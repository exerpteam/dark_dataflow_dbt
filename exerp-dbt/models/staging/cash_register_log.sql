{{ config(bind=false) }}

with cash_register_log as (

    select
        "id" as "id",
        "cash_register_center" as "cash_register_center",
        "cash_register_id" as "cash_register_id",
        "log_type" as "log_type",
        "reference_global_id" as "reference_global_id",
        "reference_center" as "reference_center",
        "reference_id" as "reference_id",
        "reference_sub_id" as "reference_sub_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"log_time"', '_center_tz."_time_zone"') }} as "logged_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"event_time"', '_center_tz."_time_zone"') }} as "event_at",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'cash_register_log') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."cash_register_center"
)

select * from cash_register_log
