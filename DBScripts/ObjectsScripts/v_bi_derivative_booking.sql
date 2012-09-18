DROP VIEW V_BI_DERIVATIVE_BOOKING;

CREATE OR REPLACE FORCE VIEW v_bi_derivative_booking (profit_center_id,
                                                      profit_center_name,
                                                      profit_center_short_name,
                                                      product_id,
                                                      product_desc,
                                                      cp_profile_id,
                                                      counter,
                                                      internal_close_out_ref_no,
                                                      close_out_ref_no,
                                                      trade_ref_no,
                                                      deal_type_id,
                                                      deal_type_name,
                                                      deal_type_display_name,
                                                      invoice_qty,
                                                      invoice_qty_unit,
                                                      trade_cur_code,
                                                      amount,
                                                      invoice_date,
                                                      fx_rate,
                                                      amont_in_base_cur,
                                                      base_cur_id,
                                                      base_cur_code,
                                                      commission_value,
                                                      commission_value_ccy,
                                                      created_by,
                                                      attribute1,
                                                      attribute2,
                                                      attribute3,
                                                      attribute4,
                                                      attribute5,
                                                      Deal_Type
                                                     )
AS
SELECT cpc.profit_center_id, cpc.profit_center_name,
          cpc.profit_center_short_name, pdd.product_id, pdm.product_desc,
          dt.cp_profile_id, phd_cp.companyname counter,
          dcoh.internal_close_out_ref_no, dcoh.close_out_ref_no,
          dt.derivative_ref_no trade_ref_no, dt.deal_type_id,
          dtm.deal_type_name, dtm.deal_type_display_name,
          dcod.quantity_closed invoice_qty, qum_um.qty_unit invoice_qty_unit,
          cm_trade.cur_code trade_cur_code,
          (  (CASE
                 WHEN dt.trade_type = 'Sell'
                    THEN -1
                 ELSE 1
              END)
           * ROUND (dcod.quantity_closed * NVL (ucm.multiplication_factor, 1))
           * dt.trade_price
          ) amount,
          dcoh.close_out_date invoice_date,
          ROUND
             (pkg_general.f_get_converted_currency_amt (dt.corporate_id,
                                                        pum_trade.cur_id,
                                                        ak.base_cur_id,
                                                        SYSDATE,
                                                        1
                                                       ),
              4
             ) fx_rate,
            (  (CASE
                   WHEN dt.trade_type = 'Sell'
                      THEN -1
                   ELSE 1
                END)
             * ROUND (dcod.quantity_closed
                      * NVL (ucm.multiplication_factor, 1)
                     )
             * dt.trade_price
            )
          * ROUND
                 (pkg_general.f_get_converted_currency_amt (dt.corporate_id,
                                                            pum_trade.cur_id,
                                                            ak.base_cur_id,
                                                            SYSDATE,
                                                            1
                                                           ),
                  4
                 ) amont_in_base_cur,
          cm_base.cur_id AS base_cur_id, cm_base.cur_code base_cur_code,
          dcod.clearer_comm_amt commission_value,
          cm_commission.cur_code commission_value_ccy,
          created_akc.login_name created_by, NULL attribute1, NULL attribute2,
          NULL attribute3, NULL attribute4, NULL attribute5,dt.trade_type Deal_Type
     FROM dt_derivative_trade dt,
          ak_corporate ak,
          cpc_corporate_profit_center cpc,
          drm_derivative_master drm,
          dim_der_instrument_master dim,
          pdd_product_derivative_def pdd,
          pdm_productmaster pdm,
          phd_profileheaderdetails phd_cp,
          qum_quantity_unit_master qum_um,
          pum_price_unit_master pum_trade,
          cm_currency_master cm_trade,
          cm_currency_master cm_base,
          dcoh_der_closeout_header dcoh,
          dcod_der_closeout_detail dcod,
          ucm_unit_conversion_master ucm,
          ak_corporate_user created_akc,
          dtm_deal_type_master dtm,
          cm_currency_master cm_commission
    WHERE dt.corporate_id = ak.corporate_id
      AND dt.profit_center_id = cpc.profit_center_id
      AND dt.dr_id = drm.dr_id(+)
      AND drm.instrument_id = dim.instrument_id(+)
      AND dim.product_derivative_id = pdd.derivative_def_id(+)
      AND pdd.product_id = pdm.product_id(+)
      and dt.clearer_profile_id = phd_cp.profileid(+)----------------------
      AND dt.quantity_unit_id = qum_um.qty_unit_id
      AND dt.trade_price_unit_id = pum_trade.price_unit_id(+)
      AND pum_trade.cur_id = cm_trade.cur_id(+)
      AND ak.base_cur_id = cm_base.cur_id(+)
      AND dcoh.internal_close_out_ref_no = dcod.internal_close_out_ref_no
      AND dt.internal_derivative_ref_no = dcod.internal_derivative_ref_no
--   and irm.instrument_type in ('Future', 'Forward')
      AND dt.is_what_if = 'N'
      AND dcoh.is_rolled_back = 'N'
      AND dt.quantity_unit_id = ucm.from_qty_unit_id
      AND pdm.base_quantity_unit = ucm.to_qty_unit_id
      AND dt.created_by = created_akc.user_id
      AND dt.deal_type_id = dtm.deal_type_id
      AND dcod.clearer_comm_cur_id = cm_commission.cur_id(+)
