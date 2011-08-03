CREATE OR REPLACE FUNCTION f_get_open_item_pnl_value(
   pc_int_contract_item_ref_no   VARCHAR2,
   pc_open_qty                   NUMBER,
   corp_id                       VARCHAR2
)
   RETURN NUMBER
IS
   vc_open_item_value    VARCHAR2 (150);
   curr_code             VARCHAR2 (100);
   current_qty           NUMBER;
   pnl_qty               NUMBER;
   pnl_value             NUMBER;
   RESULT                NUMBER;
   qty_in_base_unit      NUMBER;
   base_unit_unit_id     VARCHAR2 (20);
   pc_from_qty_unit_id   VARCHAR2 (20);
   pc_product_id          VARCHAR2 (20);
BEGIN
   BEGIN
      SELECT pci.product_id, pci.item_qty_unit_id
        INTO pc_product_id, pc_from_qty_unit_id
        FROM v_pci pci
       WHERE pci.internal_contract_item_ref_no = pc_int_contract_item_ref_no;
   END;

   BEGIN
      SELECT pdm.base_quantity_unit
        INTO base_unit_unit_id
        FROM pdm_productmaster pdm
       WHERE pdm.product_id = pc_product_id;
   END;

  
   BEGIN
      SELECT v_open.pnl_in_base, v_open.qty_in_base_unit
        INTO pnl_value, pnl_qty
        FROM mv_dm_phy_open v_open
       WHERE v_open.internal_contract_item_ref_no =
                                                   pc_int_contract_item_ref_no;
   END;

  
   IF pnl_qty <> 0
   THEN
      RESULT :=
         (  (pnl_value / pnl_qty)
          * (pkg_general.f_get_converted_quantity (pc_product_id,
                                                   pc_from_qty_unit_id,
                                                   base_unit_unit_id,
                                                   pc_open_qty
                                                  )
            )
         );
   ELSE
      RESULT := pnl_value;
   END IF;

   RETURN round(RESULT,3);
--EXCEPTION
--   WHEN NO_DATA_FOUND
--   THEN
--      RETURN 0;
END f_get_open_item_pnl_value;
/
