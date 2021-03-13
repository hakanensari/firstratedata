-- Returns the 10-day simple moving average of the volume of specified symbol on specified day
CREATE OR REPLACE FUNCTION atrader_vol(text, timestamp, integer) RETURNS numeric AS $$
	WITH dataset AS (
    	SELECT volume
    	FROM assets_1d_rth
    	WHERE symbol = $1
		AND datetime <= $2
		AND datetime > CAST($2 AS timestamp) - interval '2 weeks'
		ORDER BY datetime DESC
		LIMIT $3
	)
	SELECT round(avg(volume))
	FROM dataset;
$$ LANGUAGE SQL;
