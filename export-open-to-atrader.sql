-- TODO: We'll need logic to set xopens for stocks that don't open at 9:30AM?

select extract(epoch from (datetime - {{ date }}::timestamp))::integer as printtime,
    symbol as name,
    (row_number() over (partition by symbol)) as print_count,
    'NSDQ' as primary_exchange_name,
    'NSDQ' as exec_exchange_name,
    open as last,
    0 as size,
    volume as print_size,
    (
        select open
        from assets t1
        where symbol = assets.symbol
            and datetime >= {{ date }}::timestamp + 34200 * interval '1 second'
        limit 1
    ) as xopen,
    0 as avgprice,
    0 as bid,
    0 as ask,
    0 as pclose,
    ' ' as sale_conditions,
    0 as print_filter
from assets
where symbol = any(regexp_split_to_array(upper({{ symbols }}), ',\s*'))
    and datetime::date = {{ date }}
    and datetime >= {{ date }}::timestamp + 34200 * interval '1 second'
    and datetime <= {{ date }}::timestamp + 57600 * interval '1 second'
order by printtime
