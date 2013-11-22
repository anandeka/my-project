create or replace view v_dim_price_point_pricesource as
select dip.instrument_id,
       dip.price_source_id
  from dip_der_instrument_pricing dip
 where dip.is_deleted = 'N'
   and dip.price_point_type = 'PRICE_POINT'
group by dip.instrument_id,
       dip.price_source_id
          
