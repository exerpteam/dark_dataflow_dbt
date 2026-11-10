{{ config(bind=false) }}

with payment_request as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "subid",
        "state" as "state",
        CASE "state"
            WHEN 1 THEN 'NEW'
            WHEN 2 THEN 'SENT'
            WHEN 3 THEN 'DONE'
            WHEN 4 THEN 'DONE, MANUAL'
            WHEN 5 THEN 'REJECTED, CLEARINGHOUSE'
            WHEN 6 THEN 'REJECTED, BANK'
            WHEN 7 THEN 'REJECTED, DEBTOR'
            WHEN 8 THEN 'CANCELLED'
            WHEN 10 THEN 'REVERSED, NEW'
            WHEN 11 THEN 'REVERSED , SENT'
            WHEN 12 THEN 'FAILED, NOT CREDITOR'
            WHEN 13 THEN 'REVERSED, REJECTED'
            WHEN 14 THEN 'REVERSED, CONFIRMED'
            WHEN 17 THEN 'FAILED, PAYMENT REVOKED'
            WHEN 18 THEN 'DONE PARTIAL'
            WHEN 19 THEN 'FAILED, UNSUPPORTED'
            WHEN 20 THEN 'REQUIRE APPROVAL'
            WHEN 21 THEN 'FAIL, DEBT CASE EXISTS'
            WHEN 22 THEN 'FAILED, TIMED OUT'
        END as "state_text",
        "request_type" as "request_type",
        CASE "request_type"
            WHEN 1 THEN 'PAYMENT'
            WHEN 2 THEN 'DEBT COLLECTION'
            WHEN 3 THEN 'REVERSAL'
            WHEN 4 THEN 'REMINDER'
            WHEN 5 THEN 'REFUND'
            WHEN 6 THEN 'REPRESENTATION'
            WHEN 7 THEN 'LEGACY'
            WHEN 8 THEN 'ZERO'
            WHEN 9 THEN 'SERVICE CHARGE'
        END as "request_type_text",
        "ref" as "ref",
        "full_reference" as "full_reference",
        "req_amount" as "req_amount",
        "req_date" as "req_date",
        "req_delivery" as "req_delivery",
        "inv_coll_center" as "inv_coll_center",
        "inv_coll_id" as "inv_coll_id",
        "inv_coll_subid" as "inv_coll_subid",
        "reject_fee_invline_center" as "reject_fee_invline_center",
        "reject_fee_invline_id" as "reject_fee_invline_id",
        "reject_fee_invline_subid" as "reject_fee_invline_subid",
        "xfr_amount" as "xfr_amount",
        "xfr_date" as "xfr_date",
        "xfr_delivery" as "xfr_delivery",
        "xfr_info" as "xfr_info",
        "agr_subid" as "agr_subid",
        "coll_fee_invline_center" as "coll_fee_invline_center",
        "coll_fee_invline_id" as "coll_fee_invline_id",
        "coll_fee_invline_subid" as "coll_fee_invline_subid",
        "due_date" as "due_date",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "rejected_reason_code" as "rejected_reason_code",
        "uuid" as "uuid",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "notification_type" as "notification_type",
        {{ exerp_epoch_milliseconds_to_timestamp('"invoice_created_at"', '_center_tz."_time_zone"') }} as "invoice_created_at",
        "invoice_created_by_emp_center" as "invoice_created_by_emp_center",
        "invoice_created_by_emp_id" as "invoice_created_by_emp_id",
        "handler_type" as "handler_type",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "clearinghouse_payment_ref" as "clearinghouse_payment_ref",
        {{ exerp_epoch_milliseconds_to_timestamp('"rejection_fee_delay_time"', '_center_tz."_time_zone"') }} as "rejection_fee_delay_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'payment_request') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from payment_request
