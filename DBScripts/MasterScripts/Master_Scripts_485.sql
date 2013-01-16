DECLARE
   fetchqryioc   CLOB
      := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, internal_doc_ref_no)
   WITH TEST AS
     (SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                      NVL (pcmac.addn_charge_name,
                           scm.cost_display_name
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
   fetchqryigd   CLOB
      := 'INSERT INTO igd_inv_gmr_details_d
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
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryioc
    WHERE dgm.doc_id IN ('CREATE_PI', 'CREATE_FI', 'CREATE_DFI')
      AND dgm.is_concentrate = 'Y'
      AND dgm.dgm_id IN ('DGM-IOC_C');

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryigd
    WHERE dgm.doc_id IN ('CREATE_PI', 'CREATE_FI', 'CREATE_DFI')
      AND dgm.is_concentrate = 'Y'
      AND dgm.dgm_id IN ('DGM-PIC-IGD', 'DGM-FIC-IGD', 'DGM-DFIC-IGD');

   COMMIT;
END;
