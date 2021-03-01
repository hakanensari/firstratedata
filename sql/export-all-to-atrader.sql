WITH daily_snapshot AS
  ( SELECT *
   FROM assets_rth
   WHERE symbol = any(regexp_split_to_array(upper({{ symbols }}), ',\s*'))
     AND datetime::date = {{ date }}),
     ticks AS
  ( SELECT extract(epoch
                   FROM datetime::time) AS printtime,
           symbol AS name,
           OPEN AS LAST,
                   (volume / 4)::int AS print_size
   FROM daily_snapshot
   UNION ALL SELECT extract(epoch
                            FROM datetime::time) + 15 AS printtime,
                    symbol AS name,
                    CASE
                        WHEN OPEN > CLOSE THEN high
                        ELSE low
                    END AS LAST,
                    (volume / 4)::int AS print_size
   FROM daily_snapshot
   UNION ALL SELECT extract(epoch
                            FROM datetime::time) + 30 AS printtime,
                    symbol AS name,
                    CASE
                        WHEN OPEN > CLOSE THEN low
                        ELSE high
                    END AS LAST,
                    (volume / 4)::int AS print_size
   FROM daily_snapshot
   UNION ALL SELECT extract(epoch
                            FROM datetime::time) + 45 AS printtime,
                    symbol AS name,
                    CLOSE AS LAST,
                             (volume / 4)::int AS print_size
   FROM daily_snapshot)
SELECT printtime,
       name,
       (row_number() over (partition BY name
                           ORDER BY printtime)) AS print_count,
       'NSDQ' AS primary_exchange_name,
       'NSDQ' AS exec_exchange_name,
       LAST,
       0 AS SIZE,
       print_size,

  ( SELECT OPEN
   FROM daily_snapshot
   WHERE symbol = name
     AND datetime >= {{ date }}::TIMESTAMP + 34200 * interval '1 second' LIMIT 1 ) AS xopen,
       0 AS avgprice,
       0 AS bid,
       0 AS ask,
       0 AS pclose,
       ' ' AS sale_conditions,
       0 AS print_filter
FROM ticks
ORDER BY printtime,
         name
