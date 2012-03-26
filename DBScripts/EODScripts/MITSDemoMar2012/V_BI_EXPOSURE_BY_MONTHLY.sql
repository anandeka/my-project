CREATE OR REPLACE VIEW V_BI_EXPOSURE_BY_MONTHLY AS
SELECT   t.corporate_id, t.product_id, t.product_name, t.instrument_id,
            t.instrument_name, TO_CHAR (t.month_date, 'Mon-RRRR') month_name,
            TO_NUMBER (TO_CHAR (t.month_date, 'RRRRmm')) month_order,
            SUM (t.price_fixed_quantity) price_fixed_quantity,
            SUM (t.unpriced_quantity) unpriced_quantity,
            SUM (t.net_physical_quantity) net_physical_quantity,
            SUM (t.hedge_quantity) hedge_quantity,
            SUM (t.strategic_quantity) strategic_quantity,
            SUM (t.net_derivative_quantity) net_derivative_quantity,
            SUM (t.price_fixed_quantity) + SUM (t.net_derivative_quantity) net_risk_quantity, t.base_qty_unit_id,
            t.base_qty_unit
       FROM (SELECT   vph.corporate_id, vph.product_id,
                      vph.productname product_name, vph.instrument_id,
                      vph.instrument_name,
                      LAST_DAY (vph.price_date) month_date,
                      (SUM (  vph.price_fixed_qty
                            * (CASE
                                  WHEN pcm.purchase_sales = 'S'
                                     THEN -1
                                  ELSE 1
                               END)
                           )
                      ) price_fixed_quantity,
                      (SUM (  vph.unpriced_qty
                            * (CASE
                                  WHEN pcm.purchase_sales = 'S'
                                     THEN -1
                                  ELSE 1
                               END)
                           )
                      ) unpriced_quantity,
                      (  SUM (  vph.price_fixed_qty
                              * (CASE
                                    WHEN pcm.purchase_sales = 'S'
                                       THEN -1
                                    ELSE 1
                                 END
                                )
                             )
                       + SUM (  vph.unpriced_qty
                              * (CASE
                                    WHEN pcm.purchase_sales = 'S'
                                       THEN -1
                                    ELSE 1
                                 END
                                )
                             )
                      ) net_physical_quantity,
                      0 hedge_quantity, 0 strategic_quantity,
                      0 net_derivative_quantity,
                      (  SUM (  vph.price_fixed_qty
                              * (CASE
                                    WHEN pcm.purchase_sales = 'S'
                                       THEN -1
                                    ELSE 1
                                 END
                                )
                             )
                       + SUM (  vph.unpriced_qty
                              * (CASE
                                    WHEN pcm.purchase_sales = 'S'
                                       THEN -1
                                    ELSE 1
                                 END
                                )
                             )
                      ) net_risk_quantity,
                      vph.qty_unit_id base_qty_unit_id,
                      vph.qty_unit base_qty_unit
                 FROM v_bi_exposure_by_trade vph,
                      pcm_physical_contract_main pcm
                WHERE vph.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
             GROUP BY vph.corporate_id,
                      vph.product_id,
                      LAST_DAY (vph.price_date),
                      vph.productname,
                      vph.instrument_id,
                      vph.instrument_name,
                      vph.qty_unit_id,
                      vph.qty_unit
             UNION ALL
             SELECT   drt.corporate_id, drt.product_id,
                      drt.product_desc product_name, drt.instrument_id,
                      drt.instrument_name,
                      LAST_DAY (drt.prompt_date) month_date,
                      0 price_fixed_quantity, 0 unpriced_quantity,
                      0 net_physical_quantity,
                      SUM (drt.hedge_qty * drt.qty_sign) hedge_quantity,
                      SUM (drt.strategic_qty * drt.qty_sign
                          ) strategic_quantity,
                      SUM (drt.trade_qty * drt.qty_sign
                          ) net_derivative_quantity,
                      SUM (drt.trade_qty * drt.qty_sign) net_risk_quantity,
                      drt.qty_unit_id base_qty_unit_id,
                      drt.qty_unit base_qty_unit
                 FROM v_bi_derivative_trades drt
             GROUP BY drt.corporate_id,
                      drt.product_id,
                      LAST_DAY (drt.prompt_date),
                      drt.product_desc,
                      drt.qty_unit_id,
                      drt.qty_unit,
                      drt.instrument_id,
                      drt.instrument_name) t
   GROUP BY t.corporate_id,
            t.product_id,
            t.product_name,
            t.instrument_id,
            t.month_date,
            t.instrument_name,
            t.base_qty_unit_id,
            t.base_qty_unit 
