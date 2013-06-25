--------------------------------------------------
--  Swap Report - Corporate List filter changes...
--------------------------------------------------

declare
    lv_report_id varchar2(10):= '364';
    lv_label_id varchar2(20):='RFC364PHY06';
begin
        delete rfc_report_filter_config 
        where report_id = lv_report_id  and label_id = lv_label_id;
        
        delete rpc_rf_parameter_config 
        where report_id = lv_report_id  and label_id = lv_label_id; 
        
        for rc_corp in (select akc.corporate_id  from ak_corporate akc where akc.is_internal_corporate = 'N')
        loop              
            insert into rfc_report_filter_config
                (corporate_id, report_id, label_id, label_column_number, label_row_number, label, field_id, colspan, is_mandatory)
            values
                (rc_corp.corporate_id, lv_report_id, lv_label_id, 1, 6, 'Corporate', 'GFFCDC002', 1, 'Y');

            insert into rpc_rf_parameter_config
                (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
            values
                (rc_corp.corporate_id, lv_report_id, lv_label_id, 'RFPC00009', 'corporateList');
                
            insert into rpc_rf_parameter_config
                (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
            values
                (rc_corp.corporate_id, lv_report_id, lv_label_id, 'RFPC00010', 'PCorporateID');
                
            insert into rpc_rf_parameter_config
                (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
            values
                (rc_corp.corporate_id, lv_report_id, lv_label_id, 'RFPC00011', 'No');
                
            insert into rpc_rf_parameter_config
                (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
            values
                (rc_corp.corporate_id, lv_report_id, lv_label_id, 'RFPC00012', 'Filter');
                
            insert into rpc_rf_parameter_config
                (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
            values
                (rc_corp.corporate_id, lv_report_id, lv_label_id, 'RFPC00013', 'reportForm');
                
            insert into rpc_rf_parameter_config
                (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
            values
                (rc_corp.corporate_id, lv_report_id, lv_label_id, 'RFPC00014', '1');
                
            insert into rpc_rf_parameter_config
                (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
            values
                (rc_corp.corporate_id, lv_report_id, lv_label_id, 'RFPC00015', 'Yes');
                
            insert into rpc_rf_parameter_config
                (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
            values
                (rc_corp.corporate_id, lv_report_id, lv_label_id, 'RFPC00017', 'EXCLUDE_CORPORATE');
                              
        end loop; --End of Corporate Loop(rc_corp)
end;
/

commit;

Prompt Corporate List Filter changes has been applied successfully for all Corporates...

