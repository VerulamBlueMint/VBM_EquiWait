with source as (
    select * from {{ ref('stg_geography__deduped') }}
),

trust_names as (
    select * from {{ ref('trust_name_canonical') }}
),

cleaned as (
    select
        s.Code as code,
        s.Name as trust_name_raw,
        coalesce(t.canonical_name, s.Name) as trust_name_canonical,
        s.Geography as geography,
        s.Metric as metric,
        s.Category as category,
        s.[Waiting Bands] as waiting_bands,
        s.[Count] as count,
        s.snapshot_month,
        s.source_filename,
        s.file_version,
        s.bronze_ingestion_ts,
        s.landing_ingestion_ts
    from source s
    left join trust_names t
        on s.Code = t.trust_code
       and s.Name = t.variant_name
)

select
    code,
    trust_name_raw,
    trust_name_canonical,
    geography,
    metric,
    category,
    waiting_bands,
    count,
    snapshot_month,
    source_filename,
    file_version,
    bronze_ingestion_ts,
    landing_ingestion_ts
from cleaned;