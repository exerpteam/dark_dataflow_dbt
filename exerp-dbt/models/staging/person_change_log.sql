{{ config(bind=false) }}

with person_change_log as (

    select
        "id" as "id",
        "person_center" as "person_center",
        "person_id" as "person_id",
        "previous_entry_id" as "previous_entry_id",
        "change_source" as "change_source",
        "change_attribute" as "change_attribute",
        "new_value" as "new_value",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "login_type" as "login_type",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'person_change_log') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."person_center"
)

select * from person_change_log
