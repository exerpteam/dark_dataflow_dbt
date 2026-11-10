{{ config(bind=false) }}

with booking_program as (

    select
        "center" as "center",
        "id" as "id",
        "startdate" as "start_date",
        "stopdate" as "stop_date",
        "name" as "name",
        "description" as "description",
        "activity" as "activity",
        "state" as "state",
        "capacity" as "capacity",
        "waiting_list_capacity" as "waiting_list_capacity",
        "program_type_id" as "program_type_id",
        "cached_price" as "cached_price",
        "cached_earliest_time" as "cached_earliest_time",
        "cached_latest_time" as "cached_latest_time",
        "semester_id" as "semester_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking_program') }}
)

select * from booking_program
