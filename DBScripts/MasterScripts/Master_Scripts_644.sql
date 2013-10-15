DECLARE fetchQueryDGMOCI CLOB := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, DESCRIPTION, internal_doc_ref_no)
WITH TEST AS
     (SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
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
               CM.CUR_CODE AS amount_unit,
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
            AND invs.internal_invoice_ref_no = ?)
SELECT *
  FROM TEST t
 WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';
         
BEGIN
UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryDGMOCI WHERE DGM.DGM_ID IN ('DGM_OCI_IOC') AND DGM.DOC_ID IN ('CREATE_OCI') AND DGM.SEQUENCE_ORDER IN (2) AND DGM.IS_CONCENTRATE = 'N';

COMMIT;
END;