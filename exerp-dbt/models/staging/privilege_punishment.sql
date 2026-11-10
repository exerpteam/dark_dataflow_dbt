{{ config(bind=false) }}

with privilege_punishment as (

    select
        "id" as "id",
        "name" as "name",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "state" as "state",
        "restriction_count" as "restriction_count",
        "restriction_value" as "restriction_value",
        "restriction_unit" as "restriction_unit",
        "service_id" as "service_id",
        "restrict_by_access_group" as "is_restrict_by_access_group",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'privilege_punishment') }}
)

select * from privilege_punishment
