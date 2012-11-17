alter table is_d ADD ADJUSTMENT_AMOUNT varchar2(30);
alter table is_d ADD FREIGHT_CHARGE varchar2(30);
alter table IS_CONC_PAYABLE_CHILD add NET_PAYABLE VARCHAR2 (30);
alter table IS_CONC_PAYABLE_CHILD add DRY_QUANTITY VARCHAR2 (30);
ALTER TABLE is_conc_penalty_child ADD (uom VARCHAR2 (30),penalty_rate VARCHAR2 (30),price_name VARCHAR2 (30),wet_qty VARCHAR2 (30), penalty_qty VARCHAR2 (30),assay_details VARCHAR2 (30), QUANTITY_UOM varchar2(30));
alter table IS_CONC_RC_CHILD ADD (assay_details VARCHAR2(30), rc_es_ds VARCHAR2(30),assay_uom VARCHAR2(30),price_name VARCHAR2(30));
alter table IS_CONC_TC_CHILD ADD (WET_QUANTITY VARCHAR2(30), moisture VARCHAR2(30),tc_price VARCHAR2(30),price_unit VARCHAR2(30));
