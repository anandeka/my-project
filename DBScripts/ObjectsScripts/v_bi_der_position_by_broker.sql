create or replace view v_bi_der_position_by_broker as
select dt.corporate_id,
       pdm.product_id,
       pdm.product_desc,
       pdd.derivative_def_name,
       dim.instrument_id,
       irm.instrument_type,
       dim.instrument_name,
       phd.profileid broker_id,
       phd.companyname broker_name,
       sum(case
             when dt.trade_type = 'Buy' then
              dt.open_quantity * ucm.multiplication_factor
             else
              0
           end) long_qty,
       sum(case
             when dt.trade_type = 'Sell' then
              dt.open_quantity * ucm.multiplication_factor
             else
              0
           end) short_qty,
       qum.qty_unit trade_qty_unit
  from dt_derivative_trade        dt,
       drm_derivative_master      drm,
       dim_der_instrument_master  dim,
       irm_instrument_type_master irm,
       pdd_product_derivative_def pdd,
       pdm_productmaster          pdm,
       qum_quantity_unit_master   qum,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master   qum_dt,
       phd_profileheaderdetails   phd
 where dt.dr_id = drm.dr_id
   and drm.instrument_id = dim.instrument_id
   and dim.instrument_type_id = irm.instrument_type_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.product_id = pdm.product_id
   and dt.status = 'Verified'
   and dt.quantity_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and dt.quantity_unit_id = qum_dt.qty_unit_id
   and dt.clearer_profile_id = phd.profileid
   and dt.open_quantity <> 0
  and drm.prompt_date > trunc(sysdate)
 group by dt.corporate_id,
          dim.instrument_id,
          pdm.product_id,
          pdm.product_desc,
          pdd.derivative_def_name,
          irm.instrument_type,
          phd.profileid,
          phd.companyname,
          dim.instrument_name,
          qum.qty_unit 
