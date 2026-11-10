{{ config(bind=false) }}

with shopping_basket as (

    select
        "id" as "id",
        "status" as "status",
        "origin" as "origin",
        "center" as "center",
        "client_center" as "client_center",
        "client_id" as "client_id",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"created"', '_center_tz."_time_zone"') }} as "created",
        {{ exerp_epoch_milliseconds_to_timestamp('"modified"', '_center_tz."_time_zone"') }} as "modified",
        "version" as "version",
        "external_id" as "external_id",
        "configurable_payment_method" as "configurable_payment_method",
        "cash_register_id" as "cash_register_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'shopping_basket') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from shopping_basket
