{{ config(bind=false) }}

with staff_usage as (

    select
        "id" as "id",
        "person_center" as "person_center",
        "person_id" as "person_id",
        "booking_center" as "booking_center",
        "booking_id" as "booking_id",
        "configuration" as "configuration",
        {{ exerp_epoch_milliseconds_to_timestamp('"starttime"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"stoptime"', '_center_tz."_time_zone"') }} as "stopped_at",
        "state" as "state",
        "conflict" as "is_conflict",
        "salary" as "salary",
        "parent_booking_center" as "parent_booking_center",
        "parent_booking_id" as "parent_booking_id",
        "available_for_substitution" as "is_available_for_substitution",
        {{ exerp_epoch_milliseconds_to_timestamp('"available_for_subst_time"', '_center_tz."_time_zone"') }} as "available_for_subst_at",
        "original_staff_center" as "original_staff_center",
        "original_staff_id" as "original_staff_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancellation_time"', '_center_tz."_time_zone"') }} as "cancellation_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'staff_usage') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."booking_center"
)

select * from staff_usage
