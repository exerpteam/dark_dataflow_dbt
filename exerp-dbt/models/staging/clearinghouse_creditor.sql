{{ config(bind=false) }}

with clearinghouse_creditor as (

    select
        "clearinghouse" as "clearinghouse_id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "creditor_id" as "creditor_id",
        "blocked" as "is_blocked",
        "state" as "state",
        "creditor_name" as "creditor_name",
        "giro_account_no" as "giro_account_no",
        "deposit_account_center" as "deposit_account_center",
        "deposit_account_id" as "deposit_account_id",
        "liability_account_center" as "liability_account_center",
        "liability_account_id" as "liability_account_id",
        "rejection_account_center" as "rejection_account_center",
        "rejection_account_id" as "rejection_account_id",
        "indemnity_account_center" as "indemnity_account_center",
        "indemnity_account_id" as "indemnity_account_id",
        "refund_account_center" as "refund_account_center",
        "refund_account_id" as "refund_account_id",
        "invoice_fee_account_center" as "invoice_fee_account_center",
        "invoice_fee_account_id" as "invoice_fee_account_id",
        "rejection_fee_account_center" as "rejection_fee_account_center",
        "rejection_fee_account_id" as "rejection_fee_account_id",
        "disable_unplaced_payments" as "is_disable_unplaced_payments",
        "field_1" as "field_1",
        "field_2" as "field_2",
        "field_3" as "field_3",
        "field_4" as "field_4",
        "field_5" as "field_5",
        "field_6" as "field_6",
        "reference_modifier" as "reference_modifier",
        "web_text" as "web_text",
        "seller_center_id" as "seller_center_id",
        "description" as "description",
        "field_7" as "field_7",
        "field_8" as "field_8",
        "field_9" as "field_9",
        "field_10" as "field_10",
        "field_11" as "field_11",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'clearinghouse_creditor') }}
)

select * from clearinghouse_creditor
