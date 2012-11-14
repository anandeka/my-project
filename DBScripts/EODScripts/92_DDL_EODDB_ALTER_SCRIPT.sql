CREATE TABLE TGOC_TEMP_GMR_OTHER_CHARGE(
CORPORATE_ID                VARCHAR2(15),
INTERNAL_GMR_REF_NO         VARCHAR2(15),
INTERNAL_CONTRACT_REF_NO    VARCHAR2(15),
IS_WNS_CREATED              VARCHAR2(1),
IS_INVOICED                VARCHAR2(1),
NO_OF_BAGS                  NUMBER(10),
NO_OF_SUBLOTS               NUMBER(10),
DRY_QTY                     NUMBER(25,10),
WET_QTY                     NUMBER(25,10),
SMALL_LOT_CHARGE            NUMBER(25,10),
CONTAINER_CHARGE            NUMBER(25,10),
SAMPLING_CHARGE             NUMBER(25,10),
HANDLING_CHARGE             NUMBER(25,10),
LOCATION_VALUE              NUMBER(25,10),
FREIGHT_ALLOWANCE           NUMBER(25,10),
IS_APPLY_CONTAINER_CHARGE  CHAR(1),        
IS_APPLY_FREIGHT_ALLOWANCE CHAR(1),
LATEST_INTERNAL_INVOICE_REF_NO VARCHAR2(15));      


CREATE TABLE PCMAC_PCM_ADDN_CHARGES(
CORPORATE_ID         VARCHAR2(15 )        NOT NULL,       
PCMAC_ID             VARCHAR2(15 )        NOT NULL,
INT_CONTRACT_REF_NO  VARCHAR2(15 )        NOT NULL,
ADDN_CHARGE_ID       VARCHAR2(10 )        NOT NULL,
ADDN_CHARGE_NAME     VARCHAR2(50 )        NOT NULL,
CHARGE_TYPE          VARCHAR2(30 ),
POSITION             VARCHAR2(30 ),
RANGE_MIN_OP         VARCHAR2(15 ),
RANGE_MIN_VALUE      NUMBER(25,10),
RANGE_MAX_OP         VARCHAR2(15 ),
RANGE_MAX_VALUE      NUMBER(25,10),
RANGE_UNIT_ID        VARCHAR2(15 ),
CHARGE               NUMBER(25,10)        NOT NULL,
CHARGE_CUR_ID        VARCHAR2(15 )        NOT NULL,
CHARGE_RATE_BASIS    VARCHAR2(30 ),
CONTAINER_SIZE       VARCHAR2(30 ),
FX_RATE              VARCHAR2(30 ),
IS_ACTIVE            CHAR(1 )             NOT NULL,
QTY_UNIT_ID          VARCHAR2(10 ),
VERSION              NUMBER(10)           NOT NULL,
IS_AUTOMATIC_CHARGE  CHAR(1 )             DEFAULT 'N');

ALTER TABLE GMRUL_GMR_UL ADD IS_APPLY_CONTAINER_CHARGE  VARCHAR2(1);
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD IS_APPLY_CONTAINER_CHARGE  VARCHAR2(1);

ALTER TABLE PATD_PA_TEMP_DATA   ADD(
NO_OF_BAGS                      NUMBER(10),
INTERNAL_CONTRACT_REF_NO        VARCHAR2(15),
IS_WNS_CREATED                  VARCHAR2(1),
IS_INVOICED                     VARCHAR2(1),
IS_APPLY_CONTAINER_CHARGE       CHAR(1),        
IS_APPLY_FREIGHT_ALLOWANCE      CHAR(1),
LATEST_INTERNAL_INVOICE_REF_NO  VARCHAR2(15));


begin
  for cc in (select gmrul_app.internal_action_ref_no,
                    gmrul_app.internal_gmr_ref_no,
                    gmrul_app.is_apply_container_charge
               from gmrul_gmr_ul@eka_appdb gmrul_app
              where gmrul_app.is_apply_container_charge is not null)
  loop
    update gmrul_gmr_ul gmrul_eod
       set gmrul_eod.is_apply_container_charge = cc.is_apply_container_charge
     where gmrul_eod.internal_gmr_ref_no = cc.internal_gmr_ref_no
       and gmrul_eod.internal_action_ref_no = cc.internal_action_ref_no;
  end loop;
end; 

commit;

drop index IDX_PCI;
drop index IDX_PCI2;
create index IDX_PCI2 on PCI_PHYSICAL_CONTRACT_ITEM (PROCESS_ID, IS_ACTIVE);

CREATE MATERIALIZED VIEW GPAH_GMR_PRICE_ALLOC_HEADER AS SELECT * FROM GPAH_GMR_PRICE_ALLOC_HEADER@EKA_APPDB;
CREATE MATERIALIZED VIEW GPAD_GMR_PRICE_ALLOC_DTLS AS SELECT * FROM GPAD_GMR_PRICE_ALLOC_DTLS@EKA_APPDB;

ALTER TABLE PCDI_PC_DELIVERY_ITEM ADD PRICE_ALLOCATION_METHOD VARCHAR2(30);
ALTER TABLE PCDIUL_PC_DELIVERY_ITEM_UL ADD PRICE_ALLOCATION_METHOD VARCHAR2(30);

declare
  cursor cur_temp is
    select * from pcdiul_pc_delivery_item_ul@eka_appdb pcdiul;
begin
  for cur_temp_rows in cur_temp
  loop
    update pcdiul_pc_delivery_item_ul ul_eod
       set ul_eod.price_allocation_method = cur_temp_rows.price_allocation_method
     where ul_eod.pcdiul_id = cur_temp_rows.pcdiul_id;
  end loop;
end;
/
commit;

CREATE TABLE PAGE_PRICE_ALLOC_GMR_EXCHANGE(
PROCESS_ID                      VARCHAR2(15),
INTERNAL_GMR_REF_NO             VARCHAR2(15),
INSTRUMENT_ID                   VARCHAR2(15),
INSTRUMENT_NAME                 VARCHAR2(50),
DERIVATIVE_DEF_ID               VARCHAR2(15),
DERIVATIVE_DEF_NAME             VARCHAR2(50),
EXCHANGE_ID                     VARCHAR2(15),
EXCHANGE_NAME                   VARCHAR2(100),
ELEMENT_ID                      VARCHAR2(15));
