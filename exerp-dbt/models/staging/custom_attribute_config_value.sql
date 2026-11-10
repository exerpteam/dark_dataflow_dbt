{{ config(bind=false) }}

with custom_attribute_config_value as (

    select
        "id" as "id",
        "external_id" as "external_id",
        "value" as "value",
        "custom_attribute_config_id" as "custom_attribute_config_id",
        "rank" as "rank",
        "state" as "state",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', 'UTC') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'custom_attribute_config_value') }}
)

select * from custom_attribute_config_value
