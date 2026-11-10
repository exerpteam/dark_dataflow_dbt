{{ config(bind=false) }}

with cashregistertransaction_accountreceivablestransaction_link as (

    select
        "crt_center" as "crt_center",
        "crt_id" as "crt_id",
        "crt_subid" as "crt_sub_id",
        "art_center" as "art_center",
        "art_id" as "art_id",
        "art_subid" as "art_sub_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'cashregistertransaction_accountreceivablestransaction_link') }}
)

select * from cashregistertransaction_accountreceivablestransaction_link
