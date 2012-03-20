SET DEFINE OFF;

Insert into ETS_EVENT_TYPE_SETUP
   (EVENT_TYPE_ID, EVENT_NAME, EVENT_TYPE, EVENT_MESSAGE, EVENT_QUERY, 
    QUERY_PARAMS, EMAIL_SUBJECT, NOTIFY_SUBJECT, SUBJECT_KEY, ACTION_URL, 
    ACTION_PARAMS, ACTION_NAME, IS_ACTIVE)
 Values
   ('ETS-PHY-4', 'Amend Contract', 'Reminder', 'After Contract Amended', 'select distinct(PCM.CONTRACT_REF_NO) AS entity_name,PCM.CONTRACT_TYPE attribute_1
from PCM_PHYSICAL_CONTRACT_MAIN pcm,
PAR_PHYSICAL_AMEND_REASON par
where PCM.INTERNAL_CONTRACT_REF_NO = PAR.INTERNAL_CONTRACT_REF_NO
and PAR.AMENDMENT_TYPE = ''Amend''
and PAR.IS_ACTIVE = ''Y''
and PCM.IS_ACTIVE = ''Y''
order by entity_name', 
    'CORPID#DAYS', 'Amended Contract Ref No #KEY#', 'Amended Contract Ref No #KEY#', 'ENTITY_NAME', '/metals/loadListOfContracts.action?gridId=PHY_LOC', 
    'ATTRIBUTE_1', 'Amended Contract ', 'Y');

