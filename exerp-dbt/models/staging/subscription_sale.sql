{{ config(bind=false) }}

with subscription_sale as (

    select
        "id" as "id",
        "owner_center" as "owner_center",
        "owner_id" as "owner_id",
        "owner_type" as "owner_type",
        CASE "owner_type"
            WHEN 0 THEN 'PRIVATE'
            WHEN 1 THEN 'STUDENT'
            WHEN 2 THEN 'STAFF'
            WHEN 3 THEN 'FRIEND'
            WHEN 4 THEN 'CORPORATE'
            WHEN 5 THEN 'ONEMANCORPORATE'
            WHEN 6 THEN 'FAMILY'
            WHEN 7 THEN 'SENIOR'
            WHEN 8 THEN 'GUEST'
            WHEN 9 THEN 'CONTACT'
        END as "owner_type_text",
        "employee_center" as "employee_center",
        "employee_id" as "employee_id",
        "company_center" as "company_center",
        "company_id" as "company_id",
        "subscription_type_center" as "subscription_type_center",
        "subscription_type_id" as "subscription_type_id",
        "subscription_type_type" as "subscription_type_type",
        CASE "subscription_type_type"
            WHEN 0 THEN 'CASH'
            WHEN 1 THEN 'EFT'
            WHEN 3 THEN 'PROSPECT'
        END as "subscription_type_type_text",
        "type" as "type",
        CASE "type"
            WHEN 1 THEN 'NEW'
            WHEN 2 THEN 'EXTENSION'
            WHEN 3 THEN 'CHANGE'
            WHEN 4 THEN 'REACTIVATE'
        END as "type_text",
        "price_new" as "price_new",
        "price_new_sponsored" as "price_new_sponsored",
        "price_new_discount" as "price_new_discount",
        "price_initial" as "price_initial",
        "price_initial_sponsored" as "price_initial_sponsored",
        "price_initial_discount" as "price_initial_discount",
        "price_period" as "price_period",
        "price_admin_fee" as "price_admin_fee",
        "price_admin_fee_sponsored" as "price_admin_fee_sponsored",
        "price_admin_fee_discount" as "price_admin_fee_discount",
        "credited" as "credited",
        "binding_days" as "binding_days",
        "start_date" as "start_date",
        "sales_date" as "sales_date",
        "end_date" as "end_date",
        "subscription_center" as "subscription_center",
        "subscription_id" as "subscription_id",
        "cancellation_date" as "cancellation_date",
        "termination_date" as "termination_date",
        "cancellation_employee_center" as "cancellation_employee_center",
        "cancellation_employee_id" as "cancellation_employee_id",
        "price_prorata" as "price_prorata",
        "price_prorata_sponsored" as "price_prorata_sponsored",
        "price_prorata_discount" as "price_prorata_discount",
        "contract_excluding_sponsor" as "contract_excluding_sponsor",
        "contract_including_sponsor" as "contract_including_sponsor",
        "contract_sponsored" as "contract_sponsored",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"signatures_completed_time"', '_center_tz."_time_zone"') }} as "signatures_completed_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscription_sale') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."subscription_center"
)

select * from subscription_sale
