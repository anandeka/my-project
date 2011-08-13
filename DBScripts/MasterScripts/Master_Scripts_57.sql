SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOCPL', 'List of CP Risk Limits', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"createdDate","header":"Created Date","id":1,"sortable":true,"width":120},{"dataIndex":"startDate","header":"Start Date","id":2,"sortable":true,"width":120},{"dataIndex":"endDate","header":"End Date","id":3,"sortable":true,"width":120},{"dataIndex":"productLabel","header":"Product","id":4,"sortable":true,"width":150},{"dataIndex":"orgLevelLabel","header":"Organizational Group","id":5,"sortable":true,"width":150},{"dataIndex":"orgLabel","header":"Organization","id":6,"sortable":true,"width":150},{"dataIndex":"limitLabel","header":"CP Name","id":7,"sortable":true,"width":150},{"dataIndex":"netExposureLimit","header":"Limit","id":8,"sortable":true,"width":150},{"dataIndex":"contractType","header":"Contract Type","id":9,"sortable":true,"width":150},{"dataIndex":"qtyExposure","header":"Quantity Exposure Limit","id":10,"sortable":true,"width":150},{"dataIndex":"valueExposure","header":"Value Exposure Limit","id":11,"sortable":true,"width":150},{"dataIndex":"mtmExposure","header":"M2M Exposure Limit","id":12,"sortable":true,"width":150},{"dataIndex":"createdDate","header":"Total M2M Exposure","id":13,"sortable":true,"width":150},{"dataIndex":"currentExposure","header":"Current Exposure Limit","id":14,"sortable":true,"width":150},{"dataIndex":"netExposureLimit","header":"Net Exposure Limit","id":15,"sortable":true,"width":150},{"dataIndex":"isAggregateHigherLevel","header":"Aggregate at Higher Limit","id":16,"sortable":true,"width":150},{"dataIndex":"standbyLcPosted","header":"Stand by L/C Limit","id":17,"sortable":true,"width":150},{"dataIndex":"uninsureRiskPer","header":"Uninsured Risk %","id":18,"sortable":true,"width":150},{"dataIndex":"marginPosted","header":"Margin Posted","id":19,"sortable":true,"width":150},{"dataIndex":"createdBy","header":"Created By","id":20,"sortable":true,"width":150}]', 'Risk', '/energyCRC/commonListing.do?method=getCommonListingPage&gridId=LOCPL', 
    '[ {name : "rleId",mapping : "rleId"}, {name : "startDate",mapping : "startDate"}, {name : "endDate",mapping : "endDate"}, {name : "productLabel",mapping : "productLabel"}, {name : "orgLevelLabel",mapping : "orgLevelLabel"}, {name : "orgLabel",mapping : "orgLabel"}, {name : "limitLabel",mapping : "limitLabel"},{name : "netExposureLimit",mapping : "netExposureLimit"},{name : "contractType",mapping : "contractType"},{name : "qtyExposure",mapping : "qtyExposure"},{name : "valueExposure",mapping : "valueExposure"},{name : "mtmExposure",mapping : "mtmExposure"},{name : "createdDate",mapping : "createdDate"},{name : "currentExposure",mapping : "currentExposure"},{name : "netExposureLimit",mapping : "netExposureLimit"},{name : "isAggregateHigherLevel",mapping : "isAggregateHigherLevel"},{name : "standbyLcPosted",mapping : "standbyLcPosted"},{name : "uninsureRiskPer",mapping : "uninsureRiskPer"},{name : "marginPosted",mapping : "marginPosted"},{name:"createdBy",mapping : "createdBy"}  ]', NULL, '/private/jsp/risk/setup/limits/ListofRiskLimits.jsp', '/energyCRC/private/js/risk/setup/limits/listofCPLimits.js');

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOCYL', 'List of Country Risk Limts', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"createdDate","header":"Created Date","id":1,"sortable":true,"width":120},{"dataIndex":"startDate","header":"Start Date","id":2,"sortable":true,"width":120},{"dataIndex":"endDate","header":"End Date","id":3,"sortable":true,"width":120},{"dataIndex":"productLabel","header":"Product","id":4,"sortable":true,"width":150},{"dataIndex":"orgLevelLabel","header":"Organizational Group","id":5,"sortable":true,"width":150},{"dataIndex":"orgLabel","header":"Organization","id":6,"sortable":true,"width":150},{"dataIndex":"limitLabel","header":"Country","id":7,"sortable":true,"width":150},{"dataIndex":"contractType","header":"Contract Type","id":8,"sortable":true,"width":150},{"dataIndex":"qtyExposure","header":"Quantity Exposure Limit","id":9,"sortable":true,"width":150},{"dataIndex":"valueExposure","header":"Value Exposure Limit","id":10,"sortable":true,"width":150},{"dataIndex":"currentExposure","header":"Current Exposure Limit","id":11,"sortable":true,"width":150},{"dataIndex":"isAggregateHigherLevel","header":"Aggregate at Higher Limit","id":12,"sortable":true,"width":150},{"dataIndex":"createdBy","header":"Created By","id":13,"sortable":true,"width":150}]', 'Risk', '/energyCRC/commonListing.do?method=getCommonListingPage&gridId=LOCYL', 
    '[  {name : "rleId",mapping : "rleId"}, {name : "startDate",mapping : "startDate"}, {name : "endDate",mapping : "endDate"}, {name : "productLabel",mapping : "productLabel"}, {name : "orgLevelLabel",mapping : "orgLevelLabel"}, {name : "orgLabel",mapping : "orgLabel"}, {name : "limitLabel",mapping : "limitLabel"},{name : "contractType",mapping : "contractType"},{name : "qtyExposure",mapping : "qtyExposure"},{name : "valueExposure",mapping : "valueExposure"},{name : "createdDate",mapping : "createdDate"},{name : "currentExposure",mapping : "currentExposure"}, {name : "isAggregateHigherLevel",mapping : "isAggregateHigherLevel"},{name:"createdBy",mapping : "createdBy"}  ]', NULL, '/private/jsp/risk/setup/limits/ListofRiskLimits.jsp', '/energyCRC/private/js/risk/setup/limits/listofCountryLimits.js');

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOTRDL', 'List of Trader Risk Limts', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"createdDate","header":"Created Date","id":1,"sortable":true,"width":120},{"dataIndex":"startDate","header":"Start Date","id":2,"sortable":true,"width":120},{"dataIndex":"endDate","header":"End Date","id":3,"sortable":true,"width":120},{"dataIndex":"productLabel","header":"Product","id":4,"sortable":true,"width":150},{"dataIndex":"orgLevelLabel","header":"Organizational Group","id":5,"sortable":true,"width":150},{"dataIndex":"orgLabel","header":"Organization","id":6,"sortable":true,"width":150},{"dataIndex":"limitLabel","header":"Trader Name","id":7,"sortable":true,"width":150},{"dataIndex":"contractType","header":"Contract Type","id":8,"sortable":true,"width":150},{"dataIndex":"qtyExposure","header":"Quantity Exposure Limit","id":9,"sortable":true,"width":150},{"dataIndex":"valueExposure","header":"Value Exposure Limit","id":10,"sortable":true,"width":150},{"dataIndex":"mtmExposure","header":"M2M Exposure","id":11,"sortable":true,"width":150},{"dataIndex":"isAggregateHigherLevel","header":"Aggregate at Higher Limit","id":12,"sortable":true,"width":150},{"dataIndex":"createdBy","header":"Created By","id":13,"sortable":true,"width":150}]', 'Risk', '/energyCRC/commonListing.do?method=getCommonListingPage&gridId=LOTRDL', 
    '[ {name : "rleId",mapping : "rleId"}, {name : "startDate",mapping : "startDate"}, {name : "endDate",mapping : "endDate"}, {name : "productLabel",mapping : "productLabel"}, {name : "orgLevelLabel",mapping : "orgLevelLabel"}, {name : "orgLabel",mapping : "orgLabel"}, {name : "limitLabel",mapping : "limitLabel"},{name : "contractType",mapping : "contractType"},{name : "qtyExposure",mapping : "qtyExposure"},{name : "mtmExposure",mapping : "mtmExposure"},{name : "valueExposure",mapping : "valueExposure"},{name : "createdDate",mapping : "createdDate"},{name : "currentExposure",mapping : "currentExposure"}, {name : "isAggregateHigherLevel",mapping : "isAggregateHigherLevel"},{name:"createdBy",mapping : "createdBy"}   ]', NULL, '/private/jsp/risk/setup/limits/ListofRiskLimits.jsp', '/energyCRC/private/js/risk/setup/limits/listofTraderLimits.js');

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOBRKL', 'List of Broker Risk Limts', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"createdDate","header":"Created Date","id":1,"sortable":true,"width":120},{"dataIndex":"startDate","header":"Start Date","id":2,"sortable":true,"width":120},{"dataIndex":"endDate","header":"End Date","id":3,"sortable":true,"width":120},{"dataIndex":"brokerLabel","header":"Broker Name","id":4,"sortable":true,"width":150},{"dataIndex":"brokerAccountLable","header":"Broker Account","id":5,"sortable":true,"width":150},{"dataIndex":"exchangeLabel","header":"Exchange","id":6,"sortable":true,"width":150},{"dataIndex":"productLabel","header":"Product Name","id":7,"sortable":true,"width":150},{"dataIndex":"initialMarginLimit","header":"Initial Margin","id":8,"sortable":true,"width":150},{"dataIndex":"variationMarginLimit","header":"Variation Margin","id":9,"sortable":true,"width":150},{"dataIndex":"createdBy","header":"Created By","id":10,"sortable":true,"width":150}]', 'Risk', '/energyCRC/commonListing.do?method=getCommonListingPage&gridId=LOBRKL', 
    '[  {name : "bleId",mapping : "bleId"}, {name : "startDate",mapping : "startDate"}, {name : "endDate",mapping : "endDate"}, {name : "productLabel",mapping : "productLabel"}, {name : "brokerLabel",mapping : "brokerLabel"}, {name : "brokerAccountLable",mapping : "brokerAccountLable"}, {name : "exchangeLabel",mapping : "exchangeLabel"},{name : "initialMarginLimit",mapping : "initialMarginLimit"},{name : "variationMarginLimit",mapping : "variationMarginLimit"},{name : "createdBy",mapping : "createdBy"},{name : "createdDate",mapping : "createdDate"},{name:"createdBy",mapping : "createdBy"} ]', NULL, '/private/jsp/risk/setup/limits/ListofRiskLimits.jsp', '/energyCRC/private/js/risk/setup/limits/listofBrokerLimits.js');

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOTS', 'List of Trade Set', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"tradeSetName","header":"Trade Set","id":1,"sortable":true,"width":120},{"dataIndex":"portfolioName","header":"PortFolio Name","id":2,"sortable":true,"width":120},{"dataIndex":"tradeSetDesc","header":"Description","id":3,"sortable":true,"width":150},{"dataIndex":"status","header":"Status","id":4,"sortable":true,"width":150},{"dataIndex":"createdBy","header":"Created By","id":5,"sortable":true,"width":150},{"dataIndex":"createdDate","header":"Created Date","id":6,"sortable":true,"width":150},{"dataIndex":"lastUpdatedBy","header":"Last Updated By","id":7,"sortable":true,"width":150},{"dataIndex":"lastUpdatedDate","header":"Last Updated Date","id":8,"sortable":true,"width":150}]', 'Risk', '/energyCRC/commonListing.do?method=getCommonListingPage&gridId=LOTS', 
    '[{
                name : "vtmId",
                mapping : "vtmId"
            }, {
                name : "tradeSetName",
                mapping : "tradeSetName"
            }, {
                name : "tradeSetDesc",
                mapping : "tradeSetDesc"
            },{
                name : "portfolioId",
                mapping : "portfolioId"
            }, {
                name : "portfolioName",
                mapping : "portfolioName"
            }, {
                name : "varId",
                mapping : "varId"
            }, {
                name : "versionNo",
                mapping : "versionNo"
            }, {
                name : "status",
                mapping : "status"
            }, {
                name : "createdBy",
                mapping : "createdBy"
            }, {
                name : "createdDate",
                mapping : "createdDate"
            }

    ]', NULL, '/private/jsp/risk/fea/TradeSet/ListofTradeSets.jsp', '/energyCRC/private/js/risk/fea/TradeSet/listofTradeSets.js');

SET DEFINE OFF;
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOTS-OP', 'LOTS', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOTS-DL', 'LOTS', 'Delete Trade Set', 3, 2, 
    NULL, 'function(){deleteTradeSet();}', NULL, 'LOTS-OP', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOTS-VT', 'LOTS', 'View Trades', 1, 2, 
    NULL, 'function(){callViewTrades();}', NULL, 'LOTS-OP', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOTS-UP', 'LOTS', 'Refresh Trade Set', 2, 2, 
    NULL, 'function(){updateTradeSet();}', NULL, 'LOTS-OP', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
    (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
Values
    ('CPLOP', 'LOCPL', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('CPL-MOD', 'LOCPL', 'Modify CP Risk Limit', 2, 2, 
    NULL, 'function(){modifyLimit();}', NULL, 'CPLOP', NULL);

 
 Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('CPLvsAct', 'LOCPL', 'Monitor Set Limit Vs Actual Limit', 4, 2, 
    NULL, 'function(){compareLimit();}', NULL, 'CPLOP', NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('CPL-CRE', 'LOCPL', 'Create CP Risk Limit', 1, 2, 
    NULL, 'function(){CreateLimit();}', NULL, 'CPLOP', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('CPL-DEL', 'LOCPL', 'Delete CP Risk Limit', 3, 2, 
    NULL, 'function(){deleteLimit();}', NULL, 'CPLOP', NULL);
    
   Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TRDLOP', 'LOTRDL', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TRDLvsAct', 'LOTRDL', 'Monitor Set Limit Vs Actual Limit', 4, 2, 
    NULL, 'function(){compareLimit();}', NULL, 'TRDLOP', NULL);
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('CYLOP', 'LOCYL', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('CYL-CRE', 'LOCYL', 'Create Country Risk Limit', 1, 2, 
    NULL, 'function(){CreateLimit();}', NULL, 'CYLOP', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('CYL-DEL', 'LOCYL', 'Delete Country Risk Limit', 3, 2, 
    NULL, 'function(){deleteLimit();}', NULL, 'CYLOP', NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TRDL-CRE', 'LOTRDL', 'Create Trader Risk Limit', 1, 2, 
    NULL, 'function(){CreateLimit();}', NULL, 'TRDLOP', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TRDL-DEL', 'LOTRDL', 'Delete Trader Risk Limit', 3, 2, 
    NULL, 'function(){deleteLimit();}', NULL, 'TRDLOP', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('CYL-MOD', 'LOCYL', 'Modify Country Risk Limit', 2, 2, 
    NULL, 'function(){modifyLimit();}', NULL, 'CYLOP', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TRDL-MOD', 'LOTRDL', 'Modify Trader Risk Limit', 2, 2, 
    NULL, 'function(){modifyLimit();}', NULL, 'TRDLOP', NULL);
SET DEFINE OFF;
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BRKLOP', 'LOBRKL', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BRKL-CRE', 'LOBRKL', 'Create Broker Risk Limit', 1, 2, 
    NULL, 'function(){CreateLimit();}', NULL, 'BRKLOP', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BRKL-DEL', 'LOBRKL', 'Delete Broker Risk Limit', 3, 2, 
    NULL, 'function(){deleteLimit();}', NULL, 'BRKLOP', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BRKL-MOD', 'LOBRKL', 'Modify Broker Risk Limit', 2, 2, 
    NULL, 'function(){modifyLimit();}', NULL, 'BRKLOP', NULL);

commit;