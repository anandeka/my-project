SET DEFINE OFF;
DELETE FROM sls_static_list_setup
      WHERE value_id = 'SecondaryProvisionalAssay'
        AND list_type = 'assayTypeSearchCriteria';
COMMIT;
        
SET DEFINE OFF;       
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'SecondaryProvisionalAssay', 'N', 13);
COMMIT;