create or replace view v_eodeom_precheck_history as
select t.corporate_id,
       t.trade_date,
       t.dbd_id,
       min(t.start_time) start_time,
       max(t.start_time) end_time,
       max(t.start_time) - min(t.start_time) time_taken
  from epl_eodeom_precheck_log t
 where t.dbd_id is not null
 group by t.corporate_id,
          t.trade_date,
          t.dbd_id
 order by t.trade_date;