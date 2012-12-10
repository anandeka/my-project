CREATE INDEX IDX_DIPCH1 ON DIPCH_DI_PAYABLECONTENT_HEADER(PROCESS_ID,IS_ACTIVE,PCDI_ID,PCPCH_ID);

CREATE INDEX IDX_POCH1 ON POCH_PRICE_OPT_CALL_OFF_HEADER (IS_ACTIVE,PCDI_ID);

DROP INDEX IDX_SPQ1;
CREATE INDEX IDX_SPQ1 ON SPQ_STOCK_PAYABLE_QTY(DBD_ID,IS_ACTIVE,IS_STOCK_SPLIT);

DROP INDEX IDX_PCPCH1;
CREATE INDEX IDX_PCPCH1 ON PCPCH_PC_PAYBLE_CONTENT_HEADER (DBD_ID,IS_ACTIVE);

DROP INDEX IDX_PCEPC1;
CREATE INDEX IDX_PCEPC1 ON PCEPC_PC_ELEM_PAYABLE_CONTENT(DBD_ID,IS_ACTIVE);

DROP INDEX IDX_PQD1;
CREATE INDEX IDX_PQD1 ON PQD_PAYABLE_QUALITY_DETAILS(DBD_ID,IS_ACTIVE);

ALTER TABLE ISR_INTRASTAT_GRD DROP (VAT_NO,INTERNAL_GRD_REF_NO,PRICE,PRICE_UNIT_ID,PRICE_UNIT_NAME);

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD LOADING_DATE DATE;
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD NO_OF_CONTAINERS NUMBER(5);
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD(
NO_OF_BAGS                            NUMBER(10),        
NO_OF_SUBLOTS                         NUMBER (10));        

ALTER TABLE TGOC_TEMP_GMR_OTHER_CHARGE ADD SHIPPED_QTY NUMBER(25,10);
ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD( DRY_QTY     NUMBER(35,10));

ALTER TABLE TGI_TEMP_GMR_INVOICE ADD
(INVOICE_CUR_ID                  VARCHAR2(15),
INVOICE_CUR_CODE                  VARCHAR2(15));

ALTER TABLE ISR_INTRASTAT_GRD ADD(
DISCHARGE_COUNTRY_VAT_NO      VARCHAR2(50),
LOADING_COUNTRY_VAT_NO      VARCHAR2(50));

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD
(GMR_TYPE                        VARCHAR2(30),
CONTRACT_REF_NO                  VARCHAR2(30),
CP_ID                            VARCHAR2(15),
CP_NAME                          VARCHAR2(100));

ALTER TABLE PATD_PA_TEMP_DATA ADD(
NO_OF_SUBLOTS                         NUMBER (10),
SHIPPED_QTY                           NUMBER(25,10));    

CREATE OR REPLACE VIEW V_QAT_PPM
AS
select qat.quality_id,
       qav.attribute_text attribute_value
  from qat_quality_attributes         qat,
       qav_quality_attribute_values   qav,
       ppm_product_properties_mapping ppm,
       aml_attribute_master_list      aml
 where ppm.product_id = qat.product_id
   and ppm.attribute_id = aml.attribute_id
   and qat.is_active = 'Y'
   and ppm.is_active = 'Y'
   and aml.is_active = 'Y'
   and qav.is_deleted = 'N'
   and aml.attribute_name = 'CIN'
   and aml.attribute_type_id = 'OTHERS'
   and qat.quality_id = qav.quality_id
   and qav.attribute_id = ppm.property_id;

ALTER TABLE ISR_INTRASTAT_GRD ADD(
DRY_QTY     NUMBER(35,10),
INCOTERM_ID                                VARCHAR2(15),
INCOTERM                                VARCHAR2(20),
FINAL_INVOICE_DATE                        DATE,                
CORPORATE_NAME                            VARCHAR2(100),
INTERNAL_INVOICE_REF_NO                    VARCHAR2(15),
INVOICE_REF_NO                            VARCHAR2(30),
QTY_UNIT                                VARCHAR2(15),
NO_OF_CONTAINERS                        NUMBER(5));


CREATE TABLE ISR1_ISR_INVENTORY(
PROCESS_ID                    VARCHAR2(15 ),
SECTION_NAME                  VARCHAR2(50 ),
CORPORATE_ID                  VARCHAR2(15 ),
ELEMENT_ID                    VARCHAR2(15 ),
CONTRACT_REF_NO               VARCHAR2(15 ),
CONTRACT_REF_NO_DEL_ITEM_NO   VARCHAR2(30 ),
INTERNAL_GMR_REF_NO           VARCHAR2(15 ),
GMR_REF_NO                    VARCHAR2(30 ),
INTERNAL_GRD_REF_NO           VARCHAR2(15 ),
PRODUCT_ID                    VARCHAR2(15 ),
PRODUCT_DESC                  VARCHAR2(100 ),
CP_ID                         VARCHAR2(15 ),
SUPPLIER_NAME                 VARCHAR2(100 ),
INCOTERM_ID                   VARCHAR2(15 ),
INCOTERM                      VARCHAR2(20 ),
QUALITY_ID                    VARCHAR2(15 ),
QUALITY_NAME                  VARCHAR2(100 ),
GRD_QTY                       NUMBER(25,10),
GRD_DRY_QTY                   NUMBER(25,10),
GRD_QTY_UNIT_ID               VARCHAR2(15 ),
CONTRACT_PRICE                NUMBER(25,10),
CONTRACT_PRICE_UNIT_ID        VARCHAR2(15 ),
CONTRACT_PRICE_UNIT_CUR_ID    VARCHAR2(15 ),
CONTRACT_PRICE_UNIT_CUR_CODE  VARCHAR2(15 ),
SHIPMENT_DATE                 DATE,
INVOICE_DATE                  DATE,
LOADING_COUNTRY_ID            VARCHAR2(15 ),
LOADING_COUNTRY_NAME          VARCHAR2(100 ),
LOADING_CITY_ID               VARCHAR2(15 ),
LOADING_CITY_NAME             VARCHAR2(100 ),
LOADING_STATE_ID              VARCHAR2(15 ),
LOADING_STATE_NAME            VARCHAR2(100 ),
LOADING_REGION_ID             VARCHAR2(15 ),
LOADING_REGION                VARCHAR2(100 ),
DISCHARGE_COUNTRY_ID          VARCHAR2(15 ),
DISCHARGE_COUNTRY_NAME        VARCHAR2(100 ),
DISCHARGE_CITY_ID             VARCHAR2(15 ),
DISCHARGE_CITY_NAME           VARCHAR2(100 ),
DISCHARGE_STATE_ID            VARCHAR2(15 ),
DISCHARGE_STATE_NAME          VARCHAR2(100 ),
DISCHARGE_REGION_ID           VARCHAR2(15 ),
DISCHARGE_REGION              VARCHAR2(100 ),
MODE_OF_TRANSPORT             VARCHAR2(15 ),
BL_NO                         VARCHAR2(50 ),
PAYABLE_QTY_UNIT_ID           VARCHAR2(15 ),
PAYABLE_QTY                   NUMBER(25,10),
LOADING_COUNTRY_CUR_ID        VARCHAR2(15 ),
LOADING_COUNTRY_CUR_CODE      VARCHAR2(15 ),
DISCHARGE_COUNTRY_CUR_ID      VARCHAR2(15 ),
DISCHARGE_COUNTRY_CUR_CODE    VARCHAR2(15 ),
BASE_CUR_ID                   VARCHAR2(15 ),
BASE_CUR_CODE                 VARCHAR2(15 ),
PRICE_TO_BASE_EXCH_RATE       NUMBER(25,10),
BASE_TO_LOAD_COUNTRY_EX_RATE  NUMBER(25,10),
BASE_TO_DISC_COUNTRY_EX_RATE  NUMBER(25,10),
PAYABLE_QTY_CONV_FACTOR       NUMBER(25,10),
ATTRIBUTE_VALUE               VARCHAR2(15 ),
CONTRACT_TYPE                 VARCHAR2(15 ),
EXPORT_DATE                   DATE,
IMPORT_DATE                   DATE,
NO_OF_CONTAINERS              NUMBER(5));

CREATE TABLE ISR2_ISR_INVOICE(
PROCESS_ID                            VARCHAR2(15),    
SECTION_NAME                          VARCHAR2(50),
CORPORATE_ID                          VARCHAR2(15),
ELEMENT_ID                            VARCHAR2(15),
CONTRACT_REF_NO                        VARCHAR2(15),
CONTRACT_REF_NO_DEL_ITEM_NO            VARCHAR2(30),    
INTERNAL_GMR_REF_NO                    VARCHAR2(15),
GMR_REF_NO                            VARCHAR2(30),
PRODUCT_ID                            VARCHAR2(15),
PRODUCT_DESC                        VARCHAR2(100),
CP_ID                                VARCHAR2(15),
SUPPLIER_NAME                        VARCHAR2(100),
INCOTERM_ID                          VARCHAR2(15),
INCOTERM                          VARCHAR2(20),
QUALITY_ID                            VARCHAR2(15),
QUALITY_NAME                        VARCHAR2(100),    
GRD_QTY                                NUMBER(25,10),
GRD_DRY_QTY                                NUMBER(25,10),
GRD_QTY_UNIT_ID                        VARCHAR2(15),
SHIPMENT_DATE                        DATE,    
INVOICE_DATE                        DATE,    
LOADING_COUNTRY_ID                    VARCHAR2(15),
LOADING_COUNTRY_NAME                VARCHAR2(100),    
LOADING_CITY_ID                        VARCHAR2(15),
LOADING_CITY_NAME                    VARCHAR2(100),    
LOADING_STATE_ID                    VARCHAR2(15),
LOADING_STATE_NAME                    VARCHAR2(100),    
LOADING_REGION_ID                    VARCHAR2(15),
LOADING_REGION                        VARCHAR2(100),    
DISCHARGE_COUNTRY_ID                VARCHAR2(15),
DISCHARGE_COUNTRY_NAME                VARCHAR2(100),    
DISCHARGE_CITY_ID                    VARCHAR2(15),
DISCHARGE_CITY_NAME                    VARCHAR2(100),    
DISCHARGE_STATE_ID                    VARCHAR2(15),
DISCHARGE_STATE_NAME                VARCHAR2(100),    
DISCHARGE_REGION_ID                    VARCHAR2(15),
DISCHARGE_REGION                    VARCHAR2(100),    
MODE_OF_TRANSPORT                    VARCHAR2(15),
BL_NO                                VARCHAR2(50),
INVOICE_OR_INVENOTRY                VARCHAR2(15),
PRODUCT_PRICE_UNIT_ID                VARCHAR2(15),
UNDERLYING_PRODUCT_ID                VARCHAR2(15),
SPQ_QTY_UNIT_ID                        VARCHAR2(15),
UNDER_PRODUCT_BASE_QTY_UNIT            VARCHAR2(15),
PAYABLE_QTY                            NUMBER(25,10),    
LOADING_COUNTRY_CUR_ID                VARCHAR2(15),
LOADING_COUNTRY_CUR_CODE                VARCHAR2(15),
DISCHAGRE_COUNTRY_CUR_ID            VARCHAR2(15),    
DISCHAGRE_COUNTRY_CUR_CODE                VARCHAR2(15),
BASE_CUR_ID                            VARCHAR2(15),
BASE_CUR_CODE                        VARCHAR2(15),
BASE_TO_LOAD_COUNTRY_EX_RATE        NUMBER(25,10),    
BASE_TO_DISC_COUNTRY_EX_RATE        NUMBER(25,10),
ATTRIBUTE_VALUE                        VARCHAR2(15),            
CONTRACT_TYPE                        VARCHAR2(15),
EXPORT_DATE                            DATE,                
IMPORT_DATE                            DATE,
INVOICE_AMT                            NUMBER(25,10),
INVOICE_CUR_ID                         VARCHAR2(15),
INVOICE_CUR_CODE                         VARCHAR2(15),
INVOICE_TO_BASE_EX_RATE               NUMBER(25,10),
FINAL_INVOICE_DATE                    DATE,
INTERNAL_INVOICE_REF_NO       VARCHAR2(15),
INVOICE_REF_NO                VARCHAR2(30),
NO_OF_CONTAINERS NUMBER(5));

CREATE INDEX IDX_ISR11 ON ISR1_ISR_INVENTORY(PROCESS_ID);
CREATE INDEX IDX_ISR21 ON ISR2_ISR_INVOICE(PROCESS_ID);
ALTER TABLE ISR2_ISR_INVOICE ADD INTERNAL_GRD_REF_NO VARCHAR2(15);
ALTER TABLE TSQ_TEMP_STOCK_QUALITY ADD PCDI_ID VARCHAR2(15);
CREATE INDEX IDX_DIPCH2 ON dipch_di_payablecontent_headeR(DBD_ID,IS_ACTIVE);