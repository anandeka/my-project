declare fetchQueryIOC clob :='INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, DESCRIPTION, internal_doc_ref_no)
SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                NVL (scm.cost_display_name,
                     mcc.charge_name
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
                            ''Ocular Inspection Charge'', ''Small Lot Charges'')
                    AND ioc.charge_type = ''Rate''
                       THEN cm.cur_code || ''/'' || ''Lot''
                    ELSE pum.price_unit_name
                 END
                ) AS rate_price_unit_name,
                (CASE
                    WHEN (scm.cost_display_name = ''Location Value'')
                       THEN NULL
                    ELSE NVL (ioc.flat_amount, ioc.rate_charge)
                 END
                ) AS charge_amount_rate,
                (CASE
                    WHEN ioc.rate_price_unit = ''Bags''
                       THEN ''Bags''
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
                            ''Ocular Inspection Charge'', ''Small Lot Charges'')
                       THEN ''Lots''
                    WHEN scm.cost_component_name IN
                                            (''AssayCharge'', ''SamplingCharge'')
                       THEN ''Lots''
                    WHEN (scm.cost_display_name = ''Location Value'')
                       THEN NULL
                    ELSE qum.qty_unit
                 END
                ) AS quantity_unit,
               CM.CUR_NAME AS amount_unit,
                ioc.other_charge_desc AS description, ?
           FROM mcc_miscellaneous_comm_charges mcc,
                is_invoice_summary invs,
                ioc_invoice_other_charge ioc,
                cm_currency_master cm,
                qum_quantity_unit_master qum,
                ppu_product_price_units ppu,
                pum_price_unit_master pum,
                scm_service_charge_master scm
          WHERE invs.internal_invoice_ref_no = ioc.internal_invoice_ref_no
            AND ioc.other_charge_cost_id = mcc.mcc_id(+)
            AND invs.invoice_cur_id = cm.cur_id
            AND ioc.qty_unit_id = qum.qty_unit_id(+)
            AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
            AND ppu.price_unit_id = pum.price_unit_id(+)
            AND ioc.other_charge_cost_id = scm.cost_id(+)
            AND invs.internal_invoice_ref_no = ?';

fetchQueryTCChild clob:='INSERT INTO IS_CONC_TC_CHILD (
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
SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         SUM (intc.tcharges_amount) AS tc_amount,
         intc.element_id AS element_id, cm.cur_code AS amount_unit,
         intc.sub_lot_no AS sub_lot_no, aml.attribute_name AS element_name,
         SUM (distinct intc.lot_qty) AS dry_qty,
         NVL (qum.qty_unit, qum_dgrd.qty_unit) AS quantity_unit_name,
         SUM (distinct iid.invoiced_qty) AS wet_quantity,
         ROUND (  ((SUM (iid.invoiced_qty) - SUM (intc.lot_qty)) * 100)
                / SUM (iid.invoiced_qty),
                5
               ) AS moisture,
         (SELECT SUM (intc_inner.tcharges_amount)
            FROM intc_inv_treatment_charges intc_inner
           WHERE intc_inner.internal_invoice_ref_no =
                              invs.internal_invoice_ref_no
             AND intc_inner.grd_id = intc.grd_id
             AND intc_inner.baseescdesc_type = ''Esc/Desc''
             AND intc_inner.element_id = intc.element_id) AS esc_desc_amount,
         (SELECT SUM (intc_inner.tcharges_amount)
            FROM intc_inv_treatment_charges intc_inner
           WHERE intc_inner.internal_invoice_ref_no =
                                      invs.internal_invoice_ref_no
             AND intc_inner.grd_id = intc.grd_id
             AND intc_inner.baseescdesc_type = ''Base''
             AND intc_inner.element_id = intc.element_id) AS base_tc,
         grd.internal_stock_ref_no AS stock_ref_no,
         stragg (DISTINCT intc.baseescdesc_type) AS baseescdesc_type, ?
    FROM is_invoice_summary invs,
         intc_inv_treatment_charges intc,
         cm_currency_master cm,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         aml_attribute_master_list aml,
         grd_goods_record_detail grd,
         dgrd_delivered_grd dgrd,
         qum_quantity_unit_master qum,
         iid_invoicable_item_details iid,
         qum_quantity_unit_master qum_dgrd
   WHERE invs.internal_invoice_ref_no = intc.internal_invoice_ref_no(+)
     AND invs.invoice_cur_id = cm.cur_id(+)
     AND intc.tcharges_price_unit_id = ppu.internal_price_unit_id(+)
     AND ppu.price_unit_id = pum.price_unit_id(+)
     AND intc.element_id = aml.attribute_id
     AND intc.grd_id = grd.internal_grd_ref_no(+)
     AND intc.grd_id = dgrd.internal_dgrd_ref_no(+)
     AND grd.qty_unit_id = qum.qty_unit_id(+)
     AND dgrd.net_weight_unit_id = qum_dgrd.qty_unit_id(+)
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
         intc.grd_id,
         qum_dgrd.qty_unit';
BEGIN
UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM set DGM.FETCH_QUERY=fetchQueryIOC WHERE DGM.DGM_ID='DGM_OCI_IOC' AND DGM.DOC_ID='CREATE_OCI';

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM set DGM.FETCH_QUERY=fetchQueryTCChild WHERE DGM.FETCH_QUERY LIKE '%TC_CHILD%';
END;
COMMIT;
