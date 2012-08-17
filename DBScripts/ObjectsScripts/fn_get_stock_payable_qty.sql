create or replace function fn_get_stock_payable_qty(pc_grd_id      varchar2,
                                                    pn_grd_qty     number,
                                                    pc_qty_unit_id varchar2,
                                                    pc_asm_id      varchar2,
                                                    pc_pqca_id     varchar2)
  return number is
  vn_payablepercentage number(25, 10);

begin
  select (case
            when ash.assay_type = 'Output Assay' then
             (case
            when rm.ratio_name = '%' then
             (pqca.typical / 100)
            else
             pqca.typical *
             pkg_general.f_get_converted_quantity(aml.underlying_product_id,
                                                  pc_qty_unit_id,
                                                  rm.qty_unit_id_denominator,
                                                  1)
          end) when ash.assay_type <> 'Output Assay' then(case
           when rm.ratio_name = '%' then
            (pqcapd.payable_percentage / 100)
           else
            pqcapd.payable_percentage *
            pkg_general.f_get_converted_quantity(aml.underlying_product_id,
                                                 pc_qty_unit_id,
                                                 rm.qty_unit_id_denominator,
                                                 1)
         end) end) payable_percentage
    into vn_payablepercentage
    from asm_assay_sublot_mapping       asm,
         pqca_pq_chemical_attributes    pqca,
         pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
         grd_goods_record_detail        grd,
         ppm_product_properties_mapping ppm,
         aml_attribute_master_list      aml,
         rm_ratio_master                rm,
         ash_assay_header               ash
   where pqca.asm_id = asm.asm_id
     and ppm.attribute_id = aml.attribute_id
     and aml.attribute_id = pqca.element_id
     and pqca.unit_of_measure = rm.ratio_id
     and ppm.is_active = 'Y'
     and ppm.is_deleted = 'N'
     and asm.ash_id = ash.ash_id
     and ppm.product_id = grd.product_id
     and pqcapd.pqca_id(+) = pqca.pqca_id
     and nvl(pqca.is_elem_for_pricing, 'N') = 'Y'
     and pqca.pqca_id = pc_pqca_id
     and grd.internal_grd_ref_no = pc_grd_id
     and asm.asm_id = pc_asm_id;
  return pn_grd_qty * vn_payablepercentage;
end fn_get_stock_payable_qty;
/
