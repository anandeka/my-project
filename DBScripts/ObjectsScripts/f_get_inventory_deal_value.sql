CREATE OR REPLACE FUNCTION f_get_inventory_deal_value(open_deal_id VARCHAR2,
                                                 corp_id VARCHAR2)
  RETURN NUMBER IS
  CURSOR open_items IS
    SELECT dmd.deal_type_id item_id
      FROM dmd_deal_management_detail dmd
     WHERE dmd.deal_id = open_deal_id
       AND dmd.deal_type = 'Inventory';

  deal_item_value VARCHAR2(400);
  RESULT          NUMBER := 0;
  curr_code       VARCHAR2(15);
  pnl_qty         NUMBER;
  pnl_value       NUMBER;
  pc_open_qty     NUMBER;
  grd_str         VARCHAR2(20); 
  grd_product_id      VARCHAR2(20); 
  grd_from_qty_id VARCHAR2(20); 
  base_unit_unit_id VARCHAR2(20);
BEGIN
  FOR eachitem IN open_items LOOP
    SELECT GRD.CURRENT_QTY, grd.qty_unit_id ,grd.product_id
      INTO pc_open_qty,grd_from_qty_id,grd_product_id
      FROM GRD_GOODS_RECORD_DETAIL grd
     WHERE  grd.INTERNAL_GRD_REF_NO = eachitem.item_id;
    
    
    grd_str :='%'||eachitem.item_id||'%'  ; 
    
    
     select PDM.BASE_QUANTITY_UNIT into  base_unit_unit_id from PDM_PRODUCTMASTER pdm where PDM.PRODUCT_ID=grd_product_id;
   -- pnl_qty   := 20;
    --pnl_value :=100 ;
    
    
    select inv.pnl_in_base,inv.qty_in_base_unit into pnl_value,pnl_qty
    from mv_dm_phy_stock inv  where inv.psu_id like grd_str;
    
   
    
                                     
      IF pnl_qty <> 0 then
     
    --RESULT := ((pnl_value / pnl_qty) * pc_open_qty);
    RESULT := RESULT + ((pnl_value / pnl_qty) * (pkg_general.F_GET_CONVERTED_QUANTITY(grd_product_id,grd_from_qty_id,base_unit_unit_id,pc_open_qty)));
       
    
    ELSE  RESULT := RESULT + pnl_value;
      
    end if;
    
    --RESULT    := RESULT + ((pnl_value / pnl_qty) * pc_open_qty);
    
  END LOOP;
   
  --deal_item_value := RESULT  ;
  
 -- SELECT cm.cur_code into curr_code
 -- FROM cm_currency_master cm, ak_corporate ak
 --WHERE cm.cur_id = ak.base_cur_id AND ak.corporate_id = corp_id ;
 
 --deal_item_value  := RESULT + curr_code ;
 
  RETURN(RESULT);
END;
/
