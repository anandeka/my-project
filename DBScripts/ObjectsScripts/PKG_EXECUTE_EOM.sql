create or replace package "PKG_EXECUTE_EOM" is

  procedure sp_execute_eom(pc_corporate_id       varchar2,
                           pc_action             varchar2,
                           pt_previous_pull_date timestamp,
                           pt_current_pull_date  timestamp,
                           pc_user_id            varchar2,
                           pd_trade_date         date,
                           pc_eom_status         out varchar2);

  procedure sp_record_cost(pc_corporate_id varchar2, pd_trade_date date);

  procedure sp_mark_dumps_status(pc_corporate_id varchar2,
                                 pd_trade_date   date);

end pkg_execute_eom; 
/
create or replace package body "PKG_EXECUTE_EOM" is

  procedure sp_execute_eom(pc_corporate_id       in varchar2,
                           pc_action             varchar2,
                           pt_previous_pull_date timestamp,
                           pt_current_pull_date  timestamp,
                           pc_user_id            varchar2,
                           pd_trade_date         date,
                           pc_eom_status         out varchar2) is
    vn_error_count            number;
    vn_error_only_error_count number;
    vc_process_status         varchar2(10) := 'NA';
  begin
    pkg_execute_process.sp_execute_process@eka_eoddb(pc_corporate_id,
                                                     pc_action,
                                                     'EOM',
                                                     pt_previous_pull_date,
                                                     pt_current_pull_date,
                                                     pc_user_id,
                                                     pd_trade_date);
    sp_mark_dumps_status(pc_corporate_id, pd_trade_date);
    begin
      select count(*)
        into vn_error_count
        from eel_eod_eom_exception_log@eka_eoddb eel
       where eel.corporate_id = pc_corporate_id
         and eel.process = 'EOM'
         and nvl(eel.error_type, 'Error') = 'Error'
         and eel.trade_date = pd_trade_date;
      select count(*)
        into vn_error_only_error_count
        from eel_eod_eom_exception_log@eka_eoddb eel
       where eel.corporate_id = pc_corporate_id
         and eel.process = 'EOM'
         and eel.trade_date = pd_trade_date
         and nvl(eel.error_type, 'Error') = 'Error';
    exception
      when others then
        pc_eom_status := 'Code:' || sqlcode || 'Message:' || sqlerrm;
    end;
    if pc_action = 'PRECHECK' then
      if vn_error_count = 0 then
        pc_eom_status := 'Precheck Success, Run the EOM';
      else
        if vn_error_only_error_count > 0 then
          pc_eom_status := 'Precheck Completed, User input required';
        else
          pc_eom_status := 'Precheck Completed With Warnings';
        end if;
      end if;
    elsif pc_action = 'PRECHECK_RUN' then
      if vn_error_count = 0 then
        pc_eom_status := 'EOM Process Success,Awaiting Cost Entry';
        --Everything OK, Let us settle trades in Transaction Schema
        pkg_execute_eod.sp_record_expired_drid(pc_corporate_id,
                                               pd_trade_date,
                                               'EOM');
      else
        if vn_error_only_error_count > 0 then
          pc_eom_status := 'Precheck Completed, User input required';
        else
          pc_eom_status := 'Precheck Completed With Warnings';
        end if;
      end if;
    elsif pc_action = 'RUN' then
      if vn_error_count = 0 then
        pc_eom_status := 'EOM Process Success,Awaiting Cost Entry';
        --Everything OK, Let us settle trades in Transaction Schema
        pkg_execute_eod.sp_record_expired_drid(pc_corporate_id,
                                               pd_trade_date,
                                               'EOM');
      else
        pc_eom_status := 'Precheck Completed, User input required';
      end if;
    end if;
    vc_process_status := pkg_process_status.sp_get@eka_eoddb(pc_corporate_id,
                                                             'EOM',
                                                             pd_trade_date);
    if vc_process_status = 'Cancel' then
      pc_eom_status := 'EOM Cancelled';
    end if;
    pkg_execute_eod.sp_mark_process_status(pc_corporate_id,
                                           pd_trade_date,
                                           'EOM',
                                           pc_action,
                                           pc_eom_status);
    pkg_execute_eod.sp_refresh_mv;
    if pc_eom_status in ('EOD Processed Successfully',
        'EOD Process Success,Awaiting Cost Entry',
        'EOM Processed Successfully',
        'EOM Process Success,Awaiting Cost Entry') then
      pkg_execute_eod.sp_mark_process_count(pc_corporate_id,
                                            'EOM',
                                            pd_trade_date);
    end if;
  end;

  procedure sp_record_cost(pc_corporate_id varchar2, pd_trade_date date) is
  begin
    pkg_execute_process.sp_record_misc_cost@eka_eoddb(pc_corporate_id,
                                                      pd_trade_date,
                                                      'EOM');
  end;

  procedure sp_mark_dumps_status(pc_corporate_id varchar2,
                                 pd_trade_date   date) is
    pragma autonomous_transaction;
    /******************************************************************************************************************************************
    Procedure Name                            : sp_mark_dumps_tatus
    Author                                    : Siva
    Created Date                              : 22th Mar 2010
    Purpose                                   : To updated DB dump status back to transaction schema
    
    Parameters
    pc_corporate_id                           : Corporate ID
    pd_trade_date                             : EOD Date ID
    pc_user_id                                : User ID
    pc_process                                : Process
    
    Modification History
    Modified Date                             :
    Modified By                               :
    Modify Description                        :
    ******************************************************************************************************************************************/
  begin
    -- To update the DB Transfer complited status back to transaction schema
    update eom_end_of_month_details
       set eom_dump_status = 'COMPLETED'
     where corporate_id = pc_corporate_id
       and as_of_date = pd_trade_date
       and eom_dump_status <> 'COMPLETED';
    commit;
  exception
    when others then
      null;
  end;

end; 
/
