------------------------------------------------------------------------------------------------------
--::                        		              Bug: 74261 - Issue:2                   			          ::--
------------------------------------------------------------------------------------------------------
begin
for rc in 
    (select 
        akc.corporate_id corp_id, akc.corporate_name 
        from ak_corporate akc where akc.is_internal_corporate = 'N')
loop
    dbms_output.put_line('Modifying RPC data of '||rc.corporate_name||' Corporate...');
    
    delete from rpc_rf_parameter_config
    where report_id = '247'
    and label_id = 'RFC247PHY04'
    and parameter_id in ('RFP1051','RFP1053')
    and corporate_id = rc.corp_id;

    insert into rpc_rf_parameter_config
    (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
    values
    (rc.corp_id, '247', 'RFC247PHY04', 'RFP1054', 'Standard');
end loop;   
end;
/