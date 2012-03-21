create or replace view v_bi_exposure_by_product as
select t.corporate_id,
       t.product_id,
       t.product_name,
       t.instrument_id,
       t.instrument_name,
       sum(t.price_fixed_quantity) price_fixed_quantity,
       sum(t.unpriced_quantity) unpriced_quantity,
       sum(t.net_physical_quantity) net_physical_quantity,
       sum(t.hedge_quantity) hedge_quantity,
       sum(t.strategic_quantity) strategic_quantity,
       sum(t.net_derivative_quantity) net_derivative_quantity,
       sum(t.net_risk_quantity) net_risk_quantity,
       t.base_qty_unit_id,
       t.base_qty_unit,
       cm.cur_code || '/' || t.base_qty_unit quotes_unit,
       cm.cur_id base_cur_id,
       cm.cur_code base_cur_code
  from (select vph.corporate_id,
               vph.product_id,
               vph.productname product_name,
               vph.instrument_id,
               vph.instrument_name,
               (sum(vph.price_fixed_qty * (case
                      when pcm.purchase_sales = 'S' then
                       -1
                      else
                       1
                    end))) price_fixed_quantity,
               (sum(vph.unpriced_qty * (case
                      when pcm.purchase_sales = 'S' then
                       -1
                      else
                       1
                    end))) unpriced_quantity,
               (sum(vph.price_fixed_qty * (case
                      when pcm.purchase_sales = 'S' then
                       -1
                      else
                       1
                    end)) + sum(vph.unpriced_qty * (case
                                   when pcm.purchase_sales = 'S' then
                                    -1
                                   else
                                    1
                                 end))) net_physical_quantity,
               0 hedge_quantity,
               0 strategic_quantity,
               0 net_derivative_quantity,
               (sum(vph.price_fixed_qty * (case
                      when pcm.purchase_sales = 'S' then
                       -1
                      else
                       1
                    end)) + sum(vph.unpriced_qty * (case
                                   when pcm.purchase_sales = 'S' then
                                    -1
                                   else
                                    1
                                 end))) net_risk_quantity,
               vph.qty_unit_id base_qty_unit_id,
               vph.qty_unit base_qty_unit
          from v_bi_exposure_by_trade     vph,
               pcm_physical_contract_main pcm
         where vph.internal_contract_ref_no =
               pcm.internal_contract_ref_no(+)
         group by vph.corporate_id,
                  vph.product_id,
                  vph.productname,
                  vph.instrument_id,
                  vph.instrument_name,
                  vph.qty_unit_id,
                  vph.qty_unit
        union all
        select drt.corporate_id,
               drt.product_id,
               drt.product_desc product_name,
               drt.instrument_id,
               drt.instrument_name,
               0 price_fixed_quantity,
               0 unpriced_quantity,
               0 net_physical_quantity,
               sum(drt.hedge_qty * drt.qty_sign) hedge_quantity,
               sum(drt.strategic_qty * drt.qty_sign) strategic_quantity,
               sum(drt.trade_qty * drt.qty_sign) net_derivative_quantity,
               sum(drt.trade_qty * drt.qty_sign) net_risk_quantity,
               drt.qty_unit_id base_qty_unit_id,
               drt.qty_unit base_qty_unit
          from v_bi_derivative_trades drt
         group by drt.corporate_id,
                  drt.product_id,
                  drt.product_desc,
                  drt.qty_unit_id,
                  drt.qty_unit,
                  drt.instrument_id,
                  drt.instrument_name) t,
       ak_corporate akc,
       cm_currency_master cm
 where t.corporate_id = akc.corporate_id
   and akc.base_cur_id = cm.cur_id
 group by t.corporate_id,
          t.product_id,
          t.product_name,
          t.instrument_id,
          t.instrument_name,
          t.base_qty_unit_id,
          t.base_qty_unit,
          cm.cur_id,
          cm.cur_code
