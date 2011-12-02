delete from DGM_DOCUMENT_GENERATION_MASTER dgm where DGM.DGM_ID='DGM-WNS';
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-WNS', 'CREATE_WNS_ASSAY', 'Weighing And Sampling', 'CREATE_WNS_ASSAY', 1, 
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
       ASH.ACTIVITY_DATE AS WEIGHING_SAMPLING_DATE, ASH.LOT_NO AS LOT_NO,
       ASH.NO_OF_SUBLOTS AS NO_OF_SUBLOTS,?
  FROM ASH_ASSAY_HEADER ASH,
       AXS_ACTION_SUMMARY AXS,
       V_PCI VPCI,
       GMR_GOODS_MOVEMENT_RECORD GMR,
       GRD_GOODS_RECORD_DETAIL grd,
       BGM_BP_GROUP_MASTER BGM
 WHERE ASH.INTERNAL_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
   AND ASH.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND GMR.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND ASH.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
   AND BGM.BP_GROUP_ID(+) = ASH.ASSAYER
   and GRD.INTERNAL_CONTRACT_ITEM_REF_NO=VPCI.INTERNAL_CONTRACT_ITEM_REF_NO
   and ASH.INTERNAL_GRD_REF_NO=GRD.INTERNAL_GRD_REF_NO
   AND ASH.ASH_ID = ?', 'N');