{{ config(bind=false) }}

with product_availability as (

    select
        "id" as "id",
        "product_master_key" as "product_master_key",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'product_availability') }}
)

select * from product_availability
