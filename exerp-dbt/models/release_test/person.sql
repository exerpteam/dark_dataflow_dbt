{{ config(bind=false) }}

select
    "center",
    "id",
    cast('baseline-v3' as varchar(32)) as "fixture_version"
from {{ source('zeroetl', 'persons') }}
