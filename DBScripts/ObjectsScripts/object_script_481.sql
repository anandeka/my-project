

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD
   ADD (LATEST_INTERNAL_INVOICE_REF_NO VARCHAR2 (25 Char),LATEST_INVOICE_REF_NO VARCHAR2 (30 Char),
       SHIPMENT_DATE VARCHAR2 (21 Char),IS_FI_CREATED CHAR (1 Char),INVOICE_CUR_ID VARCHAR2 (15 Char));
       
ALTER TABLE GMRUL_GMR_UL
   ADD (LATEST_INTERNAL_INVOICE_REF_NO VARCHAR2 (25 Char),LATEST_INVOICE_REF_NO VARCHAR2 (30 Char),
       SHIPMENT_DATE VARCHAR2 (21 Char),IS_FI_CREATED CHAR (15 Char),INVOICE_CUR_ID VARCHAR2 (15 Char));