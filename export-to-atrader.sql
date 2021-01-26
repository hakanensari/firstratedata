-- TODO: We'll need to add more logic to set xopens for stocks that don't open
-- at 9:30AM.
with opens as (
                   (select symbol,
                           "open"
                    from stocks
                    where symbol = any(regexp_split_to_array(upper({{symbols}}), ',\s*'))
                        and datetime = {{date}}::timestamp + 34200 * interval '1 second' )
               union all
                   (select symbol,
                           "open"
                    from etfs
                    where symbol = any(regexp_split_to_array(upper({{symbols}}), ',\s*'))
                        and datetime = {{date}}::timestamp + 34200 * interval '1 second' ))
select extract(epoch
               from (datetime - {{date}}::timestamp)) as printtime,
       symbol as name,
       row_number() over () as printcount,
                         'NSDQ' as primary_exchange_name,
                         'NSDQ' as exec_exchange_name,
       "open" as last,
                                 0 as size,
                                 volume as print_size,

    (select "open"
     from opens
     where symbol = assets.symbol
     limit 1) as xopen,
                                 0 as avgprice,
                                 0 as bid,
                                 0 as ask,
                                 0 as pclose,
                                 ' ' as sale_conditions,
                                 0 as print_filter
from (
          (select *
           from stocks
           where symbol = any(regexp_split_to_array(upper({{symbols}}), ',\s*'))
               and datetime::date = {{date}}
               and datetime >= {{date}}::timestamp + 34200 * interval '1 second'
           order by datetime)
      union all
          (select *
           from etfs
           where symbol = any(regexp_split_to_array(upper({{symbols}}), ',\s*'))
               and datetime::date = {{date}}
               and datetime >= {{date}}::timestamp + 34200 * interval '1 second'
           order by datetime)
      order by datetime) as assets
