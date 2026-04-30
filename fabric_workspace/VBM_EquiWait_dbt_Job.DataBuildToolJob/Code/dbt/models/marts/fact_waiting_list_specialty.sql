with typed as (
    select
        *,
        try_cast(count as int) as patient_count
    from {{ ref('int_specialty') }}
)

select
    datefromparts(
        cast(left(s.snapshot_month, 4) as int),
        cast(right(s.snapshot_month, 2) as int),
        1
    )                           as snapshot_date,
    cast('-1' as varchar(32))             as geography_sk,
    sp.specialty_sk             as specialty_sk,
    d.demographic_sk            as demographic_sk,
    w.waiting_band_sk           as waiting_band_sk,
    s.patient_count             as patient_count
from typed s
inner join {{ ref('dim_specialty') }} sp
    on  s.treatment_function_code = sp.treatment_function_code
    and datefromparts(
            cast(left(s.snapshot_month, 4) as int),
            cast(right(s.snapshot_month, 2) as int),
            1
        ) between sp.valid_from_date and sp.valid_to_date
inner join {{ ref('dim_demographic') }} d
    on  s.metric   = d.demographic_dimension
    and s.category = d.demographic_value
inner join {{ ref('dim_waiting_band') }} w
    on s.waiting_bands = w.band_label
where s.patient_count is not null;