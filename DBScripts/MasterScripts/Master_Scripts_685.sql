-- Create Blending Action Scripts 

INSERT INTO axm_action_master
            (action_id, entity_id, action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable,
             is_ref_no_gen_applicable, is_event_publish_applicable,
             is_continuous_middle_no_req, is_required_for_eodeom,
             is_activity_log_applicable, is_recent_record_applicable,
             navigation_url
            )
     VALUES ('blending', 'GMR', 'Blending ', 'Y',
             NULL, 'N',
             NULL, 'N',
             'N', 'Y',
             'Y', 'Y',
             NULL
            );


INSERT INTO akm_action_ref_key_master
            (action_key_id, action_key_desc,
             validation_query
            )
     VALUES ('blendingRefNo', 'Blending Ref No',
             'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id'
            );


INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('blending', 'N', 'N',
             'action_date', 'N', NULL,
             NULL, NULL, 'N'
            );

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted,
                   seq_name
                  )
           VALUES ('ARF-BLEN-' || cc.corporate_id, 'blendingRefNo',
                   cc.corporate_id, 'BLEN-', 1,
                   0, '-' || cc.corporate_id, 1, 'N',
                   ''
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('ARFM-BLEN-' || cc.corporate_id, cc.corporate_id,
                   'blending', 'blendingRefNo', 'N'
                  );
   END LOOP;
END;

-- Cancel Blending Action Scripts 

INSERT INTO axm_action_master
            (action_id, entity_id, action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable,
             is_ref_no_gen_applicable, is_event_publish_applicable,
             is_continuous_middle_no_req, is_required_for_eodeom,
             is_activity_log_applicable, is_recent_record_applicable,
             navigation_url
            )
     VALUES ('cancelBlending', 'GMR', 'Cancel Blending ', 'Y',
             NULL, 'N',
             NULL, 'N',
             'N', 'Y',
             'Y', 'Y',
             NULL
            );


INSERT INTO akm_action_ref_key_master
            (action_key_id, action_key_desc,
             validation_query
            )
     VALUES ('delBlendRefNo', 'Cancel Blending Ref No',
             'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id'
            );


INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('cancelBlending', 'N', 'N',
             'action_date', 'N', NULL,
             NULL, NULL, 'N'
            );

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted,
                   seq_name
                  )
           VALUES ('ARF-CANBLEN-' || cc.corporate_id, 'delBlendRefNo',
                   cc.corporate_id, 'CANBLEN-', 1,
                   0, '-' || cc.corporate_id, 1, 'N',
                   ''
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('ARFM-CANBLEN-' || cc.corporate_id, cc.corporate_id,
                   'cancelBlending', 'delBlendRefNo', 'N'
                  );
   END LOOP;
END;


-- ASSAY Action Creation Scripts 

INSERT INTO axm_action_master
            (action_id, entity_id, action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable,
             is_ref_no_gen_applicable, is_event_publish_applicable,
             is_continuous_middle_no_req, is_required_for_eodeom,
             is_activity_log_applicable, is_recent_record_applicable,
             navigation_url
            )
     VALUES ('Blending Assay', 'Assay', 'Blending Assay ', 'Y',
             NULL, 'N',
             NULL, 'N',
             'N', 'Y',
             'Y', 'Y',
             NULL
            );


INSERT INTO akm_action_ref_key_master
            (action_key_id, action_key_desc,
             validation_query
            )
     VALUES ('blendAsyRefNo', 'Blending Assay Ref No',
             'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id'
            );


INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('Blending Assay', 'N', 'N',
             'action_date', 'N', NULL,
             NULL, NULL, 'N'
            );

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted,
                   seq_name
                  )
           VALUES ('ARF-BASY-' || cc.corporate_id, 'blendAsyRefNo',
                   cc.corporate_id, 'BASY-', 1,
                   0, '-' || cc.corporate_id, 1, 'N',
                   ''
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('ARFM-BASY-' || cc.corporate_id, cc.corporate_id,
                   'Blending Assay', 'blendAsyRefNo', 'N'
                  );
   END LOOP;
END;

-- ARF Sequence Scripts 

DECLARE
   CURSOR blen_create_id
   IS
      (SELECT akc.corporate_id
         FROM ak_corporate akc
        WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N');
BEGIN
   FOR sl_drf IN blen_create_id
   LOOP
      EXECUTE IMMEDIATE    'CREATE SEQUENCE SEQAXM_BLEN_'
                        || sl_drf.corporate_id
                        || ' START WITH 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE NOCACHE NOORDER';

      UPDATE arf_action_ref_number_format arf
         SET arf.seq_name = 'SEQAXM_BLEN_' || sl_drf.corporate_id
       WHERE arf.action_key_id = 'blendingRefNo'
         AND arf.corporate_id = sl_drf.corporate_id;
   END LOOP;

   COMMIT;
END;

DECLARE
   CURSOR blen_cancel_id
   IS
      (SELECT akc.corporate_id
         FROM ak_corporate akc
        WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N');
BEGIN
   FOR sl_drf IN blen_cancel_id
   LOOP
      EXECUTE IMMEDIATE    'CREATE SEQUENCE SEQAXM_CANBLEN_'
                        || sl_drf.corporate_id
                        || ' START WITH 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE NOCACHE NOORDER';

      UPDATE arf_action_ref_number_format arf
         SET arf.seq_name = 'SEQAXM_CANBLEN_' || sl_drf.corporate_id
       WHERE arf.action_key_id = 'delBlendRefNo'
         AND arf.corporate_id = sl_drf.corporate_id;
   END LOOP;

   COMMIT;
END;

DECLARE
   CURSOR blen_assay_id
   IS
      (SELECT akc.corporate_id
         FROM ak_corporate akc
        WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N');
BEGIN
   FOR sl_drf IN blen_assay_id
   LOOP
      EXECUTE IMMEDIATE    'CREATE SEQUENCE SEQAXM_BASY_'
                        || sl_drf.corporate_id
                        || ' START WITH 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE NOCACHE NOORDER';

      UPDATE arf_action_ref_number_format arf
         SET arf.seq_name = 'SEQAXM_BASY_' || sl_drf.corporate_id
       WHERE arf.action_key_id = 'blendAsyRefNo'
         AND arf.corporate_id = sl_drf.corporate_id;
   END LOOP;

   COMMIT;
END;




-- UI LINK (GM,GMC,AMC)Scripts 


Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOBA', 'List of Wns Stocks', '[{name: "stkRefNo", mapping: "stkRefNo"}, 
                                {name: "contractItemRefNo", mapping: "contractItemRefNo"}, 
                                {name: "productName", mapping: "productName"},
                                {name: "qualityName", mapping: "qualityName"},
                                {name: "covertedWmt", mapping: "covertedWmt"},
                                {name: "covertedDmt", mapping: "covertedDmt"},
                                {name: "assayDetails", mapping: "assayDetails"},
                                {name: "gmrQtyUnitName", mapping: "gmrQtyUnitName"}
                               ]', NULL, NULL, 
    NULL, '/private/jsp/logistics/blending/BlendingStockDetailPopUp.jsp', '/private/jsp/logistics/blending/BlendingStockDetailFilter.jsp', '/private/js/logistics/blending/BlendingStockDetailPopUp.js');



Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOBG', 'List of Blending GMR', '[]', NULL, NULL, 
    NULL, '', '/private/jsp/logistics/blending/BlendingListing.jsp', '/private/js/logistics/blending/BlendingListing.js');




Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOBIS', 'List of Blending Input Stocks', '[]', NULL, NULL, 
    NULL, NULL, '/private/jsp/logistics/blending/BlendingInputStocksListing.jsp', '/private/js/logistics/blending/BlendingInputStocksListing.js');




Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('TOL-B1', 'New Blending Activity', 3, 3, '/metals/loadBlendingActivity.action?method=loadBlendingActivity&is_Fresh_Load=Y', 
    NULL, 'TOL-P7', '', 'Logistics', '', 
    'N');

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('TOL-B2', 'List All(Blending)', 4, 3, '/metals/loadListOfBlending.action?gridId=LOBG', 
    NULL, 'TOL-P7', '', 'Logistics', '', 
    'N');





    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOB_1', 'LOBG', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOB_2', 'LOBG', 'Cancel Blending', 1, 2, 
    '', 'function(){cancelBlending();}', NULL, 'LOB_1', '');
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOB_3', 'LOBG', 'List Of Blending Input Stocks', 2, 2, 
    NULL, 'function(){getListOfBlendingInputStocks();}', NULL, 'LOB_1', NULL);

	


------------------------------------


BEGIN
 for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 
 loop
 
 Insert into ARF_ACTION_REF_NUMBER_FORMAT
    (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
     MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
  Values
    ('ARF-FAD-&'||CC.CORPORATE_ID, 'createFADRefNo', CC.CORPORATE_ID, 'FAD-', 1, 
     0, '-'||CC.CORPORATE_ID, 1, 'N');
 
  Insert into ARFM_ACTION_REF_NO_MAPPING
    (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
  Values
    ('ARFM-FAD-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'FX_ALLOCATION', 'createFADRefNo', 'N');
 
  Insert into ERC_EXTERNAL_REF_NO_CONFIG
    (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
  Values
    (CC.CORPORATE_ID, 'FX_ALLOCATION', 'FAD-', 0, '-'||CC.CORPORATE_ID);
    
     end loop;
 end;
/
	
-----------------------------------------------------------------




Insert into PFG_PRODUCTFEATUREGROUP
   (FEATURE_GROUP_ID, FEATURE_GROUP_NAME)
 Values
   ('APP-PFG-N-16', 'Fx Exposure');
   
   
Insert into PFL_PRODUCTFEATURELIST
   (FEATURE_ID, FEATURE_TITLE, FEATURE_TYPE, FEATURE_DESCRIPTION, FEATURE_GROUP_ID, 
    ACTION_ID)
 Values
   ('APP-PFL-N-225', 'Fx Exposure', 'STANDARD', 'FX Exposure', 'APP-PFG-N-16', 
    NULL);
    
    
Insert into MODULE_MASTER
   (MODULE_ID, MODULE_NAME, MODULE_SORT_ID, SECTION_ID)
 Values
   ('APP-MM-N-41', ' Fx Exposure', 41, 'RSM-5');
   
   
   
Insert into ACM_ACTIVITY_MASTER
   (ACTIVITY_ID, ACTIVITY_NAME, ACTIVITY_DESCRIPTION, MODULE_ID, FEATURE_ID, 
    ACTIVITY_SORT_ID, ACTIVITY_NAME_DE, ACTIVITY_NAME_ES)
 Values
   ('APP-ACM-N256', 'Fx Exposure - Operation', 'Fx Exposure - Operation', 'APP-MM-N-41', 'APP-PFL-N-225', 
    501, NULL, NULL);
    
    
Insert into ACL_ACCESS_CONTROL_LIST
   (ACL_ID, ACL_NAME, ACL_DESCRIPTION, ACTIVITY_ID, ACL_CHECK_FLAG, 
    ACL_CATEGORY_MASTER_ID)
 Values
   ('APP-ACL-N1402', 'Allocate Hedge', 'Allocate Hedge', 'APP-ACM-N256', 'Y', 
    NULL); 
    
    
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('DERIVATIVE_ALLOC_FXEXP', 'List Of Trades Fx Exposure', '[   
    {
        name : "tradeDate",
        mapping : "tradeDate"
    }, {
        name : "cpName",
        mapping : "cpName"
    }, {
        name : "treasureRefNo",
        mapping : "treasureRefNo"
    }, {
        name : "externalRefNo",
        mapping : "externalRefNo"
    }, {
        name : "productDesc",
        mapping : "productDesc"
    }, {
        name : "foreignCurrency",
        mapping : "foreignCurrency"
    }, {
        name : "foreignCurAmount",
        mapping : "foreignCurAmount"
    }, {
        name : "exchangeRate",
        mapping : "exchangeRate"
    }, {
        name : "valueDate",
        mapping : "valueDate"
    }, {
        name : "profitCenterName",
        mapping : "profitCenterName"
    }, {
        name : "amountSellCur",
        mapping : "amountSellCur"
    }, {
        name : "dealType",
        mapping : "dealType"
    }, {
        name : "instrument",
        mapping : "instrument"
    }, {
        name : "firstlastname",
        mapping : "firstlastname"
    } ]', NULL, NULL, 
    '[ 
    {
        name : "tradeDate",
        mapping : "tradeDate"
    }, {
        name : "cpName",
        mapping : "cpName"
    }, {
        name : "treasureRefNo",
        mapping : "treasureRefNo"
    }, {
        name : "externalRefNo",
        mapping : "externalRefNo"
    }, {
        name : "productDesc",
        mapping : "productDesc"
    }, {
        name : "foreignCurrency",
        mapping : "foreignCurrency"
    }, {
        name : "foreignCurAmount",
        mapping : "foreignCurAmount"
    }, {
        name : "exchangeRate",
        mapping : "exchangeRate"
    }, {
        name : "valueDate",
        mapping : "valueDate"
    }, {
        name : "profitCenterName",
        mapping : "profitCenterName"
    }, {
        name : "amountSellCur",
        mapping : "amountSellCur"
    }, {
        name : "dealType",
        mapping : "dealType"
    }, {
        name : "instrument",
        mapping : "instrument"
    }, {
        name : "firstlastname",
        mapping : "firstlastname"
    }]', 'physical/derivative/listing/derivativeFutureTradeFxExposureBtn.jsp', 'physical/derivative/listing/derivativeFutureTradeFxExposureFilter.jsp', '/private/js/physical/derivative/listing/derivativeFutureTradeFxExposure.js');
    


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('FX_ALLOCATION', 'FAD ', 'Fx Allocation Details', 'Y', 'Fx Allocation Details', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('FX_ALLOCATION', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('createFADRefNo', 'Fad Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');
    




    -------------------------------------------------------------------------------------------------






INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url,
             default_record_model_state,
             other_url,
             screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('LOFE_DEALLOC', 'List Of Fx Exposure DeAllocation',
             '[   
    {
        name : "fadId",
        mapping : "fadId"
    }, {
        name : "corporateId",
        mapping : "corporateId"
    }, {
        name : "priceFixationId",
        mapping : "priceFixationId"
    }, {
        name : "internalTreasuryRefNo",
        mapping : "internalTreasuryRefNo"
    }, {
        name : "pfcRefNo",
        mapping : "pfcRefNo"
    }, {
        name : "allocBaseAmount",
        mapping : "allocBaseAmount"
    }, {
        name : "allocFxAmount",
        mapping : "allocFxAmount"
    }, {
        name : "baseCurId",
        mapping : "baseCurId"
    }, {
        name : "fxCurId",
        mapping : "fxCurId"
    }, {
        name : "internalActionRefNo",
        mapping : "internalActionRefNo"
    } ]',
             NULL, NULL,
             '[ 
    {
        name : "fadId",
        mapping : "fadId"
    }, {
        name : "corporateId",
        mapping : "corporateId"
    }, {
        name : "priceFixationId",
        mapping : "priceFixationId"
    }, {
        name : "internalTreasuryRefNo",
        mapping : "internalTreasuryRefNo"
    }, {
        name : "pfcRefNo",
        mapping : "pfcRefNo"
    }, {
        name : "allocBaseAmount",
        mapping : "allocBaseAmount"
    }, {
        name : "allocFxAmount",
        mapping : "allocFxAmount"
    }, {
        name : "baseCurId",
        mapping : "baseCurId"
    }, {
        name : "fxCurId",
        mapping : "fxCurId"
    }, {
        name : "internalActionRefNo",
        mapping : "internalActionRefNo"
    }]',
             NULL,
             '/private/jsp/physical/derivative/listing/listOfFXExposureDeAllocation.jsp',
             '/private/js/physical/derivative/listing/listOfFXExposureDeAllocation.js'
            );




Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FXEXP_DEALLOC_1', 'LOFE_DEALLOC', 'Operation', 1, 1, 
    NULL, NULL, NULL, NULL, NULL);
    
    
INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called, icon_class,
             menu_parent_id, acl_id)
     VALUES ('FXEXP_DEALLOC_2', 'LOFE_DEALLOC', 'DeAllocate', 1,
             2, 'APP-PFL-N-225', 'function(){loadDeAllocateHedge();}', NULL,
             'FXEXP_DEALLOC_1', 'APP-ACL-N1402');



-----------------------------------------------------------------------------------------------------





Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Trasurey Ref No', 'Trasurey Ref.No.');
   
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('External Ref No', 'External Ref.No.');
   

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('futureTradeDerivativeSearch', 'Trasurey Ref No', 'N', 1);
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('futureTradeDerivativeSearch', 'External Ref No', 'N', 2);

 Insert into SLV_STATIC_LIST_VALUE
     (VALUE_ID, VALUE_TEXT)
   Values
     ('BaseCurId', 'Base Cur Id');
     
  Insert into SLV_STATIC_LIST_VALUE
     (VALUE_ID, VALUE_TEXT)
   Values
   ('QuoteCurId', 'Fx Cur Id');
   
   
 Insert into SLS_STATIC_LIST_SETUP
    (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
  Values
    ('fxExposureCurSearch', 'BaseCurId', 'N', 1);
    
 Insert into SLS_STATIC_LIST_SETUP
    (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
  Values
    ('fxExposureCurSearch', 'QuoteCurId', 'N', 2);


    -----------------------------------------------------------------------------------------------


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PIC-IGD', 'CREATE_PI', 'Concentrate Provisional Invoice',
             'CREATE_PI', 12,
             'INSERT INTO igd_inv_gmr_details_d
            (internal_invoice_ref_no, gmr_ref_no, container_name,
             mode_of_transport, bl_date, origin_city, origin_country, wet_qty,
             wet_qty_unit_name, dry_qty, dry_qty_unit_name, moisture,
             moisture_unit_name, internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            gmr.gmr_ref_no AS gmr_ref_no,
            stragg (DISTINCT (NVL (adgrd.container_no, agrd.container_no))
                   ) AS container_name,
            stragg
                  (DISTINCT (NVL (gmr.mode_of_transport, ''''))
                  ) AS mode_of_transport,
            gmr.bl_date AS bl_date,
            stragg (DISTINCT (NVL (cim.city_name, ''''))) AS origin_city,
            stragg (DISTINCT (NVL (cym.country_name, ''''))) AS origin_country,
            invs.invoiced_qty AS wet_qty, qum.qty_unit AS wet_qty_unit_name,
              invs.invoiced_qty
            - ((  invs.invoiced_qty
                * (ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                             / SUM (asm.net_weight)
                            )
                          * 100,
                          5
                         )
                  )
                / 100
               )
              ) AS dry_qty,
            qum.qty_unit AS dry_qty_unit_name,
            ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                      / SUM (asm.net_weight)
                     )
                   * 100,
                   5
                  ) AS moisture,
            qum.qty_unit AS moisture_unit_name, ?
       FROM is_invoice_summary invs,
            iid_invoicable_item_details iid,
            grd_goods_record_detail grd,
            dgrd_delivered_grd dgrd,
            gmr_goods_movement_record gmr,
            asm_assay_sublot_mapping asm,
            ash_assay_header ash,
            iam_invoice_assay_mapping iam,
            cym_countrymaster cym,
            cim_citymaster cim,
            qum_quantity_unit_master qum,
            agrd_action_grd agrd,
            adgrd_action_dgrd adgrd
      WHERE iid.internal_invoice_ref_no = invs.internal_invoice_ref_no
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND iid.stock_id = grd.internal_grd_ref_no(+)
        AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
        AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
        AND iid.stock_id = iam.internal_grd_ref_no
        AND iam.ash_id = ash.ash_id
        AND ash.ash_id = asm.ash_id
        AND qum.qty_unit_id = asm.net_weight_unit
        AND cym.country_id(+) = gmr.loading_country_id
        AND cim.city_id(+) = gmr.loading_city_id
        AND gmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = adgrd.internal_gmr_ref_no(+)
        AND invs.internal_invoice_ref_no = ?
   GROUP BY gmr.internal_gmr_ref_no,
            invs.internal_invoice_ref_no,
            gmr.bl_date,
            gmr.gmr_ref_no,
            qum.qty_unit,
            invs.invoiced_qty',
             'Y'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id,
             doc_name, activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-DFIC-IGD', 'CREATE_DFI',
             'Concentrate Direct Final Invoice', 'CREATE_DFI', 14,
             'INSERT INTO igd_inv_gmr_details_d
            (internal_invoice_ref_no, gmr_ref_no, container_name,
             mode_of_transport, bl_date, origin_city, origin_country, wet_qty,
             wet_qty_unit_name, dry_qty, dry_qty_unit_name, moisture,
             moisture_unit_name, internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            gmr.gmr_ref_no AS gmr_ref_no,
            stragg (DISTINCT (NVL (adgrd.container_no, agrd.container_no))
                   ) AS container_name,
            stragg
                  (DISTINCT (NVL (gmr.mode_of_transport, ''''))
                  ) AS mode_of_transport,
            gmr.bl_date AS bl_date,
            stragg (DISTINCT (NVL (cim.city_name, ''''))) AS origin_city,
            stragg (DISTINCT (NVL (cym.country_name, ''''))) AS origin_country,
            invs.invoiced_qty AS wet_qty, qum.qty_unit AS wet_qty_unit_name,
              invs.invoiced_qty
            - ((  invs.invoiced_qty
                * (ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                             / SUM (asm.net_weight)
                            )
                          * 100,
                          5
                         )
                  )
                / 100
               )
              ) AS dry_qty,
            qum.qty_unit AS dry_qty_unit_name,
            ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                      / SUM (asm.net_weight)
                     )
                   * 100,
                   5
                  ) AS moisture,
            qum.qty_unit AS moisture_unit_name, ?
       FROM is_invoice_summary invs,
            iid_invoicable_item_details iid,
            grd_goods_record_detail grd,
            dgrd_delivered_grd dgrd,
            gmr_goods_movement_record gmr,
            asm_assay_sublot_mapping asm,
            ash_assay_header ash,
            iam_invoice_assay_mapping iam,
            cym_countrymaster cym,
            cim_citymaster cim,
            qum_quantity_unit_master qum,
            agrd_action_grd agrd,
            adgrd_action_dgrd adgrd
      WHERE iid.internal_invoice_ref_no = invs.internal_invoice_ref_no
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND iid.stock_id = grd.internal_grd_ref_no(+)
        AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
        AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
        AND iid.stock_id = iam.internal_grd_ref_no
        AND iam.ash_id = ash.ash_id
        AND ash.ash_id = asm.ash_id
        AND qum.qty_unit_id = asm.net_weight_unit
        AND cym.country_id(+) = gmr.loading_country_id
        AND cim.city_id(+) = gmr.loading_city_id
        AND gmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = adgrd.internal_gmr_ref_no(+)
        AND invs.internal_invoice_ref_no = ?
   GROUP BY gmr.internal_gmr_ref_no,
            invs.internal_invoice_ref_no,
            gmr.bl_date,
            gmr.gmr_ref_no,
            qum.qty_unit,
            invs.invoiced_qty',
             'Y'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-FIC-IGD', 'CREATE_FI', 'Concentrate Final Invoice',
             'CREATE_FI', 14,
             'INSERT INTO igd_inv_gmr_details_d
            (internal_invoice_ref_no, gmr_ref_no, container_name,
             mode_of_transport, bl_date, origin_city, origin_country, wet_qty,
             wet_qty_unit_name, dry_qty, dry_qty_unit_name, moisture,
             moisture_unit_name, internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            gmr.gmr_ref_no AS gmr_ref_no,
            stragg (DISTINCT (NVL (adgrd.container_no, agrd.container_no))
                   ) AS container_name,
            stragg
                  (DISTINCT (NVL (gmr.mode_of_transport, ''''))
                  ) AS mode_of_transport,
            gmr.bl_date AS bl_date,
            stragg (DISTINCT (NVL (cim.city_name, ''''))) AS origin_city,
            stragg (DISTINCT (NVL (cym.country_name, ''''))) AS origin_country,
            invs.invoiced_qty AS wet_qty, qum.qty_unit AS wet_qty_unit_name,
              invs.invoiced_qty
            - ((  invs.invoiced_qty
                * (ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                             / SUM (asm.net_weight)
                            )
                          * 100,
                          5
                         )
                  )
                / 100
               )
              ) AS dry_qty,
            qum.qty_unit AS dry_qty_unit_name,
            ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                      / SUM (asm.net_weight)
                     )
                   * 100,
                   5
                  ) AS moisture,
            qum.qty_unit AS moisture_unit_name, ?
       FROM is_invoice_summary invs,
            iid_invoicable_item_details iid,
            grd_goods_record_detail grd,
            dgrd_delivered_grd dgrd,
            gmr_goods_movement_record gmr,
            asm_assay_sublot_mapping asm,
            ash_assay_header ash,
            iam_invoice_assay_mapping iam,
            cym_countrymaster cym,
            cim_citymaster cim,
            qum_quantity_unit_master qum,
            agrd_action_grd agrd,
            adgrd_action_dgrd adgrd
      WHERE iid.internal_invoice_ref_no = invs.internal_invoice_ref_no
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND iid.stock_id = grd.internal_grd_ref_no(+)
        AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
        AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
        AND iid.stock_id = iam.internal_grd_ref_no
        AND iam.ash_id = ash.ash_id
        AND ash.ash_id = asm.ash_id
        AND qum.qty_unit_id = asm.net_weight_unit
        AND cym.country_id(+) = gmr.loading_country_id
        AND cim.city_id(+) = gmr.loading_city_id
        AND gmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = adgrd.internal_gmr_ref_no(+)
        AND invs.internal_invoice_ref_no = ?
   GROUP BY gmr.internal_gmr_ref_no,
            invs.internal_invoice_ref_no,
            gmr.bl_date,
            gmr.gmr_ref_no,
            qum.qty_unit,
            invs.invoiced_qty',
             'Y'
            );


------------------------------------------------------------------------------------------------	
