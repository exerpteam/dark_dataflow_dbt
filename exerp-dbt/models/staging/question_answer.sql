{{ config(bind=false) }}

with question_answer as (

    select
        "id" as "id",
        "answer_center" as "answer_center",
        "answer_id" as "answer_id",
        "answer_subid" as "answer_subid",
        "question_id" as "question_id",
        "text_answer" as "text_answer",
        "number_answer" as "number_answer",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'question_answer') }}
)

select * from question_answer
