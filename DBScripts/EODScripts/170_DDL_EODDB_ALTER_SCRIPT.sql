alter table aro_ar_original_report add GMR_WET_QTY NUMBER (25,5);
alter table aro_ar_original_report add GMR_DRY_QTY NUMBER (25,5);
alter table FOR_FEED_ORIGINAL_REPORT add GMR_WET_QTY NUMBER (25,5);
alter table FOR_FEED_ORIGINAL_REPORT add GMR_DRY_QTY NUMBER (25,5);
alter table  FOR_FEED_ORIGINAL_REPORT add FEEDING_POINT_NAME VARCHAR2 (30);
alter table  FOR_FEED_ORIGINAL_REPORT add PILE_NAME VARCHAR2 (50);
alter table  GPQ_GMR_PAYABLE_QTY add ASSAY_QTY NUMBER (25,10)