{{ config(bind=false) }}

with privilege_set as (

    select
        "id" as "id",
        "name" as "name",
        "description" as "description",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "state" as "state",
        {{ exerp_epoch_milliseconds_to_timestamp('"blocked_on"', 'UTC') }} as "blocked_on",
        "privilege_set_groups_id" as "privilege_set_groups_id",
        "frequency_restriction_count" as "frequency_restriction_count",
        "frequency_restriction_value" as "frequency_restriction_value",
        "frequency_restriction_unit" as "frequency_restriction_unit",
        "frequency_restriction_type" as "frequency_restriction_type",
        "frequency_restr_include_noshow" as "is_frequency_restr_include_noshow",
        "reusable" as "is_reusable",
        "availability_period_id" as "availability_period_id",
        "multiaccess_window_count" as "multiaccess_window_count",
        "multiaccess_window_time_value" as "multiaccess_window_time_value",
        "multiaccess_window_time_unit" as "multiaccess_window_time_unit",
        "multiaccess_window_type" as "multiaccess_window_type",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'privilege_set') }}
)

select * from privilege_set
