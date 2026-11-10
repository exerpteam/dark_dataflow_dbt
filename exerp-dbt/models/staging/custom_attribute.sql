{{ config(bind=false) }}

with custom_attribute as (

    select
        "id" as "id",
        "custom_attribute_config_value_id" as "custom_attribute_config_value_id",
        "ref_type" as "ref_type",
        "ref_id" as "ref_id",
        "ref_center_id" as "ref_center_id",
        "state" as "state",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "text_value" as "text_value",
        "custom_attribute_config_id" as "custom_attribute_config_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'custom_attribute') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."ref_center_id"
)

select * from custom_attribute
