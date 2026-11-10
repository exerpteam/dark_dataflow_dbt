{{ config(bind=false) }}

with customer_invoice as (

    select
        "id" as "id",
        "reference_center" as "reference_center",
        "reference_id" as "reference_id",
        "reference_sub_id" as "reference_sub_id",
        "reference_type" as "reference_type",
        "invoice_reference" as "invoice_reference",
        {{ exerp_epoch_milliseconds_to_date('"issued_date"') }} as "issued_date",
        "created_by_emp_center" as "created_by_emp_center",
        "created_by_emp_id" as "created_by_emp_id",
        "person_id" as "person_id",
        "person_center" as "person_center",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'customer_invoice') }}
)

select * from customer_invoice
