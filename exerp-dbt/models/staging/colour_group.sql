{{ config(bind=false) }}

with colour_group as (

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
        "colour" as "colour",
        "old_colour_code_id" as "old_colour_code_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'colour_group') }}
)

select * from colour_group
