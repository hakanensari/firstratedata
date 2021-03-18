WITH dataset AS (
	SELECT *
	FROM assets_1m_rth
	WHERE {{symbol}}
	AND datetime >= {{datetime}}
	AND datetime < CAST({{datetime}} AS timestamp) + interval '1 day'
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
),
synthetic_dataset AS (
	-- volume >= 1600
	SELECT
		EXTRACT(EPOCH FROM CAST(datetime AS time)) AS printtime,
		symbol AS "name",
		open AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 1) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(open + (high - open) * 1 / 5, 4)
			ELSE round(open - (open - low) * 1 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 2) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(open + (high - open) * 2 / 5, 4)
			ELSE round(open - (open - low) * 2 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 3) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(open + (high - open) * 3 / 5, 4)
			ELSE round(open - (open - low) * 3 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 4) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(open + (high - open) * 4 / 5, 4)
			ELSE round(open - (open - low) * 4 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 5) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN high
			ELSE low
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 6) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(high - (high - low) * 1 / 5, 4)
			ELSE round(low + (high - low) * 1 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 7) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(high - (high - low) * 2 / 5, 4)
			ELSE round(low + (high - low) * 2 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 8) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(high - (high - low) * 3 / 5, 4)
			ELSE round(low + (high - low) * 3 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 9) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(high - (high - low) * 4 / 5, 4)
			ELSE round(low + (high - low) * 4 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 10) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN low
			ELSE high
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 11) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(low + ("close" - low) * 1 / 5, 4)
			ELSE round(high - (high - "close") * 1 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 12) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(low + ("close" - low) * 2 / 5, 4)
			ELSE round(high - (high - "close") * 2 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 13) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(low + ("close" - low) * 3/ 5, 4)
			ELSE round(high - (high - "close") * 3 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 14) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(low + ("close" - low) * 4 / 5, 4)
			ELSE round(high - (high - "close") * 4 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 15) AS printtime,
		symbol AS "name",
		"close" AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_1600

	-- vol >= 600 and vol < 1600
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) AS printtime,
		symbol AS "name",
		open AS "last",
		CAST(volume / 6 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_600_and_below_1600
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 10 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN least(high, lag(high) OVER (PARTITION BY symbol ORDER BY datetime))
			ELSE greatest(low, lag(low) OVER (PARTITION BY symbol ORDER BY datetime))
		END AS "last",
		CAST(volume / 6 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_600_and_below_1600
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 20 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN high
			ELSE low
		END AS "last",
		CAST(volume / 6 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_600_and_below_1600
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 30 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN greatest(low, lag(low) OVER (PARTITION BY symbol ORDER BY datetime))
			ELSE least(high, lag(high) OVER (PARTITION BY symbol ORDER BY datetime))
		END AS "last",
		CAST(volume / 6 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_600_and_below_1600
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 40 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN low
			ELSE high
		END AS "last",
		CAST(volume / 6 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_600_and_below_1600
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 50 AS printtime,
		symbol AS "name",
		"close" AS "last",
		CAST(volume / 6 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_600_and_below_1600

	-- vol >= 400 and vol < 600
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) AS printtime,
		symbol AS "name",
		open AS "last",
		CAST(volume / 4 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_400_and_below_600
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 15 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN high
			ELSE low
		END AS "last",
		CAST(volume / 4 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_400_and_below_600
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 30 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN low
			ELSE high
		END AS "last",
		CAST(volume / 4 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_400_and_below_600
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 45 AS printtime,
		symbol AS "name",
		"close" AS "last",
		CAST(volume / 4 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_400_and_below_600

	-- vol >= 300 and vol < 400
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) AS printtime,
		symbol AS "name",
		open AS "last",
		CAST(volume / 3 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_300_and_below_400
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 20 AS printtime,
		symbol AS "name",
		CASE
			WHEN low != open OR low != "close" THEN low
			ELSE high
		END AS "last",
		CAST(volume / 3 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_300_and_below_400
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 40 AS printtime,
		symbol AS "name",
		"close" AS "last",
		CAST(volume / 3 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_300_and_below_400

	-- vol >= 200 and vol < 300
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) AS printtime,
		symbol AS "name",
		open AS "last",
		CAST(volume / 2 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_200_and_below_300
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 30 AS printtime,
		symbol AS "name",
		"close" AS "last",
		CAST(volume / 2 AS int) AS print_size
	FROM dataset_with_volume_equal_to_or_above_200_and_below_300

	-- vol < 200
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) AS printtime,
		symbol AS "name",
		open AS "last",
		CAST(volume AS int) AS print_size
	FROM dataset_with_volume_below_200
)
SELECT
	CAST(printtime AS int),
	"name",
	row_number() OVER (PARTITION BY "name" ORDER BY printtime) AS print_count,
	'NSDQ' AS primary_exchange_name,
	'NSDQ' AS exec_exchange_name,
	"last",
	0 AS size,
	print_size,
	first_value(last) OVER (PARTITION BY "name" ORDER BY printtime) AS xopen,
	0 AS avgprice,
	0 AS bid,
	0 AS ask,
	0 AS pclose,
	' ' AS sale_conditions,
	0 AS print_filter
FROM synthetic_dataset
ORDER BY printtime, "name";
