with source as (
    select * from {{ ref('stg_timeseries__deduped') }}
),

cleaned as (
    select
        coalesce(
            try_cast([Week Ending Date] as date),
            try_cast(left([Week Ending Date], 10) as date),
            try_convert(date, [Week Ending Date], 103)
        ) as week_ending_date,
        Metric as metric,
        Category as category,
        [Waiting Bands] as waiting_bands,
        [Count] as count,
        snapshot_month,
        source_filename,
        file_version,
        bronze_ingestion_ts,
        landing_ingestion_ts
    from source
)

select * from cleaned;