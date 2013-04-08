--- Assay Parent--

DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO as_assay_d
            (internal_contract_item_ref_no, assay_refno, internal_gmr_ref_no,
             contract_type, activity_date, ship_land_date, buyer, seller,
             our_contract_ref_no, cp_contract_ref_no, gmr_ref_no,
             shipment_date, weighing_and_sampling_ref_no, product_and_quality,
             assayer, assay_type, exchange_of_assays, lot_no, no_of_sublots,
             bl_no, bl_date, vessel_name, mode_of_transport, container_no,
             cp_address, comments, senders_ref_no, internal_doc_ref_no)
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
       phd.companyname AS assayer, 
       CASE
          WHEN ash.assay_type = ''Final Assay''
             THEN ''Final''
          WHEN ash.assay_type = ''Umpire Assay''
             THEN ''Umpire''
          ELSE ash.assay_type
       END assay_type,
       ash.use_for_finalization AS exchange_of_assays,
        case 
            when ASH.ASSAY_TYPE=''Provisional Assay''
            then ASH.LOT_NO
        when ASH.ASSAY_TYPE <> ''Provisional Assay''
                and ASH.IS_SUBLOTS_AS_STOCK = ''Y''
         then
       (SELECT stragg (ash1.lot_no)
          FROM ash_assay_header ash1
         WHERE ash1.assay_ref_no = ash.assay_ref_no)
         else ASH.LOT_NO
         end lot_no,
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
       END bl_date,
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
       CASE
          WHEN ash.assay_type = ''Self Assay''
             THEN gmr.senders_ref_no
          ELSE ''''
       END senders_ref_no,
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


--- WnS child ---

DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO WNS_ASSAY_CHILD_D (
ASH_ID,    
SUBLOTORDERING,
SUBLOT_REF_NO ,
NET_WET_WEIGHT,
DEDUCTIBLE_CONTENT,
DEDUCTIBLE_CONTENT_UOM,
DEDUCTIBLE_CONTENT_WEIGHT,
NET_DRY_WEIGHT,
WEIGHT_UNIT_NAME,
DEDUCTIBLE_CONTENT_DETALS,
REMARK1,
REMARK2,
INTERNAL_DOC_REF_NO            
)
select  
  tt.ASH_ID,  
  tt.SUBLOTORDERING,
  tt.SUBLOT_REF_NO,
  tt.NET_WET_WEIGHT,
  tt.DEDUCTIBLE_CONTENT,
  tt.DEDUCTIBLE_CONTENT_UOM,
  tt.DEDUCTIBLE_CONTENT_WEIGHT,
  tt.NET_DRY_WEIGHT,
  tt.WEIGHT_UNIT_NAME,
  tt.DEDUCTIBLE_CONTENT_DETALS,
  tt.REMARK1,
  tt.REMARK2,
   tt.INTERNAL_DOC_REF_NO 
from
(select 
  rank() OVER (partition by t.SUBLOT_REF_NO ORDER BY t.DEDUCTIBLE_CONTENT desc,t.deductible_content_uom)rank,
  t.ASH_ID,
  t.SUBLOTORDERING,
  t.SUBLOT_REF_NO,
  t.NET_WET_WEIGHT,
  t.DEDUCTIBLE_CONTENT,
  t.DEDUCTIBLE_CONTENT_UOM,
  t.DEDUCTIBLE_CONTENT_WEIGHT,
  t.NET_DRY_WEIGHT,
  t.WEIGHT_UNIT_NAME,
  t.DEDUCTIBLE_CONTENT_DETALS,
  t.REMARK1,
  t.REMARK2,
  t.INTERNAL_DOC_REF_NO 
from
(SELECT 
       ASM.ASH_ID AS ASH_ID,
       ASM.ORDERING AS SUBLOTORDERING,
       case
       when ASM.SUBLOT_REF_NO is null
       then ASM.SUB_LOT_NO
       else ASM.SUBLOT_REF_NO
       end  SUBLOT_REF_NO,
       ASM.NET_WEIGHT AS NET_WET_WEIGHT,
       SUM((CASE
             WHEN NVL(PQCA.IS_DEDUCTIBLE, ''N'') = ''Y'' THEN
              PQCA.TYPICAL
             ELSE
              0
           END)) DEDUCTIBLE_CONTENT,
       RM.RATIO_NAME AS DEDUCTIBLE_CONTENT_UOM,
       (SUM((CASE
              WHEN NVL(PQCA.IS_DEDUCTIBLE, ''N'') = ''Y'' THEN
               PQCA.TYPICAL
              ELSE
               0
            END)) * (CASE
         WHEN RM.RATIO_NAME = ''%'' THEN
          (ASM.NET_WEIGHT / 100)
         ELSE
          0
       END)) DEDUCTIBLE_CONTENT_WEIGHT,
       ASM.DRY_WEIGHT AS NET_DRY_WEIGHT,
       QUM.QTY_UNIT AS WEIGHT_UNIT_NAME,
       STRAGG(((CASE
                WHEN NVL(PQCA.IS_DEDUCTIBLE, ''N'') = ''Y'' THEN
                 PQCA.TYPICAL || '''' || RM.RATIO_NAME || '''' || AML.ATTRIBUTE_DESC
                ELSE
                 NULL
              END))) DEDUCTIBLE_CONTENT_DETALS,
         ASM.REMARK_ONE as REMARK1,
         ASM.REMARK_TWO as REMARK2,           
       ? as INTERNAL_DOC_REF_NO
  FROM ASM_ASSAY_SUBLOT_MAPPING    ASM,
       QUM_QUANTITY_UNIT_MASTER    QUM,
       RM_RATIO_MASTER             RM,
       PQCA_PQ_CHEMICAL_ATTRIBUTES PQCA,
       AML_ATTRIBUTE_MASTER_LIST   AML
 WHERE ASM.NET_WEIGHT_UNIT = QUM.QTY_UNIT_ID(+)
   AND ASM.ASM_ID = PQCA.ASM_ID
   AND PQCA.UNIT_OF_MEASURE = RM.RATIO_ID
   AND PQCA.ELEMENT_ID = AML.ATTRIBUTE_ID
   AND ASM.ASH_ID = ?
 GROUP BY ASM.ASH_ID,
          ASM.ORDERING,
          ASM.SUB_LOT_NO,
          ASM.SUBLOT_REF_NO,
          ASM.NET_WEIGHT,
          RM.RATIO_NAME,
          ASM.DRY_WEIGHT,
          QUM.QTY_UNIT,
          ASM.REMARK_ONE,
          ASM.REMARK_TWO)t
           )tt
where tt.rank =1';
BEGIN
   UPDATE dgm_document_generation_master
      SET fetch_query = fetchqry1
    WHERE dgm_id = 'DGM-WNSC' AND activity_id = 'CREATE_WNS_ASSAY';
END;


---Wns GMR ---


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
          (SELECT SUM (grd.tare_weight)
          FROM grd_goods_record_detail grd
         WHERE grd.internal_gmr_ref_no =
                                 gmr.internal_gmr_ref_no
           AND grd.internal_gmr_ref_no = ash.internal_gmr_ref_no
           AND grd.is_deleted = ''N'') AS total_tare_weight,
          (SELECT SUM (agrd.no_of_pieces)
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                      gmr.internal_gmr_ref_no
              AND agrd.internal_gmr_ref_no = ash.internal_gmr_ref_no)
                                                              AS no_of_pieces,
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


--Assay Child ---

DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO AS_ASSAY_CHILD_D (
LOT_REF_NO    ,
SUBLOTORDERING,
ELEMENTORDERING,
NET_WEIGHT,
DRY_WEIGHT,
IS_DEDUCTIBLE,
IS_ELEM_FOR_PRICING,
NET_WEIGHT_UNIT_NAME ,
ELEMENT_NAME ,
ASSAY_VALUE ,
ASSAY_UOM,
INTERNAL_DOC_REF_NO           
)
SELECT DISTINCT 
               (CASE
                    WHEN ash.assay_type = ''Final Assay''
                       THEN asm.sub_lot_no
                    ELSE asm.sublot_ref_no
                 END
                ) AS lot_ref_no,
                ASM.ORDERING AS SUBLOTORDERING,
                PQCA.ORDERING AS ELEMENTORDERING,
                (CASE WHEN (ASH.ASSAY_TYPE) not in(''Provisional Assay'',''Secondary Provisional Assay'')THEN 
                (ASM.DRY_WEIGHT)
                ELSE
                (ASM.NET_WEIGHT)
                END)  AS NET_WEIGHT,
                ASM.DRY_WEIGHT AS DRY_WEIGHT,
                PQCA.IS_DEDUCTIBLE AS IS_DEDUCTIBLE,
                PQCA.IS_ELEM_FOR_PRICING as IS_ELEM_FOR_PRICING,
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
      SET fetch_query = fetchqry1
    WHERE dgm_id = 'DGM-ASC' AND activity_id = 'CREATE_ASSAY';
END;