with source as (
    select * from {{ ref('stg_specialty__deduped') }}
),

cleaned as (
    select
        trim(
          replace(
            replace(
              replace([Treatment Function Code], '  ', ' '),
              '  ', ' '
            ),
            '  ', ' '
          )
        ) as treatment_function_code,
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