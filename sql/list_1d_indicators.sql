WITH dataset AS (
    SELECT *
    FROM assets_1d_rth
    WHERE {{symbol}}
	AND datetime > {{start_date}}::DATE - interval '1 year'
	AND datetime < {{end_date}} + interval '1 day'
), true_ranges AS (
	SELECT
		symbol,
		datetime,
		(
			SELECT greatest(now.high - now.low, abs(now.high - previous."close"), abs(now.low - previous."close"))
			FROM dataset AS previous
			WHERE datetime < now.datetime
			AND symbol = now.symbol
			ORDER BY datetime DESC
			LIMIT 1
		) AS tr
	FROM dataset AS now
)
SELECT
	symbol,
	datetime,
	"close",
	(
	    SELECT avg("close")
	    FROM (
	        SELECT *
	        FROM dataset
	        WHERE datetime <= fd.datetime
	        AND symbol = fd.symbol
	        ORDER BY datetime DESC
	        LIMIT 55
	   ) AS ss
	) AS close_sma55,
	(
	    SELECT avg("close")
	    FROM (
	        SELECT *
	        FROM dataset
	        WHERE datetime <= fd.datetime
	        AND symbol = fd.symbol
	        ORDER BY datetime DESC
	        LIMIT 233
	   ) AS ss
	) AS close_sma233,
	(
	    SELECT tr
	    FROM true_ranges
		WHERE datetime = fd.datetime
		AND symbol = fd.symbol
	) AS tr,
	(
	    SELECT avg(tr)
	    FROM (
	        SELECT *
	        FROM true_ranges
	        WHERE datetime <= fd.datetime
	        AND symbol = fd.symbol
	        ORDER BY datetime DESC
	        LIMIT 14
	   ) AS ss
	) AS atr
FROM dataset AS fd
WHERE datetime > {{start_date}}
ORDER BY datetime, symbol;
