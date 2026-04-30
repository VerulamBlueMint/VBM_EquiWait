with geography_england as (
    select
        snapshot_month,
        metric,
        category,
        waiting_bands,
        sum(patient_count) as geography_count
    from (
        select
            snapshot_month,
            metric,
            category,
            waiting_bands,
            try_cast(count as int) as patient_count
        from [VBM_EquiWait_WH].[dbt_dev_intermediate].[int_geography]
        where code = 'ENG'
          and geography = 'ENGLAND'
          and metric in ('Age', 'Sex')
          and waiting_bands <> 'Total'
    ) g
    where patient_count is not null
    group by snapshot_month, metric, category, waiting_bands
),

timeseries_monthly as (
    select
        snapshot_month,
        metric,
        category,
        waiting_bands,
        patient_count as timeseries_count
    from (
        select
            format(week_ending_date, 'yyyy-MM') as snapshot_month,
            metric,
            category,
            waiting_bands,
            try_cast(count as int) as patient_count,
            row_number() over (
                partition by
                    format(week_ending_date, 'yyyy-MM'),
                    metric,
                    category,
                    waiting_bands
                order by week_ending_date desc
            ) as rn
        from [VBM_EquiWait_WH].[dbt_dev_intermediate].[int_timeseries]
        where metric in ('Age', 'Sex')
    ) t
    where rn = 1
      and patient_count is not null
),

reconciliation as (
    select
        g.snapshot_month,
        g.metric,
        g.category,
        g.waiting_bands,
        g.geography_count,
        t.timeseries_count,
        g.geography_count - t.timeseries_count as divergence,
        abs(g.geography_count - t.timeseries_count) as abs_divergence
    from geography_england g
    inner join timeseries_monthly t
        on  g.snapshot_month = t.snapshot_month
        and g.metric         = t.metric
        and g.category       = t.category
        and g.waiting_bands  = t.waiting_bands
)

select *
from reconciliation
order by abs_divergence desc;