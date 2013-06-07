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
  procedure sp_calc_mbv_report(pc_corporate_id varchar2,
                               pd_trade_date   date,
                               pc_process_id   varchar2,
                               pc_process      varchar2,
                               pc_user_id      varchar2);
  procedure sp_calc_di_valuation_price(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process      varchar2,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2);
  procedure sp_phy_postion_diff_report(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process      varchar2,
                                       pc_process_id   varchar2);
  procedure sp_allocation_report(pc_corporate_id varchar2,
                                 pd_trade_date   date,
                                 pc_process      varchar2,
                                 pc_process_id   varchar2);
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
  vc_error_msg := 'sp_calc_di_valuation_price';
  sp_calc_di_valuation_price(pc_corporate_id,
                             pd_trade_date,
                             pc_process,
                             pc_process_id,
                             pc_user_id);
  vc_error_msg := 'sp_calc_derivative_diff_report';
  sp_calc_derivative_diff_report(pc_corporate_id,
                                 pd_trade_date,
                                 pc_process_id,
                                 pc_process,
                                 pc_user_id);
  vc_error_msg := 'sp_allocation_report';
  sp_allocation_report(pc_corporate_id,
                       pd_trade_date,
                       pc_process,
                       pc_process_id);
  vc_error_msg := 'sp_phy_postion_diff_report';
  sp_phy_postion_diff_report(pc_corporate_id,
                             pd_trade_date,
                             pc_process,
                             pc_process_id);
  vc_error_msg := 'sp_calc_mbv_report';
  sp_calc_mbv_report(pc_corporate_id,
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
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm ||
                                                         '  Error Msg: ' ||
                                                         vc_error_msg,
                                                         '',
                                                         pc_process,
                                                         pc_user_id,
                                                         sysdate,
                                                         pd_trade_date);
    sp_insert_error_log(vobj_error_log);
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
    vd_prev_eom_date   date;
    vn_qty_to_consume  number;
  
  begin
    --
    -- Previous EOM ID
    --
    vc_error_msg := 'Get Previous EOM ID';
    begin
      select tdc.process_id, tdc.trade_date
        into vc_previous_eom_id,
             vd_prev_eom_date
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
    -- New PFC for this Month
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
       instrument_id,
       instrument_name,
       cp_id,
       cp_name,
       pcdi_id,
       internal_contract_ref_no,
       delivery_item_no,
       contract_ref_no_del_item_no,
       internal_gmr_ref_no,
       gmr_ref_no,
       price_fixed_date,
       is_new_pfc,
       internal_action_ref_no,
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
       fixation_value,
       fixed_unit_base_qty_factor,
       pfd_id,
       element_id,
       contract_type)
      select pc_process_id,
             pd_trade_date,
             'New PFC for this Month' section_name,
             decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
             pc_corporate_id,
             akc.corporate_name,
             pdm_aml.product_id,
             pdm_aml.product_desc,
             vped.instrument_id,
             vped.instrument_name,
             pcm.cp_id,
             pcm.cp_name,
             vped.pcdi_id,
             pcm.internal_contract_ref_no,
             pcdi.delivery_item_no,
             pcm.contract_ref_no || '(' || pcdi.delivery_item_no || ')' contract_ref_no_del_item_no,
             null gmr_ref_no,
             null internal_gmr_ref_no,
             pfd.hedge_correction_date price_fixation_date,
             'Y',
             axs.internal_action_ref_no,
             axs.action_ref_no as pf_ref_no,
             pfd.qty_fixed * ucm.multiplication_factor fixed_qty,
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
             0 consumed_qty,
             (case
               when pcm.purchase_sales = 'P' then
                1
               else
                (-1)
             end) * pfd.qty_fixed * pfd.user_price * nvl(pfd.fx_to_base, 1) *
             ucm.multiplication_factor fixation_value,
             ucm.multiplication_factor,
             pfd.pfd_id,
             aml.attribute_id,
             pcm.contract_type
        from pcm_physical_contract_main     pcm,
             pcdi_pc_delivery_item          pcdi,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pfam_price_fix_action_mapping  pfam,
             axs_action_summary             axs,
             aml_attribute_master_list      aml,
             pdm_productmaster              pdm_aml,
             v_pcdi_exchange_detail         vped,
             v_ppu_pum                      ppu,
             cm_currency_master             cm,
             qum_quantity_unit_master       qum,
             ak_corporate                   akc,
             ucm_unit_conversion_master     ucm,
             qum_quantity_unit_master       qum_qty
       where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = poch.pcdi_id
         and poch.poch_id = pocd.poch_id
         and pocd.pocd_id = pofh.pocd_id
         and pofh.pofh_id = pfd.pofh_id
         and pfd.pfd_id = pfam.pfd_id
         and pfam.internal_action_ref_no = axs.internal_action_ref_no(+)
         and pocd.element_id = aml.attribute_id
         and vped.pcdi_id = pcdi.pcdi_id
         and vped.element_id = aml.attribute_id(+)
         and aml.underlying_product_id = pdm_aml.product_id
         and pfd.price_unit_id = ppu.product_price_unit_id
         and ppu.cur_id = cm.cur_id
         and ppu.weight_unit_id = qum.qty_unit_id
         and akc.corporate_id = pcm.corporate_id
         and ucm.from_qty_unit_id = pocd.qty_to_be_fixed_unit_id
         and ucm.to_qty_unit_id = pdm_aml.base_quantity_unit
         and pdm_aml.base_quantity_unit = qum_qty.qty_unit_id
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pcm.is_active = 'Y'
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pofh.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pfd.is_active = 'Y'
         and pfam.is_active = 'Y'
         and pcm.contract_type = 'CONCENTRATES'
         and pfd.hedge_correction_date > vd_prev_eom_date
         and pfd.hedge_correction_date <= pd_trade_date
     union all
      select pc_process_id,
             pd_trade_date,
             'New PFC for this Month' section_name,
             decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
             pc_corporate_id,
             akc.corporate_name,
             pdm.product_id,
             pdm.product_desc,
             vped.instrument_id,
             vped.instrument_name,
             pcm.cp_id,
             pcm.cp_name,
             vped.pcdi_id,
             pcm.internal_contract_ref_no,
             pcdi.delivery_item_no,
             pcm.contract_ref_no || '(' || pcdi.delivery_item_no || ')' contract_ref_no_del_item_no,
             null gmr_ref_no,
             null internal_gmr_ref_no,
             pfd.hedge_correction_date price_fixation_date,
             'Y',
             axs.internal_action_ref_no,
             axs.action_ref_no as pf_ref_no,
             pfd.qty_fixed * ucm.multiplication_factor fixed_qty,
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
             0 consumed_qty,
             (case
               when pcm.purchase_sales = 'P' then
                1
               else
                (-1)
             end) * pfd.qty_fixed * pfd.user_price * nvl(pfd.fx_to_base, 1) *
             ucm.multiplication_factor fixation_value,
             ucm.multiplication_factor,
             pfd.pfd_id,
             vped.element_id,
             pcm.contract_type
        from pcm_physical_contract_main     pcm,
             pcdi_pc_delivery_item          pcdi,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pfam_price_fix_action_mapping  pfam,
             axs_action_summary             axs,
             v_pcdi_exchange_detail         vped,
             pcpd_pc_product_definition     pcpd,
             pdm_productmaster              pdm,
             v_ppu_pum                      ppu,
             cm_currency_master             cm,
             qum_quantity_unit_master       qum,
             ak_corporate                   akc,
             ucm_unit_conversion_master     ucm,
             qum_quantity_unit_master       qum_qty
       where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = poch.pcdi_id
         and poch.poch_id = pocd.poch_id
         and pocd.pocd_id = pofh.pocd_id
         and pofh.pofh_id = pfd.pofh_id
         and pfd.pfd_id = pfam.pfd_id
         and pfam.internal_action_ref_no = axs.internal_action_ref_no(+)
         and vped.pcdi_id = pcdi.pcdi_id
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.product_id = pdm.product_id
         and pfd.price_unit_id = ppu.product_price_unit_id
         and ppu.cur_id = cm.cur_id
         and ppu.weight_unit_id = qum.qty_unit_id
         and akc.corporate_id = pcm.corporate_id
         and ucm.from_qty_unit_id = pocd.qty_to_be_fixed_unit_id
         and ucm.to_qty_unit_id = pdm.base_quantity_unit
         and pdm.base_quantity_unit = qum_qty.qty_unit_id
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and pcm.is_active = 'Y'
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pofh.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pfd.is_active = 'Y'
         and pfam.is_active = 'Y'
         and pcpd.is_active = 'Y'
         and pcm.contract_type = 'BASEMETAL'
         and pfd.hedge_correction_date > vd_prev_eom_date
         and pfd.hedge_correction_date <= pd_trade_date;
    commit;
    --
    -- Need to insert PFRH here and Update the realized qty, since we have to use the 
    -- Realized qty per product and distribute it across price fixations in asecnding order
    --
    --
    -- Insert Header Raw Data
    --
    insert into pfrh_price_fix_report_header
      (process_id,
       eod_trade_date,
       corporate_id,
       corporate_name,
       product_id,
       product_name,
       instrument_id,
       instrument_name,
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
             instrument_id,
             instrument_name,
             0 priced_arrived_qty,
             0 priced_delivered_qty,
             0 realized_qty,
             0 realized_qty_prev_month,
             0 realized_qty_current_month,
             0 realized_value,
             0 purchase_price_fix_qty,
             0 wap_purchase_price_fixations,
             0 sales_price_fixation_qty,
             0 wap_sales_price_fixations,
             0 price_fix_qty_purchase_ob,
             0 price_fix_qty_sales_ob,
             0 price_fix_qty_purchase_new,
             0 price_fix_qty_sales_new
        from pfrd_price_fix_report_detail pfrd
       where pfrd.process_id = pc_process_id
       group by corporate_id,
                corporate_name,
                product_id,
                product_name,
                instrument_id,
                instrument_name;
    commit;
    
      --
    -- Update Previous Month Realized Qty, Price Fixation Qty OB for Purchase and Sales
    --
    for cur_pfhr_prev_real_qty in (select pfrh_prev.product_id,
                                          pfrh_prev.instrument_id,
                                          pfrh_prev.realized_qty realized_qty_prev_month,
                                          pfrh_prev.price_fix_qty_purchase_new price_fix_qty_purchase_ob,
                                          pfrh_prev.price_fix_qty_sales_new price_fix_qty_sales_ob
                                     from pfrh_price_fix_report_header pfrh_prev
                                    where pfrh_prev.process_id = vc_previous_eom_id)
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
    -- Update Priced and Arrived Qty and Priced and Delivered Qty
    -- 
for cur_pcs in (
select sum(nvl(case
                 when css.purchase_sales = 'P' then
                  css.priced_arrived_qty
                 else
                  0
               end,
               0)) priced_arrived_qty,
       sum(nvl(case
                 when css.purchase_sales = 'S' then
                  css.priced_arrived_qty
                 else
                  0
               end,
               0)) priced_delivered_qty,
       css.product_id
  from css_contract_status_summary css
 where css.process_id = pc_process_id
 group by css.product_id)
    loop
      update pfrh_price_fix_report_header pfrh
         set pfrh.priced_arrived_qty   = cur_pcs.priced_arrived_qty,
             pfrh.priced_delivered_qty = cur_pcs.priced_delivered_qty,
             pfrh.realized_qty         = least(cur_pcs.priced_arrived_qty, cur_pcs.priced_delivered_qty)
       where pfrh.process_id = pc_process_id
         and pfrh.product_id = cur_pcs.product_id;
    end loop;
    commit;
    
    --
    -- Update Realized Qty Current Month = (Realized Qty - Realized Qty Last EOM)
    --
    update pfrh_price_fix_report_header pfrh
    set pfrh.realized_qty_current_month = pfrh.realized_qty - pfrh.realized_qty_prev_month
     where pfrh.process_id = pc_process_id;
    --
    -- Update consumed qty for the above data from Purchase / Sales Contract Status which is
    -- already updated in PFRH column REALIZED_QTY_CURRENT_MONTH
    --
    for cur_consumed_qty in(
 select pfrh.product_id,
        pfrh.realized_qty_current_month consumed_qty
   from pfrh_price_fix_report_header pfrh
  where pfrh.process_id = pc_process_id) loop
     vn_qty_to_consume := cur_consumed_qty.consumed_qty;
         for cur_fixation in (
         select pfrd.fixed_qty,
                pfrd.internal_action_ref_no
           from pfrd_price_fix_report_detail pfrd
          where pfrd.process_id = pc_process_id
            and pfrd.product_id = cur_consumed_qty.product_id
          order by to_number(substr(pfrd.internal_action_ref_no, 5))) loop
         If cur_fixation.fixed_qty <= vn_qty_to_consume then
             Update pfrd_price_fix_report_detail pfrd
             set pfrd.consumed_qty = abs(vn_qty_to_consume - cur_fixation.fixed_qty) 
             -- If remianing qty is 10 and fixed is 20 and qty to consume is 10,
             -- then 10-20 = -10, it should be 10 hence absolute
             where pfrd.process_id = pc_process_id
             and pfrd.product_id = cur_consumed_qty.product_id
             and pfrd.internal_action_ref_no = cur_fixation.internal_action_ref_no;
             vn_qty_to_consume := vn_qty_to_consume - cur_fixation.fixed_qty;
         end if;
         If vn_qty_to_consume <= 0 then -- Everything is consumed for this Product
            exit;
         end if;
         end loop;
     end loop;
    commit;
    --
    -- List of Consumed Fixations for Realization
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
       instrument_id,
       instrument_name,
       cp_id,
       cp_name,
       pcdi_id,
       internal_contract_ref_no,
       delivery_item_no,
       contract_ref_no_del_item_no,
       internal_gmr_ref_no,
       gmr_ref_no,
       price_fixed_date,
       is_new_pfc,
       internal_action_ref_no,
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
       fixation_value,
       pfd_id,
       element_id,
       contract_type)
      select pc_process_id,
             pd_trade_date,
             'List of Consumed Fixations for Realization' section_name,
             purchase_sales,
             corporate_id,
             corporate_name,
             product_id,
             product_name,
             instrument_id,
             instrument_name,
             cp_id,
             cp_name,
             pcdi_id,
             internal_contract_ref_no,
             delivery_item_no,
             contract_ref_no_del_item_no,
             internal_gmr_ref_no,
             gmr_ref_no,
             price_fixed_date,
             'N', --is_new_pfc,    
             internal_action_ref_no,
             pf_ref_no,
             pfrd.consumed_qty,
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
             0 consumed_qty, -- Not applicable for this section
             (case
               when purchase_sales = 'P' then
                1
               else
                (-1)
             end) * (consumed_qty) * price_in_base_cur *
             fixed_unit_base_qty_factor,
             pfd_id,
             element_id,
             contract_type
        from pfrd_price_fix_report_detail pfrd
       where pfrd.process_id = pc_process_id
         and pfrd.consumed_qty > 0
         and pfrd.section_name = 'New PFC for this Month';
       commit;
    -- 
    -- List of Balance Price Fixations
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
       instrument_id,
       instrument_name,
       cp_id,
       cp_name,
       pcdi_id,
       internal_contract_ref_no,
       delivery_item_no,
       contract_ref_no_del_item_no,
       internal_gmr_ref_no,
       gmr_ref_no,
       price_fixed_date,
       is_new_pfc,
       internal_action_ref_no,
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
       fixation_value,
       pfd_id,
       element_id,
       contract_type,
       fixed_unit_base_qty_factor)
      select pc_process_id,
             pd_trade_date,
             'List of Balance Price Fixations' section_name,
             purchase_sales,
             corporate_id,
             corporate_name,
             product_id,
             product_name,
             instrument_id,
             instrument_name,
             cp_id,
             cp_name,
             pcdi_id,
             internal_contract_ref_no,
             delivery_item_no,
             contract_ref_no_del_item_no,
             internal_gmr_ref_no,
             gmr_ref_no,
             price_fixed_date,
             'N', --is_new_pfc,    
             internal_action_ref_no,
             pf_ref_no,
             fixed_qty - consumed_qty,
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
             0 consumed_qty, -- Not applicable for this section
             (case
               when purchase_sales = 'Purchase' then
                1
               else
                (-1)
             end) * (fixed_qty - consumed_qty) * price_in_base_cur *
             fixed_unit_base_qty_factor,
             pfd_id,
             element_id,
             contract_type,
             fixed_unit_base_qty_factor
        from pfrd_price_fix_report_detail pfrd
       where pfrd.process_id = pc_process_id
         and (pfrd.fixed_qty - pfrd.consumed_qty) <> 0
         and pfrd.section_name = 'New PFC for this Month'
         ;
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
       instrument_id,
       instrument_name,
       cp_id,
       cp_name,
       pcdi_id,
       internal_contract_ref_no,
       delivery_item_no,
       contract_ref_no_del_item_no,
       internal_gmr_ref_no,
       gmr_ref_no,
       price_fixed_date,
       is_new_pfc,
       internal_action_ref_no,
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
       fixation_value,
       pfd_id,
       element_id,
       contract_type,
       fixed_unit_base_qty_factor)
      select pc_process_id,
             pd_trade_date,
             'List of Balance Price Fixations from previous Month' section_name,
             purchase_sales,
             corporate_id,
             corporate_name,
             product_id,
             product_name,
             instrument_id,
             instrument_name,
             cp_id,
             cp_name,
             pcdi_id,
             internal_contract_ref_no,
             delivery_item_no,
             contract_ref_no_del_item_no,
             internal_gmr_ref_no,
             gmr_ref_no,
             price_fixed_date,
             is_new_pfc,
             internal_action_ref_no,
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
             fixation_value,
             pfd_id,
             element_id,
             contract_type,
             fixed_unit_base_qty_factor
        from pfrd_price_fix_report_detail pfrd
       where pfrd.process_id = vc_previous_eom_id
         and pfrd.section_name = 'List of Balance Price Fixations';
    commit;
    
    --
    -- Update Realized Value
    --
    for cur_realized_value in (select pfrd.product_id,
                                      sum(pfrd.fixation_value) fixation_value
                                 from pfrd_price_fix_report_detail pfrd
                                where pfrd.process_id = pc_process_id
                                  and pfrd.section_name = 'List of Consumed Fixations For Realization'
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
    select    pfrd.product_id,
              sum(nvl(case
                        when pfrd.purchase_sales = 'Purchase' then
                         pfrd.fixed_qty * pfrd.fixed_unit_base_qty_factor
                        else
                         0
                      end,
                      0)) opem_purchase_price_fix_qty,
              sum(nvl(case
                        when pfrd.purchase_sales = 'Sales' then
                         pfrd.fixed_qty * pfrd.fixed_unit_base_qty_factor
                        else
                         0
                      end,
                      0)) opem_sales_price_fix_qty,
             case when  sum(nvl(case
                        when pfrd.purchase_sales = 'Purchase' then
                         pfrd.fixed_qty * pfrd.fixed_unit_base_qty_factor
                        else
                         0
                      end,
                      0)) = 0 then 0 
             else
                      sum(case
                        when pfrd.purchase_sales = 'Purchase' then pfrd.fixation_value else 0 end) / 
                       sum(nvl(case
                        when pfrd.purchase_sales = 'Purchase' then
                         pfrd.fixed_qty * pfrd.fixed_unit_base_qty_factor
                        else
                         0
                         end,
             0)) end wap_purchase_price_fixations,
             case when   sum(nvl(case
                        when pfrd.purchase_sales = 'Sales' then
                         pfrd.fixed_qty * pfrd.fixed_unit_base_qty_factor
                        else
                         0
                      end,
                      0)) = 0 then 0 
             else
                      sum( case
                        when pfrd.purchase_sales = 'Sales' then pfrd.fixation_value * -1 else 0 end ) / 
                       sum(nvl(case
                        when pfrd.purchase_sales = 'Sales' then
                         pfrd.fixed_qty * pfrd.fixed_unit_base_qty_factor
                        else
                         0
                      end,
             0)) end wap_sales_price_fixations                                 
             from pfrd_price_fix_report_detail pfrd
             where pfrd.process_id = pc_process_id
             and pfrd.section_name = 'List of Balance Price Fixations'
             group by pfrd.product_id)
    loop
      update pfrh_price_fix_report_header pfrh
         set pfrh.purchase_price_fix_qty   = cur_pf_qty.opem_purchase_price_fix_qty,
             pfrh.sales_price_fixation_qty = cur_pf_qty.opem_sales_price_fix_qty,
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
                  pfrd.fixed_qty * pfrd.fixed_unit_base_qty_factor
                 else
                  0
               end,
               0)) purchase_price_fix_qty,
       sum(nvl(case
                 when pfrd.purchase_sales = 'Sales' then
                  pfrd.fixed_qty * pfrd.fixed_unit_base_qty_factor
                 else
                  0
               end,
               0)) sales_price_fix_qty
  from pfrd_price_fix_report_detail pfrd
 where pfrd.process_id = pc_process_id
   and pfrd.section_name = 'New PFC for this Month'
 group by pfrd.product_id)
    loop
      update pfrh_price_fix_report_header pfrh
         set pfrh.price_fix_qty_purchase_new = cur_fix_qty.purchase_price_fix_qty,
         pfrh.price_fix_qty_sales_new = cur_fix_qty.sales_price_fix_qty
       where pfrh.process_id = pc_process_id
         and pfrh.product_id = cur_fix_qty.product_id;
    end loop;
    commit;
  
    --
    -- Populate DI level Weighted Price in DIWAP_DI_WEIGHTED_AVG_PRICE
    --
insert into diwap_di_weighted_avg_price
  (process_id,
   eod_trade_date,
   purchase_sales,
   corporate_id,
   corporate_name,
   product_id,
   product_name,
   instrument_id,
   instrument_name,
   pcdi_id,
   contractt_type,
   weighted_avg_price,
   wap_price_unit_id,
   wap_price_unit_name,
   wap_price_cur_id,
   wap_price_cur_code,
   wap_price_weight_unit_id,
   wap_price_weight_unit,
   wap_price_weight,
   element_id,
   element_name)
  select process_id,
         eod_trade_date,
         purchase_sales,
         corporate_id,
         corporate_name,
         pfrd.product_id,
         product_name,
         instrument_id,
         instrument_name,
         pcdi_id,
         contract_type,
         sum(case
               when pfrd.purchase_sales = 'Purchase' then
                pfrd.fixation_value
               else
                -1 * pfrd.fixation_value
             end) / sum(pfrd.fixed_qty * pfrd.fixed_unit_base_qty_factor),
         pfrd.price_unit_id,
         pfrd.price_unit_name,
         cm.cur_id,
         cm.cur_code,
         qum.qty_unit_id,
         qum.qty_unit,
         ppu.weight,
         pfrd.element_id,
         aml.attribute_name element_name
    from pfrd_price_fix_report_detail pfrd,
         aml_attribute_master_list    aml,
         v_ppu_pum                    ppu,
         cm_currency_master           cm,
         qum_quantity_unit_master     qum
   where pfrd.process_id = pc_process_id
     and pfrd.element_id = aml.attribute_id(+)
     and pfrd.price_unit_id = ppu.price_unit_id
     and ppu.cur_id = cm.cur_id
     and ppu.weight_unit_id = qum.qty_unit_id
     and pfrd.section_name = 'New PFC for this Month'
     and pfrd.fixed_qty * pfrd.fixed_unit_base_qty_factor <> 0
   group by process_id,
            eod_trade_date,
            purchase_sales,
            corporate_id,
            corporate_name,
            pfrd.product_id,
            product_name,
            instrument_id,
            instrument_name,
            pcdi_id,
            contract_type,
            pfrd.price_unit_id,
            pfrd.price_unit_name,
            cm.cur_id,
            cm.cur_code,
            qum.qty_unit_id,
            qum.qty_unit,
            ppu.weight,
            pfrd.element_id,
            aml.attribute_name;
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
      sp_insert_error_log(vobj_error_log);                                                           
  end;
  procedure sp_calc_derivative_diff_report(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_process      varchar2,
                                         pc_user_id      varchar2) is
  vn_eel_error_count number := 1;
  vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
  vc_error_msg       varchar2(100);
  cursor mbv_ddr is
    select dpd.process_id,
           dpd.eod_trade_date,
           dpd.corporate_id,
           dpd.corporate_name,
           dpd.derivative_prodct_id,
           dpd.derivative_prodct_name,
           dpd.exchange_id,
           dpd.exchange_name,
           dpd.instrument_id,
           dpd.instrument_name,
           dpd.internal_derivative_ref_no,
           dpd.derivative_ref_no,
           dpd.external_ref_no,
           dpd.trade_date,
           dpd.trade_type,
           dpd.open_quantity,
           dpd.quantity_unit,
           dpd.quantity_unit_id,
           dpd.trade_price,
           dpd.trade_price_cur_code || '/' || dpd.trade_price_weight ||
           dpd.trade_price_weight_unit trade_price_unit,
           dpd.trade_price_unit_id,
           dpd.dr_id_name,
           dpd.settlement_price,
           dpd.sett_price_cur_code || '/' || dpd.sett_price_weight ||
           dpd.sett_price_weight_unit sett_price_unit,
           dpd.sett_price_unit_id,
           dpd.trade_value_in_trade_ccy,
           dpd.market_value_in_trade_ccy,
           dpd.pnl_in_trade_cur,
           dpd.pnl_in_base_cur,
           dpd.trade_cur_to_base_exch_rate,
           tip.price month_end_price,
           pum.price_unit_name month_end_price_unit,
           tip.price_unit_id month_end_price_unit_id,
           dpd.base_cur_id,
           dpd.base_cur_code,
           dpd.trade_cur_id,
           dpd.trade_cur_code,
           pum.cur_id mep_price_cur_id,
           pum.weight mep_price_weight,
           pum.weight_unit_id mep_price_weight_unit_id,
           dpd.trade_price_cur_id,
           dpd.trade_price_weight,
           dpd.trade_price_weight_unit_id,
           dpd.sett_price_cur_id,
           dpd.sett_price_weight,
           dpd.sett_price_weight_unit_id
      from dpd_derivative_pnl_daily  dpd,
           tip_temp_instrument_price tip,
           pum_price_unit_master     pum
     where dpd.process_id = pc_process_id
       and dpd.corporate_id = pc_corporate_id
       and dpd.instrument_id = tip.instrument_id
       and dpd.corporate_id = tip.corporate_id
       and tip.price_unit_id = pum.price_unit_id
       and dpd.instrument_type in ('Future', 'Forwards')
       and dpd.pnl_type = 'Unrealized'
       and tip.corporate_id = pc_corporate_id;
  --vn_mep_price_in_trade_cur   number(25, 5);
  vn_mep_value_in_base_cur   number(25, 5);
  vn_sett_value_in_base_cur   number(25, 5);
  vn_fx_rate_mep_to_base_ccy number(30, 10);
  vn_fx_rate_sett_to_base_ccy number(30, 10);  
  --month end price main currency details
  vc_mep_main_cur_id          varchar2(15);
  vc_mep_main_cur_code        varchar2(15);
  vn_mep_sub_cur_id_factor    number(25, 5);
  vn_mpe_cur_decimals         number(5);
  --settlement price main currency details
  vc_sp_main_cur_id          varchar2(15);
  vc_sp_main_cur_code        varchar2(15);
  vn_sp_sub_cur_id_factor    number(25, 5);
  vn_sp_cur_decimals         number(5);
  ----------------
  vn_value_diff_in_trade_ccy  number(25, 5);
  vn_value_diff_in_base_ccy   number(25, 5);
begin
  vc_error_msg := 'Start';
  for mbv_ddr_rows in mbv_ddr
  loop
    --vn_value_diff_in_trade_ccy  := 0;
    --vn_mep_value_in_base_cur   := 0;
    --vn_fx_rate_mep_to_base_ccy := null;
    vn_value_diff_in_trade_ccy  := 0;
    vn_value_diff_in_base_ccy   := 0;
   
  
  
    pkg_general.sp_get_main_cur_detail(mbv_ddr_rows.mep_price_cur_id,
                                       vc_mep_main_cur_id,
                                       vc_mep_main_cur_code,
                                       vn_mep_sub_cur_id_factor,
                                       vn_mpe_cur_decimals);
    pkg_general.sp_get_main_cur_detail(mbv_ddr_rows.sett_price_cur_id,
                                       vc_sp_main_cur_id,
                                       vc_sp_main_cur_code,
                                       vn_sp_sub_cur_id_factor,
                                       vn_sp_cur_decimals);                                       
    
    
   vn_fx_rate_sett_to_base_ccy := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                            vc_sp_main_cur_id,
                                                                            mbv_ddr_rows.base_cur_id,
                                                                            pd_trade_date,
                                                                            1);
  
    vn_fx_rate_mep_to_base_ccy := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                            vc_mep_main_cur_id,
                                                                            mbv_ddr_rows.base_cur_id,
                                                                            pd_trade_date,
                                                                            1);
    vn_mep_value_in_base_cur   := ((mbv_ddr_rows.month_end_price /
                                              nvl(mbv_ddr_rows.mep_price_weight, 1)) *
                                              pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                             mbv_ddr_rows.mep_price_cur_id,
                                                                             mbv_ddr_rows.base_cur_id,
                                                                             pd_trade_date,
                                                                             1)) *
                                              (pkg_general.f_get_converted_quantity(mbv_ddr_rows.derivative_prodct_id,
                                                                                    mbv_ddr_rows.quantity_unit_id,
                                                                                    mbv_ddr_rows.mep_price_weight_unit_id,
                                                                                    mbv_ddr_rows.open_quantity));
   vn_sett_value_in_base_cur   := ((mbv_ddr_rows.settlement_price /
                                              nvl(mbv_ddr_rows.sett_price_weight, 1)) *
                                              pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                             mbv_ddr_rows.sett_price_cur_id,
                                                                             mbv_ddr_rows.base_cur_id,
                                                                             pd_trade_date,
                                                                             1)) *
                                              (pkg_general.f_get_converted_quantity(mbv_ddr_rows.derivative_prodct_id,
                                                                                    mbv_ddr_rows.quantity_unit_id,
                                                                                    mbv_ddr_rows.sett_price_weight_unit_id,
                                                                                    mbv_ddr_rows.open_quantity));                                                                                    
    /*
    for sales trades value diff = Mep price amt- market price amt
    for buy trades value diff =  market price amt - Mep price amt
    */
    if mbv_ddr_rows.trade_type = 'Buy' then
      vn_value_diff_in_base_ccy := vn_sett_value_in_base_cur -
                                    vn_mep_value_in_base_cur;
    else
      vn_value_diff_in_base_ccy := vn_mep_value_in_base_cur -
                                    vn_sett_value_in_base_cur;
    end if;
  
  
    insert into mbv_derivative_diff_report
      (process_id,
       process_date,
       corporate_id,
       corporate_name,
       product_id,
       product_name,
       exchange_id,
       exchange_name,
       instrument_id,
       instrument_name,
       internal_derivative_ref_no,
       derivative_ref_no,
       external_ref_no,
       trade_date,
       trade_type,
       trade_qty,
       trade_qty_unit,
       trade_qty_unit_id,
       trade_price,
       trade_price_unit,
       trade_price_unit_id,
       prompt_date,
       valuation_price,
       valuation_price_unit,
       valuation_price_unit_id,
       trade_value_in_trade_ccy,
       market_value_in_trade_ccy,
       pnl_in_trade_ccy,
       pnl_in_base_ccy,
       fx_trade_to_base_ccy,
       month_end_price,
       month_end_price_unit,
       month_end_price_unit_id,
       base_cur_id,
       base_cur_code,
       tp_cur_id,
       tp_cur_code,
       vp_cur_id,
       vp_cur_code,
       mep_cur_id,
       mep_cur_code,
       mep_value_in_base_ccy,
       sett_value_in_base_ccy,
       value_diff_in_base_ccy,
       fx_mep_ccy_to_base_ccy,       
       fx_sett_ccy_to_base_ccy
       )
    values
      (pc_process_id,
       mbv_ddr_rows.eod_trade_date,
       mbv_ddr_rows.corporate_id,
       mbv_ddr_rows.corporate_name,
       mbv_ddr_rows.derivative_prodct_id,
       mbv_ddr_rows.derivative_prodct_name,
       mbv_ddr_rows.exchange_id,
       mbv_ddr_rows.exchange_name,
       mbv_ddr_rows.instrument_id,
       mbv_ddr_rows.instrument_name,
       mbv_ddr_rows.internal_derivative_ref_no,
       mbv_ddr_rows.derivative_ref_no,
       mbv_ddr_rows.external_ref_no,
       mbv_ddr_rows.trade_date,
       mbv_ddr_rows.trade_type,
       mbv_ddr_rows.open_quantity,
       mbv_ddr_rows.quantity_unit,
       mbv_ddr_rows.quantity_unit_id,
       mbv_ddr_rows.trade_price,
       mbv_ddr_rows.trade_price_unit,
       mbv_ddr_rows.trade_price_unit_id,
       mbv_ddr_rows.dr_id_name,
       mbv_ddr_rows.settlement_price,
       mbv_ddr_rows.sett_price_unit,
       mbv_ddr_rows.sett_price_unit_id,
       mbv_ddr_rows.trade_value_in_trade_ccy,
       mbv_ddr_rows.market_value_in_trade_ccy,
       mbv_ddr_rows.pnl_in_trade_cur,
       mbv_ddr_rows.pnl_in_base_cur,
       mbv_ddr_rows.trade_cur_to_base_exch_rate,
       mbv_ddr_rows.month_end_price,
       mbv_ddr_rows.month_end_price_unit,
       mbv_ddr_rows.month_end_price_unit_id,
       mbv_ddr_rows.base_cur_id,
       mbv_ddr_rows.base_cur_code,
       mbv_ddr_rows.trade_cur_id,
       mbv_ddr_rows.trade_cur_code,
       vc_sp_main_cur_id,
       vc_sp_main_cur_code,
       vc_mep_main_cur_id,
       vc_mep_main_cur_code,
       vn_mep_value_in_base_cur,
       vn_sett_value_in_base_cur,
       vn_value_diff_in_base_ccy,
       vn_fx_rate_mep_to_base_ccy,       
       vn_fx_rate_sett_to_base_ccy);
  end loop;
  commit;
  vc_error_msg := 'End';
exception
  when others then
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure pkg_phy_mbv_report.sp_calc_derivative_diff_report',
                                                         'M2M-013',
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm ||
                                                         '  Error Msg: ' ||
                                                         vc_error_msg,
                                                         '',
                                                         pc_process,
                                                         pc_user_id,
                                                         sysdate,
                                                         pd_trade_date);
    sp_insert_error_log(vobj_error_log);
end;
procedure sp_calc_mbv_report(pc_corporate_id varchar2,
                             pd_trade_date   date,
                             pc_process_id   varchar2,
                             pc_process      varchar2,
                             pc_user_id      varchar2) is
  vn_eel_error_count number := 1;
  vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
  vc_error_msg       varchar2(100);
  vc_previous_eom_id varchar2(15);
   
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
  -- Raw Data Into MBV Main Table
  --
  insert into mbv_metal_balance_valuation
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     product_id,
     product_name,
     instrument_id,
     instrument_name,
     exchange_id,
     exchange_name,
     phy_realized_ob,
     phy_realized_qty,
     phy_realized_pnl,
     phy_realized_cb,
     phy_unr_price_inv_price,
     phy_unr_price_na_inv_price,
     phy_unr_price_nd_inv_price,
     referential_price_diff,
     contango_bw_diff,
     priced_arrived_qty,
     priced_not_arrived_qty,
     unpriced_arrived_qty,
     unpriced_not_arrived_qty,
     priced_delivered_qty,
     priced_not_delivered_qty,
     unpriced_delivered_qty,
     unpriced_not_delivered_qty,
     metal_debt_qty,
     metal_debt_value,
     inventory_unreal_pnl,
     month_end_price,
     der_realized_qty,
     der_realized_pnl,
     der_unrealized_pnl,
     der_realized_ob,
     qty_decimals,
     ccy_decimals,
     total_inv_qty,
     priced_inv_qty,
     unpriced_inv_qty,
     unr_phy_priced_inv_pnl,
     unr_phy_priced_na_pnl,
     unr_phy_priced_nd_pnl,
     der_ref_price_diff,
     phy_ref_price_diff,
     contango_dueto_qty_price,
     contango_dueto_qty,
     actual_hedged_qty,
     qty_to_be_hedged,
     hedge_effectiveness,
     currency_unit,
     qty_unit)
    select pc_process_id,
           pd_trade_date,
           akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           dim.instrument_id,
           dim.instrument_name,
           emt.exchange_id,
           emt.exchange_name,
           0, --    phy_realized_ob,
           0, --    phy_realized_qty,
           0, --    phy_realized_pnl,
           0, --    phy_realized_cb,
           0, --    phy_unr_price_inv_price,
           0, --    phy_unr_price_na_inv_price,
           0, --    phy_unr_price_nd_inv_price,
           0, --    referential_price_diff,
           0, --    contango_bw_diff,
           0, --    priced_arrived_qty,
           0, --    priced_not_arrived_qty,
           0, --    unpriced_arrived_qty,
           0, --    unpriced_not_arrived_qty,
           0, --    priced_delivered_qty,
           0, --    priced_not_delivered_qty,
           0, --    unpriced_delivered_qty,
           0, --    unpriced_not_delivered_qty,
           0, --    metal_debt_qty,
           0, --    metal_debt_value,
           0, --    inventory_unreal_pnl,
           0, --    month_end_price,
           0, --    der_realized_qty,
           0, --    der_realized_pnl,
           0, --    der_unrealized_pnl,
           0, --    der_realized_ob,
           qum.decimals, --    qty_decimals,-- update this later
           cm.decimals, --    ccy_decimals,-- update this later
           0, --    total_inv_qty,
           0, --    priced_inv_qty,
           0, --    unpriced_inv_qty,
           0, --    unr_phy_priced_inv_pnl,
           0, --    unr_phy_priced_na_pnl,
           0, --    unr_phy_priced_nd_pnl,
           0, --    der_ref_price_diff,
           0, --    phy_ref_price_diff,
           0, --    contango_dueto_qty_price,
           0, --    contango_dueto_qty,
           0, --    actual_hedged_qty,
           0, -- qty_to_be_hedged
           0, --    hedge_effectiveness,
           cm.cur_code, -- currency_unit,
           qum.qty_unit -- qty_unit
      from ak_corporate               akc,
           pdm_productmaster          pdm,
           pdd_product_derivative_def pdd,
           dim_der_instrument_master  dim,
           emt_exchangemaster         emt,
           qum_quantity_unit_master qum,
           cm_currency_master cm
     where akc.corporate_id = pc_corporate_id
       and pdm.product_id = pdd.product_id
       and pdd.exchange_id = emt.exchange_id
       and pdd.derivative_def_id = dim.product_derivative_id
       and dim.is_active = 'Y'
       and dim.is_deleted = 'N'
       and pdd.is_active = 'Y'
       and pdm.product_type_id = 'Standard'
       and pdm.base_quantity_unit = qum.qty_unit_id
       and akc.base_cur_id = cm.cur_id
       ;
  commit;
  --
  -- Month End Price for Each product Assuming One Product has one instrument
  --
   vc_error_msg := 'Month End Price for Each product';
  for cur_mep in(
 select pdd.product_id,
        tip.price,
        tip.price_unit_id,
        pum.price_unit_name
   from tip_temp_instrument_price  tip,
        dim_der_instrument_master  dim,
        pdd_product_derivative_def pdd,
        pum_price_unit_master      pum
  where tip.instrument_id = dim.instrument_id
    and dim.product_derivative_id = pdd.derivative_def_id
    and tip.corporate_id = pc_corporate_id
    and tip.price_unit_id = pum.price_unit_id
    and tip.price is not null) loop
   update mbv_metal_balance_valuation mbv
      set mbv.month_end_price           = cur_mep.price,
          mbv.month_end_price_unit_id   = cur_mep.price_unit_id,
          mbv.month_end_price_unit_name = cur_mep.price_unit_name
    where mbv.product_id = cur_mep.product_id
      and mbv.process_id = pc_process_id;
   end loop;
commit;
     vc_error_msg := 'Physical Realized PNL Value';
  --
  -- Physical Realized PNL Value
  --
  for cur_real_value in (select pfrh.product_id,
                                pfrh.instrument_id,
                                pfrh.realized_value,
                                pfrh.realized_qty
                           from pfrh_price_fix_report_header pfrh
                          where pfrh.process_id = pc_process_id)
  loop
    update mbv_metal_balance_valuation mbv
       set mbv.phy_realized_pnl = cur_real_value.realized_value,
       mbv.phy_realized_qty = cur_real_value.realized_qty
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_real_value.product_id;
  end loop;
  commit;
       vc_error_msg := 'Physical Realized Opening Balance';
  --
  -- Physical Realized Opening Balance from Previous EOM CB
  --
  for cur_ob in(
  select mbv.product_id,
         mbv.phy_realized_cb phy_realized_ob
    from mbv_metal_balance_valuation mbv
   where mbv.process_id = vc_previous_eom_id) loop
   update mbv_metal_balance_valuation mbv
   set mbv.phy_realized_ob = cur_ob.phy_realized_ob
 where  mbv.process_id = pc_process_id
       and mbv.product_id = cur_ob.product_id;
   end loop;
   commit;
        vc_error_msg := 'Derivative Unrealized and Realized PNL';
 --
-- Derivative Unrealized and Realized PNL
--
for cur_der in(
select sum(case
             when dpd.pnl_type = 'Unrealized' then
              dpd.pnl_in_base_cur
             else
              0
           end) der_unrealized_pnl,
       sum(case
             when dpd.pnl_type = 'Realized' then
              dpd.pnl_in_base_cur
             else
              0
           end) der_realized_pnl,
       sum(case
             when dpd.pnl_type = 'Realized' then
              dpd.closed_quantity
             else
              0
           end) der_realized_qty,
       dpd.instrument_id,
       dpd.derivative_prodct_id
  from dpd_derivative_pnl_daily dpd
 where dpd.process_id = pc_process_id
   and dpd.instrument_type in ('Future', 'Forwards')
 group by dpd.instrument_id, dpd.derivative_prodct_id) loop
 update mbv_metal_balance_valuation mbv
       set mbv.der_unrealized_pnl = cur_der.der_unrealized_pnl,
       mbv.der_realized_pnl = cur_der.der_realized_pnl,
       mbv.der_realized_qty = cur_der.der_realized_qty
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_der.derivative_prodct_id
       and mbv.instrument_id = cur_der.instrument_id;
 end loop;
commit;

vc_error_msg := 'Data from Contract Status Report';
--
-- Data from Contract Status Report for section Qty Recon Report
--
for cur_qty_recon in(
select css.product_id,
       nvl(sum(case
             when css.contract_type = 'BASEMETAL' and css.purchase_sales = 'P' then
              css.priced_unarrived_qty
             else
              0
           end),0) priced_not_arrived_bm,
       nvl(sum(case
             when css.contract_type = 'CONCENTRATES' and css.purchase_sales = 'P' then
              css.priced_unarrived_qty
             else
              0
           end),0) priced_not_arrived_rm,
       nvl(sum(case
             when css.contract_type = 'BASEMETAL' and css.purchase_sales = 'P' then
              css.unpriced_arrived_qty
             else
              0
           end),0) unpriced_arrived_bm,
       nvl(sum(case
             when css.contract_type = 'CONCENTRATES' and css.purchase_sales = 'P' then
              css.unpriced_arrived_qty
             else
              0
           end),0) unpriced_arrived_rm,
       nvl(sum(case
             when css.contract_type = 'BASEMETAL' and css.purchase_sales = 'S' then
              css.unpriced_delivered_qty
             else
              0
           end),0) sales_unpriced_delivered_bm,
       nvl(sum(case
             when css.contract_type = 'CONCENTRATES' and
                  css.purchase_sales = 'S' then
              css.unpriced_delivered_qty
             else
              0
           end),0) sales_unpriced_delivered_rm,
       nvl(sum(case
             when css.contract_type = 'BASEMETAL' and css.purchase_sales = 'S' then
              css.priced_undelivered_qty
             else
              0
           end),0) sales_priced_not_delivered_bm,
       nvl(sum(case
             when css.contract_type = 'CONCENTRATES' and
                  css.purchase_sales = 'S' then
              css.priced_undelivered_qty
             else
              0
           end),0) sales_priced_not_delivered_rm
  from css_contract_status_summary css
 where css.process_id = pc_process_id
 group by css.product_id) loop
update mbv_metal_balance_valuation mbv
   set priced_not_arrived_bm         = cur_qty_recon.priced_not_arrived_bm,
       priced_not_arrived_rm         = cur_qty_recon.priced_not_arrived_rm,
       unpriced_arrived_bm           = cur_qty_recon.unpriced_arrived_bm,
       unpriced_arrived_rm           = cur_qty_recon.unpriced_arrived_rm,
       sales_unpriced_delivered_bm   = cur_qty_recon.sales_unpriced_delivered_bm,
       sales_unpriced_delivered_rm   = cur_qty_recon.sales_unpriced_delivered_rm,
       sales_priced_not_delivered_bm = cur_qty_recon.sales_priced_not_delivered_bm,
       sales_priced_not_delivered_rm = cur_qty_recon.sales_priced_not_delivered_rm
 where mbv.process_id = pc_process_id
   and mbv.product_id = cur_qty_recon.product_id;
 end loop;
commit;

vc_error_msg := 'Update Actual Hedged Qty';
--
-- Update Actual Hedged Qty
--
for cur_actual_hedged_qty in(
select mbvah.product_id,
       mbvah.opening_balance_qty
  from mbv_allocation_report_header mbvah
 where mbvah.process_id = pc_process_id) loop

Update mbv_metal_balance_valuation mbv
set mbv.actual_hedged_qty = cur_actual_hedged_qty.opening_balance_qty
where mbv.process_id = pc_process_id
and mbv.product_id = cur_actual_hedged_qty.product_id;
end loop;
commit;
vc_error_msg := 'Update actual hedged qty';
--
-- Update actual hedged qty
-- 

update mbv_metal_balance_valuation mbv
   set mbv.qty_to_be_hedged = total_inv_qty + priced_not_arrived_bm +
                              priced_not_arrived_rm - unpriced_arrived_bm -
                              unpriced_arrived_rm +
                              sales_unpriced_delivered_bm +
                              sales_unpriced_delivered_rm -
                              sales_priced_not_delivered_bm -
                              sales_priced_not_delivered_rm
 where mbv.process_id = pc_process_id;
commit;
vc_error_msg := 'Update Hedge Effectivenes';
--
-- Update Hedge Effectivenes
--
update mbv_metal_balance_valuation mbv
   set mbv.hedge_effectiveness = case when mbv.qty_to_be_hedged <> 0 then 1 - (mbv.qty_to_be_hedged -
                                 mbv.actual_hedged_qty) /
                                 mbv.qty_to_be_hedged
                                 else 0 end 
 where mbv.process_id = pc_process_id;
 commit;   
 vc_error_msg := 'Derivative Ref Price Diff';
-- 
--  Difference Explanation
--
-- Derivative Ref Price Diff
--
        vc_error_msg := 'Derivative Ref Price Diff';
for cur_der_ref_price_diff in(
select mbvd.product_id,
       sum(mbvd.value_diff_in_base_ccy) der_ref_price_diff
  from mbv_derivative_diff_report mbvd
 where mbvd.process_id = pc_process_id
 group by mbvd.product_id) loop
 Update mbv_metal_balance_valuation mbv
 set mbv.der_ref_price_diff = cur_der_ref_price_diff.der_ref_price_diff
 where mbv.process_id = pc_process_id
   and mbv.product_id = cur_der_ref_price_diff.product_id;
 end loop;
commit;
        vc_error_msg := 'Physical Ref Price Diff';
--
-- Physical Ref Price Diff
--
for cur_phy_ref_price_diff in(
select mbvp.product_id,
       sum(mbvp.referential_price_in_base_cur * mbvp.qty) phy_ref_price_diff
  from mbv_phy_postion_diff_report mbvp
 where mbvp.process_id = pc_process_id
 group by mbvp.product_id) loop
 update mbv_metal_balance_valuation mbv
    set mbv.phy_ref_price_diff = cur_phy_ref_price_diff.phy_ref_price_diff
  where mbv.process_id = pc_process_id
    and mbv.product_id = cur_phy_ref_price_diff.product_id;
 end loop;
commit;
        vc_error_msg := 'Contango/BW Diff due to price';
--
-- Contango/BW Diff due to price
--
for cur_contango_dueto_qty in(
select mbva.product_id,
       sum(mbva.opening_balance_qty) contango_dueto_qty_price
  from mbv_allocation_report_header mbva
 where mbva.process_id = pc_process_id
 group by mbva.product_id) loop
 update mbv_metal_balance_valuation mbv
    set mbv.contango_dueto_qty_price = cur_contango_dueto_qty.contango_dueto_qty_price
  where mbv.process_id = pc_process_id
    and mbv.product_id = cur_contango_dueto_qty.product_id;
 end loop;
commit;
        vc_error_msg := 'Contango/BW Diff due to qty';
--        
-- Contango/BW Diff due to qty
-- = (Hedged Qty * Actual Hedged Qty) * Month End Price
--

for cur_contango_dueto_qty in(
select mbv.product_id,
       sum((total_inv_qty + priced_not_arrived_bm + priced_not_arrived_rm -
           unpriced_arrived_bm - unpriced_arrived_rm +
           sales_unpriced_delivered_bm + sales_unpriced_delivered_rm -
           sales_priced_not_delivered_bm - sales_priced_not_delivered_rm +
           mbv.actual_hedged_qty) * mbv.month_end_price) contango_dueto_qty
  from mbv_metal_balance_valuation mbv
 where mbv.process_id = pc_process_id
 group by mbv.product_id) loop
 Update mbv_metal_balance_valuation mbv
 set mbv.contango_dueto_qty = cur_contango_dueto_qty.contango_dueto_qty
 where mbv.process_id = pc_process_id
    and mbv.product_id = cur_contango_dueto_qty.product_id;
 end loop;
 commit;
--
-- Update Contract Status and Inventory Status which is at the end of excel
--   
-- Contract Status Updation is not required as report is coming directly form CSS tab;e
--
-- Update Inventory Status Section
--
      vc_error_msg := 'Update Inventory Status Section';
for cur_inv_section in(
select css.product_id,
       sum(css.priced_arrived_qty + css.unpriced_arrived_qty +
           css.priced_delivered_qty + css.unpriced_delivered_qty) total_inv_qty,
       sum(css.priced_arrived_qty + css.priced_delivered_qty) priced_inv_qty,
       sum(css.unpriced_arrived_qty + css.unpriced_delivered_qty) unpriced_inv_qty
  from css_contract_status_summary css
 where css.process_id = pc_process_id
 group by css.product_id) loop
 update mbv_metal_balance_valuation mbv
 set mbv.total_inv_qty = cur_inv_section.total_inv_qty,
 mbv.priced_inv_qty = cur_inv_section.priced_inv_qty,
 mbv.unpriced_inv_qty = cur_inv_section.unpriced_inv_qty
 where mbv.process_id = pc_process_id
 and mbv.product_id = cur_inv_section.product_id;
 end loop;
commit;
     vc_error_msg := 'Qty Total P and L Till Date';
  --
  -- Qty Total P and L Till Date(Closing Balance) 
  -- 
  Update mbv_metal_balance_valuation mbv
  set mbv.phy_realized_cb = mbv.phy_realized_ob + mbv.phy_realized_pnl
  where  mbv.process_id = pc_process_id;
  commit;
  vc_error_msg := 'End of sp_calc_mbv_report';
exception
  when others then
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure pkg_phy_mbv_report.sp_calc_mbv_report',
                                                         'M2M-013',
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm ||
                                                         '  Error Msg: ' ||
                                                         vc_error_msg,
                                                         '',
                                                         pc_process,
                                                         pc_user_id,
                                                         sysdate,
                                                         pd_trade_date);
      sp_insert_error_log(vobj_error_log);                                                         
end;
procedure sp_calc_di_valuation_price(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_process      varchar2,
                                     pc_process_id   varchar2,
                                     pc_user_id      varchar2) as

  cursor cur_mar_price is
    select pcdi.pcdi_id,
           pocd.pcbpd_id,
           pcm.contract_ref_no,
           ppfd.instrument_id,
           dim.instrument_name,
           div.price_source_id,
           ps.price_source_name,
           div.available_price_id,
           apm.available_price_name,
           div.price_unit_id,
           pum.price_unit_name,
           ppu.product_price_unit_id ppu_price_unit_id,
           (case
             when pcdi.delivery_period_type = 'Date' then
              last_day(pcdi.delivery_to_date)
             when pcdi.delivery_period_type = 'Month' then
              last_day(to_date(to_char('01-' || pcdi.delivery_to_month || ' ' ||
                                       pcdi.delivery_to_year),
                               'dd-Mon-yyyy'))
           end) delivery_date,
           poch.element_id
    
      from pcm_physical_contract_main     pcm,
           pcdi_pc_delivery_item          pcdi,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pcbpd_pc_base_price_detail     pcbpd,
           ppfh_phy_price_formula_header  ppfh,
           ppfd_phy_price_formula_details ppfd,
           dim_der_instrument_master      dim,
           div_der_instrument_valuation   div,
           ps_price_source                ps,
           apm_available_price_master     apm,
           pum_price_unit_master          pum,
           pdd_product_derivative_def     pdd,
           v_ppu_pum                      ppu
    
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcm.process_id = pc_process_id
       and pcm.contract_status = 'In Position'
       and pcdi.pcdi_id = poch.pcdi_id
       and pcdi.is_active = 'Y'
       and poch.poch_id = pocd.poch_id
       and pocd.price_type <> 'Fixed'
       and poch.is_active = 'Y'
       and pcdi.process_id = pc_process_id
       and pocd.pcbpd_id = pcbpd.pcbpd_id
       and pcbpd.is_active = 'Y'
       and pcbpd.process_id = pc_process_id
       and pcbpd.pcbpd_id = ppfh.pcbpd_id
       and ppfh.is_active = 'Y'
       and ppfh.process_id = pc_process_id
       and ppfh.ppfh_id = ppfd.ppfh_id
       and ppfd.is_active = 'Y'
       and ppfd.process_id = pc_process_id
       and ppfd.instrument_id = dim.instrument_id
       and dim.instrument_id = div.instrument_id
       and div.is_deleted = 'N'
       and div.price_source_id = ps.price_source_id
       and div.available_price_id = apm.available_price_id
       and div.price_unit_id = pum.price_unit_id
       and dim.product_derivative_id = pdd.derivative_def_id
       and div.price_unit_id = ppu.price_unit_id
       and pdd.product_id = ppu.product_id
       and pcdi.price_option_call_off_status <> 'Not Called Off'
     group by pcdi.pcdi_id,
              pocd.pcbpd_id,
              pcm.contract_ref_no,
              ppfd.instrument_id,
              dim.instrument_name,
              div.price_source_id,
              ps.price_source_name,
              div.available_price_id,
              apm.available_price_name,
              div.price_unit_id,
              pum.price_unit_name,
              ppu.product_price_unit_id,
              pcdi.delivery_period_type,
              pcdi.delivery_to_date,
              pcdi.delivery_to_month,
              pcdi.delivery_to_year,
              poch.element_id
    union all
    select pcdi.pcdi_id,
           pcbpd.pcbpd_id,
           pcm.contract_ref_no,
           ppfd.instrument_id,
           dim.instrument_name,
           div.price_source_id,
           ps.price_source_name,
           div.available_price_id,
           apm.available_price_name,
           div.price_unit_id,
           pum.price_unit_name,
           ppu.product_price_unit_id ppu_price_unit_id,
           (case
             when pcdi.delivery_period_type = 'Date' then
              last_day(pcdi.delivery_to_date)
             when pcdi.delivery_period_type = 'Month' then
              last_day(to_date(to_char('01-' || pcdi.delivery_to_month || ' ' ||
                                       pcdi.delivery_to_year),
                               'dd-Mon-yyyy'))
           end) delivery_date,
           pcbph.element_id
    
      from pcm_physical_contract_main     pcm,
           pcdi_pc_delivery_item          pcdi,
           pci_physical_contract_item     pci,
           pcipf_pci_pricing_formula      pcipf,
           pcbph_pc_base_price_header     pcbph,
           pcbpd_pc_base_price_detail     pcbpd,
           ppfh_phy_price_formula_header  ppfh,
           ppfd_phy_price_formula_details ppfd,
           dim_der_instrument_master      dim,
           div_der_instrument_valuation   div,
           ps_price_source                ps,
           apm_available_price_master     apm,
           pum_price_unit_master          pum,
           pdd_product_derivative_def     pdd,
           v_ppu_pum                      ppu
    
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcm.process_id = pc_process_id
       and pcm.contract_status = 'In Position'
       and pcdi.is_active = 'Y'
       and pcdi.process_id = pc_process_id
       and pci.pcdi_id = pcdi.pcdi_id
       and pci.process_id = pc_process_id
       and pci.is_active = 'Y'
       and pci.internal_contract_item_ref_no =
           pcipf.internal_contract_item_ref_no
       and pcipf.process_id = pc_process_id
       and pcipf.is_active = 'Y'
       and pcipf.pcbph_id = pcbph.pcbph_id
       and pcbph.process_id = pc_process_id
       and pcbph.is_active = 'Y'
       and pcbph.pcbph_id = pcbpd.pcbph_id
       and pcbpd.is_active = 'Y'
       and pcbpd.process_id = pc_process_id
       and pcbpd.pcbpd_id = ppfh.pcbpd_id
       and ppfh.is_active = 'Y'
       and ppfh.process_id = pc_process_id
       and ppfh.ppfh_id = ppfd.ppfh_id
       and ppfd.is_active = 'Y'
       and ppfd.process_id = pc_process_id
       and ppfd.instrument_id = dim.instrument_id
       and dim.instrument_id = div.instrument_id
       and div.is_deleted = 'N'
       and div.price_source_id = ps.price_source_id
       and div.available_price_id = apm.available_price_id
       and div.price_unit_id = pum.price_unit_id
       and dim.product_derivative_id = pdd.derivative_def_id
       and div.price_unit_id = ppu.price_unit_id
       and pdd.product_id = ppu.product_id
       and pcdi.price_option_call_off_status = 'Not Called Off'
     group by pcdi.pcdi_id,
              pcbpd.pcbpd_id,
              pcm.contract_ref_no,
              ppfd.instrument_id,
              dim.instrument_name,
              div.price_source_id,
              ps.price_source_name,
              div.available_price_id,
              apm.available_price_name,
              div.price_unit_id,
              pum.price_unit_name,
              ppu.product_price_unit_id,
              pcdi.delivery_period_type,
              pcdi.delivery_to_date,
              pcdi.delivery_to_month,
              pcdi.delivery_to_year,
              pcbph.element_id;

  vn_price                     number;
  vc_price_unit_id             varchar2(15);
  vd_3rd_wed_of_qp             date;
  vc_price_dr_id               varchar2(15);
  vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count           number := 1;
  vd_valid_quote_date          date;
  vd_quotes_date               date;
  workings_days                number;
  vc_price_unit_cur_id         varchar2(15);
  vc_price_unit_cur_code       varchar2(15);
  vc_price_unit_weight_unit_id varchar2(15);
  vc_price_unit_weight_unit    varchar2(15);
  vn_price_unit_weight         number;
  vc_error_msg                 varchar2(100);
begin
  for cur_mar_price_rows in cur_mar_price
  loop
    vn_price         := null;
    vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(cur_mar_price_rows.delivery_date,
                                                          'Wed',
                                                          3);
    while true
    loop
      if pkg_metals_general.f_is_day_holiday(cur_mar_price_rows.instrument_id,
                                             vd_3rd_wed_of_qp) then
        vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
      else
        exit;
      end if;
    end loop;
  
    if vd_3rd_wed_of_qp <= pd_trade_date then
      workings_days  := 0;
      vd_quotes_date := pd_trade_date + 1;
      while workings_days <> 2
      loop
        if pkg_metals_general.f_is_day_holiday(cur_mar_price_rows.instrument_id,
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
        into vc_price_dr_id
        from drm_derivative_master drm
       where drm.instrument_id = cur_mar_price_rows.instrument_id
         and drm.prompt_date = vd_3rd_wed_of_qp
         and rownum <= 1
         and drm.price_point_id is null
         and drm.is_deleted = 'N';
    exception
      when no_data_found then
        if vd_3rd_wed_of_qp is not null then
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure sp_calc_DI_Valuation_price',
                                                               'PHY-002',
                                                               'DR_ID missing for ' ||
                                                               cur_mar_price_rows.instrument_name ||
                                                               ',Price Source:' ||
                                                               cur_mar_price_rows.price_source_name ||
                                                               ' Contract Ref No: ' ||
                                                               cur_mar_price_rows.contract_ref_no ||
                                                               ',Price Unit:' ||
                                                               cur_mar_price_rows.price_unit_name || ',' ||
                                                               cur_mar_price_rows.available_price_name ||
                                                               ' Price,Prompt Date:' ||
                                                               vd_3rd_wed_of_qp,
                                                               '',
                                                               pc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
        end if;
    end;
  
    --get the price              
    begin
      select dqd.price,
             dqd.price_unit_id
        into vn_price,
             vc_price_unit_id
        from dq_derivative_quotes        dq,
             dqd_derivative_quote_detail dqd,
             cdim_corporate_dim          cdim
       where dq.dq_id = dqd.dq_id
         and dqd.dr_id = vc_price_dr_id
         and dq.process_id = pc_process_id
         and dq.instrument_id = cur_mar_price_rows.instrument_id
         and dq.process_id = dqd.process_id
         and dqd.available_price_id = cur_mar_price_rows.available_price_id
         and dq.price_source_id = cur_mar_price_rows.price_source_id
         and dqd.price_unit_id = cur_mar_price_rows.price_unit_id
         and dq.trade_date = cdim.valid_quote_date
         and dq.is_deleted = 'N'
         and dqd.is_deleted = 'N'
         and rownum <= 1
         and cdim.corporate_id = pc_corporate_id
         and cdim.instrument_id = dq.instrument_id;
    exception
      when no_data_found then
        select cdim.valid_quote_date
          into vd_valid_quote_date
          from cdim_corporate_dim cdim
         where cdim.corporate_id = pc_corporate_id
           and cdim.instrument_id = cur_mar_price_rows.instrument_id;
        vobj_error_log.extend;
        vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id, --
                                                             'procedure sp_calc_DI_Valuation_price',
                                                             'PHY-002', --
                                                             'Price missing for ' ||
                                                             cur_mar_price_rows.instrument_name ||
                                                             ',Price Source:' ||
                                                             cur_mar_price_rows.price_source_name || --
                                                             ' Contract Ref No: ' ||
                                                             cur_mar_price_rows.contract_ref_no ||
                                                             ',Price Unit:' ||
                                                             cur_mar_price_rows.price_unit_name || ',' ||
                                                             cur_mar_price_rows.available_price_name ||
                                                             ' Price,Prompt Date:' ||
                                                             to_char(vd_3rd_wed_of_qp,'dd-Mon-yyyy') ||
                                                             ' Trade Date :' ||
                                                             to_char(pd_trade_date,'dd-Mon-yyyy'),
                                                             '',
                                                             pc_process,
                                                             pc_user_id,
                                                             sysdate,
                                                             pd_trade_date);
        sp_insert_error_log(vobj_error_log);
      
    end;
    vc_price_unit_id := cur_mar_price_rows.ppu_price_unit_id;
  
    -- Get Price Unit Currency, Quantity Details
    begin
      select cm.cur_id,
             cm.cur_code,
             qum.qty_unit_id,
             qum.qty_unit,
             ppu.weight
        into vc_price_unit_cur_id,
             vc_price_unit_cur_code,
             vc_price_unit_weight_unit_id,
             vc_price_unit_weight_unit,
             vn_price_unit_weight
        from v_ppu_pum                ppu,
             cm_currency_master       cm,
             qum_quantity_unit_master qum
       where ppu.product_price_unit_id = vc_price_unit_id
         and ppu.cur_id = cm.cur_id
         and ppu.weight_unit_id = qum.qty_unit_id;
    exception
      when others then
        vc_price_unit_cur_id         := null;
        vc_price_unit_cur_code       := null;
        vc_price_unit_weight_unit_id := null;
        vc_price_unit_weight_unit    := null;
        vn_price_unit_weight         := null;
    end;
  
    insert into mbv_di_valuation_price
      (process_id,
       contract_ref_no,
       pcdi_id,
       element_id,
       delivery_date,
       price,
       price_unit_id,
       price_unit_cur_id,
       price_unit_cur_code,
       price_unit_weight,
       price_unit_weight_unit_id,
       price_unit_weight_unit)
    values
      (pc_process_id,
       cur_mar_price_rows.contract_ref_no,
       cur_mar_price_rows.pcdi_id,
       cur_mar_price_rows.element_id,
       cur_mar_price_rows.delivery_date,
       vn_price,
       vc_price_unit_id,
       vc_price_unit_cur_id,
       vc_price_unit_cur_code,
       vn_price_unit_weight,
       vc_price_unit_weight_unit_id,
       vc_price_unit_weight_unit);
  end loop;
  commit;
exception
  when others then
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure pkg_phy_mbv_report.sp_calc_di_valuation_price',
                                                         'M2M-013',
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm ||
                                                         '  Error Msg: ' ||
                                                         vc_error_msg,
                                                         '',
                                                         pc_process,
                                                         null,
                                                         sysdate,
                                                         pd_trade_date);
    sp_insert_error_log(vobj_error_log);

end;
procedure sp_phy_postion_diff_report(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_process      varchar2,
                                     pc_process_id   varchar2) as

  cursor cur_diff is
  --- Normal concentrate contracts
    select pcm.internal_contract_ref_no,
           pcdi.pcdi_id,
           pcdi.delivery_item_no,
           pcm.contract_ref_no || '(' || pcdi.delivery_item_no || ')' contract_ref_no_del_item_no,
           pcm.issue_date,
           pcm.corporate_id,
           akc.corporate_name,
           akc.base_cur_id,
           akc.base_currency_name,
           aml.underlying_product_id product_id,
           pdm.product_desc,
           pcm.purchase_sales,
           pcm.cp_id,
           pcm.cp_name,
           pcm.contract_type,
           vped.instrument_id,
           vped.instrument_name,
           aml.attribute_id element_id,
           aml.attribute_name element_name,
           (case
             when pcdi.delivery_period_type = 'Date' then
              last_day(pcdi.delivery_to_date)
             when pcdi.delivery_period_type = 'Month' then
              last_day(to_date(to_char('01-' || pcdi.delivery_to_month || ' ' ||
                                       pcdi.delivery_to_year),
                               'dd-Mon-yyyy'))
           end) delivery_arrival_date,
           pcs.priced_not_arrived_qty,
           pcs.payable_qty_unit_id,
           pcs.payable_qty_unit_name,
           mvp.price val_price,
           mvp.price_unit_id val_price_unit_id,
           mvp.price_unit_cur_id val_price_unit_cur_id,
           mvp.price_unit_cur_code val_price_unit_cur_code,
           mvp.price_unit_weight_unit_id val_price_unit_weight_unit_id,
           mvp.price_unit_weight_unit val_price_unit_weight_unit,
           mvp.price_unit_weight val_price_weight,
           ppu_pum.price_unit_name val_price_unit_name,
           tip.price month_end_price,
           tip.price_unit_id month_end_price_unit_id,
           pum.cur_id month_end_price_unit_cur_id,
           cm.cur_code month_end_price_unit_cur_code,
           pum.weight_unit_id mon_price_unit_weight_unit_id,
           qum.qty_unit mon_price_unit_weight_unit,
           pum.weight month_end_price_weight,
           pum.price_unit_name month_end_price_unit_name,
           diwap.weighted_avg_price,
           diwap.wap_price_unit_id,
           diwap.wap_price_unit_name,
           diwap.wap_price_cur_id wap_price_cur_id,
           diwap.wap_price_cur_code wap_price_cur_code,
           diwap.wap_price_weight_unit_id wap_price_weight_unit_id,
           diwap.wap_price_weight_unit wap_price_weight_unit,
           diwap.wap_price_weight wap_price_weight
      from pcm_physical_contract_main pcm,
           pcdi_pc_delivery_item pcdi,
           ak_corporate akc,
           dipq_delivery_item_payable_qty dipq,
           aml_attribute_master_list aml,
           pdm_productmaster pdm,
           v_pcdi_exchange_detail vped,
           (select *
              from mbv_di_valuation_price mvp
             where mvp.process_id = pc_process_id
               and mvp.element_id is not null) mvp,
           (select *
              from pcs_purchase_contract_status pcs
             where pcs.process_id = pc_process_id
               and pcs.contract_type = 'CONCENTRATES'
               and pcs.element_id is not null) pcs,
           (select *
              from diwap_di_weighted_avg_price diwap
             where diwap.process_id = pc_process_id
               and diwap.contractt_type = 'CONCENTRATES'
               and diwap.element_id is not null) diwap,
           tip_temp_instrument_price tip,
           pum_price_unit_master pum,
           qum_quantity_unit_master qum,
           cm_currency_master cm,
           v_ppu_pum ppu_pum
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and pcm.corporate_id = akc.corporate_id
       and pcdi.pcdi_id = dipq.pcdi_id
       and dipq.process_id = pc_process_id
       and dipq.is_active = 'Y'
       and pcm.is_active = 'Y'
       and pcdi.is_active = 'Y'
       and pcm.contract_type = 'CONCENTRATES'
       and dipq.element_id = aml.attribute_id
       and aml.is_active = 'Y'
       and aml.underlying_product_id = pdm.product_id
       and pdm.is_active = 'Y'
       and vped.pcdi_id = pcdi.pcdi_id
       and vped.element_id = aml.attribute_id
       and pcm.is_tolling_contract = 'N'
       and mvp.pcdi_id = pcdi.pcdi_id
       and aml.attribute_id = mvp.element_id
       and pcs.element_id = mvp.element_id
       and pcs.pcdi_id = mvp.pcdi_id
       and vped.instrument_id = tip.instrument_id
       and tip.price_unit_id = pum.price_unit_id
       and pum.weight_unit_id = qum.qty_unit_id
       and pum.cur_id = cm.cur_id
       and mvp.price_unit_id = ppu_pum.product_price_unit_id
       and diwap.pcdi_id = pcdi.pcdi_id
       and diwap.element_id = pcs.element_id
    union all --  external tolling contracts
    select pcm.internal_contract_ref_no,
           pcdi.pcdi_id,
           pcdi.delivery_item_no,
           pcm.contract_ref_no || '(' || pcdi.delivery_item_no || ')' contract_ref_no_del_item_no,
           pcm.issue_date,
           pcm.corporate_id,
           akc.corporate_name,
           akc.base_cur_id,
           akc.base_currency_name,
           aml.underlying_product_id product_id,
           pdm.product_desc,
           pcm.purchase_sales,
           pcm.cp_id,
           pcm.cp_name,
           pcm.contract_type,
           vped.instrument_id,
           vped.instrument_name,
           aml.attribute_id element_id,
           aml.attribute_name element_name,
           (case
             when pcdi.delivery_period_type = 'Date' then
              last_day(pcdi.delivery_to_date)
             when pcdi.delivery_period_type = 'Month' then
              last_day(to_date(to_char('01-' || pcdi.delivery_to_month || ' ' ||
                                       pcdi.delivery_to_year),
                               'dd-Mon-yyyy'))
           end) delivery_arrival_date,
           pcs.priced_not_arrived_qty,
           pcs.payable_qty_unit_id,
           pcs.payable_qty_unit_name,
           mvp.price val_price,
           mvp.price_unit_id val_price_unit_id,
           mvp.price_unit_cur_id val_price_unit_cur_id,
           mvp.price_unit_cur_code val_price_unit_cur_code,
           mvp.price_unit_weight_unit_id val_price_unit_weight_unit_id,
           mvp.price_unit_weight_unit val_price_unit_weight_unit,
           mvp.price_unit_weight val_price_weight,
           ppu_pum.price_unit_name val_price_unit_name,
           tip.price month_end_price,
           tip.price_unit_id month_end_price_unit_id,
           pum.cur_id month_end_price_unit_cur_id,
           cm.cur_code month_end_price_unit_cur_code,
           pum.weight_unit_id mon_price_unit_weight_unit_id,
           qum.qty_unit mon_price_unit_weight_unit,
           pum.weight month_end_price_weight,
           pum.price_unit_name month_end_price_unit_name,
           diwap.weighted_avg_price,
           diwap.wap_price_unit_id,
           diwap.wap_price_unit_name,
           diwap.wap_price_cur_id wap_price_cur_id,
           diwap.wap_price_cur_code wap_price_cur_code,
           diwap.wap_price_weight_unit_id wap_price_weight_unit_id,
           diwap.wap_price_weight_unit wap_price_weight_unit,
           diwap.wap_price_weight wap_price_weight
      from pcm_physical_contract_main pcm,
           pcdi_pc_delivery_item pcdi,
           ak_corporate akc,
           dipq_delivery_item_payable_qty dipq,
           aml_attribute_master_list aml,
           pdm_productmaster pdm,
           v_pcdi_exchange_detail vped,
           pcmte_pcm_tolling_ext pcmte,
           (select *
              from mbv_di_valuation_price mvp
             where mvp.process_id = pc_process_id
               and mvp.element_id is not null) mvp,
           (select *
              from pcs_purchase_contract_status pcs
             where pcs.process_id = pc_process_id
               and pcs.contract_type = 'CONCENTRATES'
               and pcs.element_id is not null) pcs,
            (select *
              from diwap_di_weighted_avg_price diwap
             where diwap.process_id = pc_process_id
               and diwap.contractt_type = 'CONCENTRATES'
               and diwap.element_id is not null) diwap,               
           tip_temp_instrument_price tip,
           pum_price_unit_master pum,
           qum_quantity_unit_master qum,
           cm_currency_master cm,
           v_ppu_pum ppu_pum
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and pcm.corporate_id = akc.corporate_id
       and pcdi.pcdi_id = dipq.pcdi_id
       and dipq.process_id = pc_process_id
       and dipq.is_active = 'Y'
       and pcm.is_active = 'Y'
       and pcdi.is_active = 'Y'
       and pcm.contract_type = 'CONCENTRATES'
       and dipq.element_id = aml.attribute_id
       and aml.is_active = 'Y'
       and aml.underlying_product_id = pdm.product_id
       and pdm.is_active = 'Y'
       and vped.pcdi_id = pcdi.pcdi_id
       and vped.element_id = aml.attribute_id
       and pcm.is_tolling_contract = 'Y'
       and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no
       and pcmte.is_pass_through = 'N'
       and pcdi.pcdi_id = mvp.pcdi_id
       and aml.attribute_id = mvp.element_id
       and pcs.element_id = mvp.element_id
       and pcs.pcdi_id = mvp.pcdi_id
       and vped.instrument_id = tip.instrument_id
       and tip.price_unit_id = pum.price_unit_id
       and pum.weight_unit_id = qum.qty_unit_id
       and pum.cur_id = cm.cur_id
       and mvp.price_unit_id = ppu_pum.product_price_unit_id
       and diwap.pcdi_id = pcdi.pcdi_id
       and diwap.element_id = pcs.element_id
         
    union all -- base metal contrtcts
    select pcm.internal_contract_ref_no,
           pcdi.delivery_item_no,
           pcdi.pcdi_id,
           pcm.contract_ref_no || '(' || pcdi.delivery_item_no || ')' contract_ref_no_del_item_no,
           pcm.issue_date,
           pcm.corporate_id,
           akc.corporate_name,
           akc.base_cur_id,
           akc.base_currency_name,
           pcpd.product_id product_id,
           pdm.product_desc,
           pcm.purchase_sales,
           pcm.cp_id,
           pcm.cp_name,
           pcm.contract_type,
           vped.instrument_id,
           vped.instrument_name,
           null element_id,
           null element_name,
           (case
             when pcdi.delivery_period_type = 'Date' then
              last_day(pcdi.delivery_to_date)
             when pcdi.delivery_period_type = 'Month' then
              last_day(to_date(to_char('01-' || pcdi.delivery_to_month || ' ' ||
                                       pcdi.delivery_to_year),
                               'dd-Mon-yyyy'))
           end) delivery_arrival_date,
           pcs.priced_not_arrived_qty,
           pcs.payable_qty_unit_id,
           pcs.payable_qty_unit_name,
           mvp.price val_price,
           mvp.price_unit_id val_price_unit_id,
           mvp.price_unit_cur_id val_price_unit_cur_id,
           mvp.price_unit_cur_code val_price_unit_cur_code,
           mvp.price_unit_weight_unit_id val_price_unit_weight_unit_id,
           mvp.price_unit_weight_unit val_price_unit_weight_unit,
           mvp.price_unit_weight val_price_weight,
           ppu_pum.price_unit_name val_price_unit_name,
           tip.price month_end_price,
           tip.price_unit_id month_end_price_unit_id,
           pum.cur_id month_end_price_unit_cur_id,
           cm.cur_code month_end_price_unit_cur_code,
           pum.weight_unit_id mon_price_unit_weight_unit_id,
           qum.qty_unit mon_price_unit_weight_unit,
           pum.weight month_end_price_weight,
           pum.price_unit_name month_end_price_unit_name,
           diwap.weighted_avg_price,
           diwap.wap_price_unit_id,
           diwap.wap_price_unit_name,
           null wap_price_cur_id,
           null wap_price_cur_code,
           null wap_price_weight_unit_id,
           null wap_price_weight_unit,
           null wap_price_weight
      from pcm_physical_contract_main pcm,
           pcdi_pc_delivery_item pcdi,
           ak_corporate akc,
           pcpd_pc_product_definition pcpd,
           pdm_productmaster pdm,
           v_pcdi_exchange_detail vped,
           (select *
              from mbv_di_valuation_price mvp
             where mvp.process_id = pc_process_id
               and mvp.element_id is null) mvp,
           (select *
              from pcs_purchase_contract_status pcs
             where pcs.process_id = pc_process_id
               and pcs.contract_type = 'BASEMETAL'
               and pcs.element_id is null) pcs,
   (select *
              from diwap_di_weighted_avg_price diwap
             where diwap.process_id = pc_process_id
               and diwap.contractt_type = 'BASEMETAL'
               and diwap.element_id is null) diwap,                
           tip_temp_instrument_price tip,
           pum_price_unit_master pum,
           qum_quantity_unit_master qum,
           cm_currency_master cm,
           v_ppu_pum ppu_pum
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and pcm.corporate_id = akc.corporate_id
       and pcm.is_active = 'Y'
       and pcdi.is_active = 'Y'
       and pcm.contract_type = 'BASEMETAL'
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
       and pcpd.process_id = pc_process_id
       and pcpd.is_active = 'Y'
       and pcpd.product_id = pdm.product_id
       and vped.pcdi_id = pcdi.pcdi_id
       and pcdi.pcdi_id = mvp.pcdi_id
       and pcs.pcdi_id = mvp.pcdi_id
       and vped.instrument_id = tip.instrument_id
       and tip.price_unit_id = pum.price_unit_id
       and pum.weight_unit_id = qum.qty_unit_id
       and pum.cur_id = cm.cur_id
       and mvp.price_unit_id = ppu_pum.product_price_unit_id
       and diwap.pcdi_id = pcs.pcdi_id;

  --vn_con_price_in_base_cur number(25, 5);
  vn_val_price_in_base_cur number(25, 5);
  vn_med_price_in_base_cur number(25, 5);
  
  --month end price main currency details
  vc_mep_main_cur_id       varchar2(15);
  vc_mep_main_cur_code     varchar2(15);
  vn_mep_sub_cur_id_factor number(25, 5);
  vn_mpe_cur_decimals      number(5);
  --valuation price main currency details
  vc_vp_main_cur_id       varchar2(15);
  vc_vp_main_cur_code     varchar2(15);
  vn_vp_sub_cur_id_factor number(25, 5);
  vn_vp_cur_decimals      number(5);
  ----------------
   vc_con_main_cur_id       varchar2(15);
  vc_con_main_cur_code     varchar2(15);
  vn_con_sub_cur_id_factor number(25, 5);
  vn_con_cur_decimals      number(5);
 vn_con_price_in_base_cur number(25, 5);
  vn_mep_value_in_base_cur   number(25, 5);
  vn_val_value_in_base_cur   number(25, 5);
  vn_fx_rate_mep_to_base_ccy number(30, 10);
  vn_fx_rate_val_to_base_ccy number(30, 10);
  vn_fx_rate_con_to_base_ccy  number(30, 10);
  vn_con_value_in_base_cur    number(25, 5);
  vn_value_diff_in_base_ccy  number(25, 5);
  vn_price_diffin_base_ccy   number(25, 5);
  vn_unreal_pnl_in_base_ccy  number(25, 5);
  vn_eel_error_count number := 1;
  vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
  vc_error_msg       varchar2(100);

begin
  for cur_diff_rows in cur_diff
  loop
  
  pkg_general.sp_get_main_cur_detail(cur_diff_rows.wap_price_cur_id,
                                       vc_con_main_cur_id,
                                       vc_con_main_cur_code,
                                       vn_con_sub_cur_id_factor,
                                       vn_con_cur_decimals);
                                       
    pkg_general.sp_get_main_cur_detail(cur_diff_rows.month_end_price_unit_cur_id,
                                       vc_mep_main_cur_id,
                                       vc_mep_main_cur_code,
                                       vn_mep_sub_cur_id_factor,
                                       vn_mpe_cur_decimals);
    pkg_general.sp_get_main_cur_detail(cur_diff_rows.val_price_unit_cur_id,
                                       vc_vp_main_cur_id,
                                       vc_vp_main_cur_code,
                                       vn_vp_sub_cur_id_factor,
                                       vn_vp_cur_decimals);
vn_fx_rate_con_to_base_ccy := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                           vc_con_main_cur_id,
                                                                           cur_diff_rows.base_cur_id,
                                                                           pd_trade_date,
                                                                           1);
                                                                                                                  
  
    vn_fx_rate_val_to_base_ccy := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                           vc_vp_main_cur_id,
                                                                           cur_diff_rows.base_cur_id,
                                                                           pd_trade_date,
                                                                           1);
  
    vn_fx_rate_mep_to_base_ccy := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                           vc_mep_main_cur_id,
                                                                           cur_diff_rows.base_cur_id,
                                                                           pd_trade_date,
                                                                           1);
 vn_con_price_in_base_cur   := cur_diff_rows.weighted_avg_price *
                                  vn_fx_rate_con_to_base_ccy;
                                                                              
    vn_val_price_in_base_cur   := cur_diff_rows.val_price *
                                  vn_fx_rate_val_to_base_ccy;
    vn_med_price_in_base_cur   := cur_diff_rows.month_end_price *
                                  vn_fx_rate_mep_to_base_ccy;
  
    if cur_diff_rows.purchase_sales = 'P' then
      vn_price_diffin_base_ccy := vn_val_price_in_base_cur -
                                  vn_med_price_in_base_cur;
    else
      vn_price_diffin_base_ccy := vn_med_price_in_base_cur -
                                  vn_val_price_in_base_cur;
    end if;
    
       vn_con_value_in_base_cur := ((cur_diff_rows.weighted_avg_price /
                                nvl(cur_diff_rows.wap_price_weight,
                                      1)) *
                                pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                          cur_diff_rows.wap_price_cur_id,
                                                                          cur_diff_rows.base_cur_id,
                                                                          pd_trade_date,
                                                                          1)) *
                                (pkg_general.f_get_converted_quantity(cur_diff_rows.product_id,
                                                                      cur_diff_rows.payable_qty_unit_id,
                                                                      cur_diff_rows.wap_price_weight_unit_id,
                                                                      cur_diff_rows.priced_not_arrived_qty));
    
  
    vn_mep_value_in_base_cur := ((cur_diff_rows.month_end_price /
                                nvl(cur_diff_rows.month_end_price_weight,
                                      1)) *
                                pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                          cur_diff_rows.month_end_price_unit_cur_id,
                                                                          cur_diff_rows.base_cur_id,
                                                                          pd_trade_date,
                                                                          1)) *
                                (pkg_general.f_get_converted_quantity(cur_diff_rows.product_id,
                                                                      cur_diff_rows.payable_qty_unit_id,
                                                                      cur_diff_rows.mon_price_unit_weight_unit_id,
                                                                      cur_diff_rows.priced_not_arrived_qty));
    vn_val_value_in_base_cur := ((cur_diff_rows.val_price /
                                nvl(cur_diff_rows.val_price_weight, 1)) *
                                pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                          cur_diff_rows.val_price_unit_cur_id,
                                                                          cur_diff_rows.base_cur_id,
                                                                          pd_trade_date,
                                                                          1)) *
                                (pkg_general.f_get_converted_quantity(cur_diff_rows.product_id,
                                                                      cur_diff_rows.payable_qty_unit_id,
                                                                      cur_diff_rows.val_price_unit_weight_unit_id,
                                                                      cur_diff_rows.priced_not_arrived_qty));
    if cur_diff_rows.purchase_sales = 'P' then
      vn_value_diff_in_base_ccy := vn_val_value_in_base_cur -
                                   vn_mep_value_in_base_cur;
    else
      vn_value_diff_in_base_ccy := vn_mep_value_in_base_cur -
                                   vn_val_value_in_base_cur;
    end if;
     if cur_diff_rows.purchase_sales = 'P' then
      vn_unreal_pnl_in_base_ccy := vn_val_value_in_base_cur -
                                   vn_con_value_in_base_cur;
    else
      vn_unreal_pnl_in_base_ccy := vn_con_value_in_base_cur -
                                   vn_val_value_in_base_cur;
    end if;
    
  
    insert into mbv_phy_postion_diff_report
      (process_id,
       eod_trade_date,
       corporate_id,
       corporate_name,
       product_id,
       product_name,
       contract_date,
       purchase_sales,
       contract_type,
       instrument_id,
       instrument_name,
       cp_id,
       cp_name,
       internal_contract_ref_no,
       delivery_item_no,
       contract_ref_no_del_item_no,
       pcdi_id,
       element_id,
       element_name,
       delivery_arrival_date,
       qty,
       qty_unit_id,
       qty_unit,
       con_price,
       con_price_unit_id,
       con_price_unit_cur_id,
       con_price_unit_cur_code,
       con_price_unit_weight_unit_id,
       con_price_unit_weight_unit,
       con_price_unit_weight,
       con_price_unit_name,
       val_price,
       val_price_unit_id,
       val_price_unit_cur_id,
       val_price_unit_cur_code,
       val_price_unit_weight_unit_id,
       val_price_unit_weight_unit,
       val_price_unit_weight,
       val_price_unit_name,
       mon_end_price,
       mon_end_price_unit_id,
       mon_end_price_unit_cur_id,
       mon_end_price_unit_cur_code,
       mon_end_price_weight_unit_id,
       mon_end_price_unit_weight_unit,      
       mon_end_price_unit_weight,
       mon_end_price_unit_name,
       fx_con_price_to_base_cur,
       fx_val_price_to_base_cur,
       fx_monend_price_to_base_cur,
       contract_price_in_base_cur,
       valuation_price_in_base_cur,
       month_end_price_in_base_cur,
       referential_price_in_base_cur,
       contract_value_in_base_cur,
       valuation_value_in_base_cur,
       month_end_value_in_base_cur,
       referential_value_in_base_cur,
       cp_main_cur_id,
       cp_main_cur_code,
       vp_main_cur_id,
       vp_main_cur_code,
       mep_main_cur_id,
       mep_main_cur_code,
       base_cur_id,
       base_cur_code,
       unrealized_pnl_in_base_cur)
    values
      (pc_process_id,
       pd_trade_date,
       cur_diff_rows.corporate_id,
       cur_diff_rows.corporate_name,
       cur_diff_rows.product_id,
       cur_diff_rows.product_desc,
       cur_diff_rows.issue_date,
       cur_diff_rows.purchase_sales,
       cur_diff_rows.contract_type,
       cur_diff_rows.instrument_id,
       cur_diff_rows.instrument_name,
       cur_diff_rows.cp_id,
       cur_diff_rows.cp_name,
       cur_diff_rows.internal_contract_ref_no,
       cur_diff_rows.delivery_item_no,
       cur_diff_rows.contract_ref_no_del_item_no,
       cur_diff_rows.pcdi_id,
       cur_diff_rows.element_id,
       cur_diff_rows.element_name,
       cur_diff_rows.delivery_arrival_date,
       cur_diff_rows.priced_not_arrived_qty,
       cur_diff_rows.payable_qty_unit_id,
       cur_diff_rows.payable_qty_unit_name,
       cur_diff_rows.weighted_avg_price,
       cur_diff_rows.wap_price_unit_id,
       cur_diff_rows.wap_price_cur_id,
       cur_diff_rows.wap_price_cur_code,
       cur_diff_rows.wap_price_weight_unit_id,
       cur_diff_rows.wap_price_weight_unit,
       cur_diff_rows.wap_price_weight,
       cur_diff_rows.wap_price_unit_name,       
       cur_diff_rows.val_price,
       cur_diff_rows.val_price_unit_id,
       cur_diff_rows.val_price_unit_cur_id,
       cur_diff_rows.val_price_unit_cur_code,
       cur_diff_rows.val_price_unit_weight_unit_id,
       cur_diff_rows.val_price_unit_weight_unit,
       cur_diff_rows.val_price_weight,
       cur_diff_rows.val_price_unit_name,
       cur_diff_rows.month_end_price,
       cur_diff_rows.month_end_price_unit_id,
       cur_diff_rows.month_end_price_unit_cur_id,
       cur_diff_rows.month_end_price_unit_cur_code,
       cur_diff_rows.mon_price_unit_weight_unit_id,
       cur_diff_rows.mon_price_unit_weight_unit,
       cur_diff_rows.month_end_price_weight,
       cur_diff_rows.month_end_price_unit_name,
       vn_fx_rate_con_to_base_ccy,
       vn_fx_rate_val_to_base_ccy,
       vn_fx_rate_mep_to_base_ccy,
       vn_con_price_in_base_cur,
       vn_val_price_in_base_cur,
       vn_med_price_in_base_cur,
       vn_price_diffin_base_ccy,
       vn_con_value_in_base_cur,
       vn_val_value_in_base_cur,
       vn_mep_value_in_base_cur,
       vn_value_diff_in_base_ccy,
       vc_con_main_cur_id,
       vc_con_main_cur_code,
       vc_vp_main_cur_id,
       vc_vp_main_cur_code,
       vc_mep_main_cur_id,
       vc_mep_main_cur_code,
       cur_diff_rows.base_cur_id,
       cur_diff_rows.base_currency_name,
       vn_unreal_pnl_in_base_ccy);
  end loop;
  commit;
 exception
  when others then
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure pkg_phy_mbv_report.sp_phy_position_diff_report',
                                                         'M2M-013',
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm ||
                                                         '  Error Msg: ' ||
                                                         vc_error_msg,
                                                         '',
                                                         pc_process,
                                                         null,
                                                         sysdate,
                                                         pd_trade_date);
    sp_insert_error_log(vobj_error_log);
end;
procedure sp_allocation_report(pc_corporate_id varchar2,
                               pd_trade_date   date,
                               pc_process      varchar2,
                               pc_process_id   varchar2) as

  vd_prev_eom_date   date;
 vn_eel_error_count number := 1;
  vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
  vc_error_msg       varchar2(100);

begin
  begin
    select tdc.trade_date
      into vd_prev_eom_date
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
      vd_prev_eom_date   := to_date('01-Jan-2000', 'dd-Mon-yyyy');
  end;

  -- for physicals
  insert into mbv_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     product_id,
     product_desc,
     instrument_id,
     instrument_name,
     cp_id,
     cp_name,
     internal_contract_ref_no,
     delivery_item_no,
     gmr_ref_no,
     internal_gmr_ref_no,
     price_fixed_date,
     pf_ref_no,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     price,
     price_unit_id,
     price_unit_cur_id,
     price_unit_cur_code,
     price_unit_weight_unit_id,
     price_unit_weight_unit,
     price_unit_weight,
     price_unit_name,
     fx_rate_price_to_base,
     price_in_base_ccy,
     amount,
     base_cur_id,
     base_cur_name)
    select pc_process_id,
           pd_trade_date,
           pc_corporate_id,
           akc.corporate_name,
           'Physicals',
           pdm_aml.product_id,
           pdm_aml.product_desc,
           vped.instrument_id,
           vped.instrument_name,
           pcm.cp_id,
           pcm.cp_name,
           pcm.contract_ref_no || '(' || pcdi.delivery_item_no || ')' contract_ref_no_del_item_no,
           pcdi.delivery_item_no,
           gmr.gmr_ref_no,
           gmr.internal_gmr_ref_no,
           pfd.hedge_correction_date price_fixation_date,
           axs.action_ref_no as pf_ref_no,
           (case
             when pcm.purchase_sales = 'P' then
              pfd.qty_fixed * ucm.multiplication_factor
             else
              0
           end) purchase_qty,
           (case
             when pcm.purchase_sales = 'S' then
              pfd.qty_fixed * ucm.multiplication_factor
             else
              0
           end) sales_qty,
           pdm_aml.base_quantity_unit,
           qum_qty.qty_unit,
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
           (case
             when pcm.purchase_sales = 'P' then
              1
             else
              (-1)
           end) * pfd.qty_fixed * pfd.user_price * nvl(pfd.fx_to_base, 1) *
           ucm.multiplication_factor amount,
           akc.base_cur_id,
           akc.base_currency_name
      from pcm_physical_contract_main pcm,
           pcdi_pc_delivery_item pcdi,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pofh_price_opt_fixation_header pofh,
           pfd_price_fixation_details pfd,
           (select gmr.internal_gmr_ref_no,
                   gmr.gmr_ref_no
              from gmr_goods_movement_record gmr
             where gmr.process_id = pc_process_id
               and gmr.is_deleted = 'N') gmr,
           pfam_price_fix_action_mapping pfam,
           axs_action_summary axs,
           aml_attribute_master_list aml,
           pdm_productmaster pdm_aml,
           v_pcdi_exchange_detail vped,
           v_ppu_pum ppu,
           cm_currency_master cm,
           qum_quantity_unit_master qum,
           ak_corporate akc,
           ucm_unit_conversion_master ucm,
           qum_quantity_unit_master qum_qty
    
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id
       and pofh.pofh_id = pfd.pofh_id
       and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
       and pfd.pfd_id = pfam.pfd_id
       and pfam.internal_action_ref_no = axs.internal_action_ref_no(+)
       and pocd.element_id = aml.attribute_id
       and vped.pcdi_id = pcdi.pcdi_id
       and vped.element_id = aml.attribute_id(+)
       and aml.underlying_product_id = pdm_aml.product_id
       and pfd.price_unit_id = ppu.product_price_unit_id
       and ppu.cur_id = cm.cur_id
       and ppu.weight_unit_id = qum.qty_unit_id
       and akc.corporate_id = pcm.corporate_id
       and ucm.from_qty_unit_id = pocd.qty_to_be_fixed_unit_id
       and ucm.to_qty_unit_id = pdm_aml.base_quantity_unit
       and pdm_aml.base_quantity_unit = qum_qty.qty_unit_id
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and pcm.is_active = 'Y'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active = 'Y'
       and pcdi.is_active = 'Y'
       and pfd.is_active = 'Y'
       and pfam.is_active = 'Y'
       and pcm.contract_type = 'CONCENTRATES'
       and pfd.hedge_correction_date > vd_prev_eom_date
       and pfd.hedge_correction_date <= pd_trade_date
    union all
    select pc_process_id,
           pd_trade_date,
           pc_corporate_id,
           akc.corporate_name,
           'Physicals',
           pdm.product_id,
           pdm.product_desc,
           vped.instrument_id,
           vped.instrument_name,
           pcm.cp_id,
           pcm.cp_name,
           pcm.contract_ref_no || '(' || pcdi.delivery_item_no || ')' contract_ref_no_del_item_no,
           pcdi.delivery_item_no,
           gmr.gmr_ref_no,
           gmr.internal_gmr_ref_no,
           pfd.hedge_correction_date price_fixation_date,
           axs.action_ref_no as pf_ref_no,
           (case
             when pcm.purchase_sales = 'P' then
              pfd.qty_fixed * ucm.multiplication_factor
             else
              0
           end) purchase_qty,
           (case
             when pcm.purchase_sales = 'S' then
              pfd.qty_fixed * ucm.multiplication_factor
             else
              0
           end) sales_qty,
           pdm.base_quantity_unit,
           qum_qty.qty_unit,
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
           (case
             when pcm.purchase_sales = 'P' then
              1
             else
              (-1)
           end) * pfd.qty_fixed * pfd.user_price * nvl(pfd.fx_to_base, 1) *
           ucm.multiplication_factor amount,
           akc.base_cur_id,
           akc.base_currency_name
      from pcm_physical_contract_main pcm,
           pcdi_pc_delivery_item pcdi,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pofh_price_opt_fixation_header pofh,
           pfd_price_fixation_details pfd,
           (select gmr.internal_gmr_ref_no,
                   gmr.gmr_ref_no
              from gmr_goods_movement_record gmr
             where gmr.process_id = pc_process_id
               and gmr.is_deleted = 'N') gmr,
           pfam_price_fix_action_mapping pfam,
           axs_action_summary axs,
           v_pcdi_exchange_detail vped,
           pcpd_pc_product_definition pcpd,
           pdm_productmaster pdm,
           
           v_ppu_pum                  ppu,
           cm_currency_master         cm,
           qum_quantity_unit_master   qum,
           ak_corporate               akc,
           ucm_unit_conversion_master ucm,
           qum_quantity_unit_master   qum_qty
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id
       and pofh.pofh_id = pfd.pofh_id
       and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
       and pfd.pfd_id = pfam.pfd_id
       and pfam.internal_action_ref_no = axs.internal_action_ref_no(+)
       and vped.pcdi_id = pcdi.pcdi_id
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
       and pcpd.product_id = pdm.product_id
       and pfd.price_unit_id = ppu.product_price_unit_id
       and ppu.cur_id = cm.cur_id
       and ppu.weight_unit_id = qum.qty_unit_id
       and akc.corporate_id = pcm.corporate_id
       and ucm.from_qty_unit_id = pocd.qty_to_be_fixed_unit_id
       and ucm.to_qty_unit_id = pdm.base_quantity_unit
       and pdm.base_quantity_unit = qum_qty.qty_unit_id
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and pcm.is_active = 'Y'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active = 'Y'
       and pcdi.is_active = 'Y'
       and pfd.is_active = 'Y'
       and pfam.is_active = 'Y'
       and pcpd.is_active = 'Y'
       and pcm.contract_type = 'BASEMETAL'
       and pfd.hedge_correction_date > vd_prev_eom_date
       and pfd.hedge_correction_date <= pd_trade_date;

  commit;
  -- derivatives
  insert into mbv_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     cp_id,
     cp_name,
     product_id,
     product_desc,
     instrument_id,
     instrument_name,
     external_ref_no,
     derivative_ref_no,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     price,
     price_unit_id,
     price_unit_cur_id,
     price_unit_cur_code,
     price_unit_weight_unit_id,
     price_unit_weight_unit,
     price_unit_weight,
     price_unit_name,
     prompt_month_year,
     fx_rate_price_to_base,
     price_in_base_ccy,
     price_fixed_date,
     amount,
     base_cur_id,
     base_cur_name)
    select dpd.process_id,
           dpd.eod_trade_date,
           dpd.corporate_id,
           dpd.corporate_name,
           'Derivatives',
           dpd.cp_profile_id,
           dpd.cp_name,
           dpd.derivative_prodct_id prodct_id,
           dpd.derivative_prodct_name prodct_name,
           dpd.instrument_id,
           dpd.instrument_name,
           dpd.external_ref_no,
           dpd.derivative_ref_no,
           (case
             when dpd.trade_type = 'Buy' then
              dpd.total_quantity * ucm.multiplication_factor
             else
              0
           end) purchase_qty,
           (case
             when dpd.trade_type = 'Sell' then
              dpd.total_quantity * ucm.multiplication_factor
             else
              0
           end) sales_qty,
           dpd.base_qty_unit_id,
           dpd.base_qty_unit,
           dpd.trade_price,
           dpd.trade_price_unit_id,
           dpd.trade_price_cur_id,
           dpd.trade_price_cur_code,
           dpd.trade_price_weight_unit_id,
           dpd.trade_price_weight_unit,
           dpd.trade_price_weight,
           dpd.trade_price_cur_code || '/' || dpd.trade_price_weight ||
           dpd.trade_price_weight_unit price_unit,
           dpd.prompt_date,
           dpd.trade_cur_to_base_exch_rate,
           dpd.trade_price * dpd.trade_cur_to_base_exch_rate,
           dpd.trade_date,
           (case
             when dpd.trade_type = 'Buy' then
              dpd.total_quantity * ucm.multiplication_factor *
              dpd.trade_price * dpd.trade_cur_to_base_exch_rate
             else
              (1) * dpd.total_quantity * ucm.multiplication_factor *
              dpd.trade_price * dpd.trade_cur_to_base_exch_rate
           end) trade_value_in_base,
           dpd.base_cur_id,
           dpd.base_cur_code
      from dpd_derivative_pnl_daily   dpd,
           ucm_unit_conversion_master ucm
     where dpd.pnl_type = 'New Trade'
       and ucm.from_qty_unit_id = dpd.trade_price_weight_unit_id
       and ucm.to_qty_unit_id = dpd.base_qty_unit_id
       and dpd.process_id = pc_process_id;
  commit;
  --- 
  insert into mbv_allocation_report_header
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     product_id,
     product_name,
     opening_balance_qty)
    select pc_process_id,
           pd_trade_date,
           mbv.corporate_id,
           mbv.corporate_name,
           mbv.product_id,
           mbv.product_desc,
           sum(mbv.purchase_qty) + sum(mbv.sales_qty) opening_balance
      from mbv_allocation_report mbv
     where mbv.eod_trade_date < pd_trade_date
     group by mbv.corporate_id,
              mbv.corporate_name,
              mbv.product_id,
              mbv.product_desc;
  commit;
exception
  when others then
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure pkg_phy_mbv_report.sp_allocation_report',
                                                         'M2M-013',
                                                         'Code:' || sqlcode ||
                                                         'Message:' ||
                                                         sqlerrm ||
                                                         '  Error Msg: ' ||
                                                         vc_error_msg,
                                                         '',
                                                         pc_process,
                                                         null,
                                                         sysdate,
                                                         pd_trade_date);
    sp_insert_error_log(vobj_error_log);
end;
end; 
/
