CREATE OR REPLACE VIEW V_BI_MB_TOP5_BY_SUP_ACCOUNT AS
select corporate_id,
       product_id,
       product_name,
       supplier_id,
       supplier_name,
       quantity,
       base_qty_unit_id,
       base_qty_unit,
       order_id
  from (select vma.corporate_id,
               vma.product_id,
               vma.product_name,
               vma.supplier_id,
               vma.supplier_name,
               vma.total_qty quantity,
               vma.qty_unit_id base_qty_unit_id,
               vma.qty_unit base_qty_unit,
               rank() over(partition by vma.corporate_id, vma.product_name order by vma.total_qty desc) order_id
          from v_metal_accounts vma)
 where order_id <= 5
