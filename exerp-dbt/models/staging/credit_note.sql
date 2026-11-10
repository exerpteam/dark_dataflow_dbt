{{ config(bind=false) }}

with credit_note as (

    select
        "center" as "center",
        "id" as "id",
        {{ exerp_epoch_milliseconds_to_timestamp('"trans_time"', '_center_tz."_time_zone"') }} as "trans_at",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "cashregister_center" as "cash_register_center",
        "cashregister_id" as "cash_register_id",
        "paysessionid" as "pay_session_id",
        "transferred" as "is_transferred",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "payer_center" as "payer_center",
        "payer_id" as "payer_id",
        "receipt_id" as "receipt_id",
        "text" as "text",
        "control_device_id" as "control_device_id",
        "control_code" as "control_code",
        "invoice_center" as "invoice_center",
        "invoice_id" as "invoice_id",
        "coment" as "comment",
        "canceltype" as "cancel_type",
        "cash" as "is_cash",
        "clearance_status" as "clearance_status",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'credit_note') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from credit_note
