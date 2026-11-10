{{ config(bind=false) }}

with converter_entity_state as (

    select
        "entitytype" as "entity_type",
        "oldentityid" as "old_entity_id",
        "newentitycenter" as "new_entity_center",
        "newentityid" as "new_entity_id",
        "newentitysubid" as "new_entity_sub_id",
        "writername" as "writer_name",
        "lastupdated" as "last_updated",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'converter_entity_state') }}
)

select * from converter_entity_state
