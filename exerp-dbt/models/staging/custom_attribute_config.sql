{{ config(bind=false) }}

with custom_attribute_config as (

    select
        "id" as "id",
        "name" as "name",
        "external_id" as "external_id",
        "rank" as "rank",
        "ref_type" as "ref_type",
        "ref_id" as "ref_id",
        "state" as "state",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', 'UTC') }} as "modified_at",
        "type" as "type",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'custom_attribute_config') }}
)

select * from custom_attribute_config
