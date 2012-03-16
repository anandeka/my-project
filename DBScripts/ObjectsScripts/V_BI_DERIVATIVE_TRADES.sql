create or replace view v_bi_derivative_trades as
--this view used in expsoure dashboard
select dt.corporate_id,
       dt.internal_derivative_ref_no,
       dt.derivative_ref_no,
       drm.dr_id,
       drm.dr_id_name,
       pdm.product_id,
       --Hedge  Sum of all Derivative Types with Purpose (Hedge,Net Hedge , Pricing) ( Net will be Purchase - Sales) (Only open Lots)
       --Strategic  Sum of all Derivative Types with Purpose (Speculation, Strategy) ( Net will be Purchase - Sales)  (Only open Lots)
       pdm.product_desc,
       dim.instrument_id,
       dim.instrument_name,
       drm.prompt_date,
       dt.trade_type,
       dt.trade_date,
       dt.deal_type_id,
       dt.profit_center_id,
       cpc.profit_center_name,
       dt.strategy_id,
       css.strategy_name,
       dt.purpose_id,
       dpm.purpose_name,
       round(dt.open_quantity * ucm.multiplication_factor, 5) trade_qty,
       (case
         when nvl(dpm.purpose_name, 'NA') in
              ('Hedging', 'Pricing', 'Net Hedge') then
          round(dt.open_quantity * ucm.multiplication_factor, 5)
         else
          0
       end) hedge_qty,
       (case
         when nvl(dpm.purpose_name, 'NA') in
              ('Speculation', 'Strategy', 'NA') then
          round(dt.open_quantity * ucm.multiplication_factor, 5)
         else
          0
       end) strategic_qty,
       (case
         when dt.trade_type = 'Buy' then
          1
         else
          -1
       end) qty_sign,
       dt.traded_on,
       qum.qty_unit_id,
       qum.qty_unit
  from dt_derivative_trade           dt,
       drm_derivative_master         drm,
       dim_der_instrument_master     dim,
       irm_instrument_type_master    irm,
       pdd_product_derivative_def    pdd,
       dpm_derivative_purpose_master dpm,
       pdm_productmaster             pdm,
       qum_quantity_unit_master      qum,
       ucm_unit_conversion_master    ucm,
       cpc_corporate_profit_center   cpc,
       css_corporate_strategy_setup  css
 where dt.dr_id = drm.dr_id
   and drm.instrument_id = dim.instrument_id
   and dim.instrument_type_id = irm.instrument_type_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.product_id = pdm.product_id
   and dt.status = 'Verified'
   and dt.quantity_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and dt.purpose_id = dpm.purpose_id(+)
   and dt.open_quantity <> 0
   and dt.profit_center_id = cpc.profit_center_id(+)
   and dt.strategy_id = css.strategy_id(+)
/