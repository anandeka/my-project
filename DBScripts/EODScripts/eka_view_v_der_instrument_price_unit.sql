create or replace view v_der_instrument_price_unit as
with tmp_pum as
(select *
  from pum_price_unit_master pum
 where pum.is_active = 'Y'
   and pum.is_deleted = 'N'),
tmp_ppu as(select *
  from ppu_product_price_units ppu
 where ppu.is_active = 'Y'
   and ppu.is_deleted = 'N')   
select t.instrument_id,
       t.instrument_name,
       t.instrument_type_id,
       t.instrument_type,
       t.product_id,
       t.traded_on,
       t.price_unit_id,
       pum.price_unit_name,
       pum.cur_id price_unit_cur_id,
       pum.weight price_unit_weight,
       pum.weight_unit_id price_unit_weight_unit_id,
       ppu.internal_price_unit_id ppu_price_unit_id,
       ppu_pum.price_unit_name ppu_price_unit_name,
       ppu_pum.cur_id ppu_price_unit_cur_id,
       ppu_pum.weight ppu_price_unit_weight,
       ppu_pum.weight_unit_id ppu_price_unit_weight_unit_id
  from (select dim.instrument_id,
               dim.instrument_name,
               dim.instrument_type_id,
               irm.instrument_type,
               pdd.product_id,
               pdd.traded_on,
               dpu.price_unit_id,
               row_number() over(partition by dim.instrument_id, irm.instrument_type order by dpu.rowid desc) seq
          from div_der_instrument_valuation dpu,
               dim_der_instrument_master    dim,
               irm_instrument_type_master   irm,
               pdd_product_derivative_def   pdd
         where dpu.instrument_id = dim.instrument_id
           and dpu.is_deleted = 'N'
           and dim.is_deleted = 'N'
           and dim.instrument_type_id = irm.instrument_type_id
           and dim.product_derivative_id = pdd.derivative_def_id) t,
       tmp_pum pum,
       tmp_ppu ppu,
       tmp_pum ppu_pum
 where t.seq = 1
   and t.price_unit_id = pum.price_unit_id(+)
   and t.price_unit_id = ppu.price_unit_id(+)
   and t.product_id = ppu.product_id(+)
   and ppu.price_unit_id = ppu_pum.price_unit_id(+)
