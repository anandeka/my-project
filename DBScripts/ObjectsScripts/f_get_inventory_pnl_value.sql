/* Formatted on 2011/08/07 17:10 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FUNCTION f_get_inventory_pnl_value (
   grd_ref_no        VARCHAR2,
   grd_current_qty   NUMBER,
   grd_from_qty_id   VARCHAR2,
   grd_product_id    VARCHAR2
)
   RETURN NUMBER
IS
   pnl_qty             NUMBER;
   pnl_value           NUMBER;
   RESULT              NUMBER         := 0;
   grd_str             VARCHAR2 (100);
   base_unit_unit_id   VARCHAR2 (20);
   grd_ref             VARCHAR2 (20);
   grd_int             VARCHAR2 (20);
   grd_gmr             VARCHAR2 (20);
BEGIN
   SELECT grd.internal_gmr_ref_no, grd.internal_grd_ref_no,
          grd.internal_contract_item_ref_no
     INTO grd_gmr, grd_ref,
          grd_int
     FROM grd_goods_record_detail grd
    WHERE grd.internal_grd_ref_no = grd_ref_no;

   grd_str := grd_gmr || '-' || grd_ref || '-' || grd_int || '-';

   SELECT pdm.base_quantity_unit
     INTO base_unit_unit_id
     FROM pdm_productmaster pdm
    WHERE pdm.product_id = grd_product_id;

   -- dbms_output.put_line(grd_str);
   SELECT SUM (inv.pnl_in_base), SUM (inv.qty_in_base_unit)
     INTO pnl_value, pnl_qty
     FROM mv_dm_phy_stock inv
    WHERE inv.psu_id = grd_str;

   -- dbms_output.put_line(grd_str);

   -- select inv.stock_qty into pnl_qty
--    from v_dm_phy_stock inv where inv.psu_id like grd_str;
   IF pnl_qty <> 0
   THEN
      RESULT :=
         (  (pnl_value / pnl_qty)
          * (pkg_general.f_get_converted_quantity (grd_product_id,
                                                   grd_from_qty_id,
                                                   base_unit_unit_id,
                                                   grd_current_qty
                                                  )
            )
         );
   ELSE
      RESULT := pnl_value;
   END IF;

   RETURN ROUND (RESULT, 3);
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN RESULT;
END f_get_inventory_pnl_value;
/