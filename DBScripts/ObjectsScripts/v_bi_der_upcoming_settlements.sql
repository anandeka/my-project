create or replace view v_bi_der_upcoming_settlements as 
select corporate_id,
       prompt_date,
       instrument_id,
       clearer_name,
       sum(net_position) net_position,
       trade_qty_unit,
       sum(net_position * trade_price) trade_value,
       trade_price_unit,
       settlement_cur_code
  from (select corporate_id,
               internal_derivative_ref_no,
               trade_ref_no,
               external_ref_no,
               instrument_id,
               instrument_name,
               prompt_date,
               clearer_id,
               clearer_name,
               settlement_cur_id,
               settlement_cur_code,
               net_position,
               trade_price,
               trade_qty_unit,
               trade_price_unit,
               dim_expiry_date
          from (select dt.corporate_id,
                       dt.internal_derivative_ref_no,
                       dt.derivative_ref_no trade_ref_no,
                       dt.external_ref_no external_ref_no,
                       dim.instrument_id,
                       dim.instrument_name,
                       drm.prompt_date,
                       phd.profileid clearer_id,
                       phd.companyname clearer_name,
                       dt.settlement_cur_id,
                       cm.cur_code settlement_cur_code,
                       case
                         when dt.trade_type = 'Buy' then
                          dt.open_quantity
                         else
                          -1 * dt.open_quantity
                       end net_position,
                       qum.qty_unit trade_qty_unit,
                       dt.trade_price,
                       pum.price_unit_name trade_price_unit,
                       dim_date.max_date dim_expiry_date
                  from dt_derivative_trade dt,
                       drm_derivative_master drm,
                       dim_der_instrument_master dim,
                       irm_instrument_type_master irm,
                       phd_profileheaderdetails phd,
                       cm_currency_master cm,
                       qum_quantity_unit_master qum,
                       pum_price_unit_master pum,
                       (select dim.instrument_id,
                               f_get_next_n_days(dim.instrument_id, sysdate, 5) max_date
                          from dim_der_instrument_master dim) dim_date
                 where dt.dr_id = drm.dr_id
                   and drm.instrument_id = dim.instrument_id
                   and dim.instrument_type_id = irm.instrument_type_id
                   and dt.clearer_profile_id = phd.profileid
                   and irm.instrument_type = 'Future'
                   and dim.instrument_id = dim_date.instrument_id
                   and cm.cur_id = dt.settlement_cur_id
                   and dt.quantity_unit_id = qum.qty_unit_id
                   and dt.trade_price_unit_id = pum.price_unit_id(+)
                   and dt.status = 'Verified')
         where prompt_date between trunc(sysdate) and dim_expiry_date)
 group by corporate_id,
          prompt_date,
          clearer_name,
          trade_qty_unit,instrument_id,
          trade_price_unit,
          settlement_cur_code
