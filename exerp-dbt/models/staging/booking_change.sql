{{ config(bind=false) }}

with booking_change as (

    select
        "id" as "id",
        "booking_center" as "booking_center",
        "booking_id" as "booking_id",
        "type" as "type",
        {{ exerp_epoch_milliseconds_to_timestamp('"time"', '_center_tz."_time_zone"') }} as "time",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "value_before" as "value_before",
        "value_after" as "value_after",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking_change') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."booking_center"
)

select * from booking_change
