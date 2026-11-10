{{ config(bind=false) }}

with kpi_data as (

    select
        "field" as "field",
        "center" as "center",
        "for_date" as "for_date",
        "value" as "value",
        {{ exerp_epoch_milliseconds_to_timestamp('"timestamp"', '_center_tz."_time_zone"') }} as "timestamp",
        "kind" as "kind",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'kpi_data') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from kpi_data
