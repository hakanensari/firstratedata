#!/bin/bash

create_tables ()
{
	# Some datasets come with apparently-incorrect fractional values for volume,
	# so for now, I'm defaulting volume to numeric type.
	psql $database <<-SQL
		CREATE TABLE IF NOT EXISTS stocks (
			symbol TEXT,
			datetime TIMESTAMP,
			open NUMERIC NOT NULL,
			high NUMERIC NOT NULL,
			low NUMERIC NOT NULL,
			close NUMERIC NOT NULL,
			volume NUMERIC NOT NULL
		);
		CREATE TABLE IF NOT EXISTS etfs (
			symbol TEXT,
			datetime TIMESTAMP,
			open NUMERIC NOT NULL,
			high NUMERIC NOT NULL,
			low NUMERIC NOT NULL,
			close NUMERIC NOT NULL,
			volume NUMERIC NOT NULL
		);
		CREATE TABLE IF NOT EXISTS indices (
			symbol TEXT,
			datetime TIMESTAMP,
			open NUMERIC NOT NULL,
			high NUMERIC NOT NULL,
			low NUMERIC NOT NULL,
			close NUMERIC NOT NULL
		);
	SQL
}

create_views ()
{
	psql $database <<-SQL
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

database=$1
if [[ -z $database || -n $2 ]]; then
	usage
	exit 1
fi

create_tables
create_views
