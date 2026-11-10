{{ config(bind=false) }}

with subscription_blocked_period as (

    select
        "id" as "id",
        "freeze_period" as "freeze_period",
        "main_reduced_period" as "main_reduced_period",
        "subscription_center" as "subscription_center",
        "subscription_id" as "subscription_id",
        "type" as "type",
        "state" as "state",
        "start_date" as "start_date",
        "end_date" as "end_date",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancel_time"', '_center_tz."_time_zone"') }} as "cancelled_at",
        "text" as "text",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "cancel_employee_center" as "cancel_employee_center",
        "cancel_employee_id" as "cancel_employee_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscription_blocked_period') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."subscription_center"
)

select * from subscription_blocked_period
