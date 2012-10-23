DECLARE
   CURSOR gepd_temp_list
   IS
      SELECT *
        FROM gepd_gmr_element_pledge_detail;
BEGIN
   FOR gepd_temp IN gepd_temp_list
   LOOP
      UPDATE gepd_gmr_element_pledge_detail gepd
         SET gepd.internal_pledge_qty = gepd_temp.pledge_qty
       WHERE gepd.gepd_id = gepd_temp.gepd_id;
   END LOOP;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DECLARE
   CURSOR gepd_temp_swap_list
   IS
      SELECT *
        FROM gepd_gmr_element_pledge_detail;
BEGIN
   FOR gepd_temp IN gepd_temp_swap_list
   LOOP
      UPDATE gepd_gmr_element_pledge_detail gepd
         SET GEPD.PLEDGE_QTY = GEPD_TEMP.EXT_PLEDGE_QTY
       WHERE gepd.gepd_id = gepd_temp.gepd_id;
   END LOOP;
END;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE
   CURSOR gepd_temp_gmr
   IS
      SELECT *
        FROM gepd_gmr_element_pledge_detail;
BEGIN
   FOR gepd_temp IN gepd_temp_gmr
   LOOP
      UPDATE gmr_goods_movement_record gmr
         SET gmr.qty = gepd_temp.pledge_qty
       WHERE gmr.internal_gmr_ref_no = gepd_temp.internal_gmr_ref_no;
   END LOOP;
END;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------