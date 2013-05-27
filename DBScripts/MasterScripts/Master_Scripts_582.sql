declare fetchQueryIGDInsert CLOB := 'INSERT INTO igd_inv_gmr_details_d
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
         NVL (gmr.mode_of_transport, '''') AS mode_of_transport,
         gmr.bl_date AS bl_date, NVL (cim.city_name, '''') AS origin_city,
         NVL (cym.country_name, '''') AS origin_country, gmr.qty AS wet_qty,
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
         grd.container_no,
         gmr.mode_of_transport,
         gmr.bl_date,
         gmr.gmr_ref_no,
         cym.country_name,
         cim.city_name,
         qum.qty_unit';


begin
INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-PI-BMIGD','CREATE_PI','Provisional Invoice','CREATE_PI',9,fetchQueryIGDInsert,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-FI-BMIGD','CREATE_FI','Final Invoice','CREATE_FI',11,fetchQueryIGDInsert,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-DFI-BMIGD','CREATE_DFI','Direct Final Invoice','CREATE_DFI',11,fetchQueryIGDInsert,'N');

commit;
end;