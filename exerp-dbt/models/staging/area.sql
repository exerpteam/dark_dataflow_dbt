{{ config(bind=false) }}

with area as (

    select
        "id" as "id",
        "blocked" as "is_blocked",
        "name" as "name",
        "parent" as "parent",
        "types" as "types",
        "root_area" as "root_area",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'area') }}
)

select * from area
