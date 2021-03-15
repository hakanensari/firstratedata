CREATE OR REPLACE VIEW stocks_1m_rth AS
	SELECT *
	FROM stocks_1m
	WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
	AND EXTRACT(EPOCH FROM datetime::TIME) < 57600
	AND datetime >= '2018-01-01'::DATE;

CREATE OR REPLACE VIEW etfs_1m_rth AS
	SELECT *
	FROM etfs_1m
	WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
	AND EXTRACT(EPOCH FROM datetime::TIME) < 57600
	AND datetime >= '2018-01-01'::DATE;

DROP MATERIALIZED VIEW IF EXISTS stocks_5m_rth CASCADE;

CREATE MATERIALIZED VIEW stocks_5m_rth
WITH (
	timescaledb.continuous,
	timescaledb.materialized_only = true
) AS
	SELECT
		symbol,
		time_bucket('5m', datetime) AS datetime,
		first(open, datetime) AS open,
		max(high) AS high,
		min(low) AS low,
		last("close", datetime) AS "close",
		sum(volume) AS volume
	FROM stocks_1m
	WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
	AND EXTRACT(EPOCH FROM datetime::TIME) < 57600
	AND datetime >= '2018-01-01'::DATE
	GROUP BY 1, 2
WITH NO DATA;

DROP MATERIALIZED VIEW IF EXISTS etfs_5m_rth CASCADE;

CREATE MATERIALIZED VIEW etfs_5m_rth
WITH (
	timescaledb.continuous,
	timescaledb.materialized_only = true
) AS
	SELECT
		symbol,
		time_bucket('5m', datetime) AS datetime,
		first(open, datetime) AS open,
		max(high) AS high,
		min(low) AS low,
		last("close", datetime) AS "close",
		sum(volume) AS volume
	FROM etfs_1m
	WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
	AND EXTRACT(EPOCH FROM datetime::TIME) < 57600
	AND datetime >= '2018-01-01'::DATE
	GROUP BY 1, 2
WITH NO DATA;

DROP MATERIALIZED VIEW IF EXISTS indexes_5m CASCADE;

CREATE MATERIALIZED VIEW indexes_5m
WITH (
	timescaledb.continuous,
	timescaledb.materialized_only = true
) AS
	SELECT
		symbol,
		time_bucket('5m', datetime) AS datetime,
		first(open, datetime) AS open,
		max(high) AS high,
		min(low) AS low,
		last("close", datetime) AS "close"
	FROM indexes_1m
	WHERE datetime >= '2018-01-01'::DATE
	GROUP BY 1, 2
WITH NO DATA;

DROP MATERIALIZED VIEW IF EXISTS stocks_1d_rth CASCADE;

CREATE MATERIALIZED VIEW stocks_1d_rth
WITH (
	timescaledb.continuous,
	timescaledb.materialized_only = true
) AS
	SELECT
		symbol,
		time_bucket('1d', datetime) AS datetime,
		first(open, datetime) AS open,
		max(high) AS high,
		min(low) AS low,
		last("close", datetime) AS "close",
		sum(volume) AS volume
	FROM stocks_1m
	WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
	AND EXTRACT(EPOCH FROM datetime::TIME) < 57600
	AND datetime >= '2018-01-01'::DATE
	GROUP BY 1, 2
WITH NO DATA;

DROP MATERIALIZED VIEW IF EXISTS etfs_1d_rth CASCADE;

CREATE MATERIALIZED VIEW etfs_1d_rth
WITH (
	timescaledb.continuous,
	timescaledb.materialized_only = true
) AS
	SELECT
		symbol,
		time_bucket('1d', datetime) AS datetime,
		first(open, datetime) AS open,
		max(high) AS high,
		min(low) AS low,
		last("close", datetime) AS "close",
		sum(volume) AS volume
	FROM etfs_1m
	WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
	AND EXTRACT(EPOCH FROM datetime::TIME) < 57600
	AND datetime >= '2018-01-01'::DATE
	GROUP BY 1, 2
WITH NO DATA;

DROP MATERIALIZED VIEW IF EXISTS indexes_1d CASCADE;

CREATE MATERIALIZED VIEW indexes_1d
WITH (
	timescaledb.continuous,
	timescaledb.materialized_only = true
) AS
	SELECT
		symbol,
		time_bucket('1d', datetime) AS datetime,
		first(open, datetime) AS open,
		max(high) AS high,
		min(low) AS low,
		last("close", datetime) AS "close"
	FROM indexes_1m
	WHERE datetime >= '2018-01-01'::DATE
	GROUP BY 1, 2
WITH NO DATA;

CREATE OR REPLACE VIEW assets_1m AS
	SELECT *
	FROM stocks_1m
	UNION ALL
	SELECT *
	FROM etfs_1m;

CREATE OR REPLACE VIEW assets_1m_rth AS
	SELECT *
	FROM stocks_1m_rth
	UNION ALL
	SELECT *
	FROM etfs_1m_rth;

CREATE OR REPLACE VIEW assets_5m_rth AS
	SELECT *
	FROM stocks_5m_rth
	UNION ALL
	SELECT *
	FROM etfs_5m_rth;

CREATE OR REPLACE VIEW assets_1d_rth AS
	SELECT *
	FROM stocks_1d_rth
	UNION ALL
	SELECT *
	FROM etfs_1d_rth;
