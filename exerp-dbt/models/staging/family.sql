{{ config(bind=false) }}

with family as (

    select
        "center" as "center",
        "family_name" as "family_name",
        "status" as "status",
        "id" as "id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'family') }}
)

select * from family
