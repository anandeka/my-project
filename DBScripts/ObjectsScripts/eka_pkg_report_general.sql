create or replace package "PKG_REPORT_GENERAL" is
  -- All general packages and procedures
  function fn_get_item_dry_qty(pc_internal_cont_item_ref_no varchar2,
                               pn_item_qty                  number)
    return number;
  procedure sp_element_position_qty(pc_internal_contract_ref_no varchar2,
                                    pn_qty                      number,
                                    pc_qty_unit_id              varchar2,
                                    pc_assay_header_id          varchar2,
                                    pc_element_id               varchar2,
                                    pc_ele_qty_string           out varchar2);
  function fn_get_element_qty(pc_internal_contract_ref_no varchar2,
                              pn_qty                      number,
                              pc_qty_unit_id              varchar2,
                              pc_assay_header_id          varchar2,
                              pc_element_id               varchar2)
    return number;
  function fn_get_element_assay_qty(pc_element_id      varchar2,
                                    pc_assay_header_id varchar2,
                                    pc_wet_dry_type    varchar2,
                                    pn_qty             number,
                                    pc_qty_unit_id     varchar2)
    return number;
  function fn_get_element_qty_unit_id(pc_internal_contract_ref_no varchar2,
                                      pc_item_qty_unit_id         varchar2,
                                      pc_assay_header_id          varchar2,
                                      pc_element_id               varchar2)
    return varchar2;
  function fn_get_element_pricing_month(pc_pcbpd_id   in varchar2,
                                        pc_element_id varchar2)
    return varchar2;
  function fn_get_assay_dry_qty(pc_product_id      varchar2,
                                pc_assay_header_id varchar2,
                                pn_qty             number,
                                pc_qty_unit_id     varchar2) return number;
  function fn_deduct_wet_to_dry_qty(pc_product_id                varchar2,
                                    pc_internal_cont_item_ref_no varchar2,
                                    pn_item_qty                  number)
    return number;
  function fn_get_elmt_assay_content_qty(pc_element_id      varchar2,
                                         pc_assay_header_id varchar2,
                                         pn_qty             number,
                                         pc_qty_unit_id     varchar2)
    return number;

end; 
/
create or replace package body "PKG_REPORT_GENERAL" is
  function fn_get_item_dry_qty(pc_internal_cont_item_ref_no varchar2,
                               pn_item_qty                  number)
    return number is
    vn_deduct_qty       number;
    vn_deduct_total_qty number;
    vn_item_qty         number;
    vn_converted_qty    number;
  begin
    vn_item_qty         := pn_item_qty;
    vn_deduct_qty       := 0;
    vn_deduct_total_qty := 0;
    for cur_deduct_qty in (select aml.attribute_id,
                                  rm.ratio_name,
                                  rm.qty_unit_id_numerator,
                                  rm.qty_unit_id_denominator,
                                  pqca.typical,
                                  ppm.product_id,
                                  pci.item_qty_unit_id
                             from ppm_product_properties_mapping ppm,
                                  aml_attribute_master_list      aml,
                                  pqca_pq_chemical_attributes    pqca,
                                  rm_ratio_master                rm,
                                  asm_assay_sublot_mapping       asm,
                                  ash_assay_header               ash,
                                  pcdi_pc_delivery_item          pcdi,
                                  pci_physical_contract_item     pci,
                                  pcpq_pc_product_quality        pcpq,
                                  pcpd_pc_product_definition     pcpd
                            where ppm.attribute_id = aml.attribute_id
                              and aml.attribute_id = pqca.element_id
                              and pqca.asm_id = asm.asm_id
                              and pqca.unit_of_measure = rm.ratio_id
                              and asm.ash_id = ash.ash_id
                              and ash.internal_contract_ref_no =
                                  pcdi.internal_contract_ref_no
                              and pcdi.pcdi_id = pci.pcdi_id
                              and pci.pcpq_id = pcpq.pcpq_id
                              and pcpq.pcpd_id = pcpd.pcpd_id
                              and ppm.product_id = pcpd.product_id
                              and pci.internal_contract_item_ref_no =
                                  pc_internal_cont_item_ref_no
                              and pcpq.assay_header_id = ash.ash_id
                              and ppm.deduct_for_wet_to_dry = 'Y')
    loop
    
      if cur_deduct_qty.ratio_name = '%' then
        vn_deduct_qty := vn_item_qty * (cur_deduct_qty.typical / 100);
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 cur_deduct_qty.qty_unit_id_denominator,
                                                                 vn_item_qty) *
                            cur_deduct_qty.typical;
        vn_deduct_qty    := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.qty_unit_id_numerator,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 vn_converted_qty);
      
      end if;
      vn_deduct_total_qty := vn_deduct_total_qty + vn_deduct_qty;
    
    end loop;
    return vn_deduct_total_qty;
  end;
  --
  procedure sp_element_position_qty(pc_internal_contract_ref_no varchar2,
                                    pn_qty                      number,
                                    pc_qty_unit_id              varchar2,
                                    pc_assay_header_id          varchar2,
                                    pc_element_id               varchar2,
                                    pc_ele_qty_string           out varchar2) is
  
    cursor cur_element is
      select pci.internal_contract_item_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpq.unit_of_measure item_unit_of_measure,
             pqca.element_id,
             pcpq.assay_header_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from pci_physical_contract_item  pci,
             pcpq_pc_product_quality     pcpq,
             ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
      
       where pci.pcpq_id = pcpq.pcpq_id
         and pcpq.assay_header_id = ash.ash_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pci.internal_contract_item_ref_no =
             pc_internal_contract_ref_no
         and pcpq.assay_header_id = pc_assay_header_id
         and pqca.element_id = pc_element_id;
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
  
  begin
    for cur_element_rows in cur_element
    loop
      if cur_element_rows.item_unit_of_measure = 'Wet' then
        vn_deduct_qty := fn_get_item_dry_qty(cur_element_rows.internal_contract_item_ref_no,
                                             cur_element_rows.item_qty);
        vn_item_qty   := cur_element_rows.item_qty - vn_deduct_qty;
      else
        vn_item_qty := cur_element_rows.item_qty;
      end if;
    
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.item_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := cur_element_rows.item_qty_unit_id;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 cur_element_rows.item_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
      
        vn_element_qty := vn_converted_qty * cur_element_rows.typical;
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
      
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      end if;
    end loop;
  end;
  function fn_get_element_qty(pc_internal_contract_ref_no varchar2,
                              pn_qty                      number,
                              pc_qty_unit_id              varchar2,
                              pc_assay_header_id          varchar2,
                              pc_element_id               varchar2)
    return number is
    cursor cur_element is
      select pci.internal_contract_item_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpq.unit_of_measure item_unit_of_measure,
             pqca.element_id,
             pcpq.assay_header_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from pci_physical_contract_item  pci,
             pcpq_pc_product_quality     pcpq,
             ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
       where pci.pcpq_id = pcpq.pcpq_id
         and pcpq.assay_header_id = ash.ash_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pci.internal_contract_item_ref_no =
             pc_internal_contract_ref_no
         and pcpq.assay_header_id = pc_assay_header_id
         and pqca.element_id = pc_element_id;
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
    pc_ele_qty_string      varchar2(100);
    vn_ele_qty             number;
  begin
    for cur_element_rows in cur_element
    loop
      if cur_element_rows.item_unit_of_measure = 'Wet' then
        vn_deduct_qty := fn_get_item_dry_qty(cur_element_rows.internal_contract_item_ref_no,
                                             pn_qty);
        vn_item_qty   := pn_qty - vn_deduct_qty;
      else
        vn_item_qty := pn_qty;
      end if;
    
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.item_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := pc_qty_unit_id;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
      
        vn_element_qty := vn_converted_qty * cur_element_rows.typical;
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
      
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      end if;
      vn_ele_qty := vn_element_qty;
    end loop;
    return(vn_ele_qty);
  end;
  function fn_get_element_assay_qty(pc_element_id      varchar2,
                                    pc_assay_header_id varchar2,
                                    pc_wet_dry_type    varchar2,
                                    pn_qty             number,
                                    pc_qty_unit_id     varchar2)
    return number is
    cursor cur_element is
      select pqca.element_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
       where ash.ash_id = pc_assay_header_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pqca.element_id = pc_element_id;
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
    --pc_ele_qty_string      varchar2(100);
    vn_ele_qty number;
  begin
    for cur_element_rows in cur_element
    loop
      vn_deduct_qty := 0;
      if pc_wet_dry_type = 'Wet' then
        /*vn_deduct_qty := fn_get_item_dry_qty(cur_element_rows.internal_contract_item_ref_no,
        pn_qty);*/
        vn_item_qty := pn_qty - vn_deduct_qty;
      else
        vn_item_qty := pn_qty;
      end if;
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = pc_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := pc_qty_unit_id;
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
        vn_element_qty   := vn_converted_qty * cur_element_rows.typical;
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      end if;
      vn_ele_qty := vn_element_qty;
    end loop;
    return(vn_ele_qty);
  end;
  function fn_get_element_qty_unit_id(pc_internal_contract_ref_no varchar2,
                                      pc_item_qty_unit_id         varchar2,
                                      pc_assay_header_id          varchar2,
                                      pc_element_id               varchar2)
    return varchar2 is
    cursor cur_element is
      select pqca.element_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
       where ash.ash_id = pc_assay_header_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pqca.element_id = pc_element_id;
  
    vc_element_qty_unit_id varchar2(15);
  begin
    for cur_element_rows in cur_element
    loop
      if cur_element_rows.ratio_name = '%' then
        vc_element_qty_unit_id := pc_item_qty_unit_id;
      else
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      end if;
    end loop;
    return(vc_element_qty_unit_id);
  end;
  function fn_get_element_pricing_month(pc_pcbpd_id   in varchar2,
                                        pc_element_id varchar2)
    return varchar2 is
    cursor cur_qp_end_date is
      select pcm.contract_ref_no,
             pcdi.pcdi_id,
             pcbpd.pcbpd_id,
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
            --  and pcm.contract_type = 'BASEMETAL'
         and pcbpd.price_basis <> 'Fixed'
         and pci.item_qty > 0
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pofh.is_active(+) = 'Y'
         and pcbpd.is_active = 'Y'
         and poch.element_id = pc_element_id
            --and pci.internal_contract_item_ref_no = pc_Int_contract_Item_Ref_No Commented
         and pocd.pcbpd_id = pc_pcbpd_id; -- Newly Added
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
            vd_shipment_date := last_day('01-' ||
                                         cur_rows.delivery_to_month || '-' ||
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
              vd_qp_start_date := cur_rows.qp_end_date;
              vd_qp_end_date   := cur_rows.qp_end_date;
          end;
          /*if cur_rows.event_name = 'Month After Month Of Shipment' then
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
                                        to_char(vd_shipment_date,
                                                'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := to_date('15-' ||
                                        to_char(vd_shipment_date,
                                                'Mon-yyyy'),
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
                                        to_char(vd_shipment_date,
                                                'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := last_day(vd_qp_start_date);
          elsif cur_rows.event_name = 'Second Half Of Arrival Month' then
            vd_qp_start_date := to_date('16-' ||
                                        to_char(vd_arrival_date, 'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := last_day(vd_qp_start_date);
          end if;*/
        end if;
      
      end if;
    end loop;
  
    return to_char(last_day(vd_qp_end_date), 'dd-Mon-yyyy');
  end;
  function fn_get_assay_dry_qty(pc_product_id      varchar2,
                                pc_assay_header_id varchar2,
                                pn_qty             number,
                                pc_qty_unit_id     varchar2) return number is
    vn_deduct_qty       number;
    vn_deduct_total_qty number;
    vn_item_qty         number;
    vn_converted_qty    number;
  begin
    vn_deduct_qty       := 0;
    vn_deduct_total_qty := 0;
    for cur_deduct_qty in (select ash.ash_id,
                                  (case
                                    when ash.ash_id =
                                         (select ash_new.pricing_assay_ash_id
                                            from ash_assay_header ash_new
                                           where ash_new.assay_type =
                                                 'Provisional Assay'
                                             and ash_new.is_active = 'Y'
                                             and ash_new.internal_grd_ref_no =
                                                 ash.internal_grd_ref_no) then
                                     pn_qty                                    
                                    when ash.ash_id =
                                         (select ash_new.ash_id
                                            from ash_assay_header ash_new
                                           where ash_new.assay_type =
                                                 'Shipment Assay'
                                             and ash_new.is_active = 'Y'
                                             and ash_new.internal_grd_ref_no =
                                                 ash.internal_grd_ref_no) then
                                     pn_qty
                                    else
                                     asm.net_weight
                                  end) net_weight,
                                  pqca.element_id,
                                  pqca.is_elem_for_pricing,
                                  pqca.unit_of_measure,
                                  pqca.payable_percentage,
                                  pqca.typical,
                                  rm.qty_unit_id_numerator,
                                  rm.qty_unit_id_denominator,
                                  rm.ratio_name,
                                  aml.attribute_name,
                                  aml.attribute_desc,
                                  ppm.product_id,
                                  aml.underlying_product_id
                             from ash_assay_header               ash,
                                  asm_assay_sublot_mapping       asm,
                                  aml_attribute_master_list      aml,
                                  pqca_pq_chemical_attributes    pqca,
                                  rm_ratio_master                rm,
                                  ppm_product_properties_mapping ppm
                            where ash.ash_id = pc_assay_header_id
                              and ash.ash_id = asm.ash_id
                              and asm.asm_id = pqca.asm_id
                              and pqca.unit_of_measure = rm.ratio_id
                              and pqca.element_id = aml.attribute_id
                              and ppm.attribute_id = aml.attribute_id
                              and ppm.product_id = pc_product_id
                              and nvl(ppm.deduct_for_wet_to_dry, 'N') = 'Y')
    loop
      vn_item_qty := nvl(cur_deduct_qty.net_weight, pn_qty);
      if cur_deduct_qty.ratio_name = '%' then
        vn_deduct_qty := vn_item_qty * (cur_deduct_qty.typical / 100);
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(pc_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_deduct_qty.qty_unit_id_denominator,
                                                                 vn_item_qty) *
                            cur_deduct_qty.typical;
        vn_deduct_qty    := pkg_general.f_get_converted_quantity(pc_product_id,
                                                                 cur_deduct_qty.qty_unit_id_numerator,
                                                                 pc_qty_unit_id,
                                                                 vn_converted_qty);
      end if;
      vn_deduct_total_qty := vn_deduct_total_qty + vn_deduct_qty;
    end loop;
    return(pn_qty - vn_deduct_total_qty);
  end;

  function fn_deduct_wet_to_dry_qty(pc_product_id                varchar2,
                                    pc_internal_cont_item_ref_no varchar2,
                                    pn_item_qty                  number)
    return number is
  
    vn_deduct_qty       number;
    vn_deduct_total_qty number;
    vn_item_qty         number;
    vn_converted_qty    number;
  begin
    vn_item_qty         := pn_item_qty;
    vn_deduct_qty       := 0;
    vn_deduct_total_qty := 0;
    for cur_deduct_qty in (select rm.ratio_name,
                                  rm.qty_unit_id_numerator,
                                  rm.qty_unit_id_denominator,
                                  pqca.typical,
                                  ppm.product_id,
                                  pci.item_qty_unit_id
                             from ppm_product_properties_mapping ppm,
                                  aml_attribute_master_list      aml,
                                  pqca_pq_chemical_attributes    pqca,
                                  rm_ratio_master                rm,
                                  asm_assay_sublot_mapping       asm,
                                  ash_assay_header               ash,
                                  pcdi_pc_delivery_item          pcdi,
                                  pci_physical_contract_item     pci,
                                  pcpq_pc_product_quality        pcpq
                            where ppm.attribute_id = aml.attribute_id
                              and aml.attribute_id = pqca.element_id
                              and pqca.asm_id = asm.asm_id
                              and pqca.unit_of_measure = rm.ratio_id
                              and asm.ash_id = ash.ash_id
                              and ash.internal_contract_ref_no =
                                  pcdi.internal_contract_ref_no
                              and pcdi.pcdi_id = pci.pcdi_id
                              and pci.pcpq_id = pcpq.pcpq_id
                              and pci.internal_contract_item_ref_no =
                                  pc_internal_cont_item_ref_no
                              and ppm.product_id = pc_product_id
                              and pcpq.assay_header_id = ash.ash_id
                              and ppm.deduct_for_wet_to_dry = 'Y')
    loop
      if cur_deduct_qty.ratio_name = '%' then
        vn_deduct_qty := vn_item_qty * (cur_deduct_qty.typical / 100);
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 cur_deduct_qty.qty_unit_id_denominator,
                                                                 vn_item_qty) *
                            cur_deduct_qty.typical;
        vn_deduct_qty    := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.qty_unit_id_numerator,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 vn_converted_qty);
      
      end if;
      vn_deduct_total_qty := vn_deduct_total_qty + vn_deduct_qty;
    
    end loop;
    return vn_deduct_total_qty;
  end;
  function fn_get_elmt_assay_content_qty(pc_element_id      varchar2,
                                         pc_assay_header_id varchar2,
                                         pn_qty             number,
                                         pc_qty_unit_id     varchar2)
    return number is
    cursor cur_element is
      select pqca.element_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             ash.ash_id,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id,
             pci.internal_contract_item_ref_no,
             pcpd.product_id,
             pcpq.unit_of_measure contract_unit_of_measure
        from ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm,
             pcdi_pc_delivery_item       pcdi,
             pci_physical_contract_item  pci,
             pcpd_pc_product_definition  pcpd,
             pcpq_pc_product_quality     pcpq
       where ash.ash_id = pc_assay_header_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pqca.element_id = pc_element_id
         and ash.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = pci.pcdi_id
         and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.pcpd_id = pcpq.pcpd_id
         and pcpd.input_output = 'Input'
         and ash.is_active = 'Y'
         and asm.is_active = 'Y'
         and pqca.is_active = 'Y'
         and aml.is_active = 'Y'
         and rm.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y';
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
    --pc_ele_qty_string      varchar2(100);
    vn_ele_qty number;
  begin
    for cur_element_rows in cur_element
    loop
      vn_deduct_qty := 0;
      /*if cur_element_rows.contract_unit_of_measure = 'Wet' then
       vn_item_qty:=fn_get_assay_dry_qty(cur_element_rows.product_id,
                                        cur_element_rows.ash_id, 
                                        pn_qty,
                                        pc_qty_unit_id);  
      else
        vn_item_qty := pn_qty;
      end if;*/
      vn_item_qty := pn_qty;
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = pc_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := pc_qty_unit_id;
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
        vn_element_qty   := vn_converted_qty * cur_element_rows.typical;
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      end if;
      vn_ele_qty := vn_element_qty;
    end loop;
    return(vn_ele_qty);
  end;
end; 
/
