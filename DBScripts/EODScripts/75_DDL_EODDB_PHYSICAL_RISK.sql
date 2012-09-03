-- create table
-- Create/Recreate indexes 
create index EEDERJ1 on EOD_EOM_DERIVATIVE_JOURNAL (CORPORATE_ID,PROCESS,PROCESS_ID);
create index EEBJ1 on EOD_EOM_BOOKING_JOURNAL (CORPORATE_ID,PROCESS,PROCESS_ID);


drop table eod_eom_phy_contract_journal;
create table eod_eom_phy_contract_journal
(
  catogery                 varchar2(20),
  book_type                varchar2(20),
  corporate_id             varchar2(20),
  corporate_name           varchar2(20),
  contract_ref_no          varchar2(20),
  del_item_ref_no          varchar2(30),
  internal_contract_ref_no varchar2(30),
  cp_id                    varchar2(20),
  companyname              varchar2(30),
  trader_id                varchar2(20),
  trader                   varchar2(50),
  inco_term_id             varchar2(20),
  inco_term                varchar2(200),
  inco_term_location       varchar2(200),
  issue_date               date,
  product_id               varchar2(20),
  product_desc             varchar2(50),
  element_id               varchar2(20),
  element                  varchar2(40),
  del_item_qty             number(25,5),
  del_item_qty_unit_id     varchar2(20),
  del_item_qty_unit        varchar2(20),
  del_date                 date,
  price_basis              varchar2(20),
  price                    number(25,5),
  price_unit_id            varchar2(20),
  price_unit_name          varchar2(30),
  premium_disc_value       number(20,5),
  premium_disc_unit_id     varchar2(20),
  pd_price_unit_name       varchar2(35),
  eod_eom_date            date,
  process                 varchar2(30),
  process_id              varchar2(10),
  dbd_id                  varchar2(10)
);

create index EEPCJ1 on eod_eom_phy_contract_journal (CORPORATE_ID,PROCESS,PROCESS_ID);

drop table PHYSICAL_RISK_POSITION;
drop table prp_physical_risk_position;
-- Create table
create table prp_physical_risk_position
(
  corporate_id             VARCHAR2(50),
  corporate                VARCHAR2(100),
  cp_id                    VARCHAR2(50),
  counter_party            VARCHAR2(100),
  trade_type               VARCHAR2(15),
  cont_ref_no              VARCHAR2(50),
  int_cont_ref_no          VARCHAR2(15),
  di_item_ref_no           VARCHAR2(100),
  pcdi_id                  VARCHAR2(10),
  int_gmr_ref_no           VARCHAR2(20),
  product_id               VARCHAR2(20),
  product_name             VARCHAR2(200),
  product_type             VARCHAR2(20),
  product_group            VARCHAR2(50),
  element_id               VARCHAR2(20),
  element_name             VARCHAR2(100),
  profit_center_id         VARCHAR2(20),
  profit_center_name       VARCHAR2(100),
  profit_center_short_name VARCHAR2(100),
  del_from_date            VARCHAR2(30),
  del_to_date              VARCHAR2(30),
  del_item_qty             NUMBER(25,4),
  di_qty_unit_id           VARCHAR2(20),
  di_qty_unit              VARCHAR2(50),
  stock_location           VARCHAR2(100),
  duty_status              VARCHAR2(100),
  priced_qty               NUMBER(25,5),
  priced_qty_unit_id       VARCHAR2(20),
  price_qty_unit           VARCHAR2(50),
  di_price                 NUMBER(25,5),
  di_price_unit_id         VARCHAR2(20),
  di_price_unit            VARCHAR2(50),
  contract_premium         NUMBER(25,5),
  contract_premium_unit_id VARCHAR2(20),
  contract_premium_unit    VARCHAR2(50),
  market_price             NUMBER(25,5),
  market_price_unit_id     VARCHAR2(20),
  market_price_unit        VARCHAR2(50),
  market_premium           NUMBER(25,5),
  market_premium_cur_id    VARCHAR2(20),
  market_premium_ccy       VARCHAR2(50),
  total_amount             NUMBER(30,5),
  total_amount_cur_id      VARCHAR2(20),
  total_amount_cur_code    VARCHAR2(50),
  base_cur_id              VARCHAR2(20),
  base_ccy                 VARCHAR2(50),
  fx_rate                  NUMBER(10,4),
  total_in_base_ccy        NUMBER(30,5),
  process_id               VARCHAR2(15),
  process                  VARCHAR2(10)
);

create index EEPRP1 on prp_physical_risk_position (CORPORATE_ID,PROCESS,PROCESS_ID);


--MV_BI_PHYSICAL_RISK_POS_EOD
--MV_BI_PHYSICAL_RISK_POS_EOM
--MV_BI_PHY_CONT_JOURNAL_EOD
--MV_BI_PHY_CONT_JOURNAL_EOM


--UNRELAIZED PNL   --> MV_FACT_DERIVATIVE_UNRELAIZED
--PFJ EOD          --> MV_BI_DER_PHY_PFC_JOURNAL_EOD
--PFJ EOM          --> MV_BI_DER_PHY_PFC_JOURNAL_EOM
--Deri Journal EOD --> MV_BI_DERIVATIVE_JOURNAL_EOD
--DBJ EOD          --> MV_BI_DER_BOOK_JOURNAL_EOD
--DBJ EOM          --> MV_BI_DER_BOOK_JOURNAL_EOM


--Derivative Booking Report Domain --> V_BI_DERIVATIVE_BOOKING
--Physical Booking Report --> V_BI_DER_PHYSICAL_BOOKING
