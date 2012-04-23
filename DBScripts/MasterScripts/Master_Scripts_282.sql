update RPC_RF_PARAMETER_CONFIG rpc
set RPC.REPORT_PARAMETER_NAME = 'ProfitCenter'
where RPC.LABEL_ID = 'RFC86PHY02'
and RPC.REPORT_PARAMETER_NAME = 'Profit Center';
commit;