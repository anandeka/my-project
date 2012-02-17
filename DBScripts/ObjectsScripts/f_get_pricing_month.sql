create or replace function f_get_pricing_month(pc_pcbpd_id in varchar2)
  return varchar2 is
  cursor cur_qp_end_date is
    select pcm.contract_ref_no,
           pcdi.pcdi_id,
           pcdi.internal_contract_ref_no,
           pci.internal_contract_item_ref_no,
           pcdi.delivery_item_no,
           pcdi.delivery_period_type,
           pcdi.delivery_from_month,
           pcdi.delivery_from_year,
           pcdi.delivery_to_month,
           pcdi.delivery_to_year,
           pcdi.delivery_from_date,
           pcdi.delivery_to_date,
           pcdi.basis_type,
           nvl(pcdi.transit_days, 0) transit_days,
           pcdi.qp_declaration_date,
           ppfh.ppfh_id,
           ppfh.price_unit_id,
           pocd.qp_period_type,
           pofh.qp_start_date,
           pofh.qp_end_date,
           pfqpp.event_name,
           pfqpp.no_of_event_months,
           pofh.pofh_id,
           pcbpd.price_basis
      from pcdi_pc_delivery_item          pcdi,
           pci_physical_contract_item     pci,
           pcm_physical_contract_main     pcm,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pofh_price_opt_fixation_header pofh,
           pcbpd_pc_base_price_detail     pcbpd,
           ppfh_phy_price_formula_header  ppfh,
           pfqpp_phy_formula_qp_pricing   pfqpp
     where pcdi.pcdi_id = pci.pcdi_id
       and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id(+)
       and pocd.pcbpd_id = pcbpd.pcbpd_id
       and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
       and ppfh.ppfh_id = pfqpp.ppfh_id(+)
       and pcm.contract_status = 'In Position'
       and pcm.contract_type in ('BASEMETAL','CONCENTRATES')
       and pcbpd.price_basis <> 'Fixed'
       and pci.item_qty > 0
       and pcdi.is_active = 'Y'
       and pci.is_active = 'Y'
       and pcm.is_active = 'Y'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active(+) = 'Y'
       and pcbpd.is_active = 'Y'
          --and pci.internal_contract_item_ref_no = pc_Int_contract_Item_Ref_No; commented in order to change the parameter.
       and pocd.pcbpd_id = pc_pcbpd_id;
  --and pfqpp.is_active = 'Y'
  --and pofh.is_active(+) = 'Y';

  vd_qp_start_date date;
  vd_qp_end_date   date;
  vd_shipment_date date;
  vd_arrival_date  date;
  vd_evevnt_date   date;

begin

  for cur_rows in cur_qp_end_date
  loop
    if cur_rows.price_basis in ('Index', 'Formula') then

      if cur_rows.basis_type = 'Shipment' then
        if cur_rows.delivery_period_type = 'Month' then
          vd_shipment_date := last_day('01-' || cur_rows.delivery_to_month || '-' ||
                                       cur_rows.delivery_to_year);
        elsif cur_rows.delivery_period_type = 'Date' then
          vd_shipment_date := cur_rows.delivery_to_date;
        end if;
        vd_arrival_date := vd_shipment_date + cur_rows.transit_days;

      elsif cur_rows.basis_type = 'Arrival' then
        if cur_rows.delivery_period_type = 'Month' then
          vd_arrival_date := last_day('01-' || cur_rows.delivery_to_month || '-' ||
                                      cur_rows.delivery_to_year);
        elsif cur_rows.delivery_period_type = 'Date' then
          vd_arrival_date := cur_rows.delivery_to_date;
        end if;
        vd_shipment_date := vd_arrival_date - cur_rows.transit_days;
      end if;

      if cur_rows.qp_period_type = 'Period' then
        vd_qp_start_date := cur_rows.qp_start_date;
        vd_qp_end_date   := cur_rows.qp_end_date;
      elsif cur_rows.qp_period_type = 'Month' then
        vd_qp_start_date := cur_rows.qp_start_date;
        vd_qp_end_date   := cur_rows.qp_end_date;
      elsif cur_rows.qp_period_type = 'Date' then
        vd_qp_start_date := cur_rows.qp_start_date;
        vd_qp_end_date   := cur_rows.qp_end_date;
      elsif cur_rows.qp_period_type = 'Event' then
        if cur_rows.event_name = 'Month After Month Of Shipment' then
          vd_evevnt_date   := add_months(vd_shipment_date,
                                         cur_rows.no_of_event_months);
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_evevnt_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        elsif cur_rows.event_name = 'Month After Month Of Arrival' then
          vd_evevnt_date   := add_months(vd_arrival_date,
                                         cur_rows.no_of_event_months);
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_evevnt_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        elsif cur_rows.event_name = 'Month Before Month Of Shipment' then
          vd_evevnt_date   := add_months(vd_shipment_date,
                                         -1 * cur_rows.no_of_event_months);
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_evevnt_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        elsif cur_rows.event_name = 'Month Before Month Of Arrival' then
          vd_evevnt_date   := add_months(vd_arrival_date,
                                         -1 * cur_rows.no_of_event_months);
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_evevnt_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        elsif cur_rows.event_name = 'First Half Of Shipment Month' then
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_shipment_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := to_date('15-' ||
                                      to_char(vd_shipment_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
        elsif cur_rows.event_name = 'First Half Of Arrival Month' then
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_arrival_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := to_date('15-' ||
                                      to_char(vd_arrival_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
        elsif cur_rows.event_name = 'First Half Of Shipment Month' then
          vd_qp_start_date := to_date('16-' ||
                                      to_char(vd_shipment_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        elsif cur_rows.event_name = 'Second Half Of Arrival Month' then
          vd_qp_start_date := to_date('16-' ||
                                      to_char(vd_arrival_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        end if;
      end if;

    end if;
  end loop;

  return to_char(last_day(vd_qp_end_date), 'dd-Mon-yyyy');
end f_get_pricing_month;
/
