{{ config(bind=false) }}

with unplaced_transaction as (

    select
        "id" as "id",
        "state" as "state",
        CASE "state"
            WHEN 1 THEN 'new'
            WHEN 2 THEN 'placed'
            WHEN 4 THEN 'old'
            WHEN 5 THEN 'lenientlyMatched'
            ELSE 'Unknown'
        END as "state_text",
        "xfr_delivery" as "clearing_in_id",
        "xfr_rec_no" as "ec_no",
        "xfr_date" as "transaction_date_at",
        "xfr_amount" as "amount",
        "xfr_info" as "info",
        "xfr_text" as "text",
        "xfr_debitor_id" as "debitor_id",
        "xfr_creditor_id" as "creditor_id",
        "account_center" as "account_center",
        "account_id" as "account_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'unplaced_transaction') }}
)

select * from unplaced_transaction
