ALTER TABLE PCDB_PC_DELIVERY_BASIS
 ADD (PFFXD_ID  VARCHAR2(15 CHAR));

ALTER TABLE PCDB_PC_DELIVERY_BASIS
 ADD (FX_RATE_TYPE  VARCHAR2(15 CHAR));

ALTER TABLE PCDB_PC_DELIVERY_BASIS
 ADD (FIXED_FX_RATE  NUMBER(25,10));

ALTER TABLE PCDBUL_PC_DELIVERY_BASIS_UL
 ADD (PFFXD_ID  VARCHAR2(15 CHAR));

ALTER TABLE PCDBUL_PC_DELIVERY_BASIS_UL
 ADD (FX_RATE_TYPE  VARCHAR2(15 CHAR));

ALTER TABLE PCDBUL_PC_DELIVERY_BASIS_UL
 ADD (FIXED_FX_RATE  VARCHAR2(30 CHAR));