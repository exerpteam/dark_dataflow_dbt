{{ config(bind=false) }}

with crm_task_type as (

    select
        "id" as "id",
        "status" as "status",
        "name" as "name",
        "description" as "description",
        "workflow_id" as "workflow_id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "external_id" as "external_id",
        "follow_up_interval_type" as "follow_up_interval_type",
        "follow_up_interval" as "follow_up_interval",
        "roles" as "roles",
        "manager_roles" as "manager_roles",
        "unassigned_roles" as "unassigned_roles",
        "booking_search_id" as "booking_search_id",
        "membership_sales_access" as "is_membership_sales_access",
        "staff_groups" as "staff_groups",
        "available_in_lead_creation" as "is_available_in_lead_creation",
        "follow_up_overdue_type" as "follow_up_overdue_type",
        "follow_up_overdue_interval" as "follow_up_overdue_interval",
        "task_center_selection_type" as "task_center_selection_type",
        "task_specific_center" as "task_specific_center",
        "restrict_to_lead_center" as "is_restrict_to_lead_center",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_task_type') }}
)

select * from crm_task_type
