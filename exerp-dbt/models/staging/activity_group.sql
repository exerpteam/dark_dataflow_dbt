{{ config(bind=false) }}

with activity_group as (

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
        "old_activity_type_id" as "old_activity_type_id",
        "public_participation" as "is_public_participation",
        "bookable_in_kiosk" as "is_bookable_in_kiosk",
        "bookable_on_web" as "is_bookable_on_web",
        "bookable_via_api" as "is_bookable_via_api",
        "bookable_via_mobile_api" as "is_bookable_via_mobile_api",
        "bookable_on_frontdesk_app" as "is_bookable_on_frontdesk_app",
        "create_booking_role" as "create_booking_role",
        "handle_multiple_bookings_role" as "handle_multiple_bookings_role",
        "override_description" as "is_override_description",
        "showup_by_qrcode" as "is_showup_by_qrcode",
        "edit_booking_role" as "edit_booking_role",
        "cancel_booking_role" as "cancel_booking_role",
        "supports_substitution_flag" as "is_supports_substitution_flag",
        "showup_by_mobile_api" as "is_showup_by_mobile_api",
        "wait_list_cap_perc" as "wait_list_cap_perc",
        "override_wait_list_cap_perc" as "is_override_wait_list_cap_perc",
        "indicate_new_members" as "is_indicate_new_members",
        "parent_activity_group_id" as "parent_activity_group_id",
        "external_id" as "external_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "availability_period_id" as "availability_period_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'activity_group') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."scope_id"
        and _source_row."scope_type" = 'C'
)

select * from activity_group
