CREATE OR REPLACE FUNCTION "GETCCDETAILS" (pContractno NUMBER)
   RETURN VARCHAR2
IS
   CURSOR cr_cc
   IS
      SELECT DISTINCT pcmac.addn_charge_name
                 FROM pcmac_pcm_addn_charges pcmac,
                      pcm_physical_contract_main pcm
                WHERE pcmac.int_contract_ref_no = pcm.internal_contract_ref_no
                  AND pcmac.addn_charge_name = 'Container Charges'
                  AND pcmac.is_active = 'Y'
                  AND pcm.internal_contract_ref_no = pContractno;

   CURSOR cr_cc_data
   IS
      SELECT (   'Container Size'
              || ' : '
              || pcmac.container_size
              || ' , '
              || 'Charge'
              || ' : '
              || pcmac.charge
              || ' '
              || cm.cur_code
              || '/'
              || pcmac.charge_rate_basis
             ) AS cc
        FROM pcmac_pcm_addn_charges pcmac,
             pcm_physical_contract_main pcm,
             cm_currency_master cm
       WHERE pcmac.int_contract_ref_no = pcm.internal_contract_ref_no
         AND cm.cur_id(+) = pcmac.charge_cur_id
         AND pcmac.addn_charge_name = 'Container Charges'
         AND pcmac.is_active = 'Y'
         AND pcm.internal_contract_ref_no = pContractno;

   cc_details   VARCHAR2 (4000) := '';
BEGIN
   FOR cr_cc_rec IN cr_cc
   LOOP
      FOR cr_cc_data_rec IN cr_cc_data
      LOOP
         cc_details := cc_details || '' || cr_cc_data_rec.cc || CHR (10);
      END LOOP;
   END LOOP;

   RETURN cc_details;
END;
/
