CREATE OR REPLACE FUNCTION f_get_derivative_deal_value(open_deal_id VARCHAR2,
                                                                            corp_id      VARCHAR2)
  RETURN NUMBER IS
  deal_item_value   VARCHAR2(400);
  RESULT            NUMBER := 0;
  curr_code         VARCHAR2(15);
  pnl_qty           NUMBER;
  pnl_value         NUMBER;
  pc_open_qty       NUMBER;
  totalvalue        NUMBER;
  pc_total_qty      NUMBER;
  pc_from_qty_id    VARCHAR2(15);
  pc_product_id     VARCHAR2(15);
  base_unit_unit_id VARCHAR2(15);
  item_id           VARCHAR2(15);

  CURSOR cur_deal_detail is
  
    SELECT distinct dmd.deal_type_id
      FROM dmd_deal_management_detail dmd
     WHERE dmd.deal_id = open_deal_id
       AND dmd.deal_type = 'Derivative';

                                     
  CURSOR cur_eod_detail(item_id VARCHAR2) is
  
    SELECT v_der.quantity, v_der.pnl_in_base_cur, v_der.base_qty_unit_id
      FROM mv_dm_phy_derivative v_der
     WHERE v_der.internal_derivative_ref_no = item_id;
     
 

begin

  FOR cur_deal_detail_rows IN cur_deal_detail LOOP
    --dbms_output.put_line(' for loop 1 ' || cur_deal_detail_rows.deal_type_id);

    FOR cur_eod_detail_rows IN cur_eod_detail(cur_deal_detail_rows.deal_type_id) LOOP
    
    -- dbms_output.put_line(' for loop 2 ');
      SELECT cdc.product_id, cdc.quantity_unit_id, cdc.total_quantity
        INTO pc_product_id, pc_from_qty_id, pc_open_qty
        FROM v_cdc_derivative_trade cdc
       WHERE cdc.internal_derivative_ref_no =
             cur_deal_detail_rows.deal_type_id;
      pnl_value         := cur_eod_detail_rows.pnl_in_base_cur;
      pnl_qty           := cur_eod_detail_rows.quantity;
      base_unit_unit_id := cur_eod_detail_rows.base_qty_unit_id;
      IF pnl_qty <> 0 THEN
        --RESULT := ((pnl_value / pnl_qty) * pc_open_qty);
        --dbms_output.put_line(' pnl_value ' || pnl_value);
         --dbms_output.put_line(' pc_product_id ' || pc_product_id);
        -- dbms_output.put_line(' pc_from_qty_id ' || pc_from_qty_id);
        -- dbms_output.put_line(' base_unit_unit_id ' || base_unit_unit_id);
        -- dbms_output.put_line(' base_unit_unit_id ' || pnl_qty);
        --  dbms_output.put_line(' pc_open_qty ' || pc_open_qty);
        RESULT := RESULT + pnl_value;
      ELSE
        RESULT := 0;
      END IF;
    
    END LOOP;
  END LOOP;
return round(RESULT,4);
EXCEPTION
  WHEN OTHERS THEN
    -- raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
  
    return 0;
end;
/
