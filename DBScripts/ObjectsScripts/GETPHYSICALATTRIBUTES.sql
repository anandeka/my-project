CREATE OR REPLACE FUNCTION "GETPHYSICALATTRIBUTES" (
p_groupNo VARCHAR2 
)
return VARCHAR2 is
    cursor cr_phyAttr          
    IS
    Select ('Attribute Name: '|| AML.ATTRIBUTE_NAME || chr(10) || 'Description: ' || PQPA.ATTRIBUTE_VALUE || chr(10) ||'Rejection: ' || nvl(PQPA.REJECTION,'NA')) AS PHY_ATTR
    From PQPA_PQ_PHYSICAL_ATTRIBUTES PQPA, AML_ATTRIBUTE_MASTER_LIST AML
    Where 
    PQPA.ATTRIBUTE_ID = AML.ATTRIBUTE_ID AND 
    PQPA.IS_ACTIVE = 'Y' AND
    PQPA.PHY_ATTRIBUTE_GROUP_NO =p_groupNo;  
    
    qualityDescription VARCHAR2(4000) :='';   
    begin
            for phy_rec in cr_phyAttr
            loop
            qualityDescription:= qualityDescription || phy_rec.PHY_ATTR || chr(10);
            end loop;
            return  qualityDescription;
    end;
/
