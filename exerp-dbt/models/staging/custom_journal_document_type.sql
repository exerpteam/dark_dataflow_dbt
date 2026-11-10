{{ config(bind=false) }}

with custom_journal_document_type as (

    select
        "id" as "id",
        "definition_key" as "definition_key",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "state" as "state",
        "name" as "name",
        "override_name" as "is_override_name",
        "external_id" as "external_id",
        "override_external_id" as "is_override_external_id",
        "validity_period" as "validity_period",
        "validity_period_start" as "validity_period_start",
        "validity_period_overr_role_key" as "validity_period_overr_role_key",
        "override_validity_period" as "is_override_validity_period",
        "mandatory_attachment" as "is_mandatory_attachment",
        "override_mandatory_attachment" as "is_override_mandatory_attachment",
        "required_role_key" as "required_role_key",
        "override_required_role_key" as "is_override_required_role_key",
        "availability" as "availability",
        "expiration_date" as "expiration_date",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'custom_journal_document_type') }}
)

select * from custom_journal_document_type
