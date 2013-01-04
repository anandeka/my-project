
DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO as_assay_d
            (internal_contract_item_ref_no, assay_refno, internal_gmr_ref_no,
             contract_type, activity_date, ship_land_date, buyer, seller,
             our_contract_ref_no, cp_contract_ref_no, gmr_ref_no,
             shipment_date, weighing_and_sampling_ref_no, product_and_quality,
             assayer, assay_type, exchange_of_assays, lot_no, no_of_sublots,
             bl_no, bl_date, vessel_name, mode_of_transport, container_no,
             cp_address, comments, internal_doc_ref_no)
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
                             AND agmr.is_final_weight = ''Y''
                             AND agmr.action_no = 1) = 1
                       THEN (SELECT vd.loading_date
                               FROM vd_voyage_detail vd
                              WHERE vd.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
                    ELSE (SELECT wrd.storage_date
                            FROM wrd_warehouse_receipt_detail wrd,
                                 agmr_action_gmr agmr
                           WHERE wrd.internal_gmr_ref_no =
                                                      agmr.internal_gmr_ref_no
                             AND agmr.action_no = wrd.action_no
                             AND agmr.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no
                             AND agmr.is_deleted = ''N'')
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
           AND grd.internal_contract_item_ref_no =
                                            vpci.internal_contract_item_ref_no
           AND ash1.internal_grd_ref_no = grd.internal_grd_ref_no)
                                                 weighing_and_sampling_ref_no,
       (vpci.product_name || '','' || vpci.quality_name) product_and_quality,
       phd.companyname AS assayer, ash.assay_type AS assay_type,
       ash.use_for_finalization AS exchange_of_assays, ash.lot_no AS lot_no,
       CASE
          WHEN ash.is_sublots_as_stock = ''Y''
          AND ash.assay_type <> ''Final Assay''
             THEN (SELECT COUNT (*)
                     FROM ash_assay_header ash1
                    WHERE ash1.is_active = ''Y''
                      AND ash1.wns_group_id = ash.wns_group_id
                      AND ash1.assay_type = ''Weighing and Sampling Assay''
                      AND ash1.is_sublots_as_stock = ''Y'')
          WHEN ash.is_sublots_as_stock = ''Y''
               AND ash.assay_type = ''Final Assay''
             THEN (SELECT COUNT (*)
                     FROM ash_assay_header ash2
                    WHERE ash2.wnsrefno = ash.wnsrefno
             AND ash2.assay_type = ''Final Assay''
                      AND ash2.is_sublots_as_stock = ''Y'')
          ELSE ash.no_of_sublots
       END no_of_sublots,
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
       ash.comments,
      ?
  FROM ash_assay_header ash,
       axs_action_summary axs,
       v_pci vpci,
       gmr_goods_movement_record gmr,
       phd_profileheaderdetails phd,
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
   AND ash.internal_grd_ref_no = grd.internal_grd_ref_no
   AND grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   AND grd.internal_contract_item_ref_no = vpci.internal_contract_item_ref_no
   AND grdcontainer.intgmr(+) = gmr.internal_gmr_ref_no
   AND gmr.is_deleted = ''N''
   AND phd.profileid(+) = ash.assayer
   AND ash.ash_id = ?';
BEGIN
   UPDATE dgm_document_generation_master
      SET fetch_query = fetchqry1
    WHERE dgm_id = 'DGM-AS' AND activity_id = 'CREATE_ASSAY';
END;