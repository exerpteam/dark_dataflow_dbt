{{ config(bind=false) }}

with product as (

    select
        "center" as "center",
        "id" as "id",
        "blocked" as "is_blocked",
        "ptype" as "type",
        CASE "ptype"
            WHEN 1 THEN 'RETAIL'
            WHEN 2 THEN 'SERVICE'
            WHEN 4 THEN 'CLIPCARD'
            WHEN 5 THEN 'SUBSCRIPTION CREATION'
            WHEN 6 THEN 'TRANSFER'
            WHEN 7 THEN 'FREEZE PERIOD'
            WHEN 8 THEN 'GIFT CARD'
            WHEN 9 THEN 'FREE GIFT CARD'
            WHEN 10 THEN 'SUBSCRIPTION'
            WHEN 12 THEN 'SUBSCRIPTION PRO-RATA'
            WHEN 13 THEN 'SUBSCRIPTION ADD-ON'
            WHEN 14 THEN 'ACCESS'
        END as "type_text",
        "name" as "name",
        "coment" as "comment",
        "external_id" as "external_id",
        "income_accountcenter" as "income_accountcenter",
        "income_accountid" as "income_accountid",
        "expense_accountcenter" as "expense_accountcenter",
        "expense_accountid" as "expense_accountid",
        "refund_accountcenter" as "refund_accountcenter",
        "refund_accountid" as "refund_accountid",
        "price" as "price",
        "min_price" as "min_price",
        "cost_price" as "cost_price",
        "requiredrole" as "required_role",
        "globalid" as "global_id",
        "max_buy_qty" as "max_buy_qty",
        "max_buy_qty_period" as "max_buy_qty_period",
        "max_buy_qty_period_type" as "max_buy_qty_period_type",
        "needs_privilege" as "is_needs_privilege",
        "show_in_sale" as "is_show_in_sale",
        "returnable" as "is_returnable",
        "show_on_web" as "is_show_on_web",
        "show_on_mobile_api" as "is_show_on_mobile_api",
        "primary_product_group_id" as "primary_product_group_id",
        "product_account_config_id" as "product_account_config_id",
        "override_price_and_text_role" as "override_price_and_text_role",
        "ipc_available" as "is_ipc_available",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "restriction_type" as "restriction_type",
        "mapi_selling_points" as "mapi_selling_points",
        "mapi_rank" as "mapi_rank",
        "mapi_description" as "mapi_description",
        "sales_commission" as "sales_commission",
        "sales_units" as "sales_units",
        "sold_outside_home_center" as "is_sold_outside_home_center",
        "period_commission" as "period_commission",
        "print_qr_on_receipt" as "is_print_qr_on_receipt",
        "assigned_staff_group" as "assigned_staff_group",
        {{ exerp_epoch_milliseconds_to_date('"last_recount_date"') }} as "last_recount_date",
        "single_use" as "is_single_use",
        "flat_rate_commission" as "flat_rate_commission",
        "webname" as "web_name",
        "commissionable" as "commissionable",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'product') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from product
