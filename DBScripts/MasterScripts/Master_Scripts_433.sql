DECLARE
   p_pcbpd_desc   VARCHAR2 (4000);

   CURSOR cr_pcbpdid_record
   IS
      SELECT pcbpd.pcbpd_id AS pcbpdid
        FROM pcbpd_pc_base_price_detail pcbpd
       WHERE pcbpd.description IS NULL AND pcbpd.is_active = 'Y';
BEGIN
   FOR cur_record_rows IN cr_pcbpdid_record
   LOOP
      DBMS_OUTPUT.put_line (' HII :' || cur_record_rows.pcbpdid);
      p_pcbpd_desc := getpricepointdescription (cur_record_rows.pcbpdid);

      IF p_pcbpd_desc IS NULL
      THEN
         DBMS_OUTPUT.put_line (' HI33 :' || cur_record_rows.pcbpdid);
      ELSE
         UPDATE pcbpd_pc_base_price_detail pcbpd
            SET pcbpd.description = p_pcbpd_desc
          WHERE pcbpd.pcbpd_id = cur_record_rows.pcbpdid;
      END IF;
   END LOOP;
END;
/