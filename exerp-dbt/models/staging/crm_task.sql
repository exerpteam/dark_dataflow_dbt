{{ config(bind=false) }}

with crm_task as (

    select
        "id" as "id",
        "status" as "status",
        "step_id" as "step_id",
        "title" as "title",
        "source_type" as "source_type",
        "person_center" as "person_center",
        "person_id" as "person_id",
        "creator_center" as "creator_center",
        "creator_id" as "creator_id",
        "owner_center" as "owner_center",
        "owner_id" as "owner_id",
        "asignee_center" as "asignee_center",
        "asignee_id" as "asignee_id",
        "type_id" as "type_id",
        "invoice_center" as "invoice_center",
        "invoice_id" as "invoice_id",
        "follow_up" as "follow_up_date",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', '_center_tz."_time_zone"') }} as "creation_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_update_time"', '_center_tz."_time_zone"') }} as "last_updated_at",
        "permanent_note" as "permanent_note",
        "last_choice_id" as "last_choice_id",
        "task_category_id" as "task_category_id",
        "center" as "center",
        {{ exerp_epoch_milliseconds_to_timestamp('"follow_up_time"', '_center_tz."_time_zone"') }} as "follow_up_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_task') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from crm_task
