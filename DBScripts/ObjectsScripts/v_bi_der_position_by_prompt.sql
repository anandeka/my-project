create or replace view v_bi_der_position_by_prompt as
select tt.corporate_id,
       tt.product_id,
       tt.product_desc,
       tt.derivative_def_name,
       tt.instrument_id,
       tt.instrument_type,
       tt.instrument_name,
       tt.forward_month,
       tt.forward_month_order,
       sum(tt.long_qty) long_qty,
       sum(tt.short_qty) short_qty,
       tt.trade_qty_unit
  from (select akc.corporate_id,
               'Dummy' section_name,
               pdm.product_id,
               pdm.product_desc,
               pdd.derivative_def_name,
               dim.instrument_id,
               irm.instrument_type,
               dim.instrument_name,
               (case
                 when dpm.month_count <= 2 then
                  to_char(add_months(sysdate, dpm.month_count), 'Mon')
                 else
                  'Beyond'
               end) forward_month,
               (dpm.month_count + 1) forward_month_order,
               0 long_qty,
               0 short_qty,
               qum.qty_unit trade_qty_unit
          from dim_der_instrument_master dim,
               irm_instrument_type_master irm,
               pdd_product_derivative_def pdd,
               pdm_productmaster pdm,
               qum_quantity_unit_master qum,
               ak_corporate akc,
               (select (rownum - 1) month_count
                  from user_objects
                 where rownum < 5) dpm
         where dim.instrument_type_id = irm.instrument_type_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.product_id = pdm.product_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           and dim.is_active = 'Y'
           and dim.is_deleted = 'N'
           and dim.is_currency_curve = 'N'
           and akc.is_active = 'Y'
           and akc.is_internal_corporate = 'N'
         group by akc.corporate_id,
                  pdm.product_id,
                  pdm.product_desc,
                  pdd.derivative_def_name,
                  dim.instrument_id,
                  irm.instrument_type,
                  dpm.month_count,
                  dim.instrument_name,
                  qum.qty_unit
        union all
        select t.corporate_id,
               t.section_name,
               t.product_id,
               t.product_desc,
               t.derivative_def_name,
               t.instrument_id,
               t.instrument_type,
               t.instrument_name,
               (case
                 when t.period_date <= last_day(trunc(sysdate)) then
                  to_char(sysdate, 'Mon')
                 else
                  (case
                 when to_char(t.period_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 1), 'Mon-yyyy') then
                  to_char(add_months(sysdate, 1), 'Mon')
                 when to_char(t.period_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 2), 'Mon-yyyy') then
                  to_char(add_months(sysdate, 2), 'Mon')
                 else
                  'Beyond'
               end) end) forward_month,
               (case
                 when t.period_date <= last_day(trunc(sysdate)) then
                  1
                 else
                  (case
                 when to_char(t.period_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 1), 'Mon-yyyy') then
                  2
                 when to_char(t.period_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 2), 'Mon-yyyy') then
                  3
                 else
                  4
               end) end) forward_month_order,
               t.long_qty,
               t.short_qty,
               t.trade_qty_unit
          from (select dt.corporate_id,
                       'Online' section_name,
                       pdm.product_id,
                       pdm.product_desc,
                       pdd.derivative_def_name,
                       dim.instrument_id,
                       irm.instrument_type,
                       dim.instrument_name,
                       (case
                         when drm.period_date is null then
                          case
                         when drm.period_month is not null and
                              drm.period_year is not null then
                          to_date('01-' || drm.period_month || '-' ||
                                  drm.period_year,
                                  'dd-Mon-yyyy')
                         else
                          drm.prompt_date
                       end else drm.period_date end) period_date,
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
                       qum_quantity_unit_master   qum_dt
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
                   and dt.open_quantity <> 0
                   and drm.prompt_date > trunc(sysdate)
                 group by dt.corporate_id,
                          dim.instrument_id,
                          pdm.product_id,
                          pdm.product_desc,
                          drm.period_date,
                          drm.period_month,
                          drm.period_year,
                          drm.prompt_date,
                          drm.period_date,
                          pdd.derivative_def_name,
                          irm.instrument_type,
                          dim.instrument_name,
                          qum.qty_unit) t) tt
group by tt.corporate_id,
       tt.product_id,
       tt.product_desc,
       tt.derivative_def_name,
       tt.instrument_id,
       tt.instrument_type,
       tt.instrument_name,
       tt.forward_month,
      tt.forward_month_order,
       tt.trade_qty_unit 
