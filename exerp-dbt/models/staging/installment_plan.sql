{{ config(bind=false) }}

with installment_plan as (

    select
        "id" as "id",
        "ip_config_id" as "ip_config_id",
        "person_center" as "person_center",
        "person_id" as "person_id",
        "amount" as "amount",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', '_center_tz."_time_zone"') }} as "creation_at",
        "installements_count" as "installements_count",
        "end_date" as "end_date",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "version" as "version",
        "collect_agreement_center" as "collect_agreement_center",
        "collect_agreement_id" as "collect_agreement_id",
        "collect_agreement_subid" as "collect_agreement_subid",
        "name" as "name",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "single_booking_date" as "single_booking_date",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'installment_plan') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."person_center"
)

select * from installment_plan
