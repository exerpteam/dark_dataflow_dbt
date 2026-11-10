{{ config(bind=false) }}

with role as (

    select
        "id" as "id",
        "rolename" as "role_name",
        "masterroleid" as "master_role_id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "blocked" as "is_blocked",
        "config_type" as "config_type",
        "description" as "description",
        "system_id" as "system_id",
        "is_action" as "is_action",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'role') }}
)

select * from role
