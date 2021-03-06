
DECLARE
   fetchqueryfor_wns_assay_d_gmr     CLOB
      := 'INSERT INTO wns_assay_d_gmr
            (contract_type, buyer, seller, gmr_ref_no, shipment_date,
             arrival_date, bl_no, bl_date, vessel_name, mode_of_transport,
             container_no, senders_ref_no, tare_weight, no_of_pieces,
             qty_unit, smelter_location, supplier_representative, internal_doc_ref_no)
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
          gmr.arrival_date AS arrival_date,
          CASE
             WHEN gmr.bl_no IS NULL
                THEN gmr.warehouse_receipt_no
             ELSE gmr.bl_no
          END bl_no,
          CASE
             WHEN gmr.bl_date IS NULL
                THEN gmr.eff_date
             ELSE gmr.bl_date
          END bl_date, gmr.vessel_name AS vessel_name,
          gmr.mode_of_transport AS mode_of_transport,
          grdcontainer.containernostring AS container_no, gmr.senders_ref_no,
          (SELECT SUM (agrd.tare_weight)
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                 gmr.internal_gmr_ref_no
              AND agrd.internal_gmr_ref_no = ash.internal_gmr_ref_no
              AND agrd.action_no IN (
                     SELECT MAX (agrd1.action_no)
                       FROM agrd_action_grd agrd1
                      WHERE agrd1.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no
                        AND agrd1.status = ''Active'')) AS total_tare_weight,
          (SELECT SUM (agrd.no_of_pieces)
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                      gmr.internal_gmr_ref_no
              AND agrd.internal_gmr_ref_no = ash.internal_gmr_ref_no
              AND agrd.action_no IN (
                     SELECT MAX (agrd1.action_no)
                       FROM agrd_action_grd agrd1
                      WHERE agrd1.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no
                        AND agrd1.status = ''Active'')) AS no_of_pieces,
          pkg_general.f_get_quantity_unit (grd.qty_unit_id),
          phd.companyname as smelter_location, fn_get_supplier_representative(gmr.internal_gmr_ref_no) as supplier_representative, ?
     FROM ash_assay_header ash,
          axs_action_summary axs,
          v_pci vpci,
          gmr_goods_movement_record gmr,
          phd_profileheaderdetails phd,
          grd_goods_record_detail grd,
          (SELECT DISTINCT f_string_aggregate
                                   (agrd.container_no || ''^''
                                   ) AS containernostring,
                           agrd.internal_gmr_ref_no AS intgmr
                      FROM agrd_action_grd agrd
                     WHERE agrd.container_no IS NOT NULL
                       AND agrd.is_deleted = ''N''
                       AND agrd.status = ''Active''
                  GROUP BY agrd.internal_gmr_ref_no
           UNION ALL
           SELECT DISTINCT f_string_aggregate
                                   (dgrd.container_no || ''^''
                                   ) AS containernostring,
                           dgrd.internal_gmr_ref_no AS intgmr
                      FROM dgrd_delivered_grd dgrd
                     WHERE dgrd.container_no IS NOT NULL
                       AND dgrd.status = ''Active''
                  GROUP BY dgrd.internal_gmr_ref_no) grdcontainer
    WHERE ash.internal_action_ref_no = axs.internal_action_ref_no
      AND ash.internal_contract_ref_no = vpci.internal_contract_ref_no
      AND gmr.internal_contract_ref_no = vpci.internal_contract_ref_no
      AND ash.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND grdcontainer.intgmr(+) = gmr.internal_gmr_ref_no
      AND grd.internal_contract_item_ref_no =
                                            vpci.internal_contract_item_ref_no
      AND ash.internal_grd_ref_no = grd.internal_grd_ref_no
      AND phd.profileid(+) = gmr.warehouse_profile_id
      AND ash.ash_id = ?
   UNION ALL
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
          gmr.arrival_date AS arrival_date,
          CASE
             WHEN gmr.bl_no IS NULL
                THEN gmr.warehouse_receipt_no
             ELSE gmr.bl_no
          END bl_no,
          CASE
             WHEN gmr.bl_date IS NULL
                THEN gmr.eff_date
             ELSE gmr.bl_date
          END bl_date, gmr.vessel_name AS vessel_name,
          gmr.mode_of_transport AS mode_of_transport,
          grdcontainer.containernostring AS container_no, gmr.senders_ref_no,
          (SELECT SUM (agrd.tare_weight)
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                 gmr.internal_gmr_ref_no
              AND agrd.internal_gmr_ref_no = ash.internal_gmr_ref_no
              AND agrd.action_no IN (
                     SELECT MAX (agrd1.action_no)
                       FROM agrd_action_grd agrd1
                      WHERE agrd1.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no
                        AND agrd1.status = ''Active'')) AS total_tare_weight,
          (SELECT SUM (agrd.no_of_pieces)
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                      gmr.internal_gmr_ref_no
              AND agrd.internal_gmr_ref_no = ash.internal_gmr_ref_no
              AND agrd.action_no IN (
                     SELECT MAX (agrd1.action_no)
                       FROM agrd_action_grd agrd1
                      WHERE agrd1.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no
                        AND agrd1.status = ''Active'')) AS no_of_pieces,
          pkg_general.f_get_quantity_unit (dgrd.net_weight_unit_id),
          phd.companyname AS smelter_location, fn_get_supplier_representative(gmr.internal_gmr_ref_no) as supplier_representative,?
     FROM ash_assay_header ash,
          axs_action_summary axs,
          v_pci vpci,
          gmr_goods_movement_record gmr,
          phd_profileheaderdetails phd,
          dgrd_delivered_grd dgrd,
         (SELECT distinct  F_STRING_AGGREGATE(agrd.container_no||''^'')AS  containernostring,
                    agrd.internal_gmr_ref_no AS intgmr
               FROM ADGRD_ACTION_DGRD agrd
              WHERE agrd.container_no IS NOT NULL
                   AND agrd.status = ''Active''
           GROUP BY AGRD.INTERNAL_GMR_REF_NO
           UNION ALL
           SELECT distinct  F_STRING_AGGREGATE(dgrd.container_no||''^'')AS  containernostring,
                    dgrd.internal_gmr_ref_no AS intgmr
               FROM dgrd_delivered_grd dgrd
              WHERE dgrd.container_no IS NOT NULL AND dgrd.status = ''Active''
           GROUP BY dgrd.internal_gmr_ref_no) grdcontainer
    WHERE ash.internal_action_ref_no = axs.internal_action_ref_no
      AND ash.internal_contract_ref_no = vpci.internal_contract_ref_no
      AND gmr.internal_contract_ref_no = vpci.internal_contract_ref_no
      AND ash.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND grdcontainer.intgmr(+) = gmr.internal_gmr_ref_no
      AND dgrd.internal_contract_item_ref_no =
                                            vpci.internal_contract_item_ref_no
      AND ash.internal_grd_ref_no = dgrd.internal_dgrd_ref_no
      AND phd.profileid(+) = gmr.warehouse_profile_id
      AND ash.ash_id = ?';
  
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqueryfor_wns_assay_d_gmr
    WHERE dgm.doc_id = 'CREATE_WNS_ASSAY'
      AND dgm.dgm_id = 'DGM-WNS-GMR'
      AND dgm.sequence_order = 2;

   COMMIT;
END;