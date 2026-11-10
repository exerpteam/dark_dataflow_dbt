{{ config(bind=false) }}

with bundle_campaign_usage as (

    select
        "id" as "id",
        "campaign_id" as "campaign_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'bundle_campaign_usage') }}
)

select * from bundle_campaign_usage
