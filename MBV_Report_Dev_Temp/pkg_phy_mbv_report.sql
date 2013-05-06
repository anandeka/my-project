create or replace package pkg_phy_mbv_report is

  -- Author  : JANARDHANA
  -- Created : 4/24/2013 6:00:32 PM
  -- Purpose : Metal Balance Valuation
  procedure sp_run_mbv_report(pc_corporate_id varchar2,
                              pd_trade_date   date,
                              pc_process_id   varchar2,
                              pc_process      varchar2,
                              pc_user_id      varchar2);
  procedure sp_calc_pf_data(pc_corporate_id varchar2,
                            pd_trade_date   date,
                            pc_process_id   varchar2,
                            pc_process      varchar2,
                            pc_user_id      varchar2);
  procedure sp_calc_derivative_diff_report(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_process      varchar2,
                                           pc_user_id      varchar2);
end;
/
create or replace package body pkg_phy_mbv_report is
  procedure sp_run_mbv_report(pc_corporate_id varchar2,
                              pd_trade_date   date,
                              pc_process_id   varchar2,
                              pc_process      varchar2,
                              pc_user_id      varchar2) is
    vn_eel_error_count number := 1;
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vc_error_msg       varchar2(100);
  begin
    vc_error_msg := 'sp_calc_pf_data';
    sp_calc_pf_data(pc_corporate_id,
                    pd_trade_date,
                    pc_process_id,
                    pc_process,
                    pc_user_id);
    vc_error_msg := 'sp_calc_derivative_diff_report';
    sp_calc_derivative_diff_report(pc_corporate_id,
                                   pd_trade_date,
                                   pc_process_id,
                                   pc_process,
                                   pc_user_id);
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_mbv_report.sp_run_mbv_report',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           '  Error Msg: ' ||
                                                           vc_error_msg,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
  end;
  procedure sp_calc_pf_data(pc_corporate_id varchar2,
                            pd_trade_date   date,
                            pc_process_id   varchar2,
                            pc_process      varchar2,
                            pc_user_id      varchar2) is
    vn_eel_error_count number := 1;
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vc_previous_eom_id varchar2(15);
    vc_error_msg       varchar2(100);
  
  begin
    --
    -- Previous EOM ID
    --
    vc_error_msg := 'Get Previous EOM ID';
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
      when others then
        null;
    end;
    --
    -- Population of 2 sections below
    -- New Price Fixations for this month
    -- List of Balance Price Fixations
    --
    insert into pfrd_price_fix_report_detail
      (process_id,
       eod_trade_date,
       section_name,
       corporate_id,
       corporate_name,
       product_id,
       product_name,
       cp_id,
       cp_name,
       internal_contract_ref_no,
       delivery_item_no,
       contract_ref_no_del_item_no,
       internal_gmr_ref_no,
       gmr_ref_no,
       price_fixed_date,
       pf_ref_no,
       fixed_qty,
       price,
       price_unit_id,
       price_unit_cur_id,
       price_unit_cur_code,
       price_unit_weight_unit_id,
       price_unit_weight_unit,
       price_unit_weight,
       price_unit_name,
       fx_price_to_base_cur,
       price_in_base_cur,
       consumed_qty,
       purchase_sales,
       fixation_value)
      select pc_process_id,
             pd_trade_date,
             decode(pfd.is_balance_pricing,
                    'N',
                    'New Price Fixations For This Month',
                    'List Of Balance Price Fixations') section_name,
             pc_corporate_id,
             akc.corporate_name,
             pdm_aml.product_id,
             pdm_aml.product_desc,
             pcm.cp_id,
             pcm.cp_name,
             pcm.internal_contract_ref_no,
             pcdi.delivery_item_no,
             pcm.contract_ref_no || '(' || pcdi.delivery_item_no || ')' contract_ref_no_del_item_no,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             pfd.hedge_correction_date price_fixation_date,
             axs.action_ref_no as pf_ref_no,
             pfd.qty_fixed,
             pfd.user_price,
             pfd.price_unit_id,
             ppu.cur_id,
             cm.cur_code,
             ppu.weight_unit_id,
             qum.qty_unit,
             ppu.weight,
             ppu.price_unit_name,
             nvl(pfd.fx_to_base, 1) fx_to_base,
             pfd.user_price * nvl(pfd.fx_to_base, 1) price_in_base,
             nvl(pfd.allocated_qty, 0) allocated_qty,
             decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
             pfd.qty_fixed * pfd.user_price * nvl(pfd.fx_to_base, 1) *
             ucm.multiplication_factor / nvl(ppu.weight, 1)
        from pfd_price_fixation_details pfd,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             poch_price_opt_call_off_header poch,
             pcdi_pc_delivery_item pcdi,
             pcm_physical_contract_main pcm,
             v_ppu_pum ppu,
             axs_action_summary axs,
             cm_currency_master cm,
             qum_quantity_unit_master qum,
             aml_attribute_master_list aml,
             pdm_productmaster pdm_aml,
             ak_corporate akc,
             (select gmr.internal_gmr_ref_no,
                     gmr.gmr_ref_no
                from gmr_goods_movement_record gmr
               where gmr.process_id = pc_process_id
                 and gmr.is_deleted = 'N') gmr,
             ucm_unit_conversion_master ucm
       where pfd.pofh_id = pofh.pofh_id
         and pofh.pocd_id = pocd.pocd_id
         and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
         and pocd.poch_id = poch.poch_id
         and poch.pcdi_id = pcdi.pcdi_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pfd.hedge_correction_action_ref_no =
             axs.internal_action_ref_no(+)
         and pocd.element_id = aml.attribute_id
         and aml.underlying_product_id = pdm_aml.product_id
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pofh.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pfd.is_active = 'Y'
         and pcdi.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and trunc(pfd.hedge_correction_date, 'mm') =
             trunc(pd_trade_date, 'mm')
         and pfd.price_unit_id = ppu.product_price_unit_id
         and ppu.cur_id = cm.cur_id
         and ppu.weight_unit_id = qum.qty_unit_id
         and akc.corporate_id = pcm.corporate_id
         and ucm.from_qty_unit_id = ppu.weight_unit_id
         and ucm.to_qty_unit_id = pocd.qty_to_be_fixed_unit_id;
    commit;
    --
    -- List of Consumed Fixations for Realization
    --
    -- List of Balance Price Fixations from previous Month
    --
    insert into pfrd_price_fix_report_detail
      (process_id,
       eod_trade_date,
       section_name,
       purchase_sales,
       corporate_id,
       corporate_name,
       product_id,
       product_name,
       cp_id,
       cp_name,
       internal_contract_ref_no,
       delivery_item_no,
       contract_ref_no_del_item_no,
       price_fixed_date,
       pf_ref_no,
       fixed_qty,
       price,
       price_unit_id,
       price_unit_cur_id,
       price_unit_cur_code,
       price_unit_weight_unit_id,
       price_unit_weight_unit,
       price_unit_weight,
       price_unit_name,
       fx_price_to_base_cur,
       price_in_base_cur,
       consumed_qty)
      select pc_process_id,
             pd_trade_date,
             'List of Balance Price Fixations From Previous Month',
             purchase_sales,
             corporate_id,
             corporate_name,
             product_id,
             product_name,
             cp_id,
             cp_name,
             internal_contract_ref_no,
             delivery_item_no,
             contract_ref_no_del_item_no,
             price_fixed_date,
             pf_ref_no,
             fixed_qty,
             price,
             price_unit_id,
             price_unit_cur_id,
             price_unit_cur_code,
             price_unit_weight_unit_id,
             price_unit_weight_unit,
             price_unit_weight,
             price_unit_name,
             fx_price_to_base_cur,
             price_in_base_cur,
             consumed_qty
        from pfrd_price_fix_report_detail pfrd
       where pfrd.process_id = vc_previous_eom_id
         and pfrd.section_name = 'List Of Balance Price Fixations';
    commit;
    --
    -- Insert Header Data
    --
    insert into pfrh_price_fix_report_header
      (process_id,
       eod_trade_date,
       corporate_id,
       corporate_name,
       product_id,
       product_name,
       priced_arrived_qty,
       priced_delivered_qty,
       realized_qty,
       realized_qty_prev_month,
       realized_qty_current_month,
       realized_value,
       purchase_price_fix_qty,
       wap_purchase_price_fixations,
       sales_price_fixation_qty,
       wap_sales_price_fixations,
       price_fix_qty_purchase_ob,
       price_fix_qty_sales_ob,
       price_fix_qty_purchase_new,
       price_fix_qty_sales_new)
      select pc_process_id,
             pd_trade_date,
             corporate_id,
             corporate_name,
             product_id,
             product_name,
             0, --priced_arrived_qty,
             0, --priced_delivered_qty,
             0, --realized_qty,
             0, --realized_qty_prev_month,
             0, --realized_qty_current_month,
             0, --realized_value,
             0, --purchase_price_fix_qty,
             0, --wap_purchase_price_fixations,
             0, --sales_price_fixation_qty,
             0, --wap_sales_price_fixations,
             0, --price_fix_qty_purchase_ob,
             0, --price_fix_qty_sales_ob,
             0, --price_fix_qty_purchase_new,
             0 --price_fix_qty_sales_new)
        from pfrd_price_fix_report_detail pfrd
       where pfrd.process_id = pc_process_id
       group by corporate_id,
                corporate_name,
                product_id,
                product_name;
    commit;
    --
    -- Update Priced and Arrived Qty and Priced and Delivered Qty
    -- 
    for cur_pcs in (select sum(nvl(case
                                     when pcs.purchase_sales = 'P' then
                                      pcs.priced_arrived_qty
                                   
                                     else
                                     
                                      0
                                   end,
                                   0)) priced_arrived_qty,
                           sum(nvl(case
                                     when pcs.purchase_sales = 'S' then
                                      pcs.priced_arrived_qty
                                   
                                     else
                                     
                                      0
                                   end,
                                   0)) priced_delivered_qty,
                           pcs.product_id
                      from pcs_purchase_contract_status pcs
                     where pcs.process_id = pc_process_id
                     group by pcs.product_id)
    loop
      update pfrh_price_fix_report_header pfrh
         set pfrh.priced_arrived_qty   = cur_pcs.priced_arrived_qty,
             pfrh.priced_delivered_qty = cur_pcs.priced_delivered_qty,
             pfrh.realized_qty         = least(cur_pcs.priced_arrived_qty,
                                               cur_pcs.priced_delivered_qty)
       where pfrh.process_id = pc_process_id
         and pfrh.product_id = cur_pcs.product_id;
    end loop;
    commit;
    --
    -- Update Previous Month Realized Qty, Price Fixation Qty OB for Purchase and Sales
    --
    for cur_pfhr_prev_real_qty in (select pfrh_prev.product_id,
                                          pfrh_prev.realized_qty realized_qty_prev_month,
                                          pfrh_prev.price_fix_qty_purchase_new price_fix_qty_purchase_ob,
                                          pfrh_prev.price_fix_qty_sales_new price_fix_qty_sales_ob
                                     from pfrh_price_fix_report_header pfrh_prev
                                    where pfrh_prev.process_id =
                                          vc_previous_eom_id)
    loop
      update pfrh_price_fix_report_header pfrh
         set pfrh.realized_qty_prev_month = cur_pfhr_prev_real_qty.realized_qty_prev_month,
         pfrh.price_fix_qty_purchase_ob = cur_pfhr_prev_real_qty.price_fix_qty_purchase_ob,
         pfrh.price_fix_qty_sales_ob = cur_pfhr_prev_real_qty.price_fix_qty_sales_ob
       where pfrh.process_id = pc_process_id
         and pfrh.product_id = cur_pfhr_prev_real_qty.product_id;
    end loop;
    commit;
    --
    -- Update Realized Value
    --
    for cur_realized_value in (select pfrd.product_id,
                                      sum(pfrd.fixation_value) fixation_value
                                 from pfrd_price_fix_report_detail pfrd
                                where pfrd.process_id = pc_process_id
                                  and pfrd.section_name =
                                      'List of Consumed Fixations for Realization'
                                group by pfrd.product_id)
    loop
      update pfrh_price_fix_report_header pfrh
         set pfrh.realized_value = cur_realized_value.fixation_value
       where pfrh.process_id = pc_process_id
         and pfrh.product_id = cur_realized_value.product_id;
    end loop;
    commit;
  
    --
    -- Open Purchase And Sales Price Fixation Qty
    --
    for cur_pf_qty in (
select        pfrd.product_id,
              sum(nvl(case
                        when pfrd.purchase_sales = 'Purchase' then
                         pfrd.fixed_qty
                        else
                         0
                      end,
                      0)) opem_purchase_price_fixq_ty,
              sum(nvl(case
                        when pfrd.purchase_sales = 'Sales' then
                         pfrd.fixed_qty
                        else
                         0
                      end,
                      0)) opem_sales_price_fixq_ty,
             case when   sum(nvl(case
                        when pfrd.purchase_sales = 'Purchase' then
                         pfrd.fixed_qty
                        else
                         0
                      end,
                      0)) = 0 then 0 
                      else
                      sum(pfrd.fixation_value) / 
                       sum(nvl(case
                        when pfrd.purchase_sales = 'Purchase' then
                         pfrd.fixed_qty
                        else
                         0
                      end,
                      0)) end wap_purchase_price_fixations,
                      case when   sum(nvl(case
                        when pfrd.purchase_sales = 'Sales' then
                         pfrd.fixed_qty
                        else
                         0
                      end,
                      0)) = 0 then 0 
                      else
                      sum(pfrd.fixation_value) / 
                       sum(nvl(case
                        when pfrd.purchase_sales = 'Sales' then
                         pfrd.fixed_qty
                        else
                         0
                      end,
                      0)) end     wap_sales_price_fixations                                 
                         from pfrd_price_fix_report_detail pfrd
                        where pfrd.process_id = pc_process_id
                          and pfrd.section_name =
                              'List of Balance Price Fixations'
                        group by pfrd.product_id)
    loop
      update pfrh_price_fix_report_header pfrh
         set pfrh.purchase_price_fix_qty   = cur_pf_qty.opem_purchase_price_fixq_ty,
             pfrh.sales_price_fixation_qty = cur_pf_qty.opem_sales_price_fixq_ty,
             pfrh.wap_purchase_price_fixations = cur_pf_qty.wap_purchase_price_fixations,
             pfrh.wap_sales_price_fixations = cur_pf_qty.wap_sales_price_fixations
       where pfrh.process_id = pc_process_id
         and pfrh.product_id = cur_pf_qty.product_id;
    end loop;
    commit;
    --
    -- New Purchase and Sales New PF Qty
    --
    for cur_fix_qty in (
select pfrd.product_id,
       sum(nvl(case
                 when pfrd.purchase_sales = 'Purchase' then
                  pfrd.fixed_qty
                 else
                  0
               end,
               0)
           ) purchase_price_fix_qty,
       sum(nvl(case
                 when pfrd.purchase_sales = 'Sales' then
                  pfrd.fixed_qty
                 else
                  0
               end,
               0)
           ) sales_price_fix_qty
  from pfrd_price_fix_report_detail pfrd
 where pfrd.process_id = pc_process_id
   and pfrd.section_name = 'New Price Fixations for this month'
 group by pfrd.product_id)
    loop
      update pfrh_price_fix_report_header pfrh
         set pfrh.price_fix_qty_purchase_new = cur_fix_qty.purchase_price_fix_qty,
         pfrh.price_fix_qty_sales_new = cur_fix_qty.sales_price_fix_qty
       where pfrh.process_id = pc_process_id
         and pfrh.product_id = cur_fix_qty.product_id;
    end loop;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_mbv_report.sp_calc_pf_data',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           '  Error Msg: ' ||
                                                           vc_error_msg,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
  end;
  procedure sp_calc_derivative_diff_report(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_process      varchar2,
                                           pc_user_id      varchar2) is
    vn_eel_error_count number := 1;
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vc_error_msg       varchar2(100);
  begin
    vc_error_msg := 'Start';
    insert into ddr_derivative_diff_report
      (process_id,
       eod_trade_date,
       corporate_id,
       corporate_name,
       exchange_id,
       exchange_name,
       product_id,
       product_name,
       instrument_id,
       instrument_name,
       trade_date,
       internal_derivative_ref_no,
       derivative_ref_no,
       external_ref_no,
       trade_type,
       trade_qty,
       trade_price,
       trade_price_unit,
       prompt_date,
       fx_trade_to_base_ccy,
       trade_price_in_base_ccy,
       trade_value_in_base_ccy,
       valuation_price,
       fx_valuation_to_base_ccy,
       valuation_price_in_base_ccy,
       month_end_price,
       month_end_price_in_base_ccy,
       ref_price_diff,
       value_diff_ref_price_diff)
      select dpd.process_id,
             dpd.eod_trade_date,
             dpd.corporate_id,
             dpd.corporate_name,
             dpd.exchange_id,
             dpd.exchange_name,
             dpd.product_id,
             dpd.product_name,
             dpd.instrument_id,
             dpd.instrument_name,
             dpd.trade_date,
             dpd.internal_derivative_ref_no,
             dpd.derivative_ref_no,
             dpd.external_ref_no,
             dpd.trade_type,
             dpd.open_quantity,
             dpd.trade_price,
             dpd.trade_price_cur_code || '/' || dpd.trade_price_weight ||
             dpd.trade_price_weight_unit trade_price_unit,
             dpd.dr_id_name prompt_date,
             dpd.trade_cur_to_base_exch_rate fx_trade_to_base_ccy,
             dpd.trade_price_in_base trade_price_in_base_ccy,
             dpd.settlement_price as valuation_price,
             cet.exch_rate fx_valuation_to_base_ccy,
             dpd.trade_value_in_base trade_value_in_base_ccy,
             dpd.sett_price_in_base valuation_price_in_base_ccy,
             tip.price month_end_price,
             tip.price * cet.exch_rate month_end_price_in_base_ccy,
             case
               when dpd.trade_type = 'Sell' then
                (tip.price * cet.exch_rate) - dpd.sett_price_in_base
               else
                dpd.sett_price_in_base - (tip.price * cet.exch_rate)
             end ref_price_diff,
             dpd.open_quantity * (case
               when dpd.trade_type = 'Sell' then
                (tip.price / nvl(dpd.trade_price_weight, 1) * cet.exch_rate) -
                dpd.sett_price_in_base
               else
                dpd.sett_price_in_base - (tip.price * cet.exch_rate)
             end) * ucm.multiplication_factor value_diff_ref_price_diff
        from dpd_derivative_pnl_daily   dpd,
             tip_temp_instrument_price  tip,
             cet_corporate_exch_rate    cet,
             ucm_unit_conversion_master ucm,
             tdc_trade_date_closure     tdc
       where dpd.process_id = pc_process_id
         and dpd.instrument_type in ('Future', 'Forwards')
         and dpd.instrument_id = tip.instrument_id
         and tip.corporate_id = pc_corporate_id
         and dpd.pnl_type = 'Unrealized'
         and dpd.sett_price_cur_id = cet.from_cur_id
         and dpd.base_cur_id = cet.to_cur_id
         and ucm.from_qty_unit_id = dpd.trade_price_weight_unit_id
         and ucm.to_qty_unit_id = dpd.quantity_unit_id
         and tdc.process_id = dpd.process_id
         and tdc.process = pc_process;
    commit;
    vc_error_msg := 'End';
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_mbv_report.sp_calc_derivative_diff_report',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           '  Error Msg: ' ||
                                                           vc_error_msg,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
  end;
end;
/
