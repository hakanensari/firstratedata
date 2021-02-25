#!/bin/bash

enable_timescale ()
{
	psql -c "CREATE EXTENSION IF NOT EXISTS timescaledb" $database_url
}

create_tables ()
{
	# Some datasets come with apparently-incorrect fractional values for volume,
	# so for now, I'm defaulting volume to numeric type.
	psql $database_url <<-SQL
		CREATE TABLE IF NOT EXISTS stocks (
			symbol TEXT NOT NULL,
			datetime TIMESTAMP NOT NULL,
			open NUMERIC NOT NULL,
			high NUMERIC NOT NULL,
			low NUMERIC NOT NULL,
			close NUMERIC NOT NULL,
			volume NUMERIC NOT NULL
		);

		CREATE TABLE IF NOT EXISTS etfs (
			symbol TEXT NOT NULL,
			datetime TIMESTAMP NOT NULL,
			open NUMERIC NOT NULL,
			high NUMERIC NOT NULL,
			low NUMERIC NOT NULL,
			close NUMERIC NOT NULL,
			volume NUMERIC NOT NULL
		);

		CREATE TABLE IF NOT EXISTS indices (
			symbol TEXT NOT NULL,
			datetime TIMESTAMP NOT NULL,
			open NUMERIC NOT NULL,
			high NUMERIC NOT NULL,
			low NUMERIC NOT NULL,
			close NUMERIC NOT NULL
		);

		SELECT create_hypertable('stocks', 'datetime');
		SELECT create_hypertable('etfs', 'datetime');
		SELECT create_hypertable('indices', 'datetime');
	SQL
}

create_rth_views ()
{
	psql $database_url <<-SQL
		CREATE OR REPLACE VIEW stocks_rth AS
			SELECT *
			FROM stocks
			WHERE EXTRACT(EPOCH FROM datetime::time) >= 34200
				AND EXTRACT(EPOCH FROM datetime::time) <= 57600;

		CREATE OR REPLACE VIEW etfs_rth AS
			SELECT *
			FROM etfs
			WHERE EXTRACT(EPOCH FROM datetime::time) >= 34200
				AND EXTRACT(EPOCH FROM datetime::time) <= 57600;

		CREATE OR REPLACE VIEW assets_rth AS
			SELECT *
			FROM stocks_rth
			UNION ALL
			SELECT *
			FROM etfs_rth;
	SQL
}

create_rth_1d_view ()
{
	psql $database_url <<-SQL
		DROP MATERIALIZED VIEW IF EXISTS stocks_rth_1d;
		CREATE MATERIALIZED VIEW IF NOT EXISTS stocks_rth_1d AS
			SELECT symbol,
				datetime,
				(
					SELECT open
					FROM stocks_rth
					WHERE symbol = stocks_rth_1d_ungrouped.symbol
					AND datetime::date = stocks_rth_1d_ungrouped.datetime
					LIMIT 1
				) AS open,
				MAX(high) AS high,
				MIN(low) AS low,
				(
					SELECT close
					FROM stocks_rth
					WHERE symbol = stocks_rth_1d_ungrouped.symbol
					AND datetime::date = stocks_rth_1d_ungrouped.datetime
					ORDER BY datetime DESC
					LIMIT 1
				) AS close,
				SUM(volume)
			FROM (
				SELECT symbol,
					datetime::date as datetime,
					open,
					high,
					low,
					close,
					volume
				FROM stocks_rth
			) AS stocks_rth_1d_ungrouped
			GROUP BY symbol, datetime;
		CREATE UNIQUE INDEX stocks_rth_1d_symbol_datetime_key
			ON stocks_rth_1d (symbol, datetime);
	SQL
}

usage ()
{
	echo "usage: setup [database]"
}

database_url=$1
if [[ -z $database_url || -n $2 ]]; then
	usage
	exit 1
fi

enable_timescale
create_tables
create_rth_views
# create_rth_1d_view
