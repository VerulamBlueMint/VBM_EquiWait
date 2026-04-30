with latest as (
    select
        *,
        row_number() over (
            partition by
                week_ending_date,
                metric,
                category,
                waiting_bands
            order by
                snapshot_month desc
        ) as rn
    from {{ ref('int_timeseries') }}
    where count <> '*'
)

select
    week_ending_date,
    metric,
    cast('-1' as varchar(32))      as geography_sk,
    cast('-1' as varchar(32))      as specialty_sk,
    d.demographic_sk,
    w.waiting_band_sk,
    cast(count as int)   as patient_count
from latest s
inner join {{ ref('dim_demographic') }} d
    on  s.metric   = d.demographic_dimension
    and s.category = d.demographic_value
inner join {{ ref('dim_waiting_band') }} w
    on s.waiting_bands = w.band_label
where rn = 1;