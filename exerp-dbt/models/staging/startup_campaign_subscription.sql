{{ config(bind=false) }}

with startup_campaign_subscription as (

    select
        "id" as "id",
        "startup_campaign" as "startup_campaign",
        "ref_type" as "ref_type",
        "ref_globalid" as "ref_global_id",
        "ref_center" as "ref_center",
        "ref_id" as "ref_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'startup_campaign_subscription') }}
)

select * from startup_campaign_subscription
