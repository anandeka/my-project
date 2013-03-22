ALTER TABLE DGRDUL_DELIVERED_GRD_UL ADD PCDI_ID VARCHAR2(15);

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD(
IS_TOLLING_CONTRACT			VARCHAR2(1),
PCM_CONTRACT_TYPE			VARCHAR2(10));

ALTER TABLE PATD_PA_TEMP_DATA ADD(TRADE_TYPE   VARCHAR2(20) DEFAULT 'Non Base Metal');

ALTER TABLE PA_TEMP ADD(TRADE_TYPE   VARCHAR2(20));

ALTER TABLE PA_PURCHASE_ACCURAL_GMR ADD(TRADE_TYPE   VARCHAR2(20));

ALTER TABLE PA_PURCHASE_ACCURAL ADD(TRADE_TYPE   VARCHAR2(20));

ALTER TABLE DGRD_DELIVERED_GRD ADD(
PCDI_ID                        VARCHAR2(15),
CONC_PRODUCT_ID                VARCHAR2(15),        
CONC_PRODUCT_NAME              VARCHAR2(100),
PROFIT_CENTER_NAME             VARCHAR2(30),        
PROFIT_CENTER_SHORT_NAME       VARCHAR2(15),
QUALITY_NAME                   VARCHAR2(200),
PRODUCT_NAME                   VARCHAR2(200),
BASE_QTY_UNIT_ID               VARCHAR2(15),
BASE_QTY_UNIT                  VARCHAR2(15));

ALTER TABLE TCSM_TEMP_CONTRACT_STATUS_MAIN ADD PURCHASE_SALES CHAR(1);

ALTER TABLE PCS_PURCHASE_CONTRACT_STATUS ADD PURCHASE_SALES CHAR(1);

ALTER TABLE TCSM_TEMP_CONTRACT_STATUS_MAIN ADD ATTRIBUTE_DESC VARCHAR2(2000);

ALTER TABLE PCS_PURCHASE_CONTRACT_STATUS ADD ELEMENT_DESC VARCHAR2(2000);

-- Update Contract Type and Trade Type in Purchase Accrual
begin
  for cc1 in (select gmr.internal_gmr_ref_no,
                     decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
                     pa.process_id,
                     case when pcm.contract_type ='BASEMETAL' then 'Base Metal'
                     else
                     case
                       when pcm.is_tolling_contract = 'N' then
                        'Concentrates'
                       else
                        'Tolling'
                     end 
                     end trade_type
                from pcm_physical_contract_main pcm,
                     gmr_goods_movement_record  gmr,
                     pa_purchase_accural_gmr    pa
               where pcm.internal_contract_ref_no =
                     gmr.internal_contract_ref_no
                 and pcm.process_id = gmr.process_id
                 and gmr.internal_gmr_ref_no = pa.internal_gmr_ref_no
                 and pa.process_id = gmr.process_id)
  loop
    update pa_purchase_accural_gmr pa
       set pa.contract_type = cc1.purchase_sales,
           pa.trade_type    = cc1.trade_type
     where pa.internal_gmr_ref_no = cc1.internal_gmr_ref_no
       and pa.process_id = cc1.process_id;
  end loop;
  commit;
end;
/
