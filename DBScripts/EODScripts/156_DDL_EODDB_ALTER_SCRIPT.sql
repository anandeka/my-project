ALTER TABLE PCIUL_PHY_CONTRACT_ITEM_UL ADD ITEM_STATUS VARCHAR2(15);
ALTER TABLE PCI_PHYSICAL_CONTRACT_ITEM ADD ITEM_STATUS VARCHAR2(15);

update pciul_phy_contract_item_ul pciul_eod
   set pciul_eod.item_status = (select pciul_app.item_status
                                  from pciul_phy_contract_item_ul@eka_appdb pciul_app
                                 where pciul_app.pciul_id =
                                       pciul_eod.pciul_id);

commit;

DROP INDEX IDX_DIPQ1;
CREATE INDEX IDX_DIPQ1 ON DIPQ_DELIVERY_ITEM_PAYABLE_QTY (DBD_ID, IS_ACTIVE, PRICE_OPTION_CALL_OFF_STATUS);

CREATE TABLE CEC_CONTRACT_EXCHANGE_CHILD(
CORPORATE_ID                   VARCHAR2(15),
INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(15),
ELEMENT_ID                     VARCHAR2(15),
INSTRUMENT_ID                  VARCHAR2(15),
PCDI_ID                        VARCHAR2(15));

CREATE INDEX IDX_CEC1 ON CEC_CONTRACT_EXCHANGE_CHILD(CORPORATE_ID);

ALTER TABLE GEPC_GMR_ELEMENT_PC_CHARGES ADD ASSAY_QTY_UNIT_ID VARCHAR2(15);

--DROP TABLE PED_PENALTY_ELEMENT_DETAILS;
