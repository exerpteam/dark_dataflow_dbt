{{ config(bind=false) }}

with clipcard_usage as (

    select
        "id" as "id",
        {{ exerp_epoch_milliseconds_to_timestamp('"time"', '_center_tz."_time_zone"') }} as "time",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "description" as "description",
        "type" as "type",
        "state" as "state",
        "clips" as "clips",
        "ref" as "ref",
        "card_center" as "clipcard_center",
        "card_id" as "clipcard_id",
        "card_subid" as "clipcard_sub_id",
        "clipcard_usage_commission" as "clipcard_usage_commission",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancellation_timestamp"', '_center_tz."_time_zone"') }} as "cancellation_timestamp",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"activation_timestamp"', '_center_tz."_time_zone"') }} as "activation_timestamp",
        "creditline_center" as "credit_note_line_center",
        "creditline_id" as "credit_note_line_id",
        "creditline_subid" as "credit_note_line_sub_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'clipcard_usage') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."card_center"
)

select * from clipcard_usage
