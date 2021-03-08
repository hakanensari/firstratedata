-- Returns the simple moving average of the close price of specified symbol over specified number of 5-minute bars at
-- the end of specified day
CREATE OR REPLACE FUNCTION atrader_mav(text, timestamp, integer) RETURNS numeric AS $$
	WITH dataset AS (
    	SELECT "close"
    	FROM assets_5m_rth
    	WHERE symbol = $1
		AND datetime < CAST($2 AS timestamp) + interval '1 day'
		ORDER BY datetime DESC
		LIMIT $3
	)
	SELECT round(avg("close"), 4)
	FROM dataset;
$$ LANGUAGE SQL;
