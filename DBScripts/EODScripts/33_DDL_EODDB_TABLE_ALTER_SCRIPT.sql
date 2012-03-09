CREATE TABLE INVME_COG_ELEMENT
(
PROCESS_ID                      VARCHAR2(15 ),
INTERNAL_GRD_REF_NO             VARCHAR2(15 ),
ELEMENT_ID                      VARCHAR2(15 ),
MC_PER_UNIT                     NUMBER(20,8),
MC_PRICE_UNIT_ID                VARCHAR2(15 ),
MC_PRICE_UNIT_NAME              VARCHAR2(15 ),
TC_PER_UNIT                     NUMBER(20,8),
TC_PRICE_UNIT_ID                VARCHAR2(15),
TC_PRICE_UNIT_NAME              VARCHAR2(15),
RC_PER_UNIT                     NUMBER(20,8),
RC_PRICE_UNIT_ID                VARCHAR2(15),
RC_PRICE_UNIT_NAME              VARCHAR2(15));

CREATE TABLE INVME_COGS_ELEMENT
(
PROCESS_ID                      VARCHAR2(15 ),
INTERNAL_GRD_REF_NO             VARCHAR2(15 ),
ELEMENT_ID                      VARCHAR2(15 ),
SALES_INTERNAL_GMR_REF_NO       VARCHAR2(15 ),
MC_PER_UNIT                     NUMBER(20,8),
MC_PRICE_UNIT_ID                VARCHAR2(15 ),
MC_PRICE_UNIT_NAME              VARCHAR2(15 ),
TC_PER_UNIT                     NUMBER(20,8),
TC_PRICE_UNIT_ID                VARCHAR2(15),
TC_PRICE_UNIT_NAME              VARCHAR2(15),
RC_PER_UNIT                     NUMBER(20,8),
RC_PRICE_UNIT_ID                VARCHAR2(15),
RC_PRICE_UNIT_NAME              VARCHAR2(15));


ALTER TABLE PSUE_ELEMENT_DETAILS ADD PRICE_UNIT_NAME VARCHAR2(30);
