{{ config(bind=false) }}

with attend as (

    select
        "center" as "center",
        "id" as "id",
        {{ exerp_epoch_milliseconds_to_timestamp('"start_time"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"stop_time"', '_center_tz."_time_zone"') }} as "stopped_at",
        "attend_using_card" as "is_attend_using_card",
        "state" as "state",
        "booking_resource_center" as "booking_resource_center",
        "booking_resource_id" as "booking_resource_id",
        "person_center" as "person_center",
        "person_id" as "person_id",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "origin" as "origin",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'attend') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from attend
