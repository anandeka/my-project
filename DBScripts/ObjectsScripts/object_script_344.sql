ALTER TABLE IS_INVOICE_SUMMARY
 ADD (CREATED_BY  VARCHAR2(30 CHAR));

ALTER TABLE IS_INVOICE_SUMMARY
 ADD (CREATED_DATE  TIMESTAMP(6));

ALTER TABLE IS_INVOICE_SUMMARY
 ADD (MODIFIED_BY  VARCHAR2(30 CHAR));

ALTER TABLE IS_INVOICE_SUMMARY
 ADD (MODIFIED_DATE  TIMESTAMP(6));

ALTER TABLE IS_INVOICE_SUMMARY
 ADD (CANCELLED_BY  VARCHAR2(30 CHAR));

ALTER TABLE IS_INVOICE_SUMMARY
 ADD (CANCELLED_DATE  TIMESTAMP(6));





ALTER TABLE IS_UL_INVOICE_SUMMARY_UL
 ADD (CREATED_BY  VARCHAR2(30 CHAR));

ALTER TABLE IS_UL_INVOICE_SUMMARY_UL
 ADD (CREATED_DATE  TIMESTAMP(6));

ALTER TABLE IS_UL_INVOICE_SUMMARY_UL
 ADD (MODIFIED_BY  VARCHAR2(30 CHAR));

ALTER TABLE IS_UL_INVOICE_SUMMARY_UL
 ADD (MODIFIED_DATE  TIMESTAMP(6));

ALTER TABLE IS_UL_INVOICE_SUMMARY_UL
 ADD (CANCELLED_BY  VARCHAR2(30 CHAR));

ALTER TABLE IS_UL_INVOICE_SUMMARY_UL
 ADD (CANCELLED_DATE  TIMESTAMP(6));

ALTER TABLE IS_UL_INVOICE_SUMMARY_UL
 ADD (INTERNAL_ACTION_REF_NO  VARCHAR2(15 CHAR));
