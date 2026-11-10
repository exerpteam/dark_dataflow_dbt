{{ config(bind=false) }}

with add_on_to_product_group_link as (

    select
        "add_on_product_definition_id" as "add_on_product_definition_id",
        "product_group_id" as "product_group_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'add_on_to_product_group_link') }}
)

select * from add_on_to_product_group_link
