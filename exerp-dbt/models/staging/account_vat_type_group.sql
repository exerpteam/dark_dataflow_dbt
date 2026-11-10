{{ config(bind=false) }}

with account_vat_type_group as (

    select
        "id" as "id",
        "account_center" as "account_center",
        "account_id" as "account_id",
        "global_id" as "global_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'account_vat_type_group') }}
)

select * from account_vat_type_group
