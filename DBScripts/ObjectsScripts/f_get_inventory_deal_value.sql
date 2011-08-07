/* Formatted on 2011/08/07 18:04 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FUNCTION f_get_inventory_deal_value (
   open_deal_id   VARCHAR2,
   corp_id        VARCHAR2
)
   RETURN NUMBER
IS
   RESULT              NUMBER         := 0;

   CURSOR open_items
   IS
      SELECT dmd.deal_type_id item_id
        FROM dmd_deal_management_detail dmd
       WHERE dmd.deal_id = open_deal_id AND dmd.deal_type = 'Inventory';

   deal_item_value     VARCHAR2 (400);
   curr_code           VARCHAR2 (15);
   pnl_qty             NUMBER         := 0;
   pnl_value           NUMBER         := 0;
   pc_open_qty         NUMBER;
   grd_str             VARCHAR2 (100);
   grd_product_id      VARCHAR2 (20);
   grd_from_qty_id     VARCHAR2 (20);
   base_unit_unit_id   VARCHAR2 (20);
   grd_ref             VARCHAR2 (20);
   grd_int             VARCHAR2 (20);
   grd_gmr             VARCHAR2 (20);
BEGIN
   FOR eachitem IN open_items
   LOOP
      SELECT grd.current_qty, grd.qty_unit_id, grd.product_id,
             grd.internal_grd_ref_no, grd.internal_gmr_ref_no,
             grd.internal_contract_item_ref_no
        INTO pc_open_qty, grd_from_qty_id, grd_product_id,
             grd_ref, grd_gmr,
             grd_int
        FROM grd_goods_record_detail grd
       WHERE grd.internal_grd_ref_no = eachitem.item_id;

      grd_str := grd_gmr || '-' || grd_ref || '-' || grd_int || '-';

      SELECT pdm.base_quantity_unit
        INTO base_unit_unit_id
        FROM pdm_productmaster pdm
       WHERE pdm.product_id = grd_product_id;

      -- pnl_qty   := 20;
       --pnl_value :=100 ;
      SELECT SUM (inv.pnl_in_base), SUM (inv.qty_in_base_unit)
        INTO pnl_value, pnl_qty
        FROM mv_dm_phy_stock inv
       WHERE inv.psu_id = grd_str;

      IF pnl_qty <> 0
      THEN
         --RESULT := ((pnl_value / pnl_qty) * pc_open_qty);
         RESULT :=
              RESULT
            + (  (pnl_value / pnl_qty)
               * (pkg_general.f_get_converted_quantity (grd_product_id,
                                                        grd_from_qty_id,
                                                        base_unit_unit_id,
                                                        pc_open_qty
                                                       )
                 )
              );
      ELSE
         RESULT := RESULT;
      END IF;
   END LOOP;

--DBMS_OUTPUT.put_line ('RESULT  ' || RESULT);
   --deal_item_value := RESULT  ;

   -- SELECT cm.cur_code into curr_code
   -- FROM cm_currency_master cm, ak_corporate ak
   --WHERE cm.cur_id = ak.base_cur_id AND ak.corporate_id = corp_id ;

   --deal_item_value  := RESULT + curr_code ;
   RETURN (RESULT);
END;
/