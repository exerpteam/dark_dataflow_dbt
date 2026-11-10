{{ config(bind=false) }}

with push_message_target as (

    select
        "id" as "id",
        "name" as "name",
        "url" as "url",
        "username" as "user_name",
        "target_type" as "target_type",
        "use_security_header" as "is_use_security_header",
        "auth_url" as "auth_url",
        "auth_type" as "auth_type",
        "properties_config_type" as "properties_config_type",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'push_message_target') }}
)

select * from push_message_target
