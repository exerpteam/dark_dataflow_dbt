{{ config(bind=false) }}

select
    "center",
    "id"
from {{ source('zeroetl', 'persons') }}
