{{ config(bind=false) }}

with master_product_register as (

    select
        "id" as "id",
        "definition_key" as "definition_key",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "globalid" as "global_id",
        "masterproductregistertype" as "master_product_register_type",
        "masterproductgroup" as "master_product_group",
        "cached_productname" as "cached_productname",
        "cached_productprice" as "cached_productprice",
        "cached_productcostprice" as "cached_productcostprice",
        "cached_producttype" as "cached_producttype",
        "cached_external_id" as "cached_external_id",
        "info_text" as "info_text",
        "clearing_house_restriction" as "clearing_house_restriction",
        "globally_blocked" as "is_globally_blocked",
        "state" as "state",
        "primary_product_group_id" as "primary_product_group_id",
        "product_account_config_id" as "product_account_config_id",
        "creation_account_config_id" as "creation_account_config_id",
        "prorata_account_config_id" as "prorata_account_config_id",
        "admin_fee_config_id" as "admin_fee_config_id",
        "use_contract_template" as "is_use_contract_template",
        "contract_template_id" as "contract_template_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_state_change"', 'UTC') }} as "last_state_change",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', 'UTC') }} as "modified_at",
        "has_future_price_change" as "is_has_future_price_change",
        "mapi_selling_points" as "mapi_selling_points",
        "mapi_rank" as "mapi_rank",
        "mapi_description" as "mapi_description",
        "buyout_fee_config_id" as "buyout_fee_config_id",
        "recurring_clipcard_id" as "recurring_clipcard_id",
        "recurring_clipcard_clips" as "recurring_clipcard_clips",
        "sale_startup_clipcard" as "is_sale_startup_clipcard",
        "sales_commission" as "sales_commission",
        "sales_units" as "sales_units",
        "period_commission" as "period_commission",
        "print_qr_on_receipt" as "is_print_qr_on_receipt",
        "buyout_fee_percentage" as "buyout_fee_percentage",
        "single_use" as "is_single_use",
        "change_requiredrole" as "change_requiredrole",
        "clipcard_pack_size" as "clipcard_pack_size",
        "flat_rate_commission" as "flat_rate_commission",
        "webname" as "web_name",
        "use_documentation_settings" as "is_use_documentation_settings",
        "documentation_settings_id" as "documentation_settings_id",
        "family_membership_type" as "family_membership_type",
        "commissionable" as "commissionable",
        "freeze_price_percentage" as "freeze_price_percentage",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'master_product_register') }}
)

select * from master_product_register
