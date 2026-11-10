{{ config(bind=false) }}

with subscription_type as (

    select
        "center" as "center",
        "id" as "id",
        "st_type" as "type",
        CASE "st_type"
            WHEN 0 THEN 'CASH'
            WHEN 1 THEN 'EFT'
            WHEN 2 THEN 'CLIPCARD'
            WHEN 3 THEN 'COURSE'
        END as "type_text",
        "use_individual_price" as "is_use_individual_price",
        "productnew_center" as "productnew_center",
        "productnew_id" as "productnew_id",
        "floatingperiod" as "is_floating_period",
        "prorataperiodcount" as "prorata_period_count",
        "extend_binding_by_prorata" as "is_extend_binding_by_prorata",
        "initialperiodcount" as "initial_period_count",
        "extend_binding_by_initial" as "is_extend_binding_by_initial",
        "bindingperiodcount" as "binding_period_count",
        "periodunit" as "period_unit",
        "periodcount" as "period_count",
        "age_restriction_type" as "age_restriction_type",
        CASE "age_restriction_type"
            WHEN 1 THEN 'LESS THEN'
            WHEN 2 THEN 'MORE THEN'
            WHEN 3 THEN 'BETWEEN'
        END as "age_restriction_type_text",
        "age_restriction_value" as "age_restriction_value",
        "sex_restriction" as "sex_restriction",
        "freezeperiodproduct_center" as "freezeperiodproduct_center",
        "freezeperiodproduct_id" as "freezeperiodproduct_id",
        "freezestartupproduct_center" as "freezestartupproduct_center",
        "freezestartupproduct_id" as "freezestartupproduct_id",
        "transferproduct_center" as "transferproduct_center",
        "transferproduct_id" as "transferproduct_id",
        "add_on_to_center" as "add_on_to_center",
        "add_on_to_id" as "add_on_to_id",
        "renew_window" as "renew_window",
        "rank" as "rank",
        "is_addon_subscription" as "is_addon_subscription",
        "prorataproduct_center" as "prorataproduct_center",
        "prorataproduct_id" as "prorataproduct_id",
        "adminfeeproduct_center" as "adminfeeproduct_center",
        "adminfeeproduct_id" as "adminfeeproduct_id",
        "info_text" as "info_text",
        "clearing_house_restriction" as "clearing_house_restriction",
        "is_price_update_excluded" as "is_price_update_excluded",
        "start_date_limit_count" as "start_date_limit_count",
        "start_date_limit_unit" as "start_date_limit_unit",
        "start_date_restriction" as "start_date_restriction",
        "auto_stop_on_binding_end_date" as "is_auto_stop_on_binding_end_date",
        "roundup_end_unit" as "roundup_end_unit",
        "buyoutfeeproduct_center" as "buyoutfeeproduct_center",
        "buyoutfeeproduct_id" as "buyoutfeeproduct_id",
        "rec_clipcard_product_center" as "rec_clipcard_product_center",
        "rec_clipcard_product_id" as "rec_clipcard_product_id",
        "rec_clipcard_product_clips" as "rec_clipcard_product_clips",
        "sale_startup_clipcard" as "is_sale_startup_clipcard",
        "autorenew_binding_count" as "autorenew_binding_count",
        "autorenew_binding_unit" as "autorenew_binding_unit",
        "autorenew_binding_notice_count" as "autorenew_binding_notice_count",
        "autorenew_binding_notice_unit" as "autorenew_binding_notice_unit",
        "unrestricted_freeze_allowed" as "is_unrestricted_freeze_allowed",
        "buyout_fee_percentage" as "buyout_fee_percentage",
        "change_requiredrole" as "change_required_role",
        "can_be_reassigned" as "is_can_be_reassigned",
        "reassign_product_center" as "reassign_product_center",
        "reassign_product_id" as "reassign_product_id",
        "reassign_template" as "reassign_template",
        "reactivation_allowed" as "is_reactivation_allowed",
        "rec_clipcard_pack_size" as "rec_clipcard_pack_size",
        "age_restriction_min_value" as "age_restriction_min_value",
        "age_restriction_max_value" as "age_restriction_max_value",
        "documentation_setting_id" as "documentation_setting_id",
        "reassign_restrict_quantity" as "reassign_restrict_quantity",
        "reassign_restrict_span_unit" as "reassign_restrict_span_unit",
        "reassign_restrict_span_value" as "reassign_restrict_span_value",
        "reassign_restrict_type_id" as "reassign_restrict_type_id",
        "family_membership_type" as "family_membership_type",
        "renewal_requires_privilege" as "is_renewal_requires_privilege",
        "freeze_price_percentage" as "freeze_price_percentage",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscription_type') }}
)

select * from subscription_type
