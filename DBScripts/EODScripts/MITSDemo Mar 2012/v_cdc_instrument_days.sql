create or replace view v_cdc_instrument_days
as
-- this view will provide the last 9 working days for the LME exhange instruments
select tt.instrument_id,
       tt.work_day,
       tt.dispay_order
from (select t.instrument_id,
       t.work_day,
       dense_rank() over(partition by t.instrument_id order by t.work_day desc) dispay_order
  from (select dim.instrument_id,
               f_get_working_day(trunc(sysdate - rm), dim.instrument_id) work_day
          from dim_der_instrument_master dim,
               pdd_product_derivative_def pdd,
               emt_exchangemaster emt,
               irm_instrument_type_master irm,
               (select (rownum) rm from user_objects where rownum < 15) sss
         where emt.exchange_id = pdd.exchange_id
           and pdd.derivative_def_id = dim.product_derivative_id
           and emt.exchange_code = 'LME'
           and irm.instrument_type_id = dim.instrument_type_id
           and irm.instrument_type = 'Future'
           ) t)tt
where tt.dispay_order <=9
group by tt.instrument_id,
       tt.work_day,
       tt.dispay_order
order by 1,3       
