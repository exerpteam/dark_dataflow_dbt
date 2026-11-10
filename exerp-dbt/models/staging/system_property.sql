{{ config(bind=false) }}

with system_property as (

    select
        "id" as "id",
        "globalid" as "global_id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "txtvalue" as "txt_value",
        "mimetype" as "mime_type",
        "link_type" as "link_type",
        "link_id" as "link_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'system_property') }}
)

select * from system_property
