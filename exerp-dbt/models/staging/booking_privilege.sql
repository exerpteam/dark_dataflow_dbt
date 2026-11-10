{{ config(bind=false) }}

with booking_privilege as (

    select
        "id" as "id",
        "privilege_set" as "privilege_set",
        "valid_for" as "valid_for",
        {{ exerp_epoch_milliseconds_to_timestamp('"valid_from"', 'UTC') }} as "valid_from",
        {{ exerp_epoch_milliseconds_to_timestamp('"valid_to"', 'UTC') }} as "valid_to",
        "group_id" as "group_id",
        "max_open" as "max_open",
        "tentative_only" as "is_tentative_only",
        "cutoff_time_setting_id" as "cutoff_time_setting_id",
        "in_advance_threshold" as "in_advance_threshold",
        "requires_manual_selection" as "is_requires_manual_selection",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking_privilege') }}
)

select * from booking_privilege
