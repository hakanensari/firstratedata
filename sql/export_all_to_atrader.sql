WITH filtered_dataset AS (
	SELECT *
	FROM assets_1m_rth
	WHERE symbol = any(regexp_split_to_array(upper({{ symbols }}), ',\s*'))
	AND datetime >= {{date}}
	AND datetime < {{date}} + interval '1 day'
), ticks AS (
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) AS printtime,
		symbol AS "name",
		open AS "last",
		(volume / 4)::INT AS print_size
	FROM filtered_dataset
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 15 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN high
			ELSE low
		END AS "last",
		(volume / 4)::INT AS print_size
	FROM filtered_dataset
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 30 AS printtime,
		symbol AS "name",
		CASE
			WHEN open > "close" THEN low
			ELSE high
		END AS "last",
		(volume / 4)::INT AS print_size
	FROM filtered_dataset
	UNION ALL
	SELECT
		EXTRACT(EPOCH FROM datetime::TIME) + 45 AS printtime,
		symbol AS "name",
		"close" AS "last",
		(volume / 4)::INT AS print_size
	FROM filtered_dataset
)
SELECT
	printtime,
	"name",
	(row_number() OVER (PARTITION BY "name" ORDER BY printtime)) AS print_count,
	'NSDQ' AS primary_exchange_name,
	'NSDQ' AS exec_exchange_name,
	"last",
	0 AS size,
	print_size,
	(
		SELECT open
		FROM filtered_dataset t1
		WHERE symbol = "name"
		ORDER BY datetime
		LIMIT 1
	) AS xopen,
	0 AS avgprice,
	0 AS bid,
	0 AS ask,
	0 AS pclose,
	' ' AS sale_conditions,
	0 AS print_filter
FROM ticks
ORDER BY printtime, "name";
