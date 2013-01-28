create or replace package pkg_phy_eod_reports is
  gvn_log_counter number := 7000;
  procedure sp_calc_pnl_summary(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process_id   varchar2,
                                pc_process      varchar2,
                                pc_user_id      varchar2);

  procedure sp_calc_daily_trade_pnl(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_process_id   varchar2,
                                    pc_process      varchar2,
                                    pc_user_id      varchar2);

  procedure sp_phy_purchase_accural(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_process_id   varchar2);

  procedure sp_calc_overall_realized_pnl(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2);

  procedure sp_phy_intrstat(pc_corporate_id varchar2,
                            pd_trade_date   date,
                            pc_process      varchar2,
                            pc_process_id   varchar2);
  procedure sp_phy_contract_status(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2);
  procedure sp_feed_consumption_report(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2);
  procedure sp_stock_monthly_yeild(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2);
  procedure sp_calc_risk_limits(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process_id   varchar2,
                                pc_user_id      varchar2,
                                pc_process      varchar2);
  procedure sp_calc_phy_unreal_pnl_attr(pc_corporate_id        varchar2,
                                        pd_trade_date          date,
                                        pd_prev_trade_date     date,
                                        pc_process_id          varchar2,
                                        pc_previous_process_id varchar2,
                                        pc_user_id             varchar2);
  procedure sp_metal_balance_qty_summary(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2);
  procedure sp_misc_updates(pc_corporate_id varchar2,
                            pd_trade_date   date,
                            pc_process_id   varchar2,
                            pc_process      varchar2,
                            pc_user_id      varchar2);
  procedure sp_daily_position_record(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_process_id   varchar2);
  procedure sp_insert_temp_gmr(pc_corporate_id varchar2,
                               pd_trade_date   date,
                               pc_process_id   varchar2);
  procedure sp_arrival_report(pc_corporate_id varchar2,
                              pd_trade_date   date,
                              pc_process_id   varchar2,
                              pc_process      varchar2);
  procedure sp_feedconsumption_report(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_process_id   varchar2,
                                      pc_process      varchar2);
  procedure sp_closing_balance_report(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_process_id   varchar2,
                                      pc_process      varchar2,
                                      pc_dbd_id       varchar2);
  procedure sp_calc_treatment_charge(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_process_id   varchar2,
                                     pc_process      varchar2,
                                     pc_dbd_id       varchar2);

  procedure sp_calc_refining_charge(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_process_id   varchar2,
                                    pc_process      varchar2,
                                    pc_dbd_id       varchar2);

  procedure sp_calc_penalty_charge(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_process      varchar2,
                                   pc_dbd_id       varchar2);

  procedure sp_calc_freight_other_charge(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_process      varchar2);
end;
/
create or replace package body pkg_phy_eod_reports is
  procedure sp_calc_daily_trade_pnl
  --------------------------------------------------------------------------------------------------------------------------
    ----        procedure name                            : sp_calc_daily_trade_pnl
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
    --        modified date                             : saurabh
    --        modified by                               : exchange name and exchange id
    --        modify description                        :
    --------------------------------------------------------------------------------------------------------------------------
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_process_id   varchar2,
   pc_process      varchar2,
   pc_user_id      varchar2) is
    vc_prev_process_id varchar2(20);
    vd_prev_eod_date   date;
    vc_prev_eom_ref_no varchar2(20);
    vd_prev_eom_date   date;
    vd_acc_start_date  date;
    vc_process         varchar2(5);
    --vd_acc_end_date           date;
    vobj_error_log            tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count        number := 1;
    vn_base_currency_decimals number;
  begin
    -------- to get the previous eod reference number and date
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'sp_calc_trade_pnl',
                 'one');
    vc_process := pc_process;
    begin
      select max(t.trade_date) prev_trade_date,
             substr(max(case
                          when t.process_id is not null then
                           to_char(t.trade_date, 'yyyymmddhh24miss') || t.process_id
                        end),
                    15) prev_process_id
        into vd_prev_eod_date,
             vc_prev_process_id
        from tdc_trade_date_closure t
       where t.trade_date < pd_trade_date
         and t.corporate_id = pc_corporate_id
         and t.process = 'EOD';
    exception
      when no_data_found then
        vc_prev_process_id := null;
        vd_prev_eod_date   := to_date('01-Jan-2000', 'dd-Mon-yyyy');
    end;
    -------- to get the previous eom reference number and date
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'sp_calc_trade_pnl',
                 'two');
    begin
      select tdc.trade_date,
             tdc.process_id
        into vd_prev_eom_date,
             vc_prev_eom_ref_no
        from tdc_trade_date_closure tdc
       where tdc.trade_date = (select max(t.trade_date)
                                 from tdc_trade_date_closure t
                                where t.trade_date < pd_trade_date
                                  and t.corporate_id = pc_corporate_id
                                  and t.process = 'EOM')
         and tdc.corporate_id = pc_corporate_id
         and tdc.process = 'EOM';
    exception
      when no_data_found then
        vc_prev_eom_ref_no := null;
        vd_prev_eom_date   := to_date('01-Jan-2000', 'dd-Mon-yyyy');
    end;
    -- to get the accounding period start year date
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'sp_calc_trade_pnl',
                 'three');
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
    -- get the decimals for the base currency
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'sp_calc_trade_pnl',
                 'threeeeeeee');
    begin
      select nvl(decimals, 2)
        into vn_base_currency_decimals
        from ak_corporate       akc,
             cm_currency_master cm
       where akc.corporate_id = pc_corporate_id
         and akc.base_cur_id = cm.cur_id;
    exception
      when others then
        vn_base_currency_decimals := 2;
    end;
    -----------------------------------------------------------------------------------------
    ------------------record unrealized contracts details------------------------------------
    -----------------------------------------------------------------------------------------
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'sp_calc_trade_pnl',
                 'Before Insert into Trade PNL.....');
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
       group_qty_unit,
       unrealized_section,
       is_pending_approval,
       instrument_id,
       instrument_name)
      select t.corporate_id,
             t.corporate_name,
             pc_process_id,
             profit_center_id,
             profit_center_name,
             profit_center_short_name,
             main_section,
             sub_section,
             round(nvl(sum(today_pnl), 0) - nvl(sum(prev_yearend_pnl), 0),
                   vn_base_currency_decimals) year_to_date_pnl,
             round(nvl(sum(prev_eom_pnl), 0) -
                   nvl(sum(prev_yearend_pnl), 0),
                   vn_base_currency_decimals) prev_month_pnl,
             decode(vc_process,
                    'EOM',
                    0,
                    round(nvl(sum(today_pnl), 0) - nvl(sum(prev_eom_pnl), 0),
                          vn_base_currency_decimals)) month_to_date_pnl,
             round(nvl(sum(today_pnl), 0) -
                   nvl(decode(vc_process, 'EOM', 0, sum(prev_eod_pnl)), 0),
                   vn_base_currency_decimals) today_pnl,
             t.base_cur_id,
             base_cur_code,
             gcd.groupid,
             gcd.groupname,
             gcd.group_cur_id,
             cm_gcd.cur_code,
             gcd.group_qty_unit_id,
             qum_gcd.qty_unit,
             unrealized_section,
             is_pending_approval,
             t.product_id,
             t.product_name
        from (select poud.corporate_id,
                     poud.corporate_name,
                     poud.profit_center_id,
                     poud.profit_center_name,
                     poud.profit_center_short_name,
                     poud.main_section,
                     poud.sub_section,
                     0 prev_yearend_pnl,
                     0 prev_eom_pnl,
                     sum(case
                           when poud.process_id = vc_prev_process_id then
                            nvl(poud.pnl, 0)
                           else
                            0
                         end) prev_eod_pnl,
                     sum(case
                           when poud.process_id = pc_process_id then
                            nvl(poud.pnl, 0)
                           else
                            0
                         end) today_pnl,
                     poud.pnl_cur_id base_cur_id,
                     poud.pnl_cur_code base_cur_code,
                     entity unrealized_section,
                     poud.approval_status is_pending_approval,
                     poud.product_id,
                     poud.product_name
                from pps_physical_pnl_summary poud
               where poud.corporate_id = pc_corporate_id
                 and poud.process_id in (vc_prev_process_id, pc_process_id)
                 and poud.main_section = 'Physical'
                 and poud.sub_section = 'Unrealized'
                 and poud.entity = 'Contract'
               group by poud.corporate_id,
                        poud.corporate_name,
                        poud.profit_center_id,
                        poud.profit_center_name,
                        poud.profit_center_short_name,
                        poud.pnl_cur_id,
                        poud.pnl_cur_code,
                        poud.approval_status,
                        poud.main_section,
                        poud.sub_section,
                        poud.entity,
                        poud.product_id,
                        poud.product_name
              union all
              select poum.corporate_id,
                     poum.corporate_name,
                     poum.profit_center_id,
                     poum.profit_center_name,
                     poum.profit_center_short_name,
                     'Physical' as main_section,
                     'Unrealized' as sub_section,
                     sum(poum.pnl) prev_yearend_pnl,
                     0 prev_eom_pnl,
                     0 prev_eod_pnl,
                     0 today_pnl,
                     poum.pnl_cur_id base_cur_id,
                     poum.pnl_cur_code base_cur_code,
                     poum.entity unrealized_section,
                     poum.approval_status is_pending_approval,
                     poum.product_id,
                     poum.product_name
                from pps_physical_pnl_summary poum,
                     (select mec1.corporate_id,
                             max(mec1.trade_date) prev_year_month_end,
                             substr(max(case
                                          when mec1.process_id is not null then
                                           to_char(mec1.trade_date, 'yyyymmddhh24miss') ||
                                           mec1.process_id
                                        end),
                                    15) month_process_id
                        from tdc_trade_date_closure mec1
                       where mec1.corporate_id = pc_corporate_id
                         and mec1.process = 'EOM'
                         and mec1.trade_date <=
                             (select max(end_date)
                                from cfy_corporate_financial_year@eka_appdb
                               where end_date < vd_acc_start_date
                                 and corporateid = pc_corporate_id)
                       group by mec1.corporate_id) prev_month_data
               where poum.corporate_id = pc_corporate_id
                 and poum.main_section = 'Physical'
                 and poum.sub_section = 'Unrealized'
                 and poum.entity = 'Contract'
                 and poum.process_id = prev_month_data.month_process_id
                 and poum.corporate_id = prev_month_data.corporate_id
               group by poum.corporate_id,
                        poum.corporate_name,
                        poum.profit_center_id,
                        poum.profit_center_name,
                        poum.profit_center_short_name,
                        poum.pnl_cur_id,
                        poum.pnl_cur_code,
                        poum.approval_status,
                        poum.main_section,
                        poum.sub_section,
                        poum.entity,
                        poum.product_id,
                        poum.product_name
              union all
              select poum.corporate_id,
                     poum.corporate_name,
                     poum.profit_center_id,
                     poum.profit_center_name,
                     poum.profit_center_short_name,
                     poum.main_section,
                     poum.sub_section,
                     0 prev_yearend_pnl,
                     sum(poum.pnl) prev_eom_pnl,
                     0 prev_eod_pnl,
                     0 today_pnl,
                     poum.pnl_cur_id base_cur_id,
                     poum.pnl_cur_code base_cur_code,
                     poum.entity unrealized_section,
                     poum.approval_status is_pending_approval,
                     poum.product_id,
                     poum.product_name
                from pps_physical_pnl_summary poum
               where poum.corporate_id = pc_corporate_id
                 and poum.main_section = 'Physical'
                 and poum.sub_section = 'Unrealized'
                 and poum.entity = 'Contract'
                 and poum.process_id = vc_prev_eom_ref_no
               group by poum.corporate_id,
                        poum.corporate_name,
                        poum.profit_center_id,
                        poum.profit_center_name,
                        poum.profit_center_short_name,
                        poum.pnl_cur_id,
                        poum.pnl_cur_code,
                        poum.approval_status,
                        poum.main_section,
                        poum.sub_section,
                        poum.product_id,
                        poum.product_name,
                        poum.entity
              union all
              select psud.corporate_id,
                     psud.corporate_name,
                     psud.profit_center_id,
                     psud.profit_center_name,
                     psud.profit_center_short_name,
                     psud.main_section,
                     psud.sub_section,
                     0 prev_yearend_pnl,
                     0 prev_eom_pnl,
                     sum(case
                           when psud.process_id = vc_prev_process_id then
                            nvl(psud.pnl, 0)
                           else
                            0
                         end) prev_eod_pnl,
                     sum(case
                           when psud.process_id = pc_process_id then
                            nvl(psud.pnl, 0)
                           else
                            0
                         end) today_pnl,
                     psud.pnl_cur_id,
                     psud.pnl_cur_code,
                     psud.entity unrealized_section,
                     'N' is_pending_approval,
                     psud.product_id,
                     psud.product_name
                from pps_physical_pnl_summary psud
               where psud.corporate_id = pc_corporate_id
                 and psud.process_id in (vc_prev_process_id, pc_process_id)
                 and psud.main_section = 'Physical'
                 and psud.sub_section = 'Unrealized'
                 and psud.entity = 'Stock'
               group by psud.corporate_id,
                        psud.corporate_name,
                        psud.profit_center_id,
                        psud.profit_center_name,
                        psud.profit_center_short_name,
                        psud.pnl_cur_id,
                        psud.pnl_cur_code,
                        psud.main_section,
                        psud.sub_section,
                        psud.product_id,
                        psud.product_name,
                        psud.entity
              union all
              select psum.corporate_id,
                     psum.corporate_name,
                     psum.profit_center_id,
                     psum.profit_center_name,
                     psum.profit_center_short_name,
                     psum.main_section,
                     psum.sub_section,
                     sum(psum.pnl) prev_yearend_pnl,
                     0 prev_eom_pnl,
                     0 prev_eod_pnl,
                     0 today_pnl,
                     psum.pnl_cur_id,
                     psum.pnl_cur_code,
                     psum.entity unrealized_section,
                     psum.approval_status is_pending_approval,
                     psum.product_id,
                     psum.product_name
                from pps_physical_pnl_summary psum,
                     (select mec1.corporate_id,
                             max(mec1.trade_date) prev_year_month_end,
                             substr(max(case
                                          when mec1.process_id is not null then
                                           to_char(mec1.trade_date, 'yyyymmddhh24miss') ||
                                           mec1.process_id
                                        end),
                                    15) month_process_id
                        from tdc_trade_date_closure mec1
                       where mec1.corporate_id = pc_corporate_id
                         and mec1.process = 'EOM'
                         and mec1.trade_date <=
                             (select max(end_date)
                                from cfy_corporate_financial_year@eka_appdb
                               where end_date < vd_acc_start_date
                                 and corporateid = pc_corporate_id)
                       group by mec1.corporate_id) prev_month_data
               where psum.corporate_id = pc_corporate_id
                 and psum.main_section = 'Physical'
                 and psum.sub_section = 'Unrealized'
                 and psum.entity = 'Stock'
                 and psum.process_id = prev_month_data.month_process_id
                 and psum.corporate_id = prev_month_data.corporate_id
               group by psum.corporate_id,
                        psum.corporate_name,
                        psum.profit_center_short_name,
                        psum.profit_center_name,
                        psum.profit_center_id,
                        psum.pnl_cur_id,
                        psum.pnl_cur_code,
                        psum.approval_status,
                        psum.main_section,
                        psum.sub_section,
                        psum.product_id,
                        psum.product_name,
                        psum.entity
              union all
              select psum.corporate_id,
                     psum.corporate_name,
                     psum.profit_center_id,
                     psum.profit_center_name,
                     psum.profit_center_short_name,
                     psum.main_section,
                     psum.sub_section,
                     0 prev_yearend_pnl,
                     sum(psum.pnl) prev_eom_pnl,
                     0 prev_eod_pnl,
                     0 today_pnl,
                     psum.pnl_cur_id,
                     psum.pnl_cur_code,
                     psum.entity unrealized_section,
                     psum.approval_status is_pending_approval,
                     psum.product_id,
                     psum.product_name
                from pps_physical_pnl_summary psum
               where psum.corporate_id = pc_corporate_id
                 and psum.main_section = 'Physical'
                 and psum.sub_section = 'Unrealized'
                 and psum.entity = 'Stock'
                 and psum.process_id = vc_prev_eom_ref_no
               group by psum.corporate_id,
                        psum.corporate_name,
                        psum.profit_center_id,
                        psum.profit_center_short_name,
                        psum.profit_center_name,
                        psum.pnl_cur_id,
                        psum.approval_status,
                        psum.pnl_cur_code,
                        psum.main_section,
                        psum.sub_section,
                        psum.product_id,
                        psum.product_name,
                        psum.entity) t,
             gcd_groupcorporatedetails@eka_appdb gcd,
             ak_corporate akc,
             qum_quantity_unit_master qum_gcd,
             cm_currency_master cm_gcd
       where t.corporate_id = akc.corporate_id
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm_gcd.cur_id
         and gcd.group_qty_unit_id = qum_gcd.qty_unit_id
       group by t.corporate_id,
                t.corporate_name,
                profit_center_id,
                profit_center_name,
                profit_center_short_name,
                main_section,
                sub_section,
                t.base_cur_id, --
                base_cur_code,
                gcd.groupid,
                gcd.groupname,
                gcd.group_cur_id,
                cm_gcd.cur_code,
                gcd.group_qty_unit_id,
                qum_gcd.qty_unit,
                unrealized_section,
                is_pending_approval,
                t.product_id,
                t.product_name;
    -----------------------------------------------------------------------------------------
    ------------------record realized physical contracts details----------------------------------
    -----------------------------------------------------------------------------------------
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
       group_qty_unit,
       unrealized_section,
       is_pending_approval,
       instrument_id,
       instrument_name)
      select t.corporate_id,
             t.corporate_name,
             pc_process_id,
             profit_center_id,
             profit_center_name,
             profit_center_short_name,
             'Physical' as main_section,
             'Realized' as sub_section,
             round(sum(prev_month) +
                   decode(vc_process, 'EOM', sum(today), sum(month_to_date)),
                   vn_base_currency_decimals) year_to_date_pnl,
             round(sum(prev_month), vn_base_currency_decimals) previous_month_pnl,
             round(decode(vc_process, 'EOM', 0, sum(month_to_date)),
                   vn_base_currency_decimals) month_to_date_pnl,
             round(sum(today), vn_base_currency_decimals) today_pnl,
             t.base_cur_id,
             base_cur_code,
             gcd.groupid,
             gcd.groupname,
             gcd.group_cur_id,
             cm_gcd.cur_code,
             gcd.group_qty_unit_id,
             qum_gcd.qty_unit,
             unrealized_section,
             is_pending_approval,
             t.product_id,
             t.product_name
        from (select prd.corporate_id,
                     prd.corporate_name,
                     prd.profit_center_id,
                     prd.profit_center_name,
                     prd.profit_center_short_name,
                     'Physical' as main_section,
                     'Realized' as sub_section,
                     0 prev_month,
                     sum(prd.pnl) month_to_date,
                     sum((case
                           when tdc.trade_date = pd_trade_date then
                            prd.pnl
                           else
                            0
                         end)) today,
                     prd.pnl_cur_id base_cur_id,
                     prd.pnl_cur_code base_cur_code,
                     'Physical' unrealized_section,
                     'N' is_pending_approval,
                     prd.product_id,
                     prd.product_name
                from pps_physical_pnl_summary prd,
                     tdc_trade_date_closure   tdc
               where prd.corporate_id = pc_corporate_id
                 and prd.process_id = tdc.process_id
                 and prd.corporate_id = tdc.corporate_id
                 and tdc.trade_date <= pd_trade_date
                 and tdc.trade_date > vd_prev_eom_date
                 and prd.main_section = 'Physical'
                 and prd.sub_section = 'Realized'
                 and prd.entity = 'Physical'
               group by prd.corporate_id,
                        prd.corporate_name,
                        prd.profit_center_id,
                        profit_center_name,
                        prd.profit_center_short_name,
                        prd.pnl_cur_id,
                        prd.product_id,
                        prd.product_name,
                        prd.pnl_cur_code
              union all
              select prm.corporate_id,
                     prm.corporate_name,
                     prm.profit_center_id,
                     prm.profit_center_name,
                     prm.profit_center_short_name,
                     'Physical' as main_section,
                     'Realized' as sub_section,
                     sum(prm.pnl) prev_month,
                     0 month_to_date,
                     0 today,
                     prm.pnl_cur_id,
                     prm.pnl_cur_code,
                     'Physical' unrealized_section,
                     'N' is_pending_approval,
                     prm.product_id,
                     prm.product_name
                from pps_physical_pnl_summary prm,
                     tdc_trade_date_closure   mec
               where prm.corporate_id = mec.corporate_id
                 and prm.process_id = mec.process_id
                 and mec.process = 'EOM'
                 and prm.corporate_id = pc_corporate_id
                 and mec.trade_date >= vd_acc_start_date
                 and mec.trade_date <= vd_prev_eom_date
                 and prm.main_section = 'Physical'
                 and prm.sub_section = 'Realized'
                 and prm.entity = 'Physical'
               group by prm.corporate_id,
                        prm.corporate_name,
                        prm.profit_center_id,
                        prm.profit_center_name,
                        prm.profit_center_short_name,
                        prm.pnl_cur_id,
                        prm.pnl_cur_code,
                        prm.product_id,
                        prm.product_name) t,
             gcd_groupcorporatedetails@eka_appdb gcd,
             ak_corporate akc,
             qum_quantity_unit_master qum_gcd,
             cm_currency_master cm_gcd
       where t.corporate_id = akc.corporate_id
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm_gcd.cur_id
         and gcd.group_qty_unit_id = qum_gcd.qty_unit_id
       group by t.corporate_id,
                t.corporate_name,
                profit_center_id,
                profit_center_name,
                profit_center_short_name,
                unrealized_section,
                is_pending_approval,
                t.base_cur_id, --
                base_cur_code,
                gcd.groupid,
                gcd.groupname,
                gcd.group_cur_id,
                cm_gcd.cur_code,
                gcd.group_qty_unit_id,
                qum_gcd.qty_unit,
                t.product_id,
                t.product_name;
    --------------------------------------------------------------------------------------
    ------------------record direct to realized costs details----------------------------------
    --------------------------------------------------------------------------------------
    /*insert into tpd_trade_pnl_daily
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
     group_qty_unit,
     unrealized_section,
     is_pending_approval)
    select t.corporate_id,
           t.corporate_name,
           pc_process_id,
           profit_center_id,
           profit_center_name,
           profit_center_short_name,
           'Physical' as main_section,
           'Direct to Realized Cost' as sub_section,
           round(sum(prev_month) + decode(gvc_process,'EOM',sum(today),sum(month_to_date)),
                 vn_base_currency_decimals) year_to_date_pnl,
           round(sum(prev_month),
                 vn_base_currency_decimals) previous_month_pnl,
           round(decode(gvc_process,'EOM',0,sum(month_to_date)),
                 vn_base_currency_decimals) month_to_date_pnl,
           round(sum(today),
                 vn_base_currency_decimals) today_pnl,
           t.base_cur_id,
           base_cur_code,
           gcd.groupid,
           gcd.groupname,
           gcd.group_cur_id,
           cm_gcd.cur_code,
           gcd.group_qty_unit_id,
           qum_gcd.qty_unit,
           unrealized_section,
           is_pending_approval
    from   (select gdrc.corporate_id,
                   akc.corporate_name,
                   gdrc.profit_center_id,
                   cpc.profit_center_name,
                   cpc.profit_center_short_name,
                   'Physical' as main_section,
                   'Direct to Realized Cost' as sub_section,
                   0 prev_month,
                   sum(gdrc.dtrc_cost) month_to_date,
                   sum((case
                           when tdc.trade_date = pd_trade_date then
                            gdrc.dtrc_cost
                           else
                            0
                       end)) today,
                   akc.base_cur_id base_cur_id,
                   akc.base_currency_name base_cur_code,
                   'Physical' unrealized_section,
                   'N' is_pending_approval
            from   gdrc_gmr_direct_realized_cost gdrc,
                   cpc_corporate_profit_center cpc,
                   tdc_trade_date_closure   tdc,
                   ak_corporate akc
            where  gdrc.corporate_id = pc_corporate_id
            and    gdrc.process_id = tdc.process_id
            and    gdrc.corporate_id = tdc.corporate_id
            and    tdc.trade_date <= pd_trade_date
            and    tdc.trade_date > vd_prev_eom_date
            and    gdrc.profit_center_id = cpc.profit_center_id
            and    gdrc.corporate_id = akc.corporate_id
            group  by gdrc.corporate_id,
                      akc.corporate_name,
                      gdrc.profit_center_id,
                      cpc.profit_center_name,
                      cpc.profit_center_short_name,
                      akc.base_cur_id,
                      akc.base_currency_name
            union all
            select gdrc.corporate_id,
                   akc.corporate_name,
                   gdrc.profit_center_id,
                   cpc.profit_center_name,
                   cpc.profit_center_short_name,
                   'Physical' as main_section,
                   'Direct to Realized Cost' as sub_section,
                   sum(gdrc.dtrc_cost) prev_month,
                   0 month_to_date,
                   0 today,
                   akc.base_cur_id base_cur_id,
                   akc.base_currency_name base_cur_code,
                   'Physical' unrealized_section,
                   'N' is_pending_approval
            from   gdrc_gmr_direct_realized_cost gdrc,
                   cpc_corporate_profit_center cpc,
                   tdc_trade_date_closure   tdc,
                   ak_corporate akc
            where  gdrc.corporate_id = pc_corporate_id
            and    gdrc.process_id = tdc.process_id
            and    gdrc.corporate_id = tdc.corporate_id
            and    tdc.process = 'EOM'
            and    tdc.trade_date <= vd_prev_eom_date
            and    tdc.trade_date >= vd_acc_start_date
            and    gdrc.profit_center_id = cpc.profit_center_id
            and    gdrc.corporate_id = akc.corporate_id
            group  by gdrc.corporate_id,
                      akc.corporate_name,
                      gdrc.profit_center_id,
                      cpc.profit_center_name,
                      cpc.profit_center_short_name,
                      akc.base_cur_id,
                      akc.base_currency_name) t,
           gcd_groupcorporatedetails@eka_appdb gcd,
           ak_corporate@eka_appdb akc,
           qum_quantity_unit_master qum_gcd,
           cm_currency_master cm_gcd
    where  t.corporate_id = akc.corporate_id
    and    akc.groupid = gcd.groupid
    and    gcd.group_cur_id = cm_gcd.cur_id
    and    gcd.group_qty_unit_id = qum_gcd.qty_unit_id
    group  by t.corporate_id,
              t.corporate_name,
              profit_center_id,
              profit_center_name,
              profit_center_short_name,
              unrealized_section,
              is_pending_approval,
              t.base_cur_id, --
              base_cur_code,
              gcd.groupid,
              gcd.groupname,
              gcd.group_cur_id,
              cm_gcd.cur_code,
              gcd.group_qty_unit_id,
              qum_gcd.qty_unit;*/
    -------------------------------------------------------------------------------------------
    -------------record carrying costs details----------------------------------------
    -------------------------------------------------------------------------------------------
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
       group_qty_unit,
       unrealized_section,
       is_pending_approval,
       exchange_id,
       exchange_name)
      select corporate_id,
             corporate_name,
             pc_process_id,
             profit_center_id,
             profit_center_name,
             profit_center_short_name,
             main_section,
             sub_section,
             round(today, vn_base_currency_decimals) ytd_pnl,
             round(prev_month, vn_base_currency_decimals) previous_month_pnl,
             round((today - prev_month), vn_base_currency_decimals) mtd_pnl,
             round(decode(vc_process, 'EOM', 0, (today - prev_day)),
                   vn_base_currency_decimals) today_pnl,
             cur_id,
             cur_code,
             group_id,
             group_name,
             group_cur_id,
             group_cur_code,
             group_qty_unit_id,
             group_qty_unit,
             unrealized_section,
             is_pending_approval,
             '' exchange_id,
             '' exchange_name
        from (select cps.corporate_id,
                     akc.corporate_name,
                     cps.profit_center_id,
                     cps.profit_center_name,
                     cps.profit_center_short_name,
                     'Carrying Costs' as main_section,
                     cps.sub_section as sub_section,
                     sum((case
                           when cps.process_id = vc_prev_eom_ref_no then
                            nvl(cps.cost_amt, 0)
                           else
                            0
                         end)) prev_month,
                     0 prev_day,
                     0 today,
                     cps.cost_cur_id cur_id,
                     cps.cost_cur_code cur_code,
                     gcd.groupid group_id,
                     gcd.groupname group_name,
                     gcd.group_cur_id group_cur_id,
                     cm_gcd.cur_code group_cur_code,
                     gcd.group_qty_unit_id group_qty_unit_id,
                     qum_gcd.qty_unit group_qty_unit,
                     '' unrealized_section,
                     'N' is_pending_approval
                from cps_cost_pnl_summary                cps,
                     ak_corporate                        akc,
                     gcd_groupcorporatedetails@eka_appdb gcd,
                     cm_currency_master                  cm_akc,
                     cm_currency_master                  cm_gcd,
                     cm_currency_master                  cm_cps,
                     qum_quantity_unit_master            qum_gcd
               where cps.corporate_id = akc.corporate_id
                 and akc.base_currency_name = cm_akc.cur_code
                 and akc.groupid = gcd.groupid
                 and gcd.group_cur_id = cm_gcd.cur_id
                 and gcd.group_qty_unit_id = qum_gcd.qty_unit_id
                 and cm_cps.cur_id = cps.cost_cur_id
                 and cps.process_id = vc_prev_eom_ref_no
                 and cps.main_section = 'Carrying Costs'
               group by cps.corporate_id,
                        akc.corporate_name,
                        cps.profit_center_id,
                        cps.profit_center_name,
                        cps.profit_center_short_name,
                        cps.sub_section,
                        cps.cost_cur_id,
                        cps.cost_cur_code,
                        gcd.groupid,
                        gcd.groupname,
                        gcd.group_cur_id,
                        cm_gcd.cur_code,
                        gcd.group_qty_unit_id,
                        qum_gcd.qty_unit) temp;
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
       group_qty_unit,
       unrealized_section,
       is_pending_approval)
      select pc_corporate_id,
             t.corporate_name,
             pc_process_id,
             t.profit_center_id,
             t.profit_center_name,
             t.profit_center_short_name,
             t.main_section,
             t.sub_section,
             sum(t.previous_month_pnl) + sum(t.month_to_date_pnl) year_to_date_pnl,
             sum(t.previous_month_pnl) prev_month_pnl,
             sum(t.month_to_date_pnl) month_to_date_pnl,
             sum(t.today_pnl) today_pnl,
             t.base_cur_id,
             t.base_cur_code,
             gcd.groupid group_id,
             gcd.groupname group_name,
             gcd.group_cur_id group_cur_id,
             cm.cur_code group_cur_code,
             gcd.group_qty_unit_id group_qty_unit_id,
             qum.qty_unit group_qty_unit,
             t.unrealized_section,
             'N' is_pending_approval
        from (select cps.corporate_id,
                     cps.corporate_name,
                     cps.profit_center_id,
                     cps.profit_center_name,
                     cps.profit_center_short_name,
                     cps.main_section,
                     'Write Off Stock' sub_section,
                     sum(case
                           when cps.process_id = pc_process_id then
                            cps.cost_amt
                           else
                            0
                         end) today_pnl,
                     sum(cps.cost_amt) month_to_date_pnl,
                     0 previous_month_pnl,
                     cps.cost_cur_id base_cur_id,
                     cps.cost_cur_code base_cur_code,
                     cps.entity unrealized_section,
                     'N' is_pending_approval
                from cps_cost_pnl_summary   cps,
                     tdc_trade_date_closure tdc
               where cps.corporate_id = pc_corporate_id
                 and tdc.corporate_id = pc_corporate_id
                 and cps.process_id = tdc.process_id
                 and tdc.process = 'EOD'
                 and cps.process_id = pc_process_id
                 and cps.main_section = 'General Cost'
                 and cps.sub_section in
                     ('Write Off Stock', 'Undo Write-Off Stocks')
                 and tdc.trade_date <= pd_trade_date
                 and tdc.trade_date > vd_prev_eom_date
               group by cps.corporate_id,
                        cps.corporate_name,
                        cps.profit_center_id,
                        cps.profit_center_name,
                        cps.profit_center_short_name,
                        cps.main_section,
                        cps.cost_cur_id,
                        cps.cost_cur_code,
                        cps.entity) t,
             gcd_groupcorporatedetails@eka_appdb gcd,
             ak_corporate akc,
             cm_currency_master cm,
             qum_quantity_unit_master qum
       where akc.corporate_id = t.corporate_id
         and akc.groupid = gcd.groupid
         and cm.cur_id = gcd.group_cur_id
         and qum.qty_unit_id = gcd.group_qty_unit_id
       group by t.corporate_id,
                t.corporate_name,
                t.profit_center_id,
                t.profit_center_name,
                t.profit_center_short_name,
                t.main_section,
                t.sub_section,
                t.base_cur_id,
                t.base_cur_code,
                gcd.groupid,
                gcd.groupname,
                gcd.group_cur_id,
                cm.cur_code,
                gcd.group_qty_unit_id,
                qum.qty_unit,
                t.unrealized_section;
    ----ends here      
    -------------record physical write off section for realized-----------------------
    -------------record direct to realized costs details------------------------------   
    -- This is to populate missing sections
    -- Any section that needs data population has to be done before this
    /* INSERT INTO tpd_trade_pnl_daily
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
         group_qty_unit,
         unrealized_section,
         is_pending_approval)
        SELECT corporate_id,
               corporate_name,
               pc_process_id,
               cpc.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               tps.main_section,
               tps.sub_section,
               0,
               0,
               0,
               0,
               cm_akc.cur_id,
               cm_akc.cur_code,
               gcd.groupid,
               gcd.groupname,
               gcd.group_cur_id,
               cm_gcd.cur_code,
               qum_gcd.qty_unit_id,
               qum_gcd.qty_unit,
               tps.entity,
               'N'
        FROM   ak_corporate                akc,
               cpc_corporate_profit_center cpc,
               tps_trade_pnl_sections      tps,
               cm_currency_master          cm_akc,
               gcd_groupcorporatedetails   gcd,
               cm_currency_master          cm_gcd,
               qum_quantity_unit_master    qum_gcd
        WHERE  akc.base_currency_name = cm_akc.cur_code
        AND    akc.groupid = gcd.groupid
        AND    gcd.group_cur_id = cm_gcd.cur_id
        AND    gcd.group_qty_unit_id = qum_gcd.qty_unit_id
        AND    cpc.corporateid = akc.corporate_id
        AND    tps.is_exchange_required = 'N'
        AND    cpc.corporateid = pc_corporate_id
        AND    NOT EXISTS
         (SELECT *
                FROM   tpd_trade_pnl_daily tpd
                WHERE  tpd.process_id = pc_process_id
                AND    tpd.main_section = tps.main_section
                AND    tpd.sub_section = tps.sub_section
                AND    tpd.unrealized_section = tps.entity
                AND    tpd.profit_center_id = cpc.profit_center_id);
    -- Exchange Based Data
    INSERT INTO tpd_trade_pnl_daily
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
         group_qty_unit,
         unrealized_section,
         is_pending_approval,
         exchange_id,
         exchange_name)
        SELECT corporate_id,
               corporate_name,
               pc_process_id,
               cpc.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               tps.main_section,
               tps.sub_section,
               0,
               0,
               0,
               0,
               cm_akc.cur_id,
               cm_akc.cur_code,
               gcd.groupid,
               gcd.groupname,
               gcd.group_cur_id,
               cm_gcd.cur_code,
               qum_gcd.qty_unit_id,
               qum_gcd.qty_unit,
               tps.entity,
               'N',
               emt.exchange_id,
               emt.exchange_name
        FROM   ak_corporate                akc,
               cpc_corporate_profit_center cpc,
               tps_trade_pnl_sections      tps,
               cm_currency_master          cm_akc,
               gcd_groupcorporatedetails   gcd,
               cm_currency_master          cm_gcd,
               qum_quantity_unit_master    qum_gcd,
               emt_exchangemaster          emt
        WHERE  akc.base_currency_name = cm_akc.cur_code
        AND    akc.groupid = gcd.groupid
        AND    gcd.group_cur_id = cm_gcd.cur_id
        AND    gcd.group_qty_unit_id = qum_gcd.qty_unit_id
        AND    cpc.corporateid = akc.corporate_id
        AND    tps.is_exchange_required = 'Y'
        AND    cpc.corporateid = pc_corporate_id
        AND    NOT EXISTS
         (SELECT *
                FROM   tpd_trade_pnl_daily tpd
                WHERE  tpd.process_id = pc_process_id
                AND    tpd.main_section = tps.main_section
                AND    tpd.sub_section = tps.sub_section
                AND    tpd.unrealized_section = tps.entity
                AND    tpd.profit_center_id = cpc.profit_center_id
                AND    tpd.exchange_id = emt.exchange_id);*/
    ----PARAMETER INSERT
    insert into tpp_trade_pnl_parameters
      (process_id,
       prev_process_id,
       prev_eod_date,
       prev_eom_ref_no,
       prev_eom_date,
       acc_start_date)
    values
      (pc_process_id,
       vc_prev_process_id,
       vd_prev_eod_date,
       vc_prev_eom_ref_no,
       vd_prev_eom_date,
       vd_acc_start_date);
    ----ENDS HERE 
  
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_daily_trade_pnl',
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
      commit;
  end;
  procedure sp_calc_pnl_summary(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process_id   varchar2,
                                pc_process      varchar2,
                                pc_user_id      varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vc_process         varchar2(5);
  begin
    --
    -- record physical unrealized pnl
    --the below part is still commented as it is for stocks.
    --
    vc_process := pc_process;
    insert into pps_physical_pnl_summary
      (corporate_id,
       corporate_name,
       process_id,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       main_section,
       sub_section,
       entity,
       pnl,
       pnl_cur_id,
       pnl_cur_code,
       approval_status,
       product_id,
       product_name)
      select poud.corporate_id,
             poud.corporate_name,
             pc_process_id,
             poud.profit_center_id,
             poud.profit_center_short_name,
             poud.profit_center_name,
             'Physical' as main_section,
             'Unrealized' as sub_section,
             'Contract' entity,
             sum(poud.unrealized_pnl_in_base_cur) pnl,
             poud.base_cur_id pnl_cur_id,
             poud.base_cur_code pnl_cur_code,
             (case
               when nvl(poud.approval_status, 'NA') = 'Pending Approval' then
                'Y'
               else
                'N'
             end) is_pending_approval,
             poud.product_id,
             poud.product_name
        from poud_phy_open_unreal_daily poud
       where poud.corporate_id = pc_corporate_id
         and poud.process_id = pc_process_id
         and poud.unrealized_type in ('Unrealized','Realized Not Final Invoiced')
       group by poud.corporate_id,
                poud.corporate_name,
                poud.profit_center_id,
                poud.profit_center_name,
                poud.profit_center_short_name,
                poud.base_cur_id,
                poud.base_cur_code,
                poud.approval_status,
                poud.product_id,
                poud.product_name
      union all
      select psu.corporate_id,
             akc.corporate_name,
             pc_process_id,
             cpc.profit_center_id,
             cpc.profit_center_short_name,
             cpc.profit_center_name,
             'Physical' as main_section,
             'Unrealized' as sub_section,
             'Stock' entity,
             sum(psu.pnl_in_base_cur),
             psu.base_cur_id,
             psu.base_cur_code,
             'N',
             psu.product_id,
             psu.product_name
        from psu_phy_stock_unrealized psu,
             ak_corporate             akc,
             ---psci_phy_stock_contract_item psci
             cpc_corporate_profit_center cpc
       where psu.corporate_id = pc_corporate_id
         and akc.corporate_id = psu.corporate_id
         and psu.profit_center_id = cpc.profit_center_id
         and psu.process_id = pc_process_id
         and psu.pnl_type in ('Unrealized')
       group by psu.corporate_id,
                akc.corporate_name,
                cpc.profit_center_id,
                cpc.profit_center_name,
                cpc.profit_center_short_name,
                psu.base_cur_id,
                psu.base_cur_code,
                psu.product_id,
                psu.product_name
      union all
      ---- record physical open unrealized for element
      select poue.corporate_id,
             poue.corporate_name,
             pc_process_id,
             poue.profit_center_id,
             poue.profit_center_short_name,
             poue.profit_center_name,
             'Physical' as main_section,
             'Unrealized' as sub_section,
             'Contract' entity,
             sum(poue.unrealized_pnl_in_base_cur) pnl,
             poue.base_cur_id pnl_cur_id,
             poue.base_cur_code pnl_cur_code,
             (case
               when nvl(poue.approval_status, 'NA') = 'Pending Approval' then
                'Y'
               else
                'N'
             end) is_pending_approval,
             poue.product_id,
             poue.product_name
        from poue_phy_open_unreal_element poue
       where poue.corporate_id = pc_corporate_id
         and poue.process_id = pc_process_id
         and poue.unrealized_type in ('Unrealized','Realized Not Final Invoiced')
       group by poue.corporate_id,
                poue.corporate_name,
                poue.profit_center_id,
                poue.profit_center_name,
                poue.profit_center_short_name,
                poue.base_cur_id,
                poue.base_cur_code,
                poue.approval_status,
                poue.product_id,
                poue.product_name
      -----
      union all
      ---------- record physical stock unrealized for element
      select psue.corporate_id,
             akc.corporate_name,
             pc_process_id,
             cpc.profit_center_id,
             cpc.profit_center_short_name,
             cpc.profit_center_name,
             'Physical' as main_section,
             'Unrealized' as sub_section,
             'Stock' entity,
             sum(psue.pnl_in_base_cur),
             psue.base_cur_id,
             psue.base_cur_code,
             'N',
             psue.product_id,
             psue.product_name
        from psue_phy_stock_unrealized_ele psue,
             ak_corporate                  akc,
             -- psci_phy_stock_contract_item  psci
             cpc_corporate_profit_center cpc
       where psue.corporate_id = pc_corporate_id
         and akc.corporate_id = psue.corporate_id
         and psue.profit_center_id = cpc.profit_center_id
         and psue.process_id = pc_process_id
         and psue.pnl_type in ('Unrealized')
       group by psue.corporate_id,
                akc.corporate_name,
                cpc.profit_center_id,
                cpc.profit_center_name,
                cpc.profit_center_short_name,
                psue.base_cur_id,
                psue.base_cur_code,
                psue.product_id,
                psue.product_name;
    ---------- 
    --
    -- record physical realized pnl
    --
    insert into pps_physical_pnl_summary
      (corporate_id,
       corporate_name,
       process_id,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       main_section,
       sub_section,
       entity,
       pnl,
       pnl_cur_id,
       pnl_cur_code,
       approval_status,
       product_id,
       product_name)
      select prd.corporate_id,
             prd.corporate_name,
             pc_process_id,
             prd.profit_center_id,
             prd.profit_center_short_name,
             prd.profit_center_name,
             'Physical' as main_section,
             'Realized' as sub_section,
             'Physical' entity,
             sum(case
                   when prd.realized_type in
                        ('Realized Today', 'Reverse Realized',
                         'Reversal of Special Settlements', 'Special Settlements') then
                    nvl(prd.realized_pnl, 0)
                   when prd.realized_type in ('Previously Realized Price fixed today',
                         'Previously Realized PNL Change') then
                    nvl(prd.realized_pnl, 0) - nvl(prd.prev_real_pnl, 0)
                   else
                    0
                 end),
             prd.base_cur_id,
             prd.base_cur_code,
             'N' is_pending_approval,
             prd.product_id,
             prd.product_name
        from prd_physical_realized_daily prd
       where prd.corporate_id = pc_corporate_id
         and prd.process_id = pc_process_id
       group by prd.corporate_id,
                prd.corporate_name,
                prd.profit_center_id,
                prd.profit_center_short_name,
                prd.profit_center_name,
                prd.base_cur_id,
                prd.base_cur_code,
                prd.product_id,
                prd.product_name;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_pnl_summary',
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
      commit;
  end;
 procedure sp_phy_purchase_accural(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_process_id   varchar2) as
  -- Cursor For main Loop Only For Non Pledge GMRS
    cursor cur_pur_accural is
    select * from patd_pa_temp_data t
    where t.corporate_id = pc_corporate_id
    and t.is_pledge ='N';  
  -- Cursor For main Loop Only For  Pledge GMRS
    cursor cur_pur_accural_pledge is
    select * from patd_pa_temp_data t
    where t.corporate_id = pc_corporate_id
    and t.is_pledge ='Y';  
-- Cursor For Price Update     
    cursor cur_pur_accural_temp is
    select * from patd_pa_temp_data t
    where t.corporate_id = pc_corporate_id;  
-- For TC/RC    
    cursor cur_pur_accural_tc_rc is
    select * from patd_pa_temp_data t
    where t.corporate_id = pc_corporate_id
    and t.payable_type <> 'Penalty'
    and t.is_pledge ='N';  
-- For Penalty
    cursor cur_pur_accural_penalty is
    select * from patd_pa_temp_data t
    where t.corporate_id = pc_corporate_id
    and t.payable_type = 'Penalty'
    and t.is_pledge ='N';  
    vn_grd_to_gmr_qty_conversion number;
    vn_gmr_treatment_charge      number;
    vn_gmr_refine_charge         number;
    vn_gmr_penality_charge       number;
    vn_gmr_price                 number;
    vc_gmr_price_untit_id        varchar2(15);
    vn_gmr_price_unit_weight     varchar2(15);
    vn_price_unit_weight_unit_id varchar2(15);
    vc_gmr_price_unit_cur_id     varchar2(10);
    vc_gmr_price_unit_cur_code   varchar2(10);
    vn_payable_amt_in_price_cur  number;
    vn_payable_amt_in_pay_cur    number;
    vc_price_cur_id              varchar2(15);
    vc_price_cur_code            varchar2(15);
    vn_cont_price_cur_id_factor  number;
    vn_cont_price_cur_decimals   number;
    vn_fx_rate_price_to_pay      number;
    vn_payable_qty               number;
    vc_payable_qty_unit_id       varchar2(15);
    vn_counter                   number :=0;
    vc_gmr_ref_no_for_price      varchar2(15);
    vn_log_counter               number;
    vn_base_currency_decimals    number;
    vc_corporate_name            varchar2(15);
    vc_base_cur_id               varchar2(15);
    vc_base_cur_code               varchar2(15);
      
  begin
  vn_log_counter := gvn_log_counter;
  select akc.corporate_name,
         cm.cur_id,
         cm.cur_code,
         cm.decimals
    into vc_corporate_name,
         vc_base_cur_id,
         vc_base_cur_code,
         vn_base_currency_decimals
    from ak_corporate       akc,
         cm_currency_master cm
   where akc.base_cur_id = cm.cur_id
     and akc.corporate_id = pc_corporate_id;
                
  delete from patd_pa_temp_data  t
  where t.corporate_id = pc_corporate_id;
  commit;
  vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'delete from patd_pa_temp_data over');

  sp_gather_stats('tsq_temp_stock_quality');
  sp_gather_stats('patd_pa_temp_data');
  vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'gather_stats for purchase accrual ends');
  
-- Payable and Returnable elements
  insert into patd_pa_temp_data
    (internal_gmr_ref_no,
     internal_grd_ref_no,
     gmr_ref_no,
     product_id,
     element_id,
     payable_qty,
     payable_qty_unit_id,
     assay_qty,
     assay_qty_unit_id,
     corporate_id,
     corporate_name,
     conc_product_id,
     conc_product_name,
     conc_quality_id,
     conc_quality_name,
     profit_center_id,
     profit_center_name,
     profit_center_short_name,
     process_id,
     contract_type,
     base_cur_id,
     base_cur_code,
     base_cur_decimal,
     element_name,
     payable_type,
     cp_id,
     counterparty_name,
     pay_cur_id,
     pay_cur_code,
     pay_cur_decimal,
     pcdi_id,
     pledge_stock_id,
     wet_qty,
     dry_qty,
     grd_qty_unit_id,
     ash_id,
     is_afloat,
     is_pledge,
     no_of_bags,
    internal_contract_ref_no,
    is_wns_created,
    is_invoiced,
    is_apply_container_charge,
    is_apply_freight_allowance,
    latest_internal_invoice_ref_no,
    no_of_sublots,
    shipped_qty,
    gmr_qty_unit_id,
    grd_to_gmr_qty_factor)
    select gmr.internal_gmr_ref_no,
           grd.internal_grd_ref_no,
           gmr.gmr_ref_no,
           grd.product_id,
           spq.element_id,
           spq.payable_qty,
           spq.qty_unit_id payable_qty_unit_id,
           spq.assay_content assay_qty,
           spq.qty_unit_id assay_qty_unit_id,
           gmr.corporate_id,
           vc_corporate_name corporate_name,
           grd.conc_product_id conc_product_id,
           grd.conc_product_name conc_product_name,
           grd.quality_id conc_quality_id,
           qat.quality_name conc_quality_name,
           grd.profit_center_id profit_center,
           grd.profit_center_name profit_center_name,
           grd.profit_center_short_name profit_center_short_name,
           pc_process_id process_id,
           gmr.contract_type contract_type,
           vc_base_cur_id base_cur_id,
           vc_base_cur_code base_cur_code,
           vn_base_currency_decimals base_cur_decimal,
           aml.attribute_name element_name,
           null payable_type,
           gmr.cp_id cp_id,
           gmr.cp_name counterparty_name,
           gmr.invoice_cur_id pay_cur_id,
           gmr.invoice_cur_code pay_cur_code,
           gmr.invoice_cur_decimals pay_cur_decimal,
           grd.pcdi_id pcdi_id,
           spq.pledge_stock_id,
           grd.qty wet_qty,
           grd.qty * asm.dry_wet_qty_ratio / 100 dry_qty,
           grd.qty_unit_id as dry_wet_qty_unit_id,
           spq.weg_avg_pricing_assay_id,
           grd.is_afloat,
           'N', -- This is Not Pledge Section Data
           nvl(grd.no_of_bags,0) no_of_bags,
           gmr.internal_contract_ref_no,
           decode(gmr.wns_status,'Completed','Y','N') is_wns_created,
           nvl(gmr.is_provisional_invoiced,'N') is_invoiced,
           nvl(gmr.is_apply_container_charge,'N'),
           nvl(gmr.is_apply_freight_allowance,'N'),
           gmr.latest_internal_invoice_ref_no,
           nvl(gmr.no_of_sublots,0),
           nvl(gmr.shipped_qty,0),
           gmr.qty_unit_id,
           1
      from gmr_goods_movement_record gmr,
           grd_goods_record_detail   grd,
           spq_stock_payable_qty     spq,
           qat_quality_attributes    qat,
           sac_stock_assay_content   sac,
           aml_attribute_master_list aml,
           ii_invoicable_item        ii,
           asm_assay_sublot_mapping  asm
     where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
       and grd.internal_grd_ref_no = spq.internal_grd_ref_no
       and spq.is_stock_split = 'N'
       and grd.status = 'Active'
       and grd.quality_id = qat.quality_id(+)
       and grd.internal_grd_ref_no = sac.internal_grd_ref_no
       and spq.element_id = aml.attribute_id
       and spq.element_id = sac.element_id
       and spq.weg_avg_pricing_assay_id = asm.ash_id
       and gmr.process_id = pc_process_id
       and grd.process_id = pc_process_id
       and gmr.internal_gmr_ref_no = ii.internal_gmr_ref_no
       and grd.internal_grd_ref_no = ii.stock_id
       and gmr.is_deleted = 'N'
       and gmr.is_internal_movement = 'N'
       and nvl(gmr.contract_type, 'NA') <> 'Tolling'
       and spq.process_id = pc_process_id
       and nvl(gmr.is_final_invoiced, 'N') = 'N';
  commit;
  vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        vn_log_counter,
                        'Insert patd_pa_temp_data 1 over');
  
  for cc in (select dipq.pcdi_id,
                    dipq.element_id,
                    dipq.qty_type
               from dipq_delivery_item_payable_qty dipq
              where dipq.process_id = pc_process_id
                and dipq.is_active = 'Y'
              group by dipq.pcdi_id,
                       dipq.element_id,
                       dipq.qty_type)
  loop
    update patd_pa_temp_data patd
       set patd.payable_type = cc.qty_type
     where patd.pcdi_id = cc.pcdi_id
       and patd.element_id = cc.element_id
       and patd.corporate_id = pc_corporate_id;
  end loop;
  commit;
  vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        vn_log_counter,
                        'update patd_pa_temp_data 3 payable_type');
  update patd_pa_temp_data patd
     set patd.payable_type = 'Payable'
   where patd.payable_type is null
     and patd.corporate_id = pc_corporate_id;
  commit;
  vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        vn_log_counter,
                        'update patd_pa_temp_data 3.1 payable_type');
  
        
-- Penalty Elements
  insert into patd_pa_temp_data
    (internal_gmr_ref_no,
     internal_grd_ref_no,
     gmr_ref_no,
     product_id,
     element_id,
     payable_qty,
     payable_qty_unit_id,
     assay_qty,
     assay_qty_unit_id,
     corporate_id,
     corporate_name,
     conc_product_id,
     conc_product_name,
     conc_quality_id,
     conc_quality_name,
     profit_center_id,
     profit_center_name,
     profit_center_short_name,
     process_id,
     contract_type,
     base_cur_id,
     base_cur_code,
     base_cur_decimal,
     element_name,
     payable_type,
     cp_id,
     counterparty_name,
     pay_cur_id,
     pay_cur_code,
     pay_cur_decimal,
     pcdi_id,
     pledge_stock_id,
     wet_qty,
     dry_qty,
     grd_qty_unit_id,
     ash_id,
     is_afloat,
     is_pledge,
     no_of_sublots,
     shipped_qty,
     gmr_qty_unit_id,
     grd_to_gmr_qty_factor)
   select gmr.internal_gmr_ref_no,
           grd.internal_grd_ref_no,
           gmr.gmr_ref_no,
           grd.product_id,
           pqca.element_id,
           null payable_qty,
           null payable_qty_unit_id,
           (case
             when rm.ratio_name = '%' then
              (pqca.typical * (case
             when pqca.is_deductible = 'Y' then
              grd.qty
             else
              grd.qty * (asm.dry_wet_qty_ratio / 100)
           end)) / 100 else(grd.qty * (asm.dry_wet_qty_ratio / 100) * 
           ucm.multiplication_factor
           * pqca.typical) end) assay_qty,
           (case
             when rm.ratio_name = '%' then
              grd.qty_unit_id
             else
              rm.qty_unit_id_numerator
           end) assay_qty_unit_id,
           gmr.corporate_id,
           vc_corporate_name,
           pcpd.product_id conc_product_id,
           pdm_conc.product_desc conc_product_name,
           grd.quality_id conc_quality_id,
           grd.quality_name conc_quality_name,
           pcpd.profit_center_id profit_center,
           grd.profit_center_name,
           grd.profit_center_short_name,
           pc_process_id process_id,
           gmr.contract_type contract_type,
           vc_base_cur_id as base_cur_id,
           vc_base_cur_code base_cur_code,
           vn_base_currency_decimals as base_cur_decimal,
           aml.attribute_name element_name,
           'Penalty' payable_type,
           pcm.cp_id,
           pcm.cp_name counterparty_name,
           pcm.invoice_currency_id pay_cur_id,
           pcm.invoice_cur_code pay_cur_code,
           pcm.invoice_cur_decimals pay_cur_decimal,
           pci.pcdi_id,
           null pledge_stock_id,
           grd.qty wet_qty,
           grd.qty * asm.dry_wet_qty_ratio /100 dry_qty,
           grd.qty_unit_id as dry_wet_qty_unit_id,
           grd.weg_avg_pricing_assay_id,
           grd.is_afloat,
           'N',-- This is Not Pledge Section Data
           nvl(gmr.no_of_sublots,0),
           gmr.shipped_qty,
           gmr.qty_unit_id,
           1
      from gmr_goods_movement_record   gmr,
           grd_goods_record_detail     grd,
           pcpd_pc_product_definition  pcpd,
           pdm_productmaster           pdm_conc,
           qum_quantity_unit_master    qum_pdm_conc,
           ash_assay_header            ash,
           asm_assay_sublot_mapping    asm,
           pqca_pq_chemical_attributes pqca,
           rm_ratio_master             rm,
           pcm_physical_contract_main  pcm,
           ii_invoicable_item          ii,
           pci_physical_contract_item  pci,
           aml_attribute_master_list   aml,
           ucm_unit_conversion_master ucm
     where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
       and grd.status = 'Active'
       and gmr.process_id = pc_process_id
       and grd.process_id = pc_process_id
       and gmr.is_deleted = 'N'
       and gmr.is_internal_movement = 'N'
       and gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no
       and pcpd.input_output = 'Input'
       and pcpd.process_id = pc_process_id
       and pcpd.is_active = 'Y'
       and pcpd.product_id = pdm_conc.product_id
       and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
       and grd.weg_avg_pricing_assay_id = ash.ash_id
       and ash.ash_id = asm.ash_id
       and asm.asm_id = pqca.asm_id
       and pqca.is_elem_for_pricing = 'N'
       and pqca.unit_of_measure = rm.ratio_id
       and rm.is_active = 'Y'
       and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pcm.process_id = pc_process_id
       and pcm.is_active = 'Y'
       and gmr.internal_gmr_ref_no = ii.internal_gmr_ref_no
       and grd.internal_grd_ref_no = ii.stock_id
       and pci.internal_contract_item_ref_no = grd.internal_contract_item_ref_no
       and pci.process_id = pc_process_id
       and pqca.element_id = aml.attribute_id
       and nvl(gmr.contract_type, 'NA') <> 'Tolling'
       and aml.is_active = 'Y'
       and nvl(gmr.is_final_invoiced, 'N') = 'N'
       and ucm.from_qty_unit_id = grd.qty_unit_id
       and ucm.to_qty_unit_id = (case when rm.ratio_name = '%' then ash.net_weight_unit
       else rm.qty_unit_id_denominator end);
     commit;
     vn_log_counter := vn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'Insert patd_pa_temp_data  2 over');

-- Pledge GMR here    
insert into patd_pa_temp_data
  (internal_gmr_ref_no,
   internal_grd_ref_no,
   gmr_ref_no,
   product_id,
   element_id,
   ash_id,
   payable_qty,
   payable_qty_unit_id,
   assay_qty,
   assay_qty_unit_id,
   dry_qty,
   wet_qty,
   grd_qty_unit_id,
   corporate_id,
   corporate_name,
   conc_product_id,
   conc_product_name,
   conc_quality_id,
   conc_quality_name,
   profit_center_id,
   profit_center_name,
   profit_center_short_name,
   process_id,
   contract_type,
   base_cur_id,
   base_cur_code,
   base_cur_decimal,
   element_name,
   payable_type,
   cp_id,
   counterparty_name,
   pay_cur_id,
   pay_cur_code,
   pay_cur_decimal,
   pcdi_id,
   pledge_stock_id,
   is_afloat,
   is_pledge,
   supp_internal_gmr_ref_no,
   supp_gmr_ref_no,
   gmr_qty_unit_id,
   grd_to_gmr_qty_factor)
  select grd.internal_gmr_ref_no,
         grd.internal_grd_ref_no,
         gmr.gmr_ref_no,
         gepd.product_id,
         gepd.element_id,
         null,
         grd.current_qty payable_qty,-- Base Metal Qty in Base Unit
         grd.qty_unit_id payable_qty_unit_id, -- Base Metal Unit
         0,
         null, -- assay_qty,
         null, -- assay_qty_unit_id,
         null, -- dry_qty,
         null, -- wet_qty,
         gmr.corporate_id,
         vc_corporate_name,
         grd.product_id, -- conc_product_id
         grd.product_name,-- conc_product_name
         grd.quality_id conc_quality_id,
         grd.quality_name conc_quality_name,
         grd.profit_center_id,
         grd.profit_center_name,
         grd.profit_center_short_name,
         pc_process_id,
         gmr.contract_type contract_type,
         vc_base_cur_id,
         vc_base_cur_code,
         vn_base_currency_decimals base_cur_decimal,
         gepd.element_name,
         gepd.element_type,
         gepd.supplier_cp_id cp_id,
         gepd.supplier_cp_name cp_name,
         gmr.invoice_cur_id pay_cur_id,
         gmr.invoice_cur_code pay_cur_code,
         gmr.invoice_cur_decimals pay_cur_decimal,
         grd.pcdi_id,
         null,--pledge_stock_id
         grd.is_afloat, -- Currently this flag will not be used in Pledge Section, Can use later if we want to biforcate data
         'Y',
         gepd.pledge_input_gmr supp_internal_gmr_ref_no,
         gepd.pledge_input_gmr_ref_no supp_gmr_ref_no,
         gmr.qty_unit_id,
         1
    from ii_invoicable_item             ii,
         grd_goods_record_detail        grd,
         gepd_gmr_element_pledge_detail gepd,
         gmr_goods_movement_record      gmr
   where ii.is_pledge = 'Y'
     and ii.stock_id = grd.internal_grd_ref_no
     and grd.internal_gmr_ref_no = gepd.internal_gmr_ref_no
     and ii.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     and gmr.process_id = pc_process_id
     and ii.is_active = 'Y'
     and grd.process_id = pc_process_id
     and gepd.process_id = pc_process_id
     and gepd.is_active = 'Y'
     and nvl(gmr.is_final_invoiced, 'N') = 'N';
     commit;                          
     vn_log_counter := vn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'Insert patd_pa_temp_data  3 over And Other Charge Calculation Start');
   sp_calc_freight_other_charge(pc_corporate_id,
                                    pd_trade_date,
                                    pc_process_id,
                                    'EOM')  ;
   vn_log_counter := vn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'Other Charge Calculation End');
--
-- Stock to GMR Quantity Conversion Factor
--
  for cur_grd_gmr_qty_conv in (select patd.grd_qty_unit_id,
                                      patd.gmr_qty_unit_id
                                 from patd_pa_temp_data patd
                                where patd.corporate_id = pc_corporate_id
                                  and patd.grd_qty_unit_id <>
                                      patd.gmr_qty_unit_id
                                group by patd.grd_qty_unit_id,
                                         patd.gmr_qty_unit_id)
  loop
    select ucm.multiplication_factor
      into vn_grd_to_gmr_qty_conversion
      from ucm_unit_conversion_master ucm
     where ucm.from_qty_unit_id = cur_grd_gmr_qty_conv.grd_qty_unit_id
       and ucm.to_qty_unit_id = cur_grd_gmr_qty_conv.gmr_qty_unit_id;
    update patd_pa_temp_data patd
       set patd.grd_to_gmr_qty_factor = vn_grd_to_gmr_qty_conversion
     where patd.grd_qty_unit_id = cur_grd_gmr_qty_conv.grd_qty_unit_id
       and patd.gmr_qty_unit_id = cur_grd_gmr_qty_conv.gmr_qty_unit_id
       and patd.corporate_id = pc_corporate_id;
  end loop;
  commit;
  vn_log_counter := vn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'GRD to GMR Qty Conversion Over');
                                                               
     -- On Temp Table Update the Price First, If it is Pledge GMR get the price from Supplier GMR
    for cur_pur_accural_temp_rows in cur_pur_accural_temp
    loop
    vn_base_currency_decimals := cur_pur_accural_temp_rows.base_cur_decimal;
    if cur_pur_accural_temp_rows.payable_type <> 'Penalty' then
    If cur_pur_accural_temp_rows.is_pledge ='N' Then
       vc_gmr_ref_no_for_price := cur_pur_accural_temp_rows.internal_gmr_ref_no;
    else
        vc_gmr_ref_no_for_price := cur_pur_accural_temp_rows.supp_internal_gmr_ref_no;
    end if;-- This is fine Pledge GMRs will always be Event Based
    
        begin
         select cgcp.contract_price,
                     cgcp.price_unit_id,
                     cgcp.price_unit_weight_unit_id,
                     cgcp.price_unit_cur_id,
                     cgcp.price_unit_cur_code
                into vn_gmr_price,
                     vc_gmr_price_untit_id,
                     vn_price_unit_weight_unit_id,
                     vc_gmr_price_unit_cur_id,
                     vc_gmr_price_unit_cur_code
                from cgcp_conc_gmr_cog_price cgcp
               where cgcp.internal_gmr_ref_no =
                     vc_gmr_ref_no_for_price
                 and cgcp.process_id = pc_process_id
                 and cgcp.element_id = cur_pur_accural_temp_rows.element_id;
        exception
          when others then
            begin
             select cccp.contract_price,
                 cccp.price_unit_id,
                 cccp.price_unit_weight_unit_id,
                 cccp.price_unit_cur_id,
                 cccp.price_unit_cur_code
            into vn_gmr_price,
                 vc_gmr_price_untit_id,
                 vn_price_unit_weight_unit_id,
                 vc_gmr_price_unit_cur_id,
                 vc_gmr_price_unit_cur_code
            from cccp_conc_contract_cog_price cccp
           where cccp.pcdi_id = cur_pur_accural_temp_rows.pcdi_id
             and cccp.process_id = pc_process_id
             and cccp.element_id = cur_pur_accural_temp_rows.element_id;
            exception
              when others then
                vn_gmr_price                 := null;
                vc_gmr_price_untit_id        := null;
                vn_price_unit_weight_unit_id := null;
                vc_gmr_price_unit_cur_id     := null;
                vc_gmr_price_unit_cur_code   := null;
            end;
          
        end;
        update patd_pa_temp_data t
           set t.gmr_price                     = vn_gmr_price,
               t.gmr_price_unit_id             = vc_gmr_price_untit_id,
               t.gmr_price_unit_weight_unit_id = vn_price_unit_weight_unit_id,
               t.gmr_price_unit_cur_id         = vc_gmr_price_unit_cur_id,
               t.gmr_price_unit_cur_code       = vc_gmr_price_unit_cur_code
         where t.internal_gmr_ref_no =
               cur_pur_accural_temp_rows.internal_gmr_ref_no
           and t.element_id = cur_pur_accural_temp_rows.element_id
           and t.process_id = pc_process_id;
        end if;
    end loop;
 commit;
 vn_log_counter := vn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'patd_pa_temp_data price updation over');    
--
-- Calcualte TC Now
-- TC has its Unit specified, if stock  weight unit is different convert stock quantity to TC weight unit         
-- 

for cur_pur_accural_temp_rows in cur_pur_accural_tc_rc loop
vn_counter := vn_counter + 1;
begin
  select case
           when getc.weight_type = 'Dry' then
            cur_pur_accural_temp_rows.dry_qty * ucm.multiplication_factor *
            getc.tc_value
           else
            cur_pur_accural_temp_rows.wet_qty * ucm.multiplication_factor *
            getc.tc_value
         end
    into vn_gmr_treatment_charge
    from getc_gmr_element_tc_charges getc,
         ucm_unit_conversion_master  ucm
   where getc.process_id = pc_process_id
     and getc.internal_gmr_ref_no = cur_pur_accural_temp_rows.internal_gmr_ref_no --
     and getc.internal_grd_ref_no = cur_pur_accural_temp_rows.internal_grd_ref_no --
     and getc.element_id = cur_pur_accural_temp_rows.element_id
     and ucm.from_qty_unit_id = cur_pur_accural_temp_rows.grd_qty_unit_id
     and ucm.to_qty_unit_id = getc.tc_weight_unit_id;
exception
  when others then
    vn_gmr_treatment_charge := 0;
end;
                                                                                                     
Update patd_pa_temp_data t
set t.tc_amt = vn_gmr_treatment_charge
where t.internal_gmr_ref_no =cur_pur_accural_temp_rows.internal_gmr_ref_no
and t.internal_grd_ref_no = cur_pur_accural_temp_rows.internal_grd_ref_no
and t.element_id =   cur_pur_accural_temp_rows.element_id 
and t.process_id = pc_process_id; 
if vn_counter = 100 then
      commit;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'PA TC',
                 'finished inserting 100');
      vn_counter := 0;
end if;
   
end loop;
commit;
vn_log_counter := vn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                  pd_trade_date,
                  pc_process_id,
                  vn_log_counter,
                  'TC updation over');    

--
-- Calcualte RC Now
--         
vn_counter :=0;
for cur_pur_accural_temp_rows in cur_pur_accural_tc_rc loop
vn_counter := vn_counter + 1;

begin
  select gerc.rc_value * ucm.multiplication_factor *
         cur_pur_accural_temp_rows.payable_qty
    into vn_gmr_refine_charge
    from gerc_gmr_element_rc_charges gerc,
         ucm_unit_conversion_master  ucm
   where gerc.process_id = pc_process_id
     and gerc.internal_gmr_ref_no = cur_pur_accural_temp_rows.internal_gmr_ref_no --
     and gerc.internal_grd_ref_no = cur_pur_accural_temp_rows.internal_grd_ref_no --
     and gerc.element_id = cur_pur_accural_temp_rows.element_id
     and ucm.from_qty_unit_id = cur_pur_accural_temp_rows.payable_qty_unit_id
     and ucm.to_qty_unit_id = gerc.rc_weight_unit_id;
exception
  when others then
    vn_gmr_refine_charge := 0;
end;
                                                                                                     
Update patd_pa_temp_data t
set t.rc_amt = vn_gmr_refine_charge
where t.internal_gmr_ref_no =cur_pur_accural_temp_rows.internal_gmr_ref_no
and t.internal_grd_ref_no = cur_pur_accural_temp_rows.internal_grd_ref_no
and t.element_id =   cur_pur_accural_temp_rows.element_id 
and t.process_id = pc_process_id;                                                      
if vn_counter = 100 then
      commit;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'PA RC',
                 'finished inserting 100');
      vn_counter := 0;
end if;
end loop;     
commit;
vn_log_counter := vn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                  pd_trade_date,
                  pc_process_id,
                  vn_log_counter,
                  'RC updation over');    
--
-- Calcualte Penalty Now
--        
vn_counter :=0;
for cur_pur_accural_temp_rows in cur_pur_accural_penalty loop
vn_counter := vn_counter +1;

begin
  select case
           when gepc.weight_type = 'Dry' then
            cur_pur_accural_temp_rows.dry_qty * ucm.multiplication_factor *
            gepc.pc_value
           else
            cur_pur_accural_temp_rows.wet_qty * ucm.multiplication_factor *
            gepc.pc_value
         end
    into vn_gmr_penality_charge
    from gepc_gmr_element_pc_charges gepc,
         ucm_unit_conversion_master  ucm
   where gepc.process_id = pc_process_id
     and gepc.internal_gmr_ref_no =
         cur_pur_accural_temp_rows.internal_gmr_ref_no --
     and gepc.internal_grd_ref_no =
         cur_pur_accural_temp_rows.internal_grd_ref_no --
     and gepc.element_id = cur_pur_accural_temp_rows.element_id
     and ucm.from_qty_unit_id = cur_pur_accural_temp_rows.grd_qty_unit_id
     and ucm.to_qty_unit_id = gepc.pc_weight_unit_id;
   update patd_pa_temp_data t
      set t.penalty_amt = vn_gmr_penality_charge
    where t.internal_gmr_ref_no =
          cur_pur_accural_temp_rows.internal_gmr_ref_no
      and t.internal_grd_ref_no =
          cur_pur_accural_temp_rows.internal_grd_ref_no
      and t.element_id = cur_pur_accural_temp_rows.element_id
      and t.process_id = pc_process_id;
exception
  when others then
    vn_gmr_penality_charge := 0;
end;
if vn_counter = 100 then
      commit;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'PA Penalty',
                 'finished inserting 100');
      vn_counter := 0;
end if;
end loop;  
commit;
vn_log_counter := vn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                  pd_trade_date,
                  pc_process_id,
                  vn_log_counter,
                  'Penalty updation over');                                                         
                             
    for cur_pur_accural_rows in cur_pur_accural
    loop
      vn_payable_qty := null;
      vc_payable_qty_unit_id := null;
      vn_gmr_price                 := null;
      vc_gmr_price_untit_id        := null;
      vn_price_unit_weight_unit_id := null;
      vc_gmr_price_unit_cur_id     := null;
      vc_gmr_price_unit_cur_code   := null;
      vn_payable_amt_in_price_cur  := null;
      vn_payable_amt_in_pay_cur    := null;
      vn_fx_rate_price_to_pay      := null;
      vn_gmr_treatment_charge      :=0;
      vn_gmr_penality_charge := 0;
      vn_gmr_refine_charge :=0;
      if cur_pur_accural_rows.payable_type <> 'Penalty' then
        
                vn_gmr_price                 := cur_pur_accural_rows.gmr_price;
                vc_gmr_price_untit_id        := cur_pur_accural_rows.gmr_price_unit_id;
                vn_price_unit_weight_unit_id := cur_pur_accural_rows.gmr_price_unit_weight_unit_id;
                vc_gmr_price_unit_cur_id     := cur_pur_accural_rows.gmr_price_unit_cur_id;
                vc_gmr_price_unit_cur_code   := cur_pur_accural_rows.gmr_price_unit_cur_code;
                pkg_general.sp_get_main_cur_detail(vc_gmr_price_unit_cur_id,
                                           vc_price_cur_id,
                                           vc_price_cur_code,
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
     --                                       
     -- Janna 29th Aug 2012
     -- If the element is pledged we do not want to show the payable qty and payable amount
     -- This element has to be shown seperately under Pledge GMR Section (Will be done later)
     --  
        If cur_pur_accural_rows.pledge_stock_id is null and cur_pur_accural_rows.payable_type ='Payable' then
            vn_payable_amt_in_price_cur := round((vn_gmr_price /
                                                 nvl(vn_gmr_price_unit_weight,
                                                      1)) *
                                                 (pkg_general.f_get_converted_quantity(cur_pur_accural_rows.conc_product_id,
                                                                                       cur_pur_accural_rows.payable_qty_unit_id,
                                                                                       vn_price_unit_weight_unit_id,
                                                                                       cur_pur_accural_rows.payable_qty)) *
                                                 vn_cont_price_cur_id_factor,
                                                 vn_cont_price_cur_decimals);
            begin
              select cet.exch_rate
                into vn_fx_rate_price_to_pay
                from cet_corporate_exch_rate cet
               where cet.corporate_id = pc_corporate_id
                 and cet.from_cur_id = vc_gmr_price_unit_cur_id
                 and cet.to_cur_id = cur_pur_accural_rows.pay_cur_id;
            exception
              when no_data_found then
              vn_fx_rate_price_to_pay := - 1;
            end;
            vn_payable_amt_in_pay_cur := round(vn_payable_amt_in_price_cur *
                                               vn_fx_rate_price_to_pay,
                                               cur_pur_accural_rows.pay_cur_decimal);
            vn_payable_qty := cur_pur_accural_rows.payable_qty;
            vc_payable_qty_unit_id := cur_pur_accural_rows.payable_qty_unit_id;
         elsif cur_pur_accural_rows.pledge_stock_id is null and cur_pur_accural_rows.payable_type ='Returnable' then
            vn_payable_qty := cur_pur_accural_rows.payable_qty;
            vc_payable_qty_unit_id := cur_pur_accural_rows.payable_qty_unit_id;            
         else
            vn_payable_qty := 0;
            vc_payable_qty_unit_id := cur_pur_accural_rows.assay_qty_unit_id;
         end if;
        
       vn_gmr_treatment_charge := cur_pur_accural_rows.tc_amt;
       vn_gmr_refine_charge :=cur_pur_accural_rows.rc_amt;
      end if;
      if cur_pur_accural_rows.payable_type = 'Penalty' then
          vn_gmr_penality_charge := cur_pur_accural_rows.penalty_amt;
             vn_payable_qty := 0;
             vc_payable_qty_unit_id := cur_pur_accural_rows.assay_qty_unit_id;
      else
           vn_gmr_penality_charge := 0;
      end if;
      
      insert into pa_purchase_accural
        (corporate_id,
         process_id,
         product_id,
         product_type,
         contract_type,
         cp_id,
         counterparty_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         element_id,
         element_name,
         payable_returnable_type,
         assay_content,
         assay_content_unit,
         payable_qty,
         payable_qty_unit_id,
         price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         fx_rate_price_to_pay,
         pay_in_cur_id,
         pay_in_cur_code,
         tcharges_amount,
         rcharges_amount,
         penalty_amount,
         payable_amt_price_ccy,
         payable_amt_pay_ccy,
         frightcharges_amount,
         othercharges_amount,
         is_afloat ,
         is_pledge)
      values
        (cur_pur_accural_rows.corporate_id,
         pc_process_id,
         cur_pur_accural_rows.product_id,
         cur_pur_accural_rows.conc_product_name,
         cur_pur_accural_rows.contract_type,
         cur_pur_accural_rows.cp_id,
         cur_pur_accural_rows.counterparty_name,
         cur_pur_accural_rows.gmr_ref_no,
         cur_pur_accural_rows.internal_gmr_ref_no,
         cur_pur_accural_rows.internal_grd_ref_no,
         cur_pur_accural_rows.element_id,
         cur_pur_accural_rows.element_name,
         cur_pur_accural_rows.payable_type,
         cur_pur_accural_rows.assay_qty,
         cur_pur_accural_rows.assay_qty_unit_id,
         vn_payable_qty,
         vc_payable_qty_unit_id,
         vn_gmr_price,
         vc_gmr_price_untit_id,
         vc_gmr_price_unit_cur_id,
         vc_gmr_price_unit_cur_code,
         vn_fx_rate_price_to_pay,
         cur_pur_accural_rows.pay_cur_id,
         cur_pur_accural_rows.pay_cur_code,
         vn_gmr_treatment_charge,
         vn_gmr_refine_charge,
         vn_gmr_penality_charge ,
         nvl(vn_payable_amt_in_price_cur, 0),
         nvl(vn_payable_amt_in_pay_cur, 0),
         0, -- Fright charges amount,
         0, -- Other charges amount    
         cur_pur_accural_rows.is_afloat,
         cur_pur_accural_rows.is_pledge
         );
    end loop;
    commit;
    vn_log_counter := vn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'sp_phy_purchase_accural Loop over');
                          

for cur_pur_accural_rows in cur_pur_accural_pledge
    loop
      vn_gmr_price                 := cur_pur_accural_rows.gmr_price;
      vc_gmr_price_untit_id        := cur_pur_accural_rows.gmr_price_unit_id;
      vn_price_unit_weight_unit_id := cur_pur_accural_rows.gmr_price_unit_weight_unit_id;
      vc_gmr_price_unit_cur_id     := cur_pur_accural_rows.gmr_price_unit_cur_id;
      vc_gmr_price_unit_cur_code   := cur_pur_accural_rows.gmr_price_unit_cur_code;
      
      pkg_general.sp_get_main_cur_detail(vc_gmr_price_unit_cur_id,
                                           vc_price_cur_id,
                                           vc_price_cur_code,
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
      vn_payable_amt_in_price_cur := round((vn_gmr_price /
                                                 nvl(vn_gmr_price_unit_weight,
                                                      1)) *
                                                 (pkg_general.f_get_converted_quantity(cur_pur_accural_rows.conc_product_id,
                                                                                       cur_pur_accural_rows.payable_qty_unit_id,
                                                                                       vn_price_unit_weight_unit_id,
                                                                                       cur_pur_accural_rows.payable_qty)) *
                                                 vn_cont_price_cur_id_factor,
                                                 vn_cont_price_cur_decimals);
      begin
      select cet.exch_rate
        into vn_fx_rate_price_to_pay
        from cet_corporate_exch_rate cet
       where cet.corporate_id = pc_corporate_id
         and cet.from_cur_id = vc_gmr_price_unit_cur_id
         and cet.to_cur_id = cur_pur_accural_rows.pay_cur_id;
      exception
      when others then
      vn_fx_rate_price_to_pay :=-1;
      end;   
      vn_payable_amt_in_pay_cur := round(vn_payable_amt_in_price_cur *
                                               vn_fx_rate_price_to_pay,
                                               cur_pur_accural_rows.pay_cur_decimal);
      vn_payable_qty := cur_pur_accural_rows.payable_qty;
      vc_payable_qty_unit_id := cur_pur_accural_rows.payable_qty_unit_id;
         
      insert into pa_purchase_accural
        (corporate_id,
         process_id,
         product_id,
         product_type,
         contract_type,
         cp_id,
         counterparty_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         element_id,
         element_name,
         payable_returnable_type,
         assay_content,
         assay_content_unit,
         payable_qty,
         payable_qty_unit_id,
         price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         fx_rate_price_to_pay,
         pay_in_cur_id,
         pay_in_cur_code,
         payable_amt_price_ccy,
         payable_amt_pay_ccy,
         frightcharges_amount,
         othercharges_amount,
         is_afloat ,
         is_pledge,
         supp_internal_gmr_ref_no,
         supp_gmr_ref_no)
      values
        (cur_pur_accural_rows.corporate_id,
         pc_process_id,
         cur_pur_accural_rows.product_id,
         cur_pur_accural_rows.conc_product_name,
         cur_pur_accural_rows.contract_type,
         cur_pur_accural_rows.cp_id,
         cur_pur_accural_rows.counterparty_name,
         cur_pur_accural_rows.gmr_ref_no,
         cur_pur_accural_rows.internal_gmr_ref_no,
         cur_pur_accural_rows.internal_grd_ref_no,
         cur_pur_accural_rows.element_id,
         cur_pur_accural_rows.element_name,
         cur_pur_accural_rows.payable_type,
         cur_pur_accural_rows.assay_qty,
         cur_pur_accural_rows.assay_qty_unit_id,
         vn_payable_qty,
         vc_payable_qty_unit_id,
         vn_gmr_price,
         vc_gmr_price_untit_id,
         vc_gmr_price_unit_cur_id,
         vc_gmr_price_unit_cur_code,
         vn_fx_rate_price_to_pay,
         cur_pur_accural_rows.pay_cur_id,
         cur_pur_accural_rows.pay_cur_code,
         nvl(vn_payable_amt_in_price_cur, 0),
         nvl(vn_payable_amt_in_pay_cur, 0),
         0, -- Fright charges amount,
         0, -- Other charges amount    
         cur_pur_accural_rows.is_afloat,
         cur_pur_accural_rows.is_pledge,
         cur_pur_accural_rows.supp_internal_gmr_ref_no,
         cur_pur_accural_rows.supp_gmr_ref_no);
    end loop;
-- End Loop for Pledge GMRs                  
delete from pa_temp 
where  corporate_id = pc_corporate_id;
commit;   
vn_log_counter := vn_log_counter + 1;
   sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'sp_phy_purchase_accural Loop pa_temp1');                      

-- Payable Quantity For Concentrates                          
insert into pa_temp
  (internal_gmr_ref_no,
   internal_grd_ref_no,
   internal_contract_ref_no,
   gmr_ref_no,
   corporate_id,
   product_id,
   quality_id,
   profit_center_id,
   invoice_currency_id,
   element_id,
   contract_type,
   assay_qty,
   assay_qty_unit,
   payble_qty,
   payable_qty_unit,
   element_payable_amount,
   tcharges_amount,
   rcharges_amount,
   penalty_amount,
   latest_internal_invoice_ref_no,
   invoice_ref_no,
   is_afloat,
   is_pledge)
select grd.internal_gmr_ref_no,
       grd.internal_grd_ref_no,
       gmr.internal_contract_ref_no,
       gmr.gmr_ref_no,
       gmr.corporate_id,
       grd.product_id,
       grd.quality_id,
       grd.profit_center_id,
       iid.invoice_currency_id,
       iied.element_id,
       gmr.contract_type,
       0 assay_qty,
       (case
         when rm.ratio_name = '%' then
          ash.net_weight_unit
         else
          rm.qty_unit_id_numerator
       end) assay_qty_unit,
       iied.element_invoiced_qty payble_qty,
       iied.element_inv_qty_unit_id payable_qty_unit,
       iied.element_payable_amount,
       0 tcharges_amount,
       0 rcharges_amount,
       0 penalty_amount,
       gmr.latest_internal_invoice_ref_no,
       is1.invoice_ref_no,
       grd.is_afloat,
       'N'
  from gmr_goods_movement_record     gmr,
       grd_goods_record_detail       grd,
       iid_invoicable_item_details   iid,
       is_invoice_summary is1,
       iied_inv_item_element_details iied,
       iam_invoice_assay_mapping     iam,
       ash_assay_header              ash,
       asm_assay_sublot_mapping      asm,
       pqca_pq_chemical_attributes   pqca,
       rm_ratio_master               rm
 where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
   and grd.internal_grd_ref_no = iid.stock_id
   and iid.internal_invoice_ref_no = iied.internal_invoice_ref_no
   and iid.stock_id = iied.grd_id
   and iid.internal_invoice_ref_no = iam.internal_invoice_ref_no
   and iid.internal_invoice_ref_no = is1.internal_invoice_ref_no
   and gmr.latest_internal_invoice_ref_no = is1.internal_invoice_ref_no(+)
   and pc_process_id = is1.process_id(+)
   and iid.stock_id = iam.internal_grd_ref_no
   and iam.ash_id = ash.ash_id
   and ash.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and iied.element_id = pqca.element_id
   and pqca.unit_of_measure = rm.ratio_id
   and gmr.latest_internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
   and grd.process_id = pc_process_id
   and gmr.process_id = pc_process_id
   and gmr.is_deleted = 'N'
   and gmr.corporate_id = pc_corporate_id
   and nvl(gmr.contract_type,'NA') <> 'Tolling'
   and nvl(gmr.is_final_invoiced, 'N') = 'N';
commit;
vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'sp_phy_purchase_accural Loop pa_temp2');

-- Payable Quantity For Pledge GMRs
insert into pa_temp
  (internal_gmr_ref_no,
   internal_grd_ref_no,
   internal_contract_ref_no,
   gmr_ref_no,
   corporate_id,
   product_id,
   quality_id,
   profit_center_id,
   invoice_currency_id,
   element_id,
   contract_type,
   assay_qty,
   assay_qty_unit,
   payble_qty,
   payable_qty_unit,
   element_payable_amount,
   tcharges_amount,
   rcharges_amount,
   penalty_amount,
   latest_internal_invoice_ref_no,
   invoice_ref_no,
   is_afloat,
   is_pledge,
   supp_internal_gmr_ref_no,        
   supp_gmr_ref_no)
select grd.internal_gmr_ref_no,
       grd.internal_grd_ref_no,
       gmr.internal_contract_ref_no,
       gmr.gmr_ref_no,
       gmr.corporate_id,
       grd.product_id,
       grd.quality_id,
       grd.profit_center_id,
       iid.invoice_currency_id,
       gepd.element_id,
       gmr.contract_type,
       0 assay_qty,
       null assay_qty_unit,
       iid.invoiced_qty  payble_qty,
       grd.qty_unit_id payable_qty_unit_id,
       iid.invoice_item_amount,
       null tcharges_amount,
       null rcharges_amount,
       null penalty_amount,
       gmr.latest_internal_invoice_ref_no,
       gmr.invoice_ref_no,
       grd.is_afloat,
       'Y',-- Pledge
       gepd.pledge_input_gmr,
       gepd.pledge_input_gmr_ref_no
  from ii_invoicable_item             ii,
       iid_invoicable_item_details    iid,
       grd_goods_record_detail        grd,
       gepd_gmr_element_pledge_detail gepd,
       gmr_goods_movement_record      gmr
 where ii.is_pledge = 'Y'
   and ii.stock_id = grd.internal_grd_ref_no
   and grd.internal_gmr_ref_no = gepd.internal_gmr_ref_no
   and ii.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
  and gmr.process_id = pc_process_id
   and ii.is_active = 'Y'
   and grd.process_id = pc_process_id
   and gepd.process_id = pc_process_id
   and gepd.is_active = 'Y'
   and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
   and grd.internal_grd_ref_no = iid.stock_id
   and gmr.latest_internal_invoice_ref_no = iid.internal_invoice_ref_no
   and ii.invoicable_item_id = iid.invoicable_item_id
   and nvl(gmr.is_final_invoiced, 'N') = 'N';
   commit;
vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'sp_phy_purchase_accural Loop pa_temp2.1');   
--
-- assay qty
--
insert into pa_temp
  (internal_gmr_ref_no,
   internal_grd_ref_no,
   internal_contract_ref_no,
   gmr_ref_no,
   corporate_id,
   product_id,
   quality_id,
   profit_center_id,
   invoice_currency_id,
   element_id,
   contract_type,
   assay_qty,
   assay_qty_unit,
   payble_qty,
   payable_qty_unit,
   element_payable_amount,
   tcharges_amount,
   rcharges_amount,
   penalty_amount,
   latest_internal_invoice_ref_no,
   invoice_ref_no,
   is_afloat, 
   is_pledge)
select grd.internal_gmr_ref_no,
       grd.internal_grd_ref_no,
       gmr.internal_contract_ref_no,
       gmr.gmr_ref_no,
       gmr.corporate_id,
       grd.product_id,
       grd.quality_id,
       grd.profit_center_id,
       iid.invoice_currency_id,
       pqca.element_id,
       gmr.contract_type,
       (case
         when rm.ratio_name = '%' then
          (pqca.typical * asm.dry_weight) / 100
         else
          pkg_general.f_get_converted_quantity(aml.underlying_product_id,
                                               asm.net_weight_unit,
                                               rm.qty_unit_id_denominator,
                                               asm.dry_weight) *
          pqca.typical
       
       end) assay_qty,
       (case
         when rm.ratio_name = '%' then
          ash.net_weight_unit
         else
          rm.qty_unit_id_numerator
       end) assay_qty_unit,
       0 payble_qty,
       (case
         when rm.ratio_name = '%' then
          ash.net_weight_unit
         else
          rm.qty_unit_id_numerator
       end) payable_qty_unit,
       0 element_payable_amount,
       0 tcharges_amount,
       0 rcharges_amount,
       0 penalty_amount,
       gmr.latest_internal_invoice_ref_no,
       gmr.invoice_ref_no,
       grd.is_afloat,
       'N'
  from gmr_goods_movement_record   gmr,
       grd_goods_record_detail     grd,
       iid_invoicable_item_details iid,
       iam_invoice_assay_mapping   iam,
       ash_assay_header            ash,
       asm_assay_sublot_mapping    asm,
       pqca_pq_chemical_attributes pqca,
       rm_ratio_master             rm,
       aml_attribute_master_list   aml
 where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
   and grd.internal_grd_ref_no = iid.stock_id
   and iid.internal_invoice_ref_no = iam.internal_invoice_ref_no
   and iid.stock_id = iam.internal_grd_ref_no
   and iam.ash_id = ash.ash_id
   and ash.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pqca.element_id = aml.attribute_id
   and pqca.unit_of_measure = rm.ratio_id
   and gmr.latest_internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
   and grd.process_id = pc_process_id
   and gmr.process_id = pc_process_id
   and gmr.is_deleted = 'N'
   and nvl(gmr.contract_type,'NA') <> 'Tolling'
   and nvl(gmr.is_final_invoiced, 'N') = 'N';
  commit;
  vn_log_counter := vn_log_counter + 1;   
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'sp_phy_purchase_accural Loop pa_temp3');
--
-- Invoiced  GMR Level
--
 insert into pa_purchase_accural_gmr
   (corporate_id,
    process_id,
    eod_trade_date,
    product_id,
    product_type,
    contract_type,
    cp_id,
    counterparty_name,
    gmr_ref_no,
    element_id,
    element_name,
    payable_returnable_type,
    assay_content,
    assay_content_unit,
    payable_qty,
    payable_qty_unit_id,
    payable_amt_pay_ccy,
    pay_in_cur_id,
    pay_in_cur_code,
    tranascation_type,
    internal_gmr_ref_no,
    latest_internal_invoice_ref_no,
    invoice_ref_no,
    is_afloat,
    is_pledge,
    supp_internal_gmr_ref_no,        
    supp_gmr_ref_no)
   select temp.corporate_id,
          pc_process_id,
          pd_trade_date,
          temp.product_id,
          pdm_conc.product_desc,
          temp.contract_type,
          pcm.cp_id,
          pcm.cp_name,
          temp.gmr_ref_no,
          temp.element_id,
          aml.attribute_name,
          nvl(pcpch.payable_type, 'Penalty'),
          sum(temp.assay_qty) payable_qty,
          temp.assay_qty_unit assay_qty_unit,
          sum(temp.payble_qty) payable_qty,
          temp.payable_qty_unit payable_qty_unit_id,
          sum(temp.element_payable_amount) element_payable_amount,
          temp.invoice_currency_id,
          cm.cur_code,
          'Invoiced',
          temp.internal_gmr_ref_no,
          temp.latest_internal_invoice_ref_no,
          temp.invoice_ref_no,
          temp.is_afloat,
          temp.is_pledge,
          temp.supp_internal_gmr_ref_no,        
          temp.supp_gmr_ref_no
     from pa_temp temp,
          pdm_productmaster pdm_conc,
          cm_currency_master cm,
          aml_attribute_master_list aml,
          pcm_physical_contract_main pcm,
          (select pcp.internal_contract_ref_no,
                  pcp.element_id,
                  pcp.payable_type
             from pcpch_pc_payble_content_header pcp
            where pcp.process_id = pc_process_id
              and pcp.is_active = 'Y'
            group by pcp.internal_contract_ref_no,
                     pcp.element_id,
                     pcp.payable_type) pcpch
    where temp.product_id = pdm_conc.product_id
      and temp.corporate_id = pc_corporate_id
      and temp.element_id = aml.attribute_id
      and temp.invoice_currency_id = cm.cur_id
      and temp.internal_contract_ref_no = pcm.internal_contract_ref_no
      and temp.internal_contract_ref_no = pcpch.internal_contract_ref_no(+)
      and temp.element_id = pcpch.element_id(+)
      and pcm.process_id = pc_process_id
      and pcm.is_active = 'Y'
    group by temp.corporate_id,
             pc_process_id,
             temp.product_id,
             pdm_conc.product_desc,
             pcm.cp_id,
             temp.contract_type,
             pcm.cp_name,
             temp.gmr_ref_no,
             temp.element_id,
             aml.attribute_name,
             nvl(pcpch.payable_type, 'Penalty'),
             temp.invoice_currency_id,
             temp.payable_qty_unit,
             temp.assay_qty_unit,
             cm.cur_code,
             temp.internal_gmr_ref_no,
             temp.latest_internal_invoice_ref_no,
             temp.invoice_ref_no,
             temp.is_afloat,
             temp.is_pledge,
             temp.supp_internal_gmr_ref_no,        
             temp.supp_gmr_ref_no;
    commit;
    vn_log_counter := vn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'sp_phy_purchase_accural GMR Level');
--
-- Need to update Tc Charges,Rc Chargess, Penality
--
Update pa_purchase_accural_gmr pa_gmr
set (pa_gmr.tcharges_amount,--
     pa_gmr.rcharges_amount, --
     pa_gmr.penalty_amount
     ) =(--
select t.tc_amt, t.rc_amt, t.penalty_amt from tgc_temp_gmr_charges t
where t.corporate_id = pc_corporate_id
and t.internal_gmr_ref_no = pa_gmr.internal_gmr_ref_no
and t.internal_invoice_ref_no = pa_gmr.latest_internal_invoice_ref_no
AND t.element_id = pa_gmr.element_id)
where pa_gmr.process_id = pc_process_id
and pa_gmr.is_pledge ='N';
commit;
-- 
-- Frieght and Other charges we need to update only once per GMR, on Non Penalty Record
-- Where the sort order = 1 sort on Paybale Returnbale Type + Element Name
--
for cur_charges in
(
select is1.internal_invoice_ref_no,
       nvl(is1.freight_allowance_amt,0) /
       iid.gmr_count freight_allowance_amt,
       (nvl(is1.total_other_charge_amount, 0) -
       nvl(is1.freight_allowance_amt,0)) /
       iid.gmr_count total_other_charge_amount,
       iid.internal_gmr_ref_no
  from is_invoice_summary          is1,
       gmr_goods_movement_record   gmr,
       v_iid_invoice               iid
 where is1.process_id = pc_process_id
   and iid.internal_invoice_ref_no = is1.internal_invoice_ref_no
   and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and iid.internal_invoice_ref_no = gmr.latest_internal_invoice_ref_no
   and gmr.process_id = pc_process_id) loop

update pa_purchase_accural_gmr pa_gmr
   set pa_gmr.othercharges_amount  = cur_charges.total_other_charge_amount,
       pa_gmr.frightcharges_amount = case when pa_gmr.is_pledge = 'N' then cur_charges.freight_allowance_amt else 0 end
 where pa_gmr.process_id = pc_process_id
   and pa_gmr.internal_gmr_ref_no = cur_charges.internal_gmr_ref_no
   and pa_gmr.payable_returnable_type <> 'Penalty'
   and pa_gmr.payable_returnable_type||pa_gmr.element_id =
       (select min(pa_gmr_inn.payable_returnable_type||pa_gmr_inn.element_id)
          from pa_purchase_accural_gmr pa_gmr_inn
         where pa_gmr_inn.process_id = pc_process_id
           and pa_gmr_inn.internal_gmr_ref_no = cur_charges.internal_gmr_ref_no
           and pa_gmr.payable_returnable_type <> 'Penalty');
end loop;  
commit;
Update pa_purchase_accural_gmr pa_gmr
   set pa_gmr.provisional_pymt_pctg =
       (select is1.provisional_pymt_pctg from is_invoice_summary is1
       where is1.process_id = pc_process_id
       and is1.internal_invoice_ref_no = pa_gmr.latest_internal_invoice_ref_no)
 where pa_gmr.process_id = pc_process_id;        

commit;
vn_log_counter := vn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'sp_phy_purchase_accural Update TC and Others');

--
-- Calucalted Section GMR Leval             
--
    insert into pa_purchase_accural_gmr
      (corporate_id,
       process_id,
       eod_trade_date,
       product_id,
       product_type,
       contract_type,
       cp_id,
       counterparty_name,
       gmr_ref_no,
       element_id,
       element_name,
       payable_returnable_type,
       assay_content,
       assay_content_unit,
       payable_qty,
       payable_qty_unit_id,
       price,
       price_unit_id,
       price_unit_cur_id,
       price_unit_cur_code,
       pay_in_cur_id,
       pay_in_cur_code,
       payable_amt_price_ccy,
       payable_amt_pay_ccy,
       fx_rate_price_to_pay,
       tcharges_amount,
       rcharges_amount,
       penalty_amount,
       frightcharges_amount,
       othercharges_amount,
       tranascation_type,
       internal_gmr_ref_no,
       is_afloat,
       is_pledge,
       supp_internal_gmr_ref_no,        
       supp_gmr_ref_no)
      select pa.corporate_id,
             pc_process_id,
             pd_trade_date,
             pa.product_id,
             pa.product_type,
             pa.contract_type,
             pa.cp_id,
             pa.counterparty_name,
             pa.gmr_ref_no,
             pa.element_id,
             pa.element_name,
             pa.payable_returnable_type,
             sum(pa.assay_content),
             pa.assay_content_unit,
             sum(pa.payable_qty),
             pa.payable_qty_unit_id,
             pa.price,
             pa.price_unit_id,
             pa.price_unit_cur_id,
             pa.price_unit_cur_code,
             pa.pay_in_cur_id,
             pa.pay_in_cur_code,
             sum(pa.payable_amt_price_ccy),
             sum(pa.payable_amt_pay_ccy),
             pa.fx_rate_price_to_pay,
             round(sum(pa.tcharges_amount),vn_base_currency_decimals),
             round(sum(pa.rcharges_amount),vn_base_currency_decimals),
             round(sum(pa.penalty_amount),vn_base_currency_decimals),
             0, -- frightcharges_amount
             0, -- other_charges
             'Calculated',
             pa.internal_gmr_ref_no,
             pa.is_afloat,
             pa.is_pledge,
             pa.supp_internal_gmr_ref_no,        
             pa.supp_gmr_ref_no
        from pa_purchase_accural pa
       where pa.process_id = pc_process_id
         and pa.corporate_id = pc_corporate_id
       group by pa.corporate_id,
                pc_process_id,
                pa.product_id,
                pa.product_type,
                pa.contract_type,
                pa.cp_id,
                pa.counterparty_name,
                pa.gmr_ref_no,
                pa.element_id,
                pa.element_name,
                pa.payable_returnable_type,
                pa.assay_content_unit,
                pa.payable_qty_unit_id,
                pa.price,
                pa.price_unit_id,
                pa.price_unit_cur_id,
                pa.price_unit_cur_code,
                pa.pay_in_cur_id,
                pa.pay_in_cur_code,
                pa.fx_rate_price_to_pay,
                pa.internal_gmr_ref_no,
                pa.is_afloat,
                pa.is_pledge,
                pa.supp_internal_gmr_ref_no,        
                pa.supp_gmr_ref_no;
    commit;
    vn_log_counter := vn_log_counter + 1;
   sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'sp_phy_purchase_accural Calcualted GMR Level');
--
-- For calcualted section update freight and other charges once per GMR, on Non Penalty Record
-- Where the sort order = 1, sort on Paybale Returnbale Type + Element Name

for cur_calc_oc_fc in (select tgoc.internal_gmr_ref_no,
                            tgoc.small_lot_charge +
                            tgoc.container_charge + tgoc.sampling_charge +
                            tgoc.handling_charge + tgoc.location_value other_charges,
                            tgoc.freight_allowance freight_charges
                       from gfoc_gmr_freight_other_charge tgoc
                      where tgoc.process_id = pc_process_id)
loop
update pa_purchase_accural_gmr pa_gmr
   set pa_gmr.othercharges_amount  = -1 * cur_calc_oc_fc.other_charges,
       pa_gmr.frightcharges_amount = -1 * cur_calc_oc_fc.freight_charges
 where pa_gmr.process_id = pc_process_id
   and pa_gmr.internal_gmr_ref_no = cur_calc_oc_fc.internal_gmr_ref_no
   and pa_gmr.payable_returnable_type <> 'Penalty'
   and pa_gmr.tranascation_type = 'Calculated'
   and pa_gmr.payable_returnable_type || pa_gmr.element_id =
       (select min(pa_gmr_inn.payable_returnable_type ||
                   pa_gmr_inn.element_id)
          from pa_purchase_accural_gmr pa_gmr_inn
         where pa_gmr_inn.process_id = pc_process_id
           and pa_gmr_inn.internal_gmr_ref_no =
               cur_calc_oc_fc.internal_gmr_ref_no
           and pa_gmr_inn.payable_returnable_type <> 'Penalty'
           and pa_gmr_inn.tranascation_type = 'Calculated');
end loop;
commit;
  vn_log_counter := vn_log_counter + 1;
   sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'For calcualted section update freight and other charges');
--
-- Difference Section at GMR level
--
 insert into pa_purchase_accural_gmr
      (corporate_id,
       process_id,
       eod_trade_date,
       product_id,
       product_type,
       contract_type,
       cp_id,
       counterparty_name,
       gmr_ref_no,
       element_id,
       element_name,
       payable_returnable_type,
       assay_content,
       assay_content_unit,
       payable_qty,
       payable_qty_unit_id,
       tcharges_amount,
       rcharges_amount,
       penalty_amount,
       payable_amt_pay_ccy,
       payable_amt_price_ccy,
       pay_in_cur_id,
       pay_in_cur_code,
       frightcharges_amount,
       othercharges_amount,
       tranascation_type,
       internal_gmr_ref_no,
       is_afloat,
       is_pledge,
       supp_internal_gmr_ref_no,        
       supp_gmr_ref_no)
      select pa.corporate_id,
             pc_process_id,
             pd_trade_date,
             pa.product_id,
             pa.product_type,
             pa.contract_type,
             pa.cp_id,
             pa.counterparty_name,
             pa.gmr_ref_no,
             pa.element_id,
             pa.element_name,
             pa.payable_returnable_type,
             sum(case
                   when pa.tranascation_type = 'Calculated' then
                    pa.assay_content
                   else
                    0
                 end) - sum(case
                              when pa.tranascation_type = 'Invoiced' then
                               pa.assay_content
                              else
                               0
                            end) assay_content,
             pa.assay_content_unit,
             sum(case
                   when pa.tranascation_type = 'Calculated' then
                    pa.payable_qty
                   else
                    0
                 end) - sum(case
                              when pa.tranascation_type = 'Invoiced' then
                               pa.payable_qty
                              else
                               0
                            end) payable_qty,
             pa.payable_qty_unit_id,
             sum(case
                   when pa.tranascation_type = 'Calculated' then
                    pa.tcharges_amount
                   else
                    0
                 end) - sum(case
                              when pa.tranascation_type = 'Invoiced' then
                               pa.tcharges_amount
                              else
                               0
                            end) tcharges_amount,
             sum(case
                   when pa.tranascation_type = 'Calculated' then
                    pa.rcharges_amount
                   else
                    0
                 end) - sum(case
                              when pa.tranascation_type = 'Invoiced' then
                               pa.rcharges_amount
                              else
                               0
                            end) rcharges_amount,
             sum(case
                   when pa.tranascation_type = 'Calculated' then
                    pa.penalty_amount
                   else
                    0
                 end) - sum(case
                              when pa.tranascation_type = 'Invoiced' then
                               pa.penalty_amount
                              else
                               0
                            end) penalty_amount,
             sum(case
                   when pa.tranascation_type = 'Calculated' then
                    pa.payable_amt_pay_ccy
                   else
                    0
                 end) - sum(case
                              when pa.tranascation_type = 'Invoiced' then
                               pa.payable_amt_pay_ccy
                              else
                               0
                            end) payable_amount_pay_ccy,
             sum(case
                   when pa.tranascation_type = 'Calculated' then
                    pa.payable_amt_price_ccy
                   else
                    0
                 end) - sum(case
                              when pa.tranascation_type = 'Invoiced' then
                               pa.payable_amt_price_ccy
                              else
                               0
                            end) payable_amount_price_ccy,
             pa.pay_in_cur_id,
             pa.pay_in_cur_code,
             sum(case
                   when pa.tranascation_type = 'Calculated' then
                    pa.frightcharges_amount
                   else
                    0
                 end) - sum(case
                              when pa.tranascation_type = 'Invoiced' then
                               pa.frightcharges_amount
                              else
                               0
                            end) frightcharges_amount,
             sum(case
                   when pa.tranascation_type = 'Calculated' then
                    pa.othercharges_amount
                   else
                    0
                 end) - sum(case
                              when pa.tranascation_type = 'Invoiced' then
                               pa.othercharges_amount
                              else
                               0
                            end) othercharges_amount,
             'Difference',
             pa.internal_gmr_ref_no,
             pa.is_afloat,
             pa.is_pledge,
             pa.supp_internal_gmr_ref_no,        
             pa.supp_gmr_ref_no
        from pa_purchase_accural_gmr pa
       where pa.process_id = pc_process_id
       group by pa.corporate_id,
                pc_process_id,
                pa.product_id,
                pa.product_type,
                pa.contract_type,
                pa.cp_id,
                pa.counterparty_name,
                pa.gmr_ref_no,
                pa.element_id,
                pa.element_name,
                pa.payable_returnable_type,
                pa.assay_content_unit,
                pa.payable_qty_unit_id,
                pa.pay_in_cur_id,
                pa.pay_in_cur_code,
                pa.internal_gmr_ref_no,
                pa.is_afloat,
                pa.is_pledge,
                pa.supp_internal_gmr_ref_no,        
                pa.supp_gmr_ref_no;
commit;                
vn_log_counter := vn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'Pledge GMR Insertion into patd_pa_temp_data Over');
                  
-- Purchase Accrual update statements here
  for cc in (select gmr.internal_gmr_ref_no,
                    gmr.warehouse_profile_id,
                    gmr.warehouse_name companyname
               from gmr_goods_movement_record gmr
              where gmr.is_deleted = 'N'
                and gmr.process_id = pc_process_id)
  loop
    -- This update is for Non Pledge GMR
    update pa_purchase_accural_gmr pa
       set pa.warehouse_profile_id = cc.warehouse_profile_id,
           pa.warehouse_name       = cc.companyname
     where pa.internal_gmr_ref_no = cc.internal_gmr_ref_no
       and pa.process_id = pc_process_id;
       -- This update is for Pledge GMR
        update pa_purchase_accural_gmr pa
       set pa.warehouse_profile_id = cc.warehouse_profile_id,
           pa.warehouse_name       = cc.companyname
     where pa.supp_internal_gmr_ref_no = cc.internal_gmr_ref_no
       and pa.process_id = pc_process_id ;
  end loop;
  commit;
  for cc1 in (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.quality_name
                from grd_goods_record_detail grd
               where grd.process_id = pc_process_id
               group by grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.quality_name)
  loop
    update pa_purchase_accural_gmr pa
       set pa.quality_id   = cc1.quality_id,
           pa.quality_name = cc1.quality_name
     where pa.internal_gmr_ref_no = cc1.internal_gmr_ref_no
       and pa.process_id = pc_process_id;
  end loop;
commit;

  vn_log_counter := vn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'PA Quality Updation Over');

for cur_pledge_gmr_string in(
select gepd.pledge_input_gmr,
       f_string_aggregate(gmr.gmr_ref_no) pledged_gmr_ref_no_string
  from gepd_gmr_element_pledge_detail gepd,
       gmr_goods_movement_record      gmr
 where gepd.corporate_id = pc_corporate_id
   and gepd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gepd.is_active = 'Y'
   and gmr.process_id = pc_process_id
 group by gepd.pledge_input_gmr) loop
update pa_purchase_accural_gmr pa
   set pa.pledged_gmr_ref_nos = cur_pledge_gmr_string.pledged_gmr_ref_no_string
 where pa.internal_gmr_ref_no = cur_pledge_gmr_string.pledge_input_gmr;
end loop;
 commit;

  vn_log_counter := vn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'sp_phy_purchase_accural End');
 gvn_log_counter := vn_log_counter;                          
  end;  

  procedure sp_calc_overall_realized_pnl
  --------------------------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_calc_overall_realized_pnl
    --        author                                    : 
    --        created date                              : 
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
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    --Realized Today', 'Previously Realized PNL Change
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
       base_cur_code,
       base_qty_unit_id,
       base_cur_id,
       base_cur_decimals,
       base_qty_decimals,
       profit_center_name,
       profit_center_id,
       profit_center_short_name,
       customer_name,
       customer_id,
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
       alloc_group_name,
       internal_gmr_ref_no)
      select t.section_name,
             t.sub_section_name,
             t.section_id,
             t.order_id,
             t.cost_created_date,
             t.process_id,
             t.eod_date,
             t.corporate_id,
             t.corporate_name,
             t.base_qty_unit,
             t.base_currency_unit,
             t.base_qty_unit_id,
             t.base_currency_unit_id,
             2, -- t.base_currency_decimals,
             2, -- t.base_qty_decimals,
             t.books,
             t.book_id,
             t.book_short_name,
             t.customer_name,
             t.customer_id,
             t.journal_type,
             t.realization_date,
             t.transaction_ref_no,
             t.contract_ref_no,
             t.contract_details,
             t.cost_id,
             t.cost_name,
             t.price_fixation_status,
             t.current_qty,
             t.quantity_in_units,
             t.current_amount,
             t.previous_realized_qty,
             t.previous_realized_amount,
             t.month,
             t.transact_cur_id,
             t.transact_cur_code,
             2, -- t.transact_cur_decimals,
             t.transact_amount,
             t.internal_contract_item_ref_no,
             t.int_alloc_group_id,
             t.internal_stock_ref_no,
             t.alloc_group_name,
             t.internal_gmr_ref_no
        from (select (case
                       when prd.realized_type = 'Realized Today' then
                        'Realized on this Day'
                       when prd.realized_type = 'Special Settlements' then
                        'Special Settlements'
                       when prd.realized_type =
                            'Previously Realized PNL Change' then
                        'Change in PNL for Previously Realized Contracts'
                       else
                        'Others'
                     end) section_name,
                     decode(r, 1, 'Sales', 2, 'SS') sub_section_name,
                     (case
                       when prd.realized_type in
                            ('Realized Today', 'Special Settlements') then
                        1
                       else
                        2
                     end) section_id,
                     decode(r, 1, 1, 3) order_id,
                     prd.realized_date cost_created_date,
                     pc_process_id process_id,
                     pd_trade_date eod_date,
                     prd.corporate_id corporate_id,
                     prd.corporate_name corporate_name,
                     prd.base_qty_unit base_qty_unit,
                     prd.base_cur_code base_currency_unit,
                     prd.base_qty_unit_id base_qty_unit_id,
                     prd.base_cur_id base_currency_unit_id,
                     3 base_currency_decimals,
                     3 base_qty_decimals,
                     prd.profit_center_name books,
                     prd.profit_center_id book_id,
                     prd.profit_center_short_name book_short_name,
                     prd.cp_name customer_name,
                     prd.cp_profile_id customer_id,
                     'Sales' journal_type,
                     trunc(prd.realized_date) realization_date,
                     null transaction_ref_no, -- prd.invoice_ref_no
                     prd.alloc_group_name contract_ref_no,
                     (case
                       when prd.contract_type = 'S' then
                        prd.contract_ref_no
                       else
                        prd.gmr_ref_no
                     end) contract_details,
                     '' cost_id,
                     '' cost_name,
                     prd.price_fixation_status,
                     decode(r, 1, prd.item_qty_in_base_qty_unit, 2, 0) current_qty,
                     0 quantity_in_units,
                     (case
                       when prd.realized_type = 'Realized Today' then
                        decode(r,
                               1,
                               (prd.cog_net_sale_value+abs(prd.secondary_cost_value)),
                               2,
                              (-1)* abs(prd.secondary_cost_value))
                       when prd.realized_type = 'Special Settlements' then
                        decode(r,
                               1,
                               0, --prd.income_expense,
                               2,
                               abs(prd.secondary_cost_value))
                       else
                        decode(r,
                               1,
                               (prd.cog_net_sale_value+abs(prd.secondary_cost_value)),
                               2,
                              (-1) * abs(prd.secondary_cost_value))
                     end) current_amount,
                     pkg_general.f_get_converted_quantity(prd.product_id,
                                                          prd.prev_real_qty_id,
                                                          prd.base_qty_unit_id,
                                                          prd.prev_real_qty) previous_realized_qty,
                     decode(r,
                            1,
                      (prd.prev_real_cog_net_sale_value+abs(prd.secondary_cost_value)),
                            2,
                          -1 *  abs(prd.prev_real_secondary_cost)) previous_realized_amount,
                     cast(null as date) month,
                     '' transact_cur_id,
                     '' transact_cur_code,
                     3 transact_cur_decimals,
                     (case
                       when prd.realized_type = 'Realized Today' then
                        0
                       when prd.realized_type = 'Special Settlements' then
                        0 --prd.income_expense
                       else
                        0
                     end) transact_amount,
                     prd.internal_contract_item_ref_no,
                     prd.int_alloc_group_id,
                     prd.internal_stock_ref_no,
                     prd.alloc_group_name,
                     prd.internal_gmr_ref_no
                from prd_physical_realized_daily prd,
                     tdc_trade_date_closure tdc,
                     (select rownum r from all_objects where rownum <= 2)
               where prd.process_id = tdc.process_id
                 and prd.process_id = pc_process_id
                 and prd.contract_type = 'S'
                 and prd.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change',
                      'Special Settlements')
              
              union all
              
              select (case
                       when prd.realized_type = 'Realized Today' then
                        'Realized on this Day'
                       when prd.realized_type = 'Special Settlements' then
                        'Special Settlements'
                       when prd.realized_type =
                            'Previously Realized PNL Change' then
                        'Change in PNL for Previously Realized Contracts'
                       else
                        'Others'
                     end) section_name,
                     'COGS' sub_section_name,
                     (case
                       when prd.realized_type in
                            ('Realized Today', 'Special Settlements') then
                        1
                       else
                        2
                     end) section_id,
                     2 order_id,
                     prd.realized_date cost_created_date,
                     pc_process_id process_id,
                     pd_trade_date eod_date,
                     prd.corporate_id corporate_id,
                     prd.corporate_name corporate_name,
                     prd.base_qty_unit base_qty_unit,
                     prd.base_cur_code base_currency_unit,
                     prd.base_qty_unit_id base_qty_unit_id,
                     prd.base_cur_id base_currency_unit_id,
                     3 base_currency_decimals,
                     3 base_qty_decimals,
                     prd.profit_center_name books,
                     prd.profit_center_id book_id,
                     prd.profit_center_short_name book_short_name,
                     prd.cp_name customer_name,
                     prd.cp_profile_id customer_id,
                     'COGS' journal_type,
                     trunc(prd.realized_date) realization_date,
                     null transaction_ref_no, -- prd.invoice_ref_no
                     prd.alloc_group_name contract_ref_no,
                     (case
                       when prd.contract_type = 'S' then
                        prd.contract_ref_no
                       else
                        prd.gmr_ref_no
                     end) contract_details,
                     '' cost_id,
                     '' cost_name,
                     prd.price_fixation_status price_fixation_status,
                     sum(prd.item_qty_in_base_qty_unit) current_qty,
                     0 quantity_in_units,
                     (case
                       when prd.realized_type = 'Realized Today' then
                        sum(prd.cog_net_sale_value)
                       when prd.realized_type = 'Special Settlements' then
                        0 -- SUM(prd.income_expense)
                       else
                        sum(prd.cog_net_sale_value)
                     end) current_amount,
                     -- SUM(prd.cog_net_sale_value) current_amount,
                     sum(pkg_general.f_get_converted_quantity(prd.product_id,
                                                              prd.prev_real_qty_id,
                                                              prd.base_qty_unit_id,
                                                              prd.prev_real_qty)) previous_realized_qty,
                     sum(prd.prev_real_cog_net_sale_value) previous_realized_amount,
                     null month,
                     '' transact_cur_id,
                     '' transact_cur_code,
                     3 transact_cur_decimals,
                     (case
                       when prd.realized_type = 'Realized Today' then
                        0
                       when prd.realized_type = 'Special Settlements' then
                        0 -- prd.income_expense
                       else
                        0
                     end) transact_amount,
                     prd.internal_contract_item_ref_no,
                     prd.int_alloc_group_id,
                     prd.internal_stock_ref_no,
                     prd.alloc_group_name,
                     prd.internal_gmr_ref_no
                from prd_physical_realized_daily prd,
                     tdc_trade_date_closure      tdc
               where prd.process_id = tdc.process_id
                 and prd.process_id = pc_process_id
                 and prd.contract_type = 'P'
                 and prd.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change',
                      'Special Settlements')
               group by prd.realized_type,
                        prd.realized_date,
                        prd.corporate_id,
                        prd.corporate_name,
                        prd.base_qty_unit,
                        prd.base_cur_code,
                        prd.base_qty_unit_id,
                        prd.base_cur_id,
                        prd.profit_center_name,
                        prd.profit_center_id,
                        prd.profit_center_short_name,
                        prd.cp_name,
                        prd.cp_profile_id,
                        
                        prd.alloc_group_name,
                        (case
                          when prd.contract_type = 'S' then
                           prd.contract_ref_no
                          else
                           prd.gmr_ref_no
                        end),
                        prd.price_fixation_status,
                        (case
                          when prd.realized_type = 'Realized Today' then
                           0
                          when prd.realized_type = 'Special Settlements' then
                           0 --prd.income_expense
                          else
                           0
                        end),
                        prd.internal_contract_item_ref_no,
                        prd.int_alloc_group_id,
                        prd.internal_stock_ref_no,
                        prd.alloc_group_name,
                        prd.internal_gmr_ref_no              
              union all
              select 'Reverse Realized' section_name,
                     decode(r, 1, 'Sales', 2, 'SS') sub_section_name,
                     3 section_id,
                     decode(r, 1, 1, 3) order_id,
                     prd.realized_date cost_created_date,
                     pc_process_id process_id,
                     pd_trade_date eod_date,
                     prd.corporate_id corporate_id,
                     prd.corporate_name corporate_name,
                     prd.base_qty_unit base_qty_unit,
                     prd.base_cur_code base_currency_unit,
                     prd.base_qty_unit_id base_qty_unit_id,
                     prd.base_cur_id base_currency_unit_id,
                     3 base_currency_decimals,
                     3 base_qty_decimals,
                     prd.profit_center_name books,
                     prd.profit_center_id book_id,
                     prd.profit_center_short_name book_short_name,
                     prd.cp_name customer_name,
                     prd.cp_profile_id customer_id,
                     'Sales' journal_type,
                     trunc(prd.realized_date) realization_date,
                     null transaction_ref_no, --prd.invoice_ref_no
                     prd.alloc_group_name contract_ref_no,
                     (case
                       when prd.contract_type = 'S' then
                        prd.contract_ref_no
                       else
                        prd.gmr_ref_no
                     end) contract_details,
                     '' cost_id,
                     '' cost_name,
                     prd.price_fixation_status price_fixation_status,
                     decode(r, 1, prd.item_qty_in_base_qty_unit, 2, 0) current_qty,
                     0 quantity_in_units,
                     (case
                       when prd.realized_type = 'Realized Today' then
                        decode(r,
                               1,
                               prd.contract_invoice_value,
                               2,
                               prd.secondary_cost_value)
                       when prd.realized_type = 'Special Settlements' then
                        decode(r,
                               1,
                               0, --prd.income_expense,
                               2,
                               prd.secondary_cost_value)
                       else
                        decode(r,
                               1,
                               prd.contract_invoice_value,
                               2,
                               prd.secondary_cost_value)
                     end) current_amount,
                     pkg_general.f_get_converted_quantity(prd.product_id,
                                                          prd.prev_real_qty_id,
                                                          prd.base_qty_unit_id,
                                                          prd.prev_real_qty) previous_realized_qty,
                     decode(r,
                            1,
                            prd.prev_real_contract_value,
                            2,
                            prd.prev_real_secondary_cost) previous_realized_amount,
                     null month,
                     '' transact_cur_id,
                     '' transact_cur_code,
                     3 transact_cur_decimals,
                     (case
                       when prd.realized_type = 'Realized Today' then
                        0
                       when prd.realized_type = 'Special Settlements' then
                        0 --prd.income_expense
                       else
                        0
                     end) transact_amount,
                     prd.internal_contract_item_ref_no,
                     prd.int_alloc_group_id,
                     prd.internal_stock_ref_no,
                     prd.alloc_group_name,
                     prd.internal_gmr_ref_no
                from prd_physical_realized_daily prd,
                     tdc_trade_date_closure tdc,
                     (select rownum r from all_objects where rownum <= 2)
               where prd.process_id = tdc.process_id
                 and prd.process_id = pc_process_id
                 and prd.contract_type = 'S'
                 and prd.realized_type in
                     ('Reverse Realized', 'Reversal of Special Settlements')
              
              union all
              select 'Reverse Realized' section_name,
                     'COGS' sub_section_name,
                     3 section_id,
                     2 order_id,
                     prd.realized_date cost_created_date,
                     pc_process_id process_id,
                     pd_trade_date eod_date,
                     prd.corporate_id corporate_id,
                     prd.corporate_name corporate_name,
                     prd.base_qty_unit base_qty_unit,
                     prd.base_cur_code base_currency_unit,
                     prd.base_qty_unit_id base_qty_unit_id,
                     prd.base_cur_id base_currency_unit_id,
                     3 base_currency_decimals,
                     3 base_qty_decimals,
                     prd.profit_center_name books,
                     prd.profit_center_id book_id,
                     prd.profit_center_short_name book_short_name,
                     prd.cp_name customer_name,
                     prd.cp_profile_id customer_id,
                     'COGS' journal_type,
                     trunc(prd.realized_date) realization_date,
                     null transaction_ref_no, --prd.invoice_ref_no
                     prd.alloc_group_name contract_ref_no,
                     (case
                       when prd.contract_type = 'S' then
                        prd.contract_ref_no
                       else
                        prd.gmr_ref_no
                     end) contract_details,
                     '' cost_id,
                     '' cost_name,
                     prd.price_fixation_status price_fixation_status,
                     sum(prd.item_qty_in_base_qty_unit) current_qty,
                     0 quantity_in_units,
                     (case
                       when prd.realized_type = 'Realized Today' then
                        sum(abs(prd.cog_net_sale_value))
                       when prd.realized_type = 'Special Settlements' then
                        0 -- SUM(prd.income_expense)
                       else
                        sum(abs(prd.cog_net_sale_value))
                     end) current_amount,
                     --SUM(abs(prd.cog_net_sale_value)) current_amount,
                     sum(pkg_general.f_get_converted_quantity(prd.product_id,
                                                              prd.prev_real_qty_id,
                                                              prd.base_qty_unit_id,
                                                              prd.prev_real_qty)) previous_realized_qty,
                     sum(prd.prev_real_cog_net_sale_value) previous_realized_amount,
                     null month,
                     '' transact_cur_id,
                     '' transact_cur_code,
                     3 transact_cur_decimals,
                     (case
                       when prd.realized_type = 'Realized Today' then
                        0
                       when prd.realized_type = 'Special Settlements' then
                        0 --prd.income_expense
                       else
                        0
                     end) transact_amount,
                     prd.internal_contract_item_ref_no,
                     prd.int_alloc_group_id,
                     prd.internal_stock_ref_no,
                     prd.alloc_group_name,
                     prd.internal_gmr_ref_no
                from prd_physical_realized_daily prd,
                     tdc_trade_date_closure      tdc
               where prd.process_id = tdc.process_id
                 and prd.process_id = pc_process_id
                 and prd.contract_type = 'P'
                 and prd.realized_type in
                     ('Reverse Realized', 'Reversal of Special Settlements')
               group by prd.realized_date,
                        prd.realized_type,
                        prd.corporate_id,
                        prd.corporate_name,
                        prd.base_qty_unit,
                        prd.base_cur_code,
                        prd.base_qty_unit_id,
                        prd.base_cur_id,
                        prd.profit_center_name,
                        prd.profit_center_id,
                        prd.profit_center_short_name,
                        prd.cp_name,
                        prd.cp_profile_id,
                        
                        prd.alloc_group_name,
                        (case
                          when prd.contract_type = 'S' then
                           prd.contract_ref_no
                          else
                           prd.gmr_ref_no
                        end),
                        prd.price_fixation_status,
                        (case
                          when prd.realized_type = 'Realized Today' then
                           0
                          when prd.realized_type = 'Special Settlements' then
                           0 --prd.income_expense
                          else
                           0
                        end),
                        prd.internal_contract_item_ref_no,
                        prd.int_alloc_group_id,
                        prd.internal_stock_ref_no,
                        prd.internal_gmr_ref_no
              
              union all
              --Debit -- Credit Note--
              select 'Debit/Credit Note' section_name,
                     invs.invoice_type_name sub_section_name,
                     6 section_id,
                     1 order_id,
                     invs.invoice_issue_date cost_created_date,
                     pc_process_id process_id,
                     pd_trade_date eod_date,
                     invs.corporate_id corporate_id,
                     akc.corporate_name corporate_name,
                     '' base_qty_unit,
                     akc.base_currency_name base_currency_unit,
                     '' base_qty_unit_id,
                     cm_b.cur_id base_currency_unit_id,
                     cm_b.decimals base_currency_decimals,
                     0 base_qty_decimals,
                     cpc.profit_center_name books,
                     invs.profit_center_id book_id,
                     cpc.profit_center_short_name book_short_name,
                     phd.companyname customer_name,
                     invs.cp_id customer_id,
                     invs.invoice_type_name journal_type,
                     invs.invoice_issue_date realization_date,
                     invs.invoice_ref_no transaction_ref_no, -- Invoice Ref no
                     '-NA-' contract_ref_no, --GMR ref no
                     '-NA-' contract_details,
                     '-NA-' cost_id,
                     '-NA-' cost_name,
                     '' price_fixation_status,
                     0 current_qty,
                     0 quantity_in_units,
                     ((case
                       when invs.payable_receivable = 'Receivable' then  
                        1
                       else 
                        -1
                     end) * nvl(abs(invs.total_invoice_item_amount), 0) -
                     nvl(abs(invs.amount_paid), 0) * invs.fx_to_base) current_amount,
                     0 previous_realized_qty,
                     0 previous_realized_amount,
                     invs.invoice_issue_date month,
                     invs.invoice_cur_id transact_cur_id,
                     cm.cur_code transact_cur_code,
                     cm.decimals transact_cur_decimals,
                     nvl((invs.total_invoice_item_amount -
                         nvl((invs.amount_paid), 0)),
                         0) transact_amount,
                     null internal_contract_item_ref_no,
                     null int_alloc_group_id,
                     null internal_stock_ref_no,
                     null alloc_group_name,
                     null internal_gmr_ref_no
                from is_invoice_summary         invs,
                     iid_invoicable_item_details iid,
                     phd_profileheaderdetails   phd,
                     cm_currency_master         cm,
                     ak_corporate               akc,
                     cm_currency_master         cm_b,
                     --scm_service_charge_master    scm,
                     cpc_corporate_profit_center cpc
               where invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
                 and invs.invoice_type = 'DebitCredit'
                 and invs.invoice_type_name in
                     ('DebitCredit')
                 and invs.invoice_status in ( 'Active','Pending')
                 and invs.cp_id = phd.profileid
                 and cm.cur_id = invs.invoice_cur_id
                 and invs.corporate_id = akc.corporate_id
                 and akc.base_currency_name = cm_b.cur_code
                 and invs.profit_center_id = cpc.profit_center_id(+)
                 and invs.invoice_issue_date <= pd_trade_date
                 and invs.process_id = pc_process_id
                 and akc.corporate_id = pc_corporate_id
                 and iid.is_active = 'Y'
                 and invs.is_invoice_new = 'Y' --need to do this marking....
              
              union all
              select 'Debit/Credit Note' section_name,
                     invs.invoice_type_name sub_section_name,
                     6 section_id,
                     1 order_id,
                     invs.invoice_issue_date cost_created_date,
                     pc_process_id process_id,
                     pd_trade_date eod_date,
                     invs.corporate_id corporate_id,
                     akc.corporate_name corporate_name,
                     '' base_qty_unit,
                     akc.base_currency_name base_currency_unit,
                     '' base_qty_unit_id,
                     cm_b.cur_id base_currency_unit_id,
                     cm_b.decimals base_currency_decimals,
                     0 base_qty_decimals,
                     cpc.profit_center_name books,
                     invs.profit_center_id book_id,
                     cpc.profit_center_short_name book_short_name,
                     phd.companyname customer_name,
                     invs.cp_id customer_id,
                     invs.invoice_type_name journal_type,
                     invs.invoice_issue_date realization_date,
                     invs.invoice_ref_no transaction_ref_no, -- Invoice Ref no
                     '-NA-' contract_ref_no, --GMR ref no
                     '-NA-' contract_details,
                     '-NA-' cost_id,
                     '-NA-' cost_name,
                     '' price_fixation_status,
                     0 current_qty,
                     0 quantity_in_units,
                     ((case
                       when invs.payable_receivable = 'Receivable' then  
                        -1
                       else 
                        1
                     end) * nvl(abs(invs.total_invoice_item_amount), 0) -
                     nvl(abs(invs.amount_paid), 0) * invs.fx_to_base) current_amount,
                     0 previous_realized_qty,
                     0 previous_realized_amount,
                     invs.invoice_issue_date month,
                     invs.invoice_cur_id transact_cur_id,
                     cm.cur_code transact_cur_code,
                     cm.decimals transact_cur_decimals,
                     nvl((invs.total_invoice_item_amount -
                         nvl((invs.amount_paid), 0)),
                         0) transact_amount,
                     null internal_contract_item_ref_no,
                     null int_alloc_group_id,
                     null internal_stock_ref_no,
                     null     alloc_group_name,
                     null internal_gmr_ref_no
                from is_invoice_summary         invs,
                     iid_invoicable_item_details iid,
                     phd_profileheaderdetails   phd,
                     cm_currency_master         cm,
                     ak_corporate               akc,
                     cm_currency_master         cm_b,
                     --scm_service_charge_master    scm,
                     cpc_corporate_profit_center cpc
               where invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
                 and invs.invoice_type = 'DebitCredit'
                 and invs.invoice_type_name in
                     ('DebitCredit')
                 and invs.invoice_status in ('Cancelled')
                 and invs.cp_id = phd.profileid
                 and cm.cur_id = invs.invoice_cur_id
                 and invs.corporate_id = akc.corporate_id
                 and akc.base_currency_name = cm_b.cur_code
                 and invs.profit_center_id = cpc.profit_center_id(+)
                 and invs.invoice_issue_date <= pd_trade_date
                 and invs.process_id = pc_process_id
                 and akc.corporate_id = pc_corporate_id
                 and iid.is_active = 'N'
                 and invs.is_cancelled_today = 'Y' --need to do this marking...
              --Ends here
              union all
              select 'Miscellaneous Costs' section_name,
                     'Miscellaneous Costs' sub_section_name,
                     9 section_id,
                     1 order_id,
                     eodc.closed_date cost_created_date,
                     pc_process_id process_id,
                     pd_trade_date eod_date,
                     akc.corporate_id corporate_id,
                     akc.corporate_name corporate_name,
                     '' base_qty_unit,
                     akc.base_currency_name base_currency_unit,
                     '' base_qty_unit_id,
                     cm_b.cur_id base_currency_unit_id,
                     cm_b.decimals base_currency_decimals,
                     0 base_qty_decimals,
                     cpc.profit_center_name profit_center_name,
                     cpc.profit_center_id profit_center_id,
                     cpc.profit_center_short_name profit_center_short_name,
                     '' customer_name,
                     '' customer_id,
                     scm.cost_display_name journal_type,
                     eodc.closed_date realization_date,
                     '-NA-' transaction_ref_no, -- Invoice Ref no
                     '-NA-' contract_ref_no, --GMR ref no
                     '-NA-' contract_details,
                     scm.cost_id cost_id,
                     scm.cost_display_name cost_name,
                     '' price_fixation_status,
                     0 current_qty,
                     0 quantity_in_units,
                     nvl(to_number(eodcd.cost_value), 0) current_amount,
                     0 previous_realized_qty,
                     0 previous_realized_amount,
                     eodc.closed_date month,
                     eodcd.currency_id transact_cur_id,
                     cm.cur_code transact_cur_code,
                     cm.decimals transact_cur_decimals,
                     nvl(to_number(eodcd.cost_value), 0) transact_amount,
                     null internal_contract_item_ref_no,
                     null int_alloc_group_id,
                     null internal_stock_ref_no,
                     null  alloc_group_name,
                     null internal_gmr_ref_no
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
                 and tdc.process_id = pc_process_id
              --Ends here
              union all
              
              select 'General- Accruals' section_name,
                     'General-Original Accruals' sub_section_name,
                     10 section_id,
                     1 order_id,
                     cs.effective_date cost_created_date,
                     pc_process_id process_id,
                     pd_trade_date eod_date,
                     akc.corporate_id corporate_id,
                     akc.corporate_name corporate_name,
                     '' base_qty_unit,
                     akc.base_currency_name base_currency_unit,
                     '' base_qty_unit_id,
                     cm_b.cur_id base_currency_unit_id,
                     cm_b.decimals base_currency_decimals,
                     0 base_qty_decimals,
                     cpc.profit_center_name profit_center_name,
                     cpc.profit_center_id profit_center_id,
                     cpc.profit_center_short_name profit_center_short_name,
                     phd.companyname customer_name,
                     phd.profileid customer_id,
                     scm.cost_display_name journal_type,
                     cs.effective_date realization_date,
                     '-NA-' transaction_ref_no, -- Invoice Ref no
                     '-NA-' contract_ref_no, --GMR ref no
                     '-NA-' contract_details,
                     scm.cost_id cost_id,
                     scm.cost_display_name cost_name,
                     '' price_fixation_status,
                     0 current_qty,
                     0 quantity_in_units,
                     nvl(cs.base_amt, 0) current_amount, --* mc.transaction_amt_sign
                     0 previous_realized_qty,
                     0 previous_realized_amount,
                     cs.effective_date month,
                     cm.cur_id transact_cur_id,
                     cm.cur_code transact_cur_code,
                     cm.decimals transact_cur_decimals,
                     nvl(cs.transaction_amt, 0) transact_amount,
                     null internal_contract_item_ref_no,
                     null int_alloc_group_id,
                     null internal_stock_ref_no,
                     null alloc_group_name,
                     null internal_gmr_ref_no
                from cs_cost_store               cs,
                     cigc_contract_item_gmr_cost cigc,
                     pci_physical_contract_item  pci,
                     pcdi_pc_delivery_item       pcdi,
                     pcm_physical_contract_main  pcm,
                     pcpd_pc_product_definition  pcpd,
                     gmr_goods_movement_record   gmr,
                     scm_service_charge_master   scm,
                     cpc_corporate_profit_center cpc,
                     tdc_trade_date_closure      tdc,
                     ak_corporate                akc,
                     phd_profileheaderdetails    phd,
                     cm_currency_master          cm_b,
                     cm_currency_master          cm
               where cs.cog_ref_no = cigc.cog_ref_no
                 and cs.cost_component_id = scm.cost_id
                 and cs.base_amt_cur_id = cm_b.cur_id
                 and cs.transaction_amt_cur_id = cm.cur_id
                 and cigc.int_contract_item_ref_no =
                     pci.internal_contract_item_ref_no(+)
                 and pci.pcdi_id = pcdi.pcdi_id(+)
                 and pcpd.input_output = 'Input'
                 and gmr.internal_gmr_ref_no(+) = cigc.internal_gmr_ref_no
                 and pcm.internal_contract_ref_no(+) =
                     gmr.internal_contract_ref_no
                 and (case when cigc.int_contract_item_ref_no is null then
                      pcm.internal_contract_ref_no else
                      pcdi.internal_contract_ref_no end) =
                     pcpd.internal_contract_ref_no
                 and pcpd.profit_center_id = cpc.profit_center_id
                 and tdc.trade_date = pd_trade_date
                 and scm.reversal_type not in ('CONTRACT')
                 and cs.process_id = tdc.process_id
                 and (pci.process_id = tdc.process_id or
                     pci.process_id is null)
                 and (pcdi.process_id = tdc.process_id or
                     pcdi.process_id is null)
                 and cigc.process_id = tdc.process_id
                 and pcpd.process_id = tdc.process_id
                 and (gmr.process_id = tdc.process_id or
                     gmr.process_id is null)
                 and (pcm.process_id = tdc.process_id or
                     pcm.process_id is null)
                 and tdc.process_id = pc_process_id
                 and cpc.corporateid = pc_corporate_id
                 and cpc.corporateid = akc.corporate_id
                 and cs.is_deleted = 'N'
                 and cs.counter_party_id = phd.profileid(+)
              union all
              
              select 'General- Accruals' section_name,
                     'Actual without Accruals' sub_section_name,
                     10 section_id,
                     1 order_id,
                     cs.effective_date cost_created_date,
                     pc_process_id process_id,
                     pd_trade_date eod_date,
                     akc.corporate_id corporate_id,
                     akc.corporate_name corporate_name,
                     '' base_qty_unit,
                     akc.base_currency_name base_currency_unit,
                     '' base_qty_unit_id,
                     cm_b.cur_id base_currency_unit_id,
                     cm_b.decimals base_currency_decimals,
                     0 base_qty_decimals,
                     cpc.profit_center_name profit_center_name,
                     cpc.profit_center_id profit_center_id,
                     cpc.profit_center_short_name profit_center_short_name,
                     phd.companyname customer_name,
                     phd.profileid customer_id,
                     scm.cost_display_name journal_type,
                     cs.effective_date realization_date,
                     '-NA-' transaction_ref_no, -- Invoice Ref no
                     '-NA-' contract_ref_no, --GMR ref no
                     '-NA-' contract_details,
                     scm.cost_id cost_id,
                     scm.cost_display_name cost_name,
                     '' price_fixation_status,
                     0 current_qty,
                     0 quantity_in_units,
                     nvl(cs.base_amt, 0) current_amount, --* mc.transaction_amt_sign
                     0 previous_realized_qty,
                     0 previous_realized_amount,
                     cs.effective_date month,
                     cm.cur_id transact_cur_id,
                     cm.cur_code transact_cur_code,
                     cm.decimals transact_cur_decimals,
                     nvl(cs.transaction_amt, 0) transact_amount,
                     null internal_contract_item_ref_no,
                     null int_alloc_group_id,
                     null internal_stock_ref_no,
                     null alloc_group_name,
                     null internal_gmr_ref_no
                from cs_cost_store               cs,
                     cigc_contract_item_gmr_cost cigc,
                     pci_physical_contract_item  pci,
                     pcdi_pc_delivery_item       pcdi,
                     pcm_physical_contract_main  pcm,
                     pcpd_pc_product_definition  pcpd,
                     gmr_goods_movement_record   gmr,
                     scm_service_charge_master   scm,
                     cpc_corporate_profit_center cpc,
                     tdc_trade_date_closure      tdc,
                     ak_corporate                akc,
                     phd_profileheaderdetails    phd,
                     cm_currency_master          cm_b,
                     cm_currency_master          cm
               where cs.cog_ref_no = cigc.cog_ref_no
                 and cs.cost_component_id = scm.cost_id
                 and cs.base_amt_cur_id = cm_b.cur_id
                 and cs.transaction_amt_cur_id = cm.cur_id
                 and cigc.int_contract_item_ref_no =
                     pci.internal_contract_item_ref_no(+)
                 and pci.pcdi_id = pcdi.pcdi_id(+)
                 and pcpd.input_output = 'Input'
                 and gmr.internal_gmr_ref_no(+) = cigc.internal_gmr_ref_no
                 and pcm.internal_contract_ref_no =
                     gmr.internal_contract_ref_no
                 and (case when cigc.int_contract_item_ref_no is null then
                      pcm.internal_contract_ref_no else
                      pcdi.internal_contract_ref_no end) =
                     pcpd.internal_contract_ref_no
                 and pcpd.profit_center_id = cpc.profit_center_id
                 and tdc.trade_date = pd_trade_date
                 and cs.cost_type = 'Direct Actual'
                 and cs.process_id = tdc.process_id
                 and (pci.process_id = tdc.process_id or
                     pci.process_id is null)
                 and (pcdi.process_id = tdc.process_id or
                     pcdi.process_id is null)
                 and cigc.process_id = tdc.process_id
                 and pcpd.process_id = tdc.process_id
                 and (gmr.process_id = tdc.process_id or
                     gmr.process_id is null)
                 and (pcm.process_id = tdc.process_id or
                     pcm.process_id is null)
                 and tdc.process_id = pc_process_id
                 and cpc.corporateid = pc_corporate_id
                 and cpc.corporateid = akc.corporate_id
                 and cs.is_deleted = 'N'
                 and cs.counter_party_id = phd.profileid(+)
               union all  
                select 'Other Charges' section_name,
                       invs.invoice_type_name sub_section_name,
                       11 section_id,
                       1 order_id,
                       invs.invoice_issue_date cost_created_date,
                       pc_process_id process_id,
                       pd_trade_date eod_date,
                       invs.corporate_id corporate_id,
                       akc.corporate_name corporate_name,
                       '' base_qty_unit,
                       akc.base_currency_name base_currency_unit,
                       '' base_qty_unit_id,
                       cm_b.cur_id base_currency_unit_id,
                       cm_b.decimals base_currency_decimals,
                       0 base_qty_decimals,
                       cpc.profit_center_name books,
                       invs.profit_center_id book_id,
                       cpc.profit_center_short_name book_short_name,
                       phd.companyname customer_name,
                       invs.cp_id customer_id,
                       invs.invoice_type_name journal_type,
                       invs.invoice_issue_date realization_date,
                       invs.invoice_ref_no transaction_ref_no, -- Invoice Ref no
                       null contract_ref_no, --GMR ref no
                       '-NA-' contract_details,
                       scm.cost_id cost_id,
                       scm.cost_display_name cost_name,
                       '' price_fixation_status,
                       0 current_qty,
                       0 quantity_in_units,
                       ((case
                         when invs.payable_receivable = 'Receivable' then
                          1
                         else
                          -1
                       end) * ioc.amount_in_inv_cur * nvl(invs.fx_to_base, 1)) current_amount,
                       0 previous_realized_qty,
                       0 previous_realized_amount,
                       invs.invoice_issue_date month,
                       invs.invoice_cur_id transact_cur_id,
                       cm.cur_code transact_cur_code,
                       cm.decimals transact_cur_decimals,
                       nvl(ioc.flat_amount, 0) transact_amount,
                       null internal_contract_item_ref_no,
                       null int_alloc_group_id,
                       null internal_stock_ref_no,
                       null alloc_group_name,
                       null internal_gmr_ref_no
                  from is_invoice_summary          invs,
                       iid_invoicable_item_details iid,
                       ioc_invoice_other_charge    ioc,
                       scm_service_charge_master   scm,
                       phd_profileheaderdetails    phd,
                       cm_currency_master          cm,
                       ak_corporate                akc,
                       cm_currency_master          cm_b,
                       --scm_service_charge_master    scm,
                       cpc_corporate_profit_center cpc
                 where invs.internal_invoice_ref_no =
                       iid.internal_invoice_ref_no
                   and ioc.internal_invoice_ref_no =
                       invs.internal_invoice_ref_no
                   and ioc.other_charge_cost_id = scm.cost_id(+)
                   and invs.invoice_status in ('Active', 'Pending')
                   and invs.total_other_charge_amount is not null
                   and invs.cp_id = phd.profileid
                   and cm.cur_id(+) = invs.other_charge_amount_cur_id
                   and invs.corporate_id = akc.corporate_id
                   and akc.base_currency_name = cm_b.cur_code
                   and invs.profit_center_id = cpc.profit_center_id(+)
                   and invs.invoice_issue_date <= pd_trade_date
                   and invs.process_id = pc_process_id
                   and akc.corporate_id = pc_corporate_id
                   and iid.is_active = 'Y'
                   and invs.is_invoice_new = 'Y'
                union all
                select 'Other Charges' section_name,
                       invs.invoice_type_name || ' Cancelled' sub_section_name,
                       11 section_id,
                       1 order_id,
                       invs.invoice_issue_date cost_created_date,
                       pc_process_id process_id,
                       pd_trade_date eod_date,
                       invs.corporate_id corporate_id,
                       akc.corporate_name corporate_name,
                       '' base_qty_unit,
                       akc.base_currency_name base_currency_unit,
                       '' base_qty_unit_id,
                       cm_b.cur_id base_currency_unit_id,
                       cm_b.decimals base_currency_decimals,
                       0 base_qty_decimals,
                       cpc.profit_center_name books,
                       invs.profit_center_id book_id,
                       cpc.profit_center_short_name book_short_name,
                       phd.companyname customer_name,
                       invs.cp_id customer_id,
                       invs.invoice_type_name journal_type,
                       invs.invoice_issue_date realization_date,
                       invs.invoice_ref_no transaction_ref_no, -- Invoice Ref no
                       null contract_ref_no, --GMR ref no
                       '-NA-' contract_details,
                       scm.cost_id cost_id,
                       scm.cost_display_name cost_name,
                       '' price_fixation_status,
                       0 current_qty,
                       0 quantity_in_units,
                       ((case
                         when invs.payable_receivable = 'Receivable' then
                          -1
                         else
                          1
                       end) * ioc.amount_in_inv_cur * nvl(invs.fx_to_base, 1)) current_amount,
                       0 previous_realized_qty,
                       0 previous_realized_amount,
                       invs.invoice_issue_date month,
                       invs.invoice_cur_id transact_cur_id,
                       cm.cur_code transact_cur_code,
                       cm.decimals transact_cur_decimals,
                       nvl(invs.total_other_charge_amount, 0) transact_amount,
                       null internal_contract_item_ref_no,
                       null int_alloc_group_id,
                       null internal_stock_ref_no,
                       null alloc_group_name,
                       null internal_gmr_ref_no
                  from is_invoice_summary          invs,
                       iid_invoicable_item_details iid,
                       ioc_invoice_other_charge    ioc,
                       scm_service_charge_master   scm,
                       phd_profileheaderdetails    phd,
                       cm_currency_master          cm,
                       ak_corporate                akc,
                       cm_currency_master          cm_b,
                       --scm_service_charge_master    scm,
                       cpc_corporate_profit_center cpc
                 where invs.internal_invoice_ref_no =
                       iid.internal_invoice_ref_no
                   and ioc.internal_invoice_ref_no =
                       invs.internal_invoice_ref_no
                   and ioc.other_charge_cost_id = scm.cost_id(+)
                   and invs.invoice_status in ('Cancelled')
                   and invs.total_other_charge_amount is not null
                   and invs.cp_id = phd.profileid
                   and cm.cur_id(+) = invs.other_charge_amount_cur_id
                   and invs.corporate_id = akc.corporate_id
                   and akc.base_currency_name = cm_b.cur_code
                   and invs.profit_center_id = cpc.profit_center_id(+)
                   and invs.invoice_issue_date <= pd_trade_date
                   and invs.process_id = pc_process_id
                   and akc.corporate_id = pc_corporate_id
                   and iid.is_active = 'N'
                   and invs.is_cancelled_today = 'Y') t;
    --ends here
    
      for cc_upadte in (select ord.internal_gmr_ref_no,
                           iss.invoice_ref_no
                      from ord_overall_realized_pnl_daily ord,
                           gmr_goods_movement_record      gmr,
                           is_invoice_summary             iss
                     where ord.process_id = pc_process_id
                       and gmr.internal_gmr_ref_no = ord.internal_gmr_ref_no
                       and gmr.process_id = pc_process_id
                       and gmr.latest_internal_invoice_ref_no =
                           iss.internal_invoice_ref_no
                       and iss.process_id = pc_process_id)
  loop
    update ord_overall_realized_pnl_daily ord
       set ord.transaction_ref_no = cc_upadte.invoice_ref_no
     where ord.internal_gmr_ref_no = cc_upadte.internal_gmr_ref_no
       and ord.process_id = pc_process_id;    
  end loop;
  commit;

  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_overall_realized_pnl',
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
      commit;
  end;
  procedure sp_phy_intrstat(pc_corporate_id varchar2,
                            pd_trade_date   date,
                            pc_process      varchar2,
                            pc_process_id   varchar2) as
    vobj_error_log         tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count     number := 1;
    vc_previous_process_id varchar2(15);
    vc_base_cur_id         varchar2(15);
    vc_base_cur_code       varchar2(15);
    vn_exch_rate           number;
  begin
   
select akc.base_cur_id,
       akc.base_currency_name
  into vc_base_cur_id,
       vc_base_cur_code
  from ak_corporate akc
 where akc.corporate_id = pc_corporate_id;

    --
    -- Concentrates Non Event Based GMRS with Inventory
    --
 insert into isr1_isr_inventory
   (process_id,
    section_name,
    corporate_id,
    element_id,
    contract_ref_no,
    contract_ref_no_del_item_no,
    internal_gmr_ref_no,
    gmr_ref_no,
    internal_grd_ref_no,
    product_id,
    product_desc,
    cp_id,
    supplier_name,
    quality_id,
    quality_name,
    grd_qty,
    grd_dry_qty,
    grd_qty_unit_id,
    contract_price,
    contract_price_unit_id,
    contract_price_unit_cur_id,
    contract_price_unit_cur_code,
    shipment_date,
    invoice_date,
    loading_country_id,
    loading_country_name,
    loading_city_id,
    loading_city_name,
    loading_state_id,
    loading_state_name,
    loading_region_id,
    loading_region,
    discharge_country_id,
    discharge_country_name,
    discharge_city_id,
    discharge_city_name,
    discharge_state_id,
    discharge_state_name,
    discharge_region_id,
    discharge_region,
    mode_of_transport,
    bl_no,
    payable_qty_unit_id,
    payable_qty,
    loading_country_cur_id,
    loading_country_cur_code,
    discharge_country_cur_id,
    discharge_country_cur_code,
    base_cur_id,
    base_cur_code,
    price_to_base_exch_rate,
    base_to_load_country_ex_rate,
    base_to_disc_country_ex_rate,
    payable_qty_conv_factor,
    attribute_value,
    contract_type,
    export_date,
    import_date,
    incoterm_id,
    incoterm,
    no_of_containers)
   select /*+  ordered */
    pc_process_id process_id,
    'Concentrate Normal GMR',
    pc_corporate_id,
    spq.element_id,
    gmr.contract_ref_no,
    gmr.contract_ref_no || '-' || pcdi.delivery_item_no contract_ref_no_del_item_no,
    gmr.internal_gmr_ref_no,
    gmr.gmr_ref_no,
    grd.internal_grd_ref_no,
    pcpd.product_id,
    pcpd.product_name product_desc,
    gmr.cp_id,
    gmr.cp_name supplier_name,
    grd.quality_id,
    grd.quality_name,
    grd.qty qty,
    grd.dry_qty qty,
    grd.qty_unit_id,
    cccp.contract_price,
    cccp.price_unit_id,
    cccp.price_unit_cur_id,
    cccp.price_unit_cur_code,
    gmr.bl_date shipment_date,
    gmr.bl_date invoice_date,
    gmr.loading_country_id,
    gmr.loading_country_name loading_country_name,
    gmr.loading_city_id,
    gmr.loading_city_name,
    gmr.loading_state_id,
    gmr.loading_state_name,
    gmr.loading_region_id loading_region_id,
    gmr.loading_region_name loading_region,
    gmr.discharge_country_id,
    gmr.discharge_country_name,
    gmr.discharge_city_id,
    gmr.discharge_city_name,
    gmr.discharge_state_id,
    gmr.discharge_state_name,
    gmr.discharge_region_id,
    gmr.discharge_region_name,
    gmr.mode_of_transport,
    gmr.bl_no,
    spq.qty_unit_id,
    spq.payable_qty,
    gmr.loading_country_cur_id ,
    gmr.loading_country_cur_code,
    gmr.discharge_country_cur_id,
    gmr.discharge_country_cur_code,
    vc_base_cur_id,
    vc_base_cur_code,
    1 price_to_base_exch_rate,
    1 base_to_load_country_ex_rate,
    1 base_to_disc_country_ex_rate,
    ucm.multiplication_factor payable_qty_conv_factor,
    qat_ppm.attribute_value,
    gmr.gmr_type,
    gmr.loading_date export_date,
    gmr.eff_date import_date,
    pci.m2m_inco_term,
    pci.m2m_incoterm_desc incoterm,
    nvl(gmr.no_of_containers, 0)
     from pcdi_pc_delivery_item          pcdi,
          pci_physical_contract_item     pci,
          gmr_goods_movement_record      gmr,
          grd_goods_record_detail        grd,
          pcpd_pc_product_definition     pcpd,
          spq_stock_payable_qty          spq,
          cccp_conc_contract_cog_price   cccp,
          v_qat_ppm                      qat_ppm,
          v_ppu_pum                      ppu,
          poch_price_opt_call_off_header poch,
          pocd_price_option_calloff_dtls pocd,
          ucm_unit_conversion_master     ucm
    where gmr.internal_contract_ref_no = pcdi.internal_contract_ref_no
      and pcdi.pcdi_id = pci.pcdi_id
      and pci.internal_contract_item_ref_no =
          grd.internal_contract_item_ref_no
      and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
      and grd.is_mark_for_tolling = 'N'
      and gmr.is_deleted = 'N'
      and gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no
      and pcpd.input_output = 'Input'
      and pci.process_id = pc_process_id
      and pcdi.process_id = pc_process_id
      and gmr.process_id = pc_process_id
      and pcpd.process_id = pc_process_id
      and grd.process_id = pc_process_id
      and grd.status = 'Active'
      and spq.process_id = pc_process_id
      and spq.is_stock_split = 'N'
      and spq.internal_grd_ref_no = grd.internal_grd_ref_no
      and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      and spq.is_active = 'Y'
      and gmr.gmr_type = 'CONCENTRATES'
      and pcdi.is_active = 'Y'
      and pci.is_active = 'Y'
      and pcpd.is_active = 'Y'
      and cccp.process_id = pc_process_id
      and cccp.pcdi_id = pci.pcdi_id
      and spq.element_id = cccp.element_id
      and cccp.price_unit_id = ppu.product_price_unit_id
      and grd.quality_id = qat_ppm.quality_id
      and pcdi.pcdi_id = poch.pcdi_id
      and poch.poch_id = pocd.poch_id
      and spq.element_id = poch.element_id
         -- GMRS should not be event based nor Price Allocation
      and nvl(pocd.qp_period_type, 'NA') <> 'Event'
      and pcdi.price_allocation_method <> 'Price Allocation'
      and poch.is_active = 'Y'
      and pocd.is_active = 'Y'
      and gmr.loading_country_id <> gmr.discharge_country_id
      and ucm.from_qty_unit_id = spq.qty_unit_id
      and ucm.to_qty_unit_id = ppu.weight_unit_id
      and gmr.latest_internal_invoice_ref_no is null
      and 'TRUE' =
          (case when
           trunc(gmr.eff_date, 'Mon') = trunc(pd_trade_date, 'Mon') and
           gmr.eff_date is not null then 'TRUE' when
           trunc(gmr.loading_date, 'Mon') = trunc(pd_trade_date, 'Mon') and
           gmr.loading_date is not null then 'TRUE' else 'FALSE' end);

Commit;    
gvn_log_counter := gvn_log_counter + 1;
   sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'End of Concentrates Non Event Inventory');
   --
   -- Concentrate Event Based GMRs with Inventory
   --

insert into isr1_isr_inventory
  (process_id,
   section_name,
   corporate_id,
   element_id,
   contract_ref_no,
   contract_ref_no_del_item_no,
   internal_gmr_ref_no,
   gmr_ref_no,
   internal_grd_ref_no,
   product_id,
   product_desc,
   cp_id,
   supplier_name,
   quality_id,
   quality_name,
   grd_qty,
   grd_dry_qty,
   grd_qty_unit_id,
   contract_price,
   contract_price_unit_id,
   contract_price_unit_cur_id,
   contract_price_unit_cur_code,
   shipment_date,
   invoice_date,
   loading_country_id,
   loading_country_name,
   loading_city_id,
   loading_city_name,
   loading_state_id,
   loading_state_name,
   loading_region_id,
   loading_region,
   discharge_country_id,
   discharge_country_name,
   discharge_city_id,
   discharge_city_name,
   discharge_state_id,
   discharge_state_name,
   discharge_region_id,
   discharge_region,
   mode_of_transport,
   bl_no,
   payable_qty_unit_id,
   payable_qty,
   loading_country_cur_id,
   loading_country_cur_code,
   discharge_country_cur_id,
   discharge_country_cur_code,
   base_cur_id,
   base_cur_code,
   price_to_base_exch_rate,
   base_to_load_country_ex_rate,
   base_to_disc_country_ex_rate,
   payable_qty_conv_factor,
   attribute_value,
   contract_type,
   export_date,
   import_date,
   incoterm_id,
   incoterm,
   no_of_containers)
  select /*+ ordered */
   pc_process_id process_id,
   'Concentrate Event GMR',
   gmr.corporate_id,
   spq.element_id,
   gmr.contract_ref_no,
   gmr.contract_ref_no || '-' || pcdi.delivery_item_no contract_ref_no_del_item_no,
   gmr.internal_gmr_ref_no,
   gmr.gmr_ref_no,
   grd.internal_grd_ref_no,
   pcpd.product_id,
   pcpd.product_name product_desc,
   gmr.cp_id,
   gmr.cp_name supplier_name,
   grd.quality_id,
   grd.quality_name,
   grd.qty qty,
   grd.dry_qty qty,
   grd.qty_unit_id,
   cccp.contract_price,
   cccp.price_unit_id,
   cccp.price_unit_cur_id,
   cccp.price_unit_cur_code,
   gmr.bl_date shipment_date,
   gmr.bl_date invoice_date,
   gmr.loading_country_id,
   gmr.loading_country_name,
   gmr.loading_city_id,
   gmr.loading_city_name,
   gmr.loading_state_id,
   gmr.loading_state_name,
   gmr.loading_region_id,
   gmr.loading_region_name,
   gmr.discharge_country_id,
   gmr.discharge_country_name,
   gmr.discharge_city_id,
   gmr.discharge_city_name,
   gmr.discharge_state_id,
   gmr.discharge_state_name,
   gmr.discharge_region_id,
   gmr.discharge_region_name,
   gmr.mode_of_transport,
   gmr.bl_no,
   spq.qty_unit_id,
   spq.payable_qty,
   gmr.loading_country_cur_id,
   gmr.loading_country_cur_code,
   gmr.discharge_country_cur_id,
   gmr.discharge_country_cur_code,
   vc_base_cur_id,
   vc_base_cur_code,
   1 price_to_base_exch_rate,
   1 base_to_load_country_ex_rate,
   1 base_to_disc_country_ex_rate,
   ucm.multiplication_factor payable_qty_conv_factor,
   qat_ppm.attribute_value,
   gmr.gmr_type,
   gmr.loading_date export_date,
   gmr.eff_date import_date,
   pci.m2m_inco_term,
   pci.m2m_incoterm_desc incoterm,
   nvl(gmr.no_of_containers, 0)
    from pcdi_pc_delivery_item      pcdi,
         pci_physical_contract_item pci,
         gmr_goods_movement_record  gmr,
         grd_goods_record_detail    grd,
         pcpd_pc_product_definition pcpd,
         spq_stock_payable_qty      spq,
         cgcp_conc_gmr_cog_price    cccp,
         v_qat_ppm                  qat_ppm,
         v_ppu_pum                  ppu,
         ucm_unit_conversion_master ucm
   where gmr.internal_contract_ref_no = pcdi.internal_contract_ref_no
     and pcdi.pcdi_id = pci.pcdi_id
     and pci.internal_contract_item_ref_no =
         grd.internal_contract_item_ref_no
     and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and grd.is_mark_for_tolling = 'N'
     and gmr.is_deleted = 'N'
     and gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no
     and pcpd.input_output = 'Input'
     and pci.process_id = pc_process_id
     and pcdi.process_id = pc_process_id
     and gmr.process_id = pc_process_id
     and pcpd.process_id = pc_process_id
     and grd.process_id = pc_process_id
    and grd.status = 'Active'
     and spq.process_id = pc_process_id
     and spq.is_stock_split = 'N'
     and spq.internal_grd_ref_no = grd.internal_grd_ref_no
     and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     and spq.is_active = 'Y'
     and gmr.gmr_type = 'CONCENTRATES'
     and pcdi.is_active = 'Y'
     and pci.is_active = 'Y'
     and pcpd.is_active = 'Y'
    and cccp.process_id = pc_process_id
     and cccp.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     and spq.element_id = cccp.element_id
     and cccp.price_unit_id = ppu.product_price_unit_id
   --  and cccp.internal_grd_ref_no = grd.internal_grd_ref_no
     and grd.quality_id = qat_ppm.quality_id(+)
     and gmr.loading_country_id <> gmr.discharge_country_id
     and ucm.from_qty_unit_id = spq.qty_unit_id
     and ucm.to_qty_unit_id = ppu.weight_unit_id
     and gmr.latest_internal_invoice_ref_no is null
     and 'TRUE' =
         (case when trunc(gmr.eff_date, 'Mon') = trunc(pd_trade_date, 'Mon') and
          gmr.eff_date is not null then 'TRUE' when
          trunc(gmr.loading_date, 'Mon') = trunc(pd_trade_date, 'Mon') and
          gmr.loading_date is not null then 'TRUE' else 'FALSE' end);

commit;
gvn_log_counter := gvn_log_counter + 1;
   sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'End of Concentrates Event Inventory');
sp_gather_stats('ISR1_ISR_INVENTORY');

--
-- Price to Base Exchange Rate
-- 
for cur_price_to_base_rate in(
select isr1.contract_price_unit_cur_id,
       isr1.base_cur_id,
       isr1.shipment_date
  from isr1_isr_inventory isr1
 where isr1.process_id = pc_process_id
   and isr1.contract_price_unit_cur_id <> isr1.base_cur_id
 group by isr1.contract_price_unit_cur_id,
          isr1.base_cur_id,isr1.shipment_date) loop

select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                cur_price_to_base_rate.contract_price_unit_cur_id,
                                                cur_price_to_base_rate.base_cur_id,
                                                cur_price_to_base_rate.shipment_date,
                                                1)
  into vn_exch_rate
  from dual;
Update isr1_isr_inventory isr1
set isr1.price_to_base_exch_rate = vn_exch_rate
where  isr1.contract_price_unit_cur_id = cur_price_to_base_rate.contract_price_unit_cur_id
   and isr1.shipment_date = cur_price_to_base_rate.shipment_date
   and isr1.process_id = pc_process_id;
end loop;
commit;
--
-- Base to Loading Country Exchange Rate
--
for cur_load_to_base_rate in(
select isr1.loading_country_cur_id,
       isr1.base_cur_id,
       isr1.shipment_date
  from isr1_isr_inventory isr1
 where isr1.process_id = pc_process_id
and isr1.loading_country_cur_id <> isr1.base_cur_id
 group by isr1.loading_country_cur_id,
          isr1.base_cur_id,
          isr1.shipment_date) loop
select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                cur_load_to_base_rate.base_cur_id,
                                                cur_load_to_base_rate.loading_country_cur_id,
                                                cur_load_to_base_rate.shipment_date,
                                                1)
  into vn_exch_rate
  from dual;
Update isr1_isr_inventory isr1
set isr1.base_to_load_country_ex_rate = vn_exch_rate
where isr1.loading_country_cur_id = cur_load_to_base_rate.loading_country_cur_id
   and isr1.shipment_date = cur_load_to_base_rate.shipment_date
   and isr1.process_id = pc_process_id;  
end loop;          
commit;
--
-- Base to Discharge Country Exchange Rate
--
for cur_dis_to_base_rate in(
select isr1.discharge_country_cur_id,
       isr1.base_cur_id,
       isr1.shipment_date
  from isr1_isr_inventory isr1
 where isr1.process_id = pc_process_id
and isr1.discharge_country_cur_id <> isr1.base_cur_id
 group by isr1.discharGe_country_cur_id,
          isr1.base_cur_id,
          isr1.shipment_date) loop
select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                cur_dis_to_base_rate.base_cur_id,
                                                cur_dis_to_base_rate.discharge_country_cur_id,
                                                cur_dis_to_base_rate.shipment_date,
                                                1)
  into vn_exch_rate
  from dual;
Update isr1_isr_inventory isr1
set isr1.base_to_disc_country_ex_rate = vn_exch_rate
where isr1.discharge_country_cur_id = cur_dis_to_base_rate.discharge_country_cur_id
   and isr1.shipment_date = cur_dis_to_base_rate.shipment_date
   and isr1.process_id = pc_process_id;  
end loop;
commit;
gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Concentrates Inventory Conversion Over');
sp_gather_stats('ISR1_ISR_INVENTORY');                          
insert into isr_intrastat_grd
  (corporate_id,
   process_id,
   eod_trade_date,
   contract_ref_no,
   contract_item_ref_no,
   gmr_ref_no,
   internal_gmr_ref_no,
   product_id,
   product_name,
   cp_id,
   counterparty_name,
   quality_id,
   quality_name,
   qty,
   dry_qty,
   qty_unit_id,
   shipment_date,
   loading_country_id,
   loading_country_name,
   loading_city_id,
   loading_city_name,
   loading_state_id,
   loading_state_name,
   loading_region_id,
   loading_region_name,
   discharge_country_id,
   discharge_country_name,
   discharge_city_id,
   discharge_city_name,
   discharge_state_id,
   discharge_state_name,
   discharge_region_id,
   discharge_region_name,
   mode_of_transport,
   arrival_no,
   invoice_date,
   invoice_invenotry_status,
   invoice_invenotry_value,
   invoice_invenotry_cur_id,
   invoice_invenotry_cur_code,
   loading_country_cur_id,
   loading_country_cur_code,
   discharge_country_cur_id,
   discharge_country_cur_code,
   base_cur_id,
   base_cur_code,
   ex_rate_to_base,
   ex_rate_base_to_nat_load,
   ex_rate_base_to_nat_dis,
   comb_nome_item_code,
   contract_type,
   export_date,
   import_date,
   incoterm_id,
   incoterm,
   no_of_containers
   )
  select corporate_id,
       process_id,
       pd_trade_date,
       contract_ref_no,
       contract_ref_no_del_item_no,
       gmr_ref_no,
       internal_gmr_ref_no,
       product_id,
       product_desc,
       cp_id,
       supplier_name,
       quality_id,
       quality_name,
       sum(qty),
       sum(dry_qty),
       grd_qty_unit_id,
       shipment_date,
       loading_country_id,
       loading_country_name,
       loading_city_id,
       loading_city_name,
       loading_state_id,
       loading_state_name,
       loading_region_id,
       loading_region,
       discharge_country_id,
       discharge_country_name,
       discharge_city_id,
       discharge_city_name,
       discharge_state_id,
       discharge_state_name,
       discharge_region_id,
       discharge_region,
       mode_of_transport,
       bl_no,
       invoice_date,
       invoice_or_invenotry,
       sum(vvalue),
       base_cur_id,
       base_cur_code,
       loading_country_cur_id,
       loading_country_cur_code,
       discharge_country_cur_id,
       discharge_country_cur_code,
       base_cur_id,
       base_cur_code,
       price_to_base_exch_rate,
       base_to_load_country_ex_rate,
       base_to_disc_country_ex_rate,
       attribute_value,
       contract_type,
       export_date,
       import_date,
       incoterm_id,
       incoterm,
       no_of_containers
  from (select isr1.corporate_id,
               isr1.process_id,
               isr1.contract_ref_no,
               isr1.contract_ref_no_del_item_no,
               isr1.gmr_ref_no,
               isr1.internal_gmr_ref_no,
               isr1.product_id,
               isr1.product_desc,
               isr1.cp_id,
               isr1.supplier_name,
               isr1.quality_id,
               isr1.quality_name,
               case
                 when dense_rank() over(partition by isr1.internal_grd_ref_no
                           order by isr1.element_id) = 1 then
                  isr1.grd_qty
                 else
                  0
               end qty,
               (case
                 when dense_rank() over(partition by isr1.internal_grd_ref_no
                           order by isr1.element_id) = 1 then
                  isr1.grd_dry_qty
                 else
                  0
               end) dry_qty,
               isr1.grd_qty_unit_id,
               isr1.shipment_date,
               isr1.loading_country_id,
               isr1.loading_country_name,
               isr1.loading_city_id,
               isr1.loading_city_name,
               isr1.loading_state_id,
               isr1.loading_state_name,
               isr1.loading_region_id,
               isr1.loading_region,
               isr1.discharge_country_id,
               isr1.discharge_country_name,
               isr1.discharge_city_id,
               isr1.discharge_city_name,
               isr1.discharge_state_id,
               isr1.discharge_state_name,
               isr1.discharge_region_id,
               isr1.discharge_region,
               isr1.mode_of_transport,
               isr1.bl_no,
               isr1.invoice_date,
               'INVENTORY' invoice_or_invenotry,
               (isr1.payable_qty * isr1.payable_qty_conv_factor * 
               isr1.contract_price * isr1.price_to_base_exch_rate) vvalue,
               isr1.loading_country_cur_id,
               isr1.loading_country_cur_code,
               isr1.discharge_country_cur_id,
               isr1.discharge_country_cur_code,
               isr1.base_cur_id,
               isr1.base_cur_code,
               1 price_to_base_exch_rate, --Inventory section is in base currency, hence exchange rate is always 1
               isr1.base_to_load_country_ex_rate,
               isr1.base_to_disc_country_ex_rate,
               isr1.attribute_value,
               isr1.contract_type,
               isr1.export_date,
               isr1.import_date,
               isr1.incoterm_id,
               isr1.incoterm,
               isr1.no_of_containers
          from isr1_isr_inventory isr1
         where isr1.process_id = pc_process_id) t
group by corporate_id,
       process_id,
       contract_ref_no,
       contract_ref_no_del_item_no,
       gmr_ref_no,
       internal_gmr_ref_no,
       product_id,
       product_desc,
       cp_id,
       supplier_name,
       quality_id,
       quality_name,
       grd_qty_unit_id,
       shipment_date,
       loading_country_id,
       loading_country_name,
       loading_city_id,
       loading_city_name,
       loading_state_id,
       loading_state_name,
       loading_region_id,
       loading_region,
       discharge_country_id,
       discharge_country_name,
       discharge_city_id,
       discharge_city_name,
       discharge_state_id,
       discharge_state_name,
       discharge_region_id,
       discharge_region,
       mode_of_transport,
       bl_no,
       invoice_date,
       loading_country_cur_id,
       loading_country_cur_code,
       discharge_country_cur_id,
       discharge_country_cur_code,
       base_cur_id,
       base_cur_code,
       price_to_base_exch_rate,
       base_to_load_country_ex_rate,
       base_to_disc_country_ex_rate,
       attribute_value,
       contract_type,
       export_date,
       import_date,
       incoterm_id,
       incoterm,
       no_of_containers,
       invoice_or_invenotry;

    Commit;
gvn_log_counter := gvn_log_counter + 1;	
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Concentrates Inventory Insert into ISR Over'); 

--
-- Concentrates GMRS with Invoice
--
insert into isr2_isr_invoice
  (process_id,
   section_name,
   corporate_id,
   element_id,
   contract_ref_no,
   contract_ref_no_del_item_no,
   internal_gmr_ref_no,
   gmr_ref_no,
   product_id,
   product_desc,
   cp_id,
   supplier_name,
   quality_id,
   quality_name,
   grd_qty,
   grd_dry_qty,
   grd_qty_unit_id,
   shipment_date,
   invoice_date,
   loading_country_id,
   loading_country_name,
   loading_city_id,
   loading_city_name,
   loading_state_id,
   loading_state_name,
   loading_region_id,
   loading_region,
   discharge_country_id,
   discharge_country_name,
   discharge_city_id,
   discharge_city_name,
   discharge_state_id,
   discharge_state_name,
   discharge_region_id,
   discharge_region,
   mode_of_transport,
   bl_no,
   invoice_or_invenotry,
   product_price_unit_id,
   underlying_product_id,
   spq_qty_unit_id,
   under_product_base_qty_unit,
   payable_qty,
   loading_country_cur_id,
   loading_country_cur_code,
   dischagre_country_cur_id,
   dischagre_country_cur_code,
   base_cur_id,
   base_cur_code,
   base_to_load_country_ex_rate,
   base_to_disc_country_ex_rate,
   attribute_value,
   contract_type,
   export_date,
   import_date,
   invoice_amt,
   invoice_cur_id,
   invoice_cur_code,
   invoice_to_base_ex_rate,
   incoterm_id,
   incoterm,
   final_invoice_date,
   no_of_containers,
   internal_invoice_ref_no,
   invoice_ref_no,
   internal_grd_ref_no)
  select /*+  ordered */
   pc_process_id process_id,
   'Concentrates',
   gmr.corporate_id,
   spq.element_id,
   gmr.contract_ref_no,
   gmr.contract_ref_no || '-' || pcdi.delivery_item_no contract_ref_no_del_item_no,
   gmr.internal_gmr_ref_no,
   gmr.gmr_ref_no,
   pcpd.product_id,
   pcpd.product_name product_desc,
   gmr.cp_id,
   gmr.cp_name supplier_name,
   grd.quality_id,
   grd.quality_name,
   (grd.qty) qty,
   (grd.dry_qty) dry_qty,
   grd.qty_unit_id,
   gmr.bl_date shipment_date,
   tgi.invoice_issue_date invoice_date,
   gmr.loading_country_id,
   gmr.loading_country_name,
   gmr.loading_city_id,
   gmr.loading_city_name,
   gmr.loading_state_id,
   gmr.loading_state_name,
   gmr.loading_region_id,
   gmr.loading_region_name,
   gmr.discharge_country_id,
   gmr.discharge_country_name,
   gmr.discharge_city_id,
   gmr.discharge_city_name,
   gmr.discharge_state_id,
   gmr.discharge_state_name,
   gmr.discharge_region_id,
   gmr.discharge_region_name,
   gmr.mode_of_transport,
   gmr.bl_no,
   'INVOICE' invoice_or_invenotry,
   ppu.product_price_unit_id,
   aml.underlying_product_id,
   spq.qty_unit_id,
   pdm_aml.base_quantity_unit under_product_base_qty_unit,
   spq.payable_qty * ucm.multiplication_factor payable_qty,
   gmr.loading_country_cur_id,
   gmr.loading_country_cur_code,
   gmr.discharge_country_cur_id,
   gmr.discharge_country_cur_code,
   vc_base_cur_id base_cur_id,
   vc_base_cur_code base_cur_code,
   1 base_to_load_country_ex_rate,
   1 base_to_disc_country_ex_rate,
   qat_ppm.attribute_value,
   gmr.gmr_type,
   gmr.loading_date export_date,
   gmr.eff_date import_date,
   tgi.invoice_item_amount,
   tgi.invoice_cur_id,
   tgi.invoice_cur_code,
   1 invoice_to_base_ex_rate,
   pci.m2m_inco_term,
   pci.m2m_incoterm_desc,
   decode(gmr.is_final_invoiced, 'Y', tgi.invoice_issue_date, null) final_invoice_date,
   nvl(gmr.no_of_containers, 0) no_of_containers,
   tgi.internal_invoice_ref_no,
   tgi.invoice_ref_no,
   grd.internal_grd_ref_no
    from pcdi_pc_delivery_item      pcdi,
         pci_physical_contract_item pci,
         gmr_goods_movement_record  gmr,
         grd_goods_record_detail    grd,
         pcpd_pc_product_definition pcpd,
         spq_stock_payable_qty     spq,
         aml_attribute_master_list aml,
         v_qat_ppm                  qat_ppm,
         v_ppu_pum                  ppu,
         pdm_productmaster          pdm_aml,
         ucm_unit_conversion_master ucm,
         tgi_temp_gmr_invoice       tgi
   where gmr.internal_contract_ref_no = pcdi.internal_contract_ref_no
     and pcdi.pcdi_id = pci.pcdi_id
     and pci.internal_contract_item_ref_no =
         grd.internal_contract_item_ref_no
     and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and grd.is_mark_for_tolling = 'N'
     and gmr.is_deleted = 'N'
     and gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no
     and pcpd.input_output = 'Input'
     and pci.process_id = pc_process_id
     and pcdi.process_id = pc_process_id
     and gmr.process_id = pc_process_id
     and pcpd.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and grd.status = 'Active'
     and spq.process_id = pc_process_id
     and spq.is_stock_split = 'N'
     and spq.internal_grd_ref_no = grd.internal_grd_ref_no
     and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     and spq.element_id = aml.attribute_id
     and spq.is_active = 'Y'
     and gmr.gmr_type = 'CONCENTRATES'
     and pcdi.is_active = 'Y'
     and pci.is_active = 'Y'
     and pcpd.is_active = 'Y'
     and grd.quality_id = qat_ppm.quality_id(+)
     and ppu.product_id = aml.underlying_product_id
     and ppu.weight_unit_id = pdm_aml.base_quantity_unit
     and nvl(ppu.weight, 1) = 1
     and aml.underlying_product_id = pdm_aml.product_id
     and gmr.discharge_country_id <> gmr.loading_country_id
     and ucm.from_qty_unit_id = spq.qty_unit_id
     and ucm.to_qty_unit_id = pdm_aml.base_quantity_unit
     and gmr.latest_internal_invoice_ref_no is not null
     and tgi.process_id = pc_process_id
     and tgi.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     and tgi.internal_invoice_ref_no = gmr.latest_internal_invoice_ref_no
     and 'TRUE' =
         (case when trunc(gmr.eff_date, 'Mon') = trunc(pd_trade_date, 'Mon') and
          gmr.eff_date is not null then 'TRUE' when
          trunc(gmr.loading_date, 'Mon') = trunc(pd_trade_date, 'Mon') and
          gmr.loading_date is not null then 'TRUE' else 'FALSE' end);

commit;
gvn_log_counter := gvn_log_counter + 1;	
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Concentrates Invoice Over'); 

sp_gather_stats('ISR2_ISR_INVOICE');           
--                          
-- Base to Loading Country Exchange Rate
--
for cur_load_to_base_rate in(
select isr2.loading_country_cur_id,
       isr2.base_cur_id,
       isr2.shipment_date
  from isr2_isr_invoice isr2
 where isr2.process_id = pc_process_id
and isr2.loading_country_cur_id <> isr2.base_cur_id
 group by isr2.loading_country_cur_id,
          isr2.base_cur_id,
          isr2.shipment_date) loop
select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                cur_load_to_base_rate.base_cur_id,
                                                cur_load_to_base_rate.loading_country_cur_id,
                                                cur_load_to_base_rate.shipment_date,
                                                1)
  into vn_exch_rate
  from dual;
Update isr2_isr_invoice isr2
set isr2.base_to_load_country_ex_rate = vn_exch_rate
where isr2.loading_country_cur_id = cur_load_to_base_rate.loading_country_cur_id
   and isr2.shipment_date = cur_load_to_base_rate.shipment_date
   and isr2.process_id = pc_process_id;  
end loop;          
commit;
--
-- Base to Discharge Country Exchange Rate
--
for cur_dis_to_base_rate in(
select isr2.dischagre_country_cur_id,
       isr2.base_cur_id,
       isr2.shipment_date
  from isr2_isr_invoice isr2
 where isr2.process_id = pc_process_id
and isr2.dischagre_country_cur_id <> isr2.base_cur_id
 group by isr2.dischagre_country_cur_id,
          isr2.base_cur_id,
          isr2.shipment_date) loop
select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                cur_dis_to_base_rate.base_cur_id,
                                                cur_dis_to_base_rate.dischagre_country_cur_id,
                                                cur_dis_to_base_rate.shipment_date,
                                                1)
  into vn_exch_rate
  from dual;
Update isr2_isr_invoice isr2
set isr2.base_to_disc_country_ex_rate = vn_exch_rate
where isr2.dischagre_country_cur_id = cur_dis_to_base_rate.dischagre_country_cur_id
   and isr2.shipment_date = cur_dis_to_base_rate.shipment_date
   and isr2.process_id = pc_process_id;  
end loop;
commit;
--
-- Invoice Curreny to Base Fx Rate
--
for cur_inv_exch_rate in(
select isr2.invoice_cur_id,
       isr2.base_cur_id,
       isr2.shipment_date
  from isr2_isr_invoice isr2
 where isr2.process_id = pc_process_id having
 isr2.invoice_cur_id <> isr2.base_cur_id
 group by isr2.invoice_cur_id,
          isr2.base_cur_id,
          isr2.shipment_date) loop
select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                cur_inv_exch_rate.invoice_cur_id,
                                                cur_inv_exch_rate.base_cur_id,
                                                cur_inv_exch_rate.shipment_date,
                                                1)
  into vn_exch_rate
  from dual;
Update isr2_isr_invoice isr2
set isr2.invoice_to_base_ex_rate =  vn_exch_rate
where isr2.process_id = pc_process_id
and isr2.invoice_cur_id =  cur_inv_exch_rate.invoice_cur_id
and isr2.shipment_date = cur_inv_exch_rate.shipment_date ;  
end loop;          
commit;
gvn_log_counter := gvn_log_counter + 1;	
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Concentrates Invoice Conversion Over'); 
sp_gather_stats('ISR2_ISR_INVOICE');           
                          
insert into isr_intrastat_grd
  (corporate_id,
   process_id,
   eod_trade_date,
   contract_ref_no,
   contract_item_ref_no,
   gmr_ref_no,
   internal_gmr_ref_no,
   product_id,
   product_name,
   cp_id,
   counterparty_name,
   quality_id,
   quality_name,
   qty,
   dry_qty,
   qty_unit_id,
   shipment_date,
   loading_country_id,
   loading_country_name,
   loading_city_id,
   loading_city_name,
   loading_state_id,
   loading_state_name,
   loading_region_id,
   loading_region_name,
   discharge_country_id,
   discharge_country_name,
   discharge_city_id,
   discharge_city_name,
   discharge_state_id,
   discharge_state_name,
   discharge_region_id,
   discharge_region_name,
   mode_of_transport,
   arrival_no,
   invoice_date,
   invoice_invenotry_status,
   invoice_invenotry_value,
   invoice_invenotry_cur_id,
   invoice_invenotry_cur_code,
   loading_country_cur_id,
   loading_country_cur_code,
   discharge_country_cur_id,
   discharge_country_cur_code,
   base_cur_id,
   base_cur_code,
   ex_rate_base_to_nat_load,
   ex_rate_base_to_nat_dis,
   comb_nome_item_code,
   contract_type,
   is_new,
   export_date,
   import_date,
   ex_rate_to_base,
   incoterm_id,
   incoterm,
   final_invoice_date,
   no_of_containers,
   internal_invoice_ref_no,
   invoice_ref_no)
  select corporate_id,
         process_id,
         pd_trade_date,
         contract_ref_no,
         contract_ref_no_del_item_no,
         gmr_ref_no,
         internal_gmr_ref_no,
         product_id,
         product_desc,
         cp_id,
         supplier_name,
         quality_id,
         quality_name,
         sum(qty),
         sum(dry_qty),
         grd_qty_unit_id,
         shipment_date,
         loading_country_id,
         loading_country_name,
         loading_city_id,
         loading_city_name,
         loading_state_id,
         loading_state_name,
         loading_region_id,
         loading_region,
         discharge_country_id,
         discharge_country_name,
         discharge_city_id,
         discharge_city_name,
         discharge_state_id,
         discharge_state_name,
         discharge_region_id,
         discharge_region,
         mode_of_transport,
         bl_no,
         invoice_date,
         invoice_or_invenotry,
         max(invoice_amt),
         invoice_cur_id,
         invoice_cur_code,
         loading_country_cur_id,
         loading_country_cur_code,
         dischagre_country_cur_id,
         dischagre_country_cur_code,
         base_cur_id,
         base_cur_code,
         base_to_load_country_ex_rate,
         base_to_disc_country_ex_rate,
         attribute_value,
         contract_type,
         is_new,
         export_date,
         import_date,
         invoice_to_base_ex_rate,
         incoterm_id,
         incoterm,
         final_invoice_date,
         no_of_containers,
         internal_invoice_ref_no,
         invoice_ref_no
    from (select isr2.corporate_id,
                 isr2.process_id,
                 pd_trade_date,
                 isr2.contract_ref_no,
                 isr2.contract_ref_no_del_item_no,
                 isr2.gmr_ref_no,
                 isr2.internal_gmr_ref_no,
                 isr2.product_id,
                 isr2.product_desc,
                 isr2.cp_id,
                 isr2.supplier_name,
                 isr2.quality_id,
                 isr2.quality_name,
                 
                 (case
                   when dense_rank()
                    over(partition by isr2.internal_grd_ref_no order by
                             isr2.element_id) = 1 then
                    isr2.grd_qty
                   else
                    0
                 end) qty,
                 (case
                   when dense_rank()
                    over(partition by isr2.internal_grd_ref_no order by
                             isr2.element_id) = 1 then
                    isr2.grd_dry_qty
                   else
                    0
                 end) dry_qty,
                 isr2.grd_qty_unit_id,
                 isr2.shipment_date,
                 isr2.loading_country_id,
                 isr2.loading_country_name,
                 isr2.loading_city_id,
                 isr2.loading_city_name,
                 isr2.loading_state_id,
                 isr2.loading_state_name,
                 isr2.loading_region_id,
                 isr2.loading_region,
                 isr2.discharge_country_id,
                 isr2.discharge_country_name,
                 isr2.discharge_city_id,
                 isr2.discharge_city_name,
                 isr2.discharge_state_id,
                 isr2.discharge_state_name,
                 isr2.discharge_region_id,
                 isr2.discharge_region,
                 isr2.mode_of_transport,
                 isr2.bl_no,
                 isr2.invoice_date,
                 isr2.invoice_or_invenotry,
                 isr2.invoice_amt,
                 isr2.invoice_cur_id,
                 isr2.invoice_cur_code,
                 isr2.loading_country_cur_id,
                 isr2.loading_country_cur_code,
                 isr2.dischagre_country_cur_id,
                 isr2.dischagre_country_cur_code,
                 isr2.base_cur_id,
                 isr2.base_cur_code,
                 isr2.base_to_load_country_ex_rate,
                 isr2.base_to_disc_country_ex_rate,
                 isr2.attribute_value,
                 isr2.contract_type,
                 'N' is_new,
                 isr2.export_date,
                 isr2.import_date,
                 isr2.invoice_to_base_ex_rate,
                 isr2.incoterm_id,
                 isr2.incoterm,
                 isr2.final_invoice_date,
                 isr2.no_of_containers,
                 isr2.internal_invoice_ref_no,
                 isr2.invoice_ref_no
            from isr2_isr_invoice isr2
           where isr2.process_id = pc_process_id) t
group by corporate_id,
         process_id,
         pd_trade_date,
         contract_ref_no,
         contract_ref_no_del_item_no,
         gmr_ref_no,
         internal_gmr_ref_no,
         product_id,
         product_desc,
         cp_id,
         supplier_name,
         quality_id,
         quality_name,
         grd_qty_unit_id,
         shipment_date,
         loading_country_id,
         loading_country_name,
         loading_city_id,
         loading_city_name,
         loading_state_id,
         loading_state_name,
         loading_region_id,
         loading_region,
         discharge_country_id,
         discharge_country_name,
         discharge_city_id,
         discharge_city_name,
         discharge_state_id,
         discharge_state_name,
         discharge_region_id,
         discharge_region,
         mode_of_transport,
         bl_no,
         invoice_date,
         invoice_or_invenotry,
         invoice_cur_id,
         invoice_cur_code,
         loading_country_cur_id,
         loading_country_cur_code,
         dischagre_country_cur_id,
         dischagre_country_cur_code,
         base_cur_id,
         base_cur_code,
         base_to_load_country_ex_rate,
         base_to_disc_country_ex_rate,
         attribute_value,
         contract_type,
         is_new,
         export_date,
         import_date,
         invoice_to_base_ex_rate,
         incoterm_id,
         incoterm,
         final_invoice_date,
         no_of_containers,
         internal_invoice_ref_no,
         invoice_ref_no           ;
gvn_log_counter := gvn_log_counter + 1;			 
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Concentrates Invoice Insert into ISR Over'); 
commit;                          
--
-- Update VAT Number for Discharge Country
--
Update isr_intrastat_grd isr
set isr.discharge_country_vat_no =
(select bvd.vat_no from bvd_bp_vat_details bvd
where bvd.profile_id = isr.cp_id
and  bvd.country_id = isr.discharge_country_id
and bvd.is_deleted ='N')
where isr.process_id = pc_process_id;
--
-- Update VAT Number for Loading Country
--

Update isr_intrastat_grd isr
set isr.loading_country_vat_no =
(select bvd.vat_no from bvd_bp_vat_details bvd
where bvd.profile_id = isr.cp_id
and  bvd.country_id = isr.loading_country_id
and bvd.is_deleted ='N'
)
where isr.process_id = pc_process_id;
gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Update of Vat Number End');     

--
-- Update Stock Unit
--
Update isr_intrastat_grd isr
set isr.qty_unit = (select qum.qty_unit from qum_quantity_unit_master qum
where qum.qty_unit_id = isr.qty_unit_id)
where isr.process_id = pc_process_id;

commit;

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
  
    update isr_intrastat_grd isr
       set isr.is_new = 'Y'
     where isr.internal_gmr_ref_no not in
           (select isr_prev.internal_gmr_ref_no
              from isr_intrastat_grd isr_prev
             where isr_prev.process_id = vc_previous_process_id)
       and isr.process_id = pc_process_id;
    commit;
gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Update IS New Flag,Intrastat End');     
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_intrsstat',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ,
                                                           '',
                                                           pc_process,
                                                           '',
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
      commit;
  end;

  procedure sp_phy_contract_status(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2) as
  begin
  delete from tcsm_temp_contract_status_main t
  where t.corporate_id = pc_corporate_id;
  commit;
  delete from tcs1_temp_cs_payable t
  where t.corporate_id = pc_corporate_id;
  commit;
  delete from tcs2_temp_cs_priced t
  where t.corporate_id = pc_corporate_id;
  commit;
  gvn_log_counter := gvn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'All deletion over');
  insert into tcsm_temp_contract_status_main
    (internal_contract_ref_no,
     contract_ref_no,
     corporate_id,
     corporate_name,
     cp_id,
     element_id,
     attribute_name,
     cp_name,
     contract_status,
     product_id,
     product_desc,
     open_qty,
     qty_unit_id,
     qty_unit,
     invoice_cur_id,
     invoice_cur_code)
  select pcm.internal_contract_ref_no,
                     pcm.contract_ref_no,
                     pcm.corporate_id,
                     akc.corporate_name,
                     pcm.cp_id,
                     dipq.element_id,
                     aml.attribute_name,
                     pcm.cp_name,
                     pcm.contract_status,
                     pcpd.product_id,
                     pcpd.product_name,
                     sum(dipq.payable_qty) open_qty,
                     dipq.qty_unit_id qty_unit_id,
                     qum.qty_unit,
                     pcm.invoice_currency_id invoice_cur_id,
                     pcm.invoice_cur_code invoice_cur_code
                from pcm_physical_contract_main     pcm,
                     dipq_delivery_item_payable_qty dipq,
                     pcpd_pc_product_definition     pcpd,
                     pcdi_pc_delivery_item          pcdi,
                     ak_corporate                   akc,
                     pcmte_pcm_tolling_ext          pcmte,
                     aml_attribute_master_list      aml,
                     qum_quantity_unit_master       qum
               where pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
                 and dipq.pcdi_id = pcdi.pcdi_id   
                 and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
                 and pcm.contract_type = 'CONCENTRATES'
                 and pcpd.input_output = 'Input'
                 and pcm.contract_status = 'In Position'
                 and pcm.corporate_id = akc.corporate_id
                 and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no
                 and pcmte.tolling_service_type = 'S'
                 and dipq.element_id = aml.attribute_id
                 and qum.qty_unit_id = dipq.qty_unit_id
                 and dipq.process_id = pc_process_id    
                 and dipq.is_active = 'Y' 
                 and pcpd.process_id = pc_process_id
                 and pcdi.process_id = pc_process_id
                 and pcm.process_id = pc_process_id
                 and aml.is_active = 'Y'
                 and qum.is_active = 'Y'
                 and pcdi.is_active = 'Y'
                 and pcm.is_active = 'Y'
                 and pcpd.is_active = 'Y'
               group by pcm.internal_contract_ref_no,
                        pcm.contract_ref_no,
                        pcm.corporate_id,
                        akc.corporate_name,
                        pcm.cp_id,
                        dipq.element_id,
                        aml.attribute_name,
                        pcm.cp_name,
                        pcm.contract_status,
                        pcpd.product_id,
                        pcpd.product_name,
                        dipq.qty_unit_id,
                        qum.qty_unit,
                        pcm.invoice_currency_id,
                        pcm.invoice_cur_code;
commit;
gvn_log_counter := gvn_log_counter + 1;
 sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Main Table tcsm_temp_contract_status_main over');
insert into tcs1_temp_cs_payable
  (corporate_id, internal_contract_ref_no, element_id, landed_qty)
  select pc_corporate_id,
         gmr.internal_contract_ref_no,
         spq.element_id,
         sum(spq.payable_qty) landed_qty
    from pcm_physical_contract_main pcm,
         pcmte_pcm_tolling_ext      pcmte,
         gmr_goods_movement_record  gmr,
         spq_stock_payable_qty      spq,
         grd_goods_record_detail    grd
   where pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
     and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no
     and pcmte.tolling_service_type = 'S'
     and gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
     and spq.is_stock_split = 'N'
     and gmr.landed_qty > 0
     and pcm.is_active = 'Y'
     and spq.is_active = 'Y'
     and gmr.is_deleted = 'N'
     and spq.process_id = pc_process_id
     and pcm.process_id = pc_process_id
     and gmr.process_id = pc_process_id
     and spq.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and spq.internal_grd_ref_no = grd.internal_grd_ref_no
     and spq.process_id = grd.process_id
     and grd.status = 'Active'
   group by gmr.internal_contract_ref_no,
            spq.element_id;
      commit;     
      gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Main Table tcs1_temp_cs_payable over');         
insert into tcs2_temp_cs_priced
  (corporate_id, internal_contract_ref_no, element_id, priced_qty)

  select pc_corporate_id,
         pcm.internal_contract_ref_no,
         poch.element_id,
         sum(pfd.qty_fixed) priced_qty
    from pcm_physical_contract_main     pcm,
         pcmte_pcm_tolling_ext          pcmte,
         pcdi_pc_delivery_item          pcdi,
         poch_price_opt_call_off_header poch,
         pocd_price_option_calloff_dtls pocd,
         pofh_price_opt_fixation_header pofh,
         pfd_price_fixation_details     pfd
   where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
     and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no
     and pcmte.tolling_service_type = 'S'
     and pocd.price_type <> 'Fixed'
     and pcdi.pcdi_id = poch.pcdi_id
     and poch.poch_id = pocd.poch_id
     and pocd.pocd_id = pofh.pocd_id
     and pofh.pofh_id = pfd.pofh_id
     and pcm.is_active = 'Y'
     and pcdi.is_active = 'Y'
     and poch.is_active = 'Y'
     and pocd.is_active = 'Y'
     and pofh.is_active = 'Y'
     and pfd.is_active = 'Y'
     and pcm.process_id = pc_process_id
     and pcdi.process_id = pc_process_id
     and pfd.hedge_correction_date <= pd_trade_date
     and nvl(pfd.is_cancel,'N')='N'
   group by pcm.internal_contract_ref_no,
            poch.element_id
  union all
  select pc_corporate_id,
         pcm.internal_contract_ref_no,
         dipq.element_id,
         sum(dipq.payable_qty) priced_qty
    from pcm_physical_contract_main     pcm,
         pcmte_pcm_tolling_ext          pcmte,
         pcdi_pc_delivery_item          pcdi,
         dipq_delivery_item_payable_qty dipq,
         poch_price_opt_call_off_header poch,
         pocd_price_option_calloff_dtls pocd,
         aml_attribute_master_list      aml
   where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
     and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no
     and pcmte.tolling_service_type = 'S'
     and dipq.pcdi_id = pcdi.pcdi_id
     and pcdi.pcdi_id = poch.pcdi_id
     and poch.poch_id = pocd.poch_id
     and pocd.price_type = 'Fixed'
     and poch.element_id = dipq.element_id
     and dipq.element_id = aml.attribute_id
     and dipq.process_id = pc_process_id
     and dipq.is_active = 'Y'
     and pcm.corporate_id = pc_corporate_id
     and pcm.is_active = 'Y'
     and pcdi.is_active = 'Y'
     and poch.is_active = 'Y'
     and pocd.is_active = 'Y'
     and aml.is_active = 'Y'
     and pcm.process_id = pc_process_id
     and pcdi.process_id = pc_process_id
   group by pcm.internal_contract_ref_no,
            dipq.element_id;
commit;
 gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Main Table tcs2_temp_cs_priced over');                                 
    insert into pcs_purchase_contract_status
      (corporate_id,
       corporate_name,
       process_id,
       eod_trade_date,
       contract_ref_no,
       product_id,
       product_name,
       cp_id,
       cp_name,
       contract_status,
       invoice_pay_in_cur,
       invoice_pay_in_cur_code,
       element_id,
       element_name,
       payable_qty,
       payable_qty_unit_id,
       payable_qty_unit_name,
       priced_arrived_qty,
       priced_not_arrived_qty,
       unpriced_arrived_qty,
       unpriced_not_arrived_qty)
      select main_table.corporate_id,
             main_table.corporate_name,
             pc_process_id,
             pd_trade_date,
             main_table.contract_ref_no,
             main_table.product_id,
             main_table.product_desc,
             main_table.cp_id,
             main_table.cp_name,
             main_table.contract_status,
             main_table.invoice_cur_id,
             main_table.invoice_cur_code,
             main_table.element_id,
             main_table.attribute_name,
             main_table.open_qty,
             main_table.qty_unit_id,
             main_table.qty_unit,
             (case
               when nvl(stock_table.landed_qty, 0) <
                    nvl(pfc_data.priced_qty, 0) then
                nvl(stock_table.landed_qty, 0)
               else
                nvl(pfc_data.priced_qty, 0)
             end) priced_arrived_qty,
             
             nvl(pfc_data.priced_qty, 0) -
             (case
                when nvl(stock_table.landed_qty, 0) <
                     nvl(pfc_data.priced_qty, 0) then
                 nvl(stock_table.landed_qty, 0)
                else
                 nvl(pfc_data.priced_qty, 0)
              end) price_not_arrived_qty,
             nvl(stock_table.landed_qty, 0) -
             (case
                when nvl(stock_table.landed_qty, 0) <
                     nvl(pfc_data.priced_qty, 0) then
                 nvl(stock_table.landed_qty, 0)
                else
                 nvl(pfc_data.priced_qty, 0)
              end) unpriced_arrived_qty,
             (main_table.open_qty - nvl(stock_table.landed_qty, 0)) -
             (nvl(pfc_data.priced_qty, 0) - (case
               when nvl(stock_table.landed_qty, 0) <
                    nvl(pfc_data.priced_qty, 0) then
                nvl(stock_table.landed_qty, 0)
               else
                nvl(pfc_data.priced_qty, 0)
             end)) unpriced_not_arrived_qty
        from tcsm_temp_contract_status_main         main_table,
             tcs1_temp_cs_payable stock_table,
             tcs2_temp_cs_priced pfc_data
       where main_table.internal_contract_ref_no =
             stock_table.internal_contract_ref_no(+)
         and main_table.corporate_id = stock_table.corporate_id(+)
         and main_table.element_id = stock_table.element_id(+)
         and main_table.internal_contract_ref_no =
             pfc_data.internal_contract_ref_no(+)
         and main_table.element_id = pfc_data.element_id(+)
         and main_table.corporate_id = pfc_data.corporate_id(+)
        and main_table.corporate_id = pc_corporate_id;
    commit;
     gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Contract Status Report over');      
  end;
procedure sp_feed_consumption_report(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_process_id   varchar2) as
vn_conv number;

begin
  delete from temp_fcr where corporate_id = pc_corporate_id;
  commit;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          3001,
                          'delete from temp_fcr Over');
  insert into temp_fcr
    (corporate_id,
     corporate_name,
     internal_gmr_ref_no,
     gmr_ref_no,
     product_id,
     product_name,
     quality_id,
     quality_name,
     internal_grd_ref_no,
     cp_id,
     cp_name,
     element_id,
     element_name,
     iam_ash_id,
     spq_ash_id,
     gmr_qty,
     gmr_qty_unit_id,
     gmr_qty_unit,
     assay_qty,
     asaay_qty_unit_id,
     asaay_qty_unit,
     payable_qty,
     payable_qty_unit_id,
     payable_qty_unit,
     invoice_cur_id,
     invoice_cur_code,
     base_cur_id,
     base_cur_code,
     internal_invoice_ref_no,
     product_base_qty_unit_id,
     product_base_qty_unit )
    select pc_corporate_id corporate_id,
           akc.corporate_name,
           t.internal_gmr_ref_no,
           t.gmr_ref_no,
           t.product_id,
           pdm.product_desc,
           t.quality_id,
           t.quality_name,
           t.internal_grd_ref_no,
           pcm.cp_id cp_id,
           pcm.cp_name,
           t.element_id,
           aml.attribute_name,
           iam.ash_id,
           t.weg_avg_pricing_assay_id,
           t.current_qty,
           t.qty_unit_id,
           qum_gmr.qty_unit gmr_qty_unit,
           t.assay_qty,
           t.assay_qty_unit_id,
           qum_spq.qty_unit assay_qty_unit,
           t.payable_qty,
           t.payable_qty_unit_id,
           qum_spq.qty_unit payable_qty_unit,
           t.invoice_cur_id,
           t.invoice_cur_code invoice_cur_code,
           cm_base.cur_id base_cur_id,
           cm_base.cur_code base_cur_code,
           t.internal_invoice_ref_no,
           qum_pdm.qty_unit_id,
           qum_pdm.qty_unit
      from (select grd.internal_gmr_ref_no,
       grd.internal_grd_ref_no,
       grd.product_id,
       grd.quality_id,
       grd.quality_name,
       grd.profit_center_id,
       spq.element_id,
       case
         when dense_rank() over(partition by spq.internal_grd_ref_no order by
                   spq.element_id) = 1 then
          grd.qty * asm.dry_wet_qty_ratio / 100
         else
          0
       end current_qty,
       grd.qty_unit_id,
       spq.assay_content assay_qty,
       spq.qty_unit_id assay_qty_unit_id,
       spq.payable_qty payable_qty,
       spq.qty_unit_id payable_qty_unit_id,
       gmr.invoice_cur_id,
       gmr.invoice_cur_code,
       iss.invoice_issue_date,
       gmr.latest_internal_invoice_ref_no internal_invoice_ref_no,
       spq.weg_avg_pricing_assay_id,
       grd.internal_contract_item_ref_no,
       gmr.gmr_ref_no
  from gmr_goods_movement_record gmr,
       grd_goods_record_detail   grd,
       is_invoice_summary        iss,
       spq_stock_payable_qty     spq,
       ash_assay_header          ash,
       asm_assay_sublot_mapping  asm
 where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and spq.is_stock_split = 'N'
   and spq.internal_grd_ref_no = grd.internal_grd_ref_no
   and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pc_process_id = iss.process_id(+)
   and gmr.latest_internal_invoice_ref_no = iss.internal_invoice_ref_no(+)
   and gmr.process_id = pc_process_id
   and grd.process_id = pc_process_id
   and spq.process_id = pc_process_id
   and gmr.is_deleted = 'N'
   and grd.status = 'Active'
   and gmr.is_pass_through = 'Y'
   and grd.tolling_stock_type = 'Clone Stock'
   and spq.weg_avg_pricing_assay_id = ash.ash_id
   and ash.ash_id = asm.ash_id
   and trunc(gmr.eff_date,'mm') = trunc(pd_trade_date,'mm')
 ) t,
           iam_invoice_assay_mapping iam,
           qum_quantity_unit_master qum_spq,
           pdm_productmaster pdm,
           pci_physical_contract_item pci,
           pcdi_pc_delivery_item pcdi,
           pcm_physical_contract_main pcm,
           aml_attribute_master_list aml,
           cm_currency_master cm_base,
           ak_corporate akc,
           pdm_productmaster pdm_aml,
           qum_quantity_unit_master qum_gmr,
           qum_quantity_unit_master qum_pdm
     where t.internal_grd_ref_no = iam.internal_grd_ref_no(+)
       and t.internal_invoice_ref_no = iam.internal_invoice_ref_no(+)
       and t.payable_qty_unit_id = qum_spq.qty_unit_id
       and t.product_id = pdm.product_id
       and t.internal_contract_item_ref_no =
           pci.internal_contract_item_ref_no(+)
       and pc_process_id = pci.process_id(+)
       and pci.pcdi_id = pcdi.pcdi_id(+)
       and pc_process_id = pcdi.process_id(+)
       and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
       and pc_process_id = pcm.process_id(+)
       and t.element_id = aml.attribute_id
       and cm_base.cur_id = akc.base_cur_id
       and akc.corporate_id = pc_corporate_id
       and aml.underlying_product_id = pdm_aml.product_id
       and t.qty_unit_id = qum_gmr.qty_unit_id
       and pdm_aml.base_quantity_unit = qum_pdm.qty_unit_id;
  commit;
  
   sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          3002,
                          'Insert temp_fcr Over');
  
  commit;
   sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          3003,
                          'Dry Qty update Over');
  --
  -- Now we have to convert assay qty to product base qty unit
  --
  for cur_stock_qty in (select 
       t.asaay_qty_unit_id,
       t.product_base_qty_unit_id
  from temp_fcr t
 where t.asaay_qty_unit_id <> t.product_base_qty_unit_id
 and t.corporate_id = pc_corporate_id
 group by t.asaay_qty_unit_id,
          t.product_base_qty_unit_id)loop
       vn_conv :=  pkg_general.f_get_converted_quantity(null,
                                                              cur_stock_qty.asaay_qty_unit_id,
                                                              cur_stock_qty.product_base_qty_unit_id,
                                                              1) ;  
    update temp_fcr t
       set t.assay_qty =vn_conv *t.assay_qty,
       t.payable_qty = t.payable_qty * vn_conv
     where t.asaay_qty_unit_id = cur_stock_qty.asaay_qty_unit_id
       and t.product_base_qty_unit_id =
           cur_stock_qty.product_base_qty_unit_id
       and t.corporate_id = pc_corporate_id;
  end loop;
  commit;

  insert into fcr_feed_consumption_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     internal_gmr_ref_no,
     gmr_ref_no,
     product_id,
     product_name,
     quality_id,
     quality_name,
     cp_id,
     cp_name,
     element_id,
     element_name,
     gmr_qty,
     gmr_qty_unit_id,
     gmr_qty_unit,
     assay_qty,
     asaay_qty_unit_id,
     asaay_qty_unit,
     payable_qty,
     payable_qty_unit_id,
     payable_qty_unit,
     invoice_cur_id,
     invoice_cur_code,
     base_cur_id,
     base_cur_code,
     internal_invoice_ref_no,
     product_base_qty_unit_id,
     product_base_qty_unit)
    select pc_process_id,
           pd_trade_date,
           corporate_id,
           corporate_name,
           internal_gmr_ref_no,
           gmr_ref_no,
           product_id,
           product_name,
           quality_id,
           quality_name,
           cp_id,
           cp_name,
           element_id,
           element_name,
           sum(gmr_qty),
           gmr_qty_unit_id,
           gmr_qty_unit,
           sum(assay_qty),
           asaay_qty_unit_id,
           asaay_qty_unit,
           sum(payable_qty),
           payable_qty_unit_id,
           payable_qty_unit,
           invoice_cur_id,
           invoice_cur_code,
           base_cur_id,
           base_cur_code,
           internal_invoice_ref_no,
           product_base_qty_unit_id,
           product_base_qty_unit
   from temp_fcr
     where corporate_id = pc_corporate_id
     group by corporate_id,
              corporate_name,
              gmr_ref_no,
              internal_gmr_ref_no,
              product_id,
              product_name,
              quality_id,
              quality_name,
              cp_id,
              cp_name,
              element_id,
              element_name,
              gmr_qty_unit_id,
              gmr_qty_unit,
              asaay_qty_unit_id,
              asaay_qty_unit,
              payable_qty_unit_id,
              payable_qty_unit,
              invoice_cur_id,
              invoice_cur_code,
              base_cur_id,
              base_cur_code,
              internal_invoice_ref_no,
              product_base_qty_unit_id,
              product_base_qty_unit;
  commit;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          3004,
                          'main insert Over');
  --
  -- TC/RC/Penalty 
  --
    update fcr_feed_consumption_report fcr
       set (fcr.tc_amount, fcr.rc_amount, fcr.penality_amount)
       =(select t.tc_amt, t.rc_amt, t.penalty_amt from tgc_temp_gmr_charges t
       where t.corporate_id = pc_corporate_id
       and t.internal_gmr_ref_no = fcr.internal_gmr_ref_no
       and t.internal_invoice_ref_no = fcr.internal_invoice_ref_no
       and t.element_id = fcr.element_id)
     where fcr.process_id = pc_process_id;
commit;
--
-- Update Other charges
--
for cur_oc in 
(select is1.internal_invoice_ref_no,
       (nvl(is1.total_other_charge_amount, 0) -
       nvl(is1.freight_allowance_amt, 0)) /
       count(distinct iid.internal_gmr_ref_no) total_other_charge_amount
  from is_invoice_summary          is1,
       gmr_goods_movement_record   gmr,
       iid_invoicable_item_details iid
 where is1.process_id = pc_process_id
   and iid.internal_invoice_ref_no = is1.internal_invoice_ref_no
   and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and iid.internal_invoice_ref_no = gmr.latest_internal_invoice_ref_no
   and gmr.process_id = pc_process_id
   and iid.is_active = 'Y'
 group by is1.internal_invoice_ref_no,
          nvl(is1.freight_allowance_amt, 0),
          (nvl(is1.total_other_charge_amount, 0) -
          nvl(is1.freight_allowance_amt, 0))) loop

update fcr_feed_consumption_report fcr
       set fcr.inv_add_charges = cur_oc.total_other_charge_amount
       where  fcr.internal_invoice_ref_no =cur_oc.internal_invoice_ref_no
       and fcr.process_id = pc_process_id;
   end loop;    

commit;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          3008,
                          'Other charges Over');
end;
  procedure sp_stock_monthly_yeild(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2) as
  
  begin
    delete from tyytd_temp_yield_ytd where corporate_id = pc_corporate_id;
    gvn_log_counter := gvn_log_counter +1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Delete tyytd_temp_yield_ytd Over');
    commit;
    insert into tyytd_temp_yield_ytd
      (internal_gmr_ref_no,
       element_id,
       gmr_ref_no,
       corporate_id,
       element_name,
       element_product_id,
       element_product_name,
       yield_pct,
       current_qty,
       qty_unit_id,
       ytd_year,
       ytd_month,
       ytd_group_column)
      select ypd.internal_gmr_ref_no,
             ypd.element_id,
             gmr.gmr_ref_no || case
               when gmr.is_final_invoiced = 'Y' then
                '[FIN]'
               when gmr.is_provisional_invoiced = 'Y' then
                '[PRV]'
               else
                ''
             end gmr_ref_no,
             gmr.corporate_id,
             aml.attribute_name element_name,
             pdm.product_id element_product_id,
             pdm.product_desc element_product_name,
             ypd.yield_pct,
             agmr.current_qty,
             agmr.qty_unit_id,
             to_char(agmr.eff_date, 'yyyy') ytd_year,
             to_char(agmr.eff_date, 'Mon') ytd_month,
             to_date('01-' || to_char(agmr.eff_date, 'Mon-yyyy'),
                     'dd-Mon-yyyy') ytd_group_column
        from ypd_yield_pct_detail      ypd,
             axs_action_summary        axs,
             gmr_goods_movement_record gmr,
             agmr_action_gmr           agmr,
             aml_attribute_master_list aml,
             pdm_productmaster         pdm,
             dbd_database_dump         dbd,
             is_invoice_summary        iss
       where ypd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and ypd.internal_action_ref_no = axs.internal_action_ref_no
         and ypd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
         and ypd.element_id = aml.attribute_id
         and aml.underlying_product_id = pdm.product_id(+)
         and gmr.process_id = pc_process_id
         and gmr.corporate_id = pc_corporate_id
         and axs.dbd_id = dbd.dbd_id
         and dbd.process = 'EOM'
         and gmr.latest_internal_invoice_ref_no =
             iss.internal_invoice_ref_no(+)
         and gmr.process_id = iss.process_id(+)
         and gmr.is_deleted = 'N'
         and aml.is_active = 'Y'
         and pdm.is_active = 'Y'
         and agmr.action_no = '1'
         and ypd.is_active = 'Y';
    commit;
    gvn_log_counter := gvn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Insert tyytd_temp_yield_ytd Over');
    delete from tys_temp_yield_stock where corporate_id = pc_corporate_id;
    gvn_log_counter := gvn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Delete tys_temp_yield_stock Over');
    commit;
    insert into tys_temp_yield_stock
      (corporate_id,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       element_id,
       total_qty_in_wet,
       total_qty_in_dry,
       wtdavgpostion_ash_id,
       latest_assay_id,
       unit_of_measure,
       typical,
       finalization_method,
       is_final_assay,
       assay_winner,
       is_elem_for_pricing,
       is_deductible,
       is_returnable,
       cp_id,
       conc_product_id,
       conc_qty_unit_id,
       conc_qty_unit)
      select pc_corporate_id,
             sac.internal_gmr_ref_no,
             sac.internal_grd_ref_no,
             sac.element_id,
             (ucm.multiplication_factor * sac.total_qty_in_wet) total_qty_in_wet,
             (ucm.multiplication_factor * sac.total_qty_in_dry) total_qty_in_dry,
             sac.wtdavgpostion_ash_id,
             sac.latest_assay_id,
             pqca.unit_of_measure,
             pqca.typical,
             pqca.finalization_method,
             pqca.is_final_assay,
             pqca.assay_winner,
             pqca.is_elem_for_pricing,
             pqca.is_deductible,
             pqca.is_returnable,
             pcm.cp_id,
             grd.product_id conc_product_id,
             pdm.base_quantity_unit conc_qty_unit_id,
             qum.qty_unit conc_qty_unit
        from sac_stock_assay_content     sac,
             ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             pqca_pq_chemical_attributes pqca,
             grd_goods_record_detail     grd,
             pci_physical_contract_item  pci,
             pcdi_pc_delivery_item       pcdi,
             pcm_physical_contract_main  pcm,
             pdm_productmaster           pdm,
             ucm_unit_conversion_master  ucm,
             qum_quantity_unit_master    qum
       where ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.element_id = sac.element_id
         and pqca.is_active = 'Y'
         and ash.ash_id = sac.wtdavgpostion_ash_id
         and grd.product_id = pdm.product_id
         and grd.qty_unit_id = ucm.from_qty_unit_id
         and pdm.base_quantity_unit = ucm.to_qty_unit_id
         and pdm.base_quantity_unit = qum.qty_unit_id
         and sac.internal_grd_ref_no = grd.internal_grd_ref_no
         and grd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and pci.pcdi_id = pcdi.pcdi_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and grd.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and ash.is_active = 'Y'
         and asm.is_active = 'Y'
         and pqca.is_active = 'Y'
         and pdm.is_active = 'Y'
         and ucm.is_active = 'Y'
         and qum.is_active = 'Y'
       group by sac.internal_gmr_ref_no,
                sac.internal_grd_ref_no,
                sac.element_id,
                sac.total_qty_in_wet,
                sac.total_qty_in_dry,
                sac.wtdavgpostion_ash_id,
                ucm.multiplication_factor,
                grd.product_id,
                pdm.base_quantity_unit,
                qum.qty_unit,
                sac.latest_assay_id,
                pqca.unit_of_measure,
                pqca.typical,
                pqca.finalization_method,
                pqca.is_final_assay,
                pqca.assay_winner,
                pqca.is_elem_for_pricing,
                pqca.is_deductible,
                pcm.cp_id,
                pqca.is_returnable;
  
    commit;
    gvn_log_counter := gvn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Insert tys_temp_yield_stock Over');
sp_gather_stats('tyytd_temp_yield_ytd');
sp_gather_stats('tys_temp_yield_stock');
    insert into stock_monthly_yeild_data
      (corporate_id,
       corporate_name,
       process_id,
       internal_gmr_ref_no,
       gmr_ref_no,
       element_id,
       cp_id,
       total_qty_in_wet,
       total_qty_in_dry,
       unit_of_measure,
       avg_typical,
       yield_pct,
       current_qty,
       qty_unit_id,
       ytd_year,
       ytd_month,
       ytd_group_column,
       element_name,
       element_product_id,
       element_product_name,
       conc_product_id,
       conc_qty_unit_id,
       conc_qty_unit)
      select ytd.corporate_id,
             akc.corporate_name,
             pc_process_id,
             stock.internal_gmr_ref_no,
             ytd.gmr_ref_no,
             stock.element_id,
             stock.cp_id,
             stock.total_qty_in_wet,
             stock.total_qty_in_dry,
             stock.unit_of_measure,
             round(sum(stock.total_qty_in_dry * stock.typical) /
                   sum(stock.total_qty_in_dry),
                   4) avg_typical,
             ytd.yield_pct,
             ytd.current_qty,
             ytd.qty_unit_id,
             ytd.ytd_year,
             ytd.ytd_month,
             ytd.ytd_group_column,
             ytd.element_name,
             ytd.element_product_id,
             ytd.element_product_name,
             stock.conc_product_id,
             stock.conc_qty_unit_id,
             stock.conc_qty_unit
        from tys_temp_yield_stock stock,
             tyytd_temp_yield_ytd ytd,
             ak_corporate         akc
       where stock.internal_gmr_ref_no = ytd.internal_gmr_ref_no
         and stock.element_id = ytd.element_id
         and ytd.corporate_id = akc.corporate_id
         and ytd.corporate_id = pc_corporate_id
         and stock.corporate_id = pc_corporate_id
       group by stock.internal_gmr_ref_no,
                stock.element_id,
                stock.cp_id,
                stock.total_qty_in_wet,
                stock.total_qty_in_dry,
                stock.unit_of_measure,
                ytd.yield_pct,
                ytd.current_qty,
                ytd.qty_unit_id,
                ytd.gmr_ref_no,
                ytd.ytd_year,
                ytd.ytd_month,
                ytd.ytd_group_column,
                ytd.element_name,
                ytd.element_product_id,
                ytd.element_product_name,
                stock.conc_product_id,
                stock.conc_qty_unit_id,
                stock.conc_qty_unit,
                ytd.corporate_id,
                akc.corporate_name,
                pc_process_id;
    commit;
    gvn_log_counter := gvn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'sp_stock_monthly_yield over tys_temp_yield_stock Over');
  end;

  procedure sp_calc_risk_limits(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process_id   varchar2,
                                pc_user_id      varchar2,
                                pc_process      varchar2) is
    --vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    -- vn_eel_error_count number := 1;
  begin
    insert into cre_cp_risk_exposure
      (process_id,
       process_date,
       process,
       corporate_id,
       group_id,
       group_name,
       product_id,
       product_name,
       profit_center_id,
       profit_center_name,
       profit_center_short_name,
       contract_type,
       cp_profile_id,
       cp_name,
       qty_exposure,
       qty_exp_unit_id,
       qty_exp_unit,
       value_exposure,
       value_exp_cur_id,
       value_exp_cur_code,
       m2m_exposure,
       m2m_exp_cur_id,
       m2m_exp_cur_code,
       credit_exposure,
       credit_exp_cur_id,
       credit_exp_cur_code)
      select t.process_id,
             t.process_date,
             t.process,
             t.corporate_id,
             t.group_id,
             t.group_name,
             t.product_id,
             t.product_name,
             t.profit_center_id,
             t.profit_center_name,
             t.profit_center_short_name,
             t.contract_type,
             t.cp_profile_id,
             t.cp_name,
             sum(t.qty_exposure) qty_exposure,
             t.qty_exp_unit_id,
             t.qty_exp_unit,
             sum(t.value_exposure) value_exposure,
             t.value_exp_cur_id,
             t.value_exp_cur_code,
             sum(t.m2m_exposure) m2m_exposure,
             t.m2m_exp_cur_id,
             t.m2m_exp_cur_code,
             sum(t.credit_exposure) credit_exposure,
             t.credit_exp_cur_id,
             t.credit_exp_cur_code
        from (select poud.process_id process_id,
                     poud.eod_trade_date process_date,
                     tdc.process process,
                     poud.corporate_id corporate_id,
                     poud.group_id group_id,
                     poud.group_name group_name,
                     poud.product_id product_id,
                     poud.product_name product_name,
                     poud.profit_center_id profit_center_id,
                     poud.profit_center_name profit_center_name,
                     poud.profit_center_short_name profit_center_short_name,
                     poud.contract_type contract_type,
                     poud.cp_profile_id cp_profile_id,
                     poud.cp_name cp_name,
                     sum(poud.qty_in_base_unit) qty_exposure,
                     poud.base_qty_unit_id qty_exp_unit_id,
                     poud.base_qty_unit qty_exp_unit,
                     sum(poud.contract_value_in_price_cur *
                         pkg_general.f_get_converted_currency_amt(poud.corporate_id,
                                                                  poud.price_main_cur_id,
                                                                  poud.base_cur_id,
                                                                  poud.eod_trade_date,
                                                                  1)) value_exposure,
                     poud.base_cur_id value_exp_cur_id,
                     poud.base_cur_code value_exp_cur_code,
                     sum(poud.m2m_amt *
                         pkg_general.f_get_converted_currency_amt(poud.corporate_id,
                                                                  poud.m2m_amt_cur_id,
                                                                  poud.base_cur_id,
                                                                  poud.eod_trade_date,
                                                                  1)) m2m_exposure,
                     poud.base_cur_id m2m_exp_cur_id,
                     poud.base_cur_code m2m_exp_cur_code,
                     0 credit_exposure,
                     poud.base_cur_id credit_exp_cur_id,
                     poud.base_cur_code credit_exp_cur_code
                from poud_phy_open_unreal_daily poud,
                     tdc_trade_date_closure     tdc
               where poud.corporate_id = pc_corporate_id
                 and poud.process_id = pc_process_id
                 and poud.process_id = tdc.process_id
               group by poud.process_id,
                        poud.eod_trade_date,
                        tdc.process,
                        poud.corporate_id,
                        poud.group_id,
                        poud.group_name,
                        poud.product_id,
                        poud.product_name,
                        poud.profit_center_id,
                        poud.profit_center_name,
                        poud.profit_center_short_name,
                        poud.contract_type,
                        poud.cp_profile_id,
                        poud.cp_name,
                        poud.base_qty_unit_id,
                        poud.base_qty_unit,
                        poud.base_cur_id,
                        poud.base_cur_code
              union all
              select poud.process_id,
                     tdc.trade_date process_date,
                     tdc.process,
                     poud.corporate_id,
                     akc.groupid group_id,
                     gcd.groupname group_name,
                     poud.product_id,
                     poud.product_name,
                     cpc.profit_center_id,
                     cpc.profit_center_name,
                     cpc.profit_center_short_name,
                     poud.contract_type,
                     poud.cp_profile_id,
                     poud.cp_name,
                     sum(poud.qty_in_base_unit) qty_exposure,
                     pdm.base_quantity_unit qty_exp_unit_id,
                     qum.qty_unit qty_exp_unit,
                     sum(poud.contract_value_in_price_cur *
                         pkg_general.f_get_converted_currency_amt(poud.corporate_id,
                                                                  poud.contract_price_cur_id,
                                                                  poud.base_cur_id,
                                                                  tdc.trade_date,
                                                                  1)) value_exposure,
                     poud.base_cur_id value_exp_cur_id,
                     poud.base_cur_code value_exp_cur_code,
                     sum(poud.m2m_amt *
                         pkg_general.f_get_converted_currency_amt(poud.corporate_id,
                                                                  poud.m2m_amt_cur_id,
                                                                  poud.base_cur_id,
                                                                  tdc.trade_date,
                                                                  1)) m2m_exposure,
                     poud.base_cur_id m2m_exp_cur_id,
                     poud.base_cur_code m2m_exp_cur_code,
                     0 credit_exposure,
                     poud.base_cur_id credit_exp_cur_id,
                     poud.base_cur_code credit_exp_cur_code
                from psu_phy_stock_unrealized    poud,
                     cpc_corporate_profit_center cpc,
                     tdc_trade_date_closure      tdc,
                     pdm_productmaster           pdm,
                     qum_quantity_unit_master    qum,
                     ak_corporate                akc,
                     gcd_groupcorporatedetails   gcd
               where poud.corporate_id = pc_corporate_id
                 and poud.process_id = pc_process_id
                 and poud.profit_center_id = cpc.profit_center_id
                 and poud.process_id = tdc.process_id
                 and poud.product_id = pdm.product_id
                 and pdm.base_quantity_unit = qum.qty_unit_id
                 and poud.corporate_id = akc.corporate_id
                 and akc.groupid = gcd.groupid
               group by poud.process_id,
                        tdc.trade_date,
                        tdc.process,
                        poud.corporate_id,
                        akc.groupid,
                        gcd.groupname,
                        poud.product_id,
                        poud.product_name,
                        cpc.profit_center_id,
                        cpc.profit_center_name,
                        cpc.profit_center_short_name,
                        poud.contract_type,
                        poud.cp_profile_id,
                        poud.cp_name,
                        pdm.base_quantity_unit,
                        qum.qty_unit,
                        poud.base_cur_id,
                        poud.base_cur_code) t
       group by t.process_id,
                t.process_date,
                t.process,
                t.corporate_id,
                t.group_id,
                t.group_name,
                t.product_id,
                t.product_name,
                t.profit_center_id,
                t.profit_center_name,
                t.profit_center_short_name,
                t.contract_type,
                t.cp_profile_id,
                t.cp_name,
                t.qty_exp_unit_id,
                t.qty_exp_unit,
                t.value_exp_cur_id,
                t.value_exp_cur_code,
                t.m2m_exp_cur_id,
                t.m2m_exp_cur_code,
                t.credit_exp_cur_id,
                t.credit_exp_cur_code;
commit;                
    ----
    insert into tre_trader_risk_exposure
      (process_id,
       process_date,
       process,
       corporate_id,
       group_id,
       group_name,
       product_id,
       product_name,
       profit_center_id,
       profit_center_name,
       profit_center_short_name,
       contract_type,
       trader_user_id,
       trader_user_name,
       qty_exposure,
       qty_exp_unit_id,
       qty_exp_unit,
       value_exposure,
       value_exp_cur_id,
       value_exp_cur_code,
       m2m_exposure,
       m2m_exp_cur_id,
       m2m_exp_cur_code,
       credit_exposure,
       credit_exp_cur_id,
       credit_exp_cur_code)
      select t.process_id,
             t.process_date,
             t.process,
             t.corporate_id,
             t.group_id,
             t.group_name,
             t.product_id,
             t.product_name,
             t.profit_center_id,
             t.profit_center_name,
             t.profit_center_short_name,
             t.contract_type,
             t.trade_user_id trader_user_id,
             gab.firstname || ' ' || gab.lastname trader_user_name,
             sum(t.qty_exposure) qty_exposure,
             t.qty_exp_unit_id,
             t.qty_exp_unit,
             sum(t.value_exposure) value_exposure,
             t.value_exp_cur_id,
             t.value_exp_cur_code,
             sum(t.m2m_exposure) m2m_exposure,
             t.m2m_exp_cur_id,
             t.m2m_exp_cur_code,
             sum(t.credit_exposure) credit_exposure,
             t.credit_exp_cur_id,
             t.credit_exp_cur_code
        from (select poud.process_id process_id,
                     poud.eod_trade_date process_date,
                     tdc.process process,
                     poud.corporate_id corporate_id,
                     poud.group_id group_id,
                     poud.group_name group_name,
                     poud.product_id product_id,
                     poud.product_name product_name,
                     poud.profit_center_id profit_center_id,
                     poud.profit_center_name profit_center_name,
                     poud.profit_center_short_name profit_center_short_name,
                     poud.contract_type contract_type,
                     poud.trade_user_id,
                     poud.trade_user_name,
                     sum(poud.qty_in_base_unit) qty_exposure,
                     poud.base_qty_unit_id qty_exp_unit_id,
                     poud.base_qty_unit qty_exp_unit,
                     sum(poud.contract_value_in_price_cur *
                         pkg_general.f_get_converted_currency_amt(poud.corporate_id,
                                                                  poud.price_main_cur_id,
                                                                  poud.base_cur_id,
                                                                  poud.eod_trade_date,
                                                                  1)) value_exposure,
                     poud.base_cur_id value_exp_cur_id,
                     poud.base_cur_code value_exp_cur_code,
                     sum(poud.m2m_amt *
                         pkg_general.f_get_converted_currency_amt(poud.corporate_id,
                                                                  poud.m2m_amt_cur_id,
                                                                  poud.base_cur_id,
                                                                  poud.eod_trade_date,
                                                                  1)) m2m_exposure,
                     poud.base_cur_id m2m_exp_cur_id,
                     poud.base_cur_code m2m_exp_cur_code,
                     0 credit_exposure,
                     poud.base_cur_id credit_exp_cur_id,
                     poud.base_cur_code credit_exp_cur_code
                from poud_phy_open_unreal_daily poud,
                     tdc_trade_date_closure     tdc
               where poud.corporate_id = pc_corporate_id
                 and poud.process_id = pc_process_id
                 and poud.process_id = tdc.process_id
               group by poud.process_id,
                        poud.eod_trade_date,
                        tdc.process,
                        poud.corporate_id,
                        poud.group_id,
                        poud.group_name,
                        poud.product_id,
                        poud.product_name,
                        poud.profit_center_id,
                        poud.profit_center_name,
                        poud.profit_center_short_name,
                        poud.contract_type,
                        poud.trade_user_id,
                        poud.trade_user_name,
                        poud.base_qty_unit_id,
                        poud.base_qty_unit,
                        poud.base_cur_id,
                        poud.base_cur_code
              union all
              select poud.process_id,
                     tdc.trade_date process_date,
                     tdc.process,
                     poud.corporate_id,
                     akc.groupid group_id,
                     gcd.groupname group_name,
                     poud.product_id,
                     poud.product_name,
                     cpc.profit_center_id,
                     cpc.profit_center_name,
                     cpc.profit_center_short_name,
                     poud.contract_type,
                     poud.trader_id trade_user_id,
                     poud.trader_name trade_user_name,
                     sum(poud.qty_in_base_unit) qty_exposure,
                     pdm.base_quantity_unit qty_exp_unit_id,
                     qum.qty_unit qty_exp_unit,
                     sum(poud.contract_value_in_price_cur *
                         pkg_general.f_get_converted_currency_amt(poud.corporate_id,
                                                                  poud.contract_price_cur_id,
                                                                  poud.base_cur_id,
                                                                  tdc.trade_date,
                                                                  1)) value_exposure,
                     poud.base_cur_id value_exp_cur_id,
                     poud.base_cur_code value_exp_cur_code,
                     sum(poud.m2m_amt *
                         pkg_general.f_get_converted_currency_amt(poud.corporate_id,
                                                                  poud.m2m_amt_cur_id,
                                                                  poud.base_cur_id,
                                                                  tdc.trade_date,
                                                                  1)) m2m_exposure,
                     poud.base_cur_id m2m_exp_cur_id,
                     poud.base_cur_code m2m_exp_cur_code,
                     0 credit_exposure,
                     poud.base_cur_id credit_exp_cur_id,
                     poud.base_cur_code credit_exp_cur_code
                from psu_phy_stock_unrealized    poud,
                     cpc_corporate_profit_center cpc,
                     tdc_trade_date_closure      tdc,
                     pdm_productmaster           pdm,
                     qum_quantity_unit_master    qum,
                     ak_corporate                akc,
                     gcd_groupcorporatedetails   gcd
               where poud.corporate_id = pc_corporate_id
                 and poud.process_id = pc_process_id
                 and poud.profit_center_id = cpc.profit_center_id
                 and poud.process_id = tdc.process_id
                 and poud.product_id = pdm.product_id
                 and pdm.base_quantity_unit = qum.qty_unit_id
                 and poud.corporate_id = akc.corporate_id
                 and akc.groupid = gcd.groupid
               group by poud.process_id,
                        tdc.trade_date,
                        tdc.process,
                        poud.corporate_id,
                        akc.groupid,
                        gcd.groupname,
                        poud.product_id,
                        poud.product_name,
                        cpc.profit_center_id,
                        cpc.profit_center_name,
                        cpc.profit_center_short_name,
                        poud.contract_type,
                        poud.trader_id,
                        poud.trader_name,
                        pdm.base_quantity_unit,
                        qum.qty_unit,
                        poud.base_cur_id,
                        poud.base_cur_code) t,
             gab_globaladdressbook gab,
             ak_corporate_user aku
       where t.trade_user_id = aku.user_id(+)
         and aku.gabid = gab.gabid(+)
       group by t.process_id,
                t.process_date,
                t.process,
                t.corporate_id,
                t.group_id,
                t.group_name,
                t.product_id,
                t.product_name,
                t.profit_center_id,
                t.profit_center_name,
                t.profit_center_short_name,
                t.contract_type,
                t.trade_user_id,
                gab.firstname || ' ' || gab.lastname,
                t.qty_exp_unit_id,
                t.qty_exp_unit,
                t.value_exp_cur_id,
                t.value_exp_cur_code,
                t.m2m_exp_cur_id,
                t.m2m_exp_cur_code,
                t.credit_exp_cur_id,
                t.credit_exp_cur_code;
commit;
  exception
    when others then
      --dbms_output.put_line('Error in CRC calculation');
      null;
      /*vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'sp_calc_risk_limits',
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
      sp_insert_error_log(vobj_error_log);*/
  end;
  procedure sp_calc_phy_unreal_pnl_attr(pc_corporate_id        varchar2,
                                        pd_trade_date          date,
                                        pd_prev_trade_date     date,
                                        pc_process_id          varchar2,
                                        pc_previous_process_id varchar2,
                                        pc_user_id             varchar2
                                        --------------------------------------------------------------------------------------------------------------------------
                                        --        procedure name                            : sp_calc_phy_unreal_pnl_attr
                                        --        author                                    : AGS REPORTS TEAM
                                        --        created date                              : 11th Jan 2011
                                        --        purpose                                   : populate physical open unrealized pnl
                                        --        parameters
                                        --        pc_corporate_id                           : corporate id
                                        --        pd_trade_date                             : eod date id
                                        --        pc_user_id                                : user id
                                        --        pc_process                                : process
                                        --        modification history
                                        --        modified date                             :
                                        --        modified by                               :
                                        --        modify description                        :
                                        --------------------------------------------------------------------------------------------------------------------------
                                        ) is
    --vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    --vn_eel_error_count number := 1;
    --
    -- New Contract
    --
    cursor unreal_pnl_attr is
      select poud.process_id,
             poud.corporate_id,
             poud.corporate_name,
             'Physical Contract' attribution_type,
             'New Contract' attribution_main_type,
             (case
               when poud.contract_type = 'P' then
                'Purchase'
               when poud.contract_type = 'S' then
                'Sales'
             end) attribution_sub_type,
             (case
               when poud.contract_type = 'P' then
                1.1
               when poud.contract_type = 'S' then
                1.2
             end) attribution_order,
             poud.internal_contract_ref_no,
             poud.internal_contract_item_ref_no,
             poud.contract_ref_no,
             poud.delivery_item_no delivery_item_no,
             pci.del_distribution_item_no,
             poud.contract_type contract_type,
             poud.item_qty item_qty,
             poud.qty_unit_id qty_unit_id,
             poud.qty_unit qty_unit,
             poud.qty_in_base_unit curr_eod_qty,
             poud.qty_unit_id curr_eod_qty_unit_id,
             poud.qty_unit curr_eod_qty_unit,
             poud.contract_price curr_eod_contract_price,
             poud.price_unit_id curr_eod_price_unit_id,
             poud.price_unit_cur_code || '/' || poud.price_unit_weight_unit curr_eod_price_unit,
             poud.unrealized_pnl_in_base_cur net_pnlc_in_base,
             poud.product_id,
             poud.product_name,
             poud.profit_center_id,
             poud.profit_center_name,
             poud.profit_center_short_name,
             poud.base_qty_unit_id,
             poud.base_qty_unit,
             poud.base_cur_id,
             poud.base_cur_code,
             pd_trade_date trade_date,
             pc_previous_process_id prev_process_id,
             pd_prev_trade_date as prev_trade_date
        from poud_phy_open_unreal_daily poud,
             pci_physical_contract_item pci
       where poud.cont_unr_status = 'NEW_TRADE'
         and poud.process_id = pc_process_id
         and poud.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and pci.process_id = poud.process_id;
    --        
    --- Quantity Modification on Contract
    --
    cursor unreal_pnl_attr_mcq is
      select poud.process_id,
             poud.corporate_id,
             poud.corporate_name,
             'Physical Contract' attribution_type,
             'Quantity' attribution_main_type,
             (case
               when poud.contract_type = 'P' then
                'Purchase'
               when poud.contract_type = 'S' then
                'Sales'
               else
                'Others'
             end) attribution_sub_type,
             (case
               when poud.contract_type = 'P' then
                2.1
               when poud.contract_type = 'S' then
                2.2
             end) attribution_order,
             poud.internal_contract_ref_no,
             poud.internal_contract_item_ref_no,
             poud.contract_ref_no,
             poud.delivery_item_no delivery_item_no,
             pci.del_distribution_item_no,
             poud.contract_type contract_type,
             poud.item_qty item_qty,
             poud.qty_unit_id qty_unit_id,
             poud.qty_unit qty_unit,
             poud.qty_in_base_unit curr_eod_qty,
             poud.qty_unit_id curr_eod_qty_unit_id,
             poud.qty_unit curr_eod_qty_unit,
             poud_prev.qty_in_base_unit prev_eod_qty,
             poud.prev_qty_unit_id prev_eod_qty_unit_id,
             poud.contract_price curr_eod_contract_price,
             poud.price_unit_id curr_eod_price_unit_id,
             poud.price_unit_cur_code || '/' || poud.price_unit_weight_unit curr_eod_price_unit,
             poud_prev.contract_price prev_eod_contract_price,
             poud_prev.price_unit_id prev_eod_price_unit_id,
             poud.md_id,
             poud_prev.md_id prev_md_id,
             poud.net_m2m_price,
             poud.m2m_price_unit_id,
             poud_prev.net_m2m_price prev_net_m2m_price,
             poud_prev.m2m_price_unit_id prev_m2m_price_unit_id,
             poud.unrealized_pnl_in_base_cur net_pnlc_in_base,
             poud.product_id,
             poud.product_name,
             poud.profit_center_id,
             poud.profit_center_name,
             poud.profit_center_short_name,
             poud.base_qty_unit_id,
             poud.base_qty_unit,
             poud.base_cur_id,
             poud.base_cur_code,
             pd_trade_date trade_date,
             pc_previous_process_id prev_process_id,
             pd_prev_trade_date as prev_trade_date,
             ppu.price_unit_id price_unit_id_in_pum,
             md.base_price_unit_id_in_pum m2m_base_price_unit_id_in_pum
        from poud_phy_open_unreal_daily poud,
             pci_physical_contract_item pci,
             v_ppu_pum ppu,
             md_m2m_daily md,
             (select *
                from poud_phy_open_unreal_daily poud
               where poud.process_id = pc_previous_process_id) poud_prev
       where poud.cont_unr_status = 'EXISTING_TRADE'
         and poud.qty_in_base_unit <> poud_prev.qty_in_base_unit
         and poud.process_id = pc_process_id
         and poud.internal_contract_item_ref_no =
             poud_prev.internal_contract_item_ref_no
         and poud.pcdi_id = poud_prev.pcdi_id
         and pci.process_id = pc_process_id
         and pci.internal_contract_item_ref_no =
             poud.internal_contract_item_ref_no
         and poud.price_unit_id = ppu.product_price_unit_id
         and poud.md_id = md.md_id
         and md.process_id = pc_process_id;
    --           
    ---Change in Price
    --
    cursor unreal_pnl_attr_price is
      select poud.process_id,
             poud.corporate_id,
             poud.corporate_name,
             'Physical Contract' attribution_type,
             'Pricing' attribution_main_type,
             (case
               when poud.contract_type = 'P' then
                'Purchase'
               when poud.contract_type = 'S' then
                'Sales'
               else
                'Others'
             end) attribution_sub_type,
             (case
               when poud.contract_type = 'P' then
                3.1
               when poud.contract_type = 'S' then
                3.2
             end) attribution_order,
             poud.internal_contract_ref_no,
             poud.internal_contract_item_ref_no,
             poud.contract_ref_no,
             poud.delivery_item_no delivery_item_no,
             pci.del_distribution_item_no,
             poud.contract_type contract_type,
             poud.item_qty item_qty,
             poud.qty_unit_id qty_unit_id,
             poud.qty_unit qty_unit,
             poud.qty_in_base_unit curr_eod_qty,
             poud.qty_unit_id curr_eod_qty_unit_id,
             poud.qty_unit curr_eod_qty_unit,
             poud_prev.qty_in_base_unit prev_eod_qty,
             poud_prev.qty_unit_id prev_eod_qty_unit_id,
             poud.contract_price curr_eod_contract_price,
             poud.price_unit_id curr_eod_price_unit_id,
             poud.price_unit_cur_code || '/' || poud.price_unit_weight_unit curr_eod_price_unit,
             poud_prev.contract_price prev_eod_contract_price,
             poud_prev.price_unit_id prev_eod_price_unit_id,
             poud.md_id,
             poud_prev.md_id prev_md_id,
             poud.net_m2m_price,
             poud.m2m_price_unit_id,
             poud_prev.net_m2m_price prev_net_m2m_price,
             poud_prev.m2m_price_unit_id prev_m2m_price_unit_id,
             poud.unrealized_pnl_in_base_cur net_pnlc_in_base,
             poud.product_id,
             poud.product_name,
             poud.profit_center_id,
             poud.profit_center_name,
             poud.profit_center_short_name,
             poud.base_qty_unit_id,
             poud.base_qty_unit,
             poud.base_cur_id,
             poud.base_cur_code,
             pd_trade_date trade_date,
             pc_previous_process_id prev_process_id,
             pd_prev_trade_date as prev_trade_date,
             ppu.product_price_unit_id price_unit_id_in_base
        from poud_phy_open_unreal_daily poud,
             pci_physical_contract_item pci,
             v_ppu_pum ppu,
             (select *
                from poud_phy_open_unreal_daily poud
               where poud.process_id = pc_previous_process_id) poud_prev
       where poud.cont_unr_status = 'EXISTING_TRADE'
         and poud.contract_price <> poud_prev.contract_price
         and poud.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pci.internal_contract_item_ref_no =
             poud.internal_contract_item_ref_no
         and poud.internal_contract_item_ref_no =
             poud_prev.internal_contract_item_ref_no
         and poud.pcdi_id = poud_prev.pcdi_id
         and ppu.product_id = poud.product_id
         and ppu.cur_id = poud.base_cur_id
         and ppu.weight_unit_id = poud.base_qty_unit_id
         and nvl(ppu.weight, 1) = 1;
    --
    ---Change in Estimates
    --
    cursor unreal_pnl_attr_estimates is
      select poud.process_id,
             poud.corporate_id,
             poud.corporate_name,
             'Physical Contract' attribution_type,
             'Estimates' attribution_main_type,
             (case
               when poud.contract_type = 'P' then
                'Purchase'
               when poud.contract_type = 'S' then
                'Sales'
               else
                'Others'
             end) attribution_sub_type,
             (case
               when poud.contract_type = 'P' then
                4.1
               when poud.contract_type = 'S' then
                4.2
             end) attribution_order,
             poud.internal_contract_ref_no,
             poud.internal_contract_item_ref_no,
             poud.contract_ref_no,
             poud.delivery_item_no delivery_item_no,
             pci.del_distribution_item_no,
             poud.contract_type contract_type,
             poud.item_qty item_qty,
             poud.qty_unit_id qty_unit_id,
             poud.qty_unit qty_unit,
             poud.qty_in_base_unit curr_eod_qty,
             poud.qty_unit_id curr_eod_qty_unit_id,
             poud.qty_unit curr_eod_qty_unit,
             poud_prev.qty_in_base_unit prev_eod_qty,
             poud_prev.qty_unit_id prev_eod_qty_unit_id,
             poud.contract_price curr_eod_contract_price,
             poud.price_unit_id curr_eod_price_unit_id,
             poud.price_unit_cur_code || '/' || poud.price_unit_weight_unit curr_eod_price_unit,
             poud_prev.contract_price prev_eod_contract_price,
             poud_prev.price_unit_id prev_eod_price_unit_id,
             poud.md_id,
             poud_prev.md_id prev_md_id,
             poud.net_m2m_price,
             poud.m2m_price_unit_id,
             poud_prev.net_m2m_price prev_net_m2m_price,
             poud_prev.m2m_price_unit_id prev_m2m_price_unit_id,
             poud.sc_in_base_cur,
             poud_prev.sc_in_base_cur prev_sc_in_base_cur,
             poud.unrealized_pnl_in_base_cur net_pnlc_in_base,
             poud.product_id,
             poud.product_name,
             poud.profit_center_id,
             poud.profit_center_name,
             poud.profit_center_short_name,
             poud.base_qty_unit_id,
             poud.base_qty_unit,
             poud.base_cur_id,
             poud.base_cur_code,
             pd_trade_date trade_date,
             pc_previous_process_id prev_process_id,
             pd_prev_trade_date as prev_trade_date
        from poud_phy_open_unreal_daily poud,
             pci_physical_contract_item pci,
             (select *
                from poud_phy_open_unreal_daily poud
               where poud.process_id = pc_previous_process_id) poud_prev
       where poud.cont_unr_status = 'EXISTING_TRADE'
         and poud.sc_in_base_cur <> poud_prev.sc_in_base_cur
         and poud.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pci.internal_contract_item_ref_no =
             poud.internal_contract_item_ref_no
         and poud.internal_contract_item_ref_no =
             poud_prev.internal_contract_item_ref_no
         and poud.pcdi_id = poud_prev.pcdi_id;
    --
    ---Change in Location differentials
    --
    cursor unreal_pnl_attr_ldc is
      select poud.process_id,
             poud.corporate_id,
             poud.corporate_name,
             'Physical Contract' attribution_type,
             'Location differentials' attribution_main_type,
             (case
               when poud.contract_type = 'P' then
                'Purchase'
               when poud.contract_type = 'S' then
                'Sales'
               else
                'Others'
             end) attribution_sub_type,
             (case
               when poud.contract_type = 'P' then
                5.1
               when poud.contract_type = 'S' then
                5.2
             end) attribution_order,
             poud.internal_contract_ref_no,
             poud.internal_contract_item_ref_no,
             poud.contract_ref_no,
             poud.delivery_item_no delivery_item_no,
             pci.del_distribution_item_no,
             poud.contract_type contract_type,
             poud.item_qty item_qty,
             poud.qty_unit_id qty_unit_id,
             poud.qty_unit qty_unit,
             poud.qty_in_base_unit curr_eod_qty,
             poud.qty_unit_id curr_eod_qty_unit_id,
             poud.qty_unit curr_eod_qty_unit,
             poud_prev.qty_in_base_unit prev_eod_qty,
             poud_prev.qty_unit_id prev_eod_qty_unit_id,
             poud.contract_price curr_eod_contract_price,
             poud.price_unit_id curr_eod_price_unit_id,
             poud.price_unit_cur_code || '/' || poud.price_unit_weight_unit curr_eod_price_unit,
             poud_prev.contract_price prev_eod_contract_price,
             poud_prev.price_unit_id prev_eod_price_unit_id,
             poud.md_id,
             poud_prev.md_id prev_md_id,
             poud.net_m2m_price,
             poud.m2m_price_unit_id,
             poud_prev.net_m2m_price prev_net_m2m_price,
             poud_prev.m2m_price_unit_id prev_m2m_price_unit_id,
             poud.sc_in_base_cur,
             poud_prev.sc_in_base_cur prev_sc_in_base_cur,
             poud.net_m2m_price m2m_settlement_price,
             md.m2m_loc_incoterm_deviation m2m_loc_inco_deviation,
             poud_prev.net_m2m_price prev_m2m_settlement_price,
             md_prev.m2m_loc_incoterm_deviation prev_m2m_loc_inco_deviation,
             poud.unrealized_pnl_in_base_cur net_pnlc_in_base,
             poud.product_id,
             poud.product_name,
             poud.profit_center_id,
             poud.profit_center_name,
             poud.profit_center_short_name,
             poud.base_qty_unit_id,
             poud.base_qty_unit,
             poud.base_cur_id,
             poud.base_cur_code,
             pd_trade_date trade_date,
             pc_previous_process_id prev_process_id,
             pd_prev_trade_date as prev_trade_date
        from poud_phy_open_unreal_daily poud,
             md_m2m_daily md,
             md_m2m_daily md_prev,
             pci_physical_contract_item pci,
             (select *
                from poud_phy_open_unreal_daily poud
               where poud.process_id = pc_previous_process_id) poud_prev
       where poud.cont_unr_status = 'EXISTING_TRADE'
         and md.m2m_loc_incoterm_deviation <>
             md_prev.m2m_loc_incoterm_deviation
         and poud.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pci.internal_contract_item_ref_no =
             poud.internal_contract_item_ref_no
         and poud.internal_contract_item_ref_no =
             poud_prev.internal_contract_item_ref_no
         and poud.pcdi_id = poud_prev.pcdi_id
         and poud.md_id = md.md_id
         and md.process_id = pc_process_id
         and poud_prev.md_id = md_prev.md_id
         and md_prev.process_id = pc_previous_process_id;
    --
    --- Derivative Prices 
    --
    cursor unreal_pnl_attr_m2m_sp is
      select poud.process_id,
             poud.corporate_id,
             poud.corporate_name,
             'Physical Contract' attribution_type,
             'Derivative Prices' attribution_main_type,
             (case
               when poud.contract_type = 'P' then
                'Purchase'
               when poud.contract_type = 'S' then
                'Sales'
               else
                'Others'
             end) attribution_sub_type,
             (case
               when poud.contract_type = 'P' then
                6.1
               when poud.contract_type = 'S' then
                6.2
             end) attribution_order,
             poud.internal_contract_ref_no,
             poud.internal_contract_item_ref_no,
             poud.contract_ref_no,
             poud.delivery_item_no delivery_item_no,
             pci.del_distribution_item_no,
             poud.contract_type contract_type,
             poud.item_qty item_qty,
             poud.qty_unit_id qty_unit_id,
             poud.qty_unit qty_unit,
             poud.qty_in_base_unit curr_eod_qty,
             poud.qty_unit_id curr_eod_qty_unit_id,
             poud.qty_unit curr_eod_qty_unit,
             poud_prev.qty_in_base_unit prev_eod_qty,
             poud_prev.qty_unit_id prev_eod_qty_unit_id,
             poud.contract_price curr_eod_contract_price,
             poud.price_unit_id curr_eod_price_unit_id,
             poud.price_unit_cur_code || '/' || poud.price_unit_weight_unit curr_eod_price_unit,
             poud_prev.contract_price prev_eod_contract_price,
             poud_prev.price_unit_id prev_eod_price_unit_id,
             poud.md_id,
             poud_prev.md_id prev_md_id,
             poud.net_m2m_price,
             poud.m2m_price_unit_id,
             poud.net_m2m_price prev_net_m2m_price,
             poud_prev.m2m_price_unit_id prev_m2m_price_unit_id,
             poud.sc_in_base_cur,
             poud_prev.sc_in_base_cur prev_sc_in_base_cur,
             poud.net_m2m_price m2m_settlement_price,
             md.m2m_loc_incoterm_deviation m2m_loc_inco_deviation,
             poud_prev.net_m2m_price prev_m2m_settlement_price,
             md_prev.m2m_loc_incoterm_deviation prev_m2m_loc_inco_deviation,
             poud.unrealized_pnl_in_base_cur net_pnlc_in_base,
             poud.product_id,
             poud.product_name,
             poud.profit_center_id,
             poud.profit_center_name,
             poud.profit_center_short_name,
             poud.base_qty_unit_id,
             poud.base_qty_unit,
             poud.base_cur_id,
             poud.base_cur_code,
             pd_trade_date trade_date,
             pc_previous_process_id prev_process_id,
             pd_prev_trade_date as prev_trade_date,
             md.base_price_unit_id_in_pum m2m_base_price_unit_id_in_pum
        from poud_phy_open_unreal_daily poud,
             pci_physical_contract_item pci,
             md_m2m_daily md,
             md_m2m_daily md_prev,
             (select *
                from poud_phy_open_unreal_daily poud
               where poud.process_id = pc_previous_process_id) poud_prev
       where poud.cont_unr_status = 'EXISTING_TRADE'
         and poud.net_m2m_price <> poud_prev.net_m2m_price
         and poud.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pci.internal_contract_item_ref_no =
             poud.internal_contract_item_ref_no
         and poud.internal_contract_item_ref_no =
             poud_prev.internal_contract_item_ref_no
         and poud.pcdi_id = poud_prev.pcdi_id
         and poud.md_id = md.md_id
         and md.process_id = pc_process_id
         and poud_prev.md_id = md_prev.md_id
         and md_prev.process_id = pc_process_id;
    vn_pnlc_due_to_attr   number := 0;
    vn_other_pnlc_in_base number := 0;
  begin
    --
    -- New Contracts
    --
    for unreal_pnl_attr_rows in unreal_pnl_attr
    loop
      insert into upad_unreal_pnl_attr_detail
        (process_id,
         corporate_id,
         corporate_name,
         attribution_type,
         attribution_main_type,
         attribution_sub_type,
         attribution_order,
         internal_contract_ref_no,
         internal_contract_item_ref_no,
         contract_ref_no,
         delivery_item_no,
         del_distribution_item_no,
         contract_type,
         item_qty,
         qty_unit_id,
         curr_eod_qty,
         curr_eod_qty_unit_id,
         curr_eod_contract_price,
         curr_eod_price_unit_id,
         net_pnlc_in_base,
         product_id,
         product_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         base_qty_unit_id,
         base_qty_unit,
         base_cur_id,
         base_cur_code,
         trade_date,
         prev_process_id,
         prev_trade_date)
      values
        (pc_process_id,
         unreal_pnl_attr_rows.corporate_id,
         unreal_pnl_attr_rows.corporate_name,
         unreal_pnl_attr_rows.attribution_type,
         unreal_pnl_attr_rows.attribution_main_type,
         unreal_pnl_attr_rows.attribution_sub_type,
         unreal_pnl_attr_rows.attribution_order,
         unreal_pnl_attr_rows.internal_contract_ref_no,
         unreal_pnl_attr_rows.internal_contract_item_ref_no,
         unreal_pnl_attr_rows.contract_ref_no,
         unreal_pnl_attr_rows.delivery_item_no,
         unreal_pnl_attr_rows.del_distribution_item_no,
         unreal_pnl_attr_rows.contract_type,
         unreal_pnl_attr_rows.item_qty,
         unreal_pnl_attr_rows.qty_unit_id,
         unreal_pnl_attr_rows.curr_eod_qty,
         unreal_pnl_attr_rows.curr_eod_qty_unit_id,
         unreal_pnl_attr_rows.curr_eod_contract_price,
         unreal_pnl_attr_rows.curr_eod_price_unit_id,
         unreal_pnl_attr_rows.net_pnlc_in_base,
         unreal_pnl_attr_rows.product_id,
         unreal_pnl_attr_rows.product_name,
         unreal_pnl_attr_rows.profit_center_id,
         unreal_pnl_attr_rows.profit_center_name,
         unreal_pnl_attr_rows.profit_center_short_name,
         unreal_pnl_attr_rows.base_qty_unit_id,
         unreal_pnl_attr_rows.base_qty_unit,
         unreal_pnl_attr_rows.base_cur_id,
         unreal_pnl_attr_rows.base_cur_code,
         unreal_pnl_attr_rows.trade_date,
         unreal_pnl_attr_rows.prev_process_id,
         unreal_pnl_attr_rows.prev_trade_date);
    end loop;
    commit;
    --
    --- Quantity Modification on Contract
    --
    for unreal_pnl_attr_mcq_rows in unreal_pnl_attr_mcq
    loop
    
      if unreal_pnl_attr_mcq_rows.contract_type = 'P' then
        vn_pnlc_due_to_attr := ((unreal_pnl_attr_mcq_rows.curr_eod_qty -
                               nvl(unreal_pnl_attr_mcq_rows.prev_eod_qty,
                                     0)) *
                               ((pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                                      unreal_pnl_attr_mcq_rows.prev_net_m2m_price,
                                                                                      unreal_pnl_attr_mcq_rows.m2m_price_unit_id,
                                                                                      unreal_pnl_attr_mcq_rows.m2m_base_price_unit_id_in_pum,
                                                                                      pd_trade_date,
                                                                                      unreal_pnl_attr_mcq_rows.product_id)) -
                               (pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                                      unreal_pnl_attr_mcq_rows.prev_eod_contract_price,
                                                                                      unreal_pnl_attr_mcq_rows.price_unit_id_in_pum,
                                                                                      unreal_pnl_attr_mcq_rows.m2m_base_price_unit_id_in_pum,
                                                                                      pd_trade_date,
                                                                                      unreal_pnl_attr_mcq_rows.product_id))));
      elsif unreal_pnl_attr_mcq_rows.contract_type = 'S' then
        vn_pnlc_due_to_attr := ((unreal_pnl_attr_mcq_rows.curr_eod_qty -
                               nvl(unreal_pnl_attr_mcq_rows.prev_eod_qty,
                                     0)) *
                               ((pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                                      unreal_pnl_attr_mcq_rows.prev_eod_contract_price,
                                                                                      unreal_pnl_attr_mcq_rows.price_unit_id_in_pum,
                                                                                      unreal_pnl_attr_mcq_rows.m2m_base_price_unit_id_in_pum,
                                                                                      pd_trade_date,
                                                                                      unreal_pnl_attr_mcq_rows.product_id)) -
                               (pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                                      unreal_pnl_attr_mcq_rows.prev_net_m2m_price,
                                                                                      unreal_pnl_attr_mcq_rows.m2m_price_unit_id,
                                                                                      unreal_pnl_attr_mcq_rows.m2m_base_price_unit_id_in_pum,
                                                                                      pd_trade_date,
                                                                                      unreal_pnl_attr_mcq_rows.product_id))));
      end if;
    
      vn_other_pnlc_in_base := unreal_pnl_attr_mcq_rows.net_pnlc_in_base -
                               vn_pnlc_due_to_attr;
      insert into upad_unreal_pnl_attr_detail
        (process_id,
         corporate_id,
         corporate_name,
         attribution_type,
         attribution_main_type,
         attribution_sub_type,
         attribution_order,
         internal_contract_ref_no,
         internal_contract_item_ref_no,
         contract_ref_no,
         delivery_item_no,
         del_distribution_item_no,
         contract_type,
         item_qty,
         qty_unit_id,
         curr_eod_qty,
         curr_eod_qty_unit_id,
         prev_eod_qty,
         prev_eod_qty_unit_id,
         curr_eod_contract_price,
         curr_eod_price_unit_id,
         prev_eod_contract_price,
         prev_eod_price_unit_id,
         md_id,
         prev_md_id,
         net_m2m_price,
         m2m_price_unit_id,
         prev_net_m2m_price,
         prev_m2m_price_unit_id,
         pnlc_due_to_attr,
         delta_pnlc_in_base,
         net_pnlc_in_base,
         product_id,
         product_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         base_qty_unit_id,
         base_qty_unit,
         base_cur_id,
         base_cur_code,
         trade_date,
         prev_process_id,
         prev_trade_date)
      values
        (pc_process_id,
         unreal_pnl_attr_mcq_rows.corporate_id,
         unreal_pnl_attr_mcq_rows.corporate_name,
         unreal_pnl_attr_mcq_rows.attribution_type,
         unreal_pnl_attr_mcq_rows.attribution_main_type,
         unreal_pnl_attr_mcq_rows.attribution_sub_type,
         unreal_pnl_attr_mcq_rows.attribution_order,
         unreal_pnl_attr_mcq_rows.internal_contract_ref_no,
         unreal_pnl_attr_mcq_rows.internal_contract_item_ref_no,
         unreal_pnl_attr_mcq_rows.contract_ref_no,
         unreal_pnl_attr_mcq_rows.delivery_item_no,
         unreal_pnl_attr_mcq_rows.del_distribution_item_no,
         unreal_pnl_attr_mcq_rows.contract_type,
         unreal_pnl_attr_mcq_rows.item_qty,
         unreal_pnl_attr_mcq_rows.qty_unit_id,
         unreal_pnl_attr_mcq_rows.curr_eod_qty,
         unreal_pnl_attr_mcq_rows.curr_eod_qty_unit_id,
         unreal_pnl_attr_mcq_rows.prev_eod_qty,
         unreal_pnl_attr_mcq_rows.prev_eod_qty_unit_id,
         unreal_pnl_attr_mcq_rows.curr_eod_contract_price,
         unreal_pnl_attr_mcq_rows.curr_eod_price_unit_id,
         unreal_pnl_attr_mcq_rows.prev_eod_contract_price,
         unreal_pnl_attr_mcq_rows.prev_eod_price_unit_id,
         unreal_pnl_attr_mcq_rows.md_id,
         unreal_pnl_attr_mcq_rows.prev_md_id,
         unreal_pnl_attr_mcq_rows.net_m2m_price,
         unreal_pnl_attr_mcq_rows.m2m_price_unit_id,
         unreal_pnl_attr_mcq_rows.prev_net_m2m_price,
         unreal_pnl_attr_mcq_rows.prev_m2m_price_unit_id,
         vn_pnlc_due_to_attr,
         vn_other_pnlc_in_base,
         unreal_pnl_attr_mcq_rows.net_pnlc_in_base,
         unreal_pnl_attr_mcq_rows.product_id,
         unreal_pnl_attr_mcq_rows.product_name,
         unreal_pnl_attr_mcq_rows.profit_center_id,
         unreal_pnl_attr_mcq_rows.profit_center_name,
         unreal_pnl_attr_mcq_rows.profit_center_short_name,
         unreal_pnl_attr_mcq_rows.base_qty_unit_id,
         unreal_pnl_attr_mcq_rows.base_qty_unit,
         unreal_pnl_attr_mcq_rows.base_cur_id,
         unreal_pnl_attr_mcq_rows.base_cur_code,
         unreal_pnl_attr_mcq_rows.trade_date,
         unreal_pnl_attr_mcq_rows.prev_process_id,
         unreal_pnl_attr_mcq_rows.prev_trade_date);
    end loop;
    commit;
    --
    -- Change in Price
    --
    for unreal_pnl_attr_price_rows in unreal_pnl_attr_price
    loop
      if unreal_pnl_attr_price_rows.contract_type = 'P' then
        vn_pnlc_due_to_attr := (((pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                                  unreal_pnl_attr_price_rows.prev_eod_contract_price,
                                                                                  unreal_pnl_attr_price_rows.prev_eod_price_unit_id,
                                                                                  unreal_pnl_attr_price_rows.price_unit_id_in_base,
                                                                                  pd_trade_date)) -
                               (pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                                  nvl(unreal_pnl_attr_price_rows.curr_eod_contract_price,
                                                                                      0),
                                                                                  unreal_pnl_attr_price_rows.curr_eod_price_unit_id,
                                                                                  unreal_pnl_attr_price_rows.price_unit_id_in_base,
                                                                                  pd_trade_date))) *
                               (nvl(unreal_pnl_attr_price_rows.prev_eod_qty,
                                     0)));
      elsif unreal_pnl_attr_price_rows.contract_type = 'S' then
        vn_pnlc_due_to_attr := (((pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                                  nvl(unreal_pnl_attr_price_rows.curr_eod_contract_price,
                                                                                      0),
                                                                                  unreal_pnl_attr_price_rows.curr_eod_price_unit_id,
                                                                                  unreal_pnl_attr_price_rows.price_unit_id_in_base,
                                                                                  pd_trade_date)) -
                               (pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                                  unreal_pnl_attr_price_rows.prev_eod_contract_price,
                                                                                  unreal_pnl_attr_price_rows.prev_eod_price_unit_id,
                                                                                  unreal_pnl_attr_price_rows.price_unit_id_in_base,
                                                                                  pd_trade_date)) *
                               (nvl(unreal_pnl_attr_price_rows.prev_eod_qty,
                                      0))));
      end if;
    
      vn_other_pnlc_in_base := unreal_pnl_attr_price_rows.net_pnlc_in_base -
                               vn_pnlc_due_to_attr;
      insert into upad_unreal_pnl_attr_detail
        (process_id,
         corporate_id,
         corporate_name,
         attribution_type,
         attribution_main_type,
         attribution_sub_type,
         attribution_order,
         internal_contract_ref_no,
         internal_contract_item_ref_no,
         contract_ref_no,
         delivery_item_no,
         del_distribution_item_no,
         contract_type,
         item_qty,
         qty_unit_id,
         curr_eod_qty,
         curr_eod_qty_unit_id,
         prev_eod_qty,
         prev_eod_qty_unit_id,
         curr_eod_contract_price,
         curr_eod_price_unit_id,
         prev_eod_contract_price,
         prev_eod_price_unit_id,
         md_id,
         prev_md_id,
         net_m2m_price,
         m2m_price_unit_id,
         prev_net_m2m_price,
         prev_m2m_price_unit_id,
         pnlc_due_to_attr,
         delta_pnlc_in_base,
         net_pnlc_in_base,
         product_id,
         product_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         base_qty_unit_id,
         base_qty_unit,
         base_cur_id,
         base_cur_code,
         trade_date,
         prev_process_id,
         prev_trade_date)
      values
        (pc_process_id,
         unreal_pnl_attr_price_rows.corporate_id,
         unreal_pnl_attr_price_rows.corporate_name,
         unreal_pnl_attr_price_rows.attribution_type,
         unreal_pnl_attr_price_rows.attribution_main_type,
         unreal_pnl_attr_price_rows.attribution_sub_type,
         unreal_pnl_attr_price_rows.attribution_order,
         unreal_pnl_attr_price_rows.internal_contract_ref_no,
         unreal_pnl_attr_price_rows.internal_contract_item_ref_no,
         unreal_pnl_attr_price_rows.contract_ref_no,
         unreal_pnl_attr_price_rows.delivery_item_no,
         unreal_pnl_attr_price_rows.del_distribution_item_no,
         unreal_pnl_attr_price_rows.contract_type,
         unreal_pnl_attr_price_rows.item_qty,
         unreal_pnl_attr_price_rows.qty_unit_id,
         unreal_pnl_attr_price_rows.curr_eod_qty,
         unreal_pnl_attr_price_rows.curr_eod_qty_unit_id,
         unreal_pnl_attr_price_rows.prev_eod_qty,
         unreal_pnl_attr_price_rows.prev_eod_qty_unit_id,
         unreal_pnl_attr_price_rows.curr_eod_contract_price,
         unreal_pnl_attr_price_rows.curr_eod_price_unit_id,
         unreal_pnl_attr_price_rows.prev_eod_contract_price,
         unreal_pnl_attr_price_rows.prev_eod_price_unit_id,
         unreal_pnl_attr_price_rows.md_id,
         unreal_pnl_attr_price_rows.prev_md_id,
         unreal_pnl_attr_price_rows.net_m2m_price,
         unreal_pnl_attr_price_rows.m2m_price_unit_id,
         unreal_pnl_attr_price_rows.prev_net_m2m_price,
         unreal_pnl_attr_price_rows.prev_m2m_price_unit_id,
         vn_pnlc_due_to_attr,
         vn_other_pnlc_in_base,
         unreal_pnl_attr_price_rows.net_pnlc_in_base,
         unreal_pnl_attr_price_rows.product_id,
         unreal_pnl_attr_price_rows.product_name,
         unreal_pnl_attr_price_rows.profit_center_id,
         unreal_pnl_attr_price_rows.profit_center_name,
         unreal_pnl_attr_price_rows.profit_center_short_name,
         unreal_pnl_attr_price_rows.base_qty_unit_id,
         unreal_pnl_attr_price_rows.base_qty_unit,
         unreal_pnl_attr_price_rows.base_cur_id,
         unreal_pnl_attr_price_rows.base_cur_code,
         unreal_pnl_attr_price_rows.trade_date,
         unreal_pnl_attr_price_rows.prev_process_id,
         unreal_pnl_attr_price_rows.prev_trade_date);
    end loop;
    commit;
    --
    --Change in Estimates
    --
    for unreal_pnl_attr_estimates_rows in unreal_pnl_attr_estimates
    loop
      if unreal_pnl_attr_estimates_rows.contract_type = 'P' then
        vn_pnlc_due_to_attr := ((unreal_pnl_attr_estimates_rows.prev_sc_in_base_cur -
                               nvl(unreal_pnl_attr_estimates_rows.sc_in_base_cur,
                                     0)));
      elsif unreal_pnl_attr_estimates_rows.contract_type = 'S' then
        vn_pnlc_due_to_attr := ((unreal_pnl_attr_estimates_rows.sc_in_base_cur -
                               nvl(unreal_pnl_attr_estimates_rows.prev_sc_in_base_cur,
                                     0)));
      end if;
      vn_other_pnlc_in_base := unreal_pnl_attr_estimates_rows.net_pnlc_in_base -
                               vn_pnlc_due_to_attr;
      insert into upad_unreal_pnl_attr_detail
        (process_id,
         corporate_id,
         corporate_name,
         attribution_type,
         attribution_main_type,
         attribution_sub_type,
         attribution_order,
         internal_contract_ref_no,
         internal_contract_item_ref_no,
         contract_ref_no,
         delivery_item_no,
         del_distribution_item_no,
         contract_type,
         item_qty,
         qty_unit_id,
         curr_eod_qty,
         curr_eod_qty_unit_id,
         prev_eod_qty,
         prev_eod_qty_unit_id,
         curr_eod_contract_price,
         curr_eod_price_unit_id,
         prev_eod_contract_price,
         prev_eod_price_unit_id,
         curr_sc_in_base_cur,
         prev_sc_in_base_cur,
         md_id,
         prev_md_id,
         net_m2m_price,
         m2m_price_unit_id,
         prev_net_m2m_price,
         prev_m2m_price_unit_id,
         pnlc_due_to_attr,
         delta_pnlc_in_base,
         net_pnlc_in_base,
         product_id,
         product_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         base_qty_unit_id,
         base_qty_unit,
         base_cur_id,
         base_cur_code,
         trade_date,
         prev_process_id,
         prev_trade_date)
      values
        (pc_process_id,
         unreal_pnl_attr_estimates_rows.corporate_id,
         unreal_pnl_attr_estimates_rows.corporate_name,
         unreal_pnl_attr_estimates_rows.attribution_type,
         unreal_pnl_attr_estimates_rows.attribution_main_type,
         unreal_pnl_attr_estimates_rows.attribution_sub_type,
         unreal_pnl_attr_estimates_rows.attribution_order,
         unreal_pnl_attr_estimates_rows.internal_contract_ref_no,
         unreal_pnl_attr_estimates_rows.internal_contract_item_ref_no,
         unreal_pnl_attr_estimates_rows.contract_ref_no,
         unreal_pnl_attr_estimates_rows.delivery_item_no,
         unreal_pnl_attr_estimates_rows.del_distribution_item_no,
         unreal_pnl_attr_estimates_rows.contract_type,
         unreal_pnl_attr_estimates_rows.item_qty,
         unreal_pnl_attr_estimates_rows.qty_unit_id,
         unreal_pnl_attr_estimates_rows.curr_eod_qty,
         unreal_pnl_attr_estimates_rows.curr_eod_qty_unit_id,
         unreal_pnl_attr_estimates_rows.prev_eod_qty,
         unreal_pnl_attr_estimates_rows.prev_eod_qty_unit_id,
         unreal_pnl_attr_estimates_rows.curr_eod_contract_price,
         unreal_pnl_attr_estimates_rows.curr_eod_price_unit_id,
         unreal_pnl_attr_estimates_rows.prev_eod_contract_price,
         unreal_pnl_attr_estimates_rows.prev_eod_price_unit_id,
         unreal_pnl_attr_estimates_rows.sc_in_base_cur,
         unreal_pnl_attr_estimates_rows.prev_sc_in_base_cur,
         unreal_pnl_attr_estimates_rows.md_id,
         unreal_pnl_attr_estimates_rows.prev_md_id,
         unreal_pnl_attr_estimates_rows.net_m2m_price,
         unreal_pnl_attr_estimates_rows.m2m_price_unit_id,
         unreal_pnl_attr_estimates_rows.prev_net_m2m_price,
         unreal_pnl_attr_estimates_rows.prev_m2m_price_unit_id,
         vn_pnlc_due_to_attr,
         vn_other_pnlc_in_base,
         unreal_pnl_attr_estimates_rows.net_pnlc_in_base,
         unreal_pnl_attr_estimates_rows.product_id,
         unreal_pnl_attr_estimates_rows.product_name,
         unreal_pnl_attr_estimates_rows.profit_center_id,
         unreal_pnl_attr_estimates_rows.profit_center_name,
         unreal_pnl_attr_estimates_rows.profit_center_short_name,
         unreal_pnl_attr_estimates_rows.base_qty_unit_id,
         unreal_pnl_attr_estimates_rows.base_qty_unit,
         unreal_pnl_attr_estimates_rows.base_cur_id,
         unreal_pnl_attr_estimates_rows.base_cur_code,
         unreal_pnl_attr_estimates_rows.trade_date,
         unreal_pnl_attr_estimates_rows.prev_process_id,
         unreal_pnl_attr_estimates_rows.prev_trade_date);
    end loop;
    commit;
    --
    -- Change in Location differentials
    --
    for unreal_pnl_attr_ldc_rows in unreal_pnl_attr_ldc
    loop
      if unreal_pnl_attr_ldc_rows.contract_type = 'P' then
        vn_pnlc_due_to_attr := ((unreal_pnl_attr_ldc_rows.m2m_loc_inco_deviation -
                               nvl(unreal_pnl_attr_ldc_rows.prev_m2m_loc_inco_deviation,
                                     0)) * (nvl(unreal_pnl_attr_ldc_rows.prev_eod_qty,
                                                 0)));
      elsif unreal_pnl_attr_ldc_rows.contract_type = 'S' then
        vn_pnlc_due_to_attr := ((unreal_pnl_attr_ldc_rows.prev_m2m_loc_inco_deviation -
                               nvl(unreal_pnl_attr_ldc_rows.m2m_loc_inco_deviation,
                                     0)) * (nvl(unreal_pnl_attr_ldc_rows.prev_eod_qty,
                                                 0)));
      end if;
      vn_other_pnlc_in_base := unreal_pnl_attr_ldc_rows.net_pnlc_in_base -
                               vn_pnlc_due_to_attr;
      insert into upad_unreal_pnl_attr_detail
        (process_id,
         corporate_id,
         corporate_name,
         attribution_type,
         attribution_main_type,
         attribution_sub_type,
         attribution_order,
         internal_contract_ref_no,
         internal_contract_item_ref_no,
         contract_ref_no,
         delivery_item_no,
         del_distribution_item_no,
         contract_type,
         item_qty,
         qty_unit_id,
         curr_eod_qty,
         curr_eod_qty_unit_id,
         prev_eod_qty,
         prev_eod_qty_unit_id,
         curr_eod_contract_price,
         curr_eod_price_unit_id,
         prev_eod_contract_price,
         prev_eod_price_unit_id,
         md_id,
         prev_md_id,
         net_m2m_price,
         m2m_price_unit_id,
         prev_net_m2m_price,
         prev_m2m_price_unit_id,
         m2m_loc_inco_deviation,
         prev_m2m_loc_inco_deviation,
         pnlc_due_to_attr,
         delta_pnlc_in_base,
         net_pnlc_in_base,
         product_id,
         product_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         base_qty_unit_id,
         base_qty_unit,
         base_cur_id,
         base_cur_code,
         trade_date,
         prev_process_id,
         prev_trade_date)
      values
        (pc_process_id,
         unreal_pnl_attr_ldc_rows.corporate_id,
         unreal_pnl_attr_ldc_rows.corporate_name,
         unreal_pnl_attr_ldc_rows.attribution_type,
         unreal_pnl_attr_ldc_rows.attribution_main_type,
         unreal_pnl_attr_ldc_rows.attribution_sub_type,
         unreal_pnl_attr_ldc_rows.attribution_order,
         unreal_pnl_attr_ldc_rows.internal_contract_ref_no,
         unreal_pnl_attr_ldc_rows.internal_contract_item_ref_no,
         unreal_pnl_attr_ldc_rows.contract_ref_no,
         unreal_pnl_attr_ldc_rows.delivery_item_no,
         unreal_pnl_attr_ldc_rows.del_distribution_item_no,
         unreal_pnl_attr_ldc_rows.contract_type,
         unreal_pnl_attr_ldc_rows.item_qty,
         unreal_pnl_attr_ldc_rows.qty_unit_id,
         unreal_pnl_attr_ldc_rows.curr_eod_qty,
         unreal_pnl_attr_ldc_rows.curr_eod_qty_unit_id,
         unreal_pnl_attr_ldc_rows.prev_eod_qty,
         unreal_pnl_attr_ldc_rows.prev_eod_qty_unit_id,
         unreal_pnl_attr_ldc_rows.curr_eod_contract_price,
         unreal_pnl_attr_ldc_rows.curr_eod_price_unit_id,
         unreal_pnl_attr_ldc_rows.prev_eod_contract_price,
         unreal_pnl_attr_ldc_rows.prev_eod_price_unit_id,
         unreal_pnl_attr_ldc_rows.md_id,
         unreal_pnl_attr_ldc_rows.prev_md_id,
         unreal_pnl_attr_ldc_rows.net_m2m_price,
         unreal_pnl_attr_ldc_rows.m2m_price_unit_id,
         unreal_pnl_attr_ldc_rows.prev_net_m2m_price,
         unreal_pnl_attr_ldc_rows.prev_m2m_price_unit_id,
         unreal_pnl_attr_ldc_rows.m2m_loc_inco_deviation,
         unreal_pnl_attr_ldc_rows.prev_m2m_loc_inco_deviation,
         vn_pnlc_due_to_attr,
         vn_other_pnlc_in_base,
         unreal_pnl_attr_ldc_rows.net_pnlc_in_base,
         unreal_pnl_attr_ldc_rows.product_id,
         unreal_pnl_attr_ldc_rows.product_name,
         unreal_pnl_attr_ldc_rows.profit_center_id,
         unreal_pnl_attr_ldc_rows.profit_center_name,
         unreal_pnl_attr_ldc_rows.profit_center_short_name,
         unreal_pnl_attr_ldc_rows.base_qty_unit_id,
         unreal_pnl_attr_ldc_rows.base_qty_unit,
         unreal_pnl_attr_ldc_rows.base_cur_id,
         unreal_pnl_attr_ldc_rows.base_cur_code,
         unreal_pnl_attr_ldc_rows.trade_date,
         unreal_pnl_attr_ldc_rows.prev_process_id,
         unreal_pnl_attr_ldc_rows.prev_trade_date);
    end loop;
    commit;
    --
    -- M2M Price Change
    --
    for unreal_pnl_attr_m2m_sp_rows in unreal_pnl_attr_m2m_sp
    loop
      if unreal_pnl_attr_m2m_sp_rows.contract_type = 'P' then
        vn_pnlc_due_to_attr := (((pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                                      unreal_pnl_attr_m2m_sp_rows.m2m_settlement_price,
                                                                                      unreal_pnl_attr_m2m_sp_rows.m2m_price_unit_id,
                                                                                      unreal_pnl_attr_m2m_sp_rows.m2m_base_price_unit_id_in_pum,
                                                                                      pd_trade_date,
                                                                                      unreal_pnl_attr_m2m_sp_rows.product_id)) -
                               (pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                                      nvl(unreal_pnl_attr_m2m_sp_rows.prev_m2m_settlement_price,
                                                                                          0),
                                                                                      unreal_pnl_attr_m2m_sp_rows.m2m_price_unit_id,
                                                                                      unreal_pnl_attr_m2m_sp_rows.m2m_base_price_unit_id_in_pum,
                                                                                      pd_trade_date,
                                                                                      unreal_pnl_attr_m2m_sp_rows.product_id))) *
                               (nvl(unreal_pnl_attr_m2m_sp_rows.prev_eod_qty,
                                     0)));
      elsif unreal_pnl_attr_m2m_sp_rows.contract_type = 'S' then
        vn_pnlc_due_to_attr := (((pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                                      nvl(unreal_pnl_attr_m2m_sp_rows.prev_m2m_settlement_price,
                                                                                          0),
                                                                                      unreal_pnl_attr_m2m_sp_rows.m2m_price_unit_id,
                                                                                      unreal_pnl_attr_m2m_sp_rows.m2m_base_price_unit_id_in_pum,
                                                                                      pd_trade_date,
                                                                                      unreal_pnl_attr_m2m_sp_rows.product_id)) -
                               (pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                                      nvl(unreal_pnl_attr_m2m_sp_rows.m2m_settlement_price,
                                                                                          0),
                                                                                      unreal_pnl_attr_m2m_sp_rows.m2m_price_unit_id,
                                                                                      unreal_pnl_attr_m2m_sp_rows.m2m_base_price_unit_id_in_pum,
                                                                                      pd_trade_date,
                                                                                      unreal_pnl_attr_m2m_sp_rows.product_id))
                               
                               ) * (nvl(unreal_pnl_attr_m2m_sp_rows.prev_eod_qty,
                                         0)));
      end if;
      vn_other_pnlc_in_base := unreal_pnl_attr_m2m_sp_rows.net_pnlc_in_base -
                               vn_pnlc_due_to_attr;
      insert into upad_unreal_pnl_attr_detail
        (process_id,
         corporate_id,
         corporate_name,
         attribution_type,
         attribution_main_type,
         attribution_sub_type,
         attribution_order,
         internal_contract_ref_no,
         internal_contract_item_ref_no,
         contract_ref_no,
         delivery_item_no,
         del_distribution_item_no,
         contract_type,
         item_qty,
         qty_unit_id,
         curr_eod_qty,
         curr_eod_qty_unit_id,
         prev_eod_qty,
         prev_eod_qty_unit_id,
         curr_eod_contract_price,
         curr_eod_price_unit_id,
         prev_eod_contract_price,
         prev_eod_price_unit_id,
         md_id,
         prev_md_id,
         net_m2m_price,
         m2m_price_unit_id,
         prev_net_m2m_price,
         prev_m2m_price_unit_id,
         m2m_settlement_price,
         prev_m2m_settlement_price,
         pnlc_due_to_attr,
         delta_pnlc_in_base,
         net_pnlc_in_base,
         product_id,
         product_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         base_qty_unit_id,
         base_qty_unit,
         base_cur_id,
         base_cur_code,
         trade_date,
         prev_process_id,
         prev_trade_date)
      values
        (pc_process_id,
         unreal_pnl_attr_m2m_sp_rows.corporate_id,
         unreal_pnl_attr_m2m_sp_rows.corporate_name,
         unreal_pnl_attr_m2m_sp_rows.attribution_type,
         unreal_pnl_attr_m2m_sp_rows.attribution_main_type,
         unreal_pnl_attr_m2m_sp_rows.attribution_sub_type,
         unreal_pnl_attr_m2m_sp_rows.attribution_order,
         unreal_pnl_attr_m2m_sp_rows.internal_contract_ref_no,
         unreal_pnl_attr_m2m_sp_rows.internal_contract_item_ref_no,
         unreal_pnl_attr_m2m_sp_rows.contract_ref_no,
         unreal_pnl_attr_m2m_sp_rows.delivery_item_no,
         unreal_pnl_attr_m2m_sp_rows.del_distribution_item_no,
         unreal_pnl_attr_m2m_sp_rows.contract_type,
         unreal_pnl_attr_m2m_sp_rows.item_qty,
         unreal_pnl_attr_m2m_sp_rows.qty_unit_id,
         unreal_pnl_attr_m2m_sp_rows.curr_eod_qty,
         unreal_pnl_attr_m2m_sp_rows.curr_eod_qty_unit_id,
         unreal_pnl_attr_m2m_sp_rows.prev_eod_qty,
         unreal_pnl_attr_m2m_sp_rows.prev_eod_qty_unit_id,
         unreal_pnl_attr_m2m_sp_rows.curr_eod_contract_price,
         unreal_pnl_attr_m2m_sp_rows.curr_eod_price_unit_id,
         unreal_pnl_attr_m2m_sp_rows.prev_eod_contract_price,
         unreal_pnl_attr_m2m_sp_rows.prev_eod_price_unit_id,
         unreal_pnl_attr_m2m_sp_rows.md_id,
         unreal_pnl_attr_m2m_sp_rows.prev_md_id,
         unreal_pnl_attr_m2m_sp_rows.net_m2m_price,
         unreal_pnl_attr_m2m_sp_rows.m2m_price_unit_id,
         unreal_pnl_attr_m2m_sp_rows.prev_net_m2m_price,
         unreal_pnl_attr_m2m_sp_rows.prev_m2m_price_unit_id,
         unreal_pnl_attr_m2m_sp_rows.m2m_settlement_price,
         unreal_pnl_attr_m2m_sp_rows.prev_m2m_settlement_price,
         vn_pnlc_due_to_attr,
         vn_other_pnlc_in_base,
         unreal_pnl_attr_m2m_sp_rows.net_pnlc_in_base,
         unreal_pnl_attr_m2m_sp_rows.product_id,
         unreal_pnl_attr_m2m_sp_rows.product_name,
         unreal_pnl_attr_m2m_sp_rows.profit_center_id,
         unreal_pnl_attr_m2m_sp_rows.profit_center_name,
         unreal_pnl_attr_m2m_sp_rows.profit_center_short_name,
         unreal_pnl_attr_m2m_sp_rows.base_qty_unit_id,
         unreal_pnl_attr_m2m_sp_rows.base_qty_unit,
         unreal_pnl_attr_m2m_sp_rows.base_cur_id,
         unreal_pnl_attr_m2m_sp_rows.base_cur_code,
         unreal_pnl_attr_m2m_sp_rows.trade_date,
         unreal_pnl_attr_m2m_sp_rows.prev_process_id,
         unreal_pnl_attr_m2m_sp_rows.prev_trade_date);
    end loop;
    commit;
    insert into upad_unreal_pnl_attr_detail
      (process_id,
       corporate_id,
       corporate_name,
       attribution_type,
       attribution_main_type,
       attribution_sub_type,
       attribution_order,
       internal_contract_ref_no,
       internal_contract_item_ref_no,
       contract_ref_no,
       delivery_item_no,
       del_distribution_item_no,
       contract_type,
       item_qty,
       qty_unit_id,
       curr_eod_qty,
       curr_eod_qty_unit_id,
       prev_eod_qty,
       prev_eod_qty_unit_id,
       curr_eod_contract_price,
       curr_eod_price_unit_id,
       prev_eod_contract_price,
       prev_eod_price_unit_id,
       md_id,
       m2m_price_unit_id,
       m2m_settlement_price,
       m2m_loc_inco_deviation,
       net_m2m_price,
       prev_md_id,
       prev_m2m_price_unit_id,
       prev_m2m_settlement_price,
       prev_m2m_loc_inco_deviation,
       prev_net_m2m_price,
       pnlc_due_to_attr,
       product_id,
       product_name,
       profit_center_id,
       profit_center_name,
       profit_center_short_name,
       base_qty_unit_id,
       base_qty_unit,
       base_cur_id,
       base_cur_code,
       trade_date,
       prev_process_id,
       prev_trade_date)
      select pc_process_id,
             poud.corporate_id,
             poud.corporate_name,
             'Physical Contract' attribution_type,
             'Others' attribution_main_type,
             (case
               when poud.contract_type = 'P' then
                'Purchase'
               when poud.contract_type = 'S' then
                'Sales'
               else
                'NA'
             end) attribution_sub_type,
             (case
               when poud.contract_type = 'P' then
                10.1
               when poud.contract_type = 'S' then
                10.2
               else
                10.3
             end) attribution_order,
             poud.internal_contract_ref_no,
             poud.internal_contract_item_ref_no,
             poud.contract_ref_no,
             poud.delivery_item_no,
             t.del_distribution_item_no,
             poud.contract_type,
             nvl(poud.trade_day_pnl_in_val_cur, 0) -
             nvl(t.pnlc_due_to_attr, 0) pnlc_due_to_attr,
             poud.item_qty,
             poud.qty_unit_id,
             poud.qty_in_base_unit curr_eod_qty,
             poud.qty_unit_id curr_eod_qty_unit_id,
             poud_prev.item_qty prev_eod_qty,
             poud_prev.qty_unit_id prev_eod_qty_unit_id,
             poud.contract_price curr_eod_contract_price,
             poud.price_unit_id curr_eod_price_unit_id,
             poud_prev.contract_price prev_eod_contract_price,
             poud_prev.price_unit_id prev_eod_price_unit_id,
             poud.md_id,
             poud.m2m_price_unit_id m2m_price_unit_id,
             poud.net_m2m_price m2m_settlement_price,
             0 m2m_loc_inco_deviation,
             poud.net_m2m_price,
             poud_prev.md_id prev_md_id,
             poud_prev.m2m_price_unit_id prev_m2m_price_unit_id,
             poud_prev.net_m2m_price prev_m2m_settlement_price,
             md.m2m_loc_incoterm_deviation prev_m2m_loc_inco_deviation,
             poud_prev.net_m2m_price prev_net_m2m_price,
             poud.product_id,
             poud.product_name,
             poud.profit_center_id,
             poud.profit_center_name,
             poud.profit_center_short_name,
             poud.base_qty_unit_id,
             poud.base_qty_unit,
             poud.base_cur_id,
             poud.base_cur_code,
             pd_trade_date,
             pc_previous_process_id,
             pd_prev_trade_date
        from poud_phy_open_unreal_daily poud,
             md_m2m_daily md,
             (select *
                from poud_phy_open_unreal_daily poud
               where poud.process_id = pc_previous_process_id) poud_prev,
             (select upad.internal_contract_item_ref_no,
                     upad.delivery_item_no,
                     upad.del_distribution_item_no,
                     upad.process_id,
                     tdc.trade_date,
                     sum(upad.pnlc_due_to_attr) pnlc_due_to_attr
                from upad_unreal_pnl_attr_detail upad,
                     tdc_trade_date_closure      tdc
               where upad.process_id = tdc.process_id
                 and upad.attribution_main_type <> 'New Contract'
               group by upad.internal_contract_item_ref_no,
                        upad.delivery_item_no,
                        upad.del_distribution_item_no,
                        upad.process_id,
                        tdc.trade_date) t
       where poud.internal_contract_item_ref_no =
             t.internal_contract_item_ref_no
         and poud.process_id = t.process_id
         and poud.internal_contract_ref_no =
             poud_prev.internal_contract_item_ref_no
         and poud.pcdi_id = poud_prev.pcdi_id
         and poud_prev.md_id = md.md_id
         and md.process_id = pc_previous_process_id;
  commit;
  exception
    when others then
      null;
      commit;
      /*   vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_phy_unreal_pnl_attr',
                                                           'M2M-013',
                                                           'Code:' || sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           '',
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);*/
  end;
  procedure sp_metal_balance_qty_summary(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2) as
  vd_prev_eom_date   date;
  vc_prev_process_id number;
  vd_acc_start_date date;

begin
--
-- Financial year for calcualting Existing Stock Start Date
-- If data is missing we will assume finacial year start from Jan of the EOM Year
--
begin
  select start_date
    into vd_acc_start_date
    from cfy_corporate_financial_year@eka_appdb
   where pd_trade_date between start_date and end_date
     and corporateid = pc_corporate_id;
exception
  when others then
    vd_acc_start_date := trunc(pd_trade_date, 'yyyy');
end;
 --
 -- Get the Previous EOM Date for Calcualting New Stock
 --
  begin
    select tdc.trade_date,
           tdc.process_id
      into vd_prev_eom_date,
           vc_prev_process_id
      from tdc_trade_date_closure tdc
     where tdc.trade_date = (select max(t.trade_date)
                               from tdc_trade_date_closure t
                              where t.trade_date < pd_trade_date
                                and t.corporate_id = pc_corporate_id
                                and t.process = 'EOM')
       and tdc.corporate_id = pc_corporate_id
       and tdc.process = 'EOM';
    
  exception
    when no_data_found then
      vc_prev_process_id := null;
      vd_prev_eom_date   := to_date('01-Jan-2000','dd-Mon-yyyy');
  end;
delete from temp_mas t where t.corporate_id = pc_corporate_id;
commit;
--
-- Raw Material New Stock
--
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Raw Material New Stock',
         aml.underlying_product_id,
         pdm.product_desc,
         'Inventory' position_type,
         'Raw Material Stock' stock_type,
         'New Stocks' section_name,
         '2' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         case
           when rm.ratio_name = '%' then
            ((((grd.qty - grd.moved_out_qty) * asm.dry_wet_qty_ratio / 100)) *
            pqcapd.payable_percentage / 100)
           else
            ((((grd.qty - grd.moved_out_qty) * asm.dry_wet_qty_ratio / 100)) *
            pqcapd.payable_percentage)
         end stock_qty,
         (case
           when rm.ratio_name = '%' then
            grd.qty_unit_id
           else
            rm.qty_unit_id_numerator
         end) stock_qty_unit_id,
         pdm.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('landingDetail', 'warehouseReceipt')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         spq_stock_payable_qty spq,
         ash_assay_header ash,
         asm_assay_sublot_mapping asm,
         aml_attribute_master_list aml,
         pdm_productmaster pdm,
         qum_quantity_unit_master qum,
         ak_corporate akc,
         pqca_pq_chemical_attributes pqca,
         pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
         rm_ratio_master rm
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.tolling_stock_type = 'None Tolling'
     and grd.warehouse_profile_id = phd.profileid
     and grd.internal_grd_ref_no = spq.internal_grd_ref_no
     and spq.is_stock_split = 'N'
     and spq.element_id = aml.attribute_id
     and aml.underlying_product_id = pdm.product_id
     and pdm.base_quantity_unit = qum.qty_unit_id
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and spq.process_id = pc_process_id
     and spq.weg_avg_pricing_assay_id = ash.ash_id
     and ash.ash_id = asm.ash_id
     and pqca.element_id = aml.attribute_id
     and pqca.asm_id = asm.asm_id
     and pqcapd.pqca_id = pqca.pqca_id
     and pqcapd.pcdi_id = grd.pcdi_id
     and pqca.is_active = 'Y'
     and pqcapd.is_active = 'Y'
     and pqca.unit_of_measure = rm.ratio_id
     and rm.is_active = 'Y'
     and rm.is_deleted = 'N'
     and agmr.eff_date > vd_prev_eom_date
     and agmr.eff_date <= pd_trade_date;
     commit;
     gvn_log_counter := gvn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Raw Material New Stock End');   
--
-- Raw Material Exisitng Stock
--                          
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Raw Material Existing Stock',
         aml.underlying_product_id,
         pdm.product_desc,
         'Inventory' position_type,
         'Raw Material Stock' stock_type,
         'Existing Stock' section_name,
         '1' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         case
           when rm.ratio_name = '%' then
            ((((grd.qty - grd.moved_out_qty) * asm.dry_wet_qty_ratio / 100)) *
            pqcapd.payable_percentage / 100)
           else
            ((((grd.qty - grd.moved_out_qty) * asm.dry_wet_qty_ratio / 100)) *
            pqcapd.payable_percentage)
         end stock_qty,
         (case
           when rm.ratio_name = '%' then
            grd.qty_unit_id
           else
            rm.qty_unit_id_numerator
         end) stock_qty_unit_id,
         pdm.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('landingDetail', 'warehouseReceipt')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         spq_stock_payable_qty spq,
         ash_assay_header ash,
         asm_assay_sublot_mapping asm,
         aml_attribute_master_list aml,
         pdm_productmaster pdm,
         qum_quantity_unit_master qum,
         ak_corporate akc,
         pqca_pq_chemical_attributes pqca,
         pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
         rm_ratio_master rm
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.tolling_stock_type = 'None Tolling'
     and grd.warehouse_profile_id = phd.profileid
     and grd.internal_grd_ref_no = spq.internal_grd_ref_no
     and spq.is_stock_split = 'N'
     and spq.element_id = aml.attribute_id
     and aml.underlying_product_id = pdm.product_id
     and pdm.base_quantity_unit = qum.qty_unit_id
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and spq.process_id = pc_process_id
     and spq.internal_grd_ref_no = ash.internal_grd_ref_no
     and spq.weg_avg_pricing_assay_id = ash.ash_id
     and ash.ash_id = asm.ash_id
     and ash.is_active = 'Y'
     and asm.is_active = 'Y'
     and pqca.element_id = aml.attribute_id
     and pqca.asm_id = asm.asm_id
     and pqcapd.pqca_id = pqca.pqca_id
     and pqcapd.pcdi_id = grd.pcdi_id
     and pqca.is_active = 'Y'
     and pqcapd.is_active = 'Y'
     and pqca.unit_of_measure = rm.ratio_id
     and rm.is_active = 'Y'
     and rm.is_deleted = 'N'
     and agmr.eff_date >= vd_acc_start_date
     and agmr.eff_date <= vd_prev_eom_date;
commit;     
   gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Raw Material Existing Stock End');        
--
-- Raw Material New Stock Internal Movement
--
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Raw Material Stock IM New Stock',
         aml.underlying_product_id,
         pdm.product_desc,
         'Inventory' position_type,
         'Raw Material Stock' stock_type,
         'New Stocks' section_name,
         '2' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         case
           when rm.ratio_name = '%' then
            ((((grd.qty - grd.moved_out_qty) * asm.dry_wet_qty_ratio / 100)) *
            pqcapd.payable_percentage / 100)
           else
            ((((grd.qty - grd.moved_out_qty) * asm.dry_wet_qty_ratio / 100)) *
            pqcapd.payable_percentage)
         end stock_qty,
         (case
           when rm.ratio_name = '%' then
            grd.qty_unit_id
           else
            rm.qty_unit_id_numerator
         end) stock_qty_unit_id,
         pdm.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from grd_goods_record_detail grd,
         gmr_goods_movement_record gmr,
         sam_stock_assay_mapping sam,
         ash_assay_header ash,
         spq_stock_payable_qty spq,
         ash_assay_header ash_pricing,
         asm_assay_sublot_mapping asm,
         aml_attribute_master_list aml,
         pdm_productmaster pdm,
         pqca_pq_chemical_attributes pqca,
         pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
         ak_corporate akc,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('landingDetail', 'warehouseReceipt')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         qum_quantity_unit_master qum,
         rm_ratio_master rm
   where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     and gmr.is_internal_movement = 'Y'
     and sam.internal_grd_ref_no = grd.internal_grd_ref_no
     and grd.tolling_stock_type = 'None Tolling'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and sam.is_active = 'Y'
     and spq.is_active = 'Y'
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and spq.is_stock_split = 'N'
     and sam.ash_id = ash.ash_id
     and ash.internal_grd_ref_no = spq.internal_grd_ref_no
     and spq.weg_avg_pricing_assay_id = ash_pricing.ash_id    
     and ash_pricing.assay_type = 'Weighted Avg Pricing Assay'
     and asm.ash_id = ash_pricing.ash_id
     and aml.attribute_id = spq.element_id
     and aml.underlying_product_id = pdm.product_id
     and pqca.element_id = aml.attribute_id
     and pqca.asm_id = asm.asm_id
     and pqcapd.pqca_id = pqca.pqca_id
     and pqcapd.pcdi_id = grd.pcdi_id
     and pqca.is_active = 'Y'
     and pqcapd.is_active = 'Y'
     and gmr.corporate_id = akc.corporate_id
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
     and grd.warehouse_profile_id = phd.profileid
     and pdm.base_quantity_unit = qum.qty_unit_id
     and grd.process_id = pc_process_id
     and gmr.process_id = pc_process_id
     and spq.process_id = pc_process_id
     and pqca.unit_of_measure = rm.ratio_id
     and rm.is_active = 'Y'
     and rm.is_deleted = 'N'
     and agmr.eff_date > vd_prev_eom_date
     and agmr.eff_date <= pd_trade_date
     and ash.assay_type in ('Pricing Assay','Shipment Assay')
     and spq.assay_header_id = ash.ash_id;
     commit;
     gvn_log_counter := gvn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Raw Material Stock IM New Stock End');       
--
-- Raw Material Existing Stock Internal Movement 
--
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Raw Material Stock IM',
         aml.underlying_product_id,
         pdm.product_desc,
         'Inventory' position_type,
         'Raw Material Stock' stock_type,
         'Existing Stock' section_name,
         '1' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         case
           when rm.ratio_name = '%' then
            ((((grd.qty - grd.moved_out_qty) * asm.dry_wet_qty_ratio / 100)) *
            pqcapd.payable_percentage / 100)
           else
            ((((grd.qty - grd.moved_out_qty) * asm.dry_wet_qty_ratio / 100)) *
            pqcapd.payable_percentage)
         end stock_qty,
         (case
           when rm.ratio_name = '%' then
            grd.qty_unit_id
           else
            rm.qty_unit_id_numerator
         end) stock_qty_unit_id,
         pdm.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from grd_goods_record_detail grd,
         gmr_goods_movement_record gmr,
         sam_stock_assay_mapping sam,
         ash_assay_header ash,
         spq_stock_payable_qty spq,
         ash_assay_header ash_pricing,
         asm_assay_sublot_mapping asm,
         aml_attribute_master_list aml,
         pdm_productmaster pdm,
         pqca_pq_chemical_attributes pqca,
         pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
         ak_corporate akc,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('landingDetail', 'warehouseReceipt')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         qum_quantity_unit_master qum,
         rm_ratio_master rm
   where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     and gmr.is_internal_movement = 'Y'
     and sam.internal_grd_ref_no = grd.internal_grd_ref_no
     and grd.tolling_stock_type = 'None Tolling'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and sam.is_active = 'Y'
     and spq.is_active = 'Y'
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and spq.is_stock_split = 'N'
     and sam.ash_id = ash.ash_id
     and ash.internal_grd_ref_no = spq.internal_grd_ref_no
     and spq.weg_avg_pricing_assay_id = ash_pricing.ash_id    
     and ash_pricing.assay_type = 'Weighted Avg Pricing Assay'
     and asm.ash_id = ash_pricing.ash_id
     and aml.attribute_id = spq.element_id
     and aml.underlying_product_id = pdm.product_id
     and pqca.element_id = aml.attribute_id
     and pqca.asm_id = asm.asm_id
     and pqcapd.pqca_id = pqca.pqca_id
     and pqcapd.pcdi_id = grd.pcdi_id
     and pqca.is_active = 'Y'
     and pqcapd.is_active = 'Y'
     and gmr.corporate_id = akc.corporate_id
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
     and grd.warehouse_profile_id = phd.profileid
     and pdm.base_quantity_unit = qum.qty_unit_id
     and grd.process_id = pc_process_id
     and gmr.process_id = pc_process_id
     and spq.process_id = pc_process_id
     and pqca.unit_of_measure = rm.ratio_id
     and rm.is_active = 'Y'
     and rm.is_deleted = 'N'
     and agmr.eff_date >= vd_acc_start_date
     and agmr.eff_date <= vd_prev_eom_date
     and ash.assay_type in ('Pricing Assay','Shipment Assay')
     and spq.assay_header_id = ash.ash_id;
     commit;
     gvn_log_counter := gvn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                              pd_trade_date,
                              pc_process_id,
                              gvn_log_counter,
                              'Raw Material Existing Stock IM End');                                     
--
-- In Process Stock
--
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'In Process Stock' query_section_name,
         aml.underlying_product_id,
         pdm.product_desc,
         'Inventory' position_type,
         'In Process Stock' stock_type,
         (case
           when agmr.eff_date > vd_prev_eom_date and
                agmr.eff_date <= pd_trade_date then
            
          (case when grd.tolling_stock_type in
          ('Free Metal IP Stock', 'Delta FM IP Stock') then
            'New Stock - Free Metal Stocks'
            else
            'New Stock - In Process Stocks'
            end) 
           else
            'Existing Stock'
         end) section_name,
         (case
           when agmr.eff_date > vd_prev_eom_date and
                agmr.eff_date <= pd_trade_date then
            '3'
           else
            '2'
         end) section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         grd.qty stock_qty,
         grd.qty_unit_id,
         pdm.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         aml_attribute_master_list aml,
         pdm_productmaster pdm,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in ('MARK_FOR_TOLLING')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         qum_quantity_unit_master qum,
         phd_profileheaderdetails phd,
         ak_corporate akc
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.product_id = aml.underlying_product_id
     and aml.underlying_product_id = pdm.product_id
     and pdm.base_quantity_unit = qum.qty_unit_id
     and grd.warehouse_profile_id = phd.profileid
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and agmr.eff_date >= vd_acc_start_date
     and agmr.eff_date <= pd_trade_date
     and grd.tolling_stock_type in
         ('MFT In Process Stock', 'Free Metal IP Stock', 'Delta FM IP Stock',
          'Delta MFT IP Stock');
     commit;
     gvn_log_counter := gvn_log_counter + 1;     
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'In process Stock End');          
--
-- Finished New Stock For Concentrate Products
--    
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Finished Stock',
         pdm_aml.product_id,
         pdm_aml.product_desc,
         'Inventory' position_type,
         'Raw Material Stock' stock_type,
         'New Stocks' section_name,
         '2' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         case
           when rm.ratio_name = '%' then
            ((((grd.qty) * nvl(asm.dry_wet_qty_ratio, 100) / 100)) *
            pqca.typical / 100)
           else
            ((((grd.qty) * nvl(asm.dry_wet_qty_ratio, 0) / 100)) *
            pqca.typical)
         end stock_qty,
         (case
           when rm.ratio_name = '%' then
            grd.qty_unit_id
           else
            rm.qty_unit_id_numerator
         end) stock_qty_unit_id,
         pdm_aml.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         sam_stock_assay_mapping sam,
         asm_assay_sublot_mapping asm,
         pqca_pq_chemical_attributes pqca,
         aml_attribute_master_list aml,
         pdm_productmaster pdm_aml,
         rm_ratio_master rm,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('RECORD_OUT_PUT_TOLLING')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         pdm_productmaster pdm,
         qum_quantity_unit_master qum,
         ak_corporate akc,
         pdtm_product_type_master pdtm
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.tolling_stock_type = 'RM Out Process Stock'
     and grd.internal_grd_ref_no = sam.internal_grd_ref_no
     and sam.is_output_assay = 'Y'
     and asm.ash_id = sam.ash_id
     and asm.asm_id = pqca.asm_id
     and pqca.element_id = aml.attribute_id
     and aml.underlying_product_id = pdm_aml.product_id
     and rm.ratio_id = pqca.unit_of_measure
     and grd.warehouse_profile_id = phd.profileid
     and pdm_aml.base_quantity_unit = qum.qty_unit_id
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and pdm.product_type_id = pdtm.product_type_id
     and pdtm.product_type_name = 'Composite'
     and grd.product_id = pdm.product_id
     and agmr.eff_date > vd_prev_eom_date
     and agmr.eff_date <= pd_trade_date;
     commit;
     gvn_log_counter := gvn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Finished New Stock Composite End');    
--
-- Finished Existing Stock For Concentrate Products
--                             
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Finished Stock Conc Existing',
         pdm_aml.product_id,
         pdm_aml.product_desc,
         'Inventory' position_type,
         'Raw Material Stock' stock_type,
         'Existing Stock' section_name,
         '2' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         case
           when rm.ratio_name = '%' then
            ((((grd.qty) * nvl(asm.dry_wet_qty_ratio, 100) / 100)) *
            pqca.typical / 100)
           else
            ((((grd.qty) * nvl(asm.dry_wet_qty_ratio, 0) / 100)) *
            pqca.typical)
         end stock_qty,
         (case
           when rm.ratio_name = '%' then
            grd.qty_unit_id
           else
            rm.qty_unit_id_numerator
         end) stock_qty_unit_id,
         pdm_aml.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         sam_stock_assay_mapping sam,
         asm_assay_sublot_mapping asm,
         pqca_pq_chemical_attributes pqca,
         aml_attribute_master_list aml,
         pdm_productmaster pdm_aml,
         rm_ratio_master rm,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('RECORD_OUT_PUT_TOLLING')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         pdm_productmaster pdm,
         qum_quantity_unit_master qum,
         ak_corporate akc,
         pdtm_product_type_master pdtm
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.tolling_stock_type = 'RM Out Process Stock'
     and grd.internal_grd_ref_no = sam.internal_grd_ref_no
     and sam.is_output_assay = 'Y'
     and asm.ash_id = sam.ash_id
     and asm.asm_id = pqca.asm_id
     and pqca.element_id = aml.attribute_id
     and aml.underlying_product_id = pdm_aml.product_id
     and rm.ratio_id = pqca.unit_of_measure
     and grd.warehouse_profile_id = phd.profileid
     and pdm_aml.base_quantity_unit = qum.qty_unit_id
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and agmr.eff_date <= pd_trade_date
     and pdm.product_type_id = pdtm.product_type_id
     and pdtm.product_type_name = 'Composite'
     and grd.product_id = pdm.product_id
     and agmr.eff_date >= vd_acc_start_date
     and agmr.eff_date <= vd_prev_eom_date;
     commit;
     gvn_log_counter := gvn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Finished Existing Stock Composite End');        
--    
-- Finsihed For Concentrates Internal Movement Startes
--
--
-- Finished New Stock For Concentrate Products IM 
--    
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Finished Stock',
         pdm_aml.product_id,
         pdm_aml.product_desc,
         'Inventory' position_type,
         'Raw Material Stock' stock_type,
         'New Stocks' section_name,
         '2' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         case
           when rm.ratio_name = '%' then
            ((((grd.qty) * nvl(asm.dry_wet_qty_ratio, 100) / 100)) *
            pqca.typical / 100)
           else
            ((((grd.qty) * nvl(asm.dry_wet_qty_ratio, 0) / 100)) *
            pqca.typical)
         end stock_qty,
         (case
           when rm.ratio_name = '%' then
            grd.qty_unit_id
           else
            rm.qty_unit_id_numerator
         end) stock_qty_unit_id,
         pdm_aml.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         sam_stock_assay_mapping sam,
         asm_assay_sublot_mapping asm,
         pqca_pq_chemical_attributes pqca,
         aml_attribute_master_list aml,
         pdm_productmaster pdm_aml,
         rm_ratio_master rm,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('RECORD_OUT_PUT_TOLLING')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         pdm_productmaster pdm,
         qum_quantity_unit_master qum,
         ak_corporate akc,
         pdtm_product_type_master pdtm
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.tolling_stock_type in ('RM Out Process Stock', 'None Tolling')
     and gmr.is_internal_movement = 'Y'
     and grd.internal_grd_ref_no = sam.internal_grd_ref_no
     and sam.is_output_assay = 'Y'
     and asm.ash_id = sam.ash_id
     and asm.asm_id = pqca.asm_id
     and pqca.element_id = aml.attribute_id
     and aml.underlying_product_id = pdm_aml.product_id
     and rm.ratio_id = pqca.unit_of_measure
     and grd.warehouse_profile_id = phd.profileid
     and pdm_aml.base_quantity_unit = qum.qty_unit_id
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and pdm.product_type_id = pdtm.product_type_id
     and pdtm.product_type_name = 'Composite'
     and grd.product_id = pdm.product_id
     and agmr.eff_date > vd_prev_eom_date
     and agmr.eff_date <= pd_trade_date;
     commit;
     gvn_log_counter := gvn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Finished New Stock Composite End');    
--
-- Finished Existing Stock For Concentrate Products IM
--                             
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Finished Stock Conc Existing',
         pdm_aml.product_id,
         pdm_aml.product_desc,
         'Inventory' position_type,
         'Raw Material Stock' stock_type,
         'Existing Stock' section_name,
         '2' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         case
           when rm.ratio_name = '%' then
            ((((grd.qty) * nvl(asm.dry_wet_qty_ratio, 100) / 100)) *
            pqca.typical / 100)
           else
            ((((grd.qty) * nvl(asm.dry_wet_qty_ratio, 0) / 100)) *
            pqca.typical)
         end stock_qty,
         (case
           when rm.ratio_name = '%' then
            grd.qty_unit_id
           else
            rm.qty_unit_id_numerator
         end) stock_qty_unit_id,
         pdm_aml.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         sam_stock_assay_mapping sam,
         asm_assay_sublot_mapping asm,
         pqca_pq_chemical_attributes pqca,
         aml_attribute_master_list aml,
         pdm_productmaster pdm_aml,
         rm_ratio_master rm,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('RECORD_OUT_PUT_TOLLING')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         pdm_productmaster pdm,
         qum_quantity_unit_master qum,
         ak_corporate akc,
         pdtm_product_type_master pdtm
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.tolling_stock_type in ('RM Out Process Stock', 'None Tolling')
     and gmr.is_internal_movement = 'Y'
     and grd.internal_grd_ref_no = sam.internal_grd_ref_no
     and sam.is_output_assay = 'Y'
     and asm.ash_id = sam.ash_id
     and asm.asm_id = pqca.asm_id
     and pqca.element_id = aml.attribute_id
     and aml.underlying_product_id = pdm_aml.product_id
     and rm.ratio_id = pqca.unit_of_measure
     and grd.warehouse_profile_id = phd.profileid
     and pdm_aml.base_quantity_unit = qum.qty_unit_id
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and pdm.product_type_id = pdtm.product_type_id
     and pdtm.product_type_name = 'Composite'
     and grd.product_id = pdm.product_id
     and agmr.eff_date >= vd_acc_start_date
     and agmr.eff_date <= vd_prev_eom_date;
--- Finished for concentrates internal movement end
commit;
gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Finished Existing Stock Composite IM End');       
                          
--
-- Finished New Stock For Base Metal Products
--    
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Finished Stock',
         grd.product_id,
         pdm.product_desc,
         'Inventory' position_type,
         'Finished Stock' stock_type,
         'New Stocks' section_name,
         '2' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         grd.qty stock_qty,
         grd.qty_unit_id stock_qty_unit_id,
         pdm.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('RECORD_OUT_PUT_TOLLING')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         pdm_productmaster pdm,
         qum_quantity_unit_master qum,
         ak_corporate akc,
         pdtm_product_type_master pdtm
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.tolling_stock_type = 'RM Out Process Stock'
     and grd.warehouse_profile_id = phd.profileid
     and pdm.base_quantity_unit = qum.qty_unit_id
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and pdm.product_type_id = pdtm.product_type_id
     and pdtm.product_type_name = 'Standard'
     and grd.product_id = pdm.product_id
     and agmr.eff_date > vd_prev_eom_date
     and agmr.eff_date <= pd_trade_date;
     commit;
     gvn_log_counter := gvn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Finished New Stock Standard End');  
                          
--
-- Finished New Stock For Base Metal Products with tolling stock type = 'RM In Process Stock' (Prachir)
-- This is to create In Process Stock Consumed Section
--    
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Test ',
         grd.product_id,
         pdm.product_desc,
         'Inventory' position_type,
         'In Process Stock' stock_type,
         'Create Consumed From This' section_name,
         '2' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         grd.qty stock_qty,
         grd.qty_unit_id stock_qty_unit_id,
         pdm.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('RECORD_OUT_PUT_TOLLING','IN_PROCESS_ADJUSTMENT')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         pdm_productmaster pdm,
         qum_quantity_unit_master qum,
         ak_corporate akc,
         pdtm_product_type_master pdtm
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.tolling_stock_type in( 'RM In Process Stock','In Process Adjustment Stock')
     and grd.warehouse_profile_id = phd.profileid
     and pdm.base_quantity_unit = qum.qty_unit_id
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and pdm.product_type_id = pdtm.product_type_id
     and pdtm.product_type_name = 'Standard'
     and grd.product_id = pdm.product_id
     and agmr.eff_date > vd_prev_eom_date
     and agmr.eff_date <= pd_trade_date;
     commit;     
     gvn_log_counter := gvn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Create Consumed From This');  

                                                    
--
-- Finished Existing Stock For Base Metal Products
--  

insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Finished Stock',
         grd.product_id,
         pdm.product_desc,
         'Inventory' position_type,
         'Finished Stock' stock_type,
         'Existing Stock' section_name,
         '1' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         grd.qty - grd.moved_out_qty stock_qty,
         grd.qty_unit_id stock_qty_unit_id,
         pdm.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('RECORD_OUT_PUT_TOLLING')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         pdm_productmaster pdm,
         qum_quantity_unit_master qum,
         ak_corporate akc,
         pdtm_product_type_master pdtm
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.tolling_stock_type = 'RM Out Process Stock'
     and grd.warehouse_profile_id = phd.profileid
     and pdm.base_quantity_unit = qum.qty_unit_id
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and agmr.eff_date <= pd_trade_date
     and pdm.product_type_id = pdtm.product_type_id
     and pdtm.product_type_name = 'Standard'
     and grd.product_id = pdm.product_id
     and agmr.eff_date >= vd_acc_start_date
     and agmr.eff_date <= vd_prev_eom_date;
     commit;     
     gvn_log_counter := gvn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                              pd_trade_date,
                              pc_process_id,
                              gvn_log_counter,
                              'Finished Existing Stock Standard End');       
--     
-- Finished Stock Existing has to reduce the In Process Open Balance
-- Due to this we are making In Process Stock Existing Stock with negative qty
--
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
  select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'In Process Stock',
         grd.product_id,
         pdm.product_desc,
         'Inventory' position_type,
         'In Process Stock' stock_type,
         'Existing Stock' section_name,
         '1' section_order,
         grd.warehouse_profile_id,
         phd.companyname,
         (grd.qty) * -1 stock_qty,
         grd.qty_unit_id stock_qty_unit_id,
         pdm.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in
                 ('RECORD_OUT_PUT_TOLLING')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         phd_profileheaderdetails phd,
         pdm_productmaster pdm,
         qum_quantity_unit_master qum,
         ak_corporate akc,
         pdtm_product_type_master pdtm
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.tolling_stock_type = 'RM In Process Stock'
     and grd.warehouse_profile_id = phd.profileid
     and pdm.base_quantity_unit = qum.qty_unit_id
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and pdm.product_type_id = pdtm.product_type_id
     and pdtm.product_type_name = 'Standard'
     and grd.product_id = pdm.product_id
     and agmr.eff_date >= vd_acc_start_date
     and agmr.eff_date <= vd_prev_eom_date;
     commit;
     gvn_log_counter := gvn_log_counter + 1;
     sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'In Process Stock Existing Section Manipulation');           
          
--
-- Raw Material Existing Stock section has to be get reduced by In Process Stock 
-- Hence marking them with negative only for Tolling Type = 'MFT In Process Stock' and 'Delta MFT IP Stock'
-- Between Accounting Start Date and Last EOM Date
-- 
insert into temp_mas
  (process_id,
   corporate_id,
   corporate_name,
   query_section_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   stock_qty_unit_id,
   product_base_qty_unit_id,
   qty_unit)
    select pc_process_id,
         gmr.corporate_id,
         akc.corporate_name,
         'Raw Material Stock Negative' query_section_name,
         aml.underlying_product_id,
         pdm.product_desc,
         'Inventory' position_type,
         'Raw Material Stock' stock_type,
         'Existing Stock' section_name,
         1 section_order,
         grd.warehouse_profile_id,
         phd.companyname,
        -1 * grd.qty stock_qty,
         grd.qty_unit_id,
         pdm.base_quantity_unit qty_unit_id,
         qum.qty_unit
    from gmr_goods_movement_record gmr,
         grd_goods_record_detail grd,
         aml_attribute_master_list aml,
         pdm_productmaster pdm,
         (select gmr.internal_gmr_ref_no,
                 agmr.eff_date
            from gmr_goods_movement_record gmr,
                 agmr_action_gmr           agmr
           where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agmr.gmr_latest_action_action_id in ('MARK_FOR_TOLLING')
             and agmr.is_deleted = 'N'
             and gmr.process_id = pc_process_id) agmr,
         qum_quantity_unit_master qum,
         phd_profileheaderdetails phd,
         ak_corporate akc
   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.is_afloat = 'N'
     and grd.is_trans_ship = 'N'
     and grd.product_id = aml.underlying_product_id
     and aml.underlying_product_id = pdm.product_id
     and pdm.base_quantity_unit = qum.qty_unit_id
     and grd.warehouse_profile_id = phd.profileid
     and gmr.corporate_id = akc.corporate_id
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and agmr.eff_date >= vd_acc_start_date 
     and agmr.eff_date <= vd_prev_eom_date
     and grd.tolling_stock_type in ('MFT In Process Stock', 'Delta MFT IP Stock');
commit;
     
--
-- Now we have to convert payable qty to Product Base Quantity Unit
--
for cur_stock_qty in
(
select product_id,
       stock_qty_unit_id,
       product_base_qty_unit_id
  from temp_mas t
 where t.corporate_id = pc_corporate_id
   and t.stock_qty_unit_id <> t.product_base_qty_unit_id
 group by product_id,
          stock_qty_unit_id,
          product_base_qty_unit_id
) loop
update temp_mas t
   set t.stock_qty = pkg_general.f_get_converted_quantity(cur_stock_qty.product_id,
                                                          cur_stock_qty.stock_qty_unit_id,
                                                          cur_stock_qty.product_base_qty_unit_id,
                                                          1) * t.stock_qty
 where t.stock_qty_unit_id = cur_stock_qty.stock_qty_unit_id
   and t.product_base_qty_unit_id = cur_stock_qty.product_base_qty_unit_id
   and t.product_id = cur_stock_qty.product_id
   and t.corporate_id = pc_corporate_id;
end loop;
commit;
gvn_log_counter := gvn_log_counter + 1;
   sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Qty conversion End');  
                          
insert into mas_metal_account_summary
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   product_id,
   product_desc,
   position_type,
   stock_type,
   section_name,
   section_order,
   warehouse_profile_id,
   warehousename,
   stock_qty,
   qty_unit_id,
   qty_unit)
  select pc_process_id,
         pd_trade_date,
         corporate_id,
         corporate_name,
         product_id,
         product_desc,
         position_type,
         stock_type,
         section_name,
         section_order,
         warehouse_profile_id,
         warehousename,
         stock_qty,
         product_base_qty_unit_id,
         qty_unit
    from temp_mas
   where corporate_id = pc_corporate_id
   and section_name <> 'Create Consumed From This';
   commit; 
   gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Mas Insertion Over');  
 --
 -- Consumed for Raw Material Stock  Take From In Process New Stock
 --

  insert into mas_metal_account_summary
    (process_id,
     eod_trade_date,
     product_id,
     product_desc,
     corporate_id,
     corporate_name,
     position_type,
     stock_type,
     section_name,
     section_order,
     warehouse_profile_id,
     warehousename,
     stock_qty,
     qty_unit_id,
     qty_unit)
    select pc_process_id,
           pd_trade_date,
           mas.product_id,
           mas.product_desc,
           mas.corporate_id,
           mas.corporate_name,
           'Inventory' position_type,
           'Raw Material Stock' stock_type,
           'Consumed' section_name,
           '3' section_order,
           mas.warehouse_profile_id,
           mas.warehousename,
           mas.stock_qty,
           mas.qty_unit_id,
           mas.qty_unit
      from mas_metal_account_summary mas
     where mas.stock_type = 'In Process Stock'
       and mas.section_name IN ('New Stocks','New Stock - In Process Stocks') -- Should not contain Free Metal
       and mas.process_id = pc_process_id;
       commit;
       gvn_log_counter := gvn_log_counter + 1;
       sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Consumed For Raw Material End');   
--                           
-- Iron Stock for In Process Stock 
--
 insert into mas_metal_account_summary
   (process_id,
    eod_trade_date,
    product_id,
    product_desc,
    corporate_id,
    corporate_name,
    position_type,
    stock_type,
    section_name,
    section_order,
    warehouse_profile_id,
    warehousename,
    stock_qty,
    qty_unit_id,
    qty_unit)
   select pc_process_id,
          pd_trade_date,
          sbs.product_id,
          pdm.product_desc,
          sbs.corporate_id,
          akc.corporate_name,
          'Inventory' position_type,
          'In Process Stock' stock_type,
          'Iron Stock',
          '1' section_order,
          sbs.warehouse_profile_id,
          phd.companyname,
          pkg_general.f_get_converted_quantity(sbs.product_id,
                                               sbs.qty_unit_id,
                                               pdm.base_quantity_unit,
                                               sbs.qty),
          pdm.base_quantity_unit qty_unit_id,
          qum.qty_unit
     from sbs_smelter_base_stock   sbs,
          pdm_productmaster        pdm,
          ak_corporate             akc,
          phd_profileheaderdetails phd,
          qum_quantity_unit_master qum
    where sbs.product_id = pdm.product_id
      and sbs.corporate_id = akc.corporate_id
      and sbs.warehouse_profile_id = phd.profileid
      and pdm.base_quantity_unit = qum.qty_unit_id
      and akc.corporate_id = pc_corporate_id;
      commit;
      gvn_log_counter := gvn_log_counter + 1;
      sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Iron Stock For Process Stock End');  
--
-- Populate In Process Stock Consumed From Finished New Stock                          
--
  insert into mas_metal_account_summary
    (process_id,
     eod_trade_date,
     product_id,
     product_desc,
     corporate_id,
     corporate_name,
     position_type,
     stock_type,
     section_name,
     section_order,
     warehouse_profile_id,
     warehousename,
     stock_qty,
     qty_unit_id,
     qty_unit)
    select pc_process_id,
           pd_trade_date,
           mas.product_id,
           mas.product_desc,
           mas.corporate_id,
           mas.corporate_name,
           'Inventory' position_type,
           'In Process Stock',
           'Consumed' stock_type,
           decode(mas.stock_type, 'In Process Stock', '4', '2') section_order,
           mas.warehouse_profile_id,
           mas.warehousename,
           mas.stock_qty,
           mas.product_base_qty_unit_id qty_unit_id,
           mas.qty_unit qty_unit
      from temp_mas mas
     where mas.stock_type = 'In Process Stock'
       and mas.section_name = 'Create Consumed From This'
       and mas.process_id = pc_process_id;
       commit;
       gvn_log_counter := gvn_log_counter + 1;
       sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Consumed In Process Sotck End');  

  -- Afloat
  insert into mas_metal_account_summary
    (process_id,
     eod_trade_date,
     product_id,
     product_desc,
     corporate_id,
     corporate_name,
     position_type,
     stock_type,
     section_name,
     section_order,
     warehouse_profile_id,
     warehousename,
     stock_qty,
     qty_unit_id,
     qty_unit)
    select pc_process_id,
           pd_trade_date,
           aml.underlying_product_id,
           pdm.product_desc,
           gmr.corporate_id,
           akc.corporate_name,
           'Afloat' position_type,
           'Raw Material Stock' stock_type,
           (case
             when agmr.eff_date > vd_prev_eom_date and
                  agmr.eff_date <= pd_trade_date then
              'New Stocks'
             else
              'Existing Stock'
           end) section_name,
           (case
             when agmr.eff_date > vd_prev_eom_date and
                  agmr.eff_date <= pd_trade_date then
              '2'
             else
              '1'
           end) section_order,
           null warehouse_profile_id,
           null companyname,
           sum(case
                 when agmr.eff_date > vd_prev_eom_date and
                      agmr.eff_date <= pd_trade_date then
                  (pkg_general.f_get_converted_quantity(aml.underlying_product_id,
                                                        spq.qty_unit_id,
                                                        pdm.base_quantity_unit,
                                                        spq.payable_qty))
                 else
                  (pkg_general.f_get_converted_quantity(aml.underlying_product_id,
                                                        spq.qty_unit_id,
                                                        pdm.base_quantity_unit,
                                                        spq.payable_qty))
               end) stock_qty,
           pdm.base_quantity_unit qty_unit_id,
           qum.qty_unit
      from gmr_goods_movement_record gmr,
           grd_goods_record_detail grd,
           (select gmr.internal_gmr_ref_no,
                   agmr.eff_date
              from gmr_goods_movement_record gmr,
                   agmr_action_gmr           agmr
             where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
               and agmr.gmr_latest_action_action_id in ('shipmentDetail')
               and agmr.is_deleted = 'N'
               and gmr.process_id = pc_process_id) agmr,
           spq_stock_payable_qty spq,
           aml_attribute_master_list aml,
           pdm_productmaster pdm,
           qum_quantity_unit_master qum,
           ak_corporate akc
     where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
       and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
       and gmr.is_deleted = 'N'
       and grd.status = 'Active'
       and grd.is_afloat = 'Y'
       and grd.tolling_stock_type = 'None Tolling'
       and grd.internal_grd_ref_no = spq.internal_grd_ref_no
       and spq.is_stock_split = 'N'
       and spq.element_id = aml.attribute_id
       and aml.underlying_product_id = pdm.product_id
       and pdm.base_quantity_unit = qum.qty_unit_id
       and gmr.corporate_id = akc.corporate_id
       and gmr.process_id = pc_process_id
       and grd.process_id = pc_process_id
       and spq.process_id = pc_process_id
       and agmr.eff_date <= pd_trade_date
       and agmr.eff_date >= vd_acc_start_date
     group by aml.underlying_product_id,
              pdm.product_desc,
              pdm.base_quantity_unit,
              qum.qty_unit,
              gmr.corporate_id,
              akc.corporate_name,
              (case
                when agmr.eff_date > vd_prev_eom_date and
                     agmr.eff_date <= pd_trade_date then
                 'New Stocks'
                else
                 'Existing Stock'
              end),
              (case
                when agmr.eff_date > vd_prev_eom_date and
                     agmr.eff_date <= pd_trade_date then
                 '2'
                else
                 '1'
              end);
              commit;
              gvn_log_counter := gvn_log_counter + 1;
              sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Afloat End');  
  
  insert into md_metal_debt
    (process_id,
     corporate_id,
     product_id,
     product_name,
     stock_qty,
     debt_qty,
     net_qty,
     qty_unit_id,
     qty_unit)
    select pc_process_id,
           corporate_id,
           product_id,
           product_name,
           sum(stock_qty) stock_qty,
           sum(debt_qty),
           sum(stock_qty) + sum(debt_qty) net_qty,
           qty_unit_id,
           qty_unit
      from (select debt_temp.corporate_id,
                   debt_temp.product_id product_id,
                   debt_temp.product_name product_name,
                   0 stock_qty,
                   sum(debt_temp.total_qty) debt_qty,
                   debt_temp.qty_unit_id qty_unit_id,
                   qum.qty_unit qty_unit
              from (select returnable_temp.corporate_id,
                           returnable_temp.supplier_id supplier_id,
                           returnable_temp.product_id,
                           returnable_temp.product_name,
                           -1 * sum(returnable_temp.total_qty) total_qty,
                           returnable_temp.qty_unit_id,
                           returnable_temp.qty_type
                      from (select axs.corporate_id,
                                   prrqs.cp_id supplier_id,
                                   prrqs.product_id product_id,
                                   pdm.product_desc product_name,
                                   sum(prrqs.qty_sign *
                                       pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                            prrqs.qty_unit_id,
                                                                            cpm.inventory_qty_unit,
                                                                            prrqs.qty)) total_qty,
                                   cpm.inventory_qty_unit qty_unit_id,
                                   prrqs.qty_type qty_type
                              from prrqs_prr_qty_status       prrqs,
                                   axs_action_summary         axs,
                                   aml_attribute_master_list  aml,
                                   pdm_productmaster          pdm,
                                   cpm_corporateproductmaster cpm
                             where prrqs.internal_action_ref_no =
                                   axs.internal_action_ref_no
                               and prrqs.cp_type = 'Supplier'
                               and prrqs.is_active = 'Y'
                               and prrqs.qty_type = 'Returnable'
                               and aml.attribute_id(+) = prrqs.element_id
                               and pdm.product_id = prrqs.product_id
                               and cpm.is_active = 'Y'
                               and cpm.is_deleted = 'N'
                               and cpm.product_id = pdm.product_id
                               and cpm.corporate_id = axs.corporate_id
                               and prrqs.corporate_id = pc_corporate_id
                               and axs.corporate_id = pc_corporate_id
                               and axs.eff_date <= pd_trade_date
                             group by axs.corporate_id,
                                      prrqs.cp_id,
                                      prrqs.product_id,
                                      pdm.product_desc,
                                      cpm.inventory_qty_unit,
                                      prrqs.qty_type
                            union
                            select axs.corporate_id,
                                   spq.supplier_id,
                                   product_temp.underlying_product_id product_id,
                                   product_temp.product_desc product_name,
                                   sum(pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                            spq.qty_unit_id,
                                                                            cpm.inventory_qty_unit,
                                                                            spq.payable_qty)) total_qty,
                                   cpm.inventory_qty_unit qty_unit_id,
                                   spq.qty_type qty_type
                              from spq_stock_payable_qty spq,
                                   axs_action_summary axs,
                                   (select aml.attribute_id,
                                           aml.attribute_name,
                                           qav.quality_id quality_id,
                                           qat.long_desc,
                                           qav.comp_quality_id comp_quality_id,
                                           aml.underlying_product_id underlying_product_id,
                                           pdm.product_desc,
                                           ppm.product_id
                                      from aml_attribute_master_list      aml,
                                           ppm_product_properties_mapping ppm,
                                           qav_quality_attribute_values   qav,
                                           qat_quality_attributes         qat,
                                           pdm_productmaster              pdm
                                     where aml.attribute_id = ppm.attribute_id
                                       and aml.is_active = 'Y'
                                       and aml.is_deleted = 'N'
                                       and ppm.is_active = 'Y'
                                       and ppm.is_deleted = 'N'
                                       and qav.attribute_id = ppm.property_id
                                       and qav.is_deleted = 'N'
                                       and qat.quality_id = qav.quality_id
                                       and qat.product_id = ppm.product_id
                                       and qat.is_active = 'Y'
                                       and qat.is_deleted = 'N'
                                       and aml.underlying_product_id is not null
                                       and qav.comp_quality_id is not null
                                       and pdm.product_id =
                                           aml.underlying_product_id) product_temp,
                                   cpm_corporateproductmaster cpm,
                                   grd_goods_record_detail grd
                             where spq.internal_action_ref_no =
                                   axs.internal_action_ref_no
                               and spq.smelter_id is null
                               and spq.is_active = 'Y'
                               and spq.is_stock_split = 'N'
                               and spq.qty_type = 'Returnable'
                               and grd.internal_grd_ref_no =
                                   spq.internal_grd_ref_no
                               and product_temp.attribute_id = spq.element_id
                               and product_temp.product_id = grd.product_id
                               and product_temp.quality_id = grd.quality_id
                               and cpm.is_active = 'Y'
                               and cpm.is_deleted = 'N'
                               and cpm.product_id =
                                   product_temp.underlying_product_id
                               and cpm.corporate_id = axs.corporate_id
                               and spq.process_id = pc_process_id
                               and grd.process_id = pc_process_id
                               and axs.corporate_id = pc_corporate_id
                             group by axs.corporate_id,
                                      spq.supplier_id,
                                      product_temp.underlying_product_id,
                                      product_temp.product_desc,
                                      cpm.inventory_qty_unit,
                                      spq.qty_type) returnable_temp
                     group by returnable_temp.corporate_id,
                              returnable_temp.supplier_id,
                              returnable_temp.product_id,
                              returnable_temp.product_name,
                              returnable_temp.qty_unit_id,
                              returnable_temp.qty_type
                    union
                    select axs.corporate_id,
                           prrqs.cp_id supplier_id,
                           prrqs.product_id product_id,
                           pdm.product_desc product_name,
                           sum(prrqs.qty_sign *
                               pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                    prrqs.qty_unit_id,
                                                                    cpm.inventory_qty_unit,
                                                                    prrqs.qty)) total_qty,
                           cpm.inventory_qty_unit qty_unit_id,
                           prrqs.qty_type qty_type
                      from prrqs_prr_qty_status       prrqs,
                           axs_action_summary         axs,
                           aml_attribute_master_list  aml,
                           pdm_productmaster          pdm,
                           cpm_corporateproductmaster cpm
                     where prrqs.internal_action_ref_no =
                           axs.internal_action_ref_no
                       and prrqs.cp_type = 'Supplier'
                       and prrqs.is_active = 'Y'
                       and prrqs.qty_type = 'Returned'
                       and aml.attribute_id(+) = prrqs.element_id
                       and pdm.product_id = prrqs.product_id
                       and cpm.is_active = 'Y'
                       and cpm.is_deleted = 'N'
                       and cpm.product_id = pdm.product_id
                       and cpm.corporate_id = axs.corporate_id
                       and prrqs.corporate_id = pc_corporate_id
                       and axs.eff_date <= pd_trade_date
                     group by axs.corporate_id,
                              prrqs.cp_id,
                              prrqs.product_id,
                              pdm.product_desc,
                              cpm.inventory_qty_unit,
                              prrqs.qty_type) debt_temp,
                   phd_profileheaderdetails phd,
                   qum_quantity_unit_master qum
             where debt_temp.supplier_id = phd.profileid
               and debt_temp.qty_unit_id = qum.qty_unit_id
             group by debt_temp.corporate_id,
                      debt_temp.product_id,
                      debt_temp.product_name,
                      debt_temp.qty_unit_id,
                      qum.qty_unit
            union all
            select mas.corporate_id,
                   mas.product_id product_id,
                   mas.product_desc product_name,
                   sum(case
                          when mas.stock_type = 'Finished Stock' then
                           (case
                          when mas.section_name = 'Existing Stock' then
                           mas.stock_qty
                          when mas.section_name = 'New Stocks' then
                           mas.stock_qty
                        end) when mas.stock_type = 'In Process Stock' then(case
                     when mas.section_name =
                          'Existing Stock' then
                      mas.stock_qty
                     when mas.section_name in
                          ('New Stocks','New Stock - In Process Stocks','New Stock - Free Metal Stocks') then
                      mas.stock_qty
                     when mas.section_name =
                          'Consumed' then
                      mas.stock_qty * (-1)
                     when mas.section_name =
                          'Iron Stock' then
                      0
                   end) when mas.stock_type = 'Raw Material Stock' then(case
                     when mas.section_name =
                          'Existing Stock' then
                      mas.stock_qty
                     when mas.section_name =
                          'New Stocks' then
                      mas.stock_qty
                     when mas.section_name =
                          'Consumed' then
                      mas.stock_qty * (-1)
                   end) end) stock_qty,
                   0 debt_qty,
                   mas.qty_unit_id qty_unit_id,
                   mas.qty_unit
              from mas_metal_account_summary mas
             where mas.process_id = pc_process_id
               and mas.position_type = 'Inventory'
             group by mas.corporate_id,
                      mas.product_id,
                      mas.product_desc,
                      mas.qty_unit_id,
                      mas.qty_unit)
     group by corporate_id,
              product_id,
              product_name,
              qty_unit_id,
              qty_unit;

    commit;
    gvn_log_counter := gvn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'End of Metal Balance');  
end;  
  
  PROCEDURE sp_misc_updates
    (
        pc_corporate_id VARCHAR2,
        pd_trade_date   DATE,
        pc_process_id   varchar2,
        pc_process      varchar2,
        pc_user_id      VARCHAR2
    ) IS
        --------------------------------------------------------------------------------------------------------------------------
        --        Procedure Name                            : sp_misc
        --        Author                                    : Janna
        --        Created Date                              : 19th Sep 2010
        --        Purpose                                   : Populate Price Conversion data to be used with EOD
        --
        --        Parameters
        --        pc_corporate_id                           : Corporate ID
        --        pd_trade_date                             : Trade Date
        --        pc_user_id                                : User ID
        --        pc_process                                : Process EOD or EOM
        --
        --        Modification History
        --        Modified Date                             :
        --        Modified By                               :
        --        Modify Description                        :
        --------------------------------------------------------------------------------------------------------------------------
        vobj_error_log            tableofpelerrorlog := tableofpelerrorlog();
        vn_eel_error_count        number := 1;
        vn_log_counter            number :=0;
        vc_previous_year_eom_id   varchar2(15);
        vc_previous_eom_id        varchar2(15);
    CURSOR cur_price_units_out IS
            SELECT cm.cur_id
            FROM   cm_currency_master cm;
        CURSOR cur_price_units_in IS
            SELECT cm.cur_id
            FROM   cm_currency_master cm;
        vn_conv_factor NUMBER;
    BEGIN
    vn_log_counter := gvn_log_counter;
        DELETE FROM cet_corporate_exch_rate
        WHERE  corporate_id = pc_corporate_id;
        commit;
        FOR cur_price_units_outer IN cur_price_units_out LOOP
            FOR cur_price_units_inner IN cur_price_units_in LOOP
                vn_conv_factor := pkg_phy_pre_check_process.f_get_converted_currency_amt(pc_corporate_id,
                                                                    cur_price_units_outer.cur_id,
                                                                    cur_price_units_inner.cur_id,
                                                                    pd_trade_date,
                                                                    1);
                INSERT INTO cet_corporate_exch_rate
                    (corporate_id,
                     from_cur_id,
                     to_cur_id,
                     exch_rate)
                VALUES
                    (pc_corporate_id,
                     cur_price_units_outer.cur_id,
                     cur_price_units_inner.cur_id,
                     vn_conv_factor);
            END LOOP;
        END LOOP;
        commit;
vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'insert CET Over');         
     insert into ped_penalty_element_details
       (process_id,
        internal_gmr_ref_no,
        internal_grd_ref_no,
        element_id,
        element_name,
        weg_avg_pricing_assay_id,
        assay_qty,
        assay_qty_unit_id,
        grd_wet_qty,
        grd_dry_qty,
        grd_qty_unit_id,
        parent_stock_ref_no)
       select pc_process_id,
              gmr.internal_gmr_ref_no,
              grd.internal_grd_ref_no,
              pqca.element_id,
              aml.attribute_name,
              grd.weg_avg_pricing_assay_id,
              (case
                when rm.ratio_name = '%' then
                 (pqca.typical * (case
                when pqca.is_deductible = 'Y' then
                 grd.qty
                else
                 grd.qty * (asm.dry_wet_qty_ratio / 100)
              end)) / 100 else(grd.qty * (asm.dry_wet_qty_ratio / 100) * ucm.multiplication_factor * pqca.typical) end) assay_qty,
              (case
                when rm.ratio_name = '%' then
                 grd.qty_unit_id
                else
                 rm.qty_unit_id_numerator
              end) assay_qty_unit_id,
              grd.qty,
              grd.qty * asm.dry_wet_qty_ratio / 100 dry_qty,
              grd.qty_unit_id as grd_qty_unit_id,
              sam.parent_stock_ref_no
         from gmr_goods_movement_record   gmr,
              grd_goods_record_detail     grd,
              pcpd_pc_product_definition  pcpd,
              ash_assay_header            ash,
              asm_assay_sublot_mapping    asm,
              pqca_pq_chemical_attributes pqca,
              rm_ratio_master             rm,
              ucm_unit_conversion_master  ucm,
              aml_attribute_master_list aml,
              sam_stock_assay_mapping sam
        where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
          and grd.status = 'Active'
          and gmr.process_id = pc_process_id
          and grd.process_id = pc_process_id
          and gmr.is_deleted = 'N'
          and gmr.is_internal_movement = 'N'
          and gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no
          and pcpd.input_output = 'Input'
          and pcpd.process_id = pc_process_id
          and pcpd.is_active = 'Y'
          and grd.weg_avg_pricing_assay_id = ash.ash_id
          and ash.ash_id = asm.ash_id
          and asm.asm_id = pqca.asm_id
          and pqca.is_elem_for_pricing = 'N'
          and pqca.unit_of_measure = rm.ratio_id
          and rm.is_active = 'Y'
          and pqca.element_id = aml.attribute_id
          and ucm.from_qty_unit_id = grd.qty_unit_id
          and ucm.to_qty_unit_id =
              (case when rm.ratio_name = '%' then ash.net_weight_unit else
               rm.qty_unit_id_denominator end)
           and grd.internal_grd_ref_no = sam.internal_grd_ref_no
           and sam.is_active = 'Y'
           and ash.assay_type in ('Weighted Avg Pricing Assay', 'Shipment Assay')
           and ash.ash_id = sam.ash_id;
        commit;
vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'insert PED over');         
 insert into gpq_gmr_payable_qty
   (process_id,
    internal_gmr_ref_no,
    element_id,
    payable_qty,
    qty_unit_id)
   select pc_process_id,
          spq.internal_gmr_ref_no,
          spq.element_id,
          sum(nvl(spq.payable_qty, 0)) payable_qty,
          spq.qty_unit_id
     from spq_stock_payable_qty spq
    where spq.is_active = 'Y'
      and spq.is_stock_split = 'N'
      and spq.payable_qty > 0
      and spq.process_id = pc_process_id
    group by spq.process_id,
             spq.internal_gmr_ref_no,
             spq.element_id,
             spq.qty_unit_id;
  commit;
vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'insert GPQ over');   
delete from tsq_temp_stock_quality t
  where t.corporate_id = pc_corporate_id;
  commit;
  vn_log_counter := vn_log_counter + 1;
   sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'delete from tsq_temp_stock_quality over');
                            
 insert into tsq_temp_stock_quality
   (corporate_id,
    internal_grd_ref_no,
    internal_contract_item_ref_no,
    internal_contract_ref_no,
    pcpq_id,
    pcdi_id)
   select pc_corporate_id,
          grd.internal_grd_ref_no,
          pci.internal_contract_item_ref_no,
          pcdi.internal_contract_ref_no,
          pci.pcpq_id,
          pcdi.pcdi_id
     from grd_goods_record_detail    grd,
          pci_physical_contract_item pci,
          pcdi_pc_delivery_item      pcdi
    where grd.internal_contract_item_ref_no =
          pci.internal_contract_item_ref_no
      and pci.pcdi_id = pcdi.pcdi_id
      and grd.process_id = pci.process_id
      and pci.process_id = pcdi.process_id
      and pcdi.process_id = pc_process_id
      and grd.is_deleted = 'N'
      and grd.status = 'Active'
      and pci.is_active = 'Y'
      and pcdi.is_active = 'Y';
commit;
vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'insert grd to tsq_temp_stock_quality over');  
 insert into tsq_temp_stock_quality
   (corporate_id,
    internal_grd_ref_no,
    internal_contract_item_ref_no,
    internal_contract_ref_no,
    pcpq_id,
    pcdi_id)
   select pc_corporate_id,
          dgrd.internal_grd_ref_no,
          pci.internal_contract_item_ref_no,
          pcdi.internal_contract_ref_no,
          pci.pcpq_id,
          pci.pcdi_id
     from dgrd_delivered_grd    dgrd,
          pci_physical_contract_item pci,
          pcdi_pc_delivery_item      pcdi
    where dgrd.internal_contract_item_ref_no =
          pci.internal_contract_item_ref_no
      and pci.pcdi_id = pcdi.pcdi_id
      and dgrd.process_id = pci.process_id
      and pci.process_id = pcdi.process_id
      and pcdi.process_id = pc_process_id
      and dgrd.status = 'Active'
      and pci.is_active = 'Y'
      and pcdi.is_active = 'Y';
commit;   
vn_log_counter := vn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'insert dgrd to tsq_temp_stock_quality over');     
                          
--
-- Previous EOM ID
--
begin
      select tdc.process_id into vc_previous_eom_id from tdc_trade_date_closure tdc
      where tdc.corporate_id = pc_corporate_id
      and tdc.process = pc_process
      and tdc.trade_date =
      (select max(tdc_in.trade_date) from tdc_trade_date_closure tdc_in
      where tdc_in.corporate_id = pc_corporate_id
      and tdc_in.process = pc_process
      and tdc_in.trade_date < pd_trade_date);
    exception
      when no_data_found then
        vc_previous_eom_id := null;
    end;
--
-- Previous Year EOM ID
--
begin    
  select tdc.process_id into vc_previous_year_eom_id from tdc_trade_date_closure tdc
      where tdc.corporate_id = pc_corporate_id
      and tdc.process = pc_process
      and tdc.trade_date =
      (select max(tdc_in.trade_date) from tdc_trade_date_closure tdc_in
      where tdc_in.corporate_id = pc_corporate_id
      and tdc_in.process = pc_process
      and tdc_in.trade_date < trunc(pd_trade_date,'yyyy'));
    exception
      when no_data_found then
        vc_previous_year_eom_id := null;
    end;
    
-- 
-- GMR Is New Flag for MTD and YTD
--    
update gmr_goods_movement_record gmr
   set gmr.is_new_mtd = 'Y'
 where gmr.process_id = pc_process_id 
 and gmr.is_deleted ='N'
  and not exists
  (select * from gmr_goods_movement_record gmr_prev
  where gmr_prev.process_id =  vc_previous_eom_id
  and gmr_prev.internal_gmr_ref_no = gmr.internal_gmr_ref_no);

update gmr_goods_movement_record gmr
   set gmr.is_new_ytd = 'Y'
 where gmr.process_id = pc_process_id 
 and gmr.is_deleted ='N'
  and not exists
  (select * from gmr_goods_movement_record gmr_prev
  where gmr_prev.process_id =  vc_previous_year_eom_id
  and gmr_prev.internal_gmr_ref_no = gmr.internal_gmr_ref_no);
        
commit;
vn_log_counter := vn_log_counter + 1;

  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'End of GMR Is New Update');

-- 
-- GMR Is Assay Updated Flag for MTD and YTD
--     
begin
  for cur_assay_mtd in (select gpq.internal_gmr_ref_no
                          from gpq_gmr_payable_qty gpq,
                               gpq_gmr_payable_qty gpq_prev_month
                         where gpq.internal_gmr_ref_no =
                               gpq_prev_month.internal_gmr_ref_no
                           and gpq.element_id = gpq_prev_month.element_id
                           and gpq.process_id = pc_process_id
                           and gpq_prev_month.process_id = vc_previous_eom_id
                           and (gpq.payable_qty <> gpq_prev_month.payable_qty or
                               gpq.qty_unit_id <> gpq_prev_month.qty_unit_id)
                          group by gpq.internal_gmr_ref_no)
  loop
    update gmr_goods_movement_record gmr
       set gmr.is_assay_updated_mtd = 'Y'
     where gmr.process_id = pc_process_id
       and gmr.internal_gmr_ref_no = cur_assay_mtd.internal_gmr_ref_no
       and gmr.is_deleted ='N';
  end loop;
end;
commit;

begin
  for cur_assay_ytd in (select gpq.internal_gmr_ref_no
                          from gpq_gmr_payable_qty gpq,
                               gpq_gmr_payable_qty gpq_prev_year
                         where gpq.internal_gmr_ref_no =
                               gpq_prev_year.internal_gmr_ref_no
                           and gpq.element_id = gpq_prev_year.element_id
                           and gpq.process_id = pc_process_id
                           and gpq_prev_year.process_id = vc_previous_year_eom_id
                           and (gpq.payable_qty <> gpq_prev_year.payable_qty or
                               gpq.qty_unit_id <> gpq_prev_year.qty_unit_id)
                           group by gpq.internal_gmr_ref_no)
  loop
    update gmr_goods_movement_record gmr
       set gmr.is_assay_updated_ytd = 'Y'
     where gmr.process_id = pc_process_id
       and gmr.internal_gmr_ref_no = cur_assay_ytd.internal_gmr_ref_no
       and gmr.is_deleted ='N';
  end loop;
end;
commit;
vn_log_counter := vn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'End of GMR Assay Update Flag');
gvn_log_counter := vn_log_counter;                          
 exception when others then 
           vobj_error_log.extend;
           vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                'procedure sp_misc',
                                                                'GEN-001',
                                                                'Code:' ||
                                                                SQLCODE ||
                                                                ' Message:' ||
                                                                SQLERRM,
                                                                NULL,
                                                                'EOD',
                                                                pc_user_id,
                                                                SYSDATE,
                                                                pd_trade_date);
            sp_insert_error_log(vobj_error_log);
            commit;
    END;
procedure sp_daily_position_record ( pc_corporate_id varchar2, pd_trade_date date,pc_process_id   varchar2)
as

begin

insert into dpr_daily_position_record
  (trade_date,
   corporate_id,
   business_line_id,
   profit_center_id,
   product_id,
   fixed_qty,
   quotational_qty,process_id)
with last_eod_dump  as
(select dbd1.end_date db_dump_end_timestamp,
        dbd1.start_date db_dump_start_timestamp,
       (select max(tdc.trade_date)
          from tdc_trade_date_closure tdc
         where tdc.corporate_id = dbd1.corporate_id
           and tdc.process = dbd1.process
           and tdc.trade_date < dbd1.trade_date) trade_date
  from dbd_database_dump dbd1
 where dbd1.trade_date = pd_trade_date
   and dbd1.corporate_id = pc_corporate_id
   and dbd1.process = 'EOD')
select 
pd_trade_date,
t.corporate_id, 
t.business_line_id, 
t.profit_center_id, 
t.product_id,
sum(t.fixed_qty) fixed_qty,
sum(t.quotational_qty) quotational_qty,
pc_process_id
from 
(
select 
pd_trade_date trade_date,
corporate_id, 
business_line_id, 
profit_center_id, 
product_id,
sum(fixed_qty) fixed_qty,
sum(quotational_qty) quotational_qty
from (
-- Physical New Trades and Modified trade
SELECT   'Physicals' section_name,
         pcm.contract_ref_no, 
         pcm.corporate_id, 
         pcdi.pcdi_id,
         akc.corporate_name, 
         blm.business_line_id, 
         blm.business_line_name,
         cpc.profit_center_id, 
         cpc.profit_center_short_name,
         cpc.profit_center_name, 
         pdm.product_id,
         pdm.product_desc product_name, 
         pcm.issue_date,
         CASE
            WHEN pcbph.price_basis = 'Fixed'
               THEN ( case when PCM.PURCHASE_SALES = 'S' then (-1) * diqsl.total_qty_delta * ucm.multiplication_factor else diqsl.total_qty_delta * ucm.multiplication_factor end)
            ELSE 0
         END fixed_qty,
         CASE
            WHEN pcbph.price_basis <> 'Fixed'
               THEN ( case when PCM.PURCHASE_SALES = 'S' then (-1) * diqsl.total_qty_delta * ucm.multiplication_factor else diqsl.total_qty_delta * ucm.multiplication_factor end)
            ELSE 0
         END quotational_qty,
         last_eod_dump1.db_dump_end_timestamp,
         qum.qty_unit_id,
         qum.qty_unit base_qty_unit
         
    FROM pcm_physical_contract_main@eka_appdb pcm,
         pcdi_pc_delivery_item@eka_appdb pcdi,
         diqs_delivery_item_qty_status@eka_appdb diqs,
         pcpd_pc_product_definition@eka_appdb pcpd,
         (SELECT   pcbph.internal_contract_ref_no,
                   CASE
                      WHEN SUM (CASE
                                   WHEN pcbpd.price_basis = 'Fixed'
                                      THEN 0
                                   ELSE 1
                                END
                               ) = 0
                         THEN 'Fixed'
                      ELSE 'Other'
                   END price_basis
              FROM pcbph_pc_base_price_header@eka_appdb pcbph,
                   pcbpd_pc_base_price_detail@eka_appdb pcbpd
             WHERE pcbph.pcbph_id = pcbpd.pcbph_id
               AND pcbph.is_active = 'Y'
               AND pcbpd.is_active = 'Y'
          GROUP BY pcbph.internal_contract_ref_no) pcbph,
         pdm_productmaster pdm,
         ucm_unit_conversion_master ucm,
         ak_corporate akc,
         cpc_corporate_profit_center cpc,
         blm_business_line_master@eka_appdb blm,
         diqsl_delivery_itm_qty_sts_log@eka_appdb diqsl, 
         axs_action_summary@eka_appdb axs,
         qum_quantity_unit_master qum,
         last_eod_dump last_eod_dump1
   WHERE pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
     AND pcdi.pcdi_id = diqs.pcdi_id
     AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pcm.contract_status IN ( 'In Position','Cancelled')
     AND pcm.contract_type = 'BASEMETAL'
     AND pcdi.is_active = 'Y'
     AND diqs.is_active = 'Y'
     AND pcpd.is_active = 'Y'
     AND pcpd.input_output = 'Input'
     AND pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pcdi.internal_contract_ref_no = pcbph.internal_contract_ref_no
     AND ucm.from_qty_unit_id = diqs.item_qty_unit_id
     AND ucm.to_qty_unit_id = pdm.base_quantity_unit
     AND pcpd.product_id = pdm.product_id
     AND pcm.corporate_id = akc.corporate_id
     AND pcpd.profit_center_id = cpc.profit_center_id(+)
     AND cpc.business_line_id = blm.business_line_id(+)
     and diqs.diqs_id = diqsl.diqs_id
     and diqsl.internal_action_ref_no = axs.internal_action_ref_no
     and pdm.base_quantity_unit = qum.qty_unit_id
    -- and diqsl.entry_type ='Insert'
     and axs.action_id in('CREATE_SC','CREATE_PC','AMEND_PC','AMEND_SC','MODIFY_PC','MODIFY_SC')
     and axs.created_date > last_eod_dump1.db_dump_start_timestamp
     and axs.created_date <= last_eod_dump1.db_dump_end_timestamp
     AND AXS.EFF_DATE <= pd_trade_date
     and pcm.corporate_id=pc_corporate_id
 union all
   --Physical Cancelled trade
  SELECT   'Physicals' section_name,
         pcm.contract_ref_no, 
         pcm.corporate_id, 
         pcdi.pcdi_id,
         akc.corporate_name, 
         blm.business_line_id, 
         blm.business_line_name,
         cpc.profit_center_id, 
         cpc.profit_center_short_name,
         cpc.profit_center_name, 
         pdm.product_id,
         pdm.product_desc product_name, 
         pcm.issue_date,
         CASE
            WHEN pcbph.price_basis = 'Fixed'
               THEN ( case when PCM.PURCHASE_SALES = 'S' then  diqs.total_qty * ucm.multiplication_factor else (-1) *diqs.total_qty * ucm.multiplication_factor end)
            ELSE 0
         END fixed_qty,
         CASE
            WHEN pcbph.price_basis <> 'Fixed'
               THEN ( case when PCM.PURCHASE_SALES = 'S' then diqs.total_qty * ucm.multiplication_factor else  (-1) * diqs.total_qty * ucm.multiplication_factor end)
            ELSE 0
         END quotational_qty,
         last_eod_dump1.db_dump_end_timestamp,
         qum.qty_unit_id,
         qum.qty_unit base_qty_unit
         
    FROM pcm_physical_contract_main@eka_appdb pcm,
         pcdi_pc_delivery_item@eka_appdb pcdi,
         diqs_delivery_item_qty_status@eka_appdb diqs,
         pcpd_pc_product_definition@eka_appdb pcpd,
         (SELECT   pcbph.internal_contract_ref_no,
                   CASE
                      WHEN SUM (CASE
                                   WHEN pcbpd.price_basis = 'Fixed'
                                      THEN 0
                                   ELSE 1
                                END
                               ) = 0
                         THEN 'Fixed'
                      ELSE 'Other'
                   END price_basis
              FROM pcbph_pc_base_price_header@eka_appdb pcbph,
                   pcbpd_pc_base_price_detail@eka_appdb pcbpd
             WHERE pcbph.pcbph_id = pcbpd.pcbph_id
               AND pcbph.is_active = 'Y'
               AND pcbpd.is_active = 'Y'
          GROUP BY pcbph.internal_contract_ref_no) pcbph,
         pdm_productmaster pdm,
         ucm_unit_conversion_master ucm,
         ak_corporate akc,
         cpc_corporate_profit_center cpc,
         blm_business_line_master@eka_appdb blm,
          pcmul_phy_contract_main_ul@eka_appdb pcmul,
         axs_action_summary@eka_appdb axs,
         qum_quantity_unit_master qum,
         last_eod_dump last_eod_dump1
   WHERE pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
     AND pcdi.pcdi_id = diqs.pcdi_id
     AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pcm.contract_status = 'Cancelled'
     AND pcm.contract_type = 'BASEMETAL'
     AND pcdi.is_active = 'Y'
     AND diqs.is_active = 'Y'
     AND pcpd.is_active = 'Y'
     AND pcpd.input_output = 'Input'
     AND pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pcdi.internal_contract_ref_no = pcbph.internal_contract_ref_no
     AND ucm.from_qty_unit_id = diqs.item_qty_unit_id
     AND ucm.to_qty_unit_id = pdm.base_quantity_unit
     AND pcpd.product_id = pdm.product_id
     AND pcm.corporate_id = akc.corporate_id
     AND pcpd.profit_center_id = cpc.profit_center_id(+)
     AND cpc.business_line_id = blm.business_line_id(+)
     and pcmul.internal_contract_ref_no = pcm.internal_contract_ref_no
     and pcmul.contract_status = 'Cancelled'
     and pcmul.internal_action_ref_no = axs.internal_action_ref_no
     and pdm.base_quantity_unit = qum.qty_unit_id
    -- and diqsl.entry_type ='Insert'
     and axs.action_id in('CANCEL_PC', 'CANCEL_SC')
     and axs.created_date > last_eod_dump1.db_dump_start_timestamp
     and axs.created_date <= last_eod_dump1.db_dump_end_timestamp
     AND AXS.EFF_DATE <= pd_trade_date
     and pcm.corporate_id=pc_corporate_id
   
     
-- 'Any one day price fix' 
union all
select 'Any one day price fix' section_name,
       pcm.contract_ref_no,
       pcm.corporate_id,
       pcdi.pcdi_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       pdm.product_id,
       pdm.product_desc product_name,
       pfd.as_of_date issue_date,
       (CASE WHEN PCM.PURCHASE_SALES = 'S' Then
            -1 else 1 end)* (pfd.qty_fixed * ucm.multiplication_factor) fixed_qty,
       ((CASE WHEN PCM.PURCHASE_SALES = 'S' then
            1 else -1 end) * pfd.qty_fixed * ucm.multiplication_factor) quotational_qty,
       last_eod_dump1.db_dump_end_timestamp,
       qum.qty_unit_id,
       qum.qty_unit base_qty_unit    

  from pcm_physical_contract_main@eka_appdb     pcm,
       pcdi_pc_delivery_item@eka_appdb          pcdi,
       pfd_price_fixation_details@eka_appdb     pfd,
       poch_price_opt_call_off_header@eka_appdb poch,
       pofh_price_opt_fixation_header@eka_appdb pofh,
       pocd_price_option_calloff_dtls@eka_appdb pocd,
       ppfh_phy_price_formula_header@eka_appdb  ppfh,
       pfqpp_phy_formula_qp_pricing@eka_appdb   pfqpp,
       pcpd_pc_product_definition@eka_appdb     pcpd,
       axs_action_summary@eka_appdb             axs,
       pfam_price_fix_action_mapping@EKA_APPDB  pfam,
       pdm_productmaster              pdm,
       qum_quantity_unit_master       qum,
       ucm_unit_conversion_master     ucm,
       ak_corporate                   akc,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master@eka_appdb       blm,
       last_eod_dump             last_eod_dump1
 where pcm.contract_type = 'BASEMETAL'
   and pcm.contract_status = 'In Position'
   and pcdi.is_active = 'Y'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pfd.pofh_id = pofh.pofh_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and pfqpp.is_qp_any_day_basis = 'Y'
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pfam.pfd_id = pfd.pfd_id
   and axs.internal_action_ref_no = pfam.internal_action_ref_no
   and axs.action_id  in ('CREATE_PRICE_FIXATION')
   and pcpd.product_id = pdm.product_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and ucm.from_qty_unit_id = pcdi.qty_unit_id
   and ucm.to_qty_unit_id = pdm.base_quantity_unit
   and pcm.corporate_id = akc.corporate_id
   and pcpd.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
      -- and pfd.is_active = 'Y' --comment  this condition to fetch cancelled price fixation also for same contract it balance the next section data
   and pcm.is_active = 'Y'
   and poch.is_active = 'Y'
   and pofh.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and pfqpp.is_active = 'Y'
   and pfd.as_of_date <= pd_trade_date
   and axs.created_date > last_eod_dump1.db_dump_start_timestamp
   and axs.created_date <= last_eod_dump1.db_dump_end_timestamp
   and pcm.corporate_id=pc_corporate_id
---todo need to use axs table creatation date between db_dump_start_timestamp and db_dump_end_timestamp

  -- any one day price fix cancelled
   union all
 select 'Any one day price fix' section_name,
        pcm.contract_ref_no,
        pcm.corporate_id,
        pcdi.pcdi_id,
        akc.corporate_name,
        blm.business_line_id,
        blm.business_line_name,
        cpc.profit_center_id,
        cpc.profit_center_short_name,
        cpc.profit_center_name,
        pdm.product_id,
        pdm.product_desc product_name,
        pfd.as_of_date issue_date,
        ((CASE WHEN PCM.PURCHASE_SALES = 'S' then
            1 else -1 end) * pfd.qty_fixed * ucm.multiplication_factor) fixed_qty,
        ((CASE WHEN PCM.PURCHASE_SALES = 'S' then
            -1 else 1 end) * pfd.qty_fixed * ucm.multiplication_factor) quotational_qty,
        last_eod_dump1.db_dump_end_timestamp,
        qum.qty_unit_id,
        qum.qty_unit base_qty_unit       
 
   from pcm_physical_contract_main@eka_appdb     pcm,
        pcdi_pc_delivery_item@eka_appdb          pcdi,
        pfd_price_fixation_details@eka_appdb     pfd,
        poch_price_opt_call_off_header@eka_appdb poch,
        pofh_price_opt_fixation_header@eka_appdb pofh,
        pocd_price_option_calloff_dtls@eka_appdb pocd,
        ppfh_phy_price_formula_header@eka_appdb  ppfh,
        pfqpp_phy_formula_qp_pricing@eka_appdb   pfqpp,
        pcpd_pc_product_definition@eka_appdb     pcpd,
        pdm_productmaster              pdm,
        qum_quantity_unit_master       qum,
        ucm_unit_conversion_master     ucm,
        axs_action_summary@eka_appdb             axs,
        pfam_price_fix_action_mapping@EKA_APPDB  pfam,
        ak_corporate                   akc,
        cpc_corporate_profit_center    cpc,
        blm_business_line_master@eka_appdb       blm,
        last_eod_dump                  last_eod_dump1
  where pcm.contract_type = 'BASEMETAL'
    and pcm.contract_status = 'In Position'
    and pcdi.is_active = 'Y'
    and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
    and pfd.pofh_id = pofh.pofh_id
    and pcdi.pcdi_id = poch.pcdi_id
    and poch.poch_id = pocd.poch_id
    and pocd.pocd_id = pofh.pocd_id
    and pocd.pcbpd_id = ppfh.pcbpd_id
    and ppfh.ppfh_id = pfqpp.ppfh_id
    and pfqpp.is_qp_any_day_basis = 'Y'
    and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
    and pcpd.input_output = 'Input'
    and pcpd.product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and ucm.from_qty_unit_id = pcdi.qty_unit_id
    and ucm.to_qty_unit_id = pdm.base_quantity_unit
    and pcm.corporate_id = akc.corporate_id
    and pcpd.profit_center_id = cpc.profit_center_id(+)
    and cpc.business_line_id = blm.business_line_id(+)
    and axs.action_id in ('CANCEL_PRICE_FIXATION')
    and axs.internal_action_ref_no = pfam.internal_action_ref_no
    and pfam.pfd_id = pfd.pfd_id
    and pfd.is_active = 'N'
    and pcm.is_active = 'Y'
    and poch.is_active = 'Y'
    and pofh.is_active = 'Y'
    and ppfh.is_active = 'Y'
    and pfqpp.is_active = 'Y'
    and axs.created_date > last_eod_dump1.db_dump_start_timestamp
    and axs.created_date <= last_eod_dump1.db_dump_end_timestamp
    AND AXS.EFF_DATE <= pd_trade_date
    and pcm.corporate_id = pc_corporate_id
 union all
  -- 'Average price fix'and cancelled
 select --(CASE when is_any_day.any_one_day = 'N' then 'Average price fix' else 'Any one day price fix' end) section_name,
        --pcm.contract_ref_no,
        (case
         when to_char(pofh.qp_start_date, 'dd') = '01' and
              last_day(pofh.qp_start_date) = pofh.qp_end_date then
          'Average price fix'
         else
          'Any one day price fix'
       end) section_name,
      (case
         when to_char(pofh.qp_start_date, 'dd') = '01' and
              last_day(pofh.qp_start_date) = pofh.qp_end_date then
         null
         else
          pcm.contract_ref_no
       end) contract_ref_no,
        pcm.corporate_id,
        pcdi.pcdi_id,
        akc.corporate_name,
        blm.business_line_id,
        blm.business_line_name,
        cpc.profit_center_id,
        cpc.profit_center_short_name,
        cpc.profit_center_name,
        pdm.product_id,
        pdm.product_desc product_name,
         (case
         when to_char(pofh.qp_start_date, 'dd') = '01' and
              last_day(pofh.qp_start_date) = pofh.qp_end_date then
         null
         else
          pofhd.priced_date
       end)  issue_date,
         (CASE WHEN PCM.PURCHASE_SALES = 'S' then
            -1 else 1 end)*(pofhd.per_day_pricing_qty * ucm.multiplication_factor) fixed_qty,
        ( (CASE WHEN PCM.PURCHASE_SALES = 'S' then
            1 else -1 end)*  pofhd.per_day_pricing_qty * ucm.multiplication_factor) quotational_qty,
        last_eod_dump1.db_dump_end_timestamp,
        qum.qty_unit_id,
        qum.qty_unit base_qty_unit
    from pcm_physical_contract_main@eka_appdb     pcm,
        pcdi_pc_delivery_item@eka_appdb          pcdi,
        pofhd_pofh_daily@EKA_APPDB     pofhd,
        poch_price_opt_call_off_header@eka_appdb poch,
        pofh_price_opt_fixation_header@eka_appdb pofh,
        pocd_price_option_calloff_dtls@eka_appdb pocd,
        ppfh_phy_price_formula_header@eka_appdb  ppfh,
        pfqpp_phy_formula_qp_pricing@eka_appdb   pfqpp,
        pcpd_pc_product_definition@eka_appdb     pcpd,
        pdm_productmaster              pdm,
        qum_quantity_unit_master       qum,
        ucm_unit_conversion_master     ucm,
        ak_corporate                   akc,
        cpc_corporate_profit_center    cpc,
        blm_business_line_master@eka_appdb       blm,
        last_eod_dump last_eod_dump1 
  where pcm.contract_type = 'BASEMETAL'
    and pcm.contract_status = 'In Position'
    and pcdi.is_active = 'Y'
    and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
    and pofhd.pofh_id = pofh.pofh_id
    and pcdi.pcdi_id = poch.pcdi_id
    and poch.poch_id = pocd.poch_id
    and pofhd.pocd_id = pocd.pocd_id
    and pocd.pocd_id = pofh.pocd_id
    and pocd.pcbpd_id = ppfh.pcbpd_id
    and ppfh.ppfh_id = pfqpp.ppfh_id
    and pfqpp.is_qp_any_day_basis is null
    and not exists (select pfd.pfd_id
          from pfd_price_fixation_details@eka_appdb pfd
         where pfd.pofh_id = pofh.pofh_id
           and pfd.is_active = 'Y'
           and pfd.as_of_date = pofhd.priced_date)
    and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
    and pcpd.input_output = 'Input'
  --  and is_any_day.pofh_id = pofhd.pofh_id
    and pcpd.product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and ucm.from_qty_unit_id = pcdi.qty_unit_id
    and ucm.to_qty_unit_id = pdm.base_quantity_unit
    and pcm.corporate_id = akc.corporate_id
    and pcpd.profit_center_id = cpc.profit_center_id(+)
    and cpc.business_line_id = blm.business_line_id(+)
    and pofhd.is_active = 'Y'
    and pcm.is_active = 'Y'
    and poch.is_active = 'Y'
    and pofh.is_active = 'Y'
    and ppfh.is_active = 'Y'
    and pfqpp.is_active = 'Y'
    and pofhd.priced_date <= pd_trade_date
    and pcm.corporate_id = pc_corporate_id
    and pofhd.priced_date > last_eod_dump1.trade_date 
  UNION ALL
----Futures
select section_name,
       contract_ref_no,
       corporate_id,
       null pcdi_id,
       corporate_name,
       business_line_id,
       business_line_name,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       product_id,
       product_name,
       issue_date,
       case
         when instrument_type = 'Future' then
          qty
         else
          0
       end fixed_qty,
       case
         when instrument_type = 'Average' then
          qty
         else
          0
       end quotational_qty,
       db_dump_end_timestamp,
       qty_unit_id,
       base_qty_unit
  from (select 'Futures' section_name,
               dt.derivative_ref_no contract_ref_no,
               dt.corporate_id corporate_id,
               akc.corporate_name corporate_name,
               blm.business_line_id business_line_id,
               blm.business_line_name business_line_name,
               cpc.profit_center_id profit_center_id,
               cpc.profit_center_short_name profit_center_short_name,
               cpc.profit_center_name profit_center_name,
               pdm.product_id product_id,
               pdm.product_desc product_name,
               dt.trade_date issue_date,
               sum(dtql.total_quantity_delta *
                   decode(dt.trade_type, 'Buy', 1, 'Sell', -1) *
                   ucm.multiplication_factor) qty,
               last_eod_dump1.db_dump_end_timestamp,
               pdm.base_quantity_unit qty_unit_id,
               qum.qty_unit base_qty_unit,
               irm.instrument_type
          from dt_derivative_trade@eka_appdb         dt,
               ak_corporate                akc,
               cpc_corporate_profit_center cpc,
               blm_business_line_master@eka_appdb    blm,
               drm_derivative_master@eka_appdb       drm,
               dim_der_instrument_master@eka_appdb   dim,
               irm_instrument_type_master@eka_appdb  irm,
               dt_qty_log@eka_appdb                  dtql,
               pdd_product_derivative_def  pdd,
               pdm_productmaster           pdm,
               axs_action_summary@eka_appdb          axs,
               last_eod_dump               last_eod_dump1,
               ucm_unit_conversion_master  ucm,
               qum_quantity_unit_master    qum
         where akc.corporate_id = dt.corporate_id
           and dt.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id
           and dt.dr_id = drm.dr_id
           and drm.instrument_id = dim.instrument_id
           and irm.instrument_type_id = dim.instrument_type_id
           and dt.internal_derivative_ref_no =
               dtql.internal_derivative_ref_no
           and axs.action_id in
               ('CDC_CREATE_OTC_AVERAGE_FORWARD', 'CDC_CREATE_EX_FUTURE',
                'CDC_MODIFY_EX_FUTURE', 'CDC_DELETE_EX_FUTURE',
                'CDC_DELETE_OTC_AVERAGE_FORWARD',
                'CDC_MODIFY_OTC_AVERAGE_FORWARD')
           and irm.instrument_type in ('Average', 'Future')
           and pdd.derivative_def_id = dim.product_derivative_id
           and pdd.product_id = pdm.product_id
           and axs.internal_action_ref_no = dtql.internal_action_ref_no
           and axs.created_date > last_eod_dump1.db_dump_start_timestamp
           and axs.created_date <= last_eod_dump1.db_dump_end_timestamp
           and dt.corporate_id = pc_corporate_id
           and dt.status in ('Verified', 'Delete')
           and dt.trade_date <= pd_trade_date
           and ucm.from_qty_unit_id = dt.quantity_unit_id
           and ucm.to_qty_unit_id = pdm.base_quantity_unit
           and qum.qty_unit_id = pdm.base_quantity_unit
           AND  axs.eff_date <= pd_trade_date
         group by dt.derivative_ref_no,
                  dt.corporate_id,
                  akc.corporate_name,
                  blm.business_line_id,
                  blm.business_line_name,
                  cpc.profit_center_id,
                  cpc.profit_center_short_name,
                  cpc.profit_center_name,
                  pdm.product_id,
                  pdm.product_desc,
                  dt.trade_date,
                  pdm.base_quantity_unit,
                  db_dump_end_timestamp,
                  qum.qty_unit,
            irm.instrument_type
  union all -------trade whose trade date is less AsOFDate and greater the last eod date and creation cade is before lase eod dump date 
  select 'Futures' section_name,
         dt.derivative_ref_no contract_ref_no,
         dt.corporate_id corporate_id,
         akc.corporate_name corporate_name,
         blm.business_line_id business_line_id,
         blm.business_line_name business_line_name,
         cpc.profit_center_id profit_center_id,
         cpc.profit_center_short_name profit_center_short_name,
         cpc.profit_center_name profit_center_name,
         pdm.product_id product_id,
         pdm.product_desc product_name,
         dt.trade_date issue_date,
         sum(dtql.total_quantity_delta * (case
               when dt.status = 'Verified' then
                decode(dt.trade_type, 'Buy', 1, 'Sell', -1) else
                decode(dt.trade_type, 'Buy', -1, 'Sell', 1)
             end) * ucm.multiplication_factor) qty,
         last_eod_dump1.db_dump_end_timestamp,
         pdm.base_quantity_unit qty_unit_id,
         qum.qty_unit base_qty_unit,
         irm.instrument_type
    from dt_derivative_trade@eka_appdb        dt,
         ak_corporate                         akc,
         cpc_corporate_profit_center          cpc,
         blm_business_line_master@eka_appdb   blm,
         drm_derivative_master@eka_appdb      drm,
         dim_der_instrument_master@eka_appdb  dim,
         irm_instrument_type_master@eka_appdb irm,
         dt_qty_log@eka_appdb                 dtql,
         pdd_product_derivative_def           pdd,
         pdm_productmaster                    pdm,
         axs_action_summary@eka_appdb         axs,
         last_eod_dump                        last_eod_dump1,
         ucm_unit_conversion_master           ucm,
         qum_quantity_unit_master             qum
   where akc.corporate_id = dt.corporate_id
     and dt.profit_center_id = cpc.profit_center_id
     and cpc.business_line_id = blm.business_line_id
     and dt.dr_id = drm.dr_id
     and drm.instrument_id = dim.instrument_id
     and irm.instrument_type_id = dim.instrument_type_id
     and dt.internal_derivative_ref_no = dtql.internal_derivative_ref_no
     and axs.action_id in
         ('CDC_CREATE_OTC_AVERAGE_FORWARD', 'CDC_CREATE_EX_FUTURE',
          'CDC_MODIFY_EX_FUTURE', 'CDC_DELETE_EX_FUTURE',
          'CDC_DELETE_OTC_AVERAGE_FORWARD', 'CDC_MODIFY_OTC_AVERAGE_FORWARD')
     and irm.instrument_type in ('Average', 'Future')
     and pdd.derivative_def_id = dim.product_derivative_id
     and pdd.product_id = pdm.product_id
     and axs.internal_action_ref_no = dtql.internal_action_ref_no
     and axs.created_date < last_eod_dump1.db_dump_start_timestamp
     and axs.eff_date > last_eod_dump1.trade_date
        -- and axs.created_date <= last_eod_dump1.db_dump_end_timestamp
     and dt.corporate_id = pc_corporate_id
     and dt.status in ('Verified', 'Delete')
     and dt.trade_date <= pd_trade_date
     and ucm.from_qty_unit_id = dt.quantity_unit_id
     and ucm.to_qty_unit_id = pdm.base_quantity_unit
     and qum.qty_unit_id = pdm.base_quantity_unit
     and axs.eff_date <= pd_trade_date
   group by dt.derivative_ref_no,
            dt.corporate_id,
            akc.corporate_name,
            blm.business_line_id,
            blm.business_line_name,
            cpc.profit_center_id,
            cpc.profit_center_short_name,
            cpc.profit_center_name,
            pdm.product_id,
            pdm.product_desc,
            dt.trade_date,
            pdm.base_quantity_unit,
            db_dump_end_timestamp,
            qum.qty_unit,
            irm.instrument_type)
UNION ALL
---------------------avg trades       
select 'Average price fix' section_name,
       null contract_ref_no,
       dt.corporate_id corporate_id,
       null,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       pdm.product_id product_id,
       pdm.product_desc product_name,
       null issue_date,
       sum (dtavg.quantity * decode(dt.trade_type, 'Buy', 1, 'Sell', -1) * ucm.multiplication_factor) fixed_qty,
       sum(dtavg.quantity * decode(dt.trade_type, 'Buy', -1, 'Sell', 1) * ucm.multiplication_factor) quotational_qty,
       last_eod_dump1.db_dump_end_timestamp,
       pdm.base_quantity_unit qty_unit_id,
       qum.qty_unit base_qty_unit
  from dt_derivative_trade@eka_appdb dt,
       ak_corporate akc,
       cpc_corporate_profit_center cpc,
       blm_business_line_master@eka_appdb blm,
       drm_derivative_master drm,
       dim_der_instrument_master dim,
       irm_instrument_type_master irm,
       pdd_product_derivative_def pdd,
       pdm_productmaster pdm,
       ucm_unit_conversion_master ucm,
       last_eod_dump last_eod_dump1,
       dt_avg@eka_appdb dtavg,
       qum_quantity_unit_master qum,
       (SELECT dt.derivative_ref_no,
           CASE
               WHEN to_char(dt.average_from_date, 'MON') = to_char(dt.average_to_date, 'MON') AND
                  to_char(dt.average_from_date, 'DD') = '01' AND
                  dt.average_to_date = last_day(dt.average_to_date) THEN
                'N'
               ELSE
                'Y'
           END any_one_day
      FROM   dt_derivative_trade@eka_appdb dt) avg_or_any_day
 where akc.corporate_id = dt.corporate_id
   and dt.profit_center_id = cpc.profit_center_id
   AND    avg_or_any_day.derivative_ref_no = dt.derivative_ref_no
AND    avg_or_any_day.any_one_day = 'N'
   and cpc.business_line_id = blm.business_line_id
   and dt.dr_id = drm.dr_id
   and drm.instrument_id = dim.instrument_id
   and irm.instrument_type_id = dim.instrument_type_id
   and pdd.derivative_def_id = dim.product_derivative_id
   and pdd.product_id = pdm.product_id
   and ucm.from_qty_unit_id = dt.quantity_unit_id
   and ucm.to_qty_unit_id = pdm.base_quantity_unit
   and dtavg.internal_derivative_ref_no = dt.internal_derivative_ref_no
   and qum.qty_unit_id = pdm.base_quantity_unit
   and dtavg.period_date > last_eod_dump1.trade_date
   and irm.instrument_type = 'Average'
   and dt.status <> 'Delete'
   and dtavg.period_date <= pd_trade_date
   and dt.corporate_id= pc_corporate_id
 group by dt.derivative_ref_no,
          dt.corporate_id,
          akc.corporate_name,
          blm.business_line_id,
          blm.business_line_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          cpc.profit_center_name,
          pdm.product_id,
          pdm.product_desc,
        --  dt.trade_date,
           db_dump_end_timestamp,
          pdm.base_quantity_unit,
          qum.qty_unit
union all
select 'Any one day price fix' section_name,
       dt.derivative_ref_no contract_ref_no,
       dt.corporate_id corporate_id,
       null,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       pdm.product_id product_id,
       pdm.product_desc product_name,
       dt.trade_date issue_date,
       sum(dtavg.quantity * decode(dt.trade_type, 'Buy', 1, 'Sell', -1) * ucm.multiplication_factor) fixed_qty,
     sum(dtavg.quantity * decode(dt.trade_type, 'Buy', -1, 'Sell', 1) * ucm.multiplication_factor) quotational_qty,
       last_eod_dump1.db_dump_end_timestamp,
       pdm.base_quantity_unit qty_unit_id,
       qum.qty_unit base_qty_unit
  from dt_derivative_trade@eka_appdb dt,
       ak_corporate akc,
       cpc_corporate_profit_center cpc,
       blm_business_line_master@eka_appdb blm,
       drm_derivative_master drm,
       dim_der_instrument_master dim,
       irm_instrument_type_master irm,
       pdd_product_derivative_def pdd,
       pdm_productmaster pdm,
       ucm_unit_conversion_master ucm,
       last_eod_dump last_eod_dump1,
       dt_avg@eka_appdb dtavg,
       qum_quantity_unit_master qum,
       (SELECT dt.derivative_ref_no,
           CASE
               WHEN to_char(dt.average_from_date, 'MON') = to_char(dt.average_to_date, 'MON') AND
                  to_char(dt.average_from_date, 'DD') = '01' AND
                  dt.average_to_date = last_day(dt.average_to_date) THEN
                'N'
               ELSE
                'Y'
           END any_one_day
      FROM   dt_derivative_trade@eka_appdb dt) avg_or_any_day
 where akc.corporate_id = dt.corporate_id
   and dt.profit_center_id = cpc.profit_center_id
   AND    avg_or_any_day.derivative_ref_no = dt.derivative_ref_no
AND    avg_or_any_day.any_one_day = 'Y'
   and cpc.business_line_id = blm.business_line_id
   and dt.dr_id = drm.dr_id
   and drm.instrument_id = dim.instrument_id
   and irm.instrument_type_id = dim.instrument_type_id
   and pdd.derivative_def_id = dim.product_derivative_id
   and pdd.product_id = pdm.product_id
   and ucm.from_qty_unit_id = dt.quantity_unit_id
   and ucm.to_qty_unit_id = pdm.base_quantity_unit
   and dtavg.internal_derivative_ref_no = dt.internal_derivative_ref_no
   and qum.qty_unit_id = pdm.base_quantity_unit
    -- and dtavg.period_date > last_eod_dump1.trade_date :todo need to use previous eod date
   and irm.instrument_type = 'Average'
   and dt.status = 'Verified'
   and dt.status <> 'Delete'
   and dtavg.period_date <= pd_trade_date
   and dt.corporate_id= pc_corporate_id
 group by dt.derivative_ref_no,
          dt.corporate_id,
          akc.corporate_name,
          blm.business_line_id,
          blm.business_line_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          cpc.profit_center_name,
          pdm.product_id,
          pdm.product_desc,
          dt.trade_date,
          db_dump_end_timestamp,
          pdm.base_quantity_unit,
          qum.qty_unit
UNION ALL
--delete average forward trades       
select 'Any one day price fix' section_name,
       dt.derivative_ref_no contract_ref_no,
       null,
       dt.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       pdm.product_id product_id,
       pdm.product_desc product_name,
       dt.trade_date issue_date,
       sum(dtavg.quantity * decode(dt.trade_type, 'Buy', -1, 'Sell', 1) * ucm.multiplication_factor) fixed_qty,
     sum(dtavg.quantity * decode(dt.trade_type, 'Buy', 1, 'Sell', -1) * ucm.multiplication_factor) quotational_qty,
       last_eod_dump1.db_dump_end_timestamp,
       pdm.base_quantity_unit qty_unit_id,
       qum.qty_unit base_qty_unit
  from dt_derivative_trade@eka_appdb dt,
       dtul_derivative_trade_ul@eka_appdb dtul,
       axs_action_summary@eka_appdb axs,
       ak_corporate akc,
       cpc_corporate_profit_center cpc,
       blm_business_line_master@eka_appdb blm,
       drm_derivative_master drm,
       dim_der_instrument_master dim,
       irm_instrument_type_master irm,
       pdd_product_derivative_def pdd,
       pdm_productmaster pdm,
       ucm_unit_conversion_master ucm,
       last_eod_dump last_eod_dump1,
       dt_avg@eka_appdb  dtavg,
       qum_quantity_unit_master qum,
       (SELECT dt.derivative_ref_no,
           CASE
               WHEN to_char(dt.average_from_date, 'MON') = to_char(dt.average_to_date, 'MON') AND
                  to_char(dt.average_from_date, 'DD') = '01' AND
                  dt.average_to_date = last_day(dt.average_to_date) THEN
                'N'
               ELSE
                'Y'
           END any_one_day
      FROM   dt_derivative_trade@eka_appdb dt) avg_or_any_day
 where akc.corporate_id = dt.corporate_id
   and dtul.internal_derivative_ref_no = dt.internal_derivative_ref_no
   AND    avg_or_any_day.derivative_ref_no = dt.derivative_ref_no
AND    avg_or_any_day.any_one_day = 'Y'
   and dtul.status = 'Delete'
   and dtul.internal_action_ref_no = axs.internal_action_ref_no
   and axs.created_date > last_eod_dump1.db_dump_start_timestamp
   and axs.action_id = 'CDC_DELETE_OTC_AVERAGE_FORWARD'
   and dt.profit_center_id = cpc.profit_center_id
   and cpc.business_line_id = blm.business_line_id
   and dt.dr_id = drm.dr_id
   and drm.instrument_id = dim.instrument_id
   and irm.instrument_type_id = dim.instrument_type_id
   and pdd.derivative_def_id = dim.product_derivative_id
   and pdd.product_id = pdm.product_id
   and ucm.from_qty_unit_id = dt.quantity_unit_id
   and ucm.to_qty_unit_id = pdm.base_quantity_unit
   and dtavg.internal_derivative_ref_no = dt.internal_derivative_ref_no   
   and qum.qty_unit_id = pdm.base_quantity_unit
 --  and dtavg.period_date > last_eod_dump1.trade_date need to use previous eod date
   and irm.instrument_type = 'Average'
   and dtavg.period_date <= pd_trade_date
     and dt.corporate_id= pc_corporate_id
 group by dt.derivative_ref_no,
          dt.corporate_id,
          akc.corporate_name,
          blm.business_line_id,
          blm.business_line_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          cpc.profit_center_name,
          pdm.product_id,
          pdm.product_desc,
          dt.trade_date,
          db_dump_end_timestamp,
          pdm.base_quantity_unit,
          qum.qty_unit
UNION ALL
select 'Average price fix' section_name,
       dt.derivative_ref_no contract_ref_no,
       null,
       dt.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       pdm.product_id product_id,
       pdm.product_desc product_name,
       dt.trade_date issue_date,
       sum(dtavg.quantity * decode(dt.trade_type, 'Buy', -1, 'Sell', 1) * ucm.multiplication_factor) fixed_qty,
     sum(dtavg.quantity * decode(dt.trade_type, 'Buy', 1, 'Sell', -1) * ucm.multiplication_factor) quotational_qty,
       last_eod_dump1.db_dump_end_timestamp,
       pdm.base_quantity_unit qty_unit_id,
       qum.qty_unit base_qty_unit
  from dt_derivative_trade@eka_appdb dt,
       dtul_derivative_trade_ul@eka_appdb dtul,
       axs_action_summary@eka_appdb axs,
       ak_corporate akc,
       cpc_corporate_profit_center cpc,
       blm_business_line_master@eka_appdb blm,
       drm_derivative_master drm,
       dim_der_instrument_master dim,
       irm_instrument_type_master irm,
       pdd_product_derivative_def pdd,
       pdm_productmaster pdm,
       ucm_unit_conversion_master ucm,
       last_eod_dump last_eod_dump1,
       dt_avg@eka_appdb  dtavg,
       qum_quantity_unit_master qum,
       (SELECT dt.derivative_ref_no,
           CASE
               WHEN to_char(dt.average_from_date, 'MON') = to_char(dt.average_to_date, 'MON') AND
                  to_char(dt.average_from_date, 'DD') = '01' AND
                  dt.average_to_date = last_day(dt.average_to_date) THEN
                'N'
               ELSE
                'Y'
           END any_one_day
      FROM   dt_derivative_trade@eka_appdb dt) avg_or_any_day
 where akc.corporate_id = dt.corporate_id
   and dtul.internal_derivative_ref_no = dt.internal_derivative_ref_no
   AND    avg_or_any_day.derivative_ref_no = dt.derivative_ref_no
AND    avg_or_any_day.any_one_day = 'N'
   and dtul.status = 'Delete'
   and dtul.internal_action_ref_no = axs.internal_action_ref_no
   and axs.created_date > last_eod_dump1.db_dump_start_timestamp
   and axs.action_id = 'CDC_DELETE_OTC_AVERAGE_FORWARD'
   and dt.profit_center_id = cpc.profit_center_id
   and cpc.business_line_id = blm.business_line_id
   and dt.dr_id = drm.dr_id
   and drm.instrument_id = dim.instrument_id
   and irm.instrument_type_id = dim.instrument_type_id
   and pdd.derivative_def_id = dim.product_derivative_id
   and pdd.product_id = pdm.product_id
   and ucm.from_qty_unit_id = dt.quantity_unit_id
   and ucm.to_qty_unit_id = pdm.base_quantity_unit
   and dtavg.internal_derivative_ref_no = dt.internal_derivative_ref_no   
   and qum.qty_unit_id = pdm.base_quantity_unit
 --  and dtavg.period_date > last_eod_dump1.trade_date need to use previous eod date
   and irm.instrument_type = 'Average'
   and dtavg.period_date <= pd_trade_date
     and dt.corporate_id= pc_corporate_id
 group by dt.derivative_ref_no,
          dt.corporate_id,
          akc.corporate_name,
          blm.business_line_id,
          blm.business_line_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          cpc.profit_center_name,
          pdm.product_id,
          pdm.product_desc,
          dt.trade_date,
          
          db_dump_end_timestamp,
          pdm.base_quantity_unit,
          qum.qty_unit          )
group by 
corporate_id, 
business_line_id, 
profit_center_id, 
product_id
union all
select pd_trade_date trade_date,
       corporate_id,
       business_line_id,
       profit_center_id,       
       product_id,
       fixed_qty,
       quotational_qty
  from dpr_daily_position_record dpr
  WHERE dpr.trade_date = (select max(t.trade_date)
                                 from tdc_trade_date_closure t
                                where t.trade_date < pd_trade_date
                                  and t.corporate_id = pc_corporate_id
                                  and t.process = 'EOD')
    and dpr.corporate_id = pc_corporate_id)t
    
    group by --t.trade_date,
t.corporate_id, 
t.business_line_id, 
t.profit_center_id, 
t.product_id;
commit;    
    
exception
when others then
null;--TODO : need to ad exception handling
commit;
end;
procedure sp_insert_temp_gmr(pc_corporate_id varchar2,
                             pd_trade_date   date,
                             pc_process_id   varchar2) as
vc_inv_cur_id varchar2(15);    
vc_inv_cur_code varchar2(15);                       
begin
gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'inside sp_insert_temp_gmr stats started'); 
sp_gather_stats('pcepc_pc_elem_payable_content');
sp_gather_stats('ak_corporate');
sp_gather_stats('aml_attribute_master_list');
sp_gather_stats('ash_assay_header');
sp_gather_stats('asm_assay_sublot_mapping');
sp_gather_stats('cim_citymaster');
sp_gather_stats('cm_currency_master');
sp_gather_stats('cpc_corporate_profit_center');
sp_gather_stats('cym_countrymaster');
sp_gather_stats('dgrd_delivered_grd');
sp_gather_stats('dipq_delivery_item_payable_qty');
sp_gather_stats('gmr_goods_movement_record');
sp_gather_stats('gph_gmr_penalty_header');
sp_gather_stats('grd_goods_record_detail');
sp_gather_stats('grh_gmr_refining_header');
sp_gather_stats('gth_gmr_treatment_header');
sp_gather_stats('iepd_inv_epenalty_details');
sp_gather_stats('ii_invoicable_item');
sp_gather_stats('iid_invoicable_item_details');
sp_gather_stats('inrc_inv_refining_charges');
sp_gather_stats('intc_inv_treatment_charges');
sp_gather_stats('is_invoice_summary');
sp_gather_stats('itm_incoterm_master');
sp_gather_stats('pad_penalty_attribute_details');
sp_gather_stats('patd_pa_temp_data');
sp_gather_stats('pcap_pc_attribute_penalty');
sp_gather_stats('pcaph_pc_attr_penalty_header');
sp_gather_stats('pcdi_pc_delivery_item');
sp_gather_stats('pcerc_pc_elem_refining_charge');
sp_gather_stats('pcetc_pc_elem_treatment_charge');
sp_gather_stats('pci_physical_contract_item');
sp_gather_stats('pcm_physical_contract_main');
sp_gather_stats('pcpch_pc_payble_content_header');
sp_gather_stats('pcpd_pc_product_definition');
sp_gather_stats('pcrh_pc_refining_header');
sp_gather_stats('pcth_pc_treatment_header');
sp_gather_stats('pdm_productmaster');
sp_gather_stats('phd_profileheaderdetails');
sp_gather_stats('pocd_price_option_calloff_dtls');
sp_gather_stats('poch_price_opt_call_off_header');
sp_gather_stats('pqca_pq_chemical_attributes');
sp_gather_stats('pqcapd_prd_qlty_cattr_pay_dtls');
sp_gather_stats('pqd_penalty_quality_details');
sp_gather_stats('qat_quality_attributes');
sp_gather_stats('qum_quantity_unit_master');
sp_gather_stats('red_refining_element_details');
sp_gather_stats('rm_ratio_master');
sp_gather_stats('rqd_refining_quality_details');
sp_gather_stats('sac_stock_assay_content');
sp_gather_stats('sam_stock_assay_mapping');
sp_gather_stats('sm_state_master');
sp_gather_stats('spq_stock_payable_qty');
sp_gather_stats('ted_treatment_element_details');
sp_gather_stats('tsq_temp_stock_quality');
sp_gather_stats('ucm_unit_conversion_master');
sp_gather_stats('vd_voyage_detail');
sp_gather_stats('gepd_gmr_element_pledge_detail'); 
commit;

gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'inside sp_insert_temp_gmr stats ends'); 

delete from temp_gmr_invoice where corporate_id = pc_corporate_id;
  commit;
gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'delete temp_gmr_invoice over'); 
  
  insert into temp_gmr_invoice
    (process_id,
     corporate_id,
     invoice_ref_no,
     internal_invoice_ref_no,
     stock_id,
     invoice_item_amount,
     invoice_currency_id,
     new_invoice_price,
     invoice_type,
     invoice_issue_date,
     new_invoice_price_unit_id)
    select gmr.process_id,
           gmr.corporate_id,
           iss.invoice_ref_no,
           iid.internal_invoice_ref_no,
           iid.stock_id,
           iid.invoice_item_amount,
           iid.invoice_currency_id,
           new_invoice_price,
           iss.invoice_type,
           iss.invoice_issue_date,
           iid.new_invoice_price_unit_id
      from iid_invoicable_item_details iid,
           is_invoice_summary          iss,
           gmr_goods_movement_record   gmr
     where iid.internal_invoice_ref_no = iss.internal_invoice_ref_no
       and iss.is_active = 'Y'
       and gmr.process_id = pc_process_id
       and gmr.process_id = iss.process_id
       and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
       and gmr.latest_internal_invoice_ref_no = iid.internal_invoice_ref_no;

  commit;
gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'insert temp_gmr_invoice over'); 
  
  delete from tgi_temp_gmr_invoice t
  where t.corporate_id = pc_corporate_id;
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'delete from tgi_temp_gmr_invoice Over');
  
  --
  -- Invoice Amount For GMR
  --
  insert into tgi_temp_gmr_invoice
    (corporate_id,
     process_id,
     internal_gmr_ref_no,
     internal_invoice_ref_no,
     invoice_item_amount,
     invoice_currency_id,
     invoice_type,
     invoice_issue_date,
     new_invoice_price_unit_id,
     invoice_ref_no)
  select   gmr.corporate_id,
  pc_process_id,
           iid.internal_gmr_ref_no,
           iid.internal_invoice_ref_no,
           sum(iid.invoice_item_amount),
           iid.invoice_currency_id,
           iss.invoice_type_name,
           iss.invoice_issue_date,
           iid.new_invoice_price_unit_id,
           iss.invoice_ref_no
      from iid_invoicable_item_details iid,
           is_invoice_summary          iss,
           gmr_goods_movement_record   gmr
     where iid.internal_invoice_ref_no = iss.internal_invoice_ref_no
       and iss.is_active = 'Y'
       and gmr.process_id = pc_process_id
       and gmr.process_id = iss.process_id
       and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
       and gmr.latest_internal_invoice_ref_no = iid.internal_invoice_ref_no
       group by gmr.corporate_id,
           iid.internal_gmr_ref_no,
           iss.invoice_ref_no,
           iid.internal_invoice_ref_no,
           iid.invoice_currency_id,
           iss.invoice_type_name,
           iss.invoice_issue_date,
           iid.new_invoice_price_unit_id;
commit;
gvn_log_counter := gvn_log_counter + 1;
 sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Invoice Amt Over For Normal GMRS');
                          
-- Update Invoice Currency 
for cur_inv_currency in(
select tgi.new_invoice_price_unit_id
from tgi_temp_gmr_invoice tgi
where tgi.corporate_id = pc_corporate_id
group by tgi.new_invoice_price_unit_id) loop

select cm.cur_id,
       cm.cur_code
  into vc_inv_cur_id,
       vc_inv_cur_code
  from cm_currency_master cm
 where cm.cur_id =
       (select ppu.cur_id
          from v_ppu_pum ppu
         where ppu.product_price_unit_id =
               cur_inv_currency.new_invoice_price_unit_id);
         
Update tgi_temp_gmr_invoice tgi
set tgi.invoice_cur_id =  vc_inv_cur_id,
tgi.invoice_cur_code = vc_inv_cur_code
where tgi.new_invoice_price_unit_id = cur_inv_currency.new_invoice_price_unit_id;
end loop;
commit;
                          
delete from tgc_temp_gmr_charges t
where t.corporate_id = pc_corporate_id;
commit;                          
--         
-- Update TC/RC/Penalty Charges         
--
insert into tgc_temp_gmr_charges
  (corporate_id,
   internal_gmr_ref_no,
   internal_invoice_ref_no,
   element_id,
   tc_amt,
   rc_amt,
   penalty_amt)
  select pc_corporate_id,
         t.internal_gmr_ref_no,
         t.internal_invoice_ref_no,
         t.element_id,
         nvl(sum(tc_amt),0) tc_amt,
         nvl(sum(rc_amt),0),
         nvl(sum(penalty_amt),0)
    from (
    select gmr.internal_gmr_ref_no,
       intc.internal_invoice_ref_no,
       intc.element_id,
       sum(tcharges_amount) tc_amt,
       0 rc_amt,
       0 penalty_amt
  from gmr_goods_movement_record  gmr,
       intc_inv_treatment_charges intc,
       grd_goods_record_detail    grd
 where gmr.process_id = pc_process_id
   and gmr.latest_internal_invoice_ref_no = intc.internal_invoice_ref_no
   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and grd.internal_grd_ref_no = intc.grd_id
   and grd.process_id = pc_process_id
 group by gmr.internal_gmr_ref_no,
          intc.internal_invoice_ref_no,
          intc.element_id
union all
select gmr.internal_gmr_ref_no,
       inrc.internal_invoice_ref_no,
       inrc.element_id,
       0 tc_amt,
       sum(rcharges_amount) rc_amt,
       0 penalty_amt
  from gmr_goods_movement_record gmr,
       inrc_inv_refining_charges inrc,
       grd_goods_record_detail   grd
 where gmr.process_id = pc_process_id
   and gmr.latest_internal_invoice_ref_no = inrc.internal_invoice_ref_no
   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and grd.internal_grd_ref_no = inrc.grd_id
   and grd.process_id = pc_process_id
 group by gmr.internal_gmr_ref_no,
          inrc.element_id,
          inrc.internal_invoice_ref_no
union all
select gmr.internal_gmr_ref_no,
       iepd.internal_invoice_ref_no,
       iepd.element_id,
       0 tc_amt,
       0 rc_amt,
       sum(iepd.element_penalty_amount) penalty_amt
  from gmr_goods_movement_record gmr,
       iepd_inv_epenalty_details iepd,
       grd_goods_record_detail   grd
 where gmr.process_id = pc_process_id
   and gmr.latest_internal_invoice_ref_no = iepd.internal_invoice_ref_no
   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and grd.internal_grd_ref_no = iepd.stock_id
   and grd.process_id = pc_process_id
 group by gmr.internal_gmr_ref_no,
          iepd.element_id,
          iepd.internal_invoice_ref_no) t
   group by t.internal_gmr_ref_no,
            t.internal_invoice_ref_no,
            t.element_id;
commit;
sp_gather_stats('tgi_temp_gmr_invoice');
sp_gather_stats('tgc_temp_gmr_charges');
sp_gather_stats('temp_gmr_invoice');
--
-- Update Provisional Payment % from IS directly
--
Update tgc_temp_gmr_charges t
set t.provisional_pymt_pctg =
(select nvl(is1.provisional_pymt_pctg,100) from is_invoice_summary is1
where is1.internal_invoice_ref_no = t.internal_invoice_ref_no
and is1.process_id = pc_process_id)
where t.corporate_id = pc_corporate_id;
gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter,
                          'Invoice TC/RC and Penalty Over');
commit;
sp_gather_stats('tgi_temp_gmr_invoice');
sp_gather_stats('tgc_temp_gmr_charges');
commit;
gvn_log_counter := gvn_log_counter + 1;
sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          gvn_log_counter ,
                          'Invoice Freight and Other Changes Over');

                          
end;

procedure sp_arrival_report(pc_corporate_id varchar2,
                            pd_trade_date   date,
                            pc_process_id   varchar2,
                            pc_process      varchar2) as

  cursor cur_arrival is
    select gmr_ref_no,
           internal_gmr_ref_no,
           internal_grd_ref_no,
           internal_stock_ref_no,
           corporate_id,
           warehouse_profile_id,
           warehouse_name,
           shed_id,
           storage_location_name,
           product_id,
           product_name,
           quality_id,
           quality_name,
           wet_qty,
           dry_qty,
           qty_unit_id,
           qty_unit,
           element_id,
           attribute_name,
           underlying_product_id,
           underlying_product_name,
           base_quantity_unit_id,
           base_quantity_unit,
           assay_content,
           assay_qty_unit_id,
           assay_qty_unit,
           payable_qty,
           payable_qty_unit_id,
           payable_qty_unit,
           arrival_status,
           conc_base_qty_unit_id,
           conc_base_qty_unit,
           grd_base_qty_conv_factor,
           pcdi_id,
           pay_cur_id,
           pay_cur_code,
           pay_cur_decimals,
           section_name,
           qty_type,
           dense_rank() over(partition by internal_grd_ref_no order by section_name, element_id) ele_rank, -- Let the Penalty element be at end,
           grd_to_gmr_qty_factor,
           gmr_wet_qty
      from (select gmr.gmr_ref_no,
                   gmr.internal_gmr_ref_no,
                   grd.internal_grd_ref_no,
                   grd.internal_stock_ref_no,
                   gmr.corporate_id,
                   gmr.warehouse_profile_id,
                   gmr.warehouse_name,
                   gmr.shed_id,
                   gmr.shed_name storage_location_name,
                   grd.product_id,
                   grd.product_name,
                   grd.quality_id,
                   grd.quality_name,
                   grd.qty wet_qty,
                   grd.dry_qty,
                   grd.qty_unit_id qty_unit_id,
                   grd.qty_unit qty_unit,
                   spq.element_id,
                   aml.attribute_name,
                   aml.underlying_product_id,
                   pdm_und.product_desc underlying_product_name,
                   pdm_und.base_quantity_unit base_quantity_unit_id,
                   qum_und.qty_unit base_quantity_unit,
                   spq.assay_content assay_content,
                   spq.qty_unit_id assay_qty_unit_id,
                   spq.qty_unit assay_qty_unit,
                   spq.payable_qty payable_qty,
                   spq.qty_unit_id payable_qty_unit_id,
                   spq.qty_unit payable_qty_unit,
                   gmr.gmr_arrival_status arrival_status,
                   grd.base_qty_unit_id conc_base_qty_unit_id,
                   grd.base_qty_unit conc_base_qty_unit,
                   nvl(grd.base_qty_conv_factor, 1) grd_base_qty_conv_factor,
                   grd.pcdi_id,
                   gmr.invoice_cur_id pay_cur_id,
                   gmr.invoice_cur_code pay_cur_code,
                   gmr.invoice_cur_decimals pay_cur_decimals,
                   'Non Penalty' section_name,
                   nvl(grd.grd_to_gmr_qty_factor, 1) grd_to_gmr_qty_factor,
                   spq.qty_type,
                   gmr.wet_qty gmr_wet_qty
              from gmr_goods_movement_record gmr,
                   grd_goods_record_detail   grd,
                   spq_stock_payable_qty     spq,
                   aml_attribute_master_list aml,
                   pdm_productmaster         pdm_und,
                   qum_quantity_unit_master  qum_und
             where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
               and grd.status = 'Active'
               and grd.tolling_stock_type = 'None Tolling'
               and gmr.is_internal_movement = 'N'
               and gmr.tolling_service_type = 'S'
               and grd.internal_grd_ref_no = spq.internal_grd_ref_no
               and gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
               and spq.is_stock_split = 'N'
               and spq.element_id = aml.attribute_id
               and aml.underlying_product_id = pdm_und.product_id
               and pdm_und.base_quantity_unit = qum_und.qty_unit_id
               and gmr.gmr_status in ('In Warehouse', 'Landed')
               and gmr.is_deleted = 'N'
               and gmr.process_id = pc_process_id
               and spq.process_id = pc_process_id
               and grd.process_id = pc_process_id
               and spq.is_active = 'Y'
            union all
            select gmr.gmr_ref_no,
                   gmr.internal_gmr_ref_no,
                   grd.internal_grd_ref_no,
                   grd.internal_stock_ref_no,
                   gmr.corporate_id,
                   gmr.warehouse_profile_id,
                   gmr.warehouse_name,
                   gmr.shed_id,
                   gmr.shed_name storage_location_name,
                   grd.product_id,
                   grd.product_name,
                   grd.quality_id,
                   grd.quality_name,
                   grd.qty wet_qty,
                   grd.dry_qty,
                   grd.qty_unit_id qty_unit_id,
                   grd.qty_unit qty_unit,
                   ped.element_id,
                   aml.attribute_name,
                   null underlying_product_id,
                   null underlying_product_name,
                   null base_quantity_unit_id,
                   null base_quantity_unit,
                   ped.assay_qty assay_content,
                   ped.assay_qty_unit_id assay_qty_unit_id,
                   qum_ped.qty_unit assay_qty_unit,
                   0 payable_qty,
                   ped.assay_qty_unit_id payable_qty_unit_id,
                   qum_ped.qty_unit payable_qty_unit,
                   gmr.gmr_arrival_status arrival_status,
                   grd.base_qty_unit_id conc_base_qty_unit_id,
                   grd.base_qty_unit conc_base_qty_unit,
                   nvl(grd.base_qty_conv_factor, 1) grd_base_qty_conv_factor,
                   grd.pcdi_id,
                   gmr.invoice_cur_id pay_cur_id,
                   gmr.invoice_cur_code pay_cur_code,
                   gmr.invoice_cur_decimals pay_cur_decimals,
                   'Penalty' section_name,
                   nvl(grd.grd_to_gmr_qty_factor, 1) grd_to_gmr_qty_factor,
                   'Penalty' qty_type,
                   gmr.wet_qty
              from gmr_goods_movement_record   gmr,
                   grd_goods_record_detail     grd,
                   ped_penalty_element_details ped,
                   aml_attribute_master_list   aml,
                   qum_quantity_unit_master    qum_ped
             where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
               and grd.status = 'Active'
               and grd.tolling_stock_type = 'None Tolling'
               and gmr.is_internal_movement = 'N'
               and gmr.tolling_service_type = 'S'
               and gmr.gmr_status in ('In Warehouse', 'Landed')
               and gmr.is_deleted = 'N'
               and gmr.process_id = pc_process_id
               and grd.process_id = pc_process_id
               and ped.process_id = pc_process_id
               and ped.internal_gmr_ref_no = grd.internal_gmr_ref_no
               and ped.internal_grd_ref_no = grd.internal_grd_ref_no
               and ped.element_id = aml.attribute_id
               and ped.assay_qty_unit_id = qum_ped.qty_unit_id);
  vobj_error_log                tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count            number := 1;
  vn_counter                    number := 1;
  vn_wet_qty                    number;
  vn_dry_qty                    number;
  vc_corporate_name             varchar2(100);
  vn_spq_qty_conv_factor        number;
  vn_assay_qty                  number;
  vn_payable_qty                number;
  vn_gmr_price                  number;
  vc_gmr_price_untit_id         varchar2(15);
  vc_price_unit_weight_unit_id  varchar2(15);
  vn_gmr_price_unit_weight      number;
  vc_gmr_price_unit_cur_id      varchar2(15);
  vc_gmr_price_unit_cur_code    varchar2(15);
  vn_payable_amt_in_price_cur   number;
  vn_payable_amt_in_pay_cur     number;
  vc_price_cur_id               varchar2(15);
  vc_price_cur_code             varchar2(15);
  vn_cont_price_cur_id_factor   number;
  vn_cont_price_cur_decimals    number;
  vn_fx_rate_price_to_pay       number;
  vn_payable_to_price_wt_factor number;
  vn_gmr_refine_charge          number;
  vn_gmr_penality_charge        number;
  vn_gmr_base_tc                number;
  vn_gmr_esc_descalator_tc      number;
  vc_previous_eom_id            varchar2(15);
  vc_previous_year_eom_id       varchar2(15);
  vd_acc_start_date             date;

begin

  select akc.corporate_name
    into vc_corporate_name
    from ak_corporate akc
   where akc.corporate_id = pc_corporate_id;
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
  --
  -- Previous EOM ID
  --
  begin
    select tdc.process_id
      into vc_previous_eom_id
      from tdc_trade_date_closure tdc
     where tdc.corporate_id = pc_corporate_id
       and tdc.process = pc_process
       and tdc.trade_date =
           (select max(tdc_in.trade_date)
              from tdc_trade_date_closure tdc_in
             where tdc_in.corporate_id = pc_corporate_id
               and tdc_in.process = pc_process
               and tdc_in.trade_date < pd_trade_date);
  exception
    when no_data_found then
      vc_previous_eom_id := null;
  end;
  --
  -- Previous Year EOM ID
  --
  begin
    select tdc.process_id
      into vc_previous_year_eom_id
      from tdc_trade_date_closure tdc
     where tdc.corporate_id = pc_corporate_id
       and tdc.process = pc_process
       and tdc.trade_date =
           (select max(tdc_in.trade_date)
              from tdc_trade_date_closure tdc_in
             where tdc_in.corporate_id = pc_corporate_id
               and tdc_in.process = pc_process
               and tdc_in.trade_date < vd_acc_start_date);
  exception
    when no_data_found then
      vc_previous_year_eom_id := null;
  end;
  for cur_arrival_rows in cur_arrival
  loop
    vn_counter := vn_counter + 1;
   if cur_arrival_rows.section_name = 'Non Penalty' then
    
    begin
      select ucm.multiplication_factor
        into vn_spq_qty_conv_factor
        from ucm_unit_conversion_master ucm
       where ucm.from_qty_unit_id = cur_arrival_rows.assay_qty_unit_id
         and ucm.to_qty_unit_id = cur_arrival_rows.base_quantity_unit_id;
    exception
      when others then
        vn_spq_qty_conv_factor := -1;
    end;
    end if;
    --
    -- Wet, Dry, Payable And Assay Quantities are stored in product Base Quantity Unit
    --
  
    vn_wet_qty   := cur_arrival_rows.wet_qty *
                    cur_arrival_rows.grd_base_qty_conv_factor;
    vn_dry_qty   := cur_arrival_rows.dry_qty *
                    cur_arrival_rows.grd_base_qty_conv_factor;
    
    if cur_arrival_rows.section_name = 'Non Penalty' then
      vn_payable_qty := cur_arrival_rows.payable_qty *
                        vn_spq_qty_conv_factor;
                        vn_assay_qty := cur_arrival_rows.assay_content * vn_spq_qty_conv_factor;                        
    else
      vn_payable_qty := 0;
      vn_assay_qty :=0;-- We do not show this for penalty elements
    end if;
  
    if cur_arrival_rows.ele_rank = 1 then
      insert into aro_ar_original
        (process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         stock_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         arrival_status,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         grd_wet_qty,
         grd_dry_qty,
         grd_qty_unit_id,
         grd_qty_unit,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         other_charges_amt,
         pay_cur_id,
         pay_cur_code,
         pay_cur_decimal,
         grd_to_gmr_qty_factor,
         gmr_qty)
      values
        (pc_process_id,
         pd_trade_date,
         cur_arrival_rows.corporate_id,
         vc_corporate_name,
         cur_arrival_rows.gmr_ref_no,
         cur_arrival_rows.internal_gmr_ref_no,
         cur_arrival_rows.internal_grd_ref_no,
         cur_arrival_rows.internal_stock_ref_no,
         cur_arrival_rows.product_id,
         cur_arrival_rows.product_name,
         cur_arrival_rows.quality_id,
         cur_arrival_rows.quality_name,
         cur_arrival_rows.arrival_status,
         cur_arrival_rows.warehouse_profile_id,
         cur_arrival_rows.warehouse_name,
         cur_arrival_rows.shed_id,
         cur_arrival_rows.storage_location_name,
         vn_wet_qty,
         vn_dry_qty,
         cur_arrival_rows.qty_unit_id,
         cur_arrival_rows.qty_unit,
         cur_arrival_rows.conc_base_qty_unit_id,
         cur_arrival_rows.conc_base_qty_unit,
         0, --other_charges_amt,
         cur_arrival_rows.pay_cur_id,
         cur_arrival_rows.pay_cur_code,
         cur_arrival_rows.pay_cur_decimals,
         cur_arrival_rows.grd_to_gmr_qty_factor,
         cur_arrival_rows.gmr_wet_qty);
    
    end if;
    --
    -- Get the Price for the GMR and Element
    --
    if cur_arrival_rows.section_name = 'Non Penalty' and
       cur_arrival_rows.payable_qty <> 0 then
      begin
        select cgcp.contract_price,
               cgcp.price_unit_id,
               cgcp.price_unit_weight_unit_id,
               cgcp.price_unit_cur_id,
               cgcp.price_unit_cur_code,
               cgcp.price_unit_weight
          into vn_gmr_price,
               vc_gmr_price_untit_id,
               vc_price_unit_weight_unit_id,
               vc_gmr_price_unit_cur_id,
               vc_gmr_price_unit_cur_code,
               vn_gmr_price_unit_weight
          from cgcp_conc_gmr_cog_price cgcp
         where cgcp.internal_gmr_ref_no =
               cur_arrival_rows.internal_gmr_ref_no
           and cgcp.process_id = pc_process_id
           and cgcp.element_id = cur_arrival_rows.element_id;
      exception
        when others then
          begin
            select cccp.contract_price,
                   cccp.price_unit_id,
                   cccp.price_unit_weight_unit_id,
                   cccp.price_unit_cur_id,
                   cccp.price_unit_cur_code,
                   cccp.price_unit_weight
              into vn_gmr_price,
                   vc_gmr_price_untit_id,
                   vc_price_unit_weight_unit_id,
                   vc_gmr_price_unit_cur_id,
                   vc_gmr_price_unit_cur_code,
                   vn_gmr_price_unit_weight
              from cccp_conc_contract_cog_price cccp
             where cccp.pcdi_id = cur_arrival_rows.pcdi_id
               and cccp.process_id = pc_process_id
               and cccp.element_id = cur_arrival_rows.element_id;
          exception
            when others then
              vn_gmr_price                 := null;
              vc_gmr_price_untit_id        := null;
              vc_price_unit_weight_unit_id := null;
              vc_gmr_price_unit_cur_id     := null;
              vc_gmr_price_unit_cur_code   := null;
          end;
        
      end;
    
      pkg_general.sp_get_main_cur_detail(vc_gmr_price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
      --
      -- Quantity Conversion between Payable to Price Units
      --
      if cur_arrival_rows.payable_qty_unit_id <>
         vc_price_unit_weight_unit_id then
        begin
          select ucm.multiplication_factor
            into vn_payable_to_price_wt_factor
            from ucm_unit_conversion_master ucm
           where ucm.from_qty_unit_id =
                 cur_arrival_rows.payable_qty_unit_id
             and ucm.to_qty_unit_id = vc_price_unit_weight_unit_id;
        exception
          when others then
            vn_payable_to_price_wt_factor := -1;
        end;
      else
        vn_payable_to_price_wt_factor := 1;
      end if;
      begin
        select cet.exch_rate
          into vn_fx_rate_price_to_pay
          from cet_corporate_exch_rate cet
         where cet.corporate_id = pc_corporate_id
           and cet.from_cur_id = vc_gmr_price_unit_cur_id
           and cet.to_cur_id = cur_arrival_rows.pay_cur_id;
      exception
        when no_data_found then
          vn_fx_rate_price_to_pay := -1;
      end;
      --
      -- Calculate TC Charges, Use Dry or Wet Quantity As Configured in the Contract
      --    
      begin
        select round((case
                       when getc.weight_type = 'Dry' then
                        cur_arrival_rows.dry_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                       else
                        cur_arrival_rows.wet_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                     end),
                     cur_arrival_rows.pay_cur_decimals),
               round((case
                       when getc.weight_type = 'Dry' then
                        cur_arrival_rows.dry_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                       else
                        cur_arrival_rows.wet_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                     end),
                     cur_arrival_rows.pay_cur_decimals)
          into vn_gmr_base_tc,
               vn_gmr_esc_descalator_tc
          from getc_gmr_element_tc_charges getc,
               ucm_unit_conversion_master  ucm
         where getc.process_id = pc_process_id
           and getc.internal_gmr_ref_no =
               cur_arrival_rows.internal_gmr_ref_no
           and getc.internal_grd_ref_no =
               cur_arrival_rows.internal_grd_ref_no
           and getc.element_id = cur_arrival_rows.element_id
           and ucm.from_qty_unit_id = cur_arrival_rows.qty_unit_id
           and ucm.to_qty_unit_id = getc.tc_weight_unit_id;
      exception
        when others then
          vn_gmr_base_tc           := 0;
          vn_gmr_esc_descalator_tc := 0;
      end;
    else
      vn_gmr_price                  := null;
      vc_gmr_price_untit_id         := null;
      vc_price_unit_weight_unit_id  := null;
      vc_gmr_price_unit_cur_id      := null;
      vc_gmr_price_unit_cur_code    := null;
      vn_payable_to_price_wt_factor := null;
      vn_gmr_base_tc                := 0;
      vn_gmr_esc_descalator_tc      := 0;
      vn_fx_rate_price_to_pay       := null;
    end if;
   --
   -- If TC is assay based and payable qty is zero, we still need to calcualte TC
   -- 
     if cur_arrival_rows.section_name = 'Non Penalty' and
       cur_arrival_rows.payable_qty = 0 then
       begin
        select round((case
                       when getc.weight_type = 'Dry' then
                        cur_arrival_rows.dry_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                       else
                        cur_arrival_rows.wet_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                     end),
                     cur_arrival_rows.pay_cur_decimals),
               round((case
                       when getc.weight_type = 'Dry' then
                        cur_arrival_rows.dry_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                       else
                        cur_arrival_rows.wet_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                     end),
                     cur_arrival_rows.pay_cur_decimals)
          into vn_gmr_base_tc,
               vn_gmr_esc_descalator_tc
          from getc_gmr_element_tc_charges getc,
               ucm_unit_conversion_master  ucm
         where getc.process_id = pc_process_id
           and getc.internal_gmr_ref_no =
               cur_arrival_rows.internal_gmr_ref_no
           and getc.internal_grd_ref_no =
               cur_arrival_rows.internal_grd_ref_no
           and getc.element_id = cur_arrival_rows.element_id
           and ucm.from_qty_unit_id = cur_arrival_rows.qty_unit_id
           and ucm.to_qty_unit_id = getc.tc_weight_unit_id;
      exception
        when others then
          vn_gmr_base_tc           := 0;
          vn_gmr_esc_descalator_tc := 0;
      end;
       end if;
    --
    -- Calculate Penalty Charges, Use Dry or Wet Quantity As Configured in the Contract
    --    
    if cur_arrival_rows.section_name = 'Penalty' then
      begin
        select round((case
                       when gepc.weight_type = 'Dry' then
                        cur_arrival_rows.dry_qty * ucm.multiplication_factor *
                        gepc.pc_value
                       else
                        cur_arrival_rows.wet_qty * ucm.multiplication_factor *
                        gepc.pc_value
                     end),
                     cur_arrival_rows.pay_cur_decimals)
          into vn_gmr_penality_charge
          from gepc_gmr_element_pc_charges gepc,
               ucm_unit_conversion_master  ucm
         where gepc.process_id = pc_process_id
           and gepc.internal_gmr_ref_no =
               cur_arrival_rows.internal_gmr_ref_no
           and gepc.internal_grd_ref_no =
               cur_arrival_rows.internal_grd_ref_no
           and gepc.element_id = cur_arrival_rows.element_id
           and ucm.from_qty_unit_id = cur_arrival_rows.qty_unit_id
           and ucm.to_qty_unit_id = gepc.pc_weight_unit_id;
      exception
        when others then
          vn_gmr_penality_charge := 0;
      end;
    else
      vn_gmr_penality_charge := 0;
    end if;
    --
    -- Calcualte Payable Amount and RC Charges
    --
    if cur_arrival_rows.section_name = 'Non Penalty' and
       cur_arrival_rows.payable_qty <> 0 then
      vn_payable_amt_in_price_cur := round((vn_gmr_price /
                                           nvl(vn_gmr_price_unit_weight, 1)) *
                                           (vn_payable_to_price_wt_factor *
                                           cur_arrival_rows.payable_qty) *
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
      vn_payable_amt_in_pay_cur   := round(vn_payable_amt_in_price_cur *
                                           vn_fx_rate_price_to_pay,
                                           cur_arrival_rows.pay_cur_decimals);
      --
      -- Calculate RC Charges
      --    
    
      begin
        select round(gerc.rc_value * ucm.multiplication_factor *
                     cur_arrival_rows.payable_qty,
                     cur_arrival_rows.pay_cur_decimals)
          into vn_gmr_refine_charge
          from gerc_gmr_element_rc_charges gerc,
               ucm_unit_conversion_master  ucm
         where gerc.process_id = pc_process_id
           and gerc.internal_gmr_ref_no =
               cur_arrival_rows.internal_gmr_ref_no
           and gerc.internal_grd_ref_no =
               cur_arrival_rows.internal_grd_ref_no
           and gerc.element_id = cur_arrival_rows.element_id
           and ucm.from_qty_unit_id = cur_arrival_rows.payable_qty_unit_id
           and ucm.to_qty_unit_id = gerc.rc_weight_unit_id;
      exception
        when others then
          vn_gmr_refine_charge := 0;
      end;
    else
      vn_payable_amt_in_price_cur := 0;
      vn_payable_amt_in_pay_cur   := 0;
      vn_gmr_refine_charge        := 0;
      vn_fx_rate_price_to_pay     := null;
    end if;
    insert into areo_ar_element_original
      (process_id,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       element_id,
       element_name,
       assay_qty,
       asaay_qty_unit_id,
       asaay_qty_unit,
       payable_qty,
       payable_qty_unit_id,
       payable_qty_unit,
       price,
       price_unit_id,
       payable_amt_price_ccy,
       payable_amt_pay_ccy,
       fx_rate_price_to_pay,
       base_tc_charges_amt,
       esc_desc_tc_charges_amt,
       rc_charges_amt,
       pc_charges_amt,
       section_name,
       qty_type,
       element_base_qty_unit_id,
       element_base_qty_unit
       )
    values
      (pc_process_id,
       cur_arrival_rows.internal_gmr_ref_no,
       cur_arrival_rows.internal_grd_ref_no,
       cur_arrival_rows.element_id,
       cur_arrival_rows.attribute_name,
       vn_assay_qty,
       cur_arrival_rows.base_quantity_unit_id,
       cur_arrival_rows.base_quantity_unit,
       vn_payable_qty,
       cur_arrival_rows.base_quantity_unit_id,
       cur_arrival_rows.base_quantity_unit,
       vn_gmr_price,
       vc_gmr_price_untit_id,
       vn_payable_amt_in_price_cur,
       vn_payable_amt_in_pay_cur,
       vn_fx_rate_price_to_pay,
       vn_gmr_base_tc,
       vn_gmr_esc_descalator_tc,
       vn_gmr_refine_charge,
       vn_gmr_penality_charge,
       cur_arrival_rows.section_name,
       cur_arrival_rows.qty_type,
       cur_arrival_rows.base_quantity_unit_id,
       cur_arrival_rows.base_quantity_unit);
  
    if vn_counter = 100 then
      commit;
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'Arrival Assay change Insert',
                   'finished inserting 100');
      vn_counter := 0;
    end if;
  end loop;
  commit;
  gvn_log_counter := gvn_log_counter + 1; 
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Arrival report main insert over');
  --  
  -- Update Other Charges
  --

  for cur_oc in (select gfoc.internal_gmr_ref_no,
                        gfoc.small_lot_charge + gfoc.container_charge +
                        gfoc.sampling_charge + gfoc.handling_charge +
                        gfoc.location_value + gfoc.freight_allowance as other_charges
                   from gfoc_gmr_freight_other_charge gfoc
                  where gfoc.process_id = pc_process_id)
  loop
  
    update aro_ar_original aro
       set aro.other_charges_amt = round((cur_oc.other_charges *
                                         aro.grd_wet_qty / aro.gmr_qty),
                                         aro.pay_cur_decimal)
     where aro.process_id = pc_process_id
       and aro.internal_gmr_ref_no = cur_oc.internal_gmr_ref_no;
  end loop;
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Arrival report Other Charge Updation Over');
  --
  -- Populate MTD New Data
  --
  insert into ar_arrival_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     gmr_ref_no,
     internal_gmr_ref_no,
     internal_grd_ref_no,
     stock_ref_no,
     product_id,
     product_name,
     quality_id,
     quality_name,
     arrival_status,
     warehouse_id,
     warehouse_name,
     shed_id,
     shed_name,
     grd_wet_qty,
     grd_dry_qty,
     grd_qty_unit_id,
     grd_qty_unit,
     conc_base_qty_unit_id,
     conc_base_qty_unit,
     is_new,
     mtd_ytd,
     other_charges_amt,
     pay_cur_id,
     pay_cur_code,
     pay_cur_decimal,
     grd_to_gmr_qty_factor,
     gmr_qty)
    select pc_process_id,
           pd_trade_date,
           corporate_id,
           corporate_name,
           gmr_ref_no,
           internal_gmr_ref_no,
           internal_grd_ref_no,
           stock_ref_no,
           product_id,
           product_name,
           quality_id,
           quality_name,
           arrival_status,
           warehouse_id,
           warehouse_name,
           shed_id,
           shed_name,
           grd_wet_qty,
           grd_dry_qty,
           grd_qty_unit_id,
           grd_qty_unit,
           conc_base_qty_unit_id,
           conc_base_qty_unit,
           'Y', -- is_new,
           'MTD', -- mtd_ytd,
           other_charges_amt,
           pay_cur_id,
           pay_cur_code,
           pay_cur_decimal,
           grd_to_gmr_qty_factor,
           gmr_qty
      from aro_ar_original aro
     where aro.process_id = pc_process_id
       and exists
     (select *
              from gmr_goods_movement_record gmr
             where gmr.process_id = pc_process_id
               and gmr.internal_gmr_ref_no = aro.internal_gmr_ref_no
               and gmr.is_new_mtd = 'Y'
               and 'TRUE' =
                   (case when
                    trunc(gmr.eff_date, 'Mon') <= trunc(pd_trade_date, 'Mon') then
                    'TRUE' when trunc(gmr.loading_date, 'Mon') <=
                    trunc(pd_trade_date, 'Mon') and
                    gmr.loading_date is not null then 'TRUE' else 'FALSE' end));
  commit;
  insert into are_arrival_report_element
    (process_id,
     internal_gmr_ref_no,
     internal_grd_ref_no,
     element_id,
     element_name,
     assay_qty,
     asaay_qty_unit_id,
     asaay_qty_unit,
     payable_qty,
     payable_qty_unit_id,
     payable_qty_unit,
     mtd_ytd,
     section_name,
     qty_type,
     price,
     price_unit_id,
     payable_amt_price_ccy,
     payable_amt_pay_ccy,
     fx_rate_price_to_pay,
     base_tc_charges_amt,
     esc_desc_tc_charges_amt,
     rc_charges_amt,
     pc_charges_amt,
     element_base_qty_unit_id,
     element_base_qty_unit)
    select pc_process_id,
           internal_gmr_ref_no,
           internal_grd_ref_no,
           element_id,
           element_name,
           assay_qty,
           asaay_qty_unit_id,
           asaay_qty_unit,
           payable_qty,
           payable_qty_unit_id,
           payable_qty_unit,
           'MTD', --mtd_ytd,
           section_name,
           qty_type,
           price,
           price_unit_id,
           payable_amt_price_ccy,
           payable_amt_pay_ccy,
           fx_rate_price_to_pay,
           base_tc_charges_amt,
           esc_desc_tc_charges_amt,
           rc_charges_amt,
           pc_charges_amt,
           element_base_qty_unit_id,
           element_base_qty_unit
      from areo_ar_element_original areo
     where areo.process_id = pc_process_id
       and exists
     (select *
              from gmr_goods_movement_record gmr
             where gmr.process_id = pc_process_id
               and gmr.internal_gmr_ref_no = areo.internal_gmr_ref_no
               and gmr.is_new_mtd = 'Y'
               and 'TRUE' =
                   (case when
                    trunc(gmr.eff_date, 'Mon') <= trunc(pd_trade_date, 'Mon') then
                    'TRUE' when trunc(gmr.loading_date, 'Mon') <=
                    trunc(pd_trade_date, 'Mon') and
                    gmr.loading_date is not null then 'TRUE' else 'FALSE' end));
gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Populate MTD New Data Over');
  --
  -- Populate MTD Delta Data
  --
insert into ar_arrival_report
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   gmr_ref_no,
   internal_gmr_ref_no,
   internal_grd_ref_no,
   stock_ref_no,
   product_id,
   product_name,
   quality_id,
   quality_name,
   arrival_status,
   warehouse_id,
   warehouse_name,
   shed_id,
   shed_name,
   grd_wet_qty,
   grd_dry_qty,
   grd_qty_unit_id,
   grd_qty_unit,
   conc_base_qty_unit_id,
   conc_base_qty_unit,
   is_new,
   mtd_ytd,
   other_charges_amt,
   pay_cur_id,
   pay_cur_code,
   pay_cur_decimal,
   grd_to_gmr_qty_factor,
   gmr_qty)
  select pc_process_id,
         pd_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         stock_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         max(arrival_status),
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         sum(grd_wet_qty),
         sum(grd_dry_qty),
         grd_qty_unit_id,
         grd_qty_unit,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         is_new,
         mtd_ytd,
         sum(other_charges_amt),
         pay_cur_id,
         pay_cur_code,
         pay_cur_decimal,
         grd_to_gmr_qty_factor,
         sum(gmr_qty)
    from (select aro_current.corporate_id,
                 aro_current.corporate_name,
                 aro_current.gmr_ref_no,
                 aro_current.internal_gmr_ref_no,
                 null internal_grd_ref_no,
                 null stock_ref_no,
                 aro_current.product_id,
                 aro_current.product_name,
                 aro_current.quality_id,
                 aro_current.quality_name,
                 aro_current.arrival_status,
                 aro_current.warehouse_id,
                 aro_current.warehouse_name,
                 aro_current.shed_id,
                 aro_current.shed_name,
                 sum(aro_current.grd_wet_qty) grd_wet_qty,
                 sum(aro_current.grd_dry_qty) grd_dry_qty,
                 null grd_qty_unit_id,
                 null grd_qty_unit,
                 aro_current.conc_base_qty_unit_id,
                 aro_current.conc_base_qty_unit,
                 'N' is_new, -- is_new,
                 'MTD' mtd_ytd, -- mtd_ytd,
                 sum(aro_current.other_charges_amt) other_charges_amt,
                 aro_current.pay_cur_id,
                 aro_current.pay_cur_code,
                 aro_current.pay_cur_decimal,
                 null grd_to_gmr_qty_factor,
                 aro_current.gmr_qty
            from aro_ar_original aro_current
           where aro_current.process_id = pc_process_id
             and exists (select *
                    from gmr_goods_movement_record gmr
                   where gmr.process_id = pc_process_id
                     and gmr.internal_gmr_ref_no =
                         aro_current.internal_gmr_ref_no
                     and gmr.is_assay_updated_mtd = 'Y')
           group by aro_current.corporate_id,
                    aro_current.corporate_name,
                    aro_current.gmr_ref_no,
                    aro_current.internal_gmr_ref_no,
                    aro_current.product_id,
                    aro_current.product_name,
                    aro_current.quality_id,
                    aro_current.quality_name,
                    aro_current.arrival_status,
                    aro_current.warehouse_id,
                    aro_current.warehouse_name,
                    aro_current.shed_id,
                    aro_current.shed_name,
                    aro_current.conc_base_qty_unit_id,
                    aro_current.conc_base_qty_unit,
                    aro_current.pay_cur_id,
                    aro_current.pay_cur_code,
                    aro_current.pay_cur_decimal,
                    aro_current.gmr_qty
          union all
          select are_prev.corporate_id,
                 are_prev.corporate_name,
                 are_prev.gmr_ref_no,
                 are_prev.internal_gmr_ref_no,
                 null internal_grd_ref_no,
                 null stock_ref_no,
                 are_prev.product_id,
                 are_prev.product_name,
                 are_prev.quality_id,
                 are_prev.quality_name,
                 null arrival_status,
                 are_prev.warehouse_id,
                 are_prev.warehouse_name,
                 are_prev.shed_id,
                 are_prev.shed_name,
                 -1 * sum(are_prev.grd_wet_qty),
                 -1 * sum(are_prev.grd_dry_qty),
                 null grd_qty_unit_id,
                 null grd_qty_unit,
                 are_prev.conc_base_qty_unit_id,
                 are_prev.conc_base_qty_unit,
                 'N', -- is_new,
                 'MTD', -- mtd_ytd,
                 -1 * sum(are_prev.other_charges_amt),
                 are_prev.pay_cur_id,
                 are_prev.pay_cur_code,
                 are_prev.pay_cur_decimal,
                 null grd_to_gmr_qty_factor,
                 0 gmr_qty
            from aro_ar_original are_prev
           where are_prev.process_id = vc_previous_eom_id
             and exists (select *
                    from gmr_goods_movement_record gmr
                   where gmr.process_id = pc_process_id
                     and gmr.internal_gmr_ref_no =
                         are_prev.internal_gmr_ref_no
                     and gmr.is_assay_updated_mtd = 'Y')
           group by are_prev.corporate_id,
                    are_prev.corporate_name,
                    are_prev.gmr_ref_no,
                    are_prev.internal_gmr_ref_no,
                    are_prev.product_id,
                    are_prev.product_name,
                    are_prev.quality_id,
                    are_prev.quality_name,
                    are_prev.warehouse_id,
                    are_prev.warehouse_name,
                    are_prev.shed_id,
                    are_prev.shed_name,
                    are_prev.conc_base_qty_unit_id,
                    are_prev.conc_base_qty_unit,
                    are_prev.pay_cur_id,
                    are_prev.pay_cur_code,
                    are_prev.pay_cur_decimal,
                    are_prev.gmr_qty)
   group by corporate_id,
            corporate_name,
            gmr_ref_no,
            internal_gmr_ref_no,
            internal_grd_ref_no,
            stock_ref_no,
            product_id,
            product_name,
            quality_id,
            quality_name,
            warehouse_id,
            warehouse_name,
            shed_id,
            shed_name,
            grd_qty_unit_id,
            grd_qty_unit,
            conc_base_qty_unit_id,
            conc_base_qty_unit,
            is_new,
            mtd_ytd,
            pay_cur_id,
            pay_cur_code,
            pay_cur_decimal,
            grd_to_gmr_qty_factor;
  commit;
  
insert into are_arrival_report_element
  (process_id,
   internal_gmr_ref_no,
   internal_grd_ref_no,
   element_id,
   element_name,
   assay_qty,
   asaay_qty_unit_id,
   asaay_qty_unit,
   payable_qty,
   payable_qty_unit_id,
   payable_qty_unit,
   mtd_ytd,
   section_name,
   qty_type,
   price,
   price_unit_id,
   payable_amt_price_ccy,
   payable_amt_pay_ccy,
   fx_rate_price_to_pay,
   base_tc_charges_amt,
   esc_desc_tc_charges_amt,
   rc_charges_amt,
   pc_charges_amt,
   element_base_qty_unit_id,
   element_base_qty_unit)
  select pc_process_id,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         element_id,
         element_name,
         sum(assay_qty),
         asaay_qty_unit_id,
         asaay_qty_unit,
         sum(payable_qty),
         payable_qty_unit_id,
         payable_qty_unit,
         mtd_ytd,
         section_name,
         qty_type,
         price,
         price_unit_id,
         sum(payable_amt_price_ccy),
         sum(payable_amt_pay_ccy),
         fx_rate_price_to_pay,
         sum(base_tc_charges_amt),
         sum(esc_desc_tc_charges_amt),
         sum(rc_charges_amt),
         sum(pc_charges_amt),
         element_base_qty_unit_id,
         element_base_qty_unit
    from (select areo_current.internal_gmr_ref_no,
                 null internal_grd_ref_no,
                 areo_current.element_id,
                 areo_current.element_name,
                 sum(areo_current.assay_qty) assay_qty,
                 areo_current.asaay_qty_unit_id,
                 areo_current.asaay_qty_unit,
                 sum(areo_current.payable_qty) payable_qty,
                 areo_current.payable_qty_unit_id,
                 areo_current.payable_qty_unit,
                 'MTD' mtd_ytd, -- mtd_ytd,
                 areo_current.section_name,
                 areo_current.qty_type,
                 null price,
                 null price_unit_id,
                 sum(areo_current.payable_amt_price_ccy) payable_amt_price_ccy,
                 sum(areo_current.payable_amt_pay_ccy) payable_amt_pay_ccy,
                 null fx_rate_price_to_pay,
                 sum(areo_current.base_tc_charges_amt) base_tc_charges_amt,
                 sum(areo_current.esc_desc_tc_charges_amt) esc_desc_tc_charges_amt,
                 sum(areo_current.rc_charges_amt) rc_charges_amt,
                 sum(areo_current.pc_charges_amt) pc_charges_amt,
                 areo_current.element_base_qty_unit_id,
                 areo_current.element_base_qty_unit
            from areo_ar_element_original areo_current
           where areo_current.process_id = pc_process_id
             and exists (select *
                    from gmr_goods_movement_record gmr
                   where gmr.process_id = pc_process_id
                     and gmr.internal_gmr_ref_no =
                         areo_current.internal_gmr_ref_no
                     and gmr.is_assay_updated_mtd = 'Y')
           group by areo_current.internal_gmr_ref_no,
                    areo_current.element_id,
                    areo_current.element_name,
                    areo_current.asaay_qty_unit_id,
                    areo_current.asaay_qty_unit,
                    areo_current.payable_qty_unit_id,
                    areo_current.payable_qty_unit,
                    areo_current.section_name,
                    areo_current.qty_type,
                    areo_current.element_base_qty_unit_id,
                    areo_current.element_base_qty_unit
          union all
          select areo_prev.internal_gmr_ref_no,
                 null internal_grd_ref_no,
                 areo_prev.element_id,
                 areo_prev.element_name,
                 -1 * sum(areo_prev.assay_qty) assay_qty,
                 areo_prev.asaay_qty_unit_id,
                 areo_prev.asaay_qty_unit,
                 -1 * sum(areo_prev.payable_qty) payable_qty,
                 areo_prev.payable_qty_unit_id,
                 areo_prev.payable_qty_unit,
                 'MTD' mtd_ytd, -- mtd_ytd,
                 areo_prev.section_name,
                 areo_prev.qty_type,
                 null price,
                 null price_unit_id,
                 -1 * sum(areo_prev.payable_amt_price_ccy) payable_amt_price_ccy,
                 -1 * sum(areo_prev.payable_amt_pay_ccy) payable_amt_pay_ccy,
                 null fx_rate_price_to_pay,
                 -1 * sum(areo_prev.base_tc_charges_amt) base_tc_charges_amt,
                 -1 * sum(areo_prev.esc_desc_tc_charges_amt) esc_desc_tc_charges_amt,
                 -1 * sum(areo_prev.rc_charges_amt) rc_charges_amt,
                 -1 * sum(areo_prev.pc_charges_amt) pc_charges_amt,
                 areo_prev.element_base_qty_unit_id,
                 areo_prev.element_base_qty_unit
            from areo_ar_element_original areo_prev
           where areo_prev.process_id = vc_previous_eom_id
             and exists (select *
                    from gmr_goods_movement_record gmr
                   where gmr.process_id = pc_process_id
                     and gmr.internal_gmr_ref_no =
                         areo_prev.internal_gmr_ref_no
                     and gmr.is_assay_updated_mtd = 'Y')
           group by areo_prev.internal_gmr_ref_no,
                    areo_prev.element_id,
                    areo_prev.element_name,
                    areo_prev.asaay_qty_unit_id,
                    areo_prev.asaay_qty_unit,
                    areo_prev.payable_qty_unit_id,
                    areo_prev.payable_qty_unit,
                    areo_prev.section_name,
                    areo_prev.qty_type,
                    areo_prev.element_base_qty_unit_id,
                    areo_prev.element_base_qty_unit)
   group by internal_gmr_ref_no,
            internal_grd_ref_no,
            element_id,
            element_name,
            asaay_qty_unit_id,
            asaay_qty_unit,
            payable_qty_unit_id,
            payable_qty_unit,
            mtd_ytd,
            section_name,
            qty_type,
            price,
            price_unit_id,
            fx_rate_price_to_pay,
            element_base_qty_unit_id,
            element_base_qty_unit;
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Populate MTD Delta Data Over');

  --
  -- Populate YTD New Data
  --               
  insert into ar_arrival_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     gmr_ref_no,
     internal_gmr_ref_no,
     internal_grd_ref_no,
     stock_ref_no,
     product_id,
     product_name,
     quality_id,
     quality_name,
     arrival_status,
     warehouse_id,
     warehouse_name,
     shed_id,
     shed_name,
     grd_wet_qty,
     grd_dry_qty,
     grd_qty_unit_id,
     grd_qty_unit,
     conc_base_qty_unit_id,
     conc_base_qty_unit,
     is_new,
     mtd_ytd,
     other_charges_amt,
     pay_cur_id,
     pay_cur_code,
     pay_cur_decimal,
     grd_to_gmr_qty_factor,
     gmr_qty)
    select pc_process_id,
           pd_trade_date,
           corporate_id,
           corporate_name,
           gmr_ref_no,
           internal_gmr_ref_no,
           internal_grd_ref_no,
           stock_ref_no,
           product_id,
           product_name,
           quality_id,
           quality_name,
           arrival_status,
           warehouse_id,
           warehouse_name,
           shed_id,
           shed_name,
           grd_wet_qty,
           grd_dry_qty,
           grd_qty_unit_id,
           grd_qty_unit,
           conc_base_qty_unit_id,
           conc_base_qty_unit,
           'Y', -- is_new,
           'YTD', -- mtd_ytd,
           other_charges_amt,
           pay_cur_id,
           pay_cur_code,
           pay_cur_decimal,
           grd_to_gmr_qty_factor,
           gmr_qty
      from aro_ar_original aro
     where aro.process_id = pc_process_id
       and exists
     (select *
              from gmr_goods_movement_record gmr
             where gmr.process_id = pc_process_id
               and gmr.internal_gmr_ref_no = aro.internal_gmr_ref_no
               and gmr.is_new_ytd = 'Y'
               and 'TRUE' =
                   (case when trunc(gmr.eff_date, 'YYYY') <=
                    trunc(pd_trade_date, 'YYYY') then 'TRUE' when
                    trunc(gmr.loading_date, 'YYYY') <=
                    trunc(pd_trade_date, 'YYYY') and
                    gmr.loading_date is not null then 'TRUE' else 'FALSE' end));
  commit;
  insert into are_arrival_report_element
    (process_id,
     internal_gmr_ref_no,
     internal_grd_ref_no,
     element_id,
     element_name,
     assay_qty,
     asaay_qty_unit_id,
     asaay_qty_unit,
     payable_qty,
     payable_qty_unit_id,
     payable_qty_unit,
     mtd_ytd,
     section_name,
     qty_type,
     price,
     price_unit_id,
     payable_amt_price_ccy,
     payable_amt_pay_ccy,
     fx_rate_price_to_pay,
     base_tc_charges_amt,
     esc_desc_tc_charges_amt,
     rc_charges_amt,
     pc_charges_amt,
     element_base_qty_unit_id,
     element_base_qty_unit)
    select pc_process_id,
           internal_gmr_ref_no,
           internal_grd_ref_no,
           element_id,
           element_name,
           assay_qty,
           asaay_qty_unit_id,
           asaay_qty_unit,
           payable_qty,
           payable_qty_unit_id,
           payable_qty_unit,
           'YTD', --mtd_ytd,
           section_name,
           qty_type,
           price,
           price_unit_id,
           payable_amt_price_ccy,
           payable_amt_pay_ccy,
           fx_rate_price_to_pay,
           base_tc_charges_amt,
           esc_desc_tc_charges_amt,
           rc_charges_amt,
           pc_charges_amt,
           element_base_qty_unit_id,
           element_base_qty_unit
      from areo_ar_element_original areo
     where areo.process_id = pc_process_id
       and exists
     (select *
              from gmr_goods_movement_record gmr
             where gmr.process_id = pc_process_id
               and gmr.internal_gmr_ref_no = areo.internal_gmr_ref_no
               and gmr.is_new_ytd = 'Y'
               and 'TRUE' =
                   (case when trunc(gmr.eff_date, 'yyyy') <=
                    trunc(pd_trade_date, 'yyyy') then 'TRUE' when
                    trunc(gmr.loading_date, 'yyyy') <=
                    trunc(pd_trade_date, 'yyyy') and
                    gmr.loading_date is not null then 'TRUE' else 'FALSE' end));
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Populate YTD New Data Over');
  --
  -- Populate YTD Delta Data
  --
  insert into ar_arrival_report
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   gmr_ref_no,
   internal_gmr_ref_no,
   internal_grd_ref_no,
   stock_ref_no,
   product_id,
   product_name,
   quality_id,
   quality_name,
   arrival_status,
   warehouse_id,
   warehouse_name,
   shed_id,
   shed_name,
   grd_wet_qty,
   grd_dry_qty,
   grd_qty_unit_id,
   grd_qty_unit,
   conc_base_qty_unit_id,
   conc_base_qty_unit,
   is_new,
   mtd_ytd,
   other_charges_amt,
   pay_cur_id,
   pay_cur_code,
   pay_cur_decimal,
   grd_to_gmr_qty_factor,
   gmr_qty)
  select pc_process_id,
         pd_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         stock_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         max(arrival_status),
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         sum(grd_wet_qty),
         sum(grd_dry_qty),
         grd_qty_unit_id,
         grd_qty_unit,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         is_new,
         mtd_ytd,
         sum(other_charges_amt),
         pay_cur_id,
         pay_cur_code,
         pay_cur_decimal,
         grd_to_gmr_qty_factor,
         SUM(gmr_qty)
    from (select aro_current.corporate_id,
                 aro_current.corporate_name,
                 aro_current.gmr_ref_no,
                 aro_current.internal_gmr_ref_no,
                 null internal_grd_ref_no,
                 null stock_ref_no,
                 aro_current.product_id,
                 aro_current.product_name,
                 aro_current.quality_id,
                 aro_current.quality_name,
                 aro_current.arrival_status,
                 aro_current.warehouse_id,
                 aro_current.warehouse_name,
                 aro_current.shed_id,
                 aro_current.shed_name,
                 sum(aro_current.grd_wet_qty) grd_wet_qty,
                 sum(aro_current.grd_dry_qty) grd_dry_qty,
                 null grd_qty_unit_id,
                 null grd_qty_unit,
                 aro_current.conc_base_qty_unit_id,
                 aro_current.conc_base_qty_unit,
                 'N' is_new, -- is_new,
                 'YTD' mtd_ytd, -- mtd_ytd,
                 sum(aro_current.other_charges_amt) other_charges_amt,
                 aro_current.pay_cur_id,
                 aro_current.pay_cur_code,
                 aro_current.pay_cur_decimal,
                 null grd_to_gmr_qty_factor,
                 aro_current.gmr_qty
            from aro_ar_original aro_current
           where aro_current.process_id = pc_process_id
             and exists (select *
                    from gmr_goods_movement_record gmr
                   where gmr.process_id = pc_process_id
                     and gmr.internal_gmr_ref_no =
                         aro_current.internal_gmr_ref_no
                     and gmr.is_assay_updated_ytd = 'Y')
           group by aro_current.corporate_id,
                    aro_current.corporate_name,
                    aro_current.gmr_ref_no,
                    aro_current.internal_gmr_ref_no,
                    aro_current.product_id,
                    aro_current.product_name,
                    aro_current.quality_id,
                    aro_current.quality_name,
                    aro_current.arrival_status,
                    aro_current.warehouse_id,
                    aro_current.warehouse_name,
                    aro_current.shed_id,
                    aro_current.shed_name,
                    aro_current.conc_base_qty_unit_id,
                    aro_current.conc_base_qty_unit,
                    aro_current.pay_cur_id,
                    aro_current.pay_cur_code,
                    aro_current.pay_cur_decimal,
                    aro_current.gmr_qty
          union all
          select are_prev.corporate_id,
                 are_prev.corporate_name,
                 are_prev.gmr_ref_no,
                 are_prev.internal_gmr_ref_no,
                 null internal_grd_ref_no,
                 null stock_ref_no,
                 are_prev.product_id,
                 are_prev.product_name,
                 are_prev.quality_id,
                 are_prev.quality_name,
                 null arrival_status,
                 are_prev.warehouse_id,
                 are_prev.warehouse_name,
                 are_prev.shed_id,
                 are_prev.shed_name,
                 -1 * sum(are_prev.grd_wet_qty),
                 -1 * sum(are_prev.grd_dry_qty),
                 null grd_qty_unit_id,
                 null grd_qty_unit,
                 are_prev.conc_base_qty_unit_id,
                 are_prev.conc_base_qty_unit,
                 'N', -- is_new,
                 'YTD', -- mtd_ytd,
                 -1 * sum(are_prev.other_charges_amt),
                 are_prev.pay_cur_id,
                 are_prev.pay_cur_code,
                 are_prev.pay_cur_decimal,
                 null grd_to_gmr_qty_factor,
                 0 gmr_qty
            from aro_ar_original are_prev
           where are_prev.process_id = vc_previous_year_eom_id
             and exists (select *
                    from gmr_goods_movement_record gmr
                   where gmr.process_id = pc_process_id
                     and gmr.internal_gmr_ref_no =
                         are_prev.internal_gmr_ref_no
                     and gmr.is_assay_updated_ytd = 'Y')
           group by are_prev.corporate_id,
                    are_prev.corporate_name,
                    are_prev.gmr_ref_no,
                    are_prev.internal_gmr_ref_no,
                    are_prev.product_id,
                    are_prev.product_name,
                    are_prev.quality_id,
                    are_prev.quality_name,
                    are_prev.warehouse_id,
                    are_prev.warehouse_name,
                    are_prev.shed_id,
                    are_prev.shed_name,
                    are_prev.conc_base_qty_unit_id,
                    are_prev.conc_base_qty_unit,
                    are_prev.pay_cur_id,
                    are_prev.pay_cur_code,
                    are_prev.pay_cur_decimal,
                    are_prev.gmr_qty)
   group by pc_process_id,
            pd_trade_date,
            corporate_id,
            corporate_name,
            gmr_ref_no,
            internal_gmr_ref_no,
            internal_grd_ref_no,
            stock_ref_no,
            product_id,
            product_name,
            quality_id,
            quality_name,
            warehouse_id,
            warehouse_name,
            shed_id,
            shed_name,
            grd_qty_unit_id,
            grd_qty_unit,
            conc_base_qty_unit_id,
            conc_base_qty_unit,
            is_new,
            mtd_ytd,
            pay_cur_id,
            pay_cur_code,
            pay_cur_decimal,
            grd_to_gmr_qty_factor;


insert into are_arrival_report_element
  (process_id,
   internal_gmr_ref_no,
   internal_grd_ref_no,
   element_id,
   element_name,
   assay_qty,
   asaay_qty_unit_id,
   asaay_qty_unit,
   payable_qty,
   payable_qty_unit_id,
   payable_qty_unit,
   mtd_ytd,
   section_name,
   qty_type,
   price,
   price_unit_id,
   payable_amt_price_ccy,
   payable_amt_pay_ccy,
   fx_rate_price_to_pay,
   base_tc_charges_amt,
   esc_desc_tc_charges_amt,
   rc_charges_amt,
   pc_charges_amt,
   element_base_qty_unit_id,
   element_base_qty_unit)
  select pc_process_id,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         element_id,
         element_name,
         sum(assay_qty),
         asaay_qty_unit_id,
         asaay_qty_unit,
         sum(payable_qty),
         payable_qty_unit_id,
         payable_qty_unit,
         mtd_ytd,
         section_name,
         qty_type,
         price,
         price_unit_id,
         sum(payable_amt_price_ccy),
         sum(payable_amt_pay_ccy),
         fx_rate_price_to_pay,
         sum(base_tc_charges_amt),
         sum(esc_desc_tc_charges_amt),
         sum(rc_charges_amt),
         sum(pc_charges_amt),
         element_base_qty_unit_id,
         element_base_qty_unit
    from (select areo_current.internal_gmr_ref_no,
                 null internal_grd_ref_no,
                 areo_current.element_id,
                 areo_current.element_name,
                 sum(areo_current.assay_qty) assay_qty,
                 areo_current.asaay_qty_unit_id,
                 areo_current.asaay_qty_unit,
                 sum(areo_current.payable_qty) payable_qty,
                 areo_current.payable_qty_unit_id,
                 areo_current.payable_qty_unit,
                 'YTD' mtd_ytd, -- mtd_ytd,
                 areo_current.section_name,
                 areo_current.qty_type,
                 null price,
                 null price_unit_id,
                 sum(areo_current.payable_amt_price_ccy) payable_amt_price_ccy,
                 sum(areo_current.payable_amt_pay_ccy) payable_amt_pay_ccy,
                 null fx_rate_price_to_pay,
                 sum(areo_current.base_tc_charges_amt) base_tc_charges_amt,
                 sum(areo_current.esc_desc_tc_charges_amt) esc_desc_tc_charges_amt,
                 sum(areo_current.rc_charges_amt) rc_charges_amt,
                 sum(areo_current.pc_charges_amt) pc_charges_amt,
                 areo_current.element_base_qty_unit_id,
                 areo_current.element_base_qty_unit
            from areo_ar_element_original areo_current
           where areo_current.process_id = pc_process_id
             and exists (select *
                    from gmr_goods_movement_record gmr
                   where gmr.process_id = pc_process_id
                     and gmr.internal_gmr_ref_no =
                         areo_current.internal_gmr_ref_no
                     and gmr.is_assay_updated_ytd = 'Y')
           group by areo_current.internal_gmr_ref_no,
                    areo_current.element_id,
                    areo_current.element_name,
                    areo_current.asaay_qty_unit_id,
                    areo_current.asaay_qty_unit,
                    areo_current.payable_qty_unit_id,
                    areo_current.payable_qty_unit,
                    areo_current.section_name,
                    areo_current.qty_type,
                    areo_current.element_base_qty_unit_id,
                    areo_current.element_base_qty_unit
          union all
          select areo_prev.internal_gmr_ref_no,
                 null internal_grd_ref_no,
                 areo_prev.element_id,
                 areo_prev.element_name,
                 -1 * sum(areo_prev.assay_qty) assay_qty,
                 areo_prev.asaay_qty_unit_id,
                 areo_prev.asaay_qty_unit,
                 -1 * sum(areo_prev.payable_qty) payable_qty,
                 areo_prev.payable_qty_unit_id,
                 areo_prev.payable_qty_unit,
                 'YTD' mtd_ytd, -- mtd_ytd,
                 areo_prev.section_name,
                 areo_prev.qty_type,
                 null price,
                 null price_unit_id,
                 -1 * sum(areo_prev.payable_amt_price_ccy) payable_amt_price_ccy,
                 -1 * sum(areo_prev.payable_amt_pay_ccy) payable_amt_pay_ccy,
                 null fx_rate_price_to_pay,
                 -1 * sum(areo_prev.base_tc_charges_amt) base_tc_charges_amt,
                 -1 * sum(areo_prev.esc_desc_tc_charges_amt) esc_desc_tc_charges_amt,
                 -1 * sum(areo_prev.rc_charges_amt) rc_charges_amt,
                 -1 * sum(areo_prev.pc_charges_amt) pc_charges_amt,
                 areo_prev.element_base_qty_unit_id,
                 areo_prev.element_base_qty_unit
            from areo_ar_element_original areo_prev
           where areo_prev.process_id = vc_previous_year_eom_id
             and exists (select *
                    from gmr_goods_movement_record gmr
                   where gmr.process_id = pc_process_id
                     and gmr.internal_gmr_ref_no =
                         areo_prev.internal_gmr_ref_no
                     and gmr.is_assay_updated_ytd = 'Y')
           group by areo_prev.internal_gmr_ref_no,
                    areo_prev.element_id,
                    areo_prev.element_name,
                    areo_prev.asaay_qty_unit_id,
                    areo_prev.asaay_qty_unit,
                    areo_prev.payable_qty_unit_id,
                    areo_prev.payable_qty_unit,
                    areo_prev.section_name,
                    areo_prev.qty_type,
                    areo_prev.element_base_qty_unit_id,
                    areo_prev.element_base_qty_unit)
   group by pc_process_id,
            internal_gmr_ref_no,
            internal_grd_ref_no,
            element_id,
            element_name,
            asaay_qty_unit_id,
            asaay_qty_unit,
            payable_qty_unit_id,
            payable_qty_unit,
            mtd_ytd,
            section_name,
            qty_type,
            price,
            price_unit_id,
            fx_rate_price_to_pay,
            element_base_qty_unit_id,
            element_base_qty_unit;
  commit;

gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Populate YTD Delta Data Over');
exception
  when others then
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure sp_arrival_report',
                                                         'M2M-013',
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm,
                                                         '',
                                                         pc_process,
                                                         '',
                                                         sysdate,
                                                         pd_trade_date);
    sp_insert_error_log(vobj_error_log);
    commit;
end;
procedure sp_feedconsumption_report(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_process_id   varchar2,
                                      pc_process      varchar2) as
cursor cur_feed is
select gmr_ref_no,
       dense_rank() over(partition by internal_grd_ref_no order by element_id) ele_rank,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       internal_stock_ref_no,
       supp_internal_gmr_ref_no,
       supp_gmr_ref_no,
       corporate_id,
       warehouse_profile_id,
       companyname,
       shed_id,
       storage_location_name,
       product_id,
       product_desc,
       quality_id,
       quality_name,
       qty,
       dry_wet_qty_ratio,
       wet_qty,
       dry_qty,
       qty_unit_id,
       qty_unit,
       element_id,
       attribute_name,
       underlying_product_id,
       underlying_product_name,
       base_quantity_unit_id,
       base_quantity_unit,
       assay_qty,
       assay_qty_unit_id,
       assay_qty_unit,
       payable_qty,
       payable_qty_unit_id,
       payable_qty_unit,
       pool_name,
       conc_base_qty_unit_id,
       conc_base_qty_unit,
       pay_cur_id,
       pay_cur_code,
       qty_type,
       parent_internal_grd_ref_no,
       section_name,
       grd_base_qty_conv_factor,
       pcdi_id,
       nvl(pay_cur_decimals, 2) pay_cur_decimals,
       feeding_point_id,
       feeding_point_name,
       grd_to_gmr_qty_factor
  from fct_fc_temp t
 where t.corporate_id = pc_corporate_id;
  vobj_error_log                tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count            number := 1;
  vn_wet_qty                    number;
  vn_dry_qty                    number;
  vc_corporate_name             varchar2(100);
  vn_spq_qty_conv_factor        number;
  vn_assay_qty                  number;
  vn_payable_qty                number;
  vn_gmr_price                  number;
  vc_gmr_price_untit_id         varchar2(15);
  vc_price_unit_weight_unit_id  varchar2(15);
  vn_gmr_price_unit_weight      number;
  vc_gmr_price_unit_cur_id      varchar2(15);
  vc_gmr_price_unit_cur_code    varchar2(15);
  vn_payable_amt_in_price_cur   number;
  vn_payable_amt_in_pay_cur     number;
  vc_price_cur_id               varchar2(15);
  vc_price_cur_code             varchar2(15);
  vn_cont_price_cur_id_factor   number;
  vn_cont_price_cur_decimals    number;
  vn_fx_rate_price_to_pay       number;
  vn_payable_to_price_wt_factor number;
  vn_gmr_refine_charge          number;
  vn_gmr_penality_charge        number;
  vn_gmr_base_tc                number;
  vn_gmr_esc_descalator_tc      number;
  
  begin
  select akc.corporate_name
    into vc_corporate_name
    from ak_corporate akc
   where akc.corporate_id = pc_corporate_id;
delete from fct_fc_temp t
where t.corporate_id = pc_corporate_id;
commit;
 gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Delete fct_fc_temp Over');   
  insert into fct_fc_temp
    (gmr_ref_no,
     internal_gmr_ref_no,
     internal_grd_ref_no,
     internal_stock_ref_no,
     supp_internal_gmr_ref_no,
     supp_gmr_ref_no,
     corporate_id,
     warehouse_profile_id,
     companyname,
     shed_id,
     storage_location_name,
     product_id,
     product_desc,
     quality_id,
     quality_name,
     qty,
     dry_wet_qty_ratio,
     wet_qty,
     dry_qty,
     qty_unit_id,
     qty_unit,
     element_id,
     attribute_name,
     underlying_product_id,
     underlying_product_name,
     base_quantity_unit_id,
     base_quantity_unit,
     assay_qty,
     assay_qty_unit_id,
     assay_qty_unit,
     payable_qty,
     payable_qty_unit_id,
     payable_qty_unit,
     pool_name,
     conc_base_qty_unit_id,
     conc_base_qty_unit,
     pay_cur_id,
     pay_cur_code,
     qty_type,
     parent_internal_grd_ref_no,
     section_name,
     grd_base_qty_conv_factor,
     pcdi_id,
     pay_cur_decimals,
     feeding_point_id,
     feeding_point_name,
     grd_to_gmr_qty_factor)
    select gmr.gmr_ref_no,
           gmr.internal_gmr_ref_no,
           grd.internal_grd_ref_no,
           grd.internal_stock_ref_no,
           grd.supp_internal_gmr_ref_no,
           grd.supp_gmr_ref_no supp_gmr_ref_no,
           gmr.corporate_id,
           gmr.warehouse_profile_id,
           gmr.warehouse_name companyname,
           gmr.shed_id,
           gmr.shed_name storage_location_name,
           grd.product_id,
           grd.product_name product_desc,
           grd.quality_id,
           grd.quality_name,
           grd.qty,
           asm.dry_wet_qty_ratio,
           grd.qty wet_qty,
           (grd.qty * asm.dry_wet_qty_ratio / 100) dry_qty,
           grd.qty_unit_id qty_unit_id,
           grd.qty_unit qty_unit,
           spq.element_id,
           aml.element_name attribute_name,
           aml.underlying_product_id,
           aml.underlying_product_name underlying_product_name,
           aml.underlying_base_qty_unit_id base_quantity_unit_id,
           aml.underlying_base_qty_unit base_quantity_unit,
           spq.assay_content assay_qty,
           spq.qty_unit_id assay_qty_unit_id,
           spq.qty_unit assay_qty_unit,
           spq.payable_qty,
           spq.qty_unit_id payable_qty_unit_id,
           spq.qty_unit payable_qty_unit,
           grd.parent_grd_pool_name pool_name,
           grd.base_qty_unit_id conc_base_qty_unit_id,
           grd.base_qty_unit conc_base_qty_unit,
           gmr.invoice_cur_id pay_cur_id,
           gmr.invoice_cur_code pay_cur_code,
           spq.qty_type,
           sam.parent_stock_ref_no parent_internal_grd_ref_no,
           'Non Penalty' section_name,
           nvl(grd.base_qty_conv_factor, 1) grd_base_qty_conv_factor,
           grd.supplier_pcdi_id pcdi_id,
           gmr.invoice_cur_decimals pay_cur_decimals,
           gmr.feeding_point_id,
           gmr.feeding_point_name,
           nvl(grd.grd_to_gmr_qty_factor,1)
           from gmr_goods_movement_record      gmr,
           grd_goods_record_detail        grd,
           spq_stock_payable_qty          spq,
           ash_assay_header               ash,
           asm_assay_sublot_mapping       asm,
           eud_element_underlying_details aml,
           sam_stock_assay_mapping        sam
     where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
       and grd.status = 'Active'
       and grd.tolling_stock_type = 'Clone Stock'
       and gmr.tolling_service_type = 'P'
       and gmr.is_pass_through = 'Y'
       and grd.internal_grd_ref_no = spq.internal_grd_ref_no
       and gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
       and spq.is_stock_split = 'N'
       and spq.weg_avg_pricing_assay_id = ash.ash_id
       and ash.ash_id = asm.ash_id
       and spq.element_id = aml.element_id
       and gmr.is_deleted = 'N'
       and gmr.process_id = pc_process_id
       and spq.process_id = pc_process_id
       and grd.process_id = pc_process_id
       and grd.internal_grd_ref_no = sam.internal_grd_ref_no
       and sam.is_active = 'Y'
       and ash.assay_type in
           ('Weighted Avg Pricing Assay', 'Shipment Assay')
       and ash.ash_id = sam.ash_id
       and (gmr.is_new_mtd = 'Y' or gmr.is_new_ytd = 'Y' or
           gmr.is_assay_updated_mtd = 'Y' or
           gmr.is_assay_updated_ytd = 'Y');
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert fct_fc_temp Payable Over');            
  insert into fct_fc_temp
    (gmr_ref_no,
     internal_gmr_ref_no,
     internal_grd_ref_no,
     internal_stock_ref_no,
     supp_internal_gmr_ref_no,
     supp_gmr_ref_no,
     corporate_id,
     warehouse_profile_id,
     companyname,
     shed_id,
     storage_location_name,
     product_id,
     product_desc,
     quality_id,
     quality_name,
     qty,
     dry_wet_qty_ratio,
     wet_qty,
     dry_qty,
     qty_unit_id,
     qty_unit,
     element_id,
     attribute_name,
     underlying_product_id,
     underlying_product_name,
     base_quantity_unit_id,
     base_quantity_unit,
     assay_qty,
     assay_qty_unit_id,
     assay_qty_unit,
     payable_qty,
     payable_qty_unit_id,
     payable_qty_unit,
     pool_name,
     conc_base_qty_unit_id,
     conc_base_qty_unit,
     pay_cur_id,
     pay_cur_code,
     qty_type,
     parent_internal_grd_ref_no,
     section_name,
     grd_base_qty_conv_factor,
     pcdi_id,
     pay_cur_decimals,
     feeding_point_id,
     feeding_point_name,
     grd_to_gmr_qty_factor)
select gmr.gmr_ref_no,
               gmr.internal_gmr_ref_no,
               grd.internal_grd_ref_no,
               grd.internal_stock_ref_no,
               grd.supp_internal_gmr_ref_no,
               grd.supp_gmr_ref_no supp_gmr_ref_no,
               gmr.corporate_id,
               gmr.warehouse_profile_id,
               gmr.warehouse_name companyname,
               gmr.shed_id,
               gmr.shed_name storage_location_name,
               grd.product_id,
               grd.product_name,
               grd.quality_id,
               grd.quality_name,
               grd.qty,
               null as dry_wet_qty_ratio,
               grd.qty wet_qty,
               grd.dry_qty dry_qty,
               grd.qty_unit_id qty_unit_id,
               grd.qty_unit qty_unit,
               ped.element_id,
               ped.element_name attribute_name,
               null underlying_product_id,
               null underlying_product_name,
               null base_quantity_unit_id,
               null base_quantity_unit,
               0 assay_qty,
               null assay_qty_unit_id,
               null assay_qty_unit,
               0 payable_qty,
               null payable_qty_unit_id,
               null payable_qty_unit,
               grd.parent_grd_pool_name,
               grd.base_qty_unit_id conc_base_qty_unit_id,
               grd.base_qty_unit conc_base_qty_unit,
               gmr.invoice_cur_id pay_cur_id,
               gmr.invoice_cur_code pay_cur_code,
               'Penalty' qty_type,
               ped.parent_stock_ref_no,
               'Penalty' section_name,
               nvl(grd.base_qty_conv_factor, 1) grd_base_qty_conv_factor,
               grd.supplier_pcdi_id pcdi_id,
               gmr.invoice_cur_decimals pay_cur_decimals,
               gmr.feeding_point_id,
               gmr.feeding_point_name,
               nvl(grd.grd_to_gmr_qty_factor,1)
          from gmr_goods_movement_record   gmr,
               grd_goods_record_detail     grd,
               ped_penalty_element_details ped
         where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and grd.status = 'Active'
           and grd.tolling_stock_type = 'Clone Stock'
           and gmr.tolling_service_type = 'P'
           and gmr.is_pass_through = 'Y'
           and gmr.is_deleted = 'N'
           and gmr.process_id = pc_process_id
           and grd.process_id = pc_process_id
           and ped.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and ped.internal_grd_ref_no = grd.internal_grd_ref_no
           and ped.process_id =pc_process_id
           and (gmr.is_new_mtd ='Y' or gmr.is_new_ytd ='Y' or gmr.is_assay_updated_mtd ='Y' or gmr.is_assay_updated_ytd ='Y');
                    
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert fct_fc_temp Penalty Over');    
    for cur_feed_rows in cur_feed
    loop  
  if cur_feed_rows.section_name = 'Non Penalty' then
    
    begin
      select ucm.multiplication_factor
        into vn_spq_qty_conv_factor
        from ucm_unit_conversion_master ucm
       where ucm.from_qty_unit_id = cur_feed_rows.assay_qty_unit_id
         and ucm.to_qty_unit_id = cur_feed_rows.base_quantity_unit_id;
    exception
      when others then
        vn_spq_qty_conv_factor := -1;
    end;
    end if;
    --
    -- Wet, Dry, Payable And Assay Quantities are stored in product Base Quantity Unit
    --
    vn_wet_qty   := cur_feed_rows.wet_qty *
                    cur_feed_rows.grd_base_qty_conv_factor;
    vn_dry_qty   := cur_feed_rows.dry_qty *
                    cur_feed_rows.grd_base_qty_conv_factor;
    
    if cur_feed_rows.section_name = 'Non Penalty' then
      vn_payable_qty := cur_feed_rows.payable_qty *
                        vn_spq_qty_conv_factor;
                        vn_assay_qty := cur_feed_rows.assay_qty * vn_spq_qty_conv_factor;                        
    else
      vn_payable_qty := 0;
      vn_assay_qty :=0;
    end if;  
      if cur_feed_rows.ele_rank = 1 then
        insert into fco_feed_consumption_original
          (process_id,
           eod_trade_date,
           corporate_id,
           corporate_name,
           gmr_ref_no,
           internal_gmr_ref_no,
           internal_grd_ref_no,
           stock_ref_no,
           product_id,
           product_name,
           quality_id,
           quality_name,
           pile_name,
           parent_gmr_ref_no,
           parent_internal_gmr_ref_no,
           parent_internal_grd_ref_no,
           warehouse_id,
           warehouse_name,
           shed_id,
           shed_name,
           grd_wet_qty,
           grd_dry_qty,
           grd_qty_unit_id,
           grd_qty_unit,
           conc_base_qty_unit_id,
           conc_base_qty_unit,
           original_grd_qty,
           original_grd_qty_unit_id,
           dry_wet_qty_ratio,
           pay_cur_id,
           pay_cur_code,
           pay_cur_decimal,
           feeding_point_id,
           feeding_point_name,
           grd_to_gmr_qty_factor,
           other_charges_amt,
           pcdi_id
           )
        values
          (pc_process_id,
           pd_trade_date,
           cur_feed_rows.corporate_id,
           vc_corporate_name,
           cur_feed_rows.gmr_ref_no,
           cur_feed_rows.internal_gmr_ref_no,
           cur_feed_rows.internal_grd_ref_no,
           cur_feed_rows.internal_stock_ref_no,
           cur_feed_rows.product_id,
           cur_feed_rows.product_desc,
           cur_feed_rows.quality_id,
           cur_feed_rows.quality_name,
           cur_feed_rows.pool_name,
           cur_feed_rows.supp_gmr_ref_no,
           cur_feed_rows.supp_internal_gmr_ref_no,
           cur_feed_rows.parent_internal_grd_ref_no,
           cur_feed_rows.warehouse_profile_id,
           cur_feed_rows.companyname,
           cur_feed_rows.shed_id,
           cur_feed_rows.storage_location_name,
           vn_wet_qty,
           vn_dry_qty,
           cur_feed_rows.qty_unit_id,
           cur_feed_rows.qty_unit,
           cur_feed_rows.conc_base_qty_unit_id,
           cur_feed_rows.conc_base_qty_unit,
           cur_feed_rows.qty,
           cur_feed_rows.qty_unit_id,
           cur_feed_rows.dry_wet_qty_ratio,
           cur_feed_rows.pay_cur_id,
           cur_feed_rows.pay_cur_code,
           cur_feed_rows.pay_cur_decimals,
           cur_feed_rows.feeding_point_id,
           cur_feed_rows.feeding_point_name,
           cur_feed_rows.grd_to_gmr_qty_factor,
           0,--other_charges_amt
           cur_feed_rows.pcdi_id
           );
      end if;
    --
    -- Get the Price for the GMR and Element
    --
    if cur_feed_rows.section_name = 'Non Penalty' and
       cur_feed_rows.payable_qty <> 0 then
      begin
        select cgcp.contract_price,
               cgcp.price_unit_id,
               cgcp.price_unit_weight_unit_id,
               cgcp.price_unit_cur_id,
               cgcp.price_unit_cur_code,
               cgcp.price_unit_weight
          into vn_gmr_price,
               vc_gmr_price_untit_id,
               vc_price_unit_weight_unit_id,
               vc_gmr_price_unit_cur_id,
               vc_gmr_price_unit_cur_code,
               vn_gmr_price_unit_weight
          from cgcp_conc_gmr_cog_price cgcp
         where cgcp.internal_gmr_ref_no =
               cur_feed_rows.supp_internal_gmr_ref_no
           and cgcp.process_id = pc_process_id
           and cgcp.element_id = cur_feed_rows.element_id;
      exception
        when others then
          begin
            select cccp.contract_price,
                   cccp.price_unit_id,
                   cccp.price_unit_weight_unit_id,
                   cccp.price_unit_cur_id,
                   cccp.price_unit_cur_code,
                   cccp.price_unit_weight
              into vn_gmr_price,
                   vc_gmr_price_untit_id,
                   vc_price_unit_weight_unit_id,
                   vc_gmr_price_unit_cur_id,
                   vc_gmr_price_unit_cur_code,
                   vn_gmr_price_unit_weight
              from cccp_conc_contract_cog_price cccp
             where cccp.pcdi_id = cur_feed_rows.pcdi_id
               and cccp.process_id = pc_process_id
               and cccp.element_id = cur_feed_rows.element_id;
          exception
            when others then
              vn_gmr_price                 := null;
              vc_gmr_price_untit_id        := null;
              vc_price_unit_weight_unit_id := null;
              vc_gmr_price_unit_cur_id     := null;
              vc_gmr_price_unit_cur_code   := null;
          end;
        
      end;
    
      pkg_general.sp_get_main_cur_detail(vc_gmr_price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
      --
      -- Quantity Conversion between Payable to Price Units
      --
      if cur_feed_rows.payable_qty_unit_id <>
         vc_price_unit_weight_unit_id then
        begin
          select ucm.multiplication_factor
            into vn_payable_to_price_wt_factor
            from ucm_unit_conversion_master ucm
           where ucm.from_qty_unit_id =
                 cur_feed_rows.payable_qty_unit_id
             and ucm.to_qty_unit_id = vc_price_unit_weight_unit_id;
        exception
          when others then
            vn_payable_to_price_wt_factor := -1;
        end;
      else
        vn_payable_to_price_wt_factor := 1;
      end if;
      begin
        select cet.exch_rate
          into vn_fx_rate_price_to_pay
          from cet_corporate_exch_rate cet
         where cet.corporate_id = pc_corporate_id
           and cet.from_cur_id = vc_gmr_price_unit_cur_id
           and cet.to_cur_id = cur_feed_rows.pay_cur_id;
      exception
        when no_data_found then
          vn_fx_rate_price_to_pay := -1;
      end;
      --
      -- Calculate TC Charges, Use Dry or Wet Quantity As Configured in the Contract
      --    
      begin
        select round((case
                       when getc.weight_type = 'Dry' then
                        cur_feed_rows.dry_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                       else
                        cur_feed_rows.wet_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                     end),
                     cur_feed_rows.pay_cur_decimals),
               round((case
                       when getc.weight_type = 'Dry' then
                        cur_feed_rows.dry_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                       else
                        cur_feed_rows.wet_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                     end),
                     cur_feed_rows.pay_cur_decimals)
          into vn_gmr_base_tc,
               vn_gmr_esc_descalator_tc
          from getc_gmr_element_tc_charges getc,
               ucm_unit_conversion_master  ucm
         where getc.process_id = pc_process_id
           and getc.internal_gmr_ref_no =
               cur_feed_rows.supp_internal_gmr_ref_no
           and getc.internal_grd_ref_no =
               cur_feed_rows.parent_internal_grd_ref_no
           and getc.element_id = cur_feed_rows.element_id
           and ucm.from_qty_unit_id = cur_feed_rows.qty_unit_id
           and ucm.to_qty_unit_id = getc.tc_weight_unit_id;
      exception
        when others then
          vn_gmr_base_tc           := 0;
          vn_gmr_esc_descalator_tc := 0;
      end;
    else
      vn_gmr_price                  := null;
      vc_gmr_price_untit_id         := null;
      vc_price_unit_weight_unit_id  := null;
      vc_gmr_price_unit_cur_id      := null;
      vc_gmr_price_unit_cur_code    := null;
      vn_payable_to_price_wt_factor := null;
      vn_gmr_base_tc                := 0;
      vn_gmr_esc_descalator_tc      := 0;
      vn_fx_rate_price_to_pay       := null;
    end if;
   --
   -- If TC is assay based and payable qty is zero, we still need to calcualte TC
   -- 
     if cur_feed_rows.section_name = 'Non Penalty' and
       cur_feed_rows.payable_qty = 0 then
       begin
        select round((case
                       when getc.weight_type = 'Dry' then
                        cur_feed_rows.dry_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                       else
                        cur_feed_rows.wet_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                     end),
                     cur_feed_rows.pay_cur_decimals),
               round((case
                       when getc.weight_type = 'Dry' then
                        cur_feed_rows.dry_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                       else
                        cur_feed_rows.wet_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                     end),
                     cur_feed_rows.pay_cur_decimals)
          into vn_gmr_base_tc,
               vn_gmr_esc_descalator_tc
          from getc_gmr_element_tc_charges getc,
               ucm_unit_conversion_master  ucm
         where getc.process_id = pc_process_id
           and getc.internal_gmr_ref_no =
               cur_feed_rows.supp_internal_gmr_ref_no
           and getc.internal_grd_ref_no =
               cur_feed_rows.parent_internal_grd_ref_no
           and getc.element_id = cur_feed_rows.element_id
           and ucm.from_qty_unit_id = cur_feed_rows.qty_unit_id
           and ucm.to_qty_unit_id = getc.tc_weight_unit_id;
      exception
        when others then
          vn_gmr_base_tc           := 0;
          vn_gmr_esc_descalator_tc := 0;
      end;
       end if;
    --
    -- Calculate Penalty Charges, Use Dry or Wet Quantity As Configured in the Contract
    --    
    if cur_feed_rows.section_name = 'Penalty' then
      begin
        select round((case
                       when gepc.weight_type = 'Dry' then
                        cur_feed_rows.dry_qty * ucm.multiplication_factor *
                        gepc.pc_value
                       else
                        cur_feed_rows.wet_qty * ucm.multiplication_factor *
                        gepc.pc_value
                     end),
                     cur_feed_rows.pay_cur_decimals)
          into vn_gmr_penality_charge
          from gepc_gmr_element_pc_charges gepc,
               ucm_unit_conversion_master  ucm
         where gepc.process_id = pc_process_id
           and gepc.internal_gmr_ref_no =
               cur_feed_rows.supp_internal_gmr_ref_no
           and gepc.internal_grd_ref_no =
               cur_feed_rows.parent_internal_grd_ref_no
           and gepc.element_id = cur_feed_rows.element_id
           and ucm.from_qty_unit_id = cur_feed_rows.qty_unit_id
           and ucm.to_qty_unit_id = gepc.pc_weight_unit_id;
      exception
        when others then
          vn_gmr_penality_charge := 0;
      end;
    else
      vn_gmr_penality_charge := 0;
    end if;
    --
    -- Calcualte Payable Amount and RC Charges
    --
    if cur_feed_rows.section_name = 'Non Penalty' and
       cur_feed_rows.payable_qty <> 0 then
      vn_payable_amt_in_price_cur := round((vn_gmr_price /
                                           nvl(vn_gmr_price_unit_weight, 1)) *
                                           (vn_payable_to_price_wt_factor *
                                           cur_feed_rows.payable_qty) *
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
      vn_payable_amt_in_pay_cur   := round(vn_payable_amt_in_price_cur *
                                           vn_fx_rate_price_to_pay,
                                           cur_feed_rows.pay_cur_decimals);
      --
      -- Calculate RC Charges
      --    
    
      begin
        select round(gerc.rc_value * ucm.multiplication_factor *
                     cur_feed_rows.payable_qty,
                     cur_feed_rows.pay_cur_decimals)
          into vn_gmr_refine_charge
          from gerc_gmr_element_rc_charges gerc,
               ucm_unit_conversion_master  ucm
         where gerc.process_id = pc_process_id
           and gerc.internal_gmr_ref_no =
               cur_feed_rows.supp_internal_gmr_ref_no
           and gerc.internal_grd_ref_no =
               cur_feed_rows.parent_internal_grd_ref_no
           and gerc.element_id = cur_feed_rows.element_id
           and ucm.from_qty_unit_id = cur_feed_rows.payable_qty_unit_id
           and ucm.to_qty_unit_id = gerc.rc_weight_unit_id;
      exception
        when others then
          vn_gmr_refine_charge := 0;
      end;
    else
      vn_payable_amt_in_price_cur := 0;
      vn_payable_amt_in_pay_cur   := 0;
      vn_gmr_refine_charge        := 0;
      vn_fx_rate_price_to_pay     := null;
    end if;
      insert into fceo_feed_con_element_original
        (process_id,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         element_id,
         element_name,
         assay_qty,
         asaay_qty_unit_id,
         asaay_qty_unit,
         payable_qty,
         payable_qty_unit_id,
         payable_qty_unit,
         underlying_product_id,
         underlying_base_qty_unit_id,
         payable_returnable_type,
         parent_internal_gmr_ref_no,
         parent_internal_grd_ref_no,
         section_name,
         qty_type,
         price,
         price_unit_id,
         payable_amt_price_ccy,
         payable_amt_pay_ccy,
         fx_rate_price_to_pay,
         base_tc_charges_amt,
         esc_desc_tc_charges_amt,
         rc_charges_amt,
         pc_charges_amt,
         element_base_qty_unit_id,
         element_base_qty_unit,
         pcdi_id)
      values
        (pc_process_id,
         cur_feed_rows.internal_gmr_ref_no,
         cur_feed_rows.internal_grd_ref_no,
         cur_feed_rows.element_id,
         cur_feed_rows.attribute_name,
         vn_assay_qty,
         cur_feed_rows.base_quantity_unit_id,
         cur_feed_rows.base_quantity_unit,
         vn_payable_qty,
         cur_feed_rows.base_quantity_unit_id,
         cur_feed_rows.base_quantity_unit,
         cur_feed_rows.underlying_product_id,
         cur_feed_rows.base_quantity_unit_id,
         cur_feed_rows.qty_type,
         cur_feed_rows.supp_internal_gmr_ref_no,
         cur_feed_rows.parent_internal_grd_ref_no,
         cur_feed_rows.section_name,
         cur_feed_rows.qty_type,
         vn_gmr_price,
         vc_gmr_price_untit_id,
         vn_payable_amt_in_price_cur,
         vn_payable_amt_in_pay_cur,
         vn_fx_rate_price_to_pay,
         vn_gmr_base_tc,
         vn_gmr_esc_descalator_tc,
         vn_gmr_refine_charge,
         vn_gmr_penality_charge,
         cur_feed_rows.base_quantity_unit_id,
         cur_feed_rows.base_quantity_unit,
         cur_feed_rows.pcdi_id);
    end loop;
    commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Feed Consumption report Main Insert Over');   
for cur_fco_gmr_qty in (
select gmr.internal_gmr_ref_no parent_internal_gmr_ref_no,
       gmr.wet_qty             gmr_qty
  from gmr_goods_movement_record gmr
 where gmr.process_id = pc_process_id
   and gmr.is_deleted = 'N')
  loop
    update fco_feed_consumption_original fco
       set fco.gmr_qty = cur_fco_gmr_qty.gmr_qty
     where fco.process_id = pc_process_id
       and fco.parent_internal_gmr_ref_no = cur_fco_gmr_qty.parent_internal_gmr_ref_no;
  end loop;
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Feed Consumption report GMR Qty Updation Over');
  --  
  -- Update Other Charges
  --

  for cur_oc in (select gfoc.internal_gmr_ref_no,
                        gfoc.small_lot_charge + gfoc.container_charge +
                        gfoc.sampling_charge + gfoc.handling_charge +
                        gfoc.location_value + gfoc.freight_allowance as other_charges
                   from gfoc_gmr_freight_other_charge gfoc
                  where gfoc.process_id = pc_process_id)
  loop
  
    update fco_feed_consumption_original fco
       set fco.other_charges_amt = round((cur_oc.other_charges *
                                         fco.grd_wet_qty / fco.gmr_qty),
                                         fco.pay_cur_decimal)
     where fco.process_id = pc_process_id
       and fco.parent_internal_gmr_ref_no = cur_oc.internal_gmr_ref_no;
  end loop;
  commit;    
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Feed Consumption report Other Charge Updation Over'); 

--
-- Populate MTD New Data
--       
insert into fc_feed_consumption
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   gmr_ref_no,
   internal_gmr_ref_no,
   internal_grd_ref_no,
   stock_ref_no,
   product_id,
   product_name,
   quality_id,
   quality_name,
   pile_name,
   parent_gmr_ref_no,
   warehouse_id,
   warehouse_name,
   shed_id,
   shed_name,
   grd_wet_qty,
   grd_dry_qty,
   grd_qty_unit_id,
   grd_qty_unit,
   conc_base_qty_unit_id,
   conc_base_qty_unit,
   original_grd_qty,
   original_grd_qty_unit_id,
   dry_wet_qty_ratio,
   pay_cur_id,
   pay_cur_code,
   parent_internal_gmr_ref_no,
   parent_internal_grd_ref_no,
   feeding_point_id,
   feeding_point_name,
   is_new,
   mtd_ytd,
   other_charges_amt)
  select process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         stock_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         pile_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         grd_wet_qty,
         grd_dry_qty,
         grd_qty_unit_id,
         grd_qty_unit,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         original_grd_qty,
         original_grd_qty_unit_id,
         dry_wet_qty_ratio,
         pay_cur_id,
         pay_cur_code,
         parent_internal_gmr_ref_no,
         parent_internal_grd_ref_no,
         feeding_point_id,
         feeding_point_name,
         'Y',
         'MTD',
         other_charges_amt
    from fco_feed_consumption_original fco
   where fco.process_id = pc_process_id
     and exists
   (select * from gmr_goods_movement_record gmr
           where gmr.process_id = pc_process_id
             and gmr.internal_gmr_ref_no = fco.internal_gmr_ref_no
             and gmr.is_new_mtd = 'Y');
commit;
 gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Feed Consumption report MTD New Data Header Over'); 
insert into fce_feed_consumption_element
  (process_id,
   internal_gmr_ref_no,
   internal_grd_ref_no,
   element_id,
   element_name,
   assay_qty,
   asaay_qty_unit_id,
   asaay_qty_unit,
   payable_qty,
   payable_qty_unit_id,
   payable_qty_unit,
   underlying_product_id,
   underlying_base_qty_unit_id,
   payable_returnable_type,
   rc_amount,
   penality_amount,
   parent_internal_gmr_ref_no,
   parent_internal_grd_ref_no,
   section_name,
   qty_type,
   price,
   price_unit_id,
   payable_amt_price_ccy,
   payable_amt_pay_ccy,
   fx_rate_price_to_pay,
   base_tc_charges_amt,
   esc_desc_tc_charges_amt,
   element_base_qty_unit_id,
   element_base_qty_unit,
   mtd_ytd)
  select process_id,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         element_id,
         element_name,
         assay_qty,
         asaay_qty_unit_id,
         asaay_qty_unit,
         payable_qty,
         payable_qty_unit_id,
         payable_qty_unit,
         underlying_product_id,
         underlying_base_qty_unit_id,
         payable_returnable_type,
         fceo.rc_charges_amt rc_amount,
         fceo.pc_charges_amt penality_amount,
         parent_internal_gmr_ref_no,
         parent_internal_grd_ref_no,
         section_name,
         qty_type,
         price,
         price_unit_id,
         payable_amt_price_ccy,
         payable_amt_pay_ccy,
         fx_rate_price_to_pay,
         base_tc_charges_amt,
         esc_desc_tc_charges_amt,
         element_base_qty_unit_id,
         element_base_qty_unit,
         'MTD'
    from fceo_feed_con_element_original fceo
   where fceo.process_id = pc_process_id
     and exists
   (select *
            from gmr_goods_movement_record gmr
           where gmr.process_id = pc_process_id
             and gmr.internal_gmr_ref_no = fceo.internal_gmr_ref_no
             and gmr.is_new_mtd = 'Y');
commit;
 gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Feed Consumption report MTD New Data Detail Over'); 
--
-- Populate YTD New Data
--
insert into fc_feed_consumption
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   gmr_ref_no,
   internal_gmr_ref_no,
   internal_grd_ref_no,
   stock_ref_no,
   product_id,
   product_name,
   quality_id,
   quality_name,
   pile_name,
   parent_gmr_ref_no,
   warehouse_id,
   warehouse_name,
   shed_id,
   shed_name,
   grd_wet_qty,
   grd_dry_qty,
   grd_qty_unit_id,
   grd_qty_unit,
   conc_base_qty_unit_id,
   conc_base_qty_unit,
   original_grd_qty,
   original_grd_qty_unit_id,
   dry_wet_qty_ratio,
   pay_cur_id,
   pay_cur_code,
   parent_internal_gmr_ref_no,
   parent_internal_grd_ref_no,
   feeding_point_id,
   feeding_point_name,
   is_new,
   mtd_ytd,
   other_charges_amt)
  select process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         stock_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         pile_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         grd_wet_qty,
         grd_dry_qty,
         grd_qty_unit_id,
         grd_qty_unit,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         original_grd_qty,
         original_grd_qty_unit_id,
         dry_wet_qty_ratio,
         pay_cur_id,
         pay_cur_code,
         parent_internal_gmr_ref_no,
         parent_internal_grd_ref_no,
         feeding_point_id,
         feeding_point_name,
         'Y',
         'YTD',
         other_charges_amt
    from fco_feed_consumption_original fco
   where fco.process_id = pc_process_id
     and exists
   (select * from gmr_goods_movement_record gmr
           where gmr.process_id = pc_process_id
             and gmr.internal_gmr_ref_no = fco.internal_gmr_ref_no
             and gmr.is_new_ytd = 'Y');
commit;
 gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Feed Consumption report YTD New Data Header Over'); 
insert into fce_feed_consumption_element
  (process_id,
   internal_gmr_ref_no,
   internal_grd_ref_no,
   element_id,
   element_name,
   assay_qty,
   asaay_qty_unit_id,
   asaay_qty_unit,
   payable_qty,
   payable_qty_unit_id,
   payable_qty_unit,
   underlying_product_id,
   underlying_base_qty_unit_id,
   payable_returnable_type,
   rc_amount,
   penality_amount,
   parent_internal_gmr_ref_no,
   parent_internal_grd_ref_no,
   section_name,
   qty_type,
   price,
   price_unit_id,
   payable_amt_price_ccy,
   payable_amt_pay_ccy,
   fx_rate_price_to_pay,
   base_tc_charges_amt,
   esc_desc_tc_charges_amt,
   element_base_qty_unit_id,
   element_base_qty_unit,
   mtd_ytd)
  select process_id,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         element_id,
         element_name,
         assay_qty,
         asaay_qty_unit_id,
         asaay_qty_unit,
         payable_qty,
         payable_qty_unit_id,
         payable_qty_unit,
         underlying_product_id,
         underlying_base_qty_unit_id,
         payable_returnable_type,
         fceo.rc_charges_amt rc_amount,
         fceo.pc_charges_amt penality_amount,
         parent_internal_gmr_ref_no,
         parent_internal_grd_ref_no,
         section_name,
         qty_type,
         price,
         price_unit_id,
         payable_amt_price_ccy,
         payable_amt_pay_ccy,
         fx_rate_price_to_pay,
         base_tc_charges_amt,
         esc_desc_tc_charges_amt,
         element_base_qty_unit_id,
         element_base_qty_unit,
         'YTD'
    from fceo_feed_con_element_original fceo
   where fceo.process_id = pc_process_id
     and exists
   (select *
            from gmr_goods_movement_record gmr
           where gmr.process_id = pc_process_id
             and gmr.internal_gmr_ref_no = fceo.internal_gmr_ref_no
             and gmr.is_new_ytd = 'Y');
commit;
 gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Feed Consumption report YTD New Data Detail Over'); 

--
-- Populate FCG_FEED_CONSUMPTION_GMR for this EOM for MTD
--
insert into fcg_feed_consumption_gmr
  (process_id, internal_gmr_ref_no, mtd_ytd, prev_process_id)
  select pc_process_id,
         t.internal_gmr_ref_no,
         'MTD',
         tdc.process_id
    from (
    select fco.internal_gmr_ref_no,
           max(fco.eod_trade_date) eod_trade_date
      from fco_feed_consumption_original fco
     where fco.eod_trade_date < pd_trade_date
     and fco.internal_gmr_ref_no in
           (select gmr.internal_gmr_ref_no
              from gmr_goods_movement_record gmr
             where gmr.is_assay_updated_mtd = 'Y'
               and gmr.process_id = pc_process_id)
     group by fco.internal_gmr_ref_no) t,
         tdc_trade_date_closure tdc
   where tdc.corporate_id = pc_corporate_id
     and tdc.process = 'EOM'
     and tdc.trade_date = t.eod_trade_date;
commit;     
--
-- Populate FCG_FEED_CONSUMPTION_GMR for this EOM for YTD
--    

insert into fcg_feed_consumption_gmr
  (process_id, internal_gmr_ref_no, mtd_ytd, prev_process_id)
  select pc_process_id,
         t.internal_gmr_ref_no,
         'YTD',
         tdc.process_id
    from (
    select fco.internal_gmr_ref_no,
           max(fco.eod_trade_date) eod_trade_date
      from fco_feed_consumption_original fco
     where fco.eod_trade_date < trunc(pd_trade_date,'YYYY')
     and  fco.internal_gmr_ref_no in
           (select gmr.internal_gmr_ref_no
              from gmr_goods_movement_record gmr
             where gmr.is_assay_updated_ytd = 'Y'
               and gmr.process_id = pc_process_id)
     group by fco.internal_gmr_ref_no) t,
         tdc_trade_date_closure tdc
   where tdc.corporate_id = pc_corporate_id
     and tdc.process = 'EOM'
     and tdc.trade_date = t.eod_trade_date;
 commit;
 --
 -- Populate MTD Delta Data
 -- 
 
 delete from fcot_fco_temp where corporate_id = pc_corporate_id;
 commit;
 gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Delete fcot_fco_temp for MTD Assay Update'); 
--
-- Previous  EOD Data for Assay Change
--
insert into fcot_fco_temp
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   gmr_ref_no,
   internal_gmr_ref_no,
   product_id,
   product_name,
   quality_id,
   quality_name,
   pile_name,
   parent_gmr_ref_no,
   warehouse_id,
   warehouse_name,
   shed_id,
   shed_name,
   grd_wet_qty,
   grd_dry_qty,
   conc_base_qty_unit_id,
   conc_base_qty_unit,
   pay_cur_id,
   pay_cur_code,
   parent_internal_gmr_ref_no,
   is_new,
   mtd_ytd,
   other_charges_amt,
   feeding_point_id,
   feeding_point_name)
  select process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         pile_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
        -1*  sum(grd_wet_qty) grd_wet_qty,
        -1*   sum(grd_dry_qty)  grd_dry_qty,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         pay_cur_id,
         pay_cur_code,
         parent_internal_gmr_ref_no,
         'N', --is_new,
         'MTD', --mtd_ytd,
         -1*  sum(other_charges_amt) other_charges_amt,
         feeding_point_id,
         feeding_point_name
    from fco_feed_consumption_original fco_prev
   where (fco_prev.internal_gmr_ref_no, fco_prev.process_id) in
         (select fcg.internal_gmr_ref_no,
                 fcg.prev_process_id
            from fcg_feed_consumption_gmr fcg
           where fcg.process_id = pc_process_id
             and fcg.mtd_ytd = 'MTD')
group by process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         pile_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         pay_cur_id,
         pay_cur_code,
         parent_internal_gmr_ref_no,
         feeding_point_id,
         feeding_point_name;
 
 commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert fcot_fco_temp for MTD Assay Update Over 1'); 

--
-- Current  EOD Data for Assay Change
--

insert into fcot_fco_temp
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   gmr_ref_no,
   internal_gmr_ref_no,
   product_id,
   product_name,
   quality_id,
   quality_name,
   pile_name,
   parent_gmr_ref_no,
   warehouse_id,
   warehouse_name,
   shed_id,
   shed_name,
   grd_wet_qty,
   grd_dry_qty,
  conc_base_qty_unit_id,
   conc_base_qty_unit,
  pay_cur_id,
   pay_cur_code,
   parent_internal_gmr_ref_no,
   is_new,
   mtd_ytd,
   other_charges_amt,
   feeding_point_id,
   feeding_point_name)
  select process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         pile_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         sum(grd_wet_qty) grd_wet_qty,
         sum(grd_dry_qty) grd_dry_qty,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         pay_cur_id,
         pay_cur_code,
         parent_internal_gmr_ref_no,
         'N', --is_new,
         'MTD', --mtd_ytd,
         sum(other_charges_amt) other_charges_amt,
         feeding_point_id,
         feeding_point_name
    from fco_feed_consumption_original fco
   where (fco.internal_gmr_ref_no, fco.process_id) in
         (select fcg.internal_gmr_ref_no,
                 pc_process_id
            from fcg_feed_consumption_gmr fcg
           where fcg.process_id = pc_process_id
             and fcg.mtd_ytd = 'MTD')
group by process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         pile_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         pay_cur_id,
         pay_cur_code,
         parent_internal_gmr_ref_no,
         feeding_point_id,
         feeding_point_name;
         
commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert fcot_fco_temp for MTD Assay Update Over 2'); 
 insert into fc_feed_consumption
   (process_id,
    eod_trade_date,
    corporate_id,
    corporate_name,
    gmr_ref_no,
    internal_gmr_ref_no,
    product_id,
    product_name,
    quality_id,
    quality_name,
    pile_name,
    parent_gmr_ref_no,
    warehouse_id,
    warehouse_name,
    shed_id,
    shed_name,
    grd_wet_qty,
    grd_dry_qty,
    conc_base_qty_unit_id,
    conc_base_qty_unit,
    pay_cur_id,
    pay_cur_code,
    parent_internal_gmr_ref_no,
    is_new,
    mtd_ytd,
    feeding_point_id,
    feeding_point_name,
    other_charges_amt)
   select pc_process_id,
          pd_trade_date,
          corporate_id,
          corporate_name,
          gmr_ref_no,
          internal_gmr_ref_no,
          product_id,
          product_name,
          quality_id,
          quality_name,
          pile_name,
          parent_gmr_ref_no,
          warehouse_id,
          warehouse_name,
          shed_id,
          shed_name,
          sum(grd_wet_qty),
          sum(grd_dry_qty),
          conc_base_qty_unit_id,
          conc_base_qty_unit,
          pay_cur_id,
          pay_cur_code,
          parent_internal_gmr_ref_no,
          is_new,
          mtd_ytd,
          feeding_point_id,
          feeding_point_name,
          sum(other_charges_amt)
     from fcot_fco_temp t
    where t.corporate_id = pc_corporate_id
    group by corporate_id,
             corporate_name,
             gmr_ref_no,
             internal_gmr_ref_no,
             product_id,
             product_name,
             quality_id,
             quality_name,
             pile_name,
             parent_gmr_ref_no,
             warehouse_id,
             warehouse_name,
             shed_id,
             shed_name,
             conc_base_qty_unit_id,
             conc_base_qty_unit,
             pay_cur_id,
             pay_cur_code,
             parent_internal_gmr_ref_no,
             is_new,
             mtd_ytd,
             feeding_point_id,
             feeding_point_name;
   
    commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert FC MTD Delta Over'); 

 -- 
 -- For all GMRs with Assay Updated MTD = Y pull the data from FCEO
 --
 delete from fceot_fceo_temp where corporate_id = pc_corporate_id;
 commit;
 
 --
-- Previous  EOD Detail Data for Assay Change 
--

 insert into fceot_fceo_temp
   (corporate_id,
    process_id,
    internal_gmr_ref_no,
    element_id,
    element_name,
    assay_qty,
    asaay_qty_unit_id,
    asaay_qty_unit,
    payable_qty,
    payable_qty_unit_id,
    payable_qty_unit,
    underlying_product_id,
    underlying_base_qty_unit_id,
    payable_returnable_type,
    rc_amount,
    penality_amount,
    parent_internal_gmr_ref_no,
    mtd_ytd,
    section_name,
    qty_type,
    payable_amt_price_ccy,
    payable_amt_pay_ccy,
    base_tc_charges_amt,
    esc_desc_tc_charges_amt,
    element_base_qty_unit_id,
    element_base_qty_unit)
   select pc_corporate_id,
          pc_process_id,
          fceo_prev.internal_gmr_ref_no,
          fceo_prev.element_id,
          fceo_prev.element_name,
          -1 * sum(fceo_prev.assay_qty),
          fceo_prev.asaay_qty_unit_id,
          fceo_prev.asaay_qty_unit,
         -1 *  sum(fceo_prev.payable_qty),
          fceo_prev.payable_qty_unit_id,
          fceo_prev.payable_qty_unit,
          fceo_prev.underlying_product_id,
          fceo_prev.underlying_base_qty_unit_id,
          fceo_prev.payable_returnable_type,
         -1 *  sum(fceo_prev.rc_charges_amt),
         -1 *  sum(fceo_prev.pc_charges_amt),
          fceo_prev.parent_internal_gmr_ref_no,
          'MTD' mtd_ytd, --mtd_ytd,
          fceo_prev.section_name,
          fceo_prev.qty_type,
         -1 *  sum(fceo_prev.payable_amt_price_ccy),
         -1 *  sum(fceo_prev.payable_amt_pay_ccy),
         -1 *  sum(fceo_prev.base_tc_charges_amt),
         -1 *  sum(fceo_prev.esc_desc_tc_charges_amt),
          fceo_prev.element_base_qty_unit_id,
          fceo_prev.element_base_qty_unit
     from fceo_feed_con_element_original fceo_prev
    where (fceo_prev.internal_gmr_ref_no, fceo_prev.process_id) in
          (select fcg.internal_gmr_ref_no,
                  fcg.prev_process_id
             from fcg_feed_consumption_gmr fcg
            where fcg.process_id = pc_process_id
              and fcg.mtd_ytd = 'MTD')
    group by fceo_prev.internal_gmr_ref_no,
             fceo_prev.element_id,
             fceo_prev.element_name,
             fceo_prev.asaay_qty_unit_id,
             fceo_prev.asaay_qty_unit,
             fceo_prev.payable_qty_unit_id,
             fceo_prev.payable_qty_unit,
             fceo_prev.underlying_product_id,
             fceo_prev.underlying_base_qty_unit_id,
             fceo_prev.payable_returnable_type,
             fceo_prev.parent_internal_gmr_ref_no,
             fceo_prev.section_name,
             fceo_prev.qty_type,
             fceo_prev.element_base_qty_unit_id,
             fceo_prev.element_base_qty_unit;
  
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert FCEOT_FCEO_TEMP MTD Delta Over 1');   
 
 --
-- Current  EOD Detail Data for Assay Change 
--

 insert into fceot_fceo_temp
   (corporate_id,
    process_id,
    internal_gmr_ref_no,
    element_id,
    element_name,
    assay_qty,
    asaay_qty_unit_id,
    asaay_qty_unit,
    payable_qty,
    payable_qty_unit_id,
    payable_qty_unit,
    underlying_product_id,
    underlying_base_qty_unit_id,
    payable_returnable_type,
    rc_amount,
    penality_amount,
    parent_internal_gmr_ref_no,
    mtd_ytd,
    section_name,
    qty_type,
    payable_amt_price_ccy,
    payable_amt_pay_ccy,
    base_tc_charges_amt,
    esc_desc_tc_charges_amt,
    element_base_qty_unit_id,
    element_base_qty_unit)
   select pc_corporate_id,
          pc_process_id,
          fceo_current.internal_gmr_ref_no,
          fceo_current.element_id,
          fceo_current.element_name,
          sum(fceo_current.assay_qty),
          fceo_current.asaay_qty_unit_id,
          fceo_current.asaay_qty_unit,
          sum(fceo_current.payable_qty),
          fceo_current.payable_qty_unit_id,
          fceo_current.payable_qty_unit,
          fceo_current.underlying_product_id,
          fceo_current.underlying_base_qty_unit_id,
          fceo_current.payable_returnable_type,
          sum(fceo_current.rc_charges_amt),
          sum(fceo_current.pc_charges_amt),
          fceo_current.parent_internal_gmr_ref_no,
          'MTD' mtd_ytd, --mtd_ytd,
          fceo_current.section_name,
          fceo_current.qty_type,
          sum(fceo_current.payable_amt_price_ccy),
          sum(fceo_current.payable_amt_pay_ccy),
          sum(fceo_current.base_tc_charges_amt),
          sum(fceo_current.esc_desc_tc_charges_amt),
          fceo_current.element_base_qty_unit_id,
          fceo_current.element_base_qty_unit
     from fceo_feed_con_element_original fceo_current
    where (fceo_current.internal_gmr_ref_no, fceo_current.process_id) in
          (select fcg.internal_gmr_ref_no,
                  pc_process_id
             from fcg_feed_consumption_gmr fcg
            where fcg.process_id = pc_process_id
              and fcg.mtd_ytd = 'MTD')
    group by fceo_current.internal_gmr_ref_no,
             fceo_current.element_id,
             fceo_current.element_name,
             fceo_current.asaay_qty_unit_id,
             fceo_current.asaay_qty_unit,
             fceo_current.payable_qty_unit_id,
             fceo_current.payable_qty_unit,
             fceo_current.underlying_product_id,
             fceo_current.underlying_base_qty_unit_id,
             fceo_current.payable_returnable_type,
             fceo_current.parent_internal_gmr_ref_no,
             fceo_current.section_name,
             fceo_current.qty_type,
             fceo_current.element_base_qty_unit_id,
             fceo_current.element_base_qty_unit;
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert FCEOT_FCEO_TEMP MTD Delta Over 2');              
 
insert into fce_feed_consumption_element
  (process_id,
   internal_gmr_ref_no,
   element_id,
   element_name,
   assay_qty,
   asaay_qty_unit_id,
   asaay_qty_unit,
   payable_qty,
   payable_qty_unit_id,
   payable_qty_unit,
   underlying_product_id,
   underlying_base_qty_unit_id,
   payable_returnable_type,
   rc_amount,
   penality_amount,
   parent_internal_gmr_ref_no,
   mtd_ytd,
   section_name,
   qty_type,
   payable_amt_price_ccy,
   payable_amt_pay_ccy,
   base_tc_charges_amt,
   esc_desc_tc_charges_amt,
   element_base_qty_unit_id,
   element_base_qty_unit)
  select pc_process_id,
         internal_gmr_ref_no,
         element_id,
         element_name,
         sum(assay_qty),
         asaay_qty_unit_id,
         asaay_qty_unit,
         sum(payable_qty),
         payable_qty_unit_id,
         payable_qty_unit,
         underlying_product_id,
         underlying_base_qty_unit_id,
         payable_returnable_type,
         sum(rc_amount),
         sum(penality_amount),
         parent_internal_gmr_ref_no,
         mtd_ytd,
         section_name,
         qty_type,
         sum(payable_amt_price_ccy),
         sum(payable_amt_pay_ccy),
         sum(base_tc_charges_amt),
         sum(esc_desc_tc_charges_amt),
         element_base_qty_unit_id,
         element_base_qty_unit
    from fceot_fceo_temp t
   where t.corporate_id = pc_corporate_id
   group by internal_gmr_ref_no,
            element_id,
            element_name,
            asaay_qty_unit_id,
            asaay_qty_unit,
            payable_qty_unit_id,
            payable_qty_unit,
            underlying_product_id,
            underlying_base_qty_unit_id,
            payable_returnable_type,
            parent_internal_gmr_ref_no,
            mtd_ytd,
            section_name,
            qty_type,
            element_base_qty_unit_id,
            element_base_qty_unit;
commit;
 gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert FCE MTD Delta Over');        
 
 --
 -- Populate YTD Delta Data
 -- 
 -- For all GMRs with Assay Updated YTD =Y pull the data from FCO
 --
  
 delete from fcot_fco_temp where corporate_id = pc_corporate_id;
 commit;
 gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Delete fcot_fco_temp for YTD Assay Update'); 
--
-- Previous  EOD Data for Assay Change
--
insert into fcot_fco_temp
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   gmr_ref_no,
   internal_gmr_ref_no,
   product_id,
   product_name,
   quality_id,
   quality_name,
   pile_name,
   parent_gmr_ref_no,
   warehouse_id,
   warehouse_name,
   shed_id,
   shed_name,
   grd_wet_qty,
   grd_dry_qty,
  conc_base_qty_unit_id,
   conc_base_qty_unit,
  pay_cur_id,
   pay_cur_code,
   parent_internal_gmr_ref_no,
   is_new,
   mtd_ytd,
   other_charges_amt,
   feeding_point_id,
   feeding_point_name)
  select process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         pile_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
        -1*  sum(grd_wet_qty) grd_wet_qty,
        -1*   sum(grd_dry_qty)  grd_dry_qty,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         pay_cur_id,
         pay_cur_code,
         parent_internal_gmr_ref_no,
         'N', --is_new,
         'YTD', --mtd_ytd,
         -1*  sum(other_charges_amt) other_charges_amt,
         feeding_point_id,
         feeding_point_name
    from fco_feed_consumption_original fco_prev
   where (fco_prev.internal_gmr_ref_no, fco_prev.process_id) in
         (select fcg.internal_gmr_ref_no,
                 fcg.prev_process_id
            from fcg_feed_consumption_gmr fcg
           where fcg.process_id = pc_process_id
             and fcg.mtd_ytd = 'YTD')
group by process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         pile_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         pay_cur_id,
         pay_cur_code,
         parent_internal_gmr_ref_no,
         feeding_point_id,
         feeding_point_name;
 
 commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert fcot_fco_temp for YTD Assay Update Over 1'); 

--
-- Current  EOD Data for Assay Change
--

insert into fcot_fco_temp
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   gmr_ref_no,
   internal_gmr_ref_no,
   product_id,
   product_name,
   quality_id,
   quality_name,
   pile_name,
   parent_gmr_ref_no,
   warehouse_id,
   warehouse_name,
   shed_id,
   shed_name,
   grd_wet_qty,
   grd_dry_qty,
  conc_base_qty_unit_id,
   conc_base_qty_unit,
  pay_cur_id,
   pay_cur_code,
   parent_internal_gmr_ref_no,
   is_new,
   mtd_ytd,
   other_charges_amt,
   feeding_point_id,
   feeding_point_name)
  select process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         pile_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         sum(grd_wet_qty) grd_wet_qty,
         sum(grd_dry_qty) grd_dry_qty,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         pay_cur_id,
         pay_cur_code,
         parent_internal_gmr_ref_no,
         'N', --is_new,
         'YTD', --mtd_ytd,
         sum(other_charges_amt) other_charges_amt,
         feeding_point_id,
         feeding_point_name
    from fco_feed_consumption_original fco
   where (fco.internal_gmr_ref_no, fco.process_id) in
         (select fcg.internal_gmr_ref_no,
                 pc_process_id
            from fcg_feed_consumption_gmr fcg
           where fcg.process_id = pc_process_id
             and fcg.mtd_ytd = 'YTD')
group by process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         pile_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         pay_cur_id,
         pay_cur_code,
         parent_internal_gmr_ref_no,
         feeding_point_id,
         feeding_point_name;
         
commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert fcot_fco_temp for YTD Assay Update Over 2'); 
 insert into fc_feed_consumption
   (process_id,
    eod_trade_date,
    corporate_id,
    corporate_name,
    gmr_ref_no,
    internal_gmr_ref_no,
    product_id,
    product_name,
    quality_id,
    quality_name,
    pile_name,
    parent_gmr_ref_no,
    warehouse_id,
    warehouse_name,
    shed_id,
    shed_name,
    grd_wet_qty,
    grd_dry_qty,
    conc_base_qty_unit_id,
    conc_base_qty_unit,
    pay_cur_id,
    pay_cur_code,
    parent_internal_gmr_ref_no,
    is_new,
    mtd_ytd,
    feeding_point_id,
    feeding_point_name,
    other_charges_amt)
   select pc_process_id,
          pd_trade_date,
          corporate_id,
          corporate_name,
          gmr_ref_no,
          internal_gmr_ref_no,
          product_id,
          product_name,
          quality_id,
          quality_name,
          pile_name,
          parent_gmr_ref_no,
          warehouse_id,
          warehouse_name,
          shed_id,
          shed_name,
          sum(grd_wet_qty),
          sum(grd_dry_qty),
          conc_base_qty_unit_id,
          conc_base_qty_unit,
          pay_cur_id,
          pay_cur_code,
          parent_internal_gmr_ref_no,
          is_new,
          mtd_ytd,
          feeding_point_id,
          feeding_point_name,
          sum(other_charges_amt)
     from fcot_fco_temp t
    where t.corporate_id = pc_corporate_id
    group by corporate_id,
             corporate_name,
             gmr_ref_no,
             internal_gmr_ref_no,
             product_id,
             product_name,
             quality_id,
             quality_name,
             pile_name,
             parent_gmr_ref_no,
             warehouse_id,
             warehouse_name,
             shed_id,
             shed_name,
             conc_base_qty_unit_id,
             conc_base_qty_unit,
             pay_cur_id,
             pay_cur_code,
             parent_internal_gmr_ref_no,
             is_new,
             mtd_ytd,
             feeding_point_id,
             feeding_point_name;
   
    commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert FC YTD Delta Over'); 

 -- 
 -- For all GMRs with Assay Updated YTD = Y pull the data from FCEO
 --
 delete from fceot_fceo_temp where corporate_id = pc_corporate_id;
 commit;
 
 --
-- Previous  EOD Detail Data for Assay Change 
--

 insert into fceot_fceo_temp
   (corporate_id,
    process_id,
    internal_gmr_ref_no,
    element_id,
    element_name,
    assay_qty,
    asaay_qty_unit_id,
    asaay_qty_unit,
    payable_qty,
    payable_qty_unit_id,
    payable_qty_unit,
    underlying_product_id,
    underlying_base_qty_unit_id,
    payable_returnable_type,
    rc_amount,
    penality_amount,
    parent_internal_gmr_ref_no,
    mtd_ytd,
    section_name,
    qty_type,
    payable_amt_price_ccy,
    payable_amt_pay_ccy,
    base_tc_charges_amt,
    esc_desc_tc_charges_amt,
    element_base_qty_unit_id,
    element_base_qty_unit)
 
   select pc_corporate_id,
          pc_process_id,
          fceo_prev.internal_gmr_ref_no,
          fceo_prev.element_id,
          fceo_prev.element_name,
          -1 * sum(fceo_prev.assay_qty),
          fceo_prev.asaay_qty_unit_id,
          fceo_prev.asaay_qty_unit,
          -1 *  sum(fceo_prev.payable_qty),
          fceo_prev.payable_qty_unit_id,
          fceo_prev.payable_qty_unit,
          fceo_prev.underlying_product_id,
          fceo_prev.underlying_base_qty_unit_id,
          fceo_prev.payable_returnable_type,
          -1 *  sum(fceo_prev.rc_charges_amt),
          -1 *  sum(fceo_prev.pc_charges_amt),
          fceo_prev.parent_internal_gmr_ref_no,
          'YTD' mtd_ytd, --mtd_ytd,
          fceo_prev.section_name,
          fceo_prev.qty_type,
          -1 *  sum(fceo_prev.payable_amt_price_ccy),
          -1 *  sum(fceo_prev.payable_amt_pay_ccy),
          -1 *  sum(fceo_prev.base_tc_charges_amt),
          -1 *  sum(fceo_prev.esc_desc_tc_charges_amt),
          fceo_prev.element_base_qty_unit_id,
          fceo_prev.element_base_qty_unit
     from fceo_feed_con_element_original fceo_prev
    where (fceo_prev.internal_gmr_ref_no, fceo_prev.process_id) in
          (select fcg.internal_gmr_ref_no,
                  fcg.prev_process_id
             from fcg_feed_consumption_gmr fcg
            where fcg.process_id = pc_process_id
              and fcg.mtd_ytd = 'YTD')
    group by fceo_prev.internal_gmr_ref_no,
             fceo_prev.element_id,
             fceo_prev.element_name,
             fceo_prev.asaay_qty_unit_id,
             fceo_prev.asaay_qty_unit,
             fceo_prev.payable_qty_unit_id,
             fceo_prev.payable_qty_unit,
             fceo_prev.underlying_product_id,
             fceo_prev.underlying_base_qty_unit_id,
             fceo_prev.payable_returnable_type,
             fceo_prev.parent_internal_gmr_ref_no,
             fceo_prev.section_name,
             fceo_prev.qty_type,
             fceo_prev.element_base_qty_unit_id,
             fceo_prev.element_base_qty_unit;
  
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert FCEOT_FCEO_TEMP YTD Delta Over 1');   
 
 --
-- Current  EOD Detail Data for Assay Change 
--

 insert into fceot_fceo_temp
   (corporate_id,
    process_id,
    internal_gmr_ref_no,
    element_id,
    element_name,
    assay_qty,
    asaay_qty_unit_id,
    asaay_qty_unit,
    payable_qty,
    payable_qty_unit_id,
    payable_qty_unit,
    underlying_product_id,
    underlying_base_qty_unit_id,
    payable_returnable_type,
    rc_amount,
    penality_amount,
    parent_internal_gmr_ref_no,
    mtd_ytd,
    section_name,
    qty_type,
    payable_amt_price_ccy,
    payable_amt_pay_ccy,
    base_tc_charges_amt,
    esc_desc_tc_charges_amt,
    element_base_qty_unit_id,
    element_base_qty_unit)
   select pc_corporate_id,
          pc_process_id,
          fceo_current.internal_gmr_ref_no,
          fceo_current.element_id,
          fceo_current.element_name,
          sum(fceo_current.assay_qty),
          fceo_current.asaay_qty_unit_id,
          fceo_current.asaay_qty_unit,
          sum(fceo_current.payable_qty),
          fceo_current.payable_qty_unit_id,
          fceo_current.payable_qty_unit,
          fceo_current.underlying_product_id,
          fceo_current.underlying_base_qty_unit_id,
          fceo_current.payable_returnable_type,
          sum(fceo_current.rc_charges_amt),
          sum(fceo_current.pc_charges_amt),
          fceo_current.parent_internal_gmr_ref_no,
          'YTD' mtd_ytd, --mtd_ytd,
          fceo_current.section_name,
          fceo_current.qty_type,
          sum(fceo_current.payable_amt_price_ccy),
          sum(fceo_current.payable_amt_pay_ccy),
          sum(fceo_current.base_tc_charges_amt),
          sum(fceo_current.esc_desc_tc_charges_amt),
          fceo_current.element_base_qty_unit_id,
          fceo_current.element_base_qty_unit
     from fceo_feed_con_element_original fceo_current
    where (fceo_current.internal_gmr_ref_no, fceo_current.process_id) in
          (select fcg.internal_gmr_ref_no,
                  pc_process_id
             from fcg_feed_consumption_gmr fcg
            where fcg.process_id = pc_process_id
              and fcg.mtd_ytd = 'YTD')
    group by fceo_current.internal_gmr_ref_no,
             fceo_current.element_id,
             fceo_current.element_name,
             fceo_current.asaay_qty_unit_id,
             fceo_current.asaay_qty_unit,
             fceo_current.payable_qty_unit_id,
             fceo_current.payable_qty_unit,
             fceo_current.underlying_product_id,
             fceo_current.underlying_base_qty_unit_id,
             fceo_current.payable_returnable_type,
             fceo_current.parent_internal_gmr_ref_no,
             fceo_current.section_name,
             fceo_current.qty_type,
             fceo_current.element_base_qty_unit_id,
             fceo_current.element_base_qty_unit;
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert FCEOT_FCEO_TEMP YTD Delta Over 2');              
 
insert into fce_feed_consumption_element
  (process_id,
   internal_gmr_ref_no,
   element_id,
   element_name,
   assay_qty,
   asaay_qty_unit_id,
   asaay_qty_unit,
   payable_qty,
   payable_qty_unit_id,
   payable_qty_unit,
   underlying_product_id,
   underlying_base_qty_unit_id,
   payable_returnable_type,
   rc_amount,
   penality_amount,
   parent_internal_gmr_ref_no,
   mtd_ytd,
   section_name,
   qty_type,
   payable_amt_price_ccy,
   payable_amt_pay_ccy,
   base_tc_charges_amt,
   esc_desc_tc_charges_amt,
   element_base_qty_unit_id,
   element_base_qty_unit)
  select pc_process_id,
         internal_gmr_ref_no,
         element_id,
         element_name,
         sum(assay_qty),
         asaay_qty_unit_id,
         asaay_qty_unit,
         sum(payable_qty),
         payable_qty_unit_id,
         payable_qty_unit,
         underlying_product_id,
         underlying_base_qty_unit_id,
         payable_returnable_type,
         sum(rc_amount),
         sum(penality_amount),
         parent_internal_gmr_ref_no,
         mtd_ytd,
         section_name,
         qty_type,
         sum(payable_amt_price_ccy),
         sum(payable_amt_pay_ccy),
         sum(base_tc_charges_amt),
         sum(esc_desc_tc_charges_amt),
         element_base_qty_unit_id,
         element_base_qty_unit
    from fceot_fceo_temp t
   where t.corporate_id = pc_corporate_id
   group by internal_gmr_ref_no,
            element_id,
            element_name,
            asaay_qty_unit_id,
            asaay_qty_unit,
            payable_qty_unit_id,
            payable_qty_unit,
            underlying_product_id,
            underlying_base_qty_unit_id,
            payable_returnable_type,
            parent_internal_gmr_ref_no,
            mtd_ytd,
            section_name,
            qty_type,
            element_base_qty_unit_id,
            element_base_qty_unit;
commit;
 gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'Insert FCE YTD Delta Over');   
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_feedconsumption_report',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           '',
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
      commit;
  end;
procedure sp_closing_balance_report(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_process_id   varchar2,
                                    pc_process      varchar2,
                                    pc_dbd_id       varchar2) as
  cursor cur_closing is
  
    select t.gmr_ref_no,
           t.internal_gmr_ref_no,
           t.internal_grd_ref_no,
           t.internal_stock_ref_no,
           t.parent_internal_grd_ref_no,
           t.parent_internal_gmr_ref_no,
           t.is_internal_movement,            
           t.corporate_id,
           t.corporate_name,
           t.warehouse_profile_id,
           t.warehouse_name companyname,
           t.shed_id,
           t.shed_name storage_location_name,
           t.product_id,
           t.product_desc,
           t.quality_id,
           t.quality_name,
           t.wet_qty,
           t.dry_qty,
           t.qty_unit_id,
           t.qty_unit,
           t.element_id,
           t.element_name attribute_name,
           t.underlying_product_id,
           t.underlying_product_name,
           t.underlying_base_qty_unit_id base_quantity_unit_id,
           t.underlying_base_qty_unit base_quantity_unit,
           t.assay_qty,
           t.assay_qty_unit_id,
           t.assay_qty_unit,
           t.payable_qty,
           t.payable_qty_unit_id,
           t.payable_qty_unit,
           t.pool_name,
           dense_rank() over(partition by t.internal_grd_ref_no order by t.element_id) ele_rank,
           t.ash_id,
           t.pcdi_id,
           t.pay_cur_id,
           t.pay_cur_code,
           t.pay_cur_decimal,
           t.qty_type,
           t.conc_base_qty_unit_id,
           t.conc_base_qty_unit,
           t.gmr_ref_no_for_price,
           t.section_name,
           t.grd_to_gmr_qty_factor
      from cbt_cb_temp t
      where t.corporate_id = pc_corporate_id;

  vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count           number := 1;
  vn_rno                       number;
  vn_wet_qty                    number;
  vn_dry_qty                    number;
  vc_corporate_name             varchar2(100);
  vn_spq_qty_conv_factor        number;
  vn_assay_qty                  number;
  vn_payable_qty                number;
  vn_gmr_price                  number;
  vc_gmr_price_untit_id         varchar2(15);
  vc_price_unit_weight_unit_id  varchar2(15);
  vn_gmr_price_unit_weight      number;
  vc_gmr_price_unit_cur_id      varchar2(15);
  vc_gmr_price_unit_cur_code    varchar2(15);
  vn_payable_amt_in_price_cur   number;
  vn_payable_amt_in_pay_cur     number;
  vc_price_cur_id               varchar2(15);
  vc_price_cur_code             varchar2(15);
  vn_cont_price_cur_id_factor   number;
  vn_cont_price_cur_decimals    number;
  vn_fx_rate_price_to_pay       number;
  vn_payable_to_price_wt_factor number;
  vn_gmr_refine_charge          number;
  vn_gmr_penality_charge        number;
  vn_gmr_base_tc                number;
  vn_gmr_esc_descalator_tc      number;
  vn_gmr_total_tc               number;

begin
select akc.corporate_name
  into vc_corporate_name
  from ak_corporate akc
 where akc.corporate_id = pc_corporate_id;

  vn_rno := 0;
  delete from temp_stock_latest_assay where corporate_id = pc_corporate_id;
  commit;
gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'CB Delete TEMP_STOCK_LATEST_ASSAY Over');    
  -- For records with Pricing Assay
  insert into temp_stock_latest_assay
    (corporate_id,
     internal_gmr_ref_no,
     internal_grd_ref_no,
     element_id,
     latest_ash_id)
    select gmr.corporate_id,
           gmr.internal_gmr_ref_no,
           grd.internal_grd_ref_no,
           spq.element_id,
           ash_pricing.ash_id latest_ash_id
      from grd_goods_record_detail   grd,
           gmr_goods_movement_record gmr,
           sam_stock_assay_mapping   sam,
           ash_assay_header          ash,
           spq_stock_payable_qty     spq,
           ash_assay_header          ash_pricing,
           asm_assay_sublot_mapping  asm
     where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
       and sam.internal_grd_ref_no = grd.internal_grd_ref_no
       and spq.is_active = 'Y'
       and gmr.is_deleted = 'N'
       and grd.status = 'Active'
       and spq.is_stock_split = 'N'
       and sam.ash_id = ash.ash_id
       and ash.internal_grd_ref_no = spq.internal_grd_ref_no
       and spq.assay_header_id = ash_pricing.pricing_assay_ash_id
       and ash_pricing.assay_type = 'Weighted Avg Pricing Assay'
       and spq.process_id = pc_process_id
       and grd.process_id = pc_process_id
       and gmr.process_id = pc_process_id
       and gmr.corporate_id = pc_corporate_id
       and asm.ash_id = ash_pricing.ash_id
     group by gmr.corporate_id,
              gmr.internal_gmr_ref_no,
              grd.internal_grd_ref_no,
              spq.element_id,
              ash_pricing.ash_id;
commit;
gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'CB Insert TEMP_STOCK_LATEST_ASSAY 1 Over');  
-- Records with No Pricing Assay, Consider Shipment Assay
insert into temp_stock_latest_assay
  (corporate_id,
   internal_gmr_ref_no,
   internal_grd_ref_no,
   element_id,
   latest_ash_id)
  select gmr.corporate_id,
         gmr.internal_gmr_ref_no,
         grd.internal_grd_ref_no,
         spq.element_id,
         ash.ash_id latest_ash_id
    from grd_goods_record_detail   grd,
         gmr_goods_movement_record gmr,
         sam_stock_assay_mapping   sam,
         ash_assay_header          ash,
         spq_stock_payable_qty     spq,
         asm_assay_sublot_mapping  asm
   where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     and sam.internal_grd_ref_no = grd.internal_grd_ref_no
     and spq.is_active = 'Y'
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and spq.is_stock_split = 'N'
     and sam.ash_id = ash.ash_id
     and ash.internal_grd_ref_no = spq.internal_grd_ref_no
     and spq.weg_avg_pricing_assay_id = ash.ash_id
     and ash.assay_type = 'Shipment Assay'
     and spq.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and gmr.process_id = pc_process_id
     and asm.ash_id = ash.ash_id
     and not exists
   (select *
            from temp_stock_latest_assay t
           where t.internal_gmr_ref_no = gmr.internal_gmr_ref_no
             and t.internal_grd_ref_no = grd.internal_grd_ref_no
             and t.element_id = spq.element_id
             and t.corporate_id = pc_corporate_id)
   group by gmr.corporate_id,
            gmr.internal_gmr_ref_no,
            grd.internal_grd_ref_no,
            spq.element_id,
            ash.ash_id;
       commit;
gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'CB Insert TEMP_STOCK_LATEST_ASSAY 2 Over');       
delete from cbt_cb_temp t
where t.corporate_id = pc_corporate_id;
commit;
gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'CB Delete CBT_CB_TEMP Over');
--
-- Internal Movement payable elements
--
insert into cbt_cb_temp
  (gmr_ref_no,
   internal_gmr_ref_no,
   internal_grd_ref_no,
   internal_stock_ref_no,
   parent_internal_grd_ref_no,
   parent_internal_gmr_ref_no,
   is_internal_movement,
   corporate_id,
   corporate_name,
   warehouse_profile_id,
   warehouse_name,
   shed_id,
   shed_name,
   product_id,
   product_desc,
   quality_id,
   quality_name,
   wet_qty,
   dry_qty,
   qty_unit_id,
   qty_unit,
   element_id,
   element_name,
   underlying_product_id,
   underlying_product_name,
   underlying_base_qty_unit_id,
   underlying_base_qty_unit,
   assay_qty,
   assay_qty_unit_id,
   assay_qty_unit,
   payable_qty,
   payable_qty_unit_id,
   payable_qty_unit,
   pool_name,
   ash_id,
   pcdi_id,
   pay_cur_id,
   pay_cur_code,
   pay_cur_decimal,
   qty_type,
   conc_base_qty_unit_id,
   conc_base_qty_unit,
   gmr_ref_no_for_price,
   grd_to_gmr_qty_factor,
   section_name)
    select gmr.gmr_ref_no,
         gmr.internal_gmr_ref_no,
         grd.internal_grd_ref_no,
         grd.internal_stock_ref_no,
         grd.parent_internal_grd_ref_no,
         grd_parent.internal_gmr_ref_no parent_internal_gmr_ref_no,
         'Y' is_internal_movement,
         gmr.corporate_id,
         vc_corporate_name,
         gmr.warehouse_profile_id,
         gmr.warehouse_name companyname,
         gmr.shed_id,
         gmr.shed_name storage_location_name,
         grd.product_id,
         grd.product_name product_desc,
         grd.quality_id,
         grd.quality_name,
         grd.current_qty wet_qty,
         (grd.current_qty * asm.dry_wet_qty_ratio / 100) dry_qty,
         grd.qty_unit_id qty_unit_id,
         grd.qty_unit qty_unit,
         aml.element_id,
         aml.element_name,
         aml.underlying_product_id,
         aml.underlying_product_name underlying_product_name,
         aml.underlying_base_qty_unit_id base_quantity_unit_id,
         aml.underlying_base_qty_unit base_quantity_unit,
         (case
           when rm.ratio_name = '%' then
            ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
            (pqca.typical / 100))
           else
            (((grd.current_qty * (asm.dry_wet_qty_ratio / 100))) *
            pqca.typical)
         end) assay_qty,
         (case
           when rm.ratio_name = '%' then
            grd.qty_unit_id
           else
            rm.qty_unit_id_numerator
         end) assay_qty_unit_id,
         qum.qty_unit assay_qty_unit,
         (case
           when rm.ratio_name = '%' then
            ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
            (pqcapd.payable_percentage / 100))
           else
            ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
            pqcapd.payable_percentage)
         end) payable_qty,
         (case
           when rm.ratio_name = '%' then
            grd.qty_unit_id
           else
            rm.qty_unit_id_numerator
         end) payable_qty_unit_id,
         qum.qty_unit payable_qty_unit,
         grd.pool_name,
         ash_pricing.ash_id,
         grd.pcdi_id,
         gmr.invoice_cur_id pay_cur_id,
         gmr.invoice_cur_code pay_cur_code,
         gmr.invoice_cur_decimals pay_cur_decimal,
         'Payable' qty_type,
         grd.base_qty_unit_id conc_base_qty_unit_id,
         grd.base_qty_unit conc_base_qty_unit,
         grd.supp_internal_gmr_ref_no gmr_ref_no_for_price,
         nvl(grd.grd_to_gmr_qty_factor,1),
         'Non Penalty'
    from grd_goods_record_detail        grd,
         gmr_goods_movement_record      gmr,
         temp_stock_latest_assay        tspq,
         ash_assay_header               ash_pricing,
         asm_assay_sublot_mapping       asm,
         eud_element_underlying_details aml,
         pqca_pq_chemical_attributes    pqca,
         pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
         rm_ratio_master                rm,
         qum_quantity_unit_master       qum,
         grd_goods_record_detail        grd_parent
   where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     and gmr.is_internal_movement = 'Y'
     and gmr.is_deleted = 'N'
     and grd.status = 'Active'
     and grd.internal_grd_ref_no = tspq.internal_grd_ref_no
     and gmr.corporate_id = tspq.corporate_id
     and gmr.internal_gmr_ref_no = tspq.internal_gmr_ref_no
     and tspq.element_id = aml.element_id
     and pqca.element_id = tspq.element_id
     and tspq.latest_ash_id = ash_pricing.ash_id
     and asm.ash_id = ash_pricing.ash_id
     and asm.asm_id = pqca.asm_id
     and pqca.unit_of_measure = rm.ratio_id
     and pqca.pqca_id = pqcapd.pqca_id
     and grd.current_qty <> 0
     and grd.tolling_stock_type in ('None Tolling')
     and qum.qty_unit_id =
         (case when rm.ratio_name = '%' then grd.qty_unit_id else
          rm.qty_unit_id_numerator end)
     and gmr.eff_date <= pd_trade_date
     and rm.is_active = 'Y'
     and pqca.is_active = 'Y'
     and pqcapd.is_active = 'Y'
     and gmr.process_id = pc_process_id
     and grd.process_id = pc_process_id
     and grd.parent_internal_grd_ref_no = grd_parent.internal_grd_ref_no(+)
     and grd_parent.process_id(+) = pc_process_id;
    commit;
gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'CB Insert CBT_CB_TEMP Payable IM Over');    
    --
    -- Internal Movement penality elements
    --
  insert into cbt_cb_temp
    (gmr_ref_no,
     internal_gmr_ref_no,
     internal_grd_ref_no,
     internal_stock_ref_no,
     parent_internal_grd_ref_no,
     parent_internal_gmr_ref_no,
     is_internal_movement,
     corporate_id,
     corporate_name,
     warehouse_profile_id,
     warehouse_name,
     shed_id,
     shed_name,
     product_id,
     product_desc,
     quality_id,
     quality_name,
     wet_qty,
     dry_qty,
     qty_unit_id,
     qty_unit,
     element_id,
     element_name,
     underlying_product_id,
     underlying_product_name,
     underlying_base_qty_unit_id,
     underlying_base_qty_unit,
     assay_qty,
     assay_qty_unit_id,
     assay_qty_unit,
     payable_qty,
     payable_qty_unit_id,
     payable_qty_unit,
     pool_name,
     ash_id,
     pcdi_id,
     pay_cur_id,
     pay_cur_code,
     pay_cur_decimal,
     qty_type,
     conc_base_qty_unit_id,
     conc_base_qty_unit,
     gmr_ref_no_for_price,
     grd_to_gmr_qty_factor,
     section_name)
    select gmr.gmr_ref_no,
           gmr.internal_gmr_ref_no,
           grd.internal_grd_ref_no,
           grd.internal_stock_ref_no,
           grd.parent_internal_grd_ref_no,
           grd_parent.internal_gmr_ref_no parent_internal_gmr_ref_no,
           'Y' is_internal_movement,
           gmr.corporate_id,
           vc_corporate_name,
           gmr.warehouse_profile_id,
           gmr.warehouse_name companyname,
           gmr.shed_id,
           gmr.shed_name storage_location_name,
           grd.product_id,
           grd.product_name product_desc,
           grd.quality_id,
           grd.quality_name,
           grd.current_qty wet_qty,
           (grd.current_qty * asm.dry_wet_qty_ratio / 100) dry_qty,
           grd.qty_unit_id qty_unit_id,
           grd.qty_unit qty_unit,
           pqca.element_id,
           aml.attribute_name,
           null underlying_product_id,
           null underlying_product_name,
           null base_quantity_unit_id,
           null base_quantity_unit,
           (case
             when rm.ratio_name = '%' then
              ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
              (pqca.typical / 100))
             else
              (((grd.current_qty * (asm.dry_wet_qty_ratio / 100))) *
              pqca.typical)
           end) assay_qty,
           (case
             when rm.ratio_name = '%' then
              grd.qty_unit_id
             else
              rm.qty_unit_id_numerator
           end) assay_qty_unit_id,
           qum.qty_unit assay_qty_unit,
           null payable_qty,
           null payable_qty_unit_id,
           null payable_qty_unit,
           grd.pool_name,
           ash_pricing.ash_id,
           grd.pcdi_id,
           gmr.invoice_cur_id pay_cur_id,
           gmr.invoice_cur_code pay_cur_code,
           gmr.invoice_cur_decimals pay_cur_decimal,
           null qty_type,
           grd.base_qty_unit_id conc_base_qty_unit_id,
           grd.base_qty_unit conc_base_qty_unit,
           grd.supp_internal_gmr_ref_no gmr_ref_no_for_price,
           nvl(grd.grd_to_gmr_qty_factor,1),
           'Penalty'
      from grd_goods_record_detail     grd,
           gmr_goods_movement_record   gmr,
           sam_stock_assay_mapping     sam,
           ash_assay_header            ash,
           ash_assay_header            ash_pricing,
           asm_assay_sublot_mapping    asm,
           aml_attribute_master_list   aml,
           pqca_pq_chemical_attributes pqca,
           rm_ratio_master             rm,
           qum_quantity_unit_master    qum,
           grd_goods_record_detail     grd_parent
     where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
       and gmr.is_internal_movement = 'Y'
       and gmr.is_deleted = 'N'
       and grd.status = 'Active'
       and sam.internal_grd_ref_no = grd.internal_grd_ref_no
       and sam.is_active = 'Y'
       and sam.ash_id = ash.ash_id
       and ash.assay_type = 'Pricing Assay'
       and grd.assay_header_id = ash.ash_id
       and ash.internal_grd_ref_no = grd.internal_grd_ref_no
       and grd.assay_header_id = ash_pricing.pricing_assay_ash_id
       and ash_pricing.assay_type = 'Weighted Avg Pricing Assay'
       and asm.ash_id = ash_pricing.ash_id
       and asm.asm_id = pqca.asm_id
       and pqca.is_elem_for_pricing = 'N'
       and pqca.element_id = aml.attribute_id
       and pqca.unit_of_measure = rm.ratio_id
       and qum.qty_unit_id =
           (case when rm.ratio_name = '%' then grd.qty_unit_id else
            rm.qty_unit_id_numerator end)
      and gmr.eff_date <= pd_trade_date
       and rm.is_active = 'Y'
       and aml.is_active = 'Y'
       and pqca.is_active = 'Y'
       and grd.current_qty <> 0
       and grd.tolling_stock_type in ('None Tolling')
       and gmr.process_id = pc_process_id
       and grd.process_id = pc_process_id
       and grd.parent_internal_grd_ref_no =
           grd_parent.internal_grd_ref_no(+)
       and grd_parent.process_id(+) = pc_process_id;
commit;
gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'CB Insert CBT_CB_TEMP Penalty IM Over');
--
-- all supplier stocks payable elements
--
    insert into cbt_cb_temp
      (gmr_ref_no,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       internal_stock_ref_no,
       parent_internal_grd_ref_no,
       parent_internal_gmr_ref_no,
       is_internal_movement,
       corporate_id,
       corporate_name,
       warehouse_profile_id,
       warehouse_name,
       shed_id,
       shed_name,
       product_id,
       product_desc,
       quality_id,
       quality_name,
       wet_qty,
       dry_qty,
       qty_unit_id,
       qty_unit,
       element_id,
       element_name,
       underlying_product_id,
       underlying_product_name,
       underlying_base_qty_unit_id,
       underlying_base_qty_unit,
       assay_qty,
       assay_qty_unit_id,
       assay_qty_unit,
       payable_qty,
       payable_qty_unit_id,
       payable_qty_unit,
       pool_name,
       ash_id,
       pcdi_id,
       pay_cur_id,
       pay_cur_code,
       pay_cur_decimal,
       qty_type,
       conc_base_qty_unit_id,
       conc_base_qty_unit,
       gmr_ref_no_for_price,
       grd_to_gmr_qty_factor,
       section_name)
      select gmr.gmr_ref_no,
             gmr.internal_gmr_ref_no,
             grd.internal_grd_ref_no,
             grd.internal_stock_ref_no,
             grd.internal_grd_ref_no parent_internal_grd_ref_no,
             gmr.internal_gmr_ref_no parent_internal_gmr_ref_no,
             'N' is_internal_movement,
             gmr.corporate_id,
             vc_corporate_name,
             gmr.warehouse_profile_id,
             gmr.warehouse_name companyname,
             gmr.shed_id,
             gmr.shed_name storage_location_name,
             grd.product_id,
             grd.product_name product_desc,
             grd.quality_id,
             grd.quality_name,
             grd.current_qty wet_qty,
             (grd.current_qty * asm.dry_wet_qty_ratio / 100) dry_qty,
             grd.qty_unit_id qty_unit_id,
             grd.qty_unit qty_unit,
             tspq.element_id,
             aml.element_name attribute_name,
             aml.underlying_product_id,
             aml.underlying_product_name underlying_product_name,
             aml.underlying_base_qty_unit_id base_quantity_unit_id,
             aml.underlying_base_qty_unit base_quantity_unit,
             (case
               when rm.ratio_name = '%' then
                ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                (pqca.typical / 100))
               else
                (((grd.current_qty * (asm.dry_wet_qty_ratio / 100))) *
                pqca.typical)
             end) assay_qty,
             (case
               when rm.ratio_name = '%' then
                grd.qty_unit_id
               else
                rm.qty_unit_id_numerator
             end) assay_qty_unit_id,
             qum.qty_unit assay_qty_unit,
             (case
               when rm.ratio_name = '%' then
                ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                (pqcapd.payable_percentage / 100))
               else
                ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                pqcapd.payable_percentage)
             end) payable_qty,
             (case
               when rm.ratio_name = '%' then
                grd.qty_unit_id
               else
                rm.qty_unit_id_numerator
             end) payable_qty_unit_id,
             qum.qty_unit payable_qty_unit,
             grd.parent_grd_pool_name pool_name,
             ash.ash_id,
             grd.pcdi_id,
             gmr.invoice_cur_id pay_cur_id,
             gmr.invoice_cur_code pay_cur_code,
             gmr.invoice_cur_decimals pay_cur_decimal,
             'Payable' qty_type,
             grd.base_qty_unit_id conc_base_qty_unit_id,
             grd.base_qty_unit conc_base_qty_unit,
             gmr.internal_gmr_ref_no gmr_ref_no_for_price,
             nvl(grd_to_gmr_qty_factor,1),
             'Non Penalty'
        from gmr_goods_movement_record      gmr,
             grd_goods_record_detail        grd,
             temp_stock_latest_assay        tspq,
             ash_assay_header               ash,
             asm_assay_sublot_mapping       asm,
             eud_element_underlying_details aml,
             pqca_pq_chemical_attributes    pqca,
             pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
             rm_ratio_master                rm,
             qum_quantity_unit_master       qum
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and gmr.is_deleted = 'N'
         and grd.status = 'Active'
         and gmr.is_internal_movement = 'N'
         and ash.ash_id = asm.ash_id
         and tspq.corporate_id = gmr.corporate_id
         and tspq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and tspq.internal_grd_ref_no = grd.internal_grd_ref_no
         and tspq.element_id = aml.element_id
         and tspq.element_id = pqca.element_id
         and tspq.latest_ash_id = ash.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.pqca_id = pqcapd.pqca_id
         and qum.qty_unit_id =
             (case when rm.ratio_name = '%' then grd.qty_unit_id else
              rm.qty_unit_id_denominator end)
         and grd.current_qty <> 0
         and grd.tolling_stock_type in ('None Tolling')
         and rm.is_active = 'Y'
         and pqca.is_active = 'Y'
         and pqcapd.is_active = 'Y'
         and gmr.eff_date <= pd_trade_date
         and gmr.process_id = pc_process_id
         and grd.process_id = pc_process_id;
     commit;       
gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'CB Insert CBT_CB_TEMP Payable Over');
--
-- all supplier stocks penality elements
--
insert into cbt_cb_temp
      (gmr_ref_no,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       internal_stock_ref_no,
       parent_internal_grd_ref_no,
       parent_internal_gmr_ref_no,
       is_internal_movement,
       corporate_id,
       corporate_name,
       warehouse_profile_id,
       warehouse_name,
       shed_id,
       shed_name,
       product_id,
       product_desc,
       quality_id,
       quality_name,
       wet_qty,
       dry_qty,
       qty_unit_id,
       qty_unit,
       element_id,
       element_name,
       underlying_product_id,
       underlying_product_name,
       underlying_base_qty_unit_id,
       underlying_base_qty_unit,
       assay_qty,
       assay_qty_unit_id,
       assay_qty_unit,
       payable_qty,
       payable_qty_unit_id,
       payable_qty_unit,
       pool_name,
       ash_id,
       pcdi_id,
       pay_cur_id,
       pay_cur_code,
       pay_cur_decimal,
       qty_type,
       conc_base_qty_unit_id,
       conc_base_qty_unit,
       gmr_ref_no_for_price,
       grd_to_gmr_qty_factor,
       section_name)
            select gmr.gmr_ref_no,
                   gmr.internal_gmr_ref_no,
                   grd.internal_grd_ref_no,
                   grd.internal_stock_ref_no,
                   grd.internal_grd_ref_no parent_internal_grd_ref_no,
                   gmr.internal_gmr_ref_no parent_internal_gmr_ref_no,
                   'N' is_internal_movement, 
                   gmr.corporate_id,
                   vc_corporate_name,
                   gmr.warehouse_profile_id,
                   gmr.warehouse_name companyname,
                   gmr.shed_id,
                   gmr.shed_name storage_location_name,
                   grd.product_id,
                   grd.product_name product_desc,
                   grd.quality_id,
                   grd.quality_name,
                   grd.current_qty wet_qty,
                   (grd.current_qty * asm.dry_wet_qty_ratio / 100) dry_qty,
                   grd.qty_unit_id qty_unit_id,
                   grd.qty_unit qty_unit,
                   pqca.element_id,
                   aml.attribute_name,
                   null underlying_product_id,
                   null underlying_product_name,
                   null base_quantity_unit_id,
                   null base_quantity_unit,
                   (case
                     when rm.ratio_name = '%' then
                      ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                      (pqca.typical / 100))
                     else
                      (((grd.current_qty * (asm.dry_wet_qty_ratio / 100))) *
                      pqca.typical)
                   end) assay_qty,
                   (case
                     when rm.ratio_name = '%' then
                      grd.qty_unit_id
                     else
                      rm.qty_unit_id_numerator
                   end) assay_qty_unit_id,
                   qum.qty_unit assay_qty_unit,
                   null payable_qty,
                   null payable_qty_unit_id,
                   null payable_qty_unit,
                   grd.parent_grd_pool_name pool_name,
                   ash.ash_id,
                   grd.pcdi_id,
                   gmr.invoice_cur_id pay_cur_id,
                   gmr.invoice_cur_code pay_cur_code,
                   gmr.invoice_cur_decimals pay_cur_decimal,
                   null qty_type,
                   grd.base_qty_unit_id conc_base_qty_unit_id,
                   grd.base_qty_unit conc_base_qty_unit,
                   gmr.internal_gmr_ref_no gmr_ref_no_for_price,
                   nvl(grd_to_gmr_qty_factor,1),
                   'Penalty'
              from gmr_goods_movement_record gmr,
                   grd_goods_record_detail grd,
                   ash_assay_header ash,
                   asm_assay_sublot_mapping asm,
                   pqca_pq_chemical_attributes pqca,
                   aml_attribute_master_list aml,
                   rm_ratio_master rm,
                   qum_quantity_unit_master qum
             where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
               and gmr.is_deleted = 'N'
               and grd.status = 'Active'
               and grd.current_qty <> 0
               and grd.tolling_stock_type in ('None Tolling')
                and ash.is_active = 'Y'
               and asm.is_active = 'Y'
               and ash.pricing_assay_ash_id = grd.assay_header_id
               and ash.assay_type = 'Weighted Avg Pricing Assay'
               and ash.ash_id = asm.ash_id
               and asm.asm_id = pqca.asm_id
               and pqca.is_elem_for_pricing = 'N'
               and pqca.element_id = aml.attribute_id
               and pqca.unit_of_measure = rm.ratio_id
               and qum.qty_unit_id = (case when rm.ratio_name = '%' then grd.qty_unit_id else
                    rm.qty_unit_id_denominator end)
               and rm.is_active = 'Y'
               and aml.is_active = 'Y'
               and pqca.is_active = 'Y'
               and gmr.eff_date <= pd_trade_date
               and gmr.process_id = pc_process_id
               and grd.process_id = pc_process_id;
                                               
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'CB Insert CBT_CB_TEMP Penalty Over');          
  for cur_closing_rows in cur_closing
  loop
    vn_rno                       := vn_rno + 1;
    vn_wet_qty := pkg_general.f_get_converted_quantity(cur_closing_rows.product_id,
                                                       cur_closing_rows.qty_unit_id,
                                                       cur_closing_rows.conc_base_qty_unit_id,
                                                       cur_closing_rows.wet_qty);
    vn_dry_qty := pkg_general.f_get_converted_quantity(cur_closing_rows.product_id,
                                                       cur_closing_rows.qty_unit_id,
                                                       cur_closing_rows.conc_base_qty_unit_id,
                                                       cur_closing_rows.dry_qty);
  
    if cur_closing_rows.qty_type in ('Payable', 'Returnable') then
    
      vn_assay_qty   := pkg_general.f_get_converted_quantity(cur_closing_rows.underlying_product_id,
                                                             cur_closing_rows.assay_qty_unit_id,
                                                             cur_closing_rows.base_quantity_unit_id,
                                                             cur_closing_rows.assay_qty);
      vn_payable_qty := pkg_general.f_get_converted_quantity(cur_closing_rows.underlying_product_id,
                                                             cur_closing_rows.payable_qty_unit_id,
                                                             cur_closing_rows.base_quantity_unit_id,
                                                             cur_closing_rows.payable_qty);
    else
      vn_assay_qty   := 0;
      vn_payable_qty := 0;                                                       
    end if;
     
    if cur_closing_rows.section_name = 'Non Penalty' and
       cur_closing_rows.payable_qty <> 0 then
      begin
        select cgcp.contract_price,
               cgcp.price_unit_id,
               cgcp.price_unit_weight_unit_id,
               cgcp.price_unit_cur_id,
               cgcp.price_unit_cur_code,
               cgcp.price_unit_weight
          into vn_gmr_price,
               vc_gmr_price_untit_id,
               vc_price_unit_weight_unit_id,
               vc_gmr_price_unit_cur_id,
               vc_gmr_price_unit_cur_code,
               vn_gmr_price_unit_weight
          from cgcp_conc_gmr_cog_price cgcp
         where cgcp.internal_gmr_ref_no =
               cur_closing_rows.gmr_ref_no_for_price
           and cgcp.process_id = pc_process_id
           and cgcp.element_id = cur_closing_rows.element_id;
      exception
        when others then
          begin
            select cccp.contract_price,
                   cccp.price_unit_id,
                   cccp.price_unit_weight_unit_id,
                   cccp.price_unit_cur_id,
                   cccp.price_unit_cur_code,
                   cccp.price_unit_weight
              into vn_gmr_price,
                   vc_gmr_price_untit_id,
                   vc_price_unit_weight_unit_id,
                   vc_gmr_price_unit_cur_id,
                   vc_gmr_price_unit_cur_code,
                   vn_gmr_price_unit_weight
              from cccp_conc_contract_cog_price cccp
             where cccp.pcdi_id = cur_closing_rows.pcdi_id
               and cccp.process_id = pc_process_id
               and cccp.element_id = cur_closing_rows.element_id;
          exception
            when others then
              vn_gmr_price                 := null;
              vc_gmr_price_untit_id        := null;
              vc_price_unit_weight_unit_id := null;
              vc_gmr_price_unit_cur_id     := null;
              vc_gmr_price_unit_cur_code   := null;
          end;
        
      end;
      pkg_general.sp_get_main_cur_detail(vc_gmr_price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
      --
      -- Quantity Conversion between Payable to Price Units
      --
      if cur_closing_rows.payable_qty_unit_id <>
         vc_price_unit_weight_unit_id then
        begin
          select ucm.multiplication_factor
            into vn_payable_to_price_wt_factor
            from ucm_unit_conversion_master ucm
           where ucm.from_qty_unit_id =
                 cur_closing_rows.payable_qty_unit_id
             and ucm.to_qty_unit_id = vc_price_unit_weight_unit_id;
        exception
          when others then
            vn_payable_to_price_wt_factor := -1;
        end;
      else
        vn_payable_to_price_wt_factor := 1;
      end if;
      begin
        select cet.exch_rate
          into vn_fx_rate_price_to_pay
          from cet_corporate_exch_rate cet
         where cet.corporate_id = pc_corporate_id
           and cet.from_cur_id = vc_gmr_price_unit_cur_id
           and cet.to_cur_id = cur_closing_rows.pay_cur_id;
      exception
        when no_data_found then
          vn_fx_rate_price_to_pay := -1;
      end;
      --
      -- Calculate TC Charges, Use Dry or Wet Quantity As Configured in the Contract
      --    
      begin
        select round((case
                       when getc.weight_type = 'Dry' then
                        cur_closing_rows.dry_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                       else
                        cur_closing_rows.wet_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                     end),
                     cur_closing_rows.pay_cur_decimal),
               round((case
                       when getc.weight_type = 'Dry' then
                        cur_closing_rows.dry_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                       else
                        cur_closing_rows.wet_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                     end),
                     cur_closing_rows.pay_cur_decimal)
          into vn_gmr_base_tc,
               vn_gmr_esc_descalator_tc
          from getc_gmr_element_tc_charges getc,
               ucm_unit_conversion_master  ucm
         where getc.process_id = pc_process_id
           and getc.internal_gmr_ref_no =
               cur_closing_rows.parent_internal_gmr_ref_no
           and getc.internal_grd_ref_no =
               cur_closing_rows.parent_internal_grd_ref_no
           and getc.element_id = cur_closing_rows.element_id
           and ucm.from_qty_unit_id = cur_closing_rows.qty_unit_id
           and ucm.to_qty_unit_id = getc.tc_weight_unit_id;
      exception
        when others then
          vn_gmr_base_tc           := 0;
          vn_gmr_esc_descalator_tc := 0;
      end;
    else
      vn_gmr_price                  := null;
      vc_gmr_price_untit_id         := null;
      vc_price_unit_weight_unit_id  := null;
      vc_gmr_price_unit_cur_id      := null;
      vc_gmr_price_unit_cur_code    := null;
      vn_payable_to_price_wt_factor := null;
      vn_gmr_base_tc                := 0;
      vn_gmr_esc_descalator_tc      := 0;
      vn_fx_rate_price_to_pay       := null;
    end if;
   --
   -- If TC is assay based and payable qty is zero, we still need to calcualte TC
   -- 
     if cur_closing_rows.section_name = 'Non Penalty' and
       cur_closing_rows.payable_qty = 0 then
       begin
        select round((case
                       when getc.weight_type = 'Dry' then
                        cur_closing_rows.dry_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                       else
                        cur_closing_rows.wet_qty * ucm.multiplication_factor *
                        getc.base_tc_value
                     end),
                     cur_closing_rows.pay_cur_decimal),
               round((case
                       when getc.weight_type = 'Dry' then
                        cur_closing_rows.dry_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                       else
                        cur_closing_rows.wet_qty * ucm.multiplication_factor *
                        getc.esc_desc_tc_value
                     end),
                     cur_closing_rows.pay_cur_decimal)
          into vn_gmr_base_tc,
               vn_gmr_esc_descalator_tc
          from getc_gmr_element_tc_charges getc,
               ucm_unit_conversion_master  ucm
         where getc.process_id = pc_process_id
           and getc.internal_gmr_ref_no =
               cur_closing_rows.parent_internal_gmr_ref_no
           and getc.internal_grd_ref_no =
               cur_closing_rows.parent_internal_grd_ref_no
           and getc.element_id = cur_closing_rows.element_id
           and ucm.from_qty_unit_id = cur_closing_rows.qty_unit_id
           and ucm.to_qty_unit_id = getc.tc_weight_unit_id;
      exception
        when others then
          vn_gmr_base_tc           := 0;
          vn_gmr_esc_descalator_tc := 0;
      end;
       end if;
    --
    -- Calculate Penalty Charges, Use Dry or Wet Quantity As Configured in the Contract
    --    
    if cur_closing_rows.section_name = 'Penalty' then
      begin
        select round((case
                       when gepc.weight_type = 'Dry' then
                        cur_closing_rows.dry_qty * ucm.multiplication_factor *
                        gepc.pc_value
                       else
                        cur_closing_rows.wet_qty * ucm.multiplication_factor *
                        gepc.pc_value
                     end),
                     cur_closing_rows.pay_cur_decimal)
          into vn_gmr_penality_charge
          from gepc_gmr_element_pc_charges gepc,
               ucm_unit_conversion_master  ucm
         where gepc.process_id = pc_process_id
           and gepc.internal_gmr_ref_no =
               cur_closing_rows.parent_internal_gmr_ref_no
           and gepc.internal_grd_ref_no =
               cur_closing_rows.parent_internal_grd_ref_no
           and gepc.element_id = cur_closing_rows.element_id
           and ucm.from_qty_unit_id = cur_closing_rows.qty_unit_id
           and ucm.to_qty_unit_id = gepc.pc_weight_unit_id;
      exception
        when others then
          vn_gmr_penality_charge := 0;
      end;
    else
      vn_gmr_penality_charge := 0;
    end if;
    --
    -- Calcualte Payable Amount and RC Charges
    --
    if cur_closing_rows.section_name = 'Non Penalty' and
       cur_closing_rows.payable_qty <> 0 then
      vn_payable_amt_in_price_cur := round((vn_gmr_price /
                                           nvl(vn_gmr_price_unit_weight, 1)) *
                                           (vn_payable_to_price_wt_factor *
                                           cur_closing_rows.payable_qty) *
                                           vn_cont_price_cur_id_factor,
                                           cur_closing_rows.pay_cur_decimal);
      vn_payable_amt_in_pay_cur   := round(vn_payable_amt_in_price_cur *
                                           vn_fx_rate_price_to_pay,
                                           cur_closing_rows.pay_cur_decimal);
      --
      -- Calculate RC Charges
      --    
    
      begin
        select round(gerc.rc_value * ucm.multiplication_factor *
                     cur_closing_rows.payable_qty,
                     cur_closing_rows.pay_cur_decimal)
          into vn_gmr_refine_charge
          from gerc_gmr_element_rc_charges gerc,
               ucm_unit_conversion_master  ucm
         where gerc.process_id = pc_process_id
           and gerc.internal_gmr_ref_no =
               cur_closing_rows.parent_internal_gmr_ref_no
           and gerc.internal_grd_ref_no =
               cur_closing_rows.parent_internal_grd_ref_no
           and gerc.element_id = cur_closing_rows.element_id
           and ucm.from_qty_unit_id = cur_closing_rows.payable_qty_unit_id
           and ucm.to_qty_unit_id = gerc.rc_weight_unit_id;
      exception
        when others then
          vn_gmr_refine_charge := 0;
      end;
    else
      vn_payable_amt_in_price_cur := 0;
      vn_payable_amt_in_pay_cur   := 0;
      vn_gmr_refine_charge        := 0;
      vn_fx_rate_price_to_pay     := null;
    end if; 
    vn_gmr_total_tc := vn_gmr_base_tc + vn_gmr_esc_descalator_tc;
    if cur_closing_rows.ele_rank = 1 then
      insert into cbr_closing_balance_report
        (process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         gmr_ref_no,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         stock_ref_no,
         product_id,
         product_name,
         quality_id,
         quality_name,
         pile_name,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         grd_wet_qty,
         grd_dry_qty,
         grd_qty_unit_id,
         grd_qty_unit,
         pay_cur_id,
         pay_cur_code,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         other_charges_amt,
         parent_internal_gmr_ref_no,
         parent_internal_grd_ref_no,
         pay_cur_decimal,
         grd_to_gmr_qty_factor)
      values
        (pc_process_id,
         pd_trade_date,
         cur_closing_rows.corporate_id,
         cur_closing_rows.corporate_name,
         cur_closing_rows.gmr_ref_no,
         cur_closing_rows.internal_gmr_ref_no,
         cur_closing_rows.internal_grd_ref_no,
         cur_closing_rows.internal_stock_ref_no,
         cur_closing_rows.product_id,
         cur_closing_rows.product_desc,
         cur_closing_rows.quality_id,
         cur_closing_rows.quality_name,
         cur_closing_rows.pool_name,
         cur_closing_rows.warehouse_profile_id,
         cur_closing_rows.companyname,
         cur_closing_rows.shed_id,
         cur_closing_rows.storage_location_name,
         vn_wet_qty,
         vn_dry_qty,
         cur_closing_rows.qty_unit_id,
         cur_closing_rows.qty_unit,
         cur_closing_rows.pay_cur_id,
         cur_closing_rows.pay_cur_code,
         cur_closing_rows.conc_base_qty_unit_id,
         cur_closing_rows.conc_base_qty_unit,
         0,
         cur_closing_rows.parent_internal_gmr_ref_no,
         cur_closing_rows.parent_internal_grd_ref_no,
         cur_closing_rows.pay_cur_decimal,
         cur_closing_rows.grd_to_gmr_qty_factor
         );
    end if;
    insert into cbre_closing_bal_report_ele
      (process_id,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       element_id,
       element_name,
       assay_qty,
       asaay_qty_unit_id,
       asaay_qty_unit,
       payable_qty,
       payable_qty_unit_id,
       payable_qty_unit,
       payable_returnable_type,
       rc_amount,
       penality_amount,
       contract_price,
       price_unit_id,
       parent_internal_gmr_ref_no,
       base_tc_charges_amt,
       esc_desc_tc_charges_amt,
       tc_amount,
       payable_amt_pay_ccy,
       payable_amt_price_ccy)
    values
      (pc_process_id,
       cur_closing_rows.internal_gmr_ref_no,
       cur_closing_rows.internal_grd_ref_no,
       cur_closing_rows.element_id,
       cur_closing_rows.attribute_name,
       vn_assay_qty,
       cur_closing_rows.base_quantity_unit_id,
       cur_closing_rows.base_quantity_unit,
       vn_payable_qty,
       cur_closing_rows.base_quantity_unit_id,
       cur_closing_rows.base_quantity_unit,
       cur_closing_rows.qty_type,
       vn_gmr_refine_charge,
       vn_gmr_penality_charge,
       vn_gmr_price,
       vc_gmr_price_untit_id,
       cur_closing_rows.gmr_ref_no_for_price,
       vn_gmr_base_tc,
       vn_gmr_esc_descalator_tc,
       vn_gmr_total_tc,
       vn_payable_amt_in_pay_cur,
       vn_payable_amt_in_price_cur
       );
    if vn_rno = 500 then
      commit;
      vn_rno := 0;
    end if;
  end loop;
  commit;
gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'CB Start Of Other Charge Updation');  

for cur_cbr_gmr_qty in (select cbr.parent_internal_gmr_ref_no,
                                 sum(cbr.grd_wet_qty *
                                     cbr.grd_to_gmr_qty_factor) gmr_qty
                            from cbr_closing_balance_report cbr
                           where cbr.process_id = pc_process_id
                           group by cbr.parent_internal_gmr_ref_no)
  loop
    update cbr_closing_balance_report cbr
       set cbr.gmr_qty = cur_cbr_gmr_qty.gmr_qty
     where cbr.process_id = pc_process_id
       and cbr.parent_internal_gmr_ref_no = cur_cbr_gmr_qty.parent_internal_gmr_ref_no;
  end loop;
  commit;

gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'CB GMR Qty Updation  Over');  

  --  
  -- Update Other Charges
  -- IF GMR-1 is 500 MT and it has Internal Movement of 100 MT(GMR-2) and 150MT(GMR-3)
  -- Then Other charge for GMR-1 is 250, GMR-2 is 100 and GMR-3 is 150
  -- If Total Other charge is 500
  --

  for cur_oc in (select gfoc.internal_gmr_ref_no,
                        gfoc.small_lot_charge + gfoc.container_charge +
                        gfoc.sampling_charge + gfoc.handling_charge +
                        gfoc.location_value + gfoc.freight_allowance as other_charges
                   from gfoc_gmr_freight_other_charge gfoc
                  where gfoc.process_id = pc_process_id)
  loop
  
    update cbr_closing_balance_report cbr
       set cbr.other_charges_amt = round((cur_oc.other_charges *
                                         cbr.grd_wet_qty / cbr.gmr_qty),
                                         cbr.pay_cur_decimal)
     where cbr.process_id = pc_process_id
       and cbr.parent_internal_gmr_ref_no = cur_oc.internal_gmr_ref_no;
  end loop;
  commit;
                        
gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'CB Ends here');                          
exception
  when others then
  dbms_output.put_line(sqlerrm);
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure sp_closing_balance_report',
                                                         'M2M-013',
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm,
                                                         '',
                                                         pc_process,
                                                         '',
                                                         sysdate,
                                                         pd_trade_date);
    sp_insert_error_log(vobj_error_log);
    commit;
end;
procedure sp_calc_treatment_charge(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_process      varchar2,
                                   pc_dbd_id       varchar2) is
  vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count           number := 1;
  vn_treatment_charge          number;
  vn_max_range                 number;
  vn_min_range                 number;
  vn_typical_val               number;
  vc_weight_type               varchar2(20);
  vn_contract_price            number;
  vn_base_tret_charge          number;
  vn_each_tier_tc_charge       number;
  vn_range_gap                 number;
  vc_price_unit_id             varchar2(15);
  vc_cur_id                    varchar2(15);
  vc_tc_weight_unit_id         varchar2(15);
  vn_gmr_price                 number;
  vc_gmr_price_unit_id         varchar2(15);
  vc_price_unit_weight_unit_id varchar2(15);
  vc_gmr_price_unit_cur_id     varchar2(15);
  vn_commit_count              number := 0;
  vc_range_over                varchar2(1) := 'N';
  vn_esc_desc_tc_value         number;
  vc_range_type                varchar2(20);
  vn_total_treatment_charge    number :=0;
  vc_add_now                   varchar2(1) := 'N'; -- Set to Y for Fixed when it falls in the slab range
  vc_charge_type               varchar2(10);
  vc_is_price_range_variable      varchar2(1) := 'N';--Set to Y when TC is Price Range and Variable Type
 begin
  for cc in (select grd.internal_gmr_ref_no internal_gmr_ref_no,
                    grd.internal_grd_ref_no,
                    pqca.typical,
                    pqca.element_id,
                    pci.pcpq_id,
                    pci.pcdi_id,
                    aml.attribute_name element_name,
                    gmr.gmr_ref_no
               from gmr_goods_movement_record   gmr,
                    grd_goods_record_detail     grd,
                    ash_assay_header            ash,
                    asm_assay_sublot_mapping    asm,
                    pqca_pq_chemical_attributes pqca,
                    aml_attribute_master_list   aml,
                    pci_physical_contract_item  pci,
                    spq_stock_payable_qty       spq
              where ash.ash_id = asm.ash_id
                and asm.asm_id = pqca.asm_id
                and aml.attribute_id = pqca.element_id
                and grd.dbd_id = pc_dbd_id
                and pci.dbd_id = pc_dbd_id
                and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                and gmr.dbd_id = pc_dbd_id
                and grd.internal_contract_item_ref_no =
                    pci.internal_contract_item_ref_no
                and spq.internal_grd_ref_no = grd.internal_grd_ref_no
                and ash.ash_id = spq.weg_avg_pricing_assay_id
                and spq.dbd_id = pc_dbd_id
                and grd.is_deleted = 'N'
                and grd.status = 'Active'
                and spq.is_active = 'Y'
                and spq.element_id = aml.attribute_id
                and exists(
                select *
                  from pcth_pc_treatment_header       pcth,
                       ted_treatment_element_details  red,
                       pcetc_pc_elem_treatment_charge pcetc,
                       tqd_treatment_quality_details  tqd,
                       gth_gmr_treatment_header       gth
                 where pcth.pcth_id = red.pcth_id
                   and pcth.pcth_id = pcetc.pcth_id
                   and pcth.pcth_id = tqd.pcth_id
                   and tqd.pcpq_id = pci.pcpq_id
                   and pcth.dbd_id = pc_dbd_id
                   and red.dbd_id = pc_dbd_id
                   and pcetc.dbd_id = pc_dbd_id
                   and tqd.dbd_id = pc_dbd_id
                   and red.element_id = pqca.element_id
                   and gth.internal_gmr_ref_no = grd.internal_gmr_ref_no
                   and gth.pcth_id = pcth.pcth_id
                   and gth.is_active = 'Y'
                   and pcetc.is_active = 'Y'
                   and pcth.is_active = 'Y'
                   and red.is_active = 'Y'
                   and tqd.is_active = 'Y')              
             union
             select dgrd.internal_gmr_ref_no,
                    dgrd.internal_dgrd_ref_no,
                    pqca.typical,
                    pqca.element_id,
                    pci.pcpq_id,
                    pci.pcdi_id,
                    aml.attribute_name element_name,
                    gmr.gmr_ref_no
               from gmr_goods_movement_record   gmr,
                    dgrd_delivered_grd          dgrd,
                    ash_assay_header            ash,
                    asm_assay_sublot_mapping    asm,
                    pqca_pq_chemical_attributes pqca,
                    aml_attribute_master_list   aml,
                    pci_physical_contract_item  pci,
                    spq_stock_payable_qty       spq
              where ash.ash_id = asm.ash_id
                and asm.asm_id = pqca.asm_id
                and aml.attribute_id = pqca.element_id
                and dgrd.dbd_id = pc_dbd_id
                and pci.dbd_id = pc_dbd_id
                and dgrd.internal_contract_item_ref_no =
                    pci.internal_contract_item_ref_no
                and ash.ash_id = spq.weg_avg_pricing_assay_id
                and spq.dbd_id = pc_dbd_id
                and spq.element_id = aml.attribute_id
                and dgrd.status = 'Active'
                and dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                and gmr.dbd_id = pc_dbd_id
                and dgrd.internal_dgrd_ref_no = spq.internal_dgrd_ref_no
                and dgrd.internal_gmr_ref_no = spq.internal_gmr_ref_no
                and spq.is_active = 'Y'
                and exists (
                select *
                  from pcth_pc_treatment_header       pcth,
                       ted_treatment_element_details  red,
                       pcetc_pc_elem_treatment_charge pcetc,
                       tqd_treatment_quality_details  tqd,
                       gth_gmr_treatment_header       gth
                 where pcth.pcth_id = red.pcth_id
                   and pcth.pcth_id = pcetc.pcth_id
                   and pcth.pcth_id = tqd.pcth_id
                   and tqd.pcpq_id = pci.pcpq_id
                   and pcth.dbd_id = pc_dbd_id
                   and red.dbd_id = pc_dbd_id
                   and pcetc.dbd_id = pc_dbd_id
                   and tqd.dbd_id = pc_dbd_id
                   and red.element_id = pqca.element_id
                   and gth.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
                   and gth.pcth_id = pcth.pcth_id
                   and gth.is_active = 'Y'
                   and pcetc.is_active = 'Y'
                   and pcth.is_active = 'Y'
                   and red.is_active = 'Y'
                   and tqd.is_active = 'Y'))
  loop
    begin
      --
      -- Get the Price For the GMR
      --
      begin
         select cgcp.contract_price,
                   cgcp.price_unit_id,
                   cgcp.price_unit_weight_unit_id,
                   cgcp.price_unit_cur_id
              into vn_gmr_price,
                   vc_gmr_price_unit_id,
                   vc_price_unit_weight_unit_id,
                   vc_gmr_price_unit_cur_id
              from cgcp_conc_gmr_cog_price cgcp
             where cgcp.internal_gmr_ref_no = cc.internal_gmr_ref_no
               and cgcp.process_id = pc_process_id
               and cgcp.element_id = cc.element_id;
      exception
        when others then
          begin
          select cccp.contract_price,
               cccp.price_unit_id,
               cccp.price_unit_weight_unit_id,
               cccp.price_unit_cur_id
          into vn_gmr_price,
               vc_gmr_price_unit_id,
               vc_price_unit_weight_unit_id,
               vc_gmr_price_unit_cur_id
          from cccp_conc_contract_cog_price cccp
         where cccp.pcdi_id = cc.pcdi_id
           and cccp.process_id = pc_process_id
           and cccp.element_id = cc.element_id;

          exception
            when others then
              vn_gmr_price         := null;
              vc_gmr_price_unit_id := null;
          end;
      end;
      vn_contract_price := vn_gmr_price;
      for cur_tret_charge in (select pcth.range_type,
                                     pcetc.treatment_charge,
                                     pcetc.treatment_charge_unit_id,
                                     pcetc.charge_type,
                                     pcetc.charge_basis,
                                     pcetc.weight_type,
                                     pcetc.position,
                                     pcetc.range_min_op,
                                     nvl(pcetc.range_min_value, 0) range_min_value,
                                     pcetc.range_max_op,
                                     pcetc.range_max_value,
                                     pcth.pcth_id,
                                     pum.price_unit_id,
                                     nvl(pcetc.esc_desc_unit_id, pum.cur_id) cur_id,
                                     pum.weight_unit_id
                                from pcth_pc_treatment_header       pcth,
                                     ted_treatment_element_details  red,
                                     pcetc_pc_elem_treatment_charge pcetc,
                                     tqd_treatment_quality_details  tqd,
                                     ppu_product_price_units        ppu,
                                     pum_price_unit_master          pum,
                                     gth_gmr_treatment_header       gth
                               where pcth.pcth_id = red.pcth_id
                                 and pcth.pcth_id = pcetc.pcth_id
                                 and pcth.pcth_id = tqd.pcth_id
                                 and tqd.pcpq_id = cc.pcpq_id
                                 and pcth.dbd_id = pc_dbd_id
                                 and red.dbd_id = pc_dbd_id
                                 and pcetc.dbd_id = pc_dbd_id
                                 and tqd.dbd_id = pc_dbd_id
                                 and red.element_id = cc.element_id
                                 and pcetc.treatment_charge_unit_id =
                                     ppu.internal_price_unit_id
                                 and ppu.price_unit_id = pum.price_unit_id
                                 and gth.internal_gmr_ref_no =
                                     cc.internal_gmr_ref_no
                                 and gth.pcth_id = pcth.pcth_id
                                 and gth.is_active = 'Y'
                                 and pcetc.is_active = 'Y'
                                 and pcth.is_active = 'Y'
                                 and red.is_active = 'Y'
                                 and tqd.is_active = 'Y'
                                 -- Suppose Same contract has Assay Range and Price Range
                                 -- Then we have to add it,
                                 -- For Price Range , Variable we are existing, let this record
                                 -- come at end after assay range calcualtion is over
                                 order by pcetc.charge_type
                                 
                                 )
      loop
        vc_cur_id            := cur_tret_charge.cur_id;
        vc_price_unit_id     := cur_tret_charge.price_unit_id;
        vc_tc_weight_unit_id := cur_tret_charge.weight_unit_id;
        vc_weight_type       := cur_tret_charge.weight_type;
        vc_range_type := cur_tret_charge.range_type;
        vc_add_now :='N';
        vc_charge_type :=cur_tret_charge.charge_type;
        if cur_tret_charge.range_type = 'Price Range' then
          --if the CHARGE_TYPE is fixed then it will
          --behave as the slab as same as the assay range
          --No base concept is here
          vn_treatment_charge := 0;
          if cur_tret_charge.charge_type = 'Fixed' then
            if (cur_tret_charge.position = 'Range Begining' and
               cur_tret_charge.range_max_op = '<=' and
               vn_contract_price <= cur_tret_charge.range_max_value) or
               (cur_tret_charge.position = 'Range Begining' and
               cur_tret_charge.range_max_op = '<' and
               vn_contract_price < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position = 'Range End' and
               cur_tret_charge.range_min_op = '>=' and
               vn_contract_price >= cur_tret_charge.range_min_value) or
               (cur_tret_charge.position = 'Range End' and
               cur_tret_charge.range_min_op = '>' and
               vn_contract_price > cur_tret_charge.range_min_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>' and
               cur_tret_charge.range_max_op = '<' and
               vn_contract_price > cur_tret_charge.range_min_value and
               vn_contract_price < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>=' and
               cur_tret_charge.range_max_op = '<' and
               vn_contract_price >= cur_tret_charge.range_min_value and
               vn_contract_price < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>' and
               cur_tret_charge.range_max_op = '<=' and
               vn_contract_price > cur_tret_charge.range_min_value and
               vn_contract_price <= cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>=' and
               cur_tret_charge.range_max_op = '<=' and
               vn_contract_price >= cur_tret_charge.range_min_value and
               vn_contract_price <= cur_tret_charge.range_max_value) then
               vn_treatment_charge := cur_tret_charge.treatment_charge;
               vn_base_tret_charge := cur_tret_charge.treatment_charge;
               vc_add_now :='Y';
            end if;
          elsif cur_tret_charge.charge_type = 'Variable' then
          vc_range_over :='N'; -- Initialize for each record
            --Take the base price and its min and max range
            begin
              select pcetc.range_min_value,
                     pcetc.range_max_value,
                     pcetc.treatment_charge,
                     pcetc.weight_type
                into vn_min_range,
                     vn_max_range,
                     vn_base_tret_charge,
                     vc_weight_type
                from pcetc_pc_elem_treatment_charge pcetc
               where pcetc.pcth_id = cur_tret_charge.pcth_id
                 and pcetc.is_active = 'Y'
                 and pcetc.position = 'Base'
                 and pcetc.charge_type = 'Variable'
                 and pcetc.dbd_id = pc_dbd_id;
            exception
              when no_data_found then
                vn_max_range        := 0;
                vn_min_range        := 0;
                vn_base_tret_charge := 0;
            end;
            --according to the contract price , the price tier
            --will be find out, it may forward or back ward
            --Both vn_max_range and vn_min_range are same
            --in case if base
            if vn_contract_price > vn_max_range then
              vn_treatment_charge := vn_base_tret_charge;
              --go forward for the price range
              for cur_forward_price in (select pcetc.range_min_value,
                                               pcetc.range_min_op,                                            
                                               nvl(pcetc.range_max_value,vn_contract_price) range_max_value,
                                               pcetc.range_max_op,
                                               pcetc.esc_desc_value,
                                               pcetc.esc_desc_unit_id,
                                               pcetc.treatment_charge,
                                               pcetc.treatment_charge_unit_id,
                                               pcetc.charge_basis
                                          from pcetc_pc_elem_treatment_charge pcetc
                                         where pcetc.pcth_id =
                                               cur_tret_charge.pcth_id
                                           and nvl(pcetc.range_min_value,0) >= vn_max_range
                                           -- Because There is a defintely range for escalator saying > Base 
                                           -- If base is 6000, the escalator entry must say first entry as > 6000 and <=7000, > 7000 to 8000 or 
                                           -- If we do not put >= price one entry will be missed
                                           and nvl(pcetc.position, 'a') <> 'Base'
                                           and pcetc.is_active = 'Y'
                                           and pcetc.dbd_id = pc_dbd_id
                                           order by pcetc.range_max_value asc nulls last)
              loop
                -- if price is in the range take diff of price and max range
                if vn_contract_price>=cur_forward_price.range_min_value and
                      vn_contract_price<=cur_forward_price.range_max_value then
                      vn_range_gap := abs(vn_contract_price -
                                        cur_forward_price.range_min_value);
                      vc_range_over := 'Y';                          
                else
                  -- else diff range               
                  vn_range_gap := cur_forward_price.range_max_value -
                                  cur_forward_price.range_min_value;
                end if;
                if cur_forward_price.charge_basis = 'absolute' then
                  vn_each_tier_tc_charge := ceil(vn_range_gap /
                                                 nvl(cur_forward_price.esc_desc_value,
                                                     1)) *
                                            cur_forward_price.treatment_charge;
                elsif cur_forward_price.charge_basis = 'fractions Pro-Rata' then
                  vn_each_tier_tc_charge := (vn_range_gap /
                                            nvl(cur_forward_price.esc_desc_value,
                                                 1)) *
                                            cur_forward_price.treatment_charge;
                end if;
              
                vn_treatment_charge := vn_treatment_charge +
                                       vn_each_tier_tc_charge;
                if vc_range_over = 'Y' then
                    exit;
                  end if;                       
              end loop;
            elsif vn_contract_price < vn_min_range then
              vn_treatment_charge := vn_base_tret_charge; --
              --go back ward for the price range
              for cur_backward_price in (select nvl(pcetc.range_min_value, vn_contract_price) range_min_value,
                                                pcetc.range_min_op,
                                                pcetc.range_max_value,
                                                pcetc.range_max_op,
                                                pcetc.esc_desc_value,
                                                pcetc.esc_desc_unit_id,
                                                pcetc.treatment_charge,
                                                pcetc.treatment_charge_unit_id,
                                                pcetc.charge_basis
                                           from pcetc_pc_elem_treatment_charge pcetc
                                          where pcetc.pcth_id =
                                                cur_tret_charge.pcth_id
                                            and nvl(pcetc.range_min_value,0) < vn_min_range
                                            -- Because Deescalator has range saying < Base 
                                            -- If base is 6000, Deescalator entry has to < 6000
                                            and nvl(pcetc.position, 'a') <> 'Base'
                                            and pcetc.is_active = 'Y'
                                            and pcetc.dbd_id = pc_dbd_id
                                            order by pcetc.range_min_value desc nulls last)
              loop
                -- if price is in the range take diff of price and max range
                if   vn_contract_price>=  cur_backward_price.range_min_value  and
                          vn_contract_price<= cur_backward_price.range_max_value then
                     vn_range_gap := abs(vn_contract_price -
                                        cur_backward_price.range_max_value);
                     vc_range_over := 'Y';                                        
                else
                  -- else diff range               
                  vn_range_gap := cur_backward_price.range_max_value -
                                  cur_backward_price.range_min_value;
                end if;
                if cur_backward_price.charge_basis = 'absolute' then
                  vn_each_tier_tc_charge := ceil(vn_range_gap /
                                                 nvl(cur_backward_price.esc_desc_value,
                                                     1)) *
                                            cur_backward_price.treatment_charge;
                elsif cur_backward_price.charge_basis =
                      'fractions Pro-Rata' then
                  vn_each_tier_tc_charge := (vn_range_gap /
                                            nvl(cur_backward_price.esc_desc_value,
                                                 1)) *
                                            cur_backward_price.treatment_charge;
                end if;
                vn_treatment_charge := vn_treatment_charge -
                                       vn_each_tier_tc_charge;
                if vc_range_over = 'Y' then
                    exit;
                end if;                                       
              end loop;
            elsif vn_contract_price = vn_min_range and
                  vn_contract_price = vn_max_range then
              vn_treatment_charge := vn_base_tret_charge;
              --take the base price only
            end if;
          end if;
        elsif cur_tret_charge.range_type = 'Assay Range' then
          --Make sure the range for the element is mentation properly.
          --Only Slab basics charge
          if (cur_tret_charge.position = 'Range Begining' and
             cur_tret_charge.range_max_op = '<=' and
             cc.typical <= cur_tret_charge.range_max_value) or
             (cur_tret_charge.position = 'Range Begining' and
             cur_tret_charge.range_max_op = '<' and
             cc.typical < cur_tret_charge.range_max_value) or
             (cur_tret_charge.position = 'Range End' and
             cur_tret_charge.range_min_op = '>=' and
             cc.typical >= cur_tret_charge.range_min_value) or
             (cur_tret_charge.position = 'Range End' and
             cur_tret_charge.range_min_op = '>' and
             cc.typical > cur_tret_charge.range_min_value) or
             (cur_tret_charge.position is null and
             cur_tret_charge.range_min_op = '>' and
             cur_tret_charge.range_max_op = '<' and
             cc.typical > cur_tret_charge.range_min_value and
             cc.typical < cur_tret_charge.range_max_value) or
             (cur_tret_charge.position is null and
             cur_tret_charge.range_min_op = '>=' and
             cur_tret_charge.range_max_op = '<' and
             cc.typical >= cur_tret_charge.range_min_value and
             cc.typical < cur_tret_charge.range_max_value) or
             (cur_tret_charge.position is null and
             cur_tret_charge.range_min_op = '>' and
             cur_tret_charge.range_max_op = '<=' and
             cc.typical > cur_tret_charge.range_min_value and
             cc.typical <= cur_tret_charge.range_max_value) or
             (cur_tret_charge.position is null and
             cur_tret_charge.range_min_op = '>=' and
             cur_tret_charge.range_max_op = '<=' and
             cc.typical >= cur_tret_charge.range_min_value and
             cc.typical <= cur_tret_charge.range_max_value) then
            vn_treatment_charge := cur_tret_charge.treatment_charge;
            vn_max_range        := cur_tret_charge.range_max_value;
            vn_min_range        := cur_tret_charge.range_min_value;
            vn_typical_val      := cc.typical;
            vc_weight_type      := cur_tret_charge.weight_type;
            vn_base_tret_charge := cur_tret_charge.treatment_charge;
            vc_add_now :='Y';
          end if;
        end if;
        -- I will exit from the loop when it is tier base ,
        -- as the inner loop is done the calculation.
        if cur_tret_charge.range_type = 'Price Range' and
           cur_tret_charge.charge_type = 'Variable' then
           vn_total_treatment_charge := vn_total_treatment_charge + vn_treatment_charge;
           vc_is_price_range_variable := 'Y';
          exit;
        end if;
        --
        -- Get the total only when it was in the range, skip otherwise
        -- If it is Price range variable it adds above exits the loop
        --
        if (cur_tret_charge.range_type = 'Price Range' and cur_tret_charge.charge_type ='Fixed' and vc_add_now ='Y') or
        cur_tret_charge.range_type = 'Assay Range' and  vc_add_now ='Y' Then
        vn_total_treatment_charge := vn_total_treatment_charge + vn_treatment_charge;
        vc_add_now :='N';
        end if;
      end loop;
    end;
    If vn_base_tret_charge is null then
       vn_base_tret_charge :=0;
    end if;
    --
    -- Escalator / Desclator is applicable only for Variable Price Range
    --
    If vc_is_price_range_variable ='Y' Then
       vn_esc_desc_tc_value := vn_total_treatment_charge - vn_base_tret_charge;
    else
       vn_esc_desc_tc_value :=0;
    end if;
  
    insert into getc_gmr_element_tc_charges
      (process_id,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       gmr_ref_no,
       element_id,
       element_name,
       price,
       price_unit_id,
       price_cur_id,
       price_weight_unit_id,
       tc_value,
       tc_cur_id,
       tc_weight_unit_id,
       weight_type,
       base_tc_value,
       esc_desc_tc_value,
       range_type,
       charge_type)
    values
      (pc_process_id,
       cc.internal_gmr_ref_no,
       cc.internal_grd_ref_no,
       cc.gmr_ref_no,
       cc.element_id,
       cc.element_name,
       vn_gmr_price,
       vc_gmr_price_unit_id,
       vc_gmr_price_unit_cur_id,
       vc_price_unit_weight_unit_id,
       vn_total_treatment_charge,
       vc_cur_id,
       vc_tc_weight_unit_id,
       vc_weight_type,
       vn_base_tret_charge,
       vn_esc_desc_tc_value,
       vc_range_type,
       vc_charge_type);
    vn_commit_count := vn_commit_count + 1;
    if vn_commit_count = 500 then
      vn_commit_count := 0;
      commit;
    end if;
    vn_base_tret_charge :=0;
    vn_treatment_charge := 0;
    vn_total_treatment_charge := 0;
    vc_is_price_range_variable :='N';
  end loop;
  commit;
  --
  -- Update Range Type to Multiple if it has both assay and price range TC defined
  --
 for cur_update in(
 select t.internal_gmr_ref_no,
        t.element_id,
        t.process_id
   from getc_gmr_element_tc_charges t
  where t.process_id = pc_process_id
    and t.range_type = 'Assay Range'
    and t.esc_desc_tc_value <> 0 -- We cannot have Assay Range with Escalator Desclator Value
    for update) loop
   update getc_gmr_element_tc_charges getc
      set getc.range_type = 'Multiple'
    where getc.process_id = pc_process_id
      and getc.internal_gmr_ref_no = cur_update.internal_gmr_ref_no
      and getc.element_id = cur_update.element_id;
   end loop;
  commit;
exception
  when others then
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure sp_calc_treatment_charge',
                                                         'M2M-013',
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm,
                                                         '',
                                                         pc_process,
                                                         '',
                                                         sysdate,
                                                         pd_trade_date);
    sp_insert_error_log(vobj_error_log);
    commit;
end;
procedure sp_calc_refining_charge(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process_id   varchar2,
                                  pc_process      varchar2,
                                  pc_dbd_id       varchar2) is
  vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count           number := 1;
  vn_refine_charge             number;
  vc_price_unit_id             varchar2(100);
  vn_max_range                 number;
  vn_typical_val               number;
  vn_contract_price            number;
  vn_min_range                 number;
  vn_base_refine_charge        number;
  vn_range_gap                 number;
  vn_each_tier_rc_charge       number;
  vc_cur_id                    varchar2(10);
  vc_rc_weight_unit_id         varchar2(15);
  vc_include_ref_charge        char(1);
  vn_gmr_rc_charges            number := 0;
  vn_gmr_price                 number;
  vc_gmr_price_unit_id         varchar2(15);
  vc_price_unit_weight_unit_id varchar2(15);
  vc_gmr_price_unit_cur_id     varchar2(15);
  vn_commit_count              number := 0;
  vc_range_over          varchar2(1) := 'N';
begin
  --Get the Charge Details 
  for cc in (select gmr.internal_gmr_ref_no,
                    grd.internal_grd_ref_no,
                    gmr.internal_contract_ref_no,
                    grd.internal_contract_item_ref_no,
                    pqca.typical,
                    pqca.element_id,
                    pci.pcpq_id,
                    pci.pcdi_id,
                    gmr.gmr_ref_no,
                    aml.attribute_name element_name
               from gmr_goods_movement_record      gmr,
                    grd_goods_record_detail        grd,
                    ash_assay_header               ash,
                    asm_assay_sublot_mapping       asm,
                    pqca_pq_chemical_attributes    pqca,
                    aml_attribute_master_list      aml,
                    pci_physical_contract_item     pci,
                    spq_stock_payable_qty          spq
              where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                and grd.internal_grd_ref_no = spq.internal_grd_ref_no
                and grd.internal_gmr_ref_no = spq.internal_gmr_ref_no
                and ash.ash_id = asm.ash_id
                and spq.element_id = aml.attribute_id
                and ash.ash_id = spq.weg_avg_pricing_assay_id
                and asm.asm_id = pqca.asm_id
                and aml.attribute_id = pqca.element_id
                and pqca.element_id = spq.element_id
                and gmr.dbd_id = pc_dbd_id
                and grd.dbd_id = pc_dbd_id
                and pci.dbd_id = pc_dbd_id
                and spq.dbd_id = pc_dbd_id
                and grd.internal_contract_item_ref_no =
                    pci.internal_contract_item_ref_no
               and exists(
select *
  from pcrh_pc_refining_header       pcrh,
       red_refining_element_details  red,
       pcerc_pc_elem_refining_charge pcerc,
       rqd_refining_quality_details  rqd,
       grh_gmr_refining_header       grh
 where pcrh.pcrh_id = red.pcrh_id
   and pcrh.pcrh_id = pcerc.pcrh_id
   and pcrh.pcrh_id = rqd.pcrh_id
   and grh.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and grh.pcrh_id = pcrh.pcrh_id
   and rqd.pcpq_id = pci.pcpq_id
   and pcrh.dbd_id = pc_dbd_id
   and red.dbd_id = pc_dbd_id
   and pcerc.dbd_id = pc_dbd_id
   and rqd.dbd_id = pc_dbd_id
   and red.element_id = pqca.element_id
   and pcerc.is_active = 'Y'
   and pcrh.is_active = 'Y'
   and red.is_active = 'Y'
   and rqd.is_active = 'Y'
   and grh.is_active = 'Y')
               union
             select gmr.internal_gmr_ref_no,
                    dgrd.internal_dgrd_ref_no,
                    gmr.internal_contract_ref_no,
                    dgrd.internal_contract_item_ref_no,
                    pqca.typical,
                    pqca.element_id,
                    pci.pcpq_id,
                    pci.pcdi_id,
                    gmr.gmr_ref_no,
                    aml.attribute_name element_name
               from gmr_goods_movement_record      gmr,
                    dgrd_delivered_grd             dgrd,
                    ash_assay_header               ash,
                    asm_assay_sublot_mapping       asm,
                    pqca_pq_chemical_attributes    pqca,
                    aml_attribute_master_list      aml,
                    pci_physical_contract_item     pci,
                    spq_stock_payable_qty          spq
              where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
                and ash.ash_id = asm.ash_id
                and spq.dbd_id = pc_dbd_id
                and spq.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
                and spq.internal_dgrd_ref_no = dgrd.internal_gmr_ref_no
                and spq.element_id = aml.attribute_id
                and ash.ash_id = spq.weg_avg_pricing_assay_id
                and asm.asm_id = pqca.asm_id
                 and aml.attribute_id = pqca.element_id
                and pqca.element_id = spq.element_id
                and gmr.dbd_id = pc_dbd_id
                and dgrd.dbd_id = pc_dbd_id
                and pci.dbd_id = pc_dbd_id
                and dgrd.internal_contract_item_ref_no =
                    pci.internal_contract_item_ref_no
                 and exists((
                 select *
                   from pcrh_pc_refining_header       pcrh,
                        red_refining_element_details  red,
                        pcerc_pc_elem_refining_charge pcerc,
                        rqd_refining_quality_details  rqd,
                        grh_gmr_refining_header       grh
                  where pcrh.pcrh_id = red.pcrh_id
                    and pcrh.pcrh_id = pcerc.pcrh_id
                    and pcrh.pcrh_id = rqd.pcrh_id
                    and grh.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
                    and grh.pcrh_id = pcrh.pcrh_id
                    and rqd.pcpq_id = pci.pcpq_id
                    and pcrh.dbd_id = pc_dbd_id
                    and red.dbd_id = pc_dbd_id
                    and pcerc.dbd_id = pc_dbd_id
                    and rqd.dbd_id = pc_dbd_id
                    and red.element_id = pqca.element_id
                    and pcerc.is_active = 'Y'
                    and pcrh.is_active = 'Y'
                    and red.is_active = 'Y'
                    and rqd.is_active = 'Y'
                    and grh.is_active = 'Y')))
  loop
  dbms_output.put_line(cc.internal_gmr_ref_no);
  dbms_output.put_line(cc.element_id);
    --
    -- Get the Price For the GMR
    --
    begin
      select cgcp.contract_price,
                 cgcp.price_unit_id,
                 cgcp.price_unit_weight_unit_id,
                 cgcp.price_unit_cur_id
            into vn_gmr_price,
                 vc_gmr_price_unit_id,
                 vc_price_unit_weight_unit_id,
                 vc_gmr_price_unit_cur_id
            from cgcp_conc_gmr_cog_price cgcp
           where cgcp.internal_gmr_ref_no = cc.internal_gmr_ref_no
             and cgcp.process_id = pc_process_id
             and cgcp.element_id = cc.element_id;
    exception
      when others then
        begin
              select cccp.contract_price,
             cccp.price_unit_id,
             cccp.price_unit_weight_unit_id,
             cccp.price_unit_cur_id
        into vn_gmr_price,
             vc_gmr_price_unit_id,
             vc_price_unit_weight_unit_id,
             vc_gmr_price_unit_cur_id
        from cccp_conc_contract_cog_price cccp
       where cccp.pcdi_id = cc.pcdi_id
         and cccp.process_id = pc_process_id
         and cccp.element_id = cc.element_id;
        exception
          when others then
            vn_gmr_price         := null;
            vc_gmr_price_unit_id := null;
        end;
    end;
    vn_refine_charge  := 0;
    vn_contract_price := vn_gmr_price;
    -- for refine charge , the charge will applyed on
    -- payable qty only.So deduct the moisture and other deductable item
    -- from the item qty. 
    -- include refine charge from the contract creation.
    -- If Yes then take the conract include_ref_charge 
    -- else go for the Charge Range
    begin
       select pcepc.include_ref_charges
          into vc_include_ref_charge
          from pcpch_pc_payble_content_header pcpch,
               pcepc_pc_elem_payable_content  pcepc,
               pqd_payable_quality_details    pqd,
               dipch_di_payablecontent_header dipch
         where pcpch.pcpch_id = pcepc.pcpch_id
           and pcpch.dbd_id = pc_dbd_id
           and pcepc.dbd_id = pc_dbd_id
           and pcpch.element_id = cc.element_id
           and pcpch.internal_contract_ref_no = cc.internal_contract_ref_no
           and (pcepc.range_min_value <= cc.typical or
               pcepc.position = 'Range Begining')
           and (pcepc.range_max_value > cc.typical or
               pcepc.position = 'Range End')
           and pcpch.is_active = 'Y'
           and pcepc.is_active = 'Y'
           and pqd.pcpch_id = pcpch.pcpch_id
           and pqd.pcpq_id = cc.pcpq_id
           and pqd.is_active = 'Y'
           and pqd.dbd_id = pc_dbd_id
           and dipch.dbd_id = pc_dbd_id
           and dipch.pcpch_id = pcpch.pcpch_id
           and dipch.pcdi_id = cc.pcdi_id
           and dipch.is_active = 'Y'
           and rownum < 2; -- I never want 2 record from this;
    exception
      when no_data_found then
        vc_include_ref_charge := 'N';
    end;
  
    if vc_include_ref_charge = 'Y' then
      begin
        --Take the price and its details 
        --, This price wil store when contract is created.
        for cur_ref_charge in (select pcpch.pcpch_id,
                                      pcepc.range_max_op,
                                      pcepc.range_max_value,
                                      pcepc.range_min_op,
                                      pcepc.range_min_value,
                                      pcepc.position,
                                      pcepc.refining_charge_value,
                                      pcepc.refining_charge_unit_id,
                                      pum.cur_id,
                                      pum.price_unit_id,
                                      pum.weight_unit_id
                                 from pcdi_pc_delivery_item          pcdi,
                                      pci_physical_contract_item     pci,
                                      pcpch_pc_payble_content_header pcpch,
                                      pcepc_pc_elem_payable_content  pcepc,
                                      ppu_product_price_units        ppu,
                                      pum_price_unit_master          pum,
                                      gmr_goods_movement_record      gmr,
                                      grh_gmr_refining_header        grh
                                where pcpch.internal_contract_ref_no =
                                      pcdi.internal_contract_ref_no
                                  and pcdi.pcdi_id = pci.pcdi_id
                                  and pcpch.element_id = cc.element_id
                                  and pcpch.pcpch_id = pcepc.pcpch_id
                                  and pcepc.include_ref_charges = 'Y'
                                  and ppu.internal_price_unit_id =
                                      pcepc.refining_charge_unit_id
                                  and ppu.price_unit_id = pum.price_unit_id
                                  and pci.internal_contract_item_ref_no =
                                      cc.internal_contract_item_ref_no
                                  and gmr.internal_contract_ref_no =
                                      cc.internal_contract_ref_no
                                  and gmr.internal_gmr_ref_no =
                                      grh.internal_gmr_ref_no
                                  and pci.dbd_id = pc_dbd_id
                                  and pcdi.dbd_id = pc_dbd_id
                                  and pcpch.dbd_id = pc_dbd_id
                                  and pcepc.dbd_id = pc_dbd_id
                                  and pci.is_active = 'Y'
                                  and pcdi.is_active = 'Y'
                                  and pcpch.is_active = 'Y'
                                  and pcepc.is_active = 'Y')
        loop
          vc_rc_weight_unit_id := cur_ref_charge.weight_unit_id;
          vc_cur_id            := cur_ref_charge.cur_id;
          vc_price_unit_id     := cur_ref_charge.price_unit_id;
          if (cur_ref_charge.position = 'Range Begining' and
             cur_ref_charge.range_max_op = '<=' and
             cc.typical <= cur_ref_charge.range_max_value) or
             (cur_ref_charge.position = 'Range Begining' and
             cur_ref_charge.range_max_op = '<' and
             cc.typical <= cur_ref_charge.range_max_value) or
             (cur_ref_charge.position = 'Range End' and
             cur_ref_charge.range_min_op = '>=' and
             cc.typical >= cur_ref_charge.range_min_value) or
             (cur_ref_charge.position = 'Range End' and
             cur_ref_charge.range_min_op = '>' and
             cc.typical > cur_ref_charge.range_min_value) or
             (cur_ref_charge.position is null and
             cur_ref_charge.range_min_op = '>' and
             cur_ref_charge.range_max_op = '<' and
             cc.typical > cur_ref_charge.range_min_value and
             cc.typical < cur_ref_charge.range_max_value) or
             (cur_ref_charge.position is null and
             cur_ref_charge.range_min_op = '>=' and
             cur_ref_charge.range_max_op = '<' and
             cc.typical >= cur_ref_charge.range_min_value and
             cc.typical < cur_ref_charge.range_max_value) or
             (cur_ref_charge.position is null and
             cur_ref_charge.range_min_op = '>' and
             cur_ref_charge.range_max_op = '<=' and
             cc.typical > cur_ref_charge.range_min_value and
             cc.typical <= cur_ref_charge.range_max_value) or
             (cur_ref_charge.position is null and
             cur_ref_charge.range_min_op = '>=' and
             cur_ref_charge.range_max_op = '<=' and
             cc.typical >= cur_ref_charge.range_min_value and
             cc.typical <= cur_ref_charge.range_max_value) then
            vn_refine_charge := cur_ref_charge.refining_charge_value;
          end if;
        end loop;
      exception
        when others then
          vn_refine_charge := 0;
          vc_price_unit_id := null;
      end;
    
    else
      begin
        for cur_ref_charge in (select pcrh.range_type,
                                      pcerc.refining_charge,
                                      pcerc.refining_charge_unit_id,
                                      pcerc.charge_type,
                                      pcerc.charge_basis,
                                      pcerc.position,
                                      pcerc.range_min_op,
                                      pcerc.range_min_value,
                                      pcerc.range_max_op,
                                      pcerc.range_max_value,
                                      pcrh.pcrh_id,
                                      nvl(pcerc.esc_desc_unit_id, pum.cur_id) cur_id,
                                      pum.price_unit_id,
                                      pum.weight_unit_id
                                 from pcrh_pc_refining_header       pcrh,
                                      red_refining_element_details  red,
                                      pcerc_pc_elem_refining_charge pcerc,
                                      rqd_refining_quality_details  rqd,
                                      ppu_product_price_units       ppu,
                                      pum_price_unit_master         pum,
                                      grh_gmr_refining_header       grh
                                where pcrh.pcrh_id = red.pcrh_id
                                  and pcrh.pcrh_id = pcerc.pcrh_id
                                  and pcrh.pcrh_id = rqd.pcrh_id
                                  and grh.internal_gmr_ref_no =
                                      cc.internal_gmr_ref_no
                                  and grh.pcrh_id = pcrh.pcrh_id
                                  and rqd.pcpq_id = cc.pcpq_id
                                  and pcrh.dbd_id = pc_dbd_id
                                  and red.dbd_id = pc_dbd_id
                                  and pcerc.dbd_id = pc_dbd_id
                                  and rqd.dbd_id = pc_dbd_id
                                  and red.element_id = cc.element_id
                                  and ppu.internal_price_unit_id =
                                      pcerc.refining_charge_unit_id
                                  and ppu.price_unit_id = pum.price_unit_id
                                  and pcerc.is_active = 'Y'
                                  and pcrh.is_active = 'Y'
                                  and red.is_active = 'Y'
                                  and rqd.is_active = 'Y'
                                  and grh.is_active = 'Y'
                                order by range_min_value)
        loop
          vc_rc_weight_unit_id := cur_ref_charge.weight_unit_id;
          vc_cur_id            := cur_ref_charge.cur_id;
          vc_price_unit_id     := cur_ref_charge.price_unit_id;
          if cur_ref_charge.range_type = 'Price Range' then
            vn_gmr_rc_charges := 0;
            -- If the CHARGE_TYPE is fixed then it will
            -- behave as the slab as same as the assay range
            -- No base concept is here
            if cur_ref_charge.charge_type = 'Fixed' then
              if (cur_ref_charge.position = 'Range Begining' and
                 cur_ref_charge.range_max_op = '<=' and
                 vn_contract_price <= cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position = 'Range Begining' and
                 cur_ref_charge.range_max_op = '<' and
                 vn_contract_price < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position = 'Range End' and
                 cur_ref_charge.range_min_op = '>=' and
                 vn_contract_price >= cur_ref_charge.range_min_value) or
                 (cur_ref_charge.position = 'Range End' and
                 cur_ref_charge.range_min_op = '>' and
                 vn_contract_price > cur_ref_charge.range_min_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>' and
                 cur_ref_charge.range_max_op = '<' and
                 vn_contract_price > cur_ref_charge.range_min_value and
                 vn_contract_price < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>=' and
                 cur_ref_charge.range_max_op = '<' and
                 vn_contract_price >= cur_ref_charge.range_min_value and
                 vn_contract_price < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>' and
                 cur_ref_charge.range_max_op = '<=' and
                 vn_contract_price > cur_ref_charge.range_min_value and
                 vn_contract_price <= cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>=' and
                 cur_ref_charge.range_max_op = '<=' and
                 vn_contract_price >= cur_ref_charge.range_min_value and
                 vn_contract_price <= cur_ref_charge.range_max_value) then
                vn_refine_charge := cur_ref_charge.refining_charge;
              end if;
            elsif cur_ref_charge.charge_type = 'Variable' then
              vc_range_over := 'N';
              -- Take the base price and its min and max range
              begin
                select pcerc.range_min_value,
                       pcerc.range_max_value,
                       pcerc.refining_charge
                  into vn_min_range,
                       vn_max_range,
                       vn_base_refine_charge
                  from pcerc_pc_elem_refining_charge pcerc
                 where pcerc.pcrh_id = cur_ref_charge.pcrh_id
                   and pcerc.is_active = 'Y'
                   and pcerc.position = 'Base'
                   and pcerc.charge_type = 'Variable'
                   and pcerc.dbd_id = pc_dbd_id;
              exception
                when no_data_found then
                  vn_min_range          := 0;
                  vn_max_range          := 0;
                  vn_base_refine_charge := 0;
              end;
              --according to the contract price , the price tier
              --will be find out, it may forward or back ward
              --Both vn_max_range and vn_min_range are same in case if base
              if vn_contract_price > vn_max_range then
                --go forward for the price range
                vn_refine_charge := vn_base_refine_charge;
                for cur_forward_price in (select pcerc.range_min_value,
                                                 pcerc.range_min_op,
                                                 nvl(pcerc.range_max_value,vn_contract_price) range_max_value,
                                                 pcerc.range_max_op,
                                                 pcerc.esc_desc_value,
                                                 pcerc.esc_desc_unit_id,
                                                 pcerc.refining_charge,
                                                 pcerc.refining_charge_unit_id,
                                                 pcerc.charge_basis
                                            from pcerc_pc_elem_refining_charge pcerc
                                           where pcerc.pcrh_id =
                                                 cur_ref_charge.pcrh_id
                                             and nvl(pcerc.range_min_value,0) >= vn_max_range
                                             -- Because There is a defintely range for escalator saying > Base 
                                             -- If base is 6000, the escalator entry must say first entry as > 6000 and <=7000, > 7000 to 8000 or 
                                             -- If we do not put >= price one entry will be missed
                                             and nvl(pcerc.position, 'a') <> 'Base'
                                             and pcerc.is_active = 'Y'
                                             and pcerc.dbd_id = pc_dbd_id
                                             order by pcerc.range_max_value asc nulls last)
                loop
                  -- if price is in the range take diff of price and max range
                  if vn_contract_price>=cur_forward_price.range_min_value and
                       vn_contract_price<=cur_forward_price.range_max_value then
                      vn_range_gap := abs(vn_contract_price -
                                        cur_forward_price.range_min_value);
                                      vc_range_over := 'Y';   
                  else
                    -- else diff range               
                    vn_range_gap := cur_forward_price.range_max_value -
                                    cur_forward_price.range_min_value;
                  end if;
                
                  if cur_forward_price.charge_basis = 'absolute' then
                    vn_each_tier_rc_charge := ceil(vn_range_gap /
                                                   nvl(cur_forward_price.esc_desc_value,
                                                       1)) *
                                              cur_forward_price.refining_charge;
                  elsif cur_forward_price.charge_basis =
                        'fractions Pro-Rata' then
                    vn_each_tier_rc_charge := (vn_range_gap /
                                              nvl(cur_forward_price.esc_desc_value,
                                                   1)) *
                                              cur_forward_price.refining_charge;
                  end if;
                  vn_refine_charge := vn_refine_charge +
                                      vn_each_tier_rc_charge;
                if vc_range_over = 'Y' then
                    exit;
                  end if;

                end loop;
              elsif vn_contract_price < vn_min_range then
                --go back ward for the price range
                vn_refine_charge := vn_base_refine_charge;
                for cur_backward_price in (select nvl(pcerc.range_min_value, vn_contract_price) range_min_value,
                                                  pcerc.range_min_op,
                                                  pcerc.range_max_value,
                                                  pcerc.range_max_op,
                                                  pcerc.esc_desc_value,
                                                  pcerc.esc_desc_unit_id,
                                                  pcerc.refining_charge,
                                                  pcerc.refining_charge_unit_id,
                                                  pcerc.charge_basis
                                             from pcerc_pc_elem_refining_charge pcerc
                                            where pcerc.pcrh_id =
                                                  cur_ref_charge.pcrh_id
                                              and nvl(pcerc.range_min_value,0) < vn_min_range
                                              -- Because Deescalator has range saying < Base 
                                              -- If base is 6000, Deescalator entry has to < 6000
                                              and nvl(pcerc.position, 'a') <>'Base'
                                              and pcerc.is_active = 'Y'
                                              and pcerc.dbd_id = pc_dbd_id
                                              order by pcerc.range_min_value desc nulls last)
                loop
                  -- if price is in the range take diff of price and max range 
                 if   vn_contract_price>=  cur_backward_price.range_min_value  and
                          vn_contract_price<= cur_backward_price.range_max_value then
                     vn_range_gap := abs(vn_contract_price -
                                        cur_backward_price.range_max_value); 
                   
                                        vc_range_over := 'Y';                      
                  else
                    -- else diff range               
                    vn_range_gap := cur_backward_price.range_max_value -
                                    cur_backward_price.range_min_value;
                  end if;
                
                  if cur_backward_price.charge_basis = 'absolute' then
                    vn_each_tier_rc_charge := ceil(vn_range_gap /
                                                   nvl(cur_backward_price.esc_desc_value,
                                                       1)) *
                                              cur_backward_price.refining_charge;
                  elsif cur_backward_price.charge_basis =
                        'fractions Pro-Rata' then
                    vn_each_tier_rc_charge := (vn_range_gap /
                                              nvl(cur_backward_price.esc_desc_value,
                                                   1)) *
                                              cur_backward_price.refining_charge;
                  end if;
                  vn_refine_charge := vn_refine_charge -
                                      vn_each_tier_rc_charge;
                 if vc_range_over = 'Y' then
                    exit;
                  end if;                     
                end loop;
              elsif vn_contract_price = vn_min_range and
                    vn_contract_price = vn_max_range then
                vn_refine_charge := vn_base_refine_charge;
                --take the base price only
              end if;
            end if;
          elsif cur_ref_charge.range_type = 'Assay Range' then
            --Make sure the range for the element is mentation properly.
            if (cur_ref_charge.position = 'Range Begining' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical <= cur_ref_charge.range_max_value) or
               (cur_ref_charge.position = 'Range Begining' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical < cur_ref_charge.range_max_value) or
               (cur_ref_charge.position = 'Range End' and
               cur_ref_charge.range_min_op = '>=' and
               cc.typical >= cur_ref_charge.range_min_value) or
               (cur_ref_charge.position = 'Range End' and
               cur_ref_charge.range_min_op = '>' and
               cc.typical > cur_ref_charge.range_min_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical > cur_ref_charge.range_min_value and
               cc.typical < cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>=' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical >= cur_ref_charge.range_min_value and
               cc.typical < cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical > cur_ref_charge.range_min_value and
               cc.typical <= cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>=' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical >= cur_ref_charge.range_min_value and
               cc.typical <= cur_ref_charge.range_max_value) then
              vn_refine_charge := cur_ref_charge.refining_charge;
              vn_max_range     := cur_ref_charge.range_max_value;
              vn_min_range     := cur_ref_charge.range_min_value;
              vn_typical_val   := cc.typical;
            end if;
          end if;
          --I will exit from the loop when it is tier base ,
          --as the inner loop is done the calculation.
          if cur_ref_charge.range_type = 'Price Range' and
             cur_ref_charge.charge_type = 'Variable' then
            exit;
          end if;
        end loop;
      exception
        when others then
          vn_refine_charge := 0;
          vc_price_unit_id := null;
      end;
    end if;
  
    insert into gerc_gmr_element_rc_charges
      (process_id,
       internal_gmr_ref_no,
       gmr_ref_no,
       internal_grd_ref_no,
       element_id,
       element_name,
       price,
       price_unit_id,
       price_cur_id,
       price_weight_unit_id,
       rc_value,
       rc_cur_id,
       rc_weight_unit_id)
    values
      (pc_process_id,
       cc.internal_gmr_ref_no,
       cc.gmr_ref_no,
       cc.internal_grd_ref_no,
       cc.element_id,
       cc.element_name,
       vn_gmr_price,
       vc_gmr_price_unit_id,
       vc_gmr_price_unit_cur_id,
       vc_price_unit_weight_unit_id,
       vn_refine_charge,
       vc_cur_id,
       vc_rc_weight_unit_id);
    vn_commit_count := vn_commit_count + 1;
    if vn_commit_count = 500 then
      vn_commit_count := 0;
      commit;
    end if;
  end loop;
    commit;
exception
  when others then
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure sp_calc_refining_charge',
                                                         'M2M-013',
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm,
                                                         '',
                                                         pc_process,
                                                         '',
                                                         sysdate,
                                                         pd_trade_date);
    sp_insert_error_log(vobj_error_log);
    commit;
end;
procedure sp_calc_penalty_charge(pc_corporate_id varchar2,
                                 pd_trade_date   date,
                                 pc_process_id   varchar2,
                                 pc_process      varchar2,
                                 pc_dbd_id       varchar2) is
  vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count           number := 1;
  vn_penalty_charge      number;
  vc_penalty_weight_type varchar2(20);
  vn_max_range           number;
  vn_min_range           number;
  vn_typical_val         number := 0;
  vn_element_pc_charge   number;
  vn_range_gap           number;
  vn_tier_penalty        number;
  vc_price_unit_id       varchar2(15);
  vc_cur_id              varchar2(15);
  vc_pc_weight_unit_id   varchar2(15);
  vn_commit_count        number := 0;
begin
  --Take all the Elements associated with the conttract.
  for cc in (select gmr.internal_gmr_ref_no,
                    grd.internal_grd_ref_no,
                    pqca.typical,
                    pqca.element_id,
                    pci.pcpq_id,
                    gmr.gmr_ref_no,
                    aml.attribute_name element_name
               from gmr_goods_movement_record   gmr,
                    grd_goods_record_detail     grd,
                    ash_assay_header            ash,
                    asm_assay_sublot_mapping    asm,
                    pqca_pq_chemical_attributes pqca,
                    aml_attribute_master_list   aml,
                    pci_physical_contract_item  pci
              where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                and ash.ash_id = asm.ash_id
                and asm.asm_id = pqca.asm_id
                and aml.attribute_id = pqca.element_id
                and nvl(pqca.is_elem_for_pricing, 'N') = 'N'
                and gmr.dbd_id = pc_dbd_id
                and grd.dbd_id = pc_dbd_id
                and pci.dbd_id = pc_dbd_id
                and grd.weg_avg_pricing_assay_id = ash.ash_id
                and grd.internal_contract_item_ref_no =
                    pci.internal_contract_item_ref_no
                and exists (
                select *
                  from pcaph_pc_attr_penalty_header  pcaph,
                       pcap_pc_attribute_penalty     pcap,
                       pqd_penalty_quality_details   pqd,
                       pad_penalty_attribute_details pad,
                       gph_gmr_penalty_header        gph
                 where pcaph.pcaph_id = pcap.pcaph_id
                   and pcaph.pcaph_id = pqd.pcaph_id
                   and pcaph.pcaph_id = pad.pcaph_id
                   and pcaph.pcaph_id = gph.pcaph_id
                   and pqd.pcpq_id = pci.pcpq_id
                   and pcaph.dbd_id = pc_dbd_id
                   and pcap.dbd_id = pc_dbd_id
                   and pqd.dbd_id = pc_dbd_id
                   and pad.dbd_id = pc_dbd_id
                   and pcaph.is_active = 'Y'
                   and pcap.is_active = 'Y'
                   and pqd.is_active = 'Y'
                   and pad.is_active = 'Y'
                   and gph.is_active = 'Y'
                   and gph.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                   and pad.element_id = pqca.element_id)
union 
select gmr.internal_gmr_ref_no,
       dgrd.internal_dgrd_ref_no,
       pqca.typical,
       pqca.element_id,
       pci.pcpq_id,
       gmr.gmr_ref_no,
       aml.attribute_name
  from gmr_goods_movement_record   gmr,
       dgrd_delivered_grd          dgrd,
       sam_stock_assay_mapping     sam,
       ash_assay_header            ash,
       asm_assay_sublot_mapping    asm,
       pqca_pq_chemical_attributes pqca,
       aml_attribute_master_list   aml,
       pci_physical_contract_item  pci,
       spq_stock_payable_qty       spq
 where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
   and dgrd.internal_dgrd_ref_no = sam.internal_dgrd_ref_no
   and sam.ash_id = ash.ash_id
   and ash.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and aml.attribute_id = pqca.element_id
   and nvl(pqca.is_elem_for_pricing, 'N') = 'N'
   and gmr.dbd_id = pc_dbd_id
   and dgrd.dbd_id = pc_dbd_id
   and pci.dbd_id = pc_dbd_id
   and dgrd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and gmr.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and dgrd.internal_dgrd_ref_no = dgrd.internal_dgrd_ref_no
   and spq.internal_dgrd_ref_no = dgrd.internal_dgrd_ref_no
   and spq.element_id = pqca.element_id
   and spq.dbd_id = pc_dbd_id
   and spq.weg_avg_pricing_assay_id = ash.ash_id
   and exists (
   select *
     from pcaph_pc_attr_penalty_header  pcaph,
          pcap_pc_attribute_penalty     pcap,
          pqd_penalty_quality_details   pqd,
          pad_penalty_attribute_details pad,
          gph_gmr_penalty_header        gph
    where pcaph.pcaph_id = pcap.pcaph_id
      and pcaph.pcaph_id = pqd.pcaph_id
      and pcaph.pcaph_id = pad.pcaph_id
      and pcaph.pcaph_id = gph.pcaph_id
      and pqd.pcpq_id = pci.pcpq_id
      and pcaph.dbd_id = pc_dbd_id
      and pcap.dbd_id = pc_dbd_id
      and pqd.dbd_id = pc_dbd_id
      and pad.dbd_id = pc_dbd_id
      and pcaph.is_active = 'Y'
      and pcap.is_active = 'Y'
      and pqd.is_active = 'Y'
      and pad.is_active = 'Y'
      and gph.is_active = 'Y'
      and gph.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      and pad.element_id = pqca.element_id)) loop
    vn_element_pc_charge := 0;
    vn_tier_penalty      := 0;
    vn_penalty_charge    := 0;
    -- Passing each element which is getting  from the outer loop.
    -- and checking ,is it non payable or not.
    for cur_pc_charge in (select pcap.penalty_charge_type,
                                 pcap.penalty_basis,
                                 pcap.penalty_amount,
                                 pcap.range_min_value,
                                 pcap.range_max_value,
                                 pcap.range_min_op,
                                 pcap.range_max_op,
                                 pcap.position,
                                 pcap.charge_basis,
                                 pcap.penalty_weight_type,
                                 pcap.pcaph_id,
                                 pcaph.slab_tier,
                                 pum.price_unit_id,
                                 pum.cur_id,
                                 pum.weight_unit_id
                            from pcaph_pc_attr_penalty_header  pcaph,
                                 pcap_pc_attribute_penalty     pcap,
                                 pqd_penalty_quality_details   pqd,
                                 pad_penalty_attribute_details pad,
                                 gph_gmr_penalty_header        gph,
                                 ppu_product_price_units       ppu,
                                 pum_price_unit_master         pum
                           where pcaph.pcaph_id = pcap.pcaph_id
                             and pcaph.pcaph_id = pqd.pcaph_id
                             and pcaph.pcaph_id = pad.pcaph_id
                             and pcaph.pcaph_id = gph.pcaph_id
                             and pqd.pcpq_id = cc.pcpq_id
                             and pcaph.dbd_id = pc_dbd_id
                             and pcap.dbd_id = pc_dbd_id
                             and pqd.dbd_id = pc_dbd_id
                             and pad.dbd_id = pc_dbd_id
                             and pcaph.is_active = 'Y'
                             and pcap.is_active = 'Y'
                             and pqd.is_active = 'Y'
                             and pad.is_active = 'Y'
                             and gph.is_active = 'Y'
                             and gph.internal_gmr_ref_no =
                                 cc.internal_gmr_ref_no
                             and pad.element_id = cc.element_id
                             and pcap.penalty_unit_id =
                                 ppu.internal_price_unit_id
                             and ppu.price_unit_id = pum.price_unit_id)
    loop
      vc_pc_weight_unit_id :=cur_pc_charge.weight_unit_id; 
      vc_price_unit_id     := cur_pc_charge.price_unit_id;
      vc_cur_id            := cur_pc_charge.cur_id;
      vn_element_pc_charge := 0;
      -- check the penalty charge type
      if cur_pc_charge.penalty_charge_type = 'Fixed' then
        vc_penalty_weight_type := cur_pc_charge.penalty_weight_type;
        -- Find the PC charge which will fall in the appropriate range.
        -- as according to the typical value   
        if (cur_pc_charge.position = 'Range Begining' and
           cur_pc_charge.range_max_op = '<=' and
           cc.typical <= cur_pc_charge.range_max_value) or
           (cur_pc_charge.position = 'Range Begining' and
           cur_pc_charge.range_max_op = '<' and
           cc.typical < cur_pc_charge.range_max_value) or
           (cur_pc_charge.position = 'Range End' and
           cur_pc_charge.range_min_op = '>=' and
           cc.typical >= cur_pc_charge.range_min_value) or
           (cur_pc_charge.position = 'Range End' and
           cur_pc_charge.range_min_op = '>' and
           cc.typical > cur_pc_charge.range_min_value) or
           (cur_pc_charge.position is null and
           cur_pc_charge.range_min_op = '>' and
           cur_pc_charge.range_max_op = '<' and
           cc.typical > cur_pc_charge.range_min_value and
           cc.typical < cur_pc_charge.range_max_value) or
           (cur_pc_charge.position is null and
           cur_pc_charge.range_min_op = '>=' and
           cur_pc_charge.range_max_op = '<' and
           cc.typical >= cur_pc_charge.range_min_value and
           cc.typical < cur_pc_charge.range_max_value) or
           (cur_pc_charge.position is null and
           cur_pc_charge.range_min_op = '>' and
           cur_pc_charge.range_max_op = '<=' and
           cc.typical > cur_pc_charge.range_min_value and
           cc.typical <= cur_pc_charge.range_max_value) or
           (cur_pc_charge.position is null and
           cur_pc_charge.range_min_op = '>=' and
           cur_pc_charge.range_max_op = '<=' and
           cc.typical >= cur_pc_charge.range_min_value and
           cc.typical <= cur_pc_charge.range_max_value) then
        
          vn_penalty_charge    := cur_pc_charge.penalty_amount;
          vn_max_range         := cur_pc_charge.range_max_value;
          vn_min_range         := cur_pc_charge.range_min_value;
          vn_typical_val       := cc.typical;
          vn_element_pc_charge := vn_penalty_charge;
        end if;
      elsif cur_pc_charge.penalty_charge_type = 'Variable' then
        if cur_pc_charge.penalty_basis = 'Quantity' and
           cur_pc_charge.slab_tier = 'Tier' then
           vc_penalty_weight_type := cur_pc_charge.penalty_weight_type;
           vn_typical_val := cc.typical;
          --find the range where the typical falls in 
          if (cur_pc_charge.position = 'Range Begining' and
             cur_pc_charge.range_max_op = '<=' and
             vn_typical_val <= cur_pc_charge.range_max_value) or
             (cur_pc_charge.position = 'Range Begining' and
             cur_pc_charge.range_max_op = '<' and
             vn_typical_val < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position = 'Range End' and
             cur_pc_charge.range_min_op = '>=' and
             vn_typical_val >= cur_pc_charge.range_min_value) or
             (cur_pc_charge.position = 'Range End' and
             cur_pc_charge.range_min_op = '>' and
             vn_typical_val > cur_pc_charge.range_min_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>' and
             cur_pc_charge.range_max_op = '<' and
             vn_typical_val > cur_pc_charge.range_min_value and
             vn_typical_val < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>=' and
             cur_pc_charge.range_max_op = '<' and
             vn_typical_val >= cur_pc_charge.range_min_value and
             vn_typical_val < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>' and
             cur_pc_charge.range_max_op = '<=' and
             vn_typical_val > cur_pc_charge.range_min_value and
             vn_typical_val <= cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>=' and
             cur_pc_charge.range_max_op = '<=' and
             vn_typical_val >= cur_pc_charge.range_min_value and
             vn_typical_val <= cur_pc_charge.range_max_value) then
            --Finding all the  assay range form the start range to  last range 
            --for the different Tier basics ,assording to the typicla value
            for cur_range in (select nvl(pcap.range_min_value, 0) min_range,
                                     pcap.range_max_value max_range,
                                     pcap.penalty_amount,
                                     pcap.per_increase_value
                                from pcap_pc_attribute_penalty pcap
                               where nvl(pcap.range_min_value, 0) <=
                                     vn_typical_val
                                 and pcap.pcaph_id = cur_pc_charge.pcaph_id
                                 and pcap.dbd_id = pc_dbd_id)
            loop
              if vn_typical_val > 0 then
              iF cur_range.min_range <= vn_typical_val and
                      cur_range.max_range <= vn_typical_val then --for full range
                  vn_penalty_charge := cur_range.penalty_amount;
                  vn_range_gap      := cur_range.max_range -
                                       cur_range.min_range;
                else -- for half range
                  vn_penalty_charge := cur_range.penalty_amount;
                  vn_range_gap      := vn_typical_val - cur_range.min_range;
                                   
                end if;
              end if;
              if cur_pc_charge.charge_basis = 'absolute' then
                vn_penalty_charge := ceil(vn_range_gap /
                                          cur_range.per_increase_value) *
                                     vn_penalty_charge;
              elsif cur_pc_charge.charge_basis = 'fractions Pro-Rata' then
                vn_penalty_charge := (vn_range_gap /
                                     cur_range.per_increase_value) *
                                     vn_penalty_charge;
              end if;
              vn_tier_penalty := vn_tier_penalty + vn_penalty_charge;
            end loop;
          end if;
        elsif cur_pc_charge.penalty_basis = 'Payable Content' then
          -- Take the payable content qty from the table and 
          -- find the penalty But for the time being this feature is not applied
          null;
        end if;
        --Penalty Charge is applyed on the item wise not on the element  wise
        --This item qty may be dry or wet
        --Here no need of the typical value as penalty is on item level  
        vn_element_pc_charge := vn_tier_penalty; -- * vn_converted_qty;
      end if;
    end loop;
    insert into gepc_gmr_element_pc_charges
      (process_id,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       gmr_ref_no,
       element_id,
       element_name,
       pc_value,
       pc_cur_id,
       pc_weight_unit_id,
       weight_type)
    values
      (pc_process_id,
       cc.internal_gmr_ref_no,
       cc.internal_grd_ref_no,
       cc.gmr_ref_no,
       cc.element_id,
       cc.element_name,
       vn_element_pc_charge,
       vc_cur_id,
       vc_pc_weight_unit_id,
       vc_penalty_weight_type);
 if vn_commit_count = 500 then
      vn_commit_count := 0;
      commit;
    end if;
  end loop;
    commit;
exception
  when others then
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure sp_calc_penalty_charge',
                                                         'M2M-013',
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm,
                                                         '',
                                                         pc_process,
                                                         '',
                                                         sysdate,
                                                         pd_trade_date);    
    
end;
procedure sp_calc_freight_other_charge(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_process_id   varchar2,
                                    pc_process      varchar2) is

--------------------------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_calc_freight_other_charge
    --        author                                    : 
    --        created date                              : 2nd Jan 2013
    --        purpose                                   : Populate Freight and Other Charges for all GMRS
    --
    --        parameters

    --        modification history
    --        modified date                             : 
    --        modified by                               : 
    --        modify description                        :
--------------------------------------------------------------------------------------------------------------------------
  vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count           number := 1;
  vn_sampling_charge   number;
  vn_handling_charges  number;
  vn_location_value    number;
  vn_freight_allowance number;
  vn_small_lot_charge  number;
  vn_container_charge  number;
  vn_total_containers  number;
  vn_dummy             number;
  vn_wet_dry_qty_in_charge_unit number; -- Used for Small lot charges
  cursor cur_all_gmr is
 select gmr.internal_gmr_ref_no,
        decode(gmr.wns_status, 'Completed', 'Y', 'N') is_wns_created,
        nvl(gmr.no_of_bags, 0) no_of_bags,
        nvl(gmr.no_of_sublots, 0) no_of_sublots,
        gmr.dry_qty,
        gmr.wet_qty,
        nvl(gmr.is_apply_container_charge, 'N') is_apply_container_charge,
        nvl(gmr.is_apply_freight_allowance, 'N') is_apply_freight_allowance,
        case
          when nvl(gmr.is_final_invoiced, 'N') = 'Y' then
           'Y'
          when nvl(gmr.is_provisional_invoiced, 'N') = 'Y' then
           'Y'
          else
           'N'
        end is_invoiced,
        gmr.latest_internal_invoice_ref_no,
        gmr.shipped_qty,
        gmr.qty_unit_id gmr_qty_unit_id,
        pcmac.int_contract_ref_no
   from pcmac_pcm_addn_charges    pcmac,
        gmr_goods_movement_record gmr
  where gmr.internal_contract_ref_no = pcmac.int_contract_ref_no
    and pcmac.is_active = 'Y'
    and pcmac.is_automatic_charge = 'Y'
    and pcmac.corporate_id = pc_corporate_id
    and gmr.process_id = pc_process_id
  group by gmr.internal_gmr_ref_no,
        decode(gmr.wns_status, 'Completed', 'Y', 'N'),
        nvl(gmr.no_of_bags, 0) ,
        nvl(gmr.no_of_sublots, 0) ,
        gmr.dry_qty,
        gmr.wet_qty,
        nvl(gmr.is_apply_container_charge, 'N') ,
        nvl(gmr.is_apply_freight_allowance, 'N'),
        case
          when nvl(gmr.is_final_invoiced, 'N') = 'Y' then
           'Y'
          when nvl(gmr.is_provisional_invoiced, 'N') = 'Y' then
           'Y'
          else
           'N'
        end ,
        gmr.latest_internal_invoice_ref_no,
        gmr.shipped_qty,
        gmr.qty_unit_id,
        pcmac.int_contract_ref_no;
  cursor cur_each_gmr(pc_internal_gmr_ref_no varchar2) is
 select gmr.internal_gmr_ref_no,
        decode(gmr.wns_status, 'Completed', 'Y', 'N') is_wns_created,
        nvl(gmr.no_of_bags, 0) no_of_bags,
        nvl(gmr.no_of_sublots, 0) no_of_sublots,
        gmr.dry_qty,
        gmr.wet_qty,
        nvl(gmr.is_apply_container_charge, 'N') is_apply_container_charge,
        nvl(gmr.is_apply_freight_allowance, 'N') is_apply_freight_allowance,
        case
          when nvl(gmr.is_final_invoiced, 'N') = 'Y' then
           'Y'
          when nvl(gmr.is_provisional_invoiced, 'N') = 'Y' then
           'Y'
          else
           'N'
        end is_invoiced,
        gmr.latest_internal_invoice_ref_no,
        gmr.shipped_qty,
        gmr.qty_unit_id gmr_qty_unit_id,
        pcmac.*
   from pcmac_pcm_addn_charges    pcmac,
        gmr_goods_movement_record gmr
  where gmr.internal_contract_ref_no = pcmac.int_contract_ref_no
    and pcmac.is_active = 'Y'
    and pcmac.is_automatic_charge = 'Y'
    and pcmac.corporate_id = pc_corporate_id
    and gmr.process_id = pc_process_id
    and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
  order by gmr.internal_gmr_ref_no,
           pcmac.addn_charge_id;
begin

gvn_log_counter := gvn_log_counter + 1;
  for cur_all_gmr_rows in cur_all_gmr
  loop
    vn_sampling_charge   := 0;
    vn_handling_charges  := 0;
    vn_location_value    := 0;
    vn_freight_allowance := 0;
    vn_small_lot_charge  := 0;
    vn_container_charge  := 0;
    for cur_each_gmr_rows in cur_each_gmr(cur_all_gmr_rows.internal_gmr_ref_no)
    loop
      --
      -- Sampling Charges, Only if WNS is created
      -- If Rate then multiply by total no of sub lots for the GMR, if Flat take the value as is
      --
       if cur_each_gmr_rows.addn_charge_name = 'SamplingCharge' OR cur_each_gmr_rows.addn_charge_name = 'Sampling Charge' then
        if cur_each_gmr_rows.is_wns_created = 'Y' then
          if cur_each_gmr_rows.charge_type = 'Rate' then
            vn_sampling_charge := cur_each_gmr_rows.charge *
                                  cur_each_gmr_rows.fx_rate *
                                  cur_each_gmr_rows.no_of_sublots;
          else
            vn_sampling_charge := cur_each_gmr_rows.charge *
                                  cur_each_gmr_rows.fx_rate;
          end if;
        end if;
      end if;
      --
      -- Handling Charges, If Rate then multiply by total no of sub lots for the GMR, If Flat take the value as is
      --
      if cur_each_gmr_rows.addn_charge_name = 'Handling Charge' then
        if cur_each_gmr_rows.charge_type = 'Rate' then
          vn_handling_charges := cur_each_gmr_rows.charge *
                                 cur_each_gmr_rows.fx_rate *
                                 cur_each_gmr_rows.no_of_bags;
        else
          vn_handling_charges := cur_each_gmr_rows.charge *
                                 cur_each_gmr_rows.fx_rate;
        end if;
      end if;
      --
      -- Location Value , If Rate then multiply by dry or wet quantity, If Flat take the value as is
      --
      if cur_each_gmr_rows.addn_charge_name = 'Location Value' then
        if cur_each_gmr_rows.charge_type = 'Rate' then
          if cur_each_gmr_rows.charge_rate_basis = 'Dry' then
            vn_location_value := cur_each_gmr_rows.charge *
                                 cur_each_gmr_rows.fx_rate *
                                 cur_each_gmr_rows.dry_qty;
          else
            vn_location_value := cur_each_gmr_rows.charge *
                                 cur_each_gmr_rows.fx_rate *
                                 cur_each_gmr_rows.wet_qty;
          end if;
        else
          vn_location_value := cur_each_gmr_rows.charge *
                               cur_each_gmr_rows.fx_rate;
        end if;
      end if;
    
      --
      -- Freight Allowance , If Rate then multiply by GMR shipped quantity for the GMR, If Flat take the value as is
      --
      if cur_each_gmr_rows.addn_charge_name = 'Freight Allowance' and cur_each_gmr_rows.is_apply_freight_allowance ='Y' then
        if cur_each_gmr_rows.charge_type = 'Rate' then
          vn_freight_allowance := cur_each_gmr_rows.charge *
                                    cur_each_gmr_rows.fx_rate *
                                    cur_each_gmr_rows.shipped_qty;
        else
          vn_freight_allowance := cur_each_gmr_rows.charge *
                                  cur_each_gmr_rows.fx_rate;
        end if;
      end if;
      --
      -- Small Lot Charge, This will be like a slab, if the GMR wetor dry qty in the range, multiply the value by GMR Wet or Dry Qty
      -- Convert GMR wet quantity unit to Charge Qty unit
      --
      if cur_each_gmr_rows.addn_charge_name = 'Small Lot Charges' then
         begin
          select ucm.multiplication_factor
            into vn_wet_dry_qty_in_charge_unit
            from ucm_unit_conversion_master ucm
           where ucm.from_qty_unit_id = cur_each_gmr_rows.gmr_qty_unit_id
         and ucm.to_qty_unit_id = cur_each_gmr_rows.qty_unit_id;
         exception
         when others then
         vn_wet_dry_qty_in_charge_unit :=1;
         end;
         If cur_each_gmr_rows.charge_rate_basis ='Wet' Then
            vn_wet_dry_qty_in_charge_unit := vn_wet_dry_qty_in_charge_unit * cur_each_gmr_rows.wet_qty;
         else
            vn_wet_dry_qty_in_charge_unit := vn_wet_dry_qty_in_charge_unit * cur_each_gmr_rows.dry_qty;
         end if;
        if (cur_each_gmr_rows.position = 'Range Begining' and
           cur_each_gmr_rows.range_max_op = '<=' and
           vn_wet_dry_qty_in_charge_unit <= cur_each_gmr_rows.range_max_value) or
           (cur_each_gmr_rows.position = 'Range Begining' and
           cur_each_gmr_rows.range_max_op = '<' and
           vn_wet_dry_qty_in_charge_unit < cur_each_gmr_rows.range_max_value) or
           (cur_each_gmr_rows.position = 'Range End' and
           cur_each_gmr_rows.range_min_op = '>=' and
           vn_wet_dry_qty_in_charge_unit >= cur_each_gmr_rows.range_min_value) or
           (cur_each_gmr_rows.position = 'Range End' and
           cur_each_gmr_rows.range_min_op = '>' and
           vn_wet_dry_qty_in_charge_unit > cur_each_gmr_rows.range_min_value) or
           (cur_each_gmr_rows.position is null and
           cur_each_gmr_rows.range_min_op = '>' and
           cur_each_gmr_rows.range_max_op = '<' and
           vn_wet_dry_qty_in_charge_unit > cur_each_gmr_rows.range_min_value and
           vn_wet_dry_qty_in_charge_unit < cur_each_gmr_rows.range_max_value) or
           (cur_each_gmr_rows.position is null and
           cur_each_gmr_rows.range_min_op = '>=' and
           cur_each_gmr_rows.range_max_op = '<' and
           vn_wet_dry_qty_in_charge_unit >= cur_each_gmr_rows.range_min_value and
           vn_wet_dry_qty_in_charge_unit < cur_each_gmr_rows.range_max_value) or
           (cur_each_gmr_rows.position is null and
           cur_each_gmr_rows.range_min_op = '>' and
           cur_each_gmr_rows.range_max_op = '<=' and
           vn_wet_dry_qty_in_charge_unit > cur_each_gmr_rows.range_min_value and
           vn_wet_dry_qty_in_charge_unit <= cur_each_gmr_rows.range_max_value) or
           (cur_each_gmr_rows.position is null and
           cur_each_gmr_rows.range_min_op = '>=' and
           cur_each_gmr_rows.range_max_op = '<=' and
           vn_wet_dry_qty_in_charge_unit >= cur_each_gmr_rows.range_min_value and
           vn_wet_dry_qty_in_charge_unit <= cur_each_gmr_rows.range_max_value) then
           vn_small_lot_charge := vn_wet_dry_qty_in_charge_unit *
                                 cur_each_gmr_rows.charge *
                                 cur_each_gmr_rows.fx_rate;
        end if;
      end if;
    --
    -- Container Charge, Get the unique container numbers from gmr and size
    -- If Not Invoiced calcualte
    -- If invoiced, caldcualte only if container charge is applied in Invoice, else zero
    -- 
    If cur_each_gmr_rows.addn_charge_name = 'Container Charges' and cur_each_gmr_rows.is_apply_container_charge ='Y'  then
        if cur_each_gmr_rows.is_invoiced ='Y' then
            select count(*)
                into vn_dummy
                from ioc_invoice_other_charge ioc
               where ioc.internal_invoice_ref_no =
                     cur_each_gmr_rows.latest_internal_invoice_ref_no
                 and ioc.other_charge_cost_id in
					(select scm.cost_id
					from scm_service_charge_master scm
					where scm.cost_component_name = 'Container Charges');-- Hard code value for Container Charges
          end if;
          if cur_each_gmr_rows.is_invoiced ='N' or (cur_each_gmr_rows.is_invoiced ='Y' and vn_dummy > 0) Then
              begin
                select count(distinct agrd.container_no)
                into vn_total_containers
                from agmr_action_gmr agmr,
                     agrd_action_grd@eka_appdb agrd
                where agrd.action_no = agmr.action_no
                and agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                and agrd.status = 'Active'
                and agrd.is_deleted = 'N'
                and agmr.is_apply_container_charge = 'Y'
                and agmr.gmr_latest_action_action_id in
                 ('airDetail', 'shipmentDetail', 'railDetail', 'truckDetail','warehouseReceipt')
                  and agmr.is_internal_movement = 'N'
                  and agmr.is_deleted = 'N'
                  and agmr.internal_gmr_ref_no = cur_each_gmr_rows.internal_gmr_ref_no
                  and agrd.container_size=cur_each_gmr_rows.container_size; 
                -- We have multipe container sizes, we need to keep adding for this GMR                  
                vn_container_charge :=  vn_container_charge +   (cur_each_gmr_rows.charge *
                                         cur_each_gmr_rows.fx_rate * vn_total_containers);       
              exception
                when no_data_found then
                  null;
              end;
          end if;
    end if;
    end loop;
    insert into gfoc_gmr_freight_other_charge
      (process_id,
       internal_gmr_ref_no,
       internal_contract_ref_no,
       is_wns_created,
       is_invoiced,
       no_of_bags,
       no_of_sublots,
       dry_qty,
       wet_qty,
       small_lot_charge,
       container_charge,
       sampling_charge,
       handling_charge,
       location_value,
       freight_allowance,
       is_apply_container_charge,
       is_apply_freight_allowance,
       latest_internal_invoice_ref_no,
       shipped_qty,
       gmr_qty_unit_id)
    values
      (pc_process_id,
       cur_all_gmr_rows.internal_gmr_ref_no,
       cur_all_gmr_rows.int_contract_ref_no,
       cur_all_gmr_rows.is_wns_created,
       cur_all_gmr_rows.is_invoiced,
       cur_all_gmr_rows.no_of_bags,
       cur_all_gmr_rows.no_of_sublots,
       cur_all_gmr_rows.dry_qty,
       cur_all_gmr_rows.wet_qty,
       vn_small_lot_charge,
       vn_container_charge,
       vn_sampling_charge,
       vn_handling_charges,
       vn_location_value,
       vn_freight_allowance,
       cur_all_gmr_rows.is_apply_container_charge,
       cur_all_gmr_rows.is_apply_freight_allowance,
       cur_all_gmr_rows.latest_internal_invoice_ref_no,
       cur_all_gmr_rows.shipped_qty,
       cur_all_gmr_rows.gmr_qty_unit_id);
    
  end loop;
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        gvn_log_counter,
                        'GMR Freight And Other Charge Population Over');  
                        
 exception
 when others then
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure sp_calc_freight_other_charge',
                                                         'M2M-013',
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm,
                                                         '',
                                                         pc_process,
                                                         '',
                                                         sysdate,
                                                         pd_trade_date);                          
end; 
end; 
/
