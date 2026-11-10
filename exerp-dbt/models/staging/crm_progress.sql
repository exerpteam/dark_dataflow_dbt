{{ config(bind=false) }}

with crm_progress as (

    select
        "id" as "id",
        "name" as "name",
        "workflow_id" as "workflow_id",
        "external_id" as "external_id",
        "rank" as "rank",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'crm_progress') }}
)

select * from crm_progress
