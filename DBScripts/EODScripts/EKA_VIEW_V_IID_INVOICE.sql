CREATE OR REPLACE VIEW V_IID_INVOICE AS 
--
-- Author : Sivachalabathi S
-- Date : 3 Sep 2012, Monday
-- View Used in Calculating Other Charges and Freight For Invoice/GMR
-- Used in Purchase Accrual Report
-- If more than one GMR is associated with One Invoice then
-- Divide the charges equally between the GMRS
--
select iid.internal_invoice_ref_no,
       iid.internal_gmr_ref_no,
       count(distinct iid.internal_gmr_ref_no) over(partition by iid.internal_invoice_ref_no) gmr_count
  from iid_invoicable_item_details iid
  where iid.is_active ='Y'
 group by iid.internal_invoice_ref_no,
          iid.internal_gmr_ref_no;
