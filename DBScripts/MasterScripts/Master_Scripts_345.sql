SET DEFINE OFF;
update GM_GRID_MASTER set DEFAULT_COLUMN_MODEL_STATE=
   '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},     
                                  {header: "Lot No.", width: 150, sortable: true, dataIndex: "lotNo"},
                                  {header: "Counter Party", width: 150, sortable: true, dataIndex: "counterParty"},
                                  {header: "No.Of SubLots", width: 150, sortable: true, dataIndex: "noOfSubLots"},
                                  {header: "Assay Ref. No.", width: 150, sortable: true, dataIndex: "assayRefNo"},
                                  {header: "Assay Type", width: 150, sortable: true, dataIndex: "assayType"},
                                  {header: "Assay Fully Finalized", width: 150, sortable: true, dataIndex: "assayFullyFinalized"},
                                  {header: "Use For Assay Exchange", width: 150, sortable: true, dataIndex: "useForFinalization"},
                                  {header: "Weighing & Sampling Ref No.", width: 150, sortable: true, dataIndex: "weighingAndSamplingRefNo"},
                                  {header: "Assay Details", width: 150, sortable: true, dataIndex: "assayDetails"},
                                  {header: "Wet Weight", width: 150, sortable: true, dataIndex: "wetWeight"},
                                  {header: "Dry Weight", width: 150, sortable: true, dataIndex: "dryWeight"},
                                  {header: "Assayer/Umpire", width: 150, sortable: true, dataIndex: "assayer"},
                                  {header: "Product", width: 150, sortable: true, dataIndex: "product"},
                                  {header: "Quality", width: 150, sortable: true, dataIndex: "Quality"},
                                  {header: "GMR Ref. No.", width: 150, sortable: true, dataIndex: "gmrRefNo"},
                                  {header: "GMR Activity Ref. No.", width: 150, sortable: true, dataIndex: "gmrActivityRefNo"},
                                  {header: "Contract Item No.", width: 150, sortable: true, dataIndex: "contractItemNo"},
                                  {header: "Delivery Item No.", width: 150, sortable: true, dataIndex: "deliveryItemNo"},
                                  {header: "Used for Pricing", width: 150, sortable: true, dataIndex: "usedForPricing"},
                                  {header: "Activity Date", width: 150, sortable: true, dataIndex: "activityDate"},
                                  {header: "Activity Type", width: 150, sortable: true, dataIndex: "activityType"},
                                  {header: "Used for Invoice.", width: 150, sortable: true, dataIndex: "usedForInvoice"}                         
                              ]', 
    DEFAULT_RECORD_MODEL_STATE='[
                    {name: "lotNo", mapping: "lotNo"},
                    {name: "counterParty", mapping: "counterParty"},
                    {name: "noOfSubLots", mapping: "noOfSubLots"},
                    {name: "assayRefNo", mapping: "assayRefNo"},
                    {name: "assayType", mapping: "assayType"},
                    {name: "assayFullyFinalized", mapping: "assayFullyFinalized"}, 
                    {name: "useForFinalization", mapping: "useForFinalization"},
                    {name: "weighingAndSamplingRefNo", mapping: "weighingAndSamplingRefNo"},
                    {name: "assayDetails", mapping: "assayDetails"},  
                    {name: "wetWeight", mapping: "wetWeight"},
                    {name: "dryWeight", mapping: "dryWeight"},
                    {name: "assayer", mapping: "assayer"},
                    {name: "product", mapping: "product"}, 
                    {name: "Quality", mapping: "Quality"},
                    {name: "gmrRefNo", mapping: "gmrRefNo"},
                    {name: "gmrActivityRefNo", mapping: "gmrActivityRefNo"},  
                    {name: "contractItemNo", mapping: "contractItemNo"},
                    {name: "deliveryItemNo", mapping: "deliveryItemNo"},
                    {name: "usedForPricing", mapping: "usedForPricing"},
                    {name: "activityDate", mapping: "activityDate"}, 
                    {name: "activityType", mapping: "activityType"},
                    {name: "usedForInvoice", mapping: "usedForInvoice"}
                  ]'
where GRID_ID='LOAD';


SET DEFINE OFF;
update DGM_DOCUMENT_GENERATION_MASTER set FETCH_QUERY=
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
                             AND agmr.is_final_weight = ''Y'') = 1
                       THEN (SELECT vd.loading_date
                               FROM vd_voyage_detail vd
                              WHERE vd.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
                    ELSE (SELECT wrd.storage_date
                            FROM wrd_warehouse_receipt_detail wrd
                           WHERE wrd.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
                 END
                )
        END
       ) ship_land_date,
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
        (VPCI.PRODUCT_NAME
           || '' , ''
           || VPCI.QUALITY_NAME
       ) PRODUCT_AND_QUALITY,
       BGM.BP_GROUP_NAME as ASSAYER,
       ASH.ASSAY_TYPE AS ASSAY_TYPE,
       ASH.USE_FOR_FINALIZATION AS EXCHANGE_OF_ASSAYS, ASH.LOT_NO AS LOT_NO,
       ASH.NO_OF_SUBLOTS AS NO_OF_SUBLOTS,ASH.CONSOLIDATED_GROUP_ID AS CONSOLIDATED_GROUP_ID,?
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
  AND ASH.ASH_ID = ?'
  where DGM_ID='DGM-AS' and DOC_ID='CREATE_ASSAY';


