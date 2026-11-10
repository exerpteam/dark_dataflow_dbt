{{ config(bind=false) }}

with cash_collection_in as (

    select
        "id" as "id",
        "cashcollectionservice" as "cash_collection_service",
        "state" as "state",
        "ref" as "ref",
        "received_date" as "received_date",
        "generated_date" as "generated_date",
        "filename" as "file_name",
        "total_amount" as "total_amount",
        "payment_count" as "payment_count",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'cash_collection_in') }}
)

select * from cash_collection_in
