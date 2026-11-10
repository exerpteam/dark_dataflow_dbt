{{ config(bind=false) }}

with clearinghouse as (

    select
        "id" as "id",
        "scope_type" as "scope_type",
        CASE "scope_type"
            WHEN 'A' THEN 'AREA'
            WHEN 'C' THEN 'CENTER'
            WHEN 'T' THEN 'GLOBAL'
        END as "scope_type_text",
        "scope_id" as "scope_id",
        "blocked" as "is_blocked",
        "state" as "state",
        "ctype" as "ctype",
        CASE "ctype"
            WHEN 1 THEN 'DIRECT DEBIT'
            WHEN 2 THEN 'DIRECT DEBIT'
            WHEN 4 THEN 'DIRECT DEBIT'
            WHEN 8 THEN 'INVOICE'
            WHEN 16 THEN 'INVOICE'
            WHEN 32 THEN 'INVOICE'
            WHEN 64 THEN 'DIRECT DEBIT'
            WHEN 128 THEN 'INVOICE'
            WHEN 129 THEN 'INVOICE'
            WHEN 130 THEN 'DIRECT DEBIT'
            WHEN 131 THEN 'INVOICE'
            WHEN 132 THEN 'INVOICE'
            WHEN 133 THEN 'INVOICE'
            WHEN 134 THEN 'INVOICE'
            WHEN 135 THEN 'INVOICE'
            WHEN 136 THEN 'INVOICE'
            WHEN 137 THEN 'DIRECT DEBIT'
            WHEN 139 THEN 'INVOICE'
            WHEN 140 THEN 'DIRECT DEBIT'
            WHEN 141 THEN 'CREDIT CARD'
            WHEN 142 THEN '3'
            WHEN 143 THEN 'DIRECT DEBIT'
            WHEN 144 THEN 'CC'
            WHEN 145 THEN '1'
            WHEN 146 THEN 'DIRECT DEBIT'
            WHEN 147 THEN 'INVOICE'
            WHEN 148 THEN 'DIRECT DEBIT'
            WHEN 149 THEN 'INVOICE'
            WHEN 150 THEN 'DIRECT DEBIT'
            WHEN 151 THEN 'INVOICE'
            WHEN 152 THEN 'LSV PLUS'
            WHEN 153 THEN 'DIRECT DEBIT'
            WHEN 154 THEN 'INVOICE'
            WHEN 155 THEN 'DIRECT DEBIT'
            WHEN 156 THEN 'DIRECT DEBIT'
            WHEN 157 THEN 'DIRECT DEBIT'
            WHEN 158 THEN 'DIRECT DEBIT'
            WHEN 159 THEN 'DIRECT DEBIT'
            WHEN 160 THEN 'CREDIT CARD'
            WHEN 161 THEN 'INVOICE'
            WHEN 165 THEN 'DIRECT DEBIT'
            WHEN 166 THEN 'INVOICE'
            WHEN 167 THEN 'DIRECT DEBIT'
            WHEN 168 THEN 'DIRECT DEBIT'
            WHEN 169 THEN 'CREDIT CARD'
            WHEN 170 THEN 'INVOICE'
            WHEN 171 THEN 'INVOICE'
            WHEN 172 THEN 'DIRECT DEBIT'
            WHEN 173 THEN 'CREDIT CARD'
            WHEN 174 THEN 'INVOICE'
            WHEN 175 THEN 'CREDIT CARD'
            WHEN 176 THEN 'DIRECT DEBIT'
            WHEN 177 THEN 'DIRECT DEBIT'
            WHEN 178 THEN 'DIRECT DEBIT'
            WHEN 179 THEN 'DIRECT DEBIT'
            WHEN 180 THEN 'DIRECT DEBIT'
            WHEN 181 THEN 'DIRECT DEBIT'
            WHEN 182 THEN 'DIRECT DEBIT'
            WHEN 183 THEN 'CREDIT CARD'
            WHEN 184 THEN '2'
            WHEN 185 THEN 'DIRECT DEBIT'
            WHEN 186 THEN 'CREDIT CARD'
            WHEN 187 THEN 'DIRECT DEBIT'
            WHEN 188 THEN 'CREDIT CARD'
            WHEN 189 THEN 'DIRECT DEBIT'
            WHEN 190 THEN 'CREDIT CARD'
            WHEN 191 THEN 'DIRECT DEBIT'
            WHEN 192 THEN '1'
            WHEN 193 THEN 'CREDIT CARD'
            WHEN 194 THEN 'CREDIT CARD'
            WHEN 195 THEN 'INVOICE'
            WHEN 196 THEN 'CREDIT CARD'
            WHEN 197 THEN 'CREDIT CARD'
            WHEN 198 THEN 'CREDIT CARD'
            WHEN 199 THEN 'DIRECT DEBIT'
            WHEN 200 THEN 'DIRECT DEBIT'
            WHEN 201 THEN 'DIRECT DEBIT'
            WHEN 202 THEN 'DIRECT DEBIT'
            WHEN 203 THEN 'CREDIT CARD'
            WHEN 204 THEN 'DIRECT DEBIT'
            WHEN 205 THEN 'DIRECT DEBIT'
            WHEN 206 THEN 'DIRECT DEBIT'
        END as "ctype_text",
        "name" as "name",
        "datasupplier_id" as "data_supplier_id",
        "serial" as "serial",
        "external_clearinghouse_id" as "external_clearing_house_id",
        "gen_payment_type" as "gen_payment_type",
        "use_ch_notification" as "is_use_ch_notification",
        "available_on_web" as "is_available_on_web",
        "external_authorization" as "is_external_authorization",
        "agr_signature_required" as "is_agr_signature_required",
        "coll_default_fee" as "coll_default_fee",
        "rejection_fee" as "rejection_fee",
        "coll_invalid_fee" as "coll_invalid_fee",
        "cc_end_agr_on_expiry_date" as "is_cc_end_agr_on_expiry_date",
        "cancel_pa_on_rejected_rep_sc" as "is_cancel_pa_on_rejected_rep_sc",
        "cycle_bookdate_on_collect_fee" as "is_cycle_book_date_on_collect_fee",
        "enable_card_on_file" as "is_enable_card_on_file",
        "enable_dynamic_trans_fee" as "is_enable_dynamic_trans_fee",
        "dynamic_trans_fee" as "dynamic_trans_fee",
        "rejection_fee_delay" as "rejection_fee_delay",
        "replicated_at" as "replicated_at"
    from {{ source('zeroetl', 'clearinghouse') }}
)

select * from clearinghouse
