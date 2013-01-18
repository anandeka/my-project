
CREATE OR REPLACE FORCE VIEW v_list_audit_log 
AS
   SELECT   "ACTIVITYDATE", "ACTIVITYTIME", "ACTIONPERFORMED", "ENTITY",
            "ENTITYREFNO", "USERNAME", "ACTIONREFNO", "ACTIONID",
            "CORPORATE_ID"
            -- CDC QUERY
       FROM (SELECT TO_CHAR (axs.created_date, 'DD-MM-YYYY') AS activitydate,
                    TO_CHAR (axs.created_date, 'hh24:mi') AS activitytime,
                    axm.action_name AS actionperformed,
                    axm.entity_id AS entity,
                    dt.derivative_ref_no AS entityrefno,
                    aku.login_name AS username,
                    axs.internal_action_ref_no AS actionrefno,
                    axm.action_id AS actionid, axs.corporate_id
               FROM axs_action_summary axs,
                    axm_action_master axm,
                    dam_derivative_action_amapping dam,
                    dt_derivative_trade dt,
                    ak_corporate_user aku
              WHERE axs.action_id = axm.action_id
                AND dam.internal_action_ref_no = axs.internal_action_ref_no
                AND dam.internal_derivative_ref_no =
                                                 dt.internal_derivative_ref_no
                AND axs.created_by = aku.user_id
             UNION ALL
             -- CURRENCY TRADE QUERY
             SELECT TO_CHAR (axs.created_date, 'DD-MM-YYYY') AS activitydate,
                    TO_CHAR (axs.created_date, 'hh24:mi') AS activitytime,
                    axm.action_name AS actionperformed,
                    axm.entity_id AS entity,
                    ct.treasury_ref_no AS entityrefno,
                    aku.login_name AS username,
                    axs.internal_action_ref_no AS actionrefno,
                    axm.action_id AS actionid, axs.corporate_id
               FROM axs_action_summary axs,
                    axm_action_master axm,
                    cam_currency_action_amapping cam,
                    ct_currency_trade ct,
                    ak_corporate_user aku
              WHERE axs.action_id = axm.action_id
                AND cam.internal_action_ref_no = axs.internal_action_ref_no
                AND cam.internal_treasury_ref_no =
                                                  ct.internal_treasury_ref_no
                AND axs.created_by = aku.user_id
             UNION ALL
             -- INVOICE QUERY
             SELECT TO_CHAR (axs.created_date, 'DD-MM-YYYY') AS activitydate,
                    TO_CHAR (axs.created_date, 'hh24:mi') AS activitytime,
                    axm.action_name AS actionperformed,
                    axm.entity_id AS entity,
                    invs.invoice_ref_no AS entityrefno,
                    aku.login_name AS username,
                    axs.internal_action_ref_no AS actionrefno,
                    axm.action_id AS actionid, axs.corporate_id
               FROM axs_action_summary axs,
                    axm_action_master axm,
                    is_invoice_summary invs,
                    al_audit_log al,
                    ak_corporate_user aku,
                    iam_invoice_action_mapping iam
              WHERE invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
                AND iam.invoice_action_ref_no = axs.internal_action_ref_no
                AND al.internal_action_ref_no(+) = axs.internal_action_ref_no
                AND axs.action_id = axm.action_id
                AND axs.created_by = aku.user_id
             UNION ALL
             -- CONTRACT QUERY
             SELECT TO_CHAR (axs.created_date, 'DD-MM-YYYY') AS activitydate,
                    TO_CHAR (axs.created_date, 'hh24:mi') AS activitytime,
                    axm.action_name AS actionperformed,
                    axm.entity_id AS entity,
                    pcm.contract_ref_no AS entityrefno,
                    aku.login_name AS username,
                    axs.internal_action_ref_no AS actionrefno,
                    axm.action_id AS actionid, axs.corporate_id
               FROM axs_action_summary axs,
                    axm_action_master axm,
                    pca_physical_contract_action pca,
                    pcm_physical_contract_main pcm,
                    ak_corporate_user aku
              WHERE axs.action_id = axm.action_id
                AND pca.internal_action_ref_no = axs.internal_action_ref_no
                AND pcm.internal_contract_ref_no =
                                                  pca.internal_contract_ref_no
                AND axs.created_by = aku.user_id
             UNION ALL
             -- LOGISTICS QUERY
             SELECT TO_CHAR (axs.created_date, 'DD-MM-YYYY') AS activitydate,
                    TO_CHAR (axs.created_date, 'hh24:mi') AS activitytime,
                    axm.action_name AS actionperformed,
                    axm.entity_id AS entity, gmr.gmr_ref_no AS entityrefno,
                    aku.login_name AS username,
                    axs.internal_action_ref_no AS actionrefno,
                    axm.action_id AS actionid, axs.corporate_id
               FROM axs_action_summary axs,
                    axm_action_master axm,
                    gmr_goods_movement_record gmr,
                    gam_gmr_action_mapping gam,
                    al_audit_log al,
                    ak_corporate_user aku
              WHERE axs.action_id = axm.action_id
                AND axs.internal_action_ref_no = gam.internal_action_ref_no
                AND gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no
                AND axs.internal_action_ref_no = al.internal_action_ref_no(+)
                AND axs.created_by = aku.user_id
             UNION ALL
             -- PHYSICAL CALL-OFF QUERY
             SELECT TO_CHAR (axs.created_date, 'DD-MM-YYYY') AS activitydate,
                    TO_CHAR (axs.created_date, 'hh24:mi') AS activitytime,
                    axm.action_name AS actionperformed,
                    axm.entity_id AS entity,
                    pcm.contract_ref_no AS entityrefno,
                    aku.login_name AS username,
                    axs.internal_action_ref_no AS actionrefno,
                    axm.action_id AS actionid, axs.corporate_id
               FROM axs_action_summary axs,
                    axm_action_master axm,
                    ak_corporate_user aku,
                    pcm_physical_contract_main pcm,
                    cod_call_off_details cod,
                    pcdi_pc_delivery_item pcdi
              WHERE axs.action_id = axm.action_id
                AND axs.internal_action_ref_no = cod.internal_action_ref_no
                AND cod.pcdi_id = pcdi.pcdi_id
                AND pcm.internal_contract_ref_no =
                                                 pcdi.internal_contract_ref_no
                AND axs.created_by = aku.user_id
             UNION ALL
             -- PRICING CALL-OFF QUERY
             SELECT TO_CHAR (axs.created_date, 'DD-MM-YYYY') AS activitydate,
                    TO_CHAR (axs.created_date, 'hh24:mi') AS activitytime,
                    axm.action_name AS actionperformed,
                    axm.entity_id AS entity,
                    pcm.contract_ref_no AS entityrefno,
                    aku.login_name AS username,
                    axs.internal_action_ref_no AS actionrefno,
                    axm.action_id AS actionid, axs.corporate_id
               FROM axs_action_summary axs,
                    axm_action_master axm,
                    ak_corporate_user aku,
                    pcm_physical_contract_main pcm,
                    pcdi_pc_delivery_item pcdi,
                    poch_price_opt_call_off_header poch,
                    pcbph_pc_base_price_header pcbph,
                    pci_physical_contract_item pci
              WHERE axs.action_id = axm.action_id
                AND axs.internal_action_ref_no = poch.internal_action_ref_no
                AND poch.pcbph_id = pcbph.pcbph_id
                AND pcdi.pcdi_id = pci.pcdi_id
                AND poch.pcdi_id = pcdi.pcdi_id
                AND pcdi.is_price_optionality_present = 'Y'
                AND pcdi.internal_contract_ref_no =
                                                  pcm.internal_contract_ref_no
                AND axs.created_by = aku.user_id
             UNION ALL
             -- PRICE FIXATION CREATE QUERY
             SELECT DISTINCT TO_CHAR (axs.created_date,
                                      'DD-MM-YYYY'
                                     ) AS activitydate,
                             TO_CHAR (axs.created_date,
                                      'hh24:mi'
                                     ) AS activitytime,
                             axm.action_name AS actionperformed,
                             axm.entity_id AS entity,
                             axs.action_ref_no AS entityrefno,
                             aku.login_name AS username,
                             axs.internal_action_ref_no AS actionrefno,
                             axm.action_id AS actionid, axs.corporate_id
                        FROM pfd_price_fixation_details pfd,
                             pfam_price_fix_action_mapping pfam,
                             axs_action_summary axs,
                             axm_action_master axm,
                             ak_corporate_user aku
                       WHERE pfam.pfd_id = pfd.pfd_id
                         AND axs.internal_action_ref_no =
                                                   pfam.internal_action_ref_no
                         AND axs.action_id = axm.action_id
                         AND axs.created_by = aku.user_id
                         AND pfd.is_active = 'Y'
                         AND pfam.is_active = 'Y'
                         AND NVL (pfd.is_cancel, 'N') = 'N'
             UNION ALL
             -- PRICE FIXATION CANCEL QUERY
             SELECT DISTINCT TO_CHAR (axs.created_date,
                                      'DD-MM-YYYY'
                                     ) AS activitydate,
                             TO_CHAR (axs.created_date,
                                      'hh24:mi'
                                     ) AS activitytime,
                             axm.action_name AS actionperformed,
                             axm.entity_id AS entity,
                             axs.action_ref_no AS entityrefno,
                             aku.login_name AS username,
                             axs.internal_action_ref_no AS actionrefno,
                             axm.action_id AS actionid, axs.corporate_id
                        FROM pfd_price_fixation_details pfd,
                             axs_action_summary axs,
                             axm_action_master axm,
                             ak_corporate_user aku
                       WHERE axs.internal_action_ref_no =
                                                      pfd.cancel_action_ref_no
                         AND axs.action_id = axm.action_id
                         AND axs.created_by = aku.user_id
                         AND pfd.is_active = 'N'
                         AND pfd.is_cancel = 'Y') outer_temp
   ORDER BY TO_DATE (outer_temp.activitydate, 'DD-MM-YYYY') DESC,
            outer_temp.actionrefno DESC;

