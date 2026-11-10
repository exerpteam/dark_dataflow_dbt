{{ config(bind=false) }}

with payment_agreement as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "subid",
        "state" as "state",
        "active" as "is_active",
        "ref" as "ref",
        "clearinghouse" as "clearing_house",
        "creditor_id" as "creditor_id",
        "bank_regno" as "bank_regno",
        "bank_branch_no" as "bank_branch_no",
        "bank_name" as "bank_name",
        "bank_control_digits" as "bank_control_digits",
        "bank_accno" as "bank_accno",
        "extra_info" as "extra_info",
        "request_serial" as "request_serial",
        "requests_sent" as "requests_sent",
        "clearinghouse_ref" as "clearinghouse_ref",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', '_center_tz."_time_zone"') }} as "creation_at",
        "notify_payment" as "is_notify_payment",
        "maximum_deduction_amount" as "maximum_deduction_amount",
        "standard_deduction_amount" as "standard_deduction_amount",
        "payment_cycle_config_id" as "payment_cycle_config_id",
        "individual_deduction_day" as "individual_deduction_day",
        "expiration_date" as "expiration_date",
        "expiration_notified" as "is_expiration_notified",
        "prev_center" as "prev_center",
        "prev_id" as "prev_id",
        "prev_subid" as "prev_subid",
        "current_center" as "current_center",
        "current_id" as "current_id",
        "current_subid" as "current_subid",
        "ended_reason_code" as "ended_reason_code",
        "ended_reason_text" as "ended_reason_text",
        "ended_date" as "ended_date",
        "ended_clearing_in" as "ended_clearing_in",
        "valid_agreement_change" as "is_valid_agreement_change",
        "deduction_day_changed" as "deduction_day_changed_date",
        "pr_approval_enabled" as "is_pr_approval_enabled",
        "pr_auto_approval_enabled" as "is_pr_auto_approval_enabled",
        "pr_auto_approval_lower_pct" as "pr_auto_approval_lower_pct",
        "pr_auto_approval_upper_pct" as "pr_auto_approval_upper_pct",
        "ignore_missing_agreement" as "is_ignore_missing_agreement",
        "account_type" as "account_type",
        "example_reference" as "example_reference",
        "clearinghouse_init_ref" as "clearinghouse_init_ref",
        "agreement_completion_method" as "agreement_completion_method",
        "bank_reg_accno_search_hash" as "bank_reg_accno_search_hash",
        "bank_accno_search_hash" as "bank_accno_search_hash",
        "use_electronic_invoicing" as "is_use_electronic_invoicing",
        "credit_card_type" as "credit_card_type",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "enable_card_on_file" as "is_enable_card_on_file",
        "name" as "name",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'payment_agreement') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from payment_agreement
