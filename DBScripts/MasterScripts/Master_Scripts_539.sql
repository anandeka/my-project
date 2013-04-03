UPDATE ifm_import_file_master ifm
   SET ifm.column_model =
          '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},
{header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},
{header:"Sub Lot", width: 100, sortable: false,  dataIndex:"property1"},
{header:"Sub Lot Ref No.", width: 100, sortable: false,  dataIndex:"property2"},
{header:"Wet Weight", width: 100, sortable: false,  dataIndex:"property3"},
{header:"UoM", width: 100, sortable: false,  dataIndex:"property4"},
{header:"Min Value", width: 100, sortable: false,  dataIndex:"property5"},
{header: "Max Value", width: 100, sortable: false,  dataIndex: "property6"},
{header: "H2O", width: 100, sortable: false, dataIndex: "property7"},
{header:"Element UoM", width: 100, sortable: false,  dataIndex:"property8"},
{header:"Remarks-1", width: 100, sortable: false,  dataIndex:"property9"},
{header:"Remarks-2", width: 100, sortable: false,  dataIndex:"property10"}
]',
       ifm.record_model =
          '[{name: "lineNo", mapping: "lineNo"},
{name: "isBadRecord", mapping: "isBadRecord"},
{name: "property1", mapping: "property1"},
{name: "property2", mapping: "property2"},
{name: "property3", mapping: "property3"},
{name: "property4", mapping: "property4"},
{name: "property5", mapping: "property5"},
{name: "property6", mapping: "property6"},
{name: "property7", mapping: "property7"},
{name: "property8", mapping: "property8"},
{name: "property9", mapping: "property9"},
{name: "property10", mapping: "property10"}]',
       ifm.insert_query =
          'insert into IVR_IMPORT_VALID_RECORD(TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6,property7,property8,property9,property10) values(?,?,?,?,?,?,?,?,?,?,?,?,?)',
       ifm.select_query =
          'rn,count(*) over() TOTAL_NO_OF_RECORDS,TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6,property7,property8,property9,property10 from IVR_IMPORT_VALID_RECORD'
 WHERE ifm.file_type_id = 'IMPORT_WS_ASSAY_DETAILS';

UPDATE itcm_imp_table_column_mapping itcm
   SET itcm.file_column_name = 'Sub Lot',
   ITCM.REMARKS='Pre populated,user can not change.',
   ITCM.IS_MANDATORY='Y',
   ITCM.DATA_TYPE='Alphanumeric'
 WHERE itcm.db_column_name = 'Sys_Sub_Lot_Ref_No'
   AND itcm.file_type_id = 'IMPORT_WS_ASSAY_DETAILS';
   
   
UPDATE itcm_imp_table_column_mapping itcm
   SET itcm.file_column_name = 'Sub Lot Ref No.',
   ITCM.REMARKS='Non mandatory-can be left blanck.',
   ITCM.IS_MANDATORY='N',
   ITCM.DATA_TYPE='Alphanumeric'
 WHERE itcm.db_column_name = 'User_Sub_Lot_Ref_No'
   AND itcm.file_type_id = 'IMPORT_WS_ASSAY_DETAILS';  
   
   
   UPDATE itcm_imp_table_column_mapping itcm
   SET ITCM.COLUMN_ORDER='4',
   ITCM.REMARKS='Pre populated,user can not change.',
   ITCM.IS_MANDATORY='Y',
   ITCM.DATA_TYPE='Alphanumeric'
 WHERE itcm.db_column_name = 'Uom'
   AND itcm.file_type_id = 'IMPORT_WS_ASSAY_DETAILS'; 
   


DELETE FROM itcm_imp_table_column_mapping itcm
      WHERE itcm.db_column_name = 'Typical_Value'
        AND itcm.file_type_id = 'IMPORT_WS_ASSAY_DETAILS';
      
DELETE FROM itcm_imp_table_column_mapping itcm
      WHERE itcm.db_column_name = 'Parameter_Name';      

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'Wet Weight', 'WET_WEIGHT', 'Pre populated,user can change.Only numeric values allowed.', 0, 
    NULL, 3, 'wetWeight', 'Number', 'Y', 
    NULL, NULL, NULL);
    
    
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'Min Value', 'MIN_VALUE', 'Pre populated,user can not change.', 0, 
    NULL, 5, 'minValue', 'Number', 'N', 
    NULL, NULL, NULL);
    
    
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'Max Value', 'MAX_VALUE', 'Pre populated,user can not change', 0, 
    NULL, 6, 'maxValue', 'Number', 'N', 
    NULL, NULL, NULL);     
    
    
    
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'H2O', 'TYPICAL_VALUE', 'Pre populated,user can change.Only numeric values allowed.', 0, 
    NULL, 7, 'typicalValue', 'Number', 'Y', 
    NULL, NULL, NULL);
    
    
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'Element UoM', 'ELEMENT_UOM', 'Pre populated,user can not change', 0, 
    NULL, 8, 'elementUom', 'Alphanumeric', 'N', 
    NULL, NULL, NULL);       
    
    
    
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'Remarks-1', 'REMARKS_ONE', 'Non Mandatory', 0, 
    NULL, 9, 'remarksOne', 'Alphanumeric', 'N', 
    NULL, NULL, NULL);     
    
    
    
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS', 'Remarks-2', 'REMARKS_TWO', 'Non Mandatory', 0, 
    NULL, 10, 'remarksTwo', 'Alphanumeric', 'N', 
    NULL, NULL, NULL);




INSERT INTO ifm_import_file_master
            (file_type_id, file_type_name,
             table_name, proc_name, is_active, sample_file_name, remarks,
             column_model,
             record_model,
             function_name,
             file_mapping_table_name,
             insert_query,
             select_query,
             is_asynchronous, import_limit, context_path
            )
     VALUES ('IMPORT_WS_ASSAY_DETAILS_CON', 'ImportWsAssay.xls',
             'IPA_IMPORT_PRO_ASSAY', NULL, 'Y', NULL, NULL,
             '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},
{header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},
{header:"Sub Lot", width: 100, sortable: false,  dataIndex:"property1"},
{header:"Sub Lot Ref No.", width: 100, sortable: false,  dataIndex:"property2"},
{header:"Wet Weight", width: 100, sortable: false,  dataIndex:"property3"},
{header:"UoM", width: 100, sortable: false,  dataIndex:"property4"},
{header:"Min Value", width: 100, sortable: false,  dataIndex:"property5"},
{header: "Max Value", width: 100, sortable: false,  dataIndex: "property6"},
{header: "H2O", width: 100, sortable: false, dataIndex: "property7"},
{header:"Element UoM", width: 100, sortable: false,  dataIndex:"property8"}]',
             '[{name: "lineNo", mapping: "lineNo"},
{name: "isBadRecord", mapping: "isBadRecord"},
{name: "property1", mapping: "property1"},
{name: "property2", mapping: "property2"},
{name: "property3", mapping: "property3"},
{name: "property4", mapping: "property4"},
{name: "property5", mapping: "property5"},
{name: "property6", mapping: "property6"},
{name: "property7", mapping: "property7"},
{name: "property8", mapping: "property8"}]',
             'window.opener.Eka.metal.physical.assaymanagement.saveWsAssayImport',
             'FMIIRS_FILE_MAPPING_IIRS',
             'insert into IVR_IMPORT_VALID_RECORD(TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6,property7,property8) values(?,?,?,?,?,?,?,?,?,?,?)',
             'rn,count(*) over() TOTAL_NO_OF_RECORDS,TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6,property7,property8 from IVR_IMPORT_VALID_RECORD',
             NULL, NULL, NULL
            );



Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS_CON', 'Sub Lot', 'Sys_Sub_Lot_Ref_No', 'Pre populated,user can not change.', NULL, 
    NULL, 1, 'sysSubLotRefNo', 'Alphanumeric', 'Y', 
    NULL, NULL, NULL);

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS_CON', 'Sub Lot Ref No.', 'User_Sub_Lot_Ref_No', 'Non mandatory-can be left blanck.', NULL, 
    NULL, 2, 'userSubLotRefNo', 'Alphanumeric', 'N', 
    NULL, NULL, NULL);

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS_CON', 'UoM', 'Uom', 'Pre populated,user can not change.', NULL, 
    NULL, 4, 'uom', 'Alphanumeric', 'N', 
    NULL, NULL, NULL);

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS_CON', 'Wet Weight', 'WET_WEIGHT', 'Pre populated,user can change.Only numeric values allowed.', 0, 
    NULL, 3, 'wetWeight', 'Number', 'Y', 
    NULL, NULL, NULL);

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS_CON', 'Min Value', 'MIN_VALUE', 'Pre populated,user can not change.', 0, 
    NULL, 5, 'minValue', 'Number', 'N', 
    NULL, NULL, NULL);

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS_CON', 'Max Value', 'MAX_VALUE', 'Pre populated,user can not change.', 0, 
    NULL, 6, 'maxValue', 'Number', 'N', 
    NULL, NULL, NULL);

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS_CON', 'H2O', 'TYPICAL_VALUE', 'Pre populated,user can change.Only numeric values allowed.', 0, 
    NULL, 7, 'typicalValue', 'Number', 'Y', 
    NULL, NULL, NULL);

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_WS_ASSAY_DETAILS_CON', 'Element UoM', 'ELEMENT_UOM', 'Pre populated,user can not change.', NULL, 
    NULL, 8, 'elementUom', 'Alphanumeric', 'N', 
    NULL, NULL, NULL);



