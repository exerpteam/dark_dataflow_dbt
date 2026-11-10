{{ config(bind=false) }}

with account_receivable_transaction as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "sub_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"trans_time"', '_center_tz."_time_zone"') }} as "trans_at",
        "employeecenter" as "employee_center",
        "employeeid" as "employee_id",
        "amount" as "amount",
        "due_date" as "due_date",
        "info" as "info",
        "text" as "text",
        "transferred" as "is_transferred",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "payreq_spec_center" as "payreq_spec_center",
        "payreq_spec_id" as "payreq_spec_id",
        "payreq_spec_subid" as "payreq_spec_sub_id",
        "collected" as "collected",
        "ref_type" as "ref_type",
        CASE "ref_type"
            WHEN 'ACCOUNT_TRANS' THEN 'ACCOUNT_TRANS'
            WHEN 'CREDIT_NOTE' THEN 'SALE_LOG'
            WHEN 'INVOICE' THEN 'SALE_LOG'
            WHEN 'OVERDUE_AMOUNT' THEN 'OVERDUE AMOUNT'
        END as "ref_type_text",
        "ref_center" as "ref_center",
        "ref_id" as "ref_id",
        "ref_subid" as "ref_sub_id",
        "status" as "status",
        "match_info" as "match_info",
        "unsettled_amount" as "unsettled_amount",
        "collected_amount" as "collected_amount",
        "installment_plan_id" as "installment_plan_id",
        "collect_agreement_center" as "collect_agreement_center",
        "collect_agreement_id" as "collect_agreement_id",
        "collect_agreement_subid" as "collect_agreement_sub_id",
        "payment_request_type" as "payment_request_type",
        "installment_plan_subindex" as "installment_plan_subindex",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "collection_mode" as "collection_mode",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'account_receivable_transaction') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from account_receivable_transaction
