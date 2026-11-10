{{ config(bind=false) }}

with supplier as (

    select
        "center" as "center",
        "id" as "id",
        "active" as "is_active",
        "external_id" as "external_id",
        "supply_scope_type" as "supply_scope_type",
        CASE "supply_scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "supply_scope_type_text",
        "supply_scope_id" as "supply_scope_id",
        "delivery_time" as "delivery_time",
        "finance_account_globalid" as "finance_account_global_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'supplier') }}
)

select * from supplier
