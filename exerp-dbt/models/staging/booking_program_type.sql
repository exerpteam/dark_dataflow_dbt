{{ config(bind=false) }}

with booking_program_type as (

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
        "type" as "type",
        "description" as "description",
        "time_config_id" as "time_config_id",
        "age_group_id" as "age_group_id",
        "single_days_booking_enabled" as "is_single_days_booking_enabled",
        "single_days_from_unit" as "single_days_from_unit",
        "single_days_from_value" as "single_days_from_value",
        "availability" as "availability",
        "definition_key" as "definition_key",
        "override_name" as "is_override_name",
        "override_age_group_id" as "is_override_age_group_id",
        "override_single_days_config" as "is_override_single_days_config",
        "full_camp_product_global_id" as "full_camp_product_global_id",
        "documentation_setting_id" as "documentation_setting_id",
        "standby_list_size" as "standby_list_size",
        "available_on_web" as "is_available_on_web",
        "override_available_on_web" as "is_override_available_on_web",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking_program_type') }}
)

select * from booking_program_type
