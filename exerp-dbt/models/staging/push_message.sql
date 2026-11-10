{{ config(bind=false) }}

with push_message as (

    select
        "id" as "id",
        "receiver_center" as "receiver_center",
        "receiver_id" as "receiver_id",
        "template_id" as "template_id",
        "template_type" as "template_type",
        {{ exerp_epoch_milliseconds_to_timestamp('"sent_time"', '_center_tz."_time_zone"') }} as "sent_at",
        "push_target_id" as "push_target_id",
        "subject" as "subject",
        "response_code" as "response_code",
        "error_message" as "error_message",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'push_message') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."receiver_center"
)

select * from push_message
