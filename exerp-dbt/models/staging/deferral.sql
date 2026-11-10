{{ config(bind=false) }}

with deferral as (

    select
        "id" as "id",
        "center" as "center",
        {{ exerp_epoch_milliseconds_to_timestamp('"entry_time"', '_center_tz."_time_zone"') }} as "entry_at",
        "defer_acc_trans_center" as "defer_acc_trans_center",
        "defer_acc_trans_id" as "defer_acc_trans_id",
        "defer_acc_trans_subid" as "defer_acc_trans_sub_id",
        "revenue_type" as "revenue_type",
        {{ exerp_epoch_milliseconds_to_timestamp('"reversal_entry_time"', '_center_tz."_time_zone"') }} as "reversal_entry_at",
        "reversal_acc_trans_center" as "reversal_acc_trans_center",
        "reversal_acc_trans_id" as "reversal_acc_trans_id",
        "reversal_acc_trans_subid" as "reversal_acc_trans_sub_id",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'deferral') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from deferral
