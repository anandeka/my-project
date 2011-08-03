CREATE OR REPLACE FUNCTION f_get_inventory_pnl_value(grd_ref_no VARCHAR2,
                                                                          grd_current_qty                 NUMBER,
                                                                          grd_from_qty_id VARCHAR2,
                                                                          grd_product_id VARCHAR2)
  RETURN NUMBER IS
  pnl_qty            NUMBER;
  pnl_value          NUMBER;
  RESULT             NUMBER:=0;
  grd_str            VARCHAR2(20):='%'||grd_ref_no||'%'  ; 
  base_unit_unit_id  VARCHAR2(20);
  
BEGIN
  
   select PDM.BASE_QUANTITY_UNIT into  base_unit_unit_id from PDM_PRODUCTMASTER pdm where PDM.PRODUCT_ID=grd_product_id;

   
  
  select inv.pnl_in_base,inv.QTY_IN_BASE_UNIT into pnl_value,pnl_qty
    from mv_dm_phy_stock inv  where inv.psu_id like grd_str;

 -- select inv.stock_qty into pnl_qty
--    from v_dm_phy_stock inv where inv.psu_id like grd_str;
  
  IF pnl_qty <> 0 then
     
  RESULT := ((pnl_value / pnl_qty) *  (pkg_general.F_GET_CONVERTED_QUANTITY(grd_product_id,grd_from_qty_id,base_unit_unit_id,grd_current_qty)));
  ELSE  RESULT := pnl_value;
  end if;
  


  return round(RESULT,3);
exception
when no_data_found then

return RESULT;
END f_get_inventory_pnl_value;
/
