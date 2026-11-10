{{ config(bind=false) }}

with center_extended_attribute as (

    select
        "id" as "id",
        "center_id" as "center_id",
        "name" as "name",
        "txt_value" as "txt_value",
        "mime_type" as "mime_type",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_edit_time"', '_center_tz."_time_zone"') }} as "last_edited_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'center_extended_attribute') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center_id"
)

select * from center_extended_attribute
