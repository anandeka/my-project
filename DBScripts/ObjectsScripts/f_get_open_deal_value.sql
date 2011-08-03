CREATE OR REPLACE FUNCTION f_get_open_deal_value(open_deal_id VARCHAR2,
                                                 corp_id VARCHAR2)
  RETURN NUMBER IS
  CURSOR open_items IS
    SELECT dmd.deal_type_id item_id
      FROM dmd_deal_management_detail dmd
     WHERE dmd.deal_id = open_deal_id
       AND dmd.deal_type = 'Open';

  deal_item_value     VARCHAR2(400);
  RESULT              NUMBER := 0;
  curr_code           VARCHAR2(15);
  pnl_qty             NUMBER;
  pnl_value           NUMBER;
  pc_open_qty         NUMBER;
  from_unit_id VARCHAR2(15);
  pci_product_id          VARCHAR2(15);
  base_unit_unit_id  VARCHAR2(15);
BEGIN
  FOR eachitem IN open_items LOOP
    SELECT pci.open_qty,pci.item_qty_unit_id,pci.product_id
      INTO pc_open_qty,from_unit_id,pci_product_id
      FROM v_pci pci
     WHERE pci.internal_contract_item_ref_no = eachitem.item_id;
    
    --select pci.pr from V_PCI pci where PCI.INTERNAL_CONTRACT_ITEM_REF_NO =pc_int_contract_item_ref_no;
     select PDM.BASE_QUANTITY_UNIT into  base_unit_unit_id from PDM_PRODUCTMASTER pdm where PDM.PRODUCT_ID=pci_product_id;
  
   
    select v_open.pnl_in_base ,v_open.QTY_IN_BASE_UNIT into pnl_value,pnl_qty
    from mv_dm_phy_open v_open where v_open.internal_contract_item_ref_no = eachitem.item_id;
    
                                     
      IF pnl_qty <> 0 then
     
    --RESULT := ((pnl_value / pnl_qty) * pc_open_qty);
    RESULT := RESULT + ((pnl_value / pnl_qty) * (pkg_general.F_GET_CONVERTED_QUANTITY(pci_product_id,from_unit_id,base_unit_unit_id,pc_open_qty)));
       
    
    ELSE  RESULT := RESULT + pnl_value;
      
    end if;
    
    --RESULT    := RESULT + ((pnl_value / pnl_qty) * pc_open_qty);
    
  END LOOP;
   
  --deal_item_value := RESULT  ;
  
 -- SELECT cm.cur_code into curr_code
 -- FROM cm_currency_master cm, ak_corporate ak
 --WHERE cm.cur_id = ak.base_cur_id AND ak.corporate_id = corp_id ;
 
 --deal_item_value  := RESULT + curr_code ;
 
  RETURN round(RESULT,3);
END;
/
