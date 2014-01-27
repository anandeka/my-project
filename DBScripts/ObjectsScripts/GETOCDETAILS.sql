CREATE OR REPLACE FUNCTION "GETOCDETAILS" (pContractno NUMBER)
   RETURN VARCHAR2
IS
   CURSOR cr_oc
   IS
      SELECT DISTINCT pcmac.addn_charge_name
                 FROM pcmac_pcm_addn_charges pcmac,
                      pcm_physical_contract_main pcm
                WHERE pcmac.int_contract_ref_no = pcm.internal_contract_ref_no
                  AND pcmac.addn_charge_name != 'Container Charges'
                  AND pcmac.addn_charge_name != 'Small Lot Charges'
                  AND pcmac.is_active = 'Y'
                  AND pcm.internal_contract_ref_no = pContractno;

   CURSOR cr_oc_data
   IS
      SELECT pcmac.addn_charge_name,
             (   pcmac.charge_type
              || ' , '
              || 'Charge'
              || ': '
              || pcmac.charge_type
              || '  '
              || (CASE
                     WHEN pcmac.charge_type = 'Flat'
                        THEN CASE
                               WHEN pcmac.fx_rate IS NULL
                                  THEN pcmac.charge || ' ' || cm.cur_code
                               ELSE    pcmac.charge
                                    || ' '
                                    || cm.cur_code
                                    || ' , '
                                    || 'Fx Rate'
                                    || ' : '
                                    || pcmac.fx_rate
                            END
                     ELSE (CASE
                              WHEN pcmac.fx_rate IS NULL
                                 THEN    pcmac.charge
                                      || ' '
                                      || cm.cur_code
                                      || '/ '
                                      || pcmac.charge_rate_basis
                                      || ' '
                                      || qum.qty_unit
                              ELSE    pcmac.charge
                                   || ' '
                                   || cm.cur_code
                                   || ' , '
                                   || 'Fx Rate'
                                   || ' : '
                                   || pcmac.fx_rate
                                   || ' '
                                   || pcmac.charge_rate_basis
                                   || ' '
                                   || qum.qty_unit
                           END
                          )
                  END
                 )
             ) AS oc
        FROM pcmac_pcm_addn_charges pcmac,
             pcm_physical_contract_main pcm,
             qum_quantity_unit_master qum,
             cm_currency_master cm
       WHERE pcmac.int_contract_ref_no = pcm.internal_contract_ref_no
         AND cm.cur_id(+) = pcmac.charge_cur_id
         AND qum.qty_unit_id(+) = pcmac.qty_unit_id
         AND pcmac.addn_charge_name != 'Container Charges'
         AND pcmac.addn_charge_name != 'Small Lot Charges'
         AND pcmac.is_active = 'Y'
         AND pcm.internal_contract_ref_no = pContractno;

   oc_details   VARCHAR2 (4000) := '';
BEGIN
   FOR cr_oc_rec IN cr_oc
   LOOP
      oc_details := oc_details || '' || cr_oc_rec.addn_charge_name || ' : ';

      FOR cr_oc_data_rec IN cr_oc_data
      LOOP
         IF (cr_oc_rec.addn_charge_name = cr_oc_data_rec.addn_charge_name)
         THEN
            oc_details := oc_details || '' || cr_oc_data_rec.oc || CHR (10);
         END IF;
      END LOOP;
   END LOOP;

   RETURN oc_details;
END;
/
