Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('R10', 'Risk Listing', 9, 2, '/metals/loadListOfCreditLimitRisk.action?gridId=LOCLR', 
    NULL, 'R1', NULL, 'Risk', NULL);

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOCLR', 'List Of Credit Limit Risk', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},
   {"dataIndex":"counterPartyName","header":"Counter Party","id":1,"sortable":true,"width":150},
   {"dataIndex":"product","header":"Product","id":2,"sortable":true,"width":150},
   {"dataIndex":"organizationLevel","header":"Organization Level","id":3,"sortable":true,"width":150},
   {"dataIndex":"organization","header":"Organization","id":4,"sortable":true,"width":150},
   {"dataIndex":"contractType","header":"Contract Type","id":5,"sortable":true,"width":150},
   {"dataIndex":"creditExpLimit","header":"Credit Exposure Limit","id":6,"sortable":true,"width":150},
   {"dataIndex":"currentExp","header":"Current Exposure","id":7,"sortable":true,"width":150},
   {"dataIndex":"applicableFrom","header":"Applicable From","id":8,"sortable":true,"width":150},
   {"dataIndex":"applicableTo","header":"Applicable To","id":9,"sortable":true,"width":150}
   
   ]', NULL, NULL, 
    '[ 
          {name: "counterPartyName", mapping: "counterPartyName"},
          {name: "counterPartyId", mapping: "counterPartyId"},
          {name: "product", mapping: "product"},
          {name: "productId", mapping: "productId"},
          {name: "organizationLevel", mapping: "organizationLevel"},
          {name: "organizationLevelId", mapping: "organizationLevelId"},
          {name: "organization", mapping: "organization"},
          {name: "contractType", mapping: "contractType"},
          {name: "creditExpLimit", mapping: "creditExpLimit"},
          {name: "currentExp", mapping: "currentExp"},
          {name: "applicableFrom", mapping: "applicableFrom"},
          {name: "applicableTo", mapping: "applicableTo"}
                                
     ]', NULL, 'risk/ListOfCreditLimitRisk.jsp', '/private/js/risk/listOfCreditLimitRisk.js');

