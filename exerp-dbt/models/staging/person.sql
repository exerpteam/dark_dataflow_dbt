{{ config(bind=false) }}

with person as (

    select
        "center" as "center",
        "id" as "id",
        "blacklisted" as "blacklisted",
        "persontype" as "type",
        CASE "persontype"
            WHEN 0 THEN 'PRIVATE'
            WHEN 1 THEN 'STUDENT'
            WHEN 2 THEN 'STAFF'
            WHEN 3 THEN 'FRIEND'
            WHEN 4 THEN 'CORPORATE'
            WHEN 5 THEN 'ONEMANCORPORATE'
            WHEN 6 THEN 'FAMILY'
            WHEN 7 THEN 'SENIOR'
            WHEN 8 THEN 'GUEST'
            WHEN 9 THEN 'CHILD'
            WHEN 10 THEN 'EXTERNAL_STAFF'
        END as "type_text",
        "status" as "status",
        CASE "status"
            WHEN 0 THEN 'LEAD'
            WHEN 1 THEN 'ACTIVE'
            WHEN 2 THEN 'INACTIVE'
            WHEN 3 THEN 'TEMPORARYINACTIVE'
            WHEN 4 THEN 'TRANSFERRED'
            WHEN 5 THEN 'DUPLICATE'
            WHEN 6 THEN 'PROSPECT'
            WHEN 7 THEN 'DELETED'
            WHEN 8 THEN 'ANONYMIZED'
            WHEN 9 THEN 'CONTACT'
            WHEN 10 THEN 'BLOCKED'
        END as "status_text",
        "firstname" as "first_name",
        "middlename" as "middle_name",
        "lastname" as "last_name",
        "fullname" as "full_name",
        "nickname" as "nick_name",
        "address1" as "address1",
        "address2" as "address2",
        "address3" as "address3",
        "country" as "country",
        "zipcode" as "zip_code",
        "city" as "city",
        "birthdate" as "birth_date",
        "sex" as "sex",
        CASE "sex"
            WHEN 'C' THEN null
            WHEN 'F' THEN 'FEMALE'
            WHEN 'M' THEN 'MALE'
            WHEN 'U' THEN 'UNKNOWN'
        END as "sex_text",
        CASE "sex"
            WHEN 'C' THEN true
            ELSE false
        END as "is_company",
        "co_name" as "company_name",
        "ssn" as "ssn",
        "friends_allowance" as "friends_allowance",
        "passwd_expiration" as "passwd_expiration_date",
        "first_active_start_date" as "first_active_start_date",
        "last_active_start_date" as "last_active_start_date",
        "last_active_end_date" as "last_active_end_date",
        "memberdays" as "member_days",
        "accumulated_memberdays" as "accumulated_memberdays",
        "current_person_center" as "current_person_center",
        "current_person_id" as "current_person_id",
        "suspension_internal_note" as "suspension_internal_note",
        "suspension_external_note" as "suspension_external_note",
        "external_id" as "external_id",
        "prefer_invoice_by_email" as "is_prefer_invoice_by_email",
        "member_status" as "member_status",
        CASE "member_status"
            WHEN 0 THEN 'N'
            WHEN 1 THEN 'NON-MEMBER'
            WHEN 2 THEN 'MEMBER'
            WHEN 4 THEN 'EXTRA'
            WHEN 5 THEN 'EX-MEMBER'
            WHEN 6 THEN 'LEGACY MEMBER'
        END as "member_status_text",
        "member_status_context" as "member_status_context",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "transfers_current_prs_center" as "transfers_current_prs_center",
        "transfers_current_prs_id" as "transfers_current_prs_id",
        "state" as "state",
        "national_id" as "national_id",
        "resident_id" as "resident_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'persons') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from person
