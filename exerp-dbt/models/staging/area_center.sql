{{ config(bind=false) }}

with area_center as (

    select
        "area" as "area",
        "center" as "center",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'area_center') }}
)

select * from area_center
