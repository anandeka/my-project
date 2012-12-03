CREATE OR REPLACE VIEW V_BI_DASH_PHY_PFC as 
select t.corporate_id,
       t.contract_ref_no,
       t.del_item_ref_no,
       t.product_id,
       t.product,
       t.qty_to_be_priced,
       t.uom,
       t.price_description,
       t.qp_start_date
  from (select pcm.corporate_id,
               pcm.contract_ref_no,
               pcm.contract_ref_no || '-' || pcdi.delivery_item_no del_item_ref_no,
               pcpd.product_id,
               pdm.product_desc product,
               sum(pofh.qty_to_be_fixed) qty_to_be_priced,
               qum.qty_unit uom,
               pcbph.price_description,
               pofh.qp_start_date
          from pofh_price_opt_fixation_header pofh,
               pocd_price_option_calloff_dtls pocd,
               poch_price_opt_call_off_header poch,
               pcdi_pc_delivery_item          pcdi,
               pcm_physical_contract_main     pcm,
               pcpd_pc_product_definition     pcpd,
               pdm_productmaster              pdm,
               qum_quantity_unit_master       qum,
               pcbph_pc_base_price_header     pcbph
         where pofh.pocd_id = pocd.pocd_id
           and pocd.poch_id = poch.poch_id
           and poch.pcdi_id = pcdi.pcdi_id
           and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.input_output = 'Input'
           and pcpd.product_id = pdm.product_id
           and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
           and pcm.internal_contract_ref_no = pcbph.internal_contract_ref_no
           and pcm.contract_type = 'BASEMETAL'
           and pcm.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and pofh.is_active = 'Y'
           and pcpd.is_active = 'Y'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and pcbph.is_active = 'Y'
         group by pcm.corporate_id,
                  pcm.contract_ref_no,
                  pcdi.delivery_item_no,
                  pcpd.product_id,
                  pdm.product_desc,
                  qum.qty_unit,
                  pcbph.price_description,
                  pofh.qp_start_date
        union all
        select pcm.corporate_id,
               pcm.contract_ref_no,
               pcm.contract_ref_no || '-' || pcdi.delivery_item_no del_item_ref_no,
               pdm_ele.product_id,
               pdm.product_desc product,
               sum(pofh.qty_to_be_fixed) qty_to_be_priced,
               qum.qty_unit uom,
               pcbph.price_description,
               pofh.qp_start_date
        
          from pofh_price_opt_fixation_header pofh,
               pocd_price_option_calloff_dtls pocd,
               poch_price_opt_call_off_header poch,
               aml_attribute_master_list      aml,
               pdm_productmaster              pdm_ele,
               pdm_productmaster              pdm,
               pcdi_pc_delivery_item          pcdi,
               pcm_physical_contract_main     pcm,
               qum_quantity_unit_master       qum,
               pcbph_pc_base_price_header     pcbph,
               pcbpd_pc_base_price_detail     pcbpd
        
         where pofh.pocd_id = pocd.pocd_id
           and pocd.poch_id = poch.poch_id
           and poch.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm_ele.product_id
           and pdm_ele.product_id = pdm.product_id
           and poch.pcdi_id = pcdi.pcdi_id
           and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
           and pcm.internal_contract_ref_no = pcbph.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.element_id = aml.attribute_id
           and pcm.contract_type = 'CONCENTRATES'
           and pcm.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and pofh.is_active = 'Y'
           and qum.is_active = 'Y'
           and pcbph.is_active = 'Y'
           and aml.is_active = 'Y'
           and pdm_ele.is_active = 'Y'
           and pdm.is_active = 'Y'
           and pcbpd.is_active = 'Y'
           and pofh.qty_to_be_fixed > 0
         group by pcm.corporate_id,
                  pcm.contract_ref_no,
                  pcdi.delivery_item_no,
                  pdm_ele.product_id,
                  pdm.product_desc,
                  qum.qty_unit,
                  pcbph.price_description,
                  pofh.qp_start_date) t
 where t.qp_start_date between trunc(sysdate) and trunc(sysdate) + 10; --MAKE IT 7
