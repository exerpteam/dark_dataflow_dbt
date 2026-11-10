{{ config(bind=false) }}

with report_usage as (

    select
        "id" as "id",
        "report_key" as "report_key",
        {{ exerp_epoch_milliseconds_to_timestamp('"time"', 'UTC') }} as "time",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "rows_returned" as "rows_returned",
        "time_used" as "time_used",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'report_usage') }}
)

select * from report_usage
