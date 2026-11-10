{{ config(bind=false) }}

with availability_override as (

    select
        "id" as "id",
        "override_date" as "override_date",
        "start_time" as "start_time",
        "stop_time" as "stop_time",
        "open_all_day" as "is_open_all_day",
        "closed_all_day" as "is_closed_all_day",
        "availability_period_id" as "availability_period_id",
        "override_scope_id" as "override_scope_id",
        "override_scope_type" as "override_scope_type",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'availability_override') }}
)

select * from availability_override
