create or replace view v_bi_assay_comparision as 
SELECT t.corporate_id,
       t.corporate_name,
       t.business_line_name,
       t.profit_center_id,
       t.profit_center_name,
       t.profit_center_short_name,
       t.strategy_id,
       t.contract_type,
       t.producttype,
       t.product_desc,
       t.quality_name,
       t.contract_ref_no,
       t.delivery_ref_no,
       t.internal_contract_item_ref_no,
       t.cpname,
       t.trader,
       t.executiontype,
       t.gmr_ref_no,
       t.internal_grd_ref_no,
       t.gmr_latest_action_action_id,
       t.eff_date,
       t.internal_stock_ref_no,
       t.is_final_weight,
       t.sublot_ref_no,
       t.assay_winner,
       t.ash_id,
       t.assay_type,
       t.assay_ref_no,
       t.umpirename,
       t.wet_qty,
       t.dry_qty,
       t.product_base_uom,
       t.element_id,
       t.element_name,
       t.assayvalue,
       t.assayratio,
       t.assay_content,
       t.assayvalue weighted_avg_sublot,
       (SUM(t.assay_content * t.assayvalue)
        OVER(PARTITION BY t.internal_grd_ref_no,
             t.element_id ORDER BY t.internal_grd_ref_no,
             t.element_id) / SUM(DECODE(t.assay_content, NULL, 1, 0, 1))
        OVER(PARTITION BY t.internal_grd_ref_no,
             t.element_id ORDER BY t.internal_grd_ref_no,
             t.element_id)) weighted_avg_stock,
       (SUM(t.assay_content * t.assayvalue)
        OVER(PARTITION BY t.gmr_ref_no, t.element_id ORDER BY t.gmr_ref_no) /
        SUM(DECODE(t.assay_content, NULL, 1, 0, 1))
        OVER(PARTITION BY t.gmr_ref_no, t.element_id ORDER BY t.gmr_ref_no)) weighted_avg_gmr
  FROM (SELECT gmr.corporate_id,
               akc.corporate_name,
               blm.business_line_name,
               grd.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               grd.strategy_id,
               (CASE
                 WHEN pcm.purchase_sales = 'P' AND
                      pcm.is_tolling_contract = 'N' THEN
                  'Purchase Contract'
                 WHEN pcm.purchase_sales = 'S' AND
                      pcm.is_tolling_contract = 'N' THEN
                  'Sales Contract'
                 WHEN pcmte.tolling_service_type = 'P' AND
                      pcm.is_tolling_contract = 'Y' AND
                      pcmte.is_pass_through = 'Y' THEN
                  'Internal Buy Tolling Service Contract'
                 WHEN pcmte.tolling_service_type = 'P' AND
                      pcm.is_tolling_contract = 'Y' AND
                      pcmte.is_pass_through = 'N' THEN
                  'Buy Tolling Service Contract'
                 WHEN pcmte.tolling_service_type = 'S' AND
                      pcm.is_tolling_contract = 'Y' THEN
                  'Sell Tolling Service Contract'
                 WHEN pcm.purchase_sales = 'P' AND
                      pcm.is_tolling_contract = 'Y' AND
                      pcmte.is_pass_through IS NULL THEN
                  'Tolling Service Contract'
               END) contract_type,
               pdm.product_type_id producttype,
               pdm.product_desc,
               qat.quality_name,
               pcm.contract_ref_no,
               pci.del_distribution_item_no delivery_ref_no,
               grd.internal_contract_item_ref_no,
               phd.companyname cpname,
               aku.login_name trader,
               pcm.partnership_type executiontype,
               gmr.gmr_ref_no,
               grd.internal_grd_ref_no internal_grd_ref_no,
               gmr.gmr_latest_action_action_id,
               gmr.eff_date,
               grd.internal_stock_ref_no,
               gmr.is_final_weight,
               asm.sub_lot_no sublot_ref_no,
               pqca.assay_winner,
               ash.ash_id,
               (CASE
                 WHEN ash.assay_type = 'Shipment Assay' THEN
                  'Contractual Assay'
                 ELSE
                  ash.assay_type
               END) assay_type,
               ash.assay_ref_no,
               (CASE
                 WHEN ash.assay_type IN ('Umpire Assay', 'Final Assay') THEN
                 phd_umpire.companyname
                 ELSE
                  NULL
               END) umpirename,
               asm.net_weight wet_qty,
               asm.dry_weight dry_qty,
               asm.net_weight_unit,
               qum.qty_unit product_base_uom,
               pqca.element_id,
               aml.attribute_name element_name,
               pqca.typical assayvalue,
               rm.ratio_name assayratio,
               pkg_report_general.fn_get_elmt_assay_content_qty(pqca.element_id,
                                                                ash.ash_id,
                                                                asm.dry_weight,
                                                                asm.net_weight_unit) assay_content
          FROM gmr_goods_movement_record   gmr,
               grd_goods_record_detail     grd,
               pci_physical_contract_item  pci,
               pcm_physical_contract_main  pcm,
               pcmte_pcm_tolling_ext       pcmte,
               pcdi_pc_delivery_item       pcdi,
               pcpq_pc_product_quality     pcpq,
               pdm_productmaster           pdm,
               qat_quality_attributes      qat,
               qum_quantity_unit_master    qum,
               ash_assay_header            ash,
               asm_assay_sublot_mapping    asm,
               pqca_pq_chemical_attributes pqca,
               rm_ratio_master             rm,
               aml_attribute_master_list   aml,
               cpc_corporate_profit_center cpc,
               blm_business_line_master    blm,
               ak_corporate                akc,
               ak_corporate_user           aku,
               phd_profileheaderdetails    phd,
               phd_profileheaderdetails     phd_umpire
         WHERE gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           AND gmr.is_deleted = 'N'
           AND grd.status = 'Active'
           AND gmr.corporate_id = akc.corporate_id
           AND grd.profit_center_id = cpc.profit_center_id
           AND cpc.business_line_id = blm.business_line_id(+)
           AND gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           AND pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
           AND pcm.cp_id = phd.profileid
           AND pcm.trader_id = aku.user_id
           AND pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           AND pcdi.pcdi_id = pci.pcdi_id
           AND pci.pcpq_id = pcpq.pcpq_id
           AND grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           AND grd.product_id = pdm.product_id
           AND grd.quality_id = qat.quality_id
           AND asm.net_weight_unit = qum.qty_unit_id
           AND grd.internal_grd_ref_no = ash.internal_grd_ref_no
           AND gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
           AND ash.ash_id = asm.ash_id
           AND asm.asm_id = pqca.asm_id
           AND pqca.unit_of_measure = ratio_id
           AND pqca.element_id = aml.attribute_id
           AND ash.assayer =phd_umpire.profileid(+)
           AND pci.is_active = 'Y'
           AND pcm.is_active = 'Y'
           AND pcdi.is_active = 'Y'
           AND ash.is_active = 'Y'
           AND asm.is_active = 'Y'
           AND pqca.is_active = 'Y'
           AND rm.is_active = 'Y'
           AND pdm.is_active = 'Y'
           AND qat.is_active = 'Y'
           AND qum.is_active = 'Y'
           AND aml.is_active = 'Y'           
           AND ash.assay_type NOT IN
               ('Pricing Assay', 'Position Assay',
                'Weighted Avg Position Assay', 'Weighted Avg Pricing Assay','Invoicing Assay','Weighted Avg Invoice Assay')
           union all
           select gmr.corporate_id,
       akc.corporate_name,
       blm.business_line_name,
       dgrd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       dgrd.strategy_id,
       (case
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'N' then
          'Purchase Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'N' then
          'Sales Contract'
         when pcmte.tolling_service_type = 'P' and
              pcm.is_tolling_contract = 'Y' and pcmte.is_pass_through = 'Y' then
          'Internal Buy Tolling Service Contract'
         when pcmte.tolling_service_type = 'P' and
              pcm.is_tolling_contract = 'Y' and pcmte.is_pass_through = 'N' then
          'Buy Tolling Service Contract'
         when pcmte.tolling_service_type = 'S' and
              pcm.is_tolling_contract = 'Y' then
          'Sell Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through is null then
          'Tolling Service Contract'
       end) contract_type,
       pdm.product_type_id producttype,
       pdm.product_desc,
       qat.quality_name,
       pcm.contract_ref_no,
       pci.del_distribution_item_no delivery_ref_no,
       dgrd.internal_contract_item_ref_no,
       phd.companyname cpname,
       aku.login_name trader,
       pcm.partnership_type executiontype,
       gmr.gmr_ref_no,
       dgrd.internal_dgrd_ref_no internal_grd_ref_no,
       gmr.gmr_latest_action_action_id,
       gmr.eff_date,
       dgrd.internal_stock_ref_no,
       gmr.is_final_weight,
       asm.sub_lot_no sublot_ref_no,
       pqca.assay_winner,
       ash.ash_id,
       (case
         when ash.assay_type = 'Shipment Assay' then
          'Contractual Assay'
         else
          ash.assay_type
       end) assay_type,
       ash.assay_ref_no,
       (case
         when ash.assay_type in ('Umpire Assay', 'Final Assay') then
         phd_umpire.companyname
         else
          null
       end) umpirename,
       asm.net_weight wet_qty,
       asm.dry_weight dry_qty,
       asm.net_weight_unit,
       qum.qty_unit product_base_uom,
       pqca.element_id,
       aml.attribute_name element_name,
       pqca.typical assayvalue,
       rm.ratio_name assayratio,
       pkg_report_general.fn_get_elmt_assay_content_qty(pqca.element_id,
                                                        ash.ash_id,
                                                        asm.dry_weight,
                                                        asm.net_weight_unit) assay_content
  from gmr_goods_movement_record   gmr,
       dgrd_delivered_grd          dgrd,
       pci_physical_contract_item  pci,
       pcm_physical_contract_main  pcm,
       pcmte_pcm_tolling_ext       pcmte,
       pcdi_pc_delivery_item       pcdi,
       pcpq_pc_product_quality     pcpq,
       pdm_productmaster           pdm,
       qat_quality_attributes      qat,
       qum_quantity_unit_master    qum,
       ash_assay_header            ash,
       asm_assay_sublot_mapping    asm,
       pqca_pq_chemical_attributes pqca,
       rm_ratio_master             rm,
       aml_attribute_master_list   aml,
       cpc_corporate_profit_center cpc,
       blm_business_line_master    blm,
       ak_corporate                akc,
       ak_corporate_user           aku,
       phd_profileheaderdetails    phd,
       phd_profileheaderdetails     phd_umpire
 where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
   and gmr.is_deleted = 'N'
   and dgrd.status = 'Active'
   and gmr.corporate_id = akc.corporate_id
   and dgrd.profit_center_id = cpc.profit_center_id
   and cpc.business_line_id = blm.business_line_id(+)
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
   and pcm.cp_id = phd.profileid
   and pcm.trader_id = aku.user_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.pcpq_id = pcpq.pcpq_id
   and dgrd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and dgrd.product_id = pdm.product_id
   and dgrd.quality_id = qat.quality_id
   and asm.net_weight_unit = qum.qty_unit_id
   and dgrd.internal_dgrd_ref_no = ash.internal_grd_ref_no
   and gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
   and ash.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pqca.unit_of_measure = ratio_id
   and pqca.element_id = aml.attribute_id
   and ash.assayer =phd_umpire.profileid(+)
   and pci.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and ash.is_active = 'Y'
   and asm.is_active = 'Y'
   and pqca.is_active = 'Y'
   and rm.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qat.is_active = 'Y'
   and qum.is_active = 'Y'
   and aml.is_active = 'Y'
   and ash.assay_type not in
       ('Pricing Assay', 'Position Assay', 'Weighted Avg Position Assay',
        'Weighted Avg Pricing Assay', 'Invoicing Assay',
        'Weighted Avg Invoice Assay')
) t;
