{{ config(bind=false) }}

with invoice as (

    select
        "center" as "center",
        "id" as "id",
        {{ exerp_epoch_milliseconds_to_timestamp('"trans_time"', '_center_tz."_time_zone"') }} as "trans_at",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "cashregister_center" as "cashregister_center",
        "cashregister_id" as "cashregister_id",
        "paysessionid" as "pay_session_id",
        "transferred" as "is_transferred",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "payer_center" as "payer_center",
        "payer_id" as "payer_id",
        "receipt_id" as "receipt_id",
        "text" as "text",
        "control_device_id" as "control_device_id",
        "control_code" as "control_code",
        "cash" as "is_cash",
        "sponsor_invoice_center" as "sponsor_invoice_center",
        "sponsor_invoice_id" as "sponsor_invoice_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"print_time"', '_center_tz."_time_zone"') }} as "printed_at",
        "clearance_status" as "clearance_status",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'invoice') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from invoice
