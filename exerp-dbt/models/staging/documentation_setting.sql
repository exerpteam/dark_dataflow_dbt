{{ config(bind=false) }}

with documentation_setting as (

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
        "availability" as "availability",
        "name" as "name",
        "override_name" as "is_override_name",
        "external_id" as "external_id",
        "override_external_id" as "is_override_external_id",
        "type" as "type",
        "override_cust_journ_doc_types" as "is_override_cust_journ_doc_types",
        "contract_template_id" as "contract_template_id",
        "override_contract_template" as "is_override_contract_template",
        "override_questionnaire_campgns" as "is_override_questionnaire_campgns",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'documentation_setting') }}
)

select * from documentation_setting
