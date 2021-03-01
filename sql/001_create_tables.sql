CREATE EXTENSION IF NOT EXISTS timescaledb;

DROP TABLE IF EXISTS stocks_1m CASCADE;

DROP TABLE IF EXISTS etfs_1m CASCADE;

DROP TABLE IF EXISTS indexes_1m CASCADE;

-- Set volume to numeric because some datasets contain fractional values

CREATE TABLE stocks_1m (
  symbol TEXT NOT NULL,
  datetime TIMESTAMP NOT NULL,
  "open" DECIMAL NOT NULL,
  high DECIMAL NOT NULL,
  low DECIMAL NOT NULL,
  "close" DECIMAL NOT NULL,
  volume DECIMAL NOT NULL
);

CREATE TABLE etfs_1m (
  symbol TEXT NOT NULL,
  datetime TIMESTAMP NOT NULL,
  "open" DECIMAL NOT NULL,
  high DECIMAL NOT NULL,
  low DECIMAL NOT NULL,
  "close" DECIMAL NOT NULL,
  volume DECIMAL NOT NULL
);

CREATE TABLE indexes_1m (
  symbol TEXT NOT NULL,
  datetime TIMESTAMP NOT NULL,
  "open" DECIMAL NOT NULL,
  high DECIMAL NOT NULL,
  low DECIMAL NOT NULL,
  "close" DECIMAL NOT NULL
);

CREATE INDEX stocks_1m_symbol_datetime_idx ON stocks_1m (symbol, datetime DESC);

CREATE INDEX etfs_1m_symbol_datetime_idx ON etfs_1m (symbol, datetime DESC);

CREATE INDEX indexes_1m_symbol_datetime_idx ON indexes_1m (symbol, datetime DESC);

SELECT create_hypertable('stocks_1m', 'datetime');

SELECT add_reorder_policy('stocks_1m', 'stocks_1m_symbol_datetime_idx');

SELECT create_hypertable('etfs_1m', 'datetime');

SELECT add_reorder_policy('etfs_1m', 'etfs_1m_symbol_datetime_idx');

SELECT create_hypertable('indexes_1m', 'datetime');

SELECT add_reorder_policy('indexes_1m', 'indexes_1m_symbol_datetime_idx');
