CREATE VIEW indicators_1d AS
  WITH true_ranges AS (
    SELECT
      now.symbol,
      now.datetime,
      greatest(now.high - now.low, abs(now.high - previous."close"), abs(now.low - previous."close")) AS tr
    FROM assets_rth_1d now,
    LATERAL (
      SELECT "close"
      FROM assets_rth_1d
      WHERE datetime < now.datetime
        AND symbol = now.symbol
      ORDER BY datetime DESC
      LIMIT 1
    ) previous
  )
  SELECT
    symbol,
    datetime,
    "close",
    (
      SELECT CASE count(*) WHEN 10 THEN ROUND(sum(volume) / 10)
                                   ELSE NULL
                                   END
      FROM (
        SELECT volume
        FROM assets_rth_1d
        WHERE symbol = a.symbol
          AND datetime <= a.datetime
        ORDER BY datetime DESC
        LIMIT 10
      ) AS volumes_to_average
    ) AS volume10,
    (
      SELECT CASE count(*) WHEN 14 THEN ROUND(sum(tr) / 14, 3)
                           ELSE NULL
                           END
      FROM
      (
        SELECT tr
        FROM true_ranges
        WHERE symbol = a.symbol
          AND datetime <= a.datetime
        ORDER BY datetime DESC
        LIMIT 14
      ) AS true_ranges_to_average
    ) AS atr,
    NULL AS mav55,
    NULL AS mav233,
    NULL AS dayoftheweek,
    (
      SELECT high
      FROM assets_rth_1d
      WHERE symbol = a.symbol
        AND datetime <= a.datetime
      ORDER BY datetime DESC
      LIMIT 1
    ) AS predayhi,
    (
      SELECT low
      FROM assets_rth_1d
      WHERE symbol = a.symbol
        AND datetime <= a.datetime
      ORDER BY datetime DESC
      LIMIT 1
    ) AS predaylow
  FROM assets_rth_1d AS a;
