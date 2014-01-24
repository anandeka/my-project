CREATE OR REPLACE FUNCTION GETCONTRACTQUALITYDETAILS (
p_contractNo VARCHAR2 
)
return CLOB is

    cursor cr_quality 
    IS
          Select QAT.QUALITY_NAME ||': '|| (CASE
              WHEN PCPQ.QTY_TYPE ='Fixed'
                 THEN PCPQ.QTY_MAX_VAL || ' ' || PCPQ.UNIT_OF_MEASURE ||' '|| QUM.QTY_UNIT_DESC 
              ELSE PCPQ.QTY_MIN_OP ||' '||  PCPQ.QTY_MIN_VAL ||' '||  PCPQ.QTY_MAX_OP ||' '||  PCPQ.QTY_MAX_VAL || ' '|| QUM.QTY_UNIT_DESC 
              END
              ) quality_details,ORM.ORIGIN_NAME as origin_name,
         (CASE
              WHEN PCPQ.ASSAY_HEADER_ID IS NOT NULL
                 THEN getChemicalAttributes(PCPQ.ASSAY_HEADER_ID)
          END) CHEM_ATTR,
          (CASE
              WHEN PCPQ.PHY_ATTRIBUTE_GROUP_NO IS NOT NULL
                 THEN getPhysicalAttributes(PCPQ.PHY_ATTRIBUTE_GROUP_NO)
          END) PHY_ATTR             
          
    from PCPQ_PC_PRODUCT_QUALITY PCPQ, PCPD_PC_PRODUCT_DEFINITION PCPD, QAT_QUALITY_ATTRIBUTES QAT,
    QUM_QUANTITY_UNIT_MASTER QUM,POM_PRODUCT_ORIGIN_MASTER pom,ORM_ORIGIN_MASTER orm
    Where PCPQ.QTY_UNIT_ID = QUM.QTY_UNIT_ID 
     AND PCPQ.QUALITY_TEMPLATE_ID = QAT.QUALITY_ID 
     AND PCPD.PCPD_ID = PCPQ.PCPD_ID
     AND QAT.PRODUCT_ORIGIN_ID = POM.PRODUCT_ORIGIN_ID(+)
     AND POM.ORIGIN_ID = ORM.ORIGIN_ID(+)
     AND PCPQ.IS_ACTIVE = 'Y'
     AND PCPD.INTERNAL_CONTRACT_REF_NO =p_contractNo
     order by QAT.QUALITY_NAME;   
    
    qualityDescription CLOB :='';  
    begin
            for quality_rec in cr_quality
            loop
            if(qualityDescription is not null) then
            qualityDescription:=qualityDescription ||chr(10)||quality_rec.quality_details ||chr(10);
            else
            qualityDescription:=quality_rec.quality_details ||chr(10);
            end if;
                        
            if (quality_rec.origin_name is not null) then
                qualityDescription:=qualityDescription ||'Origin: ' || quality_rec.origin_name || chr(10);
            end if;
            
            if (quality_rec.CHEM_ATTR is not null) then
                qualityDescription:=qualityDescription ||'Typical Assays:' || chr(10)|| quality_rec.CHEM_ATTR ;
            end if;
            
            if (quality_rec.PHY_ATTR is not null) then
                qualityDescription:=qualityDescription || chr(10) ||'Physical Specifications: '|| chr(10)|| quality_rec.PHY_ATTR;
            end if;
           
            end loop;
            return  qualityDescription;
    end;
/
