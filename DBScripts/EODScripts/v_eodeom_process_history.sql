create or replace view v_eodeom_process_history as
select t.corporate_id,
       t.trade_date,
       t.process_id,
       min(t.start_time) start_time,
       max(t.start_time) end_time,
       max(t.start_time) - min(t.start_time) time_taken
  from epl_eodeom_process_log t
 where t.process_id is not null
--order by t.trade_date
 group by t.corporate_id,
          t.trade_date,
          t.process_id
 order by t.trade_date;