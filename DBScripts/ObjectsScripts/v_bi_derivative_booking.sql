CREATE OR REPLACE VIEW v_bi_derivative_booking 
AS
select cpc.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       pdd.product_id,
       pdm.product_desc,
       dt.cp_profile_id,
       phd_cp.companyname counter,
       dcoh.internal_close_out_ref_no,
       dcoh.close_out_ref_no,
       dt.derivative_ref_no trade_ref_no,
       dt.deal_type_id,
       dtm.deal_type_name,
       dtm.deal_type_display_name,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end)*dcod.quantity_closed invoice_qty,
       qum_um.qty_unit invoice_qty_unit,
       cm_trade.cur_code trade_cur_code,
       ((case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) *
       round(dcod.quantity_closed * nvl(ucm.multiplication_factor, 1)) *
       dt.trade_price) amount,
       dcoh.close_out_date invoice_date,
       round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                      pum_trade.cur_id,
                                                      ak.base_cur_id,
                                                      dcoh.close_out_date,
                                                      1),
             4) fx_rate,
       ((case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) *
       round(dcod.quantity_closed * nvl(ucm.multiplication_factor, 1)) *
       dt.trade_price) * round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                                        pum_trade.cur_id,
                                                                        ak.base_cur_id,
                                                                        dcoh.close_out_date,
                                                                        1),
                               4) amont_in_base_cur,
       cm_base.cur_id as base_cur_id,
       cm_base.cur_code base_cur_code,
       (case
         when dcod.clearer_comm_amt is null or
              nvl(dcod.clearer_comm_amt, 0) = 0 then
          (case
         when dt.clearer_comm_amt is not null then
          round((dt.clearer_comm_amt / dt.total_quantity) *
                dcod.quantity_closed,
                4)
         else
          0
       end) else dt.clearer_comm_amt end) commission_value,
       
       round( (case
         when dcod.clearer_comm_amt is null or
              nvl(dcod.clearer_comm_amt, 0) = 0 then
          (case
         when dt.clearer_comm_amt is not null then
          round((dt.clearer_comm_amt/ dt.total_quantity) *
                dcod.quantity_closed,
                4)
         else
          0
       end) else dt.clearer_comm_amt end)*pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                                        dcod.clearer_comm_cur_id,
                                                                        ak.base_cur_id,
                                                                        dcoh.close_out_date,
                                                                        1) ,4)commission_value_base,
       (case
         when dcod.clearer_comm_amt is null or
              nvl(dcod.clearer_comm_amt, 0) = 0 then
          cm_comm_dt.cur_code
         else
          cm_commission.cur_code
       end) commission_value_ccy,
       (gab.firstname || ' ' || gab.lastname) created_by,
       bst.attribute_value_1 attribute1,
       bst.attribute_value_2 attribute2,
       bst.attribute_value_3 attribute3,
       bst.attribute_value_4 attribute4,
       bst.attribute_value_5 attribute5,
       dt.trade_type deal_type,
       dt.corporate_id,
       ak.corporate_name
  from dt_derivative_trade         dt,
       ak_corporate                ak,
       cpc_corporate_profit_center cpc,
       drm_derivative_master       drm,
       dim_der_instrument_master   dim,
       pdd_product_derivative_def  pdd,
       pdm_productmaster           pdm,
       phd_profileheaderdetails    phd_cp,
       qum_quantity_unit_master    qum_um,
       pum_price_unit_master       pum_trade,
       cm_currency_master          cm_trade,
       cm_currency_master          cm_base,
       dcoh_der_closeout_header    dcoh,
       dcod_der_closeout_detail    dcod,
       ucm_unit_conversion_master  ucm,
       ak_corporate_user           created_akc,
       dtm_deal_type_master        dtm,
       cm_currency_master          cm_commission,
       cm_currency_master          cm_comm_dt,
       gab_globaladdressbook       gab,
       bct_broker_commission_types bct,
       
       v_bi_strategy_attribute bst
 where dt.corporate_id = ak.corporate_id
   and dt.profit_center_id = cpc.profit_center_id
   and dt.dr_id = drm.dr_id(+)
   and drm.instrument_id = dim.instrument_id(+)
   and dim.product_derivative_id = pdd.derivative_def_id(+)
   and pdd.product_id = pdm.product_id(+)
   and dt.clearer_profile_id = phd_cp.profileid(+) ----------------------
   and dt.quantity_unit_id = qum_um.qty_unit_id
   and dt.trade_price_unit_id = pum_trade.price_unit_id(+)
   and pum_trade.cur_id = cm_trade.cur_id(+)
   and ak.base_cur_id = cm_base.cur_id(+)
   and dcoh.internal_close_out_ref_no = dcod.internal_close_out_ref_no
   and dt.internal_derivative_ref_no = dcod.internal_derivative_ref_no
      --   and irm.instrument_type in ('Future', 'Forward')
   and dt.is_what_if = 'N'
   and dcoh.is_rolled_back = 'N'
   and dt.quantity_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and dt.created_by = created_akc.user_id
   and dt.deal_type_id = dtm.deal_type_id
   and dcod.clearer_comm_cur_id = cm_commission.cur_id(+)
   and dt.clearer_comm_type_id = bct.commission_type_id(+)
   and bct.currency_id = cm_comm_dt.cur_id(+)
   and created_akc.gabid = gab.gabid
   and dt.strategy_id = bst.startegy_id(+)
