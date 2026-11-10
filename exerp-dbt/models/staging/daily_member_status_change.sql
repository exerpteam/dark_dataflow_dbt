{{ config(bind=false) }}

with daily_member_status_change as (

    select
        "id" as "id",
        "person_center" as "person_center",
        "person_id" as "person_id",
        "change_date" as "change_date",
        "change" as "change",
        CASE "change"
            WHEN 0 THEN 'OTHER'
            WHEN 1 THEN 'JOINER'
            WHEN 2 THEN 'REJOINER'
            WHEN 3 THEN 'REACTIVATED'
            WHEN 4 THEN 'LEAVER'
            WHEN 5 THEN 'LEAVER_END_OF_DAY'
            WHEN 6 THEN 'CHANGE_MEMBERSHIP'
            WHEN 7 THEN 'TRANSFER_OUT'
            WHEN 8 THEN 'TRANSFER_IN'
            WHEN 9 THEN 'TRANSFER_IN_AND_CHANGE_MEMBERSHIP'
            WHEN 10 THEN 'MIGRATED'
            WHEN 11 THEN 'CORRECTION'
        END as "change_text",
        "member_number_delta" as "member_number_delta",
        "extra_number_delta" as "extra_number_delta",
        "secondary_member_number_delta" as "secondary_member_number_delta",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_start_time"', '_center_tz."_time_zone"') }} as "entry_started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_stop_time"', '_center_tz."_time_zone"') }} as "entry_stopped_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'daily_member_status_change') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."person_center"
)

select * from daily_member_status_change
