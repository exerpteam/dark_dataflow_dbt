{{ config(bind=false) }}

with country as (

    select
        "id" as "id",
        "name" as "name",
        "area" as "area",
        "defaultlanguage" as "default_language",
        "defaulttimezone" as "default_timezone",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', 'UTC') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'country') }}
)

select * from country
