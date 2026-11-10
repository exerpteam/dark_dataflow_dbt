{{ config(bind=false) }}

with payment_session as (

    select
        "id" as "id",
        "state" as "state",
        "center" as "center",
        {{ exerp_epoch_milliseconds_to_timestamp('"created"', '_center_tz."_time_zone"') }} as "created",
        {{ exerp_epoch_milliseconds_to_timestamp('"modified"', '_center_tz."_time_zone"') }} as "modified",
        "shopping_basket_id" as "shopping_basket_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'payment_session') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from payment_session
