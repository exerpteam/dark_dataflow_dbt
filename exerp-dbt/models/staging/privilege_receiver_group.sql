{{ config(bind=false) }}

with privilege_receiver_group as (

    select
        "id" as "id",
        "rgtype" as "type",
        CASE "rgtype"
            WHEN 'CAMPAIGN' THEN 'PRIVILEGE CAMPAIGN'
            WHEN 'UNLIMITED' THEN 'TARGET GROUP'
        END as "type_text",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "blocked" as "is_blocked",
        "name" as "name",
        "plugin_name" as "plugin_name",
        {{ exerp_epoch_milliseconds_to_timestamp('"starttime"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"endtime"', '_center_tz."_time_zone"') }} as "ended_at",
        "web_text" as "web_text",
        "available_scopes" as "available_scopes",
        "plugin_codes_name" as "plugin_codes_name",
        "free_text" as "free_text",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', '_center_tz."_time_zone"') }} as "creation_at",
        "creator_id" as "creator_id",
        "creator_center" as "creator_center",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "last_editor_id" as "last_editor_id",
        "last_editor_center" as "last_editor_center",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'privilege_receiver_group') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."creator_center"
)

select * from privilege_receiver_group
