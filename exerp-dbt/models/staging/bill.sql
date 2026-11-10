{{ config(bind=false) }}

with bill as (

    select
        "center" as "center",
        "id" as "id",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "bill_no" as "bill_no",
        {{ exerp_epoch_milliseconds_to_timestamp('"trans_time"', '_center_tz."_time_zone"') }} as "trans_at",
        "text2" as "text2",
        "total_amount" as "total_amount",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'bill') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from bill
