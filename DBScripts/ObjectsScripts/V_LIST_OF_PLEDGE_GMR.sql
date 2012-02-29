create or replace view v_list_of_pledge_gmr as
select gmr.corporate_id,
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
       (select to_char(pofh.qp_start_date, 'MM/DD/YYYY')
          from pofh_price_opt_fixation_header pofh
         where pofh.is_active = 'Y'
           and pofh.internal_gmr_ref_no = gepd.internal_gmr_ref_no) qp_start_date,
       (select to_char(pofh.qp_end_date, 'MM/DD/YYYY')
          from pofh_price_opt_fixation_header pofh
         where pofh.is_active = 'Y'
           and pofh.internal_gmr_ref_no = gepd.internal_gmr_ref_no) qp_end_date,
       (select distinct invs.invoice_issue_date
          from is_invoice_summary          invs,
               iid_invoicable_item_details iid
         where invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
           and iid.is_active = 'Y'
           and invs.is_active = 'Y'
           and iid.internal_gmr_ref_no = gepd.pledge_input_gmr
           and invs.internal_invoice_ref_no =
               (select max(invs_temp.internal_invoice_ref_no) internal_invoice_ref_no
                  from is_invoice_summary          invs_temp,
                       iid_invoicable_item_details iid_temp
                 where invs_temp.internal_invoice_ref_no =
                       iid_temp.internal_invoice_ref_no
                   and iid_temp.is_active = 'Y'
                   and invs_temp.is_active = 'Y'
                   and iid_temp.internal_gmr_ref_no = gepd.pledge_input_gmr)) supplier_inv_date,
       (select distinct invs.invoice_ref_no
          from is_invoice_summary          invs,
               iid_invoicable_item_details iid
         where invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
           and iid.is_active = 'Y'
           and invs.is_active = 'Y'
           and iid.internal_gmr_ref_no = gepd.pledge_input_gmr
           and invs.internal_invoice_ref_no =
               (select max(invs_temp.internal_invoice_ref_no) internal_invoice_ref_no
                  from is_invoice_summary          invs_temp,
                       iid_invoicable_item_details iid_temp
                 where invs_temp.internal_invoice_ref_no =
                       iid_temp.internal_invoice_ref_no
                   and iid_temp.is_active = 'Y'
                   and invs_temp.is_active = 'Y'
                   and iid_temp.internal_gmr_ref_no = gepd.pledge_input_gmr)) supplier_inv_no,
       (select distinct invs.invoice_issue_date
          from is_invoice_summary          invs,
               iid_invoicable_item_details iid
         where invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
           and iid.internal_gmr_ref_no = gepd.internal_gmr_ref_no
           and iid.is_active = 'Y'
           and invs.is_active = 'Y'
           and invs.internal_invoice_ref_no =
               (select max(invs_temp.internal_invoice_ref_no) internal_invoice_ref_no
                  from is_invoice_summary          invs_temp,
                       iid_invoicable_item_details iid_temp
                 where invs_temp.internal_invoice_ref_no =
                       iid_temp.internal_invoice_ref_no
                   and invs_temp.is_active = 'Y'
                   and iid_temp.is_active = 'Y'
                   and iid_temp.internal_gmr_ref_no =
                       gepd.internal_gmr_ref_no)) pledge_inv_date,
       (select distinct invs.invoice_ref_no
          from is_invoice_summary          invs,
               iid_invoicable_item_details iid
         where invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
           and iid.internal_gmr_ref_no = gepd.internal_gmr_ref_no
           and iid.is_active = 'Y'
           and invs.is_active = 'Y'
           and invs.internal_invoice_ref_no =
               (select max(invs_temp.internal_invoice_ref_no) internal_invoice_ref_no
                  from is_invoice_summary          invs_temp,
                       iid_invoicable_item_details iid_temp
                 where invs_temp.internal_invoice_ref_no =
                       iid_temp.internal_invoice_ref_no
                   and invs_temp.is_active = 'Y'
                   and iid_temp.is_active = 'Y'
                   and iid_temp.internal_gmr_ref_no =
                       gepd.internal_gmr_ref_no)) pledge_inv_no,
       gmr_afs.assay_finalized assay_finalized
  from gmr_goods_movement_record      gmr,
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
 where gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
   and gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
   and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
   and axs.status(+) = 'Active'
   and axm.action_id(+) = axs.action_id
   and gmr.is_deleted = 'N'
   and gmr.qty_unit_id = qum.qty_unit_id
   and nvl(gmr.is_settlement_gmr, 'N') = 'N'
   and nvl(gmr.tolling_gmr_type, 'None Tolling') in ('Pledge')
   and gmr.is_internal_movement = 'N'
   and gepd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gepd.is_active = 'Y'
   and phd_pledge.profileid = gepd.pledge_cp_id
   and phd_supplier.profileid = gepd.supplier_cp_id
   and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
   and aml.attribute_id = gepd.element_id
   and pdm.product_id = gepd.product_id
   and gmr_afs.internal_gmr_ref_no = gepd.pledge_input_gmr;
