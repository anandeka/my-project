CREATE OR REPLACE FUNCTION getTCDetails (pcthid number)
   RETURN VARCHAR2
IS

    cursor cr_tc_quality          
    IS
    
    /*SELECT distinct qat.quality_name           
    FROM pcth_pc_treatment_header pcth,
         tqd_treatment_quality_details tqd,
         pcm_physical_contract_main pcm,
         pcpq_pc_product_quality pcpq,
         qat_quality_attributes qat      
    WHERE pcth.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND tqd.pcth_id = pcth.pcth_id
     AND pcpq.pcpq_id = tqd.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND tqd.is_active = 'Y'
     AND pcth.is_active = 'Y'
     AND pcm.internal_contract_ref_no = pContractNo;*/
     
     SELECT DISTINCT qat.quality_name
           FROM pcth_pc_treatment_header pcth,
                tqd_treatment_quality_details tqd,
                pcpq_pc_product_quality pcpq,
                qat_quality_attributes qat
          WHERE tqd.pcth_id = pcthid
            AND pcpq.pcpq_id = tqd.pcpq_id
            AND pcpq.quality_template_id = qat.quality_id
            AND tqd.is_active = 'Y'
            AND pcth.is_active = 'Y';
     
    cursor cr_tc          
    IS
    SELECT qat.quality_name , ((aml.attribute_name ||' : ' || pcth.range_type) ||' '||        
        (CASE 
          WHEN pcetc.range_min_op is null
              THEN ' ' || pcetc.range_max_op || ' ' || pcetc.range_max_value || ' ' || RM.RATIO_NAME || PUM_HEADER.PRICE_UNIT_NAME
          WHEN pcetc.range_max_op is null
              THEN ' ' || pcetc.range_min_op || ' ' || pcetc.range_min_value || ' ' || RM.RATIO_NAME  || PUM_HEADER.PRICE_UNIT_NAME
          ELSE pcetc.range_min_op || ' ' || pcetc.range_min_value || ' to ' || pcetc.range_max_op || ' ' || pcetc.range_max_value  || ' ' ||  RM.RATIO_NAME || PUM_HEADER.PRICE_UNIT_NAME
        END) ||'  '||    
        (CASE 
          WHEN pcetc.charge_type = 'Fixed' 
              THEN  f_format_to_char(pcetc.treatment_charge,2) || ' ' ||  pum.price_unit_name || ' of ' || pcetc.weight_type || ' weight'
          WHEN pcetc.charge_type = 'Variable'
           THEN CASE 
              WHEN PCETC.POSITION = 'Base'
                THEN 'Base : ' ||  f_format_to_char(pcetc.treatment_charge,2) || ' ' ||  pum.price_unit_name || ' of ' || pcetc.weight_type || ' weight' 
              ELSE 'Increase ' ||  f_format_to_char(PCETC.ESC_DESC_VALUE,2) || ' ' || CM.CUR_CODE || ' per ' ||  f_format_to_char(pcetc.treatment_charge,2) || ' ' ||  pum.price_unit_name
            END 
          ELSE  f_format_to_char(pcetc.treatment_charge,2) || ' ' ||  pum.price_unit_name || ' of ' || pcetc.weight_type || ' weight'
        END))  as TC 
  FROM pcth_pc_treatment_header pcth,
       ted_treatment_element_details ted,
       tqd_treatment_quality_details tqd,
       pcetc_pc_elem_treatment_charge pcetc,
       --pcm_physical_contract_main pcm,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       aml_attribute_master_list aml,
       pcpq_pc_product_quality pcpq,
       qat_quality_attributes qat,
       CM_CURRENCY_MASTER cm,RM_RATIO_MASTER rm,
       ppu_product_price_units ppu_header,
       pum_price_unit_master pum_header
 WHERE pcth.pcth_id = ted.pcth_id
   AND pcth.pcth_id = pcetc.pcth_id
   AND pcth.pcth_id = pcthid
   --AND pcth.internal_contract_ref_no = pcm.internal_contract_ref_no
   AND tqd.pcth_id = pcth.pcth_id
   AND pcpq.pcpq_id = tqd.pcpq_id
   AND pcpq.quality_template_id = qat.quality_id
   AND ted.element_id = aml.attribute_id
   AND PCTH.PRICE_UNIT_ID = ppu_header.internal_price_unit_id(+)
   AND ppu_header.price_unit_id = pum_header.price_unit_id(+)
   AND pcetc.treatment_charge_unit_id = ppu.internal_price_unit_id
   AND ppu.price_unit_id = pum.price_unit_id
   and CM.CUR_ID(+) = pcetc.ESC_DESC_UNIT_ID
   and RM.RATIO_ID(+) = PCTH.RANGE_UNIT_ID
   AND pcetc.is_active = 'Y'
   AND pcth.is_active = 'Y'
   AND ted.is_active = 'Y'
   AND tqd.is_active = 'Y'
   --AND pcm.internal_contract_ref_no =pContractNo;
  ORDER BY aml.attribute_name;
 
   TC_DETAILS   VARCHAR2(4000) :='';     
   begin
            for tc_quality_rec in cr_tc_quality
            loop
                
                 TC_DETAILS:= TC_DETAILS ||''|| tc_quality_rec.quality_name ||chr(10);    
            
                 for tc_rec in cr_tc
                 loop
                    
                    if (tc_quality_rec.quality_name = tc_rec.quality_name) then 
                        TC_DETAILS:= TC_DETAILS ||''|| tc_rec.TC || chr(10);
                    end if;
                    
                 end loop;
            
            end loop;
           
            return  TC_DETAILS;
    end;
/
