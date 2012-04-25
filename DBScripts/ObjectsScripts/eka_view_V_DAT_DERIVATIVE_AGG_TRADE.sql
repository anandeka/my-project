CREATE OR REPLACE VIEW V_DAT_DERIVATIVE_AGG_TRADE
AS 
SELECT dat.aggregate_trade_id, dat.aggregate_trade_ref_no,
          dat.leg_1_int_der_ref_no, dat.leg_1_trade_type,
          dat.leg_2_int_der_ref_no, dat.leg_2_trade_type,
          DECODE (dt1.status, 'Settled', 'Closed out', dt1.status) status,
          pkg_general.f_get_corporate_user_name (dt1.created_by) created_by,
          TO_CHAR (dt1.created_date, 'DD-Mon-YYYY') created_date
     FROM dat_derivative_aggregate_trade dat,
          dt_derivative_trade dt1,
          dt_derivative_trade dt2,
          drm_derivative_master drm,
          dim_der_instrument_master dim,
          pm_period_master pm,
          dtm_deal_type_master dtm
    WHERE dat.leg_1_int_der_ref_no = dt1.internal_derivative_ref_no
      AND dat.leg_2_int_der_ref_no = dt2.internal_derivative_ref_no
      AND dt1.is_internal_trade = 'Y'
      AND dt2.is_internal_trade = 'Y'
      AND dt1.status <> 'Delete'
      AND dt2.status <> 'Delete'
      AND dt1.dr_id = drm.dr_id
      AND drm.instrument_id = dim.instrument_id
      AND drm.period_type_id = pm.period_type_id
      AND dtm.deal_type_id = dt1.deal_type_id;

