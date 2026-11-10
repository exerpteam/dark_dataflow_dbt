{{ config(bind=false) }}

with subscription_addon_product as (

    select
        "subscription_product_id" as "subscription_product_id",
        "addon_product_id" as "addon_product_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscription_addon_product') }}
)

select * from subscription_addon_product
