Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOCI_1_3', 'LOCI', 'Special Settlement', 6, 2, 
    NULL, 'function(){}', NULL, 'LOCI_1', NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOCI_1_1_1', 'LOCI', 'Washout', 1, 3, 
    NULL, 'function(){loadWashOutContractItems();}', NULL, 'LOCI_1_3', NULL);



Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('WO_LOCI', 'List of Contract Items For Washout', '[ 
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
                                {name: "payInCurrency", mapping: "payInCurrency"},
                                {name: "payableContent", mapping: "payableContent"},
                                {name: "origin", mapping: "origin"}
                                
                               ]', NULL, NULL, 
    NULL, '/private/jsp/physical/itemoperation/ListOfContractItemPopupWO.jsp', '/private/jsp/physical/itemoperation/ListOfContractItemFilterForWO.jsp', '/private/js/physical/itemoperation/ListOfContractItemForWO.js');



CREATE TABLE SSWH_SPE_SETTLE_WASHOUT_HEADER 
(
  SSWH_ID                       VARCHAR2(15 CHAR) primary key,
  INTERNAL_ACTION_REF_NO        VARCHAR2(15 CHAR),
  SETTLEMENT_QTY                NUMBER(25,10),
  SETTLEMENT_QTY_UNIT_ID        VARCHAR2(15 CHAR),
  SETTLEMENT_DATE               DATE,
  PURCHASE_AMT                  NUMBER(25,10),
  SALE_AMT                      NUMBER(25,10),
  PAY_IN_CURR_ID                VARCHAR2(15 CHAR),
  REMARKS                       VARCHAR2(50 CHAR),
  IS_ACTIVE                     CHAR(1 CHAR)
)



CREATE TABLE SSWD_SPE_SETTLE_WASHOUT_DETAIL 
(
  SSWD_ID                        VARCHAR2(15 CHAR) primary key,
  SSWH_ID                        VARCHAR2(15 CHAR), 
  CONTRACT_TYPE                  CHAR(1 CHAR),
  INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(15 CHAR),
  CONTRACT_ITEM_REF_NO           VARCHAR2(30 CHAR),
  PRODUCT_ID                     VARCHAR2(15 CHAR),
  QUALITY_ID                     VARCHAR2(15 CHAR),
  PRICE                          NUMBER(25,10),
  PRICE_UNIT_ID                  VARCHAR2(15 CHAR),
  QTY                            NUMBER(25,10),
  QTY_UNIT_ID                    VARCHAR2(15 CHAR),
  IS_ACTIVE                      CHAR(1 CHAR),
  FOREIGN KEY (SSWH_ID) 
  REFERENCES SSWH_SPE_SETTLE_WASHOUT_HEADER (SSWH_ID)
)



CREATE SEQUENCE SEQ_SSWH
  START WITH 200
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;



CREATE SEQUENCE SEQ_SSWD
  START WITH 300
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


alter table SSWH_SPE_SETTLE_WASHOUT_HEADER add (INTERNAL_GMR_REF_NO VARCHAR2 (15))





