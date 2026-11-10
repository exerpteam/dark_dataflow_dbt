{{ config(bind=false) }}

with bundle_campaign as (

    select
        "id" as "id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "name" as "name",
        "state" as "state",
        {{ exerp_epoch_milliseconds_to_timestamp('"starttime"', 'UTC') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"endtime"', 'UTC') }} as "ended_at",
        "auto_add_products" as "is_auto_add_products",
        "price_modification_name" as "price_modification_name",
        "price_modification_amount" as "price_modification_amount",
        "prompt_type" as "prompt_type",
        "prompt_text" as "prompt_text",
        "plugin_codes_name" as "plugin_codes_name",
        "basket_threshold" as "basket_threshold",
        "price_modification_one_time" as "is_price_modification_one_time",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'bundle_campaign') }}
)

select * from bundle_campaign
