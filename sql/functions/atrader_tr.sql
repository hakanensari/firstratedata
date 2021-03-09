-- Returns the true range of specified symbol on specified day
CREATE OR REPLACE FUNCTION atrader_tr(text, timestamp) RETURNS numeric AS $$
	WITH dataset AS (
    	SELECT high, low, "close"
    	FROM assets_1d_rth
    	WHERE symbol = $1
		AND datetime <= $2
		AND datetime > CAST($2 AS timestamp) - interval '1 week'
		ORDER BY datetime DESC
		LIMIT 2
	)
	SELECT (
		SELECT greatest(now.high - now.low, abs(now.high - previous."close"), abs(now.low - previous."close"))
		FROM dataset AS previous
		LIMIT 1 OFFSET 1
	)
	FROM dataset AS now
	LIMIT 1;
$$ LANGUAGE SQL;
