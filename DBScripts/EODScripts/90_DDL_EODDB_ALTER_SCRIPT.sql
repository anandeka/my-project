alter  table  PRP_PHYSICAL_RISK_POSITION add qp_period_type varchar2(50);
alter  table  PRP_PHYSICAL_RISK_POSITION add contract_price_cur_id varchar2(15);
alter  table  PRP_PHYSICAL_RISK_POSITION add contract_premium_cur_id varchar2(15);
alter  table  PRP_PHYSICAL_RISK_POSITION add m2m_price_cur_id varchar2(15);
alter  table  PRP_PHYSICAL_RISK_POSITION add contract_pp_to_price_fx_rate number(25,10);
alter  table  PRP_PHYSICAL_RISK_POSITION add m2m_price_to_price_fx_rate number(25,10);
alter  table  PRP_PHYSICAL_RISK_POSITION add m2m_premium_to_price_fx_rate number(25,10);


create table  cmp_contract_market_price
(process_id      varchar2(15),
 contract_ref_no varchar2(15),
 pcdi_id         varchar2(15),
 qp_start_date   date,
 qp_end_date     date,
 price           number,
 price_unit_id   varchar2(15)
 );


create table  gmp_gmr_market_price
(process_id      varchar2(15), 
 internal_gmr_ref_no  varchar2(15),
 pcdi_id         varchar2(15),
 qp_start_date   date,
 qp_end_date     date,
 price           number,
 price_unit_id   varchar2(15)
 );

create index idx_cmp1 on cmp_contract_market_price(process_id,pcdi_id);

create index idx_gmp1 on gmp_gmr_market_price(process_id,pcdi_id);


create table  temp_ii
(corporate_id            varchar2(15),
 internal_invoice_ref_no varchar2(15),
 delivery_item_ref_no    varchar2(20));

alter table temp_ii add created_USER_ID varchar2(50); 
alter table temp_ii add created_USER_NAME varchar2(200); 

drop index IDX_TEMP_II1;

CREATE INDEX IDX_TEMP_II1 ON TEMP_II
(CORPORATE_ID,internal_invoice_ref_no)
LOGGING
NOPARALLEL
/

alter table EOD_EOM_PHY_BOOKING_JOURNAL add created_USER_ID varchar2(50);
alter table EOD_EOM_PHY_BOOKING_JOURNAL add created_USER_NAME varchar2(200);
ALTER TABLE EOD_EOM_PHY_BOOKING_JOURNAL MODIFY(ATTRIBUTE1 VARCHAR2(100));
ALTER TABLE EOD_EOM_PHY_BOOKING_JOURNAL MODIFY(ATTRIBUTE2 VARCHAR2(100));
ALTER TABLE EOD_EOM_PHY_BOOKING_JOURNAL MODIFY(ATTRIBUTE3 VARCHAR2(100));
ALTER TABLE EOD_EOM_PHY_BOOKING_JOURNAL MODIFY(ATTRIBUTE4 VARCHAR2(100));
ALTER TABLE EOD_EOM_PHY_BOOKING_JOURNAL MODIFY(ATTRIBUTE5 VARCHAR2(100));

ALTER TABLE IS_INVOICE_SUMMARY ADD (IS_MODIFIED_TODAY VARCHAR2(1));

ALTER TABLE INVM_INVENTORY_MASTER MODIFY(INV_IN_ACTION_REF_NO  NULL);
ALTER TABLE INVM_INVENTORY_MASTER MODIFY(INV_STATUS  NULL);
ALTER TABLE INVM_INVENTORY_MASTER MODIFY(ORIGINAL_INV_QTY  NULL);
ALTER TABLE INVM_INVENTORY_MASTER MODIFY(CURRENT_INV_QTY  NULL);
ALTER TABLE INVM_INVENTORY_MASTER MODIFY(INV_QTY_ID  NULL);
ALTER TABLE INVM_INVENTORY_MASTER MODIFY(COG  NULL);
ALTER TABLE INVM_INVENTORY_MASTER MODIFY(AVG_COG  NULL);
ALTER TABLE INVM_INVENTORY_MASTER MODIFY(COG_CUR_ID  NULL);
ALTER TABLE INVM_INVENTORY_MASTER MODIFY(MATERIAL_COST  NULL);
ALTER TABLE INVM_INVENTORY_MASTER MODIFY(SECONDARY_COST  NULL);
ALTER TABLE INVM_INVENTORY_MASTER MODIFY(VERSION  NULL);