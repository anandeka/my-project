ALTER TABLE PFD_PRICE_FIXATION_DETAILS ADD AllOCATED_QTY NUMBER(25,10);

CREATE TABLE GPAD_GMR_PRICE_ALLOC_DTLS
    (
      GPAD_ID              VARCHAR2(15 CHAR),
      GPAH_ID              VARCHAR2(15 CHAR),
      PFD_ID               VARCHAR2(15 CHAR),
      ALLOCATED_QTY           NUMBER(25,10),
      VERSION              NUMBER(10),
      IS_ACTIVE            CHAR(1 CHAR)
      
    );



    

        CREATE TABLE GPAH_GMR_PRICE_ALLOC_HEADER
        (
          GPAH_ID                   VARCHAR2(15 CHAR),
          INTERNAL_GMR_REF_NO      VARCHAR2(15 CHAR),
          ELEMENT_ID              VARCHAR2(15 CHAR),
          TOTAL_QTY_TO_BE_ALLOCATED            NUMBER(25,10),
          TOTAL_QTY_ALLOCATED_QTY           NUMBER(25,10),
          FINAL_PRICE        NUMBER(25,10),
          FINALIZE_DATE     DATE,
          AVG_PRICE_IN_PRICE_CURRENCY   NUMBER(25,10),
          AVG_FX  NUMBER(25,10),
          QTY_UNIT_ID     VARCHAR2(15 CHAR),
          POCD_ID            VARCHAR2(15 CHAR),
          IS_ACTIVE            CHAR(1 CHAR),
         VERSION             NUMBER(25,10)
         
        );


ALTER TABLE GPAH_GMR_PRICE_ALLOC_HEADER ADD (
  CONSTRAINT GPAH 
 PRIMARY KEY
 (GPAH_ID));



CREATE INDEX IDX_FK_GPAD_PFD_ID ON GPAD_GMR_PRICE_ALLOC_DTLS
(PFD_ID);
ALTER TABLE GPAD_GMR_PRICE_ALLOC_DTLS ADD (
  CONSTRAINT FK_GPAD_PFD_ID_ID 
 FOREIGN KEY (PFD_ID) 
 REFERENCES PFD_PRICE_FIXATION_DETAILS (PFD_ID));



CREATE INDEX IDX_FK_GPAD_GPAH_ID ON GPAD_GMR_PRICE_ALLOC_DTLS
(GPAH_ID);

ALTER TABLE GPAD_GMR_PRICE_ALLOC_DTLS ADD (
  CONSTRAINT FK_GPAD_GPAH_ID 
 FOREIGN KEY (GPAH_ID) 
 REFERENCES GPAH_GMR_PRICE_ALLOC_HEADER (GPAH_ID));


CREATE INDEX IDX_FK_GPAH_POCD_ID ON GPAH_GMR_PRICE_ALLOC_HEADER
(POCD_ID);
ALTER TABLE GPAH_GMR_PRICE_ALLOC_HEADER ADD (
  CONSTRAINT FK_GPAD_POCD_ID 
 FOREIGN KEY (POCD_ID) 
 REFERENCES POCD_PRICE_OPTION_CALLOFF_DTLS (POCD_ID));

CREATE INDEX IDX_FK_GPAH_IGMR_NO ON GPAH_GMR_PRICE_ALLOC_HEADER
(INTERNAL_GMR_REF_NO);

ALTER TABLE GPAH_GMR_PRICE_ALLOC_HEADER ADD (
  CONSTRAINT FK_GPAH_IGMR_NO  
 FOREIGN KEY (INTERNAL_GMR_REF_NO) 
 REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO));



CREATE SEQUENCE SEQ_GPAD
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

CREATE SEQUENCE SEQ_GPAH
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;




ALTER TABLE GPAD_GMR_PRICE_ALLOC_DTLS ADD (
  CONSTRAINT GPAD 
 PRIMARY KEY
 (GPAD_ID));