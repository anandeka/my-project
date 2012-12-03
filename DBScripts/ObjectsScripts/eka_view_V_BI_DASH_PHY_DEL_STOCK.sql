CREATE OR REPLACE VIEW V_BI_DASH_PHY_DEL_STOCK AS
select gmr.corporate_id,
       dgrd.internal_stock_ref_no,
       gmr.gmr_ref_no,
       pci.contract_item_ref_no,
       pci.cp_name,
       pdm.product_desc product,
       qat.quality_name,
       decode(dgrd.is_afloat, 'Y', 'IN TRANSIT', 'IN WAREHOUSE') stock_status,
       dgrd.bl_number bl_number,
       pci.strategy_name strategy,
       nvl(dgrd.net_weight, 0) current_qty,
       qum.qty_unit
  from dgrd_delivered_grd        dgrd,
       gmr_goods_movement_record gmr,
       v_pci                     pci,
       agh_alloc_group_header    agh,
       pdm_productmaster         pdm,
       qum_quantity_unit_master  qum,
       qat_quality_attributes    qat
 where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and dgrd.int_alloc_group_id = agh.int_alloc_group_id
   and agh.int_sales_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and pci.product_id = pdm.product_id
   and dgrd.quality_id = qat.quality_id(+)
   and dgrd.net_weight_unit_id = qum.qty_unit_id
   and dgrd.status = 'Active'
   and gmr.is_deleted = 'N'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and agh.is_deleted = 'N'
union all
select gmr.corporate_id,
       dgrd.internal_stock_ref_no,
       gmr.gmr_ref_no,
       '' contract_item_ref_no,
       '' cp_name,
       pdm.product_desc product,
       qat.quality_name,
       decode(dgrd.is_afloat, 'Y', 'IN TRANSIT', 'IN WAREHOUSE') stock_status,
       dgrd.bl_number bl_number,
       null strategy,
       nvl(dgrd.net_weight, 0) current_qty,
       qum.qty_unit
  from dgrd_delivered_grd        dgrd,
       gmr_goods_movement_record gmr,
       pdm_productmaster         pdm,
       qum_quantity_unit_master  qum,
       qat_quality_attributes    qat
 where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.gmr_latest_action_action_id = 'CREATE_RETURN_MATERIAL'
   and dgrd.quality_id = qat.quality_id(+)
   and dgrd.net_weight_unit_id = qum.qty_unit_id
   and dgrd.product_id = pdm.product_id
   and dgrd.status = 'Active'
   and gmr.is_deleted = 'N'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y';
