create or replace package "PKG_EXECUTE_PROCESS" is
  gvc_previous_process_id varchar2(50);

  procedure sp_execute_process(pc_corporate_id       in varchar2,
                               pc_action             varchar2,
                               pc_process            varchar2,
                               pt_previous_pull_date timestamp,
                               pt_current_pull_date  timestamp,
                               pc_user_id            varchar2,
                               pd_trade_date         date);
  procedure sp_mark_dumps_status(pc_corporate_id varchar2,
                                 pd_trade_date   date,
                                 pc_user_id      varchar2,
                                 pc_process      varchar2);
  procedure sp_mark_process_time(pc_corporate_id varchar2,
                                 pd_trade_date   date,
                                 pc_user_id      varchar2,
                                 pc_process      varchar2,
                                 pc_process_type varchar2);
  procedure sp_process_time_display(pc_corporate_id varchar2,
                                 pd_trade_date   date,
                                 pc_user_id      varchar2,
                                 pc_process      varchar2,
                                 pc_process_type varchar2);                                 
  procedure sp_clear_process_status(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2,
                                    pc_clear_type   varchar2);
  procedure sp_record_misc_cost(pc_corporate_id in varchar2,
                                pd_trade_date   in date,
                                pc_process      in varchar2);
  procedure sp_delete_eel(pc_corporate_id varchar2, pc_process varchar2);
  procedure sp_rollback_process(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process      varchar2,
                                pc_dbd_id       varchar2,
                                pc_process_id   varchar2,
                                pc_user_id      varchar2);

  procedure sp_process_run(pc_corporate_id varchar2,
                           pd_trade_date   date,
                           pc_process_id   varchar2,
                           pc_user_id      varchar2,
                           pc_process      varchar2, --eod or eom
                           pc_dbd_id       varchar2);
  procedure sp_transfer_populate_precheck(pc_corporate_id       varchar2,
                                          pd_trade_date         date,
                                          pc_process            varchar2, --eod or eom
                                          pt_previous_pull_date timestamp,
                                          pt_current_pull_date  timestamp,
                                          pc_process_id         varchar2,
                                          pc_dbd_id             varchar2,
                                          pc_user_id            varchar2);

end; 
/
create or replace package body "PKG_EXECUTE_PROCESS" is

  procedure sp_execute_process
  --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_execute_process
    --        Author                                    : Siva
    --        Created Date                              : 10th Jan 2011
    --        Purpose                                   : Execute EOD
    --
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pc_action                                 : Action
    --        pt_previous_pull_date                     : Previous Data Pull Timestamp
    --        pt_current_pull_date                      : Current Data Pull Timestamp
    --        pc_user_id                                : User ID
    --        pd_trade_date                             : EOD Date
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
  (pc_corporate_id       in varchar2,
   pc_action             varchar2,
   pc_process            varchar2,
   pt_previous_pull_date timestamp,
   pt_current_pull_date  timestamp,
   pc_user_id            varchar2,
   pd_trade_date         date) is
  
    vc_process_id             varchar2(15);
    vn_total_error_count      number; -- Total No of records in EEL
    vn_error_only_error_count number; -- Total No of records in EEL where error_type='Error'
    vc_commit_flag            varchar2(1) := 'Y';
    vobj_error_log            tableofpelerrorlog := tableofpelerrorlog();
    vn_error_count_for_obj    number := 1;
    vc_oracle_error           varchar2(1000);
    pc_eod_status             varchar2(1000);
    vc_dbd_id                 varchar2(15);
    vc_process                varchar2(3);
    vc_process_status         varchar2(10) := 'NA';
    vn_process_count          number;
  begin
    vc_process := pc_process;
    sp_delete_eel(pc_corporate_id, vc_process);
  
    -- Get the Current EOD Reference Number
    -- Restrict insertion as applicable
    if pc_action in ('PRECHECK_RUN', 'PRECHECK') then
      begin
      
        begin
          select max(tdc.process_id) process_id
            into vc_process_id
            from tdc_trade_date_closure tdc
           where trade_date = pd_trade_date
             and corporate_id = pc_corporate_id
             and process = vc_process;
        exception
          when no_data_found then
            vc_process_id := null;
          when others then
            vc_process_id := null;
        end;
      
        begin
          select max(dbd.dbd_id)
            into vc_dbd_id
            from dbd_database_dump dbd
           where dbd.corporate_id = pc_corporate_id
             and dbd.process = vc_process
             and dbd.trade_date = pd_trade_date;
        exception
          when others then
            vc_dbd_id := null;
        end;
        --EOD Precheck Success and Rollback is called from UI  
        sp_rollback_process(pc_corporate_id,
                            pd_trade_date,
                            vc_process,
                            vc_dbd_id,
                            vc_process_id,
                            pc_user_id);
        vc_process_id := null;
        vc_dbd_id     := null;
      exception
        when others then
          null;
      end;
    end if;
  
    if pc_action in ('PRECHECK', 'PRECHECK_RUN') then
      select seq_eod.nextval into vc_process_id from dual;
      select seq_dbd.nextval into vc_dbd_id from dual;
      insert into tdc_trade_date_closure
        (corporate_id,
         trade_date,
         created_date,
         closed_by,
         process_id,
         process)
      values
        (pc_corporate_id,
         pd_trade_date,
         --sysdate,
         systimestamp,
         pc_user_id,
         vc_process_id,
         vc_process);
      insert into dbd_database_dump
        (dbd_id, corporate_id, start_date, end_date, trade_date, process)
      values
        (vc_dbd_id,
         pc_corporate_id,
         pt_previous_pull_date,
         pt_current_pull_date,
         pd_trade_date,
         vc_process);
    else
      begin
        select max(tdc.process_id) process_id
          into vc_process_id
          from tdc_trade_date_closure tdc
         where trade_date = pd_trade_date
           and corporate_id = pc_corporate_id
           and process = vc_process;
      exception
        when no_data_found then
          vc_process_id := null;
        when others then
          vc_process_id := null;
      end;
      begin
        select max(dbd.dbd_id)
          into vc_dbd_id
          from dbd_database_dump dbd
         where dbd.corporate_id = pc_corporate_id
           and dbd.process = vc_process
           and dbd.trade_date = pd_trade_date;
      exception
        when others then
          vc_dbd_id := null;
      end;
    end if;
  
    begin
      select tdc.process_id
        into gvc_previous_process_id
        from tdc_trade_date_closure tdc
       where tdc.corporate_id = pc_corporate_id
         and process = vc_process
         and tdc.trade_date =
             (select max(trade_date)
                from tdc_trade_date_closure
               where corporate_id = pc_corporate_id
                 and trade_date < pd_trade_date
                 and process = vc_process);
    exception
      when no_data_found then
        select seq_eod.nextval into gvc_previous_process_id from dual;
        insert into tdc_trade_date_closure
          (corporate_id,
           trade_date,
           created_date,
           closed_by,
           process_id,
           process)
        values
          (pc_corporate_id,
           to_date('01-Jan-2000', 'dd-Mon-yyyy'),
           systimestamp,
           pc_user_id,
           gvc_previous_process_id,
           vc_process);
    end;
  
    if pc_action = 'PRECHECK' then
      begin
      
        sp_transfer_populate_precheck(pc_corporate_id,
                                      pd_trade_date,
                                      vc_process,
                                      pt_previous_pull_date,
                                      pt_current_pull_date,
                                      vc_process_id,
                                      vc_dbd_id,
                                      pc_user_id);
      
        select count(*)
          into vn_total_error_count
          from eel_eod_eom_exception_log eel
         where eel.corporate_id = pc_corporate_id
           and eel.process = vc_process
           and eel.trade_date = pd_trade_date
           and nvl(eel.error_type, 'Error') = 'Error';
        if vn_total_error_count = 0 then
          pc_eod_status := 'Precheck Success, Run the EOD';
        else
          pc_eod_status := 'Precheck Completed, User input required';
          -- Retain data if there are only warnings
          -- Since user has the option to view these details
          -- and can 'Run EOD' i.e. Continue on Warnings
          select count(*)
            into vn_error_only_error_count
            from eel_eod_eom_exception_log eel
           where eel.corporate_id = pc_corporate_id
             and eel.process = vc_process
             and eel.trade_date = pd_trade_date
             and nvl(eel.error_type, 'Error') = 'Error';
          if vn_error_only_error_count > 0 then
            vc_commit_flag := 'N';
          else
            pc_eod_status := 'Precheck Completed With Warnings';
          end if;
        end if;
        vc_process_status := pkg_process_status.sp_get(pc_corporate_id,
                                                       vc_process,
                                                       pd_trade_date);
        if vc_process_status = 'Cancel' then
          vc_commit_flag := 'N';
          -- dbms_output.put_line('EOD Process cancelled in execute eod');
          begin
            sp_rollback_process(pc_corporate_id,
                                pd_trade_date,
                                vc_process,
                                vc_dbd_id,
                                vc_process_id,
                                pc_user_id);
            sp_clear_process_status(pc_corporate_id,
                                    pd_trade_date,
                                    pc_user_id,
                                    vc_process,
                                    'CANCELLLED');
          end;
          vobj_error_log.extend;
          vobj_error_log(vn_error_count_for_obj) := pelerrorlogobj(pc_corporate_id,
                                                                   'EOD/EOM Process',
                                                                   'M2M-013',
                                                                   'EOD Process cancelled by user.',
                                                                   '',
                                                                   vc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
        end if;
      exception
        when others then
          vc_oracle_error := 'Code:' || sqlcode || 'Message:' || sqlerrm;
          vobj_error_log.extend;
          vobj_error_log(vn_error_count_for_obj) := pelerrorlogobj(pc_corporate_id,
                                                                   'Package Execute EOD Pre-check',
                                                                   'M2M-013',
                                                                   'Code:' ||
                                                                   sqlcode ||
                                                                   'Message:' ||
                                                                   sqlerrm,
                                                                   '',
                                                                   vc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
          vn_error_count_for_obj := vn_error_count_for_obj + 1;
          pc_eod_status := 'Precheck Failed';
          vc_commit_flag := 'N';
      end;
    elsif pc_action = 'PRECHECK_RUN' then
      begin
      
        sp_transfer_populate_precheck(pc_corporate_id,
                                      pd_trade_date,
                                      vc_process,
                                      pt_previous_pull_date,
                                      pt_current_pull_date,
                                      vc_process_id,
                                      vc_dbd_id,
                                      pc_user_id);
        select count(*)
          into vn_total_error_count
          from eel_eod_eom_exception_log eel
         where eel.corporate_id = pc_corporate_id
           and eel.process = vc_process
           and eel.trade_date = pd_trade_date
           and nvl(eel.error_type, 'Error') = 'Error';
        if vn_total_error_count = 0 then
          pc_eod_status := 'Precheck Success, Run the EOD';
          dbms_output.put_line(pc_eod_status);
        else
          -- Retain data if there are only warnings
          -- Since user has the option to view these details
          -- and can 'Run EOD' i.e. Continue on Warnings
          pc_eod_status := 'Precheck Completed, User input required';
          select count(*)
            into vn_error_only_error_count
            from eel_eod_eom_exception_log eel
           where eel.corporate_id = pc_corporate_id
             and eel.process = vc_process
             and eel.trade_date = pd_trade_date
             and nvl(eel.error_type, 'Error') = 'Error';
          if vn_error_only_error_count > 0 then
            vc_commit_flag := 'N';
          else
            pc_eod_status := 'Precheck Completed With Warnings';
          end if;
        end if;
        if vn_total_error_count = 0 then
          sp_process_run(pc_corporate_id,
                         pd_trade_date,
                         vc_process_id,
                         pc_user_id,
                         vc_process,
                         vc_dbd_id);
        
          select count(*)
            into vn_total_error_count
            from eel_eod_eom_exception_log eel
           where eel.corporate_id = pc_corporate_id
             and eel.process = vc_process
             and eel.trade_date = pd_trade_date
             and nvl(eel.error_type, 'Error') = 'Error';
          if vn_total_error_count = 0 then
            pc_eod_status := 'EOD Process Success';
          else
            pc_eod_status  := 'EOD Process Failed';
            vc_commit_flag := 'N';
          end if;
        else
          if vn_error_only_error_count > 0 then
            vc_commit_flag := 'N';
          else
            vc_commit_flag := 'Y';
            delete from tdc_trade_date_closure
             where process_id = vc_process_id;
          end if;
        end if;
        vc_process_status := pkg_process_status.sp_get(pc_corporate_id,
                                                       vc_process,
                                                       pd_trade_date);
        if vc_process_status = 'Cancel' then
          vc_commit_flag := 'N';
          --    dbms_output.put_line('EOD Process cancelled in execute eod');
          begin
            --EOD Precheck Success and Rollback is called from UI   
          
            sp_rollback_process(pc_corporate_id,
                                pd_trade_date,
                                vc_process,
                                vc_dbd_id,
                                vc_process_id,
                                pc_user_id);
            commit;
            sp_clear_process_status(pc_corporate_id,
                                    pd_trade_date,
                                    pc_user_id,
                                    vc_process,
                                    'CANCELLLED');
          end;
          vobj_error_log.extend;
          vobj_error_log(vn_error_count_for_obj) := pelerrorlogobj(pc_corporate_id,
                                                                   'EOD/EOM Process',
                                                                   'M2M-013',
                                                                   'EOD Process cancelled by user.',
                                                                   '',
                                                                   vc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
        end if;
      exception
        when others then
          vc_oracle_error := 'Code:' || sqlcode || 'Message:' || sqlerrm;
          vobj_error_log.extend;
          vobj_error_log(vn_error_count_for_obj) := pelerrorlogobj(pc_corporate_id,
                                                                   'Package Execute EOD Pre-check/Run',
                                                                   'M2M-013',
                                                                   'Code:' ||
                                                                   sqlcode ||
                                                                   'Message:' ||
                                                                   sqlerrm,
                                                                   '',
                                                                   vc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
          vn_error_count_for_obj := vn_error_count_for_obj + 1;
          pc_eod_status := 'Precheck/EOD Process Failed';
          vc_commit_flag := 'N';
      end;
    elsif pc_action = 'RUN' then
    
      begin
        sp_process_run(pc_corporate_id,
                       pd_trade_date,
                       vc_process_id,
                       pc_user_id,
                       vc_process,
                       vc_dbd_id);
        select count(*)
          into vn_total_error_count
          from eel_eod_eom_exception_log eel
         where eel.corporate_id = pc_corporate_id
           and eel.process = vc_process
           and eel.trade_date = pd_trade_date
           and nvl(eel.error_type, 'Error') = 'Error';
        --AND    eel.error_type ='Error';
        if vn_total_error_count = 0 then
          pc_eod_status := 'EOD Process Success';
        else
          pc_eod_status  := 'EOD Process Failed';
          vc_commit_flag := 'N';
        end if;
        vc_process_status := pkg_process_status.sp_get(pc_corporate_id,
                                                       vc_process,
                                                       pd_trade_date);
        if vc_process_status = 'Cancel' then
          vc_commit_flag := 'N';
          dbms_output.put_line('EOD Process cancelled in execute eod');
          begin
            sp_rollback_process(pc_corporate_id,
                                pd_trade_date,
                                vc_process,
                                vc_dbd_id,
                                vc_process_id,
                                pc_user_id);
            sp_clear_process_status(pc_corporate_id,
                                    pd_trade_date,
                                    pc_user_id,
                                    vc_process,
                                    'CANCELLLED');
          end;
        end if;
      exception
        when others then
          vc_oracle_error := 'Code:' || sqlcode || 'Message:' || sqlerrm;
          vobj_error_log.extend;
          vobj_error_log(vn_error_count_for_obj) := pelerrorlogobj(pc_corporate_id,
                                                                   'Package Execute Run EOD',
                                                                   'M2M-013',
                                                                   'Code:' ||
                                                                   sqlcode ||
                                                                   'Message:' ||
                                                                   sqlerrm,
                                                                   '',
                                                                   vc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
          vn_error_count_for_obj := vn_error_count_for_obj + 1;
          pc_eod_status := 'EOD Process Failed';
          vc_commit_flag := 'N';
      end;
    
    elsif pc_action in ('CLEAR_DUMP', 'ROLLBACK') then
      --EOD Precheck Success and Rollback is called from UI
      begin
        sp_rollback_process(pc_corporate_id,
                            pd_trade_date,
                            vc_process,
                            vc_dbd_id,
                            vc_process_id,
                            pc_user_id);
        commit;
      exception
        when others then
          null;
      end;
    
      begin
        select count(*)
          into vn_process_count
          from dbd_database_dump t
         where t.corporate_id = pc_corporate_id
           and t.trade_date = pd_trade_date
           and t.process = vc_process;
      exception
        when no_data_found then
          vn_process_count := 0;
        when others then
          vn_process_count := 1;
      end;
      if vn_process_count = 0 then
        sp_clear_process_status(pc_corporate_id,
                                pd_trade_date,
                                pc_user_id,
                                vc_process,
                                'ROLLBACK');
        pc_eod_status := 'EOD Process Rollbacked';
      end if;
    
    end if;
    if vc_commit_flag = 'Y' then
      commit;
    else
    
      sp_rollback_process(pc_corporate_id,
                          pd_trade_date,
                          vc_process,
                          vc_dbd_id,
                          vc_process_id,
                          pc_user_id);
    
      commit;
      if pc_action = 'PRECHECK_RUN' then
        delete from tdc_trade_date_closure
         where process_id = vc_process_id;
      end if;
      commit;
    end if;
    sp_insert_error_log(vobj_error_log);
    if pc_eod_status is null and vc_oracle_error is not null then
       pc_eod_status := vc_oracle_error;
    end if;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_error_count_for_obj) := pelerrorlogobj(pc_corporate_id,
                                                               'Package Execute Run EOD',
                                                               'M2M-013',
                                                               'Code:' ||
                                                               sqlcode ||
                                                               'Message:' ||
                                                               sqlerrm,
                                                               '',
                                                               vc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
      sp_rollback_process(pc_corporate_id,
                          pd_trade_date,
                          vc_process,
                          vc_dbd_id,
                          vc_process_id,
                          pc_user_id);
    
      commit;
      pc_eod_status := 'Precheck/EOD Process Failed';
      dbms_output.put_line('pc_eod_status ' || pc_eod_status);
  end;

  procedure sp_mark_dumps_status(pc_corporate_id varchar2,
                                 pd_trade_date   date,
                                 pc_user_id      varchar2,
                                 pc_process      varchar2) is
    pragma autonomous_transaction;
    /******************************************************************************************************************************************
    Procedure Name                            : sp_mark_dumps_tatus
    Author                                    : Siva
    Created Date                              : 25th Jan 2010
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
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    if pc_process = 'EOD' then
      -- To update the DB Transfer complited status back to transaction schema
      update eod_end_of_day_details@eka_appdb
         set eod_dump_status = 'COMPLETED'
       where corporate_id = pc_corporate_id
         and as_of_date = pd_trade_date;
      commit;
    end if;
    if pc_process = 'EOM' then
      update eom_end_of_month_details@eka_appdb
         set eom_dump_status = 'COMPLETED'
       where corporate_id = pc_corporate_id
         and as_of_date = pd_trade_date;
      commit;
    end if;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_mark_dumps_tatus',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
 procedure sp_mark_process_time(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_user_id      varchar2,
                                pc_process      varchar2,
                                pc_process_type varchar2) is
   pragma autonomous_transaction;
   /******************************************************************************************************************************************
   Procedure Name                            : sp_mark_process_time 
   Author                                    : Siva
   Created Date                              : 13th Feb 2014
   Purpose                                   : To updated EOD/EOM precheck/process completion time back to app schema
   Parameters
   pc_corporate_id                           : Corporate ID
   pd_trade_date                             : EOD Date ID
   pc_user_id                                : User ID
   pc_process                                : Process ('EOD' or 'EOM')
   pc_process_type                           : 'PRECHECK' or 'PROCESS'
   Modification History
   Modified Date                             :
   Modified By                               :
   Modify Description                        :
   ******************************************************************************************************************************************/
   --vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
   --vn_eel_error_count number := 1;
   vd_current_time    timestamp;
 begin
   vd_current_time := systimestamp;
   if pc_process = 'EOD' then
     if pc_process_type = 'PRECHECK' then
       update eod_end_of_day_details@eka_appdb
          set prechcek_end_time = vd_current_time,
              precheck_duration = vd_current_time - db_dump_timestamp
        where corporate_id = pc_corporate_id
          and as_of_date = pd_trade_date;
     end if;
     if pc_process_type = 'PROCESS' then
       update eod_end_of_day_details@eka_appdb
          set process_end_time = vd_current_time,
              process_duration = vd_current_time - prechcek_end_time,
              net_duration     = vd_current_time - db_dump_timestamp
        where corporate_id = pc_corporate_id
          and as_of_date = pd_trade_date;
     end if;
   end if;
   if pc_process = 'EOM' then
     if pc_process_type = 'PRECHECK' then
       update eom_end_of_month_details@eka_appdb
          set prechcek_end_time = vd_current_time,
              precheck_duration = vd_current_time - db_dump_timestamp
        where corporate_id = pc_corporate_id
          and as_of_date = pd_trade_date;
     end if;
     if pc_process_type = 'PROCESS' then
       update eom_end_of_month_details@eka_appdb
          set process_end_time = vd_current_time,
              process_duration = vd_current_time - prechcek_end_time,
              net_duration     = vd_current_time - db_dump_timestamp
        where corporate_id = pc_corporate_id
          and as_of_date = pd_trade_date;
     end if;
   end if;
   commit;
 exception
   when others then
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'procedure sp_mark_process_time',
                 'Error marking time '||'Code:' || sqlcode ||'Message:' ||sqlerrm);
    /* vobj_error_log.extend;
     vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                          'procedure sp_mark_process_time',
                                                          'M2M-013',
                                                          'Code:' || sqlcode ||
                                                          'Message:' ||
                                                          sqlerrm,
                                                          '',
                                                          pc_process,
                                                          pc_user_id,
                                                          sysdate,
                                                          pd_trade_date);
     sp_insert_error_log(vobj_error_log);*/
     commit;
 end;
  procedure sp_process_time_display(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2,
                                    pc_process_type varchar2) is
    pragma autonomous_transaction;
    /******************************************************************************************************************************************
    Procedure Name                            : sp_mark_process_time 
    Author                                    : Siva
    Created Date                              : 13th Feb 2014
    Purpose                                   : To updated EOD/EOM precheck/process completion time back to app schema
    Parameters
    pc_corporate_id                           : Corporate ID
    pd_trade_date                             : EOD Date ID
    pc_user_id                                : User ID
    pc_process                                : Process ('EOD' or 'EOM')
    pc_process_type                           : 'PRECHECK' or 'PROCESS'
    Modification History
    Modified Date                             :
    Modified By                               :
    Modify Description                        :
    ******************************************************************************************************************************************/
    --vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    --vn_eel_error_count number := 1;
  begin
    if pc_process = 'EOD' then
      if pc_process_type = 'PRECHECK' then
        update eod_end_of_day_details@eka_appdb
           set precheck_time = extract(hour from precheck_duration) || ':' ||
                               extract(minute from precheck_duration) || ':' ||
                               extract(second from precheck_duration),
               net_time      = extract(hour from precheck_duration) || ':' ||
                               extract(minute from precheck_duration) || ':' ||
                               extract(second from precheck_duration)
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
      end if;
      if pc_process_type = 'PROCESS' then
        update eod_end_of_day_details@eka_appdb
           set process_time = extract(hour from process_duration) || ':' ||
                              extract(minute from process_duration) || ':' ||
                              extract(second from process_duration),
               net_time     = extract(hour from net_duration) || ':' ||
                              extract(minute from net_duration) || ':' ||
                              extract(second from net_duration)
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
      end if;
    end if;
    if pc_process = 'EOM' then
      if pc_process_type = 'PRECHECK' then
        update eom_end_of_month_details@eka_appdb
           set precheck_time = extract(hour from precheck_duration) || ':' ||
                               extract(minute from precheck_duration) || ':' ||
                               extract(second from precheck_duration),
               net_time      = extract(hour from precheck_duration) || ':' ||
                               extract(minute from precheck_duration) || ':' ||
                               extract(second from precheck_duration)
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
      end if;
      if pc_process_type = 'PROCESS' then
        update eom_end_of_month_details@eka_appdb
           set process_time = extract(hour from process_duration) || ':' ||
                              extract(minute from process_duration) || ':' ||
                              extract(second from process_duration),
               net_time     = extract(hour from net_duration) || ':' ||
                              extract(minute from net_duration) || ':' ||
                              extract(second from net_duration)
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
      end if;
    end if;
    commit;    
  exception
    when others then
        sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'procedure sp_process_time_display',
                 'Error marking time display '||'Code:' || sqlcode ||'Message:' ||sqlerrm);

     /* vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_process_time_display',
                                                           'M2M-013',
                                                           'Code:' || sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);*/
      commit;
  end;
  procedure sp_clear_process_status(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2,
                                    pc_clear_type   varchar2) is
    pragma autonomous_transaction;
    /******************************************************************************************************************************************
    Procedure Name                            : sp_mark_dumps_tatus
    Author                                    : Siva
    Created Date                              : 25th Jan 2010
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
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vc_eod_eom_id      varchar2(15);
    vc_status          varchar2(50);
  begin
    -- To update the DB Transfer complited status back to transaction schema
    ---Delete/update the EOD/EODH or EOM/EOMH table entry in the App Schema for this trade date
    /*
    Delete EOD/EOM Costs
    */
    if pc_process = 'EOD' then
      if pc_clear_type = 'ROLLBACK' then
        vc_status := 'EOD Rolled Back';
      else
        vc_status := 'EOD Cancelled';
      end if;
    else
      if pc_clear_type = 'ROLLBACK' then
        vc_status := 'EOM Rolled Back';
      else
        vc_status := 'EOM Cancelled';
      end if;
    end if;
    if pc_process = 'EOD' then
      select eod_id
        into vc_eod_eom_id
        from eod_end_of_day_details@eka_appdb
       where as_of_date = pd_trade_date
         and corporate_id = pc_corporate_id;
    else
      select eom_id
        into vc_eod_eom_id
        from eom_end_of_month_details@eka_appdb
       where as_of_date = pd_trade_date
         and corporate_id = pc_corporate_id;
    end if;
    if pc_process = 'EOD' then
      delete from eod_end_of_day_details@eka_appdb
       where eod_id = vc_eod_eom_id;
      update eodh_end_of_day_history@eka_appdb t
         set t.processing_status = vc_status
       where t.eod_id = vc_eod_eom_id;
    else
      delete from eom_end_of_month_details@eka_appdb
       where eom_id = vc_eod_eom_id;
      update eomh_end_of_month_history@eka_appdb t
         set t.processing_status = vc_status
       where t.eom_id = vc_eod_eom_id;
    end if;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_clear_process_status',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_record_misc_cost
  --------------------------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_record_misc_cost
    --        author                                    : 
    --        created date                              : 11th Jan 2011
    --        purpose                                   : popualte misc cost
    --
    --        parameters
    --        pc_corporate_id                           : corporate id
    --        pd_trade_date                             : trade date
    --        pc_process_id                             : eod reference no
    --
    --        modification history
    --        modified date                             :
    --        modified by                               :
    --        modify description                        :
    --------------------------------------------------------------------------------------------------------------------------
  (pc_corporate_id in varchar2,
   pd_trade_date   in date,
   pc_process      in varchar2) is
  
    vd_prev_eom_date   date;
    vd_acc_start_date  date;
    vc_process_id      varchar2(20);
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    cursor c_misc is
      select temp1.corporate_id,
             temp1.corporate_name,
             temp1.profit_center_id,
             temp1.profit_center_name,
             temp1.profit_center_short_name,
             temp1.main_section,
             temp1.sub_section,
             temp1.ytd_pnl,
             temp1.previous_month_pnl,
             temp1.mtd_pnl,
             temp1.today,
             temp1.currency_id,
             temp1.base_currency_name,
             gcd.groupid,
             gcd.groupname,
             gcd.group_cur_id,
             cm.cur_code,
             gcd.group_qty_unit_id,
             qum.qty_unit
        from (select temp.corporate_id,
                     temp.corporate_name,
                     temp.profit_center_id,
                     temp.profit_center_name,
                     temp.profit_center_short_name,
                     temp.main_section,
                     temp.sub_section,
                     sum(temp.previous_month_pnl) + sum(temp.mtd_pnl) ytd_pnl,
                     sum(temp.previous_month_pnl) previous_month_pnl,
                     sum(temp.mtd_pnl) mtd_pnl,
                     sum(temp.today) today,
                     temp.currency_id,
                     temp.base_currency_name
                from (select eod.corporate_id,
                             akc.corporate_name,
                             cpc.profit_center_id,
                             cpc.profit_center_name,
                             cpc.profit_center_short_name,
                             'Misc. Cost' main_section,
                             scm.cost_display_name sub_section,
                             'Today' pnl_section,
                             0 previous_month_pnl,
                             0 mtd_pnl,
                             sum(eodcd.cost_value) today,
                             eodcd.currency_id,
                             cm.cur_code base_currency_name
                        from eod_end_of_day_details@eka_appdb        eod,
                             eodc_end_of_day_costs@eka_appdb         eodc,
                             eodcd_end_of_day_cost_details@eka_appdb eodcd,
                             scm_service_charge_master@eka_appdb     scm,
                             cpc_corporate_profit_center             cpc,
                             cm_currency_master                      cm,
                             ak_corporate@eka_appdb                  akc
                       where eod.corporate_id = pc_corporate_id
                         and eod.as_of_date = pd_trade_date
                         and eod.as_of_date = eodc.closed_date
                         and eod.corporate_id = eodc.corporate_id
                         and eodc.eodc_id = eodcd.eodc_id
                         and eodcd.cost_id = scm.cost_id
                         and eodcd.profit_center_id = cpc.profit_center_id
                         and eodcd.currency_id = cm.cur_id
                         and eod.corporate_id = akc.corporate_id
                         and akc.corporate_id = cpc.corporateid
                       group by eod.corporate_id,
                                akc.corporate_name,
                                cpc.profit_center_id,
                                cpc.profit_center_name,
                                cpc.profit_center_short_name,
                                scm.cost_display_name,
                                eodcd.currency_id,
                                cm.cur_code
                      union all
                      select eod.corporate_id,
                             akc.corporate_name,
                             cpc.profit_center_id,
                             cpc.profit_center_name,
                             cpc.profit_center_short_name,
                             'Misc. Cost' main_section,
                             scm.cost_display_name sub_section,
                             'MonthToDate' pnl_section,
                             0 previous_month_pnl,
                             sum(eodcd.cost_value) mtd_pnl,
                             0 today,
                             eodcd.currency_id,
                             cm.cur_code base_currency_name
                        from eod_end_of_day_details@eka_appdb        eod,
                             eodc_end_of_day_costs@eka_appdb         eodc,
                             eodcd_end_of_day_cost_details@eka_appdb eodcd,
                             scm_service_charge_master@eka_appdb     scm,
                             cpc_corporate_profit_center             cpc,
                             cm_currency_master                      cm,
                             ak_corporate@eka_appdb                  akc
                       where eod.corporate_id = pc_corporate_id
                         and eod.as_of_date <= pd_trade_date
                         and eod.as_of_date > vd_prev_eom_date
                         and eod.as_of_date = eodc.closed_date
                         and eod.corporate_id = eodc.corporate_id
                         and eodc.eodc_id = eodcd.eodc_id
                         and eodcd.cost_id = scm.cost_id
                         and eodcd.profit_center_id = cpc.profit_center_id
                         and eodcd.currency_id = cm.cur_id
                         and eod.corporate_id = akc.corporate_id
                         and akc.corporate_id = cpc.corporateid
                       group by eod.corporate_id,
                                akc.corporate_name,
                                cpc.profit_center_id,
                                cpc.profit_center_name,
                                cpc.profit_center_short_name,
                                scm.cost_display_name,
                                eodcd.currency_id,
                                cm.cur_code
                      union all
                      select eom.corporate_id,
                             akc.corporate_name,
                             cpc.profit_center_id,
                             cpc.profit_center_name,
                             cpc.profit_center_short_name,
                             'Misc. Cost' main_section,
                             scm.cost_display_name sub_section,
                             'Prev_Month' pnl_section,
                             sum(eomcd.cost_value) previous_month_pnl,
                             0 mtd_pnl,
                             0 today,
                             eomcd.currency_id,
                             cm.cur_code base_currency_name
                        from eom_end_of_month_details@eka_appdb  eom,
                             eomc_end_of_month_costs@eka_appdb   eomc,
                             eomcd_eom_cost_details@eka_appdb    eomcd,
                             scm_service_charge_master@eka_appdb scm,
                             cpc_corporate_profit_center         cpc,
                             cm_currency_master                  cm,
                             ak_corporate@eka_appdb              akc
                       where eom.corporate_id = pc_corporate_id
                         and eom.as_of_date <= vd_prev_eom_date
                         and eom.as_of_date >= vd_acc_start_date
                         and eom.eom_id = eomc.eom_id
                         and eom.corporate_id = eomc.corporate_id
                         and eomc.eomc_id = eomcd.eomc_id
                         and eomcd.cost_id = scm.cost_id
                         and eomcd.profit_center_id = cpc.profit_center_id
                         and eomcd.currency_id = cm.cur_id
                         and eom.corporate_id = akc.corporate_id
                         and akc.corporate_id = cpc.corporateid
                       group by eom.corporate_id,
                                akc.corporate_name,
                                cpc.profit_center_id,
                                cpc.profit_center_name,
                                cpc.profit_center_short_name,
                                scm.cost_display_name,
                                eomcd.currency_id,
                                cm.cur_code) temp -- this is used to move columns into rows
               group by temp.corporate_id,
                        temp.corporate_name,
                        temp.profit_center_id,
                        temp.profit_center_name,
                        temp.profit_center_short_name,
                        temp.main_section,
                        temp.sub_section,
                        temp.currency_id,
                        temp.base_currency_name) temp1,
             ak_corporate@eka_appdb akc,
             gcd_groupcorporatedetails@eka_appdb gcd,
             cm_currency_master cm,
             qum_quantity_unit_master qum
       where temp1.corporate_id = akc.corporate_id
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm.cur_id
         and gcd.group_qty_unit_id = qum.qty_unit_id;
  
    cursor cc_micsc is
      select eodc.closed_date cost_created_date,
             tdc.process_id process_id,
             pd_trade_date eod_date,
             akc.corporate_id corporate_id,
             akc.corporate_name corporate_name,
             akc.base_currency_name base_currency_unit,
             cm_b.cur_id base_currency_unit_id,
             cm_b.decimals base_currency_decimals,
             cpc.profit_center_name profit_center_name,
             cpc.profit_center_id profit_center_id,
             cpc.profit_center_short_name profit_center_short_name,
             scm.cost_display_name journal_type,
             eodc.closed_date realization_date,
             scm.cost_id cost_id,
             scm.cost_display_name cost_name,
             nvl(to_number(eodcd.cost_value), 0) current_amount,
             eodc.closed_date month,
             eodcd.currency_id transact_cur_id,
             cm.cur_code transact_cur_code,
             cm.decimals transact_cur_decimals,
             nvl(to_number(eodcd.cost_value), 0) transact_amount
        from eodc_end_of_day_costs@eka_appdb         eodc,
             eodcd_end_of_day_cost_details@eka_appdb eodcd,
             cpc_corporate_profit_center             cpc,
             scm_service_charge_master               scm,
             tdc_trade_date_closure                  tdc,
             ak_corporate                            akc,
             cm_currency_master                      cm_b,
             cm_currency_master                      cm
       where eodc.eodc_id = eodcd.eodc_id
         and eodcd.profit_center_id = cpc.profit_center_id
         and eodcd.cost_id = scm.cost_id
         and eodcd.currency_id = cm.cur_id
         and akc.base_cur_id = cm_b.cur_id
         and tdc.trade_date = pd_trade_date
         and eodc.closed_date = pd_trade_date
         and eodc.corporate_id = pc_corporate_id
         and cpc.corporateid = pc_corporate_id
         and eodc.corporate_id = akc.corporate_id
         and tdc.corporate_id = pc_corporate_id
         and tdc.process = pc_process;
  begin
    select tdc.process_id
      into vc_process_id
      from tdc_trade_date_closure tdc
     where tdc.corporate_id = pc_corporate_id
       and tdc.trade_date = pd_trade_date
       and tdc.process = pc_process;
    begin
      select max(t.trade_date) prev_month_date
        into vd_prev_eom_date
        from tdc_trade_date_closure t
       where t.trade_date < pd_trade_date
         and t.corporate_id = pc_corporate_id
         and t.process = 'EOM';
    exception
      when no_data_found then
        vd_prev_eom_date := null;
    end;
    if vd_prev_eom_date is null then
      vd_prev_eom_date := to_date('01-Jan-2000', 'dd-Mon-yyyy');
    else
      vd_prev_eom_date := vd_prev_eom_date;
    end if;
    -- to get the accounding period start year date
    begin
      select start_date
        into vd_acc_start_date
        from cfy_corporate_financial_year@eka_appdb
       where pd_trade_date between start_date and end_date
         and corporateid = pc_corporate_id;
    exception
      when no_data_found then
        vd_acc_start_date := null;
    end;
    for cc in c_misc
    loop
      insert into tpd_trade_pnl_daily
        (corporate_id,
         corporate_name,
         process_id,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         main_section,
         sub_section,
         year_to_date_pnl,
         prev_month_pnl,
         month_to_date_pnl,
         today_pnl,
         pnl_cur_id,
         pnl_cur_code,
         group_id,
         group_name,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit)
      values
        (cc.corporate_id,
         cc.corporate_name,
         vc_process_id,
         cc.profit_center_id,
         cc.profit_center_name,
         cc.profit_center_short_name,
         cc.main_section,
         cc.sub_section,
         cc.ytd_pnl,
         cc.previous_month_pnl,
         cc.mtd_pnl,
         cc.today,
         cc.currency_id,
         cc.base_currency_name,
         cc.groupid,
         cc.groupname,
         cc.group_cur_id,
         cc.cur_code,
         cc.group_qty_unit_id,
         cc.qty_unit);
    end loop;
    for cc in cc_micsc
    loop
      insert into ord_overall_realized_pnl_daily
        (section_name,
         sub_section_name,
         section_id,
         order_id,
         cost_created_date,
         process_id,
         eod_date,
         corporate_id,
         corporate_name,
         base_qty_unit,
         base_qty_unit_id,
         base_cur_id,
         base_cur_code,
         base_cur_decimals,
         base_qty_decimals,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         customer_id,
         customer_name,
         journal_type,
         realization_date,
         transaction_ref_no,
         contract_ref_no,
         contract_details,
         cost_id,
         cost_name,
         price_fixation_status,
         current_qty,
         qty_in_units,
         current_amount,
         previous_realized_qty,
         previous_realized_amount,
         cost_month,
         transact_cur_id,
         transact_cur_code,
         transact_cur_decimals,
         transact_amt,
         internal_contract_item_ref_no,
         int_alloc_group_id,
         internal_stock_ref_no,
         alloc_group_name)
      values
        ('Miscellaneous Costs',
         'Miscellaneous Costs',
         9,
         1,
         cc.cost_created_date,
         cc.process_id,
         cc.eod_date,
         cc.corporate_id,
         cc.corporate_name,
         null,
         cc.base_currency_unit,
         null,
         cc.base_currency_unit_id,
         cc.base_currency_decimals,
         0,
         cc.profit_center_name,
         cc.profit_center_id,
         cc.profit_center_short_name,
         null,
         null,
         cc.journal_type,
         cc.realization_date,
         '-NA-',
         '-NA-',
         '-NA-',
         cc.cost_id,
         cc.cost_name,
         null,
         0,
         0,
         cc.current_amount,
         0,
         0,
         cc.month,
         cc.transact_cur_id,
         cc.transact_cur_code,
         cc.transact_cur_decimals,
         cc.transact_amount,
         null,
         null,
         null,
         null);
    
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_record_misc_cost',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           null, --pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_delete_eel(pc_corporate_id varchar2, pc_process varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_delete_eel
    --        Author                                    : Siva
    --        Created Date                              : 10th Jan 2011
    --        Purpose                                   : Delete EEL
    --
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pc_process                                : Process (EOD or EOM)
    --        pd_trade_date                             : EOD Date
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
    pragma autonomous_transaction;
  begin
    delete from eel_eod_eom_exception_log eel
     where eel.corporate_id = pc_corporate_id
       and eel.process = pc_process;
    commit;
  exception
    when others then
      null;
  end;
  procedure sp_rollback_process(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process      varchar2,
                                pc_dbd_id       varchar2,
                                pc_process_id   varchar2,
                                pc_user_id      varchar2) is
  
    vobj_error_log             tableofpelerrorlog := tableofpelerrorlog();
    vc_cdc_process_appplicable varchar2(1);
    vc_phy_process_applicable  varchar2(1);
    vc_cdc_execute             varchar2(4000);
    vn_eel_error_count         number := 1;
  begin
    --EOD Precheck Success or Rollback is called from UI   
    dbms_mview.refresh('ccg_corporateconfig', 'C');
    select nvl(ccg.cdc_process_applicable, 'Y'),
           nvl(ccg.phy_process_applicable, 'Y')
      into vc_cdc_process_appplicable,
           vc_phy_process_applicable
      from ccg_corporateconfig ccg
     where ccg.corporateid = pc_corporate_id;
    if vc_cdc_process_appplicable = 'Y' then
    
      vc_cdc_execute := 'call pkg_cdc_derivatives_process.sp_process_rollback(''' ||
                        pc_corporate_id || ''',''' || pc_process || ''',''' ||
                        pd_trade_date || ''',''' || pc_dbd_id || ''',''' ||
                        pc_process_id || ''')';
    
      execute immediate vc_cdc_execute;
      commit;
    end if;
  
    if vc_phy_process_applicable = 'Y' then
      vc_cdc_execute := 'call  pkg_phy_physical_process.sp_process_rollback(''' ||
                        pc_corporate_id || ''',''' || pc_process || ''',''' ||
                        pd_trade_date || ''',''' || pc_dbd_id || ''',''' ||
                        pc_process_id || ''')';
      execute immediate vc_cdc_execute;
      commit;
    end if;
    pkg_gen_process.sp_process_rollback(pc_corporate_id,
                                        pc_process,
                                        pd_trade_date,
                                        pc_dbd_id,
                                        pc_process_id);
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_rollback_process',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_process_run(pc_corporate_id varchar2,
                           pd_trade_date   date,
                           pc_process_id   varchar2,
                           pc_user_id      varchar2,
                           pc_process      varchar2, --eod or eom
                           pc_dbd_id       varchar2) is
    vobj_error_log             tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count         number := 1;
    vc_cdc_process_appplicable varchar2(1);
    vc_phy_process_applicable  varchar2(1);
    vc_cdc_execute             varchar2(4000);
  begin
    select nvl(ccg.cdc_process_applicable, 'Y'),
           nvl(ccg.phy_process_applicable, 'Y')
      into vc_cdc_process_appplicable,
           vc_phy_process_applicable
      from ccg_corporateconfig ccg
     where ccg.corporateid = pc_corporate_id;
  
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'sp_mark_process_id',
                 'EOD/EOM Marking Started.....');
    pkg_gen_process.sp_mark_process_id(pc_corporate_id,
                                       pc_process_id,
                                       pc_user_id,
                                       pd_trade_date,
                                       pc_process,
                                       pc_dbd_id);
    commit;
    sp_write_log(pc_corporate_id,
                 
                 pd_trade_date,
                 'sp_mark_process_id',
                 'Gen Process Marking Completed.....');
  
    if vc_cdc_process_appplicable = 'Y' then
    
      vc_cdc_execute := 'call pkg_cdc_derivatives_process.sp_mark_process_id(''' ||
                        pc_corporate_id || ''',''' || pc_process_id ||
                        ''',''' || pc_user_id || ''',''' || pd_trade_date ||
                        ''',''' || pc_process || ''',''' || pc_dbd_id ||
                        ''')';
      execute immediate vc_cdc_execute;
      commit;
    
    end if;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'sp_process_run',
                 'EOD/EOM Process Started.....');
-- CDC Process call moved first before the Physical process as CDC pnl required in physical module,custom reports in
-- PTM, and BI domains.                 
    if vc_cdc_process_appplicable = 'Y' then
    
      vc_cdc_execute := 'call  pkg_cdc_derivatives_process.sp_process_run(''' ||
                        pc_corporate_id || ''',''' || pd_trade_date ||
                        ''',''' || pc_process_id || ''',''' || pc_user_id ||
                        ''',''' || pc_process || ''',''' || pc_dbd_id ||
                        ''')';
      execute immediate vc_cdc_execute;
      commit;
    end if;                 
    if vc_phy_process_applicable = 'Y' then
      vc_cdc_execute := 'call pkg_phy_physical_process.sp_process_run(''' ||
                        pc_corporate_id || ''',''' || pd_trade_date ||
                        ''',''' || pc_process_id || ''',''' || pc_user_id ||
                        ''',''' || pc_process || ''',''' || pc_dbd_id ||
                        ''')';
    
      execute immediate vc_cdc_execute;
      commit;
    end if;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'sp_mark_process_id',
                 'Physical Marking Completed.....');

    --added on 09-Mar-2011
    if vc_cdc_process_appplicable = 'Y' then
    
      vc_cdc_execute := ' call pkg_cdc_pre_check_process.sp_record_expired_derivatives(''' ||
                        pc_corporate_id || ''',''' || pd_trade_date ||
                        ''',''' || pc_user_id || ''',''' || pc_process ||
                        ''',''' || pc_process_id || ''')';
      execute immediate vc_cdc_execute;
      commit;
    
      vc_cdc_execute := ' call pkg_cdc_pre_check_process.sp_record_expired_currency(''' ||
                        pc_corporate_id || ''',''' || pd_trade_date ||
                        ''',''' || pc_user_id || ''',''' || pc_process ||
                        ''',''' || pc_process_id || ''')';
      execute immediate vc_cdc_execute;
      commit;
    end if;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_process_run',
                                                           'M2M-013',
                                                           'code:' ||
                                                           sqlcode ||
                                                           'message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_transfer_populate_precheck(pc_corporate_id       varchar2,
                                          pd_trade_date         date,
                                          pc_process            varchar2,
                                          pt_previous_pull_date timestamp,
                                          pt_current_pull_date  timestamp,
                                          pc_process_id         varchar2,
                                          pc_dbd_id             varchar2,
                                          pc_user_id            varchar2) is
    vobj_error_log             tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count         number := 1;
    vc_cdc_process_appplicable varchar2(1);
    vc_phy_process_applicable  varchar2(1);
    vc_cdc_execute             varchar2(4000);
  begin
    dbms_output.put_line('pc_process_id' || pc_process_id);
    dbms_mview.refresh('ccg_corporateconfig', 'C');
    select nvl(ccg.cdc_process_applicable, 'Y'),
           nvl(ccg.phy_process_applicable, 'Y')
      into vc_cdc_process_appplicable,
           vc_phy_process_applicable
      from ccg_corporateconfig ccg
     where ccg.corporateid = pc_corporate_id;
    pkg_gen_process.sp_gen_transfer_data(pc_corporate_id,
                                         pt_previous_pull_date,
                                         pt_current_pull_date,
                                         pd_trade_date,
                                         pc_user_id,
                                         pc_process,
                                         pc_dbd_id);
    commit;
    if vc_cdc_process_appplicable = 'Y' then
    
      vc_cdc_execute := 'call pkg_cdc_transfer_data.sp_cdc_transfer_data(''' ||
                        pc_corporate_id || ''',''' || pt_previous_pull_date ||
                        ''',''' || pt_current_pull_date || ''',''' ||
                        pd_trade_date || ''',''' || pc_user_id || ''',''' ||
                        pc_process || ''',''' || pc_dbd_id || ''')';
      dbms_output.put_line('The execute immediate strins is - ' ||
                           vc_cdc_execute);
      execute immediate vc_cdc_execute;
      commit;
    end if;
  
    if vc_phy_process_applicable = 'Y' then
      vc_cdc_execute := 'call pkg_phy_transfer_data.sp_phy_transfer_data(''' ||
                        pc_corporate_id || ''',''' || pt_previous_pull_date ||
                        ''',''' || pt_current_pull_date || ''',''' ||
                        pd_trade_date || ''',''' || pc_user_id || ''',''' ||
                        pc_process || ''',''' || pc_dbd_id || ''')';
    
      dbms_output.put_line('The execute immediate strins is - ' ||
                           vc_cdc_execute);
      execute immediate vc_cdc_execute;
      commit;
    
    end if;
    sp_mark_dumps_status(pc_corporate_id,
                         pd_trade_date,
                         pc_user_id,
                         pc_process);
  
    pkg_gen_process.sp_gen_populate_table_data(pc_corporate_id,
                                               pd_trade_date,
                                               pc_user_id,
                                               pc_dbd_id,
                                               pc_process);
    commit;
    if vc_cdc_process_appplicable = 'Y' then
      vc_cdc_execute := 'call pkg_cdc_populate_data.sp_cdc_populate_table_data(''' ||
                        pc_corporate_id || ''',''' || pd_trade_date ||
                        ''',''' || pc_user_id || ''',''' || pc_dbd_id ||
                        ''',''' || pc_process || ''')';
      execute immediate vc_cdc_execute;
      commit;
    end if;
    if vc_phy_process_applicable = 'Y' then
    
      vc_cdc_execute := 'call pkg_phy_populate_data.sp_phy_populate_table_data(''' ||
                        pc_corporate_id || ''',''' || pd_trade_date ||
                        ''',''' || pc_user_id || ''',''' || pc_dbd_id ||
                        ''',''' || pc_process || ''')';
      execute immediate vc_cdc_execute;
      commit;
    end if;
  
    if vc_cdc_process_appplicable = 'Y' then
    
      vc_cdc_execute := 'call pkg_cdc_pre_check_process.sp_pre_check(''' ||
                        pc_corporate_id || ''',''' || pd_trade_date ||
                        ''',''' || pc_user_id || ''',''' || pc_process ||
                        ''')';
      execute immediate vc_cdc_execute;
      commit;
    end if;
    if vc_phy_process_applicable = 'Y' then
    
      vc_cdc_execute := 'call pkg_phy_pre_check_process.sp_pre_check(''' ||
                        pc_corporate_id || ''',''' || pd_trade_date ||
                        ''',''' || pc_user_id || ''',''' || pc_process ||
                        ''')';
      execute immediate vc_cdc_execute;
      commit;
    end if;  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_transfer_populate_precheck',
                                                           'M2M-013',
                                                           'code:' ||
                                                           sqlcode ||
                                                           'message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
end; 
/
