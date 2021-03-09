WITH previous_day AS (
	SELECT datetime
	FROM assets_1d_rth
	WHERE datetime < {{datetime}}
	AND datetime > CAST({{datetime}} AS timestamp) - interval '1 week'
	ORDER BY datetime DESC
	LIMIT 1
), dataset AS (
    SELECT *
    FROM assets_1d_rth
    WHERE {{symbol}}
	AND datetime = (SELECT * FROM previous_day)
)
SELECT
	symbol,
	"close" AS "${CLOSE}",
	atrader_vol(symbol, datetime) AS "${VOLUME}",
	atrader_atr(symbol, datetime) AS "${ATR}",
	atrader_tr(symbol, datetime) AS "${sATR}",
	atrader_mav(symbol, datetime + interval '15 hours 55 minutes', 55) AS "${Mav55}",
	atrader_mav(symbol, datetime + interval '15 hours 55 minutes', 233) AS "${Mav233}",
	EXTRACT(DOW FROM {{datetime}}) AS "${Dayoftheweek}",
	high AS "${preDayhi}",
	low AS "${predaylow}"
FROM dataset
ORDER BY symbol;
