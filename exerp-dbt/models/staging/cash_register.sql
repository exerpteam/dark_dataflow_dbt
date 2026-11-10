{{ config(bind=false) }}

with cash_register as (

    select
        "center" as "center",
        "id" as "id",
        "name" as "name",
        "type" as "type",
        "cash" as "is_cash",
        "state" as "state",
        "blocked" as "is_blocked",
        "cash_balance" as "cash_balance",
        "control_device_id" as "control_device_id",
        "asset_accountcenter" as "asset_account_center",
        "asset_accountid" as "asset_account_id",
        "reconciliation_accountcenter" as "reconciliation_account_center",
        "reconciliation_accountid" as "reconciliation_account_id",
        "rounding_accountcenter" as "rounding_account_center",
        "rounding_accountid" as "rounding_account_id",
        "error_accountcenter" as "error_account_center",
        "error_accountid" as "error_account_id",
        "payout_accountcenter" as "pay_out_account_center",
        "payout_accountid" as "pay_out_account_id",
        "cc_asset_accountcenter" as "cc_asset_account_center",
        "cc_asset_accountid" as "cc_asset_account_id",
        "default_amount_to_leave" as "default_amount_to_leave",
        "cc_payment_method" as "cc_payment_method",
        "creditcardaccountid" as "credit_card_account_id",
        "creditcardaccountpw" as "credit_card_account_pw",
        "inventory" as "inventory_id",
        "cc_external_require_trans_no" as "is_cc_external_require_trans_no",
        "automatic_closing_days" as "automatic_closing_days",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'cash_register') }}
)

select * from cash_register
