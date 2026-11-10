{{ config(bind=false) }}

with crm_task_actions_requirement as (

    select
        "task_action_id" as "task_action_id",
        "requirement_type" as "requirement_type",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_task_actions_requirement') }}
)

select * from crm_task_actions_requirement
