alter table MD_M2M_DAILY add TC_PRICE_UNIT_ID VARCHAR2(15);
alter table MD_M2M_DAILY add RC_PRICE_UNIT_ID VARCHAR2(15);
alter table PCBPHUL_PC_BASE_PRC_HEADER_UL add ELEMENT_ID VARCHAR2(15);
alter table PCBPH_PC_BASE_PRICE_HEADER add ELEMENT_ID  VARCHAR2(15);

Insert into EEM_EKA_EXCEPTION_MASTER
   (EXCEPTION_CODE, EXCEPTION_MODULE, EXCEPTION_DESC, IS_ACTIVE)
 Values
   ('M2M-030', 'Physical M2M', 'Product price unit is not setup for the product', 'Y');
COMMIT;