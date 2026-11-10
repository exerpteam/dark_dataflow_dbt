{{ config(bind=false) }}

with entity_identifier as (

    select
        "id" as "id",
        "idmethod" as "method_id",
        CASE "idmethod"
            WHEN 1 THEN 'BARCODE'
            WHEN 2 THEN 'MAGNETIC_CARD'
            WHEN 3 THEN 'SSN'
            WHEN 4 THEN 'RFID_CARD'
            WHEN 5 THEN 'PIN'
            WHEN 6 THEN 'ANTI DROWN'
            WHEN 7 THEN 'QRCODE'
        END as "method_id_text",
        "identity" as "entity",
        "ref_type" as "ref_type",
        "ref_center" as "ref_center",
        "ref_id" as "ref_id",
        "ref_globalid" as "ref_global_id",
        "entitystatus" as "status",
        CASE "entitystatus"
            WHEN 1 THEN 'OK'
            WHEN 2 THEN 'STOLEN'
            WHEN 3 THEN 'MISSING'
            WHEN 4 THEN 'BLOCKED'
            WHEN 5 THEN 'BROKEN'
            WHEN 6 THEN 'RETURNED'
            WHEN 7 THEN 'EXPIRED'
            WHEN 8 THEN 'DELETED'
            WHEN 9 THEN 'COMPROMISED'
            WHEN 10 THEN 'FORGOTTEN'
            WHEN 11 THEN 'BANNED'
        END as "status_text",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        {{ exerp_epoch_milliseconds_to_timestamp('"start_time"', '_center_tz."_time_zone"') }} as "started_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"stop_time"', '_center_tz."_time_zone"') }} as "stopped_at",
        "invoiceline_center" as "invoice_line_center",
        "invoiceline_id" as "invoice_line_id",
        "invoiceline_subid" as "invoice_line_sub_id",
        "assign_employee_center" as "assign_employee_center",
        "assign_employee_id" as "assign_employee_id",
        "block_employee_center" as "block_employee_center",
        "block_employee_id" as "block_employee_id",
        "source_type" as "source_type",
        "quantity" as "quantity",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'entity_identifier') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."ref_center"
)

select * from entity_identifier
