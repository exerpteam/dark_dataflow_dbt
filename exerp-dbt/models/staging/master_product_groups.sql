{{ config(bind=false) }}

with master_product_groups as (

    select
        "id" as "id",
        "globalid" as "global_id",
        "managerrole" as "manager_role",
        "name" as "name",
        "showinsale" as "is_show_in_sale",
        "converted_id" as "converted_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'masterproductgroups') }}
)

select * from master_product_groups
