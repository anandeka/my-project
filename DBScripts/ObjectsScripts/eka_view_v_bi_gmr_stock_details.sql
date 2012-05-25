create or replace view v_bi_gmr_stock_details as
select gmr.corporate_id,
       (case
         when nvl(grd.inventory_status, 'NA') in ('NA') then
          'Open'
         else
          'Stock'
       end) contract_status,
       (case
         when nvl(grd.inventory_status, 'NA') in ('NA') then
          'Open'
         else
          (case
         when nvl(grd.tolling_stock_type, 'NA') in ('None Tolling', 'NA') then
          'Stock'
         when nvl(grd.tolling_stock_type, 'NA') in ('MFT In Process Stock') then
          'In Process'
         else
          'Stock'
       end) end) position_status,
       (case
         when grd.is_afloat = 'Y' then
          'In Transit'
         else
          'In Warehouse'
       end) stock_status,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       grd.internal_grd_ref_no,
       grd.product_id,
       pdm.product_desc,
       grd.quality_id,
       qat.quality_name,
       grd.is_afloat,
       grd.inventory_status,
       grd.total_qty,
       grd.current_qty,
       grd.qty,
       qum.qty_unit,
       grd.qty_unit_id,
       pdm.base_quantity_unit base_qty_unit_id,
       qum_base.qty_unit base_qty_unit,
       ucm.multiplication_factor qty_conv,
       1 pos_sign,
       grd.tolling_qty,
       grd.tolling_stock_type,
       grd.warehouse_profile_id,
       grd.shed_id,
       (case
         when sld.city_id is not null then
          sld.city_id
         else
          gmr.discharge_city_id
       end) loc_city_id,
       (case
         when sld.city_id is not null then
          cim.city_name
         else
          cim_dc.city_name
       end) loc_city_name
  from gmr_goods_movement_record   gmr,
       grd_goods_record_detail     grd,
       pdm_productmaster           pdm,
       qat_quality_attributes      qat,
       sld_storage_location_detail sld,
       cim_citymaster              cim,
       cim_citymaster              cim_dc,
       qum_quantity_unit_master    qum,
       qum_quantity_unit_master    qum_base,
       ucm_unit_conversion_master  ucm
 where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and grd.product_id = pdm.product_id
   and grd.quality_id = qat.quality_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim.city_id(+)
   and grd.status = 'Active'
   and grd.is_deleted = 'N'
   and gmr.is_deleted = 'N'
   and grd.qty_unit_id = qum.qty_unit_id
   and pdm.base_quantity_unit = qum_base.qty_unit_id
   and grd.qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and pdm.product_type_id = 'Standard'
   and gmr.discharge_city_id = cim_dc.city_id(+)
   and nvl(grd.tolling_stock_type, 'NA') in
       ('None Tolling', 'MFT In Process Stock', 'RM In Process Stock', 'NA') --Receive Material is added.
union all --For Base Metal Sale
select gmr.corporate_id,
       (case
         when nvl(dgrd.inventory_status, 'NA') in ('NA') then
          'Open'
         else
          'Stock'
       end) contract_status,
       (case
         when nvl(dgrd.inventory_status, 'NA') in ('NA') then
          'Open'
         else
          (case
         when nvl(dgrd.tolling_stock_type, 'NA') in ('None Tolling', 'NA') then
          'Stock'
         when nvl(dgrd.tolling_stock_type, 'NA') in ('MFT In Process Stock') then
          'In Process'
         else
          'Stock'
       end) end) position_status,
       (case
         when dgrd.is_afloat = 'Y' then
          'In Transit'
         else
          'In Warehouse'
       end) stock_status,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       dgrd.internal_grd_ref_no,
       dgrd.product_id,
       pdm.product_desc,
       dgrd.quality_id,
       qat.quality_name,
       dgrd.is_afloat,
       dgrd.inventory_status,
       dgrd.total_qty,
       dgrd.current_qty,
       dgrd.total_qty qty,
       qum.qty_unit,
       dgrd.net_weight_unit_id,
       pdm.base_quantity_unit base_qty_unit_id,
       qum_base.qty_unit base_qty_unit,
       ucm.multiplication_factor qty_conv,
       -1 pos_sign,
       0 tolling_qty,
       dgrd.tolling_stock_type,
       dgrd.warehouse_profile_id,
       dgrd.shed_id,
       (case
         when sld.city_id is not null then
          sld.city_id
         else
          gmr.discharge_city_id
       end) loc_city_id,
       (case
         when sld.city_id is not null then
          cim.city_name
         else
          cim_dc.city_name
       end) loc_city_name
  from gmr_goods_movement_record   gmr,
       dgrd_delivered_grd          dgrd,
       pdm_productmaster           pdm,
       qat_quality_attributes      qat,
       sld_storage_location_detail sld,
       cim_citymaster              cim,
       cim_citymaster              cim_dc,
       qum_quantity_unit_master    qum,
       qum_quantity_unit_master    qum_base,
       ucm_unit_conversion_master  ucm
 where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
   and dgrd.product_id = pdm.product_id
   and dgrd.quality_id = qat.quality_id
   and dgrd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim.city_id(+)
   and dgrd.status = 'Active'
   and gmr.is_deleted = 'N'
   and dgrd.net_weight_unit_id = qum.qty_unit_id
   and pdm.base_quantity_unit = qum_base.qty_unit_id
   and dgrd.net_weight_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and pdm.product_type_id = 'Standard'
   and gmr.discharge_city_id = cim_dc.city_id(+)
   and nvl(dgrd.tolling_stock_type, 'NA') in
       ('None Tolling', 'MFT In Process Stock', 'RM In Process Stock', 'NA')
union all --For Receive Material , In Process need to reduce
SELECT gmr.corporate_id,
       (CASE
         WHEN NVL(grd.inventory_status, 'NA') IN ('NA') THEN
          'Open'
         ELSE
          'Stock'
       END) contract_status,
       (CASE
         WHEN NVL(grd.inventory_status, 'NA') IN ('NA') THEN
          'Open'
         ELSE
          (CASE
         WHEN NVL(grd.tolling_stock_type, 'NA') IN ('None Tolling', 'NA') THEN
          'Stock'
         WHEN NVL(grd.tolling_stock_type, 'NA') IN ('RM In Process Stock') THEN
          'In Process'
         ELSE
          'Stock'
       END) END) position_status,
       (CASE
         WHEN grd.is_afloat = 'Y' THEN
          'In Transit'
         ELSE
          'In Warehouse'
       END) stock_status,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       grd.internal_grd_ref_no,
       grd.product_id,
       pdm.product_desc,
       grd.quality_id,
       qat.quality_name,
       grd.is_afloat,
       grd.inventory_status,
       grd.total_qty,
       grd.current_qty,
       grd.qty,
       qum.qty_unit,
       grd.qty_unit_id,
       pdm.base_quantity_unit base_qty_unit_id,
       qum_base.qty_unit base_qty_unit,
       ucm.multiplication_factor qty_conv,
       -1 pos_sign,
       grd.tolling_qty,
       grd.tolling_stock_type,
       grd.warehouse_profile_id,
       grd.shed_id,
       (CASE
         WHEN sld.city_id IS NOT NULL THEN
          sld.city_id
         ELSE
          gmr.discharge_city_id
       END) loc_city_id,
       (CASE
         WHEN sld.city_id IS NOT NULL THEN
          cim.city_name
         ELSE
          cim_dc.city_name
       END) loc_city_name
  FROM gmr_goods_movement_record   gmr,
       grd_goods_record_detail     grd,
       pdm_productmaster           pdm,
       qat_quality_attributes      qat,
       sld_storage_location_detail sld,
       cim_citymaster              cim,
       cim_citymaster              cim_dc,
       qum_quantity_unit_master    qum,
       qum_quantity_unit_master    qum_base,
       ucm_unit_conversion_master  ucm
 WHERE gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and grd.product_id = pdm.product_id
   and grd.quality_id = qat.quality_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim.city_id(+)
   and grd.status = 'Active'
   and grd.is_deleted = 'N'
   and gmr.is_deleted = 'N'
   and grd.qty_unit_id = qum.qty_unit_id
   and pdm.base_quantity_unit = qum_base.qty_unit_id
   and grd.qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and pdm.product_type_id = 'Standard'
   and gmr.discharge_city_id = cim_dc.city_id(+)
   and grd.tolling_stock_type = 'RM In Process Stock'
union all

SELECT gmr.corporate_id,
       (CASE
         WHEN NVL(grd.inventory_status, 'NA') IN ('NA') THEN
          'Open'
         ELSE
          'Stock'
       END) contract_status,
       (CASE
         WHEN NVL(grd.inventory_status, 'NA') IN ('NA') THEN
          'Open'
         ELSE
          (CASE
         WHEN NVL(grd.tolling_stock_type, 'NA') IN ('None Tolling', 'NA') THEN
          'Stock'
         WHEN NVL(grd.tolling_stock_type, 'NA') IN ('MFT In Process Stock') THEN
          'In Process'
         ELSE
          'Stock'
       END) END) position_status,
       (CASE
         WHEN grd.is_afloat = 'Y' THEN
          'In Transit'
         ELSE
          'In Warehouse'
       END) stock_status,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       grd.internal_grd_ref_no,
       grd.product_id,
       pdm.product_desc,
       grd.quality_id,
       qat.quality_name,
       grd.is_afloat,
       grd.inventory_status,
       --grd.total_qty,
       pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                               sam.ash_id,
                                               grd.total_qty,
                                               qum.qty_unit_id) total_qty,
       --grd.current_qty,
       (case
         when grd.current_qty <> 0 then
          pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                  sam.ash_id,
                                                  grd.current_qty,
                                                  qum.qty_unit_id)
         else
          0
       end) current_qty,
       --grd.qty,
       pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                               sam.ash_id,
                                               grd.qty,
                                               qum.qty_unit_id) qty,
       qum.qty_unit,
       grd.qty_unit_id,
       pdm.base_quantity_unit base_qty_unit_id,
       qum_base.qty_unit base_qty_unit,
       ucm.multiplication_factor qty_conv,
       1 pos_sign,
       grd.tolling_qty,
       grd.tolling_stock_type,
       grd.warehouse_profile_id,
       grd.shed_id,
       (CASE
         WHEN sld.city_id IS NOT NULL THEN
          sld.city_id
         ELSE
          gmr.discharge_city_id
       END) loc_city_id,
       (CASE
         WHEN sld.city_id IS NOT NULL THEN
          cim.city_name
         ELSE
          cim_dc.city_name
       END) loc_city_name
  FROM gmr_goods_movement_record   gmr,
       grd_goods_record_detail     grd,
       ash_assay_header            ash,
       sam_stock_assay_mapping     sam,
       pdm_productmaster           pdm,
       qat_quality_attributes      qat,
       sld_storage_location_detail sld,
       cim_citymaster              cim,
       cim_citymaster              cim_dc,
       qum_quantity_unit_master    qum,
       qum_quantity_unit_master    qum_base,
       ucm_unit_conversion_master  ucm
 WHERE gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and grd.internal_grd_ref_no = ash.internal_grd_ref_no
   and ash.ash_id = sam.ash_id
   and sam.is_latest_pricing_assay = 'Y'
   and grd.internal_grd_ref_no = sam.internal_grd_ref_no
   and grd.product_id = pdm.product_id
   and grd.quality_id = qat.quality_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim.city_id(+)
   and grd.status = 'Active'
   and grd.is_deleted = 'N'
   and gmr.is_deleted = 'N'
   and ash.is_active = 'Y'
   and sam.is_active = 'Y'
   and grd.qty_unit_id = qum.qty_unit_id
   and pdm.base_quantity_unit = qum_base.qty_unit_id
   and pdm.product_type_id = 'Composite'
   and grd.qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and gmr.discharge_city_id = cim_dc.city_id(+)
   and NVL(grd.tolling_stock_type, 'NA') IN
       ('None Tolling', 'MFT In Process Stock', 'RM In Process Stock', 'NA')
