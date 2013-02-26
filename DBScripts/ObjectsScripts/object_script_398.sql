alter table PCBPD_PC_BASE_PRICE_DETAIL add is_hedge_correction_applicable char(1) default 'Y';
alter table PCBPDUL_PC_BASE_PRICE_DTL_UL add is_hedge_correction_applicable char(1) default 'Y';
alter table POCD_PRICE_OPTION_CALLOFF_DTLS  add is_hedge_correction_applicable char(1) default 'Y';

alter table PFD_PRICE_FIXATION_DETAILS add is_exposure char(1)  default 'Y';