create or replace package pkg_phy_eod_price is
  procedure sp_calc_contract_price(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_user_id      varchar2,
                                   pc_dbd_id       varchar2,
                                   pc_process      varchar2);

  procedure sp_calc_gmr_price(pc_corporate_id varchar2,
                              pd_trade_date   date,
                              pc_process_id   varchar2,
                              pc_user_id      varchar2,
                              pc_dbd_id       varchar2,
                              pc_process      varchar2);
  procedure sp_calc_stock_price(pc_process_id varchar2);
  procedure sp_calc_conc_gmr_price(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_user_id      varchar2,
                                   pc_dbd_id       varchar2,
                                   pc_process      varchar2);

  procedure sp_calc_contract_conc_price(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_dbd_id       varchar2,
                                        pc_process      varchar2);

end;
/
create or replace package body "PKG_PHY_EOD_PRICE" is

  procedure sp_calc_contract_price(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_user_id      varchar2,
                                   pc_dbd_id       varchar2,
                                   pc_process      varchar2) is
  
    vobj_error_log      tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count  number := 1;
    vd_valid_quote_date date;
  
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
             nvl(pcdi.transit_days, 0) transit_days,
             pcdi.qp_declaration_date,
             pcdi.is_price_optionality_present,
             pcdi.is_phy_optionality_present,
             pcdi.price_option_call_off_status,
             pci.internal_contract_item_ref_no,
             pcm.contract_ref_no,
             (case
               when nvl(pcdi.payment_due_date, pd_trade_date) <
                    pd_trade_date then
                pd_trade_date
               else
                nvl(pcdi.payment_due_date, pd_trade_date)
             end) payment_due_date,
             pci.item_qty,
             pci.item_qty_unit_id,
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
             pci_physical_contract_item pci,
             pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcpd_pc_product_definition pcpd,
             pcpq_pc_product_quality pcpq,
             (select *
                from ced_contract_exchange_detail ced
               where ced.corporate_id = pc_corporate_id) qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip,
             pdc_prompt_delivery_calendar pdc
       where pcdi.pcdi_id = pci.pcdi_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpq.pcpd_id = pcpd.pcpd_id
         and pci.pcpq_id = pcpq.pcpq_id
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'BASEMETAL'
         and pcpd.input_output = 'Input'
         and pci.internal_contract_item_ref_no =
             qat.internal_contract_item_ref_no(+)
         and qat.instrument_id = dim.instrument_id(+)
         and dim.instrument_id = div.instrument_id(+)
         and div.is_deleted(+) = 'N'
         and div.price_source_id = ps.price_source_id(+)
         and div.available_price_id = apm.available_price_id(+)
         and div.price_unit_id = pum.price_unit_id(+)
         and dim.instrument_id = vdip.instrument_id(+)
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id(+)
         and pci.item_qty > 0
         and pcdi.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y';
  
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
             pcbph.price_description price_description
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
  
    cursor cur_not_called_off(pc_pcdi_id varchar2, pc_int_cont_item_ref_no varchar2) is
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
         and pci.internal_contract_item_ref_no = pc_int_cont_item_ref_no
         and pci.process_id = pc_process_id
         and pcipf.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pcbpd.process_id = pc_process_id
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
  
    vn_contract_price              number;
    vc_price_unit_id               varchar2(15);
    vc_price_basis                 varchar2(15);
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vc_price_weight_unit           number;
    vc_price_weight_unit_id        varchar2(15);
    vc_price_qty_unit              varchar2(15);
    vn_contract_equity_premium     varchar2(15);
    vn_market_equity_premium       varchar2(15);
    vc_mar_equ_prem_price_unit_id  varchar2(15);
    vc_con_equ_prem_price_unit_id  varchar2(15);
    vc_price_fixation_status       varchar2(50);
    vn_price_fixed_qty             number;
    vn_total_qty                   number;
    vn_total_quantity              number;
    vn_qty_to_be_priced            number;
    vn_total_contract_value        number;
    vn_average_price               number;
    vc_contract_base_price_unit_id varchar2(15);
    vc_contract_main_cur_id        varchar2(15);
    vc_contract_main_cur_code      varchar2(15);
    vc_base_main_cur_id            varchar2(15);
    vc_base_main_cur_code          varchar2(15);
    vn_forward_points              number;
    vn_fw_exch_rate_price_to_base  number;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(15);
    vd_shipment_date               date;
    vd_arrival_date                date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vd_3rd_wed_of_qp               date;
    vc_holiday                     char(1);
    vd_payment_due_date            date;
    vc_price_description           varchar2(500);
    vn_contract_main_cur_factor    number;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_set_price      number;
    vn_during_total_val_price      number;
    vn_count_set_qp                number;
    vn_count_val_qp                number;
    workings_days                  number;
    vd_quotes_date                 date;
    vn_during_qp_price             number;
    vc_during_price_dr_id          varchar2(15);
    vc_during_qp_price_unit_id     varchar2(15);
    vn_error_no                    number := 0;
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_amt   number;
    vn_any_day_price_unfix_qty_amt number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vc_exch_rate_string            varchar2(300);
    vn_price_in_base_price_unit_id number;
    vc_fixed_price_unit_id         varchar2(15); -- During QP , Fixed Price Unit
  begin
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          2001,
                          'Start of base contract price');
    delete from ced_contract_exchange_detail ced
     where ced.corporate_id = pc_corporate_id;
    commit;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          2001,
                          'End delete CED');
  
    insert into ced_contract_exchange_detail
      (corporate_id,
       internal_contract_item_ref_no,
       pcdi_id,
       element_id,
       instrument_id,
       instrument_name,
       derivative_def_id,
       derivative_def_name,
       exchange_id,
       exchange_name)
      select pc_corporate_id,
             tt.internal_contract_item_ref_no,
             tt.pcdi_id,
             tt.element_id,
             tt.instrument_id,
             dim.instrument_name,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             emt.exchange_id,
             emt.exchange_name
        from (select pci.internal_contract_item_ref_no,
                     poch.element_id,
                     ppfd.instrument_id,
                     pci.pcdi_id
                from pci_physical_contract_item     pci,
                     pcdi_pc_delivery_item          pcdi,
                     poch_price_opt_call_off_header poch,
                     pocd_price_option_calloff_dtls pocd,
                     pcbpd_pc_base_price_detail     pcbpd,
                     ppfh_phy_price_formula_header  ppfh,
                     ppfd_phy_price_formula_details ppfd,
                     pcm_physical_contract_main     pcm
               where pci.pcdi_id = pcdi.pcdi_id
                 and pcdi.pcdi_id = poch.pcdi_id
                 and poch.poch_id = pocd.poch_id
                 and pocd.pcbpd_id = pcbpd.pcbpd_id
                 and pcbpd.pcbpd_id = ppfh.pcbpd_id
                 and ppfh.ppfh_id = ppfd.ppfh_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pci.process_id = pcdi.process_id
                 and pcdi.process_id = pcbpd.process_id
                 and pcbpd.process_id = ppfh.process_id
                 and ppfh.process_id = ppfd.process_id
                 and ppfd.process_id = pcm.process_id
                 and pcm.process_id = pc_process_id
                 and pcm.is_active = 'Y'
                 and pci.is_active = 'Y'
                 and pcdi.is_active = 'Y'
                 and poch.is_active = 'Y'
                 and pocd.is_active = 'Y'
                 and pcbpd.is_active = 'Y'
                 and ppfh.is_active = 'Y'
                 and ppfd.is_active = 'Y'
                 and pcm.product_group_type = 'BASEMETAL'
                 and pcdi.price_option_call_off_status in
                     ('Called Off', 'Not Applicable')
               group by pci.internal_contract_item_ref_no,
                        ppfd.instrument_id,
                        poch.element_id,
                        pci.pcdi_id
              union all
              select pci.internal_contract_item_ref_no,
                     pcbpd.element_id,
                     ppfd.instrument_id,
                     pci.pcdi_id
                from pci_physical_contract_item     pci,
                     pcdi_pc_delivery_item          pcdi,
                     pcipf_pci_pricing_formula      pcipf,
                     pcbph_pc_base_price_header     pcbph,
                     pcbpd_pc_base_price_detail     pcbpd,
                     ppfh_phy_price_formula_header  ppfh,
                     ppfd_phy_price_formula_details ppfd,
                     pcm_physical_contract_main     pcm
               where pci.internal_contract_item_ref_no =
                     pcipf.internal_contract_item_ref_no
                 and pcipf.pcbph_id = pcbph.pcbph_id
                 and pcbph.pcbph_id = pcbpd.pcbph_id
                 and pcbpd.pcbpd_id = ppfh.pcbpd_id
                 and ppfh.ppfh_id = ppfd.ppfh_id
                 and pci.pcdi_id = pcdi.pcdi_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pci.process_id = pcdi.process_id
                 and pcdi.process_id = pcipf.process_id
                 and pcipf.process_id = pcbph.process_id
                 and pcbph.process_id = ppfh.process_id
                 and ppfh.process_id = ppfd.process_id
                 and ppfd.process_id = pcm.process_id
                 and pcbpd.process_id = pcm.process_id
                 and pcm.process_id = pc_process_id
                 and pcdi.is_active = 'Y'
                 and pcm.product_group_type = 'BASEMETAL'
                 and pcdi.price_option_call_off_status = 'Not Called Off'
                 and pci.is_active = 'Y'
                 and pcipf.is_active = 'Y'
                 and pcbph.is_active = 'Y'
                 and pcbpd.is_active = 'Y'
                 and ppfh.is_active = 'Y'
                 and ppfd.is_active = 'Y'
               group by pci.internal_contract_item_ref_no,
                        ppfd.instrument_id,
                        pcbpd.element_id,
                        pci.pcdi_id
              union all
              select pci.internal_contract_item_ref_no,
                     pcbpd.element_id,
                     ppfd.instrument_id,
                     pci.pcdi_id
                from pci_physical_contract_item     pci,
                     pcdi_pc_delivery_item          pcdi,
                     poch_price_opt_call_off_header poch,
                     pocd_price_option_calloff_dtls pocd,
                     pcbpd_pc_base_price_detail     pcbpd,
                     ppfh_phy_price_formula_header  ppfh,
                     ppfd_phy_price_formula_details ppfd,
                     dipq_delivery_item_payable_qty dipq,
                     pcm_physical_contract_main     pcm
               where pci.pcdi_id = pcdi.pcdi_id
                 and pcdi.pcdi_id = poch.pcdi_id
                 and poch.poch_id = pocd.poch_id
                 and pocd.pcbpd_id = pcbpd.pcbpd_id
                 and pcbpd.pcbpd_id = ppfh.pcbpd_id
                 and ppfh.ppfh_id = ppfd.ppfh_id
                 and pcdi.pcdi_id = dipq.pcdi_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pci.process_id = pc_process_id
                 and pcdi.process_id = pc_process_id
                 and pcbpd.process_id = pc_process_id
                 and ppfh.process_id = pc_process_id
                 and ppfd.process_id = pc_process_id
                 and dipq.process_id = pc_process_id
                 and pcbpd.process_id = pc_process_id
                 and pcm.process_id = pc_process_id
                 and dipq.element_id = pcbpd.element_id
                 and pcdi.is_active = 'Y'
                 and dipq.price_option_call_off_status in
                     ('Called Off', 'Not Applicable')
                 and pcm.product_group_type = 'CONCENTRATES'
                 and pcm.is_active = 'Y'
                 and dipq.is_active = 'Y'
                 and pci.is_active = 'Y'
                 and pcbpd.is_active = 'Y'
                 and poch.is_active = 'Y'
                 and pocd.is_active = 'Y'
                 and ppfh.is_active = 'Y'
                 and ppfd.is_active = 'Y'
               group by pci.internal_contract_item_ref_no,
                        ppfd.instrument_id,
                        pcbpd.element_id,
                        pci.pcdi_id
              union all
              select pci.internal_contract_item_ref_no,
                     pcbpd.element_id,
                     ppfd.instrument_id,
                     pci.pcdi_id
                from pci_physical_contract_item     pci,
                     pcdi_pc_delivery_item          pcdi,
                     pcipf_pci_pricing_formula      pcipf,
                     pcbph_pc_base_price_header     pcbph,
                     pcbpd_pc_base_price_detail     pcbpd,
                     ppfh_phy_price_formula_header  ppfh,
                     ppfd_phy_price_formula_details ppfd,
                     dipq_delivery_item_payable_qty dipq,
                     pcm_physical_contract_main     pcm
               where pci.internal_contract_item_ref_no =
                     pcipf.internal_contract_item_ref_no
                 and pcipf.pcbph_id = pcbph.pcbph_id
                 and pcbph.pcbph_id = pcbpd.pcbph_id
                 and pcbpd.pcbpd_id = ppfh.pcbpd_id
                 and ppfh.ppfh_id = ppfd.ppfh_id
                 and pci.pcdi_id = pcdi.pcdi_id
                 and pcdi.pcdi_id = dipq.pcdi_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pci.process_id = pc_process_id
                 and pcdi.process_id = pc_process_id
                 and pcipf.process_id = pc_process_id
                 and pcbph.process_id = pc_process_id
                 and ppfh.process_id = pc_process_id
                 and ppfd.process_id = pc_process_id
                 and dipq.process_id = pc_process_id
                 and pcm.process_id = pc_process_id
                 and dipq.element_id = pcbpd.element_id
                 and pcdi.is_active = 'Y'
                 and dipq.price_option_call_off_status = 'Not Called Off'
                 and pcm.product_group_type = 'CONCENTRATES'
                 and pcm.is_active = 'Y'
                 and dipq.is_active = 'Y'
                 and pci.is_active = 'Y'
                 and pcipf.is_active = 'Y'
                 and pcbph.is_active = 'Y'
                 and pcbpd.is_active = 'Y'
                 and ppfh.is_active = 'Y'
                 and ppfd.is_active = 'Y'
               group by pci.internal_contract_item_ref_no,
                        ppfd.instrument_id,
                        pcbpd.element_id,
                        pci.pcdi_id) tt,
             dim_der_instrument_master dim,
             pdd_product_derivative_def pdd,
             emt_exchangemaster emt
       where tt.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.exchange_id = emt.exchange_id(+)
       group by tt.internal_contract_item_ref_no,
                tt.element_id,
                tt.instrument_id,
                dim.instrument_name,
                pdd.derivative_def_id,
                pdd.derivative_def_name,
                emt.exchange_id,
                emt.exchange_name,
                tt.pcdi_id;
    commit;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          2001,
                          'Start of Loop after Insert CED');
    for cur_pcdi_rows in cur_pcdi
    loop
      if cur_pcdi_rows.payment_due_date is null then
        vd_payment_due_date := pd_trade_date;
      else
        vd_payment_due_date := cur_pcdi_rows.payment_due_date;
      end if;
      -- Get the base main cur id
      vc_base_main_cur_id      := cur_pcdi_rows.base_cur_id;
      vc_base_main_cur_code    := cur_pcdi_rows.base_currency_name;
      vc_price_fixation_status := null;
      vn_total_contract_value  := 0;
      vc_exch_rate_string      := null;
    
      if cur_pcdi_rows.price_option_call_off_status in
         ('Called Off', 'Not Applicable') then
        vc_price_fixation_status := null;
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id)
        loop
          vc_price_basis       := cur_called_off_rows.price_basis;
          vc_price_description := cur_called_off_rows.price_description;
        
          if cur_called_off_rows.price_basis = 'Fixed' then
          
            vn_contract_price        := cur_called_off_rows.price_value;
            vn_total_quantity        := cur_pcdi_rows.item_qty;
            vn_qty_to_be_priced      := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value  := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        vn_contract_price;
            vc_price_unit_id         := cur_called_off_rows.price_unit_id;
            vc_price_fixation_status := 'Fixed';
          
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
          
            for cc1 in (select ppfh.ppfh_id,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id,
                               ppu.price_unit_name,
                               pocd.qp_period_type,
                               pofh.qp_start_date,
                               pofh.qp_end_date,
                               pfqpp.event_name,
                               pfqpp.no_of_event_months,
                               pfqpp.is_qp_any_day_basis,
                               (case
                                 when pocd.qp_period_type = 'Event' then
                                  cur_pcdi_rows.item_qty
                                 else
                                  pofh.qty_to_be_fixed
                               end) qty_to_be_fixed,
                               pofh.priced_qty,
                               pofh.pofh_id
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail pcbpd,
                               ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing pfqpp,
                               (select *
                                  from pofh_price_opt_fixation_header pfh
                                 where pfh.internal_gmr_ref_no is null
                                   and pfh.is_active = 'Y'
                                   and pfh.qty_to_be_fixed <> 0) pofh,
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
                              -- and pofh.is_active(+) = 'Y'
                           and pcbpd.process_id = pc_process_id
                           and pfqpp.process_id = pc_process_id
                           and ppfh.process_id = pc_process_id)
            
            loop
            
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
            
              if cc1.qp_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Month' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                  when others then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                end;
              else
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              -- 7th June 2012 By Janna
              -- If Event Based then the price is always 3rd Wednesday of QP 
              -- If QP is passed then Spot Price as on EOD Date
              --  
              if cc1.qp_period_type = 'Event' then
                vc_price_fixation_status := 'Un-priced';
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                        'Wed',
                                                                        3);
                
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'After QP' then
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       pd_trade_date);
                  else
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       vd_qp_end_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
                --get the price              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              
              elsif vc_period = 'Before QP' then
                vc_price_fixation_status := 'Un-priced';
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                        'Wed',
                                                                        3);
                
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                
                  vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                      vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
                --get the price              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif (vc_period = 'During QP' or vc_period = 'After QP') then
                vd_dur_qp_start_date         := vd_qp_start_date;
                vd_dur_qp_end_date           := vd_qp_end_date;
                vn_during_total_set_price    := 0;
                vn_count_set_qp              := 0;
                vn_any_day_price_fix_qty_amt := 0;
                vn_any_day_fixed_qty         := 0;
                for cc in (select pfd.user_price,
                                  pfd.as_of_date,
                                  pfd.qty_fixed,
                                  pofh.final_price,
                                  pfd.price_unit_id,
                                  vppu.price_unit_id pum_fixed_price_unit_id
                             from poch_price_opt_call_off_header poch,
                                  pocd_price_option_calloff_dtls pocd,
                                  pofh_price_opt_fixation_header pofh,
                                  pfd_price_fixation_details     pfd,
                                  v_ppu_pum                      vppu
                            where poch.poch_id = pocd.poch_id
                              and pocd.pocd_id = pofh.pocd_id
                              and pofh.pofh_id = cc1.pofh_id
                              and pofh.pofh_id = pfd.pofh_id
                              and pfd.as_of_date >= vd_dur_qp_start_date
                              and pfd.as_of_date <= pd_trade_date
                              and pfd.price_unit_id =
                                  vppu.product_price_unit_id
                              and poch.is_active = 'Y'
                              and pocd.is_active = 'Y'
                              and pofh.is_active = 'Y'
                              and pfd.is_active = 'Y')
                loop
                  vn_during_total_set_price    := vn_during_total_set_price +
                                                  cc.user_price;
                  vn_any_day_price_fix_qty_amt := vn_any_day_price_fix_qty_amt +
                                                  (cc.user_price *
                                                  cc.qty_fixed);
                  vn_any_day_fixed_qty         := vn_any_day_fixed_qty +
                                                  cc.qty_fixed;
                  vn_count_set_qp              := vn_count_set_qp + 1;
                  vc_fixed_price_unit_id       := cc.price_unit_id;
                  if cc.final_price is not null then
                    vc_price_fixation_status := 'Finalized';
                  end if;
                end loop;
              
                if vn_count_set_qp <> 0 then
                  if vc_price_fixation_status <> 'Finalized' then
                    vc_price_fixation_status := 'Partially Priced';
                  end if;
                else
                  vc_price_fixation_status := 'Un-priced';
                
                end if;
              
                if cc1.is_qp_any_day_basis = 'Y' then
                  vn_market_flag := 'N';
                else
                  vn_market_flag := 'Y';
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  -- get the third wednesday
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_dur_qp_end_date,
                                                                        'Wed',
                                                                        3);
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if (vd_3rd_wed_of_qp <= pd_trade_date and
                     vc_period = 'During QP') or vc_period = 'After QP' then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  --Get the DR-id
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cc1.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       vd_qp_end_date);
                  else
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       pd_trade_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
                --Get the price for the dr-id
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_val_price,
                         vc_during_val_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.dbd_id = dqd.dbd_id
                     and dq.dbd_id = pc_dbd_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
              
                vn_during_total_val_price := 0;
                vn_count_val_qp           := 0;
                vd_dur_qp_start_date      := pd_trade_date + 1;
              
                if vn_market_flag = 'N' then
                  vn_during_total_val_price := vn_during_total_val_price +
                                               vn_during_val_price;
                
                  vn_any_day_unfixed_qty         := cc1.qty_to_be_fixed -
                                                    vn_any_day_fixed_qty;
                  vn_count_val_qp                := vn_count_val_qp + 1;
                  vn_any_day_price_unfix_qty_amt := (vn_any_day_unfixed_qty *
                                                    vn_during_total_val_price);
                  if vn_any_day_unfixed_qty > 0 then
                    vc_price_fixation_status := 'Partially Priced';
                  else
                    vc_price_fixation_status := 'Priced';
                  end if;
                else
                
                  while vd_dur_qp_start_date <= vd_dur_qp_end_date
                  loop
                    ---- finding holidays       
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_dur_qp_start_date) then
                      vc_holiday := 'Y';
                    else
                      vc_holiday := 'N';
                    end if;
                  
                    if vc_holiday = 'N' then
                      vn_during_total_val_price := vn_during_total_val_price +
                                                   vn_during_val_price;
                      vn_count_val_qp           := vn_count_val_qp + 1;
                    end if;
                    vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
                  end loop;
                end if;
              
                if (vn_count_val_qp + vn_count_set_qp) <> 0 then
                
                  if vn_market_flag = 'N' then
                    vn_during_qp_price := (vn_any_day_price_fix_qty_amt +
                                          vn_any_day_price_unfix_qty_amt) /
                                          cc1.qty_to_be_fixed;
                  
                  else
                    vn_during_qp_price := (vn_during_total_set_price +
                                          vn_during_total_val_price) /
                                          (vn_count_set_qp +
                                          vn_count_val_qp);
                  
                  end if;
                
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_during_qp_price;
                
                  --                  vc_price_unit_id        := cur_pcdi_rows.ppu_price_unit_id;
                
                else
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                  vn_total_contract_value := 0;
                
                  --                  vc_price_unit_id        := cur_pcdi_rows.ppu_price_unit_id;
                end if;
                vc_price_unit_id := cc1.ppu_price_unit_id;
              end if;
            
            end loop;
          
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      
        vn_error_no := vn_error_no + 1;
      elsif cur_pcdi_rows.price_option_call_off_status = 'Not Called Off' then
        vn_error_no              := vn_error_no + 1;
        vc_price_fixation_status := null;
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.internal_contract_item_ref_no)
        loop
          vc_price_basis       := cur_not_called_off_rows.price_basis;
          vc_price_description := cur_not_called_off_rows.price_description;
          -- vn_total_contract_value := 0;
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price        := cur_not_called_off_rows.price_value;
            vn_total_quantity        := cur_pcdi_rows.item_qty;
            vn_qty_to_be_priced      := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value  := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        vn_contract_price;
            vc_price_unit_id         := cur_not_called_off_rows.price_unit_id;
            vc_price_fixation_status := 'Fixed';
            vn_error_no              := 3;
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select pfqpp.qp_pricing_period_type,
                               pfqpp.qp_period_from_date,
                               pfqpp.qp_period_to_date,
                               pfqpp.qp_month,
                               pfqpp.qp_year,
                               pfqpp.qp_date,
                               pfqpp.event_name,
                               pfqpp.no_of_event_months,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id, --pum price unit id, as quoted available in this unit only
                               ppu.price_unit_name
                          from ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing  pfqpp,
                               v_ppu_pum                     ppu
                         where ppfh.ppfh_id = pfqpp.ppfh_id
                           and ppfh.pcbpd_id =
                               cur_not_called_off_rows.pcbpd_id
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id
                           and ppfh.process_id = pc_process_id
                           and pfqpp.process_id = pc_process_id)
            loop
            
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
            
              if cc1.qp_pricing_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              elsif cc1.qp_pricing_period_type = 'Month' then
                vd_qp_start_date := '01-' || cc1.qp_month || '-' ||
                                    cc1.qp_year;
                vd_qp_end_date   := last_day(vd_qp_start_date);
              elsif cc1.qp_pricing_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_date;
                vd_qp_end_date   := cc1.qp_date;
              elsif cc1.qp_pricing_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_not_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                  when others then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                end;
              else
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if cc1.qp_pricing_period_type = 'Event' then
                vc_price_fixation_status := 'Un-priced';
                vn_error_no              := 4;
                -- get third wednesday of QP period
                --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                        'Wed',
                                                                        3);
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  --get the price dr_id   
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cc1.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                
                  vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                      vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --get the price
              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'Before QP' then
              
                vc_price_fixation_status := 'Un-priced';
              
                vn_error_no := 4;
                ---- get third wednesday of QP period
                --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                        'Wed',
                                                                        3);
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  --get the price dr_id   
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cc1.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                
                  vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                      vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --get the price
              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              
              elsif (vc_period = 'During QP' or vc_period = 'After QP') then
                vc_price_fixation_status := 'Un-priced';
                vn_error_no              := 6;
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                        'Wed',
                                                                        3);
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if (vd_3rd_wed_of_qp <= pd_trade_date and
                     vc_period = 'During QP') or vc_period = 'After QP' then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                
                  --get the price dr_id   
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cc1.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       vd_qp_end_date);
                  else
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       pd_trade_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                --get the price              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_qp_price,
                         vc_during_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_during_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
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
               vc_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      
        pkg_general.sp_get_base_cur_detail(vc_price_cur_id,
                                           vc_contract_main_cur_id,
                                           vc_contract_main_cur_code,
                                           vn_contract_main_cur_factor);
        vn_error_no := 8;
      
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vc_price_weight_unit    := null;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
    
      -- Get the contract base price Unit id
      begin
      
        select ppu.product_price_unit_id
          into vc_contract_base_price_unit_id
          from v_ppu_pum ppu
         where ppu.weight_unit_id = cur_pcdi_rows.item_qty_unit_id
           and ppu.product_id = cur_pcdi_rows.product_id
           and ppu.cur_id = cur_pcdi_rows.base_cur_id;
      
      exception
        when no_data_found then
          vc_contract_base_price_unit_id := null;
      end;
      --
      -- Convert the final price into base price unit ID
      --
      --
      -- Get the Forward Exchange Rate from Price Unit ID to Base Price Unit ID
      --
      if vc_price_cur_id <> vc_base_main_cur_id then
        pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                                pd_trade_date,
                                                vd_payment_due_date,
                                                vc_price_cur_id,
                                                vc_base_main_cur_id,
                                                30,
                                                vn_fw_exch_rate_price_to_base,
                                                vn_forward_points);
      
        if vc_exch_rate_string is null then
          vc_exch_rate_string := '1 ' || vc_price_cur_code || '=' ||
                                 vn_fw_exch_rate_price_to_base || ' ' ||
                                 vc_base_main_cur_code;
        else
          vc_exch_rate_string := vc_exch_rate_string || ',' || '1 ' ||
                                 vc_price_cur_code || '=' ||
                                 vn_fw_exch_rate_price_to_base || ' ' ||
                                 vc_base_main_cur_code;
        end if;
      else
        vn_fw_exch_rate_price_to_base := 1.0;
      end if;
      vn_price_in_base_price_unit_id := vn_fw_exch_rate_price_to_base *
                                        vn_contract_main_cur_factor *
                                        pkg_general.f_get_converted_quantity(cur_pcdi_rows.product_id,
                                                                             vc_price_weight_unit_id,
                                                                             cur_pcdi_rows.item_qty_unit_id,
                                                                             1) *
                                        vn_average_price;
    
      vn_error_no := 9;
      insert into cipd_contract_item_price_daily
        (corporate_id,
         pcdi_id,
         internal_contract_item_ref_no,
         internal_contract_ref_no,
         contract_ref_no,
         delivery_item_no,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         price_basis,
         price_fixation_details,
         contract_equity_premium,
         market_equity_premium,
         mkt_equity_prem_price_unit_id,
         cont_equity_prem_price_unit_id,
         process_id,
         price_fixation_status,
         price_fixed_qty,
         total_qty,
         payment_due_date,
         contract_base_price_unit_id,
         -- contract_base_fx_rate,
         exch_rate_string,
         price_description,
         price_in_base_price_unit_id)
      values
        (pc_corporate_id,
         cur_pcdi_rows.pcdi_id,
         cur_pcdi_rows.internal_contract_item_ref_no,
         cur_pcdi_rows.internal_contract_ref_no,
         cur_pcdi_rows.contract_ref_no,
         cur_pcdi_rows.delivery_item_no,
         vn_average_price,
         vc_price_unit_id,
         vc_price_cur_id,
         vc_price_cur_code,
         vc_price_weight_unit,
         vc_price_weight_unit_id,
         vc_price_qty_unit,
         vc_price_basis,
         'Not Applicable',
         vn_contract_equity_premium,
         vn_market_equity_premium,
         vc_mar_equ_prem_price_unit_id,
         vc_con_equ_prem_price_unit_id,
         pc_process_id,
         vc_price_fixation_status,
         vn_price_fixed_qty,
         vn_total_qty,
         cur_pcdi_rows.payment_due_date,
         vc_contract_base_price_unit_id,
         -- vn_fw_exch_rate_price_to_base,
         vc_exch_rate_string,
         vc_price_description,
         vn_price_in_base_price_unit_id);
      update pci_physical_contract_item pci
         set pci.price_description = vc_price_description
       where pci.internal_contract_item_ref_no =
            
             cur_pcdi_rows.internal_contract_item_ref_no
         and pci.process_id = pc_process_id;
    
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
                                                           dbms_utility.format_error_backtrace ||
                                                           'No ' ||
                                                           vn_error_no,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_calc_gmr_price(pc_corporate_id varchar2,
                              pd_trade_date   date,
                              pc_process_id   varchar2,
                              pc_user_id      varchar2,
                              pc_dbd_id       varchar2,
                              pc_process      varchar2) is
  
    cursor cur_gmr is
      select gmr.corporate_id,
             grd.product_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.pofh_id,
             pd_trade_date eod_trade_date,
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
             pofh.qty_to_be_fixed,
             round(pofh.priced_qty, 4) priced_qty,
             pofh.no_of_prompt_days,
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable,
             grd.payment_due_date
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id,
                     (case
                       when nvl(grd.payment_due_date, pd_trade_date) <
                            pd_trade_date then
                        pd_trade_date
                       else
                        grd.payment_due_date
                     end) payment_due_date
              
                from grd_goods_record_detail grd
               where grd.process_id = pc_process_id
                 and grd.tolling_stock_type = 'None Tolling'
                 and grd.status = 'Active'
                 and grd.is_deleted = 'N'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id,
                        (case
                          when nvl(grd.payment_due_date, pd_trade_date) <
                               pd_trade_date then
                           pd_trade_date
                          else
                           grd.payment_due_date
                        end)) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             --mv_qat_quality_valuation qat,
             ged_gmr_exchange_detail      qat,
             dim_der_instrument_master    dim,
             div_der_instrument_valuation div,
             ps_price_source              ps,
             apm_available_price_master   apm,
             pum_price_unit_master        pum,
             v_der_instrument_price_unit  vdip,
             pdc_prompt_delivery_calendar pdc
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdtm.product_type_name = 'Standard'
         and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
            --and grd.quality_id = qat.quality_id
         and gmr.process_id = pc_process_id
         and qat.corporate_id(+) = pc_corporate_id
         and gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
            --   and gmr.process_id = qat.process_id(+)
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
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.pofh_id,
             pd_trade_date eod_trade_date,
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
             pofh.qty_to_be_fixed,
             round(pofh.priced_qty, 4) priced_qty,
             pofh.no_of_prompt_days,
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable,
             grd.payment_due_date
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id,
                     (case
                       when nvl(grd.payment_due_date, pd_trade_date) <
                            pd_trade_date then
                        pd_trade_date
                       else
                        grd.payment_due_date
                     end) payment_due_date
                from dgrd_delivered_grd grd
               where grd.process_id = pc_process_id
                 and grd.status = 'Active'
                 and grd.tolling_stock_type = 'None Tolling'
              --and grd.is_deleted = 'N'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id,
                        (case
                          when nvl(grd.payment_due_date, pd_trade_date) <
                               pd_trade_date then
                           pd_trade_date
                          else
                           grd.payment_due_date
                        end)) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             --mv_qat_quality_valuation qat,
             (select *
                from ged_gmr_exchange_detail
               where corporate_id = pc_corporate_id) qat,
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
            --and grd.quality_id = qat.quality_id
         and gmr.process_id = pc_process_id
            -- and qat.corporate_id = pc_corporate_id
         and gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
            --and gmr.process_id = qat.process_id(+)
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
  
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(50);
    vd_3rd_wed_of_qp               date;
    workings_days                  number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_total_contract_value        number;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vc_holiday                     char(1);
    vn_during_qp_price             number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vc_price_weight_unit           number;
    vc_price_weight_unit_id        varchar2(15);
    vc_price_qty_unit              varchar2(15);
    vc_price_fixation_status       varchar2(50);
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_amt   number;
    vn_any_day_price_ufix_qty_amt  number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_price_unit_id               varchar2(15);
    vc_ppu_price_unit_id           varchar2(15);
    vc_price_name                  varchar2(100);
    vc_pcbpd_id                    varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vc_contract_base_price_unit_id varchar2(15);
    vc_contract_main_cur_id        varchar2(15);
    vc_contract_main_cur_code      varchar2(15);
    vn_contract_main_cur_factor    number;
    vc_base_main_cur_id            varchar2(15);
    vc_base_main_cur_code          varchar2(15);
    vn_settlement_price            number;
    vn_forward_points              number;
    vc_exch_rate_string            varchar2(300);
    vn_price_in_base_price_unit_id number;
    vc_fixed_price_unit_id         varchar2(15);
    vd_valid_quote_date            date;
  begin
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          2001,
                          'Start of base gmr price');
    delete from ged_gmr_exchange_detail ged
     where ged.corporate_id = pc_corporate_id;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          2002,
                          'Delete GED');
    commit;
  
    insert into ged_gmr_exchange_detail
      (corporate_id,
       internal_gmr_ref_no,
       instrument_id,
       instrument_name,
       derivative_def_id,
       derivative_def_name,
       exchange_id,
       exchange_name,
       element_id)
      select pcbpd.process_id,
             pofh.internal_gmr_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             emt.exchange_id,
             emt.exchange_name,
             pcbpd.element_id
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             ppfh_phy_price_formula_header  ppfh,
             ppfd_phy_price_formula_details ppfd,
             dim_der_instrument_master      dim,
             pdd_product_derivative_def     pdd,
             emt_exchangemaster             emt
       where pofh.pocd_id = pocd.pocd_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbpd_id = ppfh.pcbpd_id
         and ppfh.ppfh_id = ppfd.ppfh_id
         and pcbpd.process_id = ppfh.process_id
         and ppfh.process_id = ppfd.process_id
         and ppfd.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.exchange_id = emt.exchange_id(+)
         and pofh.internal_gmr_ref_no is not null
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and ppfh.is_active = 'Y'
         and ppfd.is_active = 'Y'
         and ppfd.process_id = pc_process_id
       group by pcbpd.process_id,
                pofh.internal_gmr_ref_no,
                ppfd.instrument_id,
                dim.instrument_name,
                pdd.derivative_def_id,
                pdd.derivative_def_name,
                emt.exchange_id,
                emt.exchange_name,
                pcbpd.element_id;
    commit;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          2003,
                          'Insert GED');
  
    for cur_gmr_rows in cur_gmr
    loop
      vc_price_fixation_status      := null;
      vn_total_contract_value       := 0;
      vn_market_flag                := null;
      vn_any_day_price_fix_qty_amt  := 0;
      vn_any_day_price_ufix_qty_amt := 0;
      vn_any_day_unfixed_qty        := 0;
      vn_any_day_fixed_qty          := 0;
      vc_pcbpd_id                   := cur_gmr_rows.pcbpd_id;
      vc_price_unit_id              := null;
      vc_ppu_price_unit_id          := null;
      vd_qp_start_date              := cur_gmr_rows.qp_start_date;
      vd_qp_end_date                := cur_gmr_rows.qp_end_date;
    
      begin
      
        select ppu.product_price_unit_id,
               akc.base_cur_id,
               cm.cur_code
          into vc_contract_base_price_unit_id,
               vc_base_main_cur_id,
               vc_base_main_cur_code
          from v_ppu_pum          ppu,
               pdm_productmaster  pdm,
               ak_corporate       akc,
               cm_currency_master cm
         where ppu.weight_unit_id = pdm.base_quantity_unit
           and ppu.product_id = pdm.product_id
           and ppu.product_id = cur_gmr_rows.product_id
           and ppu.cur_id = akc.base_cur_id
           and akc.corporate_id = pc_corporate_id
           and ppu.cur_id = cm.cur_id;
      
      exception
        when no_data_found then
          vc_contract_base_price_unit_id := null;
      end;
    
      if cur_gmr_rows.eod_trade_date >= vd_qp_start_date and
         cur_gmr_rows.eod_trade_date <= vd_qp_end_date then
        vc_period := 'During QP';
      elsif cur_gmr_rows.eod_trade_date < vd_qp_start_date and
            cur_gmr_rows.eod_trade_date < vd_qp_end_date then
        vc_period := 'Before QP';
      elsif cur_gmr_rows.eod_trade_date > vd_qp_start_date and
            cur_gmr_rows.eod_trade_date > vd_qp_end_date then
        vc_period := 'After QP';
      end if;
      begin
        select ppu.product_price_unit_id,
               ppu.price_unit_id,
               ppu.price_unit_name
          into vc_ppu_price_unit_id,
               vc_price_unit_id,
               vc_price_name
          from ppfh_phy_price_formula_header ppfh,
               v_ppu_pum                     ppu
         where ppfh.pcbpd_id = vc_pcbpd_id
           and ppfh.process_id = pc_process_id
           and ppfh.price_unit_id = ppu.product_price_unit_id
           and rownum <= 1;
      exception
        when no_data_found then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
          vc_price_name        := cur_gmr_rows.price_unit_name;
        when others then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
          vc_price_name        := cur_gmr_rows.price_unit_name;
      end;
      if vc_period = 'Before QP' then
        vc_price_fixation_status := 'Un-priced';
      
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                'Wed',
                                                                3);
        
          while true
          loop
            if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                   vd_3rd_wed_of_qp) then
              vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
            else
              exit;
            end if;
          end loop;
        
          --- get 3rd wednesday  before QP period 
          -- Get the quotation date = Trade Date +2 working Days
          if vd_3rd_wed_of_qp <= pd_trade_date then
            workings_days  := 0;
            vd_quotes_date := pd_trade_date + 1;
            while workings_days <> 2
            loop
              if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
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
              into vc_before_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.prompt_date = vd_3rd_wed_of_qp
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_calc_gmr_price',
                                                                   'PHY-002',
                                                                   'DR_ID missing for ' ||
                                                                   cur_gmr_rows.instrument_name ||
                                                                   ',Price Source:' ||
                                                                   cur_gmr_rows.price_source_name ||
                                                                   ' GMR No: ' ||
                                                                   cur_gmr_rows.gmr_ref_no ||
                                                                   ',Price Unit:' ||
                                                                   vc_price_name || ',' ||
                                                                   cur_gmr_rows.available_price_name ||
                                                                   ' Price,Prompt Date:' ||
                                                                   vd_3rd_wed_of_qp,
                                                                   '',
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            
          end;
        
        elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
              cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
        
          vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                              vd_qp_end_date);
          vc_prompt_month := to_char(vc_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
        
          ---- get the dr_id             
          begin
            select drm.dr_id
              into vc_before_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.period_month = vc_prompt_month
               and drm.period_year = vc_prompt_year
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_calc_contract_price',
                                                                   'PHY-002',
                                                                   'DR_ID missing for ' ||
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
                                                                   vc_prompt_year,
                                                                   '',
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
          end;
        end if;
        --get the price              
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_before_qp_price,
                 vc_before_qp_price_unit_id
            from dq_derivative_quotes        dq,
                 dqd_derivative_quote_detail dqd,
                 cdim_corporate_dim          cdim
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_before_price_dr_id
             and dq.process_id = pc_process_id
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dq.process_id = dqd.process_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dqd.price_unit_id = vc_price_unit_id
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
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_gmr_price','PHY-002','Price missing for ' || cur_gmr_rows.instrument_name ||',Price Source:' || cur_gmr_rows.price_source_name ||' GMR No: ' || cur_gmr_rows.gmr_ref_no ||',Price Unit:' || vc_price_name ||',' || cur_gmr_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_gmr_rows.is_daily_cal_applicable = 'N' and cur_gmr_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
            sp_insert_error_log(vobj_error_log);
        end;
        vn_total_contract_value := vn_total_contract_value +
                                   vn_before_qp_price;
        --  vc_price_unit_id        := cur_gmr_rows.ppu_price_unit_id;
      elsif vc_period = 'During QP' or vc_period = 'After QP' then
        vd_dur_qp_start_date      := vd_qp_start_date;
        vd_dur_qp_end_date        := vd_qp_end_date;
        vn_during_total_set_price := 0;
        vn_count_set_qp           := 0;
        for cc in (select pfd.user_price,
                          pfd.as_of_date,
                          pfd.qty_fixed,
                          pofh.final_price,
                          pocd.is_any_day_pricing,
                          pfd.price_unit_id
                     from poch_price_opt_call_off_header poch,
                          pocd_price_option_calloff_dtls pocd,
                          pofh_price_opt_fixation_header pofh,
                          pfd_price_fixation_details     pfd
                    where poch.poch_id = pocd.poch_id
                      and pocd.pocd_id = pofh.pocd_id
                      and pofh.pofh_id = cur_gmr_rows.pofh_id
                      and pofh.pofh_id = pfd.pofh_id
                      and pfd.as_of_date >= vd_dur_qp_start_date
                      and pfd.as_of_date <= pd_trade_date
                      and poch.is_active = 'Y'
                      and pocd.is_active = 'Y'
                      and pofh.is_active = 'Y'
                      and pfd.is_active = 'Y')
        loop
          vn_during_total_set_price := vn_during_total_set_price +
                                       cc.user_price;
          vn_count_set_qp           := vn_count_set_qp + 1;
        
          vn_any_day_price_fix_qty_amt := vn_any_day_price_fix_qty_amt +
                                          (cc.user_price * cc.qty_fixed);
        
          if cc.final_price is not null then
            vc_price_fixation_status := 'Finalized';
          end if;
          vn_any_day_fixed_qty := vn_any_day_fixed_qty + cc.qty_fixed;
        
          vc_fixed_price_unit_id := cc.price_unit_id;
        end loop;
      
        if vn_count_set_qp <> 0 then
          if vc_price_fixation_status <> 'Finalized' then
            vc_price_fixation_status := 'Partially Priced';
          end if;
        else
          vc_price_fixation_status := 'Un-priced';
        
        end if;
        if cur_gmr_rows.is_any_day_pricing = 'Y' then
          vn_market_flag := 'N';
        else
          vn_market_flag := 'Y';
        end if;
      
        -- get the third wednesday
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_dur_qp_end_date,
                                                                'Wed',
                                                                3);
          while true
          loop
            if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                   vd_3rd_wed_of_qp) then
              vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
            else
              exit;
            end if;
          end loop;
          --- get 3rd wednesday  before QP period 
          -- Get the quotation date = Trade Date +2 working Days
          if (vd_3rd_wed_of_qp <= pd_trade_date or vc_period = 'During QP') or
             vc_period = 'After QP' then
            workings_days  := 0;
            vd_quotes_date := pd_trade_date + 1;
            while workings_days <> 2
            loop
              if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
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
          --Get the DR-id
          begin
            select drm.dr_id
              into vc_during_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.prompt_date = vd_3rd_wed_of_qp
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_calc_gmr_price',
                                                                   'PHY-002',
                                                                   'DR-ID missing for ' ||
                                                                   cur_gmr_rows.instrument_name ||
                                                                   ',Price Source:' ||
                                                                   cur_gmr_rows.price_source_name ||
                                                                   ' GMR NO: ' ||
                                                                   cur_gmr_rows.gmr_ref_no ||
                                                                   ',Price Unit:' ||
                                                                   vc_price_name || ',' ||
                                                                   cur_gmr_rows.available_price_name ||
                                                                   ' Price,Prompt Date:' ||
                                                                   vd_3rd_wed_of_qp,
                                                                   '',
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
          end;
        elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
              cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
          if vc_period = 'During QP' then
            vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                               vd_qp_end_date);
          else
            vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                               pd_trade_date);
          
          end if;
          vc_prompt_month := to_char(vc_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
          ---- get the dr_id             
          begin
            select drm.dr_id
              into vc_during_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.period_month = vc_prompt_month
               and drm.period_year = vc_prompt_year
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_calc_contract_price',
                                                                   'PHY-002',
                                                                   'DR_ID missing for ' ||
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
                                                                   vc_prompt_year,
                                                                   '',
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
          end;
        end if;
        --Get the price for the dr-id
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_during_val_price,
                 vc_during_val_price_unit_id
            from dq_derivative_quotes        dq,
                 dqd_derivative_quote_detail dqd,
                 cdim_corporate_dim          cdim
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_during_price_dr_id
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dq.dbd_id = dqd.dbd_id
             and dq.dbd_id = pc_dbd_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dq.trade_date = cdim.valid_quote_date
             and dqd.price_unit_id = vc_price_unit_id
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
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_gmr_price','PHY-002','Price missing for ' || cur_gmr_rows.instrument_name ||',Price Source:' || cur_gmr_rows.price_source_name ||' GMR No: ' || cur_gmr_rows.gmr_ref_no ||',Price Unit:' || vc_price_name ||',' || cur_gmr_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_gmr_rows.is_daily_cal_applicable = 'N' and cur_gmr_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
            sp_insert_error_log(vobj_error_log);
        end;
        vn_during_total_val_price := 0;
        vn_count_val_qp           := 0;
        vd_dur_qp_start_date      := pd_trade_date + 1;
        if vn_market_flag = 'N' then
          vn_during_total_val_price := vn_during_total_val_price +
                                       vn_during_val_price;
        
          vn_any_day_unfixed_qty        := cur_gmr_rows.qty_to_be_fixed -
                                           vn_any_day_fixed_qty;
          vn_count_val_qp               := vn_count_val_qp + 1;
          vn_any_day_price_ufix_qty_amt := (vn_any_day_unfixed_qty *
                                           vn_during_total_val_price);
        
        else
          while vd_dur_qp_start_date <= vd_dur_qp_end_date
          loop
            if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                   vd_dur_qp_start_date) then
              vc_holiday := 'Y';
            else
              vc_holiday := 'N';
            end if;
            if vc_holiday = 'N' then
              vn_during_total_val_price := vn_during_total_val_price +
                                           vn_during_val_price;
              vn_count_val_qp           := vn_count_val_qp + 1;
            end if;
            vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
          end loop;
        end if;
        if (vn_count_val_qp + vn_count_set_qp) <> 0 then
        
          if vn_market_flag = 'N' then
            vn_during_qp_price := (vn_any_day_price_fix_qty_amt +
                                  vn_any_day_price_ufix_qty_amt) /
                                  cur_gmr_rows.qty_to_be_fixed;
          else
            vn_during_qp_price := (vn_during_total_set_price +
                                  vn_during_total_val_price) /
                                  (vn_count_set_qp + vn_count_val_qp);
          end if;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_during_qp_price;
        else
          vn_total_contract_value := 0;
        end if;
      
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
               vc_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_ppu_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vc_price_weight_unit    := null;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
    
      pkg_general.sp_get_base_cur_detail(vc_price_cur_id,
                                         vc_contract_main_cur_id,
                                         vc_contract_main_cur_code,
                                         vn_contract_main_cur_factor);
    
      --
      -- Get the Forward Exchange Rate from Price Unit ID to Base Price Unit ID
      --
      if vc_contract_main_cur_id <> vc_base_main_cur_id then
        pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                                pd_trade_date,
                                                cur_gmr_rows.payment_due_date,
                                                vc_contract_main_cur_id,
                                                vc_base_main_cur_id,
                                                30,
                                                vn_settlement_price,
                                                vn_forward_points);
        vc_exch_rate_string := vc_contract_main_cur_id || '=' ||
                               vn_settlement_price || ' ' ||
                               vc_base_main_cur_id;
        if vn_settlement_price is null or vn_settlement_price = 0 then
        
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure pkg_phy_physical_process Bae GMR Price',
                                                               'PHY-005',
                                                               vc_base_main_cur_code ||
                                                               ' to ' ||
                                                               vc_contract_main_cur_id || ' (' ||
                                                               to_char(cur_gmr_rows.payment_due_date,
                                                                       'dd-Mon-yyyy') || ') ',
                                                               '',
                                                               pc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
        end if;
      else
        vn_settlement_price := 1.0;
      end if;
      vn_price_in_base_price_unit_id := vn_settlement_price *
                                        vn_total_contract_value;
    
      insert into gpd_gmr_price_daily
        (corporate_id,
         internal_gmr_ref_no,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         process_id,
         price_fixation_status,
         contract_base_price_unit_id,
         exch_rate_string,
         price_in_base_price_unit_id)
      values
        (cur_gmr_rows.corporate_id,
         cur_gmr_rows.internal_gmr_ref_no,
         vn_total_contract_value,
         vc_ppu_price_unit_id,
         vc_price_cur_id,
         vc_price_cur_code,
         vc_price_weight_unit,
         vc_price_weight_unit_id,
         vc_price_qty_unit,
         pc_process_id,
         vc_price_fixation_status,
         null,
         null,
         null);
    
    end loop;
    commit;
  end;

  procedure sp_calc_stock_price(pc_process_id varchar2) is
    cursor cur_price is
      select *
        from (select scm.internal_grd_ref_no          internal_grd_ref_no,
                     cigc.int_contract_item_ref_no    int_contract_item_ref_no,
                     scm.transformation_ratio         transformation_ratio,
                     cipd.price_in_base_price_unit_id contract_price,
                     cipd.contract_base_price_unit_id price_unit_id,
                     grd.qty                          stock_qty
                from scm_stock_cost_mapping         scm,
                     cigc_contract_item_gmr_cost    cigc,
                     cipd_contract_item_price_daily cipd,
                     grd_goods_record_detail        grd,
                     cs_cost_store                  cs,
                     scm_service_charge_master      scm_master
               where scm.cog_ref_no = cigc.cog_ref_no
                 and cigc.process_id = pc_process_id
                 and scm.is_deleted = 'N'
                 and cigc.is_deleted = 'N'
                 and cigc.int_contract_item_ref_no is not null
                 and scm.internal_grd_ref_no is not null
                 and cipd.internal_contract_item_ref_no =
                     cigc.int_contract_item_ref_no
                 and cipd.process_id = pc_process_id
                 and grd.internal_grd_ref_no = scm.internal_grd_ref_no
                 and grd.process_id = cigc.process_id
                 and cs.cog_ref_no = cigc.cog_ref_no
                 and cs.cost_component_id = scm_master.cost_id
                 and scm_master.cost_component_name = 'Material Cost'
                 and scm_master.cost_type = 'DIRECT_COST'
                 and cs.process_id = pc_process_id
                 and nvl(grd.inventory_status, 'NA') = 'In'
              union all
              select grd.internal_grd_ref_no           internal_grd_ref_no,
                     grd.internal_contract_item_ref_no int_contract_item_ref_no,
                     1                                 transformation_ratio,
                     cipd.price_in_base_price_unit_id  contract_price,
                     cipd.contract_base_price_unit_id  price_unit_id,
                     grd.qty                           stock_qty
                from grd_goods_record_detail        grd,
                     cipd_contract_item_price_daily cipd
               where grd.internal_contract_item_ref_no =
                     cipd.internal_contract_item_ref_no
                 and grd.process_id = pc_process_id
                 and cipd.process_id = grd.process_id
                 and nvl(grd.inventory_status, 'NA') = 'NA'
                 and grd.is_deleted = 'N'
                 and grd.status = 'Active'
              union all
              select scm.internal_dgrd_ref_no,
                     cigc.int_contract_item_ref_no,
                     scm.transformation_ratio,
                     cipd.price_in_base_price_unit_id contract_price,
                     cipd.contract_base_price_unit_id price_unit_id,
                     dgrd.net_weight stock_qty
                from scm_stock_cost_mapping         scm,
                     cigc_contract_item_gmr_cost    cigc,
                     cipd_contract_item_price_daily cipd,
                     dgrd_delivered_grd             dgrd,
                     cs_cost_store                  cs,
                     scm_service_charge_master      scm_master
               where scm.cog_ref_no = cigc.cog_ref_no
                 and cigc.process_id = pc_process_id
                 and scm.is_deleted = 'N'
                 and cigc.is_deleted = 'N'
                 and cipd.internal_contract_item_ref_no =
                     cigc.int_contract_item_ref_no
                 and cipd.process_id = pc_process_id
                 and dgrd.internal_dgrd_ref_no = scm.internal_dgrd_ref_no
                 and dgrd.process_id = pc_process_id
                 and cs.cog_ref_no = cigc.cog_ref_no
                 and cs.cost_component_id = scm_master.cost_id
                 and scm_master.cost_component_name = 'Material Cost'
                 and scm_master.cost_type = 'DIRECT_COST'
                 and cs.process_id = pc_process_id
                 and nvl(dgrd.inventory_status, 'NA') = 'Out'
              union all
              select dgrd.internal_dgrd_ref_no          internal_grd_ref_no,
                     cipd.internal_contract_item_ref_no int_contract_item_ref_no,
                     1                                  transformation_ratio,
                     cipd.price_in_base_price_unit_id   contract_price,
                     cipd.contract_base_price_unit_id   price_unit_id,
                     dgrd.net_weight                    stock_qty
                from dgrd_delivered_grd             dgrd,
                     cipd_contract_item_price_daily cipd
               where dgrd.internal_contract_item_ref_no =
                     cipd.internal_contract_item_ref_no
                 and dgrd.process_id = pc_process_id
                 and cipd.process_id = dgrd.process_id
                 and nvl(dgrd.inventory_status, 'NA') in ('NA', 'None')
                 and dgrd.status = 'Active'
              
              )
       order by internal_grd_ref_no;
  
    vc_is_data_to_populate       varchar2(1) := 'N'; -- Represents that there was arleast one record which needed price calculation, Only required when there are zero stocks in the system
    vc_current_grd_dgrd_ref_no   varchar2(15);
    vc_previous_grd_dgrd_ref_no  varchar2(15);
    vn_item_mc                   number := 0;
    vn_total_mc                  number;
    vn_avg_mc                    number := 0;
    vn_item_qty                  number;
    vn_total_item_qty            number := 0;
    vc_price_unit_id             varchar2(15);
    vc_price_unit_cur_id         varchar2(15);
    vc_price_unit_cur_code       varchar2(15);
    vc_price_unit_weight_unit_id varchar2(15);
    vc_price_unit_weight_unit    varchar2(15);
    vn_price_unit_weight         number;
  begin
    for cur_price_rows in cur_price
    loop
      vc_is_data_to_populate := 'Y';
      if cur_price_rows.internal_grd_ref_no <> vc_current_grd_dgrd_ref_no or
         vc_current_grd_dgrd_ref_no is null then
        vc_current_grd_dgrd_ref_no := cur_price_rows.internal_grd_ref_no;
        vc_price_unit_id           := cur_price_rows.price_unit_id;
      
        select cm.cur_id,
               cm.cur_code,
               qum.qty_unit_id,
               qum.qty_unit,
               pum.weight
          into vc_price_unit_cur_id,
               vc_price_unit_cur_code,
               vc_price_unit_weight_unit_id,
               vc_price_unit_weight_unit,
               vn_price_unit_weight
          from ppu_product_price_units  ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum,
               pum_price_unit_master    pum
         where ppu.internal_price_unit_id = vc_price_unit_id
           and ppu.price_unit_id = pum.price_unit_id
           and pum.is_active = 'Y'
           and pum.is_deleted = 'N'
           and pum.cur_id = cm.cur_id
           and pum.weight_unit_id = qum.qty_unit_id;
      
      end if;
      vn_item_qty := cur_price_rows.stock_qty;
      vn_item_mc  := cur_price_rows.contract_price * vn_item_qty *
                     cur_price_rows.transformation_ratio;
      --
      -- Calculate the Price for the Previous GRD Since the GRD has changed
      --
      if vc_current_grd_dgrd_ref_no <> vc_previous_grd_dgrd_ref_no then
        --
        -- Calculate the Average Materail Cost
        --
        vn_avg_mc := vn_total_mc / vn_total_item_qty;
        insert into spd_stock_price_daily
          (process_id,
           internal_drg_dgrd_ref_no,
           stock_price,
           price_unit_id,
           price_unit_cur_id,
           price_unit_cur_code,
           price_unit_weight_unit_id,
           price_unit_weight_unit,
           price_unit_weight)
        values
          (pc_process_id,
           vc_previous_grd_dgrd_ref_no,
           vn_avg_mc,
           vc_price_unit_id,
           vc_price_unit_cur_id,
           vc_price_unit_cur_code,
           vc_price_unit_weight_unit_id,
           vc_price_unit_weight_unit,
           vn_price_unit_weight);
        --
        -- New Stock came, Renitialize the Price and Qty
        --
        vn_total_mc       := vn_item_mc;
        vn_total_item_qty := vn_item_qty;
      else
        --
        -- Old Stock with Different Item Or First Stock in the query
        --
        if vn_total_mc is null then
          -- First Stock in the query
          vn_total_mc       := vn_item_mc;
          vn_total_item_qty := vn_item_qty;
        else
          -- Old Stock with Different Item
          vn_total_mc       := vn_total_mc + vn_item_mc;
          vn_total_item_qty := vn_total_item_qty + vn_item_qty;
        end if;
      end if;
      vc_previous_grd_dgrd_ref_no := cur_price_rows.internal_grd_ref_no;
    end loop;
    --
    -- Need to insert data for the last record outside of the loop
    -- 
    if vc_is_data_to_populate = 'Y' then
      vn_avg_mc := vn_total_mc / vn_total_item_qty;
      insert into spd_stock_price_daily
        (process_id,
         internal_drg_dgrd_ref_no,
         stock_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         price_unit_weight)
      values
        (pc_process_id,
         vc_previous_grd_dgrd_ref_no,
         vn_avg_mc,
         vc_price_unit_id,
         vc_price_unit_cur_id,
         vc_price_unit_cur_code,
         vc_price_unit_weight_unit_id,
         vc_price_unit_weight_unit,
         vn_price_unit_weight);
    end if;
    commit;
  end;
  procedure sp_calc_conc_gmr_price(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process_id   varchar2,
                                   pc_user_id      varchar2,
                                   pc_dbd_id       varchar2,
                                   pc_process      varchar2) is
  
    cursor cur_gmr is
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             gmr.qty_unit_id,
             grd.product_id,
             pd_trade_date eod_trade_date,
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
                     grd.quality_id,
                     grd.product_id
                from grd_goods_record_detail grd
               where grd.process_id = pc_process_id
                 and grd.status = 'Active'
                 and grd.tolling_stock_type in
                     ('None Tolling', 'Clone Stock')
                 and grd.is_deleted = 'N'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             v_gmr_stockpayable_qty spq,
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
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             gmr.qty_unit_id,
             grd.product_id,
             pd_trade_date eod_trade_date,
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
                     grd.quality_id,
                     grd.product_id
                from dgrd_delivered_grd grd
               where grd.process_id = pc_process_id
                 and grd.status = 'Active'
                 and grd.tolling_stock_type in
                     ('None Tolling', 'Clone Stock')
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             v_gmr_stockpayable_qty spq,
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
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.qty_to_be_fixed,
             pcbpd.element_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pocd.is_any_day_pricing,
             pcbpd.price_basis,
             pcbph.price_description,
             pofh.no_of_prompt_days,
             pofh.final_price,
             pofh.avg_price_in_price_in_cur,
             pocd.pay_in_price_unit_id,
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
         and pofh.qty_to_be_fixed <> 0
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y'
         and pcbpd.element_id = aml.attribute_id
         and aml.underlying_product_id = pdm.product_id;
  
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(50);
    vd_3rd_wed_of_qp               date;
    workings_days                  number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_total_contract_value        number;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vc_holiday                     char(1);
    vn_during_qp_price             number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vc_price_weight_unit           number;
    vc_price_weight_unit_id        varchar2(15);
    vc_price_qty_unit              varchar2(15);
    vc_price_fixation_status       varchar2(50);
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_amt   number;
    vn_any_day_price_ufix_qty_amt  number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_price_unit_id               varchar2(15);
    vc_ppu_price_unit_id           varchar2(15);
    vc_price_name                  varchar2(100);
    vc_pcbpd_id                    varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vn_qty_to_be_priced            number;
    vn_total_quantity              number;
    vn_average_price               number;
    vc_price_basis                 varchar2(15);
    vc_price_description           varchar2(4000);
    vc_price_main_cur_id           varchar2(15);
    vc_price_main_cur_code         varchar2(15);
    vn_price_main_cur_factor       number;
    vc_contract_base_price_unit_id varchar2(15);
    vn_fw_exch_rate_price_to_base  number;
    vc_exch_rate_string            varchar2(100);
    vn_price_in_base_price_unit_id number;
    vc_base_main_cur_id            varchar2(15);
    vc_base_main_cur_code          varchar2(15);
    vn_forward_points              number;
    vc_gmr_ele_product_id          varchar2(15);
    vc_gmr_ele_base_qty_unit_id    varchar2(15);
    vd_valid_quote_date            date;
  begin
    select cm.cur_id,
           cm.cur_code
      into vc_base_main_cur_id,
           vc_base_main_cur_code
      from ak_corporate       akc,
           cm_currency_master cm
     where akc.corporate_id = pc_corporate_id
       and akc.base_cur_id = cm.cur_id;
  
    for cur_gmr_rows in cur_gmr
    loop
      vn_total_contract_value := 0;
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no,
                                          cur_gmr_rows.element_id)
      loop
      
        vc_gmr_ele_product_id       := cur_gmr_ele_rows.product_id;
        vc_gmr_ele_base_qty_unit_id := cur_gmr_ele_rows.base_qty_unit_id;
      
        vc_price_basis                := cur_gmr_ele_rows.price_basis;
        vc_price_description          := cur_gmr_ele_rows.price_description;
        vc_price_fixation_status      := null;
        vn_market_flag                := null;
        vn_any_day_price_fix_qty_amt  := 0;
        vn_any_day_price_ufix_qty_amt := 0;
        vn_any_day_unfixed_qty        := 0;
        vn_any_day_fixed_qty          := 0;
        vc_pcbpd_id                   := cur_gmr_ele_rows.pcbpd_id;
        vc_price_unit_id              := null;
        vc_ppu_price_unit_id          := null;
        vd_qp_start_date              := cur_gmr_ele_rows.qp_start_date;
        vd_qp_end_date                := cur_gmr_ele_rows.qp_end_date;
      
        if cur_gmr_rows.eod_trade_date >= vd_qp_start_date and
           cur_gmr_rows.eod_trade_date <= vd_qp_end_date then
          vc_period := 'During QP';
        elsif cur_gmr_rows.eod_trade_date < vd_qp_start_date and
              cur_gmr_rows.eod_trade_date < vd_qp_end_date then
          vc_period := 'Before QP';
        elsif cur_gmr_rows.eod_trade_date > vd_qp_start_date and
              cur_gmr_rows.eod_trade_date > vd_qp_end_date then
          vc_period := 'After QP';
        end if;
      
        begin
          select ppu.product_price_unit_id,
                 ppu.price_unit_id,
                 ppu.price_unit_name
            into vc_ppu_price_unit_id,
                 vc_price_unit_id,
                 vc_price_name
            from ppfh_phy_price_formula_header ppfh,
                 v_ppu_pum                     ppu
           where ppfh.pcbpd_id = vc_pcbpd_id
             and ppfh.process_id = pc_process_id
             and ppfh.price_unit_id = ppu.product_price_unit_id
             and rownum <= 1;
        exception
          when no_data_found then
            vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
            vc_price_unit_id     := cur_gmr_rows.price_unit_id;
            vc_price_name        := cur_gmr_rows.price_unit_name;
          when others then
            vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
            vc_price_unit_id     := cur_gmr_rows.price_unit_id;
            vc_price_name        := cur_gmr_rows.price_unit_name;
        end;
      
        if vc_period = 'Before QP' then
          vc_price_fixation_status := 'Un-priced';
        
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          
            vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                  'Wed',
                                                                  3);
          
            while true
            loop
              if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                     vd_3rd_wed_of_qp) then
                vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
              else
                exit;
              end if;
            end loop;
          
            --- get 3rd wednesday  before QP period 
            -- Get the quotation date = Trade Date +2 working Days
            if vd_3rd_wed_of_qp <= pd_trade_date then
              workings_days  := 0;
              vd_quotes_date := pd_trade_date + 1;
              while workings_days <> 2
              loop
                if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
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
                into vc_before_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.prompt_date = vd_3rd_wed_of_qp
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_calc_conc_gmr_price',
                                                                     'PHY-002',
                                                                     'DR_ID missing for ' ||
                                                                     cur_gmr_rows.instrument_name ||
                                                                     ',Price Source:' ||
                                                                     cur_gmr_rows.price_source_name ||
                                                                     ' GMR No: ' ||
                                                                     cur_gmr_rows.gmr_ref_no ||
                                                                     ',Price Unit:' ||
                                                                     vc_price_name || ',' ||
                                                                     cur_gmr_rows.available_price_name ||
                                                                     ' Price,Prompt Date:' ||
                                                                     vd_3rd_wed_of_qp,
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
              
            end;
          
          elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
                cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
          
            vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                                vd_qp_end_date);
            vc_prompt_month := to_char(vc_prompt_date, 'Mon');
            vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
          
            ---- get the dr_id             
            begin
              select drm.dr_id
                into vc_before_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.period_month = vc_prompt_month
                 and drm.period_year = vc_prompt_year
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_calc_conc_gmr_price',
                                                                     'PHY-002',
                                                                     'DR_ID missing for ' ||
                                                                     cur_gmr_rows.instrument_name ||
                                                                     ',Price Source:' ||
                                                                     cur_gmr_rows.price_source_name ||
                                                                     ' Contract Ref No: ' ||
                                                                     cur_gmr_rows.gmr_ref_no ||
                                                                     ',Price Unit:' ||
                                                                     vc_price_name || ',' ||
                                                                     cur_gmr_rows.available_price_name ||
                                                                     ' Price,Prompt Date:' ||
                                                                     vc_prompt_month || ' ' ||
                                                                     vc_prompt_year,
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
              
            end;
          
          end if;
          --get the price              
          begin
            select dqd.price,
                   dqd.price_unit_id
              into vn_before_qp_price,
                   vc_before_qp_price_unit_id
              from dq_derivative_quotes        dq,
                   dqd_derivative_quote_detail dqd,
                   cdim_corporate_dim          cdim
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_before_price_dr_id
               and dq.process_id = pc_process_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dq.process_id = dqd.process_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = cur_gmr_rows.price_source_id
               and dqd.price_unit_id = vc_price_unit_id
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
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_conc_gmr_price','PHY-002','Price missing for ' || cur_gmr_rows.instrument_name ||',Price Source:' || cur_gmr_rows.price_source_name ||' GMR No: ' || cur_gmr_rows.gmr_ref_no ||',Price Unit:' || vc_price_name ||',' || cur_gmr_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_gmr_rows.is_daily_cal_applicable = 'N' and cur_gmr_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
              sp_insert_error_log(vobj_error_log);
          end;
          vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                          cur_gmr_rows.payable_qty_unit_id,
                                                                          cur_gmr_rows.qty_unit_id,
                                                                          cur_gmr_rows.payable_qty);
          vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_total_quantity *
                                     (vn_qty_to_be_priced / 100) *
                                     vn_before_qp_price;
        
          --- vn_total_contract_value := vn_total_contract_value +vn_before_qp_price;                                   
          --  vc_price_unit_id        := cur_gmr_rows.ppu_price_unit_id;
        elsif vc_period = 'During QP' or vc_period = 'After QP' then
          vd_dur_qp_start_date      := vd_qp_start_date;
          vd_dur_qp_end_date        := vd_qp_end_date;
          vn_during_total_set_price := 0;
          vn_count_set_qp           := 0;
          for cc in (select pfd.user_price,
                            pfd.as_of_date,
                            pfd.qty_fixed,
                            pofh.final_price,
                            pocd.is_any_day_pricing
                       from poch_price_opt_call_off_header poch,
                            pocd_price_option_calloff_dtls pocd,
                            pofh_price_opt_fixation_header pofh,
                            pfd_price_fixation_details     pfd
                      where poch.poch_id = pocd.poch_id
                        and pocd.pocd_id = pofh.pocd_id
                        and pofh.pofh_id = cur_gmr_ele_rows.pofh_id
                        and pofh.pofh_id = pfd.pofh_id
                        and pfd.as_of_date >= vd_dur_qp_start_date
                        and pfd.as_of_date <= pd_trade_date
                        and pofh.qty_to_be_fixed <> 0
                        and poch.is_active = 'Y'
                        and pocd.is_active = 'Y'
                        and pofh.is_active = 'Y'
                        and pfd.is_active = 'Y')
          loop
            vn_during_total_set_price    := vn_during_total_set_price +
                                            cc.user_price;
            vn_count_set_qp              := vn_count_set_qp + 1;
            vn_any_day_price_fix_qty_amt := vn_any_day_price_fix_qty_amt +
                                            (cc.user_price * cc.qty_fixed);
            if cc.final_price is not null then
              vc_price_fixation_status := 'Finalized';
            end if;
            vn_any_day_fixed_qty := vn_any_day_fixed_qty + cc.qty_fixed;
          end loop;
          if vn_count_set_qp <> 0 then
            if vc_price_fixation_status <> 'Finalized' then
              vc_price_fixation_status := 'Partially Priced';
            end if;
          else
            vc_price_fixation_status := 'Un-priced';
          
          end if;
          if cur_gmr_ele_rows.is_any_day_pricing = 'Y' then
            vn_market_flag := 'N';
          else
            vn_market_flag := 'Y';
          end if;
        
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
            -- get the third wednes day
            vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_dur_qp_end_date,
                                                                  'Wed',
                                                                  3);
            while true
            loop
              if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                     vd_3rd_wed_of_qp) then
                vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
              else
                exit;
              end if;
            end loop;
          
            --- get 3rd wednesday  before QP period 
            -- Get the quotation date = Trade Date +2 working Days
            if (vd_3rd_wed_of_qp <= pd_trade_date and
               vc_period = 'During QP') or vc_period = 'After QP' then
              workings_days  := 0;
              vd_quotes_date := pd_trade_date + 1;
              while workings_days <> 2
              loop
                if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
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
            --Get the DR-id
            begin
              select drm.dr_id
                into vc_during_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.prompt_date = vd_3rd_wed_of_qp
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_calc_conc_gmr_price',
                                                                     'PHY-002',
                                                                     'DR-ID missing for ' ||
                                                                     cur_gmr_rows.instrument_name ||
                                                                     ',Price Source:' ||
                                                                     cur_gmr_rows.price_source_name ||
                                                                     ' GMR NO: ' ||
                                                                     cur_gmr_rows.gmr_ref_no ||
                                                                     ',Price Unit:' ||
                                                                     vc_price_name || ',' ||
                                                                     cur_gmr_rows.available_price_name ||
                                                                     ' Price,Prompt Date:' ||
                                                                     vd_3rd_wed_of_qp,
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
            end;
          elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
                cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
            if vc_period = 'During QP' then
              vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                                 vd_qp_end_date);
            else
              vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                                 pd_trade_date);
            
            end if;
            vc_prompt_month := to_char(vc_prompt_date, 'Mon');
            vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
          
            ---- get the dr_id             
            begin
              select drm.dr_id
                into vc_during_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.period_month = vc_prompt_month
                 and drm.period_year = vc_prompt_year
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_calc_conc_gmr_price',
                                                                     'PHY-002',
                                                                     'DR_ID missing for ' ||
                                                                     cur_gmr_rows.instrument_name ||
                                                                     ',Price Source:' ||
                                                                     cur_gmr_rows.price_source_name ||
                                                                     ' Contract Ref No: ' ||
                                                                     cur_gmr_rows.gmr_ref_no ||
                                                                     ',Price Unit:' ||
                                                                     vc_price_name || ',' ||
                                                                     cur_gmr_rows.available_price_name ||
                                                                     ' Price,Prompt Date:' ||
                                                                     vc_prompt_month || ' ' ||
                                                                     vc_prompt_year,
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
              
            end;
          
          end if;
          --Get the price for the price
          begin
            select dqd.price,
                   dqd.price_unit_id
              into vn_during_val_price,
                   vc_during_val_price_unit_id
              from dq_derivative_quotes        dq,
                   dqd_derivative_quote_detail dqd,
                   cdim_corporate_dim          cdim
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_during_price_dr_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dq.dbd_id = dqd.dbd_id
               and dq.dbd_id = pc_dbd_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = cur_gmr_rows.price_source_id
               and dq.trade_date = cdim.valid_quote_date
               and dqd.price_unit_id = vc_price_unit_id
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
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_conc_gmr_price','PHY-002','Price missing for ' || cur_gmr_rows.instrument_name ||',Price Source:' || cur_gmr_rows.price_source_name ||' GMR No: ' || cur_gmr_rows.gmr_ref_no ||',Price Unit:' || vc_price_name ||',' || cur_gmr_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_gmr_rows.is_daily_cal_applicable = 'N' and cur_gmr_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
              sp_insert_error_log(vobj_error_log);
          end;
        
          vn_during_total_val_price := 0;
          vn_count_val_qp           := 0;
          vd_dur_qp_start_date      := pd_trade_date + 1;
          if vn_market_flag = 'N' then
            vn_during_total_val_price := vn_during_total_val_price +
                                         vn_during_val_price;
          
            vn_any_day_unfixed_qty        := cur_gmr_ele_rows.qty_to_be_fixed -
                                             vn_any_day_fixed_qty;
            vn_count_val_qp               := vn_count_val_qp + 1;
            vn_any_day_price_ufix_qty_amt := (vn_any_day_unfixed_qty *
                                             vn_during_total_val_price);
          
          else
            while vd_dur_qp_start_date <= vd_dur_qp_end_date
            loop
              ---- finding holidays       
              if pkg_metals_general.f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                     vd_dur_qp_start_date) then
                vc_holiday := 'Y';
              else
                vc_holiday := 'N';
              end if;
            
              if vc_holiday = 'N' then
                vn_during_total_val_price := vn_during_total_val_price +
                                             vn_during_val_price;
                vn_count_val_qp           := vn_count_val_qp + 1;
              end if;
              vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
            end loop;
          end if;
          if (vn_count_val_qp + vn_count_set_qp) <> 0 then
          
            if vn_market_flag = 'N' then
              vn_during_qp_price := (vn_any_day_price_fix_qty_amt +
                                    vn_any_day_price_ufix_qty_amt) /
                                    cur_gmr_ele_rows.qty_to_be_fixed;
            else
              vn_during_qp_price := (vn_during_total_set_price +
                                    vn_during_total_val_price) /
                                    (vn_count_set_qp + vn_count_val_qp);
            end if;
            vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                            cur_gmr_rows.payable_qty_unit_id,
                                                                            cur_gmr_rows.qty_unit_id,
                                                                            cur_gmr_rows.payable_qty);
            vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_during_qp_price;
          
            -- vn_total_contract_value := vn_total_contract_value +vn_during_qp_price;
          else
            vn_total_contract_value := 0;
          end if;
        
        end if;
      end loop;
      vn_average_price := round(vn_total_contract_value / vn_total_quantity,
                                3);
      begin
        select cm.cur_id,
               cm.cur_code,
               ppu.weight,
               ppu.weight_unit_id,
               qum.qty_unit
          into vc_price_cur_id,
               vc_price_cur_code,
               vc_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_ppu_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      
        pkg_general.sp_get_base_cur_detail(vc_price_cur_id,
                                           vc_price_main_cur_id,
                                           vc_price_main_cur_code,
                                           vn_price_main_cur_factor);
      
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vc_price_weight_unit    := null;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
    
      -- Get the contract base price Unit id
      begin
        select ppu.product_price_unit_id
          into vc_contract_base_price_unit_id
          from v_ppu_pum ppu
         where ppu.weight_unit_id = vc_gmr_ele_base_qty_unit_id
           and ppu.product_id = vc_gmr_ele_product_id
           and ppu.cur_id = vc_base_main_cur_id;
      exception
        when no_data_found then
          vc_contract_base_price_unit_id := null;
      end;
      --
      -- Convert the final price into base price unit ID
      --
      --
      -- Get the Forward Exchange Rate from Price Unit ID to Base Price Unit ID
      --
      if vc_price_cur_id <> vc_base_main_cur_id then
        pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                                pd_trade_date,
                                                pd_trade_date,
                                                vc_price_cur_id,
                                                vc_base_main_cur_id,
                                                30,
                                                vn_fw_exch_rate_price_to_base,
                                                vn_forward_points);
      
        if vc_exch_rate_string is null then
          vc_exch_rate_string := '1 ' || vc_price_cur_code || '=' ||
                                 vn_fw_exch_rate_price_to_base || ' ' ||
                                 vc_base_main_cur_code;
        else
          vc_exch_rate_string := vc_exch_rate_string || ',' || '1 ' ||
                                 vc_price_cur_code || '=' ||
                                 vn_fw_exch_rate_price_to_base || ' ' ||
                                 vc_base_main_cur_code;
        end if;
      else
        vn_fw_exch_rate_price_to_base := 1.0;
      end if;
      vn_price_in_base_price_unit_id := vn_fw_exch_rate_price_to_base *
                                        vn_price_main_cur_factor *
                                        pkg_general.f_get_converted_quantity(vc_gmr_ele_product_id,
                                                                             vc_price_weight_unit_id,
                                                                             vc_gmr_ele_base_qty_unit_id,
                                                                             1) *
                                        vn_average_price;
    
      insert into gpd_gmr_conc_price_daily
        (corporate_id,
         internal_gmr_ref_no,
         element_id,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         process_id,
         price_fixation_status,
         price_basis,
         price_fixation_details,
         price_description,
         exch_rate_string,
         price_in_base_price_unit_id)
      values
        (cur_gmr_rows.corporate_id,
         cur_gmr_rows.internal_gmr_ref_no,
         cur_gmr_rows.element_id,
         vn_average_price,
         vc_ppu_price_unit_id,
         vc_price_cur_id,
         vc_price_cur_code,
         vc_price_weight_unit,
         vc_price_weight_unit_id,
         vc_price_qty_unit,
         pc_process_id,
         vc_price_fixation_status,
         vc_price_basis,
         'Not Applicable',
         vc_price_description,
         vc_exch_rate_string,
         vn_price_in_base_price_unit_id);
      vc_exch_rate_string := null;
    end loop;
    commit;
  end;
  procedure sp_calc_contract_conc_price(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_dbd_id       varchar2,
                                        pc_process      varchar2) is
  
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    cursor cur_pcdi is
      select pcdi.pcdi_id,
             pcdi.internal_contract_ref_no,
             ceqs.element_id,
             ceqs.payable_qty,
             ceqs.payable_qty_unit_id,
             null assay_qty,
             null assay_qty_unit_id,
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
             nvl(pcdi.transit_days, 0) transit_days,
             pcdi.qp_declaration_date,
             pcdi.is_price_optionality_present,
             pcdi.is_phy_optionality_present,
             pci.internal_contract_item_ref_no,
             pcm.contract_ref_no,
             (case
               when nvl(pcdi.payment_due_date, pd_trade_date) <
                    pd_trade_date then
                pd_trade_date
               else
                nvl(pcdi.payment_due_date, pd_trade_date)
             end) payment_due_date,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcm.invoice_currency_id,
             pcpd.qty_unit_id,
             pcpd.product_id,
             aml.underlying_product_id,
             tt.instrument_id,
             akc.base_cur_id,
             akc.base_currency_name,
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
             tt.is_monthly_cal_applicable
      
        from pcdi_pc_delivery_item pcdi,
             --ceqs_contract_ele_qty_status ceqs,
             cpq_contract_payable_qty ceqs,
             pci_physical_contract_item pci,
             pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcpd_pc_product_definition pcpd,
             pcpq_pc_product_quality pcpq,
             aml_attribute_master_list aml,
             dipch_di_payablecontent_header dipch,
             pcpch_pc_payble_content_header pcpch,
             (select qat.internal_contract_item_ref_no,
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
                from ced_contract_exchange_detail qat,
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
       where pcdi.pcdi_id = pci.pcdi_id
         and pci.internal_contract_item_ref_no =
             ceqs.internal_contract_item_ref_no
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcdi.pcdi_id = dipch.pcdi_id
         and dipch.pcpch_id = pcpch.pcpch_id
         and pcpch.element_id = aml.attribute_id
         and nvl(pcpch.payable_type, 'Payable') = 'Payable'
         and pci.pcpq_id = pcpq.pcpq_id
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'CONCENTRATES'
         and pcpd.input_output = 'Input'
            --and pcpd.product_id = qat.conc_product_id
            --and pcpq.quality_template_id = qat.conc_quality_id
         and ceqs.element_id = aml.attribute_id
            --and ceqs.element_id = qat.attribute_id
            --and qat.corporate_id = pc_corporate_id
         and ceqs.internal_contract_item_ref_no =
             tt.internal_contract_item_ref_no(+)
         and ceqs.element_id = tt.element_id(+)
         and pci.item_qty > 0
         and ceqs.payable_qty > 0
         and pcdi.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
            -- and ceqs.process_id = pc_process_id
         and dipch.process_id = pc_process_id
         and pcpch.process_id = pc_process_id
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and dipch.is_active = 'Y'
         and pcpch.is_active = 'Y';
  
    cursor cur_called_off(pc_pcdi_id varchar2, pc_element_id varchar2) is
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
  
    cursor cur_not_called_off(pc_pcdi_id varchar2, pc_element_id varchar2, pc_int_cont_item_ref_no varchar2) is
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
         and pcbpd.element_id = pc_element_id
         and pci.internal_contract_item_ref_no = pc_int_cont_item_ref_no
         and pci.process_id = pc_process_id
         and pcipf.process_id = pc_process_id
         and pcbph.process_id = pc_process_id
         and pcbpd.process_id = pc_process_id
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
  
    vn_contract_price              number;
    vc_price_unit_id               varchar2(15);
    vn_total_quantity              number;
    vn_total_contract_value        number;
    vd_shipment_date               date;
    vd_arrival_date                date;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(20);
    vd_3rd_wed_of_qp               date;
    workings_days                  number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_qty_to_be_priced            number;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vn_any_day_cont_price_fix_qty  number;
    vn_any_day_fixed_qty           number;
    vn_market_flag                 char(1);
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_cont_price_ufix_qty number;
    vc_holiday                     char(10);
    vn_during_qp_price             number;
    vn_average_price               number;
    vc_price_fixation_status       varchar2(50);
    vc_price_basis                 varchar2(15);
    vc_price_description           varchar2(500);
    vc_during_qp_price_unit_id     varchar2(15);
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vc_price_weight_unit           number;
    vc_price_weight_unit_id        varchar2(15);
    vc_price_qty_unit              varchar2(15);
    vc_contract_main_cur_id        varchar2(15);
    vc_contract_main_cur_code      varchar2(15);
    vn_contract_main_cur_factor    number;
    vc_base_main_cur_id            varchar2(15);
    vc_base_main_cur_code          varchar2(15);
    vd_payment_due_date            date;
    vn_fw_exch_rate_price_to_base  number;
    vn_forward_points              number;
    vn_contract_base_price_unit_id varchar2(15);
    vc_price_option_call_off_sts   varchar2(50);
    vc_pcdi_id                     varchar2(15);
    vc_element_id                  varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vc_exch_rate_string            varchar2(300);
    vn_price_in_base_price_unit_id number;
    vd_valid_quote_date            date;
  begin
    delete from cpq_contract_payable_qty cpq
     where cpq.corporate_id = pc_corporate_id;
    commit;
    insert into cpq_contract_payable_qty
      (corporate_id,
       internal_contract_item_ref_no,
       element_id,
       payable_qty,
       payable_qty_unit_id)
      select pc_corporate_id,
             t.internal_contract_item_ref_no,
             t.element_id,
             sum(t.payable_qty) payable_qty,
             t.qty_unit_id payable_qty_unit_id
        from (select pci.internal_contract_item_ref_no,
                     cipq.element_id,
                     cipq.payable_qty,
                     cipq.qty_unit_id,
                     pci.process_id
                from pci_physical_contract_item     pci,
                     pcdi_pc_delivery_item          pcdi,
                     cipq_contract_item_payable_qty cipq
               where pci.pcdi_id = pcdi.pcdi_id
                 and pci.internal_contract_item_ref_no =
                     cipq.internal_contract_item_ref_no
                 and pci.process_id = pcdi.process_id
                 and pcdi.process_id = cipq.process_id
                 and pci.is_active = 'Y'
                 and pcdi.is_active = 'Y'
                 and cipq.is_active = 'Y'
                 and cipq.process_id = pc_process_id
              union all
              select /*+ ordered */
               pci.internal_contract_item_ref_no,
               spq.element_id,
               spq.payable_qty,
               spq.qty_unit_id,
               pci.process_id
                from pci_physical_contract_item pci,
                     pcdi_pc_delivery_item      pcdi,
                     grd_goods_record_detail    grd,
                     spq_stock_payable_qty      spq
               where pci.pcdi_id = pcdi.pcdi_id
                 and pci.internal_contract_item_ref_no =
                     grd.internal_contract_item_ref_no
                    --and spq.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and spq.internal_grd_ref_no = grd.internal_grd_ref_no
                 and pci.process_id = pcdi.process_id
                 and pcdi.process_id = spq.process_id
                 and spq.process_id = grd.process_id
                 and pci.is_active = 'Y'
                 and pcdi.is_active = 'Y'
                 and spq.is_active = 'Y'
                 and grd.process_id = pc_process_id) t
       group by t.internal_contract_item_ref_no,
                t.element_id,
                t.qty_unit_id;
    commit;
    for cur_pcdi_rows in cur_pcdi
    loop
      vc_pcdi_id    := cur_pcdi_rows.pcdi_id;
      vc_element_id := cur_pcdi_rows.element_id;
      begin
        select dipq.price_option_call_off_status
          into vc_price_option_call_off_sts
          from dipq_delivery_item_payable_qty dipq
         where dipq.pcdi_id = vc_pcdi_id
           and dipq.element_id = vc_element_id
           and dipq.is_active = 'Y'
           and dipq.dbd_id = pc_dbd_id;
      exception
        when no_data_found then
          vc_price_option_call_off_sts := null;
      end;
    
      vc_price_fixation_status := null;
      vn_total_contract_value  := 0;
      vd_qp_start_date         := null;
      vd_qp_end_date           := null;
    
      if vc_price_option_call_off_sts in ('Called Off', 'Not Applicable') then
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id,
                                                  cur_pcdi_rows.element_id)
        loop
          vc_price_basis       := cur_called_off_rows.price_basis;
          vc_price_description := cur_called_off_rows.price_description;
          if cur_called_off_rows.price_basis = 'Fixed' then
          
            vn_contract_price        := cur_called_off_rows.price_value;
            vn_total_quantity        := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                             cur_pcdi_rows.payable_qty_unit_id,
                                                                             cur_pcdi_rows.item_qty_unit_id,
                                                                             cur_pcdi_rows.payable_qty);
            vn_qty_to_be_priced      := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value  := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        vn_contract_price;
            vc_price_unit_id         := cur_called_off_rows.price_unit_id;
            vc_price_fixation_status := 'Fixed';
          
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select ppfh.ppfh_id,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id,
                               ppu.price_unit_name,
                               pocd.qp_period_type,
                               pofh.qp_start_date,
                               pofh.qp_end_date,
                               pfqpp.event_name,
                               pfqpp.no_of_event_months,
                               pfqpp.is_qp_any_day_basis,
                               pofh.qty_to_be_fixed,
                               pofh.priced_qty,
                               pofh.pofh_id,
                               pofh.no_of_prompt_days,
                               pofh.avg_price_in_price_in_cur,
                               pofh.final_price,
                               pocd.pay_in_price_unit_id
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail pcbpd,
                               ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing pfqpp,
                               (select *
                                  from pofh_price_opt_fixation_header pfh
                                 where pfh.internal_gmr_ref_no is null
                                   and pfh.is_active = 'Y'
                                   and pfh.qty_to_be_fixed <> 0) pofh,
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
                              -- and pofh.is_active(+) = 'Y'
                           and pcbpd.process_id = pc_process_id
                           and pfqpp.process_id = pc_process_id
                           and ppfh.process_id = pc_process_id)
            
            loop
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
            
              if cc1.qp_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Month' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                  when others then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                end;
              else
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if cc1.qp_period_type = 'Event' then
                vc_price_fixation_status := 'Un-priced';
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                        'Wed',
                                                                        3);
                
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'After QP' then
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       pd_trade_date);
                  
                  else
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       vd_qp_end_date);
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --get the price              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_conc_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'Before QP' then
                vc_price_fixation_status := 'Un-priced';
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                        'Wed',
                                                                        3);
                
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                
                  vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                      vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --get the price              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_conc_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'During QP' or vc_period = 'After QP' then
              
                vd_dur_qp_start_date          := vd_qp_start_date;
                vd_dur_qp_end_date            := vd_qp_end_date;
                vn_during_total_set_price     := 0;
                vn_count_set_qp               := 0;
                vn_any_day_cont_price_fix_qty := 0;
                vn_any_day_fixed_qty          := 0;
              
                for cc in (select pfd.user_price,
                                  pfd.as_of_date,
                                  pfd.qty_fixed,
                                  pofh.final_price
                             from poch_price_opt_call_off_header poch,
                                  pocd_price_option_calloff_dtls pocd,
                                  pofh_price_opt_fixation_header pofh,
                                  pfd_price_fixation_details     pfd
                            where poch.poch_id = pocd.poch_id
                              and pocd.pocd_id = pofh.pocd_id
                              and pofh.pofh_id = cc1.pofh_id
                              and pofh.pofh_id = pfd.pofh_id
                              and pfd.as_of_date >= vd_dur_qp_start_date
                              and pfd.as_of_date <= pd_trade_date
                              and poch.is_active = 'Y'
                              and pocd.is_active = 'Y'
                              and pofh.is_active = 'Y'
                              and pfd.is_active = 'Y'
                              and pofh.qty_to_be_fixed <> 0)
                loop
                  vn_during_total_set_price     := vn_during_total_set_price +
                                                   cc.user_price;
                  vn_any_day_cont_price_fix_qty := vn_any_day_cont_price_fix_qty +
                                                   (cc.user_price *
                                                   cc.qty_fixed);
                  vn_any_day_fixed_qty          := vn_any_day_fixed_qty +
                                                   cc.qty_fixed;
                  vn_count_set_qp               := vn_count_set_qp + 1;
                
                  if cc.final_price is not null then
                    vc_price_fixation_status := 'Finalized';
                  end if;
                end loop;
              
                if vn_count_set_qp <> 0 then
                  if vc_price_fixation_status <> 'Finalized' then
                    vc_price_fixation_status := 'Partially Priced';
                  else
                    vc_price_fixation_status := 'Partially Priced';
                  end if;
                else
                  vc_price_fixation_status := 'Un-priced';
                
                end if;
              
                if cc1.is_qp_any_day_basis = 'Y' then
                  vn_market_flag := 'N';
                else
                  vn_market_flag := 'Y';
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  -- get the third wednes day
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_dur_qp_end_date,
                                                                        'Wed',
                                                                        3);
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if (vd_3rd_wed_of_qp <= pd_trade_date and
                     vc_period = 'During QP') or vc_period = 'After QP' then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  --Get the DR-id
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       vd_qp_end_date);
                  else
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       pd_trade_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --Get the price for the dr-id
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_val_price,
                         vc_during_val_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.dbd_id = dqd.dbd_id
                     and dq.dbd_id = pc_dbd_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                  
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_conc_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
              
                vn_during_total_val_price := 0;
                vn_count_val_qp           := 0;
                vd_dur_qp_start_date      := pd_trade_date + 1;
              
                if vn_market_flag = 'N' then
                  vn_during_total_val_price := vn_during_total_val_price +
                                               vn_during_val_price;
                
                  vn_any_day_unfixed_qty         := cc1.qty_to_be_fixed -
                                                    vn_any_day_fixed_qty;
                  vn_count_val_qp                := vn_count_val_qp + 1;
                  vn_any_day_cont_price_ufix_qty := (vn_any_day_unfixed_qty *
                                                    vn_during_total_val_price);
                  if vn_any_day_unfixed_qty > 0 then
                    vc_price_fixation_status := 'Partially Priced';
                  else
                    vc_price_fixation_status := 'Priced';
                  end if;
                
                else
                
                  while vd_dur_qp_start_date <= vd_dur_qp_end_date
                  loop
                    ---- finding holidays       
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_dur_qp_start_date) then
                      vc_holiday := 'Y';
                    else
                      vc_holiday := 'N';
                    end if;
                  
                    if vc_holiday = 'N' then
                      vn_during_total_val_price := vn_during_total_val_price +
                                                   vn_during_val_price;
                      vn_count_val_qp           := vn_count_val_qp + 1;
                    end if;
                    vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
                  end loop;
                end if;
              
                if (vn_count_val_qp + vn_count_set_qp) <> 0 then
                
                  if vn_market_flag = 'N' then
                    vn_during_qp_price := (vn_any_day_cont_price_fix_qty +
                                          vn_any_day_cont_price_ufix_qty) /
                                          cc1.qty_to_be_fixed;
                  else
                    vn_during_qp_price := (vn_during_total_set_price +
                                          vn_during_total_val_price) /
                                          (vn_count_set_qp +
                                          vn_count_val_qp);
                  end if;
                  vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                  cur_pcdi_rows.payable_qty_unit_id,
                                                                                  cur_pcdi_rows.item_qty_unit_id,
                                                                                  cur_pcdi_rows.payable_qty);
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_during_qp_price;
                  vc_price_unit_id        := cc1.ppu_price_unit_id;
                
                else
                  vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                  cur_pcdi_rows.payable_qty_unit_id,
                                                                                  cur_pcdi_rows.item_qty_unit_id,
                                                                                  cur_pcdi_rows.payable_qty);
                  vn_total_contract_value := 0;
                  vc_price_unit_id        := cc1.ppu_price_unit_id;
                end if;
              
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      
      elsif vc_price_option_call_off_sts = 'Not Called Off' then
      
        vc_price_fixation_status := null;
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.element_id,
                                                          cur_pcdi_rows.internal_contract_item_ref_no)
        loop
          vc_price_basis       := cur_not_called_off_rows.price_basis;
          vc_price_description := cur_not_called_off_rows.price_description;
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price        := cur_not_called_off_rows.price_value;
            vn_total_quantity        := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                             cur_pcdi_rows.payable_qty_unit_id,
                                                                             cur_pcdi_rows.item_qty_unit_id,
                                                                             cur_pcdi_rows.payable_qty);
            vn_qty_to_be_priced      := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value  := vn_total_contract_value +
                                        vn_total_quantity *
                                        (vn_qty_to_be_priced / 100) *
                                        vn_contract_price;
            vc_price_unit_id         := cur_not_called_off_rows.price_unit_id;
            vc_price_fixation_status := 'Fixed';
          
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select pfqpp.qp_pricing_period_type,
                               pfqpp.qp_period_from_date,
                               pfqpp.qp_period_to_date,
                               pfqpp.qp_month,
                               pfqpp.qp_year,
                               pfqpp.qp_date,
                               pfqpp.event_name,
                               pfqpp.no_of_event_months,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id, --pum price unit id, as quoted available in this unit only
                               ppu.price_unit_name
                          from ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing  pfqpp,
                               v_ppu_pum                     ppu
                         where ppfh.ppfh_id = pfqpp.ppfh_id
                           and ppfh.pcbpd_id =
                               cur_not_called_off_rows.pcbpd_id
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id
                           and ppfh.process_id = pc_process_id
                           and pfqpp.process_id = pc_process_id)
            loop
            
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
            
              if cc1.qp_pricing_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              elsif cc1.qp_pricing_period_type = 'Month' then
                vd_qp_start_date := '01-' || cc1.qp_month || '-' ||
                                    cc1.qp_year;
                vd_qp_end_date   := last_day(vd_qp_start_date);
              elsif cc1.qp_pricing_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_date;
                vd_qp_end_date   := cc1.qp_date;
              elsif cc1.qp_pricing_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_not_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                  when others then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                end;
              
              else
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if cc1.qp_pricing_period_type = 'Event' then
              
                vc_price_fixation_status := 'Un-priced';
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  ---- get third wednesday of QP period
                  --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                        'Wed',
                                                                        3);
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  --get the price dr_id   
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'After QP' then
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       pd_trade_date);
                  else
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       vd_qp_end_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                  
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --get the price
              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                  
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_conc_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'Before QP' then
              
                vc_price_fixation_status := 'Un-priced';
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  ---- get third wednesday of QP period
                  --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                        'Wed',
                                                                        3);
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                  --get the price dr_id   
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                
                  vc_prompt_date  := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                      vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                  
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --get the price
              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                  
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_conc_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              
              elsif vc_period = 'During QP' or vc_period = 'After QP' then
                vc_price_fixation_status := 'Un-priced';
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                        'Wed',
                                                                        3);
                  while true
                  loop
                    if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                           vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period 
                  -- Get the quotation date = Trade Date +2 working Days
                  if (vd_3rd_wed_of_qp <= pd_trade_date or
                     vc_period = 'During QP') or vc_period = 'After QP' then
                    workings_days  := 0;
                    vd_quotes_date := pd_trade_date + 1;
                    while workings_days <> 2
                    loop
                      if pkg_metals_general.f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                
                  --get the price dr_id   
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR-ID missing for ' ||
                                                                           cur_pcdi_rows.instrument_name ||
                                                                           ',Price Source:' ||
                                                                           cur_pcdi_rows.price_source_name ||
                                                                           ' Contract Ref No: ' ||
                                                                           cur_pcdi_rows.contract_ref_no ||
                                                                           ',Price Unit:' ||
                                                                           cur_pcdi_rows.price_unit_name || ',' ||
                                                                           cur_pcdi_rows.available_price_name ||
                                                                           ' Price,Prompt Date:' ||
                                                                           vd_3rd_wed_of_qp,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                  end;
                end if;
              
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       vd_qp_end_date);
                  else
                    vc_prompt_date := pkg_metals_general.fn_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                       pd_trade_date);
                  end if;
                
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                
                  ---- get the dr_id             
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vobj_error_log.extend;
                      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                           'procedure sp_calc_contract_conc_price',
                                                                           'PHY-002',
                                                                           'DR_ID missing for ' ||
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
                                                                           vc_prompt_year,
                                                                           '',
                                                                           pc_process,
                                                                           pc_user_id,
                                                                           sysdate,
                                                                           pd_trade_date);
                      sp_insert_error_log(vobj_error_log);
                    
                  end;
                
                end if;
              
                --get the price
              
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_qp_price,
                         vc_during_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         dqd_derivative_quote_detail dqd,
                         cdim_corporate_dim          cdim
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.process_id = pc_process_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dq.process_id = dqd.process_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
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
                    vobj_error_log.extend;
                    vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,'procedure sp_calc_contract_conc_price','PHY-002','Price missing for ' || cur_pcdi_rows.instrument_name ||',Price Source:' || cur_pcdi_rows.price_source_name ||' Contract Ref No: ' || cur_pcdi_rows.contract_ref_no ||',Price Unit:' || cc1.price_unit_name ||',' || cur_pcdi_rows.available_price_name ||' Price,Prompt Date:' || (case when cur_pcdi_rows.is_daily_cal_applicable = 'N' and cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then to_char(vc_prompt_date, 'Mon-yyyy') else to_char(vd_3rd_wed_of_qp, 'dd-Mon-yyyy') end) || ' Trade Date(' || to_char(vd_valid_quote_date, 'dd-Mon-yyyy') || ')', '', pc_process, pc_user_id, sysdate, pd_trade_date);
                    sp_insert_error_log(vobj_error_log);
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_during_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      
      end if;
    
      begin
        select cm.cur_id,
               cm.cur_code,
               ppu.weight,
               ppu.weight_unit_id,
               qum.qty_unit
          into vc_price_cur_id,
               vc_price_cur_code,
               vc_price_weight_unit,
               vc_price_weight_unit_id,
               vc_price_qty_unit
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_price_unit_id
           and ppu.cur_id = cm.cur_id
           and qum.qty_unit_id = ppu.weight_unit_id;
      
        pkg_general.sp_get_base_cur_detail(vc_price_cur_id,
                                           vc_contract_main_cur_id,
                                           vc_contract_main_cur_code,
                                           vn_contract_main_cur_factor);
      
      exception
        when no_data_found then
          vc_price_cur_id         := null;
          vc_price_cur_code       := null;
          vc_price_weight_unit    := null;
          vc_price_weight_unit_id := null;
          vc_price_qty_unit       := null;
      end;
    
      vc_base_main_cur_id   := cur_pcdi_rows.base_cur_id;
      vc_base_main_cur_code := cur_pcdi_rows.base_currency_name;
    
      if cur_pcdi_rows.payment_due_date is null then
        vd_payment_due_date := pd_trade_date;
      else
        vd_payment_due_date := cur_pcdi_rows.payment_due_date;
      end if;
    
      pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                  pd_trade_date,
                                  vd_payment_due_date,
                                  vc_contract_main_cur_id,
                                  vc_base_main_cur_id,
                                  30,
                                  'sp_calc_contract_conc_price Contract Price To Base',
                                  pc_process,
                                  vn_fw_exch_rate_price_to_base,
                                  vn_forward_points);
    
      if vc_contract_main_cur_id <> vc_base_main_cur_id then
        if vn_fw_exch_rate_price_to_base is null or
           vn_fw_exch_rate_price_to_base = 0 then
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure pkg_phy_physical_process contract price',
                                                               'PHY-005',
                                                               vc_base_main_cur_code ||
                                                               ' to ' ||
                                                               vc_contract_main_cur_code || ' (' ||
                                                               to_char(vd_payment_due_date,
                                                                       'dd-Mon-yyyy') || ') ',
                                                               '',
                                                               pc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
        else
        
          if vc_exch_rate_string is null then
            vc_exch_rate_string := '1 ' || vc_contract_main_cur_code || '=' ||
                                   vn_fw_exch_rate_price_to_base || ' ' ||
                                   vc_base_main_cur_code;
          else
            vc_exch_rate_string := vc_exch_rate_string || ',' || '1 ' ||
                                   vc_contract_main_cur_code || '=' ||
                                   vn_fw_exch_rate_price_to_base || ' ' ||
                                   vc_base_main_cur_code;
          end if;
        
        end if;
      else
        vn_fw_exch_rate_price_to_base := 1;
      end if;
      vn_price_in_base_price_unit_id := vn_fw_exch_rate_price_to_base *
                                        vn_contract_main_cur_factor *
                                        pkg_general.f_get_converted_quantity(cur_pcdi_rows.product_id,
                                                                             vc_price_weight_unit_id,
                                                                             cur_pcdi_rows.item_qty_unit_id,
                                                                             1) *
                                        vn_average_price;
    
      insert into cipde_cipd_element_price
        (corporate_id,
         process_id,
         pcdi_id,
         internal_contract_item_ref_no,
         internal_contract_ref_no,
         contract_ref_no,
         delivery_item_no,
         element_id,
         assay_qty,
         assay_qty_unit_id,
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
         price_fixation_status,
         price_fixation_details,
         payment_due_date,
         contract_base_price_unit_id,
         contract_to_base_fx_rate,
         price_description,
         cur_id,
         cur_code,
         instrument_id,
         exch_rate_string,
         price_in_base_price_unit_id)
      values
        (pc_corporate_id,
         pc_process_id,
         cur_pcdi_rows.pcdi_id,
         cur_pcdi_rows.internal_contract_item_ref_no,
         cur_pcdi_rows.internal_contract_ref_no,
         cur_pcdi_rows.contract_ref_no,
         cur_pcdi_rows.delivery_item_no,
         cur_pcdi_rows.element_id,
         cur_pcdi_rows.assay_qty,
         cur_pcdi_rows.assay_qty_unit_id,
         cur_pcdi_rows.payable_qty,
         cur_pcdi_rows.payable_qty_unit_id,
         vn_average_price,
         vc_price_unit_id,
         vc_price_cur_id,
         vc_price_cur_code,
         vc_price_weight_unit,
         vc_price_weight_unit_id,
         vc_price_qty_unit,
         null,
         null,
         vc_price_basis,
         vc_price_fixation_status,
         'Not Applicable',
         cur_pcdi_rows.payment_due_date,
         vn_contract_base_price_unit_id,
         vn_fw_exch_rate_price_to_base,
         vc_price_description,
         null,
         null,
         cur_pcdi_rows.instrument_id,
         vc_exch_rate_string,
         vn_price_in_base_price_unit_id);
      vc_exch_rate_string := null;
    end loop;
    commit;
  end;
end;
/
