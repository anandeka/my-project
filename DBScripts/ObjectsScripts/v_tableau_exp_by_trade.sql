create or replace view v_tableau_exp_by_trade as
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       'Physical' trade_type,
       (case
         when pcm1.purchase_sales = 'S' then
          'Sell'
         else
          'Buy'
       end) contract_type,
       pcm.price_date,
       null pcdi_id, -- pcm.pcdi_id,
       pcm.product_id,
       pcm.productname,
       pcm.instrument_id,
       pcm.instrument_name,
       sum((case
             when pcm1.purchase_sales = 'S' then
              -1
             else
              1
           end) * pcm.price_fixed_qty) price_fixed_qty,
       sum((case
             when pcm1.purchase_sales = 'S' then
              -1
             else
              1
           end) * pcm.unpriced_qty) unpriced_qty,
       0 hedge_qty,
       0 strategic_qty,
       pcm.qty_unit_id,
       pcm.qty_unit,
       css.strategy_name strategy,
       cpc.profit_center_name profit_center
  from v_bi_exposure_by_trade       pcm,
       pcm_physical_contract_main   pcm1,
       pcpd_pc_product_definition   pcpd,
       cpc_corporate_profit_center  cpc,
       css_corporate_strategy_setup css
 where pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.strategy_id = css.strategy_id
   and pcpd.is_active = 'Y'
   and pcm.internal_contract_ref_no = pcm1.internal_contract_ref_no(+)
 group by pcm.corporate_id,
          pcm.contract_ref_no,
          pcm1.purchase_sales,
          pcm.internal_contract_ref_no,
          pcm.price_date,
          pcm.product_id,
          pcm.productname,
          pcm.instrument_id,
          pcm.instrument_name,
          pcm.qty_unit_id,
          pcm.qty_unit,
          css.strategy_name,
          cpc.profit_center_name
union all
select drt.corporate_id,
       drt.derivative_ref_no contract_ref_no,
       null internal_contract_ref_no,
       'Derivative' trade_type,
       drt.trade_type contract_type,
       drt.prompt_date price_date,
       null pcdi_id,
       drt.product_id,
       drt.product_desc product_name,
       drt.instrument_id,
       drt.instrument_name,
       0 price_fixed_qty,
       0 unpriced_qty,
       sum(drt.hedge_qty * drt.qty_sign) hedge_qty,
       sum(drt.strategic_qty * drt.qty_sign) strategic_qty,
       drt.qty_unit_id,
       drt.qty_unit,
       drt.strategy_name strategy,
       drt.profit_center_name profit_center
  from v_bi_derivative_trades drt
 group by drt.corporate_id,
          drt.derivative_ref_no,
          drt.prompt_date,
          drt.product_id,
          drt.trade_type,
          drt.product_desc,
          drt.instrument_id,
          drt.instrument_name,
          drt.qty_unit_id,
          drt.qty_unit,
          drt.strategy_name,
          drt.profit_center_name
/