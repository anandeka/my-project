
Insert into acs_approval_config_setup
   (entity_type, approval, isactive, APPROVAL_VALUE)
 Values
   ('Sales', 'Always', 'Y', 'Bypass');
   
   Insert into acs_approval_config_setup
   (entity_type, approval, isactive, APPROVAL_VALUE)
 Values
   ('Sales', 'Always', 'N', 'limit check');
   
   Insert into acs_approval_config_setup
   (entity_type, approval, isactive, APPROVAL_VALUE)
 Values
   ('Sales', 'On Occurence Of', 'N', 'limit breach');
   
     Insert into acs_approval_config_setup
   (entity_type, approval, isactive, APPROVAL_VALUE)
 Values
   ('Sales', 'On Occurence Of', 'N', 'limit not breach');