
DECLARE
   fetchqry1   CLOB
      :='INSERT INTO wns_assay_d_gmr
            (contract_type, buyer, seller, gmr_ref_no, shipment_date,
             arrival_date, bl_no, bl_date, vessel_name, mode_of_transport,
             container_no, senders_ref_no, tare_weight, no_of_pieces,
             qty_unit, internal_doc_ref_no)
   SELECT gmr.contract_type AS contract_type,
          (CASE
              WHEN gmr.contract_type = ''Sales''
                 THEN vpci.cp_name
              ELSE vpci.corporate_name
           END
          ) buyer,
          (CASE
              WHEN gmr.contract_type = ''Purchase''
                 THEN vpci.cp_name
              ELSE vpci.corporate_name
           END
          ) seller,
          gmr.gmr_ref_no AS gmr_ref_no, gmr.eff_date AS shipment_date,
          gmr.arrival_date AS arrival_date, gmr.bl_no AS bl_no,
          gmr.bl_date AS bl_date, gmr.vessel_name AS vessel_name,
          gmr.mode_of_transport AS mode_of_transport,
          grdcontainer.containernostring AS container_no, gmr.senders_ref_no,
          gmr.total_tare_weight, grd.no_of_pieces,
          pkg_general.f_get_quantity_unit (grd.qty_unit_id), ?
     FROM ash_assay_header ash,
          axs_action_summary axs,
          v_pci vpci,
          gmr_goods_movement_record gmr,
          grd_goods_record_detail grd,
          (SELECT   stragg (DISTINCT agrd.container_no) AS containernostring,
                    agrd.internal_gmr_ref_no AS intgmr
               FROM agrd_action_grd agrd
              WHERE agrd.container_no IS NOT NULL
                AND agrd.is_deleted = ''N''
                AND agrd.status = ''Active''
           GROUP BY agrd.internal_gmr_ref_no
           UNION ALL
           SELECT   stragg (dgrd.container_no) AS containernostring,
                    dgrd.internal_gmr_ref_no AS intgmr
               FROM dgrd_delivered_grd dgrd
              WHERE dgrd.container_no IS NOT NULL AND dgrd.status = ''Active''
           GROUP BY dgrd.internal_gmr_ref_no) grdcontainer
    WHERE ash.internal_action_ref_no = axs.internal_action_ref_no
      AND ash.internal_contract_ref_no = vpci.internal_contract_ref_no
      AND gmr.internal_contract_ref_no = vpci.internal_contract_ref_no
      AND ash.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND grdcontainer.intgmr(+) = gmr.internal_gmr_ref_no
      AND grd.internal_contract_item_ref_no =
                                            vpci.internal_contract_item_ref_no
      AND ash.internal_grd_ref_no = grd.internal_grd_ref_no
      AND ash.ash_id = ?';
 BEGIN
   UPDATE dgm_document_generation_master
      SET fetch_query = fetchqry1
    WHERE dgm_id = 'DGM-WNS-GMR' AND activity_id = 'CREATE_WNS_ASSAY';
END;     