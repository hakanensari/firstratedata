WITH dataset AS (
	SELECT *
	FROM assets_1m_rth
	WHERE {{symbol}}
	AND datetime >= {{datetime}}
	AND datetime < {{datetime}} + interval '1 day'
)
SELECT
	EXTRACT(EPOCH FROM datetime::TIME) AS printtime,
	symbol AS "name",
	(row_number() OVER (PARTITION BY symbol ORDER BY datetime)) AS print_count,
	'NSDQ' AS primary_exchange_name,
	'NSDQ' AS exec_exchange_name,
	open AS "last",
	0 AS size,
	volume AS print_size,
	(
		SELECT open
		FROM dataset t1
		WHERE symbol = dataset.symbol
		ORDER BY datetime
		LIMIT 1
	) AS xopen,
	0 AS avgprice,
	0 AS bid,
	0 AS ask,
	0 AS pclose,
	' ' AS sale_conditions,
	0 AS print_filter
FROM dataset
ORDER BY printtime, "name";
