{{ config(bind=false) }}

with crm_task_step as (

    select
        "id" as "id",
        "status" as "status",
        "workflow_id" as "workflow_id",
        "name" as "name",
        "description" as "description",
        "external_id" as "external_id",
        "task_activity_id" as "task_activity_id",
        "progress_id" as "progress_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_task_step') }}
)

select * from crm_task_step
