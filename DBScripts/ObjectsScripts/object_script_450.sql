ALTER TABLE PCM_PHYSICAL_CONTRACT_MAIN
 ADD (ORDER_NO  VARCHAR2(50 CHAR));

ALTER TABLE PCMUL_PHY_CONTRACT_MAIN_UL 
 ADD (ORDER_NO  VARCHAR2(50 CHAR));
 
ALTER TABLE PCDI_PC_DELIVERY_ITEM 
 ADD (ORDER_LINE_NO  VARCHAR2(50 CHAR));
 
ALTER TABLE PCDIUL_PC_DELIVERY_ITEM_UL 
 ADD (ORDER_LINE_NO  VARCHAR2(50 CHAR));