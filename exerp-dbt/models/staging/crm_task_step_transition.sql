{{ config(bind=false) }}

with crm_task_step_transition as (

    select
        "id" as "id",
        "task_action_id" as "task_action_id",
        "task_step_id" as "task_step_id",
        "transition_to_step_id" as "transition_to_step_id",
        "task_user_choice_id" as "task_user_choice_id",
        "new_task_status" as "new_task_status",
        "assign_category_id" as "assign_category_id",
        "post_transition_action" as "post_transition_action",
        "follow_up_interval_type" as "follow_up_interval_type",
        "follow_up_interval" as "follow_up_interval",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_task_step_transition') }}
)

select * from crm_task_step_transition
