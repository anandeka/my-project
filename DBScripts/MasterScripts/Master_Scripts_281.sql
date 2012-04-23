set define off;
delete from URM_UMPIRE_RULE_MASTER;
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
    'Rule 9');
Insert into URM_UMPIRE_RULE_MASTER
   (URM_ID, RULE_DESC, RULE_FORMULA, IS_ACTIVE, VERSION, 
    RULE_NAME)
 Values
   ('3', 'Average of Ours, Umpire and counterparty assay.', '<?xml version="1.0" encoding="UTF-8"?>
<rule-execution-set>
   <name>RuleExecutionSet1</name>
   <description>Rule Execution Set</description>

   <synonymn name="assay" class="com.ekaplus.metals.entity.assaymanagement.assayfinalization.UmpireAssay" />

    
    
    <rule name="Rule1" description="Average of Ours, Umpire and counterparty assay" >
        <if leftTerm="2" op="&gt;" rightTerm="1" />
        
        <then method="assay.setFinalAssay" arg1="avg" />
    
   </rule>
   
   
   
</rule-execution-set>', 'Y', 0, 
    'Rule 10');
Insert into URM_UMPIRE_RULE_MASTER
   (URM_ID, RULE_DESC, RULE_FORMULA, IS_ACTIVE, VERSION, 
    RULE_NAME)
 Values
   ('5', 'Should the Umpire assay fall between the result of the other two parties, the arithmatic  mean of the umpire assay and the assay of party which is nearer to the umpire assay shall be taken as final assay.
Should the Umpire assay be the exact mean of exchanged assay or coincides with either,then umpire assay would govern,otherwise the middle assay of 3 shall be accepted as final.', '<?xml version="1.0" encoding="UTF-8"?>
<rule-execution-set>
  <name>RuleExecutionSet1</name>
  <description>Rule Execution Set</description>
  <synonymn name="assay" class="com.ekaplus.metals.entity.assaymanagement.assayfinalization.UmpireAssay"></synonymn>
  <rule name="Rule1" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule2" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule3" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule4" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule5" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule6" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule7" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule8" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule9" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule10" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule11" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule12" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="midpoint"></then>
  </rule>
  <rule name="Rule13" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="midpoint"></then>
  </rule>
</rule-execution-set>', 'Y', 0, 
    'Rule 5');
Insert into URM_UMPIRE_RULE_MASTER
   (URM_ID, RULE_DESC, RULE_FORMULA, IS_ACTIVE, VERSION, 
    RULE_NAME)
 Values
   ('8', 'Should the Umpire assay fall between the result of the other two parties or coincide with either, arithmatic mean of the umpire assay and assay of the party which is nearer to the umpire assay shall be taken as the agreed assay.
Should the Umpire assay fall outside of the exchanged results, the assay of party which is nearer to the umpire assay shall be taken as the agreed assay.
Should the Umpire assay be the exact mean of the exchanged assays then the umpire assay shall be taken as the agreed assay.', '<?xml version="1.0" encoding="UTF-8"?>
<rule-execution-set>
  <name>RuleExecutionSet1</name>
  <description>Rule Execution Set</description>
  <synonymn name="assay" class="com.ekaplus.metals.entity.assaymanagement.assayfinalization.UmpireAssay"></synonymn>
  <rule name="Rule1" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule2" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  
  <rule name="Rule5" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule6" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule7" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule8" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule9" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule10" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule11" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule12" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="nearestassay"></then>
  </rule>
  <rule name="Rule13" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="nearestassay"></then>
  </rule>
</rule-execution-set>', 'Y', 0, 
    'Rule 1');
Insert into URM_UMPIRE_RULE_MASTER
   (URM_ID, RULE_DESC, RULE_FORMULA, IS_ACTIVE, VERSION, 
    RULE_NAME)
 Values
   ('4', 'Should the umpire assay fall between the results of the other two parties the umpire assay shall be considered as final settlement.
Should the umpire assay does not fall between results of other two parties, then the middle of the three assays shall be considered as final settlement.
Should the umpire assay coincides either of other two assays, then the umpire assay shall be considered as final settlement.', '<?xml version="1.0" encoding="UTF-8"?>
<rule-execution-set>
  <name>RuleExecutionSet1</name>
  <description>Rule Execution Set</description>
  <synonymn name="assay" class="com.ekaplus.metals.entity.assaymanagement.assayfinalization.UmpireAssay"></synonymn>
  <rule name="Rule1" description="The Umpire Assay will be final">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule2" description="The Umpire Assay will be final">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule3" description="The Umpire Assay will be final">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule4" description="The Umpire Assay will be final">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule5" description="The Umpire Assay will be final">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule6" description="The Umpire Assay will be final">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule7" description="The middle one will be final">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getCpAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="cp"></then>
  </rule>
  <rule name="Rule8" description="The middle one will be final">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getCpAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="self"></then>
  </rule>
  <rule name="Rule9" description="The middle one will be final">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getCpAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="cp"></then>
  </rule>
  <rule name="Rule10" description="The middle one will be final">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getCpAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="self"></then>
  </rule>
  <rule name="Rule11" description="The Umpire Assay will be final">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
</rule-execution-set>', 'Y', 0, 
    'Rule 4');
Insert into URM_UMPIRE_RULE_MASTER
   (URM_ID, RULE_DESC, RULE_FORMULA, IS_ACTIVE, VERSION, 
    RULE_NAME)
 Values
   ('6', 'Average of the umpire and the nearest assay.', '<?xml version="1.0" encoding="UTF-8"?>
<rule-execution-set>
  <name>RuleExecutionSet1</name>
  <description>Rule Execution Set</description>
  <synonymn name="assay" class="com.ekaplus.metals.entity.assaymanagement.assayfinalization.UmpireAssay"></synonymn>
  <rule name="Rule1" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule2" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule3" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule4" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
</rule-execution-set>', 'Y', 0, 
    'Rule 11');
Insert into URM_UMPIRE_RULE_MASTER
   (URM_ID, RULE_DESC, RULE_FORMULA, IS_ACTIVE, VERSION, 
    RULE_NAME)
 Values
   ('7', 'If Umpire between the results, Umpire and nearest party/2. If Umpire outside, the umpire is final. ', '<?xml version="1.0" encoding="UTF-8"?>
<rule-execution-set>
  <name>RuleExecutionSet1</name>
  <description>Rule Execution Set</description>
  <synonymn name="assay" class="com.ekaplus.metals.entity.assaymanagement.assayfinalization.UmpireAssay"></synonymn>
  <rule name="Rule1" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule2" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule3" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule4" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule5" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule6" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule7" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule8" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule9" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule10" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
</rule-execution-set>', 'Y', 0, 
    'Rule 13');
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
    'Rule 14');
Insert into URM_UMPIRE_RULE_MASTER
   (URM_ID, RULE_DESC, RULE_FORMULA, IS_ACTIVE, VERSION, 
    RULE_NAME)
 Values
   ('9', 'Should the umpire assay fall between the results of the other two parties, the arithmetic mean of umpire assay and assay of the party which is nearer to umpire assay shall be taken as final assay. 

Should the umpire coincide exactly with either party, then the umpire assay shall be accepted by both parties as final assay.

Should the umpire assay fall outside the  results of the other two parties, then average of the assay of the party which is nearest to umpire and umpire assay shall be taken as final assay.

The cost of umpire shall be paid by party whose assay is further from the umpire, except when the umpire assay is the exact mean of the parties'' asssay in which event cost shall be shared equally by both parties.
', '<?xml version="1.0" encoding="UTF-8"?>
<rule-execution-set>
  <name>RuleExecutionSet1</name>
  <description>Rule Execution Set</description>
  <synonymn name="assay" class="com.ekaplus.metals.entity.assaymanagement.assayfinalization.UmpireAssay"></synonymn>
  <rule name="Rule1" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule2" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  
  <rule name="Rule3" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule4" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule5" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule6" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule7" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule8" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getMeanAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule9" description="The arithmatic mean of umpire and its nearest assay">
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="=" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="umpire"></then>
  </rule>
  <rule name="Rule10" description="umpire assay outside the othere two assays">
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&gt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
  <rule name="Rule11" description="umpire assay outside the othere two assays">
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getSelfAssay"></if>
    <if leftTerm="assay.getUmpiringAssay" op="&lt;" rightTerm="assay.getCpAssay"></if>
    <then method="assay.setFinalAssay" arg1="arithmaticmean"></then>
  </rule>
</rule-execution-set>', 'Y', 0, 
    'Rule 15');

