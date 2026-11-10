{{ config(bind=false) }}

with subscription_change_fee as (

    select
        "id" as "id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "subscr_type_from" as "subscr_type_from",
        "subscr_type_to" as "subscr_type_to",
        "change_fee_product" as "change_fee_product",
        "type" as "type",
        "state" as "state",
        "created" as "created",
        "modified" as "modified",
        "deleted" as "deleted",
        "version" as "version",
        "change_fee_percentage" as "change_fee_percentage",
        "use_remaining_contract_value" as "is_use_remaining_contract_value",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscription_change_fee') }}
)

select * from subscription_change_fee
