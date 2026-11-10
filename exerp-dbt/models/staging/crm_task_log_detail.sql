{{ config(bind=false) }}

with crm_task_log_detail as (

    select
        "id" as "id",
        "task_log_id" as "task_log_id",
        "type" as "type",
        "reference_center" as "reference_center",
        "reference_id" as "reference_id",
        "reference_sub_id" as "reference_sub_id",
        "reference_table" as "reference_table",
        "name" as "name",
        "value" as "value",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_task_log_detail') }}
)

select * from crm_task_log_detail
