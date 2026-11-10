{{ config(bind=false) }}

with cash_collection_service as (

    select
        "id" as "id",
        "top_node_id" as "top_node_id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "name" as "name",
        "state" as "state",
        "blocked" as "is_blocked",
        "servicetype" as "service_type",
        "datasupplier_id" as "data_supplier_id",
        "account_center" as "account_center",
        "account_id" as "account_id",
        "serial" as "serial",
        "ledger_number" as "ledger_number",
        "interests_account_center" as "interests_account_center",
        "interests_account_id" as "interests_account_id",
        "client_identification" as "client_identification",
        "exclude_subscription_by_age" as "is_exclude_subscription_by_age",
        "invoice_fee_account_center" as "invoice_fee_account_center",
        "invoice_fee_account_id" as "invoice_fee_account_id",
        "reminder_fee_account_center" as "reminder_fee_account_center",
        "reminder_fee_account_id" as "reminder_fee_account_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'cash_collection_service') }}
)

select * from cash_collection_service
