{{ config(bind=false) }}

with clearinghouse_and_paymentcycleconfig_link as (

    select
        "clearing_house_id" as "clearing_house_id",
        "payment_cycle_id" as "payment_cycle_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'clearinghouse_and_paymentcycleconfig_link') }}
)

select * from clearinghouse_and_paymentcycleconfig_link
