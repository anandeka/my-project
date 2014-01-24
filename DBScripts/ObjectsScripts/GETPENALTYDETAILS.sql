CREATE OR REPLACE FUNCTION getPenaltyDetails (pcaphid number)
   RETURN VARCHAR2
IS
   
     PENALTY_DETAILS        VARCHAR2(4000) :='';  
     penaltydetails       VARCHAR(4000):= '';
     elementname           VARCHAR(50):= '';    

    cursor cr_penalties          
    IS
    
    SELECT PAD.ELEMENT_NAME as elementname, (  (CASE
               WHEN pcap.range_min_op IS NULL
                  THEN    ' '
                       || pcap.range_max_op
                       || ' '
                       || RTRIM (TO_CHAR (pcap.range_max_value,
'FM999990D909999999'
                                         ),
                                 '.'
                                )
                       || ' '
                       || rm.ratio_name
               WHEN pcap.range_max_op IS NULL
                  THEN    ' '
                       || pcap.range_min_op
                       || ' '
                       || RTRIM (TO_CHAR (pcap.range_min_value,
                                          'FM999990D909999999'
                                         ),
                                 '.'
                                )
                       || ' '
                       || rm.ratio_name
               ELSE    pcap.range_min_op
                    || ' '
                    || RTRIM (TO_CHAR (pcap.range_min_value,
                                       'FM999990D909999999'
                                      ),
                              '.'
                             )
                    || ' to '
                    || pcap.range_max_op
                    || ' '
                    || RTRIM (TO_CHAR (pcap.range_max_value,
                                       'FM999990D909999999'
                                      ),
                              '.'
                             )
                    || ' '
                    || rm.ratio_name
            END
           )
        || '  '
        || (CASE
               WHEN pcap.penalty_charge_type = 'Fixed'
                  THEN    RTRIM (TO_CHAR (pcap.penalty_amount,
                                          'FM999990D909999999'
                                         ),
                                 '.'
                                )
                       || ' '
                       || pum.price_unit_name
                       || ' of '
                       || pcap.penalty_weight_type
                       || ' weight'
               WHEN pcap.penalty_charge_type = 'Variable'
                  THEN CASE
                         WHEN pcap.penalty_basis = 'Quantity'
                            THEN    RTRIM (TO_CHAR (pcap.penalty_amount,
                                                    'FM999990D909999999'
                                                   ),
                                           '.'
                                          )
                                 || ' '
                                 || pum.price_unit_name
                                 || ' of '
                                 || pcap.penalty_weight_type
                                 || ' weight per '
                                 || RTRIM (TO_CHAR (pcap.per_increase_value,
                                                    'FM999990D909999999'
                                                   ),
                                           '.'
                                          )
                                 || ' '
                                 || rm.ratio_name
                                 || ' increase'
                         WHEN pcap.penalty_basis = 'Payable Content'
                            THEN    'deduct '
                                 || pcap.deducted_payable_value
                                 || deducted_unit.ratio_name
                                 || 'of'
                                 || deducted_element.attribute_name
                                 || ' per '
                                 || RTRIM (TO_CHAR (pcap.per_increase_value,
                                                    'FM999990D909999999'
                                                   ),
                                           '.'
                                          )
                                 || ' '
                                 || rm.ratio_name
                                 || ' increase'
                         ELSE ''
                      END
            END
           )
       ) penalties
  FROM pcaph_pc_attr_penalty_header pcaph,
       pcap_pc_attribute_penalty pcap,
       pad_penalty_attribute_details pad,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       rm_ratio_master rm,
       aml_attribute_master_list deducted_element,
       rm_ratio_master deducted_unit
 WHERE pcaph.pcaph_id = pcap.pcaph_id
   AND pcaph.pcaph_id = pad.pcaph_id
   AND pcap.penalty_unit_id = ppu.internal_price_unit_id
   AND ppu.price_unit_id = pum.price_unit_id
   AND rm.ratio_id(+) = pcaph.range_unit_id
   AND deducted_element.attribute_id(+) = pcap.deducted_payable_element
   AND deducted_unit.ratio_id(+) = pcap.deducted_payable_unit_id
   AND pcaph.is_active = 'Y'
   AND pcap.is_active = 'Y'
   AND pcaph.pcaph_id = pcaphid;
   
  cursor cr_element is
   SELECT aml.attribute_name
      as elementname
    FROM pcaph_pc_attr_penalty_header pcaph,
         pad_penalty_attribute_details pad,
         aml_attribute_master_list aml
   WHERE pcaph.pcaph_id = pad.pcaph_id
     AND pcaph.pcaph_id = pcaphid
     AND pad.element_id = aml.attribute_id
     AND pcaph.is_active = 'Y'
     AND pad.is_active = 'Y'
    ORDER BY aml.attribute_name;

   Begin
   for element_rec in cr_element loop
    for penalties_rec in cr_penalties loop
      if(element_rec.elementname = penalties_rec.elementname) then
       penaltydetails := penaltydetails || element_rec.elementname || ': ' || penalties_rec.penalties || chr(10);
      end if;
    end loop;
   end loop;
      
      PENALTY_DETAILS := PENALTY_DETAILS || penaltydetails;
 
    return  PENALTY_DETAILS;
    end;
/
