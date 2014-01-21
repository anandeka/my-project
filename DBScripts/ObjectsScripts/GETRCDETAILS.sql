CREATE OR REPLACE FUNCTION getRCDetails (pcrhid number)
   RETURN VARCHAR2
IS  
    
    cursor cr_rc_quality          
    IS
    
    /*SELECT distinct qat.quality_name           
    FROM PCRH_PC_REFINING_HEADER pcrh,
         RQD_REFINING_QUALITY_DETAILS rqd,
         pcm_physical_contract_main pcm,
         pcpq_pc_product_quality pcpq,
         qat_quality_attributes qat      
    WHERE pcrh.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND rqd.pcrh_id = pcrh.pcrh_id
     AND pcpq.pcpq_id = rqd.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND rqd.is_active = 'Y'
     and PCRH.IS_ACTIVE = 'Y'
     AND pcm.internal_contract_ref_no = pContractNo;*/
     
     SELECT DISTINCT qat.quality_name
           FROM pcrh_pc_refining_header pcrh,
                rqd_refining_quality_details rqd,
                pcpq_pc_product_quality pcpq,
                qat_quality_attributes qat
          WHERE rqd.pcrh_id = pcrhid
            AND pcpq.pcpq_id = rqd.pcpq_id
            AND pcpq.quality_template_id = qat.quality_id
            AND rqd.is_active = 'Y'
            AND pcrh.is_active = 'Y'
            AND pcpq.is_active = 'Y'
            AND qat.is_active = 'Y'
            AND qat.is_deleted = 'N';

    cursor cr_rc          
    IS
    SELECT qat.quality_name , ((aml.attribute_name ||' : ' || pcrh.range_type) ||' '||        
        (CASE 
          WHEN pcerc.range_min_op is null
              THEN ' ' || pcerc.range_max_op || ' ' || pcerc.range_max_value || ' ' || RM.RATIO_NAME || PUM_HEADER.PRICE_UNIT_NAME
          WHEN pcerc.range_max_op is null
              THEN ' ' || pcerc.range_min_op || ' ' || pcerc.range_min_value || ' ' || RM.RATIO_NAME  || PUM_HEADER.PRICE_UNIT_NAME
          ELSE pcerc.range_min_op || ' ' || pcerc.range_min_value || ' to ' || pcerc.range_max_op || ' ' || pcerc.range_max_value  || ' ' ||  RM.RATIO_NAME || PUM_HEADER.PRICE_UNIT_NAME
        END) ||' '||      
        (CASE 
          WHEN pcerc.charge_type = 'Fixed' 
              THEN  f_format_to_char(pcerc.REFINING_CHARGE,2) || ' ' ||  pum.price_unit_name || ' of payable content'
          WHEN pcerc.charge_type = 'Variable'
           THEN CASE 
              WHEN pcerc.POSITION = 'Base'
                THEN 'Base : ' ||  f_format_to_char(pcerc.REFINING_CHARGE,2) || ' ' ||  pum.price_unit_name || ' of payable content' 
              ELSE 'Increase ' ||  f_format_to_char(pcerc.ESC_DESC_VALUE,2) || ' ' || CM.CUR_CODE || ' per ' ||  f_format_to_char(pcerc.REFINING_CHARGE,2) || ' ' ||  pum.price_unit_name
            END 
          ELSE  f_format_to_char(PCERC.REFINING_CHARGE,2) || ' ' ||  pum.price_unit_name || ' of payable content'
        END)) RC
  FROM PCRH_PC_REFINING_HEADER pcrh,
       RED_REFINING_ELEMENT_DETAILS red,
       RQD_REFINING_QUALITY_DETAILS rqd,
       PCERC_PC_ELEM_REFINING_CHARGE pcerc,
       --pcm_physical_contract_main pcm,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       aml_attribute_master_list aml,
       pcpq_pc_product_quality pcpq,
       qat_quality_attributes qat,
       CM_CURRENCY_MASTER cm,RM_RATIO_MASTER rm,
       ppu_product_price_units ppu_header,
       pum_price_unit_master pum_header
 WHERE pcrh.pcrh_id = red.pcrh_id
   AND pcrh.pcrh_id = pcerc.pcrh_id
   AND pcrh.pcrh_id = pcrhid
   --AND pcrh.internal_contract_ref_no = pcm.internal_contract_ref_no
   AND rqd.pcrh_id = pcrh.pcrh_id
   AND pcpq.pcpq_id = rqd.pcpq_id
   AND pcpq.quality_template_id = qat.quality_id
   AND red.element_id = aml.attribute_id
   AND PCRH.PRICE_UNIT_ID = ppu_header.internal_price_unit_id(+)
   AND ppu_header.price_unit_id = pum_header.price_unit_id(+)
   AND PCERC.REFINING_CHARGE_UNIT_ID = ppu.internal_price_unit_id
   AND ppu.price_unit_id = pum.price_unit_id
   and CM.CUR_ID(+) = pcerc.ESC_DESC_UNIT_ID
   and RM.RATIO_ID(+) = PCRH.RANGE_UNIT_ID
   AND pcerc.is_active = 'Y'
   AND pcrh.is_active = 'Y'
   AND red.is_active = 'Y'
   AND rqd.is_active = 'Y'
   --AND PCM.INTERNAL_CONTRACT_REF_NO =pContractNo 
   ORDER BY aml.attribute_name;
 
   RC_DETAILS   VARCHAR2(4000) :='';  
   begin
            for rc_quality_rec in cr_rc_quality
            loop
                
                 RC_DETAILS:= RC_DETAILS ||''|| rc_quality_rec.quality_name ||chr(10);    
            
                 for rc_rec in cr_rc
                 loop
                    
                    if (rc_quality_rec.quality_name = rc_rec.quality_name) then 
                        RC_DETAILS:= RC_DETAILS ||''|| rc_rec.RC || chr(10);
                    end if;
                    
                 end loop;
            
            end loop;
           
            return  RC_DETAILS;
    end;
/



