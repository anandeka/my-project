CREATE OR REPLACE FUNCTION getTCDetails (pcthid number)
   RETURN VARCHAR2
IS
     TC_DETAILS             VARCHAR2(4000) :='';  
     treatmentchargedetails VARCHAR(4000):= '';
     elementname             VARCHAR(50):= '';
     
    cursor cr_tc          
    IS
    SELECT ted.element_name as elementname, (pcth.range_type ||' '||        
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
        END))  as tc 
  FROM pcth_pc_treatment_header pcth,
       ted_treatment_element_details ted,
       tqd_treatment_quality_details tqd,
       pcetc_pc_elem_treatment_charge pcetc,
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
  ORDER BY aml.attribute_name;

cursor cr_element          
    IS
 SELECT  aml.attribute_name as elementname
        FROM pcth_pc_treatment_header pcth,
         ted_treatment_element_details ted,
         aml_attribute_master_list aml
    WHERE pcth.pcth_id = ted.pcth_id
     AND pcth.pcth_id = pcthid
     AND ted.element_id = aml.attribute_id
     AND pcth.is_active = 'Y'
     AND ted.is_active = 'Y'
    ORDER BY aml.attribute_name;
      
  Begin
   
   for element_rec in cr_element loop
     for tc_rec in cr_tc loop
      if(element_rec.elementname = tc_rec.elementname) then
      treatmentchargedetails :=  treatmentchargedetails || tc_rec.elementname || ': '|| tc_rec.tc || chr(10);
      end if;
     end loop; 
   end loop;
   
      TC_DETAILS := TC_DETAILS || treatmentchargedetails;
     
     return  TC_DETAILS;
    end;
/
