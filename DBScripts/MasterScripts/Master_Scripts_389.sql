declare
fetchqry1 clob := 
    'INSERT INTO WNS_ASSAY_D(
INTERNAL_CONTRACT_ITEM_REF_NO,
ASH_ID,
INTERNAL_GMR_REF_NO ,
CONTRACT_TYPE       ,
ACTIVITY_REFNO     ,
ACTIVITY_DATE      ,
BUYER               ,
SELLER            ,
OUR_CONTRACT_REF_NO ,
CP_CONTRACT_REF_NO ,
GMR_REF_NO         ,
SHIPMENT_DATE      ,
WEIGHER_AND_SAMPLER  ,
PRODUCT_AND_QUALITY ,
WEIGHING_SAMPLING_DATE ,
LOT_NO      ,
NO_OF_SUBLOTS,
WNS_GROUP_ID,
IS_SUBLOTS_AS_STOCK,
ARRIVAL_DATE,
INTERNAL_DOC_REF_NO
)
SELECT VPCI.INTERNAL_CONTRACT_ITEM_REF_NO AS INTERNAL_CONTRACT_ITEM_REF_NO,
       ASH.ASH_ID AS ASH_ID, 
       ASH.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
       GMR.CONTRACT_TYPE AS CONTRACT_TYPE,
       ASH.ASSAY_REF_NO AS ACTIVITY_REFNO, AXS.EFF_DATE AS ACTIVITY_DATE,
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
       BGM.BP_GROUP_NAME AS WEIGHER_AND_SAMPLER,
        (VPCI.PRODUCT_NAME
           || '' , ''
           || VPCI.QUALITY_NAME
       ) PRODUCT_AND_QUALITY,
       ASH.SAMPLE_DATE AS WEIGHING_SAMPLING_DATE, ASH.LOT_NO AS LOT_NO,
       case when ash.is_sublots_as_stock = ''Y'' 
         then 
        (SELECT COUNT (*)
       FROM ash_assay_header ash1
      WHERE ash1.is_active = ''Y''
        AND ash1.wns_group_id = ash.wns_group_id
        AND ash1.assay_type = ''Weighing and Sampling Assay''
        AND ash1.is_sublots_as_stock = ''Y'') 
        else
        ASH.NO_OF_SUBLOTS
        end
       NO_OF_SUBLOTS,
       ASH.WNS_GROUP_ID AS WNS_GROUP_ID,
       ASH.IS_SUBLOTS_AS_STOCK AS IS_SUBLOTS_AS_STOCK,
       (SELECT agmr.eff_date AS ship_land_date
          FROM agmr_action_gmr agmr
         WHERE agmr.internal_gmr_ref_no =
                                       gmr.internal_gmr_ref_no
           AND agmr.is_deleted = ''N''
           AND agmr.action_no = ''1'') ARRIVAL_DATE,?
  FROM ASH_ASSAY_HEADER ASH,
       AXS_ACTION_SUMMARY AXS,
       V_PCI VPCI,
       GMR_GOODS_MOVEMENT_RECORD GMR,
       BGM_BP_GROUP_MASTER BGM
 WHERE ASH.INTERNAL_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
   AND ASH.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND GMR.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND ASH.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
   AND BGM.BP_GROUP_ID(+) = ASH.ASSAYER
   AND ASH.ASH_ID = ?';
   
begin
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID='DGM-WNS' and DOC_ID='CREATE_WNS_ASSAY';
end;

declare
fetchqry2 clob := 
    'INSERT INTO WNS_ASSAY_CHILD_D (
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
       ASM.SUB_LOT_NO AS SUBLOT_REF_NO,
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
          ASM.NET_WEIGHT,
          RM.RATIO_NAME,
          ASM.DRY_WEIGHT,
          QUM.QTY_UNIT,
          ASM.REMARK_ONE,
          ASM.REMARK_TWO)t
           )tt
where tt.rank =1';
   
begin
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry2 where DGM_ID='DGM-WNSC' and DOC_ID='CREATE_WNS_ASSAY';
end;