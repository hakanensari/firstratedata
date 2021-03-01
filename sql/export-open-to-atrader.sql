-- TODO: We'll need logic to set xopens for stocks that don't open at 9:30AM?

SELECT extract(epoch
               FROM datetime::time) AS printtime,
       symbol AS name,
       (row_number() over (partition BY symbol)) AS print_count,
       'NSDQ' AS primary_exchange_name,
       'NSDQ' AS exec_exchange_name,
       OPEN AS LAST,
               0 AS SIZE,
               volume AS print_size,

  ( SELECT OPEN
   FROM assets_rth t1
   WHERE symbol = assets_rth.symbol
     AND datetime >= {{ date }}::TIMESTAMP + 34200 * interval '1 second' LIMIT 1 ) AS xopen,
               0 AS avgprice,
               0 AS bid,
               0 AS ask,
               0 AS pclose,
               ' ' AS sale_conditions,
               0 AS print_filter
FROM assets_rth
WHERE symbol = any(regexp_split_to_array(upper({{ symbols }}), ',\s*'))
  AND datetime::date = {{ date }}
ORDER BY printtime
