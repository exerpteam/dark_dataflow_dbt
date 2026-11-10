{{ config(bind=false) }}

with clipcard_type as (

    select
        "center" as "center",
        "id" as "id",
        "add_on_to_center" as "add_on_to_center",
        "add_on_to_id" as "add_on_to_id",
        "clip_count" as "clip_count",
        "period_unit" as "period_unit",
        "period_count" as "period_count",
        "period_round" as "period_round",
        "age_restriction_type" as "age_restriction_type",
        "age_restriction_value" as "age_restriction_value",
        "sex_restriction" as "sex_restriction",
        "info_text" as "info_text",
        "buyoutfeeproduct_center" as "buyoutfeeproduct_center",
        "buyoutfeeproduct_id" as "buyoutfeeproduct_id",
        "contract_template_id" as "contract_template_id",
        "clipcard_usage_commission" as "clip_card_usage_commission",
        "assigned_staff_group" as "assigned_staff_group",
        "buyout_fee_percentage" as "buyout_fee_percentage",
        "clips_pack_size" as "clips_pack_size",
        "age_restriction_min_value" as "age_restriction_min_value",
        "age_restriction_max_value" as "age_restriction_max_value",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'clipcard_type') }}
)

select * from clipcard_type
