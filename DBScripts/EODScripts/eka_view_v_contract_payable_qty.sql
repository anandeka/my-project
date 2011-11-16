CREATE OR REPLACE  VIEW v_contract_payable_qty
AS
   SELECT   t.internal_contract_item_ref_no, t.element_id,
            SUM (t.payable_qty) payable_qty,
            t.qty_unit_id payable_qty_unit_id, t.process_id
       FROM (SELECT pci.internal_contract_item_ref_no, cipq.element_id,
                    cipq.payable_qty, cipq.qty_unit_id, pci.process_id
               FROM pci_physical_contract_item pci,
                    pcdi_pc_delivery_item pcdi,
                    cipq_contract_item_payable_qty cipq
              WHERE pci.pcdi_id = pcdi.pcdi_id
                AND pci.internal_contract_item_ref_no =
                                            cipq.internal_contract_item_ref_no
                AND pci.process_id = pcdi.process_id
                AND pcdi.process_id = cipq.process_id
                AND pci.is_active = 'Y'
                AND pcdi.is_active = 'Y'
                AND cipq.is_active = 'Y'
             UNION ALL
             SELECT pci.internal_contract_item_ref_no, spq.element_id,
                    spq.payable_qty, spq.qty_unit_id, pci.process_id
               FROM pci_physical_contract_item pci,
                    pcdi_pc_delivery_item pcdi,
                    grd_goods_record_detail grd,
                    spq_stock_payable_qty spq
              WHERE pci.pcdi_id = pcdi.pcdi_id
                AND pci.internal_contract_item_ref_no =
                                             grd.internal_contract_item_ref_no
                AND spq.internal_gmr_ref_no = grd.internal_gmr_ref_no
                AND pci.process_id = pcdi.process_id
                AND pcdi.process_id = spq.process_id
                AND spq.process_id = grd.process_id
                AND pci.is_active = 'Y'
                AND pcdi.is_active = 'Y'
                AND spq.is_active = 'Y') t
   GROUP BY t.internal_contract_item_ref_no,
            t.element_id,
            t.qty_unit_id,
            t.process_id;

