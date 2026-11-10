{{ config(bind=false) }}

with campaign_code_usage as (

    select
        "id" as "id",
        "campaign_code_id" as "campaign_code_id",
        "external_id" as "external_id",
        "usage_count" as "usage_count",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'campaign_code_usage') }}
)

select * from campaign_code_usage
