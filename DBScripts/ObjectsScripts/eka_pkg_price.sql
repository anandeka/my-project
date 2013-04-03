create or replace package pkg_price is
  procedure sp_base_contract_cog_price(pc_int_contract_item_ref_no varchar2,
                                       pd_trade_date               date,
                                       pn_price                    out number,
                                       pc_price_unit_id            out varchar2);
  procedure sp_base_gmr_cog_price(pc_internal_gmr_ref_no varchar2,
                                  pd_trade_date          date,
                                  pn_price               out number,
                                  pc_price_unit_id       out varchar2);
  procedure sp_conc_contract_cog_price(pc_int_contract_item_ref_no varchar2,
                                       pd_trade_date               date,
                                       pc_element_id               varchar2,
                                       pn_price                    out number,
                                       pc_price_unit_id            out varchar2);

  procedure sp_conc_gmr_cog_price(pc_internal_gmr_ref_no varchar2,
                                  pd_trade_date          date,
                                  pc_element_id          varchar2,
                                  pn_price               out number,
                                  pc_price_unit_id       out varchar2);
  procedure sp_conc_gmr_allocation_price(pc_internal_gmr_ref_no varchar2,
                                         pd_trade_date          date,
                                         pc_element_id          varchar2,
                                         pn_price               out number,
                                         pc_price_unit_id       out varchar2);
  function f_get_converted_price_pum(pc_corporate_id       varchar2,
                                     pn_price              number,
                                     pc_from_price_unit_id varchar2,
                                     pc_to_price_unit_id   varchar2,
                                     pd_trade_date         date,
                                     pc_product_id         varchar2)
    return number;
  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean;
  function f_get_next_month_prompt_date(pc_promp_del_cal_id varchar2,
                                        pd_trade_date       date) return date;
end;
/
create or replace package body pkg_price is
  procedure sp_base_contract_cog_price(pc_int_contract_item_ref_no varchar2,
                                       pd_trade_date               date,
                                       pn_price                    out number,
                                       pc_price_unit_id            out varchar2) is
    ------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_base_contract_cog_price
    --        Author                                    : Suresh Gottipati
    --        Created Date                              : 06th Mar 2013
    --        Purpose                                   : Calcualte COG Price for BM Contract
    --
    --        Parameters
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------
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
             pdc.is_monthly_cal_applicable,
             pcm.corporate_id corporate_id
        from pcdi_pc_delivery_item pcdi,
             diqs_delivery_item_qty_status diqs,
             pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcpd_pc_product_definition pcpd,
             (select * from v_pcdi_exchange_detail t) qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip,
             pdc_prompt_delivery_calendar pdc,
             pci_physical_contract_item pci
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
         and pcpd.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pcdi.pcdi_id = pci.pcdi_id
         and pci.is_active = 'Y'
         and diqs.pcdi_id = pcdi.pcdi_id
         and pci.internal_contract_item_ref_no =
             pc_int_contract_item_ref_no
         and diqs.is_active = 'Y';
  
    cursor cur_called_off(pc_pcdi_id varchar2) is
      select poch.poch_id,
             pofh.pofh_id,
             poch.internal_action_ref_no,
             pocd.pricing_formula_id,
             pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.tonnage_basis,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced,
             pcbph.price_description,
             nvl(pofh.final_price_in_pricing_cur, 0) final_price,
             pofh.finalize_date,
             pocd.final_price_unit_id,
             nvl(pcbph.valuation_price_percentage, 100) / 100 valuation_price_percentage
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail pcbpd,
             pcbph_pc_base_price_header pcbph,
             (select pofh.pocd_id,
                     pofh.pofh_id,
                     pofh.final_price_in_pricing_cur,
                     pofh.finalize_date
                from pofh_price_opt_fixation_header pofh
               where pofh.is_active = 'Y'
                 and pofh.internal_gmr_ref_no is null) pofh
       where poch.pcdi_id = pc_pcdi_id
         and poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pocd.pocd_id = pofh.pocd_id(+)
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
             pcbph.price_description,
             nvl(pcbph.valuation_price_percentage, 100) / 100 valuation_price_percentage
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
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
  
    vn_contract_price          number;
    vc_price_unit_id           varchar2(15);
    vc_price_basis             varchar2(15);
    vc_price_cur_id            varchar2(15);
    vc_price_cur_code          varchar2(15);
    vn_price_weight_unit       number;
    vc_price_weight_unit_id    varchar2(15);
    vc_price_qty_unit          varchar2(15);
    vc_price_fixation_status   varchar2(50);
    vn_total_quantity          number;
    vn_qty_to_be_priced        number;
    vn_total_contract_value    number;
    vn_average_price           number;
    vd_quotes_date             date;
    vn_error_no                number := 0;
    vc_prompt_month            varchar2(15);
    vc_prompt_year             number;
    vc_fixed_price_unit_id     varchar2(15);
    vc_fixed_price_unit_id_pum varchar2(50);
    vn_total_qty_for_avg_price number;
  
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
      vc_fixed_price_unit_id_pum   := null;
      vn_total_qty_for_avg_price   := 0;
    
      if cur_pcdi_rows.price_option_call_off_status in
         ('Called Off', 'Not Applicable') then
        vc_price_fixation_status := null;
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id)
        loop
          vn_total_quantity   := cur_pcdi_rows.item_qty;
          vn_qty_to_be_priced := cur_called_off_rows.qty_to_be_priced;
          vc_price_basis      := cur_called_off_rows.price_basis;
          if cur_called_off_rows.price_basis = 'Fixed' then
            vn_fixed_qty               := vn_total_quantity;
            vn_unfixed_qty             := 0;
            vn_contract_price          := cur_called_off_rows.price_value;
            vn_total_contract_value    := vn_total_contract_value +
                                          vn_total_quantity *
                                          (vn_qty_to_be_priced / 100) *
                                          vn_contract_price;
            vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                          (vn_total_quantity *
                                          (vn_qty_to_be_priced / 100));
            vc_price_unit_id           := cur_called_off_rows.price_unit_id;
          
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            if cur_called_off_rows.final_price <> 0 and
               cur_called_off_rows.finalize_date <= pd_trade_date then
              vn_total_contract_value    := vn_total_contract_value +
                                            vn_total_quantity *
                                            (vn_qty_to_be_priced / 100) *
                                            cur_called_off_rows.final_price;
              vc_price_unit_id           := cur_called_off_rows.final_price_unit_id;
              vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                            (vn_total_quantity *
                                            (vn_qty_to_be_priced / 100));
            else
              begin
                select nvl(sum(pfd.user_price * pfd.qty_fixed), 0),
                       nvl(sum(pfd.qty_fixed), 0),
                       vppu.price_unit_id,
                       pfd.price_unit_id
                  into vn_fixed_value,
                       vn_fixed_qty,
                       vc_fixed_price_unit_id_pum,
                       vc_fixed_price_unit_id
                  from poch_price_opt_call_off_header poch,
                       pocd_price_option_calloff_dtls pocd,
                       pofh_price_opt_fixation_header pofh,
                       pfd_price_fixation_details     pfd,
                       v_ppu_pum                      vppu
                 where poch.poch_id = pocd.poch_id
                   and pocd.pocd_id = pofh.pocd_id
                   and pofh.pofh_id = cur_called_off_rows.pofh_id
                   and pofh.pofh_id = pfd.pofh_id
                   and pfd.hedge_correction_date <= pd_trade_date
                   and pfd.price_unit_id = vppu.product_price_unit_id
                   and poch.is_active = 'Y'
                   and pocd.is_active = 'Y'
                   and pofh.is_active = 'Y'
                   and pfd.is_active = 'Y'
                   and (nvl(pfd.user_price, 0) * nvl(pfd.qty_fixed, 0)) <> 0
                 group by vppu.price_unit_id,
                          pfd.price_unit_id;
              exception
                when others then
                  vn_fixed_value             := 0;
                  vn_fixed_qty               := 0;
                  vc_fixed_price_unit_id     := null;
                  vc_fixed_price_unit_id_pum := null;
              end;
              -- added Suresh
              if vc_fixed_price_unit_id is null or
                 vc_fixed_price_unit_id = '' then
                vc_fixed_price_unit_id := cur_called_off_rows.final_price_unit_id;
                begin
                  select ppu.price_unit_id
                    into vc_fixed_price_unit_id_pum
                    from v_ppu_pum ppu
                   where ppu.product_price_unit_id = vc_fixed_price_unit_id;
                exception
                  when others then
                    vc_fixed_price_unit_id_pum := null;
                end;
              end if;
              ---
              vn_unfixed_qty := (cur_pcdi_rows.item_qty *
                                (vn_qty_to_be_priced / 100)) - vn_fixed_qty; -- Unfixed qty is Based on Combo %
              if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                vn_forward_days := 0;
                vd_quotes_date  := pd_trade_date + 1;
                while vn_forward_days <> 2
                loop
                  if pkg_price.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                    vc_market_quote_dr_id := null;
                  
                end;
              end if;
            
              if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                 cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                vd_prompt_date  := pkg_price.f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
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
                    vc_market_quote_dr_id := null;
                end;
              end if;
              -- price 
              begin
                select dqd.price *
                       cur_called_off_rows.valuation_price_percentage,
                       dqd.price_unit_id
                  into vn_unfixed_val_price,
                       vc_unfixed_val_price_unit_id
                  from dq_derivative_quotes          dq,
                       v_dqd_derivative_quote_detail dqd
                 where dq.dq_id = dqd.dq_id
                   and dqd.dr_id = vc_market_quote_dr_id
                   and dq.instrument_id = cur_pcdi_rows.instrument_id
                   and dqd.available_price_id =
                       cur_pcdi_rows.available_price_id
                   and dq.price_source_id = cur_pcdi_rows.price_source_id
                   and dqd.price_unit_id = cur_pcdi_rows.price_unit_id
                   and dq.corporate_id = cur_pcdi_rows.corporate_id
                   and dq.is_deleted = 'N'
                   and dqd.is_deleted = 'N'
                   and rownum < 2
                   and dq.trade_date =
                       (select max(dq.trade_date)
                          from dq_derivative_quotes          dq,
                               v_dqd_derivative_quote_detail dqd
                         where dq.dq_id = dqd.dq_id
                           and dqd.dr_id = vc_market_quote_dr_id
                           and dq.instrument_id =
                               cur_pcdi_rows.instrument_id
                           and dqd.available_price_id =
                               cur_pcdi_rows.available_price_id
                           and dq.price_source_id =
                               cur_pcdi_rows.price_source_id
                           and dqd.price_unit_id =
                               cur_pcdi_rows.price_unit_id
                           and dq.corporate_id = cur_pcdi_rows.corporate_id
                           and dq.is_deleted = 'N'
                           and dqd.is_deleted = 'N'
                           and dq.trade_date <= pd_trade_date);
              exception
                when no_data_found then
                  vn_unfixed_val_price         := 0;
                  vc_unfixed_val_price_unit_id := null;
              end;
              --
              -- If Both Fixed and Unfixed Quantities are there then we have two prices
              -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
              --
              if vc_fixed_price_unit_id_pum <> vc_unfixed_val_price_unit_id then
                select f_get_converted_price_pum(cur_pcdi_rows.corporate_id,
                                                 vn_unfixed_val_price,
                                                 vc_unfixed_val_price_unit_id,
                                                 vc_fixed_price_unit_id_pum,
                                                 pd_trade_date,
                                                 cur_pcdi_rows.product_id)
                  into vn_unfixed_val_price
                  from dual;
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
            
              vc_price_unit_id           := vc_fixed_price_unit_id;
              vn_total_contract_value    := vn_total_contract_value +
                                            (vn_fixed_value +
                                            vn_unfixed_value);
              vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                            vn_fixed_qty + vn_unfixed_qty;
            end if;
          end if;
        
        end loop;
        if vn_total_qty_for_avg_price <> 0 then
          vn_average_price := round(vn_total_contract_value /
                                    vn_total_qty_for_avg_price,
                                    4);
        else
          vn_average_price := 0;
        end if;
      
        vn_error_no := vn_error_no + 1;
      elsif cur_pcdi_rows.price_option_call_off_status = 'Not Called Off' then
        vn_error_no := vn_error_no + 1;
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id)
        loop
          vc_price_basis      := cur_not_called_off_rows.price_basis;
          vn_total_quantity   := cur_pcdi_rows.item_qty;
          vn_qty_to_be_priced := cur_not_called_off_rows.qty_to_be_priced;
        
          if cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
              vn_forward_days := 0;
              vd_quotes_date  := pd_trade_date + 1;
              while vn_forward_days <> 2
              loop
                if pkg_price.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  vc_market_quote_dr_id := null;
              end;
            end if;
          
            if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
               cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
              vd_prompt_date  := pkg_price.f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
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
                  vc_market_quote_dr_id := null;
              end;
            end if;
            begin
              select dqd.price *
                     cur_not_called_off_rows.valuation_price_percentage,
                     dqd.price_unit_id
                into vn_unfixed_val_price,
                     vc_unfixed_val_price_unit_id
                from dq_derivative_quotes          dq,
                     v_dqd_derivative_quote_detail dqd
               where dq.dq_id = dqd.dq_id
                 and dqd.dr_id = vc_market_quote_dr_id
                 and dq.instrument_id = cur_pcdi_rows.instrument_id
                 and dqd.available_price_id =
                     cur_pcdi_rows.available_price_id
                 and dq.price_source_id = cur_pcdi_rows.price_source_id
                 and dqd.price_unit_id = cur_pcdi_rows.price_unit_id
                 and dq.corporate_id = cur_pcdi_rows.corporate_id
                 and dq.is_deleted = 'N'
                 and dqd.is_deleted = 'N'
                 and rownum < 2
                 and dq.trade_date =
                     (select max(dq.trade_date)
                        from dq_derivative_quotes          dq,
                             v_dqd_derivative_quote_detail dqd
                       where dq.dq_id = dqd.dq_id
                         and dqd.dr_id = vc_market_quote_dr_id
                         and dq.instrument_id = cur_pcdi_rows.instrument_id
                         and dqd.available_price_id =
                             cur_pcdi_rows.available_price_id
                         and dq.price_source_id =
                             cur_pcdi_rows.price_source_id
                         and dqd.price_unit_id = cur_pcdi_rows.price_unit_id
                         and dq.corporate_id = cur_pcdi_rows.corporate_id
                         and dq.is_deleted = 'N'
                         and dqd.is_deleted = 'N'
                         and dq.trade_date <= pd_trade_date);
            exception
              when no_data_found then
                vn_unfixed_val_price         := 0;
                vc_unfixed_val_price_unit_id := null;
            end;
            vn_fixed_qty               := 0;
            vn_unfixed_qty             := vn_total_quantity;
            vn_total_contract_value    := vn_total_contract_value +
                                          ((vn_qty_to_be_priced / 100) *
                                          (vn_total_quantity *
                                          vn_unfixed_val_price));
            vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                          vn_fixed_qty + vn_unfixed_qty;
          
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
        if vn_total_qty_for_avg_price <> 0 then
          vn_average_price := round(vn_total_contract_value /
                                    vn_total_qty_for_avg_price,
                                    4);
        else
          vn_average_price := 0;
        end if;
      end if;
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_price_unit_id;
  end;
  procedure sp_base_gmr_cog_price(pc_internal_gmr_ref_no varchar2,
                                  pd_trade_date          date,
                                  pn_price               out number,
                                  pc_price_unit_id       out varchar2) is
    ------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_base_gmr_cog_price
    --        Author                                    : Suresh Gottipati
    --        Created Date                              : 06th Mar 2013
    --        Purpose                                   : Calcualte COG GMR Price for BM Contract
    --
    --        Parameters
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------                                  
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
               where grd.tolling_stock_type = 'None Tolling'
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
         and gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
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
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
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
               where grd.status = 'Active'
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
         and gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
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
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no;
  
    cursor cur_gmr_ele(pc_internal_gmr_ref_no varchar2) is
      select pofh.internal_gmr_ref_no,
             pofh.pofh_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pcbpd.price_basis,
             nvl(pofh.final_price_in_pricing_cur, 0) final_price,
             pofh.finalize_date,
             pocd.final_price_unit_id,
             nvl(pcbph.valuation_price_percentage, 100) / 100 valuation_price_percentage
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where pofh.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
  
    vn_total_contract_value      number;
    vc_price_cur_id              varchar2(15);
    vc_price_cur_code            varchar2(15);
    vn_price_weight_unit         number;
    vc_price_weight_unit_id      varchar2(15);
    vc_price_qty_unit            varchar2(15);
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
    vc_fixed_price_unit_id_pum   varchar2(50);
    vn_total_qty_for_avg_price   number;
  begin
    for cur_gmr_rows in cur_gmr
    loop
      vn_total_contract_value      := 0;
      vn_fixed_qty                 := 0;
      vn_unfixed_qty               := 0;
      vn_fixed_value               := 0;
      vn_unfixed_value             := 0;
      vn_total_quantity            := cur_gmr_rows.qty;
      vc_unfixed_val_price_unit_id := null;
      vc_unfixed_val_price_unit_id := null;
      vc_fixed_price_unit_id_pum   := null;
      vn_total_qty_for_avg_price   := 0;
    
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no)
      loop
        vn_qty_to_be_priced := cur_gmr_ele_rows.qty_to_be_priced;
        vc_price_basis      := cur_gmr_ele_rows.price_basis;
        if cur_gmr_ele_rows.final_price <> 0 and
           cur_gmr_ele_rows.finalize_date <= pd_trade_date then
        
          vn_total_contract_value    := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        cur_gmr_ele_rows.final_price;
          vc_price_unit_id           := cur_gmr_ele_rows.final_price_unit_id;
          vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                        (vn_total_quantity *
                                        (vn_qty_to_be_priced / 100));
        else
          begin
            select nvl(sum(pfd.user_price * pfd.qty_fixed), 0),
                   nvl(sum(pfd.qty_fixed), 0),
                   ppu.price_unit_id,
                   pfd.price_unit_id
              into vn_fixed_value,
                   vn_fixed_qty,
                   vc_fixed_price_unit_id_pum,
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
             group by ppu.price_unit_id,
                      pfd.price_unit_id;
          exception
            when others then
              vn_fixed_value             := 0;
              vn_fixed_qty               := 0;
              vc_fixed_price_unit_id     := null;
              vc_fixed_price_unit_id_pum := null;
          end;
          -- added Suresh
          if vc_fixed_price_unit_id is null or vc_fixed_price_unit_id = '' then
            vc_fixed_price_unit_id := cur_gmr_ele_rows.final_price_unit_id;
            begin
              select ppu.price_unit_id
                into vc_fixed_price_unit_id_pum
                from v_ppu_pum ppu
               where ppu.product_price_unit_id = vc_fixed_price_unit_id;
            exception
              when others then
                vc_fixed_price_unit_id_pum := null;
            end;
          end if;
          ---
        
          vn_unfixed_qty := (cur_gmr_rows.qty * vn_qty_to_be_priced / 100) -
                            vn_fixed_qty; -- Unfixed qty is based on Combo %
        
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
            vn_forward_days := 0;
            vd_quotes_date  := pd_trade_date + 1;
            while vn_forward_days <> 2
            loop
              if pkg_price.f_is_day_holiday(cur_gmr_rows.instrument_id,
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
              when others then
                vc_market_quote_dr_id := null;
            end;
          end if;
        
          if cur_gmr_rows.is_daily_cal_applicable = 'N' and
             cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
            vd_prompt_date  := pkg_price.f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
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
                vc_market_quote_dr_id := null;
            end;
          end if;
        
          begin
            select dqd.price * cur_gmr_ele_rows.valuation_price_percentage,
                   dqd.price_unit_id
              into vn_unfixed_val_price,
                   vc_unfixed_val_price_unit_id
              from dq_derivative_quotes          dq,
                   v_dqd_derivative_quote_detail dqd
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_market_quote_dr_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = cur_gmr_rows.price_source_id
               and dqd.price_unit_id = cur_gmr_rows.price_unit_id
               and dq.corporate_id = cur_gmr_rows.corporate_id
               and dq.is_deleted = 'N'
               and dqd.is_deleted = 'N'
               and rownum < 2
               and dq.trade_date =
                   (select max(dq.trade_date)
                      from dq_derivative_quotes          dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_market_quote_dr_id
                       and dq.instrument_id = cur_gmr_rows.instrument_id
                       and dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                       and dq.price_source_id = cur_gmr_rows.price_source_id
                       and dqd.price_unit_id = cur_gmr_rows.price_unit_id
                       and dq.corporate_id = cur_gmr_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date <= pd_trade_date);
          exception
            when no_data_found then
              vn_unfixed_val_price         := 0;
              vc_unfixed_val_price_unit_id := null;
          end;
          --
          -- If Both Fixed and Unfixed Quantities are there then we have two prices
          -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
          --
          if vc_fixed_price_unit_id_pum <> vc_unfixed_val_price_unit_id then
            select f_get_converted_price_pum(cur_gmr_rows.corporate_id,
                                             vn_unfixed_val_price,
                                             vc_unfixed_val_price_unit_id,
                                             vc_fixed_price_unit_id_pum,
                                             pd_trade_date,
                                             cur_gmr_rows.product_id)
              into vn_unfixed_val_price
              from dual;
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
          vn_total_quantity          := vn_fixed_qty + vn_unfixed_qty;
          vc_price_unit_id           := vc_fixed_price_unit_id;
          vn_total_contract_value    := vn_total_contract_value +
                                        (vn_fixed_value + vn_unfixed_value);
          vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                        vn_fixed_qty + vn_unfixed_qty;
        end if;
      end loop;
      if vn_total_qty_for_avg_price <> 0 then
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_qty_for_avg_price,
                                  4);
      else
        vn_average_price := 0;
      end if;
    
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_price_unit_id;
  
  end;
  procedure sp_conc_contract_cog_price(pc_int_contract_item_ref_no varchar2,
                                       pd_trade_date               date,
                                       pc_element_id               varchar2,
                                       pn_price                    out number,
                                       pc_price_unit_id            out varchar2) is
    ------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_conc_contract_cog_price
    --        Author                                    : Suresh Gottipato
    --        Created Date                              : 06th Mar 2013
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
             pci.internal_contract_item_ref_no,
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
             dipq.price_option_call_off_status,
             pcm.corporate_id corporate_id
        from pcdi_pc_delivery_item pcdi,
             dipq_delivery_item_payable_qty dipq,
             pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcpd_pc_product_definition pcpd,
             aml_attribute_master_list aml,
             pci_physical_contract_item pci,
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
                     pdc.prompt_delivery_calendar_id) tt
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
         and pcdi.pcdi_id = dipq.pcdi_id
         and dipq.payable_qty > 0
         and pcpd.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pcm.is_active = 'Y'
         and dipq.is_active = 'Y'
         and pci.pcdi_id = pcdi.pcdi_id
         and pci.is_active = 'Y'
         and pci.internal_contract_item_ref_no =
             pc_int_contract_item_ref_no
         and dipq.element_id = pc_element_id
      union
      select poch.pcdi_id,
             pci.internal_contract_item_ref_no,
             pcbph.internal_contract_ref_no,
             pcbpd.element_id,
             dipq.payable_qty,
             dipq.qty_unit_id payable_qty_unit_id,
             null delivery_item_no,
             null basis_type,
             null contract_ref_no,
             null product_id,
             null underlying_product_id,
             null instrument_id,
             null instrument_name,
             null price_source_id,
             null price_source_name,
             null available_price_id,
             null available_price_name,
             null price_unit_name,
             null price_unit_id,
             null delivery_calender_id,
             null is_daily_cal_applicable,
             null is_monthly_cal_applicable,
             dipq.price_option_call_off_status,
             pcm.corporate_id corporate_id
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             pcm_physical_contract_main     pcm,
             v_ppu_pum                      ppu,
             cm_currency_master             cm,
             qum_quantity_unit_master       qum,
             dipq_delivery_item_payable_qty dipq,
             pci_physical_contract_item     pci
       where poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.contract_type = 'CONCENTRATES'
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y'
         and pcbpd.price_basis = 'Fixed'
         and ppu.product_price_unit_id = pcbpd.price_unit_id
         and ppu.cur_id = cm.cur_id
         and ppu.weight_unit_id = qum.qty_unit_id
         and dipq.pcdi_id = poch.pcdi_id
         and dipq.element_id = poch.element_id
         and dipq.payable_qty > 0
         and dipq.is_active = 'Y'
         and dipq.pcdi_id = pci.pcdi_id
         and pci.internal_contract_item_ref_no =
             pc_int_contract_item_ref_no
         and dipq.element_id = pc_element_id;
  
    cursor cur_called_off(pc_pcdi_id varchar2, pc_element_id varchar2) is
      select poch.poch_id,
             pofh.pofh_id,
             pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.qty_to_be_priced,
             pcbph.price_description,
             nvl(pofh.final_price_in_pricing_cur, 0) final_price,
             pofh.finalize_date,
             pocd.final_price_unit_id,
             nvl(pcbph.valuation_price_percentage, 100) / 100 valuation_price_percentage
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail pcbpd,
             pcbph_pc_base_price_header pcbph,
             (select pofh.pocd_id,
                     pofh.pofh_id,
                     pofh.final_price_in_pricing_cur,
                     pofh.finalize_date
                from pofh_price_opt_fixation_header pofh
               where pofh.is_active = 'Y'
                 and pofh.internal_gmr_ref_no is null) pofh
       where poch.pcdi_id = pc_pcdi_id
         and pcbpd.element_id = pc_element_id
         and poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pocd.pocd_id = pofh.pocd_id(+)
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
             pcbph.price_description,
             nvl(pcbph.valuation_price_percentage, 100) / 100 valuation_price_percentage
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
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
  
    vc_prompt_date_text          varchar2(100);
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
    vc_fixed_price_unit_id_pum   varchar2(50);
    vn_total_fixed_qty           number;
    vn_total_unfixed_qty         number;
    vn_total_qty_for_avg_price   number;
  
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
      vc_fixed_price_unit_id_pum   := null;
      vc_price_option_call_off_sts := cur_pcdi_rows.price_option_call_off_status;
      vn_total_contract_value      := 0;
      vc_price_unit_id             := null;
      vc_fixed_price_unit_id       := null;
      vn_total_fixed_qty           := 0;
      vn_total_unfixed_qty         := 0;
      vn_total_qty_for_avg_price   := 0;
    
      if vc_price_option_call_off_sts in ('Called Off', 'Not Applicable') then
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id,
                                                  cur_pcdi_rows.element_id)
        loop
          vc_price_basis := cur_called_off_rows.price_basis;
          if cur_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price          := cur_called_off_rows.price_value;
            vn_total_quantity          := cur_pcdi_rows.payable_qty;
            vn_total_contract_value    := vn_total_quantity *
                                          vn_contract_price;
            vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                          (vn_total_quantity *
                                          (vn_qty_to_be_priced / 100));
            vc_price_unit_id           := cur_called_off_rows.price_unit_id;
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            vn_qty_to_be_priced := cur_called_off_rows.qty_to_be_priced;
            vn_total_quantity   := cur_pcdi_rows.payable_qty;
          
            if cur_called_off_rows.final_price <> 0 and
               cur_called_off_rows.finalize_date <= pd_trade_date then
              vn_total_contract_value    := vn_total_contract_value +
                                            vn_total_quantity *
                                            (vn_qty_to_be_priced / 100) *
                                            cur_called_off_rows.final_price;
              vc_price_unit_id           := cur_called_off_rows.final_price_unit_id;
              vc_fixed_price_unit_id     := cur_called_off_rows.final_price_unit_id;
              vn_total_fixed_qty         := vn_total_fixed_qty +
                                            (vn_total_quantity *
                                            (vn_qty_to_be_priced / 100));
              vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                            (vn_total_quantity *
                                            (vn_qty_to_be_priced / 100));
            else
              vc_error_message := ' Line 240 ';
              begin
                select nvl(sum(pfd.user_price * pfd.qty_fixed), 0),
                       nvl(sum(pfd.qty_fixed), 0),
                       pum.price_unit_id,
                       pfd.price_unit_id
                  into vn_fixed_value,
                       vn_fixed_qty,
                       vc_fixed_price_unit_id_pum,
                       vc_fixed_price_unit_id
                  from pfd_price_fixation_details pfd,
                       ppu_product_price_units    ppu,
                       pum_price_unit_master      pum
                 where pfd.price_unit_id = ppu.internal_price_unit_id
                   and ppu.price_unit_id = pum.price_unit_id
                   and pfd.pofh_id = cur_called_off_rows.pofh_id
                   and pfd.is_active = 'Y'
                   and pfd.hedge_correction_date <= pd_trade_date
                   and (nvl(pfd.user_price, 0) * nvl(pfd.qty_fixed, 0)) <> 0
                 group by pum.price_unit_id,
                          pfd.price_unit_id;
              exception
                when others then
                  vn_fixed_value             := 0;
                  vn_fixed_qty               := 0;
                  vc_fixed_price_unit_id     := null;
                  vc_fixed_price_unit_id_pum := null;
              end;
              vn_total_fixed_qty := vn_total_fixed_qty + vn_fixed_qty;
              -- Added Suresh
              if vc_fixed_price_unit_id is null or
                 vc_fixed_price_unit_id = '' then
                vc_fixed_price_unit_id := cur_called_off_rows.final_price_unit_id;
                begin
                  select ppu.price_unit_id
                    into vc_fixed_price_unit_id_pum
                    from v_ppu_pum ppu
                   where ppu.product_price_unit_id = vc_fixed_price_unit_id;
                exception
                  when others then
                    vc_fixed_price_unit_id_pum := null;
                end;
              end if;
              ----
              -- Unfixed Qty is based on Combo %ge
              -- If copper Payable qty is 100 MT and combo is 70/30 and if this record is 70% and priced only 20 MT out of this
              -- Then Unfixed qty = (100 * 70/100)MT - 20MT = 50 MT and not 100MT - 20MT = 80 MT
              --
              vn_unfixed_qty := (vn_total_quantity *
                                (vn_qty_to_be_priced / 100)) - vn_fixed_qty;
              if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                vn_forward_days := 0;
                vd_quotes_date  := pd_trade_date + 1;
                while vn_forward_days <> 2
                loop
                  if pkg_price.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  when others then
                    vc_market_quote_dr_id := null;
                end;
              end if;
              if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                 cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                vd_prompt_date  := pkg_price.f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
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
                    vc_market_quote_dr_id := null;
                end;
              end if;
            
              begin
                select dqd.price *
                       cur_called_off_rows.valuation_price_percentage,
                       dqd.price_unit_id
                  into vn_unfixed_val_price,
                       vc_unfixed_val_price_unit_id
                  from dq_derivative_quotes          dq,
                       v_dqd_derivative_quote_detail dqd
                 where dq.dq_id = dqd.dq_id
                   and dqd.dr_id = vc_market_quote_dr_id
                   and dq.instrument_id = cur_pcdi_rows.instrument_id
                   and dqd.available_price_id =
                       cur_pcdi_rows.available_price_id
                   and dq.price_source_id = cur_pcdi_rows.price_source_id
                   and dqd.price_unit_id = cur_pcdi_rows.price_unit_id
                   and dq.corporate_id = cur_pcdi_rows.corporate_id
                   and dq.is_deleted = 'N'
                   and dqd.is_deleted = 'N'
                   and rownum < 2
                   and dq.trade_date =
                       (select max(dq.trade_date)
                          from dq_derivative_quotes          dq,
                               v_dqd_derivative_quote_detail dqd
                         where dq.dq_id = dqd.dq_id
                           and dqd.dr_id = vc_market_quote_dr_id
                           and dq.instrument_id =
                               cur_pcdi_rows.instrument_id
                           and dqd.available_price_id =
                               cur_pcdi_rows.available_price_id
                           and dq.price_source_id =
                               cur_pcdi_rows.price_source_id
                           and dqd.price_unit_id =
                               cur_pcdi_rows.price_unit_id
                           and dq.corporate_id = cur_pcdi_rows.corporate_id
                           and dq.is_deleted = 'N'
                           and dqd.is_deleted = 'N'
                           and dq.trade_date <= pd_trade_date);
              exception
                when no_data_found then
                  vn_unfixed_val_price         := 0;
                  vc_unfixed_val_price_unit_id := null;
              end;
              --
              -- If Both Fixed and Unfixed Quantities are there then we have two prices
              -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
              --
              vc_error_message := ' Line 431 ';
              if vc_fixed_price_unit_id_pum <> vc_unfixed_val_price_unit_id then
                select f_get_converted_price_pum(cur_pcdi_rows.corporate_id,
                                                 vn_unfixed_val_price,
                                                 vc_unfixed_val_price_unit_id,
                                                 vc_fixed_price_unit_id_pum,
                                                 pd_trade_date,
                                                 cur_pcdi_rows.product_id)
                  into vn_unfixed_val_price
                  from dual;
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
              vn_total_quantity          := vn_fixed_qty + vn_unfixed_qty;
              vn_qty_to_be_priced        := cur_called_off_rows.qty_to_be_priced;
              vn_total_contract_value    := vn_total_contract_value +
                                            ((vn_fixed_value +
                                            vn_unfixed_value));
              vc_price_unit_id           := vc_fixed_price_unit_id;
              vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                            vn_unfixed_qty + vn_fixed_qty;
            end if;
            vc_price_unit_id := vc_fixed_price_unit_id;
          end if;
        end loop;
        vn_total_unfixed_qty := cur_pcdi_rows.payable_qty -
                                vn_total_fixed_qty;
        if vn_total_qty_for_avg_price <> 0 then
          vn_average_price := round(vn_total_contract_value /
                                    vn_total_qty_for_avg_price,
                                    4);
        else
          vn_average_price := 0;
        end if;
      
      elsif vc_price_option_call_off_sts = 'Not Called Off' then
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.element_id)
        loop
          vc_price_basis := cur_not_called_off_rows.price_basis;
          if cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            vn_total_fixed_qty := 0;
            if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
              vn_forward_days := 0;
              vd_quotes_date  := pd_trade_date + 1;
              while vn_forward_days <> 2
              loop
                if pkg_price.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  vc_market_quote_dr_id := null;
              end;
            end if;
            if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
               cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
            
              vd_prompt_date  := pkg_price.f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
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
                  vc_market_quote_dr_id := null;
              end;
            end if;
          
            begin
              select dqd.price *
                     cur_not_called_off_rows.valuation_price_percentage,
                     dqd.price_unit_id
                into vn_unfixed_val_price,
                     vc_unfixed_val_price_unit_id
                from dq_derivative_quotes          dq,
                     v_dqd_derivative_quote_detail dqd
               where dq.dq_id = dqd.dq_id
                 and dqd.dr_id = vc_market_quote_dr_id
                 and dq.instrument_id = cur_pcdi_rows.instrument_id
                 and dqd.available_price_id =
                     cur_pcdi_rows.available_price_id
                 and dq.price_source_id = cur_pcdi_rows.price_source_id
                 and dqd.price_unit_id = cur_pcdi_rows.price_unit_id
                 and dq.corporate_id = cur_pcdi_rows.corporate_id
                 and dq.is_deleted = 'N'
                 and dqd.is_deleted = 'N'
                 and rownum < 2
                 and dq.trade_date =
                     (select max(dq.trade_date)
                        from dq_derivative_quotes          dq,
                             v_dqd_derivative_quote_detail dqd
                       where dq.dq_id = dqd.dq_id
                         and dqd.dr_id = vc_market_quote_dr_id
                         and dq.instrument_id = cur_pcdi_rows.instrument_id
                         and dqd.available_price_id =
                             cur_pcdi_rows.available_price_id
                         and dq.price_source_id =
                             cur_pcdi_rows.price_source_id
                         and dqd.price_unit_id = cur_pcdi_rows.price_unit_id
                         and dq.corporate_id = cur_pcdi_rows.corporate_id
                         and dq.is_deleted = 'N'
                         and dqd.is_deleted = 'N'
                         and dq.trade_date <= pd_trade_date);
            exception
              when no_data_found then
                vn_unfixed_val_price         := 0;
                vc_unfixed_val_price_unit_id := null;
            end;
            vn_total_quantity       := cur_pcdi_rows.payable_qty;
            vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       (vn_total_quantity *
                                       ((vn_qty_to_be_priced / 100) * -- For Non Called Off Payable Value is Combo %
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
            vc_error_message           := ' Line 647 ';
            vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                          (vn_total_quantity *
                                          (vn_qty_to_be_priced / 100));
          end if;
        end loop;
        vn_total_unfixed_qty := cur_pcdi_rows.payable_qty -
                                vn_total_fixed_qty;
        if vn_total_qty_for_avg_price <> 0 then
          vn_average_price := round(vn_total_contract_value /
                                    vn_total_qty_for_avg_price,
                                    4);
        else
          vn_average_price := 0;
        end if;
      
      end if;
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_price_unit_id;
  end;
  procedure sp_conc_gmr_cog_price(pc_internal_gmr_ref_no varchar2,
                                  pd_trade_date          date,
                                  pc_element_id          varchar2,
                                  pn_price               out number,
                                  pc_price_unit_id       out varchar2) is
    ------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_conc_gmr_cog_price
    --        Author                                    : Suresh Gottipati
    --        Created Date                              : 06th Mar 2013
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
             gmr.product_id,
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
             gpq.element_id,
             gpq.payable_qty,
             gpq.qty_unit_id payable_qty_unit_id,
             tt.corporate_id
        from gmr_goods_movement_record gmr,
             v_gmr_payable_qty         gpq,
             v_ged_gmr_exchange_detail tt
       where tt.element_id = gpq.element_id
         and tt.internal_gmr_ref_no = gpq.internal_gmr_ref_no
         and gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
         and gmr.corporate_id = tt.corporate_id(+)
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and gpq.element_id = pc_element_id
         and gmr.is_deleted = 'N';
  
    cursor cur_gmr_ele(pc_internal_gmr_ref_no varchar2, pc_element_id varchar2) is
      select pofh.internal_gmr_ref_no,
             pofh.pofh_id,
             pcbpd.element_id,
             pcbpd.pcbpd_id,
             case
               when pcbph.is_balance_pricing = 'Y' then
                100
               else
                pcbpd.qty_to_be_priced
             end qty_to_be_priced,
             pcbpd.price_basis,
             pdm.product_id,
             pdm.base_quantity_unit base_qty_unit_id,
             nvl(pofh.final_price_in_pricing_cur, 0) final_price,
             pofh.finalize_date,
             pocd.final_price_unit_id,
             nvl(pcbph.valuation_price_percentage, 100) / 100 valuation_price_percentage
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
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y'
         and pcbpd.element_id = aml.attribute_id
         and aml.underlying_product_id = pdm.product_id;
  
    vd_quotes_date               date;
    vn_total_contract_value      number;
    vc_price_cur_id              varchar2(15);
    vc_price_cur_code            varchar2(15);
    vn_price_weight_unit         number;
    vc_price_weight_unit_id      varchar2(15);
    vc_price_qty_unit            varchar2(15);
    vc_price_unit_id             varchar2(15);
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
    vc_prompt_date_text          varchar2(100);
    vc_fixed_price_unit_id       varchar2(15);
    vc_data_missing_for          varchar2(1000);
    vc_fixed_price_unit_id_pum   varchar2(50);
    vn_total_fixed_qty           number;
    vn_total_unfixed_qty         number;
    vn_total_qty_for_avg_price   number;
  
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
      vc_fixed_price_unit_id_pum   := null;
      vc_price_unit_id             := null;
      vc_fixed_price_unit_id       := null;
      vn_total_fixed_qty           := 0;
      vn_total_unfixed_qty         := 0;
      vn_total_qty_for_avg_price   := 0;
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no,
                                          cur_gmr_rows.element_id)
      loop
        if cur_gmr_ele_rows.final_price <> 0 and
           cur_gmr_ele_rows.finalize_date <= pd_trade_date then
          vn_total_quantity          := cur_gmr_rows.payable_qty;
          vn_qty_to_be_priced        := cur_gmr_ele_rows.qty_to_be_priced;
          vn_total_contract_value    := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        cur_gmr_ele_rows.final_price;
          vc_price_unit_id           := cur_gmr_ele_rows.final_price_unit_id;
          vn_total_fixed_qty         := vn_total_fixed_qty +
                                        (vn_total_quantity *
                                        (vn_qty_to_be_priced / 100));
          vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                        (vn_total_quantity *
                                        (vn_qty_to_be_priced / 100));
        else
          vc_price_basis := cur_gmr_ele_rows.price_basis;
          begin
            select nvl(sum((pfd.user_price * pfd.qty_fixed)), 0),
                   nvl(sum(pfd.qty_fixed), 0),
                   ppu.price_unit_id,
                   pfd.price_unit_id
              into vn_fixed_value,
                   vn_fixed_qty,
                   vc_fixed_price_unit_id_pum,
                   vc_fixed_price_unit_id
              from pfd_price_fixation_details pfd,
                   v_ppu_pum                  ppu
             where pfd.pofh_id = cur_gmr_ele_rows.pofh_id
               and pfd.hedge_correction_date <= pd_trade_date
               and pfd.is_active = 'Y'
               and ppu.product_price_unit_id = pfd.price_unit_id
               and (nvl(pfd.user_price, 0) * nvl(pfd.qty_fixed, 0)) <> 0
             group by ppu.price_unit_id,
                      pfd.price_unit_id;
          
          exception
            when others then
              vn_fixed_value             := 0;
              vn_fixed_qty               := 0;
              vc_fixed_price_unit_id     := null;
              vc_fixed_price_unit_id_pum := null;
          end;
          vn_total_fixed_qty := vn_total_fixed_qty + vn_fixed_qty;
          -- Added Suresh
          if vc_fixed_price_unit_id is null or vc_fixed_price_unit_id = '' then
            vc_fixed_price_unit_id := cur_gmr_ele_rows.final_price_unit_id;
            begin
              select ppu.price_unit_id
                into vc_fixed_price_unit_id_pum
                from v_ppu_pum ppu
               where ppu.product_price_unit_id = vc_fixed_price_unit_id;
            exception
              when others then
                vc_fixed_price_unit_id_pum := null;
            end;
          end if;
          ---
          vn_qty_to_be_priced := cur_gmr_ele_rows.qty_to_be_priced;
          vn_unfixed_qty      := (cur_gmr_rows.payable_qty *
                                 vn_qty_to_be_priced / 100) - vn_fixed_qty; -- Unfixed qty is Based on Combo %
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
            vn_forward_days := 0;
            vd_quotes_date  := pd_trade_date + 1;
            while vn_forward_days <> 2
            loop
              if pkg_price.f_is_day_holiday(cur_gmr_rows.instrument_id,
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
                vc_market_quote_dr_id := null;
            end;
          end if;
          if cur_gmr_rows.is_daily_cal_applicable = 'N' and
             cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
            vd_prompt_date  := pkg_price.f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
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
                vc_market_quote_dr_id := null;
            end;
          end if;
          begin
            select dqd.price * cur_gmr_ele_rows.valuation_price_percentage,
                   dqd.price_unit_id
              into vn_unfixed_val_price,
                   vc_unfixed_val_price_unit_id
              from dq_derivative_quotes          dq,
                   v_dqd_derivative_quote_detail dqd
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_market_quote_dr_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = cur_gmr_rows.price_source_id
               and dqd.price_unit_id = cur_gmr_rows.price_unit_id
               and dq.corporate_id = cur_gmr_rows.corporate_id
               and dq.is_deleted = 'N'
               and dqd.is_deleted = 'N'
               and rownum < 2
               and dq.trade_date =
                   (select max(dq.trade_date)
                      from dq_derivative_quotes          dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_market_quote_dr_id
                       and dq.instrument_id = cur_gmr_rows.instrument_id
                       and dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                       and dq.price_source_id = cur_gmr_rows.price_source_id
                       and dqd.price_unit_id = cur_gmr_rows.price_unit_id
                       and dq.corporate_id = cur_gmr_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date <= pd_trade_date);
          exception
            when no_data_found then
              vn_unfixed_val_price         := 0;
              vc_unfixed_val_price_unit_id := null;
          end;
          --
          -- If Both Fixed and Unfixed Quantities are there then we have two prices
          -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
          --
          if vc_fixed_price_unit_id_pum <> vc_unfixed_val_price_unit_id then
            select f_get_converted_price_pum(cur_gmr_rows.corporate_id,
                                             vn_unfixed_val_price,
                                             vc_unfixed_val_price_unit_id,
                                             vc_fixed_price_unit_id_pum,
                                             pd_trade_date,
                                             cur_gmr_ele_rows.product_id)
              into vn_unfixed_val_price
              from dual;
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
        
          vc_price_unit_id           := vc_fixed_price_unit_id;
          vn_total_quantity          := vn_fixed_qty + vn_unfixed_qty;
          vn_total_contract_value    := vn_total_contract_value +
                                        (vn_fixed_value + vn_unfixed_value);
          vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                        vn_fixed_qty + vn_unfixed_qty;
        
        end if;
      end loop;
      vn_total_unfixed_qty := cur_gmr_rows.payable_qty - vn_total_fixed_qty;
      if vn_total_qty_for_avg_price <> 0 then
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_qty_for_avg_price,
                                  4);
      else
        vn_average_price := 0;
      end if;
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_price_unit_id;
  end;

  procedure sp_conc_gmr_allocation_price(pc_internal_gmr_ref_no varchar2,
                                         pd_trade_date          date,
                                         pc_element_id          varchar2,
                                         pn_price               out number,
                                         pc_price_unit_id       out varchar2) is
    ------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_conc_gmr_allocation_price
    --        Author                                    : Suresh gottipati
    --        Created Date                              : 06th Mar 2013
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
             gmr.product_id,
             page.instrument_id,
             page.instrument_name,
             page.price_source_id,
             page.price_source_name,
             page.available_price_id,
             page.available_price_name,
             page.price_unit_name,
             page.ppu_price_unit_id,
             page.price_unit_id,
             page.delivery_calender_id,
             page.is_daily_cal_applicable,
             page.is_monthly_cal_applicable,
             gpq.element_id,
             gpq.payable_qty,
             gpq.qty_unit_id payable_qty_unit_id,
             gmr.corporate_id
        from v_gmr_payable_qty         gpq,
             gmr_goods_movement_record gmr,
             v_page_price_alloc_gmr    page
       where page.element_id = gpq.element_id
         and page.internal_gmr_ref_no = gpq.internal_gmr_ref_no
         and gmr.internal_gmr_ref_no = page.internal_gmr_ref_no(+)
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and gpq.element_id = pc_element_id
         and gmr.is_deleted = 'N';
    cursor cur_gmr_ele(pc_internal_gmr_ref_no varchar2, pc_element_id varchar2) is
      select gad.internal_gmr_ref_no,
             gad.element_id,
             gad.pcbpd_id,
             gad.qty_to_be_priced,
             gad.price_basis,
             gad.product_id,
             gad.base_qty_unit_id,
             gad.gpah_id,
             gad.final_price,
             gad.finalize_date,
             gad.final_price_unit_id,
             gad.valuation_price_percentage
        from v_gad_gmr_aloc_data gad
       where gad.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and gad.element_id = pc_element_id;
  
    vd_quotes_date               date;
    vn_total_contract_value      number;
    vc_price_cur_id              varchar2(15);
    vc_price_cur_code            varchar2(15);
    vn_price_weight_unit         number;
    vc_price_weight_unit_id      varchar2(15);
    vc_price_qty_unit            varchar2(15);
    vc_price_unit_id             varchar2(15);
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
    vc_prompt_date_text          varchar2(100);
    vc_fixed_price_unit_id       varchar2(15);
    vc_data_missing_for          varchar2(1000);
    vc_fixed_price_unit_id_pum   varchar2(50);
    vn_total_fixed_qty           number;
    vn_total_unfixed_qty         number;
    vn_total_qty_for_avg_price   number;
  
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
      vc_fixed_price_unit_id_pum   := null;
      vn_total_fixed_qty           := 0;
      vn_total_unfixed_qty         := 0;
      vn_total_qty_for_avg_price   := 0;
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no,
                                          cur_gmr_rows.element_id)
      loop
      
        vc_price_basis := cur_gmr_ele_rows.price_basis;
        if cur_gmr_ele_rows.final_price <> 0 and
           cur_gmr_ele_rows.finalize_date <= pd_trade_date then
          vn_total_quantity          := cur_gmr_rows.payable_qty;
          vn_qty_to_be_priced        := cur_gmr_ele_rows.qty_to_be_priced;
          vn_total_contract_value    := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        cur_gmr_ele_rows.final_price;
          vc_price_unit_id           := cur_gmr_ele_rows.final_price_unit_id;
          vn_total_fixed_qty         := vn_total_fixed_qty +
                                        (vn_total_quantity *
                                        (vn_qty_to_be_priced / 100));
          vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                        (vn_total_quantity *
                                        (vn_qty_to_be_priced / 100));
        else
          begin
            select nvl(sum((pfd.user_price * gpad.allocated_qty)), 0),
                   nvl(sum(gpad.allocated_qty), 0),
                   ppu.price_unit_id,
                   pfd.price_unit_id
              into vn_fixed_value,
                   vn_fixed_qty,
                   vc_fixed_price_unit_id_pum,
                   vc_fixed_price_unit_id
              from gpah_gmr_price_alloc_header gpah,
                   gpad_gmr_price_alloc_dtls   gpad,
                   pfd_price_fixation_details  pfd,
                   v_ppu_pum                   ppu
             where gpad.pfd_id = pfd.pfd_id
               and pfd.is_active = 'Y'
               and gpah.is_active = 'Y'
               and gpad.is_active = 'Y'
               and ppu.product_price_unit_id = pfd.price_unit_id
               and gpah.gpah_id = gpad.gpah_id
               and gpah.element_id = cur_gmr_ele_rows.element_id
               and (nvl(pfd.user_price, 0) * nvl(gpad.allocated_qty, 0)) <> 0
               and gpah.gpah_id = cur_gmr_ele_rows.gpah_id
               and pfd.hedge_correction_date <= pd_trade_date
             group by ppu.price_unit_id,
                      pfd.price_unit_id;
          exception
            when others then
              vn_fixed_value             := 0;
              vn_fixed_qty               := 0;
              vc_fixed_price_unit_id     := null;
              vc_fixed_price_unit_id_pum := null;
          end;
          vn_total_fixed_qty := vn_total_fixed_qty + vn_fixed_qty;
          --Added Suresh
          if vc_fixed_price_unit_id is null or vc_fixed_price_unit_id = '' then
            vc_fixed_price_unit_id := cur_gmr_ele_rows.final_price_unit_id;
            begin
              select ppu.price_unit_id
                into vc_fixed_price_unit_id_pum
                from v_ppu_pum ppu
               where ppu.product_price_unit_id = vc_fixed_price_unit_id;
            exception
              when others then
                vc_fixed_price_unit_id_pum := null;
            end;
          end if;
          ----
          vn_qty_to_be_priced := cur_gmr_ele_rows.qty_to_be_priced;
          vn_unfixed_qty      := (cur_gmr_rows.payable_qty *
                                 vn_qty_to_be_priced / 100) - vn_fixed_qty; --Unfixed Qty is based on Combo %ge
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
            vn_forward_days := 0;
            vd_quotes_date  := pd_trade_date + 1;
            while vn_forward_days <> 2
            loop
              if pkg_price.f_is_day_holiday(cur_gmr_rows.instrument_id,
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
                vc_market_quote_dr_id := null;
            end;
          end if;
          if cur_gmr_rows.is_daily_cal_applicable = 'N' and
             cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
            vd_prompt_date  := pkg_price.f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
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
                vc_market_quote_dr_id := null;
            end;
          end if;
          begin
            select dqd.price * cur_gmr_ele_rows.valuation_price_percentage,
                   dqd.price_unit_id
              into vn_unfixed_val_price,
                   vc_unfixed_val_price_unit_id
              from dq_derivative_quotes          dq,
                   v_dqd_derivative_quote_detail dqd
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_market_quote_dr_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = cur_gmr_rows.price_source_id
               and dqd.price_unit_id = cur_gmr_rows.price_unit_id
               and dq.corporate_id = cur_gmr_rows.corporate_id
               and dq.is_deleted = 'N'
               and dqd.is_deleted = 'N'
               and rownum < 2
               and dq.trade_date =
                   (select max(dq.trade_date)
                      from dq_derivative_quotes          dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_market_quote_dr_id
                       and dq.instrument_id = cur_gmr_rows.instrument_id
                       and dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                       and dq.price_source_id = cur_gmr_rows.price_source_id
                       and dqd.price_unit_id = cur_gmr_rows.price_unit_id
                       and dq.corporate_id = cur_gmr_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date <= pd_trade_date);
          exception
            when no_data_found then
              vn_unfixed_val_price         := 0;
              vc_unfixed_val_price_unit_id := null;
          end;
        
          --
          -- If Both Fixed and Unfixed Quantities are there then we have two prices
          -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
          --
          if vc_fixed_price_unit_id_pum <> vc_unfixed_val_price_unit_id then
            select f_get_converted_price_pum(cur_gmr_rows.corporate_id,
                                             vn_unfixed_val_price,
                                             vc_unfixed_val_price_unit_id,
                                             vc_fixed_price_unit_id_pum,
                                             pd_trade_date,
                                             cur_gmr_rows.product_id)
              into vn_unfixed_val_price
              from dual;
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
          vc_price_unit_id           := vc_fixed_price_unit_id;
          vn_total_quantity          := vn_fixed_qty + vn_unfixed_qty;
          vn_total_contract_value    := vn_total_contract_value +
                                        (vn_fixed_value + vn_unfixed_value);
          vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                        vn_fixed_qty + vn_unfixed_qty;
        end if;
      end loop;
      vn_total_unfixed_qty := cur_gmr_rows.payable_qty - vn_total_fixed_qty;
      if vn_total_qty_for_avg_price <> 0 then
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_qty_for_avg_price,
                                  4);
      else
        vn_average_price := 0;
      end if;
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_price_unit_id;
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
    
      select nvl((((nvl((pn_price), 0)) *
                 pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                            pum1.cur_id,
                                                            pum2.cur_id,
                                                            pd_trade_date,
                                                            1)) /
                 ((ucm.multiplication_factor * nvl(pum1.weight, 1)) /
                 nvl(pum2.weight, 1))),
                 0)
        into vn_result
        from pum_price_unit_master      pum1,
             pum_price_unit_master      pum2,
             ucm_unit_conversion_master ucm
       where pum1.price_unit_id = pc_from_price_unit_id
         and pum2.price_unit_id = pc_to_price_unit_id
         and pum1.weight_unit_id = ucm.from_qty_unit_id
         and pum2.weight_unit_id = ucm.to_qty_unit_id
         and pum1.is_deleted = 'N'
         and pum2.is_deleted = 'N';
      return vn_result;
    end if;
  exception
    when others then
      return 0;
  end;
  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean is
    vn_counter    number(1);
    vb_result_val boolean;
  begin
    --Checking the Week End Holiday List
    begin
      select count(*)
        into vn_counter
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
      if (vn_counter = 1) then
        vb_result_val := true;
      else
        vb_result_val := false;
      end if;
      if (vb_result_val = false) then
        --Checking Other Holiday List
        select count(*)
          into vn_counter
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
        if (vn_counter = 1) then
          vb_result_val := true;
        else
          vb_result_val := false;
        end if;
      end if;
    end;
    return vb_result_val;
  end;
  function f_get_next_month_prompt_date(pc_promp_del_cal_id varchar2,
                                        pd_trade_date       date) return date is
    cursor cur_monthly_prompt_rule is
      select mpc.*
        from mpc_monthly_prompt_calendar mpc
       where mpc.prompt_delivery_calendar_id = pc_promp_del_cal_id;
    cursor cr_applicable_months is
      select mpcm.*
        from mpcm_monthly_prompt_cal_month mpcm,
             mnm_month_name_master         mnm
       where mpcm.prompt_delivery_calendar_id = pc_promp_del_cal_id
         and mpcm.applicable_month = mnm.month_name_id
       order by mnm.display_order;
    vc_pdc_period_type_id      varchar2(15);
    vc_month_prompt_start_date date;
    vc_equ_period_type         number;
    cr_monthly_prompt_rule_rec cur_monthly_prompt_rule%rowtype;
    vc_period_to               number;
    vd_start_date              date;
    vd_end_date                date;
    vc_month                   varchar2(15);
    vn_year                    number;
    vn_month_count             number(5);
    vd_prompt_date             date;
  begin
    vc_month_prompt_start_date := pd_trade_date;
    vn_month_count             := 0;
    begin
      select pm.period_type_id
        into vc_pdc_period_type_id
        from pm_period_master pm
       where pm.period_type_name = 'Month';
    end;
    open cur_monthly_prompt_rule;
    fetch cur_monthly_prompt_rule
      into cr_monthly_prompt_rule_rec;
    vc_period_to := cr_monthly_prompt_rule_rec.period_for; --no of forward months required
    begin
      select pm.equivalent_days
        into vc_equ_period_type
        from pm_period_master pm
       where pm.period_type_id = cr_monthly_prompt_rule_rec.period_type_id;
    end;
    vd_start_date := vc_month_prompt_start_date;
    vd_end_date   := vc_month_prompt_start_date +
                     (vc_period_to * vc_equ_period_type);
    for cr_applicable_months_rec in cr_applicable_months
    loop
      vc_month_prompt_start_date := to_date(('01-' ||
                                            cr_applicable_months_rec.applicable_month || '-' ||
                                            to_char(vd_start_date, 'YYYY')),
                                            'dd/mm/yyyy');
      --------------------
      if (vc_month_prompt_start_date >=
         to_date(('01-' || to_char(vd_start_date, 'Mon-YYYY')),
                  'dd/mm/yyyy') and
         vc_month_prompt_start_date <= vd_end_date) then
        vn_month_count := vn_month_count + 1;
        if vn_month_count = 1 then
          vc_month := to_char(vc_month_prompt_start_date, 'Mon');
          vn_year  := to_char(vc_month_prompt_start_date, 'YYYY');
        end if;
      end if;
      exit when vn_month_count > 1;
      ---------------
    end loop;
    close cur_monthly_prompt_rule;
    if vc_month is not null and vn_year is not null then
      vd_prompt_date := to_date('01-' || vc_month || '-' || vn_year,
                                'dd-Mon-yyyy');
    end if;
    return vd_prompt_date;
  end;
end;
/
