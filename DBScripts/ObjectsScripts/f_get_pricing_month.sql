CREATE OR REPLACE FUNCTION "F_GET_PRICING_MONTH" (pc_pcbpd_id in varchar2)
return varchar2 is
cursor cur_qp_end_date is
--  Not Applicable + Called Off
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
       and pcm.contract_type in ('BASEMETAL', 'CONCENTRATES')
       and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
       and pcbpd.price_basis <> 'Fixed'
       and pci.item_qty > 0
       and pcdi.is_active = 'Y'
       and pci.is_active = 'Y'
       and pcm.is_active = 'Y'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active(+) = 'Y'
       and pcbpd.is_active = 'Y'
       and pocd.pcbpd_id = pc_pcbpd_id
union all
-- Not Called Off 
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
           pfqpp.qp_pricing_period_type qp_period_type,
          (case
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_from_date
         when (pfqpp.qp_pricing_period_type = 'Month') then
          to_date('01-' || pfqpp.qp_month || '-' || pfqpp.qp_year)
         when (pfqpp.qp_pricing_period_type = 'Date') then
          (pfqpp.qp_date)
         else
          qp_period_from_date
       end) qp_start_date,
         (case
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_to_date
         when (pfqpp.qp_pricing_period_type = 'Month') then
          last_day(to_date('01-' || pfqpp.qp_month || '-' || pfqpp.qp_year))
         when (pfqpp.qp_pricing_period_type = 'Date') then
         pfqpp.qp_date
         else
          qp_period_to_date
       end) qp_end_date,
           pfqpp.event_name,
           pfqpp.no_of_event_months,
           null pofh_id,
           pcbpd.price_basis
      from pcdi_pc_delivery_item          pcdi,
           pci_physical_contract_item     pci,
           pcm_physical_contract_main     pcm,
           pcipf_pci_pricing_formula  pcipf,
           pcbph_pc_base_price_header pcbph,
           pcbpd_pc_base_price_detail     pcbpd,
           ppfh_phy_price_formula_header  ppfh,
           pfqpp_phy_formula_qp_pricing   pfqpp          
 where pcdi.pcdi_id = pci.pcdi_id
       and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pci.internal_contract_item_ref_no =  pcipf.internal_contract_item_ref_no
       and pcipf.pcbph_id = pcbph.pcbph_id
       and pcbph.pcbph_id = pcbpd.pcbph_id
       and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
       and ppfh.ppfh_id = pfqpp.ppfh_id(+)
       and pcm.contract_status = 'In Position'
       and pcm.contract_type in ('BASEMETAL', 'CONCENTRATES')
       and pcdi.price_option_call_off_status = 'Not Called Off'
       and pcbpd.price_basis <> 'Fixed'
       and pci.item_qty > 0
       and pcdi.is_active = 'Y'
       and pci.is_active = 'Y'
       and pcm.is_active = 'Y'
       and pcipf.is_active = 'Y'
       and pcbph.is_active = 'Y'
       and pcbpd.is_active = 'Y'
       and pcbpd.pcbpd_id = pc_pcbpd_id;

  vd_qp_start_date date;
  vd_qp_end_date   date;
  vd_shipment_date date;
  vd_arrival_date  date;

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
        begin
          select dieqp.expected_qp_start_date,
                 dieqp.expected_qp_end_date
            into vd_qp_start_date,
                 vd_qp_end_date
            from di_del_item_exp_qp_details dieqp
           where dieqp.pcdi_id = cur_rows.pcdi_id
             and dieqp.pcbpd_id = pc_pcbpd_id
             and dieqp.is_active = 'Y';
        exception
          when no_data_found then
            vd_qp_start_date := cur_rows.qp_start_date;
            vd_qp_end_date   := cur_rows.qp_end_date;
          when others then
            vd_qp_start_date := cur_rows.qp_start_date;
            vd_qp_end_date   := cur_rows.qp_end_date;
        end;
      else
        vd_qp_start_date := cur_rows.qp_start_date;
        vd_qp_end_date   := cur_rows.qp_end_date;
      end if;
    
    end if;
  end loop;

  return to_char(vd_qp_end_date, 'dd-Mon-yyyy');
end f_get_pricing_month; 
 
 
 
 
 
/
