

with decoded as (
    select
    
       id,
    definition_key,
    scope_type,
        scope_id,
        from_varbyte(
            to_varbyte(substring(product, 3), 'hex'),
            'utf8'
        ) as product_xml,
        case
    when cached_producttype = 1 then 'GOOD'
    when cached_producttype = 2 then 'SERVICE'
    when cached_producttype = 4 then 'CLIPCARD'
    when cached_producttype = 5 then 'SUBSCRIPTION_NEW'
    when cached_producttype = 6 then 'TRANSFER'
    when cached_producttype = 7 then 'FREEZE_PERIOD'
    when cached_producttype = 8 then 'GIFTCARD'
    when cached_producttype = 9 then 'FREE_GIFTCARD'
    when cached_producttype = 10 then 'SUBSCRIPTION'
    when cached_producttype = 13 then 'SUBSCRIPTION_ADDON'
    when cached_producttype = 14 then 'ACCESS'
    when cached_producttype = 15 then 'RECURRING_SERVICE'
    else 'UNKNOWN'
end as product_type
    from {{ source('postgres', 'masterproductregister') }}
    
)

select
    id,
     definition_key,
    scope_type,
    scope_id,
    regexp_substr(
        product_xml,
        '<globalId>([^<]*)</globalId>',
        1, 1, 'pe'
    ) as global_id,
    regexp_substr(
        product_xml,
        '<name>([^<]*)</name>',
        1, 1, 'pe'
    ) as product_name,
    product_type
from decoded

