create or replace view v_bi_dash_phy_whs_stock as
select gmr.corporate_id,
       grd.internal_stock_ref_no,
       gmr.gmr_ref_no,
       pci.contract_item_ref_no,
       pci.cp_name,
       prdm.product_desc,
       qat.quality_name,
       (select shm.companyname || '(' || shm.shed_name || ')'
          from v_shm_shed_master shm
         where shm.profile_id = grd.warehouse_profile_id
           and shm.shed_id = grd.shed_id) warehouse,
       (select wcym.country_name || '(' || wcim.city_name || ')'
          from cym_countrymaster wcym,
               v_shm_shed_master shm,
               cim_citymaster    wcim
         where shm.profile_id = grd.warehouse_profile_id
           and shm.shed_id = grd.shed_id
           and shm.country_id = wcym.country_id
           and shm.city_id = wcim.city_id) location,
       pci.strategy_name,
       (nvl(grd.current_qty, 0)) || qum.qty_unit current_qty
  from grd_goods_record_detail   grd,
       pdm_productmaster         prdm,
       gmr_goods_movement_record gmr,
       v_pci                     pci,
       qat_quality_attributes    qat,
       qum_quantity_unit_master  qum
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.is_deleted = 'N'
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and grd.qty_unit_id = qum.qty_unit_id
   and grd.quality_id = qat.quality_id(+)
   and grd.is_deleted = 'N'
   and grd.status = 'Active'
   and prdm.product_id = grd.product_id
   and nvl(grd.is_added_to_pool, 'N') <> 'Y'
   and nvl(grd.tolling_stock_type, 'None Tolling') not in
       ('Input Process', 'Delta MFT IP Stock', 'Free Material Stock',
        'MFT In Process Stock', 'RM In Process Stock', 'Pledge Stock',
        'Financial Settlement Stock', 'Commercial Fee Stock')
   and nvl(grd.is_mark_for_tolling, 'N') <> 'Y';
