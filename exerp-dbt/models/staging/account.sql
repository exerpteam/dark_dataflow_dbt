{{ config(bind=false) }}

with account as (

    select
        "center" as "center",
        "id" as "id",
        "periodcenter" as "period_center",
        "periodid" as "period_id",
        "blocked" as "is_blocked",
        "atype" as "type",
        CASE "atype"
            WHEN 1 THEN 'ASSET'
            WHEN 2 THEN 'LIABILITY'
            WHEN 3 THEN 'INCOME'
            WHEN 4 THEN 'EXPENSE'
        END as "type_text",
        "name" as "name",
        "external_id" as "external_id",
        "account_vat_type_group_id" as "account_vat_type_group_id",
        "report_key" as "report_key",
        "globalid" as "global_id",
        "system" as "is_system",
        "trans_rebook_rule_type" as "trans_rebook_rule_type",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'account') }}
)

select * from account
