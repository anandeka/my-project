create or replace package pkg_phy_cog_price is
  procedure sp_base_contract_cog_price(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2,
                                       pc_process      varchar2);
  procedure sp_base_gmr_cog_price(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process_id   varchar2,
                                  pc_user_id      varchar2,
                                  pc_process      varchar2);
  procedure sp_conc_contract_cog_price(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2,
                                       pc_process      varchar2);
  procedure sp_conc_gmr_cog_price(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_process_id   varchar2,
                                  pc_user_id      varchar2,
                                  pc_process      varchar2);
  procedure sp_conc_gmr_allocation_price(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2);
  procedure sp_base_gmr_allocation_price(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2);
  procedure sp_conc_gmr_di_price(pc_corporate_id varchar2,
                                 pd_trade_date   date,
                                 pc_process_id   varchar2,
                                 pc_user_id      varchar2,
                                 pc_process      varchar2);

  procedure sp_calc_instrument_price(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_process_id   varchar2,
                                     pc_process      varchar2,
                                     pc_user_id      varchar2);

end; 
/
create or replace package body pkg_phy_cog_price is
  procedure sp_base_contract_cog_price(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2,
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
    vn_unfixed_value             number;
    vn_unfixed_qty               number;
    vc_unfixed_val_price_unit_id varchar2(100);
    vn_unfixed_val_price         number;
    vn_fixed_value               number;
    vn_fixed_qty                 number;
    vc_data_missing_for          varchar2(1000);
    cursor cur_pcdi is
      select pcdi.pcdi_id,
             pcdi.internal_contract_ref_no,
             pcdi.price_option_call_off_status,
             pcm.contract_ref_no,
             diqs.total_qty item_qty,
             diqs.item_qty_unit_id item_qty_unit_id,
             pcpd.qty_unit_id,
             pcpd.product_id,
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
         and pcm.contract_status <> 'Cancelled'
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
             pcbpd.valuation_price_percentage / 100 valuation_price_percentage,
             pocd.pay_in_price_unit_id,
             pocd.pay_in_cur_id,
             cm.cur_code pay_in_cur_code,
             pofh.final_price_in_pay_in_cur,
             pofh.fx_price_to_pay_in,
             qum.qty_unit_id pay_in_price_unit_wt_unit_id,
             qum.qty_unit pay_in_price_unit_weight_unit,
             ppu.weight pay_in_price_unit_weight
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail pcbpd,
             pcbph_pc_base_price_header pcbph,
             (select pofh.pocd_id,
                     pofh.pofh_id,
                     pofh.final_price_in_pricing_cur,
                     pofh.finalize_date,
                     pofh.final_price final_price_in_pay_in_cur,
                     pofh.avg_fx fx_price_to_pay_in
                from pofh_price_opt_fixation_header pofh
               where pofh.is_active = 'Y'
                 and pofh.internal_gmr_ref_no is null) pofh,
             cm_currency_master cm,
             v_ppu_pum ppu,
             qum_quantity_unit_master qum
       where poch.pcdi_id = pc_pcdi_id
         and poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pcbpd.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pocd.pocd_id = pofh.pocd_id(+)
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y'
         and pcbpd.price_basis <> 'Fixed' --We are inserting for Fixed Contracts at the end of SP;
         and pocd.pay_in_cur_id = cm.cur_id
         and pocd.pay_in_price_unit_id = ppu.product_price_unit_id
         and ppu.weight_unit_id = qum.qty_unit_id
       order by nvl(pofh.final_price_in_pricing_cur, 0) desc;
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
             pcbpd.valuation_price_percentage / 100 valuation_price_percentage,
             ppu.product_price_unit_id pay_in_price_unit_id,
             ppu.cur_id pay_in_cur_id,
             cm.cur_code pay_in_cur_code
        from pci_physical_contract_item pci,
             pcipf_pci_pricing_formula  pcipf,
             pcbph_pc_base_price_header pcbph,
             pcbpd_pc_base_price_detail pcbpd,
             pcm_physical_contract_main pcm,
             pcdi_pc_delivery_item      pcdi,
             aml_attribute_master_list  aml,
             v_ppu_pum                  ppu,
             cm_currency_master         cm
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
         and pcbph.is_active = 'Y'
         and pci.pcdi_id = pcdi.pcdi_id
         and pcdi.process_id = pc_process_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.process_id = pc_process_id
         and aml.attribute_id = pcbpd.element_id
         and ppu.product_id = aml.underlying_product_id
         and ppu.cur_id = pcm.invoice_currency_id
         and ppu.weight_unit_id = pcdi.qty_unit_id
         and ppu.cur_id = cm.cur_id
         and pcbpd.price_basis <> 'Fixed';
  
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
    vn_error_no                number := 0;
    vc_fixed_price_unit_id     varchar2(15);
    vc_fixed_price_unit_id_pum varchar2(50);
    vc_pay_in_price_unit_id    varchar2(15);
    vc_pay_in_cur_id           varchar2(15);
    vc_pay_in_cur_code         varchar2(15);
    vc_is_final_priced         varchar2(1);
    vn_price_in_pay_in_cur     number;
    vn_cfx_price_to_pay        number;
    vc_pay_in_qty_unit_id      varchar2(15);
    vc_pay_in_qty_unit         varchar2(15);
    vn_pay_in_weight           number;
    vn_avg_fx_rate             number;
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
      vc_pay_in_price_unit_id      := null;
      vc_pay_in_cur_id             := null;
      vc_pay_in_cur_code           := null;
      vn_price_in_pay_in_cur       := 0;
      vc_pay_in_qty_unit_id        := null;
      vc_pay_in_qty_unit           := null;
      vn_pay_in_weight             := null;
      vn_avg_fx_rate               := 0;
      vn_total_qty_for_avg_price   := 0;
      if cur_pcdi_rows.price_option_call_off_status in
         ('Called Off', 'Not Applicable') then
        vc_price_fixation_status := null;
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id)
        loop
          vc_is_final_priced      := 'N'; -- Reset Everytime, To handle combo case
          vc_pay_in_price_unit_id := cur_called_off_rows.pay_in_price_unit_id;
          vc_pay_in_cur_id        := cur_called_off_rows.pay_in_cur_id;
          vc_pay_in_cur_code      := cur_called_off_rows.pay_in_cur_code;
          vn_total_quantity       := cur_pcdi_rows.item_qty;
          vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
          vc_price_basis          := cur_called_off_rows.price_basis;
          vc_pay_in_qty_unit_id   := cur_called_off_rows.pay_in_price_unit_wt_unit_id;
          vc_pay_in_qty_unit      := cur_called_off_rows.pay_in_price_unit_weight_unit;
          vn_pay_in_weight        := cur_called_off_rows.pay_in_price_unit_weight;
          if cur_called_off_rows.price_basis in ('Index', 'Formula') then
            if cur_called_off_rows.final_price <> 0 and
               cur_called_off_rows.finalize_date <= pd_trade_date then
              vn_total_contract_value    := vn_total_contract_value +
                                            (vn_total_quantity *
                                            (vn_qty_to_be_priced / 100)) *
                                            cur_called_off_rows.final_price;
              vc_price_unit_id           := cur_called_off_rows.final_price_unit_id;
              vc_is_final_priced         := 'Y';
              vn_price_in_pay_in_cur     := vn_price_in_pay_in_cur +
                                            (cur_called_off_rows.final_price_in_pay_in_cur *
                                            (vn_qty_to_be_priced / 100));
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
              if vc_fixed_price_unit_id is null then
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
            
              begin
                select tip.price *
                       cur_called_off_rows.valuation_price_percentage,
                       tip.price_unit_id,
                       tip.data_missing_for
                  into vn_unfixed_val_price,
                       vc_unfixed_val_price_unit_id,
                       vc_data_missing_for
                  from tip_temp_instrument_price tip
                 where tip.corporate_id = pc_corporate_id
                   and tip.instrument_id = cur_pcdi_rows.instrument_id;
                if vc_data_missing_for is not null then
                  vobj_error_log.extend;
                  vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                       'procedure pkg_phy_cog_price.sp_base_contract_cog_price',
                                                                       'PHY-002',
                                                                       vc_data_missing_for,
                                                                       cur_pcdi_rows.contract_ref_no,
                                                                       pc_process,
                                                                       pc_user_id,
                                                                       sysdate,
                                                                       pd_trade_date);
                  sp_insert_error_log(vobj_error_log);
                end if;
              exception
                when others then
                  null;
              end;
              --
              -- If Both Fixed and Unfixed Quantities are there then we have two prices
              -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
              --
              if vc_fixed_price_unit_id_pum <> vc_unfixed_val_price_unit_id then
                select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
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
          vc_price_basis             := cur_not_called_off_rows.price_basis;
          vn_total_quantity          := cur_pcdi_rows.item_qty;
          vn_qty_to_be_priced        := cur_not_called_off_rows.qty_to_be_priced;
          vc_is_final_priced         := 'N';
          vc_pay_in_price_unit_id    := cur_not_called_off_rows.pay_in_price_unit_id;
          vc_pay_in_cur_id           := cur_not_called_off_rows.pay_in_cur_id;
          vc_pay_in_cur_code         := cur_not_called_off_rows.pay_in_cur_code;
          vc_pay_in_qty_unit_id      := null;
          vc_pay_in_qty_unit         := null;
          vn_pay_in_weight           := null;
          vn_avg_fx_rate             := 0;
          vn_total_qty_for_avg_price := 0;
          if cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            begin
              select tip.price *
                     cur_not_called_off_rows.valuation_price_percentage,
                     tip.price_unit_id,
                     tip.data_missing_for
                into vn_unfixed_val_price,
                     vc_unfixed_val_price_unit_id,
                     vc_data_missing_for
                from tip_temp_instrument_price tip
               where tip.corporate_id = pc_corporate_id
                 and tip.instrument_id = cur_pcdi_rows.instrument_id;
              if vc_data_missing_for is not null then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure pkg_phy_cog_price.sp_base_contract_cog_price',
                                                                     'PHY-002',
                                                                     vc_data_missing_for,
                                                                     cur_pcdi_rows.contract_ref_no,
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
              end if;
            exception
              when others then
                null;
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
          vn_total_qty_for_avg_price := vn_total_qty_for_avg_price +
                                        ((vn_qty_to_be_priced / 100) *
                                        vn_total_quantity);
        end loop;
        if vn_total_qty_for_avg_price <> 0 then
          vn_average_price := round(vn_total_contract_value /
                                    vn_total_qty_for_avg_price,
                                    4);
        else
          vn_average_price := 0;
        end if;
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
      if vc_is_final_priced = 'N' then
        vn_price_in_pay_in_cur := null;
        vn_avg_fx_rate         := 1;
      else
        vn_price_in_pay_in_cur := round(vn_price_in_pay_in_cur, 4);
      end if;
      if vn_average_price is null then
        vn_average_price := 0;
      end if;
      if vc_price_unit_id is not null and vn_average_price <> 0 then
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
           price_basis,
           is_final_priced,
           pay_in_price_unit_id,
           pay_in_cur_id,
           pay_in_cur_code,
           pay_in_price_unit_wt_unit_id,
           pay_in_price_unit_weight_unit,
           pay_in_price_unit_weight,
           contract_price_in_pay_in,
           fx_price_to_pay)
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
           vc_price_basis,
           vc_is_final_priced,
           vc_pay_in_price_unit_id,
           vc_pay_in_cur_id,
           vc_pay_in_cur_code,
           vc_pay_in_qty_unit_id,
           vc_pay_in_qty_unit,
           vn_pay_in_weight,
           vn_price_in_pay_in_cur,
           vn_avg_fx_rate);
      end if;
    end loop;
    commit;
  
    --
    -- Where Price is Not Finalized Get the Corporate FX Rate from Price to Pay in and Update Exchange Rate 
    --
    for cur_corp_fx_rate in (select bccp.price_unit_cur_id,
                                    bccp.pay_in_cur_id
                               from bccp_base_contract_cog_price bccp
                              where bccp.process_id = pc_process_id
                                and bccp.is_final_priced = 'N'
                                and bccp.price_unit_cur_id <>
                                    bccp.pay_in_cur_id
                              group by bccp.price_unit_cur_id,
                                       bccp.pay_in_cur_id)
    loop
      begin
        select cet.exch_rate
          into vn_cfx_price_to_pay
          from cet_corporate_exch_rate cet
         where cet.from_cur_id = cur_corp_fx_rate.price_unit_cur_id
           and cet.to_cur_id = cur_corp_fx_rate.pay_in_cur_id
           and cet.corporate_id = pc_corporate_id;
      exception
        when others then
          vn_cfx_price_to_pay := -1;
      end;
      update bccp_base_contract_cog_price bccp
         set bccp.fx_price_to_pay = vn_cfx_price_to_pay
       where bccp.process_id = pc_process_id
         and bccp.price_unit_cur_id = cur_corp_fx_rate.price_unit_cur_id
         and bccp.pay_in_cur_id = cur_corp_fx_rate.pay_in_cur_id
         and bccp.is_final_priced = 'N';
    end loop;
    commit;
  
    --
    -- Update Price in Pay In Currency as Price in Pricing Currency X Exchange Rate from Price to Pay
    --
  
    update bccp_base_contract_cog_price bccp
       set bccp.contract_price_in_pay_in = bccp.contract_price *
                                           bccp.fx_price_to_pay
     where bccp.process_id = pc_process_id
       and bccp.is_final_priced = 'N';
    commit;
  
    for cur_fixed_price in (select pc_process_id process_id,
                                   pc_corporate_id corporate_id,
                                   poch.pcdi_id,
                                   pcbph.internal_contract_ref_no,
                                   pcm.contract_ref_no,
                                   pcbpd.price_value contract_price,
                                   pcbpd.price_unit_id,
                                   cm.cur_id price_unit_cur_id,
                                   cm.cur_code price_unit_cur_code,
                                   ppu.weight price_unit_weight,
                                   qum.qty_unit_id price_unit_weight_unit_id,
                                   qum.qty_unit price_unit_weight_unit,
                                   0 fixed_qty,
                                   0 unfixed_qty,
                                   pcbpd.price_basis,
                                   pocd.pay_in_cur_id,
                                   pocd.pay_in_price_unit_id,
                                   pffxd.fixed_fx_rate,
                                   qum_pay.qty_unit_id pay_in_price_unit_wt_unit_id,
                                   qum_pay.qty_unit pay_in_price_unit_weight_unit,
                                   ppu_pay.weight pay_in_price_unit_weight,
                                   cm_pay.cur_code pay_in_cur_code
                              from poch_price_opt_call_off_header poch,
                                   pocd_price_option_calloff_dtls pocd,
                                   pcbpd_pc_base_price_detail     pcbpd,
                                   pffxd_phy_formula_fx_details   pffxd,
                                   pcbph_pc_base_price_header     pcbph,
                                   pcm_physical_contract_main     pcm,
                                   v_ppu_pum                      ppu,
                                   cm_currency_master             cm,
                                   qum_quantity_unit_master       qum,
                                   v_ppu_pum                      ppu_pay,
                                   cm_currency_master             cm_pay,
                                   qum_quantity_unit_master       qum_pay
                             where poch.poch_id = pocd.poch_id
                               and pocd.pcbpd_id = pcbpd.pcbpd_id
                               and pcbpd.pcbph_id = pcbph.pcbph_id
                               and pcbpd.process_id = pc_process_id
                               and pffxd.pffxd_id = pcbpd.pffxd_id
                               and pffxd.process_id = pc_process_id
                               and pcbph.process_id = pc_process_id
                               and pcm.process_id = pc_process_id
                               and pcbph.internal_contract_ref_no =
                                   pcm.internal_contract_ref_no
                               and pcm.contract_type = 'BASEMETAL'
                               and poch.is_active = 'Y'
                               and pocd.is_active = 'Y'
                               and pcbpd.is_active = 'Y'
                               and pcbph.is_active = 'Y'
                               and pcbpd.price_basis = 'Fixed'
                               and ppu.product_price_unit_id =
                                   pcbpd.price_unit_id
                               and ppu.cur_id = cm.cur_id
                               and ppu.weight_unit_id = qum.qty_unit_id
                               and ppu_pay.product_price_unit_id =
                                   pocd.pay_in_price_unit_id
                               and ppu_pay.cur_id = cm_pay.cur_id
                               and ppu_pay.weight_unit_id =
                                   qum_pay.qty_unit_id)
    loop
      insert into bccp_base_contract_cog_price
        (process_id,
         corporate_id,
         pcdi_id,
         internal_contract_ref_no,
         contract_ref_no,
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
         is_final_priced,
         pay_in_price_unit_id,
         pay_in_cur_id,
         pay_in_cur_code,
         pay_in_price_unit_wt_unit_id,
         pay_in_price_unit_weight_unit,
         pay_in_price_unit_weight,
         fx_price_to_pay,
         contract_price_in_pay_in)
      values
        (cur_fixed_price.process_id,
         cur_fixed_price.corporate_id,
         cur_fixed_price.pcdi_id,
         cur_fixed_price.internal_contract_ref_no,
         cur_fixed_price.contract_ref_no,
         cur_fixed_price.contract_price,
         cur_fixed_price.price_unit_id,
         cur_fixed_price.price_unit_cur_id,
         cur_fixed_price.price_unit_cur_code,
         cur_fixed_price.price_unit_weight,
         cur_fixed_price.price_unit_weight_unit_id,
         cur_fixed_price.price_unit_weight_unit,
         cur_fixed_price.fixed_qty,
         cur_fixed_price.unfixed_qty,
         cur_fixed_price.price_basis,
         'Y',
         cur_fixed_price.pay_in_price_unit_id,
         cur_fixed_price.pay_in_cur_id,
         cur_fixed_price.pay_in_cur_code,
         cur_fixed_price.pay_in_price_unit_wt_unit_id,
         cur_fixed_price.pay_in_price_unit_weight_unit,
         cur_fixed_price.pay_in_price_unit_weight,
         
         cur_fixed_price.fixed_fx_rate,
         cur_fixed_price.fixed_fx_rate * cur_fixed_price.contract_price);
    end loop;
    commit;
    sp_gather_stats('bccp_base_contract_cog_price');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_cog_price.sp_base_contract_cog_price',
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
                                  pc_process      varchar2) is
    cursor cur_gmr is
      select grd.product_id,
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
             pdc.is_monthly_cal_applicable,
             gmr.pcdi_id
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
      select grd.product_id,
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
             pdc.is_monthly_cal_applicable,
             gmr.pcdi_id
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
             pcbpd.price_basis,
             nvl(pofh.final_price_in_pricing_cur, 0) final_price,
             pofh.finalize_date,
             pocd.final_price_unit_id,
             pcbpd.valuation_price_percentage / 100 valuation_price_percentage,
             pocd.pay_in_price_unit_id,
             pofh.final_price final_price_in_pay_in_cur,
             pocd.pay_in_cur_id,
             cm.cur_code pay_in_cur_code,
             pofh.avg_fx fx_price_to_pay_in,
             qum.qty_unit_id pay_in_price_unit_wt_unit_id,
             qum.qty_unit pay_in_price_unit_weight_unit,
             ppu.weight pay_in_price_unit_weight
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             cm_currency_master             cm,
             v_ppu_pum                      ppu,
             qum_quantity_unit_master       qum
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
         and pcbph.is_active = 'Y'
         and pocd.pay_in_cur_id = cm.cur_id
         and ppu.product_price_unit_id = pocd.pay_in_price_unit_id
         and ppu.weight_unit_id = qum.qty_unit_id
       order by nvl(pofh.final_price_in_pricing_cur, 0) desc;
  
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
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
    vn_unfixed_val_price         number;
    vc_unfixed_val_price_unit_id varchar2(15);
    vn_qty_to_be_priced          number;
    vc_price_unit_id             varchar2(15);
    vc_price_basis               varchar2(15);
    vn_average_price             number;
    vn_unfixed_value             number;
    vc_data_missing_for          varchar2(1000);
    vc_fixed_price_unit_id_pum   varchar2(50);
    vc_pay_in_price_unit_id      varchar2(15);
    vc_pay_in_cur_id             varchar2(15);
    vc_pay_in_cur_code           varchar2(15);
    vc_is_final_priced           varchar2(1);
    vn_price_in_pay_in_cur       number;
    vc_pay_in_qty_unit_id        varchar2(15);
    vc_pay_in_qty_unit           varchar2(15);
    vn_pay_in_weight             number;
    vn_avg_fx_rate               number;
    vn_total_qty_for_avg_price   number;
    vn_total_qty_to_be_priced    number; -- For combo pricing if event based is partial and it has % of DI Price
    vc_di_final_priced           varchar2(1);
    vn_di_price                  number;
    vn_di_price_in_pay_in_cur    number;
    vn_di_avg_fx_rate            number;
  
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
      vc_pay_in_qty_unit_id        := null;
      vc_pay_in_qty_unit           := null;
      vn_pay_in_weight             := null;
      vn_avg_fx_rate               := 0;
      vn_total_qty_for_avg_price   := 0;
      vn_total_qty_to_be_priced    := 0;
    
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no)
      loop
        vn_total_qty_to_be_priced := vn_total_qty_to_be_priced +
                                     cur_gmr_ele_rows.qty_to_be_priced;
        vc_is_final_priced        := 'N'; -- Reset Everytime, To handle combo case
        vc_pay_in_price_unit_id   := cur_gmr_ele_rows.pay_in_price_unit_id;
        vc_pay_in_cur_id          := cur_gmr_ele_rows.pay_in_cur_id;
        vc_pay_in_cur_code        := cur_gmr_ele_rows.pay_in_cur_code;
        vn_qty_to_be_priced       := cur_gmr_ele_rows.qty_to_be_priced;
        vc_price_basis            := cur_gmr_ele_rows.price_basis;
        vc_pay_in_qty_unit_id     := cur_gmr_ele_rows.pay_in_price_unit_wt_unit_id;
        vc_pay_in_qty_unit        := cur_gmr_ele_rows.pay_in_price_unit_weight_unit;
        vn_pay_in_weight          := cur_gmr_ele_rows.pay_in_price_unit_weight;
        if cur_gmr_ele_rows.final_price <> 0 and
           cur_gmr_ele_rows.finalize_date <= pd_trade_date then
        
          vn_total_contract_value := vn_total_contract_value +
                                     vn_total_quantity *
                                     (vn_qty_to_be_priced / 100) *
                                     cur_gmr_ele_rows.final_price;
          vc_price_unit_id        := cur_gmr_ele_rows.final_price_unit_id;
          vc_is_final_priced      := 'Y';
          vn_price_in_pay_in_cur  := vn_price_in_pay_in_cur +
                                     (cur_gmr_ele_rows.final_price_in_pay_in_cur *
                                     (vn_qty_to_be_priced / 100));
        
          vn_avg_fx_rate             := vn_avg_fx_rate +
                                        (cur_gmr_ele_rows.fx_price_to_pay_in *
                                        (vn_qty_to_be_priced / 100));
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
          if vc_fixed_price_unit_id is null then
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
        
          begin
            select tip.price * cur_gmr_ele_rows.valuation_price_percentage,
                   tip.price_unit_id,
                   tip.data_missing_for
              into vn_unfixed_val_price,
                   vc_unfixed_val_price_unit_id,
                   vc_data_missing_for
              from tip_temp_instrument_price tip
             where tip.corporate_id = pc_corporate_id
               and tip.instrument_id = cur_gmr_rows.instrument_id;
            if vc_data_missing_for is not null then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure pkg_phy_cog_price.sp_base_gmr_cog_price',
                                                                   'PHY-002',
                                                                   vc_data_missing_for,
                                                                   cur_gmr_rows.gmr_ref_no,
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            end if;
          exception
            when others then
              null;
          end;
          --
          -- If Both Fixed and Unfixed Quantities are there then we have two prices
          -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
          --
          if vc_fixed_price_unit_id_pum <> vc_unfixed_val_price_unit_id then
            select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
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
      if vn_average_price is null then
        vn_average_price := 0;
      end if;
      if vn_average_price <> 0 and vc_price_unit_id is not null then
        if vn_total_qty_to_be_priced = 100 then
          --Combo or Non Combo 100% is price from Event Based Pricing
          if vc_is_final_priced = 'N' then
            vn_price_in_pay_in_cur := null;
            vn_avg_fx_rate         := 1;
          else
            vn_price_in_pay_in_cur := round(vn_price_in_pay_in_cur, 4);
          end if;
        else
          --
          -- If combo price case and some portion is DI based
          -- Get the DI Price Details
          -- DI Price has to be in the same price unit as that of event based GMR
          --
          begin
            select bccp.is_final_priced,
                   bccp.contract_price,
                   bccp.contract_price_in_pay_in,
                   bccp.fx_price_to_pay
              into vc_di_final_priced,
                   vn_di_price,
                   vn_di_price_in_pay_in_cur,
                   vn_di_avg_fx_rate
              from bccp_base_contract_cog_price bccp
             where bccp.pcdi_id = cur_gmr_rows.pcdi_id
               and bccp.process_id = pc_process_id;
          exception
            when others then
              vc_di_final_priced := 'N';
              vn_di_price        := 0;
          end;
          -- GMR is final prices only if DI and Event base portion are final priced
          if vc_is_final_priced = 'Y' and vc_di_final_priced = 'Y' then
            vc_is_final_priced := 'Y';
          else
            vc_is_final_priced := 'N';
          end if;
          --
          -- Modify the price in price currency based on Event Based + DI Combination
          --
          vn_average_price := ((vn_average_price *
                              vn_total_qty_to_be_priced) +
                              (vn_di_price *
                              (100 - vn_total_qty_to_be_priced))) / 100;
        
          if vc_is_final_priced = 'N' then
            vn_price_in_pay_in_cur := null;
            vn_avg_fx_rate         := 1;
          else
            -- Modify the price and FX Rate in pay in currency based on Event Based + DI Combination
            vn_price_in_pay_in_cur := round(vn_price_in_pay_in_cur, 4);
            vn_price_in_pay_in_cur := ((vn_price_in_pay_in_cur *
                                      vn_total_qty_to_be_priced) +
                                      (vn_di_price_in_pay_in_cur *
                                      (100 - vn_total_qty_to_be_priced))) / 100;
          
            vn_avg_fx_rate := ((vn_avg_fx_rate * vn_total_qty_to_be_priced) +
                              (vn_di_avg_fx_rate *
                              (100 - vn_total_qty_to_be_priced))) / 100;
          end if;
        end if;
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
           internal_grd_ref_no,
           is_final_priced,
           pay_in_price_unit_id,
           pay_in_cur_id,
           pay_in_cur_code,
           pay_in_price_unit_wt_unit_id,
           pay_in_price_unit_weight_unit,
           pay_in_price_unit_weight,
           contract_price_in_pay_in,
           fx_price_to_pay,
           pcdi_id)
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
           cur_gmr_rows.internal_grd_ref_no,
           vc_is_final_priced,
           vc_pay_in_price_unit_id,
           vc_pay_in_cur_id,
           vc_pay_in_cur_code,
           vc_pay_in_qty_unit_id,
           vc_pay_in_qty_unit,
           vn_pay_in_weight,
           vn_price_in_pay_in_cur,
           vn_avg_fx_rate,
           cur_gmr_rows.pcdi_id);
      end if;
    end loop;
    commit;
  end;
  procedure sp_conc_contract_cog_price(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2,
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
      select pcdi_id,
             internal_contract_ref_no,
             element_id,
             payable_qty,
             payable_qty_unit_id,
             contract_ref_no,
             product_id,
             instrument_id,
             instrument_name,
             price_source_id,
             price_source_name,
             available_price_id,
             available_price_name,
             price_unit_name,
             price_unit_id,
             delivery_calender_id,
             is_daily_cal_applicable,
             is_monthly_cal_applicable,
             price_option_call_off_status
        from cpt1_conc_price_temp1
       where corporate_id = pc_corporate_id;
    cursor cur_called_off(pc_pcdi_id varchar2, pc_element_id varchar2) is
      select t.poch_id,
             t.pofh_id,
             t.pcbpd_id,
             t.price_basis,
             t.price_value,
             t.price_unit_id,
             t.qty_to_be_priced,
             t.final_price,
             t.finalize_date,
             t.final_price_unit_id,
             t.valuation_price_percentage,
             t.pay_in_price_unit_id,
             t.final_price_in_pay_in_cur,
             t.pay_in_cur_id,
             t.pay_in_cur_code,
             t.pay_in_price_unit_weight,
             t.pay_in_price_unit_wt_unit_id,
             t.pay_in_price_unit_weight_unit,
             t.fx_price_to_pay_in
        from cpt2_conc_price_temp2 t
       where t.pcdi_id = pc_pcdi_id
         and t.element_id = pc_element_id
       order by nvl(t.final_price, 0) desc;
    -- For combo Price if one part is not finalized, let it be at the end
    -- so we know that it is not final priced at DI level
    cursor cur_not_called_off(pc_pcdi_id varchar2, pc_element_id varchar2) is
      select pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.qty_to_be_priced,
             pcbpd.price_unit_id,
             pcbph.price_description,
             pcbpd.valuation_price_percentage / 100 valuation_price_percentage,
             ppu.product_price_unit_id pay_in_price_unit_id,
             ppu.cur_id pay_in_cur_id,
             cm.cur_code pay_in_cur_code
        from pci_physical_contract_item pci,
             pcipf_pci_pricing_formula  pcipf,
             pcbph_pc_base_price_header pcbph,
             pcbpd_pc_base_price_detail pcbpd,
             pcm_physical_contract_main pcm,
             pcdi_pc_delivery_item      pcdi,
             aml_attribute_master_list  aml,
             v_ppu_pum                  ppu,
             cm_currency_master         cm
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
         and pcbph.is_active = 'Y'
         and pci.pcdi_id = pcdi.pcdi_id
         and pcdi.process_id = pc_process_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.process_id = pc_process_id
         and aml.attribute_id = pcbpd.element_id
         and ppu.product_id = aml.underlying_product_id
         and ppu.cur_id = pcm.invoice_currency_id
         and ppu.weight_unit_id = pcdi.qty_unit_id
         and ppu.cur_id = cm.cur_id
         and pcbpd.price_basis <> 'Fixed';
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vc_price_unit_id             varchar2(15);
    vn_total_quantity            number;
    vn_total_contract_value      number;
    vn_qty_to_be_priced          number;
    vn_average_price             number;
    vc_price_basis               varchar2(15);
    vc_price_option_call_off_sts varchar2(50);
    vn_fixed_value               number;
    vn_fixed_qty                 number;
    vc_fixed_price_unit_id       varchar2(15);
    vn_unfixed_qty               number;
    vn_unfixed_val_price         number;
    vc_unfixed_val_price_unit_id varchar2(15);
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
    vc_pay_in_price_unit_id      varchar2(15);
    vc_pay_in_cur_id             varchar2(15);
    vc_pay_in_cur_code           varchar2(15);
    vc_is_final_priced           varchar2(1);
    vn_price_in_pay_in_cur       number;
    vn_cfx_price_to_pay          number;
    vc_pay_in_qty_unit_id        varchar2(15);
    vc_pay_in_qty_unit           varchar2(15);
    vn_pay_in_weight             number;
    vn_avg_fx_rate               number;
    vn_total_qty_for_avg_price   number;
    vn_total_final_priced        number;
  begin
    sp_gather_stats('pcbph_pc_base_price_header');
    sp_gather_stats('pcbpd_pc_base_price_detail');
    sp_gather_stats('poch_price_opt_call_off_header');
    sp_gather_stats('pocd_price_option_calloff_dtls');
    sp_gather_stats('pofh_price_opt_fixation_header');
    sp_gather_stats('dq_derivative_quotes');
    sp_gather_stats('dqd_derivative_quote_detail');
    sp_gather_stats('cdim_corporate_dim');
    sp_gather_stats('drm_derivative_master');
    sp_gather_stats('cm_currency_master');
    sp_gather_stats('qum_quantity_unit_master');
    sp_gather_stats('pfd_price_fixation_details');
    sp_gather_stats('pci_physical_contract_item');
    sp_gather_stats('pcm_physical_contract_main');
    sp_gather_stats('pcipf_pci_pricing_formula');
    sp_gather_stats('pcbph_pc_base_price_header');
    sp_gather_stats('pcbpd_pc_base_price_detail');
    sp_gather_stats('ppfh_phy_price_formula_header');
    sp_gather_stats('pfqpp_phy_formula_qp_pricing');
    sp_gather_stats('ppu_product_price_units');
    sp_gather_stats('pum_price_unit_master');
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          330,
                          'Stats Inside Sp_Conc_Contract_Cog_Price Over');
  
    sp_calc_instrument_price(pc_corporate_id,
                             pd_trade_date,
                             pc_process_id,
                             pc_process,
                             pc_user_id);
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          331,
                          'Instrument COG Price End');
  
    delete from cpt1_conc_price_temp1 where corporate_id = pc_corporate_id;
    commit;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          332,
                          'Delete cpt1_conc_price_temp1 Over');
    insert into cpt1_conc_price_temp1
      (corporate_id,
       pcdi_id,
       internal_contract_ref_no,
       element_id,
       payable_qty,
       payable_qty_unit_id,
       contract_ref_no,
       product_id,
       instrument_id,
       instrument_name,
       price_source_id,
       price_source_name,
       available_price_id,
       available_price_name,
       price_unit_name,
       price_unit_id,
       delivery_calender_id,
       is_daily_cal_applicable,
       is_monthly_cal_applicable,
       price_option_call_off_status)
      select pc_corporate_id,
             pcdi.pcdi_id,
             pcdi.internal_contract_ref_no,
             dipq.element_id,
             dipq.payable_qty,
             dipq.qty_unit_id payable_qty_unit_id,
             pcm.contract_ref_no,
             pcpd.product_id,
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
         and pcm.contract_status <> 'Cancelled'
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
    commit;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          333,
                          'Insert cpt1_conc_price_temp1 Over');
    delete from cpt2_conc_price_temp2 where corporate_id = pc_corporate_id;
    commit;
    insert into cpt2_conc_price_temp2
      (corporate_id,
       pcdi_id,
       element_id,
       poch_id,
       pofh_id,
       pcbpd_id,
       price_basis,
       price_value,
       price_unit_id,
       qty_to_be_priced,
       final_price,
       finalize_date,
       final_price_unit_id,
       valuation_price_percentage,
       pay_in_price_unit_id,
       final_price_in_pay_in_cur,
       pay_in_cur_id,
       pay_in_cur_code,
       pay_in_price_unit_weight,
       pay_in_price_unit_wt_unit_id,
       pay_in_price_unit_weight_unit,
       fx_price_to_pay_in)
      select pc_corporate_id,
             poch.pcdi_id,
             pcbpd.element_id,
             poch.poch_id,
             pofh.pofh_id,
             pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.qty_to_be_priced,
             nvl(pofh.final_price_in_pricing_cur, 0) final_price,
             pofh.finalize_date,
             pocd.final_price_unit_id,
             pcbpd.valuation_price_percentage / 100 valuation_price_percentage,
             pocd.pay_in_price_unit_id,
             pofh.final_price_in_pay_in_cur,
             pocd.pay_in_cur_id,
             cm.cur_code pay_in_cur_code,
             ppu.weight,
             ppu.weight_unit_id,
             qum.qty_unit,
             nvl(pofh.avg_fx, 1) fx_price_to_pay_in
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail pcbpd,
             pcbph_pc_base_price_header pcbph,
             (select pofh.pocd_id,
                     pofh.pofh_id,
                     pofh.final_price_in_pricing_cur,
                     pofh.finalize_date,
                     pofh.final_price final_price_in_pay_in_cur,
                     pofh.avg_fx
                from pofh_price_opt_fixation_header pofh
               where pofh.is_active = 'Y'
                 and pofh.internal_gmr_ref_no is null) pofh,
             cm_currency_master cm,
             v_ppu_pum ppu,
             qum_quantity_unit_master qum
       where poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pcbpd.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pocd.pocd_id = pofh.pocd_id(+)
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y'
         and pcbpd.price_basis <> 'Fixed' -- We are inserting for Fixed Contracts at the end of SP
         and pocd.pay_in_cur_id = cm.cur_id
         and ppu.product_price_unit_id = pocd.pay_in_price_unit_id
         and ppu.weight_unit_id = qum.qty_unit_id;
  
    commit;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          334,
                          'Insert cpt2_conc_price_temp2 Over');
    vc_error_message := 'Start';
    for cur_pcdi_rows in cur_pcdi
    loop
      vn_total_final_priced        := 0;
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
      vc_pay_in_price_unit_id      := null;
      vc_pay_in_cur_id             := null;
      vc_pay_in_cur_code           := null;
      vn_price_in_pay_in_cur       := 0;
      vc_pay_in_qty_unit_id        := null;
      vc_pay_in_qty_unit           := null;
      vn_pay_in_weight             := null;
      vn_avg_fx_rate               := 0;
      vn_total_qty_for_avg_price   := 0;
      if vc_price_option_call_off_sts in ('Called Off', 'Not Applicable') then
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id,
                                                  cur_pcdi_rows.element_id)
        loop
          -- vc_is_final_priced      := 'N'; -- Reset Everytime, To handle combo case
          vc_price_basis          := cur_called_off_rows.price_basis;
          vc_pay_in_price_unit_id := cur_called_off_rows.pay_in_price_unit_id;
          vc_pay_in_cur_id        := cur_called_off_rows.pay_in_cur_id;
          vc_pay_in_cur_code      := cur_called_off_rows.pay_in_cur_code;
          vc_pay_in_qty_unit_id   := cur_called_off_rows.pay_in_price_unit_wt_unit_id;
          vc_pay_in_qty_unit      := cur_called_off_rows.pay_in_price_unit_weight_unit;
          vn_pay_in_weight        := cur_called_off_rows.pay_in_price_unit_weight;
          if cur_called_off_rows.price_basis in ('Index', 'Formula') then
            vn_qty_to_be_priced := cur_called_off_rows.qty_to_be_priced;
            vn_total_quantity   := cur_pcdi_rows.payable_qty;
          
            if cur_called_off_rows.final_price <> 0 and
               cur_called_off_rows.finalize_date <= pd_trade_date then
              vn_total_final_priced   := vn_total_final_priced +
                                         (vn_qty_to_be_priced / 100);
              vn_total_contract_value := vn_total_contract_value +
                                         vn_total_quantity *
                                         (vn_qty_to_be_priced / 100) *
                                         cur_called_off_rows.final_price;
              vc_price_unit_id        := cur_called_off_rows.final_price_unit_id;
              vc_fixed_price_unit_id  := cur_called_off_rows.final_price_unit_id;
              vn_total_fixed_qty      := vn_total_fixed_qty +
                                         (vn_total_quantity *
                                         (vn_qty_to_be_priced / 100));
            
              /*  vc_is_final_priced         := 'Y';
              */
              vn_price_in_pay_in_cur     := vn_price_in_pay_in_cur +
                                            (cur_called_off_rows.final_price_in_pay_in_cur *
                                            (vn_qty_to_be_priced / 100));
              vn_avg_fx_rate             := vn_avg_fx_rate +
                                            (cur_called_off_rows.fx_price_to_pay_in *
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
              if vc_fixed_price_unit_id is null then
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
            
              begin
                select tip.price *
                       cur_called_off_rows.valuation_price_percentage,
                       tip.price_unit_id,
                       tip.data_missing_for
                  into vn_unfixed_val_price,
                       vc_unfixed_val_price_unit_id,
                       vc_data_missing_for
                  from tip_temp_instrument_price tip
                 where tip.corporate_id = pc_corporate_id
                   and tip.instrument_id = cur_pcdi_rows.instrument_id;
                if vc_data_missing_for is not null then
                  vobj_error_log.extend;
                  vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                       'procedure pkg_phy_cog_price.sp_conc_contract_cog_price',
                                                                       'PHY-002',
                                                                       vc_data_missing_for,
                                                                       cur_pcdi_rows.contract_ref_no,
                                                                       pc_process,
                                                                       pc_user_id,
                                                                       sysdate,
                                                                       pd_trade_date);
                  sp_insert_error_log(vobj_error_log);
                end if;
              exception
                when others then
                  null;
              end;
              --
              -- If Both Fixed and Unfixed Quantities are there then we have two prices
              -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
              --
              vc_error_message := ' Line 431 ';
              if vc_fixed_price_unit_id_pum <> vc_unfixed_val_price_unit_id then
                select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
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
          --  vc_is_final_priced      := 'N';
          vc_price_basis          := cur_not_called_off_rows.price_basis;
          vc_pay_in_price_unit_id := cur_not_called_off_rows.pay_in_price_unit_id;
          vc_pay_in_cur_id        := cur_not_called_off_rows.pay_in_cur_id;
          vc_pay_in_cur_code      := cur_not_called_off_rows.pay_in_cur_code;
          if cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            vn_total_fixed_qty := 0;
            begin
              select tip.price *
                     cur_not_called_off_rows.valuation_price_percentage,
                     tip.price_unit_id,
                     tip.data_missing_for
                into vn_unfixed_val_price,
                     vc_unfixed_val_price_unit_id,
                     vc_data_missing_for
                from tip_temp_instrument_price tip
               where tip.corporate_id = pc_corporate_id
                 and tip.instrument_id = cur_pcdi_rows.instrument_id;
              if vc_data_missing_for is not null then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure pkg_phy_cog_price.sp_conc_contract_cog_price.',
                                                                     'PHY-002',
                                                                     vc_data_missing_for,
                                                                     cur_pcdi_rows.contract_ref_no,
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
              end if;
            exception
              when others then
                null;
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
      ---   if combo price  and all the portions are final priced  
      if vn_total_final_priced = 1 then
        vc_is_final_priced := 'Y';
      else
        vc_is_final_priced := 'N';
      end if;
    
      if vc_is_final_priced = 'N' then
        vn_price_in_pay_in_cur := null;
        vn_avg_fx_rate         := 1;
      else
        vn_price_in_pay_in_cur := round(vn_price_in_pay_in_cur, 4);
      end if;
      if vn_average_price is null then
        vn_average_price := 0;
      end if;
      if vn_average_price <> 0 and vc_price_unit_id is not null then
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
           price_basis,
           is_final_priced,
           pay_in_price_unit_id,
           pay_in_cur_id,
           pay_in_cur_code,
           pay_in_price_unit_wt_unit_id,
           pay_in_price_unit_weight_unit,
           pay_in_price_unit_weight,
           contract_price_in_pay_in,
           fx_price_to_pay)
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
           vn_total_fixed_qty,
           vn_total_unfixed_qty,
           vc_price_basis,
           vc_is_final_priced,
           vc_pay_in_price_unit_id,
           vc_pay_in_cur_id,
           vc_pay_in_cur_code,
           vc_pay_in_qty_unit_id,
           vc_pay_in_qty_unit,
           vn_pay_in_weight,
           vn_price_in_pay_in_cur,
           vn_avg_fx_rate);
      end if;
    end loop;
    commit;
  
    --
    -- Where Price is Not Finalized Get the Corporate FX Rate from Price to Pay in and Update Exchange Rate 
    --
    for cur_corp_fx_rate in (select cccp.price_unit_cur_id,
                                    cccp.pay_in_cur_id
                               from cccp_conc_contract_cog_price cccp
                              where cccp.process_id = pc_process_id
                                and cccp.is_final_priced = 'N'
                                and cccp.price_unit_cur_id <>
                                    cccp.pay_in_cur_id
                              group by cccp.price_unit_cur_id,
                                       cccp.pay_in_cur_id)
    loop
      begin
        select cet.exch_rate
          into vn_cfx_price_to_pay
          from cet_corporate_exch_rate cet
         where cet.from_cur_id = cur_corp_fx_rate.price_unit_cur_id
           and cet.to_cur_id = cur_corp_fx_rate.pay_in_cur_id
           and cet.corporate_id = pc_corporate_id;
      exception
        when others then
          vn_cfx_price_to_pay := -1;
      end;
      update cccp_conc_contract_cog_price cccp
         set cccp.fx_price_to_pay = vn_cfx_price_to_pay
       where cccp.process_id = pc_process_id
         and cccp.price_unit_cur_id = cur_corp_fx_rate.price_unit_cur_id
         and cccp.pay_in_cur_id = cur_corp_fx_rate.pay_in_cur_id
         and cccp.is_final_priced = 'N';
    end loop;
    commit;
  
    --
    -- Update Price in Pay In Currency as Price in Pricing Currency X Exchange Rate from Price to Pay
    --
  
    update cccp_conc_contract_cog_price cccp
       set cccp.contract_price_in_pay_in = cccp.contract_price *
                                           cccp.fx_price_to_pay
     where cccp.process_id = pc_process_id
       and cccp.is_final_priced = 'N';
    commit;
    --
    -- Price For Fixed Price
    --
    for cur_fixed_price in (select pc_process_id process_id,
                                   pc_corporate_id corporate_id,
                                   poch.pcdi_id,
                                   pcbph.internal_contract_ref_no,
                                   pcm.contract_ref_no,
                                   pcbpd.element_id,
                                   null as payable_qty,
                                   null as payable_qty_unit_id,
                                   pcbpd.price_value contract_price,
                                   pcbpd.price_unit_id,
                                   cm.cur_id price_unit_cur_id,
                                   cm.cur_code price_unit_cur_code,
                                   ppu.weight price_unit_weight,
                                   qum.qty_unit_id price_unit_weight_unit_id,
                                   qum.qty_unit price_unit_weight_unit,
                                   0 fixed_qty,
                                   0 unfixed_qty,
                                   pcbpd.price_basis,
                                   pocd.pay_in_cur_id,
                                   cm.cur_code as pay_in_cur_code,
                                   pocd.pay_in_price_unit_id,
                                   pffxd.fixed_fx_rate,
                                   qum_pay.qty_unit_id pay_in_price_unit_wt_unit_id,
                                   qum_pay.qty_unit pay_in_price_unit_weight_unit,
                                   ppu_pay.weight pay_in_price_unit_weight
                              from poch_price_opt_call_off_header poch,
                                   pocd_price_option_calloff_dtls pocd,
                                   pcbpd_pc_base_price_detail     pcbpd,
                                   pffxd_phy_formula_fx_details   pffxd,
                                   pcbph_pc_base_price_header     pcbph,
                                   pcm_physical_contract_main     pcm,
                                   v_ppu_pum                      ppu,
                                   cm_currency_master             cm,
                                   qum_quantity_unit_master       qum,
                                   v_ppu_pum                      ppu_pay,
                                   cm_currency_master             cm_pay,
                                   qum_quantity_unit_master       qum_pay
                             where poch.poch_id = pocd.poch_id
                               and pocd.pcbpd_id = pcbpd.pcbpd_id
                               and pcbpd.pcbph_id = pcbph.pcbph_id
                               and pffxd.pffxd_id = pcbpd.pffxd_id
                               and pffxd.process_id = pc_process_id
                               and pcbpd.process_id = pc_process_id
                               and pcbph.process_id = pc_process_id
                               and pcm.process_id = pc_process_id
                               and pcbph.internal_contract_ref_no =
                                   pcm.internal_contract_ref_no
                               and pcm.contract_type = 'CONCENTRATES'
                               and poch.is_active = 'Y'
                               and pocd.is_active = 'Y'
                               and pcbpd.is_active = 'Y'
                               and pcbph.is_active = 'Y'
                               and pcbpd.price_basis = 'Fixed'
                               and ppu.product_price_unit_id =
                                   pcbpd.price_unit_id
                               and ppu.cur_id = cm.cur_id
                               and ppu.weight_unit_id = qum.qty_unit_id
                               and ppu_pay.product_price_unit_id =
                                   pocd.pay_in_price_unit_id
                               and ppu_pay.cur_id = cm_pay.cur_id
                               and ppu_pay.weight_unit_id =
                                   qum_pay.qty_unit_id)
    loop
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
         price_basis,
         is_final_priced,
         pay_in_price_unit_id,
         pay_in_cur_id,
         pay_in_cur_code,
         pay_in_price_unit_wt_unit_id,
         pay_in_price_unit_weight_unit,
         pay_in_price_unit_weight,
         fx_price_to_pay,
         contract_price_in_pay_in)
      values
        (cur_fixed_price.process_id,
         cur_fixed_price.corporate_id,
         cur_fixed_price.pcdi_id,
         cur_fixed_price.internal_contract_ref_no,
         cur_fixed_price.contract_ref_no,
         cur_fixed_price.element_id,
         cur_fixed_price.payable_qty,
         cur_fixed_price.payable_qty_unit_id,
         cur_fixed_price.contract_price,
         cur_fixed_price.price_unit_id,
         cur_fixed_price.price_unit_cur_id,
         cur_fixed_price.price_unit_cur_code,
         cur_fixed_price.price_unit_weight,
         cur_fixed_price.price_unit_weight_unit_id,
         cur_fixed_price.price_unit_weight_unit,
         cur_fixed_price.payable_qty,
         0,
         cur_fixed_price.price_basis,
         'Y',
         cur_fixed_price.pay_in_price_unit_id,
         cur_fixed_price.pay_in_cur_id,
         cur_fixed_price.pay_in_cur_code,
         cur_fixed_price.pay_in_price_unit_wt_unit_id,
         cur_fixed_price.pay_in_price_unit_weight_unit,
         cur_fixed_price.pay_in_price_unit_weight,
         cur_fixed_price.fixed_fx_rate,
         cur_fixed_price.fixed_fx_rate * cur_fixed_price.contract_price);
    end loop;
    commit;
    sp_gather_stats('cccp_conc_contract_cog_price');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_cog_price.sp_conc_contract_cog_price',
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
             gmr.pcdi_id
        from gmr_goods_movement_record gmr,
             gpq_gmr_payable_qty       gpq,
             ged_gmr_exchange_detail   tt
       where gmr.gmr_type = 'CONCENTRATES'
         and gmr.contract_type <> 'Tolling'
         and gpq.process_id = pc_process_id
         and tt.element_id = gpq.element_id
         and tt.internal_gmr_ref_no = gpq.internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
         and gmr.corporate_id = tt.corporate_id(+)
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
             pcbpd.valuation_price_percentage / 100 valuation_price_percentage,
             pocd.pay_in_price_unit_id,
             pofh.final_price final_price_in_pay_in_cur,
             pocd.pay_in_cur_id,
             cm.cur_code pay_in_cur_code,
             qum.qty_unit_id pay_in_price_unit_wt_unit_id,
             qum.qty_unit pay_in_price_unit_weight_unit,
             ppu.weight pay_in_price_unit_weight,
             pofh.avg_fx fx_price_to_pay_in
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             aml_attribute_master_list      aml,
             pdm_productmaster              pdm,
             cm_currency_master             cm,
             v_ppu_pum                      ppu,
             qum_quantity_unit_master       qum
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
         and aml.underlying_product_id = pdm.product_id
         and pocd.pay_in_cur_id = cm.cur_id
         and ppu.product_price_unit_id = pocd.pay_in_price_unit_id
         and ppu.weight_unit_id = qum.qty_unit_id
       order by nvl(pofh.final_price_in_pricing_cur, 0) desc;
    -- For combo Price if one part is not finalized, let it be at the end
    -- so we know that this GMR and element is not final priced
  
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    --vd_quotes_date               date;
    vn_total_contract_value      number;
    vc_price_cur_id              varchar2(15);
    vc_price_cur_code            varchar2(15);
    vn_price_weight_unit         number;
    vc_price_weight_unit_id      varchar2(15);
    vc_price_qty_unit            varchar2(15);
    vc_price_unit_id             varchar2(15);
    vn_qty_to_be_priced          number;
    vn_total_quantity            number;
    vn_average_price             number;
    vc_price_basis               varchar2(15);
    vn_fixed_value               number;
    vn_unfixed_value             number;
    vn_fixed_qty                 number;
    vn_unfixed_qty               number;
    vn_unfixed_val_price         number;
    vc_unfixed_val_price_unit_id varchar2(15);
    vc_fixed_price_unit_id       varchar2(15);
    vc_data_missing_for          varchar2(1000);
    vc_fixed_price_unit_id_pum   varchar2(50);
    vn_total_fixed_qty           number;
    vn_total_unfixed_qty         number;
    vc_pay_in_price_unit_id      varchar2(15);
    vc_pay_in_cur_id             varchar2(15);
    vc_pay_in_cur_code           varchar2(15);
    vc_is_final_priced           varchar2(1);
    vn_price_in_pay_in_cur       number;
    vc_pay_in_qty_unit_id        varchar2(15);
    vc_pay_in_qty_unit           varchar2(15);
    vn_pay_in_weight             number;
    vn_avg_fx_rate               number;
    vn_total_qty_for_avg_price   number;
    vn_total_qty_to_be_priced    number; -- For combo pricing if event based is partial and it has % of DI Price
    vc_di_final_priced           varchar2(1);
    vn_di_price                  number;
    vn_di_price_in_pay_in_cur    number;
    vn_di_avg_fx_rate            number;
    vn_total_final_priced        number;
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
      vc_pay_in_price_unit_id      := null;
      vc_pay_in_cur_id             := null;
      vc_pay_in_cur_code           := null;
      vn_price_in_pay_in_cur       := 0;
      vc_pay_in_qty_unit_id        := null;
      vc_pay_in_qty_unit           := null;
      vn_pay_in_weight             := null;
      vn_avg_fx_rate               := 0;
      vn_total_qty_for_avg_price   := 0;
      vn_total_qty_to_be_priced    := 0;
      vn_total_final_priced        := 0;
    
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no,
                                          cur_gmr_rows.element_id)
      loop
        vn_total_qty_to_be_priced := vn_total_qty_to_be_priced +
                                     cur_gmr_ele_rows.qty_to_be_priced;
        --  vc_is_final_priced        := 'N'; -- Reset Everytime, To handle combo case
        vc_pay_in_price_unit_id := cur_gmr_ele_rows.pay_in_price_unit_id;
        vc_pay_in_cur_id        := cur_gmr_ele_rows.pay_in_cur_id;
        vc_pay_in_cur_code      := cur_gmr_ele_rows.pay_in_cur_code;
        vc_pay_in_qty_unit_id   := cur_gmr_ele_rows.pay_in_price_unit_wt_unit_id;
        vc_pay_in_qty_unit      := cur_gmr_ele_rows.pay_in_price_unit_weight_unit;
        vn_pay_in_weight        := cur_gmr_ele_rows.pay_in_price_unit_weight;
        vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
        if cur_gmr_ele_rows.final_price <> 0 and
           cur_gmr_ele_rows.finalize_date <= pd_trade_date then
          vn_total_final_priced   := vn_total_final_priced +
                                     (vn_qty_to_be_priced / 100);
          vn_total_quantity       := cur_gmr_rows.payable_qty;
          vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_total_quantity *
                                     (vn_qty_to_be_priced / 100) *
                                     cur_gmr_ele_rows.final_price;
          vc_price_unit_id        := cur_gmr_ele_rows.final_price_unit_id;
          vn_total_fixed_qty      := vn_total_fixed_qty +
                                     (vn_total_quantity *
                                     (vn_qty_to_be_priced / 100));
        
          /* vc_is_final_priced         := 'Y';*/
          vn_price_in_pay_in_cur     := vn_price_in_pay_in_cur +
                                        (cur_gmr_ele_rows.final_price_in_pay_in_cur *
                                        (vn_qty_to_be_priced / 100));
          vn_avg_fx_rate             := vn_avg_fx_rate +
                                        (cur_gmr_ele_rows.fx_price_to_pay_in *
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
          if vc_fixed_price_unit_id is null then
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
        
          begin
            select tip.price * cur_gmr_ele_rows.valuation_price_percentage,
                   tip.price_unit_id,
                   tip.data_missing_for
              into vn_unfixed_val_price,
                   vc_unfixed_val_price_unit_id,
                   vc_data_missing_for
              from tip_temp_instrument_price tip
             where tip.corporate_id = pc_corporate_id
               and tip.instrument_id = cur_gmr_rows.instrument_id;
            if vc_data_missing_for is not null then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure pkg_phy_cog_price.sp_conc_gmr_cog_price',
                                                                   'PHY-002',
                                                                   vc_data_missing_for,
                                                                   cur_gmr_rows.gmr_ref_no,
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            end if;
          exception
            when others then
              null;
          end;
          --
          -- If Both Fixed and Unfixed Quantities are there then we have two prices
          -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
          --
          if vc_fixed_price_unit_id_pum <> vc_unfixed_val_price_unit_id then
            select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
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
      if vn_average_price is null then
        vn_average_price := 0;
      end if;
      ---   if combo price  and all the portions are final priced 
      if vn_total_final_priced = 1 * vn_total_qty_to_be_priced / 100 then
        vc_is_final_priced := 'Y';
      else
        vc_is_final_priced := 'N';
      end if;
    
      if vn_average_price <> 0 and vc_price_unit_id is not null then
        if vn_total_qty_to_be_priced = 100 then
          --Combo or Non Combo 100% is price from Event Based Pricing
          if vc_is_final_priced = 'N' then
            vn_price_in_pay_in_cur := null;
            vn_avg_fx_rate         := 1;
          else
            vn_price_in_pay_in_cur := round(vn_price_in_pay_in_cur, 4);
          end if;
        else
          --
          -- If combo price case and some portion is DI based
          -- Get the DI Price Details
          -- DI Price has to be in the same price unit as that of event based GMR
          --
          begin
            select cccp.is_final_priced,
                   cccp.contract_price,
                   cccp.contract_price_in_pay_in,
                   cccp.fx_price_to_pay
              into vc_di_final_priced,
                   vn_di_price,
                   vn_di_price_in_pay_in_cur,
                   vn_di_avg_fx_rate
              from cccp_conc_contract_cog_price cccp
             where cccp.pcdi_id = cur_gmr_rows.pcdi_id
               and cccp.element_id = cur_gmr_rows.element_id
               and cccp.process_id = pc_process_id;
          exception
            when others then
              vc_di_final_priced := 'N';
              vn_di_price        := 0;
          end;
          -- GMR is final prices only if DI and Event base portion are final priced
          if vc_is_final_priced = 'Y' and vc_di_final_priced = 'Y' then
            vc_is_final_priced := 'Y';
          else
            vc_is_final_priced := 'N';
          end if;
          --
          -- Modify the price in price currency based on Event Based + DI Combination
          --
          vn_average_price := ((vn_average_price *
                              vn_total_qty_to_be_priced) +
                              (vn_di_price *
                              (100 - vn_total_qty_to_be_priced))) / 100;
        
          if vc_is_final_priced = 'N' then
            vn_price_in_pay_in_cur := null;
            vn_avg_fx_rate         := 1;
          else
            -- Modify the price and FX Rate in pay in currency based on Event Based + DI Combination
            vn_price_in_pay_in_cur := round(vn_price_in_pay_in_cur, 4);
            vn_price_in_pay_in_cur := ((vn_price_in_pay_in_cur *
                                      vn_total_qty_to_be_priced) +
                                      (vn_di_price_in_pay_in_cur *
                                      (100 - vn_total_qty_to_be_priced))) / 100;
            vn_avg_fx_rate         := ((vn_avg_fx_rate *
                                      vn_total_qty_to_be_priced) +
                                      (vn_di_avg_fx_rate *
                                      (100 - vn_total_qty_to_be_priced))) / 100;
          end if;
        end if;
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
           is_final_priced,
           pay_in_price_unit_id,
           pay_in_cur_id,
           pay_in_cur_code,
           pay_in_price_unit_wt_unit_id,
           pay_in_price_unit_weight_unit,
           pay_in_price_unit_weight,
           contract_price_in_pay_in,
           fx_price_to_pay,
           pcdi_id,
           price_allocation_method)
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
           vn_total_fixed_qty,
           vn_total_unfixed_qty,
           vc_price_basis,
           vc_is_final_priced,
           vc_pay_in_price_unit_id,
           vc_pay_in_cur_id,
           vc_pay_in_cur_code,
           vc_pay_in_qty_unit_id,
           vc_pay_in_qty_unit,
           vn_pay_in_weight,
           vn_price_in_pay_in_cur,
           vn_avg_fx_rate,
           cur_gmr_rows.pcdi_id,
           'Event Based');
      end if;
    end loop;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_cog_price.sp_conc_gmr_cog_price',
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
             gmr.pcdi_id
        from gpq_gmr_payable_qty           gpq,
             gmr_goods_movement_record     gmr,
             page_price_alloc_gmr_exchange page
       where gmr.gmr_type = 'CONCENTRATES'
         and gpq.process_id = pc_process_id
         and page.element_id = gpq.element_id
         and page.internal_gmr_ref_no = gpq.internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and page.process_id = pc_process_id
         and gmr.internal_gmr_ref_no = page.internal_gmr_ref_no
         and gmr.is_deleted = 'N';
    cursor cur_gmr_ele(pc_internal_gmr_ref_no varchar2, pc_element_id varchar2) is
      select gad.internal_gmr_ref_no,
             gad.element_id,
             gad.pcbpd_id,
             gad.qty_to_be_priced,
             gad.price_basis,
             gad.gpah_id,
             gad.final_price,
             gad.finalize_date,
             gad.final_price_unit_id,
             gad.valuation_price_percentage,
             gad.pay_in_price_unit_id,
             gad.pay_in_cur_id,
             gad.pay_in_cur_code pay_in_cur_code,
             gad.final_price_in_pay_in_cur,
             gad.pay_in_price_unit_weight,
             gad.pay_in_price_unit_wt_unit_id,
             gad.pay_in_price_unit_weight_unit,
             gad.fx_price_to_pay_in
        from gad_gmr_aloc_data gad
       where gad.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and gad.element_id = pc_element_id
       order by nvl(gad.final_price, 0) desc;
  
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vn_total_contract_value      number;
    vc_price_cur_id              varchar2(15);
    vc_price_cur_code            varchar2(15);
    vn_price_weight_unit         number;
    vc_price_weight_unit_id      varchar2(15);
    vc_price_qty_unit            varchar2(15);
    vc_price_unit_id             varchar2(15);
    vn_qty_to_be_priced          number;
    vn_total_quantity            number;
    vn_average_price             number;
    vc_price_basis               varchar2(15);
    vn_fixed_value               number;
    vn_unfixed_value             number;
    vn_fixed_qty                 number;
    vn_unfixed_qty               number;
    vn_unfixed_val_price         number;
    vc_unfixed_val_price_unit_id varchar2(15);
    vc_fixed_price_unit_id       varchar2(15);
    vc_data_missing_for          varchar2(1000);
    vc_fixed_price_unit_id_pum   varchar2(50);
    vn_total_fixed_qty           number;
    vn_total_unfixed_qty         number;
    vc_pay_in_price_unit_id      varchar2(15);
    vc_pay_in_cur_id             varchar2(15);
    vc_pay_in_cur_code           varchar2(15);
    vc_is_final_priced           varchar2(1);
    vn_price_in_pay_in_cur       number;
    vn_cfx_price_to_pay          number;
    vc_pay_in_qty_unit_id        varchar2(15);
    vc_pay_in_qty_unit           varchar2(15);
    vn_pay_in_weight             number;
    vn_avg_fx_rate               number;
    vn_total_qty_for_avg_price   number;
    vn_total_qty_to_be_priced    number; -- For combo pricing if event based is partial and it has % of DI Price
    vc_di_final_priced           varchar2(1);
    vn_di_price                  number;
    vn_di_price_in_pay_in_cur    number;
    vn_di_avg_fx_rate            number;
    vn_total_final_priced        number;
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
       element_id,
       price_source_id,
       price_source_name,
       available_price_id,
       available_price_name,
       price_unit_name,
       ppu_price_unit_id,
       price_unit_id,
       delivery_calender_id,
       is_daily_cal_applicable,
       is_monthly_cal_applicable)
      select pcdi.process_id,
             gpah.internal_gmr_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             emt.exchange_id,
             emt.exchange_name,
             pcbpd.element_id,
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
             emt_exchangemaster             emt,
             div_der_instrument_valuation   div,
             ps_price_source                ps,
             apm_available_price_master     apm,
             pum_price_unit_master          pum,
             v_der_instrument_price_unit    vdip,
             pdc_prompt_delivery_calendar   pdc
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
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id
       group by pcdi.process_id,
                gpah.internal_gmr_ref_no,
                ppfd.instrument_id,
                dim.instrument_name,
                pdd.derivative_def_id,
                pdd.derivative_def_name,
                emt.exchange_id,
                emt.exchange_name,
                pcbpd.element_id,
                ps.price_source_id,
                ps.price_source_name,
                apm.available_price_id,
                apm.available_price_name,
                pum.price_unit_name,
                vdip.ppu_price_unit_id,
                div.price_unit_id,
                dim.delivery_calender_id,
                pdc.is_daily_cal_applicable,
                pdc.is_monthly_cal_applicable;
    commit;
  
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          221,
                          'PAGE Insert 1 Over');
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
       element_id,
       price_source_id,
       price_source_name,
       available_price_id,
       available_price_name,
       price_unit_name,
       ppu_price_unit_id,
       price_unit_id,
       delivery_calender_id,
       is_daily_cal_applicable,
       is_monthly_cal_applicable)
      select pcdi.process_id,
             grd.internal_gmr_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             emt.exchange_id,
             emt.exchange_name,
             pcbpd.element_id,
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
             grd_goods_record_detail        grd,
             div_der_instrument_valuation   div,
             ps_price_source                ps,
             apm_available_price_master     apm,
             pum_price_unit_master          pum,
             v_der_instrument_price_unit    vdip,
             pdc_prompt_delivery_calendar   pdc
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
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id
            -- Though DI is Price Allocation, there could be some elements with Event Based Pricing
            -- For Which Price is Already Calcualted  in sp_conc_gmr_cog_price       
         and pocd.qp_period_type <> 'Event'
         and not exists
       (select *
                from gpah_gmr_price_alloc_header gpah
               where gpah.is_active = 'Y'
                 and nvl(gpah.element_id, 'NA') = nvl(poch.element_id, 'NA') -- so that base metal also populates here
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
                ps.price_source_id,
                ps.price_source_name,
                apm.available_price_id,
                apm.available_price_name,
                pum.price_unit_name,
                vdip.ppu_price_unit_id,
                div.price_unit_id,
                dim.delivery_calender_id,
                pdc.is_daily_cal_applicable,
                pdc.is_monthly_cal_applicable;
    commit;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          222,
                          'PAGE Insert 2 Over');
    delete from gad_gmr_aloc_data where corporate_id = pc_corporate_id;
    commit;
  
    insert into gad_gmr_aloc_data
      (corporate_id,
       internal_gmr_ref_no,
       element_id,
       pcbpd_id,
       qty_to_be_priced,
       price_basis,
       gpah_id,
       final_price,
       finalize_date,
       final_price_unit_id,
       valuation_price_percentage,
       pay_in_price_unit_id,
       final_price_in_pay_in_cur,
       pay_in_cur_id,
       pay_in_cur_code,
       pay_in_price_unit_weight,
       pay_in_price_unit_wt_unit_id,
       pay_in_price_unit_weight_unit,
       fx_price_to_pay_in)
      select pc_corporate_id,
             gpah.internal_gmr_ref_no,
             pcbpd.element_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pcbpd.price_basis,
             gpah.gpah_id,
             nvl(gpah.final_price_in_pricing_cur, 0) final_price,
             gpah.finalize_date,
             pocd.final_price_unit_id,
             pcbpd.valuation_price_percentage / 100 valuation_price_percentage,
             pocd.pay_in_price_unit_id pay_in_price_unit_id,
             gpah.final_price,
             pocd.pay_in_cur_id,
             cm.cur_code,
             ppu.weight,
             qum.qty_unit_id,
             qum.qty_unit,
             gpah.avg_fx
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             gpah_gmr_price_alloc_header    gpah,
             gpad_gmr_price_alloc_dtls      gpad,
             pcdi_pc_delivery_item          pcdi,
             v_ppu_pum                      ppu,
             cm_currency_master             cm,
             qum_quantity_unit_master       qum
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
         and nvl(gpah.element_id, 'NA') = nvl(poch.element_id, 'NA')
         and gpad.gpah_id = gpah.gpah_id
         and pocd.pay_in_price_unit_id = ppu.product_price_unit_id
         and ppu.cur_id = cm.cur_id
         and ppu.weight_unit_id = qum.qty_unit_id
       group by gpah.internal_gmr_ref_no,
                pcbpd.element_id,
                pcbpd.pcbpd_id,
                pcbpd.qty_to_be_priced,
                pcbpd.price_basis,
                gpah.gpah_id,
                nvl(gpah.final_price_in_pricing_cur, 0),
                gpah.finalize_date,
                pocd.final_price_unit_id,
                pcbpd.valuation_price_percentage / 100,
                pocd.pay_in_price_unit_id,
                gpah.final_price,
                pocd.pay_in_cur_id,
                cm.cur_code,
                ppu.weight,
                qum.qty_unit_id,
                qum.qty_unit,
                gpah.avg_fx;
  
    commit;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          223,
                          'GAD Insert 1 Over');
    insert into gad_gmr_aloc_data
      (corporate_id,
       internal_gmr_ref_no,
       element_id,
       pcbpd_id,
       qty_to_be_priced,
       price_basis,
       gpah_id,
       final_price,
       finalize_date,
       final_price_unit_id,
       valuation_price_percentage,
       pay_in_price_unit_id,
       final_price_in_pay_in_cur,
       pay_in_cur_id,
       pay_in_cur_code,
       pay_in_price_unit_weight,
       pay_in_price_unit_wt_unit_id,
       pay_in_price_unit_weight_unit,
       fx_price_to_pay_in)
      select pc_corporate_id,
             grd.internal_gmr_ref_no,
             pcbpd.element_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pcbpd.price_basis,
             null gpah_id,
             0 final_price,
             null finalize_date,
             pocd.final_price_unit_id final_price_unit_id,
             pcbpd.valuation_price_percentage / 100 valuation_price_percentage,
             pocd.pay_in_price_unit_id pay_in_price_unit_id,
             0 final_price_in_pay_in_cur,
             pocd.pay_in_cur_id,
             cm.cur_code,
             ppu.weight,
             qum.qty_unit_id,
             qum.qty_unit,
             null
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             pcdi_pc_delivery_item          pcdi,
             grd_goods_record_detail        grd,
             v_ppu_pum                      ppu,
             cm_currency_master             cm,
             qum_quantity_unit_master       qum
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
         and grd.pcdi_id = pcdi.pcdi_id
         and grd.process_id = pc_process_id
         and pocd.pay_in_price_unit_id = ppu.product_price_unit_id
         and ppu.cur_id = cm.cur_id
         and ppu.weight_unit_id = qum.qty_unit_id
            -- Though DI is Price Allocation, there could be some elements with Event Based Pricing
            -- For Which Price is Already Calcualted  in sp_conc_gmr_cog_price       
         and pocd.qp_period_type <> 'Event'
         and not exists
       (select *
                from gpah_gmr_price_alloc_header gpah
               where gpah.is_active = 'Y'
                 and gpah.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and nvl(gpah.element_id, 'NA') =
                     nvl(pcbpd.element_id, 'NA')) -- so that base metal also comes here
       group by grd.internal_gmr_ref_no,
                pcbpd.element_id,
                pcbpd.pcbpd_id,
                pcbpd.qty_to_be_priced,
                pcbpd.price_basis,
                pocd.final_price_unit_id,
                pcbpd.valuation_price_percentage / 100,
                pocd.pay_in_price_unit_id,
                pocd.pay_in_cur_id,
                cm.cur_code,
                ppu.weight,
                qum.qty_unit_id,
                qum.qty_unit;
    commit;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          224,
                          'GAD Insert 2 Over');
    sp_gather_stats('page_price_alloc_gmr_exchange');
    sp_gather_stats('gad_gmr_aloc_data');
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          225,
                          'GMR Price Allocation Start');
  
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
      vc_pay_in_price_unit_id      := null;
      vc_pay_in_cur_id             := null;
      vc_pay_in_cur_code           := null;
      vn_price_in_pay_in_cur       := 0;
      vc_pay_in_qty_unit_id        := null;
      vc_pay_in_qty_unit           := null;
      vn_pay_in_weight             := null;
      vn_avg_fx_rate               := 0;
      vn_total_qty_for_avg_price   := 0;
      vn_total_qty_to_be_priced    := 0;
      vn_total_final_priced        := 0;
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no,
                                          cur_gmr_rows.element_id)
      loop
        vn_total_qty_to_be_priced := vn_total_qty_to_be_priced +
                                     cur_gmr_ele_rows.qty_to_be_priced;
        -- vc_is_final_priced        := 'N'; -- Reset Everytime, To handle combo case
        vc_pay_in_price_unit_id := cur_gmr_ele_rows.pay_in_price_unit_id;
        vc_pay_in_cur_id        := cur_gmr_ele_rows.pay_in_cur_id;
        vc_pay_in_cur_code      := cur_gmr_ele_rows.pay_in_cur_code;
        vc_price_basis          := cur_gmr_ele_rows.price_basis;
        vc_pay_in_qty_unit_id   := cur_gmr_ele_rows.pay_in_price_unit_wt_unit_id;
        vc_pay_in_qty_unit      := cur_gmr_ele_rows.pay_in_price_unit_weight_unit;
        vn_pay_in_weight        := cur_gmr_ele_rows.pay_in_price_unit_weight;
        vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
        if cur_gmr_ele_rows.final_price <> 0 and
           cur_gmr_ele_rows.finalize_date <= pd_trade_date then
          vn_total_final_priced   := vn_total_final_priced +
                                     (vn_qty_to_be_priced / 100);
          vn_total_quantity       := cur_gmr_rows.payable_qty;
          vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_total_quantity *
                                     (vn_qty_to_be_priced / 100) *
                                     cur_gmr_ele_rows.final_price;
          vc_price_unit_id        := cur_gmr_ele_rows.final_price_unit_id;
          vn_total_fixed_qty      := vn_total_fixed_qty +
                                     (vn_total_quantity *
                                     (vn_qty_to_be_priced / 100));
          -- vc_is_final_priced         := 'Y';
          vn_price_in_pay_in_cur     := vn_price_in_pay_in_cur +
                                        (cur_gmr_ele_rows.final_price_in_pay_in_cur *
                                        (vn_qty_to_be_priced / 100));
          vn_avg_fx_rate             := vn_avg_fx_rate +
                                        (cur_gmr_ele_rows.fx_price_to_pay_in *
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
          if vc_fixed_price_unit_id is null then
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
          begin
            select tip.price * cur_gmr_ele_rows.valuation_price_percentage,
                   tip.price_unit_id,
                   tip.data_missing_for
              into vn_unfixed_val_price,
                   vc_unfixed_val_price_unit_id,
                   vc_data_missing_for
              from tip_temp_instrument_price tip
             where tip.corporate_id = pc_corporate_id
               and tip.instrument_id = cur_gmr_rows.instrument_id;
            if vc_data_missing_for is not null then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure pkg_phy_cog_price.sp_conc_gmr_allocation_price',
                                                                   'PHY-002',
                                                                   vc_data_missing_for,
                                                                   cur_gmr_rows.gmr_ref_no,
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            end if;
          exception
            when others then
              null;
          end;
        
          --
          -- If Both Fixed and Unfixed Quantities are there then we have two prices
          -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
          --
          if vc_fixed_price_unit_id_pum <> vc_unfixed_val_price_unit_id then
            select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
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
      if vn_average_price is null then
        vn_average_price := 0;
      end if;
      ---   if combo price  and all the portions are final priced 
      -- Ratio may be less than 1 when DI portion is present
      if vn_total_final_priced = 1 * vn_total_qty_to_be_priced / 100 then
        vc_is_final_priced := 'Y';
      else
        vc_is_final_priced := 'N';
      end if;
    
      if vn_average_price <> 0 and vc_price_unit_id is not null then
        if vn_total_qty_to_be_priced = 100 then
          --Combo or Non Combo 100% is price from Price Allocation
          if vc_is_final_priced = 'N' then
            vn_price_in_pay_in_cur := null;
            vn_avg_fx_rate         := 1;
          else
            vn_price_in_pay_in_cur := round(vn_price_in_pay_in_cur, 4);
          end if;
        else
          --
          -- If combo price case and some portion is DI based
          -- Get the DI Price Details
          -- DI Price has to be in the same price unit as that of event based GMR
          --
          begin
            select cccp.is_final_priced,
                   cccp.contract_price,
                   cccp.contract_price_in_pay_in,
                   cccp.fx_price_to_pay
              into vc_di_final_priced,
                   vn_di_price,
                   vn_di_price_in_pay_in_cur,
                   vn_di_avg_fx_rate
              from cccp_conc_contract_cog_price cccp
             where cccp.pcdi_id = cur_gmr_rows.pcdi_id
               and cccp.element_id = cur_gmr_rows.element_id
               and cccp.process_id = pc_process_id;
          exception
            when others then
              vc_di_final_priced := 'N';
              vn_di_price        := 0;
          end;
          -- GMR is final prices only if DI and Event base portion are final priced
          if vc_is_final_priced = 'Y' and vc_di_final_priced = 'Y' then
            vc_is_final_priced := 'Y';
          else
            vc_is_final_priced := 'N';
          end if;
          --
          -- Modify the price in price currency based on Event Based + DI Combination
          --
          vn_average_price := ((vn_average_price *
                              vn_total_qty_to_be_priced) +
                              (vn_di_price *
                              (100 - vn_total_qty_to_be_priced))) / 100;
        
          if vc_is_final_priced = 'N' then
            vn_price_in_pay_in_cur := null;
            vn_avg_fx_rate         := 1;
          else
            -- Modify the price and FX Rate in pay in currency based on Event Based + DI Combination
            vn_price_in_pay_in_cur := round(vn_price_in_pay_in_cur, 4);
            vn_price_in_pay_in_cur := ((vn_price_in_pay_in_cur *
                                      vn_total_qty_to_be_priced) +
                                      (vn_di_price_in_pay_in_cur *
                                      (100 - vn_total_qty_to_be_priced))) / 100;
            vn_avg_fx_rate         := ((vn_avg_fx_rate *
                                      vn_total_qty_to_be_priced) +
                                      (vn_di_avg_fx_rate *
                                      (100 - vn_total_qty_to_be_priced))) / 100;
          end if;
        end if;
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
           is_final_priced,
           pay_in_price_unit_id,
           pay_in_cur_id,
           pay_in_cur_code,
           pay_in_price_unit_wt_unit_id,
           pay_in_price_unit_weight_unit,
           pay_in_price_unit_weight,
           contract_price_in_pay_in,
           fx_price_to_pay,
           pcdi_id,
           price_allocation_method)
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
           vn_total_fixed_qty,
           vn_total_unfixed_qty,
           vc_price_basis,
           vc_is_final_priced,
           vc_pay_in_price_unit_id,
           vc_pay_in_cur_id,
           vc_pay_in_cur_code,
           vc_pay_in_qty_unit_id,
           vc_pay_in_qty_unit,
           vn_pay_in_weight,
           vn_price_in_pay_in_cur,
           vn_avg_fx_rate,
           cur_gmr_rows.pcdi_id,
           'Price Allocation');
      end if;
    end loop;
    commit;
    --
    -- Where Price is Not Finalized Get the Corporate FX Rate from Price to Pay in and Update Exchange Rate 
    --
    for cur_corp_fx_rate in (select cgcp.price_unit_cur_id,
                                    cgcp.pay_in_cur_id
                               from cgcp_conc_gmr_cog_price cgcp
                              where cgcp.process_id = pc_process_id
                                and cgcp.is_final_priced = 'N'
                                and cgcp.price_unit_cur_id <>
                                    cgcp.pay_in_cur_id
                              group by cgcp.price_unit_cur_id,
                                       cgcp.pay_in_cur_id)
    loop
      begin
        select cet.exch_rate
          into vn_cfx_price_to_pay
          from cet_corporate_exch_rate cet
         where cet.from_cur_id = cur_corp_fx_rate.price_unit_cur_id
           and cet.to_cur_id = cur_corp_fx_rate.pay_in_cur_id
           and cet.corporate_id = pc_corporate_id;
      exception
        when others then
          vn_cfx_price_to_pay := -1;
      end;
    
      update cgcp_conc_gmr_cog_price cgcp
         set cgcp.fx_price_to_pay = vn_cfx_price_to_pay
       where cgcp.process_id = pc_process_id
         and cgcp.price_unit_cur_id = cur_corp_fx_rate.price_unit_cur_id
         and cgcp.pay_in_cur_id = cur_corp_fx_rate.pay_in_cur_id
         and cgcp.is_final_priced = 'N';
    end loop;
    commit;
  
    --
    -- Update Price in Pay In Currency as Price in Pricing Currency X Exchange Rate from Price to Pay
    --
  
    update cgcp_conc_gmr_cog_price cgcp
       set cgcp.contract_price_in_pay_in = cgcp.contract_price *
                                           cgcp.fx_price_to_pay
     where cgcp.process_id = pc_process_id
       and cgcp.is_final_priced = 'N';
    commit;
  
    sp_conc_gmr_di_price(pc_corporate_id,
                         pd_trade_date,
                         pc_process_id,
                         pc_user_id,
                         pc_process);
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

  procedure sp_base_gmr_allocation_price(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_process_id   varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2) is
    ------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_base_gmr_allocation_price
    --        Author                                    : Janna
    --        Created Date                              : 08th Apr 2013
    --        Purpose                                   : Calcualte COG Price for Base Metal Price Allocation GMRs
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
             gmr.qty gmr_qty,
             gmr.qty_unit_id gmr_qty_unit_id,
             gmr.pcdi_id
        from gmr_goods_movement_record     gmr,
             page_price_alloc_gmr_exchange page
       where gmr.gmr_type = 'BASEMETAL'
         and gmr.process_id = pc_process_id
         and page.process_id = pc_process_id
         and gmr.internal_gmr_ref_no = page.internal_gmr_ref_no
         and gmr.is_deleted = 'N';
    cursor cur_gmr_ele(pc_internal_gmr_ref_no varchar2) is
      select gad.internal_gmr_ref_no,
             gad.pcbpd_id,
             gad.qty_to_be_priced,
             gad.price_basis,
             gad.gpah_id,
             gad.final_price,
             gad.finalize_date,
             gad.final_price_unit_id,
             gad.valuation_price_percentage,
             gad.pay_in_price_unit_id,
             gad.pay_in_cur_id,
             gad.pay_in_cur_code pay_in_cur_code,
             gad.final_price_in_pay_in_cur,
             gad.pay_in_price_unit_weight,
             gad.pay_in_price_unit_wt_unit_id,
             gad.pay_in_price_unit_weight_unit,
             gad.fx_price_to_pay_in
        from gad_gmr_aloc_data gad
       where gad.internal_gmr_ref_no = pc_internal_gmr_ref_no
       order by nvl(gad.final_price, 0) desc;
  
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vn_total_contract_value      number;
    vc_price_cur_id              varchar2(15);
    vc_price_cur_code            varchar2(15);
    vn_price_weight_unit         number;
    vc_price_weight_unit_id      varchar2(15);
    vc_price_qty_unit            varchar2(15);
    vc_price_unit_id             varchar2(15);
    vn_qty_to_be_priced          number;
    vn_total_quantity            number;
    vn_average_price             number;
    vc_price_basis               varchar2(15);
    vn_fixed_value               number;
    vn_unfixed_value             number;
    vn_fixed_qty                 number;
    vn_unfixed_qty               number;
    vn_unfixed_val_price         number;
    vc_unfixed_val_price_unit_id varchar2(15);
    vc_fixed_price_unit_id       varchar2(15);
    vc_data_missing_for          varchar2(1000);
    vc_fixed_price_unit_id_pum   varchar2(50);
    vn_total_fixed_qty           number;
    vn_total_unfixed_qty         number;
    vc_pay_in_price_unit_id      varchar2(15);
    vc_pay_in_cur_id             varchar2(15);
    vc_pay_in_cur_code           varchar2(15);
    vc_is_final_priced           varchar2(1);
    vn_price_in_pay_in_cur       number;
    vn_cfx_price_to_pay          number;
    vc_pay_in_qty_unit_id        varchar2(15);
    vc_pay_in_qty_unit           varchar2(15);
    vn_pay_in_weight             number;
    vn_avg_fx_rate               number;
    vn_total_qty_for_avg_price   number;
    vn_total_qty_to_be_priced    number; -- For combo pricing if event based is partial and it has % of DI Price
    vc_di_final_priced           varchar2(1);
    vn_di_price                  number;
    vn_di_price_in_pay_in_cur    number;
    vn_di_avg_fx_rate            number;
    vn_total_final_priced        number;
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
      vc_pay_in_price_unit_id      := null;
      vc_pay_in_cur_id             := null;
      vc_pay_in_cur_code           := null;
      vn_price_in_pay_in_cur       := 0;
      vc_pay_in_qty_unit_id        := null;
      vc_pay_in_qty_unit           := null;
      vn_pay_in_weight             := null;
      vn_avg_fx_rate               := 0;
      vn_total_qty_for_avg_price   := 0;
      vn_total_qty_to_be_priced    := 0;
      vn_total_final_priced        := 0;
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no)
      loop
        vn_total_qty_to_be_priced := vn_total_qty_to_be_priced +
                                     cur_gmr_ele_rows.qty_to_be_priced;
        /*vc_is_final_priced        := 'N'; -- Reset Everytime, To handle combo case*/
        vc_pay_in_price_unit_id := cur_gmr_ele_rows.pay_in_price_unit_id;
        vc_pay_in_cur_id        := cur_gmr_ele_rows.pay_in_cur_id;
        vc_pay_in_cur_code      := cur_gmr_ele_rows.pay_in_cur_code;
        vc_price_basis          := cur_gmr_ele_rows.price_basis;
        vc_pay_in_qty_unit_id   := cur_gmr_ele_rows.pay_in_price_unit_wt_unit_id;
        vc_pay_in_qty_unit      := cur_gmr_ele_rows.pay_in_price_unit_weight_unit;
        vn_pay_in_weight        := cur_gmr_ele_rows.pay_in_price_unit_weight;
        if cur_gmr_ele_rows.final_price <> 0 and
           cur_gmr_ele_rows.finalize_date <= pd_trade_date then
          vn_total_final_priced   := vn_total_final_priced +
                                     (vn_qty_to_be_priced / 100);
          vn_total_quantity       := cur_gmr_rows.gmr_qty;
          vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_total_quantity *
                                     (vn_qty_to_be_priced / 100) *
                                     cur_gmr_ele_rows.final_price;
          vc_price_unit_id        := cur_gmr_ele_rows.final_price_unit_id;
          vn_total_fixed_qty      := vn_total_fixed_qty +
                                     (vn_total_quantity *
                                     (vn_qty_to_be_priced / 100));
          /* vc_is_final_priced         := 'Y';*/
          vn_price_in_pay_in_cur     := vn_price_in_pay_in_cur +
                                        (cur_gmr_ele_rows.final_price_in_pay_in_cur *
                                        (vn_qty_to_be_priced / 100));
          vn_avg_fx_rate             := vn_avg_fx_rate +
                                        (cur_gmr_ele_rows.fx_price_to_pay_in *
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
          if vc_fixed_price_unit_id is null then
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
          vn_qty_to_be_priced := cur_gmr_ele_rows.qty_to_be_priced;
          vn_unfixed_qty      := (cur_gmr_rows.gmr_qty *
                                 vn_qty_to_be_priced / 100) - vn_fixed_qty; --Unfixed Qty is based on Combo %ge
          begin
            select tip.price * cur_gmr_ele_rows.valuation_price_percentage,
                   tip.price_unit_id,
                   tip.data_missing_for
              into vn_unfixed_val_price,
                   vc_unfixed_val_price_unit_id,
                   vc_data_missing_for
              from tip_temp_instrument_price tip
             where tip.corporate_id = pc_corporate_id
               and tip.instrument_id = cur_gmr_rows.instrument_id;
            if vc_data_missing_for is not null then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure pkg_phy_cog_price.sp_base_gmr_allocation_price',
                                                                   'PHY-002',
                                                                   vc_data_missing_for,
                                                                   cur_gmr_rows.gmr_ref_no,
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            end if;
          exception
            when others then
              null;
          end;
          --
          -- If Both Fixed and Unfixed Quantities are there then we have two prices
          -- Fixed and Unfixed. Unfixed Convert into Fixed Price Using Corporate FX Rate
          --
          if vc_fixed_price_unit_id_pum <> vc_unfixed_val_price_unit_id then
            select pkg_phy_pre_check_process.f_get_converted_price_pum(pc_corporate_id,
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
      vn_total_unfixed_qty := cur_gmr_rows.gmr_qty - vn_total_fixed_qty;
      if vn_total_qty_for_avg_price <> 0 then
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_qty_for_avg_price,
                                  4);
      else
        vn_average_price := 0;
      end if;
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
      if vn_average_price is null then
        vn_average_price := 0;
      end if;
      ---   if combo price  and all the portions are final priced  
      if vn_total_final_priced = 1 * vn_total_qty_to_be_priced / 100 then
        vc_is_final_priced := 'Y';
      else
        vc_is_final_priced := 'N';
      end if;
    
      if vn_average_price <> 0 and vc_price_unit_id is not null then
        if vn_total_qty_to_be_priced = 100 then
          --Combo or Non Combo 100% is price from Event Based Pricing
          if vc_is_final_priced = 'N' then
            vn_price_in_pay_in_cur := null;
            vn_avg_fx_rate         := 1;
          else
            vn_price_in_pay_in_cur := round(vn_price_in_pay_in_cur, 4);
          end if;
        else
          --
          -- If combo price case and some portion is DI based
          -- Get the DI Price Details
          -- DI Price has to be in the same price unit as that of event based GMR
          --
          begin
            select bccp.is_final_priced,
                   bccp.contract_price,
                   bccp.contract_price_in_pay_in,
                   bccp.fx_price_to_pay
              into vc_di_final_priced,
                   vn_di_price,
                   vn_di_price_in_pay_in_cur,
                   vn_di_avg_fx_rate
              from bccp_base_contract_cog_price bccp
             where bccp.pcdi_id = cur_gmr_rows.pcdi_id
               and bccp.process_id = pc_process_id;
          exception
            when others then
              vc_di_final_priced := 'N';
              vn_di_price        := 0;
          end;
          -- GMR is final prices only if DI and Event base portion are final priced
          if vc_is_final_priced = 'Y' and vc_di_final_priced = 'Y' then
            vc_is_final_priced := 'Y';
          else
            vc_is_final_priced := 'N';
          end if;
          --
          -- Modify the price in price currency based on Event Based + DI Combination
          --
          vn_average_price := ((vn_average_price *
                              vn_total_qty_to_be_priced) +
                              (vn_di_price *
                              (100 - vn_total_qty_to_be_priced))) / 100;
        
          if vc_is_final_priced = 'N' then
            vn_price_in_pay_in_cur := null;
            vn_avg_fx_rate         := 1;
          else
            -- Modify the Price and Fx Rate in pay in currency based on Event Based + DI Combination
            vn_price_in_pay_in_cur := round(vn_price_in_pay_in_cur, 4);
            vn_price_in_pay_in_cur := ((vn_price_in_pay_in_cur *
                                      vn_total_qty_to_be_priced) +
                                      (vn_di_price_in_pay_in_cur *
                                      (100 - vn_total_qty_to_be_priced))) / 100;
            vn_avg_fx_rate         := ((vn_avg_fx_rate *
                                      vn_total_qty_to_be_priced) +
                                      (vn_di_avg_fx_rate *
                                      (100 - vn_total_qty_to_be_priced))) / 100;
          end if;
        end if;
      
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
           is_final_priced,
           pay_in_price_unit_id,
           pay_in_cur_id,
           pay_in_cur_code,
           pay_in_price_unit_wt_unit_id,
           pay_in_price_unit_weight_unit,
           pay_in_price_unit_weight,
           contract_price_in_pay_in,
           fx_price_to_pay,
           pcdi_id)
        values
          (pc_process_id,
           pc_corporate_id,
           cur_gmr_rows.internal_gmr_ref_no,
           cur_gmr_rows.gmr_ref_no,
           cur_gmr_rows.gmr_qty,
           cur_gmr_rows.gmr_qty_unit_id,
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
           vc_is_final_priced,
           vc_pay_in_price_unit_id,
           vc_pay_in_cur_id,
           vc_pay_in_cur_code,
           vc_pay_in_qty_unit_id,
           vc_pay_in_qty_unit,
           vn_pay_in_weight,
           vn_price_in_pay_in_cur,
           vn_avg_fx_rate,
           cur_gmr_rows.pcdi_id);
      
      end if;
    end loop;
    commit;
  
    --
    -- Where Price is Not Finalized Get the Corporate FX Rate from Price to Pay in and Update Exchange Rate 
    --
    for cur_corp_fx_rate in (select bgcp.price_unit_cur_id,
                                    bgcp.pay_in_cur_id
                               from bgcp_base_gmr_cog_price bgcp
                              where bgcp.process_id = pc_process_id
                                and bgcp.is_final_priced = 'N'
                                and bgcp.price_unit_cur_id <>
                                    bgcp.pay_in_cur_id
                              group by bgcp.price_unit_cur_id,
                                       bgcp.pay_in_cur_id)
    loop
      begin
        select cet.exch_rate
          into vn_cfx_price_to_pay
          from cet_corporate_exch_rate cet
         where cet.from_cur_id = cur_corp_fx_rate.price_unit_cur_id
           and cet.to_cur_id = cur_corp_fx_rate.pay_in_cur_id
           and cet.corporate_id = pc_corporate_id;
      exception
        when others then
          vn_cfx_price_to_pay := -1;
      end;
    
      update bgcp_base_gmr_cog_price bgcp
         set bgcp.fx_price_to_pay = vn_cfx_price_to_pay
       where bgcp.process_id = pc_process_id
         and bgcp.price_unit_cur_id = cur_corp_fx_rate.price_unit_cur_id
         and bgcp.pay_in_cur_id = cur_corp_fx_rate.pay_in_cur_id
         and bgcp.is_final_priced = 'N';
    end loop;
    commit;
  
    --
    -- Update Price in Pay In Currency as Price in Pricing Currency X Exchange Rate from Price to Pay
    --
  
    update bgcp_base_gmr_cog_price bgcp
       set bgcp.contract_price_in_pay_in = bgcp.contract_price *
                                           bgcp.fx_price_to_pay
     where bgcp.process_id = pc_process_id
       and bgcp.is_final_priced = 'N';
    commit;
  
    sp_gather_stats('bgcp_base_gmr_cog_price');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_cog_price.sp_base_gmr_allocation_price',
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
  procedure sp_conc_gmr_di_price(pc_corporate_id varchar2,
                                 pd_trade_date   date,
                                 pc_process_id   varchar2,
                                 pc_user_id      varchar2,
                                 pc_process      varchar2) is
    vn_log_counter number := 501;
  begin
    --
    -- First populate the GMRs with only DI Level change
    --
    delete from tdige_temp_di_gmr_element t
     where t.corporate_id = pc_corporate_id;
    commit;
    vn_log_counter := vn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'Delete TDIGE_TEMP_DI_GMR_ELEMENT Over');
    insert into tdige_temp_di_gmr_element
      (corporate_id, internal_gmr_ref_no, element_id)
      select spq.corporate_id,
             spq.internal_gmr_ref_no,
             spq.element_id
        from spq_stock_payable_qty spq
       where spq.is_active = 'Y'
         and spq.is_stock_split = 'N'
         and spq.process_id = pc_process_id
         and not exists
       (select *
                from cgcp_conc_gmr_cog_price cgcp
               where cgcp.internal_gmr_ref_no = spq.internal_gmr_ref_no
                 and cgcp.element_id = spq.element_id
                 and cgcp.process_id = pc_process_id)
       group by spq.corporate_id,
                spq.internal_gmr_ref_no,
                spq.element_id;
    commit;
    vn_log_counter := vn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'Insert TDIGE_TEMP_DI_GMR_ELEMENT Over');
  
    --
    -- Update PCDI_ID from GRD table
    --      
    for cur_pcdi_id in (select grd.internal_gmr_ref_no,
                               max(grd.pcdi_id) pcdi_id
                          from grd_goods_record_detail grd
                         where grd.process_id = pc_process_id
                           and grd.is_deleted = 'N'
                           and grd.status = 'Active'
                           and grd.tolling_stock_type in ('None Tolling')
                         group by grd.internal_gmr_ref_no)
    loop
    
      update tdige_temp_di_gmr_element t
         set t.pcdi_id = cur_pcdi_id.pcdi_id
       where t.internal_gmr_ref_no = cur_pcdi_id.internal_gmr_ref_no
         and t.corporate_id = pc_corporate_id;
    
    end loop;
    commit;
    vn_log_counter := vn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'Update PCDI_ID in TDIGE Over');
  
    --
    -- Populate CGCP table for DI based GMR and Element Combination
    --
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
       is_final_priced,
       pay_in_price_unit_id,
       pay_in_cur_id,
       pay_in_cur_code,
       pay_in_price_unit_weight,
       pay_in_price_unit_wt_unit_id,
       pay_in_price_unit_weight_unit,
       contract_price_in_pay_in,
       pcdi_id,
       fx_price_to_pay,
       price_allocation_method)
      select cccp.process_id,
             cccp.corporate_id,
             t.internal_gmr_ref_no,
             gmr.gmr_ref_no gmr_ref_no,
             cccp.element_id,
             cccp.payable_qty,
             cccp.payable_qty_unit_id,
             cccp.contract_price,
             cccp.price_unit_id,
             cccp.price_unit_cur_id,
             cccp.price_unit_cur_code,
             cccp.price_unit_weight,
             cccp.price_unit_weight_unit_id,
             cccp.price_unit_weight_unit,
             cccp.fixed_qty,
             cccp.unfixed_qty,
             cccp.price_basis,
             cccp.is_final_priced,
             cccp.pay_in_price_unit_id,
             cccp.pay_in_cur_id,
             cccp.pay_in_cur_code,
             cccp.pay_in_price_unit_weight,
             cccp.pay_in_price_unit_wt_unit_id,
             cccp.pay_in_price_unit_weight_unit,
             cccp.contract_price_in_pay_in,
             cccp.pcdi_id,
             cccp.fx_price_to_pay,
             'DI Based'
        from cccp_conc_contract_cog_price cccp,
             tdige_temp_di_gmr_element    t,
             process_gmr                  gmr
       where cccp.process_id = pc_process_id
         and cccp.pcdi_id = t.pcdi_id
         and cccp.element_id = t.element_id
         and t.corporate_id = pc_corporate_id
         and t.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr.process_id = pc_process_id;
  
    commit;
    commit;
    vn_log_counter := vn_log_counter + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_log_counter,
                          'Insert DI Based GMR to CGCP Over');
  
  end;
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
             pdc_prompt_delivery_calendar pdc,
             irm_instrument_type_master   irm
       where dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id
         and irm.instrument_type_id = dim.instrument_type_id
         and irm.is_active = 'Y'
         and irm.instrument_type = 'Future';
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
      vc_data_missing_for          := null;
      vn_unfixed_val_price         := null;
      vc_unfixed_val_price_unit_id := null;
      vd_prompt_date               := null;
      vc_instrument_id             := cur_price_rows.instrument_id;
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
        -- Added Sures for NPD
         if pkg_cdc_pre_check_process.fn_is_npd(pc_corporate_id,
                                                 cur_price_rows.delivery_calender_id,
                                                 vd_quotes_date)=true then
         
         vd_quotes_date:= pkg_cdc_pre_check_process.fn_get_npd_substitute_day(pc_corporate_id,
                                                    cur_price_rows.delivery_calender_id,
                                                    vd_quotes_date);
          end if;
          --end
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
                                     ', Price Source: ' ||
                                     cur_price_rows.price_source_name ||
                                     ', Price Unit: ' ||
                                     cur_price_rows.price_unit_name || ', ' ||
                                     cur_price_rows.available_price_name ||
                                     ' Price, Prompt Date:' ||
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
                                     ', Price Source: ' ||
                                     cur_price_rows.price_source_name ||
                                     ', Price Unit: ' ||
                                     cur_price_rows.price_unit_name || ', ' ||
                                     cur_price_rows.available_price_name ||
                                     ' Price, Prompt Date:' ||
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
           and cdim.instrument_id = dq.instrument_id
           and nvl(dqd.price, 0) <> 0;
      exception
        when no_data_found then
          select cdim.valid_quote_date
            into vd_valid_quote_date
            from cdim_corporate_dim cdim
           where cdim.corporate_id = pc_corporate_id
             and cdim.instrument_id = cur_price_rows.instrument_id;
          if cur_price_rows.is_daily_cal_applicable = 'N' and
             cur_price_rows.is_monthly_cal_applicable = 'Y' then
            vc_prompt_date_text := to_char(vd_prompt_date, 'Mon-RRRR');
          else
            vc_prompt_date_text := to_char(vd_quotes_date, 'dd-Mon-RRRR');
          end if;
          if vc_data_missing_for is null then
            vc_data_missing_for := 'Price missing for ' ||
                                   cur_price_rows.instrument_name ||
                                   ', Price Source: ' ||
                                   cur_price_rows.price_source_name ||
                                   ', Price Unit: ' ||
                                   cur_price_rows.price_unit_name || ', ' ||
                                   cur_price_rows.available_price_name ||
                                   ' Price,Prompt Date: ' ||
                                   vc_prompt_date_text || ', Trade Date(' ||
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
                                                           'procedure pkg_phy_cog_price.sp_calc_instrument_price',
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
end; 
/
