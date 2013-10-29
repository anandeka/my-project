create or replace view v_product_instrument as
select pdd.product_id,
       dim.instrument_id
  from dim_der_instrument_master    dim,
       pdd_product_derivative_def   pdd,
       div_der_instrument_valuation div,
       irm_instrument_type_master   irm
 where dim.product_derivative_id = pdd.derivative_def_id
   and dim.instrument_id = div.instrument_id
   and div.is_deleted = 'N'
   and irm.instrument_type_id = dim.instrument_type_id
   and irm.is_deleted = 'N'
   and pdd.is_deleted = 'N'
   and dim.is_deleted = 'N'
   and irm.instrument_type = 'Future';
