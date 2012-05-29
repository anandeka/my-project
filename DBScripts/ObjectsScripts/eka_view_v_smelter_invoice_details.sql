create or replace view v_smelter_invoice_details as
select test.supp_internal_gmr_ref_no,
       test.smelter_invoive_no,
       test.smelter_invoice_date,
       test.smelter_id,
       test.smelter,
       test.corporate_id,
       test.corporate_name,
       sum(test.tc_amount + test.rc_amount + test.penality_amount) charges_to_smelter,
       test.invoice_currency_id,
       test.invoice_currency_code
  from (select gmr.internal_gmr_ref_no smelter_internal_gmr_ref_no,
               gmr.gmr_ref_no smelter_gmr_ref_no,
               grd.internal_grd_ref_no,
               grd.supp_internal_gmr_ref_no,
               phd.profileid smelter_id,
               phd.companyname smelter,
               gmr.corporate_id,
               akc.corporate_name,
               nvl(intc.tc_amount, 0) tc_amount,
               nvl(inrc.rc_amount, 0) rc_amount,
               nvl(iepd.penality_amount, 0) penality_amount,
               iss.invoice_ref_no smelter_invoive_no,
               iss.invoice_issue_date smelter_invoice_date,
               iid.invoice_currency_id,
               cm.cur_code invoice_currency_code,
               iss.internal_invoice_ref_no
          from pcm_physical_contract_main pcm,
               phd_profileheaderdetails phd,
               gmr_goods_movement_record gmr,
               grd_goods_record_detail grd,
               iid_invoicable_item_details iid,
               is_invoice_summary iss,
               (select intc.grd_id,
                       intc.internal_invoice_ref_no,
                       sum(intc.tcharges_amount) tc_amount
                  from intc_inv_treatment_charges intc
                 group by intc.grd_id,
                          intc.internal_invoice_ref_no) intc,
               (select inrc.grd_id,
                       inrc.internal_invoice_ref_no,
                       sum(inrc.rcharges_amount) rc_amount
                  from inrc_inv_refining_charges inrc
                 group by inrc.grd_id,
                          inrc.internal_invoice_ref_no) inrc,
               (select iepd.stock_id,
                       iepd.internal_invoice_ref_no,
                       sum(iepd.element_penalty_amount) penality_amount
                  from iepd_inv_epenalty_details iepd
                 group by iepd.stock_id,
                          iepd.internal_invoice_ref_no) iepd,
               v_bi_latest_gmr_invoice invoice,
               cm_currency_master cm,
               ak_corporate akc
         where pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
           and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
           and grd.internal_grd_ref_no = iid.stock_id
           and iid.internal_invoice_ref_no = iss.internal_invoice_ref_no
           and iss.is_active = 'Y'
           and pcm.is_active = 'Y'
           and gmr.is_deleted = 'N'
           and grd.is_deleted = 'N'
           and grd.tolling_stock_type = 'Clone Stock'
           and pcm.is_tolling_contract = 'Y'
           and pcm.purchase_sales = 'S'
           and iid.stock_id = intc.grd_id(+)
           and iid.internal_invoice_ref_no = intc.internal_invoice_ref_no(+)
           and iid.stock_id = inrc.grd_id(+)
           and iid.internal_invoice_ref_no = inrc.internal_invoice_ref_no(+)
           and iid.stock_id = iepd.stock_id(+)
           and iid.internal_invoice_ref_no = iepd.internal_invoice_ref_no(+)
           and gmr.internal_gmr_ref_no = invoice.internal_gmr_ref_no
           and iid.invoice_currency_id = cm.cur_id
           and pcm.cp_id = phd.profileid
           and gmr.corporate_id = akc.corporate_id) test
 group by test.smelter_invoive_no,
          test.smelter_invoice_date,
          test.smelter,
          test.invoice_currency_id,
          test.invoice_currency_code,
          test.supp_internal_gmr_ref_no,
          test.smelter_id,
          test.corporate_id,
          test.corporate_name
