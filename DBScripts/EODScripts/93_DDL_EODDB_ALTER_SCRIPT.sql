ALTER TABLE PCDI_PC_DELIVERY_ITEM ADD (SHIPMENT_DATE DATE);
ALTER TABLE PCDI_PC_DELIVERY_ITEM ADD (ARRIVAL_DATE DATE);
ALTER TABLE PCDI_PC_DELIVERY_ITEM ADD (QP_START_DATE DATE);
ALTER TABLE PCDI_PC_DELIVERY_ITEM ADD (QP_END_DATE DATE);

-- Create table--
create table TEMP_TPR
(
  CORPORATE_ID         VARCHAR2(15),
  group_name           VARCHAR2(50),
  section_name         VARCHAR2(100),
  section_id           VARCHAR2(15),
  product_id           VARCHAR2(50),
  product_desc         VARCHAR2(200),
  profit_center_id     VARCHAR2(15),
  profit_center_short_name VARCHAR2(100),
  profit_center_name       VARCHAR2(100),
  delivery_date            DATE,
  delivery_month_display   VARCHAR2(50),
  quantity                 NUMBER(35,5),
  quantity_unit_id         VARCHAR2(15),
  quantity_unit            VARCHAR2(15),
  strategy_id              VARCHAR2(50 ),
  strategy_name            varchar2(200),
  approval_status          varchar2(50)
);
-- Create/Recreate indexes 
create index IDX_TPR1 on TEMP_TPR (CORPORATE_ID);
create index IDX_TPR2 on TEMP_TPR (CORPORATE_ID,section_name);


-- Create table
create table TPR_TRADERS_POSITION_REPORT
(
  CORPORATE_ID         VARCHAR2(15),
  PROCESS_ID		VARCHAR2(20),
  PROCESS		VARCHAR2(10),
  EOD_DATE		DATE,
  CORPORATE_NAME	VARCHAR2(100),	
  group_name           VARCHAR2(50),
  section_name         VARCHAR2(100),
  section_id           VARCHAR2(15),
  product_id           VARCHAR2(50),
  product_desc         VARCHAR2(200),
  profit_center_id     VARCHAR2(15),
  profit_center_short_name VARCHAR2(100),
  profit_center_name       VARCHAR2(100),
  delivery_date            DATE,
  delivery_month_display   VARCHAR2(50),
  quantity                 NUMBER(35,5),
  quantity_unit_id         VARCHAR2(15),
  quantity_unit            VARCHAR2(15),
  strategy_id              VARCHAR2(50 ),
  strategy_name            varchar2(200),
  approval_status          varchar2(50)
);
-- Create/Recreate indexes 
create index IDX_TPR_M1 on TPR_TRADERS_POSITION_REPORT (PROCESS_ID);
create index IDX_TPR_M2 on TPR_TRADERS_POSITION_REPORT (CORPORATE_ID,EOD_DATE,PROCESS);