{{ config(bind=false) }}

with privilege_set_include as (

    select
        "id" as "id",
        "parent_id" as "parent_id",
        "child_id" as "child_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"valid_from"', 'UTC') }} as "valid_from",
        {{ exerp_epoch_milliseconds_to_timestamp('"valid_to"', 'UTC') }} as "valid_to",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'privilege_set_include') }}
)

select * from privilege_set_include
