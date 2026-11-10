{{ config(bind=false) }}

with cash_collection_request as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "sub_id",
        "state" as "state",
        "ref" as "ref",
        "req_amount" as "req_amount",
        "req_date" as "req_date",
        "req_delivery" as "req_delivery",
        "xfr_delivery" as "xfr_delivery",
        "payment_request_center" as "payment_request_center",
        "payment_request_id" as "payment_request_id",
        "payment_request_subid" as "payment_request_sub_id",
        "prscenter" as "prs_center",
        "prsid" as "prsid",
        "prssubid" as "prs_subid",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'cash_collection_request') }}
)

select * from cash_collection_request
