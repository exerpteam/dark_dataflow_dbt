{{ config(bind=false) }}

with invoicelines_accounttransaction_link as (

    select
        "id" as "id",
        "invoiceline_center" as "invoiceline_center",
        "invoiceline_id" as "invoiceline_id",
        "invoiceline_subid" as "invoiceline_subid",
        "account_trans_center" as "account_trans_center",
        "account_trans_id" as "account_trans_id",
        "account_trans_subid" as "account_trans_subid",
        "rate" as "rate",
        "orig_rate" as "orig_rate",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'invoicelines_accounttransaction_link') }}
)

select * from invoicelines_accounttransaction_link
