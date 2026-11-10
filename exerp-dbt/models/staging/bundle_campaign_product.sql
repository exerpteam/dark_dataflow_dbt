{{ config(bind=false) }}

with bundle_campaign_product as (

    select
        "id" as "id",
        "bundle_campaign" as "bundle_campaign",
        "rebated" as "is_rebated",
        "ref_type" as "ref_type",
        "ref_globalid" as "ref_global_id",
        "ref_center" as "ref_center",
        "ref_id" as "ref_id",
        "units" as "units",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'bundle_campaign_product') }}
)

select * from bundle_campaign_product
