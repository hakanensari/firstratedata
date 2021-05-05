WITH dataset AS (
	SELECT *
	FROM assets_1m_rth
	WHERE {{symbol}}
	AND datetime >= {{startdate}}
	AND datetime < CAST({{enddate}} AS timestamp) + interval '1 day'
),
dataset_with_volume_equal_to_or_above_1600 AS (
	SELECT *
	FROM dataset
	WHERE volume >= 1600
),
dataset_with_volume_equal_to_or_above_600_and_below_1600 AS (
	SELECT *
	FROM dataset
	WHERE volume >= 600
	AND volume < 1600
),
dataset_with_volume_equal_to_or_above_400_and_below_600 AS (
	SELECT *
	FROM dataset
	WHERE volume >= 400
	AND volume < 600
),
dataset_with_volume_equal_to_or_above_300_and_below_400 AS (
	SELECT *
	FROM dataset
	WHERE volume >= 300
	AND volume < 400
),
dataset_with_volume_equal_to_or_above_200_and_below_300 AS (
	SELECT *
	FROM dataset
	WHERE volume >= 200
	AND volume < 300
),
dataset_with_volume_below_200 AS (
	SELECT *
	FROM dataset
	WHERE volume < 200
)

-- volume >= 1600
SELECT
	symbol,
	datetime,
	open as price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 1)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(open + (high - open) * 1 / 5, 4)
		ELSE round(open - (open - low) * 1 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 2)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(open + (high - open) * 2 / 5, 4)
		ELSE round(open - (open - low) * 2 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 3)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(open + (high - open) * 3 / 5, 4)
		ELSE round(open - (open - low) * 3 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 4)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(open + (high - open) * 4 / 5, 4)
		ELSE round(open - (open - low) * 4 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 5)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN high
		ELSE low
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 6)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(high - (high - low) * 1 / 5, 4)
		ELSE round(low + (high - low) * 1 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 7)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(high - (high - low) * 2 / 5, 4)
		ELSE round(low + (high - low) * 2 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 8)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(high - (high - low) * 3 / 5, 4)
		ELSE round(low + (high - low) * 3 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 9)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(high - (high - low) * 4 / 5, 4)
		ELSE round(low + (high - low) * 4 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 10)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN low
		ELSE high
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 11)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(low + ("close" - low) * 1 / 5, 4)
		ELSE round(high - (high - "close") * 1 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 12)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(low + ("close" - low) * 2 / 5, 4)
		ELSE round(high - (high - "close") * 2 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 13)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(low + ("close" - low) * 3/ 5, 4)
		ELSE round(high - (high - "close") * 3 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 14)) AS interval) AS datetime,
	CASE
		WHEN open > "close" THEN round(low + ("close" - low) * 4 / 5, 4)
		ELSE round(high - (high - "close") * 4 / 5, 4)
	END AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600
UNION ALL
SELECT
	symbol,
	datetime + CAST(format('%s seconds', round(3.75 * 15)) AS interval) AS datetime,
	"close" AS price,
	CAST(volume / 16 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_1600

-- -- vol >= 600 and vol < 1600
UNION ALL
SELECT
	symbol,
	datetime,
	open AS price,
	CAST(volume / 6 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_600_and_below_1600
UNION ALL
SELECT
	symbol,
	datetime + interval '10 seconds' AS datetime,
	CASE
		WHEN open > "close" THEN least(high, lag(high) OVER (PARTITION BY symbol ORDER BY datetime))
		ELSE greatest(low, lag(low) OVER (PARTITION BY symbol ORDER BY datetime))
	END AS price,
	CAST(volume / 6 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_600_and_below_1600
UNION ALL
SELECT
	symbol,
	datetime + interval '20 seconds' AS datetime,
	CASE
		WHEN open > "close" THEN high
		ELSE low
	END AS price,
	CAST(volume / 6 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_600_and_below_1600
UNION ALL
SELECT
	symbol,
	datetime + interval '30 seconds' AS datetime,
	CASE
		WHEN open > "close" THEN greatest(low, lag(low) OVER (PARTITION BY symbol ORDER BY datetime))
		ELSE least(high, lag(high) OVER (PARTITION BY symbol ORDER BY datetime))
	END AS price,
	CAST(volume / 6 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_600_and_below_1600
UNION ALL
SELECT
	symbol,
	datetime + interval '40 seconds' AS datetime,
	CASE
		WHEN open > "close" THEN low
		ELSE high
	END AS price,
	CAST(volume / 6 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_600_and_below_1600
UNION ALL
SELECT
	symbol,
	datetime + interval '50 seconds' AS datetime,
	"close" AS price,
	CAST(volume / 6 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_600_and_below_1600

-- -- vol >= 400 and vol < 600
UNION ALL
SELECT
	symbol,
	datetime,
	open AS price,
	CAST(volume / 4 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_400_and_below_600
UNION ALL
SELECT
	symbol,
	datetime + interval '15 seconds' AS datetime,
	CASE
		WHEN open > "close" THEN high
		ELSE low
	END AS price,
	CAST(volume / 4 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_400_and_below_600
UNION ALL
SELECT
	symbol,
	datetime + interval '30 seconds' AS datetime,
	CASE
		WHEN open > "close" THEN low
		ELSE high
	END AS price,
	CAST(volume / 4 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_400_and_below_600
UNION ALL
SELECT
	symbol,
	datetime + interval '45 seconds' AS datetime,
	"close" AS price,
	CAST(volume / 4 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_400_and_below_600

-- -- vol >= 300 and vol < 400
UNION ALL
SELECT
	symbol,
	datetime,
	open AS price,
	CAST(volume / 3 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_300_and_below_400
UNION ALL
SELECT
	symbol,
	datetime + interval '20 seconds' AS datetime,
	CASE
		WHEN low != open OR low != "close" THEN low
		ELSE high
	END AS price,
	CAST(volume / 3 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_300_and_below_400
UNION ALL
SELECT
	symbol,
	datetime + interval '40 seconds' AS datetime,
	"close" AS price,
	CAST(volume / 3 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_300_and_below_400

-- -- vol >= 200 and vol < 300
UNION ALL
SELECT
	symbol,
	datetime,
	open AS price,
	CAST(volume / 2 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_200_and_below_300
UNION ALL
SELECT
	symbol,
	datetime + interval '30 seconds' AS datetime,
	"close" AS price,
	CAST(volume / 2 AS int) AS volume
FROM dataset_with_volume_equal_to_or_above_200_and_below_300

-- -- vol < 200
UNION ALL
SELECT
	symbol,
	datetime,
	open AS price,
	CAST(volume AS int) AS volume
FROM dataset_with_volume_below_200
ORDER BY datetime, symbol;
