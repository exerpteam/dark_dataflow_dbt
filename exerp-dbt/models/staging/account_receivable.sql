{{ config(bind=false) }}

with account_receivable as (

    select
        "center" as "center",
        "id" as "id",
        "ar_type" as "ar_type",
        CASE "ar_type"
            WHEN 1 THEN 'CASH'
            WHEN 4 THEN 'PAYMENT'
            WHEN 5 THEN 'DEBT'
            WHEN 6 THEN 'INSTALLMENT'
        END as "ar_type_text",
        "employeecenter" as "employee_center",
        "employeeid" as "employee_id",
        "customercenter" as "person_center",
        "customerid" as "person_id",
        "debit_max" as "debit_max",
        "asset_accountcenter" as "asset_account_center",
        "asset_accountid" as "asset_account_id",
        "external_id" as "external_id",
        "balance" as "balance",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_entry_time"', '_center_tz."_time_zone"') }} as "last_entry_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_trans_time"', '_center_tz."_time_zone"') }} as "last_trans_at",
        "state" as "state",
        {{ exerp_epoch_milliseconds_to_timestamp('"collected_until"', '_center_tz."_time_zone"') }} as "collected_until",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'account_receivable') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from account_receivable
