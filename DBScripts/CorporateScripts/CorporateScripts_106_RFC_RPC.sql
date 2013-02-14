begin
    --::        RFP Entries     ::--
    insert into rfp_rfc_field_parameters
       (field_id, parameter_display_seq, parameter_description, parameter_id, tag_attribute_name)
     values
       ('GFF1012', 1, null, 'RFP1212', 'removeSelect');   
    insert into rfp_rfc_field_parameters
       (field_id, parameter_display_seq, parameter_description, parameter_id, tag_attribute_name)
     values
       ('GFF1012', 1, null, 'RFP1213', 'dynamicSelectVal');   
    --::        End of RFP Entries     ::--

for rc in 
    (select 
        akc.corporate_id corp_id, akc.corporate_name 
        from ak_corporate akc where akc.is_internal_corporate = 'N')
loop
    dbms_output.put_line('Modifying Filter data for '||rc.corporate_name||' Corporate...');
            --::        RFC Entries     ::--
            insert into rfc_report_filter_config
               (corporate_id, report_id, label_id, label_column_number, label_row_number, 
                label, field_id, colspan, is_mandatory)
             values
               (rc.corp_id, '217', 'RFC217PHY06', 1, 6, 
                'Include Hedge Corrections', 'GFF1012', 1, 'Y'); 
            insert into rfc_report_filter_config
               (corporate_id, report_id, label_id, label_column_number, label_row_number, 
                label, field_id, colspan, is_mandatory)
             values
               (rc.corp_id, '218', 'RFC218PHY07', 1, 7, 
                'Include Hedge Corrections', 'GFF1012', 1, 'Y');                
            --::        End of RFC Entries     ::--        

            --::        RPC Entries     ::-- 
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '217', 'RFC217PHY06', 'RFP1060', 'Revocable');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '217', 'RFC217PHY06', 'RFP1061', 'IncludeHedgeCorr');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '217', 'RFC217PHY06', 'RFP1062', 'No');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '217', 'RFC217PHY06', 'RFP1063', 'Filter');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '217', 'RFC217PHY06', 'RFP1064', 'reportForm');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '217', 'RFC217PHY06', 'RFP1065', '1');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '217', 'RFC217PHY06', 'RFP1066', 'Yes');

            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '217', 'RFC217PHY06', 'RFP1212', 'Yes');  

            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '217', 'RFC217PHY06', 'RFP1213', 'N'); 
               
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '218', 'RFC218PHY07', 'RFP1060', 'Revocable');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '218', 'RFC218PHY07', 'RFP1061', 'IncludeHedgeCorr');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '218', 'RFC218PHY07', 'RFP1062', 'No');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '218', 'RFC218PHY07', 'RFP1063', 'Filter');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '218', 'RFC218PHY07', 'RFP1064', 'reportForm');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '218', 'RFC218PHY07', 'RFP1065', '1');
            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '218', 'RFC218PHY07', 'RFP1066', 'Yes');

            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '218', 'RFC218PHY07', 'RFP1212', 'Yes');  

            insert into rpc_rf_parameter_config
               (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
             values
               (rc.corp_id, '218', 'RFC218PHY07', 'RFP1213', 'N');     
            --::        End of RPC Entries     ::--
end loop;   
end;
/                
