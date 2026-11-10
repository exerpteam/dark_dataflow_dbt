{{ config(bind=false) }}

with employees_role as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "sub_id",
        "roleid" as "role_id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'employees_role') }}
)

select * from employees_role
