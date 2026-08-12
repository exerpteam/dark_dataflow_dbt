{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key=['personcenter', 'personid','name'],
        full_refresh=false
    )
}}

select
    personcenter,
    personid,
    name,
    cast(left(txtvalue, 65535) as varchar(65535)) as txtvalue,
    last_edit_time
from {{ source('postgres', 'person_ext_attrs') }}

{% if is_incremental() %}

where last_edit_time >= (
    select coalesce(max(last_edit_time), 0) - 300000
    from {{ this }}
)

{% endif %}