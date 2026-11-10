{{ config(bind=false) }}

with questionnaire_answer as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "subid",
        "questionnaire_campaign_id" as "questionnaire_campaign_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"log_time"', '_center_tz."_time_zone"') }} as "logged_at",
        "completed" as "is_completed",
        "result_code" as "result_code",
        "status" as "status",
        "journal_entry_id" as "journal_entry_id",
        "expiration_date" as "expiration_date",
        "replaced_by_center" as "replaced_by_center",
        "replaced_by_id" as "replaced_by_id",
        "replaced_by_subid" as "replaced_by_subid",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'questionnaire_answer') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from questionnaire_answer
