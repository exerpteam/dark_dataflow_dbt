{{ config(bind=false) }}

with campaign_code as (

    select
        "id" as "id",
        "campaign_id" as "campaign_id",
        "campaign_type" as "campaign_type",
        "code" as "code",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', 'UTC') }} as "creation_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"usage_time"', 'UTC') }} as "usage_at",
        "usage_count" as "usage_count",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'campaign_code') }}
)

select * from campaign_code
