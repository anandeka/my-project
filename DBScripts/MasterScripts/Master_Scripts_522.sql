declare
fetchQryAPI CLOB := 'INSERT into IOC_D (
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
    SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                scm.cost_display_name AS other_charge_cost_name,
                ioc.charge_type AS charge_type,
                NVL (ioc.rate_fx_rate, ioc.flat_amount_fx_rate) AS fx_rate,
                ioc.quantity AS quantity,
                NVL (ioc.rate_amount, ioc.flat_amount) AS amount,
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
                       THEN nvl(cm_lot.cur_code,cm.cur_code) || ''/'' || ''Lot''
                    ELSE pum.price_unit_name
                 END
                ) AS rate_price_unit_name,
                NVL (ioc.flat_amount, ioc.rate_charge) AS charge_amount_rate,
                qum.qty_unit AS quantity_unit, cm_ioc.cur_code AS amount_unit,
                ioc.other_charge_desc AS description, ?
           FROM is_invoice_summary invs,
                ioc_invoice_other_charge ioc,
                cm_currency_master cm,
                scm_service_charge_master scm,
                ppu_product_price_units ppu,
                pum_price_unit_master pum,
                qum_quantity_unit_master qum,
                cm_currency_master cm_ioc,
                cm_currency_master cm_lot
WHERE           invs.internal_invoice_ref_no = ioc.internal_invoice_ref_no
            AND ioc.other_charge_cost_id = scm.cost_id(+)
            AND ioc.invoice_cur_id = cm.cur_id(+)
            AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
            AND ppu.price_unit_id = pum.price_unit_id(+)
            AND ioc.rate_price_unit = cm_lot.cur_id(+)
            AND ioc.qty_unit_id = qum.qty_unit_id(+)
            AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
            AND ioc.internal_invoice_ref_no = ?';


begin
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryAPI where DGM.DOC_ID IN ('CREATE_API') and DGM.DGM_ID IN ('DGM-API-5-CONC','DGM-API-5') and DGM.SEQUENCE_ORDER = 6;
commit;
end;

