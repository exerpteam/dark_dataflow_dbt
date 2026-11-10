{{ config(bind=false) }}

with subscription_change as (

    select
        "id" as "id",
        "type" as "type",
        {{ exerp_epoch_milliseconds_to_timestamp('"change_time"', '_center_tz."_time_zone"') }} as "changed_at",
        "effect_date" as "effect_date",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancel_time"', '_center_tz."_time_zone"') }} as "cancelled_at",
        "old_subscription_center" as "old_subscription_center",
        "old_subscription_id" as "old_subscription_id",
        "new_subscription_center" as "new_subscription_center",
        "new_subscription_id" as "new_subscription_id",
        "new_change_center" as "new_change_center",
        "new_change_id" as "new_change_id",
        "prev_change_center" as "prev_change_center",
        "prev_change_id" as "prev_change_id",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "reference" as "reference",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscription_change') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."new_subscription_center"
)

select * from subscription_change
