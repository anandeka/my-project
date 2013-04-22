DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID = 'CREATE_DFT_PI' and DGM.IS_CONCENTRATE = 'Y';
DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID = 'CREATE_DFT_FI' and DGM.IS_CONCENTRATE = 'Y';


commit;

declare fetchQueryPIISDraft CLOB := 'INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_dry_quantity, invoice_wet_quantity, moisture,
             invoiced_qty_unit, internal_invoice_ref_no, invoice_amount,
             material_cost, addditional_charges, taxes, due_date,
             supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, gmr_finalize_qty, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, contract_type, origin,
             inco_term_location, notify_party, sales_purchase, invoice_status,
             freight_charge, adjustment_amount, total_premium_amount,
             our_person_incharge, internal_comments, is_self_billing,PROV_PERCENTAGE, IS_INV_DRAFT, internal_doc_ref_no)
   WITH TEST AS
        (SELECT   invs.internal_invoice_ref_no, SUM (asm.net_weight) AS wet,
                  SUM (asm.dry_weight) AS dry
             FROM is_invoice_summary invs,
                  ash_assay_header ash,
                  asm_assay_sublot_mapping asm,
                  iam_invoice_assay_mapping iam
            WHERE invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
              AND iam.ash_id = ash.ash_id
              AND ash.ash_id = asm.ash_id
         GROUP BY invs.internal_invoice_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            t.dry AS invoice_dry_quantity, t.wet AS invoice_wet_quantity,
            ROUND ((((t.wet - t.dry) / t.wet) * 100), 2) AS moisture,
            qum_gmr.qty_unit AS invoiced_qty_unit,
            invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            invs.total_amount_to_pay AS invoice_amount,
            invs.amount_to_pay_before_adj AS material_cost,
            invs.total_other_charge_amount AS addditional_charges,
            invs.total_tax_amount AS taxes, invs.payment_due_date AS due_date,
            invs.cp_ref_no AS supplier_invoice_no,
            pcm.issue_date AS contract_date,
            pcm.contract_ref_no AS contract_ref_no,
            SUM (ii.invoicable_qty) AS stock_quantity,
            stragg (DISTINCT ii.stock_ref_no) AS stock_ref_no,
            NVL (cm_pct.cur_code, cm.cur_code) AS invoice_amount_unit,
            stragg (DISTINCT gmr.gmr_ref_no) AS gmr_ref_no,
            SUM (gmr.qty) AS gmr_quality,
            pcpd.qty_max_val AS contract_quantity,
            qum.qty_unit AS contract_qty_unit,
            pcpd.max_tolerance AS contract_tolerance,
            qat.quality_name AS quality, pdm.product_desc AS product,
            pcm.cp_contract_ref_no AS cp_contract_ref_no,
            pym.payment_term AS payment_term,
            gmr.final_weight AS gmr_finalize_qty, phd.companyname AS cp_name,
            pad.address AS cp_address, cym.country_name AS cp_country,
            cim.city_name AS cp_city, sm.state_name AS cp_state,
            pad.zip AS cp_zip, pcm.contract_type AS contract_type,
            cymloading.country_name AS origin,
            pci.terms AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.freight_allowance_amt AS freight_charge,
            invs.invoice_adjustment_amount AS adjustment_amount,
            invs.total_premium_amount AS total_premium_amount,
            (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge,INVS.INTERNAL_COMMENTS as internal_comments, pcm.is_self_billing,INVS.PROV_PCTG_AMT,
            INVS.IS_INV_DRAFT, ?
       FROM is_invoice_summary invs,
            iid_invoicable_item_details iid,
            pcm_physical_contract_main pcm,
            v_pci pci,
            ii_invoicable_item ii,
            cm_currency_master cm,
            gmr_goods_movement_record gmr,
            pcpd_pc_product_definition pcpd,
            qum_quantity_unit_master qum,
            pcpq_pc_product_quality pcpq,
            qat_quality_attributes qat,
            pdm_productmaster pdm,
            phd_profileheaderdetails phd,
            pym_payment_terms_master pym,
            pad_profile_addresses pad,
            cym_countrymaster cym,
            cim_citymaster cim,
            sm_state_master sm,
            bpat_bp_address_type bpat,
            cym_countrymaster cymloading,
            sad_shipment_advice sad,
            sd_shipment_detail sd,
            phd_profileheaderdetails phd1,
            phd_profileheaderdetails phd2,
            qum_quantity_unit_master qum_gmr,
            cm_currency_master cm_pct,
            ak_corporate_user akuser,
            GAB_GLOBALADDRESSBOOK gab,
            AXS_ACTION_SUMMARY axs,
            IAM_INVOICE_ACTION_MAPPING iam,
            TEST t
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND iid.invoicable_item_id = ii.invoicable_item_id(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.invoice_currency_id = cm.cur_id(+)
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
        AND INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
        AND IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
        AND AXS.CREATED_BY = AKUSER.USER_ID
        AND AKUSER.GABID = GAB.GABID
        AND pcpd.qty_unit_id = qum.qty_unit_id(+)
        AND pcpd.pcpd_id = pcpq.pcpd_id(+)
        AND pci.quality_id = qat.quality_id(+)
        AND pcpd.product_id = pdm.product_id(+)
        AND invs.cp_id = phd.profileid(+)
        AND INVS.CREDIT_TERM = pym.payment_term_id(+)
        AND phd.profileid = pad.profile_id(+)
        AND pad.country_id = cym.country_id(+)
        AND pad.city_id = cim.city_id(+)
        AND pad.state_id = sm.state_id(+)
        AND pad.address_type = bpat.bp_address_type_id(+)
        AND cymloading.country_id(+) = gmr.loading_country_id
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.notify_party_id = phd1.profileid(+)
        AND sd.notify_party_id = phd2.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND invs.invoice_cur_id = cm_pct.cur_id(+)
        AND pad.address_type(+) = ''Billing''
        AND pad.is_deleted(+) = ''N''
        AND pcpd.input_output IN (''Input'')
        AND t.internal_invoice_ref_no = invs.internal_invoice_ref_no
        AND invs.internal_invoice_ref_no = ?
   GROUP BY invs.invoice_ref_no,
            invs.invoice_type_name,
            invs.invoice_issue_date,
            invs.invoiced_qty,
            invs.internal_invoice_ref_no,
            invs.total_amount_to_pay,
            invs.total_other_charge_amount,
            invs.total_tax_amount,
            invs.payment_due_date,
            invs.cp_ref_no,
            pcm.issue_date,
            pcm.contract_ref_no,
            cm.cur_code,
            pcpd.qty_max_val,
            qum.qty_unit,
            pcpd.max_tolerance,
            qat.quality_name,
            pdm.product_desc,
            pcm.cp_contract_ref_no,
            pym.payment_term,
            gmr.final_weight,
            phd.companyname,
            pad.address,
            cym.country_name,
            cim.city_name,
            sm.state_name,
            pad.zip,
            pcm.contract_type,
            cymloading.country_name,
            pci.terms,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            invs.invoice_status,
            invs.freight_allowance_amt,
            invs.invoice_adjustment_amount,
            invs.total_premium_amount,
            cm_pct.cur_code,
            akuser.login_name,
            t.dry,
            t.wet,
            pcm.is_self_billing,
            INVS.INTERNAL_COMMENTS,
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            INVS.PROV_PCTG_AMT,
            IS_INV_DRAFT';



fetchQueryPIBDPDraft CLOB := 'INSERT INTO is_bdp_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, remarks, iban, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          cpipi.beneficiary_name AS beneficiary_name,
          bpb.bank_name AS bank_name, bpa.account_no AS account_no,
          cpipi.aba_no AS aba_rtn, cpipi.instructions AS instruction,
          cpipi.remarks AS remarks, bpa.iban AS iban, ?
     FROM bpa_bp_bank_accounts bpa,
          bpb_business_partner_banks bpb,
          is_invoice_summary invs,
          cpipi_cp_inv_pay_instruction cpipi
    WHERE invs.internal_invoice_ref_no = cpipi.internal_invoice_ref_no
      AND cpipi.bank_id = bpa.bank_id
      AND bpa.bank_id = bpb.bank_id
      AND cpipi.bank_account_id = bpa.account_id
      AND invs.internal_invoice_ref_no = ?';

fetchQueryPIPayDraft CLOB := 'INSERT INTO IS_CONC_PAYABLE_CHILD (
  INTERNAL_INVOICE_REF_NO,
  GMR_REF_NO,
  GMR_QUANTITY,
  GMR_QUALITY,
  GMR_QTY_UNIT,
  INVOICED_PRICE_UNIT,
  STOCK_REF_NO,
  STOCK_QTY,
  ELEMENT_NAME,
  INVOICE_PRICE,
  SUB_LOT_NO,
  ELEMENT_INV_AMOUNT,
  ELEMENT_PRICE_UNIT,
  ASSAY_CONTENT,
  ASSAY_CONTENT_UNIT,
  ELEMENT_INVOICED_QTY,
  ELEMENT_INVOICED_QTY_UNIT,
  ELEMENT_ID,
  NET_PAYABLE,
  DRY_QUANTITY,
  INTERNAL_DOC_REF_NO              
)
Select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
GMR.GMR_REF_NO as GMR_REF_NO,
GMR.QTY as GMR_QUANTITY,
nvl(QAT.QUALITY_NAME, QAT1.QUALITY_NAME) as GMR_QUALITY,
QUM.QTY_UNIT as GMR_QTY_UNIT,
PUM.PRICE_UNIT_NAME as INVOICED_PRICE_UNIT,
nvl(GRD.INTERNAL_STOCK_REF_NO, DGRD.INTERNAL_STOCK_REF_NO) as STOCK_REF_NO,
IID.INVOICED_QTY as STOCK_QTY,
AML.ATTRIBUTE_NAME AS ELEMENT_NAME,
IIED.ELEMENT_PAYABLE_PRICE AS INVOICE_PRICE,
IIED.SUB_LOT_NO AS SUB_LOT_NO,
IIED.ELEMENT_PAYABLE_AMOUNT AS ELEMENT_INV_AMOUNT,
PEPUM.PRICE_UNIT_NAME AS ELEMENT_PRICE_UNIT,
PQCA.TYPICAL as ASSAY_CONTENT,
RM.RATIO_NAME as ASSAY_CONTENT_UNIT,
IIED.ELEMENT_INVOICED_QTY AS ELEMENT_INVOICED_QTY,
QUMIIED.QTY_UNIT AS ELEMENT_INVOICED_QTY_UNIT,
AML.ATTRIBUTE_ID AS ELEMENT_ID,
PQCAPD.PAYABLE_PERCENTAGE AS NET_PAYABLE,
ROUND
           ((  iid.invoiced_qty
             - (  iid.invoiced_qty
                * (SELECT pqca_mos.typical
                     FROM pqca_pq_chemical_attributes pqca_mos,
                          aml_attribute_master_list aml_mos,
                          asm_assay_sublot_mapping asm_mos,
                          ash_assay_header ash_mos
                    WHERE pqca_mos.asm_id = asm_mos.asm_id
                      AND ash_mos.ash_id = asm_mos.ash_id
                      AND pqca_mos.element_id = aml_mos.attribute_id
                      AND ash_mos.ash_id = ash.ash_id
                      AND aml_mos.attribute_name = ''H2O'')
                / 100
               )
            ),
            10
           ) AS dry_quantity,
?
from
IS_INVOICE_SUMMARY invs,
IID_INVOICABLE_ITEM_DETAILS iid,
GMR_GOODS_MOVEMENT_RECORD gmr,
QUM_QUANTITY_UNIT_MASTER qum,
QUM_QUANTITY_UNIT_MASTER quminv,
PPU_PRODUCT_PRICE_UNITS ppu,
PUM_PRICE_UNIT_MASTER pum,
GRD_GOODS_RECORD_DETAIL grd,
DGRD_DELIVERED_GRD dgrd,
QAT_QUALITY_ATTRIBUTES qat,
QAT_QUALITY_ATTRIBUTES qat1,
IIED_INV_ITEM_ELEMENT_DETAILS IIED,
AML_ATTRIBUTE_MASTER_LIST AML,
PPU_PRODUCT_PRICE_UNITS PEPU,
PUM_PRICE_UNIT_MASTER PEPUM,
ASH_ASSAY_HEADER ASH,
ASM_ASSAY_SUBLOT_MAPPING ASM,
PQCA_PQ_CHEMICAL_ATTRIBUTES PQCA,
PQCAPD_PRD_QLTY_CATTR_PAY_DTLS pqcapd,
IAM_INVOICE_ASSAY_MAPPING IAM,
RM_RATIO_MASTER rm,
QUM_QUANTITY_UNIT_MASTER QUMIIED
where
INVS.INTERNAL_INVOICE_REF_NO = IID.INTERNAL_INVOICE_REF_NO(+)
and IID.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
and GMR.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
and IID.INVOICED_QTY_UNIT_ID = QUMINV.QTY_UNIT_ID(+)
and IID.NEW_INVOICE_PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID(+)
and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
and IID.STOCK_ID = GRD.INTERNAL_GRD_REF_NO(+)
and IID.STOCK_ID = DGRD.INTERNAL_DGRD_REF_NO(+)
and GRD.QUALITY_ID = QAT.QUALITY_ID(+)
and DGRD.QUALITY_ID = QAT1.QUALITY_ID(+)
AND IIED.INTERNAL_INVOICE_REF_NO = INVS.INTERNAL_INVOICE_REF_NO(+)
AND AML.ATTRIBUTE_ID = IIED.ELEMENT_ID(+)
AND IIED.ELEMENT_PAYABLE_PRICE_UNIT_ID = PEPU.INTERNAL_PRICE_UNIT_ID(+)
AND PEPU.PRICE_UNIT_ID = PEPUM.PRICE_UNIT_ID(+)
AND IAM.INTERNAL_INVOICE_REF_NO = INVS.INTERNAL_INVOICE_REF_NO
AND IAM.ASH_ID = ASH.ASH_ID
AND ASH.ASH_ID = ASM.ASH_ID
AND ASM.ASM_ID = PQCA.ASM_ID
AND IIED.ELEMENT_ID = PQCA.ELEMENT_ID
and PQCA.UNIT_OF_MEASURE = RM.RATIO_ID
and PQCA.PQCA_ID = PQCAPD.PQCA_ID
AND IIED.ELEMENT_INV_QTY_UNIT_ID = QUMIIED.QTY_UNIT_ID
and IIED.GRD_ID = IAM.INTERNAL_GRD_REF_NO
and IIED.GRD_ID = IID.STOCK_ID
and IID.INTERNAL_INVOICE_REF_NO = ?';

fetchQueryPIPenDraft CLOB := 'INSERT INTO IS_CONC_PENALTY_CHILD(
INTERNAL_INVOICE_REF_NO,
PENALTY_AMOUNT,
ELEMENT_NAME,
ELEMENT_ID,
AMOUNT_UNIT,
penalty_qty,
assay_details,
STOCK_REF_NO,
uom,
penalty_rate,
price_name,
wet_qty,
DRY_QUANTITY,
QUANTITY_UOM,
INTERNAL_DOC_REF_NO
)
SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
       iepd.element_penalty_amount AS penalty_amount,
       aml.attribute_name AS element_name, aml.attribute_id AS element_id,
       cm.cur_code AS amount_unit, iepd.element_qty AS penalty_qty,
       pqca.typical AS assay_details, grd.internal_stock_ref_no AS stock_ref_no,
       rm.ratio_name AS uom, iepd.element_penalty_price AS penalty_rate,
       pum.price_unit_name AS price_name, iid.invoiced_qty AS wet_qty,
       ROUND
           ((  iid.invoiced_qty
             - (  iid.invoiced_qty
                * (SELECT pqca_mos.typical
                     FROM pqca_pq_chemical_attributes pqca_mos,
                          aml_attribute_master_list aml_mos,
                          asm_assay_sublot_mapping asm_mos,
                          ash_assay_header ash_mos
                    WHERE pqca_mos.asm_id = asm_mos.asm_id
                      AND ash_mos.ash_id = asm_mos.ash_id
                      AND pqca_mos.element_id = aml_mos.attribute_id
                      AND ash_mos.ash_id = ash.ash_id
                      AND aml_mos.attribute_name = ''H2O'')
                / 100
               )
            ),
            10
           ) AS dry_quantity,
       qum.qty_unit AS quantity_uom, ?
  FROM is_invoice_summary invs,
       iepd_inv_epenalty_details iepd,
       aml_attribute_master_list aml,
       cm_currency_master cm,
       iam_invoice_assay_mapping iam,
       pqca_pq_chemical_attributes pqca,
       ash_assay_header ash,
       asm_assay_sublot_mapping asm,
       grd_goods_record_detail grd,
       rm_ratio_master rm,
       ppu_product_price_units ppu,
       qum_quantity_unit_master qum,
       pum_price_unit_master pum,
       iid_invoicable_item_details iid
 WHERE invs.internal_invoice_ref_no = iepd.internal_invoice_ref_no
   AND iepd.element_id = aml.attribute_id(+)
   AND invs.invoice_cur_id = cm.cur_id
   AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
   AND iam.internal_grd_ref_no = iepd.stock_id
   AND iepd.stock_id = grd.internal_grd_ref_no
   AND aml.attribute_id = pqca.element_id
   AND iam.ash_id = ash.ash_id
   AND ash.ash_id = asm.ash_id
   AND asm.asm_id = pqca.asm_id
   AND asm.net_weight_unit = qum.qty_unit_id
   AND pqca.unit_of_measure = rm.ratio_id
   AND iepd.element_price_unit_id = ppu.internal_price_unit_id
   AND ppu.price_unit_id = pum.price_unit_id
   AND invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
   AND iid.stock_id = iepd.stock_id
   AND invs.internal_invoice_ref_no = ?';


fetchQueryPIBDSDraft CLOB := 'INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction,remarks,internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction,'''' as remarks, ?
     FROM phd_profileheaderdetails phd,
          oba_our_bank_accounts oba,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi  
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oba.bank_id = phd.profileid
      AND oba.bank_id = oipi.bank_id
      and OIPI.BANK_ACCOUNT_ID = OBA.ACCOUNT_ID
      AND invs.internal_invoice_ref_no = ?';


fetchQueryPITCDraft CLOB := 'INSERT INTO IS_CONC_TC_CHILD (
INTERNAL_INVOICE_REF_NO,
TC_AMOUNT,
ELEMENT_ID,
AMOUNT_UNIT,
SUB_LOT_NO,
ELEMENT_NAME,
DRY_QUANTITY,
QUANTITY_UNIT_NAME,
WET_QUANTITY,
moisture,
ESC_DESC_AMOUNT,
BASE_TC,
stock_ref_no,
BASEESCDESC_TYPE,
INTERNAL_DOC_REF_NO
)
SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,SUM (intc.tcharges_amount) AS tc_amount,
         intc.element_id AS element_id, cm.cur_code AS amount_unit,
         intc.sub_lot_no AS sub_lot_no, aml.attribute_name AS element_name,
         SUM (intc.lot_qty) AS dry_qty, qum.qty_unit AS quantity_unit_name,
         SUM (iid.invoiced_qty) AS wet_quantity,
         ROUND (  ((SUM (iid.invoiced_qty) - SUM (intc.lot_qty)) * 100)
                / SUM (iid.invoiced_qty),
                5
               ) AS moisture,
         (SELECT SUM (intc_inner.tcharges_amount)
            FROM intc_inv_treatment_charges intc_inner
           WHERE intc_inner.internal_invoice_ref_no =
                                    invs.internal_invoice_ref_no
             AND intc_inner.grd_id = intc.grd_id
             AND intc_inner.baseescdesc_type = ''Esc/Desc'') AS ESC_DESC_AMOUNT,
         (SELECT SUM (intc_inner.tcharges_amount)
            FROM intc_inv_treatment_charges intc_inner
           WHERE intc_inner.internal_invoice_ref_no =
                                   invs.internal_invoice_ref_no
             AND intc_inner.grd_id = intc.grd_id
             AND intc_inner.baseescdesc_type = ''Base'') AS BASE_TC,
         grd.internal_stock_ref_no AS stock_ref_no,
         stragg (DISTINCT intc.baseescdesc_type) AS BASEESCDESC_TYPE, ?
    FROM is_invoice_summary invs,
         intc_inv_treatment_charges intc,
         cm_currency_master cm,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         aml_attribute_master_list aml,
         grd_goods_record_detail grd,
         qum_quantity_unit_master qum,
         iid_invoicable_item_details iid
   WHERE invs.internal_invoice_ref_no = intc.internal_invoice_ref_no(+)
     AND invs.invoice_cur_id = cm.cur_id(+)
     AND intc.tcharges_price_unit_id = ppu.internal_price_unit_id(+)
     AND ppu.price_unit_id = pum.price_unit_id(+)
     AND intc.element_id = aml.attribute_id
     AND intc.grd_id = grd.internal_grd_ref_no
     AND grd.qty_unit_id = qum.qty_unit_id
     AND iid.internal_invoice_ref_no = invs.internal_invoice_ref_no
     AND iid.stock_id = intc.grd_id
     AND invs.internal_invoice_ref_no = ?
GROUP BY invs.internal_invoice_ref_no,
         intc.element_id,
         cm.cur_code,
         intc.sub_lot_no,
         aml.attribute_name,
         qum.qty_unit,
         grd.internal_stock_ref_no,
         intc.grd_id';


fetchQueryPICPCRDraft CLOB := 'INSERT INTO is_parent_child_d
            (internal_invoice_ref_no, invoice_ref_no, invoice_issue_date,
             due_date, invoice_currency, invoice_amount, prov_pymt_percentage,
             invoice_type_name, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
       invs.invoice_ref_no AS invoice_ref_no,
       invs.invoice_issue_date AS invoice_issue_date,
       invs.payment_due_date AS due_date, cm.cur_code AS invoice_currency,
       (CASE
           WHEN invs.prov_pctg_amt IS NOT NULL
           AND invs.freight_allowance_amt IS NOT NULL
           AND invs.invoice_adjustment_amount IS NOT NULL
              THEN   invs.prov_pctg_amt
                   + invs.freight_allowance_amt
                   + invs.invoice_adjustment_amount
           WHEN invs.prov_pctg_amt IS NOT NULL
           AND invs.invoice_adjustment_amount IS NOT NULL
              THEN invs.prov_pctg_amt + invs.invoice_adjustment_amount
           WHEN invs.prov_pctg_amt IS NOT NULL
           AND invs.freight_allowance_amt IS NOT NULL
                THEN invs.prov_pctg_amt + invs.freight_allowance_amt
           WHEN invs.prov_pctg_amt IS NOT NULL
                THEN invs.prov_pctg_amt
           WHEN invs.prov_pctg_amt IS NULL
           AND invs.freight_allowance_amt IS NOT NULL
           AND invs.invoice_adjustment_amount IS NOT NULL
              THEN   invs.amount_to_pay_before_adj
                   + invs.freight_allowance_amt
                   + invs.invoice_adjustment_amount
           WHEN invs.invoice_adjustment_amount IS NOT NULL
              THEN   invs.amount_to_pay_before_adj
                   + invs.invoice_adjustment_amount
           ELSE invs.amount_to_pay_before_adj
        END
       ) AS invoice_amount,
       NVL (TO_CHAR (invs.provisional_pymt_pctg),
            ''100''
           ) AS prov_pymt_percentage,
       invs.invoice_type_name AS invoice_type_name, ?
  FROM is_invoice_summary invs,
       cpcr_commercial_inv_pc_mapping cpcr,
       cm_currency_master cm
 WHERE cpcr.parent_invoice_ref_no = invs.internal_invoice_ref_no
   AND invs.invoice_cur_id = cm.cur_id
   AND cpcr.internal_invoice_ref_no = ?';


fetchQueryPIIOCDraft CLOB := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, DESCRIPTION, internal_doc_ref_no)
WITH TEST AS
     (SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                      NVL (scm.cost_display_name,
                           pcmac.addn_charge_name
                          ) AS other_charge_cost_name,
                      ioc.charge_type AS charge_type,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          WHEN (ioc.rate_fx_rate IS NULL)
                          AND (ioc.flat_amount_fx_rate IS NULL)
                             THEN 1
                          WHEN ioc.rate_fx_rate IS NULL
                             THEN ioc.flat_amount_fx_rate
                          ELSE ioc.rate_fx_rate
                       END
                      ) AS fx_rate,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE ioc.quantity
                       END
                      ) AS quantity,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE NVL (ioc.rate_amount, ioc.flat_amount)
                       END
                      ) AS amount,
                      ioc.amount_in_inv_cur AS invoice_amount,
                      cm.cur_code AS invoice_cur_name,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          WHEN ioc.rate_price_unit = ''Bags''
                          AND ioc.charge_type = ''Rate''
                             THEN cm.cur_code || ''/'' || ''Bag''
                          WHEN scm.cost_component_name IN
                                 (''Assay Charge'', ''Sampling Charge'',
                                  ''Ocular Inspection Charge'')
                          AND ioc.charge_type = ''Rate''
                             THEN cm_lot.cur_code || ''/'' || ''Lot''
                          ELSE pum.price_unit_name
                       END
                      ) AS rate_price_unit_name,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE NVL (ioc.flat_amount,ioc.rate_charge)
                       END
                      ) AS charge_amount_rate,
                      (CASE
                          WHEN ioc.rate_price_unit = ''Bags''
                             THEN ''Bags''
                          WHEN scm.cost_component_name IN
                                 (''Assay Charge'', ''Sampling Charge'',
                                  ''Ocular Inspection Charge'')
                             THEN ''Lots''
                          WHEN scm.cost_component_name IN
                                            (''AssayCharge'', ''SamplingCharge'')
                             THEN ''Lots''
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE qum.qty_unit
                       END
                      ) AS quantity_unit,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          WHEN scm.cost_component_name IN
                                 (''Assay Charge'',''Sampling Charge'',
                                  ''Ocular Inspection Charge'')
                          AND ioc.charge_type = ''Rate''
                             THEN cm_lot.cur_code
                          WHEN scm.cost_component_name IN (''Handling Charge'')
                             THEN cm.cur_code
                          WHEN ioc.charge_type = ''Rate''
                             THEN cm_pum.cur_code
                          ELSE cm_ioc.cur_code
                       END
                      ) AS amount_unit,
                      IOC.OTHER_CHARGE_DESC as DESCRIPTION,
                      ?
                 FROM is_invoice_summary invs,
                      ioc_invoice_other_charge ioc,
                      cm_currency_master cm,
                      scm_service_charge_master scm,
                      ppu_product_price_units ppu,
                      pum_price_unit_master pum,
                      qum_quantity_unit_master qum,
                      cm_currency_master cm_ioc,
                      cm_currency_master cm_pum,
                      cm_currency_master cm_lot,
                      pcmac_pcm_addn_charges pcmac
                WHERE invs.internal_invoice_ref_no =
                                                   ioc.internal_invoice_ref_no
                  AND ioc.other_charge_cost_id = scm.cost_id(+)
                  AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
                  AND ioc.invoice_cur_id = cm.cur_id(+)
                  AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
                  AND ioc.rate_price_unit = cm_lot.cur_id(+)
                  AND ppu.price_unit_id = pum.price_unit_id(+)
                  AND ioc.qty_unit_id = qum.qty_unit_id(+)
                  AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
                  AND cm_pum.cur_id(+) = pum.cur_id
                  AND ioc.internal_invoice_ref_no = ?)
SELECT *
  FROM TEST t
 WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';


fetchQueryPIRCDraft CLOB := 'INSERT INTO IS_CONC_RC_CHILD(
        INTERNAL_INVOICE_REF_NO,
        RC_AMOUNT,
        ELEMENT_NAME,
        ELEMENT_ID,
        AMOUNT_UNIT,
        SUB_LOT_NO,
        DRY_QUANTITY,
        QUANTITY_UNIT_NAME,
        assay_details,
        rc_es_ds,
        BASE_RC,
        assay_uom,
        STOCK_REF_NO,
        BASEESCDESC_TYPE,
        PAYABLE_QTY,
        PAYABLE_QTY_UNIT,
        INTERNAL_DOC_REF_NO
        )

SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         SUM (inrc.rcharges_amount) AS rc_amount,
         aml.attribute_name AS element_name, aml.attribute_id AS element_id,
         cm.cur_code AS amount_unit, inrc.sub_lot_no AS sub_lot_no,
         inrc.lot_qty AS dry_quantity, qum.qty_unit AS quantity_unit_name,
         pqcapd.payable_percentage AS assay_details,

         (SELECT   SUM (rcharges_amount)
              FROM inrc_inv_refining_charges inrc_inner
             WHERE inrc_inner.internal_invoice_ref_no =
                                invs.internal_invoice_ref_no
               AND inrc_inner.grd_id = inrc.grd_id
               AND inrc_inner.baseescdesc_type = ''Esc/Desc''
               AND inrc_inner.baseescdesc_type <> ''Fixed''
          GROUP BY inrc_inner.element_id) AS rc_es_ds,
         (SELECT   SUM (rcharges_amount)
              FROM inrc_inv_refining_charges inrc_inner
             WHERE inrc_inner.internal_invoice_ref_no =
                                   invs.internal_invoice_ref_no
               AND inrc_inner.grd_id = inrc.grd_id
               AND inrc_inner.baseescdesc_type = ''Base''
          GROUP BY inrc_inner.element_id) AS BASE_RC,
         rm.ratio_name AS assay_uom,
         grd.internal_stock_ref_no AS stock_ref_no,
         stragg (DISTINCT inrc.baseescdesc_type) AS BASEESCDESC_TYPE,
         inrc.payable_qty AS payable_qty,
         NVL (qum_rm.qty_unit, qum.qty_unit) AS PAYABLE_QTY_UNIT,
         ?
    FROM is_invoice_summary invs,
         inrc_inv_refining_charges inrc,
         aml_attribute_master_list aml,
         cm_currency_master cm,
         iam_invoice_assay_mapping iam,
         grd_goods_record_detail grd,
         qum_quantity_unit_master qum,
         ash_assay_header ash,
         asm_assay_sublot_mapping asm,
         pqca_pq_chemical_attributes pqca,
         pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         rm_ratio_master rm,
         qum_quantity_unit_master qum_rm
   WHERE invs.internal_invoice_ref_no = inrc.internal_invoice_ref_no(+)
     AND inrc.element_id = aml.attribute_id(+)
     AND invs.invoice_cur_id = cm.cur_id
     AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
     AND inrc.grd_id = iam.internal_grd_ref_no
     AND iam.internal_grd_ref_no = grd.internal_grd_ref_no
     AND grd.internal_grd_ref_no = inrc.grd_id
     AND grd.qty_unit_id = qum.qty_unit_id
     AND iam.ash_id = ash.ash_id
     AND ash.ash_id = asm.ash_id
     AND asm.asm_id = pqca.asm_id
     AND pqca.pqca_id = pqcapd.pqca_id
     AND pqca.element_id = inrc.element_id
     AND inrc.rcharges_price_unit_id = ppu.internal_price_unit_id
     AND ppu.price_unit_id = pum.price_unit_id
     AND pqca.unit_of_measure = rm.ratio_id
     AND rm.qty_unit_id_numerator = qum_rm.qty_unit_id(+)
     AND invs.internal_invoice_ref_no = ?
GROUP BY invs.internal_invoice_ref_no,
         aml.attribute_name,
         aml.attribute_id,
         cm.cur_code,
         inrc.sub_lot_no,
         qum.qty_unit,
         pqcapd.payable_percentage,
         rm.ratio_name,
         grd.internal_stock_ref_no,
         inrc.grd_id,
         inrc.lot_qty,
         inrc.element_id,
         inrc.payable_qty,
         qum_rm.qty_unit';


fetchQueryPIAPIDDraft CLOB := 'INSERT INTO API_DETAILS_D(
INTERNAL_INVOICE_REF_NO,
API_INVOICE_REF_NO,
API_AMOUNT_ADJUSTED,
INVOICE_CURRENCY,
INTERNAL_DOC_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS_API.INVOICE_REF_NO as API_INVOICE_REF_NO,
CIAPM.API_AMOUNT_ADJUSTED as API_AMOUNT_ADJUSTED,
CM.CUR_CODE as INVOICE_CURRENCY,
?
from
IS_INVOICE_SUMMARY invs,
IS_INVOICE_SUMMARY invs_api,
CIAPM_COMM_INV_ADV_PAY_MAPPING ciapm,
CM_CURRENCY_MASTER cm
where
CIAPM.INTERNAL_INVOICE_REF_NO = INVS.INTERNAL_INVOICE_REF_NO
and CIAPM.API_INTERNAL_INVOICE_REF_NO = INVS_API.INTERNAL_INVOICE_REF_NO
and INVS_API.INVOICE_CUR_ID = CM.CUR_ID
and INVS.INTERNAL_INVOICE_REF_NO = ?';


fetchQueryPIITDDraft CLOB := 'INSERT INTO itd_d
            (internal_invoice_ref_no, tax_code, tax_rate, invoice_currency,
             fx_rate, amount, tax_currency, invoice_amount, applicable_on,
             internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          tm.tax_code AS tax_code, itd.tax_rate AS tax_rate,
          cm.cur_code AS invoice_currency, itd.fx_rate AS fx_rate,
          itd.tax_amount AS amount, cm_tax.cur_code AS tax_currency,
          itd.tax_amount_in_inv_cur AS invoice_amount,
          itd.applicable_on AS applicable_on, ?
     FROM is_invoice_summary invs,
          itd_invoice_tax_details itd,
          tm_tax_master tm,
          cm_currency_master cm,
          cm_currency_master cm_tax
    WHERE invs.internal_invoice_ref_no = itd.internal_invoice_ref_no
      AND itd.tax_code_id = tm.tax_id
      AND itd.invoice_cur_id = cm.cur_id
      AND itd.tax_amount_cur_id = cm_tax.cur_id
      AND itd.internal_invoice_ref_no = ?';


fetchQueryPIIGDDraft CLOB := 'INSERT INTO igd_inv_gmr_details_d
            (internal_invoice_ref_no, gmr_ref_no, container_name,
             mode_of_transport, bl_date, origin_city, origin_country, wet_qty,
             wet_qty_unit_name, dry_qty, dry_qty_unit_name, moisture,
             moisture_unit_name, internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            gmr.gmr_ref_no AS gmr_ref_no,
            (SELECT stragg (DISTINCT agrd.container_no)
               FROM agrd_action_grd agrd
              WHERE agrd.internal_gmr_ref_no =
                                    gmr.internal_gmr_ref_no)
                                                            AS container_name,
            NVL (gmr.mode_of_transport, '''') AS mode_of_transport,
            gmr.bl_date AS bl_date, NVL (cim.city_name, '''') AS origin_city,
            NVL (cym.country_name, '''') AS origin_country,
            gmr.qty AS wet_qty,
            qum.qty_unit AS wet_qty_unit_name,
            gmr.qty - ((gmr.qty * (ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                      / SUM (asm.net_weight))* 100 , 5 ))/100)) as dry_qty,
            qum.qty_unit AS dry_qty_unit_name,
            ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                      / SUM (asm.net_weight))* 100 , 5 ) AS moisture,
            qum.qty_unit AS moisture_unit_name, ?
       FROM is_invoice_summary invs,
            iid_invoicable_item_details iid,
            grd_goods_record_detail grd,
            gmr_goods_movement_record gmr,
            asm_assay_sublot_mapping asm,
            ash_assay_header ash,
            iam_invoice_assay_mapping iam,
            cym_countrymaster cym,
            cim_citymaster cim,
            qum_quantity_unit_master qum
      WHERE iid.internal_invoice_ref_no = invs.internal_invoice_ref_no
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
        AND iid.stock_id = grd.internal_grd_ref_no
        AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
        AND iid.stock_id = iam.internal_grd_ref_no
        AND iam.ash_id = ash.ash_id
        AND ash.ash_id = asm.ash_id
        AND qum.qty_unit_id = asm.net_weight_unit
        AND cym.country_id(+) = gmr.loading_country_id
        AND cim.city_id(+) = gmr.loading_city_id
        AND invs.internal_invoice_ref_no = ?
   GROUP BY gmr.internal_gmr_ref_no,
            gmr.qty,
            invs.internal_invoice_ref_no,
            grd.container_no,
            gmr.mode_of_transport,
            gmr.bl_date,
            gmr.gmr_ref_no,
            cym.country_name,
            cim.city_name,
            qum.qty_unit';

fetchQueryFIIEPDDraft CLOB := 'INSERT INTO iepd_d
            (internal_invoice_ref_no, invoice_amount, delivery_item_ref_no,
             internal_gmr_ref_no, element_id, element_name, fx_rate,
             gmr_ref_no, invoice_cur_name, invoice_price_unit_name,
             adjustment, price, price_fixation_date, price_fixation_ref_no,
             price_in_pay_in_cur, pricing_cur_name, pricing_price_unit_name,
             pricing_type, product_name, qty_priced, qty_unit_name,
             qp_start_date, qp_end_date, qp_period_type, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          iepd.amount_in_pay_in_cur AS invoice_amount,
          iepd.delivery_item_ref_no AS delivery_item_ref_no,
          iepd.internal_gmr_ref_no AS internal_gmr_ref_no,
          iepd.element_id AS element_id, iepd.element_name AS element_name,
          iepd.fx_rate AS fx_rate, gmr.gmr_ref_no AS gmr_ref_no,
          iepd.pay_in_cur_name AS invoice_cur_name,
          iepd.pay_in_price_unit_name AS invoice_price_unit_name,
          iepd.adjustment AS adjustment, iepd.price AS price,
          iepd.price_fixation_date AS price_fixation_date,
          iepd.price_fixation_ref_no AS price_fixation_ref_no,
          iepd.price_in_pay_in_cur AS price_in_pay_in_cur,
          iepd.pricing_cur_name AS pricing_cur_name,
          iepd.pricing_price_unit_name AS pricing_price_unit_name,
          iepd.pricing_type AS pricing_type, pdm.product_desc AS product_name,
          iepd.qty_priced AS qty_priced, iepd.qty_unit_name AS qty_unit_name,
          pofh.qp_start_date AS qp_start_date,
          pofh.qp_end_date AS qp_end_date,
          pfqpp.qp_pricing_period_type AS qp_period_type, ?
     FROM is_invoice_summary invs,
          iepd_inv_ele_pricing_detail iepd,
          pdm_productmaster pdm,
          pofh_price_opt_fixation_header pofh,
          pcbph_pc_base_price_header pcbph,
          pcbpd_pc_base_price_detail pcbpd,
          ppfh_phy_price_formula_header ppfh,
          pfqpp_phy_formula_qp_pricing pfqpp,
          gmr_goods_movement_record gmr
    WHERE invs.internal_invoice_ref_no = iepd.internal_invoice_ref_no
      AND iepd.product_id = pdm.product_id(+)
      AND iepd.pofh_id = pofh.pofh_id(+)
      AND iepd.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
      AND pcbph.internal_contract_ref_no = invs.internal_contract_ref_no
      AND pcbph.element_id = iepd.element_id
      AND pcbph.pcbph_id = pcbpd.pcbph_id
      AND pcbpd.pcbpd_id = ppfh.pcbpd_id
      AND ppfh.ppfh_id = pfqpp.ppfh_id
      AND pcbph.is_active = ''Y''
      AND iepd.internal_invoice_ref_no = ?';

fetchQueryFIIEFPDDraft CLOB := 'INSERT INTO IEFPD_D(
  INTERNAL_INVOICE_REF_NO,
  INTERNAL_GMR_REF_NO,
  GMR_REF_NO,
  ELEMENT_ID,
  ELEMENT_NAME,
  QTY_UNIT_NAME,
  TOTAL_QTY_PRICED,
  WT_AVG_FX_RATE,
  WT_AVG_PRICE_IN_PRICING_CUR,
  PRICING_CUR_NAME,
  WT_AVG_PRICE_IN_PAY_IN_CUR,
  PAY_IN_CUR_NAME,
  INTERNAL_DOC_REF_NO
  )
  select distinct
    INVS.INTERNAL_INVOICE_REF_NO AS INTERNAL_INVOICE_REF_NO,
    GMR.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
    GMR.GMR_REF_NO AS GMR_REF_NO,
    IEFPD.ELEMENT_ID AS ELEMENT_ID,
    IEFPD.ELEMENT_NAME AS ELEMENT_NAME,
    IEFPD.QTY_UNIT_NAME AS QTY_UNIT_NAME,
    IEFPD.TOTAL_QTY_PRICED AS TOTAL_QTY_PRICED,
    IEFPD.WT_AVG_FX_RATE AS WT_AVG_FX_RATE,
    IEFPD.WT_AVG_PRICE_IN_PRICING_CUR AS WT_AVG_PRICE_IN_PRICING_CUR,
    IEFPD.PRICING_CUR_NAME AS PRICING_CUR_NAME, 
    IEFPD.WT_AVG_PRICE_IN_PAY_IN_CUR AS WT_AVG_PRICE_IN_PAY_IN_CUR,
    IEFPD.PAY_IN_CUR_NAME AS PAY_IN_CUR_NAME,
     ?
    from
    IS_INVOICE_SUMMARY invs,
    IEFPD_IEF_PRICING_DETAIL IEFPD,
    GMR_GOODS_MOVEMENT_RECORD GMR
    where
    INVS.INTERNAL_INVOICE_REF_NO = IEFPD.INTERNAL_INVOICE_REF_NO
    AND IEFPD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
    AND IEFPD.INTERNAL_INVOICE_REF_NO = ?';
      
begin
INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_1','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',1,fetchQueryPIISDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_2','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',2,fetchQueryPIPayDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_3','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',3,fetchQueryPITCDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_4','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',4,fetchQueryPIRCDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_5','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',5,fetchQueryPIPenDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_6','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',6,fetchQueryPIBDSDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_7','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',7,fetchQueryPIBDPDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_8','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',8,fetchQueryPICPCRDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_9','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',9,fetchQueryPIIOCDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_10','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',10,fetchQueryPIITDDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_11','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',11,fetchQueryPIAPIDDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_PIC_12','CREATE_DFT_PI','Conc Provisional Invoice Draft','CREATE_DFT_PI',12,fetchQueryPIIGDDraft,'Y');


INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_1','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',1,fetchQueryPIISDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_2','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',2,fetchQueryPIPayDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_3','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',3,fetchQueryPITCDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_4','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',4,fetchQueryPIRCDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_5','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',5,fetchQueryPIPenDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_6','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',6,fetchQueryPIBDSDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_7','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',7,fetchQueryPIBDPDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_8','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',8,fetchQueryPICPCRDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_9','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',9,fetchQueryPIIOCDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_10','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',10,fetchQueryPIITDDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_11','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',11,fetchQueryPIAPIDDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_12','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',12,fetchQueryPIIGDDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_13','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',13,fetchQueryFIIEPDDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_FIC_14','CREATE_DFT_FI','Conc Final Invoice Draft','CREATE_DFT_FI',14,fetchQueryFIIEFPDDraft,'Y');


INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_1','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',1,fetchQueryPIISDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_2','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',2,fetchQueryPIPayDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_3','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',3,fetchQueryPITCDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_4','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',4,fetchQueryPIRCDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_5','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',5,fetchQueryPIPenDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_6','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',6,fetchQueryPIBDSDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_7','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',7,fetchQueryPIBDPDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_8','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',8,fetchQueryPICPCRDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_9','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',9,fetchQueryPIIOCDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_10','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',10,fetchQueryPIITDDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_11','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',11,fetchQueryPIAPIDDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_12','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',12,fetchQueryPIIGDDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_13','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',13,fetchQueryFIIEPDDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_DFIC_14','CREATE_DFT_DFI','Conc Direct Final Invoice Draft','CREATE_DFT_DFI',14,fetchQueryFIIEFPDDraft,'Y');

commit;
end;