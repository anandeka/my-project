DROP INDEX IDX_PCDI1;
DROP INDEX IDX_PCDI2;
CREATE INDEX IDX_PCDI1 ON PCDI_PC_DELIVERY_ITEM (DBD_ID,IS_ACTIVE,INTERNAL_CONTRACT_REF_NO);
CREATE INDEX IDX_PCDI2 ON PCDI_PC_DELIVERY_ITEM(PROCESS_ID,IS_ACTIVE,INTERNAL_CONTRACT_REF_NO);
DROP INDEX IDX_PCPD1;
DROP INDEX IDX_PCPD2;
CREATE INDEX IDX_PCPD1 ON PCPD_PC_PRODUCT_DEFINITION (DBD_ID,IS_ACTIVE, INPUT_OUTPUT, INTERNAL_CONTRACT_REF_NO);
CREATE INDEX IDX_PCPD2 ON PCPD_PC_PRODUCT_DEFINITION (PROCESS_ID, IS_ACTIVE, INPUT_OUTPUT, INTERNAL_CONTRACT_REF_NO);
CREATE INDEX IDX_TGI1 ON TEMP_GMR_INVOICE(CORPORATE_ID,STOCK_ID);
CREATE INDEX IDX_PC1 ON PC_PRICE_CONVERSION (FROM_PRICE_UNIT_ID, TO_PRICE_UNIT_ID);
CREATE TABLE CET_CORPORATE_EXCH_RATE
(
  CORPORATE_ID        VARCHAR2(15 CHAR),
  FROM_CUR_ID  VARCHAR2(15 CHAR),
  TO_CUR_ID    VARCHAR2(15 CHAR),
  EXCH_RATE         NUMBER);
CREATE INDEX IDX_CET1 ON CET_CORPORATE_EXCH_RATE (FROM_CUR_ID, TO_CUR_ID);
CREATE INDEX IDX_IID1 ON IID_INVOICABLE_ITEM_DETAILS(INTERNAL_INVOICE_REF_NO,INTERNAL_GMR_REF_NO); -- go to mv indexes
CREATE INDEX IDX_CCCP1 ON CCCP_CONC_CONTRACT_COG_PRICE(PROCESS_ID,PCDI_ID,ELEMENT_ID);
DROP INDEX IDX_SPQ;
CREATE INDEX IDX_SPQ2 ON SPQ_STOCK_PAYABLE_QTY(PROCESS_ID,IS_ACTIVE,IS_STOCK_SPLIT,INTERNAL_GRD_REF_NO,ELEMENT_ID);
DROP INDEX IDX_PCI2;
CREATE INDEX IDX_PCI2 ON PCI_PHYSICAL_CONTRACT_ITEM(PROCESS_ID,IS_ACTIVE,PCDI_ID,Internal_Contract_Item_Ref_No);
DROP INDEX IDX_PCPCH;
CREATE INDEX IDX_PCPCH2 ON PCPCH_PC_PAYBLE_CONTENT_HEADER (PROCESS_ID,IS_ACTIVE);
CREATE INDEX IDX_II1 ON II_INVOICABLE_ITEM(STOCK_ID,INTERNAL_GMR_REF_NO);
DROP INDEX IDX_PCM2;
CREATE INDEX IDX_PCM2 ON PCM_PHYSICAL_CONTRACT_MAIN(PROCESS_ID,CONTRACT_STATUS,PRODUCT_GROUP_TYPE);
DROP INDEX IDX_PCDI2;
CREATE INDEX IDX_PCDI2 ON PCDI_PC_DELIVERY_ITEM (PROCESS_ID, IS_ACTIVE, PRICE_OPTION_CALL_OFF_STATUS, PCDI_ID);
CREATE INDEX IDX_POCH1 ON POCH_PRICE_OPT_CALL_OFF_HEADER(IS_ACTIVE, POCH_ID,PCDI_ID,ELEMENT_ID);
CREATE INDEX IDX_POCD1 ON POCD_PRICE_OPTION_CALLOFF_DTLS(IS_ACTIVE,POCH_ID,ELEMENT_ID);
DROP INDEX IDX_PPFH;
CREATE INDEX IDX_PPFH ON PPFH_PHY_PRICE_FORMULA_HEADER(PROCESS_ID,IS_ACTIVE,PPFH_ID,PCBPD_ID);
DROP INDEX IDX_PPFD;
CREATE INDEX IDX_PPFD2 ON PPFD_PHY_PRICE_FORMULA_DETAILS(PROCESS_ID,IS_ACTIVE,PPFH_ID,Instrument_Id);
DROP INDEX IDX_PCBPD;
CREATE INDEX IDX_PCBPD2 ON PCBPD_PC_BASE_PRICE_DETAIL(PROCESS_ID,IS_ACTIVE,PCBPH_ID,ELEMENT_ID,PCBPD_ID);
DROP INDEX IDX_PCIPF;
CREATE INDEX IDX_PCIPF2 ON PCIPF_PCI_PRICING_FORMULA(PROCESS_ID,IS_ACTIVE,PCBPH_ID,INTERNAL_CONTRACT_ITEM_REF_NO);
DROP INDEX IDX_DIPQ;
CREATE INDEX IDX_DIPQ2 ON DIPQ_DELIVERY_ITEM_PAYABLE_QTY(PROCESS_ID,IS_ACTIVE,PRICE_OPTION_CALL_OFF_STATUS,PCDI_ID);
DROP INDEX IDX_PCBPH;
CREATE INDEX IDX_PCBPH2 ON PCBPH_PC_BASE_PRICE_HEADER (PROCESS_ID,IS_ACTIVE,Internal_Contract_Ref_No,Pcbph_Id);
CREATE TABLE CED_CONTRACT_EXCHANGE_DETAIL
(
  CORPORATE_ID                   VARCHAR2(15) NOT NULL,
  INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(15) NOT NULL,
  PCDI_ID                        VARCHAR2(15) NOT NULL,
  ELEMENT_ID                     VARCHAR2(15),
  INSTRUMENT_ID                  VARCHAR2(15),
  INSTRUMENT_NAME                VARCHAR2(50),
  DERIVATIVE_DEF_ID              VARCHAR2(15),
  DERIVATIVE_DEF_NAME            VARCHAR2(50),
  EXCHANGE_ID                    VARCHAR2(15),
  EXCHANGE_NAME                  VARCHAR2(200));
CREATE INDEX IDX_CED1 ON CED_CONTRACT_EXCHANGE_DETAIL(CORPORATE_ID);
CREATE INDEX IDX_CED2 ON CED_CONTRACT_EXCHANGE_DETAIL(INTERNAL_CONTRACT_ITEM_REF_NO,INSTRUMENT_ID);
CREATE TABLE CPQ_CONTRACT_PAYABLE_QTY
(CORPORATE_ID VARCHAR2(15),
INTERNAL_CONTRACT_ITEM_REF_NO VARCHAR2(15),
ELEMENT_ID  VARCHAR2(15),
PAYABLE_QTY NUMBER,
PAYABLE_QTY_UNIT_ID  VARCHAR2(15));
DROP INDEX IDX_CIPQ;
CREATE INDEX IDX_CIPQ2 ON CIPQ_CONTRACT_ITEM_PAYABLE_QTY (PROCESS_ID,IS_ACTIVE,INTERNAL_CONTRACT_ITEM_REF_NO,ELEMENT_ID);
DROP INDEX IDX_PFQPP;
CREATE INDEX IDX_PFQPP2 ON PFQPP_PHY_FORMULA_QP_PRICING(PROCESS_ID,IS_ACTIVE,PPFH_ID);
CREATE INDEX IDX_CEQS1 ON CEQS_CONTRACT_ELE_QTY_STATUS(PROCESS_ID,INTERNAL_CONTRACT_ITEM_REF_NO,ELEMENT_ID);
CREATE TABLE GED_GMR_EXCHANGE_DETAIL
(CORPORATE_ID               VARCHAR2(15),
INTERNAL_GMR_REF_NO         VARCHAR2(15),
INSTRUMENT_ID               VARCHAR2(15),
INSTRUMENT_NAME             VARCHAR2(100),
DERIVATIVE_DEF_ID           VARCHAR2(15),
DERIVATIVE_DEF_NAME         VARCHAR2(100),
EXCHANGE_ID                 VARCHAR2(15),
EXCHANGE_NAME               VARCHAR2(100),
ELEMENT_ID                  VARCHAR2(15));
CREATE INDEX IDX_GED1 ON GED_GMR_EXCHANGE_DETAIL (CORPORATE_ID,INTERNAL_GMR_REF_NO,INSTRUMENT_ID);