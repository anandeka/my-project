Insert into MRCT_MDM_REFERENCE_CONF_TABLE
   (MAIN_TABLE_NAME, MAIN_TABLE_COLUMN_NAME, CHILD_TABLE_NAME, CHILD_TABLE_COLUMN_NAME, CONDITION_ID)
 Values
   ('BPSLD_BP_STORAGE_LOC_DET', 'PROFILE_ID', 'GMR_GOODS_MOVEMENT_RECORD', 'WAREHOUSE_PROFILE_ID', 'GEN-1');

Insert into MRCT_MDM_REFERENCE_CONF_TABLE
   (MAIN_TABLE_NAME, MAIN_TABLE_COLUMN_NAME, CHILD_TABLE_NAME, CHILD_TABLE_COLUMN_NAME, CONDITION_ID)
 Values
   ('BPSLD_BP_STORAGE_LOC_DET', 'STORAGE_LOC_ID', 'GMR_GOODS_MOVEMENT_RECORD', 'SHED_ID', 'GEN-1');