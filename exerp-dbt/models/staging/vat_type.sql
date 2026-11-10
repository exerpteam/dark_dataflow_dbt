{{ config(bind=false) }}

with vat_type as (

    select
        "center" as "center",
        "id" as "id",
        "name" as "name",
        "globalid" as "global_id",
        "accountcenter" as "account_center",
        "accountid" as "account_id",
        "rate" as "rate",
        "orig_rate" as "original_rate",
        "external_id" as "external_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'vat_type') }}
)

select * from vat_type
