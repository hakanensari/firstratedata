-- Returns the average true range of specified symbol on specified day
CREATE OR REPLACE FUNCTION atrader_atr(text, timestamp) RETURNS numeric AS $$
	WITH dataset AS (
    	SELECT datetime
    	FROM assets_1d_rth
    	WHERE symbol = $1
		AND datetime <= $2
		ORDER BY datetime DESC
		LIMIT 14
	)
	SELECT round(avg(atrader_tr($1, datetime)), 4)
	FROM dataset;
$$ LANGUAGE SQL;
