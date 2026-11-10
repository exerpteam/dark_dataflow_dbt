{{ config(bind=false) }}

with doc_requirement_item as (

    select
        "id" as "id",
        "documentation_requirement_key" as "documentation_requirement_key",
        "type" as "type",
        CASE "type"
            WHEN 'CONTRACT' THEN 'DOCUMENT'
            WHEN 'CUSTOM_JOURNAL_DOCUMENT' THEN 'DOCUMENT'
            WHEN 'QUESTIONNAIRE' THEN 'ANSWER_SUBMISSION'
        END as "type_text",
        "name" as "name",
        "item_type_key" as "item_type_key",
        "itm_instance_journal_entry_key" as "item_instance_journal_entry_key",
        "item_instance_center" as "item_instance_center",
        "item_instance_id" as "item_instance_id",
        "item_instance_sub_id" as "item_instance_sub_id",
        "state" as "state",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'doc_requirement_item') }}
)

select * from doc_requirement_item
