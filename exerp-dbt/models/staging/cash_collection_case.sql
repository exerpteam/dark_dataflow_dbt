{{ config(bind=false) }}

with cash_collection_case as (

    select
        "center" as "center",
        "id" as "id",
        "personcenter" as "person_center",
        "personid" as "person_id",
        "ar_center" as "ar_center",
        "ar_id" as "ar_id",
        "closed" as "is_closed",
        "successfull" as "is_successfull",
        "hold" as "is_hold",
        "amount" as "amount",
        "cc_agency_amount" as "cc_agency_amount",
        "cc_agency_update_source" as "cc_agency_update_source",
        {{ exerp_epoch_milliseconds_to_timestamp('"cc_agency_update_time"', '_center_tz."_time_zone"') }} as "cc_agency_updated_at",
        "cashcollectionservice" as "cash_collection_service_id",
        "ext_ref" as "ext_ref",
        "startdate" as "start_date",
        "currentstep" as "current_step",
        "currentstep_type" as "current_step_type",
        CASE "currentstep_type"
            WHEN -1 THEN 'NO DEBT STEP CONFIGURED'
            WHEN 0 THEN 'MESSAGE'
            WHEN 1 THEN 'REMINDER'
            WHEN 2 THEN 'BLOCK'
            WHEN 3 THEN 'REQUESTANDSTOP'
            WHEN 4 THEN 'CASHCOLLECTION'
            WHEN 5 THEN 'CLOSE'
            WHEN 6 THEN 'WAIT'
            WHEN 7 THEN 'REQUESTBUYOUTANDSTOP'
            WHEN 8 THEN 'PUSH'
        END as "current_step_type_text",
        "currentstep_date" as "current_step_date",
        "nextstep_date" as "next_step_date",
        "nextstep_type" as "next_step_type",
        CASE "nextstep_type"
            WHEN 0 THEN 'MESSAGE'
            WHEN 1 THEN 'REMINDER'
            WHEN 2 THEN 'BLOCK'
            WHEN 3 THEN 'REQUESTANDSTOP'
            WHEN 4 THEN 'CASHCOLLECTION'
            WHEN 5 THEN 'CLOSE'
            WHEN 6 THEN 'WAIT'
            WHEN 7 THEN 'REQUESTBUYOUTANDSTOP'
            WHEN 8 THEN 'PUSH'
        END as "next_step_type_text",
        "missingpayment" as "is_missing_payment",
        "below_minimum_age" as "is_below_minimum_age",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"start_datetime"', '_center_tz."_time_zone"') }} as "start_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"closed_datetime"', '_center_tz."_time_zone"') }} as "closed_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'cash_collection_case') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from cash_collection_case
