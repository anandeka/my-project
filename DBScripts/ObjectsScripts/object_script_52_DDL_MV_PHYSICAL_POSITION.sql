CREATE OR REPLACE VIEW MV_PHYSICAL_POSITION AS
SELECT   v_pci.strategy strategy_name, v_pci.comp_product_name,
            v_pci.comp_quality,
            (CASE
                WHEN v_pci.purchase_sales = 'P'
                   THEN 'Purchase'
                ELSE 'Sales'
             END
            ) contract_type,
            v_pci.product_name product_desc, v_pci.profit_center_id,
            v_pci.profit_center profit_center_name,
            v_pci.business_line business_line_name, NULL origin_name,
            v_pci.incoterm, v_pci.product_type_name,
            v_pci.quality quality_name, v_pci.corporate_name,
            v_pci.contract_ref_no, to_char(v_pci.delivery_date,'dd/mm/yyyy')delivery_date,
            SUM
               (CASE
                   WHEN TRUNC (v_pci.delivery_date) > TRUNC (SYSDATE)
                      THEN v_pci.item_open_qty * v_pci.compqty_base_conv_rate
                   ELSE 0
                END
               ) open_qty,
            SUM
               (CASE
                   WHEN TRUNC (v_pci.delivery_date) < TRUNC (SYSDATE)
                      THEN v_pci.item_open_qty * v_pci.compqty_base_conv_rate
                   ELSE 0
                END
               ) previous_pending_qty,
            0 afloat_qty, 0 stock_qty,
            v_pci.comp_base_qty_unit_id qty_unit_id,
            v_pci.comp_base_qty_unit qty_unit, v_pci.position_type,
            v_pci.corporate_id, v_pci.groupid, v_pci.business_line_id,
            v_pci.strategy_id, v_pci.product_id, v_pci.quality_id,
            v_pci.trader_id, v_pci.incoterm_id, v_pci.country_id,
            v_pci.country_name, v_pci.city_id, v_pci.city_name,
            v_pci.product_type_id, v_pci.assay_header_id, v_pci.attribute_id
       FROM v_pci_quantity_details v_pci
      WHERE v_pci.contract_row = 1
   GROUP BY v_pci.strategy,
            v_pci.comp_product_name,
            v_pci.comp_quality,
            v_pci.purchase_sales,
            v_pci.product_name,
            v_pci.profit_center_id,
            v_pci.profit_center,
            v_pci.business_line,
            v_pci.incoterm,
            v_pci.product_type_name,
            v_pci.quality,
            v_pci.corporate_name,
            v_pci.contract_ref_no,
            v_pci.delivery_date,
            v_pci.comp_base_qty_unit_id,
            v_pci.comp_base_qty_unit,
            v_pci.position_type,
            v_pci.corporate_id,
            v_pci.groupid,
            v_pci.business_line_id,
            v_pci.strategy_id,
            v_pci.product_id,
            v_pci.quality_id,
            v_pci.trader_id,
            v_pci.incoterm_id,
            v_pci.country_id,
            v_pci.country_name,
            v_pci.city_id,
            v_pci.city_name,
            v_pci.product_type_id,
            v_pci.assay_header_id,
            v_pci.attribute_id 
