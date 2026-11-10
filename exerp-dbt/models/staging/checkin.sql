{{ config(bind=false) }}

with checkin as (

    select
        "id" as "id",
        "person_center" as "person_center",
        "person_id" as "person_id",
        "checkin_center" as "checkin_center",
        {{ exerp_epoch_milliseconds_to_timestamp('"checkin_time"', '_center_tz."_time_zone"') }} as "checked_in_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"checkout_time"', '_center_tz."_time_zone"') }} as "check_out_at",
        "checked_out" as "is_checked_out",
        "card_checked_in" as "is_card_checked_in",
        "checkin_result" as "checkin_result",
        "identity_method" as "identity_method",
        CASE "identity_method"
            WHEN 1 THEN 'BARCODE'
            WHEN 2 THEN 'MAGNETIC_CARD'
            WHEN 3 THEN 'SSN'
            WHEN 4 THEN 'FOB'
            WHEN 5 THEN 'PIN'
            WHEN 6 THEN 'ANTI DROWN'
            WHEN 7 THEN 'QR'
        END as "identity_method_text",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "origin" as "origin",
        "checkout_reminder_count" as "check_out_reminder_count",
        "person_type" as "person_type",
        "checkin_failed_reason" as "checkin_failed_reason",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'checkin') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."checkin_center"
)

select * from checkin
