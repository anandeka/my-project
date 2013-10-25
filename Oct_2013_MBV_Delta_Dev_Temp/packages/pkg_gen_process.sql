create or replace package pkg_gen_process is

  -- Author  : Siva
  -- Created : 09-Jan-2009
  -- Purpose : All the Physicals Day end procedures are calculated here
  -- Public type declarations
  -- pvc_process VARCHAR2(5) := 'EOD';
  --pvc_process VARCHAR2(5);
  gvc_dbd_id varchar2(15);

  gvc_process varchar2(15);

  procedure sp_gen_populate_table_data(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_user_id      varchar2,
                                       pc_dbd_id       varchar2,
                                       pc_process      varchar2);

  procedure sp_gen_transfer_data(pc_corporate_id       in varchar2,
                                 pt_previous_pull_date timestamp,
                                 pt_current_pull_date  timestamp,
                                 pd_trade_date         date,
                                 pc_user_id            varchar2,
                                 pc_process            varchar2,
                                 pc_dbd_id             varchar2);

  procedure sp_mark_process_id(pc_corporate_id varchar2,
                               pc_process_id   varchar2,
                               pc_user_id      varchar2,
                               pd_trade_date   date,
                               pc_process      varchar2,
                               pc_dbd_id       varchar2);

  procedure sp_process_rollback(pc_corporate_id varchar2,
                                pc_process      varchar2,
                                pd_trade_date   date,
                                pc_dbd_id       varchar2,
                                pc_process_id   varchar2);

  procedure sp_gen_refresh_app_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2);

  procedure sp_gen_delete_general_data(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_user_id      varchar2,
                                       pc_process      varchar2);

  procedure sp_gen_insert_general_data(pc_corporate_id       in varchar2,
                                       pt_previous_pull_date timestamp,
                                       pt_current_pull_date  timestamp,
                                       pc_dbd_id             varchar2,
                                       pc_user_id            varchar2,
                                       pc_process            varchar2,
                                       pd_trade_date         date);
  procedure sp_mark_axsdata(pc_corporate_id varchar2,
                            pc_eodeom_id    varchar2,
                            pd_trade_date   date,
                            pc_process      varchar2,
                            pt_starttime    timestamp,
                            pt_endtime      timestamp);

  procedure sp_gen_gather_stats;
  
end; 
/
create or replace package body pkg_gen_process is

  procedure sp_gen_populate_table_data
  /******************************************************************************************************************************************
    procedure name                           : sp_cdc_populate_table_data
    author                                   : Ashok
    created date                             : 5 th jan 2011
    purpose                                  : populate transfer transaction data
    parameters
    
    pc_corporate_id                          : corporate id
    pt_previous_pull_date                    : last dump date
    pt_current_pull_date                     : current sys time(when called)
    pd_trade_date                            : eod data
    pc_user_id                               : user id
    pc_process                               : process = 'eod'
    
    modified date                            :
    modify description                       :
    ******************************************************************************************************************************************/
    --Instead of using main tables DQ_DERIVATIVE_QUOTES and DQD_DERIVATIVE_QUOTE_DETAIL, now using
    -- DQ_TEMP and DQD_TEMP tables to improve performance...        On 19th Dec, 2012       ::Raj
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_user_id      varchar2,
   pc_dbd_id       varchar2,
   pc_process      varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    --vn_logno           number := 50;
    vc_local_error_msg varchar2(100);
  begin
    null;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_gen_populate_table_data',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm || ' at ' ||
                                                           vc_local_error_msg,
                                                           '',
                                                           gvc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_gen_transfer_data(pc_corporate_id       in varchar2,
                                 pt_previous_pull_date timestamp,
                                 pt_current_pull_date  timestamp,
                                 pd_trade_date         date,
                                 pc_user_id            varchar2,
                                 pc_process            varchar2,
                                 pc_dbd_id             varchar2)
  --*****************************************************************************************************************************************
    --                    procedure name                           : sp_cdc_transfer_data
    --                    author                                   : siva
    --                    created date                             : 09th jan 2009
    --                    purpose                                  : transfer transaction data into eod database
    --                    parameters
    --
    --                    pc_corporate_id                          corporate id
    --                    pt_previous_pull_date                    last dump date
    --                    pt_current_pull_date                     current sys time(when called)
    --                    pd_trade_date                            eod data
    --                    pc_user_id                               user id
    --                    pc_process                               process = 'eod'
    --
    --                    modification history
    --                    modified by                              :
    --                    modified date                            :
    --                    modify description                       :
    --*****************************************************************************************************************************************
   is
    vc_dbd_id          varchar2(15);
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_logno           number := 25;
    vc_app_eodeom_id   varchar2(15);
    vd_date            date;
    cursor cur_dim is
      select *
        from cdim_corporate_dim cdim
       where cdim.corporate_id = pc_corporate_id;
    cursor cur_dim_holiday is
      select *
        from cdim_corporate_dim cdim
       where cdim.corporate_id = pc_corporate_id
         and cdim.is_exchange_holiday = 'Y';
  
  begin
    -- Alter session added to set the signature, due to proc call made by db link will show error message saying 'timestamp of procedure has been changed'
    -- also moved the sp_mark_axsdata to part of cdc gen process,
    execute immediate 'ALTER SESSION SET REMOTE_DEPENDENCIES_MODE = SIGNATURE';
    begin
      if pc_process = 'EOD' then
        select eod.eod_id
          into vc_app_eodeom_id
          from eod_end_of_day_details@eka_appdb eod
         where eod.corporate_id = pc_corporate_id
           and eod.as_of_date = pd_trade_date;
      else
        select eom.eom_id
          into vc_app_eodeom_id
          from eom_end_of_month_details@eka_appdb eom
         where eom.corporate_id = pc_corporate_id
           and eom.as_of_date = pd_trade_date;
      end if;
    exception
      when no_data_found then
        vc_app_eodeom_id := null;
    end;
    commit;
    sp_mark_axsdata(pc_corporate_id,
                    vc_app_eodeom_id,
                    pd_trade_date,
                    pc_process,
                    pt_previous_pull_date,
                    pt_current_pull_date);
    -- insert into database dump table
    vc_dbd_id := pc_dbd_id;
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'sp_gen_refresh_app_data');
    sp_gen_refresh_app_data(pc_corporate_id,
                            pd_trade_date,
                            pc_user_id,
                            pc_process);
    -- added on 09-May-2013 for NPD handling
    begin
      delete from npd_non_prompt_calendar_days npd
       where npd.corporate_id = pc_corporate_id;
      commit;
      insert into npd_non_prompt_calendar_days
        (corporate_id,
         npd_id,
         prompt_delivery_calendar_id,
         non_prompt_day,
         substitute_day,
         version,
         is_deleted)
        select pc_corporate_id corporate_id,
               npd_id,
               prompt_delivery_calendar_id,
               non_prompt_day,
               substitute_day,
               version,
               is_deleted
          from npd_non_prompt_calendar_days@eka_appdb
         where is_deleted = 'N';
      commit;
    exception
      when others then
        null; --TODO
    end;
    --
    -- 12th Mar 2012
    -- Added by Janna
    -- Populate CDIM and Update the columns
    -- Start
    delete from cdim_corporate_dim cdim
     where cdim.corporate_id = pc_corporate_id;
    commit;
    insert into cdim_corporate_dim
      (corporate_id,
       instrument_id,
       instrument_name,
       instrument_type_id,
       product_derivative_id,
       instrument_symbol,
       holiday_calender_id,
       delivery_calender_id,
       is_auto_generate,
       is_manual_generate,
       prompt_date_defn,
       prompt_days,
       warrant_tollerence,
       instrument_sub_type_id,
       underlying_instrument_id,
       is_cash_settlement,
       is_physical_settlement,
       settlement_type,
       spot_frequency,
       m2m_instrument_id,
       display_order,
       version,
       is_active,
       is_deleted,
       is_currency_curve)
      select pc_corporate_id,
             instrument_id,
             instrument_name,
             instrument_type_id,
             product_derivative_id,
             instrument_symbol,
             holiday_calender_id,
             delivery_calender_id,
             is_auto_generate,
             is_manual_generate,
             prompt_date_defn,
             prompt_days,
             warrant_tollerence,
             instrument_sub_type_id,
             underlying_instrument_id,
             is_cash_settlement,
             is_physical_settlement,
             settlement_type,
             spot_frequency,
             m2m_instrument_id,
             display_order,
             version,
             is_active,
             is_deleted,
             is_currency_curve
        from dim_der_instrument_master
       where is_deleted = 'N';
    commit;
    for cur_dim_rows in cur_dim
    loop
      if pkg_cdc_derivatives_process.f_is_day_holiday(cur_dim_rows.instrument_id,
                                                      pd_trade_date)  then
        update cdim_corporate_dim cdim
           set cdim.is_exchange_holiday = 'Y'
         where cdim.instrument_id = cur_dim_rows.instrument_id;
      end if;
    end loop;
    commit;
    for cur_dim_holiday_rows in cur_dim_holiday
    loop
      -- Get the previous trade date and update for instrument
      vd_date := pd_trade_date - 1;
      while true
      loop
        if pkg_cdc_derivatives_process.f_is_day_holiday(cur_dim_holiday_rows.instrument_id,
                                                        vd_date) then
          vd_date := vd_date - 1;
        else
          exit;
        end if;
      end loop;
      update cdim_corporate_dim cdim
         set cdim.valid_quote_date = vd_date
       where cdim.instrument_id = cur_dim_holiday_rows.instrument_id
         and cdim.corporate_id = pc_corporate_id;
    end loop;
    commit;
    update cdim_corporate_dim cdim
       set cdim.valid_quote_date = pd_trade_date
     where cdim.corporate_id = pc_corporate_id
       and valid_quote_date is null;
    commit;
/*
    -- update the npd days to substitute_day for the instruments on 09-May-2013
     begin
       update cdim_corporate_dim cdim
          set cdim.valid_quote_date = (select max(npd.substitute_day)
                                         from npd_non_prompt_calendar_days npd
                                        where npd.prompt_delivery_calendar_id =
                                              cdim.delivery_calender_id
                                          and npd.non_prompt_day =
                                              cdim.valid_quote_date
                                          and npd.corporate_id = pc_corporate_id
                                          and npd.is_deleted = 'N')
        where cdim.corporate_id = pc_corporate_id
          and cdim.is_deleted = 'N'
          and cdim.is_auto_generate = 'Y'
          and exists
          (select 1
                 from npd_non_prompt_calendar_days npd
                where npd.prompt_delivery_calendar_id =
                      cdim.delivery_calender_id
                  and npd.non_prompt_day = cdim.valid_quote_date
                  and npd.corporate_id = pc_corporate_id
                  and npd.is_deleted = 'N');
       commit;
     exception
       when others then
         null;
     end;
*/
    -- Populate CDIM and Update the columns
    -- End
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'sp_gen_delete_general_data');
    sp_gen_delete_general_data(pc_corporate_id,
                               pd_trade_date,
                               pc_user_id,
                               pc_process);
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'sp_gen_insert_general_data');
    sp_gen_insert_general_data(pc_corporate_id,
                               pt_previous_pull_date,
                               pt_current_pull_date,
                               vc_dbd_id,
                               pc_user_id,
                               pc_process,
                               pd_trade_date);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'sp_gen_gather_stats');
    sp_gen_gather_stats;
  
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'Data Transfer Completed !!!');
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    <<cancel_process>>
    dbms_output.put_line('EOD/EOM Process Cancelled while transafer data');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'Procedure sp_gen_transfer_data',
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

  procedure sp_mark_process_id(pc_corporate_id varchar2,
                               pc_process_id   varchar2,
                               pc_user_id      varchar2,
                               pd_trade_date   date,
                               pc_process      varchar2,
                               pc_dbd_id       varchar2
                               --------------------------------------------------------------------------------------------------------------------------
                               --        procedure name                            : sp_mark_process_id
                               --        author                                    : siva
                               --        created date                              : 20th jan 2009
                               --        purpose                                   : to mark the eod refernce numbers
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
                               ) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    --start marking
    update eodeom_derivative_quote_detail
       set process_id = pc_process_id
     where dbd_id = pc_dbd_id;
    commit;
    update dq_temp dq
       set dq.process_id = pc_process_id
     where dq.trade_date <= pd_trade_date
       and dq.process_id is null
       and dq.dbd_id = pc_dbd_id;
    commit;
    update dqd_temp dqd
       set dqd.process_id = pc_process_id
     where dqd.dbd_id = pc_dbd_id;
    commit;
    update eodeom_currency_forward_quotes eod
       set eod.process_id = pc_process_id
     where eod.corporate_id = pc_corporate_id
       and eod.dbd_id = pc_dbd_id;
    commit;
    update coq_currency_option_quotes coq
       set coq.process_id = pc_process_id
     where coq.process_id is null
       and coq.dbd_id = pc_dbd_id;
    commit;
    update coqd_cur_option_quote_detail coqd
       set coqd.process_id = pc_process_id
     where coqd.dbd_id = pc_dbd_id;
    commit;
    update fq_freight_quotes fq
       set fq.process_id = pc_process_id
     where fq.process_id is null
       and fq.dbd_id = pc_dbd_id;
    commit;
    update fqd_freight_quote_detail fqd
       set fqd.process_id = pc_process_id
     where fqd.dbd_id = pc_dbd_id;
    commit;
    ---  insert dq_temp into dq main table
    -- suresh
    insert into dq_derivative_quotes
      (dq_id,
       trade_date,
       corporate_id,
       entry_type,
       instrument_id,
       price_source_id,
       created_date,
       updated_date,
       version,
       is_deleted,
       dbd_id,
       process_id)
      select dq_id,
             trade_date,
             corporate_id,
             entry_type,
             instrument_id,
             price_source_id,
             created_date,
             updated_date,
             version,
             is_deleted,
             dbd_id,
             process_id
        from dq_temp
       where dbd_id = pc_dbd_id
         and corporate_id = pc_corporate_id;
    commit;
  
    insert into dqd_derivative_quote_detail
      (dqd_id,
       dq_id,
       dr_id,
       available_price_id,
       price,
       price_unit_id,
       delta,
       gamma,
       theta,
       wega,
       is_deleted,
       dbd_id,
       process_id,
       charm,
       lambda,
       rho,
       volatility,
       riskfree_rate,
       interest_rate,
       spot_rate,
       is_manual)
      select dqd_id,
             dq_id,
             dr_id,
             available_price_id,
             price,
             price_unit_id,
             delta,
             gamma,
             theta,
             wega,
             is_deleted,
             dbd_id,
             process_id,
             charm,
             lambda,
             rho,
             volatility,
             riskfree_rate,
             interest_rate,
             spot_rate,
             is_manual
        from dqd_temp
       where dbd_id = pc_dbd_id;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure gen sp_mark_process_id',
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

  procedure sp_process_rollback(pc_corporate_id varchar2,
                                pc_process      varchar2,
                                pd_trade_date   date,
                                pc_dbd_id       varchar2,
                                pc_process_id   varchar2)
  --------------------------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_process_rollback
    --        author                                    :
    --        created date                              : 11th Jan 2011
    --        purpose                                   : rollback eod
    --        parameters
    --        pc_corporate_id                           : corporate id
    --        modification history
    --        modified date                             :
    --        modified by                               :
    --        modify description                        :
    --------------------------------------------------------------------------------------------------------------------------
   is
    --  vc_process_id      varchar2(15);
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    delete from eodeom_derivative_quote_detail where dbd_id = pc_dbd_id;
    delete from dq_derivative_quotes where dbd_id = pc_dbd_id;
    delete from dq_temp where dbd_id = pc_dbd_id;
    commit;
    delete from dqd_derivative_quote_detail where dbd_id = pc_dbd_id;
    delete from dqd_temp where dbd_id = pc_dbd_id;
    delete from axs_action_summary where dbd_id = pc_dbd_id;
    commit;
    delete dbd_database_dump dbd where dbd.dbd_id = pc_dbd_id;
    delete from eodeom_currency_forward_quotes eod
     where eod.corporate_id = pc_corporate_id
       and eod.dbd_id = pc_dbd_id;
    commit;
    delete from coq_currency_option_quotes where dbd_id = pc_dbd_id;
    delete from coqd_cur_option_quote_detail where dbd_id = pc_dbd_id;
    commit;
    delete from fq_freight_quotes where dbd_id = pc_dbd_id;
    delete from fqd_freight_quote_detail where dbd_id = pc_dbd_id;
    commit;
    /*
    delete eod/eom costs
    */
    if pc_process = 'EOD' then
      delete from eodcd_end_of_day_cost_details@eka_appdb
       where eodc_id in (select eodc_id
                           from eodc_end_of_day_costs@eka_appdb
                          where closed_date = pd_trade_date
                            and corporate_id = pc_corporate_id);
      delete from eodc_end_of_day_costs@eka_appdb
       where closed_date = pd_trade_date
         and corporate_id = pc_corporate_id;
      commit;
    else
      delete from eomcd_eom_cost_details@eka_appdb
       where eomc_id in (select eomc_id
                           from eomc_end_of_month_costs@eka_appdb  eomc,
                                eom_end_of_month_details@eka_appdb eom
                          where eom.corporate_id = pc_corporate_id
                            and eom.as_of_date = pd_trade_date
                            and eom.eom_id = eomc.eom_id);
      delete from eomc_end_of_month_costs@eka_appdb
       where eom_id in (select eom_id
                          from eom_end_of_month_details@eka_appdb eom
                         where eom.corporate_id = pc_corporate_id
                           and eom.as_of_date = pd_trade_date);
      commit;
    end if;
    if pc_process_id is not null then
      delete from tpd_trade_pnl_daily where process_id = pc_process_id;
      delete tdc_trade_date_closure where process_id = pc_process_id;
      commit;
      delete from upad_unreal_pnl_attr_detail
       where process_id = pc_process_id;
      commit;
    end if;
    delete from edi_expired_dr_id t
     where t.corporate_id = pc_corporate_id
       and t.trade_date = pd_trade_date
       and t.process = pc_process;
    commit;
    delete from eci_expired_ct_id t
     where t.corporate_id = pc_corporate_id
       and t.trade_date = pd_trade_date
       and t.process = pc_process;
    commit;
    --delete from app db
    delete from edi_expired_dr_id@eka_appdb t
     where t.corporate_id = pc_corporate_id
       and t.trade_date = pd_trade_date
       and t.process = pc_process;
    commit;
    delete from eci_expired_ct_id@eka_appdb t
     where t.corporate_id = pc_corporate_id
       and t.trade_date = pd_trade_date
       and t.process = pc_process;
    commit;
    delete from tmef_temp_eod_fx_rate tmef
     where tmef.trade_date = pd_trade_date
       and tmef.corporate_id = pc_corporate_id;
    commit;
    delete from eod_eom_axsdata@eka_appdb
     where corporate_id = pc_corporate_id
       and trade_date = pd_trade_date
       and process = pc_process;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure gen sp_process_rollback',
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

  procedure sp_gen_refresh_app_data
  --*****************************************************************************************************************************************
    --                procedure name                           : sp_refresh_app_data
    --                author                                   : siva
    --                created date                             : 09th jan 2009
    --                purpose                                  : transfer transaction data into eod database
    --                parameters
    --
    --                pc_corporate_id                          corporate id
    --                pd_trade_date                            eod data
    --                pc_user_id                               user id
    --                pc_process                               process = 'eod'
    --
    --                modification history
    --                modified by                              :
    --                modified date                            :
    --                modify description                       :
    --*****************************************************************************************************************************************
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_user_id      varchar2,
   pc_process      varchar2) is
    vobj_error_log          tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count      number := 1;
    vc_other_process_status number := 0;
  begin
    begin
      if pc_process = 'EOD' then
        select count(*)
          into vc_other_process_status
          from eod_end_of_day_details@eka_appdb eod
         where eod.corporate_id <> pc_corporate_id
           and eod.as_of_date <> pd_trade_date
           and eod.processing_status = 'Running';
      else
        select count(*)
          into vc_other_process_status
          from eom_end_of_month_details@eka_appdb eom
         where eom.corporate_id <> pc_corporate_id
           and eom.as_of_date <> pd_trade_date
           and eom.processing_status = 'Running';
      end if;
    exception
      when others then
        vc_other_process_status := 1;
    end;
    if vc_other_process_status = 0 then
      /* dbms_mview.refresh('ak_corporate_user', 'C');
      dbms_mview.refresh('apm_available_price_master', 'C');
      dbms_mview.refresh('awpep_awp_equity_premium', 'C');
      dbms_mview.refresh('awpo_awp_product_origin', 'C');
      dbms_mview.refresh('awpp_awp_product_price', 'C');
      dbms_mview.refresh('awpu_awp_product_price_units', 'C');
      dbms_mview.refresh('axm_action_master', 'C');
      dbms_mview.refresh('bca_broker_clearer_account', 'C');
      dbms_mview.refresh('bcs_broker_commission_setup', 'C');
      dbms_mview.refresh('bct_broker_commission_types', 'C');
      dbms_mview.refresh('bgm_bp_group_master', 'C');
      dbms_mview.refresh('bpc_bp_corporates', 'C');
      dbms_mview.refresh('bpr_business_partner_roles', 'C');
      dbms_mview.refresh('bpsld_bp_storage_loc_det', 'C');
      dbms_mview.refresh('ccg_corporateconfig', 'C');
      dbms_mview.refresh('ccm_corporate_carrycost_setup', 'C');
      dbms_mview.refresh('cd_currency_definition', 'C');
      dbms_mview.refresh('cem_currency_exchange_master', 'C');
      dbms_mview.refresh('cfy_corporate_financial_year', 'C');
      dbms_mview.refresh('cgd_color_grade_definition', 'C');
      dbms_mview.refresh('cim_citymaster', 'C');
      dbms_mview.refresh('cm_currency_master', 'C');
      dbms_mview.refresh('cpm_corporateproductmaster', 'C');
      dbms_mview.refresh('cp_currency_pairs', 'C');
      dbms_mview.refresh('crm_country_region_master', 'C');
      dbms_mview.refresh('cym_countrymaster', 'C');
      dbms_mview.refresh('css_corporate_strategy_setup', 'C');
      dbms_mview.refresh('cq_currency_quote', 'C');
      dbms_mview.refresh('cpc_corporate_profit_center', 'C');
      dbms_mview.refresh('cap_corporate_acct_period', 'C');
      dbms_mview.refresh('cfq_currency_forward_quotes', 'C');
      dbms_mview.refresh('cfqd_currency_fwd_quote_detail', 'C');
      dbms_mview.refresh('cgm_cost_group_master', 'C');
      dbms_mview.refresh('clm_calendar_master', 'C');
      dbms_mview.refresh('clwh_calendar_weekly_holiday', 'C');
      dbms_mview.refresh('cpog_corp_product_origin_group', 'C');
      dbms_mview.refresh('cppm_cor_product_pdd_mapping', 'C');
      dbms_mview.refresh('dim_der_instrument_master', 'C');
      dbms_mview.refresh('dqu_derived_quantity_unit', 'C');
      dbms_mview.refresh('drm_derivative_master', 'C');
      dbms_mview.refresh('dpc_daily_prompt_calendar', 'C');
      dbms_mview.refresh('dpd_delivery_period_definition', 'C');
      dbms_mview.refresh('dpu_derivative_price_unit', 'C');
      dbms_mview.refresh('dtm_deal_type_master', 'C');
      dbms_mview.refresh('du_derivative_underlying', 'C');
      dbms_mview.refresh('dip_der_instrument_pricing', 'C');
      dbms_mview.refresh('div_der_instrument_valuation', 'C');
      dbms_mview.refresh('emt_exchangemaster', 'C');
      dbms_mview.refresh('em_entity_master', 'C');
      dbms_mview.refresh('fim_formula_index_mapping', 'C');
      dbms_mview.refresh('fbi_formula_builder_instrument', 'C');
      dbms_mview.refresh('fbs_formula_builder_setup', 'C');
      dbms_mview.refresh('gab_globaladdressbook', 'C');
      dbms_mview.refresh('gcd_groupcorporatedetails', 'C');
      dbms_mview.refresh('gsm_gmr_stauts_master', 'C');
      dbms_mview.refresh('hl_holiday_list', 'C');
      dbms_mview.refresh('hm_holiday_master', 'C');
      dbms_mview.refresh('irm_instrument_type_master', 'C');
      dbms_mview.refresh('itm_incoterm_master', 'C');
      dbms_mview.refresh('ims_initial_margin_setup', 'C');
      dbms_mview.refresh('istm_instr_sub_type_master', 'C');
      dbms_mview.refresh('mpc_monthly_prompt_calendar', 'C');
      dbms_mview.refresh('mpcm_monthly_prompt_cal_month', 'C');
      dbms_mview.refresh('orm_origin_master', 'C');
      dbms_mview.refresh('pac_product_asset_class', 'C');
      dbms_mview.refresh('pad_profile_addresses', 'C');
      dbms_mview.refresh('pdc_prompt_delivery_calendar', 'C');
      dbms_mview.refresh('pdd_product_derivative_def', 'C');
      dbms_mview.refresh('pdm_productmaster', 'C');
      dbms_mview.refresh('pdtm_product_type_master', 'C');
      dbms_mview.refresh('pfg_productfeaturegroup', 'C');
      dbms_mview.refresh('pgm_product_group_master', 'C');
      dbms_mview.refresh('phd_profileheaderdetails', 'C');
      dbms_mview.refresh('pm_period_master', 'C');
      dbms_mview.refresh('pmt_portmaster', 'C');
      dbms_mview.refresh('pog_product_origin_group', 'C');
      dbms_mview.refresh('pom_product_origin_master', 'C');
      dbms_mview.refresh('pp_price_point', 'C');
      dbms_mview.refresh('pps_product_packing_size', 'C');
      dbms_mview.refresh('ppt_product_price_types', 'C');
      dbms_mview.refresh('ppu_product_price_units', 'C');
      dbms_mview.refresh('pqu_product_quantity_unit', 'C');
      dbms_mview.refresh('ps_price_source', 'C');
      dbms_mview.refresh('psam_price_source_ap_mapping', 'C');
      dbms_mview.refresh('psm_packing_size_master', 'C');
      dbms_mview.refresh('pt_price_type', 'C');
      dbms_mview.refresh('ptm_packing_type_master', 'C');
      dbms_mview.refresh('ptm_premium_type_master', 'C');
      dbms_mview.refresh('pum_price_unit_master', 'C');
      dbms_mview.refresh('pwt_product_weight_term_master', 'C');
      dbms_mview.refresh('pym_payment_terms_master', 'C');
      dbms_mview.refresh('pcif_phy_contract_item_formula', 'C');
      dbms_mview.refresh('piip_phy_item_index_pricing', 'C');
      dbms_mview.refresh('qat_quality_attributes', 'C');
      dbms_mview.refresh('qum_quantity_unit_master', 'C');
      dbms_mview.refresh('scd_sub_currency_detail', 'C');
      dbms_mview.refresh('scm_service_charge_master', 'C');
      dbms_mview.refresh('sdm_strategy_definition_master', 'C');
      dbms_mview.refresh('sm_state_master', 'C');
      dbms_mview.refresh('sld_storage_location_detail', 'C');
      dbms_mview.refresh('ucm_unit_conversion_master', 'C');
      dbms_mview.refresh('wqc_warehouse_quotation_cost', 'C');
      dbms_mview.refresh('wqh_warehouse_quotation_header', 'C');
      dbms_mview.refresh('wpc_weekly_prompt_calendar', 'C');
      dbms_mview.refresh('mv_cfq_currency_forward_quotes', 'C');
      dbms_mview.refresh('gtm_gravity_type_master', 'C');*/
      dbms_mview.refresh('ak_corporate_user', 'F');
      dbms_mview.refresh('apm_available_price_master', 'F');
      dbms_mview.refresh('axm_action_master', 'F');
      dbms_mview.refresh('bca_broker_clearer_account', 'F');
      dbms_mview.refresh('bcs_broker_commission_setup', 'F');
      dbms_mview.refresh('bct_broker_commission_types', 'F');
      dbms_mview.refresh('bpr_business_partner_roles', 'F');
      dbms_mview.refresh('cap_corporate_acct_period', 'F');
      dbms_mview.refresh('ccg_corporateconfig', 'F');
      commit;
      dbms_mview.refresh('cfq_currency_forward_quotes', 'F');
      dbms_mview.refresh('cfqd_currency_fwd_quote_detail', 'F');
      dbms_mview.refresh('cfy_corporate_financial_year', 'F');
      dbms_mview.refresh('cim_citymaster', 'F');
      dbms_mview.refresh('clm_calendar_master', 'F');
      dbms_mview.refresh('clwh_calendar_weekly_holiday', 'F');
      dbms_mview.refresh('cm_currency_master', 'F');
      dbms_mview.refresh('cpc_corporate_profit_center', 'F');
      dbms_mview.refresh('cpm_corporateproductmaster', 'F');
      dbms_mview.refresh('cq_currency_quote', 'F');
      dbms_mview.refresh('css_corporate_strategy_setup', 'F');
      dbms_mview.refresh('cym_countrymaster', 'F');
      commit;
      dbms_mview.refresh('dim_der_instrument_master', 'F');
      dbms_mview.refresh('dip_der_instrument_pricing', 'F');
      dbms_mview.refresh('div_der_instrument_valuation', 'F');
      dbms_mview.refresh('dpc_daily_prompt_calendar', 'F');
      dbms_mview.refresh('dpd_delivery_period_definition', 'F');
      -- dbms_mview.refresh('dpm_derivative_purpose_master','F');
      dbms_mview.refresh('dpu_derivative_price_unit', 'F');
      dbms_mview.refresh('dqu_derived_quantity_unit', 'F');
      dbms_mview.refresh('drm_derivative_master', 'F');
      dbms_mview.refresh('emt_exchangemaster', 'F');
      dbms_mview.refresh('em_entity_master', 'F');
      commit;
      dbms_mview.refresh('fbi_formula_builder_instrument', 'F');
      dbms_mview.refresh('fbs_formula_builder_setup', 'F');
      dbms_mview.refresh('gab_globaladdressbook', 'F');
      dbms_mview.refresh('gcd_groupcorporatedetails', 'F');
      dbms_mview.refresh('gtm_gravity_type_master', 'F');
      dbms_mview.refresh('hl_holiday_list', 'F');
      dbms_mview.refresh('hm_holiday_master', 'F');
      commit;
      dbms_mview.refresh('ims_initial_margin_setup', 'F');
      dbms_mview.refresh('irm_instrument_type_master', 'F');
      dbms_mview.refresh('istm_instr_sub_type_master', 'F');
      dbms_mview.refresh('mpc_monthly_prompt_calendar', 'F');
      dbms_mview.refresh('mpcm_monthly_prompt_cal_month', 'F');
      -- dbms_mview.refresh('otm_option_type_master','F');
      dbms_mview.refresh('pac_product_asset_class', 'F');
      dbms_mview.refresh('pad_profile_addresses', 'F');
      commit;
      dbms_mview.refresh('pdc_prompt_delivery_calendar', 'F');
      dbms_mview.refresh('pdd_product_derivative_def', 'F');
      dbms_mview.refresh('pdm_productmaster', 'F');
      dbms_mview.refresh('pdtm_product_type_master', 'F');
      dbms_mview.refresh('pfg_productfeaturegroup', 'F');
      dbms_mview.refresh('pgm_product_group_master', 'F');
      dbms_mview.refresh('phd_profileheaderdetails', 'F');
      dbms_mview.refresh('pm_period_master', 'F');
      dbms_mview.refresh('pmt_portmaster', 'F');
      dbms_mview.refresh('pp_price_point', 'F');
      commit;
      dbms_mview.refresh('ppt_product_price_types', 'F');
      dbms_mview.refresh('ppu_product_price_units', 'F');
      dbms_mview.refresh('pqu_product_quantity_unit', 'F');
      dbms_mview.refresh('ps_price_source', 'F');
      dbms_mview.refresh('psam_price_source_ap_mapping', 'F');
      dbms_mview.refresh('pt_price_type', 'F');
      dbms_mview.refresh('pum_price_unit_master', 'F');
      dbms_mview.refresh('pym_payment_terms_master', 'F');
      dbms_mview.refresh('qat_quality_attributes', 'F');
      dbms_mview.refresh('qum_quantity_unit_master', 'F');
      dbms_mview.refresh('scd_sub_currency_detail', 'F');
      commit;
      dbms_mview.refresh('scm_service_charge_master', 'F');
      dbms_mview.refresh('sdm_strategy_definition_master', 'F');
      dbms_mview.refresh('sm_state_master', 'F');
      dbms_mview.refresh('ucm_unit_conversion_master', 'F');
      dbms_mview.refresh('wpc_weekly_prompt_calendar', 'F');
      dbms_mview.refresh('dtm_deal_type_master', 'F');
      commit;
      dbms_mview.refresh('du_derivative_underlying', 'F');
      -- dbms_mview.refresh('dtpm_deal_type_purpose_mapping','F');
      --dbms_mview.refresh('OVS_OPTION_VALUATION_SETUP', 'F');
      dbms_mview.refresh('mv_cfq_currency_forward_quotes', 'C');
      dbms_mview.refresh('cci_corp_currency_instrument', 'F');
      dbms_mview.refresh('mv_cfq_cci_cur_forward_quotes', 'C');
      commit;
      --Brokerage_Margin_Utilization Changes start
      dbms_mview.refresh('BRKMM_BROKER_MARGIN_MASTER', 'F');
      dbms_mview.refresh('BRKMD_BROKER_MARGIN_DETAIL', 'F');
      --  dbms_mview.refresh('SLS_STATIC_LIST_SETUP', 'F');
      --  dbms_mview.refresh('SLV_STATIC_LIST_VALUE', 'F');
      --Brokerage_Margin_Utilization Changes end
    end if;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'Procedure sp_gen_refresh_app_data',
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

  procedure sp_gen_delete_general_data
  --*****************************************************************************************************************************************
    --                procedure name                           : sp_delete_corporate_data
    --                author                                   : siva
    --                created date                             : 09th jan 2009
    --                purpose                                  : transfer transaction data into eod database
    --                parameters
    --
    --                pc_corporate_id                          corporate id
    --                pd_trade_date                            eod data
    --                pc_user_id                               user id
    --                pc_process                               process = 'eod'
    --
    --                modification history
    --                modified by                              :
    --                modified date                            :
    --                modify description                       :
    --*****************************************************************************************************************************************
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_user_id      varchar2,
   pc_process      varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    /* DELETE FROM cptn_corporate_prem_type_name
    WHERE  corporate_id = pc_corporate_id;*/
    delete from ak_corporate where corporate_id = pc_corporate_id;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'Procedure sp_gen_delete_general_data',
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

  procedure sp_gen_insert_general_data
  --*****************************************************************************************************************************************
    --                procedure name                           : sp_insert_derivative_data
    --                author                                   : siva
    --                created date                             : 09th jan 2009
    --                purpose                                  : transfer transaction data into eod database
    --                parameters
    --
    --                pc_corporate_id                          corporate id
    --                pd_trade_date                            eod data
    --                pc_user_id                               user id
    --                pc_process                               process = 'eod'
    --
    --                modification history
    --                modified by                              :
    --                modified date                            :
    --                modify description                       :
    --*****************************************************************************************************************************************
  (pc_corporate_id       in varchar2,
   pt_previous_pull_date timestamp,
   pt_current_pull_date  timestamp,
   pc_dbd_id             varchar2,
   pc_user_id            varchar2,
   pc_process            varchar2,
   pd_trade_date         date) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vc_log varchar2(100);
  begin
  vc_log:= 'Transfer axs data';
    insert into axs_action_summary
      (internal_action_ref_no,
       action_ref_no,
       prefix,
       suffix,
       middle_no,
       action_id,
       action_date,
       corporate_id,
       created_by,
       created_date,
       eff_date,
       status,
       cancelled_by,
       cancelled_date,
       updated_by,
       updated_date,
       parent_internal_action_ref_no,
       dbd_id,
       process)
      select axs.internal_action_ref_no,
             nvl(axs.action_ref_no, 'NA'),
             axs.prefix,
             axs.suffix,
             axs.middle_no,
             axs.action_id,
             axs.action_date,
             axs.corporate_id,
             axs.created_by,
             axs.created_date,
             axs.eff_date,
             axs.status,
             axs.cancelled_by,
             axs.cancelled_date,
             axs.updated_by,
             axs.updated_date,
             axs.parent_internal_action_ref_no,
             pc_dbd_id,
             pc_process
        from axs_action_summary@eka_appdb axs,
             axm_action_master@eka_appdb  axm
       where axs.eff_date is not null
         and created_date > pt_previous_pull_date
         and created_date <= pt_current_pull_date
            --  and axs.action_id <> 'LOGOUT_APP'
         and axs.corporate_id = pc_corporate_id
         and axs.action_id = axm.action_id
         and axm.is_required_for_eodeom = 'Y';
    commit;
    vc_log:= 'update axs data';
    for cur_axs_update in (select axs_tran.status,
                                  axs_tran.eff_date,
                                  axs_tran.internal_action_ref_no
                             from axs_action_summary@eka_appdb axs_tran,
                                  axm_action_master@eka_appdb  axm
                            where axs_tran.eff_date is not null
                              and axs_tran.updated_date >
                                  pt_previous_pull_date
                              and axs_tran.updated_date <=
                                  pt_current_pull_date
                              and axs_tran.corporate_id = pc_corporate_id
                              and axs_tran.created_date <=
                                  pt_previous_pull_date
                              and axs_tran.action_id = axm.action_id
                              and axm.is_required_for_eodeom = 'Y')
    loop
      update axs_action_summary axs
         set axs.status   = cur_axs_update.status,
             axs.eff_date = cur_axs_update.eff_date
       where axs.internal_action_ref_no =
             cur_axs_update.internal_action_ref_no
         and axs.dbd_id in
             (select dbd.dbd_id
                from dbd_database_dump dbd
               where dbd.corporate_id = pc_corporate_id
                 and dbd.process = pc_process
                 and dbd.trade_date <= pd_trade_date);
    end loop;
    commit;
  
    delete dqd_temp
     where dq_id in
           (select dq_id from dq_temp where corporate_id = pc_corporate_id);
    commit;
    delete dq_temp where corporate_id = pc_corporate_id;
    commit;
  vc_log:= 'Transfer quotes data 1..';
    insert into dq_temp
      (dq_id,
       trade_date,
       corporate_id,
       entry_type,
       instrument_id,
       price_source_id,
       created_date,
       updated_date,
       version,
       is_deleted,
       dbd_id)
      select dq_id,
             trade_date,
             corporate_id,
             entry_type,
             instrument_id,
             price_source_id,
             created_date,
             updated_date,
             version,
             is_deleted,
             pc_dbd_id
        from dq_derivative_quotes@eka_appdb dq
       where dq.corporate_id = pc_corporate_id;
    commit;
  
    sp_gather_stats('DQ_TEMP');
    --  AND    dq.created_date > pt_previous_pull_date
    --   AND    created_date <= pt_current_pull_date;
    /* FOR cur_dq_update IN (SELECT dq_tran.is_deleted,
                                 dq_tran.dq_id
                          FROM   dq_derivative_quotes@eka_appdb dq_tran
                          WHERE  dq_tran.updated_date >
                                 pt_previous_pull_date
                          AND    dq_tran.updated_date <=
                                 pt_current_pull_date
                          AND    dq_tran.corporate_id = pc_corporate_id
                          AND    dq_tran.created_date <=
                                 pt_previous_pull_date) LOOP
        UPDATE dq_derivative_quotes dq
        SET    dq.is_deleted = cur_dq_update.is_deleted
        WHERE  dq.dq_id = cur_dq_update.dq_id
        AND    dq.dbd_id IN
               (SELECT dbd.dbd_id
                 FROM   dbd_database_dump dbd
                 WHERE  dbd.corporate_id = pc_corporate_id
                 AND    dbd.process = pc_process
                 AND    dbd.trade_date <= pd_trade_date);
    END LOOP;*/
  vc_log:= 'Transfer quotes data 2..';
    insert into dqd_temp
      (dqd_id,
       dq_id,
       dr_id,
       available_price_id,
       price,
       price_unit_id,
       delta,
       gamma,
       theta,
       wega,
       is_deleted,
       charm,
       lambda,
       rho,
       volatility,
       riskfree_rate,
       interest_rate,
       spot_rate,
       is_manual,
       dbd_id)
      select dqd_id,
             dq_id,
             dr_id,
             available_price_id,
             price,
             price_unit_id,
             delta,
             gamma,
             theta,
             wega,
             is_deleted,
             charm,
             lambda,
             rho,
             volatility,
             riskfree_rate,
             interest_rate,
             spot_rate,
             is_manual,
             pc_dbd_id
        from dqd_derivative_quote_detail@eka_appdb dqd
       where dqd.dq_id in
             (select dq_id from dq_temp where dbd_id = pc_dbd_id)
         and nvl(dqd.price, 0) <> 0;
    commit;
  
    /*FOR cur_dqd_update IN (SELECT dqd_tran.dqd_id,
                                  dqd_tran.dq_id,
                                  dqd_tran.dr_id,
                                  dqd_tran.available_price_id,
                                  dqd_tran.price,
                                  dqd_tran.price_unit_id,
                                  dqd_tran.delta,
                                  dqd_tran.gamma,
                                  dqd_tran.theta,
                                  dqd_tran.wega,
                                  dqd_tran.is_deleted
                           FROM   dqd_derivative_quote_detail@eka_appdb dqd_tran,
                                  dq_derivative_quotes@eka_appdb        dq_tran
                           WHERE  dq_tran.updated_date >
                                  pt_previous_pull_date
                           AND    dq_tran.updated_date <=
                                  pt_current_pull_date
                           AND    dq_tran.corporate_id = pc_corporate_id
                           AND    dq_tran.created_date <=
                                  pt_previous_pull_date
                           AND    dqd_tran.dq_id = dq_tran.dq_id) LOOP
        UPDATE dqd_derivative_quote_detail dqd
        SET    dqd.price         = cur_dqd_update.price,
               dqd.price_unit_id = cur_dqd_update.price_unit_id,
               dqd.delta         = cur_dqd_update.delta,
               dqd.gamma         = cur_dqd_update.gamma,
               dqd.theta         = cur_dqd_update.theta,
               dqd.wega          = cur_dqd_update.wega,
               dqd.is_deleted    = cur_dqd_update.is_deleted
        WHERE  dqd.dq_id = cur_dqd_update.dq_id
        AND    dqd.dqd_id = cur_dqd_update.dqd_id
        AND    dqd.dr_id = cur_dqd_update.dr_id
        AND    dqd.dbd_id IN
               (SELECT dbd.dbd_id
                 FROM   dbd_database_dump dbd
                 WHERE  dbd.corporate_id = pc_corporate_id
                 AND    dbd.process = pc_process
                 AND    dbd.trade_date <= pd_trade_date);
    END LOOP;*/
  
    -----added on 05-Jun-2011, for the day/month/week drid's having same prompt date
    -- Example: for LME, as on 05-Jun-2011 trade date Dec-2011 will be Month DRID (with prompt date of 20-Dec-2011), when
    -- trade date moves 05-Oct-2011, 20-Dec-2011 will be Day DRID with Prompt date as 20-Dec-2011,
    -- So as on 5th Oct, we can't enter the quotes for Month DRID created on 05-Jun-2011,this time we have to
    -- consider the price entered for 20-Dec-2011 prompt date will be consider for month drid.
    vc_log:= 'Transfer quotes data 3..';
    insert into dqd_temp
      (dqd_id,
       dq_id,
       dr_id,
       available_price_id,
       price,
       price_unit_id,
       delta,
       gamma,
       theta,
       wega,
       is_deleted,
       charm,
       lambda,
       rho,
       volatility,
       riskfree_rate,
       interest_rate,
       spot_rate,
       is_manual,
       dbd_id)
      select dqd.dqd_id || new_drm.dr_id dqd_id,
             dqd.dq_id,
             new_drm.dr_id dr_id,
             dqd.available_price_id,
             dqd.price,
             dqd.price_unit_id,
             dqd.delta,
             dqd.gamma,
             dqd.theta,
             dqd.wega,
             dqd.is_deleted,
             dqd.charm,
             dqd.lambda,
             dqd.rho,
             dqd.volatility,
             dqd.riskfree_rate,
             dqd.interest_rate,
             dqd.spot_rate,
             dqd.is_manual,
             pc_dbd_id
        from dq_temp                               dq,
             drm_derivative_master                 drm,
             v_drm_multiple_prompt                 new_drm,
             dqd_derivative_quote_detail@eka_appdb dqd
       where dq.dbd_id = pc_dbd_id
         and nvl(dqd.price, 0) <> 0
         and dq.dq_id = dqd.dq_id
         and dqd.dr_id = drm.dr_id
         and drm.instrument_id = new_drm.instrument_id
         and drm.prompt_date = new_drm.prompt_date
         and drm.dr_id <> new_drm.dr_id
         and not exists
       (select dd.dq_id
                from dqd_temp dd
               where dd.dr_id = new_drm.dr_id
                 and dd.price_unit_id = dqd.price_unit_id
                 and dd.dbd_id = pc_dbd_id
                 and dd.dq_id = dq.dq_id
                 and dd.available_price_id = dqd.available_price_id
                 and dd.is_deleted = 'N'); -- as we already transfered into dqd of same drids
    ---end here
    commit;
    sp_gather_stats('DQD_TEMP');
  
    /* insert into cptn_corporate_prem_type_name
    (cptn_id,
     ptm_id,
     corporate_id,
     premium_type_display_name,
     is_active,
     is_deleted,
     product_id)
    select cptn_id,
           ptm_id,
           corporate_id,
           premium_type_display_name,
           is_active,
           is_deleted,
           product_id
      from cptn_corporate_prem_type_name@eka_appdb
     where corporate_id = pc_corporate_id;
     commit;*/
 vc_log:= 'Transfer ak..';     
    insert into ak_corporate
      (corporate_id,
       corporate_name,
       corporate_abbr,
       contact_person,
       email,
       website,
       corp_type,
       estd_year,
       no_of_employees,
       phone_no,
       fax_no,
       address1,
       address2,
       status,
       country,
       lang_code,
       status_eff_from,
       last_mod_date,
       time_zone,
       last_mod_user,
       city,
       state,
       preferredweightunit,
       fda_number,
       groupid,
       ekaowner,
       base_currency_name,
       region,
       per_equity,
       stop_loss,
       gbpid,
       default_cp,
       external_reference,
       bp_short_name,
       corp_short_name,
       base_cur_id,
       logo_path,
       logo_name,
       inv_cur_id,
       inv_qty_unit_id)
      select corporate_id,
             corporate_name,
             null corporate_abbr,
             null contact_person,
             null email,
             null website,
             null corp_type,
             null estd_year,
             null no_of_employees,
             null phone_no,
             null fax_no,
             null address1,
             null address2,
             null status,
             null country,
             lang_code,
             null status_eff_from,
             null last_mod_date,
             time_zone,
             null last_mod_user,
             null city,
             null state,
             null preferredweightunit,
             null fda_number,
             groupid,
             null ekaowner,
             cm.cur_code base_currency_name,
             null region,
             null per_equity,
             null stop_loss,
             null gbpid,
             null default_cp,
             null external_reference,
             null bp_short_name,
             corp_short_name,
             base_cur_id,
             null logo_path,
             null logo_name,
             inv_cur_id,
             null inv_qty_unit_id
        from ak_corporate@eka_appdb,
             cm_currency_master cm
       where corporate_id = pc_corporate_id
         and base_cur_id = cm.cur_id;
    commit;
    --- EOD process Quotes table
  
    begin
     vc_log:= 'Transfer eodeom quotes data ..';
      -- store the latest quotes other than Option Instrument
      insert into eodeom_derivative_quote_detail
        (corporate_id,
         process_id,
         eodeom_trade_date,
         dq_trade_date,
         dr_id,
         instrument_id,
         price_source_id,
         entry_type,
         price_unit_id,
         available_price_id,
         price,
         publishing_frequency,
         publishing_frequency_type,
         diff_days,
         price_freq_status,
         delta,
         gamma,
         theta,
         wega,
         charm,
         lambda,
         rho,
         volatility,
         riskfree_rate,
         interest_rate,
         spot_rate,
         quote_type,
         dbd_id)
        (select pc_corporate_id,
                null pc_process_id,
                pd_trade_date,
                trade_date,
                dr_id,
                instrument_id,
                price_source_id,
                entry_type,
                price_unit_id,
                available_price_id,
                price,
                publishing_frequency,
                publishing_frequency_type,
                diff_days,
                (case
                  when publishing_frequency_type = 'Month' then
                   case
                  when publishing_frequency * 30 > diff_days then
                   'NEW'
                  else
                   'OLD'
                end when publishing_frequency_type = 'Day' then case
                   when publishing_frequency > diff_days then
                    'NEW'
                   else
                    'OLD'
                 end when publishing_frequency_type = 'Hour' then case
                   when publishing_frequency / 24 > diff_days then
                    'NEW'
                   else
                    'OLD'
                 end end) price_freq_status,
                delta,
                gamma,
                theta,
                wega,
                charm,
                lambda,
                rho,
                volatility,
                riskfree_rate,
                interest_rate,
                spot_rate,
                quote_type,
                pc_dbd_id
           from (select dq.trade_date,
                        dqd.dr_id,
                        dq.instrument_id,
                        dq.price_source_id,
                        dq.entry_type,
                        dqd.price_unit_id,
                        dqd.available_price_id,
                        dqd.price,
                        ps.publishing_frequency,
                        ps.publishing_frequency_type,
                        --to_date(pd_trade_date, 'dd-mon-yyyy') -
                        pd_trade_date - dq.trade_date diff_days,
                        dqd.delta,
                        dqd.gamma,
                        dqd.theta,
                        dqd.wega,
                        dqd.charm,
                        dqd.lambda,
                        dqd.rho,
                        dqd.volatility,
                        dqd.riskfree_rate,
                        dqd.interest_rate,
                        dqd.spot_rate,
                        decode(nvl(dqd.is_manual, 'Y'),
                               'Y',
                               'INPUT',
                               'GENERATE') quote_type,
                        row_number() over(partition by dqd.dr_id, dqd.price_unit_id, dq.instrument_id, dq.entry_type, dq.price_source_id, dqd.available_price_id order by dq.trade_date desc) seq
                   from dq_temp                    dq,
                        dqd_temp                   dqd,
                        ps_price_source            ps,
                        drm_derivative_master      drm,
                        dim_der_instrument_master  dim,
                        irm_instrument_type_master irm
                  where dq.dq_id = dqd.dq_id
                    and dqd.dr_id = drm.dr_id
                    and dq.instrument_id = drm.instrument_id
                    and dq.price_source_id = ps.price_source_id
                    and dq.trade_date <= pd_trade_date
                    and dq.corporate_id = pc_corporate_id
                       --     and drm.instrument_id = div.instrument_id
                    and drm.instrument_id = dim.instrument_id
                    and dim.instrument_type_id = irm.instrument_type_id
                    and irm.instrument_type not in
                        ('Option Put', 'Option Call')
                       --    and div.is_deleted = 'N'
                       --   --   and div.price_source_id = dq.price_source_id
                       --      and div.price_unit_id = dqd.price_unit_id -- added as per the setup changes for DIV on 02-May-2011 release
                    and ps.is_active = 'Y'
                    and ps.is_deleted = 'N'
                    and drm.is_deleted = 'N'
                    and dq.dbd_id = pc_dbd_id
                    and dqd.dbd_id = pc_dbd_id
                    and dq.is_deleted = 'N'
                    and dqd.is_deleted = 'N')
          where seq = 1);
      commit;
      --- For Options quotes which are don;t have entry in OVS , or having entry with Options quotes as 'ManuallyEntered'
      for cc in (select dim.instrument_id,
                        nvl(ovs.option_quote_type_for_eod, 'ManuallyEntered') quote_type,
                        ovs.is_deleted
                   from dim_der_instrument_master  dim,
                        irm_instrument_type_master irm,
                        ovs_option_valuation_setup ovs
                  where dim.instrument_id = ovs.instrument_id(+)
                    and 'N' = ovs.is_deleted(+)
                    and dim.is_deleted = 'N'
                       --                    and dim.is_active = 'Y'
                    and dim.instrument_type_id = irm.instrument_type_id
                    and irm.instrument_type in ('Option Put', 'Option Call'))
      loop
        if cc.quote_type = 'ManuallyEntered' then
          --note : DQD.Is_manual = 'Y'  order by seq as per the trade date
          insert into eodeom_derivative_quote_detail
            (corporate_id,
             process_id,
             eodeom_trade_date,
             dq_trade_date,
             dr_id,
             instrument_id,
             price_source_id,
             entry_type,
             price_unit_id,
             available_price_id,
             price,
             publishing_frequency,
             publishing_frequency_type,
             diff_days,
             price_freq_status,
             delta,
             gamma,
             theta,
             wega,
             charm,
             lambda,
             rho,
             volatility,
             riskfree_rate,
             interest_rate,
             spot_rate,
             quote_type,
             dbd_id)
            (select pc_corporate_id,
                    null pc_process_id,
                    pd_trade_date,
                    trade_date,
                    dr_id,
                    instrument_id,
                    price_source_id,
                    entry_type,
                    price_unit_id,
                    available_price_id,
                    price,
                    publishing_frequency,
                    publishing_frequency_type,
                    diff_days,
                    (case
                      when publishing_frequency_type = 'Month' then
                       case
                      when publishing_frequency * 30 > diff_days then
                       'NEW'
                      else
                       'OLD'
                    end when publishing_frequency_type = 'Day' then case
                       when publishing_frequency > diff_days then
                        'NEW'
                       else
                        'OLD'
                     end when publishing_frequency_type = 'Hour' then case
                       when publishing_frequency / 24 > diff_days then
                        'NEW'
                       else
                        'OLD'
                     end end) price_freq_status,
                    delta,
                    gamma,
                    theta,
                    wega,
                    charm,
                    lambda,
                    rho,
                    volatility,
                    riskfree_rate,
                    interest_rate,
                    spot_rate,
                    quote_type,
                    pc_dbd_id
               from (select dq.trade_date,
                            dqd.dr_id,
                            dq.instrument_id,
                            dq.price_source_id,
                            dq.entry_type,
                            dqd.price_unit_id,
                            dqd.available_price_id,
                            dqd.price,
                            ps.publishing_frequency,
                            ps.publishing_frequency_type,
                            --to_date(pd_trade_date, 'dd-mon-yyyy') -
                            pd_trade_date - dq.trade_date diff_days,
                            dqd.delta,
                            dqd.gamma,
                            dqd.theta,
                            dqd.wega,
                            dqd.charm,
                            dqd.lambda,
                            dqd.rho,
                            dqd.volatility,
                            dqd.riskfree_rate,
                            dqd.interest_rate,
                            dqd.spot_rate,
                            decode(nvl(dqd.is_manual, 'Y'),
                                   'Y',
                                   'INPUT',
                                   'GENERATE') quote_type,
                            row_number() over(partition by dqd.dr_id, dqd.price_unit_id, dq.instrument_id, dq.entry_type, dq.price_source_id, dqd.available_price_id order by dq.trade_date desc) seq
                       from dq_temp                      dq,
                            dqd_temp                     dqd,
                            ps_price_source              ps,
                            drm_derivative_master        drm,
                            div_der_instrument_valuation div
                      where dq.dq_id = dqd.dq_id
                        and dqd.dr_id = drm.dr_id
                        and dq.instrument_id = drm.instrument_id
                        and dq.price_source_id = ps.price_source_id
                        and dq.trade_date <= pd_trade_date
                        and dq.corporate_id = pc_corporate_id
                        and drm.instrument_id = div.instrument_id
                        and drm.instrument_id = cc.instrument_id --cursor instument
                        and dqd.is_manual = 'Y'
                        and div.is_deleted = 'N'
                        and div.price_source_id = dq.price_source_id
                        and div.price_unit_id = dqd.price_unit_id -- added as per the setup changes for DIV on 02-May-2011 release
                        and ps.is_active = 'Y'
                        and ps.is_deleted = 'N'
                        and drm.is_deleted = 'N'
                        and dq.dbd_id = pc_dbd_id
                        and dqd.dbd_id = pc_dbd_id
                        and dq.is_deleted = 'N'
                        and dqd.is_deleted = 'N')
              where seq = 1);
        end if;
        if cc.quote_type = 'OptionValuation' then
          --note : DQD.Is_manual to be removed, and order by seq will change,
          -- order of quotes entered by 'GENERATE','INPUT', and trade_date
          insert into eodeom_derivative_quote_detail
            (corporate_id,
             process_id,
             eodeom_trade_date,
             dq_trade_date,
             dr_id,
             instrument_id,
             price_source_id,
             entry_type,
             price_unit_id,
             available_price_id,
             price,
             publishing_frequency,
             publishing_frequency_type,
             diff_days,
             price_freq_status,
             delta,
             gamma,
             theta,
             wega,
             charm,
             lambda,
             rho,
             volatility,
             riskfree_rate,
             interest_rate,
             spot_rate,
             quote_type,
             dbd_id)
            (select pc_corporate_id,
                    null pc_process_id,
                    pd_trade_date,
                    trade_date,
                    dr_id,
                    instrument_id,
                    price_source_id,
                    entry_type,
                    price_unit_id,
                    available_price_id,
                    price,
                    publishing_frequency,
                    publishing_frequency_type,
                    diff_days,
                    (case
                      when publishing_frequency_type = 'Month' then
                       case
                      when publishing_frequency * 30 > diff_days then
                       'NEW'
                      else
                       'OLD'
                    end when publishing_frequency_type = 'Day' then case
                       when publishing_frequency > diff_days then
                        'NEW'
                       else
                        'OLD'
                     end when publishing_frequency_type = 'Hour' then case
                       when publishing_frequency / 24 > diff_days then
                        'NEW'
                       else
                        'OLD'
                     end end) price_freq_status,
                    delta,
                    gamma,
                    theta,
                    wega,
                    charm,
                    lambda,
                    rho,
                    volatility,
                    riskfree_rate,
                    interest_rate,
                    spot_rate,
                    quote_type,
                    pc_dbd_id
               from (select dq.trade_date,
                            dqd.dr_id,
                            dq.instrument_id,
                            dq.price_source_id,
                            dq.entry_type,
                            dqd.price_unit_id,
                            dqd.available_price_id,
                            dqd.price,
                            ps.publishing_frequency,
                            ps.publishing_frequency_type,
                            --to_date(pd_trade_date, 'dd-mon-yyyy') -
                            pd_trade_date - dq.trade_date diff_days,
                            dqd.delta,
                            dqd.gamma,
                            dqd.theta,
                            dqd.wega,
                            dqd.charm,
                            dqd.lambda,
                            dqd.rho,
                            dqd.volatility,
                            dqd.riskfree_rate,
                            dqd.interest_rate,
                            dqd.spot_rate,
                            decode(nvl(dqd.is_manual, 'Y'),
                                   'Y',
                                   'INPUT',
                                   'GENERATE') quote_type,
                            row_number() over(partition by dqd.dr_id, dqd.price_unit_id, dq.instrument_id, dq.entry_type, dq.price_source_id, dqd.available_price_id order by decode(nvl(dqd.is_manual, 'Y'), 'N', 1, 2), dq.trade_date desc) seq
                       from dq_temp                      dq,
                            dqd_temp                     dqd,
                            ps_price_source              ps,
                            drm_derivative_master        drm,
                            div_der_instrument_valuation div
                      where dq.dq_id = dqd.dq_id
                        and dqd.dr_id = drm.dr_id
                        and dq.instrument_id = drm.instrument_id
                        and dq.price_source_id = ps.price_source_id
                        and dq.trade_date <= pd_trade_date
                        and dq.corporate_id = pc_corporate_id
                        and drm.instrument_id = div.instrument_id
                        and drm.instrument_id = cc.instrument_id --cursor instument
                        and div.is_deleted = 'N'
                        and div.price_source_id = dq.price_source_id
                        and div.price_unit_id = dqd.price_unit_id -- added as per the setup changes for DIV on 02-May-2011 release
                        and ps.is_active = 'Y'
                        and ps.is_deleted = 'N'
                        and drm.is_deleted = 'N'
                        and dq.dbd_id = pc_dbd_id
                        and dqd.dbd_id = pc_dbd_id
                        and dq.is_deleted = 'N'
                        and dqd.is_deleted = 'N')
              where seq = 1);
        end if;
      
      end loop;
      commit;
    end;
    vc_log:= 'Transfer eodeom currency quotes data ..';
    --record daily currency quotes at EODEOM_CURRENCY_FORWARD_QUOTES
    insert into eodeom_currency_forward_quotes
      (corporate_id,
       dbd_id,
       process_id,
       process,
       process_date,
       dr_id,
       prompt_date,
       trade_date,
       instrument_id,
       price_source_id,
       product_id,
       base_cur_id,
       quote_cur_id,
       rate,
       forward_point,
       is_spot)
      select t.corporate_id,
             pc_dbd_id dbd_id,
             null process_id,
             pc_process process,
             pd_trade_date process_date,
             t.dr_id,
             t.prompt_date,
             t.trade_date,
             t.instrument_id,
             t.price_source_id,
             t.product_id,
             t.base_cur_id,
             t.quote_cur_id,
             t.rate,
             t.forward_point,
             t.is_spot
        from (select mv_cfq.corporate_id,
                     mv_cfq.prompt_date,
                     mv_cfq.trade_date,
                     mv_cfq.dr_id_name,
                     mv_cfq.dr_id,
                     mv_cfq.instrument_id,
                     mv_cfq.instrument_name,
                     mv_cfq.price_source_id,
                     mv_cfq.product_id,
                     mv_cfq.currency_pair,
                     mv_cfq.base_cur_id,
                     mv_cfq.quote_cur_id,
                     mv_cfq.rate,
                     mv_cfq.forward_point,
                     mv_cfq.is_spot,
                     row_number() over(partition by mv_cfq.dr_id, mv_cfq.price_source_id order by mv_cfq.prompt_date, mv_cfq.trade_date desc) seq
                from mv_cfq_currency_forward_quotes mv_cfq,
                     ps_price_source                ps
               where mv_cfq.rate <> 0
                 and mv_cfq.corporate_id = pc_corporate_id
                 and mv_cfq.price_source_id = ps.price_source_id
                 and ps.is_active = 'Y'
                 and ps.is_deleted = 'N'
                 and 'TRUE' =
                     (case when mv_cfq.prompt_date = mv_cfq.trade_date and
                      mv_cfq.is_spot = 'N' then 'FALSE' else 'TRUE' end)
                 and mv_cfq.trade_date <= pd_trade_date) t
       where t.seq = 1;
    commit;
     vc_log:= 'Transfer fxs data ..';    
    --HDL_FX_settlement start
    insert into fxs_fx_settlement
      (internal_fx_settlement_ref_no,
       main_trade_int_fx_ref_no,
       matched_trade_int_fx_ref_no,
       amount,
       matched_trade_drid,
       settlement_type,
       corporate_id,
       created_by,
       modified_by,
       created_date,
       modified_date,
       trade_type,
       cur_id,
       leg_no,
       --process_id,
       is_deleted,
       dbd_id)
      select fxs.internal_fx_settlement_ref_no,
             fxs.main_trade_int_fx_ref_no,
             fxs.matched_trade_int_fx_ref_no,
             fxs.amount,
             fxs.matched_trade_drid,
             fxs.settlement_type,
             fxs.corporate_id,
             fxs.created_by,
             fxs.modified_by,
             fxs.created_date,
             fxs.modified_date,
             fxs.trade_type,
             fxs.cur_id,
             fxs.leg_no,
             --process_id
             'N',
             pc_dbd_id
        from fxs_fx_settlement@eka_appdb fxs
       where fxs.created_date > pt_previous_pull_date
         and fxs.created_date <= pt_current_pull_date
         and fxs.corporate_id = pc_corporate_id;
    commit;
       vc_log:= 'update fxs data ..';
    update fxs_fx_settlement fxs_eod
       set is_deleted = 'Y'
     where fxs_eod.dbd_id in
           (select dbd.dbd_id
              from dbd_database_dump dbd
             where dbd.corporate_id = pc_corporate_id
               and dbd.process = pc_process
               and dbd.trade_date <= pd_trade_date)
       and not exists
     (select 1
              from fxs_fx_settlement@eka_appdb fxs_app
             where fxs_app.internal_fx_settlement_ref_no =
                   fxs_eod.internal_fx_settlement_ref_no);
    commit;
    --HDL_FX_settlement end
       vc_log:= 'Transfer currency option quotes data ..';
    insert into coq_currency_option_quotes
      (coq_id,
       trade_date,
       corporate_id,
       instrument_id,
       price_source_id,
       created_date,
       updated_date,
       version,
       is_deleted,
       is_imported,
       dbd_id)
      select coq_id,
             trade_date,
             corporate_id,
             instrument_id,
             price_source_id,
             created_date,
             updated_date,
             version,
             is_deleted,
             is_imported,
             pc_dbd_id
        from coq_currency_option_quotes@eka_appdb coq
       where coq.created_date > pt_previous_pull_date
         and coq.created_date <= pt_current_pull_date
         and coq.corporate_id = pc_corporate_id;
    commit;
    vc_log:= 'update currency option quotes data ..';
    for cur_coq_update in (select coq_tran.is_deleted,
                                  coq_tran.coq_id
                             from coq_currency_option_quotes@eka_appdb coq_tran
                            where coq_tran.updated_date >
                                  pt_previous_pull_date
                              and coq_tran.updated_date <=
                                  pt_current_pull_date
                              and coq_tran.corporate_id = pc_corporate_id
                              and coq_tran.created_date <=
                                  pt_previous_pull_date)
    loop
      update coq_currency_option_quotes coq
         set coq.is_deleted = cur_coq_update.is_deleted
       where coq.coq_id = cur_coq_update.coq_id
         and coq.dbd_id in (select dbd.dbd_id
                              from dbd_database_dump dbd
                             where dbd.corporate_id = pc_corporate_id
                               and dbd.process = pc_process);
    end loop;
    commit;
    vc_log:= 'Transfer currency option quotes details data ..';    
    insert into coqd_cur_option_quote_detail
      (coqd_id,
       coq_id,
       dr_id,
       price,
       available_price_id,
       delta,
       gamma,
       theta,
       wega,
       is_deleted,
       is_imported,
       created_date,
       updated_date,
       option_premium_unit_id,
       dbd_id)
      select coqd_id,
             coq_id,
             dr_id,
             price,
             available_price_id,
             delta,
             gamma,
             theta,
             wega,
             is_deleted,
             is_imported,
             created_date,
             updated_date,
             option_premium_unit_id,
             pc_dbd_id
        from coqd_cur_option_quote_detail@eka_appdb coqd
       where coqd.coq_id in (select coq_id
                               from coq_currency_option_quotes
                              where dbd_id = pc_dbd_id);
    commit;
    vc_log:= 'update currency option quotes details data ..';
    for cur_coqd_update in (select coqd_tran.coqd_id,
                                   coqd_tran.coq_id,
                                   coqd_tran.dr_id,
                                   coqd_tran.available_price_id,
                                   coqd_tran.price,
                                   coqd_tran.delta,
                                   coqd_tran.gamma,
                                   coqd_tran.theta,
                                   coqd_tran.wega,
                                   coqd_tran.is_deleted
                              from coqd_cur_option_quote_detail@eka_appdb coqd_tran,
                                   coq_currency_option_quotes@eka_appdb   coq_tran
                             where coq_tran.updated_date >
                                   pt_previous_pull_date
                               and coq_tran.updated_date <=
                                   pt_current_pull_date
                               and coq_tran.corporate_id = pc_corporate_id
                               and coq_tran.created_date <=
                                   pt_previous_pull_date
                               and coqd_tran.coq_id = coq_tran.coq_id)
    loop
      update coqd_cur_option_quote_detail coqd
         set coqd.price      = cur_coqd_update.price,
             coqd.delta      = cur_coqd_update.delta,
             coqd.gamma      = cur_coqd_update.gamma,
             coqd.theta      = cur_coqd_update.theta,
             coqd.wega       = cur_coqd_update.wega,
             coqd.is_deleted = cur_coqd_update.is_deleted
       where coqd.coq_id = cur_coqd_update.coq_id
         and coqd.coqd_id = cur_coqd_update.coqd_id
         and coqd.dr_id = cur_coqd_update.dr_id
         and coqd.dbd_id in
             (select dbd.dbd_id
                from dbd_database_dump dbd
               where dbd.corporate_id = pc_corporate_id
                 and dbd.process = pc_process);
    end loop;
    commit;
    vc_log:= 'Transfer FFA quotes data ..';    
    insert into fq_freight_quotes
      (fq_id,
       trade_date,
       corporate_id,
       instrument_id,
       price_source_id,
       spot_price,
       spot_price_unit_id,
       created_date,
       updated_date,
       version,
       is_deleted,
       is_manual,
       dbd_id)
      select fq_id,
             trade_date,
             corporate_id,
             instrument_id,
             price_source_id,
             spot_price,
             spot_price_unit_id,
             created_date,
             updated_date,
             version,
             is_deleted,
             is_manual,
             pc_dbd_id
        from fq_freight_quotes@eka_appdb fq
       where fq.created_date > pt_previous_pull_date
         and fq.created_date <= pt_current_pull_date
         and fq.corporate_id = pc_corporate_id;
    commit;
    vc_log:= 'update FFA quotes data ..';  
    for cur_fq_update in (select fq_tran.is_deleted,
                                 fq_tran.spot_price,
                                 fq_tran.spot_price_unit_id,
                                 fq_tran.fq_id
                            from fq_freight_quotes@eka_appdb fq_tran
                           where fq_tran.updated_date >
                                 pt_previous_pull_date
                             and fq_tran.updated_date <=
                                 pt_current_pull_date
                             and fq_tran.corporate_id = pc_corporate_id
                             and fq_tran.created_date <=
                                 pt_previous_pull_date)
    loop
      update fq_freight_quotes fq
         set fq.is_deleted         = cur_fq_update.is_deleted,
             fq.spot_price         = cur_fq_update.spot_price,
             fq.spot_price_unit_id = cur_fq_update.spot_price_unit_id
       where fq.fq_id = cur_fq_update.fq_id
         and fq.dbd_id in (select dbd.dbd_id
                             from dbd_database_dump dbd
                            where dbd.corporate_id = pc_corporate_id
                              and dbd.process = pc_process);
    end loop;
    commit;
    vc_log:= 'Transfer FFA quotes details data ..';    
    insert into fqd_freight_quote_detail
      (fqd_id,
       fq_id,
       dr_id,
       settlement_price,
       settlement_price_unit_id,
       is_deleted,
       created_date,
       updated_date,
       is_manual,
       available_price_id,
       dbd_id)
      select fqd_id,
             fq_id,
             dr_id,
             settlement_price,
             settlement_price_unit_id,
             is_deleted,
             created_date,
             updated_date,
             is_manual,
             available_price_id,
             pc_dbd_id
        from fqd_freight_quote_detail@eka_appdb fqd
       where fqd.fq_id in
             (select fq_id from fq_freight_quotes where dbd_id = pc_dbd_id)
             and fqd.settlement_price is not null;
    commit;
    /*for cur_fqd_update in (select fqd_id,
                                  fqd_tran.fq_id,
                                  fqd_tran.dr_id,
                                  fqd_tran.settlement_price,
                                  fqd_tran.settlement_price_unit_id,
                                  fqd_tran.is_deleted
                             from fqd_freight_quote_detail@eka_appdb fqd_tran,
                                  fq_freight_quotes@eka_appdb        fq_tran
                            where fq_tran.updated_date >
                                  pt_previous_pull_date
                              and fq_tran.updated_date <=
                                  pt_current_pull_date
                              and fq_tran.corporate_id = pc_corporate_id
                              and fq_tran.created_date <=
                                  pt_previous_pull_date
                              and fqd_tran.fq_id = fq_tran.fq_id)
    loop
      update fqd_freight_quote_detail fqd
         set fqd.settlement_price         = cur_fqd_update.settlement_price,
             fqd.settlement_price_unit_id = cur_fqd_update.settlement_price_unit_id,
             fqd.is_deleted               = cur_fqd_update.is_deleted
       where fqd.fq_id = cur_fqd_update.fq_id
         and fqd.fqd_id = cur_fqd_update.fqd_id
         and fqd.dr_id = cur_fqd_update.dr_id
         and fqd.dbd_id in (select dbd.dbd_id
                              from dbd_database_dump dbd
                             where dbd.corporate_id = pc_corporate_id
                               and dbd.process = pc_process);
    end loop;*/-- above code commented as below code will take care for delete and insert new/updated fqd
    -- changes done on 16-jul-2013, 
    -- issue: import 4 month quotes, run eod, and update price for one month,and make new price for 3 new months
    -- old code will not insert the newly added price in fqd table in eod schema
    commit;
    vc_log:= 'update FFA quotes details data ..';    
    for cur_fqd_update in (select dbd_fq.dbd_id,
                                fq_tran.fq_id,
                                fq_tran.trade_date,
                                fq_tran.corporate_id,
                                fq_tran.instrument_id,
                                fq_tran.price_source_id,
                                fq_tran.spot_price,
                                fq_tran.spot_price_unit_id,
                                fq_eod.process_id
                           from fq_freight_quotes@eka_appdb fq_tran,
                                fq_freight_quotes           fq_eod,
                                dbd_database_dump           dbd, --current dbd details
                                dbd_database_dump           dbd_fq
                          where fq_tran.updated_date > dbd.start_date --pt_previous_pull_date
                            and fq_tran.updated_date <= dbd.end_date -- pt_current_pull_date
                            and fq_tran.corporate_id = dbd.corporate_id -- pc_corporate_id
                            and fq_tran.created_date <= dbd.start_date --pt_previous_pull_date
                            and dbd.corporate_id = pc_corporate_id
                            and dbd.dbd_id = pc_dbd_id
                            and fq_tran.fq_id = fq_eod.fq_id
                            and fq_tran.corporate_id = fq_eod.corporate_id
                            and fq_eod.dbd_id = dbd_fq.dbd_id
                            and dbd_fq.corporate_id = pc_corporate_id
                            and dbd_fq.process = pc_process)
  loop
    delete from fqd_freight_quote_detail fqd
     where fqd.fq_id = cur_fqd_update.fq_id
       and fqd.dbd_id = cur_fqd_update.dbd_id;
    dbms_output.put_line('DBD id:=' || cur_fqd_update.dbd_id ||
                         ' FQ id:= ' || cur_fqd_update.fq_id ||
                         ' no of records deleted ' || sql%rowcount);
    commit;
    insert into fqd_freight_quote_detail
      (fqd_id,
       fq_id,
       dr_id,
       settlement_price,
       settlement_price_unit_id,
       is_deleted,
       created_date,
       updated_date,
       is_manual,
       available_price_id,
       dbd_id,
       process_id)
      select fqd.fqd_id,
             fqd.fq_id,
             fqd.dr_id,
             fqd.settlement_price,
             fqd.settlement_price_unit_id,
             fqd.is_deleted,
             fqd.created_date,
             fqd.updated_date,
             fqd.is_manual,
             fqd.available_price_id,
             cur_fqd_update.dbd_id,
             cur_fqd_update.process_id
        from fqd_freight_quote_detail@eka_appdb fqd
       where fqd.fq_id = cur_fqd_update.fq_id
       and fqd.settlement_price is not null;
    dbms_output.put_line('DBD id:=' || cur_fqd_update.dbd_id ||
                         ' FQ id:= ' || cur_fqd_update.fq_id ||
                         ' no of records transfered ' || sql%rowcount);
    commit;
  end loop;
   vc_log:= 'General data Transfer completed ..';
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'Procedure sp_gen_insert_general_data',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||'@' ||vc_log,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_mark_axsdata(pc_corporate_id varchar2,
                            pc_eodeom_id    varchar2,
                            pd_trade_date   date,
                            pc_process      varchar2,
                            pt_starttime    timestamp,
                            pt_endtime      timestamp) is
    /******************************************************************************************************************************************
    Procedure Name                            : sp_mark_axsdata
    Author                                    : Siva
    Created Date                              : 28th Jun 2013
    Purpose                                   : To mark AXS data used for eodeom process
    
    Parameters
    pc_corporate_id                           : Corporate ID
    pd_trade_date                             : EOD Date ID
    pc_process                                : Process
    
    Modification History
    Modified Date                             :
    Modified By                               :
    Modify Description                        :
    ******************************************************************************************************************************************/
  begin
    -- To update the DB Transfer complited status back to transaction schema
  
    insert into eod_eom_axsdata@eka_appdb
      (corporate_id,
       internal_action_ref_no,
       trade_date,
       process,
       eodeom_id)
      select corporate_id,
             internal_action_ref_no,
             pd_trade_date,
             pc_process,
             pc_eodeom_id
        from axs_action_summary@eka_appdb axs,
             axm_action_master@eka_appdb  axm
       where axs.created_date > pt_starttime
         and axs.created_date <= pt_endtime
         and axs.corporate_id = pc_corporate_id
         and axs.action_id = axm.action_id
         and axm.is_required_for_eodeom = 'Y';
    commit;
    for cur_axs_update in (select axs_tran.internal_action_ref_no
                             from axs_action_summary@eka_appdb axs_tran,
                                  axm_action_master@eka_appdb  axm
                            where axs_tran.updated_date > pt_starttime
                              and axs_tran.updated_date <= pt_endtime
                              and axs_tran.corporate_id = pc_corporate_id
                              and axs_tran.created_date <= pt_starttime
                              and axs_tran.action_id = axm.action_id
                              and axm.is_required_for_eodeom = 'Y')
    loop
      update eod_eom_axsdata@eka_appdb axs
         set axs.updated_eodeom_id = pc_eodeom_id
       where axs.internal_action_ref_no =
             cur_axs_update.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.process = pc_process;
    end loop;
    commit;
  exception
    when others then
      null;
  end;

  procedure sp_gen_gather_stats is
  begin
    sp_gather_stats('axs_action_summary');
    sp_gather_stats('DQ_TEMP');
    sp_gather_stats('DQD_TEMP');
    sp_gather_stats('eodeom_derivative_quote_detail');
    sp_gather_stats('eodeom_currency_forward_quotes');
    sp_gather_stats('ak_corporate');
    --   sp_gather_stats('cptn_corporate_prem_type_name');
  end;
end pkg_gen_process; 
/
