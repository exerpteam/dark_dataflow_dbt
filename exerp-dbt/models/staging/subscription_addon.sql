{{ config(bind=false) }}

with subscription_addon as (

    select
        "id" as "id",
        "subscription_center" as "subscription_center",
        "subscription_id" as "subscription_id",
        "addon_product_id" as "addon_product_id",
        "center_id" as "center_id",
        "start_date" as "start_date",
        "end_date" as "end_date",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', '_center_tz."_time_zone"') }} as "creation_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"ending_time"', '_center_tz."_time_zone"') }} as "ending_at",
        "employee_creator_center" as "employee_creator_center",
        "employee_creator_id" as "employee_creator_id",
        "cancelled" as "is_cancelled",
        "quantity" as "quantity",
        "use_individual_price" as "is_use_individual_price",
        "individual_price_per_unit" as "individual_price_per_unit",
        "binding_end_date" as "binding_end_date",
        "sales_center_id" as "sales_center_id",
        "sales_interface" as "sales_interface",
        CASE "sales_interface"
            WHEN 0 THEN 'OTHER'
            WHEN 1 THEN 'CLIENT'
            WHEN 2 THEN 'WEB'
            WHEN 3 THEN 'KIOSK'
            WHEN 4 THEN 'SCRIPT'
            WHEN 5 THEN 'API'
            WHEN 6 THEN 'MOBILE_API'
            WHEN 7 THEN 'MOBILE_API_STAFF'
        END as "sales_interface_text",
        "period_commission" as "period_commission",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscription_addon') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."subscription_center"
)

select * from subscription_addon
