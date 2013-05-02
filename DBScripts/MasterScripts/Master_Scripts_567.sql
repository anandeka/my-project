Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (922, 'MODIFY_PC', 'ourPersonInCharge', 'Our Person In Charge', 302);

update AXED_ACTION_ENTITY_DETAILS set field_name='trader' where id='925' and action_id='MODIFY_PC';

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (923, 'MODIFY_PC', 'cp', 'CP Name', 1103);
