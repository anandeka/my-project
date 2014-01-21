CREATE OR REPLACE FUNCTION "GETPAYABLECONTENTDETAILS" (pcpchid number)
   RETURN CLOB
IS
    cursor cr_pc_quality          
    IS
    
    /*SELECT distinct qat.quality_name           
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
     AND pcm.internal_contract_ref_no = pContractNo;*/
     
     SELECT DISTINCT qat.quality_name as qualityname
           FROM pcpch_pc_payble_content_header pcpch,
                pqd_payable_quality_details pqd,
                pcpq_pc_product_quality pcpq,
                qat_quality_attributes qat
          WHERE pcpch.pcpch_id = pcpchid
            AND pqd.pcpch_id = pcpch.pcpch_id
            AND pcpq.pcpq_id = pqd.pcpq_id
            AND pcpq.quality_template_id = qat.quality_id
            AND pqd.is_active = 'Y'
            AND pcpch.is_active = 'Y';
  
    cursor cr_pc          
    IS

    SELECT qat.quality_name as quality_name,
           aml.attribute_name as element_Name,
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
         ) as quantity, ppf.external_formula as formula,
            pcepc.payable_content_value as payable_content,
            pcepc.assay_deduction|| rm.ratio_name as assay_deduction,
         (CASE
             WHEN pcepc.include_ref_charges = 'Y'
                THEN f_format_to_char(pcepc.refining_charge_value,4) || ' ' || pum.price_unit_name
          END
         ) as refining_charge
    FROM pcpch_pc_payble_content_header pcpch,
         pqd_payable_quality_details pqd,
         pcepc_pc_elem_payable_content pcepc,
         --pcm_physical_contract_main pcm,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         aml_attribute_master_list aml,
         pcpq_pc_product_quality pcpq,
         qat_quality_attributes qat,
         ppf_phy_payable_formula ppf,
         rm_ratio_master rm
   WHERE pcpch.pcpch_id = pcepc.pcpch_id
     AND pcpch.pcpch_id = pcpchid
     --AND pcpch.internal_contract_ref_no = pcm.internal_contract_ref_no
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
     AND pqd.is_active = 'Y';
    -- AND pcm.internal_contract_ref_no = pContractNo;
 
   PC_DETAILS   CLOB :='';     
    begin
            for pc_quality_rec in cr_pc_quality
            loop
                
                 PC_DETAILS:= PC_DETAILS ||''||pc_quality_rec.qualityname || chr(10);    
            
                 for pc_rec in cr_pc
                 loop
                    
                    if (pc_quality_rec.qualityname = pc_rec.quality_name) then 
                       -- PC_DETAILS:= PC_DETAILS ||''|| pc_rec.payable_content ||' '|| chr(10);
                       PC_DETAILS:= PC_DETAILS || pc_rec.element_Name || chr(10) 
                                    || 'Quantity: ' || pc_rec.quantity || chr(10)
                                    || 'Payable Content: ' || pc_rec.payable_content || chr(10)
                                    || 'Assay Deduction: ' || pc_rec.assay_deduction || chr(10) || chr(10);
                       
                        if (pc_rec.refining_charge is not null) then
                            PC_DETAILS := PC_DETAILS ||
                           'Refining Chargese: ' || pc_rec.refining_charge || chr(10);
                         end if;         
                                    
                    end if;
                    
                 end loop;
            
            end loop;
           
            return  PC_DETAILS;
    end;
/
