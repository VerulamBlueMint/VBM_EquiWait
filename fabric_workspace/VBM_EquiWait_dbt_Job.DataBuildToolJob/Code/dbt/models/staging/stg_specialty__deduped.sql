with ranked as (
    select
        [Treatment Function Code],
        Metric,
        Category,
        [Waiting Bands],
        [Count],
        snapshot_month,
        source_filename,
        file_version,
        bronze_ingestion_ts,
        landing_ingestion_ts,
        row_number() over (
            partition by
                snapshot_month,
                [Treatment Function Code],
                Metric,
                Category,
                [Waiting Bands]
            order by
                file_version desc,
                landing_ingestion_ts desc
        ) as rn
    from {{ source('landing', 'wlmds_specialty_landing') }}
)

select
    [Treatment Function Code],
    Metric,
    Category,
    [Waiting Bands],
    [Count],
    snapshot_month,
    source_filename,
    file_version,
    bronze_ingestion_ts,
    landing_ingestion_ts
from ranked
where rn = 1;