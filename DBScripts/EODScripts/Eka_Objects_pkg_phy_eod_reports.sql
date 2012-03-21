create or replace package pkg_phy_eod_reports is

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
                                    pc_process_id   varchar2,
                                    pc_dbd_id       varchar2);

  procedure sp_calc_overall_realized_pnl(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2);

  procedure sp_phy_intrstat(pc_corporate_id varchar2,
                            pd_trade_date   date,
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
end; 
/
create or replace package body pkg_phy_eod_reports is
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
         and poud.unrealized_type in ('Unrealized')
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
         and poue.unrealized_type in ('Unrealized')
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
  end;
  procedure sp_phy_purchase_accural(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_process_id   varchar2,
                                    pc_dbd_id       varchar2) as
  
    cursor cur_pur_accural is
      select gmr.internal_gmr_ref_no,
             grd.internal_grd_ref_no,
             gmr.gmr_ref_no,
             grd.product_id,
             spq.element_id,
             spq.payable_qty,
             spq.qty_unit_id payable_qty_unit_id,
             sac.element_current_qty assay_qty,
             sac.element_qty_unit_id assay_qty_unit_id,
             gmr.corporate_id,
             akc.corporate_name,
             pcpd.product_id conc_product_id,
             pdm_conc.product_desc conc_product_name,
             pcpq.quality_template_id conc_quality_id,
             qat.quality_name conc_quality_name,
             pcpd.profit_center_id profit_center,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             pc_process_id process_id,
             gmr.contract_type contract_type,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
             cm.decimals as base_cur_decimal,
             aml.attribute_name element_name,
             pcpch.payable_type,
             pcm.cp_id,
             phd.companyname counterparty_name,
             pcm.invoice_currency_id pay_cur_id,
             cm_pay.cur_code pay_cur_code
        from gmr_goods_movement_record      gmr,
             grd_goods_record_detail        grd,
             spq_stock_payable_qty          spq,
             ak_corporate                   akc,
             cm_currency_master             cm,
             pcpd_pc_product_definition     pcpd,
             pdm_productmaster              pdm_conc,
             qum_quantity_unit_master       qum_pdm_conc,
             pcpq_pc_product_quality        pcpq,
             qat_quality_attributes         qat,
             cpc_corporate_profit_center    cpc,
             sac_stock_assay_content        sac,
             aml_attribute_master_list      aml,
             pcpch_pc_payble_content_header pcpch,
             pcm_physical_contract_main     pcm,
             phd_profileheaderdetails       phd,
             ii_invoicable_item             ii,
             cm_currency_master             cm_pay
      
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.internal_grd_ref_no = spq.internal_grd_ref_no
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.product_id = pdm_conc.product_id
         and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
         and pcpd.pcpd_id = pcpq.pcpd_id
         and pcpq.quality_template_id = qat.quality_id(+)
         and pcpd.profit_center_id = cpc.profit_center_id
         and grd.internal_grd_ref_no = sac.internal_grd_ref_no
         and spq.element_id = aml.attribute_id
         and spq.element_id = sac.element_id
         and gmr.process_id = pc_process_id
         and grd.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and pcpd.input_output = 'Input'
         and pcpd.process_id = pc_process_id
         and gmr.corporate_id = pc_corporate_id
         and gmr.internal_contract_ref_no = pcpch.internal_contract_ref_no
         and spq.element_id = pcpch.element_id
         and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.cp_id = phd.profileid
         and gmr.internal_gmr_ref_no = ii.internal_gmr_ref_no
         and grd.internal_grd_ref_no = ii.stock_id
         and pcm.invoice_currency_id = cm_pay.cur_id
         and gmr.is_deleted = 'N'
         and gmr.is_internal_movement = 'N'
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcm.is_active = 'Y'
         and spq.process_id = pc_process_id
         and pcpch.process_id = pc_process_id
         and pcm.process_id = pc_process_id
      union all
      select gmr.internal_gmr_ref_no,
             grd.internal_grd_ref_no,
             gmr.gmr_ref_no,
             grd.product_id,
             sac.element_id,
             null payable_qty,
             null payable_qty_unit_id,
             sac.element_total_qty assay_qty,
             sac.element_qty_unit_id assay_qty_unit_id,
             gmr.corporate_id,
             akc.corporate_name,
             pcpd.product_id conc_product_id,
             pdm_conc.product_desc conc_product_name,
             pcpq.quality_template_id conc_quality_id,
             qat.quality_name conc_quality_name,
             pcpd.profit_center_id profit_center,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             pc_process_id process_id,
             gmr.contract_type contract_type,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
             cm.decimals as base_cur_decimal,
             aml.attribute_name element_name,
             null payable_type,
             pcm.cp_id,
             phd.companyname counterparty_name,
             pcm.invoice_currency_id pay_cur_id,
             cm_pay.cur_code pay_cur_code
        from gmr_goods_movement_record   gmr,
             grd_goods_record_detail     grd,
             ak_corporate                akc,
             cm_currency_master          cm,
             pcpd_pc_product_definition  pcpd,
             pdm_productmaster           pdm_conc,
             qum_quantity_unit_master    qum_pdm_conc,
             pcpq_pc_product_quality     pcpq,
             qat_quality_attributes      qat,
             cpc_corporate_profit_center cpc,
             sac_stock_assay_content     sac,
             aml_attribute_master_list   aml,
             pcm_physical_contract_main  pcm,
             phd_profileheaderdetails    phd,
             ii_invoicable_item          ii,
             cm_currency_master          cm_pay
      
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.product_id = pdm_conc.product_id
         and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
         and pcpd.pcpd_id = pcpq.pcpd_id
         and pcpq.quality_template_id = qat.quality_id(+)
         and pcpd.profit_center_id = cpc.profit_center_id
         and grd.internal_grd_ref_no = sac.internal_grd_ref_no
         and sac.element_id = aml.attribute_id
         and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.cp_id = phd.profileid
         and gmr.internal_gmr_ref_no = ii.internal_gmr_ref_no
         and grd.internal_grd_ref_no = ii.stock_id
         and pcm.invoice_currency_id = cm_pay.cur_id
         and pcm.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and grd.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and pcpd.input_output = 'Input'
         and pcpd.process_id = pc_process_id
         and gmr.corporate_id = pc_corporate_id
         and gmr.is_deleted = 'N'
         and gmr.is_internal_movement = 'N'
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcm.is_active = 'Y'
         and aml.is_active = 'Y'
         and not exists
       (select spq.element_id
                from spq_stock_payable_qty spq
               where spq.process_id = gmr.process_id
                 and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                 and spq.element_id = sac.element_id);
  
    vn_gmr_treatment_charge      number;
    vc_gmr_treatment_cur_id      varchar2(15);
    vn_base_gmr_treatment_charge number;
    vn_gmr_refine_charge         number;
    vc_gmr_refine_cur_id         varchar2(15);
    vn_base_gmr_refine_charge    number;
    vn_gmr_penality_charge       number;
    vc_gmr_penality_cur_id       varchar2(15);
    vn_base_gmr_penality_charge  number;
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
  
  begin
    for cur_pur_accural_rows in cur_pur_accural
    loop
    
      begin
        select psu.m2m_price,
               psu.m2m_price_unit_id,
               psu.m2m_price_weight_unit_id,
               psu.m2m_price_cur_id,
               psu.m2m_price_cur_code
          into vn_gmr_price,
               vc_gmr_price_untit_id,
               vn_price_unit_weight_unit_id,
               vc_gmr_price_unit_cur_id,
               vc_gmr_price_unit_cur_code
          from gmr_goods_movement_record gmr,
               grd_goods_record_detail   grd,
               psue_element_details      psu
         where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and psu.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and psu.internal_grd_dgrd_ref_no = grd.internal_grd_ref_no
           and gmr.internal_gmr_ref_no =
               cur_pur_accural_rows.internal_gmr_ref_no
           and grd.internal_grd_ref_no =
               cur_pur_accural_rows.internal_grd_ref_no
           and psu.process_id = pc_process_id
           and gmr.process_id = pc_process_id
           and grd.process_id = pc_process_id
           and gmr.corporate_id = pc_corporate_id
           and gmr.is_deleted = 'N'
           and psu.element_id = cur_pur_accural_rows.element_id;
      exception
        when no_data_found then
          vn_gmr_price                 := null;
          vc_gmr_price_untit_id        := null;
          vn_price_unit_weight_unit_id := null;
          vc_gmr_price_unit_cur_id     := null;
          vc_gmr_price_unit_cur_code   := null;
      end;
    
      pkg_general.sp_get_main_cur_detail(vc_gmr_price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
    
      vn_payable_amt_in_price_cur := (vn_gmr_price /
                                     nvl(vn_gmr_price_unit_weight, 1)) *
                                     (pkg_general.f_get_converted_quantity(cur_pur_accural_rows.conc_product_id,
                                                                           cur_pur_accural_rows.payable_qty_unit_id,
                                                                           vn_price_unit_weight_unit_id,
                                                                           cur_pur_accural_rows.payable_qty)) *
                                     vn_cont_price_cur_id_factor;
    
      vn_fx_rate_price_to_pay   := pkg_general.f_get_converted_currency_amt(cur_pur_accural_rows.corporate_id,
                                                                            vc_gmr_price_unit_cur_id,
                                                                            cur_pur_accural_rows.pay_cur_id,
                                                                            pd_trade_date,
                                                                            1);
      vn_payable_amt_in_pay_cur := vn_payable_amt_in_price_cur *
                                   vn_fx_rate_price_to_pay;
      pkg_metals_general.sp_get_gmr_treatment_charge(cur_pur_accural_rows.internal_gmr_ref_no,
                                                     cur_pur_accural_rows.internal_grd_ref_no,
                                                     cur_pur_accural_rows.element_id,
                                                     pc_dbd_id,
                                                     vn_gmr_price,
                                                     vc_gmr_price_untit_id,
                                                     vn_gmr_treatment_charge,
                                                     vc_gmr_treatment_cur_id);
    
      -- converted treatment charges to base currency                                           
      vn_base_gmr_treatment_charge := round(pkg_general.f_get_converted_currency_amt(cur_pur_accural_rows.corporate_id,
                                                                                     vc_gmr_treatment_cur_id,
                                                                                     cur_pur_accural_rows.pay_cur_id,
                                                                                     pd_trade_date,
                                                                                     vn_gmr_treatment_charge),
                                            cur_pur_accural_rows.base_cur_decimal);
    
      pkg_metals_general.sp_get_gmr_refine_charge(cur_pur_accural_rows.internal_gmr_ref_no,
                                                  cur_pur_accural_rows.internal_grd_ref_no,
                                                  cur_pur_accural_rows.element_id,
                                                  pc_dbd_id,
                                                  vn_gmr_price,
                                                  vc_gmr_price_untit_id,
                                                  vn_gmr_refine_charge,
                                                  vc_gmr_refine_cur_id);
    
      --- converted refine charges to base currency                                              
    
      vn_base_gmr_refine_charge := round(pkg_general.f_get_converted_currency_amt(cur_pur_accural_rows.corporate_id,
                                                                                  vc_gmr_refine_cur_id,
                                                                                  cur_pur_accural_rows.pay_cur_id,
                                                                                  pd_trade_date,
                                                                                  vn_gmr_refine_charge),
                                         cur_pur_accural_rows.base_cur_decimal);
      pkg_metals_general.sp_get_gmr_penalty_charge(cur_pur_accural_rows.internal_gmr_ref_no,
                                                   cur_pur_accural_rows.internal_grd_ref_no,
                                                   pc_dbd_id,
                                                   cur_pur_accural_rows.element_id,
                                                   vn_gmr_penality_charge,
                                                   vc_gmr_penality_cur_id);
    
      vn_base_gmr_penality_charge := round(pkg_general.f_get_converted_currency_amt(cur_pur_accural_rows.corporate_id,
                                                                                    vc_gmr_penality_cur_id,
                                                                                    cur_pur_accural_rows.pay_cur_id,
                                                                                    pd_trade_date,
                                                                                    vn_gmr_penality_charge),
                                           cur_pur_accural_rows.base_cur_decimal);
    
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
         othercharges_amount)
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
         nvl(cur_pur_accural_rows.payable_qty, 0),
         nvl(cur_pur_accural_rows.payable_qty_unit_id,
             cur_pur_accural_rows.assay_qty_unit_id),
         vn_gmr_price,
         vc_gmr_price_untit_id,
         vc_gmr_price_unit_cur_id,
         vc_gmr_price_unit_cur_code,
         vn_fx_rate_price_to_pay,
         cur_pur_accural_rows.pay_cur_id,
         cur_pur_accural_rows.pay_cur_code,
         vn_base_gmr_treatment_charge,
         vn_base_gmr_refine_charge,
         vn_base_gmr_penality_charge,
         nvl(vn_payable_amt_in_price_cur, 0),
         nvl(vn_payable_amt_in_pay_cur, 0),
         0, --frightcharges_amount,
         0 --othercharges_amount    
         );
    end loop;
  
    ---- Invoiced  GMR Level
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
       pay_in_cur_id,
       pay_in_cur_code,
       frightcharges_amount,
       othercharges_amount,
       tranascation_type) with latest_invoice as
      (select inv.gmr_ref_no,
              inv.internal_invoice_ref_no,
              inv.eff_date,
              inv.process_id
         from (select gmr.gmr_ref_no,
                      iss.internal_invoice_ref_no,
                      axs.eff_date,
                      pc_process_id process_id,
                      rank() over(partition by gmr.gmr_ref_no order by axs.eff_date desc) rank_disp
                 from gmr_goods_movement_record  gmr,
                      is_invoice_summary         iss,
                      iam_invoice_action_mapping iam,
                      axs_action_summary         axs
                where gmr.internal_contract_ref_no =
                      iss.internal_contract_ref_no
                  and iss.internal_invoice_ref_no =
                      iam.internal_invoice_ref_no
                  and iam.invoice_action_ref_no = axs.internal_action_ref_no
                  and gmr.process_id = pc_process_id
                  and iss.process_id = pc_process_id
                group by gmr.gmr_ref_no,
                         iss.internal_invoice_ref_no,
                         axs.eff_date,
                         pc_process_id) inv
        where inv.rank_disp = 1)
      select temp.corporate_id,
             pc_process_id,
             pd_trade_date,
             temp.product_id,
             pdm_conc.product_desc,
             temp.contract_type,
             pcm.cp_id,
             phd.companyname,
             temp.gmr_ref_no,
             temp.element_id,
             aml.attribute_name,
             pcpch.payable_type,
             sum(temp.assay_qty) payable_qty,
             temp.assay_qty_unit assay_qty_unit,
             sum(temp.payble_qty) payable_qty,
             temp.payable_qty_unit payable_qty_unit_id,
             sum(temp.tcharges_amount) tcharges_amount,
             sum(temp.rcharges_amount) rcharges_amount,
             sum(temp.penalty_amount) penalty_amount,
             sum(temp.element_payable_amount) element_payable_amount,
             temp.invoice_currency_id,
             cm.cur_code,
             0,
             0,
             'Invoiced'
        from (select grd.internal_gmr_ref_no,
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
                     0 penalty_amount
                from gmr_goods_movement_record     gmr,
                     grd_goods_record_detail       grd,
                     iid_invoicable_item_details   iid,
                     iied_inv_item_element_details iied,
                     ak_corporate                  akc,
                     cm_currency_master            cm,
                     iam_invoice_assay_mapping     iam,
                     ash_assay_header              ash,
                     asm_assay_sublot_mapping      asm,
                     pqca_pq_chemical_attributes   pqca,
                     rm_ratio_master               rm,
                     latest_invoice                inv
               where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                 and grd.internal_grd_ref_no = iid.stock_id
                 and iid.internal_invoice_ref_no =
                     iied.internal_invoice_ref_no
                 and iid.stock_id = iied.grd_id
                 and gmr.corporate_id = akc.corporate_id
                 and akc.base_cur_id = cm.cur_id
                 and iid.internal_invoice_ref_no =
                     iam.internal_invoice_ref_no
                 and iid.stock_id = iam.internal_grd_ref_no
                 and iam.ash_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and iied.element_id = pqca.element_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr.gmr_ref_no = inv.gmr_ref_no
                 and gmr.process_id = inv.process_id
                 and grd.process_id = pc_process_id
                 and gmr.process_id = pc_process_id
                 and gmr.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
              union all
              ----- assay qty
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
                     0 penalty_amount
                from gmr_goods_movement_record   gmr,
                     grd_goods_record_detail     grd,
                     iid_invoicable_item_details iid,
                     ak_corporate                akc,
                     cm_currency_master          cm,
                     iam_invoice_assay_mapping   iam,
                     ash_assay_header            ash,
                     asm_assay_sublot_mapping    asm,
                     pqca_pq_chemical_attributes pqca,
                     rm_ratio_master             rm,
                     aml_attribute_master_list   aml,
                     latest_invoice              inv
               where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                 and grd.internal_grd_ref_no = iid.stock_id
                 and gmr.corporate_id = akc.corporate_id
                 and akc.base_cur_id = cm.cur_id
                 and iid.internal_invoice_ref_no =
                     iam.internal_invoice_ref_no
                 and iid.stock_id = iam.internal_grd_ref_no
                 and iam.ash_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and pqca.element_id = aml.attribute_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr.gmr_ref_no = inv.gmr_ref_no
                 and gmr.process_id = inv.process_id
                 and grd.process_id = pc_process_id
                 and gmr.process_id = pc_process_id
                 and gmr.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
              ---- Tc Chrages
              union all
              select grd.internal_gmr_ref_no,
                     grd.internal_grd_ref_no,
                     gmr.internal_contract_ref_no,
                     gmr.gmr_ref_no,
                     gmr.corporate_id,
                     grd.product_id,
                     grd.quality_id,
                     grd.profit_center_id,
                     iid.invoice_currency_id,
                     intc.element_id,
                     gmr.contract_type,
                     0 assay_qty,
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
                     intc.tcharges_amount tcharges_amount,
                     0 rcharges_amount,
                     0 penalty_amount
                from gmr_goods_movement_record   gmr,
                     grd_goods_record_detail     grd,
                     iid_invoicable_item_details iid,
                     intc_inv_treatment_charges  intc,
                     ak_corporate                akc,
                     cm_currency_master          cm,
                     aml_attribute_master_list   aml,
                     iam_invoice_assay_mapping   iam,
                     ash_assay_header            ash,
                     asm_assay_sublot_mapping    asm,
                     pqca_pq_chemical_attributes pqca,
                     rm_ratio_master             rm,
                     latest_invoice              inv
               where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                 and grd.internal_grd_ref_no = iid.stock_id
                 and iid.internal_invoice_ref_no =
                     intc.internal_invoice_ref_no
                 and iid.stock_id = intc.grd_id
                 and gmr.corporate_id = akc.corporate_id
                 and intc.element_id = aml.attribute_id
                 and akc.base_cur_id = cm.cur_id
                 and iid.internal_invoice_ref_no =
                     iam.internal_invoice_ref_no
                 and iid.stock_id = iam.internal_grd_ref_no
                 and iam.ash_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and intc.element_id = pqca.element_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr.gmr_ref_no = inv.gmr_ref_no
                 and gmr.process_id = inv.process_id
                 and grd.process_id = pc_process_id
                 and gmr.process_id = pc_process_id
                 and gmr.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
              -- Rc Chargess
              union all
              select grd.internal_gmr_ref_no,
                     grd.internal_grd_ref_no,
                     gmr.internal_contract_ref_no,
                     gmr.gmr_ref_no,
                     gmr.corporate_id,
                     grd.product_id,
                     grd.quality_id,
                     grd.profit_center_id,
                     iid.invoice_currency_id,
                     inrc.element_id,
                     gmr.contract_type,
                     0 assay_qty,
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
                     inrc.rcharges_amount rcharges_amount,
                     0 penalty_amount
                from gmr_goods_movement_record   gmr,
                     grd_goods_record_detail     grd,
                     iid_invoicable_item_details iid,
                     inrc_inv_refining_charges   inrc,
                     ak_corporate                akc,
                     cm_currency_master          cm,
                     aml_attribute_master_list   aml,
                     iam_invoice_assay_mapping   iam,
                     ash_assay_header            ash,
                     asm_assay_sublot_mapping    asm,
                     pqca_pq_chemical_attributes pqca,
                     rm_ratio_master             rm,
                     latest_invoice              inv
               where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                 and grd.internal_grd_ref_no = iid.stock_id
                 and iid.internal_invoice_ref_no =
                     inrc.internal_invoice_ref_no
                 and iid.stock_id = inrc.grd_id
                 and gmr.corporate_id = akc.corporate_id
                 and inrc.element_id = aml.attribute_id
                 and akc.base_cur_id = cm.cur_id
                 and iid.internal_invoice_ref_no =
                     iam.internal_invoice_ref_no
                 and iid.stock_id = iam.internal_grd_ref_no
                 and iam.ash_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and inrc.element_id = pqca.element_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr.gmr_ref_no = inv.gmr_ref_no
                 and gmr.process_id = inv.process_id
                 and grd.process_id = pc_process_id
                 and gmr.process_id = pc_process_id
                 and gmr.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
              -- penality
              union all
              select grd.internal_gmr_ref_no,
                     grd.internal_grd_ref_no,
                     gmr.internal_contract_ref_no,
                     gmr.gmr_ref_no,
                     gmr.corporate_id,
                     grd.product_id,
                     grd.quality_id,
                     grd.profit_center_id,
                     iid.invoice_currency_id,
                     iepd.element_id,
                     gmr.contract_type,
                     0 assay_qty,
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
                     iepd.element_penalty_amount penalty_amount
                from gmr_goods_movement_record   gmr,
                     grd_goods_record_detail     grd,
                     iid_invoicable_item_details iid,
                     iepd_inv_epenalty_details   iepd,
                     ak_corporate                akc,
                     cm_currency_master          cm,
                     iam_invoice_assay_mapping   iam,
                     ash_assay_header            ash,
                     asm_assay_sublot_mapping    asm,
                     pqca_pq_chemical_attributes pqca,
                     rm_ratio_master             rm,
                     latest_invoice              inv
               where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                 and grd.internal_grd_ref_no = iid.stock_id
                 and iid.internal_invoice_ref_no =
                     iepd.internal_invoice_ref_no
                 and iid.stock_id = iepd.stock_id
                 and gmr.corporate_id = akc.corporate_id
                 and akc.base_cur_id = cm.cur_id
                 and iid.internal_invoice_ref_no =
                     iam.internal_invoice_ref_no
                 and iid.stock_id = iam.internal_grd_ref_no
                 and iam.ash_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and iepd.element_id = pqca.element_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr.gmr_ref_no = inv.gmr_ref_no
                 and gmr.process_id = inv.process_id
                 and grd.process_id = pc_process_id
                 and gmr.process_id = pc_process_id
                 and gmr.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id) temp,
             pdm_productmaster pdm_conc,
             qat_quality_attributes qat,
             cpc_corporate_profit_center cpc,
             ak_corporate akc,
             cm_currency_master cm,
             aml_attribute_master_list aml,
             pcm_physical_contract_main pcm,
             phd_profileheaderdetails phd,
             pcpch_pc_payble_content_header pcpch
       where temp.product_id = pdm_conc.product_id
         and temp.quality_id = qat.quality_id(+)
         and temp.profit_center_id = cpc.profit_center_id
         and temp.corporate_id = akc.corporate_id
         and temp.element_id = aml.attribute_id
         and temp.invoice_currency_id = cm.cur_id
         and temp.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.cp_id = phd.profileid
         and pcm.cp_id = phd.profileid
         and temp.internal_contract_ref_no =
             pcpch.internal_contract_ref_no(+)
         and temp.element_id = pcpch.element_id(+)
         and pcm.process_id = pc_process_id
         and pcpch.process_id(+) = pc_process_id
         and pcm.is_active = 'Y'
         and pcpch.is_active(+) = 'Y'
       group by temp.corporate_id,
                pc_process_id,
                temp.product_id,
                pdm_conc.product_desc,
                pcm.cp_id,
                temp.contract_type,
                phd.companyname,
                temp.gmr_ref_no,
                temp.element_id,
                aml.attribute_name,
                pcpch.payable_type,
                temp.invoice_currency_id,
                temp.payable_qty_unit,
                temp.assay_qty_unit,
                cm.cur_code,
                'Invoiced';
  
    --calucalted GMR Leval             
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
       tranascation_type)
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
             sum(pa.tcharges_amount),
             sum(pa.rcharges_amount),
             sum(pa.penalty_amount),
             0,
             0,
             'Calculated'
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
                'Calculated';
    -- diff GMR level
  
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
       pay_in_cur_id,
       pay_in_cur_code,
       frightcharges_amount,
       othercharges_amount,
       tranascation_type)
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
                            end) payable_amount,
             pa.pay_in_cur_id,
             pa.pay_in_cur_code,
             0,
             0,
             'Difference'
        from pa_purchase_accural_gmr pa
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
                pa.pay_in_cur_id,
                pa.pay_in_cur_code,
                'Difference';
  
    commit;
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
       internal_stock_ref_no)
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
             t.internal_stock_ref_no
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
                     prd.internal_stock_ref_no
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
                     prd.internal_stock_ref_no
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
                        prd.internal_stock_ref_no
              
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
                     prd.internal_stock_ref_no
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
                     prd.internal_stock_ref_no
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
                        prd.internal_stock_ref_no
              
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
                     gmr.gmr_ref_no contract_ref_no, --GMR ref no
                     '-NA-' contract_details,
                     '-NA-' cost_id,
                     '-NA-' cost_name,
                     '' price_fixation_status,
                     0 current_qty,
                     0 quantity_in_units,
                     ((case
                       when invs.invoice_type_name = 'Credit Note General' then
                        -1
                       else
                        1
                     end) * nvl(invs.total_invoice_item_amount, 0) -
                     nvl(invs.amount_paid, 0) * invs.fx_to_base) current_amount,
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
                     null internal_stock_ref_no
                from is_invoice_summary         invs,
                     pcm_physical_contract_main pcm,
                     gmr_goods_movement_record  gmr,
                     phd_profileheaderdetails   phd,
                     cm_currency_master         cm,
                     ak_corporate               akc,
                     cm_currency_master         cm_b,
                     --scm_service_charge_master    scm,
                     cpc_corporate_profit_center cpc
               where invs.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and gmr.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and invs.invoice_type = 'DebitCreditNote'
                 and invs.invoice_type_name in
                     ('Credit Note General', 'Debit Note General')
                 and invs.invoice_status = 'Active'
                 and invs.cp_id = phd.profileid
                 and cm.cur_id = invs.invoice_cur_id
                 and invs.corporate_id = akc.corporate_id
                 and akc.base_currency_name = cm_b.cur_code
                 and invs.profit_center_id = cpc.profit_center_id
                 and invs.invoice_issue_date <= pd_trade_date
                 and invs.process_id = pcm.process_id
                 and pcm.process_id = gmr.process_id
                 and gmr.process_id = pc_process_id
                 and invs.is_invoice_new = 'Y' --need to do this marking....
              
              union all
              select 'Debit/Credit Note' section_name,
                     invs.invoice_type_name || ' Cancelled' sub_section_name,
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
                     gmr.gmr_ref_no contract_ref_no, --GMR ref no
                     '-NA-' contract_details,
                     '-NA-' cost_id,
                     '-NA-' cost_name,
                     '' price_fixation_status,
                     0 current_qty,
                     0 quantity_in_units,
                     (case
                       when invs.invoice_type_name = 'Credit Note General' then
                        -1
                       else
                        1
                     end) * (nvl(invs.total_invoice_item_amount -
                                 nvl(invs.amount_paid, 0),
                                 0) * (-1) * invs.fx_to_base) current_amount,
                     0 previous_realized_qty,
                     0 previous_realized_amount,
                     invs.invoice_issue_date month,
                     invs.invoice_cur_id transact_cur_id,
                     cm.cur_code transact_cur_code,
                     cm.decimals transact_cur_decimals,
                     (-1) * nvl((invs.total_invoice_item_amount -
                                nvl((invs.amount_paid), 0)),
                                0) transact_amount,
                     null internal_contract_item_ref_no,
                     null int_alloc_group_id,
                     null internal_stock_ref_no
                from is_invoice_summary         invs,
                     pcm_physical_contract_main pcm,
                     gmr_goods_movement_record  gmr,
                     phd_profileheaderdetails   phd,
                     cm_currency_master         cm,
                     ak_corporate               akc,
                     cm_currency_master         cm_b,
                     --scm_service_charge_master    scm,
                     cpc_corporate_profit_center cpc
               where invs.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and gmr.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and invs.invoice_type = 'DebitCreditNote'
                 and invs.invoice_type_name in
                     ('Credit Note General', 'Debit Note General')
                 and invs.invoice_status = 'Active'
                 and invs.cp_id = phd.profileid
                 and cm.cur_id = invs.invoice_cur_id
                 and invs.corporate_id = akc.corporate_id
                 and akc.base_currency_name = cm_b.cur_code
                 and invs.profit_center_id = cpc.profit_center_id
                 and invs.invoice_issue_date <= pd_trade_date
                 and invs.process_id = pcm.process_id
                 and pcm.process_id = gmr.process_id
                 and gmr.process_id = pc_process_id
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
                     null internal_stock_ref_no
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
                     null internal_stock_ref_no
                from cs_cost_store               cs,
                     cigc_contract_item_gmr_cost cigc,
                     pci_physical_contract_item  pci,
                     pcdi_pc_delivery_item       pcdi,
                     pcpd_pc_product_definition  pcpd,
                     grd_goods_record_detail     grd,
                     scm_service_charge_master   scm,
                     cpc_corporate_profit_center cpc,
                     tdc_trade_date_closure      tdc,
                     ak_corporate                akc,
                     phd_profileheaderdetails    phd,
                     cm_currency_master          cm_b,
                     cm_currency_master          cm
               where cs.cost_component_id = scm.cost_id
                 and cs.base_amt_cur_id = cm_b.cur_id
                 and cs.transaction_amt_cur_id = cm.cur_id
                 and cigc.int_contract_item_ref_no =
                     pci.internal_contract_item_ref_no(+)
                 and pci.pcdi_id = pcdi.pcdi_id
                 and pcdi.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                    
                 and pcpd.input_output = 'Input'
                 and grd.internal_grd_ref_no(+) = cigc.internal_grd_ref_no
                 and (case when cigc.int_contract_item_ref_no is null then
                      grd.profit_center_id else pcpd.profit_center_id end) =
                     cpc.profit_center_id
                 and tdc.trade_date = pd_trade_date
                 and scm.reversal_type not in ('CONTRACT')
                 and cs.process_id = tdc.process_id
                 and pci.process_id = tdc.process_id
                 and pcdi.process_id = tdc.process_id
                 and pcpd.process_id = tdc.process_id
                    
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
                     null internal_stock_ref_no
                from cs_cost_store               cs,
                     cigc_contract_item_gmr_cost cigc,
                     pci_physical_contract_item  pci,
                     pcdi_pc_delivery_item       pcdi,
                     pcpd_pc_product_definition  pcpd,
                     grd_goods_record_detail     grd,
                     scm_service_charge_master   scm,
                     cpc_corporate_profit_center cpc,
                     tdc_trade_date_closure      tdc,
                     ak_corporate                akc,
                     phd_profileheaderdetails    phd,
                     cm_currency_master          cm_b,
                     cm_currency_master          cm
               where cs.cost_component_id = scm.cost_id
                 and cs.base_amt_cur_id = cm_b.cur_id
                 and cs.transaction_amt_cur_id = cm.cur_id
                 and cigc.int_contract_item_ref_no =
                     pci.internal_contract_item_ref_no(+)
                 and pci.pcdi_id = pcdi.pcdi_id
                 and pcdi.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                    
                 and pcpd.input_output = 'Input'
                 and grd.internal_grd_ref_no(+) = cigc.internal_grd_ref_no
                 and (case when cigc.int_contract_item_ref_no is null then
                      grd.profit_center_id else pcpd.profit_center_id end) =
                     cpc.profit_center_id
                 and tdc.trade_date = pd_trade_date
                 and cs.cost_type = 'Direct Actual'
                 and cs.process_id = tdc.process_id
                 and pci.process_id = tdc.process_id
                 and pcdi.process_id = tdc.process_id
                 and pcpd.process_id = tdc.process_id
                    
                 and tdc.process_id = pc_process_id
                 and cpc.corporateid = pc_corporate_id
                 and cpc.corporateid = akc.corporate_id
                 and cs.is_deleted = 'N'
                 and cs.counter_party_id = phd.profileid(+)) t;
    --ends here
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
  end;
  procedure sp_phy_intrstat(pc_corporate_id varchar2,
                            pd_trade_date   date,
                            pc_process_id   varchar2) as
  begin
    insert into isr_intrastat_grd
      (corporate_id,
       process_id,
       eod_trade_date,
       contract_ref_no,
       contract_item_ref_no,
       gmr_ref_no,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       product_id,
       product_name,
       cp_id,
       counterparty_name,
       quality_id,
       quality_name,
       qty,
       qty_unit_id,
       price,
       price_unit_id,
       price_unit_name,
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
       vat_no,
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
       contract_type)
    --- Base metal
      select gmr.corporate_id,
             pc_process_id,
             pd_trade_date,
             pcm.contract_ref_no,
             pcm.contract_ref_no || '-' || pcdi.delivery_item_no contract_item_ref_no,
             gmr.gmr_ref_no,
             gmr.internal_gmr_ref_no,
             grd.internal_grd_ref_no,
             pcpd.product_id,
             pdm.product_desc,
             pcm.cp_id,
             phd.companyname supplier,
             pcpq.quality_template_id,
             qat.quality_name,
             grd.current_qty,
             grd.qty_unit_id,
             (case
               when iid.invoice_item_amount is not null then
                iid.new_invoice_price
               else
                invm.material_cost_per_unit
             end) invoice_invenotry_price,
             (case
               when iid.invoice_item_amount is not null then
                iid.new_invoice_price_unit_id
               else
                invm.price_unit_id
             end) invoice_inve_price_unit_id,
             (case
               when iid.invoice_item_amount is not null then
                pum_invoice.price_unit_name
               else
                pum_inven.price_unit_name
             end) invoice_inve_price_unit_name,
             gmr.bl_date shipment_date,
             gmr.loading_country_id,
             cym_load.country_name,
             gmr.loading_city_id,
             cim_load.city_name,
             gmr.loading_state_id,
             sm_load.state_name,
             cym_load.region_id,
             rem_load.region_name loading_region,
             gmr.discharge_country_id,
             cym_discharge.country_name,
             gmr.discharge_state_id,
             cim_discharge.city_name,
             gmr.discharge_state_id,
             sm_discharge.state_name,
             cym_discharge.region_id,
             rem_discharge.region_name discharge_region,
             gmr_gd.mode_of_transport,
             gmr.bl_no,
             bvd.vat_no,
             (case
               when iid.invoice_type = 'Final' then
                iid.invoice_issue_date
               else
                gmr.eff_date
             end) invoice_date,
             (case
               when iid.invoice_item_amount is not null then
                'INVOICE'
               else
                'INVENTORY'
             end) invoice_invenotry_status,
             (case
               when iid.invoice_item_amount is not null then
                iid.invoice_item_amount
               else
                invm.material_cost_per_unit * grd.current_qty
             end) invoice_invenotry_value,
             
             (case
               when iid.invoice_item_amount is not null then
                iid.invoice_currency_id
               else
                invm.price_unit_cur_id
             end) invoice_invenotry_cur_id,
             (case
               when iid.invoice_item_amount is not null then
                cm_invoice.cur_code
               else
                cm_inven.cur_code
             end) invoice_invenotry_cur_code,
             cm_cym_load.cur_id loading_country_cur,
             cm_cym_load.cur_code loading_country_code,
             cm_cym_discharge.cur_id dischagre_country_cur,
             cm_cym_discharge.cur_code dischagre_country_code,
             ak.base_cur_id,
             cm.cur_code base_cur_code,
             (case
               when iid.invoice_item_amount is not null then
                pkg_general.f_get_converted_currency_amt(gmr.corporate_id,
                                                         iid.invoice_currency_id,
                                                         ak.base_cur_id,
                                                         gmr.bl_date,
                                                         1)
               else
                pkg_general.f_get_converted_currency_amt(gmr.corporate_id,
                                                         invm.price_unit_cur_id,
                                                         ak.base_cur_id,
                                                         gmr.bl_date,
                                                         1)
             end) ex_rate_to_base,
             pkg_general.f_get_converted_currency_amt(gmr.corporate_id,
                                                      ak.base_cur_id,
                                                      cm_cym_load.cur_id,
                                                      gmr.bl_date,
                                                      1) ex_rate_base_to_nat_load,
             pkg_general.f_get_converted_currency_amt(gmr.corporate_id,
                                                      ak.base_cur_id,
                                                      cm_cym_discharge.cur_id,
                                                      gmr.bl_date,
                                                      1) ex_rate_base_to_nat_dis,
             
             qat_ppm.attribute_value,
             pcm.contract_type
        from pcm_physical_contract_main pcm,
             pcdi_pc_delivery_item pcdi,
             pci_physical_contract_item pci,
             gmr_goods_movement_record gmr,
             grd_goods_record_detail grd,
             pcpd_pc_product_definition pcpd,
             pdm_productmaster pdm,
             pcpq_pc_product_quality pcpq,
             qat_quality_attributes qat,
             phd_profileheaderdetails phd,
             cym_countrymaster cym_load,
             cim_citymaster cim_load,
             sm_state_master sm_load,
             cym_countrymaster cym_discharge,
             cim_citymaster cim_discharge,
             sm_state_master sm_discharge,
             rem_region_master rem_load,
             rem_region_master rem_discharge,
             (select gmr.internal_gmr_ref_no,
                     agmr.current_qty,
                     agmr.released_qty release_shipped_qty,
                     agmr.tt_out_qty title_transfer_out_qty,
                     (case
                       when agmr.gmr_latest_action_action_id =
                            'shipmentDetail' then
                        'Ship'
                       when agmr.gmr_latest_action_action_id = 'railDetail' then
                        'Rail'
                       when agmr.gmr_latest_action_action_id = 'truckDetail' then
                        'Truck'
                       when agmr.gmr_latest_action_action_id = 'airDetail' then
                        'Air'
                       else
                        ''
                     end) mode_of_transport
                from gmr_goods_movement_record gmr,
                     agmr_action_gmr           agmr
               where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                 and agmr.action_no = 1
                 and gmr.is_deleted = 'N'
                 and gmr.process_id = pc_process_id) gmr_gd,
             invm_cog invm,
             (select iid.internal_invoice_ref_no,
                     iid.stock_id,
                     iid.invoice_item_amount,
                     iid.invoice_currency_id,
                     new_invoice_price,
                     iss.invoice_type,
                     iss.invoice_issue_date,
                     iid.new_invoice_price_unit_id
                from iid_invoicable_item_details iid,
                     is_invoice_summary          iss
               where iss.internal_invoice_ref_no =
                     iid.internal_invoice_ref_no
                 and iss.is_active = 'Y'
                 and iss.process_id = pc_process_id) iid,
             cm_currency_master cm_cym_load,
             cm_currency_master cm_cym_discharge,
             (select gmr.internal_gmr_ref_no,
                     gmr.latest_internal_invoice_ref_no
                from gmr_goods_movement_record gmr
               where gmr.process_id = pc_process_id) lastest_gmr,
             ak_corporate ak,
             cm_currency_master cm,
             bvd_bp_vat_details bvd,
             ppu_product_price_units ppu_invoice,
             pum_price_unit_master pum_invoice,
             ppu_product_price_units ppu_inven,
             pum_price_unit_master pum_inven,
             cm_currency_master cm_invoice,
             cm_currency_master cm_inven,
             (select qat.quality_id,
                     qav.attribute_value
                from qat_quality_attributes         qat,
                     qav_quality_attribute_values   qav,
                     ppm_product_properties_mapping ppm,
                     aml_attribute_master_list      aml
               where ppm.product_id = qat.product_id
                 and ppm.attribute_id = aml.attribute_id
                 and qat.is_active = 'Y'
                 and ppm.is_active = 'Y'
                 and aml.is_active = 'Y'
                 and aml.attribute_name = 'CNCode'
                 and aml.attribute_type_id = 'OTHERS'
                 and qat.quality_id = qav.quality_id
                 and qav.attribute_id = ppm.property_id) qat_ppm
      
       where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = pci.pcdi_id
         and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
         and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.input_output = 'Input'
         and pcpd.product_id = pdm.product_id
         and pcpd.pcpd_id = pcpq.pcpd_id
         and pcpq.quality_template_id = qat.quality_id
         and pcm.cp_id = phd.profileid
         and phd.profileid = bvd.profile_id(+)
         and gmr.loading_country_id = cym_load.country_id(+)
         and gmr.loading_city_id = cim_load.city_id(+)
         and gmr.loading_state_id = sm_load.state_id(+)
         and gmr.discharge_country_id = cym_discharge.country_id(+)
         and gmr.discharge_city_id = cim_discharge.city_id(+)
         and gmr.discharge_state_id = sm_discharge.state_id(+)
         and cym_load.region_id = rem_load.region_id
         and cym_discharge.region_id = rem_discharge.region_id
         and gmr.internal_gmr_ref_no = gmr_gd.internal_gmr_ref_no
         and grd.internal_grd_ref_no = invm.internal_grd_ref_no
         and grd.internal_grd_ref_no = iid.stock_id(+)
         and cym_load.national_currency = cm_cym_load.cur_id
         and cym_discharge.national_currency = cm_cym_discharge.cur_id
         and gmr.internal_gmr_ref_no = lastest_gmr.internal_gmr_ref_no(+)
         and gmr.latest_internal_invoice_ref_no =
             lastest_gmr.latest_internal_invoice_ref_no(+)
         and gmr.corporate_id = ak.corporate_id
         and ak.base_cur_id = cm.cur_id
         and grd.is_mark_for_tolling = 'N'
         and gmr.is_deleted = 'N'
         and gmr.corporate_id = pc_corporate_id
         and invm.price_unit_id = ppu_inven.internal_price_unit_id(+)
         and ppu_inven.price_unit_id = pum_inven.price_unit_id(+)
         and iid.new_invoice_price_unit_id =
             ppu_invoice.internal_price_unit_id(+)
         and ppu_invoice.price_unit_id = pum_invoice.price_unit_id(+)
         and iid.invoice_currency_id = cm_invoice.cur_id(+)
         and invm.price_unit_cur_id = cm_inven.cur_id(+)
         and qat.quality_id = qat_ppm.quality_id(+)
         and upper(pcm.contract_type) = 'BASEMETAL'
         and pcm.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pdm.is_active = 'Y'
         and qat.is_active = 'Y'
         and invm.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and grd.process_id = pc_process_id
      union all
      --concentrates
      select gmr.corporate_id,
             pc_process_id,
             pd_trade_date,
             pcm.contract_ref_no,
             pcm.contract_ref_no || '-' || pcdi.delivery_item_no contract_item_ref_no,
             gmr.gmr_ref_no,
             gmr.internal_gmr_ref_no,
             grd.internal_grd_ref_no,
             pcpd.product_id,
             pdm.product_desc,
             pcm.cp_id,
             phd.companyname supplier,
             pcpq.quality_template_id,
             qat.quality_name,
             (case
               when pcpd.unit_of_measure = 'Wet' then
                grd.current_qty
               else
                pkg_metals_general.fn_get_assay_dry_qty(grd.product_id,
                                                        sam.ash_id,
                                                        grd.current_qty,
                                                        grd.qty_unit_id)
             end),
             grd.qty_unit_id,
             null invoice_invenotry_price,
             null invoice_inve_price_unit_id,
             null invoice_inve_price_unit_name,
             gmr.bl_date shipment_date,
             gmr.loading_country_id,
             cym_load.country_name,
             gmr.loading_city_id,
             cim_load.city_name,
             gmr.loading_state_id,
             sm_load.state_name,
             cym_load.region_id,
             rem_load.region_name loading_region,
             gmr.discharge_country_id,
             cym_discharge.country_name,
             gmr.discharge_state_id,
             cim_discharge.city_name,
             gmr.discharge_state_id,
             sm_discharge.state_name,
             cym_discharge.region_id,
             rem_discharge.region_name discharge_region,
             gmr_gd.mode_of_transport,
             gmr.bl_no,
             bvd.vat_no,
             (case
               when iid.invoice_type = 'Final' then
                iid.invoice_issue_date
               else
                gmr.eff_date
             end) invoice_date,
             (case
               when iid.invoice_item_amount is not null then
                'INVOICE'
               else
                'INVENTORY'
             end) invoice_invenotry_status,
             (case
               when iid.invoice_item_amount is not null then
                iid.invoice_item_amount
               else
                invm.material_cost_per_unit * grd.current_qty
             end) invoice_invenotry_value,
             
             (case
               when iid.invoice_item_amount is not null then
                iid.invoice_currency_id
               else
                invm.price_unit_cur_id
             end) invoice_invenotry_cur_id,
             (case
               when iid.invoice_item_amount is not null then
                cm_invoice.cur_code
               else
                cm_inven.cur_code
             end) invoice_invenotry_cur_code,
             cm_cym_load.cur_id loading_country_cur,
             cm_cym_load.cur_code loading_country_code,
             cm_cym_discharge.cur_id dischagre_country_cur,
             cm_cym_discharge.cur_code dischagre_country_code,
             ak.base_cur_id,
             cm.cur_code base_cur_code,
             (case
               when iid.invoice_item_amount is not null then
                pkg_general.f_get_converted_currency_amt(gmr.corporate_id,
                                                         iid.invoice_currency_id,
                                                         ak.base_cur_id,
                                                         gmr.bl_date,
                                                         1)
               else
                pkg_general.f_get_converted_currency_amt(gmr.corporate_id,
                                                         invm.price_unit_cur_id,
                                                         ak.base_cur_id,
                                                         gmr.bl_date,
                                                         1)
             end) ex_rate_to_base,
             pkg_general.f_get_converted_currency_amt(gmr.corporate_id,
                                                      ak.base_cur_id,
                                                      cm_cym_load.cur_id,
                                                      gmr.bl_date,
                                                      1) ex_rate_base_to_nat_load,
             pkg_general.f_get_converted_currency_amt(gmr.corporate_id,
                                                      ak.base_cur_id,
                                                      cm_cym_discharge.cur_id,
                                                      gmr.bl_date,
                                                      1) ex_rate_base_to_nat_dis,
             
             qat_ppm.attribute_value,
             pcm.contract_type
        from pcm_physical_contract_main pcm,
             pcdi_pc_delivery_item pcdi,
             pci_physical_contract_item pci,
             gmr_goods_movement_record gmr,
             grd_goods_record_detail grd,
             pcpd_pc_product_definition pcpd,
             pdm_productmaster pdm,
             pcpq_pc_product_quality pcpq,
             qat_quality_attributes qat,
             phd_profileheaderdetails phd,
             cym_countrymaster cym_load,
             cim_citymaster cim_load,
             sm_state_master sm_load,
             cym_countrymaster cym_discharge,
             cim_citymaster cim_discharge,
             sm_state_master sm_discharge,
             rem_region_master rem_load,
             rem_region_master rem_discharge,
             (select gmr.internal_gmr_ref_no,
                     agmr.current_qty,
                     agmr.released_qty release_shipped_qty,
                     agmr.tt_out_qty title_transfer_out_qty,
                     (case
                       when agmr.gmr_latest_action_action_id =
                            'shipmentDetail' then
                        'Ship'
                       when agmr.gmr_latest_action_action_id = 'railDetail' then
                        'Rail'
                       when agmr.gmr_latest_action_action_id = 'truckDetail' then
                        'Truck'
                       when agmr.gmr_latest_action_action_id = 'airDetail' then
                        'Air'
                       else
                        ''
                     end) mode_of_transport
                from gmr_goods_movement_record gmr,
                     agmr_action_gmr           agmr
               where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                 and agmr.action_no = 1
                 and gmr.is_deleted = 'N'
                 and gmr.process_id = pc_process_id) gmr_gd,
             invm_cog invm,
             (select iid.internal_invoice_ref_no,
                     iid.stock_id,
                     iid.invoice_item_amount,
                     iid.invoice_currency_id,
                     new_invoice_price,
                     iss.invoice_type,
                     iss.invoice_issue_date,
                     iid.new_invoice_price_unit_id
                from iid_invoicable_item_details iid,
                     is_invoice_summary          iss
               where iss.internal_invoice_ref_no =
                     iid.internal_invoice_ref_no
                 and iss.is_active = 'Y'
                 and iss.process_id = pc_process_id) iid,
             cm_currency_master cm_cym_load,
             cm_currency_master cm_cym_discharge,
             (select gmr.internal_gmr_ref_no,
                     gmr.latest_internal_invoice_ref_no
                from gmr_goods_movement_record gmr
               where gmr.process_id = pc_process_id) lastest_gmr,
             ak_corporate ak,
             cm_currency_master cm,
             bvd_bp_vat_details bvd,
             ppu_product_price_units ppu_invoice,
             pum_price_unit_master pum_invoice,
             ppu_product_price_units ppu_inven,
             pum_price_unit_master pum_inven,
             cm_currency_master cm_invoice,
             cm_currency_master cm_inven,
             (select qat.quality_id,
                     qav.attribute_value
                from qat_quality_attributes         qat,
                     qav_quality_attribute_values   qav,
                     ppm_product_properties_mapping ppm,
                     aml_attribute_master_list      aml
               where ppm.product_id = qat.product_id
                 and ppm.attribute_id = aml.attribute_id
                 and qat.is_active = 'Y'
                 and ppm.is_active = 'Y'
                 and aml.is_active = 'Y'
                 and aml.attribute_name = 'CNCode'
                 and aml.attribute_type_id = 'OTHERS'
                 and qat.quality_id = qav.quality_id
                 and qav.attribute_id = ppm.property_id) qat_ppm,
             sam_stock_assay_mapping sam
      
       where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = pci.pcdi_id
         and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
         and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.input_output = 'Input'
         and pcpd.product_id = pdm.product_id
         and pcpd.pcpd_id = pcpq.pcpd_id
         and pcpq.quality_template_id = qat.quality_id
         and pcm.cp_id = phd.profileid
         and phd.profileid = bvd.profile_id(+)
         and gmr.loading_country_id = cym_load.country_id(+)
         and gmr.loading_city_id = cim_load.city_id(+)
         and gmr.loading_state_id = sm_load.state_id(+)
         and gmr.discharge_country_id = cym_discharge.country_id(+)
         and gmr.discharge_city_id = cim_discharge.city_id(+)
         and gmr.discharge_state_id = sm_discharge.state_id(+)
         and cym_load.region_id = rem_load.region_id
         and cym_discharge.region_id = rem_discharge.region_id
         and gmr.internal_gmr_ref_no = gmr_gd.internal_gmr_ref_no
         and grd.internal_grd_ref_no = invm.internal_grd_ref_no(+)
         and grd.internal_grd_ref_no = iid.stock_id(+)
         and cym_load.national_currency = cm_cym_load.cur_id(+)
         and cym_discharge.national_currency = cm_cym_discharge.cur_id(+)
         and gmr.internal_gmr_ref_no = lastest_gmr.internal_gmr_ref_no(+)
         and gmr.latest_internal_invoice_ref_no =
             lastest_gmr.latest_internal_invoice_ref_no(+)
         and gmr.corporate_id = ak.corporate_id
         and ak.base_cur_id = cm.cur_id
         and grd.is_mark_for_tolling = 'N'
         and gmr.is_deleted = 'N'
         and gmr.corporate_id = pc_corporate_id
         and invm.price_unit_id = ppu_inven.internal_price_unit_id(+)
         and ppu_inven.price_unit_id = pum_inven.price_unit_id(+)
         and iid.new_invoice_price_unit_id =
             ppu_invoice.internal_price_unit_id(+)
         and ppu_invoice.price_unit_id = pum_invoice.price_unit_id(+)
         and iid.invoice_currency_id = cm_invoice.cur_id(+)
         and invm.price_unit_cur_id = cm_inven.cur_id(+)
         and qat.quality_id = qat_ppm.quality_id(+)
         and grd.internal_grd_ref_no = sam.internal_grd_ref_no
         and sam.is_latest_pricing_assay = 'Y'
         and upper(pcm.contract_type) = 'CONCENTRATES'
         and pcm.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pdm.is_active = 'Y'
         and qat.is_active = 'Y'
         and invm.process_id(+) = pc_process_id
         and pcm.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and grd.process_id = pc_process_id;
  
    commit;
  end;

  procedure sp_phy_contract_status(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2) as
  begin
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
             main_table.companyname,
             main_table.contract_status,
             main_table.invoice_cur_id,
             main_table.invoice_cur_code,
             main_table.element_id,
             main_table.attribute_name,
             main_table.open_qty,
             main_table.qty_unit_id,
             main_table.qty_unit,
             --  nvl(stock_table.landed_qty, 0) landed_qty,
             --   nvl(pfc_data.priced_qty, 0) priced_qty,
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
        from (select pcm.internal_contract_ref_no,
                     pcm.contract_ref_no,
                     pcm.corporate_id,
                     akc.corporate_name,
                     pcm.cp_id,
                     dipq.element_id,
                     aml.attribute_name,
                     phd.companyname,
                     pcm.contract_status,
                     pcpd.product_id,
                     pdm.product_desc,
                     dipq.payable_qty open_qty,
                     dipq.qty_unit_id,
                     qum.qty_unit,
                     pcm.invoice_currency_id invoice_cur_id,
                     cm.cur_code invoice_cur_code
                from pcm_physical_contract_main     pcm,
                     phd_profileheaderdetails       phd,
                     pcpd_pc_product_definition     pcpd,
                     pdm_productmaster              pdm,
                     pcdi_pc_delivery_item          pcdi,
                     dipq_delivery_item_payable_qty dipq,
                     qum_quantity_unit_master       qum,
                     cm_currency_master             cm,
                     ak_corporate                   akc,
                     aml_attribute_master_list      aml,
                     pcmte_pcm_tolling_ext          pcmte
               where pcm.cp_id = phd.profileid
                 and pcm.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpd.product_id = pdm.product_id
                 and pcm.internal_contract_ref_no =
                     pcdi.internal_contract_ref_no
                 and pcm.contract_type = 'CONCENTRATES'
                 and pcpd.input_output = 'Input'
                 and pcm.corporate_id = pc_corporate_id
                 and pcdi.pcdi_id = dipq.pcdi_id
                 and dipq.qty_unit_id = qum.qty_unit_id
                 and pcm.invoice_currency_id = cm.cur_id
                 and pcm.corporate_id = akc.corporate_id
                 and pcm.internal_contract_ref_no =
                     pcmte.int_contract_ref_no
                 and pcmte.tolling_service_type = 'S'
                 and dipq.element_id = aml.attribute_id
                 and dipq.process_id = pc_process_id
                 and pcpd.process_id = pc_process_id
                 and pcdi.process_id = pc_process_id
                 and pcm.process_id = pc_process_id
                 and aml.is_active = 'Y'
                 and cm.is_active = 'Y'
                 and qum.is_active = 'Y'
                 and phd.is_active = 'Y'
                 and pcdi.is_active = 'Y'
                 and pcm.is_active = 'Y'
                 and dipq.is_active = 'Y'
                 and pcpd.is_active = 'Y') main_table,
             (select gmr.internal_contract_ref_no,
                     spq.element_id,
                     sum(spq.payable_qty) landed_qty
                from pcm_physical_contract_main pcm,
                     pcmte_pcm_tolling_ext      pcmte,
                     gmr_goods_movement_record  gmr,
                     spq_stock_payable_qty      spq
               where pcm.internal_contract_ref_no =
                     gmr.internal_contract_ref_no
                 and pcm.internal_contract_ref_no =
                     pcmte.int_contract_ref_no
                 and pcmte.tolling_service_type = 'S'
                 and gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
                 and gmr.landed_qty > 0
                 and pcm.is_active = 'Y'
                 and spq.is_active = 'Y'
                 and gmr.is_deleted = 'N'
                 and spq.process_id = pc_process_id
                 and pcm.process_id = pc_process_id
                 and gmr.process_id = pc_process_id
               group by gmr.internal_contract_ref_no,
                        spq.element_id) stock_table,
             (select pcm.internal_contract_ref_no,
                     poch.element_id,
                     sum(pfd.qty_fixed) priced_qty
                from pcm_physical_contract_main     pcm,
                     pcmte_pcm_tolling_ext          pcmte,
                     pcdi_pc_delivery_item          pcdi,
                     poch_price_opt_call_off_header poch,
                     pocd_price_option_calloff_dtls pocd,
                     pofh_price_opt_fixation_header pofh,
                     pfd_price_fixation_details     pfd
               where pcm.internal_contract_ref_no =
                     pcdi.internal_contract_ref_no
                 and pcm.internal_contract_ref_no =
                     pcmte.int_contract_ref_no
                 and pcmte.tolling_service_type = 'S'
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
                 and pfd.as_of_date <= pd_trade_date
               group by pcm.internal_contract_ref_no,
                        poch.element_id) pfc_data
       where main_table.internal_contract_ref_no =
             stock_table.internal_contract_ref_no(+)
         and main_table.element_id = stock_table.element_id(+)
         and main_table.internal_contract_ref_no =
             pfc_data.internal_contract_ref_no(+)
         and main_table.element_id = pfc_data.element_id(+);
    commit;
  end;
  procedure sp_feed_consumption_report(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2) as
  begin
  
    insert into fcr_feed_consumption_report
      (process_id,
       eod_trade_date,
       corporate_id,
       corporate_name,
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
       tc_amount,
       rc_amount,
       penality_amount,
       inv_add_charges,
       invoice_cur_id,
       invoice_cur_code,
       base_cur_id,
       base_cur_code)
      select pc_process_id,
             temp.invoice_issue_date,
             temp.corporate_id,
             akc.corporate_name,
             temp.gmr_ref_no,
             temp.product_id,
             pdm.product_desc,
             temp.quality_id,
             qat.quality_name,
             pcm.cp_id,
             phd.companyname,
             temp.element_id,
             aml.attribute_name,
             temp.gmr_qty,
             temp.qty_unit_id,
             qum_gmr.qty_unit,
             sum(temp.assay_qty) assay_qty,
             temp.assay_qty_unit assay_qty_unit_id,
             qum_assay.qty_unit,
             sum(temp.payable_qty) payable_qty,
             temp.payable_qty_unit payable_qty_unit_id,
             qum_paybale.qty_unit,
             sum(temp.tcharges_amount) tcharges_amount,
             sum(temp.rcharges_amount) rcharges_amount,
             sum(temp.penalty_amount) penalty_amount,
             oth_chagres.other_charges other_charges,
             temp.invoice_currency_id,
             cm_invoice.cur_code,
             akc.base_cur_id,
             cm_base.cur_code
        from ( -- payable qty,assay qty
              select gmr.gmr_ref_no,
                      grd.internal_gmr_ref_no,
                      grd.internal_grd_ref_no,
                      gmr.internal_contract_ref_no,
                      gmr.corporate_id,
                      grd.product_id,
                      grd.quality_id,
                      grd.profit_center_id,
                      spq.element_id,
                      (case
                        when pcpd.unit_of_measure = 'Wet' then
                         pkg_metals_general.fn_get_assay_dry_qty(gmr.product_id,
                                                                 iam.ash_id,
                                                                 gmr.current_qty,
                                                                 gmr.qty_unit_id)
                        else
                         gmr.current_qty
                      end) gmr_qty,
                      gmr.qty_unit_id,
                      spq.assay_content assay_qty,
                      spq.qty_unit_id assay_qty_unit,
                      spq.payable_qty payable_qty,
                      spq.qty_unit_id payable_qty_unit,
                      0 tcharges_amount,
                      0 rcharges_amount,
                      0 penalty_amount,
                      0 other_charges,
                      iid.invoice_currency_id,
                      iss.invoice_issue_date
                from gmr_goods_movement_record gmr,
                      grd_goods_record_detail grd,
                      iid_invoicable_item_details iid,
                      is_invoice_summary iss,
                      spq_stock_payable_qty spq,
                      pcpd_pc_product_definition pcpd,
                      iam_invoice_assay_mapping iam,
                      ash_assay_header ash,
                      asm_assay_sublot_mapping asm,
                      pqca_pq_chemical_attributes pqca,
                      rm_ratio_master rm,
                      (select gmr.internal_gmr_ref_no,
                              gmr.latest_internal_invoice_ref_no
                         from gmr_goods_movement_record gmr
                        where gmr.process_id = pc_process_id) lastest_gmr
               where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                 and grd.internal_grd_ref_no = iid.stock_id
                 and iid.stock_id = spq.internal_grd_ref_no
                 and iss.internal_invoice_ref_no =
                     iid.internal_invoice_ref_no
                 and iss.is_active = 'Y'
                 and iss.process_id = pc_process_id
                 and gmr.internal_gmr_ref_no =
                     lastest_gmr.internal_gmr_ref_no(+)
                 and gmr.latest_internal_invoice_ref_no =
                     lastest_gmr.latest_internal_invoice_ref_no(+)
                 and gmr.process_id = pc_process_id
                 and grd.process_id = pc_process_id
                 and spq.process_id = pc_process_id
                 and gmr.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
                 and gmr.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpd.process_id = pc_process_id
                 and pcpd.input_output = 'Input'
                 and iid.internal_invoice_ref_no =
                     iam.internal_invoice_ref_no
                 and iid.stock_id = iam.internal_grd_ref_no
                 and iam.ash_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and spq.element_id = pqca.element_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr.is_pass_through = 'Y'
                 and grd.tolling_stock_type = 'Clone Stock'
              union all
              -- tc charges
              select gmr.gmr_ref_no,
                     grd.internal_gmr_ref_no,
                     grd.internal_grd_ref_no,
                     gmr.internal_contract_ref_no,
                     gmr.corporate_id,
                     grd.product_id,
                     grd.quality_id,
                     grd.profit_center_id,
                     intc.element_id,
                     (case
                       when pcpd.unit_of_measure = 'Wet' then
                        pkg_metals_general.fn_get_assay_dry_qty(gmr.product_id,
                                                                iam.ash_id,
                                                                gmr.current_qty,
                                                                gmr.qty_unit_id)
                       else
                        gmr.current_qty
                     end) gmr_qty,
                     gmr.qty_unit_id,
                     0 assay_qty,
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
                     intc.tcharges_amount tcharges_amount,
                     0 rcharges_amount,
                     0 penalty_amount,
                     0 other_charges,
                     iid.invoice_currency_id,
                     iss.invoice_issue_date
                from gmr_goods_movement_record gmr,
                     grd_goods_record_detail grd,
                     iid_invoicable_item_details iid,
                     is_invoice_summary iss,
                     intc_inv_treatment_charges intc,
                     iam_invoice_assay_mapping iam,
                     ash_assay_header ash,
                     asm_assay_sublot_mapping asm,
                     pqca_pq_chemical_attributes pqca,
                     rm_ratio_master rm,
                     pcpd_pc_product_definition pcpd,
                     (select gmr.internal_gmr_ref_no,
                             gmr.latest_internal_invoice_ref_no
                        from gmr_goods_movement_record gmr
                       where gmr.process_id = pc_process_id) lastest_gmr
               where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                 and grd.internal_grd_ref_no = iid.stock_id
                 and iss.internal_invoice_ref_no =
                     iid.internal_invoice_ref_no
                 and iss.is_active = 'Y'
                 and iss.process_id = pc_process_id
                 and iid.internal_invoice_ref_no =
                     intc.internal_invoice_ref_no
                 and iid.stock_id = intc.grd_id
                 and iid.internal_invoice_ref_no =
                     iam.internal_invoice_ref_no
                 and iid.stock_id = iam.internal_grd_ref_no
                 and iam.ash_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and intc.element_id = pqca.element_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr.internal_gmr_ref_no =
                     lastest_gmr.internal_gmr_ref_no(+)
                 and gmr.latest_internal_invoice_ref_no =
                     lastest_gmr.latest_internal_invoice_ref_no(+)
                 and gmr.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
                 and gmr.process_id = pc_process_id
                 and grd.process_id = pc_process_id
                 and gmr.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpd.process_id = pc_process_id
                 and pcpd.input_output = 'Input'
                 and gmr.is_pass_through = 'Y'
                 and grd.tolling_stock_type = 'Clone Stock'
              union all
              -- rc charges
              select gmr.gmr_ref_no,
                     grd.internal_gmr_ref_no,
                     grd.internal_grd_ref_no,
                     gmr.internal_contract_ref_no,
                     gmr.corporate_id,
                     grd.product_id,
                     grd.quality_id,
                     grd.profit_center_id,
                     inrc.element_id,
                     (case
                       when pcpd.unit_of_measure = 'Wet' then
                        pkg_metals_general.fn_get_assay_dry_qty(gmr.product_id,
                                                                iam.ash_id,
                                                                gmr.current_qty,
                                                                gmr.qty_unit_id)
                       else
                        gmr.current_qty
                     end) gmr_qty,
                     gmr.qty_unit_id,
                     0 assay_qty,
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
                     0 tcharges_amount,
                     inrc.rcharges_amount rcharges_amount,
                     0 penalty_amount,
                     0 other_charges,
                     iid.invoice_currency_id,
                     iss.invoice_issue_date
                from gmr_goods_movement_record gmr,
                     grd_goods_record_detail grd,
                     iid_invoicable_item_details iid,
                     is_invoice_summary iss,
                     inrc_inv_refining_charges inrc,
                     iam_invoice_assay_mapping iam,
                     ash_assay_header ash,
                     asm_assay_sublot_mapping asm,
                     pqca_pq_chemical_attributes pqca,
                     rm_ratio_master rm,
                     pcpd_pc_product_definition pcpd,
                     (select gmr.internal_gmr_ref_no,
                             gmr.latest_internal_invoice_ref_no
                        from gmr_goods_movement_record gmr
                       where gmr.process_id = pc_process_id) lastest_gmr
               where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                 and grd.internal_grd_ref_no = iid.stock_id
                 and iss.internal_invoice_ref_no =
                     iid.internal_invoice_ref_no
                 and iss.is_active = 'Y'
                 and iss.process_id = pc_process_id
                 and iid.internal_invoice_ref_no =
                     inrc.internal_invoice_ref_no
                 and iid.stock_id = inrc.grd_id
                 and iid.internal_invoice_ref_no =
                     iam.internal_invoice_ref_no
                 and iid.stock_id = iam.internal_grd_ref_no
                 and iam.ash_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and inrc.element_id = pqca.element_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr.internal_gmr_ref_no =
                     lastest_gmr.internal_gmr_ref_no(+)
                 and gmr.latest_internal_invoice_ref_no =
                     lastest_gmr.latest_internal_invoice_ref_no(+)
                 and gmr.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
                 and gmr.process_id = pc_process_id
                 and grd.process_id = pc_process_id
                 and gmr.is_pass_through = 'Y'
                 and gmr.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpd.process_id = pc_process_id
                 and pcpd.input_output = 'Input'
                 and grd.tolling_stock_type = 'Clone Stock'
              union all
              -- penality charges
              select gmr.gmr_ref_no,
                     grd.internal_gmr_ref_no,
                     grd.internal_grd_ref_no,
                     gmr.internal_contract_ref_no,
                     gmr.corporate_id,
                     grd.product_id,
                     grd.quality_id,
                     grd.profit_center_id,
                     iepd.element_id,
                     (case
                       when pcpd.unit_of_measure = 'Wet' then
                        pkg_metals_general.fn_get_assay_dry_qty(gmr.product_id,
                                                                iam.ash_id,
                                                                gmr.current_qty,
                                                                gmr.qty_unit_id)
                       else
                        gmr.current_qty
                     end) gmr_qty,
                     gmr.qty_unit_id,
                     0 assay_qty,
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
                     0 tcharges_amount,
                     0 rcharges_amount,
                     iepd.element_penalty_amount penalty_amount,
                     0 other_charges,
                     iid.invoice_currency_id,
                     iss.invoice_issue_date
                from gmr_goods_movement_record gmr,
                     grd_goods_record_detail grd,
                     iid_invoicable_item_details iid,
                     is_invoice_summary iss,
                     iepd_inv_epenalty_details iepd,
                     iam_invoice_assay_mapping iam,
                     ash_assay_header ash,
                     asm_assay_sublot_mapping asm,
                     pqca_pq_chemical_attributes pqca,
                     rm_ratio_master rm,
                     pcpd_pc_product_definition pcpd,
                     (select gmr.internal_gmr_ref_no,
                             gmr.latest_internal_invoice_ref_no
                        from gmr_goods_movement_record gmr
                       where gmr.process_id = pc_process_id) lastest_gmr
               where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                 and grd.internal_grd_ref_no = iid.stock_id
                 and iss.internal_invoice_ref_no =
                     iid.internal_invoice_ref_no
                 and iss.is_active = 'Y'
                 and iss.process_id = pc_process_id
                 and iid.internal_invoice_ref_no =
                     iepd.internal_invoice_ref_no
                 and iid.stock_id = iepd.stock_id
                 and iid.internal_invoice_ref_no =
                     iam.internal_invoice_ref_no
                 and iid.stock_id = iam.internal_grd_ref_no
                 and iam.ash_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and iepd.element_id = pqca.element_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr.internal_gmr_ref_no =
                     lastest_gmr.internal_gmr_ref_no(+)
                 and gmr.latest_internal_invoice_ref_no =
                     lastest_gmr.latest_internal_invoice_ref_no(+)
                 and gmr.is_deleted = 'N'
                 and gmr.is_pass_through = 'Y'
                 and gmr.process_id = pc_process_id
                 and grd.process_id = pc_process_id
                 and gmr.corporate_id = pc_corporate_id
                 and gmr.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpd.process_id = pc_process_id
                 and pcpd.input_output = 'Input'
                 and grd.tolling_stock_type = 'Clone Stock') temp,
             ak_corporate akc,
             pdm_productmaster pdm,
             qat_quality_attributes qat,
             aml_attribute_master_list aml,
             cm_currency_master cm_invoice,
             cm_currency_master cm_base,
             pcm_physical_contract_main pcm,
             phd_profileheaderdetails phd,
             qum_quantity_unit_master qum_gmr,
             qum_quantity_unit_master qum_assay,
             qum_quantity_unit_master qum_paybale,
             (select iss.internal_invoice_ref_no,
                     gmr.internal_gmr_ref_no,
                     iss.total_other_charge_amount other_charges
                from gmr_goods_movement_record   gmr,
                     iid_invoicable_item_details iid,
                     is_invoice_summary          iss
               where gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                 and iid.internal_invoice_ref_no =
                     iss.internal_invoice_ref_no
                 and gmr.latest_internal_invoice_ref_no =
                     iss.internal_invoice_ref_no
                 and iss.is_active = 'Y'
                 and iss.process_id = pc_process_id
                 and gmr.process_id = pc_process_id) oth_chagres
       where temp.corporate_id = akc.corporate_id
         and temp.product_id = pdm.product_id
         and temp.quality_id = qat.quality_id
         and temp.element_id = aml.attribute_id
         and temp.invoice_currency_id = cm_invoice.cur_id
         and akc.base_cur_id = cm_base.cur_id
         and temp.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.process_id = pc_process_id
         and pcm.cp_id = phd.profileid
         and temp.qty_unit_id = qum_gmr.qty_unit_id
         and temp.assay_qty_unit = qum_assay.qty_unit_id
         and temp.payable_qty_unit = qum_paybale.qty_unit_id
         and temp.internal_gmr_ref_no = oth_chagres.internal_gmr_ref_no(+)
       group by temp.invoice_issue_date,
                pc_process_id,
                temp.corporate_id,
                akc.corporate_name,
                temp.gmr_ref_no,
                temp.product_id,
                pdm.product_desc,
                temp.quality_id,
                qat.quality_name,
                temp.element_id,
                aml.attribute_name,
                temp.assay_qty_unit,
                temp.payable_qty_unit,
                temp.invoice_currency_id,
                cm_invoice.cur_code,
                akc.base_cur_id,
                cm_base.cur_code,
                pcm.cp_id,
                phd.companyname,
                temp.gmr_qty,
                temp.qty_unit_id,
                qum_gmr.qty_unit,
                qum_assay.qty_unit,
                qum_paybale.qty_unit,
                oth_chagres.other_charges;
    commit;
  end;
  procedure sp_stock_monthly_yeild(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2) as
  
  begin
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
       conc_qty_unit) with ytd_data as
      (select ypd.internal_gmr_ref_no,
              ypd.element_id,
              gmr.gmr_ref_no,
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
              pdm_productmaster         pdm
        where ypd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
          and ypd.internal_action_ref_no = axs.internal_action_ref_no
          and ypd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
          and ypd.element_id = aml.attribute_id
          and aml.underlying_product_id = pdm.product_id(+)
          and gmr.process_id = pc_process_id
          and gmr.corporate_id = pc_corporate_id
          and gmr.is_deleted = 'N'
          and aml.is_active = 'Y'
          and pdm.is_active = 'Y'
          and agmr.action_no = '1'
          and ypd.is_active = 'Y')
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
        from (select sac.internal_gmr_ref_no,
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
                     pqca.is_final_assay,
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
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
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
                        pqca.is_final_assay,
                        pqca.is_elem_for_pricing,
                        pqca.is_deductible,
                        pcm.cp_id,
                        pqca.is_returnable) stock,
             ytd_data ytd,
             ak_corporate akc
       where stock.internal_gmr_ref_no = ytd.internal_gmr_ref_no
         and stock.element_id = ytd.element_id
         and ytd.corporate_id = akc.corporate_id
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
  exception
    when others then
      dbms_output.put_line('Error in CRC calculation');
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
  vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count number := 1;
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
           pd_prev_trade_date as prev_trade_date
      from poud_phy_open_unreal_daily poud,
           pci_physical_contract_item pci,
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
           poud.internal_contract_item_ref_no;
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
           pd_prev_trade_date as prev_trade_date
      from poud_phy_open_unreal_daily poud,
           pci_physical_contract_item pci,
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
       and poud.pcdi_id = poud_prev.pcdi_id;
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
           poud.net_m2m_price m_to_m_settlement_price,
           0 m_to_m_diff,
           md.m2m_loc_incoterm_deviation m_to_m_loc_inco_deviation,
           0 m_to_m_loc_deviation,
           0 m_to_m_inco_deviation,
           poud_prev.net_m2m_price prev_m_to_m_settlement_price,
           0 prev_m_to_m_diff,
           md_prev.m2m_loc_incoterm_deviation prev_m_to_m_loc_inco_deviation,
           0 prev_m_to_m_loc_deviation,
           0 prev_m_to_m_inco_deviation,
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
           poud.net_m2m_price m_to_m_settlement_price,
           0 m_to_m_diff,
           md.m2m_loc_incoterm_deviation m_to_m_loc_inco_deviation,
           0 m_to_m_loc_deviation,
           0 m_to_m_inco_deviation,
           poud_prev.net_m2m_price prev_m_to_m_settlement_price,
           0 prev_m_to_m_diff,
           md_prev.m2m_loc_incoterm_deviation prev_m_to_m_loc_inco_deviation,
           0 prev_m_to_m_loc_deviation,
           0 prev_m_to_m_inco_deviation,
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
  --
  --- Quantity Modification on Contract
  --
  for unreal_pnl_attr_mcq_rows in unreal_pnl_attr_mcq
  loop
    if unreal_pnl_attr_mcq_rows.contract_type = 'P' then
      vn_pnlc_due_to_attr := ((unreal_pnl_attr_mcq_rows.curr_eod_qty -
                             nvl(unreal_pnl_attr_mcq_rows.prev_eod_qty, 0)) *
                             (unreal_pnl_attr_mcq_rows.prev_net_m2m_price -
                             unreal_pnl_attr_mcq_rows.prev_eod_contract_price));
    elsif unreal_pnl_attr_mcq_rows.contract_type = 'S' then
      vn_pnlc_due_to_attr := ((unreal_pnl_attr_mcq_rows.curr_eod_qty -
                             nvl(unreal_pnl_attr_mcq_rows.prev_eod_qty, 0)) *
                             (unreal_pnl_attr_mcq_rows.prev_eod_contract_price -
                             unreal_pnl_attr_mcq_rows.prev_net_m2m_price));
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
  --
  -- Change in Price
  --
  for unreal_pnl_attr_price_rows in unreal_pnl_attr_price
  loop
    if unreal_pnl_attr_price_rows.contract_type = 'P' then
      vn_pnlc_due_to_attr := ((unreal_pnl_attr_price_rows.prev_eod_contract_price -
                             nvl(unreal_pnl_attr_price_rows.curr_eod_contract_price,
                                   0)) * (nvl(unreal_pnl_attr_price_rows.prev_eod_qty,
                                               0)));
    elsif unreal_pnl_attr_price_rows.contract_type = 'S' then
      vn_pnlc_due_to_attr := ((unreal_pnl_attr_price_rows.curr_eod_contract_price -
                             nvl(unreal_pnl_attr_price_rows.prev_eod_contract_price,
                                   0)) * (nvl(unreal_pnl_attr_price_rows.prev_eod_qty,
                                               0)));
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
  --
  -- Change in Location differentials
  --
  for unreal_pnl_attr_ldc_rows in unreal_pnl_attr_ldc
  loop
    if unreal_pnl_attr_ldc_rows.contract_type = 'P' then
      vn_pnlc_due_to_attr := ((unreal_pnl_attr_ldc_rows.m_to_m_loc_inco_deviation -
                             nvl(unreal_pnl_attr_ldc_rows.prev_m_to_m_loc_inco_deviation,
                                   0)) *
                             (nvl(unreal_pnl_attr_ldc_rows.prev_eod_qty, 0)));
    elsif unreal_pnl_attr_ldc_rows.contract_type = 'S' then
      vn_pnlc_due_to_attr := ((unreal_pnl_attr_ldc_rows.prev_m_to_m_loc_inco_deviation -
                             nvl(unreal_pnl_attr_ldc_rows.m_to_m_loc_inco_deviation,
                                   0)) *
                             (nvl(unreal_pnl_attr_ldc_rows.prev_eod_qty, 0)));
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
       m_to_m_loc_inco_deviation,
       prev_m_to_m_loc_inco_deviation,
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
       unreal_pnl_attr_ldc_rows.m_to_m_loc_inco_deviation,
       unreal_pnl_attr_ldc_rows.prev_m_to_m_loc_inco_deviation,
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
  --
  -- M2M Price Change
  --
  for unreal_pnl_attr_m2m_sp_rows in unreal_pnl_attr_m2m_sp
  loop
    if unreal_pnl_attr_m2m_sp_rows.contract_type = 'P' then
      vn_pnlc_due_to_attr := ((unreal_pnl_attr_m2m_sp_rows.m_to_m_settlement_price -
                             nvl(unreal_pnl_attr_m2m_sp_rows.prev_m_to_m_settlement_price,
                                   0)) * (nvl(unreal_pnl_attr_m2m_sp_rows.prev_eod_qty,
                                               0)));
    elsif unreal_pnl_attr_m2m_sp_rows.contract_type = 'S' then
      vn_pnlc_due_to_attr := ((unreal_pnl_attr_m2m_sp_rows.prev_m_to_m_settlement_price -
                             nvl(unreal_pnl_attr_m2m_sp_rows.m_to_m_settlement_price,
                                   0)) * (nvl(unreal_pnl_attr_m2m_sp_rows.prev_eod_qty,
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
       m_to_m_settlement_price,
       prev_m_to_m_settlement_price,
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
       unreal_pnl_attr_m2m_sp_rows.m_to_m_settlement_price,
       unreal_pnl_attr_m2m_sp_rows.prev_m_to_m_settlement_price,
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
  select pc_process_id, poud.corporate_id,
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
         nvl(poud.trade_day_pnl_in_val_cur, 0) - nvl(t.pnlc_due_to_attr, 0) pnlc_due_to_attr,
         
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
     and poud.process_id = t.process_id;

exception
  when others then
    vobj_error_log.extend;
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
    sp_insert_error_log(vobj_error_log);
end;
end; 
/
