---create sequences for diff corporates for HolidayHandling

DECLARE
   CURSOR holidayhand_id
   IS
      (SELECT akc.corporate_id
         FROM ak_corporate akc
        WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N');
BEGIN
   FOR sl_drf IN holidayhand_id
   LOOP
      
      EXECUTE IMMEDIATE    'CREATE SEQUENCE SEQAXM_HH_'
                        || sl_drf.corporate_id
                        || ' START WITH 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE NOCACHE NOORDER';
   END LOOP;

   COMMIT;
END;

--- Update ARF seq_name based on corporate id

UPDATE arf_action_ref_number_format arf
   SET arf.seq_name = 'SEQAXM_HH_&corpId'
 WHERE arf.action_key_id = 'HHPriceFix'
 and ARF.CORPORATE_ID='&corpId';