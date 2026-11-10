{{ config(bind=false) }}

with person_extended_attribute as (

    select
        "personcenter" as "person_center",
        "personid" as "person_id",
        "name" as "name",
        "txtvalue" as "txt_value",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_edit_time"', '_center_tz."_time_zone"') }} as "last_edited_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'person_extended_attribute') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."personcenter"
)

select * from person_extended_attribute
