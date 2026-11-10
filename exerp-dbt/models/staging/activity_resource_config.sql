{{ config(bind=false) }}

with activity_resource_config as (

    select
        "id" as "id",
        "activity_id" as "activity_id",
        "name" as "name",
        "booking_resource_group_id" as "booking_resource_group_id",
        "parent_activity_key" as "parent_activity_key",
        "resource_group_selection" as "resource_group_selection",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'activity_resource_config') }}
)

select * from activity_resource_config
