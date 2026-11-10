{{ config(bind=false) }}

with credit_note_line_vat_at_link as (

    select
        "id" as "id",
        "credit_note_line_center" as "credit_note_line_center",
        "credit_note_line_id" as "credit_note_line_id",
        "credit_note_line_subid" as "credit_note_line_sub_id",
        "account_trans_center" as "account_trans_center",
        "account_trans_id" as "account_trans_id",
        "account_trans_subid" as "account_trans_sub_id",
        "rate" as "rate",
        "orig_rate" as "orig_rate",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'credit_note_line_vat_at_link') }}
)

select * from credit_note_line_vat_at_link
