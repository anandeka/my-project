--Price Allocation

DECLARE
   pricestatus             VARCHAR2 (100) := '';
   total_elem_count        VARCHAR2 (100) := '';
   finalised_elem_count    VARCHAR2 (100) := '';
   totalqtytobeallocated   VARCHAR2 (100) := '';
   totalallocatedqty       VARCHAR2 (100) := '';

   CURSOR intgmr_cursor
   IS
     SELECT gmr.internal_gmr_ref_no AS internalgmrref
  FROM gmr_goods_movement_record gmr
 WHERE gmr.internal_gmr_ref_no IN (SELECT DISTINCT (gpah.internal_gmr_ref_no
                                                   )
                                              FROM gpah_gmr_price_alloc_header gpah
                                             WHERE gpah.is_active = 'Y')
   AND gmr.is_deleted = 'N'
   AND gmr.is_pass_through = 'N';
BEGIN
   FOR intgmr_cursor_rows IN intgmr_cursor
   LOOP
      SELECT   SUM (CASE
                       WHEN poch.element_id IS NOT NULL
                          THEN 1
                       ELSE 0
                    END) total_elem_count,
               SUM (CASE
                       WHEN gpah.final_price > 0
                          THEN 1
                       ELSE 0
                    END) finalised_elem_count,
               SUM (ROUND (NVL (gpah.total_qty_to_be_allocated, 0), 2))
                                                        totalqtytobeallocated,
               SUM (ROUND ((NVL (gpah.total_allocated_qty, 0)), 2))
                                                            totalallocatedqty
          INTO total_elem_count,
               finalised_elem_count,
               totalqtytobeallocated,
               totalallocatedqty
          FROM poch_price_opt_call_off_header poch,
               pocd_price_option_calloff_dtls pocd,
               gpah_gmr_price_alloc_header gpah
         WHERE poch.poch_id = pocd.poch_id
           AND pocd.pocd_id = gpah.pocd_id(+)
           AND gpah.internal_gmr_ref_no = intgmr_cursor_rows.internalgmrref
           AND poch.is_active = 'Y'
           AND pocd.is_active = 'Y'
           AND gpah.is_active = 'Y'
      ORDER BY gpah.internal_gmr_ref_no,
               poch.element_id,
               gpah.total_allocated_qty,
               gpah.final_price;

      IF (total_elem_count = finalised_elem_count)
      THEN
         pricestatus := 'Price Finalized';
      ELSE
         IF (totalqtytobeallocated = 0)
         THEN
            pricestatus := 'Unpriced';
         ELSE
            IF (totalqtytobeallocated = totalallocatedqty)
            THEN
               pricestatus := 'Fully Priced';
            ELSE
               pricestatus := 'Partially Priced';
            END IF;
         END IF;
      END IF;

      UPDATE gmr_goods_movement_record gmr
         SET gmr.latest_pricing_status = pricestatus
       WHERE gmr.internal_gmr_ref_no = intgmr_cursor_rows.internalgmrref;
   END LOOP;
END;


--------------------------------------------------------------------------


--Weighted Average  

DECLARE
   price_status           VARCHAR2 (100) := '';
   total_elem_count       VARCHAR2 (100) := '';
   finalised_elem_count   VARCHAR2 (100) := '';
   qty_to_be_fixed        VARCHAR2 (100) := '';
   qty_fixed              VARCHAR2 (100) := '';
   hedge_correction_qty   VARCHAR2 (100) := '';
   internal_gmr_ref_no    VARCHAR2 (100) := '';

   CURSOR pcdi_cursor
   IS
      SELECT DISTINCT (pcdi.pcdi_id) AS pcdiid
                 FROM pcdi_pc_delivery_item pcdi,
                      poch_price_opt_call_off_header poch
                WHERE pcdi.pcdi_id IN (
                         SELECT DISTINCT (grd.pcdi_id) AS pcdiid
                                    FROM grd_goods_record_detail grd,
                                         gmr_goods_movement_record gmr
                                   WHERE grd.status = 'Active'
                                     AND grd.is_deleted = 'N'
                                     AND grd.tolling_stock_type IN
                                              ('None Tolling', 'Clone Stock')
                                     AND gmr.internal_gmr_ref_no =
                                                       grd.internal_gmr_ref_no
                                     AND gmr.is_deleted = 'N'
                                     AND gmr.is_internal_movement = 'N'
                                     AND gmr.is_pass_through = 'N'
                                     AND gmr.latest_pricing_status IS NULL
                         UNION ALL
                         SELECT DISTINCT (dgrd.pcdi_id) AS pcdiid
                                    FROM dgrd_delivered_grd dgrd,
                                         gmr_goods_movement_record gmr
                                   WHERE dgrd.status = 'Active'
                                     AND dgrd.tolling_stock_type IN
                                              ('None Tolling', 'Clone Stock')
                                     AND dgrd.status = 'Active'
                                     AND gmr.internal_gmr_ref_no =
                                                      dgrd.internal_gmr_ref_no
                                     AND gmr.is_deleted = 'N'
                                     AND gmr.is_internal_movement = 'N'
                                     AND gmr.is_pass_through = 'N'
                                     AND gmr.latest_pricing_status IS NULL)
                  AND pcdi.pcdi_id = poch.pcdi_id
                  AND poch.is_balance_pricing = 'N'
                  AND poch.is_active = 'Y'
                  AND pcdi.is_active = 'Y';
BEGIN
   FOR pcdi_cursor_rows IN pcdi_cursor
   LOOP
      SELECT SUM (CASE
                     WHEN poch.element_id IS NOT NULL
                        THEN 1
                     ELSE 0
                  END) total_elem_count,
             SUM (CASE
                     WHEN pofh.final_price > 0
                        THEN 1
                     ELSE 0
                  END) finalised_elem_count,
             SUM (ROUND (NVL (pofh.qty_to_be_fixed, 0), 2)) qty_to_be_fixed,
             SUM (ROUND (NVL (pofh.priced_qty, 0), 2)) qty_fixed,
             SUM (ROUND (NVL (pofh.hedge_correction_qty, 0), 2))
                                                         hedge_correction_qty
        INTO total_elem_count,
             finalised_elem_count,
             qty_to_be_fixed,
             qty_fixed,
             hedge_correction_qty
        FROM poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh
       WHERE poch.pcdi_id = pcdi_cursor_rows.pcdiid
         AND poch.poch_id = pocd.poch_id
         AND pocd.pocd_id = pofh.pocd_id
         AND pofh.is_active = 'Y'
         AND pocd.is_active = 'Y'
         AND poch.is_active = 'Y'
         AND poch.is_balance_pricing = 'N';

      IF (total_elem_count = finalised_elem_count)
      THEN
         price_status := 'Price Finalized';
      ELSE
         IF (qty_to_be_fixed = 0)
         THEN
            price_status := 'UnPriced';
         ELSE
            IF (qty_to_be_fixed =
                   ROUND (  NVL (qty_to_be_fixed, 0)
                          + NVL (hedge_correction_qty, 0)
                         )
               )
            THEN
               price_status := 'Fully Priced';
            ELSE
               price_status := 'Partially Priced';
            END IF;
         END IF;
      END IF;

      DECLARE
         CURSOR gmr_cursor
         IS
            SELECT DISTINCT (grd.internal_gmr_ref_no)
                       INTO internal_gmr_ref_no
                       FROM grd_goods_record_detail grd,
                            gmr_goods_movement_record gmr
                      WHERE grd.pcdi_id = pcdi_cursor_rows.pcdiid
                        AND grd.is_deleted = 'N'
                        AND grd.tolling_stock_type IN
                                              ('None Tolling', 'Clone Stock')
                        AND grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                        AND gmr.contract_type != 'B2B'
            UNION ALL
            SELECT DISTINCT (dgrd.internal_gmr_ref_no)
                       FROM dgrd_delivered_grd dgrd
                      WHERE dgrd.pcdi_id = pcdi_cursor_rows.pcdiid
                        AND dgrd.tolling_stock_type IN
                                              ('None Tolling', 'Clone Stock');
      BEGIN
         FOR gmr_cursor_rows IN gmr_cursor
         LOOP
            UPDATE gmr_goods_movement_record gmr
               SET gmr.latest_pricing_status = price_status
             WHERE gmr.internal_gmr_ref_no =
                                           gmr_cursor_rows.internal_gmr_ref_no;
         END LOOP;
      END;
   END LOOP;
END;


-------------------------------------------------



--Balance Pricing


DECLARE
   price_status           VARCHAR2 (100) := '';
   total_elem_count       VARCHAR2 (100) := '';
   finalised_elem_count   VARCHAR2 (100) := '';
   qty_to_be_fixed        VARCHAR2 (100) := '';
   qty_fixed              VARCHAR2 (100) := '';
   hedge_correction_qty   VARCHAR2 (100) := '';
   internal_gmr_ref_no    VARCHAR2 (100) := '';

   CURSOR pcdi_cursor
   IS
      SELECT DISTINCT (pcdi.pcdi_id) AS pcdiid
                 FROM pcdi_pc_delivery_item pcdi,
                      poch_price_opt_call_off_header poch
                WHERE pcdi.pcdi_id IN (
                         SELECT DISTINCT (grd.pcdi_id) AS pcdiid
                                    FROM grd_goods_record_detail grd,
                                         gmr_goods_movement_record gmr
                                   WHERE grd.status = 'Active'
                                     AND grd.is_deleted = 'N'
                                     AND grd.tolling_stock_type IN
                                              ('None Tolling', 'Clone Stock')
                                     AND gmr.internal_gmr_ref_no =
                                                       grd.internal_gmr_ref_no
                                     AND gmr.is_deleted = 'N'
                                     AND gmr.is_internal_movement = 'N'
                                     AND gmr.is_pass_through = 'N'
                                     AND gmr.latest_pricing_status IS NULL
                         UNION ALL
                         SELECT DISTINCT (dgrd.pcdi_id) AS pcdiid
                                    FROM dgrd_delivered_grd dgrd,
                                         gmr_goods_movement_record gmr
                                   WHERE dgrd.status = 'Active'
                                     AND dgrd.tolling_stock_type IN
                                              ('None Tolling', 'Clone Stock')
                                     AND dgrd.status = 'Active'
                                     AND gmr.internal_gmr_ref_no =
                                                      dgrd.internal_gmr_ref_no
                                     AND gmr.is_deleted = 'N'
                                     AND gmr.is_internal_movement = 'N'
                                     AND gmr.is_pass_through = 'N'
                                     AND gmr.latest_pricing_status IS NULL)
                  AND pcdi.pcdi_id = poch.pcdi_id
                  AND poch.is_balance_pricing = 'Y'
                  AND poch.is_active = 'Y'
                  AND pcdi.is_active = 'Y';
BEGIN
   FOR pcdi_cursor_rows IN pcdi_cursor
   LOOP
      SELECT SUM (CASE
                     WHEN poch.element_id IS NOT NULL
                        THEN 1
                     ELSE 0
                  END) total_elem_count,
             SUM (CASE
                     WHEN pofh.final_price > 0
                        THEN 1
                     ELSE 0
                  END) finalised_elem_count,
             SUM (ROUND (NVL (pofh.qty_to_be_fixed, 0), 2)) qty_to_be_fixed,
             SUM (ROUND (NVL (pofh.priced_qty, 0), 2)) qty_fixed,
             SUM (ROUND (NVL (pofh.balance_priced_qty, 0), 2))
                                                         hedge_correction_qty
        INTO total_elem_count,
             finalised_elem_count,
             qty_to_be_fixed,
             qty_fixed,
             hedge_correction_qty
        FROM poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh
       WHERE poch.pcdi_id = pcdi_cursor_rows.pcdiid
         AND poch.poch_id = pocd.poch_id
         AND pocd.pocd_id = pofh.pocd_id
         AND pofh.is_active = 'Y'
         AND pocd.is_active = 'Y'
         AND poch.is_active = 'Y'
         AND poch.is_balance_pricing = 'Y';

      IF (total_elem_count = finalised_elem_count)
      THEN
         price_status := 'Price Finalized';
      ELSE
         IF (qty_to_be_fixed = 0)
         THEN
            price_status := 'UnPriced';
         ELSE
            IF (qty_to_be_fixed =
                   ROUND (  NVL (qty_to_be_fixed, 0)
                          + NVL (hedge_correction_qty, 0)
                         )
               )
            THEN
               price_status := 'Fully Priced';
            ELSE
               price_status := 'Partially Priced';
            END IF;
         END IF;
      END IF;

      DECLARE
         CURSOR gmr_cursor
         IS
            SELECT DISTINCT (grd.internal_gmr_ref_no)
                       INTO internal_gmr_ref_no
                       FROM grd_goods_record_detail grd,
                            gmr_goods_movement_record gmr
                      WHERE grd.pcdi_id = pcdi_cursor_rows.pcdiid
                        AND grd.is_deleted = 'N'
                        AND grd.tolling_stock_type IN
                                              ('None Tolling', 'Clone Stock')
                        AND grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                        AND gmr.contract_type != 'B2B'
                        AND gmr.is_deleted = 'N'
                        AND gmr.is_internal_movement = 'N'
                        AND gmr.is_pass_through = 'N'
            UNION ALL
            SELECT DISTINCT (dgrd.internal_gmr_ref_no)
                       FROM dgrd_delivered_grd dgrd
                      WHERE dgrd.pcdi_id = pcdi_cursor_rows.pcdiid
                        AND dgrd.tolling_stock_type IN
                                              ('None Tolling', 'Clone Stock');
      BEGIN
         FOR gmr_cursor_rows IN gmr_cursor
         LOOP
            UPDATE gmr_goods_movement_record gmr
               SET gmr.latest_pricing_status = price_status
             WHERE gmr.internal_gmr_ref_no =
                                           gmr_cursor_rows.internal_gmr_ref_no;
         END LOOP;
      END;
   END LOOP;
END;