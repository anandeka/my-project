Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_PC', NULL, NULL, NULL, 'Y', 
    NULL, NULL, NULL, 'Y');


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('ContractRefNo', 'Contract Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_SC', NULL, NULL, NULL, 'Y', 
    NULL, NULL, NULL, 'Y');

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('SalesRefNo', 'Sales Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('CREATE_TC', 'Tolling', 'Create Tolling Contract', 'Y', 'Tolling Contract Created', 
    'N');

Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_TC', NULL, NULL, NULL, 'Y', 
    NULL, NULL, NULL, 'Y');

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('TollingRefNo', 'Tolling Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');


update AMC_APP_MENU_CONFIGURATION set DISPLAY_SEQ_NO = '7' where MENU_ID ='CDC-M8';
update AMC_APP_MENU_CONFIGURATION set DISPLAY_SEQ_NO = '8' where MENU_ID ='CDC-M9';

SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M3', 'List of Tolling Contracts', 3, 2, '/metals/loadTollingContractList.action?method=loadTollingContractList&gridId=TOLLING_LOC', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);
 

SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M4', 'List of Tolling Contract Items', 4, 2, '/metals/loadTollingContractItemList.action?method=loadTollingContractItemList&gridId=TOLLING_LOCI', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);


SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M5', 'New Tolling Contract', 5, 2, '/metals/loadTollingContractForCreation.action?method=loadTollingContractForCreation&tabId=general&productGroupType=CONCENTRATES&actionType=current&moduleId=tolling', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);



SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('TOLLING_LOC', 'List of Tolling Contracts', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"contractRefNo","header":"Contract No.","id":1,"sortable":true,"width":150},{"dataIndex":"issueDate","header":"Contract Date","id":2,"sortable":true,"width":150},{"dataIndex":"cpName","header":"Tolling Party","id":3,"sortable":true,"width":150},{"dataIndex":"assetclass","header":"Input Product","id":4,"sortable":true,"width":150},{"dataIndex":"noOfItems","header":"Contract Items","id":6,"sortable":true,"width":150},{"dataIndex":"contractqty","header":"Input Quanity","id":5,"sortable":true,"width":150},{"dataIndex":"partnershipType","header":"Execution Type","id":8,"sortable":true,"width":150},{"dataIndex":"org","header":"Org.","id":7,"sortable":true,"width":150},{"dataIndex":"strategy","header":"Strategy","id":12,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":11,"sortable":true,"width":150},{"dataIndex":"executedQty","header":"Executed Quantity","id":9,"sortable":true,"width":150},{"dataIndex":"payInCurrency","header":"Pay-In Currency","id":10,"sortable":true,"width":150}]', NULL, NULL, 
    '[ {
		name : "issueDate",
		mapping : "issueDate"
	}, {
		name : "partnershipType",
		mapping : "partnershipType"
	}, {
		name : "internalContractRefNo",
		mapping : "internalContractRefNo"
	}, {
		name : "contractRefNo",
		mapping : "contractRefNo"
	}, {
		name : "cpName",
		mapping : "cpName"
	}, {
		name : "contractType",
		mapping : "contractType"
	}, {
		name : "intracompany",
		mapping : "intracompany"
	}, {
		name : "assetclass",
		mapping : "assetclass"
	}, {
		name : "productGroupType",
		mapping : "productGroupType"
	}, {
		name : "noOfItems",
		mapping : "noOfItems"
	}, {
		name : "contractqty",
		mapping : "contractqty"
	}, {
		name : "jvcpname",
		mapping : "jvcpname"
	}, {
		name : "internalContractRefNo",
		mapping : "internalContractRefNo"
	}, {
		name : "contractStatus",
		mapping : "contractStatus"
	}, {
		name : "org",
		mapping : "org"
	}, {
		name : "strategy",
		mapping : "strategy"
	}, {
		name : "trader",
		mapping : "trader"
	}, {
		name : "executedQty",
		mapping : "executedQty"
	}, {
		name : "allocatedQty",
		mapping : "allocatedQty"
	}, {
		name : "titleTransferQty",
		mapping : "titleTransferQty"
	}, {
		name : "provInvoiceQty",
		mapping : "provInvoiceQty"
	}, {
		name : "finalInvoiceQty",
		mapping : "finalInvoiceQty"
	}, {
		name : "payInCurrency",
		mapping : "payInCurrency"
	} ]', NULL, 'tolling/physical/listing/listOfTollingContracts.jsp', '/private/js/tolling/physical/listing/listOfTollingContracts.js');

COMMIT;


SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('TOLLING_LOCI', 'List of Tolling Contract Items', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"contractNo","header":"Contract Ref. No","id":1,"sortable":true,"width":150},{"dataIndex":"itemRefNo","header":"Contract Item Ref. No.","id":2,"sortable":true,"width":150},{"dataIndex":"partnershipType","header":"Contract Type","id":3,"sortable":true,"width":150},{"dataIndex":"strategy","header":"Strategy","id":4,"sortable":true,"width":150},{"dataIndex":"bookProfitCenter","header":"Book/Profit Center","id":5,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":6,"sortable":true,"width":150},{"dataIndex":"counterParty","header":"CP Name","id":7,"sortable":true,"width":150},{"dataIndex":"product","header":"Product","id":8,"sortable":true,"width":150},{"dataIndex":"quality","header":"Quality","id":9,"sortable":true,"width":150},{"dataIndex":"quotaMonth","header":"Quota Period","id":10,"sortable":true,"width":150},{"dataIndex":"incotermLocation","header":"INCO Term & Location","id":11,"sortable":true,"width":150},{"dataIndex":"qty","header":"Item Quantity","id":12,"sortable":true,"width":150},{"dataIndex":"executedQty","header":"Executed Quantity","id":13,"sortable":true,"width":150}]', NULL, NULL, 
    '[ 
                                {name: "contractNo", mapping: "contractNo"}, 
                                {name: "contractType", mapping: "contractType"}, 
                                {name: "counterParty", mapping: "counterParty"},
                                {name: "tradeType", mapping: "tradeType"},
                                {name: "allocationStatus", mapping: "allocationStatus"},
                                {name: "itemStatus", mapping: "itemStatus"},
                                {name: "deliveryRefNo", mapping: "deliveryRefNo"},
                                {name: "itemRefNo", mapping: "itemRefNo"},
                                {name: "internalContractItemRefNo", mapping: "internalContractItemRefNo"},
                                {name: "internalContractRefNo", mapping: "internalContractRefNo"},
                                {name: "product", mapping: "product"},
                                {name: "quality", mapping: "quality"},
                                {name: "attributes", mapping: "attributes"},
                                {name: "issueDate", mapping: "issueDate"},
                                {name: "quotaMonth", mapping: "quotaMonth"},
                                {name: "location", mapping: "location"},
                                {name: "traxysOrg", mapping: "traxysOrg"},
                                {name: "incotermLocation", mapping: "incotermLocation"},
                                {name: "pricing", mapping: "pricing"},
                                {name: "qp", mapping: "qp"},
                                {name: "qty", mapping: "qty"},
                                {name: "openQty", mapping: "openQty"},
                                {name: "qtyBasis", mapping: "qtyBasis"},
                                {name: "allocatedQty", mapping: "allocatedQty"},
                                {name: "partnershipType", mapping: "partnershipType"},
                                {name: "incoterm", mapping: "incoterm"},
                                {name: "pcdiId", mapping: "pcdiId"},
                                {name: "strategy", mapping: "strategy"},
								{name: "bookProfitCenter", mapping: "bookProfitCenter"},
								{name: "trader", mapping: "trader"},
								{name: "pricing", mapping: "pricing"},
								{name: "executedQty", mapping: "executedQty"},
								{name: "titleTransferQty", mapping: "titleTransferQty"},
								{name: "provInvoicedQty", mapping: "provInvoicedQty"},
								{name: "finalInvoicedQty", mapping: "finalInvoicedQty"},
								{name: "payInCurrency", mapping: "payInCurrency"}
                               ]', NULL, 'tolling/physical/listing/listOfTollingContractItems.jsp', '/private/js/tolling/physical/listing/listOfTollingContractItems.js');
COMMIT;


  SET DEFINE OFF;
Insert into BRM_BUSINESS_ROLE_MASTER
   (ROLE_TYPE_CODE, ROLE_TYPE_NAME, SORT_ORDER, IS_ACTIVE)
 Values
   ('UMPIRES', 'Umpires', 15, 'Y');
COMMIT;


   update AMC_APP_MENU_CONFIGURATION set LINK_CALLED='/metals/loadContractForCreation.action?tabId=general&contractType=P&productGroupType=CONCENTRATES&actionType=current&moduleId=physical' where MENU_ID='P23';

update AMC_APP_MENU_CONFIGURATION set LINK_CALLED='/metals/loadContractForCreation.action?tabId=general&contractType=S&productGroupType=CONCENTRATES&actionType=current&moduleId=physical' where MENU_ID='P33';

update AMC_APP_MENU_CONFIGURATION set LINK_CALLED='/metals/loadContractForCreation.action?tabId=general&contractType=S&productGroupType=BASEMETAL&actionType=current&moduleId=physical' where MENU_ID='P32';

update AMC_APP_MENU_CONFIGURATION set LINK_CALLED='/metals/loadContractForCreation.action?tabId=general&contractType=P&productGroupType=BASEMETAL&actionType=current&moduleId=physical' where MENU_ID='P22';

update AMC_APP_MENU_CONFIGURATION set LINK_CALLED='/metals/loadTollingContractForCreation.action?method=loadTollingContractForCreation&tabId=general&productGroupType=CONCENTRATES&actionType=current&moduleId=tolling' where MENU_ID='TOL-M5';


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TOLL_1', 'TOLLING_LOCI', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MFTOLL_2', 'TOLLING_LOCI', 'Mark For Tolling', 1, 2, 
    NULL, 'function(){loadMarkForTolling();}', NULL, 'TOLL_1', NULL);
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('ROTOLL_2', 'TOLLING_LOCI', 'Record Output ', 2, 2, 
    NULL, 'function(){loadRecordOutputTolling();}', NULL, 'TOLL_1', NULL);



Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Tolling', 'Tolling');

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('Process', 'Tolling', 'Y', 1);


 SET DEFINE OFF;
Insert into URM_UMPIRE_RULE_MASTER
   (URM_ID, RULE_DESC, RULE_FORMULA, IS_ACTIVE, VERSION, 
    RULE_NAME)
 Values
   ('1', 'RULE-1', '<?xml version="1.0" encoding="UTF-8"?>
<rule-execution-set>
   <name>RuleExecutionSet1</name>
   <description>Rule Execution Set</description>

   <synonymn name="assay" class="com.ekaplus.dao.assaying.UmpireAssay" />

    <!--
      If the credit limit of the customer is greater than the amount of the
      invoice and the status of the invoice is "unpaid" then
      decrement the credit limit with the amount of the invoice and
      set the status of the invoice to "paid".
    -->
    
   <rule name="Rule1" description="Assay Umpiring rule" >
        <if leftTerm="assay.getCpAssay" op="&lt;" rightTerm="assay.getSelfAssay" />
        <if leftTerm="assay.getCpAssay" op="&gt;" rightTerm="assay.getUmpiringAssay" />
        <then method="assay.setUmpireAssay" arg1="cp1" />
   </rule>
   <rule name="Rule2" description="Assay Umpiring rule" >
        <if leftTerm="assay.getCpAssay" op="&lt;" rightTerm="assay.getSelfAssay" />
        <if leftTerm="assay.getSelfAssay" op="&lt;" rightTerm="assay.getUmpiringAssay" />
        <then method="assay.setUmpireAssay" arg1="self1" />
   </rule>
   <rule name="Rule3" description="Assay Umpiring rule" >
        <if leftTerm="assay.getCpAssay" op="&lt;" rightTerm="assay.getSelfAssay" />
        <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay" />
        <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay" />
        <then method="assay.setUmpireAssay" arg1="umpire1" />
   </rule>
   <rule name="Rule4" description="Assay Umpiring rule" >
        <if leftTerm="assay.getSelfAssay" op="&lt;" rightTerm="assay.getCpAssay" />
        <if leftTerm="assay.getSelfAssay" op="&gt;" rightTerm="assay.getUmpiringAssay" />
        <then method="assay.setUmpireAssay" arg1="self1" />
   </rule>
   <rule name="Rule5" description="Assay Umpiring rule" >
        <if leftTerm="assay.getSelfAssay" op="&lt;" rightTerm="assay.getCpAssay" />
        <if leftTerm="assay.getCpAssay" op="&lt;" rightTerm="assay.getUmpiringAssay" />
        <then method="assay.setUmpireAssay" arg1="cp1" />
   </rule>
   <rule name="Rule7" description="Assay Umpiring rule" >
        <if leftTerm="assay.getSelfAssay" op="=" rightTerm="assay.getUmpiringAssay" />
        <then method="assay.setUmpireAssay" arg1="umpire1" />
   </rule>  
   <rule name="Rule8" description="Assay Umpiring rule" >
          <if leftTerm="assay.getCpAssay" op="=" rightTerm="assay.getUmpiringAssay" />
          <then method="assay.setUmpireAssay" arg1="umpire1" />
   </rule> 
</rule-execution-set>', 'Y', 0, 
    'RULE-1');
COMMIT;

