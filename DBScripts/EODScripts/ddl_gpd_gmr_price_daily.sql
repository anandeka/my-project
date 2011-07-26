--drop table gpd_gmr_price_daily cascade constraints;
create table gpd_gmr_price_daily
(
  process_id                      varchar2(20),
  corporate_id                    varchar2(15),
  internal_gmr_ref_no             varchar2(15),
  contract_price                  number(25,5),
  price_unit_id                   varchar2(15),
  price_unit_cur_id               varchar2(15),
  price_unit_cur_code             varchar2(15),
  price_unit_weight               number(7,2),
  price_unit_weight_unit_id       varchar2(15),
  price_unit_weight_unit          varchar2(15),
  price_fixation_status           varchar2(20)                    
)
/

--drop index IDX_CIPD_1;
--drop index IDX_GPD_1;
CREATE INDEX IDX_CIPD_1 ON CIPD_CONTRACT_ITEM_PRICE_DAILY (internal_contract_item_ref_no, process_id)
/

CREATE INDEX IDX_GPD_1 ON gpd_gmr_price_daily (internal_gmr_ref_no, process_id)
/