create or replace package pkg_cdc_derivatives_process is

  procedure sp_process_run(pc_corporate_id varchar2,
                           pd_trade_date   date,
                           pc_process_id   varchar2,
                           pc_user_id      varchar2,
                           pc_process      varchar2,
                           pc_dbd_id       varchar2);

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

  procedure sp_cdc_rebuild_stats;

  procedure sp_calc_future_unrealized_pnl(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2,
                                          pc_process      varchar2,
                                          pc_dbd_id       varchar2);

  procedure sp_calc_future_realized_pnl(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_process      varchar2,
                                        pc_dbd_id       varchar2);

  procedure sp_calc_forward_unrealized_pnl(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_user_id      varchar2,
                                           pc_process      varchar2,
                                           pc_dbd_id       varchar2);

  procedure sp_calc_forward_realized_pnl(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2,
                                         pc_dbd_id       varchar2);

  procedure sp_calc_option_unrealized_pnl(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2,
                                          pc_process      varchar2);
  procedure sp_calc_swap_unrealized_pnl(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_process      varchar2,
                                        pc_dbd_id       varchar2);

  procedure sp_calc_option_realized_pnl(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_process      varchar2,
                                        pc_dbd_id       varchar2);

  function f_get_is_derived_qty_unit(pc_qty_unit_id in varchar2)
    return varchar2;

  function f_get_converted_quantity(pc_product_id          in varchar2,
                                    pc_from_qty_unit_id    in varchar2,
                                    pc_to_qty_unit_id      in varchar2,
                                    pn_qty_to_be_converted in number)
    return number;

  function f_get_converted_currency_amt(pc_corporate_id        in varchar2,
                                        pc_from_cur_id         in varchar2,
                                        pc_to_cur_id           in varchar2,
                                        pd_cur_date            in date,
                                        pn_amt_to_be_converted in number)
    return number;

  function f_currency_exchange_rate(pd_trade_date   date,
                                    pc_corporate_id varchar2,
                                    pd_prompt_date  varchar2,
                                    pc_from_cur_id  varchar2,
                                    pc_to_cur_id    varchar2) return number;

  function f_get_converted_price_pum(pc_corporate_id       varchar2,
                                     pn_price              number,
                                     pc_from_price_unit_id varchar2,
                                     pc_to_price_unit_id   varchar2,
                                     pd_trade_date         date,
                                     pc_product_id         varchar2)
    return number;

  function f_get_next_day(p_date     in date,
                          p_day      in varchar2,
                          p_position in number) return date;

  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean;

  procedure sp_calc_daily_initial_margin(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2);

  /*   PROCEDURE sp_calc_future_accounts(
  pc_corporate_id VARCHAR2,
  pd_trade_date   DATE,
  pc_process_id   VARCHAR2,
  pc_user_id      VARCHAR2,
  pc_process      VARCHAR2);*/

  procedure sp_mark_realized_derivatives(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2);

  procedure sp_mark_new_derivative_trades(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2,
                                          pc_process      varchar2);

  procedure sp_calc_undo_closeout(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process_id   varchar2,
                                  pc_user_id      varchar2,
                                  pc_process      varchar2);

  procedure sp_calc_undo_settled(pc_corporate_id varchar2,
                                 pd_trade_date   date,
                                 pc_process_id   varchar2,
                                 pc_user_id      varchar2,
                                 pc_process      varchar2);

  procedure sp_calc_clearer_summary(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_process_id   varchar2,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2);

  procedure recordfxpnl(p_corporateid varchar2,
                        p_tradedate   date,
                        p_process_id  varchar2,
                        p_userid      varchar2,
                        p_prcoess     varchar2);

  procedure sp_calc_price_exposure(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_process      varchar2,
                                   pc_user_id      varchar2);
  procedure sp_calc_average_unrealized_pnl(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_process      varchar2,
                                           pc_user_id      varchar2,
                                           pc_dbd_id       varchar2);

end; 
/
create or replace package body pkg_cdc_derivatives_process is

  procedure sp_process_run(pc_corporate_id varchar2,
                           pd_trade_date   date,
                           pc_process_id   varchar2,
                           pc_user_id      varchar2,
                           pc_process      varchar2,
                           pc_dbd_id       varchar2 --eod or eom
                           ----------------------------------------------------------------------
                           --        procedure name                            : sp_process_run
                           --        author                                    :
                           --        created date                              : 10 th jan 2011
                           --        purpose                                   : calls all procedures for eod
                           --        parameters
                           --        pc_corporate_id                           : corporate id
                           --        pd_trade_date                             : trade date
                           --        pc_process_id                             : eod/eom reference no
                           --        modification history
                           --        modified date                             :
                           --        modified by                               :
                           --        modify description                        :
                           --------------------------------------------------------------------------------------------------------------------------
                           ) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_logno           number := 0;
    --vn_err             varchar2(50);
  begin
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'EOD/EOM process Started ....');
  
    -- mark eod
    /*IF pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' THEN
      GOTO cancel_process;
    END IF;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_mark_process_id');
    sp_mark_process_id(pc_corporate_id,
                       pc_process_id,
                       pc_user_id,
                       pd_trade_date,
                       pc_process,
                       pc_dbd_id       );*/
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_cdc_rebuild_stats');
  
    sp_cdc_rebuild_stats;
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_future_unrealized_pnl');
  
    sp_calc_future_unrealized_pnl(pc_corporate_id,
                                  pd_trade_date,
                                  pc_process_id,
                                  pc_user_id,
                                  pc_process,
                                  pc_dbd_id);
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_mark_realized_derivatives');
  
    sp_mark_realized_derivatives(pc_corporate_id,
                                 pd_trade_date,
                                 pc_process_id,
                                 pc_user_id,
                                 pc_process);
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_future_realized_pnl');
  
    sp_calc_future_realized_pnl(pc_corporate_id,
                                pd_trade_date,
                                pc_process_id,
                                pc_user_id,
                                pc_process,
                                pc_dbd_id);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_forward_unrealized_pnl');
  
    sp_calc_forward_unrealized_pnl(pc_corporate_id,
                                   pd_trade_date,
                                   pc_process_id,
                                   pc_user_id,
                                   pc_process,
                                   pc_dbd_id);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_forward_realized_pnl');
  
    sp_calc_forward_realized_pnl(pc_corporate_id,
                                 pd_trade_date,
                                 pc_process_id,
                                 pc_user_id,
                                 pc_process,
                                 pc_dbd_id);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
  
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_swap_unrealized_pnl');
  
    sp_calc_swap_unrealized_pnl(pc_corporate_id,
                                pd_trade_date,
                                pc_process_id,
                                pc_user_id,
                                pc_process,
                                pc_dbd_id);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_option_unrealized_pnl');
  
    sp_calc_option_unrealized_pnl(pc_corporate_id,
                                  pd_trade_date,
                                  pc_process_id,
                                  pc_user_id,
                                  pc_process);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_option_realized_pnl');
  
    sp_calc_option_realized_pnl(pc_corporate_id,
                                pd_trade_date,
                                pc_process_id,
                                pc_user_id,
                                pc_process,
                                pc_dbd_id);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_daily_initial_margin');
  
    sp_calc_daily_initial_margin(pc_corporate_id,
                                 pd_trade_date,
                                 pc_process_id,
                                 pc_user_id,
                                 pc_process);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_mark_new_derivative_trades');
  
    sp_mark_new_derivative_trades(pc_corporate_id,
                                  pd_trade_date,
                                  pc_process_id,
                                  pc_user_id,
                                  pc_process);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_undo_closeout');
  
    sp_calc_undo_closeout(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          pc_user_id,
                          pc_process);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_undo_settled');
  
    sp_calc_undo_settled(pc_corporate_id,
                         pd_trade_date,
                         pc_process_id,
                         pc_user_id,
                         pc_process);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_clearer_summary');
  
    sp_calc_clearer_summary(pc_corporate_id,
                            pd_trade_date,
                            pc_process_id,
                            pc_user_id,
                            pc_process);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'recordfxpnl');
  
    recordfxpnl(pc_corporate_id,
                pd_trade_date,
                pc_process_id,
                pc_user_id,
                pc_process);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_price_exposure');
    sp_calc_price_exposure(pc_corporate_id,
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
                          'sp_calc_average_unrealized_pnl');
    sp_calc_average_unrealized_pnl(pc_corporate_id,
                                   pd_trade_date,
                                   pc_process_id,
                                   pc_process,
                                   pc_user_id,
                                   pc_dbd_id);
  
    <<cancel_process>>
    dbms_output.put_line('EOD/EOM Process Cancelled while pnl calculation');
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
  
    update dat_derivative_aggregate_trade agd
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = pc_dbd_id;
  
    update crtd_cur_trade_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = pc_dbd_id;
  
    update dam_derivative_action_amapping
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = pc_dbd_id;
  
    update dt_derivative_trade
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = pc_dbd_id;
  
    /*update dcoh_der_closeout_header
    set process_id=pc_process_id
     WHERE process_id IS NULL
       AND dbd_id = pc_dbd_id;
    
    update dcod_der_closeout_detail
    set process_id=pc_process_id
     WHERE process_id IS NULL
       AND dbd_id = pc_dbd_id;*/
  
    update dcoh_der_closeout_header
       set process_id = pc_process_id
     where process_id is null
       and corporate_id = pc_corporate_id
       and close_out_date <= pd_trade_date
       and dbd_id in (select dbd.dbd_id
                        from dbd_database_dump dbd
                       where dbd.corporate_id = pc_corporate_id
                         and dbd.process = pc_process
                         and dbd.trade_date <= pd_trade_date);
    update dcod_der_closeout_detail dcod
       set process_id = pc_process_id
     where dcod.internal_close_out_ref_no in
           (select internal_close_out_ref_no
              from dcoh_der_closeout_header
             where process_id = pc_process_id)
       and dcod.dbd_id in
           (select dbd.dbd_id
              from dbd_database_dump dbd
             where dbd.corporate_id = pc_corporate_id
               and dbd.process = pc_process
               and dbd.trade_date <= pd_trade_date);
  
    update ct_currency_trade
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = pc_dbd_id;
  
    update dt_fbi
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = pc_dbd_id;
  
    update fsh_fin_settlement_header
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = pc_dbd_id;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_mark_process_id',
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
    -- vc_process_id      VARCHAR2(15);
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    delete from dtul_derivative_trade_ul where dbd_id = pc_dbd_id;
    delete from crtdul_cur_trade_details_ul where dbd_id = pc_dbd_id;
    delete from ctul_currency_trade_ul where dbd_id = pc_dbd_id;
    --delete from eodeom_derivative_quote_detail where dbd_id = pc_dbd_id;
    delete from dt_derivative_trade where dbd_id = pc_dbd_id;
    delete from dt_fbi where dbd_id = pc_dbd_id;
    delete from crtd_cur_trade_details where dbd_id = pc_dbd_id;
    delete from ct_currency_trade where dbd_id = pc_dbd_id;
    delete from dpd_derivative_pnl_daily where process_id = pc_process_id;
    delete from dim_daily_initial_margin where process_id = pc_process_id;
    delete from dat_derivative_aggregate_trade where dbd_id = pc_dbd_id;
    delete from dam_derivative_action_amapping where dbd_id = pc_dbd_id;
    delete from cpd_currency_pnl_daily where process_id = pc_process_id;
    --DELETE FROM ct_currency_trade WHERE dbd_id = pc_dbd_id;
    delete from dcoh_der_closeout_header where dbd_id = pc_dbd_id;
    delete from dcod_der_closeout_detail where dbd_id = pc_dbd_id;
    delete from fsh_fin_settlement_header where dbd_id = pc_dbd_id;
    delete from spc_summary_position_clearer
     where process_id = pc_process_id;
    update dcoh_der_closeout_header dcoh --10-jan-2011
       set dcoh.is_rolled_back       = 'N',
           dcoh.roll_back_date       = null,
           dcoh.undo_closeout_dbd_id = null
     where dcoh.undo_closeout_dbd_id = pc_dbd_id;
  
    update dcoh_der_closeout_header
       set process_id = null
     where process_id = pc_process_id;
  
    update dcod_der_closeout_detail
       set process_id = null
     where process_id = pc_process_id;
    delete from dped_drt_price_exp_details
     where process_id = pc_process_id;
    delete from dpe_derivative_price_exposure
     where process_id = pc_process_id;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_process_rollback',
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

  procedure sp_cdc_rebuild_stats is
  begin
    sp_gather_stats('dpd_derivative_pnl_daily');
    sp_gather_stats('dim_daily_initial_margin');
    sp_gather_stats('dps_derivative_pnl_summary');
  end;

  procedure sp_calc_future_unrealized_pnl(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2,
                                          pc_process      varchar2,
                                          pc_dbd_id       varchar2) is
    /******************************************************************************************************************************************
    procedure name                            : sp_calc_future_unrealized_pnl
    author                                    : janna
    created date                              : 10th jan 2009
    purpose                                   : calculate the unrealized pnl for futures as on eod date
    parameters                                :
    pc_corporate_id                           : corporate id
    pd_trade_date                             : eod date id
    pc_eod_ref_no                             : eod reference no
    modification history                      :
    modified date                             :
    modified by                               :
    modify description                        :
    ******************************************************************************************************************************************/
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
    cursor cur_futures is
      select dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             pd_trade_date eod_trade_date,
             dt.trade_date,
             dt.corporate_id,
             ak.corporate_name,
             dt.trader_id,
             gab.firstname || gab.lastname tradername,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dt.dr_id,
             drm.instrument_id,
             dim.instrument_name,
             dim.instrument_symbol,
             dim.instrument_type_id,
             irm.instrument_type,
             irm.instrument_display_name,
             dim.instrument_sub_type_id,
             istm.instrument_sub_type,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             pdd.traded_on,
             pdd.product_id,
             pdm.product_desc,
             emt.exchange_id,
             emt.exchange_name,
             emt.exchange_code,
             pdd.lot_size,
             pdd.lot_size_unit_id,
             qum.qty_unit lot_size_qty_unit,
             drm.price_point_id,
             pp.price_point_name,
             drm.period_type_id,
             pm.period_type_name,
             pm.period_type_display_name,
             drm.period_month,
             drm.period_year,
             (case
               when drm.period_date is null then
                case
               when drm.period_month is not null and
                    drm.period_year is not null then
                to_date('01-' || drm.period_month || '-' || drm.period_year,
                        'dd-Mon-yyyy')
               else
                drm.prompt_date
             end else drm.period_date end) period_date,
             drm.prompt_date,
             drm.dr_id_name,
             dt.trade_type,
             dt.deal_type_id,
             dtm.deal_type_name,
             dtm.deal_type_display_name,
             dtm.is_multiple_leg_involved,
             null deal_category,
             null deal_sub_category,
             dt.strategy_id,
             css.strategy_name,
             css.description,
             sdm.strategy_def_name,
             ak.groupid,
             gcd.groupname,
             dt.purpose_id,
             dpm.purpose_name,
             dpm.purpose_display_name,
             dt.external_ref_no,
             dt.cp_profile_id,
             phd_cp.companyname cp_name,
             dt.master_contract_id,
             dt.broker_profile_id,
             phd_broker.companyname broker_name,
             dt.broker_account_id,
             bca_broker.account_name broker_account_name,
             bca_broker.account_type broker_account_type,
             dt.broker_comm_type_id,
             dt.broker_comm_amt,
             dt.broker_comm_cur_id,
             cm_broker_cur.cur_code broker_cur_code,
             dt.clearer_profile_id,
             phd_clearer.companyname clearer_name,
             dt.clearer_account_id,
             bca_clearer.account_name clearer_account_name,
             bca_clearer.account_type clearer_account_type,
             dt.clearer_comm_type_id,
             dt.clearer_comm_amt,
             dt.clearer_comm_cur_id,
             cm_clearer.cur_code clearer_cur_code,
             dt.product_id product,
             pdm.product_desc productdesc,
             dt.quality_id,
             qat.quality_name,
             qat.gravity,
             gtm.gravity_type_name gravity_type,
             qat.density_mass_qty_unit_id,
             qat.density_volume_qty_unit_id,
             dt.quantity_unit_id,
             qum_um.qty_unit quantityname,
             dt.total_lots,
             dt.total_quantity,
             dt.open_lots,
             dt.open_quantity,
             dt.exercised_lots,
             dt.exercised_quantity,
             dt.expired_lots,
             dt.expired_quantity,
             dt.trade_price_type_id,
             dt.trade_price,
             dt.trade_price_unit_id,
             pum_trade.cur_id trade_cur_id,
             cm_trade.cur_code trade_cur_code,
             pum_trade.weight trade_weight,
             pum_trade.weight_unit_id trade_weight_unit_id,
             qum_trade.qty_unit trade_qty_unit,
             dt.formula_id,
             fbs.formula_name,
             fbs.formula_display,
             dt.index_instrument_id,
             dim_index.instrument_name index_instrument_name,
             dt.strike_price,
             dt.strike_price_unit_id,
             pum_strike.cur_id strike_cur_id,
             cm_strike.cur_code strike_cur_code,
             pum_strike.weight strike_weight,
             pum_strike.weight_unit_id strike_weight_unit_id,
             qum_strike.qty_unit strike_qty_unit,
             dt.premium_discount,
             dt.premium_discount_price_unit_id,
             pum_pd.cur_id pd_cur_id,
             cm_pd.cur_code pd_cur_code,
             pum_pd.weight pd_weight,
             pum_pd.weight_unit_id pd_weight_unit_id,
             qum_pd.qty_unit pd_qty_unit,
             dt.premium_due_date,
             dt.nominee_profile_id,
             phd_nominee.companyname nominee_name,
             dt.leg_no,
             dt.option_expiry_date,
             dt.parent_int_derivative_ref_no,
             dt.market_location_country,
             dt.market_location_state,
             dt.market_location_city,
             dt.is_what_if,
             dt.payment_term,
             pym.payment_term payment_term_name,
             dt.payment_due_date,
             dt.closed_lots,
             dt.closed_quantity,
             null as is_new_trade_date,
             dt.status,
             dt.settlement_cur_id,
             cm_settlement.cur_code settlement_cur_code,
             null as in_out_at_money_status,
             null as in_out_at_money_value,
             null as exercise_date,
             null as expiry_date,
             gcd_group.group_cur_id,
             cm_gcd.cur_code group_cur_code,
             gcd_group.group_qty_unit_id,
             qum_gcd.qty_unit gcd_qty_unit,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             null internal_close_out_ref_no,
             null close_out_ref_no,
             null close_out_date,
             edq.price settlement_price,
             edq.price_unit_id settlement_price_unit_id,
             pum_settle.cur_id settlement_price_cur_id,
             cm_settle.cur_code settlemet_price_cur_code,
             pum_settle.weight settlement_price_weight,
             pum_settle.weight_unit_id settlement_weight_unit_id,
             qum_settle.qty_unit settlement_weight_unit,
             (case
               when irm.instrument_type in ('Option Put', 'Option Call') then
                'Option'
               else
                irm.instrument_type
             end) as parent_instrument_type,
             null as clearer_comm_in_base,
             null as broker_comm_in_base,
             null as clearer_exch_rate,
             null as broker_exch_rate,
             null as trade_cur_to_base_exch_rate,
             'Unrealized' as pnl_type,
             null as pnl_in_base_cur,
             null as pnl_in_trade_cur,
             cm_base.cur_id as base_cur_id,
             ak.base_currency_name base_cur_code,
             null as underlying_future_dr_id,
             null as underlying_future_dr_id_name,
             null as underlying_future_expiry_date,
             null as underlying_future_quote_price,
             null as underlying_fut_price_unit_id,
             pc_process_id process_id
      
        from dt_derivative_trade            dt,
             ak_corporate                   ak,
             ak_corporate_user              aku,
             gab_globaladdressbook          gab,
             cpc_corporate_profit_center    cpc,
             drm_derivative_master          drm,
             dim_der_instrument_master      dim,
             irm_instrument_type_master     irm,
             istm_instr_sub_type_master     istm,
             pdd_product_derivative_def     pdd,
             pdm_productmaster              pdm,
             emt_exchangemaster             emt,
             qum_quantity_unit_master       qum,
             pp_price_point                 pp,
             pm_period_master               pm,
             dtm_deal_type_master           dtm,
             css_corporate_strategy_setup   css,
             sdm_strategy_definition_master sdm,
             gcd_groupcorporatedetails      gcd,
             dpm_derivative_purpose_master  dpm,
             phd_profileheaderdetails       phd_cp,
             phd_profileheaderdetails       phd_broker,
             bca_broker_clearer_account     bca_broker,
             cm_currency_master             cm_broker_cur,
             phd_profileheaderdetails       phd_clearer,
             bca_broker_clearer_account     bca_clearer,
             cm_currency_master             cm_clearer,
             qat_quality_attributes         qat,
             gtm_gravity_type_master        gtm,
             qum_quantity_unit_master       qum_um,
             pum_price_unit_master          pum_trade,
             cm_currency_master             cm_trade,
             qum_quantity_unit_master       qum_trade,
             fbs_formula_builder_setup      fbs,
             dim_der_instrument_master      dim_index,
             pum_price_unit_master          pum_strike,
             cm_currency_master             cm_strike,
             qum_quantity_unit_master       qum_strike,
             pum_price_unit_master          pum_pd,
             cm_currency_master             cm_pd,
             qum_quantity_unit_master       qum_pd,
             phd_profileheaderdetails       phd_nominee,
             pym_payment_terms_master       pym,
             cm_currency_master             cm_settlement,
             gcd_groupcorporatedetails      gcd_group,
             cm_currency_master             cm_gcd,
             qum_quantity_unit_master       qum_gcd,
             qum_quantity_unit_master       qum_pdm,
             eodeom_derivative_quote_detail edq,
             div_der_instrument_valuation   div,
             apm_available_price_master     apm,
             pum_price_unit_master          pum_settle,
             cm_currency_master             cm_settle,
             qum_quantity_unit_master       qum_settle,
             cm_currency_master             cm_base
      
       where dt.corporate_id = ak.corporate_id
         and dt.trader_id = aku.user_id
         and aku.gabid = gab.gabid
         and dt.profit_center_id = cpc.profit_center_id
         and dt.dr_id = drm.dr_id(+)
         and drm.instrument_id = dim.instrument_id(+)
         and dim.instrument_type_id = irm.instrument_type_id(+)
         and dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
         and dim.product_derivative_id = pdd.derivative_def_id(+)
         and pdd.product_id = pdm.product_id(+)
         and pdd.exchange_id = emt.exchange_id(+)
         and pdd.lot_size_unit_id = qum.qty_unit_id(+)
         and drm.price_point_id = pp.price_point_id(+)
         and drm.period_type_id = pm.period_type_id(+)
         and dt.deal_type_id = dtm.deal_type_id
         and dt.strategy_id = css.strategy_id
         and css.strategy_def_id = sdm.strategy_def_id
         and ak.groupid = gcd.groupid
         and dt.purpose_id = dpm.purpose_id
         and dt.cp_profile_id = phd_cp.profileid(+)
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.broker_account_id = bca_broker.account_id(+)
         and dt.broker_comm_cur_id = cm_broker_cur.cur_id(+)
         and dt.clearer_profile_id = phd_clearer.profileid(+)
         and dt.clearer_account_id = bca_clearer.account_id(+)
         and dt.clearer_comm_cur_id = cm_clearer.cur_id(+)
         and dt.quality_id = qat.quality_id(+)
         and qat.gravity_type_id = gtm.gravity_type_id(+)
         and dt.quantity_unit_id = qum_um.qty_unit_id
         and dt.trade_price_unit_id = pum_trade.price_unit_id(+)
         and pum_trade.cur_id = cm_trade.cur_id(+)
         and pum_trade.weight_unit_id = qum_trade.qty_unit_id(+)
         and dt.formula_id = fbs.formula_id(+)
         and dt.index_instrument_id = dim_index.instrument_id(+)
         and dt.strike_price_unit_id = pum_strike.price_unit_id(+)
         and pum_strike.cur_id = cm_strike.cur_id(+)
         and pum_strike.weight_unit_id = qum_strike.qty_unit_id(+)
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and pum_pd.cur_id = cm_pd.cur_id(+)
         and pum_pd.weight_unit_id = qum_pd.qty_unit_id(+)
         and dt.nominee_profile_id = phd_nominee.profileid(+)
         and dt.payment_term = pym.payment_term_id(+)
         and dt.settlement_cur_id = cm_settlement.cur_id(+)
         and ak.groupid=gcd_group.groupid
         and gcd_group.group_cur_id = cm_gcd.cur_id
         and gcd_group.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id(+)
         and dt.process_id = edq.process_id
         and dt.dr_id = edq.dr_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and edq.available_price_id = apm.available_price_id
         and edq.available_price_id = div.available_price_id
         and edq.price_unit_id = div.price_unit_id
            --         and apm.available_price_name = 'Settlement'
         and apm.is_active = 'Y'
         and apm.is_deleted = 'N'
         and edq.price_unit_id = pum_settle.price_unit_id(+)
         and pum_settle.cur_id = cm_settle.cur_id(+)
         and pum_settle.weight_unit_id = qum_settle.qty_unit_id(+)
         and ak.base_currency_name = cm_base.cur_code(+)
         and irm.instrument_type = 'Future'
         and upper(dt.status) = 'VERIFIED'
         and dtm.deal_type_display_name not like '%Swap%'
         and dt.is_what_if = 'N'
         and dt.corporate_id = pc_corporate_id
         and dt.open_quantity > 0
         and dt.trade_date <= pd_trade_date
         and dt.process_id = pc_process_id;
  
    vn_total_trade_value_base_cur  number;
    vn_pnl_value_in_trade_cur      number;
    vn_trade_to_base_exch_rate     number;
    vn_pnl_value_in_base_cur       number;
    vn_broker_comm_in_base_cur     number;
    vn_clr_comm_in_base_cur        number;
    vn_net_pnl_in_base_cur         number;
    vn_brokr_cur_to_base_exch_rate number;
    vn_clr_cur_to_base_exch_rate   number;
    vn_qty_in_trade_wt_unit        number;
    vn_market_price_in_trade_cur   number;
    vn_total_market_val_trade_cur  number;
    vn_trade_price_in_trade_cur    number;
    vn_total_trade_value_trade_cur number;
    vn_trade_qty_exch_unit         number;
  begin
  
    for cur_futures_rows in cur_futures
    loop
    
      -- Trade Qty in Exchange Weight Unit
      vn_trade_qty_exch_unit := pkg_general.f_get_converted_quantity(null,
                                                                     cur_futures_rows.quantity_unit_id,
                                                                     cur_futures_rows.lot_size_unit_id,
                                                                     cur_futures_rows.open_quantity);
    
      /*get the exchange rates
      1. from broker to base currency
      2. trade to base currency
      */
    
      vn_trade_to_base_exch_rate     := f_currency_exchange_rate(pd_trade_date,
                                                                 pc_corporate_id,
                                                                 cur_futures_rows.prompt_date,
                                                                 cur_futures_rows.trade_cur_id,
                                                                 cur_futures_rows.base_cur_id);
      vn_brokr_cur_to_base_exch_rate := f_currency_exchange_rate(pd_trade_date,
                                                                 pc_corporate_id,
                                                                 cur_futures_rows.prompt_date,
                                                                 cur_futures_rows.broker_comm_cur_id,
                                                                 cur_futures_rows.base_cur_id);
      vn_clr_cur_to_base_exch_rate   := f_currency_exchange_rate(pd_trade_date,
                                                                 pc_corporate_id,
                                                                 cur_futures_rows.prompt_date,
                                                                 cur_futures_rows.clearer_comm_cur_id,
                                                                 cur_futures_rows.base_cur_id);
    
      /*
      calcualate trade pnl in trade currency
      1. convert trade qty from trade price unit weight unit to trade weight unit
      2. get the market price in trade currency
      3. market value in trade currency = qty in trade weight unit(1) * market price in trade currency(2)
      4. trade value in trade currency = trade price in trade currency (from drt) * trade qty in trade unit(1)
      5. pnl in trade currency = market value in trade currency(2) - trade value in trade currency(4)*/
    
      /* commented code since from and to is reveresed 18-jul-2009
      vn_qty_in_trade_wt_unit      := f_get_converted_quantity(null, --product id
                                                                           cur_futures_rows.weight_unit_id,
                                                                           cur_futures_rows.trade_qty_unit_id,
                                                                           cur_futures_rows.trade_qty); */
    
      vn_qty_in_trade_wt_unit := f_get_converted_quantity(null, --product id
                                                          cur_futures_rows.quantity_unit_id,
                                                          cur_futures_rows.trade_weight_unit_id,
                                                          cur_futures_rows.open_quantity
                                                          -- this we added for drt changes. bhairu
                                                          --cur_futures_rows.trade_qty-nvl(cur_futures_rows.quantity_closed,0)
                                                          );
    
      --preeti fix for open lots
      --vn_market_price_in_trade_cur := cur_futures_rows.settlement_price;
      if cur_futures_rows.gravity is not null then
        vn_market_price_in_trade_cur := (cur_futures_rows.settlement_price /
                                        nvl(cur_futures_rows.settlement_price_weight,
                                             1)) *
                                        pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                 cur_futures_rows.settlement_price_cur_id,
                                                                                 cur_futures_rows.trade_cur_id,
                                                                                 pd_trade_date,
                                                                                 1) *
                                        (pkg_general.fn_mass_volume_qty_conversion(cur_futures_rows.product_id,
                                                                                   cur_futures_rows.settlement_weight_unit_id,
                                                                                   cur_futures_rows.trade_weight_unit_id,
                                                                                   1,
                                                                                   cur_futures_rows.gravity,
                                                                                   cur_futures_rows.gravity_type,
                                                                                   cur_futures_rows.density_mass_qty_unit_id,
                                                                                   cur_futures_rows.density_volume_qty_unit_id));
      
      else
        vn_market_price_in_trade_cur := (cur_futures_rows.settlement_price /
                                        nvl(cur_futures_rows.settlement_price_weight,
                                             1)) *
                                        pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                 cur_futures_rows.settlement_price_cur_id,
                                                                                 cur_futures_rows.trade_cur_id,
                                                                                 pd_trade_date,
                                                                                 1) *
                                        (pkg_general.f_get_converted_quantity(cur_futures_rows.product_id,
                                                                              cur_futures_rows.settlement_weight_unit_id,
                                                                              cur_futures_rows.trade_weight_unit_id,
                                                                              1));
      
      end if;
      /* he units will be the same since its defaulted in the screen
      vn_market_price_in_trade_cur   := vn_market_price_in_trade_cur *
                                            cur_futures_row(i).weight /
                                            (cur_futures_rows(i).ppu_dq_weight *
                                            pkg_general.f_get_converted_quantity(null,
                                                                                  cur_futures_rows.ppu_dq_weight_unit_id,
                                                                                  cur_futures_rows.weight_unit_id,
                                                                                  1));
       */
      vn_total_market_val_trade_cur := vn_market_price_in_trade_cur *
                                       vn_qty_in_trade_wt_unit;
    
      vn_trade_price_in_trade_cur := cur_futures_rows.trade_price;
    
      vn_total_trade_value_trade_cur := vn_trade_price_in_trade_cur *
                                        vn_qty_in_trade_wt_unit;
    
      /*
      for sales trades pnl = trade price - market price
      for buy trades pnl =  market price - trade price
      */
      if cur_futures_rows.trade_type = 'Buy' then
        vn_pnl_value_in_trade_cur := vn_total_market_val_trade_cur -
                                     vn_total_trade_value_trade_cur;
      else
        vn_pnl_value_in_trade_cur := vn_total_trade_value_trade_cur -
                                     vn_total_market_val_trade_cur;
      end if;
    
      /*
      calcualte net pnl in base currency
       1. calculate trade value in base currency
       a) convert trade qty to price unit weight unit
       b) multiply a by trade price
       c) multipy by trade to base exchange rate
       2. calcualate broker commission in base currency
       3. pnl value in base currency = pnl value in trade currency * exchange rate from trade to base
       4. net pnl in base currency = pnl value in base currency (3) - broker commission in base currency
       */
      vn_total_trade_value_base_cur := vn_trade_to_base_exch_rate *
                                       vn_total_trade_value_trade_cur;
    
      /* 18-jul-2009 . commented this and replaced this with above code
      vn_total_trade_value_base_cur := pkg_general.f_get_converted_quantity(null,
                                                                            cur_futures_rows.trade_qty_unit_id,
                                                                            cur_futures_rows.weight_unit_id,
                                                                            cur_futures_rows.trade_qty) *
                                       cur_futures_rows.trade_price *
                                       vn_trade_to_base_exch_rate; */
    
      vn_broker_comm_in_base_cur := cur_futures_rows.broker_comm_amt *
                                    vn_brokr_cur_to_base_exch_rate;
      vn_clr_comm_in_base_cur    := cur_futures_rows.clearer_comm_amt *
                                    vn_clr_cur_to_base_exch_rate;
      vn_pnl_value_in_base_cur   := vn_pnl_value_in_trade_cur *
                                    vn_trade_to_base_exch_rate;
      --Fix 10th Nov
      --vn_net_pnl_in_base_cur        := vn_pnl_value_in_base_cur -
      --                                 nvl(vn_broker_comm_in_base_cur,0) - nvl(vn_clr_comm_in_base_cur,0);
      vn_net_pnl_in_base_cur := vn_pnl_value_in_base_cur;
    
      --  all this check should be removed later
      if vn_net_pnl_in_base_cur is null then
        vn_net_pnl_in_base_cur := 0;
      end if;
    
      if vn_pnl_value_in_trade_cur is null then
        vn_pnl_value_in_trade_cur := 0;
      end if;
    
      insert into dpd_derivative_pnl_daily
        (internal_derivative_ref_no,
         derivative_ref_no,
         eod_trade_date,
         trade_date,
         corporate_id,
         corporate_name,
         trader_id,
         trader_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         dr_id,
         instrument_id,
         instrument_name,
         instrument_symbol,
         instrument_type_id,
         instrument_type,
         instrument_type_name,
         instrument_sub_type_id,
         instrument_sub_type,
         derivative_def_id,
         derivative_def_name,
         derivative_traded_on,
         derivative_prodct_id,
         derivative_prodct_name,
         exchange_id,
         exchange_name,
         exchange_code,
         lot_size,
         lot_size_unit_id,
         lot_size_unit,
         price_point_id,
         price_point_name,
         period_type_id,
         period_type_name,
         period_type_display_name,
         period_month,
         period_year,
         period_date,
         prompt_date,
         dr_id_name,
         trade_type,
         deal_type_id,
         deal_type_name,
         deal_type_display_name,
         is_multiple_leg_involved,
         deal_category,
         deal_sub_category,
         strategy_id,
         strategy_name,
         strategy_desc,
         strategy_def_name,
         group_id,
         group_name,
         purpose_id,
         purpose_name,
         purpose_display_name,
         external_ref_no,
         cp_profile_id,
         cp_name,
         master_contract_id,
         broker_profile_id,
         broker_name,
         broker_account_id,
         broker_account_name,
         broker_account_type,
         broker_comm_type_id,
         broker_comm_amt,
         broker_comm_cur_id,
         broker_comm_cur_code,
         clearer_profile_id,
         clearer_name,
         clearer_account_id,
         clearer_account_name,
         clearer_account_type,
         clearer_comm_type_id,
         clearer_comm_amt,
         clearer_comm_cur_id,
         clearer_comm_cur_code,
         product_id,
         product_name,
         quality_id,
         quality_name,
         quantity_unit_id,
         quantity_unit,
         total_lots,
         total_quantity,
         open_lots,
         open_quantity,
         exercised_lots,
         exercised_quantity,
         expired_lots,
         expired_quantity,
         trade_price_type_id,
         trade_price,
         trade_price_unit_id,
         trade_price_cur_id,
         trade_price_cur_code,
         trade_price_weight,
         trade_price_weight_unit_id,
         trade_price_weight_unit,
         formula_id,
         formula_name,
         formula_display,
         index_instrument_id,
         index_instrument_name,
         strike_price,
         strike_price_unit_id,
         strike_price_cur_id,
         strike_price_cur_code,
         strike_price_weight,
         strike_price_weight_unit_id,
         strike_price_weight_unit,
         premium_discount,
         premium_discount_price_unit_id,
         pd_price_cur_id,
         pd_price_cur_code,
         pd_price_weight,
         pd_price_weight_unit_id,
         pd_price_weight_unit,
         premium_due_date,
         nominee_profile_id,
         nominee_name,
         leg_no,
         option_expiry_date,
         parent_int_derivative_ref_no,
         market_location_country,
         market_location_state,
         market_location_city,
         is_what_if,
         payment_term_id,
         payment_term,
         payment_due_date,
         closed_lots,
         closed_quantity,
         is_new_trade,
         status,
         settlement_cur_id,
         settlement_cur_code,
         in_out_at_money_status,
         in_out_at_money_value,
         exercise_date,
         expiry_date,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         internal_close_out_ref_no,
         close_out_ref_no,
         close_out_date,
         settlement_price,
         sett_price_unit_id,
         sett_price_cur_id,
         sett_price_cur_code,
         sett_price_weight,
         sett_price_weight_unit_id,
         sett_price_weight_unit,
         parent_instrument_type,
         clearer_comm_in_base,
         broker_comm_in_base,
         clearer_exch_rate,
         broker_exch_rate,
         trade_cur_to_base_exch_rate,
         pnl_type,
         pnl_in_base_cur,
         pnl_in_trade_cur,
         base_cur_id,
         base_cur_code,
         underlying_future_dr_id,
         underlying_future_dr_id_name,
         underlying_future_expiry_date,
         underlying_future_quote_price,
         underlying_fut_price_unit_id,
         process_id,
         trade_qty_in_exch_unit)
      
      values
        (cur_futures_rows.internal_derivative_ref_no,
         cur_futures_rows.derivative_ref_no,
         cur_futures_rows.eod_trade_date,
         cur_futures_rows.trade_date,
         cur_futures_rows.corporate_id,
         cur_futures_rows.corporate_name,
         cur_futures_rows.trader_id,
         cur_futures_rows.tradername,
         cur_futures_rows.profit_center_id,
         cur_futures_rows.profit_center_name,
         cur_futures_rows.profit_center_short_name,
         cur_futures_rows.dr_id,
         cur_futures_rows.instrument_id,
         cur_futures_rows.instrument_name,
         cur_futures_rows.instrument_symbol,
         cur_futures_rows.instrument_type_id,
         cur_futures_rows.instrument_type,
         cur_futures_rows.instrument_display_name,
         cur_futures_rows.instrument_sub_type_id,
         cur_futures_rows.instrument_sub_type,
         cur_futures_rows.derivative_def_id,
         cur_futures_rows.derivative_def_name,
         cur_futures_rows.traded_on,
         cur_futures_rows.product_id,
         cur_futures_rows.product_desc,
         cur_futures_rows.exchange_id,
         cur_futures_rows.exchange_name,
         cur_futures_rows.exchange_code,
         cur_futures_rows.lot_size,
         cur_futures_rows.lot_size_unit_id,
         cur_futures_rows.lot_size_qty_unit,
         cur_futures_rows.price_point_id,
         cur_futures_rows.price_point_name,
         cur_futures_rows.period_type_id,
         cur_futures_rows.period_type_name,
         cur_futures_rows.period_type_display_name,
         cur_futures_rows.period_month,
         cur_futures_rows.period_year,
         cur_futures_rows.period_date,
         cur_futures_rows.prompt_date,
         cur_futures_rows.dr_id_name,
         cur_futures_rows.trade_type,
         cur_futures_rows.deal_type_id,
         cur_futures_rows.deal_type_name,
         cur_futures_rows.deal_type_display_name,
         cur_futures_rows.is_multiple_leg_involved,
         cur_futures_rows.deal_category,
         cur_futures_rows.deal_sub_category,
         cur_futures_rows.strategy_id,
         cur_futures_rows.strategy_name,
         cur_futures_rows.description,
         cur_futures_rows.strategy_def_name,
         cur_futures_rows.groupid,
         cur_futures_rows.groupname,
         cur_futures_rows.purpose_id,
         cur_futures_rows.purpose_name,
         cur_futures_rows.purpose_display_name,
         cur_futures_rows.external_ref_no,
         cur_futures_rows.cp_profile_id,
         cur_futures_rows.cp_name,
         cur_futures_rows.master_contract_id,
         cur_futures_rows.broker_profile_id,
         cur_futures_rows.broker_name,
         cur_futures_rows.broker_account_id,
         cur_futures_rows.broker_account_name,
         cur_futures_rows.broker_account_type,
         cur_futures_rows.broker_comm_type_id,
         cur_futures_rows.broker_comm_amt,
         cur_futures_rows.broker_comm_cur_id,
         cur_futures_rows.broker_cur_code,
         cur_futures_rows.clearer_profile_id,
         cur_futures_rows.clearer_name,
         cur_futures_rows.clearer_account_id,
         cur_futures_rows.clearer_account_name,
         cur_futures_rows.clearer_account_type,
         cur_futures_rows.clearer_comm_type_id,
         cur_futures_rows.clearer_comm_amt,
         cur_futures_rows.clearer_comm_cur_id,
         cur_futures_rows.clearer_cur_code,
         cur_futures_rows.product_id,
         cur_futures_rows.product,
         cur_futures_rows.quality_id,
         cur_futures_rows.quality_name,
         cur_futures_rows.quantity_unit_id,
         cur_futures_rows.quantityname,
         cur_futures_rows.open_lots, -- total_lots,--siva
         cur_futures_rows.open_quantity, -- .total_quantity,--siva
         cur_futures_rows.open_lots,
         cur_futures_rows.open_quantity,
         cur_futures_rows.exercised_lots,
         cur_futures_rows.exercised_quantity,
         cur_futures_rows.expired_lots,
         cur_futures_rows.expired_quantity,
         cur_futures_rows.trade_price_type_id,
         cur_futures_rows.trade_price,
         cur_futures_rows.trade_price_unit_id,
         cur_futures_rows.trade_cur_id,
         cur_futures_rows.trade_cur_code,
         cur_futures_rows.trade_weight,
         cur_futures_rows.trade_weight_unit_id,
         cur_futures_rows.trade_qty_unit,
         cur_futures_rows.formula_id,
         cur_futures_rows.formula_name,
         cur_futures_rows.formula_display,
         cur_futures_rows.index_instrument_id,
         cur_futures_rows.index_instrument_name,
         cur_futures_rows.strike_price,
         cur_futures_rows.strike_price_unit_id,
         cur_futures_rows.strike_cur_id,
         cur_futures_rows.strike_cur_code,
         cur_futures_rows.strike_weight,
         cur_futures_rows.strike_weight_unit_id,
         cur_futures_rows.strike_qty_unit,
         cur_futures_rows.premium_discount,
         cur_futures_rows.premium_discount_price_unit_id,
         cur_futures_rows.pd_cur_id,
         cur_futures_rows.pd_cur_code,
         cur_futures_rows.pd_weight,
         cur_futures_rows.pd_weight_unit_id,
         cur_futures_rows.pd_qty_unit,
         cur_futures_rows.premium_due_date,
         cur_futures_rows.nominee_profile_id,
         cur_futures_rows.nominee_name,
         cur_futures_rows.leg_no,
         cur_futures_rows.option_expiry_date,
         cur_futures_rows.parent_int_derivative_ref_no,
         cur_futures_rows.market_location_country,
         cur_futures_rows.market_location_state,
         cur_futures_rows.market_location_city,
         cur_futures_rows.is_what_if,
         cur_futures_rows.payment_term,
         cur_futures_rows.payment_term,
         cur_futures_rows.payment_due_date,
         cur_futures_rows.closed_lots,
         cur_futures_rows.closed_quantity,
         cur_futures_rows.is_new_trade_date,
         cur_futures_rows.status,
         cur_futures_rows.settlement_cur_id,
         cur_futures_rows.settlement_cur_code,
         cur_futures_rows.in_out_at_money_status,
         cur_futures_rows.in_out_at_money_value,
         cur_futures_rows.exercise_date,
         cur_futures_rows.expiry_date,
         cur_futures_rows.group_cur_id,
         cur_futures_rows.group_cur_code,
         cur_futures_rows.group_qty_unit_id,
         cur_futures_rows.gcd_qty_unit,
         cur_futures_rows.base_qty_unit_id,
         cur_futures_rows.base_qty_unit,
         cur_futures_rows.internal_close_out_ref_no,
         cur_futures_rows.close_out_ref_no,
         cur_futures_rows.close_out_date,
         cur_futures_rows.settlement_price,
         cur_futures_rows.settlement_price_unit_id,
         cur_futures_rows.settlement_price_cur_id,
         cur_futures_rows.settlemet_price_cur_code,
         cur_futures_rows.settlement_price_weight,
         cur_futures_rows.settlement_weight_unit_id,
         cur_futures_rows.settlement_weight_unit,
         cur_futures_rows.parent_instrument_type,
         vn_clr_comm_in_base_cur,
         vn_broker_comm_in_base_cur,
         vn_clr_cur_to_base_exch_rate,
         vn_brokr_cur_to_base_exch_rate,
         vn_trade_to_base_exch_rate,
         cur_futures_rows.pnl_type,
         vn_net_pnl_in_base_cur,
         vn_pnl_value_in_trade_cur,
         cur_futures_rows.base_cur_id,
         cur_futures_rows.base_cur_code,
         cur_futures_rows.underlying_future_dr_id,
         cur_futures_rows.underlying_future_dr_id_name,
         cur_futures_rows.underlying_future_expiry_date,
         cur_futures_rows.underlying_future_quote_price,
         cur_futures_rows.underlying_fut_price_unit_id,
         cur_futures_rows.process_id,
         vn_trade_qty_exch_unit);
    
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_future_unrealized_pnl',
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

  procedure sp_calc_future_realized_pnl(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_process      varchar2,
                                        pc_dbd_id       varchar2) is
    /******************************************************************************************************************************************
    procedure name                            : sp_calc_future_realized_pnl
    author                                    : janna
    created date                              : 10th jan 2009
    purpose                                   : calculate the realized pnl for futures as on eod date
    parameters                                :
    pc_corporate_id                           : corporate id
    pd_trade_date                             : eod date id
    pc_process_id                             : eod reference no
    modification history                      :
    modified date                             :
    modified by                               :
    modify description                        :
    ******************************************************************************************************************************************/
    cursor cur_futures is
      select dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             pd_trade_date eod_trade_date,
             dt.trade_date,
             dt.corporate_id,
             ak.corporate_name,
             dt.trader_id,
             gab.firstname || gab.lastname tradername,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dt.dr_id,
             drm.instrument_id,
             dim.instrument_name,
             dim.instrument_symbol,
             dim.instrument_type_id,
             irm.instrument_type,
             irm.instrument_display_name,
             dim.instrument_sub_type_id,
             istm.instrument_sub_type,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             pdd.traded_on,
             pdd.product_id,
             pdm.product_desc,
             emt.exchange_id,
             emt.exchange_name,
             emt.exchange_code,
             pdd.lot_size,
             pdd.lot_size_unit_id,
             qum.qty_unit lot_size_qty_unit,
             drm.price_point_id,
             pp.price_point_name,
             drm.period_type_id,
             pm.period_type_name,
             pm.period_type_display_name,
             drm.period_month,
             drm.period_year,
             (case
               when drm.period_date is null then
                case
               when drm.period_month is not null and
                    drm.period_year is not null then
                to_date('01-' || drm.period_month || '-' || drm.period_year,
                        'dd-Mon-yyyy')
               else
                drm.prompt_date
             end else drm.period_date end) period_date,
             drm.prompt_date,
             drm.dr_id_name,
             dt.trade_type,
             dt.deal_type_id,
             dtm.deal_type_name,
             dtm.deal_type_display_name,
             dtm.is_multiple_leg_involved,
             null deal_category,
             null deal_sub_category,
             dt.strategy_id,
             css.strategy_name,
             css.description,
             sdm.strategy_def_name,
             ak.groupid,
             gcd.groupname,
             dt.purpose_id,
             dpm.purpose_name,
             dpm.purpose_display_name,
             dt.external_ref_no,
             dt.cp_profile_id,
             phd_cp.companyname cp_name,
             dt.master_contract_id,
             dt.broker_profile_id,
             phd_broker.companyname broker_name,
             dt.broker_account_id,
             bca_broker.account_name broker_account_name,
             bca_broker.account_type broker_account_type,
             dcod.broker_comm_type_id,
             dcod.broker_comm_amt,
             dcod.broker_comm_cur_id,
             cm_broker_cur.cur_code broker_cur_code,
             dt.clearer_profile_id,
             phd_clearer.companyname clearer_name,
             dt.clearer_account_id,
             bca_clearer.account_name clearer_account_name,
             bca_clearer.account_type clearer_account_type,
             dcod.clearer_comm_type_id,
             dcod.clearer_comm_amt,
             dcod.clearer_comm_cur_id,
             cm_clearer.cur_code clearer_cur_code,
             dt.product_id product,
             pdm.product_desc productdesc,
             dt.quality_id,
             qat.quality_name,
             dt.quantity_unit_id trade_qty_unit_id,
             qum_um.qty_unit quantityname,
             dt.total_lots,
             dt.total_quantity,
             dt.open_lots,
             dt.open_quantity,
             dt.exercised_lots,
             dt.exercised_quantity,
             dt.expired_lots,
             dt.expired_quantity,
             dt.trade_price_type_id,
             dt.trade_price,
             dt.trade_price_unit_id,
             pum_trade.cur_id trade_cur_id,
             cm_trade.cur_code trade_cur_code,
             pum_trade.weight trade_weight,
             pum_trade.weight_unit_id trade_weight_unit_id,
             qum_trade.qty_unit trade_qty_unit,
             dt.formula_id,
             fbs.formula_name,
             fbs.formula_display,
             dt.index_instrument_id,
             dim_index.instrument_name index_instrument_name,
             dt.strike_price,
             dt.strike_price_unit_id,
             pum_strike.cur_id strike_cur_id,
             cm_strike.cur_code strike_cur_code,
             pum_strike.weight strike_weight,
             pum_strike.weight_unit_id strike_weight_unit_id,
             qum_strike.qty_unit strike_qty_unit,
             dt.premium_discount,
             dt.premium_discount_price_unit_id,
             pum_pd.cur_id pd_cur_id,
             cm_pd.cur_code pd_cur_code,
             pum_pd.weight pd_weight,
             pum_pd.weight_unit_id pd_weight_unit_id,
             qum_pd.qty_unit pd_qty_unit,
             dt.premium_due_date,
             dt.nominee_profile_id,
             phd_nominee.companyname nominee_name,
             dt.leg_no,
             dt.option_expiry_date,
             dt.parent_int_derivative_ref_no,
             dt.market_location_country,
             dt.market_location_state,
             dt.market_location_city,
             dt.is_what_if,
             dt.payment_term,
             pym.payment_term payment_term_name,
             dt.payment_due_date,
             dt.closed_lots,
             dt.closed_quantity,
             null as is_new_trade_date,
             dt.status,
             dt.settlement_cur_id,
             cm_settlement.cur_code settlement_cur_code,
             null as in_out_at_money_status,
             null as in_out_at_money_value,
             null as exercise_date,
             null as expiry_date,
             gcd_group.group_cur_id,
             cm_gcd.cur_code group_cur_code,
             gcd_group.group_qty_unit_id,
             qum_gcd.qty_unit gcd_qty_unit,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             dcod.lots_closed,
             dcod.quantity_closed,
             dcod.quantity_unit_id as dcod_quantity_unit_id,
             dcoh.internal_close_out_ref_no,
             dcoh.close_out_ref_no,
             dcoh.close_out_date,
             --edq.price settlement_price,
             --edq.price_unit_id settlement_price_unit_id,
             --pum_settle.cur_id settlement_price_cur_id,
             --cm_settle.cur_code settlemet_price_cur_code,
             --pum_settle.weight settlement_price_weight,
             --pum_settle.weight_unit_id settlement_weight_unit_id,
             --qum_settle.qty_unit settlement_weight_unit,
             (case
               when irm.instrument_type in ('Option Put', 'Option Call') then
                'Option'
               else
                irm.instrument_type
             end) as parent_instrument_type,
             null as clearer_comm_in_base,
             null as broker_comm_in_base,
             null as clearer_exch_rate,
             null as broker_exch_rate,
             null as trade_cur_to_base_exch_rate,
             'Realized' as pnl_type,
             null as pnl_in_base_cur,
             null as pnl_in_trade_cur,
             cm_base.cur_id as base_cur_id,
             ak.base_currency_name base_cur_code,
             null as underlying_future_dr_id,
             null as underlying_future_dr_id_name,
             null as underlying_future_expiry_date,
             null as underlying_future_quote_price,
             null as underlying_fut_price_unit_id,
             pc_process_id process_id,
             div.available_price_id,
             div.price_unit_id,
             div.price_source_id
        from dt_derivative_trade            dt,
             ak_corporate                   ak,
             ak_corporate_user              aku,
             gab_globaladdressbook          gab,
             cpc_corporate_profit_center    cpc,
             drm_derivative_master          drm,
             dim_der_instrument_master      dim,
             div_der_instrument_valuation   div,
             apm_available_price_master     apm,
             irm_instrument_type_master     irm,
             istm_instr_sub_type_master     istm,
             pdd_product_derivative_def     pdd,
             pdm_productmaster              pdm,
             emt_exchangemaster             emt,
             qum_quantity_unit_master       qum,
             pp_price_point                 pp,
             pm_period_master               pm,
             dtm_deal_type_master           dtm,
             css_corporate_strategy_setup   css,
             sdm_strategy_definition_master sdm,
             gcd_groupcorporatedetails      gcd,
             dpm_derivative_purpose_master  dpm,
             phd_profileheaderdetails       phd_cp,
             phd_profileheaderdetails       phd_broker,
             bca_broker_clearer_account     bca_broker,
             cm_currency_master             cm_broker_cur,
             phd_profileheaderdetails       phd_clearer,
             bca_broker_clearer_account     bca_clearer,
             cm_currency_master             cm_clearer,
             qat_quality_attributes         qat,
             qum_quantity_unit_master       qum_um,
             pum_price_unit_master          pum_trade,
             cm_currency_master             cm_trade,
             qum_quantity_unit_master       qum_trade,
             fbs_formula_builder_setup      fbs,
             dim_der_instrument_master      dim_index,
             pum_price_unit_master          pum_strike,
             cm_currency_master             cm_strike,
             qum_quantity_unit_master       qum_strike,
             pum_price_unit_master          pum_pd,
             cm_currency_master             cm_pd,
             qum_quantity_unit_master       qum_pd,
             phd_profileheaderdetails       phd_nominee,
             pym_payment_terms_master       pym,
             cm_currency_master             cm_settlement,
             gcd_groupcorporatedetails      gcd_group,
             cm_currency_master             cm_gcd,
             qum_quantity_unit_master       qum_gcd,
             qum_quantity_unit_master       qum_pdm,
             cm_currency_master             cm_base,
             dcoh_der_closeout_header       dcoh,
             dcod_der_closeout_detail       dcod
       where dt.corporate_id = ak.corporate_id
         and dt.trader_id = aku.user_id
         and aku.gabid = gab.gabid
         and dt.profit_center_id = cpc.profit_center_id
         and dt.dr_id = drm.dr_id(+)
         and drm.instrument_id = dim.instrument_id(+)
         and dim.instrument_type_id = irm.instrument_type_id(+)
         and dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
         and dim.product_derivative_id = pdd.derivative_def_id(+)
         and pdd.product_id = pdm.product_id(+)
         and pdd.exchange_id = emt.exchange_id(+)
         and pdd.lot_size_unit_id = qum.qty_unit_id(+)
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.available_price_id = apm.available_price_id
         and drm.price_point_id = pp.price_point_id(+)
         and drm.period_type_id = pm.period_type_id(+)
         and dt.deal_type_id = dtm.deal_type_id
         and dt.strategy_id = css.strategy_id
         and css.strategy_def_id = sdm.strategy_def_id
         and ak.groupid = gcd.groupid
         and dt.purpose_id = dpm.purpose_id
         and dt.cp_profile_id = phd_cp.profileid(+)
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.broker_account_id = bca_broker.account_id(+)
         and dcod.broker_comm_cur_id = cm_broker_cur.cur_id(+)
         and dt.clearer_profile_id = phd_clearer.profileid(+)
         and dt.clearer_account_id = bca_clearer.account_id(+)
         and dcod.clearer_comm_cur_id = cm_clearer.cur_id(+)
         and dt.quality_id = qat.quality_id(+)
         and dt.quantity_unit_id = qum_um.qty_unit_id
         and dt.trade_price_unit_id = pum_trade.price_unit_id(+)
         and pum_trade.cur_id = cm_trade.cur_id(+)
         and pum_trade.weight_unit_id = qum_trade.qty_unit_id(+)
         and dt.formula_id = fbs.formula_id(+)
         and dt.index_instrument_id = dim_index.instrument_id(+)
         and dt.strike_price_unit_id = pum_strike.price_unit_id(+)
         and pum_strike.cur_id = cm_strike.cur_id(+)
         and pum_strike.weight_unit_id = qum_strike.qty_unit_id(+)
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and pum_pd.cur_id = cm_pd.cur_id(+)
         and pum_pd.weight_unit_id = qum_pd.qty_unit_id(+)
         and dt.nominee_profile_id = phd_nominee.profileid(+)
         and dt.payment_term = pym.payment_term_id(+)
         and dt.settlement_cur_id = cm_settlement.cur_id(+)
         and ak.groupid=gcd_group.groupid
         and gcd_group.group_cur_id = cm_gcd.cur_id
         and gcd_group.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id(+)
            --and dt.process_id=edq.process_id
            --AND dt.dr_id = edq.dr_id(+)
            --AND edq.price_unit_id = pum_settle.price_unit_id(+)
            --AND pum_settle.cur_id = cm_settle.cur_id(+)
            --AND pum_settle.weight_unit_id = qum_settle.qty_unit_id(+)
         and ak.base_currency_name = cm_base.cur_code
         and dcoh.internal_close_out_ref_no =
             dcod.internal_close_out_ref_no
         and dcod.process_id = dcoh.process_id
         and dcoh.process_id = pc_process_id
         and dt.internal_derivative_ref_no =
             dcod.internal_derivative_ref_no
         and irm.instrument_type in ('Future', 'Forward')
            -- AND UPPER(dt.status) in ('closed', 'settled')
         and dt.is_what_if = 'N'
         and dt.corporate_id = pc_corporate_id
         and dt.trade_date <= pd_trade_date
         and dt.process_id = pc_process_id
         and dcoh.is_rolled_back = 'N';
  
    vn_total_trade_value_base_cur  number;
    vn_pnl_value_in_trade_cur      number;
    vn_trade_to_base_exch_rate     number;
    vn_pnl_value_in_base_cur       number;
    vn_broker_comm_in_base_cur     number;
    vn_clearer_comm_in_base_cur    number;
    vn_net_pnl_in_base_cur         number;
    vn_brokr_cur_to_base_exch_rate number;
    vn_clr_cur_to_base_exch_rate   number;
    vn_qty_in_trade_wt_unit        number;
    vn_market_price_in_trade_cur   number;
    vn_total_market_val_trade_cur  number;
    vn_trade_price_in_trade_cur    number;
    vn_total_trade_value_trade_cur number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    --vn_bank_fees_exch_rate         number;
    --vn_bank_fees                   number;
    --vn_bank_fees_in_base_cur       number;
    vn_trade_qty_exch_unit       number;
    vc_settlement_price_unit_id  varchar2(15);
    vc_settlement_cur_id         varchar2(15);
    vc_settlement_cur_code       varchar2(15);
    vc_settlement_weight         number(7, 2);
    vc_settlement_weight_unit_id varchar2(15);
    vc_settlement_weight_unit    varchar2(15);
    vn_logno                     number := 0;
  begin
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            vn_logno,
                            'sp_cdc_realized pnl');
  
    --update drt
    /*
    update drt_derivative_trade drt
    set    (drt.close_out_ref_no, drt.close_out_date) = (select dcoh.close_out_ref_no,
                                                                dcoh.close_out_date
                                                         from   dcoh_der_closeout_header dcoh,
                                                                dcod_der_closeout_detail dcod
                                                         where  dcoh.internal_close_out_ref_no =
                                                                dcod.internal_close_out_ref_no
                                                         and    dcod.process_id =
                                                                dcoh.process_id
                                                         and    dcoh.process_id =
                                                                pc_process_id
                                                         and    dcod.internal_derivative_ref_no =
                                                                drt.internal_derivative_ref_no)
    where  drt.process_id = pc_process_id;
    */
    for cur_futures_rows in cur_futures
    loop
    
      vn_trade_qty_exch_unit := pkg_general.f_get_converted_quantity(null,
                                                                     cur_futures_rows.trade_qty_unit_id,
                                                                     cur_futures_rows.lot_size_unit_id,
                                                                     cur_futures_rows.quantity_closed);
      vn_logno               := vn_logno + 1;
      sp_precheck_process_log(pc_corporate_id,
                              pd_trade_date,
                              pc_dbd_id,
                              vn_logno,
                              'sp_cdc_realized pnl vn_trade_qty_exch_unit ' ||
                              cur_futures_rows.derivative_ref_no || ' ' ||
                              vn_trade_qty_exch_unit);
    
      /*
      get the exchange rates
      1. from broker to base currency
      2. trade to base currency
      */
      if cur_futures_rows.trade_cur_id <> cur_futures_rows.base_cur_id then
        vn_trade_to_base_exch_rate := f_currency_exchange_rate(cur_futures_rows.close_out_date,
                                                               pc_corporate_id,
                                                               cur_futures_rows.prompt_date,
                                                               cur_futures_rows.trade_cur_id,
                                                               cur_futures_rows.base_cur_id);
      else
        vn_trade_to_base_exch_rate := 1;
      end if;
    
      if cur_futures_rows.broker_comm_cur_id <>
         cur_futures_rows.base_cur_id then
        vn_brokr_cur_to_base_exch_rate := f_currency_exchange_rate(cur_futures_rows.close_out_date,
                                                                   pc_corporate_id,
                                                                   cur_futures_rows.prompt_date,
                                                                   cur_futures_rows.broker_comm_cur_id,
                                                                   cur_futures_rows.base_cur_id);
      else
        vn_brokr_cur_to_base_exch_rate := 1;
      end if;
    
      if cur_futures_rows.clearer_comm_cur_id <>
         cur_futures_rows.base_cur_id then
        vn_clr_cur_to_base_exch_rate := f_currency_exchange_rate(cur_futures_rows.close_out_date,
                                                                 pc_corporate_id,
                                                                 cur_futures_rows.prompt_date,
                                                                 cur_futures_rows.clearer_comm_cur_id,
                                                                 cur_futures_rows.base_cur_id);
      else
        vn_clr_cur_to_base_exch_rate := 1;
      end if;
    
      /*      IF cur_futures_rows.bank_fee_cur_id IS NOT NULL AND
         cur_futures_rows.bank_fee_cur_id <> cur_futures_rows.base_cur_id THEN
        vn_bank_fees_exch_rate := f_currency_exchange_rate(cur_futures_rows.close_date,
                                                                                   pc_corporate_id,
                                                                                   cur_futures_rows.prompt_date,
                                                                                   cur_futures_rows.bank_fee_cur_id,
                                                                                   cur_futures_rows.base_cur_id);
      ELSE
        vn_bank_fees_exch_rate := 1;
      END IF;*/
    
      /*
      calcualate trade pnl in trade currency
      1. convert trade qty from trade price unit weight unit to trade weight unit
      2. get the market price in trade currency
      3. market value in trade currency = qty in trade weight unit(1) * market price in trade currency(2)
      4. trade value in trade currency = trade price in trade currency (from drt) * trade qty in trade unit(1)
      5. pnl in trade currency = market value in trade currency(2) - trade value in trade currency(4)
      */
    
      --vn_qty_in_trade_wt_unit      := f_get_converted_quantity(null, --product id
      --                                                                     cur_futures_rows.weight_unit_id,
      --                                                                     cur_futures_rows.trade_qty_unit_id,
      --                                                                     cur_futures_rows.trade_qty);
      --we should be getting the closed quantity
      vn_qty_in_trade_wt_unit := f_get_converted_quantity(null, --product id
                                                          cur_futures_rows.trade_qty_unit_id,
                                                          cur_futures_rows.trade_weight_unit_id,
                                                          cur_futures_rows.quantity_closed);
    
      ---    vn_market_price_in_trade_cur := cur_futures_rows.settlement_price;
      vn_logno := vn_logno + 1;
      sp_precheck_process_log(pc_corporate_id,
                              pd_trade_date,
                              pc_dbd_id,
                              vn_logno,
                              'sp_cdc_realized pnl dq/dqd ' ||
                              cur_futures_rows.derivative_ref_no ||
                              ' close out date' ||
                              cur_futures_rows.close_out_date || 'DRID ' ||
                              cur_futures_rows.dr_id || '-' ||
                              cur_futures_rows.instrument_id ||
                              ' trade on ' || cur_futures_rows.traded_on);
    
      begin
        select dqd.price,
               dqd.price_unit_id,
               pum.cur_id,
               cm.cur_code,
               pum.weight,
               pum.weight_unit_id,
               qum.qty_unit
          into vn_market_price_in_trade_cur,
               vc_settlement_price_unit_id,
               vc_settlement_cur_id,
               vc_settlement_cur_code,
               vc_settlement_weight,
               vc_settlement_weight_unit_id,
               vc_settlement_weight_unit
          from dq_derivative_quotes        dq,
               dqd_derivative_quote_detail dqd,
               apm_available_price_master  apm,
               pum_price_unit_master       pum,
               cm_currency_master          cm,
               qum_quantity_unit_master    qum
         where dq.dq_id = dqd.dq_id
           and dq.dbd_id = dqd.dbd_id
           and dqd.price_unit_id = pum.price_unit_id
           and pum.cur_id = cm.cur_id
           and pum.weight_unit_id = qum.qty_unit_id
           and dq.trade_date = cur_futures_rows.close_out_date
           and dqd.price <> 0
           and dqd.dr_id = cur_futures_rows.dr_id
           and dq.corporate_id = pc_corporate_id
           and upper(dq.entry_type) = upper(cur_futures_rows.traded_on)
           and dq.instrument_id = cur_futures_rows.instrument_id
           and dqd.available_price_id = apm.available_price_id
           and dqd.available_price_id = cur_futures_rows.available_price_id
           and dqd.price_unit_id = cur_futures_rows.price_unit_id
              --  and apm.available_price_name = 'Settlement'
           and dq.dbd_id = pc_dbd_id;
      
        vn_logno := vn_logno + 1;
        sp_precheck_process_log(pc_corporate_id,
                                pd_trade_date,
                                pc_dbd_id,
                                vn_logno,
                                'sp_cdc_realized pnl vc_settlement ' ||
                                cur_futures_rows.derivative_ref_no || ' ' ||
                                vn_market_price_in_trade_cur || '-' ||
                                vc_settlement_price_unit_id);
      
      exception
        when no_data_found then
          vn_market_price_in_trade_cur := 0;
          vc_settlement_price_unit_id  := null;
          vc_settlement_cur_id         := null;
          vc_settlement_cur_code       := null;
          vc_settlement_weight         := null;
          vc_settlement_weight_unit_id := null;
          vc_settlement_weight_unit    := null;
          vn_logno                     := vn_logno + 1;
          sp_precheck_process_log(pc_corporate_id,
                                  pd_trade_date,
                                  pc_dbd_id,
                                  vn_logno,
                                  'sp_cdc_realized pnl vc_settlement NO DATA ' ||
                                  cur_futures_rows.derivative_ref_no || ' ' ||
                                  vn_market_price_in_trade_cur || '-' ||
                                  vc_settlement_price_unit_id);
        
        when others then
          vn_market_price_in_trade_cur := 0;
          vc_settlement_price_unit_id  := null;
          vc_settlement_cur_id         := null;
          vc_settlement_cur_code       := null;
          vc_settlement_weight         := null;
          vc_settlement_weight_unit_id := null;
          vc_settlement_weight_unit    := null;
          vn_logno                     := vn_logno + 1;
          sp_precheck_process_log(pc_corporate_id,
                                  pd_trade_date,
                                  pc_dbd_id,
                                  vn_logno,
                                  'sp_cdc_realized pnl vc_settlement OTHERS ' ||
                                  cur_futures_rows.derivative_ref_no || ' ' ||
                                  vn_market_price_in_trade_cur || '-' ||
                                  vc_settlement_price_unit_id);
        
      end;
    
      /*
      market price in trade currency (dq_) needs to be converted into price unit currency of drt_
      
      vn_market_price_in_trade_cur   := vn_market_price_in_trade_cur *
                                        cur_futures_rows.weight /
                                        (cur_futures_rows.ppu_dq_weight *
                                        pkg_general.f_get_converted_quantity(null,
                                                                              cur_futures_rows.ppu_dq_weight_unit_id,
                                                                              cur_futures_rows.weight_unit_id,
                                                                              1));
      */
      vn_total_market_val_trade_cur := vn_market_price_in_trade_cur *
                                       vn_qty_in_trade_wt_unit;
    
      vn_trade_price_in_trade_cur := cur_futures_rows.trade_price;
    
      vn_total_trade_value_trade_cur := vn_trade_price_in_trade_cur *
                                        vn_qty_in_trade_wt_unit;
    
      /*
      for sales trades pnl = trade price - market price
      for buy trades pnl =  market price - trade price
      */
      if cur_futures_rows.trade_type = 'Buy' then
        vn_pnl_value_in_trade_cur := vn_total_market_val_trade_cur -
                                     vn_total_trade_value_trade_cur;
      else
        vn_pnl_value_in_trade_cur := vn_total_trade_value_trade_cur -
                                     vn_total_market_val_trade_cur;
      end if;
    
      -- calcualate trade pnl in trade currency ends here
      /*
      calcualte net pnl in base currency
       1. calculate trade value in base currency
       a) convert trade qty to price unit weight unit
       b) multiply a by trade price
       c) multipy by trade to base exchange rate
       2. calcualate broker commission in base currency
       3. pnl value in base currency = pnl value in trade currency * exchange rate from trade to base
       4. net pnl in base currency = pnl value in base currency (3) - broker commission in base currency
       */
      vn_total_trade_value_base_cur := vn_total_trade_value_trade_cur *
                                       vn_trade_to_base_exch_rate;
      /*
      vn_total_trade_value_base_cur := pkg_general.f_get_converted_quantity(null,
                                                                            cur_futures_rows.quantity_unit_id,
                                                                            cur_futures_rows.trade_qty_unit_id,
                                                                            cur_futures_rows.quantity_closed ) *
                                                                            --cur_futures_rows.weight_unit_id,
                                                                            --cur_futures_rows.trade_qty) *
                                       cur_futures_rows.trade_price *
                                       vn_trade_to_base_exch_rate;
      */
      vn_broker_comm_in_base_cur  := cur_futures_rows.broker_comm_amt *
                                     vn_brokr_cur_to_base_exch_rate;
      vn_clearer_comm_in_base_cur := cur_futures_rows.clearer_comm_amt *
                                     vn_clr_cur_to_base_exch_rate;
      vn_pnl_value_in_base_cur    := vn_pnl_value_in_trade_cur *
                                     vn_trade_to_base_exch_rate;
      vn_net_pnl_in_base_cur      := vn_pnl_value_in_base_cur -
                                     nvl(vn_broker_comm_in_base_cur, 0) -
                                     nvl(vn_clearer_comm_in_base_cur, 0);
      /* -NVL(vn_bank_fees_in_base_cur, 0);*/
    
      if vn_net_pnl_in_base_cur is null then
        vn_net_pnl_in_base_cur := 0;
      end if;
    
      if vn_pnl_value_in_trade_cur is null then
        vn_pnl_value_in_trade_cur := 0;
      end if;
    
      insert into dpd_derivative_pnl_daily
        (internal_derivative_ref_no,
         derivative_ref_no,
         eod_trade_date,
         trade_date,
         corporate_id,
         corporate_name,
         trader_id,
         trader_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         dr_id,
         instrument_id,
         instrument_name,
         instrument_symbol,
         instrument_type_id,
         instrument_type,
         instrument_type_name,
         instrument_sub_type_id,
         instrument_sub_type,
         derivative_def_id,
         derivative_def_name,
         derivative_traded_on,
         derivative_prodct_id,
         derivative_prodct_name,
         exchange_id,
         exchange_name,
         exchange_code,
         lot_size,
         lot_size_unit_id,
         lot_size_unit,
         price_point_id,
         price_point_name,
         period_type_id,
         period_type_name,
         period_type_display_name,
         period_month,
         period_year,
         period_date,
         prompt_date,
         dr_id_name,
         trade_type,
         deal_type_id,
         deal_type_name,
         deal_type_display_name,
         is_multiple_leg_involved,
         deal_category,
         deal_sub_category,
         strategy_id,
         strategy_name,
         strategy_desc,
         strategy_def_name,
         group_id,
         group_name,
         purpose_id,
         purpose_name,
         purpose_display_name,
         external_ref_no,
         cp_profile_id,
         cp_name,
         master_contract_id,
         broker_profile_id,
         broker_name,
         broker_account_id,
         broker_account_name,
         broker_account_type,
         broker_comm_type_id,
         broker_comm_amt,
         broker_comm_cur_id,
         broker_comm_cur_code,
         clearer_profile_id,
         clearer_name,
         clearer_account_id,
         clearer_account_name,
         clearer_account_type,
         clearer_comm_type_id,
         clearer_comm_amt,
         clearer_comm_cur_id,
         clearer_comm_cur_code,
         product_id,
         product_name,
         quality_id,
         quality_name,
         quantity_unit_id,
         quantity_unit,
         total_lots,
         total_quantity,
         open_lots,
         open_quantity,
         exercised_lots,
         exercised_quantity,
         expired_lots,
         expired_quantity,
         trade_price_type_id,
         trade_price,
         trade_price_unit_id,
         trade_price_cur_id,
         trade_price_cur_code,
         trade_price_weight,
         trade_price_weight_unit_id,
         trade_price_weight_unit,
         formula_id,
         formula_name,
         formula_display,
         index_instrument_id,
         index_instrument_name,
         strike_price,
         strike_price_unit_id,
         strike_price_cur_id,
         strike_price_cur_code,
         strike_price_weight,
         strike_price_weight_unit_id,
         strike_price_weight_unit,
         premium_discount,
         premium_discount_price_unit_id,
         pd_price_cur_id,
         pd_price_cur_code,
         pd_price_weight,
         pd_price_weight_unit_id,
         pd_price_weight_unit,
         premium_due_date,
         nominee_profile_id,
         nominee_name,
         leg_no,
         option_expiry_date,
         parent_int_derivative_ref_no,
         market_location_country,
         market_location_state,
         market_location_city,
         is_what_if,
         payment_term_id,
         payment_term,
         payment_due_date,
         closed_lots,
         closed_quantity,
         is_new_trade,
         status,
         settlement_cur_id,
         settlement_cur_code,
         in_out_at_money_status,
         in_out_at_money_value,
         exercise_date,
         expiry_date,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         internal_close_out_ref_no,
         close_out_ref_no,
         close_out_date,
         settlement_price,
         sett_price_unit_id,
         sett_price_cur_id,
         sett_price_cur_code,
         sett_price_weight,
         sett_price_weight_unit_id,
         sett_price_weight_unit,
         parent_instrument_type,
         clearer_comm_in_base,
         broker_comm_in_base,
         clearer_exch_rate,
         broker_exch_rate,
         trade_cur_to_base_exch_rate,
         pnl_type,
         pnl_in_base_cur,
         pnl_in_trade_cur,
         base_cur_id,
         base_cur_code,
         underlying_future_dr_id,
         underlying_future_dr_id_name,
         underlying_future_expiry_date,
         underlying_future_quote_price,
         underlying_fut_price_unit_id,
         process_id,
         trade_qty_in_exch_unit)
      
      values
        (cur_futures_rows.internal_derivative_ref_no,
         cur_futures_rows.derivative_ref_no,
         cur_futures_rows.eod_trade_date,
         cur_futures_rows.trade_date,
         cur_futures_rows.corporate_id,
         cur_futures_rows.corporate_name,
         cur_futures_rows.trader_id,
         cur_futures_rows.tradername,
         cur_futures_rows.profit_center_id,
         cur_futures_rows.profit_center_name,
         cur_futures_rows.profit_center_short_name,
         cur_futures_rows.dr_id,
         cur_futures_rows.instrument_id,
         cur_futures_rows.instrument_name,
         cur_futures_rows.instrument_symbol,
         cur_futures_rows.instrument_type_id,
         cur_futures_rows.instrument_type,
         cur_futures_rows.instrument_display_name,
         cur_futures_rows.instrument_sub_type_id,
         cur_futures_rows.instrument_sub_type,
         cur_futures_rows.derivative_def_id,
         cur_futures_rows.derivative_def_name,
         cur_futures_rows.traded_on,
         cur_futures_rows.product_id,
         cur_futures_rows.product_desc,
         cur_futures_rows.exchange_id,
         cur_futures_rows.exchange_name,
         cur_futures_rows.exchange_code,
         cur_futures_rows.lot_size,
         cur_futures_rows.lot_size_unit_id,
         cur_futures_rows.lot_size_qty_unit,
         cur_futures_rows.price_point_id,
         cur_futures_rows.price_point_name,
         cur_futures_rows.period_type_id,
         cur_futures_rows.period_type_name,
         cur_futures_rows.period_type_display_name,
         cur_futures_rows.period_month,
         cur_futures_rows.period_year,
         cur_futures_rows.period_date,
         cur_futures_rows.prompt_date,
         cur_futures_rows.dr_id_name,
         cur_futures_rows.trade_type,
         cur_futures_rows.deal_type_id,
         cur_futures_rows.deal_type_name,
         cur_futures_rows.deal_type_display_name,
         cur_futures_rows.is_multiple_leg_involved,
         cur_futures_rows.deal_category,
         cur_futures_rows.deal_sub_category,
         cur_futures_rows.strategy_id,
         cur_futures_rows.strategy_name,
         cur_futures_rows.description,
         cur_futures_rows.strategy_def_name,
         cur_futures_rows.groupid,
         cur_futures_rows.groupname,
         cur_futures_rows.purpose_id,
         cur_futures_rows.purpose_name,
         cur_futures_rows.purpose_display_name,
         cur_futures_rows.external_ref_no,
         cur_futures_rows.cp_profile_id,
         cur_futures_rows.cp_name,
         cur_futures_rows.master_contract_id,
         cur_futures_rows.broker_profile_id,
         cur_futures_rows.broker_name,
         cur_futures_rows.broker_account_id,
         cur_futures_rows.broker_account_name,
         cur_futures_rows.broker_account_type,
         cur_futures_rows.broker_comm_type_id,
         cur_futures_rows.broker_comm_amt,
         cur_futures_rows.broker_comm_cur_id,
         cur_futures_rows.broker_cur_code,
         cur_futures_rows.clearer_profile_id,
         cur_futures_rows.clearer_name,
         cur_futures_rows.clearer_account_id,
         cur_futures_rows.clearer_account_name,
         cur_futures_rows.clearer_account_type,
         cur_futures_rows.clearer_comm_type_id,
         cur_futures_rows.clearer_comm_amt,
         cur_futures_rows.clearer_comm_cur_id,
         cur_futures_rows.clearer_cur_code,
         cur_futures_rows.product_id,
         cur_futures_rows.product,
         cur_futures_rows.quality_id,
         cur_futures_rows.quality_name,
         cur_futures_rows.trade_qty_unit_id,
         cur_futures_rows.quantityname,
         cur_futures_rows.lots_closed, --siva total_lots,
         cur_futures_rows.quantity_closed, -- total_quantity,
         cur_futures_rows.open_lots,
         cur_futures_rows.open_quantity,
         cur_futures_rows.exercised_lots,
         cur_futures_rows.exercised_quantity,
         cur_futures_rows.expired_lots,
         cur_futures_rows.expired_quantity,
         cur_futures_rows.trade_price_type_id,
         cur_futures_rows.trade_price,
         cur_futures_rows.trade_price_unit_id,
         cur_futures_rows.trade_cur_id,
         cur_futures_rows.trade_cur_code,
         cur_futures_rows.trade_weight,
         cur_futures_rows.trade_weight_unit_id,
         cur_futures_rows.trade_qty_unit,
         cur_futures_rows.formula_id,
         cur_futures_rows.formula_name,
         cur_futures_rows.formula_display,
         cur_futures_rows.index_instrument_id,
         cur_futures_rows.index_instrument_name,
         cur_futures_rows.strike_price,
         cur_futures_rows.strike_price_unit_id,
         cur_futures_rows.strike_cur_id,
         cur_futures_rows.strike_cur_code,
         cur_futures_rows.strike_weight,
         cur_futures_rows.strike_weight_unit_id,
         cur_futures_rows.strike_qty_unit,
         cur_futures_rows.premium_discount,
         cur_futures_rows.premium_discount_price_unit_id,
         cur_futures_rows.pd_cur_id,
         cur_futures_rows.pd_cur_code,
         cur_futures_rows.pd_weight,
         cur_futures_rows.pd_weight_unit_id,
         cur_futures_rows.pd_qty_unit,
         cur_futures_rows.premium_due_date,
         cur_futures_rows.nominee_profile_id,
         cur_futures_rows.nominee_name,
         cur_futures_rows.leg_no,
         cur_futures_rows.option_expiry_date,
         cur_futures_rows.parent_int_derivative_ref_no,
         cur_futures_rows.market_location_country,
         cur_futures_rows.market_location_state,
         cur_futures_rows.market_location_city,
         cur_futures_rows.is_what_if,
         cur_futures_rows.payment_term,
         cur_futures_rows.payment_term,
         cur_futures_rows.payment_due_date,
         cur_futures_rows.closed_lots,
         cur_futures_rows.closed_quantity,
         cur_futures_rows.is_new_trade_date,
         cur_futures_rows.status,
         cur_futures_rows.settlement_cur_id,
         cur_futures_rows.settlement_cur_code,
         cur_futures_rows.in_out_at_money_status,
         cur_futures_rows.in_out_at_money_value,
         cur_futures_rows.exercise_date,
         cur_futures_rows.expiry_date,
         cur_futures_rows.group_cur_id,
         cur_futures_rows.group_cur_code,
         cur_futures_rows.group_qty_unit_id,
         cur_futures_rows.gcd_qty_unit,
         cur_futures_rows.base_qty_unit_id,
         cur_futures_rows.base_qty_unit,
         cur_futures_rows.internal_close_out_ref_no,
         cur_futures_rows.close_out_ref_no,
         cur_futures_rows.close_out_date,
         vn_market_price_in_trade_cur,
         vc_settlement_price_unit_id,
         vc_settlement_cur_id,
         vc_settlement_cur_code,
         vc_settlement_weight,
         vc_settlement_weight_unit_id,
         vc_settlement_weight_unit,
         cur_futures_rows.parent_instrument_type,
         vn_clearer_comm_in_base_cur,
         vn_broker_comm_in_base_cur,
         vn_clr_cur_to_base_exch_rate,
         vn_brokr_cur_to_base_exch_rate,
         vn_trade_to_base_exch_rate,
         cur_futures_rows.pnl_type,
         vn_net_pnl_in_base_cur,
         vn_pnl_value_in_trade_cur,
         cur_futures_rows.base_cur_id,
         cur_futures_rows.base_cur_code,
         cur_futures_rows.underlying_future_dr_id,
         cur_futures_rows.underlying_future_dr_id_name,
         cur_futures_rows.underlying_future_expiry_date,
         cur_futures_rows.underlying_future_quote_price,
         cur_futures_rows.underlying_fut_price_unit_id,
         cur_futures_rows.process_id,
         vn_trade_qty_exch_unit);
    end loop;
  exception
  
    when others then
    
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_future_realized_pnl',
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

  procedure sp_calc_forward_unrealized_pnl(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_user_id      varchar2,
                                           pc_process      varchar2,
                                           pc_dbd_id       varchar2) is
    /******************************************************************************************************************************************
    procedure name                            : sp_calc_future_unrealized_pnl
    author                                    : janna
    created date                              : 10th jan 2009
    purpose                                   : calculate the unrealized pnl for futures as on eod date
    parameters                                :
    pc_corporate_id                           : corporate id
    pd_trade_date                             : eod date id
    pc_eod_ref_no                             : eod reference no
    modification history                      :
    modified date                             :
    modified by                               :
    modify description                        :
    ******************************************************************************************************************************************/
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
    cursor cur_futures is
      select dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             pd_trade_date eod_trade_date,
             dt.trade_date,
             dt.corporate_id,
             ak.corporate_name,
             dt.trader_id,
             gab.firstname || gab.lastname tradername,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dt.dr_id,
             drm.instrument_id,
             dim.instrument_name,
             dim.instrument_symbol,
             dim.instrument_type_id,
             irm.instrument_type,
             irm.instrument_display_name,
             dim.instrument_sub_type_id,
             istm.instrument_sub_type,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             pdd.traded_on,
             pdd.product_id,
             pdm.product_desc,
             emt.exchange_id,
             emt.exchange_name,
             emt.exchange_code,
             pdd.lot_size,
             pdd.lot_size_unit_id,
             qum.qty_unit lot_size_qty_unit,
             drm.price_point_id,
             pp.price_point_name,
             drm.period_type_id,
             pm.period_type_name,
             pm.period_type_display_name,
             drm.period_month,
             drm.period_year,
             (case
               when drm.period_date is null then
                (case
               when drm.period_month is not null and
                    drm.period_year is not null then
                to_date('01-' || drm.period_month || '-' || drm.period_year,
                        'dd-Mon-yyyy')
               else
                drm.prompt_date
             end) else drm.period_date end) period_date,
             drm.prompt_date,
             drm.dr_id_name,
             dt.trade_type,
             dt.deal_type_id,
             dtm.deal_type_name,
             dtm.deal_type_display_name,
             dtm.is_multiple_leg_involved,
             null deal_category,
             null deal_sub_category,
             dt.strategy_id,
             css.strategy_name,
             css.description,
             sdm.strategy_def_name,
             ak.groupid,
             gcd.groupname,
             dt.purpose_id,
             dpm.purpose_name,
             dpm.purpose_display_name,
             dt.external_ref_no,
             dt.cp_profile_id,
             phd_cp.companyname cp_name,
             dt.master_contract_id,
             dt.broker_profile_id,
             phd_broker.companyname broker_name,
             dt.broker_account_id,
             bca_broker.account_name broker_account_name,
             bca_broker.account_type broker_account_type,
             dt.broker_comm_type_id,
             dt.broker_comm_amt,
             dt.broker_comm_cur_id,
             cm_broker_cur.cur_code broker_cur_code,
             dt.clearer_profile_id,
             phd_clearer.companyname clearer_name,
             dt.clearer_account_id,
             bca_clearer.account_name clearer_account_name,
             bca_clearer.account_type clearer_account_type,
             dt.clearer_comm_type_id,
             dt.clearer_comm_amt,
             dt.clearer_comm_cur_id,
             cm_clearer.cur_code clearer_cur_code,
             dt.product_id product,
             pdm.product_desc productdesc,
             dt.quality_id,
             qat.quality_name,
             qat.gravity,
             gtm.gravity_type_name gravity_type,
             qat.density_mass_qty_unit_id,
             qat.density_volume_qty_unit_id,
             dt.quantity_unit_id,
             qum_um.qty_unit quantityname,
             dt.total_lots,
             dt.total_quantity,
             dt.open_lots,
             dt.open_quantity,
             dt.exercised_lots,
             dt.exercised_quantity,
             dt.expired_lots,
             dt.expired_quantity,
             dt.trade_price_type_id,
             dt.trade_price,
             dt.trade_price_unit_id,
             pum_trade.cur_id trade_cur_id,
             pum_trade.price_unit_name trade_price_unit_name,
             cm_trade.cur_code trade_price_cur_code,
             pum_trade.weight trade_weight,
             pum_trade.weight_unit_id trade_weight_unit_id,
             qum_trade.qty_unit trade_weight_unit,
             dt.formula_id,
             fbs.formula_name,
             fbs.formula_display,
             dt.index_instrument_id,
             dim_index.instrument_name index_instrument_name,
             dt.strike_price,
             dt.strike_price_unit_id,
             pum_strike.cur_id strike_cur_id,
             cm_strike.cur_code strike_cur_code,
             pum_strike.weight strike_weight,
             pum_strike.weight_unit_id strike_weight_unit_id,
             qum_strike.qty_unit strike_qty_unit,
             dt.premium_discount,
             dt.premium_discount_price_unit_id,
             pum_pd.cur_id pd_cur_id,
             cm_pd.cur_code pd_cur_code,
             pum_pd.weight pd_weight,
             pum_pd.weight_unit_id pd_weight_unit_id,
             qum_pd.qty_unit pd_qty_unit,
             dt.premium_due_date,
             dt.nominee_profile_id,
             phd_nominee.companyname nominee_name,
             dt.leg_no,
             dt.option_expiry_date,
             dt.parent_int_derivative_ref_no,
             dt.market_location_country,
             dt.market_location_state,
             dt.market_location_city,
             dt.is_what_if,
             dt.payment_term,
             pym.payment_term payment_term_name,
             dt.payment_due_date,
             dt.closed_lots,
             dt.closed_quantity,
             null as is_new_trade_date,
             dt.status,
             dt.settlement_cur_id,
             cm_settlement.cur_code settlement_cur_code,
             null as in_out_at_money_status,
             null as in_out_at_money_value,
             null as exercise_date,
             null as expiry_date,
             gcd_group.group_cur_id,
             cm_gcd.cur_code group_cur_code,
             gcd_group.group_qty_unit_id,
             qum_gcd.qty_unit gcd_qty_unit,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             null internal_close_out_ref_no,
             null close_out_ref_no,
             null close_out_date,
             edq.price settlement_price,
             edq.price_unit_id settlement_price_unit_id,
             pum_settle.cur_id settlement_price_cur_id,
             cm_settle.cur_code settlemet_price_cur_code,
             pum_settle.weight settlement_price_weight,
             pum_settle.weight_unit_id settlement_weight_unit_id,
             qum_settle.qty_unit settlement_weight_unit,
             (case
               when irm.instrument_type in ('Option Put', 'Option Call') then
                'Option'
               else
                irm.instrument_type
             end) as parent_instrument_type,
             null as clearer_comm_in_base,
             null as broker_comm_in_base,
             null as clearer_exch_rate,
             null as broker_exch_rate,
             null as trade_cur_to_base_exch_rate,
             'Unrealized' as pnl_type,
             null as pnl_in_base_cur,
             null as pnl_in_trade_cur,
             cm_base.cur_id as base_cur_id,
             ak.base_currency_name base_cur_code,
             null as underlying_future_dr_id,
             null as underlying_future_dr_id_name,
             null as underlying_future_expiry_date,
             null as underlying_future_quote_price,
             null as underlying_fut_price_unit_id,
             pc_process_id process_id
      
        from dt_derivative_trade            dt,
             ak_corporate                   ak,
             ak_corporate_user              aku,
             gab_globaladdressbook          gab,
             cpc_corporate_profit_center    cpc,
             drm_derivative_master          drm,
             dim_der_instrument_master      dim,
             irm_instrument_type_master     irm,
             istm_instr_sub_type_master     istm,
             pdd_product_derivative_def     pdd,
             pdm_productmaster              pdm,
             emt_exchangemaster             emt,
             qum_quantity_unit_master       qum,
             pp_price_point                 pp,
             pm_period_master               pm,
             dtm_deal_type_master           dtm,
             css_corporate_strategy_setup   css,
             sdm_strategy_definition_master sdm,
             gcd_groupcorporatedetails      gcd,
             dpm_derivative_purpose_master  dpm,
             phd_profileheaderdetails       phd_cp,
             phd_profileheaderdetails       phd_broker,
             bca_broker_clearer_account     bca_broker,
             cm_currency_master             cm_broker_cur,
             phd_profileheaderdetails       phd_clearer,
             bca_broker_clearer_account     bca_clearer,
             cm_currency_master             cm_clearer,
             qat_quality_attributes         qat,
             gtm_gravity_type_master        gtm,
             qum_quantity_unit_master       qum_um,
             pum_price_unit_master          pum_trade,
             cm_currency_master             cm_trade,
             qum_quantity_unit_master       qum_trade,
             fbs_formula_builder_setup      fbs,
             dim_der_instrument_master      dim_index,
             pum_price_unit_master          pum_strike,
             cm_currency_master             cm_strike,
             qum_quantity_unit_master       qum_strike,
             pum_price_unit_master          pum_pd,
             cm_currency_master             cm_pd,
             qum_quantity_unit_master       qum_pd,
             phd_profileheaderdetails       phd_nominee,
             pym_payment_terms_master       pym,
             cm_currency_master             cm_settlement,
             gcd_groupcorporatedetails      gcd_group,
             cm_currency_master             cm_gcd,
             qum_quantity_unit_master       qum_gcd,
             qum_quantity_unit_master       qum_pdm,
             eodeom_derivative_quote_detail edq,
             apm_available_price_master     apm,
             div_der_instrument_valuation   div,
             pum_price_unit_master          pum_settle,
             cm_currency_master             cm_settle,
             qum_quantity_unit_master       qum_settle,
             cm_currency_master             cm_base
       where dt.corporate_id = ak.corporate_id
         and dt.trader_id = aku.user_id
         and aku.gabid = gab.gabid
         and dt.profit_center_id = cpc.profit_center_id
         and dt.dr_id = drm.dr_id(+)
         and drm.instrument_id = dim.instrument_id(+)
         and dim.instrument_type_id = irm.instrument_type_id(+)
         and dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
         and dim.product_derivative_id = pdd.derivative_def_id(+)
         and pdd.product_id = pdm.product_id(+)
         and pdd.exchange_id = emt.exchange_id(+)
         and pdd.lot_size_unit_id = qum.qty_unit_id(+)
         and drm.price_point_id = pp.price_point_id(+)
         and drm.period_type_id = pm.period_type_id(+)
         and dt.deal_type_id = dtm.deal_type_id
         and dt.strategy_id = css.strategy_id
         and css.strategy_def_id = sdm.strategy_def_id
         and ak.groupid = gcd.groupid
         and dt.purpose_id = dpm.purpose_id
         and dt.cp_profile_id = phd_cp.profileid(+)
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.broker_account_id = bca_broker.account_id(+)
         and dt.broker_comm_cur_id = cm_broker_cur.cur_id(+)
         and dt.clearer_profile_id = phd_clearer.profileid(+)
         and dt.clearer_account_id = bca_clearer.account_id(+)
         and dt.clearer_comm_cur_id = cm_clearer.cur_id(+)
         and dt.quality_id = qat.quality_id(+)
         and qat.gravity_type_id = gtm.gravity_type_id(+)
         and dt.quantity_unit_id = qum_um.qty_unit_id
         and dt.trade_price_unit_id = pum_trade.price_unit_id(+)
         and pum_trade.cur_id = cm_trade.cur_id(+)
         and pum_trade.weight_unit_id = qum_trade.qty_unit_id(+)
         and dt.formula_id = fbs.formula_id(+)
         and dt.index_instrument_id = dim_index.instrument_id(+)
         and dt.strike_price_unit_id = pum_strike.price_unit_id(+)
         and pum_strike.cur_id = cm_strike.cur_id(+)
         and pum_strike.weight_unit_id = qum_strike.qty_unit_id(+)
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and pum_pd.cur_id = cm_pd.cur_id(+)
         and pum_pd.weight_unit_id = qum_pd.qty_unit_id(+)
         and dt.nominee_profile_id = phd_nominee.profileid(+)
         and dt.payment_term = pym.payment_term_id(+)
         and dt.settlement_cur_id = cm_settlement.cur_id(+)
         and ak.groupid=gcd_group.groupid
         and gcd_group.group_cur_id = cm_gcd.cur_id
         and gcd_group.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id(+)
         and dt.process_id = edq.process_id
         and dt.dr_id = edq.dr_id
         and edq.available_price_id = apm.available_price_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and edq.available_price_id = div.available_price_id
         and edq.price_unit_id = div.price_unit_id
            --   and apm.available_price_name = 'Settlement'
         and apm.is_active = 'Y'
         and apm.is_deleted = 'N'
         and edq.price_unit_id = pum_settle.price_unit_id(+)
         and pum_settle.cur_id = cm_settle.cur_id(+)
         and pum_settle.weight_unit_id = qum_settle.qty_unit_id(+)
         and ak.base_currency_name = cm_base.cur_code(+)
         and irm.instrument_type = 'Forward'
         and upper(dt.status) = 'VERIFIED'
         and dtm.deal_type_display_name not like '%Swap%'
         and dt.is_what_if = 'N'
         and dt.corporate_id = pc_corporate_id
         and dt.open_quantity > 0
         and dt.trade_date <= pd_trade_date
         and dt.process_id = pc_process_id;
  
    vn_total_trade_value_base_cur  number;
    vn_pnl_value_in_trade_cur      number;
    vn_trade_to_base_exch_rate     number;
    vn_pnl_value_in_base_cur       number;
    vn_broker_comm_in_base_cur     number;
    vn_clr_comm_in_base_cur        number;
    vn_net_pnl_in_base_cur         number;
    vn_brokr_cur_to_base_exch_rate number;
    vn_clr_cur_to_base_exch_rate   number;
    vn_qty_in_trade_wt_unit        number;
    vn_market_price_in_trade_cur   number;
    vn_total_market_val_trade_cur  number;
    vn_trade_price_in_trade_cur    number;
    vn_total_trade_value_trade_cur number;
    vn_trade_qty_exch_unit         number;
    vn_trade_price                 number;
    vc_trade_price_unit_id         varchar2(15);
    vt_tbl_frm_setup               fb_tbl_setup;
    vt_tbl_frm_instrument          fb_tbl_instrument_data;
    vt_tbl_frm_instrument_out      fb_tbl_instrument_data;
    vt_tbl_frm_setup_out           fb_tbl_setup;
    vt_fb_tbl_frm_error_out        fb_tbl_error;
    vt_tbl_ind_setup               fb_tbl_setup;
    vt_tbl_ind_instrument          fb_tbl_instrument_data;
    vt_tbl_ind_instrument_out      fb_tbl_instrument_data;
    vt_tbl_ind_setup_out           fb_tbl_setup;
    vt_fb_tbl_ind_error_out        fb_tbl_error;
    vn_cur_row_cnt                 number;
    vn_fb_order_sq                 number := 1;
    vc_trade_price_cur_id          varchar2(15);
    vc_trade_price_cur_code        varchar2(15);
    vc_trade_price_unit_name       varchar2(50);
    vn_trade_price_weight          number(7, 2);
    vc_trade_price_weight_unit_id  varchar2(15);
    vc_trade_price_weight_unit     varchar2(15);
  
  begin
    for cur_futures_rows in cur_futures
    loop
      vt_tbl_frm_setup          := fb_tbl_setup();
      vt_tbl_frm_instrument     := fb_tbl_instrument_data();
      vt_tbl_frm_instrument_out := fb_tbl_instrument_data();
      vt_tbl_frm_setup_out      := fb_tbl_setup();
      vt_fb_tbl_frm_error_out   := fb_tbl_error();
      vt_tbl_ind_setup          := fb_tbl_setup();
      vt_tbl_ind_instrument     := fb_tbl_instrument_data();
      vt_tbl_ind_instrument_out := fb_tbl_instrument_data();
      vt_tbl_ind_setup_out      := fb_tbl_setup();
      vt_fb_tbl_ind_error_out   := fb_tbl_error();
      -- dbms_output.put_line('refno '|| cur_futures_rows.derivative_ref_no || ' price type '|| cur_futures_rows.trade_price_type_id);
      vn_trade_price                := null;
      vc_trade_price_unit_id        := null;
      vc_trade_price_cur_id         := null;
      vc_trade_price_cur_code       := null;
      vn_trade_price_weight         := null;
      vc_trade_price_weight_unit_id := null;
      vc_trade_price_weight_unit    := null;
    
      if cur_futures_rows.trade_price_type_id = 'Fixed' then
        vn_trade_price                := cur_futures_rows.trade_price;
        vc_trade_price_unit_id        := cur_futures_rows.trade_price_unit_id;
        vc_trade_price_unit_name      := cur_futures_rows.trade_price_unit_name;
        vc_trade_price_cur_id         := cur_futures_rows.trade_cur_id;
        vn_trade_price_weight         := cur_futures_rows.trade_weight;
        vc_trade_price_weight_unit_id := cur_futures_rows.trade_weight_unit_id;
        vc_trade_price_cur_code       := cur_futures_rows.trade_price_cur_code;
        vc_trade_price_weight_unit    := cur_futures_rows.trade_weight_unit;
      elsif cur_futures_rows.trade_price_type_id = 'Formula' then
        vn_fb_order_sq := 1;
        vn_cur_row_cnt := 1;
      
        for cc in (select fbs.formula_internal,
                          fbs.formula_display,
                          fbs.formula_name,
                          fbs.formula_id,
                          fbs.price_unit_id
                     from fbs_formula_builder_setup fbs
                    where fbs.formula_id = cur_futures_rows.formula_id)
        loop
        
          vt_tbl_frm_setup.extend;
          vt_tbl_frm_setup(1) := fb_typ_setup(cc.formula_id,
                                              pc_corporate_id,
                                              cc.formula_name,
                                              cc.formula_display,
                                              cc.formula_internal,
                                              cc.price_unit_id,
                                              pd_trade_date,
                                              null,
                                              null,
                                              null,
                                              null);
        end loop;
        for cc1 in (select dtfbi.instrument_id,
                           dtfbi.price_source_id,
                           dtfbi.price_point_id,
                           dtfbi.available_price_id,
                           dtfbi.fb_period_type,
                           dtfbi.fb_period_sub_type,
                           dtfbi.period_month,
                           dtfbi.period_year,
                           dtfbi.period_from_date,
                           dtfbi.period_to_date,
                           dtfbi.no_of_months,
                           dtfbi.no_of_days,
                           dtfbi.period_type_id,
                           dtfbi.delivery_period_id,
                           dtfbi.off_day_price,
                           dtfbi.basis,
                           dtfbi.basis_price_unit_id,
                           dtfbi.fx_rate_type,
                           dtfbi.fx_rate_
                      from dt_fbi dtfbi
                     where dtfbi.internal_derivative_ref_no =
                           cur_futures_rows.internal_derivative_ref_no
                       and dtfbi.is_deleted = 'N'
                       and dtfbi.process_id = pc_process_id)
        loop
          vn_fb_order_sq := 1;
          vt_tbl_frm_instrument.extend;
          vt_tbl_frm_instrument(vn_cur_row_cnt) := fb_typ_instrument_data(vn_fb_order_sq,
                                                                          cur_futures_rows.formula_id,
                                                                          cc1.instrument_id,
                                                                          cc1.price_source_id,
                                                                          cc1.price_point_id,
                                                                          cc1.available_price_id,
                                                                          cc1.fb_period_type,
                                                                          cc1.fb_period_sub_type,
                                                                          cc1.period_month,
                                                                          cc1.period_year,
                                                                          cc1.period_from_date,
                                                                          cc1.period_to_date,
                                                                          cc1.no_of_months,
                                                                          cc1.no_of_days,
                                                                          cc1.period_type_id,
                                                                          cc1.delivery_period_id,
                                                                          cc1.off_day_price,
                                                                          cc1.basis,
                                                                          cc1.basis_price_unit_id,
                                                                          cc1.fx_rate_type,
                                                                          cc1.fx_rate_,
                                                                          null,
                                                                          null,
                                                                          null,
                                                                          null,
                                                                          null);
          vn_fb_order_sq := vn_fb_order_sq + 1;
          vn_cur_row_cnt := vn_cur_row_cnt + 1;
        end loop;
        pkg_cdc_formula_builder.sp_calculate_price(vt_tbl_frm_setup,
                                                   vt_tbl_frm_instrument,
                                                   vt_tbl_frm_setup_out,
                                                   vt_tbl_frm_instrument_out,
                                                   vt_fb_tbl_frm_error_out,
                                                   pc_dbd_id,
                                                   cur_futures_rows.derivative_ref_no);
      
        for i in vt_tbl_frm_setup_out.first .. vt_tbl_frm_setup_out.last
        loop
          vn_trade_price         := vt_tbl_frm_setup_out(i).fb_price;
          vc_trade_price_unit_id := vt_tbl_frm_setup_out(i).price_unit_id;
          /*dbms_output.put_line('vn_trade_price ' || vn_trade_price);
          dbms_output.put_line('vc_trade_price_unit_id ' ||
                               vc_trade_price_unit_id);*/
        
        end loop;
      
      elsif cur_futures_rows.trade_price_type_id = 'Index' then
        vn_fb_order_sq := 1;
        vn_cur_row_cnt := 1;
        for cc1 in (select dtfbi.instrument_id,
                           dtfbi.price_source_id,
                           dtfbi.price_point_id,
                           dtfbi.available_price_id,
                           dtfbi.fb_period_type,
                           dtfbi.fb_period_sub_type,
                           dtfbi.period_month,
                           dtfbi.period_year,
                           dtfbi.period_from_date,
                           dtfbi.period_to_date,
                           dtfbi.no_of_months,
                           dtfbi.no_of_days,
                           dtfbi.period_type_id,
                           dtfbi.delivery_period_id,
                           dtfbi.off_day_price,
                           dtfbi.basis,
                           dtfbi.basis_price_unit_id,
                           dtfbi.fx_rate_type,
                           dtfbi.fx_rate_
                      from dt_fbi dtfbi
                     where dtfbi.internal_derivative_ref_no =
                           cur_futures_rows.internal_derivative_ref_no
                       and dtfbi.is_deleted = 'N'
                       and dtfbi.process_id = pc_process_id)
        loop
        
          vt_tbl_ind_setup.extend;
          vt_tbl_ind_setup(1) := fb_typ_setup(cc1.instrument_id,
                                              pc_corporate_id,
                                              'index',
                                              'index',
                                              '$' || cc1.instrument_id || '$',
                                              cc1.basis_price_unit_id,
                                              pd_trade_date,
                                              null,
                                              null,
                                              null,
                                              null);
        
          vt_tbl_ind_instrument.extend;
          vt_tbl_ind_instrument(vn_cur_row_cnt) := fb_typ_instrument_data(vn_fb_order_sq,
                                                                          cc1.instrument_id,
                                                                          cc1.instrument_id,
                                                                          cc1.price_source_id,
                                                                          cc1.price_point_id,
                                                                          cc1.available_price_id,
                                                                          cc1.fb_period_type,
                                                                          cc1.fb_period_sub_type,
                                                                          cc1.period_month,
                                                                          cc1.period_year,
                                                                          cc1.period_from_date,
                                                                          cc1.period_to_date,
                                                                          cc1.no_of_months,
                                                                          cc1.no_of_days,
                                                                          cc1.period_type_id,
                                                                          cc1.delivery_period_id,
                                                                          cc1.off_day_price,
                                                                          cc1.basis,
                                                                          cc1.basis_price_unit_id,
                                                                          cc1.fx_rate_type,
                                                                          cc1.fx_rate_,
                                                                          null,
                                                                          null,
                                                                          null,
                                                                          null,
                                                                          null);
          vn_fb_order_sq := vn_fb_order_sq + 1;
          vn_cur_row_cnt := vn_cur_row_cnt + 1;
        end loop;
      
        pkg_cdc_formula_builder.sp_calculate_price(vt_tbl_ind_setup,
                                                   vt_tbl_ind_instrument,
                                                   vt_tbl_ind_setup_out,
                                                   vt_tbl_ind_instrument_out,
                                                   vt_fb_tbl_ind_error_out,
                                                   pc_dbd_id,
                                                   cur_futures_rows.derivative_ref_no);
      
        for i in vt_tbl_ind_setup_out.first .. vt_tbl_ind_setup_out.last
        loop
          vn_trade_price         := vt_tbl_ind_setup_out(i).fb_price;
          vc_trade_price_unit_id := vt_tbl_ind_setup_out(i).price_unit_id;
          /*
          dbms_output.put_line('vn_trade_price ' || vn_trade_price);
          dbms_output.put_line('vc_trade_price_unit_id ' ||
                               vc_trade_price_unit_id);*/
        end loop;
      else
        vn_trade_price         := 0;
        vc_trade_price_unit_id := null;
      end if;
    
      if cur_futures_rows.trade_price_type_id <> 'Fixed' then
        begin
          select pum.price_unit_name,
                 pum.cur_id,
                 pum.weight,
                 pum.weight_unit_id,
                 cm.cur_code,
                 qum.qty_unit
            into vc_trade_price_unit_name,
                 vc_trade_price_cur_id,
                 vn_trade_price_weight,
                 vc_trade_price_weight_unit_id,
                 vc_trade_price_cur_code,
                 vc_trade_price_weight_unit
            from v_ppu_pum                pum,
                 cm_currency_master       cm,
                 qum_quantity_unit_master qum
           where pum.product_price_unit_id = vc_trade_price_unit_id
             and pum.cur_id = cm.cur_id
             and pum.weight_unit_id = qum.qty_unit_id;
        exception
          when no_data_found then
            vc_trade_price_cur_id         := null;
            vc_trade_price_unit_name      := null;
            vn_trade_price_weight         := null;
            vc_trade_price_weight_unit_id := null;
            vc_trade_price_cur_code       := null;
            vc_trade_price_weight_unit    := null;
        end;
      end if;
      /*dbms_output.put_line('vc_trade_price_unit_name' ||
      vc_trade_price_unit_name || '- ' ||
      vc_trade_price_weight_unit_id);*/
    
      -- Trade Qty in Exchange Weight Unit
      if cur_futures_rows.gravity is not null then
        if cur_futures_rows.quantity_unit_id <>
           cur_futures_rows.lot_size_unit_id then
          vn_trade_qty_exch_unit := pkg_general.fn_mass_volume_qty_conversion(cur_futures_rows.product_id,
                                                                              cur_futures_rows.quantity_unit_id,
                                                                              cur_futures_rows.lot_size_unit_id,
                                                                              cur_futures_rows.open_quantity,
                                                                              cur_futures_rows.gravity,
                                                                              cur_futures_rows.gravity_type,
                                                                              cur_futures_rows.density_mass_qty_unit_id,
                                                                              cur_futures_rows.density_volume_qty_unit_id);
        else
          vn_trade_qty_exch_unit := pkg_general.f_get_converted_quantity(null,
                                                                         cur_futures_rows.quantity_unit_id,
                                                                         cur_futures_rows.lot_size_unit_id,
                                                                         cur_futures_rows.open_quantity);
        
        end if;
      end if;
      /*get the exchange rates
      1. from broker to base currency
      2. trade to base currency
      */
    
      vn_trade_to_base_exch_rate     := f_currency_exchange_rate(pd_trade_date,
                                                                 pc_corporate_id,
                                                                 cur_futures_rows.prompt_date,
                                                                 vc_trade_price_cur_id,
                                                                 cur_futures_rows.base_cur_id);
      vn_brokr_cur_to_base_exch_rate := f_currency_exchange_rate(pd_trade_date,
                                                                 pc_corporate_id,
                                                                 cur_futures_rows.prompt_date,
                                                                 cur_futures_rows.broker_comm_cur_id,
                                                                 cur_futures_rows.base_cur_id);
      vn_clr_cur_to_base_exch_rate   := f_currency_exchange_rate(pd_trade_date,
                                                                 pc_corporate_id,
                                                                 cur_futures_rows.prompt_date,
                                                                 cur_futures_rows.clearer_comm_cur_id,
                                                                 cur_futures_rows.base_cur_id);
    
      /*
      calcualate trade pnl in trade currency
      1. convert trade qty from trade price unit weight unit to trade weight unit
      2. get the market price in trade currency
      3. market value in trade currency = qty in trade weight unit(1) * market price in trade currency(2)
      4. trade value in trade currency = trade price in trade currency (from drt) * trade qty in trade unit(1)
      5. pnl in trade currency = market value in trade currency(2) - trade value in trade currency(4)*/
    
      /* commented code since from and to is reveresed 18-jul-2009
      vn_qty_in_trade_wt_unit      := f_get_converted_quantity(null, --product id
                                                                           cur_futures_rows.weight_unit_id,
                                                                           cur_futures_rows.trade_qty_unit_id,
                                                                           cur_futures_rows.trade_qty); */
      if cur_futures_rows.gravity is not null then
        vn_qty_in_trade_wt_unit := pkg_general.fn_mass_volume_qty_conversion(cur_futures_rows.product_id,
                                                                             cur_futures_rows.quantity_unit_id,
                                                                             vc_trade_price_weight_unit_id,
                                                                             cur_futures_rows.open_quantity,
                                                                             cur_futures_rows.gravity,
                                                                             cur_futures_rows.gravity_type,
                                                                             cur_futures_rows.density_mass_qty_unit_id,
                                                                             cur_futures_rows.density_volume_qty_unit_id);
      
      else
        vn_qty_in_trade_wt_unit := f_get_converted_quantity(null, --product id
                                                            cur_futures_rows.quantity_unit_id,
                                                            vc_trade_price_weight_unit_id,
                                                            cur_futures_rows.open_quantity
                                                            -- this we added for drt changes. bhairu
                                                            --cur_futures_rows.trade_qty-nvl(cur_futures_rows.quantity_closed,0)
                                                            );
      end if;
    
      --preeti fix for open lots
      -- vn_market_price_in_trade_cur := cur_futures_rows.settlement_price;
      if cur_futures_rows.gravity is not null then
        vn_market_price_in_trade_cur := (cur_futures_rows.settlement_price /
                                        nvl(cur_futures_rows.settlement_price_weight,
                                             1)) *
                                        pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                 cur_futures_rows.settlement_price_cur_id,
                                                                                 vc_trade_price_cur_id,
                                                                                 pd_trade_date,
                                                                                 1) *
                                        (pkg_general.fn_mass_volume_qty_conversion(cur_futures_rows.product_id,
                                                                                   cur_futures_rows.settlement_weight_unit_id,
                                                                                   vc_trade_price_weight_unit_id,
                                                                                   1,
                                                                                   cur_futures_rows.gravity,
                                                                                   cur_futures_rows.gravity_type,
                                                                                   cur_futures_rows.density_mass_qty_unit_id,
                                                                                   cur_futures_rows.density_volume_qty_unit_id));
      
      else
        vn_market_price_in_trade_cur := (cur_futures_rows.settlement_price /
                                        nvl(cur_futures_rows.settlement_price_weight,
                                             1)) *
                                        pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                 cur_futures_rows.settlement_price_cur_id,
                                                                                 vc_trade_price_cur_id,
                                                                                 pd_trade_date,
                                                                                 1) *
                                        (pkg_general.f_get_converted_quantity(cur_futures_rows.product_id,
                                                                              cur_futures_rows.settlement_weight_unit_id,
                                                                              vc_trade_price_weight_unit_id,
                                                                              1));
      
      end if;
    
      /* he units will be the same since its defaulted in the screen
      vn_market_price_in_trade_cur   := vn_market_price_in_trade_cur *
                                            cur_futures_row(i).weight /
                                            (cur_futures_rows(i).ppu_dq_weight *
                                            pkg_general.f_get_converted_quantity(null,
                                                                                  cur_futures_rows.ppu_dq_weight_unit_id,
                                                                                  cur_futures_rows.weight_unit_id,
                                                                                  1));
       */
      vn_total_market_val_trade_cur := vn_market_price_in_trade_cur *
                                       vn_qty_in_trade_wt_unit;
    
      vn_trade_price_in_trade_cur := vn_trade_price;
    
      vn_total_trade_value_trade_cur := vn_trade_price_in_trade_cur *
                                        vn_qty_in_trade_wt_unit;
    
      /*
      for sales trades pnl = trade price - market price
      for buy trades pnl =  market price - trade price
      */
      if cur_futures_rows.trade_type = 'Buy' then
        vn_pnl_value_in_trade_cur := vn_total_market_val_trade_cur -
                                     vn_total_trade_value_trade_cur;
      else
        vn_pnl_value_in_trade_cur := vn_total_trade_value_trade_cur -
                                     vn_total_market_val_trade_cur;
      end if;
    
      /*
      calcualte net pnl in base currency
       1. calculate trade value in base currency
       a) convert trade qty to price unit weight unit
       b) multiply a by trade price
       c) multipy by trade to base exchange rate
       2. calcualate broker commission in base currency
       3. pnl value in base currency = pnl value in trade currency * exchange rate from trade to base
       4. net pnl in base currency = pnl value in base currency (3) - broker commission in base currency
       */
      vn_total_trade_value_base_cur := vn_trade_to_base_exch_rate *
                                       vn_total_trade_value_trade_cur;
    
      /* 18-jul-2009 . commented this and replaced this with above code
      vn_total_trade_value_base_cur := pkg_general.f_get_converted_quantity(null,
                                                                            cur_futures_rows.trade_qty_unit_id,
                                                                            cur_futures_rows.weight_unit_id,
                                                                            cur_futures_rows.trade_qty) *
                                       cur_futures_rows.trade_price *
                                       vn_trade_to_base_exch_rate; */
    
      vn_broker_comm_in_base_cur := cur_futures_rows.broker_comm_amt *
                                    vn_brokr_cur_to_base_exch_rate;
      vn_clr_comm_in_base_cur    := cur_futures_rows.clearer_comm_amt *
                                    vn_clr_cur_to_base_exch_rate;
      vn_pnl_value_in_base_cur   := vn_pnl_value_in_trade_cur *
                                    vn_trade_to_base_exch_rate;
      --Fix 10th Nov
      --vn_net_pnl_in_base_cur        := vn_pnl_value_in_base_cur -
      --                                 nvl(vn_broker_comm_in_base_cur,0) - nvl(vn_clr_comm_in_base_cur,0);
      vn_net_pnl_in_base_cur := vn_pnl_value_in_base_cur;
    
      --  all this check should be removed later
      if vn_net_pnl_in_base_cur is null then
        vn_net_pnl_in_base_cur := 0;
      end if;
    
      if vn_pnl_value_in_trade_cur is null then
        vn_pnl_value_in_trade_cur := 0;
      end if;
    
      insert into dpd_derivative_pnl_daily
        (internal_derivative_ref_no,
         derivative_ref_no,
         eod_trade_date,
         trade_date,
         corporate_id,
         corporate_name,
         trader_id,
         trader_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         dr_id,
         instrument_id,
         instrument_name,
         instrument_symbol,
         instrument_type_id,
         instrument_type,
         instrument_type_name,
         instrument_sub_type_id,
         instrument_sub_type,
         derivative_def_id,
         derivative_def_name,
         derivative_traded_on,
         derivative_prodct_id,
         derivative_prodct_name,
         exchange_id,
         exchange_name,
         exchange_code,
         lot_size,
         lot_size_unit_id,
         lot_size_unit,
         price_point_id,
         price_point_name,
         period_type_id,
         period_type_name,
         period_type_display_name,
         period_month,
         period_year,
         period_date,
         prompt_date,
         dr_id_name,
         trade_type,
         deal_type_id,
         deal_type_name,
         deal_type_display_name,
         is_multiple_leg_involved,
         deal_category,
         deal_sub_category,
         strategy_id,
         strategy_name,
         strategy_desc,
         strategy_def_name,
         group_id,
         group_name,
         purpose_id,
         purpose_name,
         purpose_display_name,
         external_ref_no,
         cp_profile_id,
         cp_name,
         master_contract_id,
         broker_profile_id,
         broker_name,
         broker_account_id,
         broker_account_name,
         broker_account_type,
         broker_comm_type_id,
         broker_comm_amt,
         broker_comm_cur_id,
         broker_comm_cur_code,
         clearer_profile_id,
         clearer_name,
         clearer_account_id,
         clearer_account_name,
         clearer_account_type,
         clearer_comm_type_id,
         clearer_comm_amt,
         clearer_comm_cur_id,
         clearer_comm_cur_code,
         product_id,
         product_name,
         quality_id,
         quality_name,
         quantity_unit_id,
         quantity_unit,
         total_lots,
         total_quantity,
         open_lots,
         open_quantity,
         exercised_lots,
         exercised_quantity,
         expired_lots,
         expired_quantity,
         trade_price_type_id,
         trade_price,
         trade_price_unit_id,
         trade_price_cur_id,
         trade_price_cur_code,
         trade_price_weight,
         trade_price_weight_unit_id,
         trade_price_weight_unit,
         formula_id,
         formula_name,
         formula_display,
         index_instrument_id,
         index_instrument_name,
         strike_price,
         strike_price_unit_id,
         strike_price_cur_id,
         strike_price_cur_code,
         strike_price_weight,
         strike_price_weight_unit_id,
         strike_price_weight_unit,
         premium_discount,
         premium_discount_price_unit_id,
         pd_price_cur_id,
         pd_price_cur_code,
         pd_price_weight,
         pd_price_weight_unit_id,
         pd_price_weight_unit,
         premium_due_date,
         nominee_profile_id,
         nominee_name,
         leg_no,
         option_expiry_date,
         parent_int_derivative_ref_no,
         market_location_country,
         market_location_state,
         market_location_city,
         is_what_if,
         payment_term_id,
         payment_term,
         payment_due_date,
         closed_lots,
         closed_quantity,
         is_new_trade,
         status,
         settlement_cur_id,
         settlement_cur_code,
         in_out_at_money_status,
         in_out_at_money_value,
         exercise_date,
         expiry_date,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         internal_close_out_ref_no,
         close_out_ref_no,
         close_out_date,
         settlement_price,
         sett_price_unit_id,
         sett_price_cur_id,
         sett_price_cur_code,
         sett_price_weight,
         sett_price_weight_unit_id,
         sett_price_weight_unit,
         parent_instrument_type,
         clearer_comm_in_base,
         broker_comm_in_base,
         clearer_exch_rate,
         broker_exch_rate,
         trade_cur_to_base_exch_rate,
         pnl_type,
         pnl_in_base_cur,
         pnl_in_trade_cur,
         base_cur_id,
         base_cur_code,
         underlying_future_dr_id,
         underlying_future_dr_id_name,
         underlying_future_expiry_date,
         underlying_future_quote_price,
         underlying_fut_price_unit_id,
         process_id,
         trade_qty_in_exch_unit)
      
      values
        (cur_futures_rows.internal_derivative_ref_no,
         cur_futures_rows.derivative_ref_no,
         cur_futures_rows.eod_trade_date,
         cur_futures_rows.trade_date,
         cur_futures_rows.corporate_id,
         cur_futures_rows.corporate_name,
         cur_futures_rows.trader_id,
         cur_futures_rows.tradername,
         cur_futures_rows.profit_center_id,
         cur_futures_rows.profit_center_name,
         cur_futures_rows.profit_center_short_name,
         cur_futures_rows.dr_id,
         cur_futures_rows.instrument_id,
         cur_futures_rows.instrument_name,
         cur_futures_rows.instrument_symbol,
         cur_futures_rows.instrument_type_id,
         cur_futures_rows.instrument_type,
         cur_futures_rows.instrument_display_name,
         cur_futures_rows.instrument_sub_type_id,
         cur_futures_rows.instrument_sub_type,
         cur_futures_rows.derivative_def_id,
         cur_futures_rows.derivative_def_name,
         cur_futures_rows.traded_on,
         cur_futures_rows.product_id,
         cur_futures_rows.product_desc,
         cur_futures_rows.exchange_id,
         cur_futures_rows.exchange_name,
         cur_futures_rows.exchange_code,
         cur_futures_rows.lot_size,
         cur_futures_rows.lot_size_unit_id,
         cur_futures_rows.lot_size_qty_unit,
         cur_futures_rows.price_point_id,
         cur_futures_rows.price_point_name,
         cur_futures_rows.period_type_id,
         cur_futures_rows.period_type_name,
         cur_futures_rows.period_type_display_name,
         cur_futures_rows.period_month,
         cur_futures_rows.period_year,
         cur_futures_rows.period_date,
         cur_futures_rows.prompt_date,
         cur_futures_rows.dr_id_name,
         cur_futures_rows.trade_type,
         cur_futures_rows.deal_type_id,
         cur_futures_rows.deal_type_name,
         cur_futures_rows.deal_type_display_name,
         cur_futures_rows.is_multiple_leg_involved,
         cur_futures_rows.deal_category,
         cur_futures_rows.deal_sub_category,
         cur_futures_rows.strategy_id,
         cur_futures_rows.strategy_name,
         cur_futures_rows.description,
         cur_futures_rows.strategy_def_name,
         cur_futures_rows.groupid,
         cur_futures_rows.groupname,
         cur_futures_rows.purpose_id,
         cur_futures_rows.purpose_name,
         cur_futures_rows.purpose_display_name,
         cur_futures_rows.external_ref_no,
         cur_futures_rows.cp_profile_id,
         cur_futures_rows.cp_name,
         cur_futures_rows.master_contract_id,
         cur_futures_rows.broker_profile_id,
         cur_futures_rows.broker_name,
         cur_futures_rows.broker_account_id,
         cur_futures_rows.broker_account_name,
         cur_futures_rows.broker_account_type,
         cur_futures_rows.broker_comm_type_id,
         cur_futures_rows.broker_comm_amt,
         cur_futures_rows.broker_comm_cur_id,
         cur_futures_rows.broker_cur_code,
         cur_futures_rows.clearer_profile_id,
         cur_futures_rows.clearer_name,
         cur_futures_rows.clearer_account_id,
         cur_futures_rows.clearer_account_name,
         cur_futures_rows.clearer_account_type,
         cur_futures_rows.clearer_comm_type_id,
         cur_futures_rows.clearer_comm_amt,
         cur_futures_rows.clearer_comm_cur_id,
         cur_futures_rows.clearer_cur_code,
         cur_futures_rows.product_id,
         cur_futures_rows.product,
         cur_futures_rows.quality_id,
         cur_futures_rows.quality_name,
         cur_futures_rows.quantity_unit_id,
         cur_futures_rows.quantityname,
         cur_futures_rows.open_lots, -- total_lots,--siva
         cur_futures_rows.open_quantity, -- .total_quantity,--siva
         cur_futures_rows.open_lots,
         cur_futures_rows.open_quantity,
         cur_futures_rows.exercised_lots,
         cur_futures_rows.exercised_quantity,
         cur_futures_rows.expired_lots,
         cur_futures_rows.expired_quantity,
         cur_futures_rows.trade_price_type_id,
         vn_trade_price,
         vc_trade_price_unit_id,
         vc_trade_price_cur_id,
         vc_trade_price_cur_code,
         vn_trade_price_weight,
         vc_trade_price_weight_unit_id,
         vc_trade_price_weight_unit,
         cur_futures_rows.formula_id,
         cur_futures_rows.formula_name,
         cur_futures_rows.formula_display,
         cur_futures_rows.index_instrument_id,
         cur_futures_rows.index_instrument_name,
         cur_futures_rows.strike_price,
         cur_futures_rows.strike_price_unit_id,
         cur_futures_rows.strike_cur_id,
         cur_futures_rows.strike_cur_code,
         cur_futures_rows.strike_weight,
         cur_futures_rows.strike_weight_unit_id,
         cur_futures_rows.strike_qty_unit,
         cur_futures_rows.premium_discount,
         cur_futures_rows.premium_discount_price_unit_id,
         cur_futures_rows.pd_cur_id,
         cur_futures_rows.pd_cur_code,
         cur_futures_rows.pd_weight,
         cur_futures_rows.pd_weight_unit_id,
         cur_futures_rows.pd_qty_unit,
         cur_futures_rows.premium_due_date,
         cur_futures_rows.nominee_profile_id,
         cur_futures_rows.nominee_name,
         cur_futures_rows.leg_no,
         cur_futures_rows.option_expiry_date,
         cur_futures_rows.parent_int_derivative_ref_no,
         cur_futures_rows.market_location_country,
         cur_futures_rows.market_location_state,
         cur_futures_rows.market_location_city,
         cur_futures_rows.is_what_if,
         cur_futures_rows.payment_term,
         cur_futures_rows.payment_term,
         cur_futures_rows.payment_due_date,
         cur_futures_rows.closed_lots,
         cur_futures_rows.closed_quantity,
         cur_futures_rows.is_new_trade_date,
         cur_futures_rows.status,
         cur_futures_rows.settlement_cur_id,
         cur_futures_rows.settlement_cur_code,
         cur_futures_rows.in_out_at_money_status,
         cur_futures_rows.in_out_at_money_value,
         cur_futures_rows.exercise_date,
         cur_futures_rows.expiry_date,
         cur_futures_rows.group_cur_id,
         cur_futures_rows.group_cur_code,
         cur_futures_rows.group_qty_unit_id,
         cur_futures_rows.gcd_qty_unit,
         cur_futures_rows.base_qty_unit_id,
         cur_futures_rows.base_qty_unit,
         cur_futures_rows.internal_close_out_ref_no,
         cur_futures_rows.close_out_ref_no,
         cur_futures_rows.close_out_date,
         cur_futures_rows.settlement_price,
         cur_futures_rows.settlement_price_unit_id,
         cur_futures_rows.settlement_price_cur_id,
         cur_futures_rows.settlemet_price_cur_code,
         cur_futures_rows.settlement_price_weight,
         cur_futures_rows.settlement_weight_unit_id,
         cur_futures_rows.settlement_weight_unit,
         cur_futures_rows.parent_instrument_type,
         vn_clr_comm_in_base_cur,
         vn_broker_comm_in_base_cur,
         vn_clr_cur_to_base_exch_rate,
         vn_brokr_cur_to_base_exch_rate,
         vn_trade_to_base_exch_rate,
         cur_futures_rows.pnl_type,
         vn_net_pnl_in_base_cur,
         vn_pnl_value_in_trade_cur,
         cur_futures_rows.base_cur_id,
         cur_futures_rows.base_cur_code,
         cur_futures_rows.underlying_future_dr_id,
         cur_futures_rows.underlying_future_dr_id_name,
         cur_futures_rows.underlying_future_expiry_date,
         cur_futures_rows.underlying_future_quote_price,
         cur_futures_rows.underlying_fut_price_unit_id,
         cur_futures_rows.process_id,
         vn_trade_qty_exch_unit);
    
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_forward_unrealized_pnl',
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

  procedure sp_calc_forward_realized_pnl(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2,
                                         pc_dbd_id       varchar2) is
  
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
    cursor cur_forwards is
      select dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             pd_trade_date eod_trade_date,
             dt.trade_date,
             dt.corporate_id,
             ak.corporate_name,
             dt.trader_id,
             gab.firstname || gab.lastname tradername,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dt.dr_id,
             drm.instrument_id,
             dim.instrument_name,
             dim.instrument_symbol,
             dim.instrument_type_id,
             irm.instrument_type,
             irm.instrument_display_name,
             dim.instrument_sub_type_id,
             istm.instrument_sub_type,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             pdd.traded_on,
             pdd.product_id,
             pdm.product_desc,
             emt.exchange_id,
             emt.exchange_name,
             emt.exchange_code,
             pdd.lot_size,
             pdd.lot_size_unit_id,
             qum.qty_unit lot_size_qty_unit,
             drm.price_point_id,
             pp.price_point_name,
             drm.period_type_id,
             pm.period_type_name,
             pm.period_type_display_name,
             drm.period_month,
             drm.period_year,
             (case
               when drm.period_date is null then
                case
               when drm.period_month is not null and
                    drm.period_year is not null then
                to_date('01-' || drm.period_month || '-' || drm.period_year,
                        'dd-Mon-yyyy')
               else
                drm.prompt_date
             end else drm.period_date end) period_date,
             drm.prompt_date,
             drm.dr_id_name,
             dt.trade_type,
             dt.deal_type_id,
             dtm.deal_type_name,
             dtm.deal_type_display_name,
             dtm.is_multiple_leg_involved,
             null deal_category,
             null deal_sub_category,
             dt.strategy_id,
             css.strategy_name,
             css.description,
             sdm.strategy_def_name,
             ak.groupid,
             gcd.groupname,
             dt.purpose_id,
             dpm.purpose_name,
             dpm.purpose_display_name,
             dt.external_ref_no,
             dt.cp_profile_id,
             phd_cp.companyname cp_name,
             dt.master_contract_id,
             dt.broker_profile_id,
             phd_broker.companyname broker_name,
             dt.broker_account_id,
             bca_broker.account_name broker_account_name,
             bca_broker.account_type broker_account_type,
             dt.broker_comm_type_id,
             dt.broker_comm_amt,
             dt.broker_comm_cur_id,
             cm_broker_cur.cur_code broker_cur_code,
             dt.clearer_profile_id,
             phd_clearer.companyname clearer_name,
             dt.clearer_account_id,
             bca_clearer.account_name clearer_account_name,
             bca_clearer.account_type clearer_account_type,
             dt.clearer_comm_type_id,
             dt.clearer_comm_amt,
             dt.clearer_comm_cur_id,
             cm_clearer.cur_code clearer_cur_code,
             dt.product_id product,
             pdm.product_desc productdesc,
             dt.quality_id,
             qat.quality_name,
             qat.gravity,
             gtm.gravity_type_name gravity_type,
             qat.density_mass_qty_unit_id,
             qat.density_volume_qty_unit_id,
             dt.quantity_unit_id,
             qum_um.qty_unit quantityname,
             dt.total_lots,
             dt.total_quantity,
             dt.open_lots,
             dt.open_quantity,
             dt.exercised_lots,
             dt.exercised_quantity,
             dt.expired_lots,
             dt.expired_quantity,
             dt.trade_price_type_id,
             dt.trade_price,
             dt.trade_price_unit_id,
             pum_trade.cur_id trade_cur_id,
             cm_trade.cur_code trade_cur_code,
             pum_trade.weight trade_weight,
             pum_trade.weight_unit_id trade_weight_unit_id,
             qum_trade.qty_unit trade_qty_unit,
             dt.formula_id,
             fbs.formula_name,
             fbs.formula_display,
             dt.index_instrument_id,
             dim_index.instrument_name index_instrument_name,
             dt.strike_price,
             dt.strike_price_unit_id,
             pum_strike.cur_id strike_cur_id,
             cm_strike.cur_code strike_cur_code,
             pum_strike.weight strike_weight,
             pum_strike.weight_unit_id strike_weight_unit_id,
             qum_strike.qty_unit strike_qty_unit,
             dt.premium_discount,
             dt.premium_discount_price_unit_id,
             pum_pd.cur_id pd_cur_id,
             cm_pd.cur_code pd_cur_code,
             pum_pd.weight pd_weight,
             pum_pd.weight_unit_id pd_weight_unit_id,
             qum_pd.qty_unit pd_qty_unit,
             dt.premium_due_date,
             dt.nominee_profile_id,
             phd_nominee.companyname nominee_name,
             dt.leg_no,
             dt.option_expiry_date,
             dt.parent_int_derivative_ref_no,
             dt.market_location_country,
             dt.market_location_state,
             dt.market_location_city,
             dt.is_what_if,
             dt.payment_term,
             pym.payment_term payment_term_name,
             dt.payment_due_date,
             dt.closed_lots,
             dt.closed_quantity,
             null as is_new_trade_date,
             'Settled' status,
             dt.settlement_cur_id,
             cm_settlement.cur_code settlement_cur_code,
             null as in_out_at_money_status,
             null as in_out_at_money_value,
             null as exercise_date,
             null as expiry_date,
             gcd_group.group_cur_id,
             cm_gcd.cur_code group_cur_code,
             gcd_group.group_qty_unit_id,
             qum_gcd.qty_unit gcd_qty_unit,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             fsh.settlement_ref_no,
             fsh.fsh_id,
             fsh.settlement_date,
             fsh.contract_price,
             fsh.contract_price_unit_id,
             fsh.market_price,
             fsh.market_price_unit_id,
             (case
               when irm.instrument_type in ('Option Put', 'Option Call') then
                'Option'
               else
                irm.instrument_type
             end) as parent_instrument_type,
             null as clearer_comm_in_base,
             null as broker_comm_in_base,
             null as clearer_exch_rate,
             null as broker_exch_rate,
             null as trade_cur_to_base_exch_rate,
             'Realized' as pnl_type,
             null as pnl_in_base_cur,
             null as pnl_in_trade_cur,
             cm_base.cur_id as base_cur_id,
             ak.base_currency_name base_cur_code,
             null as underlying_future_dr_id,
             null as underlying_future_dr_id_name,
             null as underlying_future_expiry_date,
             null as underlying_future_quote_price,
             null as underlying_fut_price_unit_id,
             pc_process_id process_id
      
        from dt_derivative_trade            dt,
             ak_corporate                   ak,
             ak_corporate_user              aku,
             gab_globaladdressbook          gab,
             cpc_corporate_profit_center    cpc,
             drm_derivative_master          drm,
             dim_der_instrument_master      dim,
             irm_instrument_type_master     irm,
             istm_instr_sub_type_master     istm,
             pdd_product_derivative_def     pdd,
             pdm_productmaster              pdm,
             emt_exchangemaster             emt,
             qum_quantity_unit_master       qum,
             pp_price_point                 pp,
             pm_period_master               pm,
             dtm_deal_type_master           dtm,
             css_corporate_strategy_setup   css,
             sdm_strategy_definition_master sdm,
             gcd_groupcorporatedetails      gcd,
             dpm_derivative_purpose_master  dpm,
             phd_profileheaderdetails       phd_cp,
             phd_profileheaderdetails       phd_broker,
             bca_broker_clearer_account     bca_broker,
             cm_currency_master             cm_broker_cur,
             phd_profileheaderdetails       phd_clearer,
             bca_broker_clearer_account     bca_clearer,
             cm_currency_master             cm_clearer,
             qat_quality_attributes         qat,
             gtm_gravity_type_master        gtm,
             qum_quantity_unit_master       qum_um,
             pum_price_unit_master          pum_trade,
             cm_currency_master             cm_trade,
             qum_quantity_unit_master       qum_trade,
             fbs_formula_builder_setup      fbs,
             dim_der_instrument_master      dim_index,
             pum_price_unit_master          pum_strike,
             cm_currency_master             cm_strike,
             qum_quantity_unit_master       qum_strike,
             pum_price_unit_master          pum_pd,
             cm_currency_master             cm_pd,
             qum_quantity_unit_master       qum_pd,
             phd_profileheaderdetails       phd_nominee,
             pym_payment_terms_master       pym,
             cm_currency_master             cm_settlement,
             gcd_groupcorporatedetails      gcd_group,
             cm_currency_master             cm_gcd,
             qum_quantity_unit_master       qum_gcd,
             qum_quantity_unit_master       qum_pdm,
             cm_currency_master             cm_base,
             fsh_fin_settlement_header      fsh
       where dt.corporate_id = ak.corporate_id
         and dt.trader_id = aku.user_id
         and aku.gabid = gab.gabid
         and dt.profit_center_id = cpc.profit_center_id
         and dt.dr_id = drm.dr_id(+)
         and drm.instrument_id = dim.instrument_id(+)
         and dim.instrument_type_id = irm.instrument_type_id(+)
         and dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
         and dim.product_derivative_id = pdd.derivative_def_id(+)
         and pdd.product_id = pdm.product_id(+)
         and pdd.exchange_id = emt.exchange_id(+)
         and pdd.lot_size_unit_id = qum.qty_unit_id(+)
         and drm.price_point_id = pp.price_point_id(+)
         and drm.period_type_id = pm.period_type_id(+)
         and dt.deal_type_id = dtm.deal_type_id
         and dt.strategy_id = css.strategy_id
         and css.strategy_def_id = sdm.strategy_def_id
         and ak.groupid = gcd.groupid
         and dt.purpose_id = dpm.purpose_id
         and dt.cp_profile_id = phd_cp.profileid(+)
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.broker_account_id = bca_broker.account_id(+)
         and dt.broker_comm_cur_id = cm_broker_cur.cur_id(+)
         and dt.clearer_profile_id = phd_clearer.profileid(+)
         and dt.clearer_account_id = bca_clearer.account_id(+)
         and dt.clearer_comm_cur_id = cm_clearer.cur_id(+)
         and dt.quality_id = qat.quality_id(+)
         and qat.gravity_type_id = gtm.gravity_type_id(+)
         and dt.quantity_unit_id = qum_um.qty_unit_id
         and dt.trade_price_unit_id = pum_trade.price_unit_id(+)
         and pum_trade.cur_id = cm_trade.cur_id(+)
         and pum_trade.weight_unit_id = qum_trade.qty_unit_id(+)
         and dt.formula_id = fbs.formula_id(+)
         and dt.index_instrument_id = dim_index.instrument_id(+)
         and dt.strike_price_unit_id = pum_strike.price_unit_id(+)
         and pum_strike.cur_id = cm_strike.cur_id(+)
         and pum_strike.weight_unit_id = qum_strike.qty_unit_id(+)
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and pum_pd.cur_id = cm_pd.cur_id(+)
         and pum_pd.weight_unit_id = qum_pd.qty_unit_id(+)
         and dt.nominee_profile_id = phd_nominee.profileid(+)
         and dt.payment_term = pym.payment_term_id(+)
         and dt.settlement_cur_id = cm_settlement.cur_id(+)
         and ak.groupid=gcd_group.groupid
         and gcd_group.group_cur_id = cm_gcd.cur_id
         and gcd_group.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id(+)
         and ak.base_currency_name = cm_base.cur_code
         and dt.internal_derivative_ref_no = fsh.internal_derivative_ref_no
         and fsh.process_id = pc_process_id
         and irm.instrument_type = 'Forward'
            -- AND UPPER(dt.status) in ('closed', 'settled')
         and dt.is_what_if = 'N'
         and dt.corporate_id = pc_corporate_id
         and dt.trade_date <= pd_trade_date
         and dt.process_id = pc_process_id;
  
    vn_trade_qty_exch_unit         number;
    vn_trade_to_base_exch_rate     number;
    vn_brokr_cur_to_base_exch_rate number;
    vn_clr_cur_to_base_exch_rate   number;
    vn_qty_in_trade_wt_unit        number;
    vc_trade_price_cur_id          varchar2(15);
    vc_trade_price_cur_code        varchar2(15);
    vn_trade_price_weight          number(7, 2);
    vc_trade_price_weight_unit_id  varchar2(15);
    vc_trade_price_qty_unit        varchar2(15);
    vc_market_price_cur_id         varchar2(15);
    vc_market_price_cur_code       varchar2(15);
    vn_market_price_weight         number(7, 2);
    vc_market_price_weight_unit_id varchar2(15);
    vc_market_price_qty_unit       varchar2(15);
    vn_market_price_in_trade_cur   number;
    vn_total_market_val_trade_cur  number;
    vn_trade_price_in_trade_cur    number;
    vn_total_trade_value_trade_cur number;
    vn_pnl_value_in_trade_cur      number;
    vn_total_trade_value_base_cur  number;
    vn_broker_comm_in_base_cur     number;
    vn_clearer_comm_in_base_cur    number;
    vn_pnl_value_in_base_cur       number;
    vn_net_pnl_in_base_cur         number;
    vn_market_contract_price       number;
  
  begin
    for cur_forwards_rows in cur_forwards
    loop
    
      begin
        select pum.cur_id,
               cm.cur_code,
               pum.weight,
               pum.weight_unit_id,
               qum.qty_unit
          into vc_trade_price_cur_id,
               vc_trade_price_cur_code,
               vn_trade_price_weight,
               vc_trade_price_weight_unit_id,
               vc_trade_price_qty_unit
          from v_ppu_pum                pum,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where pum.product_price_unit_id =
               cur_forwards_rows.contract_price_unit_id
           and pum.cur_id = cm.cur_id
           and pum.weight_unit_id = qum.qty_unit_id;
      exception
        when no_data_found then
          vc_trade_price_cur_id         := null;
          vc_trade_price_cur_code       := null;
          vn_trade_price_weight         := null;
          vc_trade_price_weight_unit_id := null;
          vc_trade_price_qty_unit       := null;
      end;
    
      -- Trade Qty in Exchange Weight Unit      
      if cur_forwards_rows.gravity is not null then
      
        vn_trade_qty_exch_unit := pkg_general.fn_mass_volume_qty_conversion(cur_forwards_rows.product_id,
                                                                            cur_forwards_rows.quantity_unit_id,
                                                                            cur_forwards_rows.lot_size_unit_id,
                                                                            cur_forwards_rows.open_quantity,
                                                                            cur_forwards_rows.gravity,
                                                                            cur_forwards_rows.gravity_type,
                                                                            cur_forwards_rows.density_mass_qty_unit_id,
                                                                            cur_forwards_rows.density_volume_qty_unit_id);
      else
        vn_trade_qty_exch_unit := pkg_general.f_get_converted_quantity(null,
                                                                       cur_forwards_rows.quantity_unit_id,
                                                                       cur_forwards_rows.lot_size_unit_id,
                                                                       cur_forwards_rows.open_quantity);
      
      end if;
    
      /*get the exchange rates
      1. from broker to base currency
      2. trade to base currency
      */
    
      if cur_forwards_rows.trade_cur_id <> cur_forwards_rows.base_cur_id then
        vn_trade_to_base_exch_rate := f_currency_exchange_rate(pd_trade_date,
                                                               pc_corporate_id,
                                                               cur_forwards_rows.prompt_date,
                                                               vc_trade_price_cur_id,
                                                               cur_forwards_rows.base_cur_id);
      else
        vn_trade_to_base_exch_rate := 1;
      end if;
    
      if cur_forwards_rows.broker_comm_cur_id <>
         cur_forwards_rows.base_cur_id then
        vn_brokr_cur_to_base_exch_rate := f_currency_exchange_rate(pd_trade_date,
                                                                   pc_corporate_id,
                                                                   cur_forwards_rows.prompt_date,
                                                                   cur_forwards_rows.broker_comm_cur_id,
                                                                   cur_forwards_rows.base_cur_id);
      else
        vn_brokr_cur_to_base_exch_rate := 1;
      end if;
    
      if cur_forwards_rows.clearer_comm_cur_id <>
         cur_forwards_rows.base_cur_id then
        vn_clr_cur_to_base_exch_rate := f_currency_exchange_rate(pd_trade_date,
                                                                 pc_corporate_id,
                                                                 cur_forwards_rows.prompt_date,
                                                                 cur_forwards_rows.clearer_comm_cur_id,
                                                                 cur_forwards_rows.base_cur_id);
      else
        vn_clr_cur_to_base_exch_rate := 1;
      end if;
    
      begin
        select pum.cur_id,
               cm.cur_code,
               pum.weight,
               pum.weight_unit_id,
               qum.qty_unit
          into vc_market_price_cur_id,
               vc_market_price_cur_code,
               vn_market_price_weight,
               vc_market_price_weight_unit_id,
               vc_market_price_qty_unit
          from v_ppu_pum                pum,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where pum.product_price_unit_id =
               cur_forwards_rows.market_price_unit_id
           and pum.cur_id = cm.cur_id
           and pum.weight_unit_id = qum.qty_unit_id;
      exception
        when no_data_found then
          vc_market_price_cur_id         := null;
          vc_market_price_cur_code       := null;
          vn_market_price_weight         := null;
          vc_market_price_weight_unit_id := null;
          vc_market_price_qty_unit       := null;
      end;
    
      if cur_forwards_rows.gravity is not null then
        vn_total_trade_value_trade_cur := (cur_forwards_rows.contract_price /
                                          nvl(vn_trade_price_weight, 1)) *
                                          pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                   vc_trade_price_cur_id,
                                                                                   cur_forwards_rows.settlement_cur_id,
                                                                                   pd_trade_date,
                                                                                   1) *
                                          (pkg_general.fn_mass_volume_qty_conversion(cur_forwards_rows.product_id,
                                                                                     cur_forwards_rows.quantity_unit_id,
                                                                                     vc_trade_price_weight_unit_id,
                                                                                     cur_forwards_rows.open_quantity,
                                                                                     cur_forwards_rows.gravity,
                                                                                     cur_forwards_rows.gravity_type,
                                                                                     cur_forwards_rows.density_mass_qty_unit_id,
                                                                                     cur_forwards_rows.density_volume_qty_unit_id));
      else
        vn_total_trade_value_trade_cur := (cur_forwards_rows.contract_price /
                                          nvl(vn_trade_price_weight, 1)) *
                                          pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                   vc_trade_price_cur_id,
                                                                                   cur_forwards_rows.settlement_cur_id,
                                                                                   pd_trade_date,
                                                                                   1) *
                                          (pkg_general.f_get_converted_quantity(cur_forwards_rows.product_id,
                                                                                cur_forwards_rows.quantity_unit_id,
                                                                                vc_trade_price_weight_unit_id,
                                                                                cur_forwards_rows.open_quantity));
      end if;
    
      if cur_forwards_rows.gravity is not null then
        vn_total_market_val_trade_cur := (cur_forwards_rows.market_price /
                                         nvl(vn_market_price_weight, 1)) *
                                         pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                  vc_market_price_cur_id,
                                                                                  cur_forwards_rows.settlement_cur_id,
                                                                                  pd_trade_date,
                                                                                  1) *
                                         (pkg_general.fn_mass_volume_qty_conversion(cur_forwards_rows.product_id,
                                                                                    cur_forwards_rows.quantity_unit_id,
                                                                                    vc_market_price_weight_unit_id,
                                                                                    cur_forwards_rows.open_quantity,
                                                                                    cur_forwards_rows.gravity,
                                                                                    cur_forwards_rows.gravity_type,
                                                                                    cur_forwards_rows.density_mass_qty_unit_id,
                                                                                    cur_forwards_rows.density_volume_qty_unit_id));
      
      else
        vn_total_market_val_trade_cur := (cur_forwards_rows.market_price /
                                         nvl(vn_market_price_weight, 1)) *
                                         pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                  vc_market_price_cur_id,
                                                                                  cur_forwards_rows.settlement_cur_id,
                                                                                  pd_trade_date,
                                                                                  1) *
                                         (pkg_general.f_get_converted_quantity(cur_forwards_rows.product_id,
                                                                               cur_forwards_rows.quantity_unit_id,
                                                                               vc_market_price_weight_unit_id,
                                                                               cur_forwards_rows.open_quantity));
      
      end if;
    
      if cur_forwards_rows.trade_type = 'Buy' then
        vn_pnl_value_in_trade_cur := vn_total_market_val_trade_cur -
                                     vn_total_trade_value_trade_cur;
      else
        vn_pnl_value_in_trade_cur := vn_total_trade_value_trade_cur -
                                     vn_total_market_val_trade_cur;
      end if;
    
      vn_total_trade_value_base_cur := vn_total_trade_value_trade_cur *
                                       vn_trade_to_base_exch_rate;
    
      vn_broker_comm_in_base_cur  := cur_forwards_rows.broker_comm_amt *
                                     vn_brokr_cur_to_base_exch_rate;
      vn_clearer_comm_in_base_cur := cur_forwards_rows.clearer_comm_amt *
                                     vn_clr_cur_to_base_exch_rate;
      vn_pnl_value_in_base_cur    := vn_pnl_value_in_trade_cur *
                                     vn_trade_to_base_exch_rate;
      vn_net_pnl_in_base_cur      := vn_pnl_value_in_base_cur -
                                     nvl(vn_broker_comm_in_base_cur, 0) -
                                     nvl(vn_clearer_comm_in_base_cur, 0);
    
      if vn_net_pnl_in_base_cur is null then
        vn_net_pnl_in_base_cur := 0;
      end if;
    
      if vn_pnl_value_in_trade_cur is null then
        vn_pnl_value_in_trade_cur := 0;
      end if;
    
      insert into dpd_derivative_pnl_daily
        (internal_derivative_ref_no,
         derivative_ref_no,
         eod_trade_date,
         trade_date,
         corporate_id,
         corporate_name,
         trader_id,
         trader_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         dr_id,
         instrument_id,
         instrument_name,
         instrument_symbol,
         instrument_type_id,
         instrument_type,
         instrument_type_name,
         instrument_sub_type_id,
         instrument_sub_type,
         derivative_def_id,
         derivative_def_name,
         derivative_traded_on,
         derivative_prodct_id,
         derivative_prodct_name,
         exchange_id,
         exchange_name,
         exchange_code,
         lot_size,
         lot_size_unit_id,
         lot_size_unit,
         price_point_id,
         price_point_name,
         period_type_id,
         period_type_name,
         period_type_display_name,
         period_month,
         period_year,
         period_date,
         prompt_date,
         dr_id_name,
         trade_type,
         deal_type_id,
         deal_type_name,
         deal_type_display_name,
         is_multiple_leg_involved,
         deal_category,
         deal_sub_category,
         strategy_id,
         strategy_name,
         strategy_desc,
         strategy_def_name,
         group_id,
         group_name,
         purpose_id,
         purpose_name,
         purpose_display_name,
         external_ref_no,
         cp_profile_id,
         cp_name,
         master_contract_id,
         broker_profile_id,
         broker_name,
         broker_account_id,
         broker_account_name,
         broker_account_type,
         broker_comm_type_id,
         broker_comm_amt,
         broker_comm_cur_id,
         broker_comm_cur_code,
         clearer_profile_id,
         clearer_name,
         clearer_account_id,
         clearer_account_name,
         clearer_account_type,
         clearer_comm_type_id,
         clearer_comm_amt,
         clearer_comm_cur_id,
         clearer_comm_cur_code,
         product_id,
         product_name,
         quality_id,
         quality_name,
         quantity_unit_id,
         quantity_unit,
         total_lots,
         total_quantity,
         open_lots,
         open_quantity,
         exercised_lots,
         exercised_quantity,
         expired_lots,
         expired_quantity,
         trade_price_type_id,
         trade_price,
         trade_price_unit_id,
         trade_price_cur_id,
         trade_price_cur_code,
         trade_price_weight,
         trade_price_weight_unit_id,
         trade_price_weight_unit,
         formula_id,
         formula_name,
         formula_display,
         index_instrument_id,
         index_instrument_name,
         strike_price,
         strike_price_unit_id,
         strike_price_cur_id,
         strike_price_cur_code,
         strike_price_weight,
         strike_price_weight_unit_id,
         strike_price_weight_unit,
         premium_discount,
         premium_discount_price_unit_id,
         pd_price_cur_id,
         pd_price_cur_code,
         pd_price_weight,
         pd_price_weight_unit_id,
         pd_price_weight_unit,
         premium_due_date,
         nominee_profile_id,
         nominee_name,
         leg_no,
         option_expiry_date,
         parent_int_derivative_ref_no,
         market_location_country,
         market_location_state,
         market_location_city,
         is_what_if,
         payment_term_id,
         payment_term,
         payment_due_date,
         closed_lots,
         closed_quantity,
         is_new_trade,
         status,
         settlement_cur_id,
         settlement_cur_code,
         in_out_at_money_status,
         in_out_at_money_value,
         exercise_date,
         expiry_date,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         --internal_close_out_ref_no,
         --close_out_ref_no,
         -- close_out_date,
         settlement_price,
         sett_price_unit_id,
         sett_price_cur_id,
         sett_price_cur_code,
         sett_price_weight,
         sett_price_weight_unit_id,
         sett_price_weight_unit,
         parent_instrument_type,
         clearer_comm_in_base,
         broker_comm_in_base,
         clearer_exch_rate,
         broker_exch_rate,
         trade_cur_to_base_exch_rate,
         pnl_type,
         pnl_in_base_cur,
         pnl_in_trade_cur,
         base_cur_id,
         base_cur_code,
         underlying_future_dr_id,
         underlying_future_dr_id_name,
         underlying_future_expiry_date,
         underlying_future_quote_price,
         underlying_fut_price_unit_id,
         process_id,
         trade_qty_in_exch_unit,
         settlement_ref_no)
      
      values
        (cur_forwards_rows.internal_derivative_ref_no,
         cur_forwards_rows.derivative_ref_no,
         cur_forwards_rows.eod_trade_date,
         cur_forwards_rows.trade_date,
         cur_forwards_rows.corporate_id,
         cur_forwards_rows.corporate_name,
         cur_forwards_rows.trader_id,
         cur_forwards_rows.tradername,
         cur_forwards_rows.profit_center_id,
         cur_forwards_rows.profit_center_name,
         cur_forwards_rows.profit_center_short_name,
         cur_forwards_rows.dr_id,
         cur_forwards_rows.instrument_id,
         cur_forwards_rows.instrument_name,
         cur_forwards_rows.instrument_symbol,
         cur_forwards_rows.instrument_type_id,
         cur_forwards_rows.instrument_type,
         cur_forwards_rows.instrument_display_name,
         cur_forwards_rows.instrument_sub_type_id,
         cur_forwards_rows.instrument_sub_type,
         cur_forwards_rows.derivative_def_id,
         cur_forwards_rows.derivative_def_name,
         cur_forwards_rows.traded_on,
         cur_forwards_rows.product_id,
         cur_forwards_rows.product_desc,
         cur_forwards_rows.exchange_id,
         cur_forwards_rows.exchange_name,
         cur_forwards_rows.exchange_code,
         cur_forwards_rows.lot_size,
         cur_forwards_rows.lot_size_unit_id,
         cur_forwards_rows.lot_size_qty_unit,
         cur_forwards_rows.price_point_id,
         cur_forwards_rows.price_point_name,
         cur_forwards_rows.period_type_id,
         cur_forwards_rows.period_type_name,
         cur_forwards_rows.period_type_display_name,
         cur_forwards_rows.period_month,
         cur_forwards_rows.period_year,
         cur_forwards_rows.period_date,
         cur_forwards_rows.prompt_date,
         cur_forwards_rows.dr_id_name,
         cur_forwards_rows.trade_type,
         cur_forwards_rows.deal_type_id,
         cur_forwards_rows.deal_type_name,
         cur_forwards_rows.deal_type_display_name,
         cur_forwards_rows.is_multiple_leg_involved,
         cur_forwards_rows.deal_category,
         cur_forwards_rows.deal_sub_category,
         cur_forwards_rows.strategy_id,
         cur_forwards_rows.strategy_name,
         cur_forwards_rows.description,
         cur_forwards_rows.strategy_def_name,
         cur_forwards_rows.groupid,
         cur_forwards_rows.groupname,
         cur_forwards_rows.purpose_id,
         cur_forwards_rows.purpose_name,
         cur_forwards_rows.purpose_display_name,
         cur_forwards_rows.external_ref_no,
         cur_forwards_rows.cp_profile_id,
         cur_forwards_rows.cp_name,
         cur_forwards_rows.master_contract_id,
         cur_forwards_rows.broker_profile_id,
         cur_forwards_rows.broker_name,
         cur_forwards_rows.broker_account_id,
         cur_forwards_rows.broker_account_name,
         cur_forwards_rows.broker_account_type,
         cur_forwards_rows.broker_comm_type_id,
         cur_forwards_rows.broker_comm_amt,
         cur_forwards_rows.broker_comm_cur_id,
         cur_forwards_rows.broker_cur_code,
         cur_forwards_rows.clearer_profile_id,
         cur_forwards_rows.clearer_name,
         cur_forwards_rows.clearer_account_id,
         cur_forwards_rows.clearer_account_name,
         cur_forwards_rows.clearer_account_type,
         cur_forwards_rows.clearer_comm_type_id,
         cur_forwards_rows.clearer_comm_amt,
         cur_forwards_rows.clearer_comm_cur_id,
         cur_forwards_rows.clearer_cur_code,
         cur_forwards_rows.product_id,
         cur_forwards_rows.product,
         cur_forwards_rows.quality_id,
         cur_forwards_rows.quality_name,
         cur_forwards_rows.quantity_unit_id,
         cur_forwards_rows.quantityname,
         cur_forwards_rows.total_lots,
         cur_forwards_rows.total_quantity,
         cur_forwards_rows.open_lots,
         cur_forwards_rows.open_quantity,
         cur_forwards_rows.exercised_lots,
         cur_forwards_rows.exercised_quantity,
         cur_forwards_rows.expired_lots,
         cur_forwards_rows.expired_quantity,
         cur_forwards_rows.trade_price_type_id,
         cur_forwards_rows.contract_price,
         cur_forwards_rows.contract_price_unit_id,
         vc_trade_price_cur_id,
         vc_trade_price_cur_code,
         vn_trade_price_weight,
         vc_trade_price_weight_unit_id,
         vc_trade_price_qty_unit,
         cur_forwards_rows.formula_id,
         cur_forwards_rows.formula_name,
         cur_forwards_rows.formula_display,
         cur_forwards_rows.index_instrument_id,
         cur_forwards_rows.index_instrument_name,
         cur_forwards_rows.strike_price,
         cur_forwards_rows.strike_price_unit_id,
         cur_forwards_rows.strike_cur_id,
         cur_forwards_rows.strike_cur_code,
         cur_forwards_rows.strike_weight,
         cur_forwards_rows.strike_weight_unit_id,
         cur_forwards_rows.strike_qty_unit,
         cur_forwards_rows.premium_discount,
         cur_forwards_rows.premium_discount_price_unit_id,
         cur_forwards_rows.pd_cur_id,
         cur_forwards_rows.pd_cur_code,
         cur_forwards_rows.pd_weight,
         cur_forwards_rows.pd_weight_unit_id,
         cur_forwards_rows.pd_qty_unit,
         cur_forwards_rows.premium_due_date,
         cur_forwards_rows.nominee_profile_id,
         cur_forwards_rows.nominee_name,
         cur_forwards_rows.leg_no,
         cur_forwards_rows.option_expiry_date,
         cur_forwards_rows.parent_int_derivative_ref_no,
         cur_forwards_rows.market_location_country,
         cur_forwards_rows.market_location_state,
         cur_forwards_rows.market_location_city,
         cur_forwards_rows.is_what_if,
         cur_forwards_rows.payment_term,
         cur_forwards_rows.payment_term,
         cur_forwards_rows.payment_due_date,
         cur_forwards_rows.closed_lots,
         cur_forwards_rows.closed_quantity,
         cur_forwards_rows.is_new_trade_date,
         cur_forwards_rows.status,
         cur_forwards_rows.settlement_cur_id,
         cur_forwards_rows.settlement_cur_code,
         cur_forwards_rows.in_out_at_money_status,
         cur_forwards_rows.in_out_at_money_value,
         cur_forwards_rows.exercise_date,
         cur_forwards_rows.expiry_date,
         cur_forwards_rows.group_cur_id,
         cur_forwards_rows.group_cur_code,
         cur_forwards_rows.group_qty_unit_id,
         cur_forwards_rows.gcd_qty_unit,
         cur_forwards_rows.base_qty_unit_id,
         cur_forwards_rows.base_qty_unit,
         --cur_forwards_rows.internal_close_out_ref_no,
         -- cur_forwards_rows.close_out_ref_no,
         --cur_forwards_rows.close_out_date,
         cur_forwards_rows.market_price,
         cur_forwards_rows.market_price_unit_id,
         vc_market_price_cur_id,
         vc_market_price_cur_code,
         vn_market_price_weight,
         vc_market_price_weight_unit_id,
         vc_market_price_qty_unit,
         cur_forwards_rows.parent_instrument_type,
         vn_clearer_comm_in_base_cur,
         vn_broker_comm_in_base_cur,
         vn_clr_cur_to_base_exch_rate,
         vn_brokr_cur_to_base_exch_rate,
         vn_trade_to_base_exch_rate,
         cur_forwards_rows.pnl_type,
         vn_net_pnl_in_base_cur,
         vn_pnl_value_in_trade_cur,
         cur_forwards_rows.base_cur_id,
         cur_forwards_rows.base_cur_code,
         cur_forwards_rows.underlying_future_dr_id,
         cur_forwards_rows.underlying_future_dr_id_name,
         cur_forwards_rows.underlying_future_expiry_date,
         cur_forwards_rows.underlying_future_quote_price,
         cur_forwards_rows.underlying_fut_price_unit_id,
         cur_forwards_rows.process_id,
         vn_trade_qty_exch_unit,
         cur_forwards_rows.settlement_ref_no);
    
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_forward_realized_pnl',
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

  procedure sp_calc_swap_unrealized_pnl(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_process      varchar2,
                                        pc_dbd_id       varchar2) is
    /******************************************************************************************************************************************
    procedure name                            : sp_calc_swap_unrealized_pnl
    author                                    : janna
    created date                              : 10th jan 2009
    purpose                                   : calculate the unrealized pnl for futures as on eod date
    parameters                                :
    pc_corporate_id                           : corporate id
    pd_trade_date                             : eod date id
    pc_eod_ref_no                             : eod reference no
    modification history                      :
    modified date                             :
    modified by                               :
    modify description                        :
    ******************************************************************************************************************************************/
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
    cursor cur_swaps is
      select dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             pd_trade_date eod_trade_date,
             dt.trade_date,
             dt.corporate_id,
             ak.corporate_name,
             dt.trader_id,
             gab.firstname || gab.lastname tradername,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dt.dr_id,
             drm.instrument_id,
             dim.instrument_name,
             dim.instrument_symbol,
             dim.instrument_type_id,
             irm.instrument_type,
             irm.instrument_display_name,
             dim.instrument_sub_type_id,
             istm.instrument_sub_type,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             pdd.traded_on,
             pdd.product_id,
             pdm.product_desc,
             emt.exchange_id,
             emt.exchange_name,
             emt.exchange_code,
             pdd.lot_size,
             pdd.lot_size_unit_id,
             qum.qty_unit lot_size_qty_unit,
             drm.price_point_id,
             pp.price_point_name,
             drm.period_type_id,
             pm.period_type_name,
             pm.period_type_display_name,
             drm.period_month,
             drm.period_year,
             (case
               when drm.period_date is null then
                case
               when drm.period_month is not null and
                    drm.period_year is not null then
                to_date('01-' || drm.period_month || '-' || drm.period_year,
                        'dd-Mon-yyyy')
               else
                drm.prompt_date
             end else drm.period_date end) period_date,
             drm.prompt_date,
             drm.dr_id_name,
             dt.trade_type,
             dt.deal_type_id,
             dtm.deal_type_name,
             dtm.deal_type_display_name,
             dtm.is_multiple_leg_involved,
             dt.strategy_id,
             css.strategy_name,
             css.description,
             sdm.strategy_def_name,
             ak.groupid,
             gcd.groupname,
             dt.purpose_id,
             dpm.purpose_name,
             dpm.purpose_display_name,
             dt.external_ref_no,
             dt.cp_profile_id,
             phd_cp.companyname cp_name,
             dt.master_contract_id,
             dt.broker_profile_id,
             phd_broker.companyname broker_name,
             dt.broker_account_id,
             bca_broker.account_name broker_account_name,
             bca_broker.account_type broker_account_type,
             dt.broker_comm_type_id,
             dt.broker_comm_amt,
             dt.broker_comm_cur_id,
             cm_broker_cur.cur_code broker_cur_code,
             dt.clearer_profile_id,
             phd_clearer.companyname clearer_name,
             dt.clearer_account_id,
             bca_clearer.account_name clearer_account_name,
             bca_clearer.account_type clearer_account_type,
             dt.clearer_comm_type_id,
             dt.clearer_comm_amt,
             dt.clearer_comm_cur_id,
             cm_clearer.cur_code clearer_cur_code,
             dt.product_id product,
             pdm.product_desc productdesc,
             dt.quality_id,
             qat.quality_name,
             qat.gravity,
             gtm.gravity_type_name gravity_type,
             qat.density_mass_qty_unit_id,
             qat.density_volume_qty_unit_id,
             dt.quantity_unit_id,
             qum_um.qty_unit quantityname,
             dt.total_lots,
             dt.total_quantity,
             dt.open_lots,
             dt.open_quantity,
             dt.exercised_lots,
             dt.exercised_quantity,
             dt.expired_lots,
             dt.expired_quantity,
             dt.trade_price_type_id,
             dt.trade_price,
             dt.trade_price_unit_id,
             pum_trade.cur_id trade_cur_id,
             cm_trade.cur_code trade_cur_code,
             pum_trade.weight trade_weight,
             pum_trade.weight_unit_id trade_weight_unit_id,
             qum_trade.qty_unit trade_qty_unit,
             dt.formula_id,
             fbs.formula_name,
             fbs.formula_display,
             dt.index_instrument_id,
             dim_index.instrument_name index_instrument_name,
             dt.strike_price,
             dt.strike_price_unit_id,
             pum_strike.cur_id strike_cur_id,
             cm_strike.cur_code strike_cur_code,
             pum_strike.weight strike_weight,
             pum_strike.weight_unit_id strike_weight_unit_id,
             qum_strike.qty_unit strike_qty_unit,
             dt.premium_discount,
             dt.premium_discount_price_unit_id,
             pum_pd.cur_id pd_cur_id,
             cm_pd.cur_code pd_cur_code,
             pum_pd.weight pd_weight,
             pum_pd.weight_unit_id pd_weight_unit_id,
             qum_pd.qty_unit pd_qty_unit,
             dt.premium_due_date,
             dt.nominee_profile_id,
             phd_nominee.companyname nominee_name,
             dt.leg_no,
             dt.option_expiry_date,
             dt.parent_int_derivative_ref_no,
             dt.market_location_country,
             dt.market_location_state,
             dt.market_location_city,
             dt.is_what_if,
             dt.payment_term,
             pym.payment_term payment_term_name,
             dt.payment_due_date,
             dt.closed_lots,
             dt.closed_quantity,
             dt.status,
             dt.settlement_cur_id,
             cm_settlement.cur_code settlement_cur_code,
             gcd_group.group_cur_id,
             cm_gcd.cur_code group_cur_code,
             gcd_group.group_qty_unit_id,
             qum_gcd.qty_unit gcd_qty_unit,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             (case
               when irm.instrument_type in ('Option Put', 'Option Call') then
                'Option'
               else
                irm.instrument_type
             end) as parent_instrument_type,
             'Unrealized' as pnl_type,
             cm_base.cur_id as base_cur_id,
             ak.base_currency_name base_cur_code,
             dt.int_trade_parent_der_ref_no,
             dt.is_internal_trade,
             dt.available_price_id,
             dt.average_from_date,
             dt.average_to_date,
             dt.swap_type_1,
             dt.swap_trade_price_type_1,
             dt.swap_float_type_1,
             dt.swap_trade_price_1,
             dt.swap_trade_price_unit_id_1,
             pum_swap.price_unit_name swap_trade_price_unit_1,
             dt.swap_index_instrument_id_1,
             dt.swap_formula_id_1,
             dt.swap_type_2,
             dt.swap_trade_price_type_2,
             dt.swap_float_type_2,
             dt.swap_trade_price_2,
             dt.swap_trade_price_unit_id_2,
             pum_swap1.price_unit_id swap_trade_price_unit_2,
             dt.swap_index_instrument_id_2,
             dt.swap_formula_id_2,
             dt.swap_product1,
             dt.swap_product_quality1,
             dt.swap_product2,
             dt.swap_product_quality2,
             dt.pricing_invoicing_status,
             dt.approval_status,
             dt.trading_fee,
             dt.clearing_fee,
             dt.trading_clearing_fee,
             pc_process_id process_id
      
        from dt_derivative_trade            dt,
             ak_corporate                   ak,
             ak_corporate_user              aku,
             gab_globaladdressbook          gab,
             cpc_corporate_profit_center    cpc,
             drm_derivative_master          drm,
             dim_der_instrument_master      dim,
             irm_instrument_type_master     irm,
             istm_instr_sub_type_master     istm,
             pdd_product_derivative_def     pdd,
             pdm_productmaster              pdm,
             emt_exchangemaster             emt,
             qum_quantity_unit_master       qum,
             pp_price_point                 pp,
             pm_period_master               pm,
             dtm_deal_type_master           dtm,
             css_corporate_strategy_setup   css,
             sdm_strategy_definition_master sdm,
             gcd_groupcorporatedetails      gcd,
             dpm_derivative_purpose_master  dpm,
             phd_profileheaderdetails       phd_cp,
             phd_profileheaderdetails       phd_broker,
             bca_broker_clearer_account     bca_broker,
             cm_currency_master             cm_broker_cur,
             phd_profileheaderdetails       phd_clearer,
             bca_broker_clearer_account     bca_clearer,
             cm_currency_master             cm_clearer,
             qat_quality_attributes         qat,
             gtm_gravity_type_master        gtm,
             qum_quantity_unit_master       qum_um,
             pum_price_unit_master          pum_trade,
             cm_currency_master             cm_trade,
             qum_quantity_unit_master       qum_trade,
             fbs_formula_builder_setup      fbs,
             dim_der_instrument_master      dim_index,
             pum_price_unit_master          pum_strike,
             cm_currency_master             cm_strike,
             qum_quantity_unit_master       qum_strike,
             pum_price_unit_master          pum_pd,
             cm_currency_master             cm_pd,
             qum_quantity_unit_master       qum_pd,
             phd_profileheaderdetails       phd_nominee,
             pym_payment_terms_master       pym,
             cm_currency_master             cm_settlement,
             gcd_groupcorporatedetails      gcd_group,
             cm_currency_master             cm_gcd,
             qum_quantity_unit_master       qum_gcd,
             qum_quantity_unit_master       qum_pdm,
             cm_currency_master             cm_base,
             pum_price_unit_master          pum_swap,
             pum_price_unit_master          pum_swap1
      
       where dt.corporate_id = ak.corporate_id
         and dt.trader_id = aku.user_id
         and aku.gabid = gab.gabid
         and dt.profit_center_id = cpc.profit_center_id
         and dt.dr_id = drm.dr_id(+)
         and drm.instrument_id = dim.instrument_id(+)
         and dim.instrument_type_id = irm.instrument_type_id(+)
         and dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
         and dim.product_derivative_id = pdd.derivative_def_id(+)
         and pdd.product_id = pdm.product_id(+)
         and pdd.exchange_id = emt.exchange_id(+)
         and pdd.lot_size_unit_id = qum.qty_unit_id(+)
         and drm.price_point_id = pp.price_point_id(+)
         and drm.period_type_id = pm.period_type_id(+)
         and dt.deal_type_id = dtm.deal_type_id
         and dt.strategy_id = css.strategy_id
         and css.strategy_def_id = sdm.strategy_def_id
         and ak.groupid = gcd.groupid
         and dt.purpose_id = dpm.purpose_id
         and dt.cp_profile_id = phd_cp.profileid(+)
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.broker_account_id = bca_broker.account_id(+)
         and dt.broker_comm_cur_id = cm_broker_cur.cur_id(+)
         and dt.clearer_profile_id = phd_clearer.profileid(+)
         and dt.clearer_account_id = bca_clearer.account_id(+)
         and dt.clearer_comm_cur_id = cm_clearer.cur_id(+)
         and dt.quality_id = qat.quality_id(+)
         and qat.gravity_type_id = gtm.gravity_type_id(+)
         and dt.quantity_unit_id = qum_um.qty_unit_id
         and dt.trade_price_unit_id = pum_trade.price_unit_id(+)
         and pum_trade.cur_id = cm_trade.cur_id(+)
         and pum_trade.weight_unit_id = qum_trade.qty_unit_id(+)
         and dt.formula_id = fbs.formula_id(+)
         and dt.index_instrument_id = dim_index.instrument_id(+)
         and dt.strike_price_unit_id = pum_strike.price_unit_id(+)
         and pum_strike.cur_id = cm_strike.cur_id(+)
         and pum_strike.weight_unit_id = qum_strike.qty_unit_id(+)
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and pum_pd.cur_id = cm_pd.cur_id(+)
         and pum_pd.weight_unit_id = qum_pd.qty_unit_id(+)
         and dt.nominee_profile_id = phd_nominee.profileid(+)
         and dt.payment_term = pym.payment_term_id(+)
         and dt.settlement_cur_id = cm_settlement.cur_id(+)
         and ak.groupid=gcd_group.groupid
         and gcd_group.group_cur_id = cm_gcd.cur_id
         and gcd_group.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id(+)
         and ak.base_currency_name = cm_base.cur_code(+)
         and dt.swap_trade_price_unit_id_1 = pum_swap.price_unit_id(+)
         and dt.swap_trade_price_unit_id_2 = pum_swap1.price_unit_id(+)
            --AND irm.instrument_type in ('Future', 'Forward')
         and dtm.deal_type_display_name like '%Swap%'
         and upper(dt.status) = 'VERIFIED'
         and dt.is_what_if = 'N'
         and dt.corporate_id = pc_corporate_id
         and dt.open_quantity > 0
         and dt.trade_date <= pd_trade_date
         and dt.process_id = pc_process_id;
  
    --vn_total_trade_value_base_cur  number;
    vn_pnl_value_in_sett_cur number;
    --vn_trade_to_base_exch_rate     number;
    vn_pnl_value_in_base_cur       number;
    vn_broker_comm_in_base_cur     number;
    vn_clr_comm_in_base_cur        number;
    vn_net_pnl_in_base_cur         number;
    vn_brokr_cur_to_base_exch_rate number;
    vn_clr_cur_to_base_exch_rate   number;
    --vn_qty_in_trade_wt_unit        number;
    --vn_market_price_in_trade_cur   number;
    --vn_total_market_val_trade_cur  number;
    --vn_trade_price_in_trade_cur    number;
    --vn_total_trade_value_trade_cur number;
    vn_trade_qty_exch_unit         number;
    vn_settle_to_base_exch_rate    number;
    vn_total_value_in_leg1_set_cur number;
    vn_total_value_in_leg2_set_cur number;
  
    vt_tbl_frm1_setup             fb_tbl_setup;
    vt_tbl_frm1_instrument        fb_tbl_instrument_data;
    vt_tbl_frm1_instrument_out    fb_tbl_instrument_data;
    vt_tbl_frm1_setup_out         fb_tbl_setup;
    vt_fb_tbl_frm1_error_out      fb_tbl_error;
    vt_tbl_frm2_setup             fb_tbl_setup;
    vt_tbl_frm2_instrument        fb_tbl_instrument_data;
    vt_tbl_frm2_instrument_out    fb_tbl_instrument_data;
    vt_tbl_frm2_setup_out         fb_tbl_setup;
    vt_fb_tbl_frm2_error_out      fb_tbl_error;
    vt_tbl_ind1_setup             fb_tbl_setup;
    vt_tbl_ind1_instrument        fb_tbl_instrument_data;
    vt_tbl_ind1_instrument_out    fb_tbl_instrument_data;
    vt_tbl_ind1_setup_out         fb_tbl_setup;
    vt_fb_tbl_ind1_error_out      fb_tbl_error;
    vt_tbl_ind2_setup             fb_tbl_setup;
    vt_tbl_ind2_instrument        fb_tbl_instrument_data;
    vt_tbl_ind2_instrument_out    fb_tbl_instrument_data;
    vt_tbl_ind2_setup_out         fb_tbl_setup;
    vt_fb_tbl_ind2_error_out      fb_tbl_error;
    vn_cur_row_cnt                number;
    vn_fb_order_sq                number := 1;
    vn_leg1_formula_price         number;
    vc_leg1_formula_price_unit_id varchar2(15);
    vn_leg2_formula_price         number;
    vc_leg2_formula_price_unit_id varchar2(15);
    vc_leg1_cur_id                varchar2(15);
    vc_leg1_price_unit_name       varchar2(50);
    vn_leg1_weight                number(7, 2);
    vc_leg1_qty_unit_id           varchar2(15);
    vc_leg1_weight_unit_id        varchar2(15);
    vc_leg2_cur_id                varchar2(15);
    vc_leg2_price_unit_name       varchar2(50);
    vn_leg2_weight                number(7, 2);
    vc_leg2_weight_unit_id        varchar2(15);
    vc_leg2_qty_unit_id           varchar2(15);
    vc_test_str                   varchar2(100);
    vc_leg_2                      varchar2(1);
  begin
  
    for cur_swaps_rows in cur_swaps
    loop
    
      vt_tbl_frm1_setup          := fb_tbl_setup();
      vt_tbl_frm1_instrument     := fb_tbl_instrument_data();
      vt_tbl_frm1_instrument_out := fb_tbl_instrument_data();
      vt_tbl_frm1_setup_out      := fb_tbl_setup();
      vt_fb_tbl_frm1_error_out   := fb_tbl_error();
      vt_tbl_frm2_setup          := fb_tbl_setup();
      vt_tbl_frm2_instrument     := fb_tbl_instrument_data();
      vt_tbl_frm2_instrument_out := fb_tbl_instrument_data();
      vt_tbl_frm2_setup_out      := fb_tbl_setup();
      vt_fb_tbl_frm2_error_out   := fb_tbl_error();
      vt_tbl_ind1_setup          := fb_tbl_setup();
      vt_tbl_ind1_instrument     := fb_tbl_instrument_data();
      vt_tbl_ind1_instrument_out := fb_tbl_instrument_data();
      vt_tbl_ind1_setup_out      := fb_tbl_setup();
      vt_fb_tbl_ind1_error_out   := fb_tbl_error();
      vt_tbl_ind2_setup          := fb_tbl_setup();
      vt_tbl_ind2_instrument     := fb_tbl_instrument_data();
      vt_tbl_ind2_instrument_out := fb_tbl_instrument_data();
      vt_tbl_ind2_setup_out      := fb_tbl_setup();
      vt_fb_tbl_ind2_error_out   := fb_tbl_error();
    
      if cur_swaps_rows.swap_trade_price_type_1 = 'Fixed' then
        begin
          select ppu.product_price_unit_id
            into vc_leg1_formula_price_unit_id
            from v_ppu_pum ppu
           where ppu.price_unit_id =
                 cur_swaps_rows.swap_trade_price_unit_id_1
             and ppu.product_id = cur_swaps_rows.product_id;
          vn_leg1_formula_price := cur_swaps_rows.swap_trade_price_1;
        exception
          when no_data_found then
            vc_leg1_formula_price_unit_id := cur_swaps_rows.swap_trade_price_unit_id_1; --TODO
        end;
      elsif cur_swaps_rows.swap_trade_price_type_1 = 'Floating' then
        if cur_swaps_rows.swap_float_type_1 = 'Formula' then
          vn_cur_row_cnt := 1;
          vn_fb_order_sq := 1;
          vc_test_str    := cur_swaps_rows.internal_derivative_ref_no ||
                            ' leg 1 ' ||
                            cur_swaps_rows.swap_trade_price_type_1 || ' - ' ||
                            cur_swaps_rows.swap_float_type_1;
          for cc in (select fbs.formula_internal,
                            fbs.formula_display,
                            fbs.formula_name,
                            fbs.formula_id,
                            fbs.price_unit_id
                       from fbs_formula_builder_setup fbs
                      where fbs.formula_id =
                            cur_swaps_rows.swap_formula_id_1)
          loop
          
            vt_tbl_frm1_setup.extend;
            vt_tbl_frm1_setup(1) := fb_typ_setup(cc.formula_id,
                                                 pc_corporate_id,
                                                 cc.formula_name,
                                                 cc.formula_display,
                                                 cc.formula_internal,
                                                 cc.price_unit_id,
                                                 pd_trade_date,
                                                 null,
                                                 null,
                                                 null,
                                                 null);
            vn_cur_row_cnt := vn_cur_row_cnt + 1;
          end loop;
          vn_cur_row_cnt := 1;
        
          for cc1 in (select dtfbi.instrument_id,
                             dtfbi.price_source_id,
                             dtfbi.price_point_id,
                             dtfbi.available_price_id,
                             dtfbi.fb_period_type,
                             dtfbi.fb_period_sub_type,
                             dtfbi.period_month,
                             dtfbi.period_year,
                             dtfbi.period_from_date,
                             dtfbi.period_to_date,
                             dtfbi.no_of_months,
                             dtfbi.no_of_days,
                             dtfbi.period_type_id,
                             dtfbi.delivery_period_id,
                             dtfbi.off_day_price,
                             dtfbi.basis,
                             dtfbi.basis_price_unit_id,
                             dtfbi.fx_rate_type,
                             dtfbi.fx_rate_
                        from dt_fbi dtfbi
                       where dtfbi.internal_derivative_ref_no =
                             cur_swaps_rows.internal_derivative_ref_no
                         and dtfbi.is_deleted = 'N'
                         and dtfbi.process_id = pc_process_id
                         and dtfbi.leg_no = '1')
          loop
            vn_fb_order_sq := 1;
            vt_tbl_frm1_instrument.extend;
            vt_tbl_frm1_instrument(vn_cur_row_cnt) := fb_typ_instrument_data(vn_fb_order_sq,
                                                                             cur_swaps_rows.swap_formula_id_1,
                                                                             cc1.instrument_id,
                                                                             cc1.price_source_id,
                                                                             cc1.price_point_id,
                                                                             cc1.available_price_id,
                                                                             cc1.fb_period_type,
                                                                             cc1.fb_period_sub_type,
                                                                             cc1.period_month,
                                                                             cc1.period_year,
                                                                             cc1.period_from_date,
                                                                             cc1.period_to_date,
                                                                             cc1.no_of_months,
                                                                             cc1.no_of_days,
                                                                             cc1.period_type_id,
                                                                             cc1.delivery_period_id,
                                                                             cc1.off_day_price,
                                                                             cc1.basis,
                                                                             cc1.basis_price_unit_id,
                                                                             cc1.fx_rate_type,
                                                                             cc1.fx_rate_,
                                                                             null,
                                                                             null,
                                                                             null,
                                                                             null,
                                                                             null);
            vn_fb_order_sq := vn_fb_order_sq + 1;
            vn_cur_row_cnt := vn_cur_row_cnt + 1;
          end loop;
          pkg_cdc_formula_builder.sp_calculate_price(vt_tbl_frm1_setup,
                                                     vt_tbl_frm1_instrument,
                                                     vt_tbl_frm1_setup_out,
                                                     vt_tbl_frm1_instrument_out,
                                                     vt_fb_tbl_frm1_error_out,
                                                     pc_dbd_id,
                                                     cur_swaps_rows.derivative_ref_no);
        
          for i in vt_tbl_frm1_setup_out.first .. vt_tbl_frm1_setup_out.last
          loop
            vn_leg1_formula_price         := vt_tbl_frm1_setup_out(i)
                                            .fb_price;
            vc_leg1_formula_price_unit_id := vt_tbl_frm1_setup_out(i)
                                            .price_unit_id;
          end loop;
        
        elsif cur_swaps_rows.swap_float_type_1 = 'Index' then
          vn_fb_order_sq := 1;
          vn_cur_row_cnt := 1;
          vc_test_str    := cur_swaps_rows.internal_derivative_ref_no ||
                            ' leg 1 ' ||
                            cur_swaps_rows.swap_trade_price_type_1 || ' - ' ||
                            cur_swaps_rows.swap_float_type_1;
          for cc1 in (select dtfbi.instrument_id,
                             dtfbi.price_source_id,
                             dtfbi.price_point_id,
                             dtfbi.available_price_id,
                             dtfbi.fb_period_type,
                             dtfbi.fb_period_sub_type,
                             dtfbi.period_month,
                             dtfbi.period_year,
                             dtfbi.period_from_date,
                             dtfbi.period_to_date,
                             dtfbi.no_of_months,
                             dtfbi.no_of_days,
                             dtfbi.period_type_id,
                             dtfbi.delivery_period_id,
                             dtfbi.off_day_price,
                             dtfbi.basis,
                             dtfbi.basis_price_unit_id,
                             dtfbi.fx_rate_type,
                             dtfbi.fx_rate_
                        from dt_fbi dtfbi
                       where dtfbi.internal_derivative_ref_no =
                             cur_swaps_rows.internal_derivative_ref_no
                         and dtfbi.is_deleted = 'N'
                         and dtfbi.process_id = pc_process_id
                         and dtfbi.leg_no = '1')
          loop
          
            vt_tbl_ind1_setup.extend;
            vt_tbl_ind1_setup(1) := fb_typ_setup(cc1.instrument_id,
                                                 pc_corporate_id,
                                                 'index',
                                                 'index',
                                                 '$' || cc1.instrument_id || '$',
                                                 cc1.basis_price_unit_id,
                                                 pd_trade_date,
                                                 null,
                                                 null,
                                                 null,
                                                 null);
          
            vt_tbl_ind1_instrument.extend;
            vt_tbl_ind1_instrument(vn_cur_row_cnt) := fb_typ_instrument_data(vn_fb_order_sq,
                                                                             cc1.instrument_id,
                                                                             cc1.instrument_id,
                                                                             cc1.price_source_id,
                                                                             cc1.price_point_id,
                                                                             cc1.available_price_id,
                                                                             cc1.fb_period_type,
                                                                             cc1.fb_period_sub_type,
                                                                             cc1.period_month,
                                                                             cc1.period_year,
                                                                             cc1.period_from_date,
                                                                             cc1.period_to_date,
                                                                             cc1.no_of_months,
                                                                             cc1.no_of_days,
                                                                             cc1.period_type_id,
                                                                             cc1.delivery_period_id,
                                                                             cc1.off_day_price,
                                                                             cc1.basis,
                                                                             cc1.basis_price_unit_id,
                                                                             cc1.fx_rate_type,
                                                                             cc1.fx_rate_,
                                                                             null,
                                                                             null,
                                                                             null,
                                                                             null,
                                                                             null);
            vn_fb_order_sq := vn_fb_order_sq + 1;
            vn_cur_row_cnt := vn_cur_row_cnt + 1;
          end loop;
        
          pkg_cdc_formula_builder.sp_calculate_price(vt_tbl_ind1_setup,
                                                     vt_tbl_ind1_instrument,
                                                     vt_tbl_ind1_setup_out,
                                                     vt_tbl_ind1_instrument_out,
                                                     vt_fb_tbl_ind1_error_out,
                                                     pc_dbd_id,
                                                     cur_swaps_rows.derivative_ref_no);
        
          for i in vt_tbl_ind1_setup_out.first .. vt_tbl_ind1_setup_out.last
          loop
            vn_leg1_formula_price         := vt_tbl_ind1_setup_out(i)
                                            .fb_price;
            vc_leg1_formula_price_unit_id := vt_tbl_ind1_setup_out(i)
                                            .price_unit_id;
          end loop;
        end if;
      else
        vn_leg1_formula_price         := 0;
        vc_leg1_formula_price_unit_id := null;
      end if;
    
      if cur_swaps_rows.swap_trade_price_type_2 = 'Fixed' then
        vc_test_str := cur_swaps_rows.internal_derivative_ref_no ||
                       ' leg 2 ' || cur_swaps_rows.swap_trade_price_type_2 ||
                       ' - ' || cur_swaps_rows.swap_float_type_2;
        begin
          select ppu.product_price_unit_id
            into vc_leg2_formula_price_unit_id
            from v_ppu_pum ppu
           where ppu.price_unit_id =
                 cur_swaps_rows.swap_trade_price_unit_id_2
             and ppu.product_id = cur_swaps_rows.product_id;
          vn_leg2_formula_price := cur_swaps_rows.swap_trade_price_2;
        exception
          when no_data_found then
            vc_leg1_formula_price_unit_id := cur_swaps_rows.swap_trade_price_unit_id_2; --TODO
        end;
      
      elsif cur_swaps_rows.swap_trade_price_type_2 = 'Floating' then
        if cur_swaps_rows.swap_float_type_2 = 'Formula' then
          if cur_swaps_rows.swap_float_type_1 = 'Formula' then
            if nvl(cur_swaps_rows.swap_formula_id_1, 1) =
               nvl(cur_swaps_rows.swap_formula_id_2, 1) then
              vc_leg_2 := 1;
            else
              vc_leg_2 := 1;
            end if;
          else
            vc_leg_2 := 1;
          end if;
          vc_test_str    := cur_swaps_rows.internal_derivative_ref_no ||
                            ' leg 2 ' ||
                            cur_swaps_rows.swap_trade_price_type_2 || ' - ' ||
                            cur_swaps_rows.swap_float_type_2;
          vn_cur_row_cnt := 1;
          for cc in (select fbs.formula_internal,
                            fbs.formula_display,
                            fbs.formula_name,
                            fbs.formula_id,
                            fbs.price_unit_id
                       from fbs_formula_builder_setup fbs
                      where fbs.formula_id =
                            cur_swaps_rows.swap_formula_id_2)
          loop
          
            vt_tbl_frm2_setup.extend;
            vt_tbl_frm2_setup(1) := fb_typ_setup(cc.formula_id,
                                                 pc_corporate_id,
                                                 cc.formula_name,
                                                 cc.formula_display,
                                                 cc.formula_internal,
                                                 cc.price_unit_id,
                                                 pd_trade_date,
                                                 null,
                                                 null,
                                                 null,
                                                 null);
            vn_cur_row_cnt := vn_cur_row_cnt + 1;
          end loop;
          vn_cur_row_cnt := 1;
        
          for cc1 in (select dtfbi.instrument_id,
                             dtfbi.price_source_id,
                             dtfbi.price_point_id,
                             dtfbi.available_price_id,
                             dtfbi.fb_period_type,
                             dtfbi.fb_period_sub_type,
                             dtfbi.period_month,
                             dtfbi.period_year,
                             dtfbi.period_from_date,
                             dtfbi.period_to_date,
                             dtfbi.no_of_months,
                             dtfbi.no_of_days,
                             dtfbi.period_type_id,
                             dtfbi.delivery_period_id,
                             dtfbi.off_day_price,
                             dtfbi.basis,
                             dtfbi.basis_price_unit_id,
                             dtfbi.fx_rate_type,
                             dtfbi.fx_rate_
                        from dt_fbi dtfbi
                       where dtfbi.internal_derivative_ref_no =
                             cur_swaps_rows.internal_derivative_ref_no
                         and dtfbi.is_deleted = 'N'
                         and dtfbi.process_id = pc_process_id
                         and dtfbi.leg_no = vc_leg_2)
          loop
            vn_fb_order_sq := 1;
            vt_tbl_frm2_instrument.extend;
            vt_tbl_frm2_instrument(vn_cur_row_cnt) := fb_typ_instrument_data(vn_fb_order_sq,
                                                                             cur_swaps_rows.swap_formula_id_2,
                                                                             cc1.instrument_id,
                                                                             cc1.price_source_id,
                                                                             cc1.price_point_id,
                                                                             cc1.available_price_id,
                                                                             cc1.fb_period_type,
                                                                             cc1.fb_period_sub_type,
                                                                             cc1.period_month,
                                                                             cc1.period_year,
                                                                             cc1.period_from_date,
                                                                             cc1.period_to_date,
                                                                             cc1.no_of_months,
                                                                             cc1.no_of_days,
                                                                             cc1.period_type_id,
                                                                             cc1.delivery_period_id,
                                                                             cc1.off_day_price,
                                                                             cc1.basis,
                                                                             cc1.basis_price_unit_id,
                                                                             cc1.fx_rate_type,
                                                                             cc1.fx_rate_,
                                                                             null,
                                                                             null,
                                                                             null,
                                                                             null,
                                                                             null);
            vn_fb_order_sq := vn_fb_order_sq + 1;
            vn_cur_row_cnt := vn_cur_row_cnt + 1;
          end loop;
          pkg_cdc_formula_builder.sp_calculate_price(vt_tbl_frm2_setup,
                                                     vt_tbl_frm2_instrument,
                                                     vt_tbl_frm2_setup_out,
                                                     vt_tbl_frm2_instrument_out,
                                                     vt_fb_tbl_frm2_error_out,
                                                     pc_dbd_id,
                                                     cur_swaps_rows.derivative_ref_no);
        
          for i in vt_tbl_frm2_setup_out.first .. vt_tbl_frm2_setup_out.last
          loop
            vn_leg2_formula_price         := vt_tbl_frm2_setup_out(i)
                                            .fb_price;
            vc_leg2_formula_price_unit_id := vt_tbl_frm2_setup_out(i)
                                            .price_unit_id;
          end loop;
        
        elsif cur_swaps_rows.swap_float_type_2 = 'Index' then
          vn_fb_order_sq := 1;
          vn_cur_row_cnt := 1;
          if cur_swaps_rows.swap_float_type_1 = 'Index' then
            if nvl(cur_swaps_rows.swap_index_instrument_id_1, 1) =
               nvl(cur_swaps_rows.swap_index_instrument_id_2, 1) then
              vc_leg_2 := 1;
            else
              vc_leg_2 := 2;
            end if;
          else
            vc_leg_2 := 1;
          end if;
        
          vc_test_str := cur_swaps_rows.internal_derivative_ref_no ||
                         ' leg 2 ' ||
                         cur_swaps_rows.swap_trade_price_type_2 || ' - ' ||
                         cur_swaps_rows.swap_float_type_2;
          for cc1 in (select dtfbi.instrument_id,
                             dtfbi.price_source_id,
                             dtfbi.price_point_id,
                             dtfbi.available_price_id,
                             dtfbi.fb_period_type,
                             dtfbi.fb_period_sub_type,
                             dtfbi.period_month,
                             dtfbi.period_year,
                             dtfbi.period_from_date,
                             dtfbi.period_to_date,
                             dtfbi.no_of_months,
                             dtfbi.no_of_days,
                             dtfbi.period_type_id,
                             dtfbi.delivery_period_id,
                             dtfbi.off_day_price,
                             dtfbi.basis,
                             dtfbi.basis_price_unit_id,
                             dtfbi.fx_rate_type,
                             dtfbi.fx_rate_
                        from dt_fbi dtfbi
                       where dtfbi.internal_derivative_ref_no =
                             cur_swaps_rows.internal_derivative_ref_no
                         and dtfbi.is_deleted = 'N'
                         and dtfbi.process_id = pc_process_id
                         and dtfbi.leg_no = vc_leg_2)
          loop
          
            vt_tbl_ind2_setup.extend;
            vt_tbl_ind2_setup(1) := fb_typ_setup(cc1.instrument_id,
                                                 pc_corporate_id,
                                                 'index',
                                                 'index',
                                                 '$' || cc1.instrument_id || '$',
                                                 cc1.basis_price_unit_id,
                                                 pd_trade_date,
                                                 null,
                                                 null,
                                                 null,
                                                 null);
          
            vt_tbl_ind2_instrument.extend;
            vt_tbl_ind2_instrument(vn_cur_row_cnt) := fb_typ_instrument_data(vn_fb_order_sq,
                                                                             cc1.instrument_id,
                                                                             cc1.instrument_id,
                                                                             cc1.price_source_id,
                                                                             cc1.price_point_id,
                                                                             cc1.available_price_id,
                                                                             cc1.fb_period_type,
                                                                             cc1.fb_period_sub_type,
                                                                             cc1.period_month,
                                                                             cc1.period_year,
                                                                             cc1.period_from_date,
                                                                             cc1.period_to_date,
                                                                             cc1.no_of_months,
                                                                             cc1.no_of_days,
                                                                             cc1.period_type_id,
                                                                             cc1.delivery_period_id,
                                                                             cc1.off_day_price,
                                                                             cc1.basis,
                                                                             cc1.basis_price_unit_id,
                                                                             cc1.fx_rate_type,
                                                                             cc1.fx_rate_,
                                                                             null,
                                                                             null,
                                                                             null,
                                                                             null,
                                                                             null);
            vn_fb_order_sq := vn_fb_order_sq + 1;
            vn_cur_row_cnt := vn_cur_row_cnt + 1;
          end loop;
        
          pkg_cdc_formula_builder.sp_calculate_price(vt_tbl_ind2_setup,
                                                     vt_tbl_ind2_instrument,
                                                     vt_tbl_ind2_setup_out,
                                                     vt_tbl_ind2_instrument_out,
                                                     vt_fb_tbl_ind2_error_out,
                                                     pc_dbd_id,
                                                     cur_swaps_rows.derivative_ref_no);
        
          for i in vt_tbl_ind2_setup_out.first .. vt_tbl_ind2_setup_out.last
          loop
            vn_leg2_formula_price         := vt_tbl_ind2_setup_out(i)
                                            .fb_price;
            vc_leg2_formula_price_unit_id := vt_tbl_ind2_setup_out(i)
                                            .price_unit_id;
          end loop;
        end if;
      else
        vn_leg2_formula_price         := 0;
        vc_leg2_formula_price_unit_id := null;
      end if;
      vc_test_str := 's1';
    
      -- Trade Qty in Exchange Weight Unit
      if cur_swaps_rows.gravity is not null then
        if cur_swaps_rows.quantity_unit_id <>
           cur_swaps_rows.lot_size_unit_id then
          vn_trade_qty_exch_unit := pkg_general.fn_mass_volume_qty_conversion(cur_swaps_rows.product_id,
                                                                              cur_swaps_rows.quantity_unit_id,
                                                                              cur_swaps_rows.lot_size_unit_id,
                                                                              cur_swaps_rows.open_quantity,
                                                                              cur_swaps_rows.gravity,
                                                                              cur_swaps_rows.gravity_type,
                                                                              cur_swaps_rows.density_mass_qty_unit_id,
                                                                              cur_swaps_rows.density_volume_qty_unit_id);
        else
          vn_trade_qty_exch_unit := pkg_general.f_get_converted_quantity(null,
                                                                         cur_swaps_rows.quantity_unit_id,
                                                                         cur_swaps_rows.lot_size_unit_id,
                                                                         cur_swaps_rows.open_quantity);
        end if;
      end if;
    
      /*get the exchange rates
      1. from broker to base currency
      2. trade to base currency
      */
      vc_test_str := 's2';
      if cur_swaps_rows.settlement_cur_id is not null then
        vn_settle_to_base_exch_rate := f_currency_exchange_rate(pd_trade_date,
                                                                pc_corporate_id,
                                                                cur_swaps_rows.prompt_date,
                                                                cur_swaps_rows.settlement_cur_id,
                                                                cur_swaps_rows.base_cur_id);
      else
        vn_settle_to_base_exch_rate := 0;
      end if;
      vc_test_str := 's3';
      if cur_swaps_rows.broker_comm_cur_id is not null then
        vn_brokr_cur_to_base_exch_rate := f_currency_exchange_rate(pd_trade_date,
                                                                   pc_corporate_id,
                                                                   cur_swaps_rows.prompt_date,
                                                                   cur_swaps_rows.broker_comm_cur_id,
                                                                   cur_swaps_rows.base_cur_id);
      else
        vn_brokr_cur_to_base_exch_rate := 0;
      end if;
      vc_test_str := 's4';
      if cur_swaps_rows.clearer_comm_cur_id is not null then
        vn_clr_cur_to_base_exch_rate := f_currency_exchange_rate(pd_trade_date,
                                                                 pc_corporate_id,
                                                                 cur_swaps_rows.prompt_date,
                                                                 cur_swaps_rows.clearer_comm_cur_id,
                                                                 cur_swaps_rows.base_cur_id);
      else
        vn_clr_cur_to_base_exch_rate := 0;
      end if;
      vc_test_str := 's5';
      /*
      calcualate trade pnl in trade currency
      1. convert trade qty from trade price unit weight unit to trade weight unit
      2. get the market price in trade currency
      3. market value in trade currency = qty in trade weight unit(1) * market price in trade currency(2)
      4. trade value in trade currency = trade price in trade currency (from drt) * trade qty in trade unit(1)
      5. pnl in trade currency = market value in trade currency(2) - trade value in trade currency(4)*/
    
      vc_test_str := 's6';
      begin
        select pum.cur_id,
               pum.price_unit_name,
               pum.weight,
               pum.weight_unit_id,
               qum.qty_unit_id
          into vc_leg1_cur_id,
               vc_leg1_price_unit_name,
               vn_leg1_weight,
               vc_leg1_weight_unit_id,
               vc_leg1_qty_unit_id
          from v_ppu_pum                pum,
               qum_quantity_unit_master qum
         where pum.product_price_unit_id = vc_leg1_formula_price_unit_id
           and pum.weight_unit_id = qum.qty_unit_id;
      exception
        when no_data_found then
          vc_leg1_cur_id          := null;
          vc_leg1_price_unit_name := null;
          vn_leg1_weight          := 0;
          vc_leg1_weight_unit_id  := null;
          vc_leg1_qty_unit_id     := null;
      end;
      vc_test_str := 's7';
      if nvl(vn_leg1_formula_price, 0) = 0 then
        vn_total_value_in_leg1_set_cur := 0;
      else
        if nvl(vc_leg1_cur_id, 'NA') <> 'NA' and
           nvl(cur_swaps_rows.settlement_cur_id, 'NA') <> 'NA' then
        
          if cur_swaps_rows.gravity is not null then
            vn_total_value_in_leg1_set_cur := (vn_leg1_formula_price /
                                              nvl(vn_leg1_weight, 1)) *
                                              pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                       vc_leg1_cur_id,
                                                                                       cur_swaps_rows.settlement_cur_id,
                                                                                       pd_trade_date,
                                                                                       1) *
                                             
                                              (pkg_general.fn_mass_volume_qty_conversion(cur_swaps_rows.product_id,
                                                                                         cur_swaps_rows.quantity_unit_id,
                                                                                         vc_leg1_qty_unit_id,
                                                                                         cur_swaps_rows.open_quantity,
                                                                                         cur_swaps_rows.gravity,
                                                                                         cur_swaps_rows.gravity_type,
                                                                                         cur_swaps_rows.density_mass_qty_unit_id,
                                                                                         cur_swaps_rows.density_volume_qty_unit_id));
          else
            vn_total_value_in_leg1_set_cur := (vn_leg1_formula_price /
                                              nvl(vn_leg1_weight, 1)) *
                                              pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                       vc_leg1_cur_id,
                                                                                       cur_swaps_rows.settlement_cur_id,
                                                                                       pd_trade_date,
                                                                                       1) *
                                              (pkg_general.f_get_converted_quantity(cur_swaps_rows.product_id,
                                                                                    cur_swaps_rows.quantity_unit_id,
                                                                                    vc_leg1_qty_unit_id,
                                                                                    cur_swaps_rows.open_quantity));
          
          end if;
        
        else
          vn_total_value_in_leg1_set_cur := 0;
        end if;
      end if;
    
      begin
        select pum.cur_id,
               pum.price_unit_name,
               pum.weight,
               pum.weight_unit_id,
               qum.qty_unit_id
          into vc_leg2_cur_id,
               vc_leg2_price_unit_name,
               vn_leg2_weight,
               vc_leg2_weight_unit_id,
               vc_leg2_qty_unit_id
          from v_ppu_pum                pum,
               qum_quantity_unit_master qum
         where pum.product_price_unit_id = vc_leg2_formula_price_unit_id
           and pum.weight_unit_id = qum.qty_unit_id;
      exception
        when no_data_found then
          vc_leg2_cur_id          := null;
          vc_leg2_price_unit_name := null;
          vn_leg2_weight          := 0;
          vc_leg2_weight_unit_id  := null;
          vc_leg2_qty_unit_id     := null;
      end;
      vc_test_str := 's8';
      if nvl(vn_leg2_formula_price, 0) = 0 then
        vn_total_value_in_leg2_set_cur := 0;
      else
        if nvl(vc_leg2_cur_id, 'NA') <> 'NA' and
           nvl(cur_swaps_rows.settlement_cur_id, 'NA') <> 'NA' then
          if cur_swaps_rows.gravity is not null then
            vn_total_value_in_leg2_set_cur := (vn_leg2_formula_price /
                                              nvl(vn_leg2_weight, 1)) *
                                              pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                       vc_leg2_cur_id,
                                                                                       cur_swaps_rows.settlement_cur_id,
                                                                                       pd_trade_date,
                                                                                       1) *
                                              (pkg_general.fn_mass_volume_qty_conversion(cur_swaps_rows.product_id,
                                                                                         cur_swaps_rows.quantity_unit_id,
                                                                                         vc_leg2_qty_unit_id,
                                                                                         cur_swaps_rows.open_quantity,
                                                                                         cur_swaps_rows.gravity,
                                                                                         cur_swaps_rows.gravity_type,
                                                                                         cur_swaps_rows.density_mass_qty_unit_id,
                                                                                         cur_swaps_rows.density_volume_qty_unit_id));
          
          else
            vn_total_value_in_leg2_set_cur := (vn_leg2_formula_price /
                                              nvl(vn_leg2_weight, 1)) *
                                              pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                       vc_leg2_cur_id,
                                                                                       cur_swaps_rows.settlement_cur_id,
                                                                                       pd_trade_date,
                                                                                       1) *
                                              (pkg_general.f_get_converted_quantity(cur_swaps_rows.product_id,
                                                                                    cur_swaps_rows.quantity_unit_id,
                                                                                    vc_leg2_qty_unit_id,
                                                                                    cur_swaps_rows.open_quantity));
          
          end if;
        
        else
          vn_total_value_in_leg2_set_cur := 0;
        end if;
      end if;
      vc_test_str := 's9';
      if cur_swaps_rows.trade_type = 'Buy' then
      
        vn_pnl_value_in_sett_cur := vn_total_value_in_leg1_set_cur -
                                    vn_total_value_in_leg2_set_cur;
      else
        vn_pnl_value_in_sett_cur := vn_total_value_in_leg2_set_cur -
                                    vn_total_value_in_leg1_set_cur;
      end if;
    
      /*
      for sales trades pnl = trade price - market price
      for buy trades pnl =  market price - trade price
      
      IF cur_swaps_rows.trade_type = 'Buy' THEN
        vn_pnl_value_in_trade_cur := vn_total_market_val_trade_cur -
                                     vn_total_trade_value_trade_cur;
      ELSE
        vn_pnl_value_in_trade_cur := vn_total_trade_value_trade_cur -
                                     vn_total_market_val_trade_cur;
      END IF;
      
      /*
      calcualte net pnl in base currency
       1. calculate trade value in base currency
       a) convert trade qty to price unit weight unit
       b) multiply a by trade price
       c) multipy by trade to base exchange rate
       2. calcualate broker commission in base currency
       3. pnl value in base currency = pnl value in trade currency * exchange rate from trade to base
       4. net pnl in base currency = pnl value in base currency (3) - broker commission in base currency
       */
      /*vn_total_trade_value_base_cur := vn_trade_to_base_exch_rate *
      vn_total_trade_value_trade_cur;*/
    
      /* 18-jul-2009 . commented this and replaced this with above code
      vn_total_trade_value_base_cur := pkg_general.f_get_converted_quantity(null,
                                                                            cur_futures_rows.trade_qty_unit_id,
                                                                            cur_futures_rows.weight_unit_id,
                                                                            cur_futures_rows.trade_qty) *
                                       cur_futures_rows.trade_price *
                                       vn_trade_to_base_exch_rate; */
    
      vn_broker_comm_in_base_cur := cur_swaps_rows.broker_comm_amt *
                                    vn_brokr_cur_to_base_exch_rate;
      vn_clr_comm_in_base_cur    := cur_swaps_rows.clearer_comm_amt *
                                    vn_clr_cur_to_base_exch_rate;
      vn_pnl_value_in_base_cur   := vn_pnl_value_in_sett_cur *
                                    vn_settle_to_base_exch_rate;
      --Fix 10th Nov
      --vn_net_pnl_in_base_cur        := vn_pnl_value_in_base_cur -
      --                                 nvl(vn_broker_comm_in_base_cur,0) - nvl(vn_clr_comm_in_base_cur,0);
      vn_net_pnl_in_base_cur := vn_pnl_value_in_base_cur;
    
      --  all this check should be removed later
      if vn_net_pnl_in_base_cur is null then
        vn_net_pnl_in_base_cur := 0;
      end if;
    
      if vn_pnl_value_in_sett_cur is null then
        vn_pnl_value_in_sett_cur := 0;
      end if;
    
      insert into dpd_derivative_pnl_daily
        (internal_derivative_ref_no,
         derivative_ref_no,
         eod_trade_date,
         trade_date,
         corporate_id,
         corporate_name,
         trader_id,
         trader_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         dr_id,
         instrument_id,
         instrument_name,
         instrument_symbol,
         instrument_type_id,
         instrument_type,
         instrument_type_name,
         instrument_sub_type_id,
         instrument_sub_type,
         derivative_def_id,
         derivative_def_name,
         derivative_traded_on,
         derivative_prodct_id,
         derivative_prodct_name,
         exchange_id,
         exchange_name,
         exchange_code,
         lot_size,
         lot_size_unit_id,
         lot_size_unit,
         price_point_id,
         price_point_name,
         period_type_id,
         period_type_name,
         period_type_display_name,
         period_month,
         period_year,
         period_date,
         prompt_date,
         dr_id_name,
         trade_type,
         deal_type_id,
         deal_type_name,
         deal_type_display_name,
         is_multiple_leg_involved,
         strategy_id,
         strategy_name,
         strategy_desc,
         strategy_def_name,
         group_id,
         group_name,
         purpose_id,
         purpose_name,
         purpose_display_name,
         external_ref_no,
         cp_profile_id,
         cp_name,
         master_contract_id,
         broker_profile_id,
         broker_name,
         broker_account_id,
         broker_account_name,
         broker_account_type,
         broker_comm_type_id,
         broker_comm_amt,
         broker_comm_cur_id,
         broker_comm_cur_code,
         clearer_profile_id,
         clearer_name,
         clearer_account_id,
         clearer_account_name,
         clearer_account_type,
         clearer_comm_type_id,
         clearer_comm_amt,
         clearer_comm_cur_id,
         clearer_comm_cur_code,
         product_id,
         product_name,
         quality_id,
         quality_name,
         quantity_unit_id,
         quantity_unit,
         total_lots,
         total_quantity,
         open_lots,
         open_quantity,
         exercised_lots,
         exercised_quantity,
         expired_lots,
         expired_quantity,
         trade_price_type_id,
         trade_price,
         trade_price_unit_id,
         trade_price_cur_id,
         trade_price_cur_code,
         trade_price_weight,
         trade_price_weight_unit_id,
         trade_price_weight_unit,
         formula_id,
         formula_name,
         formula_display,
         index_instrument_id,
         index_instrument_name,
         strike_price,
         strike_price_unit_id,
         strike_price_cur_id,
         strike_price_cur_code,
         strike_price_weight,
         strike_price_weight_unit_id,
         strike_price_weight_unit,
         premium_discount,
         premium_discount_price_unit_id,
         pd_price_cur_id,
         pd_price_cur_code,
         pd_price_weight,
         pd_price_weight_unit_id,
         pd_price_weight_unit,
         premium_due_date,
         nominee_profile_id,
         nominee_name,
         leg_no,
         option_expiry_date,
         parent_int_derivative_ref_no,
         market_location_country,
         market_location_state,
         market_location_city,
         is_what_if,
         payment_term_id,
         payment_term,
         payment_due_date,
         closed_lots,
         closed_quantity,
         status,
         settlement_cur_id,
         settlement_cur_code,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         parent_instrument_type,
         clearer_comm_in_base,
         broker_comm_in_base,
         clearer_exch_rate,
         broker_exch_rate,
         trade_cur_to_base_exch_rate,
         pnl_type,
         pnl_in_base_cur,
         pnl_in_trade_cur,
         base_cur_id,
         base_cur_code,
         process_id,
         trade_qty_in_exch_unit,
         int_trade_parent_der_ref_no,
         is_internal_trade,
         available_price_id,
         average_from_date,
         average_to_date,
         swap_type_1,
         swap_trade_price_type_1,
         swap_float_type_1,
         swap_trade_price_1,
         swap_trade_price_unit_id_1,
         swap_trade_price_unit_1,
         swap_index_instrument_id_1,
         swap_formula_id_1,
         swap_type_2,
         swap_trade_price_type_2,
         swap_float_type_2,
         swap_trade_price_2,
         swap_trade_price_unit_id_2,
         swap_trade_price_unit_2,
         swap_index_instrument_id_2,
         swap_formula_id_2,
         swap_product1,
         swap_product_quality1,
         swap_product2,
         swap_product_quality2,
         pricing_invoicing_status,
         approval_status,
         trading_fee,
         clearing_fee,
         trading_clearing_fee,
         pnl_in_sett_cur)
      values
        (cur_swaps_rows.internal_derivative_ref_no,
         cur_swaps_rows.derivative_ref_no,
         cur_swaps_rows.eod_trade_date,
         cur_swaps_rows.trade_date,
         cur_swaps_rows.corporate_id,
         cur_swaps_rows.corporate_name,
         cur_swaps_rows.trader_id,
         cur_swaps_rows.tradername,
         cur_swaps_rows.profit_center_id,
         cur_swaps_rows.profit_center_name,
         cur_swaps_rows.profit_center_short_name,
         cur_swaps_rows.dr_id,
         cur_swaps_rows.instrument_id,
         cur_swaps_rows.instrument_name,
         cur_swaps_rows.instrument_symbol,
         cur_swaps_rows.instrument_type_id,
         cur_swaps_rows.instrument_type,
         cur_swaps_rows.instrument_display_name,
         cur_swaps_rows.instrument_sub_type_id,
         cur_swaps_rows.instrument_sub_type,
         cur_swaps_rows.derivative_def_id,
         cur_swaps_rows.derivative_def_name,
         cur_swaps_rows.traded_on,
         cur_swaps_rows.product_id,
         cur_swaps_rows.product_desc,
         cur_swaps_rows.exchange_id,
         cur_swaps_rows.exchange_name,
         cur_swaps_rows.exchange_code,
         cur_swaps_rows.lot_size,
         cur_swaps_rows.lot_size_unit_id,
         cur_swaps_rows.lot_size_qty_unit,
         cur_swaps_rows.price_point_id,
         cur_swaps_rows.price_point_name,
         cur_swaps_rows.period_type_id,
         cur_swaps_rows.period_type_name,
         cur_swaps_rows.period_type_display_name,
         cur_swaps_rows.period_month,
         cur_swaps_rows.period_year,
         cur_swaps_rows.period_date,
         cur_swaps_rows.prompt_date,
         cur_swaps_rows.dr_id_name,
         cur_swaps_rows.trade_type,
         cur_swaps_rows.deal_type_id,
         cur_swaps_rows.deal_type_name,
         cur_swaps_rows.deal_type_display_name,
         cur_swaps_rows.is_multiple_leg_involved,
         cur_swaps_rows.strategy_id,
         cur_swaps_rows.strategy_name,
         cur_swaps_rows.description,
         cur_swaps_rows.strategy_def_name,
         cur_swaps_rows.groupid,
         cur_swaps_rows.groupname,
         cur_swaps_rows.purpose_id,
         cur_swaps_rows.purpose_name,
         cur_swaps_rows.purpose_display_name,
         cur_swaps_rows.external_ref_no,
         cur_swaps_rows.cp_profile_id,
         cur_swaps_rows.cp_name,
         cur_swaps_rows.master_contract_id,
         cur_swaps_rows.broker_profile_id,
         cur_swaps_rows.broker_name,
         cur_swaps_rows.broker_account_id,
         cur_swaps_rows.broker_account_name,
         cur_swaps_rows.broker_account_type,
         cur_swaps_rows.broker_comm_type_id,
         cur_swaps_rows.broker_comm_amt,
         cur_swaps_rows.broker_comm_cur_id,
         cur_swaps_rows.broker_cur_code,
         cur_swaps_rows.clearer_profile_id,
         cur_swaps_rows.clearer_name,
         cur_swaps_rows.clearer_account_id,
         cur_swaps_rows.clearer_account_name,
         cur_swaps_rows.clearer_account_type,
         cur_swaps_rows.clearer_comm_type_id,
         cur_swaps_rows.clearer_comm_amt,
         cur_swaps_rows.clearer_comm_cur_id,
         cur_swaps_rows.clearer_cur_code,
         cur_swaps_rows.product_id,
         cur_swaps_rows.product,
         cur_swaps_rows.quality_id,
         cur_swaps_rows.quality_name,
         cur_swaps_rows.quantity_unit_id,
         cur_swaps_rows.quantityname,
         cur_swaps_rows.open_lots, -- total_lots,--siva
         cur_swaps_rows.open_quantity, -- .total_quantity,--siva
         cur_swaps_rows.open_lots,
         cur_swaps_rows.open_quantity,
         cur_swaps_rows.exercised_lots,
         cur_swaps_rows.exercised_quantity,
         cur_swaps_rows.expired_lots,
         cur_swaps_rows.expired_quantity,
         cur_swaps_rows.trade_price_type_id,
         cur_swaps_rows.trade_price,
         cur_swaps_rows.trade_price_unit_id,
         cur_swaps_rows.trade_cur_id,
         cur_swaps_rows.trade_cur_code,
         cur_swaps_rows.trade_weight,
         cur_swaps_rows.trade_weight_unit_id,
         cur_swaps_rows.trade_qty_unit,
         cur_swaps_rows.formula_id,
         cur_swaps_rows.formula_name,
         cur_swaps_rows.formula_display,
         cur_swaps_rows.index_instrument_id,
         cur_swaps_rows.index_instrument_name,
         cur_swaps_rows.strike_price,
         cur_swaps_rows.strike_price_unit_id,
         cur_swaps_rows.strike_cur_id,
         cur_swaps_rows.strike_cur_code,
         cur_swaps_rows.strike_weight,
         cur_swaps_rows.strike_weight_unit_id,
         cur_swaps_rows.strike_qty_unit,
         cur_swaps_rows.premium_discount,
         cur_swaps_rows.premium_discount_price_unit_id,
         cur_swaps_rows.pd_cur_id,
         cur_swaps_rows.pd_cur_code,
         cur_swaps_rows.pd_weight,
         cur_swaps_rows.pd_weight_unit_id,
         cur_swaps_rows.pd_qty_unit,
         cur_swaps_rows.premium_due_date,
         cur_swaps_rows.nominee_profile_id,
         cur_swaps_rows.nominee_name,
         cur_swaps_rows.leg_no,
         cur_swaps_rows.option_expiry_date,
         cur_swaps_rows.parent_int_derivative_ref_no,
         cur_swaps_rows.market_location_country,
         cur_swaps_rows.market_location_state,
         cur_swaps_rows.market_location_city,
         cur_swaps_rows.is_what_if,
         cur_swaps_rows.payment_term,
         cur_swaps_rows.payment_term,
         cur_swaps_rows.payment_due_date,
         cur_swaps_rows.closed_lots,
         cur_swaps_rows.closed_quantity,
         cur_swaps_rows.status,
         cur_swaps_rows.settlement_cur_id,
         cur_swaps_rows.settlement_cur_code,
         cur_swaps_rows.group_cur_id,
         cur_swaps_rows.group_cur_code,
         cur_swaps_rows.group_qty_unit_id,
         cur_swaps_rows.gcd_qty_unit,
         cur_swaps_rows.base_qty_unit_id,
         cur_swaps_rows.base_qty_unit,
         cur_swaps_rows.parent_instrument_type,
         vn_clr_comm_in_base_cur,
         vn_broker_comm_in_base_cur,
         vn_clr_cur_to_base_exch_rate,
         vn_brokr_cur_to_base_exch_rate,
         vn_settle_to_base_exch_rate,
         cur_swaps_rows.pnl_type,
         vn_net_pnl_in_base_cur,
         vn_pnl_value_in_sett_cur,
         cur_swaps_rows.base_cur_id,
         cur_swaps_rows.base_cur_code,
         cur_swaps_rows.process_id,
         vn_trade_qty_exch_unit,
         cur_swaps_rows.int_trade_parent_der_ref_no,
         cur_swaps_rows.is_internal_trade,
         cur_swaps_rows.available_price_id,
         cur_swaps_rows.average_from_date,
         cur_swaps_rows.average_to_date,
         cur_swaps_rows.swap_type_1,
         cur_swaps_rows.swap_trade_price_type_1,
         cur_swaps_rows.swap_float_type_1,
         vn_leg1_formula_price,
         vc_leg1_formula_price_unit_id,
         vc_leg1_price_unit_name,
         cur_swaps_rows.swap_index_instrument_id_1,
         cur_swaps_rows.swap_formula_id_1,
         cur_swaps_rows.swap_type_2,
         cur_swaps_rows.swap_trade_price_type_2,
         cur_swaps_rows.swap_float_type_2,
         vn_leg2_formula_price,
         vc_leg2_formula_price_unit_id,
         vc_leg2_price_unit_name,
         cur_swaps_rows.swap_index_instrument_id_2,
         cur_swaps_rows.swap_formula_id_2,
         cur_swaps_rows.swap_product1,
         cur_swaps_rows.swap_product_quality1,
         cur_swaps_rows.swap_product2,
         cur_swaps_rows.swap_product_quality2,
         cur_swaps_rows.pricing_invoicing_status,
         cur_swaps_rows.approval_status,
         cur_swaps_rows.trading_fee,
         cur_swaps_rows.clearing_fee,
         cur_swaps_rows.trading_clearing_fee,
         vn_pnl_value_in_sett_cur);
    
    end loop;
  exception
    when others then
      dbms_output.put_line(sqlerrm || dbms_utility.format_error_backtrace ||
                           ' at ' || vc_test_str);
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_swap_unrealized_pnl',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm || ' at ' ||
                                                           vc_test_str,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
  end;

  procedure sp_calc_option_unrealized_pnl(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2,
                                          pc_process      varchar2) is
    /******************************************************************************************************************************************
    procedure name                            : sp_calc_option_unrealized_pnl
    author                                    : janna
    created date                              : 10th jan 2009
    purpose                                   : calculate the unrealized pnl for options as on eod date
    parameters                                :
    pc_corporate_id                           : corporate id
    pd_trade_date                             : eod date id
    pc_process_id                             : eod reference no
    modification history                      :
    modified date                             :
    modified by                               :
    modify description                        :
    ******************************************************************************************************************************************/
    cursor cur_options is
      select dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             pd_trade_date eod_trade_date,
             dt.trade_date,
             dt.corporate_id,
             ak.corporate_name,
             dt.trader_id,
             gab.firstname || gab.lastname tradername,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dt.dr_id,
             drm.instrument_id,
             dim.instrument_name,
             dim.instrument_symbol,
             dim.instrument_type_id,
             irm.instrument_type,
             irm.instrument_display_name,
             dim.instrument_sub_type_id,
             istm.instrument_sub_type,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             pdd.traded_on,
             pdd.product_id,
             pdm.product_desc,
             emt.exchange_id,
             emt.exchange_name,
             emt.exchange_code,
             pdd.lot_size,
             pdd.lot_size_unit_id,
             qum.qty_unit lot_size_qty_unit,
             drm.price_point_id,
             pp.price_point_name,
             drm.period_type_id,
             pm.period_type_name,
             pm.period_type_display_name,
             drm.period_month,
             drm.period_year,
             (case
               when drm.period_date is null then
                case
               when drm.period_month is not null and
                    drm.period_year is not null then
                to_date('01-' || drm.period_month || '-' || drm.period_year,
                        'dd-Mon-yyyy')
               else
                drm.prompt_date
             end else drm.period_date end) period_date,
             drm.prompt_date,
             drm.dr_id_name,
             dt.trade_type,
             dt.deal_type_id,
             dtm.deal_type_name,
             dtm.deal_type_display_name,
             dtm.is_multiple_leg_involved,
             null deal_category,
             null deal_sub_category,
             dt.strategy_id,
             css.strategy_name,
             css.description,
             sdm.strategy_def_name,
             ak.groupid,
             gcd.groupname,
             dt.purpose_id,
             dpm.purpose_name,
             dpm.purpose_display_name,
             dt.external_ref_no,
             dt.cp_profile_id,
             phd_cp.companyname cp_name,
             dt.master_contract_id,
             dt.broker_profile_id,
             phd_broker.companyname broker_name,
             dt.broker_account_id,
             bca_broker.account_name broker_account_name,
             bca_broker.account_type broker_account_type,
             dt.broker_comm_type_id,
             dt.broker_comm_amt,
             dt.broker_comm_cur_id,
             cm_broker_cur.cur_code broker_cur_code,
             dt.clearer_profile_id,
             phd_clearer.companyname clearer_name,
             dt.clearer_account_id,
             bca_clearer.account_name clearer_account_name,
             bca_clearer.account_type clearer_account_type,
             dt.clearer_comm_type_id,
             dt.clearer_comm_amt,
             dt.clearer_comm_cur_id,
             cm_clearer.cur_code clearer_cur_code,
             dt.product_id product,
             pdm.product_desc productdesc,
             dt.quality_id,
             qat.quality_name,
             qat.gravity,
             gtm.gravity_type_name gravity_type,
             qat.density_mass_qty_unit_id,
             qat.density_volume_qty_unit_id,
             dt.quantity_unit_id,
             qum_um.qty_unit quantityname,
             dt.total_lots,
             dt.total_quantity,
             dt.open_lots,
             dt.open_quantity,
             dt.exercised_lots,
             dt.exercised_quantity,
             dt.expired_lots,
             dt.expired_quantity,
             dt.trade_price_type_id,
             dt.trade_price,
             dt.trade_price_unit_id,
             pum_trade.cur_id trade_cur_id,
             cm_trade.cur_code trade_cur_code,
             pum_trade.weight trade_weight,
             pum_trade.weight_unit_id trade_weight_unit_id,
             qum_trade.qty_unit trade_qty_unit,
             dt.formula_id,
             fbs.formula_name,
             fbs.formula_display,
             dt.index_instrument_id,
             dim_index.instrument_name index_instrument_name,
             dt.strike_price,
             dt.strike_price_unit_id,
             pum_strike.cur_id strike_cur_id,
             cm_strike.cur_code strike_cur_code,
             pum_strike.weight strike_weight,
             pum_strike.weight_unit_id strike_weight_unit_id,
             qum_strike.qty_unit strike_qty_unit,
             dt.premium_discount,
             dt.premium_discount_price_unit_id,
             pum_pd.cur_id pd_cur_id,
             cm_pd.cur_code pd_cur_code,
             pum_pd.weight pd_weight,
             pum_pd.weight_unit_id pd_weight_unit_id,
             qum_pd.qty_unit pd_qty_unit,
             dt.premium_due_date,
             dt.nominee_profile_id,
             phd_nominee.companyname nominee_name,
             dt.leg_no,
             dt.option_expiry_date,
             dt.parent_int_derivative_ref_no,
             dt.market_location_country,
             dt.market_location_state,
             dt.market_location_city,
             dt.is_what_if,
             dt.payment_term,
             pym.payment_term payment_term_name,
             dt.payment_due_date,
             dt.closed_lots,
             dt.closed_quantity,
             null as is_new_trade_date,
             dt.status,
             dt.settlement_cur_id,
             cm_settlement.cur_code settlement_cur_code,
             null as in_out_at_money_status,
             null as in_out_at_money_value,
             null as exercise_date,
             null as expiry_date,
             gcd_group.group_cur_id,
             cm_gcd.cur_code group_cur_code,
             gcd_group.group_qty_unit_id,
             qum_gcd.qty_unit gcd_qty_unit,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             null internal_close_out_ref_no,
             null close_out_ref_no,
             null close_out_date,
             edq.price settlement_price,
             edq.price_unit_id settlement_price_unit_id,
             pum_settle.cur_id settlement_price_cur_id,
             cm_settle.cur_code settlemet_price_cur_code,
             pum_settle.weight settlement_price_weight,
             pum_settle.weight_unit_id settlement_weight_unit_id,
             qum_settle.qty_unit settlement_weight_unit,
             (case
               when irm.instrument_type in ('Option Put', 'Option Call') then
                'Option'
               else
                irm.instrument_type
             end) as parent_instrument_type,
             null as clearer_comm_in_base,
             null as broker_comm_in_base,
             null as clearer_exch_rate,
             null as broker_exch_rate,
             null as trade_cur_to_base_exch_rate,
             'Unrealized' as pnl_type,
             null as pnl_in_base_cur,
             null as pnl_in_trade_cur,
             cm_base.cur_id as base_cur_id,
             ak.base_currency_name base_cur_code,
             du.underlying_dr_id underlying_future_dr_id,
             drm_du.dr_id_name underlying_future_dr_id_name,
             drm_du.expiry_date underlying_future_expiry_date,
             null as underlying_future_quote_price,
             null as underlying_fut_price_unit_id,
             pc_process_id process_id
      
        from dt_derivative_trade            dt,
             ak_corporate                   ak,
             ak_corporate_user              aku,
             gab_globaladdressbook          gab,
             cpc_corporate_profit_center    cpc,
             drm_derivative_master          drm,
             dim_der_instrument_master      dim,
             irm_instrument_type_master     irm,
             istm_instr_sub_type_master     istm,
             pdd_product_derivative_def     pdd,
             pdm_productmaster              pdm,
             emt_exchangemaster             emt,
             qum_quantity_unit_master       qum,
             pp_price_point                 pp,
             pm_period_master               pm,
             dtm_deal_type_master           dtm,
             css_corporate_strategy_setup   css,
             sdm_strategy_definition_master sdm,
             gcd_groupcorporatedetails      gcd,
             dpm_derivative_purpose_master  dpm,
             phd_profileheaderdetails       phd_cp,
             phd_profileheaderdetails       phd_broker,
             bca_broker_clearer_account     bca_broker,
             cm_currency_master             cm_broker_cur,
             phd_profileheaderdetails       phd_clearer,
             bca_broker_clearer_account     bca_clearer,
             cm_currency_master             cm_clearer,
             qat_quality_attributes         qat,
             gtm_gravity_type_master        gtm,
             qum_quantity_unit_master       qum_um,
             pum_price_unit_master          pum_trade,
             cm_currency_master             cm_trade,
             qum_quantity_unit_master       qum_trade,
             fbs_formula_builder_setup      fbs,
             dim_der_instrument_master      dim_index,
             pum_price_unit_master          pum_strike,
             cm_currency_master             cm_strike,
             qum_quantity_unit_master       qum_strike,
             pum_price_unit_master          pum_pd,
             cm_currency_master             cm_pd,
             qum_quantity_unit_master       qum_pd,
             phd_profileheaderdetails       phd_nominee,
             pym_payment_terms_master       pym,
             cm_currency_master             cm_settlement,
             gcd_groupcorporatedetails      gcd_group,
             cm_currency_master             cm_gcd,
             qum_quantity_unit_master       qum_gcd,
             qum_quantity_unit_master       qum_pdm,
             eodeom_derivative_quote_detail edq,
             apm_available_price_master     apm,
             pum_price_unit_master          pum_settle,
             cm_currency_master             cm_settle,
             qum_quantity_unit_master       qum_settle,
             cm_currency_master             cm_base,
             du_derivative_underlying       du,
             drm_derivative_master          drm_du,
             div_der_instrument_valuation   div
       where dt.corporate_id = ak.corporate_id
         and dt.trader_id = aku.user_id
         and aku.gabid = gab.gabid
         and dt.profit_center_id = cpc.profit_center_id
         and dt.dr_id = drm.dr_id(+)
         and drm.instrument_id = dim.instrument_id(+)
         and dim.instrument_type_id = irm.instrument_type_id(+)
         and dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
         and dim.product_derivative_id = pdd.derivative_def_id(+)
         and pdd.product_id = pdm.product_id(+)
         and pdd.exchange_id = emt.exchange_id(+)
         and pdd.lot_size_unit_id = qum.qty_unit_id(+)
         and drm.price_point_id = pp.price_point_id(+)
         and drm.period_type_id = pm.period_type_id(+)
         and dt.deal_type_id = dtm.deal_type_id
         and dt.strategy_id = css.strategy_id
         and css.strategy_def_id = sdm.strategy_def_id
         and ak.groupid = gcd.groupid
         and dt.purpose_id = dpm.purpose_id
         and dt.cp_profile_id = phd_cp.profileid(+)
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.broker_account_id = bca_broker.account_id(+)
         and dt.broker_comm_cur_id = cm_broker_cur.cur_id(+)
         and dt.clearer_profile_id = phd_clearer.profileid(+)
         and dt.clearer_account_id = bca_clearer.account_id(+)
         and dt.clearer_comm_cur_id = cm_clearer.cur_id(+)
         and dt.quality_id = qat.quality_id(+)
         and qat.gravity_type_id = gtm.gravity_type_id(+)
         and dt.quantity_unit_id = qum_um.qty_unit_id
         and dt.trade_price_unit_id = pum_trade.price_unit_id(+)
         and pum_trade.cur_id = cm_trade.cur_id(+)
         and pum_trade.weight_unit_id = qum_trade.qty_unit_id(+)
         and dt.formula_id = fbs.formula_id(+)
         and dt.index_instrument_id = dim_index.instrument_id(+)
         and dt.strike_price_unit_id = pum_strike.price_unit_id(+)
         and pum_strike.cur_id = cm_strike.cur_id(+)
         and pum_strike.weight_unit_id = qum_strike.qty_unit_id(+)
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and pum_pd.cur_id = cm_pd.cur_id(+)
         and pum_pd.weight_unit_id = qum_pd.qty_unit_id(+)
         and dt.nominee_profile_id = phd_nominee.profileid(+)
         and dt.payment_term = pym.payment_term_id(+)
         and dt.settlement_cur_id = cm_settlement.cur_id(+)
         and ak.groupid=gcd_group.groupid
         and gcd_group.group_cur_id = cm_gcd.cur_id
         and gcd_group.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id(+)
         and dt.process_id = edq.process_id
         and dt.dr_id = edq.dr_id
         and edq.available_price_id = apm.available_price_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and edq.available_price_id = div.available_price_id
         and edq.price_unit_id = div.price_unit_id
            --         and apm.available_price_name = 'Settlement'
         and apm.is_active = 'Y'
         and apm.is_deleted = 'N'
         and edq.price_unit_id = pum_settle.price_unit_id(+)
         and pum_settle.cur_id = cm_settle.cur_id(+)
         and pum_settle.weight_unit_id = qum_settle.qty_unit_id(+)
         and ak.base_currency_name = cm_base.cur_code(+)
         and irm.instrument_type in ('Option Put', 'Option Call')
         and upper(dt.status) = 'VERIFIED'
         and dt.is_what_if = 'N'
         and dt.open_quantity > 0
         and dt.corporate_id = pc_corporate_id
         and dt.trade_date <= pd_trade_date
         and dt.process_id = pc_process_id
         and dt.dr_id = du.dr_id
         and du.underlying_dr_id = drm_du.dr_id;
  
    vn_total_trade_value_base_cur  number;
    vn_pnl_value_in_trade_cur      number;
    vn_trade_to_base_exch_rate     number;
    vn_pnl_value_in_base_cur       number;
    vn_broker_comm_in_base_cur     number;
    vn_clr_comm_in_base_cur        number;
    vn_net_pnl_in_base_cur         number;
    vn_brokr_cur_to_base_exch_rate number;
    vn_clr_cur_to_base_exch_rate   number;
    vn_qty_in_trade_wt_unit        number;
    vn_market_price_in_trade_cur   number;
    vn_total_market_val_trade_cur  number;
    vn_trade_price_in_trade_cur    number;
    vn_total_trade_value_trade_cur number;
    vn_in_out_at_money_value       number;
    vc_in_out_at_money_status      varchar2(20);
    vn_strike_settlement_price     number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_trade_qty_exch_unit         number;
    vn_underlying_quote_price      number;
    vc_underlying_price_unit_id    varchar2(20);
  begin
  
    for cur_option_rows in cur_options
    loop
    
      -- Trade Qty in Exchange Weight Unit
      if cur_option_rows.gravity is not null then
        if cur_option_rows.quantity_unit_id <>
           cur_option_rows.lot_size_unit_id then
          vn_trade_qty_exch_unit := pkg_general.fn_mass_volume_qty_conversion(cur_option_rows.product_id,
                                                                              cur_option_rows.quantity_unit_id,
                                                                              cur_option_rows.lot_size_unit_id,
                                                                              cur_option_rows.open_quantity,
                                                                              cur_option_rows.gravity,
                                                                              cur_option_rows.gravity_type,
                                                                              cur_option_rows.density_mass_qty_unit_id,
                                                                              cur_option_rows.density_volume_qty_unit_id);
        else
          vn_trade_qty_exch_unit := pkg_general.f_get_converted_quantity(null,
                                                                         cur_option_rows.quantity_unit_id,
                                                                         cur_option_rows.lot_size_unit_id,
                                                                         cur_option_rows.open_quantity);
        end if;
      end if;
    
      /*
      get the exchange rates
      1. from broker to base currency
      2. trade to base currency
      */
      vn_trade_to_base_exch_rate     := f_currency_exchange_rate(pd_trade_date,
                                                                 pc_corporate_id,
                                                                 cur_option_rows.prompt_date,
                                                                 cur_option_rows.pd_cur_id,
                                                                 cur_option_rows.base_cur_id);
      vn_brokr_cur_to_base_exch_rate := f_currency_exchange_rate(pd_trade_date,
                                                                 pc_corporate_id,
                                                                 cur_option_rows.prompt_date,
                                                                 cur_option_rows.broker_comm_cur_id,
                                                                 cur_option_rows.base_cur_id);
      vn_clr_cur_to_base_exch_rate   := f_currency_exchange_rate(pd_trade_date,
                                                                 pc_corporate_id,
                                                                 cur_option_rows.prompt_date,
                                                                 cur_option_rows.clearer_comm_cur_id,
                                                                 cur_option_rows.base_cur_id);
      /*
      calcualate trade pnl in trade currency
      1. convert trade qty from trade price unit weight unit to trade weight unit
      2. get the market price in trade currency
      3. market value in trade currency = qty in trade weight unit(1) * market price in trade currency(2)
      4. trade value in trade currency = trade price in trade currency (from drt) * trade qty in trade unit(1)
      5. pnl in trade currency = market value in trade currency(2) - trade value in trade currency(4)
      */
      if cur_option_rows.gravity is not null then
        vn_qty_in_trade_wt_unit := pkg_general.fn_mass_volume_qty_conversion(cur_option_rows.product_id,
                                                                             cur_option_rows.quantity_unit_id,
                                                                             cur_option_rows.pd_weight_unit_id,
                                                                             cur_option_rows.open_quantity,
                                                                             cur_option_rows.gravity,
                                                                             cur_option_rows.gravity_type,
                                                                             cur_option_rows.density_mass_qty_unit_id,
                                                                             cur_option_rows.density_volume_qty_unit_id);
      else
      
        vn_qty_in_trade_wt_unit := f_get_converted_quantity(null, --product id
                                                            cur_option_rows.quantity_unit_id,
                                                            cur_option_rows.pd_weight_unit_id,
                                                            cur_option_rows.open_quantity);
      end if;
      --preeti fix for open qty
      --vn_market_price_in_trade_cur := cur_option_rows.settlement_price;
    
      if cur_option_rows.gravity is not null then
        vn_market_price_in_trade_cur := (cur_option_rows.settlement_price /
                                        nvl(cur_option_rows.settlement_price_weight,
                                             1)) *
                                        pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                 cur_option_rows.settlement_price_cur_id,
                                                                                 cur_option_rows.pd_cur_id,
                                                                                 pd_trade_date,
                                                                                 1) *
                                        (pkg_general.fn_mass_volume_qty_conversion(cur_option_rows.product_id,
                                                                                   cur_option_rows.settlement_weight_unit_id,
                                                                                   cur_option_rows.pd_weight_unit_id,
                                                                                   1,
                                                                                   cur_option_rows.gravity,
                                                                                   cur_option_rows.gravity_type,
                                                                                   cur_option_rows.density_mass_qty_unit_id,
                                                                                   cur_option_rows.density_volume_qty_unit_id));
      
      else
        vn_market_price_in_trade_cur := (cur_option_rows.settlement_price /
                                        nvl(cur_option_rows.settlement_price_weight,
                                             1)) *
                                        pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                 cur_option_rows.settlement_price_cur_id,
                                                                                 cur_option_rows.pd_cur_id,
                                                                                 pd_trade_date,
                                                                                 1) *
                                        (pkg_general.f_get_converted_quantity(cur_option_rows.product_id,
                                                                              cur_option_rows.settlement_weight_unit_id,
                                                                              cur_option_rows.pd_weight_unit_id,
                                                                              1));
      
      end if;
      /*
      market price in trade currency (dq_) needs to be converted into price unit currency of drt_
      
      vn_market_price_in_trade_cur   := vn_market_price_in_trade_cur *
                                        cur_option_rows.weight /
                                        (cur_option_rows.ppu_dq_weight *
                                        f_get_converted_quantity(null,
                                                                              cur_option_rows.ppu_dq_weight_unit_id,
                                                                              cur_option_rows.weight_unit_id,
                                                                              1));
      */
      vn_total_market_val_trade_cur := vn_market_price_in_trade_cur *
                                       vn_qty_in_trade_wt_unit;
    
      vn_trade_price_in_trade_cur    := cur_option_rows.premium_discount;
      vn_total_trade_value_trade_cur := vn_trade_price_in_trade_cur *
                                        vn_qty_in_trade_wt_unit;
    
      /*
      for sales trades pnl = trade price - market price
      for buy trades pnl =  market price - trade price
      */
      if cur_option_rows.trade_type = 'Buy' then
        vn_pnl_value_in_trade_cur := vn_total_market_val_trade_cur -
                                     vn_total_trade_value_trade_cur;
      else
        vn_pnl_value_in_trade_cur := vn_total_trade_value_trade_cur -
                                     vn_total_market_val_trade_cur;
      end if;
    
      -- calcualate trade pnl in trade currency ends here
      /*
      calcualte net pnl in base currency
       1. calculate trade value in base currency
       a) convert trade qty to price unit weight unit
       b) multiply a by trade price
       c) multipy by trade to base exchange rate
       2. calcualate broker commission in base currency
       3. pnl value in base currency = pnl value in trade currency * exchange rate from trade to base
       4. net pnl in base currency = pnl value in base currency (3) - broker commission in base currency
      
      vn_total_trade_value_base_cur := f_get_converted_quantity(null,
                                                                            cur_option_rows.trade_qty_unit_id,
                                                                            cur_option_rows.weight_unit_id,
                                                                            cur_option_rows.trade_qty) *
                                       cur_option_rows.trade_price *
                                       vn_trade_to_base_exch_rate;
      */
      vn_total_trade_value_base_cur := vn_total_trade_value_trade_cur *
                                       vn_trade_to_base_exch_rate;
      vn_broker_comm_in_base_cur    := cur_option_rows.broker_comm_amt *
                                       vn_brokr_cur_to_base_exch_rate;
      vn_clr_comm_in_base_cur       := cur_option_rows.clearer_comm_amt *
                                       vn_clr_cur_to_base_exch_rate;
      vn_pnl_value_in_base_cur      := vn_pnl_value_in_trade_cur *
                                       vn_trade_to_base_exch_rate;
      --Fix 10th Nov
      --vn_net_pnl_in_base_cur        := vn_pnl_value_in_base_cur -
      --                                 nvl(vn_broker_comm_in_base_cur,0) - nvl(vn_clr_comm_in_base_cur,0)  ;
      vn_net_pnl_in_base_cur := vn_pnl_value_in_base_cur;
    
      if cur_option_rows.gravity is not null then
        vn_strike_settlement_price := (cur_option_rows.strike_price /
                                      nvl(cur_option_rows.strike_weight, 1)) *
                                      pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                               cur_option_rows.strike_cur_id,
                                                                               cur_option_rows.settlement_price_cur_id,
                                                                               pd_trade_date,
                                                                               1) *
                                      (pkg_general.fn_mass_volume_qty_conversion(cur_option_rows.product_id,
                                                                                 cur_option_rows.strike_weight_unit_id,
                                                                                 cur_option_rows.settlement_weight_unit_id,
                                                                                 1,
                                                                                 cur_option_rows.gravity,
                                                                                 cur_option_rows.gravity_type,
                                                                                 cur_option_rows.density_mass_qty_unit_id,
                                                                                 cur_option_rows.density_volume_qty_unit_id));
      
      else
        vn_strike_settlement_price := (cur_option_rows.strike_price /
                                      nvl(cur_option_rows.strike_weight, 1)) *
                                      pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                               cur_option_rows.strike_cur_id,
                                                                               cur_option_rows.settlement_price_cur_id,
                                                                               pd_trade_date,
                                                                               1) *
                                      (pkg_general.f_get_converted_quantity(cur_option_rows.product_id,
                                                                            cur_option_rows.strike_weight_unit_id,
                                                                            cur_option_rows.settlement_weight_unit_id,
                                                                            1));
      
      end if;
      if cur_option_rows.instrument_type = 'Option Put' then
        vn_in_out_at_money_value := (nvl(vn_strike_settlement_price, 0) -
                                    nvl(cur_option_rows.settlement_price,
                                         0));
      else
      
        vn_in_out_at_money_value := (nvl(cur_option_rows.settlement_price,
                                         0) -
                                    nvl(vn_strike_settlement_price, 0));
      end if;
    
      if (vn_in_out_at_money_value > 0) then
        vc_in_out_at_money_status := 'In the Money';
      elsif (vn_in_out_at_money_value < 0) then
        vc_in_out_at_money_status := 'Out of the Money';
      else
        vc_in_out_at_money_status := 'At the Money';
      end if;
    
      /*
      calcualte the in/out/at money status and value
      
      if cur_option_rows.buy_sell || ' ' ||
         cur_option_rows.instrument_type = 'Buy Put Option' or
         cur_option_rows.buy_sell || ' ' ||
         cur_option_rows.instrument_type = 'Buy OTC Put Option' or
         cur_option_rows.buy_sell || ' ' ||
         cur_option_rows.instrument_type = 'Sell Call Option' or
         cur_option_rows.buy_sell || ' ' ||
         cur_option_rows.instrument_type = 'Sell OTC Call Option' then
          vn_in_out_at_money_value := (nvl(cur_option_rows.strike_price,
                                           0) - nvl(cur_option_rows.settlement_price,
                                                     0));
      elsif cur_option_rows.buy_sell || ' ' ||
            cur_option_rows.instrument_type = 'Sell Put Option' or
            cur_option_rows.buy_sell || ' ' ||
            cur_option_rows.instrument_type = 'Sell OTC Put Option' or
            cur_option_rows.buy_sell || ' ' ||
            cur_option_rows.instrument_type = 'Buy Call Option' or
            cur_option_rows.buy_sell || ' ' ||
            cur_option_rows.instrument_type = 'Buy OTC Call Option' then
          vn_in_out_at_money_value := (nvl(cur_option_rows.settlement_price,
                                           0) - nvl(cur_option_rows.strike_price,
                                                     0));
      end if;
      if (vn_in_out_at_money_value > 0) then
          vc_in_out_at_money_status := 'In the Money';
      elsif (vn_in_out_at_money_value < 0) then
          vc_in_out_at_money_status := 'Out of the Money';
      else
          vc_in_out_at_money_status := 'At the Money';
      end if;
      */
      if vn_net_pnl_in_base_cur is null then
        vn_net_pnl_in_base_cur := 0;
      end if;
    
      if vn_pnl_value_in_trade_cur is null then
        vn_pnl_value_in_trade_cur := 0;
      end if;
    
      insert into dpd_derivative_pnl_daily
        (internal_derivative_ref_no,
         derivative_ref_no,
         eod_trade_date,
         trade_date,
         corporate_id,
         corporate_name,
         trader_id,
         trader_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         dr_id,
         instrument_id,
         instrument_name,
         instrument_symbol,
         instrument_type_id,
         instrument_type,
         instrument_type_name,
         instrument_sub_type_id,
         instrument_sub_type,
         derivative_def_id,
         derivative_def_name,
         derivative_traded_on,
         derivative_prodct_id,
         derivative_prodct_name,
         exchange_id,
         exchange_name,
         exchange_code,
         lot_size,
         lot_size_unit_id,
         lot_size_unit,
         price_point_id,
         price_point_name,
         period_type_id,
         period_type_name,
         period_type_display_name,
         period_month,
         period_year,
         period_date,
         prompt_date,
         dr_id_name,
         trade_type,
         deal_type_id,
         deal_type_name,
         deal_type_display_name,
         is_multiple_leg_involved,
         deal_category,
         deal_sub_category,
         strategy_id,
         strategy_name,
         strategy_desc,
         strategy_def_name,
         group_id,
         group_name,
         purpose_id,
         purpose_name,
         purpose_display_name,
         external_ref_no,
         cp_profile_id,
         cp_name,
         master_contract_id,
         broker_profile_id,
         broker_name,
         broker_account_id,
         broker_account_name,
         broker_account_type,
         broker_comm_type_id,
         broker_comm_amt,
         broker_comm_cur_id,
         broker_comm_cur_code,
         clearer_profile_id,
         clearer_name,
         clearer_account_id,
         clearer_account_name,
         clearer_account_type,
         clearer_comm_type_id,
         clearer_comm_amt,
         clearer_comm_cur_id,
         clearer_comm_cur_code,
         product_id,
         product_name,
         quality_id,
         quality_name,
         quantity_unit_id,
         quantity_unit,
         total_lots,
         total_quantity,
         open_lots,
         open_quantity,
         exercised_lots,
         exercised_quantity,
         expired_lots,
         expired_quantity,
         trade_price_type_id,
         trade_price,
         trade_price_unit_id,
         trade_price_cur_id,
         trade_price_cur_code,
         trade_price_weight,
         trade_price_weight_unit_id,
         trade_price_weight_unit,
         formula_id,
         formula_name,
         formula_display,
         index_instrument_id,
         index_instrument_name,
         strike_price,
         strike_price_unit_id,
         strike_price_cur_id,
         strike_price_cur_code,
         strike_price_weight,
         strike_price_weight_unit_id,
         strike_price_weight_unit,
         premium_discount,
         premium_discount_price_unit_id,
         pd_price_cur_id,
         pd_price_cur_code,
         pd_price_weight,
         pd_price_weight_unit_id,
         pd_price_weight_unit,
         premium_due_date,
         nominee_profile_id,
         nominee_name,
         leg_no,
         option_expiry_date,
         parent_int_derivative_ref_no,
         market_location_country,
         market_location_state,
         market_location_city,
         is_what_if,
         payment_term_id,
         payment_term,
         payment_due_date,
         closed_lots,
         closed_quantity,
         is_new_trade,
         status,
         settlement_cur_id,
         settlement_cur_code,
         in_out_at_money_status,
         in_out_at_money_value,
         exercise_date,
         expiry_date,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         internal_close_out_ref_no,
         close_out_ref_no,
         close_out_date,
         settlement_price,
         sett_price_unit_id,
         sett_price_cur_id,
         sett_price_cur_code,
         sett_price_weight,
         sett_price_weight_unit_id,
         sett_price_weight_unit,
         parent_instrument_type,
         clearer_comm_in_base,
         broker_comm_in_base,
         clearer_exch_rate,
         broker_exch_rate,
         trade_cur_to_base_exch_rate,
         pnl_type,
         pnl_in_base_cur,
         pnl_in_trade_cur,
         base_cur_id,
         base_cur_code,
         underlying_future_dr_id,
         underlying_future_dr_id_name,
         underlying_future_expiry_date,
         underlying_future_quote_price,
         underlying_fut_price_unit_id,
         process_id,
         trade_qty_in_exch_unit)
      
      values
        (cur_option_rows.internal_derivative_ref_no,
         cur_option_rows.derivative_ref_no,
         cur_option_rows.eod_trade_date,
         cur_option_rows.trade_date,
         cur_option_rows.corporate_id,
         cur_option_rows.corporate_name,
         cur_option_rows.trader_id,
         cur_option_rows.tradername,
         cur_option_rows.profit_center_id,
         cur_option_rows.profit_center_name,
         cur_option_rows.profit_center_short_name,
         cur_option_rows.dr_id,
         cur_option_rows.instrument_id,
         cur_option_rows.instrument_name,
         cur_option_rows.instrument_symbol,
         cur_option_rows.instrument_type_id,
         cur_option_rows.instrument_type,
         cur_option_rows.instrument_display_name,
         cur_option_rows.instrument_sub_type_id,
         cur_option_rows.instrument_sub_type,
         cur_option_rows.derivative_def_id,
         cur_option_rows.derivative_def_name,
         cur_option_rows.traded_on,
         cur_option_rows.product_id,
         cur_option_rows.product_desc,
         cur_option_rows.exchange_id,
         cur_option_rows.exchange_name,
         cur_option_rows.exchange_code,
         cur_option_rows.lot_size,
         cur_option_rows.lot_size_unit_id,
         cur_option_rows.lot_size_qty_unit,
         cur_option_rows.price_point_id,
         cur_option_rows.price_point_name,
         cur_option_rows.period_type_id,
         cur_option_rows.period_type_name,
         cur_option_rows.period_type_display_name,
         cur_option_rows.period_month,
         cur_option_rows.period_year,
         cur_option_rows.period_date,
         cur_option_rows.prompt_date,
         cur_option_rows.dr_id_name,
         cur_option_rows.trade_type,
         cur_option_rows.deal_type_id,
         cur_option_rows.deal_type_name,
         cur_option_rows.deal_type_display_name,
         cur_option_rows.is_multiple_leg_involved,
         cur_option_rows.deal_category,
         cur_option_rows.deal_sub_category,
         cur_option_rows.strategy_id,
         cur_option_rows.strategy_name,
         cur_option_rows.description,
         cur_option_rows.strategy_def_name,
         cur_option_rows.groupid,
         cur_option_rows.groupname,
         cur_option_rows.purpose_id,
         cur_option_rows.purpose_name,
         cur_option_rows.purpose_display_name,
         cur_option_rows.external_ref_no,
         cur_option_rows.cp_profile_id,
         cur_option_rows.cp_name,
         cur_option_rows.master_contract_id,
         cur_option_rows.broker_profile_id,
         cur_option_rows.broker_name,
         cur_option_rows.broker_account_id,
         cur_option_rows.broker_account_name,
         cur_option_rows.broker_account_type,
         cur_option_rows.broker_comm_type_id,
         cur_option_rows.broker_comm_amt,
         cur_option_rows.broker_comm_cur_id,
         cur_option_rows.broker_cur_code,
         cur_option_rows.clearer_profile_id,
         cur_option_rows.clearer_name,
         cur_option_rows.clearer_account_id,
         cur_option_rows.clearer_account_name,
         cur_option_rows.clearer_account_type,
         cur_option_rows.clearer_comm_type_id,
         cur_option_rows.clearer_comm_amt,
         cur_option_rows.clearer_comm_cur_id,
         cur_option_rows.clearer_cur_code,
         cur_option_rows.product_id,
         cur_option_rows.productdesc,
         cur_option_rows.quality_id,
         cur_option_rows.quality_name,
         cur_option_rows.quantity_unit_id,
         cur_option_rows.quantityname,
         cur_option_rows.open_lots, --.total_lots,
         cur_option_rows.open_quantity, --.total_quantity,
         cur_option_rows.open_lots,
         cur_option_rows.open_quantity,
         cur_option_rows.exercised_lots,
         cur_option_rows.exercised_quantity,
         cur_option_rows.expired_lots,
         cur_option_rows.expired_quantity,
         cur_option_rows.trade_price_type_id,
         cur_option_rows.trade_price,
         cur_option_rows.trade_price_unit_id,
         cur_option_rows.trade_cur_id,
         cur_option_rows.trade_cur_code,
         cur_option_rows.trade_weight,
         cur_option_rows.trade_weight_unit_id,
         cur_option_rows.trade_qty_unit,
         cur_option_rows.formula_id,
         cur_option_rows.formula_name,
         cur_option_rows.formula_display,
         cur_option_rows.index_instrument_id,
         cur_option_rows.index_instrument_name,
         cur_option_rows.strike_price,
         cur_option_rows.strike_price_unit_id,
         cur_option_rows.strike_cur_id,
         cur_option_rows.strike_cur_code,
         cur_option_rows.strike_weight,
         cur_option_rows.strike_weight_unit_id,
         cur_option_rows.strike_qty_unit,
         cur_option_rows.premium_discount,
         cur_option_rows.premium_discount_price_unit_id,
         cur_option_rows.pd_cur_id,
         cur_option_rows.pd_cur_code,
         cur_option_rows.pd_weight,
         cur_option_rows.pd_weight_unit_id,
         cur_option_rows.pd_qty_unit,
         cur_option_rows.premium_due_date,
         cur_option_rows.nominee_profile_id,
         cur_option_rows.nominee_name,
         cur_option_rows.leg_no,
         cur_option_rows.option_expiry_date,
         cur_option_rows.parent_int_derivative_ref_no,
         cur_option_rows.market_location_country,
         cur_option_rows.market_location_state,
         cur_option_rows.market_location_city,
         cur_option_rows.is_what_if,
         cur_option_rows.payment_term,
         cur_option_rows.payment_term,
         cur_option_rows.payment_due_date,
         cur_option_rows.closed_lots,
         cur_option_rows.closed_quantity,
         cur_option_rows.is_new_trade_date,
         cur_option_rows.status,
         cur_option_rows.settlement_cur_id,
         cur_option_rows.settlement_cur_code,
         vc_in_out_at_money_status,
         vn_in_out_at_money_value,
         cur_option_rows.exercise_date,
         cur_option_rows.expiry_date,
         cur_option_rows.group_cur_id,
         cur_option_rows.group_cur_code,
         cur_option_rows.group_qty_unit_id,
         cur_option_rows.gcd_qty_unit,
         cur_option_rows.base_qty_unit_id,
         cur_option_rows.base_qty_unit,
         cur_option_rows.internal_close_out_ref_no,
         cur_option_rows.close_out_ref_no,
         cur_option_rows.close_out_date,
         cur_option_rows.settlement_price,
         cur_option_rows.settlement_price_unit_id,
         cur_option_rows.settlement_price_cur_id,
         cur_option_rows.settlemet_price_cur_code,
         cur_option_rows.settlement_price_weight,
         cur_option_rows.settlement_weight_unit_id,
         cur_option_rows.settlement_weight_unit,
         cur_option_rows.parent_instrument_type,
         vn_clr_comm_in_base_cur,
         vn_broker_comm_in_base_cur,
         vn_clr_cur_to_base_exch_rate,
         vn_brokr_cur_to_base_exch_rate,
         vn_trade_to_base_exch_rate,
         cur_option_rows.pnl_type,
         vn_net_pnl_in_base_cur,
         vn_pnl_value_in_trade_cur,
         cur_option_rows.base_cur_id,
         cur_option_rows.base_cur_code,
         cur_option_rows.underlying_future_dr_id,
         cur_option_rows.underlying_future_dr_id_name,
         cur_option_rows.underlying_future_expiry_date,
         cur_option_rows.underlying_future_quote_price,
         cur_option_rows.underlying_fut_price_unit_id,
         cur_option_rows.process_id,
         vn_trade_qty_exch_unit);
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_option_unrealized_pnl',
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

  procedure sp_calc_option_realized_pnl(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_process      varchar2,
                                        pc_dbd_id       varchar2) is
    /******************************************************************************************************************************************
    procedure name                            : sp_calc_option_realized_pnl
    author                                    : janna
    created date                              : 10th jan 2009
    purpose                                   : calculate the realized pnl for options as on eod date
    parameters
    pc_corporate_id                           : corporate id
    pd_trade_date                             : eod date id
    pc_eod_ref_no                             : eod reference no
    modification history
    modified date                             :
    modified by                               :
    modify description                        :
    ******************************************************************************************************************************************/
    cursor cur_options is
      select dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             pd_trade_date eod_trade_date,
             dt.trade_date,
             dt.corporate_id,
             ak.corporate_name,
             dt.trader_id,
             gab.firstname || gab.lastname tradername,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dt.dr_id,
             drm.instrument_id,
             dim.instrument_name,
             dim.instrument_symbol,
             dim.instrument_type_id,
             irm.instrument_type,
             irm.instrument_display_name,
             dim.instrument_sub_type_id,
             istm.instrument_sub_type,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             pdd.traded_on,
             pdd.product_id,
             pdm.product_desc,
             emt.exchange_id,
             emt.exchange_name,
             emt.exchange_code,
             pdd.lot_size,
             pdd.lot_size_unit_id,
             qum.qty_unit lot_size_qty_unit,
             drm.price_point_id,
             pp.price_point_name,
             drm.period_type_id,
             pm.period_type_name,
             pm.period_type_display_name,
             drm.period_month,
             drm.period_year,
             (case
               when drm.period_date is null then
                case
               when drm.period_month is not null and
                    drm.period_year is not null then
                to_date('01-' || drm.period_month || '-' || drm.period_year,
                        'dd-Mon-yyyy')
               else
                drm.prompt_date
             end else drm.period_date end) period_date,
             drm.prompt_date,
             drm.dr_id_name,
             dt.trade_type,
             dt.deal_type_id,
             dtm.deal_type_name,
             dtm.deal_type_display_name,
             dtm.is_multiple_leg_involved,
             null deal_category,
             null deal_sub_category,
             dt.strategy_id,
             css.strategy_name,
             css.description,
             sdm.strategy_def_name,
             ak.groupid,
             gcd.groupname,
             dt.purpose_id,
             dpm.purpose_name,
             dpm.purpose_display_name,
             dt.external_ref_no,
             dt.cp_profile_id,
             phd_cp.companyname cp_name,
             dt.master_contract_id,
             dt.broker_profile_id,
             phd_broker.companyname broker_name,
             dt.broker_account_id,
             bca_broker.account_name broker_account_name,
             bca_broker.account_type broker_account_type,
             dt.broker_comm_type_id,
             0 broker_comm_amt,
             dt.broker_comm_cur_id,
             cm_broker_cur.cur_code broker_cur_code,
             dt.clearer_profile_id,
             phd_clearer.companyname clearer_name,
             dt.clearer_account_id,
             bca_clearer.account_name clearer_account_name,
             bca_clearer.account_type clearer_account_type,
             dt.clearer_comm_type_id,
             0 clearer_comm_amt,
             dt.clearer_comm_cur_id,
             cm_clearer.cur_code clearer_cur_code,
             dt.product_id product,
             pdm.product_desc productdesc,
             dt.quality_id,
             qat.quality_name,
             dt.quantity_unit_id trade_qty_unit_id,
             qum_um.qty_unit quantityname,
             dt.total_lots,
             dt.total_quantity,
             dt.open_lots,
             dt.open_quantity,
             dt.exercised_lots,
             dt.exercised_quantity,
             dt.expired_lots,
             dt.expired_quantity,
             dt.trade_price_type_id,
             dt.trade_price,
             dt.trade_price_unit_id,
             pum_trade.cur_id trade_cur_id,
             cm_trade.cur_code trade_cur_code,
             pum_trade.weight trade_weight,
             pum_trade.weight_unit_id trade_weight_unit_id,
             qum_trade.qty_unit trade_qty_unit,
             dt.formula_id,
             fbs.formula_name,
             fbs.formula_display,
             dt.index_instrument_id,
             dim_index.instrument_name index_instrument_name,
             dt.strike_price,
             dt.strike_price_unit_id,
             pum_strike.cur_id strike_cur_id,
             cm_strike.cur_code strike_cur_code,
             pum_strike.weight strike_weight,
             pum_strike.weight_unit_id strike_weight_unit_id,
             qum_strike.qty_unit strike_qty_unit,
             dt.premium_discount,
             dt.premium_discount_price_unit_id,
             pum_pd.cur_id pd_cur_id,
             cm_pd.cur_code pd_cur_code,
             pum_pd.weight pd_weight,
             pum_pd.weight_unit_id pd_weight_unit_id,
             qum_pd.qty_unit pd_qty_unit,
             dt.premium_due_date,
             dt.nominee_profile_id,
             phd_nominee.companyname nominee_name,
             dt.leg_no,
             dt.option_expiry_date,
             dt.parent_int_derivative_ref_no,
             dt.market_location_country,
             dt.market_location_state,
             dt.market_location_city,
             dt.is_what_if,
             dt.payment_term,
             pym.payment_term payment_term_name,
             dt.payment_due_date,
             decode(dt.status,
                    'Expired',
                    dt.expired_quantity,
                    dt.exercised_quantity) quantity_closed,
             decode(dt.status,
                    'Expired',
                    dt.expired_lots,
                    dt.exercised_lots) lots_closed,
             null as is_new_trade_date,
             dt.status,
             dt.settlement_cur_id,
             cm_settlement.cur_code settlement_cur_code,
             null as in_out_at_money_status,
             null as in_out_at_money_value,
             null as exercise_date,
             drm.expiry_date as expiry_date,
             gcd_group.group_cur_id,
             cm_gcd.cur_code group_cur_code,
             gcd_group.group_qty_unit_id,
             qum_gcd.qty_unit gcd_qty_unit,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             null internal_close_out_ref_no,
             null close_out_ref_no,
             drm.expiry_date close_out_date,
             (case
               when irm.instrument_type in ('Option Put', 'Option Call') then
                'Option'
               else
                irm.instrument_type
             end) as parent_instrument_type,
             null as clearer_comm_in_base,
             null as broker_comm_in_base,
             null as clearer_exch_rate,
             null as broker_exch_rate,
             null as trade_cur_to_base_exch_rate,
             'Realized' as pnl_type,
             null as pnl_in_base_cur,
             null as pnl_in_trade_cur,
             cm_base.cur_id as base_cur_id,
             ak.base_currency_name base_cur_code,
             null as underlying_future_dr_id,
             null as underlying_future_dr_id_name,
             null as underlying_future_expiry_date,
             null as underlying_future_quote_price,
             null as underlying_fut_price_unit_id,
             pc_process_id process_id,
             div.available_price_id,
             div.price_unit_id,
             div.price_source_id
        from dt_derivative_trade            dt,
             ak_corporate                   ak,
             ak_corporate_user              aku,
             gab_globaladdressbook          gab,
             cpc_corporate_profit_center    cpc,
             drm_derivative_master          drm,
             dim_der_instrument_master      dim,
             irm_instrument_type_master     irm,
             istm_instr_sub_type_master     istm,
             pdd_product_derivative_def     pdd,
             pdm_productmaster              pdm,
             div_der_instrument_valuation   div,
             emt_exchangemaster             emt,
             qum_quantity_unit_master       qum,
             pp_price_point                 pp,
             pm_period_master               pm,
             dtm_deal_type_master           dtm,
             css_corporate_strategy_setup   css,
             sdm_strategy_definition_master sdm,
             gcd_groupcorporatedetails      gcd,
             dpm_derivative_purpose_master  dpm,
             phd_profileheaderdetails       phd_cp,
             phd_profileheaderdetails       phd_broker,
             bca_broker_clearer_account     bca_broker,
             cm_currency_master             cm_broker_cur,
             phd_profileheaderdetails       phd_clearer,
             bca_broker_clearer_account     bca_clearer,
             cm_currency_master             cm_clearer,
             qat_quality_attributes         qat,
             qum_quantity_unit_master       qum_um,
             pum_price_unit_master          pum_trade,
             cm_currency_master             cm_trade,
             qum_quantity_unit_master       qum_trade,
             fbs_formula_builder_setup      fbs,
             dim_der_instrument_master      dim_index,
             pum_price_unit_master          pum_strike,
             cm_currency_master             cm_strike,
             qum_quantity_unit_master       qum_strike,
             pum_price_unit_master          pum_pd,
             cm_currency_master             cm_pd,
             qum_quantity_unit_master       qum_pd,
             phd_profileheaderdetails       phd_nominee,
             pym_payment_terms_master       pym,
             cm_currency_master             cm_settlement,
             gcd_groupcorporatedetails      gcd_group,
             cm_currency_master             cm_gcd,
             qum_quantity_unit_master       qum_gcd,
             qum_quantity_unit_master       qum_pdm,
             cm_currency_master             cm_base
       where dt.corporate_id = ak.corporate_id
         and dt.trader_id = aku.user_id
         and aku.gabid = gab.gabid
         and dt.profit_center_id = cpc.profit_center_id
         and dt.dr_id = drm.dr_id(+)
         and drm.instrument_id = dim.instrument_id(+)
         and drm.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and dim.instrument_type_id = irm.instrument_type_id(+)
         and dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
         and dim.product_derivative_id = pdd.derivative_def_id(+)
         and pdd.product_id = pdm.product_id(+)
         and pdd.exchange_id = emt.exchange_id(+)
         and pdd.lot_size_unit_id = qum.qty_unit_id(+)
         and drm.price_point_id = pp.price_point_id(+)
         and drm.period_type_id = pm.period_type_id(+)
         and dt.deal_type_id = dtm.deal_type_id
         and dt.strategy_id = css.strategy_id
         and css.strategy_def_id = sdm.strategy_def_id
         and ak.groupid = gcd.groupid
         and dt.purpose_id = dpm.purpose_id
         and dt.cp_profile_id = phd_cp.profileid(+)
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.broker_account_id = bca_broker.account_id(+)
         and dt.broker_comm_cur_id = cm_broker_cur.cur_id(+)
         and dt.clearer_profile_id = phd_clearer.profileid(+)
         and dt.clearer_account_id = bca_clearer.account_id(+)
         and dt.clearer_comm_cur_id = cm_clearer.cur_id(+)
         and dt.quality_id = qat.quality_id(+)
         and dt.quantity_unit_id = qum_um.qty_unit_id
         and dt.trade_price_unit_id = pum_trade.price_unit_id(+)
         and pum_trade.cur_id = cm_trade.cur_id(+)
         and pum_trade.weight_unit_id = qum_trade.qty_unit_id(+)
         and dt.formula_id = fbs.formula_id(+)
         and dt.index_instrument_id = dim_index.instrument_id(+)
         and dt.strike_price_unit_id = pum_strike.price_unit_id(+)
         and pum_strike.cur_id = cm_strike.cur_id(+)
         and pum_strike.weight_unit_id = qum_strike.qty_unit_id(+)
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and pum_pd.cur_id = cm_pd.cur_id(+)
         and pum_pd.weight_unit_id = qum_pd.qty_unit_id(+)
         and dt.nominee_profile_id = phd_nominee.profileid(+)
         and dt.payment_term = pym.payment_term_id(+)
         and dt.settlement_cur_id = cm_settlement.cur_id(+)
         and ak.groupid=gcd_group.groupid
         and gcd_group.group_cur_id = cm_gcd.cur_id
         and gcd_group.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id(+)
         and ak.base_currency_name = cm_base.cur_code
         and irm.instrument_type in ('Option Put', 'Option Call')
         and upper(dt.status) in ('EXERCISED', 'EXPIRED')
         and dt.is_what_if = 'N'
         and dt.is_realized_today = 'Y'
         and dt.corporate_id = pc_corporate_id
         and dt.trade_date <= pd_trade_date
         and dt.process_id = pc_process_id
      union
      select dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             pd_trade_date eod_trade_date,
             dt.trade_date,
             dt.corporate_id,
             ak.corporate_name,
             dt.trader_id,
             gab.firstname || gab.lastname tradername,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dt.dr_id,
             drm.instrument_id,
             dim.instrument_name,
             dim.instrument_symbol,
             dim.instrument_type_id,
             irm.instrument_type,
             irm.instrument_display_name,
             dim.instrument_sub_type_id,
             istm.instrument_sub_type,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             pdd.traded_on,
             pdd.product_id,
             pdm.product_desc,
             emt.exchange_id,
             emt.exchange_name,
             emt.exchange_code,
             pdd.lot_size,
             pdd.lot_size_unit_id,
             qum.qty_unit lot_size_qty_unit,
             drm.price_point_id,
             pp.price_point_name,
             drm.period_type_id,
             pm.period_type_name,
             pm.period_type_display_name,
             drm.period_month,
             drm.period_year,
             (case
               when drm.period_date is null then
                case
               when drm.period_month is not null and
                    drm.period_year is not null then
                to_date('01-' || drm.period_month || '-' || drm.period_year,
                        'dd-Mon-yyyy')
               else
                drm.prompt_date
             end else drm.period_date end) period_date,
             drm.prompt_date,
             drm.dr_id_name,
             dt.trade_type,
             dt.deal_type_id,
             dtm.deal_type_name,
             dtm.deal_type_display_name,
             dtm.is_multiple_leg_involved,
             null deal_category,
             null deal_sub_category,
             dt.strategy_id,
             css.strategy_name,
             css.description,
             sdm.strategy_def_name,
             ak.groupid,
             gcd.groupname,
             dt.purpose_id,
             dpm.purpose_name,
             dpm.purpose_display_name,
             dt.external_ref_no,
             dt.cp_profile_id,
             phd_cp.companyname cp_name,
             dt.master_contract_id,
             dt.broker_profile_id,
             phd_broker.companyname broker_name,
             dt.broker_account_id,
             bca_broker.account_name broker_account_name,
             bca_broker.account_type broker_account_type,
             dt.broker_comm_type_id,
             nvl(dcod.broker_comm_amt, 0) as broker_comm_amt,
             dcod.broker_comm_cur_id,
             cm_broker_cur.cur_code broker_cur_code,
             dt.clearer_profile_id,
             phd_clearer.companyname clearer_name,
             dt.clearer_account_id,
             bca_clearer.account_name clearer_account_name,
             bca_clearer.account_type clearer_account_type,
             dt.clearer_comm_type_id,
             dcod.clearer_comm_amt,
             dcod.clearer_comm_cur_id,
             cm_clearer.cur_code clearer_cur_code,
             dt.product_id product,
             pdm.product_desc productdesc,
             dt.quality_id,
             qat.quality_name,
             dcod.quantity_unit_id trade_qty_unit_id,
             qum_um.qty_unit quantityname,
             dt.total_lots,
             dt.total_quantity,
             dt.open_lots,
             dt.open_quantity,
             dt.exercised_lots,
             dt.exercised_quantity,
             dt.expired_lots,
             dt.expired_quantity,
             dt.trade_price_type_id,
             dt.trade_price,
             dt.trade_price_unit_id,
             pum_trade.cur_id trade_cur_id,
             cm_trade.cur_code trade_cur_code,
             pum_trade.weight trade_weight,
             pum_trade.weight_unit_id trade_weight_unit_id,
             qum_trade.qty_unit trade_qty_unit,
             dt.formula_id,
             fbs.formula_name,
             fbs.formula_display,
             dt.index_instrument_id,
             dim_index.instrument_name index_instrument_name,
             dt.strike_price,
             dt.strike_price_unit_id,
             pum_strike.cur_id strike_cur_id,
             cm_strike.cur_code strike_cur_code,
             pum_strike.weight strike_weight,
             pum_strike.weight_unit_id strike_weight_unit_id,
             qum_strike.qty_unit strike_qty_unit,
             dt.premium_discount,
             dt.premium_discount_price_unit_id,
             pum_pd.cur_id pd_cur_id,
             cm_pd.cur_code pd_cur_code,
             pum_pd.weight pd_weight,
             pum_pd.weight_unit_id pd_weight_unit_id,
             qum_pd.qty_unit pd_qty_unit,
             dt.premium_due_date,
             dt.nominee_profile_id,
             phd_nominee.companyname nominee_name,
             dt.leg_no,
             dt.option_expiry_date,
             dt.parent_int_derivative_ref_no,
             dt.market_location_country,
             dt.market_location_state,
             dt.market_location_city,
             dt.is_what_if,
             dt.payment_term,
             pym.payment_term payment_term_name,
             dt.payment_due_date,
             dcod.quantity_closed,
             dcod.lots_closed,
             null as is_new_trade_date,
             dt.status,
             dt.settlement_cur_id,
             cm_settlement.cur_code settlement_cur_code,
             null as in_out_at_money_status,
             null as in_out_at_money_value,
             null as exercise_date,
             drm.expiry_date as expiry_date,
             gcd_group.group_cur_id,
             cm_gcd.cur_code group_cur_code,
             gcd_group.group_qty_unit_id,
             qum_gcd.qty_unit gcd_qty_unit,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             dcoh.internal_close_out_ref_no,
             dcoh.close_out_ref_no,
             dcoh.close_out_date,
             (case
               when irm.instrument_type in ('Option Put', 'Option Call') then
                'Option'
               else
                irm.instrument_type
             end) as parent_instrument_type,
             null as clearer_comm_in_base,
             null as broker_comm_in_base,
             null as clearer_exch_rate,
             null as broker_exch_rate,
             null as trade_cur_to_base_exch_rate,
             'Realized' as pnl_type,
             null as pnl_in_base_cur,
             null as pnl_in_trade_cur,
             cm_base.cur_id as base_cur_id,
             ak.base_currency_name base_cur_code,
             null as underlying_future_dr_id,
             null as underlying_future_dr_id_name,
             null as underlying_future_expiry_date,
             null as underlying_future_quote_price,
             null as underlying_fut_price_unit_id,
             pc_process_id process_id,
             div.available_price_id,
             div.price_unit_id,
             div.price_source_id
      
        from dt_derivative_trade            dt,
             ak_corporate                   ak,
             ak_corporate_user              aku,
             gab_globaladdressbook          gab,
             cpc_corporate_profit_center    cpc,
             drm_derivative_master          drm,
             dim_der_instrument_master      dim,
             irm_instrument_type_master     irm,
             istm_instr_sub_type_master     istm,
             pdd_product_derivative_def     pdd,
             pdm_productmaster              pdm,
             emt_exchangemaster             emt,
             div_der_instrument_valuation   div,
             qum_quantity_unit_master       qum,
             pp_price_point                 pp,
             pm_period_master               pm,
             dtm_deal_type_master           dtm,
             css_corporate_strategy_setup   css,
             sdm_strategy_definition_master sdm,
             gcd_groupcorporatedetails      gcd,
             dpm_derivative_purpose_master  dpm,
             phd_profileheaderdetails       phd_cp,
             phd_profileheaderdetails       phd_broker,
             bca_broker_clearer_account     bca_broker,
             cm_currency_master             cm_broker_cur,
             phd_profileheaderdetails       phd_clearer,
             bca_broker_clearer_account     bca_clearer,
             cm_currency_master             cm_clearer,
             qat_quality_attributes         qat,
             qum_quantity_unit_master       qum_um,
             pum_price_unit_master          pum_trade,
             cm_currency_master             cm_trade,
             qum_quantity_unit_master       qum_trade,
             fbs_formula_builder_setup      fbs,
             dim_der_instrument_master      dim_index,
             pum_price_unit_master          pum_strike,
             cm_currency_master             cm_strike,
             qum_quantity_unit_master       qum_strike,
             pum_price_unit_master          pum_pd,
             cm_currency_master             cm_pd,
             qum_quantity_unit_master       qum_pd,
             phd_profileheaderdetails       phd_nominee,
             pym_payment_terms_master       pym,
             cm_currency_master             cm_settlement,
             gcd_groupcorporatedetails      gcd_group,
             cm_currency_master             cm_gcd,
             qum_quantity_unit_master       qum_gcd,
             qum_quantity_unit_master       qum_pdm,
             cm_currency_master             cm_base,
             dcoh_der_closeout_header       dcoh,
             dcod_der_closeout_detail       dcod
       where dt.corporate_id = ak.corporate_id
         and dt.trader_id = aku.user_id
         and aku.gabid = gab.gabid
         and dt.profit_center_id = cpc.profit_center_id
         and dt.dr_id = drm.dr_id(+)
         and drm.instrument_id = dim.instrument_id(+)
         and dim.instrument_type_id = irm.instrument_type_id(+)
         and dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
         and dim.product_derivative_id = pdd.derivative_def_id(+)
         and pdd.product_id = pdm.product_id(+)
         and pdd.exchange_id = emt.exchange_id(+)
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and pdd.lot_size_unit_id = qum.qty_unit_id(+)
         and drm.price_point_id = pp.price_point_id(+)
         and drm.period_type_id = pm.period_type_id(+)
         and dt.deal_type_id = dtm.deal_type_id
         and dt.strategy_id = css.strategy_id
         and css.strategy_def_id = sdm.strategy_def_id
         and ak.groupid = gcd.groupid
         and dt.purpose_id = dpm.purpose_id
         and dt.cp_profile_id = phd_cp.profileid(+)
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.broker_account_id = bca_broker.account_id(+)
         and dt.broker_comm_cur_id = cm_broker_cur.cur_id(+)
         and dt.clearer_profile_id = phd_clearer.profileid(+)
         and dt.clearer_account_id = bca_clearer.account_id(+)
         and dt.clearer_comm_cur_id = cm_clearer.cur_id(+)
         and dt.quality_id = qat.quality_id(+)
         and dt.quantity_unit_id = qum_um.qty_unit_id
         and dt.trade_price_unit_id = pum_trade.price_unit_id(+)
         and pum_trade.cur_id = cm_trade.cur_id(+)
         and pum_trade.weight_unit_id = qum_trade.qty_unit_id(+)
         and dt.formula_id = fbs.formula_id(+)
         and dt.index_instrument_id = dim_index.instrument_id(+)
         and dt.strike_price_unit_id = pum_strike.price_unit_id(+)
         and pum_strike.cur_id = cm_strike.cur_id(+)
         and pum_strike.weight_unit_id = qum_strike.qty_unit_id(+)
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and pum_pd.cur_id = cm_pd.cur_id(+)
         and pum_pd.weight_unit_id = qum_pd.qty_unit_id(+)
         and dt.nominee_profile_id = phd_nominee.profileid(+)
         and dt.payment_term = pym.payment_term_id(+)
         and dt.settlement_cur_id = cm_settlement.cur_id(+)
         and gcd_group.group_cur_id = cm_gcd.cur_id
         and gcd_group.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id(+)
         and ak.base_currency_name = cm_base.cur_code
         and dcoh.internal_close_out_ref_no =
             dcod.internal_close_out_ref_no
         and dcod.process_id = dcoh.process_id
         and dcoh.process_id = pc_process_id
         and dt.internal_derivative_ref_no =
             dcod.internal_derivative_ref_no
         and irm.instrument_type in ('Option Put', 'Option Call')
         and dt.is_what_if = 'N'
         and dt.corporate_id = pc_corporate_id
         and dt.trade_date <= pd_trade_date
         and dt.process_id = pc_process_id;
  
    vn_total_trade_value_base_cur  number;
    vn_pnl_value_in_trade_cur      number;
    vn_trade_to_base_exch_rate     number;
    vn_pnl_value_in_base_cur       number;
    vn_broker_comm_in_base_cur     number;
    vn_clr_cur_to_base_exch_rate   number;
    vn_clearer_comm_in_base_cur    number;
    vn_net_pnl_in_base_cur         number;
    vn_brokr_cur_to_base_exch_rate number;
    vn_qty_in_trade_wt_unit        number;
    vn_market_price_in_trade_cur   number;
    vn_total_market_val_trade_cur  number;
    vn_trade_price_in_trade_cur    number;
    vn_total_trade_value_trade_cur number;
    vn_in_out_at_money_value       number;
    vc_in_out_at_money_status      varchar2(20);
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_trade_qty_exch_unit         number;
    vc_settlement_price_unit_id    varchar2(15);
    vc_settlement_cur_id           varchar2(15);
    vc_settlement_cur_code         varchar2(15);
    vc_settlement_weight           number(7, 2);
    vc_settlement_weight_unit_id   varchar2(15);
    vc_settlement_weight_unit      varchar2(15);
  begin
    for cur_option_rows in cur_options
    loop
    
      -- Trade Qty in Exchange Weight Unit
      vn_trade_qty_exch_unit := pkg_general.f_get_converted_quantity(null,
                                                                     cur_option_rows.trade_qty_unit_id,
                                                                     cur_option_rows.lot_size_unit_id,
                                                                     cur_option_rows.quantity_closed);
    
      /*
      get the exchange rates
      1. from broker to base currency
      2. trade to base currency
      */
      if cur_option_rows.trade_cur_id <> cur_option_rows.base_cur_id then
        vn_trade_to_base_exch_rate := f_currency_exchange_rate(cur_option_rows.close_out_date,
                                                               pc_corporate_id,
                                                               cur_option_rows.prompt_date,
                                                               cur_option_rows.trade_cur_id,
                                                               cur_option_rows.base_cur_id);
      else
        vn_trade_to_base_exch_rate := 1;
      end if;
    
      if cur_option_rows.broker_comm_cur_id <> cur_option_rows.base_cur_id then
        vn_brokr_cur_to_base_exch_rate := f_currency_exchange_rate(cur_option_rows.close_out_date,
                                                                   pc_corporate_id,
                                                                   cur_option_rows.prompt_date,
                                                                   cur_option_rows.broker_comm_cur_id,
                                                                   cur_option_rows.base_cur_id);
      else
        vn_brokr_cur_to_base_exch_rate := 1;
      end if;
    
      if cur_option_rows.clearer_comm_cur_id <> cur_option_rows.base_cur_id then
        vn_clr_cur_to_base_exch_rate := f_currency_exchange_rate(cur_option_rows.close_out_date,
                                                                 pc_corporate_id,
                                                                 cur_option_rows.prompt_date,
                                                                 cur_option_rows.clearer_comm_cur_id,
                                                                 cur_option_rows.base_cur_id);
      else
        vn_clr_cur_to_base_exch_rate := 1;
      end if;
    
      /* calcualate trade pnl in trade currency
          1. convert trade qty from trade price unit weight unit to trade weight unit
          2. get the market price in trade currency
          3. market value in trade currency = qty in trade weight unit(1) * market price in trade currency(2)
          4. trade value in trade currency = trade price in trade currency (from drt) * trade qty in trade unit(1)
          5. pnl in trade currency = market value in trade currency(2) - trade value in trade currency(4)
      */
      vn_qty_in_trade_wt_unit := f_get_converted_quantity(null, --product id
                                                          cur_option_rows.trade_qty_unit_id,
                                                          cur_option_rows.trade_weight_unit_id,
                                                          cur_option_rows.quantity_closed);
    
      --vn_market_price_in_trade_cur := cur_option_rows.settlement_price;
    
      begin
        select dqd.price,
               dqd.price_unit_id,
               pum.cur_id,
               cm.cur_code,
               pum.weight,
               pum.weight_unit_id,
               qum.qty_unit
          into vn_market_price_in_trade_cur,
               vc_settlement_price_unit_id,
               vc_settlement_cur_id,
               vc_settlement_cur_code,
               vc_settlement_weight,
               vc_settlement_weight_unit_id,
               vc_settlement_weight_unit
          from dq_derivative_quotes        dq,
               dqd_derivative_quote_detail dqd,
               apm_available_price_master  apm,
               pum_price_unit_master       pum,
               cm_currency_master          cm,
               qum_quantity_unit_master    qum
         where dq.dq_id = dqd.dq_id
           and dq.dbd_id = dqd.dbd_id
           and dqd.price_unit_id = pum.price_unit_id
           and pum.cur_id = cm.cur_id
           and pum.weight_unit_id = qum.qty_unit_id
           and dq.trade_date = cur_option_rows.close_out_date
           and dqd.price <> 0
           and dqd.dr_id = cur_option_rows.dr_id
           and dq.corporate_id = pc_corporate_id
           and upper(dq.entry_type) = upper(cur_option_rows.traded_on)
           and dq.instrument_id = cur_option_rows.instrument_id
           and dqd.available_price_id = apm.available_price_id
           and dqd.available_price_id = cur_option_rows.available_price_id
           and dqd.price_unit_id = cur_option_rows.price_unit_id
              -- and apm.available_price_name = 'Settlement'
           and dq.dbd_id = pc_dbd_id;
      
      exception
        when no_data_found then
          vn_market_price_in_trade_cur := 0;
          vc_settlement_price_unit_id  := null;
          vc_settlement_cur_id         := null;
          vc_settlement_cur_code       := null;
          vc_settlement_weight         := null;
          vc_settlement_weight_unit_id := null;
          vc_settlement_weight_unit    := null;
        when others then
          vn_market_price_in_trade_cur := 0;
          vc_settlement_price_unit_id  := null;
          vc_settlement_cur_id         := null;
          vc_settlement_cur_code       := null;
          vc_settlement_weight         := null;
          vc_settlement_weight_unit_id := null;
          vc_settlement_weight_unit    := null;
      end;
    
      /*
      market price in trade currency (dq_) needs to be converted into price unit currency of drt_
      
      vn_market_price_in_trade_cur   := vn_market_price_in_trade_cur *
                                        cur_option_rows.weight /
                                        (cur_option_rows.ppu_dq_weight *
                                        pkg_general.f_get_converted_quantity(null,
                                                                              cur_option_rows.ppu_dq_weight_unit_id,
                                                                              cur_option_rows.weight_unit_id,
                                                                              1));
      
      */
      if cur_option_rows.status in ('Exercised', 'Expired') then
        vn_total_market_val_trade_cur := 0;
      else
        vn_total_market_val_trade_cur := vn_market_price_in_trade_cur *
                                         vn_qty_in_trade_wt_unit;
      end if;
    
      vn_trade_price_in_trade_cur    := cur_option_rows.premium_discount;
      vn_total_trade_value_trade_cur := vn_trade_price_in_trade_cur *
                                        vn_qty_in_trade_wt_unit;
    
      /*
      for sales trades pnl = trade price - market price
      for buy trades pnl =  market price - trade price
      */
      if cur_option_rows.trade_type = 'Buy' then
        vn_pnl_value_in_trade_cur := vn_total_market_val_trade_cur -
                                     vn_total_trade_value_trade_cur;
      else
        vn_pnl_value_in_trade_cur := vn_total_trade_value_trade_cur -
                                     vn_total_market_val_trade_cur;
      end if;
    
      -- calcualate trade pnl in trade currency ends here
      /*
      calcualte net pnl in base currency
       1. calculate trade value in base currency
       a) convert trade qty to price unit weight unit
       b) multiply a by trade price
       c) multipy by trade to base exchange rate
       2. calcualate broker commission in base currency
       3. pnl value in base currency = pnl value in trade currency * exchange rate from trade to base
       4. net pnl in base currency = pnl value in base currency (3) - broker commission in base currency
      
      vn_total_trade_value_base_cur := f_get_converted_quantity(null,
                                                                            cur_option_rows.trade_qty_unit_id,
                                                                            cur_option_rows.weight_unit_id,
                                                                            cur_option_rows.trade_qty) *
                                       cur_option_rows.trade_price *
                                       vn_trade_to_base_exch_rate;
      
      */
      vn_total_trade_value_base_cur := vn_total_trade_value_trade_cur *
                                       vn_trade_to_base_exch_rate;
      vn_broker_comm_in_base_cur    := cur_option_rows.broker_comm_amt *
                                       vn_brokr_cur_to_base_exch_rate;
      vn_clearer_comm_in_base_cur   := cur_option_rows.clearer_comm_amt *
                                       vn_clr_cur_to_base_exch_rate;
      vn_pnl_value_in_base_cur      := vn_pnl_value_in_trade_cur *
                                       vn_trade_to_base_exch_rate;
      vn_net_pnl_in_base_cur        := vn_pnl_value_in_base_cur -
                                       nvl(vn_broker_comm_in_base_cur, 0) -
                                       nvl(vn_clearer_comm_in_base_cur, 0);
    
      /*
      if cur_option_rows.buy_sell || ' ' ||
         cur_option_rows.instrument_type = 'Buy Put Option' or
         cur_option_rows.buy_sell || ' ' ||
         cur_option_rows.instrument_type = 'Buy OTC Put Option' or
         cur_option_rows.buy_sell || ' ' ||
         cur_option_rows.instrument_type = 'Sell Call Option' or
         cur_option_rows.buy_sell || ' ' ||
         cur_option_rows.instrument_type = 'Sell OTC Call Option' then
          vn_in_out_at_money_value := (nvl(cur_option_rows.strike_price,
                                           0) - nvl(cur_option_rows.settlement_price,
                                                     0));
      elsif cur_option_rows.buy_sell || ' ' ||
            cur_option_rows.instrument_type = 'Sell Put Option' or
            cur_option_rows.buy_sell || ' ' ||
            cur_option_rows.instrument_type = 'Sell OTC Put Option' or
            cur_option_rows.buy_sell || ' ' ||
            cur_option_rows.instrument_type = 'Buy Call Option' or
            cur_option_rows.buy_sell || ' ' ||
            cur_option_rows.instrument_type = 'Buy OTC Call Option' then
          vn_in_out_at_money_value := (nvl(cur_option_rows.settlement_price,
                                           0) - nvl(cur_option_rows.strike_price,
                                                     0));
      end if;
      
      if (vn_in_out_at_money_value > 0) then
          vc_in_out_at_money_status := 'In the Money';
      elsif (vn_in_out_at_money_value < 0) then
          vc_in_out_at_money_status := 'Out of the Money';
      else
          vc_in_out_at_money_status := 'At the Money';
      end if;
      */
      if vn_net_pnl_in_base_cur is null then
        vn_net_pnl_in_base_cur := 0;
      end if;
    
      if vn_pnl_value_in_trade_cur is null then
        vn_pnl_value_in_trade_cur := 0;
      end if;
    
      insert into dpd_derivative_pnl_daily
        (internal_derivative_ref_no,
         derivative_ref_no,
         eod_trade_date,
         trade_date,
         corporate_id,
         corporate_name,
         trader_id,
         trader_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         dr_id,
         instrument_id,
         instrument_name,
         instrument_symbol,
         instrument_type_id,
         instrument_type,
         instrument_type_name,
         instrument_sub_type_id,
         instrument_sub_type,
         derivative_def_id,
         derivative_def_name,
         derivative_traded_on,
         derivative_prodct_id,
         derivative_prodct_name,
         exchange_id,
         exchange_name,
         exchange_code,
         lot_size,
         lot_size_unit_id,
         lot_size_unit,
         price_point_id,
         price_point_name,
         period_type_id,
         period_type_name,
         period_type_display_name,
         period_month,
         period_year,
         period_date,
         prompt_date,
         dr_id_name,
         trade_type,
         deal_type_id,
         deal_type_name,
         deal_type_display_name,
         is_multiple_leg_involved,
         deal_category,
         deal_sub_category,
         strategy_id,
         strategy_name,
         strategy_desc,
         strategy_def_name,
         group_id,
         group_name,
         purpose_id,
         purpose_name,
         purpose_display_name,
         external_ref_no,
         cp_profile_id,
         cp_name,
         master_contract_id,
         broker_profile_id,
         broker_name,
         broker_account_id,
         broker_account_name,
         broker_account_type,
         broker_comm_type_id,
         broker_comm_amt,
         broker_comm_cur_id,
         broker_comm_cur_code,
         clearer_profile_id,
         clearer_name,
         clearer_account_id,
         clearer_account_name,
         clearer_account_type,
         clearer_comm_type_id,
         clearer_comm_amt,
         clearer_comm_cur_id,
         clearer_comm_cur_code,
         product_id,
         product_name,
         quality_id,
         quality_name,
         quantity_unit_id,
         quantity_unit,
         total_lots,
         total_quantity,
         open_lots,
         open_quantity,
         exercised_lots,
         exercised_quantity,
         expired_lots,
         expired_quantity,
         trade_price_type_id,
         trade_price,
         trade_price_unit_id,
         trade_price_cur_id,
         trade_price_cur_code,
         trade_price_weight,
         trade_price_weight_unit_id,
         trade_price_weight_unit,
         formula_id,
         formula_name,
         formula_display,
         index_instrument_id,
         index_instrument_name,
         strike_price,
         strike_price_unit_id,
         strike_price_cur_id,
         strike_price_cur_code,
         strike_price_weight,
         strike_price_weight_unit_id,
         strike_price_weight_unit,
         premium_discount,
         premium_discount_price_unit_id,
         pd_price_cur_id,
         pd_price_cur_code,
         pd_price_weight,
         pd_price_weight_unit_id,
         pd_price_weight_unit,
         premium_due_date,
         nominee_profile_id,
         nominee_name,
         leg_no,
         option_expiry_date,
         parent_int_derivative_ref_no,
         market_location_country,
         market_location_state,
         market_location_city,
         is_what_if,
         payment_term_id,
         payment_term,
         payment_due_date,
         closed_lots,
         closed_quantity,
         is_new_trade,
         status,
         settlement_cur_id,
         settlement_cur_code,
         in_out_at_money_status,
         in_out_at_money_value,
         exercise_date,
         expiry_date,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         internal_close_out_ref_no,
         close_out_ref_no,
         close_out_date,
         settlement_price,
         sett_price_unit_id,
         sett_price_cur_id,
         sett_price_cur_code,
         sett_price_weight,
         sett_price_weight_unit_id,
         sett_price_weight_unit,
         parent_instrument_type,
         clearer_comm_in_base,
         broker_comm_in_base,
         clearer_exch_rate,
         broker_exch_rate,
         trade_cur_to_base_exch_rate,
         pnl_type,
         pnl_in_base_cur,
         pnl_in_trade_cur,
         base_cur_id,
         base_cur_code,
         underlying_future_dr_id,
         underlying_future_dr_id_name,
         underlying_future_expiry_date,
         underlying_future_quote_price,
         underlying_fut_price_unit_id,
         process_id,
         trade_qty_in_exch_unit)
      
      values
        (cur_option_rows.internal_derivative_ref_no,
         cur_option_rows.derivative_ref_no,
         cur_option_rows.eod_trade_date,
         cur_option_rows.trade_date,
         cur_option_rows.corporate_id,
         cur_option_rows.corporate_name,
         cur_option_rows.trader_id,
         cur_option_rows.tradername,
         cur_option_rows.profit_center_id,
         cur_option_rows.profit_center_name,
         cur_option_rows.profit_center_short_name,
         cur_option_rows.dr_id,
         cur_option_rows.instrument_id,
         cur_option_rows.instrument_name,
         cur_option_rows.instrument_symbol,
         cur_option_rows.instrument_type_id,
         cur_option_rows.instrument_type,
         cur_option_rows.instrument_display_name,
         cur_option_rows.instrument_sub_type_id,
         cur_option_rows.instrument_sub_type,
         cur_option_rows.derivative_def_id,
         cur_option_rows.derivative_def_name,
         cur_option_rows.traded_on,
         cur_option_rows.product_id,
         cur_option_rows.product_desc,
         cur_option_rows.exchange_id,
         cur_option_rows.exchange_name,
         cur_option_rows.exchange_code,
         cur_option_rows.lot_size,
         cur_option_rows.lot_size_unit_id,
         cur_option_rows.lot_size_qty_unit,
         cur_option_rows.price_point_id,
         cur_option_rows.price_point_name,
         cur_option_rows.period_type_id,
         cur_option_rows.period_type_name,
         cur_option_rows.period_type_display_name,
         cur_option_rows.period_month,
         cur_option_rows.period_year,
         cur_option_rows.period_date,
         cur_option_rows.prompt_date,
         cur_option_rows.dr_id_name,
         cur_option_rows.trade_type,
         cur_option_rows.deal_type_id,
         cur_option_rows.deal_type_name,
         cur_option_rows.deal_type_display_name,
         cur_option_rows.is_multiple_leg_involved,
         cur_option_rows.deal_category,
         cur_option_rows.deal_sub_category,
         cur_option_rows.strategy_id,
         cur_option_rows.strategy_name,
         cur_option_rows.description,
         cur_option_rows.strategy_def_name,
         cur_option_rows.groupid,
         cur_option_rows.groupname,
         cur_option_rows.purpose_id,
         cur_option_rows.purpose_name,
         cur_option_rows.purpose_display_name,
         cur_option_rows.external_ref_no,
         cur_option_rows.cp_profile_id,
         cur_option_rows.cp_name,
         cur_option_rows.master_contract_id,
         cur_option_rows.broker_profile_id,
         cur_option_rows.broker_name,
         cur_option_rows.broker_account_id,
         cur_option_rows.broker_account_name,
         cur_option_rows.broker_account_type,
         cur_option_rows.broker_comm_type_id,
         cur_option_rows.broker_comm_amt,
         cur_option_rows.broker_comm_cur_id,
         cur_option_rows.broker_cur_code,
         cur_option_rows.clearer_profile_id,
         cur_option_rows.clearer_name,
         cur_option_rows.clearer_account_id,
         cur_option_rows.clearer_account_name,
         cur_option_rows.clearer_account_type,
         cur_option_rows.clearer_comm_type_id,
         cur_option_rows.clearer_comm_amt,
         cur_option_rows.clearer_comm_cur_id,
         cur_option_rows.clearer_cur_code,
         cur_option_rows.product_id,
         cur_option_rows.product,
         cur_option_rows.quality_id,
         cur_option_rows.quality_name,
         cur_option_rows.trade_qty_unit_id,
         cur_option_rows.quantityname,
         cur_option_rows.lots_closed, --total_lots,
         cur_option_rows.quantity_closed, --.total_quantity,
         cur_option_rows.open_lots,
         cur_option_rows.open_quantity,
         cur_option_rows.exercised_lots,
         cur_option_rows.exercised_quantity,
         cur_option_rows.expired_lots,
         cur_option_rows.expired_quantity,
         cur_option_rows.trade_price_type_id,
         cur_option_rows.trade_price,
         cur_option_rows.trade_price_unit_id,
         cur_option_rows.trade_cur_id,
         cur_option_rows.trade_cur_code,
         cur_option_rows.trade_weight,
         cur_option_rows.trade_weight_unit_id,
         cur_option_rows.trade_qty_unit,
         cur_option_rows.formula_id,
         cur_option_rows.formula_name,
         cur_option_rows.formula_display,
         cur_option_rows.index_instrument_id,
         cur_option_rows.index_instrument_name,
         cur_option_rows.strike_price,
         cur_option_rows.strike_price_unit_id,
         cur_option_rows.strike_cur_id,
         cur_option_rows.strike_cur_code,
         cur_option_rows.strike_weight,
         cur_option_rows.strike_weight_unit_id,
         cur_option_rows.strike_qty_unit,
         cur_option_rows.premium_discount,
         cur_option_rows.premium_discount_price_unit_id,
         cur_option_rows.pd_cur_id,
         cur_option_rows.pd_cur_code,
         cur_option_rows.pd_weight,
         cur_option_rows.pd_weight_unit_id,
         cur_option_rows.pd_qty_unit,
         cur_option_rows.premium_due_date,
         cur_option_rows.nominee_profile_id,
         cur_option_rows.nominee_name,
         cur_option_rows.leg_no,
         cur_option_rows.option_expiry_date,
         cur_option_rows.parent_int_derivative_ref_no,
         cur_option_rows.market_location_country,
         cur_option_rows.market_location_state,
         cur_option_rows.market_location_city,
         cur_option_rows.is_what_if,
         cur_option_rows.payment_term,
         cur_option_rows.payment_term,
         cur_option_rows.payment_due_date,
         cur_option_rows.lots_closed,
         cur_option_rows.quantity_closed,
         cur_option_rows.is_new_trade_date,
         cur_option_rows.status,
         cur_option_rows.settlement_cur_id,
         cur_option_rows.settlement_cur_code,
         cur_option_rows.in_out_at_money_status,
         cur_option_rows.in_out_at_money_value,
         cur_option_rows.exercise_date,
         cur_option_rows.expiry_date,
         cur_option_rows.group_cur_id,
         cur_option_rows.group_cur_code,
         cur_option_rows.group_qty_unit_id,
         cur_option_rows.gcd_qty_unit,
         cur_option_rows.base_qty_unit_id,
         cur_option_rows.base_qty_unit,
         cur_option_rows.internal_close_out_ref_no,
         cur_option_rows.close_out_ref_no,
         cur_option_rows.close_out_date,
         vn_market_price_in_trade_cur,
         vc_settlement_price_unit_id,
         vc_settlement_cur_id,
         vc_settlement_cur_code,
         vc_settlement_weight,
         vc_settlement_weight_unit_id,
         vc_settlement_weight_unit,
         cur_option_rows.parent_instrument_type,
         vn_clearer_comm_in_base_cur,
         vn_broker_comm_in_base_cur,
         vn_clr_cur_to_base_exch_rate,
         vn_brokr_cur_to_base_exch_rate,
         vn_trade_to_base_exch_rate,
         cur_option_rows.pnl_type,
         vn_net_pnl_in_base_cur,
         vn_pnl_value_in_trade_cur,
         cur_option_rows.base_cur_id,
         cur_option_rows.base_cur_code,
         cur_option_rows.underlying_future_dr_id,
         cur_option_rows.underlying_future_dr_id_name,
         cur_option_rows.underlying_future_expiry_date,
         cur_option_rows.underlying_future_quote_price,
         cur_option_rows.underlying_fut_price_unit_id,
         cur_option_rows.process_id,
         vn_trade_qty_exch_unit);
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_option_realized_pnl',
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

  function f_get_is_derived_qty_unit(pc_qty_unit_id in varchar2)
    return varchar2 is
    vc_is_derived_unit varchar2(1);
  begin
    select qum.is_derrived
      into vc_is_derived_unit
      from qum_quantity_unit_master qum
     where qum.qty_unit_id = pc_qty_unit_id;
    return vc_is_derived_unit;
  end;

  function f_get_converted_quantity(pc_product_id          in varchar2,
                                    pc_from_qty_unit_id    in varchar2,
                                    pc_to_qty_unit_id      in varchar2,
                                    pn_qty_to_be_converted in number)
    return number is
    vn_conv_factor             number;
    vn_converted_qty           number;
    vc_is_from_der_qty_unit_id varchar2(1);
    vc_is_to_der_qty_unit_id   varchar2(1);
    vc_base_form_qty_unit_id   varchar2(15) := pc_from_qty_unit_id;
    vn_from_der_to_base_conv   number(20, 5) := 1;
    vc_base_to_qty_unit_id     varchar2(15) := pc_to_qty_unit_id;
    vn_to_der_to_base_conv     number(20, 5) := 1;
  begin
    begin
      vc_is_from_der_qty_unit_id := f_get_is_derived_qty_unit(pc_from_qty_unit_id);
      vc_is_to_der_qty_unit_id   := f_get_is_derived_qty_unit(pc_to_qty_unit_id);
      if (vc_is_from_der_qty_unit_id = 'Y') then
        select dqu.qty_unit_id,
               dqu.qty
          into vc_base_form_qty_unit_id,
               vn_from_der_to_base_conv
          from dqu_derived_quantity_unit dqu
         where dqu.derrived_qty_unit_id = pc_from_qty_unit_id
           and dqu.product_id = pc_product_id
           and rownum < 2;
      end if;
      if (vc_is_to_der_qty_unit_id = 'Y') then
        select dqu.qty_unit_id,
               dqu.qty
          into vc_base_to_qty_unit_id,
               vn_to_der_to_base_conv
          from dqu_derived_quantity_unit dqu
         where dqu.derrived_qty_unit_id = pc_to_qty_unit_id
           and dqu.product_id = pc_product_id
           and rownum < 2;
      end if;
      select ucm.multiplication_factor
        into vn_conv_factor
        from ucm_unit_conversion_master ucm
       where ucm.from_qty_unit_id = vc_base_form_qty_unit_id
         and ucm.to_qty_unit_id = vc_base_to_qty_unit_id;
      vn_converted_qty := round(vn_from_der_to_base_conv /
                                vn_to_der_to_base_conv * vn_conv_factor *
                                pn_qty_to_be_converted,
                                15);
      return vn_converted_qty;
    exception
      when no_data_found then
        return - 1;
      when others then
        return - 1;
    end;
  end;

  function f_get_converted_currency_amt
  /**************************************************************************************************
    Function Name                       : f_get_converted_currency_amt
    Author                              : Janna
    Created Date                        : 19th Aug 2008
    Purpose                             : To convert a given amount between two currencies as on a given date
    Parameters                          :
    pc_corporate_id                     : Corporate ID
    pc_from_cur_id                      : From Currency
    pc_to_cur_id                        : To Currency
    pd_cur_date                         : Currency Date
    pn_amt_to_be_converted              : Amount to be converted
    Returns                             :
    Number                              : Converted amount
    Modification History
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id        in varchar2,
   pc_from_cur_id         in varchar2,
   pc_to_cur_id           in varchar2,
   pd_cur_date            in date,
   pn_amt_to_be_converted in number) return number is
    vn_result                    number;
    vc_base_cur_id               varchar2(30);
    vc_from_main_cur_id          varchar2(30);
    vc_to_main_cur_id            varchar2(30);
    vn_from_rate                 number;
    vn_from_main_currency_factor number := 1;
    vn_to_main_currency_factor   number := 1;
    vn_to_rate                   number;
  begin
    vn_from_rate        := 1;
    vn_to_rate          := 1;
    vc_from_main_cur_id := pc_from_cur_id;
    vc_to_main_cur_id   := pc_to_cur_id;
    -- Get the Base Currency ID of the corporate
    -- This is used to determine if one of the currencies given is the base currency itself
    -- Since AK_CORPORATE is not having Currency ID column and we are not changing it now
    -- We are joining CUR_CODE of CM with BASE_CURRENCY_NAME of AK_CORPORATE
    -- When AK_CORPORATE table is revamped change this code
    begin
      select akc.base_cur_id
        into vc_base_cur_id
        from ak_corporate akc
       where akc.corporate_id = pc_corporate_id;
      --  AND cm.cur_code = akc.base_currency_name;
    exception
      when no_data_found then
        return - 1;
    end;
    -- Check if the currency passed is a sub-currency if yes take into account
    -- the sub currency factor...
    begin
      select scd.cur_id,
             scd.factor
        into vc_from_main_cur_id,
             vn_from_main_currency_factor
        from cm_currency_master      cm,
             scd_sub_currency_detail scd
       where cm.cur_id = scd.cur_id
         and scd.sub_cur_id = pc_from_cur_id;
    exception
      when no_data_found then
        vn_from_main_currency_factor := 1;
        vc_from_main_cur_id          := pc_from_cur_id;
    end;
    begin
      select scd.cur_id,
             scd.factor
        into vc_to_main_cur_id,
             vn_to_main_currency_factor
        from cm_currency_master      cm,
             scd_sub_currency_detail scd
       where cm.cur_id = scd.cur_id
         and scd.sub_cur_id = pc_to_cur_id;
    exception
      when no_data_found then
        vn_to_main_currency_factor := 1;
        vc_to_main_cur_id          := pc_to_cur_id;
    end;
    if vc_base_cur_id = vc_from_main_cur_id and
       vc_base_cur_id = vc_to_main_cur_id then
      vn_from_rate := 1;
      vn_to_rate   := 1;
    else
      begin
        -- Get the From Currency Exchange rate
        if pc_to_cur_id = pc_from_cur_id then
          return(pn_amt_to_be_converted);
        else
          if vc_from_main_cur_id != vc_base_cur_id then
            select cq.close_rate
              into vn_from_rate
              from cq_currency_quote cq
             where cq.cur_id = vc_from_main_cur_id
               and cq.corporate_id = pc_corporate_id
               and cq.cur_date =
                   (select max(cq1.cur_date)
                      from cq_currency_quote cq1
                     where cq1.cur_id = vc_from_main_cur_id
                       and cq1.corporate_id = pc_corporate_id
                       and cq1.cur_date <= pd_cur_date);
          end if;
          -- Get the To Currency Exchange rate
          if vc_to_main_cur_id != vc_base_cur_id then
            select cq.close_rate
              into vn_to_rate
              from cq_currency_quote cq
             where cq.cur_id = upper(vc_to_main_cur_id)
               and cq.corporate_id = pc_corporate_id
               and cq.cur_date =
                   (select max(cq1.cur_date)
                      from cq_currency_quote cq1
                     where cq1.cur_id = upper(vc_to_main_cur_id)
                       and cq1.corporate_id = pc_corporate_id
                       and cq1.cur_date <= pd_cur_date);
          end if;
        end if;
      exception
        when no_data_found then
          return - 1;
      end;
    end if;
    vn_result := pn_amt_to_be_converted *
                 ((vn_to_rate / vn_to_main_currency_factor) /
                 (vn_from_rate / vn_from_main_currency_factor));
    return(vn_result);
  exception
    when no_data_found then
      return - 1;
  end;

  function f_currency_exchange_rate(pd_trade_date   date,
                                    pc_corporate_id varchar2,
                                    pd_prompt_date  varchar2,
                                    pc_from_cur_id  varchar2,
                                    pc_to_cur_id    varchar2) return number is
    vn_result number;
    /******************************************************************************************************************************************
    procedure name                            : f_currency_exchange_rate
    author                                    :
    created date                              :
    purpose                                   :
    parameters                                :
    modification history                      :
    modified date                             :
    modified by                               :
    modify description                        :
    ******************************************************************************************************************************************/
  begin
    vn_result := f_get_converted_currency_amt(pc_corporate_id,
                                              pc_from_cur_id,
                                              pc_to_cur_id,
                                              pd_trade_date,
                                              1);
    return vn_result;
  end;

  function f_get_converted_price_pum(pc_corporate_id       varchar2,
                                     pn_price              number,
                                     pc_from_price_unit_id varchar2,
                                     pc_to_price_unit_id   varchar2,
                                     pd_trade_date         date,
                                     pc_product_id         varchar2)
    return number is
    vn_result number;
  
  begin
    if pc_from_price_unit_id = pc_to_price_unit_id then
      return pn_price;
    else
    
      select nvl(round(nvl(pn_price, 0) *
                       f_get_converted_currency_amt(pc_corporate_id,
                                                    pum1.cur_id,
                                                    pum2.cur_id,
                                                    pd_trade_date,
                                                    1) *
                       f_get_converted_quantity(pc_product_id,
                                                pum1.weight_unit_id,
                                                pum2.weight_unit_id,
                                                1) * nvl(pum1.weight, 1) /
                       nvl(pum2.weight, 1),
                       5),
                 0)
        into vn_result
        from pum_price_unit_master pum1,
             pum_price_unit_master pum2
       where pum1.price_unit_id = pc_from_price_unit_id
         and pum2.price_unit_id = pc_to_price_unit_id
         and pum1.is_deleted = 'N'
         and pum2.is_deleted = 'N';
      return vn_result;
    end if;
  exception
    when others then
      return 0;
  end;

  function f_get_next_day(p_date     in date,
                          p_day      in varchar2,
                          p_position in number) return date is
  
    v_position_date      date;
    v_next_position      number;
    v_start_day          varchar2(10);
    v_first_day_position date;
  
  begin
  
    begin
      v_next_position := (p_position - 1) * 7;
      v_start_day     := to_char(to_date('01-' ||
                                         to_char(trunc(p_date), 'mon-yyyy'),
                                         'dd-mon-yyyy'),
                                 'dy');
      if upper(trim(v_start_day)) = upper(trim(p_day)) then
        v_first_day_position := to_date('01-' ||
                                        to_char(trunc(p_date), 'mon-yyyy'),
                                        'dd-mon-yyyy');
      else
        v_first_day_position := next_day(to_date('01-' ||
                                                 to_char(p_date, 'mon-yyyy'),
                                                 'dd-mon-yyyy'),
                                         trim(p_day));
      end if;
    
      if v_next_position <= 1 then
        v_position_date := trunc(v_first_day_position);
      else
        v_position_date := trunc(v_first_day_position) + v_next_position;
      end if;
    exception
      when no_data_found then
        return null;
      when others then
        return null;
    end;
    return v_position_date;
  end f_get_next_day;

  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean is
    pc_counter number(1);
    result_val boolean;
  begin
    --Checking the Week End Holiday List
    begin
      select count(*)
        into pc_counter
        from dual
       where to_char(pc_trade_date, 'Dy') in
             (select clwh.holiday
                from dim_der_instrument_master    dim,
                     clm_calendar_master          clm,
                     clwh_calendar_weekly_holiday clwh
               where dim.holiday_calender_id = clm.calendar_id
                 and clm.calendar_id = clwh.calendar_id
                 and dim.instrument_id = pc_instrumentid
                 and clm.is_deleted = 'N'
                 and clwh.is_deleted = 'N');
      if (pc_counter = 1) then
        result_val := true;
      else
        result_val := false;
      end if;
      if (result_val = false) then
        --Checking Other Holiday List
        select count(*)
          into pc_counter
          from dual
         where trim(pc_trade_date) in
               (select trim(hl.holiday_date)
                  from hm_holiday_master         hm,
                       hl_holiday_list           hl,
                       dim_der_instrument_master dim,
                       clm_calendar_master       clm
                 where hm.holiday_id = hl.holiday_id
                   and dim.holiday_calender_id = clm.calendar_id
                   and clm.calendar_id = hm.calendar_id
                   and dim.instrument_id = pc_instrumentid
                   and hm.is_deleted = 'N'
                   and hl.is_deleted = 'N');
        if (pc_counter = 1) then
          result_val := true;
        else
          result_val := false;
        end if;
      end if;
    end;
    return result_val;
  end f_is_day_holiday;

  procedure sp_calc_daily_initial_margin(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2) is
    /*******************************************************************************************************************************************
    Procedure Name                            : sp_calc_daily_initial_margin
    Author                                    : Janna
    Created Date                              : 10th Jan 2009
    Purpose                                   : Calculate the Tradewise daily initial margin as on EOD Date
    Parameters
    pc_corporate_id                           : Corporate ID
    pd_trade_date                             : EOD Date ID
    pc_process_id                             : EOD Reference No
    Modification History
    Modified Date                             :
    Modified By                               :
    Modify Description                        :
    ******************************************************************************************************************************************/
    vc_base_cur_code varchar2(15);
    vc_base_cur_id   varchar2(15);
    --vn_sp_margin_amt_per_lot    number(25, 5) := 0;
    --vc_sp_margin_cur_id         varchar2(15);
    --vn_ot_margin_amt_per_lot    number(25, 5) := 0;
    --vc_ot_margin_cur_id         varchar2(15);
    --vn_op_margin_amt_per_lot    number(25, 5) := 0;
    --vc_op_margin_cur_id         varchar2(15);
    --vc_sp_margin_cur_code       varchar2(15);
    --vc_ot_margin_cur_code       varchar2(15);
    --vc_op_margin_cur_code       varchar2(15);
    vobj_error_log              tableofpelerrorlog := tableofpelerrorlog();
    vn_future_spread            number;
    vn_future_outright          number;
    vn_option_short             number;
    vc_future_spread_cur_id     varchar2(15);
    vc_future_outright_cur_id   varchar2(15);
    vc_option_short_cur_id      varchar2(15);
    vc_future_spread_cur_code   varchar2(15);
    vc_future_outright_cur_code varchar2(15);
    vc_option_short_cur_code    varchar2(15);
    vn_eel_error_count          number := 1;
  
    cursor cur_future is
      select corporate_id,
             corporate_name,
             clearer_profile_id,
             clearer_name,
             product_id,
             product_name,
             product_derivative_id,
             derivative_def_name,
             exchange_id,
             exchange_name,
             instrument_type,
             instrument_type_id,
             (case
               when buy_lots > sell_lots then
                sell_lots
               else
                buy_lots
             end) no_of_lots,
             buy_lots,
             sell_lots
        from (select t.corporate_id,
                     t.corporate_name,
                     t.clearer_profile_id,
                     t.clearer_name,
                     t.product_id,
                     t.product_name,
                     t.product_derivative_id,
                     t.derivative_def_name,
                     t.exchange_id,
                     t.exchange_name,
                     t.instrument_type,
                     t.instrument_type_id,
                     sum((case
                           when t.net_lots > 0 then
                            t.net_lots
                           else
                            0
                         end)) buy_lots,
                     sum((case
                           when t.net_lots < 0 then
                            abs(t.net_lots)
                           else
                            0
                         end)) sell_lots,
                     sum(t.net_lots) net_lots
                from (select dt.corporate_id,
                             akc.corporate_name,
                             dt.clearer_profile_id clearer_profile_id,
                             nvl(phd.company_long_name1, phd.companyname) clearer_name,
                             dim.product_derivative_id,
                             pdd.product_id,
                             pdm.product_desc product_name,
                             pdd.derivative_def_name,
                             pdd.exchange_id,
                             emt.exchange_name,
                             irm.instrument_type,
                             irm.instrument_type_id,
                             sum((case
                                   when dt.trade_type = 'Buy' then
                                    dt.open_lots
                                 --drt.no_of_lots
                                   else
                                    (-1) * dt.open_lots
                                 --drt.no_of_lots * (-1)
                                 end)) net_lots
                        from dt_derivative_trade        dt,
                             drm_derivative_master      drm,
                             dim_der_instrument_master  dim,
                             irm_instrument_type_master irm,
                             pdd_product_derivative_def pdd,
                             emt_exchangemaster         emt,
                             ak_corporate               akc,
                             phd_profileheaderdetails   phd,
                             pdm_productmaster          pdm
                       where dt.dr_id = drm.dr_id
                         and drm.instrument_id = dim.instrument_id
                         and pdd.derivative_def_id =
                             dim.product_derivative_id
                         and dt.process_id = pc_process_id
                         and irm.instrument_type_id = dim.instrument_type_id
                         and irm.instrument_type in ('Future', 'Forward')
                         and dt.status = 'Verified'
                         and dt.is_what_if = 'N'
                         and dt.corporate_id = pc_corporate_id
                         and dt.trade_date <= pd_trade_date
                         and pdd.exchange_id = emt.exchange_id
                         and dt.corporate_id = akc.corporate_id
                         and dt.clearer_profile_id = phd.profileid
                         and pdd.product_id = pdm.product_id
                       group by dt.corporate_id,
                                akc.corporate_name,
                                dt.clearer_profile_id,
                                nvl(phd.company_long_name1, phd.companyname),
                                dim.product_derivative_id,
                                pdd.product_id,
                                pdm.product_desc,
                                pdd.derivative_def_name,
                                pdd.exchange_id,
                                emt.exchange_name,
                                irm.instrument_type_id,
                                irm.instrument_type,
                                dt.trade_type,
                                dt.open_lots) t
               group by t.corporate_id,
                        t.corporate_name,
                        t.clearer_profile_id,
                        t.clearer_name,
                        t.product_id,
                        t.product_name,
                        t.product_derivative_id,
                        t.derivative_def_name,
                        t.exchange_id,
                        t.exchange_name,
                        t.instrument_type,
                        t.instrument_type_id);
  
    cursor cur_options is
      select corporate_id,
             corporate_name,
             clearer_profile_id,
             clearer_name,
             product_id,
             product_name,
             derivative_def_id,
             derivative_def_name,
             exchange_id,
             exchange_name,
             'Short' option_type,
             instrument_type,
             instrument_type_id,
             sum(delta_value) delta_value,
             no_of_lots
        from (select dt.corporate_id,
                     akc.corporate_name,
                     dt.clearer_profile_id clearer_profile_id,
                     nvl(phd.company_long_name1, phd.companyname) clearer_name,
                     pdd.product_id,
                     pdm.product_desc product_name,
                     pdd.derivative_def_id derivative_def_id,
                     pdd.derivative_def_name derivative_def_name,
                     pdd.exchange_id,
                     emt.exchange_name,
                     irm.instrument_type,
                     irm.instrument_type_id,
                     
                     --drt.strike_price,
                     sum(dt.open_lots) no_of_lots,
                     dqd.delta,
                     sum(dt.open_lots) * dqd.delta delta_value
                from dt_derivative_trade         dt,
                     dq_derivative_quotes        dq,
                     dqd_derivative_quote_detail dqd,
                     drm_derivative_master       drm,
                     dim_der_instrument_master   dim,
                     irm_instrument_type_master  irm,
                     pdd_product_derivative_def  pdd,
                     emt_exchangemaster          emt,
                     ak_corporate                akc,
                     phd_profileheaderdetails    phd,
                     pdm_productmaster           pdm
               where dt.dr_id = drm.dr_id
                 and dt.dr_id = dqd.dr_id
                 and dq.dq_id = dqd.dq_id
                 and dq.corporate_id = dt.corporate_id
                 and dq.trade_date = pd_trade_date
                 and dq.process_id = pc_process_id
                 and dt.process_id = pc_process_id
                 and drm.instrument_id = dim.instrument_id
                 and pdd.derivative_def_id = dim.product_derivative_id
                 and irm.instrument_type_id = dim.instrument_type_id
                 and dim.instrument_type_id = irm.instrument_type_id
                 and irm.instrument_type_id in ('Option Put', 'Option Call')
                 and dt.status = 'Verified'
                 and dt.is_what_if = 'N'
                 and dt.corporate_id = pc_corporate_id
                 and dt.trade_date <= pd_trade_date
                 and pdd.exchange_id = emt.exchange_id(+)
                 and dt.trade_type = 'Sell'
                    -- AND drt.strike_price = dq.strike_price(+) --???
                 and dt.corporate_id = akc.corporate_id
                 and dt.clearer_profile_id = phd.profileid
                 and pdd.product_id = pdm.product_id
               group by dt.corporate_id,
                        akc.corporate_name,
                        dt.clearer_profile_id,
                        nvl(phd.company_long_name1, phd.companyname),
                        pdd.product_id,
                        pdm.product_desc,
                        pdd.derivative_def_id,
                        pdd.derivative_def_name,
                        pdd.exchange_id,
                        emt.exchange_name,
                        irm.instrument_type,
                        irm.instrument_type_id,
                        irm.instrument_type_id,
                        --drt.strike_price,
                        dqd.delta)
       group by corporate_id,
                corporate_name,
                clearer_profile_id,
                clearer_name,
                product_id,
                product_name,
                derivative_def_id,
                derivative_def_name,
                instrument_type,
                instrument_type_id,
                exchange_id,
                exchange_name,
                no_of_lots;
  begin
    --DBMS_OUTPUT.put_line('inside dim');
  
    select akc.base_currency_name,
           cm.cur_id
      into vc_base_cur_code,
           vc_base_cur_id
      from ak_corporate       akc,
           cm_currency_master cm
     where akc.corporate_id = pc_corporate_id
       and cm.cur_code = akc.base_currency_name;
  
    -- DBMS_OUTPUT.put_line('Before loop');
  
    for cur_future_rows in cur_future
    loop
    
      /*To Record the Futures Margin */
    
      -- DBMS_OUTPUT.put_line('inside loop');
    
      begin
        select future_spread,
               future_outright,
               option_short,
               future_spread_cur_id,
               future_outright_cur_id,
               option_short_cur_id,
               cm_spread.cur_code,
               cm_outright.cur_code,
               cm_option.cur_code
          into vn_future_spread,
               vn_future_outright,
               vn_option_short,
               vc_future_spread_cur_id,
               vc_future_outright_cur_id,
               vc_option_short_cur_id,
               vc_future_spread_cur_code,
               vc_future_outright_cur_code,
               vc_option_short_cur_code
          from ims_initial_margin_setup ims,
               cm_currency_master cm_spread,
               cm_currency_master cm_outright,
               cm_currency_master cm_option,
               (select ims1.corporate_id,
                       ims1.derivative_def_id,
                       ims1.product_id
                  from ims_initial_margin_setup ims1
                 where ims1.validity_to_date >= pd_trade_date
                   and ims1.validity_from_date <= pd_trade_date
                   and ims1.corporate_id = pc_corporate_id
                   and ims1.is_deleted = 'N'
                 group by ims1.corporate_id,
                          ims1.derivative_def_id,
                          ims1.product_id) ims2
         where ims.derivative_def_id =
               cur_future_rows.product_derivative_id
           and ims.corporate_id = pc_corporate_id
           and ims.product_id = cur_future_rows.product_id
           and ims.future_spread_cur_id = cm_spread.cur_id
           and ims.future_outright_cur_id = cm_outright.cur_id
           and ims.option_short_cur_id = cm_option.cur_id
           and ims.validity_to_date >= pd_trade_date
           and ims.validity_from_date <= pd_trade_date
           and ims.corporate_id = ims2.corporate_id
           and ims.derivative_def_id = ims2.derivative_def_id
           and ims.product_id = ims2.product_id
           and ims.is_deleted = 'N';
      
        --preeti add logic to pick up latest valid ones
        --DBMS_OUTPUT.put_line('got values without error');
      exception
        when no_data_found then
          vn_future_spread            := 0;
          vn_future_outright          := 0;
          vn_option_short             := 0;
          vc_future_spread_cur_id     := null;
          vc_future_outright_cur_id   := null;
          vc_option_short_cur_id      := null;
          vc_future_spread_cur_code   := null;
          vc_future_outright_cur_code := null;
          vc_option_short_cur_code    := null;
      end;
    
      --DBMS_OUTPUT.put_line('before insert');
    
      insert into dim_daily_initial_margin
        (corporate_id,
         corporate_name,
         process_id,
         trade_date,
         clearer_profile_id,
         clearer_name,
         product_id,
         product_name,
         exch_id,
         exch_name,
         derivative_def_id,
         derivative_def_name,
         instrument_type,
         margin_type,
         spread_margin_per_lot,
         spread_margin_cur_id,
         spread_margin_cur_code,
         outright_margin_per_lot,
         outright_margin_cur_id,
         outright_margin_cur_code,
         no_of_lots,
         long_lots,
         short_lots,
         base_cur_id,
         base_cur_code,
         exch_rate,
         option_margin_rate)
      values
        (cur_future_rows.corporate_id,
         cur_future_rows.corporate_name,
         pc_process_id,
         pd_trade_date,
         cur_future_rows.clearer_profile_id,
         cur_future_rows.clearer_name,
         cur_future_rows.product_id,
         cur_future_rows.product_name,
         cur_future_rows.exchange_id,
         cur_future_rows.exchange_name,
         cur_future_rows.product_derivative_id,
         cur_future_rows.derivative_def_name,
         cur_future_rows.instrument_type,
         'Futures',
         vn_future_spread,
         vc_future_spread_cur_id,
         vc_future_spread_cur_code,
         vn_future_outright,
         vc_future_outright_cur_id,
         vc_future_outright_cur_code,
         cur_future_rows.no_of_lots,
         cur_future_rows.buy_lots,
         cur_future_rows.sell_lots,
         vc_base_cur_id,
         vc_base_cur_code,
         f_get_converted_currency_amt(pc_corporate_id,
                                      vc_future_spread_cur_id,
                                      vc_base_cur_id,
                                      pd_trade_date,
                                      1),
         vn_option_short);
    
      dbms_output.put_line('after insert' || sql%rowcount);
    
   
    end loop;
  
    --DBMS_OUTPUT.put_line('after futures');
  
    /*   To Record the Options   */
  
    for cur_option_rows in cur_options
    loop
      -- DBMS_OUTPUT.put_line('in options');
    
      begin
        select future_spread,
               future_outright,
               option_short,
               future_spread_cur_id,
               future_outright_cur_id,
               option_short_cur_id,
               cm_spread.cur_code,
               cm_outright.cur_code,
               cm_option.cur_code
          into vn_future_spread,
               vn_future_outright,
               vn_option_short,
               vc_future_spread_cur_id,
               vc_future_outright_cur_id,
               vc_option_short_cur_id,
               vc_future_spread_cur_code,
               vc_future_outright_cur_code,
               vc_option_short_cur_code
          from ims_initial_margin_setup@eka_appdb ims,
               cm_currency_master cm_spread,
               cm_currency_master cm_outright,
               cm_currency_master cm_option,
               (select ims1.corporate_id,
                       ims1.derivative_def_id,
                       ims1.product_id
                  from ims_initial_margin_setup ims1
                 where ims1.validity_to_date >= pd_trade_date
                   and ims1.validity_from_date <= pd_trade_date
                   and ims1.corporate_id = pc_corporate_id
                   and ims1.is_deleted = 'N'
                 group by ims1.corporate_id,
                          ims1.derivative_def_id,
                          ims1.product_id) ims2
         where ims.derivative_def_id = cur_option_rows.derivative_def_id
           and ims.corporate_id = pc_corporate_id
           and ims.product_id = cur_option_rows.product_id
           and ims.future_spread_cur_id = cm_spread.cur_id
           and ims.future_outright_cur_id = cm_outright.cur_id
           and ims.option_short_cur_id = cm_option.cur_id
           and ims.validity_to_date >= pd_trade_date
           and ims.validity_from_date <= pd_trade_date
           and ims.corporate_id = ims2.corporate_id
           and ims.derivative_def_id = ims2.derivative_def_id
           and ims.product_id = ims2.product_id
           and ims.is_deleted = 'N';
      
        --preeti add logic to pick up latest valid ones
        -- DBMS_OUTPUT.put_line('after select in otiosn');
      exception
        when no_data_found then
          vn_future_spread            := 0;
          vn_future_outright          := 0;
          vn_option_short             := 0;
          vc_future_spread_cur_id     := null;
          vc_future_outright_cur_id   := null;
          vc_option_short_cur_id      := null;
          vc_future_spread_cur_code   := null;
          vc_future_outright_cur_code := null;
          vc_option_short_cur_code    := null;
      end;
    
      -- DBMS_OUTPUT.put_line('before insert n options');
    
      insert into dim_daily_initial_margin
        (corporate_id,
         corporate_name,
         process_id,
         trade_date,
         clearer_profile_id,
         clearer_name,
         product_id,
         product_name,
         exch_id,
         exch_name,
         derivative_def_id,
         derivative_def_name,
         instrument_type,
         margin_type,
         spread_margin_per_lot,
         spread_margin_cur_id,
         spread_margin_cur_code,
         outright_margin_per_lot,
         outright_margin_cur_id,
         outright_margin_cur_code,
         no_of_lots,
         long_lots,
         short_lots,
         base_cur_id,
         base_cur_code,
         exch_rate,
         option_margin_rate)
      values
        (cur_option_rows.corporate_id,
         cur_option_rows.corporate_name,
         pc_process_id,
         pd_trade_date,
         cur_option_rows.clearer_profile_id,
         cur_option_rows.clearer_name,
         cur_option_rows.product_id,
         cur_option_rows.product_name,
         cur_option_rows.exchange_id,
         cur_option_rows.exchange_name,
         cur_option_rows.derivative_def_id,
         cur_option_rows.derivative_def_name,
         cur_option_rows.instrument_type,
         'Options',
         vn_future_spread,
         vc_future_spread_cur_id,
         vc_future_spread_cur_code,
         null,
         null,
         null,
         cur_option_rows.no_of_lots,
         null,
         null,
         vc_base_cur_id,
         vc_base_cur_code,
         f_get_converted_currency_amt(pc_corporate_id,
                                      vc_future_spread_cur_id,
                                      vc_base_cur_id,
                                      pd_trade_date,
                                      1),
         vn_option_short);
    end loop;
  
    --DBMS_OUTPUT.put_line('after options');
  
    /* preeti . These are not required for AWB
    --To Record the Long Options, long Options are premium paid trades,
    
    /*INSERT INTO dim_daily_initial_margin
        (corporate_id,
         corporate_name,
         process_id,
         trade_date,
         clearer_profile_id,
         clearer_name,
         product_id,
         product_name,
         exch_id,
         exch_name,
         derivative_def_id,
         derivative_def_name,
         instrument_type,
         margin_type,
         spread_margin_amt_per_lot,
         spread_margin_cur_id,
         spread_margin_cur_code,
         no_of_lots,
         total_margin_amt,
         margin_amt_in_base_cur,
         base_cur_id,
         base_cur_code)
        SELECT t.corporate_id,
               t.corporate_name,
               pc_process_id,
               pd_trade_date,
               t.clearer_profile_id,
               t.clearer_name,
               t.product_id,
               t.product_name,
               t.exchange_id,
               t.exchange_name,
               t.derivative_def_id,
               t.derivative_def_name,
               t.instrument_type instrument_type,
               t.option_type margin_type,
               0 margin_amt_per_lot,
               t.cur_id,
               t.base_currency_name margin_cur_code,
               t.no_of_lots,
               t.premium_paid tot_margin_amt,
               t.premium_paid margin_amt_base,
               t.base_cur_id,
               t.base_currency_name base_currency
        FROM   (SELECT dt.corporate_id,
                       dt.clearer_profile_id clearer_profile_id,
                       pdd.product_id,
                       cm.cur_id,
                       pdd.exchange_id,
                       irm.instrument_type,
                       'Long' option_type,
                       SUM(dt.total_lots) no_of_lots,
                       SUM(dt.total_lots * pdd.lot_size *
                           pkg_general.f_get_converted_quantity(NULL,
                                                                pdd.lot_size_unit_id,
                                                                pum.weight_unit_id,
                                                                1) *
                           (dt.trade_price / nvl(pum.weight,
                                            1)) *
                           pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                                    cm.cur_id,
                                                                    akc.base_currency_name,
                                                                    SYSDATE,
                                                                    1)) premium_paid,
                       akc.base_currency_name,
                       akc.corporate_name,
                       nvl(phd.company_long_name1,
                           phd.companyname) clearer_name,
                       pdm.product_desc product_name,
                       pdd.derivative_def_id,
                       pdd.derivative_def_name,
                       emt.exchange_name,
                       cm_ak_currency.cur_id AS base_cur_id
                FROM   dt_derivative_trade                dt,
                       drm_derivative_master              drm,
                       dim_der_instrument_master          dim,
                       irm_instrument_type_master         irm,
                       pdd_product_derivative_def         pdd,
                       emt_exchangemaster                 emt,
                       ak_corporate                       akc,
                       phd_profileheaderdetails           phd,
                       pdm_productmaster                  pdm,
                       cm_currency_master                 cm,
                       cm_currency_master                 cm_ak_currency,
                       pum_price_unit_master              pum
                WHERE  dt.dr_id = drm.dr_id
                AND    drm.instrument_id = dim.instrument_id
                AND    pdd.derivative_def_id = dim.product_derivative_id
                AND    irm.instrument_type_id = dim.instrument_type_id
                AND    irm.instrument_type_id IN
                       ('IRMCO', 'IRMPO', 'IRMOTCO', 'IRMOTPO')
                AND    dt.status = 'Verified'
                AND    dt.corporate_id = pc_corporate_id
                AND    dt.trade_date <= pd_trade_date
                AND    pdd.exchange_id = emt.exchange_id(+)
                AND    dt.trade_type = 'Buy'
                AND    dt.corporate_id = akc.corporate_id
                AND    dt.clearer_profile_id = phd.profileid
                AND    pdd.product_id = pdm.product_id
                AND    dt.trade_price_unit_id = pum.price_unit_id
                AND    pum.cur_id = cm.cur_id
                AND    cm_ak_currency.cur_code = akc.base_currency_name
                GROUP  BY dt.corporate_id,
                          dt.clearer_profile_id,
                          pdd.product_id,
                          pdd.exchange_id,
                          irm.instrument_type,
                          akc.base_currency_name,
                          akc.corporate_name,
                          nvl(phd.company_long_name1,
                              phd.companyname),
                          pdm.product_desc,
                          pdd.derivative_def_id,
                          pdd.derivative_def_name,
                          emt.exchange_name,
                          cm.cur_id,
                          cm_ak_currency.cur_id) t; */
  exception
    when others then
      dbms_output.put_line('failing here ' || sqlerrm);
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_daily_initial_margin',
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

  /*procedure sp_calc_future_accounts(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_process_id   varchar2,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    insert into fad_future_account_daily
      (corporate_id,
       corporate_name,
       eod_trade_date,
       process_id,
       acc_type_id,
       acc_type_name,
       --acc_id,
       --acc_no,
       acc_qty,
       acc_qty_unit_id,
       acc_qty_in_lots,
       trade_date,
       exchange_id,
       exchange_name,
       period_month,
       period_year,
       period_date,
       instrument_type_id,
       instrument_type,
       instrument_id,
       instrument_name,
       order_type_id,
       order_type,
       dr_id,
       derivative_def_id,
       derivative_def_name,
       derivative_ref_no,
       profit_center_id,
       profit_center_name,
       profit_center_short_name,
       future_month_name,
       buy_sell,
       no_of_lots,
       lot_size,
       strike_price,
       strike_price_unit_id,
       strike_price_cur_id,
       strike_price_cur_code,
       strike_price_cur_weight,
       strike_price_cur_wt_unit_id,
       strike_price_cur_weight_unit,
       settlement_price)
    --parent_instrument_type)
      select akc.corporate_id,
             akc.corporate_name,
             pd_trade_date,
             pc_process_id,
             satm.acc_type_id,
             satm.acc_type_name,
             --sa.acc_id,
             --sa.acc_no,
             sum(dsa.acc_qty),
             dsa.acc_qty_unit_id,
             sum(dsa.quantity_in_lots),
             dt.trade_date,
             emt.exchange_id,
             emt.exchange_name,
             drm.period_month,
             drm.period_year,
             to_date('01/' || drm.period_month || '-' || drm.period_year,
                     'dd-mon-yyyy'),
             irm.instrument_type_id,
             irm.instrument_type,
             dim.instrument_id,
             dim.instrument_name,
             dt.deal_type_id,
             dtm.deal_type_id,
             dt.dr_id,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             dt.derivative_ref_no,
             dt.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             drm.dr_id_name as future_month_name,
             dt.trade_type,
             dt.total_lots,
             pdd.lot_size,
             dt.strike_price,
             dt.strike_price_unit_id,
             cm_drt_strike.cur_id,
             cm_drt_strike.cur_code,
             pum_drt_strike.weight,
             pum_drt_strike.weight_unit_id,
             qum_drt_strike.qty_unit,
             dt.trade_price
      --irm.parent_instrument_type
        from satm_strategy_acc_type_master satm,
             --sa_strategy_account@eka_appdb                 sa,
             dsa_der_strategy_account    dsa,
             dt_derivative_trade         dt,
             ak_corporate@eka_appdb      akc,
             drm_derivative_master       drm,
             dim_der_instrument_master   dim,
             irm_instrument_type_master  irm,
             pdd_product_derivative_def  pdd,
             emt_exchangemaster          emt,
             dtm_deal_type_master        dtm,
             cpc_corporate_profit_center cpc,
             pum_price_unit_master       pum_drt_strike,
             cm_currency_master          cm_drt_strike,
             qum_quantity_unit_master    qum_drt_strike
       where
      --satm.acc_type_id = sa.acc_type_id
       satm.corporate_id = akc.corporate_id
      --and    sa.acc_id = dsa.acc_id
       and dsa.internal_derivative_ref_no = dt.internal_derivative_ref_no
       and dt.dr_id = drm.dr_id
       and drm.instrument_id = dim.instrument_id
       and dim.product_derivative_id = pdd.derivative_def_id
       and irm.instrument_type_id = dim.instrument_type_id
       and emt.exchange_id = pdd.exchange_id
       and dt.deal_type_id = dtm.deal_type_id
       and dt.profit_center_id = cpc.profit_center_id
       and dt.strike_price_unit_id = pum_drt_strike.price_unit_id(+)
       and pum_drt_strike.cur_id = cm_drt_strike.cur_id(+)
       and pum_drt_strike.weight_unit_id = qum_drt_strike.qty_unit_id(+)
       and akc.corporate_id = pc_corporate_id
       and dt.process_id = pc_process_id
       group by akc.corporate_id,
                akc.corporate_name,
                pd_trade_date,
                pc_process_id,
                satm.acc_type_id,
                satm.acc_type_name,
                --sa.acc_id,
                --sa.acc_no,
                dsa.acc_qty_unit_id,
                dt.trade_date,
                emt.exchange_id,
                emt.exchange_name,
                drm.period_month,
                drm.period_year,
                drm.prompt_date,
                irm.instrument_type_id,
                irm.instrument_type,
                dim.instrument_id,
                dim.instrument_name,
                dt.deal_type_id,
                dtm.deal_type_id,
                dt.dr_id,
                pdd.derivative_def_id,
                pdd.derivative_def_name,
                dt.derivative_ref_no,
                dt.profit_center_id,
                cpc.profit_center_name,
                cpc.profit_center_short_name,
                drm.dr_id_name,
                dt.trade_type,
                dt.total_lots,
                pdd.lot_size,
                dt.strike_price,
                dt.strike_price_unit_id,
                cm_drt_strike.cur_id,
                cm_drt_strike.cur_code,
                pum_drt_strike.weight,
                pum_drt_strike.weight_unit_id,
                qum_drt_strike.qty_unit,
                dt.trade_price;
    --irm.parent_instrument_type;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_future_accounts',
                                                           'm2m-013',
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
  end;*/

  procedure sp_mark_realized_derivatives(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2) is
  
    vc_prev_proccess_id varchar2(15);
  
  begin
    begin
      select tdc.process_id
        into vc_prev_proccess_id
        from tdc_trade_date_closure tdc
       where tdc.corporate_id = pc_corporate_id
         and process = pc_process
         and tdc.trade_date =
             (select max(trade_date)
                from tdc_trade_date_closure
               where corporate_id = pc_corporate_id
                 and trade_date < pd_trade_date
                 and process = pc_process);
    end;
  
    update dt_derivative_trade dt
       set dt.is_realized_today = 'Y'
     where dt.process_id = pc_process_id
       and dt.corporate_id = pc_corporate_id
       and dt.status in ('Exercised', 'Expired')
       and exists (select *
              from dt_derivative_trade dt_prev
             where dt_prev.process_id = vc_prev_proccess_id
               and dt_prev.status = 'Verified'
               and dt_prev.internal_derivative_ref_no =
                   dt.internal_derivative_ref_no);
  
    update dt_derivative_trade dt
       set dt.is_realized_today = 'Y'
     where dt.process_id = pc_process_id
       and dt.corporate_id = pc_corporate_id
       and dt.status in ('Exercised', 'Expired')
       and not exists (select *
              from dt_derivative_trade dt_prev
             where dt_prev.process_id = vc_prev_proccess_id
               and dt_prev.internal_derivative_ref_no =
                   dt.internal_derivative_ref_no);
  end;

  procedure sp_mark_new_derivative_trades(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2,
                                          pc_process      varchar2) is
    /******************************************************************************************************************************************
    procedure name                            : sp_mark_new_derivative_trades
    author                                    : janna
    created date                              : 13th apr 2009
    purpose                                   : to mark the new trades created between last eod and current eod.
    parameters
    pc_corporate_id                           : corporate id
    pd_trade_date                             : eod date id
    pc_process_id                             : eod reference no
    modification history
    modified date                             :
    modified by                               :
    modify description                        :
    ******************************************************************************************************************************************/
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vc_prev_eod_refno  varchar2(20);
  begin
    --write_log(null,'inside sp_mark_new_derivative_trades begin');
    begin
      select t1.process_id
        into vc_prev_eod_refno
        from tdc_trade_date_closure t1
       where t1.corporate_id = pc_corporate_id
         and t1.process = pc_process
         and t1.trade_date =
             (select max(t2.trade_date)
                from tdc_trade_date_closure t2
               where t2.corporate_id = pc_corporate_id
                 and t2.trade_date < pd_trade_date
                 and t2.process = pc_process);
    end;
  
    insert into dpd_derivative_pnl_daily
      (internal_derivative_ref_no,
       derivative_ref_no,
       eod_trade_date,
       trade_date,
       corporate_id,
       corporate_name,
       trader_id,
       trader_name,
       profit_center_id,
       profit_center_name,
       profit_center_short_name,
       dr_id,
       instrument_id,
       instrument_name,
       instrument_symbol,
       instrument_type_id,
       instrument_type,
       instrument_type_name,
       instrument_sub_type_id,
       instrument_sub_type,
       derivative_def_id,
       derivative_def_name,
       derivative_traded_on,
       derivative_prodct_id,
       derivative_prodct_name,
       exchange_id,
       exchange_name,
       exchange_code,
       lot_size,
       lot_size_unit_id,
       lot_size_unit,
       price_point_id,
       price_point_name,
       period_type_id,
       period_type_name,
       period_type_display_name,
       period_month,
       period_year,
       period_date,
       prompt_date,
       dr_id_name,
       trade_type,
       deal_type_id,
       deal_type_name,
       deal_type_display_name,
       is_multiple_leg_involved,
       deal_category,
       deal_sub_category,
       strategy_id,
       strategy_name,
       strategy_desc,
       strategy_def_name,
       group_id,
       group_name,
       purpose_id,
       purpose_name,
       purpose_display_name,
       external_ref_no,
       cp_profile_id,
       cp_name,
       master_contract_id,
       broker_profile_id,
       broker_name,
       broker_account_id,
       broker_account_name,
       broker_account_type,
       broker_comm_type_id,
       broker_comm_amt,
       broker_comm_cur_id,
       broker_comm_cur_code,
       clearer_profile_id,
       clearer_name,
       clearer_account_id,
       clearer_account_name,
       clearer_account_type,
       clearer_comm_type_id,
       clearer_comm_amt,
       clearer_comm_cur_id,
       clearer_comm_cur_code,
       product_id,
       product_name,
       quality_id,
       quality_name,
       quantity_unit_id,
       quantity_unit,
       total_lots,
       total_quantity,
       open_lots,
       open_quantity,
       exercised_lots,
       exercised_quantity,
       expired_lots,
       expired_quantity,
       trade_price_type_id,
       trade_price,
       trade_price_unit_id,
       trade_price_cur_id,
       trade_price_cur_code,
       trade_price_weight,
       trade_price_weight_unit_id,
       trade_price_weight_unit,
       formula_id,
       formula_name,
       formula_display,
       index_instrument_id,
       index_instrument_name,
       strike_price,
       strike_price_unit_id,
       strike_price_cur_id,
       strike_price_cur_code,
       strike_price_weight,
       strike_price_weight_unit_id,
       strike_price_weight_unit,
       premium_discount,
       premium_discount_price_unit_id,
       pd_price_cur_id,
       pd_price_cur_code,
       pd_price_weight,
       pd_price_weight_unit_id,
       pd_price_weight_unit,
       premium_due_date,
       nominee_profile_id,
       nominee_name,
       leg_no,
       option_expiry_date,
       parent_int_derivative_ref_no,
       market_location_country,
       market_location_state,
       market_location_city,
       is_what_if,
       payment_term_id,
       payment_term,
       payment_due_date,
       closed_lots,
       closed_quantity,
       is_new_trade,
       status,
       settlement_cur_id,
       settlement_cur_code,
       in_out_at_money_status,
       in_out_at_money_value,
       exercise_date,
       expiry_date,
       group_cur_id,
       group_cur_code,
       group_qty_unit_id,
       group_qty_unit,
       base_qty_unit_id,
       base_qty_unit,
       internal_close_out_ref_no,
       close_out_ref_no,
       close_out_date,
       settlement_price,
       sett_price_unit_id,
       sett_price_cur_id,
       sett_price_cur_code,
       sett_price_weight,
       sett_price_weight_unit_id,
       sett_price_weight_unit,
       parent_instrument_type,
       clearer_comm_in_base,
       broker_comm_in_base,
       clearer_exch_rate,
       broker_exch_rate,
       trade_cur_to_base_exch_rate,
       pnl_type,
       pnl_in_base_cur,
       pnl_in_trade_cur,
       base_cur_id,
       base_cur_code,
       underlying_future_dr_id,
       underlying_future_dr_id_name,
       underlying_future_expiry_date,
       underlying_future_quote_price,
       underlying_fut_price_unit_id,
       process_id,
       trade_qty_in_exch_unit,
       int_trade_parent_der_ref_no,
       is_internal_trade,
       available_price_id,
       average_from_date,
       average_to_date,
       swap_type_1,
       swap_trade_price_type_1,
       swap_float_type_1,
       swap_trade_price_1,
       swap_trade_price_unit_id_1,
       swap_trade_price_unit_1,
       swap_index_instrument_id_1,
       swap_formula_id_1,
       swap_type_2,
       swap_trade_price_type_2,
       swap_float_type_2,
       swap_trade_price_2,
       swap_trade_price_unit_id_2,
       swap_trade_price_unit_2,
       swap_index_instrument_id_2,
       swap_formula_id_2,
       swap_product1,
       swap_product_quality1,
       swap_product2,
       swap_product_quality2,
       pricing_invoicing_status,
       approval_status,
       trading_fee,
       clearing_fee,
       trading_clearing_fee,
       pnl_in_sett_cur)
      select dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             pd_trade_date eod_trade_date,
             dt.trade_date,
             dt.corporate_id,
             ak.corporate_name,
             dt.trader_id,
             gab.firstname || gab.lastname tradername,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dt.dr_id,
             drm.instrument_id,
             dim.instrument_name,
             dim.instrument_symbol,
             dim.instrument_type_id,
             irm.instrument_type,
             irm.instrument_display_name,
             dim.instrument_sub_type_id,
             istm.instrument_sub_type,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             pdd.traded_on,
             pdd.product_id,
             pdm.product_desc,
             emt.exchange_id,
             emt.exchange_name,
             emt.exchange_code,
             pdd.lot_size,
             pdd.lot_size_unit_id,
             qum.qty_unit lot_size_qty_unit,
             drm.price_point_id,
             pp.price_point_name,
             drm.period_type_id,
             pm.period_type_name,
             pm.period_type_display_name,
             drm.period_month,
             drm.period_year,
             (case
               when drm.period_date is null then
                case
               when drm.period_month is not null and
                    drm.period_year is not null then
                to_date('01-' || drm.period_month || '-' || drm.period_year,
                        'dd-Mon-yyyy')
               else
                drm.prompt_date
             end else drm.period_date end) period_date,
             drm.prompt_date,
             drm.dr_id_name,
             dt.trade_type,
             dt.deal_type_id,
             dtm.deal_type_name,
             dtm.deal_type_display_name,
             dtm.is_multiple_leg_involved,
             null deal_category,
             null deal_sub_category,
             dt.strategy_id,
             css.strategy_name,
             css.description,
             sdm.strategy_def_name,
             ak.groupid,
             gcd.groupname,
             dt.purpose_id,
             dpm.purpose_name,
             dpm.purpose_display_name,
             dt.external_ref_no,
             dt.cp_profile_id,
             phd_cp.companyname cp_name,
             dt.master_contract_id,
             dt.broker_profile_id,
             phd_broker.companyname broker_name,
             dt.broker_account_id,
             bca_broker.account_name broker_account_name,
             bca_broker.account_type broker_account_type,
             dt.broker_comm_type_id,
             dt.broker_comm_amt,
             dt.broker_comm_cur_id,
             cm_broker_cur.cur_code broker_cur_code,
             dt.clearer_profile_id,
             phd_clearer.companyname clearer_name,
             dt.clearer_account_id,
             bca_clearer.account_name clearer_account_name,
             bca_clearer.account_type clearer_account_type,
             dt.clearer_comm_type_id,
             dt.clearer_comm_amt,
             dt.clearer_comm_cur_id,
             cm_clearer.cur_code clearer_cur_code,
             dt.product_id product,
             pdm.product_desc productdesc,
             dt.quality_id,
             qat.quality_name,
             --   qat.gravity,
             --  gtm.gravity_type_name gravity_type,
             --  qat.density_mass_qty_unit_id,
             --  qat.density_volume_qty_unit_id,
             dt.quantity_unit_id,
             qum_um.qty_unit,
             dt.total_lots,
             dt.total_quantity,
             dt.total_lots open_lots,
             dt.total_quantity open_quantity,
             0 exercised_lots,
             0 exercised_quantity,
             0 expired_lots,
             0 expired_quantity,
             dt.trade_price_type_id,
             dt.trade_price,
             dt.trade_price_unit_id,
             pum_trade.cur_id trade_cur_id,
             cm_trade.cur_code trade_cur_code,
             pum_trade.weight trade_weight,
             pum_trade.weight_unit_id trade_weight_unit_id,
             qum_trade.qty_unit trade_qty_unit,
             dt.formula_id,
             fbs.formula_name,
             fbs.formula_display,
             dt.index_instrument_id,
             dim_index.instrument_name index_instrument_name,
             dt.strike_price,
             dt.strike_price_unit_id,
             pum_strike.cur_id strike_cur_id,
             cm_strike.cur_code strike_cur_code,
             pum_strike.weight strike_weight,
             pum_strike.weight_unit_id strike_weight_unit_id,
             qum_strike.qty_unit strike_qty_unit,
             dt.premium_discount,
             dt.premium_discount_price_unit_id,
             pum_pd.cur_id pd_cur_id,
             cm_pd.cur_code pd_cur_code,
             pum_pd.weight pd_weight,
             pum_pd.weight_unit_id pd_weight_unit_id,
             qum_pd.qty_unit pd_qty_unit,
             dt.premium_due_date,
             dt.nominee_profile_id,
             phd_nominee.companyname nominee_name,
             dt.leg_no,
             dt.option_expiry_date,
             dt.parent_int_derivative_ref_no,
             dt.market_location_country,
             dt.market_location_state,
             dt.market_location_city,
             dt.is_what_if,
             dt.payment_term,
             pym.payment_term payment_term_name,
             dt.payment_due_date,
             0 closed_lots,
             0 closed_quantity,
             'Y' is_new_trade,
             'Verified' status,
             dt.settlement_cur_id,
             cm_settlement.cur_code settlement_cur_code,
             null as in_out_at_money_status,
             null as in_out_at_money_value,
             drm.expiry_date exercise_date,
             drm.expiry_date expiry_date,
             gcd_group.group_cur_id,
             cm_gcd.cur_code group_cur_code,
             gcd_group.group_qty_unit_id,
             qum_gcd.qty_unit gcd_qty_unit,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             null internal_close_out_ref_no,
             null close_out_ref_no,
             null close_out_date,
             edq.price settlement_price,
             edq.price_unit_id settlement_price_unit_id,
             pum_settle.cur_id settlement_price_cur_id,
             cm_settle.cur_code settlemet_price_cur_code,
             pum_settle.weight settlement_price_weight,
             pum_settle.weight_unit_id settlement_weight_unit_id,
             qum_settle.qty_unit settlement_weight_unit,
             (case
               when irm.instrument_type in ('Option Put', 'Option Call') then
                'Option'
               else
                irm.instrument_type
             end) as parent_instrument_type,
             (case
               when nvl(dt.clearer_comm_amt, 0) <> 0 and
                    dt.clearer_comm_cur_id is not null then
                nvl(dt.clearer_comm_amt, 0) *
                pkg_cdc_derivatives_process.f_get_converted_currency_amt(dt.corporate_id,
                                                                         dt.clearer_comm_cur_id,
                                                                         cm_base.cur_id,
                                                                         dt.trade_date,
                                                                         1)
             
               else
                0
             end) clearer_comm_in_base,
             (case
               when nvl(dt.broker_comm_amt, 0) <> 0 and
                    dt.broker_comm_cur_id is not null then
                nvl(dt.broker_comm_amt, 0) *
                pkg_cdc_derivatives_process.f_get_converted_currency_amt(dt.corporate_id,
                                                                         dt.broker_comm_cur_id,
                                                                         cm_base.cur_id,
                                                                         dt.trade_date,
                                                                         1)
             
               else
                0
             end) broker_comm_in_base,
             null as clearer_exch_rate,
             null as broker_exch_rate,
             null as trade_cur_to_base_exch_rate,
             'New Trade' as pnl_type,
             0 pnl_in_base_cur,
             0 pnl_in_trade_cur,
             cm_base.cur_id as base_cur_id,
             ak.base_currency_name base_cur_code,
             null as underlying_future_dr_id,
             null as underlying_future_dr_id_name,
             null as underlying_future_expiry_date,
             null as underlying_future_quote_price,
             null as underlying_fut_price_unit_id,
             pc_process_id process_id,
             0 trade_qty_in_exch_unit,
             dt.int_trade_parent_der_ref_no,
             dt.is_internal_trade,
             dt.available_price_id,
             dt.average_from_date,
             dt.average_to_date,
             dt.swap_type_1,
             dt.swap_trade_price_type_1,
             dt.swap_float_type_1,
             dt.swap_trade_price_1,
             dt.swap_trade_price_unit_id_1,
             pum_swap.price_unit_name swap_trade_price_unit_1,
             dt.swap_index_instrument_id_1,
             dt.swap_formula_id_1,
             dt.swap_type_2,
             dt.swap_trade_price_type_2,
             dt.swap_float_type_2,
             dt.swap_trade_price_2,
             dt.swap_trade_price_unit_id_2,
             pum_swap1.price_unit_id swap_trade_price_unit_2,
             dt.swap_index_instrument_id_2,
             dt.swap_formula_id_2,
             dt.swap_product1,
             dt.swap_product_quality1,
             dt.swap_product2,
             dt.swap_product_quality2,
             dt.pricing_invoicing_status,
             dt.approval_status,
             dt.trading_fee,
             dt.clearing_fee,
             dt.trading_clearing_fee,
             0
        from dt_derivative_trade dt,
             ak_corporate ak,
             ak_corporate_user aku,
             gab_globaladdressbook gab,
             cpc_corporate_profit_center cpc,
             drm_derivative_master drm,
             dim_der_instrument_master dim,
             irm_instrument_type_master irm,
             istm_instr_sub_type_master istm,
             pdd_product_derivative_def pdd,
             pdm_productmaster pdm,
             emt_exchangemaster emt,
             qum_quantity_unit_master qum,
             pp_price_point pp,
             pm_period_master pm,
             dtm_deal_type_master dtm,
             css_corporate_strategy_setup css,
             sdm_strategy_definition_master sdm,
             gcd_groupcorporatedetails gcd,
             dpm_derivative_purpose_master dpm,
             phd_profileheaderdetails phd_cp,
             phd_profileheaderdetails phd_broker,
             bca_broker_clearer_account bca_broker,
             cm_currency_master cm_broker_cur,
             phd_profileheaderdetails phd_clearer,
             bca_broker_clearer_account bca_clearer,
             cm_currency_master cm_clearer,
             qat_quality_attributes qat,
             gtm_gravity_type_master gtm,
             qum_quantity_unit_master qum_um,
             pum_price_unit_master pum_trade,
             cm_currency_master cm_trade,
             qum_quantity_unit_master qum_trade,
             fbs_formula_builder_setup fbs,
             dim_der_instrument_master dim_index,
             pum_price_unit_master pum_strike,
             cm_currency_master cm_strike,
             qum_quantity_unit_master qum_strike,
             pum_price_unit_master pum_pd,
             cm_currency_master cm_pd,
             qum_quantity_unit_master qum_pd,
             phd_profileheaderdetails phd_nominee,
             pym_payment_terms_master pym,
             cm_currency_master cm_settlement,
             gcd_groupcorporatedetails gcd_group,
             cm_currency_master cm_gcd,
             qum_quantity_unit_master qum_gcd,
             qum_quantity_unit_master qum_pdm,
             (select edq.*
                from eodeom_derivative_quote_detail edq,
                     div_der_instrument_valuation   div,
                     apm_available_price_master     apm
               where edq.available_price_id = apm.available_price_id
                 and apm.is_active = 'Y'
                 and apm.is_deleted = 'N'
                 and edq.process_id = pc_process_id
                 and edq.instrument_id = div.instrument_id
                 and div.is_deleted = 'N'
                 and edq.available_price_id = div.available_price_id
                 and edq.price_unit_id = div.price_unit_id
              --and apm.available_price_name = 'Settlement'
              ) edq,
             pum_price_unit_master pum_settle,
             cm_currency_master cm_settle,
             qum_quantity_unit_master qum_settle,
             cm_currency_master cm_base,
             pum_price_unit_master pum_swap,
             pum_price_unit_master pum_swap1
       where dt.corporate_id = ak.corporate_id
         and dt.trader_id = aku.user_id
         and aku.gabid = gab.gabid
         and dt.profit_center_id = cpc.profit_center_id
         and dt.dr_id = drm.dr_id(+)
         and drm.instrument_id = dim.instrument_id(+)
         and dim.instrument_type_id = irm.instrument_type_id(+)
         and dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
         and dim.product_derivative_id = pdd.derivative_def_id(+)
         and pdd.product_id = pdm.product_id(+)
         and pdd.exchange_id = emt.exchange_id(+)
         and pdd.lot_size_unit_id = qum.qty_unit_id(+)
         and drm.price_point_id = pp.price_point_id(+)
         and drm.period_type_id = pm.period_type_id(+)
         and dt.deal_type_id = dtm.deal_type_id
         and dt.strategy_id = css.strategy_id
         and css.strategy_def_id = sdm.strategy_def_id
         and ak.groupid = gcd.groupid
         and dt.purpose_id = dpm.purpose_id
         and dt.cp_profile_id = phd_cp.profileid(+)
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.broker_account_id = bca_broker.account_id(+)
         and dt.broker_comm_cur_id = cm_broker_cur.cur_id(+)
         and dt.clearer_profile_id = phd_clearer.profileid(+)
         and dt.clearer_account_id = bca_clearer.account_id(+)
         and dt.clearer_comm_cur_id = cm_clearer.cur_id(+)
         and dt.quality_id = qat.quality_id(+)
         and qat.gravity_type_id = gtm.gravity_type_id(+)
         and dt.quantity_unit_id = qum_um.qty_unit_id
         and dt.trade_price_unit_id = pum_trade.price_unit_id(+)
         and pum_trade.cur_id = cm_trade.cur_id(+)
         and pum_trade.weight_unit_id = qum_trade.qty_unit_id(+)
         and dt.formula_id = fbs.formula_id(+)
         and dt.index_instrument_id = dim_index.instrument_id(+)
         and dt.strike_price_unit_id = pum_strike.price_unit_id(+)
         and pum_strike.cur_id = cm_strike.cur_id(+)
         and pum_strike.weight_unit_id = qum_strike.qty_unit_id(+)
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and pum_pd.cur_id = cm_pd.cur_id(+)
         and pum_pd.weight_unit_id = qum_pd.qty_unit_id(+)
         and dt.nominee_profile_id = phd_nominee.profileid(+)
         and dt.payment_term = pym.payment_term_id(+)
         and dt.settlement_cur_id = cm_settlement.cur_id(+)
         and ak.groupid=gcd_group.groupid
         and gcd_group.group_cur_id = cm_gcd.cur_id
         and gcd_group.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id(+)
         and dt.process_id = edq.process_id(+)
         and dt.dr_id = edq.dr_id(+)
         and edq.price_unit_id = pum_settle.price_unit_id(+)
         and pum_settle.cur_id = cm_settle.cur_id(+)
         and pum_settle.weight_unit_id = qum_settle.qty_unit_id(+)
         and ak.base_currency_name = cm_base.cur_code(+)
         and dt.swap_trade_price_unit_id_1 = pum_swap.price_unit_id(+)
         and dt.swap_trade_price_unit_id_2 = pum_swap1.price_unit_id(+)
         and pdd.traded_on = 'Exchange'
         and dt.is_what_if = 'N'
         and dt.corporate_id = pc_corporate_id
         and dt.trade_date <= pd_trade_date
            -- and dt.dbd_id = '219'
         and dt.process_id = pc_process_id
         and not exists (select *
                from dt_derivative_trade dt_prev
               where dt_prev.internal_derivative_ref_no =
                     dt.internal_derivative_ref_no
                 and dt_prev.process_id = vc_prev_eod_refno
                 and dt_prev.corporate_id = pc_corporate_id
              --and dt_prev.dbd_id = '193'
              );
    /*
    update dpd_derivative_pnl_daily dpd
       set dpd.is_new_trade = 'Y'
     where not exists (select dpd1.corporate_id,
                   dpd1.derivative_ref_no
              from dpd_derivative_pnl_daily dpd1
             where dpd1.corporate_id = pc_corporate_id
               and dpd1.process_id = vc_prev_eod_refno
               and dpd1.derivative_ref_no = dpd.derivative_ref_no)
       and dpd.corporate_id = pc_corporate_id
       and dpd.process_id = pc_process_id
       and rownum <=1;*/
    --write_log(null,'inside sp_mark_new_derivative_trades end');
    --added by siva on 09-Mar-2011, to be removed after the correct entry calculated
    -- in the package for broker/clearer amount calculation.
    update dpd_derivative_pnl_daily dpd
       set dpd.clearer_comm_in_base = 0, dpd.broker_comm_in_base = 0
     where dpd.process_id = pc_process_id
       and nvl(dpd.is_new_trade, 'NA') <> 'Y'
       and dpd.pnl_type = 'Unrealized';
  
    for cc in (select dpd.corporate_id,
                      dpd.process_id,
                      dpd.underlying_future_dr_id dr_id,
                      dq.price,
                      dq.price_unit_id
                 from dpd_derivative_pnl_daily       dpd,
                      eodeom_derivative_quote_detail dq,
                      div_der_instrument_valuation   div,
                      apm_available_price_master     apm
                where dpd.underlying_future_dr_id is not null
                  and dpd.corporate_id = pc_corporate_id
                  and dpd.process_id = pc_process_id
                  and dpd.corporate_id = dq.corporate_id
                  and dpd.process_id = dq.process_id
                  and dpd.underlying_future_dr_id = dq.dr_id
                  and dq.instrument_id = div.instrument_id
                  and div.is_deleted = 'N'
                  and dq.available_price_id = apm.available_price_id
                  and dq.available_price_id = div.available_price_id
                  and dq.price_unit_id = div.price_unit_id
                     --                  and apm.available_price_name = 'Settlement'
                  and dpd.instrument_type in ('Option Call', 'Option Call'))
    loop
      update dpd_derivative_pnl_daily dpd
         set dpd.underlying_future_quote_price = cc.price,
             dpd.underlying_fut_price_unit_id  = cc.price_unit_id
       where dpd.underlying_future_dr_id = cc.dr_id
         and dpd.corporate_id = pc_corporate_id
         and dpd.process_id = pc_process_id
         and dpd.instrument_type in ('Option Call', 'Option Call');
    
    end loop;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_future_unrealized_pnl',
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

  procedure sp_calc_undo_closeout(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process_id   varchar2,
                                  pc_user_id      varchar2,
                                  pc_process      varchar2) is
    v_dbd_id varchar2(15);
  begin
    select dbd.dbd_id
      into v_dbd_id
      from dbd_database_dump dbd
     where dbd.corporate_id = pc_corporate_id
       and dbd.trade_date = pd_trade_date
       and dbd.process = pc_process;
  
    insert into dpd_derivative_pnl_daily
      (internal_derivative_ref_no,
       derivative_ref_no,
       eod_trade_date,
       trade_date,
       corporate_id,
       corporate_name,
       trader_id,
       trader_name,
       profit_center_id,
       profit_center_name,
       profit_center_short_name,
       dr_id,
       instrument_id,
       instrument_name,
       instrument_symbol,
       instrument_type_id,
       instrument_type,
       instrument_type_name,
       instrument_sub_type_id,
       instrument_sub_type,
       derivative_def_id,
       derivative_def_name,
       derivative_traded_on,
       derivative_prodct_id,
       derivative_prodct_name,
       exchange_id,
       exchange_name,
       exchange_code,
       lot_size,
       lot_size_unit_id,
       lot_size_unit,
       price_point_id,
       price_point_name,
       period_type_id,
       period_type_name,
       period_type_display_name,
       period_month,
       period_year,
       period_date,
       prompt_date,
       dr_id_name,
       trade_type,
       deal_type_id,
       deal_type_name,
       deal_type_display_name,
       is_multiple_leg_involved,
       deal_category,
       deal_sub_category,
       strategy_id,
       strategy_name,
       strategy_desc,
       strategy_def_name,
       group_id,
       group_name,
       purpose_id,
       purpose_name,
       purpose_display_name,
       external_ref_no,
       cp_profile_id,
       cp_name,
       master_contract_id,
       broker_profile_id,
       broker_name,
       broker_account_id,
       broker_account_name,
       broker_account_type,
       broker_comm_type_id,
       broker_comm_amt,
       broker_comm_cur_id,
       broker_comm_cur_code,
       clearer_profile_id,
       clearer_name,
       clearer_account_id,
       clearer_account_name,
       clearer_account_type,
       clearer_comm_type_id,
       clearer_comm_amt,
       clearer_comm_cur_id,
       clearer_comm_cur_code,
       product_id,
       product_name,
       quality_id,
       quality_name,
       quantity_unit_id,
       quantity_unit,
       total_lots,
       total_quantity,
       open_lots,
       open_quantity,
       exercised_lots,
       exercised_quantity,
       expired_lots,
       expired_quantity,
       trade_price_type_id,
       trade_price,
       trade_price_unit_id,
       trade_price_cur_id,
       trade_price_cur_code,
       trade_price_weight,
       trade_price_weight_unit_id,
       trade_price_weight_unit,
       formula_id,
       formula_name,
       formula_display,
       index_instrument_id,
       index_instrument_name,
       strike_price,
       strike_price_unit_id,
       strike_price_cur_id,
       strike_price_cur_code,
       strike_price_weight,
       strike_price_weight_unit_id,
       strike_price_weight_unit,
       premium_discount,
       premium_discount_price_unit_id,
       pd_price_cur_id,
       pd_price_cur_code,
       pd_price_weight,
       pd_price_weight_unit_id,
       pd_price_weight_unit,
       premium_due_date,
       nominee_profile_id,
       nominee_name,
       leg_no,
       option_expiry_date,
       parent_int_derivative_ref_no,
       market_location_country,
       market_location_state,
       market_location_city,
       is_what_if,
       payment_term_id,
       payment_term,
       payment_due_date,
       closed_lots,
       closed_quantity,
       is_new_trade,
       status,
       settlement_cur_id,
       settlement_cur_code,
       in_out_at_money_status,
       in_out_at_money_value,
       exercise_date,
       expiry_date,
       group_cur_id,
       group_cur_code,
       group_qty_unit_id,
       group_qty_unit,
       base_qty_unit_id,
       base_qty_unit,
       internal_close_out_ref_no,
       close_out_ref_no,
       close_out_date,
       settlement_price,
       sett_price_unit_id,
       sett_price_cur_id,
       sett_price_cur_code,
       sett_price_weight,
       sett_price_weight_unit_id,
       sett_price_weight_unit,
       parent_instrument_type,
       clearer_comm_in_base,
       broker_comm_in_base,
       clearer_exch_rate,
       broker_exch_rate,
       trade_cur_to_base_exch_rate,
       pnl_type,
       pnl_in_base_cur,
       pnl_in_trade_cur,
       base_cur_id,
       base_cur_code,
       underlying_future_dr_id,
       underlying_future_dr_id_name,
       underlying_future_expiry_date,
       underlying_future_quote_price,
       underlying_fut_price_unit_id,
       process_id)
      select internal_derivative_ref_no,
             derivative_ref_no,
             pd_trade_date,
             dpd.trade_date,
             dpd.corporate_id,
             corporate_name,
             trader_id,
             trader_name,
             profit_center_id,
             profit_center_name,
             profit_center_short_name,
             dr_id,
             instrument_id,
             instrument_name,
             instrument_symbol,
             instrument_type_id,
             instrument_type,
             instrument_type_name,
             instrument_sub_type_id,
             instrument_sub_type,
             derivative_def_id,
             derivative_def_name,
             derivative_traded_on,
             derivative_prodct_id,
             derivative_prodct_name,
             exchange_id,
             exchange_name,
             exchange_code,
             lot_size,
             lot_size_unit_id,
             lot_size_unit,
             price_point_id,
             price_point_name,
             period_type_id,
             period_type_name,
             period_type_display_name,
             period_month,
             period_year,
             period_date,
             prompt_date,
             dr_id_name,
             trade_type,
             deal_type_id,
             deal_type_name,
             deal_type_display_name,
             is_multiple_leg_involved,
             deal_category,
             deal_sub_category,
             strategy_id,
             strategy_name,
             strategy_desc,
             strategy_def_name,
             group_id,
             group_name,
             purpose_id,
             purpose_name,
             purpose_display_name,
             external_ref_no,
             cp_profile_id,
             cp_name,
             master_contract_id,
             broker_profile_id,
             broker_name,
             broker_account_id,
             broker_account_name,
             broker_account_type,
             broker_comm_type_id,
             broker_comm_amt * -1,
             broker_comm_cur_id,
             broker_comm_cur_code,
             clearer_profile_id,
             clearer_name,
             clearer_account_id,
             clearer_account_name,
             clearer_account_type,
             clearer_comm_type_id,
             clearer_comm_amt * -1,
             clearer_comm_cur_id,
             clearer_comm_cur_code,
             product_id,
             product_name,
             quality_id,
             quality_name,
             quantity_unit_id,
             quantity_unit,
             total_lots,
             total_quantity,
             open_lots,
             open_quantity,
             exercised_lots,
             exercised_quantity,
             expired_lots,
             expired_quantity,
             trade_price_type_id,
             trade_price,
             trade_price_unit_id,
             trade_price_cur_id,
             trade_price_cur_code,
             trade_price_weight,
             trade_price_weight_unit_id,
             trade_price_weight_unit,
             formula_id,
             formula_name,
             formula_display,
             index_instrument_id,
             index_instrument_name,
             strike_price,
             strike_price_unit_id,
             strike_price_cur_id,
             strike_price_cur_code,
             strike_price_weight,
             strike_price_weight_unit_id,
             strike_price_weight_unit,
             premium_discount,
             premium_discount_price_unit_id,
             pd_price_cur_id,
             pd_price_cur_code,
             pd_price_weight,
             pd_price_weight_unit_id,
             pd_price_weight_unit,
             premium_due_date,
             nominee_profile_id,
             nominee_name,
             leg_no,
             option_expiry_date,
             parent_int_derivative_ref_no,
             market_location_country,
             market_location_state,
             market_location_city,
             is_what_if,
             payment_term_id,
             payment_term,
             payment_due_date,
             closed_lots,
             closed_quantity,
             is_new_trade,
             status,
             settlement_cur_id,
             settlement_cur_code,
             in_out_at_money_status,
             in_out_at_money_value,
             exercise_date,
             expiry_date,
             group_cur_id,
             group_cur_code,
             group_qty_unit_id,
             group_qty_unit,
             base_qty_unit_id,
             base_qty_unit,
             dpd.internal_close_out_ref_no,
             close_out_ref_no,
             close_out_date,
             settlement_price,
             sett_price_unit_id,
             sett_price_cur_id,
             sett_price_cur_code,
             sett_price_weight,
             sett_price_weight_unit_id,
             sett_price_weight_unit,
             parent_instrument_type,
             clearer_comm_in_base * -1,
             broker_comm_in_base * -1,
             clearer_exch_rate,
             broker_exch_rate,
             trade_cur_to_base_exch_rate,
             'Reverse Realized',
             pnl_in_base_cur * -1,
             pnl_in_trade_cur * -1,
             base_cur_id,
             base_cur_code,
             underlying_future_dr_id,
             underlying_future_dr_id_name,
             underlying_future_expiry_date,
             underlying_future_quote_price,
             underlying_fut_price_unit_id,
             pc_process_id
        from dpd_derivative_pnl_daily dpd,
             tdc_trade_date_closure tdc,
             (select dpd.internal_close_out_ref_no,
                     max(dpd.eod_trade_date) realized_date
                from dpd_derivative_pnl_daily dpd,
                     tdc_trade_date_closure   tdc
               where dpd.corporate_id = pc_corporate_id
                 and tdc.corporate_id = pc_corporate_id
                 and dpd.pnl_type = 'Realized'
                 and dpd.eod_trade_date < pd_trade_date
                 and dpd.eod_trade_date = tdc.trade_date
                 and tdc.process = pc_process
                 and exists
               (select 1
                        from dcoh_der_closeout_header dcoh
                       where dcoh.internal_close_out_ref_no =
                             dpd.internal_close_out_ref_no
                         and dcoh.is_rolled_back = 'Y'
                         and dcoh.undo_closeout_dbd_id = v_dbd_id
                         and dcoh.corporate_id = pc_corporate_id)
               group by dpd.internal_close_out_ref_no) max_eod
       where dpd.eod_trade_date = tdc.trade_date
         and tdc.trade_date = max_eod.realized_date
         and dpd.internal_close_out_ref_no =
             max_eod.internal_close_out_ref_no
         and tdc.corporate_id = pc_corporate_id
         and tdc.process = pc_process
         and tdc.process_id = dpd.process_id;
  end;

  procedure sp_calc_undo_settled(pc_corporate_id varchar2,
                                 pd_trade_date   date,
                                 pc_process_id   varchar2,
                                 pc_user_id      varchar2,
                                 pc_process      varchar2) is
  
  begin
  
    insert into dpd_derivative_pnl_daily
      (internal_derivative_ref_no,
       derivative_ref_no,
       eod_trade_date,
       trade_date,
       corporate_id,
       corporate_name,
       trader_id,
       trader_name,
       profit_center_id,
       profit_center_name,
       profit_center_short_name,
       dr_id,
       instrument_id,
       instrument_name,
       instrument_symbol,
       instrument_type_id,
       instrument_type,
       instrument_type_name,
       instrument_sub_type_id,
       instrument_sub_type,
       derivative_def_id,
       derivative_def_name,
       derivative_traded_on,
       derivative_prodct_id,
       derivative_prodct_name,
       exchange_id,
       exchange_name,
       exchange_code,
       lot_size,
       lot_size_unit_id,
       lot_size_unit,
       price_point_id,
       price_point_name,
       period_type_id,
       period_type_name,
       period_type_display_name,
       period_month,
       period_year,
       period_date,
       prompt_date,
       dr_id_name,
       trade_type,
       deal_type_id,
       deal_type_name,
       deal_type_display_name,
       is_multiple_leg_involved,
       deal_category,
       deal_sub_category,
       strategy_id,
       strategy_name,
       strategy_desc,
       strategy_def_name,
       group_id,
       group_name,
       purpose_id,
       purpose_name,
       purpose_display_name,
       external_ref_no,
       cp_profile_id,
       cp_name,
       master_contract_id,
       broker_profile_id,
       broker_name,
       broker_account_id,
       broker_account_name,
       broker_account_type,
       broker_comm_type_id,
       broker_comm_amt,
       broker_comm_cur_id,
       broker_comm_cur_code,
       clearer_profile_id,
       clearer_name,
       clearer_account_id,
       clearer_account_name,
       clearer_account_type,
       clearer_comm_type_id,
       clearer_comm_amt,
       clearer_comm_cur_id,
       clearer_comm_cur_code,
       product_id,
       product_name,
       quality_id,
       quality_name,
       quantity_unit_id,
       quantity_unit,
       total_lots,
       total_quantity,
       open_lots,
       open_quantity,
       exercised_lots,
       exercised_quantity,
       expired_lots,
       expired_quantity,
       trade_price_type_id,
       trade_price,
       trade_price_unit_id,
       trade_price_cur_id,
       trade_price_cur_code,
       trade_price_weight,
       trade_price_weight_unit_id,
       trade_price_weight_unit,
       formula_id,
       formula_name,
       formula_display,
       index_instrument_id,
       index_instrument_name,
       strike_price,
       strike_price_unit_id,
       strike_price_cur_id,
       strike_price_cur_code,
       strike_price_weight,
       strike_price_weight_unit_id,
       strike_price_weight_unit,
       premium_discount,
       premium_discount_price_unit_id,
       pd_price_cur_id,
       pd_price_cur_code,
       pd_price_weight,
       pd_price_weight_unit_id,
       pd_price_weight_unit,
       premium_due_date,
       nominee_profile_id,
       nominee_name,
       leg_no,
       option_expiry_date,
       parent_int_derivative_ref_no,
       market_location_country,
       market_location_state,
       market_location_city,
       is_what_if,
       payment_term_id,
       payment_term,
       payment_due_date,
       closed_lots,
       closed_quantity,
       is_new_trade,
       status,
       settlement_cur_id,
       settlement_cur_code,
       in_out_at_money_status,
       in_out_at_money_value,
       exercise_date,
       expiry_date,
       group_cur_id,
       group_cur_code,
       group_qty_unit_id,
       group_qty_unit,
       base_qty_unit_id,
       base_qty_unit,
       settlement_price,
       sett_price_unit_id,
       sett_price_cur_id,
       sett_price_cur_code,
       sett_price_weight,
       sett_price_weight_unit_id,
       sett_price_weight_unit,
       parent_instrument_type,
       clearer_comm_in_base,
       broker_comm_in_base,
       clearer_exch_rate,
       broker_exch_rate,
       trade_cur_to_base_exch_rate,
       pnl_type,
       pnl_in_base_cur,
       pnl_in_trade_cur,
       base_cur_id,
       base_cur_code,
       underlying_future_dr_id,
       underlying_future_dr_id_name,
       underlying_future_expiry_date,
       underlying_future_quote_price,
       underlying_fut_price_unit_id,
       process_id,
       trade_qty_in_exch_unit,
       settlement_ref_no)
      select dpd. internal_derivative_ref_no,
             derivative_ref_no,
             pd_trade_date,
             dpd.trade_date,
             dpd.corporate_id,
             corporate_name,
             trader_id,
             trader_name,
             profit_center_id,
             profit_center_name,
             profit_center_short_name,
             dr_id,
             instrument_id,
             instrument_name,
             instrument_symbol,
             instrument_type_id,
             instrument_type,
             instrument_type_name,
             instrument_sub_type_id,
             instrument_sub_type,
             derivative_def_id,
             derivative_def_name,
             derivative_traded_on,
             derivative_prodct_id,
             derivative_prodct_name,
             exchange_id,
             exchange_name,
             exchange_code,
             lot_size,
             lot_size_unit_id,
             lot_size_unit,
             price_point_id,
             price_point_name,
             period_type_id,
             period_type_name,
             period_type_display_name,
             period_month,
             period_year,
             period_date,
             prompt_date,
             dr_id_name,
             trade_type,
             deal_type_id,
             deal_type_name,
             deal_type_display_name,
             is_multiple_leg_involved,
             deal_category,
             deal_sub_category,
             strategy_id,
             strategy_name,
             strategy_desc,
             strategy_def_name,
             group_id,
             group_name,
             purpose_id,
             purpose_name,
             purpose_display_name,
             external_ref_no,
             cp_profile_id,
             cp_name,
             master_contract_id,
             broker_profile_id,
             broker_name,
             broker_account_id,
             broker_account_name,
             broker_account_type,
             broker_comm_type_id,
             broker_comm_amt * -1,
             broker_comm_cur_id,
             broker_comm_cur_code,
             clearer_profile_id,
             clearer_name,
             clearer_account_id,
             clearer_account_name,
             clearer_account_type,
             clearer_comm_type_id,
             clearer_comm_amt * -1,
             clearer_comm_cur_id,
             clearer_comm_cur_code,
             product_id,
             product_id,
             quality_id,
             quality_name,
             quantity_unit_id,
             quantity_unit,
             total_lots,
             total_quantity,
             open_lots,
             open_quantity,
             exercised_lots,
             exercised_quantity,
             expired_lots,
             expired_quantity,
             trade_price_type_id,
             trade_price,
             trade_price_unit_id,
             trade_price_cur_id,
             trade_price_cur_code,
             trade_price_weight,
             trade_price_weight_unit_id,
             trade_price_weight_unit,
             formula_id,
             formula_name,
             formula_display,
             index_instrument_id,
             index_instrument_name,
             strike_price,
             strike_price_unit_id,
             strike_price_cur_id,
             strike_price_cur_code,
             strike_price_weight,
             strike_price_weight_unit_id,
             strike_price_weight_unit,
             premium_discount,
             premium_discount_price_unit_id,
             pd_price_cur_id,
             pd_price_cur_code,
             pd_price_weight,
             pd_price_weight_unit_id,
             pd_price_weight_unit,
             premium_due_date,
             nominee_profile_id,
             nominee_name,
             leg_no,
             option_expiry_date,
             parent_int_derivative_ref_no,
             market_location_country,
             market_location_state,
             market_location_city,
             is_what_if,
             payment_term,
             payment_term,
             payment_due_date,
             closed_lots,
             closed_quantity,
             is_new_trade,
             status,
             settlement_cur_id,
             settlement_cur_code,
             in_out_at_money_status,
             in_out_at_money_value,
             exercise_date,
             expiry_date,
             group_cur_id,
             group_cur_code,
             group_qty_unit_id,
             group_qty_unit,
             base_qty_unit_id,
             base_qty_unit,
             settlement_price,
             sett_price_unit_id,
             sett_price_cur_id,
             sett_price_cur_code,
             sett_price_weight,
             sett_price_weight_unit_id,
             sett_price_weight_unit,
             parent_instrument_type,
             clearer_comm_in_base * -1,
             broker_comm_in_base * -1,
             clearer_exch_rate,
             broker_exch_rate,
             trade_cur_to_base_exch_rate,
             'Reverse Realized',
             pnl_in_base_cur * -1,
             pnl_in_trade_cur * -1,
             base_cur_id,
             base_cur_code,
             underlying_future_dr_id,
             underlying_future_dr_id_name,
             underlying_future_expiry_date,
             underlying_future_quote_price,
             underlying_fut_price_unit_id,
             pc_process_id,
             trade_qty_in_exch_unit,
             dpd.settlement_ref_no
        from dpd_derivative_pnl_daily dpd,
             tdc_trade_date_closure tdc,
             (select dpd.settlement_ref_no,
                     max(dpd.eod_trade_date) realized_date
                from dpd_derivative_pnl_daily dpd,
                     tdc_trade_date_closure   tdc
               where dpd.corporate_id = pc_corporate_id
                 and tdc.corporate_id = pc_corporate_id
                 and dpd.pnl_type = 'Realized'
                 and dpd.eod_trade_date < pd_trade_date
                 and dpd.eod_trade_date = tdc.trade_date
                 and tdc.process = pc_process
               group by dpd.settlement_ref_no) max_eod
       where dpd.settlement_ref_no in
             (select fsh.settlement_ref_no
                from fsh_fin_settlement_header fsh
               where fsh.is_settled = 'N'
                 and fsh.undo_settlement_dbd_id =
                     (select dbd_id
                        from dbd_database_dump dbd
                       where dbd.corporate_id = pc_corporate_id
                         and dbd.trade_date = pd_trade_date
                         and dbd.process = pc_process))
         and dpd.eod_trade_date = tdc.trade_date
         and tdc.trade_date = max_eod.realized_date
         and dpd.settlement_ref_no = max_eod.settlement_ref_no
         and tdc.corporate_id = pc_corporate_id
         and tdc.process = pc_process
         and tdc.process_id = dpd.process_id;
  end;

  procedure sp_calc_clearer_summary(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_process_id   varchar2,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2) is
    vc_previous_process_id varchar2(15);
    vobj_error_log         tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count     number := 1;
  begin
    --
    -- Select Previous EOD or EOM Process ID
    --
    select tdc.process_id
      into vc_previous_process_id
      from tdc_trade_date_closure tdc
     where tdc.corporate_id = pc_corporate_id
       and process = pc_process
       and tdc.trade_date = (select max(trade_date)
                               from tdc_trade_date_closure
                              where corporate_id = pc_corporate_id
                                and trade_date < pd_trade_date
                                and process = pc_process);
  
    --
    -- Futures Section
    --
    insert into spc_summary_position_clearer
      (group_id,
       group_name,
       group_cur_id,
       group_cur_code,
       group_qty_unit_id,
       group_qty_unit,
       corporate_id,
       corporate_name,
       base_cur_id,
       base_cur_code,
       process_id,
       process,
       process_date,
       product_id,
       product_name,
       base_qty_unit_id,
       base_qty_unit,
       instrument_id,
       instrument_name,
       derivative_def_id,
       derivative_def_name,
       instrument_type_id,
       instrument_type_name,
       exchange_id,
       exchange_name,
       dr_id,
       period_date,
       lot_size,
       lot_size_weight_unit_id,
       clearer_profile_id,
       clearer_name,
       order_type_id,
       order_type_name,
       trade_type_id,
       trade_type_name,
       trade_cur_id,
       trade_cur_code,
       initial_position_in_lots,
       buy_lots,
       sell_lots,
       closed_lots,
       unrealized_pnl_in_base_cur,
       unrealized_pnl_in_trade_cur,
       realized_pnl_in_base_cur,
       realized_pnl_in_trade_cur,
       net_open_lots,
       net_open_qty,
       buy_qty,
       sell_qty,
       closed_qty,
       initial_position_in_qty,
       cancelled_buy_lots,
       cancelled_buy_qty,
       cancelled_sell_lots,
       cancelled_sell_qty,
       close_diff_in_base_cur,
       close_diff_in_trade_cur)
      select group_id,
             group_name,
             group_cur_id,
             group_cur_code,
             group_qty_unit_id,
             group_qty_unit,
             corporate_id,
             corporate_name,
             base_cur_id,
             base_cur_code,
             pc_process_id process_id,
             process,
             trade_date,
             product_id,
             product_desc,
             base_qty_unit_id,
             base_qty_unit,
             instrument_id,
             instrument_name,
             derivative_def_id,
             derivative_def_name,
             instrument_type_id,
             instrument_type,
             exchange_id,
             exchange_name,
             dr_id,
             period_date,
             lot_size,
             lot_size_unit_id,
             clearer_profile_id,
             clearer_name,
             deal_type_id,
             deal_type_name,
             trade_type_id,
             trade_type_name,
             trade_cur_id,
             trade_cur_code,
             sum(nvl(initial_position_lots, 0)),
             sum(nvl(buy_lots, 0)),
             sum(nvl(sell_lots, 0)),
             sum(nvl(closed_lots, 0)),
             sum(nvl(unrealized_pnl_in_base_cur, 0)),
             sum(nvl(unrealized_pnl_in_trade_cur, 0)),
             sum(nvl(realized_pnl_in_base_cur, 0)),
             sum(nvl(realized_pnl_in_trade_cur, 0)),
             sum(nvl(net_open_lots, 0)) as net_open_lots,
             sum(nvl(net_open_qty, 0)) as net_open_qty,
             sum(nvl(buy_qty, 0)),
             sum(nvl(sell_qty, 0)),
             sum(nvl(closed_qty, 0)),
             sum(nvl(initial_position_qty, 0)),
             sum(nvl(cancelled_buy_lots, 0)) cancelled_buy_lots,
             sum(nvl(cancelled_buy_qty, 0)) cancelled_buy_qty,
             sum(nvl(cancelled_sell_lots, 0)) cancelled_sell_lots,
             sum(nvl(cancelled_sell_qty, 0)) cancelled_sell_qty,
             sum(nvl(close_diff_in_base_cur, 0)) close_diff_in_base_cur,
             sum(nvl(close_diff_in_trade_cur, 0)) close_diff_in_trade_cur
        from (
              -- Initial Position
              select dpd_prev.group_id,
                      dpd_prev.group_name,
                      dpd_prev.group_cur_id,
                      dpd_prev.group_cur_code,
                      dpd_prev.group_qty_unit_id,
                      dpd_prev.group_qty_unit,
                      dpd_prev.corporate_id,
                      dpd_prev.corporate_name,
                      dpd_prev.base_cur_id,
                      dpd_prev.base_cur_code,
                      pc_process_id process_id,
                      pc_process process,
                      pd_trade_date trade_date,
                      pdd.product_id,
                      pdm.product_desc product_desc,
                      dpd_prev.base_qty_unit_id,
                      dpd_prev.base_qty_unit,
                      dpd_prev.instrument_id,
                      dpd_prev.instrument_name,
                      dpd_prev.derivative_def_id,
                      dpd_prev.derivative_def_name,
                      dpd_prev.instrument_type_id,
                      dpd_prev.instrument_type,
                      dpd_prev.exchange_id,
                      dpd_prev.exchange_name,
                      dpd_prev.dr_id,
                      dpd_prev.period_date,
                      dpd_prev.lot_size,
                      pdd.lot_size_unit_id,
                      dpd_prev.clearer_profile_id,
                      phd.companyname clearer_name,
                      dpd_prev.deal_type_id,
                      dpd_prev.deal_type_name,
                      dpd_prev.instrument_type_id trade_type_id,
                      dpd_prev.instrument_name trade_type_name,
                      nvl(dpd_prev.trade_price_cur_id, dpd_prev.base_cur_id) trade_cur_id,
                      nvl(dpd_prev.trade_price_cur_code,
                          dpd_prev.broker_comm_cur_code) trade_cur_code,
                      sum(decode(dpd_prev.trade_type,
                                 'Buy',
                                 dpd_prev.total_lots,
                                 0) - decode(dpd_prev.trade_type,
                                             'Sell',
                                             dpd_prev.total_lots,
                                             0)) initial_position_lots,
                      -- trade_qty To TRADE_QTY_IN_EXCH_UNIT
                      sum(decode(dpd_prev.trade_type,
                                 'Buy',
                                 dpd_prev.trade_qty_in_exch_unit,
                                 0) - decode(dpd_prev.trade_type,
                                             'Sell',
                                             dpd_prev.trade_qty_in_exch_unit,
                                             0)) initial_position_qty,
                      0 buy_lots,
                      0 sell_lots,
                      0 closed_lots,
                      0 unrealized_pnl_in_base_cur,
                      0 unrealized_pnl_in_trade_cur,
                      0 realized_pnl_in_base_cur,
                      0 realized_pnl_in_trade_cur,
                      0 net_open_lots,
                      0 net_open_qty,
                      0 buy_qty,
                      0 sell_qty,
                      0 closed_qty,
                      0 cancelled_buy_lots,
                      0 cancelled_buy_qty,
                      0 cancelled_sell_lots,
                      0 cancelled_sell_qty,
                      0 close_diff_in_base_cur,
                      0 close_diff_in_trade_cur
                from dpd_derivative_pnl_daily   dpd_prev,
                      pdd_product_derivative_def pdd,
                      phd_profileheaderdetails   phd,
                      pdm_productmaster          pdm
               where dpd_prev.process_id = vc_previous_process_id --Previous EOD/EOM ID
                 and dpd_prev.corporate_id = pc_corporate_id
                 and dpd_prev.derivative_def_id = pdd.derivative_def_id
                 and pdd.product_id = pdm.product_id
                 and dpd_prev.clearer_profile_id = phd.profileid
                 and dpd_prev.clearer_profile_id is not null
                 and dpd_prev.instrument_type in ('Future', 'Forward')
                    --AND dpd_prev.deal_type_id <> 'Internal Swap'
                 and dpd_prev.pnl_type = 'Unrealized'
               group by dpd_prev.group_id,
                         dpd_prev.group_name,
                         dpd_prev.group_cur_id,
                         dpd_prev.group_cur_code,
                         dpd_prev.group_qty_unit_id,
                         dpd_prev.group_qty_unit,
                         dpd_prev.corporate_id,
                         dpd_prev.corporate_name,
                         dpd_prev.base_cur_id,
                         dpd_prev.base_cur_code,
                         pdd.product_id,
                         pdm.product_desc,
                         dpd_prev.base_qty_unit_id,
                         dpd_prev.base_qty_unit,
                         dpd_prev.instrument_id,
                         dpd_prev.instrument_name,
                         dpd_prev.derivative_def_id,
                         dpd_prev.derivative_def_name,
                         dpd_prev.instrument_type_id,
                         dpd_prev.instrument_type,
                         dpd_prev.exchange_id,
                         dpd_prev.exchange_name,
                         dpd_prev.dr_id,
                         dpd_prev.period_date,
                         dpd_prev.period_month,
                         dpd_prev.period_year,
                         dpd_prev.lot_size,
                         pdd.lot_size_unit_id,
                         dpd_prev.clearer_profile_id,
                         phd.companyname,
                         dpd_prev.deal_type_id,
                         dpd_prev.deal_type_name,
                         dpd_prev.instrument_type_id,
                         dpd_prev.instrument_name,
                         nvl(dpd_prev.trade_price_cur_id, dpd_prev.base_cur_id),
                         nvl(dpd_prev.trade_price_cur_code,
                             dpd_prev.broker_comm_cur_code)
              union all
              -- New Trades in this EOD/EOM
              select gcd.groupid group_id,
                     gcd.groupname group_name,
                     cm_gcd.cur_id group_cur_id,
                     cm_gcd.cur_code group_cur_code,
                     qum_gcd.qty_unit_id group_qty_unit_id,
                     qum_gcd.qty_unit group_qty_unit,
                     drt.corporate_id,
                     akc.corporate_name,
                     cm_akc.cur_id base_cur_id,
                     cm_akc.cur_code base_cur_code,
                     pc_process_id,
                     pc_process,
                     pd_trade_date,
                     pdd.product_id,
                     pdm.product_desc product_desc,
                     pdm.base_quantity_unit base_qty_unit_id,
                     qum_pdm.qty_unit base_qty_unit,
                     dim.instrument_id,
                     dim.instrument_name,
                     pdd.derivative_def_id,
                     pdd.derivative_def_name,
                     dim.instrument_type_id,
                     irm.instrument_type,
                     pdd.exchange_id,
                     emt.exchange_name,
                     drt.dr_id,
                     (case
                       when drm.period_date is null then
                        case
                       when drm.period_month is not null and
                            drm.period_year is not null then
                        to_date('01-' || drm.period_month || '-' ||
                                drm.period_year,
                                'dd-Mon-yyyy')
                       else
                        drm.prompt_date
                     end else drm.period_date end) period_date,
                     pdd.lot_size,
                     pdd.lot_size_unit_id,
                     drt.clearer_profile_id,
                     phd_drt.companyname clearer_name,
                     drt.deal_type_id order_type_id,
                     drt.deal_type_id order_type,
                     dim.instrument_type_id trade_type_id,
                     dim.instrument_name trade_type_name,
                     nvl(vcur.main_currency_id, cm_akc.cur_id) trade_cur_id,
                     nvl(vcur.main_cur_code, cm_akc.cur_code) trade_cur_code,
                     0 initial_position_lots,
                     0 initial_position_qty,
                     nvl(sum(decode(drt.trade_type, 'Buy', drt.total_lots, 0)),
                         0) buy_lots,
                     nvl(sum(decode(drt.trade_type, 'Sell', drt.total_lots, 0)),
                         0) sell_lots,
                     0 closed_lots,
                     0 unrealized_pnl_in_base_cur,
                     0 unrealized_pnl_in_trade_cur,
                     0 realized_pnl_in_base_cur,
                     0 realized_pnl_in_trade_cur,
                     0 net_open_lots,
                     0 net_open_qty,
                     nvl(sum(decode(drt.trade_type,
                                    'Buy',
                                    drt.total_quantity *
                                    pkg_general.f_get_converted_quantity(null,
                                                                         drt.quantity_unit_id,
                                                                         pdd.lot_size_unit_id,
                                                                         1),
                                    0)),
                         0) buy_qty,
                     nvl(sum(decode(drt.trade_type,
                                    'Sell',
                                    drt.total_quantity *
                                    pkg_general.f_get_converted_quantity(null,
                                                                         drt.quantity_unit_id,
                                                                         pdd.lot_size_unit_id,
                                                                         1),
                                    0)),
                         0) sell_qty,
                     0 closed_qty,
                     0 cancelled_buy_lots,
                     0 cancelled_buy_qty,
                     0 cancelled_sell_lots,
                     0 cancelled_sell_qty,
                     0 close_diff_in_base_cur,
                     0 close_diff_in_trade_cur
                from dt_derivative_trade        drt,
                     ak_corporate               akc,
                     gcd_groupcorporatedetails  gcd,
                     qum_quantity_unit_master   qum_gcd,
                     cm_currency_master         cm_gcd,
                     cm_currency_master         cm_akc,
                     drm_derivative_master      drm,
                     dim_der_instrument_master  dim,
                     pdd_product_derivative_def pdd,
                     pdm_productmaster          pdm,
                     qum_quantity_unit_master   qum_pdm,
                     irm_instrument_type_master irm,
                     emt_exchangemaster         emt,
                     phd_profileheaderdetails   phd_drt,
                     pum_price_unit_master      pum,
                     v_main_currency_details    vcur
               where drt.process_id = pc_process_id
                 and akc.corporate_id = drt.corporate_id
                 and akc.groupid = gcd.groupid
                 and gcd.group_cur_id = cm_gcd.cur_id
                 and gcd.group_qty_unit_id = qum_gcd.qty_unit_id
                 and akc.base_currency_name = cm_akc.cur_code
                 and drt.dr_id = drm.dr_id
                 and drm.instrument_id = dim.instrument_id
                 and dim.product_derivative_id = pdd.derivative_def_id
                 and pdd.product_id = pdm.product_id
                 and qum_pdm.qty_unit_id = pdm.base_quantity_unit
                 and irm.instrument_type_id = dim.instrument_type_id
                 and irm.instrument_type in ('Future', 'Forward')
                    --AND drt.is_new_trade = 'Y'
                    --AND drt.deal_type_id <> 'Internal Swap'
                 and pdd.exchange_id = emt.exchange_id
                 and phd_drt.profileid = drt.clearer_profile_id
                 and drt.clearer_profile_id is not null
                 and drt.trade_price_unit_id = pum.price_unit_id
                 and pum.cur_id = vcur.main_sub_cur_id
                 and not exists
               (select dt_pre.internal_derivative_ref_no
                        from dt_derivative_trade dt_pre
                       where dt_pre.internal_derivative_ref_no =
                             drt.internal_derivative_ref_no
                         and dt_pre.process_id = vc_previous_process_id)
               group by gcd.groupid,
                        gcd.groupname,
                        cm_gcd.cur_id,
                        cm_gcd.cur_code,
                        qum_gcd.qty_unit_id,
                        qum_gcd.qty_unit,
                        drt.corporate_id,
                        akc.corporate_name,
                        cm_akc.cur_id,
                        cm_akc.cur_code,
                        pc_process_id,
                        pc_process,
                        pd_trade_date,
                        pdd.product_id,
                        pdm.product_desc,
                        pdm.base_quantity_unit,
                        qum_pdm.qty_unit,
                        dim.instrument_id,
                        dim.instrument_name,
                        pdd.derivative_def_id,
                        pdd.derivative_def_name,
                        dim.instrument_type_id,
                        irm.instrument_type,
                        pdd.exchange_id,
                        emt.exchange_name,
                        drt.dr_id,
                        drm.period_month,
                        drm.period_year,
                        (case
                          when drm.period_date is null then
                           case
                          when drm.period_month is not null and
                               drm.period_year is not null then
                           to_date('01-' || drm.period_month || '-' ||
                                   drm.period_year,
                                   'dd-Mon-yyyy')
                          else
                           drm.prompt_date
                        end else drm.period_date end),
                        pdd.lot_size,
                        pdd.lot_size_unit_id,
                        drt.clearer_profile_id,
                        phd_drt.companyname,
                        drt.deal_type_id,
                        drt.deal_type_id,
                        dim.instrument_type_id,
                        dim.instrument_name,
                        nvl(vcur.main_currency_id, cm_akc.cur_id),
                        nvl(vcur.main_cur_code, cm_akc.cur_code)
              union all
              -- Closed Position
              select dpd.group_id,
                     dpd.group_name,
                     dpd.group_cur_id,
                     dpd.group_cur_code,
                     dpd.group_qty_unit_id,
                     dpd.group_qty_unit,
                     dpd.corporate_id,
                     dpd.corporate_name,
                     dpd.base_cur_id,
                     dpd.base_cur_code,
                     pc_process_id,
                     pc_process,
                     pd_trade_date,
                     pdd.product_id,
                     pdm.product_desc product_desc,
                     dpd.base_qty_unit_id,
                     dpd.base_qty_unit,
                     dpd.instrument_id,
                     dpd.instrument_name,
                     dpd.derivative_def_id,
                     dpd.derivative_def_name,
                     dpd.instrument_type_id,
                     dpd.instrument_type,
                     dpd.exchange_id,
                     dpd.exchange_name,
                     dpd.dr_id,
                     dpd.period_date,
                     dpd.lot_size,
                     pdd.lot_size_unit_id,
                     dpd.clearer_profile_id,
                     dpd.clearer_name,
                     dpd.deal_type_id,
                     dpd.deal_type_name,
                     dpd.instrument_type_id trade_type_id,
                     dpd.instrument_name trade_type_name,
                     nvl(dpd.trade_price_cur_id, dpd.base_cur_id) trade_cur_id,
                     nvl(dpd.trade_price_cur_code, dpd.base_cur_code) trade_cur_code,
                     0 initial_position_lots,
                     0 initial_position_qty,
                     0 buy_lots,
                     0 sell_lots,
                     nvl(sum(decode(dpd.trade_type, 'Buy', dpd.total_lots, 0)),
                         0) closed_lots,
                     0 unrealized_pnl_in_base_cur,
                     0 unrealized_pnl_in_trade_cur,
                     sum(dpd.pnl_in_base_cur) realized_pnl_in_base_cur,
                     sum(dpd.pnl_in_trade_cur) realized_pnl_in_trade_cur,
                     0 net_open_lots,
                     0 net_open_qty,
                     0 buy_qty,
                     0 sell_qty,
                     nvl(sum(decode(dpd.trade_type,
                                    'Buy',
                                    nvl(dpd.total_quantity, 0),
                                    0) *
                             pkg_general.f_get_converted_quantity(null,
                                                                  dpd.quantity_unit_id,
                                                                  dpd.lot_size_unit_id,
                                                                  1)),
                         0) closed_qty,
                     0 cancelled_buy_lots,
                     0 cancelled_buy_qty,
                     0 cancelled_sell_lots,
                     0 cancelled_sell_qty,
                     0 close_diff_in_base_cur,
                     0 close_diff_in_trade_cur
                from dpd_derivative_pnl_daily   dpd,
                     pdd_product_derivative_def pdd,
                     pdm_productmaster          pdm
               where dpd.process_id = pc_process_id
                 and dpd.corporate_id = pc_corporate_id
                 and dpd.derivative_def_id = pdd.derivative_def_id
                 and pdd.product_id = pdm.product_id
                 and dpd.instrument_type in ('Future', 'Forward')
                 and dpd.clearer_profile_id is not null
                 and dpd.close_out_ref_no is not null --by siddharth
                    --AND dpd.deal_type_id <> 'Internal Swap'
                 and dpd.pnl_type = 'Realized'
              --  AND dpd.status = 'Closed'
               group by dpd.group_id,
                        dpd.group_name,
                        dpd.group_cur_id,
                        dpd.group_cur_code,
                        dpd.group_qty_unit_id,
                        dpd.group_qty_unit,
                        dpd.corporate_id,
                        dpd.corporate_name,
                        dpd.base_cur_id,
                        dpd.base_cur_code,
                        pdd.product_id,
                        pdm.product_desc,
                        dpd.base_qty_unit_id,
                        dpd.base_qty_unit,
                        dpd.instrument_id,
                        dpd.instrument_name,
                        dpd.derivative_def_id,
                        dpd.derivative_def_name,
                        dpd.instrument_type_id,
                        dpd.instrument_type,
                        dpd.exchange_id,
                        dpd.exchange_name,
                        dpd.dr_id,
                        dpd.period_month,
                        dpd.period_year,
                        dpd.period_date,
                        dpd.lot_size,
                        pdd.lot_size_unit_id,
                        dpd.clearer_profile_id,
                        dpd.clearer_name,
                        dpd.deal_type_id,
                        dpd.deal_type_name,
                        dpd.instrument_type_id,
                        dpd.instrument_name,
                        nvl(dpd.trade_price_cur_id, dpd.base_cur_id),
                        nvl(dpd.trade_price_cur_code, dpd.base_cur_code)
              union all
              ---added by siddharth 19-jan-2011
              -- Closed Position by Settlement
              select dpd.group_id,
                     dpd.group_name,
                     dpd.group_cur_id,
                     dpd.group_cur_code,
                     dpd.group_qty_unit_id,
                     dpd.group_qty_unit,
                     dpd.corporate_id,
                     dpd.corporate_name,
                     dpd.base_cur_id,
                     dpd.base_cur_code,
                     pc_process_id,
                     pc_process,
                     pd_trade_date,
                     pdd.product_id,
                     pdm.product_desc product_desc,
                     dpd.base_qty_unit_id,
                     dpd.base_qty_unit,
                     dpd.instrument_id,
                     dpd.instrument_name,
                     dpd.derivative_def_id,
                     dpd.derivative_def_name,
                     dpd.instrument_type_id,
                     dpd.instrument_type,
                     dpd.exchange_id,
                     dpd.exchange_name,
                     dpd.dr_id,
                     dpd.period_date,
                     dpd.lot_size,
                     pdd.lot_size_unit_id,
                     dpd.clearer_profile_id,
                     dpd.clearer_name,
                     dpd.deal_type_id,
                     dpd.deal_type_name,
                     dpd.instrument_type_id trade_type_id,
                     dpd.instrument_name trade_type_name,
                     nvl(dpd.trade_price_cur_id, dpd.base_cur_id) trade_cur_id,
                     nvl(dpd.trade_price_cur_code, dpd.base_cur_code) trade_cur_code,
                     0 initial_position_lots,
                     0 initial_position_qty,
                     0 buy_lots,
                     0 sell_lots,
                     nvl(sum(dpd.total_lots), 0) closed_lots,
                     0 unrealized_pnl_in_base_cur,
                     0 unrealized_pnl_in_trade_cur,
                     sum(dpd.pnl_in_base_cur) realized_pnl_in_base_cur,
                     sum(dpd.pnl_in_trade_cur) realized_pnl_in_trade_cur,
                     0 net_open_lots,
                     0 net_open_qty,
                     0 buy_qty,
                     0 sell_qty,
                     --Issue 48001
                     nvl(sum(nvl(dpd.total_quantity, 0) *
                             pkg_general.f_get_converted_quantity(null,
                                                                  dpd.quantity_unit_id,
                                                                  dpd.lot_size_unit_id,
                                                                  1)),
                         0) closed_qty,
                     0 cancelled_buy_lots,
                     0 cancelled_buy_qty,
                     0 cancelled_sell_lots,
                     0 cancelled_sell_qty,
                     0 close_diff_in_base_cur,
                     0 close_diff_in_trade_cur
                from dpd_derivative_pnl_daily   dpd,
                     pdd_product_derivative_def pdd,
                     pdm_productmaster          pdm
               where dpd.process_id = pc_process_id
                 and dpd.corporate_id = pc_corporate_id
                 and dpd.derivative_def_id = pdd.derivative_def_id
                 and pdd.product_id = pdm.product_id
                 and dpd.instrument_type in ('Future', 'Forward')
                 and dpd.clearer_profile_id is not null
                    --AND    dpd.deal_type_id = 'External Swap'
                 and dpd.close_out_ref_no is null
                 and dpd.pnl_type = 'Realized'
              --  AND    dpd.status = 'Closed'
               group by dpd.group_id,
                        dpd.group_name,
                        dpd.group_cur_id,
                        dpd.group_cur_code,
                        dpd.group_qty_unit_id,
                        dpd.group_qty_unit,
                        dpd.corporate_id,
                        dpd.corporate_name,
                        dpd.base_cur_id,
                        dpd.base_cur_code,
                        pdd.product_id,
                        pdm.product_desc,
                        dpd.base_qty_unit_id,
                        dpd.base_qty_unit,
                        dpd.instrument_id,
                        dpd.instrument_name,
                        dpd.derivative_def_id,
                        dpd.derivative_def_name,
                        dpd.instrument_type_id,
                        dpd.instrument_type,
                        dpd.exchange_id,
                        dpd.exchange_name,
                        dpd.dr_id,
                        dpd.period_month,
                        dpd.period_year,
                        dpd.period_date,
                        dpd.lot_size,
                        pdd.lot_size_unit_id,
                        dpd.clearer_profile_id,
                        dpd.clearer_name,
                        dpd.deal_type_id,
                        dpd.deal_type_name,
                        dpd.instrument_type_id,
                        dpd.instrument_name,
                        nvl(dpd.trade_price_cur_id, dpd.base_cur_id),
                        nvl(dpd.trade_price_cur_code, dpd.base_cur_code)
              --ends here
              union all
              -- Open Position
              select dpd.group_id,
                     dpd.group_name,
                     dpd.group_cur_id,
                     dpd.group_cur_code,
                     dpd.group_qty_unit_id,
                     dpd.group_qty_unit,
                     dpd.corporate_id,
                     dpd.corporate_name,
                     dpd.base_cur_id,
                     dpd.base_cur_code,
                     pc_process_id,
                     pc_process,
                     pd_trade_date,
                     pdd.product_id,
                     pdm.product_desc product_desc,
                     dpd.base_qty_unit_id,
                     dpd.base_qty_unit,
                     dpd.instrument_id,
                     dpd.instrument_name,
                     dpd.derivative_def_id,
                     dpd.derivative_def_name,
                     dpd.instrument_type_id,
                     dpd.instrument_type,
                     dpd.exchange_id,
                     dpd.exchange_name,
                     dpd.dr_id,
                     dpd.period_date,
                     dpd.lot_size,
                     pdd.lot_size_unit_id,
                     dpd.clearer_profile_id,
                     dpd.clearer_name,
                     dpd.deal_type_id,
                     dpd.deal_type_name,
                     dpd.instrument_type_id trade_type_id,
                     dpd.instrument_name trade_type_name,
                     nvl(dpd.trade_price_cur_id, dpd.base_cur_id) trade_cur_id,
                     nvl(dpd.trade_price_cur_code, dpd.base_cur_code) trade_cur_code,
                     0 initial_position_lots,
                     0 initial_position_qty,
                     0 buy_lots,
                     0 sell_lots,
                     0 closed_lots,
                     sum(dpd.pnl_in_base_cur) unrealized_pnl_in_base_cur,
                     sum(dpd.pnl_in_trade_cur) unrealized_pnl_in_trade_cur,
                     0 realized_pnl_in_base_cur,
                     0 realized_pnl_in_trade_cur,
                     sum(decode(dpd.trade_type, 'Sell', -1, 1) *
                         dpd.total_lots) net_open_lots,
                     sum(decode(dpd.trade_type, 'Sell', -1, 1) *
                         dpd.trade_qty_in_exch_unit) net_open_qty,
                     0 buy_qty,
                     0 sell_qty,
                     0 closed_qty,
                     0 cancelled_buy_lots,
                     0 cancelled_buy_qty,
                     0 cancelled_sell_lots,
                     0 cancelled_sell_qty,
                     0 close_diff_in_base_cur,
                     0 close_diff_in_trade_cur
                from dpd_derivative_pnl_daily   dpd,
                     pdd_product_derivative_def pdd,
                     pdm_productmaster          pdm
               where dpd.process_id = pc_process_id
                 and dpd.corporate_id = pc_corporate_id
                 and dpd.derivative_def_id = pdd.derivative_def_id
                 and pdd.product_id = pdm.product_id
                 and dpd.instrument_type in ('Future', 'Forward')
                 and dpd.clearer_profile_id is not null
                    --AND dpd.deal_type_id <> 'Internal Swap'
                 and dpd.pnl_type = 'Unrealized'
              --  AND dpd.status = 'Open'
               group by dpd.group_id,
                        dpd.group_name,
                        dpd.group_cur_id,
                        dpd.group_cur_code,
                        dpd.group_qty_unit_id,
                        dpd.group_qty_unit,
                        dpd.corporate_id,
                        dpd.corporate_name,
                        dpd.base_cur_id,
                        dpd.base_cur_code,
                        pdd.product_id,
                        pdm.product_desc,
                        dpd.base_qty_unit_id,
                        dpd.base_qty_unit,
                        dpd.instrument_id,
                        dpd.instrument_name,
                        dpd.derivative_def_id,
                        dpd.derivative_def_name,
                        dpd.instrument_type_id,
                        dpd.instrument_type,
                        dpd.exchange_id,
                        dpd.exchange_name,
                        dpd.dr_id,
                        dpd.period_month,
                        dpd.period_year,
                        dpd.period_date,
                        dpd.lot_size,
                        pdd.lot_size_unit_id,
                        dpd.clearer_profile_id,
                        dpd.clearer_name,
                        dpd.deal_type_id,
                        dpd.deal_type_name,
                        dpd.instrument_type_id,
                        dpd.instrument_name,
                        nvl(dpd.trade_price_cur_id, dpd.base_cur_id),
                        nvl(dpd.trade_price_cur_code, dpd.base_cur_code))
       group by group_id,
                group_name,
                group_cur_id,
                group_cur_code,
                group_qty_unit_id,
                group_qty_unit,
                corporate_id,
                corporate_name,
                base_cur_id,
                base_cur_code,
                process_id,
                process,
                trade_date,
                product_id,
                product_desc,
                base_qty_unit_id,
                base_qty_unit,
                instrument_id,
                instrument_name,
                derivative_def_id,
                derivative_def_name,
                instrument_type_id,
                instrument_type,
                exchange_id,
                exchange_name,
                dr_id,
                period_date,
                lot_size,
                lot_size_unit_id,
                clearer_profile_id,
                clearer_name,
                deal_type_id,
                deal_type_name,
                trade_type_id,
                trade_type_name,
                trade_cur_id,
                trade_cur_code
      union all
      -- Cancelled Trades in this EOD/EOM
      select gcd.groupid group_id,
             gcd.groupname group_name,
             cm_gcd.cur_id group_cur_id,
             cm_gcd.cur_code group_cur_code,
             qum_gcd.qty_unit_id group_qty_unit_id,
             qum_gcd.qty_unit group_qty_unit,
             drt.corporate_id,
             akc.corporate_name,
             cm_akc.cur_id base_cur_id,
             cm_akc.cur_code base_cur_code,
             pc_process_id,
             pc_process,
             pd_trade_date,
             pdd.product_id,
             pdm.product_desc product_desc,
             pdm.base_quantity_unit base_qty_unit_id,
             qum_pdm.qty_unit base_qty_unit,
             dim.instrument_id,
             dim.instrument_name,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             dim.instrument_type_id,
             irm.instrument_type,
             pdd.exchange_id,
             emt.exchange_name,
             drt.dr_id,
             (case
               when drm.period_date is null then
                case
               when drm.period_month is not null and
                    drm.period_year is not null then
                to_date('01-' || drm.period_month || '-' || drm.period_year,
                        'dd-Mon-yyyy')
               else
                drm.prompt_date
             end else drm.period_date end) period_date,
             pdd.lot_size,
             pdd.lot_size_unit_id,
             drt.clearer_profile_id,
             phd_drt.companyname clearer_name,
             drt.deal_type_id order_type_id,
             drt.deal_type_id order_type,
             dim.instrument_type_id trade_type_id,
             dim.instrument_name trade_type_name,
             nvl(vcur.main_currency_id, cm_akc.cur_id) trade_cur_id,
             nvl(vcur.main_cur_code, cm_akc.cur_code) trade_cur_code,
             0 initial_position_lots,
             0 initial_position_qty,
             0 buy_lots,
             0 sell_lots,
             0 closed_lots,
             0 unrealized_pnl_in_base_cur,
             0 unrealized_pnl_in_trade_cur,
             0 realized_pnl_in_base_cur,
             0 realized_pnl_in_trade_cur,
             0 net_open_lots,
             0 net_open_qty,
             0 buy_qty,
             0 sell_qty,
             0 closed_qty,
             nvl(sum(decode(drt.trade_type, 'Buy', drt.open_lots, 0)), 0) cancelled_buy_lots,
             nvl(sum(decode(drt.trade_type,
                            'Buy',
                            drt.open_quantity *
                            pkg_general.f_get_converted_quantity(null,
                                                                 drt.quantity_unit_id,
                                                                 pdd.lot_size_unit_id,
                                                                 1),
                            0)),
                 0) cancelled_buy_qty,
             nvl(sum(decode(drt.trade_type, 'Sell', drt.open_lots, 0)), 0) cancelled_sell_lots,
             nvl(sum(decode(drt.trade_type,
                            'Sell',
                            drt.open_quantity *
                            pkg_general.f_get_converted_quantity(null,
                                                                 drt.quantity_unit_id,
                                                                 pdd.lot_size_unit_id,
                                                                 1),
                            0)),
                 0) cancelled_sell_qty,
             0 close_diff_in_base_cur,
             0 close_diff_in_trade_cur
        from dt_derivative_trade        drt,
             ak_corporate               akc,
             gcd_groupcorporatedetails  gcd,
             qum_quantity_unit_master   qum_gcd,
             cm_currency_master         cm_gcd,
             cm_currency_master         cm_akc,
             drm_derivative_master      drm,
             dim_der_instrument_master  dim,
             pdd_product_derivative_def pdd,
             pdm_productmaster          pdm,
             qum_quantity_unit_master   qum_pdm,
             irm_instrument_type_master irm,
             emt_exchangemaster         emt,
             phd_profileheaderdetails   phd_drt,
             pum_price_unit_master      pum,
             v_main_currency_details    vcur
       where drt.process_id = vc_previous_process_id
         and akc.corporate_id = drt.corporate_id
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm_gcd.cur_id
         and gcd.group_qty_unit_id = qum_gcd.qty_unit_id
         and akc.base_currency_name = cm_akc.cur_code
         and drt.dr_id = drm.dr_id
         and drm.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.product_id = pdm.product_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id(+)
         and irm.instrument_type_id = dim.instrument_type_id
         and irm.instrument_type in ('Future', 'Forward')
         and not exists
       (select dt.internal_derivative_ref_no
                from dt_derivative_trade dt
               where dt.internal_derivative_ref_no =
                     drt.internal_derivative_ref_no
                 and dt.process_id = pc_process_id)
         and drt.clearer_profile_id is not null
            --AND drt.is_deleted_today = 'Y'
            --AND drt.deal_type_id <> 'Internal Swap'
         and pdd.exchange_id = emt.exchange_id
         and drt.clearer_profile_id = phd_drt.profileid
         and drt.trade_price_unit_id = pum.price_unit_id(+)
         and pum.cur_id = vcur.main_sub_cur_id(+)
       group by gcd.groupid,
                gcd.groupname,
                cm_gcd.cur_id,
                cm_gcd.cur_code,
                qum_gcd.qty_unit_id,
                qum_gcd.qty_unit,
                drt.corporate_id,
                akc.corporate_name,
                cm_akc.cur_id,
                cm_akc.cur_code,
                pc_process_id,
                pc_process,
                pd_trade_date,
                pdd.product_id,
                pdm.product_desc,
                pdm.base_quantity_unit,
                qum_pdm.qty_unit,
                dim.instrument_id,
                dim.instrument_name,
                pdd.derivative_def_id,
                pdd.derivative_def_name,
                dim.instrument_type_id,
                irm.instrument_type,
                pdd.exchange_id,
                emt.exchange_name,
                drt.dr_id,
                drm.period_month,
                drm.period_year,
                (case
                  when drm.period_date is null then
                   case
                  when drm.period_month is not null and
                       drm.period_year is not null then
                   to_date('01-' || drm.period_month || '-' ||
                           drm.period_year,
                           'dd-Mon-yyyy')
                  else
                   drm.prompt_date
                end else drm.period_date end),
                pdd.lot_size,
                pdd.lot_size_unit_id,
                drt.clearer_profile_id,
                phd_drt.companyname,
                drt.deal_type_id,
                drt.deal_type_id,
                dim.instrument_type_id,
                dim.instrument_name,
                nvl(vcur.main_currency_id, cm_akc.cur_id),
                nvl(vcur.main_cur_code, cm_akc.cur_code);
  
    --Ends here
    --
    -- Options Section
    --
    insert into spc_summary_position_clearer
      (group_id,
       group_name,
       group_cur_id,
       group_cur_code,
       group_qty_unit_id,
       group_qty_unit,
       corporate_id,
       corporate_name,
       base_cur_id,
       base_cur_code,
       process_id,
       process,
       process_date,
       product_id,
       product_name,
       base_qty_unit_id,
       base_qty_unit,
       instrument_id,
       instrument_name,
       derivative_def_id,
       derivative_def_name,
       instrument_type_id,
       instrument_type_name,
       exchange_id,
       exchange_name,
       dr_id,
       period_date,
       lot_size,
       lot_size_weight_unit_id,
       clearer_profile_id,
       clearer_name,
       order_type_id,
       order_type_name,
       trade_type_id,
       trade_type_name,
       trade_cur_id,
       trade_cur_code,
       initial_position_in_lots,
       buy_lots,
       sell_lots,
       buy_qty,
       sell_qty,
       closed_lots,
       unrealized_pnl_in_base_cur,
       unrealized_pnl_in_trade_cur,
       realized_pnl_in_base_cur,
       realized_pnl_in_trade_cur,
       net_open_lots,
       net_open_qty,
       buy_exercised_expired_lots,
       sell_exercised_expired_lots,
       buy_exercised_expired_qty,
       sell_exercised_expired_qty,
       buy_premium_month,
       sell_premium_month,
       strike_price,
       strike_price_unit_id,
       strike_price_cur_id,
       strike_price_cur_code,
       strike_price_cur_weight,
       strike_price_cur_wt_unit_id,
       strike_price_cur_weight_unit,
       closed_qty,
       initial_position_in_qty,
       cancelled_buy_lots,
       cancelled_buy_qty,
       cancelled_sell_lots,
       cancelled_sell_qty,
       close_diff_in_base_cur,
       close_diff_in_trade_cur)
      select group_id,
             group_name,
             group_cur_id,
             group_cur_code,
             group_qty_unit_id,
             group_qty_unit,
             corporate_id,
             corporate_name,
             base_cur_id,
             base_cur_code,
             process_id,
             process,
             trade_date,
             product_id,
             product_desc,
             base_qty_unit_id,
             base_qty_unit,
             instrument_id,
             instrument_name,
             derivative_def_id,
             derivative_def_name,
             instrument_type_id,
             instrument_type_name,
             exchange_id,
             exchange_name,
             dr_id,
             period_date,
             lot_size,
             lot_size_unit_id,
             clearer_profile_id,
             clearer_name,
             deal_type_id,
             deal_type_name,
             trade_type_id,
             trade_type_name,
             trade_price_cur_id,
             trade_price_cur_code,
             sum(nvl(initial_position_lots, 0)),
             sum(nvl(buy_lots, 0)),
             sum(nvl(sell_lots, 0)),
             sum(nvl(buy_qty, 0)),
             sum(nvl(sell_qty, 0)),
             sum(nvl(lots_closed, 0)),
             sum(nvl(unrealized_pnl_in_base_cur, 0)),
             sum(nvl(unrealized_pnl_in_trade_cur, 0)),
             sum(nvl(realized_pnl_in_base_cur, 0)),
             sum(nvl(realized_pnl_in_trade_cur, 0)),
             sum(nvl(net_open_lots, 0)) net_open_lots,
             sum(nvl(net_open_qty, 0)) net_open_qty,
             sum(nvl(buy_exercised_expired_lots, 0)),
             sum(nvl(sell_exercised_expired_lots, 0)),
             sum(nvl(buy_exercised_expired_qty, 0)),
             sum(nvl(sell_exercised_expired_qty, 0)),
             sum(nvl(buy_premium_month, 0)),
             sum(nvl(sell_premium_month, 0)),
             strike_price,
             strike_price_unit_id,
             strike_price_cur_id,
             strike_price_cur_code,
             nvl(strike_price_weight, 1),
             strike_price_weight_unit_id,
             strike_price_weight_unit,
             sum(nvl(closed_qty, 0)),
             sum(nvl(initial_position_qty, 0)),
             sum(nvl(cancelled_buy_lots, 0)) cancelled_buy_lots,
             sum(nvl(cancelled_buy_qty, 0)) cancelled_buy_qty,
             sum(nvl(cancelled_sell_lots, 0)) cancelled_sell_lots,
             sum(nvl(cancelled_sell_qty, 0)) cancelled_sell_qty,
             sum(nvl(close_diff_in_base_cur, 0)) close_diff_in_base_cur,
             sum(nvl(close_diff_in_trade_cur, 0)) close_diff_in_trade_cur
        from (
              --Initial Position for Options
              select dpd.group_id,
                      dpd.group_name,
                      dpd.group_cur_id,
                      dpd.group_cur_code,
                      dpd.group_qty_unit_id,
                      dpd.group_qty_unit,
                      dpd.corporate_id,
                      dpd.corporate_name,
                      dpd.base_cur_id,
                      base_cur_code,
                      pc_process_id process_id,
                      pc_process process,
                      pd_trade_date trade_date,
                      pdd.product_id,
                      product_desc,
                      dpd.base_qty_unit_id,
                      dpd.base_qty_unit,
                      dpd.instrument_id,
                      dpd.instrument_name,
                      dpd.derivative_def_id,
                      dpd.derivative_def_name,
                      dpd.instrument_type_id,
                      irm.instrument_type instrument_type_name,
                      dpd.exchange_id,
                      dpd.exchange_name,
                      dpd.dr_id,
                      dpd.period_date,
                      dpd.lot_size,
                      pdd.lot_size_unit_id lot_size_unit_id,
                      dpd.clearer_profile_id,
                      phd.companyname clearer_name,
                      dpd.deal_type_id,
                      dpd.deal_type_name,
                      dpd.instrument_type_id trade_type_id,
                      dpd.instrument_name trade_type_name,
                      nvl(dpd.trade_price_cur_id, dpd.base_cur_id) trade_price_cur_id,
                      nvl(dpd.trade_price_cur_code, dpd.base_cur_code) trade_price_cur_code,
                      sum(decode(dpd.trade_type, 'Buy', dpd.total_lots, 0) -
                          decode(dpd.trade_type, 'Sell', dpd.total_lots, 0)) initial_position_lots,
                      sum(decode(dpd.trade_type,
                                 'Buy',
                                 dpd.trade_qty_in_exch_unit,
                                 0) - decode(dpd.trade_type,
                                             'Sell',
                                             dpd.trade_qty_in_exch_unit,
                                             0)) initial_position_qty,
                      0 buy_lots,
                      0 sell_lots,
                      0 buy_qty,
                      0 sell_qty,
                      0 lots_closed,
                      0 unrealized_pnl_in_base_cur,
                      0 unrealized_pnl_in_trade_cur,
                      0 realized_pnl_in_base_cur,
                      0 realized_pnl_in_trade_cur,
                      0 net_open_lots,
                      0 net_open_qty,
                      0 buy_exercised_expired_lots,
                      0 sell_exercised_expired_lots,
                      0 buy_exercised_expired_qty,
                      0 sell_exercised_expired_qty,
                      0 buy_premium_month,
                      0 sell_premium_month,
                      dpd.strike_price,
                      dpd.strike_price_unit_id,
                      dpd.strike_price_cur_id,
                      dpd.strike_price_cur_code,
                      dpd.strike_price_weight,
                      dpd.strike_price_weight_unit_id,
                      dpd.strike_price_weight_unit,
                      0 closed_qty,
                      0 cancelled_buy_lots,
                      0 cancelled_buy_qty,
                      0 cancelled_sell_lots,
                      0 cancelled_sell_qty,
                      0 close_diff_in_base_cur,
                      0 close_diff_in_trade_cur
                from dpd_derivative_pnl_daily   dpd,
                      pdd_product_derivative_def pdd,
                      pdm_productmaster          pdm,
                      irm_instrument_type_master irm,
                      phd_profileheaderdetails   phd
               where dpd.derivative_def_id = pdd.derivative_def_id
                 and pdm.product_id = pdd.product_id
                 and dpd.instrument_type_id = irm.instrument_type_id
                 and dpd.instrument_type in ('Option Put', 'Option Call')
                    -- AND dpd.deal_type_id <> 'Internal Swap'
                 and dpd.pnl_type = 'Unrealized'
                 and dpd.clearer_profile_id = phd.profileid
                 and dpd.process_id = vc_previous_process_id
               group by dpd.group_id,
                         dpd.group_name,
                         group_cur_id,
                         group_cur_code,
                         group_qty_unit_id,
                         group_qty_unit,
                         dpd.corporate_id,
                         corporate_name,
                         dpd.base_cur_id,
                         base_cur_code,
                         process_id,
                         pc_process,
                         pd_trade_date,
                         pdd.product_id,
                         product_desc,
                         dpd.base_qty_unit_id,
                         dpd.base_qty_unit,
                         dpd.instrument_id,
                         dpd.instrument_name,
                         dpd.derivative_def_id,
                         dpd.derivative_def_name,
                         dpd.instrument_type_id,
                         irm.instrument_type,
                         dpd.exchange_id,
                         dpd.exchange_name,
                         dpd.dr_id,
                         dpd.period_date,
                         dpd.period_month,
                         dpd.period_year,
                         dpd.lot_size,
                         pdd.lot_size_unit_id,
                         dpd.clearer_profile_id,
                         phd.companyname,
                         dpd.deal_type_id,
                         dpd.deal_type_name,
                         dpd.instrument_type_id,
                         irm.instrument_type,
                         nvl(dpd.trade_price_cur_id, dpd.base_cur_id),
                         nvl(dpd.trade_price_cur_code, dpd.base_cur_code),
                         dpd.strike_price,
                         dpd.strike_price_unit_id,
                         dpd.strike_price_cur_id,
                         dpd.strike_price_cur_code,
                         dpd.strike_price_weight,
                         dpd.strike_price_weight_unit_id,
                         dpd.strike_price_weight_unit
              -- New Trades in this EOD/EOM
              union all
              select gcd.groupid group_id,
                     gcd.groupname group_name,
                     cm_gcd.cur_id group_cur_id,
                     cm_gcd.cur_code group_cur_code,
                     qum_gcd.qty_unit_id group_qty_unit_id,
                     qum_gcd.qty_unit group_qty_unit,
                     drt.corporate_id,
                     akc.corporate_name,
                     cm_akc.cur_id base_cur_id,
                     cm_akc.cur_code base_cur_code,
                     pc_process_id,
                     pc_process,
                     pd_trade_date,
                     pdd.product_id,
                     pdm.product_desc product_desc,
                     pdm.base_quantity_unit base_qty_unit_id,
                     qum_pdm.qty_unit base_qty_unit,
                     dim.instrument_id,
                     dim.instrument_name,
                     pdd.derivative_def_id,
                     pdd.derivative_def_name,
                     dim.instrument_type_id,
                     irm.instrument_type,
                     pdd.exchange_id,
                     emt.exchange_name,
                     drt.dr_id,
                     (case
                       when drm.period_date is null then
                        case
                       when drm.period_month is not null and
                            drm.period_year is not null then
                        to_date('01-' || drm.period_month || '-' ||
                                drm.period_year,
                                'dd-Mon-yyyy')
                       else
                        drm.prompt_date
                     end else drm.period_date end) period_date,
                     pdd.lot_size,
                     pdd.lot_size_unit_id,
                     drt.clearer_profile_id,
                     phd_drt.companyname clearer_name,
                     drt.deal_type_id order_type_id,
                     drt.deal_type_id order_type,
                     dim.instrument_type_id trade_type_id,
                     dim.instrument_name trade_type_name,
                     nvl(vcur.main_currency_id, cm_akc.cur_id) trade_cur_id,
                     nvl(vcur.main_cur_code, cm_akc.cur_code) trade_cur_code,
                     0 initial_position_lots,
                     0 initial_position_qty,
                     nvl(sum(decode(drt.trade_type, 'Buy', drt.total_lots, 0)),
                         0) buy_lots,
                     nvl(sum(decode(drt.trade_type, 'Sell', drt.total_lots, 0)),
                         0) sell_lots,
                     nvl(sum(decode(drt.trade_type,
                                    'Buy',
                                    pkg_general.f_get_converted_quantity(null,
                                                                         drt.quantity_unit_id,
                                                                         pdd.lot_size_unit_id,
                                                                         drt.total_quantity),
                                    0)),
                         0) buy_qty,
                     nvl(sum(decode(drt.trade_type,
                                    'Sell',
                                    pkg_general.f_get_converted_quantity(null,
                                                                         drt.quantity_unit_id,
                                                                         pdd.lot_size_unit_id,
                                                                         drt.total_quantity),
                                    0)),
                         0) sell_qty,
                     0 lots_closed,
                     0 unrealized_pnl_in_base_cur,
                     0 unrealized_pnl_in_trade_cur,
                     0 realized_pnl_in_base_cur,
                     0 realized_pnl_in_trade_cur,
                     0 net_open_lots,
                     0 net_open_qty,
                     0 buy_exercised_expired_lots,
                     0 sell_exercised_expired_lots,
                     0 buy_exercised_expired_qty,
                     0 sell_exercised_expired_qty,
                     0 buy_premium_month,
                     0 sell_premium_month,
                     drt.strike_price,
                     drt.strike_price_unit_id,
                     cm_sp.cur_id,
                     cm_sp.cur_code,
                     pum_sp.weight,
                     qum_sp.qty_unit_id,
                     qum_sp.qty_unit,
                     0 closed_qty,
                     0 cancelled_buy_lots,
                     0 cancelled_buy_qty,
                     0 cancelled_sell_lots,
                     0 cancelled_sell_qty,
                     0 close_diff_in_base_cur,
                     0 close_diff_in_trade_cur
                from dt_derivative_trade        drt,
                     ak_corporate               akc,
                     gcd_groupcorporatedetails  gcd,
                     qum_quantity_unit_master   qum_gcd,
                     cm_currency_master         cm_gcd,
                     cm_currency_master         cm_akc,
                     drm_derivative_master      drm,
                     dim_der_instrument_master  dim,
                     pdd_product_derivative_def pdd,
                     pdm_productmaster          pdm,
                     qum_quantity_unit_master   qum_pdm,
                     irm_instrument_type_master irm,
                     emt_exchangemaster         emt,
                     phd_profileheaderdetails   phd_drt,
                     pum_price_unit_master      pum,
                     pum_price_unit_master      pum_sp,
                     cm_currency_master         cm_sp,
                     qum_quantity_unit_master   qum_sp,
                     v_main_currency_details    vcur
               where drt.process_id = pc_process_id
                 and akc.corporate_id = drt.corporate_id
                 and akc.groupid = gcd.groupid
                 and gcd.group_cur_id = cm_gcd.cur_id
                 and gcd.group_qty_unit_id = qum_gcd.qty_unit_id
                 and akc.base_currency_name = cm_akc.cur_code
                 and drt.dr_id = drm.dr_id
                 and drm.instrument_id = dim.instrument_id
                 and dim.product_derivative_id = pdd.derivative_def_id
                 and pdd.product_id = pdm.product_id
                 and qum_pdm.qty_unit_id = pdm.base_quantity_unit
                 and irm.instrument_type_id = dim.instrument_type_id
                 and irm.instrument_type in ('Option Put', 'Option Call')
                 and drt.is_what_if = 'N'
                    --AND drt.deal_type_id <> 'Internal Swap'
                    --AND drt.is_new_trade = 'Y'
                 and pdd.exchange_id = emt.exchange_id
                 and phd_drt.profileid = drt.clearer_profile_id
                 and drt.trade_price_unit_id = pum.price_unit_id
                 and pum.cur_id = vcur.main_sub_cur_id
                 and drt.strike_price_unit_id = pum_sp.price_unit_id
                 and pum_sp.cur_id = cm_sp.cur_id
                 and pum_sp.weight_unit_id = qum_sp.qty_unit_id
                 and not exists
               (select dt_pre.internal_derivative_ref_no
                        from dt_derivative_trade dt_pre
                       where dt_pre.internal_derivative_ref_no =
                             drt.internal_derivative_ref_no
                         and dt_pre.process_id = vc_previous_process_id)
               group by gcd.groupid,
                        gcd.groupname,
                        cm_gcd.cur_id,
                        cm_gcd.cur_code,
                        qum_gcd.qty_unit_id,
                        qum_gcd.qty_unit,
                        drt.corporate_id,
                        akc.corporate_name,
                        cm_akc.cur_id,
                        cm_akc.cur_code,
                        pc_process_id,
                        pc_process,
                        pd_trade_date,
                        pdd.product_id,
                        pdm.product_desc,
                        pdm.base_quantity_unit,
                        qum_pdm.qty_unit,
                        dim.instrument_id,
                        dim.instrument_name,
                        pdd.derivative_def_id,
                        pdd.derivative_def_name,
                        dim.instrument_type_id,
                        irm.instrument_type,
                        pdd.exchange_id,
                        emt.exchange_name,
                        drt.dr_id,
                        drm.period_month,
                        drm.period_year,
                        (case
                          when drm.period_date is null then
                           case
                          when drm.period_month is not null and
                               drm.period_year is not null then
                           to_date('01-' || drm.period_month || '-' ||
                                   drm.period_year,
                                   'dd-Mon-yyyy')
                          else
                           drm.prompt_date
                        end else drm.period_date end),
                        pdd.lot_size,
                        pdd.lot_size_unit_id,
                        drt.clearer_profile_id,
                        phd_drt.companyname,
                        drt.deal_type_id,
                        drt.deal_type_id,
                        dim.instrument_type_id,
                        dim.instrument_name,
                        nvl(vcur.main_currency_id, cm_akc.cur_id),
                        nvl(vcur.main_cur_code, cm_akc.cur_code),
                        drt.strike_price,
                        drt.strike_price_unit_id,
                        cm_sp.cur_id,
                        cm_sp.cur_code,
                        pum_sp.weight,
                        qum_sp.qty_unit_id,
                        qum_sp.qty_unit
              union all
              select dpd.group_id,
                     dpd.group_name,
                     dpd.group_cur_id,
                     dpd.group_cur_code,
                     dpd.group_qty_unit_id,
                     dpd.group_qty_unit,
                     dpd.corporate_id,
                     dpd.corporate_name,
                     dpd.base_cur_id,
                     dpd.base_cur_code,
                     pc_process_id,
                     pc_process,
                     pd_trade_date,
                     pdd.product_id,
                     pdm.product_desc product_desc,
                     dpd.base_qty_unit_id,
                     dpd.base_qty_unit,
                     dpd.instrument_id,
                     dpd.instrument_name,
                     dpd.derivative_def_id,
                     dpd.derivative_def_name,
                     dpd.instrument_type_id,
                     dpd.instrument_type,
                     dpd.exchange_id,
                     dpd.exchange_name,
                     dpd.dr_id,
                     dpd.period_date,
                     dpd.lot_size,
                     pdd.lot_size_unit_id,
                     dpd.clearer_profile_id,
                     dpd.clearer_name,
                     dpd.deal_type_id,
                     dpd.deal_type_name,
                     dpd.instrument_type_id trade_type_id,
                     dpd.instrument_name trade_type_name,
                     nvl(dpd.trade_price_cur_id, dpd.base_cur_id) trade_cur_id,
                     nvl(dpd.trade_price_cur_code, dpd.base_cur_code) trade_cur_code,
                     0 initial_position_lots,
                     0 initial_position_qty,
                     0 buy_lots,
                     0 sell_lots,
                     0 buy_qty,
                     0 sell_qty,
                     0 lots_closed,
                     0 unrealized_pnl_in_base_cur,
                     0 unrealized_pnl_in_trade_cur,
                     sum(dpd.pnl_in_base_cur) realized_pnl_in_base_cur,
                     sum(dpd.pnl_in_trade_cur) realized_pnl_in_trade_cur,
                     0 net_open_lots,
                     0 net_open_qty,
                     0 buy_exercised_expired_lots,
                     0 sell_exercised_expired_lots,
                     0 buy_exercised_expired_qty,
                     0 sell_exercised_expired_qty,
                     nvl(sum(case
                               when dpd.trade_type = 'Buy' then
                                dpd.pnl_in_base_cur
                               else
                                0
                             end),
                         0) buy_premium_month,
                     nvl(sum(case
                               when dpd.trade_type = 'Sell' then
                                dpd.pnl_in_base_cur
                               else
                                0
                             end),
                         0) sell_premium_month,
                     dpd.strike_price,
                     dpd.strike_price_unit_id,
                     dpd.strike_price_cur_id,
                     dpd.strike_price_cur_code,
                     dpd.strike_price_weight,
                     dpd.strike_price_weight_unit_id,
                     dpd.strike_price_weight_unit,
                     0 closed_qty,
                     0 cancelled_buy_lots,
                     0 cancelled_buy_qty,
                     0 cancelled_sell_lots,
                     0 cancelled_sell_qty,
                     0 close_diff_in_base_cur,
                     0 close_diff_in_trade_cur
                from dpd_derivative_pnl_daily   dpd,
                     pdd_product_derivative_def pdd,
                     pdm_productmaster          pdm
               where dpd.process_id = pc_process_id
                 and dpd.corporate_id = pc_corporate_id
                 and dpd.derivative_def_id = pdd.derivative_def_id
                 and pdd.product_id = pdm.product_id
                 and dpd.instrument_type in ('Option Put', 'Option Call')
                 and dpd.clearer_profile_id is not null
                    --AND dpd.deal_type_id <> 'Internal Swap'
                 and dpd.pnl_type in ('Options Premium')
                 and dpd.status in ('Settled', 'Closed')
               group by dpd.group_id,
                        dpd.group_name,
                        dpd.group_cur_id,
                        dpd.group_cur_code,
                        dpd.group_qty_unit_id,
                        dpd.group_qty_unit,
                        dpd.corporate_id,
                        dpd.corporate_name,
                        dpd.base_cur_id,
                        dpd.base_cur_code,
                        pc_process_id,
                        pc_process,
                        pd_trade_date,
                        pdd.product_id,
                        pdm.product_desc,
                        dpd.base_qty_unit_id,
                        dpd.base_qty_unit,
                        dpd.instrument_id,
                        dpd.instrument_name,
                        dpd.derivative_def_id,
                        dpd.derivative_def_name,
                        dpd.instrument_type_id,
                        dpd.instrument_type,
                        dpd.exchange_id,
                        dpd.exchange_name,
                        dpd.dr_id,
                        dpd.period_date,
                        dpd.period_month,
                        dpd.period_year,
                        dpd.lot_size,
                        pdd.lot_size_unit_id,
                        dpd.clearer_profile_id,
                        dpd.clearer_name,
                        dpd.deal_type_id,
                        dpd.deal_type_name,
                        dpd.instrument_type_id,
                        dpd.instrument_name,
                        nvl(dpd.trade_price_cur_id, dpd.base_cur_id),
                        nvl(dpd.trade_price_cur_code, dpd.base_cur_code),
                        dpd.strike_price,
                        dpd.strike_price_unit_id,
                        dpd.strike_price_cur_id,
                        dpd.strike_price_cur_code,
                        dpd.strike_price_weight,
                        dpd.strike_price_weight_unit_id,
                        dpd.strike_price_weight_unit
              ---Positon from Closed out and pnl from option premium
              union all
              select dpd.group_id,
                     dpd.group_name,
                     dpd.group_cur_id,
                     dpd.group_cur_code,
                     dpd.group_qty_unit_id,
                     dpd.group_qty_unit,
                     dpd.corporate_id,
                     dpd.corporate_name,
                     dpd.base_cur_id,
                     dpd.base_cur_code,
                     pc_process_id,
                     pc_process,
                     pd_trade_date,
                     pdd.product_id,
                     pdm.product_desc product_desc,
                     dpd.base_qty_unit_id,
                     dpd.base_qty_unit,
                     dpd.instrument_id,
                     dpd.instrument_name,
                     dpd.derivative_def_id,
                     dpd.derivative_def_name,
                     dpd.instrument_type_id,
                     dpd.instrument_type,
                     dpd.exchange_id,
                     dpd.exchange_name,
                     dpd.dr_id,
                     dpd.period_date,
                     dpd.lot_size,
                     pdd.lot_size_unit_id,
                     dpd.clearer_profile_id,
                     dpd.clearer_name,
                     dpd.deal_type_id,
                     dpd.deal_type_name,
                     dpd.instrument_type_id trade_type_id,
                     dpd.instrument_name trade_type_name,
                     nvl(dpd.trade_price_cur_id, dpd.base_cur_id) trade_cur_id,
                     nvl(dpd.trade_price_cur_code, dpd.base_cur_code) trade_cur_code,
                     0 initial_position_lots,
                     0 initial_position_qty,
                     0 buy_lots,
                     0 sell_lots,
                     0 buy_qty,
                     0 sell_qty,
                     nvl(sum(decode(dpd.trade_type, 'Buy', dpd.total_lots, 0)),
                         0) lots_closed,
                     0 unrealized_pnl_in_base_cur,
                     0 unrealized_pnl_in_trade_cur,
                     0 realized_pnl_in_base_cur, --48001
                     0 realized_pnl_in_trade_cur, --48001
                     0 net_open_lots,
                     0 net_open_qty,
                     0 buy_exercised_expired_lots,
                     0 sell_exercised_expired_lots,
                     0 buy_exercised_expired_qty,
                     0 sell_exercised_expired_qty,
                     0 buy_premium_month, --48001
                     0 sell_premium_month, --48001
                     dpd.strike_price,
                     dpd.strike_price_unit_id,
                     dpd.strike_price_cur_id,
                     dpd.strike_price_cur_code,
                     dpd.strike_price_weight,
                     dpd.strike_price_weight_unit_id,
                     dpd.strike_price_weight_unit,
                     nvl(sum(decode(dpd.trade_type,
                                    'Buy',
                                    nvl(dpd.total_quantity, 0),
                                    0) *
                             pkg_general.f_get_converted_quantity(null,
                                                                  dpd.lot_size_unit_id,
                                                                  pdd.lot_size_unit_id,
                                                                  1)),
                         0),
                     0 cancelled_buy_lots,
                     0 cancelled_buy_qty,
                     0 cancelled_sell_lots,
                     0 cancelled_sell_qty,
                     0 close_diff_in_base_cur,
                     0 close_diff_in_trade_cur
                from dpd_derivative_pnl_daily   dpd,
                     pdd_product_derivative_def pdd,
                     pdm_productmaster          pdm
               where dpd.process_id = pc_process_id
                 and dpd.corporate_id = pc_corporate_id
                 and dpd.derivative_def_id = pdd.derivative_def_id
                 and pdd.product_id = pdm.product_id
                 and dpd.instrument_type in ('Option Put', 'Option Call')
                 and dpd.clearer_profile_id is not null
                    --AND dpd.deal_type_id <> 'Internal Swap'
                 and dpd.pnl_type in ('Realized')
                 and dpd.status = 'Closed'
               group by dpd.group_id,
                        dpd.group_name,
                        dpd.group_cur_id,
                        dpd.group_cur_code,
                        dpd.group_qty_unit_id,
                        dpd.group_qty_unit,
                        dpd.corporate_id,
                        dpd.corporate_name,
                        dpd.base_cur_id,
                        dpd.base_cur_code,
                        pc_process_id,
                        pc_process,
                        pd_trade_date,
                        pdd.product_id,
                        pdm.product_desc,
                        dpd.base_qty_unit_id,
                        dpd.base_qty_unit,
                        dpd.instrument_id,
                        dpd.instrument_name,
                        dpd.derivative_def_id,
                        dpd.derivative_def_name,
                        dpd.instrument_type_id,
                        dpd.instrument_type,
                        dpd.exchange_id,
                        dpd.exchange_name,
                        dpd.dr_id,
                        dpd.period_date,
                        dpd.period_month,
                        dpd.period_year,
                        dpd.lot_size,
                        pdd.lot_size_unit_id,
                        dpd.clearer_profile_id,
                        dpd.clearer_name,
                        dpd.deal_type_id,
                        dpd.deal_type_name,
                        dpd.instrument_type_id,
                        dpd.instrument_name,
                        nvl(dpd.trade_price_cur_id, dpd.base_cur_id),
                        nvl(dpd.trade_price_cur_code, dpd.base_cur_code),
                        dpd.strike_price,
                        dpd.strike_price_unit_id,
                        dpd.strike_price_cur_id,
                        dpd.strike_price_cur_code,
                        dpd.strike_price_weight,
                        dpd.strike_price_weight_unit_id,
                        dpd.strike_price_weight_unit
              -- Exercised / Expired Trades for getting Lots/Qty Exercised / Expired
              union all
              select dpd.group_id,
                     dpd.group_name,
                     dpd.group_cur_id,
                     dpd.group_cur_code,
                     dpd.group_qty_unit_id,
                     dpd.group_qty_unit,
                     dpd.corporate_id,
                     dpd.corporate_name,
                     dpd.base_cur_id,
                     dpd.base_cur_code,
                     pc_process_id,
                     pc_process,
                     pd_trade_date,
                     pdd.product_id,
                     pdm.product_desc product_desc,
                     dpd.base_qty_unit_id,
                     dpd.base_qty_unit,
                     dpd.instrument_id,
                     dpd.instrument_name,
                     dpd.derivative_def_id,
                     dpd.derivative_def_name,
                     dpd.instrument_type_id,
                     dpd.instrument_type,
                     dpd.exchange_id,
                     dpd.exchange_name,
                     dpd.dr_id,
                     dpd.period_date,
                     dpd.lot_size,
                     pdd.lot_size_unit_id,
                     dpd.clearer_profile_id,
                     dpd.clearer_name,
                     dpd.deal_type_id,
                     dpd.deal_type_name,
                     dpd.instrument_type_id trade_type_id,
                     dpd.instrument_name trade_type_name,
                     dpd.base_cur_id trade_cur_id,
                     dpd.base_cur_code trade_cur_code,
                     0 initial_position_lots,
                     0 initial_position_qty,
                     0 buy_lots,
                     0 sell_lots,
                     0 buy_qty,
                     0 sell_qty,
                     0 lots_closed,
                     0 unrealized_pnl_in_base_cur,
                     0 unrealized_pnl_in_trade_cur,
                     0 realized_pnl_in_base_cur,
                     0 realized_pnl_in_trade_cur,
                     0 net_open_lots,
                     0 net_open_qty,
                     nvl(sum(case
                               when dpd.trade_type = 'Buy' then
                                dpd.total_lots
                               else
                                0
                             end),
                         0) buy_exercised_expired_lots,
                     nvl(sum(case
                               when dpd.trade_type = 'Sell' then
                                dpd.total_lots
                               else
                                0
                             end),
                         0) sell_exercised_expired_lots,
                     nvl(sum(case
                               when dpd.trade_type = 'Buy' then
                                dpd.trade_qty_in_exch_unit
                               else
                                0
                             end),
                         0) buy_exercised_expired_qty,
                     nvl(sum(case
                               when dpd.trade_type = 'Sell' then
                                dpd.trade_qty_in_exch_unit
                               else
                                0
                             end),
                         0) sell_exercised_expired_qty,
                     0 buy_premium_month,
                     0 sell_premium_month,
                     dpd.strike_price,
                     dpd.strike_price_unit_id,
                     dpd.strike_price_cur_id,
                     dpd.strike_price_cur_code,
                     dpd.strike_price_weight,
                     dpd.strike_price_weight_unit_id,
                     dpd.strike_price_weight_unit,
                     0 closed_qty,
                     0 cancelled_buy_lots,
                     0 cancelled_buy_qty,
                     0 cancelled_sell_lots,
                     0 cancelled_sell_qty,
                     0 close_diff_in_base_cur,
                     0 close_diff_in_trade_cur
                from dpd_derivative_pnl_daily   dpd,
                     pdd_product_derivative_def pdd,
                     pdm_productmaster          pdm
               where dpd.process_id = pc_process_id
                 and dpd.corporate_id = pc_corporate_id
                 and dpd.derivative_def_id = pdd.derivative_def_id
                 and pdd.product_id = pdm.product_id
                 and dpd.instrument_type in ('Option Put', 'Option Call')
                 and dpd.clearer_profile_id is not null
                    --AND dpd.deal_type_id <> 'Internal Swap'
                 and dpd.pnl_type = 'Realized'
                 and dpd.status = 'Closed'
                 and dpd.status in ('Expired', 'Exercised')
               group by dpd.group_id,
                        dpd.group_name,
                        dpd.group_cur_id,
                        dpd.group_cur_code,
                        dpd.group_qty_unit_id,
                        dpd.group_qty_unit,
                        dpd.corporate_id,
                        dpd.corporate_name,
                        dpd.base_cur_id,
                        dpd.base_cur_code,
                        pc_process_id,
                        pc_process,
                        pd_trade_date,
                        pdd.product_id,
                        pdm.product_desc,
                        dpd.base_qty_unit_id,
                        dpd.base_qty_unit,
                        dpd.instrument_id,
                        dpd.instrument_name,
                        dpd.derivative_def_id,
                        dpd.derivative_def_name,
                        dpd.instrument_type_id,
                        dpd.instrument_type,
                        dpd.exchange_id,
                        dpd.exchange_name,
                        dpd.dr_id,
                        dpd.period_date,
                        dpd.period_month,
                        dpd.period_year,
                        dpd.lot_size,
                        pdd.lot_size_unit_id,
                        dpd.clearer_profile_id,
                        dpd.clearer_name,
                        dpd.deal_type_id,
                        dpd.deal_type_name,
                        dpd.instrument_type_id,
                        dpd.instrument_name,
                        dpd.trade_price_cur_id,
                        dpd.trade_price_cur_code,
                        dpd.strike_price,
                        dpd.strike_price_unit_id,
                        dpd.strike_price_cur_id,
                        dpd.strike_price_cur_code,
                        dpd.strike_price_weight,
                        dpd.strike_price_weight_unit_id,
                        dpd.strike_price_weight_unit
              -- Open Position
              union all
              select dpd.group_id,
                     dpd.group_name,
                     dpd.group_cur_id,
                     dpd.group_cur_code,
                     dpd.group_qty_unit_id,
                     dpd.group_qty_unit,
                     dpd.corporate_id,
                     dpd.corporate_name,
                     dpd.base_cur_id,
                     dpd.base_cur_code,
                     pc_process_id,
                     pc_process,
                     pd_trade_date,
                     pdd.product_id,
                     pdm.product_desc product_desc,
                     dpd.base_qty_unit_id,
                     dpd.base_qty_unit,
                     dpd.instrument_id,
                     dpd.instrument_name,
                     dpd.derivative_def_id,
                     dpd.derivative_def_name,
                     dpd.instrument_type_id,
                     dpd.instrument_type,
                     dpd.exchange_id,
                     dpd.exchange_name,
                     dpd.dr_id,
                     dpd.period_date,
                     dpd.lot_size,
                     pdd.lot_size_unit_id,
                     dpd.clearer_profile_id,
                     dpd.clearer_name,
                     dpd.deal_type_id,
                     dpd.deal_type_name,
                     dpd.instrument_type_id trade_type_id,
                     dpd.instrument_name trade_type_name,
                     nvl(dpd.trade_price_cur_id, dpd.base_cur_id) trade_price_cur_id,
                     nvl(dpd.trade_price_cur_code, dpd.base_cur_code) trade_price_cur_code,
                     0 initial_position_lots,
                     0 initial_position_qty,
                     0 buy_lots,
                     0 sell_lots,
                     0 buy_qty,
                     0 sell_qty,
                     0 lots_closed,
                     sum(dpd.pnl_in_base_cur) unrealized_pnl_in_base_cur,
                     sum(dpd.pnl_in_trade_cur) unrealized_pnl_in_trade_cur,
                     0 realized_pnl_in_base_cur,
                     0 realized_pnl_in_trade_cur,
                     sum(decode(dpd.trade_type, 'Sell', -1, 1) *
                         dpd.total_lots) net_open_lots,
                     sum(decode(dpd.trade_type, 'Sell', -1, 1) *
                         dpd.trade_qty_in_exch_unit) net_open_qty,
                     0 buy_exercised_expired_lots,
                     0 sell_exercised_expired_lots,
                     0 buy_exercised_expired_qty,
                     0 sell_exercised_expired_qty,
                     0 buy_premium_month,
                     0 sell_premium_month,
                     dpd.strike_price,
                     dpd.strike_price_unit_id,
                     dpd.strike_price_cur_id,
                     dpd.strike_price_cur_code,
                     dpd.strike_price_weight,
                     dpd.strike_price_weight_unit_id,
                     dpd.strike_price_weight_unit,
                     0 closed_qty,
                     0 cancelled_buy_lots,
                     0 cancelled_buy_qty,
                     0 cancelled_sell_lots,
                     0 cancelled_sell_qty,
                     0 close_diff_in_base_cur,
                     0 close_diff_in_trade_cur
                from dpd_derivative_pnl_daily   dpd,
                     pdd_product_derivative_def pdd,
                     pdm_productmaster          pdm
               where dpd.process_id = pc_process_id
                 and dpd.corporate_id = pc_corporate_id
                 and dpd.derivative_def_id = pdd.derivative_def_id
                 and pdd.product_id = pdm.product_id
                 and dpd.instrument_type in ('Option Put', 'Option Call')
                 and dpd.clearer_profile_id is not null
                    --AND dpd.deal_type_id <> 'Internal Swap'
                 and dpd.pnl_type = 'Unrealized'
              --AND dpd.trade_status = 'Open'
               group by dpd.group_id,
                        dpd.group_name,
                        dpd.group_cur_id,
                        dpd.group_cur_code,
                        dpd.group_qty_unit_id,
                        dpd.group_qty_unit,
                        dpd.corporate_id,
                        dpd.corporate_name,
                        dpd.base_cur_id,
                        dpd.base_cur_code,
                        pc_process_id,
                        pc_process,
                        pd_trade_date,
                        pdd.product_id,
                        pdm.product_desc,
                        dpd.base_qty_unit_id,
                        dpd.base_qty_unit,
                        dpd.instrument_id,
                        dpd.instrument_name,
                        dpd.derivative_def_id,
                        dpd.derivative_def_name,
                        dpd.instrument_type_id,
                        dpd.instrument_type,
                        dpd.exchange_id,
                        dpd.exchange_name,
                        dpd.dr_id,
                        dpd.period_date,
                        dpd.period_month,
                        dpd.period_year,
                        dpd.lot_size,
                        pdd.lot_size_unit_id,
                        dpd.clearer_profile_id,
                        dpd.clearer_name,
                        dpd.deal_type_id,
                        dpd.deal_type_name,
                        dpd.instrument_type_id,
                        dpd.instrument_name,
                        nvl(dpd.trade_price_cur_id, dpd.base_cur_id),
                        nvl(dpd.trade_price_cur_code, dpd.base_cur_code),
                        dpd.strike_price,
                        dpd.strike_price_unit_id,
                        dpd.strike_price_cur_id,
                        dpd.strike_price_cur_code,
                        dpd.strike_price_weight,
                        dpd.strike_price_weight_unit_id,
                        dpd.strike_price_weight_unit)
       group by group_id,
                group_name,
                group_cur_id,
                group_cur_code,
                group_qty_unit_id,
                group_qty_unit,
                corporate_id,
                corporate_name,
                base_cur_id,
                base_cur_code,
                process_id,
                process,
                trade_date,
                product_id,
                product_desc,
                base_qty_unit_id,
                base_qty_unit,
                instrument_id,
                instrument_name,
                derivative_def_id,
                derivative_def_name,
                instrument_type_id,
                instrument_type_name,
                exchange_id,
                exchange_name,
                dr_id,
                period_date,
                lot_size,
                lot_size_unit_id,
                clearer_profile_id,
                clearer_name,
                deal_type_id,
                deal_type_name,
                trade_type_id,
                trade_type_name,
                trade_price_cur_id,
                trade_price_cur_code,
                strike_price,
                strike_price_unit_id,
                strike_price_cur_id,
                strike_price_cur_code,
                nvl(strike_price_weight, 1),
                strike_price_weight_unit_id,
                strike_price_weight_unit;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_clearer_summary',
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

  procedure recordfxpnl(p_corporateid varchar2,
                        p_tradedate   date,
                        p_process_id  varchar2,
                        p_userid      varchar2,
                        p_prcoess     varchar2) is
    cursor c_day_end_fx is
      select ct.internal_treasury_ref_no,
             ct.corporate_id,
             ak.corporate_name,
             ct.process_id,
             ct.trade_date,
             ct.treasury_ref_no ct_ref_no,
             ct.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             ct.dr_id ct_id,
             dim.instrument_id instrument_id,
             irm.instrument_type instrument_type,
             pdd.derivative_def_id currency_def_id,
             pdd.derivative_def_name derivative_name,
             pdm.product_desc product_name,
             drm.prompt_date prompt_date,
             drm.prompt_date expiry_date,
             crtd_base.amount base_currency_amount,
             crtd_base.trade_type base_cur_buy_sell,
             ak.base_currency_name base_currency,
             round(1 / mv_cfq.rate, 8) market_exchange_rate,
             round(1 / ct.fx_rate_base_to_foreign, 8) original_exchange_rate, -- this has to be changed with exchange_rate column, as bug in app
             crtd_fx.cur_id fx_cur_id,
             crtd_base.cur_id base_cur_id,
             cm_fx.cur_code fx_cur_code,
             crtd_fx.amount fx_currency_amount,
             crtd_fx.trade_type fx_cur_buy_sell,
             oba.account_name,
             oba.account_no,
             phd.companyname bank_name,
             ct.bank_acc_id bank_account,
             ct.bank_charges bank_charges,
             ct.bank_charges_cur_id bank_cur_id,
             null as bank_charges_percent,
             ct.bank_charges_type,
             cm.cur_code bank_charges_currency,
             mv_cfq.dr_id cfq_id,
             mv_cfq.process_date,
             mv_cfq.prompt_date maturity_date,
             mv_cfq.is_spot,
             null as user_entered_fx
        from ct_currency_trade              ct,
             ak_corporate                   ak,
             cpc_corporate_profit_center    cpc,
             eodeom_currency_forward_quotes mv_cfq,
             irm_instrument_type_master     irm,
             pdd_product_derivative_def     pdd,
             dim_der_instrument_master      dim,
             drm_derivative_master          drm,
             pdm_productmaster              pdm,
             crtd_cur_trade_details         crtd_base,
             crtd_cur_trade_details         crtd_fx,
             cm_currency_master             cm_base,
             cm_currency_master             cm,
             cm_currency_master             cm_fx,
             oba_our_bank_accounts          oba,
             phd_profileheaderdetails       phd
      
       where ct.corporate_id = ak.corporate_id
         and ak.corporate_id = p_corporateid
         and ct.profit_center_id = cpc.profit_center_id
         and ct.corporate_id = mv_cfq.corporate_id
         and ct.dr_id = mv_cfq.dr_id
         and mv_cfq.process_id = p_process_id
            --AND mv_cfq.trade_date <= '08-FEB-2011'
            --   and mv_cfq.trade_date = least(drm.prompt_date, p_tradedate)
         and ct.dr_id = drm.dr_id
         and drm.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.product_id = pdm.product_id
         and dim.instrument_type_id = irm.instrument_type_id
         and ct.internal_treasury_ref_no =
             crtd_base.internal_treasury_ref_no
         and crtd_base.cur_id = cm_base.cur_id(+)
         and ct.internal_treasury_ref_no = crtd_fx.internal_treasury_ref_no
         and crtd_fx.cur_id = cm_fx.cur_id(+)
         and crtd_base.is_base = 'Y'
         and crtd_fx.is_base = 'N'
         and ct.bank_charges_cur_id = cm.cur_id(+)
         and ct.bank_id = phd.profileid(+)
         and ct.bank_id = oba.bank_id(+)
         and ct.bank_acc_id = oba.account_id(+)
         and upper(ct.status) = 'VERIFIED'
         and not exists (select eci.ct_id
                from eci_expired_ct_id eci
               where eci.corporate_id = p_corporateid
                 and eci.process = p_prcoess
                 and eci.trade_date < p_tradedate
                 and eci.ct_id = drm.dr_id)
         and ct.process_id = p_process_id
         and crtd_base.process_id = p_process_id
         and crtd_fx.process_id = p_process_id;
  
    l_market_exchange_rate       number;
    l_ex_rate_bank_to_home_cur   number;
    l_market_value_in_home_cur   number;
    l_original_value_in_home_cur number;
    l_pnl_value_in_home_cur      number;
    l_bank_charges_in_home_cur   number;
    l_net_pnl_in_home_cur        number;
    l_pnl_type                   varchar2(15);
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
  begin
    dbms_output.put_line('currency section starts');
  
    for fx_rec_new in c_day_end_fx
    loop
      --since there is an outer join with cfq, a null in cfq_id indicates that there is no entry for forward quotes.
      if fx_rec_new.cfq_id is null then
        dbms_output.put_line('currency section entets if');
        vobj_error_log.extend;
        vobj_error_log(vn_eel_error_count) := pelerrorlogobj(p_corporateid,
                                                             'procedure recordfxpnl',
                                                             'M2M-027',
                                                             'Settlement Rate ',
                                                             null,
                                                             --fx_rec_new.ct_ref_no,
                                                             p_prcoess,
                                                             p_userid,
                                                             sysdate,
                                                             p_tradedate);
        sp_insert_error_log(vobj_error_log);
        dbms_output.put_line('Failed with exception');
      end if;
      /*
      if fx_rec_new.expiry_date <= p_tradedate then
        l_pnl_type := 'REALIZED';
      else
        l_pnl_type := 'UNREALIZED';
      end if;*/
      if fx_rec_new.process_date = fx_rec_new.maturity_date and
         fx_rec_new.is_spot = 'Y' then
        l_pnl_type := 'REALIZED';
      else
        l_pnl_type := 'UNREALIZED';
      end if;
    
      dbms_output.put_line('currency section l_market_exchange_rate');
      l_market_exchange_rate := fx_rec_new.market_exchange_rate;
    
      --if fx_rec_new.bank_charges_type ='Absolute' then
      if l_pnl_type = 'REALIZED' then
        if (fx_rec_new.bank_cur_id != fx_rec_new.base_cur_id) then
          dbms_output.put_line('fx_rec_new.bank_cur_id != fx_rec_new.base_cur_id');
          l_ex_rate_bank_to_home_cur := pkg_general.f_get_converted_currency_amt(p_corporateid,
                                                                                 fx_rec_new.bank_cur_id,
                                                                                 fx_rec_new.base_cur_id,
                                                                                 p_tradedate,
                                                                                 1);
          dbms_output.put_line('pkg_general.f_get_converted_currency_amt');
        else
          l_ex_rate_bank_to_home_cur := 1;
        end if;
      
        if upper(fx_rec_new.bank_charges_type) = 'ABSOLUTE' then
          l_bank_charges_in_home_cur := nvl(fx_rec_new.bank_charges, 0) *
                                        nvl(l_ex_rate_bank_to_home_cur, 0);
        else
          l_bank_charges_in_home_cur := (fx_rec_new.bank_charges / 100) *
                                        fx_rec_new.base_currency_amount;
          l_ex_rate_bank_to_home_cur := 1;
        end if;
      else
        l_bank_charges_in_home_cur := 0;
        l_ex_rate_bank_to_home_cur := 1;
      end if;
    
      --    l_market_value_in_home_cur   := l_market_exchange_rate *  fx_rec_new.base_currency_amount;
      --      l_original_value_in_home_cur := fx_rec_new.original_exchange_rate *  fx_rec_new.base_currency_amount;
    
      l_market_value_in_home_cur   := l_market_exchange_rate *
                                      fx_rec_new.fx_currency_amount;
      l_original_value_in_home_cur := fx_rec_new.original_exchange_rate *
                                      fx_rec_new.fx_currency_amount;
    
      if fx_rec_new.base_cur_buy_sell = 'Sell' then
        l_pnl_value_in_home_cur := l_market_value_in_home_cur -
                                   l_original_value_in_home_cur;
      else
        l_pnl_value_in_home_cur := -1 * (l_market_value_in_home_cur -
                                   l_original_value_in_home_cur);
      end if;
    
      l_net_pnl_in_home_cur := l_pnl_value_in_home_cur -
                               l_bank_charges_in_home_cur;
    
      dbms_output.put_line('insert into cpd_currency_pnl_daily');
    
      insert into cpd_currency_pnl_daily
        (ct_internal_ref_no,
         corporate_id,
         corporate_name,
         process_id,
         eod_trade_date,
         trade_date,
         ct_ref_no,
         profit_center_id,
         profit_center_name,
         strategy_id,
         strategy_name,
         ct_id,
         cfq_id,
         instrument_id,
         instrument_name,
         instrument_type,
         currency_def_id,
         derivative_name,
         product_name,
         prompt_date,
         expiry_date,
         pnl_type,
         home_currency_amount,
         home_cur_buy_sell,
         home_currency,
         home_cur_id,
         market_exchange_rate,
         original_exchange_rate,
         fx_cur_id,
         fx_currency,
         fx_currency_amount,
         fx_cur_buy_sell,
         bank_name,
         bank_account,
         account_no,
         account_name,
         bank_charges,
         bank_charges_currency,
         bank_charges_type,
         bank_charges_cur_id,
         bank_charges_percent,
         ex_rate_from_bank_to_home_cur,
         market_value_in_home_currency,
         original_value_in_home_curr,
         pnl_value_in_home_currency,
         bank_charges_in_home_currency,
         net_pnl_in_home_currency,
         user_entered_fx,
         profit_center_short_name)
      values
        (fx_rec_new.internal_treasury_ref_no,
         fx_rec_new.corporate_id,
         fx_rec_new.corporate_name,
         fx_rec_new.process_id,
         p_tradedate,
         fx_rec_new.trade_date,
         fx_rec_new.ct_ref_no,
         fx_rec_new.profit_center_id,
         fx_rec_new.profit_center_name,
         '', --strategy_id
         '', --strategy_name
         fx_rec_new.ct_id,
         fx_rec_new.cfq_id,
         fx_rec_new.instrument_id,
         fx_rec_new.instrument_type, -- Instrument name
         fx_rec_new.instrument_type,
         fx_rec_new.currency_def_id,
         fx_rec_new.derivative_name, --derivative_name
         fx_rec_new.product_name,
         fx_rec_new.prompt_date, --prompt_date
         fx_rec_new.expiry_date,
         l_pnl_type, --pnl type
         fx_rec_new.base_currency_amount,
         fx_rec_new.base_cur_buy_sell,
         fx_rec_new.base_currency,
         fx_rec_new.base_cur_id,
         fx_rec_new.market_exchange_rate,
         fx_rec_new.original_exchange_rate,
         fx_rec_new.fx_cur_id,
         fx_rec_new.fx_cur_code,
         fx_rec_new.fx_currency_amount,
         fx_rec_new.fx_cur_buy_sell,
         fx_rec_new.bank_name,
         fx_rec_new.bank_account,
         fx_rec_new.account_no,
         fx_rec_new.account_name,
         fx_rec_new.bank_charges,
         fx_rec_new.bank_charges_currency,
         fx_rec_new.bank_charges_type,
         fx_rec_new.bank_cur_id,
         fx_rec_new.bank_charges_percent,
         l_ex_rate_bank_to_home_cur,
         l_market_value_in_home_cur,
         l_original_value_in_home_cur,
         l_pnl_value_in_home_cur,
         l_bank_charges_in_home_cur,
         l_net_pnl_in_home_cur,
         fx_rec_new.user_entered_fx,
         fx_rec_new.profit_center_short_name);
    end loop;
  exception
    when others then
      dbms_output.put_line('Error in currency section' || sqlerrm);
  end;

  procedure sp_calc_price_exposure(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_process      varchar2,
                                   pc_user_id      varchar2) is
  
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
    cursor cur_derivative is
      select dpd.corporate_id,
             dpd.process_id process_id,
             dpd.eod_trade_date process_date,
             dpd.derivative_ref_no,
             dpd.internal_derivative_ref_no,
             dpd.trade_type,
             dpd.trade_price,
             dpd.trade_price_cur_code || '/' ||
             decode(nvl(dpd.trade_price_weight, 1),
                    1,
                    null,
                    dpd.trade_price_weight_unit) ||
             dpd.sett_price_weight_unit price_unit_name,
             dpd.trade_price_weight,
             dpd.trade_price_weight_unit,
             dpd.trade_price_weight_unit_id, --QUM-51
             dpd.trade_price_type_id price_type_id,
             dpd.trade_price_unit_id trade_price_unit_id,
             dpd.settlement_price,
             dpd.trade_price_cur_id,
             dpd.sett_price_unit_id sett_price_unit_id, --PUM-161
             dpd.sett_price_cur_code || '/' ||
             decode(nvl(dpd.sett_price_weight, 1),
                    1,
                    null,
                    dpd.sett_price_weight) || dpd.sett_price_weight_unit sett_price_unit,
             decode(nvl(dpd.trade_price_weight, 1),
                    1,
                    null,
                    dpd.trade_price_weight) || dpd.trade_price_weight_unit trade_price_unit,
             dpd.sett_price_weight_unit,
             dpd.sett_price_weight_unit_id,
             dpd.sett_price_cur_id,
             dpd.total_quantity,
             dpd.quantity_unit_id,
             dpd.sett_price_weight,
             dpd.quantity_unit,
             dpd.product_id,
             dpd.product_name,
             dpd.profit_center_id,
             dpd.profit_center_name,
             dpd.profit_center_short_name,
             dpd.base_qty_unit_id,
             dpd.base_qty_unit quantity,
             dpd.pnl_type,
             dpd.price_point_id,
             dpd.instrument_id,
             dpd.instrument_name,
             dpd.dr_id,
             dpd.dr_id_name,
             dpd.base_cur_id,
             dpd.base_cur_code,
             dpd.index_instrument_id,
             dpd.index_instrument_name,
             dpd.formula_id,
             dpd.formula_name,
             dpd.formula_display,
             nvl(period_year,to_char(period_date,'yyyy')) period_year,
             nvl(period_month,to_char(period_date,'Mon')) period_month,
             dpd.period_date,
             dpd.leg_no,
             dpd.gravity,
             dpd.gravity_type,
             dpd.density_mass_qty_unit_id,
             dpd.density_volume_qty_unit_id
        from dpd_derivative_pnl_daily dpd
       where dpd.pnl_type = 'Unrealized'
         and dpd.corporate_id = pc_corporate_id
         and dpd.instrument_type in ('Future', 'Forward')
         and dpd.process_id = pc_process_id;
  
    vn_contract_value     number(25, 4);
    vn_m2m_amount         number(25, 4);
    vt_tbl_setup          pe_tbl_setup;
    vt_tbl_instrument     pe_tbl_instrument;
    vn_cur_row_cnt        number;
    vn_fb_order_sq        number := 1;
    vt_tbl_instrument_out pe_tbl_instrument;
    vt_tbl_setup_out      pe_tbl_setup;
    vc_error_loc          varchar2(50);
    vc_error_number       number := 0;
  
  begin
    for cur_derivative_row in cur_derivative
    loop
    
      -- make one entry for valuation section as exposure type as 'Market' and price status as 'Floating'
      vn_contract_value := 0;
      vn_m2m_amount     := 0;
      vn_contract_value := 0;
    
      vn_m2m_amount   := round((cur_derivative_row.settlement_price /
                               nvl(cur_derivative_row.sett_price_weight, 1)) *
                               pkg_general.f_get_converted_currency_amt(cur_derivative_row.corporate_id,
                                                                        cur_derivative_row.sett_price_cur_id,
                                                                        cur_derivative_row.base_cur_id,
                                                                        cur_derivative_row.process_date,
                                                                        1) *
                               (pkg_general.fn_mass_volume_qty_conversion(cur_derivative_row.product_id,
                                                                          cur_derivative_row.base_qty_unit_id,
                                                                          cur_derivative_row.sett_price_weight_unit_id,
                                                                          cur_derivative_row.total_quantity,
                                                                          cur_derivative_row.gravity,
                                                                          cur_derivative_row.gravity_type,
                                                                          cur_derivative_row.density_mass_qty_unit_id,
                                                                          cur_derivative_row.density_volume_qty_unit_id)),
                               4);
      vc_error_number := 1;
      insert into dpe_derivative_price_exposure
        (corporate_id,
         process_id,
         process_date,
         internal_derivative_ref_no,
         derivative_ref_no,
         leg_no,
         trade_type,
         exposure_type,
         price_status,
         instrumnet_id,
         instrument_name,
         instrument_month_year,
         instrument_month_date,
         exposure_quantity,
         quantity_unit_id,
         quantity_unit,
         final_price,
         final_price_unit,
         final_price_unit_id,
         final_price_staus,
         final_price_qp_status,
         total_value,
         value_cur_id,
         value_cur_code,
         setup_remarks)
      values
        (cur_derivative_row.corporate_id,
         cur_derivative_row.process_id,
         cur_derivative_row.process_date,
         cur_derivative_row.internal_derivative_ref_no,
         cur_derivative_row.derivative_ref_no,
         cur_derivative_row.leg_no,
         decode(cur_derivative_row.trade_type, 'Sell', 'S', 'P'),
         'Market',
         'Floating',
         cur_derivative_row.instrument_id,
         cur_derivative_row.instrument_name,
         cur_derivative_row.period_month,
         '01-' || cur_derivative_row.period_month || '-' ||
         cur_derivative_row.period_year, --v_instrument_month_date
         cur_derivative_row.total_quantity,
         cur_derivative_row.quantity_unit_id,
         cur_derivative_row.quantity_unit,
         cur_derivative_row. settlement_price,
         cur_derivative_row.sett_price_unit, --   v_final_price_unit,        
         cur_derivative_row.sett_price_unit_id,
         null, --final_price_staus,                          
         null, --final_price_qp_status               
         vn_m2m_amount * (-1),
         cur_derivative_row.base_cur_id, -- v_value_cur_id,                                   
         cur_derivative_row.base_cur_code, -- v_value_cur_code,                                 
         null);
      vc_error_number := 2;
      /*for fixed price type*/
      if cur_derivative_row.price_type_id = 'Fixed' then
      
        --calculate the contract value
        vn_contract_value := round((cur_derivative_row.trade_price /
                                   nvl(cur_derivative_row.trade_price_weight,
                                        1)) *
                                   pkg_general.f_get_converted_currency_amt(cur_derivative_row.corporate_id,
                                                                            cur_derivative_row.trade_price_cur_id,
                                                                            cur_derivative_row.base_cur_id,
                                                                            cur_derivative_row.process_date,
                                                                            1) *
                                   (pkg_general.fn_mass_volume_qty_conversion(cur_derivative_row.product_id,
                                                                              cur_derivative_row.base_qty_unit_id,
                                                                              cur_derivative_row.trade_price_weight_unit_id,
                                                                              cur_derivative_row.total_quantity,
                                                                              cur_derivative_row.gravity,
                                                                              cur_derivative_row.gravity_type,
                                                                              cur_derivative_row.density_mass_qty_unit_id,
                                                                              cur_derivative_row.density_volume_qty_unit_id)),
                                   4);
        vc_error_number   := 3;
        --insert the values to the dpe_derivative_price_exposore                                                   
        insert into dpe_derivative_price_exposure
          (corporate_id,
           process_id,
           process_date,
           internal_derivative_ref_no,
           derivative_ref_no,
           leg_no,
           trade_type,
           exposure_type,
           price_status,
           instrumnet_id,
           instrument_name,
           instrument_month_year,
           instrument_month_date,
           exposure_quantity,
           quantity_unit_id,
           quantity_unit,
           final_price,
           final_price_unit,
           final_price_unit_id,
           final_price_staus,
           final_price_qp_status,
           total_value,
           value_cur_id,
           value_cur_code,
           setup_remarks)
        values
          (cur_derivative_row.corporate_id,
           cur_derivative_row.process_id,
           cur_derivative_row.process_date,
           cur_derivative_row.internal_derivative_ref_no,
           cur_derivative_row.derivative_ref_no,
           cur_derivative_row.leg_no,
           decode(cur_derivative_row.trade_type, 'Sell', 'S', 'P'),
           'Position',
           'Fixed',
           null, --cur_derivative_row.instrument_id,
           'Fixed Price', -- cur_derivative_row.instrument_name, 
           'NA', --cur_derivative_row.period_month, 
           null, --v_instrument_month_date,--not e
           cur_derivative_row.total_quantity,
           cur_derivative_row.quantity_unit_id,
           cur_derivative_row.quantity_unit,
           cur_derivative_row.trade_price,
           cur_derivative_row.trade_price_unit, --   v_final_price_unit,                               
           cur_derivative_row.trade_price_unit_id, --  v_final_price_unit_id,                            
           null, --v_final_price_staus,                          
           null, --v_final_price_qp_status,                          
           vn_contract_value,
           cur_derivative_row.base_cur_id, -- v_value_cur_id,                                   
           cur_derivative_row.base_cur_code, -- v_value_cur_code,                                 
           null); -- v_setup_remarks);    
        vc_error_number := 4;
      
      end if;
    
      if cur_derivative_row.price_type_id in ('Index', 'Formula') then
        vt_tbl_setup          := pe_tbl_setup();
        vt_tbl_setup_out      := pe_tbl_setup();
        vt_tbl_instrument     := pe_tbl_instrument();
        vt_tbl_instrument_out := pe_tbl_instrument();
        vc_error_loc          := '1';
      
        if cur_derivative_row.price_type_id = 'Index' then
          vn_fb_order_sq := 1;
          vn_cur_row_cnt := 1;
        
          for cc1 in (select dt.instrument_id,
                             dt.price_source_id,
                             dt.price_point_id,
                             dt.available_price_id,
                             dt.period_type_id,
                             dt.period_month,
                             dt.period_year,
                             dt.period_from_date,
                             dt.period_to_date,
                             dt.no_of_months,
                             dt.no_of_days,
                             dt.fb_period_type,
                             dt.fb_period_sub_type,
                             dt.delivery_period_id,
                             dt.off_day_price,
                             dt.basis,
                             dt.basis_price_unit_id,
                             dt.fx_rate_type,
                             dt.fx_rate_
                        from dt_fbi dt
                       where dt.internal_derivative_ref_no =
                             cur_derivative_row.internal_derivative_ref_no)
          loop
            vc_error_loc := '2';
            vt_tbl_setup.extend;
            vt_tbl_setup(1) := pe_typ_setup(pc_corporate_id,
                                            cur_derivative_row.index_instrument_id,
                                            'index',
                                            'index',
                                            '$' || cc1.instrument_id || '$',
                                            pd_trade_date,
                                            null,
                                            null,
                                            null,
                                            null,
                                            null,
                                            null,
                                            null,
                                            cur_derivative_row.base_cur_id, -- v_value_cur_id,
                                            cur_derivative_row.base_cur_code, --v_value_cur_code,
                                            cur_derivative_row.total_quantity,
                                            cur_derivative_row.base_qty_unit_id,
                                            null);
            vc_error_number := 5;
            vt_tbl_instrument.extend;
            vt_tbl_instrument(vn_cur_row_cnt) := pe_typ_instrument(vn_fb_order_sq,
                                                                   cc1.instrument_id, --index_id
                                                                   cc1.instrument_id,
                                                                   cc1.price_source_id,
                                                                   cc1.price_point_id,
                                                                   cc1.available_price_id,
                                                                   cc1.fb_period_type,
                                                                   cc1.fb_period_sub_type,
                                                                   cc1.period_month,
                                                                   cc1.period_year,
                                                                   cc1.period_from_date,
                                                                   cc1.period_to_date,
                                                                   cc1.no_of_months,
                                                                   cc1.no_of_days,
                                                                   cc1.period_type_id,
                                                                   cc1.delivery_period_id,
                                                                   cc1.off_day_price,
                                                                   cc1.basis,
                                                                   cc1.basis_price_unit_id,
                                                                   cc1.fx_rate_type,
                                                                   cc1.fx_rate_,
                                                                   null, -- avg_price                                                                                                                                                                                                                                
                                                                   null, --avg_price_unit_id
                                                                   null, --avg_fx_rate
                                                                   null, --avg_conv_price
                                                                   null, --avg_conv_price_wt_basis
                                                                   null, --price_status
                                                                   null, --price_qp_status
                                                                   cur_derivative_row.total_quantity,
                                                                   cur_derivative_row.base_qty_unit_id,
                                                                   null, --avg_value
                                                                   null, --avg_cur_id
                                                                   null, --avg_cur_code
                                                                   null, --price_details(nested obj)
                                                                   null --remarks
                                                                   );
            vc_error_number := 6;
          end loop;
        end if;
      
        /*for formula*/
        if cur_derivative_row.price_type_id = 'Formula' then
          vn_fb_order_sq := 1;
          vn_cur_row_cnt := 1;
          vc_error_loc   := '3';
        
          for cc in (select fbs.formula_internal,
                            fbs.formula_display,
                            fbs.formula_name,
                            fbs.formula_id,
                            fbs.price_unit_id
                       from fbs_formula_builder_setup fbs
                      where fbs.formula_id = cur_derivative_row.formula_id)
          loop
            /*constructin the set up type*/
            vc_error_loc := '4';
            vt_tbl_setup.extend;
            vt_tbl_setup(vn_cur_row_cnt) := pe_typ_setup(pc_corporate_id,
                                                         cur_derivative_row.formula_id,
                                                         cur_derivative_row.formula_name,
                                                         cur_derivative_row.formula_display,
                                                         null, --formula_internal
                                                         pd_trade_date,
                                                         null, --basics
                                                         null, --basics_price_unit_id
                                                         null, --final_price
                                                         null, --final_price_unit
                                                         null, --final_price_staus
                                                         null, --final_price_qp_status
                                                         null, --total_value
                                                         cur_derivative_row.base_cur_id,
                                                         cur_derivative_row.base_cur_code,
                                                         cur_derivative_row.total_quantity,
                                                         cur_derivative_row.base_qty_unit_id,
                                                         null --remarks
                                                         );
            vc_error_number := 7;
            vn_cur_row_cnt := vn_cur_row_cnt + 1;
          end loop;
          vn_cur_row_cnt := 1;
          vn_fb_order_sq := 1;
          /*constructing the instrument type*/
        
          for cc1 in (select dt.instrument_id,
                             dt.formula_id,
                             dt.price_source_id,
                             dt.price_point_id,
                             dt.available_price_id,
                             dt.period_type_id,
                             dt.period_month,
                             dt.period_year,
                             dt.period_from_date,
                             dt.period_to_date,
                             dt.no_of_months,
                             dt.no_of_days,
                             dt.fb_period_type,
                             dt.fb_period_sub_type,
                             dt.delivery_period_id,
                             dt.off_day_price,
                             dt.basis,
                             dt.basis_price_unit_id,
                             dt.fx_rate_type,
                             dt.fx_rate_
                        from dt_fbi dt
                       where dt.internal_derivative_ref_no =
                             cur_derivative_row.internal_derivative_ref_no)
          loop
            vc_error_loc := '5';
            vt_tbl_instrument.extend;
            vt_tbl_instrument(vn_cur_row_cnt) := pe_typ_instrument(vn_fb_order_sq,
                                                                   cc1.formula_id, --index_id
                                                                   cc1.instrument_id,
                                                                   cc1.price_source_id,
                                                                   cc1.price_point_id,
                                                                   cc1.available_price_id,
                                                                   cc1.fb_period_type,
                                                                   cc1.fb_period_sub_type,
                                                                   cc1.period_month,
                                                                   cc1.period_year,
                                                                   cc1.period_from_date,
                                                                   cc1.period_to_date,
                                                                   cc1.no_of_months,
                                                                   cc1.no_of_days,
                                                                   cc1.period_type_id,
                                                                   cc1.delivery_period_id,
                                                                   cc1.off_day_price,
                                                                   cc1.basis,
                                                                   cc1.basis_price_unit_id,
                                                                   cc1.fx_rate_type,
                                                                   cc1.fx_rate_,
                                                                   null, --avg_price                                                                                                                                                                                                                          
                                                                   null, --avg_price_unit_id
                                                                   null, --avg_fx_rate
                                                                   null, --avg_conv_price
                                                                   null, --avg_conv_price_wt_basis
                                                                   null, --price_status
                                                                   null, --price_qp_status
                                                                   cur_derivative_row.total_quantity,
                                                                   cur_derivative_row.base_qty_unit_id,
                                                                   null, --avg_value
                                                                   null, --avg_cur_id
                                                                   null, --avg_cur_code
                                                                   null, --price_details(nested obj)
                                                                   null --remarks
                                                                   );
            vc_error_number := 8;
            vn_fb_order_sq := vn_fb_order_sq + 1;
            vn_cur_row_cnt := vn_cur_row_cnt + 1;
          end loop;
        end if;
        vt_tbl_instrument_out.extend;
        vt_tbl_setup_out.extend;
      
        dbms_output.put_line('The total no. of recordsin the instrument is  ' ||
                             vt_tbl_instrument.count);
        dbms_output.put_line('Tthe total np of records in the set up is ' ||
                             vt_tbl_setup.count);
      
        pkg_cdc_price_exposure.sp_calculate_price(vt_tbl_setup,
                                                  vt_tbl_instrument,
                                                  vt_tbl_setup_out,
                                                  vt_tbl_instrument_out,
                                                  cur_derivative_row.product_id,
                                                  cur_derivative_row.gravity,
                                                  cur_derivative_row.gravity_type,
                                                  cur_derivative_row.density_mass_qty_unit_id,
                                                  cur_derivative_row.density_volume_qty_unit_id,
                                                  pc_process_id);
      
        dbms_output.put_line('The total no. of recordsin the instrument is(After)  ' ||
                             vt_tbl_instrument.count);
        dbms_output.put_line('The total np of records in the set up is(After) ' ||
                             vt_tbl_setup.count);
      
        if vt_tbl_instrument(1).price_details is null then
          dbms_output.put_line('no data in the nested record');
        else
          dbms_output.put_line('Data is in the nested record ');
        end if;
        -- for cc in (select * from the (select * from cast (vt_tbl_instrument_out as pe_tbl_instrument) from dual) loop
        vc_error_loc := '6';
        for cc in (select *
                     from the (select cast(vt_tbl_instrument_out as
                                           pe_tbl_instrument)
                                 from dual))
        loop
          vc_error_loc := '7';
          if cc.price_details is not null then
            for cc_qp in (select *
                            from the (select cast(cc.price_details as
                                                  pe_tbl_price_exposure)
                                        from dual))
            loop
              vc_error_loc := '8';
              --insert to the DPED_DRT_PRICE_EXP_DETAILS table
            
              insert into dped_drt_price_exp_details
                (process_id,
                 internal_derivative_ref_no,
                 fb_order_seq,
                 instrument_id,
                 fb_period_type,
                 fb_period_sub_type,
                 fb_period_month,
                 fb_period_year,
                 fb_period_from_date,
                 fb_period_to_date,
                 fb_off_day_price,
                 price_date,
                 price_drid,
                 price_month,
                 price_month_date,
                 is_holiday,
                 price,
                 price_unit_id,
                 price_unit,
                 quotes_price_date,
                 avg_fx_rate,
                 price_exp_status,
                 exp_quantity,
                 exp_quantity_unit_id,
                 exp_quantity_unit,
                 exp_value,
                 exp_cur_id,
                 exp_cur_code,
                 inst_price_status,
                 inst_price_qp_status,
                 remarks)
              values
                (pc_process_id,
                 cur_derivative_row.internal_derivative_ref_no,
                 cc.fb_order_seq,
                 cc_qp.instrument_id,
                 cc.fb_period_type,
                 cc.fb_period_sub_type,
                 cc.period_month,
                 cc.period_year,
                 cc.period_from_date,
                 cc.period_to_date,
                 cc.off_day_price,
                 cc_qp.price_date,
                 cc_qp.price_drid,
                 cc_qp.price_month,
                 cc_qp.price_month_date,
                 cc_qp.is_holiday,
                 cc_qp.price,
                 cc_qp.price_unit_id,
                 cc_qp.price_unit,
                 cc_qp.quotes_price_date,
                 cc_qp.avg_fx_rate,
                 cc_qp.price_exp_status,
                 cc_qp.exp_quantity,
                 cc_qp.exp_quantity_unit_id,
                 cc_qp.exp_quantity_unit,
                 cc_qp.exp_value,
                 cc_qp.exp_cur_id,
                 cc_qp.exp_cur_code,
                 cc.price_status,
                 cc.price_qp_status,
                 cc_qp.status_remarks);
              vc_error_number := 9;
            
            end loop;
          
          end if;
        
        end loop;
      
      end if;
    end loop;
    commit;
    /*insert into the dpe_derivative_price_exposure*/
  
    insert into dpe_derivative_price_exposure
      (corporate_id,
       process_id,
       process_date,
       internal_derivative_ref_no,
       derivative_ref_no,
       leg_no,
       trade_type,
       exposure_type,
       price_status,
       instrumnet_id,
       instrument_name,
       instrument_month_year,
       instrument_month_date,
       exposure_quantity,
       quantity_unit_id,
       quantity_unit,
       final_price,
       final_price_unit,
       final_price_unit_id,
       final_price_staus,
       final_price_qp_status,
       total_value,
       value_cur_id,
       value_cur_code,
       setup_remarks)
      select dt.corporate_id corporate_id,
             dped.process_id process_id,
             pd_trade_date process_date,
             dt.internal_derivative_ref_no internal_derivative_ref_no,
             dt.derivative_ref_no derivative_ref_no,
             dt.leg_no leg_no,
             decode(dt.trade_type, 'Sell', 'S', 'P') trade_type,
             'Position' exposure_type,
             dped.price_exp_status price_status,
             dped.instrument_id instrument_id,
             dim.instrument_name instrument_name,
             dped.price_month instrument_month_year,
             dped.price_month_date instrument_month_date,
             sum(dped.exp_quantity) exposure_quantity,
             dped.exp_quantity_unit_id quantity_unit_id,
             dped.exp_quantity_unit quantity_unit,
             (case
               when sum(dped.exp_quantity) <> 0 then
                sum(dped.exp_value) / sum(dped.exp_quantity)
               else
                null
             end) fina_price,
             dped.exp_cur_code || '/' || dped.exp_quantity_unit final_price_unit,
             ppu.internal_price_unit_id final_price_unit_id,
             dped.price_exp_status final_price_staus,
             null final_price_qp_status,
             sum(dped.exp_value) total_value,
             dped.exp_cur_id value_cur_id,
             dped.exp_cur_code value_cur_code,
             null remark
        from dped_drt_price_exp_details dped,
             dim_der_instrument_master  dim,
             dt_derivative_trade        dt,
             ppu_product_price_units    ppu,
             pum_price_unit_master      pum
       where dped.process_id = pc_process_id
         and dped.internal_derivative_ref_no =
             dt.internal_derivative_ref_no
         and dped.process_id = dt.process_id
         and dped.instrument_id = dim.instrument_id
         and dped.exp_cur_id = pum.cur_id
         and dped.exp_quantity_unit_id = pum.weight_unit_id
         and nvl(pum.weight, 1) = 1
         and ppu.product_id = dt.product_id
         and pum.is_active = 'Y'
         and pum.is_deleted = 'N'
         and ppu.is_active = 'Y'
         and ppu.is_deleted = 'N'
         and ppu.price_unit_id = pum.price_unit_id
       group by dt.corporate_id,
                dped.process_id,
                dt.internal_derivative_ref_no,
                dt.derivative_ref_no,
                dt.leg_no,
                dt.trade_type,
                dped.price_exp_status,
                dped.instrument_id,
                dim.instrument_name,
                dped.price_month,
                dped.price_month_date,
                dped.exp_quantity_unit_id,
                dped.exp_quantity_unit,
                dped.exp_cur_id,
                dped.price_unit_id,
                ppu.internal_price_unit_id,
                dped.exp_cur_code;
    vc_error_loc    := '9';
    vc_error_number := 10;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'sp_calc_price_exposure',
                                                           'M2M-013' ||
                                                           '  vc_error_number ' ||
                                                           vc_error_number,
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           vc_error_loc,
                                                           'DAte is  ' ||
                                                           pd_trade_date ||
                                                           'pc_process_id is ' ||
                                                           pc_process_id ||
                                                           'pc_process ' ||
                                                           pc_process ||
                                                           'pc_user_id ' ||
                                                           pc_user_id,
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end sp_calc_price_exposure;

  procedure sp_calc_average_unrealized_pnl(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_process      varchar2,
                                           pc_user_id      varchar2,
                                           pc_dbd_id       varchar2) as
  
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    cursor cur_avg is
      select dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             pd_trade_date eod_trade_date,
             dt.trade_date,
             dt.corporate_id,
             ak.corporate_name,
             dt.trader_id,
             gab.firstname || gab.lastname tradername,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dt.dr_id,
             dim.instrument_id,
             dim.underlying_instrument_id,
             dim.instrument_name,
             dim.instrument_symbol,
             dim.instrument_type_id,
             irm.instrument_type,
             irm.instrument_display_name,
             dim.instrument_sub_type_id,
             istm.instrument_sub_type,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             pdd.traded_on,
             pdd.product_id,
             pdm.product_desc,
             emt.exchange_id,
             emt.exchange_name,
             emt.exchange_code,
             pdd.lot_size,
             pdd.lot_size_unit_id,
             qum.qty_unit lot_size_qty_unit,
             drm.price_point_id,
             pp.price_point_name,
             drm.period_type_id,
             pm.period_type_name,
             pm.period_type_display_name,
             drm.period_month,
             drm.period_year,
             drm.period_date,
             drm.prompt_date,
             drm.dr_id_name,
             dt.trade_type,
             dt.deal_type_id,
             dtm.deal_type_name,
             dtm.deal_type_display_name,
             dtm.is_multiple_leg_involved,
             null deal_category,
             null deal_sub_category,
             dt.strategy_id,
             css.strategy_name,
             css.description,
             sdm.strategy_def_name,
             ak.groupid,
             gcd.groupname,
             dt.purpose_id,
             dpm.purpose_name,
             dpm.purpose_display_name,
             dt.external_ref_no,
             dt.cp_profile_id,
             phd_cp.companyname cp_name,
             dt.master_contract_id,
             dt.broker_profile_id,
             phd_broker.companyname broker_name,
             dt.broker_account_id,
             bca_broker.account_name broker_account_name,
             bca_broker.account_type broker_account_type,
             dt.broker_comm_type_id,
             dt.broker_comm_amt,
             dt.broker_comm_cur_id,
             cm_broker_cur.cur_code broker_cur_code,
             dt.clearer_profile_id,
             phd_clearer.companyname clearer_name,
             dt.clearer_account_id,
             bca_clearer.account_name clearer_account_name,
             bca_clearer.account_type clearer_account_type,
             dt.clearer_comm_type_id,
             dt.clearer_comm_amt,
             dt.clearer_comm_cur_id,
             cm_clearer.cur_code clearer_cur_code,
             dt.product_id product,
             pdm.product_desc productdesc,
             dt.quality_id,
             dt.quantity_unit_id,
             dt.total_lots,
             dt.total_quantity,
             dt.open_lots,
             dt.open_quantity,
             dt.exercised_lots,
             dt.exercised_quantity,
             dt.expired_lots,
             dt.expired_quantity,
             dt.trade_price_type_id,
             dt.trade_price,
             dt.trade_price_unit_id,
             dt.premium_discount,
             dt.premium_discount_price_unit_id,
             pum_pd.cur_id pd_cur_id,
             cm_pd.cur_code pd_cur_code,
             pum_pd.weight pd_weight,
             pum_pd.weight_unit_id pd_weight_unit_id,
             qum_pd.qty_unit pd_qty_unit,
             dt.premium_due_date,
             dt.available_price_id,
             apm.available_price_name,
             dt.average_from_date,
             dt.average_to_date,
             dt.nominee_profile_id,
             phd_nominee.companyname nominee_name,
             dt.leg_no,
             dt.option_expiry_date,
             dt.parent_int_derivative_ref_no,
             dt.market_location_country,
             dt.market_location_state,
             dt.market_location_city,
             dt.is_what_if,
             dt.price_source_id,
             dt.payment_term,
             pym.payment_term payment_term_name,
             dt.payment_due_date,
             dt.closed_lots,
             dt.closed_quantity,
             null as is_new_trade_date,
             dt.status,
             dt.settlement_cur_id,
             cm_settlement.cur_code settlement_cur_code,
             null as in_out_at_money_status,
             null as in_out_at_money_value,
             null as exercise_date,
             null as expiry_date,
             gcd_group.group_cur_id,
             cm_gcd.cur_code group_cur_code,
             gcd_group.group_qty_unit_id,
             qum_gcd.qty_unit gcd_qty_unit,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             (case
               when irm.instrument_type in ('Option Put', 'Option Call') then
                'Option'
               else
                irm.instrument_type
             end) as parent_instrument_type,
             null as clearer_comm_in_base,
             null as broker_comm_in_base,
             null as clearer_exch_rate,
             null as broker_exch_rate,
             null as trade_cur_to_base_exch_rate,
             'Unrealized' as pnl_type,
             null as pnl_in_base_cur,
             null as pnl_in_trade_cur,
             cm_base.cur_id as base_cur_id,
             ak.base_currency_name base_cur_code,
             null as underlying_future_dr_id,
             null as underlying_future_dr_id_name,
             null as underlying_future_expiry_date,
             null as underlying_future_quote_price,
             null as underlying_fut_price_unit_id,
             pc_process_id process_id,
             div.price_source_id val_price_source_id
      
        from dt_derivative_trade            dt,
             ak_corporate                   ak,
             ak_corporate_user              aku,
             gab_globaladdressbook          gab,
             cpc_corporate_profit_center    cpc,
             drm_derivative_master          drm,
             dim_der_instrument_master      dim,
             irm_instrument_type_master     irm,
             istm_instr_sub_type_master     istm,
             pdd_product_derivative_def     pdd,
             pdm_productmaster              pdm,
             emt_exchangemaster             emt,
             qum_quantity_unit_master       qum,
             pp_price_point                 pp,
             pm_period_master               pm,
             dtm_deal_type_master           dtm,
             css_corporate_strategy_setup   css,
             sdm_strategy_definition_master sdm,
             gcd_groupcorporatedetails      gcd,
             dpm_derivative_purpose_master  dpm,
             phd_profileheaderdetails       phd_cp,
             phd_profileheaderdetails       phd_broker,
             bca_broker_clearer_account     bca_broker,
             cm_currency_master             cm_broker_cur,
             phd_profileheaderdetails       phd_clearer,
             bca_broker_clearer_account     bca_clearer,
             cm_currency_master             cm_clearer,
             pum_price_unit_master          pum_pd,
             cm_currency_master             cm_pd,
             qum_quantity_unit_master       qum_pd,
             apm_available_price_master     apm,
             phd_profileheaderdetails       phd_nominee,
             pym_payment_terms_master       pym,
             cm_currency_master             cm_settlement,
             gcd_groupcorporatedetails      gcd_group,
             cm_currency_master             cm_gcd,
             qum_quantity_unit_master       qum_gcd,
             qum_quantity_unit_master       qum_pdm,
             cm_currency_master             cm_base,
             div_der_instrument_valuation   div
      
       where dt.corporate_id = ak.corporate_id
         and dt.trader_id = aku.user_id
         and aku.gabid = gab.gabid
         and dt.profit_center_id = cpc.profit_center_id
         and dt.dr_id = drm.dr_id(+)
         and drm.instrument_id = dim.instrument_id(+)
         and dim.instrument_type_id = irm.instrument_type_id(+)
         and dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
         and dim.product_derivative_id = pdd.derivative_def_id(+)
         and pdd.product_id = pdm.product_id(+)
         and pdd.exchange_id = emt.exchange_id(+)
         and pdd.lot_size_unit_id = qum.qty_unit_id(+)
         and drm.price_point_id = pp.price_point_id(+)
         and drm.period_type_id = pm.period_type_id(+)
         and dt.deal_type_id = dtm.deal_type_id
         and dt.strategy_id = css.strategy_id
         and css.strategy_def_id = sdm.strategy_def_id
         and ak.groupid = gcd.groupid
         and dt.purpose_id = dpm.purpose_id
         and dt.cp_profile_id = phd_cp.profileid(+)
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.broker_account_id = bca_broker.account_id(+)
         and dt.broker_comm_cur_id = cm_broker_cur.cur_id(+)
         and dt.clearer_profile_id = phd_clearer.profileid(+)
         and dt.clearer_account_id = bca_clearer.account_id(+)
         and dt.clearer_comm_cur_id = cm_clearer.cur_id(+)
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and pum_pd.cur_id = cm_pd.cur_id(+)
         and pum_pd.weight_unit_id = qum_pd.qty_unit_id(+)
         and dt.available_price_id = apm.available_price_id
         and dt.nominee_profile_id = phd_nominee.profileid(+)
         and dt.payment_term = pym.payment_term_id(+)
         and dt.settlement_cur_id = cm_settlement.cur_id(+)
         and ak.groupid=gcd_group.groupid
         and gcd_group.group_cur_id = cm_gcd.cur_id
         and gcd_group.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id(+)
         and ak.base_currency_name = cm_base.cur_code
         and dim.underlying_instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and irm.instrument_type = 'Average'
         and dt.is_what_if = 'N'
         and dt.corporate_id = pc_corporate_id
         and dt.trade_date <= pd_trade_date
         and dt.process_id = pc_process_id;
  
    vn_mk_premium_trade_prm_cur  number;
    vn_trade_premium_trade_cur   number;
    vn_total_market_value_pd_cur number;
    vn_total_trade_pre_trdae_cur number;
    vn_market_price_trade_cur    number;
    vn_market_premium            number;
    vc_market_pre_price_unit_id  varchar2(20);
    vn_qty_in_premium_wt_unit    number;
    vn_pnl_value_in_trade_cur    number;
    vn_premium_to_base_exch_rate number;
    vn_pnl_value_in_base_cur     number;
    vn_net_pnl_in_base_cur       number;
    vn_total_trade_pre_base_cur  number;
    vc_period                    varchar2(50);
    vc_premium_main_cur_id       varchar2(15);
    vc_premium_main_cur_code     varchar2(15);
    vc_cur_id_factor             number;
    vc_caluclate_set_dr_id       varchar2(15);
    vc_caluclate_val_dr_id       varchar2(15);
    vc_caluclate_mar_dr_id       varchar2(15);
    vn_caluclate_set_price       number;
    vn_caluclate_val_price       number;
    vc_cal_set_price_unit_id     varchar2(15);
    vc_cal_val_price_unit_id     varchar2(15);
    qp_startdate                 date;
    qp_enddate                   date;
    vn_count_set_qp              number;
    vn_total_set_price           number;
    vn_total_val_price           number;
    vn_count_val_qp              number;
    vd_3rd_wed_of_qp             varchar2(15);
    vc_is_valid_prompt_date      varchar2(10);
    vc_holiday                   char(1);
    vn_avg_set_price             number;
    vn_avg_val_price             number;
    vn_avg_contract_price        number;
    vn_market_price              number;
    vc_market_price_unit_id      varchar2(15);
    vn_total_market_price        number;
    vn_paid_premium              number;
    vn_total_trade_price         number;
    vn_trade_price_trade_cur     number;
    vc_error_message             varchar2(200);
    workings_days                number;
    vd_quotes_date               date;
  
  begin
    for cur_avg_rows in cur_avg
    loop
      vn_avg_contract_price       := null;
      vn_total_trade_price        := null;
      vn_market_premium           := null;
      vc_market_pre_price_unit_id := null;
      vn_market_price             := null;
      vc_market_price_unit_id     := null;
      vc_cal_set_price_unit_id    := null;
    
      if cur_avg_rows.eod_trade_date >= cur_avg_rows.average_from_date and
         cur_avg_rows.eod_trade_date <= cur_avg_rows.average_to_date then
        vc_period := 'During QP';
      elsif cur_avg_rows.eod_trade_date < cur_avg_rows.average_from_date and
            cur_avg_rows.eod_trade_date < cur_avg_rows.average_to_date then
        vc_period := 'Before QP';
      elsif cur_avg_rows.eod_trade_date > cur_avg_rows.average_from_date and
            cur_avg_rows.eod_trade_date > cur_avg_rows.average_to_date then
        vc_period := 'After QP';
      end if;
    
      vn_qty_in_premium_wt_unit := f_get_converted_quantity(cur_avg_rows.product_id,
                                                            cur_avg_rows.quantity_unit_id,
                                                            cur_avg_rows.pd_weight_unit_id,
                                                            cur_avg_rows.total_quantity);
    
      pkg_general.sp_get_base_cur_detail(cur_avg_rows.pd_cur_id,
                                         vc_premium_main_cur_id,
                                         vc_premium_main_cur_code,
                                         vc_cur_id_factor);
    
      vn_premium_to_base_exch_rate := f_currency_exchange_rate(pd_trade_date,
                                                               pc_corporate_id,
                                                               cur_avg_rows.prompt_date,
                                                               vc_premium_main_cur_id,
                                                               cur_avg_rows.base_cur_id);
    
      ---- finding Market premium 
    
      begin
        select price,
               price_unit_id
          into vn_market_premium,
               vc_market_pre_price_unit_id
          from eodeom_derivative_quote_detail eod_dq
         where eod_dq.dr_id = cur_avg_rows.dr_id
           and eod_dq.price_source_id = cur_avg_rows.price_source_id
           and eod_dq.available_price_id = cur_avg_rows.available_price_id
           and eod_dq.eodeom_trade_date = pd_trade_date
           and eod_dq.process_id = pc_process_id
           and eod_dq.corporate_id = pc_corporate_id;
      exception
        when no_data_found then
          vn_market_premium           := null;
          vc_market_pre_price_unit_id := null;
        when others then
          vc_error_message := 'Missing Data for Market Premium';
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure sp_calc_avg_price',
                                                               'M2M-013',
                                                               vc_error_message ||
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
    
      vn_mk_premium_trade_prm_cur := f_get_converted_price_pum(cur_avg_rows.corporate_id,
                                                               vn_market_premium,
                                                               vc_market_pre_price_unit_id,
                                                               cur_avg_rows.premium_discount_price_unit_id,
                                                               pd_trade_date,
                                                               cur_avg_rows.product_id);
    
      --- finding market dr_id
    
      begin
        select drm.dr_id
          into vc_caluclate_mar_dr_id
          from drm_derivative_master drm
         where drm.instrument_id = cur_avg_rows.underlying_instrument_id
           and drm.prompt_date = cur_avg_rows.prompt_date
           and drm.price_point_id is null
           and rownum <= 1
           and drm.is_deleted = 'N';
      exception
        when no_data_found then
          vc_caluclate_mar_dr_id := null;
        when others then
          vc_error_message := 'Missing Data for Market DR-ID';
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure sp_calc_avg_price',
                                                               'M2M-013',
                                                               vc_error_message ||
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
    
      --- finding market price
      begin
      
        select price,
               price_unit_id
          into vn_market_price,
               vc_market_price_unit_id
          from eodeom_derivative_quote_detail eod_dq
         where eod_dq.dr_id = vc_caluclate_mar_dr_id
           and eod_dq.price_source_id = cur_avg_rows.val_price_source_id
           and eod_dq.available_price_id = cur_avg_rows.available_price_id
           and eod_dq.process_id = pc_process_id
           and eod_dq.corporate_id = pc_corporate_id;
      exception
        when no_data_found then
          vn_market_price         := 0;
          vc_market_price_unit_id := null;
        when others then
          vc_error_message := 'Missing Data for Market Price';
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure sp_calc_avg_price',
                                                               'M2M-013',
                                                               vc_error_message ||
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
    
      vn_market_price_trade_cur := f_get_converted_price_pum(cur_avg_rows.corporate_id,
                                                             vn_market_price,
                                                             vc_market_price_unit_id,
                                                             cur_avg_rows.premium_discount_price_unit_id,
                                                             pd_trade_date,
                                                             cur_avg_rows.product_id);
    
      if vc_period = 'Before QP' then
        vn_total_market_value_pd_cur := vn_mk_premium_trade_prm_cur *
                                        vn_qty_in_premium_wt_unit *
                                        vc_cur_id_factor;
        vn_trade_premium_trade_cur   := cur_avg_rows.premium_discount;
        vn_total_trade_pre_trdae_cur := vn_trade_premium_trade_cur *
                                        vn_qty_in_premium_wt_unit *
                                        vc_cur_id_factor;
      
        if cur_avg_rows.trade_type = 'Buy' then
          vn_pnl_value_in_trade_cur := vn_total_market_value_pd_cur -
                                       vn_total_trade_pre_trdae_cur;
        else
          vn_pnl_value_in_trade_cur := vn_total_trade_pre_trdae_cur -
                                       vn_total_market_value_pd_cur;
        end if;
      
        vn_total_trade_pre_base_cur := vn_total_trade_pre_trdae_cur *
                                       vn_premium_to_base_exch_rate;
      
        vn_pnl_value_in_base_cur := vn_pnl_value_in_trade_cur *
                                    vn_premium_to_base_exch_rate;
      
        vn_net_pnl_in_base_cur := vn_pnl_value_in_base_cur;
      
        if vn_net_pnl_in_base_cur is null then
          vn_net_pnl_in_base_cur := 0;
        end if;
      
        if vn_pnl_value_in_trade_cur is null then
          vn_pnl_value_in_trade_cur := 0;
        end if;
      
      elsif vc_period = 'During QP' then
        qp_startdate       := cur_avg_rows.average_from_date;
        qp_enddate         := cur_avg_rows.average_to_date;
        vn_count_set_qp    := 0;
        vn_total_set_price := 0;
      
        --- finding settlement DR_ID                                         
        begin
          select drm.dr_id
            into vc_caluclate_set_dr_id
            from drm_derivative_master drm
           where drm.instrument_id = cur_avg_rows.underlying_instrument_id
             and drm.price_point_id = cur_avg_rows.price_point_id
             and rownum <= 1
             and drm.is_deleted = 'N';
        exception
          when no_data_found then
            vc_caluclate_set_dr_id := null;
          when others then
            vc_error_message := 'Missing Data for Settlement DR-ID';
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure sp_calc_avg_price',
                                                                 'M2M-013',
                                                                 vc_error_message ||
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
      
        while qp_startdate <= pd_trade_date
        loop
          ---- finding holidays       
          if f_is_day_holiday(cur_avg_rows.underlying_instrument_id,
                              qp_startdate) then
            vc_holiday := 'Y';
          else
            vc_holiday := 'N';
          end if;
        
          --- Finding  settlement Price
          if vc_holiday = 'N' then
            begin
              select price,
                     price_unit_id
                into vn_caluclate_set_price,
                     vc_cal_set_price_unit_id
                from (select dqd.price,
                             dqd.price_unit_id,
                             rank() over(order by dq.trade_date desc nulls last) as td_rank
                        from dqd_derivative_quote_detail dqd,
                             dq_derivative_quotes        dq
                       where dqd.dq_id = dq.dq_id
                         and dqd.available_price_id =
                             cur_avg_rows.available_price_id
                         and dq.corporate_id = cur_avg_rows.corporate_id
                         and dq.trade_date <= qp_startdate
                         and dq.instrument_id =
                             cur_avg_rows.underlying_instrument_id
                         and dq.trade_date <= pd_trade_date
                         and dq.price_source_id =
                             cur_avg_rows.price_source_id
                         and dqd.dr_id = vc_caluclate_set_dr_id
                         and dq.dbd_id = dqd.dbd_id
                         and dq.dbd_id = pc_dbd_id
                         and dq.is_deleted = 'N'
                         and dqd.is_deleted = 'N')
               where td_rank = 1;
            exception
              when no_data_found then
                vn_caluclate_set_price   := 0;
                vc_cal_set_price_unit_id := null;
              when others then
                vc_error_message := 'Missing Data for Settlement Price';
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_calc_avg_price',
                                                                     'M2M-013',
                                                                     vc_error_message ||
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
            vn_total_set_price := vn_total_set_price +
                                  vn_caluclate_set_price;
            vn_count_set_qp    := vn_count_set_qp + 1;
          end if;
          qp_startdate := qp_startdate + 1;
        end loop;
      
        ---- get third wednesday of after QP period
        --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
      
        vd_3rd_wed_of_qp := f_get_next_day(qp_enddate, 'Wed', 3);
        while true
        loop
          if f_is_day_holiday(cur_avg_rows.underlying_instrument_id,
                              vd_3rd_wed_of_qp) then
            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
          else
            exit;
          end if;
        end loop;
      
        --- get 3rd wednesday  before QP period 
        -- Get the quotation date = Trade Date +2 working Days
        if vd_3rd_wed_of_qp < pd_trade_date then
          workings_days  := 0;
          vd_quotes_date := pd_trade_date + 1;
          while workings_days <> 2
          loop
            if f_is_day_holiday(cur_avg_rows.underlying_instrument_id,
                                vd_quotes_date) then
              vd_quotes_date := vd_quotes_date + 1;
            else
              workings_days := workings_days + 1;
              if workings_days <> 2 then
                vd_quotes_date := vd_quotes_date + 1;
              end if;
            end if;
          end loop;
          vd_3rd_wed_of_qp := vd_quotes_date;
        end if;
      
        --- finding  valuation dr_id
        begin
          select drm.dr_id
            into vc_caluclate_val_dr_id
            from drm_derivative_master drm
           where drm.instrument_id = cur_avg_rows.underlying_instrument_id
             and drm.prompt_date = vd_3rd_wed_of_qp
             and rownum <= 1
             and drm.is_deleted = 'N';
        exception
          when no_data_found then
            vc_caluclate_val_dr_id := null;
          when others then
            vc_error_message := 'Missing Data for Valuation DR-ID';
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure sp_calc_avg_price',
                                                                 'M2M-013',
                                                                 vc_error_message ||
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
        --- finding valuation price
      
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_caluclate_val_price,
                 vc_cal_val_price_unit_id
            from dq_derivative_quotes        dq,
                 dqd_derivative_quote_detail dqd
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_caluclate_val_dr_id
             and dq.dbd_id = dqd.dbd_id
             and dq.dbd_id = pc_dbd_id
             and dqd.available_price_id = cur_avg_rows.available_price_id
             and dq.price_source_id = cur_avg_rows.val_price_source_id
             and dq.trade_date = pd_trade_date
             and dq.is_deleted = 'N'
             and dqd.is_deleted = 'N';
        exception
          when no_data_found then
            vn_caluclate_val_price := 0;
            vc_caluclate_val_dr_id := null;
          when others then
            vc_error_message := 'Missing Data for Valuation Price';
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure sp_calc_avg_price',
                                                                 'M2M-013',
                                                                 vc_error_message ||
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
      
        vn_total_val_price := 0;
        vn_count_val_qp    := 0;
      
        while qp_startdate <= qp_enddate
        loop
          ---- finding holidays       
          if f_is_day_holiday(cur_avg_rows.underlying_instrument_id,
                              qp_startdate) then
            vc_holiday := 'Y';
          else
            vc_holiday := 'N';
          end if;
        
          if vc_holiday = 'N' then
            vn_total_val_price := vn_total_val_price +
                                  vn_caluclate_val_price;
            vn_count_val_qp    := vn_count_val_qp + 1;
          end if;
          qp_startdate := qp_startdate + 1;
        end loop;
      
        vn_total_trade_price     := (vn_total_set_price +
                                    vn_total_val_price) /
                                    (vn_count_set_qp + vn_count_val_qp);
        vn_trade_price_trade_cur := f_get_converted_price_pum(cur_avg_rows.corporate_id,
                                                              vn_total_trade_price,
                                                              vc_cal_val_price_unit_id,
                                                              cur_avg_rows.premium_discount_price_unit_id,
                                                              pd_trade_date,
                                                              cur_avg_rows.product_id);
      
        vn_paid_premium       := cur_avg_rows.premium_discount;
        vn_avg_contract_price := (vn_trade_price_trade_cur +
                                 vn_paid_premium) * vc_cur_id_factor;
      
        vn_total_market_price := vn_market_price_trade_cur +
                                 vn_mk_premium_trade_prm_cur *
                                 vc_cur_id_factor;
      
        if cur_avg_rows.trade_type = 'Buy' then
          vn_pnl_value_in_trade_cur := (vn_total_market_price -
                                       vn_avg_contract_price) *
                                       vn_qty_in_premium_wt_unit;
        else
          vn_pnl_value_in_trade_cur := (vn_avg_contract_price -
                                       vn_total_market_price) *
                                       vn_qty_in_premium_wt_unit;
        end if;
      
        vn_pnl_value_in_base_cur := vn_pnl_value_in_trade_cur *
                                    vn_premium_to_base_exch_rate;
      
        vn_net_pnl_in_base_cur := vn_pnl_value_in_base_cur;
      
        if vn_net_pnl_in_base_cur is null then
          vn_net_pnl_in_base_cur := 0;
        end if;
      
        if vn_pnl_value_in_trade_cur is null then
          vn_pnl_value_in_trade_cur := 0;
        end if;
      
      elsif vc_period = 'After QP' then
        qp_startdate       := cur_avg_rows.average_from_date;
        qp_enddate         := cur_avg_rows.average_to_date;
        vn_total_set_price := 0;
        vn_count_set_qp    := 0;
        --- finding settlement DR_ID  
        begin
          select drm.dr_id
            into vc_caluclate_set_dr_id
            from drm_derivative_master drm
           where drm.instrument_id = cur_avg_rows.underlying_instrument_id
             and drm.price_point_id = cur_avg_rows.price_point_id
             and rownum <= 1
             and drm.is_deleted = 'N';
        exception
          when no_data_found then
            vc_caluclate_set_dr_id := null;
          when others then
            vc_error_message := 'Missing Data for Settlement DR-ID';
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure sp_calc_avg_price',
                                                                 'M2M-013',
                                                                 vc_error_message ||
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
      
        while qp_startdate <= qp_enddate
        loop
          ---- finding holidays       
          if f_is_day_holiday(cur_avg_rows.underlying_instrument_id,
                              qp_startdate) then
            vc_holiday := 'Y';
          else
            vc_holiday := 'N';
          end if;
        
          --- Finding  settlement Price
          if vc_holiday = 'N' then
            begin
              select price,
                     price_unit_id
                into vn_caluclate_set_price,
                     vc_cal_set_price_unit_id
                from (select dqd.price,
                             dqd.price_unit_id,
                             rank() over(order by dq.trade_date desc nulls last) as td_rank
                        from dqd_derivative_quote_detail dqd,
                             dq_derivative_quotes        dq
                       where dqd.dq_id = dq.dq_id
                         and dqd.available_price_id =
                             cur_avg_rows.available_price_id
                         and dq.corporate_id = cur_avg_rows.corporate_id
                         and dq.trade_date <= qp_startdate
                         and dq.instrument_id =
                             cur_avg_rows.underlying_instrument_id
                         and dq.trade_date <= pd_trade_date
                         and dq.price_source_id =
                             cur_avg_rows.price_source_id
                         and dqd.dr_id = vc_caluclate_set_dr_id
                         and dq.dbd_id = dqd.dbd_id
                         and dq.dbd_id = pc_dbd_id
                         and dq.is_deleted = 'N'
                         and dqd.is_deleted = 'N')
               where td_rank = 1;
            exception
              when no_data_found then
                vn_caluclate_set_price   := 0;
                vc_cal_set_price_unit_id := null;
              when others then
                vc_error_message := 'Missing Data for Settlement Price';
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_calc_avg_price',
                                                                     'M2M-013',
                                                                     vc_error_message ||
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
            vn_total_set_price := vn_total_set_price +
                                  vn_caluclate_set_price;
            vn_count_set_qp    := vn_count_set_qp + 1;
          end if;
          qp_startdate := qp_startdate + 1;
        end loop;
      
        vn_total_trade_price     := vn_total_set_price / vn_count_set_qp;
        vn_trade_price_trade_cur := f_get_converted_price_pum(cur_avg_rows.corporate_id,
                                                              vn_total_trade_price,
                                                              vc_cal_set_price_unit_id,
                                                              cur_avg_rows.premium_discount_price_unit_id,
                                                              pd_trade_date,
                                                              cur_avg_rows.product_id);
      
        vn_paid_premium       := cur_avg_rows.premium_discount;
        vn_avg_contract_price := (vn_trade_price_trade_cur +
                                 vn_paid_premium) * vc_cur_id_factor;
      
        vn_total_market_price := (vn_market_price_trade_cur +
                                 vn_mk_premium_trade_prm_cur) *
                                 vc_cur_id_factor;
      
        if cur_avg_rows.trade_type = 'Buy' then
          vn_pnl_value_in_trade_cur := (vn_total_market_price -
                                       vn_avg_contract_price) *
                                       vn_qty_in_premium_wt_unit;
        else
          vn_pnl_value_in_trade_cur := (vn_avg_contract_price -
                                       vn_total_market_price) *
                                       vn_qty_in_premium_wt_unit;
        end if;
      
        vn_pnl_value_in_base_cur := vn_pnl_value_in_trade_cur *
                                    vn_premium_to_base_exch_rate;
      
        vn_net_pnl_in_base_cur := vn_pnl_value_in_base_cur;
      
        if vn_net_pnl_in_base_cur is null then
          vn_net_pnl_in_base_cur := 0;
        end if;
      
        if vn_pnl_value_in_trade_cur is null then
          vn_pnl_value_in_trade_cur := 0;
        end if;
      
      end if;
    
      insert into dpd_derivative_pnl_daily
        (internal_derivative_ref_no,
         derivative_ref_no,
         eod_trade_date,
         trade_date,
         corporate_id,
         corporate_name,
         trader_id,
         trader_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         dr_id,
         instrument_id,
         instrument_name,
         instrument_symbol,
         instrument_type_id,
         instrument_type,
         instrument_type_name,
         instrument_sub_type_id,
         instrument_sub_type,
         derivative_def_id,
         derivative_def_name,
         derivative_traded_on,
         derivative_prodct_id,
         derivative_prodct_name,
         exchange_id,
         exchange_name,
         exchange_code,
         lot_size,
         lot_size_unit_id,
         lot_size_unit,
         price_point_id,
         price_point_name,
         period_type_id,
         period_type_name,
         period_type_display_name,
         period_month,
         period_year,
         period_date,
         prompt_date,
         dr_id_name,
         trade_type,
         deal_type_id,
         deal_type_name,
         deal_type_display_name,
         is_multiple_leg_involved,
         deal_category,
         deal_sub_category,
         strategy_id,
         strategy_name,
         strategy_desc,
         strategy_def_name,
         group_id,
         group_name,
         purpose_id,
         purpose_name,
         purpose_display_name,
         external_ref_no,
         cp_profile_id,
         cp_name,
         master_contract_id,
         broker_profile_id,
         broker_name,
         broker_account_id,
         broker_account_name,
         broker_account_type,
         broker_comm_type_id,
         broker_comm_amt,
         broker_comm_cur_id,
         broker_comm_cur_code,
         clearer_profile_id,
         clearer_name,
         clearer_account_id,
         clearer_account_name,
         clearer_account_type,
         clearer_comm_type_id,
         clearer_comm_amt,
         clearer_comm_cur_id,
         clearer_comm_cur_code,
         product_id,
         product_name,
         quality_id,
         quantity_unit_id,
         total_lots,
         total_quantity,
         open_lots,
         open_quantity,
         exercised_lots,
         exercised_quantity,
         expired_lots,
         expired_quantity,
         trade_price_type_id,
         trade_price,
         trade_price_unit_id,
         premium_discount,
         premium_discount_price_unit_id,
         pd_price_cur_id,
         pd_price_cur_code,
         pd_price_weight,
         pd_price_weight_unit_id,
         pd_price_weight_unit,
         premium_due_date,
         nominee_profile_id,
         nominee_name,
         leg_no,
         option_expiry_date,
         settlement_price,
         sett_price_unit_id,
         parent_int_derivative_ref_no,
         market_location_country,
         market_location_state,
         market_location_city,
         is_what_if,
         payment_term_id,
         payment_term,
         payment_due_date,
         closed_lots,
         closed_quantity,
         is_new_trade,
         status,
         settlement_cur_id,
         settlement_cur_code,
         in_out_at_money_status,
         in_out_at_money_value,
         exercise_date,
         expiry_date,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         parent_instrument_type,
         --clearer_comm_in_base,
         --broker_comm_in_base,
         --clearer_exch_rate,
         --broker_exch_rate,
         trade_cur_to_base_exch_rate,
         pnl_type,
         pnl_in_base_cur,
         pnl_in_trade_cur,
         base_cur_id,
         base_cur_code,
         underlying_future_dr_id,
         underlying_future_dr_id_name,
         underlying_future_expiry_date,
         underlying_future_quote_price,
         underlying_fut_price_unit_id,
         process_id,
         average_from_date,
         average_to_date,
         market_premium,
         market_premium_price_unit_id,
         trade_main_cur_id,
         trade_main_cur_code,
         qp_period,
         avg_contract_price,
         avg_contract_price_unit_id)
      
      values
        (cur_avg_rows.internal_derivative_ref_no,
         cur_avg_rows.derivative_ref_no,
         cur_avg_rows.eod_trade_date,
         cur_avg_rows.trade_date,
         cur_avg_rows.corporate_id,
         cur_avg_rows.corporate_name,
         cur_avg_rows.trader_id,
         cur_avg_rows.tradername,
         cur_avg_rows.profit_center_id,
         cur_avg_rows.profit_center_name,
         cur_avg_rows.profit_center_short_name,
         cur_avg_rows.dr_id,
         cur_avg_rows.instrument_id,
         cur_avg_rows.instrument_name,
         cur_avg_rows.instrument_symbol,
         cur_avg_rows.instrument_type_id,
         cur_avg_rows.instrument_type,
         cur_avg_rows.instrument_display_name,
         cur_avg_rows.instrument_sub_type_id,
         cur_avg_rows.instrument_sub_type,
         cur_avg_rows.derivative_def_id,
         cur_avg_rows.derivative_def_name,
         cur_avg_rows.traded_on,
         cur_avg_rows.product_id,
         cur_avg_rows.product_desc,
         cur_avg_rows.exchange_id,
         cur_avg_rows.exchange_name,
         cur_avg_rows.exchange_code,
         cur_avg_rows.lot_size,
         cur_avg_rows.lot_size_unit_id,
         cur_avg_rows.lot_size_qty_unit,
         cur_avg_rows.price_point_id,
         cur_avg_rows.price_point_name,
         cur_avg_rows.period_type_id,
         cur_avg_rows.period_type_name,
         cur_avg_rows.period_type_display_name,
         cur_avg_rows.period_month,
         cur_avg_rows.period_year,
         cur_avg_rows.period_date,
         cur_avg_rows.prompt_date,
         cur_avg_rows.dr_id_name,
         cur_avg_rows.trade_type,
         cur_avg_rows.deal_type_id,
         cur_avg_rows.deal_type_name,
         cur_avg_rows.deal_type_display_name,
         cur_avg_rows.is_multiple_leg_involved,
         cur_avg_rows.deal_category,
         cur_avg_rows.deal_sub_category,
         cur_avg_rows.strategy_id,
         cur_avg_rows.strategy_name,
         cur_avg_rows.description,
         cur_avg_rows.strategy_def_name,
         cur_avg_rows.groupid,
         cur_avg_rows.groupname,
         cur_avg_rows.purpose_id,
         cur_avg_rows.purpose_name,
         cur_avg_rows.purpose_display_name,
         cur_avg_rows.external_ref_no,
         cur_avg_rows.cp_profile_id,
         cur_avg_rows.cp_name,
         cur_avg_rows.master_contract_id,
         cur_avg_rows.broker_profile_id,
         cur_avg_rows.broker_name,
         cur_avg_rows.broker_account_id,
         cur_avg_rows.broker_account_name,
         cur_avg_rows.broker_account_type,
         cur_avg_rows.broker_comm_type_id,
         cur_avg_rows.broker_comm_amt,
         cur_avg_rows.broker_comm_cur_id,
         cur_avg_rows.broker_cur_code,
         cur_avg_rows.clearer_profile_id,
         cur_avg_rows.clearer_name,
         cur_avg_rows.clearer_account_id,
         cur_avg_rows.clearer_account_name,
         cur_avg_rows.clearer_account_type,
         cur_avg_rows.clearer_comm_type_id,
         cur_avg_rows.clearer_comm_amt,
         cur_avg_rows.clearer_comm_cur_id,
         cur_avg_rows.clearer_cur_code,
         cur_avg_rows.product_id,
         cur_avg_rows.product,
         cur_avg_rows.quality_id,
         cur_avg_rows.quantity_unit_id,
         cur_avg_rows.total_lots,
         cur_avg_rows.total_quantity,
         cur_avg_rows.open_lots,
         cur_avg_rows.open_quantity,
         cur_avg_rows.exercised_lots,
         cur_avg_rows.exercised_quantity,
         cur_avg_rows.expired_lots,
         cur_avg_rows.expired_quantity,
         cur_avg_rows.trade_price_type_id,
         vn_total_trade_price, -- trade price
         vc_cal_set_price_unit_id, -- trade price unit id
         cur_avg_rows.premium_discount,
         cur_avg_rows.premium_discount_price_unit_id,
         cur_avg_rows.pd_cur_id,
         cur_avg_rows.pd_cur_code,
         cur_avg_rows.pd_weight,
         cur_avg_rows.pd_weight_unit_id,
         cur_avg_rows.pd_qty_unit,
         cur_avg_rows.premium_due_date,
         cur_avg_rows.nominee_profile_id,
         cur_avg_rows.nominee_name,
         cur_avg_rows.leg_no,
         cur_avg_rows.option_expiry_date,
         vn_market_price, --- market price
         vc_market_price_unit_id, --- Market price unit id
         cur_avg_rows.parent_int_derivative_ref_no,
         cur_avg_rows.market_location_country,
         cur_avg_rows.market_location_state,
         cur_avg_rows.market_location_city,
         cur_avg_rows.is_what_if,
         cur_avg_rows.payment_term,
         cur_avg_rows.payment_term,
         cur_avg_rows.payment_due_date,
         cur_avg_rows.closed_lots,
         cur_avg_rows.closed_quantity,
         cur_avg_rows.is_new_trade_date,
         cur_avg_rows.status,
         cur_avg_rows.settlement_cur_id,
         cur_avg_rows.settlement_cur_code,
         cur_avg_rows.in_out_at_money_status,
         cur_avg_rows.in_out_at_money_value,
         cur_avg_rows.exercise_date,
         cur_avg_rows.expiry_date,
         cur_avg_rows.group_cur_id,
         cur_avg_rows.group_cur_code,
         cur_avg_rows.group_qty_unit_id,
         cur_avg_rows.gcd_qty_unit,
         cur_avg_rows.base_qty_unit_id,
         cur_avg_rows.base_qty_unit,
         cur_avg_rows.parent_instrument_type,
         --vn_clearer_comm_in_base_cur,
         --vn_broker_comm_in_base_cur,
         --vn_clr_cur_to_base_exch_rate,
         --vn_brokr_cur_to_base_exch_rate,
         vn_premium_to_base_exch_rate,
         cur_avg_rows.pnl_type,
         vn_net_pnl_in_base_cur,
         vn_pnl_value_in_trade_cur,
         cur_avg_rows.base_cur_id,
         cur_avg_rows.base_cur_code,
         cur_avg_rows.underlying_future_dr_id,
         cur_avg_rows.underlying_future_dr_id_name,
         cur_avg_rows.underlying_future_expiry_date,
         cur_avg_rows.underlying_future_quote_price,
         cur_avg_rows.underlying_fut_price_unit_id,
         cur_avg_rows.process_id,
         cur_avg_rows.average_from_date,
         cur_avg_rows.average_to_date,
         vn_market_premium, -- market premium
         vc_market_pre_price_unit_id, -- market premiun unit id
         vc_premium_main_cur_id,
         vc_premium_main_cur_code,
         vc_period,
         vn_avg_contract_price, ---contract price
         vc_cal_set_price_unit_id -- contract price unit id
         );
    
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_avg_price',
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
end; 
/
