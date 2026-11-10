{{ config(bind=false) }}

with bill_lines_vat_at_link as (

    select
        "id" as "id",
        "billline_center" as "bill_line_center",
        "billline_id" as "bill_line_id",
        "billline_subid" as "bill_line_sub_id",
        "account_trans_center" as "account_trans_center",
        "account_trans_id" as "account_trans_id",
        "account_trans_subid" as "account_trans_sub_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'bill_lines_vat_at_link') }}
)

select * from bill_lines_vat_at_link
