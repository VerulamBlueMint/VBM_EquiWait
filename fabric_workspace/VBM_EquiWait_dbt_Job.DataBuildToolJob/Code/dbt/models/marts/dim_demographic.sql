with source as (
    select distinct
        metric   as demographic_dimension,
        category as demographic_value
    from {{ ref('int_geography') }}

    union

    select distinct
        metric,
        category
    from {{ ref('int_specialty') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(
            ['demographic_dimension', 'demographic_value']) }}
            as demographic_sk,

        demographic_dimension,
        demographic_value,

        case
            when demographic_dimension = 'IMD' then '2019'
            else null
        end as imd_version,

        case
            when demographic_value in ('Z: Not stated', '99: Not known')
                then 1
            else 0
        end as is_unknown,

        case
            when demographic_value = 'Total'
                then 1
            else 0
        end as is_total
    from source
)

select * from final;