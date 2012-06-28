--773

SET define off; 
set feedback off
set autoprint off

rem Execute PL/SQL Block
DECLARE
  CURSOR grd_stock IS
    SELECT grd.internal_grd_ref_no,
           pci.internal_contract_item_ref_no,
           pci.phy_attribute_group_no
      FROM grd_goods_record_detail grd, v_pci pci
     WHERE grd.internal_contract_item_ref_no =
           pci.internal_contract_item_ref_no(+)
       AND grd.status = 'Active'
       AND grd.tolling_stock_type = 'None Tolling'
       and pci.phy_attribute_group_no is not null
       and grd.pqpa_phy_attribute_group_no IS NULL;
    
     vc_seq VARCHAR2(50);

BEGIN
  FOR eachitem IN grd_stock LOOP
    SELECT 'PHY-GRP-' || seq_phy_group.NEXTVAL INTO vc_seq FROM dual;
    --update GRD with new groupNo
    UPDATE grd_goods_record_detail grd
       SET grd.pqpa_phy_attribute_group_no = vc_seq
     WHERE grd.internal_contract_item_ref_no =
           eachitem.internal_contract_item_ref_no
       AND grd.internal_grd_ref_no = eachitem.internal_grd_ref_no;
   --- update only for shipment,rail,air detail AGRD  with new group no  
    UPDATE agrd_action_grd grd
       SET grd.pqpa_phy_attribute_group_no = vc_seq
     WHERE grd.internal_grd_ref_no = eachitem.internal_grd_ref_no
       AND grd.action_no =
           (SELECT agrd.action_no
              FROM agmr_action_gmr agmr, agrd_action_grd agrd
             WHERE agmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no
               AND agmr.action_no = agrd.action_no
               AND agrd.internal_grd_ref_no = eachitem.internal_grd_ref_no
               AND agrd.status = 'Active'
               AND agrd.tolling_stock_type = 'None Tolling'
               AND agmr.gmr_latest_action_action_id in ('shipmentDetail','railDetail','airDetail','warehouseReceipt'));
    
     DECLARE CURSOR
     phyattribute IS
            SELECT pqpa.attribute_id, pqpa.attribute_value, pqpa.rejection
              FROM pqpa_pq_physical_attributes pqpa
             WHERE pqpa.phy_attribute_group_no =
                   eachitem.phy_attribute_group_no;
  
    pqpqid VARCHAR2(50);
    BEGIN
      FOR phyattribute_rows IN phyattribute LOOP
      
        SELECT seq_pqpa.NEXTVAL INTO pqpqid FROM dual;
        INSERT INTO pqpa_pq_physical_attributes
        VALUES
          (pqpqid,
           vc_seq,
           phyattribute_rows.attribute_id,
           phyattribute_rows.attribute_value,
           phyattribute_rows.rejection,
           0,
           'Y');
      END LOOP;
    
    END;
  END LOOP;

  COMMIT;
END;
/
rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
DECLARE
  CURSOR agrd_stock IS
  
    SELECT agrd.action_no,
           (SELECT s_agrd.pqpa_phy_attribute_group_no
              FROM agmr_action_gmr s_agmr, agrd_action_grd s_agrd
             WHERE s_agmr.internal_gmr_ref_no = s_agrd.internal_gmr_ref_no
               AND s_agmr.action_no = s_agrd.action_no
               AND s_agrd.status = 'Active'
               AND s_agrd.tolling_stock_type = 'None Tolling'
               AND s_agmr.gmr_latest_action_action_id IN
                   ('shipmentDetail', 'railDetail', 'airDetail')
               AND s_agrd.pqpa_phy_attribute_group_no IS NOT NULL
               AND s_agrd.internal_grd_ref_no = agrd.internal_grd_ref_no
               AND s_agrd.internal_gmr_ref_no = agrd.internal_gmr_ref_no) AS phy_attribute_group_no,
           agrd.internal_gmr_ref_no,
           agrd.internal_grd_ref_no
      FROM agmr_action_gmr agmr, agrd_action_grd agrd
     WHERE agmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no
       AND agmr.action_no = agrd.action_no
       AND agrd.status = 'Active'
       AND agrd.tolling_stock_type = 'None Tolling'
       AND agmr.gmr_latest_action_action_id = 'landingDetail'
       AND agrd.pqpa_phy_attribute_group_no IS NULL;
    
     vc_seq VARCHAR2(50);

BEGIN
  FOR eachitem IN agrd_stock LOOP
    SELECT 'PHY-GRP-' || seq_phy_group.NEXTVAL INTO vc_seq FROM dual;
    --- update agrd for landing with new group no  
    UPDATE agrd_action_grd agrd
       SET agrd.pqpa_phy_attribute_group_no = vc_seq
     WHERE agrd.internal_grd_ref_no = eachitem.internal_grd_ref_no
       AND agrd.action_no = eachitem.action_no;
  
    DECLARE
      CURSOR phyattribute IS
        SELECT pqpa.attribute_id, pqpa.attribute_value, pqpa.rejection
          FROM pqpa_pq_physical_attributes pqpa
         WHERE pqpa.phy_attribute_group_no =
               eachitem.phy_attribute_group_no;
    
      pqpqid VARCHAR2(50);
    BEGIN
      FOR phyattribute_rows IN phyattribute LOOP
      
        SELECT seq_pqpa.NEXTVAL INTO pqpqid FROM dual;
        INSERT INTO pqpa_pq_physical_attributes
        VALUES
          (pqpqid,
           vc_seq,
           phyattribute_rows.attribute_id,
           phyattribute_rows.attribute_value,
           phyattribute_rows.rejection,
           0,
           'Y');
      END LOOP;
    
    END;
  END LOOP;

  COMMIT;
END;
/
--776
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('251', '11', 'DailyPositionBalanceReport.rpt', 'Daily Position Balance Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D251', 'Daily Position Balance Report', 31, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=251&ReportName=DailyPositionBalanceReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL, 
    'N');
insert into REF_REPORTEXPORTFORMAT values('251','EXCEL','DailyPositionBalanceReport.rpt');

BEGIN

for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 
loop

Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY01', 1, 1, 
    'Trade Date', 'GFF021', 1, 'Y');

Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY02', 1, 2, 
    'Profit Center', 'GFF1011', 1, NULL);

Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY03', 1, 3, 
    'Product', 'GFF1011', 1, NULL);


Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY01', 'RFP0104', 'SYSTEM');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY01', 'RFP0026', 'AsOfDate');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY02', 'RFP1045', 'reportProfitcenterList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY02', 'RFP1046', 'ProfitCenter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY02', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY02', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY02', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY02', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY02', 'RFP1051', 'multiple');
 Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY03', 'RFP1045', 'allProducts');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY03', 'RFP1046', 'Product');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY03', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY03', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY03', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '251', 'RFC251PHY03', 'RFP1050', '1');
 end loop;
end;
--777
Insert into BRM_BUSINESS_ROLE_MASTER
   (ROLE_TYPE_CODE, ROLE_TYPE_NAME, SORT_ORDER, IS_ACTIVE)
Values
   ('PLEDGEPARTY', 'Pledge Party', 15, 'Y');
--778
Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('ASH_ASSAY_HEADER_CON_PK', 'CONGPID', 'SEQ_CONGRP');


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
           AND ASH1.IS_DELETE = ''N''
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
  where DGM_ID='DGM-AS' and ACTIVITY_ID='CREATE_ASSAY';
  
  --782
  Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('111', 'LOG', 'Modify Terms And Charges', 10, 2, 
    NULL, 'function(){loadTermsAndChargesToModify();}', NULL, '102', NULL);

INSERT INTO AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 VALUES
   ('modifyGmrTerm', 'GMR', 'Modify Gmr Term', 'N', 'Modify Gmr Term','N', NULL);
   
INSERT INTO CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 VALUES
   ('modifyGmrTerm', 'N', 'N', 'activityDate', 'N', NULL, NULL, 'N', 'N');
 --785
 Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('CREATE_HEDGE_CORRECTION', 'HedgeCorr', 'Create Hedge Correction', 'Y', 'Create Hedge Correction', 
    'N');
    
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_HEDGE_CORRECTION', 'Y', 'N', 'hedgeCorrectionDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('CHCRefNo', 'Hedge Correction Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');
    

 Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('CANCEL_ASSAY', 'Assay ', 'Cancel Assay', 'Y', 'Cancel Assay', 
    'N');
    
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('ASYCRefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');
  BEGIN
for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 
loop


 Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-CHC-&'||CC.CORPORATE_ID, 'CHCRefNo', CC.CORPORATE_ID, 'HC-', 1, 
    0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-CHC-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CREATE_HEDGE_CORRECTION', 'CHCRefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CREATE_HEDGE_CORRECTION', 'HC-', 0, '-'||CC.CORPORATE_ID);

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-ASYC-'||CC.CORPORATE_ID, 'ASYCRefNo', CC.CORPORATE_ID, 'ASY-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-ASYC-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CANCEL_ASSAY', 'ASYCRefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CANCEL_ASSAY', 'ASY-', 0, '-'||CC.CORPORATE_ID);

 end loop;
end;
Update  CYM_COUNTRYMASTER SET NATIONAL_CURRENCY = 'CM-61' Where COUNTRY_ID = 'CYM-399';
----------------------------------------------------------------------------------------------------------------------------------------
-- PURCAHSE SIDE DGM Entry for CHILD TABLE FOR STOCK
----------------------------------------------------------------------------------------------------------------------------------------

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_SD_GRD_D', 'shipmentDetail', 'Shipment Detail', 'shipmentDetail', 2, '1','N');
   
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_RD_GRD_D', 'railDetail', 'Rail Detail', 'railDetail', 2, '1','N');
   
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_TD_GRD_D', 'truckDetail', 'Truck Detail', 'truckDetail', 2, '1','N');
   
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_AD_GRD_D', 'airDetail', 'Air Detail', 'airDetail', 2, '1','N');

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_WN_GRD_D', 'weightNote', 'Purchase Weight Note', 'weightNote', 2, '1','N');
----------------------------------------------------------------------------------------------------------------------------------------
-- SALES SIDE DGM Entry for CHILD TABLE FOR STOCK
----------------------------------------------------------------------------------------------------------------------------------------

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_SA_DGRD_D', 'shipmentAdvise', 'Shipment Advice', 'shipmentAdvise', 2, '1','N');
   
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_RA_DGRD_D', 'railAdvice', 'Rail Advice', 'railAdvice', 2, '1','N');
   
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_TA_DGRD_D', 'truckAdvice', 'Truck Advice', 'truckAdvice', 2, '1','N');
   
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_AA_DGRD_D', 'airAdvice', 'Air Advice', 'airAdvice', 2, '1','N');
   
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_SWN_DGRD_D', 'salesWeightNote', 'Sales Weight Note', 'salesWeightNote', 2, '1','N');
----------------------------------------------------------------------------------------------------------------------------------------
-- PURCAHSE SIDE FETCH QUERY  FOR DGM ALL DETAILS OF CHILD TABLE FOR STOCK
----------------------------------------------------------------------------------------------------------------------------------------
declare
fetchqry clob := 'INSERT INTO sddc_child_grd_d
            (internal_gmr_ref_no, internal_grd_ref_no,
             internal_contract_item_ref_no, internal_doc_ref_no, stock_ref_no,
             net_weight, tare_weight, gross_weight, landed_net_qty,
             landed_gross_qty, current_qty, qty_unit, qty_unit_id,
             container_no, container_size, no_of_bags, no_of_containers,
             no_of_pieces, brand, mark_no, seal_no, customer_seal_no,
             stock_status, remarks)
   SELECT gmr.internal_gmr_ref_no internal_gmr_ref_no,
          agrd.internal_grd_ref_no internal_grd_ref_no,
          agrd.internal_contract_item_ref_no internal_contract_item_ref_no, ?,
          agrd.internal_stock_ref_no internal_stock_ref_no,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.qty
                                                    )
              ),
              4
             ) net_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.tare_weight
                                                    )
              ),
              4
             ) tare_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.gross_weight
                                                    )
              ),
              4
             ) gross_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.landed_net_qty
                                                    )
              ),
              4
             ) landed_net_qty,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.landed_gross_qty
                                                    )
              ),
              4
             ) landed_gross_qty,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.current_qty
                                                    )
              ),
              4
             ) current_qty,
          qum_bl.qty_unit qty_unit, qum_bl.qty_unit_id qty_unit_id,
          agrd.container_no container_no, agrd.container_size container_size,
          agrd.no_of_bags no_of_bags, agrd.no_of_containers no_of_containers,
          agrd.no_of_pieces no_of_pieces, agrd.brand brand,
          agrd.mark_no mark_no, agrd.seal_no seal_no,
          agrd.customer_seal_no customer_seal_no,
          agrd.stock_status stock_status, agrd.remarks remarks
     FROM agrd_action_grd agrd,
          gmr_goods_movement_record gmr,
          agmr_action_gmr agmr,
          qum_quantity_unit_master qum_bl
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agmr.action_no = agrd.action_no
      AND qum_bl.qty_unit_id = agrd.qty_unit_id
      AND agmr.gmr_latest_action_action_id IN
                 (''shipmentDetail'', ''airDetail'', ''truckDetail'', ''railDetail'')
      AND agmr.is_deleted = ''N''
      AND agrd.is_deleted = ''N''
      AND gmr.internal_gmr_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry where DGM_ID IN ('DGM_SD_GRD_D','DGM_RD_GRD_D','DGM_TD_GRD_D','DGM_AD_GRD_D');
  
end;
----------------------------------------------------------------------------------------------------------------------------------------
-- PURCHASE SIDE FETCH QUERY  FOR DGM  WEIGHT NOTE OF CHILD TABLE FOR STOCK
----------------------------------------------------------------------------------------------------------------------------------------

declare
fetchqry1 clob := 'INSERT INTO sddc_child_grd_d
            (internal_gmr_ref_no, internal_grd_ref_no,
             internal_contract_item_ref_no, internal_doc_ref_no, stock_ref_no,
             net_weight, tare_weight, gross_weight, landed_net_qty,
             landed_gross_qty, current_qty, qty_unit, qty_unit_id,
             container_no, container_size, no_of_bags, no_of_containers,
             no_of_pieces, brand, mark_no, seal_no, customer_seal_no,
             stock_status, remarks)
   SELECT gmr.internal_gmr_ref_no internal_gmr_ref_no,
          agrd.internal_grd_ref_no internal_grd_ref_no,
          agrd.internal_contract_item_ref_no internal_contract_item_ref_no, ?,
          agrd.internal_stock_ref_no internal_stock_ref_no,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.qty
                                                    )
              ),
              4
             ) net_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.tare_weight
                                                    )
              ),
              4
             ) tare_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.gross_weight
                                                    )
              ),
              4
             ) gross_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.landed_net_qty
                                                    )
              ),
              4
             ) landed_net_qty,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.landed_gross_qty
                                                    )
              ),
              4
             ) landed_gross_qty,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.current_qty
                                                    )
              ),
              4
             ) current_qty,
          qum_bl.qty_unit qty_unit, qum_bl.qty_unit_id qty_unit_id,
          agrd.container_no container_no, agrd.container_size container_size,
          agrd.no_of_bags no_of_bags, agrd.no_of_containers no_of_containers,
          agrd.no_of_pieces no_of_pieces, agrd.brand brand,
          agrd.mark_no mark_no, agrd.seal_no seal_no,
          agrd.customer_seal_no customer_seal_no,
          agrd.stock_status stock_status, agrd.remarks remarks
     FROM agrd_action_grd agrd,
          gmr_goods_movement_record gmr,
          agmr_action_gmr agmr,
          qum_quantity_unit_master qum_bl
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agmr.action_no = agrd.action_no
      AND qum_bl.qty_unit_id = agrd.qty_unit_id
      AND agmr.gmr_latest_action_action_id = ''weightNote''
      AND agmr.is_deleted = ''N''
      AND agrd.is_deleted = ''N''
      AND gmr.internal_gmr_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('DGM_WN_GRD_D');
  
end;

----------------------------------------------------------------------------------------------------------------------------------------
-- SALES SIDE FETCH QUERY  FOR DGM FOR ALL ADVICE OF CHILD TABLE FOR STOCK
----------------------------------------------------------------------------------------------------------------------------------------

declare
fetchqry2 clob := 'INSERT INTO sadc_child_dgrd_d
            (internal_gmr_ref_no, internal_dgrd_ref_no,
             internal_contract_item_ref_no, internal_doc_ref_no, stock_ref_no,
             net_weight, tare_weight, gross_weight, p_shipped_net_weight,
             p_shipped_gross_weight, p_shipped_tare_weight, landed_net_qty,
             landed_gross_qty, current_qty, net_weight_unit,
             net_weight_unit_id, container_no, container_size, no_of_bags,
             no_of_containers, no_of_pieces, brand, mark_no, seal_no,
             customer_seal_no, stock_status, remarks)
   SELECT gmr.internal_gmr_ref_no internal_gmr_ref_no,
          agrd.internal_grd_ref_no internal_grd_ref_no,
          agrd.internal_contract_item_ref_no internal_contract_item_ref_no,
          ?, agrd.internal_stock_ref_no internal_stock_ref_no,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.net_weight
                                                    )
              ),
              4
             ) net_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.tare_weight
                                                    )
              ),
              4
             ) tare_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.gross_weight
                                                    )
              ),
              4
             ) gross_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.p_shipped_net_weight
                                                    )
              ),
              4
             ) p_shipped_net_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity
                                                  (agrd.product_id,
                                                   agrd.net_weight_unit_id,
                                                   qum_bl.qty_unit_id,
                                                   agrd.p_shipped_gross_weight
                                                  )
              ),
              4
             ) p_shipped_gross_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity
                                                   (agrd.product_id,
                                                    agrd.net_weight_unit_id,
                                                    qum_bl.qty_unit_id,
                                                    agrd.p_shipped_tare_weight
                                                   )
              ),
              4
             ) p_shipped_tare_weight,
          '''' landed_net_qty, '''' landed_gross_qty,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.current_qty
                                                    )
              ),
              4
             ) current_qty,
          qum_bl.qty_unit net_weight_unit,
          qum_bl.qty_unit_id net_weight_unit_id,
          agrd.container_no container_no, agrd.container_size container_size,
          agrd.no_of_bags no_of_bags, agrd.no_of_containers no_of_containers,
          agrd.no_of_pieces no_of_pieces, agrd.brand brand,
          agrd.mark_no mark_no, agrd.seal_no seal_no,
          agrd.customer_seal_no customer_seal_no,
          agrd.stock_status stock_status, agrd.remarks remarks
     FROM adgrd_action_dgrd agrd,
          gmr_goods_movement_record gmr,
          agmr_action_gmr agmr,
          qum_quantity_unit_master qum_bl
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agmr.action_no = agrd.action_no
      AND qum_bl.qty_unit_id = agrd.net_weight_unit_id
      AND agmr.gmr_latest_action_action_id IN
                 (''shipmentAdvise'', ''railAdvice'', ''truckAdvice'', ''airAdvice'')
      AND agmr.is_deleted = ''N''
      AND agrd.status = ''Active''
      AND gmr.internal_gmr_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry2 where DGM_ID IN ('DGM_SA_DGRD_D','DGM_RA_DGRD_D','DGM_TA_DGRD_D','DGM_AA_DGRD_D');
  
end;

---------------------------------------------------------------------------------------------------------------------------------------------------
-- SALES SIDE FETCH QUERY  FOR DGM  SALES WEIGHT NOTE OF CHILD TABLE FOR STOCK
---------------------------------------------------------------------------------------------------------------------------------------------------

declare
fetchqry3 clob := 'INSERT INTO sadc_child_dgrd_d
            (internal_gmr_ref_no, internal_dgrd_ref_no,
             internal_contract_item_ref_no, internal_doc_ref_no, stock_ref_no,
             net_weight, tare_weight, gross_weight, p_shipped_net_weight,
             p_shipped_gross_weight, p_shipped_tare_weight, landed_net_qty,
             landed_gross_qty, current_qty, net_weight_unit,
             net_weight_unit_id, container_no, container_size, no_of_bags,
             no_of_containers, no_of_pieces, brand, mark_no, seal_no,
             customer_seal_no, stock_status, remarks)
   SELECT gmr.internal_gmr_ref_no internal_gmr_ref_no,
          agrd.internal_grd_ref_no internal_grd_ref_no,
          agrd.internal_contract_item_ref_no internal_contract_item_ref_no,
          ?, agrd.internal_stock_ref_no internal_stock_ref_no,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.net_weight
                                                    )
              ),
              4
             ) net_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.tare_weight
                                                    )
              ),
              4
             ) tare_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.gross_weight
                                                    )
              ),
              4
             ) gross_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.p_shipped_net_weight
                                                    )
              ),
              4
             ) p_shipped_net_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity
                                                  (agrd.product_id,
                                                   agrd.net_weight_unit_id,
                                                   qum_bl.qty_unit_id,
                                                   agrd.p_shipped_gross_weight
                                                  )
              ),
              4
             ) p_shipped_gross_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity
                                                   (agrd.product_id,
                                                    agrd.net_weight_unit_id,
                                                    qum_bl.qty_unit_id,
                                                    agrd.p_shipped_tare_weight
                                                   )
              ),
              4
             ) p_shipped_tare_weight,
          '''' landed_net_qty, '''' landed_gross_qty,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.current_qty
                                                    )
              ),
              4
             ) current_qty,
          qum_bl.qty_unit net_weight_unit,
          qum_bl.qty_unit_id net_weight_unit_id,
          agrd.container_no container_no, agrd.container_size container_size,
          agrd.no_of_bags no_of_bags, agrd.no_of_containers no_of_containers,
          agrd.no_of_pieces no_of_pieces, agrd.brand brand,
          agrd.mark_no mark_no, agrd.seal_no seal_no,
          agrd.customer_seal_no customer_seal_no,
          agrd.stock_status stock_status, agrd.remarks remarks
     FROM adgrd_action_dgrd agrd,
          gmr_goods_movement_record gmr,
          agmr_action_gmr agmr,
          qum_quantity_unit_master qum_bl
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agmr.action_no = agrd.action_no
      AND qum_bl.qty_unit_id = agrd.net_weight_unit_id
      AND agmr.gmr_latest_action_action_id = ''salesWeightNote''
      AND agmr.is_deleted = ''N''
      AND agrd.status = ''Active''
      AND gmr.internal_gmr_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry3 where DGM_ID IN ('DGM_SWN_DGRD_D');
  
end;
UPDATE pcmte_pcm_tolling_ext pcmte
   SET pcmte.is_free_metal_applicable = 'Y'
 WHERE pcmte.is_free_metal_applicable IS NULL AND pcmte.is_pass_through = 'Y';
 
 delete from sls_static_list_setup sls where sls.list_type = 'GroupList';
delete from slv_static_list_value slv where slv.value_id in ('Group','UnGroup');
delete from ref_reportexportformat where report_id = '252';
delete from rpc_rf_parameter_config rpc where rpc.report_id = '252';
delete from rfc_report_filter_config rfc where rfc.report_id = '252';
delete from amc_app_menu_configuration amc where amc.menu_id = 'RPT-D2496';
delete from rml_report_master_list rml where rml.report_id = '252';
commit;
SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Group', 'Group');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('UnGroup', 'UnGroup');
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('GroupList', 'UnGroup', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('GroupList', 'Group', 'N', 2);
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('252', '11', 'GlobalPositionReport.rpt', 'Global Position Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('252', 'EXCEL', 'GlobalPositionReport.rpt');
COMMIT;
SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D2496', 'Global Position Report', 32, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=252&ReportName=GlobalPositionReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL, 
    'N');
COMMIT;
SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
  loop
    dbms_output.put_line(cc.corporate_id);
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '252', 'RFC252PHY03', 1, 3, 
    'Product', 'GFF1011', 1, NULL);
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '252', 'RFC252PHY01', 1, 1, 
    'Report Date', 'GFF021', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '252', 'RFC252PHY04', 1, 4, 
    'Group', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '252', 'RFC252PHY02', 1, 2, 
    'Profit Center', 'GFF1011', 1, NULL);
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY01', 'RFP0104', 'SYSTEM');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY01', 'RFP0026', 'AsOfDate');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY04', 'RFP1060', 'GroupList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY04', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY04', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY04', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY04', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY04', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY04', 'RFP1061', 'Groping');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY02', 'RFP1045', 'reportProfitcenterList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY02', 'RFP1046', 'ProfitCenter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY02', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY02', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY02', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY02', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY03', 'RFP1045', 'allProducts');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY03', 'RFP1046', 'Product');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY03', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY03', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY03', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY03', 'RFP1050', '1');
COMMIT;
 end loop;
commit;
end;
set define off;
update RML_REPORT_MASTER_LIST rml  set RML.IS_ACTIVE = 'Y' where RML.REPORT_ID in ( '213','216');

update rml_report_master_list rml set RML.REPORT_FILE_NAME = 'DailyOpenUnrealizedPhysicalConc_Cog.rpt' where RML.REPORT_ID = '213';

update RML_REPORT_MASTER_LIST rml set RML.REPORT_FILE_NAME = 'DailyInventoryUnrealizedPhysicalPnLConc_Cog.rpt' where RML.REPORT_ID = '216';

update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_DISPLAY_NAME = 'Daily Open Unrealized Physical P&L (Conc)' , AMC.LINK_CALLED = 
             '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=213&ReportName=DailyOpenUnrealizedPhysicalConc_Cog.rpt&ExportFormat=HTML&isEodReport=Y',AMC.IS_DELETED = 'N'
             where AMC.MENU_ID = 'RPT-D224';
             
update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_DISPLAY_NAME = 'Daily Inventory Unrealized Physical P&L (Conc)' , AMC.LINK_CALLED = 
             '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=216&ReportName=DailyInventoryUnrealizedPhysicalPnLConc_Cog.rpt&ExportFormat=HTML&isEodReport=Y' ,AMC.IS_DELETED = 'N'
             where AMC.MENU_ID = 'RPT-D225';             

Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('253', '21', 'DailyRealizedPNLReportConc_Cog.rpt', 'Daily Realized PNL Report Conc_Cog', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');

SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D253', 'Daily Realized PNL Report P&L (Conc)', 23, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=249&ReportName=DailyRealizedPNLReportConc_Cog.rpt.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D22', 'APP-ACL-N1296', 'Reports', 'APP-PFL-N-214', 
    'N');
set define off;
UPDATE RML_REPORT_MASTER_LIST rml set RML.REPORT_display_NAME = 'Monthly Open Unrealized Physical Conc Cog' , RML.REPORT_FILE_NAME = 'MonthlyOpenUnrealizedPhysicalConc_Cog.rpt' 
 where RML.REPORT_ID = '226';
 
 
UPDATE RML_REPORT_MASTER_LIST rml set RML.REPORT_display_NAME = 'Monthly Inventory Unrealized Physical PnL Conc Cog' , RML.REPORT_FILE_NAME = 'MonthlyInventoryUnrealizedPhysicalPnLConc_Cog.rpt' 
 where RML.REPORT_ID = '228';
 
DELETE FROM AMC_APP_MENU_CONFIGURATION amc
  where AMC.MENU_ID = 'RPT-D232';
  
DELETE FROM AMC_APP_MENU_CONFIGURATION amc
  where AMC.MENU_ID = 'RPT-D234';
  
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D232', 'Monthly Open Unrealized Physical Conc Cog', 12, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=226&ReportName=MonthlyOpenUnrealizedPhysicalConc_Cog.rpt&ExportFormat=HTML&isEodReport=Y', 'RPT-D23', 'APP-ACL-N1302', 'Reports', 'APP-PFL-N-215', 'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D234', 'Monthly Inventory Unrealized Physical PnL Conc Cog', 14, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=228&ReportName=MonthlyInventoryUnrealizedPhysicalPnLConc_Cog.rpt&ExportFormat=HTML&isEodReport=Y', 'RPT-D23', 'APP-ACL-N1304', 'Reports', 'APP-PFL-N-215', 'N');

-- update AMC_APP_MENU_CONFIGURATION amc set AMC.DISPLAY_SEQ_NO = '21' where AMC.MENU_ID = 'RPT-D235';
 
  
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('254', '31', 'MonthlyRealizedPNLReportConc_Cog.rpt', 'Monthly Realized PNL Report Conc Cog', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D254', 'Monthly Realized PNL Report Conc Cog',21, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=250&ReportName=MonthlyRealizedPNLReportConc_Cog.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', 'APP-ACL-N1304', 'Reports', 'APP-PFL-N-215', 
    'N');

COMMIT;
Delete from REF_REPORTEXPORTFORMAT ref where REF.REPORT_ID in ('213','216','250');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('216', 'EXCEL', 'DailyInventoryUnrealizedPhysicalPnLConc_Cog_Excel.rpt');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('213', 'EXCEL', 'DailyOpenUnrealizedPhysicalConc_Cog_Excel.rpt');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('253', 'EXCEL', 'DailyRealizedPNLReportConc_Cog_Excel.rpt');

BEGIN
for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 
loop
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (CC.CORPORATE_ID, '253', 'RFC253PHY01', 1, 1, 
    'EOD Date', 'GFF021', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (CC.CORPORATE_ID, '253', 'RFC253PHY02', 1, 2, 
    'Profit Center', 'GFF1011', 1, NULL);
--------
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '253', 'RFC253PHY01', 'RFP0104', 'SYSTEM');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '253', 'RFC253PHY01', 'RFP0026', 'AsOfDate');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '253', 'RFC253PHY02', 'RFP1045', 'reportProfitcenterList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '253', 'RFC253PHY02', 'RFP1046', 'Book');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '253', 'RFC253PHY02', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '253', 'RFC253PHY02', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '253', 'RFC253PHY02', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '253', 'RFC253PHY02', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '253', 'RFC253PHY02', 'RFP1051', 'multiple');

end loop;

COMMIT;
end;

BEGIN

for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 
loop

Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY01', 1, 1, 
    'EOM Month', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY02', 1, 3, 
    'Profit Center', 'GFF1011', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY04', 1, 2, 
    'EOM Year', 'GFF1012', 1, 'Y');

Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY04', 'RFP1060', 'yearList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY04', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY02', 'RFP1045', 'reportProfitcenterList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY02', 'RFP1046', 'Book');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY02', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY02', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY02', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY02', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '254', 'RFC254PHY02', 'RFP1051', 'multiple');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY01', 'RFP1061', 'Month');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY01', 'RFP1060', 'MonthList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY01', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY01', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY01', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY01', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY01', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY04', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY04', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY04', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY04', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '254', 'RFC254PHY04', 'RFP1061', 'Year');
COMMIT;

END LOOP;

END;
UPDATE rpc_rf_parameter_config rpc
   SET rpc.report_parameter_name = 'ProfitCenter'
 WHERE rpc.report_id IN ('213', '216', '253', '226', '228', '254')
   AND rpc.report_parameter_name = 'Book';
 Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_FREEMETAL_UTILITY', 'FreeMetalUtil', 'FreeMetal Utility Creation', 'N', 'FreeMetal Utility Created', 
    'Y', NULL);

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('FMUtilRefNo', 'Utility Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('FREEMETAL_PRICE_FIXATION', 'FreeMetalUtil', 'FreeMetal Price Fixation', 'N', 'FreeMetal Price Fixation', 
    'Y', NULL);

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('FMPricefix', 'Price Fixation', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('ROLLBACK_FREEMETAL_UTILITY', 'RollbackUtil', 'Rollback FreeMetal Util', 'N', 'Rollback FreeMetal Util', 
    'Y', NULL);

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('FMRollback', 'Rollback Utility', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('LOFMU', 'List Of Free Metal Utility', 10, 3, '/metals/loadListOfFreeMetalUtility.action?gridId=LOFM_UTILITY', 
    NULL, 'F2', 'APP-ACL-N1085', 'Finance', 'APP-PFL-N-187', 
    'N');

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOFM_UTILITY', 'List Of Free Metal Utility', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"freeMetalUtilityRefNo","header":"Free Metal Utility Ref. No","id":1,"sortable":true,"width":150},{"dataIndex":"cpName","header":"Smelter","id":2,"sortable":true,"width":150},{"header":"Free Metal","id":3,"sortable":false,"width":150},{"dataIndex":"qpMonthYear","header":"QP Pricing","id":4,"sortable":false,"width":150},{"dataIndex":"yearMonthOfConsumption","header":"Consumption Month/Year","id":5,"sortable":true,"width":150},{"dataIndex":"runBy","header":"Run By","id":6,"sortable":true,"width":150},{"dataIndex":"runOn","header":"Run On","id":7,"sortable":true,"width":150},{"dataIndex":"status","header":"Status","id":8,"sortable":true,"width":150}]', 'Finance', '/metals/loadListOfFreeMetalUtility.action', 
    '[ {name : ''utilityHeaderId'',mapping : ''utilityHeaderId''}, 
  {name : ''freeMetalUtilityRefNo'',mapping : ''freeMetalUtilityRefNo''},
  {name : ''cpName'',mapping : ''cpName''},
  {name : ''qpMonthYear'',mapping : ''qpMonthYear''},
  {name : ''yearMonthOfConsumption'',mapping : ''yearMonthOfConsumption''},
  {name : ''runBy'',mapping : ''runBy''},
  {name : ''runOn'',mapping : ''runOn''},
  {name : ''status'',mapping : ''status''} ]', NULL, '/private/jsp/mining/physical/pricing/freemetalpricing/listOfFreeMetalUtility.jsp', '/private/js/mining/physical/pricing/freemetalpricing/listOfFreeMetalUtility.js');


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOFMU_1', 'LOFM_UTILITY', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOFMU_4', 'LOFM_UTILITY', 'Roll Back', 3, 2, 
    'APP-PFL-N-187', 'function(){runRollBack();}', NULL, 'LOFMU_1', NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOFMU_2', 'LOFM_UTILITY', 'Run Utility', 1, 2, 
    'APP-PFL-N-187', 'function(){runFreeMetalUtility();}', NULL, 'LOFMU_1', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOFMU_3', 'LOFM_UTILITY', 'Re-run Pricing', 2, 2, 
    'APP-PFL-N-187', 'function(){reRunPricing();}', NULL, 'LOFMU_1', NULL);
BEGIN

for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 

loop

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-FMU-&'||CC.CORPORATE_ID, 'FMUtilRefNo', CC.CORPORATE_ID, 'FM-UTIL-', 1, 
    0,  '-'||CC.CORPORATE_ID, 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-FMU-&'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CREATE_FREEMETAL_UTILITY', 'FMUtilRefNo', 'N');

Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CREATE_FREEMETAL_UTILITY', 'FM-UTIL-', 0, '-'||CC.CORPORATE_ID);


Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-FP-&'||CC.CORPORATE_ID, 'FMPricefix', CC.CORPORATE_ID, 'FM-PF-', 1, 
    0,  '-'||CC.CORPORATE_ID, 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-FP-&'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'FREEMETAL_PRICE_FIXATION', 'FMPricefix', 'N');

Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'FREEMETAL_PRICE_FIXATION', 'FM-PF-', 0, '-'||CC.CORPORATE_ID);


Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-RU-&'||CC.CORPORATE_ID, 'FMRollback', CC.CORPORATE_ID, 'FM-RU-', 1, 
    0,  '-'||CC.CORPORATE_ID, 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-RU-&'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'ROLLBACK_FREEMETAL_UTILITY', 'FMRollback', 'N');

Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'ROLLBACK_FREEMETAL_UTILITY', 'FM-RU-', 0, '-'||CC.CORPORATE_ID);
 

 end loop;

end;


delete from REF_REPORTEXPORTFORMAT where report_id = '251';
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('251', 'EXCEL', 'DailyPositionBalanceReport_Excel.rpt');

begin
for cc in(select * from AK_CORPORATE akc where AKC.IS_ACTIVE = 'Y' and AKC.IS_INTERNAL_CORPORATE = 'N')
loop


Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.CORPORATE_ID, '251', 'RFC251PHY04', 1, 4, 
    'Business Line', 'GFF1011', 1, NULL);

Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '251', 'RFC251PHY04', 'RFP1045', 'mdmBusinessLine');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '251', 'RFC251PHY04', 'RFP1046', 'BusinessLine');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '251', 'RFC251PHY04', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '251', 'RFC251PHY04', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '251', 'RFC251PHY04', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '251', 'RFC251PHY04', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.CORPORATE_ID, '251', 'RFC251PHY04', 'RFP1051', 'multiple');
   
end loop;   
end;

update RFC_REPORT_FILTER_CONFIG rfc
set RFC.LABEL_ROW_NUMBER = 5
where RFC.LABEL_ID = 'RFC252PHY04';
update RFC_REPORT_FILTER_CONFIG rfc
set RFC.IS_MANDATORY = 'Y'
where RFC.LABEL_ID in ('RFC252PHY02','RFC252PHY03');
commit;

delete from RPC_RF_PARAMETER_CONFIG rpc where RPC.LABEL_ID = 'RFC252PHY05';
delete from RFC_REPORT_FILTER_CONFIG rfc where RfC.LABEL_ID = 'RFC252PHY05';
commit;

SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
  loop
    dbms_output.put_line(cc.corporate_id);
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 1, 4, 
    'Business Line', 'GFF1011', 1, 'Y');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1045', 'mdmBusinessLine');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1046', 'BusinessLine');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1050', '1');
COMMIT;
 end loop;
commit;
end;
declare
fetchqry1 clob := 'INSERT INTO IS_D(
INVOICE_REF_NO,
INVOICE_TYPE_NAME,
INVOICE_CREATION_DATE,
INVOICE_DRY_QUANTITY,
INVOICE_WET_QUANTITY,
MOISTURE,
INVOICED_QTY_UNIT,
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
MATERIAL_COST,
ADDDITIONAL_CHARGES,
TAXES,
DUE_DATE,
SUPPLIRE_INVOICE_NO,
CONTRACT_DATE,
CONTRACT_REF_NO,
STOCK_QUANTITY,
STOCK_REF_NO,
INVOICE_AMOUNT_UNIT,
GMR_REF_NO,
GMR_QUALITY,
CONTRACT_QUANTITY,
CONTRACT_QTY_UNIT,
CONTRACT_TOLERANCE,
QUALITY,
PRODUCT,
CP_CONTRACT_REF_NO,
PAYMENT_TERM,
GMR_FINALIZE_QTY,
CP_NAME,
CP_ADDRESS,
CP_COUNTRY,
CP_CITY,
CP_STATE,
CP_ZIP,
CONTRACT_TYPE,
ORIGIN,
INCO_TERM_LOCATION,
NOTIFY_PARTY,
SALES_PURCHASE,
INVOICE_STATUS,
INTERNAL_DOC_REF_NO
)
with test as (select invs.INTERNAL_INVOICE_REF_NO, sum(ASM.NET_WEIGHT) as wet,
sum(ASM.DRY_WEIGHT) as dry
from 
IS_INVOICE_SUMMARY invs,
ASH_ASSAY_HEADER ash,
ASM_ASSAY_SUBLOT_MAPPING asm,
IAM_INVOICE_ASSAY_MAPPING iam
where
INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
and IAM.ASH_ID = ASH.ASH_ID
and ASH.ASH_ID = ASM.ASH_ID
group by invs.INTERNAL_INVOICE_REF_NO
)
select
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME as INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE as INVOICE_CREATION_DATE,
t.DRY as INVOICE_DRY_QUANTITY,
t.WET as INVOICE_WET_QUANTITY,
ROUND((((t.WET - t.DRY)/t.WET)*100),2) as MOISTURE,
QUM_GMR.QTY_UNIT as INVOICED_QTY_UNIT,
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ as MATERIAL_COST,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as ADDDITIONAL_CHARGES,
INVS.TOTAL_TAX_AMOUNT as TAXES,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
INVS.CP_REF_NO as SUPPLIER_INVOICE_NO,
PCM.ISSUE_DATE as CONTRACT_DATE,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
sum(II.INVOICABLE_QTY) as STOCK_QUANTITY,
stragg(DISTINCT II.STOCK_REF_NO) as STOCK_REF_NO,
NVL (cm_pct.cur_code, cm.cur_code) AS invoice_amount_unit,
stragg(DISTINCT GMR.GMR_REF_NO) as GMR_REF_NO,
sum(GMR.QTY) as GMR_QUALITY,
PCPD.QTY_MAX_VAL as CONTRACT_QUANTITY,
QUM.QTY_UNIT as CONTRACT_QTY_UNIT,
PCPD.MAX_TOLERANCE as CONTRACT_TOLERANCE,
QAT.QUALITY_NAME as QUALITY,
PDM.PRODUCT_DESC as PRODUCT,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM as PAYMENT_TERM,
GMR.FINAL_WEIGHT as GMR_FINALIZE_QTY,
PHD.COMPANYNAME as CP_NAME,
PAD.ADDRESS as CP_ADDRESS,
CYM.COUNTRY_NAME as CP_COUNTRY,
CIM.CITY_NAME as CP_CITY,
SM.STATE_NAME as CP_STATE,
PAD.ZIP as CP_ZIP,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME as ORIGIN,
PCI.TERMS as INCO_TERM_LOCATION,
nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME) as NOTIFY_PARTY, 
PCI.CONTRACT_TYPE as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
?
from 
IS_INVOICE_SUMMARY invs,
IID_INVOICABLE_ITEM_DETAILS iid,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
II_INVOICABLE_ITEM ii,
CM_CURRENCY_MASTER cm,
GMR_GOODS_MOVEMENT_RECORD gmr,
PCPD_PC_PRODUCT_DEFINITION pcpd,
QUM_QUANTITY_UNIT_MASTER qum,
PCPQ_PC_PRODUCT_QUALITY pcpq,
QAT_QUALITY_ATTRIBUTES qat,
PDM_PRODUCTMASTER pdm,
PHD_PROFILEHEADERDETAILS phd,
PYM_PAYMENT_TERMS_MASTER pym,
PAD_PROFILE_ADDRESSES pad,
CYM_COUNTRYMASTER cym,
CIM_CITYMASTER cim,
SM_STATE_MASTER sm,
BPAT_BP_ADDRESS_TYPE bpat,
CYM_COUNTRYMASTER cymloading,
SAD_SHIPMENT_ADVICE sad,
SD_SHIPMENT_DETAIL sd,
PHD_PROFILEHEADERDETAILS phd1,
PHD_PROFILEHEADERDETAILS phd2,
QUM_QUANTITY_UNIT_MASTER qum_gmr,
cm_currency_master cm_pct,
test t
where
INVS.INTERNAL_INVOICE_REF_NO = IID.INTERNAL_INVOICE_REF_NO(+)
and IID.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO(+)
and IID.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO(+)
and IID.INVOICABLE_ITEM_ID = II.INVOICABLE_ITEM_ID(+)
and IID.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INVOICE_CURRENCY_ID = CM.CUR_ID(+)
and II.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INTERNAL_CONTRACT_REF_NO = PCPD.INTERNAL_CONTRACT_REF_NO(+)
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
and PCPD.PCPD_ID = PCPQ.PCPD_ID(+)
and PCI.QUALITY_ID = QAT.QUALITY_ID(+)
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
and INVS.CP_ID = PHD.PROFILEID(+)
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID(+)
and PHD.PROFILEID = PAD.PROFILE_ID(+)
and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.NOTIFY_PARTY_ID = PHD1.PROFILEID(+)
and SD.NOTIFY_PARTY_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and invs.invoice_cur_id = cm_pct.cur_id(+)
and PAD.ADDRESS_TYPE(+) = ''Billing''
and PAD.IS_DELETED(+) = ''N''
and PCPD.INPUT_OUTPUT in (''Input'')
and t.INTERNAL_INVOICE_REF_NO = INVS.INTERNAL_INVOICE_REF_NO
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
INVS.INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE,
INVS.INVOICED_QTY,
INVS.INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
INVS.TOTAL_TAX_AMOUNT,
INVS.PAYMENT_DUE_DATE,
INVS.CP_REF_NO,
PCM.ISSUE_DATE,
PCM.CONTRACT_REF_NO,
CM.CUR_CODE,
PCPD.QTY_MAX_VAL,
QUM.QTY_UNIT,
PCPD.MAX_TOLERANCE,
QAT.QUALITY_NAME,
PDM.PRODUCT_DESC,
PCM.CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM,
GMR.FINAL_WEIGHT,
PHD.COMPANYNAME,
PAD.ADDRESS,
CYM.COUNTRY_NAME,
CIM.CITY_NAME,
SM.STATE_NAME,
PAD.ZIP,
PCM.CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME,
PCI.TERMS,
PHD1.COMPANYNAME,
PHD2.COMPANYNAME,
QUM_GMR.QTY_UNIT,
PCI.CONTRACT_TYPE,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ,
INVS.INVOICE_STATUS,
cm_pct.cur_code,
t.DRY,
t.WET';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('DGM-PIC','11','10','DGM-FIC','DGM-DFIC','12');
  
end;

declare
fetchqry clob := 'Insert into SDD_D
  (ATTENTION,
   BUYER,
   CONTRACT_DATE,
   CONTRACT_ITEM_NO,
   CONTRACT_QTY,
   CONTRACT_QTY_UNIT,
   CONTRACT_REF_NO,
   CP_REF_NO,
   DESTINATION_LOCATION,
   DISCHARGE_COUNTRY,
   DISCHARGE_PORT,
   ETA_END,
   ETA_START,
   FULFILMENT_TYPE,
   GOODS,
   INCO_TERMS,
   INTERNAL_CONTRACT_ITEM_REF_NO,
   INTERNAL_DOC_REF_NO,
   INTERNAL_GMR_REF_NO,
   IS_OTHER_OPTIONAL_PORTS,
   ISSUE_DATE,
   LOADING_COUNTRY,
   LOADING_LOCATION,
   LOADING_PORT,
   OTHER_SHIPMENT_TERMS,
   PACKING_TYPE,
   QTY_OF_GOODS,
   QTY_OF_GOODS_UNIT,
   SELLER,
   TOLERANCE_LEVEL,
   TOLERANCE_MAX,
   TOLERANCE_MIN,
   TOLERANCE_TYPE,
   VESSEL_NAME,
   BL_DATE,
   BL_NUMBER,
   BL_QUANTITY,
   BL_QUANTITY_UNIT,
   OPTIONAL_DESTIN_PORTS,
   OPTIONAL_ORIGIN_PORTS,
   CREATED_DATE,
   PARITY_LOCATION,
   PRODUCTANDQUALITY,
   NOTIFYPARITY,
   SHIPPER,
   NOTES,
   SPECIALINSTRUCTIONS,
   VOYAGENUMBER,
   SHIPPERREFNO,
   TRANSSHIPMENTPORT,
   ETADESTINATIONPORT,
   SHIPPERSINSTRUCTIONS,
   CARRIERAGENTSENDORSEMENTS,
   WHOLENEWREPORT,
   CONTAINER_NOS,
   QUANTITY,
   QUANTITY_UNIT,
   QUANTITY_DECIMALS,
   NET_WEIGNT_GMR,
   NET_WEIGHT_UNIT_GMR,
   DECIMALS,
   BLDATE_BLNO,
   BL_QUANTITY_DECIMALS,
   ACTIVITY_DATE,
   FLIGHT_NUMBER,
   DESTINATION_AIRPORT,
   AWB_DATE,
   AWB_NUMBER,
   AWB_QUANTITY,
   LOADING_AIRPORT,
   LOADING_DATE,
   ENDORSEMENTS,
   OTHER_AIRWAY_BILLING_ITEM,
   NO_OF_PIECES,
   NATURE_OF_GOOD,
   DIMENSIONS,
   STOCK_REF_NO,
   NET_WEIGHT,
   TARE_WEIGHT,
   GROSS_WEIGHT,
   COMMODITY_DESCRIPTION,
   COMMENTS,
   ACTIVITY_REF_NO,
   WEIGHER,
   WEIGHER_NOTE_NO,
   WEIGHING_DATE,
   REMARKS,
   RAIL_NAME_NUMBER,
   RR_DATE,
   RR_NUMBER,
   TOTAL_QTY,
   RR_QTY,
   TRUCK_NUMBER,
   CMR_DATE,
   CMR_NUMBER,
   CMR_QUANTITY,
   OTHER_TRUCKING_TERMS,
   TRUCKING_INSTRUCTIONS,
   CP_ADDRESS,
   CP_LOCATION)

SELECT '''' ATTENTION,
         phd.companyname buyer,
         pcm.issue_date contractdate,
         (SELECT f_string_aggregate(pci.contract_item_ref_no)
            FROM v_pci pci, agrd_action_grd agrd
           WHERE pci.internal_contract_item_ref_no =
                 agrd.internal_contract_item_ref_no
             AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') contractitemno,
         pcpd.qty_max_val contractqty,
         qum.qty_unit contractqtyunit,
         pcm.contract_ref_no contractrefno,
         pcm.cp_contract_ref_no,
         cym.country_name destination_location,
         cym.country_name dischargecountry,
         cim.city_name,
         vd.etd etaend,
         vd.eta etastart,
         '''' FULFILMENT_TYPE,
         '''' GOODS,
         (SELECT f_string_aggregate(pci.incoterm)
            FROM v_pci pci, agrd_action_grd agrd
           WHERE pci.internal_contract_item_ref_no =
                 agrd.internal_contract_item_ref_no
             AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') incoterm,
         (SELECT f_string_aggregate(pci.internal_contract_item_ref_no)
            FROM v_pci pci, agrd_action_grd agrd
           WHERE pci.internal_contract_item_ref_no =
                 agrd.internal_contract_item_ref_no
             AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') internalcontractitemrefno,
          ?,
         gmr.internal_gmr_ref_no internalgmrrefno,
         '''' IS_OTHER_OPTIONAL_PORTS,
         '''' issue_date,
         cyml.country_name loadingcountry,
         cyml.country_name loading_location,
         cim_load.city_name loadingport,
         '''' OTHER_SHIPMENT_TERMS,
         '''' packing_type,
         (SELECT SUM(pkg_general.f_get_converted_quantity(agrd.product_id,
                                                          agrd.qty_unit_id,
                                                          gmr.qty_unit_id,
                                                          agrd.qty))
            FROM agrd_action_grd agrd
           WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') qty_of_goods,
         qumbl.qty_unit,
         phdnp.companyname seller,
         '''' TOLERANCE_LEVEL,
         pcpd.max_tolerance maxtolerance,
         pcpd.min_tolerance mintolerance,
         pcpd.tolerance_type tolerancetype,
         vd.vessel_voyage_name vesselname,
         wrd.storage_date bldate,
         gmr.bl_no blnumber,
         gmr.qty blqty,
         qumbl.qty_unit blqtyunit,
         '''' OPTIONAL_DESTIN_PORTS,
         '''' OPTIONAL_ORIGIN_PORTS,
         to_char(gmr.created_date, ''dd-Mon-yyyy'') createddate,
         (SELECT f_string_aggregate(pci.incoterm_location)
            FROM v_pci pci, agrd_action_grd agrd
           WHERE pci.internal_contract_item_ref_no =
                 agrd.internal_contract_item_ref_no
             AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') parity_location,
         
         (SELECT f_string_aggregate(pdm.product_desc || '' , '' ||
                                    qat.quality_name)
            FROM pdm_productmaster      pdm,
                 qat_quality_attributes qat,
                 agrd_action_grd        agrd
           WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N''
             AND pdm.product_id = agrd.product_id
             AND qat.quality_id = agrd.quality_id) productandquality,
         phdnp.companyname notifyparty,
         '''' shipper,
         vd.notes notes,
         vd.special_instructions specialinst,
         vd.voyage_number voyagenumber,
         vd.shippers_ref_no shipperrefno,
         '''' transport,
         TO_CHAR(vd.eta, ''dd-Mon-yyyy'') etadestinationport,
         vd.shippers_instructions shippersinstructions,
         vd.carriers_agents_endorsements carrieragentsendorsements,
         '''' WHOLENEWREPORT,
         (SELECT f_string_aggregate(agrd.no_of_containers)
            FROM agrd_action_grd agrd
           WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') container_nos,
         gmr.qty quantity,
         qum_gmr.qty_unit quantity_unit,
         qum_gmr.decimals quantity_decimals,
         gmr.current_qty net_weignt_gmr,
         qum_gmr.qty_unit net_weight_unit_gmr,
         qum_gmr.decimals decimals,
         ((to_char(gmr.bl_date, ''dd-Mon-yyyy'')) || '' '' || gmr.bl_no) bldate_blno,
         qum_gmr.decimals bl_quantity_decimals,
         to_char(axs.action_date, ''dd-Mon-yyyy'') activity_date,
         vd.voyage_number flight_number,
         cym_vd.country_name destination_airport,
         '''' awb_date,
         '''' awb_number,
         gmr.qty awb_quantity,
         cym_vdl.country_name loading_airport,
         vd.loading_date loading_date,
         '''' ENDORSEMENTS,
         '''' OTHER_AIRWAY_BILLING_ITEM,
         vd.no_of_pieces no_of_pieces,
         vd.nature_of_goods nature_of_good,
         vd.dimensions dimensions,
         '''',
         gmr.qty net_weight,
         gmr.total_tare_weight tare_weight,
         gmr.total_gross_weight gross_weight,
         '''' COMMODITY_DESCRIPTION,
         wrd.internal_remarks comments,
         wrd.activity_ref_no ACTIVITY_REF_NO,
         '''' WEIGHER,
         '''' WEIGHER_NOTE_NO,
         '''' WEIGHING_DATE,
         wrd.notes REMARKS,
         (vd.vessel_voyage_name || '' '' || vd.voyage_number) rail_name_number,
         '''' rr_date,
         '''' rr_number,
         gmr.qty total_qty,
         gmr.qty rr_qty,
         vd.shippers_ref_no truck_number,
         '''' cmr_date,
         '''' cmr_number,
         gmr.qty cmr_quantity,
         '''' OTHER_TRUCKING_TERMS,
         vd.comments trucking_instructions,
         (select max(pad.address)
            from pad_profile_addresses pad
           where pad.profile_id = pcm.cp_id
             and pad.address_type = ''Main'') cp_address,
         (select max(cim.city_name || '','' || cym.country_name)
            from pad_profile_addresses pad,
                 cim_citymaster        cim,
                 cym_countrymaster     cym
           where pad.profile_id = pcm.cp_id
             and pad.address_type = ''Main''
             and pad.city_id = cim.city_id(+)
             and pad.country_id = cym.country_id(+)) cp_location
    FROM gmr_goods_movement_record    gmr,
         vd_voyage_detail             vd,
         WRD_WAREHOUSE_RECEIPT_DETAIL wrd,
         agmr_action_gmr              agmr,
         axs_action_summary           axs,
         phd_profileheaderdetails     phd,
         phd_profileheaderdetails     phdnp,
         pcm_physical_contract_main   pcm,
         pcpd_pc_product_definition   pcpd,
         qum_quantity_unit_master     qum,
         cym_countrymaster            cym,
         cym_countrymaster            cyml,
         cym_countrymaster            cym_vd,
         cym_countrymaster            cym_vdl,
         cim_citymaster               cim,
         cim_citymaster               cim_load,
         qum_quantity_unit_master     qumbl,
         qum_quantity_unit_master     qum_gmr
   WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
     And VD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
     And WRD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
     And WRD.ACTION_NO = AGMR.ACTION_NO
     And gmr.internal_action_ref_no = axs.internal_action_ref_no
     AND agmr.gmr_latest_action_action_id = ''landingDetail''
     AND agmr.is_deleted = ''N''
     AND agmr.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pcm.cp_id = phd.profileid
     AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
     AND pcpd.qty_unit_id = qum.qty_unit_id
     AND gmr.discharge_country_id = cym.country_id
     AND gmr.loading_country_id = cyml.country_id
     AND gmr.loading_country_id = cym_vd.country_id
     AND gmr.loading_country_id = cym_vdl.country_id
     AND vd.discharge_city_id = cim.city_id(+)
     AND vd.loading_city_id = cim_load.city_id(+)
     AND gmr.qty_unit_id = qumbl.qty_unit_id
     AND wrd.sender_id = phdnp.profileid(+)
     AND gmr.qty_unit_id = qum_gmr.qty_unit_id
     AND gmr.internal_gmr_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry where DGM_ID = '24';
  
end;


----------------------------------------------------------------------------------------------------------------------------------------
-- PURCAHSE SIDE DGM Entry for CHILD TABLE FOR STOCK -- Landing Details
----------------------------------------------------------------------------------------------------------------------------------------

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_LD_GRD_D', 'landingDetail', 'Landing Detail', 'landingDetail', 2, '1','N');


----------------------------------------------------------------------------------------------------------------------------------------
-- PURCAHSE SIDE FETCH QUERY  FOR DGM  Landing Details
----------------------------------------------------------------------------------------------------------------------------------------
declare
fetchqry clob := 'INSERT INTO sddc_child_grd_d
            (internal_gmr_ref_no, internal_grd_ref_no,
             internal_contract_item_ref_no, internal_doc_ref_no, stock_ref_no,
             net_weight, tare_weight, gross_weight, landed_net_qty,
             landed_gross_qty, current_qty, qty_unit, qty_unit_id,
             container_no, container_size, no_of_bags, no_of_containers,
             no_of_pieces, brand, mark_no, seal_no, customer_seal_no,
             stock_status, remarks)
 SELECT gmr.internal_gmr_ref_no internal_gmr_ref_no,
          agrd.internal_grd_ref_no internal_grd_ref_no,
          agrd.internal_contract_item_ref_no internal_contract_item_ref_no, ?,
          agrd.internal_stock_ref_no internal_stock_ref_no,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.qty
                                                    )
              ),
              4
             ) net_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.tare_weight
                                                    )
              ),
              4
             ) tare_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.gross_weight
                                                    )
              ),
              4
             ) gross_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.landed_net_qty
                                                    )
              ),
              4
             ) landed_net_qty,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.landed_gross_qty
                                                    )
              ),
              4
             ) landed_gross_qty,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.qty_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.current_qty
                                                    )
              ),
              4
             ) current_qty,
          qum_bl.qty_unit qty_unit, qum_bl.qty_unit_id qty_unit_id,
          agrd.container_no container_no, agrd.container_size container_size,
          agrd.no_of_bags no_of_bags, agrd.no_of_containers no_of_containers,
          agrd.no_of_pieces no_of_pieces, agrd.brand brand,
          agrd.mark_no mark_no, agrd.seal_no seal_no,
          agrd.customer_seal_no customer_seal_no,
          agrd.stock_status stock_status, agrd.remarks remarks
     FROM agrd_action_grd agrd,
          gmr_goods_movement_record gmr,
          agmr_action_gmr agmr,
          qum_quantity_unit_master qum_bl
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agmr.action_no = agrd.action_no
      AND qum_bl.qty_unit_id = agrd.qty_unit_id
      AND agmr.gmr_latest_action_action_id = ''landingDetail''
      AND agmr.is_deleted = ''N''
      AND agrd.is_deleted = ''N''
      AND gmr.internal_gmr_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry where DGM_ID IN ('DGM_LD_GRD_D');
  
end;
update RFC_REPORT_FILTER_CONFIG rfc
set RFC.LABEL_ROW_NUMBER = 5
where RFC.LABEL_ID = 'RFC252PHY04';
update RFC_REPORT_FILTER_CONFIG rfc
set RFC.IS_MANDATORY = 'Y'
where RFC.LABEL_ID in ('RFC252PHY02','RFC252PHY03');
commit;

delete from RPC_RF_PARAMETER_CONFIG rpc where RPC.LABEL_ID = 'RFC252PHY05';
delete from RFC_REPORT_FILTER_CONFIG rfc where RfC.LABEL_ID = 'RFC252PHY05';
commit;

SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
  loop
    dbms_output.put_line(cc.corporate_id);
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 1, 4, 
    'Business Line', 'GFF1011', 1, 'Y');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1045', 'mdmBusinessLine');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1046', 'BusinessLine');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1050', '1');
COMMIT;
 end loop;
commit;
end;

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('In Process Stock', 'In Process Stock');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Receive Material Stock', 'Receive Material Stock');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Delta IP Stock', 'Delta IP Stock');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Delta FM IP Stock', 'Delta FM IP Stock');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Free Metal IP Stock', 'Free Metal IP Stock');
   

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('InProcessStockType', 'In Process Stock', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('InProcessStockType', 'Receive Material Stock', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('InProcessStockType', 'Delta IP Stock', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('InProcessStockType', 'Delta FM IP Stock', 'N', 4);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('InProcessStockType', 'Free Metal IP Stock', 'N', 5);

update RFC_REPORT_FILTER_CONFIG rfc
set RFC.IS_MANDATORY = 'Y'
where rfc.label_id in ('RFC251PHY02','RFC251PHY03');

update POFH_PRICE_OPT_FIXATION_HEADER pofh 
set POFH.QP_START_QTY = POFH.QTY_TO_BE_FIXED
where POFH.QP_START_QTY is null;

update POCH_PRICE_OPT_CALL_OFF_HEADER poch
set POCH.IS_BALANCE_PRICING='N'
where POCH.IS_BALANCE_PRICING is null;

update POFH_PRICE_OPT_FIXATION_HEADER pofh
set POFH.IS_PROVESIONAL_ASSAY_EXIST='N'
where POFH.IS_PROVESIONAL_ASSAY_EXIST is null;

update PFD_PRICE_FIXATION_DETAILS pfd
set PFD.HEDGE_CORRECTION_DATE = PFD.AS_OF_DATE;

update PFD_PRICE_FIXATION_DETAILS pfd
set PFD.FX_FIXATION_DATE = PFD.AS_OF_DATE
,PFD.FX_CORRECTION_DATE=PFD.AS_OF_DATE
where PFD.FX_RATE is not null;

commit;
