set define off;
delete from GMC_GRID_MENU_CONFIGURATION gmc where GMC.MENU_ID = 'LOAS-DAM';
update GMC_GRID_MENU_CONFIGURATION gmc set GMC.DISPLAY_SEQ_NO = '5' where GMC.MENU_ID = 'LOAS-UPA';
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('otherChargeUnit', 'Lot', 'N', 1);
update GMC_GRID_MENU_CONFIGURATION
set GMC_GRID_MENU_CONFIGURATION.LINK_CALLED='function(){loadMFTGmrDataforPriceAllocation();}'
where GMC_GRID_MENU_CONFIGURATION.MENU_ID='MTGMR_LIST_5';

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('GEPD_KEY_3', 'Pledge', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');


declare
fetchqry clob :='INSERT INTO gepd_d
            (internal_doc_ref_no, pledge_cp_name, pledge_person_in_charge,
             pledge_activity_date, product, quality, supplier_name,
             contract_ref_no, supplier_person_in_charge, supplier_ref_no,
             pledge_gmr_ref_no, element_name, corporate_name,
             our_person_in_charge, corporate_id, logo_path)
   SELECT ?, pledgephd.companyname AS pledge_cp_name,
          '' '' AS pledge_person_in_charge,
          TO_CHAR (gepd.activity_date, ''dd-Mon-yyyy'') AS pledge_activity_date,
          productquality.pname AS product, productquality.qname AS quality,
          supplierphd.companyname AS supplier_name,
          pcm.contract_ref_no AS contract_ref_no,
          (gab.firstname || '' '' || gab.lastname
          ) AS supplier_person_in_charge,
          ((SELECT sd.bl_no
             FROM sd_shipment_detail sd
            WHERE sd.internal_gmr_ref_no =
                                     gepd.pledge_input_gmr)
           || '' '' ||
           (SELECT wrd.warehouse_receipt_no
             FROM wrd_warehouse_receipt_detail wrd
            WHERE wrd.internal_gmr_ref_no =
                                     gepd.pledge_input_gmr))
                                                           AS supplier_ref_no,
          gmr.gmr_ref_no AS pledge_gmr_ref_no,
          aml.attribute_name AS element_name,
          akc.corporate_name AS corporate_name,
          (akgab.firstname || '' '' || akgab.lastname
          ) AS our_person_in_charge, pcm.corporate_id AS corporate_id,
          akl.corporate_image AS logo_path
     FROM gepd_gmr_element_pledge_detail gepd,
          gmr_goods_movement_record gmr,
          pcm_physical_contract_main pcm,
          aml_attribute_master_list aml,
          phd_profileheaderdetails supplierphd,
          phd_profileheaderdetails pledgephd,
          gab_globaladdressbook gab,
          gab_globaladdressbook akgab,
          ak_corporate akc,
          ak_corporate_logo akl,
          ak_corporate_user aku,
          (SELECT   stragg (qat.quality_name) AS qname,
                    pdm.product_desc AS pname,
                    grd.internal_gmr_ref_no AS int_gmr
               FROM qat_quality_attributes qat,
                    grd_goods_record_detail grd,
                    pdm_productmaster pdm
              WHERE grd.quality_id = qat.quality_id
                AND grd.product_id = pdm.product_id
                AND grd.is_deleted = ''N''
                AND grd.status = ''Active''
           GROUP BY grd.internal_gmr_ref_no, pdm.product_desc) productquality
    WHERE gepd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND productquality.int_gmr = gmr.internal_gmr_ref_no
      AND gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND gepd.element_id = aml.attribute_id
      AND pcm.cp_id = supplierphd.profileid
      AND gepd.pledge_cp_id = pledgephd.profileid
      AND pcm.corporate_id = akc.corporate_id
      AND akc.corporate_id = akl.corporate_id(+)
      AND pcm.cp_person_in_charge_id = gab.gabid(+)
      AND pcm.our_person_in_charge_id = aku.user_id(+)
      AND aku.gabid = akgab.gabid(+)
      AND gmr.is_deleted = ''N''
      AND gepd.is_active = ''Y''
      AND gepd.internal_gmr_ref_no = ? ';

begin

update DGM_DOCUMENT_GENERATION_MASTER set FETCH_QUERY = fetchqry where DGM_ID ='DGM-GEPD-1' and DOC_ID='pledgeTransfer';
end;

delete from rpc_rf_parameter_config rpc where rpc.parameter_id in ('RFP1053','RFP1000');
delete from rfp_rfc_field_parameters rfp where rfp.parameter_id in ('RFP1053','RFP1000');
commit;
SET DEFINE OFF;
Insert into RFP_RFC_FIELD_PARAMETERS
   (FIELD_ID, PARAMETER_DISPLAY_SEQ, PARAMETER_DESCRIPTION, PARAMETER_ID, TAG_ATTRIBUTE_NAME)
 Values
   ('GFF1011', 1, NULL, 'RFP1053', 'removeSelect');
Insert into RFP_RFC_FIELD_PARAMETERS
   (FIELD_ID, PARAMETER_DISPLAY_SEQ, PARAMETER_DESCRIPTION, PARAMETER_ID, TAG_ATTRIBUTE_NAME)
 Values
   ('GFF1001', 1, NULL, 'RFP1000', 'removeSelect');
 update IRC_INTERNAL_REF_NO_CONFIG irc set IRC.PREFIX = 'GPID' where IRC.INTERNAL_REF_NO_KEY = 'ASH_ASSAY_HEADER_PK';
Insert into SLV_STATIC_LIST_VALUE (VALUE_ID,VALUE_TEXT) values('Landing','Landing');
Insert into SLV_STATIC_LIST_VALUE (VALUE_ID,VALUE_TEXT) values('Sampling','Sampling');
Insert into SLV_STATIC_LIST_VALUE (VALUE_ID,VALUE_TEXT) values('Assay Finalization','Assay Finalization');

Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE,VALUE_ID,IS_DEFAULT,DISPLAY_ORDER) values('ReturnableDateActivity','Shipment','N','1');
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE,VALUE_ID,IS_DEFAULT,DISPLAY_ORDER) values('ReturnableDateActivity','Landing','N','2');
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE,VALUE_ID,IS_DEFAULT,DISPLAY_ORDER) values('ReturnableDateActivity','Sampling','N','3');
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE,VALUE_ID,IS_DEFAULT,DISPLAY_ORDER) values('ReturnableDateActivity','Assay Finalization','N','4');
update CDC_CORPORATE_DOC_CONFIG cdc set CDC.IS_ACTIVE='Y' where CDC.DOC_ID = 'airAdvice';
Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('MODIFY_ASSAY', 'Assay ', 'Modify Assay', 'Y', 'Modify Assay', 
    'N');

Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('MODIFY_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('ASYMRefNo', 'Asy Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOAS-MA', 'LOAD', 'Modify Assay', 6, 2, 
    'APP-PFL-N-160', 'function(){modifyAssay()}', NULL, 'LOAS', NULL);

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('LOIU', 'List Of Invoice Utility', 9, 3, '/metals/loadListOfInvoiceUtility.action?gridId=LOIU', 
    NULL, 'F2', 'APP-ACL-N1085', 'Finance', 'APP-PFL-N-187', 
    'N');



SET DEFINE OFF;
INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url,
             default_record_model_state,
             other_url, screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('LOIU', 'List of Invoice Utility',
             '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"utilityRefNo","header":"Utility Ref No.","id":1,"sortable":true,"width":150},{"dataIndex":"smelter","header":"Smelter","id":2,"sortable":true,"width":150},{"dataIndex":"status","header":"Status","id":3,"sortable":true,"width":150},{"dataIndex":"runBy","header":"Run By","id":4,"sortable":true,"width":150},{"dataIndex":"runDate","header":"Run Date & Time","id":5,"sortable":true,"width":150},{"dataIndex":"generateDoc","header":"Generate Doc","id":6,"sortable":true,"width":150}]',
             'Finance', '/metals/loadListOfInvoiceUtility.action',
             '[ 
                                   {name: "utilityRefNo", mapping: "utilityRefNo"},
                                   {name: "smelter", mapping: "smelter"},
                                {name: "status", mapping: "status"}, 
                                {name: "runBy", mapping: "runBy"}, 
                                {name: "runDate", mapping: "runDate"},
                                {name: "generateDoc", mapping: "generateDoc"},
                                {name: "iusId", mapping: "iusId"}
                               ] ',
             NULL, 'mining/invoice/listing/listOfInvoiceUtility.jsp',
             '/private/js/mining/invoice/listing/listOfInvoiceUtility.js'
            );




Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOIU_1', 'LOIU', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOIU_1_1', 'LOIU', 'Run Utility', 2, 2, 
    'APP-PFL-N-187', 'function(){loadForRunUtility();}', NULL, 'LOIU_1', 'APP-ACL-N1087');

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOIU_1_2', 'LOIU', 'Roll Back', 3, 2, 
    'APP-PFL-N-187', 'function(){rollback();}', NULL, 'LOIU_1', 'APP-ACL-N1087');



Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Successful', 'Successful');
   
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Rolled Back', 'Rolled Back');


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('InvoiceUtilityStatus', 'Successful', 'N', 1);
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('InvoiceUtilityStatus', 'Rolled Back', 'N', 2);

/************** 29th May**********************/

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('gmrRefNo', 'GMR Ref. No.');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('deliveryRefNo', 'Delivery Item Ref. No.');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('conItemRefNo', 'Contract Item Ref. No.');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('activityRefNo', 'Activity Ref. No.');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('CancelInvoice', 'Cancel Invoice');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('AdvancePaymentDebitCredit', 'Advance Payment Debit Credit Note');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Output Charge Invoice', 'Receive Material Invoice');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Commercial Fee', 'Commercial Fee Invoice');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('isFreeMetal', 'Free Metal Invoice');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('isPledge', 'Pledge Invoice');


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoicableItemSearch', 'conItemRefNo', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoicableItemSearch', 'gmrRefNo', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoicableItemSearch', 'deliveryRefNo', 'N', 4);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoicableItemSearch', 'activityRefNo', 'N', 5);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceType', 'CancelInvoice', 'N', 10);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceType', 'AdvancePaymentDebitCredit', 'N', 11);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceType', 'Output Charge Invoice', 'N', 12);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceType', 'Commercial Fee', 'N', 12);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceSubType', 'isFreeMetal', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceSubType', 'isPledge', 'N', 2);
 
Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_UTIL_INV', 'Invoice', 'Create Utility Invoice', 'N', 'Utility Invoice Created', 
    'N', NULL);

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('UtilInvRefNo', 'Utility Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  
axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');



Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_UTIL_INV', 'N', 'N', 'issueDate', 'N', 
    NULL, NULL, NULL, 'Y');

set define off;
delete from rpc_rf_parameter_config rpc where rpc.report_id='249';
delete from rfc_report_filter_config rfc where rfc.report_id='249';
delete from ref_reportexportformat ref where ref.report_id='249';
delete from amc_app_menu_configuration amc where amc.menu_id='RPT-D2495';
delete from rml_report_master_list rml where rml.report_id='249';
commit;

insert into amc_app_menu_configuration
   (menu_id, menu_display_name, display_seq_no, menu_level_no, link_called, 
    icon_class, menu_parent_id, acl_id, tab_id, feature_id, 
    is_deleted)
 values
   ('RPT-D2495', 'TC RC Distribution Report', 30, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=249&ReportName=TCRCDistributionReport.rpt&ExportFormat=HTML', 
    null, 'RPT-D21', null, 'Reports', null, 
    'N');
insert into rml_report_master_list
   (report_id, section_id, report_file_name, report_display_name, feature_id, 
    report_display_name_de, report_display_name_es, action_method, report_type, is_active)
 values
   ('249', '11', 'TCRCDistributionReport.rpt', 'TC RC Distribution Report', null, 
    null, null, 'populateFilter', 'ONLINE', 'Y');

insert into ref_reportexportformat
   (report_id, export_format, report_file_name)
 values
   ('249', 'EXCEL', 'TCRCDistributionReport_Excel.rpt');
 update RFC_REPORT_FILTER_CONFIG rfc set rfc.label = 'Arrival No.' where rfc.label_id = 'RFC237PHY07';
update RFC_REPORT_FILTER_CONFIG rfc set rfc.label= 'Contract Ref. No.' where rfc.label_id = 'RFC237PHY08';
update RFC_REPORT_FILTER_CONFIG rfc set rfc.label= 'GMR Ref. No.' where rfc.label_id = 'RFC237PHY09';
update RFC_REPORT_FILTER_CONFIG rfc set rfc.label = 'From Date'where rfc.label_id = 'RFC238PHY01';
update RFC_REPORT_FILTER_CONFIG rfc set rfc.label = 'To Date' where rfc.label_id = 'RFC238PHY02';
update RFC_REPORT_FILTER_CONFIG rfc set rfc.label = 'Contract Ref. No.' where rfc.label_id = 'RFC238PHY07';
update RFC_REPORT_FILTER_CONFIG rfc set rfc.label= 'Contract Item Ref. No.' where rfc.label_id = 'RFC238PHY08';
commit;

