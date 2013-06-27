declare fetchQueryIGDConc clob :='INSERT INTO igd_inv_gmr_details_d
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
         stragg(distinct(NVL (gmr.mode_of_transport, ''''))) AS mode_of_transport,
         gmr.bl_date AS bl_date, stragg(distinct(NVL (cim.city_name, ''''))) AS origin_city,
         stragg(distinct(NVL (cym.country_name, ''''))) AS origin_country,
         gmr.current_qty AS wet_qty, qum.qty_unit AS wet_qty_unit_name,
           gmr.current_qty
         - ((  gmr.current_qty
             * (ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                          / SUM (asm.net_weight)
                         )
                       * 100,
                       5
                      )
               )
             / 100
            )
           ) AS dry_qty,
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
         dgrd_delivered_grd dgrd,
         gmr_goods_movement_record gmr,
         asm_assay_sublot_mapping asm,
         ash_assay_header ash,
         iam_invoice_assay_mapping iam,
         cym_countrymaster cym,
         cim_citymaster cim,
         qum_quantity_unit_master qum
   WHERE iid.internal_invoice_ref_no = invs.internal_invoice_ref_no
     AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     AND iid.stock_id = grd.internal_grd_ref_no(+)
     AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
     AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
     AND iid.stock_id = iam.internal_grd_ref_no
     AND iam.ash_id = ash.ash_id
     AND ash.ash_id = asm.ash_id
     AND qum.qty_unit_id = asm.net_weight_unit
     AND cym.country_id(+) = gmr.loading_country_id
     AND cim.city_id(+) = gmr.loading_city_id
     AND invs.internal_invoice_ref_no = ?
GROUP BY gmr.internal_gmr_ref_no,
         gmr.current_qty,
         invs.internal_invoice_ref_no,
         gmr.bl_date,
         gmr.gmr_ref_no,
         qum.qty_unit';

fetchQueryIGDBase clob:='INSERT INTO igd_inv_gmr_details_d
            (internal_invoice_ref_no, gmr_ref_no, container_name,
             mode_of_transport, bl_date, origin_city, origin_country, wet_qty,
             wet_qty_unit_name, internal_doc_ref_no)
SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         gmr.gmr_ref_no AS gmr_ref_no,
         (SELECT stragg (DISTINCT agrd.container_no)
            FROM agrd_action_grd agrd
           WHERE agrd.internal_gmr_ref_no =
                                    gmr.internal_gmr_ref_no)
                                                            AS container_name,
         stragg(distinct(NVL (gmr.mode_of_transport, ''''))) AS mode_of_transport,
         gmr.bl_date AS bl_date, stragg(distinct(NVL (cim.city_name, ''''))) AS origin_city,
         stragg(distinct(NVL (cym.country_name, ''''))) AS origin_country, gmr.qty AS wet_qty,
         qum.qty_unit AS wet_qty_unit_name, ?
    FROM is_invoice_summary invs,
         iid_invoicable_item_details iid,
         grd_goods_record_detail grd,
         dgrd_delivered_grd dgrd,
         gmr_goods_movement_record gmr,
         cym_countrymaster cym,
         cim_citymaster cim,
         qum_quantity_unit_master qum
   WHERE iid.internal_invoice_ref_no = invs.internal_invoice_ref_no
     AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     AND iid.stock_id = grd.internal_grd_ref_no(+)
     AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
     AND invs.invoiced_qty_unit_id = qum.qty_unit_id
     AND cym.country_id(+) = gmr.loading_country_id
     AND cim.city_id(+) = gmr.loading_city_id
     AND invs.internal_invoice_ref_no = ?
GROUP BY gmr.internal_gmr_ref_no,
         gmr.qty,
         invs.internal_invoice_ref_no,
         gmr.bl_date,
         gmr.gmr_ref_no,
         qum.qty_unit';
BEGIN
UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM set DGM.FETCH_QUERY=fetchQueryIGDConc WHERE DGM.DGM_ID IN ('DGM-DFIC-IGD','DGM-FIC-IGD','DGM-PIC-IGD') AND DGM.DOC_ID IN ('CREATE_DFI','CREATE_FI','CREATE_PI') AND DGM.SEQUENCE_ORDER = '12' AND DGM.IS_CONCENTRATE = 'Y';

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM set DGM.FETCH_QUERY=fetchQueryIGDBase WHERE DGM.DGM_ID IN ('DGM-PI-BMIGD') AND DGM.DOC_ID IN ('CREATE_PI') AND DGM.SEQUENCE_ORDER = '9' AND DGM.IS_CONCENTRATE = 'N';

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM set DGM.FETCH_QUERY=fetchQueryIGDBase WHERE DGM.DGM_ID IN ('DGM-FI-BMIGD','DGM-DFI-BMIGD') AND DGM.DOC_ID IN ('CREATE_FI','CREATE_DFI') AND DGM.SEQUENCE_ORDER = '11' AND DGM.IS_CONCENTRATE = 'N';

END;
COMMIT;
