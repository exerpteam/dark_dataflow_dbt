{{ config(bind=false) }}

with crm_workflow as (

    select
        "id" as "id",
        "status" as "status",
        "name" as "name",
        "external_id" as "external_id",
        "initial_step_id" as "initial_task_step_id",
        "default_category_id" as "default_task_category_id",
        "extended_attributes" as "extended_attributes",
        "task_title_subjects" as "task_title_subjects",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_workflow') }}
)

select * from crm_workflow
