DROP materialized view MV_BI_PHY_BOOK_JOURNAL_EOD;
DROP table MV_BI_PHY_BOOK_JOURNAL_EOD;
create materialized view MV_BI_PHY_BOOK_JOURNAL_EOD
refresh force on demand
with rowid
as
select eepbj.section_name,
       eepbj.corporate_id,
       eepbj.corporate_name,
       eepbj.product_id,
       eepbj.product_desc,
       eepbj.counter_party_id,
       eepbj.counter_party_name,
       eepbj.invoice_quantity,
       eepbj.invoice_quantity_uom,
       eepbj.fx_base,
       eepbj.profit_center_id,
       eepbj.profit_center,
       eepbj.strategy_id,
       eepbj.strategy_name,
       eepbj.base_cur_id,
       eepbj.base_currency,
       eepbj.invoice_ref_no,
       eepbj.contract_ref_no,
       eepbj.internal_contract_ref_no,
       eepbj.invoice_cur_id,
       eepbj.pay_in_currency,
       eepbj.amount_in_base_cur,
       eepbj.invoice_amt,
       eepbj.invoice_date,
       eepbj.invoice_due_date,
       eepbj.invoice_type,
       eepbj.bill_to_cp_country,
       eepbj.delivery_item_ref_no,
       eepbj.vat_amount,
       eepbj.vat_remit_cur_id,
       eepbj.vat_remit_currency,
       eepbj.fx_rate_for_vat,
       eepbj.vat_amount_base_currency,
       eepbj.commission_value,
       eepbj.commission_value_ccy,
       eepbj.attribute1,
       eepbj.attribute2,
       eepbj.attribute3,
       eepbj.attribute4,
       eepbj.attribute5,
       eepbj.process_id,
       eepbj.process,
       eepbj.eod_run_date,
       eepbj.eod_date,
       eepbj.process_run_count
  from eod_eom_phy_booking_journal@eka_eoddb eepbj
    where eepbj.process='EOD';
DROP materialized view MV_BI_PHY_BOOK_JOURNAL_EOM;
DROP table MV_BI_PHY_BOOK_JOURNAL_EOM;

create materialized view MV_BI_PHY_BOOK_JOURNAL_EOM
refresh force on demand
with rowid
as
select eepbj.section_name,
       eepbj.corporate_id,
       eepbj.corporate_name,
       eepbj.product_id,
       eepbj.product_desc,
       eepbj.counter_party_id,
       eepbj.counter_party_name,
       eepbj.invoice_quantity,
       eepbj.invoice_quantity_uom,
       eepbj.fx_base,
       eepbj.profit_center_id,
       eepbj.profit_center,
       eepbj.strategy_id,
       eepbj.strategy_name,
       eepbj.base_cur_id,
       eepbj.base_currency,
       eepbj.invoice_ref_no,
       eepbj.contract_ref_no,
       eepbj.internal_contract_ref_no,
       eepbj.invoice_cur_id,
       eepbj.pay_in_currency,
       eepbj.amount_in_base_cur,
       eepbj.invoice_amt,
       eepbj.invoice_date,
       eepbj.invoice_due_date,
       eepbj.invoice_type,
       eepbj.bill_to_cp_country,
       eepbj.delivery_item_ref_no,
       eepbj.vat_amount,
       eepbj.vat_remit_cur_id,
       eepbj.vat_remit_currency,
       eepbj.fx_rate_for_vat,
       eepbj.vat_amount_base_currency,
       eepbj.commission_value,
       eepbj.commission_value_ccy,
       eepbj.attribute1,
       eepbj.attribute2,
       eepbj.attribute3,
       eepbj.attribute4,
       eepbj.attribute5,
       eepbj.process_id,
       eepbj.process,
       eepbj.eod_run_date,
       eepbj.eod_date,
       eepbj.process_run_count
  from eod_eom_phy_booking_journal@eka_eoddb eepbj
    where eepbj.process='EOM';

CREATE OR REPLACE VIEW V_BI_DASH_PHY_DEL_STOCK AS
SELECT GMR.CORPORATE_ID,
       DGRD.INTERNAL_STOCK_REF_NO,
       GMR.GMR_REF_NO,
       PCI.CONTRACT_ITEM_REF_NO,
       PCI.CP_NAME,
       PDM.PRODUCT_DESC PRODUCT,
       QAT.QUALITY_NAME,
       DECODE(DGRD.IS_AFLOAT, 'Y', 'IN TRANSIT', 'IN WAREHOUSE') STOCK_STATUS,
       DGRD.BL_NUMBER BL_NUMBER,
       PCI.STRATEGY_NAME STRATEGY,
       NVL(DGRD.NET_WEIGHT, 0) CURRENT_QTY,
       QUM.QTY_UNIT
  FROM DGRD_DELIVERED_GRD        DGRD,
       GMR_GOODS_MOVEMENT_RECORD GMR,
       V_PCI                     PCI,
       AGH_ALLOC_GROUP_HEADER    AGH,
       PDM_PRODUCTMASTER         PDM,
       QUM_QUANTITY_UNIT_MASTER  QUM,
       QAT_QUALITY_ATTRIBUTES    QAT
 WHERE DGRD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
   AND DGRD.INT_ALLOC_GROUP_ID = AGH.INT_ALLOC_GROUP_ID
   AND AGH.INT_SALES_CONTRACT_ITEM_REF_NO =
       PCI.INTERNAL_CONTRACT_ITEM_REF_NO
   AND PCI.PRODUCT_ID = PDM.PRODUCT_ID
   AND DGRD.QUALITY_ID = QAT.QUALITY_ID(+)
   AND DGRD.NET_WEIGHT_UNIT_ID = QUM.QTY_UNIT_ID
   AND DGRD.STATUS = 'ACTIVE'
   AND GMR.IS_DELETED = 'N'
   AND PDM.IS_ACTIVE = 'Y'
   AND QUM.IS_ACTIVE = 'Y'
   AND QAT.IS_ACTIVE = 'Y'
   AND AGH.IS_DELETED = 'N'
   UNION ALL
   SELECT GMR.CORPORATE_ID,
   DGRD.INTERNAL_STOCK_REF_NO,
       GMR.GMR_REF_NO,
       '' CONTRACT_ITEM_REF_NO,
       '' CP_NAME,
       PDM.PRODUCT_DESC PRODUCT,
       QAT.QUALITY_NAME,
       DECODE(DGRD.IS_AFLOAT, 'Y', 'IN TRANSIT', 'IN WAREHOUSE') STOCK_STATUS,
       DGRD.BL_NUMBER BL_NUMBER,
       NULL STRATEGY,
       NVL(DGRD.NET_WEIGHT, 0) CURRENT_QTY,
       QUM.QTY_UNIT
  FROM DGRD_DELIVERED_GRD        DGRD,
       GMR_GOODS_MOVEMENT_RECORD GMR,
       PDM_PRODUCTMASTER         PDM,
       QUM_QUANTITY_UNIT_MASTER  QUM,
       QAT_QUALITY_ATTRIBUTES    QAT
 WHERE DGRD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
   AND GMR.GMR_LATEST_ACTION_ACTION_ID = 'CREATE_RETURN_MATERIAL'
   AND DGRD.QUALITY_ID = QAT.QUALITY_ID(+)
   AND DGRD.NET_WEIGHT_UNIT_ID = QUM.QTY_UNIT_ID
   AND DGRD.PRODUCT_ID = PDM.PRODUCT_ID
   AND DGRD.STATUS = 'ACTIVE'
   AND GMR.IS_DELETED = 'N'
   AND PDM.IS_ACTIVE = 'Y'
   AND QUM.IS_ACTIVE = 'Y'
   AND QAT.IS_ACTIVE = 'Y';

CREATE OR REPLACE VIEW V_BI_DASH_PHY_PFC AS
SELECT T.CORPORATE_ID,
T.CONTRACT_REF_NO,
       T.DEL_ITEM_REF_NO,
       T.PRODUCT_ID,
       T.PRODUCT,
       T.QTY_TO_BE_PRICED,
       T.UOM,
       T.PRICE_DESCRIPTION,
       T.QP_START_DATE
  FROM (SELECT PCM.CORPORATE_ID, PCM.CONTRACT_REF_NO ,
               PCM.CONTRACT_REF_NO || '-' || PCDI.DELIVERY_ITEM_NO DEL_ITEM_REF_NO,
               PCPD.PRODUCT_ID,
               PDM.PRODUCT_DESC PRODUCT,
               SUM(POFH.QTY_TO_BE_FIXED) QTY_TO_BE_PRICED,
               QUM.QTY_UNIT UOM,
               PCBPH.PRICE_DESCRIPTION,
               POFH.QP_START_DATE
          FROM POFH_PRICE_OPT_FIXATION_HEADER POFH,
               POCD_PRICE_OPTION_CALLOFF_DTLS POCD,
               POCH_PRICE_OPT_CALL_OFF_HEADER POCH,
               PCDI_PC_DELIVERY_ITEM          PCDI,
               PCM_PHYSICAL_CONTRACT_MAIN     PCM,
               PCPD_PC_PRODUCT_DEFINITION     PCPD,
               PDM_PRODUCTMASTER              PDM,
               QUM_QUANTITY_UNIT_MASTER       QUM,
               PCBPH_PC_BASE_PRICE_HEADER     PCBPH        
         WHERE POFH.POCD_ID = POCD.POCD_ID
           AND POCD.POCH_ID = POCH.POCH_ID
           AND POCH.PCDI_ID = PCDI.PCDI_ID
           AND PCDI.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
           AND PCM.INTERNAL_CONTRACT_REF_NO = PCPD.INTERNAL_CONTRACT_REF_NO
           AND PCPD.INPUT_OUTPUT = 'INPUT'
           AND PCPD.PRODUCT_ID = PDM.PRODUCT_ID
           AND POCD.QTY_TO_BE_FIXED_UNIT_ID = QUM.QTY_UNIT_ID
           AND PCM.INTERNAL_CONTRACT_REF_NO = PCBPH.INTERNAL_CONTRACT_REF_NO
           AND PCM.CONTRACT_TYPE = 'BASEMETAL'
           AND PCM.IS_ACTIVE = 'Y'
           AND POCH.IS_ACTIVE = 'Y'
           AND POCD.IS_ACTIVE = 'Y'
           AND POFH.IS_ACTIVE = 'Y'
           AND PCPD.IS_ACTIVE = 'Y'
           AND PDM.IS_ACTIVE = 'Y'
           AND QUM.IS_ACTIVE = 'Y'
           AND PCBPH.IS_ACTIVE = 'Y'
         GROUP BY PCM.CORPORATE_ID,
                  PCM.CONTRACT_REF_NO,
                  PCDI.DELIVERY_ITEM_NO,
                  PCPD.PRODUCT_ID,
                  PDM.PRODUCT_DESC,
                  QUM.QTY_UNIT,
                  PCBPH.PRICE_DESCRIPTION,
                  POFH.QP_START_DATE
        UNION ALL
        SELECT PCM.CORPORATE_ID,PCM.CONTRACT_REF_NO,
               PCM.CONTRACT_REF_NO || '-' || PCDI.DELIVERY_ITEM_NO DEL_ITEM_REF_NO,
               PDM_ELE.PRODUCT_ID,
               PDM.PRODUCT_DESC PRODUCT,
               SUM(POFH.QTY_TO_BE_FIXED) QTY_TO_BE_PRICED,
               QUM.QTY_UNIT UOM,
               PCBPH.PRICE_DESCRIPTION,
               POFH.QP_START_DATE
        
          FROM POFH_PRICE_OPT_FIXATION_HEADER POFH,
               POCD_PRICE_OPTION_CALLOFF_DTLS POCD,
               POCH_PRICE_OPT_CALL_OFF_HEADER POCH,
               AML_ATTRIBUTE_MASTER_LIST      AML,
               PDM_PRODUCTMASTER              PDM_ELE,
               PDM_PRODUCTMASTER              PDM,
               PCDI_PC_DELIVERY_ITEM          PCDI,
               PCM_PHYSICAL_CONTRACT_MAIN     PCM,
               QUM_QUANTITY_UNIT_MASTER       QUM,
               PCBPH_PC_BASE_PRICE_HEADER     PCBPH,
               PCBPD_PC_BASE_PRICE_DETAIL     PCBPD
        
         WHERE POFH.POCD_ID = POCD.POCD_ID
           AND POCD.POCH_ID = POCH.POCH_ID
           AND POCH.ELEMENT_ID = AML.ATTRIBUTE_ID
           AND AML.UNDERLYING_PRODUCT_ID = PDM_ELE.PRODUCT_ID
           AND PDM_ELE.PRODUCT_ID = PDM.PRODUCT_ID
           AND POCH.PCDI_ID = PCDI.PCDI_ID
           AND PCDI.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
           AND POCD.QTY_TO_BE_FIXED_UNIT_ID = QUM.QTY_UNIT_ID
           AND PCM.INTERNAL_CONTRACT_REF_NO = PCBPH.INTERNAL_CONTRACT_REF_NO
           AND PCBPH.PCBPH_ID = PCBPD.PCBPH_ID
           AND PCBPD.ELEMENT_ID = AML.ATTRIBUTE_ID
           AND PCM.CONTRACT_TYPE = 'CONCENTRATES'
           AND PCM.IS_ACTIVE = 'Y'
           AND POCH.IS_ACTIVE = 'Y'
           AND POCD.IS_ACTIVE = 'Y'
           AND POFH.IS_ACTIVE = 'Y'
           AND QUM.IS_ACTIVE = 'Y'
           AND PCBPH.IS_ACTIVE = 'Y'
           AND AML.IS_ACTIVE = 'Y'
           AND PDM_ELE.IS_ACTIVE = 'Y'
           AND PDM.IS_ACTIVE = 'Y'
           AND PCBPD.IS_ACTIVE = 'Y'
           AND POFH.QTY_TO_BE_FIXED > 0
         GROUP BY PCM.CORPORATE_ID,
                  PCM.CONTRACT_REF_NO,
                  PCDI.DELIVERY_ITEM_NO,
                  PDM_ELE.PRODUCT_ID,
                  PDM.PRODUCT_DESC,
                  QUM.QTY_UNIT,
                  PCBPH.PRICE_DESCRIPTION,
                  POFH.QP_START_DATE) T
 WHERE T.QP_START_DATE BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + 10 ;--MAKE IT 7

create or replace view v_bi_dash_der_prompt as
select dt.corporate_id,
       dt.derivative_ref_no,
       dt.trade_date,
       dt.traded_on || ' ' || irm.instrument_type derivative_type,
       dim.instrument_name,
       dt.trade_type deal_type,
       drm.prompt_date,
       dt.total_quantity || ' ' || qum.qty_unit quantity,
       dt.trade_price || ' ' || pum.price_unit_name trade_price

  from dt_derivative_trade        dt,
       drm_derivative_master      drm,
       dim_der_instrument_master  dim,
       irm_instrument_type_master irm,
       qum_quantity_unit_master   qum,
       pum_price_unit_master      pum
 where dt.dr_id = drm.dr_id
   and drm.is_deleted = 'N'
   and drm.instrument_id = dim.instrument_id
   and drm.is_deleted = 'N'
   and dim.instrument_type_id = irm.instrument_type_id
   and irm.is_active = 'Y'
   and dt.quantity_unit_id = qum.qty_unit_id
   and dt.trade_price_unit_id = pum.price_unit_id
   and drm.prompt_date between trunc(sysdate) and trunc(sysdate) +10 ; --make it 7


