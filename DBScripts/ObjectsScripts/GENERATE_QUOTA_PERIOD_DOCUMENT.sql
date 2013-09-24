CREATE OR REPLACE PROCEDURE "GENERATE_QUOTA_PERIOD_DOCUMENT" (
   p_internal_gmr_ref_no   VARCHAR2,
   p_docrefno              VARCHAR2,
   p_activity_id           VARCHAR2,
   p_doc_issue_date        VARCHAR2
)
IS
BEGIN
   INSERT INTO gmrqp_quota_period_d
               (internal_doc_ref_no, doc_issue_date, internal_gmr_ref_no,
                gmr_ref_no, cp_id, cp_name, cp_address, product_id,
                product_name, vessel_voyage_name, senders_ref_no, bl_date,
                bl_quantity, gmr_unit, landing_date, prov_payment_due_date,
                payment_term_id, payment_term, user_firstname, user_lastname)
      SELECT p_docrefno, p_doc_issue_date, gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no, phd.profileid cp_id, phd.companyname cp_name,
             (   pad.address_name
              || ','
              || cym.country_name
              || ','
              || sm.state_name
              || ','
              || cim.city_name
             ) AS cp_address,
             gmr.product_id, pdm.product_desc product_name,
             vd.vessel_voyage_name, gmr.senders_ref_no,
             TO_CHAR (gmr.bl_date, 'DD-Mon-YYYY') bl_date,
             f_format_to_char
                ((SELECT SUM
                            (pkg_general.f_get_converted_quantity
                                                            (agrd.product_id,
                                                             agrd.qty_unit_id,
                                                             qum.qty_unit_id,
                                                             agrd.qty
                                                            )
                            )
                    FROM agrd_action_grd agrd
                   WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                     AND agrd.status = 'Active'
                     AND agrd.action_no = agmr.action_no),
                 4
                ) bl_quantity,
             qum.qty_unit gmr_unit, gmr.landing_date,
             (CASE
                 WHEN (    pym.base_date = 'Arrival_Date'
                       AND landed.landing_date IS NOT NULL
                      )
                    THEN TO_CHAR (  landed.landing_date
                                  + pym.number_of_credit_days,
                                  'dd-Mon-yyyy'
                                 )
                 ELSE ''
              END
             ) prov_payment_due_date,
             pym.payment_term_id payment_term_id,
             pym.payment_term payment_term, gab.firstname AS user_firstname,
             gab.lastname AS user_lastname
        FROM agmr_action_gmr agmr,
             gmr_goods_movement_record gmr,
             vd_voyage_detail vd,
             pcm_physical_contract_main pcm,
             phd_profileheaderdetails phd,
             pdm_productmaster pdm,
             qum_quantity_unit_master qum,
             pad_profile_addresses pad,
             cym_countrymaster cym,
             sm_state_master sm,
             cim_citymaster cim,
             pym_payment_terms_master pym,
             pyme_payment_term_ext pyme,
             (SELECT MAX (axs.action_date) landing_date
                FROM gmr_goods_movement_record gmr,
                     axs_action_summary axs,
                     agmr_action_gmr agmr,
                     gam_gmr_action_mapping gam
               WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                 AND gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no
                 AND gam.action_no = agmr.action_no
                 AND gam.internal_action_ref_no = axs.internal_action_ref_no
                 AND gmr.is_deleted = 'N'
                 AND agmr.is_deleted = 'N'
                 AND agmr.gmr_latest_action_action_id IN
                                        ('landingDetail', 'warehouseReceipt')
                 AND gmr.internal_gmr_ref_no = p_internal_gmr_ref_no) landed,
             ds_document_summary ds,
             ak_corporate_user aku,
             gab_globaladdressbook gab
       WHERE agmr.internal_contract_ref_no = pcm.internal_contract_ref_no
         AND pcm.cp_id = phd.profileid
         AND gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
         AND gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
         AND pdm.product_id = gmr.product_id
         AND gmr.qty_unit_id = qum.qty_unit_id
         AND pad.profile_id = phd.profileid
         AND pad.address_id = pcm.cp_address_id
         AND pad.country_id = cym.country_id(+)
         AND pad.state_id = sm.state_id(+)
         AND pad.city_id = cim.city_id(+)
         AND ds.created_by = aku.user_id
         AND aku.gabid = gab.gabid
         AND agmr.gmr_latest_action_action_id IN
                ('shipmentDetail', 'airDetail', 'truckDetail', 'railDetail',
                 'warehouseReceipt')
         AND agmr.is_deleted = 'N'
         AND gmr.is_deleted = 'N'
         AND gmr.is_internal_movement = 'N'
         AND pcm.payment_term_id = pym.payment_term_id
         AND pym.base_date = pyme.base_date(+)
         AND ds.internal_doc_ref_no = p_docrefno
         AND gmr.internal_gmr_ref_no = p_internal_gmr_ref_no;

   INSERT INTO gmrqpc_child_qp_d
               (internal_doc_ref_no, internal_gmr_ref_no, element_id,
                element_name, quota_period, event_name)
      (SELECT p_docrefno, gcim.internal_gmr_ref_no,
              poch.element_id AS element_id, aml.attribute_name element_name,
              pofh.qp_start_date || ' to ' || pofh.qp_end_date AS qp_period,
              pfqpp.event_name
         FROM gcim_gmr_contract_item_mapping gcim,
              pci_physical_contract_item pci,
              poch_price_opt_call_off_header poch,
              pocd_price_option_calloff_dtls pocd,
              pofh_price_opt_fixation_header pofh,
              ppfh_phy_price_formula_header ppfh,
              pfqpp_phy_formula_qp_pricing pfqpp,
              aml_attribute_master_list aml
        WHERE gcim.internal_gmr_ref_no = p_internal_gmr_ref_no
          AND gcim.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
          AND aml.attribute_id = poch.element_id
          AND NVL (pci.is_called_off, 'Y') = 'Y'
          AND pci.pcdi_id = poch.pcdi_id
          AND poch.poch_id = pocd.poch_id
          AND pocd.pocd_id = pofh.pocd_id
          AND pocd.qp_period_type <> 'Event'
          AND pocd.is_active = 'Y'
          AND pocd.is_active = 'Y'
          AND pci.is_active = 'Y'
          AND pocd.pcbpd_id = ppfh.pcbpd_id
          AND pfqpp.ppfh_id = ppfh.ppfh_id
          AND pofh.is_active = 'Y'
       UNION ALL
       SELECT p_docrefno, pofh.internal_gmr_ref_no,
              poch.element_id AS element_id, aml.attribute_name element_name,
              pofh.qp_start_date || ' to ' || pofh.qp_end_date AS qp_period,
              pfqpp.event_name
         FROM pofh_price_opt_fixation_header pofh,
              pocd_price_option_calloff_dtls pocd,
              poch_price_opt_call_off_header poch,
              ppfh_phy_price_formula_header ppfh,
              pfqpp_phy_formula_qp_pricing pfqpp,
              aml_attribute_master_list aml
        WHERE pofh.internal_gmr_ref_no = p_internal_gmr_ref_no
          AND aml.attribute_id = poch.element_id
          AND pofh.is_active = 'Y'
          AND pofh.pocd_id = pocd.pocd_id
          AND pocd.is_active = 'Y'
          AND pocd.qp_period_type = 'Event'
          AND pocd.poch_id = poch.poch_id
          AND poch.is_active = 'Y'
          AND pocd.pcbpd_id = ppfh.pcbpd_id
          AND ppfh.is_active = 'Y'
          AND ppfh.ppfh_id = pfqpp.ppfh_id
          AND pfqpp.is_active = 'Y'
       UNION ALL
       SELECT p_docrefno, gcim.internal_gmr_ref_no,
              poch.element_id AS element_id, aml.attribute_name element_name,
              NULL AS qp_period, pfqpp.event_name AS eventname
         FROM gcim_gmr_contract_item_mapping gcim,
              pci_physical_contract_item pci,
              poch_price_opt_call_off_header poch,
              pocd_price_option_calloff_dtls pocd,
              ppfh_phy_price_formula_header ppfh,
              pfqpp_phy_formula_qp_pricing pfqpp,
              aml_attribute_master_list aml
        WHERE gcim.internal_gmr_ref_no = p_internal_gmr_ref_no
          AND gcim.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
          AND pci.pcdi_id = poch.pcdi_id
          AND aml.attribute_id = poch.element_id
          AND pci.is_active = 'Y'
          AND poch.is_active = 'Y'
          AND poch.poch_id = pocd.poch_id
          AND pocd.is_active = 'Y'
          AND pocd.qp_period_type = 'Event'
          AND pocd.pcbpd_id = ppfh.pcbpd_id
          AND ppfh.is_active = 'Y'
          AND ppfh.ppfh_id = pfqpp.ppfh_id
          AND pfqpp.is_active = 'Y'
          AND pocd.pocd_id NOT IN (
                 SELECT pofh.pocd_id
                   FROM pofh_price_opt_fixation_header pofh
                  WHERE pofh.internal_gmr_ref_no = p_internal_gmr_ref_no
                    AND pofh.is_active = 'Y'));
END;
/
