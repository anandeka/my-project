DECLARE
   fetchqryigd   CLOB
      := 'INSERT INTO igd_inv_gmr_details_d
            (internal_invoice_ref_no, gmr_ref_no, container_name,
             mode_of_transport, bl_date, origin_city, origin_country, wet_qty,
             wet_qty_unit_name, dry_qty, dry_qty_unit_name, moisture,
             moisture_unit_name, internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            gmr.gmr_ref_no AS gmr_ref_no,
            stragg (DISTINCT grd.container_no) AS container_name,
            NVL (gmr.mode_of_transport, '''') AS mode_of_transport,
            gmr.bl_date AS bl_date, NVL (cim.city_name, '''') AS origin_city,
            NVL (cym.country_name, '''') AS origin_country,
            SUM (asm.net_weight) AS wet_qty,
            qum.qty_unit AS wet_qty_unit_name, SUM (asm.dry_weight)
                                                                   AS dry_qty,
            qum.qty_unit AS dry_qty_unit_name,
            ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                      / SUM (asm.net_weight)
                     )
                   * 100,
                   5
                  ) AS moisture,
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
            
   fetchqrybdp   CLOB
      := 'INSERT INTO is_bdp_child_d
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
      
   fetchqryitd   CLOB
      := 'INSERT INTO itd_d
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
      
BEGIN

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryigd
    WHERE dgm.doc_id IN ('CREATE_DFI', 'CREATE_FI', 'CREATE_PI')
      AND dgm.is_concentrate = 'Y'
      AND dgm.dgm_id IN ('DGM-PIC-IGD', 'DGM-FIC-IGD', 'DGM-DFIC-IGD');

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqrybdp
    WHERE dgm.doc_id IN
             ('CREATE_API', 'CREATE_CFI', 'CREATE_DC', 'CREATE_DFI',
              'CREATE_FI', 'CREATE_OCI', 'CREATE_PFI', 'CREATE_PI',
              'CREATE_SI')
      AND dgm.dgm_id IN
             ('DGM-PI-C4', 'DGM-CFI-C4', 'DGM-SI-2', 'DGM-SIC-2',
              'DGM-PFI-4-CONC', 'DGM-API-3-CONC', 'DGM-PFI-4', 'DGM-API-3',
              'DGM-DFI-C4', 'DGM-FI-C4', 'DGM_OCI_BDP', 'DGM-PIC-C6',
              'DGM-FIC-C6', 'DGM-DFIC-C6');

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryitd
    WHERE dgm.doc_id IN
             ('CREATE_API', 'CREATE_CFI', 'CREATE_DC', 'CREATE_DFI',
              'CREATE_FI', 'CREATE_OCI', 'CREATE_PFI', 'CREATE_PI',
              'CREATE_SI')
      AND dgm.dgm_id IN
             ('DGM-API-4-CONC', 'DGM-API-4', 'DGM-CFI-C6', 'DGM-ITD_BM',
              'DGM-DFI-C6', 'DGM-ITD_C', 'DGM_OCI_ITD', 'DGM-PFI-5-CONC',
              'DGM-PFI-5');
    COMMIT;
END;



