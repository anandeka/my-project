CREATE OR REPLACE PACKAGE "PKG_PHY_PHYSICAL_PROCESS" IS

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

  procedure sp_phy_rebuild_stats;

  procedure sp_calc_contract_price(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_user_id      varchar2,
                                   pc_dbd_id       varchar2);

  procedure sp_calc_gmr_price(pc_corporate_id varchar2,
                              pd_trade_date   date,
                              pc_process_id   varchar2,
                              pc_user_id      varchar2,
                              pc_dbd_id       varchar2);

  procedure sp_calc_conc_gmr_price(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_user_id      varchar2,
                                   pc_dbd_id       varchar2);

  procedure sp_calc_contract_conc_price(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
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

  procedure sp_calc_phy_open_unreal_pnl(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2);

  procedure sp_calc_phy_opencon_unreal_pnl(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_user_id      varchar2,
                                           pc_dbd_id       varchar2);

  procedure sp_calc_phy_stock_unreal_pnl(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2);

  procedure sp_cal_phy_stok_con_unreal_pnl(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_user_id      varchar2);

  procedure sp_process_rollback(pc_corporate_id varchar2,
                                pc_process      varchar2,
                                pd_trade_date   date,
                                pc_dbd_id       varchar2,
                                pc_process_id   varchar2);

  procedure sp_calc_daily_trade_pnl(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_process_id   varchar2,
                                    pc_user_id      varchar2);

  procedure sp_calc_pnl_summary(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process_id   varchar2,
                                pc_user_id      varchar2);

  procedure sp_calc_overall_realized_pnl(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2);

  function f_get_converted_currency_amt(pc_corporate_id        in varchar2,
                                        pc_from_cur_id         in varchar2,
                                        pc_to_cur_id           in varchar2,
                                        pd_cur_date            in date,
                                        pn_amt_to_be_converted in number)
    return number;

  function f_get_next_day(p_date     in date,
                          p_day      in varchar2,
                          p_position in number) return date;

  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean;

  procedure sp_calc_risk_limits(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process_id   varchar2,
                                pc_user_id      varchar2);
  procedure sp_calc_quality_premium(pc_int_contract_item_ref_no in varchar2,
                                    pc_price_unit_id            in varchar2,
                                    pc_corporate_id             in varchar2,
                                    pd_trade_date               in date,
                                    pc_product_id               in varchar2,
                                    pc_process_id               in varchar2,
                                    pn_premium                  out number);
  procedure sp_calc_pofh_price(pc_pofh_id       varchar2,
                               pd_trade_date    date,
                               pn_price         out number,
                               pc_price_unit_id out varchar2);

end;
/
CREATE OR REPLACE PACKAGE BODY "PKG_PHY_PHYSICAL_PROCESS" IS

  procedure sp_process_run(pc_corporate_id varchar2,
                           pd_trade_date   date,
                           pc_process_id   varchar2,
                           pc_user_id      varchar2,
                           pc_process      varchar2, --eod or eom
                           pc_dbd_id       varchar2
                           ------------------------------------------------------------------------------------------
                           --        procedure name                            : sp_process_run
                           --        author                                    :
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
    --Added by Siddharth
    vc_prev_eod_id   varchar2(15);
    vc_prev_eod_date date;
    vc_prev_eom_id   varchar2(15);
    vc_prev_eom_date date;
    --Ends here
  begin
    gvc_process := pc_process;
  
    vc_err_msg := 'Before gvc_previous_process_id ';
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
    --Added by Siddharth
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
  
    if pc_process = 'EOD' then
      gvc_previous_process_id   := vc_prev_eod_id;
      gvc_previous_process_date := vc_prev_eod_date;
    else
      gvc_previous_process_id   := vc_prev_eom_id;
      gvc_previous_process_date := vc_prev_eom_date;
    end if;
    --Ends here
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
    --sp_phy_rebuild_stats;
  
    vc_err_msg := 'sp_calc_contract_price ';
  
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
    sp_calc_contract_price(pc_corporate_id,
                           pd_trade_date,
                           pc_process_id,
                           pc_user_id,
                           pc_dbd_id);
  
    -----GMR Price calculation
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
    sp_calc_gmr_price(pc_corporate_id,
                      pd_trade_date,
                      pc_process_id,
                      pc_user_id,
                      pc_dbd_id);
  
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
    sp_calc_contract_conc_price(pc_corporate_id,
                                pd_trade_date,
                                pc_process_id,
                                pc_user_id,
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
                          'sp_calc_conc_gmr_price');
    sp_calc_conc_gmr_price(pc_corporate_id,
                           pd_trade_date,
                           pc_process_id,
                           pc_user_id,
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
                          'sp_calc_secondary_cost');
    sp_calc_secondary_cost(pc_corporate_id,
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
                          'sp_calc_m2m_cost');
    vc_err_msg := 'Before calc m2m cost ';
    sp_calc_m2m_cost(pc_corporate_id,
                     pd_trade_date,
                     pc_process_id,
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
                          'sp_calc_m2m_conc_cost');
    vc_err_msg := 'Before calc m2m conc  cost ';
    sp_calc_m2m_conc_cost(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
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
                          'sp_calc_phy_open_unreal_pnl');
    vc_err_msg := 'Before open unreal pnl ';
  
    sp_calc_phy_open_unreal_pnl(pc_corporate_id,
                                pd_trade_date,
                                pc_process_id,
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
                          'sp_calc_phy_opencon_unreal_pnl');
  
    sp_calc_phy_opencon_unreal_pnl(pc_corporate_id,
                                   pd_trade_date,
                                   pc_process_id,
                                   pc_user_id,
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
                          'sp_calc_phy_stock_unreal_pnl');
  
    sp_calc_phy_stock_unreal_pnl(pc_corporate_id,
                                 pd_trade_date,
                                 pc_process_id,
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
                          'sp_cal_phy_stok_con_unreal_pnl');
  
    sp_cal_phy_stok_con_unreal_pnl(pc_corporate_id,
                                   pd_trade_date,
                                   pc_process_id,
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
                          'sp_calc_daily_trade_pnl');
    vc_err_msg := 'Before trade pnl ';
    /*  sp_calc_daily_trade_pnl(pc_corporate_id,
    pd_trade_date,
    pc_process_id,
    pc_user_id);*/
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_pnl_summary');
    /*sp_calc_pnl_summary(pc_corporate_id,
    pd_trade_date,
    pc_process_id,
    pc_user_id);*/
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_calc_overall_realized_pnl');
    /*sp_calc_overall_realized_pnl(pc_corporate_id,
    pd_trade_date,
    pc_process_id,
    pc_user_id,
    pc_process);*/
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'EOD/EOM Process Completed.....!!!!');
    vc_err_msg := 'end of physical sp process run ';
    <<cancel_process>>
    dbms_output.put_line('EOD/EOM Process Cancelled while pnl calculation');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_physical_process sp_process_run' ||
                                                           vc_err_msg,
                                                           'M2M-013',
                                                           'code:' ||
                                                           sqlcode ||
                                                           'message:' ||
                                                           sqlerrm || ' ' ||
                                                           vc_err_msg,
                                                           '',
                                                           gvc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_phy_rebuild_stats is
  begin
    sp_gather_stats('cipd_contract_item_price_daily');
    sp_gather_stats('cisc_contract_item_sec_cost');
    sp_gather_stats('gsc_gmr_sec_cost');
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

  procedure sp_calc_contract_price(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_user_id      varchar2,
                                   pc_dbd_id       varchar2) is
  
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
    cursor cur_pcdi is
      select pcdi.pcdi_id,
             pcdi.internal_contract_ref_no,
             pcdi.delivery_item_no,
             pcdi.delivery_period_type,
             pcdi.delivery_from_month,
             pcdi.delivery_from_year,
             pcdi.delivery_to_month,
             pcdi.delivery_to_year,
             pcdi.delivery_from_date,
             pcdi.delivery_to_date,
             pd_trade_date eod_trade_date,
             pcdi.basis_type,
             nvl(pcdi.transit_days, 0) transit_days,
             pcdi.qp_declaration_date,
             pcdi.is_price_optionality_present,
             pcdi.is_phy_optionality_present,
             pcdi.price_option_call_off_status,
             pci.internal_contract_item_ref_no,
             pcm.contract_ref_no,
             nvl(pcdi.payment_due_date, pd_trade_date) payment_due_date,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcm.invoice_currency_id,
             pcpd.qty_unit_id,
             pcpd.product_id,
             qat.quality_name,
             qat.instrument_id,
             akc.base_cur_id,
             akc.base_currency_name,
             dim.instrument_name,
             ps.price_source_id,
             ps.price_source_name,
             apm.available_price_id,
             apm.available_price_name,
             pum.price_unit_name,
             vdip.ppu_price_unit_id,
             div.price_unit_id
        from pcdi_pc_delivery_item        pcdi,
             pci_physical_contract_item   pci,
             pcm_physical_contract_main   pcm,
             ak_corporate                 akc,
             pcpd_pc_product_definition   pcpd,
             pcpq_pc_product_quality      pcpq,
             mv_qat_quality_valuation     qat,
             dim_der_instrument_master    dim,
             div_der_instrument_valuation div,
             ps_price_source              ps,
             apm_available_price_master   apm,
             pum_price_unit_master        pum,
             v_der_instrument_price_unit  vdip
       where pcdi.pcdi_id = pci.pcdi_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'BASEMETAL'
         and pcpq.quality_template_id = qat.quality_id
         and qat.corporate_id = pc_corporate_id
         and qat.instrument_id = dim.instrument_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and pci.item_qty > 0
         and pcdi.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y';
  
    cursor cur_called_off(pc_pcdi_id varchar2) is
      select poch.poch_id,
             poch.internal_action_ref_no,
             pocd.pricing_formula_id,
             pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.tonnage_basis,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced,
             pcbph.price_description
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where poch.pcdi_id = pc_pcdi_id
         and poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pcbpd.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
  
    cursor cur_not_called_off(pc_pcdi_id varchar2) is
      select pcbpd.pcbpd_id,
             pcbph.internal_contract_ref_no,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.tonnage_basis,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced,
             pcbph.price_description
        from pci_physical_contract_item pci,
             pcipf_pci_pricing_formula  pcipf,
             pcbph_pc_base_price_header pcbph,
             pcbpd_pc_base_price_detail pcbpd
       where pci.internal_contract_item_ref_no =
             pcipf.internal_contract_item_ref_no
         and pcipf.pcbph_id = pcbph.pcbph_id
         and pcbph.pcbph_id = pcbpd.pcbph_id
         and pci.pcdi_id = pc_pcdi_id
         and pci.process_id = pc_process_id
         and pcipf.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pcbpd.process_id = pc_process_id
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
  
    vn_contract_price number;
    vc_price_unit_id  varchar2(15);
    --   vn_fb_order_sq                 number;
    --vn_cur_row_cnt                 number;
    vc_price_basis                varchar2(15);
    vc_price_cur_id               varchar2(15);
    vc_price_cur_code             varchar2(15);
    vc_price_weight_unit          number;
    vc_price_weight_unit_id       varchar2(15);
    vc_price_qty_unit             varchar2(15);
    vn_contract_equity_premium    varchar2(15);
    vn_market_equity_premium      varchar2(15);
    vc_mar_equ_prem_price_unit_id varchar2(15);
    vc_con_equ_prem_price_unit_id varchar2(15);
    vc_price_fixation_status      varchar2(50);
    vn_price_fixed_qty            number;
    vn_total_qty                  number;
    --vc_price_fixation_details      varchar2(15);
    vn_total_quantity              number;
    vn_qty_to_be_priced            number;
    vn_total_contract_value        number;
    vn_avarage_price               number;
    vn_contract_base_price_unit_id varchar2(15);
    vc_contract_main_cur_id        varchar2(15);
    vc_contract_main_cur_code      varchar2(15);
    vc_base_main_cur_id            varchar2(15);
    vc_base_main_cur_code          varchar2(15);
    vn_forward_points              number;
    vn_settlement_price            number;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    --vc_qp_period_type              varchar2(15);
    vc_period varchar2(15);
    --vd_eod_trade_date              date;
    vd_shipment_date date;
    vd_arrival_date  date;
    vd_evevnt_date   date;
    vd_qp_price_date date;
    --vn_price_month                 varchar2(10);
    --vn_price_year                  varchar2(10);
    vc_before_price_dr_id      varchar2(15);
    vn_before_qp_price         number;
    vc_before_qp_price_unit_id varchar2(15);
    vd_3rd_wed_of_qp           date;
    vc_holiday                 char(1);
    vn_after_qp_price          number;
    vc_after_qp_price_unit_id  varchar2(10);
    --vn_total_qp_price              number;
    --vn_count_after_qp              number;
    --vn_total_after_qp_price        number;
    --vn_final_price                 number;
    --vn_final_price_unit_id         varchar2(10);
    vd_payment_due_date         date;
    vc_price_description        varchar2(500);
    vn_contract_main_cur_factor number;
    --vc_pci_price_basis             varchar2(10);
    vd_dur_qp_start_date date;
    vd_dur_qp_end_date   date;
    --vn_during_set_price            number;
    --vc_during_set_price_unit_id    varchar2(15);
    vn_during_val_price         number;
    vc_during_val_price_unit_id varchar2(15);
    vn_during_total_set_price   number;
    vn_during_total_val_price   number;
    vn_count_set_qp             number;
    vn_count_val_qp             number;
    workings_days               number;
    vd_quotes_date              date;
    --vc_after_dr_id                 varchar2(15);
    --vn_total_during_price          number;
    --vn_pofh_id                     varchar2(15);
    vn_after_count                 number;
    vn_after_price                 number;
    vn_during_qp_price             number;
    vc_after_price_dr_id           varchar2(15);
    vc_during_price_dr_id          varchar2(15);
    vc_during_qp_price_unit_id     varchar2(15);
    vn_error_no                    number := 0;
    vn_market_flag                 char(1);
    vn_any_day_cont_price_fix_qty  number;
    vn_any_day_cont_price_ufix_qty number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
  
  begin
    for cur_pcdi_rows in cur_pcdi
    loop
      vc_price_fixation_status := null;
      vn_total_contract_value  := 0;
      if cur_pcdi_rows.price_option_call_off_status in
         ('Called Off', 'Not Applicable') then
        vc_price_fixation_status := null;
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id)
        loop
          vc_price_basis       := cur_called_off_rows.price_basis;
          vc_price_description := cur_called_off_rows.price_description;
        
          if cur_called_off_rows.price_basis = 'Fixed' then
          
            vn_contract_price        := cur_called_off_rows.price_value;
            vn_total_quantity        := cur_pcdi_rows.item_qty;
            vn_qty_to_be_priced      := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value  := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        vn_contract_price;
            vc_price_unit_id         := cur_called_off_rows.price_unit_id;
            vc_price_fixation_status := 'Fixed';
          
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
          
            for cc1 in (select ppfh.ppfh_id,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id,
                               ppu.price_unit_name,
                               pocd.qp_period_type,
                               pofh.qp_start_date,
                               pofh.qp_end_date,
                               pfqpp.event_name,
                               pfqpp.no_of_event_months,
                               pfqpp.is_qp_any_day_basis,
                               pofh.qty_to_be_fixed,
                               pofh.priced_qty,
                               pofh.pofh_id
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail     pcbpd,
                               ppfh_phy_price_formula_header  ppfh,
                               pfqpp_phy_formula_qp_pricing   pfqpp,
                               pofh_price_opt_fixation_header pofh,
                               v_ppu_pum                      ppu
                         where poch.poch_id = pocd.poch_id
                           and pocd.pcbpd_id = pcbpd.pcbpd_id
                           and pcbpd.pcbpd_id = ppfh.pcbpd_id
                           and ppfh.ppfh_id = pfqpp.ppfh_id
                           and pocd.pocd_id = pofh.pocd_id(+)
                           and pcbpd.pcbpd_id = cur_called_off_rows.pcbpd_id
                           and poch.poch_id = cur_called_off_rows.poch_id
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id
                           and poch.is_active = 'Y'
                           and pocd.is_active = 'Y'
                           and pcbpd.is_active = 'Y'
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and pofh.is_active(+) = 'Y'
                           and pcbpd.process_id = pc_process_id
                           and pfqpp.process_id = pc_process_id
                           and ppfh.process_id = pc_process_id)
            
            loop
            
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
            
              if cc1.qp_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Month' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Event' then
                if cc1.event_name = 'Month After Month Of Shipment' then
                  vd_evevnt_date   := add_months(vd_shipment_date,
                                                 cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month After Month Of Arrival' then
                  vd_evevnt_date   := add_months(vd_arrival_date,
                                                 cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month Before Month Of Shipment' then
                  vd_evevnt_date   := add_months(vd_shipment_date,
                                                 -1 * cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month Before Month Of Arrival' then
                  vd_evevnt_date   := add_months(vd_arrival_date,
                                                 -1 * cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'First Half Of Shipment Month' then
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := to_date('15-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                elsif cc1.event_name = 'First Half Of Arrival Month' then
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := to_date('15-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                elsif cc1.event_name = 'First Half Of Shipment Month' then
                  vd_qp_start_date := to_date('16-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Second Half Of Arrival Month' then
                  vd_qp_start_date := to_date('16-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                end if;
              end if;
            
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
            
              if vc_period = 'Before QP' then
                vc_price_fixation_status := 'Un-priced';
              
                vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date, 'Wed', 3);
              
                while true
                loop
                  if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                      vd_3rd_wed_of_qp) then
                    vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                  else
                    exit;
                  end if;
                end loop;
                --- get 3rd wednesday  before QP period 
                -- Get the quotation date = Trade Date +2 working Days
                if vd_3rd_wed_of_qp <= pd_trade_date then
                  workings_days  := 0;
                  vd_quotes_date := pd_trade_date + 1;
                  while workings_days <> 2
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                ---- get the dr_id             
                begin
                  select drm.dr_id
                    into vc_before_price_dr_id
                    from drm_derivative_master drm
                   where drm.instrument_id = cur_pcdi_rows.instrument_id
                     and drm.prompt_date = vd_3rd_wed_of_qp
                     and rownum <= 1
                     and drm.price_point_id is null
                     and drm.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_price',
                                                                         'PHY-002',
                                                                         'DR_ID missing for ' ||
                                                                         cur_pcdi_rows.instrument_name ||
                                                                         ',Price Source:' ||
                                                                         cur_pcdi_rows.price_source_name ||
                                                                         ' Contract Ref No: ' ||
                                                                         cur_pcdi_rows.contract_ref_no ||
                                                                         ',Price Unit:' ||
                                                                         cur_pcdi_rows.price_unit_name || ',' ||
                                                                         cur_pcdi_rows.available_price_name ||
                                                                         ' Price,Prompt Date:' ||
                                                                         vd_3rd_wed_of_qp,
                                                                         '',
                                                                         gvc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                  
                end;
              
                --get the price              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.trade_date = pd_trade_date
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_price',
                                                                         'PHY-002',
                                                                         'Price missing for ' ||
                                                                         cur_pcdi_rows.instrument_name ||
                                                                         ',Price Source:' ||
                                                                         cur_pcdi_rows.price_source_name ||
                                                                         ' Contract Ref No: ' ||
                                                                         cur_pcdi_rows.contract_ref_no ||
                                                                         ',Price Unit:' ||
                                                                         cc1.price_unit_name || ',' ||
                                                                         cur_pcdi_rows.available_price_name ||
                                                                         ' Price,Prompt Date:' ||
                                                                         vd_3rd_wed_of_qp,
                                                                         '',
                                                                         gvc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              
              elsif vc_period = 'After QP' then
                vn_after_price := 0;
                vn_after_count := 0;
                for pfd_price in (select pfd.user_price,
                                         pfd.price_unit_id,
                                         pofh.final_price
                                    from poch_price_opt_call_off_header poch,
                                         pocd_price_option_calloff_dtls pocd,
                                         pofh_price_opt_fixation_header pofh,
                                         pfd_price_fixation_details     pfd
                                   where poch.poch_id = pocd.poch_id
                                     and pocd.pocd_id = pofh.pocd_id
                                     and pfd.pofh_id = cc1.pofh_id
                                     and pofh.pofh_id = pfd.pofh_id
                                     and poch.is_active = 'Y'
                                     and pocd.is_active = 'Y'
                                     and pofh.is_active = 'Y'
                                     and pfd.is_active = 'Y')
                loop
                  vn_after_price            := vn_after_price +
                                               pfd_price.user_price;
                  vn_after_count            := vn_after_count + 1;
                  vc_after_qp_price_unit_id := pfd_price.price_unit_id;
                
                  if pfd_price.final_price is not null then
                    vc_price_fixation_status := 'Finalized';
                  end if;
                
                end loop;
                if vn_after_count = 0 then
                  vn_after_qp_price        := 0;
                  vn_total_contract_value  := 0;
                  vc_price_fixation_status := 'Un-priced';
                else
                  if vc_price_fixation_status <> 'Finalized' then
                    vc_price_fixation_status := 'Partially Priced';
                  else
                    vc_price_fixation_status := 'Partially Priced';
                  end if;
                  vn_after_qp_price       := vn_after_price /
                                             vn_after_count;
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_after_qp_price;
                  vc_price_unit_id        := vc_after_qp_price_unit_id;
                end if;
              
              elsif vc_period = 'During QP' then
              
                vd_dur_qp_start_date          := vd_qp_start_date;
                vd_dur_qp_end_date            := vd_qp_end_date;
                vn_during_total_set_price     := 0;
                vn_count_set_qp               := 0;
                vn_any_day_cont_price_fix_qty := 0;
                vn_any_day_fixed_qty          := 0;
              
                for cc in (select pfd.user_price,
                                  pfd.as_of_date,
                                  pfd.qty_fixed,
                                  pofh.final_price
                             from poch_price_opt_call_off_header poch,
                                  pocd_price_option_calloff_dtls pocd,
                                  pofh_price_opt_fixation_header pofh,
                                  pfd_price_fixation_details     pfd
                            where poch.poch_id = pocd.poch_id
                              and pocd.pocd_id = pofh.pocd_id
                              and pofh.pofh_id = cc1.pofh_id
                              and pofh.pofh_id = pfd.pofh_id
                              and pfd.as_of_date >= vd_dur_qp_start_date
                              and pfd.as_of_date <= pd_trade_date
                              and poch.is_active = 'Y'
                              and pocd.is_active = 'Y'
                              and pofh.is_active = 'Y'
                              and pfd.is_active = 'Y')
                loop
                  vn_during_total_set_price     := vn_during_total_set_price +
                                                   cc.user_price;
                  vn_any_day_cont_price_fix_qty := vn_any_day_cont_price_fix_qty +
                                                   (cc.user_price *
                                                   cc.qty_fixed);
                  vn_any_day_fixed_qty          := vn_any_day_fixed_qty +
                                                   cc.qty_fixed;
                  vn_count_set_qp               := vn_count_set_qp + 1;
                
                  if cc.final_price is not null then
                    vc_price_fixation_status := 'Finalized';
                  end if;
                end loop;
              
                if vn_count_set_qp <> 0 then
                  if vc_price_fixation_status <> 'Finalized' then
                    vc_price_fixation_status := 'Partially Priced';
                  end if;
                else
                  vc_price_fixation_status := 'Un-priced';
                
                end if;
              
                if cc1.is_qp_any_day_basis = 'Y' then
                  vn_market_flag := 'N';
                else
                  vn_market_flag := 'Y';
                end if;
              
                -- get the third wednes day
                vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                   'Wed',
                                                   3);
                while true
                loop
                  if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                      vd_3rd_wed_of_qp) then
                    vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                  else
                    exit;
                  end if;
                end loop;
              
                --- get 3rd wednesday  before QP period 
                -- Get the quotation date = Trade Date +2 working Days
                if vd_3rd_wed_of_qp <= pd_trade_date then
                  workings_days  := 0;
                  vd_quotes_date := pd_trade_date + 1;
                  while workings_days <> 2
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                --Get the DR-id
                begin
                  select drm.dr_id
                    into vc_during_price_dr_id
                    from drm_derivative_master drm
                   where drm.instrument_id = cur_pcdi_rows.instrument_id
                     and drm.prompt_date = vd_3rd_wed_of_qp
                     and rownum <= 1
                     and drm.price_point_id is null
                     and drm.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_price',
                                                                         'PHY-002',
                                                                         'DR-ID missing for ' ||
                                                                         cur_pcdi_rows.instrument_name ||
                                                                         ',Price Source:' ||
                                                                         cur_pcdi_rows.price_source_name ||
                                                                         ' Contract Ref No: ' ||
                                                                         cur_pcdi_rows.contract_ref_no ||
                                                                         ',Price Unit:' ||
                                                                         cc1.price_unit_name || ',' ||
                                                                         cur_pcdi_rows.available_price_name ||
                                                                         ' Price,Prompt Date:' ||
                                                                         vd_3rd_wed_of_qp,
                                                                         '',
                                                                         gvc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                --Get the price for the dr-id
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_val_price,
                         vc_during_val_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.dbd_id = dqd.dbd_id
                     and dq.dbd_id = pc_dbd_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.trade_date = pd_trade_date
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_price',
                                                                         'PHY-002',
                                                                         'Price missing for ' ||
                                                                         cur_pcdi_rows.instrument_name ||
                                                                         ',Price Source:' ||
                                                                         cur_pcdi_rows.price_source_name ||
                                                                         ' Contract Ref No: ' ||
                                                                         cur_pcdi_rows.contract_ref_no ||
                                                                         ',Price Unit:' ||
                                                                         cc1.price_unit_name || ',' ||
                                                                         cur_pcdi_rows.available_price_name ||
                                                                         ' Price,Prompt Date:' ||
                                                                         vd_3rd_wed_of_qp,
                                                                         '',
                                                                         gvc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
              
                vn_during_total_val_price := 0;
                vn_count_val_qp           := 0;
                vd_dur_qp_start_date      := pd_trade_date + 1;
              
                if vn_market_flag = 'N' then
                  vn_during_total_val_price := vn_during_total_val_price +
                                               vn_during_val_price;
                
                  vn_any_day_unfixed_qty         := cc1.qty_to_be_fixed -
                                                    vn_any_day_fixed_qty;
                  vn_count_val_qp                := vn_count_val_qp + 1;
                  vn_any_day_cont_price_ufix_qty := (vn_any_day_unfixed_qty *
                                                    vn_during_total_val_price);
                
                else
                
                  while vd_dur_qp_start_date <= vd_dur_qp_end_date
                  loop
                    ---- finding holidays       
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_dur_qp_start_date) then
                      vc_holiday := 'Y';
                    else
                      vc_holiday := 'N';
                    end if;
                  
                    if vc_holiday = 'N' then
                      vn_during_total_val_price := vn_during_total_val_price +
                                                   vn_during_val_price;
                      vn_count_val_qp           := vn_count_val_qp + 1;
                    end if;
                    vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
                  end loop;
                end if;
              
                if (vn_count_val_qp + vn_count_set_qp) <> 0 then
                
                  if vn_market_flag = 'N' then
                    vn_during_qp_price := (vn_any_day_cont_price_fix_qty +
                                          vn_any_day_cont_price_ufix_qty) /
                                          cc1.qty_to_be_fixed;
                  else
                    vn_during_qp_price := (vn_during_total_set_price +
                                          vn_during_total_val_price) /
                                          (vn_count_set_qp +
                                          vn_count_val_qp);
                  end if;
                
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_during_qp_price;
                  --                  vc_price_unit_id        := cur_pcdi_rows.ppu_price_unit_id;
                
                else
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                  vn_total_contract_value := 0;
                  --                  vc_price_unit_id        := cur_pcdi_rows.ppu_price_unit_id;
                end if;
                vc_price_unit_id := cc1.ppu_price_unit_id;
              end if;
            end loop;
          
          end if;
        end loop;
        vn_avarage_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      
        vn_error_no := vn_error_no + 1;
      elsif cur_pcdi_rows.price_option_call_off_status = 'Not Called Off' then
        vn_error_no              := vn_error_no + 1;
        vc_price_fixation_status := null;
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id)
        loop
          vc_price_basis          := cur_not_called_off_rows.price_basis;
          vc_price_description    := cur_not_called_off_rows.price_description;
          vn_total_contract_value := 0;
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price        := cur_not_called_off_rows.price_value;
            vn_total_quantity        := cur_pcdi_rows.item_qty;
            vn_qty_to_be_priced      := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value  := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        vn_contract_price;
            vc_price_unit_id         := cur_not_called_off_rows.price_unit_id;
            vc_price_fixation_status := 'Fixed';
          
            vn_error_no := 3;
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select pfqpp.qp_pricing_period_type,
                               pfqpp.qp_period_from_date,
                               pfqpp.qp_period_to_date,
                               pfqpp.qp_month,
                               pfqpp.qp_year,
                               pfqpp.qp_date,
                               pfqpp.event_name,
                               pfqpp.no_of_event_months,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id, --pum price unit id, as quoted available in this unit only
                               ppu.price_unit_name
                          from ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing  pfqpp,
                               v_ppu_pum                     ppu
                         where ppfh.ppfh_id = pfqpp.ppfh_id
                           and ppfh.pcbpd_id =
                               cur_not_called_off_rows.pcbpd_id
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id
                           and ppfh.process_id = pc_process_id
                           and pfqpp.process_id = pc_process_id)
            loop
            
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
            
              if cc1.qp_pricing_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              elsif cc1.qp_pricing_period_type = 'Month' then
                vd_qp_start_date := '01-' || cc1.qp_month || '-' ||
                                    cc1.qp_year;
                vd_qp_end_date   := last_day(vd_qp_start_date);
              elsif cc1.qp_pricing_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_date;
                vd_qp_end_date   := cc1.qp_date;
              elsif cc1.qp_pricing_period_type = 'Event' then
                if cc1.event_name = 'Month After Month Of Shipment' then
                  vd_evevnt_date   := add_months(vd_shipment_date,
                                                 cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month After Month Of Arrival' then
                  vd_evevnt_date   := add_months(vd_arrival_date,
                                                 cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month Before Month Of Shipment' then
                  vd_evevnt_date   := add_months(vd_shipment_date,
                                                 -1 * cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month Before Month Of Arrival' then
                  vd_evevnt_date   := add_months(vd_arrival_date,
                                                 -1 * cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'First Half Of Shipment Month' then
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := to_date('15-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                elsif cc1.event_name = 'First Half Of Arrival Month' then
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := to_date('15-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                elsif cc1.event_name = 'First Half Of Shipment Month' then
                  vd_qp_start_date := to_date('16-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Second Half Of Arrival Month' then
                  vd_qp_start_date := to_date('16-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                end if;
                vd_qp_price_date := vd_evevnt_date;
              end if;
            
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
            
              if vc_period = 'Before QP' then
              
                vc_price_fixation_status := 'Un-priced';
              
                vn_error_no := 4;
                ---- get third wednesday of QP period
                --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date, 'Wed', 3);
                while true
                loop
                  if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                      vd_3rd_wed_of_qp) then
                    vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                  else
                    exit;
                  end if;
                end loop;
                --- get 3rd wednesday  before QP period 
                -- Get the quotation date = Trade Date +2 working Days
                if vd_3rd_wed_of_qp <= pd_trade_date then
                  workings_days  := 0;
                  vd_quotes_date := pd_trade_date + 1;
                  while workings_days <> 2
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                --get the price dr_id   
                begin
                  select drm.dr_id
                    into vc_before_price_dr_id
                    from drm_derivative_master drm
                   where drm.instrument_id = cur_pcdi_rows.instrument_id
                     and drm.prompt_date = vd_3rd_wed_of_qp
                     and drm.price_point_id is null
                     and rownum <= 1
                     and drm.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_price',
                                                                         'PHY-002',
                                                                         'DR-ID missing for ' ||
                                                                         cur_pcdi_rows.instrument_name ||
                                                                         ',Price Source:' ||
                                                                         cur_pcdi_rows.price_source_name ||
                                                                         ' Contract Ref No: ' ||
                                                                         cur_pcdi_rows.contract_ref_no ||
                                                                         ',Price Unit:' ||
                                                                         cc1.price_unit_name || ',' ||
                                                                         cur_pcdi_rows.available_price_name ||
                                                                         ' Price,Prompt Date:' ||
                                                                         vd_3rd_wed_of_qp,
                                                                         '',
                                                                         gvc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
              
                --get the price
              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.trade_date = pd_trade_date
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_price',
                                                                         'PHY-002',
                                                                         'Price missing for ' ||
                                                                         cur_pcdi_rows.instrument_name ||
                                                                         ',Price Source:' ||
                                                                         cur_pcdi_rows.price_source_name ||
                                                                         ' Contract Ref No: ' ||
                                                                         cur_pcdi_rows.contract_ref_no ||
                                                                         ',Price Unit:' ||
                                                                         cc1.price_unit_name || ',' ||
                                                                         cur_pcdi_rows.available_price_name ||
                                                                         ' Price,Prompt Date:' ||
                                                                         vd_3rd_wed_of_qp,
                                                                         '',
                                                                         gvc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              
              elsif vc_period = 'After QP' then
                vc_price_fixation_status := 'Un-priced';
                vn_error_no              := 5;
                vd_3rd_wed_of_qp         := f_get_next_day(vd_qp_end_date,
                                                           'Wed',
                                                           3);
                while true
                loop
                  if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                      vd_3rd_wed_of_qp) then
                    vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                  else
                    exit;
                  end if;
                end loop;
                --- get 3rd wednesday  before QP period 
                -- Get the quotation date = Trade Date +2 working Days
                if vd_3rd_wed_of_qp <= pd_trade_date then
                  workings_days  := 0;
                  vd_quotes_date := pd_trade_date + 1;
                  while workings_days <> 2
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
              
                --get the price dr_id   
                begin
                  select drm.dr_id
                    into vc_after_price_dr_id
                    from drm_derivative_master drm
                   where drm.instrument_id = cur_pcdi_rows.instrument_id
                     and drm.prompt_date = vd_3rd_wed_of_qp
                     and drm.price_point_id is null
                     and rownum <= 1
                     and drm.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_price',
                                                                         'PHY-002',
                                                                         'DR-ID missing for ' ||
                                                                         cur_pcdi_rows.instrument_name ||
                                                                         ',Price Source:' ||
                                                                         cur_pcdi_rows.price_source_name ||
                                                                         ' Contract Ref No: ' ||
                                                                         cur_pcdi_rows.contract_ref_no ||
                                                                         ',Price Unit:' ||
                                                                         cc1.price_unit_name || ',' ||
                                                                         cur_pcdi_rows.available_price_name ||
                                                                         ' Price,Prompt Date:' ||
                                                                         vd_3rd_wed_of_qp,
                                                                         '',
                                                                         gvc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
              
                --get the price
              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_after_qp_price,
                         vc_after_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_after_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.trade_date = pd_trade_date
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_price',
                                                                         'PHY-002',
                                                                         'Price missing for ' ||
                                                                         cur_pcdi_rows.instrument_name ||
                                                                         ',Price Source:' ||
                                                                         cur_pcdi_rows.price_source_name ||
                                                                         ' Contract Ref No: ' ||
                                                                         cur_pcdi_rows.contract_ref_no ||
                                                                         ',Price Unit:' ||
                                                                         cc1.price_unit_name || ',' ||
                                                                         cur_pcdi_rows.available_price_name ||
                                                                         ' Price,Prompt Date:' ||
                                                                         vd_3rd_wed_of_qp,
                                                                         '',
                                                                         gvc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_after_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'During QP' then
                vc_price_fixation_status := 'Un-priced';
                vn_error_no              := 6;
                vd_3rd_wed_of_qp         := f_get_next_day(vd_qp_end_date,
                                                           'Wed',
                                                           3);
                while true
                loop
                  if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                      vd_3rd_wed_of_qp) then
                    vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                  else
                    exit;
                  end if;
                end loop;
                --- get 3rd wednesday  before QP period 
                -- Get the quotation date = Trade Date +2 working Days
                if vd_3rd_wed_of_qp <= pd_trade_date then
                  workings_days  := 0;
                  vd_quotes_date := pd_trade_date + 1;
                  while workings_days <> 2
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
              
                --get the price dr_id   
                begin
                  select drm.dr_id
                    into vc_during_price_dr_id
                    from drm_derivative_master drm
                   where drm.instrument_id = cur_pcdi_rows.instrument_id
                     and drm.prompt_date = vd_3rd_wed_of_qp
                     and drm.price_point_id is null
                     and rownum <= 1
                     and drm.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_price',
                                                                         'PHY-002',
                                                                         'DR-ID missing for ' ||
                                                                         cur_pcdi_rows.instrument_name ||
                                                                         ',Price Source:' ||
                                                                         cur_pcdi_rows.price_source_name ||
                                                                         ' Contract Ref No: ' ||
                                                                         cur_pcdi_rows.contract_ref_no ||
                                                                         ',Price Unit:' ||
                                                                         cc1.price_unit_name || ',' ||
                                                                         cur_pcdi_rows.available_price_name ||
                                                                         ' Price,Prompt Date:' ||
                                                                         vd_3rd_wed_of_qp,
                                                                         '',
                                                                         gvc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
              
                --get the price
              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_qp_price,
                         vc_during_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.trade_date = pd_trade_date
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_price',
                                                                         'PHY-002',
                                                                         'Price missing for ' ||
                                                                         cur_pcdi_rows.instrument_name ||
                                                                         ',Price Source:' ||
                                                                         cur_pcdi_rows.price_source_name ||
                                                                         ' Contract Ref No: ' ||
                                                                         cur_pcdi_rows.contract_ref_no ||
                                                                         ',Price Unit:' ||
                                                                         cc1.price_unit_name || ',' ||
                                                                         cur_pcdi_rows.available_price_name ||
                                                                         ' Price,Prompt Date:' ||
                                                                         vd_3rd_wed_of_qp,
                                                                         '',
                                                                         gvc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_during_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              
              end if;
            end loop;
          end if;
        end loop;
        vn_avarage_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      end if;
      vn_error_no := 7;
      begin
        select cm.cur_id,
               cm.cur_code,
               nvl(ppu.weight, 1),
               ppu.weight_unit_id,
               qum.qty_unit
          into vc_price_cur_id,
               vc_price_cur_code,
               vc_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      
        pkg_general.sp_get_base_cur_detail(vc_price_cur_id,
                                           vc_contract_main_cur_id,
                                           vc_contract_main_cur_code,
                                           vn_contract_main_cur_factor);
        vn_error_no := 8;
      
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vc_price_weight_unit    := 1;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
    
      ---get the contract main cur id
      /* begin
          select scd.cur_id
            into vc_contract_main_cur_id
            from scd_sub_currency_detail scd
           where scd.sub_cur_id = vc_price_cur_id;
        exception
          when no_data_found then
            vc_contract_main_cur_id := vc_price_cur_id;
        end;
      */
    
      -- get the contract base price Unit id
      /*begin
        select product_price_unit_id
          into vn_contract_base_price_unit_id
          from v_ppu_pum pum,
               ak_corporate akc,
               pdm_productmaster pdm
         where pum.cur_id = akc.base_cur_id
           and pum.weight_unit_id=pdm.base_quantity_unit
           and pum.product_id=pdm.product_id;
      exception
        when no_data_found then
          vn_contract_base_price_unit_id := null;
      end;*/
    
      -- get the base main cur id
    
      vc_base_main_cur_id   := cur_pcdi_rows.base_cur_id;
      vc_base_main_cur_code := cur_pcdi_rows.base_currency_name;
    
      if cur_pcdi_rows.payment_due_date is null then
        vd_payment_due_date := pd_trade_date;
      else
        vd_payment_due_date := cur_pcdi_rows.payment_due_date;
      end if;
    
      /*pkg_general.sp_forward_cur_exchange_rate(pc_corporate_id,
      pd_trade_date,
      vd_payment_due_date,
      vc_contract_main_cur_id,
      vc_base_main_cur_id,
      vn_settlement_price,
      vn_forward_points);*/
      vn_error_no := 9;
      --not required, as handled in pnl calculation
      /*if vc_contract_main_cur_id <> vc_base_main_cur_id then
        if vn_settlement_price is null or vn_settlement_price = 0 then
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure pkg_phy_physical_process contract price',
                                                               'PHY-005',
                                                               vc_base_main_cur_code ||
                                                               ' to ' ||
                                                               vc_contract_main_cur_code,
                                                               '',
                                                               gvc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
        
        end if;
      end if;*/
      insert into cipd_contract_item_price_daily
        (corporate_id,
         pcdi_id,
         internal_contract_item_ref_no,
         internal_contract_ref_no,
         contract_ref_no,
         delivery_item_no,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         price_basis,
         price_fixation_details,
         contract_equity_premium,
         market_equity_premium,
         mkt_equity_prem_price_unit_id,
         cont_equity_prem_price_unit_id,
         process_id,
         price_fixation_status,
         price_fixed_qty,
         total_qty,
         payment_due_date,
         contract_base_price_unit_id,
         contract_base_fx_rate,
         price_description)
      values
        (pc_corporate_id,
         cur_pcdi_rows.pcdi_id,
         cur_pcdi_rows.internal_contract_item_ref_no,
         cur_pcdi_rows.internal_contract_ref_no,
         cur_pcdi_rows.contract_ref_no,
         cur_pcdi_rows.delivery_item_no,
         vn_avarage_price,
         vc_price_unit_id,
         vc_price_cur_id,
         vc_price_cur_code,
         vc_price_weight_unit,
         vc_price_weight_unit_id,
         vc_price_qty_unit,
         vc_price_basis,
         'Not Applicable',
         vn_contract_equity_premium,
         vn_market_equity_premium,
         vc_mar_equ_prem_price_unit_id,
         vc_con_equ_prem_price_unit_id,
         pc_process_id,
         vc_price_fixation_status,
         vn_price_fixed_qty,
         vn_total_qty,
         cur_pcdi_rows.payment_due_date,
         vn_contract_base_price_unit_id,
         vn_settlement_price,
         vc_price_description);
    
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_physical_process contract price',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           dbms_utility.format_error_backtrace ||
                                                           'No ' ||
                                                           vn_error_no,
                                                           '',
                                                           gvc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_calc_gmr_price(pc_corporate_id varchar2,
                              pd_trade_date   date,
                              pc_process_id   varchar2,
                              pc_user_id      varchar2,
                              pc_dbd_id       varchar2) is
  
    cursor cur_gmr is
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.pofh_id,
             pd_trade_date eod_trade_date,
             qat.instrument_id,
             dim.instrument_name,
             ps.price_source_id,
             ps.price_source_name,
             apm.available_price_id,
             apm.available_price_name,
             pum.price_unit_name,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             pocd.is_any_day_pricing,
             pofh.qty_to_be_fixed,
             round(pofh.priced_qty, 4) priced_qty,
             pofh.no_of_prompt_days,
             pocd.pcbpd_id
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id
                from grd_goods_record_detail grd
               where grd.process_id = pc_process_id
                 and grd.status = 'Active'
                 and grd.is_deleted = 'N'
                 and nvl(grd.inventory_status, 'NA') <> 'Out'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id) grd,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             mv_qat_quality_valuation qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and grd.quality_id = qat.quality_id
         and gmr.process_id = pc_process_id
         and qat.corporate_id = pc_corporate_id
         and qat.instrument_id = dim.instrument_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
            --  and gmr.internal_gmr_ref_no = 'GMR-68'
         and gmr.is_deleted = 'N'
         and pofh.is_active = 'Y';
  
    vobj_error_log             tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count         number := 1;
    vd_qp_start_date           date;
    vd_qp_end_date             date;
    vc_period                  varchar2(50);
    vd_3rd_wed_of_qp           date;
    workings_days              number;
    vd_quotes_date             date;
    vc_before_price_dr_id      varchar2(15);
    vn_before_qp_price         number;
    vc_before_qp_price_unit_id varchar2(15);
    --vn_total_quantity              number;
    vn_total_contract_value number;
    -- vc_price_unit_id               varchar2(15);
    vn_after_price                 number;
    vn_after_count                 number;
    vn_after_qp_price              number;
    vc_after_qp_price_unit_id      varchar2(15);
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vc_holiday                     char(1);
    vn_during_qp_price             number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vc_price_weight_unit           number;
    vc_price_weight_unit_id        varchar2(15);
    vc_price_qty_unit              varchar2(15);
    vc_price_fixation_status       varchar2(50);
    vn_market_flag                 char(1);
    vn_any_day_cont_price_fix_qty  number;
    vn_any_day_cont_price_ufix_qty number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_price_unit_id               varchar2(15);
    vc_ppu_price_unit_id           varchar2(15);
    vc_price_name                  varchar2(100);
    vc_pcbpd_id                    varchar2(15);
  
  begin
    for cur_gmr_rows in cur_gmr
    loop
      vc_price_fixation_status       := null;
      vn_total_contract_value        := 0;
      vn_market_flag                 := null;
      vn_any_day_cont_price_fix_qty  := 0;
      vn_any_day_cont_price_ufix_qty := 0;
      vn_any_day_unfixed_qty         := 0;
      vn_any_day_fixed_qty           := 0;
      vc_pcbpd_id                    := cur_gmr_rows.pcbpd_id;
      vc_price_unit_id               := null;
      vc_ppu_price_unit_id           := null;
      vd_qp_start_date               := cur_gmr_rows.qp_start_date;
      vd_qp_end_date                 := cur_gmr_rows.qp_end_date;
    
      if cur_gmr_rows.eod_trade_date >= vd_qp_start_date and
         cur_gmr_rows.eod_trade_date <= vd_qp_end_date then
        vc_period := 'During QP';
      elsif cur_gmr_rows.eod_trade_date < vd_qp_start_date and
            cur_gmr_rows.eod_trade_date < vd_qp_end_date then
        vc_period := 'Before QP';
      elsif cur_gmr_rows.eod_trade_date > vd_qp_start_date and
            cur_gmr_rows.eod_trade_date > vd_qp_end_date then
        vc_period := 'After QP';
      end if;
      begin
        select ppu.product_price_unit_id,
               ppu.price_unit_id,
               ppu.price_unit_name
          into vc_ppu_price_unit_id,
               vc_price_unit_id,
               vc_price_name
          from ppfh_phy_price_formula_header ppfh,
               v_ppu_pum                     ppu
         where ppfh.pcbpd_id = vc_pcbpd_id
           and ppfh.process_id = pc_process_id
           and ppfh.price_unit_id = ppu.product_price_unit_id
           and rownum <= 1;
      exception
        when no_data_found then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
          vc_price_name        := cur_gmr_rows.price_unit_name;
        when others then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
          vc_price_name        := cur_gmr_rows.price_unit_name;
      end;
      if vc_period = 'Before QP' then
        vc_price_fixation_status := 'Un-priced';
        vd_3rd_wed_of_qp         := f_get_next_day(vd_qp_end_date, 'Wed', 3);
      
        while true
        loop
          if f_is_day_holiday(cur_gmr_rows.instrument_id, vd_3rd_wed_of_qp) then
            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
          else
            exit;
          end if;
        end loop;
      
        --- get 3rd wednesday  before QP period 
        -- Get the quotation date = Trade Date +2 working Days
        if vd_3rd_wed_of_qp <= pd_trade_date then
          workings_days  := 0;
          vd_quotes_date := pd_trade_date + 1;
          while workings_days <> 2
          loop
            if f_is_day_holiday(cur_gmr_rows.instrument_id, vd_quotes_date) then
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
        ---- get the dr_id             
        begin
          select drm.dr_id
            into vc_before_price_dr_id
            from drm_derivative_master drm
           where drm.instrument_id = cur_gmr_rows.instrument_id
             and drm.prompt_date = vd_3rd_wed_of_qp
             and rownum <= 1
             and drm.price_point_id is null
             and drm.is_deleted = 'N';
        exception
          when no_data_found then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure sp_calc_gmr_price',
                                                                 'PHY-002',
                                                                 'DR_ID missing for ' ||
                                                                 cur_gmr_rows.instrument_name ||
                                                                 ',Price Source:' ||
                                                                 cur_gmr_rows.price_source_name ||
                                                                 ' GMR No: ' ||
                                                                 cur_gmr_rows.gmr_ref_no ||
                                                                 ',Price Unit:' ||
                                                                 vc_price_name || ',' ||
                                                                 cur_gmr_rows.available_price_name ||
                                                                 ' Price,Prompt Date:' ||
                                                                 vd_3rd_wed_of_qp,
                                                                 '',
                                                                 gvc_process,
                                                                 pc_user_id,
                                                                 sysdate,
                                                                 pd_trade_date);
            sp_insert_error_log(vobj_error_log);
          
        end;
        --get the price              
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_before_qp_price,
                 vc_before_qp_price_unit_id
            from dq_derivative_quotes        dq,
                 dqd_derivative_quote_detail dqd
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_before_price_dr_id
             and dq.process_id = pc_process_id
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dq.process_id = dqd.process_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dqd.price_unit_id = vc_price_unit_id
             and dq.trade_date = pd_trade_date
             and dq.is_deleted = 'N'
             and dqd.is_deleted = 'N';
        exception
          when no_data_found then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure sp_calc_gmr_price',
                                                                 'PHY-002',
                                                                 'Price missing for ' ||
                                                                 cur_gmr_rows.instrument_name ||
                                                                 ',Price Source:' ||
                                                                 cur_gmr_rows.price_source_name ||
                                                                 ' GMR No: ' ||
                                                                 cur_gmr_rows.gmr_ref_no ||
                                                                 ',Price Unit:' ||
                                                                 vc_price_name || ',' ||
                                                                 cur_gmr_rows.available_price_name ||
                                                                 ' Price,Prompt Date:' ||
                                                                 vd_3rd_wed_of_qp,
                                                                 '',
                                                                 gvc_process,
                                                                 pc_user_id,
                                                                 sysdate,
                                                                 pd_trade_date);
            sp_insert_error_log(vobj_error_log);
        end;
        vn_total_contract_value := vn_total_contract_value +
                                   vn_before_qp_price;
        --  vc_price_unit_id        := cur_gmr_rows.ppu_price_unit_id;
      
      elsif vc_period = 'After QP' then
        vn_after_price := 0;
        vn_after_count := 0;
        for pfd_price in (select pfd.user_price,
                                 pfd.price_unit_id,
                                 pofh.final_price
                            from poch_price_opt_call_off_header poch,
                                 pocd_price_option_calloff_dtls pocd,
                                 pofh_price_opt_fixation_header pofh,
                                 pfd_price_fixation_details     pfd
                           where poch.poch_id = pocd.poch_id
                             and pocd.pocd_id = pofh.pocd_id
                             and pfd.pofh_id = cur_gmr_rows.pofh_id
                             and pofh.pofh_id = pfd.pofh_id
                             and poch.is_active = 'Y'
                             and pocd.is_active = 'Y'
                             and pofh.is_active = 'Y'
                             and pfd.is_active = 'Y')
        loop
          if pfd_price.final_price is not null then
            vc_price_fixation_status := 'Finalized';
          end if;
        
          vn_after_price := vn_after_price + pfd_price.user_price;
          vn_after_count := vn_after_count + 1;
        
        end loop;
        --   end if;
        if vn_after_count = 0 then
          vn_after_qp_price         := 0;
          vn_total_contract_value   := 0;
          vc_after_qp_price_unit_id := null;
          vc_price_fixation_status  := 'Un-priced';
        else
          vn_after_qp_price       := vn_after_price / vn_after_count;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_after_qp_price;
          -- vc_price_unit_id        := cur_gmr_rows.ppu_price_unit_id;
          if vc_price_fixation_status <> 'Finalized' then
            vc_price_fixation_status := 'Partially Priced';
          else
            vc_price_fixation_status := 'Partially Priced';
          end if;
        end if;
      elsif vc_period = 'During QP' then
        vd_dur_qp_start_date      := vd_qp_start_date;
        vd_dur_qp_end_date        := vd_qp_end_date;
        vn_during_total_set_price := 0;
        vn_count_set_qp           := 0;
        for cc in (select pfd.user_price,
                          pfd.as_of_date,
                          pfd.qty_fixed,
                          pofh.final_price,
                          pocd.is_any_day_pricing
                     from poch_price_opt_call_off_header poch,
                          pocd_price_option_calloff_dtls pocd,
                          pofh_price_opt_fixation_header pofh,
                          pfd_price_fixation_details     pfd
                    where poch.poch_id = pocd.poch_id
                      and pocd.pocd_id = pofh.pocd_id
                      and pofh.pofh_id = cur_gmr_rows.pofh_id
                      and pofh.pofh_id = pfd.pofh_id
                      and pfd.as_of_date >= vd_dur_qp_start_date
                      and pfd.as_of_date <= pd_trade_date
                      and poch.is_active = 'Y'
                      and pocd.is_active = 'Y'
                      and pofh.is_active = 'Y'
                      and pfd.is_active = 'Y')
        loop
          vn_during_total_set_price := vn_during_total_set_price +
                                       cc.user_price;
          vn_count_set_qp           := vn_count_set_qp + 1;
          if cc.final_price is not null then
            vc_price_fixation_status := 'Finalized';
          end if;
          vn_any_day_fixed_qty := vn_any_day_fixed_qty + cc.qty_fixed;
        end loop;
        if vn_count_set_qp <> 0 then
          if vc_price_fixation_status <> 'Finalized' then
            vc_price_fixation_status := 'Partially Priced';
          end if;
        else
          vc_price_fixation_status := 'Un-priced';
        
        end if;
        if cur_gmr_rows.is_any_day_pricing = 'Y' then
          vn_market_flag := 'N';
        else
          vn_market_flag := 'Y';
        end if;
      
        -- get the third wednes day
        vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date, 'Wed', 3);
        while true
        loop
          if f_is_day_holiday(cur_gmr_rows.instrument_id, vd_3rd_wed_of_qp) then
            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
          else
            exit;
          end if;
        end loop;
      
        --- get 3rd wednesday  before QP period 
        -- Get the quotation date = Trade Date +2 working Days
        if vd_3rd_wed_of_qp <= pd_trade_date then
          workings_days  := 0;
          vd_quotes_date := pd_trade_date + 1;
          while workings_days <> 2
          loop
            if f_is_day_holiday(cur_gmr_rows.instrument_id, vd_quotes_date) then
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
        --Get the DR-id
        begin
          select drm.dr_id
            into vc_during_price_dr_id
            from drm_derivative_master drm
           where drm.instrument_id = cur_gmr_rows.instrument_id
             and drm.prompt_date = vd_3rd_wed_of_qp
             and rownum <= 1
             and drm.price_point_id is null
             and drm.is_deleted = 'N';
        exception
          when no_data_found then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure sp_calc_gmr_price',
                                                                 'PHY-002',
                                                                 'DR-ID missing for ' ||
                                                                 cur_gmr_rows.instrument_name ||
                                                                 ',Price Source:' ||
                                                                 cur_gmr_rows.price_source_name ||
                                                                 ' GMR NO: ' ||
                                                                 cur_gmr_rows.gmr_ref_no ||
                                                                 ',Price Unit:' ||
                                                                 vc_price_name || ',' ||
                                                                 cur_gmr_rows.available_price_name ||
                                                                 ' Price,Prompt Date:' ||
                                                                 vd_3rd_wed_of_qp,
                                                                 '',
                                                                 gvc_process,
                                                                 pc_user_id,
                                                                 sysdate,
                                                                 pd_trade_date);
            sp_insert_error_log(vobj_error_log);
        end;
        --Get the price for the dr-id
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_during_val_price,
                 vc_during_val_price_unit_id
            from dq_derivative_quotes        dq,
                 dqd_derivative_quote_detail dqd
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_during_price_dr_id
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dq.dbd_id = dqd.dbd_id
             and dq.dbd_id = pc_dbd_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dq.trade_date = pd_trade_date
             and dqd.price_unit_id = vc_price_unit_id
             and dq.is_deleted = 'N'
             and dqd.is_deleted = 'N';
        exception
          when no_data_found then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure sp_gmr_price',
                                                                 'PHY-002',
                                                                 'Price missing for ' ||
                                                                 cur_gmr_rows.instrument_name ||
                                                                 ',Price Source:' ||
                                                                 cur_gmr_rows.price_source_name ||
                                                                 ' GMR No: ' ||
                                                                 cur_gmr_rows.gmr_ref_no ||
                                                                 ',Price Unit:' ||
                                                                 vc_price_name || ',' ||
                                                                 cur_gmr_rows.available_price_name ||
                                                                 ' Price,Prompt Date:' ||
                                                                 vd_3rd_wed_of_qp,
                                                                 '',
                                                                 gvc_process,
                                                                 pc_user_id,
                                                                 sysdate,
                                                                 pd_trade_date);
            sp_insert_error_log(vobj_error_log);
        end;
      
        vn_during_total_val_price := 0;
        vn_count_val_qp           := 0;
        vd_dur_qp_start_date      := pd_trade_date + 1;
        if vn_market_flag = 'N' then
          vn_during_total_val_price := vn_during_total_val_price +
                                       vn_during_val_price;
        
          vn_any_day_unfixed_qty         := cur_gmr_rows.qty_to_be_fixed -
                                            vn_any_day_fixed_qty;
          vn_count_val_qp                := vn_count_val_qp + 1;
          vn_any_day_cont_price_ufix_qty := (vn_any_day_unfixed_qty *
                                            vn_during_total_val_price);
        
        else
          while vd_dur_qp_start_date <= vd_dur_qp_end_date
          loop
            ---- finding holidays       
            if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                vd_dur_qp_start_date) then
              vc_holiday := 'Y';
            else
              vc_holiday := 'N';
            end if;
          
            if vc_holiday = 'N' then
              vn_during_total_val_price := vn_during_total_val_price +
                                           vn_during_val_price;
              vn_count_val_qp           := vn_count_val_qp + 1;
            end if;
            vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
          end loop;
        end if;
        if (vn_count_val_qp + vn_count_set_qp) <> 0 then
        
          if vn_market_flag = 'N' then
            vn_during_qp_price := (vn_any_day_cont_price_fix_qty +
                                  vn_any_day_cont_price_ufix_qty) /
                                  cur_gmr_rows.qty_to_be_fixed;
          else
            vn_during_qp_price := (vn_during_total_set_price +
                                  vn_during_total_val_price) /
                                  (vn_count_set_qp + vn_count_val_qp);
          end if;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_during_qp_price;
        else
          vn_total_contract_value := 0;
        end if;
      
      end if;
    
      begin
        select cm.cur_id,
               cm.cur_code,
               nvl(ppu.weight, 1),
               ppu.weight_unit_id,
               qum.qty_unit
          into vc_price_cur_id,
               vc_price_cur_code,
               vc_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_ppu_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vc_price_weight_unit    := 1;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
      insert into gpd_gmr_price_daily
        (corporate_id,
         internal_gmr_ref_no,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         process_id,
         price_fixation_status)
      values
        (cur_gmr_rows.corporate_id,
         cur_gmr_rows.internal_gmr_ref_no,
         vn_total_contract_value,
         vc_ppu_price_unit_id,
         vc_price_cur_id,
         vc_price_cur_code,
         vc_price_weight_unit,
         vc_price_weight_unit_id,
         vc_price_qty_unit,
         pc_process_id,
         vc_price_fixation_status);
    
    end loop;
  
  end;

  procedure sp_calc_conc_gmr_price(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_user_id      varchar2,
                                   pc_dbd_id       varchar2) is
  
    cursor cur_gmr is
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             poch.element_id,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.pofh_id,
             pd_trade_date eod_trade_date,
             qat.instrument_id,
             dim.instrument_name,
             ps.price_source_id,
             ps.price_source_name,
             apm.available_price_id,
             apm.available_price_name,
             pum.price_unit_name,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             pocd.is_any_day_pricing,
             pofh.qty_to_be_fixed,
             round(pofh.priced_qty, 4) priced_qty,
             pofh.no_of_prompt_days,
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from grd_goods_record_detail grd
               where grd.process_id = pc_process_id
                 and grd.status = 'Active'
                 and grd.is_deleted = 'N'
                 and nvl(grd.inventory_status, 'NA') <> 'Out'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             mv_conc_qat_quality_valuation qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip,
             pdc_prompt_delivery_calendar pdc
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
         and poch.poch_id = pocd.pocd_id
         and pocd.pocd_id = pofh.pocd_id
         and grd.quality_id = qat.conc_quality_id
         and grd.product_id = qat.conc_product_id
         and poch.element_id = qat.attribute_id
         and gmr.process_id = pc_process_id
         and qat.corporate_id = pc_corporate_id
         and qat.instrument_id = dim.instrument_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id
         and gmr.is_deleted = 'N'
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pofh.is_active = 'Y'
      union all
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             poch.element_id,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.pofh_id,
             pd_trade_date eod_trade_date,
             qat.instrument_id,
             dim.instrument_name,
             ps.price_source_id,
             ps.price_source_name,
             apm.available_price_id,
             apm.available_price_name,
             pum.price_unit_name,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             pocd.is_any_day_pricing,
             pofh.qty_to_be_fixed,
             round(pofh.priced_qty, 4) priced_qty,
             pofh.no_of_prompt_days,
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from dgrd_delivered_grd grd
               where grd.process_id = pc_process_id
                 and grd.status = 'Active'
                 and nvl(grd.inventory_status, 'NA') <> 'Out'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             mv_conc_qat_quality_valuation qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip,
             pdc_prompt_delivery_calendar pdc
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
         and poch.poch_id = pocd.pocd_id
         and pocd.pocd_id = pofh.pocd_id
         and grd.quality_id = qat.conc_quality_id
         and grd.product_id = qat.conc_product_id
         and poch.element_id = qat.attribute_id
         and gmr.process_id = pc_process_id
         and qat.corporate_id = pc_corporate_id
         and qat.instrument_id = dim.instrument_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id
         and gmr.is_deleted = 'N'
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pofh.is_active = 'Y';
  
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(50);
    vd_3rd_wed_of_qp               date;
    workings_days                  number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_total_contract_value        number;
    vn_after_price                 number;
    vn_after_count                 number;
    vn_after_qp_price              number;
    vc_after_qp_price_unit_id      varchar2(15);
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vc_holiday                     char(1);
    vn_during_qp_price             number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vc_price_weight_unit           number;
    vc_price_weight_unit_id        varchar2(15);
    vc_price_qty_unit              varchar2(15);
    vc_price_fixation_status       varchar2(50);
    vn_market_flag                 char(1);
    vn_any_day_cont_price_fix_qty  number;
    vn_any_day_cont_price_ufix_qty number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_price_unit_id               varchar2(15);
    vc_ppu_price_unit_id           varchar2(15);
    vc_price_name                  varchar2(100);
    vc_pcbpd_id                    varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
  
  begin
    for cur_gmr_rows in cur_gmr
    loop
      vc_price_fixation_status       := null;
      vn_total_contract_value        := 0;
      vn_market_flag                 := null;
      vn_any_day_cont_price_fix_qty  := 0;
      vn_any_day_cont_price_ufix_qty := 0;
      vn_any_day_unfixed_qty         := 0;
      vn_any_day_fixed_qty           := 0;
      vc_pcbpd_id                    := cur_gmr_rows.pcbpd_id;
      vc_price_unit_id               := null;
      vc_ppu_price_unit_id           := null;
      vd_qp_start_date               := cur_gmr_rows.qp_start_date;
      vd_qp_end_date                 := cur_gmr_rows.qp_end_date;
    
      if cur_gmr_rows.eod_trade_date >= vd_qp_start_date and
         cur_gmr_rows.eod_trade_date <= vd_qp_end_date then
        vc_period := 'During QP';
      elsif cur_gmr_rows.eod_trade_date < vd_qp_start_date and
            cur_gmr_rows.eod_trade_date < vd_qp_end_date then
        vc_period := 'Before QP';
      elsif cur_gmr_rows.eod_trade_date > vd_qp_start_date and
            cur_gmr_rows.eod_trade_date > vd_qp_end_date then
        vc_period := 'After QP';
      end if;
    
      begin
        select ppu.product_price_unit_id,
               ppu.price_unit_id,
               ppu.price_unit_name
          into vc_ppu_price_unit_id,
               vc_price_unit_id,
               vc_price_name
          from ppfh_phy_price_formula_header ppfh,
               v_ppu_pum                     ppu
         where ppfh.pcbpd_id = vc_pcbpd_id
           and ppfh.process_id = pc_process_id
           and ppfh.price_unit_id = ppu.product_price_unit_id
           and rownum <= 1;
      exception
        when no_data_found then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
          vc_price_name        := cur_gmr_rows.price_unit_name;
        when others then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
          vc_price_name        := cur_gmr_rows.price_unit_name;
      end;
    
      if vc_period = 'Before QP' then
        vc_price_fixation_status := 'Un-priced';
      
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
        
          vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date, 'Wed', 3);
        
          while true
          loop
            if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                vd_3rd_wed_of_qp) then
              vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
            else
              exit;
            end if;
          end loop;
        
          --- get 3rd wednesday  before QP period 
          -- Get the quotation date = Trade Date +2 working Days
          if vd_3rd_wed_of_qp <= pd_trade_date then
            workings_days  := 0;
            vd_quotes_date := pd_trade_date + 1;
            while workings_days <> 2
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
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
          ---- get the dr_id             
          begin
            select drm.dr_id
              into vc_before_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.prompt_date = vd_3rd_wed_of_qp
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_calc_gmr_price',
                                                                   'PHY-002',
                                                                   'DR_ID missing for ' ||
                                                                   cur_gmr_rows.instrument_name ||
                                                                   ',Price Source:' ||
                                                                   cur_gmr_rows.price_source_name ||
                                                                   ' GMR No: ' ||
                                                                   cur_gmr_rows.gmr_ref_no ||
                                                                   ',Price Unit:' ||
                                                                   vc_price_name || ',' ||
                                                                   cur_gmr_rows.available_price_name ||
                                                                   ' Price,Prompt Date:' ||
                                                                   vd_3rd_wed_of_qp,
                                                                   '',
                                                                   gvc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            
          end;
        
        elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
              cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
        
          vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                              pd_trade_date);
          vc_prompt_month := to_char(vc_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
        
          ---- get the dr_id             
          begin
            select drm.dr_id
              into vc_before_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.period_month = vc_prompt_month
               and drm.period_year = vc_prompt_year
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_calc_contract_price',
                                                                   'PHY-002',
                                                                   'DR_ID missing for ' ||
                                                                   cur_gmr_rows.instrument_name ||
                                                                   ',Price Source:' ||
                                                                   cur_gmr_rows.price_source_name ||
                                                                   ' Contract Ref No: ' ||
                                                                   cur_gmr_rows.gmr_ref_no ||
                                                                   ',Price Unit:' ||
                                                                   vc_price_name || ',' ||
                                                                   cur_gmr_rows.available_price_name ||
                                                                   ' Price,Prompt Date:' ||
                                                                   vc_prompt_month || ' ' ||
                                                                   vc_prompt_year,
                                                                   '',
                                                                   gvc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            
          end;
        
        end if;
        --get the price              
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_before_qp_price,
                 vc_before_qp_price_unit_id
            from dq_derivative_quotes        dq,
                 dqd_derivative_quote_detail dqd
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_before_price_dr_id
             and dq.process_id = pc_process_id
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dq.process_id = dqd.process_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dqd.price_unit_id = vc_price_unit_id
             and dq.trade_date = pd_trade_date
             and dq.is_deleted = 'N'
             and dqd.is_deleted = 'N';
        exception
          when no_data_found then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_gmr_price','PHY-002','Price missing for ' || cur_gmr_rows.instrument_name ||',Price Source:' || cur_gmr_rows.price_source_name ||' GMR No: ' || cur_gmr_rows.gmr_ref_no ||',Price Unit:' || vc_price_name ||',' || cur_gmr_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_gmr_rows.is_daily_cal_applicable = 'N' and cur_gmr_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end), '', gvc_process, pc_user_id, sysdate, pd_trade_date);
            sp_insert_error_log(vobj_error_log);
        end;
        vn_total_contract_value := vn_total_contract_value +
                                   vn_before_qp_price;
        --  vc_price_unit_id        := cur_gmr_rows.ppu_price_unit_id;
      
      elsif vc_period = 'After QP' then
        vn_after_price := 0;
        vn_after_count := 0;
        for pfd_price in (select pfd.user_price,
                                 pfd.price_unit_id,
                                 pofh.final_price
                            from poch_price_opt_call_off_header poch,
                                 pocd_price_option_calloff_dtls pocd,
                                 pofh_price_opt_fixation_header pofh,
                                 pfd_price_fixation_details     pfd
                           where poch.poch_id = pocd.poch_id
                             and pocd.pocd_id = pofh.pocd_id
                             and pfd.pofh_id = cur_gmr_rows.pofh_id
                             and pofh.pofh_id = pfd.pofh_id
                             and poch.is_active = 'Y'
                             and pocd.is_active = 'Y'
                             and pofh.is_active = 'Y'
                             and pfd.is_active = 'Y')
        loop
          if pfd_price.final_price is not null then
            vc_price_fixation_status := 'Finalized';
          end if;
        
          vn_after_price := vn_after_price + pfd_price.user_price;
          vn_after_count := vn_after_count + 1;
        
        end loop;
        --   end if;
        if vn_after_count = 0 then
          vn_after_qp_price         := 0;
          vn_total_contract_value   := 0;
          vc_after_qp_price_unit_id := null;
          vc_price_fixation_status  := 'Un-priced';
        else
          vn_after_qp_price       := vn_after_price / vn_after_count;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_after_qp_price;
          -- vc_price_unit_id        := cur_gmr_rows.ppu_price_unit_id;
          if vc_price_fixation_status <> 'Finalized' then
            vc_price_fixation_status := 'Partially Priced';
          else
            vc_price_fixation_status := 'Partially Priced';
          end if;
        end if;
      elsif vc_period = 'During QP' then
        vd_dur_qp_start_date      := vd_qp_start_date;
        vd_dur_qp_end_date        := vd_qp_end_date;
        vn_during_total_set_price := 0;
        vn_count_set_qp           := 0;
        for cc in (select pfd.user_price,
                          pfd.as_of_date,
                          pfd.qty_fixed,
                          pofh.final_price,
                          pocd.is_any_day_pricing
                     from poch_price_opt_call_off_header poch,
                          pocd_price_option_calloff_dtls pocd,
                          pofh_price_opt_fixation_header pofh,
                          pfd_price_fixation_details     pfd
                    where poch.poch_id = pocd.poch_id
                      and pocd.pocd_id = pofh.pocd_id
                      and pofh.pofh_id = cur_gmr_rows.pofh_id
                      and pofh.pofh_id = pfd.pofh_id
                      and pfd.as_of_date >= vd_dur_qp_start_date
                      and pfd.as_of_date <= pd_trade_date
                      and poch.is_active = 'Y'
                      and pocd.is_active = 'Y'
                      and pofh.is_active = 'Y'
                      and pfd.is_active = 'Y')
        loop
          vn_during_total_set_price := vn_during_total_set_price +
                                       cc.user_price;
          vn_count_set_qp           := vn_count_set_qp + 1;
          if cc.final_price is not null then
            vc_price_fixation_status := 'Finalized';
          end if;
          vn_any_day_fixed_qty := vn_any_day_fixed_qty + cc.qty_fixed;
        end loop;
        if vn_count_set_qp <> 0 then
          if vc_price_fixation_status <> 'Finalized' then
            vc_price_fixation_status := 'Partially Priced';
          end if;
        else
          vc_price_fixation_status := 'Un-priced';
        
        end if;
        if cur_gmr_rows.is_any_day_pricing = 'Y' then
          vn_market_flag := 'N';
        else
          vn_market_flag := 'Y';
        end if;
      
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          -- get the third wednes day
          vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date, 'Wed', 3);
          while true
          loop
            if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                vd_3rd_wed_of_qp) then
              vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
            else
              exit;
            end if;
          end loop;
        
          --- get 3rd wednesday  before QP period 
          -- Get the quotation date = Trade Date +2 working Days
          if vd_3rd_wed_of_qp <= pd_trade_date then
            workings_days  := 0;
            vd_quotes_date := pd_trade_date + 1;
            while workings_days <> 2
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
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
          --Get the DR-id
          begin
            select drm.dr_id
              into vc_during_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.prompt_date = vd_3rd_wed_of_qp
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_calc_gmr_price',
                                                                   'PHY-002',
                                                                   'DR-ID missing for ' ||
                                                                   cur_gmr_rows.instrument_name ||
                                                                   ',Price Source:' ||
                                                                   cur_gmr_rows.price_source_name ||
                                                                   ' GMR NO: ' ||
                                                                   cur_gmr_rows.gmr_ref_no ||
                                                                   ',Price Unit:' ||
                                                                   vc_price_name || ',' ||
                                                                   cur_gmr_rows.available_price_name ||
                                                                   ' Price,Prompt Date:' ||
                                                                   vd_3rd_wed_of_qp,
                                                                   '',
                                                                   gvc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
          end;
        elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
              cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
        
          vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                              pd_trade_date);
          vc_prompt_month := to_char(vc_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
        
          ---- get the dr_id             
          begin
            select drm.dr_id
              into vc_during_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.period_month = vc_prompt_month
               and drm.period_year = vc_prompt_year
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_calc_contract_price',
                                                                   'PHY-002',
                                                                   'DR_ID missing for ' ||
                                                                   cur_gmr_rows.instrument_name ||
                                                                   ',Price Source:' ||
                                                                   cur_gmr_rows.price_source_name ||
                                                                   ' Contract Ref No: ' ||
                                                                   cur_gmr_rows.gmr_ref_no ||
                                                                   ',Price Unit:' ||
                                                                   vc_price_name || ',' ||
                                                                   cur_gmr_rows.available_price_name ||
                                                                   ' Price,Prompt Date:' ||
                                                                   vc_prompt_month || ' ' ||
                                                                   vc_prompt_year,
                                                                   '',
                                                                   gvc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            
          end;
        
        end if;
        --Get the price for the price
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_during_val_price,
                 vc_during_val_price_unit_id
            from dq_derivative_quotes        dq,
                 dqd_derivative_quote_detail dqd
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_during_price_dr_id
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dq.dbd_id = dqd.dbd_id
             and dq.dbd_id = pc_dbd_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dq.trade_date = pd_trade_date
             and dqd.price_unit_id = vc_price_unit_id
             and dq.is_deleted = 'N'
             and dqd.is_deleted = 'N';
        exception
          when no_data_found then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_gmr_price','PHY-002','Price missing for ' || cur_gmr_rows.instrument_name ||',Price Source:' || cur_gmr_rows.price_source_name ||' GMR No: ' || cur_gmr_rows.gmr_ref_no ||',Price Unit:' || vc_price_name ||',' || cur_gmr_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_gmr_rows.is_daily_cal_applicable = 'N' and cur_gmr_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end), '', gvc_process, pc_user_id, sysdate, pd_trade_date);
            sp_insert_error_log(vobj_error_log);
        end;
      
        vn_during_total_val_price := 0;
        vn_count_val_qp           := 0;
        vd_dur_qp_start_date      := pd_trade_date + 1;
        if vn_market_flag = 'N' then
          vn_during_total_val_price := vn_during_total_val_price +
                                       vn_during_val_price;
        
          vn_any_day_unfixed_qty         := cur_gmr_rows.qty_to_be_fixed -
                                            vn_any_day_fixed_qty;
          vn_count_val_qp                := vn_count_val_qp + 1;
          vn_any_day_cont_price_ufix_qty := (vn_any_day_unfixed_qty *
                                            vn_during_total_val_price);
        
        else
          while vd_dur_qp_start_date <= vd_dur_qp_end_date
          loop
            ---- finding holidays       
            if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                vd_dur_qp_start_date) then
              vc_holiday := 'Y';
            else
              vc_holiday := 'N';
            end if;
          
            if vc_holiday = 'N' then
              vn_during_total_val_price := vn_during_total_val_price +
                                           vn_during_val_price;
              vn_count_val_qp           := vn_count_val_qp + 1;
            end if;
            vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
          end loop;
        end if;
        if (vn_count_val_qp + vn_count_set_qp) <> 0 then
        
          if vn_market_flag = 'N' then
            vn_during_qp_price := (vn_any_day_cont_price_fix_qty +
                                  vn_any_day_cont_price_ufix_qty) /
                                  cur_gmr_rows.qty_to_be_fixed;
          else
            vn_during_qp_price := (vn_during_total_set_price +
                                  vn_during_total_val_price) /
                                  (vn_count_set_qp + vn_count_val_qp);
          end if;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_during_qp_price;
        else
          vn_total_contract_value := 0;
        end if;
      
      end if;
      begin
        select cm.cur_id,
               cm.cur_code,
               nvl(ppu.weight, 1),
               ppu.weight_unit_id,
               qum.qty_unit
          into vc_price_cur_id,
               vc_price_cur_code,
               vc_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_ppu_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vc_price_weight_unit    := 1;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
    
      insert into gpd_gmr_conc_price_daily
        (corporate_id,
         internal_gmr_ref_no,
         element_id,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         process_id,
         price_fixation_status)
      values
        (cur_gmr_rows.corporate_id,
         cur_gmr_rows.internal_gmr_ref_no,
         cur_gmr_rows.element_id,
         vn_total_contract_value,
         vc_ppu_price_unit_id,
         vc_price_cur_id,
         vc_price_cur_code,
         vc_price_weight_unit,
         vc_price_weight_unit_id,
         vc_price_qty_unit,
         pc_process_id,
         vc_price_fixation_status);
    
    end loop;
  end;

  procedure sp_calc_contract_conc_price(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_dbd_id       varchar2) is
  
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    cursor cur_pcdi is
      select pcdi.pcdi_id,
             pcdi.internal_contract_ref_no,
             ceqs.element_id,
             ceqs.payable_qty,
             ceqs.payable_qty_unit_id,
             ceqs.assay_qty,
             ceqs.assay_qty_unit_id,
             pcdi.delivery_item_no,
             pcdi.delivery_period_type,
             pcdi.delivery_from_month,
             pcdi.delivery_from_year,
             pcdi.delivery_to_month,
             pcdi.delivery_to_year,
             pcdi.delivery_from_date,
             pcdi.delivery_to_date,
             pd_trade_date eod_trade_date,
             pcdi.basis_type,
             nvl(pcdi.transit_days, 0) transit_days,
             pcdi.qp_declaration_date,
             pcdi.is_price_optionality_present,
             pcdi.is_phy_optionality_present,
             pci.internal_contract_item_ref_no,
             pcm.contract_ref_no,
             nvl(pcdi.payment_due_date, pd_trade_date) payment_due_date,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcm.invoice_currency_id,
             pcpd.qty_unit_id,
             pcpd.product_id,
             aml.underlying_product_id,
             qat.quality_name,
             qat.instrument_id,
             akc.base_cur_id,
             akc.base_currency_name,
             dim.instrument_name,
             ps.price_source_id,
             ps.price_source_name,
             apm.available_price_id,
             apm.available_price_name,
             pum.price_unit_name,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
      
        from pcdi_pc_delivery_item         pcdi,
             ceqs_contract_ele_qty_status  ceqs,
             pci_physical_contract_item    pci,
             pcm_physical_contract_main    pcm,
             ak_corporate                  akc,
             pcpd_pc_product_definition    pcpd,
             pcpq_pc_product_quality       pcpq,
             aml_attribute_master_list     aml,
             mv_conc_qat_quality_valuation qat,
             dim_der_instrument_master     dim,
             div_der_instrument_valuation  div,
             ps_price_source               ps,
             apm_available_price_master    apm,
             pum_price_unit_master         pum,
             v_der_instrument_price_unit   vdip,
             pdc_prompt_delivery_calendar  pdc
      
       where pcdi.pcdi_id = pci.pcdi_id
         and pci.internal_contract_item_ref_no =
             ceqs.internal_contract_item_ref_no
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'CONCENTRATES'
         and pcpd.product_id = qat.conc_product_id
         and pcpq.quality_template_id = qat.conc_quality_id
         and ceqs.element_id = aml.attribute_id
         and ceqs.element_id = qat.attribute_id
         and qat.corporate_id = pc_corporate_id
         and qat.instrument_id = dim.instrument_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id
         and pci.item_qty > 0
         and ceqs.payable_qty > 0
         and pcdi.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and ceqs.process_id = pc_process_id
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y';
  
    cursor cur_called_off(pc_pcdi_id varchar2, pc_element_id varchar2) is
      select poch.poch_id,
             poch.internal_action_ref_no,
             pocd.pricing_formula_id,
             pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.tonnage_basis,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced,
             pcbph.price_description
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where poch.pcdi_id = pc_pcdi_id
         and pcbpd.element_id = pc_element_id
         and poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pcbpd.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
  
    cursor cur_not_called_off(pc_pcdi_id varchar2, pc_element_id varchar2) is
      select pcbpd.pcbpd_id,
             pcbph.internal_contract_ref_no,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.tonnage_basis,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced,
             pcbph.price_description
        from pci_physical_contract_item pci,
             pcipf_pci_pricing_formula  pcipf,
             pcbph_pc_base_price_header pcbph,
             pcbpd_pc_base_price_detail pcbpd
       where pci.internal_contract_item_ref_no =
             pcipf.internal_contract_item_ref_no
         and pcipf.pcbph_id = pcbph.pcbph_id
         and pcbph.pcbph_id = pcbpd.pcbph_id
         and pci.pcdi_id = pc_pcdi_id
         and pcbpd.element_id = pc_element_id
         and pci.process_id = pc_process_id
         and pcipf.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pcbpd.process_id = pc_process_id
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
  
    vn_contract_price              number;
    vc_price_unit_id               varchar2(15);
    vn_total_quantity              number;
    vn_total_contract_value        number;
    vd_shipment_date               date;
    vd_arrival_date                date;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(20);
    vd_3rd_wed_of_qp               date;
    workings_days                  number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_qty_to_be_priced            number;
    vn_after_price                 number;
    vn_after_count                 number;
    vc_after_qp_price_unit_id      varchar2(15);
    vn_after_qp_price              number;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vn_any_day_cont_price_fix_qty  number;
    vn_any_day_fixed_qty           number;
    vn_market_flag                 char(1);
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_cont_price_ufix_qty number;
    vc_holiday                     char(10);
    vn_during_qp_price             number;
    vn_avarage_price               number;
    vc_price_fixation_status       varchar2(50);
    vc_price_basis                 varchar2(15);
    vc_price_description           varchar2(500);
    vd_evevnt_date                 date;
    vd_qp_price_date               date;
    vc_after_price_dr_id           varchar2(15);
    vc_during_qp_price_unit_id     varchar2(15);
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vc_price_weight_unit           number;
    vc_price_weight_unit_id        varchar2(15);
    vc_price_qty_unit              varchar2(15);
    vc_contract_main_cur_id        varchar2(15);
    vc_contract_main_cur_code      varchar2(15);
    vn_contract_main_cur_factor    number;
    vc_base_main_cur_id            varchar2(15);
    vc_base_main_cur_code          varchar2(15);
    vd_payment_due_date            date;
    vn_settlement_price            number;
    vn_forward_points              number;
    vn_contract_base_price_unit_id varchar2(15);
    vc_price_option_call_off_sts   varchar2(50);
    vc_pcdi_id                     varchar2(15);
    vc_element_id                  varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
  
  begin
  
    for cur_pcdi_rows in cur_pcdi
    loop
      vc_pcdi_id    := cur_pcdi_rows.pcdi_id;
      vc_element_id := cur_pcdi_rows.element_id;
      begin
        select dipq.price_option_call_off_status
          into vc_price_option_call_off_sts
          from dipq_delivery_item_payable_qty dipq
         where dipq.pcdi_id = vc_pcdi_id
           and dipq.element_id = vc_element_id
           and dipq.is_active = 'Y';
      exception
        when no_data_found then
          vc_price_option_call_off_sts := null;
      end;
    
      vc_price_fixation_status := null;
      vn_total_contract_value  := 0;
      vd_qp_start_date         := null;
      vd_qp_end_date           := null;
    
      if vc_price_option_call_off_sts in ('Called Off', 'Not Applicable') then
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id,
                                                  cur_pcdi_rows.element_id)
        loop
          vc_price_basis       := cur_called_off_rows.price_basis;
          vc_price_description := cur_called_off_rows.price_description;
          if cur_called_off_rows.price_basis = 'Fixed' then
          
            vn_contract_price        := cur_called_off_rows.price_value;
            vn_total_quantity        := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                             cur_pcdi_rows.payable_qty_unit_id,
                                                                             cur_pcdi_rows.item_qty_unit_id,
                                                                             cur_pcdi_rows.payable_qty);
            vn_qty_to_be_priced      := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value  := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        vn_contract_price;
            vc_price_unit_id         := cur_called_off_rows.price_unit_id;
            vc_price_fixation_status := 'Fixed';
          
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select ppfh.ppfh_id,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id,
                               ppu.price_unit_name,
                               pocd.qp_period_type,
                               pofh.qp_start_date,
                               pofh.qp_end_date,
                               pfqpp.event_name,
                               pfqpp.no_of_event_months,
                               pfqpp.is_qp_any_day_basis,
                               pofh.qty_to_be_fixed,
                               pofh.priced_qty,
                               pofh.pofh_id
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail     pcbpd,
                               ppfh_phy_price_formula_header  ppfh,
                               pfqpp_phy_formula_qp_pricing   pfqpp,
                               pofh_price_opt_fixation_header pofh,
                               v_ppu_pum                      ppu
                         where poch.poch_id = pocd.poch_id
                           and pocd.pcbpd_id = pcbpd.pcbpd_id
                           and pcbpd.pcbpd_id = ppfh.pcbpd_id
                           and ppfh.ppfh_id = pfqpp.ppfh_id
                           and pocd.pocd_id = pofh.pocd_id(+)
                           and pcbpd.pcbpd_id = cur_called_off_rows.pcbpd_id
                           and poch.poch_id = cur_called_off_rows.poch_id
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id
                           and poch.is_active = 'Y'
                           and pocd.is_active = 'Y'
                           and pcbpd.is_active = 'Y'
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and pofh.is_active(+) = 'Y'
                           and pcbpd.process_id = pc_process_id
                           and pfqpp.process_id = pc_process_id
                           and ppfh.process_id = pc_process_id)
            
            loop
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
            
              if cc1.qp_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Month' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Event' then
                if cc1.event_name = 'Month After Month Of Shipment' then
                  vd_evevnt_date   := add_months(vd_shipment_date,
                                                 cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month After Month Of Arrival' then
                  vd_evevnt_date   := add_months(vd_arrival_date,
                                                 cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month Before Month Of Shipment' then
                  vd_evevnt_date   := add_months(vd_shipment_date,
                                                 -1 * cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month Before Month Of Arrival' then
                  vd_evevnt_date   := add_months(vd_arrival_date,
                                                 -1 * cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'First Half Of Shipment Month' then
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := to_date('15-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                elsif cc1.event_name = 'First Half Of Arrival Month' then
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := to_date('15-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                elsif cc1.event_name = 'First Half Of Shipment Month' then
                  vd_qp_start_date := to_date('16-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Second Half Of Arrival Month' then
                  vd_qp_start_date := to_date('16-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                end if;
              end if;
            
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if vc_period = 'Before QP' then
                vc_price_fixation_status := 'Un-priced';
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           gvc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                
                  vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                      pd_trade_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vc_prompt_month || ' ' ||
                                                                           vc_prompt_year,
                                                                           '',
                                                                           gvc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --get the price              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.trade_date = pd_trade_date
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                    --vc_prompt_month || '-' || vc_prompt_year
                     to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end), '', gvc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              
              elsif vc_period = 'After QP' then
                vn_after_price := 0;
                vn_after_count := 0;
                for pfd_price in (select pfd.user_price,
                                         pfd.price_unit_id,
                                         pofh.final_price
                                    from poch_price_opt_call_off_header poch,
                                         pocd_price_option_calloff_dtls pocd,
                                         pofh_price_opt_fixation_header pofh,
                                         pfd_price_fixation_details     pfd
                                   where poch.poch_id = pocd.poch_id
                                     and pocd.pocd_id = pofh.pocd_id
                                     and pfd.pofh_id = cc1.pofh_id
                                     and pofh.pofh_id = pfd.pofh_id
                                     and poch.is_active = 'Y'
                                     and pocd.is_active = 'Y'
                                     and pofh.is_active = 'Y'
                                     and pfd.is_active = 'Y')
                loop
                  vn_after_price            := vn_after_price +
                                               pfd_price.user_price;
                  vn_after_count            := vn_after_count + 1;
                  vc_after_qp_price_unit_id := pfd_price.price_unit_id;
                
                  if pfd_price.final_price is not null then
                    vc_price_fixation_status := 'Finalized';
                  end if;
                
                end loop;
                if vn_after_count = 0 then
                  vn_after_qp_price        := 0;
                  vn_total_contract_value  := 0;
                  vc_price_fixation_status := 'Un-priced';
                else
                  if vc_price_fixation_status <> 'Finalized' then
                    vc_price_fixation_status := 'Partially Priced';
                  else
                    vc_price_fixation_status := 'Partially Priced';
                  end if;
                  vn_after_qp_price       := vn_after_price /
                                             vn_after_count;
                  vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                  cur_pcdi_rows.payable_qty_unit_id,
                                                                                  cur_pcdi_rows.item_qty_unit_id,
                                                                                  cur_pcdi_rows.payable_qty);
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_after_qp_price;
                  vc_price_unit_id        := vc_after_qp_price_unit_id;
                end if;
              
              elsif vc_period = 'During QP' then
              
                vd_dur_qp_start_date          := vd_qp_start_date;
                vd_dur_qp_end_date            := vd_qp_end_date;
                vn_during_total_set_price     := 0;
                vn_count_set_qp               := 0;
                vn_any_day_cont_price_fix_qty := 0;
                vn_any_day_fixed_qty          := 0;
              
                for cc in (select pfd.user_price,
                                  pfd.as_of_date,
                                  pfd.qty_fixed,
                                  pofh.final_price
                             from poch_price_opt_call_off_header poch,
                                  pocd_price_option_calloff_dtls pocd,
                                  pofh_price_opt_fixation_header pofh,
                                  pfd_price_fixation_details     pfd
                            where poch.poch_id = pocd.poch_id
                              and pocd.pocd_id = pofh.pocd_id
                              and pofh.pofh_id = cc1.pofh_id
                              and pofh.pofh_id = pfd.pofh_id
                              and pfd.as_of_date >= vd_dur_qp_start_date
                              and pfd.as_of_date <= pd_trade_date
                              and poch.is_active = 'Y'
                              and pocd.is_active = 'Y'
                              and pofh.is_active = 'Y'
                              and pfd.is_active = 'Y')
                loop
                  vn_during_total_set_price     := vn_during_total_set_price +
                                                   cc.user_price;
                  vn_any_day_cont_price_fix_qty := vn_any_day_cont_price_fix_qty +
                                                   (cc.user_price *
                                                   cc.qty_fixed);
                  vn_any_day_fixed_qty          := vn_any_day_fixed_qty +
                                                   cc.qty_fixed;
                  vn_count_set_qp               := vn_count_set_qp + 1;
                
                  if cc.final_price is not null then
                    vc_price_fixation_status := 'Finalized';
                  end if;
                end loop;
              
                if vn_count_set_qp <> 0 then
                  if vc_price_fixation_status <> 'Finalized' then
                    vc_price_fixation_status := 'Partially Priced';
                  else
                    vc_price_fixation_status := 'Partially Priced';
                  end if;
                else
                  vc_price_fixation_status := 'Un-priced';
                
                end if;
              
                if cc1.is_qp_any_day_basis = 'Y' then
                  vn_market_flag := 'N';
                else
                  vn_market_flag := 'Y';
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  -- get the third wednes day
                  vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  --Get the DR-id
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           gvc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                
                  vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                      pd_trade_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vc_prompt_month || ' ' ||
                                                                           vc_prompt_year,
                                                                           '',
                                                                           gvc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --Get the price for the dr-id
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_val_price,
                         vc_during_val_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.dbd_id = dqd.dbd_id
                     and dq.dbd_id = pc_dbd_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.trade_date = pd_trade_date
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                    -- vc_prompt_month || '-' || vc_prompt_year
                     to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end), '', gvc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
              
                vn_during_total_val_price := 0;
                vn_count_val_qp           := 0;
                vd_dur_qp_start_date      := pd_trade_date + 1;
              
                if vn_market_flag = 'N' then
                  vn_during_total_val_price := vn_during_total_val_price +
                                               vn_during_val_price;
                
                  vn_any_day_unfixed_qty         := cc1.qty_to_be_fixed -
                                                    vn_any_day_fixed_qty;
                  vn_count_val_qp                := vn_count_val_qp + 1;
                  vn_any_day_cont_price_ufix_qty := (vn_any_day_unfixed_qty *
                                                    vn_during_total_val_price);
                
                else
                
                  while vd_dur_qp_start_date <= vd_dur_qp_end_date
                  loop
                    ---- finding holidays       
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_dur_qp_start_date) then
                      vc_holiday := 'Y';
                    else
                      vc_holiday := 'N';
                    end if;
                  
                    if vc_holiday = 'N' then
                      vn_during_total_val_price := vn_during_total_val_price +
                                                   vn_during_val_price;
                      vn_count_val_qp           := vn_count_val_qp + 1;
                    end if;
                    vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
                  end loop;
                end if;
              
                if (vn_count_val_qp + vn_count_set_qp) <> 0 then
                
                  if vn_market_flag = 'N' then
                    vn_during_qp_price := (vn_any_day_cont_price_fix_qty +
                                          vn_any_day_cont_price_ufix_qty) /
                                          cc1.qty_to_be_fixed;
                  else
                    vn_during_qp_price := (vn_during_total_set_price +
                                          vn_during_total_val_price) /
                                          (vn_count_set_qp +
                                          vn_count_val_qp);
                  end if;
                  vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                  cur_pcdi_rows.payable_qty_unit_id,
                                                                                  cur_pcdi_rows.item_qty_unit_id,
                                                                                  cur_pcdi_rows.payable_qty);
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_during_qp_price;
                  vc_price_unit_id        := cc1.ppu_price_unit_id;
                
                else
                  vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                  cur_pcdi_rows.payable_qty_unit_id,
                                                                                  cur_pcdi_rows.item_qty_unit_id,
                                                                                  cur_pcdi_rows.payable_qty);
                  vn_total_contract_value := 0;
                  vc_price_unit_id        := cc1.ppu_price_unit_id;
                end if;
              
              end if;
            end loop;
          end if;
        end loop;
        vn_avarage_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      
      elsif vc_price_option_call_off_sts = 'Not Called Off' then
      
        vc_price_fixation_status := null;
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.element_id)
        loop
          vc_price_basis          := cur_not_called_off_rows.price_basis;
          vc_price_description    := cur_not_called_off_rows.price_description;
          vn_total_contract_value := 0;
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price        := cur_not_called_off_rows.price_value;
            vn_total_quantity        := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                             cur_pcdi_rows.payable_qty_unit_id,
                                                                             cur_pcdi_rows.item_qty_unit_id,
                                                                             cur_pcdi_rows.payable_qty);
            vn_qty_to_be_priced      := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value  := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        vn_contract_price;
            vc_price_unit_id         := cur_not_called_off_rows.price_unit_id;
            vc_price_fixation_status := 'Fixed';
          
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select pfqpp.qp_pricing_period_type,
                               pfqpp.qp_period_from_date,
                               pfqpp.qp_period_to_date,
                               pfqpp.qp_month,
                               pfqpp.qp_year,
                               pfqpp.qp_date,
                               pfqpp.event_name,
                               pfqpp.no_of_event_months,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id, --pum price unit id, as quoted available in this unit only
                               ppu.price_unit_name
                          from ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing  pfqpp,
                               v_ppu_pum                     ppu
                         where ppfh.ppfh_id = pfqpp.ppfh_id
                           and ppfh.pcbpd_id =
                               cur_not_called_off_rows.pcbpd_id
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id
                           and ppfh.process_id = pc_process_id
                           and pfqpp.process_id = pc_process_id)
            loop
            
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
            
              if cc1.qp_pricing_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              elsif cc1.qp_pricing_period_type = 'Month' then
                vd_qp_start_date := '01-' || cc1.qp_month || '-' ||
                                    cc1.qp_year;
                vd_qp_end_date   := last_day(vd_qp_start_date);
              elsif cc1.qp_pricing_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_date;
                vd_qp_end_date   := cc1.qp_date;
              elsif cc1.qp_pricing_period_type = 'Event' then
                if cc1.event_name = 'Month After Month Of Shipment' then
                  vd_evevnt_date   := add_months(vd_shipment_date,
                                                 cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month After Month Of Arrival' then
                  vd_evevnt_date   := add_months(vd_arrival_date,
                                                 cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month Before Month Of Shipment' then
                  vd_evevnt_date   := add_months(vd_shipment_date,
                                                 -1 * cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Month Before Month Of Arrival' then
                  vd_evevnt_date   := add_months(vd_arrival_date,
                                                 -1 * cc1.no_of_event_months);
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_evevnt_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'First Half Of Shipment Month' then
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := to_date('15-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                elsif cc1.event_name = 'First Half Of Arrival Month' then
                  vd_qp_start_date := to_date('01-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := to_date('15-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                elsif cc1.event_name = 'First Half Of Shipment Month' then
                  vd_qp_start_date := to_date('16-' ||
                                              to_char(vd_shipment_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                elsif cc1.event_name = 'Second Half Of Arrival Month' then
                  vd_qp_start_date := to_date('16-' ||
                                              to_char(vd_arrival_date,
                                                      'Mon-yyyy'),
                                              'dd-mon-yyyy');
                  vd_qp_end_date   := last_day(vd_qp_start_date);
                end if;
                vd_qp_price_date := vd_evevnt_date;
              end if;
            
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
            
              if vc_period = 'Before QP' then
              
                vc_price_fixation_status := 'Un-priced';
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  ---- get third wednesday of QP period
                  --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  --get the price dr_id   
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           gvc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                
                  vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                      pd_trade_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                  
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vc_prompt_month || ' ' ||
                                                                           vc_prompt_year,
                                                                           '',
                                                                           gvc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --get the price
              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.trade_date = pd_trade_date
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                    -- vc_prompt_month || '-' || vc_prompt_year
                     to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end), '', gvc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              
              elsif vc_period = 'After QP' then
                vc_price_fixation_status := 'Un-priced';
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                
                  --get the price dr_id   
                  begin
                    select drm.dr_id
                      into vc_after_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           gvc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                
                  vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                      pd_trade_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_after_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vc_prompt_month || ' ' ||
                                                                           vc_prompt_year,
                                                                           '',
                                                                           gvc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --get the price
              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_after_qp_price,
                         vc_after_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_after_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.trade_date = pd_trade_date
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                    -- vc_prompt_month || '-' || vc_prompt_year
                     to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end), '', gvc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_after_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'During QP' then
                vc_price_fixation_status := 'Un-priced';
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                
                  --get the price dr_id   
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           gvc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                
                  vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                      pd_trade_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vc_prompt_month || ' ' ||
                                                                           vc_prompt_year,
                                                                           '',
                                                                           gvc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --get the price
              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_qp_price,
                         vc_during_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.trade_date = pd_trade_date
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N';
                exception
                  when no_data_found then
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                    --- vc_prompt_month || '-' || vc_prompt_year
                     to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end), '', gvc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_during_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              
              end if;
            end loop;
          end if;
        end loop;
        vn_avarage_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      
      end if;
    
      begin
        select cm.cur_id,
               cm.cur_code,
               ppu.weight,
               ppu.weight_unit_id,
               qum.qty_unit
          into vc_price_cur_id,
               vc_price_cur_code,
               vc_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      
        pkg_general.sp_get_base_cur_detail(vc_price_cur_id,
                                           vc_contract_main_cur_id,
                                           vc_contract_main_cur_code,
                                           vn_contract_main_cur_factor);
      
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vc_price_weight_unit    := 1;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
    
      vc_base_main_cur_id   := cur_pcdi_rows.base_cur_id;
      vc_base_main_cur_code := cur_pcdi_rows.base_currency_name;
    
      if cur_pcdi_rows.payment_due_date is null then
        vd_payment_due_date := pd_trade_date;
      else
        vd_payment_due_date := cur_pcdi_rows.payment_due_date;
      end if;
    
      pkg_general.sp_forward_cur_exchange_rate(pc_corporate_id,
                                               pd_trade_date,
                                               vd_payment_due_date,
                                               vc_contract_main_cur_id,
                                               vc_base_main_cur_id,
                                               vn_settlement_price,
                                               vn_forward_points);
    
      if vc_contract_main_cur_id <> vc_base_main_cur_id then
        if vn_settlement_price is null or vn_settlement_price = 0 then
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure pkg_phy_physical_process contract price',
                                                               'PHY-005',
                                                               vc_base_main_cur_code ||
                                                               ' to ' ||
                                                               vc_contract_main_cur_code,
                                                               '',
                                                               gvc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
        
        end if;
      end if;
    
      insert into cipde_cipd_element_price
        (corporate_id,
         process_id,
         pcdi_id,
         internal_contract_item_ref_no,
         internal_contract_ref_no,
         contract_ref_no,
         delivery_item_no,
         element_id,
         assay_qty,
         assay_qty_unit_id,
         payable_qty,
         payable_qty_unit_id,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         fixed_qty,
         unfixed_qty,
         price_basis,
         price_fixation_status,
         price_fixation_details,
         payment_due_date,
         contract_base_price_unit_id,
         contract_to_base_fx_rate,
         price_description,
         refining_charge,
         treatment_charge,
         penalty_charge,
         cur_id,
         cur_code,
         qp_period_from_date,
         qp_period_to_date,
         instrument_id)
      values
        (pc_corporate_id,
         pc_process_id,
         cur_pcdi_rows.pcdi_id,
         cur_pcdi_rows.internal_contract_item_ref_no,
         cur_pcdi_rows.internal_contract_ref_no,
         cur_pcdi_rows.contract_ref_no,
         cur_pcdi_rows.delivery_item_no,
         cur_pcdi_rows.element_id,
         cur_pcdi_rows.assay_qty,
         cur_pcdi_rows.assay_qty_unit_id,
         cur_pcdi_rows.payable_qty,
         cur_pcdi_rows.payable_qty_unit_id,
         vn_avarage_price,
         vc_price_unit_id,
         vc_price_cur_id,
         vc_price_cur_code,
         vc_price_weight_unit,
         vc_price_weight_unit_id,
         vc_price_qty_unit,
         null,
         null,
         vc_price_basis,
         vc_price_fixation_status,
         'Not Applicable',
         cur_pcdi_rows.payment_due_date,
         vn_contract_base_price_unit_id,
         vn_settlement_price,
         vc_price_description,
         null,
         null,
         null,
         null,
         null,
         vd_qp_start_date,
         vd_qp_end_date,
         cur_pcdi_rows.instrument_id);
    
    end loop;
    commit;
    --Checking for the treatment  is there or not
    --For this  we are calling the sp_get_treatment_charge
    /*  for cc1 in (select tmpc.internal_contract_item_ref_no,
                         tmpc.conc_product_id,
                         tmpc.conc_quality_id,
                         tmpc.element_id,
                                       tmpc.product_id,
                                       tmpc.quality_id,
                                       pc_process_id,
                                       pci.item_qty,
                                       pci.item_qty_unit_id,
                                       vn_cp_price,
                                       vc_cp_price_unit_id
                                        from tmpc_temp_m2m_pre_check tmpc,
                                                  pci_physical_contract_item    pci
                                                  where  pci.internal_contract_item_ref_no=
                                                  tmpc.internal_contract_item_ref_no
                                                  and tmpc.product_type='CONCENTRATES' ) loop      
      sp_get_treatment_charge(cc1.internal_contract_item_ref_no,
                                                             cc1.element_id,
                                                             pc_process_id,
                                                             cc1.item_qty,
                                                             cc1.item_qty_unit_id,
                                                             cc1.vn_cp_price,
                                                             cc1.vc_cp_price_unit_id,
                                                             vn_total_tc_charge,
                                                             vc_tc_cur_id);
                                                             
      --if  vn_total_tc_charge  is zero or null we have to raise the exception
      --else 
      if nvl(vn_total_tc_charge,0)<>0   then
         update md_m2m_daily md
         set md.treatment_charge=vn_total_tc_charge
         where md.corporate_id =pc_corporate_id
           and md.product_type='CONCENTRATES'
           and md.conc_product_id=cc1.conc_product_id
           and md.conc_quality_id=cc1.conc_quality_id
           and md.product_id=cc1.product_id
           and md.quality_id=cc1.quality_id
           and md.element_id=cc1.element_id
           and md.process_id=pc_process_id;
          end if;
    end loop;
    
    --Check theRefine Charege is there or not
    --If Refine charge  is  there we will update the md table
    --for this we are calling the sp_get_refine_chage
    for cc_rc  in (select tmpc.internal_contract_item_ref_no,
                                       tmpc.conc_product_id,
                                       tmpc.conc_quality_id,
                                       tmpc.element_id,
                                       tmpc.product_id,
                                       tmpc.quality_id,
                                       pc_process_id,
                                       pci.item_qty,
                                       pci.item_qty_unit_id,
                                       vn_cp_price,
                                       vc_cp_price_unit_id
                                        from tmpc_temp_m2m_pre_check tmpc,
                                                  pci_physical_contract_item    pci
                                                  where  pci.internal_contract_item_ref_no=
                                                  tmpc.internal_contract_item_ref_no
                                                  and tmpc.product_type='CONCENTRATES' ) loop      
      sp_get_refine_charge( cc_rc.internal_contract_item_ref_no,
                                                              cc_rc.element_id,
                                                             pc_process_id,
                                                              cc_rc.item_qty,
                                                              cc_rc.item_qty_unit_id,
                                                              cc_rc.vn_cp_price,
                                                              cc_rc.vc_cp_price_unit_id,
                                                             vn_total_rc_charge,
                                                             vc_tc_cur_id);
                                                             
      --if  vn_total_tc_charge  is zero or null we have to raise the exception
      --else we have to update the md table
      if nvl(vn_total_rc_charge,0)<>0   then
         update md_m2m_daily md
         set md.refine_charge=vn_total_rc_charge
         where md.corporate_id =pc_corporate_id
           and md.product_type='CONCENTRATES'
           and md.conc_product_id= cc_rc.conc_product_id
           and md.conc_quality_id= cc_rc.conc_quality_id
           and md.product_id= cc_rc.product_id
           and md.quality_id= cc_rc.quality_id
           and md.element_id= cc_rc.element_id
           and md.process_id=pc_process_id;
          end if;
    end loop;
    --calling the sp_get_penalty_charge
    for cc_pc  in (select tmpc.internal_contract_item_ref_no,
                                       tmpc.conc_product_id,
                                       tmpc.conc_quality_id,
                                       tmpc.element_id,
                                       tmpc.product_id,
                                       tmpc.quality_id,
                                       pc_process_id,
                                       pci.item_qty,
                                       pci.item_qty_unit_id,
                                       vn_cp_price,
                                       vc_cp_price_unit_id
                                        from tmpc_temp_m2m_pre_check tmpc,
                                                  pci_physical_contract_item    pci
                                                  where  pci.internal_contract_item_ref_no=
                                                  tmpc.internal_contract_item_ref_no
                                                  and tmpc.product_type='CONCENTRATES' ) loop  
      sp_get_penalty_charge( cc_pc.internal_contract_item_ref_no,
                                                         cc_pc.element_id,
                                                         pc_process_id,
                                                         cc_pc.item_qty,
                                                         cc_pc.item_qty_unit_id,
                                                         vn_total_pc_charge,
                                                         vc_pc_cur_id);
                                                             
      --if  vn_total_pc_charge  is zero or null we have to raise the exception
      --else we have to update the md table
      if nvl(vn_total_pc_charge,0)<> 0   then
         update md_m2m_daily md
         set md.penalty_charge=vn_total_pc_charge
         where md.corporate_id =pc_corporate_id
           and md.product_type='CONCENTRATES'
           and md.conc_product_id= cc_pc.conc_product_id
           and md.conc_quality_id= cc_pc.conc_quality_id
           and md.product_id= cc_pc.product_id
           and md.quality_id= cc_pc.quality_id
           and md.element_id= cc_pc.element_id
           and md.process_id=pc_process_id;
          end if;
    end loop;*/
  
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
  
    update agd_alloc_group_detail
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update agh_alloc_group_header
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update cigc_contract_item_gmr_cost
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update cs_cost_store
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update dgrd_delivered_grd
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update gmr_goods_movement_record
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update mogrd_moved_out_grd
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcad_pc_agency_detail
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcbpd_pc_base_price_detail
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcbph_pc_base_price_header
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcdb_pc_delivery_basis
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcdd_document_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcdiob_di_optional_basis
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcdipe_di_pricing_elements
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcdiqd_di_quality_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcdi_pc_delivery_item
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcipf_pci_pricing_formula
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pci_physical_contract_item
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcjv_pc_jv_detail
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcm_physical_contract_main
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcpdqd_pd_quality_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcpd_pc_product_definition
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcpq_pc_product_quality
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcqpd_pc_qual_premium_discount
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pffxd_phy_formula_fx_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pfqpp_phy_formula_qp_pricing
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update ppfd_phy_price_formula_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update ppfh_phy_price_formula_header
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update ciqs_contract_item_qty_status
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update diqs_delivery_item_qty_status
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update cqs_contract_qty_status
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update grd_goods_record_detail
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update vd_voyage_detail
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update invm_inventory_master
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcpch_pc_payble_content_header
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pqd_payable_quality_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcepc_pc_elem_payable_content
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcth_pc_treatment_header
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update ted_treatment_element_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update tqd_treatment_quality_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
    update tqd_treatment_quality_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcetc_pc_elem_treatment_charge
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcar_pc_assaying_rules
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcaesl_assay_elem_split_limits
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update arqd_assay_quality_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcaph_pc_attr_penalty_header
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcap_pc_attribute_penalty
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pqd_penalty_quality_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pad_penalty_attribute_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcrh_pc_refining_header
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update rqd_refining_quality_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update red_refining_element_details
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update pcerc_pc_elem_refining_charge
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
    update ceqs_contract_ele_qty_status
       set process_id = pc_process_id
     where process_id is null
       and dbd_id = vc_dbd_id;
  
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
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    --updating the  cs_cost_store table
    for cc1 in (select cog.cog_ref_no,
                       cog.qty,
                       cog.qty_unit_id,
                       cs.internal_cost_id,
                       cs.transaction_amt,
                       cs.transaction_amt_cur_id,
                       pum.price_unit_id,
                       cs.rate_type,
                       round(cs.transaction_amt / cog.qty, 10) transaction_cost
                  from cigc_contract_item_gmr_cost cog,
                       cs_cost_store               cs,
                       pum_price_unit_master       pum
                 where cog.int_contract_item_ref_no is not null
                   and cog.process_id = pc_process_id
                   and cog.cog_ref_no = cs.cog_ref_no
                   and cog.qty_unit_id = pum.weight_unit_id
                   and cs.transaction_amt_cur_id = pum.cur_id
                      --   AND cs.rate_type = 'Absolute'
                   and nvl(pum.weight, 1) = 1)
    loop
      if cc1.rate_type = 'Absolute' then
        update cs_cost_store css
           set css.cost_in_transact_price_unit_id = cc1.transaction_cost;
      end if;
      update cs_cost_store css
         set css.transaction_price_unit_id = cc1.price_unit_id;
    end loop;
  
    insert into cisc_contract_item_sec_cost
      (internal_contract_item_ref_no,
       cost_component_id,
       avg_cost,
       process_id,
       secondary_cost,
       avg_cost_in_trn_cur,
       avg_cost_price_unit_id)
      select pci.internal_contract_item_ref_no,
             cs.cost_component_id,
             cs.cost_in_base_price_unit_id,
             pc_process_id,
             cs.cost_value secondary_cost,
             cs.cost_in_transact_price_unit_id,
             cs.transaction_price_unit_id
        from cs_cost_store               cs,
             cigc_contract_item_gmr_cost cigc,
             pcdi_pc_delivery_item       pcdi,
             pci_physical_contract_item  pci,
             pcm_physical_contract_main  pcm,
             scm_service_charge_master   scm
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
         and cs.cost_type = 'Estimate';
    --For GMR
    insert into gsc_gmr_sec_cost
      (internal_gmr_ref_no,
       cost_component_id,
       avg_cost,
       process_id,
       secondary_cost,
       parent_gmr_ref_no,
       internal_contract_item_ref_no,
       avg_cost_in_trn_cur,
       avg_cost_price_unit_id)
      select cigc.internal_gmr_ref_no,
             cs.cost_component_id,
             cs.cost_in_base_price_unit_id,
             pc_process_id process_id,
             0 secondary_cost,
             null parent_gmr_ref_no,
             cigc.int_contract_item_ref_no,
             cs.cost_in_transact_price_unit_id,
             cs.transaction_price_unit_id
        from cs_cost_store               cs,
             cigc_contract_item_gmr_cost cigc,
             scm_service_charge_master   scm
       where cs.cog_ref_no = cigc.cog_ref_no
         and cs.is_deleted = 'N'
         and cigc.is_deleted = 'N'
         and cigc.process_id = pc_process_id
         and cs.process_id = pc_process_id
         and cigc.internal_gmr_ref_no is not null
         and cs.cost_component_id = scm.cost_id
         and scm.cost_type = 'SECONDARY_COST'
         and cs.cost_type <> 'Estimate';
  exception
    when others then
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
    --vc_ldc_cur_id      varchar2(15);
    --vc_ldc_weight      number(7,2);
    --vc_weight_unit_id  varchar2(15);
    vc_err_msg          varchar2(100);
    vn_qat_premimum_amt number(25, 5);
    vn_pdm_premimum_amt number(25, 5);
  begin
    --generate unique m2m data with m2m id
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
                        t.base_price_unit_id_in_pum
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
                           t.base_price_unit_id_in_pum)
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
           valuation_method)
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
           cc.value_type);
        vn_serial_no := vn_serial_no + 1;
      end loop;
      --*******************************************************************************
      -- tmef gives rate between main currency only
      -- convert contract sub to main
      -- convert back the whole unit to m2m price unit ...whcih is why we have put a 1 divided by
      --
    
      --Checking for the Quality premimum is there or not
      --For this  we are calling the sp_calc_m2m_quality_premimum
      for cc1 in (select tmpc.corporate_id,
                         tmpc.mvp_id,
                         tmpc.valuation_point,
                         tmpc.shipment_month,
                         tmpc.shipment_year,
                         tmpc.instrument_id,
                         tmpc.base_price_unit_id_in_ppu,
                         tmpc.quality_id,
                         tmpc.product_id,
                         pdm.product_desc,
                         qat.quality_name
                    from tmpc_temp_m2m_pre_check tmpc,
                         qat_quality_attributes  qat,
                         pdm_productmaster       pdm
                   where tmpc.corporate_id = pc_corporate_id
                     and tmpc.quality_id = qat.quality_id
                     and tmpc.product_id = pdm.product_id
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
                            pdm.product_desc,
                            qat.quality_name)
      loop
        pkg_phy_pre_check_process.sp_calc_m2m_quality_premimum(pc_corporate_id,
                                                               pd_trade_date,
                                                               cc1.mvp_id,
                                                               cc1.quality_id,
                                                               cc1.product_id,
                                                               cc1.base_price_unit_id_in_ppu,
                                                               cc1.shipment_month,
                                                               cc1.shipment_year,
                                                               pc_user_id,
                                                               'EOD',
                                                               vn_qat_premimum_amt);
        --if  vn_qty_premimum_amt is zero or null we have to raise the exception
        --else not
        if vn_qat_premimum_amt is not null then
          update md_m2m_daily md
             set md.m2m_quality_premium = vn_qat_premimum_amt
           where md.corporate_id = cc1.corporate_id
             and md.product_id = cc1.product_id
             and md.quality_id = cc1.quality_id
             and md.shipment_month_year =
                 cc1.shipment_month || '-' || cc1.shipment_year
             and md.mvp_id = cc1.mvp_id
             and md.process_id = pc_process_id;
        end if;
      end loop;
      --  vn_qat_premimum_amt number(25,5);
      -- vn_pdm_premimum_amt number(25,5);
      --Check the product premimum
      --If Product premimum is not there we will rise the error
      --for this we are calling the sp_calc_product_premimum
      for cc2 in (select tmpc.corporate_id,
                         tmpc.product_id,
                         pdm.product_desc,
                         tmpc.base_price_unit_id_in_ppu,
                         tmpc.shipment_month,
                         tmpc.shipment_year
                    from tmpc_temp_m2m_pre_check tmpc,
                         pdm_productmaster       pdm
                   where tmpc.corporate_id = pc_corporate_id
                     and tmpc.product_id = pdm.product_id
                     and tmpc.product_type = 'BASEMETAL'
                   group by tmpc.corporate_id,
                            tmpc.product_id,
                            pdm.product_desc,
                            tmpc.base_price_unit_id_in_ppu,
                            tmpc.shipment_month,
                            tmpc.shipment_year)
      loop
        pkg_phy_pre_check_process.sp_calc_m2m_product_premimum(cc2.corporate_id,
                                                               pd_trade_date,
                                                               cc2.product_id,
                                                               cc2.shipment_month,
                                                               cc2.shipment_year,
                                                               pc_user_id,
                                                               'EOD',
                                                               cc2.base_price_unit_id_in_ppu,
                                                               vn_pdm_premimum_amt);
        if vn_pdm_premimum_amt is not null then
          update md_m2m_daily md
             set md.m2m_product_premium = vn_pdm_premimum_amt
           where md.corporate_id = cc2.corporate_id
             and md.product_id = cc2.product_id
             and md.shipment_month_year =
                 cc2.shipment_month || '-' || cc2.shipment_year
             and md.process_id = pc_process_id;
        end if;
      
      end loop;
      vc_err_msg := 'line 2819';
      update md_m2m_daily md
         set (md.valuation_exchange_id, md.m2m_settlement_price, md.m2m_sett_price_available_date) = (select pdd.exchange_id,
                                                                                                             edq.price,
                                                                                                             edq.dq_trade_date
                                                                                                        from eodeom_derivative_quote_detail edq,
                                                                                                             pum_price_unit_master          pum,
                                                                                                             dim_der_instrument_master      dim,
                                                                                                             div_der_instrument_valuation   div,
                                                                                                             pdd_product_derivative_def     pdd
                                                                                                       where edq.dr_id =
                                                                                                             md.valuation_dr_id
                                                                                                         and edq.corporate_id =
                                                                                                             pc_corporate_id
                                                                                                         and dim.instrument_id =
                                                                                                             md.instrument_id
                                                                                                         and edq.instrument_id =
                                                                                                             div.instrument_id
                                                                                                         and dim.product_derivative_id =
                                                                                                             pdd.derivative_def_id
                                                                                                         and edq.price_source_id =
                                                                                                             div.price_source_id
                                                                                                         and div.is_deleted = 'N'
                                                                                                         and edq.available_price_id =
                                                                                                             div.available_price_id
                                                                                                         and edq.price_unit_id =
                                                                                                             pum.price_unit_id
                                                                                                         and edq.price is not null
                                                                                                         and edq.process_id =
                                                                                                             pc_process_id
                                                                                                         and edq.dq_trade_date =
                                                                                                             pd_trade_date)
      
       where md.corporate_id = pc_corporate_id
         and md.valuation_method <> 'FIXED'
         and md.process_id = pc_process_id;
      ----
      vc_err_msg := 'line 2887';
    
      -- dbms_output.put_line('after update -3 ');
      --update the m2m location -incoterm deviation for the within region of growth
    
      update md_m2m_daily md
         set md.m2m_loc_incoterm_deviation = nvl((select sum(ldc.cost_value /
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
                                                    and md.product_id =
                                                        ldh.product_id
                                                    and md_base.price_unit_id =
                                                        md.base_price_unit_id_in_pum
                                                    and ldh.inco_term_id =
                                                        md.valuation_incoterm_id
                                                    and md.product_type =
                                                        'BASEMETAL'
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
                                                 0)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'BASEMETAL'
         and md.process_id = pc_process_id;
      vc_err_msg := 'line 3049';
      -- dbms_output.put_line('after update -4 ');
      --sp_write_log(pc_corporate_id, pd_trade_date, 'sp_calc_m2m', 'before 4');
      -----------calulate the net m2m diff for all the rows in md tabel
      /* update md_m2m_daily md
        set md.net_m2m_price = ((case when upper(md.valuation_method) = 'DIFFERENTIAL' then --
             nvl(md.m2m_settlement_price, 0) else 0 end)) + nvl(md.m2m_diff, 0) + --
             nvl(md.m2m_loc_incoterm_deviation, 0)
      where md.corporate_id = pc_corporate_id
        and md.process_id = pc_process_id;*/
      update md_m2m_daily md
         set md.net_m2m_price = nvl(md.m2m_settlement_price, 0)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'BASEMETAL'
         and md.process_id = pc_process_id;
      --   dbms_output.put_line('after update -5 ');
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 5');
      vc_err_msg := 'line 3068';
      --update valuation_location, reference_location and valuation_incoterm
      update md_m2m_daily md
         set (valuation_location, reference_location, valuation_incoterm, valuation_location_country, reference_location_country) = (select cim_val_loc.city_name,
                                                                                                                                            cim_ref_loc.city_name,
                                                                                                                                            itm.incoterm,
                                                                                                                                            cim_val_loc_v.country_name,
                                                                                                                                            cim_ref_loc_r.country_name
                                                                                                                                       from cim_citymaster      cim_val_loc,
                                                                                                                                            cim_citymaster      cim_ref_loc,
                                                                                                                                            cym_countrymaster   cim_val_loc_v,
                                                                                                                                            cym_countrymaster   cim_ref_loc_r,
                                                                                                                                            itm_incoterm_master itm
                                                                                                                                      where md.valuation_city_id =
                                                                                                                                            cim_val_loc.city_id
                                                                                                                                        and md.product_type =
                                                                                                                                            'BASEMETAL'
                                                                                                                                        and md.refernce_location_id =
                                                                                                                                            cim_ref_loc.city_id
                                                                                                                                        and cim_val_loc_v.country_id =
                                                                                                                                            cim_val_loc.country_id
                                                                                                                                        and cim_ref_loc_r.country_id =
                                                                                                                                            cim_ref_loc.country_id
                                                                                                                                        and md.valuation_incoterm_id =
                                                                                                                                            itm.incoterm_id)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'BASEMETAL'
         and md.process_id = pc_process_id;
      vc_err_msg := 'line 3090';
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 6');
      --  dbms_output.put_line('after update -6 ');
      -- update derivative def id/name
      update md_m2m_daily md
         set (derivative_def_id, derivative_def_name) =
             -- set values
              (select pdd.derivative_def_id,
                      pdd.derivative_def_name
                 from dim_der_instrument_master  dim,
                      pdd_product_derivative_def pdd,
                      irm_instrument_type_master irm
                where dim.instrument_id = md.instrument_id
                  and dim.product_derivative_id = pdd.derivative_def_id
                  and dim.instrument_type_id = irm.instrument_type_id
                  and md.product_type = 'BASEMETAL'
                  and irm.instrument_type = 'Future'
                  and rownum <= 1)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'BASEMETAL'
         and md.process_id = pc_process_id;
      --  dbms_output.put_line('after update -7 ');
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
         set (md.m2m_main_cur_id, md.m2m_main_cur_code, md.m2m_main_cur_decimals, md.main_currency_factor) = (select (case
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
                                                                                                                        nvl(scd.factor,
                                                                                                                            1)
                                                                                                                       else
                                                                                                                        1
                                                                                                                     end) factor
                                                                                                                from cm_currency_master      cm,
                                                                                                                     scd_sub_currency_detail scd,
                                                                                                                     cm_currency_master      cm_1
                                                                                                               where cm.cur_id =
                                                                                                                     md.m2m_price_unit_cur_id
                                                                                                                 and cm.cur_id =
                                                                                                                     scd.sub_cur_id(+)
                                                                                                                 and scd.cur_id =
                                                                                                                     cm_1.cur_id(+))
       where md.process_id = pc_process_id
         and md.product_type = 'BASEMETAL';
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 8');
      --  dbms_output.put_line('after update -8 ');
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
                        md.rate_type
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
             and tmpc.product_type = 'BASEMETAL';
        
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
             and tmpc.instrument_id = c1.instrument_id
             and tmpc.shipment_date = c1.shipment_date
             and tmpc.shipment_month || '-' || tmpc.shipment_year =
                 c1.shipment_month_year
             and decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') =
                 c1.rate_type
             and tmpc.product_type = 'BASEMETAL';
        end if;
      end loop;
    end;
    --  dbms_output.put_line('after allll');
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
    vn_serial_no            number;
    vobj_error_log          tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count      number := 1;
    vc_err_msg              varchar2(100);
    vn_qat_premimum_amt     number(25, 5);
    vn_pdm_premimum_amt     number(25, 5);
    vn_cp_price             number;
    vc_cp_price_unit_id     varchar2(20);
    vn_total_pc_charge      number;
    vn_total_tc_charge      number;
    vn_total_rc_charge      number;
    vc_tc_cur_id            varchar2(20);
    vc_pc_cur_id            varchar2(20);
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
                        t.base_price_unit_id_in_pum
                   from tmpc_temp_m2m_pre_check  t,
                        pum_price_unit_master    pum,
                        cm_currency_master       cm,
                        qum_quantity_unit_master qum
                  where t.corporate_id = pc_corporate_id
                    and t.m2m_price_unit_id = pum.price_unit_id(+)
                    and pum.cur_id = cm.cur_id(+)
                    and pum.weight_unit_id = qum.qty_unit_id(+)
                    and t.product_type = 'CONCENTRATES'
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
                           t.base_price_unit_id_in_pum)
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
           valuation_method)
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
           cc.value_type);
        vn_serial_no := vn_serial_no + 1;
      end loop;
      --Checking for the treatment  is there or not
      --For this  we are calling the sp_get_treatment_charge
      /*  for cc1 in (select tmpc.internal_contract_item_ref_no,
                                         tmpc.conc_product_id,
                                         tmpc.conc_quality_id,
                                         tmpc.element_id,
                                         tmpc.product_id,
                                         tmpc.quality_id,
                                         pc_process_id,
                                         pci.item_qty,
                                         pci.item_qty_unit_id,
                                         vn_cp_price,
                                         vc_cp_price_unit_id
                                          from tmpc_temp_m2m_pre_check tmpc,
                                                    pci_physical_contract_item    pci
                                                    where  pci.internal_contract_item_ref_no=
                                                    tmpc.internal_contract_item_ref_no
                                                    and tmpc.product_type='CONCENTRATES' ) loop      
        sp_get_treatment_charge(cc1.internal_contract_item_ref_no,
                                                               cc1.element_id,
                                                               pc_process_id,
                                                               cc1.item_qty,
                                                               cc1.item_qty_unit_id,
                                                               cc1.vn_cp_price,
                                                               cc1.vc_cp_price_unit_id,
                                                               vn_total_tc_charge,
                                                               vc_tc_cur_id);
                                                               
        --if  vn_total_tc_charge  is zero or null we have to raise the exception
        --else 
        if nvl(vn_total_tc_charge,0)<>0   then
           update md_m2m_daily md
           set md.treatment_charge=vn_total_tc_charge
           where md.corporate_id =pc_corporate_id
             and md.product_type='CONCENTRATES'
             and md.conc_product_id=cc1.conc_product_id
             and md.conc_quality_id=cc1.conc_quality_id
             and md.product_id=cc1.product_id
             and md.quality_id=cc1.quality_id
             and md.element_id=cc1.element_id
             and md.process_id=pc_process_id;
            end if;
      end loop;
      
      --Check theRefine Charege is there or not
      --If Refine charge  is  there we will update the md table
      --for this we are calling the sp_get_refine_chage
      for cc_rc  in (select tmpc.internal_contract_item_ref_no,
                                         tmpc.conc_product_id,
                                         tmpc.conc_quality_id,
                                         tmpc.element_id,
                                         tmpc.product_id,
                                         tmpc.quality_id,
                                         pc_process_id,
                                         pci.item_qty,
                                         pci.item_qty_unit_id,
                                         vn_cp_price,
                                         vc_cp_price_unit_id
                                          from tmpc_temp_m2m_pre_check tmpc,
                                                    pci_physical_contract_item    pci
                                                    where  pci.internal_contract_item_ref_no=
                                                    tmpc.internal_contract_item_ref_no
                                                    and tmpc.product_type='CONCENTRATES' ) loop      
        sp_get_refine_charge( cc_rc.internal_contract_item_ref_no,
                                                                cc_rc.element_id,
                                                               pc_process_id,
                                                                cc_rc.item_qty,
                                                                cc_rc.item_qty_unit_id,
                                                                cc_rc.vn_cp_price,
                                                                cc_rc.vc_cp_price_unit_id,
                                                               vn_total_rc_charge,
                                                               vc_tc_cur_id);
                                                               
        --if  vn_total_tc_charge  is zero or null we have to raise the exception
        --else we have to update the md table
        if nvl(vn_total_rc_charge,0)<>0   then
           update md_m2m_daily md
           set md.refine_charge=vn_total_rc_charge
           where md.corporate_id =pc_corporate_id
             and md.product_type='CONCENTRATES'
             and md.conc_product_id= cc_rc.conc_product_id
             and md.conc_quality_id= cc_rc.conc_quality_id
             and md.product_id= cc_rc.product_id
             and md.quality_id= cc_rc.quality_id
             and md.element_id= cc_rc.element_id
             and md.process_id=pc_process_id;
            end if;
      end loop;
      --calling the sp_get_penalty_charge
      for cc_pc  in (select tmpc.internal_contract_item_ref_no,
                                         tmpc.conc_product_id,
                                         tmpc.conc_quality_id,
                                         tmpc.element_id,
                                         tmpc.product_id,
                                         tmpc.quality_id,
                                         pc_process_id,
                                         pci.item_qty,
                                         pci.item_qty_unit_id,
                                         vn_cp_price,
                                         vc_cp_price_unit_id
                                          from tmpc_temp_m2m_pre_check tmpc,
                                                    pci_physical_contract_item    pci
                                                    where  pci.internal_contract_item_ref_no=
                                                    tmpc.internal_contract_item_ref_no
                                                    and tmpc.product_type='CONCENTRATES' ) loop  
        sp_get_penalty_charge( cc_pc.internal_contract_item_ref_no,
                                                           cc_pc.element_id,
                                                           pc_process_id,
                                                           cc_pc.item_qty,
                                                           cc_pc.item_qty_unit_id,
                                                           vn_total_pc_charge,
                                                           vc_pc_cur_id);
                                                               
        --if  vn_total_pc_charge  is zero or null we have to raise the exception
        --else we have to update the md table
        if nvl(vn_total_pc_charge,0)<> 0   then
           update md_m2m_daily md
           set md.penalty_charge=vn_total_pc_charge
           where md.corporate_id =pc_corporate_id
             and md.product_type='CONCENTRATES'
             and md.conc_product_id= cc_pc.conc_product_id
             and md.conc_quality_id= cc_pc.conc_quality_id
             and md.product_id= cc_pc.product_id
             and md.quality_id= cc_pc.quality_id
             and md.element_id= cc_pc.element_id
             and md.process_id=pc_process_id;
            end if;
      end loop;*/
    
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
                                                              pn_charge_amt,
                                                              pc_charge_price_unit_id);
      
        /* if nvl(pn_charge_amt, 0) <> 0 then
        pn_charge_amt := round(pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                               pn_charge_amt,
                                                                               pc_charge_price_unit_id,
                                                                               cc_tmpc.base_price_unit_id_in_ppu,
                                                                               pd_trade_date),
                               cc_tmpc.decimals);*/
        update md_m2m_daily md
           set md.treatment_charge = pn_charge_amt,
               md.tc_price_unit_id = pc_charge_price_unit_id
         where md.corporate_id = pc_corporate_id
           and md.product_type = 'CONCENTRATES'
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
                                                              pn_charge_amt,
                                                              pc_charge_price_unit_id);
      
        /*if nvl(pn_charge_amt, 0) <> 0 then
        pn_charge_amt := round(pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                               pn_charge_amt,
                                                                               pc_charge_price_unit_id,
                                                                               cc_tmpc.base_price_unit_id_in_ppu,
                                                                               pd_trade_date),
                               cc_tmpc.decimals);*/
        update md_m2m_daily md
           set md.refine_charge    = pn_charge_amt,
               md.rc_price_unit_id = pc_charge_price_unit_id
         where md.corporate_id = pc_corporate_id
           and md.product_type = 'CONCENTRATES'
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
      -- updating penalty  charge  to the md table 
      /*for cc_penalty in (select tmpc.corporate_id,
                                tmpc.conc_product_id,
                                tmpc.conc_quality_id,
                                pdm.product_desc,
                                qat.quality_name,
                                qat.quality_id,
                                tmpc.product_id,
                                tmpc.shipment_month,
                                tmpc.shipment_year,
                                tmpc.mvp_id,
                                tmpc.valuation_point,
                                pqca.element_id,
                                tmpc.base_price_unit_id_in_ppu,
                                aml.attribute_name
                           from ash_assay_header               ash,
                                asm_assay_sublot_mapping       asm,
                                aml_attribute_master_list      aml,
                                pqca_pq_chemical_attributes    pqca,
                                rm_ratio_master                rm,
                                ppm_product_properties_mapping ppm,
                                tmpc_temp_m2m_pre_check        tmpc,
                                pdm_productmaster              pdm,
                                qat_quality_attributes         qat
                          where ash.ash_id = tmpc.assay_header_id
                            and tmpc.conc_product_id = pdm.product_id
                            and ash.ash_id = asm.ash_id
                            and asm.asm_id = pqca.asm_id
                            and pqca.unit_of_measure = rm.ratio_id
                            and pqca.element_id = aml.attribute_id
                            and ppm.attribute_id = aml.attribute_id
                            and tmpc.corporate_id = 'EKA'
                            and tmpc.conc_quality_id = qat.quality_id
                            and pqca.is_elem_for_pricing = 'N'
                            and pqca.is_active = 'Y'
                            and asm.is_active = 'Y'
                            and ppm.product_id = tmpc.conc_product_id
                            and nvl(ppm.deduct_for_wet_to_dry, 'N') = 'N'
                          group by tmpc.corporate_id,
                                   tmpc.conc_product_id,
                                   tmpc.conc_quality_id,
                                   pdm.product_desc,
                                   qat.quality_name,
                                   qat.quality_id,
                                   tmpc.product_id,
                                   tmpc.shipment_month,
                                   tmpc.shipment_year,
                                   tmpc.mvp_id,
                                   tmpc.valuation_point,
                                   tmpc.base_price_unit_id_in_ppu,
                                   pqca.element_id,
                                   aml.attribute_name)
      loop
      
        pkg_phy_pre_check_process.sp_calc_m2m_tc_pc_rc_charge(cc_penalty.corporate_id,
                                                              pd_trade_date,
                                                              cc_penalty.conc_product_id,
                                                              cc_penalty.conc_quality_id,
                                                              cc_penalty.mvp_id, --valuation_id
                                                              'Penalties', --charge_type
                                                              cc_penalty.element_id,
                                                              cc_penalty.shipment_month,
                                                              cc_penalty.shipment_year,
                                                              pn_charge_amt,
                                                              pc_charge_price_unit_id);
      
        if nvl(pn_charge_amt, 0) <> 0 then
          pn_charge_amt := pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                           pn_charge_amt,
                                                                           pc_charge_price_unit_id,
                                                                           cc_penalty.base_price_unit_id_in_ppu,
                                                                           pd_trade_date);
          update md_m2m_daily md
             set md.penalty_charge = pn_charge_amt
           where md.corporate_id = pc_corporate_id
             and md.product_type = 'CONCENTRATES'
             and md.conc_product_id = cc_penalty.conc_product_id
             and md.conc_quality_id = cc_penalty.conc_quality_id
             and md.product_id = cc_penalty.product_id
             and md.quality_id = cc_penalty.quality_id
             and md.shipment_month_year = cc_penalty.shipment_month || '-' ||
                 cc_penalty.shipment_year
             and md.mvp_id = cc_penalty.mvp_id
             and md.process_id = pc_process_id
             and md.element_id = cc_penalty.element_id
             and md.process_id = pc_process_id;
        end if;
      
      end loop;*/
      /** End of updatin the Treatment Charge,Refine Charge and  Penalty Charge of the MD table ***/
      vc_err_msg := 'line 2819';
      --Updating exg_id,settlement_price,settlement price avl date of the md table
      update md_m2m_daily md
         set (md.valuation_exchange_id, md.m2m_settlement_price, md.m2m_sett_price_available_date) = (select pdd.exchange_id,
                                                                                                             edq.price,
                                                                                                             edq.dq_trade_date
                                                                                                        from eodeom_derivative_quote_detail edq,
                                                                                                             pum_price_unit_master          pum,
                                                                                                             dim_der_instrument_master      dim,
                                                                                                             div_der_instrument_valuation   div,
                                                                                                             pdd_product_derivative_def     pdd
                                                                                                       where edq.dr_id =
                                                                                                             md.valuation_dr_id
                                                                                                         and edq.corporate_id =
                                                                                                             pc_corporate_id
                                                                                                         and dim.instrument_id =
                                                                                                             md.instrument_id
                                                                                                         and edq.instrument_id =
                                                                                                             div.instrument_id
                                                                                                         and dim.product_derivative_id =
                                                                                                             pdd.derivative_def_id
                                                                                                         and edq.price_source_id =
                                                                                                             div.price_source_id
                                                                                                         and div.price_unit_id =
                                                                                                             edq.price_unit_id
                                                                                                         and div.is_deleted = 'N'
                                                                                                         and edq.available_price_id =
                                                                                                             div.available_price_id
                                                                                                         and edq.price_unit_id =
                                                                                                             pum.price_unit_id
                                                                                                         and edq.price is not null
                                                                                                         and edq.process_id =
                                                                                                             pc_process_id
                                                                                                         and edq.dq_trade_date =
                                                                                                             pd_trade_date)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'CONCENTRATES'
         and md.valuation_method <> 'FIXED'
         and md.process_id = pc_process_id;
    
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
         and md.process_id = pc_process_id;
      vc_err_msg := 'line 3049';
      update md_m2m_daily md
         set md.net_m2m_price = nvl(md.m2m_settlement_price, 0)
       where md.corporate_id = pc_corporate_id
         and md.product_type = 'CONCENTRATES'
         and md.process_id = pc_process_id;
      --   dbms_output.put_line('after update -5 ');
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 5');
      vc_err_msg := 'line 3068';
      --update valuation_location, reference_location and valuation_incoterm
      update md_m2m_daily md
         set (valuation_location, reference_location, valuation_incoterm, valuation_location_country, reference_location_country) = (select cim_val_loc.city_name,
                                                                                                                                            cim_ref_loc.city_name,
                                                                                                                                            itm.incoterm,
                                                                                                                                            cim_val_loc_v.country_name,
                                                                                                                                            cim_ref_loc_r.country_name
                                                                                                                                       from cim_citymaster      cim_val_loc,
                                                                                                                                            cim_citymaster      cim_ref_loc,
                                                                                                                                            cym_countrymaster   cim_val_loc_v,
                                                                                                                                            cym_countrymaster   cim_ref_loc_r,
                                                                                                                                            itm_incoterm_master itm
                                                                                                                                      where md.valuation_city_id =
                                                                                                                                            cim_val_loc.city_id
                                                                                                                                        and md.product_type =
                                                                                                                                            'CONCENTRATES'
                                                                                                                                        and md.refernce_location_id =
                                                                                                                                            cim_ref_loc.city_id
                                                                                                                                        and cim_val_loc_v.country_id =
                                                                                                                                            cim_val_loc.country_id
                                                                                                                                        and cim_ref_loc_r.country_id =
                                                                                                                                            cim_ref_loc.country_id
                                                                                                                                        and md.valuation_incoterm_id =
                                                                                                                                            itm.incoterm_id)
       where md.corporate_id = pc_corporate_id
         and md.process_id = pc_process_id;
      vc_err_msg := 'line 3090';
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 6');
      --  dbms_output.put_line('after update -6 ');
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
         and md.process_id = pc_process_id;
    
      --get the m2m_price_unit_cur_id
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 7');
      vc_err_msg := 'line 3121';
      update md_m2m_daily md
         set (md.m2m_main_cur_id, md.m2m_main_cur_code, md.m2m_main_cur_decimals, md.main_currency_factor) = (select (case
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
                                                                                                                        nvl(scd.factor,
                                                                                                                            1)
                                                                                                                       else
                                                                                                                        1
                                                                                                                     end) factor
                                                                                                                from cm_currency_master      cm,
                                                                                                                     scd_sub_currency_detail scd,
                                                                                                                     cm_currency_master      cm_1
                                                                                                               where cm.cur_id =
                                                                                                                     md.m2m_price_unit_cur_id
                                                                                                                 and cm.cur_id =
                                                                                                                     scd.sub_cur_id(+)
                                                                                                                 and scd.cur_id =
                                                                                                                     cm_1.cur_id(+))
       where md.process_id = pc_process_id
         and md.product_type = 'CONCENTRATES';
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_calc_m2m',
                   'before 8');
      --  dbms_output.put_line('after update -8 ');
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
             and tmpc.product_type = 'CONCENTRATES';
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
                --and tmpc.instrument_id = c1.instrument_id
             and tmpc.shipment_date = c1.shipment_date
             and tmpc.shipment_month || '-' || tmpc.shipment_year =
                 c1.shipment_month_year
             and decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') =
                 c1.rate_type
             and tmpc.product_type = 'CONCENTRATES';
        end if;
      end loop;
    end;
    --  dbms_output.put_line('after allll');
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
                                                           gvc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_calc_phy_open_unreal_pnl(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2) is
    cursor cur_unrealized is
      select pcm.corporate_id,
             akc.corporate_name,
             pc_process_id,
             pcdi.pcdi_id,
             pcdi.delivery_item_no,
             pcdi.prefix,
             pcdi.middle_no,
             pcdi.suffix,
             pcdi.internal_contract_ref_no,
             pcm.contract_ref_no,
             pcm.issue_date,
             pci.internal_contract_item_ref_no,
             pcdi.basis_type,
             pcdi.delivery_period_type,
             pcdi.delivery_from_month,
             pcdi.delivery_from_year,
             pcdi.delivery_to_month,
             pcdi.delivery_to_year,
             pcdi.delivery_from_date,
             pcdi.delivery_to_date,
             pcdi.transit_days,
             pcm.purchase_sales,
             pcm.contract_status,
             'Unrealized' unrealized_type,
             pcpd.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             pcm.cp_id,
             phd_cp.companyname cp_name,
             pcm.trader_id,
             (case
               when pcm.trader_id is not null then
                (select gab.firstname || ' ' || gab.lastname
                   from gab_globaladdressbook       gab,
                        ak_corporate_user@eka_appdb aku
                  where gab.gabid = aku.gabid
                    and aku.user_id = pcm.trader_id)
               else
                ''
             end) trader_user_name,
             pcpd.product_id,
             pdm.product_desc product_name,
             ciqs.open_qty item_qty,
             ciqs.item_qty_unit_id qty_unit_id,
             qum.qty_unit,
             pcpq.quality_template_id,
             qat.quality_name,
             pdm.product_desc,
             cipd.price_basis,
             pt.price_type_name,
             cipd.price_description price_description,
             pci.expected_delivery_month || '-' ||
             pci.expected_delivery_year item_delivery_period_string,
             cipd.price_basis fixation_method,
             cipd.price_fixation_status,
             pcdb.inco_term_id,
             itm.incoterm,
             pcdb.city_id origination_city_id,
             cim1.city_name origination_city,
             pcdb.country_id origination_country_id,
             cym1.country_name origination_country,
             pcdb.city_id destination_city_id,
             cim2.city_name destination_city,
             pcdb.country_id destination_country_id,
             cym2.country_name destination_country,
             rem_cym1.region_id origination_region_id,
             rem_cym1.region_name origination_region,
             rem_cym2.region_id destination_region_id,
             rem_cym2.region_name destination_region,
             pcm.payment_term_id,
             pym.payment_term,
             cipd.price_fixation_details as price_fixation_details,
             cipd.contract_price as contract_price,
             cipd.price_unit_id price_unit_id,
             cipd.price_unit_cur_id price_unit_cur_id,
             cipd.price_unit_cur_code price_unit_cur_code,
             cipd.price_unit_weight_unit_id,
             cipd.price_unit_weight price_unit_weight,
             cipd.price_unit_weight_unit price_unit_weight_unit,
             nvl(cipd.payment_due_date, pd_trade_date) payment_due_date,
             md.net_m2m_price net_m2m_price,
             md.m2m_price_unit_id,
             md.m2m_price_unit_cur_id,
             md.m2m_price_unit_cur_code,
             md.m2m_price_unit_weight,
             md.m2m_price_unit_weight_unit_id,
             md.m2m_price_unit_weight_unit,
             md.m2m_main_cur_id,
             md.m2m_main_cur_code,
             md.m2m_main_cur_decimals,
             md.main_currency_factor,
             0 m2m_amt, -- to do
             nvl((select sum(cisc.avg_cost)
                   from cisc_contract_item_sec_cost cisc
                  where cisc.internal_contract_item_ref_no =
                        pci.internal_contract_item_ref_no
                    and cisc.process_id = pc_process_id),
                 0) sc_in_base_cur, --to do
             cm.cur_id as base_cur_id,
             cm.cur_code as base_cur_code,
             md.md_id md_id,
             pd_trade_date eod_trade_date,
             gcd.groupid,
             gcd.groupname,
             cm_gcd.cur_id cur_id_gcd,
             cm_gcd.cur_code cur_code_gcd,
             qum_gcd.qty_unit_id qty_unit_id_gcd,
             qum_gcd.qty_unit qty_unit_gcd,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             pcpd.strategy_id,
             css.strategy_name,
             (ciqs.total_qty - nvl(ciqs.price_fixed_qty, 0)) unfxd_qty,
             ciqs.price_fixed_qty fxd_qty,
             md.derivative_def_id,
             md.valuation_exchange_id,
             md.valuation_dr_id,
             drm.dr_id_name,
             md.valuation_month,
             md.m2m_loc_incoterm_deviation,
             md.m2m_quality_premium,
             md.m2m_product_premium,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             nvl(md.m2m_loc_incoterm_deviation, 0) +
             nvl(md.m2m_quality_premium, 0) +
             nvl(md.m2m_product_premium, 0) total_premium,
             akc.base_currency_name,
             nvl(pcdb.premium, 0) delivery_premium,
             pcdb.premium_unit_id delivery_premium_unit_id
        from pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcdi_pc_delivery_item pcdi,
             pci_physical_contract_item pci,
             pcpd_pc_product_definition pcpd,
             cpc_corporate_profit_center cpc,
             phd_profileheaderdetails phd_cp,
             pdm_productmaster pdm,
             qum_quantity_unit_master qum,
             pcpq_pc_product_quality pcpq,
             pt_price_type pt,
             qat_quality_attributes qat,
             pcdb_pc_delivery_basis pcdb,
             itm_incoterm_master itm,
             cim_citymaster cim1,
             cim_citymaster cim2,
             cym_countrymaster cym1,
             cym_countrymaster cym2,
             rem_region_master@eka_appdb rem_cym1,
             rem_region_master@eka_appdb rem_cym2,
             pym_payment_terms_master pym,
             cipd_contract_item_price_daily cipd,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type = 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'BASEMETAL'
                 and md1.process_id = pc_process_id) md,
             drm_derivative_master drm,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'BASEMETAL'
                 and tmp.section_name = 'OPEN') tmpc,
             cm_currency_master cm,
             gcd_groupcorporatedetails gcd,
             cm_currency_master cm_gcd,
             qum_quantity_unit_master qum_gcd,
             qum_quantity_unit_master qum_pdm,
             css_corporate_strategy_setup css,
             ciqs_contract_item_qty_status ciqs
       where pcm.corporate_id = akc.corporate_id
         and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = pci.pcdi_id
         and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.profit_center_id = cpc.profit_center_id
         and pcm.cp_id = phd_cp.profileid
         and pcpd.product_id = pdm.product_id
         and pci.item_qty_unit_id = qum.qty_unit_id
         and pci.pcpq_id = pcpq.pcpq_id
         and pcpq.quality_template_id = qat.quality_id
         and cipd.price_basis = pt.price_type_id
         and pcdi.internal_contract_ref_no = pcdb.internal_contract_ref_no
         and pcdb.inco_term_id = itm.incoterm_id
         and pcdb.city_id = cim1.city_id(+)
         and pcdb.city_id = cim2.city_id(+)
         and pcdb.country_id = cym1.country_id(+)
         and pcdb.country_id = cym2.country_id(+)
         and cym1.region_id = rem_cym1.region_id(+)
         and cym2.region_id = rem_cym2.region_id(+)
         and pcm.payment_term_id = pym.payment_term_id
         and pci.internal_contract_item_ref_no =
             cipd.internal_contract_item_ref_no
         and akc.base_cur_id = cm.cur_id
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm_gcd.cur_id(+)
         and gcd.group_qty_unit_id = qum_gcd.qty_unit_id(+)
         and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         and pcpd.strategy_id = css.strategy_id
         and ciqs.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and pci.pcdb_id = pcdb.pcdb_id
         and pcm.corporate_id = pc_corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pcdb.is_active = 'Y'
         and ciqs.is_active = 'Y'
         and pcm.contract_type = 'BASEMETAL'
         and pcm.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and pcdb.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and ciqs.process_id = pc_process_id
         and cipd.process_id = pc_process_id
         and ciqs.open_qty > 0
         and pci.internal_contract_item_ref_no =
             tmpc.internal_contract_item_ref_no(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and md.valuation_dr_id = drm.dr_id(+);
  
    vn_m2m_amt                     number;
    vn_m2m_amt_open_exposure       number;
    vc_m2m_cur_id                  varchar2(15);
    vc_m2m_cur_code                varchar2(15);
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_m2m_sub_cur_id_factor       number;
    vn_m2m_cur_decimals            number;
    vn_cont_price_cur_id_factor    number;
    vn_cont_price_cur_decimals     number;
    vn_contract_value_in_price_cur number;
    vn_forward_exch_rate           number;
    vn_fw_fx_price_cur_to_m2m_cur  number;
    vn_val_to_base_corp_fx_rate    number;
    vn_base_to_val_fx_rate         number;
    vn_contract_value_in_val_cur   number;
    vn_sc_in_base_cur              number;
    vn_sc_in_valuation_cur         number;
    vn_expected_cog_in_val_cur     number;
    vn_unrealized_pnl_in_val_cur   number;
    vn_unrealized_pnl_in_base_cur  number;
    vc_base_price_unit             varchar2(15);
    vn_qty_in_base                 number;
    vn_unrealized_pnl_in_m2m_unit  number;
    vc_m2m_price_unit_id           varchar2(15);
    vc_m2m_price_unit_cur_id       varchar2(15);
    vc_m2m_price_unit_cur_code     varchar2(15);
    vc_m2m_price_unit_wgt_unit_id  varchar2(15);
    vc_m2m_price_unit_wgt_unit     varchar2(15);
    vn_m2m_price_unit_wgt_unit_wt  number;
    vn_contract_premium            number;
    vn_contract_premium_value      number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_m2m_base_fx_rate            number;
    vn_m2m_base_deviation          number;
    vn_m2m_amount_in_base          number;
    vn_m2m_total_amount            number;
    vn_m2m_total_premium_amt       number;
    vn_fx_price_to_base            number;
    vn_cont_delivery_premium       number;
    vn_cont_del_premium_amt        number;
    vn_contract_value_in_base_cur  number;
  
  begin
  
    for cur_unrealized_rows in cur_unrealized
    loop
      vn_cont_delivery_premium  := 0;
      vn_cont_del_premium_amt   := 0;
      vn_contract_premium       := 0;
      vn_contract_premium_value := 0;
      -- dbms_output.put_line('1');
      vn_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                                   cur_unrealized_rows.qty_unit_id,
                                                                   cur_unrealized_rows.base_qty_unit_id,
                                                                   1) *
                              cur_unrealized_rows.item_qty,
                              8);
      vn_m2m_amt     := nvl(cur_unrealized_rows.net_m2m_price, 0) /
                        nvl(cur_unrealized_rows.m2m_price_unit_weight, 1) *
                        pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                             cur_unrealized_rows.qty_unit_id,
                                                             cur_unrealized_rows.m2m_price_unit_weight_unit_id,
                                                             cur_unrealized_rows.item_qty);
      --  dbms_output.put_line('2');
      pkg_general.sp_get_main_cur_detail(nvl(cur_unrealized_rows.m2m_price_unit_cur_id,
                                             cur_unrealized_rows.base_cur_id),
                                         vc_m2m_cur_id,
                                         vc_m2m_cur_code,
                                         vn_m2m_sub_cur_id_factor,
                                         vn_m2m_cur_decimals);
      vn_m2m_amt := round(vn_m2m_amt * vn_m2m_sub_cur_id_factor, 2);
      --  dbms_output.put_line('3');
      pkg_general.sp_forward_cur_exchange_new(cur_unrealized_rows.corporate_id,
                                              pd_trade_date,
                                              cur_unrealized_rows.payment_due_date,
                                              vc_m2m_cur_id,
                                              cur_unrealized_rows.base_cur_id,
                                              30,
                                              vn_m2m_base_fx_rate,
                                              vn_m2m_base_deviation);
    
      if vc_m2m_cur_id <> cur_unrealized_rows.base_cur_id then
        if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
                                                               'PHY-005',
                                                               cur_unrealized_rows.base_cur_code ||
                                                               ' to ' ||
                                                               vc_m2m_cur_code,
                                                               '',
                                                               gvc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
        
        end if;
      end if;
    
      vn_m2m_amount_in_base    := vn_m2m_amt * vn_m2m_base_fx_rate;
      vn_m2m_total_premium_amt := vn_qty_in_base *
                                  cur_unrealized_rows.total_premium;
      vn_m2m_total_amount      := vn_m2m_amount_in_base +
                                  vn_m2m_total_premium_amt;
    
      --  dbms_output.put_line('4');
      pkg_general.sp_get_main_cur_detail(cur_unrealized_rows.price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
    
      vn_contract_value_in_price_cur := (cur_unrealized_rows.contract_price /
                                        nvl(cur_unrealized_rows.price_unit_weight,
                                             1)) *
                                        (pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                                              cur_unrealized_rows.qty_unit_id,
                                                                              cur_unrealized_rows.price_unit_weight_unit_id,
                                                                              cur_unrealized_rows.item_qty)) *
                                        vn_cont_price_cur_id_factor;
    
      --  vn_forward_exch_rate          := cur_unrealized_rows.cipd_fx_rate;
      --vn_fw_fx_price_cur_to_m2m_cur := vn_forward_exch_rate;
    
      --  dbms_output.put_line('5');
      pkg_general.sp_forward_cur_exchange_new(cur_unrealized_rows.corporate_id,
                                              pd_trade_date,
                                              cur_unrealized_rows.payment_due_date,
                                              vc_price_cur_id,
                                              cur_unrealized_rows.base_cur_id,
                                              30,
                                              vn_fx_price_to_base,
                                              vn_forward_exch_rate);
    
      /*if vc_price_cur_id <> cur_unrealized_rows.base_cur_id then
        if vn_fx_price_to_base is null or vn_fx_price_to_base = 0 then
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure pkg_phy_physical_process contract price',
                                                               'PHY-005',
                                                               cur_unrealized_rows.base_cur_code ||
                                                               ' to ' ||
                                                               vc_price_cur_code,
                                                               '',
                                                               gvc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
      
        end if;
      end if;*/
      -- contract value in value currency will store the data in base currency
      vn_contract_value_in_price_cur := round(vn_contract_value_in_price_cur,
                                              2);
    
      vn_contract_value_in_val_cur := round(vn_contract_value_in_price_cur *
                                            nvl(vn_fx_price_to_base, 1),
                                            2);
      begin
        select ppu.product_price_unit_id
          into vc_base_price_unit
          from v_ppu_pum ppu
         where ppu.cur_id = cur_unrealized_rows.base_cur_id
           and ppu.weight_unit_id = cur_unrealized_rows.base_qty_unit_id
           and nvl(ppu.weight, 1) = 1
           and ppu.product_id = cur_unrealized_rows.product_id;
      exception
        when others then
          sp_write_log(pc_corporate_id,
                       pd_trade_date,
                       'sp_open_phy_unreal',
                       'vc_base_price_unit' || vc_base_price_unit || ' For' ||
                       cur_unrealized_rows.contract_ref_no);
      end;
      vn_contract_premium := 0;
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_open_phy_unreal',
                   'QP in ' || vc_base_price_unit || ' For' ||
                   cur_unrealized_rows.contract_ref_no ||
                   cur_unrealized_rows.internal_contract_item_ref_no || ' ' ||
                   pd_trade_date || ' ' || cur_unrealized_rows.product_id ||
                   ' pc_process_id ' || pc_process_id);
      ------------------******** Premium Calculations starts here ******-------------------
      sp_calc_quality_premium(cur_unrealized_rows.internal_contract_item_ref_no,
                              vc_base_price_unit,
                              pc_corporate_id,
                              pd_trade_date,
                              cur_unrealized_rows.product_id,
                              pc_process_id,
                              vn_contract_premium);
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_open_phy_unreal',
                   'premium' || vc_base_price_unit || ' For' ||
                   cur_unrealized_rows.contract_ref_no ||
                   cur_unrealized_rows.internal_contract_item_ref_no ||
                   vn_contract_premium);
      --calculate contract delivery premium from pcdb
      -- dbms_output.put_line('2 ' || vn_contract_premium);
      if cur_unrealized_rows.delivery_premium <> 0 then
        if cur_unrealized_rows.delivery_premium_unit_id <>
           vc_base_price_unit then
          vn_cont_delivery_premium := cur_unrealized_rows.delivery_premium *
                                      pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                                      1,
                                                                                      cur_unrealized_rows.delivery_premium_unit_id,
                                                                                      vc_base_price_unit,
                                                                                      pd_trade_date);
        else
          vn_cont_delivery_premium := cur_unrealized_rows.delivery_premium;
        end if;
        vn_cont_del_premium_amt := round(vn_cont_delivery_premium *
                                         vn_qty_in_base,
                                         2);
      else
        vn_cont_delivery_premium := 0;
        vn_cont_del_premium_amt  := 0;
      end if;
      --  dbms_output.put_line('3 ' || vn_contract_premium_value);
      vn_contract_premium_value := round((vn_contract_premium *
                                         vn_qty_in_base) +
                                         vn_cont_del_premium_amt,
                                         2);
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_open_phy_unreal',
                   'vn_contract_premium_value ' || vc_base_price_unit ||
                   ' For' || cur_unrealized_rows.contract_ref_no ||
                   cur_unrealized_rows.internal_contract_item_ref_no ||
                   ' =  ' || vn_contract_premium_value);
      --calculate contract delivery premium from pcdb
      -- dbms_output.put_line('2 ' || vn_contract_premium);
      --  dbms_output.put_line('1 ' || vn_contract_premium_value);
      ------------------******** Premium Calculations ends here ******-------------------
      ---- Add premium to contract value,as vn_contract_value_in_val_cur is in base currency and vn_contract_premium_value also in base currency
      vn_contract_value_in_base_cur := vn_contract_value_in_val_cur;
      vn_contract_value_in_val_cur  := vn_contract_value_in_val_cur +
                                       vn_contract_premium_value;
      vn_sc_in_base_cur             := round(cur_unrealized_rows.sc_in_base_cur *
                                             vn_qty_in_base,
                                             2);
      vn_sc_in_valuation_cur        := vn_sc_in_base_cur;
    
      /* if cur_unrealized_rows.purchase_sales = 'P' then
        vn_contract_value_in_val_cur := (-1) * vn_contract_value_in_val_cur;
      else
        vn_contract_value_in_val_cur := vn_contract_value_in_val_cur;
      end if;*/
      -- as per the current implementation in basemetals, there is not Income/expense accruals separately
      -- so we need to ass conract value + SC  - done as on 05-Jul-2011, once we implement the 
      -- Income/expense accruals separately, we have to remove the abs from SC.
      -- vn_contract_value_in_val_cur := vn_contract_value_in_val_cur;
      vn_expected_cog_in_val_cur := round((abs(vn_contract_value_in_val_cur) +
                                          abs(vn_sc_in_valuation_cur)),
                                          2);
    
      if cur_unrealized_rows.purchase_sales = 'P' then
        vn_unrealized_pnl_in_val_cur := round((vn_m2m_total_amount -
                                              vn_expected_cog_in_val_cur),
                                              2);
      else
        vn_unrealized_pnl_in_val_cur := round((vn_expected_cog_in_val_cur -
                                              vn_m2m_total_amount),
                                              2);
      end if;
    
      vn_unrealized_pnl_in_base_cur := vn_unrealized_pnl_in_val_cur;
    
      -- below variable set as zero as it's not used in any calculation.
      vn_unrealized_pnl_in_m2m_unit := 0;
      vc_m2m_price_unit_id          := cur_unrealized_rows.m2m_price_unit_id;
      vc_m2m_price_unit_cur_id      := cur_unrealized_rows.m2m_price_unit_cur_id;
      vc_m2m_price_unit_cur_code    := cur_unrealized_rows.m2m_price_unit_cur_code;
      vc_m2m_price_unit_wgt_unit_id := cur_unrealized_rows.m2m_price_unit_weight_unit_id;
      vc_m2m_price_unit_wgt_unit    := cur_unrealized_rows.m2m_price_unit_weight_unit;
      vn_m2m_price_unit_wgt_unit_wt := cur_unrealized_rows.m2m_price_unit_weight;
    
      insert into poud_phy_open_unreal_daily
        (corporate_id,
         corporate_name,
         process_id,
         pcdi_id,
         delivery_item_no,
         prefix,
         middle_no,
         suffix,
         internal_contract_ref_no,
         contract_ref_no,
         contract_issue_date,
         internal_contract_item_ref_no,
         basis_type,
         delivery_period_type,
         delivery_from_month,
         delivery_from_year,
         delivery_to_month,
         delivery_to_year,
         delivery_from_date,
         delivery_to_date,
         transit_days,
         contract_type,
         approval_status,
         unrealized_type,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         cp_profile_id,
         cp_name,
         trade_user_id,
         trade_user_name,
         product_id,
         product_name,
         item_qty,
         qty_unit_id,
         qty_unit,
         quality_id,
         quality_name,
         product_desc,
         price_type_id,
         price_type_name,
         price_string,
         item_delivery_period_string,
         fixation_method,
         price_fixation_status,
         incoterm_id,
         incoterm,
         origination_city_id,
         origination_city,
         origination_country_id,
         origination_country,
         destination_city_id,
         destination_city,
         destination_country_id,
         destination_country,
         origination_region_id,
         origination_region,
         destination_region_id,
         destination_region,
         payment_term_id,
         payment_term,
         price_fixation_details,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight,
         price_unit_weight_unit,
         net_m2m_price,
         m2m_price_unit_id,
         m2m_price_cur_id,
         m2m_price_cur_code,
         m2m_price_weight,
         m2m_price_weght_unit_id,
         m2m_price_weight_unit,
         contract_value_in_price_cur,
         contract_value_in_val_cur,
         price_main_cur_id,
         price_main_cur_code,
         valualtion_cur_id,
         valualtion_cur_code,
         m2m_amt,
         m2m_amt_cur_id,
         m2m_amt_cur_code,
         sc_in_valuation_cur,
         sc_in_base_cur,
         contract_premium_value,
         premium_cur_id,
         premium_cur_code,
         expected_cog_net_sale_value,
         unrealized_pnl_in_val_cur,
         unrealized_pnl_in_base_cur,
         prev_day_unr_pnl_in_val_cur,
         prev_day_unr_pnl_in_base_cur,
         trade_day_pnl_in_val_cur,
         trade_day_pnl_in_base_cur,
         base_cur_id,
         base_cur_code,
         expected_cog_in_val_cur,
         price_cur_to_val_cur_fx_rate,
         price_cur_to_base_cur_fx_rate,
         base_cur_to_val_cur_fx_rate,
         val_to_base_corp_fx_rate,
         spot_rate_val_cur_to_base_cur,
         unrealized_pnl_in_m2m_price_id,
         prev_unr_pnl_in_m2m_price_id,
         trade_day_pnl_in_m2m_price_id,
         realized_date,
         realized_price,
         realized_price_id,
         realized_price_cur_id,
         realized_price_cur_code,
         realized_price_weight,
         realized_price_weight_unit,
         realized_qty,
         realized_qty_id,
         realized_qty_unit,
         md_id,
         group_id,
         group_name,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         prev_item_qty,
         prev_qty_unit_id,
         cont_unr_status,
         unfxd_qty,
         fxd_qty,
         qty_in_base_unit,
         eod_trade_date,
         strategy_id,
         strategy_name,
         derivative_def_id,
         valuation_exchange_id,
         valuation_dr_id,
         valuation_dr_id_name,
         valuation_month,
         price_month,
         pay_in_cur_id,
         pay_in_cur_code,
         unreal_pnl_in_base_per_unit,
         unreal_pnl_in_val_cur_per_unit,
         realized_internal_stock_ref_no,
         sales_internal_gmr_ref_no,
         sales_gmr_ref_no)
      values
        (cur_unrealized_rows.corporate_id,
         cur_unrealized_rows.corporate_name,
         pc_process_id,
         cur_unrealized_rows.pcdi_id,
         cur_unrealized_rows.delivery_item_no,
         cur_unrealized_rows.prefix,
         cur_unrealized_rows.middle_no,
         cur_unrealized_rows.suffix,
         cur_unrealized_rows.internal_contract_ref_no,
         cur_unrealized_rows.contract_ref_no,
         cur_unrealized_rows.issue_date,
         cur_unrealized_rows.internal_contract_item_ref_no,
         cur_unrealized_rows.basis_type,
         cur_unrealized_rows.delivery_period_type,
         cur_unrealized_rows.delivery_from_month,
         cur_unrealized_rows.delivery_from_year,
         cur_unrealized_rows.delivery_to_month,
         cur_unrealized_rows.delivery_to_year,
         cur_unrealized_rows.delivery_from_date,
         cur_unrealized_rows.delivery_to_date,
         cur_unrealized_rows.transit_days,
         cur_unrealized_rows.purchase_sales,
         cur_unrealized_rows.contract_status,
         cur_unrealized_rows.unrealized_type,
         cur_unrealized_rows.profit_center_id,
         cur_unrealized_rows.profit_center_name,
         cur_unrealized_rows.profit_center_short_name,
         cur_unrealized_rows.cp_id,
         cur_unrealized_rows.cp_name,
         cur_unrealized_rows.trader_id,
         cur_unrealized_rows.trader_user_name,
         cur_unrealized_rows.product_id,
         cur_unrealized_rows.product_name,
         cur_unrealized_rows.item_qty,
         cur_unrealized_rows.qty_unit_id,
         cur_unrealized_rows.qty_unit,
         cur_unrealized_rows.quality_template_id,
         cur_unrealized_rows.quality_name,
         cur_unrealized_rows.product_desc,
         cur_unrealized_rows.price_basis,
         cur_unrealized_rows.price_type_name,
         cur_unrealized_rows.price_description,
         cur_unrealized_rows.item_delivery_period_string,
         cur_unrealized_rows.fixation_method,
         cur_unrealized_rows.price_fixation_status,
         cur_unrealized_rows.inco_term_id,
         cur_unrealized_rows.incoterm,
         cur_unrealized_rows.origination_city_id,
         cur_unrealized_rows.origination_city,
         cur_unrealized_rows.origination_country_id,
         cur_unrealized_rows.origination_country,
         cur_unrealized_rows.destination_city_id,
         cur_unrealized_rows.destination_city,
         cur_unrealized_rows.destination_country_id,
         cur_unrealized_rows.destination_country,
         cur_unrealized_rows.origination_region_id,
         cur_unrealized_rows.origination_region,
         cur_unrealized_rows.destination_region_id,
         cur_unrealized_rows.destination_region,
         cur_unrealized_rows.payment_term_id,
         cur_unrealized_rows.payment_term,
         cur_unrealized_rows.price_fixation_details,
         cur_unrealized_rows.contract_price,
         cur_unrealized_rows.price_unit_id,
         cur_unrealized_rows.price_unit_cur_id,
         cur_unrealized_rows.price_unit_cur_code,
         cur_unrealized_rows.price_unit_weight_unit_id,
         cur_unrealized_rows.price_unit_weight,
         cur_unrealized_rows.price_unit_weight_unit,
         cur_unrealized_rows.net_m2m_price,
         vc_m2m_price_unit_id,
         vc_m2m_price_unit_cur_id,
         vc_m2m_price_unit_cur_code,
         vn_m2m_price_unit_wgt_unit_wt,
         vc_m2m_price_unit_wgt_unit_id,
         vc_m2m_price_unit_wgt_unit,
         vn_contract_value_in_price_cur,
         vn_contract_value_in_val_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vc_m2m_price_unit_cur_id, -- valuation cur_id
         vc_m2m_price_unit_cur_code, -- valuation cur_code
         vn_m2m_total_amount,
         cur_unrealized_rows.base_cur_id,
         cur_unrealized_rows.base_cur_code,
         --  vc_m2m_cur_id,
         -- vc_m2m_cur_id,
         vn_sc_in_base_cur,
         vn_sc_in_valuation_cur,
         vn_contract_premium_value, -- contract premium value
         cur_unrealized_rows.base_cur_id, -- premium cur_id
         cur_unrealized_rows.base_cur_code, --premium cur_code
         vn_expected_cog_in_val_cur, -- expected_cog_net_sale_value
         vn_unrealized_pnl_in_val_cur,
         vn_unrealized_pnl_in_base_cur,
         0, --prev_day_unr_pnl_in_val_cur
         0, --prev_day_unr_pnl_in_base_cur
         0, --trade_day_pnl_in_val_cur
         0, --trade_day_pnl_in_base_cur
         cur_unrealized_rows.base_cur_id,
         cur_unrealized_rows.base_cur_code,
         vn_expected_cog_in_val_cur,
         vn_fw_fx_price_cur_to_m2m_cur,
         vn_fx_price_to_base, --price_cur_to_base_cur_fx_rate
         vn_base_to_val_fx_rate, --base_cur_to_val_cur_fx_rate
         vn_val_to_base_corp_fx_rate, --val_to_base_corp_fx_rate
         vn_m2m_base_fx_rate, --spot_rate_val_cur_to_base_cur
         vn_unrealized_pnl_in_m2m_unit, --unrealized_pnl_in_m2m_price_id
         0, --prev_unr_pnl_in_m2m_price_id
         0, --trade_day_pnl_in_m2m_price_id
         null, --realized_date
         null, --realized_price
         null, --realized_price_id
         null, --realized_price_cur_id
         null, --realized_price_cur_code
         null, --realized_price_weight
         null, --realized_price_weight_unit
         null, --realized_qty
         null, --realized_qty_id
         null, --realized_qty_unit
         cur_unrealized_rows.md_id,
         cur_unrealized_rows.groupid,
         cur_unrealized_rows.groupname,
         cur_unrealized_rows.cur_id_gcd,
         cur_unrealized_rows.cur_code_gcd,
         cur_unrealized_rows.qty_unit_id_gcd,
         cur_unrealized_rows.qty_unit_gcd,
         cur_unrealized_rows.base_qty_unit_id,
         cur_unrealized_rows.base_qty_unit,
         null, --prev_item_qty
         null, --prev_qty_unit_id
         null, --cont_unr_status
         cur_unrealized_rows.unfxd_qty,
         cur_unrealized_rows.fxd_qty,
         vn_qty_in_base,
         cur_unrealized_rows.eod_trade_date,
         cur_unrealized_rows.strategy_id,
         cur_unrealized_rows.strategy_name,
         cur_unrealized_rows.derivative_def_id,
         cur_unrealized_rows.valuation_exchange_id,
         cur_unrealized_rows.valuation_dr_id,
         cur_unrealized_rows.dr_id_name,
         cur_unrealized_rows.valuation_month,
         null, --price_month
         null, --pay_in_cur_id
         null, --pay_in_cur_code
         vn_unrealized_pnl_in_base_cur /
         decode(vn_qty_in_base, 0, 1, vn_qty_in_base), --unreal_pnl_in_base_per_unit
         vn_unrealized_pnl_in_val_cur /
         decode(vn_qty_in_base, 0, 1, vn_qty_in_base), --unreal_pnl_in_val_cur_per_unit
         null, --realized_internal_stock_ref_no
         null, --sales_internal_gmr_ref_no
         null -- sales_gmr_ref_no
         );
    end loop;
    ---------
    commit;
    sp_gather_stats('poud_phy_open_unreal_daily');
    begin
      -- update previous eod data
      for cur_update in (select poud_prev_day.internal_contract_item_ref_no,
                                poud_prev_day.unreal_pnl_in_base_per_unit,
                                poud_prev_day.unreal_pnl_in_val_cur_per_unit,
                                poud_prev_day.unrealized_pnl_in_m2m_price_id,
                                poud_prev_day.item_qty,
                                poud_prev_day.qty_unit_id,
                                poud_prev_day.unrealized_type,
                                poud_prev_day.m2m_amt_cur_id
                           from poud_phy_open_unreal_daily poud_prev_day
                          where poud_prev_day.process_id =
                                gvc_previous_process_id
                            and corporate_id = pc_corporate_id)
      loop
        update poud_phy_open_unreal_daily poud_today
           set poud_today.prev_day_unr_pnl_in_base_cur = cur_update.unreal_pnl_in_base_per_unit *
                                                         poud_today.qty_in_base_unit,
               poud_today.prev_day_unr_pnl_in_val_cur  = pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                                  cur_update.m2m_amt_cur_id,
                                                                                                  poud_today.m2m_amt_cur_id,
                                                                                                  pd_trade_date,
                                                                                                  cur_update.unreal_pnl_in_val_cur_per_unit),
               poud_today.prev_unr_pnl_in_m2m_price_id = cur_update.unrealized_pnl_in_m2m_price_id,
               poud_today.prev_item_qty                = cur_update.item_qty,
               poud_today.prev_qty_unit_id             = cur_update.qty_unit_id,
               poud_today.cont_unr_status              = 'EXISTING_TRADE'
         where poud_today.internal_contract_item_ref_no =
               cur_update.internal_contract_item_ref_no
           and poud_today.process_id = pc_process_id
           and poud_today.unrealized_type = cur_update.unrealized_type
           and poud_today.corporate_id = pc_corporate_id;
      end loop;
    exception
      when others then
        dbms_output.put_line('SQLERRM-1' || sqlerrm);
    end;
    -- mark the trades came as new in this eod/eom
    --dbms_output.put_line('mark the trades came as new in this eod/eom');
    begin
      update poud_phy_open_unreal_daily poud
         set poud.cont_unr_status = 'NEW_TRADE'
       where poud.cont_unr_status is null
         and poud.process_id = pc_process_id
         and poud.corporate_id = pc_corporate_id;
    exception
      when others then
        dbms_output.put_line('SQLERRM-2' || sqlerrm);
    end;
    -- dbms_output.put_line('inside update poud-2');
    update poud_phy_open_unreal_daily poud
       set poud.trade_day_pnl_in_val_cur  = nvl(poud.unrealized_pnl_in_val_cur,
                                                0) - nvl(poud.prev_day_unr_pnl_in_val_cur,
                                                         0),
           poud.trade_day_pnl_in_base_cur = nvl(poud.unrealized_pnl_in_base_cur,
                                                0) - nvl(poud.prev_day_unr_pnl_in_base_cur,
                                                         0)
     where poud.process_id = pc_process_id
       and poud.corporate_id = pc_corporate_id
       and poud.unrealized_type = 'Unrealized';
    -- dbms_output.put_line('finished...');
  exception
    when others then
      dbms_output.put_line('failed with ' || sqlerrm);
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_phy_open_unreal_pnl',
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

  procedure sp_calc_phy_opencon_unreal_pnl(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_user_id      varchar2,
                                           pc_dbd_id       varchar2) is
  
    cursor cur_unrealized is
      select pcm.corporate_id,
             akc.corporate_name,
             pc_process_id,
             pcdi.pcdi_id,
             pcdi.delivery_item_no,
             pcdi.prefix,
             pcdi.middle_no,
             pcdi.suffix,
             pcdi.internal_contract_ref_no,
             pcm.contract_ref_no,
             pcm.issue_date,
             pci.internal_contract_item_ref_no,
             pci.del_distribution_item_no,
             pcdi.basis_type,
             pcdi.delivery_period_type,
             pcdi.delivery_from_month,
             pcdi.delivery_from_year,
             pcdi.delivery_to_month,
             pcdi.delivery_to_year,
             pcdi.delivery_from_date,
             pcdi.delivery_to_date,
             pcdi.transit_days,
             pcm.purchase_sales,
             pcm.contract_status,
             'Unrealized' unrealized_type,
             pcpd.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             pcm.cp_id,
             phd_cp.companyname cp_name,
             pcm.trader_id,
             (case
               when pcm.trader_id is not null then
                (select gab.firstname || ' ' || gab.lastname
                   from gab_globaladdressbook       gab,
                        ak_corporate_user@eka_appdb aku
                  where gab.gabid = aku.gabid
                    and aku.user_id = pcm.trader_id)
               else
                ''
             end) trader_user_name,
             pcpd.product_id conc_product_id,
             aml.underlying_product_id product_id,
             pdm.product_desc product_name,
             ciqs.open_qty item_qty,
             ciqs.item_qty_unit_id qty_unit_id,
             qum.qty_unit,
             qum.decimals item_qty_decimal,
             pcpq.quality_template_id conc_quality_id,
             qav.comp_quality_id quality_id,
             qat_und.quality_name,
             pcdb.inco_term_id,
             itm.incoterm,
             pcdb.city_id origination_city_id,
             cim1.city_name origination_city,
             pcdb.country_id origination_country_id,
             cym1.country_name origination_country,
             pcdb.city_id destination_city_id,
             cim2.city_name destination_city,
             pcdb.country_id destination_country_id,
             cym2.country_name destination_country,
             rem_cym1.region_id origination_region_id,
             rem_cym1.region_name origination_region,
             rem_cym2.region_id destination_region_id,
             rem_cym2.region_name destination_region,
             pcm.payment_term_id,
             pym.payment_term,
             cm.cur_id as base_cur_id,
             cm.cur_code as base_cur_code,
             cm.decimals as base_cur_decimal,
             gcd.groupid,
             gcd.groupname,
             cm_gcd.cur_id cur_id_gcd,
             cm_gcd.cur_code cur_code_gcd,
             qum_gcd.qty_unit_id qty_unit_id_gcd,
             qum_gcd.qty_unit qty_unit_gcd,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             qum_pdm.decimals as base_qty_decimal,
             qum_pdm_conc.qty_unit_id as conc_base_qty_unit_id,
             qum_pdm_conc.qty_unit as conc_base_qty_unit,
             qum_pdm_conc.decimals as conc_base_qty_decimal,
             pcpd.strategy_id,
             css.strategy_name,
             cipde.element_id,
             aml.attribute_name,
             pcpq.assay_header_id,
             pcpq.unit_of_measure,
             cipde.assay_qty,
             cipde.assay_qty_unit_id,
             cipde.payable_qty,
             cipde.payable_qty_unit_id,
             cipde.contract_price,
             cipde.price_unit_id,
             cipde.price_unit_cur_id,
             cipde.price_unit_cur_code,
             cipde.price_unit_weight_unit_id,
             cipde.price_unit_weight,
             cipde.price_unit_weight_unit,
             --   cipde.treatment_charge,
             --  cipde.refining_charge,
             --  cipde.penalty_charge,
             cipde.price_basis fixation_method,
             cipde.price_description,
             cipde.price_fixation_status,
             cipde.price_fixation_details,
             nvl(cipde.payment_due_date, pd_trade_date) payment_due_date,
             pci.expected_delivery_month || '-' ||
             pci.expected_delivery_year item_delivery_period_string,
             md.net_m2m_price net_m2m_price,
             md.m2m_price_unit_id,
             md.m2m_price_unit_cur_id,
             md.m2m_price_unit_cur_code,
             md.m2m_price_unit_weight,
             md.m2m_price_unit_weight_unit_id,
             md.m2m_price_unit_weight_unit,
             md.m2m_main_cur_id,
             md.m2m_main_cur_code,
             md.m2m_main_cur_decimals,
             md.main_currency_factor,
             md.md_id,
             0 m2m_amt,
             nvl(md.treatment_charge, 0) m2m_treatment_charge, -- will be in base price unit id
             nvl(md.refine_charge, 0) m2m_refining_charge, -- will be in base price unit id
             nvl(md.penalty_charge, 0) m2m_penalty_charge, -- will be in base price unit id
             tc_ppu_pum.price_unit_id m2m_tc_price_unit_id,
             tc_ppu_pum.price_unit_name m2m_tc_price_unit_name,
             tc_ppu_pum.cur_id m2m_tc_cur_id,
             tc_ppu_pum.weight m2m_tc_weight,
             tc_ppu_pum.weight_unit_id m2m_tc_weight_unit_id,
             rc_ppu_pum.price_unit_id m2m_rc_price_unit_id,
             rc_ppu_pum.price_unit_name m2m_rc_price_unit_name,
             rc_ppu_pum.cur_id m2m_rc_cur_id,
             rc_ppu_pum.weight m2m_rc_weight,
             rc_ppu_pum.weight_unit_id m2m_rc_weight_unit_id,
             nvl((select sum(cisc.avg_cost)
                   from cisc_contract_item_sec_cost cisc
                  where cisc.internal_contract_item_ref_no =
                        pci.internal_contract_item_ref_no
                    and cisc.process_id = pc_process_id),
                 0) sc_in_base_cur,
             md.derivative_def_id,
             md.valuation_exchange_id,
             emt.exchange_name,
             md.valuation_dr_id,
             drm.dr_id_name,
             md.valuation_month,
             md.valuation_date,
             md.m2m_loc_incoterm_deviation,
             dense_rank() over(partition by pci.internal_contract_item_ref_no order by cipde.element_id) ele_rank,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             pum_base_price_id.price_unit_name base_price_unit_name,
             pum_loc_base.weight_unit_id loc_qty_unit_id,
             tmpc.mvp_id,
             tmpc.shipment_month,
             tmpc.shipment_year,
             nvl(pdm_conc.valuation_against_underlying, 'Y') valuation_against_underlying
        from pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcdi_pc_delivery_item pcdi,
             pci_physical_contract_item pci,
             pcpd_pc_product_definition pcpd,
             cpc_corporate_profit_center cpc,
             phd_profileheaderdetails phd_cp,
             pdm_productmaster pdm,
             ciqs_contract_item_qty_status ciqs,
             qum_quantity_unit_master qum,
             pcpq_pc_product_quality pcpq,
             qat_quality_attributes qat,
             qat_quality_attributes qat_und,
             qav_quality_attribute_values qav,
             ppm_product_properties_mapping ppm,
             aml_attribute_master_list aml,
             pcdb_pc_delivery_basis pcdb,
             itm_incoterm_master itm,
             cim_citymaster cim1,
             cim_citymaster cim2,
             cym_countrymaster cym1,
             cym_countrymaster cym2,
             rem_region_master@eka_appdb rem_cym1,
             rem_region_master@eka_appdb rem_cym2,
             pym_payment_terms_master pym,
             cm_currency_master cm,
             gcd_groupcorporatedetails gcd,
             cm_currency_master cm_gcd,
             qum_quantity_unit_master qum_gcd,
             qum_quantity_unit_master qum_pdm,
             pdm_productmaster pdm_conc,
             qum_quantity_unit_master qum_pdm_conc,
             css_corporate_strategy_setup css,
             pum_price_unit_master pum_base_price_id,
             pum_price_unit_master pum_loc_base,
             cipde_cipd_element_price cipde,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type = 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'CONCENTRATES'
                 and md1.process_id = pc_process_id) md,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'CONCENTRATES'
                 and tmp.section_name = 'OPEN') tmpc,
             drm_derivative_master drm,
             emt_exchangemaster emt,
             v_ppu_pum tc_ppu_pum,
             v_ppu_pum rc_ppu_pum
       where pcm.corporate_id = akc.corporate_id
         and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = pci.pcdi_id
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.profit_center_id = cpc.profit_center_id
         and pcm.cp_id = phd_cp.profileid
         and pci.internal_contract_item_ref_no =
             ciqs.internal_contract_item_ref_no
         and ciqs.item_qty_unit_id = qum.qty_unit_id
         and pci.pcpq_id = pcpq.pcpq_id
         and pcpq.quality_template_id = qat.quality_id
         and qat.quality_id = qav.quality_id
         and qav.attribute_id = ppm.property_id
         and qav.comp_quality_id = qat_und.quality_id
         and ppm.attribute_id = aml.attribute_id
         and aml.underlying_product_id = pdm.product_id
         and aml.attribute_id = cipde.element_id
         and pci.pcdb_id = pcdb.pcdb_id
         and pcdb.inco_term_id = itm.incoterm_id
         and pcdb.city_id = cim1.city_id(+)
         and pcdb.city_id = cim2.city_id(+)
         and pcdb.country_id = cym1.country_id(+)
         and pcdb.country_id = cym2.country_id(+)
         and cym1.region_id = rem_cym1.region_id(+)
         and cym2.region_id = rem_cym2.region_id(+)
         and pcm.payment_term_id = pym.payment_term_id
         and akc.base_cur_id = cm.cur_id
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm_gcd.cur_id(+)
         and gcd.group_qty_unit_id = qum_gcd.qty_unit_id(+)
         and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         and pcpd.product_id = pdm_conc.product_id
         and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
         and pcpd.strategy_id = css.strategy_id
         and pci.internal_contract_item_ref_no =
             cipde.internal_contract_item_ref_no
         and pci.internal_contract_item_ref_no =
             tmpc.internal_contract_item_ref_no(+)
         and tmpc.element_id = cipde.element_id
         and tmpc.internal_m2m_id = md.md_id(+)
         and md.element_id = cipde.element_id
         and md.valuation_dr_id = drm.dr_id(+)
         and md.valuation_exchange_id = emt.exchange_id(+)
         and pcm.corporate_id = pc_corporate_id
         and ciqs.open_qty > 0
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'CONCENTRATES'
         and pcm.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pcdb.is_active = 'Y'
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and ciqs.is_active = 'Y'
         and ppm.is_active = 'Y'
         and ppm.is_deleted = 'N'
         and qav.is_deleted = 'N'
         and qav.is_comp_product_attribute = 'Y'
         and qat.is_active = 'Y'
         and qat.is_deleted = 'N'
         and aml.is_active = 'Y'
         and aml.is_deleted = 'N'
         and qat_und.is_active = 'Y'
         and qat_und.is_deleted = 'N'
         and md.base_price_unit_id_in_pum = pum_base_price_id.price_unit_id
         and md.base_price_unit_id_in_pum = pum_loc_base.price_unit_id
         and md.tc_price_unit_id = tc_ppu_pum.product_price_unit_id
         and md.rc_price_unit_id = rc_ppu_pum.product_price_unit_id
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and ciqs.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and pcdb.process_id = pc_process_id
         and cipde.process_id = pc_process_id;
    vn_ele_qty_in_base             number;
    vn_ele_m2m_amt                 number;
    vc_m2m_cur_id                  varchar2(15);
    vc_m2m_cur_code                varchar2(15);
    vn_m2m_base_fx_rate            number;
    vn_m2m_base_deviation          number;
    vn_m2m_sub_cur_id_factor       number;
    vn_m2m_cur_decimals            number;
    vn_ele_m2m_amount_in_base      number;
    vn_ele_m2m_total_amount        number;
    vn_ele_m2m_total_premium_amt   number;
    vn_ele_m2m_premium_amt         number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_cont_price_cur_decimals     number;
    vn_ele_cont_value_in_price_cur number;
    vn_fx_price_to_base            number;
    vn_forward_exch_rate           number;
    vc_base_price_unit             varchar2(15);
    vn_ele_cont_premium            number;
    vn_ele_cont_total_premium      number;
    vn_ele_cont_value_in_base_cur  number;
    vn_ele_sc_in_base_cur          number;
    vn_ele_exp_cog_in_base_cur     number;
    vn_ele_unreal_pnl_in_base_cur  number;
    vn_unrealized_pnl_in_m2m_unit  number;
    vc_m2m_price_unit_id           varchar2(15);
    vc_m2m_price_unit_cur_id       varchar2(15);
    vc_m2m_price_unit_cur_code     varchar2(15);
    vc_m2m_price_unit_wgt_unit_id  varchar2(15);
    vc_m2m_price_unit_wgt_unit     varchar2(15);
    vn_m2m_price_unit_wgt_unit_wt  number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_dry_qty                     number;
    vn_wet_qty                     number;
    vn_m2m_total_amount            number;
    vn_cont_value_in_base_cur      number;
    vn_cont_total_premium          number;
    vn_sc_in_base_cur              number;
    vn_exp_cog_in_base_cur         number;
    vn_unreal_pnl_in_base_cur      number;
    vn_qty_in_base                 number;
    vn_con_treatment_charge        number;
    vc_con_treatment_cur_id        varchar2(15);
    vn_base_con_treatment_charge   number;
    vn_con_refine_charge           number;
    vc_con_refine_cur_id           varchar2(15);
    vn_base_con_refine_charge      number;
    vn_con_penality_charge         number;
    vn_base_con_penality_charge    number;
    vn_con_penality_per_elemet     number;
    vc_con_penality_cur_id         varchar2(15);
    vn_dry_qty_in_base             number;
    vn_ele_m2m_treatment_charge    number;
    vn_ele_m2m_refine_charge       number;
    vn_loc_amount                  number;
    vn_loc_total_amount            number;
    vn_penality                    number;
    vc_penality_price_unit_id      varchar2(20);
    vn_total_penality              number;
  
  begin
    for cur_unrealized_rows in cur_unrealized
    loop
    
      -- convert wet qty to dry qty
      if cur_unrealized_rows.unit_of_measure = 'Wet' then
        vn_dry_qty := round(pkg_metals_general.fn_get_assay_dry_qty(cur_unrealized_rows.conc_product_id,
                                                                    cur_unrealized_rows.assay_header_id,
                                                                    cur_unrealized_rows.item_qty,
                                                                    cur_unrealized_rows.qty_unit_id),
                            cur_unrealized_rows.item_qty_decimal);
      else
        vn_dry_qty := cur_unrealized_rows.item_qty;
      end if;
    
      vn_wet_qty := cur_unrealized_rows.item_qty;
    
      -- convert into dry qty to base qty element level
    
      vn_dry_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                                       cur_unrealized_rows.qty_unit_id,
                                                                       cur_unrealized_rows.base_qty_unit_id,
                                                                       1) *
                                  vn_dry_qty,
                                  cur_unrealized_rows.base_qty_decimal);
    
      -- contract treatment charges
      pkg_metals_general.sp_get_treatment_charge(cur_unrealized_rows.internal_contract_item_ref_no,
                                                 cur_unrealized_rows.element_id,
                                                 pc_dbd_id,
                                                 vn_dry_qty,
                                                 vn_wet_qty,
                                                 cur_unrealized_rows.qty_unit_id,
                                                 cur_unrealized_rows.contract_price,
                                                 cur_unrealized_rows.price_unit_id,
                                                 vn_con_treatment_charge,
                                                 vc_con_treatment_cur_id);
      -- converted treatment charges to base currency                                           
      vn_base_con_treatment_charge := round(pkg_general.f_get_converted_currency_amt(cur_unrealized_rows.corporate_id,
                                                                                     vc_con_treatment_cur_id,
                                                                                     cur_unrealized_rows.base_cur_id,
                                                                                     pd_trade_date,
                                                                                     vn_con_treatment_charge),
                                            cur_unrealized_rows.base_cur_decimal);
    
      --- contract refine chrges
      pkg_metals_general.sp_get_refine_charge(cur_unrealized_rows.internal_contract_item_ref_no,
                                              cur_unrealized_rows.element_id,
                                              pc_dbd_id,
                                              cur_unrealized_rows.payable_qty,
                                              cur_unrealized_rows.payable_qty_unit_id,
                                              cur_unrealized_rows.contract_price,
                                              cur_unrealized_rows.price_unit_id,
                                              vn_con_refine_charge,
                                              vc_con_refine_cur_id);
    
      --- converted refine charges to base currency                                              
    
      vn_base_con_refine_charge := round(pkg_general.f_get_converted_currency_amt(cur_unrealized_rows.corporate_id,
                                                                                  vc_con_refine_cur_id,
                                                                                  cur_unrealized_rows.base_cur_id,
                                                                                  pd_trade_date,
                                                                                  vn_con_refine_charge),
                                         cur_unrealized_rows.base_cur_decimal);
      --- contract penality chrges   
      if cur_unrealized_rows.ele_rank = 1 then
        pkg_metals_general.sp_get_penalty_charge(cur_unrealized_rows.internal_contract_item_ref_no,
                                                 pc_dbd_id,
                                                 vn_dry_qty,
                                                 cur_unrealized_rows.qty_unit_id,
                                                 vn_con_penality_charge,
                                                 vc_con_penality_cur_id);
      
        vn_base_con_penality_charge := round(pkg_general.f_get_converted_currency_amt(cur_unrealized_rows.corporate_id,
                                                                                      vc_con_penality_cur_id,
                                                                                      cur_unrealized_rows.base_cur_id,
                                                                                      pd_trade_date,
                                                                                      vn_con_penality_charge),
                                             cur_unrealized_rows.base_cur_decimal);
      end if;
    
      vn_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                                   cur_unrealized_rows.qty_unit_id,
                                                                   cur_unrealized_rows.conc_base_qty_unit_id,
                                                                   1) *
                              vn_wet_qty,
                              cur_unrealized_rows.conc_base_qty_decimal);
    
      vn_ele_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                                       cur_unrealized_rows.payable_qty_unit_id,
                                                                       cur_unrealized_rows.base_qty_unit_id,
                                                                       1) *
                                  cur_unrealized_rows.payable_qty,
                                  cur_unrealized_rows.base_qty_decimal);
      if cur_unrealized_rows.valuation_against_underlying = 'Y' then
        vn_ele_m2m_amt := nvl(cur_unrealized_rows.net_m2m_price, 0) /
                          nvl(cur_unrealized_rows.m2m_price_unit_weight, 1) *
                          pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                               cur_unrealized_rows.payable_qty_unit_id,
                                                               cur_unrealized_rows.m2m_price_unit_weight_unit_id,
                                                               cur_unrealized_rows.payable_qty);
      
        pkg_general.sp_get_main_cur_detail(nvl(cur_unrealized_rows.m2m_price_unit_cur_id,
                                               cur_unrealized_rows.base_cur_id),
                                           vc_m2m_cur_id,
                                           vc_m2m_cur_code,
                                           vn_m2m_sub_cur_id_factor,
                                           vn_m2m_cur_decimals);
        vn_ele_m2m_amt := round(vn_ele_m2m_amt * vn_m2m_sub_cur_id_factor,
                                vn_m2m_cur_decimals);
      
        pkg_general.sp_forward_cur_exchange_new(cur_unrealized_rows.corporate_id,
                                                pd_trade_date,
                                                cur_unrealized_rows.payment_due_date,
                                                vc_m2m_cur_id,
                                                cur_unrealized_rows.base_cur_id,
                                                30,
                                                vn_m2m_base_fx_rate,
                                                vn_m2m_base_deviation);
        if vc_m2m_cur_id <> cur_unrealized_rows.base_cur_id then
          if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
                                                                 'PHY-005',
                                                                 cur_unrealized_rows.base_cur_code ||
                                                                 ' to ' ||
                                                                 vc_m2m_cur_code,
                                                                 '',
                                                                 gvc_process,
                                                                 pc_user_id,
                                                                 sysdate,
                                                                 pd_trade_date);
            sp_insert_error_log(vobj_error_log);
          end if;
        end if;
        vn_ele_m2m_amount_in_base := vn_ele_m2m_amt * vn_m2m_base_fx_rate;
      else
        vn_ele_m2m_amt := nvl(cur_unrealized_rows.net_m2m_price, 0) /
                          nvl(cur_unrealized_rows.m2m_price_unit_weight, 1) *
                          pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                               cur_unrealized_rows.conc_base_qty_unit_id,
                                                               cur_unrealized_rows.m2m_price_unit_weight_unit_id,
                                                               vn_dry_qty_in_base);
      
        pkg_general.sp_get_main_cur_detail(nvl(cur_unrealized_rows.m2m_price_unit_cur_id,
                                               cur_unrealized_rows.base_cur_id),
                                           vc_m2m_cur_id,
                                           vc_m2m_cur_code,
                                           vn_m2m_sub_cur_id_factor,
                                           vn_m2m_cur_decimals);
        vn_ele_m2m_amt := round(vn_ele_m2m_amt * vn_m2m_sub_cur_id_factor,
                                vn_m2m_cur_decimals);
      
        pkg_general.sp_forward_cur_exchange_new(cur_unrealized_rows.corporate_id,
                                                pd_trade_date,
                                                cur_unrealized_rows.payment_due_date,
                                                vc_m2m_cur_id,
                                                cur_unrealized_rows.base_cur_id,
                                                30,
                                                vn_m2m_base_fx_rate,
                                                vn_m2m_base_deviation);
        if vc_m2m_cur_id <> cur_unrealized_rows.base_cur_id then
          if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
                                                                 'PHY-005',
                                                                 cur_unrealized_rows.base_cur_code ||
                                                                 ' to ' ||
                                                                 vc_m2m_cur_code,
                                                                 '',
                                                                 gvc_process,
                                                                 pc_user_id,
                                                                 sysdate,
                                                                 pd_trade_date);
            sp_insert_error_log(vobj_error_log);
          end if;
        end if;
        if cur_unrealized_rows.ele_rank = 1 then
          vn_ele_m2m_amount_in_base := vn_ele_m2m_amt * vn_m2m_base_fx_rate;
        else
          vn_ele_m2m_amount_in_base := 0;
          vn_ele_m2m_amt            := 0;
        end if;
      end if;
    
      /*vn_ele_m2m_treatment_charge := round(cur_unrealized_rows.m2m_treatment_charge *
                                           vn_dry_qty_in_base,
                                           cur_unrealized_rows.base_cur_decimal);
      vn_ele_m2m_refine_charge    := round(cur_unrealized_rows.m2m_refining_charge *
                                           vn_ele_qty_in_base,
                                           cur_unrealized_rows.base_cur_decimal);*/
    
      vn_ele_m2m_treatment_charge :=round((cur_unrealized_rows.m2m_treatment_charge /
                                     nvl(cur_unrealized_rows.m2m_tc_weight,
                                          1)) *
                                     pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                              cur_unrealized_rows.m2m_tc_cur_id,
                                                                              cur_unrealized_rows.base_cur_id,
                                                                              pd_trade_date,
                                                                              1) *
                                     (pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                                           cur_unrealized_rows.qty_unit_id,
                                                                           cur_unrealized_rows.m2m_tc_weight_unit_id,
                                                                           vn_dry_qty)),cur_unrealized_rows.base_cur_decimal);
    
      vn_ele_m2m_refine_charge :=round((cur_unrealized_rows.m2m_refining_charge /
                                  nvl(cur_unrealized_rows.m2m_rc_weight, 1)) *
                                  pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                           cur_unrealized_rows.m2m_rc_cur_id,
                                                                           cur_unrealized_rows.base_cur_id,
                                                                           pd_trade_date,
                                                                           1) *
                                  (pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,                                                                        
                                                                        cur_unrealized_rows.payable_qty_unit_id,
                                                                        cur_unrealized_rows.m2m_rc_weight_unit_id,
                                                                        cur_unrealized_rows.payable_qty)),cur_unrealized_rows.base_cur_decimal);
    
      vn_loc_amount := round(pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                                  cur_unrealized_rows.loc_qty_unit_id,
                                                                  cur_unrealized_rows.conc_base_qty_unit_id,
                                                                  1) *
                             cur_unrealized_rows.m2m_loc_incoterm_deviation,
                             cur_unrealized_rows.base_cur_decimal);
    
      vn_loc_total_amount := round(vn_loc_amount * vn_qty_in_base,
                                   cur_unrealized_rows.base_cur_decimal);
      vn_total_penality   := 0;
      if cur_unrealized_rows.ele_rank = 1 then
        vn_total_penality := 0;
        for cc in (select pci.internal_contract_item_ref_no,
                          pqca.element_id,
                          pcpq.quality_template_id
                     from pci_physical_contract_item  pci,
                          pcpq_pc_product_quality     pcpq,
                          ash_assay_header            ash,
                          asm_assay_sublot_mapping    asm,
                          pqca_pq_chemical_attributes pqca
                    where pci.pcpq_id = pcpq.pcpq_id
                      and pcpq.assay_header_id = ash.ash_id
                      and ash.ash_id = asm.ash_id
                      and asm.asm_id = pqca.asm_id
                      and pci.process_id = pc_process_id
                      and pcpq.process_id = pc_process_id
                      and pci.is_active = 'Y'
                      and pcpq.is_active = 'Y'
                      and ash.is_active = 'Y'
                      and asm.is_active = 'Y'
                      and pqca.is_active = 'Y'
                      and pqca.is_elem_for_pricing = 'N'
                      and pqca.is_deductible = 'N'
                      and pci.internal_contract_item_ref_no =
                          cur_unrealized_rows.internal_contract_item_ref_no)
        loop
        
          pkg_phy_pre_check_process.sp_calc_m2m_tc_pc_rc_charge(cur_unrealized_rows.corporate_id,
                                                                pd_trade_date,
                                                                cur_unrealized_rows.conc_product_id,
                                                                cur_unrealized_rows.conc_quality_id,
                                                                cur_unrealized_rows.mvp_id,
                                                                'Penalties',
                                                                cc.element_id,
                                                                cur_unrealized_rows.shipment_month,
                                                                cur_unrealized_rows.shipment_year,
                                                                vn_penality,
                                                                vc_penality_price_unit_id);
          if nvl(vn_penality, 0) <> 0 then
            vn_total_penality := round(vn_total_penality +
                                       (vn_penality * vn_dry_qty_in_base),
                                       cur_unrealized_rows.base_cur_decimal);
          end if;
        
        end loop;
      
      end if;
    
      /* vn_ele_m2m_premium_amt       := (cur_unrealized_rows.m2m_treatment_charge*vn_dry_qty_in_base) +
                                      (cur_unrealized_rows.m2m_refining_charge*vn_ele_qty_in_base);
                                      
      vn_ele_m2m_total_premium_amt := vn_ele_qty_in_base *
                                      nvl(vn_ele_m2m_premium_amt, 0);
                                      
      vn_ele_m2m_total_amount      := vn_ele_m2m_amount_in_base -
                                      vn_ele_m2m_total_premium_amt; */
    
      vn_ele_m2m_total_amount := vn_ele_m2m_amount_in_base -
                                 vn_ele_m2m_treatment_charge -
                                 vn_ele_m2m_refine_charge;
    
      pkg_general.sp_get_main_cur_detail(cur_unrealized_rows.price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
    
      vn_ele_cont_value_in_price_cur := (cur_unrealized_rows.contract_price /
                                        nvl(cur_unrealized_rows.price_unit_weight,
                                             1)) *
                                        (pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                                              cur_unrealized_rows.payable_qty_unit_id,
                                                                              cur_unrealized_rows.price_unit_weight_unit_id,
                                                                              cur_unrealized_rows.payable_qty)) *
                                        vn_cont_price_cur_id_factor;
    
      pkg_general.sp_forward_cur_exchange_new(cur_unrealized_rows.corporate_id,
                                              pd_trade_date,
                                              cur_unrealized_rows.payment_due_date,
                                              vc_price_cur_id,
                                              cur_unrealized_rows.base_cur_id,
                                              30,
                                              vn_fx_price_to_base,
                                              vn_forward_exch_rate);
    
      -- contract value in value currency will store the data in base currency
      vn_ele_cont_value_in_price_cur := round(vn_ele_cont_value_in_price_cur *
                                              nvl(vn_fx_price_to_base, 1),
                                              cur_unrealized_rows.base_cur_decimal);
    
      vn_ele_cont_premium := vn_base_con_treatment_charge +
                             vn_base_con_refine_charge;
    
      vn_ele_cont_total_premium := round((nvl(vn_ele_cont_premium, 0) *
                                         vn_ele_qty_in_base),
                                         cur_unrealized_rows.base_cur_decimal);
    
      vn_ele_cont_value_in_base_cur := vn_ele_cont_value_in_price_cur -
                                       vn_ele_cont_total_premium;
      -- secondray cost                                 
      if cur_unrealized_rows.ele_rank = 1 then
        vn_sc_in_base_cur := round(cur_unrealized_rows.sc_in_base_cur *
                                   vn_qty_in_base,
                                   cur_unrealized_rows.base_cur_decimal);
      end if;
    
      -- vn_ele_exp_cog_in_base_cur := round((abs(vn_ele_cont_value_in_base_cur)),2);
    
      /*  if cur_unrealized_rows.purchase_sales = 'P' then
        vn_ele_unreal_pnl_in_base_cur := round((vn_ele_m2m_total_amount -
                                               vn_ele_exp_cog_in_base_cur),
                                               2);
      else
        vn_ele_unreal_pnl_in_base_cur := round((vn_ele_exp_cog_in_base_cur -
                                               vn_ele_m2m_total_amount),
                                               2);
      end if;*/
    
      -- below variable set as zero as it's not used in any calculation.
      vn_unrealized_pnl_in_m2m_unit := 0;
      vc_m2m_price_unit_id          := cur_unrealized_rows.m2m_price_unit_id;
      vc_m2m_price_unit_cur_id      := cur_unrealized_rows.m2m_price_unit_cur_id;
      vc_m2m_price_unit_cur_code    := cur_unrealized_rows.m2m_price_unit_cur_code;
      vc_m2m_price_unit_wgt_unit_id := cur_unrealized_rows.m2m_price_unit_weight_unit_id;
      vc_m2m_price_unit_wgt_unit    := cur_unrealized_rows.m2m_price_unit_weight_unit;
      vn_m2m_price_unit_wgt_unit_wt := cur_unrealized_rows.m2m_price_unit_weight;
    
      insert into poued_element_details
        (corporate_id,
         corporate_name,
         process_id,
         md_id,
         internal_contract_item_ref_no,
         element_id,
         element_name,
         assay_header_id,
         assay_qty,
         assay_qty_unit_id,
         payable_qty,
         payable_qty_unit_id,
         refining_charge,
         treatment_charge,
         -- penalty_charge,
         pricing_details,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight,
         price_unit_weight_unit,
         m2m_price,
         m2m_price_unit_id,
         m2m_price_cur_id,
         m2m_price_cur_code,
         m2m_price_weight,
         m2m_price_weght_unit_id,
         m2m_price_weight_unit,
         contract_value,
         contract_value_cur_id,
         contract_value_cur_code,
         contract_value_in_base,
         contract_premium_value_in_base,
         m2m_value,
         m2m_value_cur_id,
         m2m_value_cur_code,
         m2m_refining_charge,
         m2m_treatment_charge,
         -- m2m_penalty_charge,
         m2m_loc_diff,
         m2m_amt_in_base,
         -- sc_in_base_cur,
         valuation_dr_id,
         valuation_dr_id_name,
         valuation_month,
         valuation_date,
         expected_cog_net_sale_value,
         unrealized_pnl_in_base_cur,
         base_cur_id,
         base_cur_code,
         price_cur_to_base_cur_fx_rate,
         m2m_cur_to_base_cur_fx_rate,
         derivative_def_id,
         valuation_exchange_id,
         valuation_exchange,
         element_qty_in_base_unit,
         base_price_unit_id_ppu,
         base_price_unit_name,
         valuation_against_underlying)
      values
        (cur_unrealized_rows.corporate_id,
         cur_unrealized_rows.corporate_name,
         pc_process_id,
         cur_unrealized_rows.md_id,
         cur_unrealized_rows.internal_contract_item_ref_no,
         cur_unrealized_rows.element_id,
         cur_unrealized_rows.attribute_name,
         cur_unrealized_rows.assay_header_id,
         cur_unrealized_rows.assay_qty,
         cur_unrealized_rows.assay_qty_unit_id,
         cur_unrealized_rows.payable_qty,
         cur_unrealized_rows.payable_qty_unit_id,
         vn_base_con_refine_charge,
         vn_base_con_treatment_charge,
         -- vn_con_penality_per_elemet,
         cur_unrealized_rows.attribute_name ||
         cur_unrealized_rows.price_description, --pricing_details,
         cur_unrealized_rows.contract_price,
         cur_unrealized_rows.price_unit_id,
         cur_unrealized_rows.price_unit_cur_id,
         cur_unrealized_rows.price_unit_cur_code,
         cur_unrealized_rows.price_unit_weight_unit_id,
         cur_unrealized_rows.price_unit_weight,
         cur_unrealized_rows.price_unit_weight_unit,
         cur_unrealized_rows.net_m2m_price,
         cur_unrealized_rows.m2m_price_unit_id,
         cur_unrealized_rows.m2m_price_unit_cur_id,
         cur_unrealized_rows.m2m_price_unit_cur_code,
         decode(cur_unrealized_rows.m2m_price_unit_weight,
                1,
                null,
                cur_unrealized_rows.m2m_price_unit_weight),
         cur_unrealized_rows.m2m_price_unit_weight_unit_id,
         cur_unrealized_rows.m2m_price_unit_weight_unit,
         vn_ele_cont_value_in_price_cur, --contract_value,
         vc_price_cur_id, --contract_value_cur_id,
         vc_price_cur_code, --contract_value_cur_code,
         vn_ele_cont_value_in_price_cur, --contract_value_in_base, 
         vn_ele_cont_total_premium, --contract_premium_value_in_base , 
         vn_ele_m2m_amount_in_base, --m2m_value,
         vc_m2m_cur_id, --m2m_value_cur_id,
         vc_m2m_cur_code, --m2m_value_cur_code,
         vn_ele_m2m_refine_charge,
         vn_ele_m2m_treatment_charge,
         -- cur_unrealized_rows.m2m_penalty_charge,
         cur_unrealized_rows.m2m_loc_incoterm_deviation,
         vn_ele_m2m_amount_in_base, -- updated by siva on 14sep2011 vn_ele_m2m_total_amount, --m2m_amt_in_base, ---used to sum at main table
         -- round(vn_ele_sc_in_base_cur, 3), --sc_in_base_cur,
         cur_unrealized_rows.valuation_dr_id,
         cur_unrealized_rows.dr_id_name,
         cur_unrealized_rows.valuation_month,
         cur_unrealized_rows.valuation_date,
         vn_ele_exp_cog_in_base_cur, --expected_cog_net_sale_value,
         vn_ele_unreal_pnl_in_base_cur, --unrealized_pnl_in_base_cur,
         cur_unrealized_rows.base_cur_id,
         cur_unrealized_rows.base_cur_code,
         vn_fx_price_to_base, --price_cur_to_base_cur_fx_rate,
         vn_m2m_base_fx_rate, --m2m_cur_to_base_cur_fx_rate,
         cur_unrealized_rows.derivative_def_id,
         cur_unrealized_rows.valuation_exchange_id,
         cur_unrealized_rows.exchange_name,
         vn_ele_qty_in_base,
         cur_unrealized_rows.base_price_unit_id_in_ppu,
         cur_unrealized_rows.base_price_unit_name,
         cur_unrealized_rows.valuation_against_underlying);
    
      if cur_unrealized_rows.ele_rank = 1 then
        insert into poue_phy_open_unreal_element
          (corporate_id,
           corporate_name,
           process_id,
           pcdi_id,
           delivery_item_no,
           prefix,
           middle_no,
           suffix,
           internal_contract_ref_no,
           contract_ref_no,
           contract_issue_date,
           internal_contract_item_ref_no,
           basis_type,
           delivery_period_type,
           delivery_from_month,
           delivery_from_year,
           delivery_to_month,
           delivery_to_year,
           delivery_from_date,
           delivery_to_date,
           transit_days,
           contract_type,
           approval_status,
           unrealized_type,
           profit_center_id,
           profit_center_name,
           profit_center_short_name,
           cp_profile_id,
           cp_name,
           trade_user_id,
           trade_user_name,
           product_id,
           product_name,
           item_dry_qty,
           item_wet_qty,
           qty_unit_id,
           qty_unit,
           quality_id,
           quality_name,
           fixation_method,
           price_string,
           price_fixation_status,
           price_fixation_details,
           item_delivery_period_string,
           incoterm_id,
           incoterm,
           origination_city_id,
           origination_city,
           origination_country_id,
           origination_country,
           destination_city_id,
           destination_city,
           destination_country_id,
           destination_country,
           origination_region_id,
           origination_region,
           destination_region_id,
           destination_region,
           payment_term_id,
           payment_term,
           contract_price_string,
           contract_rc_tc_pen_string,
           m2m_price_string,
           m2m_rc_tc_pen_string,
           net_contract_value_in_base_cur,
           net_contract_prem_in_base_cur,
           net_m2m_amt_in_base_cur,
           net_sc_in_base_cur,
           expected_cog_net_sale_value,
           unrealized_pnl_in_base_cur,
           unreal_pnl_in_base_per_unit,
           prev_day_unr_pnl_in_base_cur,
           trade_day_pnl_in_base_cur,
           base_cur_id,
           base_cur_code,
           group_id,
           group_name,
           group_cur_id,
           group_cur_code,
           group_qty_unit_id,
           group_qty_unit,
           base_qty_unit_id,
           base_qty_unit,
           cont_unr_status,
           qty_in_base_unit,
           process_trade_date,
           strategy_id,
           strategy_name,
           del_distribution_item_no,
           penalty_charge,
           m2m_penalty_charge,
           m2m_loc_diff_premium,
           valuation_against_underlying)
        values
          (cur_unrealized_rows.corporate_id,
           cur_unrealized_rows.corporate_name,
           pc_process_id,
           cur_unrealized_rows.pcdi_id,
           cur_unrealized_rows.delivery_item_no,
           cur_unrealized_rows.prefix,
           cur_unrealized_rows.middle_no,
           cur_unrealized_rows.suffix,
           cur_unrealized_rows.internal_contract_ref_no,
           cur_unrealized_rows.contract_ref_no,
           cur_unrealized_rows.issue_date,
           cur_unrealized_rows.internal_contract_item_ref_no,
           cur_unrealized_rows.basis_type,
           cur_unrealized_rows.delivery_period_type,
           cur_unrealized_rows.delivery_from_month,
           cur_unrealized_rows.delivery_from_year,
           cur_unrealized_rows.delivery_to_month,
           cur_unrealized_rows.delivery_to_year,
           cur_unrealized_rows.delivery_from_date,
           cur_unrealized_rows.delivery_to_date,
           cur_unrealized_rows.transit_days,
           cur_unrealized_rows.purchase_sales,
           cur_unrealized_rows.contract_status,
           cur_unrealized_rows.unrealized_type,
           cur_unrealized_rows.profit_center_id,
           cur_unrealized_rows.profit_center_name,
           cur_unrealized_rows.profit_center_short_name,
           cur_unrealized_rows.cp_id,
           cur_unrealized_rows.cp_name,
           cur_unrealized_rows.trader_id,
           cur_unrealized_rows.trader_user_name,
           cur_unrealized_rows.product_id,
           cur_unrealized_rows.product_name,
           vn_dry_qty,
           vn_wet_qty,
           cur_unrealized_rows.qty_unit_id,
           cur_unrealized_rows.qty_unit,
           cur_unrealized_rows.conc_quality_id,
           cur_unrealized_rows.quality_name,
           cur_unrealized_rows.fixation_method,
           cur_unrealized_rows.price_description,
           cur_unrealized_rows.price_fixation_status,
           cur_unrealized_rows.price_fixation_details,
           cur_unrealized_rows.item_delivery_period_string,
           cur_unrealized_rows.inco_term_id,
           cur_unrealized_rows.incoterm,
           cur_unrealized_rows.origination_city_id,
           cur_unrealized_rows.origination_city,
           cur_unrealized_rows.origination_country_id,
           cur_unrealized_rows.origination_country,
           cur_unrealized_rows.destination_city_id,
           cur_unrealized_rows.destination_city,
           cur_unrealized_rows.destination_country_id,
           cur_unrealized_rows.destination_country,
           cur_unrealized_rows.origination_region_id,
           cur_unrealized_rows.origination_region,
           cur_unrealized_rows.destination_region_id,
           cur_unrealized_rows.destination_region,
           cur_unrealized_rows.payment_term_id,
           cur_unrealized_rows.payment_term,
           null, -- contract_price_string,
           null, --contract_rc_tc_pen_string,
           null, -- m2m_price_string,
           null, -- m2m_rc_tc_pen_string,
           null, -- net_contract_value_in_base_cur,
           null, -- net_contract_prem_in_base_cur,
           null, -- net_m2m_amt_in_base_cur, 
           vn_sc_in_base_cur, -- net_sc_in_base_cur,
           null, -- expected_cog_net_sale_value,
           null, -- unrealized_pnl_in_base_cur,
           null, -- unreal_pnl_in_base_per_unit,
           null, -- prev_day_unr_pnl_in_base_cur,
           null, -- trade_day_pnl_in_base_cur,
           cur_unrealized_rows.base_cur_id,
           cur_unrealized_rows.base_cur_code,
           cur_unrealized_rows.groupid,
           cur_unrealized_rows.groupname,
           cur_unrealized_rows.cur_id_gcd,
           cur_unrealized_rows.cur_code_gcd,
           cur_unrealized_rows.qty_unit_id_gcd,
           cur_unrealized_rows.qty_unit_gcd,
           cur_unrealized_rows.base_qty_unit_id,
           cur_unrealized_rows.base_qty_unit,
           null, -- cont_unr_status,
           vn_qty_in_base,
           pd_trade_date,
           cur_unrealized_rows.strategy_id,
           cur_unrealized_rows.strategy_name,
           cur_unrealized_rows.del_distribution_item_no,
           vn_base_con_penality_charge,
           vn_total_penality,
           vn_loc_total_amount,
           cur_unrealized_rows.valuation_against_underlying);
      end if;
    
    end loop;
  
    for cur_update_pnl in (select poude.internal_contract_item_ref_no,
                                  sum(poude.contract_value_in_base) net_contract_value_in_base_cur,
                                  sum(poude.contract_premium_value_in_base) net_contract_prem_in_base_cur,
                                  sum(poude.m2m_amt_in_base) net_m2m_amt_in_base_cur,
                                  sum(poude.treatment_charge) net_contract_treatment_charge,
                                  sum(poude.refining_charge) net_contract_refining_charge,
                                  sum(poude.m2m_treatment_charge) net_m2m_treatment_charge,
                                  sum(poude.m2m_refining_charge) net_m2m_refining_charge,
                                  -- sum(poude.expected_cog_net_sale_value) expected_cog_net_sale_value,
                                  --sum(poude.unrealized_pnl_in_base_cur) unrealized_pnl_in_base_cur,
                                  stragg(poude.element_name || '-' ||
                                         poude.contract_price || ' ' ||
                                         poude.price_unit_cur_code || '/' ||
                                         poude.price_unit_weight ||
                                         poude.price_unit_weight_unit) contract_price_string,
                                  (case
                                     when poude.valuation_against_underlying = 'N' then
                                      max((case
                                     when nvl(poude.m2m_price, 0) <> 0 then
                                      (poude.m2m_price || ' ' ||
                                      poude.m2m_price_cur_code || '/' ||
                                      poude.m2m_price_weight ||
                                      poude.m2m_price_weight_unit)
                                     else
                                      null
                                   end)) else stragg((case
                                    when nvl(poude.m2m_price,
                                             0) <> 0 then
                                     (poude.element_name || '-' ||
                                     poude.m2m_price || ' ' ||
                                     poude.m2m_price_cur_code || '/' ||
                                     poude.m2m_price_weight ||
                                     poude.m2m_price_weight_unit)
                                    else
                                     null
                                  end)) end) m2m_price_string, -- TODO if underly valuation = n, show the concentrate price
                                  stragg('TC:' || poude.element_name || '-' ||
                                         poude.treatment_charge || ' ' ||
                                         poude.base_cur_code || '  ' ||
                                         'RC:' || poude.element_name || '-' ||
                                         poude.refining_charge || ' ' ||
                                         poude.base_cur_code) contract_rc_tc_pen_string,
                                  stragg('TC:' || poude.element_name || '-' ||
                                         poude.m2m_treatment_charge || ' ' ||
                                         poude.base_cur_code || ' ' || 'RC:' ||
                                         poude.element_name || '-' ||
                                         poude.m2m_refining_charge || ' ' ||
                                         poude.base_cur_code) m2m_rc_tc_pen_string
                             from poued_element_details poude
                            where poude.corporate_id = pc_corporate_id
                              and poude.process_id = pc_process_id
                            group by poude.internal_contract_item_ref_no,
                                     poude.valuation_against_underlying)
    loop
      update poue_phy_open_unreal_element poue
         set poue.net_contract_value_in_base_cur = round(cur_update_pnl.net_contract_value_in_base_cur,
                                                         2),
             poue.net_contract_prem_in_base_cur  = round(cur_update_pnl.net_contract_prem_in_base_cur,
                                                         2),
             poue.net_m2m_amt_in_base_cur        = round(cur_update_pnl.net_m2m_amt_in_base_cur,
                                                         2),
             poue.net_contract_treatment_charge  = cur_update_pnl.net_contract_treatment_charge,
             poue.net_contract_refining_charge   = cur_update_pnl.net_contract_refining_charge,
             poue.net_m2m_treatment_charge       = cur_update_pnl.net_m2m_treatment_charge,
             poue.net_m2m_refining_charge        = cur_update_pnl.net_m2m_refining_charge,
             -- poue.expected_cog_net_sale_value    = round(cur_update_pnl.expected_cog_net_sale_value, 3),
             /*poue.unrealized_pnl_in_base_cur     = round(cur_update_pnl.unrealized_pnl_in_base_cur,
                                                                                                                                                                                                                                                                                                   3),*/
             poue.contract_price_string     = cur_update_pnl.contract_price_string,
             poue.m2m_price_string          = cur_update_pnl.m2m_price_string,
             poue.contract_rc_tc_pen_string = cur_update_pnl.contract_rc_tc_pen_string,
             poue.m2m_rc_tc_pen_string      = cur_update_pnl.m2m_rc_tc_pen_string
       where poue.internal_contract_item_ref_no =
             cur_update_pnl.internal_contract_item_ref_no
         and poue.process_id = pc_process_id
         and poue.corporate_id = pc_corporate_id;
    end loop;
    commit;
  
    update poue_phy_open_unreal_element poue
       set poue.expected_cog_net_sale_value = poue.net_contract_value_in_base_cur -
                                              poue.net_contract_treatment_charge -
                                              poue.net_contract_refining_charge +
                                              poue.net_sc_in_base_cur
     where poue.corporate_id = pc_corporate_id
       and poue.process_id = pc_process_id;
    commit;
    --- update unrealized pnl
    update poue_phy_open_unreal_element poue
       set poue.unrealized_pnl_in_base_cur = (poue.expected_cog_net_sale_value -
                                             nvl(poue.penalty_charge, 0)) -
                                             (poue.net_m2m_amt_in_base_cur -
                                             poue.net_m2m_treatment_charge -
                                             poue.net_contract_refining_charge -
                                             nvl(poue.m2m_penalty_charge, 0) +
                                             poue.m2m_loc_diff_premium)
     where poue.corporate_id = pc_corporate_id
       and poue.process_id = pc_process_id;
    commit;
    -- update pnl base per unit
    update poue_phy_open_unreal_element poue
       set poue.unreal_pnl_in_base_per_unit = round(poue.unrealized_pnl_in_base_cur /
                                                    poue.qty_in_base_unit,
                                                    2)
     where poue.corporate_id = pc_corporate_id
       and poue.process_id = pc_process_id
       and poue.qty_in_base_unit <> 0;
  
    -- update previous eod data  
    begin
      for cur_update in (select poue_prev_day.internal_contract_item_ref_no,
                                poue_prev_day.unreal_pnl_in_base_per_unit,
                                poue_prev_day.unrealized_type
                           from poue_phy_open_unreal_element poue_prev_day
                          where poue_prev_day.process_id =
                                gvc_previous_process_id
                            and corporate_id = pc_corporate_id)
      loop
        update poue_phy_open_unreal_element poue_today
           set poue_today.prev_day_unr_pnl_in_base_cur = round(cur_update.unreal_pnl_in_base_per_unit *
                                                               poue_today.qty_in_base_unit,
                                                               2),
               poue_today.cont_unr_status              = 'EXISTING_TRADE'
         where poue_today.internal_contract_item_ref_no =
               cur_update.internal_contract_item_ref_no
           and poue_today.process_id = pc_process_id
           and poue_today.unrealized_type = cur_update.unrealized_type
           and poue_today.corporate_id = pc_corporate_id;
      end loop;
    exception
      when others then
        dbms_output.put_line('SQLERRM-1' || sqlerrm);
    end;
  
    -- mark the trades came as new in this eod/eom
  
    begin
      update poue_phy_open_unreal_element poue
         set poue.cont_unr_status = 'NEW_TRADE'
       where poue.cont_unr_status is null
         and poue.process_id = pc_process_id
         and poue.corporate_id = pc_corporate_id;
    exception
      when others then
        dbms_output.put_line('SQLERRM-2' || sqlerrm);
    end;
  
    update poue_phy_open_unreal_element poue
       set poue.trade_day_pnl_in_base_cur = round(nvl(poue.unrealized_pnl_in_base_cur,
                                                      0) - nvl(poue.prev_day_unr_pnl_in_base_cur,
                                                               0),
                                                  2)
     where poue.process_id = pc_process_id
       and poue.corporate_id = pc_corporate_id
       and poue.unrealized_type = 'Unrealized';
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_phy_opencon_unreal_pnl',
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

  procedure sp_calc_phy_stock_unreal_pnl(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2) as
  
    cursor cur_grd is
      select 'Purchase' section_type,
             pcpd.profit_center_id profit_center,
             pc_process_id process_id,
             gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             grd.internal_contract_item_ref_no,
             pcm.purchase_sales,
             grd.product_id,
             pdm.product_desc product_name,
             grd.origin_id,
             orm.origin_name,
             qat.quality_id,
             qat.quality_name,
             grd.container_no,
             grd.current_qty stock_qty,
             grd.qty_unit_id,
             gmr.qty_unit_id gmr_qty_unit_id,
             qum.qty_unit,
             grd.no_of_units,
             md.md_id,
             md.m2m_price_unit_id,
             md.net_m2m_price,
             md.m2m_price_unit_cur_id,
             md.m2m_price_unit_cur_code,
             md.m2m_price_unit_weight_unit_id,
             md.m2m_price_unit_weight_unit,
             nvl(md.m2m_price_unit_weight, 1) m2m_price_unit_weight,
             md.m2m_price_unit_cur_code || '/' ||
             decode(md.m2m_price_unit_weight,
                    1,
                    null,
                    md.m2m_price_unit_weight) ||
             md.m2m_price_unit_weight_unit m2m_price_unit_str,
             md.m2m_main_cur_id,
             md.m2m_main_cur_code,
             md.m2m_main_cur_decimals,
             md.main_currency_factor,
             md.settlement_cur_id,
             md.settlement_to_val_fx_rate,
             cipd.contract_price,
             cipd.price_unit_id,
             cipd.price_unit_weight_unit_id,
             cipd.price_unit_weight,
             cipd.price_unit_cur_id,
             cipd.price_unit_cur_code,
             cipd.price_unit_weight_unit,
             cipd.price_fixation_details,
             nvl(cipd.payment_due_date, pd_trade_date) payment_due_date,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
             grd.inventory_status,
             gsm.status shipment_status,
             (case
               when nvl(grd.is_afloat, 'N') = 'Y' and
                    nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                'Shipped NTT'
               when nvl(grd.is_afloat, 'N') = 'Y' and
                    nvl(grd.inventory_status, 'NA') = 'In' then
                'Shipped IN'
               when nvl(grd.is_afloat, 'N') = 'Y' and
                    nvl(grd.inventory_status, 'NA') = 'Out' then
                'Shipped TT'
               when nvl(grd.is_afloat, 'N') = 'N' and
                    nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                'Stock NTT'
               when nvl(grd.is_afloat, 'N') = 'N' and
                    nvl(grd.inventory_status, 'NA') = 'In' then
                'Stock IN'
               when nvl(grd.is_afloat, 'N') = 'N' and
                    nvl(grd.inventory_status, 'NA') = 'Out' then
                'Stock TT'
               else
                'Others'
             end) section_name,
             cipd.price_basis,
             gmr.shed_id,
             gmr.destination_city_id,
             cipd.price_fixation_status price_fixation_status,
             pdm.base_quantity_unit base_qty_unit_id,
             pcpd.strategy_id,
             css.strategy_name,
             (ciqs.total_qty - nvl(ciqs.price_fixed_qty, 0)) unfxd_qty,
             ciqs.price_fixed_qty fxd_qty,
             md.valuation_exchange_id,
             md.valuation_month,
             md.derivative_def_id,
             nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
             gmr.contract_type gmr_contract_type,
             null int_alloc_group_id,
             grd.internal_grd_ref_no internal_grd_dgrd_ref_no,
             grd.internal_stock_ref_no stock_ref_no,
             pcm.trader_id,
             (case
               when pcm.trader_id is not null then
                (select gab.firstname || ' ' || gab.lastname
                   from gab_globaladdressbook gab,
                        ak_corporate_user     aku
                  where gab.gabid = aku.gabid
                    and aku.user_id = pcm.trader_id)
               else
                ''
             end) trader_user_name,
             md.m2m_loc_incoterm_deviation,
             md.m2m_quality_premium,
             md.m2m_product_premium,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             nvl(md.m2m_loc_incoterm_deviation, 0) +
             nvl(md.m2m_quality_premium, 0) +
             nvl(md.m2m_product_premium, 0) total_premium,
             qat.eval_basis,
             nvl(pcdb.premium, 0) delivery_premium,
             pcdb.premium_unit_id delivery_premium_unit_id,
             gpd.contract_price gmr_price,
             gpd.price_unit_id gmr_price_unit_id,
             gpd.price_unit_weight_unit_id gmr_price_wt_unit_id,
             gpd.price_unit_weight gmr_price_wt,
             gpd.price_unit_cur_id gmr_price_cur_id,
             gpd.price_unit_cur_code gmr_price_cur_code,
             gpd.price_unit_weight_unit gmr_price_wt_unit,
             gpd.price_fixation_status gmr_price_fixation_status
        from gmr_goods_movement_record gmr,
             grd_goods_record_detail grd,
             gpd_gmr_price_daily gpd,
             pcm_physical_contract_main pcm,
             pcpd_pc_product_definition pcpd,
             pdm_productmaster pdm,
             orm_origin_master orm,
             qat_quality_attributes qat,
             qum_quantity_unit_master qum,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type <> 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'BASEMETAL'
                 and md1.process_id = pc_process_id) md,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'BASEMETAL'
                 and tmp.section_name <> 'OPEN') tmpc,
             cipd_contract_item_price_daily cipd,
             ak_corporate akc,
             cm_currency_master cm,
             gsm_gmr_stauts_master gsm,
             pci_physical_contract_item pci,
             pcdb_pc_delivery_basis pcdb,
             ciqs_contract_item_qty_status ciqs,
             css_corporate_strategy_setup css
       where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and grd.product_id = pdm.product_id
         and grd.origin_id = orm.origin_id(+)
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.process_id = gpd.process_id(+)
         and grd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
         and grd.internal_grd_ref_no = tmpc.internal_grd_ref_no(+)
         and grd.internal_contract_item_ref_no =
             tmpc.internal_contract_item_ref_no(+)
         and tmpc.quality_id = qat.quality_id(+)
         and grd.qty_unit_id = qum.qty_unit_id(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and grd.internal_contract_item_ref_no =
             cipd.internal_contract_item_ref_no
         and grd.process_id = cipd.process_id
         and cipd.internal_contract_ref_no = pcm.internal_contract_ref_no
         and grd.internal_contract_item_ref_no =
             ciqs.internal_contract_item_ref_no
         and grd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and pci.pcdb_id = pcdb.pcdb_id
         and pci.process_id = pcdb.process_id
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and gmr.status_id = gsm.status_id(+)
         and pcpd.strategy_id = css.strategy_id
         and grd.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and cipd.process_id = pc_process_id
         and ciqs.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'BASEMETAL'
         and pcm.is_active = 'Y'
         and pci.is_active = 'Y'
         and gmr.corporate_id = pc_corporate_id
         and grd.status = 'Active'
         and grd.is_deleted = 'N'
         and gmr.is_deleted = 'N'
         and nvl(grd.inventory_status, 'NA') <> 'Out'
         and pcm.purchase_sales = 'P'
         and nvl(grd.current_qty, 0) > 0
         and gmr.is_internal_movement = 'N'
      union all
      select 'Sales' section_type,
             pcpd.profit_center_id profit_center,
             pc_process_id process_id,
             gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             dgrd.internal_contract_item_ref_no,
             pcm.purchase_sales,
             dgrd.product_id,
             pdm.product_desc product_name,
             dgrd.origin_id,
             orm.origin_name,
             tmpc.quality_id,
             qat.quality_name,
             '' container_no,
             dgrd.net_weight stock_qty,
             dgrd.net_weight_unit_id qty_unit_id,
             gmr.qty_unit_id gmr_qty_unit_id,
             qum.qty_unit,
             gmr.current_no_of_units no_of_units,
             md.md_id,
             md.m2m_price_unit_id,
             md.net_m2m_price,
             md.m2m_price_unit_cur_id,
             md.m2m_price_unit_cur_code,
             md.m2m_price_unit_weight_unit_id,
             md.m2m_price_unit_weight_unit,
             nvl(md.m2m_price_unit_weight, 1) m2m_price_unit_weight,
             md.m2m_price_unit_cur_code || '/' ||
             decode(md.m2m_price_unit_weight,
                    1,
                    null,
                    md.m2m_price_unit_weight) ||
             md.m2m_price_unit_weight_unit m2m_price_unit_str,
             md.m2m_main_cur_id,
             md.m2m_main_cur_code,
             md.m2m_main_cur_decimals,
             md.main_currency_factor,
             md.settlement_cur_id,
             md.settlement_to_val_fx_rate,
             cipd.contract_price,
             cipd.price_unit_id,
             cipd.price_unit_weight_unit_id,
             cipd.price_unit_weight,
             cipd.price_unit_cur_id,
             cipd.price_unit_cur_code,
             cipd.price_unit_weight_unit,
             cipd.price_fixation_details,
             nvl(cipd.payment_due_date, pd_trade_date) payment_due_date,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
             gmr.inventory_status,
             gsm.status shipment_status,
             (case
               when nvl(dgrd.inventory_status, 'NA') = 'Under CMA' then
                'UnderCMA NTT'
               when nvl(dgrd.is_afloat, 'N') = 'Y' and
                    nvl(dgrd.inventory_status, 'NA') in ('In', 'None', 'NA') then
                'Shipped NTT'
               when nvl(dgrd.is_afloat, 'N') = 'Y' and
                    nvl(dgrd.inventory_status, 'NA') = 'Out' then
                'Shipped TT'
               when nvl(dgrd.is_afloat, 'N') = 'N' and
                    nvl(dgrd.inventory_status, 'NA') in ('In', 'None', 'NA') then
                'Stock NTT'
               when nvl(dgrd.is_afloat, 'N') = 'N' and
                    nvl(dgrd.inventory_status, 'NA') = 'Out' then
                'Stock TT'
               else
                'Others'
             end) section_name,
             cipd.price_basis,
             gmr.shed_id,
             gmr.destination_city_id,
             cipd.price_fixation_status price_fixation_status,
             pdm.base_quantity_unit base_qty_unit_id,
             pcpd.strategy_id,
             css.strategy_name,
             (ciqs.total_qty - nvl(ciqs.price_fixed_qty, 0)) unfxd_qty,
             ciqs.price_fixed_qty fxd_qty,
             md.valuation_exchange_id,
             md.valuation_month,
             md.derivative_def_id,
             nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
             gmr.contract_type gmr_contract_type,
             agh.int_alloc_group_id,
             dgrd.internal_dgrd_ref_no internal_grd_dgrd_ref_no,
             dgrd.internal_stock_ref_no stock_ref_no,
             pcm.trader_id,
             (case
               when pcm.trader_id is not null then
                (select gab.firstname || ' ' || gab.lastname
                   from gab_globaladdressbook gab,
                        ak_corporate_user     aku
                  where gab.gabid = aku.gabid
                    and aku.user_id = pcm.trader_id)
               else
                ''
             end) trader_user_name,
             md.m2m_loc_incoterm_deviation,
             md.m2m_quality_premium,
             md.m2m_product_premium,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             nvl(md.m2m_loc_incoterm_deviation, 0) +
             nvl(md.m2m_quality_premium, 0) +
             nvl(md.m2m_product_premium, 0) total_premium,
             qat.eval_basis,
             nvl(pcdb.premium, 0) delivery_premium,
             pcdb.premium_unit_id delivery_premium_unit_id,
             gpd.contract_price gmr_price,
             gpd.price_unit_id gmr_price_unit_id,
             gpd.price_unit_weight_unit_id gmr_price_wt_unit_id,
             gpd.price_unit_weight gmr_price_wt,
             gpd.price_unit_cur_id gmr_price_cur_id,
             gpd.price_unit_cur_code gmr_price_cur_code,
             gpd.price_unit_weight_unit gmr_price_wt_unit,
             gpd.price_fixation_status gmr_price_fixation_status
        from gmr_goods_movement_record gmr,
             gpd_gmr_price_daily gpd,
             dgrd_delivered_grd dgrd,
             agh_alloc_group_header agh,
             pcm_physical_contract_main pcm,
             pcpd_pc_product_definition pcpd,
             pdm_productmaster pdm,
             orm_origin_master orm,
             qat_quality_attributes qat,
             qum_quantity_unit_master qum,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type <> 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'BASEMETAL'
                 and md1.process_id = pc_process_id) md,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'BASEMETAL'
                 and tmp.section_name <> 'OPEN') tmpc,
             cipd_contract_item_price_daily cipd,
             ak_corporate akc,
             gsm_gmr_stauts_master gsm,
             ciqs_contract_item_qty_status ciqs,
             pci_physical_contract_item pci,
             pcdb_pc_delivery_basis pcdb,
             cm_currency_master cm,
             css_corporate_strategy_setup css
       where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.process_id = gpd.process_id(+)
         and dgrd.product_id = pdm.product_id
         and dgrd.origin_id = orm.origin_id(+)
         and dgrd.int_alloc_group_id = agh.int_alloc_group_id
         and dgrd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
         and dgrd.internal_dgrd_ref_no = tmpc.internal_grd_ref_no(+)
         and dgrd.internal_contract_item_ref_no =
             tmpc.internal_contract_item_ref_no(+)
         and tmpc.quality_id = qat.quality_id(+)
         and dgrd.net_weight_unit_id = qum.qty_unit_id(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and dgrd.internal_contract_item_ref_no =
             cipd.internal_contract_item_ref_no
         and dgrd.process_id = cipd.process_id
         and cipd.internal_contract_ref_no = pcm.internal_contract_ref_no
         and cipd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and pci.internal_contract_item_ref_no =
             ciqs.internal_contract_item_ref_no
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and cm.cur_code = akc.base_currency_name
         and gmr.status_id = gsm.status_id(+)
         and pcpd.strategy_id = css.strategy_id
         and pci.pcdb_id = pcdb.pcdb_id
         and pci.process_id = pcdb.process_id
         and pcm.purchase_sales = 'S'
         and gsm.is_required_for_m2m = 'Y'
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'BASEMETAL'
         and pcm.is_active = 'Y'
         and pci.is_active = 'Y'
         and gmr.is_deleted = 'N'
         and pcm.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and ciqs.process_id = pc_process_id
         and upper(dgrd.realized_status) in
             ('UNREALIZED', 'UNDERCMA', 'REVERSEREALIZED', 'REVERSEUNDERCMA')
         and dgrd.status = 'Active'
         and nvl(dgrd.net_weight, 0) > 0
         and dgrd.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and cipd.process_id = pc_process_id
         and agh.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and agh.is_deleted = 'N'
         and gmr.corporate_id = pc_corporate_id
         and gmr.is_internal_movement = 'N'
      union all
      select 'Internal Movement' section_type,
             null profit_center, -- pcpd.profit_center_id profit_center,
             pc_process_id process_id,
             gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             grd.internal_contract_item_ref_no,
             (case
               when gmr.contract_type = 'Purchase' then
                'P'
               when gmr.contract_type = 'Sales' then
                'S'
               else
                'P'
             end) purchase_sales,
             grd.product_id,
             pdm.product_desc product_name,
             grd.origin_id,
             orm.origin_name,
             qat.quality_id,
             qat.quality_name,
             grd.container_no,
             grd.current_qty stock_qty,
             grd.qty_unit_id,
             gmr.qty_unit_id gmr_qty_unit_id,
             qum.qty_unit,
             grd.no_of_units,
             md.md_id,
             md.m2m_price_unit_id,
             md.net_m2m_price,
             md.m2m_price_unit_cur_id,
             md.m2m_price_unit_cur_code,
             md.m2m_price_unit_weight_unit_id,
             md.m2m_price_unit_weight_unit,
             nvl(md.m2m_price_unit_weight, 1) m2m_price_unit_weight,
             md.m2m_price_unit_cur_code || '/' ||
             decode(md.m2m_price_unit_weight,
                    1,
                    null,
                    md.m2m_price_unit_weight) ||
             md.m2m_price_unit_weight_unit m2m_price_unit_str,
             md.m2m_main_cur_id,
             md.m2m_main_cur_code,
             md.m2m_main_cur_decimals,
             md.main_currency_factor,
             md.settlement_cur_id,
             md.settlement_to_val_fx_rate,
             null contract_price, --cipd.contract_price,
             null price_unit_id, --cipd.price_unit_id,
             null price_unit_weight_unit_id, --cipd.price_unit_weight_unit_id,
             null price_unit_weight, --cipd.price_unit_weight,
             null price_unit_cur_id, --cipd.price_unit_cur_id,
             null price_unit_cur_code, --cipd.price_unit_cur_code,
             null price_unit_weight_unit, ---cipd.price_unit_weight_unit,
             null price_fixation_details, --cipd.price_fixation_details,
             pd_trade_date payment_due_date, --nvl(cipd.payment_due_date, '09-May-2011') payment_due_date,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
             grd.inventory_status,
             gsm.status shipment_status,
             (case
               when nvl(grd.is_afloat, 'N') = 'Y' and
                    nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                'Shipped NTT'
               when nvl(grd.is_afloat, 'N') = 'Y' and
                    nvl(grd.inventory_status, 'NA') = 'In' then
                'Shipped IN'
               when nvl(grd.is_afloat, 'N') = 'Y' and
                    nvl(grd.inventory_status, 'NA') = 'Out' then
                'Shipped TT'
               when nvl(grd.is_afloat, 'N') = 'N' and
                    nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                'Stock NTT'
               when nvl(grd.is_afloat, 'N') = 'N' and
                    nvl(grd.inventory_status, 'NA') = 'In' then
                'Stock IN'
               when nvl(grd.is_afloat, 'N') = 'N' and
                    nvl(grd.inventory_status, 'NA') = 'Out' then
                'Stock TT'
               else
                'Others'
             end) section_name,
             null price_basis, --cipd.price_basis,
             gmr.shed_id,
             gmr.destination_city_id,
             null price_fixation_status, ---cipd.price_fixation_status price_fixation_status,
             pdm.base_quantity_unit base_qty_unit_id,
             null strategy_id, --pcpd.strategy_id,
             null strategy_name, --css.strategy_name,
             null unfxd_qty, -- (ciqs.total_qty - nvl(ciqs.price_fixed_qty, 0)) unfxd_qty,
             null fxd_qty, --ciqs.price_fixed_qty fxd_qty,
             md.valuation_exchange_id,
             md.valuation_month,
             md.derivative_def_id,
             nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
             gmr.contract_type gmr_contract_type,
             null int_alloc_group_id,
             grd.internal_grd_ref_no internal_grd_dgrd_ref_no,
             grd.internal_stock_ref_no stock_ref_no,
             gmr.created_by trader_id,
             (case
               when gmr.created_by is not null then
                (select gab.firstname || ' ' || gab.lastname
                   from gab_globaladdressbook gab,
                        ak_corporate_user     aku
                  where gab.gabid = aku.gabid
                    and aku.user_id = gmr.created_by)
               else
                ''
             end) trader_user_name,
             md.m2m_loc_incoterm_deviation,
             md.m2m_quality_premium,
             md.m2m_product_premium,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             nvl(md.m2m_loc_incoterm_deviation, 0) +
             nvl(md.m2m_quality_premium, 0) +
             nvl(md.m2m_product_premium, 0) total_premium,
             qat.eval_basis,
             null delivery_premium, -- nvl(pcdb.premium, 0) delivery_premium,
             null delivery_premium_unit_id, -- pcdb.premium_unit_id delivery_premium_unit_id      
             gpd.contract_price gmr_price,
             gpd.price_unit_id gmr_price_unit_id,
             gpd.price_unit_weight_unit_id gmr_price_wt_unit_id,
             gpd.price_unit_weight gmr_price_wt,
             gpd.price_unit_cur_id gmr_price_cur_id,
             gpd.price_unit_cur_code gmr_price_cur_code,
             gpd.price_unit_weight_unit gmr_price_wt_unit,
             gpd.price_fixation_status gmr_price_fixation_status
        from gmr_goods_movement_record gmr,
             grd_goods_record_detail grd,
             gpd_gmr_price_daily gpd,
             pdm_productmaster pdm,
             orm_origin_master orm,
             qum_quantity_unit_master qum,
             qat_quality_attributes qat,
             ak_corporate akc,
             cm_currency_master cm,
             gsm_gmr_stauts_master gsm,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type <> 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'BASEMETAL'
                 and md1.process_id = pc_process_id) md,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'BASEMETAL'
                 and tmp.section_name <> 'OPEN') tmpc
       where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.process_id = gpd.process_id(+)
         and grd.origin_id = orm.origin_id(+)
         and grd.qty_unit_id = qum.qty_unit_id(+)
         and grd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
         and grd.internal_grd_ref_no = tmpc.internal_grd_ref_no(+)
         and tmpc.quality_id = qat.quality_id(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and gmr.status_id = gsm.status_id(+)
         and grd.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and gmr.corporate_id = pc_corporate_id
         and grd.status = 'Active'
         and grd.is_deleted = 'N'
         and gmr.is_deleted = 'N'
         and nvl(grd.inventory_status, 'NA') <> 'Out'
         and nvl(grd.current_qty, 0) > 0
         and gmr.is_internal_movement = 'Y';
  
    vc_base_price_unit_id          varchar2(15);
    vn_qty_in_base                 number;
    vn_m2m_amt                     number;
    vc_m2m_cur_id                  varchar2(15);
    vc_m2m_cur_code                varchar2(15);
    vn_m2m_sub_cur_id_factor       number;
    vn_m2m_cur_decimals            number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_contract_value_in_price_cur number;
    vn_cont_price_cur_decimals     number;
    --vn_spot_rate_price_to_val_cur  number;
    vn_contract_value_in_val_cur  number;
    vn_contract_value_in_base_cur number;
    vc_m2m_price_unit_str         varchar2(100);
    vc_m2m_price_unit_id          varchar2(15);
    vc_m2m_price_unit_cur_id      varchar2(15);
    vc_m2m_price_unit_cur_code    varchar2(15);
    vc_m2m_price_unit_qty_unit_id varchar2(15);
    vc_m2m_price_unit_qty_unit    varchar2(15);
    vn_m2m_price_unit_qty_unit_wt number;
    vn_ratio                      number;
    vn_corp_rate_val_to_base_cur  number;
    vn_spot_rate_base_to_val_cur  number;
    --vn_cog_value_in_base_cur       number;
    vn_expected_cog_net_sale_value number;
    vn_expected_cog_in_val_cur     number;
    vn_pnl_in_val_cur              number;
    vn_pnl_in_base_cur             number;
    vn_pnl_per_base_unit           number;
    vc_psu_id                      varchar2(500);
    vn_pnl_in_exch_price_unit      number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_m2m_base_fx_rate            number;
    vn_m2m_base_deviation          number;
    vn_m2m_amount_in_base          number;
    vn_m2m_total_amount            number;
    vn_m2m_total_premium_amt       number;
    vn_fx_price_to_base            number;
    vn_fx_price_deviation          number;
    vn_contract_premium_value      number;
    vn_contract_premium            number;
    vn_cont_delivery_premium       number;
    vn_cont_del_premium_amt        number;
    vc_base_price_unit             varchar2(20);
    vn_m2m_amt_per_unit            number;
    vn_cont_price                  number;
    vc_cont_price_unit_id          varchar2(15);
    vc_cont_price_unit_cur_id      varchar2(15);
    vc_cont_price_unit_cur_code    varchar2(15);
    vn_cont_price_wt               number;
    vc_cont_price_wt_unit_id       varchar2(15);
    vc_cont_price_wt_unit          varchar2(15);
    vc_price_fixation_status       varchar2(50);
    vc_error_msg                   varchar2(100);
    vc_error                       varchar2(100);
  begin
    for cur_grd_rows in cur_grd
    loop
      vn_cont_delivery_premium      := 0;
      vn_cont_del_premium_amt       := 0;
      vn_contract_premium           := 0;
      vn_contract_value_in_base_cur := 0;
      vn_contract_premium_value     := 0;
      vn_cont_price                 := 0;
      vc_cont_price_unit_id         := null;
      vc_cont_price_unit_cur_id     := null;
      vc_cont_price_unit_cur_code   := null;
      vn_cont_price_wt              := 1;
      vc_cont_price_wt_unit_id      := null;
      vc_cont_price_wt_unit         := null;
      vc_price_fixation_status      := null;
      if cur_grd_rows.gmr_price is null then
        vn_cont_price               := cur_grd_rows.contract_price;
        vc_cont_price_unit_id       := cur_grd_rows.price_unit_id;
        vc_cont_price_unit_cur_id   := cur_grd_rows.price_unit_cur_id;
        vc_cont_price_unit_cur_code := cur_grd_rows.price_unit_cur_code;
        vn_cont_price_wt            := cur_grd_rows.price_unit_weight;
        vc_cont_price_wt_unit_id    := cur_grd_rows.price_unit_weight_unit_id;
        vc_cont_price_wt_unit       := cur_grd_rows.price_unit_weight_unit;
        vc_price_fixation_status    := cur_grd_rows.price_fixation_status;
      
      else
        vn_cont_price               := cur_grd_rows.gmr_price;
        vc_cont_price_unit_id       := cur_grd_rows.gmr_price_unit_id;
        vc_cont_price_unit_cur_id   := cur_grd_rows.gmr_price_cur_id;
        vc_cont_price_unit_cur_code := cur_grd_rows.gmr_price_cur_code;
        vn_cont_price_wt            := cur_grd_rows.gmr_price_wt;
        vc_cont_price_wt_unit_id    := cur_grd_rows.gmr_price_wt_unit_id;
        vc_cont_price_wt_unit       := cur_grd_rows.gmr_price_wt_unit;
        vc_price_fixation_status    := cur_grd_rows.gmr_price_fixation_status;
      end if;
    
      vc_error_msg := vn_cont_price || vc_cont_price_unit_id;
      if cur_grd_rows.stock_qty <> 0 then
        vc_psu_id := cur_grd_rows.internal_gmr_ref_no || '-' ||
                     cur_grd_rows.internal_grd_dgrd_ref_no || '-' ||
                     cur_grd_rows.internal_contract_item_ref_no || '-' ||
                     cur_grd_rows.container_no;
        -- get the base price unit id
        vc_error_msg   := '1';
        vn_qty_in_base := cur_grd_rows.stock_qty *
                          pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                               cur_grd_rows.qty_unit_id,
                                                               cur_grd_rows.base_qty_unit_id,
                                                               1);
        vc_error_msg   := '2';
        if cur_grd_rows.eval_basis = 'FIXED' then
          vn_m2m_amt               := 0;
          vc_m2m_price_unit_cur_id := cur_grd_rows.base_cur_id;
        else
          vc_m2m_price_unit_cur_id := nvl(cur_grd_rows.m2m_price_unit_cur_id,
                                          cur_grd_rows.base_cur_id);
          vn_m2m_amt               := nvl(cur_grd_rows.net_m2m_price, 0) /
                                      nvl(cur_grd_rows.m2m_price_unit_weight,
                                          1) *
                                      pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                           cur_grd_rows.qty_unit_id,
                                                                           cur_grd_rows.m2m_price_unit_weight_unit_id,
                                                                           cur_grd_rows.stock_qty);
        end if;
        vc_error_msg := '3';
        pkg_general.sp_get_main_cur_detail(nvl(vc_m2m_price_unit_cur_id,
                                               cur_grd_rows.base_cur_id),
                                           vc_m2m_cur_id,
                                           vc_m2m_cur_code,
                                           vn_m2m_sub_cur_id_factor,
                                           vn_m2m_cur_decimals);
      
        vn_m2m_amt   := round(vn_m2m_amt * vn_m2m_sub_cur_id_factor, 2);
        vc_error_msg := '4';
        pkg_general.sp_forward_cur_exchange_new(cur_grd_rows.corporate_id,
                                                pd_trade_date,
                                                cur_grd_rows.payment_due_date,
                                                nvl(vc_m2m_cur_id,
                                                    cur_grd_rows.base_cur_id),
                                                cur_grd_rows.base_cur_id,
                                                30,
                                                vn_m2m_base_fx_rate,
                                                vn_m2m_base_deviation);
        vc_error_msg := '5';
        if vc_m2m_cur_id <> cur_grd_rows.base_cur_id then
          if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
                                                                 'PHY-005',
                                                                 cur_grd_rows.base_cur_code ||
                                                                 ' to ' ||
                                                                 vc_m2m_cur_code,
                                                                 '',
                                                                 gvc_process,
                                                                 pc_user_id,
                                                                 sysdate,
                                                                 pd_trade_date);
            sp_insert_error_log(vobj_error_log);
          
          end if;
        end if;
      
        vn_m2m_amount_in_base    := vn_m2m_amt * vn_m2m_base_fx_rate;
        vn_m2m_total_premium_amt := vn_qty_in_base *
                                    cur_grd_rows.total_premium;
        vn_m2m_total_amount      := vn_m2m_amount_in_base +
                                    vn_m2m_total_premium_amt;
        vc_error_msg             := '6';
        vn_m2m_amt_per_unit      := round(vn_m2m_total_amount /
                                          vn_qty_in_base,
                                          8);
      
        pkg_general.sp_get_main_cur_detail(nvl(vc_cont_price_unit_cur_id,
                                               cur_grd_rows.base_cur_id),
                                           vc_price_cur_id,
                                           vc_price_cur_code,
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
        vc_error_msg := '7';
        if nvl(vn_cont_price, 0) <> 0 and
           vc_cont_price_wt_unit_id is not null then
          vc_error_msg                   := '8';
          vn_contract_value_in_price_cur := (vn_cont_price /
                                            nvl(vn_cont_price_wt, 1)) *
                                            (pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                                  cur_grd_rows.qty_unit_id,
                                                                                  vc_cont_price_wt_unit_id,
                                                                                  cur_grd_rows.stock_qty)) *
                                            vn_cont_price_cur_id_factor;
        else
          vn_contract_value_in_price_cur := 0;
        end if;
        vc_error_msg := '9';
        pkg_general.sp_forward_cur_exchange_new(cur_grd_rows.corporate_id,
                                                pd_trade_date,
                                                cur_grd_rows.payment_due_date,
                                                vc_price_cur_id,
                                                cur_grd_rows.base_cur_id,
                                                30,
                                                vn_fx_price_to_base,
                                                vn_fx_price_deviation);
      
        vn_contract_value_in_price_cur := round(vn_contract_value_in_price_cur,
                                                vn_cont_price_cur_decimals);
      
        vn_contract_value_in_val_cur := round((vn_contract_value_in_price_cur *
                                              nvl(vn_fx_price_to_base, 1)),
                                              2);
      end if;
      vc_error_msg          := '10';
      vc_m2m_price_unit_str := cur_grd_rows.m2m_price_unit_str;
      vc_m2m_price_unit_id  := cur_grd_rows.m2m_price_unit_id;
      -- vc_m2m_price_unit_cur_id      := cur_grd_rows.m2m_price_unit_cur_id1;
      -- vc_m2m_price_unit_cur_code    := cur_grd_rows.m2m_price_unit_cur_code1;
      -- vc_m2m_price_unit_qty_unit_id := cur_grd_rows.m2m_price_unit_qty_unit_id1;
      -- vc_m2m_price_unit_qty_unit    := cur_grd_rows.m2m_price_unit_qty_unit1;
      --vn_m2m_price_unit_qty_unit_wt := cur_grd_rows.m2m_price_unit_qty_unit_wt1;
    
      --   vn_spot_rate_base_to_val_cur := cur_grd_rows.spot_fx_rate;
      --  vn_corp_rate_val_to_base_cur := cur_grd_rows.corp_fx_rate;
    
      begin
        select ppu.product_price_unit_id
          into vc_base_price_unit
          from v_ppu_pum ppu
         where ppu.cur_id = cur_grd_rows.base_cur_id
           and ppu.weight_unit_id = cur_grd_rows.base_qty_unit_id
           and nvl(ppu.weight, 1) = 1
           and ppu.product_id = cur_grd_rows.product_id;
      exception
        when others then
          sp_write_log(pc_corporate_id,
                       pd_trade_date,
                       'sp_open_phy_unreal',
                       'vc_base_price_unit' || vc_base_price_unit || ' For' ||
                       cur_grd_rows.internal_contract_item_ref_no);
      end;
      vc_error_msg          := '11';
      vc_base_price_unit_id := vc_base_price_unit;
      -------
      ------------------******** Premium Calculations starts here ******-------------------
      sp_calc_quality_premium(cur_grd_rows.internal_contract_item_ref_no,
                              vc_base_price_unit,
                              pc_corporate_id,
                              pd_trade_date,
                              cur_grd_rows.product_id,
                              pc_process_id,
                              vn_contract_premium);
      --calculate contract delivery premium from pcdb
      vc_error_msg := '12';
      if cur_grd_rows.delivery_premium <> 0 then
        if cur_grd_rows.delivery_premium_unit_id <> vc_base_price_unit then
          vn_cont_delivery_premium := cur_grd_rows.delivery_premium *
                                      pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                                      1,
                                                                                      cur_grd_rows.delivery_premium_unit_id,
                                                                                      vc_base_price_unit,
                                                                                      pd_trade_date);
        else
          vn_cont_delivery_premium := cur_grd_rows.delivery_premium;
        end if;
        vn_cont_del_premium_amt := round(vn_cont_delivery_premium *
                                         vn_qty_in_base,
                                         2);
      else
        vn_cont_delivery_premium := 0;
        vn_cont_del_premium_amt  := 0;
      end if;
      vc_error_msg              := '13';
      vn_contract_premium_value := round((vn_contract_premium *
                                         vn_qty_in_base) +
                                         vn_cont_del_premium_amt,
                                         2);
    
      ------------------******** Premium Calculations ends here ******-------------------
      ---- Add premium to contract value,as vn_contract_value_in_val_cur is in base currency and vn_contract_premium_value also in base currency
      vn_contract_value_in_base_cur := vn_contract_value_in_val_cur +
                                       vn_contract_premium_value;
      vn_contract_value_in_val_cur  := vn_contract_value_in_val_cur +
                                       vn_contract_premium_value;
      --------------------------------------------------------------------------
      vc_error_msg               := '14';
      vn_expected_cog_in_val_cur := round(vn_contract_value_in_val_cur, 2);
    
      if cur_grd_rows.purchase_sales = 'P' then
        vn_contract_value_in_val_cur := (-1) * vn_contract_value_in_val_cur;
        vn_expected_cog_in_val_cur   := (-1) * vn_expected_cog_in_val_cur;
      else
        vn_contract_value_in_val_cur := vn_contract_value_in_val_cur;
        vn_expected_cog_in_val_cur   := vn_expected_cog_in_val_cur;
      end if;
    
      vn_expected_cog_net_sale_value := round(vn_expected_cog_in_val_cur, 2);
      /*If cur_grd_rows.purchase_sales = 'P' then
        vn_pnl_in_val_cur := (vn_m2m_total_amount -
                             (nvl(vn_expected_cog_in_val_cur, 0) * (-1)));
      else
        vn_pnl_in_val_cur := (nvl(vn_expected_cog_in_val_cur, 0) -
                             vn_m2m_total_amount);
      end if;
      
      vn_pnl_in_val_cur    := round(vn_pnl_in_val_cur, 2);
      vn_pnl_in_base_cur   := round(vn_pnl_in_val_cur, 2);
      vn_pnl_per_base_unit := round(vn_pnl_in_base_cur /
                                    nvl(vn_qty_in_base, 1),
                                    5);*/
      vc_error_msg         := '15';
      vn_pnl_in_val_cur    := 0;
      vn_pnl_in_base_cur   := 0;
      vn_pnl_per_base_unit := 0;
      insert into psu_phy_stock_unrealized
        (process_id,
         psu_id,
         corporate_id,
         internal_gmr_ref_no,
         internal_contract_item_ref_no,
         product_id,
         product_name,
         origin_id,
         origin_name,
         quality_id,
         quality_name,
         container_no,
         growth_code_id,
         growth_code_name,
         stock_qty,
         qty_unit_id,
         qty_unit,
         no_of_units,
         md_id,
         m2m_price_unit_id,
         m2m_price_unit_str,
         m2m_amt,
         m2m_amt_cur_id,
         m2m_amt_cur_code,
         contract_value_in_price_cur,
         contract_price_cur_id,
         contract_price_cur_code,
         material_cost_in_base_cur,
         material_cost_in_val_cur,
         sc_in_base_cur,
         sc_in_valuation_cur,
         expected_cog_in_base_cur,
         expected_cog_in_val_cur,
         pnl_type,
         pnl_in_base_cur,
         pnl_in_val_cur,
         prev_day_pnl_in_base_cur,
         prev_day_pnl_in_val_cur,
         trade_day_pnl_in_base_cur,
         trade_day_pnl_in_val_cur,
         pnl_in_exch_price_unit,
         prev_pnl_in_exch_price_unit,
         day_pnl_in_exch_price_unit,
         pnl_per_base_unit,
         trade_day_pnl_per_base_unit,
         fw_fx_price_cur_to_m2m_cur,
         fw_fx_base_cur_to_m2m_cur,
         spot_rate_m2m_cur_to_base_cur,
         base_cur_id,
         base_cur_code,
         inventory_status,
         shipment_status,
         section_name,
         base_price_unit_id,
         qty_in_base_unit,
         m2m_price_unit_cur_id,
         m2m_price_unit_cur_code,
         m2m_price_unit_qty_unit_id,
         m2m_price_unit_qty_unit,
         m2m_price_unit_qty_unit_weight,
         --fw_spot_base_cur_to_m2m_cur,
         spot_price_cur_to_base_cur,
         invm_inventory_status,
         strategy_id,
         strategy_name,
         valuation_month,
         contract_type,
         profit_center_id,
         net_m2m_price,
         unfxd_qty,
         fxd_qty,
         valuation_exchange_id,
         --price_month,
         derivative_def_id,
         price_to_val_rate,
         val_to_base_rate,
         base_to_val_rate,
         sec_cost_ratio,
         gmr_contract_type,
         is_voyage_gmr,
         sc_to_val_fx_rate,
         sc_to_val_fx_rate_cur_id,
         sc_to_val_fx_rate_cur_code,
         int_alloc_group_id,
         internal_grd_dgrd_ref_no,
         vessel_id,
         charter_voyage_id,
         vessel_voyage_name,
         price_type_id,
         price_type_name,
         price_string,
         item_delivery_period_string,
         fixation_method,
         price_fixation_details,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight,
         price_unit_weight_unit,
         voyage_ref_no,
         cma_purchase_ref_no,
         cma_purchase_cp_no,
         cma_purchase_item_ref_no,
         stock_ref_no,
         cma_stock,
         trader_name,
         trader_id,
         unreal_pnl_in_base_per_unit,
         unreal_pnl_in_val_cur_per_unit,
         contract_premium_value,
         m2m_quality_premium,
         m2m_product_premium,
         m2m_loc_diff_premium,
         base_price_unit_id_in_ppu,
         base_price_unit_id_in_pum,
         market_premimum_amt,
         m2m_amt_per_unit)
      values
        (pc_process_id,
         vc_psu_id,
         pc_corporate_id,
         cur_grd_rows.internal_gmr_ref_no,
         cur_grd_rows.internal_contract_item_ref_no,
         cur_grd_rows.product_id,
         cur_grd_rows.product_name,
         cur_grd_rows.origin_id,
         cur_grd_rows.origin_name,
         cur_grd_rows.quality_id,
         cur_grd_rows.quality_name,
         cur_grd_rows.container_no,
         null,
         null,
         cur_grd_rows.stock_qty,
         cur_grd_rows.qty_unit_id,
         cur_grd_rows.qty_unit,
         cur_grd_rows.no_of_units,
         cur_grd_rows.md_id,
         vc_m2m_price_unit_id,
         vc_m2m_price_unit_str,
         vn_m2m_total_amount,
         cur_grd_rows.base_cur_id,
         cur_grd_rows.base_cur_code,
         vn_contract_value_in_price_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vn_contract_value_in_base_cur,
         vn_contract_value_in_val_cur,
         null, --vn_sc_in_base_cur,
         null, --vn_sc_in_valuation_cur,
         vn_expected_cog_net_sale_value,
         vn_expected_cog_in_val_cur,
         'Unrealized',
         vn_pnl_in_base_cur,
         vn_pnl_in_val_cur,
         null, --prev_day_pnl_in_base_cur
         null, -- prev_day_pnl_in_val_cur
         null, -- trade_day_pnl_in_base_cur
         null, --  trade_day_pnl_in_val_cur
         vn_pnl_in_exch_price_unit,
         null, --   prev_pnl_in_exch_price_unit
         null, --  day_pnl_in_exch_price_unit
         vn_pnl_per_base_unit, --  v_pnl_per_base_unit
         null, -- trade_day_pnl_per_base_unit
         null, --fw_fx_price_cur_to_m2m_cur
         null, --fw_fx_base_cur_to_m2m_cur
         vn_corp_rate_val_to_base_cur,
         cur_grd_rows.base_cur_id,
         cur_grd_rows.base_cur_code,
         cur_grd_rows.inventory_status,
         cur_grd_rows.shipment_status,
         cur_grd_rows.section_name,
         vc_base_price_unit_id,
         vn_qty_in_base,
         vc_m2m_price_unit_cur_id,
         vc_m2m_price_unit_cur_code,
         vc_m2m_price_unit_qty_unit_id,
         vc_m2m_price_unit_qty_unit,
         vn_m2m_price_unit_qty_unit_wt,
         vn_fx_price_to_base, --vn_corp_rate_price_to_base_cur,
         null, --cur_grd_rows.invm_inventory_status,
         cur_grd_rows.strategy_id,
         cur_grd_rows.strategy_name,
         cur_grd_rows.valuation_month,
         cur_grd_rows.purchase_sales,
         cur_grd_rows.profit_center,
         cur_grd_rows.net_m2m_price,
         cur_grd_rows.unfxd_qty,
         cur_grd_rows.fxd_qty,
         cur_grd_rows.valuation_exchange_id,
         --cur_grd_rows.price_month,
         cur_grd_rows.derivative_def_id,
         null, --vn_spot_rate_price_to_val_cur,
         vn_m2m_base_fx_rate, --vn_corp_rate_val_to_base_cur,
         null, --vn_spot_rate_base_to_val_cur,
         vn_ratio,
         cur_grd_rows.gmr_contract_type,
         cur_grd_rows.is_voyage_gmr,
         vn_spot_rate_base_to_val_cur,
         null, --sc_to_val_fx_rate_cur_id
         null, --sc_to_val_fx_rate_cur_code
         cur_grd_rows.int_alloc_group_id,
         cur_grd_rows.internal_grd_dgrd_ref_no,
         null, --cur_grd_rows.vessel_id,
         null, --cur_grd_rows.voyage_number,
         null, --cur_grd_rows.vessel_voyage_name,
         cur_grd_rows.price_basis,
         null, --cur_grd_rows.price_type_name,
         null, --cur_grd_rows.price_string
         null, --cur_grd_rows.item_delivery_period_string
         vc_price_fixation_status,
         cur_grd_rows.price_fixation_details,
         vn_cont_price,
         vc_cont_price_unit_id,
         vc_cont_price_unit_cur_id,
         vc_cont_price_unit_cur_code,
         vc_cont_price_wt_unit_id,
         vn_cont_price_wt,
         vc_cont_price_wt_unit,
         null, --cur_grd_rows.voyage_ref_no,
         null, ---cur_grd_rows.cma_purchase_ref_no,
         null, --cur_grd_rows.cma_purchase_cp_no,
         null, --cur_grd_rows.purchase_item_ref_no,
         cur_grd_rows.stock_ref_no,
         null, --cur_grd_rows.cma_stock,
         cur_grd_rows.trader_user_name,
         cur_grd_rows.trader_id,
         vn_pnl_in_base_cur / decode(vn_qty_in_base, 0, 1, vn_qty_in_base),
         vn_pnl_in_val_cur / decode(vn_qty_in_base, 0, 1, vn_qty_in_base),
         vn_contract_premium_value,
         cur_grd_rows.m2m_quality_premium,
         cur_grd_rows.m2m_product_premium,
         cur_grd_rows.m2m_loc_incoterm_deviation,
         cur_grd_rows.base_price_unit_id_in_ppu,
         cur_grd_rows.base_price_unit_id_in_pum,
         vn_m2m_total_premium_amt,
         vn_m2m_amt_per_unit);
    end loop;
    -----------
    vc_error_msg := '16';
    commit;
    sp_gather_stats('psu_phy_stock_unrealized');
    sp_gather_stats('pcm_physical_contract_main');
    sp_gather_stats('pci_physical_contract_item');
    sp_gather_stats('cipd_contract_item_price_daily');
    dbms_output.put_line('finsihed loop');
    vc_error_msg := '17';
    begin
      -- update previous eod data
      for cur_update in (select psu_prev_day.unreal_pnl_in_base_per_unit,
                                psu_prev_day.unreal_pnl_in_val_cur_per_unit,
                                psu_prev_day.pnl_in_exch_price_unit,
                                psu_prev_day.m2m_quality_premium,
                                psu_prev_day.m2m_product_premium,
                                psu_prev_day.m2m_loc_diff_premium,
                                psu_prev_day.market_premimum_amt,
                                psu_prev_day.net_m2m_price,
                                psu_prev_day.m2m_price_unit_id,
                                psu_prev_day.m2m_amt,
                                psu_prev_day.m2m_amt_cur_id,
                                psu_prev_day.m2m_amt_cur_code,
                                psu_prev_day.psu_id,
                                psu_prev_day.m2m_amt_per_unit
                           from psu_phy_stock_unrealized psu_prev_day
                          where process_id = gvc_previous_process_id
                            and corporate_id = pc_corporate_id)
      loop
        vc_error_msg := '18';
        update psu_phy_stock_unrealized psu_today
           set psu_today.prev_day_pnl_in_val_cur     = cur_update.unreal_pnl_in_val_cur_per_unit *
                                                       psu_today.qty_in_base_unit,
               psu_today.prev_day_pnl_in_base_cur    = cur_update.unreal_pnl_in_base_per_unit *
                                                       psu_today.qty_in_base_unit,
               psu_today.prev_pnl_in_exch_price_unit = cur_update.pnl_in_exch_price_unit,
               psu_today.prev_m2m_quality_premium    = cur_update.m2m_quality_premium,
               psu_today.prev_m2m_product_premium    = cur_update.m2m_product_premium,
               psu_today.prev_m2m_loc_diff_premium   = cur_update.m2m_loc_diff_premium,
               psu_today.prev_market_premimum_amt    = cur_update.market_premimum_amt,
               psu_today.prev_market_price           = cur_update.net_m2m_price,
               psu_today.prev_market_price_unit_id   = cur_update.m2m_price_unit_id,
               psu_today.prev_market_value           = round(nvl(cur_update.m2m_amt_per_unit,
                                                                 0) *
                                                             psu_today.qty_in_base_unit,
                                                             4),
               psu_today.prev_market_value_cur_id    = cur_update.m2m_amt_cur_id,
               psu_today.prev_market_value_cur_code  = cur_update.m2m_amt_cur_code,
               psu_today.prev_m2m_amt_per_unit       = cur_update.m2m_amt_per_unit,
               psu_today.cont_unr_status             = 'EXISTING_TRADE'
         where psu_today.psu_id = cur_update.psu_id
           and psu_today.process_id = pc_process_id
           and psu_today.corporate_id = pc_corporate_id;
      end loop;
    exception
      when others then
        dbms_output.put_line('SQLERRM-1' || sqlerrm);
    end;
    vc_error_msg := '19';
    -- mark the trades came as new in this eod/eom
    begin
      update psu_phy_stock_unrealized psu
         set psu.prev_day_pnl_in_val_cur     = psu.unreal_pnl_in_val_cur_per_unit *
                                               psu.qty_in_base_unit,
             psu.prev_day_pnl_in_base_cur    = psu.unreal_pnl_in_base_per_unit *
                                               psu.qty_in_base_unit,
             psu.prev_pnl_in_exch_price_unit = psu.pnl_in_exch_price_unit,
             psu.prev_m2m_quality_premium    = psu.m2m_quality_premium,
             psu.prev_m2m_product_premium    = psu.m2m_product_premium,
             psu.prev_m2m_loc_diff_premium   = psu.m2m_loc_diff_premium,
             psu.prev_market_premimum_amt    = psu.market_premimum_amt,
             psu.prev_market_price           = psu.net_m2m_price,
             psu.prev_market_price_unit_id   = psu.m2m_price_unit_id,
             psu.prev_market_value           = psu.m2m_amt,
             psu.prev_market_value_cur_id    = psu.m2m_amt_cur_id,
             psu.prev_market_value_cur_code  = psu.m2m_amt_cur_code,
             psu.prev_m2m_amt_per_unit       = psu.m2m_amt_per_unit,
             psu.cont_unr_status             = 'NEW_TRADE'
       where psu.cont_unr_status is null
         and psu.process_id = pc_process_id
         and psu.corporate_id = pc_corporate_id;
    exception
      when others then
        dbms_output.put_line('SQLERRM-2' || sqlerrm);
    end;
    vc_error_msg := '20';
    update psu_phy_stock_unrealized psu
       set psu.pnl_in_val_cur                 = (psu.m2m_amt -
                                                psu.prev_market_value),
           psu.pnl_in_base_cur                = (psu.m2m_amt -
                                                psu.prev_market_value),
           psu.unreal_pnl_in_base_per_unit    = (psu.m2m_amt -
                                                psu.prev_market_value) /
                                                psu.qty_in_base_unit,
           psu.unreal_pnl_in_val_cur_per_unit = (psu.m2m_amt -
                                                psu.prev_market_value) /
                                                psu.qty_in_base_unit
     where psu.process_id = pc_process_id
       and psu.corporate_id = pc_corporate_id;
  
    /*for cur_update in (select poud_prev_day.internal_contract_item_ref_no,
                              poud_prev_day.unreal_pnl_in_base_per_unit,
                              poud_prev_day.unreal_pnl_in_val_cur_per_unit,
                              poud_prev_day.m2m_amt_cur_id
                         from poud_phy_open_unreal_daily poud_prev_day
                        where process_id = gvc_previous_process_id
                          and corporate_id = pc_corporate_id)
    loop
      update psu_phy_stock_unrealized psu_today
         set psu_today.prev_day_pnl_in_val_cur  = cur_update.unreal_pnl_in_val_cur_per_unit * psu_today.qty_in_base_unit,
             psu_today.prev_day_pnl_in_base_cur = cur_update.unreal_pnl_in_base_per_unit * psu_today.qty_in_base_unit
       where psu_today.internal_contract_item_ref_no =
             cur_update.internal_contract_item_ref_no
         and nvl(psu_today.prev_day_pnl_in_val_cur, 0) = 0
         and 'TRUE' = (case when psu_today.contract_type = 'P' and
              psu_today.inventory_status = 'Under CMA' then 'FALSE' else
              'TRUE' end)
         and psu_today.process_id = pc_process_id;
    end loop;*/
    --
    -- update trade day pnl values
    -- it is the difference of unrealized pnl on trade date and previous eod date
    --
    vc_error_msg := '21';
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Phy Stock Unrlzd',
                 'after loop' || vc_error_msg);
    update psu_phy_stock_unrealized psu
       set trade_day_pnl_in_val_cur  = nvl(psu.pnl_in_val_cur, 0) -
                                       nvl(psu.prev_day_pnl_in_val_cur, 0),
           trade_day_pnl_in_base_cur = nvl(psu.pnl_in_base_cur, 0) -
                                       nvl(psu.prev_day_pnl_in_base_cur, 0)
     where psu.process_id = pc_process_id;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Phy Stock Unrlzd',
                 'after update' || vc_error_msg);
    --
    -- insert into contract and price data for the contract items that are in pss
    --
    vc_error_msg := '22';
    update psu_phy_stock_unrealized pss
       set (gmr_ref_no, origination_city_id, origination_country_id, destination_city_id, destination_country_id, origination_city, origination_country, destination_city, destination_country, warehouse_id, warehouse_name, shed_id, shed_name, product_id, prod_base_unit_id, prod_base_unit) = (select gmr.gmr_ref_no,
                                                                                                                                                                                                                                                                                                           gmr.origin_city_id,
                                                                                                                                                                                                                                                                                                           gmr.origin_country_id,
                                                                                                                                                                                                                                                                                                           gmr.destination_city_id,
                                                                                                                                                                                                                                                                                                           gmr.destination_country_id,
                                                                                                                                                                                                                                                                                                           cim_orig.city_name as origin_city_name,
                                                                                                                                                                                                                                                                                                           cym_orig.country_name origin_country_name,
                                                                                                                                                                                                                                                                                                           cim_dest.city_name as destination_city_name,
                                                                                                                                                                                                                                                                                                           cym_dest.country_name destination_country_name,
                                                                                                                                                                                                                                                                                                           gmr.warehouse_profile_id,
                                                                                                                                                                                                                                                                                                           phd_gmr.companyname as warehouse_profile_name,
                                                                                                                                                                                                                                                                                                           gmr.shed_id,
                                                                                                                                                                                                                                                                                                           sld.storage_location_name,
                                                                                                                                                                                                                                                                                                           pss.product_id,
                                                                                                                                                                                                                                                                                                           pdm.base_quantity_unit,
                                                                                                                                                                                                                                                                                                           qum.qty_unit
                                                                                                                                                                                                                                                                                                      from gmr_goods_movement_record   gmr,
                                                                                                                                                                                                                                                                                                           pdm_productmaster           pdm,
                                                                                                                                                                                                                                                                                                           phd_profileheaderdetails    phd_gmr,
                                                                                                                                                                                                                                                                                                           sld_storage_location_detail sld,
                                                                                                                                                                                                                                                                                                           cim_citymaster              cim_orig,
                                                                                                                                                                                                                                                                                                           cym_countrymaster           cym_orig,
                                                                                                                                                                                                                                                                                                           cim_citymaster              cim_dest,
                                                                                                                                                                                                                                                                                                           cym_countrymaster           cym_dest,
                                                                                                                                                                                                                                                                                                           qum_quantity_unit_master    qum
                                                                                                                                                                                                                                                                                                     where gmr.internal_gmr_ref_no =
                                                                                                                                                                                                                                                                                                           pss.internal_gmr_ref_no
                                                                                                                                                                                                                                                                                                       and pss.product_id =
                                                                                                                                                                                                                                                                                                           pdm.product_id
                                                                                                                                                                                                                                                                                                       and pdm.base_quantity_unit =
                                                                                                                                                                                                                                                                                                           qum.qty_unit_id
                                                                                                                                                                                                                                                                                                       and gmr.warehouse_profile_id =
                                                                                                                                                                                                                                                                                                           phd_gmr.profileid(+)
                                                                                                                                                                                                                                                                                                       and gmr.shed_id =
                                                                                                                                                                                                                                                                                                           sld.storage_loc_id(+)
                                                                                                                                                                                                                                                                                                       and gmr.origin_city_id =
                                                                                                                                                                                                                                                                                                           cim_orig.city_id(+)
                                                                                                                                                                                                                                                                                                       and gmr.origin_country_id =
                                                                                                                                                                                                                                                                                                           cym_orig.country_id(+)
                                                                                                                                                                                                                                                                                                       and gmr.destination_city_id =
                                                                                                                                                                                                                                                                                                           cim_dest.city_id(+)
                                                                                                                                                                                                                                                                                                       and gmr.destination_country_id =
                                                                                                                                                                                                                                                                                                           cym_dest.country_id(+)
                                                                                                                                                                                                                                                                                                       and pss.process_id =
                                                                                                                                                                                                                                                                                                           gmr.process_id
                                                                                                                                                                                                                                                                                                       and pss.process_id =
                                                                                                                                                                                                                                                                                                           pc_process_id)
     where pss.process_id = pc_process_id;
    --
    --
    vc_error_msg := '23';
    update md_m2m_daily md
       set md.m2m_price_unit_weight = null
     where md.m2m_price_unit_weight = 1
       and md.process_id = pc_process_id;
    /*update psci_phy_stock_contract_item psci
      set psci.price_unit_weight = null
    where psci.price_unit_weight = 1
      and psci.process_id = pc_process_id;  */
    vc_error_msg := '24';
  exception
    when others then
      dbms_output.put_line('failed with ' || sqlerrm);
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_phy_stock_unreal_pnl',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm || '- ' ||
                                                           vc_error_msg,
                                                           '',
                                                           gvc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_cal_phy_stok_con_unreal_pnl(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_user_id      varchar2) is
  
    cursor cur_grd is
      select 'Purchase' section_type,
             pcpd.profit_center_id profit_center,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             pc_process_id process_id,
             gmr.corporate_id,
             akc.corporate_name,
             gmr.internal_gmr_ref_no,
             grd.internal_contract_item_ref_no,
             pci.del_distribution_item_no,
             pcdi.delivery_item_no,
             pcm.contract_ref_no,
             pcm.purchase_sales,
             grd.product_id conc_product_id,
             aml.underlying_product_id product_id,
             pdm.product_desc product_name,
             grd.origin_id,
             orm.origin_name,
             pcpq.quality_template_id conc_quality_id,
             qav.comp_quality_id quality_id,
             qat_und.quality_name,
             grd.container_no,
             grd.current_qty stock_qty,
             grd.qty_unit_id,
             gmr.qty_unit_id gmr_qty_unit_id,
             qum.qty_unit,
             qum.decimals stocky_qty_decimal,
             grd.no_of_units,
             md.md_id,
             md.m2m_price_unit_id,
             md.net_m2m_price,
             md.m2m_price_unit_cur_id,
             md.m2m_price_unit_cur_code,
             md.m2m_price_unit_weight_unit_id,
             md.m2m_price_unit_weight_unit,
             nvl(md.m2m_price_unit_weight, 1) m2m_price_unit_weight,
             md.m2m_price_unit_cur_code || '/' ||
             decode(md.m2m_price_unit_weight,
                    1,
                    null,
                    md.m2m_price_unit_weight) ||
             md.m2m_price_unit_weight_unit m2m_price_unit_str,
             md.m2m_main_cur_id,
             md.m2m_main_cur_code,
             md.m2m_main_cur_decimals,
             md.main_currency_factor,
             md.settlement_cur_id,
             md.settlement_to_val_fx_rate,
             cipde.element_id,
             aml.attribute_name,
             pcpq.assay_header_id,
             cipde.assay_qty,
             cipde.assay_qty_unit_id,
             --cipde.payable_qty,
             -- cipde.payable_qty_unit_id,
             gmr_qty.payable_qty,
             gmr_qty.qty_unit_id payable_qty_unit_id,
             gmr_qum.qty_unit payable_qty_unit,
             cipde.contract_price,
             cipde.price_unit_id,
             cipde.price_unit_weight_unit_id,
             cipde.price_unit_weight,
             cipde.price_unit_cur_id,
             cipde.price_unit_cur_code,
             cipde.price_unit_weight_unit,
             cipde.price_fixation_details,
             cipde.price_description,
             nvl(cipde.payment_due_date, pd_trade_date) payment_due_date,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
             cm.decimals as base_cur_decimal,
             grd.inventory_status,
             gsm.status shipment_status,
             (case
               when nvl(grd.is_afloat, 'N') = 'Y' and
                    nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                'Shipped NTT'
               when nvl(grd.is_afloat, 'N') = 'Y' and
                    nvl(grd.inventory_status, 'NA') = 'In' then
                'Shipped IN'
               when nvl(grd.is_afloat, 'N') = 'Y' and
                    nvl(grd.inventory_status, 'NA') = 'Out' then
                'Shipped TT'
               when nvl(grd.is_afloat, 'N') = 'N' and
                    nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                'Stock NTT'
               when nvl(grd.is_afloat, 'N') = 'N' and
                    nvl(grd.inventory_status, 'NA') = 'In' then
                'Stock IN'
               when nvl(grd.is_afloat, 'N') = 'N' and
                    nvl(grd.inventory_status, 'NA') = 'Out' then
                'Stock TT'
               else
                'Others'
             end) section_name,
             cipde.price_basis,
             gmr.shed_id,
             gmr.destination_city_id,
             cipde.price_fixation_status price_fixation_status,
             pdm.base_quantity_unit base_qty_unit_id,
             qum_pdm_conc.qty_unit_id as conc_base_qty_unit_id,
             qum_pdm_conc.decimals as base_qty_decimal,
             pcpd.strategy_id,
             css.strategy_name,
             md.valuation_exchange_id,
             md.valuation_month,
             md.derivative_def_id,
             nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
             gmr.contract_type gmr_contract_type,
             null int_alloc_group_id,
             grd.internal_grd_ref_no internal_grd_dgrd_ref_no,
             grd.internal_stock_ref_no stock_ref_no,
             pcm.trader_id,
             (case
               when pcm.trader_id is not null then
                (select gab.firstname || ' ' || gab.lastname
                   from gab_globaladdressbook gab,
                        ak_corporate_user     aku
                  where gab.gabid = aku.gabid
                    and aku.user_id = pcm.trader_id)
               else
                ''
             end) trader_user_name,
             md.m2m_loc_incoterm_deviation,
             md.treatment_charge m2m_treatment_charge,
             md.refine_charge m2m_refine_charge,
             tc_ppu_pum.price_unit_id m2m_tc_price_unit_id,
             tc_ppu_pum.price_unit_name m2m_tc_price_unit_name,
             tc_ppu_pum.cur_id m2m_tc_cur_id,
             tc_ppu_pum.weight m2m_tc_weight,
             tc_ppu_pum.weight_unit_id m2m_tc_weight_unit_id,
             rc_ppu_pum.price_unit_id m2m_rc_price_unit_id,
             rc_ppu_pum.price_unit_name m2m_rc_price_unit_name,
             rc_ppu_pum.cur_id m2m_rc_cur_id,
             rc_ppu_pum.weight m2m_rc_weight,
             rc_ppu_pum.weight_unit_id m2m_rc_weight_unit_id,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             gpd.contract_price gmr_price,
             gpd.price_unit_id gmr_price_unit_id,
             gpd.price_unit_weight_unit_id gmr_price_wt_unit_id,
             gpd.price_unit_weight gmr_price_wt,
             gpd.price_unit_cur_id gmr_price_cur_id,
             gpd.price_unit_cur_code gmr_price_cur_code,
             gpd.price_unit_weight_unit gmr_price_wt_unit,
             gpd.price_fixation_status gmr_price_fixation_status,
             qat.eval_basis,
             dense_rank() over(partition by pci.internal_contract_item_ref_no order by cipde.element_id) ele_rank,
             pcpq.unit_of_measure,
             pum_loc_base.weight_unit_id loc_qty_unit_id,
             tmpc.mvp_id,
             tmpc.shipment_month,
             tmpc.shipment_year,
             pum_base_price_id.price_unit_name base_price_unit_name,
             nvl(pdm_conc.valuation_against_underlying, 'Y') valuation_against_underlying
        from gmr_goods_movement_record gmr,
             grd_goods_record_detail grd,
             gpd_gmr_conc_price_daily gpd,
             pcm_physical_contract_main pcm,
             pcpd_pc_product_definition pcpd,
             cpc_corporate_profit_center cpc,
             pdm_productmaster pdm,
             orm_origin_master orm,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'CONCENTRATES'
                 and tmp.section_name <> 'OPEN') tmpc,
             qum_quantity_unit_master qum,
             qat_quality_attributes qat,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type <> 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'CONCENTRATES'
                 and md1.process_id = pc_process_id) md,
             cipde_cipd_element_price cipde,
             ciqs_contract_item_qty_status ciqs,
             pci_physical_contract_item pci,
             pcpq_pc_product_quality pcpq,
             pcdi_pc_delivery_item pcdi,
             qav_quality_attribute_values qav,
             ppm_product_properties_mapping ppm,
             qat_quality_attributes qat_und,
             aml_attribute_master_list aml,
             pcdb_pc_delivery_basis pcdb,
             ak_corporate akc,
             cm_currency_master cm,
             gsm_gmr_stauts_master gsm,
             css_corporate_strategy_setup css,
             pdm_productmaster pdm_conc,
             qum_quantity_unit_master qum_pdm_conc,
             pum_price_unit_master pum_loc_base,
             pum_price_unit_master pum_base_price_id,
             v_gmr_stockpayable_qty gmr_qty,
             qum_quantity_unit_master gmr_qum,
             v_ppu_pum tc_ppu_pum,
             v_ppu_pum rc_ppu_pum
       where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.profit_center_id = cpc.profit_center_id
            --and grd.product_id = pdm.product_id  Commnted pupose fully
         and grd.origin_id = orm.origin_id(+)
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.process_id = gpd.process_id(+)
         and grd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
         and grd.internal_grd_ref_no = tmpc.internal_grd_ref_no(+)
         and grd.internal_contract_item_ref_no =
             tmpc.internal_contract_item_ref_no(+)
         and tmpc.conc_quality_id = qat.quality_id
         and grd.qty_unit_id = qum.qty_unit_id(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and tmpc.element_id = cipde.element_id
         and md.element_id = cipde.element_id
         and grd.internal_contract_item_ref_no =
             cipde.internal_contract_item_ref_no
         and grd.process_id = cipde.process_id
         and cipde.internal_contract_ref_no = pcm.internal_contract_ref_no
         and grd.internal_contract_item_ref_no =
             ciqs.internal_contract_item_ref_no
         and grd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = pci.pcdi_id
         and pcpq.quality_template_id = qat.quality_id(+)
         and qat.quality_id = qav.quality_id
         and qav.attribute_id = ppm.property_id
         and qav.comp_quality_id = qat_und.quality_id
         and ppm.attribute_id = aml.attribute_id
         and aml.underlying_product_id = pdm.product_id(+)
         and aml.attribute_id = cipde.element_id
         and pci.pcdb_id = pcdb.pcdb_id
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and gmr.status_id = gsm.status_id(+)
         and pcpd.strategy_id = css.strategy_id
         and pcpd.product_id = pdm_conc.product_id
         and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
         and md.base_price_unit_id_in_pum = pum_loc_base.price_unit_id
         and md.base_price_unit_id_in_pum = pum_base_price_id.price_unit_id
         and md.tc_price_unit_id = tc_ppu_pum.product_price_unit_id
         and md.rc_price_unit_id = rc_ppu_pum.product_price_unit_id
         and gmr.internal_gmr_ref_no = gmr_qty.internal_gmr_ref_no
         and grd.internal_grd_ref_no = gmr_qty.internal_grd_ref_no
         and cipde.element_id = gmr_qty.element_id
         and gmr_qty.qty_unit_id = gmr_qum.qty_unit_id
         and grd.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and ciqs.process_id = pc_process_id
         and cipde.process_id = pc_process_id
         and pcdb.process_id = pc_process_id
         and pcm.purchase_sales = 'P'
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'CONCENTRATES'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pcpd.is_active = 'Y'
         and ppm.is_active = 'Y'
         and ppm.is_deleted = 'N'
         and qav.is_deleted = 'N'
         and qav.is_comp_product_attribute = 'Y'
         and qat.is_active = 'Y'
         and qat.is_deleted = 'N'
         and aml.is_active = 'Y'
         and aml.is_deleted = 'N'
         and qat_und.is_active = 'Y'
         and qat_und.is_deleted = 'N'
         and gmr.corporate_id = pc_corporate_id
         and grd.status = 'Active'
         and grd.is_deleted = 'N'
         and gmr.is_deleted = 'N'
         and nvl(grd.inventory_status, 'NA') <> 'Out'
         and pcm.purchase_sales = 'P'
         and nvl(grd.current_qty, 0) > 0
         and gmr.is_internal_movement = 'N'
      union all
      select 'Sales' section_type,
             pcpd.profit_center_id profit_center,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             pc_process_id process_id,
             gmr.corporate_id,
             akc.corporate_name,
             gmr.internal_gmr_ref_no,
             dgrd.internal_contract_item_ref_no,
             pci.del_distribution_item_no,
             pcdi.delivery_item_no,
             pcm.contract_ref_no,
             pcm.purchase_sales,
             dgrd.product_id conc_product_id,
             aml.underlying_product_id product_id,
             pdm.product_desc product_name,
             dgrd.origin_id,
             orm.origin_name,
             pcpq.quality_template_id conc_quality_id,
             qav.comp_quality_id quality_id,
             qat_und.quality_name,
             '' container_no,
             dgrd.net_weight stock_qty,
             dgrd.net_weight_unit_id qty_unit_id,
             gmr.qty_unit_id gmr_qty_unit_id,
             qum.qty_unit,
             qum.decimals stocky_qty_decimal,
             gmr.current_no_of_units no_of_units,
             md.md_id,
             md.m2m_price_unit_id,
             md.net_m2m_price,
             md.m2m_price_unit_cur_id,
             md.m2m_price_unit_cur_code,
             md.m2m_price_unit_weight_unit_id,
             md.m2m_price_unit_weight_unit,
             nvl(md.m2m_price_unit_weight, 1) m2m_price_unit_weight,
             md.m2m_price_unit_cur_code || '/' ||
             decode(md.m2m_price_unit_weight,
                    1,
                    null,
                    md.m2m_price_unit_weight) ||
             md.m2m_price_unit_weight_unit m2m_price_unit_str,
             md.m2m_main_cur_id,
             md.m2m_main_cur_code,
             md.m2m_main_cur_decimals,
             md.main_currency_factor,
             md.settlement_cur_id,
             md.settlement_to_val_fx_rate,
             cipde.element_id,
             aml.attribute_name,
             pcpq.assay_header_id,
             cipde.assay_qty,
             cipde.assay_qty_unit_id,
             --  cipde.payable_qty,
             -- cipde.payable_qty_unit_id,
             gmr_qty.payable_qty,
             gmr_qty.qty_unit_id payable_qty_unit_id,
             gmr_qum.qty_unit payable_qty_unit,
             cipde.contract_price,
             cipde.price_unit_id,
             cipde.price_unit_weight_unit_id,
             cipde.price_unit_weight,
             cipde.price_unit_cur_id,
             cipde.price_unit_cur_code,
             cipde.price_unit_weight_unit,
             cipde.price_fixation_details,
             cipde.price_description,
             nvl(cipde.payment_due_date, pd_trade_date) payment_due_date,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
             cm.decimals as base_cur_decimal,
             gmr.inventory_status,
             gsm.status shipment_status,
             (case
               when nvl(dgrd.inventory_status, 'NA') = 'Under CMA' then
                'UnderCMA NTT'
               when nvl(dgrd.is_afloat, 'N') = 'Y' and
                    nvl(dgrd.inventory_status, 'NA') in ('In', 'None', 'NA') then
                'Shipped NTT'
               when nvl(dgrd.is_afloat, 'N') = 'Y' and
                    nvl(dgrd.inventory_status, 'NA') = 'Out' then
                'Shipped TT'
               when nvl(dgrd.is_afloat, 'N') = 'N' and
                    nvl(dgrd.inventory_status, 'NA') in ('In', 'None', 'NA') then
                'Stock NTT'
               when nvl(dgrd.is_afloat, 'N') = 'N' and
                    nvl(dgrd.inventory_status, 'NA') = 'Out' then
                'Stock TT'
               else
                'Others'
             end) section_name,
             cipde.price_basis,
             gmr.shed_id,
             gmr.destination_city_id,
             cipde.price_fixation_status price_fixation_status,
             pdm.base_quantity_unit base_qty_unit_id,
             qum_pdm_conc.qty_unit_id as conc_base_qty_unit_id,
             qum_pdm_conc.decimals as base_qty_decimal,
             pcpd.strategy_id,
             css.strategy_name,
             md.valuation_exchange_id,
             md.valuation_month,
             md.derivative_def_id,
             nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
             gmr.contract_type gmr_contract_type,
             agh.int_alloc_group_id,
             dgrd.internal_dgrd_ref_no internal_grd_dgrd_ref_no,
             dgrd.internal_stock_ref_no stock_ref_no,
             pcm.trader_id,
             (case
               when pcm.trader_id is not null then
                (select gab.firstname || ' ' || gab.lastname
                   from gab_globaladdressbook gab,
                        ak_corporate_user     aku
                  where gab.gabid = aku.gabid
                    and aku.user_id = pcm.trader_id)
               else
                ''
             end) trader_user_name,
             md.m2m_loc_incoterm_deviation,
             md.treatment_charge m2m_treatment_charge,
             md.refine_charge m2m_refine_charge,
             tc_ppu_pum.price_unit_id m2m_tc_price_unit_id,
             tc_ppu_pum.price_unit_name m2m_tc_price_unit_name,
             tc_ppu_pum.cur_id m2m_tc_cur_id,
             tc_ppu_pum.weight m2m_tc_weight,
             tc_ppu_pum.weight_unit_id m2m_tc_weight_unit_id,
             rc_ppu_pum.price_unit_id m2m_rc_price_unit_id,
             rc_ppu_pum.price_unit_name m2m_rc_price_unit_name,
             rc_ppu_pum.cur_id m2m_rc_cur_id,
             rc_ppu_pum.weight m2m_rc_weight,
             rc_ppu_pum.weight_unit_id m2m_rc_weight_unit_id,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             gpd.contract_price gmr_price,
             gpd.price_unit_id gmr_price_unit_id,
             gpd.price_unit_weight_unit_id gmr_price_wt_unit_id,
             gpd.price_unit_weight gmr_price_wt,
             gpd.price_unit_cur_id gmr_price_cur_id,
             gpd.price_unit_cur_code gmr_price_cur_code,
             gpd.price_unit_weight_unit gmr_price_wt_unit,
             gpd.price_fixation_status gmr_price_fixation_status,
             qat.eval_basis,
             dense_rank() over(partition by pci.internal_contract_item_ref_no order by cipde.element_id) ele_rank,
             pcpq.unit_of_measure,
             pum_loc_base.weight_unit_id loc_qty_unit_id,
             tmpc.mvp_id,
             tmpc.shipment_month,
             tmpc.shipment_year,
             pum_base_price_id.price_unit_name base_price_unit_name,
             nvl(pdm_conc.valuation_against_underlying, 'Y') valuation_against_underlying
        from gmr_goods_movement_record gmr,
             gpd_gmr_conc_price_daily gpd,
             dgrd_delivered_grd dgrd,
             agh_alloc_group_header agh,
             pcm_physical_contract_main pcm,
             pcpd_pc_product_definition pcpd,
             cpc_corporate_profit_center cpc,
             pdm_productmaster pdm,
             orm_origin_master orm,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'CONCENTRATES'
                 and tmp.section_name <> 'OPEN') tmpc,
             qat_quality_attributes qat,
             qum_quantity_unit_master qum,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type <> 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'CONCENTRATES'
                 and md1.process_id = pc_process_id) md,
             cipde_cipd_element_price cipde,
             pcdi_pc_delivery_item pcdi,
             pci_physical_contract_item pci,
             pcpq_pc_product_quality pcpq,
             qav_quality_attribute_values qav,
             ppm_product_properties_mapping ppm,
             qat_quality_attributes qat_und,
             aml_attribute_master_list aml,
             ciqs_contract_item_qty_status ciqs,
             ak_corporate akc,
             cm_currency_master cm,
             gsm_gmr_stauts_master gsm,
             css_corporate_strategy_setup css,
             pcdb_pc_delivery_basis pcdb,
             pdm_productmaster pdm_conc,
             qum_quantity_unit_master qum_pdm_conc,
             pum_price_unit_master pum_loc_base,
             pum_price_unit_master pum_base_price_id,
             v_gmr_stockpayable_qty gmr_qty,
             qum_quantity_unit_master gmr_qum,
             v_ppu_pum tc_ppu_pum,
             v_ppu_pum rc_ppu_pum
       where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
            -- and gmr.internal_gmr_ref_no = 'GMR-129'
         and dgrd.int_alloc_group_id = agh.int_alloc_group_id
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.process_id = gpd.process_id(+)
         and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.profit_center_id = cpc.profit_center_id
         and dgrd.origin_id = orm.origin_id(+)
         and dgrd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
            --and dgrd.internal_grd_ref_no = tmpc.internal_grd_ref_no(+)
         and dgrd.internal_contract_item_ref_no =
             tmpc.internal_contract_item_ref_no(+)
         and tmpc.conc_quality_id = qat.quality_id
         and dgrd.net_weight_unit_id = qum.qty_unit_id(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and tmpc.element_id = cipde.element_id
         and md.element_id = cipde.element_id
         and dgrd.internal_contract_item_ref_no =
             cipde.internal_contract_item_ref_no
         and dgrd.internal_contract_item_ref_no =
             cipde.internal_contract_item_ref_no
            --and dgrd.process_id = cipde.process_id --commented by ashok 
         and cipde.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = pci.pcdi_id
         and pci.internal_contract_item_ref_no =
             cipde.internal_contract_item_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and qat.quality_id = qav.quality_id
         and qav.attribute_id = ppm.property_id
         and qav.comp_quality_id = qat_und.quality_id
         and pcpq.quality_template_id = qat.quality_id
         and ppm.attribute_id = aml.attribute_id(+)
         and aml.underlying_product_id = pdm.product_id(+)
         and aml.attribute_id = cipde.element_id
         and pcpq.quality_template_id = qat.quality_id(+)
         and pci.internal_contract_item_ref_no =
             ciqs.internal_contract_item_ref_no
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and cm.cur_code = akc.base_currency_name
         and gmr.status_id = gsm.status_id(+)
         and pcpd.strategy_id = css.strategy_id
         and pci.pcdb_id = pcdb.pcdb_id
         and pcpd.product_id = pdm_conc.product_id
         and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
         and md.base_price_unit_id_in_pum = pum_loc_base.price_unit_id
         and md.base_price_unit_id_in_pum = pum_base_price_id.price_unit_id
         and md.tc_price_unit_id = tc_ppu_pum.product_price_unit_id
         and md.rc_price_unit_id = rc_ppu_pum.product_price_unit_id
         and gmr.internal_gmr_ref_no = gmr_qty.internal_gmr_ref_no
         and dgrd.internal_dgrd_ref_no = gmr_qty.internal_dgrd_ref_no
         and cipde.element_id = gmr_qty.element_id
         and gmr_qty.qty_unit_id = gmr_qum.qty_unit_id
         and pcm.purchase_sales = 'S'
         and gsm.is_required_for_m2m = 'Y'
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'CONCENTRATES'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pcdb.is_active = 'Y'
         and gmr.is_deleted = 'N'
         and ppm.is_active = 'Y'
         and ppm.is_deleted = 'N'
         and qav.is_deleted = 'N'
         and qav.is_comp_product_attribute = 'Y'
         and qat.is_active = 'Y'
         and qat.is_deleted = 'N'
         and aml.is_active = 'Y'
         and aml.is_deleted = 'N'
         and qat_und.is_active = 'Y'
         and qat_und.is_deleted = 'N'
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and dgrd.process_id = pc_process_id
         and agh.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and cipde.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and ciqs.process_id = pc_process_id
         and pcdb.process_id = pc_process_id
         and upper(dgrd.realized_status) in
             ('UNREALIZED', 'UNDERCMA', 'REVERSEREALIZED', 'REVERSEUNDERCMA')
         and dgrd.status = 'Active'
         and nvl(dgrd.net_weight, 0) > 0
         and agh.is_deleted = 'N'
         and gmr.corporate_id = pc_corporate_id
         and gmr.is_internal_movement = 'N';
  
    vn_cont_price                  number;
    vc_cont_price_unit_id          varchar2(15);
    vc_cont_price_unit_cur_id      varchar2(15);
    vc_cont_price_unit_cur_code    varchar2(15);
    vn_cont_price_wt               number;
    vc_cont_price_wt_unit_id       varchar2(15);
    vc_cont_price_wt_unit          varchar2(15);
    vc_price_fixation_status       varchar2(50);
    vc_psu_id                      varchar2(500);
    vn_qty_in_base                 number;
    vn_ele_qty_in_base             number;
    vn_m2m_amt                     number;
    vc_m2m_price_unit_cur_id       varchar2(15);
    vc_m2m_cur_id                  varchar2(15);
    vc_m2m_cur_code                varchar2(15);
    vn_m2m_sub_cur_id_factor       number;
    vn_m2m_cur_decimals            number;
    vn_m2m_base_fx_rate            number;
    vn_m2m_base_deviation          number;
    vn_ele_m2m_amount_in_base      number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_m2m_total_premium_amt       number;
    vn_ele_m2m_total_amount        number;
    vn_ele_m2m_amt_per_unit        number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_contract_value_in_price_cur number;
    vn_cont_price_cur_decimals     number;
    vn_fx_price_to_base            number;
    vn_fx_price_deviation          number;
    vn_contract_value_in_val_cur   number;
    vn_contract_value_in_base_cur  number;
    vn_ele_m2m_treatment_charge    number;
    vn_dry_qty                     number;
    vn_wet_qty                     number;
    vn_dry_qty_in_base             number;
    vn_ele_m2m_refine_charge       number;
    vn_loc_amount                  number;
    vn_loc_total_amount            number;
    vn_total_penality              number;
    vn_penality                    number;
    vc_penality_price_unit_id      varchar2(15);
  begin
  
    for cur_grd_rows in cur_grd
    loop
      vn_cont_price               := 0;
      vc_cont_price_unit_id       := null;
      vc_cont_price_unit_cur_id   := null;
      vc_cont_price_unit_cur_code := null;
      vn_cont_price_wt            := 1;
      vc_cont_price_wt_unit_id    := null;
      vc_cont_price_wt_unit       := null;
      vc_price_fixation_status    := null;
    
      if cur_grd_rows.gmr_price is null then
        vn_cont_price               := cur_grd_rows.contract_price;
        vc_cont_price_unit_id       := cur_grd_rows.price_unit_id;
        vc_cont_price_unit_cur_id   := cur_grd_rows.price_unit_cur_id;
        vc_cont_price_unit_cur_code := cur_grd_rows.price_unit_cur_code;
        vn_cont_price_wt            := cur_grd_rows.price_unit_weight;
        vc_cont_price_wt_unit_id    := cur_grd_rows.price_unit_weight_unit_id;
        vc_cont_price_wt_unit       := cur_grd_rows.price_unit_weight_unit;
        vc_price_fixation_status    := cur_grd_rows.price_fixation_status;
      
      else
        vn_cont_price               := cur_grd_rows.gmr_price;
        vc_cont_price_unit_id       := cur_grd_rows.gmr_price_unit_id;
        vc_cont_price_unit_cur_id   := cur_grd_rows.gmr_price_cur_id;
        vc_cont_price_unit_cur_code := cur_grd_rows.gmr_price_cur_code;
        vn_cont_price_wt            := cur_grd_rows.gmr_price_wt;
        vc_cont_price_wt_unit_id    := cur_grd_rows.gmr_price_wt_unit_id;
        vc_cont_price_wt_unit       := cur_grd_rows.gmr_price_wt_unit;
        vc_price_fixation_status    := cur_grd_rows.gmr_price_fixation_status;
      end if;
    
      if cur_grd_rows.stock_qty <> 0 then
        vc_psu_id := cur_grd_rows.internal_gmr_ref_no || '-' ||
                     cur_grd_rows.internal_grd_dgrd_ref_no || '-' ||
                     cur_grd_rows.internal_contract_item_ref_no || '-' ||
                     cur_grd_rows.container_no;
      
        if cur_grd_rows.unit_of_measure = 'Wet' then
          vn_dry_qty := round(pkg_metals_general.fn_get_assay_dry_qty(cur_grd_rows.conc_product_id,
                                                                      cur_grd_rows.assay_header_id,
                                                                      cur_grd_rows.stock_qty,
                                                                      cur_grd_rows.qty_unit_id),
                              cur_grd_rows.stocky_qty_decimal);
        else
          vn_dry_qty := cur_grd_rows.stock_qty;
        end if;
      
        vn_wet_qty := cur_grd_rows.stock_qty;
      
        -- convert into dry qty to base qty element level
      
        vn_dry_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                         cur_grd_rows.qty_unit_id,
                                                                         cur_grd_rows.base_qty_unit_id,
                                                                         1) *
                                    vn_dry_qty,
                                    cur_grd_rows.base_qty_decimal);
      
        vn_qty_in_base := round(cur_grd_rows.stock_qty *
                                pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                     cur_grd_rows.qty_unit_id,
                                                                     cur_grd_rows.conc_base_qty_unit_id,
                                                                     1),
                                cur_grd_rows.base_qty_decimal);
      
        vn_ele_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                         cur_grd_rows.payable_qty_unit_id,
                                                                         cur_grd_rows.base_qty_unit_id,
                                                                         1) *
                                    cur_grd_rows.payable_qty,
                                    cur_grd_rows.base_qty_decimal);
        if cur_grd_rows.valuation_against_underlying = 'Y' then
          if cur_grd_rows.eval_basis = 'FIXED' then
            vn_m2m_amt               := 0;
            vc_m2m_price_unit_cur_id := cur_grd_rows.base_cur_id;
          else
            vc_m2m_price_unit_cur_id := nvl(cur_grd_rows.m2m_price_unit_cur_id,
                                            cur_grd_rows.base_cur_id);
            vn_m2m_amt               := nvl(cur_grd_rows.net_m2m_price, 0) /
                                        nvl(cur_grd_rows.m2m_price_unit_weight,
                                            1) *
                                        pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                             cur_grd_rows.payable_qty_unit_id,
                                                                             cur_grd_rows.m2m_price_unit_weight_unit_id,
                                                                             cur_grd_rows.payable_qty);
          end if;
        
          pkg_general.sp_get_main_cur_detail(nvl(vc_m2m_price_unit_cur_id,
                                                 cur_grd_rows.base_cur_id),
                                             vc_m2m_cur_id,
                                             vc_m2m_cur_code,
                                             vn_m2m_sub_cur_id_factor,
                                             vn_m2m_cur_decimals);
        
          vn_m2m_amt := round(vn_m2m_amt * vn_m2m_sub_cur_id_factor,
                              cur_grd_rows.base_cur_decimal);
        
          pkg_general.sp_forward_cur_exchange_new(cur_grd_rows.corporate_id,
                                                  pd_trade_date,
                                                  cur_grd_rows.payment_due_date,
                                                  nvl(vc_m2m_cur_id,
                                                      cur_grd_rows.base_cur_id),
                                                  cur_grd_rows.base_cur_id,
                                                  30,
                                                  vn_m2m_base_fx_rate,
                                                  vn_m2m_base_deviation);
        
          if vc_m2m_cur_id <> cur_grd_rows.base_cur_id then
            if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
                                                                   'PHY-005',
                                                                   cur_grd_rows.base_cur_code ||
                                                                   ' to ' ||
                                                                   vc_m2m_cur_code,
                                                                   '',
                                                                   gvc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            
            end if;
          end if;
        
          vn_ele_m2m_amount_in_base := vn_m2m_amt * vn_m2m_base_fx_rate;
        else
          --if valuation against underly is no, then use total concentrate qty and market price to calculate the
          --market value for the gmr level.
          if cur_grd_rows.eval_basis = 'FIXED' then
            vn_m2m_amt               := 0;
            vc_m2m_price_unit_cur_id := cur_grd_rows.base_cur_id;
          else
            vc_m2m_price_unit_cur_id := nvl(cur_grd_rows.m2m_price_unit_cur_id,
                                            cur_grd_rows.base_cur_id);
            vn_m2m_amt               := nvl(cur_grd_rows.net_m2m_price, 0) /
                                        nvl(cur_grd_rows.m2m_price_unit_weight,
                                            1) *
                                        pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                             cur_grd_rows.conc_base_qty_unit_id,
                                                                             cur_grd_rows.m2m_price_unit_weight_unit_id,
                                                                             vn_dry_qty_in_base);
          end if;
        
          pkg_general.sp_get_main_cur_detail(nvl(vc_m2m_price_unit_cur_id,
                                                 cur_grd_rows.base_cur_id),
                                             vc_m2m_cur_id,
                                             vc_m2m_cur_code,
                                             vn_m2m_sub_cur_id_factor,
                                             vn_m2m_cur_decimals);
        
          vn_m2m_amt := round(vn_m2m_amt * vn_m2m_sub_cur_id_factor,
                              cur_grd_rows.base_cur_decimal);
        
          pkg_general.sp_forward_cur_exchange_new(cur_grd_rows.corporate_id,
                                                  pd_trade_date,
                                                  cur_grd_rows.payment_due_date,
                                                  nvl(vc_m2m_cur_id,
                                                      cur_grd_rows.base_cur_id),
                                                  cur_grd_rows.base_cur_id,
                                                  30,
                                                  vn_m2m_base_fx_rate,
                                                  vn_m2m_base_deviation);
        
          if vc_m2m_cur_id <> cur_grd_rows.base_cur_id then
            if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
                                                                   'PHY-005',
                                                                   cur_grd_rows.base_cur_code ||
                                                                   ' to ' ||
                                                                   vc_m2m_cur_code,
                                                                   '',
                                                                   gvc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            
            end if;
          end if;
          if cur_grd_rows.ele_rank = 1 then
            vn_ele_m2m_amount_in_base := vn_m2m_amt * vn_m2m_base_fx_rate;
          else
            vn_ele_m2m_amount_in_base := 0;
            vn_m2m_amt                := 0;
          end if;
        
        end if;
      /*  vn_ele_m2m_treatment_charge := round(cur_grd_rows.m2m_treatment_charge *
                                             vn_dry_qty_in_base,
                                             cur_grd_rows.base_cur_decimal);
        vn_ele_m2m_refine_charge    := round(cur_grd_rows.m2m_refine_charge *
                                             vn_ele_qty_in_base,
                                             cur_grd_rows.base_cur_decimal);*/
                                             
        vn_ele_m2m_treatment_charge :=round((cur_grd_rows.m2m_treatment_charge /
                                     nvl(cur_grd_rows.m2m_tc_weight,
                                          1)) *
                                     pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                              cur_grd_rows.m2m_tc_cur_id,
                                                                              cur_grd_rows.base_cur_id,
                                                                              pd_trade_date,
                                                                              1) *
                                     (pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                           cur_grd_rows.qty_unit_id,
                                                                           cur_grd_rows.m2m_tc_weight_unit_id,
                                                                           vn_dry_qty)),cur_grd_rows.base_cur_decimal);
    
      vn_ele_m2m_refine_charge :=round((cur_grd_rows.m2m_refine_charge /
                                  nvl(cur_grd_rows.m2m_rc_weight, 1)) *
                                  pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                           cur_grd_rows.m2m_rc_cur_id,
                                                                           cur_grd_rows.base_cur_id,
                                                                           pd_trade_date,
                                                                           1) *
                                  (pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,                                                                        
                                                                        cur_grd_rows.payable_qty_unit_id,
                                                                        cur_grd_rows.m2m_rc_weight_unit_id,
                                                                        cur_grd_rows.payable_qty)),cur_grd_rows.base_cur_decimal);                                     
                                             
                                             
        if cur_grd_rows.ele_rank = 1 then
          vn_loc_amount := round(pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                      cur_grd_rows.loc_qty_unit_id,
                                                                      cur_grd_rows.conc_base_qty_unit_id,
                                                                      1) *
                                 cur_grd_rows.m2m_loc_incoterm_deviation,
                                 cur_grd_rows.base_cur_decimal);
        
          vn_loc_total_amount := round(vn_loc_amount * vn_qty_in_base,
                                       cur_grd_rows.base_cur_decimal);
        end if;
        vn_total_penality := 0;
        if cur_grd_rows.ele_rank = 1 then
          vn_total_penality := 0;
          for cc in (select pci.internal_contract_item_ref_no,
                            pqca.element_id,
                            pcpq.quality_template_id
                       from pci_physical_contract_item  pci,
                            pcpq_pc_product_quality     pcpq,
                            ash_assay_header            ash,
                            asm_assay_sublot_mapping    asm,
                            pqca_pq_chemical_attributes pqca
                      where pci.pcpq_id = pcpq.pcpq_id
                        and pcpq.assay_header_id = ash.ash_id
                        and ash.ash_id = asm.ash_id
                        and asm.asm_id = pqca.asm_id
                        and pci.process_id = pc_process_id
                        and pcpq.process_id = pc_process_id
                        and pci.is_active = 'Y'
                        and pcpq.is_active = 'Y'
                        and ash.is_active = 'Y'
                        and asm.is_active = 'Y'
                        and pqca.is_active = 'Y'
                        and pqca.is_elem_for_pricing = 'N'
                        and pqca.is_deductible = 'N'
                        and pci.internal_contract_item_ref_no =
                            cur_grd_rows.internal_contract_item_ref_no)
          loop
          
            pkg_phy_pre_check_process.sp_calc_m2m_tc_pc_rc_charge(cur_grd_rows.corporate_id,
                                                                  pd_trade_date,
                                                                  cur_grd_rows.conc_product_id,
                                                                  cur_grd_rows.conc_quality_id,
                                                                  cur_grd_rows.mvp_id,
                                                                  'Penalties',
                                                                  cc.element_id,
                                                                  cur_grd_rows.shipment_month,
                                                                  cur_grd_rows.shipment_year,
                                                                  vn_penality,
                                                                  vc_penality_price_unit_id);
            if nvl(vn_penality, 0) <> 0 then
              vn_total_penality := round(vn_total_penality +
                                         (vn_penality * vn_dry_qty_in_base),
                                         cur_grd_rows.base_cur_decimal);
            end if;
          
          end loop;
        
        end if;
      
        vn_ele_m2m_total_amount := vn_ele_m2m_amount_in_base -
                                   vn_ele_m2m_treatment_charge -
                                   vn_ele_m2m_refine_charge;
      
        vn_ele_m2m_amt_per_unit := round(vn_ele_m2m_total_amount /
                                         vn_ele_qty_in_base,
                                         cur_grd_rows.base_cur_decimal);
      
        pkg_general.sp_get_main_cur_detail(nvl(vc_cont_price_unit_cur_id,
                                               cur_grd_rows.base_cur_id),
                                           vc_price_cur_id,
                                           vc_price_cur_code,
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
      
        if nvl(vn_cont_price, 0) <> 0 and
           vc_cont_price_wt_unit_id is not null then
        
          vn_contract_value_in_price_cur := (vn_cont_price /
                                            nvl(vn_cont_price_wt, 1)) *
                                            (pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                                  cur_grd_rows.qty_unit_id,
                                                                                  vc_cont_price_wt_unit_id,
                                                                                  cur_grd_rows.stock_qty)) *
                                            vn_cont_price_cur_id_factor;
        else
          vn_contract_value_in_price_cur := 0;
        end if;
      
        pkg_general.sp_forward_cur_exchange_new(cur_grd_rows.corporate_id,
                                                pd_trade_date,
                                                cur_grd_rows.payment_due_date,
                                                vc_price_cur_id,
                                                cur_grd_rows.base_cur_id,
                                                30,
                                                vn_fx_price_to_base,
                                                vn_fx_price_deviation);
      
        vn_contract_value_in_price_cur := round(vn_contract_value_in_price_cur,
                                                vn_cont_price_cur_decimals);
      
        vn_contract_value_in_val_cur  := round((vn_contract_value_in_price_cur *
                                               nvl(vn_fx_price_to_base, 1)),
                                               cur_grd_rows.base_cur_decimal);
        vn_contract_value_in_base_cur := vn_contract_value_in_val_cur;
      end if;
    
      insert into psue_element_details
        (corporate_id,
         process_id,
         internal_contract_item_ref_no,
         psu_id,
         internal_gmr_ref_no,
         element_id,
         element_name,
         assay_header_id,
         assay_qty,
         assay_qty_unit_id,
         payable_qty,
         payable_qty_unit_id,
         payable_qty_unit,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight,
         price_unit_weight_unit,
         md_id,
         m2m_price,
         m2m_price_cur_id,
         m2m_price_cur_code,
         m2m_price_weight_unit_id,
         m2m_price_weight_unit,
         m2m_price_weight_unit_weight,
         m2m_refining_charge,
         m2m_treatment_charge,
         pricing_details,
         m2m_price_unit_id,
         m2m_price_unit_str,
         m2m_amt,
         m2m_amt_cur_id,
         m2m_amt_cur_code,
         contract_value_in_price_cur,
         contract_price_cur_id,
         contract_price_cur_code,
         material_cost_in_base_cur,
         element_qty_in_base_unit,
         total_m2m_amount,
         m2m_amt_per_unit,
         price_cur_to_base_cur_fx_rate,
         m2m_cur_to_base_cur_fx_rate,
         base_price_unit_id_in_ppu,
         base_price_unit_id_in_pum,
         valuation_against_underlying)
      values
        (cur_grd_rows.corporate_id,
         pc_process_id,
         cur_grd_rows.internal_contract_item_ref_no,
         vc_psu_id,
         cur_grd_rows.internal_gmr_ref_no,
         cur_grd_rows.element_id,
         cur_grd_rows.attribute_name,
         cur_grd_rows.assay_header_id,
         cur_grd_rows.assay_qty,
         cur_grd_rows.assay_qty_unit_id,
         cur_grd_rows.payable_qty,
         cur_grd_rows.payable_qty_unit_id,
         cur_grd_rows.payable_qty_unit,
         vn_cont_price,
         vc_cont_price_unit_id,
         vc_cont_price_unit_cur_id,
         vc_cont_price_unit_cur_code,
         vc_cont_price_wt_unit_id,
         vn_cont_price_wt,
         vc_cont_price_wt_unit,
         cur_grd_rows.md_id,
         cur_grd_rows.net_m2m_price,
         cur_grd_rows.m2m_price_unit_cur_id,
         cur_grd_rows.m2m_price_unit_cur_code,
         cur_grd_rows.m2m_price_unit_weight_unit_id,
         cur_grd_rows.m2m_price_unit_weight_unit,
         decode(cur_grd_rows.m2m_price_unit_weight,
                1,
                null,
                cur_grd_rows.m2m_price_unit_weight),
         vn_ele_m2m_refine_charge,
         vn_ele_m2m_treatment_charge,
         cur_grd_rows.price_description,
         cur_grd_rows.m2m_price_unit_id,
         cur_grd_rows.m2m_price_unit_str,
         vn_m2m_amt, --m2m_amt
         cur_grd_rows.base_cur_id,
         cur_grd_rows.base_cur_code,
         vn_contract_value_in_price_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vn_contract_value_in_base_cur,
         vn_ele_qty_in_base,
         vn_ele_m2m_total_amount, --total_m2m_amount,
         vn_ele_m2m_amt_per_unit, --m2m_amt_per_unit,
         vn_fx_price_to_base, --price_cur_to_base_cur_fx_rate,   
         vn_m2m_base_fx_rate, --m2m_cur_to_base_cur_fx_rate,
         cur_grd_rows.base_price_unit_id_in_ppu, --base_price_unit_id_in_ppu,
         cur_grd_rows.base_price_unit_id_in_pum, --base_price_unit_id_in_pum)*/
         cur_grd_rows.valuation_against_underlying);
    
      if cur_grd_rows.ele_rank = 1 then
        insert into psue_phy_stock_unrealized_ele
          (process_id,
           psu_id,
           corporate_id,
           corporate_name,
           internal_gmr_ref_no,
           internal_contract_item_ref_no,
           contract_ref_no,
           delivery_item_no,
           del_distribution_item_no,
           product_id,
           product_name,
           origin_id,
           origin_name,
           quality_id,
           quality_name,
           container_no,
           stock_wet_qty,
           stock_dry_qty,
           qty_unit_id,
           qty_unit,
           qty_in_base_unit,
           no_of_units,
           prod_base_qty_unit_id,
           prod_base_qty_unit,
           inventory_status,
           shipment_status,
           section_name,
           strategy_id,
           strategy_name,
           valuation_month,
           contract_type,
           profit_center_id,
           profit_center_name,
           profit_center_short_name,
           valuation_exchange_id,
           derivative_def_id,
           gmr_contract_type,
           is_voyage_gmr,
           gmr_ref_no,
           warehouse_id,
           warehouse_name,
           shed_id,
           shed_name,
           int_alloc_group_id,
           internal_grd_dgrd_ref_no,
           price_type_id,
           fixation_method,
           price_fixation_details,
           stock_ref_no,
           trader_name,
           trader_id,
           contract_qty_string,
           contract_price_string,
           m2m_price_string,
           m2m_rc_tc_string,
           m2m_penalty_charge,
           m2m_treatment_charge,
           m2m_refining_charge,
           m2m_loc_diff_premium,
           net_contract_value_in_base_cur,
           net_m2m_amount_in_base_cur,
           prev_net_m2m_amt_in_base_cur,
           pnl_type,
           pnl_in_base_cur,
           pnl_in_per_base_unit,
           prev_day_pnl_in_base_cur,
           prev_day_pnl_per_base_unit,
           trade_day_pnl_in_base_cur,
           trade_day_pnl_per_base_unit,
           cont_unr_status,
           prev_m2m_price_string,
           prev_m2m_rc_tc_string,
           prev_m2m_penalty_charge,
           prev_m2m_treatment_charge,
           prev_m2m_refining_charge,
           prev_m2m_loc_diff_premium,
           base_price_unit_id,
           base_price_unit_name,
           base_cur_id,
           base_cur_code,
           valuation_against_underlying)
        values
          (pc_process_id,
           vc_psu_id,
           cur_grd_rows.corporate_id,
           cur_grd_rows.corporate_name,
           cur_grd_rows.internal_gmr_ref_no,
           cur_grd_rows.internal_contract_item_ref_no,
           cur_grd_rows.contract_ref_no,
           cur_grd_rows.delivery_item_no,
           cur_grd_rows.del_distribution_item_no,
           cur_grd_rows.conc_product_id,
           cur_grd_rows.product_name,
           cur_grd_rows.origin_id,
           cur_grd_rows.origin_name,
           cur_grd_rows.conc_quality_id,
           cur_grd_rows.quality_name,
           cur_grd_rows.container_no,
           vn_wet_qty,
           vn_dry_qty,
           cur_grd_rows.qty_unit_id,
           cur_grd_rows.qty_unit,
           vn_qty_in_base,
           cur_grd_rows.no_of_units,
           null, --prod_base_qty_unit_id
           null, --prod_base_qty_unit
           cur_grd_rows.inventory_status,
           cur_grd_rows.shipment_status,
           cur_grd_rows.section_name,
           cur_grd_rows.strategy_id,
           cur_grd_rows.strategy_name,
           cur_grd_rows.valuation_month,
           cur_grd_rows.purchase_sales,
           cur_grd_rows.profit_center,
           cur_grd_rows.profit_center_name,
           cur_grd_rows.profit_center_short_name,
           cur_grd_rows.valuation_exchange_id,
           cur_grd_rows.derivative_def_id,
           cur_grd_rows.gmr_contract_type,
           cur_grd_rows.is_voyage_gmr,
           null, --gmr_ref_no
           null, --warehouse_id,
           null, --warehouse_name,
           null, --shed_id,
           null, --shed_name
           cur_grd_rows.int_alloc_group_id,
           cur_grd_rows.internal_grd_dgrd_ref_no,
           cur_grd_rows.price_basis,
           vc_price_fixation_status,
           cur_grd_rows.price_fixation_details,
           cur_grd_rows.stock_ref_no,
           cur_grd_rows.trader_user_name,
           cur_grd_rows.trader_id,
           null, --contract_qty_string,
           null, --contract_price_string,  
           null, --m2m_price_string,   
           null, --m2m_rc_tc_string,
           vn_total_penality, --m2m_penalty_charge,
           null, --m2m_treatment_charge,
           null, --m2m_refining_charge,
           vn_loc_total_amount, --m2m_loc_diff_premium,
           null, --net_contract_value_in_base_cur, 
           null, --net_m2m_amount_in_base_cur,
           null, --prev_net_m2m_amt_in_base_cur,
           'Unrealized',
           null, --pnl_in_base_cur,
           null, --pnl_in_per_base_unit,
           null, --prev_day_pnl_in_base_cur,
           null, --prev_day_pnl_per_base_unit,
           null, --trade_day_pnl_in_base_cur,
           null, --trade_day_pnl_per_base_unit,
           null, --cont_unr_status,
           null, --prev_m2m_price_string,    
           null, --prev_m2m_rc_tc_string,
           null, --prev_m2m_penalty_charge, 
           null, --prev_m2m_treatment_charge, 
           null, --prev_m2m_refining_charge, 
           null, --prev_m2m_loc_diff_premium,
           cur_grd_rows.base_price_unit_id_in_ppu,
           cur_grd_rows.base_price_unit_name,
           cur_grd_rows.base_cur_id,
           cur_grd_rows.base_cur_code,
           cur_grd_rows.valuation_against_underlying);
      end if;
    end loop;
  
    for cur_update_pnl in (select psue.psu_id,
                                  sum(psue.material_cost_in_base_cur) net_contract_value_in_base_cur,
                                  sum(psue.m2m_amt) net_m2m_amt,
                                  sum(psue.m2m_treatment_charge) net_m2m_treatment_charge,
                                  sum(psue.m2m_refining_charge) net_m2m_refining_charge,
                                  stragg(psue.element_name || '-' ||
                                         psue.payable_qty || ' ' ||
                                         psue.payable_qty_unit) contract_qty_string,
                                  stragg(psue.element_name || '-' ||
                                         psue.contract_price || ' ' ||
                                         psue.price_unit_cur_code || '/' ||
                                         psue.price_unit_weight ||
                                         psue.price_unit_weight_unit) contract_price_string,
                                  (case
                                     when psue.valuation_against_underlying = 'N' then
                                      max((case
                                     when nvl(psue.m2m_price, 0) <> 0 then
                                      (psue.m2m_price || ' ' ||
                                      psue.m2m_price_cur_code || '/' ||
                                      psue.m2m_price_weight_unit_weight ||
                                      psue.m2m_price_weight_unit)
                                     else
                                      null
                                   end)) else stragg((case
                                    when nvl(psue.m2m_price,
                                             0) <> 0 then
                                     (psue.element_name || '-' ||
                                     psue.m2m_price || ' ' ||
                                     psue.m2m_price_cur_code || '/' ||
                                     psue.m2m_price_weight_unit_weight ||
                                     psue.m2m_price_weight_unit)
                                    else
                                     null
                                  end)) end) m2m_price_string, -- TODO if underly valuation = n, show the concentrate price
                                  stragg('TC:' || psue.element_name || '-' ||
                                         psue.m2m_treatment_charge || ' ' ||
                                         psue.price_unit_cur_code || ' ' ||
                                         'RC:' || psue.element_name || '-' ||
                                         psue.m2m_refining_charge || ' ' ||
                                         psue.price_unit_cur_code) m2m_rc_tc_pen_string
                             from psue_element_details psue
                            where psue.corporate_id = pc_corporate_id
                              and psue.process_id = pc_process_id
                            group by psue.psu_id,
                                     psue.valuation_against_underlying)
    loop
    
      update psue_phy_stock_unrealized_ele psuee
         set psuee.net_contract_value_in_base_cur = cur_update_pnl.
                                                    net_contract_value_in_base_cur,
             psuee.net_m2m_amount                 = cur_update_pnl.net_m2m_amt,
             psuee.m2m_treatment_charge           = cur_update_pnl.net_m2m_treatment_charge,
             psuee.m2m_refining_charge            = cur_update_pnl.net_m2m_refining_charge,
             psuee.contract_price_string          = cur_update_pnl.contract_price_string,
             psuee.m2m_price_string               = cur_update_pnl.m2m_price_string,
             psuee.m2m_rc_tc_string               = cur_update_pnl.m2m_rc_tc_pen_string,
             psuee.contract_qty_string            = cur_update_pnl.contract_qty_string
       where psuee.psu_id = cur_update_pnl.psu_id
         and psuee.process_id = pc_process_id
         and psuee.corporate_id = pc_corporate_id;
    end loop;
  
    update psue_phy_stock_unrealized_ele psuee
       set psuee.net_m2m_amount_in_base_cur = (psuee.net_m2m_amount -
                                              psuee.m2m_treatment_charge -
                                              psuee.m2m_refining_charge -
                                              psuee.m2m_penalty_charge +
                                              psuee.m2m_loc_diff_premium)
     where psuee.corporate_id = pc_corporate_id
       and psuee.process_id = pc_process_id;
  
    --- previous EOD Data
    for cur_update in (select psue_prev_day.net_m2m_amount_in_base_cur,
                              psue_prev_day.net_m2m_amount,
                              psue_prev_day.pnl_in_per_base_unit,
                              psue_prev_day.m2m_price_string,
                              psue_prev_day.m2m_rc_tc_string,
                              psue_prev_day.m2m_penalty_charge,
                              psue_prev_day.m2m_treatment_charge,
                              psue_prev_day.m2m_refining_charge,
                              psue_prev_day.m2m_loc_diff_premium,
                              psue_prev_day.qty_in_base_unit,
                              psue_prev_day.psu_id
                         from psue_phy_stock_unrealized_ele psue_prev_day
                        where process_id = gvc_previous_process_id
                          and corporate_id = pc_corporate_id)
    loop
      update psue_phy_stock_unrealized_ele psue_today
         set psue_today.prev_net_m2m_amt_in_base_cur = cur_update.net_m2m_amount_in_base_cur,
             psue_today.prev_day_pnl_in_base_cur     = cur_update.pnl_in_per_base_unit *
                                                       psue_today.qty_in_base_unit,
             psue_today.prev_net_m2m_amount          = cur_update.net_m2m_amount,
             psue_today.prev_day_pnl_per_base_unit   = cur_update.pnl_in_per_base_unit,
             psue_today.prev_m2m_price_string        = cur_update.m2m_price_string,
             psue_today.prev_m2m_rc_tc_string        = cur_update.m2m_rc_tc_string,
             psue_today.prev_m2m_penalty_charge      = cur_update.m2m_penalty_charge,
             psue_today.prev_m2m_treatment_charge    = cur_update.m2m_treatment_charge,
             psue_today.prev_m2m_refining_charge     = cur_update.m2m_refining_charge,
             psue_today.prev_m2m_loc_diff_premium    = cur_update.m2m_loc_diff_premium,
             psue_today.cont_unr_status              = 'EXISTING_TRADE'
       where psue_today.process_id = pc_process_id
         and psue_today.corporate_id = pc_corporate_id
         and psue_today.psu_id = cur_update.psu_id;
    end loop;
  
    begin
      update psue_phy_stock_unrealized_ele psue
         set psue.prev_net_m2m_amt_in_base_cur = psue.net_m2m_amount_in_base_cur,
             psue.prev_day_pnl_in_base_cur     = 0,
             psue.prev_day_pnl_per_base_unit   = 0,
             psue.prev_net_m2m_amount          = psue.net_m2m_amount,
             psue.prev_m2m_price_string        = psue.m2m_price_string,
             psue.prev_m2m_rc_tc_string        = psue.m2m_rc_tc_string,
             psue.prev_m2m_penalty_charge      = psue.m2m_penalty_charge,
             psue.prev_m2m_treatment_charge    = psue.m2m_treatment_charge,
             psue.prev_m2m_refining_charge     = psue.m2m_refining_charge,
             psue.prev_m2m_loc_diff_premium    = psue.m2m_loc_diff_premium,
             psue.cont_unr_status              = 'NEW_TRADE'
       where psue.cont_unr_status is null
         and psue.process_id = pc_process_id
         and psue.corporate_id = pc_corporate_id;
    end;
  
    update psue_phy_stock_unrealized_ele psue
       set psue.pnl_in_base_cur      = psue.net_m2m_amount_in_base_cur -
                                       psue.prev_net_m2m_amt_in_base_cur,
           psue.pnl_in_per_base_unit = (psue.net_m2m_amount_in_base_cur -
                                       psue.prev_net_m2m_amt_in_base_cur) /
                                       psue.qty_in_base_unit
     where psue.process_id = pc_process_id
       and psue.corporate_id = pc_corporate_id;
  
    update psue_phy_stock_unrealized_ele psue
       set trade_day_pnl_in_base_cur   = nvl(psue.pnl_in_base_cur, 0) -
                                         nvl(psue.prev_day_pnl_in_base_cur,
                                             0),
           trade_day_pnl_per_base_unit = nvl(psue.pnl_in_base_cur, 0) -
                                         nvl(psue.prev_day_pnl_in_base_cur,
                                             0) / psue.qty_in_base_unit
     where psue.process_id = pc_process_id
       and psue.corporate_id = pc_corporate_id;
  
    update psue_phy_stock_unrealized_ele psue
       set (gmr_ref_no, warehouse_id, warehouse_name, shed_id, shed_name, prod_base_qty_unit_id, prod_base_qty_unit) = (select gmr.gmr_ref_no,
                                                                                                                               gmr.warehouse_profile_id,
                                                                                                                               phd_gmr.companyname as warehouse_profile_name,
                                                                                                                               gmr.shed_id,
                                                                                                                               sld.storage_location_name,
                                                                                                                               pdm.base_quantity_unit,
                                                                                                                               qum.qty_unit
                                                                                                                          from gmr_goods_movement_record   gmr,
                                                                                                                               pdm_productmaster           pdm,
                                                                                                                               phd_profileheaderdetails    phd_gmr,
                                                                                                                               sld_storage_location_detail sld,
                                                                                                                               qum_quantity_unit_master    qum
                                                                                                                         where gmr.internal_gmr_ref_no =
                                                                                                                               psue.internal_gmr_ref_no
                                                                                                                           and psue.product_id =
                                                                                                                               pdm.product_id
                                                                                                                           and pdm.base_quantity_unit =
                                                                                                                               qum.qty_unit_id
                                                                                                                           and gmr.warehouse_profile_id =
                                                                                                                               phd_gmr.profileid(+)
                                                                                                                           and gmr.shed_id =
                                                                                                                               sld.storage_loc_id(+)
                                                                                                                           and psue.process_id =
                                                                                                                               gmr.process_id
                                                                                                                           and psue.process_id =
                                                                                                                               pc_process_id)
     where psue.process_id = pc_process_id;
  
  exception
    when others then
      dbms_output.put_line('SQLERRM-1' || sqlerrm);
    
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
  
    vc_process_id      varchar2(15);
    vc_dbd_id          varchar2(15);
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
  
    dbms_output.put_line('begining of physical_process roll back procedure');
    vc_dbd_id     := pc_dbd_id;
    vc_process_id := pc_process_id;
    --dbms_output.put_line('process_id' || vc_process_id);
  
    delete from agdul_alloc_group_detail_ul where dbd_id = vc_dbd_id;
    delete from aghul_alloc_group_header_ul where dbd_id = vc_dbd_id;
    delete from cigcul_contrct_itm_gmr_cost_ul where dbd_id = vc_dbd_id;
    delete from csul_cost_store_ul where dbd_id = vc_dbd_id;
    delete from dgrdul_delivered_grd_ul where dbd_id = vc_dbd_id;
    delete from gmrul_gmr_ul where dbd_id = vc_dbd_id;
    delete from mogrdul_moved_out_grd_ul where dbd_id = vc_dbd_id;
    delete from pcadul_pc_agency_detail_ul where dbd_id = vc_dbd_id;
    delete from pcbpdul_pc_base_price_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcbphul_pc_base_prc_header_ul where dbd_id = vc_dbd_id;
    delete from pcdbul_pc_delivery_basis_ul where dbd_id = vc_dbd_id;
    delete from pcddul_document_details_ul where dbd_id = vc_dbd_id;
    delete from pcdiobul_di_optional_basis_ul where dbd_id = vc_dbd_id;
    delete from pcdipeul_di_pricing_elemnt_ul where dbd_id = vc_dbd_id;
    delete from pcdiqdul_di_quality_detail_ul where dbd_id = vc_dbd_id;
    delete from pcdiul_pc_delivery_item_ul where dbd_id = vc_dbd_id;
    delete from pcipful_pci_pricing_formula_ul where dbd_id = vc_dbd_id;
    delete from pciul_phy_contract_item_ul where dbd_id = vc_dbd_id;
    delete from pcjvul_pc_jv_detail_ul where dbd_id = vc_dbd_id;
    delete from pcmul_phy_contract_main_ul where dbd_id = vc_dbd_id;
    delete from pcpdqdul_pd_quality_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcpdul_pc_product_defintn_ul where dbd_id = vc_dbd_id;
    delete from pcpqul_pc_product_quality_ul where dbd_id = vc_dbd_id;
    delete from pcqpdul_pc_qual_prm_discnt_ul where dbd_id = vc_dbd_id;
    delete from pffxdul_phy_formula_fx_dtl_ul where dbd_id = vc_dbd_id;
    delete from pfqppul_phy_formula_qp_prc_ul where dbd_id = vc_dbd_id;
    delete from ppfdul_phy_price_frmula_dtl_ul where dbd_id = vc_dbd_id;
    delete from ppfhul_phy_price_frmla_hdr_ul where dbd_id = vc_dbd_id;
    delete from ciqsl_contract_itm_qty_sts_log where dbd_id = vc_dbd_id;
    delete from diqsl_delivery_itm_qty_sts_log where dbd_id = vc_dbd_id;
    delete from cqsl_contract_qty_status_log where dbd_id = vc_dbd_id;
    delete from grdl_goods_record_detail_log where dbd_id = vc_dbd_id;
    delete from vdul_voyage_detail_ul where dbd_id = vc_dbd_id;
    delete from pcpchul_payble_contnt_headr_ul where dbd_id = vc_dbd_id;
    delete from pqdul_payable_quality_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcepcul_elem_payble_content_ul where dbd_id = vc_dbd_id;
    delete from pcthul_treatment_header_ul where dbd_id = vc_dbd_id;
    delete from tedul_treatment_element_dtl_ul where dbd_id = vc_dbd_id;
    delete from tqdul_treatment_quality_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcetcul_elem_treatmnt_chrg_ul where dbd_id = vc_dbd_id;
    delete from pcarul_assaying_rules_ul where dbd_id = vc_dbd_id;
    delete from pcaeslul_assay_elm_splt_lmt_ul where dbd_id = vc_dbd_id;
    delete from pcaeslul_assay_elm_splt_lmt_ul where dbd_id = vc_dbd_id;
    delete from arqdul_assay_quality_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcaphul_attr_penalty_header_ul where dbd_id = vc_dbd_id;
    delete from pcapul_attribute_penalty_ul where dbd_id = vc_dbd_id;
    delete from pqdul_penalty_quality_dtl_ul where dbd_id = vc_dbd_id;
    delete from padul_penalty_attribute_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcrhul_refining_header_ul where dbd_id = vc_dbd_id;
    delete from rqdul_refining_quality_dtl_ul where dbd_id = vc_dbd_id;
    delete from redul_refining_element_dtl_ul where dbd_id = vc_dbd_id;
    delete from pcercul_elem_refing_charge_ul where dbd_id = vc_dbd_id;
  
    delete from agd_alloc_group_detail where dbd_id = vc_dbd_id;
    delete from agh_alloc_group_header where dbd_id = vc_dbd_id;
    delete from cigc_contract_item_gmr_cost where dbd_id = vc_dbd_id;
    delete from cs_cost_store where dbd_id = vc_dbd_id;
    delete from dgrd_delivered_grd where dbd_id = vc_dbd_id;
    delete from gmr_goods_movement_record where dbd_id = vc_dbd_id;
    delete from mogrd_moved_out_grd where dbd_id = vc_dbd_id;
    delete from pcad_pc_agency_detail where dbd_id = vc_dbd_id;
    delete from pcbpd_pc_base_price_detail where dbd_id = vc_dbd_id;
    delete from pcbph_pc_base_price_header where dbd_id = vc_dbd_id;
    delete from pcdb_pc_delivery_basis where dbd_id = vc_dbd_id;
    delete from pcdd_document_details where dbd_id = vc_dbd_id;
    delete from pcdiob_di_optional_basis where dbd_id = vc_dbd_id;
    delete from pcdipe_di_pricing_elements where dbd_id = vc_dbd_id;
    delete from pcdiqd_di_quality_details where dbd_id = vc_dbd_id;
    delete from pcdi_pc_delivery_item where dbd_id = vc_dbd_id;
    delete from pcipf_pci_pricing_formula where dbd_id = vc_dbd_id;
    delete from pci_physical_contract_item where dbd_id = vc_dbd_id;
    delete from pcjv_pc_jv_detail where dbd_id = vc_dbd_id;
    delete from pcm_physical_contract_main where dbd_id = vc_dbd_id;
    delete from pcpdqd_pd_quality_details where dbd_id = vc_dbd_id;
    delete from pcpd_pc_product_definition where dbd_id = vc_dbd_id;
    delete from pcpq_pc_product_quality where dbd_id = vc_dbd_id;
    delete from pcqpd_pc_qual_premium_discount where dbd_id = vc_dbd_id;
    delete from pffxd_phy_formula_fx_details where dbd_id = vc_dbd_id;
    delete from pfqpp_phy_formula_qp_pricing where dbd_id = vc_dbd_id;
    delete from ppfd_phy_price_formula_details where dbd_id = vc_dbd_id;
    delete from ppfh_phy_price_formula_header where dbd_id = vc_dbd_id;
    delete from ciqs_contract_item_qty_status where dbd_id = vc_dbd_id;
    delete from diqs_delivery_item_qty_status where dbd_id = vc_dbd_id;
    delete from cqs_contract_qty_status where dbd_id = vc_dbd_id;
    delete from grd_goods_record_detail where dbd_id = vc_dbd_id;
    delete from vd_voyage_detail where dbd_id = vc_dbd_id;
    delete from invd_inventory_detail where dbd_id = vc_dbd_id;
    delete from invm_inventory_master where dbd_id = vc_dbd_id;
    delete from cipd_contract_item_price_daily
     where process_id = pc_process_id;
    delete from poud_phy_open_unreal_daily
     where process_id = pc_process_id;
    delete from psu_phy_stock_unrealized where process_id = pc_process_id;
    delete from md_m2m_daily where process_id = pc_process_id;
    delete from gsc_gmr_sec_cost where process_id = pc_process_id;
    delete cisc_contract_item_sec_cost where process_id = pc_process_id;
    delete gpd_gmr_price_daily where process_id = pc_process_id;
    delete from pcpch_pc_payble_content_header where dbd_id = vc_dbd_id;
    delete from pqd_payable_quality_details where dbd_id = vc_dbd_id;
    delete from pcepc_pc_elem_payable_content where dbd_id = vc_dbd_id;
    delete from pcth_pc_treatment_header where dbd_id = vc_dbd_id;
    delete from ted_treatment_element_details where dbd_id = vc_dbd_id;
    delete from tqd_treatment_quality_details where dbd_id = vc_dbd_id;
    delete from pcetc_pc_elem_treatment_charge where dbd_id = vc_dbd_id;
    delete from pcar_pc_assaying_rules where dbd_id = vc_dbd_id;
    delete from pcaesl_assay_elem_split_limits where dbd_id = vc_dbd_id;
    delete from arqd_assay_quality_details where dbd_id = vc_dbd_id;
    delete from pcaph_pc_attr_penalty_header where dbd_id = vc_dbd_id;
    delete from pcap_pc_attribute_penalty where dbd_id = vc_dbd_id;
    delete from pqd_penalty_quality_details where dbd_id = vc_dbd_id;
    delete from pad_penalty_attribute_details where dbd_id = vc_dbd_id;
    delete from pcrh_pc_refining_header where dbd_id = vc_dbd_id;
    delete from rqd_refining_quality_details where dbd_id = vc_dbd_id;
    delete from red_refining_element_details where dbd_id = vc_dbd_id;
    delete from pcerc_pc_elem_refining_charge where dbd_id = vc_dbd_id;
    delete from ceqs_contract_ele_qty_status where dbd_id = vc_dbd_id;
    delete from cipde_cipd_element_price where process_id = pc_process_id;
    delete from poue_phy_open_unreal_element
     where process_id = pc_process_id;
    delete from poued_element_details where process_id = pc_process_id;
    delete from gpd_gmr_conc_price_daily where process_id = pc_process_id;
    delete from psue_element_details where process_id = pc_process_id;
    delete from psue_phy_stock_unrealized_ele
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

  procedure sp_calc_daily_trade_pnl
  --------------------------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_calc_daily_trade_pnl
    --        author                                    :
    --        created date                              : 11th Jan 2011
    --        purpose                                   : populate daily trade pnl
    --
    --        parameters
    --        pc_corporate_id                           : corporate id
    --        pd_trade_date                             : trade date
    --        pc_process_id                             : eod reference no
    --
    --        modification history
    --        modified date                             : siddharth
    --        modified by                               : exchange name and exchange id
    --        modify description                        :
    --------------------------------------------------------------------------------------------------------------------------
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_process_id   varchar2,
   pc_user_id      varchar2) is
  
  begin
    null;
  end;

  procedure sp_calc_pnl_summary(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process_id   varchar2,
                                pc_user_id      varchar2) is
  
  begin
    null;
  end;

  procedure sp_calc_overall_realized_pnl
  --------------------------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_calc_overall_realized_pnl
    --        author                                    :
    --        created date                              : 11th Jan 2011
    --        purpose                                   : popualte overall realized data
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
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_process_id   varchar2,
   pc_user_id      varchar2,
   pc_process      varchar2) is
  
  begin
    null;
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

  procedure sp_calc_risk_limits(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process_id   varchar2,
                                pc_user_id      varchar2) is
  
  begin
    null;
  end;

  procedure sp_calc_quality_premium(pc_int_contract_item_ref_no in varchar2,
                                    pc_price_unit_id            in varchar2,
                                    pc_corporate_id             in varchar2,
                                    pd_trade_date               in date,
                                    pc_product_id               in varchar2,
                                    pc_process_id               in varchar2,
                                    pn_premium                  out number) is
  
    cursor cur_preimium is
      select pcqpd.premium_disc_value,
             pcqpd.premium_disc_unit_id
        from pci_physical_contract_item     pci,
             pcpq_pc_product_quality        pcpq,
             pcpdqd_pd_quality_details      pcpdqd,
             pcqpd_pc_qual_premium_discount pcqpd
       where pci.pcpq_id = pcpq.pcpq_id
         and pcpq.pcpq_id = pcpdqd.pcpq_id
         and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
         and pci.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and pcqpd.process_id = pc_process_id
         and pcpdqd.process_id = pc_process_id
         and pci.internal_contract_item_ref_no =
             pc_int_contract_item_ref_no;
    vn_premium       number;
    vn_total_premium number := 0;
  begin
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'sp_calc_quality_premium',
                 'premium for ' || pc_int_contract_item_ref_no || ' in ' ||
                 pc_price_unit_id);
    for cur_preimium_rows in cur_preimium
    loop
      if cur_preimium_rows.premium_disc_unit_id = pc_price_unit_id then
        vn_premium := cur_preimium_rows.premium_disc_value;
      else
        vn_premium := pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                      cur_preimium_rows.premium_disc_value,
                                                                      cur_preimium_rows.premium_disc_unit_id,
                                                                      pc_price_unit_id,
                                                                      pd_trade_date);
      
      end if;
      vn_total_premium := vn_total_premium + vn_premium;
    end loop;
    pn_premium := vn_total_premium;
  
  end;

  procedure sp_calc_pofh_price(pc_pofh_id       varchar2,
                               pd_trade_date    date,
                               pn_price         out number,
                               pc_price_unit_id out varchar2) as
    cursor cur_ppfh is
      select pfd.pofh_id,
             pfd.qty_fixed,
             pfd.user_price,
             pfd.price_unit_id
        from pfd_price_fixation_details pfd
       where pfd.pofh_id = pc_pofh_id
         and pfd.as_of_date <= pd_trade_date;
  
    vn_qty_fixed     number;
    vn_user_price    number;
    vn_count         number;
    vn_avg_price     number;
    vn_price_unit_id varchar2(10);
  
  begin
  
    vn_qty_fixed  := 0;
    vn_count      := 0;
    vn_user_price := 0;
  
    for cur_ppfh_rows in cur_ppfh
    loop
      vn_qty_fixed     := vn_qty_fixed + cur_ppfh_rows.qty_fixed;
      vn_user_price    := vn_user_price +
                          cur_ppfh_rows.user_price * vn_qty_fixed;
      vn_price_unit_id := cur_ppfh_rows.price_unit_id;
    end loop;
    if vn_qty_fixed <> 0 then
      vn_avg_price     := round(vn_user_price / vn_qty_fixed, 4);
      pn_price         := vn_avg_price;
      pc_price_unit_id := vn_price_unit_id;
    end if;
  end;

end;
/
