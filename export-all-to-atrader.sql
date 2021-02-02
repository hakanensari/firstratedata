with daily_snapshot as (
    select *
    from assets
    where symbol = any(regexp_split_to_array(upper({{ symbols }}), ',\s*'))
        and datetime::date = {{ date }}
),
ticks as (
    select extract(epoch from datetime::time) as printtime,
        symbol as name,
        open as last,
        (volume / 4)::int as print_size
    from daily_snapshot
    union all
    select extract(epoch from datetime::time) + 15 as printtime,
        symbol as name,
        case when open > close then high else low end as last,
        (volume / 4)::int as print_size
    from daily_snapshot
    union all
    select extract(epoch from datetime::time) + 30 as printtime,
        symbol as name,
        case when open > close then low else high end as last,
        (volume / 4)::int as print_size
    from daily_snapshot
    union all
    select extract(epoch from datetime::time) + 45 as printtime,
        symbol as name,
        close as last,
        (volume / 4)::int as print_size
    from daily_snapshot
)
select printtime,
    name,
    (row_number() over (partition by name order by printtime)) as print_count,
    'NSDQ' as primary_exchange_name,
    'NSDQ' as exec_exchange_name,
    last,
    0 as size,
    print_size,
    (
        select open
        from daily_snapshot
        where symbol = name
            and datetime >= {{ date }}::timestamp + 34200 * interval '1 second'
        limit 1
    ) as xopen,
    0 as avgprice,
    0 as bid,
    0 as ask,
    0 as pclose,
    ' ' as sale_conditions,
    0 as print_filter
from ticks
order by printtime, name
