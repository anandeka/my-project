/* Formatted on 2013/01/15 15:57 (Formatter Plus v4.8.8) */
DROP TRIGGER trg_insert_spql;

CREATE OR REPLACE TRIGGER "TRG_INSERT_SPQL"
   AFTER INSERT OR UPDATE
   ON spq_stock_payable_qty
   FOR EACH ROW
BEGIN
   IF UPDATING
   THEN
      IF :NEW.is_active = 'Y'
      THEN
         --Qty Unit is Not Updated
         IF :NEW.qty_unit_id = :OLD.qty_unit_id
         THEN
            INSERT INTO spql_stock_payable_qty_log
                        (spq_id, internal_gmr_ref_no,
                         stock_type, internal_grd_ref_no,
                         internal_dgrd_ref_no, action_no,
                         internal_action_ref_no, element_id,
                         payable_qty_delta,
                         qty_unit_id, qty_type,
                         activity_action_id, is_stock_split,
                         supplier_id, smelter_id,
                         free_metal_stock_id,
                         free_metal_qty,
                         assay_content,
                         pledge_stock_id,
                         gepd_id,
                         assay_header_id, is_final_assay,
                         corporate_id, is_pure_free_metal_elem,
                         ext_assay_header_id,
                         ext_assay_content,
                         ext_payable_qty,
                         VERSION, entry_type, is_active,
                         weg_avg_pricing_assay_id,
                         weg_avg_invoice_assay_id,
                         cot_int_action_ref_no
                        )
                 VALUES (:NEW.spq_id, :NEW.internal_gmr_ref_no,
                         :NEW.stock_type, :NEW.internal_grd_ref_no,
                         :NEW.internal_dgrd_ref_no, :NEW.action_no,
                         :NEW.internal_action_ref_no, :NEW.element_id,
                         :NEW.payable_qty - :OLD.payable_qty,
                         :NEW.qty_unit_id, :NEW.qty_type,
                         :NEW.activity_action_id, :NEW.is_stock_split,
                         :NEW.supplier_id, :NEW.smelter_id,
                         :NEW.free_metal_stock_id,
                         :NEW.free_metal_qty - NVL (:OLD.free_metal_qty, 0),
                         :NEW.assay_content - :OLD.assay_content,
                         (SELECT (CASE
                                     WHEN (SELECT axs.action_id
                                             FROM axs_action_summary axs
                                            WHERE axs.internal_action_ref_no =
                                                     :NEW.internal_action_ref_no) =
                                                        'cancelPledgeTransfer'
                                        THEN 'Empty_String'
                                     ELSE :NEW.pledge_stock_id
                                  END
                                 )
                            FROM DUAL),
                         (SELECT (CASE
                                     WHEN (SELECT axs.action_id
                                             FROM axs_action_summary axs
                                            WHERE axs.internal_action_ref_no =
                                                     :NEW.internal_action_ref_no) =
                                                        'cancelPledgeTransfer'
                                        THEN 'Empty_String'
                                     ELSE :NEW.gepd_id
                                  END
                                 )
                            FROM DUAL),
                         :NEW.assay_header_id, :NEW.is_final_assay,
                         :NEW.corporate_id, :NEW.is_pure_free_metal_elem,
                         :NEW.ext_assay_header_id,
                         :NEW.ext_assay_content - :OLD.ext_assay_content,
                         :NEW.ext_payable_qty - :OLD.ext_payable_qty,
                         :NEW.VERSION, 'Update', 'Y',
                         (SELECT (CASE
                                     WHEN (SELECT COUNT (*)
                                             FROM ash_assay_header ash
                                            WHERE (   ash.pricing_assay_ash_id =
                                                          :NEW.assay_header_id
                                                   OR ash.ash_id =
                                                          :NEW.assay_header_id
                                                  )
                                              AND ash.assay_type =
                                                     'Weighted Avg Pricing Assay') =
                                                                             0
                                        THEN (SELECT DISTINCT ash.ash_id
                                                         FROM ash_assay_header ash
                                                        WHERE ash.internal_grd_ref_no =
                                                                 :NEW.internal_grd_ref_no
                                                          AND ash.assay_type =
                                                                 'Shipment Assay')
                                     ELSE (SELECT ash.ash_id
                                             FROM ash_assay_header ash
                                            WHERE (   ash.pricing_assay_ash_id =
                                                          :NEW.assay_header_id
                                                   OR ash.ash_id =
                                                          :NEW.assay_header_id
                                                  )
                                              AND ash.assay_type =
                                                     'Weighted Avg Pricing Assay')
                                  END
                                 )
                            FROM DUAL),
                         (SELECT (CASE
                                     WHEN (SELECT COUNT (*)
                                             FROM ash_assay_header ash
                                            WHERE (   ash.invoice_ash_id =
                                                         :NEW.ext_assay_header_id
                                                   OR ash.ash_id =
                                                         :NEW.ext_assay_header_id
                                                  )
                                              AND ash.assay_type =
                                                     'Weighted Avg Invoice Assay') =
                                                                             0
                                        THEN (SELECT DISTINCT ash.ash_id
                                                         FROM ash_assay_header ash
                                                        WHERE ash.internal_grd_ref_no =
                                                                 :NEW.internal_grd_ref_no
                                                          AND ash.assay_type =
                                                                 'Shipment Assay')
                                     ELSE (SELECT ash.ash_id
                                             FROM ash_assay_header ash
                                            WHERE (   ash.invoice_ash_id =
                                                         :NEW.ext_assay_header_id
                                                   OR ash.ash_id =
                                                         :NEW.ext_assay_header_id
                                                  )
                                              AND ash.assay_type =
                                                     'Weighted Avg Invoice Assay')
                                  END
                                 )
                            FROM DUAL),
                         :NEW.cot_int_action_ref_no
                        );
         ELSE
            --Qty Unit is Updated
            INSERT INTO spql_stock_payable_qty_log
                        (spq_id, internal_gmr_ref_no,
                         stock_type, internal_grd_ref_no,
                         internal_dgrd_ref_no, action_no,
                         internal_action_ref_no, element_id,
                         payable_qty_delta,
                         qty_unit_id, qty_type,
                         activity_action_id, is_stock_split,
                         supplier_id, smelter_id,
                         free_metal_stock_id,
                         free_metal_qty,
                         assay_content,
                         pledge_stock_id,
                         gepd_id,
                         assay_header_id, is_final_assay,
                         corporate_id, is_pure_free_metal_elem,
                         ext_assay_header_id,
                         ext_assay_content,
                         ext_payable_qty,
                         VERSION, entry_type, is_active,
                         weg_avg_pricing_assay_id,
                         weg_avg_invoice_assay_id,
                         cot_int_action_ref_no
                        )
                 VALUES (:NEW.spq_id, :NEW.internal_gmr_ref_no,
                         :NEW.stock_type, :NEW.internal_grd_ref_no,
                         :NEW.internal_dgrd_ref_no, :NEW.action_no,
                         :NEW.internal_action_ref_no, :NEW.element_id,
                           :NEW.payable_qty
                         - pkg_general.f_get_converted_quantity
                                                            (NULL,
                                                             :OLD.qty_unit_id,
                                                             :NEW.qty_unit_id,
                                                             :OLD.payable_qty
                                                            ),
                         :NEW.qty_unit_id, :NEW.qty_type,
                         :NEW.activity_action_id, :NEW.is_stock_split,
                         :NEW.supplier_id, :NEW.smelter_id,
                         :NEW.free_metal_stock_id,
                           :NEW.free_metal_qty
                         - pkg_general.f_get_converted_quantity
                                                     (NULL,
                                                      :OLD.qty_unit_id,
                                                      :NEW.qty_unit_id,
                                                      NVL
                                                         (:OLD.free_metal_qty,
                                                          0
                                                         )
                                                     ),
                           :NEW.assay_content
                         - pkg_general.f_get_converted_quantity
                                                           (NULL,
                                                            :OLD.qty_unit_id,
                                                            :NEW.qty_unit_id,
                                                            :OLD.assay_content
                                                           ),
                         (SELECT (CASE
                                     WHEN (SELECT axs.action_id
                                             FROM axs_action_summary axs
                                            WHERE axs.internal_action_ref_no =
                                                     :NEW.internal_action_ref_no) =
                                                        'cancelPledgeTransfer'
                                        THEN 'Empty_String'
                                     ELSE :NEW.pledge_stock_id
                                  END
                                 )
                            FROM DUAL),
                         (SELECT (CASE
                                     WHEN (SELECT axs.action_id
                                             FROM axs_action_summary axs
                                            WHERE axs.internal_action_ref_no =
                                                     :NEW.internal_action_ref_no) =
                                                        'cancelPledgeTransfer'
                                        THEN 'Empty_String'
                                     ELSE :NEW.gepd_id
                                  END
                                 )
                            FROM DUAL),
                         :NEW.assay_header_id, :NEW.is_final_assay,
                         :NEW.corporate_id, :NEW.is_pure_free_metal_elem,
                         :NEW.ext_assay_header_id,
                           :NEW.ext_assay_content
                         - pkg_general.f_get_converted_quantity
                                                       (NULL,
                                                        :OLD.qty_unit_id,
                                                        :NEW.qty_unit_id,
                                                        :OLD.ext_assay_content
                                                       ),
                           :NEW.ext_payable_qty
                         - pkg_general.f_get_converted_quantity
                                                         (NULL,
                                                          :OLD.qty_unit_id,
                                                          :NEW.qty_unit_id,
                                                          :OLD.ext_payable_qty
                                                         ),
                         :NEW.VERSION, 'Update', 'Y',
                         (SELECT (CASE
                                     WHEN (SELECT COUNT (*)
                                             FROM ash_assay_header ash
                                            WHERE (   ash.pricing_assay_ash_id =
                                                          :NEW.assay_header_id
                                                   OR ash.ash_id =
                                                          :NEW.assay_header_id
                                                  )
                                              AND ash.assay_type =
                                                     'Weighted Avg Pricing Assay') =
                                                                             0
                                        THEN (SELECT DISTINCT ash.ash_id
                                                         FROM ash_assay_header ash
                                                        WHERE ash.internal_grd_ref_no =
                                                                 :NEW.internal_grd_ref_no
                                                          AND ash.assay_type =
                                                                 'Shipment Assay')
                                     ELSE (SELECT ash.ash_id
                                             FROM ash_assay_header ash
                                            WHERE (   ash.pricing_assay_ash_id =
                                                          :NEW.assay_header_id
                                                   OR ash.ash_id =
                                                          :NEW.assay_header_id
                                                  )
                                              AND ash.assay_type =
                                                     'Weighted Avg Pricing Assay')
                                  END
                                 )
                            FROM DUAL),
                         (SELECT (CASE
                                     WHEN (SELECT COUNT (*)
                                             FROM ash_assay_header ash
                                            WHERE (   ash.invoice_ash_id =
                                                         :NEW.ext_assay_header_id
                                                   OR ash.ash_id =
                                                         :NEW.ext_assay_header_id
                                                  )
                                              AND ash.assay_type =
                                                     'Weighted Avg Invoice Assay') =
                                                                             0
                                        THEN (SELECT DISTINCT ash.ash_id
                                                         FROM ash_assay_header ash
                                                        WHERE ash.internal_grd_ref_no =
                                                                 :NEW.internal_grd_ref_no
                                                          AND ash.assay_type =
                                                                 'Shipment Assay')
                                     ELSE (SELECT ash.ash_id
                                             FROM ash_assay_header ash
                                            WHERE (   ash.invoice_ash_id =
                                                         :NEW.ext_assay_header_id
                                                   OR ash.ash_id =
                                                         :NEW.ext_assay_header_id
                                                  )
                                              AND ash.assay_type =
                                                     'Weighted Avg Invoice Assay')
                                  END
                                 )
                            FROM DUAL),
                         :NEW.cot_int_action_ref_no
                        );
         END IF;
      ELSE
         -- IsActive is Cancelled
         INSERT INTO spql_stock_payable_qty_log
                     (spq_id, internal_gmr_ref_no,
                      stock_type, internal_grd_ref_no,
                      internal_dgrd_ref_no, action_no,
                      internal_action_ref_no, element_id,
                      payable_qty_delta, qty_unit_id,
                      qty_type, activity_action_id,
                      is_stock_split, supplier_id,
                      smelter_id, free_metal_stock_id,
                      free_metal_qty,
                      assay_content,
                      pledge_stock_id,
                      gepd_id,
                      assay_header_id, is_final_assay,
                      corporate_id, is_pure_free_metal_elem,
                      ext_assay_header_id,
                      ext_assay_content,
                      ext_payable_qty,
                      VERSION, entry_type, is_active,
                      weg_avg_pricing_assay_id,
                      weg_avg_invoice_assay_id,
                      cot_int_action_ref_no
                     )
              VALUES (:NEW.spq_id, :NEW.internal_gmr_ref_no,
                      :NEW.stock_type, :NEW.internal_grd_ref_no,
                      :NEW.internal_dgrd_ref_no, :NEW.action_no,
                      :NEW.internal_action_ref_no, :NEW.element_id,
                      :NEW.payable_qty - :OLD.payable_qty, :NEW.qty_unit_id,
                      :NEW.qty_type, :NEW.activity_action_id,
                      :NEW.is_stock_split, :NEW.supplier_id,
                      :NEW.smelter_id, :NEW.free_metal_stock_id,
                      :NEW.free_metal_qty - NVL (:OLD.free_metal_qty, 0),
                      :NEW.assay_content - :OLD.assay_content,
                      (SELECT (CASE
                                  WHEN (SELECT axs.action_id
                                          FROM axs_action_summary axs
                                         WHERE axs.internal_action_ref_no =
                                                   :NEW.internal_action_ref_no) =
                                                        'cancelPledgeTransfer'
                                     THEN 'Empty_String'
                                  ELSE :NEW.pledge_stock_id
                               END
                              )
                         FROM DUAL),
                      (SELECT (CASE
                                  WHEN (SELECT axs.action_id
                                          FROM axs_action_summary axs
                                         WHERE axs.internal_action_ref_no =
                                                   :NEW.internal_action_ref_no) =
                                                        'cancelPledgeTransfer'
                                     THEN 'Empty_String'
                                  ELSE :NEW.gepd_id
                               END
                              )
                         FROM DUAL),
                      :NEW.assay_header_id, :NEW.is_final_assay,
                      :NEW.corporate_id, :NEW.is_pure_free_metal_elem,
                      :NEW.ext_assay_header_id,
                      :NEW.ext_assay_content - :OLD.ext_assay_content,
                      :NEW.ext_payable_qty - :OLD.ext_payable_qty,
                      :NEW.VERSION, 'Update', 'N',
                      (SELECT (CASE
                                  WHEN (SELECT COUNT (*)
                                          FROM ash_assay_header ash
                                         WHERE (   ash.pricing_assay_ash_id =
                                                          :NEW.assay_header_id
                                                OR ash.ash_id =
                                                          :NEW.assay_header_id
                                               )
                                           AND ash.assay_type =
                                                  'Weighted Avg Pricing Assay') =
                                                                             0
                                     THEN (SELECT DISTINCT ash.ash_id
                                                      FROM ash_assay_header ash
                                                     WHERE ash.internal_grd_ref_no =
                                                              :NEW.internal_grd_ref_no
                                                       AND ash.assay_type =
                                                              'Shipment Assay')
                                  ELSE (SELECT ash.ash_id
                                          FROM ash_assay_header ash
                                         WHERE (   ash.pricing_assay_ash_id =
                                                          :NEW.assay_header_id
                                                OR ash.ash_id =
                                                          :NEW.assay_header_id
                                               )
                                           AND ash.assay_type =
                                                  'Weighted Avg Pricing Assay')
                               END
                              )
                         FROM DUAL),
                      (SELECT (CASE
                                  WHEN (SELECT COUNT (*)
                                          FROM ash_assay_header ash
                                         WHERE (   ash.invoice_ash_id =
                                                      :NEW.ext_assay_header_id
                                                OR ash.ash_id =
                                                      :NEW.ext_assay_header_id
                                               )
                                           AND ash.assay_type =
                                                  'Weighted Avg Invoice Assay') =
                                                                             0
                                     THEN (SELECT DISTINCT ash.ash_id
                                                      FROM ash_assay_header ash
                                                     WHERE ash.internal_grd_ref_no =
                                                              :NEW.internal_grd_ref_no
                                                       AND ash.assay_type =
                                                              'Shipment Assay')
                                  ELSE (SELECT ash.ash_id
                                          FROM ash_assay_header ash
                                         WHERE (   ash.invoice_ash_id =
                                                      :NEW.ext_assay_header_id
                                                OR ash.ash_id =
                                                      :NEW.ext_assay_header_id
                                               )
                                           AND ash.assay_type =
                                                  'Weighted Avg Invoice Assay')
                               END
                              )
                         FROM DUAL),
                      :NEW.cot_int_action_ref_no
                     );
      END IF;
   ELSE
      --
      -- New Entry ( Entry Type=Insert)
      --
      INSERT INTO spql_stock_payable_qty_log
                  (spq_id, internal_gmr_ref_no, stock_type,
                   internal_grd_ref_no, internal_dgrd_ref_no,
                   action_no, internal_action_ref_no,
                   element_id, payable_qty_delta, qty_unit_id,
                   qty_type, activity_action_id,
                   is_stock_split, supplier_id, smelter_id,
                   free_metal_stock_id, free_metal_qty,
                   assay_content,
                   pledge_stock_id,
                   gepd_id,
                   assay_header_id, is_final_assay,
                   corporate_id, is_pure_free_metal_elem,
                   ext_assay_header_id, ext_assay_content,
                   ext_payable_qty, VERSION, entry_type, is_active,
                   weg_avg_pricing_assay_id,
                   weg_avg_invoice_assay_id,
                   cot_int_action_ref_no
                  )
           VALUES (:NEW.spq_id, :NEW.internal_gmr_ref_no, :NEW.stock_type,
                   :NEW.internal_grd_ref_no, :NEW.internal_dgrd_ref_no,
                   :NEW.action_no, :NEW.internal_action_ref_no,
                   :NEW.element_id, :NEW.payable_qty, :NEW.qty_unit_id,
                   :NEW.qty_type, :NEW.activity_action_id,
                   :NEW.is_stock_split, :NEW.supplier_id, :NEW.smelter_id,
                   :NEW.free_metal_stock_id, :NEW.free_metal_qty,
                   :NEW.assay_content,
                   (SELECT (CASE
                               WHEN (SELECT axs.action_id
                                       FROM axs_action_summary axs
                                      WHERE axs.internal_action_ref_no =
                                                   :NEW.internal_action_ref_no) =
                                                        'cancelPledgeTransfer'
                                  THEN 'Empty_String'
                               ELSE :NEW.pledge_stock_id
                            END
                           )
                      FROM DUAL),
                   (SELECT (CASE
                               WHEN (SELECT axs.action_id
                                       FROM axs_action_summary axs
                                      WHERE axs.internal_action_ref_no =
                                                   :NEW.internal_action_ref_no) =
                                                        'cancelPledgeTransfer'
                                  THEN 'Empty_String'
                               ELSE :NEW.gepd_id
                            END
                           )
                      FROM DUAL),
                   :NEW.assay_header_id, :NEW.is_final_assay,
                   :NEW.corporate_id, :NEW.is_pure_free_metal_elem,
                   :NEW.ext_assay_header_id, :NEW.ext_assay_content,
                   :NEW.ext_payable_qty, :NEW.VERSION, 'Insert', 'Y',
                   (SELECT (CASE
                               WHEN (SELECT COUNT (*)
                                       FROM ash_assay_header ash
                                      WHERE (   ash.pricing_assay_ash_id =
                                                          :NEW.assay_header_id
                                             OR ash.ash_id =
                                                          :NEW.assay_header_id
                                            )
                                        AND ash.assay_type =
                                                  'Weighted Avg Pricing Assay') =
                                                                             0
                                  THEN (SELECT DISTINCT ash.ash_id
                                                   FROM ash_assay_header ash
                                                  WHERE ash.internal_grd_ref_no =
                                                           :NEW.internal_grd_ref_no
                                                    AND ash.assay_type =
                                                              'Shipment Assay')
                               ELSE (SELECT ash.ash_id
                                       FROM ash_assay_header ash
                                      WHERE (   ash.pricing_assay_ash_id =
                                                          :NEW.assay_header_id
                                             OR ash.ash_id =
                                                          :NEW.assay_header_id
                                            )
                                        AND ash.assay_type =
                                                  'Weighted Avg Pricing Assay')
                            END
                           )
                      FROM DUAL),
                   (SELECT (CASE
                               WHEN (SELECT COUNT (*)
                                       FROM ash_assay_header ash
                                      WHERE (   ash.invoice_ash_id =
                                                      :NEW.ext_assay_header_id
                                             OR ash.ash_id =
                                                      :NEW.ext_assay_header_id
                                            )
                                        AND ash.assay_type =
                                                  'Weighted Avg Invoice Assay') =
                                                                             0
                                  THEN (SELECT DISTINCT ash.ash_id
                                                   FROM ash_assay_header ash
                                                  WHERE ash.internal_grd_ref_no =
                                                           :NEW.internal_grd_ref_no
                                                    AND ash.assay_type =
                                                              'Shipment Assay')
                               ELSE (SELECT ash.ash_id
                                       FROM ash_assay_header ash
                                      WHERE (   ash.invoice_ash_id =
                                                      :NEW.ext_assay_header_id
                                             OR ash.ash_id =
                                                      :NEW.ext_assay_header_id
                                            )
                                        AND ash.assay_type =
                                                  'Weighted Avg Invoice Assay')
                            END
                           )
                      FROM DUAL),
                   :NEW.cot_int_action_ref_no
                  );
   END IF;
END;
/