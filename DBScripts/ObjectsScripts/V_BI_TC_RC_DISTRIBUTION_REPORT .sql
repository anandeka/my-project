create or replace view v_bi_tc_rc_distribution_report as
select supplier.supplier_invoive_no,
       supplier.supplier_invoice_date,
       supplier.supplier_contract_ref_no,
       supplier.supplier_gmr_ref_no,
       supplier.supplier,
       supplier.charges_to_supplier,
       supplier.invoice_currency_id,
       supplier.invoice_currency_code,
       smelter.smelter_invoive_no,
       smelter.smelter_invoice_date,
       smelter.smelter_gmr_ref_no,
       smelter.smelter_contract_ref_no,
       smelter.smelter,
       smelter.charges_to_smelter
  from (select test.supplier_gmr_ref_no,
               test.supplier_internal_gmr_ref_no,
               test.supplier_invoive_no,
               test.supplier_invoice_date,
               test.supplier_contract_ref_no,
               test.supplier,
               sum(test.tc_amount + test.rc_amount + test.penality_amount) charges_to_supplier,
               test.invoice_currency_id,
               test.invoice_currency_code
          from (select pcm.contract_ref_no supplier_contract_ref_no,
                       gmr.gmr_ref_no supplier_gmr_ref_no,
                       gmr.internal_gmr_ref_no supplier_internal_gmr_ref_no,
                       grd.internal_grd_ref_no,
                       phd.companyname supplier,
                       nvl(intc.tc_amount, 0) tc_amount,
                       nvl(inrc.rc_amount, 0) rc_amount,
                       nvl(iepd.penality_amount, 0) penality_amount,
                       iss.invoice_ref_no supplier_invoive_no,
                       iss.invoice_issue_date supplier_invoice_date,
                       iid.invoice_currency_id,
                       cm.cur_code invoice_currency_code
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
                       ii_invoicable_item ii,
                       cm_currency_master cm
                 where pcm.internal_contract_ref_no =
                       gmr.internal_contract_ref_no
                   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                   and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = iid.stock_id
                   and iid.internal_invoice_ref_no =
                       iss.internal_invoice_ref_no
                   and iss.is_active = 'Y'
                   and pcm.is_active = 'Y'
                   and gmr.is_deleted = 'N'
                   and grd.is_deleted = 'N'
                   and iid.invoicable_item_id = ii.invoicable_item_id
                      --   and nvl(ii.is_pass_through,'N') = 'Y'
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
                   and iss.internal_invoice_ref_no =
                       invoice.internal_invoice_ref_no
                   and iid.invoice_currency_id = cm.cur_id
                   and pcm.cp_id = phd.profileid
                union all
                select pcm.contract_ref_no supplier_contract_ref_no,
                       gmr.gmr_ref_no supplier_gmr_ref_no,
                       gmr.internal_gmr_ref_no supplier_internal_gmr_ref_no,
                       grd.internal_grd_ref_no,
                       phd.companyname supplier,
                       0 tc_amount,
                       0 rc_amount,
                       0 penality_amount,
                       'NA' supplier_invoive_no,
                       null supplier_invoice_date,
                       iid.invoice_currency_id,
                       -- iid.*,
                       cm.cur_code invoice_currency_code
                  from pcm_physical_contract_main pcm,
                       phd_profileheaderdetails   phd,
                       gmr_goods_movement_record  gmr,
                       grd_goods_record_detail    grd,
                       ii_invoicable_item         iid,
                       cm_currency_master         cm
                 where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                   and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = iid.stock_id
                   and iid.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and iid.is_pass_through = 'Y'
                   and not exists
                 (select *
                          from iid_invoicable_item_details iid1
                         where iid1.invoicable_item_id =
                               iid.invoicable_item_id)
                   and pcm.is_active = 'Y'
                   and gmr.is_deleted = 'N'
                   and grd.is_deleted = 'N'
                   and pcm.is_tolling_contract = 'Y'
                   and pcm.purchase_sales = 'P'
                   and iid.invoice_currency_id = cm.cur_id(+)
                   and pcm.cp_id = phd.profileid
                ) test
         group by test.supplier_invoive_no,
                  test.supplier_invoice_date,
                  test.supplier_contract_ref_no,
                  test.supplier,
                  test.invoice_currency_id,
                  test.invoice_currency_code,
                  test.supplier_gmr_ref_no,
                  test.supplier_internal_gmr_ref_no) supplier,
       (select test.smelter_gmr_ref_no,
               test.smelter_internal_gmr_ref_no,
               test.supp_internal_gmr_ref_no,
               test.smelter_invoive_no,
               test.smelter_invoice_date,
               test.smelter_contract_ref_no,
               test.smelter,
               sum(test.tc_amount + test.rc_amount + test.penality_amount) charges_to_smelter,
               test.invoice_currency_id,
               test.invoice_currency_code
          from (select pcm.contract_ref_no smelter_contract_ref_no,
                       gmr.internal_gmr_ref_no smelter_internal_gmr_ref_no,
                       gmr.gmr_ref_no smelter_gmr_ref_no,
                       grd.internal_grd_ref_no,
                       grd.supp_internal_gmr_ref_no,
                       phd.companyname smelter,
                       nvl(intc.tc_amount, 0) tc_amount,
                       nvl(inrc.rc_amount, 0) rc_amount,
                       nvl(iepd.penality_amount, 0) penality_amount,
                       iss.invoice_ref_no smelter_invoive_no,
                       iss.invoice_issue_date smelter_invoice_date,
                       iid.invoice_currency_id,
                       cm.cur_code invoice_currency_code
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
                       cm_currency_master cm
                 where pcm.internal_contract_ref_no =
                       gmr.internal_contract_ref_no
                   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                   and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = iid.stock_id
                   and iid.internal_invoice_ref_no =
                       iss.internal_invoice_ref_no
                   and iss.is_active = 'Y'
                   and pcm.is_active = 'Y'
                   and gmr.is_deleted = 'N'
                   and grd.is_deleted = 'N'
                   and pcm.is_tolling_contract = 'Y'
                   and pcm.purchase_sales = 'S'
                   and iid.stock_id = intc.grd_id(+)
                   and iid.internal_invoice_ref_no =
                       intc.internal_invoice_ref_no(+)
                   and iid.stock_id = inrc.grd_id(+)
                   and iid.internal_invoice_ref_no =
                       inrc.internal_invoice_ref_no(+)
                   and iid.stock_id = iepd.stock_id(+)
                   and iid.internal_invoice_ref_no =
                       iepd.internal_invoice_ref_no(+)
                   and iss.internal_invoice_ref_no =
                       invoice.internal_invoice_ref_no
                   and iid.invoice_currency_id = cm.cur_id
                   and pcm.cp_id = phd.profileid) test
         group by test.smelter_invoive_no,
                  test.smelter_invoice_date,
                  test.smelter_contract_ref_no,
                  test.smelter,
                  test.invoice_currency_id,
                  test.invoice_currency_code,
                  test.smelter_gmr_ref_no,
                  test.supp_internal_gmr_ref_no,
                  test.smelter_internal_gmr_ref_no) smelter
 where supplier.supplier_internal_gmr_ref_no =
       smelter.supp_internal_gmr_ref_no(+)
