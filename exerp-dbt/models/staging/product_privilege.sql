{{ config(bind=false) }}

with product_privilege as (

    select
        "id" as "id",
        "privilege_set" as "privilege_set",
        "valid_for" as "valid_for",
        {{ exerp_epoch_milliseconds_to_timestamp('"valid_from"', '_center_tz."_time_zone"') }} as "valid_from",
        {{ exerp_epoch_milliseconds_to_timestamp('"valid_to"', '_center_tz."_time_zone"') }} as "valid_to",
        "price_modification_name" as "price_modification_name",
        "price_modification_amount" as "price_modification_amount",
        "price_modification_rounding" as "price_modification_rounding",
        "ref_type" as "ref_type",
        "ref_globalid" as "ref_global_id",
        "ref_center" as "ref_center",
        "ref_id" as "ref_id",
        "disable_min_price" as "is_disable_min_price",
        "purchase_right" as "is_purchase_right",
        "skip_pro_rata_price_adjustment" as "is_skip_pro_rata_price_adjustment",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'product_privilege') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."ref_center"
)

select * from product_privilege
