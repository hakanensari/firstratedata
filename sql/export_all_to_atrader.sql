WITH dataset AS (
	SELECT *
	FROM assets_1m_rth
	WHERE {{symbol}}
	AND datetime >= {{datetime}}
	AND datetime < {{datetime}} + interval '1 day'
), synthetic_dataset AS (
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) AS printtime,
		symbol AS "name",
		open AS "last",
		(volume / 6)::INT AS print_size
	FROM dataset
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 10 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN least(high, lag(high) OVER (PARTITION BY symbol ORDER BY datetime))
			ELSE greatest(low, lag(low) OVER (PARTITION BY symbol ORDER BY datetime))
		END AS "last",
		(volume / 6)::INT AS print_size
	FROM dataset
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 20 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN high
			ELSE low
		END AS "last",
		(volume / 6)::INT AS print_size
	FROM dataset
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 30 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN greatest(low, lag(low) OVER (PARTITION BY symbol ORDER BY datetime))
			ELSE least(high, lag(high) OVER (PARTITION BY symbol ORDER BY datetime))
		END AS "last",
		(volume / 6)::INT AS print_size
	FROM dataset
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 40 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN low
			ELSE high
		END AS "last",
		(volume / 6)::INT AS print_size
	FROM dataset
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 50 AS printtime,
		symbol AS "name",
		"close" AS "last",
		(volume / 6)::INT AS print_size
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
