delete from rpc_rf_parameter_config where report_id = '214';
delete from rfc_report_filter_config where report_id = '214';
commit;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
  loop
    dbms_output.put_line(cc.corporate_id);
insert into rfc_report_filter_config
(corporate_id,report_id,label_id,label_column_number,label_row_number,label,field_id,colspan,is_mandatory)
values  (cc.corporate_id, '214', 'RFC214PHY01', 1, 1, 'CP Name', 'GFF1001', 1, 'N');
insert into rpc_rf_parameter_config
  (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
values
  (cc.corporate_id, '214', 'RFC214PHY01', 'RFP1001', 'businesspartner');
insert into rpc_rf_parameter_config
  (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
values
  (cc.corporate_id, '214', 'RFC214PHY01', 'RFP1002', 'CPName');
insert into rpc_rf_parameter_config
  (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
values
  (cc.corporate_id, '214', 'RFC214PHY01', 'RFP1003', 'No');
insert into rpc_rf_parameter_config
  (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
values
  (cc.corporate_id, '214', 'RFC214PHY01', 'RFP1004', 'Filter');
insert into rpc_rf_parameter_config
  (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
values
  (cc.corporate_id, '214', 'RFC214PHY01', 'RFP1005', 'reportForm');
insert into rpc_rf_parameter_config
  (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
values
  (cc.corporate_id, '214', 'RFC214PHY01', 'RFP1006', '1');
insert into rpc_rf_parameter_config
  (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
values
  (cc.corporate_id, '214', 'RFC214PHY01', 'RFP1008', 'BUYER,SELLER');
  end loop;
commit;
end;