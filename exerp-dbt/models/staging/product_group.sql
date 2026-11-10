{{ config(bind=false) }}

with product_group as (

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
        "parent_product_group_id" as "parent_product_group_id",
        "dimension_product_group_id" as "dimension_product_group_id",
        "show_in_shop" as "is_show_in_shop",
        "product_account_config_id" as "product_account_config_id",
        "colour_group_id" as "colour_group_id",
        "ranking" as "ranking",
        "description" as "description",
        "in_subscription_sales" as "is_in_subscription_sales",
        "hide_in_report_parameters" as "is_hide_in_report_parameters",
        "exclude_from_member_count" as "is_exclude_from_member_count",
        "exclude_from_product_cleaning" as "is_exclude_from_product_cleaning",
        "external_id" as "external_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', 'UTC') }} as "modified_at",
        "single_product_in_basket" as "is_single_product_in_basket",
        "show_on_web" as "is_show_on_web",
        "installment_plans_enabled" as "is_installment_plans_enabled",
        "include_in_termination_policy" as "is_include_in_termination_policy",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'product_group') }}
)

select * from product_group
