{{ config(bind=false) }}

with clearing_out as (

    select
        "id" as "id",
        "clearinghouse" as "clearing_house",
        "state" as "state",
        "ref" as "ref",
        "generated_date" as "generated_date",
        "sent_date" as "sent_date",
        "confirmed_date" as "confirmed_date",
        "total_amount" as "total_amount",
        "invoice_count" as "invoice_count",
        "total_reversal_amount" as "total_reversal_amount",
        "reversal_count" as "reversal_count",
        "requested_date" as "requested_date",
        "handler_type" as "handler_type",
        "file_name_provided_by_handler" as "file_name_provided_by_handler",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'clearing_out') }}
)

select * from clearing_out
