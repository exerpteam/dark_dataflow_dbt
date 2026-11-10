{{ config(bind=false) }}

with booking_restriction as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "sub_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"start_time"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"stop_time"', '_center_tz."_time_zone"') }} as "stopped_at",
        "user_interface_type" as "user_interface_type",
        "in_advance_unit" as "in_advance_unit",
        "in_advance_value" as "in_advance_value",
        "reason" as "reason",
        "has_expiry_been_notified" as "is_has_expiry_been_notified",
        "access_group" as "access_group",
        "prevent_all_bookings" as "is_prevent_all_bookings",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking_restriction') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from booking_restriction
