ALTER TABLE SDD_D ADD (ISSUER VARCHAR2 (100));
ALTER TABLE SDD_D ADD (ISSUER_REF_NO VARCHAR2 (100));
ALTER TABLE SDD_D ADD (ISSUER_ADDRESS VARCHAR2 (3000));


ALTER TABLE SDD_D ADD (CONSIGNEE VARCHAR2 (100));
ALTER TABLE SDD_D ADD (CONSIGNEE_REF_NO VARCHAR2 (100));
ALTER TABLE SDD_D ADD (CONSIGNEE_ADDRESS VARCHAR2 (3000));

ALTER TABLE SDD_D ADD (WAREHOUSE_AND_SHED VARCHAR2 (100));
ALTER TABLE SDD_D ADD (WAREHOUSE_ADDRESS VARCHAR2 (3000));