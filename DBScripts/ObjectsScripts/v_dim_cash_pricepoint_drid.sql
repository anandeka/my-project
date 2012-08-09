create or replace view v_dim_cash_pricepoint_drid as
select t.dr_id,
       t.instrument_id,
       t.price_point_id,
       t.price_point_name,
       t.price_source_id,
       t.price_point_type,
       t.price_source_name,
       t.order_id
  from (select drm.dr_id,
               drm.instrument_id,
               drm.price_point_id,
               pp.price_point_name,
               dip.price_source_id,
               dip.price_point_type,
               ps.price_source_name,
               row_number() over(partition by drm.instrument_id, drm.price_point_id, dip.price_source_id order by drm.instrument_id, drm.price_point_id, dip.price_source_id asc) order_id
          from drm_derivative_master      drm,
               pp_price_point             pp,
               dip_der_instrument_pricing dip,
               ps_price_source            ps
         where drm.price_point_id = pp.price_point_id
           and upper(pp.price_point_name) = 'CASH'
           and drm.is_deleted = 'N'
           and drm.instrument_id = dip.instrument_id
           and dip.is_deleted = 'N'
           and dip.price_point_type = 'PRICE_POINT'
           and dip.price_source_id = ps.price_source_id
           and pp.is_active = 'Y'
           and pp.is_deleted = 'N') t
 where t.order_id = 1
/