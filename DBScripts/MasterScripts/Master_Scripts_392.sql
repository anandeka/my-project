SET DEFINE OFF;
Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (324, 'select COMPANYNAME from PHD_PROFILEHEADERDETAILS where PROFILEID=?');
Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (325, 'SELECT gab.firstname||'' ''||gab.lastname FROM PHD_PROFILEHEADERDETAILS phd,gab_globaladdressbook gab WHERE phd.PROFILEID = gab.PROFILEID AND phd.PROFILEID = ?');
COMMIT;
