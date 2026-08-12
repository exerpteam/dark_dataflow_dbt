--dummy query to test 
with participation_counts as (

    select
        participant_center,
        participant_id,
        count(*) as participation_count,
        sum(case when showup_time is not null then 1 else 0 end) as showup_count,
        sum(case when cancelation_time is not null then 1 else 0 end) as cancelled_participation_count,
        max(start_time) as last_participation_time
    from {{ ref('participations') }}
    group by
        participant_center,
        participant_id

),

latest_subscription_sale as (

    select *
    from (
        select
            ss.*,
            row_number() over (
                partition by subscription_center, subscription_id
                order by sales_date desc nulls last, id desc
            ) as rn
        from {{ ref('subscription_sales') }} ss
    )
    where rn = 1

)

select
    p.center || 'p' || p.id as person_id,
    p.external_id as person_external_id,
    p.fullname as person_name,
    p.status as person_status,
    p.member_status,

    c.id as center_id,
    c.name as center_name,

    s.center || 'ss' || s.id as subscription_id,
    s.state as subscription_state,
    s.sub_state as subscription_sub_state,
    s.start_date as subscription_start_date,
    s.end_date as subscription_end_date,

    ss.id as subscription_sale_id,
    ss.sales_date,
    ss.type as subscription_sale_type,

    

    coalesce(pc.participation_count, 0) as participation_count,
    coalesce(pc.showup_count, 0) as showup_count,
    coalesce(pc.cancelled_participation_count, 0) as cancelled_participation_count,
    pc.last_participation_time,

    pa.center || 'pa' || pa.id || '-' || pa.subid as payment_agreement_id,
    pa.state as payment_agreement_state,
    pa.active as payment_agreement_active,
    pa.ended_date as payment_agreement_ended_date,
    pa.ended_reason_code as payment_agreement_ended_reason_code,

    ar.id as account_receivable_id,
    ar.balance as account_receivable_balance,
    ar.state as account_receivable_state,

    pea.txtvalue as test_person_ext_attr_value

from {{ ref('persons') }} p

join {{ ref('subscriptions') }} s
    on s.owner_center = p.center
   and s.owner_id = p.id
    and s.state in (2,4,8)
left join latest_subscription_sale ss
    on ss.subscription_center = s.center
   and ss.subscription_id = s.id

left join {{ ref('centers') }} c
    on c.id = p.center


left join participation_counts pc
    on pc.participant_center = p.center
   and pc.participant_id = p.id

left join {{ ref('payment_agreements') }} pa
    on pa.center = s.payment_agreement_center
   and pa.id = s.payment_agreement_id
   and pa.subid = s.payment_agreement_subid
   and pa.active = true

left join {{ ref('account_receivables') }} ar
    on ar.customercenter = p.center
   and ar.customerid = p.id

left join {{ ref('person_ext_attrs') }} pea
    on pea.personcenter = p.center
   and pea.personid = p.id
   and pea.name = '_eClub_Email'

where p.persontype <> 2