/* Formatted on 2013/03/19 15:16 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PROCEDURE "GENERATEPRICEFIXATIONDOCUMENT" (
   p_pfd_id           VARCHAR2,
   p_docrefno         VARCHAR2,
   p_activity_id      VARCHAR2,
   p_doc_issue_date   VARCHAR2
)
IS
   corporate_name          VARCHAR2 (100);
   cp_address              VARCHAR2 (100);
   cp_city                 VARCHAR2 (100);
   cp_country              VARCHAR2 (100);
   cp_zip                  VARCHAR2 (100);
   cp_state                VARCHAR2 (100);
   cp_name                 VARCHAR2 (100);
   cp_person_in_charge     VARCHAR2 (100);
   contract_type           VARCHAR2 (30);
   contract_ref_no         VARCHAR2 (30);
   delivery_item_ref_no    VARCHAR2 (80);
   pay_in_currency         VARCHAR2 (15);
   product                 VARCHAR2 (100);
   quality                 VARCHAR2 (200);
   element_name            VARCHAR2 (30);
   pricing_formula         VARCHAR2 (200);
   quota_period            VARCHAR2 (50);
   gmr_ref_no              VARCHAR2 (30);
   qp                      VARCHAR2 (50);
   currency_product        VARCHAR2 (30);
   quantity_unit           VARCHAR2 (30);
   price_type              VARCHAR2 (20);
   p_pofh_id               VARCHAR2 (20);
   is_delta_pricing        VARCHAR2 (10);
   purchase_sales          VARCHAR2 (30);
   is_payin_pricing_same   VARCHAR2 (10);
   premium_details         VARCHAR2 (2000);
   weighted_avg_price      NUMBER (25, 10);
   priced_qty              NUMBER (25, 10);
   any_day_pricing         CHAR (1 CHAR);
   fx_rate                 NUMBER (25, 10);
BEGIN
   SELECT ak.corporate_name, pad.address, cim.city_name, cym.country_name,
          pad.zip, sm.state_name, phd.companyname,
          gab.firstname || ' ' || gab.lastname, pcm.contract_type,
          pcm.contract_ref_no,
          (pcm.contract_ref_no || '-' || pcdi.delivery_item_no
          ),
          cm.cur_code, pdm.product_desc,
          (CASE
              WHEN pocd.qp_period_type = 'Event'
                 THEN (SELECT   stragg
                                     (gmrquality.quality_name)
                                                              AS quality_name
                           FROM (SELECT DISTINCT qat.quality_name,
                                                 pci.internal_contract_item_ref_no
                                                    AS internal_contract_item_ref_no,
                                                 gmr_in.internal_gmr_ref_no
                                                       AS internal_gmr_ref_no
                                            FROM gmr_goods_movement_record gmr_in,
                                                 grd_goods_record_detail grd,
                                                 pci_physical_contract_item pci,
                                                 pcpq_pc_product_quality pcpq,
                                                 qat_quality_attributes qat
                                           WHERE gmr_in.internal_gmr_ref_no =
                                                       grd.internal_gmr_ref_no
                                             AND grd.internal_contract_item_ref_no =
                                                    pci.internal_contract_item_ref_no
                                             AND pcpq.quality_template_id =
                                                                qat.quality_id
                                             AND pci.pcpq_id = pcpq.pcpq_id
                                             AND pcpq.is_active = 'Y'
                                             AND gmr_in.is_deleted = 'N'
                                             AND grd.is_deleted = 'N'
                                             AND grd.status = 'Active'
                                             AND pci.is_active = 'Y'
                                 UNION ALL
                                 SELECT DISTINCT qat.quality_name,
                                                 pci.internal_contract_item_ref_no
                                                    AS internal_contract_item_ref_no,
                                                 gmr_in.internal_gmr_ref_no
                                                       AS internal_gmr_ref_no
                                            FROM gmr_goods_movement_record gmr_in,
                                                 dgrd_delivered_grd grd,
                                                 pci_physical_contract_item pci,
                                                 pcpq_pc_product_quality pcpq,
                                                 qat_quality_attributes qat
                                           WHERE gmr_in.internal_gmr_ref_no =
                                                       grd.internal_gmr_ref_no
                                             AND grd.internal_contract_item_ref_no =
                                                    pci.internal_contract_item_ref_no
                                             AND pcpq.quality_template_id =
                                                                qat.quality_id
                                             AND pci.pcpq_id = pcpq.pcpq_id
                                             AND pcpq.is_active = 'Y'
                                             AND gmr_in.is_deleted = 'N'
                                             AND grd.status = 'Active'
                                             AND pci.is_active = 'Y') gmrquality
                          WHERE gmrquality.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no
                       GROUP BY gmrquality.internal_contract_item_ref_no,
                                gmrquality.internal_gmr_ref_no)
              ELSE (SELECT   stragg (qat.quality_name) AS quality_name
                        FROM qat_quality_attributes qat,
                             pcdiqd_di_quality_details pcdiqd,
                             pcdi_pc_delivery_item pcdi_in,
                             pcpq_pc_product_quality pcpq
                       WHERE pcdiqd.pcpq_id = pcpq.pcpq_id
                         AND pcdiqd.pcdi_id = pcdi_in.pcdi_id
                         AND pcdiqd.is_active = 'Y'
                         AND pcpq.is_active = 'Y'
                         AND pcpq.quality_template_id = qat.quality_id
                         AND pcdi_in.pcdi_id = pcdi.pcdi_id
                    GROUP BY pcdi_in.pcdi_id)
           END
          ),
          aml.attribute_name,
          (   pcbpd.qty_to_be_priced
           || '% of '
           || (CASE
                  WHEN pcbpd.price_basis = 'Formula'
                     THEN    ppfh.formula_name
                          || ' - '
                          || (SELECT   stragg
                                             (   dim.instrument_name
                                              || ' - '
                                              || ps.price_source_name
                                              || ' '
                                              || pp.price_point_name
                                              || ' '
                                              || apm.available_price_display_name
                                             )
                                  FROM dim_der_instrument_master dim,
                                       ppfd_phy_price_formula_details ppfd,
                                       pp_price_point pp,
                                       ps_price_source ps,
                                       apm_available_price_master apm
                                 WHERE dim.instrument_id = ppfd.instrument_id
                                   AND ppfd.is_active = 'Y'
                                   AND ppfh.ppfh_id = ppfd.ppfh_id
                                   AND ppfd.price_point_id = pp.price_point_id(+)
                                   AND ppfd.price_source_id =
                                                            ps.price_source_id
                                   AND ppfd.available_price_type_id =
                                                        apm.available_price_id
                              GROUP BY ppfh.ppfh_id)
                  WHEN pcbpd.price_basis = 'Index'
                     THEN (SELECT    dim.instrument_name
                                  || ' - '
                                  || ps.price_source_name
                                  || ' '
                                  || pp.price_point_name
                                  || ' '
                                  || apm.available_price_display_name
                             FROM dim_der_instrument_master dim,
                                  ppfd_phy_price_formula_details ppfd,
                                  pp_price_point pp,
                                  ps_price_source ps,
                                  apm_available_price_master apm
                            WHERE dim.instrument_id = ppfd.instrument_id
                              AND ppfd.is_active = 'Y'
                              AND ppfh.ppfh_id = ppfd.ppfh_id
                              AND ppfd.price_point_id = pp.price_point_id(+)
                              AND ppfd.price_source_id = ps.price_source_id
                              AND ppfd.available_price_type_id =
                                                        apm.available_price_id)
               END
              )
           || (CASE
                  WHEN pocd.qp_period_type = 'Event'
                     THEN    ', '
                          || pfqpp.no_of_event_months
                          || ' '
                          || pfqpp.event_name
               END
              )
          ),
          (CASE
              WHEN pcdi.delivery_period_type = 'Month'
                 THEN CASE
                        WHEN pcdi.delivery_from_month = pcdi.delivery_to_month
                        AND pcdi.delivery_from_year = pcdi.delivery_to_year
                           THEN    pcdi.delivery_from_month
                                || ' '
                                || pcdi.delivery_from_year
                        ELSE    pcdi.delivery_from_month
                             || ' '
                             || pcdi.delivery_from_year
                             || ' To '
                             || pcdi.delivery_to_month
                             || ' '
                             || pcdi.delivery_to_year
                     END
              ELSE CASE
              WHEN TO_CHAR (pcdi.delivery_from_date, 'dd-Mon-YYYY') =
                                TO_CHAR (pcdi.delivery_to_date, 'dd-Mon-YYYY')
                 THEN TO_CHAR (pcdi.delivery_from_date, 'dd-Mon-YYYY')
              ELSE    TO_CHAR (pcdi.delivery_from_date, 'dd-Mon-YYYY')
                   || ' To '
                   || TO_CHAR (pcdi.delivery_to_date, 'dd-Mon-YYYY')
           END
           END
          ),
          (CASE
              WHEN pocd.qp_period_type = 'Event'
                 THEN gmr.gmr_ref_no
              ELSE pfd.allocated_gmr_ref_no
           END
          ),
          (   TO_CHAR (pofh.qp_start_date, 'dd-Mon-YYYY')
           || ' to '
           || TO_CHAR (pofh.qp_end_date, 'dd-Mon-YYYY')
          ),
          pdm_curr.product_desc, qum.qty_unit,
          (CASE
              WHEN pcm.is_tolling_contract = 'Y'
                 THEN CASE
                        WHEN pcm.purchase_sales = 'P'
                           THEN 'Sell Tolling'
                        ELSE 'Buy Tolling'
                     END
              ELSE CASE
              WHEN pcm.purchase_sales = 'P'
                 THEN 'Purchase'
              ELSE 'Sales'
           END
           END
          ),
          (CASE
              WHEN pocd.pay_in_cur_id = pocd.pricing_cur_id
                 THEN 'Y'
              ELSE 'N'
           END
          ),
          getpremuimdetails (pcdi.pcdi_id), pofh.priced_qty,
          pocd.is_any_day_pricing
     INTO corporate_name, cp_address, cp_city, cp_country,
          cp_zip, cp_state, cp_name,
          cp_person_in_charge, contract_type,
          contract_ref_no,
          delivery_item_ref_no,
          pay_in_currency, product,
          quality,
          element_name,
          pricing_formula,
          quota_period,
          gmr_ref_no,
          qp,
          currency_product, quantity_unit,
          purchase_sales,
          is_payin_pricing_same,
          premium_details, priced_qty,
          any_day_pricing
     FROM pfd_price_fixation_details pfd,
          pofh_price_opt_fixation_header pofh,
          pocd_price_option_calloff_dtls pocd,
          poch_price_opt_call_off_header poch,
          pcdi_pc_delivery_item pcdi,
          pcm_physical_contract_main pcm,
          pcpd_pc_product_definition pcpd,
          pdm_productmaster pdm,
          ak_corporate ak,
          cm_currency_master cm,
          phd_profileheaderdetails phd,
          pad_profile_addresses pad,
          cym_countrymaster cym,
          cim_citymaster cim,
          sm_state_master sm,
          qum_quantity_unit_master qum,
          gab_globaladdressbook gab,
          gmr_goods_movement_record gmr,
          pcbpd_pc_base_price_detail pcbpd,
          pffxd_phy_formula_fx_details pffxd,
          ppfh_phy_price_formula_header ppfh,
          pfqpp_phy_formula_qp_pricing pfqpp,
          pdm_productmaster pdm_curr,
          aml_attribute_master_list aml
    WHERE pfd.pofh_id = pofh.pofh_id
      AND pofh.pocd_id = pocd.pocd_id
      AND pocd.poch_id = poch.poch_id
      AND poch.pcdi_id = pcdi.pcdi_id
      AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pcpd.product_id = pdm.product_id
      AND pcpd.input_output = 'Input'
      AND pcm.corporate_id = ak.corporate_id
      AND pcm.invoice_currency_id = cm.cur_id
      AND pcm.cp_id = phd.profileid
      AND phd.profileid = pad.profile_id(+)
      AND pad.country_id = cym.country_id(+)
      AND pad.city_id = cim.city_id(+)
      AND pad.state_id = sm.state_id(+)
      AND pad.address_type(+) = 'Main'
      AND pcm.cp_person_in_charge_id = gab.gabid(+)
      AND pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
      AND pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
      AND pocd.pcbpd_id = pcbpd.pcbpd_id
      AND pcbpd.pcbpd_id = ppfh.pcbpd_id
      AND pcbpd.pffxd_id = pffxd.pffxd_id
      AND pffxd.currency_pair_instrument = pdm_curr.product_id(+)
      AND pocd.element_id = aml.attribute_id(+)
      AND pfqpp.ppfh_id = ppfh.ppfh_id
      AND pcbpd.is_active = 'Y'
      AND ppfh.is_active = 'Y'
      AND ppfh.ppfh_id = pfqpp.ppfh_id
      AND NVL (pfd.is_hedge_correction, 'N') = 'N'
      AND pfd.pfd_id = p_pfd_id;

   /** for weighted avg price */
   SELECT (SUM (pfd.qty_fixed * pfd.user_price)) / SUM (pfd.qty_fixed),
          AVG (pfd.fx_rate)
     INTO weighted_avg_price,
          fx_rate
     FROM pofh_price_opt_fixation_header pofh,
          pfd_price_fixation_details pfd,
          pocd_price_option_calloff_dtls pocd
    WHERE pofh.pofh_id = pfd.pofh_id
      AND pocd.pocd_id = pofh.pocd_id
      AND pocd.is_any_day_pricing = 'N'
      AND pfd.is_hedge_correction = 'N'
      AND pfd.is_active = 'Y'
      AND pofh.is_active = 'Y'
      AND NVL (pfd.is_hedge_correction, 'N') = 'N'
      AND pofh.pofh_id IN (SELECT pfd.pofh_id
                             FROM pfd_price_fixation_details pfd
                            WHERE pfd.pfd_id = p_pfd_id);

   INSERT INTO pfd_d
               (internal_doc_ref_no, corporate_name, cp_address, cp_city,
                cp_country, cp_zip, cp_state, cp_name, cp_person_in_charge,
                contract_type, contract_ref_no, delivery_item_ref_no,
                pay_in_currency, product, quality, element_name,
                pricing_formula, quota_period, gmr_ref_no, qp,
                currency_product, quantity_unit, doc_issue_date,
                purchase_sales, premium, weighted_avg_price,
                priced_qty, any_day_pricing, fx_rate
               )
        VALUES (p_docrefno, corporate_name, cp_address, cp_city,
                cp_country, cp_zip, cp_state, cp_name, cp_person_in_charge,
                contract_type, contract_ref_no, delivery_item_ref_no,
                pay_in_currency, product, quality, element_name,
                pricing_formula, quota_period, gmr_ref_no, qp,
                currency_product, quantity_unit, p_doc_issue_date,
                purchase_sales, premium_details, weighted_avg_price,
                priced_qty, any_day_pricing, fx_rate
               );

   /** Check if delta pricing exist for that pfd  */
   SELECT NVL (pfd.is_delta_pricing, 'N')
     INTO is_delta_pricing
     FROM pfd_price_fixation_details pfd
    WHERE pfd.pfd_id = p_pfd_id;

   /** Get the price type and based on that insert into child  */
   SELECT (CASE
              WHEN pocd.is_any_day_pricing = 'Y'
              AND pfqpp.is_spot_pricing = 'Y'
                 THEN 'Spot'
              WHEN pocd.is_any_day_pricing = 'Y'
                 THEN 'Price By Request'
              ELSE (CASE
                       WHEN pfd.is_delta_pricing = 'Y'
                          THEN 'Spot'
                       ELSE 'Average'
                    END
                   )
           END
          ),
          pfd.pofh_id
     INTO price_type,
          p_pofh_id
     FROM pfd_price_fixation_details pfd,
          pofh_price_opt_fixation_header pofh,
          pocd_price_option_calloff_dtls pocd,
          ppfh_phy_price_formula_header ppfh,
          pfqpp_phy_formula_qp_pricing pfqpp
    WHERE pfd.pofh_id = pofh.pofh_id
      AND pofh.pocd_id = pocd.pocd_id
      AND pocd.pricing_formula_id = ppfh.ppfh_id
      AND ppfh.ppfh_id = pfqpp.ppfh_id
      AND NVL (pfd.is_hedge_correction, 'N') = 'N'
      AND pfd.pfd_id = p_pfd_id;

   IF (price_type = 'Average' AND is_delta_pricing = 'N')
   THEN
      INSERT INTO pfd_child_d
                  (pfd_id, internal_doc_ref_no, price_fixation_ref_no, price,
                   price_unit, price_fixation_date, priced_quantity, fx_rate,
                   price_type)
         (SELECT pfd.pfd_id AS pfd_id, p_docrefno,
                 axs.action_ref_no AS price_fixation_ref_no,
                 pfd.user_price AS price, pum.price_unit_name AS price_unit,
                 TO_CHAR (pfd.as_of_date,
                          'dd-Mon-YYYY'
                         ) AS price_fixation_date,
                 pfd.qty_fixed AS priced_quantity,
                 (CASE
                     WHEN is_payin_pricing_same = 'Y'
                        THEN '1'
                     ELSE pfd.fx_rate || ''
                  END
                 ) AS fx_rate,
                 price_type
            FROM pfd_price_fixation_details pfd,
                 pofh_price_opt_fixation_header pofh,
                 ppu_product_price_units ppu,
                 pum_price_unit_master pum,
                 pfam_price_fix_action_mapping pfam,
                 axs_action_summary axs
           WHERE pfd.pofh_id = pofh.pofh_id
             AND pfam.internal_action_ref_no = axs.internal_action_ref_no
             AND pfd.pfd_id = pfam.pfd_id
             AND pfd.price_unit_id = ppu.internal_price_unit_id
             AND ppu.price_unit_id = pum.price_unit_id
             AND pfd.is_active = 'Y'
             AND pfam.is_active = 'Y'
             AND NVL (pfd.is_hedge_correction, 'N') = 'N'
             AND (pfd.is_delta_pricing IS NULL OR pfd.is_delta_pricing != 'Y'
                 )
             AND pofh.pofh_id = p_pofh_id);
   ELSE
      INSERT INTO pfd_child_d
                  (pfd_id, internal_doc_ref_no, price_fixation_ref_no, price,
                   price_unit, price_fixation_date, priced_quantity, fx_rate,
                   price_type)
         (SELECT pfd.pfd_id AS pfd_id, p_docrefno,
                 axs.action_ref_no AS price_fixation_ref_no,
                 pfd.user_price AS price, pum.price_unit_name AS price_unit,
                 TO_CHAR (pfd.as_of_date,
                          'dd-Mon-YYYY'
                         ) AS price_fixation_date,
                 pfd.qty_fixed AS priced_quantity,
                 (CASE
                     WHEN is_payin_pricing_same = 'Y'
                        THEN '1'
                     ELSE pfd.fx_rate || ''
                  END
                 ) AS fx_rate,
                 price_type
            FROM pfd_price_fixation_details pfd,
                 ppu_product_price_units ppu,
                 pum_price_unit_master pum,
                 pfam_price_fix_action_mapping pfam,
                 axs_action_summary axs
           WHERE pfd.pfd_id = pfam.pfd_id
             AND pfam.internal_action_ref_no = axs.internal_action_ref_no
             AND pfd.price_unit_id = ppu.internal_price_unit_id
             AND ppu.price_unit_id = pum.price_unit_id
             AND pfd.is_active = 'Y'
             AND NVL (pfd.is_hedge_correction, 'N') = 'N'
             AND pfam.is_active = 'Y'
             AND pfd.pfd_id = p_pfd_id);
   END IF;
END;
/