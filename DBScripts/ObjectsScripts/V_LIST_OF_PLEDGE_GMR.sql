CREATE OR REPLACE VIEW V_LIST_OF_PLEDGE_GMR
AS
SELECT gmr.corporate_id,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       gmr.internal_contract_ref_no,
       pcm.contract_ref_no contract_ref_no,
       gepd.supplier_cp_id supplier_cp_id,
       phd_supplier.companyname supplier_cp_name,
       gepd.pledge_cp_id pledge_cp_id,
       phd_pledge.companyname pledge_cp_name,
       axs.action_id,
       axm.action_name action_name,
       axs.internal_action_ref_no,
       axs.eff_date activity_date,
       axs.action_ref_no,
       gmr.qty,
       gmr.qty_unit_id,
       qum.qty_unit,
       gepd.element_id,
       aml.attribute_name element_name,
       gepd.product_id,
       pdm.product_desc product_name,
       gepd.element_type,
       (SELECT to_char(pofh.qp_start_date,
                       'MM/DD/YYYY')
        FROM   pofh_price_opt_fixation_header pofh
        WHERE  pofh.is_active = 'Y'
        AND    pofh.internal_gmr_ref_no = gepd.internal_gmr_ref_no) qp_start_date,
       (SELECT to_char(pofh.qp_end_date,
                       'MM/DD/YYYY')
        FROM   pofh_price_opt_fixation_header pofh
        WHERE  pofh.is_active = 'Y'
        AND    pofh.internal_gmr_ref_no = gepd.internal_gmr_ref_no) qp_end_date,
       (SELECT invs.invoice_issue_date
        FROM   is_invoice_summary          invs,
               iid_invoicable_item_details iid
        WHERE  invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND    invs.internal_invoice_ref_no =
               (SELECT MAX(invs_temp.internal_invoice_ref_no) internal_invoice_ref_no
                 FROM   is_invoice_summary          invs_temp,
                        iid_invoicable_item_details iid
                 WHERE  invs_temp.internal_invoice_ref_no =
                        iid.internal_invoice_ref_no
                 AND    invs_temp.is_active = 'Y'
                 AND    iid.internal_gmr_ref_no = gepd.pledge_input_gmr)) supplier_inv_date,
       (SELECT invs.invoice_ref_no
        FROM   is_invoice_summary          invs,
               iid_invoicable_item_details iid
        WHERE  invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND    invs.internal_invoice_ref_no =
               (SELECT MAX(invs_temp.internal_invoice_ref_no) internal_invoice_ref_no
                 FROM   is_invoice_summary          invs_temp,
                        iid_invoicable_item_details iid
                 WHERE  invs_temp.internal_invoice_ref_no =
                        iid.internal_invoice_ref_no
                 AND    invs_temp.is_active = 'Y'
                 AND    iid.internal_gmr_ref_no = gepd.pledge_input_gmr)) supplier_inv_no,
       (SELECT invs.invoice_issue_date
        FROM   is_invoice_summary          invs,
               iid_invoicable_item_details iid
        WHERE  invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND    invs.internal_invoice_ref_no =
               (SELECT MAX(invs_temp.internal_invoice_ref_no) internal_invoice_ref_no
                 FROM   is_invoice_summary          invs_temp,
                        iid_invoicable_item_details iid
                 WHERE  invs_temp.internal_invoice_ref_no =
                        iid.internal_invoice_ref_no
                 AND    invs_temp.is_active = 'Y'
                 AND    iid.internal_gmr_ref_no = gepd.internal_gmr_ref_no)) pledge_inv_date,
       (SELECT invs.invoice_ref_no
        FROM   is_invoice_summary          invs,
               iid_invoicable_item_details iid
        WHERE  invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND    invs.internal_invoice_ref_no =
               (SELECT MAX(invs_temp.internal_invoice_ref_no) internal_invoice_ref_no
                 FROM   is_invoice_summary          invs_temp,
                        iid_invoicable_item_details iid
                 WHERE  invs_temp.internal_invoice_ref_no =
                        iid.internal_invoice_ref_no
                 AND    invs_temp.is_active = 'Y'
                 AND    iid.internal_gmr_ref_no = gepd.internal_gmr_ref_no)) pledge_inv_no,
       gmr_afs.assay_finalized assay_finalized
FROM   gmr_goods_movement_record      gmr,
       gam_gmr_action_mapping         gam,
       axs_action_summary             axs,
       qum_quantity_unit_master       qum,
       axm_action_master              axm,
       gepd_gmr_element_pledge_detail gepd,
       phd_profileheaderdetails       phd_pledge,
       phd_profileheaderdetails       phd_supplier,
       pcm_physical_contract_main     pcm,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm,
       v_gmr_assay_finalized_status   gmr_afs
WHERE  gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
AND    gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
AND    axs.internal_action_ref_no(+) = gam.internal_action_ref_no
AND    axs.status(+) = 'Active'
AND    axm.action_id(+) = axs.action_id
AND    gmr.is_deleted = 'N'
AND    gmr.qty_unit_id = qum.qty_unit_id
AND    nvl(gmr.is_settlement_gmr,
           'N') = 'N'
AND    nvl(gmr.tolling_gmr_type,
           'None Tolling') IN ('Pledge')
AND    gmr.is_internal_movement = 'N'
AND    gepd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    gepd.is_active = 'Y'
AND    phd_pledge.profileid = gepd.pledge_cp_id
AND    phd_supplier.profileid = gepd.supplier_cp_id
AND    pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
AND    aml.attribute_id = gepd.element_id
AND    pdm.product_id = gepd.product_id
AND    gmr_afs.internal_gmr_ref_no = gepd.pledge_input_gmr;
