{{ config(bind=false) }}

with gift_card_usage as (

    select
        "id" as "id",
        {{ exerp_epoch_milliseconds_to_timestamp('"time"', '_center_tz."_time_zone"') }} as "time",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "amount" as "amount",
        "ref" as "ref",
        "type" as "type",
        "transaction_center" as "transaction_center",
        "transaction_id" as "transaction_id",
        "transaction_subid" as "transaction_subid",
        "gift_card_center" as "gift_card_center",
        "gift_card_id" as "gift_card_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'gift_card_usage') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."transaction_center"
)

select * from gift_card_usage
