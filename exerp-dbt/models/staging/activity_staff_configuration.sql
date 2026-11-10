{{ config(bind=false) }}

with activity_staff_configuration as (

    select
        "id" as "id",
        "activity_id" as "activity_id",
        "name" as "name",
        "excluzive" as "is_excluzive",
        "staff_group_id" as "staff_group_id",
        "minimum_staffs" as "minimum_staffs",
        "maximum_staffs" as "maximum_staffs",
        "staff_anonymity" as "staff_anonymity",
        "parent_activity_id" as "parent_activity_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'activity_staff_configuration') }}
)

select * from activity_staff_configuration
