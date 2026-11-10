{{ config(bind=false) }}

with questionnaire as (

    select
        "id" as "id",
        "name" as "name",
        "headline" as "headline",
        "text" as "text",
        "questions" as "questions",
        "employeecenter" as "employee_center",
        "employeeid" as "employee_id",
        "creation_time" as "creation_date",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "externalid" as "external_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'questionnaire') }}
)

select * from questionnaire
