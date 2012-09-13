alter table pa_purchase_accural_gmr add warehouse_profile_id VARCHAR2(20);
alter table pa_purchase_accural_gmr add warehouse_name  VARCHAR2(100);
ALTER TABLE DPD_DERIVATIVE_PNL_DAILY MODIFY(PAYMENT_TERM_ID VARCHAR2(30));
ALTER TABLE DPD_DERIVATIVE_PNL_DAILY MODIFY(PAYMENT_TERM VARCHAR2(100));
