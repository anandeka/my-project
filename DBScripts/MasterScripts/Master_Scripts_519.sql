declare
fetchQryIOCOCI CLOB := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, description, quantity_unit,
             amount_unit, internal_doc_ref_no)
   WITH TEST AS
        (SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                (CASE
                    WHEN (pcmac.addn_charge_name IS NULL)
                    AND (scm.cost_display_name IS NULL)
                       THEN mcc.charge_name
                    WHEN pcmac.addn_charge_name IS NULL
                       THEN scm.cost_display_name
                    ELSE pcmac.addn_charge_name
                 END
                ) AS other_charge_cost_name,
                ioc.charge_type AS charge_type,
                (CASE
                    WHEN (ioc.rate_fx_rate IS NULL)
                    AND (ioc.flat_amount_fx_rate IS NULL)
                       THEN 1
                    WHEN ioc.rate_fx_rate IS NULL
                       THEN ioc.flat_amount_fx_rate
                    ELSE ioc.rate_fx_rate
                 END
                ) AS fx_rate,
                ioc.quantity AS quantity,
                NVL (ioc.rate_amount, ioc.flat_amount) AS amount,
                ioc.amount_in_inv_cur AS invoice_amount,
                cm.cur_code AS invoice_cur_name,
                (CASE
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
                NVL (ioc.flat_amount, ioc.rate_charge) AS charge_amount_rate,
                NVL (ioc.other_charge_desc,
                     aml.attribute_name) AS description,
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
                    ELSE qum.qty_unit
                 END
                ) AS quantity_unit,
                (CASE
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
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
                pcmac_pcm_addn_charges pcmac,
                mcc_miscellaneous_comm_charges mcc,
                aml_attribute_master_list aml
          WHERE invs.internal_invoice_ref_no = ioc.internal_invoice_ref_no
            AND ioc.other_charge_cost_id = scm.cost_id(+)
            AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
            AND ioc.other_charge_cost_id IN (
                   SELECT mcc.mcc_id
                     FROM mcc_miscellaneous_comm_charges mcc
                   UNION ALL
                   SELECT mcc.charge_id
                     FROM mcc_miscellaneous_comm_charges mcc)
            AND mcc.element_id = aml.attribute_id(+)
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


begin
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryIOCOCI where DGM.DOC_ID IN ('CREATE_OCI') and DGM.DGM_ID IN ('DGM_OCI_IOC') and DGM.IS_CONCENTRATE = 'N' and DGM.SEQUENCE_ORDER = 2;
commit;
end;