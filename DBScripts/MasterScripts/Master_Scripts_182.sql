Insert into ACS_APPROVAL_CONFIG_SETUP
   (ACS_ID,ENTITY_TYPE, APPROVAL, ISACTIVE)
 Values
   ('1','Sales', 'Always', 'Y');
   
   Insert into ACS_APPROVAL_CONFIG_SETUP
   (ACS_ID,ENTITY_TYPE, APPROVAL, ISACTIVE)
 Values
   ('2','Sales', 'On Occurence Of', 'N');
   
Insert into aes_approval_event_setup
   (aes_id,acs_id, event_type)
 Values
   ('1','1','Approve');
   
   Insert into aes_approval_event_setup
   (aes_id,acs_id, event_type)
 Values
   ('2','2','Credit breach');
