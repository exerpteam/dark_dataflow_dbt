{{ config(bind=false) }}

with participation as (

    select
        "center" as "center",
        "id" as "id",
        "configuration" as "configuration",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', '_center_tz."_time_zone"') }} as "creation_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "creation_by_center" as "creation_by_center",
        "creation_by_id" as "creation_by_id",
        "participation_number" as "participation_number",
        {{ exerp_epoch_milliseconds_to_timestamp('"start_time"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"stop_time"', '_center_tz."_time_zone"') }} as "stopped_at",
        "booking_center" as "booking_center",
        "booking_id" as "booking_id",
        "participant_center" as "participant_center",
        "participant_id" as "participant_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"showup_time"', '_center_tz."_time_zone"') }} as "showup_at",
        "showup_interface_type" as "showup_interface_type",
        "showup_using_card" as "is_showup_using_card",
        "showup_by_center" as "showup_by_center",
        "showup_by_id" as "showup_by_id",
        "on_waiting_list" as "is_on_waiting_list",
        "state" as "state",
        "cancelation_reason" as "cancelation_reason",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancelation_time"', '_center_tz."_time_zone"') }} as "cancelation_at",
        "cancelation_interface_type" as "cancelation_interface_type",
        "cancelation_by_center" as "cancelation_by_center",
        "cancelation_by_id" as "cancelation_by_id",
        "user_interface_type" as "user_interface_type",
        "reminder_message_attempted" as "is_reminder_message_attempted",
        "no_show_up_punish_state" as "no_show_up_punish_state",
        {{ exerp_epoch_milliseconds_to_timestamp('"moved_up_time"', '_center_tz."_time_zone"') }} as "moved_up_at",
        "cancelation_notified" as "is_cancelation_notified",
        {{ exerp_epoch_milliseconds_to_timestamp('"print_time"', '_center_tz."_time_zone"') }} as "printed_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"finish_time"', '_center_tz."_time_zone"') }} as "finished_at",
        "invoice_line_center" as "invoice_line_center",
        "invoice_line_id" as "invoice_line_id",
        "invoice_line_subid" as "invoice_line_subid",
        "energy_consumption_kcal" as "energy_consumption_kcal",
        "external_id" as "external_id",
        "seat_id" as "seat_id",
        "owner_center" as "owner_center",
        "owner_id" as "owner_id",
        "seat_state" as "seat_state",
        "used_owner_privilege" as "is_used_owner_privilege",
        "booking_participation_type" as "booking_participation_type",
        "reviewed_by_center" as "reviewed_by_center",
        "reviewed_by_id" as "reviewed_by_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"reviewed_time"', '_center_tz."_time_zone"') }} as "reviewed_at",
        "last_checkin_autoshowup" as "last_checkin_autoshowup",
        {{ exerp_epoch_milliseconds_to_timestamp('"tentative_cutoff_time"', '_center_tz."_time_zone"') }} as "tentative_cutoff_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"showup_entry_time"', '_center_tz."_time_zone"') }} as "showup_entry_at",
        "pickup_by_center" as "pickup_by_center",
        "pickup_by_id" as "pickup_by_id",
        "dropoff_by_center" as "dropoff_by_center",
        "dropoff_by_id" as "dropoff_by_id",
        "recurring_participation_key" as "recurring_participation_key",
        "after_sale_process" as "is_after_sale_process",
        "confirmation_process" as "is_confirmation_process",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'participation') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from participation
