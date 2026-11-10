{{ config(bind=false) }}

with staff_group as (

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
        "default_salary" as "default_salary",
        "old_activity_type_id" as "old_activity_type_id",
        "external_reference" as "external_reference",
        "commissionable" as "is_commissionable",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'staff_group') }}
)

select * from staff_group
