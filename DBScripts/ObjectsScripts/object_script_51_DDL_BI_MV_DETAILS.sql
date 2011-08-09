DROP MATERIALIZED VIEW MV_DIM_CM_CURRENCY_MASTER
/
CREATE MATERIALIZED VIEW MV_DIM_CM_CURRENCY_MASTER
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
select cur_id,
       cur_code
  from cm_currency_master
/

DROP MATERIALIZED VIEW MV_DIM_PHD_PROFILEHEADER
/
CREATE MATERIALIZED VIEW MV_DIM_PHD_PROFILEHEADER
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
select profileid,
              companyname FROM  phd_profileheaderdetails
/
DROP MATERIALIZED VIEW MV_DIM_GCD_GROUP_DETAILS
/
CREATE MATERIALIZED VIEW MV_DIM_GCD_GROUP_DETAILS
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
SELECT groupid,
       groupname FROM  GCD_GROUPCORPORATEDETAILS
/

DROP MATERIALIZED VIEW MV_DIM_QAT_QUALITY_ATTRIBUTES
/
CREATE MATERIALIZED VIEW MV_DIM_QAT_QUALITY_ATTRIBUTES
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
SELECT quality_id,
       quality_name FROM  QAT_QUALITY_ATTRIBUTES
/

DROP MATERIALIZED VIEW MV_DIM_AK_CORPORATE
/
CREATE MATERIALIZED VIEW MV_DIM_AK_CORPORATE
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
SELECT corporate_id,
       corporate_name FROM  AK_CORPORATE
/

DROP MATERIALIZED VIEW MV_DIM_PDM_PRODUCTMASTER
/
CREATE MATERIALIZED VIEW MV_DIM_PDM_PRODUCTMASTER
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
SELECT product_id,
       product_desc product_name FROM  pdm_productmaster
/

DROP MATERIALIZED VIEW MV_DIM_CPC_PROFIT_CENTER
/
CREATE MATERIALIZED VIEW MV_DIM_CPC_PROFIT_CENTER
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
SELECT profit_center_id,
       profit_center_name,
       profit_center_short_name FROM  cpc_corporate_profit_center
/

DROP MATERIALIZED VIEW MV_DIM_PDD_PRODUCT_DERIVATIVE
/
CREATE MATERIALIZED VIEW MV_DIM_PDD_PRODUCT_DERIVATIVE
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
SELECT derivative_def_id,
       derivative_def_name FROM  pdd_product_derivative_def
/

DROP MATERIALIZED VIEW MV_DIM_EMT_EXCHANGEMASTER
/
CREATE MATERIALIZED VIEW MV_DIM_EMT_EXCHANGEMASTER
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
SELECT exchange_id,
       exchange_name FROM  emt_exchangemaster
/

DROP MATERIALIZED VIEW MV_DIM_DER_INSTRUMENT_MASTER
/
CREATE MATERIALIZED VIEW MV_DIM_DER_INSTRUMENT_MASTER
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
SELECT instrument_id,
       instrument_name FROM  dim_der_instrument_master
/

DROP MATERIALIZED VIEW MV_DIM_CSS_CORPORATE_STRATEGY
/
CREATE MATERIALIZED VIEW MV_DIM_CSS_CORPORATE_STRATEGY
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
SELECT strategy_id, strategy_name FROM css_corporate_strategy_setup
/

DROP MATERIALIZED VIEW MV_DIM_ITM_INCOTERM_MASTER
/
CREATE MATERIALIZED VIEW MV_DIM_ITM_INCOTERM_MASTER
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
select incoterm_id,
       incoterm
  from itm_incoterm_master
/

DROP MATERIALIZED VIEW MV_DIM_CIM_CITYMASTER
/
CREATE MATERIALIZED VIEW MV_DIM_CIM_CITYMASTER
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
select city_id,
       city_name
  from cim_citymaster
/

DROP MATERIALIZED VIEW MV_DIM_DRM_DERIVATIVE_MASTER
/
CREATE MATERIALIZED VIEW MV_DIM_DRM_DERIVATIVE_MASTER
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
select dr_id,
       prompt_date,
       dr_id_name
  from drm_derivative_master
/

DROP MATERIALIZED VIEW MV_DIM_CYM_COUNTRYMASTER
/
CREATE MATERIALIZED VIEW MV_DIM_CYM_COUNTRYMASTER
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
select country_id,
       country_name
  from cym_countrymaster
/

DROP MATERIALIZED VIEW MV_DIM_BLM_BUSINESS_LINE
/
CREATE MATERIALIZED VIEW MV_DIM_BLM_BUSINESS_LINE
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
select t.business_line_id,
       t.business_line_name
  from blm_business_line_master t
/

DROP MATERIALIZED VIEW MV_DIM_PDTM_PRODUCT_TYPE
/
CREATE MATERIALIZED VIEW MV_DIM_PDTM_PRODUCT_TYPE
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
select product_type_id,
       product_type_name
  from pdtm_product_type_master
/

DROP MATERIALIZED VIEW MV_DIM_AML_ATTRIBUTE_MASTER
/
CREATE MATERIALIZED VIEW MV_DIM_AML_ATTRIBUTE_MASTER
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON COMMIT
WITH PRIMARY KEY
AS 
select attribute_id,
       attribute_name
  from aml_attribute_master_list
/
---------

drop materialized view MV_CASH_FLOW_REPORT
/
create materialized view MV_CASH_FLOW_REPORT
NOCACHE
NOLOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE
START WITH TO_DATE('05-Aug-2011 12:22:18','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE+1/1440 
WITH PRIMARY KEY
as
select iss.corporate_id,
       akc.groupid,
       cpc.profit_center_id,
       cpc.profit_center_name,
       cpc.business_line_id,
       pci.strategy_id strategy_id,
       pci.strategy_name,
       nvl(pcm.partnership_type,'Normal') execution_type,
       pci.product_id,
       pci.product_name,
       pdm.product_type_id,
       (case
         when nvl(pci.contract_type, 'NA') = 'P' then
          'Purchase'
         when nvl(pci.contract_type, 'NA') = 'S' then
          'Sales'
         else
          'NA'
       end) contract_type,
       iss.internal_invoice_ref_no,
       iss.internal_contract_ref_no,
       iss.invoice_ref_no,
       iss.invoice_type,
       iss.invoice_type_name,
       phd.profileid cp_id,
       phd.companyname cp_name,
       pad.city_id,
       cim.city_name,
       pad.country_id,
       cym.country_name,
       round(iss.total_invoice_item_amount, 4) *(case when nvl(iss.recieved_raised_type,'NA')='Raised' then
                 1
            when nvl(iss.recieved_raised_type,'NA')='Received' then
                 -1
       else
            (case when nvl(iss.invoice_type_name,'NA')='ServiceInvoiceReceived' then
                 -1
            else     1 end)
       end) invoice_amount,
       (case
         when iss.payment_due_date is not null then
          to_char(iss.payment_due_date, 'dd/mm/yyyy')
         else
          ''
       end) payment_due_date,
       (case
         when iss.invoice_issue_date is not null then
          to_char(iss.invoice_issue_date, 'dd/mm/yyyy')
         else
          ''
       end) invoice_issue_date,
       iss.cp_ref_no,
       iss.credit_term,
       round(iss.total_amount_to_pay, 4)
       *  (case when nvl(iss.recieved_raised_type,'NA')='Raised' then
                 1
            when nvl(iss.recieved_raised_type,'NA')='Received' then
                 -1
       else
            (case when nvl(iss.invoice_type_name,'NA')='ServiceInvoiceReceived' then
                 -1
            else     1 end)
       end) invoice_amount_in_payin_cur,
       iss.invoice_cur_id invoice_pay_in_cur_id,
       iss.fx_to_base,
       round(iss.total_amount_to_pay, 4) * nvl(iss.fx_to_base, 1) *(case when nvl(iss.recieved_raised_type,'NA')='Raised' then
                 1
            when nvl(iss.recieved_raised_type,'NA')='Received' then
                 -1
       else
            (case when nvl(iss.invoice_type_name,'NA')='ServiceInvoiceReceived' then
                 -1
            else     1 end)
       end) invoice_amount_in_base_cur,
       akc.base_cur_id,
       (case when nvl(iss.recieved_raised_type,'NA')='Raised' then
                 'Receivable'
            when nvl(iss.recieved_raised_type,'NA')='Received' then
                 'Payable'
       else
            (case when nvl(iss.invoice_type_name,'NA')='ServiceInvoiceReceived' then
                 'Payable'
            when nvl(iss.invoice_type_name,'NA')='ServiceInvoiceRaised' then
                 'Receivable'
            else
                 '' end)
       end) payable_receivable
  from is_invoice_summary          iss,
       INCM_INVOICE_CONTRACT_MAPPING incm,
       pcm_physical_contract_main    pcm,
       phd_profileheaderdetails    phd,
       ak_corporate                akc,
       cpc_corporate_profit_center cpc,
       v_pci                       pci,
       pdm_productmaster           pdm,
       pad_profile_addresses       pad,
       bpat_bp_address_type        bpat,
       cim_citymaster              cim,
       cym_countrymaster           cym
 where iss.is_active = 'Y'
   and iss.corporate_id is not null
   and iss.cp_id = phd.profileid
   and iss.internal_invoice_ref_no = incm.internal_invoice_ref_no(+)
   and incm.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   and iss.corporate_id = akc.corporate_id
   and iss.profit_center_id = cpc.profit_center_id(+)
   and iss.internal_contract_ref_no = pci.internal_contract_item_ref_no(+)
   and pci.product_id = pdm.product_id(+)
   and iss.cp_id = pad.profile_id
   and pad.address_type = bpat.bp_address_type_id
   and bpat.bp_address_type = 'Main Address'
   and pad.city_id = cim.city_id(+)
   and pad.country_id = cym.country_id(+)
/

DROP MATERIALIZED VIEW MV_FACT_PHY_INV_VALUATION
/
CREATE MATERIALIZED VIEW MV_FACT_PHY_INV_VALUATION
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
SELECT psu.corporate_id, psu.internal_contract_item_ref_no,psu.STOCK_REF_NO,
 psu.product_id,
       psu.product_name, psu.origin_id, psu.origin_name, psu.quality_id,
       psu.quality_name, psu.stock_qty quantity, psu.qty_unit_id,
       psu.qty_unit, psu.qty_in_base_unit, psu.prod_base_unit_id base_unit_id,
       psu.prod_base_unit base_unit, psu.contract_price,
          psu.price_unit_cur_code
       || '/'
       || psu.price_unit_weight
       || psu.price_unit_weight_unit contract_price_unit,
       psu.contract_premium_value,
       psu.material_cost_in_base_cur contract_value_in_base_cur,
       psu.base_cur_id, psu.base_cur_code, psu.net_m2m_price,
       psu.m2m_price_unit_str m2m_price_unit, psu.m2m_quality_premium,
       psu.m2m_product_premium, psu.m2m_loc_diff_premium,
       pum.price_unit_name premium_price_unit, psu.market_premimum_amt,
       psu.m2m_amt, psu.m2m_amt_cur_id, psu.m2m_amt_cur_code,
       psu.pnl_in_base_cur, psu.prev_day_pnl_in_base_cur,
       psu.trade_day_pnl_in_base_cur, psu.unreal_pnl_in_base_per_unit,
       psu.pnl_per_base_unit, psu.trade_day_pnl_per_base_unit,
       psu.inventory_status, psu.shipment_status, psu.section_name,
       psu.strategy_id, psu.strategy_name, psu.valuation_month,
       psu.contract_type, psu.profit_center_id, psu.val_to_base_rate,
       psu.gmr_ref_no, md.valuation_city_id,
       md.valuation_location valuation_city,
       cim.country_id valuation_country_id,
       md.valuation_location_country valuation_country, psu.warehouse_id,
       psu.warehouse_name, psu.shed_id, psu.shed_name,
       psu.destination_country_id, psu.destination_country,
       psu.destination_city_id, psu.destination_city, psu.vessel_voyage_name,
       psu.price_string, psu.item_delivery_period_string, psu.fixation_method,
       psu.trader_name, psu.trader_id, psu.m2m_amt_per_unit,
       psu.prev_market_price, psu.prev_market_value,
       psu.prev_market_value_cur_id, psu.prev_market_value_cur_code,
       psu.prev_market_premimum_amt, psu.prev_m2m_quality_premium,
       psu.prev_m2m_product_premium, psu.prev_m2m_loc_diff_premium,
       psu.prev_m2m_amt_per_unit
  FROM psu_phy_stock_unrealized@eka_eoddb psu,
       tdc_trade_date_closure@eka_eoddb tdc,
       pum_price_unit_master@eka_eoddb pum,
       (SELECT   tdc.corporate_id, MAX (tdc.trade_date) max_date
            FROM tdc_trade_date_closure@eka_eoddb tdc
           WHERE tdc.process = 'EOD'
        GROUP BY tdc.corporate_id) tdc_max,
       gmr_goods_movement_record@eka_eoddb gmr,
       pcm_physical_contract_main@eka_eoddb pcm,
       md_m2m_daily@eka_eoddb md,
       cim_citymaster@eka_eoddb cim
 WHERE psu.process_id = tdc.process_id
   AND psu.corporate_id = tdc.corporate_id
   AND tdc.process = 'EOD'
   AND tdc.corporate_id = tdc_max.corporate_id
   AND tdc.trade_date = tdc_max.max_date
   AND psu.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
   AND psu.process_id = gmr.process_id(+)
   AND gmr.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   AND gmr.process_id = pcm.process_id(+)
   AND NVL (psu.inventory_status, 'NA') = 'In'
   AND psu.md_id = md.md_id
   AND psu.process_id = md.process_id
   AND psu.base_price_unit_id_in_pum = pum.price_unit_id
   AND md.valuation_city_id = cim.city_id
/

