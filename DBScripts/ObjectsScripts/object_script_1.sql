alter table POCH_PRICE_OPT_CALL_OFF_HEADER  add element_id varchar2(15);
alter table PCI_PHYSICAL_CONTRACT_ITEM add expected_qp_start_date date;
alter table PCI_PHYSICAL_CONTRACT_ITEM add expected_qp_end_date date;

alter table PCIUL_PHY_CONTRACT_ITEM_UL add expected_qp_start_date varchar2(30);
alter table PCIUL_PHY_CONTRACT_ITEM_UL add expected_qp_end_date varchar2(30);
