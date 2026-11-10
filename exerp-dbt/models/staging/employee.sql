{{ config(bind=false) }}

with employee as (

    select
        "center" as "center",
        "id" as "id",
        "blocked" as "is_blocked",
        "use_api" as "is_use_api",
        "personcenter" as "person_center",
        "personid" as "person_id",
        "last_login" as "last_login_date",
        "external_id" as "external_id",
        "pause_messages" as "is_paused_messages",
        "enterprise_subject" as "enterprise_subject",
        {{ exerp_epoch_milliseconds_to_timestamp('"created_at"', '_center_tz."_time_zone"') }} as "created_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"block_status_changed_at"', '_center_tz."_time_zone"') }} as "block_status_changed_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'employee') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from employee
