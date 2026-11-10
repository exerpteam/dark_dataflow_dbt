{{ config(bind=false) }}

with inventory_tran as (

    select
        "id" as "id",
        "inventory" as "inventory",
        "type" as "type",
        "coment" as "comment",
        "product_center" as "product_center",
        "product_id" as "product_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"book_time"', '_center_tz."_time_zone"') }} as "booked_at",
        "had_report_role" as "is_had_report_role",
        "quantity" as "quantity",
        "unit_value" as "unit_value",
        "remaining" as "remaining",
        "ref_type" as "ref_type",
        "ref_center" as "ref_center",
        "ref_id" as "ref_id",
        "ref_subid" as "ref_subid",
        "source_id" as "source_id",
        "first_source_id" as "first_source_id",
        "last_write_off_id" as "last_write_off_id",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "balance_quantity" as "balance_quantity",
        "balance_value" as "balance_value",
        "account_trans_center" as "account_trans_center",
        "account_trans_id" as "account_trans_id",
        "account_trans_subid" as "account_trans_subid",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'inventory_tran') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."product_center"
)

select * from inventory_tran
