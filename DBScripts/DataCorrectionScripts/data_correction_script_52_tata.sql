/* Formatted on 2013/07/23 19:35 (Formatter Plus v4.8.8) */
DECLARE
   CURSOR ciqs_cursor
   IS
      (SELECT ABS (ciqsl.open_qty_delta) AS qty, temp.ciqsid AS ciqsid
         FROM (SELECT   MAX (ciqsl.VERSION) AS versionno,
                        ciqsl.ciqs_id AS ciqsid
                   FROM pci_physical_contract_item pci,
                        ciqsl_contract_itm_qty_sts_log ciqsl
                  WHERE pci.item_status = 'Fullfilled'
                    AND ciqsl.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
                    AND ciqsl.open_qty_delta <> 0
               GROUP BY ciqsl.ciqs_id) temp,
              ciqsl_contract_itm_qty_sts_log ciqsl
        WHERE temp.ciqsid = ciqsl.ciqs_id AND temp.versionno = ciqsl.VERSION);
BEGIN
   FOR ciqs_cursor_row IN ciqs_cursor
   LOOP
      UPDATE ciqs_contract_item_qty_status ciqs
         SET ciqs.fulfilled_qty = ciqs_cursor_row.qty
       WHERE ciqs.ciqs_id = ciqs_cursor_row.ciqsid;
   END LOOP;
END;

DECLARE
   CURSOR pcdi_cursor
   IS
      SELECT   SUM (ciqs.fulfilled_qty) AS qty, pci.pcdi_id AS pcdiid
          FROM pci_physical_contract_item pci,
               ciqs_contract_item_qty_status ciqs
         WHERE pci.item_status = 'Fullfilled'
           AND ciqs.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
      GROUP BY pci.pcdi_id;
BEGIN
   FOR pcdi_cursor_rows IN pcdi_cursor
   LOOP
      UPDATE diqs_delivery_item_qty_status diqs
         SET diqs.fulfilled_qty = (diqs.fulfilled_qty + pcdi_cursor_rows.qty),
             diqs.open_qty = (diqs.open_qty - pcdi_cursor_rows.qty)
       WHERE diqs.pcdi_id = pcdi_cursor_rows.pcdiid;
   END LOOP;
END;