create or replace package "PKG_EXECUTE_EOD" is

  procedure sp_execute_eod(pc_corporate_id       varchar2,
                           pc_action             varchar2,
                           pt_previous_pull_date timestamp,
                           pt_current_pull_date  timestamp,
                           pc_user_id            varchar2,
                           pd_trade_date         date,
                           pc_eod_status         out varchar2);

  procedure sp_record_cost(pc_corporate_id varchar2, pd_trade_date date);

  procedure sp_record_expired_drid(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process      varchar2);

  procedure sp_insert_eod_error_log(pc_corporate_id     varchar2,
                                    pc_submodule_name   varchar2,
                                    pc_exception_code   varchar2,
                                    pc_data_missing_for varchar2,
                                    pc_trade_ref_no     varchar2,
                                    pc_process          varchar2,
                                    pc_process_run_by   varchar2,
                                    pd_trade_date       date);

  procedure sp_mark_dumps_status(pc_corporate_id varchar2,
                                 pd_trade_date   date);
  procedure sp_mark_process_status(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process      varchar2,
                                   pc_action       varchar2,
                                   pc_eod_status   varchar2);
  procedure sp_mark_process_count(pc_corporate_id varchar2,
                                  pc_process      varchar2,
                                  pd_trade_date   date);

  procedure sp_refresh_mv;
end pkg_execute_eod; 
/
create or replace package body "PKG_EXECUTE_EOD" is

  procedure sp_execute_eod(pc_corporate_id       in varchar2,
                           pc_action             varchar2,
                           pt_previous_pull_date timestamp,
                           pt_current_pull_date  timestamp,
                           pc_user_id            varchar2,
                           pd_trade_date         date,
                           pc_eod_status         out varchar2) is
    vn_error_count            number;
    vn_error_only_error_count number;
    vc_process_status         varchar2(10) := 'NA';
  begin
    vn_error_count            := 0;
    vn_error_only_error_count := 0;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'Before calling EOD sp_execute_process, pc_action ' ||
                          pc_action || ' pt_previous_pull_date ' ||
                          pt_previous_pull_date || ' pt_current_pull_date ' ||
                          pt_current_pull_date,
                          1);
    pkg_execute_process.sp_execute_process@eka_eoddb(pc_corporate_id,
                                                     pc_action,
                                                     'EOD',
                                                     pt_previous_pull_date,
                                                     pt_current_pull_date,
                                                     pc_user_id,
                                                     pd_trade_date);
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'Before calling sp_mark_dumps_status',
                          2);
    sp_mark_dumps_status(pc_corporate_id, pd_trade_date);
  
    begin
      select count(*)
        into vn_error_count
        from eel_eod_eom_exception_log@eka_eoddb eel
       where eel.corporate_id = pc_corporate_id
         and eel.process = 'EOD'
         and nvl(eel.error_type, 'Error') = 'Error'
         and eel.trade_date = pd_trade_date;
      select count(*)
        into vn_error_only_error_count
        from eel_eod_eom_exception_log@eka_eoddb eel
       where eel.corporate_id = pc_corporate_id
         and eel.process = 'EOD'
         and eel.trade_date = pd_trade_date
         and nvl(eel.error_type, 'Error') = 'Error';
    exception
      when others then
        pc_eod_status             := 'Code:' || sqlcode || 'Message:' ||
                                     sqlerrm;
        vn_error_count            := 0;
        vn_error_only_error_count := 0;
    end;
   /* sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'error count check completed ' ||
                          ' vn_error_count =' || vn_error_count ||
                          ' vn_error_only_error_count ' ||
                          vn_error_only_error_count || ' pc_eod_status ' ||
                          pc_eod_status,
                          3);*/
    if pc_action = 'PRECHECK' then
      if vn_error_count = 0 then
        pc_eod_status := 'Precheck Success, Run the EOD';
      else
        if vn_error_only_error_count > 0 then
          pc_eod_status := 'Precheck Completed, User input required';
        else
          pc_eod_status := 'Precheck Completed With Warnings';
        end if;
      end if;
    elsif pc_action = 'PRECHECK_RUN' then
      if vn_error_count = 0 then
        pc_eod_status := 'EOD Process Success,Awaiting Cost Entry';
        sp_record_expired_drid(pc_corporate_id, pd_trade_date, 'EOD');
      else
        if vn_error_only_error_count > 0 then
          pc_eod_status := 'Precheck Completed, User input required';
        else
          pc_eod_status := 'Precheck Completed With Warnings';
        end if;
      end if;
    elsif pc_action = 'RUN' then
      if vn_error_count = 0 then
        pc_eod_status := 'EOD Process Success,Awaiting Cost Entry';
        sp_record_expired_drid(pc_corporate_id, pd_trade_date, 'EOD');
      else
        pc_eod_status := 'Precheck Completed, User input required';
      end if;
    end if;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          ' End of execute eod pkg ' || ' pc_eod_status ' ||
                          pc_eod_status,
                          4);
    vc_process_status := pkg_process_status.sp_get@eka_eoddb(pc_corporate_id,
                                                             'EOD',
                                                             pd_trade_date);
    if vc_process_status = 'Cancel' then
      pc_eod_status := 'EOD Cancelled';
    end if;
    sp_mark_process_status(pc_corporate_id,
                           pd_trade_date,
                           'EOD',
                           pc_action,
                           pc_eod_status);
    if pc_eod_status in ('EOD Processed Successfully',
        'EOD Process Success,Awaiting Cost Entry',
        'EOM Processed Successfully',
        'EOM Process Success,Awaiting Cost Entry') then
      sp_mark_process_count(pc_corporate_id, 'EOD', pd_trade_date);
    end if;
    sp_refresh_mv;    
  exception
    when others then
      sp_mark_process_status(pc_corporate_id,
                             pd_trade_date,
                             'EOD',
                             pc_action,
                             pc_eod_status);
  end;

  procedure sp_record_cost(pc_corporate_id varchar2, pd_trade_date date) is
  begin
    begin
      pkg_execute_process.sp_record_misc_cost@eka_eoddb(pc_corporate_id,
                                                        pd_trade_date,
                                                        'EOD');
    
    end;
  end;

  procedure sp_record_expired_drid
  --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_settle_future_trades
    --        Author                                    : Janna
    --        Created Date                              : 14th July 2009
    --        Purpose                                   : Updates Future Trades as Settled once EOD is completed
    --
    --        Description                               : Trades are marked as Settled first in
    --                                                    EOD schema. The currency trades which are settled
    --                                                    in this EOD are stored in SFT table
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pd_trade_date                             : EOD Date
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
  (pc_corporate_id varchar2, pd_trade_date date, pc_process varchar2) is
  begin
    --siva commented below to do
    /*update ct_currency_trade ct
    set    ct.status = 'SETTLED'
    where  ct.ct_id in (select ct_id
                        from   eci_expired_ct_id@eka_eoddb
                        where  corporate_id = pc_corporate_id and
                               trade_date >
                               (select max(trade_date)
                                from   tdc_trade_date_closure@eka_eoddb
                                where  corporate_id = pc_corporate_id and
                                       trade_date < pd_trade_date) and
                               trade_date <= pd_trade_date);
    commit;*/
    insert into eci_expired_ct_id
      (corporate_id, ct_id, trade_date, process_id, process)
      select corporate_id,
             ct_id,
             trade_date,
             process_id,
             process
        from eci_expired_ct_id@eka_eoddb eci
       where corporate_id = pc_corporate_id
         and trade_date = pd_trade_date
         and process = pc_process;
    commit;
    insert into edi_expired_dr_id
      (corporate_id, dr_id, trade_date, process_id, process)
      select corporate_id,
             dr_id,
             trade_date,
             process_id,
             process
        from edi_expired_dr_id@eka_eoddb edi
       where corporate_id = pc_corporate_id
         and trade_date = pd_trade_date
         and process = pc_process;
    commit;
  exception
    when others then
      null;
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
   /* sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'inside marking eod_dump_status as COMPLETED for pc_corporate_id ' ||
                          pc_corporate_id || '-pd_trade_date ' ||
                          pd_trade_date,
                          2);*/
    update eod_end_of_day_details
       set eod_dump_status = 'COMPLETED'
     where corporate_id = pc_corporate_id
       and as_of_date = pd_trade_date;
    --       and eod_dump_status <> 'COMPLETED';
    commit;
  exception
    when others then
      update eod_end_of_day_details
         set eod_dump_status = 'COMPLETED'
       where corporate_id = pc_corporate_id
         and as_of_date = pd_trade_date;
      commit;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            'Exception when others while marking eod_dump_status as COMPLETED',
                            2);
  end;
  procedure sp_mark_process_status(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process      varchar2,
                                   pc_action       varchar2,
                                   pc_eod_status   varchar2) is
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
   vc_eod_eom_id         varchar2(15);
   pc_eodeom_status      varchar2(100);
  begin
  vc_eod_eom_id := 'NA';
    -- To update the DB Transfer complited status back to transaction schema
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'marking process_dump_status as COMPLETED for pc_corporate_id ' ||
                          pc_corporate_id || '-pd_trade_date ' ||
                          pd_trade_date,
                          2);
    --     pc_corporate_id, pd_trade_date  pc_process, pc_action ,pc_eod_status
    begin
      if pc_eod_status in ('EOD Processed Successfully',
          'EOD Process Success,Awaiting Cost Entry',
          'EOM Processed Successfully',
          'EOM Process Success,Awaiting Cost Entry') then
        insert into eod_eom_process_count
          (corporate_id,
           trade_date,
           process,
           created_date,
           processing_status)
        values
          (pc_corporate_id,
           pd_trade_date,
           pc_process,
           sysdate,
           pc_eod_status);
      end if;
    exception
      when others then
        sp_eodeom_process_log(pc_corporate_id,
                              pd_trade_date,
                              'Error while insert into eod_eom_process_count' ||
                              pc_eod_status || ' ' || pc_process || ' ' ||
                              sqlerrm,
                              2);
    end;
     begin
       if pc_process = 'EOD' then
         select max(eod.eod_id)
           into vc_eod_eom_id
           from eod_end_of_day_details eod
          where eod.corporate_id = pc_corporate_id
            and eod.as_of_date = pd_trade_date;
       else
         select max(eom.eom_id)
           into vc_eod_eom_id
           from eom_end_of_month_details eom
          where eom.corporate_id = pc_corporate_id
            and eom.as_of_date = pd_trade_date;
       end if;
     exception
       when others then
         vc_eod_eom_id := 'NA';
     end;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'vc_eod_eom_id ' || vc_eod_eom_id,2);     
    if pc_action in ('PRECHECK', 'PRECHECK_RUN', 'RUN') then
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'pc_action ' || pc_action || ' pc_eod_status '||pc_eod_status,2);     
      if pc_process = 'EOD' then
        update eod_end_of_day_details
           set processing_status = pc_eod_status
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
        update eodh_end_of_day_history eodh
           set eodh.processing_status = pc_eod_status
         where eodh.eod_id = vc_eod_eom_id
             and eodh.corporate_id = pc_corporate_id
             and eodh.as_of_date = pd_trade_date;
      else
        update eom_end_of_month_details
           set processing_status = pc_eod_status
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
        update eomh_end_of_month_history eomh
           set eomh.processing_status = pc_eod_status
         where eomh.eom_id =vc_eod_eom_id
              and eomh.corporate_id = pc_corporate_id
             and eomh.as_of_date = pd_trade_date;
      end if;
    else
      if pc_process = 'EOD' then
         if pc_eod_status is null then
            pc_eodeom_status := 'EOD Rolled Back';
          else
            pc_eodeom_status := pc_eod_status;
         end if;
        update eodh_end_of_day_history eodh
           set eodh.processing_status = pc_eodeom_status
         where eodh.corporate_id = pc_corporate_id
             and eodh.as_of_date = pd_trade_date
            and (eodh.processing_status like '%Running%' or
                       eodh.processing_status like '%Cancelling%' or
                       eodh.processing_status like '%Rolling%' or eodh.processing_status is null );
        delete from eod_end_of_day_details eod
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
      else
         if pc_eod_status is null then
            pc_eodeom_status := 'EOM Rolled Back';
          else
            pc_eodeom_status := pc_eod_status;
         end if;        
         update eomh_end_of_month_history eomh
           set eomh.processing_status = pc_eodeom_status
         where eomh.corporate_id = pc_corporate_id
             and eomh.as_of_date = pd_trade_date
             and (eomh.processing_status like '%Running%' or
                       eomh.processing_status like '%Cancelling%' or
                       eomh.processing_status like '%Rolling%' or  eomh.processing_status is null);
        delete from eom_end_of_month_details eom
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
      end if;
    end if;
    commit;
  exception
    when others then
      if pc_process = 'EOD' then
        update eod_end_of_day_details
           set processing_status = pc_eod_status
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
        update eodh_end_of_day_history eodh
           set eodh.processing_status = pc_eod_status
         where eodh.eod_id in
               (select eod.eod_id
                  from eod_end_of_day_details eod
                 where eod.corporate_id = pc_corporate_id
                   and eod.as_of_date = pd_trade_date)
             and eodh.corporate_id = pc_corporate_id
             and eodh.as_of_date = pd_trade_date;
      else
        update eom_end_of_month_details
           set processing_status = pc_eod_status
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
        update eomh_end_of_month_deta_history eomh
           set eomh.processing_status = pc_eod_status
         where eomh.eom_id in
               (select eom.eom_id
                  from eom_end_of_month_details eom
                 where eom.corporate_id = pc_corporate_id
                   and eom.as_of_date = pd_trade_date)
             and eomh.corporate_id = pc_corporate_id
             and eomh.as_of_date = pd_trade_date;
      end if;
      commit;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            'Exception while marking processing status in eod/eom table :' ||
                            pc_eod_status || ' ' || sqlerrm,
                            2);
  end;
  procedure sp_insert_eod_error_log(pc_corporate_id     varchar2,
                                    pc_submodule_name   varchar2,
                                    pc_exception_code   varchar2,
                                    pc_data_missing_for varchar2,
                                    pc_trade_ref_no     varchar2,
                                    pc_process          varchar2,
                                    pc_process_run_by   varchar2,
                                    pd_trade_date       date) is
    pragma autonomous_transaction;
  begin
    if pc_corporate_id is not null then
      insert into eel_eod_eom_exception_log@eka_eoddb
        (corporate_id,
         submodule_name,
         exception_code,
         data_missing_for,
         trade_ref_no,
         process,
         process_run_by,
         process_run_date,
         trade_date)
      values
        (pc_corporate_id,
         pc_submodule_name,
         pc_exception_code,
         pc_data_missing_for,
         pc_trade_ref_no,
         pc_process,
         pc_process_run_by,
         sysdate,
         pd_trade_date);
    end if;
    commit;
  exception
    when others then
      rollback;
  end;
  procedure sp_mark_process_count(pc_corporate_id varchar2,
                                  pc_process      varchar2,
                                  pd_trade_date   date) is
    pragma autonomous_transaction;
  begin
    if pc_corporate_id is not null then
      for cc in (select epc.corporate_id,
                        epc.trade_date,
                        epc.process,
                        count(*) process_count
                   from eod_eom_process_count epc
                  where epc.corporate_id = pc_corporate_id
                    and epc.process = pc_process
                    and epc.trade_date = pd_trade_date
                  group by epc.corporate_id,
                           epc.trade_date,
                           epc.process)
      loop
        update tdc_trade_date_closure@eka_eoddb tdc
           set tdc.process_run_count = cc.process_count
         where tdc.corporate_id = pc_corporate_id
           and tdc.trade_date = pd_trade_date
           and tdc.process = pc_process;
      end loop;
    end if;
    commit;
  exception
    when others then
      rollback;
  end;
  procedure sp_refresh_mv is
  
    /******************************************************************************************************************************************
    Procedure Name                            : sp_refresh_mv
    Author                                    : Siva
    Created Date                              : 29th Jul 2011
    Purpose                                   : To refresh mv available in app db schema
    
    Parameters
    
    Modification History
    Modified Date                             :
    Modified By                               :
    Modify Description                        :
    ******************************************************************************************************************************************/
  begin
    sp_eodeom_process_log('NA',sysdate,'MV Refresh Started..',0);
    dbms_mview.refresh('mv_dm_phy_open', 'C');
    dbms_mview.refresh('mv_dm_phy_stock', 'C');
    dbms_mview.refresh('mv_dm_phy_derivative', 'c');
    dbms_mview.refresh('mv_fact_phy_inv_valuation', 'c');
    dbms_mview.refresh('mv_fact_bm_phy_open_pnl', 'c');
    dbms_mview.refresh('mv_fact_bm_phy_stock_pnl', 'c');
    dbms_mview.refresh('mv_fact_derivative_realized', 'c');
    dbms_mview.refresh('mv_fact_derivative_unrealized', 'c');
    dbms_mview.refresh('MV_FACT_PHYSICAL_UNREALIZED', 'c');
    dbms_mview.refresh('MV_FACT_UNREALIZED', 'c');
    -------------------------------------------------------
    dbms_mview.refresh('MV_LATEST_EOD_DATES', 'c');
    dbms_mview.refresh('MV_TRPNL_CCY_BY_INSTRUMENT', 'c');
    dbms_mview.refresh('MV_TRPNL_DRT_BY_INSTRUMENT', 'c');
    dbms_mview.refresh('MV_TRPNL_NET_BY_PROFITCENTER', 'c');
    dbms_mview.refresh('MV_TRPNL_PHY_BY_PRODUCT', 'c');
    dbms_mview.refresh('MV_UNPNL_CCY_BY_INSTRUMENT', 'c');
    dbms_mview.refresh('MV_UNPNL_DRT_BY_INSTRUMENT', 'c');
    dbms_mview.refresh('MV_UNPNL_NET_BY_PROFITCENTER', 'c');
    dbms_mview.refresh('MV_UNPNL_PHY_BY_PRODUCT', 'c');
    dbms_mview.refresh('MV_UNPNL_PHY_CHANGE_BY_TRADE', 'c');
    dbms_mview.refresh('MV_BI_UPAD', 'c');
    dbms_mview.refresh('MV_FACT_BROKER_MARGIN_UTIL', 'c');
    ------------------------------------------------------------
    dbms_mview.refresh('MV_BI_DERIVATIVE_JOURNAL_EOM', 'c');
    dbms_mview.refresh('MV_BI_DERIVATIVE_JOURNAL_EOD', 'c');
    dbms_mview.refresh('MV_BI_DER_PHY_PFC_JOURNAL_EOM', 'c');
    dbms_mview.refresh('MV_BI_DER_PHY_PFC_JOURNAL_EOD', 'c');
    dbms_mview.refresh('MV_BI_DER_BOOK_JOURNAL_EOM', 'c');
    dbms_mview.refresh('MV_BI_DER_BOOK_JOURNAL_EOD', 'c');
    dbms_mview.refresh('mv_bi_physical_risk_pos_eod', 'c');
    dbms_mview.refresh('mv_bi_physical_risk_pos_eom', 'c');
    dbms_mview.refresh('mv_bi_phy_cont_journal_eod', 'c');
    dbms_mview.refresh('mv_bi_phy_cont_journal_eom', 'c');
    dbms_mview.refresh('MV_BI_PHY_BOOK_JOURNAL_EOD', 'c');
    dbms_mview.refresh('MV_BI_PHY_BOOK_JOURNAL_EOM', 'c');
    dbms_mview.refresh('MV_BI_DER_PNL_EODEOM', 'c');
    commit;
    sp_eodeom_process_log('NA',sysdate,'MV Refresh Completed..',0);    
  exception
    when others then
      sp_eodeom_process_log('NA',
                            sysdate,
                            'Exception when refresh sp_refresh_mv as' ||
                            sqlerrm,
                            2);
      commit;
    
  end;
end; 
/
