create or replace package pkg_metals_general is
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
                                  pc_dbd_id                 varchar2,
                                  pn_penalty_qty            number,
                                  pc_pc_qty_unit_id         varchar2,
                                  pn_total_pc_charge        out number,
                                  pc_pc_cur_id              out varchar2);

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
                                        pn_dry_qty          number,
                                        pn_wet_qty          number,
                                        pc_qty_unit_id      varchar2,
                                        pn_cp_price         number,
                                        pc_cp_unit_id       varchar2,
                                        pn_total_tc_charge  out number,
                                        pc_tc_cur_id        out varchar2);

  procedure sp_get_gmr_tc_by_assay(pc_inter_gmr_ref_no varchar2,
                                   pc_inter_grd_ref_no varchar2,
                                   pc_element_id       varchar2,
                                   pc_dbd_id           varchar2,
                                   pn_cp_price         number,
                                   pc_cp_unit_id       varchar2,
                                   pc_ash_id           varchar2,
                                   pn_dry_qty          number,
                                   pc_qty_unit_id      varchar2,
                                   pn_total_tc_charge  out number,
                                   pc_tc_cur_id        out varchar2);
  procedure sp_get_gmr_rc_by_assay(pc_inter_gmr_ref_no varchar2,
                                   pc_inter_grd_ref_no varchar2,
                                   pc_element_id       varchar2,
                                   pc_dbd_id           varchar2,
                                   pn_cp_price         number,
                                   pc_cp_unit_id       varchar2,
                                   pc_ash_id           varchar2,
                                   pn_payable_qty      number,
                                   pc_qty_unit_id      varchar2,
                                   pn_total_rc_charge  out number,
                                   pc_rc_cur_id        out varchar2);
  procedure sp_get_gmr_pc_by_assay(pc_inter_gmr_ref_no varchar2,
                                   pc_inter_grd_ref_no varchar2,
                                   pc_dbd_id           varchar2,
                                   pc_element_id       varchar2,
                                   pc_ash_id           varchar2,
                                   pn_dry_qty          number,
                                   pn_wet_qty          number,
                                   pc_qty_unit_id      varchar2,
                                   pn_total_pc_charge  out number,
                                   pc_pc_cur_id        out varchar2);
  procedure sp_get_gmr_refine_charge(pc_inter_gmr_ref_no varchar2,
                                     pc_inter_grd_ref_no varchar2,
                                     pc_element_id       varchar2,
                                     pc_dbd_id           varchar2,
                                     pn_rc_qty           number,
                                     pc_rc_qty_unit_id   varchar2,
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
  procedure sp_get_gmr_penalty_charge_new(pc_inter_gmr_ref_no varchar2,
                                          pc_inter_grd_ref_no varchar2,
                                          pc_dbd_id           varchar2,
                                          pn_total_pc_charge  out number,
                                          pc_pc_cur_id        out varchar2);

  function f_get_next_day(p_date     in date,
                          p_day      in varchar2,
                          p_position in number) return date;

  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean;

  procedure sp_quality_premium_fw_rate(pc_int_contract_item_ref_no in varchar2,
                                       pc_corporate_id             in varchar2,
                                       pc_process                  in varchar2,
                                       pd_trade_date               in date,
                                       pc_price_unit_id            in varchar2,
                                       pc_base_cur_id              in varchar2,
                                       pc_product_id               in varchar2,
                                       pc_base_qty_unit_id         in varchar2,
                                       pc_process_id               in varchar2,
                                       pc_price_basis              in varchar2,
                                       pd_valuation_fx_date        date,
                                       pd_qp_fx_date               date,
                                       pn_premium                  out number,
                                       pc_exch_rate_string         out varchar2);

end;
/
create or replace package body pkg_metals_general is
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
                                  aml.underlying_product_id,
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
                                  end) net_weight
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
                                   pum.cur_id cur_id,
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
                               and ppu.price_unit_id = pum.price_unit_id)
      loop
        vc_price_unit_id     := cur_pc_charge.price_unit_id;
        vc_cur_id            := cur_pc_charge.cur_id;
        vn_element_pc_charge := 0;
        --check the penalty charge type
        if cur_pc_charge.penalty_charge_type = 'Fixed' then
          vc_penalty_weight_type := cur_pc_charge.penalty_weight_type;
          --Find the PC charge which will fall in the appropriate range.
          --as according to the typical value   
          if (cur_pc_charge.position = 'Range Begining' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical <= cur_pc_charge.range_max_value) or
             (cur_pc_charge.position = 'Range Begining' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position = 'Range End' and
             cur_pc_charge.range_min_op = '>=' and
             cc.typical >= cur_pc_charge.range_min_value) or
             (cur_pc_charge.position = 'Range End' and
             cur_pc_charge.range_min_op = '>' and
             cc.typical > cur_pc_charge.range_min_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical > cur_pc_charge.range_min_value and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>=' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical >= cur_pc_charge.range_min_value and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical > cur_pc_charge.range_min_value and
             cc.typical <= cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>=' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical >= cur_pc_charge.range_min_value and
             cc.typical <= cur_pc_charge.range_max_value) then
          
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
            if (cur_pc_charge.position = 'Range Begining' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val <= cur_pc_charge.range_max_value) or
               (cur_pc_charge.position = 'Range Begining' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position = 'Range End' and
               cur_pc_charge.range_min_op = '>=' and
               vn_typical_val >= cur_pc_charge.range_min_value) or
               (cur_pc_charge.position = 'Range End' and
               cur_pc_charge.range_min_op = '>' and
               vn_typical_val > cur_pc_charge.range_min_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val > cur_pc_charge.range_min_value and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>=' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val >= cur_pc_charge.range_min_value and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val > cur_pc_charge.range_min_value and
               vn_typical_val <= cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>=' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val >= cur_pc_charge.range_min_value and
               vn_typical_val <= cur_pc_charge.range_max_value) then
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
                if vn_typical_val > 0 then
                  if cur_range.min_range <= vn_typical_val and
                     cur_range.max_range <= vn_typical_val then
                    --for full range    
                    vn_penalty_charge := cur_range.penalty_amount;
                    vn_range_gap      := cur_range.max_range -
                                         cur_range.min_range;
                  else
                    --for half range
                    vn_penalty_charge := cur_range.penalty_amount;
                    vn_range_gap      := vn_typical_val -
                                         cur_range.min_range;
                  end if;
                end if;
                -- get the  qty according to the dry or wet
                -- penalty is applyed on the item qty not on the penalty qty
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
              /* dbms_output.put_line(' Variable  Penalty charge for this ' ||                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     vn_penalty_charge);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    dbms_output.put_line('---------------------------');*/
              --calculate total Penalty charge
              end loop;
            end if;
          elsif cur_pc_charge.penalty_basis = 'Payable Content' then
            -- Take the payable content qty from the table and 
            -- find the penalty But for the time being this feature is not applied
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
    vn_refine_charge number;
    vn_item_qty      number;
    --vn_element_qty         number;
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
    --vn_min_price           number;
    --vn_max_price           number;
    vc_range_over varchar2(1) := 'N';
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
               pcepc_pc_elem_payable_content  pcepc,
               pqd_payable_quality_details    pqd
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
           and pcepc.is_active = 'Y'
           and pqd.pcpch_id = pcpch.pcpch_id
           and pqd.pcpq_id = cc.pcpq_id
           and pqd.is_active = 'Y'
           and pqd.dbd_id = pc_dbd_id;
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
          
            if (cur_ref_charge.position = 'Range Begining' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical <= cur_ref_charge.range_max_value) or
               (cur_ref_charge.position = 'Range Begining' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical < cur_ref_charge.range_max_value) or
               (cur_ref_charge.position = 'Range End' and
               cur_ref_charge.range_min_op = '>=' and
               cc.typical >= cur_ref_charge.range_min_value) or
               (cur_ref_charge.position = 'Range End' and
               cur_ref_charge.range_min_op = '>' and
               cc.typical > cur_ref_charge.range_min_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical > cur_ref_charge.range_min_value and
               cc.typical < cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>=' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical >= cur_ref_charge.range_min_value and
               cc.typical < cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical > cur_ref_charge.range_min_value and
               cc.typical <= cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>=' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical >= cur_ref_charge.range_min_value and
               cc.typical <= cur_ref_charge.range_max_value) then
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
                                        nvl(pcerc.esc_desc_unit_id,
                                            pum.cur_id) cur_id,
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
              vn_tot_refine_charge := 0;
              --if the CHARGE_TYPE is fixed then it will
              --behave as the slab as same as the assay range
              --No base concept is here
              if cur_ref_charge.charge_type = 'Fixed' then
                if (cur_ref_charge.position = 'Range Begining' and
                   cur_ref_charge.range_max_op = '<=' and
                   vn_contract_price <= cur_ref_charge.range_max_value) or
                   (cur_ref_charge.position = 'Range Begining' and
                   cur_ref_charge.range_max_op = '<' and
                   vn_contract_price < cur_ref_charge.range_max_value) or
                   (cur_ref_charge.position = 'Range End' and
                   cur_ref_charge.range_min_op = '>=' and
                   vn_contract_price >= cur_ref_charge.range_min_value) or
                   (cur_ref_charge.position = 'Range End' and
                   cur_ref_charge.range_min_op = '>' and
                   vn_contract_price > cur_ref_charge.range_min_value) or
                   (cur_ref_charge.position is null and
                   cur_ref_charge.range_min_op = '>' and
                   cur_ref_charge.range_max_op = '<' and
                   vn_contract_price > cur_ref_charge.range_min_value and
                   vn_contract_price < cur_ref_charge.range_max_value) or
                   (cur_ref_charge.position is null and
                   cur_ref_charge.range_min_op = '>=' and
                   cur_ref_charge.range_max_op = '<' and
                   vn_contract_price >= cur_ref_charge.range_min_value and
                   vn_contract_price < cur_ref_charge.range_max_value) or
                   (cur_ref_charge.position is null and
                   cur_ref_charge.range_min_op = '>' and
                   cur_ref_charge.range_max_op = '<=' and
                   vn_contract_price > cur_ref_charge.range_min_value and
                   vn_contract_price <= cur_ref_charge.range_max_value) or
                   (cur_ref_charge.position is null and
                   cur_ref_charge.range_min_op = '>=' and
                   cur_ref_charge.range_max_op = '<=' and
                   vn_contract_price >= cur_ref_charge.range_min_value and
                   vn_contract_price <= cur_ref_charge.range_max_value) then
                  vn_refine_charge := cur_ref_charge.refining_charge;
                  --    dbms_output.put_line(vn_refine_charge);
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
                     and pcerc.is_active = 'Y'
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
                                                   nvl(pcerc.range_max_value,
                                                       vn_contract_price) range_max_value,
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
                                                       0) >= vn_max_range
                                                  -- Because There is a defintely range for escalator saying > Base 
                                                  -- If base is 6000, the escalator entry must say first entry as > 6000 and <=7000, > 7000 to 8000 or 
                                                  -- If we do not put >= price one entry will be missed
                                               and nvl(pcerc.position, 'a') <>
                                                   'Base'
                                               and pcerc.is_active = 'Y'
                                               and pcerc.dbd_id = pc_dbd_id
                                             order by pcerc.range_max_value asc nulls last)
                  loop
                    -- if price is in the range take diff of price and max range                   
                    if vn_contract_price >=
                       cur_forward_price.range_min_value and
                       vn_contract_price <=
                       cur_forward_price.range_max_value then
                      vn_range_gap  := abs(vn_contract_price -
                                           cur_forward_price.range_min_value);
                      vc_range_over := 'Y';
                    else
                      -- else diff range               
                      vn_range_gap := cur_forward_price.range_max_value -
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
                    if vc_range_over = 'Y' then
                      exit;
                    end if;
                  end loop;
                elsif vn_contract_price < vn_min_range then
                  --go back ward for the price range
                  vn_refine_charge := vn_base_refine_charge;
                  for cur_backward_price in (select nvl(pcerc.range_min_value,
                                                        vn_contract_price) range_min_value,
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
                                                        0) < vn_min_range
                                                   -- Because Deescalator has range saying < Base 
                                                   -- If base is 6000, Deescalator entry has to < 6000
                                                and nvl(pcerc.position, 'a') <>
                                                    'Base'
                                                and pcerc.is_active = 'Y'
                                                and pcerc.dbd_id = pc_dbd_id
                                              order by pcerc.range_min_value desc nulls last)
                  loop
                    -- if price is in the range take diff of price and max range
                    if vn_contract_price >=
                       cur_backward_price.range_min_value and
                       vn_contract_price <=
                       cur_backward_price.range_max_value then
                      vn_range_gap  := abs(vn_contract_price -
                                           cur_backward_price.range_max_value);
                      vc_range_over := 'Y';
                    else
                      -- else diff range               
                      vn_range_gap := cur_backward_price.range_max_value -
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
                    vn_refine_charge := vn_refine_charge -
                                        vn_each_tier_rc_charge;
                    if vc_range_over = 'Y' then
                      exit;
                    end if;
                  end loop;
                elsif vn_contract_price = vn_min_range and
                      vn_contract_price = vn_max_range then
                  vn_refine_charge := vn_base_refine_charge;
                  --take the base price only            
                end if;
              end if;
            elsif cur_ref_charge.range_type = 'Assay Range' then
              --Make sure the range for the element is mentation properly.
              if (cur_ref_charge.position = 'Range Begining' and
                 cur_ref_charge.range_max_op = '<=' and
                 cc.typical <= cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position = 'Range Begining' and
                 cur_ref_charge.range_max_op = '<' and
                 cc.typical < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position = 'Range End' and
                 cur_ref_charge.range_min_op = '>=' and
                 cc.typical >= cur_ref_charge.range_min_value) or
                 (cur_ref_charge.position = 'Range End' and
                 cur_ref_charge.range_min_op = '>' and
                 cc.typical > cur_ref_charge.range_min_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>' and
                 cur_ref_charge.range_max_op = '<' and
                 cc.typical > cur_ref_charge.range_min_value and
                 cc.typical < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>=' and
                 cur_ref_charge.range_max_op = '<' and
                 cc.typical >= cur_ref_charge.range_min_value and
                 cc.typical < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>' and
                 cur_ref_charge.range_max_op = '<=' and
                 cc.typical > cur_ref_charge.range_min_value and
                 cc.typical <= cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>=' and
                 cur_ref_charge.range_max_op = '<=' and
                 cc.typical >= cur_ref_charge.range_min_value and
                 cc.typical <= cur_ref_charge.range_max_value) then
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
          --   dbms_output.put_line('The typical value is  ' || vn_typical_val);
          --   dbms_output.put_line('The Assay Range Applicable for this typical is ' ||
          --                        vn_min_range || ' --' || vn_max_range);
          --   dbms_output.put_line('The Refine charge for this assay Range is  ' ||
          --                       vn_refine_charge);
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
      -- dbms_output.put_line('The refine  quantity is ' || vn_element_qty);
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
    --vn_min_price           number;
    --vn_max_price           number;
    vc_range_over varchar2(1) := 'N';
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
                                       nvl(pcetc.esc_desc_unit_id,
                                           pum.cur_id) cur_id,
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
            vn_total_treat_charge := 0;
            --if the CHARGE_TYPE is fixed then it will
            --behave as the slab as same as the assay range
            --No base concept is here
            -- Modified by Janna on 9th May 2012
            -- Compared Based on Each Type of Position along with the sign associated
            if cur_tret_charge.charge_type = 'Fixed' then
              if (cur_tret_charge.position = 'Range Begining' and
                 cur_tret_charge.range_max_op = '<=' and
                 vn_contract_price <= cur_tret_charge.range_max_value) or
                 (cur_tret_charge.position = 'Range Begining' and
                 cur_tret_charge.range_max_op = '<' and
                 vn_contract_price < cur_tret_charge.range_max_value) or
                 (cur_tret_charge.position = 'Range End' and
                 cur_tret_charge.range_min_op = '>=' and
                 vn_contract_price >= cur_tret_charge.range_min_value) or
                 (cur_tret_charge.position = 'Range End' and
                 cur_tret_charge.range_min_op = '>' and
                 vn_contract_price > cur_tret_charge.range_min_value) or
                 (cur_tret_charge.position is null and
                 cur_tret_charge.range_min_op = '>' and
                 cur_tret_charge.range_max_op = '<' and
                 vn_contract_price > cur_tret_charge.range_min_value and
                 vn_contract_price < cur_tret_charge.range_max_value) or
                 (cur_tret_charge.position is null and
                 cur_tret_charge.range_min_op = '>=' and
                 cur_tret_charge.range_max_op = '<' and
                 vn_contract_price >= cur_tret_charge.range_min_value and
                 vn_contract_price < cur_tret_charge.range_max_value) or
                 (cur_tret_charge.position is null and
                 cur_tret_charge.range_min_op = '>' and
                 cur_tret_charge.range_max_op = '<=' and
                 vn_contract_price > cur_tret_charge.range_min_value and
                 vn_contract_price <= cur_tret_charge.range_max_value) or
                 (cur_tret_charge.position is null and
                 cur_tret_charge.range_min_op = '>=' and
                 cur_tret_charge.range_max_op = '<=' and
                 vn_contract_price >= cur_tret_charge.range_min_value and
                 vn_contract_price <= cur_tret_charge.range_max_value) then
                vn_treatment_charge := cur_tret_charge.treatment_charge;
                --  dbms_output.put_line(vn_treatment_charge);
              end if;
            elsif cur_tret_charge.charge_type = 'Variable' then
              -- Take the base price and its min and max range
              begin
                select pcetc.range_min_value,
                       pcetc.range_max_value,
                       pcetc.treatment_charge
                  into vn_min_range,
                       vn_max_range,
                       vn_base_tret_charge
                  from pcetc_pc_elem_treatment_charge pcetc
                 where pcetc.pcth_id = cur_tret_charge.pcth_id
                   and pcetc.is_active = 'Y'
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
                                                 nvl(pcetc.range_max_value,
                                                     vn_contract_price) range_max_value,
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
                                                     0) >= vn_max_range
                                                -- Because There is a defintely range for escalator saying > Base 
                                                -- If base is 6000, the escalator entry must say first entry as > 6000 and <=7000, > 7000 to 8000 or 
                                                -- If we do not put >= price one entry will be missed
                                             and nvl(pcetc.position, 'a') <>
                                                 'Base'
                                             and pcetc.is_active = 'Y'
                                             and pcetc.dbd_id = pc_dbd_id
                                           order by pcetc.range_max_value asc nulls last)
                loop
                  -- if price is in the range take diff of price and max range                 
                  if vn_contract_price >= cur_forward_price.range_min_value and
                     vn_contract_price <= cur_forward_price.range_max_value then
                    vn_range_gap  := abs(vn_contract_price -
                                         cur_forward_price.range_min_value);
                    vc_range_over := 'Y';
                  else
                    -- else diff range               
                    vn_range_gap := cur_forward_price.range_max_value -
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
                  if vc_range_over = 'Y' then
                    exit;
                  end if;
                end loop;
              elsif vn_contract_price < vn_min_range then
                vn_treatment_charge := vn_base_tret_charge;
                --go back ward for the price range
                for cur_backward_price in (select nvl(pcetc.range_min_value,
                                                      vn_contract_price) range_min_value,
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
                                                      0) < vn_min_range
                                                 -- Because Deescalator has range saying < Base 
                                                 -- If base is 6000, Deescalator entry has to < 6000
                                              and nvl(pcetc.position, 'a') <>
                                                  'Base'
                                              and pcetc.is_active = 'Y'
                                              and pcetc.dbd_id = pc_dbd_id
                                            order by pcetc.range_min_value desc nulls last)
                loop
                  -- if price is in the range take diff of price and max range              
                  if vn_contract_price >=
                     cur_backward_price.range_min_value and
                     vn_contract_price <=
                     cur_backward_price.range_max_value then
                    vn_range_gap  := abs(vn_contract_price -
                                         cur_backward_price.range_max_value);
                    vc_range_over := 'Y';
                  else
                    -- else diff range               
                    vn_range_gap := cur_backward_price.range_max_value -
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
                  vn_treatment_charge := vn_treatment_charge -
                                         vn_each_tier_tc_charge;
                  if vc_range_over = 'Y' then
                    exit;
                  end if;
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
            if (cur_tret_charge.position = 'Range Begining' and
               cur_tret_charge.range_max_op = '<=' and
               cc.typical <= cur_tret_charge.range_max_value) or
               (cur_tret_charge.position = 'Range Begining' and
               cur_tret_charge.range_max_op = '<' and
               cc.typical < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position = 'Range End' and
               cur_tret_charge.range_min_op = '>=' and
               cc.typical >= cur_tret_charge.range_min_value) or
               (cur_tret_charge.position = 'Range End' and
               cur_tret_charge.range_min_op = '>' and
               cc.typical > cur_tret_charge.range_min_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>' and
               cur_tret_charge.range_max_op = '<' and
               cc.typical > cur_tret_charge.range_min_value and
               cc.typical < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>=' and
               cur_tret_charge.range_max_op = '<' and
               cc.typical >= cur_tret_charge.range_min_value and
               cc.typical < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>' and
               cur_tret_charge.range_max_op = '<=' and
               cc.typical > cur_tret_charge.range_min_value and
               cc.typical <= cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>=' and
               cur_tret_charge.range_max_op = '<=' and
               cc.typical >= cur_tret_charge.range_min_value and
               cc.typical <= cur_tret_charge.range_max_value) then
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
        --  dbms_output.put_line('The typical value is  ' || vn_typical_val);
        --   dbms_output.put_line('The Assay Range Applicable for this typical is ' ||
        --  --                      vn_min_range || ' --' || vn_max_range);
        -- dbms_output.put_line('The Treatment  charge for this assay Range is  ' ||
        --                      vn_treatment_charge);
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
        -- dbms_output.put_line('The Item  Quantity is   :-- ' ||
        --                      vn_converted_qty);
        vn_total_treat_charge := vn_converted_qty * vn_treatment_charge;
        --  dbms_output.put_line('the treatment  charge is ' ||
        --                     vn_total_treat_charge);
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
      --      dbms_output.put_line('pc_month_prompt_start_date ' || pc_month_prompt_start_date);
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
      --      dbms_output.put_line('pc_month pc_year ' || pc_month || '-' || pc_year);
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
                                        pn_dry_qty          number,
                                        pn_wet_qty          number,
                                        pc_qty_unit_id      varchar2,
                                        pn_cp_price         number,
                                        pc_cp_unit_id       varchar2,
                                        pn_total_tc_charge  out number,
                                        pc_tc_cur_id        out varchar2) is
  vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count           number := 1;
  vn_treatment_charge          number;
  vn_max_range                 number;
  vn_min_range                 number;
  vn_typical_val               number;
  vc_weight_type               varchar2(20);
  vn_contract_price            number;
  vn_base_tret_charge          number;
  vn_each_tier_tc_charge       number;
  vn_range_gap                 number;
  vc_price_unit_id             varchar2(15);
  vc_cur_id                    varchar2(15);
  vc_tc_weight_unit_id         varchar2(15);
  vn_gmr_price                 number;
  vc_gmr_price_unit_id         varchar2(15);
  vc_price_unit_weight_unit_id varchar2(15);
  vc_gmr_price_unit_cur_id     varchar2(15);
  vn_commit_count              number := 0;
  vc_range_over                varchar2(1) := 'N';
  vn_esc_desc_tc_value         number;
  vc_range_type                varchar2(20);
  vn_total_treatment_charge    number := 0;
  vc_add_now                   varchar2(1) := 'N'; -- Set to Y for Fixed when it falls in the slab range
  vc_charge_type               varchar2(10); 
  vn_weight_conv_factor        number;
  vn_total_base_tret_charge    number;
  vn_item_qty                  number;
  vn_cur_factor                number;
  vn_dry_qty                   number;
  vn_wet_qty                   number;                                      
  vc_qty_unit_id               varchar2(20);
  
begin
 vn_dry_qty :=pn_dry_qty;
 vn_wet_qty :=pn_wet_qty;
 vc_qty_unit_id:=pc_qty_unit_id;
  for cc in (select grd.internal_gmr_ref_no internal_gmr_ref_no,
                    grd.internal_grd_ref_no,
                    pqca.typical,
                    pqca.element_id,
                    pci.pcpq_id,
                    pci.pcdi_id,
                    aml.attribute_name element_name,
                    gmr.gmr_ref_no,
                    grd.qty_unit_id grd_qty_unit_id,
                    grd.qty grd_wet_qty,
                    grd.dry_qty grd_dry_qty,
                    nvl(gmr.invoice_cur_decimals,2) pay_cur_decimals
               from process_gmr                 gmr,
                    process_grd                 grd,
                    ash_assay_header            ash,
                    asm_assay_sublot_mapping    asm,
                    pqca_pq_chemical_attributes pqca,
                    aml_attribute_master_list   aml,
                    pci_physical_contract_item  pci,
                    process_spq                 spq
              where ash.ash_id = asm.ash_id
                and asm.asm_id = pqca.asm_id
                and aml.attribute_id = pqca.element_id
                and grd.dbd_id = pc_dbd_id
                and pci.dbd_id = pc_dbd_id
                and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                and gmr.dbd_id = pc_dbd_id
                and grd.internal_contract_item_ref_no =
                    pci.internal_contract_item_ref_no
                and spq.internal_grd_ref_no = grd.internal_grd_ref_no
                and ash.ash_id = spq.weg_avg_pricing_assay_id
                and spq.dbd_id = pc_dbd_id
                and grd.is_deleted = 'N'
                and grd.status = 'Active'
                and spq.is_active = 'Y'
                and spq.element_id = aml.attribute_id
                and gmr.internal_gmr_ref_no=pc_inter_gmr_ref_no
                and grd.internal_grd_ref_no=pc_inter_grd_ref_no
                and spq.element_id=pc_element_id                
             union 
             select dgrd.internal_gmr_ref_no,
                    dgrd.internal_dgrd_ref_no,
                    pqca.typical,
                    pqca.element_id,
                    pci.pcpq_id,
                    pci.pcdi_id,
                    aml.attribute_name element_name,
                    gmr.gmr_ref_no,
                    dgrd.net_weight_unit_id,
                    dgrd.net_weight grd_wet_qty,
                    dgrd.dry_qty grd_dry_qty,
                    nvl(gmr.invoice_cur_decimals,2) pay_cur_decimals
               from process_gmr                 gmr,
                    dgrd_delivered_grd          dgrd,
                    ash_assay_header            ash,
                    asm_assay_sublot_mapping    asm,
                    pqca_pq_chemical_attributes pqca,
                    aml_attribute_master_list   aml,
                    pci_physical_contract_item  pci,
                    process_spq       spq
              where ash.ash_id = asm.ash_id
                and asm.asm_id = pqca.asm_id
                and aml.attribute_id = pqca.element_id
                and dgrd.dbd_id = pc_dbd_id
                and pci.dbd_id = pc_dbd_id
                and dgrd.internal_contract_item_ref_no =
                    pci.internal_contract_item_ref_no
                and ash.ash_id = spq.weg_avg_pricing_assay_id
                and spq.dbd_id = pc_dbd_id
                and spq.element_id = aml.attribute_id
                and dgrd.status = 'Active'
                and dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                and gmr.dbd_id = pc_dbd_id
                and dgrd.internal_dgrd_ref_no = spq.internal_dgrd_ref_no
                and dgrd.internal_gmr_ref_no = spq.internal_gmr_ref_no
                and gmr.internal_gmr_ref_no=pc_inter_gmr_ref_no
                and dgrd.internal_dgrd_ref_no=pc_inter_grd_ref_no
                and spq.element_id=pc_element_id
                and spq.is_active = 'Y')
  loop
  vn_base_tret_charge:=0;
  vn_total_base_tret_charge:=0;
  vc_range_type:=null;
    begin
      --
      -- Get the Price For the GMR
      --
      
      vn_contract_price := pn_cp_price;
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
                                     nvl(pcetc.esc_desc_unit_id, pum.cur_id) cur_id,
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
                                 and gth.dbd_id = pc_dbd_id
                                 and red.element_id = cc.element_id
                                 and pcetc.treatment_charge_unit_id =
                                     ppu.internal_price_unit_id
                                 and ppu.price_unit_id = pum.price_unit_id
                                 and gth.internal_gmr_ref_no =
                                     cc.internal_gmr_ref_no
                                 and gth.pcth_id = pcth.pcth_id
                                 and gth.is_active = 'Y'
                                 and pcetc.is_active = 'Y'
                                 and pcth.is_active = 'Y'
                                 and red.is_active = 'Y'
                                 and tqd.is_active = 'Y'
                              -- Suppose Same contract has Assay Range and Price Range
                              -- Then we have to add it,
                              -- For Price Range , Variable we are existing, let this record
                              -- come at end after assay range calcualtion is over
                               order by pcth.range_type,pcetc.position )
      loop
        vc_cur_id            := cur_tret_charge.cur_id;
        vc_price_unit_id     := cur_tret_charge.price_unit_id;
        --
        -- TC Charge Price Unit should be taken from Range Type = Base or Range Type = Null(Assay Range)
        -- App is storing Price Unit of Price and Not Price Unit of TC Charge
        -- Where is the correct data present?
        -- 1)When Assay Range Use it
        -- 2) Price Range Range, use from Base
        -- 3) When Assay and Price Range use from Assay Range
        -- Data sorted to mee this condition already
        --
        If vc_tc_weight_unit_id is null then
           vc_tc_weight_unit_id := cur_tret_charge.weight_unit_id;
        end if;
        vc_weight_type       := cur_tret_charge.weight_type;
        if vc_range_type is null or vc_range_type=cur_tret_charge.range_type then
        vc_range_type        := cur_tret_charge.range_type;
        else
        vc_range_type        :='Multiple';
        end if;
        vc_add_now           := 'N';
        vc_charge_type       := cur_tret_charge.charge_type;
        if cur_tret_charge.range_type = 'Price Range' then
          --if the CHARGE_TYPE is fixed then it will
          --behave as the slab as same as the assay range
          --No base concept is here
          vn_treatment_charge := 0;
          if cur_tret_charge.charge_type = 'Fixed' then
            if (cur_tret_charge.position = 'Range Begining' and
               cur_tret_charge.range_max_op = '<=' and
               vn_contract_price <= cur_tret_charge.range_max_value) or
               (cur_tret_charge.position = 'Range Begining' and
               cur_tret_charge.range_max_op = '<' and
               vn_contract_price < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position = 'Range End' and
               cur_tret_charge.range_min_op = '>=' and
               vn_contract_price >= cur_tret_charge.range_min_value) or
               (cur_tret_charge.position = 'Range End' and
               cur_tret_charge.range_min_op = '>' and
               vn_contract_price > cur_tret_charge.range_min_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>' and
               cur_tret_charge.range_max_op = '<' and
               vn_contract_price > cur_tret_charge.range_min_value and
               vn_contract_price < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>=' and
               cur_tret_charge.range_max_op = '<' and
               vn_contract_price >= cur_tret_charge.range_min_value and
               vn_contract_price < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>' and
               cur_tret_charge.range_max_op = '<=' and
               vn_contract_price > cur_tret_charge.range_min_value and
               vn_contract_price <= cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>=' and
               cur_tret_charge.range_max_op = '<=' and
               vn_contract_price >= cur_tret_charge.range_min_value and
               vn_contract_price <= cur_tret_charge.range_max_value) then
              vn_treatment_charge := cur_tret_charge.treatment_charge;
              vn_total_base_tret_charge := vn_total_base_tret_charge+cur_tret_charge.treatment_charge;
              vc_add_now          := 'Y';
            end if;
          elsif cur_tret_charge.charge_type = 'Variable' then
            vc_range_over := 'N'; -- Initialize for each record
            --Take the base price and its min and max range
            begin
              select pcetc.range_min_value,
                     pcetc.range_max_value,
                     pcetc.treatment_charge,
                     pcetc.weight_type
                into vn_min_range,
                     vn_max_range,
                     vn_base_tret_charge,
                     vc_weight_type
                from pcetc_pc_elem_treatment_charge pcetc
               where pcetc.pcth_id = cur_tret_charge.pcth_id
                 and pcetc.is_active = 'Y'
                 and pcetc.position = 'Base'
                 and pcetc.charge_type = 'Variable'
                 and pcetc.dbd_id = pc_dbd_id;
            exception
              when no_data_found then
                vn_max_range        := 0;
                vn_min_range        := 0;
                vn_base_tret_charge := 0;
            end;
            vn_total_base_tret_charge:=vn_total_base_tret_charge+vn_base_tret_charge;
            --according to the contract price , the price tier
            --will be find out, it may forward or back ward
            --Both vn_max_range and vn_min_range are same
            --in case if base
            if vn_contract_price > vn_max_range then
              vn_treatment_charge := vn_base_tret_charge;
              --go forward for the price range
              for cur_forward_price in (select pcetc.range_min_value,
                                               pcetc.range_min_op,
                                               nvl(pcetc.range_max_value,
                                                   vn_contract_price) range_max_value,
                                               pcetc.range_max_op,
                                               pcetc.esc_desc_value,
                                               pcetc.esc_desc_unit_id,
                                               pcetc.treatment_charge,
                                               pcetc.treatment_charge_unit_id,
                                               pcetc.charge_basis
                                          from pcetc_pc_elem_treatment_charge pcetc
                                         where pcetc.pcth_id =
                                               cur_tret_charge.pcth_id
                                           and nvl(pcetc.range_min_value, 0) >=
                                               vn_max_range
                                              -- Because There is a defintely range for escalator saying > Base 
                                              -- If base is 6000, the escalator entry must say first entry as > 6000 and <=7000, > 7000 to 8000 or 
                                              -- If we do not put >= price one entry will be missed
                                           and nvl(pcetc.position, 'a') <>
                                               'Base'
                                           and pcetc.is_active = 'Y'
                                           and pcetc.dbd_id = pc_dbd_id
                                         order by pcetc.range_max_value asc nulls last)
              loop
                -- if price is in the range take diff of price and max range
                if vn_contract_price >= cur_forward_price.range_min_value and
                   vn_contract_price <= cur_forward_price.range_max_value then
                  vn_range_gap  := abs(vn_contract_price -
                                       cur_forward_price.range_min_value);
                  vc_range_over := 'Y';
                else
                  -- else diff range               
                  vn_range_gap := cur_forward_price.range_max_value -
                                  cur_forward_price.range_min_value;
                end if;
                if cur_forward_price.charge_basis = 'absolute' then
                  vn_each_tier_tc_charge := ceil(vn_range_gap /
                                                 nvl(cur_forward_price.esc_desc_value,
                                                     1)) *
                                            cur_forward_price.treatment_charge;
                elsif cur_forward_price.charge_basis = 'fractions Pro-Rata' then
                  vn_each_tier_tc_charge := (vn_range_gap /
                                            nvl(cur_forward_price.esc_desc_value,
                                                 1)) *
                                            cur_forward_price.treatment_charge;
                end if;
              
                vn_treatment_charge := vn_treatment_charge +
                                       vn_each_tier_tc_charge;
                if vc_range_over = 'Y' then
                  exit;
                end if;
              end loop;
            elsif vn_contract_price < vn_min_range then
              vn_treatment_charge := vn_base_tret_charge; --
              --go back ward for the price range
              for cur_backward_price in (select nvl(pcetc.range_min_value,
                                                    vn_contract_price) range_min_value,
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
                                            and nvl(pcetc.range_min_value, 0) <
                                                vn_min_range
                                               -- Because Deescalator has range saying < Base 
                                               -- If base is 6000, Deescalator entry has to < 6000
                                            and nvl(pcetc.position, 'a') <>
                                                'Base'
                                            and pcetc.is_active = 'Y'
                                            and pcetc.dbd_id = pc_dbd_id
                                          order by pcetc.range_min_value desc nulls last)
              loop
                -- if price is in the range take diff of price and max range
                if vn_contract_price >= cur_backward_price.range_min_value and
                   vn_contract_price <= cur_backward_price.range_max_value then
                  vn_range_gap  := abs(vn_contract_price -
                                       cur_backward_price.range_max_value);
                  vc_range_over := 'Y';
                else
                  -- else diff range               
                  vn_range_gap := cur_backward_price.range_max_value -
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
                vn_treatment_charge := vn_treatment_charge -
                                       vn_each_tier_tc_charge;
                if vc_range_over = 'Y' then
                  exit;
                end if;
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
          if (cur_tret_charge.position = 'Range Begining' and
             cur_tret_charge.range_max_op = '<=' and
             cc.typical <= cur_tret_charge.range_max_value) or
             (cur_tret_charge.position = 'Range Begining' and
             cur_tret_charge.range_max_op = '<' and
             cc.typical < cur_tret_charge.range_max_value) or
             (cur_tret_charge.position = 'Range End' and
             cur_tret_charge.range_min_op = '>=' and
             cc.typical >= cur_tret_charge.range_min_value) or
             (cur_tret_charge.position = 'Range End' and
             cur_tret_charge.range_min_op = '>' and
             cc.typical > cur_tret_charge.range_min_value) or
             (cur_tret_charge.position is null and
             cur_tret_charge.range_min_op = '>' and
             cur_tret_charge.range_max_op = '<' and
             cc.typical > cur_tret_charge.range_min_value and
             cc.typical < cur_tret_charge.range_max_value) or
             (cur_tret_charge.position is null and
             cur_tret_charge.range_min_op = '>=' and
             cur_tret_charge.range_max_op = '<' and
             cc.typical >= cur_tret_charge.range_min_value and
             cc.typical < cur_tret_charge.range_max_value) or
             (cur_tret_charge.position is null and
             cur_tret_charge.range_min_op = '>' and
             cur_tret_charge.range_max_op = '<=' and
             cc.typical > cur_tret_charge.range_min_value and
             cc.typical <= cur_tret_charge.range_max_value) or
             (cur_tret_charge.position is null and
             cur_tret_charge.range_min_op = '>=' and
             cur_tret_charge.range_max_op = '<=' and
             cc.typical >= cur_tret_charge.range_min_value and
             cc.typical <= cur_tret_charge.range_max_value) then
            vn_treatment_charge := cur_tret_charge.treatment_charge;
            vn_max_range        := cur_tret_charge.range_max_value;
            vn_min_range        := cur_tret_charge.range_min_value;
            vn_typical_val      := cc.typical;
            vc_weight_type      := cur_tret_charge.weight_type;
            vn_total_base_tret_charge := cur_tret_charge.treatment_charge;
            vc_add_now          := 'Y';
          end if;
        end if;
        -- I will exit from the loop when it is tier base ,
        -- as the inner loop is done the calculation.
        if cur_tret_charge.range_type = 'Price Range' and
           cur_tret_charge.charge_type = 'Variable' then
          vn_total_treatment_charge  := vn_total_treatment_charge +
                                        vn_treatment_charge; 
          exit;
        end if;
        --
        -- Get the total only when it was in the range, skip otherwise
        -- If it is Price range variable it adds above exits the loop
        --
        if (cur_tret_charge.range_type = 'Price Range' and
           cur_tret_charge.charge_type = 'Fixed' and vc_add_now = 'Y') or
           cur_tret_charge.range_type = 'Assay Range' and vc_add_now = 'Y' then
          vn_total_treatment_charge := vn_total_treatment_charge +
                                       vn_treatment_charge;
          vc_add_now                := 'N';
        end if;        
      end loop;
    end;
    ---
  begin
    select scd.factor
      into vn_cur_factor
      from scd_sub_currency_detail scd
     where scd.is_deleted = 'N'
       and scd.sub_cur_id = vc_cur_id;
  exception
    when others then
      vn_cur_factor := 1;
  end;

  begin
      select ucm.multiplication_factor
        into vn_weight_conv_factor
        from ucm_unit_conversion_master ucm
       where ucm.from_qty_unit_id =vc_qty_unit_id 
         and ucm.to_qty_unit_id = vc_tc_weight_unit_id;
    exception
      when others then
        vn_weight_conv_factor := -1;
    end;                   
  
  if vc_weight_type ='Dry' then 
  vn_total_treatment_charge:=vn_total_treatment_charge*vn_dry_qty*vn_cur_factor*vn_weight_conv_factor;
  else
  vn_total_treatment_charge:=vn_total_treatment_charge*vn_wet_qty*vn_cur_factor*vn_weight_conv_factor;
  end if;
  /*  round((case when getc.weight_type = 'Dry' then 
   getc.grd_dry_qty * getc.grd_to_tc_weight_factor 
   * getc.base_tc_value else getc.grd_wet_qty 
   * getc.grd_to_tc_weight_factor * 
   getc.base_tc_value end * getc.currency_factor
   ), getc.pay_cur_decimals),
     
 where getc.process_id = pc_process_id;*/
    
 
  end loop;
    pn_total_tc_charge := vn_total_treatment_charge;
    pc_tc_cur_id       := vc_cur_id;
  
  exception
    when others then
      vn_total_treatment_charge := -1;
      vc_price_unit_id     := null;
  end;
  procedure sp_get_gmr_tc_by_assay(pc_inter_gmr_ref_no varchar2,
                                   pc_inter_grd_ref_no varchar2,
                                   pc_element_id       varchar2,
                                   pc_dbd_id           varchar2,
                                   pn_cp_price         number,
                                   pc_cp_unit_id       varchar2,
                                   pc_ash_id           varchar2,
                                   pn_dry_qty          number,
                                   pc_qty_unit_id      varchar2,
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
    --vn_min_price           number;
    --vn_max_price           number;
    vc_range_over varchar2(1) := 'N';
  begin
    vn_contract_price   := pn_cp_price;
    vn_treatment_charge := 0;
    for cc in (select pc_inter_grd_ref_no internal_grd_ref_no,
                      ash.ash_id,
                      ash.assay_type,
                      asm.sub_lot_no,
                      pqca.typical,
                      rm.qty_unit_id_numerator,
                      rm.qty_unit_id_denominator,
                      rm.ratio_name,
                      pqca.element_id,
                      aml.underlying_product_id,
                      t.pcpq_id
                 from tsq_temp_stock_quality      t,
                      ash_assay_header            ash,
                      asm_assay_sublot_mapping    asm,
                      pqca_pq_chemical_attributes pqca,
                      rm_ratio_master             rm,
                      aml_attribute_master_list   aml
                where ash.ash_id = asm.ash_id
                  and asm.asm_id = pqca.asm_id
                  and rm.ratio_id = pqca.unit_of_measure
                  and aml.attribute_id = pqca.element_id
                  and pqca.element_id = pc_element_id
                  and t.internal_grd_ref_no = pc_inter_grd_ref_no
                  and ash.ash_id = pc_ash_id)
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
                                       nvl(pcetc.esc_desc_unit_id,
                                           pum.cur_id) cur_id,
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
                                   and gth.dbd_id = pc_dbd_id
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
            vn_total_gmr_tc_value := 0;
            if cur_tret_charge.charge_type = 'Fixed' then
              if (cur_tret_charge.position = 'Range Begining' and
                 cur_tret_charge.range_max_op = '<=' and
                 vn_contract_price <= cur_tret_charge.range_max_value) or
                 (cur_tret_charge.position = 'Range Begining' and
                 cur_tret_charge.range_max_op = '<' and
                 vn_contract_price < cur_tret_charge.range_max_value) or
                 (cur_tret_charge.position = 'Range End' and
                 cur_tret_charge.range_min_op = '>=' and
                 vn_contract_price >= cur_tret_charge.range_min_value) or
                 (cur_tret_charge.position = 'Range End' and
                 cur_tret_charge.range_min_op = '>' and
                 vn_contract_price > cur_tret_charge.range_min_value) or
                 (cur_tret_charge.position is null and
                 cur_tret_charge.range_min_op = '>' and
                 cur_tret_charge.range_max_op = '<' and
                 vn_contract_price > cur_tret_charge.range_min_value and
                 vn_contract_price < cur_tret_charge.range_max_value) or
                 (cur_tret_charge.position is null and
                 cur_tret_charge.range_min_op = '>=' and
                 cur_tret_charge.range_max_op = '<' and
                 vn_contract_price >= cur_tret_charge.range_min_value and
                 vn_contract_price < cur_tret_charge.range_max_value) or
                 (cur_tret_charge.position is null and
                 cur_tret_charge.range_min_op = '>' and
                 cur_tret_charge.range_max_op = '<=' and
                 vn_contract_price > cur_tret_charge.range_min_value and
                 vn_contract_price <= cur_tret_charge.range_max_value) or
                 (cur_tret_charge.position is null and
                 cur_tret_charge.range_min_op = '>=' and
                 cur_tret_charge.range_max_op = '<=' and
                 vn_contract_price >= cur_tret_charge.range_min_value and
                 vn_contract_price <= cur_tret_charge.range_max_value) then
                vn_treatment_charge := cur_tret_charge.treatment_charge;
                --   dbms_output.put_line(vn_treatment_charge);
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
                   and pcetc.is_active = 'Y'
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
              
                -- Go forward for the price range
                for cur_forward_price in (select pcetc.range_min_value range_min_value,
                                                 pcetc.range_min_op,
                                                 nvl(pcetc.range_max_value,
                                                     vn_contract_price) range_max_value,
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
                                                     0) >= vn_max_range
                                                -- Because There is a defintely range for escalator saying > Base 
                                                -- If base is 6000, the escalator entry must say first entry as > 6000 and <=7000, > 7000 to 8000 or 
                                                -- If we do not put >= price one entry will be missed
                                             and nvl(pcetc.position, 'a') <>
                                                 'Base'
                                             and pcetc.dbd_id = pc_dbd_id
                                           order by pcetc.range_max_value asc nulls last)
                loop
                  -- if price is in the range take diff of price and max range                                                       
                
                  if vn_contract_price >= cur_forward_price.range_min_value and
                     vn_contract_price <= cur_forward_price.range_max_value then
                    vn_range_gap  := abs(vn_contract_price -
                                         cur_forward_price.range_min_value);
                    vc_range_over := 'Y';
                  else
                    -- else diff range               
                    vn_range_gap := cur_forward_price.range_max_value -
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
                  if vc_range_over = 'Y' then
                    exit;
                  end if;
                end loop;
              elsif vn_contract_price < vn_min_range then
                vn_treatment_charge := vn_base_tret_charge; --
                --go back ward for the price range
                for cur_backward_price in (select nvl(pcetc.range_min_value,
                                                      vn_contract_price) range_min_value,
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
                                                      0) < vn_min_range
                                                 -- Because Deescalator has range saying < Base 
                                                 -- If base is 6000, Deescalator entry has to < 6000
                                              and nvl(pcetc.position, 'a') <>
                                                  'Base'
                                              and pcetc.is_active = 'Y'
                                              and pcetc.dbd_id = pc_dbd_id
                                            order by pcetc.range_min_value desc nulls last)
                loop
                  -- if price is in the range take diff of price and max range                 
                  if vn_contract_price >=
                     cur_backward_price.range_min_value and
                     vn_contract_price <=
                     cur_backward_price.range_max_value then
                    vn_range_gap  := abs(vn_contract_price -
                                         cur_backward_price.range_max_value);
                    vc_range_over := 'Y';
                  else
                    -- else diff range               
                    vn_range_gap := cur_backward_price.range_max_value -
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
                  vn_treatment_charge := vn_treatment_charge -
                                         vn_each_tier_tc_charge;
                  if vc_range_over = 'Y' then
                    exit;
                  end if;
                end loop;
              elsif vn_contract_price = vn_min_range and
                    vn_contract_price = vn_max_range then
                vn_treatment_charge := vn_base_tret_charge;
                -- take the base price only
              end if;
            end if;
          elsif cur_tret_charge.range_type = 'Assay Range' then
            --Make sure the range for the element is mentation properly.
            --Only Slab basics charge
            if (cur_tret_charge.position = 'Range Begining' and
               cur_tret_charge.range_max_op = '<=' and
               cc.typical <= cur_tret_charge.range_max_value) or
               (cur_tret_charge.position = 'Range Begining' and
               cur_tret_charge.range_max_op = '<' and
               cc.typical < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position = 'Range End' and
               cur_tret_charge.range_min_op = '>=' and
               cc.typical >= cur_tret_charge.range_min_value) or
               (cur_tret_charge.position = 'Range End' and
               cur_tret_charge.range_min_op = '>' and
               cc.typical > cur_tret_charge.range_min_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>' and
               cur_tret_charge.range_max_op = '<' and
               cc.typical > cur_tret_charge.range_min_value and
               cc.typical < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>=' and
               cur_tret_charge.range_max_op = '<' and
               cc.typical >= cur_tret_charge.range_min_value and
               cc.typical < cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>' and
               cur_tret_charge.range_max_op = '<=' and
               cc.typical > cur_tret_charge.range_min_value and
               cc.typical <= cur_tret_charge.range_max_value) or
               (cur_tret_charge.position is null and
               cur_tret_charge.range_min_op = '>=' and
               cur_tret_charge.range_max_op = '<=' and
               cc.typical >= cur_tret_charge.range_min_value and
               cc.typical <= cur_tret_charge.range_max_value) then
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
        -- dbms_output.put_line('The typical value is  ' || vn_typical_val);
        -- dbms_output.put_line('The Assay Range Applicable for this typical is ' ||
        --                     vn_min_range || ' --' || vn_max_range);
        --  dbms_output.put_line('The Treatment  charge for this assay Range is  ' ||
        --                    vn_treatment_charge);
      
        --For TC , it is calculated on item Qty not on the element Qty
        vn_converted_qty := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                 pc_qty_unit_id,
                                                                 vc_rc_weight_unit_id,
                                                                 pn_dry_qty);
        --Here no need of the typicla value as penalty is on item level   not on the element level
        --  dbms_output.put_line('The Item  Quantity is   :-- ' ||
        --                      vn_converted_qty);
        vn_total_treat_charge := vn_converted_qty * vn_treatment_charge;
        -- dbms_output.put_line('the treatment  charge is ' ||
        --                    vn_total_treat_charge);
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
  procedure sp_get_gmr_rc_by_assay(pc_inter_gmr_ref_no varchar2,
                                   pc_inter_grd_ref_no varchar2,
                                   pc_element_id       varchar2,
                                   pc_dbd_id           varchar2,
                                   pn_cp_price         number,
                                   pc_cp_unit_id       varchar2,
                                   pc_ash_id           varchar2,
                                   pn_payable_qty      number,
                                   pc_qty_unit_id      varchar2,
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
    --vn_min_price           number;
    --vn_max_price           number;
    vc_range_over varchar2(1) := 'N';
  begin
    vn_refine_charge  := 0;
    vn_contract_price := pn_cp_price;
    --Get the Charge Details 
    for cc in (select t.internal_grd_ref_no,
                      t.internal_contract_ref_no,
                      t.internal_contract_item_ref_no,
                      ash.ash_id,
                      ash.assay_type,
                      asm.sub_lot_no,
                      pqca.typical,
                      rm.qty_unit_id_numerator,
                      rm.qty_unit_id_denominator,
                      rm.ratio_name,
                      pqca.element_id,
                      aml.underlying_product_id,
                      t.pcpq_id,
                      (case
                        when rm.ratio_name = '%' then
                         ash.net_weight_unit
                        else
                         rm.qty_unit_id_numerator
                      end) payable_qty_unit,
                      t.pcdi_id
                 from tsq_temp_stock_quality         t,
                      ash_assay_header               ash,
                      asm_assay_sublot_mapping       asm,
                      pqca_pq_chemical_attributes    pqca,
                      pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
                      rm_ratio_master                rm,
                      aml_attribute_master_list      aml
                where ash.ash_id = asm.ash_id
                  and ash.ash_id = pc_ash_id
                  and asm.asm_id = pqca.asm_id
                  and pqca.pqca_id = pqcapd.pqca_id
                  and rm.ratio_id = pqca.unit_of_measure
                  and aml.attribute_id = pqca.element_id
                  and pqca.element_id = pc_element_id
                  and t.internal_grd_ref_no = pc_inter_grd_ref_no)
    loop
      --for refine charge , the charge will applyed on
      --payable qty only.So deduct the moisture and other deductable item
      --from the item qty. 
      --include refine charge from the contract creation.
      --If Yes then take the conract include_ref_charge 
      --else go for the Charge Range
      --   dbms_output.put_line('payable qty ' || cc.sub_lot_no || ' payable ' ||
      --            cc.payable_qty || ' qty unit ' ||
      --           cc.payable_qty_unit);
    
      begin
        select pcepc.include_ref_charges
          into vc_include_ref_charge
          from pcpch_pc_payble_content_header pcpch,
               pcepc_pc_elem_payable_content  pcepc,
               pqd_payable_quality_details    pqd,
               dipch_di_payablecontent_header dipch
         where pcpch.pcpch_id = pcepc.pcpch_id
           and pcpch.dbd_id = pc_dbd_id
           and pcepc.dbd_id = pc_dbd_id
           and pcpch.element_id = cc.element_id
           and pcpch.internal_contract_ref_no = cc.internal_contract_ref_no
           and (pcepc.range_min_value <= cc.typical or
               pcepc.position = 'Range Begining')
           and (pcepc.range_max_value > cc.typical or
               pcepc.position = 'Range End')
           and pcpch.is_active = 'Y'
           and pcepc.is_active = 'Y'
           and pqd.pcpch_id = pcpch.pcpch_id
           and pqd.pcpq_id = cc.pcpq_id
           and pqd.is_active = 'Y'
           and pqd.dbd_id = pc_dbd_id
           and dipch.dbd_id = pc_dbd_id
           and dipch.pcpch_id = pcpch.pcpch_id
           and dipch.pcdi_id = cc.pcdi_id
           and dipch.is_active = 'Y'
           and rownum < 2; -- I never want 2 record from this;
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
                                   from pcdi_pc_delivery_item          pcdi,
                                        pci_physical_contract_item     pci,
                                        pcpch_pc_payble_content_header pcpch,
                                        pcepc_pc_elem_payable_content  pcepc,
                                        ppu_product_price_units        ppu,
                                        pum_price_unit_master          pum,
                                        gmr_goods_movement_record      gmr,
                                        grh_gmr_refining_header        grh
                                  where pcpch.internal_contract_ref_no =
                                        pcdi.internal_contract_ref_no
                                    and pcdi.pcdi_id = pci.pcdi_id
                                    and pcpch.element_id = cc.element_id
                                    and pcpch.pcpch_id = pcepc.pcpch_id
                                    and pcepc.include_ref_charges = 'Y'
                                    and ppu.internal_price_unit_id =
                                        pcepc.refining_charge_unit_id
                                    and ppu.price_unit_id =
                                        pum.price_unit_id
                                    and pci.internal_contract_item_ref_no =
                                        cc.internal_contract_item_ref_no
                                    and gmr.internal_contract_ref_no =
                                        cc.internal_contract_ref_no
                                    and gmr.internal_gmr_ref_no =
                                        grh.internal_gmr_ref_no
                                    and pci.dbd_id = pc_dbd_id
                                    and pcdi.dbd_id = pc_dbd_id
                                    and pcpch.dbd_id = pc_dbd_id
                                    and pcepc.dbd_id = pc_dbd_id
                                    and grh.dbd_id = pc_dbd_id
                                    and pci.is_active = 'Y'
                                    and pcdi.is_active = 'Y'
                                    and pcpch.is_active = 'Y'
                                    and pcepc.is_active = 'Y')
          loop
            vc_rc_weight_unit_id := cur_ref_charge.weight_unit_id;
            vc_cur_id            := cur_ref_charge.cur_id;
            vc_price_unit_id     := cur_ref_charge.price_unit_id;
          
            if (cur_ref_charge.position = 'Range Begining' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical <= cur_ref_charge.range_max_value) or
               (cur_ref_charge.position = 'Range Begining' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical <= cur_ref_charge.range_max_value) or
               (cur_ref_charge.position = 'Range End' and
               cur_ref_charge.range_min_op = '>=' and
               cc.typical >= cur_ref_charge.range_min_value) or
               (cur_ref_charge.position = 'Range End' and
               cur_ref_charge.range_min_op = '>' and
               cc.typical > cur_ref_charge.range_min_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical > cur_ref_charge.range_min_value and
               cc.typical < cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>=' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical >= cur_ref_charge.range_min_value and
               cc.typical < cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical > cur_ref_charge.range_min_value and
               cc.typical <= cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>=' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical >= cur_ref_charge.range_min_value and
               cc.typical <= cur_ref_charge.range_max_value) then
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
                                        nvl(pcerc.esc_desc_unit_id,
                                            pum.cur_id) cur_id,
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
                                    and grh.dbd_id = pc_dbd_id
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
              vn_gmr_rc_charges := 0;
              --if the CHARGE_TYPE is fixed then it will
              --behave as the slab as same as the assay range
              --No base concept is here
              if cur_ref_charge.charge_type = 'Fixed' then
                if (cur_ref_charge.position = 'Range Begining' and
                   cur_ref_charge.range_max_op = '<=' and
                   vn_contract_price <= cur_ref_charge.range_max_value) or
                   (cur_ref_charge.position = 'Range Begining' and
                   cur_ref_charge.range_max_op = '<' and
                   vn_contract_price < cur_ref_charge.range_max_value) or
                   (cur_ref_charge.position = 'Range End' and
                   cur_ref_charge.range_min_op = '>=' and
                   vn_contract_price >= cur_ref_charge.range_min_value) or
                   (cur_ref_charge.position = 'Range End' and
                   cur_ref_charge.range_min_op = '>' and
                   vn_contract_price > cur_ref_charge.range_min_value) or
                   (cur_ref_charge.position is null and
                   cur_ref_charge.range_min_op = '>' and
                   cur_ref_charge.range_max_op = '<' and
                   vn_contract_price > cur_ref_charge.range_min_value and
                   vn_contract_price < cur_ref_charge.range_max_value) or
                   (cur_ref_charge.position is null and
                   cur_ref_charge.range_min_op = '>=' and
                   cur_ref_charge.range_max_op = '<' and
                   vn_contract_price >= cur_ref_charge.range_min_value and
                   vn_contract_price < cur_ref_charge.range_max_value) or
                   (cur_ref_charge.position is null and
                   cur_ref_charge.range_min_op = '>' and
                   cur_ref_charge.range_max_op = '<=' and
                   vn_contract_price > cur_ref_charge.range_min_value and
                   vn_contract_price <= cur_ref_charge.range_max_value) or
                   (cur_ref_charge.position is null and
                   cur_ref_charge.range_min_op = '>=' and
                   cur_ref_charge.range_max_op = '<=' and
                   vn_contract_price >= cur_ref_charge.range_min_value and
                   vn_contract_price <= cur_ref_charge.range_max_value) then
                  vn_refine_charge := cur_ref_charge.refining_charge;
                  --   dbms_output.put_line(vn_refine_charge);
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
                     and pcerc.is_active = 'Y'
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
                                                   nvl(pcerc.range_max_value,
                                                       vn_contract_price) range_max_value,
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
                                                       0) >= vn_max_range
                                                  -- Because There is a defintely range for escalator saying > Base 
                                                  -- If base is 6000, the escalator entry must say first entry as > 6000 and <=7000, > 7000 to 8000 or 
                                                  -- If we do not put >= price one entry will be missed
                                               and nvl(pcerc.position, 'a') <>
                                                   'Base'
                                               and pcerc.is_active = 'Y'
                                               and pcerc.dbd_id = pc_dbd_id
                                             order by pcerc.range_max_value asc nulls last)
                  loop
                    -- if price is in the range take diff of price and max range                  
                    if vn_contract_price >=
                       cur_forward_price.range_min_value and
                       vn_contract_price <=
                       cur_forward_price.range_max_value then
                      vn_range_gap := abs(vn_contract_price -
                                          cur_forward_price.range_min_value);
                    
                      vc_range_over := 'Y';
                    else
                      -- else diff range               
                      vn_range_gap := cur_forward_price.range_max_value -
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
                    if vc_range_over = 'Y' then
                      exit;
                    end if;
                  end loop;
                elsif vn_contract_price < vn_min_range then
                  --go back ward for the price range
                  vn_refine_charge := vn_base_refine_charge;
                  for cur_backward_price in (select nvl(pcerc.range_min_value,
                                                        vn_contract_price) range_min_value,
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
                                                        0) < vn_min_range
                                                   -- Because Deescalator has range saying < Base 
                                                   -- If base is 6000, Deescalator entry has to < 6000
                                                and nvl(pcerc.position, 'a') <>
                                                    'Base'
                                                and pcerc.is_active = 'Y'
                                                and pcerc.dbd_id = pc_dbd_id
                                              order by pcerc.range_min_value desc nulls last)
                  loop
                    -- if price is in the range take diff of price and max range 
                    if vn_contract_price >=
                       cur_backward_price.range_min_value and
                       vn_contract_price <=
                       cur_backward_price.range_max_value then
                      vn_range_gap  := abs(vn_contract_price -
                                           cur_backward_price.range_max_value);
                      vc_range_over := 'Y';
                    else
                      -- else diff range               
                      vn_range_gap := cur_backward_price.range_max_value -
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
                    vn_refine_charge := vn_refine_charge -
                                        vn_each_tier_rc_charge;
                    if vc_range_over = 'Y' then
                      exit;
                    end if;
                  end loop;
                elsif vn_contract_price = vn_min_range and
                      vn_contract_price = vn_max_range then
                  vn_refine_charge := vn_base_refine_charge;
                  --take the base price only
                end if;
              end if;
            elsif cur_ref_charge.range_type = 'Assay Range' then
              --Make sure the range for the element is mentation properly.
              if (cur_ref_charge.position = 'Range Begining' and
                 cur_ref_charge.range_max_op = '<=' and
                 cc.typical <= cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position = 'Range Begining' and
                 cur_ref_charge.range_max_op = '<' and
                 cc.typical < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position = 'Range End' and
                 cur_ref_charge.range_min_op = '>=' and
                 cc.typical >= cur_ref_charge.range_min_value) or
                 (cur_ref_charge.position = 'Range End' and
                 cur_ref_charge.range_min_op = '>' and
                 cc.typical > cur_ref_charge.range_min_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>' and
                 cur_ref_charge.range_max_op = '<' and
                 cc.typical > cur_ref_charge.range_min_value and
                 cc.typical < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>=' and
                 cur_ref_charge.range_max_op = '<' and
                 cc.typical >= cur_ref_charge.range_min_value and
                 cc.typical < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>' and
                 cur_ref_charge.range_max_op = '<=' and
                 cc.typical > cur_ref_charge.range_min_value and
                 cc.typical <= cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>=' and
                 cur_ref_charge.range_max_op = '<=' and
                 cc.typical >= cur_ref_charge.range_min_value and
                 cc.typical <= cur_ref_charge.range_max_value) then
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
          --   dbms_output.put_line('The typical value is  ' || vn_typical_val);
          --   dbms_output.put_line('The Assay Range Applicable for this typical is ' ||
          --                       vn_min_range || ' --' || vn_max_range);
          --   dbms_output.put_line('The Refine charge for this assay Range is  ' ||
          --                       vn_refine_charge);
        exception
          when others then
            vn_refine_charge := 0;
            vc_price_unit_id := null;
        end;
      end if;
    
      vn_pricable_qty      := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                   pc_qty_unit_id,
                                                                   vc_rc_weight_unit_id,
                                                                   pn_payable_qty);
      vn_tot_refine_charge := vn_pricable_qty * vn_refine_charge;
      --  dbms_output.put_line('The refine  quantity is ' || vn_pricable_qty);
      vn_gmr_rc_charges := vn_gmr_rc_charges + vn_tot_refine_charge;
      --  dbms_output.put_line('The refine  Amount is ' ||
    --                    vn_tot_refine_charge);
    end loop;
    pn_total_rc_charge := vn_gmr_rc_charges;
    pc_rc_cur_id       := vc_cur_id;
  
  exception
    when others then
      vn_tot_refine_charge := -1;
      vc_price_unit_id     := null;
    
  end;
  procedure sp_get_gmr_pc_by_assay(pc_inter_gmr_ref_no varchar2,
                                   pc_inter_grd_ref_no varchar2,
                                   pc_dbd_id           varchar2,
                                   pc_element_id       varchar2,
                                   pc_ash_id           varchar2,
                                   pn_dry_qty          number,
                                   pn_wet_qty          number,
                                   pc_qty_unit_id      varchar2,
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
    for cc in (select t.internal_grd_ref_no,
                      ash.ash_id,
                      ash.assay_type,
                      asm.sub_lot_no,
                      pqca.typical,
                      rm.qty_unit_id_numerator,
                      rm.qty_unit_id_denominator,
                      rm.ratio_name,
                      pqca.element_id,
                      aml.underlying_product_id,
                      t.pcpq_id
                 from tsq_temp_stock_quality      t,
                      ash_assay_header            ash,
                      asm_assay_sublot_mapping    asm,
                      pqca_pq_chemical_attributes pqca,
                      rm_ratio_master             rm,
                      aml_attribute_master_list   aml
                where ash.ash_id = asm.ash_id
                  and asm.asm_id = pqca.asm_id
                  and rm.ratio_id = pqca.unit_of_measure
                  and aml.attribute_id = pqca.element_id
                  and nvl(pqca.is_elem_for_pricing, 'N') = 'N'
                  and pqca.element_id = pc_element_id
                  and t.internal_grd_ref_no = pc_inter_grd_ref_no
                  and ash.ash_id = pc_ash_id)
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
                               and gph.dbd_id = pc_dbd_id
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
                               and ppu.price_unit_id = pum.price_unit_id)
      loop
        vc_price_unit_id       := cur_pc_charge.price_unit_id;
        vc_cur_id              := cur_pc_charge.cur_id;
        vn_element_pc_charge   := 0;
        vc_penalty_weight_type := cur_pc_charge.penalty_weight_type;
        --check the penalty charge type
        if cur_pc_charge.penalty_charge_type = 'Fixed' then
          --Find the PC charge which will fall in the appropriate range.
          --as according to the typical value   
          if (cur_pc_charge.position = 'Range Begining' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical <= cur_pc_charge.range_max_value) or
             (cur_pc_charge.position = 'Range Begining' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position = 'Range End' and
             cur_pc_charge.range_min_op = '>=' and
             cc.typical >= cur_pc_charge.range_min_value) or
             (cur_pc_charge.position = 'Range End' and
             cur_pc_charge.range_min_op = '>' and
             cc.typical > cur_pc_charge.range_min_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical > cur_pc_charge.range_min_value and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>=' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical >= cur_pc_charge.range_min_value and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical > cur_pc_charge.range_min_value and
             cc.typical <= cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>=' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical >= cur_pc_charge.range_min_value and
             cc.typical <= cur_pc_charge.range_max_value) then
          
            vn_penalty_charge := cur_pc_charge.penalty_amount;
            vn_max_range      := cur_pc_charge.range_max_value;
            vn_min_range      := cur_pc_charge.range_min_value;
            vn_typical_val    := cc.typical;
            if vc_penalty_weight_type = 'Dry' then
              vn_converted_qty := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                       pc_qty_unit_id,
                                                                       cur_pc_charge.weight_unit_id,
                                                                       pn_dry_qty);
            else
              vn_converted_qty := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                       pc_qty_unit_id,
                                                                       cur_pc_charge.weight_unit_id,
                                                                       pn_wet_qty);
            
            end if;
          
            vn_element_pc_charge := vn_penalty_charge * vn_converted_qty;
          end if;
        elsif cur_pc_charge.penalty_charge_type = 'Variable' then
          if cur_pc_charge.penalty_basis = 'Quantity' and
             cur_pc_charge.slab_tier = 'Tier' then
            vn_typical_val := cc.typical;
            --find the range where the typical falls in 
            if (cur_pc_charge.position = 'Range Begining' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val <= cur_pc_charge.range_max_value) or
               (cur_pc_charge.position = 'Range Begining' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position = 'Range End' and
               cur_pc_charge.range_min_op = '>=' and
               vn_typical_val >= cur_pc_charge.range_min_value) or
               (cur_pc_charge.position = 'Range End' and
               cur_pc_charge.range_min_op = '>' and
               vn_typical_val > cur_pc_charge.range_min_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val > cur_pc_charge.range_min_value and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>=' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val >= cur_pc_charge.range_min_value and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val > cur_pc_charge.range_min_value and
               vn_typical_val <= cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>=' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val >= cur_pc_charge.range_min_value and
               vn_typical_val <= cur_pc_charge.range_max_value) then
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
              
                if vn_typical_val > 0 then
                  if cur_range.min_range <= vn_typical_val and
                     cur_range.max_range <= vn_typical_val then
                    -- for full range
                    vn_penalty_charge := cur_range.penalty_amount;
                    vn_range_gap      := cur_range.max_range -
                                         cur_range.min_range;
                  else
                    -- for half range
                    vn_penalty_charge := cur_range.penalty_amount;
                    vn_range_gap      := vn_typical_val -
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
          if vc_penalty_weight_type = 'Dry' then
            vn_converted_qty := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                     pc_qty_unit_id,
                                                                     cur_pc_charge.weight_unit_id,
                                                                     pn_dry_qty);
          else
            vn_converted_qty := pkg_general.f_get_converted_quantity(cc.underlying_product_id,
                                                                     pc_qty_unit_id,
                                                                     cur_pc_charge.weight_unit_id,
                                                                     pn_wet_qty);
          
          end if;
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
  procedure sp_get_gmr_refine_charge(pc_inter_gmr_ref_no varchar2,
                                     pc_inter_grd_ref_no varchar2,
                                     pc_element_id       varchar2,
                                     pc_dbd_id           varchar2,
                                     pn_rc_qty           number,
                                     pc_rc_qty_unit_id   varchar2,
                                     pn_cp_price         number,
                                     pc_cp_unit_id       varchar2,
                                     pn_total_rc_charge  out number,
                                     pc_rc_cur_id        out varchar2) is
  vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count           number := 1;
  vn_refine_charge             number;
  vc_price_unit_id             varchar2(100);
  vn_max_range                 number;
  vn_typical_val               number;
  vn_contract_price            number;
  vn_min_range                 number;
  vn_base_refine_charge        number;
  vn_range_gap                 number;
  vn_each_tier_rc_charge       number;
  vc_cur_id                    varchar2(10);
  vc_rc_weight_unit_id         varchar2(15);
  vc_include_ref_charge        char(1);
  vn_gmr_rc_charges            number := 0;
  vn_gmr_price                 number;
  vc_gmr_price_unit_id         varchar2(15);
  vc_price_unit_weight_unit_id varchar2(15);
  vc_gmr_price_unit_cur_id     varchar2(15);
  vn_commit_count              number := 0;
  vc_range_over                varchar2(1) := 'N';
  vn_weight_conv_factor        number;
  vc_add_now                   varchar2(1) := 'N'; -- Set to Y for Fixed when it falls in the slab range
  vn_total_refine_charge       number := 0;
  vc_range_type                varchar2(20);
  vn_cur_factor                number;
  vn_payable_qty               number;
  vc_payable_qty_unit_id       varchar2(50);
begin
vn_payable_qty:=pn_rc_qty;
vc_payable_qty_unit_id:=pc_rc_qty_unit_id;
  --Get the Charge Details 
  for cc in (select gmr.internal_gmr_ref_no,
                    grd.internal_grd_ref_no,
                    gmr.internal_contract_ref_no,
                    grd.internal_contract_item_ref_no,
                    pqca.typical,
                    pqca.element_id,
                    pci.pcpq_id,
                    pci.pcdi_id,
                    gmr.gmr_ref_no,
                    aml.attribute_name element_name,
                    spq.payable_qty,
                    spq.qty_unit_id payable_qty_unit_id,
                    nvl(gmr.invoice_cur_decimals, 2) pay_cur_decimals
               from process_gmr                 gmr,
                    process_grd                 grd,
                    ash_assay_header            ash,
                    asm_assay_sublot_mapping    asm,
                    pqca_pq_chemical_attributes pqca,
                    aml_attribute_master_list   aml,
                    pci_physical_contract_item  pci,
                    process_spq                 spq
              where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                and grd.internal_grd_ref_no = spq.internal_grd_ref_no
                and grd.internal_gmr_ref_no = spq.internal_gmr_ref_no
                and ash.ash_id = asm.ash_id
                and spq.element_id = aml.attribute_id
                and ash.ash_id = spq.weg_avg_pricing_assay_id
                and asm.asm_id = pqca.asm_id
                and aml.attribute_id = pqca.element_id
                and pqca.element_id = spq.element_id
                and gmr.dbd_id = pc_dbd_id
                and grd.dbd_id = pc_dbd_id
                and pci.dbd_id = pc_dbd_id
                and spq.dbd_id = pc_dbd_id
                and gmr.internal_gmr_ref_no=pc_inter_gmr_ref_no
                and grd.internal_grd_ref_no=pc_inter_grd_ref_no
                and spq.element_id=pc_element_id
                and grd.internal_contract_item_ref_no =
                    pci.internal_contract_item_ref_no                
             union
             select gmr.internal_gmr_ref_no,
                    dgrd.internal_dgrd_ref_no,
                    gmr.internal_contract_ref_no,
                    dgrd.internal_contract_item_ref_no,
                    pqca.typical,
                    pqca.element_id,
                    pci.pcpq_id,
                    pci.pcdi_id,
                    gmr.gmr_ref_no,
                    aml.attribute_name element_name,
                    spq.payable_qty,
                    spq.qty_unit_id payable_qty_unit_id,
                    nvl(gmr.invoice_cur_decimals, 2) pay_cur_decimals
               from process_gmr                 gmr,
                    dgrd_delivered_grd          dgrd,
                    ash_assay_header            ash,
                    asm_assay_sublot_mapping    asm,
                    pqca_pq_chemical_attributes pqca,
                    aml_attribute_master_list   aml,
                    pci_physical_contract_item  pci,
                    process_spq                 spq
              where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
                and ash.ash_id = asm.ash_id
                and spq.dbd_id = pc_dbd_id
                and spq.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
                and spq.internal_dgrd_ref_no = dgrd.internal_dgrd_ref_no
                and spq.element_id = aml.attribute_id
                and ash.ash_id = spq.weg_avg_pricing_assay_id
                and asm.asm_id = pqca.asm_id
                and aml.attribute_id = pqca.element_id
                and pqca.element_id = spq.element_id
                and gmr.dbd_id = pc_dbd_id
                and dgrd.dbd_id = pc_dbd_id
                and pci.dbd_id = pc_dbd_id
                and gmr.internal_gmr_ref_no=pc_inter_gmr_ref_no
                and dgrd.internal_dgrd_ref_no=pc_inter_grd_ref_no
                and spq.element_id=pc_element_id
                and dgrd.internal_contract_item_ref_no =
                    pci.internal_contract_item_ref_no)
  loop
    dbms_output.put_line(cc.internal_gmr_ref_no);
    dbms_output.put_line(cc.element_id);
    vn_total_refine_charge := 0;
    vc_range_type          := null;
    --
    -- Get the Price For the GMR
    --
     vn_refine_charge  := 0;
    vn_contract_price := pn_cp_price;
    -- for refine charge , the charge will applyed on
    -- payable qty only.So deduct the moisture and other deductable item
    -- from the item qty. 
    -- include refine charge from the contract creation.
    -- If Yes then take the conract include_ref_charge 
    -- else go for the Charge Range
    begin
      select pcepc.include_ref_charges
        into vc_include_ref_charge
        from pcpch_pc_payble_content_header pcpch,
             pcepc_pc_elem_payable_content  pcepc,
             pqd_payable_quality_details    pqd,
             dipch_di_payablecontent_header dipch
       where pcpch.pcpch_id = pcepc.pcpch_id
         and pcpch.dbd_id = pc_dbd_id
         and pcepc.dbd_id = pc_dbd_id
         and pcpch.element_id = cc.element_id
         and pcpch.internal_contract_ref_no = cc.internal_contract_ref_no
         and (pcepc.range_min_value <= cc.typical or
             pcepc.position = 'Range Begining')
         and (pcepc.range_max_value > cc.typical or
             pcepc.position = 'Range End')
         and pcpch.is_active = 'Y'
         and pcepc.is_active = 'Y'
         and pqd.pcpch_id = pcpch.pcpch_id
         and pqd.pcpq_id = cc.pcpq_id
         and pqd.is_active = 'Y'
         and pqd.dbd_id = pc_dbd_id
         and dipch.dbd_id = pc_dbd_id
         and dipch.pcpch_id = pcpch.pcpch_id
         and dipch.pcdi_id = cc.pcdi_id
         and dipch.is_active = 'Y'
         and rownum < 2; -- I never want 2 record from this;
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
                                 from pcdi_pc_delivery_item          pcdi,
                                      pci_physical_contract_item     pci,
                                      pcpch_pc_payble_content_header pcpch,
                                      pcepc_pc_elem_payable_content  pcepc,
                                      ppu_product_price_units        ppu,
                                      pum_price_unit_master          pum,
                                      process_gmr                    gmr,
                                      grh_gmr_refining_header        grh
                                where pcpch.internal_contract_ref_no =
                                      pcdi.internal_contract_ref_no
                                  and pcdi.pcdi_id = pci.pcdi_id
                                  and pcpch.element_id = cc.element_id
                                  and pcpch.pcpch_id = pcepc.pcpch_id
                                  and pcepc.include_ref_charges = 'Y'
                                  and ppu.internal_price_unit_id =
                                      pcepc.refining_charge_unit_id
                                  and ppu.price_unit_id = pum.price_unit_id
                                  and pci.internal_contract_item_ref_no =
                                      cc.internal_contract_item_ref_no
                                  and gmr.internal_contract_ref_no =
                                      cc.internal_contract_ref_no
                                  and gmr.internal_gmr_ref_no =
                                      grh.internal_gmr_ref_no
                                  and pci.dbd_id = pc_dbd_id
                                  and pcdi.dbd_id = pc_dbd_id
                                  and pcpch.dbd_id = pc_dbd_id
                                  and pcepc.dbd_id = pc_dbd_id
                                  and grh.dbd_id = pc_dbd_id
                                  and pci.is_active = 'Y'
                                  and pcdi.is_active = 'Y'
                                  and pcpch.is_active = 'Y'
                                  and pcepc.is_active = 'Y')
        loop
          vc_rc_weight_unit_id := cur_ref_charge.weight_unit_id;
          vc_cur_id            := cur_ref_charge.cur_id;
          vc_price_unit_id     := cur_ref_charge.price_unit_id;
          if (cur_ref_charge.position = 'Range Begining' and
             cur_ref_charge.range_max_op = '<=' and
             cc.typical <= cur_ref_charge.range_max_value) or
             (cur_ref_charge.position = 'Range Begining' and
             cur_ref_charge.range_max_op = '<' and
             cc.typical <= cur_ref_charge.range_max_value) or
             (cur_ref_charge.position = 'Range End' and
             cur_ref_charge.range_min_op = '>=' and
             cc.typical >= cur_ref_charge.range_min_value) or
             (cur_ref_charge.position = 'Range End' and
             cur_ref_charge.range_min_op = '>' and
             cc.typical > cur_ref_charge.range_min_value) or
             (cur_ref_charge.position is null and
             cur_ref_charge.range_min_op = '>' and
             cur_ref_charge.range_max_op = '<' and
             cc.typical > cur_ref_charge.range_min_value and
             cc.typical < cur_ref_charge.range_max_value) or
             (cur_ref_charge.position is null and
             cur_ref_charge.range_min_op = '>=' and
             cur_ref_charge.range_max_op = '<' and
             cc.typical >= cur_ref_charge.range_min_value and
             cc.typical < cur_ref_charge.range_max_value) or
             (cur_ref_charge.position is null and
             cur_ref_charge.range_min_op = '>' and
             cur_ref_charge.range_max_op = '<=' and
             cc.typical > cur_ref_charge.range_min_value and
             cc.typical <= cur_ref_charge.range_max_value) or
             (cur_ref_charge.position is null and
             cur_ref_charge.range_min_op = '>=' and
             cur_ref_charge.range_max_op = '<=' and
             cc.typical >= cur_ref_charge.range_min_value and
             cc.typical <= cur_ref_charge.range_max_value) then
            vn_total_refine_charge := cur_ref_charge.refining_charge_value;
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
                                      nvl(pcerc.esc_desc_unit_id, pum.cur_id) cur_id,
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
                                      cc.internal_gmr_ref_no
                                  and grh.pcrh_id = pcrh.pcrh_id
                                  and rqd.pcpq_id = cc.pcpq_id
                                  and pcrh.dbd_id = pc_dbd_id
                                  and red.dbd_id = pc_dbd_id
                                  and pcerc.dbd_id = pc_dbd_id
                                  and rqd.dbd_id = pc_dbd_id
                                  and grh.dbd_id = pc_dbd_id
                                  and red.element_id = cc.element_id
                                  and ppu.internal_price_unit_id =
                                      pcerc.refining_charge_unit_id
                                  and ppu.price_unit_id = pum.price_unit_id
                                  and pcerc.is_active = 'Y'
                                  and pcrh.is_active = 'Y'
                                  and red.is_active = 'Y'
                                  and rqd.is_active = 'Y'
                                  and grh.is_active = 'Y'
                                order by pcrh.range_type,
                                         pcerc.position)
        loop
          --
          -- RC Charge Price Unit should be taken from Range Type = Base or Range Type = Null(Assay Range)
          -- App is storing Price Unit of Price and Not Price Unit of RC Charge
          -- Where is the correct data present?
          -- 1)When Assay Range Use it
          -- 2) Price Range Range, use from Base
          -- 3) When Assay and Price Range use from Assay Range
          -- Data sorted to mee this condition already
          --
          if vc_rc_weight_unit_id is null then
            vc_rc_weight_unit_id := cur_ref_charge.weight_unit_id;
          end if;
          vc_cur_id        := cur_ref_charge.cur_id;
          vc_price_unit_id := cur_ref_charge.price_unit_id;
          if vc_range_type is null or
             vc_range_type = cur_ref_charge.range_type then
            vc_range_type := cur_ref_charge.range_type;
          else
            vc_range_type := 'Multiple';
          end if;
          vc_add_now := 'N';
          if cur_ref_charge.range_type = 'Price Range' then
            vn_gmr_rc_charges := 0;
            -- If the CHARGE_TYPE is fixed then it will
            -- behave as the slab as same as the assay range
            -- No base concept is here
            if cur_ref_charge.charge_type = 'Fixed' then
              if (cur_ref_charge.position = 'Range Begining' and
                 cur_ref_charge.range_max_op = '<=' and
                 vn_contract_price <= cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position = 'Range Begining' and
                 cur_ref_charge.range_max_op = '<' and
                 vn_contract_price < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position = 'Range End' and
                 cur_ref_charge.range_min_op = '>=' and
                 vn_contract_price >= cur_ref_charge.range_min_value) or
                 (cur_ref_charge.position = 'Range End' and
                 cur_ref_charge.range_min_op = '>' and
                 vn_contract_price > cur_ref_charge.range_min_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>' and
                 cur_ref_charge.range_max_op = '<' and
                 vn_contract_price > cur_ref_charge.range_min_value and
                 vn_contract_price < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>=' and
                 cur_ref_charge.range_max_op = '<' and
                 vn_contract_price >= cur_ref_charge.range_min_value and
                 vn_contract_price < cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>' and
                 cur_ref_charge.range_max_op = '<=' and
                 vn_contract_price > cur_ref_charge.range_min_value and
                 vn_contract_price <= cur_ref_charge.range_max_value) or
                 (cur_ref_charge.position is null and
                 cur_ref_charge.range_min_op = '>=' and
                 cur_ref_charge.range_max_op = '<=' and
                 vn_contract_price >= cur_ref_charge.range_min_value and
                 vn_contract_price <= cur_ref_charge.range_max_value) then
                vn_refine_charge := cur_ref_charge.refining_charge;
                vc_add_now       := 'Y';
              end if;
            elsif cur_ref_charge.charge_type = 'Variable' then
              vc_range_over := 'N';
              -- Take the base price and its min and max range
              begin
                select pcerc.range_min_value,
                       pcerc.range_max_value,
                       pcerc.refining_charge
                  into vn_min_range,
                       vn_max_range,
                       vn_base_refine_charge
                  from pcerc_pc_elem_refining_charge pcerc
                 where pcerc.pcrh_id = cur_ref_charge.pcrh_id
                   and pcerc.is_active = 'Y'
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
                                                 nvl(pcerc.range_max_value,
                                                     vn_contract_price) range_max_value,
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
                                                     0) >= vn_max_range
                                                -- Because There is a defintely range for escalator saying > Base 
                                                -- If base is 6000, the escalator entry must say first entry as > 6000 and <=7000, > 7000 to 8000 or 
                                                -- If we do not put >= price one entry will be missed
                                             and nvl(pcerc.position, 'a') <>
                                                 'Base'
                                             and pcerc.is_active = 'Y'
                                             and pcerc.dbd_id = pc_dbd_id
                                           order by pcerc.range_max_value asc nulls last)
                loop
                  -- if price is in the range take diff of price and max range
                  if vn_contract_price >= cur_forward_price.range_min_value and
                     vn_contract_price <= cur_forward_price.range_max_value then
                    vn_range_gap  := abs(vn_contract_price -
                                         cur_forward_price.range_min_value);
                    vc_range_over := 'Y';
                  else
                    -- else diff range               
                    vn_range_gap := cur_forward_price.range_max_value -
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
                  if vc_range_over = 'Y' then
                    exit;
                  end if;
                
                end loop;
              elsif vn_contract_price < vn_min_range then
                --go back ward for the price range
                vn_refine_charge := vn_base_refine_charge;
                for cur_backward_price in (select nvl(pcerc.range_min_value,
                                                      vn_contract_price) range_min_value,
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
                                                      0) < vn_min_range
                                                 -- Because Deescalator has range saying < Base 
                                                 -- If base is 6000, Deescalator entry has to < 6000
                                              and nvl(pcerc.position, 'a') <>
                                                  'Base'
                                              and pcerc.is_active = 'Y'
                                              and pcerc.dbd_id = pc_dbd_id
                                            order by pcerc.range_min_value desc nulls last)
                loop
                  -- if price is in the range take diff of price and max range 
                  if vn_contract_price >=
                     cur_backward_price.range_min_value and
                     vn_contract_price <=
                     cur_backward_price.range_max_value then
                    vn_range_gap := abs(vn_contract_price -
                                        cur_backward_price.range_max_value);
                  
                    vc_range_over := 'Y';
                  else
                    -- else diff range               
                    vn_range_gap := cur_backward_price.range_max_value -
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
                  vn_refine_charge := vn_refine_charge -
                                      vn_each_tier_rc_charge;
                  if vc_range_over = 'Y' then
                    exit;
                  end if;
                end loop;
              elsif vn_contract_price = vn_min_range and
                    vn_contract_price = vn_max_range then
                vn_refine_charge := vn_base_refine_charge;
                --take the base price only
              end if;
            end if;
          elsif cur_ref_charge.range_type = 'Assay Range' then
            --Make sure the range for the element is mentation properly.
            if (cur_ref_charge.position = 'Range Begining' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical <= cur_ref_charge.range_max_value) or
               (cur_ref_charge.position = 'Range Begining' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical < cur_ref_charge.range_max_value) or
               (cur_ref_charge.position = 'Range End' and
               cur_ref_charge.range_min_op = '>=' and
               cc.typical >= cur_ref_charge.range_min_value) or
               (cur_ref_charge.position = 'Range End' and
               cur_ref_charge.range_min_op = '>' and
               cc.typical > cur_ref_charge.range_min_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical > cur_ref_charge.range_min_value and
               cc.typical < cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>=' and
               cur_ref_charge.range_max_op = '<' and
               cc.typical >= cur_ref_charge.range_min_value and
               cc.typical < cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical > cur_ref_charge.range_min_value and
               cc.typical <= cur_ref_charge.range_max_value) or
               (cur_ref_charge.position is null and
               cur_ref_charge.range_min_op = '>=' and
               cur_ref_charge.range_max_op = '<=' and
               cc.typical >= cur_ref_charge.range_min_value and
               cc.typical <= cur_ref_charge.range_max_value) then
              vn_refine_charge := cur_ref_charge.refining_charge;
              vn_max_range     := cur_ref_charge.range_max_value;
              vn_min_range     := cur_ref_charge.range_min_value;
              vn_typical_val   := cc.typical;
              vc_add_now       := 'Y';
            end if;
          end if;
          --I will exit from the loop when it is tier base ,
          --as the inner loop is done the calculation.
          if cur_ref_charge.range_type = 'Price Range' and
             cur_ref_charge.charge_type = 'Variable' then
            vn_total_refine_charge := vn_total_refine_charge +
                                      vn_refine_charge;
            exit;
          end if;
        
          --
          -- Get the total only when it was in the range, skip otherwise
          -- If it is Price range variable it adds above exits the loop
          --
          if (cur_ref_charge.range_type = 'Price Range' and
             cur_ref_charge.charge_type = 'Fixed' and vc_add_now = 'Y') or
             cur_ref_charge.range_type = 'Assay Range' and vc_add_now = 'Y' then
            vn_total_refine_charge := vn_total_refine_charge +
                                      vn_refine_charge;
            vc_add_now             := 'N';
          end if;
        end loop;
      exception
        when others then
          vn_refine_charge := 0;
          vc_price_unit_id := null;
      end;
    end if; 
    
     begin
    select scd.factor
      into vn_cur_factor
      from scd_sub_currency_detail scd
     where scd.is_deleted = 'N'
       and scd.sub_cur_id = vc_cur_id;
  exception
    when others then
      vn_cur_factor := 1;
  end;
  begin
      select ucm.multiplication_factor
        into vn_weight_conv_factor
        from ucm_unit_conversion_master ucm
       where ucm.from_qty_unit_id = vc_payable_qty_unit_id
         and ucm.to_qty_unit_id = vc_rc_weight_unit_id;
    exception
      when others then
        vn_weight_conv_factor := -1;
    end;  
    
   vn_total_refine_charge:= vn_total_refine_charge *
                             vn_weight_conv_factor *
                             vn_payable_qty * vn_cur_factor;
  end loop;
pn_total_rc_charge:=vn_total_refine_charge;
pc_rc_cur_id:=vc_cur_id;    
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
                      grd.current_qty,
                      grd.qty * asm.dry_wet_qty_ratio / 100 dry_weight,
                      grd.qty_unit_id net_weight_unit,
                      pci.pcpq_id
                 from gmr_goods_movement_record   gmr,
                      grd_goods_record_detail     grd,
                      ash_assay_header            ash,
                      asm_assay_sublot_mapping    asm,
                      pqca_pq_chemical_attributes pqca,
                      rm_ratio_master             rm,
                      aml_attribute_master_list   aml,
                      pci_physical_contract_item  pci
                where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                  and ash.ash_id = asm.ash_id
                  and asm.asm_id = pqca.asm_id
                  and rm.ratio_id = pqca.unit_of_measure
                  and aml.attribute_id = pqca.element_id
                  and nvl(pqca.is_elem_for_pricing, 'N') = 'N'
                  and pqca.element_id = pc_element_id
                  and gmr.dbd_id = pc_dbd_id
                  and grd.dbd_id = pc_dbd_id
                  and pci.dbd_id = pc_dbd_id
                  and grd.internal_contract_item_ref_no =
                      pci.internal_contract_item_ref_no
                  and gmr.internal_gmr_ref_no = pc_inter_gmr_ref_no
                  and grd.internal_grd_ref_no = pc_inter_grd_ref_no
                  and grd.weg_avg_pricing_assay_id = ash.ash_id)
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
                               and gph.dbd_id = pc_dbd_id
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
          if (cur_pc_charge.position = 'Range Begining' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical <= cur_pc_charge.range_max_value) or
             (cur_pc_charge.position = 'Range Begining' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position = 'Range End' and
             cur_pc_charge.range_min_op = '>=' and
             cc.typical >= cur_pc_charge.range_min_value) or
             (cur_pc_charge.position = 'Range End' and
             cur_pc_charge.range_min_op = '>' and
             cc.typical > cur_pc_charge.range_min_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical > cur_pc_charge.range_min_value and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>=' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical >= cur_pc_charge.range_min_value and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical > cur_pc_charge.range_min_value and
             cc.typical <= cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>=' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical >= cur_pc_charge.range_min_value and
             cc.typical <= cur_pc_charge.range_max_value) then
          
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
            if (cur_pc_charge.position = 'Range Begining' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val <= cur_pc_charge.range_max_value) or
               (cur_pc_charge.position = 'Range Begining' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position = 'Range End' and
               cur_pc_charge.range_min_op = '>=' and
               vn_typical_val >= cur_pc_charge.range_min_value) or
               (cur_pc_charge.position = 'Range End' and
               cur_pc_charge.range_min_op = '>' and
               vn_typical_val > cur_pc_charge.range_min_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val > cur_pc_charge.range_min_value and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>=' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val >= cur_pc_charge.range_min_value and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val > cur_pc_charge.range_min_value and
               vn_typical_val <= cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>=' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val >= cur_pc_charge.range_min_value and
               vn_typical_val <= cur_pc_charge.range_max_value) then
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
  procedure sp_get_gmr_penalty_charge_new(pc_inter_gmr_ref_no varchar2,
                                          pc_inter_grd_ref_no varchar2,
                                          pc_dbd_id           varchar2,
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
                      grd.qty net_weight,
                      grd.qty * asm.dry_wet_qty_ratio / 100 dry_weight,
                      grd.qty_unit_id net_weight_unit,
                      pci.pcpq_id
                 from gmr_goods_movement_record   gmr,
                      grd_goods_record_detail     grd,
                     -- sam_stock_assay_mapping     sam,
                      ash_assay_header            ash,
                      asm_assay_sublot_mapping    asm,
                      pqca_pq_chemical_attributes pqca,
                      rm_ratio_master             rm,
                      aml_attribute_master_list   aml,
                      pci_physical_contract_item  pci
                where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                  and grd.weg_avg_pricing_assay_id = ash.ash_id
                  and ash.ash_id = asm.ash_id
                  and asm.asm_id = pqca.asm_id
                  and rm.ratio_id = pqca.unit_of_measure
                  and aml.attribute_id = pqca.element_id
                  and nvl(pqca.is_elem_for_pricing, 'N') = 'N'
                  and gmr.dbd_id = pc_dbd_id
                  and grd.dbd_id = pc_dbd_id
                  and pci.dbd_id = pc_dbd_id
                  and grd.internal_contract_item_ref_no =
                      pci.internal_contract_item_ref_no
                  and gmr.internal_gmr_ref_no = pc_inter_gmr_ref_no
                  and grd.internal_grd_ref_no = pc_inter_grd_ref_no
               union
               select gmr.internal_gmr_ref_no,
                      dgrd.internal_grd_ref_no,
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
                      dgrd.net_weight,
                      asm.net_weight_unit,
                      pci.pcpq_id
                 from gmr_goods_movement_record   gmr,
                      dgrd_delivered_grd          dgrd,
                      ash_assay_header            ash,
                      asm_assay_sublot_mapping    asm,
                      pqca_pq_chemical_attributes pqca,
                      rm_ratio_master             rm,
                      aml_attribute_master_list   aml,
                      pci_physical_contract_item  pci
                where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no              
                  and dgrd.weg_avg_pricing_assay_id = ash.ash_id
                  and ash.ash_id = asm.ash_id
                  and asm.asm_id = pqca.asm_id
                  and rm.ratio_id = pqca.unit_of_measure
                  and aml.attribute_id = pqca.element_id
                  and nvl(pqca.is_elem_for_pricing, 'N') = 'N'
                  and gmr.dbd_id = pc_dbd_id
                  and dgrd.dbd_id = pc_dbd_id
                  and pci.dbd_id = pc_dbd_id
                  and dgrd.internal_contract_item_ref_no =
                      pci.internal_contract_item_ref_no
                  and gmr.internal_gmr_ref_no = pc_inter_gmr_ref_no
                  and dgrd.internal_dgrd_ref_no = pc_inter_grd_ref_no)
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
                               and gph.dbd_id = pc_dbd_id
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
                               and ppu.price_unit_id = pum.price_unit_id)
      loop
        vc_price_unit_id     := cur_pc_charge.price_unit_id;
        vc_cur_id            := cur_pc_charge.cur_id;
        vn_element_pc_charge := 0;
        --check the penalty charge type
        if cur_pc_charge.penalty_charge_type = 'Fixed' then
          vc_penalty_weight_type := cur_pc_charge.penalty_weight_type;
          --Find the PC charge which will fall in the appropriate range.
          --as according to the typical value   
          if (cur_pc_charge.position = 'Range Begining' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical <= cur_pc_charge.range_max_value) or
             (cur_pc_charge.position = 'Range Begining' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position = 'Range End' and
             cur_pc_charge.range_min_op = '>=' and
             cc.typical >= cur_pc_charge.range_min_value) or
             (cur_pc_charge.position = 'Range End' and
             cur_pc_charge.range_min_op = '>' and
             cc.typical > cur_pc_charge.range_min_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical > cur_pc_charge.range_min_value and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>=' and
             cur_pc_charge.range_max_op = '<' and
             cc.typical >= cur_pc_charge.range_min_value and
             cc.typical < cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical > cur_pc_charge.range_min_value and
             cc.typical <= cur_pc_charge.range_max_value) or
             (cur_pc_charge.position is null and
             cur_pc_charge.range_min_op = '>=' and
             cur_pc_charge.range_max_op = '<=' and
             cc.typical >= cur_pc_charge.range_min_value and
             cc.typical <= cur_pc_charge.range_max_value) then
          
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
            if (cur_pc_charge.position = 'Range Begining' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val <= cur_pc_charge.range_max_value) or
               (cur_pc_charge.position = 'Range Begining' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position = 'Range End' and
               cur_pc_charge.range_min_op = '>=' and
               vn_typical_val >= cur_pc_charge.range_min_value) or
               (cur_pc_charge.position = 'Range End' and
               cur_pc_charge.range_min_op = '>' and
               vn_typical_val > cur_pc_charge.range_min_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val > cur_pc_charge.range_min_value and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>=' and
               cur_pc_charge.range_max_op = '<' and
               vn_typical_val >= cur_pc_charge.range_min_value and
               vn_typical_val < cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val > cur_pc_charge.range_min_value and
               vn_typical_val <= cur_pc_charge.range_max_value) or
               (cur_pc_charge.position is null and
               cur_pc_charge.range_min_op = '>=' and
               cur_pc_charge.range_max_op = '<=' and
               vn_typical_val >= cur_pc_charge.range_min_value and
               vn_typical_val <= cur_pc_charge.range_max_value) then
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
              
                if vn_typical_val > 0 then
                  if
                  --for full range      
                   cur_range.min_range <= vn_typical_val and
                   cur_range.max_range <= vn_typical_val then
                    vn_penalty_charge := cur_range.penalty_amount;
                    vn_range_gap      := cur_range.max_range -
                                         cur_range.min_range;
                  else
                    --for half range
                    vn_penalty_charge := cur_range.penalty_amount;
                    vn_range_gap      := vn_typical_val -
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

  function f_get_next_day(p_date     in date,
                          p_day      in varchar2,
                          p_position in number) return date is
  
    v_position_date      date;
    v_next_position      number;
    v_start_day          varchar2(10);
    v_first_day_position date;
  
  begin
  
    begin
      v_next_position := (p_position - 1) * 7;
      v_start_day     := to_char(to_date('01-' ||
                                         to_char(trunc(p_date), 'mon-yyyy'),
                                         'dd-mon-yyyy'),
                                 'dy');
      if upper(trim(v_start_day)) = upper(trim(p_day)) then
        v_first_day_position := to_date('01-' ||
                                        to_char(trunc(p_date), 'mon-yyyy'),
                                        'dd-mon-yyyy');
      else
        v_first_day_position := next_day(to_date('01-' ||
                                                 to_char(p_date, 'mon-yyyy'),
                                                 'dd-mon-yyyy'),
                                         trim(p_day));
      end if;
    
      if v_next_position <= 1 then
        v_position_date := trunc(v_first_day_position);
      else
        v_position_date := trunc(v_first_day_position) + v_next_position;
      end if;
    exception
      when no_data_found then
        return null;
      when others then
        return null;
    end;
    return v_position_date;
  end f_get_next_day;
  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean is
    pc_counter number(1);
    result_val boolean;
  begin
    --Checking the Week End Holiday List
    begin
      select count(*)
        into pc_counter
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
      if (pc_counter = 1) then
        result_val := true;
      else
        result_val := false;
      end if;
      if (result_val = false) then
        --Checking Other Holiday List
        select count(*)
          into pc_counter
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
        if (pc_counter = 1) then
          result_val := true;
        else
          result_val := false;
        end if;
      end if;
    end;
    return result_val;
  end f_is_day_holiday;
  procedure sp_quality_premium_fw_rate(pc_int_contract_item_ref_no in varchar2,
                                       pc_corporate_id             in varchar2,
                                       pc_process                  in varchar2,
                                       pd_trade_date               in date,
                                       pc_price_unit_id            in varchar2,
                                       pc_base_cur_id              in varchar2,
                                       pc_product_id               in varchar2,
                                       pc_base_qty_unit_id         in varchar2,
                                       pc_process_id               in varchar2,
                                       pc_price_basis              in varchar2,
                                       pd_valuation_fx_date        date,
                                       pd_qp_fx_date               date,
                                       pn_premium                  out number,
                                       pc_exch_rate_string         out varchar2) is
  
    cursor cur_preimium is
      select pcqpd.premium_disc_value,
             pcqpd.premium_disc_unit_id
        from pci_physical_contract_item     pci,
             pcpq_pc_product_quality        pcpq,
             pcpdqd_pd_quality_details      pcpdqd,
             pcqpd_pc_qual_premium_discount pcqpd
       where pci.pcpq_id = pcpq.pcpq_id
         and pcpq.pcpq_id = pcpdqd.pcpq_id
         and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
         and pci.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and pcqpd.process_id = pc_process_id
         and pcpdqd.process_id = pc_process_id
         and pci.internal_contract_item_ref_no =
             pc_int_contract_item_ref_no;
    vn_premium                 number;
    vn_total_premium           number := 0;
    vc_premium_cur_id          varchar2(15);
    vc_premium_main_cur_id     varchar2(15);
    vc_premium_main_cur_code   varchar2(15);
    vn_premium_cur_main_factor number;
    vc_premium_weight_unit_id  varchar2(15);
    vn_premium_weight          number;
    vn_premium_to_base_fw_rate number;
    vn_forward_points          number;
    vc_base_cur_code           varchar2(15);
    vobj_error_log             tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count         number := 1;
    vn_forward_exch_rate       number;
  begin
    select cm.cur_code
      into vc_base_cur_code
      from cm_currency_master cm
     where cm.cur_id = pc_base_cur_id;
    for cur_preimium_rows in cur_preimium
    loop
      if cur_preimium_rows.premium_disc_unit_id = pc_price_unit_id then
        vn_premium := cur_preimium_rows.premium_disc_value;
      else
        --
        -- Get the Currency, Weight Unit and Weight Unit of Premium Price Unit
        --
        select ppu.cur_id,
               ppu.weight_unit_id,
               nvl(ppu.weight, 1)
          into vc_premium_cur_id,
               vc_premium_weight_unit_id,
               vn_premium_weight
          from v_ppu_pum ppu
         where ppu.product_price_unit_id =
               cur_preimium_rows.premium_disc_unit_id;
      
        --
        -- Get the Main Currency of the Premium Price Unit
        --
        pkg_general.sp_get_base_cur_detail(vc_premium_cur_id,
                                           vc_premium_main_cur_id,
                                           vc_premium_main_cur_code,
                                           vn_premium_cur_main_factor);
        --
        -- Exchange Rate from Premium to Base Currency
        --       
      
        if pc_price_basis = 'Fixed' then
          if pd_valuation_fx_date = pd_trade_date then
          
            pkg_general.sp_bank_fx_rate_spot(pc_corporate_id,
                                             pd_trade_date,
                                             vc_premium_main_cur_id,
                                             pc_base_cur_id,
                                             'sp_quality_premin_fw_rate Premium to Base Spot ',
                                             pc_process,
                                             vn_premium_to_base_fw_rate);
          else
            pkg_general.sp_bank_fx_rate_spot_fw_points(pc_corporate_id,
                                                       pd_trade_date,
                                                       pd_valuation_fx_date,
                                                       vc_premium_main_cur_id,
                                                       pc_base_cur_id,
                                                       'sp_quality_premin_fw_rate Premium To Base Spot + FW Points',
                                                       pc_process,
                                                       vn_premium_to_base_fw_rate,
                                                       vn_forward_exch_rate);
          end if;
        
        else
          if pd_qp_fx_date = pd_trade_date then
            dbms_output.put_line('Variable type and val = eod date');
            pkg_general.sp_bank_fx_rate_spot(pc_corporate_id,
                                             pd_trade_date,
                                             vc_premium_main_cur_id,
                                             pc_base_cur_id,
                                             'sp_quality_premin_fw_rate Premium To Base Spot ',
                                             pc_process,
                                             vn_premium_to_base_fw_rate);
          else
            pkg_general.sp_bank_fx_rate_spot_fw_points(pc_corporate_id,
                                                       pd_trade_date,
                                                       pd_qp_fx_date,
                                                       vc_premium_main_cur_id,
                                                       pc_base_cur_id,
                                                       'sp_quality_premin_fw_rate Premium To Base Spot + FW Points',
                                                       pc_process,
                                                       vn_premium_to_base_fw_rate,
                                                       vn_forward_exch_rate);
          end if;
        end if;
        if vc_premium_main_cur_code <> vc_base_cur_code then
          if pc_exch_rate_string is null then
            pc_exch_rate_string := '1 ' || vc_premium_main_cur_code || '=' ||
                                   vn_premium_to_base_fw_rate || ' ' ||
                                   vc_base_cur_code;
          else
            pc_exch_rate_string := pc_exch_rate_string || ',' || '1 ' ||
                                   vc_premium_main_cur_code || '=' ||
                                   vn_premium_to_base_fw_rate || ' ' ||
                                   vc_base_cur_code;
          end if;
        end if;
        vn_premium := (cur_preimium_rows.premium_disc_value /
                      vn_premium_cur_main_factor) *
                      vn_premium_to_base_fw_rate *
                      pkg_general.f_get_converted_quantity(pc_product_id,
                                                           vc_premium_weight_unit_id,
                                                           pc_base_qty_unit_id,
                                                           1);
      end if;
      vn_total_premium := vn_total_premium + vn_premium;
    end loop;
    pn_premium := vn_total_premium;
  end;
end;
/
