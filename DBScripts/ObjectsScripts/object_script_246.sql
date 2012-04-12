create table DGAM_DOC_GEN_ACTION_MAPPING (
dgam_Id varchar2(15) primary key,
internal_Contract_Ref_No varchar2(15),
internal_Action_Ref_No varchar2(15),
internal_Action_Ref_No_DS varchar2(15),
is_Active char(1)
);


CREATE SEQUENCE SEQ_DGAM
  START WITH 61
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;