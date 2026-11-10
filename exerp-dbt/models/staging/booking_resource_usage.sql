{{ config(bind=false) }}

with booking_resource_usage as (

    select
        "booking_resource_center" as "booking_resource_center",
        "booking_resource_id" as "booking_resource_id",
        "booking_center" as "booking_center",
        "booking_id" as "booking_id",
        "configuration" as "configuration",
        {{ exerp_epoch_milliseconds_to_timestamp('"starttime"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"stoptime"', '_center_tz."_time_zone"') }} as "stopped_at",
        "state" as "state",
        "conflict" as "is_conflict",
        "parent_booking_center" as "parent_booking_center",
        "parent_booking_id" as "parent_booking_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking_resource_usage') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."booking_center"
)

select * from booking_resource_usage
