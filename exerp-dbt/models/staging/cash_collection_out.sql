{{ config(bind=false) }}

with cash_collection_out as (

    select
        "id" as "id",
        "cashcollectionservice" as "cash_collection_service",
        "state" as "state",
        "ref" as "ref",
        "generated_date" as "generated_date",
        "sent_date" as "sent_date",
        "amount_req" as "amount_req",
        "nb_req" as "nb_req",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'cash_collection_out') }}
)

select * from cash_collection_out
