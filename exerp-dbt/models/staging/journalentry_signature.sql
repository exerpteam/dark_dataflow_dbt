{{ config(bind=false) }}

with journalentry_signature as (

    select
        "id" as "id",
        "journalentry_id" as "journalentry_id",
        "name" as "name",
        "reason" as "reason",
        "rank" as "rank",
        "signature_center" as "signature_center",
        "signature_id" as "signature_id",
        "position_left" as "position_left",
        "position_top" as "position_top",
        "width" as "width",
        "height" as "height",
        "page" as "page",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'journalentry_signature') }}
)

select * from journalentry_signature
