create or replace view v_pci_pcdi_details as
select pcdi.pcdi_id,
       pci.internal_contract_item_ref_no,
       pcdi.internal_contract_ref_no,
       pcdi.delivery_item_no,
       pcm.purchase_sales,
       pcm.contract_ref_no,
       pci.del_distribution_item_no,
       pcdb.inco_term_id,
       pcdb.country_id,
       pcdb.city_id,
       pcpd.strategy_id,
       pcpd.product_id,
       pcpd.profit_center_id,
       pcpq.quality_template_id,
       pcpq.assay_header_id,
       pcm.trader_id,
       pcm.cp_id,
       pcm.product_group_type,
       pcm.payment_term_id,
       pcdi.payment_due_date
  from pci_physical_contract_item pci,
       pcdi_pc_delivery_item      pcdi,
       pcdb_pc_delivery_basis     pcdb,
       pcm_physical_contract_main pcm,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality    pcpq
 where pci.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pci.pcdb_id = pcdb.pcdb_id
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pci.pcpq_id = pcpq.pcpq_id
   and pci.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and nvl(pcm.is_tolling_contract,'N') = 'N'
   and pcm.contract_status <> 'Cancelled'
   and pcm.is_active = 'Y' 
/