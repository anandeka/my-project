declare
fetchQryISDC CLOB := 'INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_quantity, invoiced_qty_unit, internal_invoice_ref_no,
             invoice_amount, material_cost, addditional_charges, taxes,
             due_date, supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, gmr_finalize_qty, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, contract_type, origin,
             inco_term_location, notify_party, sales_purchase, invoice_status,
             our_person_incharge, internal_comments, is_self_billing, internal_doc_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            invs.invoiced_qty AS invoice_quantity,
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
            stragg(ii.stock_ref_no) AS stock_ref_no,
            cm.cur_code AS invoice_amount_unit, gmr.gmr_ref_no AS gmr_ref_no,
            gmr.qty AS gmr_quality, pcpd.qty_max_val AS contract_quantity,
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
            NVL (akuser.login_name, '''') AS our_person_incharge, INVS.INTERNAL_COMMENTS as internal_comments,pcm.is_self_billing as is_self_billing, ?
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
            ak_corporate_user akuser
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND iid.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND iid.invoicable_item_id = ii.invoicable_item_id
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.invoice_currency_id = cm.cur_id
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
        AND pcm.our_person_in_charge_id = akuser.user_id(+)
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pcpd.pcpd_id = pcpq.pcpd_id
        AND pci.quality_id = qat.quality_id
        AND pcpq.quality_template_id = qat.quality_id
        AND pcpd.product_id = pdm.product_id
        AND pcm.cp_id = phd.profileid
        AND INVS.CREDIT_TERM(+) = pym.payment_term_id
        AND phd.profileid = pad.profile_id(+)
        AND pad.country_id = cym.country_id(+)
        AND pad.city_id = cim.city_id(+)
        AND pad.state_id = sm.state_id(+)
        AND pad.address_type = bpat.bp_address_type_id(+)
        AND cymloading.country_id(+) = gmr.loading_country_id
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.consignee_id = phd1.profileid(+)
        AND sd.consignee_id = phd2.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND pad.is_deleted(+) = ''N''
        AND pad.address_type(+) = ''Billing''
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
            gmr.gmr_ref_no,
            gmr.qty,
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
            akuser.login_name,
            invs.invoice_status,
            INVS.INTERNAL_COMMENTS, is_self_billing';





fetchQryISDCChild CLOB := 'INSERT INTO IS_DC_CONC_CHILD_D(
ELEMENT_ID,
ELEMENT_NAME,
OLD_INVOICED_QTY,
OLD_INVOICED_QTY_UNIT_ID,
OLD_PAYABLE_PRICE,
OLD_PAYABLE_PRICE_UNIT_ID,
OLD_PAYABLE_AMOUNT,
NEW_INVOICED_QTY,
NEW_INVOICED_QTY_UNIT_ID,
NEW_PAYABLE_PRICE,
NEW_PAYABLE_PRICE_UNIT_ID,
NEW_PAYABLE_AMOUNT,
OLD_FX_RATE,
NEW_FX_RATE,
OLD_TC_AMOUNT,
NEW_TC_AMOUNT,
OLD_RC_AMOUNT,
NEW_RC_AMOUNT,
OLD_PENALTY_AMOUNT,
NEW_PENALTY_AMOUNT,
STOCK_REF_NO,
LOT_REF_NO,
AMOUNT_UNIT,
INTERNAL_DOC_REF_NO
)
SELECT iied.element_id AS ELEMENT_ID, aml.attribute_name AS ELEMENT_NAME,
       iied.element_invoiced_qty AS OLD_INVOICED_QTY,
       iied.element_inv_qty_unit_id AS OLD_INVOICED_QTY_UNIT_ID,
       iied.element_payable_price AS OLD_PAYABLE_PRICE,
       iied.element_payable_price_unit_id AS OLD_PAYABLE_PRICE_UNIT_ID,
       iied.element_payable_amount AS OLD_PAYABLE_AMOUNT,
       iied.new_invoiced_qty AS NEW_INVOICED_QTY,
       iied.new_invoiced_qty_unit_id AS NEW_INVOICED_QTY_UNIT_ID,
       iied.new_price AS NEW_PAYABLE_PRICE, iied.new_price_unit_id AS NEW_PAYABLE_PRICE_UNIT_ID,
       iied.new_payable_amount AS NEW_PAYABLE_AMOUNT, iied.fx_rate AS OLD_FX_RATE,
       iied.new_fx_rate AS NEW_FX_RATE, intc.tcharges_amount AS OLD_TC_AMOUNT,
       intc_new.tcharges_amount AS NEW_TC_AMOUNT,
       inrc.rcharges_amount AS OLD_RC_AMOUNT,
       inrc_new.rcharges_amount AS NEW_RC_AMOUNT,
       iepd.element_penalty_amount AS OLD_PENALTY_AMOUNT,
       iepd_new.element_penalty_amount AS NEW_PENALTY_AMOUNT,
       GRD.INTERNAL_STOCK_REF_NO as STOCK_REF_NO,
       IIED.SUB_LOT_NO as LOT_REF_NO, CM.CUR_CODE as AMOUNT_UNIT, ?
  FROM iied_inv_item_element_details iied,
       aml_attribute_master_list aml,
       cpcr_commercial_inv_pc_mapping cpcr,
       intc_inv_treatment_charges intc,
       intc_inv_treatment_charges intc_new,
       inrc_inv_refining_charges inrc,
       inrc_inv_refining_charges inrc_new,
       iepd_inv_epenalty_details iepd,
       iepd_inv_epenalty_details iepd_new,
       GRD_GOODS_RECORD_DETAIL grd,
       CM_CURRENCY_MASTER CM,
       IS_INVOICE_SUMMARY INVS
 WHERE INVS.INTERNAL_INVOICE_REF_NO = IIED.INTERNAL_INVOICE_REF_NO(+)
   AND aml.attribute_id = iied.element_id
   AND iied.internal_invoice_ref_no = cpcr.internal_invoice_ref_no
   AND cpcr.parent_invoice_ref_no = intc.internal_invoice_ref_no(+)
   AND iied.internal_invoice_ref_no = intc_new.internal_invoice_ref_no(+)
   AND cpcr.parent_invoice_ref_no = inrc.internal_invoice_ref_no(+)
   AND iied.internal_invoice_ref_no = inrc_new.internal_invoice_ref_no(+)
   AND cpcr.parent_invoice_ref_no = iepd.internal_invoice_ref_no(+)
   AND iied.internal_invoice_ref_no = iepd_new.internal_invoice_ref_no(+)
   AND IIED.GRD_ID = GRD.INTERNAL_GRD_REF_NO
   AND INVS.INVOICE_CUR_ID = CM.CUR_ID(+)
   AND INVS.INTERNAL_INVOICE_REF_NO = ?';




fetchQryIOCDC CLOB := 'INSERT into IOC_D (
    INTERNAL_INVOICE_REF_NO,
    OTHER_CHARGE_COST_NAME,
    CHARGE_TYPE,
    FX_RATE,
    QUANTITY,
    AMOUNT,
    INVOICE_AMOUNT,
    INVOICE_CUR_NAME,
    RATE_PRICE_UNIT_NAME,
    CHARGE_AMOUNT_RATE,
    QUANTITY_UNIT,
    AMOUNT_UNIT,
    DESCRIPTION,
    INTERNAL_DOC_REF_NO
    )
    select 
    INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
    SCM.COST_DISPLAY_NAME as OTHER_CHARGE_COST_NAME,
    IOC.CHARGE_TYPE as CHARGE_TYPE,
    nvl(IOC.RATE_FX_RATE, IOC.FLAT_AMOUNT_FX_RATE) as FX_RATE,
    IOC.QUANTITY as QUANTITY,
    nvl(IOC.RATE_AMOUNT, IOC.FLAT_AMOUNT) as AMOUNT,
    IOC.AMOUNT_IN_INV_CUR as INVOICE_AMOUNT,
    CM.CUR_CODE as INVOICE_CUR_NAME,
    PUM.PRICE_UNIT_NAME as RATE_PRICE_UNIT_NAME,
    nvl(IOC.FLAT_AMOUNT, IOC.RATE_CHARGE) as CHARGE_AMOUNT_RATE,
    QUM.QTY_UNIT as QUANTITY_UNIT,
    CM_IOC.CUR_CODE as AMOUNT_UNIT,
    IOC.OTHER_CHARGE_DESC as DESCRIPTION,
    ?
    from
    IS_INVOICE_SUMMARY invs,
    IOC_INVOICE_OTHER_CHARGE ioc,
    CM_CURRENCY_MASTER cm,
    SCM_SERVICE_CHARGE_MASTER scm,
    PPU_PRODUCT_PRICE_UNITS ppu,
    PUM_PRICE_UNIT_MASTER pum,
    QUM_QUANTITY_UNIT_MASTER qum,
    CM_CURRENCY_MASTER cm_ioc
    where
    INVS.INTERNAL_INVOICE_REF_NO = IOC.INTERNAL_INVOICE_REF_NO
    and IOC.OTHER_CHARGE_COST_ID = SCM.COST_ID
    and IOC.INVOICE_CUR_ID = CM.CUR_ID
    and IOC.RATE_PRICE_UNIT = PPU.INTERNAL_PRICE_UNIT_ID(+)
    and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
    and IOC.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
    and IOC.FLAT_AMOUNT_CUR_UNIT_ID = CM_IOC.CUR_ID(+)
    and IOC.INTERNAL_INVOICE_REF_NO = ?';




fetchQryITDDC CLOB := 'INSERT INTO itd_d
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



fetchQryIGDDC CLOB := 'INSERT INTO igd_inv_gmr_details_d
            (internal_invoice_ref_no, gmr_ref_no, container_name,
             mode_of_transport, bl_date, origin_city, origin_country, wet_qty,
             wet_qty_unit_name, dry_qty, dry_qty_unit_name, moisture,
             moisture_unit_name, internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            gmr.gmr_ref_no AS gmr_ref_no,
            stragg (grd.container_no) AS container_name,
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



begin
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DC-CONC', 'CREATE_DC', 'Debit Credit', 'CREATE_DC', 1,fetchQryISDC,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-DC-CONC-C1', 'CREATE_DC', 'Debit Credit', 'CREATE_DC', 2,fetchQryISDCChild,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-IOC-CONC', 'CREATE_DC', 'Debit Credit', 'CREATE_DC', 3,fetchQryIOCDC,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-ITD-CONC', 'CREATE_DC', 'Debit Credit', 'CREATE_DC', 4,fetchQryITDDC,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-FIC-IGD-CONC', 'CREATE_DC', 'Debit Credit', 'CREATE_DC', 5,fetchQryIGDDC,'Y');
    commit;
end;