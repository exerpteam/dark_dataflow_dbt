{{ config(bind=false) }}

with documentation_requirement as (

    select
        "id" as "id",
        "documentation_setting_key" as "documentation_setting_key",
        "source_key" as "source_key",
        "source_center" as "source_center",
        "source_id" as "source_id",
        "source_sub_id" as "source_sub_id",
        "source_owner_center" as "source_owner_center",
        "source_owner_id" as "source_owner_id",
        "state" as "state",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', '_center_tz."_time_zone"') }} as "creation_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"completion_time"', '_center_tz."_time_zone"') }} as "completion_at",
        "documentation_setting_type" as "documentation_setting_type",
        "is_needed" as "is_needed",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'documentation_requirement') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."source_center"
)

select * from documentation_requirement
