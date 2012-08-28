declare
fetchqry1 clob := 
    'INSERT INTO AS_ASSAY_D(
INTERNAL_CONTRACT_ITEM_REF_NO,
ASSAY_REFNO,
INTERNAL_GMR_REF_NO ,
CONTRACT_TYPE       ,
ACTIVITY_DATE      ,
ship_land_date ,
BUYER               ,
SELLER            ,
OUR_CONTRACT_REF_NO ,
CP_CONTRACT_REF_NO ,
GMR_REF_NO         ,
SHIPMENT_DATE      ,
WEIGHING_AND_SAMPLING_REF_NO  ,
WEIGHING_SAMPLING_DATE,
PRODUCT_AND_QUALITY ,
ASSAYER      ,
ASSAY_TYPE     ,
EXCHANGE_OF_ASSAYS ,
LOT_NO      ,
NO_OF_SUBLOTS,
CONSOLIDATED_GROUP_ID,
INTERNAL_DOC_REF_NO 
)
SELECT VPCI.INTERNAL_CONTRACT_ITEM_REF_NO AS INTERNAL_CONTRACT_ITEM_REF_NO,
       ASH.ASSAY_REF_NO AS ASSAY_REFNO,
       ASH.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
       GMR.CONTRACT_TYPE AS CONTRACT_TYPE,AXS.EFF_DATE AS ACTIVITY_DATE,
       (SELECT agmr.eff_date AS ship_land_date
          FROM agmr_action_gmr agmr
         WHERE agmr.internal_gmr_ref_no =
                                       gmr.internal_gmr_ref_no
           AND agmr.is_deleted = ''N''
           AND agmr.action_no = ''1'') ship_land_date,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Sales''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) BUYER,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Purchase''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) SELLER,
       VPCI.CONTRACT_REF_NO AS OUR_CONTRACT_REF_NO,
       VPCI.CP_CONTRACT_REF_NO AS CP_CONTRACT_REF_NO,
       GMR.GMR_REF_NO AS GMR_REF_NO, GMR.EFF_DATE AS SHIPMENT_DATE,
       (SELECT ASH1.ASSAY_REF_NO
          FROM ASH_ASSAY_HEADER ASH1
         WHERE ASH1.ASSAY_TYPE =
                   ''Weighing and Sampling Assay''
           AND ASH1.IS_ACTIVE = ''Y''
           AND nvl(ASH1.IS_DELETE,''N'') = ''N'' 
           AND ASH1.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
           AND ASH1.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
           AND ASH1.INTERNAL_GRD_REF_NO = ASH.INTERNAL_GRD_REF_NO)
                                                 WEIGHING_AND_SAMPLING_REF_NO,
          (SELECT ASH1.ACTIVITY_DATE
          FROM ASH_ASSAY_HEADER ASH1
         WHERE ASH1.ASSAY_TYPE =
                   ''Weighing and Sampling Assay''
           AND ASH1.IS_ACTIVE = ''Y''
           AND nvl(ASH1.IS_DELETE,''N'') = ''N'' 
           AND ASH1.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
           AND ASH1.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
           AND ASH1.INTERNAL_GRD_REF_NO = ASH.INTERNAL_GRD_REF_NO)
                                                 WEIGHING_SAMPLING_DATE,                                      
        (VPCI.PRODUCT_NAME
           || '' , ''
           || VPCI.QUALITY_NAME
       ) PRODUCT_AND_QUALITY,
       BGM.BP_GROUP_NAME as ASSAYER,
       ASH.ASSAY_TYPE AS ASSAY_TYPE,
       ASH.USE_FOR_FINALIZATION AS EXCHANGE_OF_ASSAYS,
       case when ASH.CONSOLIDATED_GROUP_ID is not null
         then 
       '''' 
        else
       ASH.LOT_NO
        end
       LOT_NO,
        case when ASH.CONSOLIDATED_GROUP_ID is not null
         then 
        (SELECT COUNT (*)
       FROM ash_assay_header ash1
      WHERE ash1.is_active = ''Y''
        AND ash1.assay_type = ASH.ASSAY_TYPE
        AND ASH1.CONSOLIDATED_GROUP_ID =ash.CONSOLIDATED_GROUP_ID) 
        else
        ASH.NO_OF_SUBLOTS
        end
       NO_OF_SUBLOTS,ASH.CONSOLIDATED_GROUP_ID AS CONSOLIDATED_GROUP_ID,?
  FROM ASH_ASSAY_HEADER ASH,
       AXS_ACTION_SUMMARY AXS,
       V_PCI VPCI,
       GMR_GOODS_MOVEMENT_RECORD GMR,
       BGM_BP_GROUP_MASTER bgm
 WHERE ASH.INTERNAL_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
   AND ASH.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND GMR.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND ASH.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
   AND BGM.BP_GROUP_ID(+) = ASH.ASSAYER
  AND ASH.ASH_ID = ?';
   
begin
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID='DGM-AS' and DOC_ID='CREATE_ASSAY';
end;


declare
fetchqry2 clob := 
    'INSERT INTO AS_ASSAY_CHILD_D (
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
ASH_ID,
INTERNAL_DOC_REF_NO           
)
SELECT DISTINCT 
                (CASE WHEN (ASH.ASSAY_TYPE) <> ''Provisional Assay'' THEN 
                (ASM.SUB_LOT_NO)
                ELSE
                (ASH.LOT_NO)
                END)  AS LOT_REF_NO,
                ASM.ORDERING AS SUBLOTORDERING,
                PQCA.ORDERING AS ELEMENTORDERING,
                (CASE WHEN (ASH.ASSAY_TYPE) <> ''Provisional Assay'' THEN 
                (ASM.DRY_WEIGHT)
                ELSE
                (ASM.NET_WEIGHT)
                END)  AS NET_WEIGHT,
                ASM.DRY_WEIGHT AS DRY_WEIGHT,
                PQCA.IS_DEDUCTIBLE AS IS_DEDUCTIBLE,
                QUM.QTY_UNIT AS NET_WEIGHT_UNIT_NAME,
               AML.ATTRIBUTE_NAME AS ELEMENT_NAME,
               PQCA.TYPICAL AS ASSAY_VALUE,
                RM.RATIO_NAME AS ASSAY_UOM,ASM.ASH_ID,?
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
   
begin
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry2 where DGM_ID='DGM-ASC' and DOC_ID='CREATE_ASSAY';
end;

