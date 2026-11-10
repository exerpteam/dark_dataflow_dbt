{{ config(bind=false) }}

with kpi_fields as (

    select
        "id" as "id",
        "name" as "name",
        "key" as "key",
        "external_id" as "external_id",
        "type" as "type",
        "display_type" as "display_type",
        "display_decimals" as "display_decimals",
        "start_date" as "start_date",
        "last_calculation" as "last_calculation_date",
        "state" as "state",
        "description" as "description",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "kpi" as "is_kpi",
        "best_rate" as "best_rate",
        "recalculate_from_dependent" as "is_recalculate_from_dependent",
        "scope_aggregation" as "scope_aggregation",
        "time_aggregation" as "time_aggregation",
        "dashboard" as "is_dashboard",
        "dashboard_scale_from" as "dashboard_scale_from",
        "dashboard_scale_to" as "dashboard_scale_to",
        "dashboard_target_fieldid" as "dashboard_target_fieldid",
        "benchmark" as "is_benchmark",
        "benchmark_interval_type" as "benchmark_interval_type",
        "benchmark_scope" as "benchmark_scope",
        "live" as "is_live",
        "dashboard_warning_percentage" as "dashboard_warning_percentage",
        "refresh_interval" as "refresh_interval",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'kpi_fields') }}
)

select * from kpi_fields
