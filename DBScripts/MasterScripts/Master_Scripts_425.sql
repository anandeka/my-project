
DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO as_assay_d
            (internal_contract_item_ref_no, assay_refno, internal_gmr_ref_no,
             contract_type, activity_date, ship_land_date, buyer, seller,
             our_contract_ref_no, cp_contract_ref_no, gmr_ref_no,
             shipment_date, weighing_and_sampling_ref_no, product_and_quality,
             assayer, assay_type, exchange_of_assays, lot_no, no_of_sublots,
             bl_no, bl_date, vessel_name, mode_of_transport, container_no,
             cp_address, internal_doc_ref_no)
   SELECT vpci.internal_contract_item_ref_no AS internal_contract_item_ref_no,
          ash.assay_ref_no AS assay_refno,
          ash.internal_gmr_ref_no AS internal_gmr_ref_no,
          gmr.contract_type AS contract_type, axs.eff_date AS activity_date,
          (CASE
              WHEN ash.assay_type = ''Provisional Assay''
                 THEN (SELECT vd.loading_date
                         FROM vd_voyage_detail vd
                        WHERE vd.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
              ELSE (CASE
                       WHEN (SELECT agmr.action_no AS actionno
                               FROM agmr_action_gmr agmr
                              WHERE agmr.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no
                                AND agmr.is_deleted = ''N''
                                AND agmr.is_final_weight = ''Y'') = 1
                          THEN (SELECT vd.loading_date
                                  FROM vd_voyage_detail vd
                                 WHERE vd.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
                       ELSE (SELECT wrd.storage_date
                               FROM wrd_warehouse_receipt_detail wrd
                              WHERE wrd.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
                    END
                   )
           END
          ) ship_land_date,
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
          vpci.contract_ref_no AS our_contract_ref_no,
          vpci.cp_contract_ref_no AS cp_contract_ref_no,
          gmr.gmr_ref_no AS gmr_ref_no, gmr.eff_date AS shipment_date,
          (SELECT ash1.assay_ref_no
             FROM ash_assay_header ash1
            WHERE ash1.assay_type =
                     ''Weighing and Sampling Assay''
              AND ash1.is_active = ''Y''
              AND ash1.is_delete = ''N''
              AND ash1.internal_contract_ref_no =
                                                 vpci.internal_contract_ref_no
              AND ash1.internal_gmr_ref_no = gmr.internal_gmr_ref_no
              AND ash1.internal_grd_ref_no = ash.internal_grd_ref_no)
                                                 weighing_and_sampling_ref_no,
          (vpci.product_name || '','' || vpci.quality_name
          ) product_and_quality,
          bgm.bp_group_name AS assayer,
          (CASE
              WHEN ash.assay_type = ''Self Assay''
                 THEN CONCAT (vpci.corporate_name, '' Assay'')
              ELSE (CASE
                       WHEN ash.assay_type = ''CounterParty Assay''
                          THEN CONCAT (vpci.cp_name, '' Assay'')
                       ELSE ash.assay_type
                    END
                   )
           END
          ) AS assay_type,
          ash.use_for_finalization AS exchange_of_assays,
          ash.lot_no AS lot_no, ash.no_of_sublots AS no_of_sublots,
          gmr.bl_no AS bl_no, gmr.bl_date AS bl_date,
          gmr.vessel_name AS vessel_name,
          gmr.mode_of_transport AS mode_of_transport,
          grdcontainer.containernostring AS container_no,
          (SELECT    pad.address
                  || '' ''
                  || cim.city_name
                  || '' ''
                  || sm.state_name
                  || '' ''
                  || cym.country_name
             FROM pad_profile_addresses pad,
                  cym_countrymaster cym,
                  cim_citymaster cim,
                  sm_state_master sm
            WHERE pad.profile_id = vpci.cp_id
              AND pad.address_type = ''Main''
              AND pad.is_deleted = ''N''
              AND pad.country_id = cym.country_id
              AND pad.state_id = sm.state_id(+)
              AND pad.city_id = cim.city_id(+)) AS cp_address,
          ?
     FROM ash_assay_header ash,
          axs_action_summary axs,
          v_pci vpci,
          gmr_goods_movement_record gmr,
          bgm_bp_group_master bgm,
          (SELECT   stragg (grd.container_no) AS containernostring,
                    grd.internal_gmr_ref_no AS intgmr
               FROM grd_goods_record_detail grd
              WHERE grd.container_no IS NOT NULL
                AND grd.is_deleted = ''N''
                AND grd.status = ''Active''
           GROUP BY grd.internal_gmr_ref_no
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
      AND bgm.bp_group_id(+) = ash.assayer
      AND ash.ash_id = ?';
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqry1
    WHERE dgm.dgm_id = 'DGM-AS';

   COMMIT;
END;