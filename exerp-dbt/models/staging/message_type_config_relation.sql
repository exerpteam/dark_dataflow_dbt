{{ config(bind=false) }}

with message_type_config_relation as (

    select
        "ranking" as "ranking",
        "delivery_method_id" as "delivery_method_id",
        "template_id" as "template_id",
        "charge_product" as "charge_product",
        "availability_period_id" as "availability_period_id",
        "receiver_address_type" as "receiver_address_type",
        "sender_address_type" as "sender_address_type",
        "delay" as "delay",
        "messagecategory" as "message_category",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'message_type_config_relation') }}
)

select * from message_type_config_relation
