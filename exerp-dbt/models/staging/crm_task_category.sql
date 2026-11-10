{{ config(bind=false) }}

with crm_task_category as (

    select
        "id" as "id",
        "name" as "name",
        "status" as "status",
        "external_id" as "external_id",
        "description" as "description",
        "workflow_id" as "workflow_id",
        "color" as "color",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_task_category') }}
)

select * from crm_task_category
