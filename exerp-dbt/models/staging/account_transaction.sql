{{ config(bind=false) }}

with account_transaction as (

    select
        "subid" as "sub_id",
        "trans_type" as "trans_type",
        CASE "trans_type"
            WHEN 1 THEN 'GENERAL LEDGER'
            WHEN 2 THEN 'ACCOUNT RECEIVABLES'
            WHEN 3 THEN 'ACCOUNT PAYABLES'
            WHEN 4 THEN 'INVOICE LINE'
            WHEN 5 THEN 'CREDIT NOTE LINE'
            WHEN 6 THEN 'BILL LINE'
        END as "trans_type_text",
        {{ exerp_epoch_milliseconds_to_timestamp('"trans_time"', '_center_tz."_time_zone"') }} as "trans_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "amount" as "amount",
        "debit_accountcenter" as "debit_account_center",
        "debit_accountid" as "debit_account_id",
        "credit_accountcenter" as "credit_account_center",
        "credit_accountid" as "credit_account_id",
        "main_transcenter" as "main_trans_center",
        "main_transid" as "main_trans_id",
        "main_transsubid" as "main_trans_sub_id",
        "origin_transcenter" as "origin_trans_center",
        "origin_transid" as "origin_trans_id",
        "origin_transsubid" as "origin_trans_sub_id",
        "text" as "text",
        "transferred" as "is_transferred",
        "export_file" as "export_file",
        "aggregated_transaction_center" as "aggregated_transaction_center",
        "aggregated_transaction_id" as "aggregated_transaction_id",
        "vat_type_center" as "vat_type_center",
        "vat_type_id" as "vat_type_id",
        "info_type" as "info_type",
        CASE "info_type"
            WHEN 1 THEN 'LEGACY'
            WHEN 2 THEN 'DATACONVERSION'
            WHEN 3 THEN 'EFT-FILE'
            WHEN 4 THEN 'DEBT COLLECTION-FILE'
            WHEN 5 THEN 'AR'
            WHEN 6 THEN 'CASHREGISTER'
            WHEN 7 THEN 'OTHERGL'
            WHEN 8 THEN 'API'
            WHEN 9 THEN 'CREDITCARD'
            WHEN 10 THEN 'VOUCHERREGISTRATION'
            WHEN 11 THEN 'ACCOUNTRECEIVABLEOWNER'
            WHEN 12 THEN 'CASHREGISTERMANUAL'
            WHEN 13 THEN 'INVENTORY'
            WHEN 14 THEN 'GIFTCARD'
            WHEN 15 THEN 'DELIVERY'
            WHEN 16 THEN 'OWNERMANUALPAYMENTOFREQUEST'
            WHEN 17 THEN 'UNPLACEDPAYMENT'
            WHEN 18 THEN 'CONTROLDEVICEID'
            WHEN 19 THEN 'REVOKEPAYMENTAGREEMENTREFERENCE'
            WHEN 20 THEN 'CASHREGISTERBANKIDENTIFIER'
            WHEN 21 THEN 'ARTRANSIMPORTFILE'
            WHEN 22 THEN 'REVERTARTRANSIMPORTFILE'
            WHEN 23 THEN 'PAYMENTOFREQUESTBYAPIUSER'
            WHEN 24 THEN 'MOBILE_API'
            WHEN 25 THEN 'EFT-FILE-REFUND'
            WHEN 26 THEN 'PAYMENTOFREQUESTBYMAPIUSER'
            WHEN 27 THEN 'AUTORENEWAL'
            WHEN 28 THEN 'DEBTPAYMENTBYINSTALLMENT'
            WHEN 29 THEN 'STOPINSTALLMENTPLAN'
            WHEN 30 THEN 'INSTALLMENTPLAN'
        END as "info_type_text",
        "info" as "info",
        "debit_transaction_center" as "debit_transaction_center",
        "debit_transaction_id" as "debit_transaction_id",
        "debit_transaction_subid" as "debit_transaction_sub_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'account_transaction') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."main_transcenter"
)

select * from account_transaction
