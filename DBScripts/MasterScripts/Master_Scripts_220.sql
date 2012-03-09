
update axm_action_master
   set action_name = 'Capture Yield',ACTION_DESC = 'Capture Yield'
 where action_id = 'CREATE_FREE_MATERIAL';

update axm_action_master
   set action_name = 'Cancel Capture Yield',ACTION_DESC = 'Cancel Capture Yield'
 where action_id = 'FREE_MATERIAL_CANCEL';

update axm_action_master
   set action_name = 'Return Material',ACTION_DESC = 'Return Material'
 where action_id = 'CREATE_RETURN_MATERIAL';

update axm_action_master
   set action_name = 'Cancel Return Material',ACTION_DESC = 'Cancel Return Material'
 where action_id = 'RETURN_MATERIAL_CANCEL';