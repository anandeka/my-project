DROP VIEW V_PCI;
CREATE OR REPLACE VIEW V_PCI
AS 
SELECT pci.internal_contract_item_ref_no AS internal_contract_item_ref_no,
          pcm.internal_contract_ref_no AS internal_contract_ref_no,
          pcm.contract_ref_no AS contract_ref_no,
          CAST (pci.del_distribution_item_no AS VARCHAR2 (5)) AS item_no,
          (   pcm.contract_ref_no
           || ' '
           || 'Item No.'
           || ' '
           || pci.del_distribution_item_no
          ) contract_item_ref_no,
          pcpd.strategy_id,
          CAST (pcm.purchase_sales AS VARCHAR2 (1)) AS contract_type,
          pcm.partnership_type partnership_type,
          pcm.corporate_id AS corporate_id,
          akc.corporate_name AS corporate_name, pcm.cp_id AS cp_id,
          phd.companyname AS cp_name,
          pcm.cp_person_in_charge_id cp_person_in_charge_id,
          pcm.cp_contract_ref_no cp_contract_ref_no,
          pcm.our_person_in_charge_id our_person_in_charge_id,
          pcm.issue_date AS issue_date,
          NVL (pcm.contract_type, 'Normal') trade_type,
          CAST ('Open' AS VARCHAR2 (10)) AS item_status,
          CAST (pci.is_active AS VARCHAR2 (1)) is_active,
          pcm.invoice_currency_id AS invoice_currency_id,
          cm.cur_code invoice_currency, pcpd.product_id AS product_id,
          pdm.product_desc AS product_name, qat.long_desc product_specs,
          pcpq.quality_template_id AS quality_id,
          qat.quality_name AS quality_name, orm.origin_name AS origin_name,
          pcpq.phy_attribute_group_no AS phy_attribute_group_no,
          pcpq.assay_header_id AS assay_header_id, pcdb.customs customs_id,
          pcdb.duty_status duty_status_id, pcdb.tax_status tax_status_id,
          pci.delivery_period_type AS delivery_period_type,
          pci.delivery_from_date AS delivery_from_date,
          pci.delivery_to_date AS delivery_to_date,
          pci.delivery_from_month AS delivery_from_month,
          pci.delivery_from_year AS delivery_from_year,
          pci.delivery_to_month AS delivery_to_month,
          pci.delivery_to_year AS delivery_to_year, pci.pcpq_id AS pcpq_id,
          pci.pcdi_id AS pcdi_id, pci.pcdb_id AS pcdb_id,
          pcdb.inco_term_id AS inco_term_id, itm.incoterm AS incoterm,
          pcdb.warehouse_id AS warehouse_id,
          pcdb.warehouse_shed_id AS warehouse_shed_id,
          pci.m2m_country_id AS valuation_country_id,
          pci.m2m_state_id AS valuation_state_id,
          pci.m2m_city_id AS valuation_city_id,
          cym_valuation.country_name AS valuation_country,
          sm_valuation.state_name AS valuation_state,
          cim_valuation.city_name AS valuation_city,
          pym.payment_term_id AS payment_term_id,
          pym.payment_term AS payment_term,
          (   itm.incoterm
           || ', '
           || cim.city_name
           || ', '
           || cym.country_name
           || ', '
           || pym.payment_term
          ) terms,
          CAST ('' AS VARCHAR2 (1)) AS origination_city_id,
          CAST ('' AS VARCHAR2 (1)) AS origination_state_id,
          CAST ('' AS VARCHAR2 (1)) AS origination_country_id,
          CAST ('' AS VARCHAR2 (1)) AS destination_city_id,
          CAST ('' AS VARCHAR2 (1)) AS destination_state_id,
          CAST ('' AS VARCHAR2 (1)) AS destination_country_id,
          CAST ('Pricing' AS VARCHAR2 (20)) AS pricing, pci.item_qty,
          pci.item_qty_unit_id, qum.qty_unit AS item_qty_unit,
          pcpq.unit_of_measure AS qty_basis, ciqs.open_qty AS open_qty,
          ciqs.gmr_qty AS gmr_qty, ciqs.shipped_qty AS shipped_qty,
          0 AS warehouse_qty,
          ciqs.title_transferred_qty AS title_transferred_qty,
          ciqs.allocated_qty AS alloc_qty,
          ciqs.unallocated_qty AS unallocated_qty,
          ciqs.fulfilled_qty AS fulfilled_qty,
          ciqs.prov_invoiced_qty AS prov_invoiced_qty,
          ciqs.final_invoiced_qty AS final_invoiced_qty,
          CAST ('Not Fulfilled' AS VARCHAR2 (20)) AS fulfillment_status,
          (CASE
              WHEN ciqs.allocated_qty > 0
                 THEN 'Allocated'
              ELSE 'Un-allocated'
           END
          ) AS allocation_status,
          (pcm.contract_ref_no || '-' || pcdi.delivery_item_no
          ) AS delivery_item_ref_no,
          (CASE
              WHEN pci.delivery_period_type = 'Month'
                 THEN CASE
                        WHEN pci.delivery_from_month = pci.delivery_to_month
                        AND pci.delivery_from_year = pci.delivery_to_year
                           THEN    pci.delivery_from_month
                                || ' '
                                || pci.delivery_from_year
                        ELSE    pci.delivery_from_month
                             || ' '
                             || pci.delivery_from_year
                             || ' To '
                             || pci.delivery_to_month
                             || ' '
                             || pci.delivery_to_year
                     END
              WHEN pci.delivery_period_type = 'Date'
                 THEN CASE
                        WHEN TO_CHAR (pci.delivery_from_date, 'dd-Mon-YYYY') =
                                 TO_CHAR (pci.delivery_to_date, 'dd-Mon-YYYY')
                           THEN TO_CHAR (pci.delivery_from_date,
                                         'dd-Mon-YYYY')
                        ELSE    TO_CHAR (pci.delivery_from_date,
                                         'dd-Mon-YYYY')
                             || ' To '
                             || TO_CHAR (pci.delivery_to_date, 'dd-Mon-YYYY')
                     END
              ELSE '-'
           END
          ) quota_month,
          (NVL (cim.city_name, '') || cym.country_name) AS LOCATION,
          (itm.incoterm || ', ' || cim.city_name || ', ' || cym.country_name
          ) AS incoterm_location,
          CAST ('QP PERIOD' AS VARCHAR2 (20)) qp_period,
          pcpd.profit_center_id AS profit_center_id,
          cpc.profit_center_name AS profit_center_name,
          NVL (pcdi.tolerance_type, 'Approx') tolerance_type,
          NVL (pcdi.min_tolerance, 0) tolerance_min,
          NVL (pcdi.max_tolerance, 0) tolerance_max, pcdi.tolerance_unit_id,
          (CASE
              WHEN pcdi.tolerance_type = 'Percentage'
                 THEN pci.item_qty - pci.item_qty
                                     * (pcdi.min_tolerance / 100)
              ELSE pci.item_qty
           END
          ) min_tolerance_item_qty,
          (CASE
              WHEN pcdi.tolerance_type = 'Percentage'
                 THEN pci.item_qty + pci.item_qty
                                     * (pcdi.max_tolerance / 100)
              ELSE pci.item_qty
           END
          ) max_tolerance_item_qty,
          css.strategy_name, (gab.firstname || ' ' || gab.lastname
                             ) AS trader,PCM.TRADER_ID as trader_id,  pcdi.basis_type,
          CAST (pcm.is_tolling_contract AS VARCHAR2 (1)) AS is_tolling_contract, pcm.middle_no,
          pci.del_distribution_item_no, pcdi.price_option_call_off_status,
          pcdi.delivery_item_no,
          DECODE (pcmte.is_pass_through, 'Y', 'Y', 'N', 'N') is_pass_through,
          pcm.approval_status
     FROM pci_physical_contract_item pci,
          pcm_physical_contract_main pcm,
          pcdb_pc_delivery_basis pcdb,
          pcdi_pc_delivery_item pcdi,
          pcpd_pc_product_definition pcpd,
          pcpq_pc_product_quality pcpq,
          ciqs_contract_item_qty_status ciqs,
          phd_profileheaderdetails phd,
          itm_incoterm_master itm,
          cim_citymaster cim,
          cym_countrymaster cym,
          pdm_productmaster pdm,
          qat_quality_attributes qat,
          pym_payment_terms_master pym,
          ak_corporate akc,
          qum_quantity_unit_master qum,
          cym_countrymaster cym_valuation,
          sm_state_master sm_valuation,
          cim_citymaster cim_valuation,
          cpc_corporate_profit_center cpc,
          cm_currency_master cm,
          css_corporate_strategy_setup css,
          ak_corporate_user aku,
          gab_globaladdressbook gab,
          pom_product_origin_master pom,
          orm_origin_master orm,
          pcmte_pcm_tolling_ext pcmte
    WHERE pcdb.pcdb_id = pci.pcdb_id
      AND pci.pcdi_id = pcdi.pcdi_id
      AND phd.profileid = pcm.cp_id
      AND itm.incoterm_id = pcdb.inco_term_id
      AND ciqs.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
      AND pcdb.city_id = cim.city_id(+)
      AND pcdb.country_id = cym.country_id(+)
      AND pci.m2m_country_id = cym_valuation.country_id(+)
      AND pci.m2m_state_id = sm_valuation.state_id(+)
      AND pci.m2m_city_id = cim_valuation.city_id(+)
      AND pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
      AND pci.pcpq_id = pcpq.pcpq_id
      AND pym.payment_term_id(+) = pcm.payment_term_id
      AND pcm.corporate_id = akc.corporate_id
      AND pcpq.pcpq_id = pci.pcpq_id
      AND pcpd.pcpd_id = pcpq.pcpd_id
      AND qat.quality_id = pcpq.quality_template_id
      AND qat.product_origin_id = pom.product_origin_id(+)
      AND pom.origin_id = orm.origin_id(+)
      AND pdm.product_id = pcpd.product_id
      AND qum.qty_unit_id = pci.item_qty_unit_id
      AND cpc.profit_center_id = pcpd.profit_center_id
      AND pcm.invoice_currency_id = cm.cur_id
      AND css.strategy_id = pcpd.strategy_id
      AND pcm.trader_id = aku.user_id
      AND aku.gabid = gab.gabid
      AND pci.is_active = 'Y'
      AND pcm.contract_status = 'In Position'
      AND (pci.is_called_off = 'Y' OR pcdi.is_phy_optionality_present = 'N')
      AND pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+);