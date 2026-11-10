{{ config(bind=false) }}

with relative as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "subid",
        "rtype" as "type",
        CASE "rtype"
            WHEN 1 THEN 'FRIEND'
            WHEN 2 THEN 'MY COMPANY'
            WHEN 3 THEN 'MY COMPANY AGREEMENT'
            WHEN 4 THEN 'FAMILY'
            WHEN 5 THEN 'MY FRIENDS (MEMBER)'
            WHEN 6 THEN 'MAIN COMPANY'
            WHEN 7 THEN 'CONTACTPERSON'
            WHEN 8 THEN 'CREATEDBY'
            WHEN 9 THEN 'COUNSELLOR'
            WHEN 10 THEN 'ACCOUNTMANAGER'
            WHEN 11 THEN 'DUPLICATE'
            WHEN 12 THEN 'EFT_PAYER'
            WHEN 13 THEN 'REFERRED BY ME'
            WHEN 14 THEN 'MY CHILD'
            WHEN 15 THEN 'MY SECONDARY MEMBER'
            WHEN 16 THEN 'MY FAMILY EMPLOYED AT COMPANY'
            WHEN 17 THEN 'COMPANY MY FAMILY IS EMPLOYED IN'
            WHEN 18 THEN 'FAMILY_RELATIVE'
            WHEN 19 THEN 'PRIMARYTOFAMILY'
            WHEN 20 THEN 'SPOUSETOFAMILY'
            WHEN 21 THEN 'PARTNERTOFAMILY'
            WHEN 22 THEN 'CHILDTOFAMILY'
            WHEN 23 THEN 'OTHERTOFAMILY'
        END as "type_text",
        "relativecenter" as "relative_center",
        "relativeid" as "relative_id",
        "relativesubid" as "relative_subid",
        "status" as "status",
        CASE "status"
            WHEN 0 THEN 'LEAD'
            WHEN 1 THEN 'ACTIVE'
            WHEN 2 THEN 'INACTIVE'
            WHEN 3 THEN 'BLOCKED'
        END as "status_text",
        "expiredate" as "expire_date",
        "family_allow_card_on_file" as "family_allow_card_on_file",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'relative') }}
)

select * from relative
