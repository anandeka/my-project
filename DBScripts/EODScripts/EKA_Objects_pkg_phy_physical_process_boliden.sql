create or replace package pkg_phy_physical_process is
----pkg_phy_physical_process for boliden specific
  gvc_previous_process_id varchar2(15);

  gvc_dbd_id varchar2(15);

  gvc_process varchar2(10);

  gvc_base_cur_decimals number;

  gvc_prev_eod_ref_no_mig varchar2(15);

  gvc_prev_eom_ref_no_mig varchar2(15);

  gvc_previous_process_date date;

  procedure sp_process_run(pc_corporate_id varchar2,
                           pd_trade_date   date,
                           pc_process_id   varchar2,
                           pc_user_id      varchar2,
                           pc_process      varchar2,
                           pc_dbd_id       varchar2);

  procedure sp_mark_process_id(pc_corporate_id varchar2,
                               pc_process_id   varchar2,
                               pc_user_id      varchar2,
                               pd_trade_date   date);

  procedure sp_calc_secondary_cost(pc_corporate_id varchar2,
                                   pc_process_id   varchar2,
                                   pc_user_id      varchar2,
                                   pd_trade_date   date);

  procedure sp_calc_m2m_cost(pc_corporate_id varchar2,
                             pd_trade_date   date,
                             pc_process_id   varchar2,
                             pc_user_id      varchar2);
  procedure sp_calc_m2m_conc_cost(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process_id   varchar2,
                                  pc_user_id      varchar2);

  procedure sp_calc_m2m_tolling_extn_cost(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2);

  procedure sp_process_rollback(pc_corporate_id varchar2,
                                pc_process      varchar2,
                                pd_trade_date   date,
                                pc_dbd_id       varchar2,
                                pc_process_id   varchar2);
  procedure sp_phy_rebuild_stats;

end; 
/
create or replace package body pkg_phy_physical_process is
-- pkg_phy_physical_process for boliden specific.....
  procedure sp_process_run(pc_corporate_id varchar2,
                           pd_trade_date   date,
                           pc_process_id   varchar2,
                           pc_user_id      varchar2,
                           pc_process      varchar2, --eod or eom
                           pc_dbd_id       varchar2
                           ------------------------------------------------------------------------------------------
                           --        procedure name                            : sp_process_run
                           --        author                                    : Jana
                           --        created date                              : 10 th jan 2011
                           --        purpose                                   : calls all procedures for eod
                           --
                           --        parameters
                           --        pc_corporate_id                           : corporate id
                           --        pd_trade_date                             : trade date
                           --        pc_process_id                             : eod/eom reference no
                           --
                           --        modification history
                           --        modified date                             :
                           --        modified by                               :
                           --        modify description                        :
                           --------------------------------------------------------------------------------------------
                           ) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_logno           number := 0;
    vc_err_msg         varchar2(1000);
    vc_prev_eod_id     varchar2(15);
    vc_prev_eod_date   date;
    vc_prev_eom_id     varchar2(15);
    vc_prev_eom_date   date;
    vn_error_count     number;
  begin
    gvc_process    := pc_process;
    vn_error_count := 0;
    vc_err_msg     := 'Before gvc_previous_process_id ';
    if gvc_process = 'EOD' then
      begin
        select tdc.process_id,
               tdc.trade_date
          into vc_prev_eod_id,
               vc_prev_eod_date
          from tdc_trade_date_closure tdc
         where tdc.corporate_id = pc_corporate_id
           and process = pc_process
           and tdc.trade_date =
               (select max(trade_date)
                  from tdc_trade_date_closure
                 where corporate_id = pc_corporate_id
                   and trade_date < pd_trade_date
                   and process = pc_process);
      exception
        when no_data_found then
          select seq_eod.nextval into vc_prev_eod_id from dual;
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
             pc_process);
      end;
      vc_err_msg := 'Before vc_prev_eom_id/date ';
    else
      begin
        -- To get the Previous EOM Process ID
        select tdc.process_id,
               tdc.trade_date
          into vc_prev_eom_id,
               vc_prev_eom_date
          from tdc_trade_date_closure tdc
         where tdc.corporate_id = pc_corporate_id
           and process = 'EOM'
           and tdc.trade_date = (select max(trade_date)
                                   from tdc_trade_date_closure
                                  where corporate_id = pc_corporate_id
                                    and trade_date < pd_trade_date
                                    and process = 'EOM');
      exception
        when no_data_found then
          select seq_eod.nextval into vc_prev_eom_id from dual;
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
             vc_prev_eom_id,
             'EOM');
          vc_prev_eom_date := to_date('01-Jan-2000', 'dd-Mon-yyyy');
      end;
    end if;
    commit;
    if pc_process = 'EOD' then
      gvc_previous_process_id   := vc_prev_eod_id;
      gvc_previous_process_date := vc_prev_eod_date;
    else
      gvc_previous_process_id   := vc_prev_eom_id;
      gvc_previous_process_date := vc_prev_eom_date;
    end if;
    -- get the dump id
    gvc_dbd_id := pc_dbd_id;
    --
    -- get the base currency decinals
    --
    vc_err_msg := 'Before base currency decimals ';
    select cm.decimals
      into gvc_base_cur_decimals
      from ak_corporate       akc,
           cm_currency_master cm
     where akc.corporate_id = pc_corporate_id
       and akc.base_cur_id = cm.cur_id;
    -- mark eod
    vc_err_msg := 'Before mark process id ';
    vn_logno   := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'Start of EOD/EOM Process From Physical');
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_mark_process_id');
    sp_mark_process_id(pc_corporate_id,
                       pc_process_id,
                       pc_user_id,
                       pd_trade_date);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_phy_rebuild_stats');
  
    vc_err_msg := 'sp_insert_temp_gmr ';
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_insert_temp_gmr');
  
    pkg_phy_eod_reports.sp_insert_temp_gmr(pc_corporate_id,
                                           pd_trade_date,
                                           pc_process_id);
  
    vc_err_msg := 'sp_calc_contract_price ';
    commit;
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_contract_price');
    /*pkg_phy_eod_price.sp_calc_contract_price(pc_corporate_id,
    pd_trade_date,
    pc_process_id,
    pc_user_id,
    pc_dbd_id,
    pc_process);*/
    commit;
    vc_err_msg := 'sp_calc_gmr_price ';
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_gmr_price');
    /*pkg_phy_eod_price.sp_calc_gmr_price(pc_corporate_id,
    pd_trade_date,
    pc_process_id,
    pc_user_id,
    pc_dbd_id,
    pc_process);*/
    commit;
  
    vc_err_msg := 'sp_calc_contract_conc_price ';
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_contract_conc_price');
    /*pkg_phy_eod_price.sp_calc_contract_conc_price(pc_corporate_id,
    pd_trade_date,
    pc_process_id,
    pc_user_id,
    pc_dbd_id,
    pc_process);*/
    commit;
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_conc_gmr_price');
    /*pkg_phy_eod_price.sp_calc_conc_gmr_price(pc_corporate_id,
    pd_trade_date,
    pc_process_id,
    pc_user_id,
    pc_dbd_id,
    pc_process);*/
    commit;
    vc_err_msg := 'sp_calc_secondary_cost ';
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_secondary_cost');
    sp_calc_secondary_cost(pc_corporate_id,
                           pc_process_id,
                           pc_user_id,
                           pd_trade_date);
    commit;
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_invm_cog');
    vc_err_msg := 'sp_calc_invm_cog ';
  
    /*  pkg_phy_calculate_cog.sp_calc_invm_cog(pc_corporate_id,
    pc_process_id,
    pc_user_id,
    pd_trade_date,
    pc_process);*/
    commit;
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_invm_cogs');
    vc_err_msg := 'sp_calc_invm_cogs ';
  
    /*  pkg_phy_calculate_cog.sp_calc_invm_cogs(pc_corporate_id,
    pc_process_id,
    pc_user_id,
    pd_trade_date,
    pc_process);*/
    commit;
    vc_err_msg := 'sp_misc_updates ';
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    pkg_phy_eod_reports.sp_misc_updates(pc_corporate_id,
                                        pd_trade_date,
                                        pc_process_id,
                                        pc_process,
                                        pc_user_id);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_conc_contract_cog_price');
    vc_err_msg := 'sp_conc_contract_cog_price';
  
    pkg_phy_cog_price.sp_conc_contract_cog_price(pc_corporate_id,
                                                 pd_trade_date,
                                                 pc_process_id,
                                                 pc_user_id,
                                                 pc_process);
    commit;
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_base_contract_cog_price');
    vc_err_msg := 'sp_base_contract_cog_price';
  
    pkg_phy_cog_price.sp_base_contract_cog_price(pc_corporate_id,
                                                 pd_trade_date,
                                                 pc_process_id,
                                                 pc_user_id,
                                                 pc_process);
    commit;
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_conc_gmr_cog_price');
  
    vc_err_msg := 'sp_conc_gmr_cog_price ';
  
    pkg_phy_cog_price.sp_conc_gmr_cog_price(pc_corporate_id,
                                            pd_trade_date,
                                            pc_process_id,
                                            pc_user_id,
                                            pc_process);
    commit;
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_conc_gmr_allocation_price');
  
    vc_err_msg := 'sp_conc_gmr_allocation_price';
  
    pkg_phy_cog_price.sp_conc_gmr_allocation_price(pc_corporate_id,
                                                   pd_trade_date,
                                                   pc_process_id,
                                                   pc_user_id,
                                                   pc_process);
    commit;
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
  
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_base_gmr_allocation_price');
  
    vc_err_msg := 'sp_base_gmr_allocation_price';
  
    pkg_phy_cog_price.sp_base_gmr_allocation_price(pc_corporate_id,
                                                   pd_trade_date,
                                                   pc_process_id,
                                                   pc_user_id,
                                                   pc_process);
    commit;
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
  
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_base_gmr_cog_price');
    vc_err_msg := 'sp_base_gmr_cog_price';
  
    pkg_phy_cog_price.sp_base_gmr_cog_price(pc_corporate_id,
                                            pd_trade_date,
                                            pc_process_id,
                                            pc_user_id,
                                            pc_process);
    commit;
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
  
    ------------------DO NOT CONTINUE EOD/EOM IF ANY ERROR UPTO NOW, AS BELOW CALCULATION INVOLVED
    -- IN PNL CALCULATION, OR REPORT CALCULATIO
    --added by siva on 23AUG2012
    begin
      select count(*)
        into vn_error_count
        from eel_eod_eom_exception_log eel
       where eel.corporate_id = pc_corporate_id
         and eel.process = pc_process
         and nvl(eel.error_type, 'Error') = 'Error'
         and eel.trade_date = pd_trade_date;
    
    exception
      when others then
        vn_error_count := 0;
    end;
    ----------------  
    if vn_error_count = 0 then
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_treatment_charge');
      pkg_phy_eod_reports.sp_calc_treatment_charge(pc_corporate_id,
                                                   pd_trade_date,
                                                   pc_process_id,
                                                   pc_process);
      commit;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_refining_charge');
      pkg_phy_eod_reports.sp_calc_refining_charge(pc_corporate_id,
                                                  pd_trade_date,
                                                  pc_process_id,
                                                  pc_process);
      commit;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_penalty_charge');
      pkg_phy_eod_reports.sp_calc_penalty_charge(pc_corporate_id,
                                                 pd_trade_date,
                                                 pc_process_id,
                                                 pc_process);
      commit;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_m2m_cost');
      vc_err_msg := 'Before calc m2m cost ';
      /*  sp_calc_m2m_cost(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_m2m_conc_cost');
      vc_err_msg := 'Before calc m2m conc  cost ';
      /*    sp_calc_m2m_conc_cost(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id);*/
      ----
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_m2m_tolling_extn_cost');
      vc_err_msg := 'Before call of sp_calc_m2m_tolling_extn_cost';
    
      /* sp_calc_m2m_tolling_extn_cost(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id);*/
      ---
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_stock_price');
      vc_err_msg := 'Before call of sp_calc_stock_price';
    
      /* pkg_phy_eod_price.sp_calc_stock_price(pc_process_id);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_phy_open_unreal_pnl');
      vc_err_msg := 'Before open unreal pnl ';
      /*    pkg_phy_bm_unrealized_pnl.sp_calc_phy_open_unreal_pnl(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id,
      pc_process,
      gvc_previous_process_id);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_stock_unreal_sntt_bm');
    
      vc_err_msg := 'Before call of sp_stock_unreal_sntt_bm';
    
      /*    pkg_phy_bm_unrealized_pnl.sp_stock_unreal_sntt_bm(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id,
      pc_process,
      gvc_previous_process_id);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_stock_unreal_inv_in_bm');
    
      vc_err_msg := 'Before call of sp_stock_unreal_inv_in_bm';
      /*    pkg_phy_bm_unrealized_pnl.sp_stock_unreal_inv_in_bm(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id,
      pc_process,
      gvc_previous_process_id);*/
      commit;
      --- tolling start                                                                
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_phy_opencon_ext_unreal_pnl');
      vc_err_msg := 'Before sp_phy_opencon_ext_unreal_pnl';
      /* pkg_phy_tolling_unrealized_pnl.sp_phy_opencon_ext_unreal_pnl(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id,
      pc_dbd_id,
      pc_process,
      gvc_previous_process_id);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_phy_stok_con_ext_unreal_pnl');
      vc_err_msg := 'Before sp_phy_stok_con_ext_unreal_pnl';
      /* pkg_phy_tolling_unrealized_pnl.sp_phy_stok_con_ext_unreal_pnl(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id,
      pc_process,
      gvc_previous_process_id);*/
      -- tolling end             
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_phy_realized_today');
    
      vc_err_msg := 'Before call of sp_calc_phy_realized_today';
    
      /*    pkg_phy_bm_realized_pnl.sp_calc_phy_realized_today(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id,
      pc_process);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_reverse_realized');
      vc_err_msg := 'Before call of sp_calc_reverse_realized';
    
      /*    pkg_phy_bm_realized_pnl.sp_calc_reverse_realized(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id,
      pc_process,
      gvc_previous_process_id);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_phy_realize_pnl_change');
      vc_err_msg := 'Before call of sp_calc_phy_realize_pnl_change';
    
      /*    pkg_phy_bm_realized_pnl.sp_calc_phy_realize_pnl_change(pc_corporate_id,
      pd_trade_date,
      pc_process,
      pc_process_id,
      pc_user_id);*/
      commit;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_realized_not_fixed');
      vc_err_msg := 'Before sp_calc_realized_not_fixed ';
      /*    pkg_phy_bm_realized_pnl.sp_calc_realized_not_fixed(pc_corporate_id,
      pd_trade_date,
      pc_process,
      pc_process_id,
      pc_user_id,
      gvc_previous_process_id);*/
      vn_logno := vn_logno + 1;
    
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_phy_purchase_accural');
      vc_err_msg := 'Before sp_phy_purchase_accural ';
      if pc_process = 'EOM' then
        pkg_phy_eod_reports.sp_phy_purchase_accural(pc_corporate_id,
                                                    pd_trade_date,
                                                    pc_process_id);
      end if;
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_washout_realized_today');
      vc_err_msg := 'Before sp_calc_washout_realized_today';
      /* pkg_phy_bm_washout_pnl.sp_calc_washout_realized_today(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id,
      pc_process);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            ' sp_washout_reverse_realized');
      vc_err_msg := 'Before  sp_washout_reverse_realized';
      /* pkg_phy_bm_washout_pnl.sp_washout_reverse_realized(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id,
      pc_dbd_id,
      pc_process);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            ' sp_washout_realize_pnl_change');
      vc_err_msg := 'Before  sp_washout_realize_pnl_change';
      /* pkg_phy_bm_washout_pnl.sp_washout_realize_pnl_change(pc_corporate_id,
      pd_trade_date,
      pc_process,
      pc_process_id,
      pc_user_id);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_phy_intrstat');
      vc_err_msg := 'Before sp_phy_intrstat';
      if pc_process = 'EOM' then
        pkg_phy_eod_reports.sp_phy_intrstat(pc_corporate_id,
                                            pd_trade_date,
                                            pc_process,
                                            pc_process_id);
      end if;
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_phy_contract_status');
      vc_err_msg := 'Before sp_phy_contract_status';
      pkg_phy_eod_reports.sp_phy_contract_status(pc_corporate_id,
                                                 pd_trade_date,
                                                 pc_process_id);
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_feed_consumption_report');
      vc_err_msg := 'Before sp_feed_consumption_report';
      if pc_process = 'EOM' then
        pkg_phy_eod_reports.sp_feed_consumption_report(pc_corporate_id,
                                                       pd_trade_date,
                                                       pc_process_id);
      end if;
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_stock_monthly_yeild');
      vc_err_msg := 'Before sp_stock_monthly_yeild';
      if pc_process = 'EOM' then
        pkg_phy_eod_reports.sp_stock_monthly_yeild(pc_corporate_id,
                                                   pd_trade_date,
                                                   pc_process_id);
      end if;
      commit;
      /*    -- Concentrate PNL Call Start
      if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
         'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_phy_opencon_unreal_pnl');
      vc_err_msg := 'Before sp_calc_phy_opencon_unreal_pnl';
      
      pkg_phy_conc_unrealized_pnl.sp_calc_phy_opencon_unreal_pnl(pc_corporate_id,
                                                                 pd_trade_date,
                                                                 pc_process_id,
                                                                 pc_dbd_id,
                                                                 pc_user_id,
                                                                 pc_process,
                                                                 gvc_previous_process_id);
      if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
         'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_stock_unreal_sntt_conc');
      vc_err_msg := 'Before sp_stock_unreal_sntt_conc';
      pkg_phy_conc_unrealized_pnl.sp_stock_unreal_sntt_conc(pc_corporate_id,
                                                            pd_trade_date,
                                                            pc_process_id,
                                                            pc_dbd_id,
                                                            pc_user_id,
                                                            pc_process,
                                                            gvc_previous_process_id);
      if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
         'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_stock_unreal_inv_in_conc');
      vc_err_msg := 'Before sp_stock_unreal_inv_in_conc';
      
      pkg_phy_conc_unrealized_pnl.sp_stock_unreal_inv_in_conc(pc_corporate_id,
                                                              pd_trade_date,
                                                              pc_process_id,
                                                              pc_user_id,
                                                              pc_process,
                                                              gvc_previous_process_id,
                                                              pc_dbd_id);
      
      pkg_phy_conc_realized_pnl.sp_calc_phy_conc_realize_today(pc_corporate_id,
                                                               pd_trade_date,
                                                               pc_process_id,
                                                               pc_dbd_id,
                                                               pc_user_id,
                                                               pc_process);
      
      pkg_phy_conc_realized_pnl.sp_calc_phy_conc_pnl_change(pc_corporate_id,
                                                            pd_trade_date,
                                                            pc_process,
                                                            pc_process_id,
                                                            pc_dbd_id,
                                                            pc_user_id);
      
      pkg_phy_conc_realized_pnl.sp_calc_phy_conc_reverse_rlzed(pc_corporate_id,
                                                               pd_trade_date,
                                                               pc_process_id,
                                                               gvc_previous_process_id,
                                                               pc_user_id,
                                                               pc_process);
      pkg_phy_conc_realized_pnl.sp_calc_conc_rlzed_not_fixed(pc_corporate_id,
                                                             pd_trade_date,
                                                             pc_process_id,
                                                             gvc_previous_process_id,
                                                             pc_user_id,
                                                             pc_process); */
    
      -- Concentrate PNL Call End
      -- Trade PNL 
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_pnl_summary');
      pkg_phy_eod_reports.sp_calc_pnl_summary(pc_corporate_id,
                                              pd_trade_date,
                                              pc_process_id,
                                              gvc_process,
                                              pc_user_id);
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_daily_trade_pnl');
      vc_err_msg := 'Before trade pnl ';
      pkg_phy_eod_reports.sp_calc_daily_trade_pnl(pc_corporate_id,
                                                  pd_trade_date,
                                                  pc_process_id,
                                                  gvc_process,
                                                  pc_user_id);
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_risk_limits');
      vc_err_msg := 'Before sp_calc_risk_limits';
      /* pkg_phy_eod_reports.sp_calc_risk_limits(pc_corporate_id,
      pd_trade_date,
      pc_process_id,
      pc_user_id,
      pc_process);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_overall_realized_pnl');
      vc_err_msg := 'Before sp_calc_overall_realized_pnl';
    
      /* pkg_phy_eod_reports.sp_calc_overall_realized_pnl(pc_corporate_id,
                                                         pd_trade_date,
                                                         pc_process_id,
                                                         pc_user_id,
                                                         pc_process);
      */
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_calc_phy_unreal_pnl_attr');
      vc_err_msg := 'Before sp_calc_phy_unreal_pnl_attr';
      /* pkg_phy_eod_reports.sp_calc_phy_unreal_pnl_attr(pc_corporate_id,
      pd_trade_date,
      gvc_previous_process_date,
      pc_process_id,
      gvc_previous_process_id,
      pc_user_id);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_metal_balance_qty_summary');
      vc_err_msg := 'Before sp_metal_balance_qty_summary';
      if pc_process = 'EOM' then
        pkg_phy_eod_reports.sp_metal_balance_qty_summary(pc_corporate_id,
                                                         pd_trade_date,
                                                         pc_process_id);
      end if;
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_daily_position_record');
      vc_err_msg := 'Before sp_daily_position_record';
    
      /* pkg_phy_eod_reports.sp_daily_position_record(pc_corporate_id,
      pd_trade_date,
      pc_process_id);*/
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_arrival_report');
      vc_err_msg := 'Before sp_arrival_report';
      if pc_process = 'EOM' then
        pkg_phy_eod_reports.sp_arrival_report(pc_corporate_id,
                                              pd_trade_date,
                                              pc_process_id,
                                              pc_process);
      end if;
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_feedconsumption_report');
      vc_err_msg := 'Before sp_feedconsumption_report';
      if pc_process = 'EOM' then
        pkg_phy_eod_reports.sp_feedconsumption_report(pc_corporate_id,
                                                      pd_trade_date,
                                                      pc_process_id,
                                                      pc_process);
      end if;
      commit;
      if pkg_process_status.sp_get(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date) = 'Cancel' then
        goto cancel_process;
      end if;
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_closing_balance_report');
      vc_err_msg := 'Before sp_closing_balance_report';
      if pc_process = 'EOM' then
        pkg_phy_eod_reports.sp_closing_balance_report(pc_corporate_id,
                                                      pd_trade_date,
                                                      pc_process_id,
                                                      pc_process,
                                                      pc_dbd_id);
      end if;
      commit;
    
      --- Added suresh  for MBV Report
      vn_logno := vn_logno + 1;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            vn_logno,
                            'sp_run_mbv_report');
      vc_err_msg := 'Before sp_run_mbv_report';
    
      if pc_process = 'EOM' then
        pkg_phy_mbv_report.sp_run_mbv_report(pc_corporate_id,
                                             pd_trade_date,
                                             pc_process_id,
                                             pc_process,
                                             pc_user_id);
      end if;
      commit;
      --- End Suresh 
    end if; ---this end if starts from if vn_error_count = 0 then
    commit;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'End of EOD/EOM Process From Physical');
     pkg_execute_process.sp_mark_process_time(pc_corporate_id,
                                             pd_trade_date,
                                             pc_user_id,
                                             pc_process,
                                             'PROCESS');
    commit;
    pkg_execute_process.sp_process_time_display(pc_corporate_id,
                                                 pd_trade_date,
                                                 pc_user_id,
                                                 pc_process,
                                                 'PROCESS'); 
    commit;      
    vc_err_msg := 'end of physical sp process run ';
    <<cancel_process>>
    dbms_output.put_line('EOD/EOM Process Cancelled while pnl calculation');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_physical_process sp_process_run ' ||
                                                           vc_err_msg,
                                                           'M2M-013',
                                                           'code:' ||
                                                           sqlcode ||
                                                           ' message:' ||
                                                           sqlerrm || ' ' ||
                                                           vc_err_msg,
                                                           '',
                                                           gvc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
      commit;
  end;

  procedure sp_mark_process_id(pc_corporate_id varchar2,
                               pc_process_id   varchar2,
                               pc_user_id      varchar2,
                               pd_trade_date   date
                               --------------------------------------------------------------------------------------------------
                               --  procedure name                            : sp_mark_process_id
                               --  author                                    : siva
                               --  created date                              : 20th jan 2009
                               --  purpose                                   : to mark the eod refernce numbers
                               --
                               --  parameters
                               --  pc_corporate_id                           : corporate id
                               --  pd_trade_date                             : trade date
                               --  pc_process_id                             : eod reference no
                               --
                               --  modification history
                               --  modified date                             :
                               --  modified by                               :
                               --  modify description                        :
                               --------------------------------------------------------------------------------------------------
                               ) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vc_dbd_id          varchar2(15);
    vc_prev_process_id varchar2(15);
    prev_trade_date    date;
    vc_err_msg         varchar2(100);
  begin
    -- get the dump id
  
    vc_err_msg := 'Before select vc_dbd_id';
    select max(dbd.dbd_id)
      into vc_dbd_id
      from dbd_database_dump dbd
     where dbd.corporate_id = pc_corporate_id
       and dbd.process = gvc_process
       and dbd.trade_date = pd_trade_date;
  
    vc_err_msg := 'Before select vc_prev_process_id';
    select max(tdc.process_id)
      into vc_prev_process_id
      from tdc_trade_date_closure tdc
     where tdc.corporate_id = pc_corporate_id
       and tdc.process = gvc_process
       and tdc.trade_date < pd_trade_date;
  
    vc_err_msg := 'Before select prev_trade_date';
    select tdc.trade_date
      into prev_trade_date
      from tdc_trade_date_closure tdc
     where tdc.corporate_id = pc_corporate_id
       and tdc.process_id = vc_prev_process_id;

 update agh_alloc_group_header agh
     set process_id = pc_process_id
   where process_id is null
     and agh.realized_date <= pd_trade_date
     and agh.dbd_id =vc_dbd_id;
    --
    -- 1. AGH was not present in previous eod and became inventory out in this eod
    --
    update agh_alloc_group_header agh
       set agh.today_status = 'Realized Today'
     where trim(agh.realized_status) = 'Realized'
       and agh.process_id = pc_process_id
       and agh.is_deleted = 'N'
       and agh.int_alloc_group_id not in
           (select agh_prev.int_alloc_group_id
              from agh_alloc_group_header agh_prev
             where trim(agh_prev.realized_status) = 'Realized'
               and agh_prev.process_id = gvc_previous_process_id
               and agh_prev.is_deleted = 'N');
    commit;
    sp_write_log(pc_corporate_id, pd_trade_date, 'sp_mark_process_id', '1');
  
    --
    -- 2. AGH was present in previous eod and became inventory out in this eod
    --
    update agh_alloc_group_header agh
       set agh.today_status = 'Realized Today'
     where trim(agh.realized_status) = 'Realized'
       and agh.process_id = pc_process_id
       and agh.is_deleted = 'N'
       and agh.int_alloc_group_id in
           (select agh_prev.int_alloc_group_id
              from agh_alloc_group_header agh_prev
             where trim(agh_prev.realized_status) <> 'Realized'
               and agh_prev.process_id = gvc_previous_process_id
               and agh_prev.is_deleted = 'N');
    commit;
    sp_write_log(pc_corporate_id, pd_trade_date, 'sp_mark_process_id', '2');
    --
    -- For Realized PNL Change update below tables for PROCESS_ID 
    --               
    update grdl_goods_record_detail_log grdl
       set grdl.process_id = pc_process_id
     where grdl.process_id is null
       and (grdl.internal_action_ref_no) in
           (select axs.internal_action_ref_no
              from axs_action_summary axs
             where axs.internal_action_ref_no = grdl.internal_action_ref_no
               and axs.eff_date <= pd_trade_date
               and axs.corporate_id = pc_corporate_id)
       and grdl.dbd_id in
           (select dbd.dbd_id
              from dbd_database_dump dbd
             where dbd.corporate_id = pc_corporate_id
               and dbd.process = gvc_process
               and dbd.trade_date <= pd_trade_date);
    commit;
    sp_write_log(pc_corporate_id, pd_trade_date, 'sp_mark_process_id', '3');
    update dgrdul_delivered_grd_ul dgrdul
       set dgrdul.process_id = pc_process_id
     where dgrdul.process_id is null
       and (dgrdul.internal_action_ref_no) in
           (select axs.internal_action_ref_no
              from axs_action_summary axs
             where axs.internal_action_ref_no =
                   dgrdul.internal_action_ref_no
               and axs.eff_date <= pd_trade_date
               and axs.corporate_id = pc_corporate_id)
       and dgrdul.dbd_id in
           (select dbd.dbd_id
              from dbd_database_dump dbd
             where dbd.corporate_id = pc_corporate_id
               and dbd.process = gvc_process
               and dbd.trade_date <= pd_trade_date);
    commit;
    sp_write_log(pc_corporate_id, pd_trade_date, 'sp_mark_process_id', '4');
  
-- added Suresh               
update spql_stock_payable_qty_log sqpl
       set sqpl.process_id = pc_process_id
     where sqpl.process_id is null
       and (sqpl.internal_action_ref_no) in
           (select axs.internal_action_ref_no
              from axs_action_summary axs
             where axs.internal_action_ref_no =
                   sqpl.internal_action_ref_no
               and axs.eff_date <= pd_trade_date
               and axs.corporate_id = pc_corporate_id)
       and sqpl.dbd_id in
           (select dbd.dbd_id
              from dbd_database_dump dbd
             where dbd.corporate_id = pc_corporate_id
               and dbd.process = gvc_process
               and dbd.trade_date <= pd_trade_date);               
commit;  
    update cdl_cost_delta_log cdl
       set cdl.process_id = pc_process_id
     where cdl.process_id is null
       and (cdl.internal_action_ref_no) in
           (select axs.internal_action_ref_no
              from axs_action_summary axs
             where axs.internal_action_ref_no = cdl.internal_action_ref_no
               and axs.eff_date <= pd_trade_date
               and axs.corporate_id = pc_corporate_id)
       and cdl.dbd_id in
           (select dbd.dbd_id
              from dbd_database_dump dbd
             where dbd.corporate_id = pc_corporate_id
               and dbd.process = gvc_process
               and dbd.trade_date <= pd_trade_date);
    commit;
    sp_write_log(pc_corporate_id, pd_trade_date, 'sp_mark_process_id', '5');
  
    -- Washout Tables
    update sswh_spe_settle_washout_header sswh
       set process_id = pc_process_id
     where process_id is null
       and (sswh.internal_action_ref_no) in
           (select axs.internal_action_ref_no
              from axs_action_summary axs
             where axs.internal_action_ref_no = sswh.internal_action_ref_no
               and axs.eff_date <= pd_trade_date
               and axs.corporate_id = pc_corporate_id);
  
    update sswd_spe_settle_washout_detail sswd
       set process_id = pc_process_id
     where process_id is null
       and sswd.sswh_id in
           (select sswh.sswh_id
              from sswh_spe_settle_washout_header sswh
             where sswh.process_id = pc_process_id);
    commit;
    sp_write_log(pc_corporate_id, pd_trade_date, 'sp_mark_process_id', '6');
  
    --- added suresh   
    update pca_physical_contract_action pca
       set process_id = pc_process_id
     where process_id is null
       and (pca.internal_action_ref_no) in
           (select axs.internal_action_ref_no
              from axs_action_summary axs
             where axs.internal_action_ref_no = pca.internal_action_ref_no
               and axs.eff_date <= pd_trade_date
               and axs.corporate_id = pc_corporate_id)
       and pca.dbd_id in
           (select dbd.dbd_id
              from dbd_database_dump dbd
             where dbd.corporate_id = pc_corporate_id
               and dbd.process = gvc_process
               and dbd.trade_date <= pd_trade_date);
    commit;
    sp_write_log(pc_corporate_id, pd_trade_date, 'sp_mark_process_id', '7');
  
    update cod_call_off_details cod
       set process_id = pc_process_id
     where process_id is null
       and (cod.internal_action_ref_no) in
           (select axs.internal_action_ref_no
              from axs_action_summary axs
             where axs.internal_action_ref_no = cod.internal_action_ref_no
               and axs.eff_date <= pd_trade_date
               and axs.corporate_id = pc_corporate_id)
       and cod.dbd_id in
           (select dbd.dbd_id
              from dbd_database_dump dbd
             where dbd.corporate_id = pc_corporate_id
               and dbd.process = gvc_process
               and dbd.trade_date <= pd_trade_date);
    commit;
    sp_write_log(pc_corporate_id, pd_trade_date, 'sp_mark_process_id', '8');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_physical_process sp_mark_process_id',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm || ' ' ||
                                                           vc_err_msg,
                                                           '',
                                                           gvc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_calc_secondary_cost(pc_corporate_id varchar2,
                                   pc_process_id   varchar2,
                                   pc_user_id      varchar2,
                                   pd_trade_date   date) is
    -----------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_calc_secondary_cost
    --        author                                    :
    --        created date                              : 11th Jan 2011
    --        purpose                                   : populate secondary costs for contracts and gmrs
    --
    --        parameters
    --        pc_corporate_id                           : corporate id
    --        pc_process_id                             : eod reference no
    --
    --        modification history
    --        modified date                             :
    --        modified by                               :
    --        modify description                        :
    --------------------------------------------------------------------------------------------------------------
    vobj_error_log           tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count       number := 1;
    vn_trans_to_base_fw_rate number;
    vn_forward_points        number;
    vn_qty_factor            number;
  begin
    --
    -- Update PUM ID for Rate Type
    -- Not doing with PPU because I don't know the product at this point
    --
    update cs_cost_store cs
       set cs.transaction_price_unit_id = (select ppu.price_unit_id
                                             from v_ppu_pum             ppu,
                                                  pum_price_unit_master pum
                                            where ppu.product_price_unit_id =
                                                  cs.rate_price_unit_id
                                              and ppu.price_unit_id =
                                                  pum.price_unit_id)
     where cs.process_id = pc_process_id
       and cs.rate_type = 'Rate';
    --
    -- Update PUM ID for Absolute Type
    -- Currency from CS and Unit from CIGC
    -- 
    for cc1 in (select cs.internal_cost_id,
                       cog.cog_ref_no,
                       cog.qty,
                       cog.qty_unit_id,
                       cs.transaction_amt,
                       cs.transaction_amt_cur_id,
                       pum.price_unit_id,
                       cs.rate_type,
                       round(cs.transaction_amt / cog.qty, 10) transaction_cost,
                       round(cs.cost_value / cog.qty, 10) cost_value
                  from cigc_contract_item_gmr_cost cog,
                       cs_cost_store               cs,
                       pum_price_unit_master       pum
                 where cog.process_id = pc_process_id
                   and cs.process_id = cog.process_id
                   and cog.cog_ref_no = cs.cog_ref_no
                   and cog.qty_unit_id = pum.weight_unit_id
                   and cs.transaction_amt_cur_id = pum.cur_id
                   and cs.rate_type = 'Absolute'
                   and nvl(pum.weight, 1) = 1
                   and pum.is_active = 'Y'
                   and pum.is_deleted = 'N')
    loop
      update cs_cost_store css
         set css.cost_value                = cc1.cost_value,
             css.transaction_price_unit_id = cc1.price_unit_id
       where css.internal_cost_id = cc1.internal_cost_id;
    
    end loop;
  
    insert into cisc_contract_item_sec_cost
      (internal_contract_item_ref_no,
       cost_component_id,
       avg_cost,
       process_id,
       secondary_cost,
       avg_cost_in_trn_cur,
       avg_cost_price_unit_id,
       payment_due_date,
       product_id,
       corporate_id,
       transact_price_unit_id,
       transact_qty_unit_id,
       transact_cur_id,
       transact_main_cur_id,
       currency_factor,
       base_cur_id,
       base_qty_unit_id,
       base_price_unit_id,
       cost_value,
       price_qty_unit_id,
       fw_rate_trans_to_base_currency,
       fw_rate_string)
      select pci.internal_contract_item_ref_no,
             cs.cost_component_id,
             cs.cost_in_base_price_unit_id,
             pc_process_id,
             cs.cost_value secondary_cost,
             cs.cost_in_transact_price_unit_id,
             cs.transaction_price_unit_id,
             case
               when nvl(cs.est_payment_due_date, pd_trade_date) >
                    pd_trade_date then
                pd_trade_date
               else
                nvl(cs.est_payment_due_date, pd_trade_date)
             end,
             pcpd.product_id,
             pcm.corporate_id,
             cs.transaction_price_unit_id,
             cigc.qty_unit_id,
             cs.transaction_amt_cur_id,
             nvl(scd.cur_id, cs.transaction_amt_cur_id),
             nvl(scd.factor, 1),
             akc.base_cur_id,
             pdm.base_quantity_unit,
             pum_base.price_unit_id,
             cs.cost_value,
             pum_trans.weight_unit_id,
             cs.fx_to_base,
             (case
               when cs.transaction_amt_cur_id <> cs.base_amt_cur_id then
                '1 ' || cm_trans.cur_code || '=' || cs.fx_to_base || ' ' ||
                cm_base.cur_code
               else
                null
             end)
        from cs_cost_store               cs,
             cigc_contract_item_gmr_cost cigc,
             pcdi_pc_delivery_item       pcdi,
             pci_physical_contract_item  pci,
             pcm_physical_contract_main  pcm,
             scm_service_charge_master   scm,
             pcpq_pc_product_quality     pcpq,
             pcpd_pc_product_definition  pcpd,
             ak_corporate                akc,
             pdm_productmaster           pdm,
             scd_sub_currency_detail     scd,
             pum_price_unit_master       pum_base,
             pum_price_unit_master       pum_trans,
             cm_currency_master          cm_trans,
             cm_currency_master          cm_base
       where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = pci.pcdi_id
         and pci.internal_contract_item_ref_no =
             cigc.int_contract_item_ref_no
         and cigc.cog_ref_no = cs.cog_ref_no
         and pcm.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and cigc.is_deleted = 'N'
         and cs.is_deleted = 'N'
         and pcm.contract_status = 'In Position'
         and pcm.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and cigc.process_id = pc_process_id
         and cs.process_id = pc_process_id
         and cs.cost_component_id = scm.cost_id
         and scm.cost_type = 'SECONDARY_COST'
         and cs.cost_type = 'Estimate'
         and pci.pcpq_id = pcpq.pcpq_id
         and pcpq.pcpd_id = pcpd.pcpd_id
         and pcpq.process_id = pcpd.process_id
         and pcm.corporate_id = akc.corporate_id
         and pcpd.product_id = pdm.product_id
         and cs.transaction_amt_cur_id = scd.sub_cur_id(+)
         and pum_base.weight_unit_id = pdm.base_quantity_unit
         and pum_base.cur_id = akc.base_cur_id
         and pum_trans.price_unit_id = cs.transaction_price_unit_id
         and pcpd.process_id = pc_process_id
         and cs.transaction_amt_cur_id = cm_trans.cur_id
         and cs.base_amt_cur_id = cm_base.cur_id;
    commit;
    --
    -- Check the exchange rate from Transaction Currency to Base Currency
    --
    /*for cur_cisc in (select cisc.transact_main_cur_id,
                            cisc.base_cur_id,
                            cisc.payment_due_date,
                            cm_tran.cur_code transact_main_cur_code,
                            cm_base.cur_code base_cur_code
                       from cisc_contract_item_sec_cost cisc,
                            cm_currency_master          cm_tran,
                            cm_currency_master          cm_base
                      where cisc.process_id = pc_process_id
                        and cisc.transact_main_cur_id <> cisc.base_cur_id
                        and cisc.transact_main_cur_id = cm_tran.cur_id
                        and cisc.base_cur_id = cm_base.cur_id
                      group by cisc.transact_main_cur_id,
                               cisc.base_cur_id,
                               cisc.payment_due_date,
                               cm_tran.cur_code,
                               cm_base.cur_code)
    loop
      pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                  pd_trade_date,
                                  cur_cisc.payment_due_date,
                                  cur_cisc.transact_main_cur_id,
                                  cur_cisc.base_cur_id,
                                  30,
                                  'sp_calc_secondary_cost on Contract Accrual CISC',
                                  gvc_process,
                                  vn_trans_to_base_fw_rate,
                                  vn_forward_points);
    
      if vn_trans_to_base_fw_rate <> 0 then
        update cisc_contract_item_sec_cost cisc
           set cisc.fw_rate_trans_to_base_currency = vn_trans_to_base_fw_rate,
               cisc.fw_rate_string                 = '1 ' ||
                                                     cur_cisc.transact_main_cur_code || '=' ||
                                                     vn_trans_to_base_fw_rate || ' ' ||
                                                     cur_cisc.base_cur_code
         where cisc.process_id = pc_process_id
           and cisc.transact_main_cur_id = cur_cisc.transact_main_cur_id
           and cisc.base_cur_id = cur_cisc.base_cur_id
           and cisc.payment_due_date = cur_cisc.payment_due_date;
      end if;
    end loop;*/
  
    --
    -- Update the Quantity Conversion from Base to Transaction
    --
    for cur_cisc_qty in (select cisc.product_id,
                                cisc.price_qty_unit_id,
                                cisc.base_qty_unit_id
                           from cisc_contract_item_sec_cost cisc
                          where cisc.process_id = pc_process_id
                            and cisc.price_qty_unit_id <>
                                cisc.base_qty_unit_id
                          group by cisc.product_id,
                                   cisc.price_qty_unit_id,
                                   cisc.base_qty_unit_id)
    loop
      select pkg_general.f_get_converted_quantity(cur_cisc_qty.product_id,
                                                  cur_cisc_qty.base_qty_unit_id,
                                                  cur_cisc_qty.price_qty_unit_id,
                                                  1)
        into vn_qty_factor
        from dual;
      update cisc_contract_item_sec_cost cisc
         set cisc.base_to_price_weight_factor = vn_qty_factor
       where cisc.price_qty_unit_id = cur_cisc_qty.price_qty_unit_id
         and cisc.base_qty_unit_id = cur_cisc_qty.base_qty_unit_id
         and cisc.process_id = pc_process_id;
    end loop;
    commit;
    --
    -- Average Price in Base Price Unit ID
    --
    update cisc_contract_item_sec_cost cisc
       set cisc.avg_cost_fw_rate = cisc.cost_value *
                                   nvl(cisc.currency_factor, 1) *
                                   nvl(cisc.base_to_price_weight_factor, 1) *
                                   nvl(cisc.fw_rate_trans_to_base_currency,
                                       1)
     where cisc.process_id = pc_process_id;
    commit;
    -- For GMR
    pkg_phy_calculate_cog.sp_calc_gmr_sec_cost(pc_corporate_id,
                                               pc_process_id,
                                               pc_user_id,
                                               pd_trade_date,
                                               gvc_process);
  
    --
    -- Calcualte Contract Item Sec Cost Summary for PNL
    --
  
    insert into ciscs_cisc_summary ciscs
      (internal_contract_item_ref_no,
       avg_cost,
       process_id,
       avg_cost_fw_rate,
       fw_rate_string)
      select cisc.internal_contract_item_ref_no,
             sum(cisc.avg_cost),
             pc_process_id,
             sum(cisc.avg_cost_fw_rate),
             f_string_aggregate(cisc.fw_rate_string)
        from cisc_contract_item_sec_cost cisc
       where cisc.process_id = pc_process_id
       group by cisc.internal_contract_item_ref_no;
    commit;
  exception
    when others then
      commit;
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_secondary_cost',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           gvc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_calc_m2m_cost(pc_corporate_id varchar2,
                             pd_trade_date   date,
                             pc_process_id   varchar2,
                             pc_user_id      varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_calc_m2m_cost
    --        author                                    :
    --        created date                              : 11th Jan 2011
    --        purpose                                   : populate secondary costs for contracts and gmrs
    --
    --        parameters
    --        pc_corporate_id                           : corporate id
    --        pc_process_id                             : eod reference no
    --
    --        modification history
    --        modified date                             :
    --        modified by                               :
    --        modify description                        :
    --------------------------------------------------------------------------------------------------------------------------
    vn_serial_no       number;
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vc_err_msg         varchar2(100);
  begin
    --
    -- Generate unique m2m data with m2m id
    --
    vc_err_msg := 'before generate Unique M2M data with M2M ID';
    begin
      vn_serial_no := 1;
      for cc in (select t.corporate_id,
                        t.product_id,
                        t.product_type,
                        t.quality_id,
                        t.mvp_id,
                        t.mvpl_id,
                        t.value_type,
                        t.valuation_region,
                        t.valuation_point,
                        t.valuation_incoterm_id,
                        t.valuation_city_id,
                        t.valuation_basis,
                        t.reference_incoterm,
                        t.refernce_location,
                        t.instrument_id,
                        t.valuation_dr_id,
                        t.price_basis as valuation_method,
                        t.m2m_price_unit_id,
                        pum.cur_id m2m_price_unit_cur_id,
                        cm.cur_code,
                        pum.weight_unit_id,
                        qum.qty_unit,
                        nvl(pum.weight, 1) as weight,
                        t.derivative_def_id,
                        t.valuation_month || '-' || t.valuation_year valuation_period,
                        t.valuation_date,
                        t.shipment_month || '-' || t.shipment_year shipment_month_year,
                        t.shipment_date,
                        decode(t.section_name, 'OPEN', 'OPEN', 'STOCK') rate_type,
                        pum.cur_id valuation_cur_id,
                        t.base_price_unit_id_in_ppu,
                        t.base_price_unit_id_in_pum,
                        t.payment_due_date
                   from tmpc_temp_m2m_pre_check  t,
                        pum_price_unit_master    pum,
                        cm_currency_master       cm,
                        qum_quantity_unit_master qum
                  where t.corporate_id = pc_corporate_id
                    and t.m2m_price_unit_id = pum.price_unit_id(+)
                    and pum.cur_id = cm.cur_id(+)
                    and pum.weight_unit_id = qum.qty_unit_id(+)
                    and t.product_type = 'BASEMETAL'
                  group by t.corporate_id,
                           t.product_id,
                           t.product_type,
                           t.mvp_id,
                           t.mvpl_id,
                           t.value_type,
                           t.valuation_region,
                           t.valuation_point,
                           t.valuation_incoterm_id,
                           t.valuation_city_id,
                           t.valuation_basis,
                           t.reference_incoterm,
                           t.refernce_location,
                           t.instrument_id,
                           t.valuation_dr_id,
                           t.price_basis,
                           pum.cur_id,
                           t.m2m_price_unit_id,
                           t.m2m_price_unit_cur_id,
                           cm.cur_code,
                           pum.weight_unit_id,
                           qum.qty_unit,
                           nvl(pum.weight, 1),
                           t.quality_id,
                           t.derivative_def_id,
                           t.valuation_month || '-' || t.valuation_year,
                           t.valuation_date,
                           t.shipment_month || '-' || t.shipment_year,
                           t.shipment_date,
                           --this bit is important since for the same dr_id , open contract use forward rates and
                           --stock uses spot. tmef has been populated for both types
                           decode(t.section_name, 'OPEN', 'OPEN', 'STOCK'),
                           t.valuation_cur_id,
                           t.base_price_unit_id_in_ppu,
                           t.base_price_unit_id_in_pum,
                           t.payment_due_date)
      loop
        insert into md_m2m_daily
          (md_id,
           process_id,
           corporate_id,
           product_id,
           product_type,
           quality_id,
           mvp_id,
           mvpl_id,
           valuation_region,
           valuation_point,
           valuation_incoterm_id,
           valuation_city_id,
           valuation_basis,
           reference_incoterm,
           refernce_location_id,
           instrument_id,
           valuation_dr_id,
           m2m_price_unit_id,
           m2m_price_unit_cur_id,
           m2m_price_unit_cur_code,
           m2m_price_unit_weight_unit_id,
           m2m_price_unit_weight_unit,
           m2m_price_unit_weight,
           valuation_month,
           valuation_future_contract,
           derivative_def_id,
           valuation_date,
           shipment_month_year,
           shipment_date,
           rate_type,
           valuation_cur_id,
           base_price_unit_id_in_ppu,
           base_price_unit_id_in_pum,
           valuation_method,
           payment_due_date)
        values
          ('MDB-' || vn_serial_no,
           pc_process_id,
           cc.corporate_id,
           cc.product_id,
           cc.product_type,
           cc.quality_id,
           cc.mvp_id,
           cc.mvpl_id,
           cc.valuation_region,
           cc.valuation_point,
           cc.valuation_incoterm_id,
           cc.valuation_city_id,
           cc.valuation_basis,
           cc.reference_incoterm,
           cc.refernce_location,
           cc.instrument_id,
           cc.valuation_dr_id,
           cc.m2m_price_unit_id,
           cc.m2m_price_unit_cur_id,
           cc.cur_code,
           cc.weight_unit_id,
           cc.qty_unit,
           cc.weight,
           cc.valuation_period,
           cc.valuation_dr_id,
           cc.derivative_def_id,
           cc.valuation_date,
           cc.shipment_month_year,
           cc.shipment_date,
           cc.rate_type,
           cc.valuation_cur_id,
           cc.base_price_unit_id_in_ppu,
           cc.base_price_unit_id_in_pum,
           cc.value_type,
           cc.payment_due_date);
        vn_serial_no := vn_serial_no + 1;
      end loop;
      commit;
      --
      -- Update the Quality premimum
      --
      for cc1 in (select tmpc.corporate_id,
                         tmpc.mvp_id,
                         tmpc.valuation_point,
                         tmpc.shipment_month,
                         tmpc.shipment_year,
                         tmpc.instrument_id,
                         tmpc.base_price_unit_id_in_ppu,
                         tmpc.quality_id,
                         tmpc.product_id,
                         tmpc.payment_due_date,
                         tmpc.m2m_quality_premium,
                         tmpc.m2m_qp_fw_exch_rate
                    from tmpc_temp_m2m_pre_check tmpc
                   where tmpc.corporate_id = pc_corporate_id
                     and tmpc.product_type = 'BASEMETAL'
                   group by tmpc.corporate_id,
                            tmpc.mvp_id,
                            tmpc.valuation_point,
                            tmpc.shipment_month,
                            tmpc.shipment_year,
                            tmpc.instrument_id,
                            tmpc.base_price_unit_id_in_ppu,
                            tmpc.quality_id,
                            tmpc.product_id,
                            tmpc.payment_due_date,
                            tmpc.m2m_quality_premium,
                            tmpc.m2m_qp_fw_exch_rate)
      loop
      
        update md_m2m_daily md
           set md.m2m_quality_premium = cc1.m2m_quality_premium,
               md.m2m_qp_fw_exch_rate = cc1.m2m_qp_fw_exch_rate
         where md.corporate_id = cc1.corporate_id
           and md.product_id = cc1.product_id
           and md.quality_id = cc1.quality_id
           and md.shipment_month_year =
               cc1.shipment_month || '-' || cc1.shipment_year
           and md.mvp_id = cc1.mvp_id
           and md.payment_due_date = cc1.payment_due_date
           and md.process_id = pc_process_id
           and md.product_type = 'BASEMETAL';
      
      end loop;
      commit;
      --
      -- Update the product premimum
      --
      for cc2 in (select tmpc.corporate_id,
                         tmpc.product_id,
                         tmpc.base_price_unit_id_in_ppu,
                         tmpc.shipment_month,
                         tmpc.shipment_year,
                         tmpc.payment_due_date,
                         tmpc.m2m_product_premium,
                         tmpc.m2m_pp_fw_exch_rate
                    from tmpc_temp_m2m_pre_check tmpc
                   where tmpc.corporate_id = pc_corporate_id
                     and tmpc.product_type = 'BASEMETAL'
                   group by tmpc.corporate_id,
                            tmpc.product_id,
                            tmpc.base_price_unit_id_in_ppu,
                            tmpc.shipment_month,
                            tmpc.shipment_year,
                            tmpc.payment_due_date,
                            tmpc.m2m_product_premium,
                            tmpc.m2m_pp_fw_exch_rate)
      loop
        update md_m2m_daily md
           set md.m2m_product_premium = cc2.m2m_product_premium,
               md.m2m_pp_fw_exch_rate = cc2.m2m_pp_fw_exch_rate
         where md.corporate_id = cc2.corporate_id
           and md.product_id = cc2.product_id
           and md.shipment_month_year =
               cc2.shipment_month || '-' || cc2.shipment_year
           and md.payment_due_date = cc2.payment_due_date
           and md.process_id = pc_process_id
           and md.product_type = 'BASEMETAL';
        commit;
      end loop;
      vc_err_msg := 'line 2819';
      update md_m2m_daily md
         set (md.valuation_exchange_id, md.m2m_settlement_price, md.m2m_sett_price_available_date) = --
              (select pdd.exchange_id,
                      edq.price,
                      edq.dq_trade_date
                 from eodeom_derivative_quote_detail edq,
                      pum_price_unit_master          pum,
                      dim_der_instrument_master      dim,
                      div_der_instrument_valuation   div,
                      pdd_product_derivative_def     pdd,
                      cdim_corporate_dim             cdim
                where edq.dr_id = md.valuation_dr_id
                  and edq.corporate_id = pc_corporate_id
                  and dim.instrument_id = md.instrument_id
                  and edq.instrument_id = div.instrument_id
                  and dim.product_derivative_id = pdd.derivative_def_id
                  and edq.price_source_id = div.price_source_id
                  and div.is_deleted = 'N'
                  and edq.available_price_id = div.available_price_id
                  and edq.price_unit_id = pum.price_unit_id
                  and edq.price_unit_id = div.price_unit_id
                  and edq.price is not null
                  and edq.process_id = pc_process_id
                  and edq.dq_trade_date = cdim.valid_quote_date
                  and cdim.corporate_id = pc_corporate_id
                  and cdim.instrument_id = edq.instrument_id)
      
       where md.corporate_id = pc_corporate_id
         and md.valuation_method <> 'FIXED'
         and md.process_id = pc_process_id;
      commit;
      ----
      vc_err_msg := 'line 2887';
      --
      -- Update the M2M Location Incoterm Deviation
      --
      for cc3 in (select tmpc.product_id,
                         tmpc.valuation_city_id,
                         tmpc.mvp_id,
                         tmpc.valuation_incoterm_id,
                         tmpc.payment_due_date,
                         tmpc.m2m_loc_incoterm_deviation,
                         tmpc.m2m_ld_fw_exch_rate
                    from tmpc_temp_m2m_pre_check tmpc
                   where tmpc.product_type = 'BASEMETAL'
                     and tmpc.corporate_id = pc_corporate_id
                   group by tmpc.product_id,
                            tmpc.valuation_city_id,
                            tmpc.mvp_id,
                            tmpc.valuation_incoterm_id,
                            tmpc.payment_due_date,
                            tmpc.m2m_loc_incoterm_deviation,
                            tmpc.m2m_ld_fw_exch_rate)
      loop
      
        update md_m2m_daily md
           set md.m2m_loc_incoterm_deviation = cc3.m2m_loc_incoterm_deviation,
               md.m2m_ld_fw_exch_rate        = cc3.m2m_ld_fw_exch_rate
         where md.valuation_city_id = cc3.valuation_city_id
           and md.mvp_id = cc3.mvp_id
           and md.product_id = cc3.product_id
           and md.valuation_incoterm_id = cc3.valuation_incoterm_id
           and md.product_type = 'BASEMETAL'
           and md.corporate_id = pc_corporate_id
           and md.payment_due_date = cc3.payment_due_date
           and md.process_id = pc_process_id;
      
      end loop;
      commit;
    
      vc_err_msg := 'line 3049';
    
      update md_m2m_daily md
         set md.net_m2m_price = nvl(md.m2m_settlement_price, 0)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'BASEMETAL'
         and md.process_id = pc_process_id;
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 5');
      vc_err_msg := 'line 3068';
      vc_err_msg := 'line 3090';
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 6');
      --
      -- update derivative def id/name
      --
      update md_m2m_daily md
         set (derivative_def_id, derivative_def_name) = (select pdd.derivative_def_id,
                                                                pdd.derivative_def_name
                                                           from dim_der_instrument_master  dim,
                                                                pdd_product_derivative_def pdd,
                                                                irm_instrument_type_master irm
                                                          where dim.instrument_id =
                                                                md.instrument_id
                                                            and dim.product_derivative_id =
                                                                pdd.derivative_def_id
                                                            and dim.instrument_type_id =
                                                                irm.instrument_type_id
                                                            and md.product_type =
                                                                'BASEMETAL'
                                                            and irm.instrument_type =
                                                                'Future'
                                                            and rownum <= 1)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'BASEMETAL'
         and md.process_id = pc_process_id;
      commit;
      --
      -- update m2m main currency and decimals
      --
      -- tbd : update is not working : 25th   : this is not working as have commented the above update to
      --get the m2m_price_unit_cur_id
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 7');
      vc_err_msg := 'line 3121';
      update md_m2m_daily md
         set (md.m2m_main_cur_id, md.m2m_main_cur_code, md.m2m_main_cur_decimals, md.main_currency_factor) = --
              (select (case
                        when cm.is_sub_cur = 'Y' then
                         scd.cur_id
                        else
                         cm.cur_id
                      end) base_currency_id,
                      (case
                        when cm.is_sub_cur = 'Y' then
                         cm_1.cur_code
                        else
                         cm.cur_code
                      end) cur_code,
                      (case
                        when cm.is_sub_cur = 'Y' then
                         cm_1.decimals
                        else
                         cm.decimals
                      end),
                      (case
                        when cm.is_sub_cur = 'Y' then
                         nvl(scd.factor, 1)
                        else
                         1
                      end) factor
                 from cm_currency_master      cm,
                      scd_sub_currency_detail scd,
                      cm_currency_master      cm_1
                where cm.cur_id = md.m2m_price_unit_cur_id
                  and cm.cur_id = scd.sub_cur_id(+)
                  and scd.cur_id = cm_1.cur_id(+))
       where md.process_id = pc_process_id
         and md.product_type = 'BASEMETAL';
      commit;
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 8');
      -- now update the m2m id in the tmpc_temp_m2m_pre_check
      -- table per contract item level,gmr level,grd level --
      vc_err_msg := 'line 3163';
      for c1 in (select md.md_id,
                        md.corporate_id,
                        md.product_id,
                        md.crop_year_id,
                        md.quality_id,
                        md.origin_id,
                        md.origin_group_id,
                        md.growth_code_id,
                        md.valuation_method,
                        md.mvp_id,
                        md.mvpl_id,
                        md.valuation_region,
                        md.valuation_point,
                        md.valuation_incoterm_id,
                        md.valuation_city_id,
                        md.valuation_basis,
                        md.reference_incoterm,
                        md.refernce_location_id refernce_location,
                        md.instrument_id,
                        md.valuation_dr_id,
                        md.valuation_month,
                        md.valuation_date,
                        md.shipment_month_year,
                        md.shipment_date,
                        md.rate_type,
                        md.payment_due_date
                   from md_m2m_daily md
                  where md.corporate_id = pc_corporate_id
                    and md.process_id = pc_process_id)
      loop
        if c1.valuation_method <> 'FIXED' then
          update tmpc_temp_m2m_pre_check tmpc
             set tmpc.internal_m2m_id = c1.md_id
           where tmpc.corporate_id = c1.corporate_id
             and tmpc.product_id = c1.product_id
             and tmpc.quality_id = c1.quality_id
             and tmpc.mvp_id = c1.mvp_id
             and tmpc.mvpl_id = c1.mvpl_id
             and tmpc.valuation_region = c1.valuation_region
             and tmpc.valuation_point = c1.valuation_point
             and tmpc.valuation_incoterm_id = c1.valuation_incoterm_id
             and tmpc.valuation_city_id = c1.valuation_city_id
             and tmpc.valuation_basis = c1.valuation_basis
             and tmpc.valuation_dr_id = c1.valuation_dr_id
             and tmpc.reference_incoterm = c1.reference_incoterm
             and tmpc.refernce_location = c1.refernce_location
             and tmpc.instrument_id = c1.instrument_id
             and tmpc.shipment_date = c1.shipment_date
             and tmpc.shipment_month || '-' || tmpc.shipment_year =
                 c1.shipment_month_year
             and decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') =
                 c1.rate_type
             and tmpc.product_type = 'BASEMETAL'
             and tmpc.payment_due_date = c1.payment_due_date;
        
        else
          update tmpc_temp_m2m_pre_check tmpc
             set tmpc.internal_m2m_id = c1.md_id
           where tmpc.corporate_id = c1.corporate_id
             and tmpc.product_id = c1.product_id
             and tmpc.quality_id = c1.quality_id
             and tmpc.mvp_id = c1.mvp_id
             and tmpc.mvpl_id = c1.mvpl_id
             and tmpc.valuation_region = c1.valuation_region
             and tmpc.valuation_point = c1.valuation_point
             and tmpc.valuation_incoterm_id = c1.valuation_incoterm_id
             and tmpc.valuation_city_id = c1.valuation_city_id
             and tmpc.valuation_basis = c1.valuation_basis
             and tmpc.reference_incoterm = c1.reference_incoterm
             and tmpc.refernce_location = c1.refernce_location
                --and tmpc.instrument_id = c1.instrument_id
             and tmpc.shipment_date = c1.shipment_date
             and tmpc.shipment_month || '-' || tmpc.shipment_year =
                 c1.shipment_month_year
             and decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') =
                 c1.rate_type
             and tmpc.product_type = 'BASEMETAL'
             and tmpc.payment_due_date = c1.payment_due_date;
        end if;
      end loop;
      commit;
    
      -- Update valuation_location, reference_location and valuation_incoterm
    
      for cc in (select tmpc.internal_m2m_id,
                        tmpc.product_id,
                        cim_val_loc.city_name valuation_location,
                        cim_ref_loc.city_name reference_location,
                        itm.incoterm valuation_incoterm,
                        cim_val_loc_v.country_name valuation_location_country,
                        cim_ref_loc_r.country_name reference_location_country
                   from tmpc_temp_m2m_pre_check tmpc,
                        cim_citymaster          cim_val_loc,
                        cim_citymaster          cim_ref_loc,
                        cym_countrymaster       cim_val_loc_v,
                        cym_countrymaster       cim_ref_loc_r,
                        itm_incoterm_master     itm
                  where tmpc.valuation_city_id = cim_val_loc.city_id
                    and tmpc.refernce_location = cim_ref_loc.city_id
                    and cim_val_loc_v.country_id = cim_val_loc.country_id
                    and cim_ref_loc_r.country_id = cim_ref_loc.country_id
                    and tmpc.valuation_incoterm_id = itm.incoterm_id
                    and tmpc.corporate_id = pc_corporate_id
                    and tmpc.product_type = 'BASEMETAL'
                  group by cim_val_loc.city_name,
                           cim_ref_loc.city_name,
                           itm.incoterm,
                           cim_val_loc_v.country_name,
                           cim_ref_loc_r.country_name,
                           tmpc.product_id,
                           tmpc.internal_m2m_id)
      loop
        update md_m2m_daily md
           set md.valuation_location         = cc.valuation_location,
               md.reference_location         = cc.reference_location,
               md.valuation_incoterm         = cc.valuation_incoterm,
               md.valuation_location_country = cc.valuation_location_country,
               md.reference_location_country = cc.reference_location_country
         where md.md_id = cc.internal_m2m_id
           and md.product_id = cc.product_id
           and md.process_id = pc_process_id;
      end loop;
      commit;
    
    end;
    sp_write_log(pc_corporate_id, pd_trade_date, 'sp_calc_m2m', 'Done');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_physical_process.sp_calc_m2m_cost',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           vc_err_msg,
                                                           '',
                                                           gvc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_calc_m2m_conc_cost(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process_id   varchar2,
                                  pc_user_id      varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_calc_m2m_cost
    --        author                                    :
    --        created date                              : 11th Jan 2011
    --        purpose                                   : populate secondary costs for contracts and gmrs
    --        parameters
    --        pc_corporate_id                           : corporate id
    --        pc_process_id                             : eod reference no
    --        modification history
    --        modified date                             :
    --        modified by                               :
    --        modify description                        :
    --------------------------------------------------------------------------------------------------------------------------
    vn_serial_no       number;
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vc_err_msg         varchar2(100);
  begin
    -- Generate unique m2m data with m2m id
    vc_err_msg := 'before generate Unique M2M data with M2M ID';
    begin
      vn_serial_no := 1;
      for cc in (select t.corporate_id,
                        t.conc_product_id,
                        t.conc_quality_id,
                        t.product_id,
                        t.quality_id,
                        t.element_id,
                        t.product_type,
                        t.mvp_id,
                        t.mvpl_id,
                        t.value_type,
                        t.valuation_region,
                        t.valuation_point,
                        t.valuation_incoterm_id,
                        t.valuation_city_id,
                        t.valuation_basis,
                        t.reference_incoterm,
                        t.refernce_location,
                        t.instrument_id,
                        t.valuation_dr_id,
                        t.price_basis as valuation_method,
                        t.m2m_price_unit_id,
                        pum.cur_id m2m_price_unit_cur_id,
                        cm.cur_code,
                        pum.weight_unit_id,
                        qum.qty_unit,
                        nvl(pum.weight, 1) as weight,
                        t.derivative_def_id,
                        t.valuation_month || '-' || t.valuation_year valuation_period,
                        t.valuation_date,
                        t.shipment_month || '-' || t.shipment_year shipment_month_year,
                        t.shipment_date,
                        decode(t.section_name, 'OPEN', 'OPEN', 'STOCK') rate_type,
                        pum.cur_id valuation_cur_id,
                        t.base_price_unit_id_in_ppu,
                        t.base_price_unit_id_in_pum,
                        t.is_tolling_contract,
                        t.is_tolling_extn,
                        t.payment_due_date
                   from tmpc_temp_m2m_pre_check  t,
                        pum_price_unit_master    pum,
                        cm_currency_master       cm,
                        qum_quantity_unit_master qum
                  where t.corporate_id = pc_corporate_id
                    and t.m2m_price_unit_id = pum.price_unit_id(+)
                    and pum.cur_id = cm.cur_id(+)
                    and pum.weight_unit_id = qum.qty_unit_id(+)
                    and t.product_type = 'CONCENTRATES'
                    and t.is_tolling_contract = 'N'
                    and t.is_tolling_extn = 'N'
                  group by t.corporate_id,
                           t.conc_product_id,
                           t.conc_quality_id,
                           t.product_id,
                           t.element_id,
                           t.product_type,
                           t.mvp_id,
                           t.mvpl_id,
                           t.value_type,
                           t.valuation_region,
                           t.valuation_point,
                           t.valuation_incoterm_id,
                           t.valuation_city_id,
                           t.valuation_basis,
                           t.reference_incoterm,
                           t.refernce_location,
                           t.instrument_id,
                           t.valuation_dr_id,
                           t.price_basis,
                           pum.cur_id,
                           t.m2m_price_unit_id,
                           t.m2m_price_unit_cur_id,
                           cm.cur_code,
                           pum.weight_unit_id,
                           qum.qty_unit,
                           nvl(pum.weight, 1),
                           t.quality_id,
                           t.derivative_def_id,
                           t.valuation_month || '-' || t.valuation_year,
                           t.valuation_date,
                           t.shipment_month || '-' || t.shipment_year,
                           t.shipment_date,
                           --this bit is important since for the same dr_id , open contract use forward rates and
                           --stock uses spot. tmef has been populated for both types
                           decode(t.section_name, 'OPEN', 'OPEN', 'STOCK'),
                           t.valuation_cur_id,
                           t.base_price_unit_id_in_ppu,
                           t.base_price_unit_id_in_pum,
                           t.is_tolling_contract,
                           t.is_tolling_extn,
                           t.payment_due_date)
      loop
        insert into md_m2m_daily
          (md_id,
           process_id,
           corporate_id,
           conc_product_id,
           conc_quality_id,
           product_id,
           quality_id,
           element_id,
           product_type,
           mvp_id,
           mvpl_id,
           valuation_region,
           valuation_point,
           valuation_incoterm_id,
           valuation_city_id,
           valuation_basis,
           reference_incoterm,
           refernce_location_id,
           instrument_id,
           valuation_dr_id,
           m2m_price_unit_id,
           m2m_price_unit_cur_id,
           m2m_price_unit_cur_code,
           m2m_price_unit_weight_unit_id,
           m2m_price_unit_weight_unit,
           m2m_price_unit_weight,
           valuation_month,
           valuation_future_contract,
           derivative_def_id,
           valuation_date,
           shipment_month_year,
           shipment_date,
           rate_type,
           valuation_cur_id,
           base_price_unit_id_in_ppu,
           base_price_unit_id_in_pum,
           valuation_method,
           is_tolling_contract,
           is_tolling_extn,
           payment_due_date)
        values
          ('MDC-' || vn_serial_no,
           pc_process_id,
           cc.corporate_id,
           cc.conc_product_id,
           cc.conc_quality_id,
           cc.product_id,
           cc.quality_id,
           cc.element_id,
           cc.product_type,
           cc.mvp_id,
           cc.mvpl_id,
           cc.valuation_region,
           cc.valuation_point,
           cc.valuation_incoterm_id,
           cc.valuation_city_id,
           cc.valuation_basis,
           cc.reference_incoterm,
           cc.refernce_location,
           cc.instrument_id,
           cc.valuation_dr_id,
           cc.m2m_price_unit_id,
           cc.m2m_price_unit_cur_id,
           cc.cur_code,
           cc.weight_unit_id,
           cc.qty_unit,
           cc.weight,
           cc.valuation_period,
           cc.valuation_dr_id,
           cc.derivative_def_id,
           cc.valuation_date,
           cc.shipment_month_year,
           cc.shipment_date,
           cc.rate_type,
           cc.valuation_cur_id,
           cc.base_price_unit_id_in_ppu,
           cc.base_price_unit_id_in_pum,
           cc.value_type,
           cc.is_tolling_contract,
           cc.is_tolling_extn,
           cc.payment_due_date);
        vn_serial_no := vn_serial_no + 1;
      end loop;
      commit;
      -- 
      -- Updating TC and RC into MD table
      --
      vc_err_msg := 'Updating TC and RC into MD table';
      for cur_update in (select tmpc.conc_product_id,
                                tmpc.conc_quality_id,
                                tmpc.element_id,
                                tmpc.shipment_month || '-' ||
                                tmpc.shipment_year shipment_month_year,
                                tmpc.payment_due_date,
                                tmpc.mvp_id,
                                tmpc.m2m_treatment_charge,
                                tmpc.m2m_tc_fw_exch_rate,
                                tmpc.m2m_refining_charge,
                                tmpc.m2m_rc_fw_exch_rate,
                                tmpc.conc_base_price_unit_id_ppu
                           from tmpc_temp_m2m_pre_check tmpc
                          where tmpc.corporate_id = pc_corporate_id
                            and tmpc.product_type = 'CONCENTRATES'
                            and tmpc.is_tolling_contract = 'N'
                            and tmpc.is_tolling_extn = 'N'
                          group by tmpc.conc_product_id,
                                   tmpc.conc_quality_id,
                                   tmpc.element_id,
                                   tmpc.shipment_month || '-' ||
                                   tmpc.shipment_year,
                                   tmpc.payment_due_date,
                                   tmpc.mvp_id,
                                   tmpc.m2m_treatment_charge,
                                   tmpc.m2m_tc_fw_exch_rate,
                                   tmpc.m2m_refining_charge,
                                   tmpc.m2m_rc_fw_exch_rate,
                                   tmpc.conc_base_price_unit_id_ppu)
      loop
        update md_m2m_daily md
           set md.treatment_charge    = cur_update.m2m_treatment_charge,
               md.tc_price_unit_id    = cur_update.conc_base_price_unit_id_ppu,
               md.m2m_tc_fw_exch_rate = cur_update.m2m_tc_fw_exch_rate,
               md.refine_charge       = cur_update.m2m_refining_charge,
               md.rc_price_unit_id    = cur_update.conc_base_price_unit_id_ppu,
               md.m2m_rc_fw_exch_rate = cur_update.m2m_rc_fw_exch_rate
         where md.process_id = pc_process_id
           and md.product_type = 'CONCENTRATES'
           and md.is_tolling_contract = 'N'
           and md.is_tolling_extn = 'N'
           and md.conc_product_id = cur_update.conc_product_id
           and md.conc_quality_id = cur_update.conc_quality_id
           and md.shipment_month_year = cur_update.shipment_month_year
           and md.payment_due_date = cur_update.payment_due_date
           and md.mvp_id = cur_update.mvp_id
           and md.element_id = cur_update.element_id;
      end loop;
    
      vc_err_msg := 'line 7913';
      -- Updating exg_id,settlement_price,settlement price avl date of the md table
      update md_m2m_daily md
         set (md.valuation_exchange_id, md.m2m_settlement_price, md.m2m_sett_price_available_date) = --
              (select pdd.exchange_id,
                      edq.price,
                      edq.dq_trade_date
                 from eodeom_derivative_quote_detail edq,
                      pum_price_unit_master          pum,
                      dim_der_instrument_master      dim,
                      div_der_instrument_valuation   div,
                      pdd_product_derivative_def     pdd,
                      cdim_corporate_dim             cdim
                where edq.dr_id = md.valuation_dr_id
                  and edq.corporate_id = pc_corporate_id
                  and dim.instrument_id = md.instrument_id
                  and edq.instrument_id = div.instrument_id
                  and dim.product_derivative_id = pdd.derivative_def_id
                  and edq.price_source_id = div.price_source_id
                  and div.price_unit_id = edq.price_unit_id
                  and div.is_deleted = 'N'
                  and edq.available_price_id = div.available_price_id
                  and edq.price_unit_id = pum.price_unit_id
                  and edq.price is not null
                  and edq.process_id = pc_process_id
                  and edq.dq_trade_date = cdim.valid_quote_date
                  and cdim.corporate_id = pc_corporate_id
                  and cdim.instrument_id = edq.instrument_id)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'CONCENTRATES'
         and md.is_tolling_contract = 'N'
         and md.is_tolling_extn = 'N'
         and md.valuation_method <> 'FIXED'
         and md.process_id = pc_process_id;
      commit;
      vc_err_msg := 'line 2450';
      --
      -- Update the M2M Location Incoterm Deviation    
      --
      for cur_update in (
                         
                         select tmpc.mvpl_id,
                                 tmpc.mvp_id,
                                 tmpc.conc_product_id,
                                 tmpc.valuation_incoterm_id,
                                 tmpc.element_id,
                                 tmpc.payment_due_date,
                                 tmpc.m2m_loc_incoterm_deviation,
                                 tmpc.m2m_ld_fw_exch_rate
                           from tmpc_temp_m2m_pre_check tmpc
                          where tmpc.product_type = 'CONCENTRATES'
                            and tmpc.is_tolling_contract = 'N'
                            and tmpc.is_tolling_extn = 'N'
                            and tmpc.corporate_id = pc_corporate_id)
      loop
      
        update md_m2m_daily md
           set md.m2m_loc_incoterm_deviation = cur_update.m2m_loc_incoterm_deviation,
               md.m2m_ld_fw_exch_rate        = cur_update.m2m_ld_fw_exch_rate
        
         where md.mvpl_id = cur_update.mvpl_id
           and md.mvp_id = cur_update.mvp_id
           and md.conc_product_id = cur_update.conc_product_id
           and md.valuation_incoterm_id = cur_update.valuation_incoterm_id
           and md.element_id = cur_update.element_id
           and md.product_type = 'CONCENTRATES'
           and md.is_tolling_contract = 'N'
           and md.is_tolling_extn = 'N'
           and md.payment_due_date = cur_update.payment_due_date
           and md.process_id = pc_process_id;
      
      end loop;
      commit;
    
      vc_err_msg := 'line 7972';
      update md_m2m_daily md
         set md.net_m2m_price = nvl(md.m2m_settlement_price, 0)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'CONCENTRATES'
         and md.is_tolling_contract = 'N'
         and md.is_tolling_extn = 'N'
         and md.process_id = pc_process_id;
      commit;
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 5');
      vc_err_msg := 'line 7984';
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 6');
      -- Update derivative def id/name
      update md_m2m_daily md
         set (derivative_def_id, derivative_def_name) = --
              (select pdd.derivative_def_id,
                      pdd.derivative_def_name
                 from dim_der_instrument_master  dim,
                      pdd_product_derivative_def pdd,
                      irm_instrument_type_master irm
                where dim.instrument_id = md.instrument_id
                  and md.product_type = 'CONCENTRATES'
                  and dim.product_derivative_id = pdd.derivative_def_id
                  and dim.instrument_type_id = irm.instrument_type_id
                  and irm.instrument_type = 'Future'
                  and rownum <= 1)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'CONCENTRATES'
         and md.is_tolling_contract = 'N'
         and md.is_tolling_extn = 'N'
         and md.process_id = pc_process_id;
      commit;
      --get the m2m_price_unit_cur_id
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 7');
      vc_err_msg := 'line 8013';
      update md_m2m_daily md
         set (md.m2m_main_cur_id, md.m2m_main_cur_code, md.m2m_main_cur_decimals, md.main_currency_factor) = --
              (select (case
                        when cm.is_sub_cur = 'Y' then
                         scd.cur_id
                        else
                         cm.cur_id
                      end) base_currency_id,
                      (case
                        when cm.is_sub_cur = 'Y' then
                         cm_1.cur_code
                        else
                         cm.cur_code
                      end) cur_code,
                      (case
                        when cm.is_sub_cur = 'Y' then
                         cm_1.decimals
                        else
                         cm.decimals
                      end),
                      (case
                        when cm.is_sub_cur = 'Y' then
                         nvl(scd.factor, 1)
                        else
                         1
                      end) factor
                 from cm_currency_master      cm,
                      scd_sub_currency_detail scd,
                      cm_currency_master      cm_1
                where cm.cur_id = md.m2m_price_unit_cur_id
                  and cm.cur_id = scd.sub_cur_id(+)
                  and scd.cur_id = cm_1.cur_id(+))
       where md.process_id = pc_process_id
         and md.product_type = 'CONCENTRATES'
         and md.is_tolling_contract = 'N'
         and md.is_tolling_extn = 'N';
      commit;
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 8');
      -- now update the m2m id in the tmpc_temp_m2m_pre_check
      -- table per contract item level,gmr level,grd level --
      vc_err_msg := 'line 8056';
      for c1 in (select md.md_id,
                        md.conc_product_id,
                        md.conc_quality_id,
                        md.corporate_id,
                        md.product_id,
                        md.element_id,
                        md.crop_year_id,
                        md.quality_id,
                        md.origin_id,
                        md.origin_group_id,
                        md.growth_code_id,
                        md.valuation_method,
                        md.mvp_id,
                        md.mvpl_id,
                        md.valuation_region,
                        md.valuation_point,
                        md.valuation_incoterm_id,
                        md.valuation_city_id,
                        md.valuation_basis,
                        md.reference_incoterm,
                        md.refernce_location_id refernce_location,
                        md.instrument_id,
                        md.valuation_dr_id,
                        md.valuation_month,
                        md.valuation_date,
                        md.shipment_month_year,
                        md.shipment_date,
                        md.rate_type,
                        md.payment_due_date
                   from md_m2m_daily md
                  where md.corporate_id = pc_corporate_id
                    and md.product_type = 'CONCENTRATES'
                    and md.is_tolling_contract = 'N'
                    and md.is_tolling_extn = 'N'
                    and md.process_id = pc_process_id)
      loop
        if c1.valuation_method <> 'FIXED' then
          update tmpc_temp_m2m_pre_check tmpc
             set tmpc.internal_m2m_id = c1.md_id
           where tmpc.corporate_id = c1.corporate_id
             and tmpc.product_id = c1.product_id
             and tmpc.conc_product_id = c1.conc_product_id
             and tmpc.conc_quality_id = c1.conc_quality_id
             and tmpc.element_id = c1.element_id
             and tmpc.quality_id = c1.quality_id
             and tmpc.mvp_id = c1.mvp_id
             and tmpc.mvpl_id = c1.mvpl_id
             and tmpc.valuation_region = c1.valuation_region
             and tmpc.valuation_point = c1.valuation_point
             and tmpc.valuation_incoterm_id = c1.valuation_incoterm_id
             and tmpc.valuation_city_id = c1.valuation_city_id
             and tmpc.valuation_basis = c1.valuation_basis
             and tmpc.valuation_dr_id = c1.valuation_dr_id
             and tmpc.reference_incoterm = c1.reference_incoterm
             and tmpc.refernce_location = c1.refernce_location
             and tmpc.instrument_id = c1.instrument_id
             and tmpc.shipment_date = c1.shipment_date
             and tmpc.shipment_month || '-' || tmpc.shipment_year =
                 c1.shipment_month_year
             and decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') =
                 c1.rate_type
             and tmpc.product_type = 'CONCENTRATES'
             and tmpc.is_tolling_contract = 'N'
             and tmpc.is_tolling_extn = 'N'
             and tmpc.payment_due_date = c1.payment_due_date;
        else
          update tmpc_temp_m2m_pre_check tmpc
             set tmpc.internal_m2m_id = c1.md_id
           where tmpc.corporate_id = c1.corporate_id
             and tmpc.conc_product_id = c1.conc_product_id
             and tmpc.conc_quality_id = c1.conc_quality_id
             and tmpc.product_id = c1.product_id
             and tmpc.quality_id = c1.quality_id
             and tmpc.element_id = c1.element_id
             and tmpc.mvp_id = c1.mvp_id
             and tmpc.mvpl_id = c1.mvpl_id
             and tmpc.valuation_region = c1.valuation_region
             and tmpc.valuation_point = c1.valuation_point
             and tmpc.valuation_incoterm_id = c1.valuation_incoterm_id
             and tmpc.valuation_city_id = c1.valuation_city_id
             and tmpc.valuation_basis = c1.valuation_basis
             and tmpc.reference_incoterm = c1.reference_incoterm
             and tmpc.refernce_location = c1.refernce_location
             and tmpc.shipment_date = c1.shipment_date
             and tmpc.shipment_month || '-' || tmpc.shipment_year =
                 c1.shipment_month_year
             and decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') =
                 c1.rate_type
             and tmpc.product_type = 'CONCENTRATES'
             and tmpc.is_tolling_contract = 'N'
             and tmpc.is_tolling_extn = 'N'
             and tmpc.payment_due_date = c1.payment_due_date;
        end if;
      end loop;
      commit;
    
      --update valuation_location, reference_location and valuation_incoterm
    
      for cc in (select tmpc.internal_m2m_id,
                        tmpc.product_id,
                        cim_val_loc.city_name valuation_location,
                        cim_ref_loc.city_name reference_location,
                        itm.incoterm valuation_incoterm,
                        cim_val_loc_v.country_name valuation_location_country,
                        cim_ref_loc_r.country_name reference_location_country
                   from tmpc_temp_m2m_pre_check tmpc,
                        cim_citymaster          cim_val_loc,
                        cim_citymaster          cim_ref_loc,
                        cym_countrymaster       cim_val_loc_v,
                        cym_countrymaster       cim_ref_loc_r,
                        itm_incoterm_master     itm
                  where tmpc.valuation_city_id = cim_val_loc.city_id
                    and tmpc.refernce_location = cim_ref_loc.city_id
                    and cim_val_loc_v.country_id = cim_val_loc.country_id
                    and cim_ref_loc_r.country_id = cim_ref_loc.country_id
                    and tmpc.valuation_incoterm_id = itm.incoterm_id
                    and tmpc.corporate_id = pc_corporate_id
                    and tmpc.product_type = 'CONCENTRATES'
                    and tmpc.is_tolling_contract = 'N'
                    and tmpc.is_tolling_extn = 'N'
                  group by cim_val_loc.city_name,
                           cim_ref_loc.city_name,
                           itm.incoterm,
                           cim_val_loc_v.country_name,
                           cim_ref_loc_r.country_name,
                           tmpc.product_id,
                           tmpc.internal_m2m_id)
      loop
      
        update md_m2m_daily md
           set valuation_location         = cc.valuation_location,
               reference_location         = cc.reference_location,
               valuation_incoterm         = cc.valuation_incoterm,
               valuation_location_country = cc.valuation_location_country,
               reference_location_country = cc.reference_location_country
         where md.md_id = cc.internal_m2m_id
           and md.product_id = cc.product_id
           and md.process_id = pc_process_id;
        commit;
      end loop;
      commit;
    
    end;
    sp_write_log(pc_corporate_id, pd_trade_date, 'sp_calc_m2m', 'Done');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_physical_process.sp_calc_m2m_conc_cost',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           vc_err_msg,
                                                           '',
                                                           pkg_phy_physical_process.gvc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_calc_m2m_tolling_extn_cost(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_calc_m2m_cost
    --        author                                    :
    --        created date                              : 11th Jan 2011
    --        purpose                                   : populate secondary costs for contracts and gmrs
    --        parameters
    --        pc_corporate_id                           : corporate id
    --        pc_process_id                             : eod reference no
    --        modification history
    --        modified date                             :
    --        modified by                               :
    --        modify description                        :
    --------------------------------------------------------------------------------------------------------------------------
    vn_serial_no            number;
    vobj_error_log          tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count      number := 1;
    vc_err_msg              varchar2(100);
    pn_charge_amt           number;
    pc_charge_price_unit_id varchar2(25);
  begin
    --generate unique m2m data with m2m id
    vc_err_msg := 'before generate Unique M2M data with M2M ID';
    begin
      vn_serial_no := 1;
      for cc in (select t.corporate_id,
                        t.conc_product_id,
                        t.conc_quality_id,
                        t.product_id,
                        t.quality_id,
                        t.element_id,
                        t.product_type,
                        t.mvp_id,
                        t.mvpl_id,
                        t.value_type,
                        t.valuation_region,
                        t.valuation_point,
                        t.valuation_incoterm_id,
                        t.valuation_city_id,
                        t.valuation_basis,
                        t.reference_incoterm,
                        t.refernce_location,
                        t.instrument_id,
                        t.valuation_dr_id,
                        t.price_basis as valuation_method,
                        t.m2m_price_unit_id,
                        pum.cur_id m2m_price_unit_cur_id,
                        cm.cur_code,
                        pum.weight_unit_id,
                        qum.qty_unit,
                        nvl(pum.weight, 1) as weight,
                        t.derivative_def_id,
                        t.valuation_month || '-' || t.valuation_year valuation_period,
                        t.valuation_date,
                        t.shipment_month || '-' || t.shipment_year shipment_month_year,
                        t.shipment_date,
                        decode(t.section_name, 'OPEN', 'OPEN', 'STOCK') rate_type,
                        pum.cur_id valuation_cur_id,
                        t.base_price_unit_id_in_ppu,
                        t.base_price_unit_id_in_pum,
                        t.is_tolling_contract,
                        t.is_tolling_extn
                   from tmpc_temp_m2m_pre_check  t,
                        pum_price_unit_master    pum,
                        cm_currency_master       cm,
                        qum_quantity_unit_master qum
                  where t.corporate_id = pc_corporate_id
                    and t.m2m_price_unit_id = pum.price_unit_id(+)
                    and pum.cur_id = cm.cur_id(+)
                    and pum.weight_unit_id = qum.qty_unit_id(+)
                    and t.product_type = 'CONCENTRATES'
                    and t.is_tolling_contract = 'Y'
                    and t.is_tolling_extn = 'Y'
                  group by t.corporate_id,
                           t.conc_product_id,
                           t.conc_quality_id,
                           t.product_id,
                           t.element_id,
                           t.product_type,
                           t.mvp_id,
                           t.mvpl_id,
                           t.value_type,
                           t.valuation_region,
                           t.valuation_point,
                           t.valuation_incoterm_id,
                           t.valuation_city_id,
                           t.valuation_basis,
                           t.reference_incoterm,
                           t.refernce_location,
                           t.instrument_id,
                           t.valuation_dr_id,
                           t.price_basis,
                           pum.cur_id,
                           t.m2m_price_unit_id,
                           t.m2m_price_unit_cur_id,
                           cm.cur_code,
                           pum.weight_unit_id,
                           qum.qty_unit,
                           nvl(pum.weight, 1),
                           t.quality_id,
                           t.derivative_def_id,
                           t.valuation_month || '-' || t.valuation_year,
                           t.valuation_date,
                           t.shipment_month || '-' || t.shipment_year,
                           t.shipment_date,
                           --this bit is important since for the same dr_id , open contract use forward rates and
                           --stock uses spot. tmef has been populated for both types
                           decode(t.section_name, 'OPEN', 'OPEN', 'STOCK'),
                           t.valuation_cur_id,
                           t.base_price_unit_id_in_ppu,
                           t.base_price_unit_id_in_pum,
                           t.is_tolling_contract,
                           t.is_tolling_extn)
      loop
        insert into md_m2m_daily
          (md_id,
           process_id,
           corporate_id,
           conc_product_id,
           conc_quality_id,
           product_id,
           quality_id,
           element_id,
           product_type,
           mvp_id,
           mvpl_id,
           valuation_region,
           valuation_point,
           valuation_incoterm_id,
           valuation_city_id,
           valuation_basis,
           reference_incoterm,
           refernce_location_id,
           instrument_id,
           valuation_dr_id,
           m2m_price_unit_id,
           m2m_price_unit_cur_id,
           m2m_price_unit_cur_code,
           m2m_price_unit_weight_unit_id,
           m2m_price_unit_weight_unit,
           m2m_price_unit_weight,
           valuation_month,
           valuation_future_contract,
           derivative_def_id,
           valuation_date,
           shipment_month_year,
           shipment_date,
           rate_type,
           valuation_cur_id,
           base_price_unit_id_in_ppu,
           base_price_unit_id_in_pum,
           valuation_method,
           is_tolling_contract,
           is_tolling_extn)
        values
          ('MDE-' || vn_serial_no,
           pc_process_id,
           cc.corporate_id,
           cc.conc_product_id,
           cc.conc_quality_id,
           cc.product_id,
           cc.quality_id,
           cc.element_id,
           cc.product_type,
           cc.mvp_id,
           cc.mvpl_id,
           cc.valuation_region,
           cc.valuation_point,
           cc.valuation_incoterm_id,
           cc.valuation_city_id,
           cc.valuation_basis,
           cc.reference_incoterm,
           cc.refernce_location,
           cc.instrument_id,
           cc.valuation_dr_id,
           cc.m2m_price_unit_id,
           cc.m2m_price_unit_cur_id,
           cc.cur_code,
           cc.weight_unit_id,
           cc.qty_unit,
           cc.weight,
           cc.valuation_period,
           cc.valuation_dr_id,
           cc.derivative_def_id,
           cc.valuation_date,
           cc.shipment_month_year,
           cc.shipment_date,
           cc.rate_type,
           cc.valuation_cur_id,
           cc.base_price_unit_id_in_ppu,
           cc.base_price_unit_id_in_pum,
           cc.value_type,
           cc.is_tolling_contract,
           cc.is_tolling_extn);
        vn_serial_no := vn_serial_no + 1;
      end loop;
      commit;
      --Checking for the treatment  is there or not
      --For this  we are calling the sp_get_treatment_charge
      for cc_tmpc in (select tmpc.corporate_id,
                             tmpc.conc_product_id,
                             tmpc.conc_quality_id,
                             tmpc.product_id,
                             tmpc.quality_id,
                             tmpc.element_id,
                             tmpc.base_price_unit_id_in_ppu,
                             tmpc.shipment_month,
                             tmpc.shipment_year,
                             tmpc.mvp_id valuation_point_id,
                             ppu.decimals
                        from tmpc_temp_m2m_pre_check tmpc,
                             pdm_productmaster       pdm,
                             qat_quality_attributes  qat,
                             ppu_product_price_units ppu
                       where tmpc.product_type = 'CONCENTRATES'
                         and tmpc.is_tolling_contract = 'Y'
                         and tmpc.is_tolling_extn = 'Y'
                         and tmpc.corporate_id = pc_corporate_id
                         and tmpc.conc_product_id = pdm.product_id
                         and tmpc.conc_quality_id = qat.quality_id
                         and tmpc.base_price_unit_id_in_ppu =
                             ppu.internal_price_unit_id
                       group by tmpc.corporate_id,
                                tmpc.conc_product_id,
                                tmpc.conc_quality_id,
                                tmpc.product_id,
                                tmpc.quality_id,
                                tmpc.base_price_unit_id_in_ppu,
                                tmpc.element_id,
                                tmpc.mvp_id,
                                tmpc.shipment_month,
                                tmpc.shipment_year,
                                ppu.decimals)
      loop
        -- updating treatment charge  to the md table
        pkg_phy_pre_check_process.sp_calc_m2m_tc_pc_rc_charge(cc_tmpc.corporate_id,
                                                              pd_trade_date,
                                                              cc_tmpc.conc_product_id,
                                                              cc_tmpc.conc_quality_id,
                                                              cc_tmpc.valuation_point_id, --valuation_id
                                                              'Treatment Charges', --charge_type
                                                              cc_tmpc.element_id,
                                                              cc_tmpc.shipment_month,
                                                              cc_tmpc.shipment_year,
                                                              cc_tmpc.base_price_unit_id_in_ppu,
                                                              pn_charge_amt,
                                                              pc_charge_price_unit_id);
      
        update md_m2m_daily md
           set md.treatment_charge = pn_charge_amt,
               md.tc_price_unit_id = pc_charge_price_unit_id
         where md.corporate_id = pc_corporate_id
           and md.product_type = 'CONCENTRATES'
           and md.is_tolling_contract = 'Y'
           and md.is_tolling_extn = 'Y'
           and md.conc_product_id = cc_tmpc.conc_product_id
           and md.conc_quality_id = cc_tmpc.conc_quality_id
           and md.product_id = cc_tmpc.product_id
           and md.quality_id = cc_tmpc.quality_id
           and md.shipment_month_year =
               cc_tmpc.shipment_month || '-' || cc_tmpc.shipment_year
           and md.mvp_id = cc_tmpc.valuation_point_id
           and md.process_id = pc_process_id
           and md.element_id = cc_tmpc.element_id
           and md.process_id = pc_process_id;
        commit;
        -- end if;
        -- updating refine  charge  to the md table
        pkg_phy_pre_check_process.sp_calc_m2m_tc_pc_rc_charge(cc_tmpc.corporate_id,
                                                              pd_trade_date,
                                                              cc_tmpc.conc_product_id,
                                                              cc_tmpc.conc_quality_id,
                                                              cc_tmpc.valuation_point_id,
                                                              'Refining Charges',
                                                              cc_tmpc.element_id,
                                                              cc_tmpc.shipment_month,
                                                              cc_tmpc.shipment_year,
                                                              cc_tmpc.base_price_unit_id_in_ppu,
                                                              pn_charge_amt,
                                                              pc_charge_price_unit_id);
      
        update md_m2m_daily md
           set md.refine_charge    = pn_charge_amt,
               md.rc_price_unit_id = pc_charge_price_unit_id
         where md.corporate_id = pc_corporate_id
           and md.product_type = 'CONCENTRATES'
           and md.is_tolling_contract = 'Y'
           and md.is_tolling_extn = 'Y'
           and md.conc_product_id = cc_tmpc.conc_product_id
           and md.conc_quality_id = cc_tmpc.conc_quality_id
           and md.product_id = cc_tmpc.product_id
           and md.quality_id = cc_tmpc.quality_id
           and md.shipment_month_year =
               cc_tmpc.shipment_month || '-' || cc_tmpc.shipment_year
           and md.mvp_id = cc_tmpc.valuation_point_id
           and md.process_id = pc_process_id
           and md.element_id = cc_tmpc.element_id
           and md.process_id = pc_process_id;
        -- end if;
      end loop;
      commit;
      -- updating penalty  charge  to the md table 
    
      /** End of updatin the Treatment Charge,Refine Charge and  Penalty Charge of the MD table ***/
      vc_err_msg := 'line 2819';
      --Updating exg_id,settlement_price,settlement price avl date of the md table
      update md_m2m_daily md
         set (md.valuation_exchange_id, md.m2m_settlement_price, md.m2m_sett_price_available_date) = --
              (select pdd.exchange_id,
                      edq.price,
                      edq.dq_trade_date
                 from eodeom_derivative_quote_detail edq,
                      pum_price_unit_master          pum,
                      dim_der_instrument_master      dim,
                      div_der_instrument_valuation   div,
                      pdd_product_derivative_def     pdd,
                      cdim_corporate_dim             cdim
                where edq.dr_id = md.valuation_dr_id
                  and edq.corporate_id = pc_corporate_id
                  and dim.instrument_id = md.instrument_id
                  and edq.instrument_id = div.instrument_id
                  and dim.product_derivative_id = pdd.derivative_def_id
                  and edq.price_source_id = div.price_source_id
                  and div.price_unit_id = edq.price_unit_id
                  and div.is_deleted = 'N'
                  and edq.available_price_id = div.available_price_id
                  and edq.price_unit_id = pum.price_unit_id
                  and edq.price is not null
                  and edq.process_id = pc_process_id
                  and edq.dq_trade_date = cdim.valid_quote_date
                  and cdim.corporate_id = pc_corporate_id
                  and cdim.instrument_id = edq.instrument_id)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'CONCENTRATES'
         and md.is_tolling_contract = 'Y'
         and md.is_tolling_extn = 'Y'
         and md.valuation_method <> 'FIXED'
         and md.process_id = pc_process_id;
      commit;
      vc_err_msg := 'line 2887';
      --update the m2m location -incoterm deviation for the within region of growth    
      update md_m2m_daily md
         set md.m2m_loc_incoterm_deviation = round(nvl((select sum(ldc.cost_value /
                                                                  nvl(vpp.weight,
                                                                      1) *
                                                                  pkg_general.f_get_converted_currency_amt(md.corporate_id,
                                                                                                           vpp.cur_id,
                                                                                                           md_base.cur_id,
                                                                                                           pd_trade_date,
                                                                                                           1) *
                                                                  (pkg_general.f_get_converted_quantity(md.product_id,
                                                                                                        vpp.weight_unit_id,
                                                                                                        md_base.weight_unit_id,
                                                                                                        1)))
                                                       
                                                         from lds_location_diff_setup ldh,
                                                              ldc_location_diff_cost  ldc,
                                                              v_ppu_pum               vpp,
                                                              pum_price_unit_master   md_base
                                                        where ldh.loc_diff_id =
                                                              ldc.loc_diff_id
                                                          and ldh.valuation_city_id =
                                                              md.valuation_city_id
                                                          and md.mvp_id =
                                                              ldh.valuation_point_id
                                                          and md.conc_product_id = --updated
                                                              ldh.product_id
                                                          and md_base.price_unit_id =
                                                              md.base_price_unit_id_in_pum
                                                          and md.product_type =
                                                              'CONCENTRATES'
                                                          and ldh.inco_term_id =
                                                              md.valuation_incoterm_id
                                                          and ldh.corporate_id =
                                                              pc_corporate_id
                                                          and ldc.cost_price_unit_id =
                                                              vpp.product_price_unit_id
                                                          and ldh.as_on_date =
                                                              (select max(ldh1.as_on_date)
                                                                 from lds_location_diff_setup ldh1
                                                                where ldh1.as_on_date <=
                                                                      pd_trade_date
                                                                  and ldh1.valuation_point_id =
                                                                      ldh.valuation_point_id
                                                                  and ldh1.inco_term_id =
                                                                      ldh.inco_term_id
                                                                  and ldh1.valuation_city_id =
                                                                      ldh.valuation_city_id
                                                                  and ldh1.product_id =
                                                                      ldh.product_id)),
                                                       0),
                                                   4)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'CONCENTRATES'
         and md.is_tolling_contract = 'Y'
         and md.is_tolling_extn = 'Y'
         and md.process_id = pc_process_id;
      commit;
      vc_err_msg := 'line 3049';
      update md_m2m_daily md
         set md.net_m2m_price = nvl(md.m2m_settlement_price, 0)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'CONCENTRATES'
         and md.process_id = pc_process_id
         and md.is_tolling_contract = 'Y'
         and md.is_tolling_extn = 'Y';
      --   dbms_output.put_line('after update -5 ');
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 5');
      vc_err_msg := 'line 3068';
    
      vc_err_msg := 'line 3090';
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 6');
      -- update derivative def id/name
      update md_m2m_daily md
         set (derivative_def_id, derivative_def_name) = (select pdd.derivative_def_id,
                                                                pdd.derivative_def_name
                                                           from dim_der_instrument_master  dim,
                                                                pdd_product_derivative_def pdd,
                                                                irm_instrument_type_master irm
                                                          where dim.instrument_id =
                                                                md.instrument_id
                                                            and md.product_type =
                                                                'CONCENTRATES'
                                                            and dim.product_derivative_id =
                                                                pdd.derivative_def_id
                                                            and dim.instrument_type_id =
                                                                irm.instrument_type_id
                                                            and irm.instrument_type =
                                                                'Future'
                                                            and rownum <= 1)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'CONCENTRATES'
         and md.is_tolling_contract = 'Y'
         and md.is_tolling_extn = 'Y'
         and md.process_id = pc_process_id;
      commit;
      --get the m2m_price_unit_cur_id
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 7');
      vc_err_msg := 'line 3121';
      update md_m2m_daily md
         set (md.m2m_main_cur_id, md.m2m_main_cur_code, md.m2m_main_cur_decimals, md.main_currency_factor) = --
              (select (case
                        when cm.is_sub_cur = 'Y' then
                         scd.cur_id
                        else
                         cm.cur_id
                      end) base_currency_id,
                      (case
                        when cm.is_sub_cur = 'Y' then
                         cm_1.cur_code
                        else
                         cm.cur_code
                      end) cur_code,
                      (case
                        when cm.is_sub_cur = 'Y' then
                         cm_1.decimals
                        else
                         cm.decimals
                      end),
                      (case
                        when cm.is_sub_cur = 'Y' then
                         nvl(scd.factor, 1)
                        else
                         1
                      end) factor
                 from cm_currency_master      cm,
                      scd_sub_currency_detail scd,
                      cm_currency_master      cm_1
                where cm.cur_id = md.m2m_price_unit_cur_id
                  and cm.cur_id = scd.sub_cur_id(+)
                  and scd.cur_id = cm_1.cur_id(+))
       where md.process_id = pc_process_id
         and md.product_type = 'CONCENTRATES'
         and md.is_tolling_contract = 'Y'
         and md.is_tolling_extn = 'Y';
      commit;
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 8');
      -- now update the m2m id in the tmpc_temp_m2m_pre_check
      -- table per contract item level,gmr level,grd level --
      vc_err_msg := 'line 3163';
      for c1 in (select md.md_id,
                        md.conc_product_id,
                        md.conc_quality_id,
                        md.corporate_id,
                        md.product_id,
                        md.element_id,
                        md.crop_year_id,
                        md.quality_id,
                        md.origin_id,
                        md.origin_group_id,
                        md.growth_code_id,
                        md.valuation_method,
                        md.mvp_id,
                        md.mvpl_id,
                        md.valuation_region,
                        md.valuation_point,
                        md.valuation_incoterm_id,
                        md.valuation_city_id,
                        md.valuation_basis,
                        md.reference_incoterm,
                        md.refernce_location_id refernce_location,
                        md.instrument_id,
                        md.valuation_dr_id,
                        md.valuation_month,
                        md.valuation_date,
                        md.shipment_month_year,
                        md.shipment_date,
                        md.rate_type
                   from md_m2m_daily md
                  where md.corporate_id = pc_corporate_id
                    and md.product_type = 'CONCENTRATES'
                    and md.is_tolling_contract = 'Y'
                    and md.is_tolling_extn = 'Y'
                    and md.process_id = pc_process_id)
      loop
        if c1.valuation_method <> 'FIXED' then
          update tmpc_temp_m2m_pre_check tmpc
             set tmpc.internal_m2m_id = c1.md_id
           where tmpc.corporate_id = c1.corporate_id
             and tmpc.product_id = c1.product_id
             and tmpc.conc_product_id = c1.conc_product_id
             and tmpc.conc_quality_id = c1.conc_quality_id
             and tmpc.element_id = c1.element_id
             and tmpc.quality_id = c1.quality_id
             and tmpc.mvp_id = c1.mvp_id
             and tmpc.mvpl_id = c1.mvpl_id
             and tmpc.valuation_region = c1.valuation_region
             and tmpc.valuation_point = c1.valuation_point
             and tmpc.valuation_incoterm_id = c1.valuation_incoterm_id
             and tmpc.valuation_city_id = c1.valuation_city_id
             and tmpc.valuation_basis = c1.valuation_basis
             and tmpc.valuation_dr_id = c1.valuation_dr_id
             and tmpc.reference_incoterm = c1.reference_incoterm
             and tmpc.refernce_location = c1.refernce_location
             and tmpc.instrument_id = c1.instrument_id
             and tmpc.shipment_date = c1.shipment_date
             and tmpc.shipment_month || '-' || tmpc.shipment_year =
                 c1.shipment_month_year
             and decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') =
                 c1.rate_type
             and tmpc.product_type = 'CONCENTRATES'
             and tmpc.is_tolling_contract = 'Y'
             and tmpc.is_tolling_extn = 'Y';
        else
          update tmpc_temp_m2m_pre_check tmpc
             set tmpc.internal_m2m_id = c1.md_id
           where tmpc.corporate_id = c1.corporate_id
             and tmpc.conc_product_id = c1.conc_product_id
             and tmpc.conc_quality_id = c1.conc_quality_id
             and tmpc.product_id = c1.product_id
             and tmpc.quality_id = c1.quality_id
             and tmpc.element_id = c1.element_id
             and tmpc.mvp_id = c1.mvp_id
             and tmpc.mvpl_id = c1.mvpl_id
             and tmpc.valuation_region = c1.valuation_region
             and tmpc.valuation_point = c1.valuation_point
             and tmpc.valuation_incoterm_id = c1.valuation_incoterm_id
             and tmpc.valuation_city_id = c1.valuation_city_id
             and tmpc.valuation_basis = c1.valuation_basis
             and tmpc.reference_incoterm = c1.reference_incoterm
             and tmpc.refernce_location = c1.refernce_location
             and tmpc.shipment_date = c1.shipment_date
             and tmpc.shipment_month || '-' || tmpc.shipment_year =
                 c1.shipment_month_year
             and decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') =
                 c1.rate_type
             and tmpc.product_type = 'CONCENTRATES'
             and tmpc.is_tolling_contract = 'Y'
             and tmpc.is_tolling_extn = 'Y';
        end if;
      end loop;
      commit;
      --update valuation_location, reference_location and valuation_incoterm
    
      for cc in (select tmpc.internal_m2m_id,
                        tmpc.product_id,
                        cim_val_loc.city_name valuation_location,
                        cim_ref_loc.city_name reference_location,
                        itm.incoterm valuation_incoterm,
                        cim_val_loc_v.country_name valuation_location_country,
                        cim_ref_loc_r.country_name reference_location_country
                   from tmpc_temp_m2m_pre_check tmpc,
                        cim_citymaster          cim_val_loc,
                        cim_citymaster          cim_ref_loc,
                        cym_countrymaster       cim_val_loc_v,
                        cym_countrymaster       cim_ref_loc_r,
                        itm_incoterm_master     itm
                  where tmpc.valuation_city_id = cim_val_loc.city_id
                    and tmpc.refernce_location = cim_ref_loc.city_id
                    and cim_val_loc_v.country_id = cim_val_loc.country_id
                    and cim_ref_loc_r.country_id = cim_ref_loc.country_id
                    and tmpc.valuation_incoterm_id = itm.incoterm_id
                    and tmpc.corporate_id = pc_corporate_id
                    and tmpc.product_type = 'CONCENTRATES'
                    and tmpc.is_tolling_contract = 'Y'
                    and tmpc.is_tolling_extn = 'Y'
                  group by cim_val_loc.city_name,
                           cim_ref_loc.city_name,
                           itm.incoterm,
                           cim_val_loc_v.country_name,
                           cim_ref_loc_r.country_name,
                           tmpc.product_id,
                           tmpc.internal_m2m_id)
      loop
      
        update md_m2m_daily md
           set valuation_location         = cc.valuation_location,
               reference_location         = cc.reference_location,
               valuation_incoterm         = cc.valuation_incoterm,
               valuation_location_country = cc.valuation_location_country,
               reference_location_country = cc.reference_location_country
         where md.md_id = cc.internal_m2m_id
           and md.product_id = cc.product_id
           and md.process_id = pc_process_id;
        commit;
      end loop;
      commit;
    end;
    sp_write_log(pc_corporate_id, pd_trade_date, 'sp_calc_m2m', 'Done');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_physical_process.sp_calc_m2m_conc_cost',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           vc_err_msg,
                                                           '',
                                                           pkg_phy_physical_process.gvc_process,
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
  
    vc_dbd_id          varchar2(15);
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_logno           number := 0;
  begin
  
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          vn_logno,
                          'Rollback Start');
    vc_dbd_id := pc_dbd_id;
    delete from agdul_alloc_group_detail_ul where dbd_id = vc_dbd_id;
    delete from aghul_alloc_group_header_ul where dbd_id = vc_dbd_id;
    delete from cigcul_contrct_itm_gmr_cost_ul where dbd_id = vc_dbd_id;
    delete from csul_cost_store_ul where dbd_id = vc_dbd_id;
    commit;
    delete from dgrdul_delivered_grd_ul where dbd_id = vc_dbd_id;
    delete from gmrul_gmr_ul where dbd_id = vc_dbd_id;
    delete from mogrdul_moved_out_grd_ul where dbd_id = vc_dbd_id;
    delete from pcadul_pc_agency_detail_ul where dbd_id = vc_dbd_id;
    commit;
    delete from pcbpdul_pc_base_price_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcbphul_pc_base_prc_header_ul where dbd_id = vc_dbd_id;
    delete from pcdbul_pc_delivery_basis_ul where dbd_id = vc_dbd_id;
    delete from pcddul_document_details_ul where dbd_id = vc_dbd_id;
    commit;
    delete from pcdiobul_di_optional_basis_ul where dbd_id = vc_dbd_id;
    delete from pcdipeul_di_pricing_elemnt_ul where dbd_id = vc_dbd_id;
    delete from pcdiqdul_di_quality_detail_ul where dbd_id = vc_dbd_id;
    delete from pcdiul_pc_delivery_item_ul where dbd_id = vc_dbd_id;
    commit;
    delete from pcipful_pci_pricing_formula_ul where dbd_id = vc_dbd_id;
    delete from pciul_phy_contract_item_ul where dbd_id = vc_dbd_id;
    delete from pcjvul_pc_jv_detail_ul where dbd_id = vc_dbd_id;
    delete from pcmul_phy_contract_main_ul where dbd_id = vc_dbd_id;
    delete from pcpdqdul_pd_quality_dtl_ul where dbd_id = vc_dbd_id;
    commit;
    delete from pcpdul_pc_product_defintn_ul where dbd_id = vc_dbd_id;
    delete from pcpqul_pc_product_quality_ul where dbd_id = vc_dbd_id;
    delete from pcqpdul_pc_qual_prm_discnt_ul where dbd_id = vc_dbd_id;
    delete from pffxdul_phy_formula_fx_dtl_ul where dbd_id = vc_dbd_id;
    commit;
    delete from pfqppul_phy_formula_qp_prc_ul where dbd_id = vc_dbd_id;
    delete from ppfdul_phy_price_frmula_dtl_ul where dbd_id = vc_dbd_id;
    delete from ppfhul_phy_price_frmla_hdr_ul where dbd_id = vc_dbd_id;
    commit;
    delete from ciqsl_contract_itm_qty_sts_log where dbd_id = vc_dbd_id;
    delete from diqsl_delivery_itm_qty_sts_log where dbd_id = vc_dbd_id;
    delete from cqsl_contract_qty_status_log where dbd_id = vc_dbd_id;
    commit;
    delete from grdl_goods_record_detail_log where dbd_id = vc_dbd_id;
    delete from vdul_voyage_detail_ul where dbd_id = vc_dbd_id;
    delete from pcpchul_payble_contnt_headr_ul where dbd_id = vc_dbd_id;
    commit;
    delete from pqdul_payable_quality_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcepcul_elem_payble_content_ul where dbd_id = vc_dbd_id;
    delete from pcthul_treatment_header_ul where dbd_id = vc_dbd_id;
    commit;
    delete from tedul_treatment_element_dtl_ul where dbd_id = vc_dbd_id;
    delete from tqdul_treatment_quality_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcetcul_elem_treatmnt_chrg_ul where dbd_id = vc_dbd_id;
    commit;
    delete from pcarul_assaying_rules_ul where dbd_id = vc_dbd_id;
    delete from pcaeslul_assay_elm_splt_lmt_ul where dbd_id = vc_dbd_id;
    delete from pcaeslul_assay_elm_splt_lmt_ul where dbd_id = vc_dbd_id;
    commit;
    delete from arqdul_assay_quality_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcaphul_attr_penalty_header_ul where dbd_id = vc_dbd_id;
    delete from pcapul_attribute_penalty_ul where dbd_id = vc_dbd_id;
    commit;
    delete from pqdul_penalty_quality_dtl_ul where dbd_id = vc_dbd_id;
    delete from padul_penalty_attribute_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcrhul_refining_header_ul where dbd_id = vc_dbd_id;
    commit;
    delete from rqdul_refining_quality_dtl_ul where dbd_id = vc_dbd_id;
    delete from redul_refining_element_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcercul_elem_refing_charge_ul where dbd_id = vc_dbd_id;
    commit;
    delete from dithul_di_treatment_header_ul where dbd_id = vc_dbd_id;
    delete from dirhul_di_refining_header_ul where dbd_id = vc_dbd_id;
    delete from diphul_di_penalty_header_ul where dbd_id = vc_dbd_id;
    commit;
    delete from cipql_ctrt_itm_payable_qty_log where dbd_id = vc_dbd_id;
    delete from dipql_del_itm_payble_qty_log where dbd_id = vc_dbd_id;
    commit;
    delete from spql_stock_payable_qty_log where dbd_id = vc_dbd_id;
    delete from dipchul_di_payblecon_header_ul where dbd_id = vc_dbd_id;
    delete from agd_alloc_group_detail where dbd_id = vc_dbd_id;
    delete from agh_alloc_group_header where dbd_id = vc_dbd_id;
    commit;
    delete from cigc_contract_item_gmr_cost where dbd_id = vc_dbd_id;
    delete from cs_cost_store where dbd_id = vc_dbd_id;
    delete from ecs_element_cost_store where dbd_id = vc_dbd_id;
    delete from dgrd_delivered_grd where dbd_id = vc_dbd_id;
    commit;
    delete from gmr_goods_movement_record where dbd_id = vc_dbd_id;
    delete from mogrd_moved_out_grd where dbd_id = vc_dbd_id;
    commit;
    delete from pcad_pc_agency_detail where dbd_id = vc_dbd_id;
    commit;
    delete from pcbpd_pc_base_price_detail where dbd_id = vc_dbd_id;
    delete from pcbph_pc_base_price_header where dbd_id = vc_dbd_id;
    delete from pcdb_pc_delivery_basis where dbd_id = vc_dbd_id;
    commit;
    delete from pcdd_document_details where dbd_id = vc_dbd_id;
    delete from pcdiob_di_optional_basis where dbd_id = vc_dbd_id;
    delete from pcdipe_di_pricing_elements where dbd_id = vc_dbd_id;
    delete from pcdiqd_di_quality_details where dbd_id = vc_dbd_id;
    commit;
    delete from pcdi_pc_delivery_item where dbd_id = vc_dbd_id;
    delete from pcipf_pci_pricing_formula where dbd_id = vc_dbd_id;
    delete from pci_physical_contract_item where dbd_id = vc_dbd_id;
    delete from pcjv_pc_jv_detail where dbd_id = vc_dbd_id;
    delete from pcm_physical_contract_main where dbd_id = vc_dbd_id;
    delete from pcpdqd_pd_quality_details where dbd_id = vc_dbd_id;
    delete from pcpd_pc_product_definition where dbd_id = vc_dbd_id;
    delete from pcpq_pc_product_quality where dbd_id = vc_dbd_id;
    commit;
    delete from pcqpd_pc_qual_premium_discount where dbd_id = vc_dbd_id;
    delete from pffxd_phy_formula_fx_details where dbd_id = vc_dbd_id;
    delete from pfqpp_phy_formula_qp_pricing where dbd_id = vc_dbd_id;
    delete from ppfd_phy_price_formula_details where dbd_id = vc_dbd_id;
    delete from ppfh_phy_price_formula_header where dbd_id = vc_dbd_id;
    commit;
    delete from ciqs_contract_item_qty_status where dbd_id = vc_dbd_id;
    delete from diqs_delivery_item_qty_status where dbd_id = vc_dbd_id;
    commit;
    delete from cqs_contract_qty_status where dbd_id = vc_dbd_id;
    delete from grd_goods_record_detail where dbd_id = vc_dbd_id;
    delete from vd_voyage_detail where dbd_id = vc_dbd_id;
    commit;
    delete from invd_inventory_detail where dbd_id = vc_dbd_id;
    delete from invm_inventory_master where dbd_id = vc_dbd_id;
    delete from cipd_contract_item_price_daily
     where process_id = pc_process_id;
    delete from poud_phy_open_unreal_daily
     where process_id = pc_process_id;
    commit;
    delete from psu_phy_stock_unrealized where process_id = pc_process_id;
    delete from md_m2m_daily where process_id = pc_process_id;
    delete from tgsc_temp_gmr_sec_cost where process_id = pc_process_id;
    delete from gscs_gmr_sec_cost_summary where process_id = pc_process_id;
    delete from cisc_contract_item_sec_cost
     where process_id = pc_process_id;
    commit;
    delete from gpd_gmr_price_daily where process_id = pc_process_id;
    delete from pcpch_pc_payble_content_header where dbd_id = vc_dbd_id;
    delete from pqd_payable_quality_details where dbd_id = vc_dbd_id;
    delete from pcepc_pc_elem_payable_content where dbd_id = vc_dbd_id;
    delete from pcth_pc_treatment_header where process_id = pc_process_id;
    delete from ted_treatment_element_details
     where process_id = pc_process_id;
    delete from tqd_treatment_quality_details
     where process_id = pc_process_id;
    delete from pcetc_pc_elem_treatment_charge
     where process_id = pc_process_id;
    delete from pcar_pc_assaying_rules where dbd_id = vc_dbd_id;
    delete from pcaesl_assay_elem_split_limits where dbd_id = vc_dbd_id;
    delete from arqd_assay_quality_details where dbd_id = vc_dbd_id;
    delete from pcaph_pc_attr_penalty_header
     where process_id = pc_process_id;
    delete from pcap_pc_attribute_penalty where process_id = pc_process_id;
    delete from pqd_penalty_quality_details
     where process_id = pc_process_id;
    delete from pad_penalty_attribute_details
     where process_id = pc_process_id;
    delete from pcrh_pc_refining_header where process_id = pc_process_id;
    delete from rqd_refining_quality_details
     where process_id = pc_process_id;
    delete from red_refining_element_details
     where process_id = pc_process_id;
    delete from pcerc_pc_elem_refining_charge
     where process_id = pc_process_id;
    delete from ceqs_contract_ele_qty_status where dbd_id = vc_dbd_id;
    delete from cipde_cipd_element_price where process_id = pc_process_id;
    delete from poue_phy_open_unreal_element
     where process_id = pc_process_id;
    delete from poued_element_details where process_id = pc_process_id;
    delete from gpd_gmr_conc_price_daily where process_id = pc_process_id;
    delete from psue_element_details where process_id = pc_process_id;
    delete from psue_phy_stock_unrealized_ele
     where process_id = pc_process_id;
    delete from dith_di_treatment_header where dbd_id = vc_dbd_id;
    delete from dirh_di_refining_header where dbd_id = vc_dbd_id;
    delete from diph_di_penalty_header where dbd_id = vc_dbd_id;
    commit;
    delete from cipq_contract_item_payable_qty where dbd_id = vc_dbd_id;
    delete from dipq_delivery_item_payable_qty where dbd_id = vc_dbd_id;
    delete from spq_stock_payable_qty where dbd_id = vc_dbd_id;
    delete from dipch_di_payablecontent_header where dbd_id = vc_dbd_id;
    delete from rgmr_realized_gmr where process_id = pc_process_id;
    commit;
    delete from rgmrd_realized_gmr_detail where process_id = pc_process_id;
    delete from prd_physical_realized_daily
     where process_id = pc_process_id;
    delete from spd_stock_price_daily where process_id = pc_process_id;
    delete from is_invoice_summary where dbd_id = vc_dbd_id;
    commit;
    update is_invoice_summary iss
       set iss.process_id = null
     where iss.process_id = pc_process_id;
    commit;
    delete from cdl_cost_delta_log where dbd_id = vc_dbd_id;
    delete from invs_inventory_sales where process_id = pc_process_id;
    delete from tinvp_temp_invm_cog where process_id = pc_process_id;
    delete from tinvs_temp_invm_cogs where process_id = pc_process_id;
    commit;
    delete from invm_cog where process_id = pc_process_id;
    delete from invm_cogs where process_id = pc_process_id;
    delete from invme_cog_element where process_id = pc_process_id;
    delete from invme_cogs_element where process_id = pc_process_id;
    commit;
    delete from pa_purchase_accural where process_id = pc_process_id;
    delete from pa_purchase_accural_gmr where process_id = pc_process_id;
    delete from isr_intrastat_grd where process_id = pc_process_id;
    delete from isr1_isr_inventory where process_id = pc_process_id;
    delete from isr2_isr_invoice where process_id = pc_process_id;
    delete from pcs_purchase_contract_status
     where process_id = pc_process_id;
    delete from css_contract_status_summary
    where process_id = pc_process_id;
    delete from csfm_cont_status_free_metal
    where process_id = pc_process_id;
    commit;
    delete from fcr_feed_consumption_report
     where process_id = pc_process_id;
    delete from stock_monthly_yeild_data where process_id = pc_process_id;
    delete from upad_unreal_pnl_attr_detail
     where process_id = pc_process_id;
    delete from cccp_conc_contract_cog_price
     where process_id = pc_process_id;
    commit;
    delete from cgcp_conc_gmr_cog_price where process_id = pc_process_id;
    delete from bccp_base_contract_cog_price
     where process_id = pc_process_id;
    delete from bgcp_base_gmr_cog_price where process_id = pc_process_id;
    delete from mas_metal_account_summary where process_id = pc_process_id;
    delete from md_metal_debt where process_id = pc_process_id;
    delete from dpr_daily_position_record where process_id = pc_process_id;
    delete from prch_phy_realized_conc_header
     where process_id = pc_process_id;
    commit;
    delete from prce_phy_realized_conc_element
     where process_id = pc_process_id;
    delete from rgmrc_realized_gmr_conc where process_id = pc_process_id;
    delete from trgmrc_temp_rgmr_conc where corporate_id = pc_corporate_id;
    delete from ar_arrival_report where process_id = pc_process_id;
    delete from are_arrival_report_element
     where process_id = pc_process_id;
    delete from aro_ar_original where process_id = pc_process_id;
    delete from areo_ar_element_original where process_id = pc_process_id;
    delete from fc_feed_consumption where process_id = pc_process_id;
    delete from fce_feed_consumption_element
     where process_id = pc_process_id;
    delete from cbr_closing_balance_report
     where process_id = pc_process_id;
    delete from cbre_closing_bal_report_ele
     where process_id = pc_process_id;
    delete from ord_overall_realized_pnl_daily
     where process_id = pc_process_id;
    delete from tpd_trade_pnl_daily where process_id = pc_process_id;
    delete from gepd_gmr_element_pledge_detail where dbd_id = vc_dbd_id;
    delete from eod_eom_fixation_journal where process_id = pc_process_id;
    delete from pofh_history where process_id = pc_process_id;
    delete from eod_eom_derivative_journal
     where process_id = pc_process_id;
    delete from eod_eom_booking_journal where process_id = pc_process_id;
    delete from eod_eom_phy_contract_journal
     where process_id = pc_process_id;
    delete from prp_physical_risk_position
     where process_id = pc_process_id;
    commit;
    delete from eod_eom_phy_booking_journal
     where process_id = pc_process_id;
    delete from getc_gmr_element_tc_charges
     where process_id = pc_process_id;
    commit;
    delete from gerc_gmr_element_rc_charges
     where process_id = pc_process_id;
    delete from gepc_gmr_element_pc_charges
     where process_id = pc_process_id;
    commit;
    delete from cmp_contract_market_price where process_id = pc_process_id;
    delete from gmp_gmr_market_price where process_id = pc_process_id;
    delete from bdp_bi_dertivative_pnl where process_id = pc_process_id;    
    commit;
    delete from page_price_alloc_gmr_exchange
     where process_id = pc_process_id;
    delete from tpr_traders_position_report
     where process_id = pc_process_id;
    commit;
    delete from ped_penalty_element_details
     where process_id = pc_process_id;
    delete from ped_penalty_element_details
     where process_id = pc_process_id;
    delete from ciscs_cisc_summary where process_id = pc_process_id;
    delete from gpq_gmr_payable_qty where process_id = pc_process_id;
    commit;
    delete from fco_feed_consumption_original fco
     where process_id = pc_process_id;
    delete from fceo_feed_con_element_original fceo
     where process_id = pc_process_id;
    commit;
    delete from fcg_feed_consumption_gmr fcg
     where fcg.process_id = pc_process_id;
    delete from arg_arrival_report_gmr arg
     where arg.process_id = pc_process_id;
    --
    -- If below tables Process ID might have marked for previoud DBD IDs
    -- Since they were not eleigible for previous EODS, we have unmark the Procee ID now
    --
    update grdl_goods_record_detail_log t
       set t.process_id = null
     where t.process_id = pc_process_id;
    update dgrdul_delivered_grd_ul t
       set t.process_id = null
     where t.process_id = pc_process_id;
    update cdl_cost_delta_log t
       set t.process_id = null
     where t.process_id = pc_process_id;
      update spql_stock_payable_qty_log t
       set t.process_id = null
     where t.process_id = pc_process_id;
    commit;
    vn_logno := vn_logno + 1;
    -- Washout rollback
    delete from sswh_spe_settle_washout_header where dbd_id = vc_dbd_id;
    delete from sswd_spe_settle_washout_detail where dbd_id = vc_dbd_id;
    commit;
    update sswh_spe_settle_washout_header
       set process_id = null
     where process_id = pc_process_id;
    update sswh_spe_settle_washout_header
       set cancelled_process_id = null
     where cancelled_process_id = pc_process_id;
    update sswd_spe_settle_washout_detail
       set process_id = null
     where process_id = pc_process_id;
    delete from pca_physical_contract_action where dbd_id = vc_dbd_id;
    delete from cod_call_off_details where dbd_id = vc_dbd_id;
    delete from gth_gmr_treatment_header where process_id = pc_process_id;
    delete from grh_gmr_refining_header where process_id = pc_process_id;
    delete from gph_gmr_penalty_header where process_id = pc_process_id;
    commit;
    --- added suresh for MBV Report
    delete from mbv_allocation_report where process_id = pc_process_id;
    delete from mbv_allocation_report_header
     where process_id = pc_process_id;
    delete from mbv_di_valuation_price where process_id = pc_process_id;
    delete from mbv_phy_postion_diff_report
     where process_id = pc_process_id;
    delete from mbv_derivative_diff_report
     where process_id = pc_process_id;
    delete from mbv_metal_balance_valuation
     where process_id = pc_process_id;
    delete from pfrh_price_fix_report_header
     where process_id = pc_process_id;
    delete from pfrd_price_fix_report_detail
     where process_id = pc_process_id;
    delete from css_contract_status_summary
     where process_id = pc_process_id;
    delete from csfm_cont_status_free_metal
     where process_id = pc_process_id;
    delete from pfrhe_pfrh_extension where process_id = pc_process_id;
    delete from fxar_fx_allocation_report where process_id = pc_process_id;
    commit;
    delete iids_iid_summary where process_id = pc_process_id;
    delete iocd_ioc_details where process_id = pc_process_id;
    delete tgc_temp_gmr_charges where process_id = pc_process_id;
    delete aro_ar_original_report where process_id = pc_process_id;
    delete areor_ar_ele_original_report where process_id = pc_process_id;
    delete for_feed_original_report where process_id = pc_process_id;
    delete feor_feed_ele_original_report where process_id = pc_process_id;
    delete from gds_gmr_delta_status where process_id = pc_process_id;
    delete from grhul_gmr_refining_header_ul where dbd_id = vc_dbd_id;
    delete from gthul_gmr_treatment_header_ul where dbd_id = vc_dbd_id;
    delete from gphul_gmr_penalty_header_ul where dbd_id = vc_dbd_id;
    commit;
    --end Suresh 
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          vn_logno,
                          'Rollback End');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_process_rollback',
                                                           'M2M-013',
                                                           ' Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           null, --pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_phy_rebuild_stats is
  begin
    sp_gather_stats('cipd_contract_item_price_daily');
    sp_gather_stats('cisc_contract_item_sec_cost');
    sp_gather_stats('gscs_gmr_sec_cost_summary');
    sp_gather_stats('tmpc_temp_m2m_pre_check');
    sp_gather_stats('md_m2m_daily');
    sp_gather_stats('dpp_daily_physical_position');
    sp_gather_stats('poud_phy_open_unreal_daily');
    sp_gather_stats('psu_phy_stock_unrealized');
    sp_gather_stats('psci_phy_stock_contract_item');
    sp_gather_stats('psg_phy_stock_gmr');
    sp_gather_stats('tpd_trade_pnl_daily');
    sp_gather_stats('prd_physical_realized_daily');
    sp_gather_stats('ord_overall_realized_pnl_daily');
    sp_gather_stats('cps_cost_pnl_summary');
    sp_gather_stats('pnlc_pnl_change');
    sp_gather_stats('ccd_carrying_cost_daily');
    sp_gather_stats('rgmrd_realized_gmr_detail');
    sp_gather_stats('mes_month_end_stock');
    sp_gather_stats('pps_physical_pnl_summary');
    sp_gather_stats('rgmr_realized_gmr');
  end;

end pkg_phy_physical_process; 
/
