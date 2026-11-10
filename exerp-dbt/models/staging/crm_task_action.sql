{{ config(bind=false) }}

with crm_task_action as (

    select
        "id" as "id",
        "status" as "status",
        "workflow_id" as "workflow_id",
        "name" as "name",
        "external_id" as "external_id",
        "automatic" as "is_automatic",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_task_action') }}
)

select * from crm_task_action
