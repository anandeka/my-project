alter table ASH_ASSAY_HEADER add(CONSOLIDATED_GROUP_ID varchar2(15));

alter table AS_ASSAY_D add(CONSOLIDATED_GROUP_ID VARCHAR2 (15 Char));


CREATE SEQUENCE SEQ_CONGRP
  START WITH 8181
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;
