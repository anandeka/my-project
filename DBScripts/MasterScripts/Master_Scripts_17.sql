SET DEFINE OFF;
Insert into URM_UMPIRE_RULE_MASTER
   (URM_ID, RULE_DESC, RULE_FORMULA, IS_ACTIVE, VERSION, 
    RULE_NAME)
 Values
   ('2', 'The Umpire Assay is taken as final.', '<?xml version="1.0" encoding="UTF-8"?>
<rule-execution-set>
   <name>RuleExecutionSet1</name>
   <description>Rule Execution Set</description>

   <synonymn name="assay" class="com.ekaplus.metals.entity.assaymanagement.assayfinalization.UmpireAssay" />

    
    
    <rule name="Rule1" description="The umpire is taken as final final" >
        <if leftTerm="2" op="&gt;" rightTerm="1" />
        
        <then method="assay.setFinalAssay" arg1="umpire" />
    
   </rule>
   
   
   
</rule-execution-set>', 'Y', 0, 
    'The Umpire Assay is taken as final.');
Insert into URM_UMPIRE_RULE_MASTER
   (URM_ID, RULE_DESC, RULE_FORMULA, IS_ACTIVE, VERSION, 
    RULE_NAME)
 Values
   ('1', 'The middle one is final', '<?xml version="1.0" encoding="UTF-8"?>
<rule-execution-set>
   <name>RuleExecutionSet1</name>
   <description>Rule Execution Set</description>

   <synonymn name="assay" class="com.ekaplus.metals.entity.assaymanagement.assayfinalization.UmpireAssay" />

    
    
    <rule name="Rule1" description="The middle one is final" >
        <if leftTerm="assay.getCpAssay" op="&gt;" rightTerm="assay.getSelfAssay" />
        <if leftTerm="assay.getCpAssay" op="&lt;" rightTerm="assay.getUmpiringAssay" />
        <then method="assay.setFinalAssay" arg1="cp" />
    
   </rule>
   <rule name="Rule2" description="The middle one is final" >
        <if leftTerm="assay.getCpAssay" op="&lt;" rightTerm="assay.getSelfAssay" />
        <if leftTerm="assay.getCpAssay" op="&gt;" rightTerm="assay.getUmpiringAssay" />
        <then method="assay.setFinalAssay" arg1="cp" />
   </rule>
   <rule name="Rule3" description="The middle one is final" >
        <if leftTerm="assay.getSelfAssay" op="&gt;" rightTerm="assay.getCpAssay" />
        <if leftTerm="assay.getSelfAssay" op="&lt;" rightTerm="assay.getUmpiringAssay" />
        <then method="assay.setFinalAssay" arg1="self" />
   </rule>
    <rule name="Rule4" description="The middle one is final">
       <if leftTerm="assay.getSelfAssay" op="&lt;" rightTerm="assay.getCpAssay" />
        <if leftTerm="assay.getSelfAssay" op="&gt;" rightTerm="assay.getUmpiringAssay" />
        <then method="assay.setFinalAssay" arg1="self" />
   </rule>
   <rule name="Rule5" description="The middle one is final" >
        <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay" />
        <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay" />
        <then method="assay.setFinalAssay" arg1="umpire" />
   </rule>
    <rule name="Rule6" description="The middle one is final" >
        <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay" />
        <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay" />
        <then method="assay.setFinalAssay" arg1="umpire" />
   </rule>
   
   
</rule-execution-set>', 'Y', 0, 
    'The middle one is final');
COMMIT;
