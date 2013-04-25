CREATE OR REPLACE PROCEDURE PROCESSASSAYCONTENTINPUT IS
 Cursor ASSAY_CONTENT_UPDATE IS Select INTERNAL_GRD_NO,CONT_TYPE,ASH_ID from ACI_ASSAY_CONTENT_UPDATE_INPUT Where IS_DELETED  ='N';
    BEGIN

    FOR cur_record_rows IN ASSAY_CONTENT_UPDATE 
        
    LOOP  


    IF (cur_record_rows.CONT_TYPE ='ASSAY')  THEN
    dbms_output.put_line('Calling updateAssayContent');
    updateAssayContent(cur_record_rows.CONT_TYPE ,NULL , cur_record_rows.ASH_ID );
        UPDATE ACI_ASSAY_CONTENT_UPDATE_INPUT SET  IS_DELETED ='Y'  WHERE ASH_ID = cur_record_rows.ASH_ID;    
    end if;
    IF (cur_record_rows.CONT_TYPE ='GRD')  THEN
        dbms_output.put_line('Calling updateAssayContent');
        updateAssayContent(cur_record_rows.CONT_TYPE ,cur_record_rows.INTERNAL_GRD_NO , NULL );
    UPDATE ACI_ASSAY_CONTENT_UPDATE_INPUT SET  IS_DELETED ='Y'  WHERE INTERNAL_GRD_NO = cur_record_rows.INTERNAL_GRD_NO;
    end if;    

END LOOP;
    delete from ACI_ASSAY_CONTENT_UPDATE_INPUT WHERE  IS_DELETED ='Y' ;
END;
/
