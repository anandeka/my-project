

Insert into IFM_IMPORT_FILE_MASTER
   (FILE_TYPE_ID, FILE_TYPE_NAME, TABLE_NAME, PROC_NAME, IS_ACTIVE, 
    SAMPLE_FILE_NAME, REMARKS, COLUMN_MODEL, RECORD_MODEL, FUNCTION_NAME, 
    FILE_MAPPING_TABLE_NAME, INSERT_QUERY, SELECT_QUERY)
 Values
   ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'ImportProvisionalAssay.xls', 'IPA_IMPORT_PRO_ASSAY', NULL, 'Y', 
    NULL, NULL, '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},
{header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},
{header:"System generated Sub lot Ref No.", width: 100, sortable: false,  dataIndex:"property1"},
{header:"User Defined Sub lot Ref No.", width: 100, sortable: false,  dataIndex:"property2"},
{header:"Element", width: 100, sortable: false,  dataIndex:"property3"},
{header:"Provsional Assay Value", width: 100, sortable: false,  dataIndex:"property4"},
{header:"UoM", width: 100, sortable: false,  dataIndex:"property5"}]', '[{name: "lineNo", mapping: "lineNo"},
{name: "isBadRecord", mapping: "isBadRecord"},
{name: "property1", mapping: "property1"},
{name: "property2", mapping: "property2"},
{name: "property3", mapping: "property3"},
{name: "property4", mapping: "property4"},
{name: "property5", mapping: "property5"}]', 'window.opener.Eka.metal.physical.assaymanagement.saveAssayImport', 
    'FMIIRS_FILE_MAPPING_IIRS', 'insert into IVR_IMPORT_VALID_RECORD(TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5) values(?,?,?,?,?,?,?,?)', 'rn,count(*) over() TOTAL_NO_OF_RECORDS,TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5 from IVR_IMPORT_VALID_RECORD');



Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'System generated Sub lot Ref No.', 'Sys_Sub_Lot_Ref_No', NULL, NULL, 
    NULL, 1, 'sysSubLotRefNo');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'User Defined Sub lot Ref No.', 'User_Sub_Lot_Ref_No', NULL, NULL, 
    NULL, 2, 'userSubLotRefNo');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'Element', 'Element_Name', NULL, 0, 
    NULL, 3, 'elementName');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'Provsional Assay Value', 'Typical_Value', NULL, 0, 
    NULL, 4, 'typicalValue');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'UoM', 'Uom', NULL, 0, 
    NULL, 5, 'uom');



Insert into IFM_IMPORT_FILE_MASTER
   (FILE_TYPE_ID, FILE_TYPE_NAME, TABLE_NAME, PROC_NAME, IS_ACTIVE, 
    SAMPLE_FILE_NAME, REMARKS, COLUMN_MODEL, RECORD_MODEL, FUNCTION_NAME, 
    FILE_MAPPING_TABLE_NAME, INSERT_QUERY, SELECT_QUERY)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'ImportWsAssay.xls', 'IPA_IMPORT_PRO_ASSAY', NULL, 'Y', 
    NULL, NULL, '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},
{header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},
{header:"System generated Sub lot Ref No.", width: 100, sortable: false,  dataIndex:"property1"},
{header:"User Defined Sub lot Ref No.", width: 100, sortable: false,  dataIndex:"property2"},
{header:"Parameters", width: 100, sortable: false,  dataIndex:"property3"},
{header:"Value", width: 100, sortable: false,  dataIndex:"property4"},
{header:"UoM", width: 100, sortable: false,  dataIndex:"property5"}
]', '[{name: "lineNo", mapping: "lineNo"},
{name: "isBadRecord", mapping: "isBadRecord"},
{name: "property1", mapping: "property1"},
{name: "property2", mapping: "property2"},
{name: "property3", mapping: "property3"},
{name: "property4", mapping: "property4"},
{name: "property5", mapping: "property5"}]', 'window.opener.Eka.metal.physical.assaymanagement.saveWsAssayImport', 
    'FMIIRS_FILE_MAPPING_IIRS', 'insert into IVR_IMPORT_VALID_RECORD(TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5) values(?,?,?,?,?,?,?,?)', 'rn,count(*) over() TOTAL_NO_OF_RECORDS,TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5 from IVR_IMPORT_VALID_RECORD');


Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'System generated Sub lot Ref No.', 'Sys_Sub_Lot_Ref_No', NULL, NULL, 
    NULL, 1, 'sysSubLotRefNo');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'User Defined Sub lot Ref No.', 'User_Sub_Lot_Ref_No', NULL, NULL, 
    NULL, 2, 'userSubLotRefNo');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'Parameters', 'Parameter_Name', NULL, 0, 
    NULL, 3, 'parameterName');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'Value', 'Typical_Value', NULL, NULL, 
    NULL, 4, 'typicalValue');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'UoM', 'Uom', NULL, 0, 
    NULL, 5, 'uom');

Insert into IFM_IMPORT_FILE_MASTER
   (FILE_TYPE_ID, FILE_TYPE_NAME, TABLE_NAME, PROC_NAME, IS_ACTIVE, 
    SAMPLE_FILE_NAME, REMARKS, COLUMN_MODEL, RECORD_MODEL, FUNCTION_NAME, 
    FILE_MAPPING_TABLE_NAME, INSERT_QUERY, SELECT_QUERY)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'ImportSCUAssay.xls', 'IPA_IMPORT_SCU_ASSAY', NULL, 'Y', 
    NULL, NULL, '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},
{header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},
{header:"System generated Sub lot Ref No.", width: 100, sortable: false,  dataIndex:"property1"},
{header:"User Defined Sub lot Ref No.", width: 100, sortable: false,  dataIndex:"property2"},
{header:"Element", width: 100, sortable: false,  dataIndex:"property3"},
{header:"Assay Value", width: 100, sortable: false,  dataIndex:"property4"},
{header:"UoM", width: 100, sortable: false,  dataIndex:"property5"}
]', '[{name: "lineNo", mapping: "lineNo"},
{name: "isBadRecord", mapping: "isBadRecord"},
{name: "property1", mapping: "property1"},
{name: "property2", mapping: "property2"},
{name: "property3", mapping: "property3"},
{name: "property4", mapping: "property4"},
{name: "property5", mapping: "property5"}]', 'window.opener.Eka.metal.physical.assaymanagement.saveSCUAssayImport', 
    'FMIIRS_FILE_MAPPING_IIRS', 'insert into IVR_IMPORT_VALID_RECORD(TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5) values(?,?,?,?,?,?,?,?)', 'rn,count(*) over() TOTAL_NO_OF_RECORDS,TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5 from IVR_IMPORT_VALID_RECORD');


Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'System generated Sub lot Ref No.', 'Sys_Sub_Lot_Ref_No', NULL, NULL, 
    NULL, 1, 'sysSubLotRefNo');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'User Defined Sub lot Ref No.', 'User_Sub_Lot_Ref_No', NULL, NULL, 
    NULL, 2, 'userSubLotRefNo');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'Element', 'Element_Name', NULL, 0, 
    NULL, 3, 'elementName');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'Assay Value', 'Typical_Value', NULL, NULL, 
    NULL, 4, 'typicalValue');

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'UoM', 'Uom', NULL, 0, 
    NULL, 5, 'uom');






