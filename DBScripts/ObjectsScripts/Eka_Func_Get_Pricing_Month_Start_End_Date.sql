create or replace function f_get_pricing_mth_strt_end_dt 
/*
--    Function:            F_Get_Pricing_Mth_Strt_End_Dt
--    Created On:       22nd Feb 2013
--    Created By:       G.A.Raju
--    Purpose:            To get Pricing Start and End dates as an object
--    Modified On:       
--    Modified By:       
*/
return type_tbl_prc_mth_strt_dt pipelined is
cursor cur_qp_end_date is
with qry as(
select 
        poch.poch_id,
        pocd.pcbpd_id,
        pcm.contract_ref_no,
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
        pcbpd.price_basis,
        row_number() over (partition by poch.poch_id, pcbpd.pcbpd_id order by rownum) ordr
from pcdi_pc_delivery_item          pcdi,
        pci_physical_contract_item     pci,
        pcm_physical_contract_main     pcm,
        poch_price_opt_call_off_header poch,
        pocd_price_option_calloff_dtls pocd,
        (select *
                                  from pofh_price_opt_fixation_header pfh
                                 where pfh.internal_gmr_ref_no is null
                                   and pfh.is_active = 'Y'
                                   and pfh.qty_to_be_fixed <> 0) pofh,
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
)
select * from qry where ordr=1;

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
                     and dieqp.pcbpd_id = cur_rows.pcbpd_id
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
        pipe row(type_prc_mth_strt_dt(cur_rows.pcbpd_id, cur_rows.poch_id, vd_qp_start_date, vd_qp_end_date));
  end loop;
  return;
end f_get_pricing_mth_strt_end_dt;
/
