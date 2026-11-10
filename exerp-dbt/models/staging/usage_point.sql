{{ config(bind=false) }}

with usage_point as (

    select
        "center" as "center",
        "id" as "id",
        "state" as "state",
        "name" as "name",
        "all_clients" as "is_all_clients",
        "all_kiosks" as "is_all_kiosks",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'usage_point') }}
)

select * from usage_point
