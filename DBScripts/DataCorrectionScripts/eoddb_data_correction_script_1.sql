rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
declare
  cursor c1 is
    select tname,
           decode(tname,
                  'DBD_DATABASE_DUMP',
                  1006,
                  'TDC_TRADE_DATE_CLOSURE',
                  1007,
                  rownum) as order_by
      from (select obj.object_name tname
              from user_objects obj
             where obj.object_type = 'TABLE')
     where tname not in
           ('EEM_EKA_EXCEPTION_MASTER', 'TPS_TRADE_PNL_SECTIONS',
            'CPE_CORP_PAYBLE_ELEMENT', 'CPE_CORP_PENALITY_ELEMENT')
     order by decode(tname,
                     'DBD_DATABASE_DUMP',
                     1006,
                     'TDC_TRADE_DATE_CLOSURE',
                     1007,
                     rownum);
  vc_user_name varchar2(100);
begin
  execute immediate 'PURGE RECYCLEBIN';
  for c11 in c1
  loop
    execute immediate 'truncate table  ' || c11.tname;
  end loop;
  commit;
  delete from eodph_eod_precheck_history@eka_appdb;
  delete from eodh_end_of_day_history@eka_appdb;
  delete from eomph_eom_precheck_history@eka_appdb;
  delete from eomh_end_of_month_history@eka_appdb;
  delete from eodcd_end_of_day_cost_details@eka_appdb;
  delete from eodc_end_of_day_costs@eka_appdb;
  delete from eomcd_eom_cost_details@eka_appdb;
  delete from eomc_end_of_month_costs@eka_appdb;
  delete from eod_eom_axsdata@eka_appdb;
  delete from eod_end_of_day_details@eka_appdb;
  delete from eom_end_of_month_details@eka_appdb;
  delete from eci_expired_ct_id@eka_appdb;
  delete from edi_expired_dr_id@eka_appdb;
  commit;
end;
/
