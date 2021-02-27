#!/bin/bash

enable_timescale ()
{
	psql -c "CREATE EXTENSION IF NOT EXISTS timescaledb" $database_url
}

# Some datasets come with apparently-incorrect fractional values for volume,
# so for now, I'm defaulting volume to numeric type.
create_stocks_table ()
{
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
		SELECT create_hypertable('stocks', 'datetime');
	SQL
}

create_etfs_table ()
{
	psql $database_url <<-SQL
		CREATE TABLE IF NOT EXISTS etfs (
			symbol TEXT NOT NULL,
			datetime TIMESTAMP NOT NULL,
			open NUMERIC NOT NULL,
			high NUMERIC NOT NULL,
			low NUMERIC NOT NULL,
			close NUMERIC NOT NULL,
			volume NUMERIC NOT NULL
		);
		SELECT create_hypertable('etfs', 'datetime');
	SQL
}

create_indices_table ()
{
	psql $database_url <<-SQL
		CREATE TABLE IF NOT EXISTS indices (
			symbol TEXT NOT NULL,
			datetime TIMESTAMP NOT NULL,
			open NUMERIC NOT NULL,
			high NUMERIC NOT NULL,
			low NUMERIC NOT NULL,
			close NUMERIC NOT NULL
		);
		SELECT create_hypertable('indices', 'datetime');
	SQL
}

create_stocks_rth_view ()
{
	psql $database_url <<-SQL
		CREATE OR REPLACE VIEW stocks_rth AS
			SELECT *
			FROM stocks
			WHERE EXTRACT(EPOCH FROM datetime::time) >= 34200
				AND EXTRACT(EPOCH FROM datetime::time) <= 57600;
	SQL
}

create_etfs_rth_view ()
{
	psql $database_url <<-SQL
		CREATE OR REPLACE VIEW etfs_rth AS
			SELECT *
			FROM etfs
			WHERE EXTRACT(EPOCH FROM datetime::time) >= 34200
				AND EXTRACT(EPOCH FROM datetime::time) <= 57600;

	SQL
}

create_assets_rth_view ()
{
	psql $database_url <<-SQL
		CREATE OR REPLACE VIEW assets_rth AS
			SELECT *
			FROM stocks_rth
			UNION ALL
			SELECT *
			FROM etfs_rth;
	SQL
}

create_indices_1d_view ()
{
	psql $database_url <<-SQL
		DROP MATERIALIZED VIEW IF EXISTS indices_1d;
		CREATE MATERIALIZED VIEW IF NOT EXISTS indices_1d AS
			SELECT symbol,
				datetime::DATE::TIMESTAMP as datetime,
				FIRST(open, datetime) as open,
				MAX(high) AS high,
				MIN(low) AS low,
				LAST(close, datetime) AS close
			FROM indices
			GROUP BY 1, 2;
		CREATE INDEX indices_1d_symbol_datetime_idx ON indices_1d (symbol, datetime);
	SQL
}

create_stocks_rth_1d_view ()
{
	psql $database_url <<-SQL
		DROP MATERIALIZED VIEW IF EXISTS stocks_rth_1d;
		CREATE MATERIALIZED VIEW IF NOT EXISTS stocks_rth_1d AS
			SELECT symbol,
				datetime::DATE::TIMESTAMP as datetime,
				FIRST(open, datetime) as open,
				MAX(high) AS high,
				MIN(low) AS low,
				LAST(close, datetime) AS close,
				SUM(volume) as volume
			FROM stocks_rth
			GROUP BY 1, 2;
		CREATE INDEX stocks_rth_1d_symbol_datetime_idx ON stocks_rth_1d (symbol, datetime);
	SQL
}

create_etfs_rth_1d_view ()
{
	psql $database_url <<-SQL
		DROP MATERIALIZED VIEW IF EXISTS etfs_rth_1d;
		CREATE MATERIALIZED VIEW IF NOT EXISTS etfs_rth_1d AS
			SELECT symbol,
				datetime::DATE::TIMESTAMP as datetime,
				FIRST(open, datetime) as open,
				MAX(high) AS high,
				MIN(low) AS low,
				LAST(close, datetime) AS close,
				SUM(volume) as volume
			FROM etfs_rth
			GROUP BY 1, 2;
		CREATE INDEX etfs_rth_1d_symbol_datetime_idx ON etfs_rth_1d (symbol, datetime);
	SQL
}

create_assets_rth_1d_view ()
{
	psql $database_url <<-SQL
		CREATE OR REPLACE VIEW assets_rth_1d AS
			SELECT *
			FROM stocks_rth_1d
			UNION ALL
			SELECT *
			FROM etfs_rth_1d;
	SQL
}

create_indicators_view ()
{
	psql $database_url <<-SQL
		CREATE OR REPLACE VIEW indicators AS
			WITH true_ranges AS (
				SELECT today.symbol,
					today.datetime,
					GREATEST(today.high - today.low, ABS(today.high - yesterday.close), ABS(today.low - yesterday.close)) AS tr
				FROM stocks_rth_1d today,
				LATERAL (
						SELECT close
						FROM assets_rth_1d
						WHERE datetime < today.datetime
						AND symbol = today.symbol
						ORDER by datetime DESC
						LIMIT 1
				) yesterday
			)
			SELECT symbol,
				datetime,
				close,
				(
					SELECT CASE WHEN count(*) = 10 THEN ROUND(SUM(volume) / 10) ELSE null END
					FROM (
						SELECT volume
						FROM assets_rth_1d
						WHERE symbol = a.symbol
						AND datetime <= a.datetime
						ORDER BY datetime DESC
						LIMIT 10
					) AS volumes_to_average
				) AS volume10,
				(
					SELECT CASE WHEN count(*) = 14 THEN ROUND(SUM(tr) / 14, 3) ELSE null END
					FROM (
						SELECT tr
						FROM true_ranges
						WHERE symbol = a.symbol
						AND datetime <= a.datetime
						ORDER BY datetime DESC
						LIMIT 14
					) AS true_ranges_to_average
				) AS atr,
				NULL AS mav55,
				NULL AS mav233,
				NULL AS dayoftheweek,
				(
					SELECT high
					FROM assets_rth_1d
					WHERE symbol = a.symbol
					AND datetime <= a.datetime
					ORDER BY datetime DESC
					LIMIT 1
				) AS predayhi,
				(
					SELECT low
					FROM assets_rth_1d
					WHERE symbol = a.symbol
					AND datetime <= a.datetime
					ORDER BY datetime DESC
					LIMIT 1
				) AS predaylow
			FROM assets_rth_1d AS a;
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
create_stocks_table
create_etfs_table
create_indices_table
create_stocks_rth_view
create_etfs_rth_view
create_assets_rth_view
create_indices_1d_view
create_stocks_rth_1d_view
create_etfs_rth_1d_view
create_assets_rth_1d_view
create_indicators_view
