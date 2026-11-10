{{ config(bind=false) }}

with journalentry_and_role_link as (

    select
        "journalentry_id" as "journalentry_id",
        "role_id" as "role_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'journalentry_and_role_link') }}
)

select * from journalentry_and_role_link
