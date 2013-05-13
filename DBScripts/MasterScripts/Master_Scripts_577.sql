--- Provisional Assay upload---

UPDATE ifm_import_file_master ifm
   SET ifm.column_model =
          '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},
{header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},
{header:"Element Name", width: 100, sortable: false,  dataIndex:"property1"},
{header:"Min value", width: 100, sortable: false,  dataIndex:"property2"},
{header:"Max value", width: 100, sortable: false,  dataIndex:"property3"},
{header:"Provisional Assay Value", width: 100, sortable: false,  dataIndex:"property4"},
{header:"UoM", width: 100, sortable: false,  dataIndex:"property5"}]',
       ifm.record_model =
          '[{name: "lineNo", mapping: "lineNo"},
{name: "isBadRecord", mapping: "isBadRecord"},
{name: "property1", mapping: "property1"},
{name: "property2", mapping: "property2"},
{name: "property3", mapping: "property3"},
{name: "property4", mapping: "property4"},
{name: "property5", mapping: "property5"}]',
       ifm.insert_query =
          'insert into IVR_IMPORT_VALID_RECORD(TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5) values(?,?,?,?,?,?,?,?)',
       ifm.select_query =
          'rn,count(*) over() TOTAL_NO_OF_RECORDS,TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5 from IVR_IMPORT_VALID_RECORD'
 WHERE ifm.file_type_id = 'IMPORT_PROVISIONAL_ASSAY_DETAILS';



DELETE FROM itcm_imp_table_column_mapping itcm
      WHERE itcm.file_type_id = 'IMPORT_PROVISIONAL_ASSAY_DETAILS';


INSERT INTO itcm_imp_table_column_mapping
            (file_type_id, file_column_name,
             db_column_name, remarks, min_value,
             mapped_column_name, column_order, property_name, data_type,
             is_mandatory, data_length, data_precision, data_scale
            )
     VALUES ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'Element Name',
             'Element_name', 'Pre populated,user can not change.', NULL,
             NULL, 1, 'elementName', 'Alphanumeric',
             'Y', NULL, NULL, NULL
            );

INSERT INTO itcm_imp_table_column_mapping
            (file_type_id, file_column_name, db_column_name,
             remarks, min_value, mapped_column_name, column_order,
             property_name, data_type, is_mandatory, data_length,
             data_precision, data_scale
            )
     VALUES ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'Min Value', 'Min_Value',
             'Pre populated,user can not change.', NULL, NULL, 2,
             'minValue', 'Number', 'Y', NULL,
             NULL, NULL
            );

INSERT INTO itcm_imp_table_column_mapping
            (file_type_id, file_column_name, db_column_name,
             remarks, min_value, mapped_column_name, column_order,
             property_name, data_type, is_mandatory, data_length,
             data_precision, data_scale
            )
     VALUES ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'Max Value', 'Max_Value',
             'Pre populated,user can not change.', NULL, NULL, 3,
             'maxValue', NULL, NULL, NULL,
             NULL, NULL
            );

INSERT INTO itcm_imp_table_column_mapping
            (file_type_id, file_column_name,
             db_column_name, remarks, min_value, mapped_column_name,
             column_order, property_name, data_type, is_mandatory,
             data_length, data_precision, data_scale
            )
     VALUES ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'Provisional Assay Value',
             'Typical_Value', 'User can change the values.', NULL, NULL,
             4, 'typicalValue', NULL, NULL,
             NULL, NULL, NULL
            );

INSERT INTO itcm_imp_table_column_mapping
            (file_type_id, file_column_name, db_column_name,
             remarks, min_value, mapped_column_name, column_order,
             property_name, data_type, is_mandatory, data_length,
             data_precision, data_scale
            )
     VALUES ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'UoM', 'Uom',
             'Pre populated,user can not change.', NULL, NULL, 5,
             'uom', NULL, NULL, NULL,
             NULL, NULL
            );

--- Upload Self Cp Umpire assays --

DELETE FROM itcm_imp_table_column_mapping itcm
      WHERE itcm.file_type_id = 'IMPORT_SCU_ASSAY_DETAILS';
      

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'System Sub Lot Ref No.', 'Sys_Sub_Lot_Ref_No', 'Pre populated,user can not change.', NULL, 
    NULL, 1, 'sysSubLotRefNo', 'Alphanumeric', NULL, 
    NULL, NULL, NULL);

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'User Sub Lot Ref No.', 'User_Sub_Lot_Ref_No', 'Pre populated,user can not change.', NULL, 
    NULL, 2, 'userSubLotRefNo', 'Alphanumeric', NULL, 
    NULL, NULL, NULL);
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'Element Name', 'Element_Name', 'Pre populated,user can not change.', NULL, 
    NULL, 3, 'elementName', 'Alphanumeric', NULL, 
    NULL, NULL, NULL);
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'Min Value', 'Min_Value', 'Pre populated,user can not change.', NULL, 
    NULL, 4, 'minValue', 'Number', 'Y', 
    NULL, NULL, NULL);
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'Max Value', 'Max_Value', 'Pre populated,user can not change.', NULL, 
    NULL, 5, 'maxValue', 'Number', NULL, 
    NULL, NULL, NULL);
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'Typical Value', 'Typical_Value', 'User can change the values.', NULL, 
    NULL, 6, 'typicalValue', 'Number', NULL, 
    NULL, NULL, NULL);
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_SCU_ASSAY_DETAILS', 'UoM', 'Uom', 'Pre populated,user can not change.', NULL, 
    NULL, 7, 'uom', 'Alphanumeric', NULL, 
    NULL, NULL, NULL);

    
    
UPDATE ifm_import_file_master ifm
   SET ifm.column_model =
          '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},
{header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},
{header:"System Sub Lot Ref No.", width: 100, sortable: false,  dataIndex:"property1"},
{header:"User Sub Lot Ref No.", width: 100, sortable: false,  dataIndex:"property2"},
{header:"Element Name", width: 100, sortable: false,  dataIndex:"property3"},
{header:"Min Value", width: 100, sortable: false,  dataIndex:"property4"},
{header:"Max Value", width: 100, sortable: false,  dataIndex:"property5"},
{header:"Typical Value", width: 100, sortable: false,  dataIndex:"property6"},
{header:"UoM", width: 100, sortable: false,  dataIndex:"property7"}]',
       ifm.record_model =
          '[{name: "lineNo", mapping: "lineNo"},
{name: "isBadRecord", mapping: "isBadRecord"},
{name: "property1", mapping: "property1"},
{name: "property2", mapping: "property2"},
{name: "property3", mapping: "property3"},
{name: "property4", mapping: "property4"},
{name: "property5", mapping: "property5"},
{name: "property6", mapping: "property6"},
{name: "property7", mapping: "property7"}]',
       ifm.insert_query =
          'insert into IVR_IMPORT_VALID_RECORD(TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6,property7) values(?,?,?,?,?,?,?,?,?,?)',
       ifm.select_query =
          'rn,count(*) over() TOTAL_NO_OF_RECORDS,TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6,property7 from IVR_IMPORT_VALID_RECORD'
 WHERE ifm.file_type_id = 'IMPORT_SCU_ASSAY_DETAILS'; 

---Upload Consolidation self/cp/umpire assays---

Insert into IFM_IMPORT_FILE_MASTER
   (FILE_TYPE_ID, FILE_TYPE_NAME, TABLE_NAME, PROC_NAME, IS_ACTIVE, 
    SAMPLE_FILE_NAME, REMARKS, COLUMN_MODEL, RECORD_MODEL, FUNCTION_NAME, 
    FILE_MAPPING_TABLE_NAME, INSERT_QUERY, SELECT_QUERY, IS_ASYNCHRONOUS, IMPORT_LIMIT, 
    CONTEXT_PATH)
 Values
   ('IMPORT_CONSOL_SCU_ASSAY_DETAILS', 'ImportSCUAssay.xls', 'IPA_IMPORT_SCU_ASSAY', NULL, 'Y', 
    NULL, NULL, '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},
{header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},
{header:"Sub Lot Ref No.", width: 100, sortable: false,  dataIndex:"property1"},
{header:"Element Name", width: 100, sortable: false,  dataIndex:"property2"},
{header:"Min Value", width: 100, sortable: false,  dataIndex:"property3"},
{header:"Max Value", width: 100, sortable: false,  dataIndex:"property4"},
{header:"Typical Value", width: 100, sortable: false,  dataIndex:"property5"},
{header:"UoM", width: 100, sortable: false,  dataIndex:"property6"}]', '[{name: "lineNo", mapping: "lineNo"},
{name: "isBadRecord", mapping: "isBadRecord"},
{name: "property1", mapping: "property1"},
{name: "property2", mapping: "property2"},
{name: "property3", mapping: "property3"},
{name: "property4", mapping: "property4"},
{name: "property5", mapping: "property5"},
{name: "property6", mapping: "property6"}]', 'window.opener.Eka.metal.physical.assaymanagement.saveSCUAssayImport', 
    'FMIIRS_FILE_MAPPING_IIRS', 'insert into IVR_IMPORT_VALID_RECORD

(TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6) values(?,?,?,?,?,?,?,?,?)', 'rn,count(*) over() 

TOTAL_NO_OF_RECORDS,TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6 from 

IVR_IMPORT_VALID_RECORD', NULL, NULL, 
    NULL);
    
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_CONSOL_SCU_ASSAY_DETAILS', 'Sub Lot Ref No.', 'Sys_Sub_Lot_Ref_No', 'Pre populated,user can not change.', NULL, 
    NULL, 1, 'sysSubLotRefNo', 'Alphanumeric', NULL, 
    NULL, NULL, NULL);


Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_CONSOL_SCU_ASSAY_DETAILS', 'Element Name', 'Element_Name', 'Pre populated,user can not change.', NULL, 
    NULL, 2, 'elementName', 'Alphanumeric', NULL, 
    NULL, NULL, NULL);
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_CONSOL_SCU_ASSAY_DETAILS', 'Min Value', 'Min_Value', 'Pre populated,user can not change.', NULL, 
    NULL, 3, 'minValue', 'Number', 'Y', 
    NULL, NULL, NULL);
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_CONSOL_SCU_ASSAY_DETAILS', 'Max Value', 'Max_Value', 'Pre populated,user can not change.', NULL, 
    NULL, 4, 'maxValue', 'Number', NULL, 
    NULL, NULL, NULL);
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_CONSOL_SCU_ASSAY_DETAILS', 'Typical Value', 'Typical_Value', 'User can change the values.', NULL, 
    NULL, 5, 'typicalValue', 'Number', NULL, 
    NULL, NULL, NULL);
Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME, DATA_TYPE, IS_MANDATORY, 
    DATA_LENGTH, DATA_PRECISION, DATA_SCALE)
 Values
   ('IMPORT_CONSOL_SCU_ASSAY_DETAILS', 'UoM', 'Uom', 'Pre populated,user can not change.', NULL, 
    NULL, 6, 'uom', 'Alphanumeric', NULL, 
    NULL, NULL, NULL);