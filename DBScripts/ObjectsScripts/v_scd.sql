create or replace view v_scd as
select scd.sub_cur_id,
       cm.cur_id main_cur_id,
       cm.cur_code main_cur_code,
       cm.cur_name main_cur_name,
       scd.factor sub_to_main_factor
  from scd_sub_currency_detail scd,
       cm_currency_master      cm
 where scd.is_deleted = 'N'
   and scd.cur_id = cm.cur_id
/