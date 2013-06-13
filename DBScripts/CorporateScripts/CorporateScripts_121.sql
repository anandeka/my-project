

BEGIN
for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 
loop

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-CC-'||CC.CORPORATE_ID, 'CloseContract', CC.CORPORATE_ID, 'CC-', 1, 
    0,  '-'||CC.CORPORATE_ID, 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-CC-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CLOSE_CONTRACT', 'CloseContract', 'N');

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-CTC-'||CC.CORPORATE_ID, 'CloseTC', CC.CORPORATE_ID, 'CTC-', 1, 
    0,  '-'||CC.CORPORATE_ID, 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-CTC-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CLOSE_TOLLING_CONTRACT', 'CloseTC', 'N');


 end loop;

end;



declare
vn_sql_stmt VARCHAR2(1000);
vn_last_num NUMBER := 1;
vn_action_id varchar2(30) := 'CREATE_TEMPLATE';
vn_seq_name VARCHAR2(100);
vn_update_query varchar2(1000);

begin
for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 
loop

    vn_seq_name := 'SEQ_TEMPLATE_'||cc.CORPORATE_ID;
    vn_sql_stmt :=  'CREATE SEQUENCE ' || vn_seq_name ||  ' INCREMENT BY 1 START WITH ' ||  vn_last_num || ' MINVALUE ' || vn_last_num || ' NOCACHE';
    EXECUTE IMMEDIATE vn_sql_stmt;
    vn_update_query := 'update erc_external_ref_no_config ERC set erc.seq_name = ' || '''' || vn_seq_name || '''' || ' where CORPORATE_ID = ' || '''' || cc.CORPORATE_ID || '''' || ' AND EXTERNAL_REF_NO_KEY = ' || '''' || vn_action_id || '''';
    EXECUTE IMMEDIATE vn_update_query;
end loop;
end;
/
