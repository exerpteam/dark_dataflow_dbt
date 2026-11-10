{{ config(bind=false) }}

with report_period as (

    select
        "id" as "id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "period_name" as "period_name",
        "start_date" as "start_date",
        "end_date" as "end_date",
        {{ exerp_epoch_milliseconds_to_timestamp('"close_time"', 'UTC') }} as "closed_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"hard_close_time"', 'UTC') }} as "hard_closed_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'report_period') }}
)

select * from report_period
