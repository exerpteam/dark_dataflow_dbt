{{ config(bind=false) }}

with credit_card_transaction_reference as (

    select
        "id" as "id",
        "invoice_payment_session_id" as "invoice_payment_session_id",
        "transaction_reference" as "transaction_reference",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'credit_card_transaction_reference') }}
)

select * from credit_card_transaction_reference
