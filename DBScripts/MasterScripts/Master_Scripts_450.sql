DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO IOC_D
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, internal_doc_ref_no)
with test as (SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                   NVL (pcmac.addn_charge_name,
                        scm.cost_display_name
                       ) AS other_charge_cost_name,
                   ioc.charge_type AS charge_type,
                   NVL (ioc.rate_fx_rate, ioc.flat_amount_fx_rate) AS fx_rate,
                   ioc.quantity AS quantity,
                   NVL (ioc.rate_amount, ioc.flat_amount) AS amount,
                   ioc.amount_in_inv_cur AS invoice_amount,
                   cm.cur_code AS invoice_cur_name,
                   (CASE
                       WHEN ioc.rate_price_unit = ''Bags'' and IOC.CHARGE_TYPE = ''Rate''
                          THEN cm.cur_code || ''/'' || ''Bag''
                       WHEN scm.cost_component_name IN
                              (''Assay Charge'', ''Sampling Charge'',
                               ''Ocular Inspection Charge'') and IOC.CHARGE_TYPE = ''Rate''
                          THEN cm.cur_code || ''/'' || ''Lot''
                       ELSE pum.price_unit_name
                    END
                   ) AS rate_price_unit_name,
                   NVL (ioc.flat_amount,
                        ioc.rate_charge
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
                       ELSE qum.qty_unit
                    END
                   ) AS quantity_unit,
                   (case 
                        when scm.cost_component_name IN
                              (''Assay Charge'', ''Sampling Charge'',
                               ''Ocular Inspection Charge'',''Handling Charge'') and IOC.CHARGE_TYPE = ''Rate''
                        then cm.cur_code
                        WHEN IOC.CHARGE_TYPE = ''Rate'' then CM_PUM.CUR_CODE
                        else cm_ioc.cur_code
                        END
                   )AS amount_unit, ?
              FROM is_invoice_summary invs,
                   ioc_invoice_other_charge ioc,
                   cm_currency_master cm,
                   scm_service_charge_master scm,
                   ppu_product_price_units ppu,
                   pum_price_unit_master pum,
                   qum_quantity_unit_master qum,
                   cm_currency_master cm_ioc,
                   CM_CURRENCY_MASTER cm_pum,
                   pcmac_pcm_addn_charges pcmac
             WHERE invs.internal_invoice_ref_no = ioc.internal_invoice_ref_no
               AND ioc.other_charge_cost_id = scm.cost_id(+)
               AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
               AND ioc.invoice_cur_id = cm.cur_id(+)
               AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
               AND ppu.price_unit_id = pum.price_unit_id(+)
               AND ioc.qty_unit_id = qum.qty_unit_id(+)
               AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
               AND CM_PUM.CUR_ID(+) = PUM.CUR_ID
               AND ioc.internal_invoice_ref_no = ?)
               select * from test t where t.other_charge_cost_name not in(''Freight Allowance'')';
         
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqry1
    WHERE dgm.doc_id IN ('CREATE_PI', 'CREATE_DFI', 'CREATE_FI')
      AND dgm.is_concentrate = 'Y'
      AND dgm.sequence_order = 9;
      commit;
      
END;