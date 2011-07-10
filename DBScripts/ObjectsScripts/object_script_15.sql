
CREATE OR REPLACE FORCE VIEW v_pci (internal_contract_item_ref_no,
                                    internal_contract_ref_no,
                                    contract_ref_no,
                                    item_no,
                                    contract_item_ref_no,
                                    contract_type,
                                    partnership_type,
                                    corporate_id,
                                    corporate_name,
                                    cp_id,
                                    cp_name,
                                    cp_person_in_charge_id,
                                    cp_contract_ref_no,
                                    our_person_in_charge_id,
                                    issue_date,
                                    trade_type,
                                    item_status,
                                    is_active,
                                    invoice_currency_id,
                                    invoice_currency,
                                    product_id,
                                    product_name,
                                    product_specs,
                                    quality_id,
                                    quality_name,
                                    phy_attribute_group_no,
                                    assay_header_id,
                                    customs_id,
                                    duty_status_id,
                                    tax_status_id,
                                    delivery_period_type,
                                    delivery_from_date,
                                    delivery_to_date,
                                    delivery_from_month,
                                    delivery_from_year,
                                    delivery_to_month,
                                    delivery_to_year,
                                    pcpq_id,
                                    pcdi_id,
                                    pcdb_id,
                                    inco_term_id,
                                    incoterm,
                                    valuation_country_id,
                                    valuation_state_id,
                                    valuation_city_id,
                                    valuation_country,
                                    valuation_state,
                                    valuation_city,
                                    payment_term_id,
                                    payment_term,
                                    terms,
                                    origination_city_id,
                                    origination_state_id,
                                    origination_country_id,
                                    destination_city_id,
                                    destination_state_id,
                                    destination_country_id,
                                    pricing,
                                    item_qty,
                                    item_qty_unit_id,
                                    item_qty_unit,
                                    qty_basis,
                                    open_qty,
                                    gmr_qty,
                                    shipped_qty,
                                    warehouse_qty,
                                    title_transferred_qty,
                                    alloc_qty,
                                    unallocated_qty,
                                    fulfilled_qty,
                                    prov_invoiced_qty,
                                    final_invoiced_qty,
                                    fulfillment_status,
                                    allocation_status,
                                    delivery_item_ref_no,
                                    quota_month,
                                    LOCATION,
                                    incoterm_location,
                                    qp_period,
                                    profit_center_id,
                                    profit_center_name,
                                    tolerance_type,
                                    tolerance_min,
                                    tolerance_max,
                                    tolerance_unit_id,
                                    min_tolerance_item_qty,
                                    max_tolerance_item_qty,
                                    strategy_name,
                                    trader
                                   )
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
          qat.quality_name AS quality_name,
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
          pcpq.unit_of_measure AS qty_basis,
          ciqs.open_qty AS open_qty, ciqs.gmr_qty AS gmr_qty,
          ciqs.shipped_qty AS shipped_qty, 0 AS warehouse_qty,
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
          (pci.delivery_from_month || '-' || pci.delivery_from_year
          ) AS quota_month,
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
                             ) AS trader
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
          gab_globaladdressbook gab
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
      AND pym.payment_term_id = pcm.payment_term_id
      AND pcm.corporate_id = akc.corporate_id
      AND pcpq.pcpq_id = pci.pcpq_id
      AND pcpd.pcpd_id = pcpq.pcpd_id
      AND qat.quality_id = pcpq.quality_template_id
      AND pdm.product_id = pcpd.product_id
      AND qum.qty_unit_id = pci.item_qty_unit_id
      AND cpc.profit_center_id = pcpd.profit_center_id
      AND pcm.invoice_currency_id = cm.cur_id
      AND css.strategy_id = pcpd.strategy_id
      AND pcm.trader_id = aku.user_id
      AND aku.gabid = gab.gabid
      AND pci.is_active = 'Y'
      AND (pci.is_called_off = 'Y' OR pcdi.is_phy_optionality_present = 'N');



CREATE TABLE AAM_ASSAY_ACTION_MAPPING
(
  INTERNAL_ACTION_REF_NO  VARCHAR2(15 BYTE),
  ASH_ID                  VARCHAR2(15 BYTE),
  AAM_ID                  VARCHAR2(15 BYTE)  primary key  NOT NULL
);


ALTER TABLE AAM_ASSAY_ACTION_MAPPING ADD (
  CONSTRAINT FK_AAM_ASSAY_ACTION_REF_NO 
 FOREIGN KEY (INTERNAL_ACTION_REF_NO) 
 REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),
  CONSTRAINT FK_AAM_ASH 
 FOREIGN KEY (ASH_ID) 
 REFERENCES ASH_ASSAY_HEADER (ASH_ID));
 
 CREATE SEQUENCE SEQ_AAM_ASSAY
  START WITH 227
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

alter table ASH_ASSAY_HEADER modify(ASSAY_TYPE VARCHAR2 (50 Byte));

  