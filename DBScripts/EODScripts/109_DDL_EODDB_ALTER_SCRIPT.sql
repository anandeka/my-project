ALTER TABLE EUD_ELEMENT_UNDERLYING_DETAILS MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE ARE_ARRIVAL_REPORT_ELEMENT MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE PRCE_PHY_REALIZED_CONC_ELEMENT MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE TEMP_FCR MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE FCE_FEED_CONSUMPTION_ELEMENT MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE CBRE_CLOSING_BAL_REPORT_ELE MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE PSUE_ELEMENT_DETAILS MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE POUED_ELEMENT_DETAILS MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE PCS_PURCHASE_CONTRACT_STATUS MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE PA_PURCHASE_ACCURAL MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE PA_PURCHASE_ACCURAL_GMR MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE FCR_FEED_CONSUMPTION_REPORT MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE FCEOT_FCEO_TEMP MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE FCEO_FEED_CON_ELEMENT_ORIGINAL MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE AREO_AR_ELEMENT_ORIGINAL MODIFY ELEMENT_NAME VARCHAR2(30);
ALTER TABLE AR_ARRIVAL_REPORT MODIFY CORPORATE_NAME VARCHAR2(100);
ALTER TABLE TEMP_MAS MODIFY CORPORATE_NAME VARCHAR2(100);
ALTER TABLE TEMP_FCR MODIFY CORPORATE_NAME VARCHAR2(100);
ALTER TABLE MAS_METAL_ACCOUNT_SUMMARY MODIFY CORPORATE_NAME VARCHAR2(100);
ALTER TABLE STOCK_MONTHLY_YEILD_DATA MODIFY CORPORATE_NAME VARCHAR2(100);
ALTER TABLE PCS_PURCHASE_CONTRACT_STATUS MODIFY CORPORATE_NAME VARCHAR2(100);
ALTER TABLE FCR_FEED_CONSUMPTION_REPORT MODIFY CORPORATE_NAME VARCHAR2(100);
ALTER TABLE ARO_AR_ORIGINAL MODIFY CORPORATE_NAME VARCHAR2(100);
ALTER TABLE CBT_CB_TEMP MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE FCO_FEED_CONSUMPTION_ORIGINAL MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE FCT_FC_TEMP MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PA_TEMP MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE ISR2_ISR_INVOICE MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE ISR1_ISR_INVENTORY MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PATD_PA_TEMP_DATA MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE AR_ARRIVAL_REPORT MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE CBR_CLOSING_BALANCE_REPORT MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE TEMP_FCR MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE FC_FEED_CONSUMPTION MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PRCH_PHY_REALIZED_CONC_HEADER MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE TQDUL_TREATMENT_QUALITY_DTL_UL MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE TQD_TREATMENT_QUALITY_DETAILS MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE RQDUL_REFINING_QUALITY_DTL_UL MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE RQD_REFINING_QUALITY_DETAILS MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PSU_PHY_STOCK_UNREALIZED MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PSCI_PHY_STOCK_CONTRACT_ITEM MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PSUE_PHY_STOCK_UNREALIZED_ELE MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PQDUL_PAYABLE_QUALITY_DTL_UL MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PQD_PAYABLE_QUALITY_DETAILS MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PRD_PHYSICAL_REALIZED_DAILY MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE POUE_PHY_OPEN_UNREAL_ELEMENT MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE POUD_PHY_OPEN_UNREAL_DAILY MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PA_PURCHASE_ACCURAL MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PA_PURCHASE_ACCURAL_GMR MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE ISR_INTRASTAT_GRD MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE FCR_FEED_CONSUMPTION_REPORT MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE ARQDUL_ASSAY_QUALITY_DTL_UL MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE ARQD_ASSAY_QUALITY_DETAILS MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE FCOT_FCO_TEMP MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PCPDQDUL_PD_QUALITY_DTL_UL MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE PCPDQD_PD_QUALITY_DETAILS MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE DPD_DERIVATIVE_PNL_DAILY MODIFY QUALITY_NAME VARCHAR2(200);
ALTER TABLE ARO_AR_ORIGINAL MODIFY QUALITY_NAME VARCHAR2(200);

ALTER TABLE GRD_GOODS_RECORD_DETAIL MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE AR_ARRIVAL_REPORT MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE TEMP_FCR MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE MD_METAL_DEBT MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE PRCH_PHY_REALIZED_CONC_HEADER MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE SPC_SUMMARY_POSITION_CLEARER MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE PRD_PHYSICAL_REALIZED_DAILY MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE PPS_PHYSICAL_PNL_SUMMARY MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE PCS_PURCHASE_CONTRACT_STATUS MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE ISR_INTRASTAT_GRD MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE PCPD_PC_PRODUCT_DEFINITION MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE UPAD_UNREAL_PNL_ATTR_DETAIL MODIFY PRODUCT_NAME VARCHAR2(200);
ALTER TABLE ARO_AR_ORIGINAL MODIFY PRODUCT_NAME VARCHAR2(200);


ALTER TABLE CBT_CB_TEMP MODIFY PRODUCT_DESC VARCHAR2(200);
ALTER TABLE FCT_FC_TEMP MODIFY PRODUCT_DESC VARCHAR2(200);
ALTER TABLE EOD_EOM_PHY_CONTRACT_JOURNAL MODIFY PRODUCT_DESC VARCHAR2(200);
ALTER TABLE ISR2_ISR_INVOICE MODIFY PRODUCT_DESC VARCHAR2(200);
ALTER TABLE ISR1_ISR_INVENTORY MODIFY PRODUCT_DESC VARCHAR2(200);
ALTER TABLE TCSM_TEMP_CONTRACT_STATUS_MAIN MODIFY PRODUCT_DESC VARCHAR2(200);

ALTER TABLE II_INVOICABLE_ITEM MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE CBT_CB_TEMP MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE GETC_GMR_ELEMENT_TC_CHARGES MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE GERC_GMR_ELEMENT_RC_CHARGES MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE GEPC_GMR_ELEMENT_PC_CHARGES MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE AR_ARRIVAL_REPORT MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE TEMP_FCR MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE CGCP_CONC_GMR_COG_PRICE MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE BGCP_BASE_GMR_COG_PRICE MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE PA_PURCHASE_ACCURAL MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE PA_PURCHASE_ACCURAL_GMR MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE ISR_INTRASTAT_GRD MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE ARO_AR_ORIGINAL MODIFY GMR_REF_NO VARCHAR2(30);


ALTER TABLE TEMP_FCR MODIFY CP_NAME VARCHAR2(100);
ALTER TABLE PCS_PURCHASE_CONTRACT_STATUS MODIFY CP_NAME VARCHAR2(100);
ALTER TABLE FCR_FEED_CONSUMPTION_REPORT MODIFY CP_NAME VARCHAR2(100);


ALTER TABLE TEMP_MAS MODIFY WAREHOUSENAME VARCHAR2(100);
ALTER TABLE MAS_METAL_ACCOUNT_SUMMARY MODIFY WAREHOUSENAME VARCHAR2(100);

ALTER TABLE PSU_PHY_STOCK_UNREALIZED MODIFY SHED_NAME VARCHAR2(50);
ALTER TABLE PSUE_PHY_STOCK_UNREALIZED_ELE MODIFY SHED_NAME VARCHAR2(50);

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD MODIFY LOADING_CITY_NAME VARCHAR2(500);
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD MODIFY DISCHARGE_CITY_NAME VARCHAR2(500);
ALTER TABLE ISR2_ISR_INVOICE MODIFY DISCHARGE_CITY_NAME VARCHAR2(500);
ALTER TABLE ISR1_ISR_INVENTORY MODIFY LOADING_CITY_NAME VARCHAR2(500);
ALTER TABLE ISR1_ISR_INVENTORY MODIFY DISCHARGE_CITY_NAME VARCHAR2(500);
ALTER TABLE ISR2_ISR_INVOICE MODIFY LOADING_CITY_NAME VARCHAR2(500);
ALTER TABLE ISR_INTRASTAT_GRD MODIFY LOADING_CITY_NAME VARCHAR2(500);
ALTER TABLE ISR_INTRASTAT_GRD MODIFY DISCHARGE_CITY_NAME VARCHAR2(500);
ALTER TABLE PRCH_PHY_REALIZED_CONC_HEADER MODIFY DESTINATION_CITY_NAME VARCHAR2(500);
ALTER TABLE PRD_PHYSICAL_REALIZED_DAILY MODIFY DESTINATION_CITY_NAME VARCHAR2(500);
ALTER TABLE PRD_PHYSICAL_REALIZED_DAILY MODIFY ORIGINATION_CITY_NAME VARCHAR2(500);
ALTER TABLE PRCH_PHY_REALIZED_CONC_HEADER MODIFY ORIGINATION_CITY_NAME VARCHAR2(500);