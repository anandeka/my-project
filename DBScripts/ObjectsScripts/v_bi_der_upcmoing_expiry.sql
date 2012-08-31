create or replace view v_bi_der_upcmoing_expiry as 
select corporate_id,
       internal_derivative_ref_no,
       trade_ref_no,
       external_ref_no,
       expiry_date,
       instrument_id,
       instrument_name,
       buy_sell,
       clearer_id,
       clearer_name,
       strike_price,
       strike_price_name,
       dim_expiry_date
  from (select dt.corporate_id,
               dt.internal_derivative_ref_no,
               dt.derivative_ref_no trade_ref_no,
               dt.external_ref_no external_ref_no,
               drm.expiry_date,
               dim.instrument_id,
               dim.instrument_name,
               dt.trade_type buy_sell,
               phd.profileid clearer_id,
               phd.companyname clearer_name,
               dt.strike_price,
               pum.price_unit_name strike_price_name,
               dim_date.max_date dim_expiry_date
          from dt_derivative_trade dt,
               drm_derivative_master drm,
               dim_der_instrument_master dim,
               irm_instrument_type_master irm,
               phd_profileheaderdetails phd,
               pum_price_unit_master pum,
               (select dim.instrument_id,
                       f_get_next_n_days(dim.instrument_id, sysdate, 5) max_date
                  from dim_der_instrument_master dim) dim_date
         where dt.dr_id = drm.dr_id
           and drm.instrument_id = dim.instrument_id
           and dim.instrument_type_id = irm.instrument_type_id
           and dt.clearer_profile_id = phd.profileid
           and dt.strike_price_unit_id = pum.price_unit_id
           and irm.instrument_type in ('OTC Put Option', 'OTC Call Option')
           and dim.instrument_id = dim_date.instrument_id
           and dt.status = 'Verified')
 where expiry_date between trunc(sysdate) and dim_expiry_date
