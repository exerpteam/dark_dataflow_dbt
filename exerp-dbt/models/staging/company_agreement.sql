{{ config(bind=false) }}

with company_agreement as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "sub_id",
        "name" as "name",
        "roleid" as "role_id",
        "terms" as "terms",
        "state" as "state",
        "blocked" as "is_blocked",
        "documentation_required" as "is_documentation_required",
        "employee_number_required" as "is_employee_number_required",
        "documentation_interval_unit" as "documentation_interval_unit",
        "documentation_interval" as "documentation_interval",
        "target_employee_count" as "target_employee_count",
        {{ exerp_epoch_milliseconds_to_timestamp('"target_time"', '_center_tz."_time_zone"') }} as "target_at",
        "contactcenter" as "contact_center",
        "contactid" as "contact_id",
        "ref" as "ref",
        "stop_new_date" as "stop_new_date",
        "cash_subscription_stop_date" as "is_cash_subscription_stop_date",
        "availability" as "availability",
        "external_id" as "external_id",
        "web_text" as "web_text",
        "max_family_corporate" as "max_family_corporate",
        "family_corporate_status" as "family_corporate_status",
        "require_other_payer" as "is_require_other_payer",
        "last_member_update" as "last_member_update",
        "creation_date" as "creation_date",
        "start_date" as "start_date",
        "activation_date" as "activation_date",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'company_agreement') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from company_agreement
