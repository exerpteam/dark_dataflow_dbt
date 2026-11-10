{{ config(bind=false) }}

with crm_task_user_choice as (

    select
        "id" as "id",
        "workflow_id" as "workflow_id",
        "status" as "status",
        "name" as "name",
        "description" as "description",
        "requires_text" as "is_requires_text",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_task_user_choice') }}
)

select * from crm_task_user_choice
