{{ config(bind=false) }}

with sms_splits as (

    select
        "ref_no" as "ref_no",
        "ok" as "is_ok",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'sms_splits') }}
)

select * from sms_splits
