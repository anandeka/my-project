alter table POCD_PRICE_OPTION_CALLOFF_DTLS add pay_in_price_unit_id  varchar2(30);

alter table ASH_ASSAY_HEADER add is_final_assay_fully_finalized char(1) default 'N';