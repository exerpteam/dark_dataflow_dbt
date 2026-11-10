{{ config(bind=false) }}

with journal_entry as (

    select
        "id" as "id",
        "person_center" as "person_center",
        "person_id" as "person_id",
        "person_subid" as "person_subid",
        "jetype" as "type",
        CASE "jetype"
            WHEN 1 THEN 'SUBSCRIPTION_CONTRACT'
            WHEN 2 THEN 'DOCUMENTATION'
            WHEN 3 THEN 'NOTE'
            WHEN 8 THEN 'STATUS'
            WHEN 11 THEN 'PAYMENT_AGREEMENT_CONTRACT'
            WHEN 12 THEN 'CASHOUT'
            WHEN 13 THEN 'FREEZE_CREATION'
            WHEN 14 THEN 'FREEZE_CANCELLATION'
            WHEN 15 THEN 'FREEZE_CHANGE'
            WHEN 16 THEN 'OTHER_PAYER_START'
            WHEN 17 THEN 'OTHER_PAYER_STOP'
            WHEN 18 THEN 'SUBSCRIPTION_TERMINATION'
            WHEN 19 THEN 'SUBSCRIPTION_TERMINATION_CANCELLATION'
            WHEN 20 THEN 'PAYMENT_NOTE'
            WHEN 21 THEN 'ACCOUNT_PAYMENT_NOTE'
            WHEN 22 THEN 'SAVED_FREE_DAYS_USE'
            WHEN 23 THEN 'FREE_PERIOD_ASSIGNMENT'
            WHEN 24 THEN 'FREE_PERIOD_CANCELLATION'
            WHEN 25 THEN 'CASH_ACCOUNT_CREDIT'
            WHEN 26 THEN 'ADDON_TERMINATION'
            WHEN 27 THEN 'ADDON_TERMINATION_CANCELLATION'
            WHEN 28 THEN 'CHILD_RELATION_CONTRACT'
            WHEN 29 THEN 'DOCTOR_NOTE'
            WHEN 30 THEN 'ADDON_CONTRACT'
            WHEN 31 THEN 'HEALTH_CERTIFICATE'
            WHEN 32 THEN 'CREDITCARD_AGREEMENT_CONTRACT'
            WHEN 33 THEN 'CLIPCARD_BUYOUT'
            WHEN 34 THEN 'CLIPCARD_CONTRACT'
            WHEN 35 THEN 'REASSIGN_SUBSCRIPTION_CONTRACT'
            WHEN 36 THEN 'AGGREGATED_SUBSCRIPTION_CONTRACT'
            WHEN 37 THEN 'FREE_PERIOD_CHANGE'
        END as "type_text",
        "name" as "name",
        "creatorcenter" as "creator_center",
        "creatorid" as "creator_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', '_center_tz."_time_zone"') }} as "creation_at",
        "text" as "text",
        "document_name" as "document_name",
        "signable" as "is_signable",
        "ref_globalid" as "ref_global_id",
        "ref_center" as "ref_center",
        "ref_id" as "ref_id",
        "ref_subid" as "ref_subid",
        "expiration_date" as "expiration_date",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "custom_type" as "custom_type",
        "issue_date" as "issue_date",
        "replaced_by" as "replaced_by",
        "state" as "state",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'journal_entry') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."ref_center"
)

select * from journal_entry
