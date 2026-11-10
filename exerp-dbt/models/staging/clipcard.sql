{{ config(bind=false) }}

with clipcard as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "sub_id",
        "owner_center" as "owner_center",
        "owner_id" as "owner_id",
        "clips_left" as "clips_left",
        "clips_initial" as "clips_initial",
        "finished" as "is_finished",
        "cancelled" as "is_cancelled",
        "blocked" as "is_blocked",
        "invoiceline_center" as "invoice_line_center",
        "invoiceline_id" as "invoice_line_id",
        "invoiceline_subid" as "invoice_line_sub_id",
        "refmain_center" as "ref_main_subscription_center",
        "refmain_id" as "ref_main_subscription_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"valid_from"', '_center_tz."_time_zone"') }} as "valid_from",
        {{ exerp_epoch_milliseconds_to_timestamp('"valid_until"', '_center_tz."_time_zone"') }} as "valid_until",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancellation_time"', '_center_tz."_time_zone"') }} as "cancellation_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"blocking_time"', '_center_tz."_time_zone"') }} as "blocking_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"overdue_since"', '_center_tz."_time_zone"') }} as "overdue_since",
        "assigned_staff_group" as "assigned_staff_group",
        "assigned_staff_center" as "assigned_staff_center",
        "assigned_staff_id" as "assigned_staff_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "cc_comment" as "cc_comment",
        "creditline_center" as "credit_line_center",
        "creditline_id" as "credit_line_id",
        "creditline_subid" as "credit_line_sub_id",
        "transfer_from_clipcard_center" as "transfer_from_clip_card_center",
        "transfer_from_clipcard_id" as "transfer_from_clip_card_id",
        "transfer_from_clipcard_subid" as "transfer_from_clip_card_sub_id",
        "recurring_participation_key" as "recurring_participation_key",
        "booking_program_id" as "booking_program_id",
        "booking_program_activity_id" as "booking_program_activity_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'clipcard') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from clipcard
