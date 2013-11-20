create or replace view v_eod_tdc as
select corporate_id,
          trade_date,
          created_date,
          closed_by,
          process_id,
          process,
          process_run_count
     from tdc_trade_date_closure@eka_eoddb
/
