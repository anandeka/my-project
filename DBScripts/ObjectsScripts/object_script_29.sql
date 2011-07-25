alter table PCM_PHYSICAL_CONTRACT_MAIN add is_tolling_contract char(1) default 'N';

alter table PCPD_PC_PRODUCT_DEFINITION drop constraint FK_PCPD_TOL_QTY_UNIT_ID;

