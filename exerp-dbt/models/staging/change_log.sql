{{ config(bind=false) }}

with change_log as (

    select
        "id" as "id",
        "type" as "type",
        CASE "type"
            WHEN 1 THEN 'ADD'
            WHEN 2 THEN 'UPDATE'
            WHEN 3 THEN 'REMOVE'
        END as "type_text",
        "service_name" as "service_name",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "source_primary" as "source_primary",
        "source_secondary" as "source_secondary",
        "text_value_before" as "text_value_before",
        "text_value_after" as "text_value_after",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'change_log') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."employee_center"
)

select * from change_log
