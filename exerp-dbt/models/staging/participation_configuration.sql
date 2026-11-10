{{ config(bind=false) }}

with participation_configuration as (

    select
        "id" as "id",
        "activity_id" as "activity_id",
        "name" as "name",
        "excluzive" as "is_exclusive",
        "ordinal" as "ordinal",
        "min_participants_at_creation" as "min_participants_at_creation",
        "max_participants_at_creation" as "max_participants_at_creation",
        "minimum_showups" as "minimum_showups",
        "max_participants_absolute" as "max_participants_absolute",
        "max_participants_percentage" as "max_participants_percentage",
        "access_group_id" as "access_group_id",
        "owner_participation" as "is_owner_participation",
        "participate_in_all_recurring" as "is_participate_in_all_recurring",
        "privilege_at_showup_client" as "is_privilege_at_showup_client",
        "privilege_at_showup_kiosk" as "is_privilege_at_showup_kiosk",
        "privilege_at_showup_web" as "is_privilege_at_showup_web",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'participation_configuration') }}
)

select * from participation_configuration
