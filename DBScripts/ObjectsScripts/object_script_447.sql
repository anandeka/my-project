ALTER TABLE PCI_PHYSICAL_CONTRACT_ITEM
 ADD (CI_EFFECTIVE_DATE  DATE);

ALTER TABLE PCIUL_PHY_CONTRACT_ITEM_UL
 ADD (CI_EFFECTIVE_DATE  VARCHAR2 (15 Char));

ALTER TABLE PCDI_PC_DELIVERY_ITEM
 ADD (DI_EFFECTIVE_DATE  DATE);

ALTER TABLE PCDIUL_PC_DELIVERY_ITEM_UL
 ADD (DI_EFFECTIVE_DATE  VARCHAR2 (15 Char));