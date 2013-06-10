---Dashboard script for tata alerts and remainters
 Delete from AMC_APP_MENU_CONFIGURATION t Where t.MENU_ID = 'IEKA-19';

 Delete from PRTLMAP_PORTAL_MAPPING t Where t.PORTAL_ID = 'PRTLM-3';

 Delete from PRTLM_PORTAL_MASTER t Where t.PORTAL_ID = 'PRTLM-3';

 Delete from IGVC_IEKA_GRAPHICAL_VIEW_COL t
 Where t.GRAPHICAL_VIEW_ID in
       ('IGVD-13', 'IGVD-14', 'IGVD-15', 'IGVD-16', 'IGVD-17');

 Delete from IGVD_IEKA_GRAPHICAL_VIEW_DET t
 Where t.PORTLET_ID in
       ('PRLTM-13', 'PRLTM-14', 'PRLTM-15', 'PRLTM-16', 'PRLTM-17');

 Delete from PRLTM_PORTLET_MASTER t
 Where t.PORTLET_ID in
       ('PRLTM-13', 'PRLTM-14', 'PRLTM-15', 'PRLTM-16', 'PRLTM-17');

 Delete From IVCD_IEKA_VIEW_COLUMN_DEF t
 Where t.VIEW_DEF_ID in 
       ('IVD-13', 'IVD-14', 'IVD-15', 'IVD-16', 'IVD-17');

 Delete from IVD_IEKA_VIEW_DEF t
 Where t.VIEW_DEF_ID in 
       ('IVD-13', 'IVD-14', 'IVD-15', 'IVD-16', 'IVD-17');
 COMMIT;




SET DEFINE OFF;
Insert into IVD_IEKA_VIEW_DEF
   (VIEW_DEF_ID, IEKA_VIEW_NAME, DATABASE_VIEW_NAME, STANDARD_FILTER, CONFIG)
 Values
   ('IVD-15', 'Prompt dates in next 7 days', 'V_BI_DASH_DER_PROMPT', '{Type:''C'',Col:''CORPORATE_ID''}', '{"orderByColumn":"","orderByType":""}');
Insert into IVD_IEKA_VIEW_DEF
   (VIEW_DEF_ID, IEKA_VIEW_NAME, DATABASE_VIEW_NAME, STANDARD_FILTER, CONFIG)
 Values
   ('IVD-16', 'Warehouse stocks', 'V_BI_DASH_PHY_WHS_STOCK', '{Type:''C'',Col:''CORPORATE_ID''}', '{"orderByColumn":"","orderByType":""}');
Insert into IVD_IEKA_VIEW_DEF
   (VIEW_DEF_ID, IEKA_VIEW_NAME, DATABASE_VIEW_NAME, STANDARD_FILTER, CONFIG)
 Values
   ('IVD-17', 'Delivered stocks', 'V_BI_DASH_PHY_DEL_STOCK', '{Type:''C'',Col:''CORPORATE_ID''}', '{"orderByColumn":"","orderByType":""}');
Insert into IVD_IEKA_VIEW_DEF
   (VIEW_DEF_ID, IEKA_VIEW_NAME, DATABASE_VIEW_NAME, STANDARD_FILTER, CONFIG)
 Values
   ('IVD-13', 'Broker Margin', 'V_BI_DASH_PHY_BRK_MARGIN', '{Type:''C'',Col:''CORPORATE_ID''}', '{"orderByColumn":"","orderByType":""}');
Insert into IVD_IEKA_VIEW_DEF
   (VIEW_DEF_ID, IEKA_VIEW_NAME, DATABASE_VIEW_NAME, STANDARD_FILTER, CONFIG)
 Values
   ('IVD-14', 'Price fixation in next 7 days', 'V_BI_DASH_PHY_PFC', '{Type:''C'',Col:''CORPORATE_ID''}', '{"orderByColumn":"","orderByType":""}');


Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-95', 'IVD-14', 'CONTRACT_REF_NO', 'STANDARD', '{columnType:"string", label:"Contract Ref No.",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Contract Ref No"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-96', 'IVD-14', 'DEL_ITEM_REF_NO', 'STANDARD', '{columnType:"string", label:"Delivery Item Ref No.",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Delivery Item Ref No"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-97', 'IVD-14', 'PRODUCT', 'STANDARD', '{columnType:"string", label:"Product",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Product"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-98', 'IVD-14', 'QTY_TO_BE_PRICED', 'STANDARD', '{columnType:"string", label:"Quantity to be Priced",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Quantity to be Priced"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-99', 'IVD-14', 'UOM', 'STANDARD', '{columnType:"string", label:"UOM",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"UOM"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-100', 'IVD-14', 'PRICE_DESCRIPTION', 'STANDARD', '{columnType:"string", label:"Pricing Method",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Pricing Method"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-101', 'IVD-14', 'QP_START_DATE', 'STANDARD', '{columnType:"string", label:"QP Start Date",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"QP Start Date"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-116', 'IVD-16', 'WAREHOUSE', 'STANDARD', '{columnType:"string", label:"Warehouse Shed",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Warehouse Shed"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-117', 'IVD-16', 'LOCATION', 'STANDARD', '{columnType:"string", label:"Location",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Location"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-118', 'IVD-16', 'STRATEGY_NAME', 'STANDARD', '{columnType:"string", label:"Strategy",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Strategy"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-119', 'IVD-16', 'CURRENT_QTY', 'STANDARD', '{columnType:"string", label:"Current Qty (MT)",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Current Qty (MT)"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-120', 'IVD-17', 'INTERNAL_STOCK_REF_NO', 'STANDARD', '{columnType:"string", label:"Stock Ref No.",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Stock Ref No"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-121', 'IVD-17', 'GMR_REF_NO', 'STANDARD', '{columnType:"string", label:"GMR Ref No",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"GMR Ref No"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-122', 'IVD-17', 'CONTRACT_ITEM_REF_NO', 'STANDARD', '{columnType:"string", label:"Contract Item Ref No.",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Contract Item Ref No"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-123', 'IVD-17', 'CP_NAME', 'STANDARD', '{columnType:"string", label:"CP Name",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"CP Name"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-124', 'IVD-17', 'PRODUCT', 'STANDARD', '{columnType:"string", label:"Product",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Product"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-125', 'IVD-17', 'QUALITY_NAME', 'STANDARD', '{columnType:"string", label:"Quality",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Quality"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-93', 'IVD-13', 'BROKER_NAME', 'STANDARD', '{columnType:"string", label:"Broker",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Broker"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-94', 'IVD-13', 'EXCHANGE_PRODUCT', 'STANDARD', '{columnType:"string", label:"Product",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Product"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-103', 'IVD-15', 'TRADE_DATE', 'STANDARD', '{columnType:"string", label:"Trade Date",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Trade Date"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-102', 'IVD-15', 'DERIVATIVE_REF_NO', 'STANDARD', '{columnType:"string", label:"Contract Ref No.",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Contract Ref No"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-104', 'IVD-15', 'DERIVATIVE_TYPE', 'STANDARD', '{columnType:"string", label:"Derivative Type",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Derivative Type"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-105', 'IVD-15', 'INSTRUMENT_NAME', 'STANDARD', '{columnType:"string", label:"Instrument Name",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Instrument Name"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-106', 'IVD-15', 'DEAL_TYPE', 'STANDARD', '{columnType:"string", label:"Deal Type",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Deal Type"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-107', 'IVD-15', 'PROMPT_DATE', 'STANDARD', '{columnType:"string", label:"Prompt Date",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Prompt Date"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-108', 'IVD-15', 'QUANTITY', 'STANDARD', '{columnType:"string", label:"Quantity(MT)",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Quantity(MT)"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-109', 'IVD-15', 'TRADE_PRICE', 'STANDARD', '{columnType:"string", label:"Trade Price",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Trade Price"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-110', 'IVD-16', 'INTERNAL_STOCK_REF_NO', 'STANDARD', '{columnType:"string", label:"Stock Ref No.",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Stock Ref No"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-111', 'IVD-16', 'GMR_REF_NO', 'STANDARD', '{columnType:"string", label:"GMR Ref No",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"GMR Ref No"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-112', 'IVD-16', 'CONTRACT_ITEM_REF_NO', 'STANDARD', '{columnType:"string", label:"Contract Item Ref No.",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Contract Item Ref No"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-113', 'IVD-16', 'CP_NAME', 'STANDARD', '{columnType:"string", label:"CP Name",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"CP Name"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-114', 'IVD-16', 'PRODUCT_DESC', 'STANDARD', '{columnType:"string", label:"Product",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Product"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-115', 'IVD-16', 'QUALITY_NAME', 'STANDARD', '{columnType:"string", label:"Quality",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Quality"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-130', 'IVD-13', 'IM_LIMIT', 'STANDARD', '{columnType:"string", label:"IM Limit",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"IM Limit"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-131', 'IVD-13', 'IM_UTILIZATION', 'STANDARD', '{columnType:"string", label:"IM Utilization",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"IM Utilization"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-132', 'IVD-13', 'IM_HEADROOM', 'STANDARD', '{columnType:"string", label:"IM Headroom",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"IM Headroom"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-126', 'IVD-17', 'STOCK_STATUS', 'STANDARD', '{columnType:"string", label:"Stock Status",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Stock Status"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-127', 'IVD-17', 'BL_NUMBER', 'STANDARD', '{columnType:"string", label:"BL No",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"BL No"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-128', 'IVD-17', 'STRATEGY', 'STANDARD', '{columnType:"string", label:"Strategy",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Strategy"}}');
Insert into IVCD_IEKA_VIEW_COLUMN_DEF
   (VIEW_COLUMN_DEF_ID, VIEW_DEF_ID, COLUMN_NAME, COLUMN_TYPE_ID, CONFIG)
 Values
   ('IVCD-129', 'IVD-17', 'CURRENT_QTY', 'STANDARD', '{columnType:"string", label:"Current Qty (MT)",align:"left",width:100,sortable:false,"tooltipRequired":true,"tooltipConfig":{"tooltipType":"static","tooltipKey":"Current Qty (MT)"}}');


Insert into PRLTM_PORTLET_MASTER
   (PORTLET_ID, VIEW_DEF_ID, PORTLET_NAME, PORTLET_DESCRIPTION, IS_GRPAHICAL_VIEW_BASED, 
    URL, JS_FILE_NAME, USE_STANDARD_SERVICE, IS_ALWAYS_DEPENDENT, CONFIG, 
    IS_DELETED)
 Values
   ('PRLTM-14', 'IVD-14', 'Price fixation in next 7 days', 'Price fixation in next 7 days', 'Y', 
    '/iEka/iekaDashboardPage.do?method=getPortletData&portletId=PRLTM-14', NULL, 'Y', 'N', '{"height":99,"titleConfig":{"titleType":"static","dynamicBy":"parent","titleKey":"Price fixation in next 7 days"},"autoLoad":true,"gridSummary":false,"gridHandler":true}', 
    'N');
Insert into PRLTM_PORTLET_MASTER
   (PORTLET_ID, VIEW_DEF_ID, PORTLET_NAME, PORTLET_DESCRIPTION, IS_GRPAHICAL_VIEW_BASED, 
    URL, JS_FILE_NAME, USE_STANDARD_SERVICE, IS_ALWAYS_DEPENDENT, CONFIG, 
    IS_DELETED)
 Values
   ('PRLTM-16', 'IVD-16', 'Warehouse stocks', 'Warehouse stocks', 'Y', 
    '/iEka/iekaDashboardPage.do?method=getPortletData&portletId=PRLTM-16', NULL, 'Y', 'N', '{"height":99,"titleConfig":{"titleType":"static","dynamicBy":"parent","titleKey":"Warehouse stocks"},"autoLoad":true,"gridSummary":false,"gridHandler":true}', 
    'N');
Insert into PRLTM_PORTLET_MASTER
   (PORTLET_ID, VIEW_DEF_ID, PORTLET_NAME, PORTLET_DESCRIPTION, IS_GRPAHICAL_VIEW_BASED, 
    URL, JS_FILE_NAME, USE_STANDARD_SERVICE, IS_ALWAYS_DEPENDENT, CONFIG, 
    IS_DELETED)
 Values
   ('PRLTM-15', 'IVD-15', 'Prompt dates in next 7 days', 'Prompt dates in next 7 days', 'Y', 
    '/iEka/iekaDashboardPage.do?method=getPortletData&portletId=PRLTM-15', NULL, 'Y', 'N', '{"height":99,"titleConfig":{"titleType":"static","dynamicBy":"parent","titleKey":"Prompt dates in next 7 days"},"autoLoad":true,"gridSummary":false,"gridHandler":true}', 
    'N');
Insert into PRLTM_PORTLET_MASTER
   (PORTLET_ID, VIEW_DEF_ID, PORTLET_NAME, PORTLET_DESCRIPTION, IS_GRPAHICAL_VIEW_BASED, 
    URL, JS_FILE_NAME, USE_STANDARD_SERVICE, IS_ALWAYS_DEPENDENT, CONFIG, 
    IS_DELETED)
 Values
   ('PRLTM-17', 'IVD-17', 'Delivered stocks', 'Delivered stocks', 'Y', 
    '/iEka/iekaDashboardPage.do?method=getPortletData&portletId=PRLTM-17', NULL, 'Y', 'N', '{"height":99,"titleConfig":{"titleType":"static","dynamicBy":"parent","titleKey":"Delivered stocks"},"autoLoad":true,"gridSummary":false,"gridHandler":true}', 
    'N');
Insert into PRLTM_PORTLET_MASTER
   (PORTLET_ID, VIEW_DEF_ID, PORTLET_NAME, PORTLET_DESCRIPTION, IS_GRPAHICAL_VIEW_BASED, 
    URL, JS_FILE_NAME, USE_STANDARD_SERVICE, IS_ALWAYS_DEPENDENT, CONFIG, 
    IS_DELETED)
 Values
   ('PRLTM-13', 'IVD-13', 'Broker Margin', 'Broker Margin', 'Y', 
    '/iEka/iekaDashboardPage.do?method=getPortletData&portletId=PRLTM-13', NULL, 'Y', 'N', '{"height":99,"titleConfig":{"titleType":"static","dynamicBy":"parent","titleKey":"Broker Margin"},"autoLoad":true,"gridSummary":false,"gridHandler":true}', 
    'N');

Insert into IGVD_IEKA_GRAPHICAL_VIEW_DET
   (GRAPHICAL_VIEW_ID, PORTLET_ID, GRAPHICAL_VIEW_NAME, GRAPHICAL_VIEW_DESC, GRPAHICAL_VIEW_TYPE_ID, 
    CONFIG, IS_DELETED)
 Values
   ('IGVD-15', 'PRLTM-15', 'Prompt dates in next 7 days', 'Prompt dates in next 7 days', 'GRID', 
    NULL, 'N');
Insert into IGVD_IEKA_GRAPHICAL_VIEW_DET
   (GRAPHICAL_VIEW_ID, PORTLET_ID, GRAPHICAL_VIEW_NAME, GRAPHICAL_VIEW_DESC, GRPAHICAL_VIEW_TYPE_ID, 
    CONFIG, IS_DELETED)
 Values
   ('IGVD-13', 'PRLTM-13', 'Broker Margin', 'Broker Margin', 'GRID', 
    NULL, 'N');
Insert into IGVD_IEKA_GRAPHICAL_VIEW_DET
   (GRAPHICAL_VIEW_ID, PORTLET_ID, GRAPHICAL_VIEW_NAME, GRAPHICAL_VIEW_DESC, GRPAHICAL_VIEW_TYPE_ID, 
    CONFIG, IS_DELETED)
 Values
   ('IGVD-16', 'PRLTM-16', 'Warehouse stocks', 'Warehouse stocks', 'GRID', 
    NULL, 'N');
Insert into IGVD_IEKA_GRAPHICAL_VIEW_DET
   (GRAPHICAL_VIEW_ID, PORTLET_ID, GRAPHICAL_VIEW_NAME, GRAPHICAL_VIEW_DESC, GRPAHICAL_VIEW_TYPE_ID, 
    CONFIG, IS_DELETED)
 Values
   ('IGVD-17', 'PRLTM-17', 'Delivered stocks', 'Delivered stocks', 'GRID', 
    NULL, 'N');
Insert into IGVD_IEKA_GRAPHICAL_VIEW_DET
   (GRAPHICAL_VIEW_ID, PORTLET_ID, GRAPHICAL_VIEW_NAME, GRAPHICAL_VIEW_DESC, GRPAHICAL_VIEW_TYPE_ID, 
    CONFIG, IS_DELETED)
 Values
   ('IGVD-14', 'PRLTM-14', 'Price fixation in next 7 days', 'Price fixation in next 7 days', 'GRID', 
    NULL, 'N');

Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-13', 'IVCD-93', NULL, 1);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-13', 'IVCD-94', NULL, 2);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-15', 'IVCD-102', NULL, 1);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-15', 'IVCD-103', NULL, 2);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-15', 'IVCD-104', NULL, 3);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-15', 'IVCD-105', NULL, 4);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-15', 'IVCD-106', NULL, 5);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-15', 'IVCD-107', NULL, 6);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-15', 'IVCD-108', NULL, 7);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-15', 'IVCD-109', NULL, 8);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-16', 'IVCD-110', NULL, 1);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-16', 'IVCD-111', NULL, 2);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-16', 'IVCD-112', NULL, 3);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-16', 'IVCD-113', NULL, 4);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-16', 'IVCD-114', NULL, 5);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-16', 'IVCD-115', NULL, 6);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-16', 'IVCD-116', NULL, 7);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-16', 'IVCD-117', NULL, 8);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-16', 'IVCD-118', NULL, 9);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-16', 'IVCD-119', NULL, 10);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-17', 'IVCD-120', NULL, 1);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-17', 'IVCD-121', NULL, 2);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-17', 'IVCD-122', NULL, 3);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-17', 'IVCD-123', NULL, 4);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-17', 'IVCD-124', NULL, 5);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-17', 'IVCD-125', NULL, 6);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-17', 'IVCD-126', NULL, 7);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-17', 'IVCD-127', NULL, 8);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-17', 'IVCD-128', NULL, 9);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-17', 'IVCD-129', NULL, 10);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-13', 'IVCD-130', NULL, 3);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-13', 'IVCD-131', NULL, 4);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-13', 'IVCD-132', NULL, 5);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-14', 'IVCD-95', NULL, 1);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-14', 'IVCD-96', NULL, 2);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-14', 'IVCD-97', NULL, 3);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-14', 'IVCD-98', NULL, 4);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-14', 'IVCD-99', NULL, 5);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-14', 'IVCD-100', NULL, 6);
Insert into IGVC_IEKA_GRAPHICAL_VIEW_COL
   (GRAPHICAL_VIEW_ID, VIEW_COLUMN_DEF_ID, CONFIG, DISPLAY_ORDER)
 Values
   ('IGVD-14', 'IVCD-101', NULL, 7);

Insert into PRTLM_PORTAL_MASTER
   (PORTAL_ID, PORTAL_NAME, PORTAL_DESC, PORTAL_CATEGORY_ID, QUANTITY_DENOMINATOR, 
    IS_FIXED_TO_SCREEN, NO_OF_PORTLETS, NO_OF_ROWS, NO_OF_COLUMNS, CONFIG, 
    IS_DELETED)
 Values
   ('PRTLM-3', 'Alerts', 'Alerts', 'DASHBOARD', NULL, 
    'Y', 5, 2, 3, '{"xtype":"portal", "region":"center","margins":"100 5 5 0","frame":true,"minsize":800,"portalDefault":true,"columnWidth":[0.333,0.333,0.333], "customScriptFile":"/private/js/ieka/ieka-Custom-Function.js"}', 
    'N');


Insert into PRTLMAP_PORTAL_MAPPING
   (PORTAL_ID, PORTLET_ID, IS_CHILD, PARENT_PORTLET_ID, PARENT_PRIMARY_KEY, 
    PARENT_TITLE_KEY, DEFAULT_VIEW, COLUMN_NUMBER, ROW_NUMBER)
 Values
   ('PRTLM-3', 'PRLTM-15', 'N', NULL, NULL, 
    NULL, 'IGVD-15', 2, 1);
Insert into PRTLMAP_PORTAL_MAPPING
   (PORTAL_ID, PORTLET_ID, IS_CHILD, PARENT_PORTLET_ID, PARENT_PRIMARY_KEY, 
    PARENT_TITLE_KEY, DEFAULT_VIEW, COLUMN_NUMBER, ROW_NUMBER)
 Values
   ('PRTLM-3', 'PRLTM-13', 'N', NULL, NULL, 
    NULL, 'IGVD-13', 2, 2);
Insert into PRTLMAP_PORTAL_MAPPING
   (PORTAL_ID, PORTLET_ID, IS_CHILD, PARENT_PORTLET_ID, PARENT_PRIMARY_KEY, 
    PARENT_TITLE_KEY, DEFAULT_VIEW, COLUMN_NUMBER, ROW_NUMBER)
 Values
   ('PRTLM-3', 'PRLTM-16', 'N', NULL, NULL, 
    NULL, 'IGVD-16', 3, 1);
Insert into PRTLMAP_PORTAL_MAPPING
   (PORTAL_ID, PORTLET_ID, IS_CHILD, PARENT_PORTLET_ID, PARENT_PRIMARY_KEY, 
    PARENT_TITLE_KEY, DEFAULT_VIEW, COLUMN_NUMBER, ROW_NUMBER)
 Values
   ('PRTLM-3', 'PRLTM-17', 'N', NULL, NULL, 
    NULL, 'IGVD-17', 1, 2);
Insert into PRTLMAP_PORTAL_MAPPING
   (PORTAL_ID, PORTLET_ID, IS_CHILD, PARENT_PORTLET_ID, PARENT_PRIMARY_KEY, 
    PARENT_TITLE_KEY, DEFAULT_VIEW, COLUMN_NUMBER, ROW_NUMBER)
 Values
   ('PRTLM-3', 'PRLTM-14', 'N', NULL, NULL, 
    NULL, 'IGVD-14', 1, 1);


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('IEKA-19', 'Alerts', 25, 2, '/iEka/iekaDashboardPage.do?method=getPortalMetadataJson&portalId=PRTLM-3', 
    NULL, 'IEKA-1', 'APP-ACL-N889', 'iEka', 'APP-PFL-N-161', 
    'N');

COMMIT;

