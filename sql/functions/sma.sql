-- Here we calculate simple moving avrage using a window function
SELECT
	*,
	AVG("close") OVER(ORDER BY datetime ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS sma5
FROM assets_1m_rth
