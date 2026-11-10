{{ config(bind=false) }}

with clearing_in as (

    select
        "id" as "id",
        "clearinghouse" as "clearing_house_id",
        "state" as "state",
        CASE "state"
            WHEN 1 THEN 'RECEIVED'
            WHEN 2 THEN 'VERIFIED'
            WHEN 3 THEN 'ERRORED'
            WHEN 4 THEN 'BAD'
            WHEN 5 THEN 'HANDLED'
            WHEN 6 THEN 'CONFIRMED'
            WHEN 7 THEN 'CLEANED'
            WHEN 8 THEN 'HANDLING'
        END as "state_text",
        "ref" as "ref",
        "payment_count" as "payment_count",
        "total_amount" as "total_amount",
        "received_date" as "received_date",
        "generated_date" as "generated_date",
        "substate" as "sub_state",
        "filename" as "file_name",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'clearing_in') }}
)

select * from clearing_in
