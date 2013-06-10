alter table tcsm_temp_contract_status_main add CONTRACT_TYPE VARCHAR2 (30 Char);
alter table tcsm_temp_contract_status_main add DELIVERY_ITEM_NO VARCHAR2 (30 Char);
alter table tcsm_temp_contract_status_main add PCDI_ID VARCHAR2 (15 Char);


alter table tcs1_temp_cs_payable add CONTRACT_TYPE VARCHAR2 (30 Char);
alter table tcs1_temp_cs_payable add DELIVERY_ITEM_NO VARCHAR2 (30 Char);
alter table tcs1_temp_cs_payable add PCDI_ID VARCHAR2 (15 Char);

alter table tcs2_temp_cs_priced add CONTRACT_TYPE VARCHAR2 (30 Char);
alter table tcs2_temp_cs_priced add DELIVERY_ITEM_NO VARCHAR2 (30 Char);
alter table tcs2_temp_cs_priced add PCDI_ID VARCHAR2 (15 Char);

alter table PCS_PURCHASE_CONTRACT_STATUS add CONTRACT_TYPE VARCHAR2 (30 Char);
alter table PCS_PURCHASE_CONTRACT_STATUS add DELIVERY_ITEM_NO VARCHAR2 (30 Char);
alter table PCS_PURCHASE_CONTRACT_STATUS add PCDI_ID VARCHAR2 (15 Char);
--added later
ALTER TABLE PCS_PURCHASE_CONTRACT_STATUS ADD INSTRUMENT_ID VARCHAR2(15);--gone
ALTER TABLE TCS2_TEMP_CS_PRICED ADD INSTRUMENT_ID VARCHAR2(15);--gone
