{{ config(bind=false) }}

with payment_request_specification as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "subid",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "requested_amount" as "requested_amount",
        "collection_fee" as "collection_fee",
        "rejection_fee" as "rejection_fee",
        "cancelled" as "is_cancelled",
        "ref" as "ref",
        "text" as "text",
        "original_due_date" as "original_due_date",
        "total_invoice_amount" as "total_invoice_amount",
        {{ exerp_epoch_milliseconds_to_date('"from_date"') }} as "from_date",
        {{ exerp_epoch_milliseconds_to_date('"to_date"') }} as "to_date",
        "balance_from" as "balance_from",
        "balance_to" as "balance_to",
        "included_overdue_amount" as "included_overdue_amount",
        "open_amount" as "open_amount",
        "paid_state" as "paid_state",
        {{ exerp_epoch_milliseconds_to_timestamp('"paid_state_last_entry_time"', '_center_tz."_time_zone"') }} as "paid_state_last_entry_at",
        "inv_diff" as "inv_diff",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        {{ exerp_epoch_milliseconds_to_date('"issued_date"') }} as "issued_date",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'payment_request_specification') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from payment_request_specification
