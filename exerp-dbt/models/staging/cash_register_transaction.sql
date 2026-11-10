{{ config(bind=false) }}

with cash_register_transaction as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "sub_id",
        "crttype" as "crt_type",
        CASE "crttype"
            WHEN 0 THEN '0'
            WHEN 1 THEN 'CASH'
            WHEN 2 THEN 'CHANGE'
            WHEN 3 THEN 'RETURN ON CREDIT'
            WHEN 4 THEN 'PAYOUT CASH'
            WHEN 5 THEN 'PAID BY CASH AR ACCOUNT'
            WHEN 6 THEN 'DEBIT CARD'
            WHEN 7 THEN 'CREDIT CARD'
            WHEN 8 THEN 'DEBIT OR CREDIT CARD'
            WHEN 9 THEN 'GIFT CARD'
            WHEN 10 THEN 'CASH ADJUSTMENT'
            WHEN 11 THEN 'CASH TRANSFER'
            WHEN 12 THEN 'PAYMENT AR'
            WHEN 13 THEN 'CONFIG PAYMENT METHOD'
            WHEN 14 THEN 'CASH REGISTER PAYOUT'
            WHEN 15 THEN 'CREDIT CARD ADJUSTMENT'
            WHEN 16 THEN 'CLOSING CASH ADJUST'
            WHEN 17 THEN 'VOUCHER'
            WHEN 18 THEN 'PAYOUT CREDIT CARD'
            WHEN 19 THEN 'TRANSFER BETWEEN REGISTERS'
            WHEN 20 THEN 'CLOSING CREDIT CARD ADJ'
            WHEN 21 THEN 'TRANSFER BACK CASH COINS'
            WHEN 22 THEN 'INSTALLMENT PLAN'
            WHEN 100 THEN 'INITIAL CASH'
            WHEN 101 THEN 'MANUAL'
        END as "crt_type_text",
        {{ exerp_epoch_milliseconds_to_timestamp('"transtime"', '_center_tz."_time_zone"') }} as "trans_at",
        "employeecenter" as "employee_center",
        "employeeid" as "employee_id",
        "crcenter" as "cr_center",
        "crid" as "cr_id",
        "crsubid" as "cr_sub_id",
        "gltranscenter" as "gl_trans_center",
        "gltransid" as "gl_trans_id",
        "gltranssubid" as "gl_trans_sub_id",
        "artranscenter" as "ar_trans_center",
        "artransid" as "ar_trans_id",
        "artranssubid" as "ar_trans_sub_id",
        "aptranscenter" as "ap_trans_center",
        "aptransid" as "ap_trans_id",
        "aptranssubid" as "ap_trans_sub_id",
        "billcenter" as "bill_center",
        "billid" as "bill_id",
        "paysessionid" as "pay_session_id",
        "coment" as "comment",
        "amount" as "amount",
        "customercenter" as "customer_center",
        "customerid" as "customer_id",
        "cr_action" as "cr_action",
        "config_payment_method_id" as "config_payment_method_id",
        "marker" as "marker",
        "installment_plan_id" as "installment_plan_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'cash_register_transaction') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from cash_register_transaction
