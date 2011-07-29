CREATE OR REPLACE FUNCTION f_get_open_item_pnl_value(pc_int_contract_item_ref_no VARCHAR2,
                                                                          pc_open_qty                 NUMBER,
                                                                          corp_id                     VARCHAR2)
  RETURN NUMBER IS
  vc_open_item_value VARCHAR2(150);
  curr_code          VARCHAR2(100);
  current_qty        NUMBER;
  pnl_qty            NUMBER;
  pnl_value          NUMBER;
  RESULT             NUMBER:=0;
BEGIN

 -- pnl_value := 100;
  --pnl_qty   := 20;
  select v_open.pnl_in_base ,v_open.item_qty into pnl_value,pnl_qty
    from mv_dm_phy_open v_open where v_open.internal_contract_item_ref_no = pc_int_contract_item_ref_no ;

  
  IF pnl_qty <> 0 then
     
  RESULT := ((pnl_value / pnl_qty) * pc_open_qty);
  ELSE  RESULT := pnl_value;
  end if;
  


  return RESULT;
  
exception
when no_data_found then

return RESULT;

END f_get_open_item_pnl_value;
/

CREATE OR REPLACE FUNCTION f_get_inventory_pnl_value(grd_ref_no VARCHAR2,
                                                                          grd_current_qty                 NUMBER)
  RETURN NUMBER IS
  pnl_qty            NUMBER;
  pnl_value          NUMBER;
  RESULT             NUMBER:=0;
  grd_str            VARCHAR2(20):='%'||grd_ref_no||'%'  ; 
  
BEGIN
   
 -- pnl_value := 100;
  --pnl_qty   := 20;
  select inv.pnl_in_base,inv.stock_qty into pnl_value,pnl_qty
    from mv_dm_phy_stock inv  where inv.psu_id like grd_str;

 -- select inv.stock_qty into pnl_qty
--    from v_dm_phy_stock inv where inv.psu_id like grd_str;
  
  IF pnl_qty <> 0 then
     
  RESULT := ((pnl_value / pnl_qty) * grd_current_qty);
  ELSE  RESULT := pnl_value;
  end if;
  


  return RESULT;
exception
when no_data_found then

return RESULT;
END f_get_inventory_pnl_value;
/

CREATE OR REPLACE FUNCTION f_get_open_deal_value(open_deal_id VARCHAR2,
                                                 corp_id VARCHAR2)
  RETURN NUMBER IS
  CURSOR open_items IS
    SELECT dmd.deal_type_id item_id
      FROM dmd_deal_management_detail dmd
     WHERE dmd.deal_id = open_deal_id
       AND dmd.deal_type = 'Open';

  deal_item_value VARCHAR2(400);
  RESULT          NUMBER := 0;
  curr_code       VARCHAR2(15);
  pnl_qty         NUMBER;
  pnl_value       NUMBER;
  pc_open_qty     NUMBER;
BEGIN
  FOR eachitem IN open_items LOOP
    SELECT pci.open_qty
      INTO pc_open_qty
      FROM v_pci pci
     WHERE pci.internal_contract_item_ref_no = eachitem.item_id;
    dbms_output.put_line('eachitem.item_id ' ||
                                     eachitem.item_id);
   
    select v_open.pnl_in_base ,v_open.item_qty into pnl_value,pnl_qty
    from mv_dm_phy_open v_open where v_open.internal_contract_item_ref_no = eachitem.item_id;
    
                                     
      IF pnl_qty <> 0 then
     
    --RESULT := ((pnl_value / pnl_qty) * pc_open_qty);
    RESULT := RESULT + ((pnl_value / pnl_qty) * pc_open_qty);
       
    
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
  grd_str            VARCHAR2(20); 
BEGIN
  FOR eachitem IN open_items LOOP
    SELECT GRD.CURRENT_QTY
      INTO pc_open_qty
      FROM GRD_GOODS_RECORD_DETAIL grd
     WHERE  grd.INTERNAL_GRD_REF_NO = eachitem.item_id;
    dbms_output.put_line('eachitem.item_id ' ||
                                     eachitem.item_id);
    grd_str :='%'||eachitem.item_id||'%'  ; 
    
   -- pnl_qty   := 20;
    --pnl_value :=100 ;
    
    
    select inv.pnl_in_base,inv.stock_qty into pnl_value,pnl_qty
    from mv_dm_phy_stock inv  where inv.psu_id like grd_str;
    
   
    
                                     
      IF pnl_qty <> 0 then
     
    --RESULT := ((pnl_value / pnl_qty) * pc_open_qty);
    RESULT := RESULT + ((pnl_value / pnl_qty) * pc_open_qty);
       
    
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
CREATE OR REPLACE FUNCTION f_get_derivative_Deal_Value(open_deal_id VARCHAR2,
                                                 corp_id VARCHAR2)
  RETURN NUMBER IS
  CURSOR open_items IS
    SELECT dmd.deal_type_id item_id
      FROM dmd_deal_management_detail dmd
     WHERE dmd.deal_id = open_deal_id
       AND dmd.deal_type = 'Derivative';

  deal_item_value VARCHAR2(400);
  RESULT          NUMBER := 0;
  curr_code       VARCHAR2(15);
  pnl_qty         NUMBER;
  pnl_value       NUMBER;
  pc_open_qty     NUMBER;
  totalValue     NUMBER;
BEGIN
  FOR eachitem IN open_items LOOP
  
     
    select sum(v_der.PNL_IN_BASE_CUR) into totalValue
    from mv_dm_phy_derivative v_der where v_der.INTERNAL_DERIVATIVE_REF_NO=eachitem.item_id
    group by INTERNAL_DERIVATIVE_REF_NO;
   
                                  
     -- IF pnl_qty <> 0 then
     
    --RESULT := ((pnl_value / pnl_qty) * pc_open_qty);
    --RESULT := RESULT + ((pnl_value / pnl_qty) * pc_open_qty);
       
    
   -- ELSE  RESULT := RESULT + pnl_value;
      
   -- end if;
    
    --RESULT    := RESULT + ((pnl_value / pnl_qty) * pc_open_qty);
    
     RESULT := RESULT + totalValue;
    
  END LOOP;
   
  --deal_item_value := RESULT  ;
  
 -- SELECT cm.cur_code into curr_code
 -- FROM cm_currency_master cm, ak_corporate ak
 --WHERE cm.cur_id = ak.base_cur_id AND ak.corporate_id = corp_id ;
 
 --deal_item_value  := RESULT + curr_code ;
 
  RETURN(RESULT);
END;
/
