{{ config(bind=false) }}

with login_log as (

    select
        "id" as "id",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"log_in_time"', '_center_tz."_time_zone"') }} as "log_in_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"log_out_time"', '_center_tz."_time_zone"') }} as "log_out_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'login_log') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."employee_center"
)

select * from login_log
