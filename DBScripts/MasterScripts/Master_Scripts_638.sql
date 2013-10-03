----- self cp umpire final

DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO as_assay_d
            (internal_contract_item_ref_no, assay_refno, internal_gmr_ref_no,
             contract_type, activity_date, ship_land_date, buyer, seller,
             our_contract_ref_no, cp_contract_ref_no, gmr_ref_no,
             shipment_date, weighing_and_sampling_ref_no, product_and_quality,
             assayer, assay_type, exchange_of_assays, lot_no, no_of_sublots,
             bl_no, bl_date, vessel_name, mode_of_transport, container_no,
             cp_address,cp_name, comments, senders_ref_no,smelter_location, internal_doc_ref_no)
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
                              WHERE wrd.internal_gmr_ref_no =  agmr.internal_gmr_ref_no
                                AND agmr.internal_gmr_ref_no =  gmr.internal_gmr_ref_no
                                AND agmr.is_deleted = ''N''
                                group by WRD.STORAGE_DATE
                                having max(agmr.action_no) = max(wrd.action_no))
                    END
                   )
           END
          ) ship_land_date,
          (CASE
              WHEN gmr.contract_type = ''Sales''
                 THEN vpci.cp_name
              WHEN gmr.contract_type = ''Tolling''
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
          (vpci.product_name || '','' || vpci.quality_name
          ) product_and_quality, phd.companyname AS assayer,
          CASE
             WHEN ash.assay_type = ''Final Assay''
                THEN ''Final''
             WHEN ash.assay_type = ''Umpire Assay''
                THEN ''Umpire''
             ELSE ash.assay_type
          END assay_type,
          ash.use_for_finalization AS exchange_of_assays,
          CASE
             WHEN ash.assay_type IN
                    (''Provisional Assay'',
                     ''Secondary Provisional Assay'')
             AND ash.consolidated_group_id IS NOT NULL
                THEN (SELECT stragg (ash1.lot_no)
                        FROM ash_assay_header ash1
                       WHERE ash1.assay_ref_no = ash.assay_ref_no
                         AND ash1.assay_type IN
                                (''Provisional Assay'',
                                 ''Secondary Provisional Assay''))
             WHEN ash.assay_type <> ''Provisional Assay''
             AND ash.is_sublots_as_stock = ''Y''
                THEN (SELECT stragg (ash1.lot_no)
                        FROM ash_assay_header ash1
                       WHERE ash1.assay_ref_no = ash.assay_ref_no)
             ELSE ash.lot_no
          END lot_no,
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
                         AND ash2.is_active = ''Y''
                         AND ash2.is_sublots_as_stock = ''Y'')
             ELSE ash.no_of_sublots
          END no_of_sublots,
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
          CASE
             WHEN ash.consolidated_group_id IS NOT NULL
                THEN (SELECT Listagg (agrd.container_no,''^'') within group(order by AGRD.CONTAINER_NO)
                        FROM agrd_action_grd agrd
                       WHERE agrd.container_no IS NOT NULL
                         AND agrd.is_deleted = ''N''
                         AND agrd.status = ''Active''
                         AND agrd.internal_grd_ref_no IN (
                            select AGRD1.INTERNAL_GRD_REF_NO from AGRD_ACTION_GRD agrd1
                            where AGRD1.INTERNAL_GMR_REF_NO = ASH.INTERNAL_GMR_REF_NO
                            AND agrd1.is_deleted = ''N''
                            AND agrd1.is_deleted = ''N''
                            AND agrd1.status = ''Active''))
             when ASH.ASSAY_TYPE in(''Provisional Assay'',''Secondary Provisional Assay'')
                then (SELECT Listagg (agrd.container_no,''^'') within group (order by AGRD.CONTAINER_NO)  from AGRD_ACTION_GRD agrd
                    where AGRD.CONTAINER_NO is not null
                        and AGRD.IS_DELETED=''N''
                        AND agrd.status = ''Active''
                        and AGRD.INTERNAL_GRD_REF_NO = ASH.INTERNAL_GRD_REF_NO)                            
             ELSE (SELECT Listagg (agrd.container_no,''^'') within group (order by AGRD.CONTAINER_NO)
                     FROM agrd_action_grd agrd
                    WHERE agrd.container_no IS NOT NULL
                      AND agrd.is_deleted = ''N''
                      AND agrd.status = ''Active''
                     AND AGRD.INTERNAL_GMR_REF_NO = ASH.INTERNAL_GMR_REF_NO)
          END container_no,
         (SELECT  pad.address
                  || '',''
                  || pad.zip
                  || '',''
                  || cim.city_name
                  || '',''
                  || sm.state_name
                  || '',''
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
           (SELECT phd1.companyname
              FROM phd_profileheaderdetails phd1
             WHERE phd1.profileid = vpci.cp_id) as cp_name,
          ash.comments,
          CASE
             WHEN ash.assay_type = ''Self Assay''
                THEN gmr.senders_ref_no
             ELSE ''''
          END senders_ref_no,
          phd2.companyname as smelter_location,
          ?
     FROM ash_assay_header ash,
          axs_action_summary axs,
          v_pci vpci,
          gmr_goods_movement_record gmr,
          phd_profileheaderdetails phd,
          phd_profileheaderdetails phd2,
          grd_goods_record_detail grd
    WHERE ash.internal_action_ref_no = axs.internal_action_ref_no
      AND ash.internal_grd_ref_no = grd.internal_grd_ref_no
      AND grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND grd.internal_contract_item_ref_no =
                                            vpci.internal_contract_item_ref_no
      AND gmr.is_deleted = ''N''
      AND phd.profileid(+) = ash.assayer
      AND phd2.profileid = gmr.warehouse_profile_id
      AND ash.ash_id = ?
   UNION ALL
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
                              WHERE wrd.internal_gmr_ref_no =  agmr.internal_gmr_ref_no
                                    AND agmr.internal_gmr_ref_no =  gmr.internal_gmr_ref_no
                                    AND agmr.is_deleted = ''N''
                                    group by WRD.STORAGE_DATE
                                    having max(AGMR.ACTION_NO) = max(WRD.ACTION_NO))
                    END
                   )
           END
          ) ship_land_date,
          (CASE
              WHEN gmr.contract_type = ''Sales''
                 THEN vpci.cp_name
              WHEN gmr.contract_type = ''Tolling''
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
              AND dgrd.internal_contract_item_ref_no =
                                            vpci.internal_contract_item_ref_no
              AND ash1.internal_grd_ref_no = dgrd.internal_dgrd_ref_no)
                                                 weighing_and_sampling_ref_no,
          (vpci.product_name || '','' || vpci.quality_name
          ) product_and_quality, phd.companyname AS assayer,
          CASE
             WHEN ash.assay_type = ''Final Assay''
                THEN ''Final''
             WHEN ash.assay_type = ''Umpire Assay''
                THEN ''Umpire''
             ELSE ash.assay_type
          END assay_type,
          ash.use_for_finalization AS exchange_of_assays,
          CASE
             WHEN ash.assay_type IN
                    (''Provisional Assay'',
                     ''Secondary Provisional Assay'')
             AND ash.consolidated_group_id IS NOT NULL
                THEN (SELECT stragg (ash1.lot_no)
                        FROM ash_assay_header ash1
                       WHERE ash1.assay_ref_no = ash.assay_ref_no
                         AND ash1.assay_type IN
                                (''Provisional Assay'',
                                 ''Secondary Provisional Assay''))
             WHEN ash.assay_type <> ''Provisional Assay''
             AND ash.is_sublots_as_stock = ''Y''
                THEN (SELECT stragg (ash1.lot_no)
                        FROM ash_assay_header ash1
                       WHERE ash1.assay_ref_no = ash.assay_ref_no)
             ELSE ash.lot_no
          END lot_no,
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
         CASE
             WHEN ash.consolidated_group_id IS NOT NULL
                THEN (SELECT Listagg (agrd.container_no,''^'') within group(order by AGRD.CONTAINER_NO)
                        FROM agrd_action_grd agrd
                       WHERE agrd.container_no IS NOT NULL
                         AND agrd.is_deleted = ''N''
                         AND agrd.status = ''Active''
                         AND agrd.internal_grd_ref_no IN (
                            select AGRD1.INTERNAL_GRD_REF_NO from AGRD_ACTION_GRD agrd1
                            where AGRD1.INTERNAL_GMR_REF_NO = ASH.INTERNAL_GMR_REF_NO
                            AND agrd1.is_deleted = ''N''
                            AND agrd1.is_deleted = ''N''
                            AND agrd1.status = ''Active''))
           when ASH.ASSAY_TYPE in(''Provisional Assay'',''Secondary Provisional Assay'')
                then (SELECT Listagg (agrd.container_no,''^'') within group(order by AGRD.CONTAINER_NO)  from AGRD_ACTION_GRD agrd
                    where AGRD.CONTAINER_NO is not null
                        and AGRD.IS_DELETED=''N''
                        AND agrd.status = ''Active''
                        and AGRD.INTERNAL_GRD_REF_NO = ASH.INTERNAL_GRD_REF_NO)   
          ELSE (SELECT Listagg (agrd.container_no,''^'') within group (order by AGRD.CONTAINER_NO)
                  FROM adgrd_action_dgrd agrd
                 WHERE agrd.container_no IS NOT NULL
                   AND agrd.status = ''Active''
                   AND AGRD.INTERNAL_GMR_REF_NO = ASH.INTERNAL_GMR_REF_NO)
       END container_no,
      
           (SELECT pad.address
                  || '',''
                  || pad.zip
                  || '',''
                  || cim.city_name
                  || '',''
                  || sm.state_name
                  || '',''
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
        (SELECT phd1.companyname
              FROM phd_profileheaderdetails phd1
             WHERE phd1.profileid = vpci.cp_id) as cp_name,    
                      
          ash.comments,
          CASE
             WHEN ash.assay_type = ''Self Assay''
                THEN gmr.senders_ref_no
             ELSE ''''
          END senders_ref_no,
          phd2.companyname as smelter_location,
          ?
     FROM ash_assay_header ash,
          axs_action_summary axs,
          v_pci vpci,
          gmr_goods_movement_record gmr,
          phd_profileheaderdetails phd,
          PHD_PROFILEHEADERDETAILS phd2,
          dgrd_delivered_grd dgrd
    WHERE ash.internal_action_ref_no = axs.internal_action_ref_no
      AND ash.internal_grd_ref_no = dgrd.internal_dgrd_ref_no
      AND dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND dgrd.internal_contract_item_ref_no =
                                            vpci.internal_contract_item_ref_no
      AND gmr.is_deleted = ''N''
      AND phd.profileid(+) = ash.assayer
      and PHD2.PROFILEID = GMR.WAREHOUSE_PROFILE_ID
      AND ash.ash_id = ?';
BEGIN
   UPDATE dgm_document_generation_master
      SET fetch_query = fetchqry1
    WHERE dgm_id = 'DGM-AS' AND activity_id = 'CREATE_ASSAY';
END;

-----WnS GMR---

DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO wns_assay_d_gmr
            (contract_type, buyer, seller, gmr_ref_no, shipment_date,
             arrival_date, bl_no, bl_date, vessel_name, mode_of_transport,
             container_no, senders_ref_no, tare_weight, no_of_pieces,
             qty_unit,smelter_location, internal_doc_ref_no)
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
                   WHERE agrd1.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                     AND agrd1.status = ''Active'')) AS total_tare_weight,
       (SELECT SUM (agrd.no_of_pieces)
          FROM agrd_action_grd agrd
         WHERE agrd.internal_gmr_ref_no =
                                      gmr.internal_gmr_ref_no
           AND agrd.internal_gmr_ref_no = ash.internal_gmr_ref_no
           AND agrd.action_no IN (
                  SELECT MAX (agrd1.action_no)
                    FROM agrd_action_grd agrd1
                   WHERE agrd1.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                     AND agrd1.status = ''Active'')) AS no_of_pieces,
          pkg_general.f_get_quantity_unit (grd.qty_unit_id),
          PHD.COMPANYNAME assmelter_location,  ?
     FROM ash_assay_header ash,
          axs_action_summary axs,
          v_pci vpci,
          gmr_goods_movement_record gmr,
          PHD_PROFILEHEADERDETAILS phd,
          grd_goods_record_detail grd,
          (SELECT   Listagg (agrd.container_no,''^'') within group(order by agrd.container_no)AS containernostring,
                    agrd.internal_gmr_ref_no AS intgmr
               FROM agrd_action_grd agrd
              WHERE agrd.container_no IS NOT NULL
                AND agrd.is_deleted = ''N''
                AND agrd.status = ''Active''
           GROUP BY agrd.internal_gmr_ref_no
           UNION ALL
           SELECT   Listagg (dgrd.container_no,''^'') within group(order by dgrd.container_no) AS containernostring,
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
      AND phd.profileid = gmr.warehouse_profile_id
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
                   WHERE agrd1.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                     AND agrd1.status = ''Active'')) AS total_tare_weight,
       (SELECT SUM (agrd.no_of_pieces)
          FROM agrd_action_grd agrd
         WHERE agrd.internal_gmr_ref_no =
                                      gmr.internal_gmr_ref_no
           AND agrd.internal_gmr_ref_no = ash.internal_gmr_ref_no
           AND agrd.action_no IN (
                  SELECT MAX (agrd1.action_no)
                    FROM agrd_action_grd agrd1
                   WHERE agrd1.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                     AND agrd1.status = ''Active'')) AS no_of_pieces,
          pkg_general.f_get_quantity_unit (dgrd.net_weight_unit_id),phd.companyname as smelter_location, ?
     FROM ash_assay_header ash,
          axs_action_summary axs,
          v_pci vpci,
          gmr_goods_movement_record gmr,
          PHD_PROFILEHEADERDETAILS phd,
          dgrd_delivered_grd dgrd,
          (SELECT   Listagg(agrd.container_no,''^'') within group(order by agrd.container_no) AS containernostring,
                    agrd.internal_gmr_ref_no AS intgmr
               FROM agrd_action_grd agrd
              WHERE agrd.container_no IS NOT NULL
                AND agrd.is_deleted = ''N''
                AND agrd.status = ''Active''
           GROUP BY agrd.internal_gmr_ref_no
           UNION ALL
           SELECT   Listagg (dgrd.container_no,''^'')  within group(order by dgrd.container_no) AS containernostring,
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
      AND phd.profileid = gmr.warehouse_profile_id
      AND ash.ash_id = ?';
BEGIN
   UPDATE dgm_document_generation_master
      SET fetch_query = fetchqry1
    WHERE dgm_id = 'DGM-WNS-GMR' AND activity_id = 'CREATE_WNS_ASSAY';
END;