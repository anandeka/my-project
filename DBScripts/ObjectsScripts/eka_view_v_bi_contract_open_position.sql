create or replace view v_bi_contract_open_position as
select pci.internal_contract_item_ref_no as internal_contract_item_ref_no,
       pcm.internal_contract_ref_no as internal_contract_ref_no,
       pcm.contract_ref_no as contract_ref_no,
       cast(pcm.purchase_sales as varchar2(1)) as contract_type,
       pcm.corporate_id as corporate_id,
       pcm.issue_date as issue_date,
       nvl(pcm.contract_type, 'BASEMETAL') trade_type,
       pcpd.product_id as product_id,
       pdm.product_desc as product_name,
       qat.long_desc product_specs,
       pcpq.quality_template_id as quality_id,
       qat.quality_name as quality_name,
       pci.item_qty,
       pci.item_qty_unit_id,
       qum.qty_unit as item_qty_unit,
       ciqs.open_qty as open_qty,
       qum_base.qty_unit_id base_qty_unit_id,
       qum_base.qty_unit base_qty_unit,
       ucm.multiplication_factor qty_conv,
       (case
         when pcm.purchase_sales = 'P' then
          1
         else
          -1
       end) pos_sign,
       pci.expected_delivery_month,
       pci.expected_delivery_year,
       (case
         when pci.expected_delivery_month is not null and
              pci.expected_delivery_year is not null then
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
         else
          trunc(sysdate)
       end) delivery_date,
       cast(pcm.is_tolling_contract as varchar2(1)) as is_tolling_contract,
       pcm.middle_no,
       pci.del_distribution_item_no,
       pcdi.price_option_call_off_status,
       pcdi.delivery_item_no,
       pcm.approval_status
  from pci_physical_contract_item    pci,
       pcm_physical_contract_main    pcm,
       pcdi_pc_delivery_item         pcdi,
       pcpd_pc_product_definition    pcpd,
       pcpq_pc_product_quality       pcpq,
       ciqs_contract_item_qty_status ciqs,
       pdm_productmaster             pdm,
       qat_quality_attributes        qat,
       qum_quantity_unit_master      qum,
       qum_quantity_unit_master      qum_base,
       ucm_unit_conversion_master    ucm
 where pci.pcdi_id = pcdi.pcdi_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and ciqs.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and pci.pcpq_id = pcpq.pcpq_id
   and pcpq.pcpq_id = pci.pcpq_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and qat.quality_id = pcpq.quality_template_id
   and pdm.product_id = pcpd.product_id
   and qum.qty_unit_id = pci.item_qty_unit_id
   and pcpd.product_id = pdm.product_id
   and pdm.base_quantity_unit = qum_base.qty_unit_id
   and pci.item_qty_unit_id = ucm.from_qty_unit_id
   and qum_base.qty_unit_id = ucm.to_qty_unit_id
   and ciqs.open_qty <> 0
   and pcm.contract_type = 'BASEMETAL'
   and pci.is_active = 'Y'
   and pcm.contract_status = 'In Position'
   and nvl(pcm.approval_status,'NA') <> 'Rejected' --added for 78648

union all
select pci.internal_contract_item_ref_no as internal_contract_item_ref_no,
       pcm.internal_contract_ref_no as internal_contract_ref_no,
       pcm.contract_ref_no as contract_ref_no,
       cast(pcm.purchase_sales as varchar2(1)) as contract_type,
       pcm.corporate_id as corporate_id,
       pcm.issue_date as issue_date,
       nvl(pcm.contract_type, 'BASEMETAL') trade_type,
       pcpd.product_id as product_id,
       pdm.product_desc as product_name,
       qat.long_desc product_specs,
       pcpq.quality_template_id as quality_id,
       qat.quality_name as quality_name,
       pci.item_qty,
       pci.item_qty_unit_id,
       qum.qty_unit as item_qty_unit,
       (case
         when pcpq.unit_of_measure = 'Dry' then
          ciqs.open_qty
         else
          ciqs.open_qty * (1 - (nvl(vsh.typical, 1) / 100))
       end) as open_qty,
       qum_base.qty_unit_id base_qty_unit_id,
       qum_base.qty_unit base_qty_unit,
       ucm.multiplication_factor qty_conv,
       (case
         when pcm.purchase_sales = 'P' then
          1
         else
          -1
       end) pos_sign,
       pci.expected_delivery_month,
       pci.expected_delivery_year,
       (case
         when pci.expected_delivery_month is not null and
              pci.expected_delivery_year is not null then
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
         else
          trunc(sysdate)
       end) delivery_date,
       cast(pcm.is_tolling_contract as varchar2(1)) as is_tolling_contract,
       pcm.middle_no,
       pci.del_distribution_item_no,
       pcdi.price_option_call_off_status,
       pcdi.delivery_item_no,
       pcm.approval_status
  from pci_physical_contract_item    pci,
       pcm_physical_contract_main    pcm,
       pcdi_pc_delivery_item         pcdi,
       pcpd_pc_product_definition    pcpd,
       pcpq_pc_product_quality       pcpq,
       ciqs_contract_item_qty_status ciqs,
       pdm_productmaster             pdm,
       qat_quality_attributes        qat,
       qum_quantity_unit_master      qum_base,
       qum_quantity_unit_master      qum,
       v_deductible_value_by_ash_id  vsh,
       ucm_unit_conversion_master    ucm
 where pci.pcdi_id = pcdi.pcdi_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and ciqs.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and pci.pcpq_id = pcpq.pcpq_id
   and pcpq.pcpq_id = pci.pcpq_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and qat.quality_id = pcpq.quality_template_id
   and pdm.product_id = pcpd.product_id
   and qum.qty_unit_id = pci.item_qty_unit_id
   and pdm.base_quantity_unit = qum_base.qty_unit_id
   and pci.item_qty_unit_id = ucm.from_qty_unit_id
   and qum_base.qty_unit_id = ucm.to_qty_unit_id
   and ciqs.open_qty <> 0
   and pcm.contract_type <> 'BASEMETAL'
   and pcpq.assay_header_id = vsh.ash_id(+)
   and pci.is_active = 'Y'
   and pcm.contract_status = 'In Position'
   and nvl(pcm.approval_status,'NA') <> 'Rejected';