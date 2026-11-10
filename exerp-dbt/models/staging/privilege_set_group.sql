{{ config(bind=false) }}

with privilege_set_group as (

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
        "role_id" as "role_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'privilege_set_group') }}
)

select * from privilege_set_group
