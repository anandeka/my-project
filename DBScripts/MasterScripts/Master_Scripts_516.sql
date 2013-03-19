DECLARE
   fetchqry1   CLOB
      :='
INSERT INTO wns_assay_d
            (internal_contract_item_ref_no, internal_gmr_ref_no,
             activity_refno, activity_date, our_contract_ref_no,
             cp_contract_ref_no, weigher_and_sampler, product_and_quality,
             weighing_sampling_date, lot_no, no_of_sublots, wns_group_id,
             is_sublots_as_stock, cp_address, ash_id, internal_doc_ref_no)
   SELECT vpci.internal_contract_item_ref_no AS internal_contract_item_ref_no,
          ash.internal_gmr_ref_no AS internal_gmr_ref_no,
          ash.assay_ref_no AS activity_refno, axs.eff_date AS activity_date,
          vpci.contract_ref_no AS our_contract_ref_no,
          vpci.cp_contract_ref_no AS cp_contract_ref_no,
          phd.companyname AS weigher_and_sampler,
          (vpci.product_name || '','' || vpci.quality_name
          ) product_and_quality, ash.activity_date AS weighing_sampling_date,
          ash.lot_no AS lot_no,
          CASE
             WHEN ash.is_sublots_as_stock = ''Y''
                THEN (SELECT COUNT (*)
                        FROM ash_assay_header ash1
                       WHERE ash1.is_active = ''Y''
                         AND ash1.wns_group_id = ash.wns_group_id
                         AND ash1.assay_type = ''Weighing and Sampling Assay''
                         AND ash1.is_sublots_as_stock = ''Y'')
             ELSE ash.no_of_sublots
          END no_of_sublots,
          ash.wns_group_id AS wns_group_id,
          ash.is_sublots_as_stock AS is_sublots_as_stock,
          (SELECT    pad.address
                  || '', ''
                  || cim.city_name
                  || '', ''
                  || sm.state_name
                  || '', ''
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
          ash.ash_id, ?
     FROM ash_assay_header ash,
          axs_action_summary axs,
          v_pci vpci,
          gmr_goods_movement_record gmr,
          grd_goods_record_detail grd,
          phd_profileheaderdetails phd,
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
      AND phd.profileid(+) = ash.assayer
      AND grd.internal_contract_item_ref_no =  vpci.internal_contract_item_ref_no
      AND ash.internal_grd_ref_no = grd.internal_grd_ref_no
      AND ash.ash_id = ?';
 BEGIN
   UPDATE dgm_document_generation_master
      SET fetch_query = fetchqry1
    WHERE dgm_id = 'DGM-WNS' AND activity_id = 'CREATE_WNS_ASSAY';
END;     