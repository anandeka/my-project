CREATE OR REPLACE FUNCTION fn_get_supplier_representative (
   pc_internal_gmr_ref_no   IN   VARCHAR2
)
   RETURN VARCHAR2
IS
   pc_result   VARCHAR2 (200);
BEGIN
   SELECT MAX (supplier_representative)
     INTO pc_result
     FROM (SELECT phd.companyname AS supplier_representative
             FROM sd_shipment_detail sd, phd_profileheaderdetails phd
            WHERE sd.internal_gmr_ref_no = pc_internal_gmr_ref_no
              AND sd.supp_rep_id = phd.profileid
           UNION ALL
           SELECT phd.companyname AS supplier_representative
             FROM wrd_warehouse_receipt_detail wrd,
                  phd_profileheaderdetails phd
            WHERE wrd.internal_gmr_ref_no = pc_internal_gmr_ref_no
              AND wrd.supp_rep_id = phd.profileid
           UNION ALL
           SELECT phd.companyname AS supplier_representative
             FROM sad_shipment_advice sad, phd_profileheaderdetails phd
            WHERE sad.internal_gmr_ref_no = pc_internal_gmr_ref_no
              AND sad.supp_rep_id = phd.profileid
           UNION ALL
           SELECT phd.companyname AS supplier_representative
             FROM rod_release_order_detail rod, phd_profileheaderdetails phd
            WHERE rod.internal_gmr_ref_no = pc_internal_gmr_ref_no
              AND rod.supp_rep_id = phd.profileid);

   RETURN (pc_result);
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN ('');
END fn_get_supplier_representative;
/