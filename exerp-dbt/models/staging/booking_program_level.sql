{{ config(bind=false) }}

with booking_program_level as (

    select
        "id" as "id",
        "external_id" as "external_id",
        "name" as "name",
        "state" as "state",
        "rank" as "rank",
        "booking_program_type_id" as "booking_program_type_id",
        "required_showup" as "required_showup",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking_program_level') }}
)

select * from booking_program_level
