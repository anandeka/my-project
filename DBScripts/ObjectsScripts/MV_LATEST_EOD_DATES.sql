DROP TABLE MV_LATEST_EOD_DATES;
DROP MATERIALIZED VIEW MV_LATEST_EOD_DATES;
CREATE MATERIALIZED VIEW MV_LATEST_EOD_DATES
REFRESH FORCE ON DEMAND as
select aa.process,
       aa.corporate_id,
       aa.trade_date lastest_eod,
       aa.process_id latest_process_id,
       bb.trade_date previous_eod,
       bb.process_id previous_process_id
  from (select process,
               corporate_id,
               trade_date,
               process_id
          from (select process,
                       corporate_id,
                       trade_date,
                       process_id,
                       rank() over(partition by process, corporate_id order by trade_date desc) rank
                  from tdc_trade_date_closure@eka_eoddb)
         where rank in (1, 2)) aa,
       (select process,
               corporate_id,
               trade_date,
               process_id
          from (select process,
                       corporate_id,
                       trade_date,
                       process_id,
                       rank() over(partition by process, corporate_id order by trade_date desc) rank
                  from tdc_trade_date_closure@eka_eoddb)
         where rank in (1, 2)) bb
 where aa.process = bb.process
   and aa.corporate_id = bb.corporate_id
   and aa.trade_date > bb.trade_date
   and aa.process_id <> bb.process_id
   and aa.process = 'EOD'
/
------------
