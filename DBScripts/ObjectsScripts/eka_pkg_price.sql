create or replace view v_dim_cash_pricepoint_drid as
select t.dr_id,
       t.instrument_id,
       t.price_point_id,
       t.price_point_name,
       t.price_source_id,
       t.price_point_type,
       t.price_source_name,
       t.order_id
  from (select drm.dr_id,
               drm.instrument_id,
               drm.price_point_id,
               pp.price_point_name,
               dip.price_source_id,
               dip.price_point_type,
               ps.price_source_name,
               row_number() over(partition by drm.instrument_id, drm.price_point_id, dip.price_source_id order by drm.instrument_id, drm.price_point_id, dip.price_source_id asc) order_id
          from drm_derivative_master      drm,
               pp_price_point             pp,
               dip_der_instrument_pricing dip,
               ps_price_source            ps
         where drm.price_point_id = pp.price_point_id
           and upper(pp.price_point_name) = 'CASH'
           and drm.is_deleted = 'N'
           and drm.instrument_id = dip.instrument_id
           and dip.is_deleted = 'N'
           and dip.price_point_type = 'PRICE_POINT'
           and dip.price_source_id = ps.price_source_id
           and pp.is_active = 'Y'
           and pp.is_deleted = 'N') t
 where t.order_id = 1
/
create or replace package pkg_price is

  -- Author  : JANARDHANA
  -- Created : 12/8/2011 2:34:26 PM
  -- Purpose : Online Price Calculation for Contracts and GMRs
  procedure sp_calc_contract_price(pc_int_contract_item_ref_no varchar2,
                                   pd_trade_date               date,
                                   pn_price                    out number,
                                   pc_price_unit_id            out varchar2);

  procedure sp_calc_gmr_price(pc_internal_gmr_ref_no varchar2,
                              pd_trade_date          date,
                              pn_price               out number,
                              pc_price_unit_id       out varchar2);

  procedure sp_calc_contract_conc_price(pc_int_contract_item_ref_no varchar2,
                                        pc_element_id               varchar2,
                                        pd_trade_date               date,
                                        pn_price                    out number,
                                        pc_price_unit_id            out varchar2);

  procedure sp_calc_conc_gmr_price(pc_internal_gmr_ref_no varchar2,
                                   pc_element_id          varchar2,
                                   pd_trade_date          date,
                                   pn_price               out number,
                                   pc_price_unit_id       out varchar2);

  function f_get_next_day(pd_date     in date,
                          pc_day      in varchar2,
                          pn_position in number) return date;

  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean;

  function f_get_next_month_prompt_date(pc_promp_del_cal_id varchar2,
                                        pd_trade_date       date) return date;

end;
/
create or replace package body "PKG_PRICE" is

  procedure sp_calc_contract_price(pc_int_contract_item_ref_no varchar2,
                                   pd_trade_date               date,
                                   pn_price                    out number,
                                   pc_price_unit_id            out varchar2) is
    cursor cur_pcdi is
      select pcdi.pcdi_id,
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
             pcdi.price_option_call_off_status,
             pci.internal_contract_item_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpd.qty_unit_id,
             pcpd.product_id,
             qat.instrument_id,
             ps.price_source_id,
             apm.available_price_id,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable,
             akc.corporate_id
        from pcdi_pc_delivery_item        pcdi,
             pci_physical_contract_item   pci,
             pcm_physical_contract_main   pcm,
             ak_corporate                 akc,
             pcpd_pc_product_definition   pcpd,
             pcpq_pc_product_quality      pcpq,
             v_contract_exchange_detail   qat,
             dim_der_instrument_master    dim,
             div_der_instrument_valuation div,
             ps_price_source              ps,
             apm_available_price_master   apm,
             pum_price_unit_master        pum,
             v_der_instrument_price_unit  vdip,
             pdc_prompt_delivery_calendar pdc
       where pcdi.pcdi_id = pci.pcdi_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'BASEMETAL'
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
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pci.internal_contract_item_ref_no =
             pc_int_contract_item_ref_no;
    cursor cur_called_off(pc_pcdi_id varchar2) is
      select poch.poch_id,
             poch.internal_action_ref_no,
             pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where poch.pcdi_id = pc_pcdi_id
         and poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
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
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced
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
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    vn_contract_price              number;
    vc_price_unit_id               varchar2(15);
    vn_total_quantity              number;
    vn_qty_to_be_priced            number;
    vn_total_contract_value        number;
    vn_average_price               number;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(15);
    vd_shipment_date               date;
    vd_arrival_date                date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vd_3rd_wed_of_qp               date;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_set_price      number;
    vn_during_total_val_price      number;
    vn_count_set_qp                number;
    vn_count_val_qp                number;
    vn_workings_days               number;
    vd_quotes_date                 date;
    vn_during_qp_price             number;
    vc_during_price_dr_id          varchar2(15);
    vc_during_qp_price_unit_id     varchar2(15);
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_value number;
    vn_anyday_price_ufix_qty_value number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vn_no_of_trading_days          number;
  begin
    for cur_pcdi_rows in cur_pcdi
    loop
      vn_total_contract_value := 0;
      if cur_pcdi_rows.price_option_call_off_status in
         ('Called Off', 'Not Applicable') then
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id)
        loop
          if cur_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_called_off_rows.price_value;
            vn_total_quantity       := cur_pcdi_rows.item_qty;
            vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_called_off_rows.price_unit_id;
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select ppfh.ppfh_id,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id,
                               pocd.qp_period_type,
                               pofh.qp_start_date,
                               pofh.qp_end_date,
                               pfqpp.is_qp_any_day_basis,
                               -- pofh.qty_to_be_fixed,
                               (case
                                 when pocd.qp_period_type = 'Event' then
                                  cur_pcdi_rows.item_qty
                                 else
                                  pofh.qty_to_be_fixed
                               end) qty_to_be_fixed,
                               pofh.priced_qty,
                               pofh.pofh_id,
                               pofh.no_of_prompt_days
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail     pcbpd,
                               ppfh_phy_price_formula_header  ppfh,
                               pfqpp_phy_formula_qp_pricing   pfqpp,
                               pofh_price_opt_fixation_header pofh,
                               v_ppu_pum                      ppu
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
                        )
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
              if vc_period = 'Before QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
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
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
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
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif (vc_period = 'During QP' or vc_period = 'After QP') then
                vd_dur_qp_start_date           := vd_qp_start_date;
                vd_dur_qp_end_date             := vd_qp_end_date;
                vn_during_total_set_price      := 0;
                vn_count_set_qp                := 0;
                vn_any_day_price_fix_qty_value := 0;
                vn_any_day_fixed_qty           := 0;
                for cc in (select pfd.user_price,
                                  pfd.qty_fixed
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
                              and nvl(pfd.is_hedge_correction, 'N') = 'N'
                              and nvl(pfd.user_price, 0) <> 0
                              and pfd.is_active = 'Y')
                loop
                  vn_during_total_set_price      := vn_during_total_set_price +
                                                    cc.user_price;
                  vn_any_day_price_fix_qty_value := vn_any_day_price_fix_qty_value +
                                                    (cc.user_price *
                                                    cc.qty_fixed);
                  vn_any_day_fixed_qty           := vn_any_day_fixed_qty +
                                                    cc.qty_fixed;
                  vn_count_set_qp                := vn_count_set_qp + 1;
                end loop;
                if cc1.is_qp_any_day_basis = 'Y' then
                  vn_market_flag := 'N';
                else
                  vn_market_flag := 'Y';
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
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
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   vd_qp_end_date);
                  elsif vc_period = 'After QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   pd_trade_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
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
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  begin
                    select dqd.dr_id,
                           dqd.price,
                           dqd.price_unit_id
                      into vc_during_price_dr_id,
                           vn_during_val_price,
                           vc_during_val_price_unit_id
                      from dq_derivative_quotes        dq,
                           dqd_derivative_quote_detail dqd,
                           v_dim_cash_pricepoint_drid  drm
                     where dq.dq_id = dqd.dq_id
                       and dq.instrument_id = cur_pcdi_rows.instrument_id
                       and dq.instrument_id = drm.instrument_id
                       and drm.dr_id = dqd.dr_id
                       and dqd.available_price_id =
                           cur_pcdi_rows.available_price_id
                       and dq.price_source_id = drm.price_source_id
                       and dqd.price_unit_id = cc1.price_unit_id
                       and dq.corporate_id = cur_pcdi_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date =
                           (select max(dq.trade_date)
                              from dq_derivative_quotes        dq,
                                   dqd_derivative_quote_detail dqd
                             where dq.dq_id = dqd.dq_id
                               and dqd.dr_id = drm.dr_id
                               and dq.instrument_id =
                                   cur_pcdi_rows.instrument_id
                               and dqd.available_price_id =
                                   cur_pcdi_rows.available_price_id
                               and dq.price_source_id = drm.price_source_id
                               and dqd.price_unit_id = cc1.price_unit_id
                               and dq.corporate_id =
                                   cur_pcdi_rows.corporate_id
                               and dq.is_deleted = 'N'
                               and dqd.is_deleted = 'N'
                               and dq.trade_date <= pd_trade_date);
                  exception
                    when no_data_found then
                      vn_during_val_price         := 0;
                      vc_during_val_price_unit_id := null;
                  end;
                else
                  begin
                    select dqd.price,
                           dqd.price_unit_id
                      into vn_during_val_price,
                           vc_during_val_price_unit_id
                      from dq_derivative_quotes          dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_during_price_dr_id
                       and dq.instrument_id = cur_pcdi_rows.instrument_id
                       and dqd.available_price_id =
                           cur_pcdi_rows.available_price_id
                       and dq.price_source_id =
                           cur_pcdi_rows.price_source_id
                       and dqd.price_unit_id = cc1.price_unit_id
                       and dq.corporate_id = cur_pcdi_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date =
                           (select max(dq.trade_date)
                              from dq_derivative_quotes          dq,
                                   v_dqd_derivative_quote_detail dqd
                             where dq.dq_id = dqd.dq_id
                               and dqd.dr_id = vc_during_price_dr_id
                               and dq.instrument_id =
                                   cur_pcdi_rows.instrument_id
                               and dqd.available_price_id =
                                   cur_pcdi_rows.available_price_id
                               and dq.price_source_id =
                                   cur_pcdi_rows.price_source_id
                               and dqd.price_unit_id = cc1.price_unit_id
                               and dq.corporate_id =
                                   cur_pcdi_rows.corporate_id
                               and dq.is_deleted = 'N'
                               and dqd.is_deleted = 'N'
                               and dq.trade_date <= pd_trade_date);
                  exception
                    when no_data_found then
                      vn_during_val_price         := 0;
                      vc_during_val_price_unit_id := null;
                  end;
                end if;
                vn_during_total_val_price := 0;
                vn_count_val_qp           := 0;
                vd_dur_qp_start_date      := pd_trade_date + 1;
                if vn_market_flag = 'N' then
                  vn_during_total_val_price      := vn_during_total_val_price +
                                                    vn_during_val_price;
                  vn_any_day_unfixed_qty         := cc1.qty_to_be_fixed -
                                                    vn_any_day_fixed_qty;
                  vn_count_val_qp                := vn_count_val_qp + 1;
                  vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                                    vn_during_total_val_price);
                else
                  vn_no_of_trading_days := pkg_general.f_get_instrument_trading_days(cur_pcdi_rows.instrument_id,
                                                                                     vd_qp_start_date,
                                                                                     vd_qp_end_date);
                
                  vn_count_val_qp           := vn_no_of_trading_days -
                                               vn_count_set_qp;
                  vn_during_total_val_price := vn_during_total_val_price +
                                               vn_during_val_price *
                                               vn_count_val_qp;
                
                end if;
                if (vn_count_val_qp + vn_count_set_qp) <> 0 then
                  if vn_market_flag = 'N' then
                    vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                          vn_anyday_price_ufix_qty_value) /
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
                else
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                  vn_total_contract_value := 0;
                end if;
                vc_price_unit_id := cc1.ppu_price_unit_id;
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      elsif cur_pcdi_rows.price_option_call_off_status = 'Not Called Off' then
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.internal_contract_item_ref_no)
        loop
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_not_called_off_rows.price_value;
            vn_total_quantity       := cur_pcdi_rows.item_qty;
            vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_not_called_off_rows.price_unit_id;
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select pfqpp.qp_pricing_period_type,
                               pfqpp.qp_period_from_date,
                               pfqpp.qp_period_to_date,
                               pfqpp.qp_month,
                               pfqpp.qp_year,
                               pfqpp.qp_date,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id --pum price unit id, as quoted available in this unit only
                          from ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing  pfqpp,
                               v_ppu_pum                     ppu
                         where ppfh.ppfh_id = pfqpp.ppfh_id
                           and ppfh.pcbpd_id =
                               cur_not_called_off_rows.pcbpd_id
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id)
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
              if vc_period = 'Before QP' then
                ---- get third wednesday of QP period
                --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
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
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
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
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif (vc_period = 'During QP' or vc_period = 'After QP') then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
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
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   vd_qp_end_date);
                  elsif vc_period = 'After QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   pd_trade_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
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
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  begin
                    select dqd.dr_id,
                           dqd.price,
                           dqd.price_unit_id
                      into vc_during_price_dr_id,
                           vn_during_qp_price,
                           vc_during_qp_price_unit_id
                      from dq_derivative_quotes        dq,
                           dqd_derivative_quote_detail dqd,
                           v_dim_cash_pricepoint_drid  drm
                     where dq.dq_id = dqd.dq_id
                       and dq.instrument_id = cur_pcdi_rows.instrument_id
                       and dq.instrument_id = drm.instrument_id
                       and drm.dr_id = dqd.dr_id
                       and dqd.available_price_id =
                           cur_pcdi_rows.available_price_id
                       and dq.price_source_id = drm.price_source_id
                       and dqd.price_unit_id = cc1.price_unit_id
                       and dq.corporate_id = cur_pcdi_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date =
                           (select max(dq.trade_date)
                              from dq_derivative_quotes        dq,
                                   dqd_derivative_quote_detail dqd
                             where dq.dq_id = dqd.dq_id
                               and dqd.dr_id = drm.dr_id
                               and dq.instrument_id =
                                   cur_pcdi_rows.instrument_id
                               and dqd.available_price_id =
                                   cur_pcdi_rows.available_price_id
                               and dq.price_source_id = drm.price_source_id
                               and dqd.price_unit_id = cc1.price_unit_id
                               and dq.corporate_id =
                                   cur_pcdi_rows.corporate_id
                               and dq.is_deleted = 'N'
                               and dqd.is_deleted = 'N'
                               and dq.trade_date <= pd_trade_date);
                  exception
                    when no_data_found then
                      vn_during_qp_price         := 0;
                      vc_during_qp_price_unit_id := null;
                  end;
                else
                  begin
                    select dqd.price,
                           dqd.price_unit_id
                      into vn_during_qp_price,
                           vc_during_qp_price_unit_id
                      from dq_derivative_quotes          dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_during_price_dr_id
                       and dq.instrument_id = cur_pcdi_rows.instrument_id
                       and dqd.available_price_id =
                           cur_pcdi_rows.available_price_id
                       and dq.price_source_id =
                           cur_pcdi_rows.price_source_id
                       and dqd.price_unit_id = cc1.price_unit_id
                       and dq.corporate_id = cur_pcdi_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date =
                           (select max(dq.trade_date)
                              from dq_derivative_quotes          dq,
                                   v_dqd_derivative_quote_detail dqd
                             where dq.dq_id = dqd.dq_id
                               and dqd.dr_id = vc_during_price_dr_id
                               and dq.instrument_id =
                                   cur_pcdi_rows.instrument_id
                               and dqd.available_price_id =
                                   cur_pcdi_rows.available_price_id
                               and dq.price_source_id =
                                   cur_pcdi_rows.price_source_id
                               and dqd.price_unit_id = cc1.price_unit_id
                               and dq.corporate_id =
                                   cur_pcdi_rows.corporate_id
                               and dq.is_deleted = 'N'
                               and dqd.is_deleted = 'N'
                               and dq.trade_date <= pd_trade_date);
                  exception
                    when no_data_found then
                      vn_during_qp_price         := 0;
                      vc_during_qp_price_unit_id := null;
                  end;
                end if;
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
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_price_unit_id;
  end;

  procedure sp_calc_gmr_price(pc_internal_gmr_ref_no varchar2,
                              pd_trade_date          date,
                              pn_price               out number,
                              pc_price_unit_id       out varchar2) is
    cursor cur_gmr is
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.pofh_id,
             pd_trade_date eod_trade_date,
             qat.instrument_id,
             ps.price_source_id,
             apm.available_price_id,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             pocd.is_any_day_pricing,
             pofh.qty_to_be_fixed,
             round(pofh.priced_qty, 4) priced_qty,
             pofh.no_of_prompt_days,
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from grd_goods_record_detail grd
               where grd.status = 'Active'
                 and grd.is_deleted = 'N'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             v_gmr_exchange_details qat,
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
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.pofh_id,
             pd_trade_date eod_trade_date,
             qat.instrument_id,
             ps.price_source_id,
             apm.available_price_id,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             pocd.is_any_day_pricing,
             pofh.qty_to_be_fixed,
             round(pofh.priced_qty, 4) priced_qty,
             pofh.no_of_prompt_days,
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from dgrd_delivered_grd grd
               where grd.status = 'Active'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             v_gmr_exchange_details qat,
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
    vn_during_qp_price             number;
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_value number;
    vn_anyday_price_ufix_qty_value number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_price_unit_id               varchar2(15);
    vc_ppu_price_unit_id           varchar2(15);
    vc_pcbpd_id                    varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
  begin
    for cur_gmr_rows in cur_gmr
    loop
      vn_total_contract_value        := 0;
      vn_market_flag                 := null;
      vn_any_day_price_fix_qty_value := 0;
      vn_anyday_price_ufix_qty_value := 0;
      vn_any_day_unfixed_qty         := 0;
      vn_any_day_fixed_qty           := 0;
      vc_pcbpd_id                    := cur_gmr_rows.pcbpd_id;
      vc_price_unit_id               := null;
      vc_ppu_price_unit_id           := null;
      vd_qp_start_date               := cur_gmr_rows.qp_start_date;
      vd_qp_end_date                 := cur_gmr_rows.qp_end_date;
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
               ppu.price_unit_id
          into vc_ppu_price_unit_id,
               vc_price_unit_id
          from ppfh_phy_price_formula_header ppfh,
               v_ppu_pum                     ppu
         where ppfh.pcbpd_id = vc_pcbpd_id
           and ppfh.price_unit_id = ppu.product_price_unit_id
           and rownum <= 1;
      exception
        when no_data_found then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
        when others then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
      end;
      if vc_period = 'Before QP' then
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date, 'Wed', 3);
          while true
          loop
            if f_is_day_holiday(cur_gmr_rows.instrument_id,
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
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
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
              vc_before_price_dr_id := null;
          end;
        elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
              cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
          vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                          vd_qp_end_date);
          vc_prompt_month := to_char(vc_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
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
              vc_before_price_dr_id := null;
          end;
        end if;
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_before_qp_price,
                 vc_before_qp_price_unit_id
            from dq_derivative_quotes          dq,
                 v_dqd_derivative_quote_detail dqd
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_before_price_dr_id
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dqd.price_unit_id = vc_price_unit_id
             and dq.corporate_id = cur_gmr_rows.corporate_id
             and dq.is_deleted = 'N'
             and dqd.is_deleted = 'N'
             and dq.trade_date =
                 (select max(dq.trade_date)
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_gmr_rows.instrument_id
                     and dqd.available_price_id =
                         cur_gmr_rows.available_price_id
                     and dq.price_source_id = cur_gmr_rows.price_source_id
                     and dqd.price_unit_id = vc_price_unit_id
                     and dq.corporate_id = cur_gmr_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date <= pd_trade_date);
        exception
          when no_data_found then
            vn_before_qp_price         := 0;
            vc_before_qp_price_unit_id := null;
        end;
        vn_total_contract_value := vn_total_contract_value +
                                   vn_before_qp_price;
      elsif (vc_period = 'During QP' or vc_period = 'After QP') then
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
                      and pofh.pofh_id = cur_gmr_rows.pofh_id
                      and pofh.pofh_id = pfd.pofh_id
                      and pfd.as_of_date >= vd_dur_qp_start_date
                      and pfd.as_of_date <= pd_trade_date
                      and poch.is_active = 'Y'
                      and pocd.is_active = 'Y'
                      and pofh.is_active = 'Y'
                      and nvl(pfd.is_hedge_correction, 'N') = 'N'
                      and nvl(pfd.user_price, 0) <> 0
                      and pfd.is_active = 'Y')
        loop
          vn_during_total_set_price      := vn_during_total_set_price +
                                            cc.user_price;
          vn_count_set_qp                := vn_count_set_qp + 1;
          vn_any_day_fixed_qty           := vn_any_day_fixed_qty +
                                            cc.qty_fixed;
          vn_any_day_price_fix_qty_value := vn_any_day_price_fix_qty_value +
                                            (cc.user_price * cc.qty_fixed);
        end loop;
        if cur_gmr_rows.is_any_day_pricing = 'Y' then
          vn_market_flag := 'N';
        else
          vn_market_flag := 'Y';
        end if;
        -- get the third wednes day
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date, 'Wed', 3);
          while true
          loop
            if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                vd_3rd_wed_of_qp) then
              vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
            else
              exit;
            end if;
          end loop;
          --- get 3rd wednesday  before QP period
          -- Get the quotation date = Trade Date +2 working Days
          if (vd_3rd_wed_of_qp <= pd_trade_date and vc_period = 'During QP') or
             vc_period = 'After QP' then
            workings_days  := 0;
            vd_quotes_date := pd_trade_date + 1;
            while workings_days <> 2
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
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
              vc_during_price_dr_id := null;
          end;
        elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
              cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
          if vc_period = 'During QP' then
            vc_prompt_date := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                           vd_qp_end_date);
          elsif vc_period = 'After QP' then
            vc_prompt_date := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                           pd_trade_date);
          end if;
          vc_prompt_month := to_char(vc_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
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
              vc_during_price_dr_id := null;
          end;
        end if;
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          begin
            select dqd.dr_id,
                   dqd.price,
                   dqd.price_unit_id
              into vc_during_price_dr_id,
                   vn_during_val_price,
                   vc_during_val_price_unit_id
              from dq_derivative_quotes        dq,
                   dqd_derivative_quote_detail dqd,
                   v_dim_cash_pricepoint_drid  drm
             where dq.dq_id = dqd.dq_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dq.instrument_id = drm.instrument_id
               and drm.dr_id = dqd.dr_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = drm.price_source_id
               and dqd.price_unit_id = vc_price_unit_id
               and dq.corporate_id = cur_gmr_rows.corporate_id
               and dq.is_deleted = 'N'
               and dqd.is_deleted = 'N'
               and dq.trade_date =
                   (select max(dq.trade_date)
                      from dq_derivative_quotes        dq,
                           dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = drm.dr_id
                       and dq.instrument_id = cur_gmr_rows.instrument_id
                       and dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                       and dq.price_source_id = drm.price_source_id
                       and dqd.price_unit_id = vc_price_unit_id
                       and dq.corporate_id = cur_gmr_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date <= pd_trade_date);
          exception
            when no_data_found then
              vn_during_val_price         := 0;
              vc_during_val_price_unit_id := null;
          end;
        else
          begin
            select dqd.price,
                   dqd.price_unit_id
              into vn_during_val_price,
                   vc_during_val_price_unit_id
              from dq_derivative_quotes          dq,
                   v_dqd_derivative_quote_detail dqd
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_during_price_dr_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = cur_gmr_rows.price_source_id
               and dqd.price_unit_id = vc_price_unit_id
               and dq.corporate_id = cur_gmr_rows.corporate_id
               and dq.is_deleted = 'N'
               and dqd.is_deleted = 'N'
               and dq.trade_date =
                   (select max(dq.trade_date)
                      from dq_derivative_quotes          dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_during_price_dr_id
                       and dq.instrument_id = cur_gmr_rows.instrument_id
                       and dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                       and dq.price_source_id = cur_gmr_rows.price_source_id
                       and dqd.price_unit_id = vc_price_unit_id
                       and dq.corporate_id = cur_gmr_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date <= pd_trade_date);
          exception
            when no_data_found then
              vn_during_val_price         := 0;
              vc_during_val_price_unit_id := null;
          end;
        end if;
        vn_during_total_val_price := 0;
        vn_count_val_qp           := 0;
        vd_dur_qp_start_date      := pd_trade_date + 1;
        if vn_market_flag = 'N' then
          vn_during_total_val_price      := vn_during_total_val_price +
                                            vn_during_val_price;
          vn_any_day_unfixed_qty         := cur_gmr_rows.qty_to_be_fixed -
                                            vn_any_day_fixed_qty;
          vn_count_val_qp                := vn_count_val_qp + 1;
          vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                            vn_during_total_val_price);
        else
          vn_count_val_qp           := cur_gmr_rows.no_of_prompt_days -
                                       vn_count_set_qp;
          vn_during_total_val_price := vn_during_total_val_price +
                                       vn_during_val_price *
                                       vn_count_val_qp;
        
        end if;
        if (vn_count_val_qp + vn_count_set_qp) <> 0 then
          if vn_market_flag = 'N' then
            vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                  vn_anyday_price_ufix_qty_value) /
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
    end loop;
    pn_price         := vn_total_contract_value;
    pc_price_unit_id := vc_ppu_price_unit_id;
  end;

  procedure sp_calc_contract_conc_price(pc_int_contract_item_ref_no varchar2,
                                        pc_element_id               varchar2,
                                        pd_trade_date               date,
                                        pn_price                    out number,
                                        pc_price_unit_id            out varchar2) is
    cursor cur_pcdi is
      select pcdi.pcdi_id,
             pcm.corporate_id,
             pcdi.internal_contract_ref_no,
             ceqs.element_id,
             ceqs.payable_qty,
             ceqs.payable_qty_unit_id,
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
             pci.internal_contract_item_ref_no,
             pcm.contract_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpd.qty_unit_id,
             pcpd.product_id,
             aml.underlying_product_id,
             tt.instrument_id,
             akc.base_cur_id,
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
             v_contract_payable_qty ceqs,
             pci_physical_contract_item pci,
             pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcpd_pc_product_definition pcpd,
             pcpq_pc_product_quality pcpq,
             aml_attribute_master_list aml,
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
                from v_contract_exchange_detail   qat,
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
       where pcdi.pcdi_id = pci.pcdi_id
         and pci.internal_contract_item_ref_no =
             ceqs.internal_contract_item_ref_no
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'CONCENTRATES'
         and ceqs.element_id = aml.attribute_id
         and ceqs.internal_contract_item_ref_no =
             tt.internal_contract_item_ref_no(+)
         and ceqs.element_id = tt.element_id(+)
         and pci.item_qty > 0
         and ceqs.payable_qty > 0
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pci.internal_contract_item_ref_no =
             pc_int_contract_item_ref_no
         and ceqs.element_id = pc_element_id
         and pcpd.input_output = 'Input';
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
    vn_workings_days               number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_qty_to_be_priced            number;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vn_any_day_price_fix_qty_value number;
    vn_any_day_fixed_qty           number;
    vn_market_flag                 char(1);
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vn_any_day_unfixed_qty         number;
    vn_anyday_price_ufix_qty_value number;
    vn_during_qp_price             number;
    vn_average_price               number;
    vc_during_qp_price_unit_id     varchar2(15);
    vc_price_option_call_off_sts   varchar2(50);
    vc_pcdi_id                     varchar2(15);
    vc_element_id                  varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vn_no_of_trading_days          number;
  begin
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
           and dipq.is_active = 'Y';
      exception
        when no_data_found then
          vc_price_option_call_off_sts := null;
      end;
      vn_total_contract_value := 0;
      vd_qp_start_date        := null;
      vd_qp_end_date          := null;
      if vc_price_option_call_off_sts in ('Called Off', 'Not Applicable') then
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id,
                                                  cur_pcdi_rows.element_id)
        loop
          if cur_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_called_off_rows.price_value;
            vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                            cur_pcdi_rows.payable_qty_unit_id,
                                                                            cur_pcdi_rows.item_qty_unit_id,
                                                                            cur_pcdi_rows.payable_qty);
            vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_called_off_rows.price_unit_id;
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select ppfh.ppfh_id,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id,
                               pocd.qp_period_type,
                               pofh.qp_start_date,
                               pofh.qp_end_date,
                               pfqpp.event_name,
                               pfqpp.no_of_event_months,
                               pfqpp.is_qp_any_day_basis,
                               -- pofh.qty_to_be_fixed,
                               (case
                                 when pocd.qp_period_type = 'Event' then
                                  cur_pcdi_rows.item_qty
                                 else
                                  pofh.qty_to_be_fixed
                               end) qty_to_be_fixed,
                               pofh.priced_qty,
                               pofh.pofh_id,
                               pofh.no_of_prompt_days
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail     pcbpd,
                               ppfh_phy_price_formula_header  ppfh,
                               pfqpp_phy_formula_qp_pricing   pfqpp,
                               pofh_price_opt_fixation_header pofh,
                               v_ppu_pum                      ppu
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
                        )
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
              if vc_period = 'Before QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
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
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
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
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
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
              elsif (vc_period = 'During QP' or vc_period = 'After QP') then
                vd_dur_qp_start_date           := vd_qp_start_date;
                vd_dur_qp_end_date             := vd_qp_end_date;
                vn_during_total_set_price      := 0;
                vn_count_set_qp                := 0;
                vn_any_day_price_fix_qty_value := 0;
                vn_any_day_fixed_qty           := 0;
                for cc in (select pfd.user_price,
                                  pfd.as_of_date,
                                  pfd.qty_fixed
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
                              and nvl(pfd.is_hedge_correction, 'N') = 'N'
                              and nvl(pfd.user_price, 0) <> 0
                              and pfd.is_active = 'Y')
                loop
                  vn_during_total_set_price      := vn_during_total_set_price +
                                                    cc.user_price;
                  vn_any_day_price_fix_qty_value := vn_any_day_price_fix_qty_value +
                                                    (cc.user_price *
                                                    cc.qty_fixed);
                  vn_any_day_fixed_qty           := vn_any_day_fixed_qty +
                                                    cc.qty_fixed;
                  vn_count_set_qp                := vn_count_set_qp + 1;
                end loop;
                if cc1.is_qp_any_day_basis = 'Y' then
                  vn_market_flag := 'N';
                else
                  vn_market_flag := 'Y';
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  -- get the third wednes day
                  vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
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
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   vd_qp_end_date);
                  elsif vc_period = 'After QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   pd_trade_date);
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
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
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  begin
                    select dqd.dr_id,
                           dqd.price,
                           dqd.price_unit_id
                      into vc_during_price_dr_id,
                           vn_during_val_price,
                           vc_during_val_price_unit_id
                      from dq_derivative_quotes        dq,
                           dqd_derivative_quote_detail dqd,
                           v_dim_cash_pricepoint_drid  drm
                     where dq.dq_id = dqd.dq_id
                       and dq.instrument_id = cur_pcdi_rows.instrument_id
                       and dq.instrument_id = drm.instrument_id
                       and drm.dr_id = dqd.dr_id
                       and dqd.available_price_id =
                           cur_pcdi_rows.available_price_id
                       and dq.price_source_id = drm.price_source_id
                       and dqd.price_unit_id = cc1.price_unit_id
                       and dq.corporate_id = cur_pcdi_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date =
                           (select max(dq.trade_date)
                              from dq_derivative_quotes        dq,
                                   dqd_derivative_quote_detail dqd
                             where dq.dq_id = dqd.dq_id
                               and dqd.dr_id = drm.dr_id
                               and dq.instrument_id =
                                   cur_pcdi_rows.instrument_id
                               and dqd.available_price_id =
                                   cur_pcdi_rows.available_price_id
                               and dq.price_source_id = drm.price_source_id
                               and dqd.price_unit_id = cc1.price_unit_id
                               and dq.corporate_id =
                                   cur_pcdi_rows.corporate_id
                               and dq.is_deleted = 'N'
                               and dqd.is_deleted = 'N'
                               and dq.trade_date <= pd_trade_date);
                  exception
                    when no_data_found then
                      vn_during_val_price         := 0;
                      vc_during_val_price_unit_id := null;
                  end;
                else
                  begin
                    select dqd.price,
                           dqd.price_unit_id
                      into vn_during_val_price,
                           vc_during_val_price_unit_id
                      from dq_derivative_quotes          dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_during_price_dr_id
                       and dq.instrument_id = cur_pcdi_rows.instrument_id
                       and dqd.available_price_id =
                           cur_pcdi_rows.available_price_id
                       and dq.price_source_id =
                           cur_pcdi_rows.price_source_id
                       and dqd.price_unit_id = cc1.price_unit_id
                       and dq.corporate_id = cur_pcdi_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date =
                           (select max(dq.trade_date)
                              from dq_derivative_quotes          dq,
                                   v_dqd_derivative_quote_detail dqd
                             where dq.dq_id = dqd.dq_id
                               and dqd.dr_id = vc_during_price_dr_id
                               and dq.instrument_id =
                                   cur_pcdi_rows.instrument_id
                               and dqd.available_price_id =
                                   cur_pcdi_rows.available_price_id
                               and dq.price_source_id =
                                   cur_pcdi_rows.price_source_id
                               and dqd.price_unit_id = cc1.price_unit_id
                               and dq.corporate_id =
                                   cur_pcdi_rows.corporate_id
                               and dq.is_deleted = 'N'
                               and dqd.is_deleted = 'N'
                               and dq.trade_date <= pd_trade_date);
                  exception
                    when no_data_found then
                      vn_during_val_price         := 0;
                      vc_during_val_price_unit_id := null;
                  end;
                end if;
                vn_during_total_val_price := 0;
                vn_count_val_qp           := 0;
                vd_dur_qp_start_date      := pd_trade_date + 1;
                if vn_market_flag = 'N' then
                  vn_during_total_val_price      := vn_during_total_val_price +
                                                    vn_during_val_price;
                  vn_any_day_unfixed_qty         := nvl(cc1.qty_to_be_fixed,
                                                        0) -
                                                    vn_any_day_fixed_qty;
                  vn_count_val_qp                := vn_count_val_qp + 1;
                  vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                                    vn_during_total_val_price);
                else
                  vn_no_of_trading_days     := pkg_general.f_get_instrument_trading_days(cur_pcdi_rows.instrument_id,
                                                                                         vd_qp_start_date,
                                                                                         vd_qp_end_date);
                  vn_count_val_qp           := vn_no_of_trading_days -
                                               vn_count_set_qp;
                  vn_during_total_val_price := vn_during_total_val_price +
                                               vn_during_val_price *
                                               vn_count_val_qp;
                
                end if;
                if (vn_count_val_qp + vn_count_set_qp) <> 0 then
                  if vn_market_flag = 'N' then
                    vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                          vn_anyday_price_ufix_qty_value) /
                                          nvl(cc1.qty_to_be_fixed, 0);
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
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.element_id,
                                                          cur_pcdi_rows.internal_contract_item_ref_no)
        loop
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_not_called_off_rows.price_value;
            vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                            cur_pcdi_rows.payable_qty_unit_id,
                                                                            cur_pcdi_rows.item_qty_unit_id,
                                                                            cur_pcdi_rows.payable_qty);
            vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_not_called_off_rows.price_unit_id;
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select pfqpp.qp_pricing_period_type,
                               pfqpp.qp_period_from_date,
                               pfqpp.qp_period_to_date,
                               pfqpp.qp_month,
                               pfqpp.qp_year,
                               pfqpp.qp_date,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id --pum price unit id, as quoted available in this unit only
                          from ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing  pfqpp,
                               v_ppu_pum                     ppu
                         where ppfh.ppfh_id = pfqpp.ppfh_id
                           and ppfh.pcbpd_id =
                               cur_not_called_off_rows.pcbpd_id
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id)
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
              if vc_period = 'Before QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  ---- get third wednesday of QP period
                  --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
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
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   vd_qp_end_date);
                  elsif vc_period = 'After QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   pd_trade_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
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
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
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
              elsif (vc_period = 'During QP' or vc_period = 'After QP') then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
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
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
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
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   vd_qp_end_date);
                  elsif vc_period = 'After QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   pd_trade_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
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
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  begin
                    select dqd.dr_id,
                           dqd.price,
                           dqd.price_unit_id
                      into vc_during_price_dr_id,
                           vn_during_qp_price,
                           vc_during_qp_price_unit_id
                      from dq_derivative_quotes        dq,
                           dqd_derivative_quote_detail dqd,
                           v_dim_cash_pricepoint_drid  drm
                     where dq.dq_id = dqd.dq_id
                       and dq.instrument_id = cur_pcdi_rows.instrument_id
                       and dq.instrument_id = drm.instrument_id
                       and drm.dr_id = dqd.dr_id
                       and dqd.available_price_id =
                           cur_pcdi_rows.available_price_id
                       and dq.price_source_id = drm.price_source_id
                       and dqd.price_unit_id = cc1.price_unit_id
                       and dq.corporate_id = cur_pcdi_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date =
                           (select max(dq.trade_date)
                              from dq_derivative_quotes        dq,
                                   dqd_derivative_quote_detail dqd
                             where dq.dq_id = dqd.dq_id
                               and dqd.dr_id = drm.dr_id
                               and dq.instrument_id =
                                   cur_pcdi_rows.instrument_id
                               and dqd.available_price_id =
                                   cur_pcdi_rows.available_price_id
                               and dq.price_source_id = drm.price_source_id
                               and dqd.price_unit_id = cc1.price_unit_id
                               and dq.corporate_id =
                                   cur_pcdi_rows.corporate_id
                               and dq.is_deleted = 'N'
                               and dqd.is_deleted = 'N'
                               and dq.trade_date <= pd_trade_date);
                  exception
                    when no_data_found then
                      vn_during_qp_price         := 0;
                      vc_during_qp_price_unit_id := null;
                  end;
                else
                  begin
                    select dqd.price,
                           dqd.price_unit_id
                      into vn_during_qp_price,
                           vc_during_qp_price_unit_id
                      from dq_derivative_quotes          dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_during_price_dr_id
                       and dq.instrument_id = cur_pcdi_rows.instrument_id
                       and dqd.available_price_id =
                           cur_pcdi_rows.available_price_id
                       and dq.price_source_id =
                           cur_pcdi_rows.price_source_id
                       and dqd.price_unit_id = cc1.price_unit_id
                       and dq.corporate_id = cur_pcdi_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date =
                           (select max(dq.trade_date)
                              from dq_derivative_quotes          dq,
                                   v_dqd_derivative_quote_detail dqd
                             where dq.dq_id = dqd.dq_id
                               and dqd.dr_id = vc_during_price_dr_id
                               and dq.instrument_id =
                                   cur_pcdi_rows.instrument_id
                               and dqd.available_price_id =
                                   cur_pcdi_rows.available_price_id
                               and dq.price_source_id =
                                   cur_pcdi_rows.price_source_id
                               and dqd.price_unit_id = cc1.price_unit_id
                               and dq.corporate_id =
                                   cur_pcdi_rows.corporate_id
                               and dq.is_deleted = 'N'
                               and dqd.is_deleted = 'N'
                               and dq.trade_date <= pd_trade_date);
                  exception
                    when no_data_found then
                      vn_during_qp_price         := 0;
                      vc_during_qp_price_unit_id := null;
                  end;
                end if;
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
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_price_unit_id;
  end;

  procedure sp_calc_conc_gmr_price(pc_internal_gmr_ref_no varchar2,
                                   pc_element_id          varchar2,
                                   pd_trade_date          date,
                                   pn_price               out number,
                                   pc_price_unit_id       out varchar2) is
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
               where grd.status = 'Active'
                 and grd.is_deleted = 'N'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             v_gmr_stockpayable_qty spq,
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
                from v_gmr_exchange_details       qat,
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
         and tt.element_id = spq.element_id
         and tt.internal_gmr_ref_no = spq.internal_gmr_ref_no
         and gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
         and gmr.is_deleted = 'N'
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and spq.element_id = pc_element_id
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
               where grd.status = 'Active'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             v_gmr_stockpayable_qty spq,
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
                from v_gmr_exchange_details       qat,
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
         and tt.element_id = spq.element_id
         and tt.internal_gmr_ref_no = spq.internal_gmr_ref_no
         and gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
         and gmr.is_deleted = 'N'
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and spq.element_id = pc_element_id;
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
             pofh.no_of_prompt_days
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where pofh.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pcbpd.element_id = pc_element_id
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(50);
    vd_3rd_wed_of_qp               date;
    vn_workings_days               number;
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
    vn_during_qp_price             number;
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_value number;
    vn_anyday_price_ufix_qty_value number;
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
  begin
    for cur_gmr_rows in cur_gmr
    loop
      vn_total_contract_value := 0;
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no,
                                          cur_gmr_rows.element_id)
      loop
        vn_market_flag                 := null;
        vn_any_day_price_fix_qty_value := 0;
        vn_anyday_price_ufix_qty_value := 0;
        vn_any_day_unfixed_qty         := 0;
        vn_any_day_fixed_qty           := 0;
        vc_pcbpd_id                    := cur_gmr_ele_rows.pcbpd_id;
        vc_price_unit_id               := null;
        vc_ppu_price_unit_id           := null;
        vd_qp_start_date               := cur_gmr_ele_rows.qp_start_date;
        vd_qp_end_date                 := cur_gmr_ele_rows.qp_end_date;
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
        dbms_output.put_line('vc_period ' || vc_period || ' QP: ' ||
                             vd_qp_start_date || ' to ' || vd_qp_end_date);
        if vc_period = 'Before QP' then
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
            vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date, 'Wed', 3);
            while true
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                  vd_3rd_wed_of_qp) then
                vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
              else
                exit;
              end if;
            end loop;
            --- get 3rd wednesday  before QP period
            -- Get the quotation date = Trade Date +2 working Days
            if vd_3rd_wed_of_qp <= pd_trade_date then
              vn_workings_days := 0;
              vd_quotes_date   := pd_trade_date + 1;
              while vn_workings_days <> 2
              loop
                if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                    vd_quotes_date) then
                  vd_quotes_date := vd_quotes_date + 1;
                else
                  vn_workings_days := vn_workings_days + 1;
                  if vn_workings_days <> 2 then
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
                vc_before_price_dr_id := null;
            end;
          elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
                cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
            vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
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
                vc_before_price_dr_id := null;
            end;
          end if;
          begin
            select dqd.price,
                   dqd.price_unit_id
              into vn_before_qp_price,
                   vc_before_qp_price_unit_id
              from dq_derivative_quotes          dq,
                   v_dqd_derivative_quote_detail dqd
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_before_price_dr_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = cur_gmr_rows.price_source_id
               and dqd.price_unit_id = vc_price_unit_id
               and dq.corporate_id = cur_gmr_rows.corporate_id
               and dq.is_deleted = 'N'
               and dqd.is_deleted = 'N'
               and dq.trade_date =
                   (select max(dq.trade_date)
                      from dq_derivative_quotes          dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_before_price_dr_id
                       and dq.instrument_id = cur_gmr_rows.instrument_id
                       and dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                       and dq.price_source_id = cur_gmr_rows.price_source_id
                       and dqd.price_unit_id = vc_price_unit_id
                       and dq.corporate_id = cur_gmr_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date <= pd_trade_date);
          exception
            when no_data_found then
              vn_before_qp_price         := 0;
              vc_before_qp_price_unit_id := null;
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
        elsif (vc_period = 'During QP' or vc_period = 'After QP') then
          vd_dur_qp_start_date := vd_qp_start_date;
          vd_dur_qp_end_date   := vd_qp_end_date;
          dbms_output.put_line('vc_period ' || vc_period || ' QP: ' ||
                               vd_dur_qp_start_date || ' to ' ||
                               vd_dur_qp_end_date);
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
                        and poch.is_active = 'Y'
                        and pocd.is_active = 'Y'
                        and pofh.is_active = 'Y'
                        and nvl(pfd.is_hedge_correction, 'N') = 'N'
                        and nvl(pfd.user_price, 0) <> 0
                        and pfd.is_active = 'Y')
          loop
            vn_during_total_set_price := vn_during_total_set_price +
                                         cc.user_price;
            vn_count_set_qp           := vn_count_set_qp + 1;
            vn_any_day_fixed_qty      := vn_any_day_fixed_qty +
                                         cc.qty_fixed;
          
            vn_any_day_price_fix_qty_value := vn_any_day_price_fix_qty_value +
                                              (cc.user_price * cc.qty_fixed);
          end loop;
          if cur_gmr_ele_rows.is_any_day_pricing = 'Y' then
            vn_market_flag := 'N';
          else
            vn_market_flag := 'Y';
          end if;
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
            -- get the third wednes day
            vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date, 'Wed', 3);
            while true
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
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
              vn_workings_days := 0;
              vd_quotes_date   := pd_trade_date + 1;
              while vn_workings_days <> 2
              loop
                if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                    vd_quotes_date) then
                  vd_quotes_date := vd_quotes_date + 1;
                else
                  vn_workings_days := vn_workings_days + 1;
                  if vn_workings_days <> 2 then
                    vd_quotes_date := vd_quotes_date + 1;
                  end if;
                end if;
              end loop;
              vd_3rd_wed_of_qp := vd_quotes_date;
            end if;
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
                vc_during_price_dr_id := null;
            end;
          elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
                cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
            if vc_period = 'During QP' then
              vc_prompt_date := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                             vd_qp_end_date);
            elsif vc_period = 'After QP' then
              vc_prompt_date := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
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
                vc_during_price_dr_id := null;
            end;
          end if;
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
            begin
              select dqd.dr_id,
                     dqd.price,
                     dqd.price_unit_id
                into vc_during_price_dr_id,
                     vn_during_val_price,
                     vc_during_val_price_unit_id
                from dq_derivative_quotes        dq,
                     dqd_derivative_quote_detail dqd,
                     v_dim_cash_pricepoint_drid  drm
               where dq.dq_id = dqd.dq_id
                 and dq.instrument_id = cur_gmr_rows.instrument_id
                 and dq.instrument_id = drm.instrument_id
                 and drm.dr_id = dqd.dr_id
                 and dqd.available_price_id =
                     cur_gmr_rows.available_price_id
                 and dq.price_source_id = drm.price_source_id
                 and dqd.price_unit_id = vc_price_unit_id
                 and dq.corporate_id = cur_gmr_rows.corporate_id
                 and dq.is_deleted = 'N'
                 and dqd.is_deleted = 'N'
                 and dq.trade_date =
                     (select max(dq.trade_date)
                        from dq_derivative_quotes        dq,
                             dqd_derivative_quote_detail dqd
                       where dq.dq_id = dqd.dq_id
                         and dqd.dr_id = drm.dr_id
                         and dq.instrument_id = cur_gmr_rows.instrument_id
                         and dqd.available_price_id =
                             cur_gmr_rows.available_price_id
                         and dq.price_source_id = drm.price_source_id
                         and dqd.price_unit_id = vc_price_unit_id
                         and dq.corporate_id = cur_gmr_rows.corporate_id
                         and dq.is_deleted = 'N'
                         and dqd.is_deleted = 'N'
                         and dq.trade_date <= pd_trade_date);
            exception
              when no_data_found then
                vn_during_val_price         := 0;
                vc_during_val_price_unit_id := null;
            end;
          else
            begin
              select dqd.price,
                     dqd.price_unit_id
                into vn_during_val_price,
                     vc_during_val_price_unit_id
                from dq_derivative_quotes          dq,
                     v_dqd_derivative_quote_detail dqd
               where dq.dq_id = dqd.dq_id
                 and dqd.dr_id = vc_during_price_dr_id
                 and dq.instrument_id = cur_gmr_rows.instrument_id
                 and dqd.available_price_id =
                     cur_gmr_rows.available_price_id
                 and dq.price_source_id = cur_gmr_rows.price_source_id
                 and dqd.price_unit_id = vc_price_unit_id
                 and dq.corporate_id = cur_gmr_rows.corporate_id
                 and dq.is_deleted = 'N'
                 and dqd.is_deleted = 'N'
                 and dq.trade_date =
                     (select max(dq.trade_date)
                        from dq_derivative_quotes          dq,
                             v_dqd_derivative_quote_detail dqd
                       where dq.dq_id = dqd.dq_id
                         and dqd.dr_id = vc_during_price_dr_id
                         and dq.instrument_id = cur_gmr_rows.instrument_id
                         and dqd.available_price_id =
                             cur_gmr_rows.available_price_id
                         and dq.price_source_id =
                             cur_gmr_rows.price_source_id
                         and dqd.price_unit_id = vc_price_unit_id
                         and dq.corporate_id = cur_gmr_rows.corporate_id
                         and dq.is_deleted = 'N'
                         and dqd.is_deleted = 'N'
                         and dq.trade_date <= pd_trade_date);
            exception
              when no_data_found then
                vn_during_val_price         := 0;
                vc_during_val_price_unit_id := null;
            end;
          end if;
          vn_during_total_val_price := 0;
          vn_count_val_qp           := 0;
          vd_dur_qp_start_date      := pd_trade_date + 1;
          if vn_market_flag = 'N' then
            vn_during_total_val_price      := vn_during_total_val_price +
                                              vn_during_val_price;
            vn_any_day_unfixed_qty         := cur_gmr_ele_rows.qty_to_be_fixed -
                                              vn_any_day_fixed_qty;
            vn_count_val_qp                := vn_count_val_qp + 1;
            vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                              vn_during_total_val_price);
          else
            vn_count_val_qp           := cur_gmr_ele_rows.no_of_prompt_days -
                                         vn_count_set_qp;
            vn_during_total_val_price := vn_during_total_val_price +
                                         vn_during_val_price *
                                         vn_count_val_qp;
          
          end if;
          if (vn_count_val_qp + vn_count_set_qp) <> 0 then
            if vn_market_flag = 'N' then
              vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                    vn_anyday_price_ufix_qty_value) /
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
          else
            vn_total_contract_value := 0;
          end if;
        end if;
      end loop;
      dbms_output.put_line('vn_total_quantity ' || vn_total_quantity ||
                           ' vn_total_contract_value ' ||
                           vn_total_contract_value);
      vn_average_price := round(vn_total_contract_value / vn_total_quantity,
                                3);
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_ppu_price_unit_id;
  end;

  function f_get_next_day(pd_date     in date,
                          pc_day      in varchar2,
                          pn_position in number) return date is
    vd_position_date date;
  begin
    select next_day((trunc(pd_date, 'Mon') - 1), pc_day) +
           ((pn_position * 7) - 7)
      into vd_position_date
      from dual;
    return vd_position_date;
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
