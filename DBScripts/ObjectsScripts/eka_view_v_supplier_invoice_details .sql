create or replace view v_supplier_invoice_details as
select tt.supplier_invoive_no,
       tt.supplier_gmr_ref_no,
       tt.supplier_internal_gmr_ref_no,
       tt.supplier_invoice_date,
       tt.supplier_contract_ref_no,
       tt.supplier_id,
       tt.supplier,
       tt.corporate_id,
       tt.corporate_name,
       tt.charges_to_supplier,
       sum(tt.charges_to_supplier) over(partition by tt.supplier_invoive_no order by tt.supplier_invoive_no) net_charges_to_supplier,
       tt.invoice_currency_id,
       tt.invoice_currency_code,
       tt.add_charges_to_supplier
  from (select test.supplier_invoive_no,
               test.supplier_gmr_ref_no,
               test.supplier_internal_gmr_ref_no,
               test.supplier_invoice_date,
               test.supplier_contract_ref_no,
               test.supplier_id,
               test.supplier,
               test.corporate_id,
               test.corporate_name,
               sum(test.tc_amount + test.rc_amount + test.penality_amount) charges_to_supplier,
               test.invoice_currency_id,
               test.invoice_currency_code,
               nvl(iss.total_other_charge_amount, 0) / iss.gmr_cnt add_charges_to_supplier
          from (select pcm.contract_ref_no supplier_contract_ref_no,
                       gmr.gmr_ref_no supplier_gmr_ref_no,
                       gmr.internal_gmr_ref_no supplier_internal_gmr_ref_no,
                       grd.internal_grd_ref_no,
                       phd.profileid supplier_id,
                       phd.companyname supplier,
                       gmr.corporate_id,
                       akc.corporate_name,
                       nvl(intc.tc_amount, 0) tc_amount,
                       nvl(inrc.rc_amount, 0) rc_amount,
                       nvl(iepd.penality_amount, 0) penality_amount,
                       iss.invoice_ref_no supplier_invoive_no,
                       iss.invoice_issue_date supplier_invoice_date,
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
                    --   ii_invoicable_item ii,
                       cm_currency_master cm,
                       ak_corporate      akc
                 where pcm.internal_contract_ref_no =
                       gmr.internal_contract_ref_no
                   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                   and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = iid.stock_id
                   and iid.internal_invoice_ref_no =  iss.internal_invoice_ref_no
                   and iss.is_active = 'Y'
                   and pcm.is_active = 'Y'
                   and gmr.is_deleted = 'N'
                   and grd.is_deleted = 'N'
               --    and iid.invoicable_item_id = ii.invoicable_item_id
                   and pcm.is_tolling_contract = 'Y'
                   and pcm.purchase_sales = 'P'
                   and iid.stock_id = intc.grd_id(+)
                   and iid.internal_invoice_ref_no =
                       intc.internal_invoice_ref_no(+)
                   and iid.stock_id = inrc.grd_id(+)
                   and iid.internal_invoice_ref_no =
                       inrc.internal_invoice_ref_no(+)
                   and iid.stock_id = iepd.stock_id(+)
                   and iid.internal_invoice_ref_no =
                       iepd.internal_invoice_ref_no(+)
                   and gmr.internal_gmr_ref_no = invoice.internal_gmr_ref_no
                   and iid.invoice_currency_id = cm.cur_id
                   and pcm.cp_id = phd.profileid
                   and gmr.corporate_id=akc.corporate_id) test,
               (select is1.internal_invoice_ref_no,
                       nvl(is1.total_other_charge_amount, 0)total_other_charge_amount,
                       count(distinct iid.internal_gmr_ref_no) gmr_cnt
                  from is_invoice_summary          is1,
                       iid_invoicable_item_details iid
                 where iid.internal_invoice_ref_no =
                       is1.internal_invoice_ref_no
                   and iid.is_active = 'Y'
                 group by is1.internal_invoice_ref_no,
                          nvl(is1.total_other_charge_amount, 0)) iss
         where test.internal_invoice_ref_no = iss.internal_invoice_ref_no(+)
         group by test.supplier_invoive_no,
                  test.supplier_invoice_date,
                  test.supplier_contract_ref_no,
                  test.supplier_id,
                  test.supplier,
                  test.corporate_id,
                  test.corporate_name,
                  test.invoice_currency_id,
                  test.invoice_currency_code,
                  test.supplier_gmr_ref_no,
                  test.supplier_internal_gmr_ref_no,
                  iss.total_other_charge_amount,
                  iss.gmr_cnt) tt
