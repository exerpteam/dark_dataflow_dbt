{{ config(bind=false) }}

with age_group as (

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
        "min_age" as "min_age",
        "max_age" as "max_age",
        "external_id" as "external_id",
        "strict_min_age" as "is_strict_min_age",
        "min_age_time_unit" as "min_age_time_unit",
        "max_age_time_unit" as "max_age_time_unit",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'age_group') }}
)

select * from age_group
