{{ config(bind=false) }}

with privilege_grant as (

    select
        "id" as "id",
        "privilege_set" as "privilege_set",
        "punishment" as "punishment",
        "granter_service" as "granter_service",
        "granter_globalid" as "granter_global_id",
        "granter_center" as "granter_center",
        "granter_id" as "granter_id",
        "granter_subid" as "granter_subid",
        {{ exerp_epoch_milliseconds_to_timestamp('"valid_from"', '_center_tz."_time_zone"') }} as "valid_from",
        {{ exerp_epoch_milliseconds_to_timestamp('"valid_to"', '_center_tz."_time_zone"') }} as "valid_to",
        "sponsorship_name" as "sponsorship_name",
        "sponsorship_amount" as "sponsorship_amount",
        "sponsorship_rounding" as "sponsorship_rounding",
        "usage_product" as "usage_product",
        "usage_quantity" as "usage_quantity",
        "usage_duration_value" as "usage_duration_value",
        "usage_duration_unit" as "usage_duration_unit",
        "usage_duration_round" as "usage_duration_round",
        "usage_use_at_planning" as "is_usage_use_at_planning",
        "extension" as "is_extension",
        "frequency_restriction_target" as "frequency_restriction_target",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'privilege_grant') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."granter_center"
)

select * from privilege_grant
