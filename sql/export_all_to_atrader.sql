WITH dataset AS (
	SELECT *
	FROM assets_1m_rth
	WHERE {{symbol}}
	AND datetime >= {{datetime}}
	AND datetime < {{datetime}} + interval '1 day'
), synthetic_dataset AS (
	SELECT
		EXTRACT(EPOCH FROM CAST(datetime AS time)) AS printtime,
		symbol AS "name",
		open AS "last",
		(volume / 20)::INT AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 1) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(open + (high - open) * 1 / 5, 4)
			ELSE round(open - (open - low) * 1 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 2) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(open + (high - open) * 2 / 5, 4)
			ELSE round(open - (open - low) * 2 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 3) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(open + (high - open) * 3 / 5, 4)
			ELSE round(open - (open - low) * 3 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 4) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(open + (high - open) * 4 / 5, 4)
			ELSE round(open - (open - low) * 4 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 5) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN high
			ELSE low
		END AS "last",
		(volume / 6)::INT AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 6) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(high - (high - low) * 1 / 5, 4)
			ELSE round(low + (high - low) * 1 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 7) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(high - (high - low) * 2 / 5, 4)
			ELSE round(low + (high - low) * 2 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 8) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(high - (high - low) * 3 / 5, 4)
			ELSE round(low + (high - low) * 3 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 9) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(high - (high - low) * 4 / 5, 4)
			ELSE round(low + (high - low) * 4 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 10) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN low
			ELSE high
		END AS "last",
		(volume / 6)::INT AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 11) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(low + ("close" - low) * 1 / 5, 4)
			ELSE round(high - (high - "close") * 1 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 12) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(low + ("close" - low) * 2 / 5, 4)
			ELSE round(high - (high - "close") * 2 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 13) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(low + ("close" - low) * 3/ 5, 4)
			ELSE round(high - (high - "close") * 3 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 14) AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN round(low + ("close" - low) * 4 / 5, 4)
			ELSE round(high - (high - "close") * 4 / 5, 4)
		END AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
	UNION ALL
	SELECT
		round(EXTRACT(EPOCH FROM CAST(datetime AS time)) + 3.75 * 15) AS printtime,
		symbol AS "name",
		"close" AS "last",
		CAST(volume / 16 AS int) AS print_size
	FROM dataset
)
SELECT
	printtime,
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
