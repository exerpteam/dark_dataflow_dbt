{{ config(bind=false) }}

with aggregated_transaction as (

    select
        "center" as "center",
        "id" as "id",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "book_date" as "book_date",
        "amount" as "amount",
        "debit_account_external_id" as "debit_account_external_id",
        "credit_account_external_id" as "credit_account_external_id",
        "vat_amount" as "vat_amount",
        "debit_vat_account_external_id" as "debit_vat_account_external_id",
        "credit_vat_account_external_id" as "credit_vat_account_external_id",
        "vat_rate" as "vat_rate",
        "vat_external_id" as "vat_external_id",
        "text" as "text",
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
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'aggregated_transaction') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from aggregated_transaction
