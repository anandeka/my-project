CREATE OR REPLACE FORCE VIEW v_pci_for_assay (internal_contract_item_ref_no,
                                              internal_contract_ref_no,
                                              contract_ref_no,
                                              contract_item_ref_no,
                                              contract_type,
                                              corporate_id,
                                              cp_name,
                                              cp_id,
                                              product_id,
                                              product_name,
                                              quality_name,
                                              delivery_item_ref_no,
                                              middle_no
                                             )
AS
   SELECT pci.internal_contract_item_ref_no AS internal_contract_item_ref_no,
          pcm.internal_contract_ref_no AS internal_contract_ref_no,
          pcm.contract_ref_no AS contract_ref_no,
          (   pcm.contract_ref_no
           || ' '
           || 'Item No.'
           || ' '
           || pci.del_distribution_item_no
          ) contract_item_ref_no,
          pcm.purchase_sales AS contract_type,
          pcm.corporate_id AS corporate_id, phd.companyname AS cp_name,
          phd.profileid AS cp_id, pcpd.product_id AS product_id,
          pdm.product_desc AS product_name, qat.quality_name AS quality_name,
          (pcm.contract_ref_no || '-' || pcdi.delivery_item_no
          ) AS delivery_item_ref_no,
          pcm.middle_no
     FROM pci_physical_contract_item pci,
          pcm_physical_contract_main pcm,
          pcdb_pc_delivery_basis pcdb,
          pcdi_pc_delivery_item pcdi,
          pcpd_pc_product_definition pcpd,
          pcpq_pc_product_quality pcpq,
          phd_profileheaderdetails phd,
          pdm_productmaster pdm,
          qat_quality_attributes qat
    WHERE pcdb.pcdb_id = pci.pcdb_id
      AND pci.pcdi_id = pcdi.pcdi_id
      AND phd.profileid = pcm.cp_id
      AND pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
      AND pci.pcpq_id = pcpq.pcpq_id
      AND pcpq.pcpq_id = pci.pcpq_id
      AND pcpd.pcpd_id = pcpq.pcpd_id
      AND qat.quality_id = pcpq.quality_template_id
      AND pdm.product_id = pcpd.product_id
      AND pci.is_active = 'Y'
      AND pcm.contract_status = 'In Position'
      AND (pci.is_called_off = 'Y' OR pcdi.is_phy_optionality_present = 'N');