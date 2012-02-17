CREATE OR REPLACE VIEW  V_BI_PHYSICAL_CALL_OFF_DUE AS
select t.corporate_id,
       t.product_id,
       t.product_name,
       t.qty,
       t.qty_unit_id base_qty_unit_id,
       t.qty_unit base_qty_unit,
       t.contract_ref_no || '(' || delivery_item_no || ')' delivery_item_ref_no,
       t.pcdi_id,
       t.qty_declaration_date due_date
  from (select pcdi.pcdi_id,
               pcm.corporate_id,
               pcpd.product_id,
               pcm.contract_ref_no,
               pcdi.delivery_item_no,
               pdm.product_desc product_name,
               pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                    diqs.item_qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    nvl(diqs.total_qty, 0) -
                                                    nvl(diqs.called_off_qty,
                                                        0)) qty,
               pdm.base_quantity_unit qty_unit_id,
               qum.qty_unit,
               pcm.issue_date,
               pcdi.payment_due_date,
               pcdi.qp_declaration_date,
               pcdi.qty_declaration_date,
               pcdi.quality_declaration_date,
               pcdi.inco_location_declaration_date
          from pcdi_pc_delivery_item         pcdi,
               pcm_physical_contract_main    pcm,
               pcpd_pc_product_definition    pcpd,
               pdm_productmaster             pdm,
               qum_quantity_unit_master      qum,
               diqs_delivery_item_qty_status diqs
         where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.product_id = pdm.product_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           and pcpd.input_output = 'Input'
           and pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and pcm.is_active = 'Y'
           and pcpd.is_active = 'Y'
           and diqs.is_active = 'Y'
           and qum.is_active = 'Y'
           and pcdi.is_phy_optionality_present = 'Y'
           and nvl(diqs.total_qty, 0) - nvl(diqs.called_off_qty, 0) > 0) t
