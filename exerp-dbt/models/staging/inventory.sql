{{ config(bind=false) }}

with inventory as (

    select
        "id" as "id",
        "center" as "center",
        "state" as "state",
        "name" as "name",
        "def" as "is_def",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'inventory') }}
)

select * from inventory
