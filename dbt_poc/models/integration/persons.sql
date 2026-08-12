{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key=['center', 'id'],
        full_refresh=false
    )
}}

select
    center,
    id,
    blacklisted,
    persontype,
    status,
    firstname,
    middlename,
    lastname,
    fullname,
    nickname,
    address1,
    address2,
    address3,
    country,
    zipcode,
    city,
    birthdate,
    sex,
    pincode,
    password_hash,
    co_name,
    ssn,
    friends_allowance,
    passwd_expiration,
    first_active_start_date,
    last_active_start_date,
    last_active_end_date,
    memberdays,
    accumulated_memberdays,
    current_person_center,
    current_person_id,
    suspension_internal_note,
    suspension_external_note,
    external_id,
    prefer_invoice_by_email,
    member_status,
    member_status_context,
    password_reset_token,
    password_reset_token_exp,
    password_reset_token_used,
    last_modified,
    transfers_current_prs_center,
    transfers_current_prs_id,
    fullname_search,
    state,
    encrypted_ssn,
    encryption_time,
    national_id,
    resident_id
from {{ source('postgres', 'persons') }}

{% if is_incremental() %}

where last_modified >= (
    select coalesce(max(last_modified), 0) - 300000
    from {{ this }}
)

{% endif %}
