{{ config(bind=false) }}

with gift_card as (

    select
        "center" as "center",
        "id" as "id",
        "state" as "state",
        CASE "state"
            WHEN 0 THEN 'ISSUED'
            WHEN 1 THEN 'CANCELLED'
            WHEN 2 THEN 'EXPIRED'
            WHEN 3 THEN 'USED'
            WHEN 4 THEN 'PARTIAL USED'
        END as "state_text",
        "amount" as "amount",
        "product_center" as "product_center",
        "product_id" as "product_id",
        "invoiceline_center" as "invoiceline_center",
        "invoiceline_id" as "invoiceline_id",
        "invoiceline_subid" as "invoiceline_subid",
        "expirationdate" as "expiration_date",
        {{ exerp_epoch_milliseconds_to_timestamp('"use_time"', '_center_tz."_time_zone"') }} as "used_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"purchase_time"', '_center_tz."_time_zone"') }} as "purchased_at",
        "payer_center" as "payer_center",
        "payer_id" as "payer_id",
        "amount_remaining" as "amount_remaining",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'gift_card') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from gift_card
