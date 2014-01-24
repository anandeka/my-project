CREATE OR REPLACE FUNCTION GETASSAYINRULES (pContractNo number)
   RETURN CLOB
IS
    ASSAY_RULES            CLOB :='';
    umpires_list           VARCHAR2 (4000) := ''; 
    elementname            VARCHAR2 (50);
    finalassay             VARCHAR2 (1000);
    finalizemethod         VARCHAR2 (10000);
    qualityname            VARCHAR2 (50) := '';
    assay_details          CLOB :='';
    
   
    cursor cr_assay_quality          
    IS
    SELECT distinct qat.quality_name as qualityname         
    FROM pcar_pc_assaying_rules pcar,
         arqd_assay_quality_details arqd,
         pcm_physical_contract_main pcm,
         pcpq_pc_product_quality pcpq,
         qat_quality_attributes qat      
    WHERE pcar.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND arqd.pcar_id = pcar.pcar_id
     AND pcpq.pcpq_id = arqd.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND arqd.is_active = 'Y'
     AND pcar.is_active = 'Y'
     AND pcm.internal_contract_ref_no = pContractNo;
     
    cursor cr_assay_header          
    IS
    SELECT qat.quality_name AS qualityname, pcar.pcar_id AS pcarid
  FROM pcar_pc_assaying_rules pcar,
       arqd_assay_quality_details arqd,
       pcm_physical_contract_main pcm,
       pcpq_pc_product_quality pcpq,
       qat_quality_attributes qat
 WHERE pcar.internal_contract_ref_no = pcm.internal_contract_ref_no
   AND arqd.pcar_id = pcar.pcar_id
   AND pcpq.pcpq_id = arqd.pcpq_id
   AND pcpq.quality_template_id = qat.quality_id
   AND arqd.is_active = 'Y'
   AND pcar.is_active = 'Y'
   AND pcm.internal_contract_ref_no = pContractNo;

    
   /* cursor cr_ar          
    IS

    SELECT qat.quality_name ,
         (aml.attribute_name ||' : '|| CHR(10) ||
         'Final Assay  :     Will be finalized based on ' || PCAR.FINAL_ASSAY_BASIS_ID || CHR(10) ||
         (case
            when PCAR.FINAL_ASSAY_BASIS_ID = 'Assay Exchange' 
                then 'Method        :     '|| PCAR.COMPARISION || ' ' ||     
                    case 
                        when PCAR.COMPARISION = 'Apply Spliting Limit' and  PCAR.SPLIT_LIMIT_BASIS = 'Fixed'
                            then rtrim(TO_CHAR(PCAR.SPLIT_LIMIT, 'FM999990D909999999'),'.') || RM.RATIO_NAME
                        when PCAR.COMPARISION = 'Apply Spliting Limit' and PCAR.SPLIT_LIMIT_BASIS = 'Assay Content Based'
                            then rtrim(TO_CHAR (PCAESL.APPLICABLE_VALUE, 'FM999990D909999999'),'.')  || RM.RATIO_NAME || ' ,if range falls in   '|| PCAESL.ASSAY_MIN_OP || ' ' || rtrim(TO_CHAR(PCAESL.ASSAY_MIN_VALUE, 'FM999990D909999999'),'.') || ' to ' || PCAESL.ASSAY_MAX_OP || ' ' || rtrim(TO_CHAR(PCAESL.ASSAY_MAX_VALUE, 'FM999990D909999999'),'.') || RM.RATIO_NAME                     
                    end
         end) ) as final_assay
    FROM pcar_pc_assaying_rules pcar,
         pcaesl_assay_elem_split_limits pcaesl,
         arqd_assay_quality_details arqd,
         pcm_physical_contract_main pcm,
         aml_attribute_master_list aml,
         pcpq_pc_product_quality pcpq,
         qat_quality_attributes qat,
         rm_ratio_master rm,
         URM_UMPIRE_RULE_MASTER urm  
   WHERE pcar.pcar_id = pcaesl.pcar_id(+)
     and  pcar.internal_contract_ref_no = pcm.internal_contract_ref_no
     and PCM.UMPIRE_RULE_ID = URM.URM_ID(+)
     AND arqd.pcar_id = pcar.pcar_id
     AND pcpq.pcpq_id = arqd.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND pcar.element_id = aml.attribute_id
     AND rm.ratio_id = pcar.split_limit_unit_id
     AND pcar.is_active = 'Y'
     AND pcaesl.is_active(+) = 'Y'
     AND arqd.is_active = 'Y'
     AND pcm.internal_contract_ref_no = pContractNo
     order by AML.ATTRIBUTE_NAME;*/
   
    cursor cr_umpire
    is
    SELECT URM.RULE_DESC as umpire_rule,
            PCM.COST_BASIS_ID  as umpire_cost    
     FROM   pcm_physical_contract_main pcm,URM_UMPIRE_RULE_MASTER urm  
     where  PCM.UMPIRE_RULE_ID = URM.URM_ID
     AND pcm.internal_contract_ref_no = pContractNo;
     
    cursor cr_umpires_list
    is
    select PHD.COMPANYNAME as umpire_name,PAD.ADDRESS as umpire_address from PCM_PHYSICAL_CONTRACT_MAIN pcm,PCU_PC_UMPIRES pcu, PHD_PROFILEHEADERDETAILS phd,
    PAD_PROFILE_ADDRESSES pad
    where PCM.INTERNAL_CONTRACT_REF_NO = PCU.INTERNAL_CONTRACT_REF_NO
    and PCU.UMPIRE_ID = PHD.PROFILEID
    and PHD.PROFILEID = PAD.PROFILE_ID
    and PAD.IS_DELETED = 'N'
    and PAD.ADDRESS_TYPE = 'Main'
    and PCU.IS_ACTIVE = 'Y'
    AND pcm.internal_contract_ref_no = pContractNo;

   begin
            /*for assay_quality_rec in cr_assay_quality
            loop
                
                 ASSAY_RULES:= ASSAY_RULES ||''|| assay_quality_rec.quality_name ||chr(10);    
            
                 for ar_rec in cr_ar
                 loop
                    
                         if (assay_quality_rec.quality_name = ar_rec.quality_name) then 
                        ASSAY_RULES:= ASSAY_RULES || ar_rec.final_assay || chr(10);
                    end if;
                    
                 end loop;
            
            end loop;*/
            
          for assay_quality_rec in cr_assay_quality
            loop

            for assay_header_rec in cr_assay_header
            loop
            
            if(assay_quality_rec.qualityname= assay_header_rec.qualityname)
              then
              qualityname := assay_quality_rec.qualityname;
              
            SELECT pcar.element_name
                INTO elementname
                FROM pcar_pc_assaying_rules pcar
                WHERE pcar.pcar_id = assay_header_rec.pcarid
                AND pcar.is_active = 'Y';

            SELECT pcar.final_assay_basis_id
                INTO finalassay
                FROM pcar_pc_assaying_rules pcar
                WHERE pcar.pcar_id = assay_header_rec.pcarid
                AND pcar.is_active = 'Y';
                   
            assay_details:= assay_details || elementname || ':' || chr(10)
                         || 'Final Assay: Will be finalized based on ' || finalassay || chr(10);
                         
             if(finalassay = 'Assay Exchange')    
             then          
                     assay_details := assay_details || 'Method: ' || GETASSAYSPLITLIMIT(assay_header_rec.pcarid)|| chr(10);
              end if;
              
              end if;
            end loop;
            
            ASSAY_RULES:= ASSAY_RULES || qualityname || chr(10) || assay_details ;
            
            assay_details:='';
          end loop;
            
           for umpire in cr_umpire
            loop
                if (umpire.umpire_rule is not null) then
                     ASSAY_RULES:= ASSAY_RULES || 'Umpire Rule: '|| umpire.umpire_rule;
                end if;
                if (umpire.umpire_cost is not null) then
                     ASSAY_RULES:= ASSAY_RULES || chr(10) || 'Umpiring Cost: '|| umpire.umpire_cost;
                end if;
                            
            end loop;
            
            for umpires in cr_umpires_list
            loop
                if (umpires.umpire_name is not null) then
                     umpires_list:= umpires_list || chr(10) ||  umpires.umpire_name ||',' ||umpires.umpire_address||'. ';
                end if;
            end loop;
            
            if (umpires_list is not null) then
                     ASSAY_RULES:= ASSAY_RULES || chr(10) || 'Umpires: '|| umpires_list;
            end if;        
   
            return  ASSAY_RULES;
    end;
/
