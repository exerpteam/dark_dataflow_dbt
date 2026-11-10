{{ config(bind=false) }}

with master_vat_type as (

    select
        "id" as "id",
        "name" as "name",
        "globalid" as "global_id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "master_account" as "master_account",
        "rate" as "rate",
        "orig_rate" as "orig_rate",
        "external_id" as "external_id",
        "definition" as "is_definition",
        "available" as "is_available",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'master_vat_type') }}
)

select * from master_vat_type
