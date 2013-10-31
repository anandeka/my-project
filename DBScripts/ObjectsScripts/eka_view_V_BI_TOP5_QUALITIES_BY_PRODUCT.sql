create or replace view v_bi_top5_qualities_by_product as
select tt.corporate_id,
       tt.product_id,
       tt.product_name,
       tt.quality_id,
       tt.quality_name,
       tt.position_open,
       tt.position_stock,
       tt.position_inprocess,
       tt.base_qty_unit_id,
       tt.base_qty_unit,
       tt.order_seq
  from (select t.corporate_id,
               t.product_id,
               t.product_name,
               t.quality_id,
               t.quality_name,
               sum(t.position_open) position_open,
               sum(t.position_stock) position_stock,
               sum(t.position_inprocess) position_inprocess,
               t.base_qty_unit_id,
               t.base_qty_unit,
               rank() over(partition by t.corporate_id, t.product_name order by sum(t.position_net) desc) order_seq
          from (select pci.corporate_id,
                       pci.product_id,
                       pci.product_name,
                       pci.quality_id,
                       pci.quality_name,
                       sum(pci.pos_sign * pci.open_qty * pci.qty_conv) position_open,
                       0 position_stock,
                       0 position_inprocess,
                       sum(pci.pos_sign * pci.open_qty * pci.qty_conv) position_net,
                       pci.base_qty_unit_id,
                       pci.base_qty_unit
                  from v_bi_contract_open_position pci
                 group by pci.corporate_id,
                          pci.product_id,
                          pci.product_name,
                          pci.quality_id,
                          pci.quality_name,
                          pci.base_qty_unit_id,
                          pci.base_qty_unit
                union all
                select gmr.corporate_id,
                       gmr.product_id,
                       gmr.product_desc product_name,
                       gmr.quality_id,
                       gmr.quality_name,
                       0 position_open,
                       sum(case
                             when gmr.position_status = 'Stock' then
                              gmr.current_qty * gmr.pos_sign * gmr.qty_conv
                             else
                              0
                           end) position_stock,
                       sum(case
                             when gmr.position_status = 'In Process' then
                              gmr.current_qty * gmr.pos_sign * gmr.qty_conv
                             else
                              0
                           end) position_inprocess,
                       sum(case
                             when gmr.position_status in ('Stock', 'In Process') then
                              gmr.current_qty * gmr.pos_sign * gmr.qty_conv
                             else
                              0
                           end) position_net,
                       gmr.base_qty_unit_id,
                       gmr.base_qty_unit
                  from v_bi_gmr_stock_details gmr
                 group by gmr.corporate_id,
                          gmr.product_id,
                          gmr.product_desc,
                          gmr.quality_id,
                          gmr.quality_name,
                          gmr.base_qty_unit_id,
                          gmr.base_qty_unit) t
         group by t.corporate_id,
                  t.product_id,
                  t.product_name,
                  t.quality_id,
                  t.quality_name,
                  t.base_qty_unit_id,
                  t.base_qty_unit) tt
 where tt.order_seq < 6
/