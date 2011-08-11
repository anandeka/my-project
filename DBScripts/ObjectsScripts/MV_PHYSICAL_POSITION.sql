CREATE OR REPLACE VIEW MV_PHYSICAL_POSITION AS
select v_pci.strategy strategy_name,
       v_pci.comp_product_name,
       v_pci.comp_quality,
       (case
         when v_pci.purchase_sales = 'P' then
          'Purchase'
         else
          'Sales'
       end) contract_type,
       v_pci.product_name product_desc,
       v_pci.profit_center_id,
       v_pci.profit_center profit_center_name,
       v_pci.business_line business_line_name,
       null origin_name,
       v_pci.incoterm,
       v_pci.product_type_name,
       v_pci.quality quality_name,
       v_pci.corporate_name,
       v_pci.contract_ref_no,
       to_char(v_pci.delivery_date, 'dd/mm/yyyy') delivery_date,
       sum(case
             when trunc(v_pci.delivery_date) > trunc(sysdate) then
              v_pci.item_open_qty * v_pci.compqty_base_conv_rate
             else
              0
           end) open_qty,
       sum(case
             when trunc(v_pci.delivery_date) < trunc(sysdate) then
              v_pci.item_open_qty * v_pci.compqty_base_conv_rate
             else
              0
           end) previous_pending_qty,
       0 afloat_qty,
       0 stock_qty,
       v_pci.comp_base_qty_unit_id qty_unit_id,
       v_pci.comp_base_qty_unit qty_unit,
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
       v_pci.attribute_id,
       pdm.product_group_id
  from v_pci_quantity_details v_pci,
       pdm_productmaster      pdm
 where v_pci.contract_row = 1
   and v_pci.product_id = pdm.product_id
 group by v_pci.strategy,
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
          pdm.product_group_id,
          v_pci.attribute_id
-------
union all
select v_pci.strategy strategy_name,
       v_pci.comp_product_name,
       v_pci.comp_quality,
       (case
         when v_pci.purchase_sales = 'P' then
          'Purchase'
         else
          'Sales'
       end) contract_type,
       v_pci.product_name product_desc,
       v_pci.profit_center_id,
       v_pci.profit_center profit_center_name,
       v_pci.business_line business_line_name,
       null origin_name,
       nvl(v_pci.incoterm, 'NA') incoterm,
       v_pci.product_type_name,
       v_pci.quality quality_name,
       v_pci.corporate_name,
       v_pci.gmr_ref_no contract_ref_no,
       to_char(v_pci.delivery_date, 'dd/mm/yyyy')delivery_date,--v_pci.delivery_date,
       0 open_qty, --element qty
       0 previous_pending_qty,
       sum(case
             when v_pci.subsectionname = 'Afloat' then
              v_pci.item_open_qty * v_pci.compqty_base_conv_rate
             else
              0
           end) afloat_qty,
       sum(case
             when v_pci.subsectionname = 'Stock' then
              v_pci.item_open_qty * v_pci.compqty_base_conv_rate
             else
              0
           end) stock_qty,
       v_pci.comp_base_qty_unit_id qty_unit_id,
       v_pci.comp_base_qty_unit qty_unit,
       v_pci.position_type,
       v_pci.corporate_id,
       v_pci.groupid,
       v_pci.business_line_id,
       v_pci.strategy_id,
       v_pci.product_id,
       v_pci.quality_id,
       v_pci.trader_id,
       null incoterm_id,
       v_pci.country_id,
       v_pci.country_name,
       v_pci.city_id,
       v_pci.city_name,
       v_pci.product_type_id,
       v_pci.assay_header_id,
       v_pci.attribute_id,
       pdm.product_group_id
  from v_gmr_stock_details v_pci,
       pdm_productmaster   pdm
 where v_pci.contract_row = 1
   and v_pci.product_id = pdm.product_id
 group by v_pci.strategy,
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
          v_pci.gmr_ref_no,
          v_pci.delivery_date,
          v_pci.contract_row,
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
          v_pci.country_id,
          v_pci.country_name,
          v_pci.city_id,
          v_pci.city_name,
          v_pci.product_type_id,
          v_pci.assay_header_id,
          v_pci.attribute_id,
          pdm.product_group_id
