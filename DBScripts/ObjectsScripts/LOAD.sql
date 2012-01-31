CREATE OR REPLACE PROCEDURE LOAD
(
    p_corporate IN ak_corporate_logo.corporate_id%TYPE,
    p_name      IN ak_corporate_logo.file_name%TYPE,
    p_header    IN ak_corporate_logo.headeraddress%TYPE,
    p_footer    IN ak_corporate_logo.footeraddress%TYPE
) IS
    v_bfile      BFILE;
    v_blob       BLOB;
BEGIN
    INSERT INTO ak_corporate_logo
        (corporate_id,
         file_name,
         headeraddress,
         footeraddress,
         corporate_image)
    VALUES
        (p_corporate,
         p_name,
         p_header,
         p_footer,
         empty_blob()) RETURN corporate_image INTO v_blob;
    v_bfile := bfilename('EXAMPLE',
                         p_name);
    dbms_lob.fileopen(v_bfile,
                      dbms_lob.file_readonly);
    dbms_lob.loadfromfile(v_blob,
                          v_bfile,
                          dbms_lob.getlength(v_bfile));
    dbms_lob.fileclose(v_bfile);   
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END; 
/
