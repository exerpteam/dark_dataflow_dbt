{{ config(bind=false) }}

with subscription_freeze_period as (

    select
        "id" as "id",
        "subscription_center" as "subscription_center",
        "subscription_id" as "subscription_id",
        "start_invoice_line_center" as "start_invoice_line_center",
        "start_invoice_line_id" as "start_invoice_line_id",
        "start_invoice_line_subid" as "start_invoice_line_subid",
        "start_date" as "start_date",
        "end_date" as "end_date",
        "type" as "type",
        "state" as "state",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancel_time"', '_center_tz."_time_zone"') }} as "cancelled_at",
        "text" as "text",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "entry_interface_type" as "entry_interface_type",
        CASE "entry_interface_type"
            WHEN 0 THEN 'OTHER'
            WHEN 1 THEN 'CLIENT'
            WHEN 2 THEN 'WEB'
            WHEN 5 THEN 'API'
        END as "entry_interface_type_text",
        "cancel_employee_center" as "cancel_employee_center",
        "cancel_employee_id" as "cancel_employee_id",
        "cancel_interface_type" as "cancel_interface_type",
        "end_notified" as "is_end_notified",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscription_freeze_period') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."subscription_center"
)

select * from subscription_freeze_period
