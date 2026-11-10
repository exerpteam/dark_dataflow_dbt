{{ config(bind=false) }}

with startup_campaign as (

    select
        "id" as "id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "state" as "state",
        "name" as "name",
        "plugin_name" as "plugin_name",
        {{ exerp_epoch_milliseconds_to_timestamp('"starttime"', 'UTC') }} as "start_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"endtime"', 'UTC') }} as "end_at",
        "period_type" as "period_type",
        "period_unit" as "period_unit",
        "period_value" as "period_value",
        "period_round" as "is_period_round",
        "period_start" as "period_start_date",
        "period_end" as "period_end_date",
        "web_text" as "web_text",
        "available_scopes" as "available_scopes",
        "plugin_codes_name" as "plugin_codes_name",
        "free_period_unit" as "free_period_unit",
        "free_period_value" as "free_period_value",
        "free_period_type" as "free_period_type",
        "free_period_extends_binding" as "is_free_period_extends_binding",
        "campaign_apply_for" as "campaign_apply_for",
        "privilege_change_binding_type" as "privilege_change_binding_type",
        "relative_to_start_date_value" as "relative_to_start_date_value",
        "relative_to_start_date_unit" as "relative_to_start_date_unit",
        "relative_to_start_date_round" as "is_relative_to_start_date_round",
        "fixed_binding_end_date" as "fixed_binding_end_date",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'startup_campaign') }}
)

select * from startup_campaign
