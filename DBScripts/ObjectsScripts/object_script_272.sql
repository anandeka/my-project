--------------------------------------------------------------------
-- SALES SIDE CHILD TABLE FOR STOCK
--------------------------------------------------------------------

CREATE TABLE SADC_CHILD_DGRD_D
(
  INTERNAL_GMR_REF_NO            VARCHAR2(30),
  INTERNAL_DGRD_REF_NO           VARCHAR2(15),
  INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(15),
  INTERNAL_DOC_REF_NO            VARCHAR2(30),
  STOCK_REF_NO                   VARCHAR2(100),
  NET_WEIGHT                     NUMBER(25,10),
  TARE_WEIGHT                    NUMBER(25,10),
  GROSS_WEIGHT                   NUMBER(25,10),
  P_SHIPPED_NET_WEIGHT           NUMBER(25,10),
  P_SHIPPED_GROSS_WEIGHT         NUMBER(25,10),
  P_SHIPPED_TARE_WEIGHT          NUMBER(25,10),
  LANDED_NET_QTY                 NUMBER(25,10),
  LANDED_GROSS_QTY               NUMBER(25,10),
  CURRENT_QTY                    NUMBER (25,10),
  NET_WEIGHT_UNIT                VARCHAR2(15),
  NET_WEIGHT_UNIT_ID             VARCHAR2(15),
  CONTAINER_NO                   VARCHAR2(100),
  CONTAINER_SIZE                 VARCHAR2(50),
  NO_OF_BAGS                     NUMBER(9),   
  NO_OF_CONTAINERS               NUMBER(9),   
  NO_OF_PIECES                   NUMBER(9),
  BRAND                          VARCHAR2(50),   
  MARK_NO                        VARCHAR2(50),   
  SEAL_NO                        VARCHAR2(50),   
  CUSTOMER_SEAL_NO               VARCHAR2(50), 
  STOCK_STATUS                   VARCHAR2(50),
  REMARKS                        VARCHAR2(3000)  
)

--------------------------------------------------------------------
-- PURCHSE SIDE CHILD TABLE FOR STOCK
--------------------------------------------------------------------


CREATE TABLE SDDC_CHILD_GRD_D
(
  INTERNAL_GMR_REF_NO            VARCHAR2(30),
  INTERNAL_GRD_REF_NO            VARCHAR2(15),
  INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(15),
  INTERNAL_DOC_REF_NO            VARCHAR2(30),
  STOCK_REF_NO                   VARCHAR2(100),
  NET_WEIGHT                     NUMBER(25,10),
  TARE_WEIGHT                    NUMBER(25,10),
  GROSS_WEIGHT                   NUMBER(25,10),
  LANDED_NET_QTY                 NUMBER(25,10),
  LANDED_GROSS_QTY               NUMBER(25,10),
  CURRENT_QTY                    NUMBER (25,10),
  QTY_UNIT                       VARCHAR2(15),
  QTY_UNIT_ID                    VARCHAR2(15),
  CONTAINER_NO                   VARCHAR2(100),
  CONTAINER_SIZE                 VARCHAR2(50),
  NO_OF_BAGS                     NUMBER(9),   
  NO_OF_CONTAINERS               NUMBER(9),   
  NO_OF_PIECES                   NUMBER(9),
  BRAND                          VARCHAR2(50),   
  MARK_NO                        VARCHAR2(50), 
  SEAL_NO                        VARCHAR2(50),   
  CUSTOMER_SEAL_NO               VARCHAR2(50),     
  STOCK_STATUS                   VARCHAR2(50),
  REMARKS                        VARCHAR2(3000)  
)