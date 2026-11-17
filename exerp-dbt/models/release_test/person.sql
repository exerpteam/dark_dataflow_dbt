{{ config(bind=false) }}

select
    "center",
    "id",
    cast('ci-pr-v4' as varchar(32)) as "fixture_version",
    cast("center" as varchar(32)) || ':' || cast("id" as varchar(32))
        as "fixture_person_key"
from {{ source('zeroetl', 'persons') }}
