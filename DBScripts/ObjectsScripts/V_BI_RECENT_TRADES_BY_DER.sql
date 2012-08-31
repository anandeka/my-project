CREATE OR REPLACE VIEW V_BI_RECENT_TRADES_BY_DER AS
select t2.corporate_id,
       t2.product_id,
       t2.product_name,
       t2.instrument_id,
       t2.contract_ref_no,
       t2.trade_type,
       to_date(t2.issue_date, 'dd-Mon-RRRR') issue_date,
       t2.item_qty position_quantity,
       t2.base_quantity_unit qty_unit_id,
       t2.qty_unit base_qty_unit
  from (select t1.contract_ref_no,
               t1.corporate_id,
               t1.instrument_id,
               t1.created_date,
               t1.product_id,
               t1.product_name,
               t1.trade_type,
               t1.base_quantity_unit,
               t1.item_qty,
               t1.qty_unit,
               t1.issue_date,
               row_number() over(partition by t1.corporate_id, t1.product_id order by t1.created_date desc) order_seq
          from (select dt.derivative_ref_no contract_ref_no,
                       dt.corporate_id,
                       tab.created_date,
                       dim.instrument_id,
                       tab.trade_date issue_date,
                       decode(dt.trade_type,
                              'Buy',
                              'Derivative Buy',
                              'Sell',
                              'Derivative Sell',
                              null) trade_type,
                       pdm.product_id,
                       pdm.product_desc product_name,
                       pdm.base_quantity_unit,
                       round(dt.open_quantity * ucm.multiplication_factor, 5) item_qty,
                       qum.qty_unit
                  from dt_derivative_trade dt,
                       drm_derivative_master drm,
                       dim_der_instrument_master dim,
                       irm_instrument_type_master irm,
                       pdd_product_derivative_def pdd,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       ucm_unit_conversion_master ucm,
                       (select substr(max(case
                                            when dtul.derivative_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dtul.derivative_ref_no
                                          end),
                                      24) derivative_ref_no,
                               substr(max(case
                                            when dtul.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dtul.corporate_id
                                          end),
                                      24) corporate_id,
                               substr(max(case
                                            when dtul.internal_derivative_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dtul.internal_derivative_ref_no
                                          end),
                                      24) internal_derivative_ref_no,
                               substr(max(case
                                            when dtul.trade_date is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dtul.trade_date
                                          end),
                                      24) trade_date,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from dtul_derivative_trade_ul dtul,
                               axs_action_summary       axs
                         where dtul.internal_action_ref_no =
                               axs.internal_action_ref_no
                         group by dtul.internal_derivative_ref_no) tab
                 where dt.dr_id = drm.dr_id
                   and tab.internal_derivative_ref_no =
                       dt.internal_derivative_ref_no
                   and drm.instrument_id = dim.instrument_id
                   and dim.instrument_type_id = irm.instrument_type_id
                   and dim.product_derivative_id = pdd.derivative_def_id
                   and pdd.product_id = pdm.product_id
                   and dt.status = 'Verified'
                   and dt.quantity_unit_id = ucm.from_qty_unit_id
                   and pdm.base_quantity_unit = ucm.to_qty_unit_id
                   and pdm.base_quantity_unit = qum.qty_unit_id
                   and dt.open_quantity <> 0
                --Bug 63342 fix end            
                ) t1
         order by t1.product_id,
                  t1.created_date) t2
 where t2.order_seq < 6
 order by t2.corporate_id,
          t2.product_id
