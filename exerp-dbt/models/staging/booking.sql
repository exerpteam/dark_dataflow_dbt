{{ config(bind=false) }}

with booking as (

    select
        "center" as "center",
        "id" as "id",
        {{ exerp_epoch_milliseconds_to_timestamp('"starttime"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"stoptime"', '_center_tz."_time_zone"') }} as "stopped_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', '_center_tz."_time_zone"') }} as "creation_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "creator_center" as "creator_center",
        "creator_id" as "creator_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"activation_time"', '_center_tz."_time_zone"') }} as "activation_at",
        "activation_by_center" as "activation_by_center",
        "activation_by_id" as "activation_by_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancelation_time"', '_center_tz."_time_zone"') }} as "cancelation_at",
        "cancellation_reason" as "cancellation_reason",
        "cancelation_by_center" as "cancelation_by_center",
        "cancelation_by_id" as "cancelation_by_id",
        "state" as "state",
        "conflict" as "is_conflict",
        "last_participation_seq" as "last_participation_seq",
        {{ exerp_epoch_milliseconds_to_timestamp('"queue_run_time"', '_center_tz."_time_zone"') }} as "queue_ran_at",
        "queue_run_by_center" as "queue_run_by_center",
        "queue_run_by_id" as "queue_run_by_id",
        "class_capacity" as "class_capacity",
        "waiting_list_capacity" as "waiting_list_capacity",
        "maximum_sub_staff_usages" as "maximum_sub_staff_usages",
        "name" as "name",
        "description" as "description",
        "coment" as "comment",
        "activity" as "activity",
        "main_booking_center" as "main_booking_center",
        "main_booking_id" as "main_booking_id",
        "recurrence_type" as "recurrence_type",
        "recurrence_data" as "recurrence_data",
        "recurrence_end" as "recurrence_end",
        "recurrence_for" as "recurrence_for",
        "recurrence_at_planned" as "is_recurrence_at_planned",
        "owner_center" as "owner_center",
        "owner_id" as "owner_id",
        "colour_group_id" as "colour_group_id",
        "booking_program_id" as "booking_program_id",
        "external_id" as "external_id",
        "deadline_showup_percentage" as "deadline_showup_percentage",
        "one_off_cancellation" as "is_one_off_cancellation",
        "min_age" as "min_age",
        "max_age" as "max_age",
        "min_age_strict" as "is_min_age_strict",
        "not_shown_notification_sent" as "is_not_shown_notification_sent",
        "streaming_id" as "streaming_id",
        "additional_info" as "additional_info",
        "main_preparation_booking_id" as "main_preparation_booking_id",
        "main_preparation_booking_center" as "main_preparation_booking_center",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from booking
