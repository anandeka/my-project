create or replace view v_bi_phy_position_by_product as
select b.corporate_id,
       b.product_id,
       b.product_name,
       sum(b.position_long) position_long,
       sum(b.position_short) position_short,
       sum(b.position_stock) position_stock,
       sum(b.position_inprocess) position_inprocess,
       sum(b.position_net) position_net,
       b.base_qty_unit_id,
       b.base_qty_unit
  from (select pci.corporate_id,
               pci.product_id,
               pci.product_name product_name,
               (case
                 when pci.contract_type = 'P' then
                  pci.open_qty * pci.qty_conv
                 else
                  0
               end) position_long,
               (case
                 when pci.contract_type = 'S' then
                  pci.open_qty * pci.qty_conv
                 else
                  0
               end) position_short,
               0 position_stock,
               0 position_inprocess,
               pci.pos_sign * pci.open_qty * pci.qty_conv position_net,
               pci.base_qty_unit_id,
               pci.base_qty_unit base_qty_unit
          from v_bi_contract_open_position pci
        union all
        select gmr.corporate_id,
               gmr.product_id,
               gmr.product_desc product_name,
               0 position_long,
               0 position_short,
               (case
                 when gmr.position_status = 'Stock' then
                  gmr.current_qty * gmr.pos_sign * gmr.qty_conv
                 else
                  0
               end) position_stock,
               (case
                 when gmr.position_status = 'In Process' then
                  gmr.current_qty * gmr.pos_sign * gmr.qty_conv
                 else
                  0
               end) position_inprocess,
               (case
                 when gmr.position_status in ('Stock', 'In Process') then
                  gmr.current_qty * gmr.pos_sign * gmr.qty_conv
                 else
                  0
               end) position_net,
               base_qty_unit_id,
               base_qty_unit
          from v_bi_gmr_stock_details gmr) b
 group by b.corporate_id,
          b.product_id,
          b.product_name,
          b.base_qty_unit_id,
          b.base_qty_unit
 order by sum(b.position_net) desc
/