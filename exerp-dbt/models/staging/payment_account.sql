{{ config(bind=false) }}

with payment_account as (

    select
        "center" as "center",
        "id" as "id",
        "active_agr_center" as "active_agr_center",
        "active_agr_id" as "active_agr_id",
        "active_agr_subid" as "active_agr_subid",
        "day_in_interval" as "day_in_interval",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'payment_account') }}
)

select * from payment_account
