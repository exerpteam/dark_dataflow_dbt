{{ config(bind=false) }}

with bill_lines_mt as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "sub_id",
        "account_trans_center" as "account_trans_center",
        "account_trans_id" as "account_trans_id",
        "account_trans_subid" as "account_trans_sub_id",
        "text2" as "text2",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'bill_lines_mt') }}
)

select * from bill_lines_mt
