create or replace package "PKG_METALS_GENERAL" is
  function fn_deduct_wet_to_dry_qty(pc_product_id                varchar2,
                                    pc_internal_cont_item_ref_no varchar2,
                                    pn_item_qty                  number,
                                    pc_dbd_id                    varchar)
    return number;

  procedure sp_element_position_qty(pc_internal_con_item_ref_no varchar2,
                                    pc_assay_header_id          varchar2,
                                    pc_element_id               varchar2,
                                    pc_dbd_id                   varchar2,
                                    pc_ele_qty_string           out varchar2);

  function fn_element_qty(pc_internal_cont_item_ref_no varchar2,
                          pc_assay_header_id           varchar2,
                          pc_element_id                varchar2,
                          pc_dbd_id                    varchar2)
    return varchar2;

  function fn_get_assay_dry_qty(pc_product_id      varchar2,
                                pc_assay_header_id varchar2,
                                pn_qty             number,
                                pc_qty_unit_id     varchar2) return number;

  procedure sp_get_penalty_charge(pc_inter_cont_item_ref_no varchar2,
                                  -- pc_element_id             varchar2,
                                  pc_dbd_id          varchar2,
                                  pn_penalty_qty     number,
                                  pc_pc_qty_unit_id  varchar2,
                                  pn_total_pc_charge out number,
                                  pc_pc_cur_id       out varchar2);

  procedure sp_get_refine_charge(pc_inter_cont_item_ref_no varchar2,
                                 pc_element_id             varchar2,
                                 pc_dbd_id                 varchar2,
                                 pn_rc_qty                 number,
                                 pc_rc_qty_unit_id         varchar2,
                                 pn_cp_price               number,
                                 pc_cp_unit_id             varchar2,
                                 pn_total_rc_charge        out number,
                                 pc_rc_cur_id              out varchar2);

  procedure sp_get_treatment_charge(pc_inter_cont_item_ref_no varchar2,
                                    pc_element_id             varchar2,
                                    pc_dbd_id                 varchar2,
                                    pn_dry_qty                number,
                                    pn_wet_qty                number,
                                    pc_qty_unit_id            varchar2,
                                    pn_cp_price               number,
                                    pc_cp_unit_id             varchar2,
                                    pn_total_tc_charge        out number,
                                    pc_tc_cur_id              out varchar2);
  function fn_get_next_month_prompt_date(pc_promp_del_cal_id varchar2,
                                         pd_trade_date       date)
    return date;
  procedure sp_get_gmr_treatment_charge(pc_inter_gmr_ref_no varchar2,
                                        pc_inter_grd_ref_no varchar2,
                                        pc_element_id       varchar2,
                                        pc_dbd_id           varchar2,
                                        pn_cp_price         number,
                                        pc_cp_unit_id       varchar2,
                                        pn_total_tc_charge  out number,
                                        pc_tc_cur_id        out varchar2);

  procedure sp_get_gmr_refine_charge(pc_inter_gmr_ref_no varchar2,
                                     pc_inter_grd_ref_no varchar2,
                                     pc_element_id       varchar2,
                                     pc_dbd_id           varchar2,
                                     pn_cp_price         number,
                                     pc_cp_unit_id       varchar2,
                                     pn_total_rc_charge  out number,
                                     pc_rc_cur_id        out varchar2);

  procedure sp_get_gmr_penalty_charge(pc_inter_gmr_ref_no varchar2,
                                      pc_inter_grd_ref_no varchar2,
                                      pc_dbd_id           varchar2,
                                      pc_element_id       varchar2,
                                      pn_total_pc_charge  out number,
                                      pc_pc_cur_id        out varchar2);
end; 
/
create or replace package body "PKG_METALS_GENERAL" is
  function fn_deduct_wet_to_dry_qty(pc_product_id                varchar2,
                                    pc_internal_cont_item_ref_no varchar2,
                                    pn_item_qty                  number,
                                    pc_dbd_id                    varchar)
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
                              and ppm.deduct_for_wet_to_dry = 'Y'
                              and pci.dbd_id = pc_dbd_id
                              and pcdi.dbd_id = pc_dbd_id
                              and pcpq.dbd_id = pc_dbd_id)
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

  procedure sp_element_position_qty(pc_internal_con_item_ref_no varchar2,
                                    pc_assay_header_id          varchar2,
                                    pc_element_id               varchar2,
                                    pc_dbd_id                   varchar2,
                                    pc_ele_qty_string           out varchar2) is
    cursor cur_element is
      select pci.internal_contract_item_ref_no,
             ciqs.open_qty item_qty,
             ciqs.item_qty_unit_id,
             pcpq.unit_of_measure item_unit_of_measure,
             pcpd.product_id,
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
      
        from pci_physical_contract_item    pci,
             ciqs_contract_item_qty_status ciqs,
             pcpq_pc_product_quality       pcpq,
             pcpd_pc_product_definition    pcpd,
             ash_assay_header              ash,
             asm_assay_sublot_mapping      asm,
             aml_attribute_master_list     aml,
             pqca_pq_chemical_attributes   pqca,
             rm_ratio_master               rm
      
       where pci.pcpq_id = pcpq.pcpq_id
         and pci.internal_contract_item_ref_no =
             ciqs.internal_contract_item_ref_no
         and pcpq.assay_header_id = ash.ash_id
         and pcpq.pcpd_id = pcpd.pcpd_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pci.dbd_id = pc_dbd_id
         and pcpq.dbd_id = pc_dbd_id
         and ciqs.dbd_id = pc_dbd_id
         and pcpq.dbd_id = pc_dbd_id
         and pci.internal_contract_item_ref_no =
             pc_internal_con_item_ref_no
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
        vn_deduct_qty := fn_deduct_wet_to_dry_qty(cur_element_rows.product_id,
                                                  cur_element_rows.internal_contract_item_ref_no,
                                                  cur_element_rows.item_qty,
                                                  pc_dbd_id);
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
      
        pc_ele_qty_string := vn_element_qty || '$' || vc_element_qty_unit || '$' ||
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
      
        pc_ele_qty_string := vn_element_qty || '$' || vc_element_qty_unit || '$' ||
                             vc_element_qty_unit_id;
      
      end if;
    end loop;
  end sp_element_position_qty;

  function fn_element_qty(pc_internal_cont_item_ref_no varchar2,
                          pc_assay_header_id           varchar2,
                          pc_element_id                varchar2,
                          pc_dbd_id                    varchar2)
    return varchar2 is
    vn_ele_qty_string varchar2(200);
  begin
    sp_element_position_qty(pc_internal_cont_item_ref_no,
                            pc_assay_header_id,
                            pc_element_id,
                            pc_dbd_id,
                            vn_ele_qty_string);
    return(vn_ele_qty_string);
  end fn_element_qty;

  function fn_get_assay_dry_qty(pc_product_id      varchar2,
                                pc_assay_header_id varchar2,
                                pn_qty             number,
                                pc_qty_unit_id     varchar2) return number is
    vn_deduct_qty       number;
    vn_deduct_total_qty number;
    vn_item_qty         number;
    vn_converted_qty    number;
  begin
    vn_item_qty         := pn_qty;
    vn_deduct_qty       := 0;
    vn_deduct_total_qty := 0;
    for cur_deduct_qty in (select ash.ash_id,
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
    return(vn_item_qty - vn_deduct_total_qty);
  end;

  procedure sp_get_penalty_charge(pc_inter_cont_item_ref_no varchar2,
                                  pc_dbd_id                 varchar2,
                                  pn_penalty_qty            number,
                                  pc_pc_qty_unit_id         varchar2,
                                  pn_total_pc_charge        out number,
                                  pc_pc_cur_id              out varchar2) is
    vn_penalty_charge      number;
    vc_penalty_weight_type varchar2(20);
    vn_max_range           number;
    vn_min_range           number;
    vn_typical_val         number := 0;
    vn_converted_qty       number;
    vn_element_pc_charge   number;
    vn_range_gap           number;
    vn_tier_penalty        number;
    vc_price_unit_id       varchar2(15);
    vc_cur_id              varchar2(15);
  begin
    vn_penalty_charge    := 0;
    vn_element_pc_charge := 0;
    vn_tier_penalty      := 0;
    pn_total_pc_charge   := 0;
    --Take all the Elements associated with the conttract.
    for cc in (select pci.item_qty,
                      pqca.element_id,
                      pqca.typical,
                      rm.qty_unit_id_denominator,
                      rm.qty_unit_id_numerator,
                      rm.ratio_name,
                      pci.item_qty_unit_id,
                      aml.underlying_product_id,
                      pcpd.unit_of_measure,
                      asm.asm_id,
                      pci.pcpq_id,
                      pci.pcdi_id
                 from pcpd_pc_product_definition  pcpd,
                      pcpq_pc_product_quality     pcpq,
                      pqca_pq_chemical_attributes pqca,
                      ash_assay_header            ash,
                      asm_assay_sublot_mapping    asm,
                      pci_physical_contract_item  pci,
                      pcdi_pc_delivery_item       pcdi,
                      aml_attribute_master_list   aml,
                      qum_quantity_unit_master    qum,
                      rm_ratio_master             rm
                where pci.pcdi_id = pcdi.pcdi_id
                  and pci.pcpq_id = pcpq.pcpq_id
                  and pcpq.pcpd_id = pcpd.pcpd_id
                  and pcpq.assay_header_id = ash.ash_id
                  and pqca.asm_id = asm.asm_id
                  and asm.ash_id = ash.ash_id
                  and ash.assay_type = 'Contractual Assay'
                  and pci.internal_contract_item_ref_no =
                      pc_inter_cont_item_ref_no
                  and pcpd.dbd_id = pc_dbd_id
                  and pcpq.dbd_id = pc_dbd_id
                  and pci.dbd_id = pc_dbd_id
                  and pcdi.dbd_id = pc_dbd_id
                  and aml.attribute_id = pqca.element_id
                  and qum.qty_unit_id = pci.item_qty_unit_id
                     --   and pqca.element_id = pc_element_id
                  and nvl(pqca.is_elem_for_pricing, 'N') = 'N'
                  and rm.ratio_id = pqca.unit_of_measure
                  and pcdi.is_active = 'Y'
                  and pci.is_active = 'Y'
                  and aml.is_active = 'Y'
                  and pqca.is_active = 'Y'
                  and pcdi.is_active = 'Y')
    loop
      vn_element_pc_charge := 0;
      vn_tier_penalty      := 0;
      --Passing each element which is getting  from the outer loop.
      --and checking ,is it non payable or not.
      for cur_pc_charge in (select pcap.penalty_charge_type,
                                   pcap.penalty_basis,
                                   pcap.penalty_amount,
                                   pcap.range_min_value,
                                   pcap.range_max_value,
                                   pcap.range_min_op,
                                   pcap.range_max_op,
                                   pcap.position,
                                   pcap.charge_basis,
                                   pcap.penalty_weight_type,
                                   pcap.pcaph_id,
                                   pcaph.slab_tier,
                                   pum.price_unit_id,
                                   pum.cur_id,
                                   pum.weight_unit_id
                              from pcaph_pc_attr_penalty_header  pcaph,
                                   pcap_pc_attribute_penalty     pcap,
                                   pqd_penalty_quality_details   pqd,
                                   pad_penalty_attribute_details pad,
                                   diph_di_penalty_header        diph,
                                   ppu_product_price_units       ppu,
                                   pum_price_unit_master         pum
                             where pcaph.pcaph_id = pcap.pcaph_id
                               and pcaph.pcaph_id = pqd.pcaph_id
                               and pcaph.pcaph_id = pad.pcaph_id
                               and pcaph.pcaph_id = diph.pcaph_id
                               and pqd.pcpq_id = cc.pcpq_id
                               and diph.pcdi_id = cc.pcdi_id
                               and pcaph.dbd_id = pc_dbd_id
                               and pcap.dbd_id = pc_dbd_id
                               and pqd.dbd_id = pc_dbd_id
                               and pad.dbd_id = pc_dbd_id
                               and diph.dbd_id = pc_dbd_id
                               and pcaph.is_active = 'Y'
                               and pcap.is_active = 'Y'
                               and pqd.is_active = 'Y'
                               and pad.is_active = 'Y'
                               and diph.is_active = 'Y'
                               and pad.element_id = cc.element_id
                               and pcap.penalty_unit_id =
                                   ppu.internal_price_unit_id
                               and ppu.price_unit_id = pum.price_unit_id
                               and (pcap.range_max_value > cc.typical or
                                   pcap.position = 'Range End')
                               and (pcap.range_min_value <= cc.typical or
                                   pcap.position = 'Range Begining'))
      loop
        vc_price_unit_id     := cur_pc_charge.price_unit_id;
        vc_cur_id            := cur_pc_charge.cur_id;
        vn_element_pc_charge := 0;
        --check the penalty charge type
        if cur_pc_charge.penalty_charge_type = 'Fixed' then
          vc_penalty_weight_type := cur_pc_charge.penalty_weight_type;
          --Find the PC charge which will fall in the appropriate range.
          --as according to the typical value   
          if (cur_pc_charge.range_min_value <= cc.typical or
             cur_pc_charge.position = 'Range Begining') and
             (cur_pc_charge.range_max_value > cc.typical or
             cur_pc_charge.position = 'Range End') then
          
            vn_penalty_charge := cur_pc_charge.penalty_amount;
            vn_max_range      := cur_pc_charge.range_max_value;
            vn_min_range      := cur_pc_charge.range_min_value;
            vn_typical_val    := cc.typical;
          
            vn_converted_qty := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                     pc_pc_qty_unit_id,
                                                                     cur_pc_charge.weight_unit_id,
                                                                     pn_penalty_qty);
          
            vn_element_pc_charge := vn_penalty_charge * vn_converted_qty;
          end if;
        elsif cur_pc_charge.penalty_charge_type = 'Variable' then
          if cur_pc_charge.penalty_basis = 'Quantity' and
             cur_pc_charge.slab_tier = 'Tier' then
            vn_typical_val := cc.typical;
            --find the range where the typical falls in 
            if (cur_pc_charge.range_min_value <= vn_typical_val or
               cur_pc_charge.position = 'Range Begining') and
               (cur_pc_charge.range_max_value > vn_typical_val or
               cur_pc_charge.position = 'Range End') then
              --Finding all the  assay range form the start range to  last range 
              --for the different Tier basics ,assording to the typicla value
              for cur_range in (select nvl(pcap.range_min_value, 0) min_range,
                                       pcap.range_max_value max_range,
                                       pcap.penalty_amount,
                                       pcap.per_increase_value
                                  from pcap_pc_attribute_penalty pcap
                                 where nvl(pcap.range_min_value, 0) <=
                                       vn_typical_val
                                   and pcap.pcaph_id =
                                       cur_pc_charge.pcaph_id
                                   and pcap.dbd_id = pc_dbd_id)
              loop
                --for half range
                if vn_typical_val > 0 then
                  if cur_range.min_range < vn_typical_val and
                     nvl(cur_range.max_range, vn_typical_val + 1) >
                     vn_typical_val then
                    vn_penalty_charge := cur_range.penalty_amount;
                    vn_range_gap      := vn_typical_val -
                                         cur_range.min_range;
                    --for full range                 
                  elsif cur_range.min_range <= vn_typical_val and
                        cur_range.max_range <= vn_typical_val then
                    vn_penalty_charge := cur_range.penalty_amount;
                    vn_range_gap      := cur_range.max_range -
                                         cur_range.min_range;
                  end if;
                end if;
                --get the  qty according to the dry or wet
                --penalty is applyed on the item qty not on the penalty qty
                /* dbms_output.put_line('Range %  is ' || cur_range.min_range || '-' ||
                                     cur_range.max_range);
                dbms_output.put_line(' Typical value is   ' ||
                                     vn_typical_val);
                dbms_output.put_line('Range Gap is ' || vn_range_gap);
                dbms_output.put_line(' Item Qty is  ' || cc.item_qty);
                
                dbms_output.put_line(' Base Penalty charge for this ' ||
                                     vn_penalty_charge);
                dbms_output.put_line(' Variable  Penalty charge formula is  ' ||
                                     vn_penalty_charge || '*(' ||
                                     vn_range_gap || '/' ||
                                     cur_range.per_increase_value || ')');*/
                if cur_pc_charge.charge_basis = 'absolute' then
                  vn_penalty_charge := ceil(vn_range_gap /
                                            cur_range.per_increase_value) *
                                       vn_penalty_charge;
                elsif cur_pc_charge.charge_basis = 'fractions Pro-Rata' then
                  vn_penalty_charge := (vn_range_gap /
                                       cur_range.per_increase_value) *
                                       vn_penalty_charge;
                end if;
                vn_tier_penalty := vn_tier_penalty + vn_penalty_charge;
                /** vn_range_gap;*/
              /* dbms_output.put_line(' Variable  Penalty charge for this ' ||
                                                   vn_penalty_charge);
                              dbms_output.put_line('---------------------------');*/
              --calculate total Penalty charge
              end loop;
            end if;
          elsif cur_pc_charge.penalty_basis = 'Payable Content' then
            --Take the payable content qty from the table and 
            --find the penalty But for the time being this feature is not applied
            null;
          end if;
          --vn_penalty_qty :=  pn_penalty_qty;
          /*if cur_pc_charge.penalty_weight_type = 'Wet' then
            vn_penalty_qty := cc.item_qty;
          elsif cur_pc_charge.penalty_weight_type = 'Dry' then
            vn_penalty_qty := fn_deduct_wet_to_dry_qty(pc_inter_cont_item_ref_no,
                                                      cc.item_qty,
                                                      pc_dbd_id);
          end if;*/
          --Penalty Charge is applyed on the item wise not on the element  wise
          --This item qty may be dry or wet
          vn_converted_qty := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                   pc_pc_qty_unit_id,
                                                                   cur_pc_charge.weight_unit_id,
                                                                   pn_penalty_qty);
          --Here no need of the typical value as penalty is on item level  
          vn_element_pc_charge := vn_tier_penalty * vn_converted_qty;
          /*  dbms_output.put_line('vn_element_pc_charge' ||
          vn_element_pc_charge);*/
        end if;
      end loop;
      pn_total_pc_charge := pn_total_pc_charge + vn_element_pc_charge;
    end loop;
  
    pc_pc_cur_id := vc_cur_id;
  exception
    when others then
      pn_total_pc_charge := -1;
      pc_pc_cur_id       := null;
  end;

  procedure sp_get_refine_charge(pc_inter_cont_item_ref_no varchar2,
                                 pc_element_id             varchar2,
                                 pc_dbd_id                 varchar2,
                                 pn_rc_qty                 number,
                                 pc_rc_qty_unit_id         varchar2,
                                 pn_cp_price               number,
                                 pc_cp_unit_id             varchar2,
                                 pn_total_rc_charge        out number,
                                 pc_rc_cur_id              out varchar2) is
    vn_refine_charge       number;
    vn_item_qty            number;
    vn_element_qty         number;
    vc_price_unit_id       varchar2(100);
    vn_tot_refine_charge   number;
    vn_max_range           number;
    vn_typical_val         number;
    vn_contract_price      number;
    vn_min_range           number;
    vn_base_refine_charge  number;
    vn_range_gap           number;
    vn_each_tier_rc_charge number;
    vc_cur_id              varchar2(10);
    vc_rc_weight_unit_id   varchar2(15);
    vn_pricable_qty        number;
    vc_include_ref_charge  char(1);
  begin
    vn_refine_charge  := 0;
    vn_contract_price := pn_cp_price;
    for cc in (select pci.item_qty,
                      pqca.element_id,
                      pqca.typical,
                      rm.qty_unit_id_denominator,
                      rm.qty_unit_id_numerator,
                      rm.ratio_name,
                      pci.item_qty_unit_id,
                      aml.underlying_product_id,
                      pcpd.unit_of_measure,
                      asm.asm_id,
                      pci.pcpq_id,
                      pci.pcdi_id,
                      pcdi.internal_contract_ref_no,
                      pci.internal_contract_item_ref_no
                 from pcpd_pc_product_definition  pcpd,
                      pcpq_pc_product_quality     pcpq,
                      pqca_pq_chemical_attributes pqca,
                      ash_assay_header            ash,
                      asm_assay_sublot_mapping    asm,
                      pci_physical_contract_item  pci,
                      pcdi_pc_delivery_item       pcdi,
                      aml_attribute_master_list   aml,
                      qum_quantity_unit_master    qum,
                      rm_ratio_master             rm
                where pci.pcdi_id = pcdi.pcdi_id
                  and pci.pcpq_id = pcpq.pcpq_id
                  and pcpq.pcpd_id = pcpd.pcpd_id
                  and pcpq.assay_header_id = ash.ash_id
                  and pqca.asm_id = asm.asm_id
                  and asm.ash_id = ash.ash_id
                  and pcpd.dbd_id = pc_dbd_id
                  and pcpq.dbd_id = pc_dbd_id
                  and pci.dbd_id = pc_dbd_id
                  and pcdi.dbd_id = pc_dbd_id
                  and ash.assay_type = 'Contractual Assay'
                  and pci.internal_contract_item_ref_no =
                      pc_inter_cont_item_ref_no
                  and aml.attribute_id = pqca.element_id
                  and qum.qty_unit_id = pci.item_qty_unit_id
                  and pqca.element_id = pc_element_id
                  and rm.ratio_id = pqca.unit_of_measure
                  and pcdi.is_active = 'Y'
                  and pci.is_active = 'Y'
                  and pqca.is_active = 'Y'
                  and pcdi.is_active = 'Y')
    loop
      --for refine charge , the charge will applyed on
      --payable qty only.So deduct the moisture and other deductable item 
      --from the item qty.
    
      vn_item_qty := pn_rc_qty;
    
      begin
        select pcepc.include_ref_charges
          into vc_include_ref_charge
          from pcm_physical_contract_main     pcm,
               pcpch_pc_payble_content_header pcpch,
               pcepc_pc_elem_payable_content  pcepc
         where pcm.internal_contract_ref_no =
               pcpch.internal_contract_ref_no
           and pcpch.pcpch_id = pcepc.pcpch_id
           and pcm.dbd_id = pc_dbd_id
           and pcpch.dbd_id = pc_dbd_id
           and pcepc.dbd_id = pc_dbd_id
           and pcpch.element_id = cc.element_id
           and pcm.internal_contract_ref_no = cc.internal_contract_ref_no
           and (pcepc.range_min_value <= cc.typical or
               pcepc.position = 'Range Begining')
           and (pcepc.range_max_value > cc.typical or
               pcepc.position = 'Range End')
           and pcm.is_active = 'Y'
           and pcpch.is_active = 'Y'
           and pcepc.is_active = 'Y';
      exception
        when no_data_found then
          vc_include_ref_charge := 'N';
      end;
    
      if vc_include_ref_charge = 'Y' then
        begin
          for cur_ref_charge in (select pcpch.pcpch_id,
                                        pcepc.range_max_op,
                                        pcepc.range_max_value,
                                        pcepc.range_min_op,
                                        pcepc.range_min_value,
                                        pcepc.position,
                                        pcepc.refining_charge_value,
                                        pcepc.refining_charge_unit_id,
                                        pum.cur_id,
                                        pum.price_unit_id,
                                        pum.weight_unit_id
                                   from pcm_physical_contract_main     pcm,
                                        pcdi_pc_delivery_item          pcdi,
                                        pci_physical_contract_item     pci,
                                        pcpch_pc_payble_content_header pcpch,
                                        pcepc_pc_elem_payable_content  pcepc,
                                        ppu_product_price_units        ppu,
                                        pum_price_unit_master          pum
                                  where pcm.internal_contract_ref_no =
                                        pcdi.internal_contract_ref_no
                                    and pcdi.pcdi_id = pci.pcdi_id
                                    and pcm.internal_contract_ref_no =
                                        pcpch.internal_contract_ref_no
                                    and pcpch.element_id = cc.element_id
                                    and pcpch.pcpch_id = pcepc.pcpch_id
                                    and pcepc.include_ref_charges = 'Y'
                                    and ppu.internal_price_unit_id =
                                        pcepc.refining_charge_unit_id
                                    and ppu.price_unit_id =
                                        pum.price_unit_id
                                    and pci.internal_contract_item_ref_no =
                                        cc.internal_contract_item_ref_no
                                    and pci.dbd_id = pc_dbd_id
                                    and pcdi.dbd_id = pc_dbd_id
                                    and pcm.dbd_id = pc_dbd_id
                                    and pcpch.dbd_id = pc_dbd_id
                                    and pcepc.dbd_id = pc_dbd_id
                                    and pci.is_active = 'Y'
                                    and pcm.is_active = 'Y'
                                    and pcdi.is_active = 'Y'
                                    and pcpch.is_active = 'Y'
                                    and pcepc.is_active = 'Y')
          loop
            vc_rc_weight_unit_id := cur_ref_charge.weight_unit_id;
            vc_cur_id            := cur_ref_charge.cur_id;
            vc_price_unit_id     := cur_ref_charge.price_unit_id;
          
            if (cur_ref_charge.range_min_value <= cc.typical or
               cur_ref_charge.position = 'Range Begining') and
               (cur_ref_charge.range_max_value > cc.typical or
               cur_ref_charge.position = 'Range End') then
              vn_refine_charge := cur_ref_charge.refining_charge_value;
            end if;
          end loop;
        exception
          when others then
            vn_refine_charge := 0;
            vc_price_unit_id := null;
        end;
      
      else
      
        /*if cc.unit_of_measure = 'Wet' then
          vn_item_qty := cc.item_qty;
        else
          total_deduct_qty := fn_deduct_wet_to_dry_qty(pc_inter_cont_item_ref_no,
                                                      vn_item_qty,
                                                      pc_dbd_id);
          vn_item_qty      := vn_item_qty - total_deduct_qty;
        end if;*/
        /*dbms_output.put_line('The Contract item Quantity is  ' || vn_item_qty);
        dbms_output.put_line('The Contract item Quantity unit id  is  ' ||
                             cc.item_qty_unit_id);
        dbms_output.put_line('The Contract item Element  id  ' ||
                             cc.element_id);
        dbms_output.put_line('The Contract item Element  typical is  ' ||
                             cc.typical || cc.ratio_name);*/
        begin
          for cur_ref_charge in (select pcrh.range_type,
                                        pcerc.refining_charge,
                                        pcerc.refining_charge_unit_id,
                                        pcerc.charge_type,
                                        pcerc.charge_basis,
                                        pcerc.position,
                                        pcerc.range_min_op,
                                        pcerc.range_min_value,
                                        pcerc.range_max_op,
                                        pcerc.range_max_value,
                                        pcrh.pcrh_id,
                                        pum.cur_id,
                                        pum.price_unit_id,
                                        pum.weight_unit_id
                                   from pcrh_pc_refining_header       pcrh,
                                        red_refining_element_details  red,
                                        pcerc_pc_elem_refining_charge pcerc,
                                        rqd_refining_quality_details  rqd,
                                        dirh_di_refining_header       dirh,
                                        ppu_product_price_units       ppu,
                                        pum_price_unit_master         pum
                                  where pcrh.pcrh_id = red.pcrh_id
                                    and pcrh.pcrh_id = pcerc.pcrh_id
                                    and pcrh.pcrh_id = rqd.pcrh_id
                                    and pcrh.pcrh_id = dirh.pcrh_id
                                    and rqd.pcpq_id = cc.pcpq_id
                                    and dirh.pcdi_id = cc.pcdi_id
                                    and pcrh.dbd_id = pc_dbd_id
                                    and red.dbd_id = pc_dbd_id
                                    and pcerc.dbd_id = pc_dbd_id
                                    and rqd.dbd_id = pc_dbd_id
                                    and dirh.dbd_id = pc_dbd_id
                                    and red.element_id = cc.element_id
                                    and ppu.internal_price_unit_id =
                                        pcerc.refining_charge_unit_id
                                    and ppu.price_unit_id =
                                        pum.price_unit_id
                                    and pcerc.is_active = 'Y'
                                    and pcrh.is_active = 'Y'
                                    and red.is_active = 'Y'
                                    and rqd.is_active = 'Y'
                                    and dirh.is_active = 'Y'
                                  order by range_min_value)
          loop
            vc_rc_weight_unit_id := cur_ref_charge.weight_unit_id;
            vc_cur_id            := cur_ref_charge.cur_id;
            vc_price_unit_id     := cur_ref_charge.price_unit_id;
            if cur_ref_charge.range_type = 'Price Range' then
              --if the CHARGE_TYPE is fixed then it will
              --behave as the slab as same as the assay range
              --No base concept is here
              if cur_ref_charge.charge_type = 'Fixed' then
                if (cur_ref_charge.range_min_value <= vn_contract_price or
                   cur_ref_charge.position = 'Range Begining') and
                   (cur_ref_charge.range_max_value >= vn_contract_price or
                   cur_ref_charge.position = 'Range End') then
                  vn_refine_charge := cur_ref_charge.refining_charge;
                  dbms_output.put_line(vn_refine_charge);
                end if;
              elsif cur_ref_charge.charge_type = 'Variable' then
                --Take the base price and its min and max range
                begin
                  select pcerc.range_min_value,
                         pcerc.range_max_value,
                         pcerc.refining_charge
                    into vn_min_range,
                         vn_max_range,
                         vn_base_refine_charge
                    from pcerc_pc_elem_refining_charge pcerc
                   where pcerc.pcrh_id = cur_ref_charge.pcrh_id
                     and pcerc.position = 'Base'
                     and pcerc.charge_type = 'Variable'
                     and pcerc.dbd_id = pc_dbd_id;
                exception
                  when no_data_found then
                    vn_min_range          := 0;
                    vn_max_range          := 0;
                    vn_base_refine_charge := 0;
                end;
                --according to the contract price , the price tier 
                --will be find out, it may forward or back ward
                --Both vn_max_range and vn_min_range are same in case if base
                if vn_contract_price > vn_max_range then
                  --go forward for the price range
                  vn_refine_charge := vn_base_refine_charge;
                  for cur_forward_price in (select pcerc.range_min_value,
                                                   pcerc.range_min_op,
                                                   pcerc.range_max_value,
                                                   pcerc.range_max_op,
                                                   pcerc.esc_desc_value,
                                                   pcerc.esc_desc_unit_id,
                                                   pcerc.refining_charge,
                                                   pcerc.refining_charge_unit_id,
                                                   pcerc.charge_basis
                                              from pcerc_pc_elem_refining_charge pcerc
                                             where pcerc.pcrh_id =
                                                   cur_ref_charge.pcrh_id
                                               and nvl(pcerc.range_min_value,
                                                       0) <
                                                   vn_contract_price
                                               and nvl(pcerc.range_min_value,
                                                       0) >= vn_min_range
                                               and nvl(pcerc.position, 'a') <>
                                                   'Base'
                                               and pcerc.dbd_id = pc_dbd_id)
                  loop
                    --for full Range
                    if cur_forward_price.range_max_value <=
                       vn_contract_price then
                      vn_range_gap := cur_forward_price.range_max_value -
                                      cur_forward_price.range_min_value;
                    elsif nvl(cur_forward_price.range_max_value,
                              vn_contract_price + 1) > vn_contract_price then
                      --For the Half  Range 
                      vn_range_gap := vn_contract_price -
                                      cur_forward_price.range_min_value;
                    end if;
                    /* vn_each_tier_rc_charge := (vn_range_gap /
                                              nvl(cur_forward_price.esc_desc_value,
                                                   1)) *
                                              cur_forward_price.refining_charge;
                    vn_refine_charge       := vn_refine_charge +
                                              vn_each_tier_rc_charge;*/
                    --
                    if cur_forward_price.charge_basis = 'absolute' then
                      vn_each_tier_rc_charge := ceil(vn_range_gap /
                                                     nvl(cur_forward_price.esc_desc_value,
                                                         1)) *
                                                cur_forward_price.refining_charge;
                    elsif cur_forward_price.charge_basis =
                          'fractions Pro-Rata' then
                      vn_each_tier_rc_charge := (vn_range_gap /
                                                nvl(cur_forward_price.esc_desc_value,
                                                     1)) *
                                                cur_forward_price.refining_charge;
                    end if;
                    vn_refine_charge := vn_refine_charge +
                                        vn_each_tier_rc_charge;
                    --
                  end loop;
                elsif vn_contract_price < vn_min_range then
                  --go back ward for the price range
                  vn_refine_charge := vn_base_refine_charge;
                  for cur_backward_price in (select nvl(pcerc.range_min_value,
                                                        0) range_min_value,
                                                    pcerc.range_min_op,
                                                    pcerc.range_max_value,
                                                    pcerc.range_max_op,
                                                    pcerc.esc_desc_value,
                                                    pcerc.esc_desc_unit_id,
                                                    pcerc.refining_charge,
                                                    pcerc.refining_charge_unit_id,
                                                    pcerc.charge_basis
                                               from pcerc_pc_elem_refining_charge pcerc
                                              where pcerc.pcrh_id =
                                                    cur_ref_charge.pcrh_id
                                                and nvl(pcerc.range_min_value,
                                                        0) <
                                                    vn_contract_price
                                                and nvl(pcerc.range_min_value,
                                                        0) <= vn_min_range
                                                and nvl(pcerc.position, 'a') <>
                                                    'Base'
                                                and pcerc.dbd_id = pc_dbd_id)
                  loop
                    --For the full Range 
                    if cur_backward_price.range_max_value <=
                       vn_contract_price then
                      vn_range_gap := cur_backward_price.range_max_value -
                                      cur_backward_price.range_min_value;
                    elsif cur_backward_price.range_max_value >
                          vn_contract_price then
                      --For the Half  Range 
                      vn_range_gap := vn_contract_price -
                                      cur_backward_price.range_min_value;
                    end if;
                    if cur_backward_price.charge_basis = 'absolute' then
                      vn_each_tier_rc_charge := ceil(vn_range_gap /
                                                     nvl(cur_backward_price.esc_desc_value,
                                                         1)) *
                                                cur_backward_price.refining_charge;
                    elsif cur_backward_price.charge_basis =
                          'fractions Pro-Rata' then
                      vn_each_tier_rc_charge := (vn_range_gap /
                                                nvl(cur_backward_price.esc_desc_value,
                                                     1)) *
                                                cur_backward_price.refining_charge;
                    end if;
                    vn_refine_charge := vn_refine_charge +
                                        vn_each_tier_rc_charge;
                  end loop;
                elsif vn_contract_price = vn_min_range and
                      vn_contract_price = vn_max_range then
                  vn_refine_charge := vn_base_refine_charge;
                  --take the base price only            
                end if;
              end if;
            elsif cur_ref_charge.range_type = 'Assay Range' then
              --Make sure the range for the element is mentation properly.
              if (cur_ref_charge.range_min_value <= cc.typical or
                 cur_ref_charge.position = 'Range Begining') and
                 (cur_ref_charge.range_max_value > cc.typical or
                 cur_ref_charge.position = 'Range End') then
                vn_refine_charge := cur_ref_charge.refining_charge;
                vn_max_range     := cur_ref_charge.range_max_value;
                vn_min_range     := cur_ref_charge.range_min_value;
                vn_typical_val   := cc.typical;
              end if;
            end if;
            --I will exit from the loop when it is tier base ,
            --as the inner loop is done the calculation.
            if cur_ref_charge.range_type = 'Price Range' and
               cur_ref_charge.charge_type = 'Variable' then
              exit;
            end if;
          end loop;
          dbms_output.put_line('The typical value is  ' || vn_typical_val);
          dbms_output.put_line('The Assay Range Applicable for this typical is ' ||
                               vn_min_range || ' --' || vn_max_range);
          dbms_output.put_line('The Refine charge for this assay Range is  ' ||
                               vn_refine_charge);
        exception
          when others then
            vn_refine_charge := 0;
            vc_price_unit_id := null;
        end;
        --Find ing element quantity  form the concentrate.
        --After that the RC will multiply on that amount.
        --Refine charge is applyed on element wise
      
        /*if cc.ratio_name = '%' then
          vn_element_qty           := round(vn_item_qty * (cc.typical / 100),
                                            4);
          vc_qty_unit_id_numerator := pc_rc_qty_unit_id;
        else
          vn_converted_qty         := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                           pc_rc_qty_unit_id,
                                                                           cc.qty_unit_id_denominator,
                                                                           vn_item_qty);
          vn_element_qty           := vn_converted_qty * cc.typical;
          vc_qty_unit_id_numerator := cc.qty_unit_id_numerator;
        end if;*/
      end if;
    
      vn_pricable_qty      := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                   pc_rc_qty_unit_id,
                                                                   vc_rc_weight_unit_id,
                                                                   vn_item_qty);
      vn_tot_refine_charge := vn_pricable_qty * vn_refine_charge;
      dbms_output.put_line('The refine  quantity is ' || vn_element_qty);
    end loop;
    pn_total_rc_charge := vn_tot_refine_charge;
    pc_rc_cur_id       := vc_cur_id;
  
  exception
    when others then
      vn_tot_refine_charge := -1;
      vc_price_unit_id     := null;
    
  end;

  procedure sp_get_treatment_charge(pc_inter_cont_item_ref_no varchar2,
                                    pc_element_id             varchar2,
                                    pc_dbd_id                 varchar2,
                                    pn_dry_qty                number,
                                    pn_wet_qty                number,
                                    pc_qty_unit_id            varchar2,
                                    pn_cp_price               number,
                                    pc_cp_unit_id             varchar2,
                                    pn_total_tc_charge        out number,
                                    pc_tc_cur_id              out varchar2) is
    vn_treatment_charge    number;
    vn_total_treat_charge  number;
    vn_item_qty            number;
    vn_max_range           number;
    vn_min_range           number;
    vn_typical_val         number;
    vc_weight_type         varchar2(20);
    vn_contract_price      number;
    vn_base_tret_charge    number;
    vn_each_tier_tc_charge number;
    vn_range_gap           number;
    vc_price_unit_id       varchar2(10);
    vc_cur_id              varchar2(10);
    vn_converted_qty       number;
    vc_rc_weight_unit_id   varchar2(15);
  begin
    vn_contract_price   := pn_cp_price;
    vn_treatment_charge := 0;
    for cc in (select pci.item_qty,
                      pci.item_qty_unit_id,
                      pqca.element_id,
                      pqca.typical,
                      rm.qty_unit_id_numerator,
                      rm.qty_unit_id_denominator,
                      rm.ratio_name,
                      aml.underlying_product_id,
                      pcpd.unit_of_measure,
                      pci.pcpq_id,
                      pci.pcdi_id
                 from pci_physical_contract_item  pci,
                      pcdi_pc_delivery_item       pcdi,
                      pcpd_pc_product_definition  pcpd,
                      pcpq_pc_product_quality     pcpq,
                      pqca_pq_chemical_attributes pqca,
                      ash_assay_header            ash,
                      asm_assay_sublot_mapping    asm,
                      aml_attribute_master_list   aml,
                      qum_quantity_unit_master    qum,
                      rm_ratio_master             rm
                where pci.pcdi_id = pcdi.pcdi_id
                  and pci.pcpq_id = pcpq.pcpq_id
                  and pcpq.pcpd_id = pcpd.pcpd_id
                  and pci.dbd_id = pc_dbd_id
                  and pcdi.dbd_id = pc_dbd_id
                  and pcpd.dbd_id = pc_dbd_id
                  and pcpq.dbd_id = pc_dbd_id
                  and pcpq.assay_header_id = ash.ash_id
                  and pqca.asm_id = asm.asm_id
                  and asm.ash_id = ash.ash_id
                  and ash.assay_type = 'Contractual Assay'
                  and pci.internal_contract_item_ref_no =
                      pc_inter_cont_item_ref_no
                  and aml.attribute_id = pqca.element_id
                  and qum.qty_unit_id = pci.item_qty_unit_id
                  and pqca.element_id = pc_element_id
                  and rm.ratio_id = pqca.unit_of_measure)
    loop
      begin
        for cur_tret_charge in (select pcth.range_type,
                                       pcetc.treatment_charge,
                                       pcetc.treatment_charge_unit_id,
                                       pcetc.charge_type,
                                       pcetc.charge_basis,
                                       pcetc.weight_type,
                                       pcetc.position,
                                       pcetc.range_min_op,
                                       nvl(pcetc.range_min_value, 0) range_min_value,
                                       pcetc.range_max_op,
                                       pcetc.range_max_value,
                                       pcth.pcth_id,
                                       pum.price_unit_id,
                                       pum.cur_id,
                                       pum.weight_unit_id
                                  from pcth_pc_treatment_header       pcth,
                                       ted_treatment_element_details  red,
                                       pcetc_pc_elem_treatment_charge pcetc,
                                       tqd_treatment_quality_details  tqd,
                                       dith_di_treatment_header       dith,
                                       ppu_product_price_units        ppu,
                                       pum_price_unit_master          pum
                                 where pcth.pcth_id = red.pcth_id
                                   and pcth.pcth_id = pcetc.pcth_id
                                   and pcth.pcth_id = tqd.pcth_id
                                   and pcth.pcth_id = dith.pcth_id
                                   and tqd.pcpq_id = cc.pcpq_id
                                   and dith.pcdi_id = cc.pcdi_id
                                   and pcth.dbd_id = pc_dbd_id
                                   and red.dbd_id = pc_dbd_id
                                   and pcetc.dbd_id = pc_dbd_id
                                   and tqd.dbd_id = pc_dbd_id
                                   and dith.dbd_id = pc_dbd_id
                                   and red.element_id = cc.element_id
                                   and pcetc.treatment_charge_unit_id =
                                       ppu.internal_price_unit_id
                                   and ppu.price_unit_id = pum.price_unit_id
                                   and pcetc.is_active = 'Y'
                                   and pcth.is_active = 'Y'
                                   and red.is_active = 'Y'
                                   and tqd.is_active = 'Y'
                                   and dith.is_active = 'Y')
        loop
          vc_cur_id            := cur_tret_charge.cur_id;
          vc_price_unit_id     := cur_tret_charge.price_unit_id;
          vc_rc_weight_unit_id := cur_tret_charge.weight_unit_id;
          vc_weight_type       := cur_tret_charge.weight_type;
          if cur_tret_charge.range_type = 'Price Range' then
            --if the CHARGE_TYPE is fixed then it will
            --behave as the slab as same as the assay range
            --No base concept is here
            if cur_tret_charge.charge_type = 'Fixed' then
              if (cur_tret_charge.range_min_value <= vn_contract_price or
                 cur_tret_charge.position = 'Range Begining') and
                 (cur_tret_charge.range_max_value >= vn_contract_price or
                 cur_tret_charge.position = 'Range End') then
                vn_treatment_charge := cur_tret_charge.treatment_charge;
                dbms_output.put_line(vn_treatment_charge);
              end if;
            elsif cur_tret_charge.charge_type = 'Variable' then
              --Take the base price and its min and max range
              begin
                select pcetc.range_min_value,
                       pcetc.range_max_value,
                       pcetc.treatment_charge
                  into vn_min_range,
                       vn_max_range,
                       vn_base_tret_charge
                  from pcetc_pc_elem_treatment_charge pcetc
                 where pcetc.pcth_id = cur_tret_charge.pcth_id
                   and pcetc.position = 'Base'
                   and pcetc.charge_type = 'Variable'
                   and pcetc.dbd_id = pc_dbd_id;
              exception
                when no_data_found then
                  vn_max_range        := 0;
                  vn_min_range        := 0;
                  vn_base_tret_charge := 0;
              end;
              --according to the contract price , the price tier 
              --will be find out, it may forward or back ward
              --Both vn_max_range and vn_min_range are same 
              --in case if base
              if vn_contract_price > vn_max_range then
                vn_treatment_charge := vn_base_tret_charge;
                --go forward for the price range
                for cur_forward_price in (select pcetc.range_min_value,
                                                 pcetc.range_min_op,
                                                 pcetc.range_max_value,
                                                 pcetc.range_max_op,
                                                 pcetc.esc_desc_value,
                                                 pcetc.esc_desc_unit_id,
                                                 pcetc.treatment_charge,
                                                 pcetc.treatment_charge_unit_id,
                                                 pcetc.charge_basis
                                            from pcetc_pc_elem_treatment_charge pcetc
                                           where pcetc.pcth_id =
                                                 cur_tret_charge.pcth_id
                                             and nvl(pcetc.range_min_value,
                                                     0) < vn_contract_price
                                             and nvl(pcetc.range_min_value,
                                                     0) >= vn_min_range
                                             and nvl(pcetc.position, 'a') <>
                                                 'Base'
                                             and pcetc.dbd_id = pc_dbd_id)
                loop
                  --for full Range
                  if cur_forward_price.range_max_value <= vn_contract_price then
                    vn_range_gap := cur_forward_price.range_max_value -
                                    cur_forward_price.range_min_value;
                  elsif nvl(cur_forward_price.range_max_value,
                            vn_contract_price + 1) > vn_contract_price then
                    --For the Half  Range 
                    vn_range_gap := vn_contract_price -
                                    cur_forward_price.range_min_value;
                  end if;
                  if cur_forward_price.charge_basis = 'absolute' then
                    vn_each_tier_tc_charge := ceil(vn_range_gap /
                                                   nvl(cur_forward_price.esc_desc_value,
                                                       1)) *
                                              cur_forward_price.treatment_charge;
                  elsif cur_forward_price.charge_basis =
                        'fractions Pro-Rata' then
                    vn_each_tier_tc_charge := (vn_range_gap /
                                              nvl(cur_forward_price.esc_desc_value,
                                                   1)) *
                                              cur_forward_price.treatment_charge;
                  end if;
                
                  vn_treatment_charge := vn_treatment_charge +
                                         vn_each_tier_tc_charge;
                end loop;
              elsif vn_contract_price < vn_min_range then
                vn_treatment_charge := vn_base_tret_charge;
                --go back ward for the price range
                for cur_backward_price in (select nvl(pcetc.range_min_value,
                                                      0) range_min_value,
                                                  pcetc.range_min_op,
                                                  pcetc.range_max_value,
                                                  pcetc.range_max_op,
                                                  pcetc.esc_desc_value,
                                                  pcetc.esc_desc_unit_id,
                                                  pcetc.treatment_charge,
                                                  pcetc.treatment_charge_unit_id,
                                                  pcetc.charge_basis
                                             from pcetc_pc_elem_treatment_charge pcetc
                                            where pcetc.pcth_id =
                                                  cur_tret_charge.pcth_id
                                              and nvl(pcetc.range_min_value,
                                                      0) < vn_contract_price
                                              and nvl(pcetc.range_min_value,
                                                      0) <= vn_min_range
                                              and nvl(pcetc.position, 'a') <>
                                                  'Base'
                                              and pcetc.dbd_id = pc_dbd_id)
                loop
                  --For the full Range 
                  if cur_backward_price.range_max_value <=
                     vn_contract_price then
                    vn_range_gap := cur_backward_price.range_max_value -
                                    cur_backward_price.range_min_value;
                  elsif cur_backward_price.range_max_value >
                        vn_contract_price then
                    --For the Half  Range 
                    vn_range_gap := vn_contract_price -
                                    cur_backward_price.range_min_value;
                  end if;
                  if cur_backward_price.charge_basis = 'absolute' then
                    vn_each_tier_tc_charge := ceil(vn_range_gap /
                                                   nvl(cur_backward_price.esc_desc_value,
                                                       1)) *
                                              cur_backward_price.treatment_charge;
                  elsif cur_backward_price.charge_basis =
                        'fractions Pro-Rata' then
                    vn_each_tier_tc_charge := (vn_range_gap /
                                              nvl(cur_backward_price.esc_desc_value,
                                                   1)) *
                                              cur_backward_price.treatment_charge;
                  end if;
                  vn_treatment_charge := vn_treatment_charge +
                                         vn_each_tier_tc_charge;
                end loop;
              elsif vn_contract_price = vn_min_range and
                    vn_contract_price = vn_max_range then
                vn_treatment_charge := vn_base_tret_charge;
                --take the base price only
              
              end if;
            end if;
          elsif cur_tret_charge.range_type = 'Assay Range' then
            --Make sure the range for the element is mentation properly.
            --Only Slab basics charge
            if (cur_tret_charge.range_min_value <= cc.typical or
               cur_tret_charge.position = 'Range Begining') and
               (cur_tret_charge.range_max_value > cc.typical or
               cur_tret_charge.position = 'Range End') then
              vn_treatment_charge := cur_tret_charge.treatment_charge;
              vn_max_range        := cur_tret_charge.range_max_value;
              vn_min_range        := cur_tret_charge.range_min_value;
              vn_typical_val      := cc.typical;
              vc_weight_type      := cur_tret_charge.weight_type;
            end if;
          end if;
          --I will exit from the loop when it is tier base ,
          --as the inner loop is done the calculation.
          if cur_tret_charge.range_type = 'Price Range' and
             cur_tret_charge.charge_type = 'Variable' then
            exit;
          end if;
        end loop;
        dbms_output.put_line('The typical value is  ' || vn_typical_val);
        dbms_output.put_line('The Assay Range Applicable for this typical is ' ||
                             vn_min_range || ' --' || vn_max_range);
        dbms_output.put_line('The Treatment  charge for this assay Range is  ' ||
                             vn_treatment_charge);
        if vn_treatment_charge <> 0 then
          --Converting from wet to dry
          -- vn_item_qty := pn_qty;
        
          if vc_weight_type = 'Wet' then
            vn_item_qty := pn_wet_qty;
          else
            vn_item_qty := pn_dry_qty;
          end if;
        else
          vn_item_qty := 0;
        end if;
        --For TC , it is calculated on item Qty not on the element Qty
        vn_converted_qty := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                 pc_qty_unit_id,
                                                                 vc_rc_weight_unit_id,
                                                                 vn_item_qty);
        --Here no need of the typicla value as penalty is on item level   not on the element level                                           
        dbms_output.put_line('The Item  Quantity is   :-- ' ||
                             vn_converted_qty);
        vn_total_treat_charge := vn_converted_qty * vn_treatment_charge;
        dbms_output.put_line('the treatment  charge is ' ||
                             vn_total_treat_charge);
      exception
        when no_data_found then
          dbms_output.put_line(sqlerrm);
      end;
    end loop;
    pn_total_tc_charge := vn_total_treat_charge;
    pc_tc_cur_id       := vc_cur_id;
  exception
    when others then
      pn_total_tc_charge := -1;
      pc_tc_cur_id       := null;
  end;

  function fn_get_next_month_prompt_date(pc_promp_del_cal_id varchar2,
                                         pd_trade_date       date)
    return date is
    cursor cr_monthly_prompt_rule is
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
  
    pc_pdc_period_type_id      varchar2(15);
    pc_month_prompt_start_date date;
    pc_equ_period_type         number;
    cr_monthly_prompt_rule_rec cr_monthly_prompt_rule%rowtype;
    pc_period_to               number;
    pc_start_date              date;
    pc_end_date                date;
    pc_month                   varchar2(15);
    pc_year                    number;
    pn_month_count             number(5);
    vc_prompt_date             date;
  begin
    pc_month_prompt_start_date := pd_trade_date;
    pn_month_count             := 0;
    begin
      select pm.period_type_id
        into pc_pdc_period_type_id
        from pm_period_master pm
       where pm.period_type_name = 'Month';
    end;
  
    open cr_monthly_prompt_rule;
  
    fetch cr_monthly_prompt_rule
      into cr_monthly_prompt_rule_rec;
  
    pc_period_to := cr_monthly_prompt_rule_rec.period_for; --no of forward months required
  
    begin
      select pm.equivalent_days
        into pc_equ_period_type
        from pm_period_master pm
       where pm.period_type_id = cr_monthly_prompt_rule_rec.period_type_id;
    end;
    pc_start_date := pc_month_prompt_start_date;
    pc_end_date   := pc_month_prompt_start_date +
                     (pc_period_to * pc_equ_period_type);
    for cr_applicable_months_rec in cr_applicable_months
    loop
      pc_month_prompt_start_date := to_date(('01-' ||
                                            cr_applicable_months_rec.applicable_month || '-' ||
                                            to_char(pc_start_date, 'YYYY')),
                                            'dd/mm/yyyy');
      --------------------
      dbms_output.put_line('pc_month_prompt_start_date ' ||
                           pc_month_prompt_start_date);
      if (pc_month_prompt_start_date >=
         to_date(('01-' || to_char(pc_start_date, 'Mon-YYYY')),
                  'dd/mm/yyyy') and
         pc_month_prompt_start_date <= pc_end_date) then
        pn_month_count := pn_month_count + 1;
        if pn_month_count = 1 then
          pc_month := to_char(pc_month_prompt_start_date, 'Mon');
          pc_year  := to_char(pc_month_prompt_start_date, 'YYYY');
        end if;
      end if;
      exit when pn_month_count > 1;
      dbms_output.put_line('pc_month pc_year ' || pc_month || '-' ||
                           pc_year);
      ---------------
    end loop;
    close cr_monthly_prompt_rule;
    if pc_month is not null and pc_year is not null then
      vc_prompt_date := to_date('01-' || pc_month || '-' || pc_year,
                                'dd-Mon-yyyy');
    end if;
    return vc_prompt_date;
  end;
  procedure sp_get_gmr_treatment_charge(pc_inter_gmr_ref_no varchar2,
                                        pc_inter_grd_ref_no varchar2,
                                        pc_element_id       varchar2,
                                        pc_dbd_id           varchar2,
                                        pn_cp_price         number,
                                        pc_cp_unit_id       varchar2,
                                        pn_total_tc_charge  out number,
                                        pc_tc_cur_id        out varchar2) is
    vn_treatment_charge    number;
    vn_total_treat_charge  number;
    vn_max_range           number;
    vn_min_range           number;
    vn_typical_val         number;
    vc_weight_type         varchar2(20);
    vn_contract_price      number;
    vn_base_tret_charge    number;
    vn_each_tier_tc_charge number;
    vn_range_gap           number;
    vc_price_unit_id       varchar2(10);
    vc_cur_id              varchar2(10);
    vn_converted_qty       number;
    vc_rc_weight_unit_id   varchar2(15);
    vn_total_gmr_tc_value  number := 0;
  begin
    vn_contract_price   := pn_cp_price;
    vn_treatment_charge := 0;
    for cc in (select gmr.internal_gmr_ref_no,
                      grd.internal_grd_ref_no,
                      ash.ash_id,
                      ash.assay_type,
                      asm.sub_lot_no,
                      pqca.typical,
                      rm.qty_unit_id_numerator,
                      rm.qty_unit_id_denominator,
                      rm.ratio_name,
                      pqca.element_id,
                      aml.underlying_product_id,
                      asm.net_weight,
                      asm.dry_weight,
                      asm.net_weight_unit,
                      pci.pcpq_id
                 from gmr_goods_movement_record   gmr,
                      grd_goods_record_detail     grd,
                      sam_stock_assay_mapping     sam,
                      ash_assay_header            ash,
                      asm_assay_sublot_mapping    asm,
                      pqca_pq_chemical_attributes pqca,
                      rm_ratio_master             rm,
                      aml_attribute_master_list   aml,
                      pci_physical_contract_item  pci
               
                where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                  and grd.internal_grd_ref_no = sam.internal_grd_ref_no
                  and sam.ash_id = ash.ash_id
                  and sam.is_latest_pricing_assay = 'Y'
                  and ash.ash_id = asm.ash_id
                  and asm.asm_id = pqca.asm_id
                  and rm.ratio_id = pqca.unit_of_measure
                  and ash.is_active = 'Y'
                  and asm.is_active = 'Y'
                  and aml.attribute_id = pqca.element_id
                  and pqca.element_id = pc_element_id
                  and gmr.dbd_id = pc_dbd_id
                  and grd.dbd_id = pc_dbd_id
                  and pci.dbd_id = pc_dbd_id
                  and grd.internal_contract_item_ref_no=pci.internal_contract_item_ref_no
                  and gmr.internal_gmr_ref_no = pc_inter_gmr_ref_no
                  and grd.internal_grd_ref_no = pc_inter_grd_ref_no)
    loop
      begin
        for cur_tret_charge in (select pcth.range_type,
                                       pcetc.treatment_charge,
                                       pcetc.treatment_charge_unit_id,
                                       pcetc.charge_type,
                                       pcetc.charge_basis,
                                       pcetc.weight_type,
                                       pcetc.position,
                                       pcetc.range_min_op,
                                       nvl(pcetc.range_min_value, 0) range_min_value,
                                       pcetc.range_max_op,
                                       pcetc.range_max_value,
                                       pcth.pcth_id,
                                       pum.price_unit_id,
                                       pum.cur_id,
                                       pum.weight_unit_id
                                  from pcth_pc_treatment_header       pcth,
                                       ted_treatment_element_details  red,
                                       pcetc_pc_elem_treatment_charge pcetc,
                                       tqd_treatment_quality_details  tqd,
                                       ppu_product_price_units        ppu,
                                       pum_price_unit_master          pum,
                                       gth_gmr_treatment_header       gth
                                 where pcth.pcth_id = red.pcth_id
                                   and pcth.pcth_id = pcetc.pcth_id
                                   and pcth.pcth_id = tqd.pcth_id
                                   and tqd.pcpq_id = cc.pcpq_id
                                   and pcth.dbd_id = pc_dbd_id
                                   and red.dbd_id = pc_dbd_id
                                   and pcetc.dbd_id = pc_dbd_id
                                   and tqd.dbd_id = pc_dbd_id
                                   and red.element_id = cc.element_id
                                   and pcetc.treatment_charge_unit_id =
                                       ppu.internal_price_unit_id
                                   and ppu.price_unit_id = pum.price_unit_id
                                   and gth.internal_gmr_ref_no =
                                       pc_inter_gmr_ref_no
                                   and gth.pcth_id = pcth.pcth_id
                                   and gth.is_active = 'Y'
                                   and pcetc.is_active = 'Y'
                                   and pcth.is_active = 'Y'
                                   and red.is_active = 'Y'
                                   and tqd.is_active = 'Y')
        loop
          vc_cur_id            := cur_tret_charge.cur_id;
          vc_price_unit_id     := cur_tret_charge.price_unit_id;
          vc_rc_weight_unit_id := cur_tret_charge.weight_unit_id;
          vc_weight_type       := cur_tret_charge.weight_type;
          if cur_tret_charge.range_type = 'Price Range' then
            --if the CHARGE_TYPE is fixed then it will
            --behave as the slab as same as the assay range
            --No base concept is here
            if cur_tret_charge.charge_type = 'Fixed' then
              if (cur_tret_charge.range_min_value <= vn_contract_price or
                 cur_tret_charge.position = 'Range Begining') and
                 (cur_tret_charge.range_max_value >= vn_contract_price or
                 cur_tret_charge.position = 'Range End') then
                vn_treatment_charge := cur_tret_charge.treatment_charge;
                dbms_output.put_line(vn_treatment_charge);
              end if;
            elsif cur_tret_charge.charge_type = 'Variable' then
              --Take the base price and its min and max range
              begin
                select pcetc.range_min_value,
                       pcetc.range_max_value,
                       pcetc.treatment_charge
                  into vn_min_range,
                       vn_max_range,
                       vn_base_tret_charge
                  from pcetc_pc_elem_treatment_charge pcetc
                 where pcetc.pcth_id = cur_tret_charge.pcth_id
                   and pcetc.position = 'Base'
                   and pcetc.charge_type = 'Variable'
                   and pcetc.dbd_id = pc_dbd_id;
              exception
                when no_data_found then
                  vn_max_range        := 0;
                  vn_min_range        := 0;
                  vn_base_tret_charge := 0;
              end;
              --according to the contract price , the price tier
              --will be find out, it may forward or back ward
              --Both vn_max_range and vn_min_range are same
              --in case if base
              if vn_contract_price > vn_max_range then
                vn_treatment_charge := vn_base_tret_charge;
                --go forward for the price range
                for cur_forward_price in (select pcetc.range_min_value,
                                                 pcetc.range_min_op,
                                                 pcetc.range_max_value,
                                                 pcetc.range_max_op,
                                                 pcetc.esc_desc_value,
                                                 pcetc.esc_desc_unit_id,
                                                 pcetc.treatment_charge,
                                                 pcetc.treatment_charge_unit_id,
                                                 pcetc.charge_basis
                                            from pcetc_pc_elem_treatment_charge pcetc
                                           where pcetc.pcth_id =
                                                 cur_tret_charge.pcth_id
                                             and nvl(pcetc.range_min_value,
                                                     0) < vn_contract_price
                                             and nvl(pcetc.range_min_value,
                                                     0) >= vn_min_range
                                             and nvl(pcetc.position, 'a') <>
                                                 'Base'
                                             and pcetc.dbd_id = pc_dbd_id)
                loop
                  --for full Range
                  if cur_forward_price.range_max_value <= vn_contract_price then
                    vn_range_gap := cur_forward_price.range_max_value -
                                    cur_forward_price.range_min_value;
                  elsif nvl(cur_forward_price.range_max_value,
                            vn_contract_price + 1) > vn_contract_price then
                    --For the Half  Range
                    vn_range_gap := vn_contract_price -
                                    cur_forward_price.range_min_value;
                  end if;
                  if cur_forward_price.charge_basis = 'absolute' then
                    vn_each_tier_tc_charge := ceil(vn_range_gap /
                                                   nvl(cur_forward_price.esc_desc_value,
                                                       1)) *
                                              cur_forward_price.treatment_charge;
                  elsif cur_forward_price.charge_basis =
                        'fractions Pro-Rata' then
                    vn_each_tier_tc_charge := (vn_range_gap /
                                              nvl(cur_forward_price.esc_desc_value,
                                                   1)) *
                                              cur_forward_price.treatment_charge;
                  end if;
                
                  vn_treatment_charge := vn_treatment_charge +
                                         vn_each_tier_tc_charge;
                end loop;
              elsif vn_contract_price < vn_min_range then
                vn_treatment_charge := vn_base_tret_charge;
                --go back ward for the price range
                for cur_backward_price in (select nvl(pcetc.range_min_value,
                                                      0) range_min_value,
                                                  pcetc.range_min_op,
                                                  pcetc.range_max_value,
                                                  pcetc.range_max_op,
                                                  pcetc.esc_desc_value,
                                                  pcetc.esc_desc_unit_id,
                                                  pcetc.treatment_charge,
                                                  pcetc.treatment_charge_unit_id,
                                                  pcetc.charge_basis
                                             from pcetc_pc_elem_treatment_charge pcetc
                                            where pcetc.pcth_id =
                                                  cur_tret_charge.pcth_id
                                              and nvl(pcetc.range_min_value,
                                                      0) < vn_contract_price
                                              and nvl(pcetc.range_min_value,
                                                      0) <= vn_min_range
                                              and nvl(pcetc.position, 'a') <>
                                                  'Base'
                                              and pcetc.dbd_id = pc_dbd_id)
                loop
                  --For the full Range
                  if cur_backward_price.range_max_value <=
                     vn_contract_price then
                    vn_range_gap := cur_backward_price.range_max_value -
                                    cur_backward_price.range_min_value;
                  elsif cur_backward_price.range_max_value >
                        vn_contract_price then
                    --For the Half  Range
                    vn_range_gap := vn_contract_price -
                                    cur_backward_price.range_min_value;
                  end if;
                  if cur_backward_price.charge_basis = 'absolute' then
                    vn_each_tier_tc_charge := ceil(vn_range_gap /
                                                   nvl(cur_backward_price.esc_desc_value,
                                                       1)) *
                                              cur_backward_price.treatment_charge;
                  elsif cur_backward_price.charge_basis =
                        'fractions Pro-Rata' then
                    vn_each_tier_tc_charge := (vn_range_gap /
                                              nvl(cur_backward_price.esc_desc_value,
                                                   1)) *
                                              cur_backward_price.treatment_charge;
                  end if;
                  vn_treatment_charge := vn_treatment_charge +
                                         vn_each_tier_tc_charge;
                end loop;
              elsif vn_contract_price = vn_min_range and
                    vn_contract_price = vn_max_range then
                vn_treatment_charge := vn_base_tret_charge;
                --take the base price only
              
              end if;
            end if;
          elsif cur_tret_charge.range_type = 'Assay Range' then
            --Make sure the range for the element is mentation properly.
            --Only Slab basics charge
            if (cur_tret_charge.range_min_value <= cc.typical or
               cur_tret_charge.position = 'Range Begining') and
               (cur_tret_charge.range_max_value > cc.typical or
               cur_tret_charge.position = 'Range End') then
              vn_treatment_charge := cur_tret_charge.treatment_charge;
              vn_max_range        := cur_tret_charge.range_max_value;
              vn_min_range        := cur_tret_charge.range_min_value;
              vn_typical_val      := cc.typical;
              vc_weight_type      := cur_tret_charge.weight_type;
            end if;
          end if;
          --I will exit from the loop when it is tier base ,
          --as the inner loop is done the calculation.
          if cur_tret_charge.range_type = 'Price Range' and
             cur_tret_charge.charge_type = 'Variable' then
            exit;
          end if;
        end loop;
        dbms_output.put_line('The typical value is  ' || vn_typical_val);
        dbms_output.put_line('The Assay Range Applicable for this typical is ' ||
                             vn_min_range || ' --' || vn_max_range);
        dbms_output.put_line('The Treatment  charge for this assay Range is  ' ||
                             vn_treatment_charge);
      
        --For TC , it is calculated on item Qty not on the element Qty
        vn_converted_qty := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                 cc.net_weight_unit,
                                                                 vc_rc_weight_unit_id,
                                                                 cc.dry_weight);
        --Here no need of the typicla value as penalty is on item level   not on the element level
        dbms_output.put_line('The Item  Quantity is   :-- ' ||
                             vn_converted_qty);
        vn_total_treat_charge := vn_converted_qty * vn_treatment_charge;
        dbms_output.put_line('the treatment  charge is ' ||
                             vn_total_treat_charge);
      exception
        when no_data_found then
          dbms_output.put_line(sqlerrm);
      end;
    
      vn_total_gmr_tc_value := vn_total_gmr_tc_value +
                               vn_total_treat_charge;
    end loop;
    pn_total_tc_charge := vn_total_gmr_tc_value;
    pc_tc_cur_id       := vc_cur_id;
  exception
    when others then
      pn_total_tc_charge := -1;
      pc_tc_cur_id       := null;
  end;

  procedure sp_get_gmr_refine_charge(pc_inter_gmr_ref_no varchar2,
                                     pc_inter_grd_ref_no varchar2,
                                     pc_element_id       varchar2,
                                     pc_dbd_id           varchar2,
                                     pn_cp_price         number,
                                     pc_cp_unit_id       varchar2,
                                     pn_total_rc_charge  out number,
                                     pc_rc_cur_id        out varchar2) is
    vn_refine_charge       number;
    vc_price_unit_id       varchar2(100);
    vn_tot_refine_charge   number;
    vn_max_range           number;
    vn_typical_val         number;
    vn_contract_price      number;
    vn_min_range           number;
    vn_base_refine_charge  number;
    vn_range_gap           number;
    vn_each_tier_rc_charge number;
    vc_cur_id              varchar2(10);
    vc_rc_weight_unit_id   varchar2(15);
    vn_pricable_qty        number;
    vc_include_ref_charge  char(1);
    vn_gmr_rc_charges      number := 0;
  begin
    vn_refine_charge  := 0;
    vn_contract_price := pn_cp_price;
    --Get the Charge Details 
    for cc in (select gmr.internal_gmr_ref_no,
                      grd.internal_grd_ref_no,
                      gmr.internal_contract_ref_no,
                      grd.internal_contract_item_ref_no,
                      ash.ash_id,
                      ash.assay_type,
                      asm.sub_lot_no,
                      pqca.typical,
                      rm.qty_unit_id_numerator,
                      rm.qty_unit_id_denominator,
                      rm.ratio_name,
                      pqca.element_id,
                      aml.underlying_product_id,
                      asm.net_weight,
                      asm.dry_weight,
                      asm.net_weight_unit,
                      pci.pcpq_id,
                      (case
                        when rm.ratio_name = '%' then
                         (pqcapd.payable_percentage * asm.dry_weight) / 100
                        else
                         pkg_general.f_get_converted_quantity(aml.underlying_product_id,
                                                              asm.net_weight_unit,
                                                              rm.qty_unit_id_denominator,
                                                              asm.dry_weight) *
                         pqcapd.payable_percentage
                      
                      end) payable_qty,
                      (case
                        when rm.ratio_name = '%' then
                         ash.net_weight_unit
                        else
                         rm.qty_unit_id_numerator
                      end) payable_qty_unit
               
                 from gmr_goods_movement_record      gmr,
                      grd_goods_record_detail        grd,
                      sam_stock_assay_mapping        sam,
                      ash_assay_header               ash,
                      asm_assay_sublot_mapping       asm,
                      pqca_pq_chemical_attributes    pqca,
                      pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
                      rm_ratio_master                rm,
                      aml_attribute_master_list      aml,
                      pci_physical_contract_item     pci
               
                where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                  and grd.internal_grd_ref_no = sam.internal_grd_ref_no
                  and sam.ash_id = ash.ash_id
                  and sam.is_latest_pricing_assay = 'Y'
                  and ash.ash_id = asm.ash_id
                  and asm.asm_id = pqca.asm_id
                  and pqca.pqca_id = pqcapd.pqca_id
                  and rm.ratio_id = pqca.unit_of_measure
                  and ash.is_active = 'Y'
                  and asm.is_active = 'Y'
                  and aml.attribute_id = pqca.element_id
                  and pqca.element_id = pc_element_id
                  and gmr.dbd_id = pc_dbd_id
                  and grd.dbd_id = pc_dbd_id
                  and pci.dbd_id = pc_dbd_id
                  and grd.internal_contract_item_ref_no=pci.internal_contract_item_ref_no
                  and gmr.internal_gmr_ref_no = pc_inter_gmr_ref_no
                  and grd.internal_grd_ref_no = pc_inter_grd_ref_no)
    loop
      --for refine charge , the charge will applyed on
      --payable qty only.So deduct the moisture and other deductable item
      --from the item qty. 
      --include refine charge from the contract creation.
      --If Yes then take the conract include_ref_charge 
      --else go for the Charge Range
      begin
        select pcepc.include_ref_charges
          into vc_include_ref_charge
          from pcm_physical_contract_main     pcm,
               pcpch_pc_payble_content_header pcpch,
               pcepc_pc_elem_payable_content  pcepc
         where pcm.internal_contract_ref_no =
               pcpch.internal_contract_ref_no
           and pcpch.pcpch_id = pcepc.pcpch_id
           and pcm.dbd_id = pc_dbd_id
           and pcpch.dbd_id = pc_dbd_id
           and pcepc.dbd_id = pc_dbd_id
           and pcpch.element_id = cc.element_id
           and pcm.internal_contract_ref_no = cc.internal_contract_ref_no
           and (pcepc.range_min_value <= cc.typical or
               pcepc.position = 'Range Begining')
           and (pcepc.range_max_value > cc.typical or
               pcepc.position = 'Range End')
           and pcm.is_active = 'Y'
           and pcpch.is_active = 'Y'
           and pcepc.is_active = 'Y';
      exception
        when no_data_found then
          vc_include_ref_charge := 'N';
      end;
    
      if vc_include_ref_charge = 'Y' then
        begin
          --Take the price and its details 
          --, This price wil store when contract is created.
          for cur_ref_charge in (select pcpch.pcpch_id,
                                        pcepc.range_max_op,
                                        pcepc.range_max_value,
                                        pcepc.range_min_op,
                                        pcepc.range_min_value,
                                        pcepc.position,
                                        pcepc.refining_charge_value,
                                        pcepc.refining_charge_unit_id,
                                        pum.cur_id,
                                        pum.price_unit_id,
                                        pum.weight_unit_id
                                   from pcm_physical_contract_main     pcm,
                                        pcdi_pc_delivery_item          pcdi,
                                        pci_physical_contract_item     pci,
                                        pcpch_pc_payble_content_header pcpch,
                                        pcepc_pc_elem_payable_content  pcepc,
                                        ppu_product_price_units        ppu,
                                        pum_price_unit_master          pum,
                                        gmr_goods_movement_record      gmr,
                                        grh_gmr_refining_header        grh
                                  where pcm.internal_contract_ref_no =
                                        pcdi.internal_contract_ref_no
                                    and pcdi.pcdi_id = pci.pcdi_id
                                    and pcm.internal_contract_ref_no =
                                        pcpch.internal_contract_ref_no
                                    and pcpch.element_id = cc.element_id
                                    and pcpch.pcpch_id = pcepc.pcpch_id
                                    and pcepc.include_ref_charges = 'Y'
                                    and ppu.internal_price_unit_id =
                                        pcepc.refining_charge_unit_id
                                    and ppu.price_unit_id =
                                        pum.price_unit_id
                                    and pci.internal_contract_item_ref_no = cc.internal_contract_item_ref_no
                                    and gmr.internal_contract_ref_no = cc.internal_contract_ref_no
                                    and gmr.internal_gmr_ref_no =
                                        grh.internal_gmr_ref_no
                                    and pci.dbd_id = pc_dbd_id
                                    and pcdi.dbd_id = pc_dbd_id
                                    and pcm.dbd_id = pc_dbd_id
                                    and pcpch.dbd_id = pc_dbd_id
                                    and pcepc.dbd_id = pc_dbd_id
                                    and pci.is_active = 'Y'
                                    and pcm.is_active = 'Y'
                                    and pcdi.is_active = 'Y'
                                    and pcpch.is_active = 'Y'
                                    and pcepc.is_active = 'Y')
          loop
            vc_rc_weight_unit_id := cur_ref_charge.weight_unit_id;
            vc_cur_id            := cur_ref_charge.cur_id;
            vc_price_unit_id     := cur_ref_charge.price_unit_id;
          
            if (cur_ref_charge.range_min_value <= cc.typical or
               cur_ref_charge.position = 'Range Begining') and
               (cur_ref_charge.range_max_value > cc.typical or
               cur_ref_charge.position = 'Range End') then
              vn_refine_charge := cur_ref_charge.refining_charge_value;
            end if;
          end loop;
        exception
          when others then
            vn_refine_charge := 0;
            vc_price_unit_id := null;
        end;
      
      else
        begin
          for cur_ref_charge in (select pcrh.range_type,
                                        pcerc.refining_charge,
                                        pcerc.refining_charge_unit_id,
                                        pcerc.charge_type,
                                        pcerc.charge_basis,
                                        pcerc.position,
                                        pcerc.range_min_op,
                                        pcerc.range_min_value,
                                        pcerc.range_max_op,
                                        pcerc.range_max_value,
                                        pcrh.pcrh_id,
                                        pum.cur_id,
                                        pum.price_unit_id,
                                        pum.weight_unit_id
                                   from pcrh_pc_refining_header       pcrh,
                                        red_refining_element_details  red,
                                        pcerc_pc_elem_refining_charge pcerc,
                                        rqd_refining_quality_details  rqd,
                                        ppu_product_price_units       ppu,
                                        pum_price_unit_master         pum,
                                        grh_gmr_refining_header       grh
                                  where pcrh.pcrh_id = red.pcrh_id
                                    and pcrh.pcrh_id = pcerc.pcrh_id
                                    and pcrh.pcrh_id = rqd.pcrh_id
                                    and grh.internal_gmr_ref_no =
                                        pc_inter_gmr_ref_no
                                    and grh.pcrh_id = pcrh.pcrh_id
                                    and rqd.pcpq_id = cc.pcpq_id
                                    and pcrh.dbd_id = pc_dbd_id
                                    and red.dbd_id = pc_dbd_id
                                    and pcerc.dbd_id = pc_dbd_id
                                    and rqd.dbd_id = pc_dbd_id
                                    and red.element_id = pc_element_id
                                    and ppu.internal_price_unit_id =
                                        pcerc.refining_charge_unit_id
                                    and ppu.price_unit_id =
                                        pum.price_unit_id
                                    and pcerc.is_active = 'Y'
                                    and pcrh.is_active = 'Y'
                                    and red.is_active = 'Y'
                                    and rqd.is_active = 'Y'
                                    and grh.is_active = 'Y'
                                  order by range_min_value)
          loop
            vc_rc_weight_unit_id := cur_ref_charge.weight_unit_id;
            vc_cur_id            := cur_ref_charge.cur_id;
            vc_price_unit_id     := cur_ref_charge.price_unit_id;
            if cur_ref_charge.range_type = 'Price Range' then
              --if the CHARGE_TYPE is fixed then it will
              --behave as the slab as same as the assay range
              --No base concept is here
              if cur_ref_charge.charge_type = 'Fixed' then
                if (cur_ref_charge.range_min_value <= vn_contract_price or
                   cur_ref_charge.position = 'Range Begining') and
                   (cur_ref_charge.range_max_value >= vn_contract_price or
                   cur_ref_charge.position = 'Range End') then
                  vn_refine_charge := cur_ref_charge.refining_charge;
                  dbms_output.put_line(vn_refine_charge);
                end if;
              elsif cur_ref_charge.charge_type = 'Variable' then
                --Take the base price and its min and max range
                begin
                  select pcerc.range_min_value,
                         pcerc.range_max_value,
                         pcerc.refining_charge
                    into vn_min_range,
                         vn_max_range,
                         vn_base_refine_charge
                    from pcerc_pc_elem_refining_charge pcerc
                   where pcerc.pcrh_id = cur_ref_charge.pcrh_id
                     and pcerc.position = 'Base'
                     and pcerc.charge_type = 'Variable'
                     and pcerc.dbd_id = pc_dbd_id;
                exception
                  when no_data_found then
                    vn_min_range          := 0;
                    vn_max_range          := 0;
                    vn_base_refine_charge := 0;
                end;
                --according to the contract price , the price tier
                --will be find out, it may forward or back ward
                --Both vn_max_range and vn_min_range are same in case if base
                if vn_contract_price > vn_max_range then
                  --go forward for the price range
                  vn_refine_charge := vn_base_refine_charge;
                  for cur_forward_price in (select pcerc.range_min_value,
                                                   pcerc.range_min_op,
                                                   pcerc.range_max_value,
                                                   pcerc.range_max_op,
                                                   pcerc.esc_desc_value,
                                                   pcerc.esc_desc_unit_id,
                                                   pcerc.refining_charge,
                                                   pcerc.refining_charge_unit_id,
                                                   pcerc.charge_basis
                                              from pcerc_pc_elem_refining_charge pcerc
                                             where pcerc.pcrh_id =
                                                   cur_ref_charge.pcrh_id
                                               and nvl(pcerc.range_min_value,
                                                       0) <
                                                   vn_contract_price
                                               and nvl(pcerc.range_min_value,
                                                       0) >= vn_min_range
                                               and nvl(pcerc.position, 'a') <>
                                                   'Base'
                                               and pcerc.dbd_id = pc_dbd_id)
                  loop
                    --for full Range
                    if cur_forward_price.range_max_value <=
                       vn_contract_price then
                      vn_range_gap := cur_forward_price.range_max_value -
                                      cur_forward_price.range_min_value;
                    elsif nvl(cur_forward_price.range_max_value,
                              vn_contract_price + 1) > vn_contract_price then
                      --For the Half  Range
                      vn_range_gap := vn_contract_price -
                                      cur_forward_price.range_min_value;
                    end if;
                  
                    if cur_forward_price.charge_basis = 'absolute' then
                      vn_each_tier_rc_charge := ceil(vn_range_gap /
                                                     nvl(cur_forward_price.esc_desc_value,
                                                         1)) *
                                                cur_forward_price.refining_charge;
                    elsif cur_forward_price.charge_basis =
                          'fractions Pro-Rata' then
                      vn_each_tier_rc_charge := (vn_range_gap /
                                                nvl(cur_forward_price.esc_desc_value,
                                                     1)) *
                                                cur_forward_price.refining_charge;
                    end if;
                    vn_refine_charge := vn_refine_charge +
                                        vn_each_tier_rc_charge;
                  
                  end loop;
                elsif vn_contract_price < vn_min_range then
                  --go back ward for the price range
                  vn_refine_charge := vn_base_refine_charge;
                  for cur_backward_price in (select nvl(pcerc.range_min_value,
                                                        0) range_min_value,
                                                    pcerc.range_min_op,
                                                    pcerc.range_max_value,
                                                    pcerc.range_max_op,
                                                    pcerc.esc_desc_value,
                                                    pcerc.esc_desc_unit_id,
                                                    pcerc.refining_charge,
                                                    pcerc.refining_charge_unit_id,
                                                    pcerc.charge_basis
                                               from pcerc_pc_elem_refining_charge pcerc
                                              where pcerc.pcrh_id =
                                                    cur_ref_charge.pcrh_id
                                                and nvl(pcerc.range_min_value,
                                                        0) <
                                                    vn_contract_price
                                                and nvl(pcerc.range_min_value,
                                                        0) <= vn_min_range
                                                and nvl(pcerc.position, 'a') <>
                                                    'Base'
                                                and pcerc.dbd_id = pc_dbd_id)
                  loop
                    --For the full Range
                    if cur_backward_price.range_max_value <=
                       vn_contract_price then
                      vn_range_gap := cur_backward_price.range_max_value -
                                      cur_backward_price.range_min_value;
                    elsif cur_backward_price.range_max_value >
                          vn_contract_price then
                      --For the Half  Range
                      vn_range_gap := vn_contract_price -
                                      cur_backward_price.range_min_value;
                    end if;
                    if cur_backward_price.charge_basis = 'absolute' then
                      vn_each_tier_rc_charge := ceil(vn_range_gap /
                                                     nvl(cur_backward_price.esc_desc_value,
                                                         1)) *
                                                cur_backward_price.refining_charge;
                    elsif cur_backward_price.charge_basis =
                          'fractions Pro-Rata' then
                      vn_each_tier_rc_charge := (vn_range_gap /
                                                nvl(cur_backward_price.esc_desc_value,
                                                     1)) *
                                                cur_backward_price.refining_charge;
                    end if;
                    vn_refine_charge := vn_refine_charge +
                                        vn_each_tier_rc_charge;
                  end loop;
                elsif vn_contract_price = vn_min_range and
                      vn_contract_price = vn_max_range then
                  vn_refine_charge := vn_base_refine_charge;
                  --take the base price only
                end if;
              end if;
            elsif cur_ref_charge.range_type = 'Assay Range' then
              --Make sure the range for the element is mentation properly.
              if (cur_ref_charge.range_min_value <= cc.typical or
                 cur_ref_charge.position = 'Range Begining') and
                 (cur_ref_charge.range_max_value > cc.typical or
                 cur_ref_charge.position = 'Range End') then
                vn_refine_charge := cur_ref_charge.refining_charge;
                vn_max_range     := cur_ref_charge.range_max_value;
                vn_min_range     := cur_ref_charge.range_min_value;
                vn_typical_val   := cc.typical;
              end if;
            end if;
            --I will exit from the loop when it is tier base ,
            --as the inner loop is done the calculation.
            if cur_ref_charge.range_type = 'Price Range' and
               cur_ref_charge.charge_type = 'Variable' then
              exit;
            end if;
          end loop;
          dbms_output.put_line('The typical value is  ' || vn_typical_val);
          dbms_output.put_line('The Assay Range Applicable for this typical is ' ||
                               vn_min_range || ' --' || vn_max_range);
          dbms_output.put_line('The Refine charge for this assay Range is  ' ||
                               vn_refine_charge);
        exception
          when others then
            vn_refine_charge := 0;
            vc_price_unit_id := null;
        end;
      end if;
    
      vn_pricable_qty      := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                   cc.payable_qty_unit,
                                                                   vc_rc_weight_unit_id,
                                                                   cc.payable_qty);
      vn_tot_refine_charge := vn_pricable_qty * vn_refine_charge;
      dbms_output.put_line('The refine  quantity is ' || vn_pricable_qty);
      vn_gmr_rc_charges := vn_gmr_rc_charges + vn_tot_refine_charge;
      dbms_output.put_line('The refine  Amount is ' ||
                           vn_tot_refine_charge);
    end loop;
    pn_total_rc_charge := vn_gmr_rc_charges;
    pc_rc_cur_id       := vc_cur_id;
  
  exception
    when others then
      vn_tot_refine_charge := -1;
      vc_price_unit_id     := null;
    
  end;
  procedure sp_get_gmr_penalty_charge(pc_inter_gmr_ref_no varchar2,
                                      pc_inter_grd_ref_no varchar2,
                                      pc_dbd_id           varchar2,
                                      pc_element_id       varchar2,
                                      pn_total_pc_charge  out number,
                                      pc_pc_cur_id        out varchar2) is
    vn_penalty_charge      number;
    vc_penalty_weight_type varchar2(20);
    vn_max_range           number;
    vn_min_range           number;
    vn_typical_val         number := 0;
    vn_converted_qty       number;
    vn_element_pc_charge   number;
    vn_range_gap           number;
    vn_tier_penalty        number;
    vc_price_unit_id       varchar2(15);
    vc_cur_id              varchar2(15);
  begin
    vn_penalty_charge    := 0;
    vn_element_pc_charge := 0;
    vn_tier_penalty      := 0;
    pn_total_pc_charge   := 0;
    --Take all the Elements associated with the conttract.
    for cc in (select gmr.internal_gmr_ref_no,
                      grd.internal_grd_ref_no,
                      ash.ash_id,
                      ash.assay_type,
                      asm.sub_lot_no,
                      pqca.typical,
                      rm.qty_unit_id_numerator,
                      rm.qty_unit_id_denominator,
                      rm.ratio_name,
                      pqca.element_id,
                      aml.underlying_product_id,
                      asm.net_weight,
                      asm.dry_weight,
                      asm.net_weight_unit,
                      pci.pcpq_id
                 from gmr_goods_movement_record   gmr,
                      grd_goods_record_detail     grd,
                      sam_stock_assay_mapping     sam,
                      ash_assay_header            ash,
                      asm_assay_sublot_mapping    asm,
                      pqca_pq_chemical_attributes pqca,
                      rm_ratio_master             rm,
                      aml_attribute_master_list   aml,
                      pci_physical_contract_item  pci
               
                where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                  and grd.internal_grd_ref_no = sam.internal_grd_ref_no
                  and sam.ash_id = ash.ash_id
                  and sam.is_latest_pricing_assay = 'Y'
                  and ash.ash_id = asm.ash_id
                  and asm.asm_id = pqca.asm_id
                  and rm.ratio_id = pqca.unit_of_measure
                  and ash.is_active = 'Y'
                  and asm.is_active = 'Y'
                  and aml.attribute_id = pqca.element_id
                  and nvl(pqca.is_elem_for_pricing, 'N') = 'N'
                  and pqca.element_id = pc_element_id
                  and gmr.dbd_id = pc_dbd_id
                  and grd.dbd_id = pc_dbd_id
                  and pci.dbd_id = pc_dbd_id
                  and grd.internal_contract_item_ref_no=pci.internal_contract_item_ref_no
                  and gmr.internal_gmr_ref_no = pc_inter_gmr_ref_no
                  and grd.internal_grd_ref_no = pc_inter_grd_ref_no)
    loop
      vn_element_pc_charge := 0;
      vn_tier_penalty      := 0;
      --Passing each element which is getting  from the outer loop.
      --and checking ,is it non payable or not.
      for cur_pc_charge in (select pcap.penalty_charge_type,
                                   pcap.penalty_basis,
                                   pcap.penalty_amount,
                                   pcap.range_min_value,
                                   pcap.range_max_value,
                                   pcap.range_min_op,
                                   pcap.range_max_op,
                                   pcap.position,
                                   pcap.charge_basis,
                                   pcap.penalty_weight_type,
                                   pcap.pcaph_id,
                                   pcaph.slab_tier,
                                   pum.price_unit_id,
                                   pum.cur_id,
                                   pum.weight_unit_id
                              from pcaph_pc_attr_penalty_header  pcaph,
                                   pcap_pc_attribute_penalty     pcap,
                                   pqd_penalty_quality_details   pqd,
                                   pad_penalty_attribute_details pad,
                                   gph_gmr_penalty_header        gph,
                                   ppu_product_price_units       ppu,
                                   pum_price_unit_master         pum
                             where pcaph.pcaph_id = pcap.pcaph_id
                               and pcaph.pcaph_id = pqd.pcaph_id
                               and pcaph.pcaph_id = pad.pcaph_id
                               and pcaph.pcaph_id = gph.pcaph_id
                               and pqd.pcpq_id = cc.pcpq_id
                               and pcaph.dbd_id = pc_dbd_id
                               and pcap.dbd_id = pc_dbd_id
                               and pqd.dbd_id = pc_dbd_id
                               and pad.dbd_id = pc_dbd_id
                               and pcaph.is_active = 'Y'
                               and pcap.is_active = 'Y'
                               and pqd.is_active = 'Y'
                               and pad.is_active = 'Y'
                               and gph.is_active = 'Y'
                               and gph.internal_gmr_ref_no =
                                   pc_inter_gmr_ref_no
                               and pad.element_id = cc.element_id
                               and pcap.penalty_unit_id =
                                   ppu.internal_price_unit_id
                               and ppu.price_unit_id = pum.price_unit_id
                               and (pcap.range_max_value > cc.typical or
                                   pcap.position = 'Range End')
                               and (pcap.range_min_value <= cc.typical or
                                   pcap.position = 'Range Begining'))
      loop
        vc_price_unit_id     := cur_pc_charge.price_unit_id;
        vc_cur_id            := cur_pc_charge.cur_id;
        vn_element_pc_charge := 0;
        --check the penalty charge type
        if cur_pc_charge.penalty_charge_type = 'Fixed' then
          vc_penalty_weight_type := cur_pc_charge.penalty_weight_type;
          --Find the PC charge which will fall in the appropriate range.
          --as according to the typical value   
          if (cur_pc_charge.range_min_value <= cc.typical or
             cur_pc_charge.position = 'Range Begining') and
             (cur_pc_charge.range_max_value > cc.typical or
             cur_pc_charge.position = 'Range End') then
          
            vn_penalty_charge := cur_pc_charge.penalty_amount;
            vn_max_range      := cur_pc_charge.range_max_value;
            vn_min_range      := cur_pc_charge.range_min_value;
            vn_typical_val    := cc.typical;
          
            vn_converted_qty := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                     cc.net_weight_unit,
                                                                     cur_pc_charge.weight_unit_id,
                                                                     cc.dry_weight);
          
            vn_element_pc_charge := vn_penalty_charge * vn_converted_qty;
          end if;
        elsif cur_pc_charge.penalty_charge_type = 'Variable' then
          if cur_pc_charge.penalty_basis = 'Quantity' and
             cur_pc_charge.slab_tier = 'Tier' then
            vn_typical_val := cc.typical;
            --find the range where the typical falls in 
            if (cur_pc_charge.range_min_value <= vn_typical_val or
               cur_pc_charge.position = 'Range Begining') and
               (cur_pc_charge.range_max_value > vn_typical_val or
               cur_pc_charge.position = 'Range End') then
              --Finding all the  assay range form the start range to  last range 
              --for the different Tier basics ,assording to the typicla value
              for cur_range in (select nvl(pcap.range_min_value, 0) min_range,
                                       pcap.range_max_value max_range,
                                       pcap.penalty_amount,
                                       pcap.per_increase_value
                                  from pcap_pc_attribute_penalty pcap
                                 where nvl(pcap.range_min_value, 0) <=
                                       vn_typical_val
                                   and pcap.pcaph_id =
                                       cur_pc_charge.pcaph_id
                                   and pcap.dbd_id = pc_dbd_id)
              loop
                --for half range
                if vn_typical_val > 0 then
                  if cur_range.min_range < vn_typical_val and
                     nvl(cur_range.max_range, vn_typical_val + 1) >
                     vn_typical_val then
                    vn_penalty_charge := cur_range.penalty_amount;
                    vn_range_gap      := vn_typical_val -
                                         cur_range.min_range;
                    --for full range                 
                  elsif cur_range.min_range <= vn_typical_val and
                        cur_range.max_range <= vn_typical_val then
                    vn_penalty_charge := cur_range.penalty_amount;
                    vn_range_gap      := cur_range.max_range -
                                         cur_range.min_range;
                  end if;
                end if;
                if cur_pc_charge.charge_basis = 'absolute' then
                  vn_penalty_charge := ceil(vn_range_gap /
                                            cur_range.per_increase_value) *
                                       vn_penalty_charge;
                elsif cur_pc_charge.charge_basis = 'fractions Pro-Rata' then
                  vn_penalty_charge := (vn_range_gap /
                                       cur_range.per_increase_value) *
                                       vn_penalty_charge;
                end if;
                vn_tier_penalty := vn_tier_penalty + vn_penalty_charge;
              
              end loop;
            end if;
          elsif cur_pc_charge.penalty_basis = 'Payable Content' then
            --Take the payable content qty from the table and 
            --find the penalty But for the time being this feature is not applied
            null;
          end if;
        
          --Penalty Charge is applyed on the item wise not on the element  wise
          --This item qty may be dry or wet
          vn_converted_qty := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                   cc.net_weight_unit,
                                                                   cur_pc_charge.weight_unit_id,
                                                                   cc.dry_weight);
          --Here no need of the typical value as penalty is on item level  
          vn_element_pc_charge := vn_tier_penalty * vn_converted_qty;
        end if;
      end loop;
      pn_total_pc_charge := pn_total_pc_charge + vn_element_pc_charge;
    end loop;
  
    pc_pc_cur_id := vc_cur_id;
  exception
    when others then
      pn_total_pc_charge := -1;
      pc_pc_cur_id       := null;
  end;
end; 
/
