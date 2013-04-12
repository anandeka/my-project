alter table IS_CONC_TC_CHILD add(ESC_DESC_AMOUNT varchar2(100));
alter table IS_CONC_TC_CHILD add(BASEESCDESC_TYPE varchar2(100));
alter table IS_CONC_TC_CHILD add(BASE_TC varchar2(100));
alter table INTC_INV_TREATMENT_CHARGES add(BASEESCDESC_TYPE varchar2(100));

alter table INRC_INV_REFINING_CHARGES add(BASEESCDESC_TYPE varchar2(100),PAYABLE_QTY varchar2(100));
alter table IS_CONC_RC_CHILD add(BASE_RC varchar2(100));
alter table IS_CONC_RC_CHILD add(BASEESCDESC_TYPE varchar2(100));
alter table IS_CONC_RC_CHILD add(PAYABLE_QTY varchar2(100));