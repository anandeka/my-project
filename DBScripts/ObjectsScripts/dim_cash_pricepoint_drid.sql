CREATE OR REPLACE VIEW v_dim_cash_pricepoint_drid (dr_id,
                                                         instrument_id,
                                                         price_point_id,
                                                         price_point_name,
                                                         price_source_id,
                                                         price_point_type,
                                                         price_source_name,
                                                         order_id
                                                        )
AS
   SELECT t.dr_id, t.instrument_id, t.price_point_id, t.price_point_name,
          t.price_source_id, t.price_point_type, t.price_source_name,
          t.order_id
     FROM (SELECT drm.dr_id, drm.instrument_id, drm.price_point_id,
                  pp.price_point_name, dip.price_source_id,
                  dip.price_point_type, ps.price_source_name,
                  ROW_NUMBER () OVER (PARTITION BY drm.instrument_id, drm.price_point_id, dip.price_source_id ORDER BY drm.instrument_id,
                   drm.price_point_id,
                   dip.price_source_id ASC) order_id
             FROM drm_derivative_master drm,
                  pp_price_point pp,
                  dip_der_instrument_pricing dip,
                  ps_price_source ps
            WHERE drm.price_point_id = pp.price_point_id
              AND UPPER (pp.price_point_name) IN ('CASH','SPOT FIX','AM FIXING','AM FIX','FREEMARKET')
              AND drm.is_deleted = 'N'
              AND drm.instrument_id = dip.instrument_id
              AND dip.is_deleted = 'N'
              AND dip.price_point_type = 'PRICE_POINT'
              AND dip.price_source_id = ps.price_source_id
              AND pp.is_active = 'Y'
              AND pp.is_deleted = 'N') t
    WHERE t.order_id = 1;

