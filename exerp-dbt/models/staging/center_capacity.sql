{{ config(bind=false) }}

with center_capacity as (

    select
        "id" as "id",
        "checked_in_count" as "checked_in_count",
        "reserved_spots" as "reserved_spots",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'center_capacity') }}
)

select * from center_capacity
