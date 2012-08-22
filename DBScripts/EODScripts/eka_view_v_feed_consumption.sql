CREATE OR REPLACE VIEW v_feed_consumption AS
   SELECT fcr.corporate_name,
          fcr.corporate_id,
          fcr.product_id,
          fcr.product_name,
          fcr.eod_trade_date,
          fcr.quality_id,
          fcr.quality_name,
          SUM(fcr.wet_qty) wet_qty,
          MAX(fcr.gmr_qty_unit) gmr_qty_unit,
          fcr.cp_id,
          fcr.cp_name,
          MAX(fcr.element_name1) element_name1,
          SUM(fcr.contained_element1) contained_element1,
          SUM(fcr.payable_element1) payable_element1,
          SUM(fcr.rc_element1) rc_element1,
          MAX(fcr.element_name2) element_name2,
          SUM(fcr.contained_element2) contained_element2,
          SUM(fcr.payable_element2) payable_element2,
          SUM(fcr.rc_element2) rc_element2,
          MAX(fcr.element_name3) element_name3,
          SUM(fcr.contained_element3) contained_element3,
          SUM(fcr.payable_element3) payable_element3,
          SUM(fcr.rc_element3) rc_element3,
          MAX(fcr.element_name4) element_name4,
          SUM(fcr.contained_element4) contained_element4,
          SUM(fcr.payable_element4) payable_element4,
          SUM(fcr.rc_element4) rc_element4,
          MAX(fcr.element_name5) element_name5,
          SUM(fcr.contained_element5) contained_element5,
          SUM(fcr.payable_element5) payable_element5,
          SUM(fcr.rc_element5) rc_element5,
          MAX(fcr.element_name6) element_name6,
          SUM(fcr.contained_element6) contained_element6,
          SUM(fcr.payable_element6) payable_element6,
          SUM(fcr.rc_element6) rc_element6,
          MAX(fcr.element_name7) element_name7,
          SUM(fcr.contained_element7) contained_element7,
          SUM(fcr.payable_element7) payable_element7,
          SUM(fcr.rc_element7) rc_element7,
          SUM(fcr.tc_amount) tc_amount,
          MAX(fcr.lv_amount) lv_amount,
          fcr.currency_code,
          MAX(fcr.pen_element_name1) pen_element_name1,
          SUM(fcr.penalty_amount1) penalty_amount1,
          MAX(fcr.pen_element_name2) pen_element_name2,
          SUM(fcr.penalty_amount2) penalty_amount2,
          MAX(fcr.pen_element_name3) pen_element_name3,
          SUM(fcr.penalty_amount3) penalty_amount3,
          MAX(fcr.pen_element_name4) pen_element_name4,
          SUM(fcr.penalty_amount4) penalty_amount4,
          MAX(fcr.pen_element_name5) pen_element_name5,
          SUM(fcr.penalty_amount5) penalty_amount5,
          SUM(fcr.OTHERS) OTHERS
     FROM (SELECT fcr.corporate_name,
                  fcr.corporate_id,
                  fcr.product_id,
                  fcr.product_name,
                  fcr.eod_trade_date,
                  fcr.quality_id,
                  fcr.quality_name,
                  MAX(fcr.gmr_qty) wet_qty,
                  fcr.gmr_qty_unit,
                  fcr.cp_id,
                  fcr.cp_name,
                  MAX(CASE
                        WHEN pay.order_id = 1 THEN
                         pay.element_name || '(' || fcr.product_base_qty_unit || ')'
                        ELSE
                         ''
                      END) element_name1,
                  SUM(CASE
                        WHEN pay.order_id = 1 THEN
                         fcr.assay_qty
                        ELSE
                         0
                      END) contained_element1,
                  SUM(CASE
                        WHEN pay.order_id = 1 THEN
                         fcr.payable_qty
                        ELSE
                         0
                      END) payable_element1,
                  SUM(CASE
                        WHEN pay.order_id = 1 THEN
                         fcr.rc_amount
                        ELSE
                         0
                      END) rc_element1,
                  MAX(CASE
                        WHEN pay.order_id = 2 THEN
                         pay.element_name || '(' || fcr.product_base_qty_unit || ')'
                        ELSE
                         ''
                      END) element_name2,
                  SUM(CASE
                        WHEN pay.order_id = 2 THEN
                         fcr.assay_qty
                        ELSE
                         0
                      END) contained_element2,
                  SUM(CASE
                        WHEN pay.order_id = 2 THEN
                         fcr.payable_qty
                        ELSE
                         0
                      END) payable_element2,
                  SUM(CASE
                        WHEN pay.order_id = 2 THEN
                         fcr.rc_amount
                        ELSE
                         0
                      END) rc_element2,
                  MAX(CASE
                        WHEN pay.order_id = 3 THEN
                         pay.element_name || '(' || fcr.product_base_qty_unit || ')'
                        ELSE
                         ''
                      END) element_name3,
                  SUM(CASE
                        WHEN pay.order_id = 3 THEN
                         fcr.assay_qty
                        ELSE
                         0
                      END) contained_element3,
                  SUM(CASE
                        WHEN pay.order_id = 3 THEN
                         fcr.payable_qty
                        ELSE
                         0
                      END) payable_element3,
                  SUM(CASE
                        WHEN pay.order_id = 3 THEN
                         fcr.rc_amount
                        ELSE
                         0
                      END) rc_element3,
                  MAX(CASE
                        WHEN pay.order_id = 4 THEN
                         pay.element_name || '(' || fcr.product_base_qty_unit || ')'
                        ELSE
                         ''
                      END) element_name4,
                  SUM(CASE
                        WHEN pay.order_id = 4 THEN
                         fcr.assay_qty
                        ELSE
                         0
                      END) contained_element4,
                  SUM(CASE
                        WHEN pay.order_id = 4 THEN
                         fcr.payable_qty
                        ELSE
                         0
                      END) payable_element4,
                  SUM(CASE
                        WHEN pay.order_id = 4 THEN
                         fcr.rc_amount
                        ELSE
                         0
                      END) rc_element4,
                  MAX(CASE
                        WHEN pay.order_id = 5 THEN
                         pay.element_name || '(' || fcr.product_base_qty_unit || ')'
                        ELSE
                         ''
                      END) element_name5,
                  SUM(CASE
                        WHEN pay.order_id = 5 THEN
                         fcr.assay_qty
                        ELSE
                         0
                      END) contained_element5,
                  SUM(CASE
                        WHEN pay.order_id = 5 THEN
                         fcr.payable_qty
                        ELSE
                         0
                      END) payable_element5,
                  SUM(CASE
                        WHEN pay.order_id = 5 THEN
                         fcr.rc_amount
                        ELSE
                         0
                      END) rc_element5,
                  MAX(CASE
                        WHEN pay.order_id = 6 THEN
                         pay.element_name || '(' || fcr.product_base_qty_unit || ')'
                        ELSE
                         ''
                      END) element_name6,
                  SUM(CASE
                        WHEN pay.order_id = 6 THEN
                         fcr.assay_qty
                        ELSE
                         0
                      END) contained_element6,
                  SUM(CASE
                        WHEN pay.order_id = 6 THEN
                         fcr.payable_qty
                        ELSE
                         0
                      END) payable_element6,
                  SUM(CASE
                        WHEN pay.order_id = 6 THEN
                         fcr.rc_amount
                        ELSE
                         0
                      END) rc_element6,
                  MAX(CASE
                        WHEN pay.order_id = 7 THEN
                         pay.element_name || '(' || fcr.product_base_qty_unit || ')'
                        ELSE
                         ''
                      END) element_name7,
                  SUM(CASE
                        WHEN pay.order_id = 7 THEN
                         fcr.assay_qty
                        ELSE
                         0
                      END) contained_element7,
                  SUM(CASE
                        WHEN pay.order_id = 7 THEN
                         fcr.payable_qty
                        ELSE
                         0
                      END) payable_element7,
                  SUM(CASE
                        WHEN pay.order_id = 7 THEN
                         fcr.rc_amount
                        ELSE
                         0
                      END) rc_element7,
                  SUM(fcr.tc_amount) tc_amount,
                  fcr.inv_add_charges lv_amount,
                  fcr.invoice_cur_code currency_code,
                  NULL pen_element_name1,
                  NULL penalty_amount1,
                  NULL pen_element_name2,
                  NULL penalty_amount2,
                  NULL pen_element_name3,
                  NULL penalty_amount3,
                  NULL pen_element_name4,
                  NULL penalty_amount4,
                  NULL pen_element_name5,
                  NULL penalty_amount5,
                  NULL OTHERS
             FROM fcr_feed_consumption_report fcr,
                  cpe_corp_payble_element     pay,
                  tdc_trade_date_closure      tdc,
                  aml_attribute_master_list   aml,
                  ucm_unit_conversion_master  ucm,
                  qum_quantity_unit_master    qum,
                  pdm_productmaster           pdm
            WHERE fcr.process_id = tdc.process_id
              AND fcr.corporate_id = tdc.corporate_id
              AND tdc.process = 'EOM'
              AND fcr.corporate_id = pay.corporate_id(+)
              AND fcr.element_id = aml.attribute_id
              AND aml.underlying_product_id = pdm.product_id
              AND fcr.payable_qty_unit_id = ucm.from_qty_unit_id
              AND pdm.base_quantity_unit = ucm.to_qty_unit_id
              AND pdm.base_quantity_unit = qum.qty_unit_id
              AND fcr.element_id = pay.element_id(+)
            GROUP BY fcr.product_id,
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
           UNION ALL
           SELECT fcr.corporate_name,
                  fcr.corporate_id,
                  fcr.product_id,
                  fcr.product_name,
                  fcr.eod_trade_date,
                  fcr.quality_id,
                  fcr.quality_name,
                  0 wet_qty,
                  NULL gmr_qty_unit,
                  fcr.cp_id,
                  fcr.cp_name,
                  NULL element_name1,
                  NULL contained_element1,
                  NULL payable_element1,
                  NULL rc_element1,
                  NULL element_name2,
                  NULL contained_element2,
                  NULL payable_element2,
                  NULL rc_element2,
                  NULL element_name3,
                  NULL contained_element3,
                  NULL payable_element3,
                  NULL rc_element3,
                  NULL element_name4,
                  NULL contained_element4,
                  NULL payable_element4,
                  NULL rc_element4,
                  NULL element_name5,
                  NULL contained_element5,
                  NULL payable_element5,
                  NULL rc_element5,
                  NULL element_name6,
                  NULL contained_element6,
                  NULL payable_element6,
                  NULL rc_element6,
                  NULL element_name7,
                  NULL contained_element7,
                  NULL payable_element7,
                  NULL rc_element7,
                  NULL tc_amount,
                  NULL lv_amount,
                  fcr.invoice_cur_code currency_code,
                  MAX(CASE
                        WHEN pen.order_id = 1 THEN
                         pen.element_name
                        ELSE
                         ''
                      END) pen_element_name1,
                  SUM(CASE
                        WHEN pen.order_id = 1 THEN
                         fcr.penality_amount
                        ELSE
                         0
                      END) penalty_amount1,
                  MAX(CASE
                        WHEN pen.order_id = 2 THEN
                         pen.element_name
                        ELSE
                         ''
                      END) pen_element_name2,
                  SUM(CASE
                        WHEN pen.order_id = 2 THEN
                         fcr.penality_amount
                        ELSE
                         0
                      END) penalty_amount2,
                  MAX(CASE
                        WHEN pen.order_id = 3 THEN
                         pen.element_name
                        ELSE
                         ''
                      END) pen_element_name3,
                  SUM(CASE
                        WHEN pen.order_id = 3 THEN
                         fcr.penality_amount
                        ELSE
                         0
                      END) penalty_amount3,
                  MAX(CASE
                        WHEN pen.order_id = 4 THEN
                         pen.element_name
                        ELSE
                         ''
                      END) pen_element_name4,
                  SUM(CASE
                        WHEN pen.order_id = 4 THEN
                         fcr.penality_amount
                        ELSE
                         0
                      END) penalty_amount4,
                  MAX(CASE
                        WHEN pen.order_id = 5 THEN
                         pen.element_name
                        ELSE
                         ''
                      END) pen_element_name5,
                  SUM(CASE
                        WHEN pen.order_id = 5 THEN
                         fcr.penality_amount
                        ELSE
                         0
                      END) penalty_amount5,
                  SUM(CASE
                        WHEN pen.order_id > 5 THEN
                         fcr.penality_amount
                        ELSE
                         0
                      END) OTHERS
             FROM fcr_feed_consumption_report fcr,
                  cpe_corp_penality_element   pen,
                  tdc_trade_date_closure      tdc,
                  aml_attribute_master_list   aml,
                  ucm_unit_conversion_master  ucm,
                  qum_quantity_unit_master    qum,
                  pdm_productmaster           pdm
            WHERE fcr.process_id = tdc.process_id
              AND fcr.corporate_id = tdc.corporate_id
              AND tdc.process = 'EOM'
              AND fcr.element_id = aml.attribute_id
              AND aml.underlying_product_id = pdm.product_id
              AND fcr.payable_qty_unit_id = ucm.from_qty_unit_id
              AND pdm.base_quantity_unit = ucm.to_qty_unit_id
              AND pdm.base_quantity_unit = qum.qty_unit_id
              AND fcr.element_id = pen.element_id(+)
            GROUP BY fcr.product_id,
                     fcr.product_name,
                     fcr.corporate_id,
                     fcr.quality_id,
                     fcr.quality_name,
                     fcr.gmr_qty_unit,
                     fcr.cp_id,
                     fcr.cp_name,
                     fcr.invoice_cur_code,
                     fcr.eod_trade_date,
                     fcr.corporate_name) fcr
    GROUP BY fcr.corporate_name,
             fcr.product_id,
             fcr.corporate_id,
             fcr.product_name,
             fcr.eod_trade_date,
             fcr.quality_id,
             fcr.quality_name,
             fcr.cp_id,
             fcr.cp_name,
             fcr.currency_code;
