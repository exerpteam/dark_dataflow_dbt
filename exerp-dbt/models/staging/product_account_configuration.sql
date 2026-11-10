{{ config(bind=false) }}

with product_account_configuration as (

    select
        "id" as "id",
        "name" as "name",
        "product_account_type" as "product_account_type",
        "blocked" as "is_blocked",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "sales_account_globalid" as "sales_account_global_id",
        "expenses_account_globalid" as "expenses_account_global_id",
        "refund_account_globalid" as "refund_account_global_id",
        "write_off_account_globalid" as "write_off_account_global_id",
        "defer_rev_account_globalid" as "defer_rev_account_global_id",
        "inventory_account_globalid" as "inventory_account_global_id",
        "defer_lia_account_globalid" as "defer_lia_account_global_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'product_account_configuration') }}
)

select * from product_account_configuration
