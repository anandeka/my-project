create or replace view v_bi_mb_yield_by_smelters as
with free_metal_stock as
(select grd.internal_gmr_ref_no,
       round(sum(grd.total_qty * ucm.multiplication_factor), 5) free_metal_qty,
       grd.element_id,
       pdm.product_id,
       pdm.product_desc product_name,--Bug 63266 Fix added alias name
       qum.qty_unit_id,
       qum.qty_unit,
       pcm.cp_id smelter_id,
       phd.companyname smelter_name
  from grd_goods_record_detail    grd,
       aml_attribute_master_list  aml,
       pdm_productmaster          pdm,
       qum_quantity_unit_master   qum,
       ucm_unit_conversion_master ucm,
       pcdi_pc_delivery_item      pcdi,
       pcm_physical_contract_main pcm,
       phd_profileheaderdetails   phd
 where grd.tolling_stock_type = 'Free Material Stock'
   and grd.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm.product_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and grd.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.cp_id = phd.profileid
   and grd.status = 'Active'
   and grd.is_deleted = 'N'
 group by grd.internal_gmr_ref_no,
          grd.element_id,
          pdm.product_id,
          pdm.product_desc,
          qum.qty_unit_id,
          qum.qty_unit,
          pcm.cp_id,
          phd.companyname
)
select gmr.corporate_id corporate_id,
       pdm.product_id,
       pdm.product_desc product_name,--Bug 63266 Fix added alias name
       grd.smelter_id,
       grd.smelter_name,
       ypd.yield_pct yield_percentage,
       sum(agmr.current_qty) feed_quantity,
       sum(grd.free_metal_qty) free_metal_quantity,
       grd.qty_unit_id base_qty_unit_id,
       grd.qty_unit base_qty_unit,
       to_char(agmr.eff_date, 'yyyy') ytd_year,
       to_char(agmr.eff_date, 'Mon') ytd_month
  from ypd_yield_pct_detail      ypd,
       axs_action_summary        axs,
       gmr_goods_movement_record gmr,
       agmr_action_gmr           agmr,
       aml_attribute_master_list aml,
       pdm_productmaster         pdm,
       qum_quantity_unit_master  qum,
       free_metal_stock          grd
 where ypd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and ypd.internal_action_ref_no = axs.internal_action_ref_no
   and ypd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   and ypd.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm.product_id(+)
  -- and to_char(agmr.eff_date, 'Mon-yyyy') = to_char(sysdate, 'Mon-yyyy')
   and gmr.is_deleted = 'N'
   and agmr.qty_unit_id = qum.qty_unit_id
   and ypd.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and ypd.is_active = 'Y'---added for Bug ID 79231
   and ypd.element_id = grd.element_id
   and aml.is_active = 'Y'
   and pdm.is_active = 'Y'
   and agmr.action_no = '1'
       group by gmr.corporate_id,
       pdm.product_id,
       pdm.product_desc,
       grd.smelter_id,
       grd.smelter_name,
       ypd.yield_pct,
       grd.qty_unit_id,
       grd.qty_unit,
       to_char(agmr.eff_date, 'yyyy'),
       to_char(agmr.eff_date, 'Mon');
