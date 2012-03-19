CREATE OR REPLACE VIEW v_premium_report (corporate_id,
	     product_id,
	     product_name,
	     base_qty_unit_id,
	     base_qty_unit,
	     base_cur_id,
	     base_cur_code,
	     month_1_name,
	     month_2_name,
	     month_3_name,
	     month_4_name,
	     month_5_name,
	     month_6_name,
	     p_month_1_qty,
	     p_month_2_qty,
	     p_month_3_qty,
	     p_month_4_qty,
	     p_month_5_qty,
	     p_month_6_qty,
	     s_month_1_qty,
	     s_month_2_qty,
	     s_month_3_qty,
	     s_month_4_qty,
	     s_month_5_qty,
	     s_month_6_qty,
	     p_month_1_premium,
	     p_month_2_premium,
	     p_month_3_premium,
	     p_month_4_premium,
	     p_month_5_premium,
	     p_month_6_premium,
	     s_month_1_premium,
	     s_month_2_premium,
	     s_month_3_premium,
	     s_month_4_premium,
	     s_month_5_premium,
	     s_month_6_premium,
	     net_month_1_qty,
	     net_month_2_qty,
	     net_month_3_qty,
	     net_month_4_qty,
	     net_month_5_qty,
	     net_month_6_qty,
	     net_month_1_premium,
	     net_month_2_premium,
	     net_month_3_premium,
	     net_month_4_premium,
	     net_month_5_premium,
	     net_month_6_premium
	    )
AS
   SELECT corporate_id, product_id, product_name, base_qty_unit_id,
          base_qty_unit, base_cur_id, base_cur_code, month_1_name,
          month_2_name, month_3_name, month_4_name, month_5_name,
          month_6_name, p_month_1_qty, p_month_2_qty, p_month_3_qty,
          p_month_4_qty, p_month_5_qty, p_month_6_qty, s_month_1_qty,
          s_month_2_qty, s_month_3_qty, s_month_4_qty, s_month_5_qty,
          s_month_6_qty,
          NVL (  p_month_1_premium_value
               / DECODE (p_month_1_qty, 0, NULL, p_month_1_qty),
               0
              ) p_month_1_premium,
          NVL (  p_month_2_premium_value
               / DECODE (p_month_2_qty, 0, NULL, p_month_2_qty),
               0
              ) p_month_2_premium,
          NVL (  p_month_3_premium_value
               / DECODE (p_month_3_qty, 0, NULL, p_month_3_qty),
               0
              ) p_month_3_premium,
          NVL (  p_month_4_premium_value
               / DECODE (p_month_4_qty, 0, NULL, p_month_4_qty),
               0
              ) p_month_4_premium,
          NVL (  p_month_5_premium_value
               / DECODE (p_month_5_qty, 0, NULL, p_month_5_qty),
               0
              ) p_month_5_premium,
          NVL (  p_month_6_premium_value
               / DECODE (p_month_6_qty, 0, NULL, p_month_6_qty),
               0
              ) p_month_6_premium,
          NVL (  s_month_1_premium_value
               / DECODE (s_month_1_qty, 0, NULL, s_month_1_qty),
               0
              ) s_month_1_premium,
          NVL (  s_month_2_premium_value
               / DECODE (s_month_2_qty, 0, NULL, s_month_2_qty),
               0
              ) s_month_2_premium,
          NVL (  s_month_3_premium_value
               / DECODE (s_month_3_qty, 0, NULL, s_month_3_qty),
               0
              ) s_month_3_premium,
          NVL (  s_month_4_premium_value
               / DECODE (s_month_4_qty, 0, NULL, s_month_4_qty),
               0
              ) s_month_4_premium,
          NVL (  s_month_5_premium_value
               / DECODE (s_month_5_qty, 0, NULL, s_month_5_qty),
               0
              ) s_month_5_premium,
          NVL (  s_month_6_premium_value
               / DECODE (s_month_6_qty, 0, NULL, s_month_6_qty),
               0
              ) s_month_6_premium,
          p_month_1_qty - s_month_1_qty net_month_1_qty,
          p_month_2_qty - s_month_2_qty net_month_2_qty,
          p_month_3_qty - s_month_3_qty net_month_3_qty,
          p_month_4_qty - s_month_4_qty net_month_4_qty,
          p_month_5_qty - s_month_5_qty net_month_5_qty,
          p_month_6_qty - s_month_6_qty net_month_6_qty,
          DECODE (SIGN (p_month_1_qty - s_month_1_qty),
                  -1, NVL (  s_month_1_premium_value
                           / DECODE (s_month_1_qty, 0, NULL, s_month_1_qty),
                           0
                          ),
                  NVL (  p_month_1_premium_value
                       / DECODE (p_month_1_qty, 0, NULL, p_month_1_qty),
                       0
                      )
                 ) net_month_1_premium,
          DECODE (SIGN (p_month_2_qty - s_month_2_qty),
                  -1, NVL (  s_month_2_premium_value
                           / DECODE (s_month_2_qty, 0, NULL, s_month_2_qty),
                           0
                          ),
                  NVL (  p_month_2_premium_value
                       / DECODE (p_month_2_qty, 0, NULL, p_month_2_qty),
                       0
                      )
                 ) net_month_2_premium,
          DECODE (SIGN (p_month_3_qty - s_month_3_qty),
                  -1, NVL (  s_month_3_premium_value
                           / DECODE (s_month_3_qty, 0, NULL, s_month_3_qty),
                           0
                          ),
                  NVL (  p_month_3_premium_value
                       / DECODE (p_month_3_qty, 0, NULL, p_month_3_qty),
                       0
                      )
                 ) net_month_3_premium,
          DECODE (SIGN (p_month_4_qty - s_month_4_qty),
                  -1, NVL (  s_month_4_premium_value
                           / DECODE (s_month_4_qty, 0, NULL, s_month_4_qty),
                           0
                          ),
                  NVL (  p_month_4_premium_value
                       / DECODE (p_month_4_qty, 0, NULL, p_month_4_qty),
                       0
                      )
                 ) net_month_4_premium,
          DECODE (SIGN (p_month_5_qty - s_month_5_qty),
                  -1, NVL (  s_month_5_premium_value
                           / DECODE (s_month_5_qty, 0, NULL, s_month_5_qty),
                           0
                          ),
                  NVL (  p_month_5_premium_value
                       / DECODE (p_month_5_qty, 0, NULL, p_month_5_qty),
                       0
                      )
                 ) net_month_5_premium,
          DECODE (SIGN (p_month_6_qty - s_month_6_qty),
                  -1, NVL (  s_month_6_premium_value
                           / DECODE (s_month_6_qty, 0, NULL, s_month_6_qty),
                           0
                          ),
                  NVL (  p_month_6_premium_value
                       / DECODE (p_month_6_qty, 0, NULL, p_month_6_qty),
                       0
                      )
                 ) net_month_6_premium
     FROM (SELECT   t.corporate_id, t.product_id, t.product_name,
                    t.base_qty_unit_id, t.base_qty_unit, t.base_cur_id,
                    t.base_cur_code,
                    TO_CHAR (SYSDATE, 'Mon-YYYY') month_1_name,
                    TO_CHAR (ADD_MONTHS (SYSDATE, 1),
                             'Mon-yyyy') month_2_name,
                    TO_CHAR (ADD_MONTHS (SYSDATE, 2),
                             'Mon-yyyy') month_3_name,
                    TO_CHAR (ADD_MONTHS (SYSDATE, 3),
                             'Mon-yyyy') month_4_name,
                    TO_CHAR (ADD_MONTHS (SYSDATE, 4),
                             'Mon-yyyy') month_5_name,
                    TO_CHAR (ADD_MONTHS (SYSDATE, 5),
                             'Mon-yyyy') month_6_name,
                    SUM (CASE
                            WHEN t.no_of_months = 0 AND t.purchase_sales = 'P'
                               THEN qty
                            ELSE 0
                         END
                        ) p_month_1_qty,
                    SUM (CASE
                            WHEN t.no_of_months = 0 AND t.purchase_sales = 'S'
                               THEN qty
                            ELSE 0
                         END
                        ) s_month_1_qty,
                    SUM (CASE
                            WHEN t.no_of_months = 1 AND t.purchase_sales = 'P'
                               THEN qty
                            ELSE 0
                         END
                        ) p_month_2_qty,
                    SUM (CASE
                            WHEN t.no_of_months = 1 AND t.purchase_sales = 'S'
                               THEN qty
                            ELSE 0
                         END
                        ) s_month_2_qty,
                    SUM (CASE
                            WHEN t.no_of_months = 2 AND t.purchase_sales = 'P'
                               THEN qty
                            ELSE 0
                         END
                        ) p_month_3_qty,
                    SUM (CASE
                            WHEN t.no_of_months = 2 AND t.purchase_sales = 'S'
                               THEN qty
                            ELSE 0
                         END
                        ) s_month_3_qty,
                    SUM (CASE
                            WHEN t.no_of_months = 3 AND t.purchase_sales = 'P'
                               THEN qty
                            ELSE 0
                         END
                        ) p_month_4_qty,
                    SUM (CASE
                            WHEN t.no_of_months = 3 AND t.purchase_sales = 'S'
                               THEN qty
                            ELSE 0
                         END
                        ) s_month_4_qty,
                    SUM (CASE
                            WHEN t.no_of_months = 4 AND t.purchase_sales = 'P'
                               THEN qty
                            ELSE 0
                         END
                        ) p_month_5_qty,
                    SUM (CASE
                            WHEN t.no_of_months = 4 AND t.purchase_sales = 'S'
                               THEN qty
                            ELSE 0
                         END
                        ) s_month_5_qty,
                    SUM (CASE
                            WHEN t.no_of_months = 5 AND t.purchase_sales = 'P'
                               THEN qty
                            ELSE 0
                         END
                        ) p_month_6_qty,
                    SUM (CASE
                            WHEN t.no_of_months = 5 AND t.purchase_sales = 'S'
                               THEN qty
                            ELSE 0
                         END
                        ) s_month_6_qty,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 0 AND t.purchase_sales = 'P'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS p_month_1_premium_value,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 1 AND t.purchase_sales = 'P'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS p_month_2_premium_value,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 2 AND t.purchase_sales = 'P'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS p_month_3_premium_value,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 3 AND t.purchase_sales = 'P'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS p_month_4_premium_value,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 4 AND t.purchase_sales = 'P'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS p_month_5_premium_value,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 5 AND t.purchase_sales = 'P'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS p_month_6_premium_value,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 0 AND t.purchase_sales = 'S'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS s_month_1_premium_value,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 1 AND t.purchase_sales = 'S'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS s_month_2_premium_value,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 2 AND t.purchase_sales = 'S'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS s_month_3_premium_value,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 3 AND t.purchase_sales = 'S'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS s_month_4_premium_value,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 4 AND t.purchase_sales = 'S'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS s_month_5_premium_value,
                    SUM
                       (CASE
                           WHEN t.no_of_months = 5 AND t.purchase_sales = 'S'
                              THEN qty * premium
                           ELSE 0
                        END
                       ) AS s_month_6_premium_value
               FROM (SELECT pcm.corporate_id, pcm.purchase_sales,
                            pdm.product_id, pdm.product_desc product_name,
                            qum.qty_unit_id base_qty_unit_id,
                            qum.qty_unit base_qty_unit, cm.cur_id base_cur_id,
                            cm.cur_code base_cur_code,
                            pkg_general.f_get_converted_quantity
                                                 (pdm.product_id,
                                                  pci.item_qty_unit_id,
                                                  pdm.base_quantity_unit,
                                                  pci.item_qty
                                                 ) qty,
                              pcqpd.premium_disc_value
                            * NVL (pffxd.fixed_fx_rate, 1) premium,
                            MONTHS_BETWEEN
                               (TRUNC
                                   ((CASE
                                        WHEN pcbpd.price_basis = 'Fixed'
                                           THEN pcm.issue_date
                                        ELSE pofh.qp_end_date
                                     END
                                    ),
                                    'mm'
                                   ),
                                TRUNC (SYSDATE, 'mm')
                               ) no_of_months
                       FROM pci_physical_contract_item pci,
                            pcm_physical_contract_main pcm,
                            pcdi_pc_delivery_item pcdi,
                            ak_corporate akc,
                            pcpd_pc_product_definition pcpd,
                            pdm_productmaster pdm,
                            pcpq_pc_product_quality pcpq,
                            pcdb_pc_delivery_basis pcdb,
                            pcqpd_pc_qual_premium_discount pcqpd,
                            v_ppu_pum ppu,
                            poch_price_opt_call_off_header poch,
                            pocd_price_option_calloff_dtls pocd,
                            pcbpd_pc_base_price_detail pcbpd,
                            pcbph_pc_base_price_header pcbph,
                            (SELECT *
                               FROM pofh_price_opt_fixation_header pfh
                              WHERE pfh.internal_gmr_ref_no IS NULL
                                AND pfh.is_active = 'Y') pofh,
                            qum_quantity_unit_master qum,
                            cm_currency_master cm,
                            pffxd_phy_formula_fx_details pffxd
                      WHERE pcm.internal_contract_ref_no =
                                                 pcdi.internal_contract_ref_no
                        AND pcdi.pcdi_id = pci.pcdi_id
                        AND pci.pcpq_id = pcpq.pcpq_id
                        AND pcm.contract_status = 'In Position'
                        AND pcm.corporate_id = akc.corporate_id
                        AND pcm.internal_contract_ref_no =
                                                 pcpd.internal_contract_ref_no
                        AND pcpd.product_id = pdm.product_id
                        AND pcpd.pcpd_id = pcpq.pcpd_id
                        AND pcpq.is_active = 'Y'
                        AND pci.is_active = 'Y'
                        AND pcdi.is_active = 'Y'
                        AND pcdb.is_active = 'Y'
                        AND pcqpd.is_active = 'Y'
                        AND pci.pcdb_id = pcdb.pcdb_id
                        AND pcdb.internal_contract_ref_no =
                                                 pcdi.internal_contract_ref_no
                        AND pci.pcpq_id = pcpq.pcpq_id
                        AND pci.pcdb_id = pcdb.pcdb_id
                        AND pcm.contract_type = 'BASEMETAL'
                        AND pcqpd.internal_contract_ref_no =
                                                  pcm.internal_contract_ref_no
                        AND ppu.cur_id = akc.base_cur_id
                        AND ppu.weight_unit_id = pdm.base_quantity_unit
                        AND NVL (ppu.weight, 1) = 1
                        AND ppu.product_id = pdm.product_id
                        AND poch.pcdi_id = pcdi.pcdi_id
                        AND poch.poch_id = pocd.poch_id
                        AND pocd.pcbpd_id = pcbpd.pcbpd_id
                        AND pcbpd.pcbph_id = pcbph.pcbph_id
                        AND poch.is_active = 'Y'
                        AND pocd.is_active = 'Y'
                        AND pcbpd.is_active = 'Y'
                        AND pcbph.is_active = 'Y'
                        AND pocd.pocd_id = pofh.pocd_id(+)
                        AND pdm.base_quantity_unit = qum.qty_unit_id
                        AND cm.cur_id = akc.base_cur_id
                        AND pffxd.pffxd_id = pcqpd.pffxd_id
                        AND pffxd.is_active = 'Y'
                     UNION ALL
                     SELECT pcm.corporate_id, pcm.purchase_sales,
                            pdm.product_id, pdm.product_desc product_name,
                            qum.qty_unit_id base_qty_unit_id,
                            qum.qty_unit base_qty_unit, cm.cur_id base_cur_id,
                            cm.cur_code base_cur_code,
                            pkg_general.f_get_converted_quantity
                                                 (pdm.product_id,
                                                  pci.item_qty_unit_id,
                                                  pdm.base_quantity_unit,
                                                  pci.item_qty
                                                 ) qty,
                              pcqpd.premium_disc_value
                            * NVL (pffxd.fixed_fx_rate, 1) premium,
                            MONTHS_BETWEEN
                               (TRUNC
                                   ((CASE
                                        WHEN pcbpd.price_basis = 'Fixed'
                                           THEN pcm.issue_date
                                        ELSE pfqpp.qp_period_to_date
                                     END
                                    ),
                                    'mm'
                                   ),
                                TRUNC (SYSDATE, 'mm')
                               ) no_of_months
                       FROM pci_physical_contract_item pci,
                            pcm_physical_contract_main pcm,
                            pcdi_pc_delivery_item pcdi,
                            ak_corporate akc,
                            pcpd_pc_product_definition pcpd,
                            pdm_productmaster pdm,
                            pcpq_pc_product_quality pcpq,
                            pcdb_pc_delivery_basis pcdb,
                            pcqpd_pc_qual_premium_discount pcqpd,
                            qum_quantity_unit_master qum,
                            cm_currency_master cm,
                            v_ppu_pum ppu,
                            pcipf_pci_pricing_formula pcipf,
                            pcbph_pc_base_price_header pcbph,
                            pcbpd_pc_base_price_detail pcbpd,
                            ppfh_phy_price_formula_header ppfh,
                            pfqpp_phy_formula_qp_pricing pfqpp,
                            pffxd_phy_formula_fx_details pffxd
                      WHERE pcm.internal_contract_ref_no =
                                                 pcdi.internal_contract_ref_no
                        AND pcdi.pcdi_id = pci.pcdi_id
                        AND pci.pcpq_id = pcpq.pcpq_id
                        AND pcm.contract_status = 'In Position'
                        AND pcm.corporate_id = akc.corporate_id
                        AND pcm.internal_contract_ref_no =
                                                 pcpd.internal_contract_ref_no
                        AND pcpd.product_id = pdm.product_id
                        AND pcpd.pcpd_id = pcpq.pcpd_id
                        AND pcpq.is_active = 'Y'
                        AND pci.is_active = 'Y'
                        AND pcdi.is_active = 'Y'
                        AND pcdb.is_active = 'Y'
                        AND pcqpd.is_active = 'Y'
                        AND pci.pcdb_id = pcdb.pcdb_id
                        AND pcdb.internal_contract_ref_no =
                                                 pcdi.internal_contract_ref_no
                        AND pci.pcpq_id = pcpq.pcpq_id
                        AND pci.pcdb_id = pcdb.pcdb_id
                        AND pcm.contract_type = 'BASEMETAL'
                        AND pcqpd.internal_contract_ref_no =
                                                  pcm.internal_contract_ref_no
                        AND ppu.cur_id = akc.base_cur_id
                        AND ppu.weight_unit_id = pdm.base_quantity_unit
                        AND NVL (ppu.weight, 1) = 1
                        AND ppu.product_id = pdm.product_id
                        AND pdm.base_quantity_unit = qum.qty_unit_id
                        AND cm.cur_id = akc.base_cur_id
                        AND pci.internal_contract_item_ref_no =
                                           pcipf.internal_contract_item_ref_no
                        AND pcipf.pcbph_id = pcbph.pcbph_id
                        AND pcbph.pcbph_id = pcbpd.pcbph_id
                        AND pci.is_active = 'Y'
                        AND pcipf.is_active = 'Y'
                        AND pcbpd.is_active = 'Y'
                        AND pcbph.is_active = 'Y'
                        AND ppfh.ppfh_id = pfqpp.ppfh_id
                        AND ppfh.pcbpd_id = pcbpd.pcbpd_id
                        AND ppfh.is_active = 'Y'
                        AND pfqpp.is_active = 'Y'
                        AND pffxd.pffxd_id = pcqpd.pffxd_id
                        AND pffxd.is_active = 'Y') t
           GROUP BY t.product_id,
                    t.product_name,
                    t.base_qty_unit_id,
                    t.base_qty_unit,
                    t.base_cur_id,
                    t.base_cur_code,
                    t.corporate_id) tt;