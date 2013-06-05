
INSERT INTO itcm_imp_table_column_mapping
            (file_type_id, file_column_name,
             db_column_name, remarks,
             min_value, mapped_column_name, column_order, property_name,
             data_type, is_mandatory, data_length, data_precision, data_scale
            )
     VALUES ('IMPORT_PROVISIONAL_ASSAY_DETAILS', 'Stock Ref No.',
             'User_Sub_Lot_Ref_No', 'Pre populated,user can not change.',
             NULL, NULL, 1, 'userSubLotRefNo',
             'Alphanumeric', NULL, NULL, NULL, NULL
            );


UPDATE itcm_imp_table_column_mapping itcm
   SET itcm.column_order = '2'
 WHERE itcm.file_type_id = 'IMPORT_PROVISIONAL_ASSAY_DETAILS'
   AND itcm.db_column_name = 'Element_name';


UPDATE itcm_imp_table_column_mapping itcm
   SET itcm.column_order = '3'
 WHERE itcm.db_column_name = 'Min_Value'
   AND itcm.file_type_id = 'IMPORT_PROVISIONAL_ASSAY_DETAILS';

UPDATE itcm_imp_table_column_mapping itcm
   SET itcm.column_order = '4'
 WHERE itcm.db_column_name = 'Max_Value'
   AND itcm.file_type_id = 'IMPORT_PROVISIONAL_ASSAY_DETAILS';

UPDATE itcm_imp_table_column_mapping itcm
   SET itcm.column_order = '5'
 WHERE itcm.db_column_name = 'Typical_Value'
   AND itcm.file_type_id = 'IMPORT_PROVISIONAL_ASSAY_DETAILS';

UPDATE itcm_imp_table_column_mapping itcm
   SET itcm.column_order = '6'
 WHERE itcm.db_column_name = 'Uom'
   AND itcm.file_type_id = 'IMPORT_PROVISIONAL_ASSAY_DETAILS';          
      

UPDATE ifm_import_file_master ifm
   SET ifm.column_model =
          '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},
{header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},
{header:"Stock Ref No.", width: 100, sortable: false,  dataIndex:"property1"},
{header:"Element Name", width: 100, sortable: false,  dataIndex:"property2"},
{header:"Min value", width: 100, sortable: false,  dataIndex:"property3"},
{header:"Max value", width: 100, sortable: false,  dataIndex:"property4"},
{header:"Provisional Assay Value", width: 100, sortable: false,  dataIndex:"property5"},
{header:"UoM", width: 100, sortable: false,  dataIndex:"property6"}]',
       ifm.record_model =
          '[{name: "lineNo", mapping: "lineNo"},
{name: "isBadRecord", mapping: "isBadRecord"},
{name: "property1", mapping: "property1"},
{name: "property2", mapping: "property2"},
{name: "property3", mapping: "property3"},
{name: "property4", mapping: "property4"},
{name: "property5", mapping: "property5"},
{name: "property6", mapping: "property6"}]',
       ifm.insert_query =
          'insert into IVR_IMPORT_VALID_RECORD(TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6) values(?,?,?,?,?,?,?,?,?)',
       ifm.select_query =
          'rn,count(*) over() TOTAL_NO_OF_RECORDS,TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6 from IVR_IMPORT_VALID_RECORD'
 WHERE ifm.file_type_id = 'IMPORT_PROVISIONAL_ASSAY_DETAILS';
 
 