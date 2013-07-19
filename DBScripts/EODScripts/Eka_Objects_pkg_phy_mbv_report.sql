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
  procedure sp_fx_allocation_report(pc_corporate_id varchar2,
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
  vn_logno           number := 770;
begin
  vc_error_msg := 'sp_calc_pf_data';
  sp_calc_pf_data(pc_corporate_id,
                  pd_trade_date,
                  pc_process_id,
                  pc_process,
                  pc_user_id);
  vn_logno := vn_logno + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        vn_logno,
                        'End of ' || vc_error_msg);

  vc_error_msg := 'sp_calc_di_valuation_price';
  sp_calc_di_valuation_price(pc_corporate_id,
                             pd_trade_date,
                             pc_process,
                             pc_process_id,
                             pc_user_id);
  vn_logno := vn_logno + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        vn_logno,
                        'End of ' || vc_error_msg);

  vc_error_msg := 'sp_calc_derivative_diff_report';
  sp_calc_derivative_diff_report(pc_corporate_id,
                                 pd_trade_date,
                                 pc_process_id,
                                 pc_process,
                                 pc_user_id);
  vn_logno := vn_logno + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        vn_logno,
                        'End of ' || vc_error_msg);

  vc_error_msg := 'sp_allocation_report';
  sp_allocation_report(pc_corporate_id,
                       pd_trade_date,
                       pc_process,
                       pc_process_id);
  vn_logno := vn_logno + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        vn_logno,
                        'End of ' || vc_error_msg);

  vc_error_msg := 'sp_phy_postion_diff_report';
  sp_phy_postion_diff_report(pc_corporate_id,
                             pd_trade_date,
                             pc_process,
                             pc_process_id);
  vn_logno := vn_logno + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        vn_logno,
                        'End of ' || vc_error_msg);

  vc_error_msg := 'sp_calc_mbv_report';
  sp_calc_mbv_report(pc_corporate_id,
                     pd_trade_date,
                     pc_process_id,
                     pc_process,
                     pc_user_id);
  vn_logno := vn_logno + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        vn_logno,
                        'End of ' || vc_error_msg);

  ---- Added Suresh
  vc_error_msg := 'sp_fx_allocation_report';
  sp_fx_allocation_report(pc_corporate_id,
                          pd_trade_date,
                          pc_process,
                          pc_process_id);
  vn_logno := vn_logno + 1;
  sp_eodeom_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        vn_logno,
                        'End of ' || vc_error_msg);

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
    vn_eel_error_count            number := 1;
    vobj_error_log                tableofpelerrorlog := tableofpelerrorlog();
    vc_previous_eom_id            varchar2(15);
    vc_error_msg                  varchar2(100);
    vd_prev_eom_date              date;
    vn_qty_to_consume             number;
    vn_consumed_for_this_fixation number;
    vc_base_cur_id                varchar2(15);
    vn_price_factor               number;
    vc_m2m_price_unit_id          varchar2(15);
    vc_wap_price_unit_id          varchar2(15);
    vc_wap_price_unit_name        varchar2(100);
    vc_wap_price_cur_id           varchar2(15);
    vc_wap_price_cur_code         varchar2(15);
    vc_wap_price_weight_unit_id   varchar2(15);
    vc_wap_price_weight_unit      varchar2(15);
    vn_wap_price_weight           number;
    vn_exch_rate                  number;
  begin
  
select akc.base_cur_id
  into vc_base_cur_id
  from ak_corporate akc
 where akc.corporate_id = pc_corporate_id;
    --
    -- Previous EOM ID
    --
    vc_error_msg := 'Get Previous EOM ID';
    begin
      select tdc.process_id,
             tdc.trade_date
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
        -- List of Balance Price Fixations from previous Month
        --
       insert into pfrhe_pfrh_extension
         (process_id,
          eod_trade_date,
          corporate_id,
          corporate_name,
          product_id,
          product_name,
          purchase_sales,
          fixed_qty,
          weighted_avg_price,
          from_section_name,
          section_name,
          consumed_qty,
          fixation_value)
         select pc_process_id,
                pd_trade_date,
                pfrhe.corporate_id,
                pfrhe.corporate_name,
                pfrhe.product_id,
                pfrhe.product_name,
                pfrhe.purchase_sales,
                sum(fixed_qty),
                case
                  when sum(fixed_qty) = 0 then
                   0
                  else
                   sum((fixed_qty ) * weighted_avg_price) / sum(fixed_qty)
                end,
                'NA', -- Thought this is from List of Balance Price Fixations from EOM, this is not required for any logic
                'List of Balance Price Fixations from previous Month',
                sum(pfrhe.consumed_qty) consumed_qty, 
                0 -- Not Applicable
           from pfrhe_pfrh_extension pfrhe
          where pfrhe.process_id = vc_previous_eom_id
            and pfrhe.section_name = 'List of Balance Price Fixations'
          group by pfrhe.corporate_id,
                   pfrhe.corporate_name,
                   pfrhe.product_id,
                   pfrhe.product_name,
                   pfrhe.purchase_sales;
        commit;
       --
       -- Same above data into Consumption Section 
       -- 
       insert into pfrhe_pfrh_extension
         (process_id,
          eod_trade_date,
          corporate_id,
          corporate_name,
          product_id,
          product_name,
          purchase_sales,
          fixed_qty,
          weighted_avg_price,
          from_section_name,
          section_name,
          consumed_qty,
          fixation_value)
         select pc_process_id,
                pd_trade_date,
                pfrhe.corporate_id,
                pfrhe.corporate_name,
                pfrhe.product_id,
                pfrhe.product_name,
                pfrhe.purchase_sales,
                sum(fixed_qty), -- This is Balance qty
                case
                  when sum(fixed_qty) = 0 then
                   0
                  else
                   sum((fixed_qty) * weighted_avg_price) / sum(fixed_qty)
                end,
                'List of Balance Price Fixations from previous Month',
                'List of Consumed Fixations for Realization',
                0 consumed_qty, -- Will Update later based on new realization 
                0 -- This has to be Realized qty * WAP
           from pfrhe_pfrh_extension pfrhe
          where pfrhe.process_id = pc_process_id
            and pfrhe.section_name = 'List of Balance Price Fixations from previous Month'
          group by pfrhe.corporate_id,
                   pfrhe.corporate_name,
                   pfrhe.product_id,
                   pfrhe.product_name,
                   pfrhe.purchase_sales;
    vc_error_msg := 'New PFC for this Month';
    commit;
          
    --
    -- New PFC for this Month for Concentrates Active
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
   price_fixed_date,
   is_new_pfc,
   internal_action_ref_no,
   pf_ref_no,
   fixed_qty,
   fixed_qty_unit_id,
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
   contract_type,
   base_qty_unit_id,
   base_qty_unit,
   base_price_unit_id,
   base_price_unit_name,
   prod_base_to_price_wt_factor,
   is_active)
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
         pfd.hedge_correction_date price_fixation_date,
         'Y',
         axs.internal_action_ref_no,
         axs.action_ref_no as pf_ref_no,
         pfd.qty_fixed * ucm.multiplication_factor fixed_qty,
         pocd.qty_to_be_fixed_unit_id,
         pfd.user_price,
         pfd.price_unit_id,
         ppu.cur_id,
         cm.cur_code,
         ppu.weight_unit_id,
         qum.qty_unit,
         ppu.weight,
         ppu.price_unit_name,
         1 fx_to_base, -- Calcualte Exchange Rate from Payable to Base Later
         pfd.user_price * ucm_price.multiplication_factor price_in_base, -- Apply Exchange Rate later
         0 consumed_qty,
         (case
           when pcm.purchase_sales = 'P' then
            1
           else
            (-1)
         end) * pfd.qty_fixed * pfd.user_price *  ucm.multiplication_factor * 
         ucm_price.multiplication_factor /
         nvl(ppu.weight, 1) fixation_value, -- Apply Exchange Rate later
         ucm.multiplication_factor,
         pfd.pfd_id,
         aml.attribute_id,
         pcm.contract_type,
         qum_qty.qty_unit_id,
         qum_qty.qty_unit,
         ppu_base.product_price_unit_id,
         ppu_base.price_unit_name,
         ucm_price.multiplication_factor,
         pfd.is_active
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
         qum_quantity_unit_master       qum_qty,
         ucm_unit_conversion_master     ucm_price,
         v_ppu_pum                      ppu_base
   where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
     and pcdi.pcdi_id = poch.pcdi_id
     and poch.poch_id = pocd.poch_id
     and pocd.pocd_id = pofh.pocd_id
     and pofh.pofh_id = pfd.pofh_id
     and pfd.pfd_id = pfam.pfd_id
     and pfam.internal_action_ref_no = axs.internal_action_ref_no
     and poch.element_id = aml.attribute_id
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
     and pfam.is_active = 'Y'
     and pfd.is_active ='Y'
     and pcm.contract_type = 'CONCENTRATES'
     and pfd.hedge_correction_date > vd_prev_eom_date
     and pfd.hedge_correction_date <= pd_trade_date
     and pcm.is_pass_through = 'N'
     and ucm_price.from_qty_unit_id = pdm_aml.base_quantity_unit
     and ucm_price.to_qty_unit_id = ppu.weight_unit_id
     and ucm_price.is_active = 'Y'
     and ppu_base.product_id = pdm_aml.product_id
     and ppu_base.cur_id = akc.base_cur_id
     and ppu_base.weight_unit_id = pdm_aml.base_quantity_unit
     and axs.process = 'EOM'
     and pocd.price_type <> 'Fixed';
     commit;
     
  --
    -- New PFC for this Month for Concentrates Cancelled
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
   price_fixed_date,
   is_new_pfc,
   internal_action_ref_no,
   pf_ref_no,
   fixed_qty,
   fixed_qty_unit_id,
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
   contract_type,
   base_qty_unit_id,
   base_qty_unit,
   base_price_unit_id,
   base_price_unit_name,
   prod_base_to_price_wt_factor,
   is_active)
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
         pfd.hedge_correction_date price_fixation_date,
         'Y',
         axs.internal_action_ref_no,
         axs.action_ref_no as pf_ref_no,
         pfd.qty_fixed * ucm.multiplication_factor fixed_qty,
         pocd.qty_to_be_fixed_unit_id,
         pfd.user_price,
         pfd.price_unit_id,
         ppu.cur_id,
         cm.cur_code,
         ppu.weight_unit_id,
         qum.qty_unit,
         ppu.weight,
         ppu.price_unit_name,
         1 fx_to_base, -- Calcualte Exchange Rate from Payable to Base Later
         pfd.user_price * ucm_price.multiplication_factor price_in_base, -- Apply Exchange Rate later
         0 consumed_qty,
         (case
           when pcm.purchase_sales = 'P' then
            1
           else
            (-1)
         end) * pfd.qty_fixed * pfd.user_price *  ucm.multiplication_factor * 
         ucm_price.multiplication_factor /
         nvl(ppu.weight, 1) fixation_value, -- Apply Exchange Rate later
         ucm.multiplication_factor,
         pfd.pfd_id,
         aml.attribute_id,
         pcm.contract_type,
         qum_qty.qty_unit_id,
         qum_qty.qty_unit,
         ppu_base.product_price_unit_id,
         ppu_base.price_unit_name,
         ucm_price.multiplication_factor,
         pfd.is_active
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
         qum_quantity_unit_master       qum_qty,
         ucm_unit_conversion_master     ucm_price,
         v_ppu_pum                      ppu_base
   where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
     and pcdi.pcdi_id = poch.pcdi_id
     and poch.poch_id = pocd.poch_id
     and pocd.pocd_id = pofh.pocd_id
     and pofh.pofh_id = pfd.pofh_id
     and pfd.pfd_id = pfam.pfd_id
     and pfam.internal_action_ref_no = axs.internal_action_ref_no
     and poch.element_id = aml.attribute_id
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
     and pfam.is_active = 'Y'
     and pfd.is_active ='N'
     and pfd.cancel_action_ref_no is not null
     and nvl(pfd.user_price,0) <> 0
     and pcm.contract_type = 'CONCENTRATES'
     and pfd.hedge_correction_date > vd_prev_eom_date
     and pfd.hedge_correction_date <= pd_trade_date
     and pcm.is_pass_through = 'N'
     and ucm_price.from_qty_unit_id = pdm_aml.base_quantity_unit
     and ucm_price.to_qty_unit_id = ppu.weight_unit_id
     and ucm_price.is_active = 'Y'
     and ppu_base.product_id = pdm_aml.product_id
     and ppu_base.cur_id = akc.base_cur_id
     and ppu_base.weight_unit_id = pdm_aml.base_quantity_unit
     and axs.process = 'EOM'
     and pocd.price_type <> 'Fixed';
     commit;     
    --
    -- New PFC for this Month for Base Metal Active Records
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
   price_fixed_date,
   is_new_pfc,
   internal_action_ref_no,
   pf_ref_no,
   fixed_qty,
   fixed_qty_unit_id,
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
   contract_type,
   base_qty_unit_id,
   base_qty_unit,
   base_price_unit_id,
   base_price_unit_name,
   prod_base_to_price_wt_factor,
   is_active)
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
         pfd.hedge_correction_date price_fixation_date,
         'Y',
         axs.internal_action_ref_no,
         axs.action_ref_no as pf_ref_no,
         pfd.qty_fixed * ucm.multiplication_factor fixed_qty,
         pocd.qty_to_be_fixed_unit_id,
         pfd.user_price,
         pfd.price_unit_id,
         ppu.cur_id,
         cm.cur_code,
         ppu.weight_unit_id,
         qum.qty_unit,
         ppu.weight,
         ppu.price_unit_name,
         1 fx_to_base,
         pfd.user_price * ucm_price.multiplication_factor price_in_base,
         0 consumed_qty,
         (case
           when pcm.purchase_sales = 'P' then
            1
           else
            (-1)
         end) * pfd.qty_fixed * pfd.user_price * 
         ucm_price.multiplication_factor * ucm.multiplication_factor /
         nvl(ppu.weight, 1) fixation_value,
         ucm.multiplication_factor,
         pfd.pfd_id,
         vped.element_id,
         pcm.contract_type,
         qum_qty.qty_unit_id,
         qum_qty.qty_unit,
         ppu_base.product_price_unit_id,
         ppu_base.price_unit_name,
         ucm_price.multiplication_factor,
         pfd.is_active
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
         qum_quantity_unit_master       qum_qty,
         ucm_unit_conversion_master     ucm_price,
         v_ppu_pum ppu_base
   where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
     and pcdi.pcdi_id = poch.pcdi_id
     and poch.poch_id = pocd.poch_id
     and pocd.pocd_id = pofh.pocd_id
     and pofh.pofh_id = pfd.pofh_id
     and pfd.pfd_id = pfam.pfd_id
     and pfam.internal_action_ref_no = axs.internal_action_ref_no
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
     and pfam.is_active = 'Y'
     and pcpd.is_active = 'Y'
     and pfd.is_active ='Y'
     and pcm.contract_type = 'BASEMETAL'
     and pfd.hedge_correction_date > vd_prev_eom_date
     and pfd.hedge_correction_date <= pd_trade_date
     and ucm_price.from_qty_unit_id = pdm.base_quantity_unit
     and ucm_price.to_qty_unit_id = ppu.weight_unit_id
     and ucm_price.is_active = 'Y'
     and ppu_base.product_id = pdm.product_id
     and ppu_base.cur_id = akc.base_cur_id
     and ppu_base.weight_unit_id = pdm.base_quantity_unit
     and axs.process = 'EOM'
     and pocd.price_type <> 'Fixed';

    commit;
    
      --
    -- New PFC for this Month for Base Metal Cancelled Records
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
   price_fixed_date,
   is_new_pfc,
   internal_action_ref_no,
   pf_ref_no,
   fixed_qty,
   fixed_qty_unit_id,
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
   contract_type,
   base_qty_unit_id,
   base_qty_unit,
   base_price_unit_id,
   base_price_unit_name,
   prod_base_to_price_wt_factor,
   is_active)
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
         pfd.hedge_correction_date price_fixation_date,
         'Y',
         axs.internal_action_ref_no,
         axs.action_ref_no as pf_ref_no,
         pfd.qty_fixed * ucm.multiplication_factor fixed_qty,
         pocd.qty_to_be_fixed_unit_id,
         pfd.user_price,
         pfd.price_unit_id,
         ppu.cur_id,
         cm.cur_code,
         ppu.weight_unit_id,
         qum.qty_unit,
         ppu.weight,
         ppu.price_unit_name,
         1 fx_to_base,
         pfd.user_price * ucm_price.multiplication_factor price_in_base,
         0 consumed_qty,
         (case
           when pcm.purchase_sales = 'P' then
            1
           else
            (-1)
         end) * pfd.qty_fixed * pfd.user_price * 
         ucm_price.multiplication_factor * ucm.multiplication_factor /
         nvl(ppu.weight, 1) fixation_value,
         ucm.multiplication_factor,
         pfd.pfd_id,
         vped.element_id,
         pcm.contract_type,
         qum_qty.qty_unit_id,
         qum_qty.qty_unit,
         ppu_base.product_price_unit_id,
         ppu_base.price_unit_name,
         ucm_price.multiplication_factor,
         pfd.is_active
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
         qum_quantity_unit_master       qum_qty,
         ucm_unit_conversion_master     ucm_price,
         v_ppu_pum ppu_base
   where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
     and pcdi.pcdi_id = poch.pcdi_id
     and poch.poch_id = pocd.poch_id
     and pocd.pocd_id = pofh.pocd_id
     and pofh.pofh_id = pfd.pofh_id
     and pfd.pfd_id = pfam.pfd_id
     and pfam.internal_action_ref_no = axs.internal_action_ref_no
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
     and pfam.is_active = 'Y'
     and pcpd.is_active = 'Y'
     and pfd.is_active ='N'
     and pfd.cancel_action_ref_no is not null
     and nvl(pfd.user_price,0) <> 0
     and pcm.contract_type = 'BASEMETAL'
     and pfd.hedge_correction_date > vd_prev_eom_date
     and pfd.hedge_correction_date <= pd_trade_date
     and ucm_price.from_qty_unit_id = pdm.base_quantity_unit
     and ucm_price.to_qty_unit_id = ppu.weight_unit_id
     and ucm_price.is_active = 'Y'
     and ppu_base.product_id = pdm.product_id
     and ppu_base.cur_id = akc.base_cur_id
     and ppu_base.weight_unit_id = pdm.base_quantity_unit
     and axs.process = 'EOM'
     and pocd.price_type <> 'Fixed';

    commit;  
    
    vc_error_msg := 'Add Free Metal';
    --
    -- New PFC for this Month for Free Metal
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
   element_id,
   instrument_id,
   instrument_name,
   cp_id,
   cp_name,
   internal_contract_ref_no,
   delivery_item_no,
   contract_type,
   pcdi_id,
   contract_ref_no_del_item_no,
   price_fixed_date,
   internal_action_ref_no,
   pfd_id,
   is_new_pfc,
   pf_ref_no,
   fixed_qty,
   fixed_qty_unit_id,
   fixed_unit_base_qty_factor,
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
   base_qty_unit_id,
   base_qty_unit,
   is_free_metal,
   base_price_unit_id,
   base_price_unit_name,
   prod_base_to_price_wt_factor,
   is_active)
  select pc_process_id process_id,
         pd_trade_date eod_trade_date,
         'New PFC for this Month' section_name,
         'Purchase' purchase_sales,
         akc.corporate_id,
         akc.corporate_name,
         pdm.product_id,
         pdm.product_desc,
         aml.attribute_id element_id,
         null instrument_id,
         null instrument_name,
         phd.profileid cp_id,
         phd.companyname cp_name,
         null internal_contract_ref_no,
         null delivery_item_no,
         'P' contract_type,
         null pcdi_id,
         null contract_ref_no_del_item_no,
         axs.eff_date price_fixed_date,
         axs.internal_action_ref_no,
         fmed.fmed_id pfd_id,
         'Y' is_new_pfc,
         axs.action_ref_no pf_ref_no,
         nvl(fmpfd.qty_fixed, 0) * ucm.multiplication_factor fixed_qty,
         fmed.qty_unit_id,
         ucm.multiplication_factor fixed_unit_base_qty_factor,
         fmpfd.user_price price,
         fmpfd.price_unit_id,
         ppu.cur_id price_unit_cur_id,
         cm.cur_code price_unit_cur_code,
         qum.qty_unit_id price_unit_weight_unit_id,
         qum.qty_unit price_unit_weight_unit,
         ppu.weight price_unit_weight,
         ppu.price_unit_name,
         1 fx_price_to_base_cur,
         fmpfd.user_price * ucm_price.multiplication_factor price_in_base_cur,
         0 consumed_qty,
         fmpfd.user_price * nvl(fmpfd.qty_fixed, 0) *
         ucm_price.multiplication_factor * ucm.multiplication_factor /
         nvl(ppu.weight, 1) fixation_value,
         pdm.base_quantity_unit base_qty_unit_id,
         qum_pdm.qty_unit base_qty_unit,
         'Y' is_free_metal,
         ppu_base.product_price_unit_id,
         ppu_base.price_unit_name,
         ucm_price.multiplication_factor,
         fmpfd.is_active
    from fmuh_free_metal_utility_header fmuh,
         fmed_free_metal_elemt_details  fmed,
         fmpfh_price_fixation_header    fmpfh,
         fmpfd_price_fixation_details   fmpfd,
         fmpfam_price_action_mapping    fmpfam,
         ak_corporate                   akc,
         qum_quantity_unit_master       qum,
         phd_profileheaderdetails       phd,
         aml_attribute_master_list      aml,
         pdm_productmaster              pdm,
         axs_action_summary             axs,
         ucm_unit_conversion_master     ucm,
         v_ppu_pum                      ppu,
         cm_currency_master             cm,
         qum_quantity_unit_master       qum_ppu,
         qum_quantity_unit_master       qum_pdm,
         ucm_unit_conversion_master     ucm_price,
         v_ppu_pum                      ppu_base
   where fmuh.fmuh_id = fmed.fmuh_id
     and fmed.fmed_id = fmpfh.fmed_id
     and fmed.element_id = fmpfh.element_id
     and fmpfh.fmpfh_id = fmpfd.fmpfh_id
     and fmpfd.fmpfd_id = fmpfam.fmpfd_id
     and fmpfam.is_active = 'Y'
     and fmuh.is_active = 'Y'
     and fmed.is_active = 'Y'
     and fmpfh.is_active = 'Y'
     and fmuh.corporate_id = akc.corporate_id
     and fmed.qty_unit_id = qum.qty_unit_id
     and phd.profileid = fmuh.smelter_id
     and fmed.element_id = aml.attribute_id
     and aml.underlying_product_id = pdm.product_id
     and fmpfam.internal_action_ref_no = axs.internal_action_ref_no
     and axs.corporate_id = pc_corporate_id
     and ucm.from_qty_unit_id = fmed.qty_unit_id  
     and ucm.to_qty_unit_id = pdm.base_quantity_unit
     and ucm.is_active = 'Y'
     and ppu.product_price_unit_id = fmpfd.price_unit_id
     and ppu.cur_id = cm.cur_id
     and ppu.weight_unit_id = qum_ppu.qty_unit_id
     and qum_pdm.qty_unit_id = pdm.base_quantity_unit
     and axs.eff_date > vd_prev_eom_date
     and axs.eff_date < = pd_trade_date
     and axs.process = 'EOM'
     and ucm_price.from_qty_unit_id = pdm.base_quantity_unit
     and ucm_price.to_qty_unit_id = ppu.weight_unit_id
     and ucm_price.is_active = 'Y'
     and ppu_base.product_id = pdm.product_id
     and ppu_base.cur_id = akc.base_cur_id
     and ppu_base.weight_unit_id = pdm.base_quantity_unit;
   commit;
   
   --
   -- If the Price Is Missing Throw the Error
   --
   
   insert into eel_eod_eom_exception_log
     (corporate_id,
      submodule_name,
      exception_code,
      data_missing_for,
      trade_ref_no,
      process,
      process_run_date,
      process_run_by,
      dr_id,
      trade_date)
     select pfrd.corporate_id,
            'pkg_phy_mbv_report.sp_calc_pf_data',
            'PHY-105',
            'Contract Delivery No: ' || pfrd.contract_ref_no_del_item_no || ' PF Ref No: ' || pfrd.pf_ref_no,
            null,
            pc_process,
            sysdate,
            pc_user_id,
            null,
            pd_trade_date
       from pfrd_price_fix_report_detail pfrd
      where pfrd.process_id = pc_process_id
        and pfrd.is_free_metal = 'N'
        and nvl(pfrd.price,0) =0;
    commit;
insert into eel_eod_eom_exception_log
  (corporate_id,
   submodule_name,
   exception_code,
   data_missing_for,
   trade_ref_no,
   process,
   process_run_date,
   process_run_by,
   dr_id,
   trade_date)
  select pfrd.corporate_id,
         'pkg_phy_mbv_report.sp_calc_pf_data',
         'PHY-105',
         'Free Metal PF Ref No: ' || pfrd.pf_ref_no,
         null,
         pc_process,
         sysdate,
         pc_user_id,
         null,
         pd_trade_date
    from pfrd_price_fix_report_detail pfrd
   where pfrd.process_id = pc_process_id
     and pfrd.is_free_metal = 'Y'
     and nvl(pfrd.price,0) = 0;
   --
   -- FX Rate from Payable to Base, Price in Base and Fixation Value
   --
   for cur_exch_rate in(
   select pfrd.price_unit_cur_id
     from pfrd_price_fix_report_detail pfrd
    where pfrd.process_id = pc_process_id
      and pfrd.price_unit_cur_id <> vc_base_cur_id
    group by pfrd.price_unit_cur_id)loop
    select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                    cur_exch_rate.price_unit_cur_id,
                                                    vc_base_cur_id,
                                                    pd_trade_date,
                                                    1)
      into vn_exch_rate
      from dual;
      update pfrd_price_fix_report_detail pfrd
         set pfrd.fx_price_to_base_cur = vn_exch_rate,
             pfrd.price_in_base_cur    = pfrd.price_in_base_cur *
                                         vn_exch_rate,
             pfrd.fixation_value       = pfrd.fixation_value * vn_exch_rate
       where pfrd.process_id = pc_process_id
         and pfrd.price_unit_cur_id = cur_exch_rate.price_unit_cur_id;
    end loop;
    commit;
     --
     -- Need to insert PFRH here and Update the realized qty, since we have to use the 
     -- Realized qty per product and distribute it across price fixations in asecnding order
     -- for the New PFC This Month records and Previous Month Records
     --
     -- Insert Header Raw Data
     --
      vc_error_msg := 'Insert Header Raw Data';
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
   price_fix_qty_sales_new,
   base_qty_unit_id,
   base_qty_unit,
   base_cur_decimals,
   base_qty_decimals,
   base_price_unit_id,
   base_price_unit_name)
  select pc_process_id,
         pd_trade_date,
         pfrd.corporate_id,
         pfrd.corporate_name,
         pfrd.product_id,
         pfrd.product_name,
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
         0 price_fix_qty_sales_new,
         pfrd.base_qty_unit_id,
         pfrd.base_qty_unit,
         cm.decimals,
         qum.decimals,
         ppu_base.product_price_unit_id,
         ppu_base.price_unit_name
    from pfrd_price_fix_report_detail pfrd,
         ak_corporate                 akc,
         cm_currency_master           cm,
         qum_quantity_unit_master     qum,
         v_ppu_pum                    ppu_base
   where pfrd.process_id = pc_process_id
     and pfrd.corporate_id = akc.corporate_id
     and akc.base_cur_id = cm.cur_id
     and pfrd.base_qty_unit_id = qum.qty_unit_id
     and ppu_base.product_id = pfrd.product_id
     and ppu_base.cur_id = akc.base_cur_id
     and ppu_base.weight_unit_id = pfrd.base_qty_unit_id
   group by pfrd.corporate_id,
            pfrd.corporate_name,
            pfrd.product_id,
            pfrd.product_name,
            pfrd.base_qty_unit_id,
            pfrd.base_qty_unit,
            cm.decimals,
            qum.decimals,
            ppu_base.product_price_unit_id,
            ppu_base.price_unit_name,
            ppu_base.price_unit_id;
        commit;
        --
        -- Update Priced and Arrived Qty and Priced and Delivered Qty
        -- 
    for cur_pcs in (
    select sum(nvl(css.priced_arrived_qty,0)) priced_arrived_qty,
           sum(nvl(css.priced_delivered_qty,0)) priced_delivered_qty,
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
        vc_error_msg := 'Update Previous Month Realized Qty';
        --
        -- Update Previous Month Realized Qty
        --
        for cur_pfhr_prev_real_qty in ( 
            select pfrh_prev.product_id,
                        sum(case
                              when pfrh_prev.eod_trade_date = vd_prev_eom_date then
                               pfrh_prev.realized_qty
                              else
                               0
                            end) realized_qty_prev_month
                   from pfrh_price_fix_report_header pfrh_prev
                  where pfrh_prev.eod_trade_date <= vd_prev_eom_date
                  and pfrh_prev.corporate_id = pc_corporate_id
                  group by pfrh_prev.product_id)
        loop
          update pfrh_price_fix_report_header pfrh
             set pfrh.realized_qty_prev_month = cur_pfhr_prev_real_qty.realized_qty_prev_month
           where pfrh.process_id = pc_process_id
             and pfrh.product_id = cur_pfhr_prev_real_qty.product_id;
        end loop;
        commit;   
  --
        -- Update Price Fixation Qty OB for Purchase and Sales
        --
              
for cur_pfhr_prev_real_qty in ( 
            select pfrh_prev.product_id,
                        sum(pfrh_prev.price_fix_qty_purchase_new) -
                        sum(pfrh_prev.realized_qty_current_month) price_fix_qty_purchase_ob,
                        sum(pfrh_prev.price_fix_qty_sales_new) -
                        sum(pfrh_prev.realized_qty_current_month) price_fix_qty_sales_ob
                   from pfrh_price_fix_report_header pfrh_prev
                  where pfrh_prev.eod_trade_date <= vd_prev_eom_date
                  and pfrh_prev.corporate_id = pc_corporate_id
                  group by pfrh_prev.product_id)
        loop
          update pfrh_price_fix_report_header pfrh
             set pfrh.price_fix_qty_purchase_ob = cur_pfhr_prev_real_qty.price_fix_qty_purchase_ob,
             pfrh.price_fix_qty_sales_ob = cur_pfhr_prev_real_qty.price_fix_qty_sales_ob
           where pfrh.process_id = pc_process_id
             and pfrh.product_id = cur_pfhr_prev_real_qty.product_id;
        end loop;
                    
 --
        -- Update Realized Qty Current Month = (Realized Qty - Realized Qty Last EOM)
        --
        update pfrh_price_fix_report_header pfrh
           set pfrh.realized_qty_current_month = pfrh.realized_qty -
                                                 pfrh.realized_qty_prev_month
         where pfrh.process_id = pc_process_id;
         commit;
                 
 vc_error_msg := 'Open Purchase And Sales Price Fixation Qty';             
        --
        -- PFRH Aggregated available data from PFRD
        --
        for cur_pf_qty in (
            select pfrd.product_id,
                sum(nvl(case
                            when pfrd.purchase_sales = 'Purchase' then
                             pfrd.fixed_qty
                            else
                             0
                          end,
                          0)) purchase_price_fix_qty,
                  sum(nvl(case
                            when pfrd.purchase_sales = 'Sales' then
                             pfrd.fixed_qty
                            else
                             0
                          end,
                          0)) sales_price_fix_qty,
                   ppu.product_price_unit_id wap_price_unit_id,
                   ppu.price_unit_name       wap_price_unit_name,
                   cm.cur_id                 wap_price_cur_id,
                   cm.cur_code               wap_price_cur_code,
                   qum.qty_unit_id           wap_price_weight_unit_id,
                   qum.qty_unit              wap_price_weight_unit,
                   ppu.weight                wap_price_weight
              from pfrd_price_fix_report_detail pfrd,
                   v_ppu_pum                    ppu,
                   qum_quantity_unit_master     qum,
                   cm_currency_master           cm,
                   ak_corporate                 akc
             where pfrd.process_id = pc_process_id
               and pfrd.section_name = 'New PFC for this Month'
               and pfrd.product_id = ppu.product_id
               and pfrd.corporate_id = akc.corporate_id
               and ppu.cur_id = akc.base_cur_id
               and ppu.cur_id = cm.cur_id
               and ppu.weight_unit_id = qum.qty_unit_id
               and ppu.weight_unit_id = pfrd.base_qty_unit_id
             group by pfrd.product_id,
                      ppu.product_price_unit_id,
                      ppu.price_unit_name,
                      cm.cur_id,
                      cm.cur_code,
                      qum.qty_unit_id,
                      qum.qty_unit,
                      ppu.weight)
        loop
          update pfrh_price_fix_report_header pfrh
             set pfrh.wap_price_unit_id = cur_pf_qty.wap_price_unit_id,
                 pfrh.wap_price_unit_name = cur_pf_qty.wap_price_unit_name,
                 pfrh.wap_price_cur_id = cur_pf_qty.wap_price_cur_id,
                 pfrh.wap_price_cur_code = cur_pf_qty.wap_price_cur_code,
                 pfrh.wap_price_weight_unit_id = cur_pf_qty.wap_price_weight_unit_id,
                 pfrh.wap_price_weight_unit = cur_pf_qty.wap_price_weight_unit,
                 pfrh.wap_price_weight = cur_pf_qty.wap_price_weight,
                 pfrh.price_fix_qty_purchase_new = cur_pf_qty.purchase_price_fix_qty,
                 pfrh.price_fix_qty_sales_new = cur_pf_qty.sales_price_fix_qty
           where pfrh.process_id = pc_process_id
             and pfrh.product_id = cur_pf_qty.product_id;
        end loop;
        commit;        

--
-- Update PFRH WAP Purchase / Sales for New PFC
--
for cur_pfrd1 in(
select pfrd.product_id,
       case when sum(case
             when pfrd.purchase_sales = 'Purchase' then
              pfrd.fixed_qty
             else
              0
           end) = 0 then 0
           else
           sum(case
             when pfrd.purchase_sales = 'Purchase' then
              pfrd.fixation_value
             else
              0
           end) /
       sum(case
             when pfrd.purchase_sales = 'Purchase' then
              pfrd.fixed_qty
             else
              0
           end)
           end wap_purchase_price_fixtion_new,
           case when sum(case
             when pfrd.purchase_sales = 'Sales' then
              pfrd.fixed_qty
             else
              0
           end) = 0 then 0
           else
           sum(case
             when pfrd.purchase_sales = 'Sales' then
            -1 *  pfrd.fixation_value
             else
              0
           end) /
       sum(case
             when pfrd.purchase_sales = 'Sales' then
              pfrd.fixed_qty
             else
              0
           end)
           end wap_sales_price_fixtion_new
  from pfrd_price_fix_report_detail pfrd
 where pfrd.section_name = 'New PFC for this Month'
  and pfrd.process_id = pc_process_id
 group by pfrd.product_id) loop
 update pfrh_price_fix_report_header pfrh
    set pfrh.wap_purchase_price_fixtion_new = cur_pfrd1.wap_purchase_price_fixtion_new,
        pfrh.wap_sales_price_fixtion_new    = cur_pfrd1.wap_sales_price_fixtion_new
  where pfrh.process_id = pc_process_id
    and pfrh.product_id = cur_pfrd1.product_id;
 end loop;
 commit;

--
-- Put New PFC This month to PFTHE, required for consumption record
--
insert into pfrhe_pfrh_extension
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   product_id,
   product_name,
   purchase_sales,
   fixed_qty,
   weighted_avg_price,
   from_section_name,
   section_name,
   consumed_qty,
   fixation_value,
   base_price_unit_id,
   base_price_unit_name)
-- Split header data into purchase and sales
  select pfrh.process_id,
         pfrh.eod_trade_date,
         pfrh.corporate_id,
         pfrh.corporate_name,
         pfrh.product_id,
         pfrh.product_name,
         'Purchase',
         pfrh.price_fix_qty_purchase_new,
         pfrh.wap_purchase_price_fixtion_new,
         'New PFC for this Month',
         'List of Consumed Fixations for Realization',
         0,
         0,-- update when realized qty is available
         pfrh.base_price_unit_id,
         pfrh.base_price_unit_name
    from pfrh_price_fix_report_header pfrh
   where pfrh.process_id = pc_process_id
  union all
  select pfrh.process_id,
         pfrh.eod_trade_date,
         pfrh.corporate_id,
         pfrh.corporate_name,
         pfrh.product_id,
         pfrh.product_name,
         'Sales',
         pfrh.price_fix_qty_sales_new,
         pfrh.wap_sales_price_fixtion_new,
         'New PFC for this Month',
         'List of Consumed Fixations for Realization',
         0,
         0, -- update when realized qty is available
         pfrh.base_price_unit_id,
         pfrh.base_price_unit_name
    from pfrh_price_fix_report_header pfrh
   where pfrh.process_id = pc_process_id;
        
        vc_error_msg := 'Update Priced and Arrived Qty and Priced and Delivered Qty';     
     
        
       
        --
        -- List of Consumed Fixations for Realization
        --
        vc_error_msg := 'List of Consumed Fixations for Realization Purchase';
        --
        -- Purchase First 
        --
        for cur_pfrh in(     
        select pfrh.product_id,
               pfrh.realized_qty_current_month consumed_qty
          from pfrh_price_fix_report_header pfrh
         where pfrh.process_id = pc_process_id
           and pfrh.realized_qty_current_month > 0) loop
        vn_qty_to_consume := cur_pfrh.consumed_qty ;  
        for cur_consumed in(                                
        select pfrhe.product_id,
               pfrhe.purchase_sales,
               pfrhe.fixed_qty,
               nvl(pfrhe.consumed_qty,0) prev_consumed_qty,
               pfrhe.from_section_name
          from pfrhe_pfrh_extension pfrhe
         where pfrhe.process_id = pc_process_id
           and pfrhe.purchase_sales = 'Purchase'
           and pfrhe.product_id = cur_pfrh.product_id
           and pfrhe.section_name = 'List of Consumed Fixations for Realization'
         order by pfrhe.from_section_name) loop -- Balance First and New PFC Next
         -- While consuming we should take into account of previous consumed qty if any
        If vn_qty_to_consume <=  cur_consumed.fixed_qty - cur_consumed.prev_consumed_qty then
            vn_consumed_for_this_fixation := vn_qty_to_consume;
            vn_qty_to_consume := 0;
        else
            vn_consumed_for_this_fixation := cur_consumed.fixed_qty;
            vn_qty_to_consume := vn_qty_to_consume - cur_consumed.fixed_qty - cur_consumed.prev_consumed_qty ;
        end if;
        update pfrhe_pfrh_extension pfrhe
           set pfrhe.consumed_qty = vn_consumed_for_this_fixation
         where pfrhe.process_id = pc_process_id
           and pfrhe.product_id = cur_consumed.product_id
           and pfrhe.from_section_name = cur_consumed.from_section_name 
           and pfrhe.purchase_sales =cur_consumed.purchase_sales
           and pfrhe.section_name = 'List of Consumed Fixations for Realization';
            -- 
          if vn_qty_to_consume <= 0 then -- Everything is consumed for this Product
           exit;
          end if;
        end loop;
        end loop;
--
-- Sales Next
--       
    vc_error_msg := 'List of Consumed Fixations for Realization Sales';
    
for cur_pfrh in(     
        select pfrh.product_id,
               pfrh.realized_qty_current_month consumed_qty
          from pfrh_price_fix_report_header pfrh
         where pfrh.process_id = pc_process_id
           and pfrh.realized_qty_current_month > 0) loop
        vn_qty_to_consume := cur_pfrh.consumed_qty ;  
        for cur_consumed in(                                
        select pfrhe.product_id,
               pfrhe.purchase_sales,
               pfrhe.fixed_qty,
               nvl(pfrhe.consumed_qty,0) prev_consumed_qty,
               pfrhe.from_section_name
          from pfrhe_pfrh_extension pfrhe
         where pfrhe.process_id = pc_process_id
           and pfrhe.purchase_sales = 'Sales'
           and pfrhe.product_id = cur_pfrh.product_id
           and section_name = 'List of Consumed Fixations for Realization'
         order by pfrhe.from_section_name) loop -- Balance First and New Next
        If vn_qty_to_consume <=  cur_consumed.fixed_qty - cur_consumed.prev_consumed_qty then
            vn_consumed_for_this_fixation := vn_qty_to_consume;
            vn_qty_to_consume := 0;
        else
            vn_consumed_for_this_fixation := cur_consumed.fixed_qty;
            vn_qty_to_consume := vn_qty_to_consume - cur_consumed.fixed_qty - cur_consumed.prev_consumed_qty ;
        end if;
        update pfrhe_pfrh_extension pfrhe
           set pfrhe.consumed_qty = vn_consumed_for_this_fixation
         where pfrhe.process_id = pc_process_id
           and pfrhe.product_id = cur_consumed.product_id
           and pfrhe.from_section_name = cur_consumed.from_section_name 
           and pfrhe.purchase_sales =cur_consumed.purchase_sales
           and pfrhe.section_name = 'List of Consumed Fixations for Realization';
            -- 
          if vn_qty_to_consume <= 0 then -- Everything is consumed for this Product
           exit;
          end if;
        end loop;
        end loop;   
commit;
--
-- Deletion of Realization where consumed qty is zero, as this is not required
--
 vc_error_msg := 'Deletion of Realization where consumed qty is zero';
delete from pfrhe_pfrh_extension pfrhe
 where pfrhe.process_id = pc_process_id
   and pfrhe.from_section_name =
       'List of Consumed Fixations for Realization'
   and pfrhe.consumed_qty = 0;
commit;

-- 
-- List of Balance Price Fixations
--
        vc_error_msg := 'List of Balance Price Fixations';

insert into pfrhe_pfrh_extension
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   product_id,
   product_name,
   purchase_sales,
   fixed_qty,
   weighted_avg_price,
   from_section_name,
   section_name,
   consumed_qty,
   fixation_value,
   base_price_unit_id,
   base_price_unit_name)
  select process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         product_id,
         product_name,
         purchase_sales,
         pfrhe.fixed_qty - pfrhe.consumed_qty, -- show this in the report
         weighted_avg_price,
         from_section_name,
         'List of Balance Price Fixations',
         pfrhe.consumed_qty, --consumed_qty -- not shown in report, required for next EOM
         (pfrhe.fixed_qty - pfrhe.consumed_qty) * weighted_avg_price, -- Balance Qty * Price
         pfrhe.base_price_unit_id,
         pfrhe.base_price_unit_name
    from pfrhe_pfrh_extension pfrhe
   where pfrhe.process_id = pc_process_id
     and pfrhe.section_name = 'List of Consumed Fixations for Realization'
     and pfrhe.fixed_qty - pfrhe.consumed_qty > 0;
     commit;
        vc_error_msg := 'Update Realized Value PFRH';
     --
     -- Update Fixation Value = Realized Value = Consumed Qty * WAP in PFRHE
     --
     update pfrhe_pfrh_extension pfrhe
        set pfrhe.fixation_value = pfrhe.consumed_qty *
                                   pfrhe.weighted_avg_price
      where pfrhe.process_id = pc_process_id
      and pfrhe.section_name = 'List of Consumed Fixations for Realization';
     commit;
     
     
--
-- Update Below Columns from PFRHE in PFRH
-- Open Purchase Price Fixation Qty
-- WAP for Open Purchase Price Fixations
-- Open Sales Price Fixation Qty
-- WAP for Open Sales Price Fixations
--
for cur_pfrhe1 in(
SELECT   pfrhe.product_id,
         ROUND
            (SUM (CASE
                     WHEN pfrhe.purchase_sales = 'Purchase'
                        THEN pfrhe.fixed_qty
                     ELSE 0
                  END
                 ),
             4
            ) open_purchase_price_fix_qty,
         ROUND
            (SUM (CASE
                     WHEN pfrhe.purchase_sales = 'Sales'
                        THEN pfrhe.fixed_qty
                     ELSE 0
                  END
                 ),
             4
            ) open_sales_price_fix_qty,
         ROUND
            (CASE
                WHEN SUM (CASE
                             WHEN pfrhe.purchase_sales = 'Purchase'
                                THEN pfrhe.fixed_qty
                             ELSE 0
                          END
                         ) = 0
                   THEN 0
                ELSE   SUM
                          (CASE
                              WHEN pfrhe.purchase_sales = 'Purchase'
                                 THEN pfrhe.fixation_value
                              ELSE 0
                           END
                          )
                     / SUM (CASE
                               WHEN pfrhe.purchase_sales = 'Purchase'
                                  THEN pfrhe.fixed_qty
                               ELSE 0
                            END
                           )
             END,
             4
            ) wap_purchase_price_fixations,
         ROUND
            (CASE
                WHEN SUM (CASE
                             WHEN pfrhe.purchase_sales = 'Sales'
                                THEN pfrhe.fixed_qty
                             ELSE 0
                          END
                         ) = 0
                   THEN 0
                ELSE   SUM
                          (CASE
                              WHEN pfrhe.purchase_sales = 'Sales'
                                 THEN pfrhe.fixation_value
                              ELSE 0
                           END
                          )
                     / SUM (CASE
                               WHEN pfrhe.purchase_sales = 'Sales'
                                  THEN pfrhe.fixed_qty
                               ELSE 0
                            END
                           )
             END,
             4
            ) wap_sales_price_fixations
    FROM pfrhe_pfrh_extension pfrhe
   WHERE pfrhe.process_id = pc_process_id
     AND pfrhe.section_name = 'List of Balance Price Fixations'
GROUP BY pfrhe.product_id ) loop
update pfrh_price_fix_report_header pfrh
             set pfrh.purchase_price_fix_qty   = cur_pfrhe1.open_purchase_price_fix_qty,
                 pfrh.sales_price_fixation_qty = cur_pfrhe1.open_sales_price_fix_qty,
                 pfrh.wap_purchase_price_fixations = cur_pfrhe1.wap_purchase_price_fixations,
                 pfrh.wap_sales_price_fixations = cur_pfrhe1.wap_sales_price_fixations
           where pfrh.process_id = pc_process_id
             and pfrh.product_id = cur_pfrhe1.product_id;
end loop;
commit;

 --
 -- WAP will be in Product Base Quantity Unit and Base Currency
 -- i.e. Copper in USD/MT, Gold and Silver in USD/Kg
 -- This price has to be converted into M2M Price Unit
 --
 for cur_pfrh_wap in(
 select pfrh.*
   from pfrh_price_fix_report_header pfrh
  where pfrh.process_id = pc_process_id
    and pfrh.wap_purchase_price_fixations <> 0) loop
    -- Get the M2M Price Unit ID
    vc_error_msg :='Trying to get M2M Price Unit For ' ||cur_pfrh_wap.product_id;

select ppu.product_price_unit_id wap_price_unit_id,
       ppu.price_unit_name       wap_price_unit_name,
       cm.cur_id                 wap_price_cur_id,
       cm.cur_code               wap_price_cur_code,
       qum.qty_unit_id           wap_price_weight_unit_id,
       qum.qty_unit              wap_price_weight_unit,
       ppu.weight                wap_price_weight
  into vc_wap_price_unit_id,
       vc_wap_price_unit_name,
       vc_wap_price_cur_id,
       vc_wap_price_cur_code,
       vc_wap_price_weight_unit_id,
       vc_wap_price_weight_unit,
       vn_wap_price_weight
  from pdd_product_derivative_def   pdd,
       dim_der_instrument_master    dim,
       div_der_instrument_valuation div,
       v_ppu_pum                    ppu,
       cm_currency_master           cm,
       qum_quantity_unit_master     qum,
       irm_instrument_type_master   irm
 where pdd.product_id = cur_pfrh_wap.product_id
   and pdd.is_deleted = 'N'
   and pdd.is_active = 'Y'
   and dim.product_derivative_id = pdd.derivative_def_id
   and dim.is_active = 'Y'
   and dim.is_deleted = 'N'
   and div.instrument_id = dim.instrument_id
   and div.is_deleted = 'N'
   and div.price_unit_id = ppu.price_unit_id
   and ppu.product_id = cur_pfrh_wap.product_id
   and ppu.cur_id = cm.cur_id
   and ppu.weight_unit_id = qum.qty_unit_id
   and irm.instrument_type_id = dim.instrument_type_id
   and irm.is_active = 'Y'
   and irm.instrument_type = 'Future';
   vc_m2m_price_unit_id := vc_wap_price_unit_id;
    If cur_pfrh_wap.base_price_unit_id <> vc_m2m_price_unit_id then
    
     select pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                            1,
                                                            vc_m2m_price_unit_id,
                                                            cur_pfrh_wap.base_price_unit_id,
                                                            pd_trade_date)
       into vn_price_factor
       from dual;
      -- Need to update  price and all other columns
      update pfrh_price_fix_report_header pfrh
         set pfrh.wap_purchase_price_fixations = pfrh.wap_purchase_price_fixations /
                                                 vn_price_factor,
             pfrh.wap_sales_price_fixations    = pfrh.wap_sales_price_fixations /
                                                 vn_price_factor,
             pfrh.wap_price_unit_id            = vc_wap_price_unit_id,
             pfrh.wap_price_unit_name          = vc_wap_price_unit_name,
             pfrh.wap_price_cur_id             = vc_wap_price_cur_id,
             pfrh.wap_price_cur_code           = vc_wap_price_cur_code,
             pfrh.wap_price_weight_unit_id     = vc_wap_price_weight_unit_id,
             pfrh.wap_price_weight_unit        = vc_wap_price_weight_unit,
             pfrh.wap_price_weight             = vn_wap_price_weight
       where pfrh.process_id = pc_process_id
         and pfrh.product_id = cur_pfrh_wap.product_id;
    end if;
   end loop;
commit;   
        vc_error_msg := 'Update Realized Value';  
        --
        -- Update Realized Value (Consumed Qty * WAP)
        --
        for cur_realized_value in (
            select pfrhe.product_id,
                   sum(case
                         when pfrhe.purchase_sales = 'Sales' then
                          1
                         else
                          -1
                       end * pfrhe.fixation_value
                       ) fixation_value
              from pfrhe_pfrh_extension pfrhe
             where pfrhe.process_id = pc_process_id
               and pfrhe.section_name =
                   'List of Consumed Fixations for Realization'
             group by pfrhe.product_id) loop
          update pfrh_price_fix_report_header pfrh
             set pfrh.realized_value = cur_realized_value.fixation_value
           where pfrh.process_id = pc_process_id
             and pfrh.product_id = cur_realized_value.product_id;
        end loop;
        commit;
      
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
        and dpd.instrument_type in ('Future')
        and dpd.pnl_type = 'Unrealized'
        and tip.corporate_id = pc_corporate_id;
   vn_mep_value_in_base_cur    number(25, 5);
   vn_sett_value_in_base_cur   number(25, 5);
   vn_fx_rate_mep_to_base_ccy  number(30, 10);
   vn_fx_rate_sett_to_base_ccy number(30, 10);
   --month end price main currency details
   vc_mep_main_cur_id       varchar2(15);
   vc_mep_main_cur_code     varchar2(15);
   vn_mep_sub_cur_id_factor number(25, 5);
   vn_mpe_cur_decimals      number(5);
   --settlement price main currency details
   vc_sp_main_cur_id       varchar2(15);
   vc_sp_main_cur_code     varchar2(15);
   vn_sp_sub_cur_id_factor number(25, 5);
   vn_sp_cur_decimals      number(5);
   ----------------
   vn_value_diff_in_trade_ccy number(25, 5);
   vn_value_diff_in_base_ccy  number(25, 5);
   vn_temp_qty_factor         number;
   vn_temp_currency_factor    number;
 begin
   vc_error_msg := 'Start';
   for mbv_ddr_rows in mbv_ddr
   loop
     vn_value_diff_in_trade_ccy := 0;
     vn_value_diff_in_base_ccy  := 0;
   
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
     vc_error_msg := 'Conversion 1';
     if vc_sp_main_cur_id <> mbv_ddr_rows.base_cur_id then
       vn_fx_rate_sett_to_base_ccy := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                               vc_sp_main_cur_id,
                                                                               mbv_ddr_rows.base_cur_id,
                                                                               pd_trade_date,
                                                                               1);
     else
       vn_fx_rate_sett_to_base_ccy := 1;
     end if;
     vc_error_msg := 'Conversion 2';
     if vc_mep_main_cur_id <> mbv_ddr_rows.base_cur_id then
       vn_fx_rate_mep_to_base_ccy := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                              vc_mep_main_cur_id,
                                                                              mbv_ddr_rows.base_cur_id,
                                                                              pd_trade_date,
                                                                              1);
     else
       vn_fx_rate_mep_to_base_ccy := 1;
     end if;
     vc_error_msg := 'Conversion 3';
     if mbv_ddr_rows.quantity_unit_id <>
        mbv_ddr_rows.mep_price_weight_unit_id then
       select pkg_general.f_get_converted_quantity(mbv_ddr_rows.derivative_prodct_id,
                                                   mbv_ddr_rows.quantity_unit_id,
                                                   mbv_ddr_rows.mep_price_weight_unit_id,
                                                   mbv_ddr_rows.open_quantity)
         into vn_temp_qty_factor
         from dual;
     else
       vn_temp_qty_factor := mbv_ddr_rows.open_quantity;
     end if;
     vc_error_msg := 'Conversion 4';
     if mbv_ddr_rows.mep_price_cur_id <> mbv_ddr_rows.base_cur_id then
       select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                       mbv_ddr_rows.mep_price_cur_id,
                                                       mbv_ddr_rows.base_cur_id,
                                                       pd_trade_date,
                                                       1)
         into vn_temp_currency_factor
         from dual;
     else
       vn_temp_currency_factor := 1;
     end if;
     vc_error_msg             := 'MEP Value in Base';
     vn_mep_value_in_base_cur := ((mbv_ddr_rows.month_end_price /
                                 nvl(mbv_ddr_rows.mep_price_weight, 1)) *
                                 vn_temp_currency_factor) *
                                 (vn_temp_qty_factor);
     vc_error_msg             := 'Conversion 5';
     if mbv_ddr_rows.quantity_unit_id <>
        mbv_ddr_rows.sett_price_weight_unit_id then
       select pkg_general.f_get_converted_quantity(mbv_ddr_rows.derivative_prodct_id,
                                                   mbv_ddr_rows.quantity_unit_id,
                                                   mbv_ddr_rows.sett_price_weight_unit_id,
                                                   mbv_ddr_rows.open_quantity)
         into vn_temp_qty_factor
         from dual;
     else
       vn_temp_qty_factor := mbv_ddr_rows.open_quantity;
     end if;
     vc_error_msg := 'Conversion 6';
     if mbv_ddr_rows.sett_price_cur_id <> mbv_ddr_rows.base_cur_id then
       select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                       mbv_ddr_rows.sett_price_cur_id,
                                                       mbv_ddr_rows.base_cur_id,
                                                       pd_trade_date,
                                                       1)
         into vn_temp_currency_factor
         from dual;
     else
       vn_temp_currency_factor := 1;
     end if;
     vc_error_msg := 'Settlement value in Base Currency';
   
     vn_sett_value_in_base_cur := ((mbv_ddr_rows.settlement_price /
                                  nvl(mbv_ddr_rows.sett_price_weight, 1)) *
                                  vn_temp_currency_factor) *
                                  (vn_temp_qty_factor);
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
     vc_error_msg := 'Before Insert';
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
        fx_sett_ccy_to_base_ccy)
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
     vc_error_msg := 'After Insert';
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
  vn_price_factor    number;
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
  -- Raw Data Into MBV Main Table For Base Metal Products
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
     phy_realized_ob_pnl,
     phy_realized_qty,
     phy_realized_pnl,
     phy_realized_cb_pnl,
     phy_unr_price_inv_price,
     phy_unr_price_na_inv_price,
     phy_unr_price_nd_inv_price,
     referential_price_diff,
     contango_bw_diff_value,
     priced_not_arrived_qty,
     priced_not_delivered_qty,
     metal_debt_qty,
     metal_debt_value,
     inventory_unreal_pnl,
     month_end_price,
     der_realized_qty,
     der_realized_pnl,
     der_unrealized_pnl,
     der_realized_ob_pnl,
     qty_decimals,
     ccy_decimals,
     total_inv_qty,
     priced_inv_qty,
     unpriced_inv_qty,
     unr_phy_priced_inv_pnl,
     unr_phy_priced_na_pnl,
     unr_phy_priced_nd_pnl,
     der_ref_price_diff_value,
     phy_ref_price_diff_value,
     contango_dueto_qty_price,
     contango_dueto_qty,
     actual_hedged_qty,
     qty_to_be_hedged,
     hedge_effectiveness,
     currency_unit,
     qty_unit,
     base_price_unit_id)
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
           0, --    priced_not_arrived_qty,
           0, --    priced_not_delivered_qty,
           0, --    metal_debt_qty,
           0, --    metal_debt_value,
           0, --    inventory_unreal_pnl,
           0, --    month_end_price,
           0, --    der_realized_qty,
           0, --    der_realized_pnl,
           0, --    der_unrealized_pnl,
           0, --    der_realized_ob,
           qum.decimals, --    qty_decimals,
           cm.decimals, --    ccy_decimals,
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
           0, --    qty_to_be_hedged
           0, --    hedge_effectiveness,
           cm.cur_code, -- currency_unit,
           qum.qty_unit, -- qty_unit
           ppu.price_unit_id
      from ak_corporate               akc,
           pdm_productmaster          pdm,
           pdd_product_derivative_def pdd,
           dim_der_instrument_master  dim,
           emt_exchangemaster         emt,
           qum_quantity_unit_master   qum,
           cm_currency_master         cm,
           irm_instrument_type_master irm,
           v_ppu_pum                  ppu
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
       and irm.instrument_type_id = dim.instrument_type_id
       and irm.is_active = 'Y'
       and irm.instrument_type = 'Future'
       and ppu.product_id = pdm.product_id
       and ppu.weight_unit_id = pdm.base_quantity_unit
       and ppu.cur_id = akc.base_cur_id;
  commit;
  --
  -- Month End Price for Each product Assuming One Product has one instrument
  --
  vc_error_msg := 'Month End Price for Each product';
  for cur_mep in (select pdd.product_id,
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
                     and tip.price is not null)
  loop
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
                                nvl(pfrh.realized_value, 0) realized_value,
                                nvl(pfrh.realized_qty, 0) realized_qty
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
  for cur_ob in (select mbv.product_id,
                        nvl(mbv.phy_realized_cb_pnl, 0) phy_realized_ob_pnl
                   from mbv_metal_balance_valuation mbv
                  where mbv.process_id = vc_previous_eom_id)
  loop
    update mbv_metal_balance_valuation mbv
       set mbv.phy_realized_ob_pnl = cur_ob.phy_realized_ob_pnl
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_ob.product_id;
  end loop;
  commit;
  vc_error_msg := 'Derivative Unrealized and Realized PNL';
  --
  -- Derivative Unrealized and Realized PNL
  --
  for cur_der in (select nvl(sum(case
                                   when dpd.pnl_type = 'Unrealized' then
                                    dpd.pnl_in_base_cur
                                   else
                                    0
                                 end),
                             0) der_unrealized_pnl,
                         nvl(sum(case
                                   when dpd.pnl_type = 'Realized' then
                                    dpd.pnl_in_base_cur
                                   else
                                    0
                                 end),
                             0) der_realized_pnl,
                         nvl(sum(case
                                   when dpd.pnl_type = 'Realized' then
                                    dpd.closed_quantity
                                   else
                                    0
                                 end),
                             0) der_realized_qty,
                         dpd.instrument_id,
                         dpd.derivative_prodct_id
                    from dpd_derivative_pnl_daily dpd
                   where dpd.process_id = pc_process_id
                     and dpd.instrument_type in ('Future')
                   group by dpd.instrument_id,
                            dpd.derivative_prodct_id)
  loop
    update mbv_metal_balance_valuation mbv
       set mbv.der_unrealized_pnl = cur_der.der_unrealized_pnl,
           mbv.der_realized_pnl   = cur_der.der_realized_pnl,
           mbv.der_realized_qty   = cur_der.der_realized_qty
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_der.derivative_prodct_id
       and mbv.instrument_id = cur_der.instrument_id;
  end loop;
  commit;

  vc_error_msg := 'Data from Contract Status Report';
  --
  -- Data from Contract Status Report for section Qty Recon Report And 
  -- Unrealized Physical Section Columns 1) Priced and Not Arrived and 2) Priced and Not Delivered
  --
  for cur_qty_recon in (select css.product_id,
                               nvl(sum(case
                                         when css.contract_type = 'BASEMETAL' then
                                          css.priced_unarrived_qty
                                         else
                                          0
                                       end),
                                   0) priced_not_arrived_bm,
                               nvl(sum(case
                                         when css.contract_type = 'CONCENTRATES' then
                                          css.priced_unarrived_qty
                                         else
                                          0
                                       end),
                                   0) priced_not_arrived_rm,
                               nvl(sum(case
                                         when css.contract_type = 'BASEMETAL' then
                                          css.unpriced_arrived_qty
                                         else
                                          0
                                       end),
                                   0) unpriced_arrived_bm,
                               nvl(sum(case
                                         when css.contract_type = 'CONCENTRATES' then
                                          css.unpriced_arrived_qty
                                         else
                                          0
                                       end),
                                   0) unpriced_arrived_rm,
                               nvl(sum(case
                                         when css.contract_type = 'BASEMETAL' then
                                          css.unpriced_delivered_qty
                                         else
                                          0
                                       end),
                                   0) sales_unpriced_delivered_bm,
                               nvl(sum(case
                                         when css.contract_type = 'CONCENTRATES' then
                                          css.unpriced_delivered_qty
                                         else
                                          0
                                       end),
                                   0) sales_unpriced_delivered_rm,
                               nvl(sum(case
                                         when css.contract_type = 'BASEMETAL' then
                                          css.priced_undelivered_qty
                                         else
                                          0
                                       end),
                                   0) sales_priced_not_delivered_bm,
                               nvl(sum(case
                                         when css.contract_type = 'CONCENTRATES' then
                                          css.priced_undelivered_qty
                                         else
                                          0
                                       end),
                                   0) sales_priced_not_delivered_rm
                          from css_contract_status_summary css
                         where css.process_id = pc_process_id
                         group by css.product_id)
  loop
    update mbv_metal_balance_valuation mbv
       set priced_not_arrived_bm         = cur_qty_recon.priced_not_arrived_bm,
           priced_not_arrived_rm         = cur_qty_recon.priced_not_arrived_rm,
           unpriced_arrived_bm           = cur_qty_recon.unpriced_arrived_bm,
           unpriced_arrived_rm           = cur_qty_recon.unpriced_arrived_rm,
           sales_unpriced_delivered_bm   = cur_qty_recon.sales_unpriced_delivered_bm,
           sales_unpriced_delivered_rm   = cur_qty_recon.sales_unpriced_delivered_rm,
           sales_priced_not_delivered_bm = cur_qty_recon.sales_priced_not_delivered_bm,
           sales_priced_not_delivered_rm = cur_qty_recon.sales_priced_not_delivered_rm,
           priced_not_arrived_qty        = cur_qty_recon.priced_not_arrived_bm +
                                           cur_qty_recon.priced_not_arrived_rm,
           priced_not_delivered_qty      = cur_qty_recon.sales_priced_not_delivered_bm +
                                           cur_qty_recon.sales_priced_not_delivered_rm
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_qty_recon.product_id;
  end loop;
  commit;

  vc_error_msg := 'Update Actual Hedged Qty';
  --
  -- Update Actual Hedged Qty
  --
  for cur_actual_hedged_qty in (select mbvah.product_id,
                                       nvl(mbvah.actual_hedged_qty, 0) actual_hedged_qty
                                  from mbv_allocation_report_header mbvah
                                 where mbvah.process_id = pc_process_id)
  loop
  
    update mbv_metal_balance_valuation mbv
       set mbv.actual_hedged_qty = cur_actual_hedged_qty.actual_hedged_qty
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_actual_hedged_qty.product_id;
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
  for cur_inv_section in (select css.product_id,
                                 nvl(sum(css.priced_arrived_qty +
                                         css.unpriced_arrived_qty -
                                         css.priced_delivered_qty -
                                         css.unpriced_delivered_qty),
                                     0) total_inv_qty,
                                 nvl(sum(css.priced_arrived_qty -
                                         css.priced_delivered_qty),
                                     0) priced_inv_qty,
                                 nvl(sum(css.unpriced_arrived_qty -
                                         css.unpriced_delivered_qty),
                                     0) unpriced_inv_qty
                            from css_contract_status_summary css
                           where css.process_id = pc_process_id
                           group by css.product_id)
  loop
    update mbv_metal_balance_valuation mbv
       set mbv.total_inv_qty    = cur_inv_section.total_inv_qty,
           mbv.priced_inv_qty   = cur_inv_section.priced_inv_qty,
           mbv.unpriced_inv_qty = cur_inv_section.unpriced_inv_qty
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_inv_section.product_id;
  end loop;
  commit;

  vc_error_msg := 'Update Quantity to be hedged';
  --
  -- Update Quantity to be hedged
  -- 
  update mbv_metal_balance_valuation mbv
     set mbv.qty_to_be_hedged = nvl((mbv.total_inv_qty +
                                    mbv.priced_not_arrived_bm +
                                    mbv.priced_not_arrived_rm -
                                    mbv.unpriced_arrived_bm -
                                    mbv.unpriced_arrived_rm +
                                    mbv.sales_unpriced_delivered_bm +
                                    mbv.sales_unpriced_delivered_rm -
                                    mbv.sales_priced_not_delivered_bm -
                                    mbv.sales_priced_not_delivered_rm),
                                    0)
   where mbv.process_id = pc_process_id;
  commit;
  vc_error_msg := 'Update Hedge Effectivenes';
  --
  -- Update Hedge Effectivenes
  --
  update mbv_metal_balance_valuation mbv
     set mbv.hedge_effectiveness = nvl((case when mbv.qty_to_be_hedged <> 0 then 1 - (mbv.qty_to_be_hedged + mbv.actual_hedged_qty) / mbv.qty_to_be_hedged else 0 end), 0) * 100
   where mbv.process_id = pc_process_id;
  commit;
  vc_error_msg := 'Derivative Ref Price Diff';
  -- 
  --  Difference Explanation
  --
  -- Derivative Ref Price Diff
  --
  vc_error_msg := 'Derivative Ref Price Diff';
  for cur_der_ref_price_diff in (select mbvd.product_id,
                                        nvl(sum(mbvd.value_diff_in_base_ccy),
                                            0) der_ref_price_diff_value
                                   from mbv_derivative_diff_report mbvd
                                  where mbvd.process_id = pc_process_id
                                  group by mbvd.product_id)
  loop
    update mbv_metal_balance_valuation mbv
       set mbv.der_ref_price_diff_value = cur_der_ref_price_diff.der_ref_price_diff_value
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_der_ref_price_diff.product_id;
  end loop;
  commit;
  vc_error_msg := 'Physical Ref Price Diff';
  --
  -- Physical Ref Price Diff
  --
  for cur_phy_ref_price_diff in (select mbvp.product_id,
                                        nvl(sum(mbvp.referential_value_in_base_cur),
                                            0) phy_ref_price_diff_value
                                   from mbv_phy_postion_diff_report mbvp
                                  where mbvp.process_id = pc_process_id
                                  group by mbvp.product_id)
  loop
    update mbv_metal_balance_valuation mbv
       set mbv.phy_ref_price_diff_value = cur_phy_ref_price_diff.phy_ref_price_diff_value
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_phy_ref_price_diff.product_id;
  end loop;
  commit;
  vc_error_msg := 'Contango/BW Diff due to price';
  --
  -- Contango/BW Diff due to price
  --
  for cur_contango_dueto_qty_price in (select mbva.product_id,
                                              nvl(sum(mbva.contango_due_to_qty_and_price),
                                                  0) contango_dueto_qty_price
                                         from mbv_allocation_report_header mbva
                                        where mbva.process_id =
                                              pc_process_id
                                        group by mbva.product_id)
  loop
    update mbv_metal_balance_valuation mbv
       set mbv.contango_dueto_qty_price = cur_contango_dueto_qty_price.contango_dueto_qty_price
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_contango_dueto_qty_price.product_id;
  end loop;
  commit;
  vc_error_msg := 'Contango/BW Diff due to qty';
  --        
  -- Contango/BW Difference Due To Quantity
  -- = (Hedged Qty(From Physical) + Actual Hedged Qty(From Derivaties)) * Month End Price
  -- Month End Price has to be converted to Base Currency and Product Base Qty Unit
  -- 
  for cur_temp in (select mbv.qty_to_be_hedged,
                          mbv.actual_hedged_qty,
                          month_end_price,
                          mbv.month_end_price_unit_id,
                          mbv.product_id,
                          mbv.base_price_unit_id
                     from mbv_metal_balance_valuation mbv
                    where mbv.process_id = pc_process_id)
  loop
    begin
    
      select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                 1,
                                                                 cur_temp.month_end_price_unit_id,
                                                                 cur_temp.base_price_unit_id,
                                                                 pd_trade_date,
                                                                 cur_temp.product_id)
        into vn_price_factor
        from dual;
    
    exception
      when others then
        vn_price_factor := 1;
    end;
  
    update mbv_metal_balance_valuation mbv
       set mbv.contango_dueto_qty = (mbv.qty_to_be_hedged +
                                    mbv.actual_hedged_qty) *
                                    mbv.month_end_price * vn_price_factor
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_temp.product_id;
  end loop;
  commit;
  vc_error_msg := 'Update Unrealized Physical Section Price Columns';
  --
  -- Update Unrealized Physical Section Price Columns
  --
  for cur_pfhr1 in (select pfrh.product_id,
                           pfrh.wap_purchase_price_fixations,
                           pfrh.wap_sales_price_fixations
                      from pfrh_price_fix_report_header pfrh
                     where pfrh.process_id = pc_process_id)
  loop
    update mbv_metal_balance_valuation mbv
       set mbv.phy_unr_price_inv_price    = (case when mbv.priced_inv_qty < 0 then cur_pfhr1.wap_sales_price_fixations else cur_pfhr1.wap_purchase_price_fixations end),
           mbv.phy_unr_price_na_inv_price = cur_pfhr1.wap_purchase_price_fixations,
           mbv.phy_unr_price_nd_inv_price = cur_pfhr1.wap_sales_price_fixations
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_pfhr1.product_id;
  end loop;
  commit;
  vc_error_msg := 'Update Unrealized Physical Section P And L Values';
  --
  -- Update Unrealized Physical Section P And L Values
  --
  -- Priced Inventory P and L
  --
  for cur_pi_pnl in (select *
                       from mbv_metal_balance_valuation mbv
                      where mbv.process_id = pc_process_id)
  loop
    begin
      select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                 1,
                                                                 cur_pi_pnl.month_end_price_unit_id,
                                                                 cur_pi_pnl.base_price_unit_id,
                                                                 pd_trade_date,
                                                                 cur_pi_pnl.product_id)
        into vn_price_factor
        from dual;
    exception
      when others then
        vn_price_factor := 1;
    end;
    update mbv_metal_balance_valuation mbv
       set mbv.unr_phy_priced_inv_pnl = (mbv.month_end_price -
                                        phy_unr_price_inv_price) *
                                        mbv.priced_inv_qty * vn_price_factor
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_pi_pnl.product_id;
  end loop;
  commit;
  --
  -- Priced and Not Arrived PNL = Total Unrealized PNL from Physical Position Report for Purchase
  -- Priced and Not Delivered PNL = Total Unrealized PNL from Physical Position Report for Sales
  --
  for cur_mbvp in (select mbvp.product_id,
                          nvl(sum(case
                                    when mbvp.purchase_sales = 'P' then
                                     mbvp.unrealized_pnl_in_base_cur
                                    else
                                     0
                                  end),
                              0) unr_phy_priced_na_pnl,
                          nvl(sum(case
                                    when mbvp.purchase_sales = 'S' then
                                     mbvp.unrealized_pnl_in_base_cur
                                    else
                                     0
                                  end),
                              0) unr_phy_priced_nd_pnl
                     from mbv_phy_postion_diff_report mbvp
                    where mbvp.process_id = pc_process_id
                    group by mbvp.product_id)
  loop
    update mbv_metal_balance_valuation mbv
       set mbv.unr_phy_priced_na_pnl = cur_mbvp.unr_phy_priced_na_pnl,
           mbv.unr_phy_priced_nd_pnl = cur_mbvp.unr_phy_priced_nd_pnl
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_mbvp.product_id;
  end loop;
  commit;
  vc_error_msg := 'Qty Total P and L Till Date';
  --
  -- Qty Total P and L Till Date(Closing Balance) 
  -- 
  update mbv_metal_balance_valuation mbv
     set mbv.phy_realized_cb_pnl = mbv.phy_realized_ob_pnl +
                                   mbv.phy_realized_pnl
   where mbv.process_id = pc_process_id;
  commit;

  --
  -- Update Metal Debt Quantity 
  --    
  for cur_md_debt in (select md.product_id,
                             md.debt_qty
                        from md_metal_debt md
                       where md.process_id = pc_process_id)
  loop
    update mbv_metal_balance_valuation mbv
       set mbv.metal_debt_qty = -1 * cur_md_debt.debt_qty
     where mbv.process_id = pc_process_id
       and mbv.product_id = cur_md_debt.product_id;
  end loop;
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
       and pcm.contract_status <> 'Cancelled'
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
       and pcm.contract_status <> 'Cancelled'
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
                                                             to_char(vd_3rd_wed_of_qp,
                                                                     'dd-Mon-yyyy') ||
                                                             ' Trade Date :' ||
                                                             to_char(vd_valid_quote_date,
                                                                     'dd-Mon-yyyy'),
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
           case
             when pcm.purchase_sales = 'P' then
              pfrh.wap_purchase_price_fixations
             else
              pfrh.wap_sales_price_fixations
           end weighted_avg_price,
           pfrh.wap_price_unit_id,
           pfrh.wap_price_unit_name,
           pfrh.wap_price_cur_id wap_price_cur_id,
           pfrh.wap_price_cur_code wap_price_cur_code,
           pfrh.wap_price_weight_unit_id wap_price_weight_unit_id,
           pfrh.wap_price_weight_unit wap_price_weight_unit,
           pfrh.wap_price_weight wap_price_weight,
           pdm.base_quantity_unit product_base_qty_unit_id,
           qum_pdm.qty_unit product_base_qty_unit,
           ucm.multiplication_factor product_base_qty_factor
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
               and pcs.element_id is not null
               and pcs.priced_not_arrived_qty <> 0) pcs,
           pfrh_price_fix_report_header pfrh,
           tip_temp_instrument_price tip,
           pum_price_unit_master pum,
           qum_quantity_unit_master qum,
           cm_currency_master cm,
           v_ppu_pum ppu_pum,
           qum_quantity_unit_master qum_pdm,
           ucm_unit_conversion_master ucm
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
       and pcm.is_pass_through = 'N'
       and mvp.pcdi_id = pcdi.pcdi_id
       and aml.attribute_id = mvp.element_id
       and pcs.element_id = mvp.element_id
       and pcs.pcdi_id = mvp.pcdi_id
       and vped.instrument_id = tip.instrument_id
       and tip.price_unit_id = pum.price_unit_id
       and pum.weight_unit_id = qum.qty_unit_id
       and pum.cur_id = cm.cur_id
       and mvp.price_unit_id = ppu_pum.product_price_unit_id
       and pfrh.process_id = pc_process_id
       and pfrh.product_id = aml.underlying_product_id
       and tip.corporate_id = pc_corporate_id
       and pdm.base_quantity_unit = qum_pdm.qty_unit_id
       and ucm.from_qty_unit_id = pcs.payable_qty_unit_id
       and ucm.to_qty_unit_id = pdm.base_quantity_unit
    union all -- base metal contracts
    select pcm.internal_contract_ref_no,
           pcdi.pcdi_id,
           pcdi.delivery_item_no,
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
           case
             when pcm.purchase_sales = 'P' then
              pfrh.wap_purchase_price_fixations
             else
              pfrh.wap_sales_price_fixations
           end weighted_avg_price,
           pfrh.wap_price_unit_id,
           pfrh.wap_price_unit_name,
           pfrh.wap_price_cur_id wap_price_cur_id,
           pfrh.wap_price_cur_code wap_price_cur_code,
           pfrh.wap_price_weight_unit_id wap_price_weight_unit_id,
           pfrh.wap_price_weight_unit wap_price_weight_unit,
           pfrh.wap_price_weight wap_price_weight,
           pdm.base_quantity_unit product_base_qty_unit_id,
           qum_pdm.qty_unit product_base_qty_unit,
           ucm.multiplication_factor product_base_qty_factor
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
               and pcs.element_id is null
               and pcs.priced_not_arrived_qty <> 0) pcs,
           pfrh_price_fix_report_header pfrh,
           tip_temp_instrument_price tip,
           pum_price_unit_master pum,
           qum_quantity_unit_master qum,
           cm_currency_master cm,
           v_ppu_pum ppu_pum,
           qum_quantity_unit_master qum_pdm,
           ucm_unit_conversion_master ucm
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
       and pfrh.process_id = pc_process_id
       and pfrh.product_id = pcpd.product_id
       and tip.corporate_id = pc_corporate_id
       and pdm.base_quantity_unit = qum_pdm.qty_unit_id
       and ucm.from_qty_unit_id = pcs.payable_qty_unit_id
       and ucm.to_qty_unit_id = pdm.base_quantity_unit;
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
  vc_con_main_cur_id         varchar2(15);
  vc_con_main_cur_code       varchar2(15);
  vn_con_sub_cur_id_factor   number(25, 5);
  vn_con_cur_decimals        number(5);
  vn_con_price_in_base_cur   number(25, 5);
  vn_mep_value_in_base_cur   number(25, 5);
  vn_val_value_in_base_cur   number(25, 5);
  vn_fx_rate_mep_to_base_ccy number(30, 10);
  vn_fx_rate_val_to_base_ccy number(30, 10);
  vn_fx_rate_con_to_base_ccy number(30, 10);
  vn_con_value_in_base_cur   number(25, 5);
  vn_value_diff_in_base_ccy  number(25, 5);
  vn_price_diffin_base_ccy   number(25, 5);
  vn_unreal_pnl_in_base_ccy  number(25, 5);
  vn_eel_error_count         number := 1;
  vobj_error_log             tableofpelerrorlog := tableofpelerrorlog();
  vc_error_msg               varchar2(100);
  vn_temp_qty_factor         number;
  vn_temp_currency_factor    number;
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
    vc_error_msg := 'Exchange Rate Contract To Base';
    if vc_con_main_cur_id <> cur_diff_rows.base_cur_id then
      vn_fx_rate_con_to_base_ccy := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                             vc_con_main_cur_id,
                                                                             cur_diff_rows.base_cur_id,
                                                                             pd_trade_date,
                                                                             1);
    else
      vn_fx_rate_con_to_base_ccy := 1;
    end if;
    vc_error_msg := 'Exchange Rate M2M To Base';
    if vc_vp_main_cur_id <> cur_diff_rows.base_cur_id then
      vn_fx_rate_val_to_base_ccy := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                             vc_vp_main_cur_id,
                                                                             cur_diff_rows.base_cur_id,
                                                                             pd_trade_date,
                                                                             1);
    else
      vn_fx_rate_val_to_base_ccy := 1;
    end if;
    vc_error_msg := 'Exchange Rate MEP To Base';
    if vc_mep_main_cur_id <> cur_diff_rows.base_cur_id then
      vn_fx_rate_mep_to_base_ccy := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                             vc_mep_main_cur_id,
                                                                             cur_diff_rows.base_cur_id,
                                                                             pd_trade_date,
                                                                             1);
    else
      vn_fx_rate_mep_to_base_ccy := 1;
    end if;
    vn_con_price_in_base_cur := cur_diff_rows.weighted_avg_price *
                                vn_fx_rate_con_to_base_ccy;
  
    vn_val_price_in_base_cur := cur_diff_rows.val_price *
                                vn_fx_rate_val_to_base_ccy;
    vn_med_price_in_base_cur := cur_diff_rows.month_end_price *
                                vn_fx_rate_mep_to_base_ccy;
  
    if cur_diff_rows.purchase_sales = 'P' then
      vn_price_diffin_base_ccy := vn_val_price_in_base_cur -
                                  vn_med_price_in_base_cur;
    else
      vn_price_diffin_base_ccy := vn_med_price_in_base_cur -
                                  vn_val_price_in_base_cur;
    end if;
    vc_error_msg := 'Quantity Conversion From Payable to WAP';
    if cur_diff_rows.payable_qty_unit_id <>
       cur_diff_rows.wap_price_weight_unit_id then
    
      select pkg_general.f_get_converted_quantity(cur_diff_rows.product_id,
                                                  cur_diff_rows.payable_qty_unit_id,
                                                  cur_diff_rows.wap_price_weight_unit_id,
                                                  cur_diff_rows.priced_not_arrived_qty)
        into vn_temp_qty_factor
      
        from dual;
    else
      vn_temp_qty_factor := cur_diff_rows.priced_not_arrived_qty;
    end if;
    vc_error_msg := 'Exchange Rate From WAP to Base';
    if cur_diff_rows.wap_price_cur_id <> cur_diff_rows.base_cur_id then
      select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                      cur_diff_rows.wap_price_cur_id,
                                                      cur_diff_rows.base_cur_id,
                                                      pd_trade_date,
                                                      1)
        into vn_temp_currency_factor
        from dual;
    else
      vn_temp_currency_factor := 1;
    end if;
    vn_con_value_in_base_cur := ((cur_diff_rows.weighted_avg_price /
                                nvl(cur_diff_rows.wap_price_weight, 1)) *
                                vn_temp_currency_factor) *
                                (vn_temp_qty_factor);
    vc_error_msg             := 'Quantity Conversion From Payable to MEP';
    if cur_diff_rows.payable_qty_unit_id <>
       cur_diff_rows.mon_price_unit_weight_unit_id then
    
      select pkg_general.f_get_converted_quantity(cur_diff_rows.product_id,
                                                  cur_diff_rows.payable_qty_unit_id,
                                                  cur_diff_rows.mon_price_unit_weight_unit_id,
                                                  cur_diff_rows.priced_not_arrived_qty)
        into vn_temp_qty_factor
      
        from dual;
    else
      vn_temp_qty_factor := cur_diff_rows.priced_not_arrived_qty;
    end if;
    vc_error_msg := 'Exchange Rate from MEP to Base ';
    if cur_diff_rows.month_end_price_unit_cur_id <>
       cur_diff_rows.base_cur_id then
      select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                      cur_diff_rows.month_end_price_unit_cur_id,
                                                      cur_diff_rows.base_cur_id,
                                                      pd_trade_date,
                                                      1)
        into vn_temp_currency_factor
        from dual;
    else
      vn_temp_currency_factor := 1;
    end if;
    vc_error_msg             := 'MEP Value in Base';
    vn_mep_value_in_base_cur := ((cur_diff_rows.month_end_price /
                                nvl(cur_diff_rows.month_end_price_weight,
                                      1)) * vn_temp_currency_factor) *
                                (vn_temp_qty_factor);
    vc_error_msg             := 'Exchange Rate from Payable to M2M';
    if cur_diff_rows.payable_qty_unit_id <>
       cur_diff_rows.val_price_unit_weight_unit_id then
    
      select pkg_general.f_get_converted_quantity(cur_diff_rows.product_id,
                                                  cur_diff_rows.payable_qty_unit_id,
                                                  cur_diff_rows.val_price_unit_weight_unit_id,
                                                  cur_diff_rows.priced_not_arrived_qty)
        into vn_temp_qty_factor
      
        from dual;
    else
      vn_temp_qty_factor := cur_diff_rows.priced_not_arrived_qty;
    end if;
    vc_error_msg := 'Exchange Rate from Valuation to M2M';
    if cur_diff_rows.val_price_unit_cur_id <> cur_diff_rows.base_cur_id then
      select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                      cur_diff_rows.val_price_unit_cur_id,
                                                      cur_diff_rows.base_cur_id,
                                                      pd_trade_date,
                                                      1)
        into vn_temp_currency_factor
        from dual;
    else
      vn_temp_currency_factor := 1;
    end if;
    vc_error_msg             := 'Valuation Value in Base Currency';
    vn_val_value_in_base_cur := ((cur_diff_rows.val_price /
                                nvl(cur_diff_rows.val_price_weight, 1)) *
                                vn_temp_currency_factor) *
                                (vn_temp_qty_factor);
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
    vc_error_msg := 'Befor Insert';
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
       unrealized_pnl_in_base_cur,
       product_base_qty_factor,
       product_base_qty_unit_id,
       product_base_qty_unit)
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
       vn_unreal_pnl_in_base_ccy,
       cur_diff_rows.product_base_qty_factor,
       cur_diff_rows.product_base_qty_unit_id,
       cur_diff_rows.product_base_qty_unit);
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
  vc_base_cur_id     varchar2(15);
  vn_exch_rate       number;

begin
  vc_error_msg := 'Start of Allocation Report';
  select akc.base_cur_id
    into vc_base_cur_id
    from ak_corporate akc
   where akc.corporate_id = pc_corporate_id;
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
      vd_prev_eom_date := to_date('01-Jan-2000', 'dd-Mon-yyyy');
  end;
  vc_error_msg := 'Start of Physicals';
  --
  -- For Physicals
  -- Concentrates Active Records
  --
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
     base_cur_name,
     pcdi_id,
     is_active)
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
           1 fx_to_base,
           pfd.user_price price_in_base,
           (case
             when pcm.purchase_sales = 'P' then
              1
             else
              (-1)
           end) * pfd.qty_fixed * pfd.user_price *
           ucm.multiplication_factor * ucm_price.multiplication_factor amount,
           akc.base_cur_id,
           akc.base_currency_name,
           pcdi.pcdi_id,
           pfd.is_active
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
           qum_quantity_unit_master qum_qty,
           ucm_unit_conversion_master ucm_price
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id
       and pofh.pofh_id = pfd.pofh_id
       and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
       and pfd.pfd_id = pfam.pfd_id
       and pfam.internal_action_ref_no = axs.internal_action_ref_no(+)
       and poch.element_id = aml.attribute_id
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
       and pfam.is_active = 'Y'
       and pfd.is_active = 'Y'
       and pcm.contract_type = 'CONCENTRATES'
       and pfd.hedge_correction_date > vd_prev_eom_date
       and pfd.hedge_correction_date <= pd_trade_date
       and pcm.is_pass_through = 'N'
       and axs.process = 'EOM'
       and pocd.price_type <> 'Fixed'
       and ucm_price.from_qty_unit_id = pdm_aml.base_quantity_unit
       and ucm_price.to_qty_unit_id = ppu.weight_unit_id;
  commit;
  --
  -- Concentrates Cancelled records
  -- 
  vc_error_msg := 'Start of Concentrates Cancelled records';
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
     base_cur_name,
     pcdi_id,
     is_active)
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
           1 fx_to_base,
           pfd.user_price price_in_base,
           (case
             when pcm.purchase_sales = 'P' then
              1
             else
              (-1)
           end) * pfd.qty_fixed * pfd.user_price *
           ucm.multiplication_factor * ucm_price.multiplication_factor amount,
           akc.base_cur_id,
           akc.base_currency_name,
           pcdi.pcdi_id,
           pfd.is_active
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
           qum_quantity_unit_master qum_qty,
           ucm_unit_conversion_master ucm_price
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id
       and pofh.pofh_id = pfd.pofh_id
       and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
       and pfd.pfd_id = pfam.pfd_id
       and pfam.internal_action_ref_no = axs.internal_action_ref_no(+)
       and poch.element_id = aml.attribute_id
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
       and pfam.is_active = 'Y'
       and pfd.is_active = 'N'
       and pfd.cancel_action_ref_no is not null
       and nvl(pfd.user_price, 0) <> 0
       and pcm.contract_type = 'CONCENTRATES'
       and pfd.hedge_correction_date > vd_prev_eom_date
       and pfd.hedge_correction_date <= pd_trade_date
       and pcm.is_pass_through = 'N'
       and axs.process = 'EOM'
       and pocd.price_type <> 'Fixed'
       and ucm_price.from_qty_unit_id = pdm_aml.base_quantity_unit
       and ucm_price.to_qty_unit_id = ppu.weight_unit_id;
  --
  -- Base Metal Active records
  --    
  vc_error_msg := 'Start of Base Metal Active records';

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
     base_cur_name,
     pcdi_id,
     is_active)
  
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
           1 fx_to_base,
           pfd.user_price price_in_base,
           (case
             when pcm.purchase_sales = 'P' then
              1
             else
              (-1)
           end) * pfd.qty_fixed * pfd.user_price *
           ucm.multiplication_factor * ucm_price.multiplication_factor amount,
           akc.base_cur_id,
           akc.base_currency_name,
           pcdi.pcdi_id,
           pfd.is_active
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
           v_ppu_pum ppu,
           cm_currency_master cm,
           qum_quantity_unit_master qum,
           ak_corporate akc,
           ucm_unit_conversion_master ucm,
           qum_quantity_unit_master qum_qty,
           ucm_unit_conversion_master ucm_price
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
       and pfam.is_active = 'Y'
       and pcpd.is_active = 'Y'
       and pfd.is_active = 'Y'
       and pcm.contract_type = 'BASEMETAL'
       and pfd.hedge_correction_date > vd_prev_eom_date
       and pfd.hedge_correction_date <= pd_trade_date
       and axs.process = 'EOM'
       and pocd.price_type <> 'Fixed'
       and ucm_price.from_qty_unit_id = pdm.base_quantity_unit
       and ucm_price.to_qty_unit_id = ppu.weight_unit_id;
  commit;
  --
  -- Base Metal Cancelled records
  --   
  vc_error_msg := 'Start of Base Metal Cancelled records';

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
     base_cur_name,
     pcdi_id,
     is_active)
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
           1 fx_to_base,
           pfd.user_price price_in_base,
           (case
             when pcm.purchase_sales = 'P' then
              1
             else
              (-1)
           end) * pfd.qty_fixed * pfd.user_price *
           ucm.multiplication_factor * ucm_price.multiplication_factor amount,
           akc.base_cur_id,
           akc.base_currency_name,
           pcdi.pcdi_id,
           pfd.is_active
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
           v_ppu_pum ppu,
           cm_currency_master cm,
           qum_quantity_unit_master qum,
           ak_corporate akc,
           ucm_unit_conversion_master ucm,
           qum_quantity_unit_master qum_qty,
           ucm_unit_conversion_master ucm_price
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
       and pfam.is_active = 'Y'
       and pcpd.is_active = 'Y'
       and pfd.is_active = 'N'
       and pfd.cancel_action_ref_no is not null
       and nvl(pfd.user_price, 0) <> 0
       and pcm.contract_type = 'BASEMETAL'
       and pfd.hedge_correction_date > vd_prev_eom_date
       and pfd.hedge_correction_date <= pd_trade_date
       and axs.process = 'EOM'
       and pocd.price_type <> 'Fixed'
       and ucm_price.from_qty_unit_id = pdm.base_quantity_unit
       and ucm_price.to_qty_unit_id = ppu.weight_unit_id;
  vc_error_msg := 'Start of Derivatives';
  --
  -- derivatives
  --
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
           to_char(dpd.prompt_date, 'dd-Mon-RRRR'),
           dpd.trade_cur_to_base_exch_rate,
           dpd.trade_price * dpd.trade_cur_to_base_exch_rate,
           dpd.trade_date,
           (case
             when dpd.trade_type = 'Buy' then
              dpd.total_quantity * ucm_price.multiplication_factor *
              dpd.trade_price * dpd.trade_cur_to_base_exch_rate
             else
              (-1) * dpd.total_quantity * ucm_price.multiplication_factor *
              dpd.trade_price * dpd.trade_cur_to_base_exch_rate
           end) trade_value_in_base,
           dpd.base_cur_id,
           dpd.base_cur_code
      from dpd_derivative_pnl_daily   dpd,
           ucm_unit_conversion_master ucm,
           ucm_unit_conversion_master ucm_price
     where dpd.pnl_type = 'New Trade'
       and ucm.from_qty_unit_id = dpd.trade_price_weight_unit_id
       and ucm.to_qty_unit_id = dpd.base_qty_unit_id
       and ucm_price.from_qty_unit_id = dpd.trade_price_weight_unit_id
       and ucm_price.to_qty_unit_id = dpd.quantity_unit_id
       and dpd.process_id = pc_process_id;
  commit;
  --- 
  -- Free Metal
  --
  vc_error_msg := 'Free Metal';
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
     internal_contract_ref_no,
     delivery_item_no,
     gmr_ref_no,
     internal_gmr_ref_no,
     pf_ref_no,
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
     base_cur_name,
     pcdi_id,
     is_active)
    select pc_process_id process_id,
           pd_trade_date eod_trade_date,
           fmuh.corporate_id,
           akc.corporate_name,
           'Physicals' section_name,
           phd.profileid cp_id,
           phd.companyname cp_name,
           pdm.product_id,
           pdm.product_desc,
           null instrument_id,
           null instrument_name,
           null internal_contract_ref_no,
           null delivery_item_no,
           null gmr_ref_no,
           null internal_gmr_ref_no,
           axs.action_ref_no pf_ref_no,
           null external_ref_no,
           null derivative_ref_no,
           fmpfd.qty_fixed * ucm.multiplication_factor purchase_qty,
           0 sales_qty,
           fmed.qty_unit_id,
           qum.qty_unit,
           fmpfd.user_price price,
           fmed.price_unit_id,
           cm.cur_id,
           cm.cur_code,
           qum.qty_unit_id,
           qum.qty_unit,
           ppu.weight,
           ppu.price_unit_name,
           null prompt_month_year,
           1 fx_rate_price_to_base,
           fmpfd.user_price price_in_base_ccy,
           axs.eff_date price_fixed_date,
           fmpfd.user_price * fmpfd.qty_fixed * ucm.multiplication_factor * ucm_price.multiplication_factor  amount,
           akc.base_cur_id,
           akc.base_currency_name,
           null as pcdi_id,
           fmpfd.is_active
      from fmuh_free_metal_utility_header fmuh,
           fmed_free_metal_elemt_details  fmed,
           fmpfh_price_fixation_header    fmpfh,
           fmpfd_price_fixation_details   fmpfd,
           fmpfam_price_action_mapping    fmpfam,
           ak_corporate                   akc,
           qum_quantity_unit_master       qum,
           phd_profileheaderdetails       phd,
           aml_attribute_master_list      aml,
           pdm_productmaster              pdm,
           axs_action_summary             axs,
           v_ppu_pum                      ppu,
           cm_currency_master             cm,
           qum_quantity_unit_master       qum_ppu,
           ucm_unit_conversion_master     ucm,
           ucm_unit_conversion_master     ucm_price
     where fmuh.fmuh_id = fmed.fmuh_id
       and fmed.fmed_id = fmpfh.fmed_id
       and fmed.element_id = fmpfh.element_id
       and fmpfh.fmpfh_id = fmpfd.fmpfh_id
       and fmpfd.fmpfd_id = fmpfam.fmpfd_id
       and fmuh.is_active = 'Y'
       and fmed.is_active = 'Y'
       and fmpfh.is_active = 'Y'
       and fmpfam.is_active = 'Y'
       and fmuh.corporate_id = akc.corporate_id
       and fmed.qty_unit_id = qum.qty_unit_id
       and phd.profileid = fmuh.smelter_id
       and fmed.element_id = aml.attribute_id
       and aml.underlying_product_id = pdm.product_id
       and fmpfam.internal_action_ref_no = axs.internal_action_ref_no
       and axs.corporate_id = pc_corporate_id
       and axs.eff_date > vd_prev_eom_date
       and axs.eff_date <= pd_trade_date
       and fmpfd.price_unit_id = ppu.product_price_unit_id
       and ppu.cur_id = cm.cur_id
       and ppu.weight_unit_id = qum_ppu.qty_unit_id
       and ucm.from_qty_unit_id = fmed.qty_unit_id
       and ucm.to_qty_unit_id = pdm.base_quantity_unit
       and ucm.is_active = 'Y'
       and aml.is_deleted = 'N'
       and pdm.is_deleted = 'N'
       and phd.is_deleted = 'N'
       and axs.process = 'EOM'
       and ucm_price.from_qty_unit_id = pdm.base_quantity_unit
       and ucm_price.to_qty_unit_id = ppu.weight_unit_id;
  commit;
  --
  -- FX Rate from Payable to Base, Price in Base and Fixation Value for Sections Exclude Derivatives
  --
  for cur_exch_rate in (select mbvad.price_unit_cur_id
                          from mbv_allocation_report mbvad
                         where mbvad.process_id = pc_process_id
                           and mbvad.price_unit_cur_id <> vc_base_cur_id
                           and mbvad.section_name <> 'Derivatives'
                         group by mbvad.price_unit_cur_id)
  loop
    select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                    cur_exch_rate.price_unit_cur_id,
                                                    vc_base_cur_id,
                                                    pd_trade_date,
                                                    1)
      into vn_exch_rate
      from dual;
    update mbv_allocation_report mbva
       set mbva.fx_rate_price_to_base = vn_exch_rate,
           mbva.price_in_base_ccy     = mbva.price_in_base_ccy *
                                        vn_exch_rate,
           mbva.amount                = mbva.amount * vn_exch_rate
     where mbva.process_id = pc_process_id
       and mbva.price_unit_cur_id = cur_exch_rate.price_unit_cur_id
       and mbva.section_name <> 'Derivatives';
  end loop;
  commit;
  --
  -- Logic for Contango Due To Quantity 
  -- Physical Purchase Value - Physical Sales Value (a)
  -- Derivative Sales Value - Derivative Purchase Value (b)
  -- Contango due to qty and price (c) = b - a
  --
  vc_error_msg := 'Start of Allocation Header Data Insertion';
  insert into mbv_allocation_report_header
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     product_id,
     product_name,
     opening_balance_qty,
     actual_hedged_qty,
     contango_due_to_qty_and_price)
    select process_id,
           eod_trade_date,
           corporate_id,
           corporate_name,
           product_id,
           product_desc,
           sum(opening_balance),
           sum(actual_hedged_qty),
           sum(contango_due_to_qty_and_price)
      from (select pc_process_id process_id,
                   pd_trade_date eod_trade_date,
                   mbv.corporate_id,
                   mbv.corporate_name,
                   mbv.product_id,
                   mbv.product_desc,
                   sum(case
                         when mbv.eod_trade_date < pd_trade_date then
                          mbv.purchase_qty
                         else
                          0
                       end) - sum(case
                                    when mbv.eod_trade_date < pd_trade_date then
                                     mbv.sales_qty
                                    else
                                     0
                                  end) opening_balance,
                   sum(case
                         when mbv.section_name = 'Derivatives' then
                          mbv.purchase_qty - mbv.sales_qty
                         else
                          0
                       end) actual_hedged_qty,
                   sum(case
                         when mbv.section_name = 'Derivatives' then
                          -1 * mbv.amount
                         when mbv.section_name = 'Physicals' then
                          -1 * mbv.amount -- Physical Amount is stored as Positive for Purchase and Negative for Sales
                         else
                          0
                       end) contango_due_to_qty_and_price
              from mbv_allocation_report mbv
             where mbv.eod_trade_date <= pd_trade_date
               and mbv.corporate_id = pc_corporate_id
             group by mbv.corporate_id,
                      mbv.corporate_name,
                      mbv.product_id,
                      mbv.product_desc
            union all
            select mbvd.process_id,
                   mbvd.eod_trade_date,
                   mbvd.corporate_id,
                   mbvd.corporate_name,
                   mbvd.product_id,
                   mbvd.product_desc,
                   0 opening_balance,
                   0 actual_hedged_qty,
                   0 contango_due_to_qty_and_price
              from mbv_allocation_report mbvd
             where mbvd.process_id = pc_process_id)
     group by process_id,
              eod_trade_date,
              corporate_id,
              corporate_name,
              product_id,
              product_desc;
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
procedure sp_fx_allocation_report(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process      varchar2,
                                  pc_process_id   varchar2) is
  vd_prev_eom_date   date;
  vn_exch_rate       number;
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
      vd_prev_eom_date := to_date('01-Jan-2000', 'dd-Mon-yyyy');
  end;
  ---1. Base metal Fixed Contracts
  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     internal_contract_ref_no,
     delivery_item_no,
     pcdi_id,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     purchase_sales)
    select pc_process_id,
           pd_trade_date,
           akc.corporate_id,
           akc.corporate_name,
           'Physicals' main_section,
           'Base Metal-Fixed Price' section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           pdm.product_id,
           pdm.product_desc product,
           pcm.trader_id trader_id,
           gab.firstname || ' ' || gab.lastname trader,
           pcm.contract_ref_no,
           pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
           pcdi.pcdi_id,
           (case
             when pcm.purchase_sales = 'P' then
              (-1) * diqs.total_qty
             else
              0
           end) purchase_qty,
           (case
             when pcm.purchase_sales = 'S' then
              (1) * diqs.total_qty
             else
              0
           end) sales_qty,
           qum.qty_unit qty_unit,
           qum.qty_unit_id,
           pcm.issue_date trade_date,
           pcbpd.price_value price,
           pum.price_unit_id,
           pum.price_unit_name price_unit,
           decode(pcm.purchase_sales, 'P', -1, 'S', 1) *
           (pcbpd.price_value / nvl(ppu.weight, 1)) *
           (pffxd.fixed_fx_rate *
            pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 qum.qty_unit_id,
                                                 pum.weight_unit_id,
                                                 diqs.total_qty)) hedging_amount,
           cm_pay.cur_id exposure_cur_id,
           cm_pay.cur_code exposure_currency,
           cm_base.cur_id,
           cm_base.cur_code base_currency,
           1,
           pcm.purchase_sales
      from pcdi_pc_delivery_item          pcdi,
           diqs_delivery_item_qty_status  diqs,
           pcm_physical_contract_main     pcm,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pofh_price_opt_fixation_header pofh,
           pcbpd_pc_base_price_detail     pcbpd,
           pffxd_phy_formula_fx_details   pffxd,
           ak_corporate                   akc,
           ak_corporate_user              akcu,
           gab_globaladdressbook          gab,
           pcpd_pc_product_definition     pcpd,
           cpc_corporate_profit_center    cpc,
           pdm_productmaster              pdm,
           cm_currency_master             cm_base,
           cm_currency_master             cm_pay,
           v_ppu_pum                      ppu,
           pum_price_unit_master          pum,
           qum_quantity_unit_master       qum,
           phd_profileheaderdetails       phd
     where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pcdi.pcdi_id = diqs.pcdi_id
       and diqs.is_active = 'Y'
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id(+)
       and pocd.pcbpd_id = pcbpd.pcbpd_id
       and pcbpd.pffxd_id = pffxd.pffxd_id
       and pffxd.is_active = 'Y'
       and pcm.corporate_id = akc.corporate_id
       and pcm.trader_id = akcu.user_id(+)
       and akcu.gabid = gab.gabid
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
       and pcpd.profit_center_id = cpc.profit_center_id
       and pcpd.product_id = pdm.product_id
       and akc.base_cur_id = cm_base.cur_id
       and pocd.pay_in_cur_id = cm_pay.cur_id
       and pcbpd.price_unit_id = ppu.product_price_unit_id
       and ppu.price_unit_id = pum.price_unit_id
       and diqs.item_qty_unit_id = qum.qty_unit_id
       and pcm.cp_id = phd.profileid
       and pcbpd.price_basis = 'Fixed'
       and pcdi.is_active = 'Y'
       and pcm.is_active = 'Y'
       and pcm.contract_type = 'BASEMETAL'
       and pcm.approval_status = 'Approved'
       and pcm.contract_status <> 'Cancelled'
       and pcpd.input_output = 'Input'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active(+) = 'Y'
       and pcbpd.is_active = 'Y'
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and diqs.process_id = pc_process_id
       and pcbpd.process_id = pc_process_id
       and pffxd.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and pcm.corporate_id = pc_corporate_id
       and pcm.issue_date > vd_prev_eom_date
       and pcm.issue_date <= pd_trade_date;
  commit;
  ---2. concentrates Fixed contracts
  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     internal_contract_ref_no,
     delivery_item_no,
     pcdi_id,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     purchase_sales)
    select pc_process_id,
           pd_trade_date,
           akc.corporate_id,
           akc.corporate_name,
           'Physicals' main_section,
           'Concentrates-Fixed Price' section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           pdm_under.product_id,
           pdm_under.product_desc product,
           pcm.trader_id trader_id,
           gab.firstname || ' ' || gab.lastname trader,
           pcm.contract_ref_no,
           pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
           pcdi.pcdi_id,
           (case
             when pcm.purchase_sales = 'P' then
              (-1) * dipq.payable_qty
             else
              0
           end) purchase_qty,
           (case
             when pcm.purchase_sales = 'S' then
              (1) * dipq.payable_qty
             else
              0
           end) sales_qty,
           qum.qty_unit qty_unit,
           qum.qty_unit_id,
           pcm.issue_date trade_date,
           pcbpd.price_value price,
           pum.price_unit_id,
           pum.price_unit_name price_unit,
           decode(pcm.purchase_sales, 'P', -1, 'S', 1) *
           (pcbpd.price_value / nvl(ppu.weight, 1)) *
           (pffxd.fixed_fx_rate *
            pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                     pdm.product_id),
                                                 qum.qty_unit_id,
                                                 pum.weight_unit_id,
                                                 dipq.payable_qty)) hedging_amount,
           cm_pay.cur_id exposure_cur_id,
           cm_pay.cur_code exposure_currency,
           cm_base.cur_id base_cur_id,
           cm_base.cur_code base_currency,
           1,
           pcm.purchase_sales
      from pcdi_pc_delivery_item          pcdi,
           dipq_delivery_item_payable_qty dipq,
           aml_attribute_master_list      aml,
           pdm_productmaster              pdm_under,
           qum_quantity_unit_master       qum_under,
           pcm_physical_contract_main     pcm,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pofh_price_opt_fixation_header pofh,
           pcbpd_pc_base_price_detail     pcbpd,
           pffxd_phy_formula_fx_details   pffxd,
           ak_corporate                   akc,
           ak_corporate_user              akcu,
           gab_globaladdressbook          gab,
           pcpd_pc_product_definition     pcpd,
           cpc_corporate_profit_center    cpc,
           pdm_productmaster              pdm,
           cm_currency_master             cm_base,
           cm_currency_master             cm_pay,
           v_ppu_pum                      ppu,
           pum_price_unit_master          pum,
           qum_quantity_unit_master       qum,
           phd_profileheaderdetails       phd
     where pcdi.pcdi_id = dipq.pcdi_id
       and dipq.element_id = aml.attribute_id
       and aml.underlying_product_id = pdm_under.product_id(+)
       and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
       and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and poch.element_id = aml.attribute_id
       and pocd.pocd_id = pofh.pocd_id(+)
       and pocd.pcbpd_id = pcbpd.pcbpd_id
       and pcbpd.pffxd_id = pffxd.pffxd_id
       and pffxd.is_active = 'Y'
       and dipq.is_active = 'Y'
       and pcm.corporate_id = akc.corporate_id
       and pcm.trader_id = akcu.user_id(+)
       and akcu.gabid = gab.gabid
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
       and pcpd.profit_center_id = cpc.profit_center_id
       and pcpd.product_id = pdm.product_id
       and akc.base_cur_id = cm_base.cur_id
       and pocd.pay_in_cur_id = cm_pay.cur_id
       and pcbpd.price_unit_id = ppu.product_price_unit_id
       and ppu.price_unit_id = pum.price_unit_id
       and dipq.qty_unit_id = qum.qty_unit_id
       and pcm.cp_id = phd.profileid
       and pcbpd.price_basis = 'Fixed'
       and pcdi.is_active = 'Y'
       and pcm.is_active = 'Y'
       and pcm.contract_type = 'CONCENTRATES'
       and pcpd.input_output = 'Input'
       and (case when pcm.is_tolling_contract = 'Y' then
            nvl(pcm.approval_status, 'Approved') else pcm.approval_status end) =
           'Approved'
       and pcm.contract_status <> 'Cancelled'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active(+) = 'Y'
       and pcbpd.is_active = 'Y'
       and dipq.payable_qty <> 0
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and dipq.process_id = pc_process_id
       and pcbpd.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and pffxd.process_id = pc_process_id
       and pcm.corporate_id = pc_corporate_id
       and pcm.issue_date > vd_prev_eom_date
       and pcm.issue_date <= pd_trade_date;
  commit;
  --- 3.Base metal Price Fixations

  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     internal_contract_ref_no,
     delivery_item_no,
     pcdi_id,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     purchase_sales)
    select pc_process_id,
           pd_trade_date,
           akc.corporate_id,
           akc.corporate_name,
           'Physicals' main_section,
           'Base Metal-Price Fixation' section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           pdm.product_id,
           pdm.product_desc product,
           pcm.trader_id trader_id,
           gab.firstname || ' ' || gab.lastname trader,
           
           pcm.contract_ref_no,
           pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
           pcdi.pcdi_id,
           (case
             when pcm.purchase_sales = 'P' then
              (-1) * pfd.qty_fixed
             else
              0
           end) purchase_qty,
           (case
             when pcm.purchase_sales = 'S' then
              (1) * pfd.qty_fixed
             else
              0
           end) sales_qty,
           qum.qty_unit,
           qum.qty_unit_id,
           pfd.fx_correction_date trade_date,
           (nvl(pfd.user_price, 0) + nvl(pfd.adjustment_price, 0)) price,
           pum.price_unit_id,
           pum.price_unit_name price_unit,
           decode(pcm.purchase_sales, 'P', -1, 'S', 1) *
           nvl(pfd.hedge_amount, 0) hedging_amount,
           cm_pay.cur_id exposure_cur_id,
           cm_pay.cur_code exposure_currency,
           cm_base.cur_id base_cur_id,
           cm_base.cur_code base_currency,
           1,
           pcm.purchase_sales
    
      from pcdi_pc_delivery_item          pcdi,
           pcm_physical_contract_main     pcm,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pofh_price_opt_fixation_header pofh,
           pfd_price_fixation_details     pfd,
           ak_corporate                   akc,
           ak_corporate_user              akcu,
           gab_globaladdressbook          gab,
           pcpd_pc_product_definition     pcpd,
          -- pym_payment_terms_master       pym,
           cpc_corporate_profit_center    cpc,
           pdm_productmaster              pdm,
           cm_currency_master             cm_base,
           cm_currency_master             cm_pay,
           v_ppu_pum                      ppu,
           pum_price_unit_master          pum,
           qum_quantity_unit_master       qum,
           phd_profileheaderdetails       phd
     where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id(+)
       and pofh.pofh_id = pfd.pofh_id
       and pfd.is_active = 'Y'
       and pcm.corporate_id = akc.corporate_id
       and pcm.trader_id = akcu.user_id(+)
       and akcu.gabid = gab.gabid(+)
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
       and pcpd.profit_center_id = cpc.profit_center_id
       and pcpd.product_id = pdm.product_id
       and akc.base_cur_id = cm_base.cur_id
       and pocd.pay_in_cur_id = cm_pay.cur_id
       and pfd.price_unit_id = ppu.product_price_unit_id(+)
       and ppu.price_unit_id = pum.price_unit_id(+)
       and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
       and pcm.cp_id = phd.profileid
       and pcm.contract_type = 'BASEMETAL'
       and pcm.approval_status = 'Approved'
       and pcpd.input_output = 'Input'
       and pcdi.is_active = 'Y'
       and pcm.is_active = 'Y'
       and pcm.contract_status <> 'Cancelled'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active(+) = 'Y'
       and nvl(pfd.is_hedge_correction, 'N') = 'N'
       and nvl(pfd.is_cancel, 'N') = 'N'
       and pfd.hedge_amount is not null
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and pcm.corporate_id = pc_corporate_id
       and pfd.fx_correction_date > vd_prev_eom_date
       and pfd.fx_correction_date <= pd_trade_date;
  commit;
  ---  4.concentrates Price Fixation    
  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     internal_contract_ref_no,
     delivery_item_no,
     pcdi_id,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     purchase_sales)
    select pc_process_id,
           pd_trade_date,
           akc.corporate_id,
           akc.corporate_name,
           'Physicals' section,
           'Concentrate-Price Fixation' main_section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           pdm_under.product_id,
           pdm_under.product_desc product,
           pcm.trader_id trader_id,
           gab.firstname || ' ' || gab.lastname trader,
           pcm.contract_ref_no,
           pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
           pcdi.pcdi_id,
           (case
             when pcm.purchase_sales = 'P' then
              (-1) * pfd.qty_fixed
             else
              0
           end) purchase_qty,
           (case
             when pcm.purchase_sales = 'S' then
              (1) * pfd.qty_fixed
             else
              0
           end) sales_qty,
           qum.qty_unit,
           qum.qty_unit_id,
           pfd.fx_correction_date trade_date,
           (nvl(pfd.user_price, 0) + nvl(pfd.adjustment_price, 0)) price,
           pum.price_unit_id,
           pum.price_unit_name price_unit,
           decode(pcm.purchase_sales, 'P', -1, 'S', 1) *
           nvl(pfd.hedge_amount, 0) hedging_amount,
           cm_pay.cur_id exposure_cur_id,
           cm_pay.cur_code exposure_currency,
           cm_base.cur_id base_cur_id,
           cm_base.cur_code base_currency,
           1,
           pcm.purchase_sales
    
      from pcdi_pc_delivery_item          pcdi,
           pcm_physical_contract_main     pcm,
           poch_price_opt_call_off_header poch,
           aml_attribute_master_list      aml,
           pdm_productmaster              pdm_under,
           qum_quantity_unit_master       qum_under,
           pocd_price_option_calloff_dtls pocd,
           pofh_price_opt_fixation_header pofh,
           pfd_price_fixation_details     pfd,
           ak_corporate                   akc,
           ak_corporate_user              akcu,
           gab_globaladdressbook          gab,
           pcpd_pc_product_definition     pcpd,
           cpc_corporate_profit_center    cpc,
           pdm_productmaster              pdm,
           cm_currency_master             cm_base,
           cm_currency_master             cm_pay,
           v_ppu_pum                      ppu,
           pum_price_unit_master          pum,
           qum_quantity_unit_master       qum
     where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.element_id = aml.attribute_id
       and aml.underlying_product_id = pdm_under.product_id(+)
       and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id(+)
       and pcdi.is_active = 'Y'
       and pcm.is_active = 'Y'
       and pcm.contract_status <> 'Cancelled'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active(+) = 'Y'
       and pofh.pofh_id = pfd.pofh_id
       and pfd.is_active = 'Y'
       and pcm.corporate_id = akc.corporate_id
       and pcm.trader_id = akcu.user_id(+)
       and akcu.gabid = gab.gabid
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
       and pcpd.profit_center_id = cpc.profit_center_id
       and pcpd.product_id = pdm.product_id
       and akc.base_cur_id = cm_base.cur_id
       and pocd.pay_in_cur_id = cm_pay.cur_id
       and pfd.price_unit_id = ppu.product_price_unit_id(+)
       and ppu.price_unit_id = pum.price_unit_id(+)
       and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
       and pcm.contract_type = 'CONCENTRATES'
       and pcpd.input_output = 'Input'
       and (case when pcm.is_tolling_contract = 'Y' then
            nvl(pcm.approval_status, 'Approved') else pcm.approval_status end) =
           'Approved'
       and nvl(pfd.is_hedge_correction, 'N') = 'N'
       and nvl(pfd.is_cancel, 'N') = 'N'
       and pfd.hedge_amount is not null
       and pcdi.process_id = pc_process_id
       and pcm.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and pcm.corporate_id = pc_corporate_id
       and pfd.fx_correction_date > vd_prev_eom_date
       and pfd.fx_correction_date <= pd_trade_date;
  commit;
  -- 5. Quality Premium
  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     internal_contract_ref_no,
     delivery_item_no,
     pcdi_id,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     purchase_sales)
    select pc_process_id,
           pd_trade_date,
           ak.corporate_id,
           ak.corporate_name,
           'Physicals' main_section,
           'Quality  Premium' section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           pdm.product_id,
           pdm.product_desc product,
           pcm.trader_id trader_id,
           gab.firstname || '  ' || gab.lastname trader,
           pcm.contract_ref_no,
           pcm.contract_ref_no || '-' || pcdi.delivery_item_no delivery_item_ref_no,
           pcdi.pcdi_id,
           (case
             when pcm.purchase_sales = 'P' then
              (-1) * diqs.total_qty
             else
              0
           end) purchase_qty,
           (case
             when pcm.purchase_sales = 'S' then
              (1) * diqs.total_qty
             else
              0
           end) sales_qty,
           qum.qty_unit qty_unit,
           qum.qty_unit_id,
           pcm.issue_date trade_date,
           pcqpd.premium_disc_value price,
           pcqpd.premium_disc_unit_id price_unit_id,
           pum.price_unit_name price_unit,
           decode(pcm.purchase_sales, 'P', -1, 'S', 1) *
           (pcqpd.premium_disc_value / nvl(ppu.weight, 1)) *
           (pffxd.fixed_fx_rate *
            pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 qum.qty_unit_id,
                                                 pum.weight_unit_id,
                                                 diqs.total_qty)) hedging_amount,
           cm_pay.cur_id exposure_cur_id,
           cm_pay.cur_code exposure_currency,
           cm_base.cur_id,
           cm_base.cur_code base_currency,
           1,
           pcm.purchase_sales
    
      from ak_corporate                   ak,
           pcm_physical_contract_main     pcm,
           pcdi_pc_delivery_item          pcdi,
           diqs_delivery_item_qty_status  diqs,
           cm_currency_master             cm_base,
           pcpd_pc_product_definition     pcpd,
           cpc_corporate_profit_center    cpc,
           pdm_productmaster              pdm,
           qum_quantity_unit_master       qum,
           pcqpd_pc_qual_premium_discount pcqpd,
           pffxd_phy_formula_fx_details   pffxd,
           v_ppu_pum                      ppu,
           pum_price_unit_master          pum,
           cm_currency_master             cm_pay,
           ak_corporate_user              akc,
           gab_globaladdressbook          gab
     where ak.corporate_id = pcm.corporate_id
       and ak.base_cur_id = cm_base.cur_id
       and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcdi.pcdi_id = diqs.pcdi_id
       and diqs.is_active = 'Y'
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
       and pcpd.profit_center_id = cpc.profit_center_id
       and pdm.product_id = pcpd.product_id
       and qum.qty_unit_id = diqs.item_qty_unit_id
       and pcqpd.internal_contract_ref_no = pcm.internal_contract_ref_no
       and ppu.product_price_unit_id = pcqpd.premium_disc_unit_id
       and pcqpd.pffxd_id = pffxd.pffxd_id
       and pffxd.is_active = 'Y'
       and pum.price_unit_id = ppu.price_unit_id
       and cm_pay.cur_id = pcm.invoice_currency_id
       and pcm.trader_id = akc.user_id
       and akc.gabid = gab.gabid
       and pcm.is_active = 'Y'
       and (case when pcm.is_tolling_contract = 'Y' then
            nvl(pcm.approval_status, 'Approved') else pcm.approval_status end) =
           'Approved'
       and pcm.contract_status <> 'Cancelled'
       and pcpd.input_output = 'Input'
       and pcdi.is_active = 'Y'
       and pcpd.is_active = 'Y'
       and pum.is_active = 'Y'
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and diqs.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and pcqpd.process_id = pc_process_id
       and pffxd.process_id = pc_process_id
       and pcm.corporate_id = pc_corporate_id
       and pcm.issue_date > vd_prev_eom_date
       and pcm.issue_date <= pd_trade_date;
  commit;

  --  6. Location Premium
  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     internal_contract_ref_no,
     delivery_item_no,
     pcdi_id,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     purchase_sales)
    select pc_process_id,
           pd_trade_date,
           ak.corporate_id,
           ak.corporate_name,
           'Physicals' main_section,
           'location  Premium' section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           pdm.product_id,
           pdm.product_desc product,
           pcm.trader_id trader_id,
           gab.firstname || '  ' || gab.lastname trader,
           pcm.contract_ref_no,
           pcm.contract_ref_no || '-' || pcdi.delivery_item_no delivery_item_ref_no,
           pcdi.pcdi_id,
           (case
             when pcm.purchase_sales = 'P' then
              (-1) * diqs.total_qty
             else
              0
           end) purchase_qty,
           (case
             when pcm.purchase_sales = 'S' then
              (1) * diqs.total_qty
             else
              0
           end) sales_qty,
           qum.qty_unit contract_qty_unit,
           qum.qty_unit_id,
           pcm.issue_date trade_date,
           pcdb.premium price,
           pcdb.premium_unit_id price_unit_id,
           pum.price_unit_name price_unit,
           decode(pcm.purchase_sales, 'P', -1, 'S', 1) *
           (pcdb.premium / nvl(ppu.weight, 1)) *
           (pffxd.fixed_fx_rate *
            pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 qum.qty_unit_id,
                                                 pum.weight_unit_id,
                                                 diqs.total_qty)) hedging_amount,
           cm_pay.cur_id exposure_cur_id,
           cm_pay.cur_code exposure_currency,
           cm_base.cur_id,
           cm_base.cur_code base_currency,
           1,
           pcm.purchase_sales
      from ak_corporate                  ak,
           pcm_physical_contract_main    pcm,
           pcdi_pc_delivery_item         pcdi,
           diqs_delivery_item_qty_status diqs,
           cm_currency_master            cm_base,
           pcpd_pc_product_definition    pcpd,
           cpc_corporate_profit_center   cpc,
           pdm_productmaster             pdm,
           qum_quantity_unit_master      qum,
           pcdb_pc_delivery_basis        pcdb,
           pffxd_phy_formula_fx_details  pffxd,
           v_ppu_pum                     ppu,
           pum_price_unit_master         pum,
           cm_currency_master            cm_expo,
           ak_corporate_user             akc,
           gab_globaladdressbook         gab,
           cm_currency_master            cm_pay
    
     where ak.corporate_id = pcm.corporate_id
       and ak.base_cur_id = cm_base.cur_id
       and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcdi.pcdi_id = diqs.pcdi_id
       and diqs.is_active = 'Y'
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
       and pcpd.profit_center_id = cpc.profit_center_id
       and pdm.product_id = pcpd.product_id
       and qum.qty_unit_id = diqs.item_qty_unit_id
       and pcdb.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pum.price_unit_id = ppu.price_unit_id
       and pum.cur_id = cm_expo.cur_id
       and ppu.product_price_unit_id = pcdb.premium_unit_id
       and pcdb.pffxd_id = pffxd.pffxd_id(+)
       and pffxd.is_active(+) = 'Y'
       and cm_pay.cur_id = pcm.invoice_currency_id
       and pcm.trader_id = akc.user_id
       and akc.gabid = gab.gabid
       and pcm.is_active = 'Y'
       and (case when pcm.is_tolling_contract = 'Y' then
            nvl(pcm.approval_status, 'Approved') else pcm.approval_status end) =
           'Approved'
       and pcm.contract_status <> 'Cancelled'
       and pcpd.input_output = 'Input'
       and pcdi.is_active = 'Y'
       and pcpd.is_active = 'Y'
       and pum.is_active = 'Y'
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and diqs.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and pcdb.process_id = pc_process_id
       and pffxd.process_id = pc_process_id
       and pcm.corporate_id = pcm.corporate_id
       and pcm.issue_date > vd_prev_eom_date
       and pcm.issue_date <= pd_trade_date;
  commit;

  --  7. Accurals
  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     internal_contract_ref_no,
     delivery_item_no,
     pcdi_id,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     purchase_sales)
    select pc_process_id,
           pd_trade_date,
           ak.corporate_id,
           ak.corporate_name,
           'Physicals' main_section,
           'Accruals' section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           pdm.product_id,
           pdm.product_desc product,
           pcm.trader_id trader_id,
           gab.firstname || ' ' || gab.lastname trader,
           pcm.contract_ref_no,
           pcm.contract_ref_no || '-' || pcdi.delivery_item_no delivery_item_ref_no,
           pcdi.pcdi_id,
           (case
             when pcm.purchase_sales = 'P' then
              (-1) * cigc.qty
             else
              0
           end) purchase_qty,
           (case
             when pcm.purchase_sales = 'S' then
              (1) * cigc.qty
             else
              0
           end) sales_qty,
           qum.qty_unit qty_unit,
           qum.qty_unit_id,
           cs.effective_date trade_date,
           cs.cost_value price,
           (case
             when cs.rate_type = 'Rate' then
              cs.rate_price_unit_id
             when cs.rate_type = 'Absolute' then
              cs.transaction_amt_cur_id
           end) price_unit_id,
           (case
             when cs.rate_type = 'Rate' then
              pum.price_unit_name
             when cs.rate_type = 'Absolute' then
              cm_pay.cur_code
           end) price_unit,
           decode(cs.income_expense, 'Expense', -1, 'Income', 1) *
           (cs.cost_value * decode(cs.rate_type, 'Rate', 1, cigc.qty) /
            nvl(ppu.weight, 1)) * cs.fx_to_base *
           decode(cs.rate_type,
                  'Rate',
                  pkg_general.f_get_converted_quantity(pdm.product_id,
                                                       qum.qty_unit_id,
                                                       decode(cs.rate_type,
                                                              'Rate',
                                                              pum.weight_unit_id,
                                                              qum.qty_unit_id),
                                                       cigc.qty),
                  1) hedging_amount,
           cm_pay.cur_id exposure_cur_id,
           cm_pay.cur_code exposure_currency,
           cm_base.cur_id,
           cm_base.cur_code base_currency,
           1,
           pcm.purchase_sales
    
      from ak_corporate                ak,
           pcm_physical_contract_main  pcm,
           pcdi_pc_delivery_item       pcdi,
           cm_currency_master          cm_base,
           cm_currency_master          cm_pay,
           pcpd_pc_product_definition  pcpd,
           cpc_corporate_profit_center cpc,
           pdm_productmaster           pdm,
           qum_quantity_unit_master    qum,
           v_ppu_pum                   ppu,
           pum_price_unit_master       pum,
           gmr_goods_movement_record   gmr,
           cigc_contract_item_gmr_cost cigc,
           cs_cost_store               cs,
           scm_service_charge_master   scm,
           ak_corporate_user           akc,
           gab_globaladdressbook       gab
     where ak.corporate_id = pcm.corporate_id
       and ak.base_cur_id = cm_base.cur_id
       and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
       and pcpd.profit_center_id = cpc.profit_center_id
       and pdm.product_id = pcpd.product_id
       and qum.qty_unit_id = cigc.qty_unit_id
       and cs.rate_price_unit_id = ppu.product_price_unit_id(+)
       and cs.cost_component_id = scm.cost_id
       and ppu.price_unit_id = pum.price_unit_id(+)
       and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
       and gmr.internal_gmr_ref_no = cigc.internal_gmr_ref_no
       and cigc.cog_ref_no = cs.cog_ref_no
       and cm_pay.cur_id = cs.transaction_amt_cur_id
       and scm.cost_type = 'SECONDARY_COST'
       and pcpd.input_output = 'Input'
       and pcm.trader_id = akc.user_id
       and akc.gabid = gab.gabid
       and pcm.is_active = 'Y'
       and gmr.is_deleted = 'N'
       and pcm.contract_status <> 'Cancelled'
       and (case when pcm.is_tolling_contract = 'Y' then
            nvl(pcm.approval_status, 'Approved') else pcm.approval_status end) =
           'Approved'
       and pcdi.is_active = 'Y'
       and pcpd.is_active = 'Y'
       and pum.is_active(+) = 'Y'
       and cigc.is_deleted = 'N'
       and cs.is_deleted = 'N'
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and gmr.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and cigc.process_id = pc_process_id
       and cs.process_id = pc_process_id
       and pcm.corporate_id = pc_corporate_id
       and cs.effective_date > vd_prev_eom_date
       and cs.effective_date <= pd_trade_date;
  commit;
  --8  cancel fixations

  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     internal_contract_ref_no,
     delivery_item_no,
     pcdi_id,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     purchase_sales)
    select pc_process_id,
           pd_trade_date,
           akc.corporate_id,
           akc.corporate_name,
           'Physicals' main_section,
           'CANCELLED FIXATION' section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           aml.underlying_product_id product_id,
           pdm.product_desc product,
           pcm.trader_id trader_id,
           gab.firstname || ' ' || gab.lastname trader,
           pcm.contract_ref_no,
           pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
           pcdi.pcdi_id,
           (case
             when pcm.purchase_sales = 'P' then
              (-1) * pfd.qty_fixed
             else
              0
           end) purchase_qty,
           (case
             when pcm.purchase_sales = 'S' then
              (1) * pfd.qty_fixed
             else
              0
           end) sales_qty,
           qum.qty_unit,
           qum.qty_unit_id,
           pfd.fx_correction_date trade_date,
           (nvl(pfd.user_price, 0) + nvl(pfd.adjustment_price, 0)) price,
           pum.price_unit_id,
           pum.price_unit_name price_unit,
           decode(pcm.purchase_sales, 'P', -1, 'S', 1) *
           nvl(pfd.hedge_amount, 0) hedging_amount,
           cm_pay.cur_id exposure_cur_id,
           cm_pay.cur_code exposure_currency,
           cm_base.cur_id,
           cm_base.cur_code base_currency,
           1,
           pcm.purchase_sales
    
      from pcdi_pc_delivery_item          pcdi,
           pcm_physical_contract_main     pcm,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pofh_price_opt_fixation_header pofh,
           pfd_price_fixation_details     pfd,
           ak_corporate                   akc,
           ak_corporate_user              akcu,
           gab_globaladdressbook          gab,
           pcpd_pc_product_definition     pcpd,
           cpc_corporate_profit_center    cpc,
           pdm_productmaster              pdm,
           cm_currency_master             cm_base,
           cm_currency_master             cm_pay,
           v_ppu_pum                      ppu,
           pum_price_unit_master          pum,
           qum_quantity_unit_master       qum,
           aml_attribute_master_list      aml
     where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id(+)
       and pofh.pofh_id = pfd.pofh_id
       and pcm.corporate_id = akc.corporate_id
       and pcm.trader_id = akcu.user_id(+)
       and akcu.gabid = gab.gabid
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
       and pcpd.input_output = 'Input'
       and pcpd.profit_center_id = cpc.profit_center_id
       and poch.element_id = aml.attribute_id
       and aml.underlying_product_id = pdm.product_id
       and akc.base_cur_id = cm_base.cur_id
       and pocd.pay_in_cur_id = cm_pay.cur_id
       and pfd.price_unit_id = ppu.product_price_unit_id(+)
       and ppu.price_unit_id = pum.price_unit_id(+)
       and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
       and pcdi.is_active = 'Y'
       and pcm.is_active = 'Y'
       and pcm.contract_status <> 'Cancelled'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active(+) = 'Y'
       and pfd.is_cancel = 'Y'
       and nvl(pfd.is_exposure, 'Y') = 'Y'
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and pcm.corporate_id = pc_corporate_id
       and pfd.fx_correction_date > vd_prev_eom_date
       and pfd.fx_correction_date <= pd_trade_date;
  commit;
  --- 9) hedge corrections
  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     internal_contract_ref_no,
     delivery_item_no,
     pcdi_id,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     purchase_sales)
  
    select pc_process_id,
           pd_trade_date,
           akc.corporate_id,
           akc.corporate_name,
           'Physicals' main_section,
           'Hedge Corrections' section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           aml.underlying_product_id product_id,
           pdm.product_desc product,
           pcm.trader_id trader_id,
           gab.firstname || ' ' || gab.lastname trader,
           pcm.contract_ref_no,
           pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
           pcdi.pcdi_id,
           (case
             when pcm.purchase_sales = 'P' then
              (-1) * pfd.qty_fixed
             else
              0
           end) purchase_qty,
           (case
             when pcm.purchase_sales = 'S' then
              (1) * pfd.qty_fixed
             else
              0
           end) sales_qty,
           qum.qty_unit,
           qum.qty_unit_id,
           pfd.fx_correction_date trade_date,
           (nvl(pfd.user_price, 0) + nvl(pfd.adjustment_price, 0)) price,
           pum.price_unit_id,
           pum.price_unit_name price_unit,
           decode(pcm.purchase_sales, 'P', -1, 'S', 1) *
           nvl(pfd.hedge_amount, 0) hedging_amount,
           cm_pay.cur_id exposure_cur_id,
           cm_pay.cur_code exposure_currency,
           cm_base.cur_id,
           cm_base.cur_code base_currency,
           1,
           pcm.purchase_sales
      from pcdi_pc_delivery_item          pcdi,
           pcm_physical_contract_main     pcm,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pofh_price_opt_fixation_header pofh,
           pfd_price_fixation_details     pfd,
           ak_corporate                   akc,
           ak_corporate_user              akcu,
           gab_globaladdressbook          gab,
           pcpd_pc_product_definition     pcpd,
           cpc_corporate_profit_center    cpc,
           pdm_productmaster              pdm,
           cm_currency_master             cm_base,
           cm_currency_master             cm_pay,
           v_ppu_pum                      ppu,
           pum_price_unit_master          pum,
           qum_quantity_unit_master       qum,
           aml_attribute_master_list      aml
     where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id(+)
       and pofh.pofh_id = pfd.pofh_id
       and pfd.is_active = 'Y'
       and pcm.corporate_id = akc.corporate_id
       and pcm.trader_id = akcu.user_id(+)
       and akcu.gabid = gab.gabid
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
       and pcpd.profit_center_id = cpc.profit_center_id
       and poch.element_id = aml.attribute_id
       and aml.underlying_product_id = pdm.product_id
       and akc.base_cur_id = cm_base.cur_id
       and pocd.pay_in_cur_id = cm_pay.cur_id
       and pfd.price_unit_id = ppu.product_price_unit_id(+)
       and ppu.price_unit_id = pum.price_unit_id(+)
       and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
       and pcpd.input_output = 'Input'
       and pcdi.is_active = 'Y'
       and pcm.is_active = 'Y'
       and pcm.contract_status <> 'Cancelled'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active(+) = 'Y'
       and pfd.hedge_amount is not null
       and pfd.is_hedge_correction = 'Y'
       and nvl(pfd.is_cancel, 'N') = 'N'
       and nvl(pfd.is_exposure, 'Y') = 'Y'
       and pcm.process_id = pc_process_id
       and pcdi.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and pcm.corporate_id = pc_corporate_id
       and pfd.fx_correction_date > vd_prev_eom_date
       and pfd.fx_correction_date <= pd_trade_date;
  commit;
  ---  10 Vat invoices
  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     internal_contract_ref_no,
     delivery_item_no,
     pcdi_id,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     purchase_sales)
    select pc_process_id,
           pd_trade_date,
           akc.corporate_id,
           akc.corporate_name,
           'Physicals' main_section,
           'Vat' section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           pdm.product_id,
           pdm.product_desc product,
           pcm.trader_id trader_id,
           gab.firstname || ' ' || gab.lastname trader,
           pcm.contract_ref_no,
           pcm.contract_ref_no || ' - ' || iid.delivery_item_ref_no delivery_item_ref_no,
           null pcdi_id,
           null purchase_qty,
           null sales_qty,
           null qty_unit,
           null qty_unit_id,
           iis.invoice_created_date trade_date,
           null price,
           null price_unit_id,
           null price_unit,
           (decode(iis.payable_receivable, 'Payable', 1, 'Receivable', -1) *
           abs(ivd.vat_amount_in_vat_cur)) hedging_amount,
           cm_pay.cur_id exposure_cur_id,
           cm_pay.cur_code exposure_currency,
           cm_base.cur_id,
           cm_base.cur_code base_currency,
           1,
           pcm.purchase_sales
    
      from ivd_invoice_vat_details ivd,
           (select iid.internal_contract_item_ref_no,
                   iid.internal_contract_ref_no,
                   ii.delivery_item_ref_no,
                   iid.internal_invoice_ref_no,
                   iid.internal_gmr_ref_no,
                   sum(iid.invoiced_qty)
              from iid_invoicable_item_details iid,
                   ii_invoicable_item          ii
             where iid.is_active = 'Y'
               and iid.invoicable_item_id = ii.invoicable_item_id
               and ii.is_active = 'Y'
             group by iid.internal_contract_item_ref_no,
                      iid.internal_contract_ref_no,
                      iid.internal_gmr_ref_no,
                      iid.internal_invoice_ref_no,
                      ii.delivery_item_ref_no) iid,
           is_invoice_summary iis,
           gmr_goods_movement_record gmr,
           pcm_physical_contract_main pcm,
           ak_corporate akc,
           ak_corporate_user akcu,
           gab_globaladdressbook gab,
           pcpd_pc_product_definition pcpd,
           pym_payment_terms_master pym,
           cpc_corporate_profit_center cpc,
           pdm_productmaster pdm,
           cm_currency_master cm_base,
           cm_currency_master cm_pay,
           cm_currency_master cm_vat,
           cm_currency_master cm_invoice
     where ivd.internal_invoice_ref_no = iid.internal_invoice_ref_no
       and iid.internal_invoice_ref_no = iis.internal_invoice_ref_no
       and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
       and iid.internal_contract_ref_no = pcm.internal_contract_ref_no
       and ivd.is_separate_invoice = 'N'
       and ivd.vat_remit_cur_id <> ivd.invoice_cur_id
       and pcm.corporate_id = akc.corporate_id
       and pcm.trader_id = akcu.user_id(+)
       and akcu.gabid = gab.gabid
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
       and pcpd.input_output = 'Input'
       and pcm.payment_term_id = pym.payment_term_id
       and pcpd.profit_center_id = cpc.profit_center_id
       and pcpd.product_id = pdm.product_id
       and akc.base_cur_id = cm_base.cur_id
       and ivd.vat_remit_cur_id = cm_pay.cur_id
       and akc.base_cur_id = cm_base.cur_id
       and ivd.vat_remit_cur_id = cm_vat.cur_id
       and ivd.invoice_cur_id = cm_invoice.cur_id
       and iis.is_active = 'Y'
       and gmr.is_deleted = 'N'
       and nvl(ivd.vat_amount_in_vat_cur, 0) <> 0
       and pcm.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and iis.process_id = pc_process_id
       and gmr.process_id = pc_process_id
       and iis.invoice_created_date > vd_prev_eom_date
       and iis.invoice_created_date <= pd_trade_date;
  commit;

  -- 11  VAT Exposure in INVOICE CURRENCY( for Invoice CCY <> VAT Remit With VAT as "Same Invoice" :-
  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     internal_contract_ref_no,
     delivery_item_no,
     pcdi_id,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     purchase_sales)
    select pc_process_id,
           pd_trade_date,
           akc.corporate_id,
           akc.corporate_name,
           'Physicals' main_section,
           'Vat' section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           pdm.product_id,
           pdm.product_desc product,
           pcm.trader_id trader_id,
           gab.firstname || ' ' || gab.lastname trader,
           pcm.contract_ref_no,
           pcm.contract_ref_no || ' - ' || iid.delivery_item_ref_no delivery_item_ref_no,
           null pcdi_id,
           null purchase_qty,
           null sales_qty,
           null qty_unit,
           null qty_unit_id,
           iis.invoice_created_date trade_date,
           null price,
           null price_unit_id,
           null price_unit,
           (decode(iis.payable_receivable, 'Payable', -1, 'Receivable', 1) *
           abs(ivd.vat_amount_in_inv_cur)) hedging_amount,
           cm_pay.cur_id exposure_cur_id,
           cm_pay.cur_code exposure_currency,
           cm_base.cur_id,
           cm_base.cur_code base_currency,
           1,
           pcm.purchase_sales
    
      from ivd_invoice_vat_details ivd,
           (select iid.internal_contract_item_ref_no,
                   iid.internal_contract_ref_no,
                   ii.delivery_item_ref_no,
                   iid.internal_invoice_ref_no,
                   iid.internal_gmr_ref_no,
                   sum(iid.invoiced_qty)
              from iid_invoicable_item_details iid,
                   ii_invoicable_item          ii
             where iid.is_active = 'Y'
               and iid.invoicable_item_id = ii.invoicable_item_id
               and ii.is_active = 'Y'
             group by iid.internal_contract_item_ref_no,
                      iid.internal_contract_ref_no,
                      iid.internal_gmr_ref_no,
                      iid.internal_invoice_ref_no,
                      ii.delivery_item_ref_no) iid,
           is_invoice_summary iis,
           gmr_goods_movement_record gmr,
           pcm_physical_contract_main pcm,
           ak_corporate akc,
           ak_corporate_user akcu,
           gab_globaladdressbook gab,
           pcpd_pc_product_definition pcpd,
           cpc_corporate_profit_center cpc,
           pdm_productmaster pdm,
           cm_currency_master cm_base,
           cm_currency_master cm_pay,
           cm_currency_master cm_vat,
           cm_currency_master cm_invoice
     where ivd.internal_invoice_ref_no = iid.internal_invoice_ref_no
       and iid.internal_invoice_ref_no = iis.internal_invoice_ref_no
       and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
       and iid.internal_contract_ref_no = pcm.internal_contract_ref_no
       and ivd.is_separate_invoice = 'N'
       and ivd.vat_remit_cur_id <> ivd.invoice_cur_id
       and pcm.corporate_id = akc.corporate_id
       and pcm.trader_id = akcu.user_id(+)
       and akcu.gabid = gab.gabid
       and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
       and pcpd.input_output = 'Input'
       and pcpd.profit_center_id = cpc.profit_center_id
       and pcpd.product_id = pdm.product_id
       and akc.base_cur_id = cm_base.cur_id
       and ivd.invoice_cur_id = cm_pay.cur_id
       and akc.base_cur_id = cm_base.cur_id
       and ivd.vat_remit_cur_id = cm_vat.cur_id
       and ivd.invoice_cur_id = cm_invoice.cur_id
       and iis.is_active = 'Y'
       and gmr.is_deleted = 'N'
       and nvl(ivd.vat_amount_in_inv_cur, 0) <> 0
       and pcm.process_id = pc_process_id
       and gmr.process_id = pc_process_id
       and pcpd.process_id = pc_process_id
       and iis.process_id = pc_process_id
       and iis.invoice_created_date > vd_prev_eom_date
       and iis.invoice_created_date <= pd_trade_date;
  commit;

  --- 12. Fx trades
  insert into fxar_fx_allocation_report
    (process_id,
     eod_trade_date,
     corporate_id,
     corporate_name,
     section_name,
     main_section,
     profit_center_id,
     profit_center_name,
     product_id,
     product_desc,
     trader_id,
     trader_name,
     external_ref_no,
     trade_ref_no,
     purchase_qty,
     sales_qty,
     qty_unit_id,
     qty_unit,
     exposure_date,
     price,
     price_unit_id,
     price_unit_name,
     hedge_amount,
     exposure_cur_id,
     exposure_cur_name,
     base_cur_id,
     base_cur_name,
     exchange_rate,
     instrument_id,
     instrument_name,
     value_date)
    select pc_process_id,
           pd_trade_date,
           ak.corporate_id,
           ak.corporate_name,
           'Derivatives' main_section,
           'FX Trades' section,
           cpc.profit_center_id,
           cpc.profit_center_short_name profit_center,
           pdm.product_id,
           pdm.product_desc product,
           ct.trader_id trader_id,
           gab.firstname || ' ' || gab.lastname trader,
           ct.external_ref_no,
           ct.treasury_ref_no,
           (case
             when crtd.trade_type = 'Buy' then
              (1) * crtd.amount
             else
              0
           end) purchase_qty,
           (case
             when crtd.trade_type = 'Sell' then
              (-1) * crtd.amount
             else
              0
           end) sales_qty,
           null qty_unit,
           null qty_unit_id,
           ct.trade_date trade_date,
           round(crtd.amount, 4) * (case
                                      when upper(crtd.trade_type) = 'BUY' then
                                       1
                                      else
                                       -1
                                    end) price,
           null price_unit_id,
           null price_unit,
           round(((case
                   when ak.base_cur_id = crtd.cur_id then
                    1
                   else
                    pkg_general.f_get_converted_currency_amt(ct.corporate_id,
                                                             crtd.cur_id,
                                                             ak.base_cur_id,
                                                             ct.trade_date,
                                                             1)
                 end) * round(crtd.amount, 4) * (case
                   when upper(crtd.trade_type) = 'BUY' then
                    1
                   else
                    -1
                 end)),
                 4) hedging_amount,
           crtd_cm.cur_id exposure_cur_id,
           crtd_cm.cur_code exposure_currency,
           cm_base.cur_id,
           cm_base.cur_code base_currency,
           1,
           dim.instrument_id,
           dim.instrument_name,
           ct.value_date
    
      from ct_currency_trade            ct,
           ak_corporate                 ak,
           cm_currency_master           cm_base,
           cpc_corporate_profit_center  cpc,
           cm_currency_master           cpc_cm,
           css_corporate_strategy_setup css,
           crtd_cur_trade_details       crtd,
           cm_currency_master           crtd_cm,
           drm_derivative_master        drm,
           dim_der_instrument_master    dim,
           pdd_product_derivative_def   pdd,
           pdm_productmaster            pdm,
           ak_corporate_user            akc,
           gab_globaladdressbook        gab
     where ct.corporate_id = ak.corporate_id
       and ak.base_cur_id = cm_base.cur_id
       and ct.profit_center_id = cpc.profit_center_id
       and ct.strategy_id = css.strategy_id(+)
       and ct.internal_treasury_ref_no = crtd.internal_treasury_ref_no
       and crtd.cur_id = crtd_cm.cur_id(+)
       and ct.bank_charges_cur_id = cpc_cm.cur_id(+)
       and ct.dr_id = drm.dr_id
       and drm.instrument_id = dim.instrument_id
       and dim.product_derivative_id = pdd.derivative_def_id
       and pdd.product_id = pdm.product_id
       and ct.trader_id = akc.user_id
       and akc.gabid = gab.gabid
       and upper(ct.status) = 'VERIFIED'
       and ct.process_id = pc_process_id
       and crtd.process_id = pc_process_id
       and ct.trade_date > vd_prev_eom_date
       and ct.trade_date <= pd_trade_date;
  commit;
  ---update the exchange rate for physicals
  for cur_exp_exch_rate in (select fxar.exposure_cur_id,
                                   fxar.base_cur_id,
                                   fxar.exposure_date
                              from fxar_fx_allocation_report fxar
                             where fxar.process_id = pc_process_id having
                             fxar.exposure_cur_id <> fxar.base_cur_id
                             group by fxar.exposure_cur_id,
                                      fxar.base_cur_id,
                                      fxar.exposure_date)
  loop
    select pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                    cur_exp_exch_rate.exposure_cur_id,
                                                    cur_exp_exch_rate.base_cur_id,
                                                    cur_exp_exch_rate.exposure_date,
                                                    1)
      into vn_exch_rate
      from dual;
    update fxar_fx_allocation_report fxar
       set fxar.exchange_rate = vn_exch_rate
     where fxar.process_id = pc_process_id
       and fxar.exposure_date = cur_exp_exch_rate.exposure_date
       and fxar.exposure_cur_id = cur_exp_exch_rate.exposure_cur_id;
  end loop;
  commit;
exception
  when others then
    vobj_error_log.extend;
    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                         'procedure pkg_phy_mbv_report.sp_fx_allocation_report',
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
