{{ config(bind=false) }}

with subscription as (

    select
        "center" as "center",
        "id" as "id",
        "state" as "state",
        CASE "state"
            WHEN 0 THEN 'PENDING'
            WHEN 1 THEN 'AWAITING ACTIVATION (DEPRECATED)'
            WHEN 2 THEN 'ACTIVE'
            WHEN 3 THEN 'ENDED'
            WHEN 4 THEN 'FROZEN'
            WHEN 5 THEN 'CANCELLED'
            WHEN 6 THEN 'NOT PAID'
            WHEN 7 THEN 'WINDOW'
            WHEN 8 THEN 'CREATED'
            WHEN 9 THEN 'CREATED TRANSFERRED'
            WHEN 10 THEN 'CREATED TRANSFERRED (DEPRECATED)'
        END as "state_text",
        "sub_state" as "sub_state",
        CASE "sub_state"
            WHEN 1 THEN 'NONE'
            WHEN 2 THEN 'AWAITING_ACTIVATION'
            WHEN 3 THEN 'UPGRADED'
            WHEN 4 THEN 'DOWNGRADED'
            WHEN 5 THEN 'EXTENDED'
            WHEN 6 THEN 'TRANSFERRED'
            WHEN 7 THEN 'REGRETTED'
            WHEN 8 THEN 'CANCELLED'
            WHEN 9 THEN 'BLOCKED'
            WHEN 10 THEN 'CHANGED'
        END as "sub_state_text",
        "subscriptiontype_center" as "subscriptiontype_center",
        "subscriptiontype_id" as "subscriptiontype_id",
        "owner_center" as "owner_center",
        "owner_id" as "owner_id",
        "binding_end_date" as "binding_end_date",
        "binding_price" as "binding_price",
        "individual_price" as "is_individual_price",
        "subscription_price" as "subscription_price",
        "start_date" as "start_date",
        "end_date" as "end_date",
        "end_date_auto_binding_end_date" as "is_end_date_auto_binding",
        "billed_until_date" as "billed_until_date",
        "refmain_center" as "refmain_center",
        "refmain_id" as "refmain_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', '_center_tz."_time_zone"') }} as "creation_at",
        "creator_center" as "creator_center",
        "creator_id" as "creator_id",
        "orig_creator_center" as "orig_creator_center",
        "orig_creator_id" as "orig_creator_id",
        "saved_free_days" as "saved_free_days",
        "saved_free_months" as "saved_free_months",
        "invoiceline_center" as "invoiceline_center",
        "invoiceline_id" as "invoiceline_id",
        "invoiceline_subid" as "invoiceline_subid",
        "transferred_center" as "transferred_center",
        "transferred_id" as "transferred_id",
        "sub_comment" as "sub_comment",
        "extended_to_center" as "extended_to_center",
        "extended_to_id" as "extended_to_id",
        "renewal_reminder_sent" as "is_renewal_reminder_sent",
        "renewal_policy_override" as "renewal_policy_override",
        "campaign_code_id" as "campaign_code_id",
        "is_price_update_excluded" as "is_price_update_excluded",
        "startup_free_period_id" as "startup_free_period_id",
        "stup_free_period_unit" as "stup_free_period_unit",
        "stup_free_period_value" as "stup_free_period_value",
        "stup_free_period_type" as "stup_free_period_type",
        "stup_freep_extends_binding" as "is_stup_freep_extends_binding",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "changed_to_center" as "changed_to_center",
        "changed_to_id" as "changed_to_id",
        "change_type" as "change_type",
        CASE "change_type"
            WHEN 3 THEN 'Upgrade'
            WHEN 4 THEN 'Downgrade'
            WHEN 13 THEN 'Change'
        END as "change_type_text",
        "period_commission" as "period_commission",
        "payment_agreement_center" as "payment_agreement_center",
        "payment_agreement_id" as "payment_agreement_id",
        "payment_agreement_subid" as "payment_agreement_subid",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_edit_time"', '_center_tz."_time_zone"') }} as "last_edited_at",
        "is_change_restricted" as "is_change_restricted",
        "reassigned_center" as "reassigned_center",
        "reassigned_id" as "reassigned_id",
        "rec_clipcard_clips" as "rec_clipcard_clips",
        "buyoutfeeproduct_center" as "buyoutfeeproduct_center",
        "buyoutfeeproduct_id" as "buyoutfeeproduct_id",
        "assigned_staff_center" as "assigned_staff_center",
        "assigned_staff_id" as "assigned_staff_id",
        "installment_plan_id" as "installment_plan_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"reassigned_time"', '_center_tz."_time_zone"') }} as "reassigned_at",
        "family_id" as "family_id",
        "is_stop_requested_by_member" as "is_stop_requested_by_member",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscription') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from subscription
