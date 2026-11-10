{{ config(bind=false) }}

with invoice_sales_employee as (

    select
        "id" as "id",
        "invoice_id" as "invoice_id",
        "invoice_center" as "invoice_center",
        "sales_employee_id" as "sales_employee_id",
        "sales_employee_center" as "sales_employee_center",
        "change_employee_id" as "change_employee_id",
        "change_employee_center" as "change_employee_center",
        {{ exerp_epoch_milliseconds_to_timestamp('"start_time"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"stop_time"', '_center_tz."_time_zone"') }} as "stopped_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'invoice_sales_employee') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."invoice_center"
)

select * from invoice_sales_employee
