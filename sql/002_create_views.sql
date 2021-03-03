CREATE OR REPLACE VIEW stocks_rth_1m AS
  SELECT *
  FROM stocks_1m
  WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
    AND EXTRACT(EPOCH FROM datetime::TIME) <= 57600;

CREATE OR REPLACE VIEW etfs_rth_1m AS
  SELECT *
  FROM etfs_1m
  WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
    AND EXTRACT(EPOCH FROM datetime::TIME) <= 57600;

DROP MATERIALIZED VIEW IF EXISTS stocks_rth_5m CASCADE;

CREATE MATERIALIZED VIEW stocks_rth_5m
WITH (timescaledb.continuous) AS
  SELECT
    symbol,
    time_bucket('5m', datetime) AS datetime,
    first("open", datetime) AS "open",
    max(high) AS high,
    min(low) AS low,
    last("close", datetime) AS "close",
    sum(volume) AS volume
  FROM stocks_1m
  WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
    AND EXTRACT(EPOCH FROM datetime::TIME) <= 57600
  GROUP BY 1, 2;

DROP MATERIALIZED VIEW IF EXISTS etfs_rth_5m CASCADE;

CREATE MATERIALIZED VIEW etfs_rth_5m
WITH (timescaledb.continuous) AS
  SELECT
    symbol,
    time_bucket('5m', datetime) AS datetime,
    first("open", datetime) AS "open",
    max(high) AS high,
    min(low) AS low,
    last("close", datetime) AS "close",
    sum(volume) AS volume
  FROM etfs_1m
  WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
    AND EXTRACT(EPOCH FROM datetime::TIME) <= 57600
  GROUP BY 1, 2;

DROP MATERIALIZED VIEW IF EXISTS indexes_5m CASCADE;

CREATE MATERIALIZED VIEW indexes_5m
WITH (timescaledb.continuous) AS
  SELECT
    symbol,
    time_bucket('1d', datetime) AS datetime,
    first("open", datetime) AS "open",
    max(high) AS high,
    min(low) AS low,
    last("close", datetime) AS "close"
  FROM indexes_1m
  GROUP BY 1, 2;

DROP MATERIALIZED VIEW IF EXISTS stocks_rth_1h CASCADE;

CREATE MATERIALIZED VIEW stocks_rth_1h
WITH (timescaledb.continuous) AS
  SELECT
    symbol,
    time_bucket('1h', datetime) AS datetime,
    first("open", datetime) AS "open",
    max(high) AS high,
    min(low) AS low,
    last("close", datetime) AS "close",
    sum(volume) AS volume
  FROM stocks_1m
  WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
    AND EXTRACT(EPOCH FROM datetime::TIME) <= 57600
  GROUP BY 1, 2;

DROP MATERIALIZED VIEW IF EXISTS etfs_rth_1h CASCADE;

CREATE MATERIALIZED VIEW etfs_rth_1h
WITH (timescaledb.continuous) AS
  SELECT
    symbol,
    time_bucket('1h', datetime) AS datetime,
    first("open", datetime) AS "open",
    max(high) AS high,
    min(low) AS low,
    last("close", datetime) AS "close",
    sum(volume) AS volume
  FROM etfs_1m
  WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
    AND EXTRACT(EPOCH FROM datetime::TIME) <= 57600
  GROUP BY 1, 2;

DROP MATERIALIZED VIEW IF EXISTS indexes_1h CASCADE;

CREATE MATERIALIZED VIEW indexes_1h
WITH (timescaledb.continuous) AS
  SELECT
    symbol,
    time_bucket('1d', datetime) AS datetime,
    first("open", datetime) AS "open",
    max(high) AS high,
    min(low) AS low,
    last("close", datetime) AS "close"
  FROM indexes_1m
  GROUP BY 1, 2;

DROP MATERIALIZED VIEW IF EXISTS stocks_rth_1d CASCADE;

CREATE MATERIALIZED VIEW stocks_rth_1d
WITH (timescaledb.continuous) AS
  SELECT
    symbol,
    time_bucket('1d', datetime) AS datetime,
    first("open", datetime) AS "open",
    max(high) AS high,
    min(low) AS low,
    last("close", datetime) AS "close",
    sum(volume) AS volume
  FROM stocks_1m
  WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
    AND EXTRACT(EPOCH FROM datetime::TIME) <= 57600
  GROUP BY 1, 2;

DROP MATERIALIZED VIEW IF EXISTS etfs_rth_1d CASCADE;

CREATE MATERIALIZED VIEW etfs_rth_1d
WITH (timescaledb.continuous) AS
  SELECT
    symbol,
    time_bucket('1d', datetime) AS datetime,
    first("open", datetime) AS "open",
    max(high) AS high,
    min(low) AS low,
    last("close", datetime) AS "close",
    sum(volume) AS volume
  FROM etfs_1m
  WHERE EXTRACT(EPOCH FROM datetime::TIME) >= 34200
    AND EXTRACT(EPOCH FROM datetime::TIME) <= 57600
  GROUP BY 1, 2;

DROP MATERIALIZED VIEW IF EXISTS indexes_1d CASCADE;

CREATE MATERIALIZED VIEW indexes_1d
WITH (timescaledb.continuous) AS
  SELECT
    symbol,
    time_bucket('1d', datetime) AS datetime,
    first("open", datetime) AS "open",
    max(high) AS high,
    min(low) AS low,
    last("close", datetime) AS "close"
  FROM indexes_1m
  GROUP BY 1, 2;

CREATE OR REPLACE VIEW assets_1m AS
  SELECT *
  FROM stocks_1m
  UNION ALL
  SELECT *
  FROM etfs_1m;

CREATE OR REPLACE VIEW assets_rth_1m AS
  SELECT *
  FROM stocks_rth_1m
  UNION ALL
  SELECT *
  FROM etfs_rth_1m;

CREATE OR REPLACE VIEW assets_rth_5m AS
  SELECT *
  FROM stocks_rth_5m
  UNION ALL
  SELECT *
  FROM etfs_rth_5m;

CREATE OR REPLACE VIEW assets_rth_1h AS
  SELECT *
  FROM stocks_rth_1h
  UNION ALL
  SELECT *
  FROM etfs_rth_1h;

CREATE OR REPLACE VIEW assets_rth_1d AS
  SELECT *
  FROM stocks_rth_1d
  UNION ALL
  SELECT *
  FROM etfs_rth_1d;
