-- Returns the average true range of specified symbol on specified day
CREATE OR REPLACE FUNCTION atrader_atr(text, timestamp, integer) RETURNS numeric AS $$
	WITH dataset AS (
    	(
    		SELECT datetime
    		FROM assets_1d_rth
    		WHERE symbol = $1
			AND datetime <= $2
			AND datetime > CAST($2 AS timestamp) - interval '4 weeks'
			ORDER BY datetime DESC
			LIMIT $3
		) UNION ALL (
			SELECT datetime
    		FROM indexes_1d
    		WHERE symbol = $1
			AND datetime <= $2
			AND datetime > CAST($2 AS timestamp) - interval '4 weeks'
			ORDER BY datetime DESC
			LIMIT $3
		)
	)
	SELECT round(avg(atrader_tr($1, datetime)), 4)
	FROM dataset;
$$ LANGUAGE SQL;
