{{ config(bind=false) }}

with secondary_membership as (

    select
        "id" as "id",
        "secondary_member_person_center" as "secondary_member_person_center",
        "secondary_member_person_id" as "secondary_member_person_id",
        "subscription_add_on_id" as "subscription_add_on_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"start_time"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"stop_time"', '_center_tz."_time_zone"') }} as "stopped_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'secondary_membership') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."secondary_member_person_center"
)

select * from secondary_membership
