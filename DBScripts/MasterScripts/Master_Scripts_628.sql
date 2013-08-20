
Insert into IFM_IMPORT_FILE_MASTER
   (FILE_TYPE_ID, FILE_TYPE_NAME, TABLE_NAME, PROC_NAME, IS_ACTIVE, 
    SAMPLE_FILE_NAME, REMARKS, COLUMN_MODEL, RECORD_MODEL, FUNCTION_NAME, 
    FILE_MAPPING_TABLE_NAME, INSERT_QUERY, SELECT_QUERY, IS_ASYNCHRONOUS, IMPORT_LIMIT, 
    CONTEXT_PATH)
 Values
   ('IMPORT_SECONDARY_PROVISIONAL_ASSAY', 'SecondaryProvAssay.xls', 'ISPA_IMPORT_SEC_PRO_ASSAY', NULL, 'Y', 
    NULL, NULL, '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},
{header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},
{header:"Stock Ref No.", width: 100, sortable: false,  dataIndex:"property1"},
{header:"Element Name", width: 100, sortable: false,  dataIndex:"property2"},
{header:"Min value", width: 100, sortable: false,  dataIndex:"property3"},
{header:"Max value", width: 100, sortable: false,  dataIndex:"property4"},
{header:"Provisional Assay Value", width: 100, sortable: false,  dataIndex:"property5"},
{header:"UoM", width: 100, sortable: false,  dataIndex:"property6"}]', '[{name: "lineNo", mapping: "lineNo"},
{name: "isBadRecord", mapping: "isBadRecord"},
{name: "property1", mapping: "property1"},
{name: "property2", mapping: "property2"},
{name: "property3", mapping: "property3"},
{name: "property4", mapping: "property4"},
{name: "property5", mapping: "property5"},
{name: "property6", mapping: "property6"}]', 'window.opener.Eka.metal.physical.secondaryassaymanagement.saveAssayImport', 
    'FMIIRS_FILE_MAPPING_IIRS', 'insert into IVR_IMPORT_VALID_RECORD(TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6) values(?,?,?,?,?,?,?,?,?)', 'rn,count(*) over() TOTAL_NO_OF_RECORDS,TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6 from IVR_IMPORT_VALID_RECORD', NULL, NULL, 
    NULL);



Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SECONDARY_PROVISIONAL_ASSAY', 'Element Name', 'Element_name', 'Pre populated,user can not change.', NULL, 
    NULL, 2, 'elementName', 'Alphanumeric', 'Y', 
    NULL, NULL, NULL);
    
    

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SECONDARY_PROVISIONAL_ASSAY', 'Min Value', 'Min_Value', 'Pre populated,user can not change.', NULL, 
    NULL, 3, 'minValue', 'Number', 'Y', 
    NULL, NULL, NULL);

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SECONDARY_PROVISIONAL_ASSAY', 'Max Value', 'Max_Value', 'Pre populated,user can not change.', NULL, 
    NULL, 4, 'maxValue', NULL, NULL, 
    NULL, NULL, NULL);


Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SECONDARY_PROVISIONAL_ASSAY', 'Provisional Assay Value', 'Typical_Value', 'User can change the values.', NULL, 
    NULL, 5, 'typicalValue', NULL, NULL, 
    NULL, NULL, NULL);


Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SECONDARY_PROVISIONAL_ASSAY', 'UoM', 'Uom', 'Pre populated,user can not change.', NULL, 
    NULL, 6, 'uom', NULL, NULL, 
    NULL, NULL, NULL);


Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SECONDARY_PROVISIONAL_ASSAY', 'Stock Ref No.', 'User_Sub_Lot_Ref_No', 'Pre populated,user can not change.', NULL, 
    NULL, 1, 'userSubLotRefNo', 'Alphanumeric', NULL, 
    NULL, NULL, NULL);
