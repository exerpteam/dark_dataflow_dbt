{{ config(bind=false) }}

with account_receivable_transaction_match as (

    select
        "id" as "id",
        "art_paying_center" as "art_paying_center",
        "art_paying_id" as "art_paying_id",
        "art_paying_subid" as "art_paying_sub_id",
        "art_paid_center" as "art_paid_center",
        "art_paid_id" as "art_paid_id",
        "art_paid_subid" as "art_paid_sub_id",
        "amount" as "amount",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancelled_time"', '_center_tz."_time_zone"') }} as "cancelled_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'account_receivable_transaction_match') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."art_paying_center"
)

select * from account_receivable_transaction_match
