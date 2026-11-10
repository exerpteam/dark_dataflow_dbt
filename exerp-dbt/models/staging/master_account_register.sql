{{ config(bind=false) }}

with master_account_register as (

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
        "atype" as "type",
        "name" as "name",
        "vattype" as "vat_type",
        "external_id" as "external_id",
        "definition" as "is_definition",
        "available" as "is_available",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'master_account_register') }}
)

select * from master_account_register
