CREATE OR REPLACE FUNCTION "GETSLCDETAILS" (pContractno NUMBER)
   RETURN VARCHAR2
IS
   CURSOR cr_slc
   IS
      SELECT DISTINCT pcmac.addn_charge_name
                 FROM pcmac_pcm_addn_charges pcmac,
                      pcm_physical_contract_main pcm
                WHERE pcmac.int_contract_ref_no = pcm.internal_contract_ref_no
                  AND pcmac.addn_charge_name = 'Small Lot Charges'
                  AND pcmac.is_active = 'Y'
                  AND pcm.internal_contract_ref_no = pContractno;

   CURSOR cr_slc_data
   IS
      SELECT (   pcmac.charge_type
              || ', '
              || (CASE
                     WHEN pcmac.POSITION = 'Range Begining'
                        THEN    ' '
                             || pcmac.range_max_op
                             || ' '
                             || pcmac.range_max_value
                             || ' '
                             || qum.qty_unit
                     WHEN pcmac.POSITION = 'Range End'
                        THEN    ' '
                             || pcmac.range_min_op
                             || ' '
                             || pcmac.range_min_value
                             || ' '
                             || qum.qty_unit
                     ELSE    pcmac.range_min_op
                          || ' '
                          || pcmac.range_min_value
                          || ' to '
                          || pcmac.range_max_op
                          || ' '
                          || pcmac.range_max_value
                          || ' '
                          || qum.qty_unit
                  END
                 )
              || ', '
              || 'Charge'
              || ': '
              || pcmac.charge
              || ' '
              || cm.cur_code
              || '/'
             || case
              when  qum.qty_unit <> null
              then qum.qty_unit
              when pcmac.charge_rate_basis = 'Container' or pcmac.charge_rate_basis = 'Lot' or pcmac.charge_rate_basis = 'Bags'
                then pcmac.charge_rate_basis
                else qum.qty_unit||', '||pcmac.charge_rate_basis
               end
             ) AS SLC
        FROM pcmac_pcm_addn_charges pcmac,
             pcm_physical_contract_main pcm,
             qum_quantity_unit_master qum,
             cm_currency_master cm
       WHERE pcmac.int_contract_ref_no = pcm.internal_contract_ref_no
         AND cm.cur_id(+) = pcmac.charge_cur_id
         AND qum.qty_unit_id(+) = pcmac.qty_unit_id
         AND pcmac.addn_charge_name = 'Small Lot Charges'
         AND pcmac.is_active = 'Y'
         AND pcm.internal_contract_ref_no = pContractno
         order by NVL(pcmac.range_min_value,0);

   SLC_DETAILS   VARCHAR2(4000) :='';  
   begin
            for cr_slc_rec in cr_slc
            loop
                
                 for cr_slc_data_rec in cr_slc_data
                 loop
                        
                        SLC_DETAILS:= SLC_DETAILS ||''|| cr_slc_data_rec.SLC || chr(10);

                 end loop;
            
            end loop;
           
            return  SLC_DETAILS;
    end;
/
