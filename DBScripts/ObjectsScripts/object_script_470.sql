 
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD
   ADD (INVOICE_REF_NO VARCHAR2 (30 Char),
       INVOICE_ISSUE_DATE VARCHAR2 (21 Char));



ALTER TABLE GMRUL_GMR_UL
   ADD (invoice_ref_no VARCHAR2 (30 CHAR),
       invoice_issue_date VARCHAR2 (21 CHAR));