
DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO wns_assay_d
            (internal_contract_item_ref_no, internal_gmr_ref_no,
             contract_type, activity_refno, activity_date, buyer, seller,
             our_contract_ref_no, cp_contract_ref_no, gmr_ref_no,
             shipment_date, weigher_and_sampler, product_and_quality,
             weighing_sampling_date, lot_no, no_of_sublots, wns_group_id,
             is_sublots_as_stock, arrival_date, bl_no, bl_date, vessel_name,
             mode_of_transport, container_no, cp_address, ASH_ID, internal_doc_ref_no)
   SELECT vpci.internal_contract_item_ref_no AS internal_contract_item_ref_no,
          ash.internal_gmr_ref_no AS internal_gmr_ref_no,
          gmr.contract_type AS contract_type,
          ash.assay_ref_no AS activity_refno, axs.eff_date AS activity_date,
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
          bgm.bp_group_name AS weigher_and_sampler,
          (vpci.product_name|| '','' || vpci.quality_name
          ) product_and_quality,
          ash.activity_date AS weighing_sampling_date, ash.lot_no AS lot_no,
          ash.no_of_sublots AS no_of_sublots,
          ash.wns_group_id AS wns_group_id,
          ash.is_sublots_as_stock AS is_sublots_as_stock,
          gmr.arrival_date AS arrival_date, gmr.bl_no AS bl_no,
          gmr.bl_date AS bl_date, gmr.vessel_name AS vessel_name,
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
              AND pad.city_id = cim.city_id(+)) AS cp_address,ASH.ASH_ID,
          ?
     FROM ash_assay_header ash,
          axs_action_summary axs,
          v_pci vpci,
          gmr_goods_movement_record gmr,
          grd_goods_record_detail grd,
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
      AND grd.internal_contract_item_ref_no =
                                            vpci.internal_contract_item_ref_no
      AND ash.internal_grd_ref_no = grd.internal_grd_ref_no
      AND ash.ash_id = ?';
BEGIN
   UPDATE dgm_document_generation_master
      SET fetch_query = fetchqry1
    WHERE dgm_id = 'DGM-WNS' AND activity_id = 'CREATE_WNS_ASSAY';
END;