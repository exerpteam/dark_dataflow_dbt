{{ config(bind=false) }}

with privilege_usage as (

    select
        "id" as "id",
        "state" as "state",
        "misuse_state" as "misuse_state",
        "grant_id" as "grant_id",
        "privilege_id" as "privilege_id",
        "privilege_type" as "privilege_type",
        "source_globalid" as "source_global_id",
        "source_center" as "source_center",
        "source_id" as "source_id",
        "source_subid" as "source_subid",
        "target_service" as "target_service",
        "target_globalid" as "target_global_id",
        "target_center" as "target_center",
        "target_id" as "target_id",
        "target_subid" as "target_subid",
        {{ exerp_epoch_milliseconds_to_timestamp('"target_start_time"', '_center_tz."_time_zone"') }} as "target_started_at",
        "deduction_quantity" as "deduction_quantity",
        "deduction_key" as "deduction_key",
        "deduction_usage" as "deduction_usage",
        "deduction_time" as "deduction_time",
        {{ exerp_epoch_milliseconds_to_timestamp('"plan_time"', '_center_tz."_time_zone"') }} as "planned_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"use_time"', '_center_tz."_time_zone"') }} as "used_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancel_time"', '_center_tz."_time_zone"') }} as "cancelled_at",
        "punishment_key" as "punishment_key",
        "campaign_code_id" as "campaign_code_id",
        "count" as "count",
        "person_center" as "person_center",
        "person_id" as "person_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'privilege_usage') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."source_center"
)

select * from privilege_usage
