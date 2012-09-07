alter table eod_eom_phy_contract_journal add (contract_qty  number(15,3),
                cont_qty_unit_id varchar2(15),
               cont_qty_unit    varchar2(20),
               profit_center_id varchar(20),
               profit_center_short_name varchar(35),
               profit_center_name varchar(35),
               del_quota_period   varchar2(50),
               strategy_id  varchar2(15),
               strategy  varchar2(30));
alter table eod_eom_fixation_journal add PRICE_IN_PAY_IN_CURRENCY  number(25,5);
alter table eod_eom_fixation_journal add PAY_IN_CCY_UNIT           varchar2(20);
alter table eod_eom_fixation_journal add PAY_IN_PRICE_UNIT         varchar2(20);
alter table eod_eom_fixation_journal add average_from_date          VARCHAR2(20);
alter table eod_eom_fixation_journal add average_to_date            VARCHAR2(20);