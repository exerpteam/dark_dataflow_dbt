{{ config(bind=false) }}

with offline_massive_attend as (

    select
        "id" as "id",
        "person_center" as "person_center",
        "person_id" as "person_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"timestamp"', '_center_tz."_time_zone"') }} as "timestamp",
        "resource_center" as "resource_center",
        "resource_id" as "resource_id",
        "identity_method" as "identity_method",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'offline_massive_attend') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."resource_center"
)

select * from offline_massive_attend
