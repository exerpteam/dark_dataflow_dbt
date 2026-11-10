{{ config(bind=false) }}

with account_vat_type_link as (

    select
        "id" as "id",
        "vat_type_center" as "vat_type_center",
        "vat_type_id" as "vat_type_id",
        "account_vat_type_group_id" as "account_vat_type_group_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'account_vat_type_link') }}
)

select * from account_vat_type_link
