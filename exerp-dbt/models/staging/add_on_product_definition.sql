{{ config(bind=false) }}

with add_on_product_definition as (

    select
        "id" as "id",
        "price_period_count" as "price_period_count",
        "price_period_unit" as "price_period_unit",
        "scope_selection" as "scope_selection",
        "include_home_center" as "is_include_home_center",
        "required" as "is_required",
        "secondary_membership" as "is_secondary_membership",
        "secondary_membership_type" as "secondary_membership_type",
        "sec_mem_age_restriction_type" as "sec_mem_age_restriction_type",
        "sec_mem_age_restriction_value" as "sec_mem_age_restriction_value",
        "sec_mem_sex_restriction_type" as "sec_mem_sex_restriction_type",
        "quantity_min" as "quantity_min",
        "quantity_max" as "quantity_max",
        "quantity_default" as "quantity_default",
        "num_secondary_members_per_unit" as "num_secondary_members_per_unit",
        "use_individual_price" as "is_use_individual_price",
        "freeze_fee_product_id" as "freeze_fee_product_id",
        "include_in_pro_rata_period" as "is_include_in_pro_rata_period",
        "binding_period_count" as "binding_period_count",
        "binding_period_unit" as "binding_period_unit",
        "start_date_restriction" as "start_date_restriction",
        "added_by_default" as "is_added_by_default",
        "sec_mem_age_rest_min_value" as "sec_mem_age_rest_min_value",
        "sec_mem_age_rest_max_value" as "sec_mem_age_rest_max_value",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'add_on_product_definition') }}
)

select * from add_on_product_definition
