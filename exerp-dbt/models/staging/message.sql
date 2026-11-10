{{ config(bind=false) }}

with message as (

    select
        "center" as "center",
        "id" as "id",
        "subid" as "subid",
        "deliverycode" as "delivery_code",
        "delivery_ref" as "delivery_ref",
        "deliverymethod" as "delivery_method",
        CASE "deliverymethod"
            WHEN 0 THEN 'STAFF'
            WHEN 1 THEN 'EMAIL'
            WHEN 2 THEN 'SMS'
            WHEN 3 THEN 'PERSINTF'
            WHEN 4 THEN 'BLOCKPERSINTF'
            WHEN 5 THEN 'LETTER'
            WHEN 6 THEN 'MOBILE_API'
            WHEN 7 THEN 'STAFF_APP_NOTIFICATION'
            WHEN 8 THEN 'MEMBER_APP_NOTIFICATION'
        END as "delivery_method_text",
        "templatetype" as "template_type",
        "templateid" as "template_id",
        "senderid" as "sender_id",
        "sendercenter" as "sender_center",
        "sender_ext_ref" as "sender_ext_ref",
        {{ exerp_epoch_milliseconds_to_timestamp('"senttime"', '_center_tz."_time_zone"') }} as "sent_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"earliest_delivery_time"', '_center_tz."_time_zone"') }} as "earliest_delivery_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"receivedtime"', '_center_tz."_time_zone"') }} as "received_at",
        {{ exerp_epoch_milliseconds_to_timestamp('"expiretime"', '_center_tz."_time_zone"') }} as "expired_at",
        "subject" as "subject",
        "message_type_id" as "message_type_id",
        CASE "message_type_id"
            WHEN 0 THEN 'REMINDER_STUDENT_DOCUMENTATION'
            WHEN 1 THEN 'REMINDER_FRIEND_DOCUMENTATION'
            WHEN 2 THEN 'REMINDER_CORPORATE_DOCUMENTATION'
            WHEN 3 THEN 'REMINDER_FAMILY_DOCUMENTATION'
            WHEN 4 THEN 'REMINDER_SENIOR_DOCUMENTATION'
            WHEN 5 THEN 'EXPIRED_STUDENT_DOCUMENTATION'
            WHEN 6 THEN 'EXPIRED_FRIEND_DOCUMENTATION'
            WHEN 7 THEN 'EXPIRED_CORPORATE_DOCUMENTATION'
            WHEN 8 THEN 'EXPIRED_FAMILY_DOCUMENTATION'
            WHEN 9 THEN 'EXPIRED_SENIOR_DOCUMENTATION'
            WHEN 10 THEN 'STAFF_TO_CUSTOMER'
            WHEN 11 THEN 'CASH_SUBSCRIPTION_RENEWAL_REMINDER'
            WHEN 12 THEN 'SUBSCRIPTION_PRICE_CHANGE'
            WHEN 15 THEN 'SEND_PASSWORD'
            WHEN 16 THEN 'PAY_FOR_OTHER_PERSONS_EFT_SUBSCRIPTION_START'
            WHEN 17 THEN 'PAY_FOR_OTHER_PERSONS_EFT_SUBSCRIPTION_STOP'
            WHEN 19 THEN 'CASH_COLLECTION_REMINDER'
            WHEN 20 THEN 'CASH_COLLECTION_NOTIFICATION'
            WHEN 21 THEN 'CASH_COLLECTION_REQUEST_REMAINING_AND_STOP'
            WHEN 22 THEN 'TODO_COMPLETED'
            WHEN 23 THEN 'WEB_SALES'
            WHEN 24 THEN 'CASH_COLLECTION_BLOCK'
            WHEN 25 THEN 'NEWS_LETTER'
            WHEN 26 THEN 'WEB_SALES_SUBSCRIPTION_CONTRACT'
            WHEN 27 THEN 'WEB_CREATE_CUSTOMER'
            WHEN 28 THEN 'SANCTION_SERVICE_PRODUCT_PUNISHMENT'
            WHEN 29 THEN 'SANCTION_DAY_BLOCK_PUNISHMENT'
            WHEN 30 THEN 'SANCTION_CLIP_PUNISHMENT'
            WHEN 31 THEN 'SANCTION_BOOKING_RESTRICTION_PUNISHMENT'
            WHEN 32 THEN 'SANCTION_SERVICE_PRODUCT_WARNING'
            WHEN 33 THEN 'SANCTION_DAY_BLOCK_WARNING'
            WHEN 34 THEN 'SANCTION_CLIP_WARNING'
            WHEN 35 THEN 'SANCTION_BOOKING_RESTRICTION_WARNING'
            WHEN 36 THEN 'PARTICIPATION_CANCELATION_BY_STAFF'
            WHEN 37 THEN 'PARTICIPATION_MOVEDUP'
            WHEN 38 THEN 'SUBSCRIPTION_SALE'
            WHEN 39 THEN 'STAFF_CANCELATION'
            WHEN 40 THEN 'PARTICIPATION_CREATION'
            WHEN 41 THEN 'PARTICIPATION_MOVE'
            WHEN 42 THEN 'BOOKING_REMINDER_COURT'
            WHEN 43 THEN 'BOOKING_REMINDER_STAFF'
            WHEN 44 THEN 'BOOKING_REMINDER_CLASS'
            WHEN 45 THEN 'PARTICIPATION_CONFIRMATION_CLASS'
            WHEN 46 THEN 'PARTICIPATION_CONFIRMATION_COURT'
            WHEN 47 THEN 'PARTICIPATION_CONFIRMATION_STAFF'
            WHEN 48 THEN 'FREEZE_CREATION'
            WHEN 49 THEN 'FREEZE_END'
            WHEN 50 THEN 'SUBSCRIPTION_TERMINATION'
            WHEN 51 THEN 'BIRTHDAY'
            WHEN 52 THEN 'PASSWORD_EXPIRATION_WARNING'
            WHEN 53 THEN 'PAYMENT_REQUEST_NOTIFICATION'
            WHEN 54 THEN 'ADVANCED_AGREEMENT_NOTIFICATION'
            WHEN 55 THEN 'TODO_ASSIGNED'
            WHEN 56 THEN 'PARTICIPATION_CONFIRMATION_CHILD_CARE'
            WHEN 57 THEN 'PARTICIPATION_CANCELATION_BY_MEMBER'
            WHEN 58 THEN 'BOOKING_STAFF_CHANGE'
            WHEN 59 THEN 'BOOKING_STAFF_CHANGE_TO_STAFF'
            WHEN 60 THEN 'TODO_DELETED'
            WHEN 61 THEN 'PAYMENT_AGREEMENT_CREATION'
            WHEN 62 THEN 'CREDIT_CARD_AGREEMENT_FINISH_ONLINE'
            WHEN 63 THEN 'CHECK_IN'
            WHEN 64 THEN 'ATTEND'
            WHEN 65 THEN 'PERSON_CREATED'
            WHEN 66 THEN 'PERSON_DETAILS_CHANGED'
            WHEN 67 THEN 'PERSON_STATE_CHANGED'
            WHEN 68 THEN 'PERSON_TRANSFERRED'
            WHEN 69 THEN 'COMPANY_DETAILS_CHANGED'
            WHEN 70 THEN 'COMPANY_AGREEMENT_DETAILS_CHANGED'
            WHEN 71 THEN 'PARTICIPATION_STATE_CHANGED'
            WHEN 72 THEN 'EFT_AGREEMENT_FINISH_EXTERNALLY'
            WHEN 73 THEN 'BOOKING_CREATED'
            WHEN 74 THEN 'BOOKING_CANCELLED'
            WHEN 75 THEN 'BOOKING_CHANGED'
            WHEN 76 THEN 'PAYMENT_AGREEMENT_EXPIRATION'
            WHEN 77 THEN 'LEAD_ONLINE_SALES_DISCONTINUED'
            WHEN 78 THEN 'PRODUCT_SALE'
            WHEN 79 THEN 'PRODUCT_CREDIT'
            WHEN 80 THEN 'CALDAV_FAILURE'
            WHEN 81 THEN 'CREATE_TASK'
            WHEN 82 THEN 'EXTENDED_ATTRIBUTE_CHANGED'
            WHEN 83 THEN 'NEW_ACTIVE_MEMBERS'
            WHEN 84 THEN 'MEMBER_CARD_ASSIGNED'
            WHEN 85 THEN 'MEMBER_CARD_BLOCKED'
            WHEN 86 THEN 'MEMBER_CARD_UNBLOCKED'
            WHEN 88 THEN 'QUESTIONNAIRE_ANSWERED'
            WHEN 89 THEN 'JOURNAL_NOTE_ADDED'
            WHEN 90 THEN 'SUSPENSION_STATUS_CHANGED'
            WHEN 91 THEN 'SUBSCRIPTION_CHANGED'
            WHEN 92 THEN 'CLIPCARD_SOLD'
            WHEN 93 THEN 'CLIPCARD_CLIPS_ADJUSTED'
            WHEN 94 THEN 'ADDON_STARTED'
            WHEN 95 THEN 'ADDON_STOPPED'
            WHEN 96 THEN 'ADVANCE_NOTICE'
            WHEN 97 THEN 'SQL_EVENT_JOB'
            WHEN 98 THEN 'PAYMENT_AGREEMENT_CREATED'
            WHEN 99 THEN 'REJECT_REASON_CODES'
            WHEN 100 THEN 'TASK_ACTION_PERFORMED'
            WHEN 101 THEN 'FAILED_PAYMENT_REQUEST_NOTIFICATION'
            WHEN 102 THEN 'TASK_CHANGE_FOR_STAFF'
            WHEN 103 THEN 'TASK_TRANSITION_MANUALLY_SELECTED'
            WHEN 104 THEN 'SUBSCRIPTION_CANCELLED'
            WHEN 105 THEN 'LEAD_CREATED'
            WHEN 106 THEN 'PARTICIPATION_REMINDER'
            WHEN 107 THEN 'PARTICIPATION_CANCELLATION'
            WHEN 108 THEN 'PERSON_STATUS_DURATION'
            WHEN 109 THEN 'PAYMENT_REQUEST_DELIVERY'
            WHEN 110 THEN 'PAID_STATE_CHANGED'
            WHEN 111 THEN 'PAID_STATE_INACTIVITY_PERIOD'
            WHEN 112 THEN 'PAID_STATE_TOTAL'
            WHEN 113 THEN 'PERSON_TRANSFERRED_SUBSCRIPTION_CHANGED'
            WHEN 114 THEN 'SEND_PASSWORD_TOKEN'
            WHEN 115 THEN 'SUBSCRIPTION_STATE_CHANGED'
            WHEN 116 THEN 'SUBSCRIPTION_PRICE_CHANGE_CUSTOM'
            WHEN 117 THEN 'PARTICIPATION_SEAT_CHANGED'
            WHEN 118 THEN 'HEALTH_CERTIFICATE_EXPIRATION'
            WHEN 119 THEN 'NOTIFICATION_BEFORE_AUTO_STOP_AT_BINDING_END_DATE'
            WHEN 120 THEN 'ATTEND_FAILURE'
            WHEN 121 THEN 'PAYMENT_REQUEST_NOTIFICATION_WITH_INVOICE'
            WHEN 122 THEN 'PARTICIPATION_ACTIVITY_CHANGED'
            WHEN 123 THEN 'CONTROLLER_OFFLINE_ALERT'
            WHEN 124 THEN 'CONTROLLER_BACK_ONLINE_ALERT'
            WHEN 125 THEN 'CONTROLLER_STOPPED_ALERT'
            WHEN 126 THEN 'CLIPCARD_OUT_OF_CLIPS'
            WHEN 127 THEN 'CHECK_OUT'
            WHEN 128 THEN 'PERSON_PICTURE_CHANGED'
            WHEN 129 THEN 'CONTACT_INFORMATION_CHANGED'
            WHEN 130 THEN 'BULK_SUBSCRIPTION_CHANGED'
            WHEN 131 THEN 'CLIPCARD_STATE_CHANGED'
            WHEN 132 THEN 'BINDING_END_DATE_CHANGED'
            WHEN 133 THEN 'CLIPCARD_EXPIRATION_ADVISE'
            WHEN 134 THEN 'RECURRING_PARTICIPATIONS_CREATION'
            WHEN 135 THEN 'RECURRING_PARTICIPATIONS_CANCELLATION'
            WHEN 136 THEN 'RECURRING_PARTICIPATIONS_CONFIRMATION_CLASS'
            WHEN 137 THEN 'RECURRING_PARTICIPATIONS_CONFIRMATION_COURT'
            WHEN 138 THEN 'RECURRING_PARTICIPATIONS_CONFIRMATION_STAFF'
            WHEN 139 THEN 'RECURRING_PARTICIPATIONS_CONFIRMATION_CHILD_CARE'
            WHEN 140 THEN 'RECURRING_PARTICIPATIONS_CANCELATION_BY_STAFF'
            WHEN 141 THEN 'RECURRING_PARTICIPATIONS_CANCELATION_BY_MEMBER'
            WHEN 142 THEN 'RECURRING_PARTICIPATIONS_MOVE'
            WHEN 143 THEN 'CLIPCARD_CHANGE_ASSIGNED_STAFF'
            WHEN 144 THEN 'CLIPCARD_CLIPS_REACHED'
            WHEN 145 THEN 'BINDING_PERIOD_AUTO_RENEWED'
            WHEN 146 THEN 'CASH_COLLECTION_REQUEST_BUYOUT_AND_STOP'
            WHEN 147 THEN 'CASH_COLLECTION_PUSH_MESSAGE'
            WHEN 148 THEN 'PAYMENT_REQUESTS_FAILED'
            WHEN 149 THEN 'SUBSCRIPTION_REASSIGNED'
            WHEN 150 THEN 'STAFF_AVAILABLE_FOR_SUBSTITUTION'
            WHEN 151 THEN 'STAFF_AVAILABLE_FOR_SUBSTITUTION_TAKEN_OVER'
            WHEN 152 THEN 'ADDON_STARTED_IN_FUTURE'
            WHEN 153 THEN 'SANCTION_BOOKING_RESTRICTION_EXPIRED'
            WHEN 154 THEN 'EMPLOYEE_LOGIN_CREATED'
        END as "message_type_id_text",
        "delivered_by_center" as "delivered_by_center",
        "delivered_by_id" as "delivered_by_id",
        "invoice_line_center" as "invoice_line_center",
        "invoice_line_id" as "invoice_line_id",
        "invoice_line_subid" as "invoice_line_subid",
        "use_work_address" as "is_use_work_address",
        "reference" as "reference",
        "receiver_address_type" as "receiver_address_type",
        "sender_address_type" as "sender_address_type",
        "payload" as "payload",
        "payload_type" as "payload_type",
        "messagecategory" as "message_category",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'message') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from message
