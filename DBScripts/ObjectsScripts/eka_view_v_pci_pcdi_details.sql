CREATE OR REPLACE VIEW V_PCI_PCDI_DETAILS AS
SELECT pcdi.pcdi_id, pci.internal_contract_item_ref_no,
          pcdi.internal_contract_ref_no, pcdi.delivery_item_no,
          pcm.purchase_sales, pcm.contract_ref_no,
          pci.del_distribution_item_no, pcdb.inco_term_id, pcdb.country_id,
          pcdb.city_id, pcpd.strategy_id, pcpd.product_id,
          pcpd.profit_center_id, pcpq.quality_template_id,
          pcpq.assay_header_id, pcm.trader_id, pcm.cp_id,
          pcm.product_group_type, pcm.payment_term_id, pcdi.payment_due_date,
          itm.incoterm_id, itm.incoterm, pci.delivery_from_date,
          pci.delivery_to_date, pci.expected_delivery_month,
          pci.expected_delivery_year, pcm.invoice_currency_id, pcm.issue_date,
          pcm.cp_contract_ref_no, pci.m2m_country_id, pci.m2m_city_id, pcdb.pcdb_id,
          pci.delivery_period_type, pci.is_called_off, pcpq.pcpq_id, pcdi.item_price_type,
      NVL (pcm.is_tolling_contract, 'N') is_tolling_contract,
      pci.item_qty_unit_id,
      nvl(pcm.approval_status,'Approved') approval_status
     FROM pci_physical_contract_item pci,
          pcdi_pc_delivery_item pcdi,
          pcdb_pc_delivery_basis pcdb,
          pcm_physical_contract_main pcm,
          pcpd_pc_product_definition pcpd,
          pcpq_pc_product_quality pcpq,
          itm_incoterm_master itm
    WHERE pci.pcdi_id = pcdi.pcdi_id
      AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcdi.internal_contract_ref_no = pcdb.internal_contract_ref_no
      AND pci.pcdb_id = pcdb.pcdb_id
      AND pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pci.pcpq_id = pcpq.pcpq_id
      AND pcdb.inco_term_id = itm.incoterm_id(+)
      AND pci.is_active = 'Y'
      AND pcdi.is_active = 'Y'
      AND pcm.contract_status <> 'Cancelled'
      AND pcm.is_active = 'Y'
      and pcpd.input_output = 'Input'
