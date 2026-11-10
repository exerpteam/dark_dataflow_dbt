{{ config(bind=false) }}

with crm_task_activity as (

    select
        "id" as "id",
        "status" as "status",
        "workflow_id" as "workflow_id",
        "name" as "name",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_task_activity') }}
)

select * from crm_task_activity
