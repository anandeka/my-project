
set define off;

ALTER TABLE DT_DERIVATIVE_TRADE
ADD (STRIP_REF_NO VARCHAR2(50 CHAR))
/

ALTER TABLE DTUL_DERIVATIVE_TRADE_UL
ADD (STRIP_REF_NO VARCHAR2(50 CHAR))
/
--for doc conf table entries
DECLARE
   doc_id   VARCHAR2 (15);
   display_order   number (15);
BEGIN
   INSERT INTO dkm_doc_ref_key_master
               (doc_key_id, doc_key_desc, validation_query
               )
        VALUES ('DT_D_OAF_KEY', 'DERIVATIVE_TRADE_DOCUMENT_AVG_FORW',
                'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id'
               );

   select  'DM-' || seq_dm.NEXTVAL into doc_id from dual;
   
   SELECT dm.display_order + 1 into display_order
   FROM dm_document_master dm
   WHERE dm.display_order = (SELECT MAX (dm1.display_order)FROM dm_document_master dm1);
   
   
   
   INSERT INTO dm_document_master
               (doc_id, doc_name, display_order, VERSION, is_active,is_deleted
               )
        VALUES (doc_id, 'DERIVATIVE_TRADE_DOCUMENT_AVG_FORW', display_order, NULL, 'Y','N'
               );

   FOR akc_cursor IN (SELECT akc.corporate_id
                        FROM ak_corporate akc)
   LOOP
      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id,doc_id, doc_key_id, is_deleted
                  )
           VALUES ('DRFM-' || seq_drfm.NEXTVAL, akc_cursor.corporate_id,doc_id, 'DT_D_OAF_KEY', 'N'
                  );

      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id,corporate_id, prefix, middle_no_start_value, middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-' || seq_drf.NEXTVAL, 'DT_D_OAF_KEY',akc_cursor.corporate_id, 'DT-', 0, 0, '-' || akc_cursor.corporate_id, NULL, 'N'
                  );

      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, 
                  corporate_id, doc_id,
                   doc_template_name, 
                   doc_template_name_de,
                   doc_template_name_es, 
                   doc_print_name, 
                   doc_print_name_de,
                   doc_print_name_es, 
                   doc_rpt_file_name, 
                   is_active,
                   doc_auto_generate
                  )
           VALUES ('CDC-DT-AVG-FORW', 
                   akc_cursor.corporate_id, 
                   doc_id,
                   'DerivativeTradeAvgForwDoc', 
                   NULL,
                   NULL, 
                   'DOC', 
                   NULL,
                   NULL, 
                   'DerivativeContractPreview.rpt', 
                   'Y',
                   'Y'
                  );
   END LOOP;
END;

/


--for the print doc operation entry
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('AVG_FWD_TRADES-08', 'LIST_AVERAGE_FORWARDS', 'Print', 7, 2, 
    NULL, 'function(){printDocument();}', NULL, 'AVG_FWD_TRADES-01', NULL)
/

update GM_GRID_MASTER gm
set GM.SCREEN_SPECIFIC_JS = '/private/js/trademanagement/derivative/ListofAverageForwardDerivatives.js,/private/js/report/report.js'
where GM.GRID_ID = 'LIST_AVERAGE_FORWARDS'
/

Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (323, 'SELECT OBA.ACCOUNT_NAME FROM OBA_OUR_BANK_ACCOUNTS oba WHERE OBA.ACCOUNT_ID = ?')
/
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'treasuryRefNo', 'Treasury Ref No', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'externalRefNo', 'External Ref No', 
   NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'exchangeInstrumentId', 'Exchange Instrument', 
    308)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'valueDate', 'Value Date', 
   NULL)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'traderId', 'Trader', 
    302)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'counterPartyId', 'Counter Party', 
    303)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'masterContractId', 'Master Contract', 
    319)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'paymentTermsId', 'Payment Terms', 
    318)
/
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'tradeType', 'Trade Type', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'currencyId', 'NOT_SHOWN_TO_THE_USER - currencyId', 
    306)
/
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'amount', 'Amount', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'exchangeRate', 'Exchange Rate', 
    NULL)
/
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'spotRate', 'Spot', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'marginRate', 'Margin', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'premiumRate', 'Premium', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'otherCharges', 'Other Charges', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'slippageRate', 'Slippage', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'netExchangeRate', 'Net Rate', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'bankId', 'Bank Name/Account', 
   303)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'bankAccountId', 'NOT_SHOWN_TO_THE_USER - bankAccountId', 
   323)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'bankCharges', 'Bank Charges', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'bankChargesType', 'NOT_SHOWN_TO_THE_USER - bankChargesType', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'bankChargesCurId', 'NOT_SHOWN_TO_THE_USER - bankChargesCurId', 
     306)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'profitCenterId', 'Profit Center', 
    304)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'strategyId', 'Strategy', 
    301)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'purposeId', 'Purpose', 
    300)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'remarks', 'Remarks', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'tradeDate', 'Trade Date', 
    NULL)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'paymentDueDate', 'Payment Due Date', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'parentIntTresuryRefNo', 'NOT_SHOWN_TO_THE_USER - parentIntTresuryRefNo', 
    NULL)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'outstandingAmountCurId', 'NOT_SHOWN_TO_THE_USER - outstandingAmountCurId', 
    306)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'outstandingAmount', 'NOT_SHOWN_TO_THE_USER - outstandingAmount', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'nomineeProfileId', 'Nominee', 
    303)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'fxRateBaseToForeign', 'NOT_SHOWN_TO_THE_USER - fxRateBaseToForeign', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'isExchRateComp', 'NOT_SHOWN_TO_THE_USER - isExchRateComp', 
    NULL)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'modifiedDate', 'NOT_SHOWN_TO_THE_USER - modifiedDate', 
     NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'modifiedBy', 'NOT_SHOWN_TO_THE_USER - modifiedBy', 
     NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'drId', 'NOT_SHOWN_TO_THE_USER - drId', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_MODIFY_TRADE', NULL, 'isImported', 'NOT_SHOWN_TO_THE_USER - isImported', 
    NULL)
/






Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'treasuryRefNo', 'Trade Ref. No.', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'externalRefNo', 'External Ref No', 
   NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'exchangeInstrumentId', 'Instrument', 
    308)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'valueDate', 'Value Date of Underlying', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'expiryDate', 'Expiry Date', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'exchangeRate', 'Strike Rate', 
    NULL)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'traderId', 'Trader', 
    302)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'counterPartyId', 'Counter Party', 
    303)
/



Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'paymentTermsId', 'Payment Terms', 
    318)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'tradeType', 'Trade Type', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'currencyId', 'NOT_SHOWN_TO_THE_USER - currencyId', 
    306)
/
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'amount', 'Amount', 
   NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'exchangeRate', 'Exchange Rate', 
    NULL)
/
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'spotRate', 'Spot', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'marginRate', 'Margin', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'premiumRate', 'Premium', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'premium', 'Option Premium', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'premiumUnitId', 'NOT_SHOWN_TO_THE_USER - premiumUnitId', 
    306)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'otherCharges', 'Other Charges', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'slippageRate', 'Slippage', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'netExchangeRate', 'Net Rate', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'bankId', 'Bank Name/Account', 
   303)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'bankAccountId', 'NOT_SHOWN_TO_THE_USER - bankAccountId', 
    323)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'bankCharges', 'Bank Charges', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'bankChargesType', 'NOT_SHOWN_TO_THE_USER - bankChargesType', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'bankChargesCurId', 'NOT_SHOWN_TO_THE_USER - bankChargesCurId', 
    306)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'profitCenterId', 'Profit Center', 
    304)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'strategyId', 'Strategy', 
    301)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'purposeId', 'Purpose', 
    300)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'remarks', 'Remarks', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'tradeDate', 'Trade Date', 
    NULL)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'paymentDueDate', 'Payment Due Date', 
   NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'parentIntTresuryRefNo', 'NOT_SHOWN_TO_THE_USER - parentIntTresuryRefNo', 
   NULL)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'outstandingAmountCurId', 'NOT_SHOWN_TO_THE_USER - outstandingAmountCurId', 
    306)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'outstandingAmount', 'NOT_SHOWN_TO_THE_USER - outstandingAmount', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'nomineeProfileId', 'NOT_SHOWN_TO_THE_USER - nomineeProfileId', 
    303)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'fxRateBaseToForeign', 'NOT_SHOWN_TO_THE_USER - fxRateBaseToForeign', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'isExchRateComp', 'NOT_SHOWN_TO_THE_USER - isExchRateComp', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'modifiedDate', 'NOT_SHOWN_TO_THE_USER - modifiedDate', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'drId', 'NOT_SHOWN_TO_THE_USER - drId', 
    NULL)
/

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'isImported', 'NOT_SHOWN_TO_THE_USER - isImported', 
    NULL)
/


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (seq_axed.nextval, 'CDC_TR_OPTION_MODIFY_TRADE', NULL, 'modifiedBy', 'NOT_SHOWN_TO_THE_USER - modifiedBy', 
     NULL)
/


ALTER TABLE DT_FBI_D
MODIFY(INSTRUMENT VARCHAR2(50 CHAR))
/
update GM_GRID_MASTER gm
set GM.SCREEN_SPECIFIC_JS = '/private/js/trademanagement/derivative/ListofDerivativesTrade.js'
where GM.GRID_ID = 'LIST_DER_TRADES'
/
DECLARE
BEGIN
   FOR cc IN (SELECT *
                FROM ak_corporate akc
               WHERE akc.is_internal_corporate = 'N')
   LOOP
      DBMS_OUTPUT.put_line (cc.corporate_id);

      Insert into ERC_EXTERNAL_REF_NO_CONFIG
	   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
	 Values
	   (cc.corporate_id, 'STRIP_REF_NO', 'SDT-', 1, '-' || cc.corporate_id);


      
   END LOOP;
END;

/
UPDATE IFM_IMPORT_FILE_MASTER
SET COLUMN_MODEL = '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},
      {header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},
      {header:"Trade Date", width: 100, sortable: false,  dataIndex:"tradeDate"},
      {header:"External Trade Ref.No", width: 100, sortable: false,  dataIndex:"externalTradeRefNo"},
      {header:"Leg", width: 100, sortable: false,  dataIndex:"leg"},
      {header:"Trader", width: 100, sortable: false,  dataIndex:"trader"},      
      {header:"Exchange Instrument", width: 100, sortable: false,  dataIndex:"exchangeInstrument"},      
      {header:"Deal Type", width: 100, sortable: false,  dataIndex:"dealTypeName"},
      {header:"Clearer", width: 100, sortable: false,  dataIndex:"clearer"},      
      {header:"Clearer Account", width: 100, sortable: false,  dataIndex:"clearerAccount"},      
      {header:"Clearer Commission Type", width: 100, sortable: false,  dataIndex:"clearerCommissionType"},
      {header:"Broker", width: 100, sortable: false,  dataIndex:"broker"},      
      {header:"Broker Commission Type", width: 100, sortable: false,  dataIndex:"brokerCommissionType"},
      {header:"Delivery Period Type", width: 100, sortable: false,  dataIndex:"deliveryPeriodType"},
      {header:"Prompt/Delivery Details", width: 100, sortable: false,  dataIndex:"deliveryPeriod"},      
      {header:"Trade Type", width: 100, sortable: false,  dataIndex:"tradeType"},
      {header:"Trade Price Type", width: 100, sortable: false,  dataIndex:"tradePriceType"},
      {header:"Trade/Strike Price", width: 100, sortable: false,  dataIndex:"tradeStrikePrice"},      
      {header:"Trade/Strike Price Unit", width: 100, sortable: false,  dataIndex:"tradeStrikePriceUnit"},
      {header:"Quantity(lots)", width: 100, sortable: false,  dataIndex:"quantityInLots"},
      {header:"Settlement Currency", width: 100, sortable: false,  dataIndex:"settlementCurrency"},
      {header:"Option Premium", width: 100, sortable: false,  dataIndex:"optionPremium"},      
      {header:"Option Premium Price Unit", width: 100, sortable: false,  dataIndex:"optionPremiumPriceUnit"},
      {header:"Option Expiry Date", width: 100, sortable: false,  dataIndex:"optionExpiryDate"},
      {header:"Profit Center", width: 100, sortable: false,  dataIndex:"profitCenter"},      
      {header:"Strategy", width: 100, sortable: false,  dataIndex:"strategy"},
      {header:"Purpose", width: 100, sortable: false,  dataIndex:"purpose"},
      {header:"Nominee", width: 100, sortable: false,  dataIndex:"nominee"},      
      {header:"Remarks", width: 100, sortable: false,  dataIndex:"remarks"}]'
WHERE  FILE_TYPE_ID = 'IMPORT_MONTH_BASED_DERIVATIVE_TRADES'
/
UPDATE ITCM_IMP_TABLE_COLUMN_MAPPING
SET FILE_COLUMN_NAME = 'Prompt/Delivery Details'
WHERE  FILE_TYPE_ID = 'IMPORT_MONTH_BASED_DERIVATIVE_TRADES' AND DB_COLUMN_NAME = 'DELIVERY_PERIOD'
/
ALTER TABLE DT_FBI_D
MODIFY(FORMULA_INST VARCHAR2(50 CHAR))
/

ALTER TABLE DT_FBI_D
MODIFY(FORMULA VARCHAR2(50 CHAR))
/
ALTER TABLE DT_FBI_D
MODIFY(PRICE_SOURCE VARCHAR2(50 CHAR))
/

ALTER TABLE DT_FBI_D
MODIFY(PRICE_POINT VARCHAR2(50 CHAR))
/

ALTER TABLE DT_FBI_D
MODIFY(AVAILABLE_PRICE VARCHAR2(50 CHAR))
/


ALTER TABLE DT_FBI_D
MODIFY(FB_PERIOD_SUB_TYPE VARCHAR2(50 CHAR))
/

ALTER TABLE DT_FBI_D
MODIFY(PERIOD_TYPE VARCHAR2(50 CHAR))
/


ALTER TABLE DT_FBI_D
MODIFY(OFF_DAY_PRICE VARCHAR2(50 CHAR))
/


ALTER TABLE DT_FBI_D
MODIFY(DELIVERY_PERIOD VARCHAR2(50 CHAR))
/
UPDATE itcm_imp_table_column_mapping itcm
   SET itcm.db_column_name = 'DELIVERY_PERIOD'
 WHERE itcm.file_type_id = 'IMPORT_FX_OPTION_QUOTES'
   AND itcm.db_column_name = 'PERIOD'
/
INSERT INTO dtm_deal_type_master
            (deal_type_id, deal_type_name, deal_type_display_name,
             is_multiple_leg_involved, display_order, VERSION, is_active,
             is_deleted
            )
     VALUES ('DTM-20', 'OAFS', 'OTC Average Forward Strip',
             'N', 20, '1', 'Y',
             'N'
            )
/
INSERT INTO ddpm_der_deal_purpose_mapping
            (deal_type_id, purpose_id, entity, is_deleted
            )
     VALUES ('DTM-20', 'DPM-3', 'Derivative', 'N'
            )
/
INSERT INTO ddpm_der_deal_purpose_mapping
            (deal_type_id, purpose_id, entity, is_deleted
            )
     VALUES ('DTM-20', 'DPM-4', 'Derivative', 'N'
            )
/
INSERT INTO ddpm_der_deal_purpose_mapping
            (deal_type_id, purpose_id, entity, is_deleted
            )
     VALUES ('DTM-20', 'DPM-2', 'Derivative', 'N'
            )
/
INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Monthly Prompt', 'Monthly Prompt'
            )
/
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('promptDateTypeList', 'Cash', 'N', 1
            )
/
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('promptDateTypeList', 'Monthly Prompt', 'N', 2
            )
/
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('frequencyList', 'Monthly', 'N', 1
            )
/
UPDATE amc_app_menu_configuration amc
   SET amc.display_seq_no = 3
 WHERE amc.menu_id = 'CDC-D292'
/
INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called,
             icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID,
             is_deleted
            )
     VALUES ('CDC-D295', 'New Average Strips ', 2, 4,
             '/cdc/loadNewAverageStripTrade.action?dealType=OAFS&dealTypeID=DTM-20&action=Create&isWhatIf=N',
             NULL, 'CDC-D29', NULL, 'Derivative', NULL,
             'N'
            )
/
update GM_GRID_MASTER gm set GM.DEFAULT_COLUMN_MODEL_STATE = '[{header: "Trade Ref. No.", width: 150, sortable: true, dataIndex: "tradeRefNo"},
                     {header: "Underlying Instrument Ref. No.", width: 150, sortable: true, dataIndex: "underlyingInstrRefNo"},
                     {header: "Strip Ref. No.", width: 150, sortable: true, dataIndex: "stripRefNo"},
                     {header: "Trade Date", width: 150, sortable: true, dataIndex: "tradeDate"},
                     {header: "Trader", width: 150, sortable: true, dataIndex: "traderName"},
                     {header: "External Trade Ref. No.", width: 150, sortable: true, dataIndex: "externalRefNo"},                     
                     {header: "Prompt/Delivery Details", width: 150, sortable: true, dataIndex: "deliveryDateMonth"},
                     {header: "B/S", width: 150, sortable: true, dataIndex: "buySell"},
                     {header: "Clearer", width: 150, sortable: true, dataIndex: "clearerName"},
                     {header: "Clearing Account", width: 150, sortable: true, dataIndex: "clearerAccount"},
                     {header: "Purpose", width: 150, sortable: true, dataIndex: "purposeDisplayName"},
                     {header: "Internal Trade Nos.", width: 150, sortable: true, dataIndex: "intTradeNumber"},
                     {header: "Strategy", width: 150, sortable: true, dataIndex: "strategyName"},
                     {header: "Trade Basis Price", width: 150, sortable: true, dataIndex: "tradePriceTypeId"},
                     {header: "Total Quantity", width: 150, sortable: true, dataIndex: "totalQuantity"},
                     {header: "Total Lots", width: 150, sortable: true, dataIndex: "totalLots"},
                     {header: "Closed Lots", width: 150, sortable: true, dataIndex: "closedLots"},
                     {header: "Open Lots", width: 150, sortable: true, dataIndex: "openLots"},                     
                     {header: "Price", width: 150, sortable: true, dataIndex: "priceDetails"},
                     {header: "Status", width: 150, sortable: true, dataIndex: "status"},                     
                     {header: "Profit Center", width: 150, sortable: true, dataIndex: "profitCenterName"},
                     {header: "Deal Type", width: 150, sortable: true, dataIndex: "dealType"},
                     {header: "Average Pricing Period", width: 150, sortable: true, dataIndex: "averagePricingPeriod"},
                     {header: "Created By", width: 150, sortable: true, dataIndex: "createdBy"},
                     {header: "Created Date", width: 150, sortable: true, dataIndex: "createdDate"},
                     {header: "Created Through", width: 150, sortable: true, dataIndex: "createdThrough"}
                     {header: "Exchange Instrument", width: 150, sortable: true, dataIndex: "instrumentName"},
                     {header: "Price Source", width: 150, sortable: true, dataIndex: "priceSource"},
                     {header: "Price Point", width: 150, sortable: true, dataIndex: "pricePoint"},
                     {header: "Premium/Discount", width: 150, sortable: true, dataIndex: "premium"}]'
where GM.GRID_ID = 'LIST_AVERAGE_FORWARDS'
/
create or replace trigger "TRG_INSERT_DT_QTY_LOG"
/**************************************************************************************************
           Trigger Name                       : TRG_INSERT_DT_QTY_LOG
           Author                             : Venu
           Created Date                       : 17th May 2012
           Purpose                            : To Insert into DT_QTY_LOG Table

           Modification History

           Modified Date  :
           Modified By  :
           Modify Description :

   ***************************************************************************************************/
  after insert or update or delete on dt_derivative_trade
  for each row
declare
  v_total_qty      number(25, 4);
  v_open_qty       number(25, 4);
  v_closed_qty     number(25, 4);
  v_exercised_qty  number(25, 4);
  v_expired_qty    number(25, 4);
  v_total_lots     number(5);
  v_open_lots      number(5);
  v_closed_lots    number(5);
  v_exercised_lots number(5);
  v_expired_lots   number(5);
begin
  --
  -- If updating then put the delta for Quantity columns as Old - New
  -- If inserting put the new value as is as Delta
  --
  if updating then
    --Qty Unit is Not Updated
    if (:new.quantity_unit_id = :old.quantity_unit_id) then
    
      v_total_qty      := nvl(:new.total_quantity, 0) -
                          nvl(:old.total_quantity, 0);
      v_open_qty       := nvl(:new.open_quantity, 0) -
                          nvl(:old.open_quantity, 0);
      v_closed_qty     := nvl(:new.closed_quantity, 0) -
                          nvl(:old.closed_quantity, 0);
      v_exercised_qty  := nvl(:new.exercised_quantity, 0) -
                          nvl(:old.exercised_quantity, 0);
      v_expired_qty    := nvl(:new.expired_quantity, 0) -
                          nvl(:old.expired_quantity, 0);
      v_total_lots     := nvl(:new.total_lots, 0) - nvl(:old.total_lots, 0);
      v_open_lots      := nvl(:new.open_lots, 0) - nvl(:old.open_lots, 0);
      v_closed_lots    := nvl(:new.closed_lots, 0) -
                          nvl(:old.closed_lots, 0);
      v_exercised_lots := nvl(:new.exercised_lots, 0) -
                          nvl(:old.exercised_lots, 0);
      v_expired_lots   := nvl(:new.expired_lots, 0) -
                          nvl(:old.expired_lots, 0);
    
      if nvl(:new.status, 'XXX') = 'Delete' then
        v_total_qty := 0 - nvl(:old.total_quantity, 0);
      end if;
    
      if v_total_qty <> 0 or v_open_qty <> 0 or v_closed_qty <> 0 or
         v_exercised_qty <> 0 or v_expired_qty <> 0 or v_total_lots <> 0 or
         v_open_lots <> 0 or v_closed_lots <> 0 or v_exercised_lots <> 0 or
         v_expired_lots <> 0 then
        insert into dt_qty_log
          (internal_derivative_ref_no,
           derivative_ref_no,
           internal_action_ref_no,
           dr_id,
           corporate_id,
           status,
           quantity_unit_id,
           total_quantity_delta,
           open_quantity_delta,
           closed_quantity_delta,
           exercised_quantity_delta,
           expired_quantity_delta,
           total_lots_delta,
           open_lots_delta,
           closed_lots_delta,
           exercised_lots_delta,
           expired_lots_delta,
           entry_type)
        values
          (:new.internal_derivative_ref_no,
           :new.derivative_ref_no,
           :new.latest_internal_action_ref_no,
           :new.dr_id,
           :new.corporate_id,
           :new.status,
           :new.quantity_unit_id,
           v_total_qty,
           v_open_qty,
           v_closed_qty,
           v_exercised_qty,
           v_expired_qty,
           v_total_lots,
           v_open_lots,
           v_closed_lots,
           v_exercised_lots,
           v_expired_lots,
           'Update');
      end if;
    elsif deleting then
      insert into dt_qty_log
        (internal_derivative_ref_no,
         derivative_ref_no,
         internal_action_ref_no,
         dr_id,
         corporate_id,
         status,
         quantity_unit_id,
         total_quantity_delta,
         open_quantity_delta,
         closed_quantity_delta,
         exercised_quantity_delta,
         expired_quantity_delta,
         total_lots_delta,
         open_lots_delta,
         closed_lots_delta,
         exercised_lots_delta,
         expired_lots_delta,
         entry_type)
      values
        (:new.internal_derivative_ref_no,
         :new.derivative_ref_no,
         :new.latest_internal_action_ref_no,
         :new.dr_id,
         :new.corporate_id,
         :new.status,
         :new.quantity_unit_id,
         :new.total_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.total_quantity),
         :new.open_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.open_quantity),
         :new.closed_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.closed_quantity),
         :new.exercised_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.exercised_quantity),
         :new.expired_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.expired_quantity),
         :new.total_lots - :old.total_lots,
         :new.open_lots - :old.open_lots,
         :new.closed_lots - :old.closed_lots,
         :new.exercised_lots - :old.exercised_lots,
         :new.expired_lots - :old.expired_lots,
         'Delete');
    else
      --Qty Unit is Updated
      insert into dt_qty_log
        (internal_derivative_ref_no,
         derivative_ref_no,
         internal_action_ref_no,
         dr_id,
         corporate_id,
         status,
         quantity_unit_id,
         total_quantity_delta,
         open_quantity_delta,
         closed_quantity_delta,
         exercised_quantity_delta,
         expired_quantity_delta,
         total_lots_delta,
         open_lots_delta,
         closed_lots_delta,
         exercised_lots_delta,
         expired_lots_delta,
         entry_type)
      values
        (:new.internal_derivative_ref_no,
         :new.derivative_ref_no,
         :new.latest_internal_action_ref_no,
         :new.dr_id,
         :new.corporate_id,
         :new.status,
         :new.quantity_unit_id,
         :new.total_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.total_quantity),
         :new.open_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.open_quantity),
         :new.closed_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.closed_quantity),
         :new.exercised_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.exercised_quantity),
         :new.expired_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.expired_quantity),
         :new.total_lots - :old.total_lots,
         :new.open_lots - :old.open_lots,
         :new.closed_lots - :old.closed_lots,
         :new.exercised_lots - :old.exercised_lots,
         :new.expired_lots - :old.expired_lots,
         'Update');
    
    end if;
  
  else
    --
    -- New Entry ( Entry Type=Insert)
    --
    insert into dt_qty_log
      (internal_derivative_ref_no,
       derivative_ref_no,
       internal_action_ref_no,
       dr_id,
       corporate_id,
       status,
       quantity_unit_id,
       total_quantity_delta,
       open_quantity_delta,
       closed_quantity_delta,
       exercised_quantity_delta,
       expired_quantity_delta,
       total_lots_delta,
       open_lots_delta,
       closed_lots_delta,
       exercised_lots_delta,
       expired_lots_delta,
       entry_type)
    values
      (:new.internal_derivative_ref_no,
       :new.derivative_ref_no,
       :new.latest_internal_action_ref_no,
       :new.dr_id,
       :new.corporate_id,
       :new.status,
       :new.quantity_unit_id,
       :new.total_quantity,
       :new.open_quantity,
       :new.closed_quantity,
       :new.exercised_quantity,
       :new.expired_quantity,
       :new.total_lots,
       :new.open_lots,
       :new.closed_lots,
       :new.exercised_lots,
       :new.expired_lots,
       'Insert');
  
  end if;
end;
/
commit;