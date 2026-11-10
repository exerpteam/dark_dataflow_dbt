{{ config(bind=false) }}

with access_code as (

    select
        "id" as "id",
        "access_code" as "access_code",
        "usage_point_center" as "usage_point_center",
        "usage_point_id" as "usage_point_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"access_time"', '_center_tz."_time_zone"') }} as "accessed_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'access_code') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."usage_point_center"
)

select * from access_code
