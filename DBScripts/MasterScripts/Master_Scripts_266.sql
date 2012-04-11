-- master scripts
Update RML_REPORT_MASTER_LIST rml
set RML.IS_ACTIVE ='Y'
WHERE report_id in (213,216);
COMMIT;
Update AMC_APP_MENU_CONFIGURATION amc
set AMC.IS_DELETED ='N'
where AMC.MENU_ID in ('RPT-D224','RPT-D225');
COMMIT;