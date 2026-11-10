{{ config(bind=false) }}

with center as (

    select
        "id" as "id",
        "shortname" as "short_name",
        "name" as "name",
        "startupdate" as "startup_date",
        "phone_number" as "phone_number",
        "fax_number" as "fax_number",
        "email" as "email",
        "org_code" as "org_code",
        "address1" as "address1",
        "address2" as "address2",
        "address3" as "address3",
        "country" as "country",
        "zipcode" as "zip_code",
        "latitude" as "latitude",
        "longitude" as "longitude",
        "center_type" as "center_type",
        CASE "center_type"
            WHEN 1 THEN 'GLOBAL_HEAD_OFFICE'
            WHEN 2 THEN 'NATIONAL_HEAD_OFFICE'
            WHEN 3 THEN 'REGIONAL_HEAD_OFFICE'
            WHEN 4 THEN 'CENTER'
        END as "center_type_text",
        "external_id" as "external_id",
        "city" as "city",
        "org_code2" as "org_code2",
        "web_name" as "web_name",
        "website_url" as "web_site_url",
        "manager_center" as "manager_center",
        "manager_id" as "manager_id",
        "asst_manager_center" as "asst_manager_center",
        "asst_manager_id" as "asst_manager_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '"time_zone"') }} as "modified_at",
        "time_zone" as "time_zone",
        "facility_url" as "facility_url",
        "state" as "state",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'center') }}
)

select * from center
