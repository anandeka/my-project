create or replace package pkg_phy_mb_valuation is

  -- Author  : JANARDHANA
  -- Created : 4/24/2013 6:00:32 PM
  -- Purpose : Metal Balance Valuation

  procedure sp_calc_instrument_price(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_process_id   varchar2,
                                     pc_process      varchar2,
                                     pc_user_id      varchar2);
  procedure sp_calc_pf_data(pc_corporate_id varchar2,
                            pd_trade_date   date,
                            pc_process_id   varchar2,
                            pc_process      varchar2,
                            pc_user_id      varchar2);

end;
/
create or replace package body pkg_phy_mb_valuation is
  procedure sp_calc_instrument_price(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_process_id   varchar2,
                                     pc_process      varchar2,
                                     pc_user_id      varchar2) is
    cursor cur_price is
      select dim.instrument_id,
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
        from dim_der_instrument_master    dim,
             div_der_instrument_valuation div,
             ps_price_source              ps,
             apm_available_price_master   apm,
             pum_price_unit_master        pum,
             v_der_instrument_price_unit  vdip,
             pdc_prompt_delivery_calendar pdc
       where dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id;
    vn_forward_days              number;
    vd_quotes_date               date;
    vc_market_quote_dr_id        varchar2(15);
    vc_data_missing_for          varchar2(1000);
    vd_prompt_date               date;
    vc_prompt_month              varchar2(15);
    vc_prompt_year               varchar2(15);
    vn_unfixed_val_price         number;
    vc_unfixed_val_price_unit_id varchar2(15);
    vd_valid_quote_date          date;
    vc_prompt_date_text          varchar2(100);
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vc_instrument_id             varchar2(15);
  
  begin
    delete from tip_temp_instrument_price
     where corporate_id = pc_corporate_id;
    commit;
    for cur_price_rows in cur_price
    loop
      vc_data_missing_for := null;
      vc_instrument_id    := cur_price_rows.instrument_id;
      if cur_price_rows.is_daily_cal_applicable = 'Y' then
        vn_forward_days := 0;
        vd_quotes_date  := pd_trade_date + 1;
        while vn_forward_days <> 2
        loop
          if pkg_metals_general.f_is_day_holiday(cur_price_rows.instrument_id,
                                                 vd_quotes_date) then
            vd_quotes_date := vd_quotes_date + 1;
          else
            vn_forward_days := vn_forward_days + 1;
            if vn_forward_days <> 2 then
              vd_quotes_date := vd_quotes_date + 1;
            end if;
          end if;
        end loop;
        begin
          select drm.dr_id
            into vc_market_quote_dr_id
            from drm_derivative_master drm
           where drm.instrument_id = cur_price_rows.instrument_id
             and drm.prompt_date = vd_quotes_date
             and rownum <= 1
             and drm.price_point_id is null
             and drm.is_deleted = 'N';
        exception
          when no_data_found then
            if vd_quotes_date is not null then
              vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
                                     cur_price_rows.instrument_name ||
                                     ',Price Source:' ||
                                     cur_price_rows.price_source_name ||
                                     ',Price Unit:' ||
                                     cur_price_rows.price_unit_name || ',' ||
                                     cur_price_rows.available_price_name ||
                                     ' Price,Prompt Date:' ||
                                     to_char(vd_quotes_date, 'dd-Mon-RRRR');
            end if;
        end;
      end if;
    
      if cur_price_rows.is_daily_cal_applicable = 'N' and
         cur_price_rows.is_monthly_cal_applicable = 'Y' then
        vd_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_price_rows.delivery_calender_id,
                                                                            pd_trade_date);
        vc_prompt_month := to_char(vd_prompt_date, 'Mon');
        vc_prompt_year  := to_char(vd_prompt_date, 'RRRR');
        begin
          select drm.dr_id
            into vc_market_quote_dr_id
            from drm_derivative_master drm
           where drm.instrument_id = cur_price_rows.instrument_id
             and drm.period_month = vc_prompt_month
             and drm.period_year = vc_prompt_year
             and rownum <= 1
             and drm.price_point_id is null
             and drm.is_deleted = 'N';
        exception
          when no_data_found then
            if vc_prompt_month is not null and vc_prompt_year is not null then
              vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
                                     cur_price_rows.instrument_name ||
                                     ',Price Source:' ||
                                     cur_price_rows.price_source_name ||
                                     ',Price Unit:' ||
                                     cur_price_rows.price_unit_name || ',' ||
                                     cur_price_rows.available_price_name ||
                                     ' Price,Prompt Date:' ||
                                     vc_prompt_month || ' ' ||
                                     vc_prompt_year;
            end if;
        end;
      end if;
    
      begin
        select dqd.price,
               dqd.price_unit_id
          into vn_unfixed_val_price,
               vc_unfixed_val_price_unit_id
          from dq_derivative_quotes        dq,
               dqd_derivative_quote_detail dqd,
               cdim_corporate_dim          cdim
         where dq.dq_id = dqd.dq_id
           and dqd.dr_id = vc_market_quote_dr_id
           and dq.instrument_id = cur_price_rows.instrument_id
           and dqd.process_id = pc_process_id
           and dq.process_id = pc_process_id
           and dqd.available_price_id = cur_price_rows.available_price_id
           and dq.price_source_id = cur_price_rows.price_source_id
           and dqd.price_unit_id = cur_price_rows.price_unit_id
           and dq.trade_date = cdim.valid_quote_date
           and dq.is_deleted = 'N'
           and dqd.is_deleted = 'N'
           and cdim.corporate_id = pc_corporate_id
           and cdim.instrument_id = dq.instrument_id;
      exception
        when no_data_found then
          select cdim.valid_quote_date
            into vd_valid_quote_date
            from cdim_corporate_dim cdim
           where cdim.corporate_id = pc_corporate_id
             and cdim.instrument_id = cur_price_rows.instrument_id;
          if vd_prompt_date is not null then
            select (case
                     when cur_price_rows.is_daily_cal_applicable = 'N' and
                          cur_price_rows.is_monthly_cal_applicable = 'Y' then
                      to_char(vd_prompt_date, 'Mon-RRRR')
                     else
                      to_char(vd_quotes_date, 'dd-Mon-RRRR')
                   end)
              into vc_prompt_date_text
              from dual;
            vc_data_missing_for := 'Price missing for ' ||
                                   cur_price_rows.instrument_name ||
                                   ',Price Source:' ||
                                   cur_price_rows.price_source_name ||
                                   ',Price Unit:' ||
                                   cur_price_rows.price_unit_name || ',' ||
                                   cur_price_rows.available_price_name ||
                                   ' Price,Prompt Date:' ||
                                   vc_prompt_date_text || ' Trade Date(' ||
                                   to_char(vd_valid_quote_date,
                                           'dd-Mon-RRRR') || ')';
          
          end if;
      end;
      insert into tip_temp_instrument_price
        (corporate_id,
         instrument_id,
         price,
         price_unit_id,
         data_missing_for)
      values
        (pc_corporate_id,
         cur_price_rows.instrument_id,
         vn_unfixed_val_price,
         vc_unfixed_val_price_unit_id,
         vc_data_missing_for);
    end loop;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_instrument_price',
                                                           'M2M-013',
                                                           sqlcode || ' ' ||
                                                           sqlerrm ||
                                                           ' Instrument ID is ' ||
                                                           vc_instrument_id,
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
    vc_corporate_name varchar2(100);
  begin
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
       purchase_sales)
      select pc_process_id,
             pd_trade_date,
             decode(pfd.is_balance_pricing,
                    'N',
                    'New Price Fixations For This Month',
                    'List Of Balance Price Fixations') section_name,
             pc_corporate_id,
             vc_corporate_name,
             pdm_aml.product_id,
             pdm_aml.product_desc,
             pcm.cp_id,
             pcm.cp_name,
             pcm.internal_contract_ref_no,
             pcdi.delivery_item_no,
             pcm.contract_ref_no || '(' || pcdi.delivery_item_no || ')' contract_ref_no_del_item_no,
             pfd.hedge_correction_date price_fixation_date,
             null as pf_ref_no,
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
             decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales
        from pfd_price_fixation_details     pfd,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             poch_price_opt_call_off_header poch,
             pcdi_pc_delivery_item          pcdi,
             pcm_physical_contract_main     pcm,
             v_ppu_pum                      ppu,
             cm_currency_master             cm,
             qum_quantity_unit_master       qum,
             aml_attribute_master_list      aml,
             pdm_productmaster              pdm_aml
       where pfd.pofh_id = pofh.pofh_id
         and pofh.pocd_id = pocd.pocd_id
         and pocd.poch_id = poch.poch_id
         and poch.pcdi_id = pcdi.pcdi_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
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
         and ppu.weight_unit_id = qum.qty_unit_id;
  
    -- List of Consumed Fixations for Realization
    -- List of Balance Price Fixations from previous Month
  
  end;
end;
/
