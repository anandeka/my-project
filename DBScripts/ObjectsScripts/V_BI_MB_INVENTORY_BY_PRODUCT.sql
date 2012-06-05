create or replace view v_bi_mb_inventory_by_product as
select t.corporate_id corporate_id,
       t.product_id,
       t.product_name,
       round(sum(t.contained_qty),2) contained_quantity,
       round(sum(t.in_process_qty),2) inprocess_quantity,
       round(sum(t.stock_qty),2) stock_quantity,
       round(sum(t.debt_qty),2) debt_quantity,
       round(sum(t.contained_qty),2) + round(sum(t.in_process_qty),2) + round(sum(t.stock_qty),2) -
       round(sum(t.debt_qty),2) net_quantity,
       t.qty_unit_id base_qty_unit_id,
       t.qty_unit base_qty_unit
  from (
        -- Contained Qty and Debt Qty
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        sum( pkg_general.f_get_converted_quantity(pdm.product_id,
                                                    spq.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    spq.payable_qty)
              ) contained_qty,
        0 in_process_qty,
        0 stock_qty,
       sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                            spq.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            spq.payable_qty)
              ) debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        spq_stock_payable_qty     spq,
        aml_attribute_master_list aml,
        qum_quantity_unit_master  qum,
        pdm_productmaster         pdm,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and spq.internal_grd_ref_no = grd.internal_grd_ref_no
    and spq.element_id = aml.attribute_id
    and aml.underlying_product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    --and grd.tolling_stock_type IN ( 'Clone Stock','None Tolling')
    and grd.tolling_stock_type IN ( 'None Tolling') --added 'None Tolling for  the Bug id 65542
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and spq.is_active = 'Y'
    and grd.warehouse_profile_id = phd_smelter.profileid(+)--TT in
    and grd.inventory_status = 'In'

    group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 union all
 -- In Process Qty
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 spq.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 spq.payable_qty))*-1 contained_qty,
        sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 spq.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 spq.payable_qty)) in_process_qty,
        0 stock_qty,
        0 debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        spq_stock_payable_qty     spq,
        aml_attribute_master_list aml,
        qum_quantity_unit_master  qum,
        pdm_productmaster         pdm,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and spq.element_id=grd.element_id
    and spq.element_id = aml.attribute_id
    and aml.underlying_product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.tolling_stock_type = 'MFT In Process Stock'
    and grd.warehouse_profile_id = phd_smelter.profileid(+)--TT in
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and spq.is_active = 'Y'

  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 -- Stock Qty Inventory in Base Metal Contracts
 union all
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0,
        0,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty)) stock_qty,
        0
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        pdm_productmaster         pdm,
        qum_quantity_unit_master  qum,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and grd.product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.warehouse_profile_id = phd_smelter.profileid(+) --TT in
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and grd.tolling_stock_type = 'None Tolling'
    and grd.inventory_status = 'In'
    and pdm.product_type_id = 'Standard'

  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 -- Stock Qty for In Process Stock
 union all
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0 contained_qty,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty))*-1 in_process_qty,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty)) stock_qty,
        0 debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        pdm_productmaster         pdm,
        qum_quantity_unit_master  qum,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and grd.tolling_stock_type = 'RM In Process Stock'
    and grd.product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.warehouse_profile_id = phd_smelter.profileid(+) --TT in
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'

  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
union all
select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0 contained_qty,
        0 in_process_qty,
        sum(pkg_general.f_get_converted_quantity(dgrd.product_id,
                                                 dgrd.net_weight_unit_id,
                                                 pdm.base_quantity_unit,
                                                 dgrd.current_qty))*(-1) stock_qty,
         sum(pkg_general.f_get_converted_quantity(dgrd.product_id,
                                                 dgrd.net_weight_unit_id,
                                                 pdm.base_quantity_unit,
                                                 dgrd.current_qty)) debt_qty
from dgrd_delivered_grd                  dgrd,
        gmr_goods_movement_record gmr,
        ak_corporate                         akc,
        pdm_productmaster               pdm,
        qum_quantity_unit_master      qum,
        phd_profileheaderdetails          phd_smelter
where dgrd.internal_gmr_ref_no=gmr.internal_gmr_ref_no
        and dgrd.tolling_stock_type = 'Return Material Stock'
        and gmr.corporate_id=akc.corporate_id
        and dgrd.product_id=pdm.product_id
        and pdm.base_quantity_unit=qum.qty_unit_id
        and dgrd.warehouse_profile_id=phd_smelter.profileid
        --and gmr.gmr_ref_no='GMR-369-BLD'

group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname) t
   group by t.corporate_id,
           t.corporate_name,
           t.product_id,
           t.product_name,
           t.qty_unit_id,
           t.qty_unit

