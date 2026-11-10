{{ config(bind=false) }}

with message_attachment as (

    select
        "id" as "id",
        "message_center" as "message_center",
        "message_id" as "message_id",
        "message_subid" as "message_subid",
        "attachment_filename" as "attachment_filename",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'message_attachment') }}
)

select * from message_attachment
