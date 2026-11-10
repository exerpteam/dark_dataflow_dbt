{{ config(bind=false) }}

with product_and_product_group_link as (

    select
        "product_center" as "product_center",
        "product_id" as "product_id",
        "product_group_id" as "product_group_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'product_and_product_group_link') }}
)

select * from product_and_product_group_link
