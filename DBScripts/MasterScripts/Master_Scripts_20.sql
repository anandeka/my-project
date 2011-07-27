SET DEFINE OFF;
Insert into URM_UMPIRE_RULE_MASTER
   (URM_ID, RULE_DESC, RULE_FORMULA, IS_ACTIVE, VERSION, 
    RULE_NAME)
 Values
   ('3', 'Average of Ours, Umpire and counterparty assay
.', '<?xml version="1.0" encoding="UTF-8"?>
<rule-execution-set>
   <name>RuleExecutionSet1</name>
   <description>Rule Execution Set</description>

   <synonymn name="assay" class="com.ekaplus.metals.entity.assaymanagement.assayfinalization.UmpireAssay" />

    
    
    <rule name="Rule1" description="Average of Ours, Umpire and counterparty assay" >
        <if leftTerm="2" op="&gt;" rightTerm="1" />
        
        <then method="assay.setFinalAssay" arg1="avg" />
    
   </rule>
   
   
   
</rule-execution-set>', 'Y', 0, 
    'Average of Ours, Umpire and counterparty assay.');
COMMIT;
