
alter table PCBPH_PC_BASE_PRICE_HEADER add is_free_metal_applicable CHAR(1 CHAR) default 'N';

alter table PCAR_PC_ASSAYING_RULES add quality_id varchar2(15);

alter table PCPD_PC_PRODUCT_DEFINITION add input_output varchar2(15) default 'Input';

alter table PCM_PHYSICAL_CONTRACT_MAIN add is_lot_level_invoice CHAR(1 CHAR) default 'N';

alter table CIPQ_CONTRACT_ITEM_PAYABLE_QTY add qty_type varchar2(30) default 'Payable';

alter table DIPQ_DELIVERY_ITEM_PAYABLE_QTY add qty_type varchar2(30) default 'Payable';

alter table PCPCH_PC_PAYBLE_CONTENT_HEADER add PAYABLE_TYPE varchar2(15) default 'Payable';

alter table POCH_PRICE_OPT_CALL_OFF_HEADER add IS_FREE_METAL_PRICING CHAR(1 CHAR) default 'N';

ALTER TABLE PQCA_PQ_CHEMICAL_ATTRIBUTES MODIFY(IS_RETURNABLE CHAR(1 CHAR));