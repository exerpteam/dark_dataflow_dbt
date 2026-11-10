{{ config(bind=false) }}

with zip_code as (

    select
        "country" as "country_id",
        "zipcode" as "zip_code",
        "city" as "city",
        "county" as "county",
        "province" as "province",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'zip_code') }}
)

select * from zip_code
