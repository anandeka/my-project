declare
fetchqry1 clob := 
    'INSERT INTO WNS_ASSAY_D(
INTERNAL_CONTRACT_ITEM_REF_NO,
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