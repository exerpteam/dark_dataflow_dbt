{{ config(bind=false) }}

with usage_point_action as (

    select
        "center" as "center",
        "id" as "id",
        "usage_point_center" as "usage_point_center",
        "usage_point_id" as "usage_point_id",
        "name" as "name",
        "resource_order" as "action_order",
        "resource_usage" as "resource_usage",
        "check_out" as "is_check_out",
        "handback_check" as "is_handback_check",
        "print_ticket" as "is_print_ticket",
        "auto_execution_kiosk" as "is_auto_execution_kiosk",
        "shortcut_key" as "shortcut_key",
        "block_unsigned_documents" as "is_block_unsigned_documents",
        "block_incomplete_agreement" as "is_block_incomplete_agreement",
        "no_reentry_before_checkout" as "is_no_reentry_before_checkout",
        "no_check_in" as "is_no_check_in",
        "exit_previous_attend" as "is_exit_previous_attend",
        "exit_resource_center" as "exit_resource_center",
        "exit_resource_id" as "exit_resource_id",
        "block_expired_hc" as "is_block_expired_health_certificate",
        "notify_on_access_error" as "is_notify_on_access_error",
        "enter_attend_duration" as "is_enter_attend_duration",
        "show_attendance_history" as "is_show_attendance_history",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'usage_point_action') }}
)

select * from usage_point_action
