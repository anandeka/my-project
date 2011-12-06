CREATE INDEX IDX_EODEOM1 ON eodeom_derivative_quote_detail (corporate_id,dbd_id)
/
CREATE INDEX IDX_DQ1 ON dq_derivative_quotes (dbd_id)
/
CREATE INDEX IDX_DQD1 ON dqd_derivative_quote_detail (dbd_id)
/
CREATE INDEX IDX_AXS1 ON axs_action_summary (dbd_id)
/
CREATE INDEX IDX_DBD1 ON dbd_database_dump (dbd_id)
/
CREATE INDEX IDX_TPD1 ON tpd_trade_pnl_daily (process_id)
/
CREATE INDEX IDX_EDI1 ON edi_expired_dr_id (corporate_id,trade_date,process)
/
CREATE INDEX IDX_ECI1 ON eci_expired_ct_id (corporate_id,trade_date,process)
/
CREATE INDEX IDX_TMEF1 ON tmef_temp_eod_fx_rate (corporate_id,trade_date)
/
CREATE INDEX IDX_DQ2 ON dq_derivative_quotes (PROCESS_ID,CORPORATE_ID)
/
CREATE INDEX IDX_DQD2 ON dqd_derivative_quote_detail (PROCESS_ID)
/
create index IDX_TDC2 on TDC_TRADE_DATE_CLOSURE (PROCESS_ID)
/
create index IDX_TDC3 on TDC_TRADE_DATE_CLOSURE (PROCESS_ID,CORPORATE_ID)
/
