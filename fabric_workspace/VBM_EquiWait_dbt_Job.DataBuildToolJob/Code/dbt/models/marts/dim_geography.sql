{{ config(
    materialized='incremental',
    unique_key=['trust_code', 'valid_from_date']
) }}

{% if is_incremental() %}

with current_dim as (
    select *
    from {{ this }}
    where is_current = 1
),

incoming as (
    select distinct
        code as trust_code,
        trust_name_canonical as trust_name,
        snapshot_month
    from {{ ref('int_geography') }}
    where datefromparts(
            cast(left(snapshot_month, 4) as int),
            cast(right(snapshot_month, 2) as int),
            1
          ) > coalesce(
                (select max(valid_from_date) from {{ this }}),
                datefromparts(1900, 1, 1)
              )
),

changes as (
    select
        i.trust_code,
        i.trust_name,
        i.snapshot_month
    from incoming i
    left join current_dim d
        on i.trust_code = d.trust_code
    where d.trust_code is null
       or i.trust_name <> d.trust_name
),

close_existing as (
    select
        d.geography_sk,
        d.trust_code,
        d.trust_name,
        d.valid_from_date,
        dateadd(
            day,
            -1,
            datefromparts(
                cast(left(c.snapshot_month, 4) as int),
                cast(right(c.snapshot_month, 2) as int),
                1
            )
        ) as valid_to_date,
        0 as is_current,
        d.submission_gap,
        d.gap_reason
    from current_dim d
    inner join changes c
        on d.trust_code = c.trust_code
),

insert_new as (
    select
        {{ dbt_utils.generate_surrogate_key(['trust_code', 'snapshot_month']) }} as geography_sk,
        trust_code,
        trust_name,
        datefromparts(
            cast(left(snapshot_month, 4) as int),
            cast(right(snapshot_month, 2) as int),
            1
        ) as valid_from_date,
        cast('9999-12-31' as date) as valid_to_date,
        1 as is_current,
        case
            when trust_code = 'RHQ'
             and datefromparts(
                    cast(left(snapshot_month, 4) as int),
                    cast(right(snapshot_month, 2) as int),
                    1
                 ) >= datefromparts(2025, 7, 1)
                then 1
            else 0
        end as submission_gap,
        case
            when trust_code = 'RHQ'
             and datefromparts(
                    cast(left(snapshot_month, 4) as int),
                    cast(right(snapshot_month, 2) as int),
                    1
                 ) >= datefromparts(2025, 7, 1)
                then 'EPR migration - Oracle Cerner go-live July 2025'
            else null
        end as gap_reason
    from changes
)

select * from close_existing
union all
select * from insert_new

{% else %}

with snapshots as (
    select distinct
        code as trust_code,
        trust_name_canonical as trust_name,
        datefromparts(
            cast(left(snapshot_month, 4) as int),
            cast(right(snapshot_month, 2) as int),
            1
        ) as snapshot_date
    from {{ ref('int_geography') }}
),

numbered as (
    select
        trust_code,
        trust_name,
        snapshot_date,
        row_number() over (
            partition by trust_code
            order by snapshot_date
        ) as rn,
        lag(trust_name) over (
            partition by trust_code
            order by snapshot_date
        ) as prev_name
    from snapshots
),

change_points as (
    select
        trust_code,
        trust_name,
        snapshot_date as valid_from_date
    from numbered
    where rn = 1
       or trust_name <> prev_name
),

with_valid_to as (
    select
        trust_code,
        trust_name,
        valid_from_date,
        coalesce(
            dateadd(
                day,
                -1,
                lead(valid_from_date) over (
                    partition by trust_code
                    order by valid_from_date
                )
            ),
            cast('9999-12-31' as date)
        ) as valid_to_date
    from change_points
),

initial_load as (
    select
        {{ dbt_utils.generate_surrogate_key(['trust_code', 'valid_from_date']) }} as geography_sk,
        trust_code,
        trust_name,
        valid_from_date,
        valid_to_date,
        case when valid_to_date = cast('9999-12-31' as date) then 1 else 0 end as is_current,
        case
            when trust_code = 'RHQ'
             and valid_from_date >= datefromparts(2025, 7, 1)
                then 1
            else 0
        end as submission_gap,
        case
            when trust_code = 'RHQ'
             and valid_from_date >= datefromparts(2025, 7, 1)
                then 'EPR migration - Oracle Cerner go-live July 2025'
            else null
        end as gap_reason
    from with_valid_to
),

not_applicable as (
    select
        cast('-1' as varchar(32)) as geography_sk,
        'N/A' as trust_code,
        'Not Applicable' as trust_name,
        datefromparts(2000, 1, 1) as valid_from_date,
        cast('9999-12-31' as date) as valid_to_date,
        1 as is_current,
        0 as submission_gap,
        null as gap_reason
)

select * from initial_load
union all
select * from not_applicable

{% endif %}