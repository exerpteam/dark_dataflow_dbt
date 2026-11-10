{{ config(bind=false) }}

with booking_privilege_group as (

    select
        "id" as "id",
        "top_node_id" as "top_node_id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "name" as "name",
        "state" as "state",
        "converted_rr_type" as "converted_rr_type",
        "frequency_restriction_count" as "frequency_restriction_count",
        "frequency_restriction_value" as "frequency_restriction_value",
        "frequency_restriction_unit" as "frequency_restriction_unit",
        "frequency_restriction_type" as "frequency_restriction_type",
        "frequency_restr_include_noshow" as "is_frequency_restr_include_noshow",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking_privilege_group') }}
)

select * from booking_privilege_group
