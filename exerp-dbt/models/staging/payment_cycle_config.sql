{{ config(bind=false) }}

with payment_cycle_config as (

    select
        "id" as "id",
        "name" as "name",
        "company" as "is_company",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "cycle_type" as "cycle_type",
        "interval_type" as "interval_type",
        CASE "interval_type"
            WHEN 0 THEN 'Daily'
            WHEN 1 THEN 'Weekly'
            WHEN 2 THEN 'Monthly'
        END as "interval_type_text",
        "interval" as "interval",
        "day_in_interval" as "day_in_interval",
        "days_before_due" as "days_before_due",
        "relative_renewal_days" as "relative_renewal_days",
        "deduction_date" as "deduction_date",
        "cashcollection_delay" as "cashcollection_delay",
        "booking_date" as "booking_date",
        "sign_up_deadline" as "sign_up_deadline",
        "sign_off_deadline" as "sign_off_deadline",
        "payment_coll_policy" as "payment_coll_policy",
        "renewal_policy" as "renewal_policy",
        "notify_deduction_change" as "is_notify_deduction_change",
        "pay_req_notification_mode" as "pay_req_notification_mode",
        "refunds_enablement_mode" as "refunds_enablement_mode",
        "recollect_account_balance" as "is_recollect_account_balance",
        "collect_future_days" as "collect_future_days",
        "exclude_collection_on_debt" as "is_exclude_collection_on_debt",
        "deduction_days_allowed" as "deduction_days_allowed",
        "skip_extra_collection" as "is_skip_extra_collection",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'payment_cycle_config') }}
)

select * from payment_cycle_config
