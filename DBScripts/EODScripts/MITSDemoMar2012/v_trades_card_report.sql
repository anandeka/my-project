create or replace view v_trades_card_report as
select drm.prompt_date,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       drt.product_id temp_product_id,
       drm.instrument_id temp_instrument_id,
       akc.corporate_id,
       akc.corporate_name,
       drt.trade_type buy_sell_contractype_flag,
       -- drt.trade_date tradedate,
       0 phy_long_qty,
       0 phy_short_qty,
       (case
         when upper(drt.trade_type) = 'BUY' then
          (nvl(drt.open_lots, 0))
         else
          0
       end) longlots,
       (case
         when upper(drt.trade_type) = 'SELL' then
          (nvl(drt.open_lots, 0))
         else
          0
       end) shortlots,
       nvl(drt.total_lots, 0) netlots,
       (case
         when upper(drt.trade_type) = 'BUY' then
          ((nvl(drt.open_quantity, 0)))
         else
          0
       end) long_qty,
       (case
         when upper(drt.trade_type) = 'BUY' then
          ((nvl(drt.open_quantity, 0)))
         else
          0
       end) long_qty_mt,
       (case
         when upper(drt.trade_type) = 'SELL' then
          ((nvl(drt.open_quantity, 0)))
         else
          0
       end) short_qty,
       (case
         when upper(drt.trade_type) = 'SELL' then
          ((nvl(drt.open_quantity, 0)))
         else
          0
       end) short_qty_mt
  from dt_derivative_trade         drt,
       drm_derivative_master       drm,
       ak_corporate                akc,
       cpc_corporate_profit_center cpc,
       dim_der_instrument_master   dim,
       irm_instrument_type_master  irm
 where drt.dr_id = drm.dr_id
   and drt.corporate_id = akc.corporate_id
   and drt.profit_center_id = cpc.profit_center_id(+)
   and drm.instrument_id = dim.instrument_id(+)
   and dim.instrument_type_id = irm.instrument_type_id(+)
   and upper(nvl(drt.status, 'NA')) in ('NONE', 'VERIFIED')
   and drm.is_expired = 'N'
   and drm.prompt_date is not null
   and drt.traded_on = 'Exchange'
   and upper(irm.instrument_type) = 'FUTURE'
union all
select vcc.calender_date prompt_date,
       vtc.profit_center_name,
       vtc.profit_center_short_name,
       vtc.product_id temp_product_id,
       vtc.instrument_id temp_instrument_id,
       vtc.corporate_id,
       akc.corporate_name,
       ((case
         when vtc.contract_type = 'P' then
          'Buy'
         else
          'Sell'
       end)) buy_sell_contractype_flag,
       sum((case
             when vtc.contract_type = 'P' then
              vtc.price_fixed_qty / vtc.no_of_days
             else
              0
           end)) phy_long_qty,
       sum((case
             when vtc.contract_type = 'S' then
              vtc.price_fixed_qty / vtc.no_of_days
             else
              0
           end)) phy_short_qty,
       0 longlots,
       0 shortlots,
       0 netlots,
       0 long_qty,
       0 long_qty_mt,
       0 short_qty,
       0 short_qty_mt
  from v_traders_card_expected_qp vtc,
       v_traders_card_calender    vcc,
       ak_corporate               akc
 where vtc.instrument_id = vcc.instrument_id
   and vcc.calender_date >= vtc.start_price_date
   and vcc.calender_date <= vtc.end_price_date
   and vcc.is_holiday = 'N'
   and vtc.corporate_id = akc.corporate_id
 group by vcc.calender_date,
          vtc.profit_center_name,
          vtc.profit_center_short_name,
          vtc.product_id,
          vtc.instrument_id,
          vtc.corporate_id,
          akc.corporate_name,
          (case
            when vtc.contract_type = 'P' then
             'Buy'
            else
             'Sell'
          end)
