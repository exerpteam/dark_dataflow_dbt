{{ config(bind=false) }}

select
    "center",
    count(*) as "person_count"
from {{ ref('person') }}
group by "center"
