
SET DEFINE OFF;
declare
begin
 for cc in (select akc.*, rownum
               from ak_corporate akc
              where akc.is_internal_corporate = 'N'
              order by akc.corporate_id)
loop
    dbms_output.put_line(cc.corporate_id);

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   (cc.corporate_id, cc.corporate_id);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('corporateList', cc.corporate_id, 'N', cc.rownum);
  end loop;
commit;
end;




