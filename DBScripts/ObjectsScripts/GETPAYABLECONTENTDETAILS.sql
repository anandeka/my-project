CREATE OR REPLACE FUNCTION getPayableContentDetails (pContractNo number)
   RETURN VARCHAR2
IS
    
    cursor cr_pc_quality          
    IS
    
    SELECT distinct qat.quality_name           
    FROM pcpch_pc_payble_content_header pcpch,
         pqd_payable_quality_details pqd,
         pcm_physical_contract_main pcm,
         pcpq_pc_product_quality pcpq,
         qat_quality_attributes qat      
    WHERE pcpch.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pqd.pcpch_id = pcpch.pcpch_id
     AND pcpq.pcpq_id = pqd.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND pqd.is_active = 'Y'
     AND pcpch.is_active = 'Y'
     AND pcm.internal_contract_ref_no = pContractNo;

    cursor cr_pc          
    IS

    SELECT  qat.quality_name ,
          (aml.attribute_name || ' :' || 
         (CASE
             WHEN pcepc.range_min_op IS NULL
                THEN    ' '
                     || pcepc.range_max_op
                     || ' '
                     || pcepc.range_max_value
                     || ' '
                     || rm.ratio_name
             WHEN pcepc.range_max_op IS NULL
                THEN    ' '
                     || pcepc.range_min_op
                     || ' '
                     || pcepc.range_min_value
                     || ' '
                     || rm.ratio_name
             ELSE    pcepc.range_min_op
                  || ' '
                  || pcepc.range_min_value
                  || ' to '
                  || pcepc.range_max_op
                  || ' '
                  || pcepc.range_max_value
                  || ' '
                  || rm.ratio_name
          END
         ) ||' ,Formula : '||   
         (   ppf.external_formula
          || ' where payable content = '
          || pcepc.payable_content_value
          || ' % and assay deduction = '
          || pcepc.assay_deduction
          || ' '
          || rm.ratio_name
         ) ||' '||   
         (CASE
             WHEN pcepc.include_ref_charges = 'Y'
                THEN  ',Refining Charges : ' ||  f_format_to_char(pcepc.refining_charge_value,4) || ' ' || pum.price_unit_name
          END
         ) ) AS payable_content
    FROM pcpch_pc_payble_content_header pcpch,
         pqd_payable_quality_details pqd,
         pcepc_pc_elem_payable_content pcepc,
         pcm_physical_contract_main pcm,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         aml_attribute_master_list aml,
         pcpq_pc_product_quality pcpq,
         qat_quality_attributes qat,
         ppf_phy_payable_formula ppf,
         rm_ratio_master rm
   WHERE pcpch.pcpch_id = pcepc.pcpch_id
     AND pcpch.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pqd.pcpch_id = pcpch.pcpch_id
     AND pcpq.pcpq_id = pqd.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND pcpch.element_id = aml.attribute_id
     AND pcepc.refining_charge_unit_id = ppu.internal_price_unit_id(+)
     AND ppu.price_unit_id = pum.price_unit_id(+)
     AND rm.ratio_id = pcpch.range_unit_id
     AND ppf.ppf_id = pcepc.payable_formula_id
     AND pcepc.is_active = 'Y'
     AND pcpch.is_active = 'Y'
     AND pqd.is_active = 'Y'
     AND pcm.internal_contract_ref_no = pContractNo;
 
   PC_DETAILS   VARCHAR2(4000) :='';     
    begin
            for pc_quality_rec in cr_pc_quality
            loop
                
                 PC_DETAILS:= PC_DETAILS ||''|| pc_quality_rec.quality_name ||chr(10);    
            
                 for pc_rec in cr_pc
                 loop
                    
                    if (pc_quality_rec.quality_name = pc_rec.quality_name) then 
                        PC_DETAILS:= PC_DETAILS ||''|| pc_rec.payable_content ||' '|| chr(10);
                    end if;
                    
                 end loop;
            
            end loop;
           
            return  PC_DETAILS;
    end;
/
