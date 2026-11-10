{{ config(bind=false) }}

with invoice_lines_mt as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "subid",
        "productcenter" as "product_center",
        "productid" as "product_id",
        "person_center" as "person_center",
        "person_id" as "person_id",
        "account_trans_center" as "account_trans_center",
        "account_trans_id" as "account_trans_id",
        "account_trans_subid" as "account_trans_subid",
        "quantity" as "quantity",
        "text" as "text",
        "product_cost" as "product_cost",
        "product_normal_price" as "product_normal_price",
        "total_amount" as "total_amount",
        "sales_type" as "sales_type",
        "remove_from_inventory" as "is_remove_from_inventory",
        "reason" as "reason",
        CASE "reason"
            WHEN 0 THEN 'UNKNOWN'
            WHEN 1 THEN 'DEFAULT'
            WHEN 2 THEN 'FREEZE'
            WHEN 3 THEN 'PERSONTYPECHANGE'
            WHEN 4 THEN 'UPGRADE'
            WHEN 5 THEN 'DOWNGRADE'
            WHEN 6 THEN 'TRANSFER'
            WHEN 7 THEN 'REGRET'
            WHEN 8 THEN 'STOPMEMBERSHIP'
            WHEN 9 THEN 'AUTORENEW'
            WHEN 10 THEN 'SAVEDFREEDAYS'
            WHEN 11 THEN 'PAYOUTMEMBERSHIP'
            WHEN 12 THEN 'CHANGEMEMBERSHIP'
            WHEN 13 THEN 'DCSTOPMEMBERSHIP'
            WHEN 14 THEN 'WRONGSALE'
            WHEN 15 THEN 'PRODUCTRETURNED'
            WHEN 16 THEN 'FREECREDITLINE'
            WHEN 17 THEN 'MANUALPRICEADJUST'
            WHEN 18 THEN 'SANCTION'
            WHEN 19 THEN 'CHARGEDMESSAGEUNDELIVERABLE'
            WHEN 20 THEN 'DCSENDAGENCY'
            WHEN 21 THEN 'MANUALRENEW'
            WHEN 22 THEN 'PRIVILEGEUSAGECANCELLED'
            WHEN 23 THEN 'DOCUMENTATION'
            WHEN 24 THEN 'WRITEOFF'
            WHEN 25 THEN 'PAYMENTCOLLECTIONFEEREVERSED'
            WHEN 26 THEN 'APPLYSTEP'
            WHEN 27 THEN 'SALEONACCOUNT'
            WHEN 28 THEN 'REMINDERFEE'
            WHEN 29 THEN 'MEMBERCARDRETURNED'
            WHEN 30 THEN 'MEMBERSHIPSALE'
            WHEN 31 THEN 'SHOPSALE'
            WHEN 32 THEN 'CHANGESTARTDATE'
            WHEN 33 THEN 'BUYOUTCLIPCARD'
            WHEN 34 THEN 'FAMILYPERSONTYPECHANGE'
            WHEN 35 THEN 'FAMILYSUBSCRIPTIONCHANGE'
            WHEN 36 THEN 'REASSIGN'
            WHEN 37 THEN 'REGRETCLIPCARD'
        END as "reason_text",
        "sponsor_invoice_subid" as "sponsor_invoice_subid",
        "installment_plan_id" as "installment_plan_id",
        "net_amount" as "net_amount",
        "rebooking_acc_trans_center" as "rebooking_acc_trans_center",
        "rebooking_acc_trans_id" as "rebooking_acc_trans_id",
        "rebooking_acc_trans_subid" as "rebooking_acc_trans_subid",
        "rebooking_to_center" as "rebooking_to_center",
        "sales_commission" as "sales_commission",
        "sales_units" as "sales_units",
        "period_commission" as "period_commission",
        "flat_rate_commission" as "flat_rate_commission",
        "external_id" as "external_id",
        "sub_quantity" as "sub_quantity",
        "commissionable" as "is_commissionable",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'invoice_lines_mt') }}
)

select * from invoice_lines_mt
