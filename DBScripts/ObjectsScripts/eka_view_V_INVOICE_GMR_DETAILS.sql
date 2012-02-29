CREATE OR REPLACE VIEW V_INVOICE_GMR_DETAILS AS
SELECT inv_lastest.gmr_ref_no, inv_lastest.internal_gmr_ref_no,
          inv_lastest.internal_grd_ref_no, inv_lastest.invoice_ref_no,
          inv_lastest.internal_invoice_ref_no,
          ROUND (inv_lastest.invoice_item_amount, 4) invoice_item_amount,
          inv_lastest.invoice_currency_id, inv_lastest.invoice_type,
          inv_lastest.eff_date, inv_lastest.created_date
     FROM (SELECT gmr.gmr_ref_no, gmr.internal_gmr_ref_no,
                  grd.internal_grd_ref_no, iis.invoice_ref_no,
                  iid.internal_invoice_ref_no, iid.invoice_item_amount,
                  iid.invoice_currency_id, iid.invoice_type, axs.eff_date,
                  axs.created_date,
                  RANK () OVER (PARTITION BY gmr.internal_gmr_ref_no, grd.internal_grd_ref_no ORDER BY axs.created_date DESC NULLS LAST)
                                                                   AS td_rank
             FROM gmr_goods_movement_record gmr,
                  grd_goods_record_detail grd,
                  iid_invoicable_item_details iid,
                  is_invoice_summary iis,
                  iam_invoice_action_mapping iam,
                  axs_action_summary axs
            WHERE gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
              AND gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
              AND grd.internal_grd_ref_no = iid.stock_id
              AND iid.internal_invoice_ref_no = iam.internal_invoice_ref_no
              AND iid.internal_invoice_ref_no = iis.internal_invoice_ref_no
              AND axs.internal_action_ref_no = iam.invoice_action_ref_no) inv_lastest
    WHERE inv_lastest.td_rank = 1

