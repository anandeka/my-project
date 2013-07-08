delete from ARF_ACTION_REF_NUMBER_FORMAT arf where ARF.ACTION_KEY_ID = 'DFTPFIRefNo';
delete from ARFM_ACTION_REF_NO_MAPPING arfm where ARFM.ACTION_ID = 'CREATE_DFT_PFI';
delete from ERC_EXTERNAL_REF_NO_CONFIG erc where ERC.EXTERNAL_REF_NO_KEY = 'CREATE_DFT_PFI';
DROP SEQUENCE SEQERC_DFT_LDE;
DROP SEQUENCE SEQERC_DFT_BAT;
DROP SEQUENCE SEQERC_DFT_BLD;
DROP SEQUENCE SEQERC_DFT_BAM;
DROP SEQUENCE SEQ_DFTPFI_BAM;
DROP SEQUENCE SEQ_DFTPFI_BLD;
DROP SEQUENCE SEQ_DFTPFI_BAT;
DROP SEQUENCE SEQ_DFTPFI_LDE;

DROP SEQUENCE SEQARF_DFT_LDE;
DROP SEQUENCE SEQARF_DFT_BLD;
DROP SEQUENCE SEQARF_DFT_BAM;
DROP SEQUENCE SEQARF_DFT_BAT;

declare
vn_sql_stmt VARCHAR2(1000);
vn_last_num NUMBER := 1;
vn_action_id varchar2(30) := 'CREATE_DFT_PFI';
vn_seq_name VARCHAR2(100);
vn_update_query varchar2(1000);
vn_drop_stmt varchar2(1000);
vn_seq_name_arf VARCHAR2(100);
vn_sql_stmt_arf VARCHAR2(1000);

BEGIN
for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 
loop
vn_seq_name := 'SEQERC_DFT_PFI_'||cc.CORPORATE_ID;
vn_seq_name_arf:= 'SEQ_DFT_PFI_'||cc.CORPORATE_ID;
--vn_drop_stmt := 'DROp SEQUENCE '|| vn_seq_name;
--EXECUTE IMMEDIATE vn_drop_stmt;
    vn_sql_stmt :=  'CREATE SEQUENCE ' || vn_seq_name ||  ' INCREMENT BY 1 START WITH ' ||  vn_last_num || ' MINVALUE ' || vn_last_num || ' NOCACHE';
    EXECUTE IMMEDIATE vn_sql_stmt;
   vn_sql_stmt_arf :=  'CREATE SEQUENCE ' || vn_seq_name_arf ||  ' INCREMENT BY 1 START WITH ' ||  vn_last_num || ' MINVALUE ' || vn_last_num || ' NOCACHE';
    EXECUTE IMMEDIATE vn_sql_stmt_arf;
   

    Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX, 
    IS_CONTINUOUS_MIDDLE_NO_REQ, SEQ_NAME)
 Values
   (cc.CORPORATE_ID, 'CREATE_DFT_PFI', 'DFT-PFI-', 0, ' ', 
    'N', 'Dummy');
      
    vn_update_query := 'update erc_external_ref_no_config ERC set erc.seq_name = ' || '''' || vn_seq_name || '''' || ' where CORPORATE_ID = ' || '''' || cc.CORPORATE_ID || '''' || ' AND EXTERNAL_REF_NO_KEY = ' || '''' || vn_action_id || '''';
    EXECUTE IMMEDIATE vn_update_query;
    Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED,SEQ_NAME)
 Values
   ('ARF-DRFI-'||CC.CORPORATE_ID, 'DFTPFIRefNo', CC.CORPORATE_ID, 'DFT-PFI-', 1, 
    0,  '-'||CC.CORPORATE_ID, 1, 'N',vn_seq_name_arf);

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-DRFI-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CREATE_DFT_PFI', 'DFTPFIRefNo', 'N');

 end loop;

end;
/
