create or replace view v_feed_consumption as
select fcr.corporate_name,
       fcr.corporate_id,
       fcr.product_id,
       fcr.product_name,
       fcr.eod_trade_date,
       fcr.quality_id,
       fcr.quality_name,
       sum(fcr.wet_qty) wet_qty,
       max(fcr.gmr_qty_unit) gmr_qty_unit,
       fcr.cp_id,
       fcr.cp_name,
       max(fcr.element_name1) element_name1,
       sum(fcr.contained_element1) contained_element1,
       sum(fcr.payable_element1) payable_element1,
       sum(fcr.rc_element1) rc_element1,
       max(fcr.element_name2) element_name2,
       sum(fcr.contained_element2) contained_element2,
       sum(fcr.payable_element2) payable_element2,
       sum(fcr.rc_element2) rc_element2,
       max(fcr.element_name3) element_name3,
       sum(fcr.contained_element3) contained_element3,
       sum(fcr.payable_element3) payable_element3,
       sum(fcr.rc_element3) rc_element3,
       max(fcr.element_name4) element_name4,
       sum(fcr.contained_element4) contained_element4,
       sum(fcr.payable_element4) payable_element4,
       sum(fcr.rc_element4) rc_element4,
       max(fcr.element_name5) element_name5,
       sum(fcr.contained_element5) contained_element5,
       sum(fcr.payable_element5) payable_element5,
       sum(fcr.rc_element5) rc_element5,
       max(fcr.element_name6) element_name6,
       sum(fcr.contained_element6) contained_element6,
       sum(fcr.payable_element6) payable_element6,
       sum(fcr.rc_element6) rc_element6,
       max(fcr.element_name7) element_name7,
       sum(fcr.contained_element7) contained_element7,
       sum(fcr.payable_element7) payable_element7,
       sum(fcr.rc_element7) rc_element7,
       sum(fcr.tc_amount) tc_amount,
       max(fcr.lv_amount) lv_amount,
       fcr.currency_code,
       max(fcr.pen_element_name1) pen_element_name1,
       sum(fcr.penalty_amount1) penalty_amount1,
       max(fcr.pen_element_name2) pen_element_name2,
       sum(fcr.penalty_amount2) penalty_amount2,
       max(fcr.pen_element_name3) pen_element_name3,
       sum(fcr.penalty_amount3) penalty_amount3,
       max(fcr.pen_element_name4) pen_element_name4,
       sum(fcr.penalty_amount4) penalty_amount4,
       max(fcr.pen_element_name5) pen_element_name5,
       sum(fcr.penalty_amount5) penalty_amount5,
       sum(fcr.others) others
from
(
select fcr.corporate_name,
       fcr.corporate_id,
       fcr.product_id,
       fcr.product_name,
       fcr.eod_trade_date,
       fcr.quality_id,
       fcr.quality_name,
       sum(fcr.gmr_qty) wet_qty,
       fcr.gmr_qty_unit,
       fcr.cp_id,
       fcr.cp_name,
       max(case
             when pay.order_id = 1 then
              pay.element_name|| '(' || qum.qty_unit|| ')'
             else
              ''
           end) element_name1,
       sum(case
             when pay.order_id = 1 then
              fcr.assay_qty
             else
              0
           end) contained_element1,
       sum(case
             when pay.order_id = 1 then
              fcr.payable_qty
             else
              ''
           end) payable_element1,
       sum(case
             when pay.order_id = 1 then
              fcr.rc_amount
             else
              0
           end) rc_element1,
       max(case
             when pay.order_id = 2 then
              pay.element_name|| '(' || qum.qty_unit|| ')'
             else
              ''
           end) element_name2,
       sum(case
             when pay.order_id = 2 then
              fcr.assay_qty
             else
              0
           end) contained_element2,
       sum(case
             when pay.order_id = 2 then
              fcr.payable_qty
             else
              ''
           end) payable_element2,
       sum(case
             when pay.order_id = 2 then
              fcr.rc_amount
             else
              0
           end) rc_element2,
       max(case
             when pay.order_id = 3 then
              pay.element_name|| '(' || qum.qty_unit|| ')'
             else
              ''
           end) element_name3,
       sum(case
             when pay.order_id = 3 then
              fcr.assay_qty
             else
              0
           end) contained_element3,
       sum(case
             when pay.order_id = 3 then
              fcr.payable_qty
             else
              ''
           end) payable_element3,
       sum(case
             when pay.order_id = 3 then
              fcr.rc_amount
             else
              0
           end) rc_element3,
       max(case
             when pay.order_id = 4 then
              pay.element_name|| '(' || qum.qty_unit|| ')'
             else
              ''
           end) element_name4,
       sum(case
             when pay.order_id = 4 then
              fcr.assay_qty
             else
              0
           end) contained_element4,
       sum(case
             when pay.order_id = 4 then
              fcr.payable_qty
             else
              ''
           end) payable_element4,
       sum(case
             when pay.order_id = 4 then
              fcr.rc_amount
             else
              0
           end) rc_element4,
       max(case
             when pay.order_id = 5 then
              pay.element_name|| '(' || qum.qty_unit|| ')'
             else
              ''
           end) element_name5,
       sum(case
             when pay.order_id = 5 then
              fcr.assay_qty
             else
              0
           end) contained_element5,
       sum(case
             when pay.order_id = 5 then
              fcr.payable_qty
             else
              ''
           end) payable_element5,
       sum(case
             when pay.order_id = 5 then
              fcr.rc_amount
             else
              0
           end) rc_element5,
       max(case
             when pay.order_id = 6 then
              pay.element_name|| '(' || qum.qty_unit|| ')'
             else
              ''
           end) element_name6,
       sum(case
             when pay.order_id = 6 then
              fcr.assay_qty
             else
              0
           end) contained_element6,
       sum(case
             when pay.order_id = 6 then
              fcr.payable_qty
             else
              ''
           end) payable_element6,
       sum(case
             when pay.order_id = 6 then
              fcr.rc_amount
             else
              0
           end) rc_element6,
       max(case
             when pay.order_id = 7 then
              pay.element_name|| '(' || qum.qty_unit|| ')'
             else
              ''
           end) element_name7,
       sum(case
             when pay.order_id = 7 then
              fcr.assay_qty
             else
              0
           end) contained_element7,
       sum(case
             when pay.order_id = 7 then
              fcr.payable_qty
             else
              ''
           end) payable_element7,
       sum(case
             when pay.order_id = 7 then
              fcr.rc_amount
             else
              0
           end) rc_element7,
       sum(fcr.tc_amount) tc_amount,
       fcr.inv_add_charges lv_amount,
       fcr.invoice_cur_code currency_code,
       null pen_element_name1,
       null penalty_amount1,
       null pen_element_name2,
       null penalty_amount2,
       null pen_element_name3,
       null penalty_amount3,
       null pen_element_name4,
       null penalty_amount4,
       null pen_element_name5,
       null penalty_amount5,
       null others
  from fcr_feed_consumption_report fcr,
       cpe_corp_payble_element     pay,
       tdc_trade_date_closure      tdc,
       aml_attribute_master_list aml,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master qum,
       pdm_productmaster pdm
 where fcr.process_id = tdc.process_id
   and fcr.corporate_id = tdc.corporate_id
   and tdc.process = 'EOM'
   and fcr.corporate_id = pay.corporate_id(+)
   and fcr.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm.product_id
   and fcr.payable_qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and fcr.element_id = pay.element_id(+)
 group by fcr.product_id,
          fcr.product_name,
          fcr.corporate_id,
          fcr.quality_id,
          fcr.quality_name,
          fcr.gmr_qty_unit,
          fcr.cp_id,
          fcr.cp_name,
          fcr.invoice_cur_code,
          fcr.eod_trade_date,
          fcr.corporate_name,
          fcr.inv_add_charges
union all

select fcr.corporate_name,
       fcr.corporate_id,
       fcr.product_id,
       fcr.product_name,
       fcr.eod_trade_date,
       fcr.quality_id,
       fcr.quality_name,
       0 wet_qty,
       null gmr_qty_unit,
       fcr.cp_id,
       fcr.cp_name,
       null element_name1,
       null contained_element1,
       null payable_element1,
       null rc_element1,
       null element_name2,
       null contained_element2,
       null payable_element2,
       null rc_element2,
       null element_name3,
       null contained_element3,
       null payable_element3,
       null rc_element3,
       null element_name4,
       null contained_element4,
       null payable_element4,
       null rc_element4,
       null element_name5,
       null contained_element5,
       null payable_element5,
       null rc_element5,
       null element_name6,
       null contained_element6,
       null payable_element6,
       null rc_element6,
       null element_name7,
       null contained_element7,
       null payable_element7,
       null rc_element7,
       null tc_amount,
       null lv_amount,
       fcr.invoice_cur_code currency_code,
       max(case
             when pen.order_id = 1 then
              pen.element_name
             else
              ''
           end) pen_element_name1,
       sum(case
             when pen.order_id = 1 then
              fcr.penality_amount
             else
              0
           end) penalty_amount1,
       max(case
             when pen.order_id = 2 then
              pen.element_name
             else
              ''
           end) pen_element_name2,
       sum(case
             when pen.order_id = 2 then
              fcr.penality_amount
             else
              0
           end) penalty_amount2,
       max(case
             when pen.order_id = 3 then
              pen.element_name
             else
              ''
           end) pen_element_name3,
       sum(case
             when pen.order_id = 3 then
              fcr.penality_amount
             else
              0
           end) penalty_amount3,
       max(case
             when pen.order_id = 4 then
              pen.element_name
             else
              ''
           end) pen_element_name4,
       sum(case
             when pen.order_id = 4 then
              fcr.penality_amount
             else
              0
           end) penalty_amount4,
       max(case
             when pen.order_id = 5 then
              pen.element_name
             else
              ''
           end) pen_element_name5,
       sum(case
             when pen.order_id = 5 then
              fcr.penality_amount
             else
              0
           end) penalty_amount5,
       sum(case
             when pen.order_id > 5 then
              fcr.penality_amount
             else
              0
           end) others
  from fcr_feed_consumption_report fcr,
       cpe_corp_penality_element   pen,
       tdc_trade_date_closure      tdc,
       aml_attribute_master_list aml,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master qum,
       pdm_productmaster pdm
 where fcr.process_id = tdc.process_id
   and fcr.corporate_id = tdc.corporate_id
   and tdc.process = 'EOM'
   and fcr.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm.product_id
   and fcr.payable_qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and fcr.element_id = pen.element_id(+)
 group by fcr.product_id,
          fcr.product_name,
          fcr.corporate_id,
          fcr.quality_id,
          fcr.quality_name,
          fcr.gmr_qty_unit,
          fcr.cp_id,
          fcr.cp_name,
          fcr.invoice_cur_code,
          fcr.eod_trade_date,
          fcr.corporate_name
          )fcr
group by
fcr.corporate_name,
       fcr.product_id,
       fcr.corporate_id,
       fcr.product_name,
       fcr.eod_trade_date,
       fcr.quality_id,
       fcr.quality_name,
       fcr.cp_id,
       fcr.cp_name,
       fcr.currency_code

