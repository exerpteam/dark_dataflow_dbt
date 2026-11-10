{{ config(bind=false) }}

with usage_point_source as (

    select
        "center" as "center",
        "id" as "id",
        "usage_point_center" as "usage_point_center",
        "usage_point_id" as "usage_point_id",
        "reader_device_sub_id" as "device_subid",
        "action_center" as "action_center",
        "action_id" as "usage_point_action_center",
        "external_id" as "usage_point_action_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'usage_point_source') }}
)

select * from usage_point_source
