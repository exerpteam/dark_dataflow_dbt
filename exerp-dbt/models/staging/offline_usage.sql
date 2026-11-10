{{ config(bind=false) }}

with offline_usage as (

    select
        "id" as "id",
        "center" as "center",
        {{ exerp_epoch_milliseconds_to_timestamp('"timestamp"', '_center_tz."_time_zone"') }} as "timestamp",
        "card_identity" as "card_identity",
        "card_identity_method" as "card_identity_method",
        CASE "card_identity_method"
            WHEN 1 THEN 'BARCODE'
            WHEN 2 THEN 'MAGNETIC_CARD'
            WHEN 3 THEN 'SSN'
            WHEN 4 THEN 'RFID_CARD'
            WHEN 5 THEN 'PIN'
            WHEN 6 THEN 'ANTI DROWN'
            WHEN 7 THEN 'QRCODE'
        END as "card_identity_method_text",
        "reader_device_id" as "reader_device_id",
        "reader_device_sub_id" as "reader_device_sub_id",
        "person_center" as "person_center",
        "person_id" as "person_id",
        "usage_point_action_center" as "usage_point_action_center",
        "usage_point_action_id" as "usage_point_action_id",
        "client_id" as "client_id",
        "event_type" as "event_type",
        "device_part" as "device_part",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'offline_usage') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from offline_usage
