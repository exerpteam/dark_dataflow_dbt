{{ config(bind=false) }}

with questionnaire_campaign as (

    select
        "id" as "id",
        "questionnaire" as "questionnaire",
        "name" as "name",
        "required" as "is_required",
        "startdate" as "start_date",
        "stopdate" as "stop_date",
        "type" as "type",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "rank" as "rank",
        "viewresultrole" as "view_result_role",
        "source_id" as "source_id",
        "document_template_id" as "document_template_id",
        "validity_period_value" as "validity_period_value",
        "validity_period_unit" as "validity_period_unit",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'questionnaire_campaign') }}
)

select * from questionnaire_campaign
