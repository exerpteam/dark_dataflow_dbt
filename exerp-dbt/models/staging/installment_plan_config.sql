{{ config(bind=false) }}

with installment_plan_config as (

    select
        "id" as "id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "name" as "name",
        "quantity" as "quantity",
        "type" as "type",
        "rounding" as "rounding",
        "first_inst_paid_in_pos" as "is_first_inst_paid_in_pos",
        "contract_template_id" as "contract_template_id",
        "admin_fee_product" as "admin_fee_product",
        "roles" as "roles",
        "state" as "state",
        {{ exerp_epoch_milliseconds_to_timestamp('"created"', 'UTC') }} as "created",
        {{ exerp_epoch_milliseconds_to_timestamp('"modified"', 'UTC') }} as "modified",
        {{ exerp_epoch_milliseconds_to_timestamp('"deleted"', 'UTC') }} as "deleted",
        "version" as "version",
        "external_id" as "external_id",
        "installment_plan_type" as "installment_plan_type",
        "threshold" as "threshold",
        "initial_amount" as "initial_amount",
        "ref_type" as "ref_type",
        "ref_globalid" as "ref_global_id",
        "ref_center" as "ref_center",
        "ref_id" as "ref_id",
        "ref_program_type_id" as "ref_program_type_id",
        "available_on_web" as "is_available_on_web",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'installment_plan_config') }}
)

select * from installment_plan_config
