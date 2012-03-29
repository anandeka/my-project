create or replace view v_bi_list_of_pledge_gmr as
SELECT gmr.corporate_id corporate,
	 gcd.groupname corporate_group,
	 cpc.profit_center_name profit_center,
	 pcm.contract_ref_no,
	 pci.del_distribution_item_no,
	 pcm.contract_ref_no || '-' || pci.del_distribution_item_no contract_item_ref_no,
	 gmr.gmr_ref_no,
	 axs.eff_date activity_date,
	 gepd.supplier_cp_id,
	 phd_supplier.companyname supplier_cp_name,
	 gepd.pledge_cp_id pledge_cp_id,
	 phd_pledge.companyname pledge_cp_name,
	 aml.attribute_name element,
	 grd.payable_returnable_type settlement_type,
	 decode(gmr_afs.assay_finalized, 'N', 'No', 'Yes') assay_finalized,
	 (SELECT to_char(MAX(pofh.qp_end_date), 'dd-Mon-yyyy')
	  FROM   pofh_price_opt_fixation_header pofh
	  WHERE  pofh.is_active = 'Y'
	  AND    pofh.internal_gmr_ref_no = gepd.internal_gmr_ref_no) qp_end_date,
	 (SELECT MAX(invs.invoice_type_name)
	  FROM   is_invoice_summary          invs,
		   iid_invoicable_item_details iid
	  WHERE  invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
	  AND    iid.internal_gmr_ref_no = gepd.internal_gmr_ref_no
	  AND    iid.is_active = 'Y'
	  AND    invs.is_active = 'Y'
	  AND    invs.internal_invoice_ref_no =
		   (SELECT MAX(invs_temp.internal_invoice_ref_no) internal_invoice_ref_no
		     FROM   is_invoice_summary          invs_temp,
				iid_invoicable_item_details iid_temp
		     WHERE  invs_temp.internal_invoice_ref_no = iid_temp.internal_invoice_ref_no
		     AND    invs_temp.is_active = 'Y'
		     AND    iid_temp.is_active = 'Y'
		     AND    iid_temp.internal_gmr_ref_no = gepd.internal_gmr_ref_no)) pledge_invoice_status,
	 invs.invoice_type_name supplier_invoice_status, --tt.supplier_invoice_status, bug 63130 fix
	 invs.invoice_ref_no supplier_invoice_number, --tt.supplier_invoice_number, bug 63130 fix
	 gmr.qty gmr_qty,
	 gepd.pledge_qty,
	 qum.qty_unit pleadge_qty_unit,
	 axm.action_name,
	 axs.internal_action_ref_no,
	 axs.action_ref_no,
	 qum_aml.qty_unit pledge_base_product_unit,
	 round(gepd.pledge_qty *
		 pkg_general.f_get_converted_quantity(pdm_aml.product_id, gmr.qty_unit_id, pdm_aml.base_quantity_unit, 1)
		,5) pledge_qty_in_base_unit
FROM   gmr_goods_movement_record      gmr,
	 gam_gmr_action_mapping         gam,
	 axs_action_summary             axs,
	 qum_quantity_unit_master       qum,
	 axm_action_master              axm,
	 gepd_gmr_element_pledge_detail gepd,
	 phd_profileheaderdetails       phd_pledge,
	 phd_profileheaderdetails       phd_supplier,
	 pcm_physical_contract_main     pcm,
	 pcdi_pc_delivery_item          pcdi,
	 pci_physical_contract_item     pci,
	 aml_attribute_master_list      aml,
	 pdm_productmaster              pdm_aml,
	 qum_quantity_unit_master       qum_aml,
	 v_gmr_assay_finalized_status   gmr_afs,
	 ak_corporate                   ak,
	 gcd_groupcorporatedetails      gcd,
	 pcpd_pc_product_definition     pcpd,
	 cpc_corporate_profit_center    cpc,
	 grd_goods_record_detail        grd,
	 --bug 63130 fix starts
	 is_invoice_summary      invs,
	 v_bi_latest_gmr_invoice l_gmr_inv
       /*(select invs.invoice_ref_no supplier_invoice_number,
                     iid.internal_gmr_ref_no,
                     invs.invoice_type_name supplier_invoice_status
                from is_invoice_summary          invs,
                     iid_invoicable_item_details iid
               where invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
                 and invs.internal_invoice_ref_no =
                     (select max(invs_temp.internal_invoice_ref_no) internal_invoice_ref_no
                        from is_invoice_summary          invs_temp,
                             iid_invoicable_item_details iid
                       where invs_temp.internal_invoice_ref_no =
                             iid.internal_invoice_ref_no
                         and invs_temp.is_active = 'Y')) tt*/
       --bug 63130 fix ends            
WHERE  gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
AND    gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
AND    axs.internal_action_ref_no(+) = gam.internal_action_ref_no
AND    axs.status(+) = 'Active'
AND    axm.action_id(+) = axs.action_id
AND    gmr.is_deleted = 'N'
AND    gmr.qty_unit_id = qum.qty_unit_id
AND    nvl(gmr.is_settlement_gmr, 'N') = 'N'
AND    nvl(gmr.tolling_gmr_type, 'None Tolling') IN ('Pledge')
AND    gmr.is_internal_movement = 'N'
AND    gepd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    gepd.is_active = 'Y'
AND    phd_pledge.profileid = gepd.pledge_cp_id
AND    phd_supplier.profileid = gepd.supplier_cp_id
AND    pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
AND    pcdi.pcdi_id = pci.pcdi_id
AND    pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
AND    aml.attribute_id = gepd.element_id
AND    gmr_afs.internal_gmr_ref_no = gepd.pledge_input_gmr
AND    ak.corporate_id = gmr.corporate_id
AND    gcd.groupid = ak.groupid
AND    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.input_output = 'Input'
AND    cpc.profit_center_id = pcpd.profit_center_id
AND    aml.attribute_id = gepd.element_id
AND    aml.underlying_product_id = pdm_aml.product_id
AND    pdm_aml.base_quantity_unit = qum_aml.qty_unit_id
AND    gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
AND    pci.internal_contract_item_ref_no = grd.internal_contract_item_ref_no
	--bug 63130 fix start    
	--and gepd.pledge_input_gmr = tt.internal_gmr_ref_no(+)
AND    l_gmr_inv.internal_gmr_ref_no(+) = gepd.pledge_input_gmr
AND    l_gmr_inv.internal_invoice_ref_no = invs.internal_invoice_ref_no(+)
      --bug 63130 fix ends
/
