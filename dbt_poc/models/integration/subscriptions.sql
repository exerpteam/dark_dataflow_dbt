{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key=['center', 'id'],
        full_refresh=false
    )
}}

select
    center,
    id,
    state,
    sub_state,
    subscriptiontype_center,
    subscriptiontype_id,
    owner_center,
    owner_id,
    binding_end_date,
    binding_price,
    individual_price,
    subscription_price,
    start_date,
    end_date,
    end_date_auto_binding_end_date,
    billed_until_date,
    refmain_center,
    refmain_id,
    creation_time,
    creator_center,
    creator_id,
    orig_creator_center,
    orig_creator_id,
    saved_free_days,
    saved_free_months,
    invoiceline_center,
    invoiceline_id,
    invoiceline_subid,
    adminfee_invoiceline_subid,
    transferred_center,
    transferred_id,
    sub_comment,
    extended_to_center,
    extended_to_id,
    renewal_reminder_sent,
    renewal_policy_override,
    campaign_code_id,
    is_price_update_excluded,
    startup_free_period_id,
    stup_free_period_unit,
    stup_free_period_value,
    stup_free_period_type,
    stup_freep_extends_binding,
    last_modified,
    changed_to_center,
    changed_to_id,
    change_type,
    period_commission,
    payment_agreement_center,
    payment_agreement_id,
    payment_agreement_subid,
    last_edit_time,
    is_change_restricted,
    reassigned_center,
    reassigned_id,
    rec_clipcard_clips,
    buyoutfeeproduct_center,
    buyoutfeeproduct_id,
    assigned_staff_center,
    assigned_staff_id,
    installment_plan_id,
    reassigned_time,
    family_id,
    is_stop_requested_by_member
from {{ source('postgres', 'subscriptions') }}


{% if is_incremental() %}

where last_modified >= (
    select coalesce(max(last_modified), 0) - 300000
    from {{ this }}
)

{% endif %}