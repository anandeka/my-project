ALTER TABLE PCPDUL_PC_PRODUCT_DEFINTN_UL modify PROFIT_CENTER_ID  NULL;
ALTER TABLE PCPDUL_PC_PRODUCT_DEFINTN_UL modify QTY_UNIT_ID  NULL;
ALTER TABLE PCPDUL_PC_PRODUCT_DEFINTN_UL modify STRATEGY_ID  NULL;

alter table PCMTE_PCM_TOLLING_EXT add tolling_service_type varchar2(10) ;