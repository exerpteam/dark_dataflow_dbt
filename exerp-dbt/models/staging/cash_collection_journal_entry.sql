{{ config(bind=false) }}

with cash_collection_journal_entry as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "sub_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"creationtime"', '_center_tz."_time_zone"') }} as "creation_at",
        "step" as "step",
        "journalentry_id" as "journal_entry_id",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'cash_collection_journal_entry') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from cash_collection_journal_entry
