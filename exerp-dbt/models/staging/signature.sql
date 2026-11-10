{{ config(bind=false) }}

with signature as (

    select
        "center" as "center",
        "id" as "id",
        "signed_document_mimetype" as "signed_document_mime_type",
        "signature_image_mimetype" as "signature_image_mime_type",
        "signature_receipt" as "signature_receipt",
        "signature_hash" as "signature_hash",
        "document_receipt" as "document_receipt",
        "document_hash" as "document_hash",
        "device_key" as "device_key",
        {{ exerp_epoch_milliseconds_to_timestamp('"creation_time"', '_center_tz."_time_zone"') }} as "creation_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'signature') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from signature
