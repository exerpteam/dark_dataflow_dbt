{{ config(bind=false) }}

with subscriptionperiodparts_invoicelines_link as (

    select
        "invoiceline_center" as "invoiceline_center",
        "invoiceline_id" as "invoiceline_id",
        "invoiceline_subid" as "invoiceline_subid",
        "period_center" as "period_center",
        "period_id" as "period_id",
        "period_subid" as "period_subid",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscriptionperiodparts_invoicelines_link') }}
)

select * from subscriptionperiodparts_invoicelines_link
