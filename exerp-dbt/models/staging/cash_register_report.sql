{{ config(bind=false) }}

with cash_register_report as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "sub_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"starttime"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"reporttime"', '_center_tz."_time_zone"') }} as "report_at",
        "cashinitial" as "cash_initial",
        "cashend" as "cash_end",
        "employeecenter" as "employee_center",
        "employeeid" as "employee_id",
        "sales_total" as "sales_total",
        "sales_count" as "sales_count",
        "credits_total" as "credits_total",
        "credits_count" as "credits_count",
        "control_device_id" as "control_device_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'cash_register_report') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from cash_register_report
