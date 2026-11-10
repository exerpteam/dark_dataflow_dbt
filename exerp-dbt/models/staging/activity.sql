{{ config(bind=false) }}

with activity as (

    select
        "id" as "id",
        "top_node_id" as "top_node_id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "name" as "name",
        "state" as "state",
        "availability" as "availability",
        "activity_type" as "activity_type",
        CASE "activity_type"
            WHEN 1 THEN 'GENERAL'
            WHEN 2 THEN 'CLASS'
            WHEN 3 THEN 'RESOURCE BOOKING'
            WHEN 4 THEN 'STAFF BOOKING'
            WHEN 5 THEN 'MEETING'
            WHEN 6 THEN 'STAFF AVAILABILITY'
            WHEN 7 THEN 'RESOURCE AVAILABILITY'
            WHEN 8 THEN 'CHILDCARE'
            WHEN 9 THEN 'COURSE'
            WHEN 10 THEN 'TASK'
            WHEN 11 THEN 'CAMP'
            WHEN 12 THEN 'CAMP ELECTIVE'
        END as "activity_type_text",
        "activity_group_id" as "activity_group_id",
        "colour_group_id" as "colour_group_id",
        "creation_privilege_group_id" as "creation_privilege_group_id",
        "duration_list" as "duration_list",
        "description" as "description",
        "description_mime_type" as "description_mime_type",
        "max_participants" as "max_participants",
        "max_waiting_list_participants" as "max_waiting_list_participants",
        "requires_planning" as "is_requires_planning",
        "allow_name_override" as "is_allow_name_override",
        "allow_recurring_bookings" as "is_allow_recurring_bookings",
        "maximum_sub_staff_usages" as "maximum_sub_staff_usages",
        "override_resource_configs" as "is_override_resource_configs",
        "override_staff_configs" as "is_override_staff_configs",
        "override_participation_configs" as "is_override_participation_configs",
        "override_time_config" as "is_override_time_config",
        "time_config_id" as "time_config_id",
        "sub_staff_usage_interval" as "sub_staff_usage_interval",
        "energy_consumption_kcal_hour" as "energy_consumption_kcal_hour",
        "external_id" as "external_id",
        "lessons" as "lessons",
        "age_group_id" as "age_group_id",
        "course_type_id" as "course_type_id",
        "course_level_id" as "course_level_id",
        "seat_booking_support_type" as "seat_booking_support_type",
        "headcount_manual_adjustment" as "is_headcount_manual_adjustment",
        "available_from" as "available_from",
        "available_to" as "available_to",
        "course_schedule_type" as "course_schedule_type",
        CASE "course_schedule_type"
            WHEN 0 THEN 'FIXED'
            WHEN 1 THEN 'CONTINUOUS'
        END as "course_schedule_type_text",
        "print_showup_receipt" as "is_print_showup_receipt",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "allow_overlapping_bookings" as "is_allow_overlapping_bookings",
        "age_restriction_on_bookings" as "is_age_restriction_on_bookings",
        "allow_multiple_camps" as "is_allow_multiple_camps",
        "enable_streaming_id" as "is_enable_streaming_id",
        "documentation_setting_id" as "documentation_setting_id",
        "additional_info" as "additional_info",
        "set_up_activity_id" as "set_up_activity_id",
        "set_up_mandatory" as "is_set_up_mandatory",
        "dismantling_activity_id" as "dismantling_activity_id",
        "dismantling_mandatory" as "is_dismantling_mandatory",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'activity') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."scope_id" and _source_row."scope_type" = 'C'
)

select * from activity
