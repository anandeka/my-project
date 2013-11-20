alter table AXS_ACTION_SUMMARY  modify ACTION_REF_NO VARCHAR2 (1000 Char);
alter table PFRD_PRICE_FIX_REPORT_DETAIL  modify PF_REF_NO VARCHAR2 (1000 Char);
alter table tar_temp_alloc_report modify PF_REF_NO VARCHAR2 (1000 Char);
alter table mbv_allocation_report modify PF_REF_NO VARCHAR2 (1000 Char);
alter table pofh_history modify LATEST_PFC_NO VARCHAR2 (1000 Char);