create or replace package pkg_phy_mb_valuation is

  -- Author  : JANARDHANA
  -- Created : 4/24/2013 6:00:32 PM
  -- Purpose : Metal Balance Valuation

  procedure sp_calc_instrument_price(pc_corporate_id varchar2,
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
  
  begin
    delete from ip_instrument_price where corporate_id = pc_corporate_id;
    commit;
    for cur_price_rows in cur_price
    loop
      vc_data_missing_for := null;
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
      insert into ip_instrument_price
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
