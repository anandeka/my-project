delete from URM_UMPIRE_RULE_MASTER urm where URM.URM_ID = '1';


SET DEFINE OFF;
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
   <rule name="Rule7" description="The middle one is final" >
        <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
        <if leftTerm="assay.getCpAssay" op="&gt;" rightTerm="assay.getSelfAssay" />
        <then method="assay.setFinalAssay" arg1="umpire" />
   </rule>
   <rule name="Rule8" description="The middle one is final" >
        <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
        <if leftTerm="assay.getCpAssay" op="&lt;" rightTerm="assay.getSelfAssay" />
        <then method="assay.setFinalAssay" arg1="umpire" />
   </rule>
   <rule name="Rule9" description="The middle one is final" >
        <if leftTerm="assay.getSelfAssay" op="=" rightTerm="assay.getCpAssay"></if>
        <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay" />
        <then method="assay.setFinalAssay" arg1="self" />
   </rule>
   <rule name="Rule10" description="The middle one is final" >
        <if leftTerm="assay.getSelfAssay" op="=" rightTerm="assay.getCpAssay"></if>
        <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay" />
        <then method="assay.setFinalAssay" arg1="self" />
   </rule>
   <rule name="Rule11" description="The middle one is final" >
        <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
        <if leftTerm="assay.getSelfAssay" op="&lt;" rightTerm="assay.getCpAssay" />
        <then method="assay.setFinalAssay" arg1="umpire" />
   </rule>
   <rule name="Rule12" description="The middle one is final" >
        <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
        <if leftTerm="assay.getSelfAssay" op="&gt;" rightTerm="assay.getCpAssay" />
        <then method="assay.setFinalAssay" arg1="umpire" />
   </rule>
   <rule name="Rule13" description="The middle one is final" >
        <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
        <if leftTerm="assay.getSelfAssay" op="=" rightTerm="assay.getCpAssay"></if>
        <then method="assay.setFinalAssay" arg1="umpire" />
   </rule>
   
</rule-execution-set>', 'Y', 0, 
    'The middle one is final');