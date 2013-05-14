create or replace view v_rpt_contract_vs_delivered as
---this view used in contracted vs delivered report
with deductible_value as
(select * from v_rpt_assay_deductible),
pricing_assay_value as 
(select * from v_rpt_pricing_assay pav)
select 'Actual' section,
       akc.corporate_id,
       akc.corporate_name,
       gmr.contract_type,
       grd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       grd.strategy_id,
       pcm.cp_id supplier_id,
       phd.companyname supplier,
       axs.eff_date gmr_date,
       gmr.bl_no arrival_no,
       agmr.eff_date arrival_date,
       gmr.internal_gmr_ref_no,
       pcm.contract_ref_no,
       pcm.contract_ref_no || '-' || pci.del_distribution_item_no cont_itm_ref_no,
       gmr.gmr_ref_no,
       round(round(gmr.qty, 4) * ucm_con.multiplication_factor, 4) gmr_wet_qty, -- req
       sum(round(round(grd.qty, 4) * ucm_con.multiplication_factor, 4)) grd_wet_qty,
       -- req -- this column used qty used in report not the gme.qty
       sum(round((round(grd.qty, 4) -
                 (round(grd.qty, 4) * nvl(sded.deductibile_ratio, 0))) *
                 ucm_con.multiplication_factor,
                 4)) grd_dry_qty, -- req
       qum.qty_unit_id,
       qum.qty_unit,
       grd.product_id,
       pdm.product_desc,
       grd.quality_id,
       qat.quality_name,
       pav.element_id,
       aml.attribute_name element_name,
       round(sum(round((round(grd.qty, 4) -
                       (round(grd.qty, 4) * nvl(sded.deductibile_ratio, 0))) *
                       ucm_con.multiplication_factor,
                       4) * nvl(pav.typical, 0) ---for 78661
                 ) /
             sum(round((round(grd.qty, 4) -
                       (round(grd.qty, 4) * nvl(sded.deductibile_ratio, 0))) *
                       ucm_con.multiplication_factor,
                       4)),
             8) typical,
       rm.ratio_name,
       round(sum(round((round(grd.qty, 4) -
                       (round(grd.qty, 4) * nvl(sded.deductibile_ratio, 0))) *
                       ucm_con.multiplication_factor,
                       4) * nvl(pav.typical_ratio, 0)),
             4) assay_qty,
       (case
         when rm.ratio_name = '%' then
          qum.qty_unit_id
         else
          qum_element.qty_unit_id
       end) assay_qty_unit,
       (case
         when rm.ratio_name = '%' then
          qum.qty_unit
         else
          qum_element.qty_unit
       end) ele_qty_unit,
       pcm.purchase_sales
  from gmr_goods_movement_record gmr,
       grd_goods_record_detail grd,
       pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pci_physical_contract_item pci,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       qum_quantity_unit_master qum,
       phd_profileheaderdetails phd,
       spq_stock_payable_qty spq,
       deductible_value sded,
       pricing_assay_value pav,
       rm_ratio_master rm,
       aml_attribute_master_list aml,
       ak_corporate akc,
       cpc_corporate_profit_center cpc,
       ucm_unit_conversion_master ucm_con,
       qum_quantity_unit_master qum_element,
       axs_action_summary axs,
       (select gmr.internal_gmr_ref_no,
               agmr.eff_date
          from gmr_goods_movement_record gmr,
               agmr_action_gmr           agmr
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agmr.gmr_latest_action_action_id in
               ('landingDetail', 'warehouseReceipt')
           and agmr.is_deleted = 'N') agmr
 where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   and gmr.is_deleted = 'N'
   and grd.status = 'Active'
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.pcpq_id = pcpq.pcpq_id
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and grd.product_id = pdm.product_id
   and grd.quality_id = qat.quality_id
   and grd.qty_unit_id = ucm_con.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_con.to_qty_unit_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcm.cp_id = phd.profileid
   and spq.assay_header_id = sded.ash_id(+)
   and spq.assay_header_id = pav.ash_id
   and spq.element_id = pav.element_id
   and gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
   and spq.internal_grd_ref_no = grd.internal_grd_ref_no
   and spq.element_id = aml.attribute_id
   and pav.unit_of_measure = rm.ratio_id(+)
   and spq.element_id = aml.attribute_id
   and gmr.corporate_id = akc.corporate_id
   and grd.profit_center_id = cpc.profit_center_id
   and rm.qty_unit_id_numerator = qum_element.qty_unit_id(+)
   and grd.tolling_stock_type in ('None Tolling')
   and pci.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and spq.is_stock_split = 'N'
--   and gmr.corporate_id = ('{?CorporateID}')
 group by akc.corporate_id,
          akc.corporate_name,
          gmr.contract_type,
          grd.profit_center_id,
          cpc.profit_center_name,
          cpc.profit_center_short_name,
          grd.strategy_id,
          pcm.cp_id,
          phd.companyname,
          axs.eff_date,
          gmr.bl_no,
          agmr.eff_date,
          gmr.internal_gmr_ref_no,
          pcm.contract_ref_no,
          pci.del_distribution_item_no,
          gmr.gmr_ref_no,
          gmr.qty,
          ucm_con.multiplication_factor,
          qum.qty_unit_id,
          qum.qty_unit,
          grd.product_id,
          pdm.product_desc,
          grd.quality_id,
          qat.quality_name,
          pav.element_id,
          aml.attribute_name,
          rm.ratio_name,
          qum.qty_unit_id,
          qum_element.qty_unit,
          qum_element.qty_unit_id,
          pcm.purchase_sales
union all ---sales
select 'Actual' section,
       akc.corporate_id,
       akc.corporate_name,
       gmr.contract_type,
       dgrd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       dgrd.strategy_id,
       pcm.cp_id supplier_id,
       phd.companyname supplier,
       axs.eff_date gmr_date,
       gmr.bl_no arrival_no,
       agmr.eff_date arrival_date,
       gmr.internal_gmr_ref_no,
       pcm.contract_ref_no,
       pcm.contract_ref_no || '-' || pci.del_distribution_item_no cont_itm_ref_no,
       gmr.gmr_ref_no,
       round(round(gmr.qty, 4) * ucm_con.multiplication_factor, 4) gmr_wet_qty, -- req
       sum(round(round(dgrd.net_weight, 4) * ucm_con.multiplication_factor,
                 4)) grd_wet_qty,
       -- req -- this column used qty used in report not the gme.qty
       sum(round((round(dgrd.net_weight, 4) -
                 (round(dgrd.net_weight, 4) *
                 nvl(sded.deductibile_ratio, 0))) *
                 ucm_con.multiplication_factor,
                 4)) grd_dry_qty, -- req
       qum.qty_unit_id,
       qum.qty_unit,
       dgrd.product_id,
       pdm.product_desc,
       dgrd.quality_id,
       qat.quality_name,
       pav.element_id,
       aml.attribute_name element_name,
       round(sum(round((round(dgrd.net_weight, 4) -
                       (round(dgrd.net_weight, 4) *
                       nvl(sded.deductibile_ratio, 0))) *
                       ucm_con.multiplication_factor,
                       4) * nvl(pav.typical, 0) -------for 78661
                 ) / sum(round((round(dgrd.net_weight, 4) -
                               (round(dgrd.net_weight, 4) *
                               nvl(sded.deductibile_ratio, 0))) *
                               ucm_con.multiplication_factor,
                               4)),
             8) typical,
       rm.ratio_name,
       round(sum(round((round(dgrd.net_weight, 4) -
                       (round(dgrd.net_weight, 4) *
                       nvl(sded.deductibile_ratio, 0))) *
                       ucm_con.multiplication_factor,
                       4) * nvl(pav.typical_ratio, 0)),
             4) assay_qty,
       (case
         when rm.ratio_name = '%' then
          qum.qty_unit_id
         else
          qum_element.qty_unit_id
       end) assay_qty_unit,
       (case
         when rm.ratio_name = '%' then
          qum.qty_unit
         else
          qum_element.qty_unit
       end) ele_qty_unit,
       pcm.purchase_sales
  from gmr_goods_movement_record gmr,
       dgrd_delivered_grd dgrd,
       axs_action_summary axs,
       (select gmr.internal_gmr_ref_no,
               agmr.eff_date
          from gmr_goods_movement_record gmr,
               agmr_action_gmr           agmr
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agmr.gmr_latest_action_action_id in
               ('landingDetail', 'warehouseReceipt', 'salesLandingDetail')
           and agmr.is_deleted = 'N') agmr,
       pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pci_physical_contract_item pci,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       qum_quantity_unit_master qum,
       phd_profileheaderdetails phd,
       ucm_unit_conversion_master ucm_con,
       spq_stock_payable_qty spq,
       deductible_value sded,
       pricing_assay_value pav,
       rm_ratio_master rm,
       aml_attribute_master_list aml,
       ak_corporate akc,
       cpc_corporate_profit_center cpc,
       qum_quantity_unit_master qum_element
 where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
   and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   and gmr.is_deleted = 'N'
   and dgrd.status = 'Active'
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.pcpq_id = pcpq.pcpq_id
   and dgrd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and dgrd.product_id = pdm.product_id
   and dgrd.quality_id = qat.quality_id
   and dgrd.net_weight_unit_id = ucm_con.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_con.to_qty_unit_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcm.cp_id = phd.profileid
   and gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
   and spq.internal_dgrd_ref_no = dgrd.internal_dgrd_ref_no
   and spq.assay_header_id = sded.ash_id(+)
   and spq.assay_header_id = pav.ash_id
   and spq.element_id = pav.element_id
   and pav.unit_of_measure = rm.ratio_id(+)
   and spq.element_id = aml.attribute_id
   and gmr.corporate_id = akc.corporate_id
   and dgrd.profit_center_id = cpc.profit_center_id
   and rm.qty_unit_id_numerator = qum_element.qty_unit_id(+)
   and pci.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and spq.is_stock_split = 'N'
--  and gmr.corporate_id = ('{?CorporateID}')
 group by akc.corporate_id,
          akc.corporate_name,
          gmr.contract_type,
          dgrd.profit_center_id,
          cpc.profit_center_name,
          cpc.profit_center_short_name,
          dgrd.strategy_id,
          pcm.cp_id,
          phd.companyname,
          axs.eff_date,
          gmr.bl_no,
          agmr.eff_date,
          gmr.internal_gmr_ref_no,
          pcm.contract_ref_no,
          pci.del_distribution_item_no,
          gmr.gmr_ref_no,
          gmr.qty,
          ucm_con.multiplication_factor,
          qum.qty_unit_id,
          qum.qty_unit,
          dgrd.product_id,
          pdm.product_desc,
          dgrd.quality_id,
          qat.quality_name,
          pav.element_id,
          aml.attribute_name,
          rm.ratio_name,
          qum_element.qty_unit_id,
          qum_element.qty_unit,
          pcm.purchase_sales
union all
select 'Expected' section,
       akc.corporate_id,
       akc.corporate_name,
       gmr.contract_type,
       grd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       grd.strategy_id,
       pcm.cp_id supplier_id,
       phd.companyname supplier,
       axs.eff_date gmr_date,
       gmr.bl_no arrival_no,
       agmr.eff_date arrival_date,
       gmr.internal_gmr_ref_no,
       pcm.contract_ref_no,
       pcm.contract_ref_no || '-' || pci.del_distribution_item_no cont_itm_ref_no,
       gmr.gmr_ref_no,
       round(round(gmr.qty, 4) * ucm_con.multiplication_factor, 4) gmr_wet_qty, -- req
       sum(round(round(grd.qty, 4) * ucm_con.multiplication_factor, 4)) grd_wet_qty,
       -- req -- this column used qty used in report not the gme.qty
       sum(round((round(grd.qty, 4) -
                 (round(grd.qty, 4) * nvl(sded.deductibile_ratio, 0))) *
                 ucm_con.multiplication_factor,
                 4)) grd_dry_qty, -- req
       qum.qty_unit_id,
       qum.qty_unit,
       grd.product_id,
       pdm.product_desc,
       grd.quality_id,
       qat.quality_name,
       pqca.element_id,
       aml.attribute_name element_name,
       round(sum(round((round(grd.qty, 4) -
                       (round(grd.qty, 4) * nvl(sded.deductibile_ratio, 0))) *
                       ucm_con.multiplication_factor,
                       4) * (case
                               when rm.ratio_name = '%' then
                                round(pqca.typical, 8) / 100
                               else
                                round(pqca.typical, 8)
                             end)) /
             sum(round((round(grd.qty, 4) -
                       (round(grd.qty, 4) * nvl(sded.deductibile_ratio, 0))) *
                       ucm_con.multiplication_factor,
                       4)),
             8) typical,
       rm.ratio_name,
       round(sum(round((round(grd.qty, 4) -
                       (round(grd.qty, 4) * nvl(sded.deductibile_ratio, 0))) *
                       ucm_con.multiplication_factor,
                       4) * (case
                               when rm.ratio_name = '%' then
                                round(pqca.typical, 8) / 100
                               else
                                round(pqca.typical, 8)
                             end)),
             4) assay_qty,
       (case
         when rm.ratio_name = '%' then
          qum.qty_unit_id
         else
          rm.qty_unit_id_numerator
       end) assay_qty_unit,
       (case
         when rm.ratio_name = '%' then
          qum.qty_unit
         else
          qum_element.qty_unit
       end) ele_qty_unit,
       pcm.purchase_sales
  from gmr_goods_movement_record gmr,
       grd_goods_record_detail grd,
       pci_physical_contract_item pci,
       pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       qum_quantity_unit_master qum,
       phd_profileheaderdetails phd,
       ash_assay_header ash,
       asm_assay_sublot_mapping asm,
       pqca_pq_chemical_attributes pqca,
       deductible_value sded,
       rm_ratio_master rm,
       aml_attribute_master_list aml,
       cpc_corporate_profit_center cpc,
       ucm_unit_conversion_master ucm_con,
       ak_corporate akc,
       qum_quantity_unit_master qum_element,
       axs_action_summary axs,
       (select gmr.internal_gmr_ref_no,
               agmr.eff_date
          from gmr_goods_movement_record gmr,
               agmr_action_gmr           agmr
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agmr.gmr_latest_action_action_id in
               ('landingDetail', 'warehouseReceipt')
           and agmr.is_deleted = 'N') agmr
 where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   and gmr.is_deleted = 'N'
   and grd.status = 'Active'
   and gmr.corporate_id = akc.corporate_id
   and grd.profit_center_id = cpc.profit_center_id
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.pcpq_id = pcpq.pcpq_id
   and pcm.cp_id = phd.profileid
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and grd.product_id = pdm.product_id
   and grd.quality_id = qat.quality_id
   and grd.qty_unit_id = ucm_con.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_con.to_qty_unit_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpq.assay_header_id = ash.ash_id
   and pcpq.assay_header_id = sded.ash_id(+)
   and ash.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pqca.unit_of_measure = ratio_id
   and pqca.element_id = aml.attribute_id
   and rm.qty_unit_id_numerator = qum_element.qty_unit_id(+)
   and pqca.is_elem_for_pricing = 'Y'
   and grd.tolling_stock_type in ('None Tolling')
   and pci.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and ash.is_active = 'Y'
   and asm.is_active = 'Y'
   and pqca.is_active = 'Y'
 group by akc.corporate_id,
          akc.corporate_name,
          gmr.contract_type,
          grd.profit_center_id,
          cpc.profit_center_name,
          cpc.profit_center_short_name,
          grd.strategy_id,
          pcm.cp_id,
          phd.companyname,
          axs.eff_date,
          gmr.bl_no,
          agmr.eff_date,
          gmr.internal_gmr_ref_no,
          pcm.contract_ref_no,
          pci.del_distribution_item_no,
          gmr.gmr_ref_no,
          gmr.qty,
          ucm_con.multiplication_factor,
          qum.qty_unit_id,
          qum.qty_unit,
          grd.product_id,
          pdm.product_desc,
          grd.quality_id,
          qat.quality_name,
          pqca.element_id,
          aml.attribute_name,
          rm.ratio_name,
          qum.qty_unit_id,
          rm.qty_unit_id_numerator,
          qum_element.qty_unit,
          pcm.purchase_sales
union all --- sales
select 'Expected' section,
       akc.corporate_id,
       akc.corporate_name,
       gmr.contract_type,
       dgrd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       dgrd.strategy_id,
       pcm.cp_id supplier_id,
       phd.companyname supplier,
       axs.eff_date gmr_date,
       gmr.bl_no arrival_no,
       agmr.eff_date arrival_date,
       gmr.internal_gmr_ref_no,
       pcm.contract_ref_no,
       pcm.contract_ref_no || '-' || pci.del_distribution_item_no cont_itm_ref_no,
       gmr.gmr_ref_no,
       round(round(gmr.qty, 4) * ucm_con.multiplication_factor, 4) gmr_wet_qty, -- req
       sum(round(round(dgrd.net_weight, 4) * ucm_con.multiplication_factor,
                 4)) grd_wet_qty,
       -- req -- this column used qty used in report not the gme.qty
       sum(round((round(dgrd.net_weight, 4) -
                 (round(dgrd.net_weight, 4) *
                 nvl(sded.deductibile_ratio, 0))) *
                 ucm_con.multiplication_factor,
                 4)) grd_dry_qty, -- re
       qum.qty_unit_id,
       qum.qty_unit,
       dgrd.product_id,
       pdm.product_desc,
       dgrd.quality_id,
       qat.quality_name,
       pqca.element_id,
       aml.attribute_name element_name,
       round(sum(round((round(dgrd.net_weight, 4) -
                       (round(dgrd.net_weight, 4) *
                       nvl(sded.deductibile_ratio, 0))) *
                       ucm_con.multiplication_factor,
                       4) * round(pqca.typical, 8)) /
             sum(round((round(dgrd.net_weight, 4) -
                       (round(dgrd.net_weight, 4) *
                       nvl(sded.deductibile_ratio, 0))) *
                       ucm_con.multiplication_factor,
                       4)),
             8) typical,
       rm.ratio_name,
       round(sum(round((round(dgrd.net_weight, 4) -
                       (round(dgrd.net_weight, 4) *
                       nvl(sded.deductibile_ratio, 0))) *
                       ucm_con.multiplication_factor,
                       4) * (case
                               when rm.ratio_name = '%' then
                                round(pqca.typical, 8) / 100
                               else
                                round(pqca.typical, 8)
                             end)),
             4) assay_qty,
       (case
         when rm.ratio_name = '%' then
          qum.qty_unit_id
         else
          rm.qty_unit_id_numerator
       end) assay_qty_unit,
       (case
         when rm.ratio_name = '%' then
          qum.qty_unit
         else
          qum_element.qty_unit
       end) ele_qty_unit,
       pcm.purchase_sales
  from gmr_goods_movement_record gmr,
       dgrd_delivered_grd dgrd,
       axs_action_summary axs,
       cpc_corporate_profit_center cpc,
       ak_corporate akc,
       pci_physical_contract_item pci,
       pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       phd_profileheaderdetails phd,
       qum_quantity_unit_master qum,
       ash_assay_header ash,
       asm_assay_sublot_mapping asm,
       pqca_pq_chemical_attributes pqca,
       deductible_value sded,
       rm_ratio_master rm,
       aml_attribute_master_list aml,
       ucm_unit_conversion_master ucm_con,
       (select gmr.internal_gmr_ref_no,
               agmr.eff_date
          from gmr_goods_movement_record gmr,
               agmr_action_gmr           agmr
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agmr.gmr_latest_action_action_id in
               ('landingDetail', 'warehouseReceipt', 'salesLandingDetail',
                'releaseOrder')
           and agmr.is_deleted = 'N') agmr,
       qum_quantity_unit_master qum_element
 where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
   and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   and gmr.is_deleted = 'N'
   and dgrd.status = 'Active'
   and gmr.corporate_id = akc.corporate_id
   and dgrd.profit_center_id = cpc.profit_center_id
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.pcpq_id = pcpq.pcpq_id
   and pcm.cp_id = phd.profileid
   and dgrd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and dgrd.product_id = pdm.product_id
   and dgrd.quality_id = qat.quality_id
   and pcpq.assay_header_id = ash.ash_id
   and ash.ash_id = asm.ash_id
   and dgrd.net_weight_unit_id = ucm_con.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_con.to_qty_unit_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpq.assay_header_id = sded.ash_id(+)
   and asm.asm_id = pqca.asm_id
   and pqca.unit_of_measure = ratio_id
   and pqca.is_elem_for_pricing = 'Y'
   and pqca.element_id = aml.attribute_id
   and rm.qty_unit_id_numerator = qum_element.qty_unit_id(+)
   and pci.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and ash.is_active = 'Y'
   and asm.is_active = 'Y'
   and pqca.is_active = 'Y'
--   and gmr.corporate_id = ('{?CorporateID}')
 group by akc.corporate_id,
          akc.corporate_name,
          gmr.contract_type,
          dgrd.profit_center_id,
          cpc.profit_center_name,
          cpc.profit_center_short_name,
          dgrd.strategy_id,
          pcm.cp_id,
          phd.companyname,
          axs.eff_date,
          gmr.bl_no,
          agmr.eff_date,
          gmr.internal_gmr_ref_no,
          pcm.contract_ref_no,
          pci.del_distribution_item_no,
          gmr.gmr_ref_no,
          gmr.qty,
          ucm_con.multiplication_factor,
          qum.qty_unit_id,
          qum.qty_unit,
          dgrd.product_id,
          pdm.product_desc,
          dgrd.quality_id,
          qat.quality_name,
          pqca.element_id,
          aml.attribute_name,
          (case
            when rm.ratio_name = '%' then
             qum.qty_unit_id
            else
             rm.qty_unit_id_numerator
          end),
          rm.ratio_name,
          qum_element.qty_unit,
          pcm.purchase_sales
/
