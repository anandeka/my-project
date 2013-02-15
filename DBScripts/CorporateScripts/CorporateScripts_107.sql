-- Metal Balance Sumamry Product Made Multi Select
begin
for rc in 
    (select 
        akc.corporate_id corp_id, akc.corporate_name 
        from ak_corporate akc where akc.is_internal_corporate = 'N') loop
insert into rpc_rf_parameter_config
    (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
    values
    (rc.corp_id, '247', 'RFC247PHY04', 'RFP1051', 'multiple');
end loop;    
commit;
end ;  

