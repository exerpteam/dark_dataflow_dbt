{{ config(bind=false) }}

with masterproductregister_product_group_link as (

    select
        "master_product_id" as "master_product_id",
        "product_group_id" as "product_group_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'masterproductregister_product_group_link') }}
)

select * from masterproductregister_product_group_link
