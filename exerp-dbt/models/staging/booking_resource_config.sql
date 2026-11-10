{{ config(bind=false) }}

with booking_resource_config as (

    select
        "booking_resource_center" as "booking_resource_center",
        "booking_resource_id" as "booking_resource_id",
        "group_id" as "group_id",
        "maximum_participations" as "maximum_participations",
        "business_starttimes" as "business_starttimes",
        "other_starttimes" as "other_starttimes",
        "availability_period_id" as "availability_period_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking_resource_config') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."booking_resource_center"
)

select * from booking_resource_config
