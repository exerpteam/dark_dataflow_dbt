{{ config(bind=false) }}

with state_change_log as (

    select
        "key" as "key",
        "center" as "center",
        "id" as "id",
        "subid" as "subid",
        "entry_type" as "entry_type",
        CASE "entry_type"
            WHEN 1 THEN 'PERSON_STATE_LOG'
            WHEN 2 THEN 'SUBSCRIPTION_STATE_LOG'
            WHEN 3 THEN 'PERSON_TYPE_LOG'
            WHEN 4 THEN 'RELATION_STATE_LOG'
            WHEN 5 THEN 'MEMBER_STATUS_LOG'
            WHEN 6 THEN 'CLIPCARD_STATUS_LOG'
        END as "entry_type_text",
        "stateid" as "state_id",
        CASE "stateid"
            WHEN 0 THEN 'PRIVATE'
            WHEN 1 THEN 'STUDENT'
            WHEN 2 THEN 'STAFF'
            WHEN 3 THEN 'FRIEND'
            WHEN 4 THEN 'CORPORATE'
            WHEN 5 THEN 'ONEMANCORPORATE'
            WHEN 6 THEN 'FAMILY'
            WHEN 7 THEN 'SENIOR'
            WHEN 8 THEN 'GUEST'
            WHEN 9 THEN 'CONTACT'
            WHEN 10 THEN 'EXTERNAL_STAFF'
        END as "state_id_text",
        "sub_state" as "sub_state",
        CASE "sub_state"
            WHEN 1 THEN 'NONE'
            WHEN 2 THEN 'AWAITING_ACTIVATION'
            WHEN 3 THEN 'UPGRADED'
            WHEN 4 THEN 'DOWNGRADED'
            WHEN 5 THEN 'EXTENDED'
            WHEN 6 THEN 'TRANSFERRED'
            WHEN 7 THEN 'REGRETTED'
            WHEN 8 THEN 'CANCELLED'
            WHEN 9 THEN 'BLOCKED'
            WHEN 10 THEN 'CHANGED'
        END as "sub_state_text",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_start_time"', '_center_tz."_time_zone"') }} as "entry_started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_end_time"', '_center_tz."_time_zone"') }} as "entry_ended_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"book_start_time"', '_center_tz."_time_zone"') }} as "book_started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"book_end_time"', '_center_tz."_time_zone"') }} as "book_ended_at",
        "had_report_role" as "is_had_report_role",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'state_change_log') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from state_change_log
