

DECLARE
   CURSOR sdddataupdate
   IS
      SELECT   gmr.internal_gmr_ref_no, gmr.gmr_ref_no, gmr.senders_ref_no
          FROM gmr_goods_movement_record gmr
         WHERE gmr.internal_gmr_ref_no IN (SELECT   sdd.internal_gmr_ref_no
                                               FROM sdd_d sdd
                                           GROUP BY sdd.internal_gmr_ref_no)
      GROUP BY gmr.internal_gmr_ref_no, gmr.gmr_ref_no, gmr.senders_ref_no;
BEGIN
   FOR sddupdate IN sdddataupdate
   LOOP
      UPDATE sdd_d sdd
         SET sdd.gmr_ref_no = sddupdate.gmr_ref_no, sdd.senders_ref_no = sddupdate.senders_ref_no
       WHERE sdd.internal_gmr_ref_no = sddupdate.internal_gmr_ref_no;
   END LOOP;

   COMMIT;
END;


---------------------------------------------------------------------------------------------------

DECLARE
   CURSOR saddataupdate
   IS
      SELECT   gmr.internal_gmr_ref_no, gmr.gmr_ref_no
          FROM gmr_goods_movement_record gmr
         WHERE gmr.internal_gmr_ref_no IN (SELECT   sad.internal_gmr_ref_no
                                               FROM sad_d sad
                                           GROUP BY sad.internal_gmr_ref_no)
      GROUP BY gmr.internal_gmr_ref_no, gmr.gmr_ref_no;
BEGIN
   FOR sadupdate IN saddataupdate
   LOOP
      UPDATE sad_d sad
         SET sad.gmr_ref_no = sadupdate.gmr_ref_no
       WHERE sad.internal_gmr_ref_no = sadupdate.internal_gmr_ref_no;
   END LOOP;

   COMMIT;
END;