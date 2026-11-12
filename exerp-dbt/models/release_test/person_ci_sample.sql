{{ config(bind=false) }}

select
    "center",
    "id",
    "fixture_person_key"
from {{ ref('person') }}
