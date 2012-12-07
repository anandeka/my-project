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
                                AND agmr.is_final_weight = ''Y''
                      and AGMR.ACTION_NO=1) = 1
                          THEN (SELECT vd.loading_date
                                  FROM vd_voyage_detail vd
                                 WHERE vd.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
                       ELSE (SELECT wrd.storage_date
                               FROM wrd_warehouse_receipt_detail wrd,AGMR_ACTION_GMR agmr
                              WHERE wrd.internal_gmr_ref_no =agmr.internal_gmr_ref_no
                              and AGMR.ACTION_NO=WRD.ACTION_NO
                              and AGMR.INTERNAL_GMR_REF_NO=GMR.INTERNAL_GMR_REF_NO
                              and AGMR.IS_DELETED=''N'')
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
              and GRD.INTERNAL_CONTRACT_ITEM_REF_NO=VPCI.INTERNAL_CONTRACT_ITEM_REF_NO
              AND ash1.internal_grd_ref_no = grd.internal_grd_ref_no)
                                                 weighing_and_sampling_ref_no,
          (vpci.product_name|| '','' || vpci.quality_name
          ) product_and_quality,
         PHD.COMPANYNAME AS assayer,
          ASH.ASSAY_TYPE AS assay_type,
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
          phd_profileheaderdetails phd,
          grd_goods_record_detail grd,
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
   AND ash.internal_grd_ref_no = grd.internal_grd_ref_no
   AND grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   AND grd.internal_contract_item_ref_no = vpci.internal_contract_item_ref_no
   AND grdcontainer.intgmr(+) = gmr.internal_gmr_ref_no
   AND gmr.is_deleted = ''N''
   AND PHD.PROFILEID(+) = ash.assayer
   AND ash.ash_id = ?';
BEGIN
   UPDATE dgm_document_generation_master
      SET fetch_query = fetchqry1
    WHERE dgm_id = 'DGM-AS' AND activity_id = 'CREATE_ASSAY';
END;



DECLARE
   fetchqry2   CLOB
      :='INSERT INTO AS_ASSAY_CHILD_D (
LOT_REF_NO    ,
SUBLOTORDERING,
ELEMENTORDERING,
NET_WEIGHT,
DRY_WEIGHT,
IS_DEDUCTIBLE,
NET_WEIGHT_UNIT_NAME ,
ELEMENT_NAME ,
ASSAY_VALUE ,
ASSAY_UOM,
INTERNAL_DOC_REF_NO           
)
SELECT DISTINCT 
                (CASE WHEN  ASM.SUBLOT_REF_NO is not null THEN 
                ASM.SUBLOT_REF_NO
                ELSE
                ASH.LOT_NO
                END)  AS LOT_REF_NO,
                ASM.ORDERING AS SUBLOTORDERING,
                PQCA.ORDERING AS ELEMENTORDERING,
                (CASE WHEN (ASH.ASSAY_TYPE) not in(''Provisional Assay'',''Secondary Provisional Assay'')THEN 
                (ASM.DRY_WEIGHT)
                ELSE
                (ASM.NET_WEIGHT)
                END)  AS NET_WEIGHT,
                ASM.DRY_WEIGHT AS DRY_WEIGHT,
                PQCA.IS_DEDUCTIBLE AS IS_DEDUCTIBLE,
                QUM.QTY_UNIT AS NET_WEIGHT_UNIT_NAME,
               AML.ATTRIBUTE_NAME AS ELEMENT_NAME,
               PQCA.TYPICAL AS ASSAY_VALUE,
                RM.RATIO_NAME AS ASSAY_UOM,?
           FROM ASM_ASSAY_SUBLOT_MAPPING ASM,
                ASH_ASSAY_HEADER ASH,
                QUM_QUANTITY_UNIT_MASTER QUM,
                RM_RATIO_MASTER RM,
                PQCA_PQ_CHEMICAL_ATTRIBUTES PQCA,
                AML_ATTRIBUTE_MASTER_LIST AML
          WHERE ASM.NET_WEIGHT_UNIT = QUM.QTY_UNIT_ID
            AND ASM.ASH_ID=ASH.ASH_ID
            AND ASM.ASM_ID = PQCA.ASM_ID
            AND PQCA.UNIT_OF_MEASURE = RM.RATIO_ID
            AND PQCA.ELEMENT_ID=AML.ATTRIBUTE_ID
            AND ASM.ASH_ID = ?
            AND PQCA.ELEMENT_ID IN (?)
            order by ASM.ORDERING,PQCA.ORDERING';
BEGIN
   UPDATE dgm_document_generation_master
      SET fetch_query = fetchqry2
    WHERE dgm_id = 'DGM-ASC' AND activity_id = 'CREATE_ASSAY';
END;