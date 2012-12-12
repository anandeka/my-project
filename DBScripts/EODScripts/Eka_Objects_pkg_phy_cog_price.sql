create or replace package pkg_phy_cog_price is
  procedure sp_base_contract_cog_price(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2,
                                       pc_dbd_id       varchar2,
                                       pc_process      varchar2);
  procedure sp_base_gmr_cog_price(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process_id   varchar2,
                                  pc_user_id      varchar2,
                                  pc_dbd_id       varchar2,
                                  pc_process      varchar2);
  procedure sp_conc_contract_cog_price(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2,
                                       pc_dbd_id       varchar2,
                                       pc_process      varchar2);
  procedure sp_conc_gmr_cog_price(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process_id   varchar2,
                                  pc_user_id      varchar2,
                                  pc_dbd_id       varchar2,
                                  pc_process      varchar2);
  procedure sp_conc_gmr_allocation_price(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_dbd_id       varchar2,
                                         pc_process      varchar2);
end;
/
create or replace package body pkg_phy_cog_price is
  procedure sp_base_contract_cog_price(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2,
                                       pc_dbd_id       varchar2,
                                       pc_process      varchar2) is
    ------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_base_contract_cog_price
    --        Author                                    : Janna
    --        Created Date                              : 29th Mar 2012
    --        Purpose                                   : Calcualte COG Price for BM Contract
    --
    --        Parameters
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------                                       
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vc_price_unit_cur_id         varchar2(15);
    vc_price_unit_cur_code       varchar2(15);
    vc_price_unit_weight_unit_id varchar2(15);
    vc_price_unit_weight_unit    varchar2(15);
    vn_price_unit_weight         number;
    vn_forward_days              number;
    vd_valid_quote_date          date;
    vc_prompt_date_text          varchar2(100);
    vn_unfixed_value             number;
    vn_unfixed_qty               number;
    vc_unfixed_val_price_unit_id varchar2(100);
    vn_unfixed_val_price         number;
    vc_market_quote_dr_id        varchar2(15);
    vn_fixed_value               number;
    vn_fixed_qty                 number;
    vd_prompt_date               date;
    vc_data_missing_for          varchar2(1000);
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
             pcdi.price_option_call_off_status,
             pcm.contract_ref_no,
             diqs.total_qty item_qty,
             diqs.item_qty_unit_id item_qty_unit_id,
             pcm.invoice_currency_id,
             pcpd.qty_unit_id,
             pcpd.product_id,
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
        from pcdi_pc_delivery_item pcdi,
             diqs_delivery_item_qty_status diqs,
             pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcpd_pc_product_definition pcpd,
             (select *
                from v_pcdi_exchange_detail t
               where t.corporate_id = pc_corporate_id) qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip,
             pdc_prompt_delivery_calendar pdc
       where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'BASEMETAL'
         and pcpd.input_output = 'Input'
         and pcdi.pcdi_id = qat.pcdi_id(+)
         and qat.instrument_id = dim.instrument_id(+)
         and dim.instrument_id = div.instrument_id(+)
         and div.is_deleted(+) = 'N'
         and div.price_source_id = ps.price_source_id(+)
         and div.available_price_id = apm.available_price_id(+)
         and div.price_unit_id = pum.price_unit_id(+)
         and dim.instrument_id = vdip.instrument_id(+)
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id(+)
         and pcdi.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and pcpd.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pcm.is_active = 'Y'
         and diqs.pcdi_id = pcdi.pcdi_id
         and diqs.process_id = pc_process_id
         and diqs.is_active = 'Y';
  
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
         and pci.pcdi_id = pc_pcdi_id
         and pci.process_id = pc_process_id
         and pcipf.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pcbpd.process_id = pc_process_id
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
  
    vn_contract_price        number;
    vc_price_unit_id         varchar2(15);
    vc_price_basis           varchar2(15);
    vc_price_cur_id          varchar2(15);
    vc_price_cur_code        varchar2(15);
    vn_price_weight_unit     number;
    vc_price_weight_unit_id  varchar2(15);
    vc_price_qty_unit        varchar2(15);
    vc_price_fixation_status varchar2(50);
    vn_total_quantity        number;
    vn_qty_to_be_priced      number;
    vn_total_contract_value  number;
    vn_average_price         number;
    vd_quotes_date           date;
    vn_error_no              number := 0;
    vc_prompt_month          varchar2(15);
    vc_prompt_year           number;
    vc_fixed_price_unit_id   varchar2(15);
  
  begin
    for cur_pcdi_rows in cur_pcdi
    loop
      vn_total_contract_value      := 0;
      vn_fixed_qty                 := 0;
      vn_unfixed_qty               := 0;
      vn_fixed_value               := 0;
      vn_unfixed_value             := 0;
      vc_fixed_price_unit_id       := null;
      vc_unfixed_val_price_unit_id := null;
      if cur_pcdi_rows.price_option_call_off_status in
         ('Called Off', 'Not Applicable') then
        vc_price_fixation_status := null;
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id)
        loop
          vn_total_quantity   := cur_pcdi_rows.item_qty;
          vn_qty_to_be_priced := cur_called_off_rows.qty_to_be_priced;
          vc_price_basis      := cur_called_off_rows.price_basis;
          if cur_called_off_rows.price_basis = 'Fixed' then
            vn_fixed_qty            := vn_total_quantity;
            vn_unfixed_qty          := 0;
            vn_contract_price       := cur_called_off_rows.price_value;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_called_off_rows.price_unit_id;
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select pofh.pofh_id
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail pcbpd,
                               ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing pfqpp,
                               (select *
                                  from pofh_price_opt_fixation_header pfh
                                 where pfh.internal_gmr_ref_no is null
                                   and pfh.is_active = 'Y') pofh,
                               v_ppu_pum ppu
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
                           and pcbpd.process_id = pc_process_id
                           and pfqpp.process_id = pc_process_id
                           and ppfh.process_id = pc_process_id)
            
            loop
              begin
                select nvl(sum(pfd.user_price * pfd.qty_fixed), 0),
                       nvl(sum(pfd.qty_fixed), 0),
                       vppu.price_unit_id
                  into vn_fixed_value,
                       vn_fixed_qty,
                       vc_fixed_price_unit_id
                  from poch_price_opt_call_off_header poch,
                       pocd_price_option_calloff_dtls pocd,
                       pofh_price_opt_fixation_header pofh,
                       pfd_price_fixation_details     pfd,
                       v_ppu_pum                      vppu
                 where poch.poch_id = pocd.poch_id
                   and pocd.pocd_id = pofh.pocd_id
                   and pofh.pofh_id = cc1.pofh_id
                   and pofh.pofh_id = pfd.pofh_id
                   and pfd.hedge_correction_date <= pd_trade_date
                   and pfd.price_unit_id = vppu.product_price_unit_id
                   and poch.is_active = 'Y'
                   and pocd.is_active = 'Y'
                   and pofh.is_active = 'Y'
                   and pfd.is_active = 'Y'
                   and (nvl(pfd.user_price, 0) * nvl(pfd.qty_fixed, 0)) <> 0
                 group by vppu.price_unit_id;
              exception
                when others then
                  vn_fixed_value         := 0;
                  vn_fixed_qty           := 0;
                  vc_fixed_price_unit_id := null;
              end;
              vn_unfixed_qty := vn_total_quantity - vn_fixed_qty;
              if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                vn_forward_days := 0;
                vd_quotes_date  := pd_trade_date + 1;
                while vn_forward_days <> 2
                loop
                  if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                   where drm.instrument_id = cur_pcdi_rows.instrument_id
                     and drm.prompt_date = vd_quotes_date
                     and rownum <= 1
                     and drm.price_point_id is null
                     and drm.is_deleted = 'N';
                exception
                  when no_data_found then
                    if vd_quotes_date is not null then
                      vobj_error_log.extend;
                      vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
                                             cur_pcdi_rows.instrument_name ||
                                             ',Price Source:' ||
                                             cur_pcdi_rows.price_source_name ||
                                             ' Contract Ref No: ' ||
                                             cur_pcdi_rows.contract_ref_no ||
                                             ',Price Unit:' ||
                                             cur_pcdi_rows.price_unit_name || ',' ||
                                             cur_pcdi_rows.available_price_name ||
                                             ' Price,Prompt Date:' ||
                                             to_char(vd_quotes_date,
                                                     'dd-Mon-RRRR');
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_concentrate_cog_price',
                                                                           'PHY-002',
                                                                           vc_data_missing_for,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    end if;
                end;
              end if;
            
              if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                 cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                vd_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                    pd_trade_date);
                vc_prompt_month := to_char(vd_prompt_date, 'Mon');
                vc_prompt_year  := to_char(vd_prompt_date, 'RRRR');
                begin
                  select drm.dr_id
                    into vc_market_quote_dr_id
                    from drm_derivative_master drm
                   where drm.instrument_id = cur_pcdi_rows.instrument_id
                     and drm.period_month = vc_prompt_month
                     and drm.period_year = vc_prompt_year
                     and rownum <= 1
                     and drm.price_point_id is null
                     and drm.is_deleted = 'N';
                exception
                  when no_data_found then
                    if vc_prompt_month is not null and
                       vc_prompt_year is not null then
                      vobj_error_log.extend;
                      vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
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
                                             vc_prompt_year;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_concentrate_cog_price',
                                                                           'PHY-002',
                                                                           vc_data_missing_for,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
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
                   and dq.instrument_id = cur_pcdi_rows.instrument_id
                   and dq.dbd_id = dqd.dbd_id
                   and dq.dbd_id = pc_dbd_id
                   and dqd.available_price_id =
                       cur_pcdi_rows.available_price_id
                   and dq.price_source_id = cur_pcdi_rows.price_source_id
                   and dqd.price_unit_id = cur_pcdi_rows.price_unit_id
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
                     and cdim.instrument_id = cur_pcdi_rows.instrument_id;
                  if vd_prompt_date is not null then
                    vobj_error_log.extend;
                    select (case
                             when cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                                  cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                              to_char(vd_prompt_date, 'Mon-RRRR')
                             else
                              to_char(vd_quotes_date, 'dd-Mon-RRRR')
                           end)
                      into vc_prompt_date_text
                      from dual;
                    vc_data_missing_for := 'Price missing for ' ||
                                           cur_pcdi_rows.instrument_name ||
                                           ',Price Source:' ||
                                           cur_pcdi_rows.price_source_name ||
                                           ' Contract Ref No: ' ||
                                           cur_pcdi_rows.contract_ref_no ||
                                           ',Price Unit:' ||
                                           cur_pcdi_rows.price_unit_name || ',' ||
                                           cur_pcdi_rows.available_price_name ||
                                           ' Price,Prompt Date:' ||
                                           vc_prompt_date_text ||
                                           ' Trade Date(' ||
                                           to_char(vd_valid_quote_date,
                                                   'dd-Mon-RRRR') || ')';
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_concentrate_congprice',
                                                                         'PHY-002',
                                                                         vc_data_missing_for,
                                                                         '',
                                                                         pc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                  
                    sp_insert_error_log(vobj_error_log);
                  end if;
                when others then
                  vobj_error_log.extend;
                  vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                       'procedure sp_concentrate_congprice',
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
              --
              -- If Both Fixed and Unfixed Quantities are there then we have two prices
              -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
              --
              if vn_fixed_value > 0 and vn_unfixed_val_price > 0 then
                if vc_fixed_price_unit_id <> vc_unfixed_val_price_unit_id then
                  select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                             vn_unfixed_val_price,
                                                                             vc_unfixed_val_price_unit_id,
                                                                             vc_fixed_price_unit_id,
                                                                             pd_trade_date,
                                                                             cur_pcdi_rows.product_id)
                    into vn_unfixed_val_price
                    from dual;
                end if;
              
              end if;
              if vn_unfixed_qty > 0 then
                vn_unfixed_value := vn_unfixed_qty * vn_unfixed_val_price;
              else
                vn_unfixed_value := 0;
                vn_unfixed_qty   := 0;
              end if;
              if vn_fixed_qty < 0 then
                vn_fixed_value := 0;
                vn_fixed_qty   := 0;
              end if;
              vn_total_quantity := vn_fixed_qty + vn_unfixed_qty;
              if vc_fixed_price_unit_id is not null then
                vc_price_unit_id := vc_fixed_price_unit_id;
              else
                vc_price_unit_id := vc_unfixed_val_price_unit_id;
              end if;
              begin
                select ppu.product_price_unit_id
                  into vc_price_unit_id
                  from v_ppu_pum ppu
                 where ppu.price_unit_id = vc_price_unit_id
                   and ppu.product_id = cur_pcdi_rows.product_id;
              exception
                when others then
                  vc_price_unit_id := null;
              end;
              vn_total_contract_value := vn_total_contract_value +
                                         ((vn_qty_to_be_priced / 100) *
                                         (vn_fixed_value +
                                         vn_unfixed_value));
            
            end loop;
          end if;
        
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  4);
      
        vn_error_no := vn_error_no + 1;
      elsif cur_pcdi_rows.price_option_call_off_status = 'Not Called Off' then
        vn_error_no := vn_error_no + 1;
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id)
        loop
          vc_price_basis      := cur_not_called_off_rows.price_basis;
          vn_total_quantity   := cur_pcdi_rows.item_qty;
          vn_qty_to_be_priced := cur_not_called_off_rows.qty_to_be_priced;
        
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price        := cur_not_called_off_rows.price_value;
            vn_total_contract_value  := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        vn_contract_price;
            vc_price_unit_id         := cur_not_called_off_rows.price_unit_id;
            vc_price_fixation_status := 'Fixed';
            vn_fixed_qty             := vn_total_quantity;
            vn_unfixed_qty           := 0;
            vn_error_no              := 3;
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
              vn_forward_days := 0;
              vd_quotes_date  := pd_trade_date + 1;
              while vn_forward_days <> 2
              loop
                if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                 where drm.instrument_id = cur_pcdi_rows.instrument_id
                   and drm.prompt_date = vd_quotes_date
                   and rownum <= 1
                   and drm.price_point_id is null
                   and drm.is_deleted = 'N';
              exception
                when no_data_found then
                  if vd_quotes_date is not null then
                    vobj_error_log.extend;
                    vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
                                           cur_pcdi_rows.instrument_name ||
                                           ',Price Source:' ||
                                           cur_pcdi_rows.price_source_name ||
                                           ' Contract Ref No: ' ||
                                           cur_pcdi_rows.contract_ref_no ||
                                           ',Price Unit:' ||
                                           cur_pcdi_rows.price_unit_name || ',' ||
                                           cur_pcdi_rows.available_price_name ||
                                           ' Price,Prompt Date:' ||
                                           to_char(vd_quotes_date,
                                                   'dd-Mon-RRRR');
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_concentrate_cog_price',
                                                                         'PHY-002',
                                                                         vc_data_missing_for,
                                                                         '',
                                                                         pc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                  end if;
              end;
            end if;
          
            if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
               cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
              vd_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                  pd_trade_date);
              vc_prompt_month := to_char(vd_prompt_date, 'Mon');
              vc_prompt_year  := to_char(vd_prompt_date, 'RRRR');
              begin
                select drm.dr_id
                  into vc_market_quote_dr_id
                  from drm_derivative_master drm
                 where drm.instrument_id = cur_pcdi_rows.instrument_id
                   and drm.period_month = vc_prompt_month
                   and drm.period_year = vc_prompt_year
                   and rownum <= 1
                   and drm.price_point_id is null
                   and drm.is_deleted = 'N';
              exception
                when no_data_found then
                
                  if vc_prompt_month is not null and
                     vc_prompt_year is not null then
                    vobj_error_log.extend;
                    vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
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
                                           vc_prompt_year;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_concentrate_cog_price',
                                                                         'PHY-002',
                                                                         vc_data_missing_for,
                                                                         '',
                                                                         pc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
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
                 and dq.instrument_id = cur_pcdi_rows.instrument_id
                 and dq.dbd_id = dqd.dbd_id
                 and dq.dbd_id = pc_dbd_id
                 and dqd.available_price_id =
                     cur_pcdi_rows.available_price_id
                 and dq.price_source_id = cur_pcdi_rows.price_source_id
                 and dqd.price_unit_id = cur_pcdi_rows.price_unit_id
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
                   and cdim.instrument_id = cur_pcdi_rows.instrument_id;
                if vd_quotes_date is not null then
                  vobj_error_log.extend;
                  select (case
                           when cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                                cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                            to_char(vd_prompt_date, 'Mon-RRRR')
                           else
                            to_char(vd_quotes_date, 'dd-Mon-RRRR')
                         end)
                    into vc_prompt_date_text
                    from dual;
                  vc_data_missing_for := 'Price missing for ' ||
                                         cur_pcdi_rows.instrument_name ||
                                         ',Price Source:' ||
                                         cur_pcdi_rows.price_source_name ||
                                         ' Contract Ref No: ' ||
                                         cur_pcdi_rows.contract_ref_no ||
                                         ',Price Unit:' ||
                                         cur_pcdi_rows.price_unit_name || ',' ||
                                         cur_pcdi_rows.available_price_name ||
                                         ' Price,Prompt Date:' ||
                                         vc_prompt_date_text ||
                                         ' Trade Date(' ||
                                         to_char(vd_valid_quote_date,
                                                 'dd-Mon-RRRR') || ')';
                  vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                       'procedure sp_concentrate_congprice',
                                                                       'PHY-002',
                                                                       vc_data_missing_for,
                                                                       '',
                                                                       pc_process,
                                                                       pc_user_id,
                                                                       sysdate,
                                                                       pd_trade_date);
                
                  sp_insert_error_log(vobj_error_log);
                end if;
              when others then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_concentrate_congprice',
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
            vn_fixed_qty            := 0;
            vn_unfixed_qty          := vn_total_quantity;
            vn_total_contract_value := vn_total_contract_value +
                                       ((vn_qty_to_be_priced / 100) *
                                       (vn_total_quantity *
                                       vn_unfixed_val_price));
            begin
              select ppu.product_price_unit_id
                into vc_price_unit_id
                from v_ppu_pum ppu
               where ppu.price_unit_id = vc_unfixed_val_price_unit_id
                 and ppu.product_id = cur_pcdi_rows.product_id;
            exception
              when others then
                vc_price_unit_id := null;
            end;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  4);
      end if;
      vn_error_no := 7;
      begin
        select cm.cur_id,
               cm.cur_code,
               ppu.weight,
               ppu.weight_unit_id,
               qum.qty_unit
          into vc_price_cur_id,
               vc_price_cur_code,
               vn_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      
        vn_error_no := 8;
      
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vn_price_weight_unit    := null;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
    
      vn_error_no := 9;
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
          null;
      end;
      if vn_average_price is not null and vc_price_unit_id is not null then
        insert into bccp_base_contract_cog_price
          (process_id,
           corporate_id,
           pcdi_id,
           internal_contract_ref_no,
           contract_ref_no,
           delivery_qty,
           qty_unit_id,
           contract_price,
           price_unit_id,
           price_unit_cur_id,
           price_unit_cur_code,
           price_unit_weight,
           price_unit_weight_unit_id,
           price_unit_weight_unit,
           fixed_qty,
           unfixed_qty,
           price_basis)
        values
          (pc_process_id,
           pc_corporate_id,
           cur_pcdi_rows.pcdi_id,
           cur_pcdi_rows.internal_contract_ref_no,
           cur_pcdi_rows.contract_ref_no,
           cur_pcdi_rows.item_qty,
           cur_pcdi_rows.qty_unit_id,
           vn_average_price,
           vc_price_unit_id,
           vc_price_unit_cur_id,
           vc_price_unit_cur_code,
           vn_price_unit_weight,
           vc_price_unit_weight_unit_id,
           vc_price_unit_weight_unit,
           vn_fixed_qty,
           vn_unfixed_qty,
           vc_price_basis);
      end if;
    end loop;
    commit;
    sp_gather_stats('bccp_base_contract_cog_price');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_base_contract_cog_price',
                                                           'M2M-013',
                                                           ' Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm ||
                                                           dbms_utility.format_error_backtrace ||
                                                           'No ' ||
                                                           vn_error_no,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
      commit;
  end;
  procedure sp_base_gmr_cog_price(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process_id   varchar2,
                                  pc_user_id      varchar2,
                                  pc_dbd_id       varchar2,
                                  pc_process      varchar2) is
    cursor cur_gmr is
      select gmr.corporate_id,
             grd.product_id,
             grd.internal_grd_ref_no internal_grd_ref_no,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.qty,
             gmr.qty_unit_id,
             pofh.pofh_id,
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
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.internal_grd_ref_no,
                     grd.quality_id,
                     grd.product_id
                from grd_goods_record_detail grd
               where grd.process_id = pc_process_id
                 and grd.tolling_stock_type = 'None Tolling'
                 and grd.status = 'Active'
                 and grd.is_deleted = 'N'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id,
                        grd.internal_grd_ref_no) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             v_gmr_exchange_detail qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip,
             pdc_prompt_delivery_calendar pdc
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdtm.product_type_name = 'Standard'
         and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and gmr.process_id = pc_process_id
         and gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
         and gmr.process_id = qat.process_id(+)
         and qat.instrument_id = dim.instrument_id(+)
         and dim.instrument_id = div.instrument_id(+)
         and div.is_deleted(+) = 'N'
         and div.price_source_id = ps.price_source_id(+)
         and div.available_price_id = apm.available_price_id(+)
         and div.price_unit_id = pum.price_unit_id(+)
         and dim.instrument_id = vdip.instrument_id(+)
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id(+)
         and gmr.is_deleted = 'N'
         and pofh.is_active = 'Y'
      union all
      select gmr.corporate_id,
             grd.product_id,
             grd.internal_dgrd_ref_no internal_grd_ref_no,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.qty,
             gmr.qty_unit_id,
             pofh.pofh_id,
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
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.internal_dgrd_ref_no,
                     grd.quality_id,
                     grd.product_id
                from dgrd_delivered_grd grd
               where grd.process_id = pc_process_id
                 and grd.status = 'Active'
                 and grd.tolling_stock_type = 'None Tolling'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id,
                        grd.internal_dgrd_ref_no) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             v_gmr_exchange_detail qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip,
             pdc_prompt_delivery_calendar pdc
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdtm.product_type_name = 'Standard'
         and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and gmr.process_id = pc_process_id
         and gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
         and gmr.process_id = qat.process_id(+)
         and qat.instrument_id = dim.instrument_id(+)
         and dim.instrument_id = div.instrument_id(+)
         and div.is_deleted(+) = 'N'
         and div.price_source_id = ps.price_source_id(+)
         and div.available_price_id = apm.available_price_id(+)
         and div.price_unit_id = pum.price_unit_id(+)
         and dim.instrument_id = vdip.instrument_id(+)
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id(+)
         and gmr.is_deleted = 'N'
         and pofh.is_active = 'Y';
  
    cursor cur_gmr_ele(pc_internal_gmr_ref_no varchar2) is
      select pofh.internal_gmr_ref_no,
             pofh.pofh_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pcbpd.price_basis
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where pofh.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pcbpd.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
  
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vn_total_contract_value      number;
    vc_price_cur_id              varchar2(15);
    vc_price_cur_code            varchar2(15);
    vn_price_weight_unit         number;
    vc_price_weight_unit_id      varchar2(15);
    vc_price_qty_unit            varchar2(15);
    vc_pcbpd_id                  varchar2(15);
    vc_fixed_price_unit_id       varchar2(15);
    vn_fixed_value               number;
    vn_fixed_qty                 number;
    vn_unfixed_qty               number;
    vn_total_quantity            number;
    vn_forward_days              number;
    vd_quotes_date               date;
    vd_prompt_date               date;
    vc_prompt_month              varchar2(15);
    vc_prompt_year               varchar2(15);
    vc_market_quote_dr_id        varchar2(15);
    vd_valid_quote_date          date;
    vn_unfixed_val_price         number;
    vc_unfixed_val_price_unit_id varchar2(15);
    vc_prompt_date_text          varchar2(100);
    vn_qty_to_be_priced          number;
    vc_price_unit_id             varchar2(15);
    vc_price_basis               varchar2(15);
    vn_average_price             number;
    vn_unfixed_value             number;
    vc_data_missing_for          varchar2(1000);
  begin
    for cur_gmr_rows in cur_gmr
    loop
      vn_total_contract_value      := 0;
      vn_fixed_qty                 := 0;
      vn_unfixed_qty               := 0;
      vn_fixed_value               := 0;
      vn_unfixed_value             := 0;
      vc_pcbpd_id                  := cur_gmr_rows.pcbpd_id;
      vn_total_quantity            := cur_gmr_rows.qty;
      vc_unfixed_val_price_unit_id := null;
      vc_unfixed_val_price_unit_id := null;
    
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no)
      loop
        vn_qty_to_be_priced := cur_gmr_ele_rows.qty_to_be_priced;
        vc_price_basis      := cur_gmr_ele_rows.price_basis;
        begin
          select nvl(sum(pfd.user_price * pfd.qty_fixed), 0),
                 nvl(sum(pfd.qty_fixed), 0),
                 ppu.price_unit_id
            into vn_fixed_value,
                 vn_fixed_qty,
                 vc_fixed_price_unit_id
            from poch_price_opt_call_off_header poch,
                 pocd_price_option_calloff_dtls pocd,
                 pofh_price_opt_fixation_header pofh,
                 pfd_price_fixation_details     pfd,
                 v_ppu_pum                      ppu
           where poch.poch_id = pocd.poch_id
             and pocd.pocd_id = pofh.pocd_id
             and pofh.pofh_id = cur_gmr_rows.pofh_id
             and pofh.pofh_id = pfd.pofh_id
             and pfd.hedge_correction_date <= pd_trade_date
             and poch.is_active = 'Y'
             and pocd.is_active = 'Y'
             and pofh.is_active = 'Y'
             and pfd.is_active = 'Y'
             and ppu.product_price_unit_id = pfd.price_unit_id
             and (nvl(pfd.user_price, 0) * nvl(pfd.qty_fixed, 0)) <> 0
           group by ppu.price_unit_id;
        exception
          when others then
            vn_fixed_value         := 0;
            vn_fixed_qty           := 0;
            vc_fixed_price_unit_id := null;
        end;
        vn_unfixed_qty := vn_total_quantity - vn_fixed_qty;
      
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          vn_forward_days := 0;
          vd_quotes_date  := pd_trade_date + 1;
          while vn_forward_days <> 2
          loop
            if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
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
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.prompt_date = vd_quotes_date
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              if vd_quotes_date is not null then
                vobj_error_log.extend;
                vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
                                       cur_gmr_rows.instrument_name ||
                                       ',Price Source:' ||
                                       cur_gmr_rows.price_source_name ||
                                       ' Contract Ref No: ' ||
                                       cur_gmr_rows.gmr_ref_no ||
                                       ',Price Unit:' ||
                                       cur_gmr_rows.price_unit_name || ',' ||
                                       cur_gmr_rows.available_price_name ||
                                       ' Price,Prompt Date:' ||
                                       to_char(vd_quotes_date,
                                               'dd-Mon-RRRR');
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_concentrate_cog_price',
                                                                     'PHY-002',
                                                                     vc_data_missing_for,
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
              end if;
          end;
        end if;
      
        if cur_gmr_rows.is_daily_cal_applicable = 'N' and
           cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
          vd_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                              pd_trade_date);
          vc_prompt_month := to_char(vd_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vd_prompt_date, 'RRRR');
          begin
            select drm.dr_id
              into vc_market_quote_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.period_month = vc_prompt_month
               and drm.period_year = vc_prompt_year
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              if vc_prompt_month is not null and vc_prompt_year is not null then
                vobj_error_log.extend;
                vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
                                       cur_gmr_rows.instrument_name ||
                                       ',Price Source:' ||
                                       cur_gmr_rows.price_source_name ||
                                       ' Contract Ref No: ' ||
                                       cur_gmr_rows.gmr_ref_no ||
                                       ',Price Unit:' ||
                                       cur_gmr_rows.price_unit_name || ',' ||
                                       cur_gmr_rows.available_price_name ||
                                       ' Price,Prompt Date:' ||
                                       vc_prompt_month || ' ' ||
                                       vc_prompt_year;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_concentrate_cog_price',
                                                                     'PHY-002',
                                                                     vc_data_missing_for,
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
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
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dq.dbd_id = dqd.dbd_id
             and dq.dbd_id = pc_dbd_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dqd.price_unit_id = cur_gmr_rows.price_unit_id
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
               and cdim.instrument_id = cur_gmr_rows.instrument_id;
            if vd_quotes_date is not null then
              vobj_error_log.extend;
              select (case
                       when cur_gmr_rows.is_daily_cal_applicable = 'N' and
                            cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
                        to_char(vd_prompt_date, 'Mon-RRRR')
                       else
                        to_char(vd_quotes_date, 'dd-Mon-RRRR')
                     end)
                into vc_prompt_date_text
                from dual;
              vc_data_missing_for := 'Price missing for ' ||
                                     cur_gmr_rows.instrument_name ||
                                     ',Price Source:' ||
                                     cur_gmr_rows.price_source_name ||
                                     ' Contract Ref No: ' ||
                                     cur_gmr_rows.gmr_ref_no ||
                                     ',Price Unit:' ||
                                     cur_gmr_rows.price_unit_name || ',' ||
                                     cur_gmr_rows.available_price_name ||
                                     ' Price,Prompt Date:' ||
                                     vc_prompt_date_text || ' Trade Date(' ||
                                     to_char(vd_valid_quote_date,
                                             'dd-Mon-RRRR') || ')';
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_concentrate_congprice',
                                                                   'PHY-002',
                                                                   vc_data_missing_for,
                                                                   '',
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
            
              sp_insert_error_log(vobj_error_log);
            end if;
          when others then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure sp_concentrate_congprice',
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
        --
        -- If Both Fixed and Unfixed Quantities are there then we have two prices
        -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
        --
        if vn_fixed_value > 0 and vn_unfixed_val_price > 0 then
          if vc_fixed_price_unit_id <> vc_unfixed_val_price_unit_id then
            select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                       vn_unfixed_val_price,
                                                                       vc_unfixed_val_price_unit_id,
                                                                       vc_fixed_price_unit_id,
                                                                       pd_trade_date,
                                                                       cur_gmr_rows.product_id)
              into vn_unfixed_val_price
              from dual;
          end if;
        
        end if;
        if vn_unfixed_qty > 0 then
          vn_unfixed_value := vn_unfixed_qty * vn_unfixed_val_price;
        else
          vn_unfixed_value := 0;
          vn_unfixed_qty   := 0;
        end if;
        if vn_fixed_qty < 0 then
          vn_fixed_value := 0;
          vn_fixed_qty   := 0;
        end if;
        vn_total_quantity := vn_fixed_qty + vn_unfixed_qty;
        if vc_fixed_price_unit_id is not null then
          vc_price_unit_id := vc_fixed_price_unit_id;
        else
          vc_price_unit_id := vc_unfixed_val_price_unit_id;
        end if;
        begin
          select ppu.product_price_unit_id
            into vc_price_unit_id
            from v_ppu_pum ppu
           where ppu.price_unit_id = vc_price_unit_id
             and ppu.product_id = cur_gmr_rows.product_id;
        exception
          when others then
            vc_price_unit_id := null;
        end;
        vn_total_contract_value := vn_total_contract_value +
                                   ((vn_qty_to_be_priced / 100) *
                                   (vn_fixed_value + vn_unfixed_value));
      end loop;
    
      vn_average_price := round(vn_total_contract_value / vn_total_quantity,
                                4);
      --
      -- Convert the final price into Base Price Unit 
      --
      begin
        select cm.cur_id,
               cm.cur_code,
               ppu.weight,
               ppu.weight_unit_id,
               qum.qty_unit
          into vc_price_cur_id,
               vc_price_cur_code,
               vn_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vn_price_weight_unit    := null;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
      if vn_average_price is not null and vc_price_unit_id is not null then
        insert into bgcp_base_gmr_cog_price
          (process_id,
           corporate_id,
           internal_gmr_ref_no,
           gmr_ref_no,
           qty,
           qty_unit_id,
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
           internal_grd_ref_no)
        values
          (pc_process_id,
           pc_corporate_id,
           cur_gmr_rows.internal_gmr_ref_no,
           cur_gmr_rows.gmr_ref_no,
           cur_gmr_rows.qty,
           cur_gmr_rows.qty_unit_id,
           vn_average_price,
           vc_price_unit_id,
           vc_price_cur_id,
           vc_price_cur_code,
           vn_price_weight_unit,
           vc_price_weight_unit_id,
           vn_price_weight_unit,
           vn_fixed_qty,
           vn_unfixed_qty,
           vc_price_basis,
           cur_gmr_rows.internal_grd_ref_no);
      end if;
    end loop;
    commit;
    sp_gather_stats('bgcp_base_gmr_cog_price');
  end;
  procedure sp_conc_contract_cog_price(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2,
                                       pc_dbd_id       varchar2,
                                       pc_process      varchar2) is
    ------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_conc_contract_cog_price
    --        Author                                    : Janna
    --        Created Date                              : 29th Mar 2012
    --        Purpose                                   : Calcualte COG Price for Concentrate Contract
    --
    --        Parameters
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------                                       
    cursor cur_pcdi is
      select pcdi.pcdi_id,
             pcdi.internal_contract_ref_no,
             dipq.element_id,
             dipq.payable_qty,
             dipq.qty_unit_id payable_qty_unit_id,
             pcdi.delivery_item_no,
             pcdi.basis_type,
             pcm.contract_ref_no,
             pcpd.product_id,
             aml.underlying_product_id,
             tt.instrument_id,
             tt.instrument_name,
             tt.price_source_id,
             tt.price_source_name,
             tt.available_price_id,
             tt.available_price_name,
             tt.price_unit_name,
             tt.price_unit_id,
             tt.delivery_calender_id,
             tt.is_daily_cal_applicable,
             tt.is_monthly_cal_applicable,
             dipq.price_option_call_off_status
        from pcdi_pc_delivery_item pcdi,
             dipq_delivery_item_payable_qty dipq,
             pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcpd_pc_product_definition pcpd,
             aml_attribute_master_list aml,
             (select qat.pcdi_id,
                     qat.element_id,
                     qat.instrument_id,
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
                from v_pcdi_exchange_detail       qat,
                     dim_der_instrument_master    dim,
                     div_der_instrument_valuation div,
                     ps_price_source              ps,
                     apm_available_price_master   apm,
                     pum_price_unit_master        pum,
                     v_der_instrument_price_unit  vdip,
                     pdc_prompt_delivery_calendar pdc
               where qat.instrument_id = dim.instrument_id
                 and dim.instrument_id = div.instrument_id
                 and div.is_deleted = 'N'
                 and div.price_source_id = ps.price_source_id
                 and div.available_price_id = apm.available_price_id
                 and div.price_unit_id = pum.price_unit_id
                 and dim.instrument_id = vdip.instrument_id
                 and dim.delivery_calender_id =
                     pdc.prompt_delivery_calendar_id
                 and qat.corporate_id = pc_corporate_id) tt
       where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and nvl(dipq.qty_type, 'Payable') = 'Payable'
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'CONCENTRATES'
         and pcpd.input_output = 'Input'
         and dipq.element_id = aml.attribute_id
         and dipq.pcdi_id = tt.pcdi_id(+)
         and dipq.element_id = tt.element_id(+)
         and pcdi.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and dipq.process_id = pc_process_id
         and pcdi.pcdi_id = dipq.pcdi_id
         and dipq.payable_qty > 0
         and pcpd.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pcm.is_active = 'Y'
         and dipq.is_active = 'Y';
    cursor cur_called_off(pc_pcdi_id varchar2, pc_element_id varchar2) is
      select poch.poch_id,
             pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
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
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
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
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vc_prompt_date_text          varchar2(100); -- Setting the decode to this variable to make the Beautifier work
    vn_contract_price            number;
    vc_price_unit_id             varchar2(15);
    vn_total_quantity            number;
    vn_total_contract_value      number;
    vn_qty_to_be_priced          number;
    vn_average_price             number;
    vc_price_basis               varchar2(15);
    vc_price_option_call_off_sts varchar2(50);
    vd_prompt_date               date;
    vd_valid_quote_date          date;
    vn_fixed_value               number;
    vn_fixed_qty                 number;
    vc_fixed_price_unit_id       varchar2(15);
    vn_unfixed_qty               number;
    vn_unfixed_val_price         number;
    vc_unfixed_val_price_unit_id varchar2(15);
    vn_forward_days              number;
    vd_quotes_date               date;
    vc_market_quote_dr_id        varchar2(15);
    vc_prompt_month              varchar2(15);
    vc_prompt_year               varchar2(15);
    vn_unfixed_value             number;
    vc_price_unit_cur_id         varchar2(15);
    vc_price_unit_cur_code       varchar2(15);
    vc_price_unit_weight_unit_id varchar2(15);
    vc_price_unit_weight_unit    varchar2(15);
    vn_price_unit_weight         number;
    vc_error_message             varchar2(100);
    vc_data_missing_for          varchar2(1000);
  begin
    vc_error_message := 'Start';
    for cur_pcdi_rows in cur_pcdi
    loop
      vn_total_contract_value      := 0;
      vn_fixed_qty                 := 0;
      vn_unfixed_qty               := 0;
      vn_fixed_value               := 0;
      vn_unfixed_value             := 0;
      vc_fixed_price_unit_id       := null;
      vc_unfixed_val_price_unit_id := null;
    
      vc_price_option_call_off_sts := cur_pcdi_rows.price_option_call_off_status;
      vn_total_contract_value      := 0;
      if vc_price_option_call_off_sts in ('Called Off', 'Not Applicable') then
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id,
                                                  cur_pcdi_rows.element_id)
        loop
          vc_price_basis := cur_called_off_rows.price_basis;
          if cur_called_off_rows.price_basis = 'Fixed' then
          
            vn_contract_price       := cur_called_off_rows.price_value;
            vn_total_quantity       := cur_pcdi_rows.payable_qty;
            vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_called_off_rows.price_unit_id;
          
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            vn_qty_to_be_priced := cur_called_off_rows.qty_to_be_priced;
            vn_total_quantity   := cur_pcdi_rows.payable_qty;
            for cc1 in (select pofh.pofh_id
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail pcbpd,
                               ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing pfqpp,
                               (select *
                                  from pofh_price_opt_fixation_header pfh
                                 where pfh.internal_gmr_ref_no is null
                                   and pfh.is_active = 'Y') pofh,
                               v_ppu_pum ppu
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
                           and pcbpd.process_id = pc_process_id
                           and pfqpp.process_id = pc_process_id
                           and ppfh.process_id = pc_process_id)
            loop
              vc_error_message := ' Line 240 ';
              begin
                select nvl(sum(pfd.user_price * pfd.qty_fixed), 0),
                       nvl(sum(pfd.qty_fixed), 0),
                       ppu.price_unit_id
                  into vn_fixed_value,
                       vn_fixed_qty,
                       vc_fixed_price_unit_id
                  from poch_price_opt_call_off_header poch,
                       pocd_price_option_calloff_dtls pocd,
                       pofh_price_opt_fixation_header pofh,
                       pfd_price_fixation_details     pfd,
                       v_ppu_pum                      ppu
                 where poch.poch_id = pocd.poch_id
                   and pocd.pocd_id = pofh.pocd_id
                   and pofh.pofh_id = cc1.pofh_id
                   and pofh.pofh_id = pfd.pofh_id
                   and pfd.hedge_correction_date <= pd_trade_date
                   and poch.is_active = 'Y'
                   and pocd.is_active = 'Y'
                   and pofh.is_active = 'Y'
                   and pfd.is_active = 'Y'
                   and ppu.product_price_unit_id = pfd.price_unit_id
                   and (nvl(pfd.user_price, 0) * nvl(pfd.qty_fixed, 0)) <> 0
                 group by ppu.price_unit_id;
              exception
                when others then
                  vn_fixed_value         := 0;
                  vn_fixed_qty           := 0;
                  vc_fixed_price_unit_id := null;
              end;
            end loop;
            vn_unfixed_qty := vn_total_quantity - vn_fixed_qty;
          
            if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
              vn_forward_days := 0;
              vd_quotes_date  := pd_trade_date + 1;
              while vn_forward_days <> 2
              loop
                if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                 where drm.instrument_id = cur_pcdi_rows.instrument_id
                   and drm.prompt_date = vd_quotes_date
                   and rownum <= 1
                   and drm.price_point_id is null
                   and drm.is_deleted = 'N';
              exception
                when no_data_found then
                  if vd_quotes_date is not null then
                    vobj_error_log.extend;
                    vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
                                           cur_pcdi_rows.instrument_name ||
                                           ',Price Source:' ||
                                           cur_pcdi_rows.price_source_name ||
                                           ' Contract Ref No: ' ||
                                           cur_pcdi_rows.contract_ref_no ||
                                           ',Price Unit:' ||
                                           cur_pcdi_rows.price_unit_name || ',' ||
                                           cur_pcdi_rows.available_price_name ||
                                           ' Price,Prompt Date:' ||
                                           to_char(vd_quotes_date,
                                                   'dd-Mon-RRRR');
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_concentrate_cog_price',
                                                                         'PHY-002',
                                                                         vc_data_missing_for,
                                                                         '',
                                                                         pc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                  end if;
              end;
            end if;
            if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
               cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
              vd_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                  pd_trade_date);
              vc_prompt_month := to_char(vd_prompt_date, 'Mon');
              vc_prompt_year  := to_char(vd_prompt_date, 'RRRR');
              begin
                select drm.dr_id
                  into vc_market_quote_dr_id
                  from drm_derivative_master drm
                 where drm.instrument_id = cur_pcdi_rows.instrument_id
                   and drm.period_month = vc_prompt_month
                   and drm.period_year = vc_prompt_year
                   and rownum <= 1
                   and drm.price_point_id is null
                   and drm.is_deleted = 'N';
              exception
                when no_data_found then
                  if vc_prompt_month is not null and
                     vc_prompt_year is not null then
                    vobj_error_log.extend;
                    vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
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
                                           vc_prompt_year;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_concentrate_cog_price',
                                                                         'PHY-002',
                                                                         vc_data_missing_for,
                                                                         '',
                                                                         pc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
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
                 and dq.instrument_id = cur_pcdi_rows.instrument_id
                 and dq.dbd_id = dqd.dbd_id
                 and dq.dbd_id = pc_dbd_id
                 and dqd.available_price_id =
                     cur_pcdi_rows.available_price_id
                 and dq.price_source_id = cur_pcdi_rows.price_source_id
                 and dqd.price_unit_id = cur_pcdi_rows.price_unit_id
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
                   and cdim.instrument_id = cur_pcdi_rows.instrument_id;
                if vd_quotes_date is not null then
                  vobj_error_log.extend;
                  vc_error_message := ' Line 391 ';
                  select (case
                           when cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                                cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                            to_char(vd_prompt_date, 'Mon-RRRR')
                           else
                            to_char(vd_quotes_date, 'dd-Mon-RRRR')
                         end)
                    into vc_prompt_date_text
                    from dual;
                  vc_data_missing_for := 'Price missing for ' ||
                                         cur_pcdi_rows.instrument_name ||
                                         ',Price Source:' ||
                                         cur_pcdi_rows.price_source_name ||
                                         ' Contract Ref No: ' ||
                                         cur_pcdi_rows.contract_ref_no ||
                                         ',Price Unit:' ||
                                         cur_pcdi_rows.price_unit_name || ',' ||
                                         cur_pcdi_rows.available_price_name ||
                                         ' Price,Prompt Date:' ||
                                         vc_prompt_date_text ||
                                         ' Trade Date(' ||
                                         to_char(vd_valid_quote_date,
                                                 'dd-Mon-RRRR') || ')';
                  vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                       'procedure sp_concentrate_congprice',
                                                                       'PHY-002',
                                                                       vc_data_missing_for,
                                                                       '',
                                                                       pc_process,
                                                                       pc_user_id,
                                                                       sysdate,
                                                                       pd_trade_date);
                
                  sp_insert_error_log(vobj_error_log);
                end if;
              when others then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_concentrate_congprice',
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
            --
            -- If Both Fixed and Unfixed Quantities are there then we have two prices
            -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
            --
            vc_error_message := ' Line 431 ';
            if vn_fixed_value > 0 and vn_unfixed_val_price > 0 then
              if vc_fixed_price_unit_id <> vc_unfixed_val_price_unit_id then
                select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                           vn_unfixed_val_price,
                                                                           vc_unfixed_val_price_unit_id,
                                                                           vc_fixed_price_unit_id,
                                                                           pd_trade_date,
                                                                           cur_pcdi_rows.product_id)
                  into vn_unfixed_val_price
                  from dual;
              end if;
            
            end if;
            vc_error_message := ' Line 444';
            if vn_unfixed_qty > 0 then
              vn_unfixed_value := vn_unfixed_qty * vn_unfixed_val_price;
            else
              vn_unfixed_value := 0;
              vn_unfixed_qty   := 0;
            end if;
            if vn_fixed_qty < 0 then
              vn_fixed_value := 0;
              vn_fixed_qty   := 0;
            end if;
            vn_total_quantity       := vn_fixed_qty + vn_unfixed_qty;
            vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       ((vn_qty_to_be_priced / 100) *
                                       (vn_fixed_value + vn_unfixed_value));
            if vc_fixed_price_unit_id is not null then
              vc_price_unit_id := vc_fixed_price_unit_id;
            else
              vc_price_unit_id := vc_unfixed_val_price_unit_id;
            end if;
            begin
              select ppu.product_price_unit_id
                into vc_price_unit_id
                from v_ppu_pum ppu
               where ppu.price_unit_id = vc_price_unit_id
                 and ppu.product_id = cur_pcdi_rows.product_id;
            exception
              when others then
                vc_price_unit_id := null;
              
            end;
          end if;
        end loop;
      
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  4);
      
      elsif vc_price_option_call_off_sts = 'Not Called Off' then
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.element_id)
        loop
          vc_price_basis := cur_not_called_off_rows.price_basis;
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_not_called_off_rows.price_value;
            vn_total_quantity       := cur_pcdi_rows.payable_qty;
            vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_not_called_off_rows.price_unit_id;
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
              vn_forward_days := 0;
              vd_quotes_date  := pd_trade_date + 1;
              while vn_forward_days <> 2
              loop
                if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                 where drm.instrument_id = cur_pcdi_rows.instrument_id
                   and drm.prompt_date = vd_quotes_date
                   and drm.price_point_id is null
                   and rownum <= 1
                   and drm.is_deleted = 'N';
              exception
                when no_data_found then
                  if vd_quotes_date is not null then
                    vobj_error_log.extend;
                    vc_data_missing_for := 'DR-ID missing for ' ||
                                           cur_pcdi_rows.instrument_name ||
                                           ',Price Source:' ||
                                           cur_pcdi_rows.price_source_name ||
                                           ' Contract Ref No: ' ||
                                           cur_pcdi_rows.contract_ref_no ||
                                           ',Price Unit:' ||
                                           cur_pcdi_rows.price_unit_name || ',' ||
                                           cur_pcdi_rows.available_price_name ||
                                           ' Price,Prompt Date:' ||
                                           to_char(vd_quotes_date,
                                                   'dd-Mon-RRRR');
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_conc_price',
                                                                         'PHY-002',
                                                                         vc_data_missing_for,
                                                                         '',
                                                                         pc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                  end if;
              end;
            end if;
            if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
               cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
            
              vd_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                  pd_trade_date);
              vc_prompt_month := to_char(vd_prompt_date, 'Mon');
              vc_prompt_year  := to_char(vd_prompt_date, 'RRRR');
              begin
                select drm.dr_id
                  into vc_market_quote_dr_id
                  from drm_derivative_master drm
                 where drm.instrument_id = cur_pcdi_rows.instrument_id
                   and drm.period_month = vc_prompt_month
                   and drm.period_year = vc_prompt_year
                   and drm.price_point_id is null
                   and rownum <= 1
                   and drm.is_deleted = 'N';
              exception
                when no_data_found then
                  if vc_prompt_month is not null and
                     vc_prompt_year is not null then
                    vobj_error_log.extend;
                    vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
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
                                           vc_prompt_year;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                         'procedure sp_calc_contract_conc_price',
                                                                         'PHY-002',
                                                                         vc_data_missing_for,
                                                                         '',
                                                                         pc_process,
                                                                         pc_user_id,
                                                                         sysdate,
                                                                         pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
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
                 and dq.process_id = pc_process_id
                 and dq.instrument_id = cur_pcdi_rows.instrument_id
                 and dq.process_id = dqd.process_id
                 and dqd.available_price_id =
                     cur_pcdi_rows.available_price_id
                 and dq.price_source_id = cur_pcdi_rows.price_source_id
                 and dqd.price_unit_id = cur_pcdi_rows.price_unit_id
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
                   and cdim.instrument_id = cur_pcdi_rows.instrument_id;
                if vd_quotes_date is not null then
                
                  vobj_error_log.extend;
                  select (case
                           when cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                                cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                            to_char(vd_prompt_date, 'Mon-RRRR')
                           else
                            to_char(vd_quotes_date, 'dd-Mon-RRRR')
                         end)
                    into vc_prompt_date_text
                    from dual;
                  vc_data_missing_for := 'Price missing for ' ||
                                         cur_pcdi_rows.instrument_name ||
                                         ',Price Source:' ||
                                         cur_pcdi_rows.price_source_name ||
                                         ' Contract Ref No: ' ||
                                         cur_pcdi_rows.contract_ref_no ||
                                         ',Price Unit:' ||
                                         cur_pcdi_rows.price_unit_name || ',' ||
                                         cur_pcdi_rows.available_price_name ||
                                         ' Price,Prompt Date:' ||
                                         vc_prompt_date_text ||
                                         ' Trade Date(' ||
                                         to_char(vd_valid_quote_date,
                                                 'dd-Mon-RRRR') || ')';
                  vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                       'procedure sp_calc_contract_conc_price',
                                                                       'PHY-002',
                                                                       vc_data_missing_for,
                                                                       '',
                                                                       pc_process,
                                                                       pc_user_id,
                                                                       sysdate,
                                                                       pd_trade_date);
                  sp_insert_error_log(vobj_error_log);
                end if;
              when others then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_calc_contract_conc_price',
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
            vn_total_quantity       := cur_pcdi_rows.payable_qty;
            vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       (vn_total_quantity *
                                       ((vn_qty_to_be_priced / 100) *
                                       vn_unfixed_val_price));
            vc_error_message        := ' Line 641 ';
            begin
              select ppu.product_price_unit_id
                into vc_price_unit_id
                from v_ppu_pum ppu
               where ppu.price_unit_id = vc_unfixed_val_price_unit_id
                 and ppu.product_id = cur_pcdi_rows.product_id;
            exception
              when others then
                vc_price_unit_id := null;
            end;
            vc_error_message := ' Line 647 ';
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  4);
      
      end if;
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
      vc_error_message := ' Line 676 ';
      if vn_average_price is not null and vc_price_unit_id is not null then
        insert into cccp_conc_contract_cog_price
          (process_id,
           corporate_id,
           pcdi_id,
           internal_contract_ref_no,
           contract_ref_no,
           element_id,
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
           price_basis)
        values
          (pc_process_id,
           pc_corporate_id,
           cur_pcdi_rows.pcdi_id,
           cur_pcdi_rows.internal_contract_ref_no,
           cur_pcdi_rows.contract_ref_no,
           cur_pcdi_rows.element_id,
           cur_pcdi_rows.payable_qty,
           cur_pcdi_rows.payable_qty_unit_id,
           vn_average_price,
           vc_price_unit_id,
           vc_price_unit_cur_id,
           vc_price_unit_cur_code,
           vn_price_unit_weight,
           vc_price_unit_weight_unit_id,
           vc_price_unit_weight_unit,
           vn_fixed_qty,
           vn_unfixed_qty,
           vc_price_basis);
      end if;
    end loop;
    commit;
    sp_gather_stats('cccp_conc_contract_cog_price');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_conc_contract_cog_price contract price',
                                                           'M2M-013',
                                                           ' Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm ||
                                                           dbms_utility.format_error_backtrace ||
                                                           vc_error_message,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
      commit;
  end;
  procedure sp_conc_gmr_cog_price(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process_id   varchar2,
                                  pc_user_id      varchar2,
                                  pc_dbd_id       varchar2,
                                  pc_process      varchar2) is
    ------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_conc_gmr_cog_price
    --        Author                                    : Janna
    --        Created Date                              : 29th Mar 2012
    --        Purpose                                   : Calcualte COG Price for Concentrate GMRS
    --
    --        parameters
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------                                       
  
    cursor cur_gmr is
      select gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             grd.product_id,
             grd.internal_grd_ref_no internal_grd_ref_no,
             tt.instrument_id,
             tt.instrument_name,
             tt.price_source_id,
             tt.price_source_name,
             tt.available_price_id,
             tt.available_price_name,
             tt.price_unit_name,
             tt.ppu_price_unit_id,
             tt.price_unit_id,
             tt.delivery_calender_id,
             tt.is_daily_cal_applicable,
             tt.is_monthly_cal_applicable,
             spq.element_id,
             spq.payable_qty,
             spq.qty_unit_id payable_qty_unit_id
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.internal_grd_ref_no,
                     grd.quality_id,
                     grd.product_id
                from grd_goods_record_detail grd
               where grd.process_id = pc_process_id
                 and grd.status = 'Active'
                 and grd.tolling_stock_type in ('None Tolling')
                 and grd.is_deleted = 'N'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id,
                        grd.internal_grd_ref_no) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             v_gmr_payable_qty spq,
             (select qat.process_id,
                     qat.internal_gmr_ref_no,
                     qat.instrument_id,
                     qat.element_id,
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
                from v_gmr_exchange_detail        qat,
                     dim_der_instrument_master    dim,
                     div_der_instrument_valuation div,
                     ps_price_source              ps,
                     apm_available_price_master   apm,
                     pum_price_unit_master        pum,
                     v_der_instrument_price_unit  vdip,
                     pdc_prompt_delivery_calendar pdc
               where qat.instrument_id = dim.instrument_id
                 and dim.instrument_id = div.instrument_id
                 and div.is_deleted = 'N'
                 and div.price_source_id = ps.price_source_id
                 and div.available_price_id = apm.available_price_id
                 and div.price_unit_id = pum.price_unit_id
                 and dim.instrument_id = vdip.instrument_id
                 and dim.delivery_calender_id =
                     pdc.prompt_delivery_calendar_id) tt
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdtm.product_type_name = 'Composite'
         and spq.process_id = pc_process_id
         and tt.element_id = spq.element_id
         and tt.internal_gmr_ref_no = spq.internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
         and gmr.process_id = tt.process_id(+)
         and gmr.is_deleted = 'N'
         and spq.payable_qty > 0
      union all
      select gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             grd.product_id,
             grd.internal_dgrd_ref_no internal_grd_ref_no,
             tt.instrument_id,
             tt.instrument_name,
             tt.price_source_id,
             tt.price_source_name,
             tt.available_price_id,
             tt.available_price_name,
             tt.price_unit_name,
             tt.ppu_price_unit_id,
             tt.price_unit_id,
             tt.delivery_calender_id,
             tt.is_daily_cal_applicable,
             tt.is_monthly_cal_applicable,
             spq.element_id,
             spq.payable_qty,
             spq.qty_unit_id payable_qty_unit_id
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.internal_dgrd_ref_no,
                     grd.quality_id,
                     grd.product_id
                from dgrd_delivered_grd grd
               where grd.process_id = pc_process_id
                 and grd.status = 'Active'
                 and grd.tolling_stock_type in ('None Tolling')
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id,
                        grd.internal_dgrd_ref_no) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             v_gmr_payable_qty spq,
             (select qat.process_id,
                     qat.internal_gmr_ref_no,
                     qat.instrument_id,
                     qat.element_id,
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
                from v_gmr_exchange_detail        qat,
                     dim_der_instrument_master    dim,
                     div_der_instrument_valuation div,
                     ps_price_source              ps,
                     apm_available_price_master   apm,
                     pum_price_unit_master        pum,
                     v_der_instrument_price_unit  vdip,
                     pdc_prompt_delivery_calendar pdc
               where qat.instrument_id = dim.instrument_id
                 and dim.instrument_id = div.instrument_id
                 and div.is_deleted = 'N'
                 and div.price_source_id = ps.price_source_id
                 and div.available_price_id = apm.available_price_id
                 and div.price_unit_id = pum.price_unit_id
                 and dim.instrument_id = vdip.instrument_id
                 and dim.delivery_calender_id =
                     pdc.prompt_delivery_calendar_id) tt
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdm.product_type_id = 'Composite'
         and spq.process_id = pc_process_id
         and tt.element_id = spq.element_id
         and tt.internal_gmr_ref_no = spq.internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
         and gmr.process_id = tt.process_id(+)
         and gmr.is_deleted = 'N'
         and spq.payable_qty > 0;
  
    cursor cur_gmr_ele(pc_internal_gmr_ref_no varchar2, pc_element_id varchar2) is
      select pofh.internal_gmr_ref_no,
             pofh.pofh_id,
             pcbpd.element_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pcbpd.price_basis,
             pdm.product_id,
             pdm.base_quantity_unit base_qty_unit_id
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             aml_attribute_master_list      aml,
             pdm_productmaster              pdm
       where pofh.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pcbpd.element_id = pc_element_id
         and pcbpd.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y'
         and pcbpd.element_id = aml.attribute_id
         and aml.underlying_product_id = pdm.product_id;
  
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vd_quotes_date               date;
    vn_total_contract_value      number;
    vc_price_cur_id              varchar2(15);
    vc_price_cur_code            varchar2(15);
    vn_price_weight_unit         number;
    vc_price_weight_unit_id      varchar2(15);
    vc_price_qty_unit            varchar2(15);
    vc_price_unit_id             varchar2(15);
    vc_pcbpd_id                  varchar2(15);
    vc_prompt_month              varchar2(15);
    vc_prompt_year               number;
    vn_qty_to_be_priced          number;
    vn_total_quantity            number;
    vn_average_price             number;
    vc_price_basis               varchar2(15);
    vd_valid_quote_date          date;
    vn_fixed_value               number;
    vn_unfixed_value             number;
    vn_fixed_qty                 number;
    vn_unfixed_qty               number;
    vn_forward_days              number;
    vc_market_quote_dr_id        varchar2(15);
    vd_prompt_date               date;
    vn_unfixed_val_price         number;
    vc_unfixed_val_price_unit_id varchar2(15);
    vc_prompt_date_text          varchar2(100); -- Setting the decode to this variable to make the Beautifier work
    vc_fixed_price_unit_id       varchar2(15);
    vc_data_missing_for          varchar2(1000);
  begin
  
    for cur_gmr_rows in cur_gmr
    loop
      vn_total_contract_value      := 0;
      vn_fixed_qty                 := 0;
      vn_unfixed_qty               := 0;
      vn_fixed_value               := 0;
      vn_unfixed_value             := 0;
      vc_unfixed_val_price_unit_id := null;
      vc_unfixed_val_price_unit_id := null;
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no,
                                          cur_gmr_rows.element_id)
      loop
      
        vc_price_basis := cur_gmr_ele_rows.price_basis;
        vc_pcbpd_id    := cur_gmr_ele_rows.pcbpd_id;
      
        begin
          select nvl(sum((pfd.user_price * pfd.qty_fixed)), 0),
                 nvl(sum(pfd.qty_fixed), 0),
                 ppu.price_unit_id
            into vn_fixed_value,
                 vn_fixed_qty,
                 vc_fixed_price_unit_id
            from poch_price_opt_call_off_header poch,
                 pocd_price_option_calloff_dtls pocd,
                 pofh_price_opt_fixation_header pofh,
                 pfd_price_fixation_details     pfd,
                 v_ppu_pum                      ppu
           where poch.poch_id = pocd.poch_id
             and pocd.pocd_id = pofh.pocd_id
             and pofh.pofh_id = cur_gmr_ele_rows.pofh_id
             and pofh.pofh_id = pfd.pofh_id
             and pfd.hedge_correction_date <= pd_trade_date
             and poch.is_active = 'Y'
             and pocd.is_active = 'Y'
             and pofh.is_active = 'Y'
             and pfd.is_active = 'Y'
             and ppu.product_price_unit_id = pfd.price_unit_id
             and (nvl(pfd.user_price, 0) * nvl(pfd.qty_fixed, 0)) <> 0
           group by ppu.price_unit_id;
        exception
          when others then
            vn_fixed_value         := 0;
            vn_fixed_qty           := 0;
            vc_fixed_price_unit_id := null;
        end;
      
        vn_qty_to_be_priced := cur_gmr_ele_rows.qty_to_be_priced;
        vn_unfixed_qty      := cur_gmr_rows.payable_qty - vn_fixed_qty;
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          vn_forward_days := 0;
          vd_quotes_date  := pd_trade_date + 1;
          while vn_forward_days <> 2
          loop
            if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
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
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.prompt_date = vd_quotes_date
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              if vd_quotes_date is not null then
                vobj_error_log.extend;
                vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
                                       cur_gmr_rows.instrument_name ||
                                       ',Price Source:' ||
                                       cur_gmr_rows.price_source_name ||
                                       ' GMR Ref No: ' ||
                                       cur_gmr_rows.gmr_ref_no ||
                                       ',Price Unit:' ||
                                       cur_gmr_rows.price_unit_name || ',' ||
                                       cur_gmr_rows.available_price_name ||
                                       ' Price,Prompt Date:' ||
                                       to_char(vd_quotes_date,
                                               'dd-Mon-RRRR');
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_conc_contract_cog_price',
                                                                     'PHY-002',
                                                                     vc_data_missing_for,
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
              end if;
          end;
        end if;
        if cur_gmr_rows.is_daily_cal_applicable = 'N' and
           cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
          vd_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                              pd_trade_date);
          vc_prompt_month := to_char(vd_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vd_prompt_date, 'RRRR');
          begin
            select drm.dr_id
              into vc_market_quote_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.period_month = vc_prompt_month
               and drm.period_year = vc_prompt_year
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
            
              if vc_prompt_month is not null and vc_prompt_year is not null then
                vobj_error_log.extend;
                vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
                                       cur_gmr_rows.instrument_name ||
                                       ',Price Source:' ||
                                       cur_gmr_rows.price_source_name ||
                                       ' GMR Ref No: ' ||
                                       cur_gmr_rows.gmr_ref_no ||
                                       ',Price Unit:' ||
                                       cur_gmr_rows.price_unit_name || ',' ||
                                       cur_gmr_rows.available_price_name ||
                                       ' Price,Prompt Date:' ||
                                       vc_prompt_month || ' ' ||
                                       vc_prompt_year;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_concentrate_cog_price',
                                                                     'PHY-002',
                                                                     vc_data_missing_for,
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
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
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dq.dbd_id = dqd.dbd_id
             and dq.dbd_id = pc_dbd_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dqd.price_unit_id = cur_gmr_rows.price_unit_id
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
               and cdim.instrument_id = cur_gmr_rows.instrument_id;
            if vd_quotes_date is not null then
              vobj_error_log.extend;
              select (case
                       when cur_gmr_rows.is_daily_cal_applicable = 'N' and
                            cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
                        to_char(vd_prompt_date, 'Mon-RRRR')
                       else
                        to_char(vd_quotes_date, 'dd-Mon-RRRR')
                     end)
                into vc_prompt_date_text
                from dual;
              vc_data_missing_for := 'Price missing for ' ||
                                     cur_gmr_rows.instrument_name ||
                                     ',Price Source:' ||
                                     cur_gmr_rows.price_source_name ||
                                     ',Price Unit:' ||
                                     cur_gmr_rows.price_unit_name || ',' ||
                                     cur_gmr_rows.available_price_name ||
                                     ' Price,Prompt Date:' ||
                                     vc_prompt_date_text || ' Trade Date(' ||
                                     to_char(vd_valid_quote_date,
                                             'dd-Mon-RRRR') || ')';
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_concentrate_congprice',
                                                                   'PHY-002',
                                                                   vc_data_missing_for,
                                                                   '',
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            end if;
          when others then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure sp_concentrate_congprice',
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
        --
        -- If Both Fixed and Unfixed Quantities are there then we have two prices
        -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
        --
        if vn_fixed_value > 0 and vn_unfixed_val_price > 0 then
          if vc_fixed_price_unit_id <> vc_unfixed_val_price_unit_id then
            select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                       vn_unfixed_val_price,
                                                                       vc_unfixed_val_price_unit_id,
                                                                       vc_fixed_price_unit_id,
                                                                       pd_trade_date,
                                                                       cur_gmr_rows.product_id)
              into vn_unfixed_val_price
              from dual;
          end if;
        
        end if;
        if vn_unfixed_qty > 0 then
          vn_unfixed_value := vn_unfixed_qty * vn_unfixed_val_price;
        else
          vn_unfixed_value := 0;
          vn_unfixed_qty   := 0;
        end if;
        if vn_fixed_qty < 0 then
          vn_fixed_value := 0;
          vn_fixed_qty   := 0;
        end if;
      
        if vc_fixed_price_unit_id is not null then
          vc_price_unit_id := vc_fixed_price_unit_id;
        else
          vc_price_unit_id := vc_unfixed_val_price_unit_id;
        end if;
        begin
          select ppu.product_price_unit_id
            into vc_price_unit_id
            from v_ppu_pum ppu
           where ppu.price_unit_id = vc_price_unit_id
             and ppu.product_id = cur_gmr_rows.product_id;
        exception
          when others then
            vc_price_unit_id := null;
        end;
        --vn_total_quantity       := cur_gmr_rows.payable_qty;
        vn_total_quantity       := vn_fixed_qty + vn_unfixed_qty;
        vn_total_contract_value := vn_total_contract_value +
                                   ((vn_qty_to_be_priced / 100) *
                                   (vn_fixed_value + vn_unfixed_value));
      
      end loop;
      vn_average_price := round(vn_total_contract_value / vn_total_quantity,
                                4);
      begin
        select cm.cur_id,
               cm.cur_code,
               ppu.weight,
               ppu.weight_unit_id,
               qum.qty_unit
          into vc_price_cur_id,
               vc_price_cur_code,
               vn_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vn_price_weight_unit    := null;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
      if vn_average_price is not null and vc_price_unit_id is not null then
        insert into cgcp_conc_gmr_cog_price
          (process_id,
           corporate_id,
           internal_gmr_ref_no,
           gmr_ref_no,
           element_id,
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
           internal_grd_ref_no)
        values
          (pc_process_id,
           pc_corporate_id,
           cur_gmr_rows.internal_gmr_ref_no,
           cur_gmr_rows.gmr_ref_no,
           cur_gmr_rows.element_id,
           cur_gmr_rows.payable_qty,
           cur_gmr_rows.payable_qty_unit_id,
           vn_average_price,
           vc_price_unit_id,
           vc_price_cur_id,
           vc_price_cur_code,
           vn_price_weight_unit,
           vc_price_weight_unit_id,
           vn_price_weight_unit,
           vn_fixed_qty,
           vn_unfixed_qty,
           vc_price_basis,
           cur_gmr_rows.internal_grd_ref_no);
      end if;
    end loop;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_physical_process contract price',
                                                           'M2M-013',
                                                           ' Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm ||
                                                           dbms_utility.format_error_backtrace,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
      commit;
  end;
  procedure sp_conc_gmr_allocation_price(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_dbd_id       varchar2,
                                         pc_process      varchar2) is
    ------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_conc_gmr_allocation_price
    --        Author                                    : Janna
    --        Created Date                              : 08th Nov 2012
    --        Purpose                                   : Calcualte COG Price for Price Allocation GMRs
    --
    --        parameters
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------                                       
  
    cursor cur_gmr is
      select gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             grd.product_id,
             grd.internal_grd_ref_no internal_grd_ref_no,
             tt.instrument_id,
             tt.instrument_name,
             tt.price_source_id,
             tt.price_source_name,
             tt.available_price_id,
             tt.available_price_name,
             tt.price_unit_name,
             tt.ppu_price_unit_id,
             tt.price_unit_id,
             tt.delivery_calender_id,
             tt.is_daily_cal_applicable,
             tt.is_monthly_cal_applicable,
             spq.element_id,
             spq.payable_qty,
             spq.qty_unit_id payable_qty_unit_id
        from (select grd.internal_gmr_ref_no,
                     grd.internal_grd_ref_no,
                     grd.quality_id,
                     grd.product_id
                from grd_goods_record_detail grd
               where grd.process_id = pc_process_id
                 and grd.status = 'Active'
                 and grd.tolling_stock_type in ('None Tolling')
                 and grd.is_deleted = 'N'
              union
              select grd.internal_gmr_ref_no,
                     grd.internal_dgrd_ref_no internal_grd_ref_no,
                     grd.quality_id,
                     grd.product_id
                from dgrd_delivered_grd grd
               where grd.process_id = pc_process_id
                 and grd.status = 'Active'
                 and grd.tolling_stock_type in ('None Tolling')) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             v_gmr_payable_qty spq,
             gmr_goods_movement_record gmr,
             (select qat.internal_gmr_ref_no,
                     qat.instrument_id,
                     qat.element_id,
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
                from page_price_alloc_gmr_exchange qat,
                     dim_der_instrument_master     dim,
                     div_der_instrument_valuation  div,
                     ps_price_source               ps,
                     apm_available_price_master    apm,
                     pum_price_unit_master         pum,
                     v_der_instrument_price_unit   vdip,
                     pdc_prompt_delivery_calendar  pdc
               where qat.instrument_id = dim.instrument_id
                 and dim.instrument_id = div.instrument_id
                 and div.is_deleted = 'N'
                 and div.price_source_id = ps.price_source_id
                 and div.available_price_id = apm.available_price_id
                 and div.price_unit_id = pum.price_unit_id
                 and dim.instrument_id = vdip.instrument_id
                 and dim.delivery_calender_id =
                     pdc.prompt_delivery_calendar_id
                 and qat.process_id = pc_process_id) tt
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdtm.product_type_name = 'Composite'
         and spq.process_id = pc_process_id
         and tt.element_id = spq.element_id
         and tt.internal_gmr_ref_no = spq.internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and grd.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
         and gmr.is_deleted = 'N'
         and spq.payable_qty > 0;
    cursor cur_gmr_ele(pc_internal_gmr_ref_no varchar2, pc_element_id varchar2) is
      select gpah.internal_gmr_ref_no,
             pcbpd.element_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pcbpd.price_basis,
             pdm.product_id,
             pdm.base_quantity_unit base_qty_unit_id,
             gpah.gpah_id
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             gpah_gmr_price_alloc_header    gpah,
             gpad_gmr_price_alloc_dtls      gpad,
             pcdi_pc_delivery_item          pcdi,
             aml_attribute_master_list      aml,
             pdm_productmaster              pdm
       where poch.poch_id = pocd.poch_id
         and gpad.pfd_id = pfd.pfd_id
         and pcdi.pcdi_id = poch.pcdi_id
         and pocd.pocd_id = pofh.pocd_id(+)
         and pcbpd.pcbpd_id = pocd.pcbpd_id
         and pofh.pofh_id = pfd.pofh_id(+)
         and pfd.is_active(+) = 'Y'
         and pofh.is_active(+) = 'Y'
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pocd.pocd_id = gpah.pocd_id
         and pocd.is_active = 'Y'
         and poch.is_active = 'Y'
         and gpah.is_active = 'Y'
         and gpad.is_active = 'Y'
         and pcdi.price_allocation_method = 'Price Allocation'
         and nvl(pocd.is_any_day_pricing, 'N') = 'Y'
         and pcbpd.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pcbpd.element_id = aml.attribute_id
         and aml.underlying_product_id = pdm.product_id
         and gpah.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and pcbpd.element_id = pc_element_id
         and gpah.element_id = poch.element_id
         and gpad.gpah_id = gpah.gpah_id
       group by gpah.internal_gmr_ref_no,
                pofh.pofh_id,
                pcbpd.element_id,
                pcbpd.pcbpd_id,
                pcbpd.qty_to_be_priced,
                pcbpd.price_basis,
                pdm.product_id,
                pdm.base_quantity_unit,
                gpah.gpah_id
      union
      select grd.internal_gmr_ref_no,
             pcbpd.element_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pcbpd.price_basis,
             pdm.product_id,
             pdm.base_quantity_unit base_qty_unit_id,
             null gpah_id
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             pcdi_pc_delivery_item          pcdi,
             aml_attribute_master_list      aml,
             pdm_productmaster              pdm,
             grd_goods_record_detail        grd
       where poch.poch_id = pocd.poch_id
         and pcdi.pcdi_id = poch.pcdi_id
         and pocd.pocd_id = pofh.pocd_id
         and pcbpd.pcbpd_id = pocd.pcbpd_id
         and pofh.pofh_id = pfd.pofh_id(+)
         and pfd.is_active(+) = 'Y'
         and pofh.is_active(+) = 'Y'
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pocd.is_active = 'Y'
         and poch.is_active = 'Y'
         and pcdi.price_allocation_method = 'Price Allocation'
         and nvl(pocd.is_any_day_pricing, 'N') = 'Y'
         and pcbpd.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pcbpd.element_id = aml.attribute_id
         and aml.underlying_product_id = pdm.product_id
         and pcbpd.element_id = pc_element_id
         and grd.pcdi_id = pcdi.pcdi_id
         and grd.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and grd.process_id = pc_process_id
         and not exists
       (select *
                from gpah_gmr_price_alloc_header gpah
               where gpah.is_active = 'Y'
                 and gpah.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and gpah.element_id = pcbpd.element_id)
       group by grd.internal_gmr_ref_no,
                pofh.pofh_id,
                pcbpd.element_id,
                pcbpd.pcbpd_id,
                pcbpd.qty_to_be_priced,
                pcbpd.price_basis,
                pdm.product_id,
                pdm.base_quantity_unit;
  
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vd_quotes_date               date;
    vn_total_contract_value      number;
    vc_price_cur_id              varchar2(15);
    vc_price_cur_code            varchar2(15);
    vn_price_weight_unit         number;
    vc_price_weight_unit_id      varchar2(15);
    vc_price_qty_unit            varchar2(15);
    vc_price_unit_id             varchar2(15);
    vc_pcbpd_id                  varchar2(15);
    vc_prompt_month              varchar2(15);
    vc_prompt_year               number;
    vn_qty_to_be_priced          number;
    vn_total_quantity            number;
    vn_average_price             number;
    vc_price_basis               varchar2(15);
    vd_valid_quote_date          date;
    vn_fixed_value               number;
    vn_unfixed_value             number;
    vn_fixed_qty                 number;
    vn_unfixed_qty               number;
    vn_forward_days              number;
    vc_market_quote_dr_id        varchar2(15);
    vd_prompt_date               date;
    vn_unfixed_val_price         number;
    vc_unfixed_val_price_unit_id varchar2(15);
    vc_prompt_date_text          varchar2(100); -- Setting the decode to this variable to make the Beautifier work
    vc_fixed_price_unit_id       varchar2(15);
    vc_data_missing_for          varchar2(1000);
  begin
    --
    -- Populate Price Allocation GMR Exchange Details
    --
    insert into page_price_alloc_gmr_exchange
      (process_id,
       internal_gmr_ref_no,
       instrument_id,
       instrument_name,
       derivative_def_id,
       derivative_def_name,
       exchange_id,
       exchange_name,
       element_id)
      select pcdi.process_id,
             gpah.internal_gmr_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             emt.exchange_id,
             emt.exchange_name,
             pcbpd.element_id
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             gpah_gmr_price_alloc_header    gpah,
             gpad_gmr_price_alloc_dtls      gpad,
             pcdi_pc_delivery_item          pcdi,
             ppfh_phy_price_formula_header  ppfh,
             ppfd_phy_price_formula_details ppfd,
             dim_der_instrument_master      dim,
             pdd_product_derivative_def     pdd,
             emt_exchangemaster             emt
       where poch.poch_id = pocd.poch_id
         and gpad.pfd_id = pfd.pfd_id
         and pcdi.pcdi_id = poch.pcdi_id
         and pocd.pocd_id = pofh.pocd_id(+)
         and pcbpd.pcbpd_id = pocd.pcbpd_id
         and pofh.pofh_id = pfd.pofh_id(+)
         and pfd.is_active(+) = 'Y'
         and pofh.is_active(+) = 'Y'
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pocd.pocd_id = gpah.pocd_id
         and pocd.is_active = 'Y'
         and poch.is_active = 'Y'
         and gpah.is_active = 'Y'
         and gpad.is_active = 'Y'
         and pcdi.price_allocation_method = 'Price Allocation'
         and nvl(pocd.is_any_day_pricing, 'N') = 'Y'
         and pcbpd.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and ppfd.process_id = pc_process_id
         and ppfh.process_id = pc_process_id
         and pcbpd.pcbpd_id = ppfh.pcbpd_id
         and ppfh.ppfh_id = ppfd.ppfh_id
         and ppfd.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.exchange_id = emt.exchange_id(+)
         and gpad.gpah_id = gpah.gpah_id
       group by pcdi.process_id,
                gpah.internal_gmr_ref_no,
                ppfd.instrument_id,
                dim.instrument_name,
                pdd.derivative_def_id,
                pdd.derivative_def_name,
                emt.exchange_id,
                emt.exchange_name,
                pcbpd.element_id;
    commit;
    --
    -- Populate Price Allocation GMR Exchange Details where it is not allocated
    --
    insert into page_price_alloc_gmr_exchange
      (process_id,
       internal_gmr_ref_no,
       instrument_id,
       instrument_name,
       derivative_def_id,
       derivative_def_name,
       exchange_id,
       exchange_name,
       element_id)
      select pcdi.process_id,
             grd.internal_gmr_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             emt.exchange_id,
             emt.exchange_name,
             pcbpd.element_id
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             pcdi_pc_delivery_item          pcdi,
             ppfh_phy_price_formula_header  ppfh,
             ppfd_phy_price_formula_details ppfd,
             dim_der_instrument_master      dim,
             pdd_product_derivative_def     pdd,
             emt_exchangemaster             emt,
             grd_goods_record_detail        grd
       where poch.poch_id = pocd.poch_id
         and pcdi.pcdi_id = poch.pcdi_id
         and pocd.pocd_id = pofh.pocd_id(+)
         and pcbpd.pcbpd_id = pocd.pcbpd_id
         and pofh.pofh_id = pfd.pofh_id(+)
         and pfd.is_active(+) = 'Y'
         and pofh.is_active(+) = 'Y'
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pocd.is_active = 'Y'
         and poch.is_active = 'Y'
         and pcdi.price_allocation_method = 'Price Allocation'
         and nvl(pocd.is_any_day_pricing, 'N') = 'Y'
         and pcbpd.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and ppfd.process_id = pc_process_id
         and ppfh.process_id = pc_process_id
         and pcbpd.pcbpd_id = ppfh.pcbpd_id
         and ppfh.ppfh_id = ppfd.ppfh_id
         and ppfd.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.exchange_id = emt.exchange_id(+)
         and grd.pcdi_id = pcdi.pcdi_id
         and grd.process_id = pc_process_id
         and not exists
       (select *
                from gpah_gmr_price_alloc_header gpah
               where gpah.is_active = 'Y'
                 and gpah.element_id = poch.element_id
                 and gpah.internal_gmr_ref_no = grd.internal_gmr_ref_no)
       group by pcdi.process_id,
                grd.internal_gmr_ref_no,
                ppfd.instrument_id,
                dim.instrument_name,
                pdd.derivative_def_id,
                pdd.derivative_def_name,
                emt.exchange_id,
                emt.exchange_name,
                pcbpd.element_id,
                pcdi.pcdi_id;
    commit;
    for cur_gmr_rows in cur_gmr
    loop
      vn_total_contract_value      := 0;
      vn_fixed_qty                 := 0;
      vn_unfixed_qty               := 0;
      vn_fixed_value               := 0;
      vn_unfixed_value             := 0;
      vc_unfixed_val_price_unit_id := null;
      vc_unfixed_val_price_unit_id := null;
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no,
                                          cur_gmr_rows.element_id)
      loop
      
        vc_price_basis := cur_gmr_ele_rows.price_basis;
        vc_pcbpd_id    := cur_gmr_ele_rows.pcbpd_id;
      
        begin
          select nvl(sum((pfd.user_price * gpad.allocated_qty)), 0),
                 nvl(sum(gpad.allocated_qty), 0),
                 ppu.price_unit_id
            into vn_fixed_value,
                 vn_fixed_qty,
                 vc_fixed_price_unit_id
            from poch_price_opt_call_off_header poch,
                 pocd_price_option_calloff_dtls pocd,
                 pofh_price_opt_fixation_header pofh,
                 pfd_price_fixation_details     pfd,
                 pcbpd_pc_base_price_detail     pcbpd,
                 pcbph_pc_base_price_header     pcbph,
                 gpah_gmr_price_alloc_header    gpah,
                 gpad_gmr_price_alloc_dtls      gpad,
                 pcdi_pc_delivery_item          pcdi,
                 v_ppu_pum                      ppu
           where poch.poch_id = pocd.poch_id
             and gpad.pfd_id = pfd.pfd_id
             and pcdi.pcdi_id = poch.pcdi_id
             and pocd.pocd_id = pofh.pocd_id(+)
             and pcbpd.pcbpd_id = pocd.pcbpd_id
             and pofh.pofh_id = pfd.pofh_id(+)
             and pfd.is_active(+) = 'Y'
             and pofh.is_active(+) = 'Y'
             and pcbpd.pcbph_id = pcbph.pcbph_id
             and pocd.pocd_id = gpah.pocd_id
             and pocd.is_active = 'Y'
             and poch.is_active = 'Y'
             and gpah.is_active = 'Y'
             and gpad.is_active = 'Y'
             and pcbpd.process_id = pc_process_id
             and pcbph.process_id = pc_process_id
             and pcdi.process_id = pc_process_id
             and ppu.product_price_unit_id = pfd.price_unit_id
             and gpah.gpah_id = gpad.gpah_id
             and gpah.element_id = poch.element_id
             and (nvl(pfd.user_price, 0) * nvl(gpad.allocated_qty, 0)) <> 0
             and gpah.gpah_id = cur_gmr_ele_rows.gpah_id
             and pfd.hedge_correction_date <= pd_trade_date
           group by ppu.price_unit_id;
        exception
          when others then
            vn_fixed_value         := 0;
            vn_fixed_qty           := 0;
            vc_fixed_price_unit_id := null;
        end;
        vn_qty_to_be_priced := cur_gmr_ele_rows.qty_to_be_priced;
        vn_unfixed_qty      := cur_gmr_rows.payable_qty - vn_fixed_qty;
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          vn_forward_days := 0;
          vd_quotes_date  := pd_trade_date + 1;
          while vn_forward_days <> 2
          loop
            if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
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
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.prompt_date = vd_quotes_date
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              if vd_quotes_date is not null then
                vobj_error_log.extend;
                vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
                                       cur_gmr_rows.instrument_name ||
                                       ',Price Source:' ||
                                       cur_gmr_rows.price_source_name ||
                                       ' GMR Ref No: ' ||
                                       cur_gmr_rows.gmr_ref_no ||
                                       ',Price Unit:' ||
                                       cur_gmr_rows.price_unit_name || ',' ||
                                       cur_gmr_rows.available_price_name ||
                                       ' Price,Prompt Date:' ||
                                       to_char(vd_quotes_date,
                                               'dd-Mon-RRRR');
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_conc_gmr_allocation_price',
                                                                     'PHY-002',
                                                                     vc_data_missing_for,
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
              end if;
          end;
        end if;
        if cur_gmr_rows.is_daily_cal_applicable = 'N' and
           cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
          vd_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                              pd_trade_date);
          vc_prompt_month := to_char(vd_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vd_prompt_date, 'RRRR');
          begin
            select drm.dr_id
              into vc_market_quote_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.period_month = vc_prompt_month
               and drm.period_year = vc_prompt_year
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
            
              if vc_prompt_month is not null and vc_prompt_year is not null then
                vobj_error_log.extend;
                vc_data_missing_for := 'Prompt Delivery Period Missing For ' ||
                                       cur_gmr_rows.instrument_name ||
                                       ',Price Source:' ||
                                       cur_gmr_rows.price_source_name ||
                                       ' GMR Ref No: ' ||
                                       cur_gmr_rows.gmr_ref_no ||
                                       ',Price Unit:' ||
                                       cur_gmr_rows.price_unit_name || ',' ||
                                       cur_gmr_rows.available_price_name ||
                                       ' Price,Prompt Date:' ||
                                       vc_prompt_month || ' ' ||
                                       vc_prompt_year;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_conc_gmr_allocation_price',
                                                                     'PHY-002',
                                                                     vc_data_missing_for,
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
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
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dq.dbd_id = dqd.dbd_id
             and dq.dbd_id = pc_dbd_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dqd.price_unit_id = cur_gmr_rows.price_unit_id
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
               and cdim.instrument_id = cur_gmr_rows.instrument_id;
            if vd_quotes_date is not null then
              vobj_error_log.extend;
              select (case
                       when cur_gmr_rows.is_daily_cal_applicable = 'N' and
                            cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
                        to_char(vd_prompt_date, 'Mon-RRRR')
                       else
                        to_char(vd_quotes_date, 'dd-Mon-RRRR')
                     end)
                into vc_prompt_date_text
                from dual;
              vc_data_missing_for := 'Price missing for ' ||
                                     cur_gmr_rows.instrument_name ||
                                     ',Price Source:' ||
                                     cur_gmr_rows.price_source_name ||
                                     ',Price Unit:' ||
                                     cur_gmr_rows.price_unit_name || ',' ||
                                     cur_gmr_rows.available_price_name ||
                                     ' Price,Prompt Date:' ||
                                     vc_prompt_date_text || ' Trade Date(' ||
                                     to_char(vd_valid_quote_date,
                                             'dd-Mon-RRRR') || ')';
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_conc_gmr_allocation_price',
                                                                   'PHY-002',
                                                                   vc_data_missing_for,
                                                                   '',
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            end if;
          when others then
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure sp_conc_gmr_allocation_price',
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
        --
        -- If Both Fixed and Unfixed Quantities are there then we have two prices
        -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
        --
        if vn_fixed_value > 0 and vn_unfixed_val_price > 0 then
          if vc_fixed_price_unit_id <> vc_unfixed_val_price_unit_id then
            select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
                                                                       vn_unfixed_val_price,
                                                                       vc_unfixed_val_price_unit_id,
                                                                       vc_fixed_price_unit_id,
                                                                       pd_trade_date,
                                                                       cur_gmr_rows.product_id)
              into vn_unfixed_val_price
              from dual;
          end if;
        
        end if;
        if vn_unfixed_qty > 0 then
          vn_unfixed_value := vn_unfixed_qty * vn_unfixed_val_price;
        else
          vn_unfixed_value := 0;
          vn_unfixed_qty   := 0;
        end if;
        if vn_fixed_qty < 0 then
          vn_fixed_value := 0;
          vn_fixed_qty   := 0;
        end if;
      
        if vc_fixed_price_unit_id is not null then
          vc_price_unit_id := vc_fixed_price_unit_id;
        else
          vc_price_unit_id := vc_unfixed_val_price_unit_id;
        end if;
        begin
          select ppu.product_price_unit_id
            into vc_price_unit_id
            from v_ppu_pum ppu
           where ppu.price_unit_id = vc_price_unit_id
             and ppu.product_id = cur_gmr_rows.product_id;
        exception
          when others then
            vc_price_unit_id := null;
        end;
        vn_total_quantity       := vn_fixed_qty + vn_unfixed_qty;
        vn_total_contract_value := vn_total_contract_value +
                                   ((vn_qty_to_be_priced / 100) *
                                   (vn_fixed_value + vn_unfixed_value));
      
      end loop;
      vn_average_price := round(vn_total_contract_value / vn_total_quantity,
                                4);
      begin
        select cm.cur_id,
               cm.cur_code,
               ppu.weight,
               ppu.weight_unit_id,
               qum.qty_unit
          into vc_price_cur_id,
               vc_price_cur_code,
               vn_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vn_price_weight_unit    := null;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
      if vn_average_price is not null and vc_price_unit_id is not null then
        insert into cgcp_conc_gmr_cog_price
          (process_id,
           corporate_id,
           internal_gmr_ref_no,
           gmr_ref_no,
           element_id,
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
           internal_grd_ref_no)
        values
          (pc_process_id,
           pc_corporate_id,
           cur_gmr_rows.internal_gmr_ref_no,
           cur_gmr_rows.gmr_ref_no,
           cur_gmr_rows.element_id,
           cur_gmr_rows.payable_qty,
           cur_gmr_rows.payable_qty_unit_id,
           vn_average_price,
           vc_price_unit_id,
           vc_price_cur_id,
           vc_price_cur_code,
           vn_price_weight_unit,
           vc_price_weight_unit_id,
           vn_price_weight_unit,
           vn_fixed_qty,
           vn_unfixed_qty,
           vc_price_basis,
           cur_gmr_rows.internal_grd_ref_no);
      end if;
    end loop;
    commit;
    sp_gather_stats('cgcp_conc_gmr_cog_price');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_cog_price.sp_conc_gmr_allocation_price',
                                                           'M2M-013',
                                                           ' Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm ||
                                                           dbms_utility.format_error_backtrace,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
      commit;
  end;
end;
/
