Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('MOD-ALLOC-&corpId', 'ModifyDerAlloc', '&corpId', 'MDA-', 1, 
    0,  '-&corpId', 1, 'N');
    
    
 
Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DR-ALLOC-&corpId', 'DerivativeAlloc', '&corpId', 'DA-', 1, 
    0, '-&corpId', 1, 'N'); 



Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('MOD-ALLOC-&corpId', '&corpId', 'MODIFY_DER_ALLOCATION', 'ModifyDerAlloc', 'N');
   
   
   
Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('DR-ALLOC-&corpId', '&corpId', 'DERIVATIVE_ALLOCATION', 'DerivativeAlloc', 'N');



Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   ('&corpId', 'MODIFY_DER_ALLOCATION', 'MDA-', 0, '-&corpId');



Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   ('&corpId', 'DERIVATIVE_ALLOCATION', 'DA-', 0, '-&corpId');



    
Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('REM-&corpId', 'ReturnMaterial', '&corpId', 'REM-', 1, 
    0, '-&corpId', 1, 'N');

 

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('REM-&corpId', '&corpId', 'CREATE_RETURN_MATERIAL', 'ReturnMaterial', 'N');



Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   ('&corpId', 'CREATE_RETURN_MATERIAL', 'REM-', 0, '-corpId');



