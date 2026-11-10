{{ config(bind=false) }}

with crm_task_log as (

    select
        "id" as "id",
        "task_id" as "task_id",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"event_time"', '_center_tz."_time_zone"') }} as "event_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "task_action_id" as "task_action_id",
        "task_step_id" as "task_step_id",
        "task_status" as "task_status",
        "previous_task_log_id" as "previous_task_log_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_task_log') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."employee_center"
)

select * from crm_task_log
