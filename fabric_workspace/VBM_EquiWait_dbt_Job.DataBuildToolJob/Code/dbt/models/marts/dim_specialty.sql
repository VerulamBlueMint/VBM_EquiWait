{{ config(
    materialized='incremental',
    unique_key=['treatment_function_code', 'valid_from_date']
) }}

{% if is_incremental() %}

with current_dim as (
    select *
    from {{ this }}
    where is_current = 1
),

incoming as (
    select distinct
        treatment_function_code,
        treatment_function_code as treatment_function_name,
        snapshot_month
    from {{ ref('int_specialty') }}
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
    select i.*
    from incoming i
    left join current_dim d
        on i.treatment_function_code = d.treatment_function_code
    where d.treatment_function_code is null
       or i.treatment_function_name <> d.treatment_function_name
),

close_existing as (
    select
        d.specialty_sk,
        d.treatment_function_code,
        d.treatment_function_name,
        d.grouping,
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
        0 as is_current
    from current_dim d
    inner join changes c
        on d.treatment_function_code = c.treatment_function_code
),

insert_new as (
    select
        {{ dbt_utils.generate_surrogate_key(
            ['treatment_function_code', 'snapshot_month']) }} as specialty_sk,
        treatment_function_code,
        treatment_function_name,
        null as grouping,
        datefromparts(
            cast(left(snapshot_month, 4) as int),
            cast(right(snapshot_month, 2) as int),
            1
        ) as valid_from_date,
        cast('9999-12-31' as date) as valid_to_date,
        1 as is_current
    from changes
)

select * from close_existing
union all
select * from insert_new

{% else %}

with snapshots as (
    select distinct
        treatment_function_code,
        treatment_function_code as treatment_function_name,
        datefromparts(
            cast(left(snapshot_month, 4) as int),
            cast(right(snapshot_month, 2) as int),
            1
        ) as snapshot_date
    from {{ ref('int_specialty') }}
),

numbered as (
    select
        treatment_function_code,
        treatment_function_name,
        snapshot_date,
        row_number() over (
            partition by treatment_function_code
            order by snapshot_date
        ) as rn,
        lag(treatment_function_name) over (
            partition by treatment_function_code
            order by snapshot_date
        ) as prev_name
    from snapshots
),

change_points as (
    select
        treatment_function_code,
        treatment_function_name,
        snapshot_date as valid_from_date
    from numbered
    where rn = 1
       or treatment_function_name <> prev_name
),

with_valid_to as (
    select
        treatment_function_code,
        treatment_function_name,
        valid_from_date,
        coalesce(
            dateadd(
                day,
                -1,
                lead(valid_from_date) over (
                    partition by treatment_function_code
                    order by valid_from_date
                )
            ),
            cast('9999-12-31' as date)
        ) as valid_to_date
    from change_points
),

initial_load as (
    select
        {{ dbt_utils.generate_surrogate_key(
            ['treatment_function_code', 'valid_from_date']) }} as specialty_sk,
        treatment_function_code,
        treatment_function_name,
        null as grouping,
        valid_from_date,
        valid_to_date,
        case when valid_to_date = cast('9999-12-31' as date) then 1 else 0 end as is_current
    from with_valid_to
),

not_applicable as (
    select
        cast('-1' as varchar(32)) as specialty_sk,
        'N/A' as treatment_function_code,
        'Not Applicable' as treatment_function_name,
        null as grouping,
        datefromparts(2000, 1, 1) as valid_from_date,
        cast('9999-12-31' as date) as valid_to_date,
        1 as is_current
)

select * from initial_load
union all
select * from not_applicable

{% endif %}