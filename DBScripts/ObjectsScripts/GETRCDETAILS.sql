CREATE OR REPLACE FUNCTION getRCDetails (pcrhid number)
   RETURN VARCHAR2
IS  
    
     RC_DETAILS             VARCHAR2(4000) :='';  
     refiningchargedetails  VARCHAR(4000):= '';
     elementname            VARCHAR(50):= '';

cursor cr_rc          
    IS
    SELECT red.element_name as elementname, (pcrh.range_type || '' ||  
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
       PCERC_PC_ELEM_REFINING_CHARGE pcerc,
       RED_REFINING_ELEMENT_DETAILS red,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       CM_CURRENCY_MASTER cm,
       RM_RATIO_MASTER rm,
       ppu_product_price_units ppu_header,
       pum_price_unit_master pum_header
 WHERE  pcrh.pcrh_id = pcerc.pcrh_id
   AND pcrh.pcrh_id = pcrhid
   AND PCRH.PCRH_ID = red.PCRH_ID
   AND PCRH.PRICE_UNIT_ID = ppu_header.internal_price_unit_id(+)
   AND ppu_header.price_unit_id = pum_header.price_unit_id(+)
   AND PCERC.REFINING_CHARGE_UNIT_ID = ppu.internal_price_unit_id
   AND ppu.price_unit_id = pum.price_unit_id
   and CM.CUR_ID(+) = pcerc.ESC_DESC_UNIT_ID
   and RM.RATIO_ID(+) = PCRH.RANGE_UNIT_ID
   AND pcerc.is_active = 'Y'
   AND pcrh.is_active = 'Y';
   
   cursor cr_element         
    IS
   SELECT   aml.attribute_name
    as elementname
    FROM pcrh_pc_refining_header pcrh,
         red_refining_element_details red,
         aml_attribute_master_list aml
   WHERE pcrh.pcrh_id = red.pcrh_id
     AND pcrh.pcrh_id = pcrhid
     AND red.element_id = aml.attribute_id
     AND pcrh.is_active = 'Y'
     AND red.is_active = 'Y'
    ORDER BY aml.attribute_name;
     
   begin
   
    for element_rec in cr_element loop
      for rc_rec in cr_rc loop
       if(element_rec.elementname = rc_rec.elementname) then
       refiningchargedetails := refiningchargedetails || element_rec.elementname || ': ' || rc_rec.rc || chr(10);
       end if;
      end loop;
    end loop;
      
      RC_DETAILS := RC_DETAILS || refiningchargedetails;
   
      return  RC_DETAILS;
    end;
/
