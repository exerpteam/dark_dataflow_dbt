{{ config(bind=false) }}

with semester as (

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
        "start_date" as "start_date",
        "end_date" as "end_date",
        "state" as "state",
        "available_on_web" as "is_available_on_web",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'semester') }}
)

select * from semester
