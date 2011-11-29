/* Formatted on 2011/11/28 15:36 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FUNCTION getJVdetails (p_contractno VARCHAR2)
   RETURN VARCHAR2
IS
   CURSOR cr_jv
   IS
      SELECT phd.company_long_name1 AS jvname,
             pcjv.profit_share_percentage AS profit,
             pcjv.loss_share_percentage AS loss
        FROM pcjv_pc_jv_detail pcjv, phd_profileheaderdetails phd
       WHERE pcjv.cp_id = phd.profileid
         AND pcjv.is_active = 'Y'
         AND pcjv.internal_contract_ref_no = p_contractno;

   jvdesc   VARCHAR2 (1000) := NULL;
BEGIN
   FOR jv_rec IN cr_jv
   LOOP
            
      IF jvdesc IS NULL
      THEN
         jvdesc := jv_rec.jvname;
      ELSE
         jvdesc := jvdesc || CHR (10) || jv_rec.jvname;
      END IF;


      IF (jv_rec.profit IS NOT NULL)
      THEN
         jvdesc := jvdesc || ' : Profit sharing: ' || jv_rec.profit || '%';
      END IF;

      IF (jv_rec.loss IS NOT NULL)
      THEN
         jvdesc := jvdesc || ' , Loss sharing: ' || jv_rec.loss || '%';
      END IF;
   END LOOP;

   RETURN jvdesc;
END;
/