{{ config(bind=false) }}

with availability_period as (

    select
        "id" as "id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "name" as "name",
        "schedule_type" as "schedule_type",
        "blocked" as "is_blocked",
        "deleted" as "is_deleted",
        "availability_period_id" as "availability_period_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'availability_period') }}
)

select * from availability_period
