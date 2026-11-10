{{ config(bind=false) }}

with recurring_participation as (

    select
        "id" as "id",
        "booking_program_id" as "booking_program_id",
        "participant_center" as "participant_center",
        "participant_id" as "participant_id",
        "state" as "state",
        "subscription_id" as "subscription_id",
        "subscription_center" as "subscription_center",
        {{ exerp_epoch_milliseconds_to_timestamp('"start_time"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"end_time"', '_center_tz."_time_zone"') }} as "ended_at",
        "installment_plan_id" as "installment_plan_id",
        "owner_center" as "owner_center",
        "owner_id" as "owner_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'recurring_participation') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."participant_center"
)

select * from recurring_participation
