create or replace function "F_GET_INVENTORY_PNL_VALUE"(grd_ref_no      varchar2,
                                                       grd_current_qty number,
                                                       grd_from_qty_id varchar2,
                                                       grd_product_id  varchar2)
  return number is
  pnl_qty           number;
  pnl_value         number;
  result            number := 0;
  grd_str           varchar2(100);
  grd_con_no        varchar2(100);
  base_unit_unit_id varchar2(20);
  grd_ref           varchar2(20);
  grd_int           varchar2(20);
  grd_gmr           varchar2(20);
begin
  grd_gmr    := null;
  grd_ref    := null;
  grd_int    := null;
  grd_con_no := null;
  select grd.internal_gmr_ref_no,
         grd.internal_grd_ref_no,
         grd.internal_contract_item_ref_no,
         grd.container_no
    into grd_gmr,
         grd_ref,
         grd_int,
         grd_con_no
    from grd_goods_record_detail grd
   where grd.internal_grd_ref_no = grd_ref_no;

  grd_str := grd_gmr || '-' || grd_ref || '-' || grd_int || '-' ||
             grd_con_no;

  select pdm.base_quantity_unit
    into base_unit_unit_id
    from pdm_productmaster pdm
   where pdm.product_id = grd_product_id;

  -- dbms_output.put_line(grd_str);
  select sum(inv.pnl_in_base),
         sum(inv.qty_in_base_unit)
    into pnl_value,
         pnl_qty
    from mv_dm_phy_stock inv
   where inv.psu_id = grd_str;

  dbms_output.put_line(grd_str);

  -- select inv.stock_qty into pnl_qty
  --    from v_dm_phy_stock inv where inv.psu_id like grd_str;
  if pnl_qty <> 0 then
    result := ((pnl_value / pnl_qty) *
              (pkg_general.f_get_converted_quantity(grd_product_id,
                                                     grd_from_qty_id,
                                                     base_unit_unit_id,
                                                     grd_current_qty)));
  else
    result := pnl_value;
  end if;

  return round(result, 3);
exception
  when no_data_found then
    return result;
end f_get_inventory_pnl_value;
/
