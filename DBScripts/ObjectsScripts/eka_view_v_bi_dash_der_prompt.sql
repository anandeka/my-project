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
   and drm.prompt_date between trunc(sysdate) and trunc(sysdate) + 10;
