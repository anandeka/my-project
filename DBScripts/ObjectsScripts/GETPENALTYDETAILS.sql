CREATE OR REPLACE FUNCTION getPenaltyDetails (pContractNo number)
   RETURN VARCHAR2
IS

    cursor cr_penalty_quality          
    IS
    
    SELECT distinct qat.quality_name           
    FROM pcaph_pc_attr_penalty_header pcaph,
         pqd_penalty_quality_details pqd,
         pcm_physical_contract_main pcm,
         pcpq_pc_product_quality pcpq,
         qat_quality_attributes qat      
    WHERE pcaph.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND PQD.PCAPH_ID = pcaph.PCAPH_ID
     AND pcpq.pcpq_id = pqd.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND pqd.is_active = 'Y'
     AND PCAPH.IS_ACTIVE ='Y'
     AND pcm.internal_contract_ref_no = pContractNo;
     
    cursor cr_penalties          
    IS
   
    SELECT qat.quality_name , ((aml.attribute_name)||' :'|| 
        (CASE 
          WHEN pcap.range_min_op is null
              THEN ' ' || pcap.range_max_op || ' ' || pcap.range_max_value || ' ' || RM.RATIO_NAME 
          WHEN pcap.range_max_op is null
              THEN ' ' || pcap.range_min_op || ' ' || pcap.range_min_value || ' ' || RM.RATIO_NAME  
          ELSE pcap.range_min_op || ' ' || pcap.range_min_value || ' to ' || pcap.range_max_op || ' ' || pcap.range_max_value  || ' ' ||  RM.RATIO_NAME 
        END) ||'  '||        
         (CASE 
          WHEN pcap.penalty_charge_type = 'Fixed' 
              THEN  f_format_to_char(pcap.penalty_amount,4) || ' ' ||  pum.price_unit_name ||  ' of ' || pcap.penalty_weight_type || ' weight'
          WHEN pcap.penalty_charge_type = 'Variable'
           THEN CASE 
              WHEN pcap.penalty_basis = 'Quantity'
                THEN  f_format_to_char(pcap.penalty_amount,4) || ' ' ||  pum.price_unit_name ||  ' of ' || pcap.penalty_weight_type || ' weight per ' || PCAP.PER_INCREASE_VALUE || ' ' ||  RM.RATIO_NAME  || ' increase'
              WHEN pcap.penalty_basis = 'Payable Content'
                THEN 'deduct ' || PCAP.DEDUCTED_PAYABLE_VALUE || DEDUCTED_UNIT.RATIO_NAME || 'of' ||  DEDUCTED_ELEMENT.ATTRIBUTE_NAME || ' per ' || PCAP.PER_INCREASE_VALUE || ' ' ||  RM.RATIO_NAME || ' increase'  
             ELSE
             ''
            END 
          
        END)) penalties
  FROM pcaph_pc_attr_penalty_header pcaph,
       pcap_pc_attribute_penalty pcap,
       pqd_penalty_quality_details pqd,
       pad_penalty_attribute_details pad,
       pcm_physical_contract_main pcm,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       aml_attribute_master_list aml,
       pcpq_pc_product_quality pcpq,
       qat_quality_attributes qat,
       RM_RATIO_MASTER rm,
        AML_ATTRIBUTE_MASTER_LIST deducted_element,
        RM_RATIO_MASTER deducted_unit
 WHERE pcaph.pcaph_id = pcap.pcaph_id
   AND pcaph.pcaph_id = pqd.pcaph_id
   AND pcaph.pcaph_id = pad.pcaph_id
   AND pcaph.internal_contract_ref_no = pcm.internal_contract_ref_no
   AND pqd.pcpq_id = pcpq.pcpq_id
   AND pcpq.quality_template_id = qat.quality_id
   AND pad.element_id = aml.attribute_id
   AND pcap.penalty_unit_id = ppu.internal_price_unit_id
   AND ppu.price_unit_id = pum.price_unit_id
   and RM.RATIO_ID(+) = pcaph.RANGE_UNIT_ID
   and DEDUCTED_ELEMENT.ATTRIBUTE_ID(+) = PCAP.DEDUCTED_PAYABLE_ELEMENT
   and DEDUCTED_UNIT.RATIO_ID(+) = PCAP.DEDUCTED_PAYABLE_UNIT_ID
   AND PCAPH.IS_ACTIVE ='Y'
   AND pqd.IS_ACTIVE ='Y'
   AND pad.IS_ACTIVE ='Y'
   AND pcap.IS_ACTIVE ='Y'
   AND PCM.INTERNAL_CONTRACT_REF_NO =pContractNo;

 
   PENALTY_DETAILS   VARCHAR2(4000) :='';
   begin
            for penalty_quality_rec in cr_penalty_quality
            loop
                
                 PENALTY_DETAILS:= PENALTY_DETAILS ||''|| penalty_quality_rec.quality_name ||chr(10);    
            
                 for penalty_rec in cr_penalties
                 loop
                    
                    if (penalty_quality_rec.quality_name = penalty_rec.quality_name) then 
                        PENALTY_DETAILS:= PENALTY_DETAILS ||''|| penalty_rec.penalties || chr(10);
                    end if;
                    
                 end loop;
            
            end loop;
           
            return  PENALTY_DETAILS;
    end;
/
