{{ config(bind=false) }}

with subscription_period_part as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "subid",
        "spp_type" as "spp_type",
        "spp_state" as "spp_state",
        "period_number" as "period_number",
        "from_date" as "from_date",
        "to_date" as "to_date",
        "old_billed_until_date" as "old_billed_until_date",
        "subscription_price" as "subscription_price",
        "addons_price" as "addons_price",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"cancellation_time"', '_center_tz."_time_zone"') }} as "cancellation_at",
        "campaign_code_id" as "campaign_code_id",
        "had_hard_close_role" as "is_had_hard_close_role",
        "sync_date" as "sync_date",
        "prorata_sessions" as "prorata_sessions",
        "prorata_sessions_total" as "prorata_sessions_total",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'subscription_period_part') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from subscription_period_part
