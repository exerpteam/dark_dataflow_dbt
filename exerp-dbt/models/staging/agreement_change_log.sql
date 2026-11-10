{{ config(bind=false) }}

with agreement_change_log as (

    select
        "id" as "id",
        "log_date" as "log_date",
        "agreement_center" as "agreement_center",
        "agreement_id" as "agreement_id",
        "agreement_subid" as "agreement_sub_id",
        "state" as "state",
        CASE "state"
            WHEN 1 THEN 'CREATED'
            WHEN 2 THEN 'SENT'
            WHEN 3 THEN 'FAILED'
            WHEN 4 THEN 'OK'
            WHEN 5 THEN 'ENDED BY DEBITORS BANK'
            WHEN 6 THEN 'ENDED BY THE CLEARING HOUSE'
            WHEN 7 THEN 'ENDED BY DEBITOR'
            WHEN 8 THEN 'SHALL BE CANCELLED'
            WHEN 9 THEN 'END REQUEST SENT'
            WHEN 10 THEN 'AGREEMENT ENDED BY CREDITOR'
            WHEN 11 THEN 'NO AGREEMENT WITH DEBITOR'
            WHEN 12 THEN 'DEPRICATED'
            WHEN 13 THEN 'NOT NEEDED'
            WHEN 14 THEN 'INCOMPLETE'
            WHEN 15 THEN 'TRANSFERRED'
            WHEN 16 THEN 'AGREEMENT RECREATED'
            WHEN 17 THEN 'SIGNATURE MISSING'
        END as "state_text",
        "text" as "text",
        "code" as "code",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "clearing_in" as "clearing_in",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'agreement_change_log') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."agreement_center"
)

select * from agreement_change_log
