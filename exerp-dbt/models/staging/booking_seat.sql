{{ config(bind=false) }}

with booking_seat as (

    select
        "id" as "id",
        "ref" as "ref",
        "resource_center" as "resource_center",
        "resource_id" as "resource_id",
        "x" as "x",
        "y" as "y",
        "status" as "status",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking_seat') }}
)

select * from booking_seat
