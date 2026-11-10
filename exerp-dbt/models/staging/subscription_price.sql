{{ config(bind=false) }}

with subscription_price as (

    select
        "id" as "id",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "from_date" as "from_date",
        "to_date" as "to_date",
        "subscription_center" as "subscription_center",
        "subscription_id" as "subscription_id",
        "price" as "price",
        "binding" as "is_binding",
        "type" as "type",
        "coment" as "comment",
        "notified" as "is_notified",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "applied" as "is_applied",
        "cancelled" as "is_cancelled",
        "approved" as "is_approved",
        "pending" as "is_pending",
        "approved_employee_center" as "approved_employee_center",
        "approved_employee_id" as "approved_employee_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"approved_entry_time"', '_center_tz."_time_zone"') }} as "approved_entry_at",
        "cancelled_employee_center" as "cancelled_employee_center",
        "cancelled_employee_id" as "cancelled_employee_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancelled_entry_time"', '_center_tz."_time_zone"') }} as "cancelled_entry_at",
        "aggregated_change_date" as "aggregated_change_date",
        "template_id" as "template_id",
        "event_config_id" as "event_config_id",
        "prorata_sessions" as "prorata_sessions",
        "prorata_sessions_total" as "prorata_sessions_total",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscription_price') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."subscription_center"
)

select * from subscription_price
