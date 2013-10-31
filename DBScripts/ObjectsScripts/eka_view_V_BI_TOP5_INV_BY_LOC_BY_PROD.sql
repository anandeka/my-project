create or replace view v_bi_top5_inv_by_loc_by_prod as
select t.corporate_id,
       t.product_id,
       t.product_name,
       t.city_name,
       t.position_stock,
       t.position_inprocess,
       t.tot_qty,
       t.base_qty_unit_id,
       t.base_qty_unit,
       t.order_seq
  from (select gmr.corporate_id,
               gmr.product_id,
               gmr.product_desc product_name,
               gmr.loc_city_name city_name,
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
               sum(gmr.current_qty * gmr.pos_sign * gmr.qty_conv) tot_qty,
               gmr.base_qty_unit_id,
               gmr.base_qty_unit,
               rank() over(partition by gmr.corporate_id, gmr.product_desc order by sum(gmr.current_qty * gmr.pos_sign * gmr.qty_conv) desc) order_seq
          from v_bi_gmr_stock_details gmr
         where gmr.current_qty <> 0
           and gmr.position_status in ('Stock', 'In Process')
         group by gmr.corporate_id,
                  gmr.product_id,
                  gmr.product_desc,
                  gmr.loc_city_name,
                  gmr.base_qty_unit_id,
                  gmr.base_qty_unit) t
 where t.order_seq < 6
/