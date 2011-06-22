


SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Assay Range', 'Assay Range');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Price Range', 'Price Range');


SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('basisRangeType', 'Assay Range', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('basisRangeType', 'Price Range', 'N', 2);




SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Range Begining', 'Range Begining');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Range End', 'Range End');


SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('treatmentChargePosition', 'Range Begining', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('treatmentChargePosition', 'Range End', 'N', 2);




SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Self Assay', 'Self Assay');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Counterparty Assay', 'Counterparty Assay');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Assay Exchange', 'Assay Exchange');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Contractual Assay', 'Contractual Assay');



SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('FinalAssay', 'Self Assay', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('FinalAssay', 'Counterparty Assay', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('FinalAssay', 'Assay Exchange', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('FinalAssay', 'Contractual Assay', 'N', 4);



SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Split the Assays', 'Split the Assays');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Apply Spliting Limit', 'Apply Spliting Limit');



SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayComparison', 'Split the Assays', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayComparison', 'Apply Spliting Limit', 'N', 2);




SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Assay Content Based', 'Assay Content Based');


SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('SplitLimitBasis', 'Fixed', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('SplitLimitBasis', 'Assay Content Based', 'N', 2);




SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('%', '%');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('PPM', 'PPM');


SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('splitLimitUnit', '%', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('splitLimitUnit', 'PPM', 'N', 2);

SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('P33', 'New Concentrate Sale', 3, 3, '/metals/loadContractForCreation.action?tabId=general&contractType=S&productGroupType=CONCENTRATES&actionType=current', 
    NULL, 'P3', NULL, 'Physical', NULL);
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('P23', 'New Concentrate Purchase', 3, 3, '/metals/loadContractForCreation.action?tabId=general&contractType=P&productGroupType=CONCENTRATES&actionType=current', 
    NULL, 'P2', NULL, 'Physical', NULL);
COMMIT;

SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('partnershipTypeSales', 'Agency', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('partnershipTypeSales', 'Normal', 'Y', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('partnershipTypeSales', 'Joint Venture', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('partnershipTypeSales', 'Consignment', 'N', 4);