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
   and gmr.discharge_city_id = cim_dc.city_id(+)
   and nvl(grd.tolling_stock_type, 'NA') in
       ('None Tolling', 'MFT In Process Stock', 'NA')
