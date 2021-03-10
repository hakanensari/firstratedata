-- Returns the simple moving average of the close price of specified symbol over specified number of 1-minute bars at
-- the end of specified day
CREATE OR REPLACE FUNCTION atrader_mav_1m(text, timestamp, integer) RETURNS numeric AS $$
	WITH dataset AS (
    	SELECT "close"
    	FROM assets_1m_rth
    	WHERE symbol = $1
		AND datetime <= $2
		AND datetime > CAST($2 AS timestamp) - interval '1 week'
		ORDER BY datetime DESC
		LIMIT $3
	)
	SELECT round(avg("close"), 4)
	FROM dataset;
$$ LANGUAGE SQL;
