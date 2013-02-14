create or replace view v_arrived_not_priced as 
with price_fixation as(select pfd.pofh_id,
       sum(pfd.qty_fixed) priced_qty
  from pfd_price_fixation_details pfd
 where pfd.user_price is not null
 and pfd.is_active='Y'
 and pfd.is_exposure='Y'
 group by pfd.pofh_id)

-- 1. SCT Traxys Event Based Query + Conc:
select phd.companyname cp_name,
       phd.profileid,
       'GMR Level Pricing' section_name,
       pcm.contract_type,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no cont_ref_no,
       cont_qty.contract_qty,
       pcpd.product_id,
       pdm.product_desc product,
       pcdi.delivery_item_no del_itm_ref_no,
       diqs.total_qty del_itm_qty,
       qum_del.qty_unit del_itm_qty_unit,
       qum_del.decimals del_qty_decimals,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no cont_itm_ref_no,
       pcdi.pricing_option_type pricing_option,
       qat.quality_id,
       qat.quality_name quality,
       pci.item_qty cont_itm_qty,
       qum_itm_qty.qty_unit,
       qum_itm_qty.decimals cont_itm_qty_decimals,
       gmr.gmr_ref_no,
       to_number(substr(gmr.gmr_ref_no,
                        instr(gmr.gmr_ref_no, '-') + 1,
                        (instr(gmr.gmr_ref_no, '-', 1, 2) -
                        instr(gmr.gmr_ref_no, '-')) - 1)) gmr_no,
       (case
         when gmr.is_final_weight = 'N' then
          gmr.qty
         else
          gmr.final_weight
       end) gmr_qty,
       qum_gmr.qty_unit gmr_qty_unit,
       qum_gmr.decimals gmr_qty_decimals,
       aml.attribute_id element_id,
       aml.attribute_name element,
       (case
         when grd.is_afloat = 'Y' then
          'Shipped'
         else
          'Landed'
       end) shipping_status,
       axs.eff_date shipped_date,
       agmr.eff_date landed_date,
       pofh.qp_start_date,
       pofh.qp_end_date,
       to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy') qp,
       pcbph.price_description pricing_method,
       sum(nvl(spq.payable_qty, 0)) payable_qty,
       qum_payable_qty.qty_unit payable_qty_unit,
       qum_payable_qty.decimals payable_qty_decimals,
       null price_fixation_qty_allocated,
       round(sum(nvl(spq.payable_qty, 0)), 4) -
       round(nvl(pfd.priced_qty, 0), 4) unpriced_qty,
       nvl(pfd.priced_qty, 0) priced_qty,
       null di_executed_qty,
       null utility_ref_no,
       pdm_under.product_desc underlying_product,
       ucm.multiplication_factor,
       qum_under.qty_unit underlying_product_qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       ak_corporate akc,
       pci_physical_contract_item pci,
       (select pcdi.internal_contract_ref_no,
               sum(diqs.total_qty) contract_qty
          from pcdi_pc_delivery_item         pcdi,
               diqs_delivery_item_qty_status diqs
         where pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and diqs.is_active = 'Y'
         group by pcdi.internal_contract_ref_no) cont_qty,
       grd_goods_record_detail grd,
       gmr_goods_movement_record gmr,
       axs_action_summary axs,
       (select gmr.internal_gmr_ref_no,
               agmr.eff_date
          from gmr_goods_movement_record gmr,
               agmr_action_gmr           agmr
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agmr.gmr_latest_action_action_id in
               ('landingDetail', 'warehouseReceipt')
           and agmr.is_deleted = 'N') agmr,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcdb_pc_delivery_basis pcdb,
       spq_stock_payable_qty spq,
       pcbpd_pc_base_price_detail pcbpd,
       pcbph_pc_base_price_header pcbph,
       qat_quality_attributes qat,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       phd_profileheaderdetails phd,
       pdm_productmaster pdm,
       qum_quantity_unit_master qum_payable_qty,
       qum_quantity_unit_master qum_del,
       qum_quantity_unit_master qum_itm_qty,
       qum_quantity_unit_master qum_gmr,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       price_fixation pfd,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master   qum_under
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcm.corporate_id = akc.corporate_id
   and pcm.contract_type = 'CONCENTRATES'
   and pcdi.pcdi_id = pci.pcdi_id
   and pcm.internal_contract_ref_no = cont_qty.internal_contract_ref_no
   and pci.internal_contract_item_ref_no =
       grd.internal_contract_item_ref_no
   and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
   and grd.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pci.pcdb_id = pcdb.pcdb_id
   and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and spq.internal_grd_ref_no = grd.internal_grd_ref_no
   and spq.qty_type = 'Payable'
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and spq.element_id = pcbph.element_id
   and spq.is_stock_split = 'N'
   and pcpd.product_id = grd.product_id
   and qat.quality_id = pcpq.quality_template_id
   and pcpq.quality_template_id = grd.quality_id
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpd.input_output = 'Input'
   and phd.profileid = pcm.cp_id
   and pdm.product_id = pcpd.product_id
   and poch.element_id = pcbph.element_id
   and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
   and qum_payable_qty.qty_unit_id = spq.qty_unit_id
   and qum_itm_qty.qty_unit_id = pci.item_qty_unit_id
   and gmr.qty_unit_id = qum_gmr.qty_unit_id
   and diqs.item_qty_unit_id = qum_del.qty_unit_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pofh.pofh_id = pfd.pofh_id(+)
   and spq.qty_unit_id=ucm.from_qty_unit_id
   and pdm_under.base_quantity_unit=ucm.to_qty_unit_id
   and pdm_under.base_quantity_unit=qum_under.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.purchase_sales = 'P'
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and gmr.is_deleted = 'N'
   and grd.is_deleted = 'N'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and spq.is_active = 'Y'
   and diqs.is_active = 'Y'
   and pocd.qp_period_type = 'Event'
   having
 round(sum(nvl(spq.payable_qty, 0)), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) > 0 ---- it should not show the fully priced
 group by phd.companyname,
          phd.profileid,
          pcm.contract_type,
          akc.corporate_id,
          akc.corporate_name,
          pcm.contract_ref_no,
          cont_qty.contract_qty,
          pcpd.product_id,
          pdm.product_desc,
          pcdi.delivery_item_no,
          diqs.total_qty,
          qum_del.qty_unit,
          qum_del.decimals,
          qat.quality_id,
          pcdi.pricing_option_type,
          qat.quality_name,
          pci.item_qty,
          qum_itm_qty.qty_unit,
          qum_itm_qty.decimals,
          gmr.gmr_ref_no,
          gmr.is_final_weight,
          gmr.qty,
          gmr.final_weight,
          qum_gmr.qty_unit,
          qum_gmr.decimals,
          aml.attribute_id,
          aml.attribute_name,
          grd.is_afloat,
          gmr.eff_date,
          gmr.bl_date,
          pofh.qp_start_date,
          pofh.qp_end_date,
          pcbph.price_description,
          qum_payable_qty.qty_unit,
          qum_payable_qty.decimals,
          agmr.eff_date,
          axs.eff_date,
          pdm_under.product_desc,
          pfd.priced_qty,
          ucm.multiplication_factor,
          qum_under.qty_unit

union all

-- 2. SCT Traxys Non Event Based(DI) Query + Conc:
select phd.companyname cp_name,
       phd.profileid,
       'DI Level Pricing' section_name,
       pcm.contract_type,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no cont_ref_no,
       cont_qty.contract_qty,
       pcpd.product_id,
       pdm.product_desc product,
       pcdi.delivery_item_no del_itm_ref_no,
       diqs.total_qty del_itm_qty,
       qum_del.qty_unit del_itm_qty_unit,
       qum_del.decimals del_qty_decimals,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no cont_itm_ref_no,
       pcdi.pricing_option_type pricing_option,
       qat.quality_id,
       qat.quality_name quality,
       pci.item_qty cont_itm_qty,
       qum_itm_qty.qty_unit,
       qum_itm_qty.decimals cont_itm_qty_decimals,
       null gmr_ref_no,
       null gmr_no,
       null gmr_qty,
       null gmr_qty_unit,
       null gmr_qty_decimals,
       aml.attribute_id element_id,
       aml.attribute_name element,
       'NA' shipping_status,
       null shipped_date,
       null landed_date,
       pofh.qp_start_date,
       pofh.qp_end_date,
       to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy') qp,
       pcbph.price_description pricing_method,
       nvl(dipq.payable_qty, 0) payable_qty,
       qum_payable_qty.qty_unit payable_qty_unit,
       qum_payable_qty.decimals payable_qty_decimals,
       (case
         when pocd.is_any_day_pricing = 'Y' and
              pcdi.price_allocation_method = 'Price Allocation' then
          to_char(round(nvl(gpah.total_allocated_qty, 0), 4))
         else
          'NA'
       end) price_fixation_qty_allocated,
       round(nvl(dipq.payable_qty, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) unpriced_qty,
       nvl(pfd.priced_qty, 0) priced_qty,
       nvl(diqs.title_transferred_qty, 0) di_executed_qty,
       null utility_ref_no,
       pdm_under.product_desc underlying_product,
       ucm.multiplication_factor,
       qum_under.qty_unit underlying_product_qty_unit      
  from pcm_physical_contract_main pcm,
       ak_corporate akc,
       pcdi_pc_delivery_item pcdi,
       pci_physical_contract_item pci,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       diqs_delivery_item_qty_status diqs,
       dipq_delivery_item_payable_qty dipq,
       pofh_price_opt_fixation_header pofh,
       (select pcdi.internal_contract_ref_no,
               sum(diqs.total_qty) contract_qty
          from pcdi_pc_delivery_item         pcdi,
               diqs_delivery_item_qty_status diqs
         where pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and diqs.is_active = 'Y'
         group by pcdi.internal_contract_ref_no) cont_qty,
       qat_quality_attributes qat,
       pcdb_pc_delivery_basis pcdb,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       phd_profileheaderdetails phd,
       pdm_productmaster pdm,
       (select sum(gpah.total_allocated_qty) total_allocated_qty,
               gpah.element_id,
               gpah.pocd_id
          from gpah_gmr_price_alloc_header gpah
         where gpah.is_active = 'Y'
         group by gpah.pocd_id,
                  gpah.element_id) gpah,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       qum_quantity_unit_master qum_payable_qty,
       qum_quantity_unit_master qum_del,
       qum_quantity_unit_master qum_itm_qty,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       price_fixation pfd,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master   qum_under
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.contract_type = 'CONCENTRATES'
   and pcdi.pcdi_id = pci.pcdi_id
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcdb.pcdb_id = pci.pcdb_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcdi.pcdi_id = dipq.pcdi_id
   and dipq.is_active = 'Y'
   and dipq.element_id = poch.element_id
   and pocd.pocd_id = pofh.pocd_id
   and pcm.internal_contract_ref_no = cont_qty.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpd.input_output = 'Input'
   and qat.quality_id = pcpq.quality_template_id
   and phd.profileid = pcm.cp_id
   and pdm.product_id = pcpd.product_id
   and poch.element_id = pcbph.element_id
   and pocd.pocd_id = gpah.pocd_id(+)
   and pocd.element_id = gpah.element_id(+)
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and dipq.element_id = pcbph.element_id
   and qum_payable_qty.qty_unit_id = dipq.qty_unit_id --diqs.item_qty_unit_id
   and qum_itm_qty.qty_unit_id = pci.item_qty_unit_id
   and diqs.item_qty_unit_id = qum_del.qty_unit_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pofh.pofh_id = pfd.pofh_id(+)
   and dipq.qty_unit_id=ucm.from_qty_unit_id
   and pdm_under.base_quantity_unit=ucm.to_qty_unit_id
   and pdm_under.base_quantity_unit=qum_under.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.purchase_sales = 'P'
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and nvl(dipq.qty_type, 'Payable') = 'Payable'
   and diqs.is_active = 'Y'
   and pocd.qp_period_type <> 'Event'   
   and round(nvl(dipq.payable_qty, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) > 0
  and nvl(diqs.title_transferred_qty, 0)<>0  --- it should not show when Gmr is not created.   
union all
-- 3. PCT Traxys Event Based Query + Conc:
select phd.companyname cp_name,
       phd.profileid,
       'GMR Level Pricing' section_name,
       pcm.contract_type,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no cont_ref_no,
       cont_qty.contract_qty,
       pcpd.product_id,
       pdm.product_desc product,
       pcdi.delivery_item_no del_itm_ref_no,
       diqs.total_qty del_itm_qty,
       qum_del.qty_unit del_itm_qty_unit,
       qum_del.decimals del_qty_decimals,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no cont_itm_ref_no,
       pcdi.pricing_option_type pricing_option,
       qat.quality_id,
       qat.quality_name quality,
       pci.item_qty cont_itm_qty,
       qum_itm_qty.qty_unit,
       qum_itm_qty.decimals cont_itm_qty_decimals,
       gmr.gmr_ref_no,
       to_number(substr(gmr.gmr_ref_no,
                        instr(gmr.gmr_ref_no, '-') + 1,
                        (instr(gmr.gmr_ref_no, '-', 1, 2) -
                        instr(gmr.gmr_ref_no, '-')) - 1)) gmr_no,
       (case
         when gmr.is_final_weight = 'N' then
          gmr.qty
         else
          gmr.final_weight
       end) gmr_qty,
       qum_gmr.qty_unit gmr_qty_unit,
       qum_gmr.decimals gmr_qty_decimals,
       aml.attribute_id element_id,
       aml.attribute_name element,
       (case
         when dgrd.is_afloat = 'Y' then
          'Shipped'
         else
          'Landed'
       end) shipping_status,
       axs.eff_date shipped_date,
       agmr.eff_date landed_date,
       pofh.qp_start_date,
       pofh.qp_end_date,
       to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy') qp,
       pcbph.price_description pricing_method,
       sum(nvl(spq.payable_qty, 0)) payable_qty,
       qum_payable_qty.qty_unit payable_qty_unit,
       qum_payable_qty.decimals payable_qty_decimals,
       null price_fixation_qty_allocated,
       round(sum(nvl(spq.payable_qty, 0)), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) unpriced_qty,
       nvl(pfd.priced_qty, 0) priced_qty,
       null di_executed_qty,
       null utility_ref_no,
       pdm_under.product_desc underlying_product,
       ucm.multiplication_factor,
       qum_under.qty_unit underlying_product_qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       ak_corporate akc,
       pci_physical_contract_item pci,
       (select pcdi.internal_contract_ref_no,
               sum(diqs.total_qty) contract_qty
          from pcdi_pc_delivery_item         pcdi,
               diqs_delivery_item_qty_status diqs
         where pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and diqs.is_active = 'Y'
         group by pcdi.internal_contract_ref_no) cont_qty,
       dgrd_delivered_grd dgrd,
       gmr_goods_movement_record gmr,
       axs_action_summary axs,
       (select gmr.internal_gmr_ref_no,
               agmr.eff_date
          from gmr_goods_movement_record gmr,
               agmr_action_gmr           agmr
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agmr.gmr_latest_action_action_id in
               ('landingDetail', 'releaseOrder')
           and agmr.is_deleted = 'N') agmr,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcdb_pc_delivery_basis pcdb,
       spq_stock_payable_qty spq,
       pcbpd_pc_base_price_detail pcbpd,
       pcbph_pc_base_price_header pcbph,
       qat_quality_attributes qat,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       phd_profileheaderdetails phd,
       pdm_productmaster pdm,
       qum_quantity_unit_master qum_payable_qty,
       qum_quantity_unit_master qum_del,
       qum_quantity_unit_master qum_itm_qty,
       qum_quantity_unit_master qum_gmr,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       price_fixation pfd,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master   qum_under
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcm.corporate_id = akc.corporate_id
   and pcm.contract_type = 'CONCENTRATES'
   and pcdi.pcdi_id = pci.pcdi_id
   and pcm.internal_contract_ref_no = cont_qty.internal_contract_ref_no
   and pci.internal_contract_item_ref_no =
       dgrd.internal_contract_item_ref_no
   and dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
   and dgrd.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pci.pcdb_id = pcdb.pcdb_id
   and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and spq.internal_grd_ref_no = dgrd.internal_grd_ref_no
   and spq.qty_type = 'Payable'
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and spq.element_id = pcbph.element_id
   and spq.is_stock_split = 'N'
   and pcpd.product_id = dgrd.product_id
   and qat.quality_id = pcpq.quality_template_id
   and pcpq.quality_template_id = dgrd.quality_id
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpd.input_output = 'Input'
   and phd.profileid = pcm.cp_id
   and pdm.product_id = pcpd.product_id
   and poch.element_id = pcbph.element_id
   and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
   and qum_payable_qty.qty_unit_id = spq.qty_unit_id
   and qum_itm_qty.qty_unit_id = pci.item_qty_unit_id
   and gmr.qty_unit_id = qum_gmr.qty_unit_id
   and diqs.item_qty_unit_id = qum_del.qty_unit_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pofh.pofh_id = pfd.pofh_id(+)
   and spq.qty_unit_id=ucm.from_qty_unit_id
   and pdm_under.base_quantity_unit=ucm.to_qty_unit_id
   and pdm_under.base_quantity_unit=qum_under.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.purchase_sales = 'S'
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and gmr.is_deleted = 'N'
   and dgrd.status = 'Active'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and spq.is_active = 'Y'
   and diqs.is_active = 'Y'
   and pocd.qp_period_type = 'Event'
   having
 round(sum(nvl(spq.payable_qty, 0)), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) > 0
 group by phd.companyname,
          phd.profileid,
          pcm.contract_type,
          akc.corporate_id,
          akc.corporate_name,
          pcm.contract_ref_no,
          cont_qty.contract_qty,
          pcpd.product_id,
          pdm.product_desc,
          pcdi.delivery_item_no,
          diqs.total_qty,
          qum_del.qty_unit,
          qum_del.decimals,
          qat.quality_id,
          pcdi.pricing_option_type,
          qat.quality_name,
          pci.item_qty,
          qum_itm_qty.qty_unit,
          qum_itm_qty.decimals,
          gmr.gmr_ref_no,
          gmr.is_final_weight,
          gmr.qty,
          gmr.final_weight,
          qum_gmr.qty_unit,
          qum_gmr.decimals,
          aml.attribute_id,
          aml.attribute_name,
          dgrd.is_afloat,
          gmr.eff_date,
          gmr.bl_date,
          pofh.qp_start_date,
          pofh.qp_end_date,
          pcbph.price_description,
          qum_payable_qty.qty_unit,
          qum_payable_qty.decimals,
          agmr.eff_date,
          axs.eff_date,
          pdm_under.product_desc,
          pfd.priced_qty,
          ucm.multiplication_factor,
          qum_under.qty_unit
union all
-- 4. PCT Traxys Non Event Based(DI) Query + Conc:
select phd.companyname cp_name,
       phd.profileid,
       'DI Level Pricing' section_name,
       pcm.contract_type,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no cont_ref_no,
       cont_qty.contract_qty,
       pcpd.product_id,
       pdm.product_desc product,
       pcdi.delivery_item_no del_itm_ref_no,
       diqs.total_qty del_itm_qty,
       qum_del.qty_unit del_itm_qty_unit,
       qum_del.decimals del_qty_decimals,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no cont_itm_ref_no,
       pcdi.pricing_option_type pricing_option,
       qat.quality_id,
       qat.quality_name quality,
       pci.item_qty cont_itm_qty,
       qum_itm_qty.qty_unit,
       qum_itm_qty.decimals cont_itm_qty_decimals,
       null gmr_ref_no,
       null gmr_no,
       null gmr_qty,
       null gmr_qty_unit,
       null gmr_qty_decimals,
       aml.attribute_id element_id,
       aml.attribute_name element,
       'NA' shipping_status,
       null shipped_date,
       null landed_date,
       pofh.qp_start_date,
       pofh.qp_end_date,
       to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy') qp,
       pcbph.price_description pricing_method,
       nvl(dipq.payable_qty, 0) payable_qty,
       qum_payable_qty.qty_unit payable_qty_unit,
       qum_payable_qty.decimals payable_qty_decimals,
       (case
         when pocd.is_any_day_pricing = 'Y' and
              pcdi.price_allocation_method = 'Price Allocation' then
          to_char(round(nvl(gpah.total_allocated_qty, 0), 4))
         else
          'NA'
       end) price_fixation_qty_allocated,
       round(nvl(dipq.payable_qty, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) unpriced_qty,
       nvl(pfd.priced_qty, 0) priced_qty,
       nvl(diqs.title_transferred_qty, 0) di_executed_qty,
       null utility_ref_no,
       pdm_under.product_desc underlying_product,
       ucm.multiplication_factor,
       qum_under.qty_unit underlying_product_qty_unit
  from pcm_physical_contract_main pcm,
       ak_corporate akc,
       pcdi_pc_delivery_item pcdi,
       pci_physical_contract_item pci,
       (select pcdi.internal_contract_ref_no,
               sum(diqs.total_qty) contract_qty
          from pcdi_pc_delivery_item         pcdi,
               diqs_delivery_item_qty_status diqs
         where pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and diqs.is_active = 'Y'
         group by pcdi.internal_contract_ref_no) cont_qty,
       qat_quality_attributes qat,
       pcdb_pc_delivery_basis pcdb,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       phd_profileheaderdetails phd,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       dipq_delivery_item_payable_qty dipq,
       diqs_delivery_item_qty_status diqs,
       pofh_price_opt_fixation_header pofh,
       (select sum(gpah.total_allocated_qty) total_allocated_qty,
               gpah.element_id,
               gpah.pocd_id
          from gpah_gmr_price_alloc_header gpah
         where gpah.is_active = 'Y'
         group by gpah.pocd_id,
                  gpah.element_id) gpah,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       qum_quantity_unit_master qum_payable_qty,
       qum_quantity_unit_master qum_del,
       qum_quantity_unit_master qum_itm_qty,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       price_fixation pfd,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master   qum_under
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.contract_type = 'CONCENTRATES'
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcdi.pcdi_id = pci.pcdi_id
   and pcm.internal_contract_ref_no = cont_qty.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcdb.pcdb_id = pci.pcdb_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and qat.quality_id = pcpq.quality_template_id
   and pcpd.input_output = 'Input'
   and phd.profileid = pcm.cp_id
   and pdm.product_id = pcpd.product_id
   and poch.element_id = pcbph.element_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and dipq.element_id = poch.element_id
   and dipq.is_active = 'Y'
   and nvl(dipq.qty_type, 'Payable') = 'Payable'
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pocd_id = gpah.pocd_id(+)
   and pocd.element_id = gpah.element_id(+)
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and qum_payable_qty.qty_unit_id = dipq.qty_unit_id --diqs.item_qty_unit_id
   and qum_itm_qty.qty_unit_id = pci.item_qty_unit_id
   and diqs.item_qty_unit_id = qum_del.qty_unit_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pofh.pofh_id = pfd.pofh_id(+)
   and dipq.qty_unit_id=ucm.from_qty_unit_id
   and pdm_under.base_quantity_unit=ucm.to_qty_unit_id
   and pdm_under.base_quantity_unit=qum_under.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.purchase_sales = 'S'
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and diqs.is_active = 'Y'
   and pocd.qp_period_type <> 'Event'
   and round(nvl(dipq.payable_qty, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) > 0
   and nvl(diqs.title_transferred_qty, 0)<>0    --- it should not show when Gmr is not created.    
union all
-- 5. PC Contract With Non Event Based(DI) Query:-
select phd.companyname cp_name,
       phd.profileid,
       'DI Level Pricing' section_name,
       pcm.contract_type,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no cont_ref_no,
       cont_qty.contract_qty,
       pcpd.product_id,
       pdm.product_desc product,
       pcdi.delivery_item_no del_itm_ref_no,
       diqs.total_qty del_itm_qty,
       qum_del.qty_unit del_itm_qty_unit,
       qum_del.decimals del_qty_decimals,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no cont_itm_ref_no,
       pcdi.pricing_option_type pricing_option,
       qat.quality_id,
       qat.quality_name quality,
       pci.item_qty cont_itm_qty,
       qum_itm_qty.qty_unit,
       qum_itm_qty.decimals cont_itm_qty_decimals,
       null gmr_ref_no,
       null gmr_no,
       null gmr_qty,
       null gmr_qty_unit,
       null gmr_qty_decimals,
       null element_id,
       null element,
       'NA' shipping_status,
       null shipped_date,
       null landed_date,
       pofh.qp_start_date,
       pofh.qp_end_date,
       to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy') qp,
       pcbph.price_description pricing_method,
       null payable_qty,
       null payable_qty_unit,
       null payable_qty_decimals,
       (case
         when pocd.is_any_day_pricing = 'Y' and
              pcdi.price_allocation_method = 'Price Allocation' then
          to_char(round(nvl(gpah.total_allocated_qty, 0), 4))
         else
          'NA'
       end) price_fixation_qty_allocated,
       round(nvl(pofh.qty_to_be_fixed, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) unpriced_qty,
       nvl(pfd.priced_qty, 0) priced_qty,
       nvl(diqs.title_transferred_qty, 0) di_executed_qty,
       null utility_ref_no,
       pdm.product_desc underlying_product,
       ucm.multiplication_factor,
       qum_under.qty_unit underlying_product_qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       ak_corporate akc,
       diqs_delivery_item_qty_status diqs,
       pci_physical_contract_item pci,
       (select pcdi.internal_contract_ref_no,
               sum(diqs.total_qty) contract_qty
          from pcdi_pc_delivery_item         pcdi,
               diqs_delivery_item_qty_status diqs
         where pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and diqs.is_active = 'Y'
         group by pcdi.internal_contract_ref_no) cont_qty,
       pcpq_pc_product_quality pcpq,
       pcpd_pc_product_definition pcpd,
       qat_quality_attributes qat,
       pcdb_pc_delivery_basis pcdb,
       phd_profileheaderdetails phd,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       (select sum(gpah.total_allocated_qty) total_allocated_qty,
               gpah.element_id,
               gpah.pocd_id
          from gpah_gmr_price_alloc_header gpah
         where gpah.is_active = 'Y'
         group by gpah.pocd_id,
                  gpah.element_id) gpah,
       pcbpd_pc_base_price_detail pcbpd,
       pcbph_pc_base_price_header pcbph,
       qum_quantity_unit_master qum_itm_qty,
       qum_quantity_unit_master qum_del,
       price_fixation pfd,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master   qum_under
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.contract_type = 'BASEMETAL'
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcdi.pcdi_id = pci.pcdi_id
   and pcm.internal_contract_ref_no = cont_qty.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpd.input_output = 'Input'
   and qat.quality_id = pcpq.quality_template_id
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcdb.pcdb_id = pci.pcdb_id
   and phd.profileid = pcm.cp_id
   and pdm.product_id = pcpd.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pocd_id = gpah.pocd_id(+)
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and qum_itm_qty.qty_unit_id = pci.item_qty_unit_id
   and diqs.item_qty_unit_id = qum_del.qty_unit_id
   and pofh.pofh_id = pfd.pofh_id(+)
   and pci.item_qty_unit_id=ucm.from_qty_unit_id
   and pdm.base_quantity_unit=ucm.to_qty_unit_id
   and pdm.base_quantity_unit=qum_under.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.purchase_sales = 'P'
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and diqs.is_active = 'Y'
   and pocd.qp_period_type <> 'Event' 
   and round(nvl(pofh.qty_to_be_fixed, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) > 0
    and nvl(diqs.title_transferred_qty, 0)<>0 --- it should not show when Gmr is not created.       
union all
-- 6. SC Contract With Non Event Based(DI) Query:-
select phd.companyname cp_name,
       phd.profileid,
       'DI Level Pricing' section_name,
       pcm.contract_type,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no cont_ref_no,
       cont_qty.contract_qty,
       pcpd.product_id,
       pdm.product_desc product,
       pcdi.delivery_item_no del_itm_ref_no,
       diqs.total_qty del_itm_qty,
       qum_del.qty_unit del_itm_qty_unit,
       qum_del.decimals del_qty_decimals,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no cont_itm_ref_no,
       pcdi.pricing_option_type pricing_option,
       qat.quality_id,
       qat.quality_name quality,
       pci.item_qty cont_itm_qty,
       qum_itm_qty.qty_unit,
       qum_itm_qty.decimals cont_itm_qty_decimals,
       null gmr_ref_no,
       null gmr_no,
       null gmr_qty,
       null gmr_qty_unit,
       null gmr_qty_decimals,
       null element_id,
       null element,
       'NA' shipping_status,
       null shipped_date,
       null landed_date,
       pofh.qp_start_date,
       pofh.qp_end_date,
       to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy') qp,
       pcbph.price_description pricing_method,
       null payable_qty,
       null payable_qty_unit,
       null payable_qty_decimals,
       (case
         when pocd.is_any_day_pricing = 'Y' and
              pcdi.price_allocation_method = 'Price Allocation' then
          to_char(round(nvl(gpah.total_allocated_qty, 0), 4))
         else
          'NA'
       end) price_fixation_qty_allocated,
       round(nvl(pofh.qty_to_be_fixed, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) unpriced_qty,
       nvl(pfd.priced_qty, 0) priced_qty,
       nvl(diqs.title_transferred_qty, 0) di_executed_qty,
       null utility_ref_no,
       pdm.product_desc underlying_product,
       ucm.multiplication_factor,
       qum_under.qty_unit underlying_product_qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       ak_corporate akc,
       diqs_delivery_item_qty_status diqs,
       pci_physical_contract_item pci,
       (select pcdi.internal_contract_ref_no,
               sum(diqs.total_qty) contract_qty
          from pcdi_pc_delivery_item         pcdi,
               diqs_delivery_item_qty_status diqs
         where pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and diqs.is_active = 'Y'
         group by pcdi.internal_contract_ref_no) cont_qty,
       pcpq_pc_product_quality pcpq,
       pcpd_pc_product_definition pcpd,
       qat_quality_attributes qat,
       pcdb_pc_delivery_basis pcdb,
       phd_profileheaderdetails phd,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       (select sum(gpah.total_allocated_qty) total_allocated_qty,
               gpah.element_id,
               gpah.pocd_id
          from gpah_gmr_price_alloc_header gpah
         where gpah.is_active = 'Y'
         group by gpah.pocd_id,
                  gpah.element_id) gpah,
       pcbpd_pc_base_price_detail pcbpd,
       pcbph_pc_base_price_header pcbph,
       qum_quantity_unit_master qum_itm_qty,
       qum_quantity_unit_master qum_del,
       price_fixation pfd,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master   qum_under
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.contract_type = 'BASEMETAL'
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcdi.pcdi_id = pci.pcdi_id
   and pcm.internal_contract_ref_no = cont_qty.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpd.input_output = 'Input'
   and qat.quality_id = pcpq.quality_template_id
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcdb.pcdb_id = pci.pcdb_id
   and phd.profileid = pcm.cp_id
   and pdm.product_id = pcpd.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pocd_id = gpah.pocd_id(+)
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and qum_itm_qty.qty_unit_id = pci.item_qty_unit_id
   and diqs.item_qty_unit_id = qum_del.qty_unit_id
   and pofh.pofh_id = pfd.pofh_id(+)
   and pci.item_qty_unit_id=ucm.from_qty_unit_id
   and pdm.base_quantity_unit=ucm.to_qty_unit_id
   and pdm.base_quantity_unit=qum_under.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.purchase_sales = 'S'
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and diqs.is_active = 'Y'
   and pocd.qp_period_type <> 'Event'   
   and round(nvl(pofh.qty_to_be_fixed, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) > 0
   and nvl(diqs.title_transferred_qty, 0)<>0   --- it should not show when Gmr is not created.     
union all
-- 7. PC Event Based Query + Base Metal:
select phd.companyname cp_name,
       phd.profileid,
       'GMR Level Pricing' section_name,
       pcm.contract_type,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no cont_ref_no,
       cont_qty.contract_qty,
       pcpd.product_id,
       pdm.product_desc product,
       pcdi.delivery_item_no del_itm_ref_no,
       diqs.total_qty del_itm_qty,
       qum_del.qty_unit del_itm_qty_unit,
       qum_del.decimals del_qty_decimals,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no cont_itm_ref_no,
       pcdi.pricing_option_type pricing_option,
       qat.quality_id,
       qat.quality_name quality,
       pci.item_qty cont_itm_qty,
       qum_itm_qty.qty_unit,
       qum_itm_qty.decimals cont_itm_qty_decimals,
       gmr.gmr_ref_no,
       to_number(substr(gmr.gmr_ref_no,
                        instr(gmr.gmr_ref_no, '-') + 1,
                        (instr(gmr.gmr_ref_no, '-', 1, 2) -
                        instr(gmr.gmr_ref_no, '-')) - 1)) gmr_no,
       (case
         when gmr.is_final_weight = 'N' then
          gmr.qty
         else
          gmr.final_weight
       end) gmr_qty,
       qum_gmr.qty_unit gmr_qty_unit,
       qum_gmr.decimals gmr_qty_decimals,
       null element_id,
       null element,
       (case
         when grd.is_afloat = 'Y' then
          'Shipped'
         else
          'Landed'
       end) shipping_status,
       axs.eff_date shipped_date,
       agmr.eff_date landed_date,
       pofh.qp_start_date,
       pofh.qp_end_date,
       to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy') qp,
       pcbph.price_description pricing_method,
       null payable_qty,
       null payable_qty_unit,
       null payable_qty_decimals,
       null price_fixation_qty_allocated,
       round(nvl(pofh.qty_to_be_fixed, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) unpriced_qty,
       nvl(pfd.priced_qty, 0) priced_qty,
       null di_executed_qty,
       null utility_ref_no,
       pdm.product_desc underlying_product,
       ucm.multiplication_factor,
       qum_under.qty_unit underlying_product_qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       ak_corporate akc,
       pci_physical_contract_item pci,
       (select pcdi.internal_contract_ref_no,
               sum(diqs.total_qty) contract_qty
          from pcdi_pc_delivery_item         pcdi,
               diqs_delivery_item_qty_status diqs
         where pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and diqs.is_active = 'Y'
         group by pcdi.internal_contract_ref_no) cont_qty,
       grd_goods_record_detail grd,
       gmr_goods_movement_record gmr,
       axs_action_summary axs,
       (select gmr.internal_gmr_ref_no,
               agmr.eff_date
          from gmr_goods_movement_record gmr,
               agmr_action_gmr           agmr
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agmr.gmr_latest_action_action_id in
               ('landingDetail', 'warehouseReceipt')
           and agmr.is_deleted = 'N') agmr,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcdb_pc_delivery_basis pcdb,
       pcbpd_pc_base_price_detail pcbpd,
       pcbph_pc_base_price_header pcbph,
       qat_quality_attributes qat,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       phd_profileheaderdetails phd,
       pdm_productmaster pdm,
       qum_quantity_unit_master qum_del,
       qum_quantity_unit_master qum_itm_qty,
       qum_quantity_unit_master qum_gmr,
       price_fixation pfd,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master   qum_under
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcm.corporate_id = akc.corporate_id
   and pcm.contract_type = 'BASEMETAL'
   and pcdi.pcdi_id = pci.pcdi_id
   and pcm.internal_contract_ref_no = cont_qty.internal_contract_ref_no
   and pci.internal_contract_item_ref_no =
       grd.internal_contract_item_ref_no
   and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
   and grd.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pci.pcdb_id = pcdb.pcdb_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and pcpd.product_id = grd.product_id
   and qat.quality_id = pcpq.quality_template_id
   and pcpq.quality_template_id = grd.quality_id
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpd.input_output = 'Input'
   and phd.profileid = pcm.cp_id
   and pdm.product_id = pcpd.product_id
   and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
   and qum_itm_qty.qty_unit_id = pci.item_qty_unit_id
   and diqs.item_qty_unit_id = qum_del.qty_unit_id
   and gmr.qty_unit_id = qum_gmr.qty_unit_id
   and pofh.pofh_id = pfd.pofh_id(+)
   and pci.item_qty_unit_id=ucm.from_qty_unit_id
   and pdm.base_quantity_unit=ucm.to_qty_unit_id
   and pdm.base_quantity_unit=qum_under.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.purchase_sales = 'P'
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and gmr.is_deleted = 'N'
   and grd.is_deleted = 'N'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and diqs.is_active = 'Y'
   and pocd.qp_period_type = 'Event'
   and round(nvl(pofh.qty_to_be_fixed, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) > 0
union all
-- 8. SC Event Based Query + Base Metal:
select phd.companyname cp_name,
       phd.profileid,
       'GMR Level Pricing' section_name,
       pcm.contract_type,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no cont_ref_no,
       cont_qty.contract_qty,
       pcpd.product_id,
       pdm.product_desc product,
       pcdi.delivery_item_no del_itm_ref_no,
       diqs.total_qty del_itm_qty,
       qum_del.qty_unit del_itm_qty_unit,
       qum_del.decimals del_qty_decimals,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no cont_itm_ref_no,
       pcdi.pricing_option_type pricing_option,
       qat.quality_id,
       qat.quality_name quality,
       pci.item_qty cont_itm_qty,
       qum_itm_qty.qty_unit,
       qum_itm_qty.decimals cont_itm_qty_decimals,
       gmr.gmr_ref_no,
       to_number(substr(gmr.gmr_ref_no,
                        instr(gmr.gmr_ref_no, '-') + 1,
                        (instr(gmr.gmr_ref_no, '-', 1, 2) -
                        instr(gmr.gmr_ref_no, '-')) - 1)) gmr_no,
       (case
         when gmr.is_final_weight = 'N' then
          gmr.qty
         else
          gmr.final_weight
       end) gmr_qty,
       qum_gmr.qty_unit gmr_qty_unit,
       qum_gmr.decimals gmr_qty_decimals,
       null element_id,
       null element,
       (case
         when dgrd.is_afloat = 'Y' then
          'Shipped'
         else
          'Landed'
       end) shipping_status,
       axs.eff_date shipped_date,
       agmr.eff_date landed_date,
       pofh.qp_start_date,
       pofh.qp_end_date,
       to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy') qp,
       pcbph.price_description pricing_method,
       null payable_qty,
       null payable_qty_unit,
       null payable_qty_decimals,
       null price_fixation_qty_allocated,
       round(nvl(pofh.qty_to_be_fixed, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) unpriced_qty,
       nvl(pfd.priced_qty, 0) priced_qty,
       null di_executed_qty,
       null utility_ref_no,
       pdm.product_desc underlying_product,
       ucm.multiplication_factor,
       qum_under.qty_unit underlying_product_qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       ak_corporate akc,
       pci_physical_contract_item pci,
       (select pcdi.internal_contract_ref_no,
               sum(diqs.total_qty) contract_qty
          from pcdi_pc_delivery_item         pcdi,
               diqs_delivery_item_qty_status diqs
         where pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and diqs.is_active = 'Y'
         group by pcdi.internal_contract_ref_no) cont_qty,
       dgrd_delivered_grd dgrd,
       gmr_goods_movement_record gmr,
       axs_action_summary axs,
       (select gmr.internal_gmr_ref_no,
               agmr.eff_date
          from gmr_goods_movement_record gmr,
               agmr_action_gmr           agmr
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agmr.gmr_latest_action_action_id in
               ('landingDetail', 'releaseOrder')
           and agmr.is_deleted = 'N') agmr,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcdb_pc_delivery_basis pcdb,
       pcbpd_pc_base_price_detail pcbpd,
       pcbph_pc_base_price_header pcbph,
       qat_quality_attributes qat,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       phd_profileheaderdetails phd,
       pdm_productmaster pdm,
       qum_quantity_unit_master qum_del,
       qum_quantity_unit_master qum_itm_qty,
       qum_quantity_unit_master qum_gmr,
       price_fixation pfd,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master   qum_under
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcm.corporate_id = akc.corporate_id
   and pcm.contract_type = 'BASEMETAL'
   and pcdi.pcdi_id = pci.pcdi_id
   and pcm.internal_contract_ref_no = cont_qty.internal_contract_ref_no
   and pci.internal_contract_item_ref_no =
       dgrd.internal_contract_item_ref_no
   and dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
   and dgrd.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pci.pcdb_id = pcdb.pcdb_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and pcpd.product_id = dgrd.product_id
   and qat.quality_id = pcpq.quality_template_id
   and pcpq.quality_template_id = dgrd.quality_id
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpd.input_output = 'Input'
   and phd.profileid = pcm.cp_id
   and pdm.product_id = pcpd.product_id
   and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
   and qum_itm_qty.qty_unit_id = pci.item_qty_unit_id
   and diqs.item_qty_unit_id = qum_del.qty_unit_id
   and gmr.qty_unit_id = qum_gmr.qty_unit_id
   and pofh.pofh_id = pfd.pofh_id(+)
   and pci.item_qty_unit_id=ucm.from_qty_unit_id
   and pdm.base_quantity_unit=ucm.to_qty_unit_id
   and pdm.base_quantity_unit=qum_under.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.purchase_sales = 'S'
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and gmr.is_deleted = 'N'
   and dgrd.status = 'Active'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and diqs.is_active = 'Y'
   and pocd.qp_period_type = 'Event' 
   and round(nvl(pofh.qty_to_be_fixed, 0), 4) -
       round((nvl(pfd.priced_qty, 0)), 4) > 0
union all
-- 9. Free Metal:
select phd.companyname cp_name,
       phd.profileid,
       'GMR Level Pricing' section_name,
       'Free Metal' contract_type,
       fmuh.corporate_id,
       fmuh.corporate_id corporate_name,
       null cont_ref_no,
       null contract_qty,
       pdm.product_id,
       pdm.product_desc product,
       null del_itm_ref_no,
       null del_itm_qty,
       null del_itm_qty_unit,
       null del_qty_decimals,
       null cont_itm_ref_no,
       null pricing_option,
       grd.quality_id,
       qat.quality_name quality,
       null cont_itm_qty,
       null qty_unit,
       null cont_itm_qty_decimals,
       gmr.gmr_ref_no,
       to_number(substr(gmr.gmr_ref_no,
                        instr(gmr.gmr_ref_no, '-') + 1,
                        (instr(gmr.gmr_ref_no, '-', 1, 2) -
                        instr(gmr.gmr_ref_no, '-')) - 1)) gmr_no,
       (case
         when gmr.is_final_weight = 'N' then
          gmr.shipped_qty
         else
          gmr.final_weight
       end) gmr_qty,
       qum_gmr.qty_unit gmr_qty_unit,
       qum_gmr.decimals gmr_qty_decimals,
       null element_id,
       null element,
       'Landed' shipping_status,
       null shipped_date,
       null landed_date,
       fmuh.qp_start_date,
       fmuh.qp_end_date,
       to_char(fmuh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(fmuh.qp_end_date, 'dd-Mon-yyyy') qp,
       fmed.formula_description pricing_method,
       null payable_qty,
       null payable_qty_unit,
       null payable_qty_decimals,
       null price_fixation_qty_allocated,
       round(nvl(fmpfh.qty_to_be_fixed, 0), 4) -
       round(nvl(fmpfh.priced_qty, 0), 4) unpriced_qty,
       nvl(fmpfh.priced_qty, 0) priced_qty,
       null di_executed_qty,
       fmuh.utility_ref_no,
       pdm.product_desc underlying_product,
       ucm.multiplication_factor,
       qum_under.qty_unit underlying_product_qty_unit
  from fmuh_free_metal_utility_header fmuh,
       fmed_free_metal_elemt_details  fmed,
       fmeifd_index_formula_details   fmeifd,
       fmpfh_price_fixation_header    fmpfh,
       gmr_goods_movement_record      gmr,
       grd_goods_record_detail        grd,
       qat_quality_attributes         qat,
       qum_quantity_unit_master       qum_gmr,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm,
       phd_profileheaderdetails       phd,
       ucm_unit_conversion_master     ucm,
       qum_quantity_unit_master       qum_under
 where fmuh.fmuh_id = fmed.fmuh_id
   and fmed.fmed_id = fmeifd.fmed_id
   and fmed.fmed_id = fmpfh.fmed_id
   and fmed.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and grd.quality_id = qat.quality_id
   and gmr.qty_unit_id = qum_gmr.qty_unit_id
   and fmed.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm.product_id
   and fmuh.smelter_id = phd.profileid 
   and gmr.qty_unit_id =ucm.from_qty_unit_id
   and pdm.base_quantity_unit=ucm.to_qty_unit_id
   and pdm.base_quantity_unit=qum_under.qty_unit_id
   and round(nvl(fmpfh.qty_to_be_fixed, 0), 4) -
       round(nvl(fmpfh.priced_qty, 0), 4) > 0
union all
-- 10 Pricing Method: Price Allocation, Any Day QP Concentrate
select phd.companyname cp_name,
       phd.profileid,
       'Pricing Method: Price Allocation, Any Day QP' section_name,
       pcm.contract_type,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no cont_ref_no,
       cont_qty.contract_qty,
       pcpd.product_id,
       pdm.product_desc product,
       pcdi.delivery_item_no del_itm_ref_no,
       diqs.total_qty del_itm_qty,
       qum_del.qty_unit del_itm_qty_unit,
       qum_del.decimals del_qty_decimals,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no cont_itm_ref_no,
       pcdi.pricing_option_type pricing_option,
       qat.quality_id,
       qat.quality_name quality,
       pci.item_qty cont_itm_qty,
       qum_itm_qty.qty_unit,
       qum_itm_qty.decimals cont_itm_qty_decimals,
       gmr.gmr_ref_no,
       to_number(substr(gmr.gmr_ref_no,
                        instr(gmr.gmr_ref_no, '-') + 1,
                        (instr(gmr.gmr_ref_no, '-', 1, 2) -
                        instr(gmr.gmr_ref_no, '-')) - 1)) gmr_no,
       (case
         when gmr.is_final_weight = 'N' then
          gmr.shipped_qty
         else
          gmr.final_weight
       end) gmr_qty,
       qum_gmr.qty_unit gmr_qty_unit,
       qum_gmr.decimals gmr_qty_decimals,
       aml.attribute_id element_id,
       aml.attribute_name element,
       (case
         when grd.is_afloat = 'Y' then
          'Shipped'
         else
          'Landed'
       end) shipping_status,
       axs.eff_date shipped_date,
       agmr.eff_date landed_date,
       pofh.qp_start_date,
       pofh.qp_end_date,
       to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy') qp,
       pcbph.price_description pricing_method,
       sum(nvl(spq.payable_qty, 0)) payable_qty,
       qum_payable_qty.qty_unit payable_qty_unit,
       qum_payable_qty.decimals payable_qty_decimals,
       to_char(round(nvl(gpah.total_allocated_qty, 0), 4)) price_fixation_qty_allocated,
       sum(nvl(spq.payable_qty, 0) - gpah.priced_qty) unpriced_qty,
       sum(gpah.priced_qty) priced_qty,
       nvl(diqs.title_transferred_qty, 0) di_executed_qty,
       null utility_ref_no,
       pdm_under.product_desc underlying_product,
       ucm.multiplication_factor,
       qum_under.qty_unit underlying_product_qty_unit
  from pcm_physical_contract_main pcm,
       ak_corporate akc,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       pci_physical_contract_item pci,
       (select pcdi.internal_contract_ref_no,
               sum(diqs.total_qty) contract_qty
          from pcdi_pc_delivery_item         pcdi,
               diqs_delivery_item_qty_status diqs
         where pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and diqs.is_active = 'Y'
         group by pcdi.internal_contract_ref_no) cont_qty,
       qat_quality_attributes qat,
       axs_action_summary axs,
       gmr_goods_movement_record gmr,
       (select gmr.internal_gmr_ref_no,
               agmr.eff_date
          from gmr_goods_movement_record gmr,
               agmr_action_gmr           agmr
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agmr.gmr_latest_action_action_id in
               ('landingDetail', 'releaseOrder')
           and agmr.is_deleted = 'N') agmr,
       gsm_gmr_stauts_master gsm,
       grd_goods_record_detail grd,
       pcdb_pc_delivery_basis pcdb,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       phd_profileheaderdetails phd,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       (select gmr.internal_gmr_ref_no,
               sum(case
                     when pfd.user_price is null then
                      0
                     else
                      gpad.allocated_qty
                   end) priced_qty,
               gpah.element_id,
               gpah.total_allocated_qty
          from gmr_goods_movement_record   gmr,
               gpah_gmr_price_alloc_header gpah,
               gpad_gmr_price_alloc_dtls   gpad,
               pfd_price_fixation_details  pfd
         where gmr.internal_gmr_ref_no = gpah.internal_gmr_ref_no
           and gpah.gpah_id = gpad.gpah_id
           and gpad.pfd_id = pfd.pfd_id
           and gmr.is_deleted = 'N'
           and gpah.is_active = 'Y'
           and gpad.is_active = 'Y'
           and pfd.is_active = 'Y'
           and pfd.is_exposure='Y'
         group by gmr.internal_gmr_ref_no,
                  gpah.element_id,
                  gpah.total_allocated_qty) gpah,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       spq_stock_payable_qty spq,
       qum_quantity_unit_master qum_payable_qty,
       qum_quantity_unit_master qum_del,
       qum_quantity_unit_master qum_itm_qty,
       qum_quantity_unit_master qum_gmr,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master   qum_under
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.contract_type = 'CONCENTRATES'
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcdi.pcdi_id = pci.pcdi_id
   and qat.quality_id = pcpq.quality_template_id
   and pcm.internal_contract_ref_no = cont_qty.internal_contract_ref_no
   and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
   and gsm.status_id = gmr.status_id
   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and pci.internal_contract_item_ref_no =
       grd.internal_contract_item_ref_no
   and pcpd.product_id = grd.product_id
   and pcpq.quality_template_id = grd.quality_id
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcdb.pcdb_id = pci.pcdb_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpd.input_output = 'Input'
   and phd.profileid = pcm.cp_id
   and pdm.product_id = pcpd.product_id
   and poch.pcdi_id = grd.pcdi_id
   and poch.element_id = pcbph.element_id
   and pocd.poch_id = poch.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and gpah.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gpah.element_id = pcbph.element_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and spq.internal_grd_ref_no = grd.internal_grd_ref_no
   and spq.element_id = pcbph.element_id
   and spq.is_stock_split = 'N'
   and qum_payable_qty.qty_unit_id = spq.qty_unit_id
   and qum_itm_qty.qty_unit_id = pci.item_qty_unit_id
   and gmr.qty_unit_id = qum_gmr.qty_unit_id
   and diqs.item_qty_unit_id = qum_del.qty_unit_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and spq.qty_unit_id=ucm.from_qty_unit_id
   and pdm_under.base_quantity_unit=ucm.to_qty_unit_id
   and pdm_under.base_quantity_unit=qum_under.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.purchase_sales = 'P'
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and gmr.is_deleted = 'N'
   and grd.is_deleted = 'N'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and spq.is_active = 'Y'
   and spq.qty_type = 'Payable'
   and spq.is_stock_split = 'N'
   and diqs.is_active = 'Y'
   and gsm.status in
       ('Landed', 'On Ship', 'On Truck', 'On Rail', 'On Air', 'In Warehouse')
   and pocd.qp_period_type <> 'Event' 
   and pocd.is_any_day_pricing = 'Y'
   and pcdi.price_allocation_method = 'Price Allocation' having
 sum(nvl(spq.payable_qty, 0) - gpah.priced_qty) > 0
 group by phd.companyname,
          phd.profileid,
          pcm.contract_type,
          akc.corporate_id,
          akc.corporate_name,
          pcm.contract_ref_no,
          cont_qty.contract_qty,
          pcpd.product_id,
          pdm.product_desc,
          pcdi.delivery_item_no,
          diqs.total_qty,
          qum_del.qty_unit,
          qum_del.decimals,
          qat.quality_id,
          pcdi.pricing_option_type,
          qat.quality_name,
          pci.item_qty,
          qum_itm_qty.qty_unit,
          qum_itm_qty.decimals,
          gmr.gmr_ref_no,
          gmr.is_final_weight,
          gmr.shipped_qty,
          gmr.final_weight,
          qum_gmr.qty_unit,
          qum_gmr.decimals,
          aml.attribute_id,
          aml.attribute_name,
          gsm.status,
          gmr.eff_date,
          gmr.bl_date,
          pofh.qp_start_date,
          pofh.qp_end_date,
          pcbph.price_description,
          qum_payable_qty.qty_unit,
          qum_payable_qty.decimals,
          agmr.eff_date,
          axs.eff_date,
          pocd.is_any_day_pricing,
          pcdi.price_allocation_method,
          diqs.title_transferred_qty,
          gpah.total_allocated_qty,
          pdm_under.product_desc,
          grd.is_afloat,
          ucm.multiplication_factor,
          qum_under.qty_unit 
union all
--11 Pricing Method: Price Allocation, Any Day QP Base Metal
select phd.companyname cp_name,
       phd.profileid,
       'Pricing Method: Price Allocation, Any Day QP' section_name,
       pcm.contract_type,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no cont_ref_no,
       cont_qty.contract_qty,
       pcpd.product_id,
       pdm.product_desc product,
       pcdi.delivery_item_no del_itm_ref_no,
       diqs.total_qty del_itm_qty,
       qum_del.qty_unit del_itm_qty_unit,
       qum_del.decimals del_qty_decimals,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no cont_itm_ref_no,
       pcdi.pricing_option_type pricing_option,
       qat.quality_id,
       qat.quality_name quality,
       pci.item_qty cont_itm_qty,
       qum_itm_qty.qty_unit,
       qum_itm_qty.decimals cont_itm_qty_decimals,
       gmr.gmr_ref_no,
       to_number(substr(gmr.gmr_ref_no,
                        instr(gmr.gmr_ref_no, '-') + 1,
                        (instr(gmr.gmr_ref_no, '-', 1, 2) -
                        instr(gmr.gmr_ref_no, '-')) - 1)) gmr_no,
       (case
         when gmr.is_final_weight = 'N' then
          gmr.shipped_qty
         else
          gmr.final_weight
       end) gmr_qty,
       qum_gmr.qty_unit gmr_qty_unit,
       qum_gmr.decimals gmr_qty_decimals,
       null element_id,
       null element,
       (case
         when grd.is_afloat = 'Y' then
          'Shipped'
         else
          'Landed'
       end) shipping_status,
       axs.eff_date shipped_date,
       agmr.eff_date landed_date,
       pofh.qp_start_date,
       pofh.qp_end_date,
       to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy') qp,
       pcbph.price_description pricing_method,
       null payable_qty,
       null payable_qty_unit,
       null payable_qty_decimals,
       to_char(round(nvl(gpah.total_allocated_qty, 0), 4)) price_fixation_qty_allocated,
       round(nvl(pofh.qty_to_be_fixed, 0), 4) - round(gpah.priced_qty, 4) unpriced_qty,
       gpah.priced_qty priced_qty,
       nvl(diqs.title_transferred_qty, 0) di_executed_qty,
       null utility_ref_no,
       pdm.product_desc underlying_product,
       ucm.multiplication_factor,
       qum_under.qty_unit underlying_product_qty_unit
  from pcm_physical_contract_main pcm,
       ak_corporate akc,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       pci_physical_contract_item pci,
       (select pcdi.internal_contract_ref_no,
               sum(diqs.total_qty) contract_qty
          from pcdi_pc_delivery_item         pcdi,
               diqs_delivery_item_qty_status diqs
         where pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and diqs.is_active = 'Y'
         group by pcdi.internal_contract_ref_no) cont_qty,
       qat_quality_attributes qat,
       axs_action_summary axs,
       gmr_goods_movement_record gmr,
       (select gmr.internal_gmr_ref_no,
               agmr.eff_date
          from gmr_goods_movement_record gmr,
               agmr_action_gmr           agmr
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agmr.gmr_latest_action_action_id in
               ('landingDetail', 'releaseOrder')
           and agmr.is_deleted = 'N') agmr,
       gsm_gmr_stauts_master gsm,
       grd_goods_record_detail grd,
       pcdb_pc_delivery_basis pcdb,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       phd_profileheaderdetails phd,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       (select gpah.internal_gmr_ref_no,
               sum(case
                     when pfd.user_price is null then
                      0
                     else
                      gpad.allocated_qty
                   end) priced_qty,
               sum(gpah.total_allocated_qty) total_allocated_qty
          from gpah_gmr_price_alloc_header gpah,
               gpad_gmr_price_alloc_dtls   gpad,
               pfd_price_fixation_details  pfd
         where gpah.gpah_id = gpad.gpah_id
           and gpad.pfd_id = pfd.pfd_id
           and gpah.is_active = 'Y'
           and gpad.is_active = 'Y'
           and pfd.is_active = 'Y'
           and pfd.is_exposure='Y'
         group by gpah.internal_gmr_ref_no) gpah,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       qum_quantity_unit_master qum_del,
       qum_quantity_unit_master qum_itm_qty,
       qum_quantity_unit_master qum_gmr,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master   qum_under
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.contract_type = 'BASEMETAL'
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcdi.pcdi_id = pci.pcdi_id
   and qat.quality_id = pcpq.quality_template_id
   and pcm.internal_contract_ref_no = cont_qty.internal_contract_ref_no
   and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
   and gsm.status_id = gmr.status_id
   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and pci.internal_contract_item_ref_no =
       grd.internal_contract_item_ref_no
   and pcpd.product_id = grd.product_id
   and pcpq.quality_template_id = grd.quality_id
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcdb.pcdb_id = pci.pcdb_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpd.input_output = 'Input'
   and phd.profileid = pcm.cp_id
   and pdm.product_id = pcpd.product_id
   and poch.pcdi_id = grd.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pofh.pofh_id = pfd.pofh_id
   and pfd.is_active = 'Y'
   and pfd.is_exposure='Y'
   and gpah.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and qum_itm_qty.qty_unit_id = pci.item_qty_unit_id
   and gmr.qty_unit_id = qum_gmr.qty_unit_id
   and diqs.item_qty_unit_id = qum_del.qty_unit_id
   and gmr.qty_unit_id=ucm.from_qty_unit_id
   and pdm.base_quantity_unit=ucm.to_qty_unit_id
   and pdm.base_quantity_unit=qum_under.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.purchase_sales = 'P'
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and gmr.is_deleted = 'N'
   and grd.is_deleted = 'N'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and diqs.is_active = 'Y'
   and gsm.status in
       ('Landed', 'On Ship', 'On Truck', 'On Rail', 'On Air', 'In Warehouse')
   and pocd.qp_period_type <> 'Event'  
   and pocd.is_any_day_pricing = 'Y'
   and pcdi.price_allocation_method = 'Price Allocation'
   and (round(nvl(pofh.qty_to_be_fixed, 0), 4) - round(gpah.priced_qty, 4)) > 0
