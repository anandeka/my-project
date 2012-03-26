CREATE OR REPLACE VIEW V_BI_RECENT_TRADES_BY_PRODUCT AS
SELECT   t2.corporate_id, t2.product_id, t2.product_name,
            t2.contract_ref_no, t2.trade_type,
            TO_DATE (t2.issue_date, 'dd-Mon-RRRR') issue_date,
            t2.item_qty position_quantity, t2.base_quantity_unit qty_unit_id,
            t2.qty_unit base_qty_unit
       FROM (SELECT   t1.contract_ref_no, t1.corporate_id, t1.created_date,
                      t1.product_id, t1.product_name, t1.trade_type,
                      t1.base_quantity_unit, t1.item_qty, t1.qty_unit,
                      t1.issue_date,
                      ROW_NUMBER () OVER (PARTITION BY t1.corporate_id, t1.product_id ORDER BY t1.created_date DESC)
                                                                    order_seq
                 --  row_number() over(partition by t1.corporate_id, t1.product_id order by t1.created_date desc) seq
             FROM     (SELECT   t.contract_ref_no, t.corporate_id,
                                t.created_date, t.issue_date,
                                (CASE
                                    WHEN pcm.contract_type = 'BASEMETAL'
                                    AND pcm.purchase_sales = 'P'
                                    AND pcm.is_tolling_contract = 'N'
                                       THEN 'Physical Purchase'
                                    WHEN pcm.contract_type = 'BASEMETAL'
                                    AND pcm.purchase_sales = 'S'
                                    AND pcm.is_tolling_contract = 'N'
                                       THEN 'Physical Sales'
                                    WHEN pcm.contract_type = 'CONCENTRATES'
                                    AND pcm.purchase_sales = 'P'
                                    AND pcm.is_tolling_contract = 'N'
                                       THEN 'Physical Purchase'
                                    WHEN pcm.contract_type = 'CONCENTRATES'
                                    AND pcm.purchase_sales = 'S'
                                    AND pcm.is_tolling_contract = 'N'
                                       THEN 'Physical Sales'
                                    WHEN pcm.contract_type = 'CONCENTRATES'
                                    AND pcm.purchase_sales = 'P'
                                    AND pcm.is_tolling_contract = 'Y'
                                       THEN 'Sell Tolling'
                                    WHEN pcm.contract_type = 'CONCENTRATES'
                                    AND pcm.purchase_sales = 'S'
                                    AND pcm.is_tolling_contract = 'Y'
                                       THEN 'Buy Tolling'
                                    ELSE 'NA'
                                 END
                                ) trade_type,
                                pdm.product_id, pdm.product_desc product_name,
                                pdm.base_quantity_unit,
                                (cqs.total_qty * ucm.multiplication_factor
                                ) item_qty,
                                qum.qty_unit
                           FROM (SELECT   SUBSTR
                                             (MAX
                                                 (CASE
                                                     WHEN pcmul.contract_ref_no IS NOT NULL
                                                        THEN    TO_CHAR
                                                                   (axs.created_date,
                                                                    'yyyymmddhh24missff9'
                                                                   )
                                                             || pcmul.contract_ref_no
                                                  END
                                                 ),
                                              24
                                             ) contract_ref_no,
                                          SUBSTR
                                             (MAX
                                                 (CASE
                                                     WHEN pcmul.corporate_id IS NOT NULL
                                                        THEN    TO_CHAR
                                                                   (axs.created_date,
                                                                    'yyyymmddhh24missff9'
                                                                   )
                                                             || pcmul.corporate_id
                                                  END
                                                 ),
                                              24
                                             ) corporate_id,
                                          SUBSTR
                                             (MAX
                                                 (CASE
                                                     WHEN pcmul.internal_contract_ref_no IS NOT NULL
                                                        THEN    TO_CHAR
                                                                   (axs.created_date,
                                                                    'yyyymmddhh24missff9'
                                                                   )
                                                             || pcmul.internal_contract_ref_no
                                                  END
                                                 ),
                                              24
                                             ) internal_contract_ref_no,
                                          SUBSTR
                                             (MAX
                                                 (CASE
                                                     WHEN pcmul.issue_date IS NOT NULL
                                                        THEN    TO_CHAR
                                                                   (axs.created_date,
                                                                    'yyyymmddhh24missff9'
                                                                   )
                                                             || pcmul.issue_date
                                                  END
                                                 ),
                                              24
                                             ) issue_date,
                                          MAX
                                             (CASE
                                                 WHEN axs.created_date IS NOT NULL
                                                    THEN axs.created_date
                                              END
                                             ) created_date
                                     FROM pcmul_phy_contract_main_ul pcmul,
                                          axs_action_summary axs
                                    WHERE pcmul.internal_action_ref_no =
                                                    axs.internal_action_ref_no
                                 GROUP BY pcmul.internal_contract_ref_no) t,
                                pdm_productmaster pdm,
                                pcm_physical_contract_main pcm,
                                pci_physical_contract_item pci,
                                pcdi_pc_delivery_item pcdi,
                                pcpd_pc_product_definition pcpd,
                                pcpq_pc_product_quality pcpq,
                                cqs_contract_qty_status cqs,
                                ucm_unit_conversion_master ucm,
                                qum_quantity_unit_master qum
                          WHERE pcdi.internal_contract_ref_no =
                                                    t.internal_contract_ref_no
                            AND pci.pcdi_id = pcdi.pcdi_id
                            AND pcm.internal_contract_ref_no =
                                                 pcdi.internal_contract_ref_no
                            AND pci.pcpq_id = pcpq.pcpq_id
                            AND pcpq.pcpq_id = pci.pcpq_id
                            AND pcpd.pcpd_id = pcpq.pcpd_id
                            AND pcm.internal_contract_ref_no =
                                                  cqs.internal_contract_ref_no
                            AND pdm.product_id = pcpd.product_id
                            AND pcpd.product_id = pdm.product_id
                            AND cqs.item_qty_unit_id = ucm.from_qty_unit_id
                            AND pdm.base_quantity_unit = ucm.to_qty_unit_id
                            AND pcm.contract_status IN
                                          ('In Position', 'Pending Approval')
                            AND pci.is_active = 'Y'
                            AND pdm.base_quantity_unit = qum.qty_unit_id
                            AND pdm.is_deleted = 'N'
                       GROUP BY t.contract_ref_no,
                                t.corporate_id,
                                t.created_date,
                                pdm.product_id,
                                t.issue_date,
                                pdm.product_desc,
                                cqs.total_qty,
                                ucm.multiplication_factor,
                                pcm.contract_type,
                                pcm.is_tolling_contract,
                                pdm.base_quantity_unit,
                                pcm.purchase_sales,
                                qum.qty_unit
                       ORDER BY t.created_date DESC) t1
             ORDER BY t1.product_id, t1.created_date) t2
      WHERE t2.order_seq < 6
   ORDER BY t2.corporate_id, t2.product_id 
