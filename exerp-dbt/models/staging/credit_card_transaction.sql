{{ config(bind=false) }}

with credit_card_transaction as (

    select
        "center" as "center",
        "id" as "id",
        {{ exerp_epoch_milliseconds_to_timestamp('"transtime"', '_center_tz."_time_zone"') }} as "transaction_at",
        "type" as "type",
        CASE "type"
            WHEN 1 THEN 'VISA'
            WHEN 2 THEN 'MASTERCARD'
            WHEN 3 THEN 'MAESTRO'
            WHEN 4 THEN 'DANKORT'
            WHEN 5 THEN 'AMERICAN_EXPRESS'
            WHEN 6 THEN 'DINERSCLUB'
            WHEN 7 THEN 'JCB'
            WHEN 8 THEN 'SPARBANKEN'
            WHEN 9 THEN 'SHELL'
            WHEN 10 THEN 'NORSKHYDROUNOX'
            WHEN 11 THEN 'OKQ8'
            WHEN 12 THEN 'PREEM'
            WHEN 13 THEN 'STATOIL'
            WHEN 14 THEN 'STATOILROUTEX'
            WHEN 15 THEN 'VOLVO'
            WHEN 16 THEN 'VISAELECTRON'
            WHEN 17 THEN 'VISA CREDIT'
            WHEN 18 THEN 'BT TEST HOST'
            WHEN 19 THEN 'TIME'
            WHEN 20 THEN 'SOLO'
            WHEN 21 THEN 'LASER'
            WHEN 22 THEN 'LTF'
            WHEN 23 THEN 'CAF'
            WHEN 24 THEN 'CREATION'
            WHEN 25 THEN 'CLYDESDALE'
            WHEN 26 THEN 'BHS GOLD'
            WHEN 27 THEN 'MOTHERCARE CARD'
            WHEN 28 THEN 'BURTON MENSWEAR'
            WHEN 29 THEN 'BA AIRPLUS'
            WHEN 30 THEN 'EDC'
            WHEN 31 THEN 'VISA DEBIT'
            WHEN 32 THEN 'POSTCARD'
            WHEN 33 THEN 'JELMOLI BONUS CARD'
            WHEN 34 THEN 'EC'
            WHEN 35 THEN 'V PAY'
            WHEN 36 THEN 'BEEPTIFY'
            WHEN 37 THEN 'EXTERNAL DEVICE'
            WHEN 38 THEN 'INTERAC'
            WHEN 39 THEN 'DISCOVER'
            WHEN 40 THEN 'UNIONPAY'
            WHEN 41 THEN 'ALLSTAR'
            WHEN 42 THEN 'ARCADIA GROUP CARD'
            WHEN 43 THEN 'FCUK CARD'
            WHEN 44 THEN 'MASTERCARD DEBIT'
            WHEN 45 THEN 'IKEA HOME CARD'
            WHEN 46 THEN 'HFC STORE CARD'
            WHEN 47 THEN 'ACCEL'
            WHEN 48 THEN 'AFFN'
            WHEN 49 THEN 'ALIPAY'
            WHEN 50 THEN 'BCMC'
            WHEN 51 THEN 'CARNETDEBIT'
            WHEN 52 THEN 'CARTEBANCAIRE'
            WHEN 53 THEN 'CABAL'
            WHEN 54 THEN 'CODENSA'
            WHEN 55 THEN 'CU24'
            WHEN 56 THEN 'EFTPOS_AUSTRALIA'
            WHEN 57 THEN 'ELOCREDIT'
            WHEN 58 THEN 'INTERLINK'
            WHEN 59 THEN 'NARANIA'
            WHEN 60 THEN 'NYCE'
            WHEN 61 THEN 'PULSE'
            WHEN 62 THEN 'SHAZAM_PINLESS'
            WHEN 63 THEN 'STAR'
            WHEN 64 THEN 'VIAS'
            WHEN 65 THEN 'WAREHOUSE'
            WHEN 66 THEN 'MCCREDIT'
            WHEN 67 THEN 'MCSTANDARDCREDIT'
            WHEN 68 THEN 'MCSTANDARDDEBIT'
            WHEN 69 THEN 'MCPREMIUMCREDIT'
            WHEN 70 THEN 'MCPREMIUMDEBIT'
            WHEN 71 THEN 'MCSUPERPREMIUMCREDIT'
            WHEN 72 THEN 'MCSUPERPREMIUMDEBIT'
            WHEN 73 THEN 'MCCOMMERCIALCREDIT'
            WHEN 74 THEN 'MCCOMMERCIALDEBIT'
            WHEN 75 THEN 'MCCOMMERCIALPREMIUMCREDIT'
            WHEN 76 THEN 'MCCOMMERCIALPREMIUMDEBIT'
            WHEN 77 THEN 'MCCORPORATECREDIT'
            WHEN 78 THEN 'MCCORPORATEDEBIT'
            WHEN 79 THEN 'MCPURCHASINGCREDIT'
            WHEN 80 THEN 'MCPURCHASINGDEBIT'
            WHEN 81 THEN 'MCFLEETCREDIT'
            WHEN 82 THEN 'MCFLEETDEBIT'
            WHEN 83 THEN 'MCPRO'
            WHEN 84 THEN 'MC_APPLEPAY'
            WHEN 85 THEN 'MC_ANDROIDPAY'
            WHEN 86 THEN 'BIJCARD'
            WHEN 87 THEN 'VISASTANDARDCREDIT'
            WHEN 88 THEN 'VISASTANDARDDEBIT'
            WHEN 89 THEN 'VISAPREMIUMCREDIT'
            WHEN 90 THEN 'VISAPREMIUMDEBIT'
            WHEN 91 THEN 'VISASUPERPREMIUMCREDIT'
            WHEN 92 THEN 'VISASUPERPREMIUMDEBIT'
            WHEN 93 THEN 'VISACOMMERCIALCREDIT'
            WHEN 94 THEN 'VISACOMMERCIALDEBIT'
            WHEN 95 THEN 'VISACOMMERCIALPREMIUMCREDIT'
            WHEN 96 THEN 'VISACOMMERCIALPREMIUMDEBIT'
            WHEN 97 THEN 'VISACOMMERCIALSUPERPREMIUMCREDIT'
            WHEN 98 THEN 'VISACOMMERCIALSUPERPREMIUMDEBIT'
            WHEN 99 THEN 'VISACORPORATECREDIT'
            WHEN 100 THEN 'VISACORPORATEDEBIT'
            WHEN 101 THEN 'VISAPURCHASINGCREDIT'
            WHEN 102 THEN 'VISAPURCHASINGDEBIT'
            WHEN 103 THEN 'VISAFLEETCREDIT'
            WHEN 104 THEN 'VISAFLEETDEBIT'
            WHEN 105 THEN 'VISADANKORT'
            WHEN 106 THEN 'VISAPROPREITARY'
            WHEN 107 THEN 'VISA_APPLEPAY'
            WHEN 108 THEN 'VISA_ANDROIDPAY'
            WHEN 109 THEN 'AMEX_APPLEPAY'
            WHEN 110 THEN 'BOLETOBANCARIO_SANTANDER'
            WHEN 111 THEN 'DINERS_APPLEPAY'
            WHEN 112 THEN 'DIRECTEBANKING'
            WHEN 113 THEN 'DISCOVER_APPLEPAY'
            WHEN 114 THEN 'DOTPAY'
            WHEN 115 THEN 'IDEALBN'
            WHEN 116 THEN 'IDEALING'
            WHEN 117 THEN 'IDEALRABOBANK'
            WHEN 118 THEN 'PAYPAL'
            WHEN 119 THEN 'SEPADIRECTDEBIT_AUTHCAP'
            WHEN 120 THEN 'DEPADIRECTDEBIT_RECEIVED'
            WHEN 121 THEN 'CUPCREDIT'
            WHEN 122 THEN 'CUPDEBIT'
            WHEN 123 THEN 'CARD ON FILE'
            WHEN 124 THEN 'MADA'
            WHEN 125 THEN 'APPLEPAY'
            WHEN 126 THEN 'PAYWITHGOOGLE'
            WHEN 127 THEN 'TWINT'
            WHEN 128 THEN 'ACH'
            WHEN 129 THEN 'PAYBYBANK'
            WHEN 1000 THEN 'OTHER'
        END as "type_text",
        "gl_trans_center" as "gl_trans_center",
        "gl_trans_id" as "gl_trans_id",
        "gl_trans_subid" as "gl_trans_sub_id",
        "amount" as "amount",
        "transaction_id" as "transaction_id",
        "expiration_date" as "expiration_date",
        "card_swiped" as "is_card_swiped",
        "transaction_state" as "transaction_state",
        CASE "transaction_state"
            WHEN 0 THEN 'INITIALIZED'
            WHEN 1 THEN 'AUTHORIZED'
            WHEN 2 THEN 'CAPTURED'
            WHEN 3 THEN 'REVERSED'
            WHEN 4 THEN 'FAILED'
            WHEN 5 THEN 'ERROR'
        END as "transaction_state_text",
        "method" as "method",
        "return_code" as "return_code",
        "return_code_details" as "return_code_details",
        "order_id" as "order_id",
        "recurring_agreement_ref" as "recurring_agreement_ref",
        "capture_type" as "capture_type",
        "cof_payment_agreement_center" as "cof_payment_agreement_center",
        "cof_payment_agreement_id" as "cof_payment_agreement_id",
        "cof_payment_agreement_subid" as "cof_payment_agreement_sub_id",
        "approval_code" as "approval_code",
        "receipt_number" as "receipt_number",
        "invoice_center" as "invoice_center",
        "invoice_id" as "invoice_id",
        "account_id" as "account_id",
        "is_card_on_file" as "is_card_on_file",
        {{ exerp_epoch_milliseconds_to_timestamp('"last_modified"', '_center_tz."_time_zone"') }} as "modified_at",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'credit_card_transaction') }} as _source_row
    left join (
        select "id" as "_center_id", "time_zone" as "_time_zone"
        from {{ source('zeroetl', 'center') }}
    ) as _center_tz
        on _center_tz."_center_id" = _source_row."center"
)

select * from credit_card_transaction
