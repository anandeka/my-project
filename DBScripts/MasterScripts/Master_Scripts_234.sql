set define off;
insert into amc_app_menu_configuration (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
values ('BI-17', 'Exposure', 12, 2, '/metalExposureDashboardForwardServlet', '', 'BI-1', 'APP-ACL-N897', 'Analytics', 'APP-PFL-N-161', 'N');

insert into amc_app_menu_configuration (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
values ('BI-16', 'Trade P&L', 11, 2, '/metalTradePnlDashboardForwardServlet', '', 'BI-1', 'APP-ACL-N897', 'Analytics', 'APP-PFL-N-161', 'N');

insert into amc_app_menu_configuration (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
values ('BI-18', 'Unrealized P&L', 10, 2, '/metalPnlDashboardForwardServlet', '', 'BI-1', 'APP-ACL-N897', 'Analytics', 'APP-PFL-N-161', 'N');

--insert into amc_app_menu_configuration (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
--values ('BI-14', 'Physical Position Dashboard', 1, 2, '/metalPhysicalPositionDashboardForwardServlet', '', 'BI-1', 'APP-ACL-N897', 'Analytics', 'APP-PFL-N-161', 'N');

--insert into amc_app_menu_configuration (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
--values ('BI-18', 'Metal Balance', 13, 2, '/metalBalanceDashboardForwardServlet', '', 'BI-1', 'APP-ACL-N897', 'Analytics', 'APP-PFL-N-161', 'N');
