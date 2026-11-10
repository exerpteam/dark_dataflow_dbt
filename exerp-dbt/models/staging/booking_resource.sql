{{ config(bind=false) }}

with booking_resource as (

    select
        "center" as "center",
        "id" as "id",
        "name" as "name",
        "attendable" as "is_attendable",
        "show_calendar" as "is_show_calendar",
        "attend_privilege_id" as "attend_privilege_id",
        "state" as "state",
        "type" as "type",
        CASE "type"
            WHEN '1' THEN 'DAILY'
            WHEN '2' THEN 'WEEKLY'
            WHEN '3' THEN 'MONTHLY'
        END as "type_text",
        "vertices" as "vertices",
        "override_center_opening_hours" as "is_override_center_opening_hours",
        "coment" as "comment",
        "external_id" as "external_id",
        "sex_restriction" as "sex_restriction",
        "age_restriction_type" as "age_restriction_type",
        CASE "age_restriction_type"
            WHEN 0 THEN 'NONE'
            WHEN 1 THEN 'LESS THAN'
            WHEN 2 THEN 'GREATER THAN'
        END as "age_restriction_type_text",
        "age_restriction_value" as "age_restriction_value",
        "instructor_x" as "instructor_x",
        "instructor_y" as "instructor_y",
        "attend_availability_period_id" as "attend_availability_period_id",
        "staff_availability_period_id" as "staff_availability_period_id",
        "api_ignore__check_in" as "is_api_ignore_check_in",
        "api_check_out" as "is_api_check_out",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "age_restriction_min_value" as "age_restriction_min_value",
        "age_restriction_max_value" as "age_restriction_max_value",
        "webname" as "web_name",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'booking_resource') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from booking_resource
