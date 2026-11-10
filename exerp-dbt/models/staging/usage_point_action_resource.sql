{{ config(bind=false) }}

with usage_point_action_resource as (

    select
        "action_center" as "usage_point_action_center",
        "action_id" as "usage_point_action_id",
        "resource_center" as "booking_resource_center",
        "resource_id" as "booking_resource_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'usage_point_action_resource') }}
)

select * from usage_point_action_resource
