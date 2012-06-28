
SET define off;
--770
CREATE TABLE PQCAPDUL_PR_QLTY_CHEPAY_DTL_UL
(
  PQCAPDUL_ID             VARCHAR2(15)         NOT NULL,
  PQCAPD_ID               VARCHAR2(15)         NOT NULL,
  PQCA_ID                 VARCHAR2(15)         NOT NULL,
  PCDI_ID                 VARCHAR2(15),
  PAYABLE_RULE_ID         VARCHAR2(15)         NOT NULL,
  PAYABLE_PERCENTAGE      NUMBER(25,10),
  INTERNAL_ACTION_REF_NO  VARCHAR2(30)         NOT NULL,
  IS_ACTIVE               CHAR(1)              DEFAULT 'N'  NOT NULL,
  IS_RETURNABLE           CHAR(1)              DEFAULT 'N',
  VERSION                 NUMBER(10)           NOT NULL
);

CREATE SEQUENCE SEQ_PQCAPDUL
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;
  CREATE TABLE HCD_HEDGE_CORRECTION_DETAILS
(
  HCD_ID varchar(15),
  INTERNAL_ACTION_REF_NO varchar(30),
  HEDGE_CORRECTION_DATE date,
  QTY NUMBER(25,10),
  PER_DAY_HEDGE_CORRE_QTY NUMBER(25,10),
  TOTAL_NO_OF_PROMT_DAYS number(25,10),
  POFH_ID varchar(15)
)
;
--771

CREATE UNIQUE INDEX HCD ON HCD_HEDGE_CORRECTION_DETAILS
(HCD_ID);
CREATE SEQUENCE SEQ_HCD
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;
ALTER TABLE HCD_HEDGE_CORRECTION_DETAILS ADD (
  CONSTRAINT FK_HCD_POFH_ID 
 FOREIGN KEY (POFH_ID) 
 REFERENCES POFH_PRICE_OPT_FIXATION_HEADER (POFH_ID));
alter table PFD_PRICE_FIXATION_DETAILS add FX_FIXATION_DATE DATE ;
alter table PFD_PRICE_FIXATION_DETAILS add IS_HEDGE_CORRE_BEFORE_QP CHAR (1 CHAR) ;
alter table PFD_PRICE_FIXATION_DETAILS add HEDGE_AMOUNT NUMBER (25,10) ;
alter table POCH_PRICE_OPT_CALL_OFF_HEADER add IS_BALANCE_PRICING CHAR (1 CHAR);
alter table POFH_PRICE_OPT_FIXATION_HEADER add HEDGE_CORRECTION_QTY NUMBER (25,10) ;
alter table POFH_PRICE_OPT_FIXATION_HEADER add TOTAT_HEDGE_CORRE_QTY NUMBER (25,10) ;
alter table POFH_PRICE_OPT_FIXATION_HEADER add PER_DAY_HEDGE_CORRE_QTY NUMBER (25,10) ; 
alter table POFH_PRICE_OPT_FIXATION_HEADER add  QP_START_QTY NUMBER (25,10) ;
alter table PCBPH_PC_BASE_PRICE_HEADER add IS_BALANCE_PRICING CHAR (1 CHAR);
alter table PCBPHUL_PC_BASE_PRC_HEADER_UL add IS_BALANCE_PRICING CHAR (1 CHAR);
alter table PFD_PRICE_FIXATION_DETAILS add IS_HEDGE_CORRECTION CHAR (1 CHAR) ;
alter table POFH_PRICE_OPT_FIXATION_HEADER add IS_PROVESIONAL_ASSAY_EXIST  CHAR (1 CHAR);
alter table PFD_PRICE_FIXATION_DETAILS add FX_CORRECTION_DATE date;
alter table PFD_PRICE_FIXATION_DETAILS add IS_BALANCE_PRICING CHAR(1 CHAR);
alter table POFH_PRICE_OPT_FIXATION_HEADER add BALANCE_PRICED_QTY number(25,10);
alter table PFD_PRICE_FIXATION_DETAILS add HEDGE_CORRECTION_DATE date;
alter table  HCD_HEDGE_CORRECTION_DETAILS add VERSION VARCHAR2 (15 Char);

--772
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(FEED_QTY VARCHAR2(15 CHAR));

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(PAYABLE_QTY_DISPLAY VARCHAR2(15 CHAR));

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(FREE_METAL_QTY_DISPLAY VARCHAR2(15 CHAR));

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(TC_AMOUNT_DISPLAY VARCHAR2(100 CHAR));

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(RC_AMOUNT_DISPLAY VARCHAR2(100 CHAR));

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(PENALTY_AMOUNT_DISPLAY VARCHAR2(100 CHAR));

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(FREE_METAL_AMOUNT_DISPLAY VARCHAR2(100 CHAR));

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(TOTAL_INVOICE_AMOUNT VARCHAR2(15 CHAR));

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(PARENT_INVOICE_AMOUNT VARCHAR2(15 CHAR));

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(VAT_AMOUNT_IN_INVOICE_CURRENCY VARCHAR2(15 CHAR));

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(FX_RATE VARCHAR2(15 CHAR));
--774
create or replace view v_bi_mb_inventory_by_product as
select t.corporate_id corporate_id,
       t.product_id,
       t.product_name,
       round(sum(t.contained_qty),2) contained_quantity,
       round(sum(t.in_process_qty),2) inprocess_quantity,
       round(sum(t.stock_qty),2) stock_quantity,
       round(sum(t.debt_qty),2) debt_quantity,
       round(sum(t.contained_qty),2) + round(sum(t.in_process_qty),2) + round(sum(t.stock_qty),2)+
       round(sum(t.debt_qty),2) net_quantity,
       t.qty_unit_id base_qty_unit_id,
       t.qty_unit base_qty_unit
  from (
        -- Contained Qty and Debt Qty
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        sum( pkg_general.f_get_converted_quantity(pdm.product_id,
                                                    spq.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    spq.payable_qty)
              ) contained_qty,
        0 in_process_qty,
        0 stock_qty,
       -1* sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                            spq.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            spq.payable_qty)
              ) debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        spq_stock_payable_qty     spq,
        aml_attribute_master_list aml,
        qum_quantity_unit_master  qum,
        pdm_productmaster         pdm,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and spq.internal_grd_ref_no = grd.internal_grd_ref_no
    and spq.element_id = aml.attribute_id
    and aml.underlying_product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    --and grd.tolling_stock_type IN ( 'Clone Stock','None Tolling')
    and grd.tolling_stock_type IN ( 'None Tolling') --added 'None Tolling for  the Bug id 65542
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and spq.is_active = 'Y'
    and grd.warehouse_profile_id = phd_smelter.profileid(+)--TT in
    and grd.inventory_status = 'In'
    group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 union all
 -- In Process Qty
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 spq.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 spq.payable_qty))*-1 contained_qty,
        sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 spq.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 spq.payable_qty)) in_process_qty,
        0 stock_qty,
        0 debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        spq_stock_payable_qty     spq,
        aml_attribute_master_list aml,
        qum_quantity_unit_master  qum,
        pdm_productmaster         pdm,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and spq.element_id=grd.element_id
    and spq.element_id = aml.attribute_id
    and aml.underlying_product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.tolling_stock_type = 'MFT In Process Stock'
    and grd.warehouse_profile_id = phd_smelter.profileid(+)--TT in
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and spq.is_active = 'Y'
  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 -- Stock Qty Inventory in Base Metal Contracts
 union all
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0,
        0,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty)) stock_qty,
        0
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        pdm_productmaster         pdm,
        qum_quantity_unit_master  qum,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and grd.product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.warehouse_profile_id = phd_smelter.profileid(+) --TT in
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and grd.tolling_stock_type = 'None Tolling'
    and grd.inventory_status = 'In'
    and pdm.product_type_id = 'Standard'
  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 -- Stock Qty for In Process Stock
 union all
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0 contained_qty,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty))*-1 in_process_qty,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty)) stock_qty,
        0 debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        pdm_productmaster         pdm,
        qum_quantity_unit_master  qum,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and grd.tolling_stock_type = 'RM In Process Stock'
    and grd.product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.warehouse_profile_id = phd_smelter.profileid(+) --TT in
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
union all
select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0 contained_qty,
        0 in_process_qty,
        sum(pkg_general.f_get_converted_quantity(dgrd.product_id,
                                                 dgrd.net_weight_unit_id,
                                                 pdm.base_quantity_unit,
                                                 dgrd.current_qty))*(-1) stock_qty,
         sum(pkg_general.f_get_converted_quantity(dgrd.product_id,
                                                 dgrd.net_weight_unit_id,
                                                 pdm.base_quantity_unit,
                                                 dgrd.current_qty)) debt_qty
from dgrd_delivered_grd                  dgrd,
        gmr_goods_movement_record gmr,
        ak_corporate                         akc,
        pdm_productmaster               pdm,
        qum_quantity_unit_master      qum,
        phd_profileheaderdetails          phd_smelter
where dgrd.internal_gmr_ref_no=gmr.internal_gmr_ref_no
        and dgrd.tolling_stock_type = 'Return Material Stock'
        and gmr.corporate_id=akc.corporate_id
        and dgrd.product_id=pdm.product_id
        and pdm.base_quantity_unit=qum.qty_unit_id
        and dgrd.warehouse_profile_id=phd_smelter.profileid
group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname) t
   group by t.corporate_id,
           t.corporate_name,
           t.product_id,
           t.product_name,
           t.qty_unit_id,
           t.qty_unit;

create or replace view v_bi_mb_inventory_by_smelters as
select t.corporate_id,
       t.product_id,
       t.product_name,
       t.smelter_id,
       t.smelter_name,
       round(sum(t.contained_qty),2) contained_quantity,
       round(sum(t.in_process_qty),2) inprocess_quantity,
       round(sum(t.stock_qty),2) stock_quantity,
      -- round(sum(t.debt_qty),2) debt_qty,
       round(sum(t.contained_qty),2) + round(sum(t.in_process_qty),2) + round(sum(t.stock_qty),2)  net_quantity,
              t.qty_unit_id base_qty_unit_id,
       t.qty_unit base_qty_unit
  from (
    -- Contained Qty and Debt Qty
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        sum(case
              when spq.qty_type = 'Payable' then
               pkg_general.f_get_converted_quantity(pdm.product_id,
                                                    spq.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    spq.payable_qty)
              else
               0
            end) contained_qty,
        0 in_process_qty,
        0 stock_qty,
        sum(case
              when spq.qty_type = 'Returnable' then
               pkg_general.f_get_converted_quantity(pdm.product_id,
                                                    spq.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    spq.payable_qty)
              else
               0
            end) debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        pci_physical_contract_item pci,
        pcdi_pc_delivery_item pcdi,
        pcm_physical_contract_main pcm,
        ak_corporate              akc,
        spq_stock_payable_qty     spq,
        aml_attribute_master_list aml,
        qum_quantity_unit_master  qum,
        pdm_productmaster         pdm,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and spq.internal_grd_ref_no = grd.internal_grd_ref_no
    and spq.element_id = aml.attribute_id
    and aml.underlying_product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.tolling_stock_type = 'Clone Stock'
    and grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
    and pci.pcdi_id = pcdi.pcdi_id
    and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and spq.is_active = 'Y'
    and pcm.cp_id = phd_smelter.profileid
    and grd.inventory_status = 'In'

  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 union all
 -- In Process Qty
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 spq.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 spq.payable_qty))*-1 contained_qty,
        sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 spq.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 spq.payable_qty)) in_process_qty,
        0 stock_qty,
        0 debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        PCI_PHYSICAL_CONTRACT_ITEM pci,
        PCDI_PC_DELIVERY_ITEM pcdi,
        PCM_PHYSICAL_CONTRACT_MAIN pcm,
        ak_corporate              akc,
        spq_stock_payable_qty     spq,
        aml_attribute_master_list aml,
        qum_quantity_unit_master  qum,
        pdm_productmaster         pdm,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and grd.element_id=spq.element_id
     and grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
    and pci.pcdi_id = pcdi.pcdi_id
    and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
    and pcm.cp_id = phd_smelter.profileid
    and spq.element_id = aml.attribute_id
    and aml.underlying_product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.tolling_stock_type = 'MFT In Process Stock'
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and spq.is_active = 'Y'

  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 -- Stock Qty Inventory in Base Metal Contracts
 union all
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0,
        0,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty)) stock_qty,
        0
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        PCI_PHYSICAL_CONTRACT_ITEM pci,
        PCDI_PC_DELIVERY_ITEM pcdi,
        PCM_PHYSICAL_CONTRACT_MAIN pcm,
        ak_corporate              akc,
        pdm_productmaster         pdm,
        qum_quantity_unit_master  qum,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and grd.product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
    and pci.pcdi_id = pcdi.pcdi_id
    and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
    and pcm.cp_id = phd_smelter.profileid
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and grd.tolling_stock_type = 'None Tolling'
    and grd.inventory_status = 'In'
    and pdm.product_type_id = 'Standard'

  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 -- Stock Qty for In Process Stock
 union all
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0 contained_qty,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty))*(-1) in_process_qty,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty)) stock_qty,
        0 debt_qty
from grd_goods_record_detail        grd,
      gmr_goods_movement_record gmr,
      wrd_warehouse_receipt_detail wrd,
      ak_corporate                         akc,
      pdm_productmaster               pdm,
      qum_quantity_unit_master      qum,
      phd_profileheaderdetails          phd_smelter
where grd.internal_gmr_ref_no=gmr.internal_gmr_ref_no
      and grd.tolling_stock_type = 'RM In Process Stock'
      and gmr.internal_gmr_ref_no=wrd.internal_gmr_ref_no
      and gmr.corporate_id=akc.corporate_id
      and grd.product_id=pdm.product_id
      and pdm.base_quantity_unit=qum.qty_unit_id
      and wrd.smelter_cp_id=phd_smelter.profileid

group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
union all
select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0 contained_qty,
        0 in_process_qty,
        sum(pkg_general.f_get_converted_quantity(dgrd.product_id,
                                                 dgrd.net_weight_unit_id,
                                                 pdm.base_quantity_unit,
                                                 dgrd.current_qty))*-1 stock_qty,
        0 debt_qty
from dgrd_delivered_grd                  dgrd,
      gmr_goods_movement_record gmr,
      ak_corporate                         akc,
      pdm_productmaster               pdm,
      qum_quantity_unit_master      qum,
      phd_profileheaderdetails          phd_smelter
where dgrd.internal_gmr_ref_no=gmr.internal_gmr_ref_no
      and dgrd.tolling_stock_type = 'Return Material Stock'
      and gmr.corporate_id=akc.corporate_id
      and dgrd.product_id=pdm.product_id
      and pdm.base_quantity_unit=qum.qty_unit_id
      and dgrd.warehouse_profile_id=phd_smelter.profileid
group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname) t
   group by t.corporate_id,
           t.corporate_name,
           t.product_id,
           t.product_name,
           t.qty_unit_id,
           t.qty_unit,
           t.smelter_id,
           t.smelter_name;
create or replace view v_bi_mb_recent5_by_stock as
select t2.corporate_id,
       t2.product_id,
       t2.product_desc product_name,
       t2.action_ref_no reference_no,
       t2.activity,
       t2.cp_id,
       t2.cpname cp_name,--Bug 63266 Fix added alias name
       t2.qty quantity,
       t2.qty_unit_id base_qty_unit_id,
       t2.qty_unit base_qty_unit,
       t2.order_seq order_id--Bug 63266 Fix added column
  from (select t1.product_id,
               t1.corporate_id,
               t1.internal_grd_ref_no,
               t1.activity,
               t1.action_ref_no,
               t1.qty,
               t1.qty_unit_id,
               t1.created_date,
               t1.product_desc,
               t1.qty_unit,
               t1.cp_id,
               t1.cpname,
               row_number() over(partition by t1.corporate_id, t1.product_id order by t1.created_date desc) order_seq
          from (select t.product_id,
                       t.internal_grd_ref_no,
                       t.corporate_id,
                       axm.action_name activity,
                       t.action_ref_no,
                       t.qty,
                       t.qty_unit_id,
                       t.created_date,
                       pdm.product_desc,
                       qum.qty_unit,
                       phd.profileid cp_id,
                       phd.companyname cpname
                  from (select substr(max(case
                                            when dgrdul.internal_dgrd_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.internal_dgrd_ref_no
                                          end),
                                      24) internal_grd_ref_no,
                               substr(max(case
                                            when gmr.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.corporate_id
                                          end),
                                      24) corporate_id,
                               substr(max(case
                                            when dgrdul.pcdi_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.pcdi_id
                                          end),
                                      24) pcdi_id,
                               substr(max(case
                                            when dgrdul.product_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.product_id
                                          end),
                                      24) product_id,
                               substr(max(case
                                            when dgrdul.qty is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') || dgrdul.qty
                                          end),
                                      24) qty,
                               substr(max(case
                                            when gmr.qty_unit_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.qty_unit_id
                                          end),
                                      24) qty_unit_id,
                               substr(max(case
                                            when axs.action_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_id
                                          end),
                                      24) action_id,
                               substr(max(case
                                            when axs.action_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_ref_no
                                          end),
                                      24) action_ref_no,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from dgrdul_delivered_grd_ul   dgrdul,
                               gmr_goods_movement_record gmr,
                               axs_action_summary        axs
                         where dgrdul.internal_action_ref_no =
                               axs.internal_action_ref_no
                           and dgrdul.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no
                           and gmr.is_deleted='N' --Bug 65543
                         group by dgrdul.internal_dgrd_ref_no) t,
                       dgrd_delivered_grd dgrd,
                       axm_action_master axm,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       pcdi_pc_delivery_item pcdi,
                       pcm_physical_contract_main pcm,
                       phd_profileheaderdetails phd
                 where t.internal_grd_ref_no = dgrd.internal_dgrd_ref_no
                   and t.pcdi_id = pcdi.pcdi_id
                   and t.action_id = axm.action_id
                   and t.product_id = pdm.product_id
                   and pcdi.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and t.qty_unit_id = qum.qty_unit_id
                   and pcm.cp_id = phd.profileid
                union all
                select t.product_id,
                       t.internal_grd_ref_no,
                       t.corporate_id,
                       axm.action_name activity,
                       t.action_ref_no,
                       t.qty,
                       t.qty_unit_id,
                       t.created_date,
                       pdm.product_desc,
                       qum.qty_unit,
                       phd.profileid cp_id,
                       phd.companyname cpname
                  from (select substr(max(case
                                            when grdul.internal_grd_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.internal_grd_ref_no
                                          end),
                                      24) internal_grd_ref_no,
                               substr(max(case
                                            when gmr.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.corporate_id
                                          end),
                                      24) corporate_id,

                               substr(max(case
                                            when grdul.pcdi_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.pcdi_id
                                          end),
                                      24) pcdi_id,
                               substr(max(case
                                            when grdul.product_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.product_id
                                          end),
                                      24) product_id,
                               substr(max(case
                                            when grdul.qty is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') || grdul.qty
                                          end),
                                      24) qty,
                               substr(max(case
                                            when grdul.qty_unit_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.qty_unit_id
                                          end),
                                      24) qty_unit_id,
                               substr(max(case
                                            when axs.action_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_id
                                          end),
                                      24) action_id,
                               substr(max(case
                                            when axs.action_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_ref_no
                                          end),
                                      24) action_ref_no,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from grdul_goods_record_detail_ul grdul,
                               gmr_goods_movement_record    gmr,
                               axs_action_summary           axs
                         where grdul.internal_action_ref_no =
                               axs.internal_action_ref_no
                           and grdul.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no
                           and gmr.is_deleted='N'--Bug 65543
                         group by grdul.internal_grd_ref_no) t,
                       grd_goods_record_detail grd,
                       axm_action_master axm,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       pcdi_pc_delivery_item pcdi,
                       pcm_physical_contract_main pcm,
                       phd_profileheaderdetails phd
                 where t.internal_grd_ref_no = grd.internal_grd_ref_no
                   and t.action_id = axm.action_id
                   and t.pcdi_id = pcdi.pcdi_id
                   and t.product_id = pdm.product_id
                   and pcdi.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and pcm.cp_id = phd.profileid
                   and t.qty_unit_id = qum.qty_unit_id
       union all--Receive Material
       select  t.product_id,
           t.internal_grd_ref_no,
           t.corporate_id,
           axm.action_name activity,
           t.action_ref_no,
           t.qty,
           t.qty_unit_id,
           t.created_date,
           pdm.product_desc,
           qum.qty_unit,
           phd.profileid cp_id,
           phd.companyname cpname
                  from (select substr(max(case
                                            when grdul.internal_grd_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.internal_grd_ref_no
                                          end),
                                      24) internal_grd_ref_no,
                               substr(max(case
                                            when gmr.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.corporate_id
                                          end),
                                      24) corporate_id,
                               substr(max(case
                                            when grdul.product_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.product_id
                                          end),
                                      24) product_id,
                               substr(max(case
                                            when grdul.qty is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') || grdul.qty
                                          end),
                                      24) qty,
                               substr(max(case
                                            when grdul.qty_unit_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.qty_unit_id
                                          end),
                                      24) qty_unit_id,
                               substr(max(case
                                            when axs.action_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_id
                                          end),
                                      24) action_id,
                               substr(max(case
                                            when axs.action_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_ref_no
                                          end),
                                      24) action_ref_no,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from grdul_goods_record_detail_ul grdul,
                               gmr_goods_movement_record    gmr,
                               axs_action_summary           axs
                         where grdul.internal_action_ref_no =
                               axs.internal_action_ref_no
                           and grdul.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no
                           and gmr.is_deleted='N'--Bug 65543
                           and axs.status='Active'
                           --and gmr.gmr_ref_no='GMR-380-BLD'
                           group by grdul.internal_grd_ref_no) t,
                       grd_goods_record_detail grd,
                       axm_action_master axm,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       wrd_warehouse_receipt_detail wrd,
                       phd_profileheaderdetails phd

                 where t.internal_grd_ref_no = grd.internal_grd_ref_no
                   and grd.internal_gmr_ref_no=wrd.internal_gmr_ref_no
                   and wrd.smelter_cp_id=phd.profileid
                   and grd.tolling_stock_type='RM In Process Stock'
                   and t.action_id = axm.action_id
                   and t.product_id = pdm.product_id
                   and t.qty_unit_id = qum.qty_unit_id
                   and grd.is_deleted='N'
                   and pdm.is_active='Y'
 union all --Return Material
 select  t.product_id,
           t.internal_grd_ref_no,
           t.corporate_id,
           axm.action_name activity,
           t.action_ref_no,
           t.qty,
           t.qty_unit_id,
           t.created_date,
           pdm.product_desc,
           qum.qty_unit,
           phd.profileid cp_id,
           phd.companyname cpname
                  from (select substr(max(case
                                            when dgrdul.internal_dgrd_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.internal_dgrd_ref_no
                                          end),
                                      24) internal_grd_ref_no,
                               substr(max(case
                                            when gmr.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.corporate_id
                                          end),
                                      24) corporate_id,
                               substr(max(case
                                            when dgrdul.product_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.product_id
                                          end),
                                      24) product_id,
                               substr(max(case
                                            when dgrdul.net_weight is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') || dgrdul.net_weight
                                          end),
                                      24) qty,
                               substr(max(case
                                            when dgrdul.net_weight_unit_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.net_weight_unit_id
                                          end),
                                      24) qty_unit_id,
                               substr(max(case
                                            when axs.action_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_id
                                          end),
                                      24) action_id,
                               substr(max(case
                                            when axs.action_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_ref_no
                                          end),
                                      24) action_ref_no,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from dgrdul_delivered_grd_ul dgrdul,
                               gmr_goods_movement_record    gmr,
                               axs_action_summary           axs
                         where dgrdul.internal_action_ref_no =
                               axs.internal_action_ref_no
                           and dgrdul.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no
                           and gmr.is_deleted='N'--Bug 65543
                           --and gmr.gmr_ref_no='GMR-381-BLD'
                           and axs.status='Active'
                           group by dgrdul.internal_grd_ref_no) t,
                       dgrd_delivered_grd    dgrd,
                       axm_action_master axm,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       wrd_warehouse_receipt_detail wrd,
                       phd_profileheaderdetails phd
                 where t.internal_grd_ref_no = dgrd.internal_dgrd_ref_no
                   and dgrd.internal_gmr_ref_no=wrd.internal_gmr_ref_no
                   and wrd.smelter_cp_id=phd.profileid
                   and dgrd.tolling_stock_type='Return Material Stock'
                   and t.action_id = axm.action_id
                   and t.product_id = pdm.product_id
                   and t.qty_unit_id = qum.qty_unit_id
                   and dgrd.status='Active'
                   and pdm.is_active='Y' ) t1) t2
 where t2.order_seq < 6;

--776
DROP TABLE POFHD_POFH_DAILY CASCADE CONSTRAINTS;

CREATE TABLE POFHD_POFH_DAILY
(
  POFH_ID                     VARCHAR2(15 CHAR),
  POCD_ID                     VARCHAR2(15 CHAR),
  INTERNAL_GMR_REF_NO         VARCHAR2(15 CHAR),
  QP_START_DATE               DATE,
  QP_END_DATE                 DATE,
  PRICED_DATE                 DATE,
  QTY_TO_BE_FIXED             NUMBER(25,10),
  PRICED_QTY                  NUMBER(25,10),
  NO_OF_PROMPT_DAYS           NUMBER(25,10),
  PER_DAY_PRICING_QTY         NUMBER(25,10),
  FINAL_PRICE                 NUMBER(25,10),
  FINALIZE_DATE               DATE,
  VERSION                     NUMBER(10),
  IS_ACTIVE                   CHAR(1 CHAR),
  AVG_PRICE_IN_PRICE_IN_CUR   NUMBER(25,10),
  AVG_FX                      NUMBER(25,10),
  NO_OF_PROMPT_DAYS_FIXED     NUMBER(25,10)     DEFAULT 0,
  EVENT_NAME                  VARCHAR2(50 CHAR),
  DELTA_PRICED_QTY            NUMBER(25,10),
  FINAL_PRICE_IN_PRICING_CUR  NUMBER(25,10)
);
/

create or replace trigger trg_pop_pofh_price
/***************************************************************************************************
           Trigger Name                       :  trg_pop_pofh_price
           Author                             :    Saurabh
           Created Date                       : 28th May 2012
           Purpose                            : To Insert into  POFHD_POFH_DAILY Table

           Modification History

           Modified Date  :
           Modified By  :
           Modify Description :   */                                                                        
  after insert or update on pofh_price_opt_fixation_header
  for each row
declare
  -- local variables here

  vd_from_date date;
  vd_to_date   date;
  vd_instrument_id varchar2(30);

begin

  if inserting then
     select
                           ppfd.instrument_id into vd_instrument_id
                      from pcm_physical_contract_main     pcm,
                           pcdi_pc_delivery_item          pcdi,
                           poch_price_opt_call_off_header poch,
                           pocd_price_option_calloff_dtls pocd,
                           pcbpd_pc_base_price_detail     pcbpd,
                           ppfh_phy_price_formula_header  ppfh,
                           ppfd_phy_price_formula_details ppfd
                     where pcm.internal_contract_ref_no =
                           pcdi.internal_contract_ref_no
                       and pcdi.pcdi_id = poch.pcdi_id
                       and pcm.contract_type = 'BASEMETAL'
                       and pcm.contract_status = 'In Position'
                       and pcdi.is_active = 'Y'
                       and pocd.pocd_id=:new.pocd_id
                       and poch.is_active = 'Y'
                       and pocd.poch_id = poch.poch_id
                       and pocd.is_active = 'Y'
                       and :new.is_active = 'Y'
                       and pcbpd.pcbpd_id = pocd.pcbpd_id
                       and pcbpd.is_active = 'Y'
                       and ppfh.pcbpd_id = pcbpd.pcbpd_id
                       and ppfd.ppfh_id = ppfh.ppfh_id
                       and ppfh.is_active = 'Y'
                       and ppfd.is_active = 'Y'
                       and pocd.element_id is null
                       and poch.element_id is null
                       and pcbpd.element_id is null;
                    
    
   
      vd_from_date := :new.qp_start_date;
      vd_to_date   := :new.qp_end_date;
      while vd_from_date <= vd_to_date
      
      loop
        -- Here need to find holiday and insert
        begin
          if f_is_day_holiday(vd_instrument_id, vd_from_date) =
             'false' then
            insert into pofhd_pofh_daily
              (pofh_id,
               pocd_id,
               internal_gmr_ref_no,
               qp_start_date,
               qp_end_date,
               priced_date,
               qty_to_be_fixed,
               priced_qty,
               no_of_prompt_days,
               per_day_pricing_qty,
               final_price,
               finalize_date,
               version,
               is_active,
               avg_price_in_price_in_cur,
               avg_fx,
               no_of_prompt_days_fixed,
               event_name,
               delta_priced_qty,
               final_price_in_pricing_cur)
            values
              (:new.pofh_id,
               :new.pocd_id,
               :new.internal_gmr_ref_no,
               :new.qp_start_date,
               :new.qp_end_date,
                vd_from_date,
               :new.qty_to_be_fixed,
               :new.priced_qty,
               :new.no_of_prompt_days,
               :new.per_day_pricing_qty,
               :new.final_price,
               :new.finalize_date,
               :new.version,
               :new.is_active,
               :new.avg_price_in_price_in_cur,
               :new.avg_fx,
               :new.no_of_prompt_days_fixed,
               :new.event_name,
               :new.delta_priced_qty,
               :new.final_price_in_pricing_cur);
          end if;
        exception
          when others then
            null;
            dbms_output.put_line(' ERROR ' || sqlerrm);
        end;
        vd_from_date := vd_from_date + 1;
      end loop;
   
    
    
  elsif  updating  then
    if :new.is_active = 'N' then
    update pofhd_pofh_daily set is_active='N' where pofh_id = :new.pofh_id;
    end if;
  
  end if;
  
  exception
          when others then
            null;
            dbms_output.put_line(' ERROR ' || sqlerrm);
  
end;
alter table ASH_ASSAY_HEADER add(CONSOLIDATED_GROUP_ID varchar2(15));

alter table AS_ASSAY_D add(CONSOLIDATED_GROUP_ID VARCHAR2 (15 Char));


CREATE SEQUENCE SEQ_CONGRP
  START WITH 8181
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;

alter table II_INVOICABLE_ITEM add(IS_FM_PRICING_UTILITY_APPL CHAR(1) default 'N');

alter table IUS_INVOICE_UTILITY_SUMMARY add(ACTIVITY_DATE DATE);

alter table IS_INVOICE_SUMMARY add(IS_FM_PRICING_UTILITY_APPL CHAR(1) default 'N');

create or replace view v_bi_mb_inventory_by_product as
select t.corporate_id corporate_id,
       t.product_id,
       t.product_name,
       round(sum(t.contained_qty),2) contained_quantity,
       round(sum(t.in_process_qty),2) inprocess_quantity,
       round(sum(t.stock_qty),2) stock_quantity,
       round(sum(t.debt_qty),2) debt_quantity,
       round(sum(t.contained_qty),2) + round(sum(t.in_process_qty),2) + round(sum(t.stock_qty),2)+
       round(sum(t.debt_qty),2) net_quantity,
       t.qty_unit_id base_qty_unit_id,
       t.qty_unit base_qty_unit
  from (
        -- Contained Qty and Debt Qty
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        sum( pkg_general.f_get_converted_quantity(pdm.product_id,
                                                    spq.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    spq.payable_qty)
              ) contained_qty,
        0 in_process_qty,
        0 stock_qty,
       -1* sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                            spq.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            spq.payable_qty)
              ) debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        spq_stock_payable_qty     spq,
        aml_attribute_master_list aml,
        qum_quantity_unit_master  qum,
        pdm_productmaster         pdm,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and spq.internal_grd_ref_no = grd.internal_grd_ref_no
    and spq.element_id = aml.attribute_id
    and aml.underlying_product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    --and grd.tolling_stock_type IN ( 'Clone Stock','None Tolling')
    and grd.tolling_stock_type IN ( 'None Tolling') --added 'None Tolling for  the Bug id 65542
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and spq.is_active = 'Y'
    and grd.warehouse_profile_id = phd_smelter.profileid(+)--TT in
    and grd.inventory_status = 'In'
    group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 union all
 -- In Process Qty
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 spq.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 spq.payable_qty))*-1 contained_qty,
        sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 spq.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 spq.payable_qty)) in_process_qty,
        0 stock_qty,
        0 debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        spq_stock_payable_qty     spq,
        aml_attribute_master_list aml,
        qum_quantity_unit_master  qum,
        pdm_productmaster         pdm,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and spq.element_id=grd.element_id
    and spq.element_id = aml.attribute_id
    and aml.underlying_product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.tolling_stock_type = 'MFT In Process Stock'
    and grd.warehouse_profile_id = phd_smelter.profileid(+)--TT in
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and spq.is_active = 'Y'
  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 -- Stock Qty Inventory in Base Metal Contracts
 union all
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0,
        0,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty)) stock_qty,
        0
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        pdm_productmaster         pdm,
        qum_quantity_unit_master  qum,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and grd.product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.warehouse_profile_id = phd_smelter.profileid(+) --TT in
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and grd.tolling_stock_type = 'None Tolling'
    and grd.inventory_status = 'In'
    and pdm.product_type_id = 'Standard'
  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 -- Stock Qty for In Process Stock
 union all
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0 contained_qty,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty))*-1 in_process_qty,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty)) stock_qty,
        0 debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        ak_corporate              akc,
        pdm_productmaster         pdm,
        qum_quantity_unit_master  qum,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and grd.tolling_stock_type = 'RM In Process Stock'
    and grd.product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.warehouse_profile_id = phd_smelter.profileid(+) --TT in
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
union all
select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0 contained_qty,
        0 in_process_qty,
        sum(pkg_general.f_get_converted_quantity(dgrd.product_id,
                                                 dgrd.net_weight_unit_id,
                                                 pdm.base_quantity_unit,
                                                 dgrd.current_qty))*(-1) stock_qty,
         sum(pkg_general.f_get_converted_quantity(dgrd.product_id,
                                                 dgrd.net_weight_unit_id,
                                                 pdm.base_quantity_unit,
                                                 dgrd.current_qty)) debt_qty
from dgrd_delivered_grd                  dgrd,
        gmr_goods_movement_record gmr,
        ak_corporate                         akc,
        pdm_productmaster               pdm,
        qum_quantity_unit_master      qum,
        phd_profileheaderdetails          phd_smelter
where dgrd.internal_gmr_ref_no=gmr.internal_gmr_ref_no
        and dgrd.tolling_stock_type = 'Return Material Stock'
        and gmr.corporate_id=akc.corporate_id
        and dgrd.product_id=pdm.product_id
        and pdm.base_quantity_unit=qum.qty_unit_id
        and dgrd.warehouse_profile_id=phd_smelter.profileid
group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname) t
   group by t.corporate_id,
           t.corporate_name,
           t.product_id,
           t.product_name,
           t.qty_unit_id,
           t.qty_unit;

create or replace view v_bi_mb_inventory_by_smelters as
select t.corporate_id,
       t.product_id,
       t.product_name,
       t.smelter_id,
       t.smelter_name,
       round(sum(t.contained_qty),2) contained_quantity,
       round(sum(t.in_process_qty),2) inprocess_quantity,
       round(sum(t.stock_qty),2) stock_quantity,
      -- round(sum(t.debt_qty),2) debt_qty,
       round(sum(t.contained_qty),2) + round(sum(t.in_process_qty),2) + round(sum(t.stock_qty),2)  net_quantity,
              t.qty_unit_id base_qty_unit_id,
       t.qty_unit base_qty_unit
  from (
    -- Contained Qty and Debt Qty
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        sum(case
              when spq.qty_type = 'Payable' then
               pkg_general.f_get_converted_quantity(pdm.product_id,
                                                    spq.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    spq.payable_qty)
              else
               0
            end) contained_qty,
        0 in_process_qty,
        0 stock_qty,
        sum(case
              when spq.qty_type = 'Returnable' then
               pkg_general.f_get_converted_quantity(pdm.product_id,
                                                    spq.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    spq.payable_qty)
              else
               0
            end) debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        pci_physical_contract_item pci,
        pcdi_pc_delivery_item pcdi,
        pcm_physical_contract_main pcm,
        ak_corporate              akc,
        spq_stock_payable_qty     spq,
        aml_attribute_master_list aml,
        qum_quantity_unit_master  qum,
        pdm_productmaster         pdm,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and spq.internal_grd_ref_no = grd.internal_grd_ref_no
    and spq.element_id = aml.attribute_id
    and aml.underlying_product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.tolling_stock_type = 'Clone Stock'
    and grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
    and pci.pcdi_id = pcdi.pcdi_id
    and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and spq.is_active = 'Y'
    and pcm.cp_id = phd_smelter.profileid
    and grd.inventory_status = 'In'

  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 union all
 -- In Process Qty
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 spq.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 spq.payable_qty))*-1 contained_qty,
        sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                 spq.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 spq.payable_qty)) in_process_qty,
        0 stock_qty,
        0 debt_qty
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        PCI_PHYSICAL_CONTRACT_ITEM pci,
        PCDI_PC_DELIVERY_ITEM pcdi,
        PCM_PHYSICAL_CONTRACT_MAIN pcm,
        ak_corporate              akc,
        spq_stock_payable_qty     spq,
        aml_attribute_master_list aml,
        qum_quantity_unit_master  qum,
        pdm_productmaster         pdm,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and grd.element_id=spq.element_id
     and grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
    and pci.pcdi_id = pcdi.pcdi_id
    and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
    and pcm.cp_id = phd_smelter.profileid
    and spq.element_id = aml.attribute_id
    and aml.underlying_product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.tolling_stock_type = 'MFT In Process Stock'
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and spq.is_active = 'Y'

  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 -- Stock Qty Inventory in Base Metal Contracts
 union all
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0,
        0,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty)) stock_qty,
        0
   from grd_goods_record_detail   grd,
        gmr_goods_movement_record gmr,
        PCI_PHYSICAL_CONTRACT_ITEM pci,
        PCDI_PC_DELIVERY_ITEM pcdi,
        PCM_PHYSICAL_CONTRACT_MAIN pcm,
        ak_corporate              akc,
        pdm_productmaster         pdm,
        qum_quantity_unit_master  qum,
        phd_profileheaderdetails  phd_smelter
  where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
    and gmr.corporate_id = akc.corporate_id
    and grd.product_id = pdm.product_id
    and pdm.base_quantity_unit = qum.qty_unit_id
    and grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
    and pci.pcdi_id = pcdi.pcdi_id
    and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
    and pcm.cp_id = phd_smelter.profileid
    and grd.is_deleted = 'N'
    and gmr.is_deleted = 'N'
    and grd.tolling_stock_type = 'None Tolling'
    and grd.inventory_status = 'In'
    and pdm.product_type_id = 'Standard'

  group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
 -- Stock Qty for In Process Stock
 union all
 select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0 contained_qty,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty))*(-1) in_process_qty,
        sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                 grd.qty_unit_id,
                                                 pdm.base_quantity_unit,
                                                 grd.current_qty)) stock_qty,
        0 debt_qty
from grd_goods_record_detail        grd,
      gmr_goods_movement_record gmr,
      wrd_warehouse_receipt_detail wrd,
      ak_corporate                         akc,
      pdm_productmaster               pdm,
      qum_quantity_unit_master      qum,
      phd_profileheaderdetails          phd_smelter
where grd.internal_gmr_ref_no=gmr.internal_gmr_ref_no
      and grd.tolling_stock_type = 'RM In Process Stock'
      and gmr.internal_gmr_ref_no=wrd.internal_gmr_ref_no
      and gmr.corporate_id=akc.corporate_id
      and grd.product_id=pdm.product_id
      and pdm.base_quantity_unit=qum.qty_unit_id
      and wrd.smelter_cp_id=phd_smelter.profileid

group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname
union all
select akc.corporate_id,
        akc.corporate_name,
        pdm.product_id,
        pdm.product_desc product_name,
        qum.qty_unit_id,
        qum.qty_unit,
        phd_smelter.profileid smelter_id,
        phd_smelter.companyname smelter_name,
        0 contained_qty,
        0 in_process_qty,
        sum(pkg_general.f_get_converted_quantity(dgrd.product_id,
                                                 dgrd.net_weight_unit_id,
                                                 pdm.base_quantity_unit,
                                                 dgrd.current_qty))*-1 stock_qty,
        0 debt_qty
from dgrd_delivered_grd                  dgrd,
      gmr_goods_movement_record gmr,
      ak_corporate                         akc,
      pdm_productmaster               pdm,
      qum_quantity_unit_master      qum,
      phd_profileheaderdetails          phd_smelter
where dgrd.internal_gmr_ref_no=gmr.internal_gmr_ref_no
      and dgrd.tolling_stock_type = 'Return Material Stock'
      and gmr.corporate_id=akc.corporate_id
      and dgrd.product_id=pdm.product_id
      and pdm.base_quantity_unit=qum.qty_unit_id
      and dgrd.warehouse_profile_id=phd_smelter.profileid

group by akc.corporate_id,
           akc.corporate_name,
           pdm.product_id,
           pdm.product_desc,
           qum.qty_unit_id,
           qum.qty_unit,
           phd_smelter.profileid,
           phd_smelter.companyname) t
   group by t.corporate_id,
           t.corporate_name,
           t.product_id,
           t.product_name,
           t.qty_unit_id,
           t.qty_unit,
           t.smelter_id,
           t.smelter_name;
		   
create or replace view v_bi_mb_recent5_by_stock as
select t2.corporate_id,
       t2.product_id,
       t2.product_desc product_name,
       t2.action_ref_no reference_no,
       t2.activity,
       t2.cp_id,
       t2.cpname cp_name,--Bug 63266 Fix added alias name
       t2.qty quantity,
       t2.qty_unit_id base_qty_unit_id,
       t2.qty_unit base_qty_unit,
       t2.order_seq order_id--Bug 63266 Fix added column
  from (select t1.product_id,
               t1.corporate_id,
               t1.internal_grd_ref_no,
               t1.activity,
               t1.action_ref_no,
               t1.qty,
               t1.qty_unit_id,
               t1.created_date,
               t1.product_desc,
               t1.qty_unit,
               t1.cp_id,
               t1.cpname,
               row_number() over(partition by t1.corporate_id, t1.product_id order by t1.created_date desc) order_seq
          from (select t.product_id,
                       t.internal_grd_ref_no,
                       t.corporate_id,
                       axm.action_name activity,
                       t.action_ref_no,
                       t.qty,
                       t.qty_unit_id,
                       t.created_date,
                       pdm.product_desc,
                       qum.qty_unit,
                       phd.profileid cp_id,
                       phd.companyname cpname
                  from (select substr(max(case
                                            when dgrdul.internal_dgrd_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.internal_dgrd_ref_no
                                          end),
                                      24) internal_grd_ref_no,
                               substr(max(case
                                            when gmr.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.corporate_id
                                          end),
                                      24) corporate_id,
                               substr(max(case
                                            when dgrdul.pcdi_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.pcdi_id
                                          end),
                                      24) pcdi_id,
                               substr(max(case
                                            when dgrdul.product_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.product_id
                                          end),
                                      24) product_id,
                               substr(max(case
                                            when dgrdul.qty is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') || dgrdul.qty
                                          end),
                                      24) qty,
                               substr(max(case
                                            when gmr.qty_unit_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.qty_unit_id
                                          end),
                                      24) qty_unit_id,
                               substr(max(case
                                            when axs.action_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_id
                                          end),
                                      24) action_id,
                               substr(max(case
                                            when axs.action_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_ref_no
                                          end),
                                      24) action_ref_no,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from dgrdul_delivered_grd_ul   dgrdul,
                               gmr_goods_movement_record gmr,
                               axs_action_summary        axs
                         where dgrdul.internal_action_ref_no =
                               axs.internal_action_ref_no
                           and dgrdul.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no
                           and gmr.is_deleted='N' --Bug 65543
                         group by dgrdul.internal_dgrd_ref_no) t,
                       dgrd_delivered_grd dgrd,
                       axm_action_master axm,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       pcdi_pc_delivery_item pcdi,
                       pcm_physical_contract_main pcm,
                       phd_profileheaderdetails phd
                 where t.internal_grd_ref_no = dgrd.internal_dgrd_ref_no
                   and t.pcdi_id = pcdi.pcdi_id
                   and t.action_id = axm.action_id
                   and t.product_id = pdm.product_id
                   and pcdi.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and t.qty_unit_id = qum.qty_unit_id
                   and pcm.cp_id = phd.profileid
                union all
                select t.product_id,
                       t.internal_grd_ref_no,
                       t.corporate_id,
                       axm.action_name activity,
                       t.action_ref_no,
                       t.qty,
                       t.qty_unit_id,
                       t.created_date,
                       pdm.product_desc,
                       qum.qty_unit,
                       phd.profileid cp_id,
                       phd.companyname cpname
                  from (select substr(max(case
                                            when grdul.internal_grd_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.internal_grd_ref_no
                                          end),
                                      24) internal_grd_ref_no,
                               substr(max(case
                                            when gmr.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.corporate_id
                                          end),
                                      24) corporate_id,

                               substr(max(case
                                            when grdul.pcdi_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.pcdi_id
                                          end),
                                      24) pcdi_id,
                               substr(max(case
                                            when grdul.product_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.product_id
                                          end),
                                      24) product_id,
                               substr(max(case
                                            when grdul.qty is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') || grdul.qty
                                          end),
                                      24) qty,
                               substr(max(case
                                            when grdul.qty_unit_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.qty_unit_id
                                          end),
                                      24) qty_unit_id,
                               substr(max(case
                                            when axs.action_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_id
                                          end),
                                      24) action_id,
                               substr(max(case
                                            when axs.action_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_ref_no
                                          end),
                                      24) action_ref_no,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from grdul_goods_record_detail_ul grdul,
                               gmr_goods_movement_record    gmr,
                               axs_action_summary           axs
                         where grdul.internal_action_ref_no =
                               axs.internal_action_ref_no
                           and grdul.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no
                           and gmr.is_deleted='N'--Bug 65543
                         group by grdul.internal_grd_ref_no) t,
                       grd_goods_record_detail grd,
                       axm_action_master axm,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       pcdi_pc_delivery_item pcdi,
                       pcm_physical_contract_main pcm,
                       phd_profileheaderdetails phd
                 where t.internal_grd_ref_no = grd.internal_grd_ref_no
                   and t.action_id = axm.action_id
                   and t.pcdi_id = pcdi.pcdi_id
                   and t.product_id = pdm.product_id
                   and pcdi.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and pcm.cp_id = phd.profileid
                   and t.qty_unit_id = qum.qty_unit_id
       union all--Receive Material
       select  t.product_id,
           t.internal_grd_ref_no,
           t.corporate_id,
           axm.action_name activity,
           t.action_ref_no,
           t.qty,
           t.qty_unit_id,
           t.created_date,
           pdm.product_desc,
           qum.qty_unit,
           phd.profileid cp_id,
           phd.companyname cpname
                  from (select substr(max(case
                                            when grdul.internal_grd_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.internal_grd_ref_no
                                          end),
                                      24) internal_grd_ref_no,
                               substr(max(case
                                            when gmr.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.corporate_id
                                          end),
                                      24) corporate_id,
                               substr(max(case
                                            when grdul.product_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.product_id
                                          end),
                                      24) product_id,
                               substr(max(case
                                            when grdul.qty is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') || grdul.qty
                                          end),
                                      24) qty,
                               substr(max(case
                                            when grdul.qty_unit_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.qty_unit_id
                                          end),
                                      24) qty_unit_id,
                               substr(max(case
                                            when axs.action_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_id
                                          end),
                                      24) action_id,
                               substr(max(case
                                            when axs.action_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_ref_no
                                          end),
                                      24) action_ref_no,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from grdul_goods_record_detail_ul grdul,
                               gmr_goods_movement_record    gmr,
                               axs_action_summary           axs
                         where grdul.internal_action_ref_no =
                               axs.internal_action_ref_no
                           and grdul.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no
                           and gmr.is_deleted='N'--Bug 65543
                           and axs.status='Active'
                           --and gmr.gmr_ref_no='GMR-380-BLD'
                           group by grdul.internal_grd_ref_no) t,
                       grd_goods_record_detail grd,
                       axm_action_master axm,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       wrd_warehouse_receipt_detail wrd,
                       phd_profileheaderdetails phd

                 where t.internal_grd_ref_no = grd.internal_grd_ref_no
                   and grd.internal_gmr_ref_no=wrd.internal_gmr_ref_no
                   and wrd.smelter_cp_id=phd.profileid
                   and grd.tolling_stock_type='RM In Process Stock'
                   and t.action_id = axm.action_id
                   and t.product_id = pdm.product_id
                   and t.qty_unit_id = qum.qty_unit_id
                   and grd.is_deleted='N'
                   and pdm.is_active='Y'
 union all --Return Material
 select  t.product_id,
           t.internal_grd_ref_no,
           t.corporate_id,
           axm.action_name activity,
           t.action_ref_no,
           t.qty,
           t.qty_unit_id,
           t.created_date,
           pdm.product_desc,
           qum.qty_unit,
           phd.profileid cp_id,
           phd.companyname cpname
                  from (select substr(max(case
                                            when dgrdul.internal_dgrd_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.internal_dgrd_ref_no
                                          end),
                                      24) internal_grd_ref_no,
                               substr(max(case
                                            when gmr.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.corporate_id
                                          end),
                                      24) corporate_id,
                               substr(max(case
                                            when dgrdul.product_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.product_id
                                          end),
                                      24) product_id,
                               substr(max(case
                                            when dgrdul.net_weight is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') || dgrdul.net_weight
                                          end),
                                      24) qty,
                               substr(max(case
                                            when dgrdul.net_weight_unit_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.net_weight_unit_id
                                          end),
                                      24) qty_unit_id,
                               substr(max(case
                                            when axs.action_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_id
                                          end),
                                      24) action_id,
                               substr(max(case
                                            when axs.action_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_ref_no
                                          end),
                                      24) action_ref_no,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from dgrdul_delivered_grd_ul dgrdul,
                               gmr_goods_movement_record    gmr,
                               axs_action_summary           axs
                         where dgrdul.internal_action_ref_no =
                               axs.internal_action_ref_no
                           and dgrdul.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no
                           and gmr.is_deleted='N'--Bug 65543
                           --and gmr.gmr_ref_no='GMR-381-BLD'
                           and axs.status='Active'
                           group by dgrdul.internal_grd_ref_no) t,
                       dgrd_delivered_grd    dgrd,
                       axm_action_master axm,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       wrd_warehouse_receipt_detail wrd,
                       phd_profileheaderdetails phd

                 where t.internal_grd_ref_no = dgrd.internal_dgrd_ref_no
                   and dgrd.internal_gmr_ref_no=wrd.internal_gmr_ref_no
                   and wrd.smelter_cp_id=phd.profileid
                   and dgrd.tolling_stock_type='Return Material Stock'
                   and t.action_id = axm.action_id
                   and t.product_id = pdm.product_id
                   and t.qty_unit_id = qum.qty_unit_id
                   and dgrd.status='Active'
                   and pdm.is_active='Y' ) t1) t2
 where t2.order_seq < 6;
 
 --782
 ALTER TABLE GRD_GOODS_RECORD_DETAIL DROP CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE;
ALTER TABLE AGRD_ACTION_GRD DROP CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE;

ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD
(
CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE
    CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock'))
);        
  
ALTER TABLE AGRD_ACTION_GRD ADD
(
CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE
CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock'))
);

create or replace function f_get_returnable_due_date(pc_activity_action_id varchar2,
                                                     pc_stock_id           varchar2,
                                                     pc_element_id         varchar2)
  return date is
  returnable_due_date   date;
  v_activity_date       date;
  v_due_date_days       number(25, 10);
  v_due_date_activity   varchar2(20);
  v_internal_gmr_ref_no varchar2(15);
begin
  --dbms_output.put_line('hello');
  begin
    --To get Event Details & Internal_GMR_Ref_No of Passed Stock & Element
    select pcpch.due_date_days,
           pcpch.due_date_activity,
           grd.internal_gmr_ref_no
      into v_due_date_days,
           v_due_date_activity,
           v_internal_gmr_ref_no
      from grd_goods_record_detail        grd,
           pci_physical_contract_item     pci,
           pcdi_pc_delivery_item          pcdi,
           dipch_di_payablecontent_header dipch,
           pcpch_pc_payble_content_header pcpch
     where grd.internal_contract_item_ref_no =
           pci.internal_contract_item_ref_no
       and pci.pcdi_id = pcdi.pcdi_id
       and pcdi.pcdi_id = dipch.pcdi_id
       and pcpch.pcpch_id = dipch.pcpch_id
       and pcpch.payable_type = 'Returnable'
       and dipch.is_active = 'Y'
       and pcpch.is_active = 'Y'
       and pcpch.element_id = pc_element_id
       and grd.internal_grd_ref_no = pc_stock_id;
  
    if v_due_date_activity = 'Shipment' and
       pc_activity_action_id not in
       ('CANCEL_SD', 'CANCEL_WR', 'CANCEL_RD', 'CANCEL_TD', 'CANCEL_AID') then
      select axs.eff_date
        into v_activity_date
        from agmr_action_gmr        agmr,
             gam_gmr_action_mapping gam,
             axs_action_summary     axs
       where gam.internal_gmr_ref_no = agmr.internal_gmr_ref_no
         and gam.action_no = agmr.action_no
         and axs.internal_action_ref_no = gam.internal_action_ref_no
         and axs.action_id = agmr.gmr_latest_action_action_id
         and axs.status = 'Active'
         and agmr.gmr_latest_action_action_id in
             ('shipmentDetail', 'railDetail', 'truckDetail', 'airDetail',
              'warehouseReceipt')
         and agmr.internal_gmr_ref_no = v_internal_gmr_ref_no;
    end if;
  
    if v_due_date_activity = 'Landing' and
       pc_activity_action_id not in ('CANCEL_WR', 'CANCEL_LD') then
      select axs.eff_date
        into v_activity_date
        from agmr_action_gmr        agmr,
             gam_gmr_action_mapping gam,
             axs_action_summary     axs
       where gam.internal_gmr_ref_no = agmr.internal_gmr_ref_no
         and gam.action_no = agmr.action_no
         and axs.internal_action_ref_no = gam.internal_action_ref_no
         and axs.action_id = agmr.gmr_latest_action_action_id
         and axs.status = 'Active'
         and agmr.gmr_latest_action_action_id in
             ('landingDetail', 'warehouseReceipt')
         and agmr.internal_gmr_ref_no = v_internal_gmr_ref_no;
    end if;
  
    if v_due_date_activity = 'Sampling' and
       pc_activity_action_id <> 'CANCEL_WNS_ASSAY' then
      select axs.eff_date
        into v_activity_date
        from ash_assay_header   ash,
             axs_action_summary axs
       where axs.internal_action_ref_no = ash.internal_action_ref_no
         and ash.assay_type = 'Weighing and Sampling Assay'
         and ash.is_active = 'Y'
         and nvl(ash.is_delete, 'N') = 'N'
         and axs.action_id = 'CREATE_WNS_ASSAY'
         and axs.status = 'Active'
         and ash.internal_gmr_ref_no = v_internal_gmr_ref_no
         and ash.internal_grd_ref_no = pc_stock_id;
    end if;
  
    /*if v_due_date_activity = 'Assay Finalization' then
    
    end if;*/
  
    returnable_due_date := v_activity_date + nvl(v_due_date_days, 0);
  
    --print msg start
    /*dbms_output.put_line(v_due_date_days);
    dbms_output.put_line(v_due_date_activity);
    dbms_output.put_line(v_internal_gmr_ref_no);
    dbms_output.put_line(v_activity_date);
    dbms_output.put_line(returnable_due_date);*/
    --print msg end
  
  exception
    when others then
      returnable_due_date := null;
  end;
  return returnable_due_date;
end f_get_returnable_due_date;
/
ALTER TABLE IUH_INVOICE_UTILITY_HEADER
 ADD (IUH_ID  VARCHAR2(15 CHAR)                     NOT NULL);

ALTER TABLE IUH_INVOICE_UTILITY_HEADER
 ADD CONSTRAINT IUH_INVOICE_UTILITY_HEADER_PK
 PRIMARY KEY
 (IUH_ID);

CREATE SEQUENCE SEQ_IUH
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 100000000000000000000000000
CACHE 20
NOCYCLE 
NOORDER ;

create or replace package "PKG_REPORT_GENERAL" is
  -- All general packages and procedures
  function fn_get_item_dry_qty(pc_internal_cont_item_ref_no varchar2,
                               pn_item_qty                  number)
    return number;
  procedure sp_element_position_qty(pc_internal_contract_ref_no varchar2,
                                    pn_qty                      number,
                                    pc_qty_unit_id              varchar2,
                                    pc_assay_header_id          varchar2,
                                    pc_element_id               varchar2,
                                    pc_ele_qty_string           out varchar2);
  function fn_get_element_qty(pc_internal_contract_ref_no varchar2,
                              pn_qty                      number,
                              pc_qty_unit_id              varchar2,
                              pc_assay_header_id          varchar2,
                              pc_element_id               varchar2)
    return number;
  function fn_get_element_assay_qty(pc_element_id      varchar2,
                                    pc_assay_header_id varchar2,
                                    pc_wet_dry_type    varchar2,
                                    pn_qty             number,
                                    pc_qty_unit_id     varchar2)
    return number;
  function fn_get_element_qty_unit_id(pc_internal_contract_ref_no varchar2,
                                      pc_item_qty_unit_id         varchar2,
                                      pc_assay_header_id          varchar2,
                                      pc_element_id               varchar2)
    return varchar2;
  function fn_get_element_pricing_month(pc_pcbpd_id   in varchar2,
                                        pc_element_id varchar2)
    return varchar2;
  function fn_get_assay_dry_qty(pc_product_id      varchar2,
                                pc_assay_header_id varchar2,
                                pn_qty             number,
                                pc_qty_unit_id     varchar2) return number;
  function fn_deduct_wet_to_dry_qty(pc_product_id                varchar2,
                                    pc_internal_cont_item_ref_no varchar2,
                                    pn_item_qty                  number)
    return number;
  function fn_get_elmt_assay_content_qty(pc_element_id      varchar2,
                                         pc_assay_header_id varchar2,
                                         pn_qty             number,
                                         pc_qty_unit_id     varchar2)
    return number;

end; 
/
create or replace package body "PKG_REPORT_GENERAL" is
  function fn_get_item_dry_qty(pc_internal_cont_item_ref_no varchar2,
                               pn_item_qty                  number)
    return number is
    vn_deduct_qty       number;
    vn_deduct_total_qty number;
    vn_item_qty         number;
    vn_converted_qty    number;
  begin
    vn_item_qty         := pn_item_qty;
    vn_deduct_qty       := 0;
    vn_deduct_total_qty := 0;
    for cur_deduct_qty in (select aml.attribute_id,
                                  rm.ratio_name,
                                  rm.qty_unit_id_numerator,
                                  rm.qty_unit_id_denominator,
                                  pqca.typical,
                                  ppm.product_id,
                                  pci.item_qty_unit_id
                             from ppm_product_properties_mapping ppm,
                                  aml_attribute_master_list      aml,
                                  pqca_pq_chemical_attributes    pqca,
                                  rm_ratio_master                rm,
                                  asm_assay_sublot_mapping       asm,
                                  ash_assay_header               ash,
                                  pcdi_pc_delivery_item          pcdi,
                                  pci_physical_contract_item     pci,
                                  pcpq_pc_product_quality        pcpq,
                                  pcpd_pc_product_definition     pcpd
                            where ppm.attribute_id = aml.attribute_id
                              and aml.attribute_id = pqca.element_id
                              and pqca.asm_id = asm.asm_id
                              and pqca.unit_of_measure = rm.ratio_id
                              and asm.ash_id = ash.ash_id
                              and ash.internal_contract_ref_no =
                                  pcdi.internal_contract_ref_no
                              and pcdi.pcdi_id = pci.pcdi_id
                              and pci.pcpq_id = pcpq.pcpq_id
                              and pcpq.pcpd_id = pcpd.pcpd_id
                              and ppm.product_id = pcpd.product_id
                              and pci.internal_contract_item_ref_no =
                                  pc_internal_cont_item_ref_no
                              and pcpq.assay_header_id = ash.ash_id
                              and ppm.deduct_for_wet_to_dry = 'Y')
    loop
    
      if cur_deduct_qty.ratio_name = '%' then
        vn_deduct_qty := vn_item_qty * (cur_deduct_qty.typical / 100);
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 cur_deduct_qty.qty_unit_id_denominator,
                                                                 vn_item_qty) *
                            cur_deduct_qty.typical;
        vn_deduct_qty    := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.qty_unit_id_numerator,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 vn_converted_qty);
      
      end if;
      vn_deduct_total_qty := vn_deduct_total_qty + vn_deduct_qty;
    
    end loop;
    return vn_deduct_total_qty;
  end;
  --
  procedure sp_element_position_qty(pc_internal_contract_ref_no varchar2,
                                    pn_qty                      number,
                                    pc_qty_unit_id              varchar2,
                                    pc_assay_header_id          varchar2,
                                    pc_element_id               varchar2,
                                    pc_ele_qty_string           out varchar2) is
  
    cursor cur_element is
      select pci.internal_contract_item_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpq.unit_of_measure item_unit_of_measure,
             pqca.element_id,
             pcpq.assay_header_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from pci_physical_contract_item  pci,
             pcpq_pc_product_quality     pcpq,
             ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
      
       where pci.pcpq_id = pcpq.pcpq_id
         and pcpq.assay_header_id = ash.ash_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pci.internal_contract_item_ref_no =
             pc_internal_contract_ref_no
         and pcpq.assay_header_id = pc_assay_header_id
         and pqca.element_id = pc_element_id;
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
  
  begin
    for cur_element_rows in cur_element
    loop
      if cur_element_rows.item_unit_of_measure = 'Wet' then
        vn_deduct_qty := fn_get_item_dry_qty(cur_element_rows.internal_contract_item_ref_no,
                                             cur_element_rows.item_qty);
        vn_item_qty   := cur_element_rows.item_qty - vn_deduct_qty;
      else
        vn_item_qty := cur_element_rows.item_qty;
      end if;
    
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.item_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := cur_element_rows.item_qty_unit_id;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 cur_element_rows.item_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
      
        vn_element_qty := vn_converted_qty * cur_element_rows.typical;
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
      
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      end if;
    end loop;
  end;
  function fn_get_element_qty(pc_internal_contract_ref_no varchar2,
                              pn_qty                      number,
                              pc_qty_unit_id              varchar2,
                              pc_assay_header_id          varchar2,
                              pc_element_id               varchar2)
    return number is
    cursor cur_element is
      select pci.internal_contract_item_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpq.unit_of_measure item_unit_of_measure,
             pqca.element_id,
             pcpq.assay_header_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from pci_physical_contract_item  pci,
             pcpq_pc_product_quality     pcpq,
             ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
       where pci.pcpq_id = pcpq.pcpq_id
         and pcpq.assay_header_id = ash.ash_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pci.internal_contract_item_ref_no =
             pc_internal_contract_ref_no
         and pcpq.assay_header_id = pc_assay_header_id
         and pqca.element_id = pc_element_id;
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
    pc_ele_qty_string      varchar2(100);
    vn_ele_qty             number;
  begin
    for cur_element_rows in cur_element
    loop
      if cur_element_rows.item_unit_of_measure = 'Wet' then
        vn_deduct_qty := fn_get_item_dry_qty(cur_element_rows.internal_contract_item_ref_no,
                                             pn_qty);
        vn_item_qty   := pn_qty - vn_deduct_qty;
      else
        vn_item_qty := pn_qty;
      end if;
    
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.item_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := pc_qty_unit_id;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
      
        vn_element_qty := vn_converted_qty * cur_element_rows.typical;
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
      
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      end if;
      vn_ele_qty := vn_element_qty;
    end loop;
    return(vn_ele_qty);
  end;
  function fn_get_element_assay_qty(pc_element_id      varchar2,
                                    pc_assay_header_id varchar2,
                                    pc_wet_dry_type    varchar2,
                                    pn_qty             number,
                                    pc_qty_unit_id     varchar2)
    return number is
    cursor cur_element is
      select pqca.element_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
       where ash.ash_id = pc_assay_header_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pqca.element_id = pc_element_id;
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
    --pc_ele_qty_string      varchar2(100);
    vn_ele_qty number;
  begin
    for cur_element_rows in cur_element
    loop
      vn_deduct_qty := 0;
      if pc_wet_dry_type = 'Wet' then
        /*vn_deduct_qty := fn_get_item_dry_qty(cur_element_rows.internal_contract_item_ref_no,
        pn_qty);*/
        vn_item_qty := pn_qty - vn_deduct_qty;
      else
        vn_item_qty := pn_qty;
      end if;
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = pc_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := pc_qty_unit_id;
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
        vn_element_qty   := vn_converted_qty * cur_element_rows.typical;
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      end if;
      vn_ele_qty := vn_element_qty;
    end loop;
    return(vn_ele_qty);
  end;
  function fn_get_element_qty_unit_id(pc_internal_contract_ref_no varchar2,
                                      pc_item_qty_unit_id         varchar2,
                                      pc_assay_header_id          varchar2,
                                      pc_element_id               varchar2)
    return varchar2 is
    cursor cur_element is
      select pqca.element_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
       where ash.ash_id = pc_assay_header_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pqca.element_id = pc_element_id;
  
    vc_element_qty_unit_id varchar2(15);
  begin
    for cur_element_rows in cur_element
    loop
      if cur_element_rows.ratio_name = '%' then
        vc_element_qty_unit_id := pc_item_qty_unit_id;
      else
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      end if;
    end loop;
    return(vc_element_qty_unit_id);
  end;
  function fn_get_element_pricing_month(pc_pcbpd_id   in varchar2,
                                        pc_element_id varchar2)
    return varchar2 is
    cursor cur_qp_end_date is
      select pcm.contract_ref_no,
             pcdi.pcdi_id,
             pcbpd.pcbpd_id,
             pcdi.internal_contract_ref_no,
             pci.internal_contract_item_ref_no,
             pcdi.delivery_item_no,
             pcdi.delivery_period_type,
             pcdi.delivery_from_month,
             pcdi.delivery_from_year,
             pcdi.delivery_to_month,
             pcdi.delivery_to_year,
             pcdi.delivery_from_date,
             pcdi.delivery_to_date,
             pcdi.basis_type,
             nvl(pcdi.transit_days, 0) transit_days,
             pcdi.qp_declaration_date,
             ppfh.ppfh_id,
             ppfh.price_unit_id,
             pocd.qp_period_type,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pfqpp.event_name,
             pfqpp.no_of_event_months,
             pofh.pofh_id,
             pcbpd.price_basis
        from pcdi_pc_delivery_item          pcdi,
             pci_physical_contract_item     pci,
             pcm_physical_contract_main     pcm,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pcbpd_pc_base_price_detail     pcbpd,
             ppfh_phy_price_formula_header  ppfh,
             pfqpp_phy_formula_qp_pricing   pfqpp
       where pcdi.pcdi_id = pci.pcdi_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcdi.pcdi_id = poch.pcdi_id
         and poch.poch_id = pocd.poch_id
         and pocd.pocd_id = pofh.pocd_id(+)
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
         and ppfh.ppfh_id = pfqpp.ppfh_id(+)
         and pcm.contract_status = 'In Position'
            --  and pcm.contract_type = 'BASEMETAL'
         and pcbpd.price_basis <> 'Fixed'
         and pci.item_qty > 0
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pofh.is_active(+) = 'Y'
         and pcbpd.is_active = 'Y'
         and poch.element_id = pc_element_id
            --and pci.internal_contract_item_ref_no = pc_Int_contract_Item_Ref_No Commented
         and pocd.pcbpd_id = pc_pcbpd_id; -- Newly Added
    --and pfqpp.is_active = 'Y'
    --and pofh.is_active(+) = 'Y';
  
    vd_qp_start_date date;
    vd_qp_end_date   date;
    vd_shipment_date date;
    vd_arrival_date  date;
    vd_evevnt_date   date;
  
  begin
  
    for cur_rows in cur_qp_end_date
    loop
      if cur_rows.price_basis in ('Index', 'Formula') then
      
        if cur_rows.basis_type = 'Shipment' then
          if cur_rows.delivery_period_type = 'Month' then
            vd_shipment_date := last_day('01-' ||
                                         cur_rows.delivery_to_month || '-' ||
                                         cur_rows.delivery_to_year);
          elsif cur_rows.delivery_period_type = 'Date' then
            vd_shipment_date := cur_rows.delivery_to_date;
          end if;
          vd_arrival_date := vd_shipment_date + cur_rows.transit_days;
        
        elsif cur_rows.basis_type = 'Arrival' then
          if cur_rows.delivery_period_type = 'Month' then
            vd_arrival_date := last_day('01-' || cur_rows.delivery_to_month || '-' ||
                                        cur_rows.delivery_to_year);
          elsif cur_rows.delivery_period_type = 'Date' then
            vd_arrival_date := cur_rows.delivery_to_date;
          end if;
          vd_shipment_date := vd_arrival_date - cur_rows.transit_days;
        end if;
      
        if cur_rows.qp_period_type = 'Period' then
          vd_qp_start_date := cur_rows.qp_start_date;
          vd_qp_end_date   := cur_rows.qp_end_date;
        elsif cur_rows.qp_period_type = 'Month' then
          vd_qp_start_date := cur_rows.qp_start_date;
          vd_qp_end_date   := cur_rows.qp_end_date;
        elsif cur_rows.qp_period_type = 'Date' then
          vd_qp_start_date := cur_rows.qp_start_date;
          vd_qp_end_date   := cur_rows.qp_end_date;
        elsif cur_rows.qp_period_type = 'Event' then
          begin
            select dieqp.expected_qp_start_date,
                   dieqp.expected_qp_end_date
              into vd_qp_start_date,
                   vd_qp_end_date
              from di_del_item_exp_qp_details dieqp
             where dieqp.pcdi_id = cur_rows.pcdi_id
               and dieqp.pcbpd_id = cur_rows.pcbpd_id
               and dieqp.is_active = 'Y';
          exception
            when no_data_found then
              vd_qp_start_date := cur_rows.qp_start_date;
              vd_qp_end_date   := cur_rows.qp_end_date;
            when others then
              vd_qp_start_date := cur_rows.qp_end_date;
              vd_qp_end_date   := cur_rows.qp_end_date;
          end;
          /*if cur_rows.event_name = 'Month After Month Of Shipment' then
            vd_evevnt_date   := add_months(vd_shipment_date,
                                           cur_rows.no_of_event_months);
            vd_qp_start_date := to_date('01-' ||
                                        to_char(vd_evevnt_date, 'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := last_day(vd_qp_start_date);
          elsif cur_rows.event_name = 'Month After Month Of Arrival' then
            vd_evevnt_date   := add_months(vd_arrival_date,
                                           cur_rows.no_of_event_months);
            vd_qp_start_date := to_date('01-' ||
                                        to_char(vd_evevnt_date, 'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := last_day(vd_qp_start_date);
          elsif cur_rows.event_name = 'Month Before Month Of Shipment' then
            vd_evevnt_date   := add_months(vd_shipment_date,
                                           -1 * cur_rows.no_of_event_months);
            vd_qp_start_date := to_date('01-' ||
                                        to_char(vd_evevnt_date, 'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := last_day(vd_qp_start_date);
          elsif cur_rows.event_name = 'Month Before Month Of Arrival' then
            vd_evevnt_date   := add_months(vd_arrival_date,
                                           -1 * cur_rows.no_of_event_months);
            vd_qp_start_date := to_date('01-' ||
                                        to_char(vd_evevnt_date, 'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := last_day(vd_qp_start_date);
          elsif cur_rows.event_name = 'First Half Of Shipment Month' then
            vd_qp_start_date := to_date('01-' ||
                                        to_char(vd_shipment_date,
                                                'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := to_date('15-' ||
                                        to_char(vd_shipment_date,
                                                'Mon-yyyy'),
                                        'dd-mon-yyyy');
          elsif cur_rows.event_name = 'First Half Of Arrival Month' then
            vd_qp_start_date := to_date('01-' ||
                                        to_char(vd_arrival_date, 'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := to_date('15-' ||
                                        to_char(vd_arrival_date, 'Mon-yyyy'),
                                        'dd-mon-yyyy');
          elsif cur_rows.event_name = 'First Half Of Shipment Month' then
            vd_qp_start_date := to_date('16-' ||
                                        to_char(vd_shipment_date,
                                                'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := last_day(vd_qp_start_date);
          elsif cur_rows.event_name = 'Second Half Of Arrival Month' then
            vd_qp_start_date := to_date('16-' ||
                                        to_char(vd_arrival_date, 'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := last_day(vd_qp_start_date);
          end if;*/
        end if;
      
      end if;
    end loop;
  
    return to_char(last_day(vd_qp_end_date), 'dd-Mon-yyyy');
  end;
  function fn_get_assay_dry_qty(pc_product_id      varchar2,
                                pc_assay_header_id varchar2,
                                pn_qty             number,
                                pc_qty_unit_id     varchar2) return number is
    vn_deduct_qty       number;
    vn_deduct_total_qty number;
    vn_item_qty         number;
    vn_converted_qty    number;
  begin
    vn_deduct_qty       := 0;
    vn_deduct_total_qty := 0;
    for cur_deduct_qty in (select ash.ash_id,
                                  (case
                                    when ash.ash_id =
                                         (select ash_new.pricing_assay_ash_id
                                            from ash_assay_header ash_new
                                           where ash_new.assay_type =
                                                 'Provisional Assay'
                                             and ash_new.is_active = 'Y'
                                             and ash_new.internal_grd_ref_no =
                                                 ash.internal_grd_ref_no) then
                                     pn_qty                                    
                                    when ash.ash_id =
                                         (select ash_new.ash_id
                                            from ash_assay_header ash_new
                                           where ash_new.assay_type =
                                                 'Shipment Assay'
                                             and ash_new.is_active = 'Y'
                                             and ash_new.internal_grd_ref_no =
                                                 ash.internal_grd_ref_no) then
                                     pn_qty
                                    else
                                     asm.net_weight
                                  end) net_weight,
                                  pqca.element_id,
                                  pqca.is_elem_for_pricing,
                                  pqca.unit_of_measure,
                                  pqca.payable_percentage,
                                  pqca.typical,
                                  rm.qty_unit_id_numerator,
                                  rm.qty_unit_id_denominator,
                                  rm.ratio_name,
                                  aml.attribute_name,
                                  aml.attribute_desc,
                                  ppm.product_id,
                                  aml.underlying_product_id
                             from ash_assay_header               ash,
                                  asm_assay_sublot_mapping       asm,
                                  aml_attribute_master_list      aml,
                                  pqca_pq_chemical_attributes    pqca,
                                  rm_ratio_master                rm,
                                  ppm_product_properties_mapping ppm
                            where ash.ash_id = pc_assay_header_id
                              and ash.ash_id = asm.ash_id
                              and asm.asm_id = pqca.asm_id
                              and pqca.unit_of_measure = rm.ratio_id
                              and pqca.element_id = aml.attribute_id
                              and ppm.attribute_id = aml.attribute_id
                              and ppm.product_id = pc_product_id
                              and nvl(ppm.deduct_for_wet_to_dry, 'N') = 'Y')
    loop
      vn_item_qty := nvl(cur_deduct_qty.net_weight, pn_qty);
      if cur_deduct_qty.ratio_name = '%' then
        vn_deduct_qty := vn_item_qty * (cur_deduct_qty.typical / 100);
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(pc_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_deduct_qty.qty_unit_id_denominator,
                                                                 vn_item_qty) *
                            cur_deduct_qty.typical;
        vn_deduct_qty    := pkg_general.f_get_converted_quantity(pc_product_id,
                                                                 cur_deduct_qty.qty_unit_id_numerator,
                                                                 pc_qty_unit_id,
                                                                 vn_converted_qty);
      end if;
      vn_deduct_total_qty := vn_deduct_total_qty + vn_deduct_qty;
    end loop;
    return(pn_qty - vn_deduct_total_qty);
  end;

  function fn_deduct_wet_to_dry_qty(pc_product_id                varchar2,
                                    pc_internal_cont_item_ref_no varchar2,
                                    pn_item_qty                  number)
    return number is
  
    vn_deduct_qty       number;
    vn_deduct_total_qty number;
    vn_item_qty         number;
    vn_converted_qty    number;
  begin
    vn_item_qty         := pn_item_qty;
    vn_deduct_qty       := 0;
    vn_deduct_total_qty := 0;
    for cur_deduct_qty in (select rm.ratio_name,
                                  rm.qty_unit_id_numerator,
                                  rm.qty_unit_id_denominator,
                                  pqca.typical,
                                  ppm.product_id,
                                  pci.item_qty_unit_id
                             from ppm_product_properties_mapping ppm,
                                  aml_attribute_master_list      aml,
                                  pqca_pq_chemical_attributes    pqca,
                                  rm_ratio_master                rm,
                                  asm_assay_sublot_mapping       asm,
                                  ash_assay_header               ash,
                                  pcdi_pc_delivery_item          pcdi,
                                  pci_physical_contract_item     pci,
                                  pcpq_pc_product_quality        pcpq
                            where ppm.attribute_id = aml.attribute_id
                              and aml.attribute_id = pqca.element_id
                              and pqca.asm_id = asm.asm_id
                              and pqca.unit_of_measure = rm.ratio_id
                              and asm.ash_id = ash.ash_id
                              and ash.internal_contract_ref_no =
                                  pcdi.internal_contract_ref_no
                              and pcdi.pcdi_id = pci.pcdi_id
                              and pci.pcpq_id = pcpq.pcpq_id
                              and pci.internal_contract_item_ref_no =
                                  pc_internal_cont_item_ref_no
                              and ppm.product_id = pc_product_id
                              and pcpq.assay_header_id = ash.ash_id
                              and ppm.deduct_for_wet_to_dry = 'Y')
    loop
      if cur_deduct_qty.ratio_name = '%' then
        vn_deduct_qty := vn_item_qty * (cur_deduct_qty.typical / 100);
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 cur_deduct_qty.qty_unit_id_denominator,
                                                                 vn_item_qty) *
                            cur_deduct_qty.typical;
        vn_deduct_qty    := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.qty_unit_id_numerator,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 vn_converted_qty);
      
      end if;
      vn_deduct_total_qty := vn_deduct_total_qty + vn_deduct_qty;
    
    end loop;
    return vn_deduct_total_qty;
  end;
  function fn_get_elmt_assay_content_qty(pc_element_id      varchar2,
                                         pc_assay_header_id varchar2,
                                         pn_qty             number,
                                         pc_qty_unit_id     varchar2)
    return number is
    cursor cur_element is
      select pqca.element_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             ash.ash_id,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id,
             -- asm.dry_weight,
             (case
               when ash.ash_id =
                    (select ash_new.pricing_assay_ash_id
                       from ash_assay_header ash_new
                      where ash_new.assay_type = 'Provisional Assay'
                        and ash_new.is_active = 'Y'
                        and ash_new.internal_grd_ref_no =
                            ash.internal_grd_ref_no) then
                pn_qty
               when ash.ash_id =
                    (select ash_new.ash_id
                       from ash_assay_header ash_new
                      where ash_new.assay_type = 'Shipment Assay'
                        and ash_new.is_active = 'Y'
                        and ash_new.internal_grd_ref_no =
                            ash.internal_grd_ref_no) then
                pn_qty
               else
                asm.dry_weight
             end) dry_weight,
             pcpd.product_id,
             pcpq.unit_of_measure contract_unit_of_measure
        from ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm,
             pcpd_pc_product_definition  pcpd,
             pcpq_pc_product_quality     pcpq
       where ash.ash_id = pc_assay_header_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pqca.element_id = pc_element_id
         and ash.internal_contract_ref_no=pcpd.internal_contract_ref_no
         and pcpd.pcpd_id = pcpq.pcpd_id
         and pcpd.input_output = 'Input'
         and ash.is_active = 'Y'
         and asm.is_active = 'Y'
         and pqca.is_active = 'Y'
         and aml.is_active = 'Y'
         and rm.is_active = 'Y'
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y';
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
    vn_ele_assay_value number :=0;   
  begin
    for cur_element_rows in cur_element
    loop
      vn_deduct_qty := 0;      
      vn_item_qty := nvl(cur_element_rows.dry_weight,pn_qty);
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = pc_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := pc_qty_unit_id;
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
        vn_element_qty   := vn_converted_qty * cur_element_rows.typical;
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      end if;     
      vn_ele_assay_value :=vn_ele_assay_value+vn_element_qty;     
    end loop;
    return(vn_ele_assay_value);
  end;
end; 
/
create or replace view v_supplier_invoice_details as
select tt.supplier_invoive_no,
       tt.supplier_gmr_ref_no,
       tt.supplier_internal_gmr_ref_no,
       tt.supplier_invoice_date,
       tt.supplier_contract_ref_no,
       tt.supplier_id,
       tt.supplier,
       tt.corporate_id,
       tt.corporate_name,
       tt.charges_to_supplier,
       sum(tt.charges_to_supplier) over(partition by tt.supplier_invoive_no order by tt.supplier_invoive_no) net_charges_to_supplier,
       tt.invoice_currency_id,
       tt.invoice_currency_code,
       tt.add_charges_to_supplier
  from (select test.supplier_invoive_no,
               test.supplier_gmr_ref_no,
               test.supplier_internal_gmr_ref_no,
               test.supplier_invoice_date,
               test.supplier_contract_ref_no,
               test.supplier_id,
               test.supplier,
               test.corporate_id,
               test.corporate_name,
               sum(test.tc_amount + test.rc_amount + test.penality_amount) charges_to_supplier,
               test.invoice_currency_id,
               test.invoice_currency_code,
               nvl(iss.total_other_charge_amount, 0) add_charges_to_supplier
          from (select pcm.contract_ref_no supplier_contract_ref_no,
                       gmr.gmr_ref_no supplier_gmr_ref_no,
                       gmr.internal_gmr_ref_no supplier_internal_gmr_ref_no,
                       grd.internal_grd_ref_no,
                       phd.profileid supplier_id,
                       phd.companyname supplier,
                       gmr.corporate_id,
                       akc.corporate_name,
                       nvl(intc.tc_amount, 0) tc_amount,
                       nvl(inrc.rc_amount, 0) rc_amount,
                       nvl(iepd.penality_amount, 0) penality_amount,
                       iss.invoice_ref_no supplier_invoive_no,
                       iss.invoice_issue_date supplier_invoice_date,
                       iid.invoice_currency_id,
                       cm.cur_code invoice_currency_code,
                       iss.internal_invoice_ref_no
                  from pcm_physical_contract_main pcm,
                       phd_profileheaderdetails phd,
                       gmr_goods_movement_record gmr,
                       grd_goods_record_detail grd,
                       iid_invoicable_item_details iid,
                       is_invoice_summary iss,
                       (select intc.grd_id,
                               intc.internal_invoice_ref_no,
                               sum(intc.tcharges_amount) tc_amount
                          from intc_inv_treatment_charges intc
                         group by intc.grd_id,
                                  intc.internal_invoice_ref_no) intc,
                       (select inrc.grd_id,
                               inrc.internal_invoice_ref_no,
                               sum(inrc.rcharges_amount) rc_amount
                          from inrc_inv_refining_charges inrc
                         group by inrc.grd_id,
                                  inrc.internal_invoice_ref_no) inrc,
                       (select iepd.stock_id,
                               iepd.internal_invoice_ref_no,
                               sum(iepd.element_penalty_amount) penality_amount
                          from iepd_inv_epenalty_details iepd
                         group by iepd.stock_id,
                                  iepd.internal_invoice_ref_no) iepd,
                       v_bi_latest_gmr_invoice invoice,
                    --   ii_invoicable_item ii,
                       cm_currency_master cm,
                       ak_corporate      akc
                 where pcm.internal_contract_ref_no =
                       gmr.internal_contract_ref_no
                   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                   and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = iid.stock_id
                   and iid.internal_invoice_ref_no =  iss.internal_invoice_ref_no
                   and iss.is_active = 'Y'
                   and pcm.is_active = 'Y'
                   and gmr.is_deleted = 'N'
                   and grd.is_deleted = 'N'
               --    and iid.invoicable_item_id = ii.invoicable_item_id
                   and pcm.is_tolling_contract = 'Y'
                   and pcm.purchase_sales = 'P'
                   and iid.stock_id = intc.grd_id(+)
                   and iid.internal_invoice_ref_no =
                       intc.internal_invoice_ref_no(+)
                   and iid.stock_id = inrc.grd_id(+)
                   and iid.internal_invoice_ref_no =
                       inrc.internal_invoice_ref_no(+)
                   and iid.stock_id = iepd.stock_id(+)
                   and iid.internal_invoice_ref_no =
                       iepd.internal_invoice_ref_no(+)
                   and gmr.internal_gmr_ref_no = invoice.internal_gmr_ref_no
                   and iid.invoice_currency_id = cm.cur_id
                   and pcm.cp_id = phd.profileid
                   and gmr.corporate_id=akc.corporate_id) test,
               is_invoice_summary iss
         where test.internal_invoice_ref_no = iss.internal_invoice_ref_no(+)
         group by test.supplier_invoive_no,
                  test.supplier_invoice_date,
                  test.supplier_contract_ref_no,
                  test.supplier_id,
                  test.supplier,
                  test.corporate_id,
                  test.corporate_name,
                  test.invoice_currency_id,
                  test.invoice_currency_code,
                  test.supplier_gmr_ref_no,
                  test.supplier_internal_gmr_ref_no,
                  iss.total_other_charge_amount) tt ;
				  
create or replace view v_in_process_stock as
select ips_temp.corporate_id,
       ips_temp.internal_grd_ref_no,
       ips_temp.stock_ref_no,
       ips_temp.internal_gmr_ref_no,
       ips_temp.gmr_ref_no,
       ips_temp.action_id,
       (case
         when ips_temp.action_id = 'RECORD_OUT_PUT_TOLLING' then
          'Receive Material'
         when ips_temp.action_id = 'CREATE_FREE_MATERIAL' then
          'Capture Yield'
         else
          ips_temp.action_name
       end) action_name,
       ips_temp.internal_action_ref_no,
       ips_temp.activity_date,
       ips_temp.action_ref_no,
       ips_temp.internal_contract_item_ref_no,
       ips_temp.contract_item_ref_no,
       ips_temp.pcdi_id,
       ips_temp.delivery_item_ref_no,
       ips_temp.internal_contract_ref_no,
       ips_temp.contract_ref_no,
       ips_temp.smelter_cp_id,
       ips_temp.smelter_cp_name,
       ips_temp.product_id,
       ips_temp.product_name,
       ips_temp.quality_id,
       ips_temp.quality_name,
       ips_temp.element_id,
       ips_temp.element_name,
       ips_temp.warehouse_profile_id,
       ips_temp.warehouse,
       ips_temp.shed_id,
       ips_temp.shed_name,
       ips_temp.stock_qty,
       ips_temp.qty_unit,
       ips_temp.qty_unit_id,
       ips_temp.payable_returnable_type,
       (case
         when ips_temp.tolling_stock_type = 'RM In Process Stock' then
          'Receive Material Stock'
         when ips_temp.tolling_stock_type = 'MFT In Process Stock' then
          'In Process Stock'
       /* when ips_temp.tolling_stock_type = 'Free Material Stock' then
                                                           'Free Metal Stock'*/
         when ips_temp.tolling_stock_type = 'Delta MFT IP Stock' then
          'Delta IP Stock'
         else
          ips_temp.tolling_stock_type
       end) tolling_stock_type,
       ips_temp.assay_content_qty,
       ips_temp.is_pass_through,
       ips_temp.element_by_product,
       ips_temp.input_stock_ref_no
  from (select gmr.corporate_id,
               grd.internal_grd_ref_no,
               grd.internal_stock_ref_no stock_ref_no,
               gmr.internal_gmr_ref_no,
               gmr.gmr_ref_no,
               axs.action_id,
               axm.action_name action_name,
               axs.internal_action_ref_no,
               axs.eff_date activity_date,
               axs.action_ref_no,
               pci.internal_contract_item_ref_no,
               pci.contract_item_ref_no,
               pci.pcdi_id pcdi_id,
               pci.delivery_item_ref_no delivery_item_ref_no,
               pci.internal_contract_ref_no,
               pci.contract_ref_no,
               wrd.smelter_cp_id smelter_cp_id,
               phd.companyname smelter_cp_name,
               grd.product_id,
               prdm.product_desc product_name,
               qat.quality_id,
               qat.quality_name,
               grd.element_id,
               aml.attribute_name element_name,
               grd.warehouse_profile_id,
               shm.companyname as warehouse,
               grd.shed_id,
               shm.shed_name,
               nvl(grd.qty, 0) as stock_qty,
               pkg_general.f_get_quantity_unit(grd.qty_unit_id) as qty_unit,
               grd.qty_unit_id as qty_unit_id,
               grd.payable_returnable_type,
               grd.tolling_stock_type,
               grd.assay_content as assay_content_qty,
               gmr.is_pass_through is_pass_through,
               (aml.attribute_name || '/' || pdm_consc.product_desc) element_by_product,
               grd_cloned.internal_stock_ref_no input_stock_ref_no
          from grd_goods_record_detail      grd,
               grd_goods_record_detail      grd_cloned,
               pdm_productmaster            pdm_consc,
               gmr_goods_movement_record    gmr,
               gam_gmr_action_mapping       gam,
               axs_action_summary           axs,
               axm_action_master            axm,
               wrd_warehouse_receipt_detail wrd,
               v_pci                        pci,
               v_shm_shed_master            shm,
               pdm_productmaster            prdm,
               qat_quality_attributes       qat,
               aml_attribute_master_list    aml,
               phd_profileheaderdetails     phd
         where grd.is_deleted = 'N'
           and grd.status = 'Active'
           and grd.tolling_stock_type in
               ('MFT In Process Stock', 'Delta MFT IP Stock')
           and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and wrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and pci.internal_contract_item_ref_no =
               grd.internal_contract_item_ref_no
           and shm.profile_id = grd.warehouse_profile_id
           and shm.shed_id = grd.shed_id
           and prdm.product_id = grd.product_id
           and qat.quality_id = grd.quality_id
           and aml.attribute_id = grd.element_id
           and phd.profileid = wrd.smelter_cp_id
           and gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
           and gam.internal_action_ref_no(+) =
               gmr.gmr_first_int_action_ref_no
           and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
           and axs.status(+) = 'Active'
           and axm.action_id(+) = axs.action_id
           and grd_cloned.internal_grd_ref_no =
               grd.parent_internal_grd_ref_no
           and grd_cloned.is_deleted = 'N'
           and grd_cloned.status = 'Active'
           and pdm_consc.product_id = grd_cloned.product_id
        
        union all
        
        select gmr.corporate_id,
               grd.internal_grd_ref_no,
               grd.internal_stock_ref_no stock_ref_no,
               gmr.internal_gmr_ref_no,
               gmr.gmr_ref_no,
               axs.action_id,
               axm.action_name action_name,
               axs.internal_action_ref_no,
               axs.eff_date activity_date,
               axs.action_ref_no,
               pci.internal_contract_item_ref_no,
               pci.contract_item_ref_no,
               pci.pcdi_id pcdi_id,
               pci.delivery_item_ref_no delivery_item_ref_no,
               pci.internal_contract_ref_no,
               pci.contract_ref_no,
               wrd.smelter_cp_id smelter_cp_id,
               phd.companyname smelter_cp_name,
               grd.product_id,
               prdm.product_desc product_name,
               qat.quality_id,
               qat.quality_name,
               grd.element_id,
               aml.attribute_name element_name,
               grd.warehouse_profile_id,
               shm.companyname as warehouse,
               grd.shed_id,
               shm.shed_name,
               nvl(grd.qty, 0) as stock_qty,
               pkg_general.f_get_quantity_unit(grd.qty_unit_id) as qty_unit,
               grd.qty_unit_id as qty_unit_id,
               grd.payable_returnable_type,
               grd.tolling_stock_type,
               grd.assay_content as assay_content_qty,
               gmr.is_pass_through is_pass_through,
               (aml.attribute_name || '/' || pdm_parent.product_desc) element_by_product,
               grd_parent.internal_stock_ref_no input_stock_ref_no
        
          from grd_goods_record_detail      grd,
               grd_goods_record_detail      grd_parent,
               pdm_productmaster            pdm_parent,
               gmr_goods_movement_record    gmr,
               gam_gmr_action_mapping       gam,
               axs_action_summary           axs,
               axm_action_master            axm,
               wrd_warehouse_receipt_detail wrd,
               v_pci                        pci,
               v_shm_shed_master            shm,
               pdm_productmaster            prdm,
               qat_quality_attributes       qat,
               aml_attribute_master_list    aml,
               phd_profileheaderdetails     phd
         where grd.is_deleted = 'N'
           and grd.status = 'Active'
           and grd.tolling_stock_type = 'RM In Process Stock'
           and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and wrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and pci.internal_contract_item_ref_no(+) =
               grd.internal_contract_item_ref_no
           and shm.profile_id = grd.warehouse_profile_id
           and shm.shed_id = grd.shed_id
           and prdm.product_id = grd.product_id
           and qat.quality_id = grd.quality_id
           and aml.attribute_id(+) = grd.element_id
           and phd.profileid = wrd.smelter_cp_id
           and gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
           and gam.internal_action_ref_no(+) =
               gmr.gmr_first_int_action_ref_no
           and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
           and axs.status(+) = 'Active'
           and axm.action_id(+) = axs.action_id
           and grd_parent.internal_grd_ref_no(+) =
               grd.parent_internal_grd_ref_no
           and grd_parent.is_deleted(+) = 'N'
           and grd_parent.status(+) = 'Active'
           and pdm_parent.product_id(+) = grd_parent.product_id
        
        union all
        select agmr.corporate_id,
               agrd.internal_grd_ref_no,
               agrd.internal_stock_ref_no stock_ref_no,
               agmr.internal_gmr_ref_no,
               agmr.gmr_ref_no,
               axs.action_id,
               axm.action_name action_name,
               axs.internal_action_ref_no,
               axs.eff_date activity_date,
               axs.action_ref_no,
               pci.internal_contract_item_ref_no,
               pci.contract_item_ref_no,
               pci.pcdi_id pcdi_id,
               pci.delivery_item_ref_no delivery_item_ref_no,
               pci.internal_contract_ref_no,
               pci.contract_ref_no,
               wrd.smelter_cp_id smelter_cp_id,
               phd.companyname smelter_cp_name,
               agrd.product_id,
               prdm.product_desc product_name,
               qat.quality_id,
               qat.quality_name,
               agrd.element_id,
               aml.attribute_name element_name,
               agrd.warehouse_profile_id,
               shm.companyname as warehouse,
               agrd.shed_id,
               shm.shed_name,
               nvl(agrd.qty, 0) as stock_qty,
               pkg_general.f_get_quantity_unit(agrd.qty_unit_id) as qty_unit,
               agrd.qty_unit_id as qty_unit_id,
               agrd.payable_returnable_type,
               agrd.tolling_stock_type,
               agrd.assay_content as assay_content_qty,
               gmr.is_pass_through is_pass_through,
               (aml.attribute_name || '/' || pdm_consc.product_desc) element_by_product,
               agrd_cloned.internal_stock_ref_no input_stock_ref_no
          from agrd_action_grd              agrd,
               agrd_action_grd              agrd_fm,
               agrd_action_grd              agrd_cloned,
               pdm_productmaster            pdm_consc,
               ypd_yield_pct_detail         ypd,
               gmr_goods_movement_record    gmr,
               agmr_action_gmr              agmr,
               axs_action_summary           axs,
               axm_action_master            axm,
               wrd_warehouse_receipt_detail wrd,
               v_pci                        pci,
               v_shm_shed_master            shm,
               pdm_productmaster            prdm,
               qat_quality_attributes       qat,
               aml_attribute_master_list    aml,
               phd_profileheaderdetails     phd
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and agrd.tolling_stock_type in
               ('Free Metal IP Stock', 'Delta FM IP Stock')
           and agmr.gmr_latest_action_action_id = 'CREATE_FREE_MATERIAL'
           and agmr.is_deleted = 'N'
           and agmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no
           and agmr.action_no = agrd.action_no
           and agrd_fm.tolling_stock_type = 'Free Material Stock'
           and agrd_fm.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agrd_fm.action_no = agmr.action_no
           and agrd_fm.is_deleted = 'N'
           and agrd_fm.status = 'Active'
           and ypd.internal_gmr_ref_no = agrd.internal_gmr_ref_no
           and ypd.action_no = agrd.action_no
           and ypd.element_id = agrd.element_id
           and ypd.is_active = 'Y'
           and agrd.is_deleted = 'N'
           and agrd.status = 'Active'
           and wrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and pci.internal_contract_item_ref_no =
               agrd.internal_contract_item_ref_no
           and shm.profile_id = agrd.warehouse_profile_id
           and shm.shed_id = agrd.shed_id
           and prdm.product_id = agrd.product_id
           and qat.quality_id = agrd.quality_id
           and aml.attribute_id = agrd.element_id
           and phd.profileid = wrd.smelter_cp_id
           and axs.internal_action_ref_no = ypd.internal_action_ref_no
           and axs.status = 'Active'
           and axm.action_id = axs.action_id
           and agrd_cloned.internal_grd_ref_no =
               agrd_fm.parent_internal_grd_ref_no
           and agrd_fm.internal_grd_ref_no = agrd.parent_internal_grd_ref_no
           and agrd_cloned.is_deleted = 'N'
           and agrd_cloned.status = 'Active'
           and pdm_consc.product_id = agrd_cloned.product_id
        
        /* union all
                                        
                  select sbs.corporate_id,
                  sbs.sbs_id internal_grd_ref_no,
                  '' stock_ref_no,
                  '' internal_gmr_ref_no,
                  '' gmr_ref_no,
                  '' action_id,
                  '' action_name,
                  '' internal_action_ref_no,
                  sbs.activity_date,
                  '' action_ref_no,
                  '' internal_contract_item_ref_no,
                  '' contract_item_ref_no,
                  '' pcdi_id,
                  '' delivery_item_ref_no,
                  '' internal_contract_ref_no,
                  '' contract_ref_no,
                  sbs.smelter_cp_id smelter_cp_id,
                  phd.companyname smelter_cp_name,
                  sbs.product_id,
                  pdm.product_desc product_name,
                  sbs.quality_id,
                  qat.quality_name,
                  sbs.element_id,
                  aml.attribute_name element_name,
                  sbs.warehouse_profile_id,
                  shm.companyname as warehouse,
                  sbs.shed_id,
                  shm.shed_name,
                  nvl(sbs.qty, 0) as stock_qty,
                  pkg_general.f_get_quantity_unit(sbs.qty_unit_id) as qty_unit,
                  sbs.qty_unit_id as qty_unit_id,
                  'Returnable' payable_returnable_type,
                  'Base Stock' tolling_stock_type,
                  '' assay_content_qty,
                  '' is_pass_through,
                  '' element_by_product,
                  '' input_stock_ref_no
                  from sbs_smelter_base_stock    sbs,
                  pdm_productmaster         pdm,
                  qat_quality_attributes    qat,
                  aml_attribute_master_list aml,
                  phd_profileheaderdetails  phd,
                  v_shm_shed_master         shm
                  where pdm.product_id = sbs.product_id
                  and qat.quality_id = sbs.quality_id
                  and phd.profileid = sbs.smelter_cp_id
                  and aml.attribute_id(+) = sbs.element_id
                  and sbs.is_active = 'Y'
                  and shm.profile_id = sbs.warehouse_profile_id
                  and shm.shed_id = sbs.shed_id*/
        ) ips_temp;
DROP VIEW V_PCI;


CREATE OR REPLACE FORCE VIEW v_pci (internal_contract_item_ref_no,
                                                    internal_contract_ref_no,
                                                    contract_ref_no,
                                                    item_no,
                                                    contract_item_ref_no,
                                                    strategy_id,
                                                    contract_type,
                                                    partnership_type,
                                                    corporate_id,
                                                    corporate_name,
                                                    cp_id,
                                                    cp_name,
                                                    cp_person_in_charge_id,
                                                    cp_contract_ref_no,
                                                    our_person_in_charge_id,
                                                    issue_date,
                                                    trade_type,
                                                    item_status,
                                                    spe_settlement_status,
                                                    is_active,
                                                    invoice_currency_id,
                                                    invoice_currency,
                                                    product_id,
                                                    product_name,
                                                    product_specs,
                                                    quality_id,
                                                    quality_name,
                                                    origin_name,
                                                    phy_attribute_group_no,
                                                    assay_header_id,
                                                    customs_id,
                                                    duty_status_id,
                                                    tax_status_id,
                                                    delivery_period_type,
                                                    delivery_from_date,
                                                    delivery_to_date,
                                                    delivery_from_month,
                                                    delivery_from_year,
                                                    delivery_to_month,
                                                    delivery_to_year,
                                                    pcpq_id,
                                                    pcdi_id,
                                                    price_allocation_method,
                                                    pcdb_id,
                                                    inco_term_id,
                                                    incoterm,
                                                    warehouse_id,
                                                    warehouse_shed_id,
                                                    valuation_country_id,
                                                    valuation_state_id,
                                                    valuation_city_id,
                                                    valuation_country,
                                                    valuation_state,
                                                    valuation_city,
                                                    payment_term_id,
                                                    payment_term,
                                                    terms,
                                                    origination_city_id,
                                                    origination_state_id,
                                                    origination_country_id,
                                                    destination_city_id,
                                                    destination_state_id,
                                                    destination_country_id,
                                                    pricing,
                                                    item_qty,
                                                    item_qty_unit_id,
                                                    item_qty_unit,
                                                    qty_basis,
                                                    open_qty,
                                                    gmr_qty,
                                                    shipped_qty,
                                                    warehouse_qty,
                                                    title_transferred_qty,
                                                    alloc_qty,
                                                    unallocated_qty,
                                                    fulfilled_qty,
                                                    prov_invoiced_qty,
                                                    final_invoiced_qty,
                                                    fulfillment_status,
                                                    allocation_status,
                                                    delivery_item_ref_no,
                                                    quota_month,
                                                    LOCATION,
                                                    incoterm_location,
                                                    qp_period,
                                                    profit_center_id,
                                                    profit_center_name,
                                                    tolerance_type,
                                                    tolerance_min,
                                                    tolerance_max,
                                                    tolerance_unit_id,
                                                    min_tolerance_item_qty,
                                                    max_tolerance_item_qty,
                                                    strategy_name,
                                                    trader,
                                                    trader_id,
                                                    basis_type,
                                                    is_tolling_contract,
                                                    middle_no,
                                                    del_distribution_item_no,
                                                    price_option_call_off_status,
                                                    delivery_item_no,
                                                    is_pass_through,
                                                    fulfillment_date,
                                                    approval_status,
                                                    incoterm_country_id,
                                                    incoterm_state_id,
                                                    incoterm_city_id,
                                                    incoterm_country,
                                                    incoterm_state,
                                                    incoterm_city,
                                                    IS_COMMERCIAL_FEE_APPLIED,
                                                    is_free_metal_applicable
                                                   )
AS
   SELECT pci.internal_contract_item_ref_no AS internal_contract_item_ref_no,
          pcm.internal_contract_ref_no AS internal_contract_ref_no,
          pcm.contract_ref_no AS contract_ref_no,
          CAST (pci.del_distribution_item_no AS VARCHAR2 (5)) AS item_no,
          (   pcm.contract_ref_no
           || ' '
           || 'Item No.'
           || ' '
           || pci.del_distribution_item_no
          ) contract_item_ref_no,
          pcpd.strategy_id,
          CAST (pcm.purchase_sales AS VARCHAR2 (1)) AS contract_type,
          pcm.partnership_type partnership_type,
          pcm.corporate_id AS corporate_id,
          akc.corporate_name AS corporate_name, pcm.cp_id AS cp_id,
          phd.companyname AS cp_name,
          pcm.cp_person_in_charge_id cp_person_in_charge_id,
          pcm.cp_contract_ref_no cp_contract_ref_no,
          pcm.our_person_in_charge_id our_person_in_charge_id,
          pcm.issue_date AS issue_date,
          NVL (pcm.contract_type, 'Normal') trade_type,
          pci.item_status AS item_status, pci.spe_settlement_status,
          CAST (pci.is_active AS VARCHAR2 (1)) is_active,
          pcm.invoice_currency_id AS invoice_currency_id,
          cm.cur_code invoice_currency, pcpd.product_id AS product_id,
          pdm.product_desc AS product_name, qat.long_desc product_specs,
          pcpq.quality_template_id AS quality_id,
          qat.quality_name AS quality_name, orm.origin_name AS origin_name,
          pcpq.phy_attribute_group_no AS phy_attribute_group_no,
          pcpq.assay_header_id AS assay_header_id, pcdb.customs customs_id,
          pcdb.duty_status duty_status_id, pcdb.tax_status tax_status_id,
          pci.delivery_period_type AS delivery_period_type,
          pci.delivery_from_date AS delivery_from_date,
          pci.delivery_to_date AS delivery_to_date,
          pci.delivery_from_month AS delivery_from_month,
          pci.delivery_from_year AS delivery_from_year,
          pci.delivery_to_month AS delivery_to_month,
          pci.delivery_to_year AS delivery_to_year, pci.pcpq_id AS pcpq_id,
          pci.pcdi_id AS pcdi_id, pcdi.price_allocation_method,
          pci.pcdb_id AS pcdb_id, pcdb.inco_term_id AS inco_term_id,
          itm.incoterm AS incoterm, pcdb.warehouse_id AS warehouse_id,
          pcdb.warehouse_shed_id AS warehouse_shed_id,
          pci.m2m_country_id AS valuation_country_id,
          pci.m2m_state_id AS valuation_state_id,
          pci.m2m_city_id AS valuation_city_id,
          cym_valuation.country_name AS valuation_country,
          sm_valuation.state_name AS valuation_state,
          cim_valuation.city_name AS valuation_city,
          pym.payment_term_id AS payment_term_id,
          pym.payment_term AS payment_term,
          (   itm.incoterm
           || ', '
           || cim.city_name
           || ', '
           || cym.country_name
           || ', '
           || pym.payment_term
          ) terms,
          CAST ('' AS VARCHAR2 (1)) AS origination_city_id,
          CAST ('' AS VARCHAR2 (1)) AS origination_state_id,
          CAST ('' AS VARCHAR2 (1)) AS origination_country_id,
          CAST ('' AS VARCHAR2 (1)) AS destination_city_id,
          CAST ('' AS VARCHAR2 (1)) AS destination_state_id,
          CAST ('' AS VARCHAR2 (1)) AS destination_country_id,
          CAST ('Pricing' AS VARCHAR2 (20)) AS pricing, pci.item_qty,
          pci.item_qty_unit_id, qum.qty_unit AS item_qty_unit,
          pcpq.unit_of_measure AS qty_basis, ciqs.open_qty AS open_qty,
          ciqs.gmr_qty AS gmr_qty, ciqs.shipped_qty AS shipped_qty,
          0 AS warehouse_qty,
          ciqs.title_transferred_qty AS title_transferred_qty,
          ciqs.allocated_qty AS alloc_qty,
          ciqs.unallocated_qty AS unallocated_qty,
          ciqs.fulfilled_qty AS fulfilled_qty,
          ciqs.prov_invoiced_qty AS prov_invoiced_qty,
          ciqs.final_invoiced_qty AS final_invoiced_qty,
          CAST ('Not Fulfilled' AS VARCHAR2 (20)) AS fulfillment_status,
          (CASE
              WHEN ciqs.allocated_qty > 0
                 THEN 'Allocated'
              ELSE 'Un-allocated'
           END
          ) AS allocation_status,
          (pcm.contract_ref_no || '-' || pcdi.delivery_item_no
          ) AS delivery_item_ref_no,
          (CASE
              WHEN pci.delivery_period_type = 'Month'
                 THEN CASE
                        WHEN pci.delivery_from_month = pci.delivery_to_month
                        AND pci.delivery_from_year = pci.delivery_to_year
                           THEN    pci.delivery_from_month
                                || ' '
                                || pci.delivery_from_year
                        ELSE    pci.delivery_from_month
                             || ' '
                             || pci.delivery_from_year
                             || ' To '
                             || pci.delivery_to_month
                             || ' '
                             || pci.delivery_to_year
                     END
              WHEN pci.delivery_period_type = 'Date'
                 THEN CASE
                        WHEN TO_CHAR (pci.delivery_from_date, 'dd-Mon-YYYY') =
                                 TO_CHAR (pci.delivery_to_date, 'dd-Mon-YYYY')
                           THEN TO_CHAR (pci.delivery_from_date,
                                         'dd-Mon-YYYY')
                        ELSE    TO_CHAR (pci.delivery_from_date,
                                         'dd-Mon-YYYY')
                             || ' To '
                             || TO_CHAR (pci.delivery_to_date, 'dd-Mon-YYYY')
                     END
              ELSE '-'
           END
          ) quota_month,
          (NVL (cim.city_name, '') || cym.country_name) AS LOCATION,
          (itm.incoterm || ', ' || cim.city_name || ', ' || cym.country_name
          ) AS incoterm_location,
          CAST ('QP PERIOD' AS VARCHAR2 (20)) qp_period,
          pcpd.profit_center_id AS profit_center_id,
          cpc.profit_center_name AS profit_center_name,
          NVL (pcdi.tolerance_type, 'Approx') tolerance_type,
          NVL (pcdi.min_tolerance, 0) tolerance_min,
          NVL (pcdi.max_tolerance, 0) tolerance_max, pcdi.tolerance_unit_id,
          (CASE
              WHEN pcdi.tolerance_type = 'Percentage'
                 THEN pci.item_qty - pci.item_qty
                                     * (pcdi.min_tolerance / 100)
              ELSE pci.item_qty
           END
          ) min_tolerance_item_qty,
          (CASE
              WHEN pcdi.tolerance_type = 'Percentage'
                 THEN pci.item_qty + pci.item_qty
                                     * (pcdi.max_tolerance / 100)
              ELSE pci.item_qty
           END
          ) max_tolerance_item_qty,
          css.strategy_name, (gab.firstname || ' ' || gab.lastname
                             ) AS trader, pcm.trader_id AS trader_id,
          pcdi.basis_type,
          CAST
              (pcm.is_tolling_contract AS VARCHAR2 (1))
                                                       AS is_tolling_contract,
          pcm.middle_no, pci.del_distribution_item_no,
          pcdi.price_option_call_off_status, pcdi.delivery_item_no,
          DECODE (pcmte.is_pass_through, 'Y', 'Y', 'N', 'N') is_pass_through,
          pci.fulfillment_date AS fulfillment_date, pcm.approval_status,
          cym.country_id AS incoterm_country_id,
          sm.state_id AS incoterm_state_id, cim.city_id AS incoterm_city_id,
          cym.country_name AS incoterm_country,
          sm.state_name AS incoterm_state, cim.city_name AS incoterm_city,
          CAST(PCM.IS_COMMERCIAL_FEE_APPLIED AS VARCHAR2 (1)) As IS_COMMERCIAL_FEE_APPLIED,
          NVL(pcmte.is_free_metal_applicable, 'N') is_free_metal_applicable
     FROM pci_physical_contract_item pci,
          pcm_physical_contract_main pcm,
          pcdb_pc_delivery_basis pcdb,
          pcdi_pc_delivery_item pcdi,
          pcpd_pc_product_definition pcpd,
          pcpq_pc_product_quality pcpq,
          ciqs_contract_item_qty_status ciqs,
          phd_profileheaderdetails phd,
          itm_incoterm_master itm,
          cim_citymaster cim,
          cym_countrymaster cym,
          pdm_productmaster pdm,
          qat_quality_attributes qat,
          pym_payment_terms_master pym,
          ak_corporate akc,
          qum_quantity_unit_master qum,
          cym_countrymaster cym_valuation,
          sm_state_master sm_valuation,
          sm_state_master sm,
          cim_citymaster cim_valuation,
          cpc_corporate_profit_center cpc,
          cm_currency_master cm,
          css_corporate_strategy_setup css,
          ak_corporate_user aku,
          gab_globaladdressbook gab,
          pom_product_origin_master pom,
          orm_origin_master orm,
          pcmte_pcm_tolling_ext pcmte
    WHERE pcdb.pcdb_id = pci.pcdb_id
      AND pci.pcdi_id = pcdi.pcdi_id
      AND phd.profileid = pcm.cp_id
      AND itm.incoterm_id = pcdb.inco_term_id
      AND ciqs.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
      AND sm.state_id = pcdb.state_id
      AND pcdb.city_id = cim.city_id(+)
      AND pcdb.country_id = cym.country_id(+)
      AND pci.m2m_country_id = cym_valuation.country_id(+)
      AND pci.m2m_state_id = sm_valuation.state_id(+)
      AND pci.m2m_city_id = cim_valuation.city_id(+)
      AND pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
      AND pci.pcpq_id = pcpq.pcpq_id
      AND pym.payment_term_id(+) = pcm.payment_term_id
      AND pcm.corporate_id = akc.corporate_id
      AND pcpq.pcpq_id = pci.pcpq_id
      AND pcpd.pcpd_id = pcpq.pcpd_id
      AND qat.quality_id = pcpq.quality_template_id
      AND qat.product_origin_id = pom.product_origin_id(+)
      AND pom.origin_id = orm.origin_id(+)
      AND pdm.product_id = pcpd.product_id
      AND qum.qty_unit_id = pci.item_qty_unit_id
      AND cpc.profit_center_id = pcpd.profit_center_id
      AND pcm.invoice_currency_id = cm.cur_id
      AND css.strategy_id = pcpd.strategy_id
      AND pcm.trader_id = aku.user_id
      AND aku.gabid = gab.gabid
      AND pci.is_active = 'Y'
      AND pcm.contract_status = 'In Position'
      AND (pci.is_called_off = 'Y' OR pcdi.is_phy_optionality_present = 'N')
      AND pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+);

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
);

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
);

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(PAYABLE_QTY_DISPLAY VARCHAR2(100));

ALTER TABLE PCMTE_PCM_TOLLING_EXT
 ADD (IS_FREE_METAL_APPLICABLE  CHAR(1 CHAR));
 
 ALTER TABLE GMR_GOODS_MOVEMENT_RECORD DROP CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE;
ALTER TABLE AGMR_ACTION_GMR DROP CONSTRAINT CHK_AGMR_TOLLING_GMR_TYPE;

ALTER TABLE GRD_GOODS_RECORD_DETAIL DROP CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE;
ALTER TABLE AGRD_ACTION_GRD DROP CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE;

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD
(
CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE
 CHECK (TOLLING_GMR_TYPE IN ('None Tolling','Mark For Tolling','Received Materials','Output Process',
                                'Process Activity','Input Process','Pledge','Financial Settlement',
                                'Return Material','Free Metal Utility'))
  
);

ALTER TABLE AGMR_ACTION_GMR ADD (
  CONSTRAINT CHK_AGMR_TOLLING_GMR_TYPE
 CHECK (TOLLING_GMR_TYPE IN ('None Tolling','Mark For Tolling','Received Materials','Output Process',
                                'Process Activity','Input Process','Pledge','Financial Settlement',
                                'Return Material','Free Metal Utility'))
);


ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD
(
CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE
 CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock','Free Metal Utility Stock'))
);

ALTER TABLE AGRD_ACTION_GRD ADD
(
CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE
 CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock','Free Metal Utility Stock'))
);


ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD UTILITY_HEADER_ID VARCHAR2(15);
alter table GRD_GOODS_RECORD_DETAIL add 
( 
UTILITY_HEADER_ID varchar2(15),
CONSTRAINT FK_GRD_UTILITY_HEADER_ID FOREIGN KEY (UTILITY_HEADER_ID) REFERENCES FMUH_FREE_METAL_UTILITY_HEADER (FMUH_ID)
);
alter table GRDL_GOODS_RECORD_DETAIL_LOG add utility_header_id varchar2(15);

CREATE OR REPLACE VIEW V_PCI_NEW AS
select pci.internal_contract_item_ref_no as internal_contract_item_ref_no,
       pcm.internal_contract_ref_no as internal_contract_ref_no,
       pcm.contract_ref_no as contract_ref_no,
       cast(pci.del_distribution_item_no as varchar2(5)) as item_no,
       (pcm.contract_ref_no || ' ' || 'Item No.' || ' ' ||
       pci.del_distribution_item_no) contract_item_ref_no,
       cast(pcm.purchase_sales as varchar2(1)) as contract_type,
       pcm.partnership_type partnership_type,
       pcm.corporate_id as corporate_id,
       pcm.cp_id as cp_id,
       phd.companyname as cp_name,
       pcm.cp_person_in_charge_id cp_person_in_charge_id,
       pcm.cp_contract_ref_no cp_contract_ref_no,
       pcm.our_person_in_charge_id our_person_in_charge_id,
       pcm.issue_date as issue_date,
       nvl(pcm.contract_type, 'Normal') trade_type,
       pci.item_status as item_status,
       pci.spe_settlement_status,
       cast(pci.is_active as varchar2(1)) is_active,
       pcm.invoice_currency_id as invoice_currency_id,
       qat.long_desc product_specs,
       pcpq.quality_template_id as quality_id,
       qat.quality_name as quality_name,
       orm.origin_name as origin_name,
       pcpq.phy_attribute_group_no as phy_attribute_group_no,
       pcpq.assay_header_id as assay_header_id,
       pcdb.customs customs_id,
       pcdb.duty_status duty_status_id,
       pcdb.tax_status tax_status_id,
       pci.delivery_period_type as delivery_period_type,
       pci.delivery_from_date as delivery_from_date,
       pci.delivery_to_date as delivery_to_date,
       pci.delivery_from_month as delivery_from_month,
       pci.delivery_from_year as delivery_from_year,
       pci.delivery_to_month as delivery_to_month,
       pci.delivery_to_year as delivery_to_year,
       pci.pcpq_id as pcpq_id,
       pci.pcdi_id as pcdi_id,
       pcdi.price_allocation_method,
       pci.pcdb_id as pcdb_id,
       pcdb.inco_term_id as inco_term_id,
       pcdb.warehouse_id as warehouse_id,
       pcdb.warehouse_shed_id as warehouse_shed_id,
       pci.m2m_country_id as valuation_country_id,
       pci.m2m_state_id as valuation_state_id,
       pci.m2m_city_id as valuation_city_id,
       cym_valuation.country_name as valuation_country,
       cast('Pricing' as varchar2(20)) as pricing,
       pci.item_qty,
       pci.item_qty_unit_id,
       pcpq.unit_of_measure as qty_basis,
       cast('Not Fulfilled' as varchar2(20)) as fulfillment_status,
       (pcm.contract_ref_no || '-' || pcdi.delivery_item_no) as delivery_item_ref_no,
       cast('QP PERIOD' as varchar2(20)) qp_period,
       nvl(pcdi.tolerance_type, 'Approx') tolerance_type,
       nvl(pcdi.min_tolerance, 0) tolerance_min,
       nvl(pcdi.max_tolerance, 0) tolerance_max,
       pcdi.tolerance_unit_id,
       pcm.trader_id as trader_id,
       pcdi.basis_type,
       cast(pcm.is_tolling_contract as varchar2(1)) as is_tolling_contract,
       pcm.middle_no,
       pci.del_distribution_item_no,
       pcdi.price_option_call_off_status,
       pcdi.delivery_item_no,
       pci.fulfillment_date as fulfillment_date,
       pcm.approval_status,
       cym.country_id as incoterm_country_id,
       sm.state_id as incoterm_state_id,
       cym.country_name as incoterm_country,
       sm.state_name as incoterm_state,
       cast(pcm.is_commercial_fee_applied as varchar2(1)) as is_commercial_fee_applied
  from pci_physical_contract_item pci,
       pcm_physical_contract_main pcm,
       pcdb_pc_delivery_basis     pcdb,
       pcdi_pc_delivery_item      pcdi,
       pcpq_pc_product_quality    pcpq,
       phd_profileheaderdetails   phd,
       cym_countrymaster          cym,
       qat_quality_attributes     qat,
       cym_countrymaster          cym_valuation,
       sm_state_master            sm,
       pom_product_origin_master  pom,
       orm_origin_master          orm
 where pcdb.pcdb_id = pci.pcdb_id
   and pci.pcdi_id = pcdi.pcdi_id
   and phd.profileid = pcm.cp_id
   and sm.state_id = pcdb.state_id
   and pcdb.country_id = cym.country_id(+)
   and pci.m2m_country_id = cym_valuation.country_id(+)
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pci.pcpq_id = pcpq.pcpq_id
   and pcpq.pcpq_id = pci.pcpq_id
   and qat.quality_id = pcpq.quality_template_id
   and qat.product_origin_id = pom.product_origin_id(+)
   and pom.origin_id = orm.origin_id(+)
   and pci.is_active = 'Y'
   and pcm.contract_status = 'In Position'
   and (pci.is_called_off = 'Y' or pcdi.is_phy_optionality_present = 'N');

CREATE OR REPLACE VIEW V_LIST_OF_GMR_NEW AS
select gmr.corporate_id,
       cp.contract_ref_no contract_ref_no,
       gmr.trucking_receipt_no trucking_receipt_no,
       gmr.rail_receipt_no rail_receipt_no,
       to_char(gmr.trucking_receipt_date, 'dd-Mon-yyyy') trucking_receipt_date,
       to_char(gmr.rail_receipt_date, 'dd-Mon-yyyy') rail_receipt_date,
       axs.action_id,
       gmr.is_voyage_gmr,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       gam.action_no,
       axs.internal_action_ref_no,
       axs.eff_date activity_date,
       axs.action_ref_no activity_ref_no,
       gmr.warehouse_receipt_no warehouse_receipt_no,
       cim_origin.city_name origin_city,
       cim_origin.city_id origin_city_id,
       cym_origin.country_name origin_country,
       cym_origin.country_id origin_country_id,
       cim_des.city_name des_city,
       cym_des.country_name des_country,
       gmr.warehouse_profile_id warehouse_profile_id,
       phd_warehouse.companyname warehouse,
       gmr.shed_id shed_id,
       sld.storage_location_name shed_name,
       (case
         when gmr.is_internal_movement = 'Y' then
          (select f_string_aggregate(qat_sub.long_desc)
             from grd_goods_record_detail grd_sub,
                  qat_quality_attributes  qat_sub
            where grd_sub.internal_gmr_ref_no = gmr.internal_gmr_ref_no
              and qat_sub.quality_id = grd_sub.quality_id
              and grd_sub.is_deleted = 'N')
         else
          cp.product_specs
       end) productspec,
       nvl(nvl(gmr.current_qty, 0) - nvl(moved_out_qty, 0) -
           nvl(gmr.write_off_qty, 0),
           0) current_qty,
       gmr.qty_unit_id,
       qum.qty_unit,
       gmr.current_no_of_units,
       gmr.status_id,
       gsm.status status,
       gmr.inventory_status is_title_transfered,
       '' accrual_amt,
       '' accrual_currency,
       (select vcd.vessel_name
          from vcd_vessel_creation_detail vcd
         where vcd.vessel_id = vd.vessel_id) vessel_name,
       gam.delivered_pieces no_of_pieces,
       gam.release_ref_no release_no,
       gmr.gmr_latest_action_action_id latest_action_id,
       (select axm.action_name
          from axm_action_master axm
         where axm.action_id = gmr.gmr_latest_action_action_id) latest_action_name,
       cim_des.city_id des_city_id,
       cym_des.country_id des_country_id,
       (case
         when gmr.is_voyage_gmr = 'Y' then
          'Create Vessel Fixation'
         else
          axm.action_name
       end) first_action_name,
       axs.action_ref_no,
       cym_loading.country_name loading_country,
       pmt_loading.port_name loading_port,
       cym_discharge.country_name discharge_country,
       cym_discharge.country_id discharge_country_id,
       pmt_discharge.port_name discharge_port,
       pmt_discharge.port_id discharge_port_id,
       pmt_trans.port_name trans_port_name,
       cym_trans.country_name trans_country_name,
       phd_shipping_line.companyname shipping_line,
       phd_shipping_line.profileid shipping_line_profile_id,
       phd_controller.companyname controller,
       gmr.is_internal_movement,
       (case
         when gmr.contract_type = 'Purchase' then
          'P'
         when gmr.contract_type = 'Sales' then
          'S'
         else
          ''
       end) contract_type,
       cp.contract_party_profile_id cp_profile_id,
       cp.cp_name,
       cp.internal_contract_item_ref_no internal_contract_item_ref_nos,
       cp.contract_item_ref_no item_nos,
       nvl(gmr.tt_under_cma_qty, 0) tt_under_cma_qty,
       nvl(gmr.tt_in_qty, 0) tt_in_qty,
       nvl(gmr.tt_out_qty, 0) tt_out_qty,
       nvl(gmr.tt_none_qty, 0) tt_none_qty,
       vd.vessel_voyage_name,
       vd.booking_ref_no,
       gmr.internal_contract_ref_no,
       bl_details.bl_no bl_no,
       bl_details.bl_date bl_date,
       axs.created_date,
       (select aku_sub.login_name
          from ak_corporate_user aku_sub
         where aku_sub.user_id = axs.created_by) created_by,
       axs_last.updated_date,
       (select aku_sub.login_name
          from ak_corporate_user aku_sub
         where aku_sub.user_id = axs_last.created_by) updated_by,
       gmr.is_final_weight is_final_weight,
       gmr.is_warrant is_warrant,
       gmr.tolling_qty tolling_qty,
       cp.price_allocation_method,
       to_char(vd.eta, 'dd-Mon-yyyy') eta,
       gmr.mode_of_transport,
       gmr.wns_status wns_status
  from gmr_goods_movement_record gmr,
       gam_gmr_action_mapping gam,
       axs_action_summary axs,
       axs_action_summary axs_last,
       cim_citymaster cim_origin,
       cym_countrymaster cym_origin,
       cim_citymaster cim_des,
       cym_countrymaster cym_des,
       gsm_gmr_stauts_master gsm,
       qum_quantity_unit_master qum,
       axm_action_master axm,
       pmt_portmaster pmt_loading,
       cym_countrymaster cym_loading,
       pmt_portmaster pmt_discharge,
       cym_countrymaster cym_discharge,
       pmt_portmaster pmt_trans,
       cym_countrymaster cym_trans,
       phd_profileheaderdetails phd_shipping_line,
       phd_profileheaderdetails phd_controller,
       phd_profileheaderdetails phd_warehouse,
       sld_storage_location_detail sld,
       vd_voyage_detail vd,
       (select gcim.internal_gmr_ref_no internal_gmr_ref_no,
               f_string_aggregate(pci.internal_contract_ref_no) internal_contract_ref_no,
               f_string_aggregate(pci.contract_ref_no) contract_ref_no,
               f_string_aggregate(pci.cp_id) contract_party_profile_id,
               f_string_aggregate(pci.cp_name) as cp_name,
               f_string_aggregate(pci.internal_contract_item_ref_no) internal_contract_item_ref_no,
               f_string_aggregate(pci.contract_item_ref_no) contract_item_ref_no,
               f_string_aggregate(pci.product_specs) product_specs,
               f_string_aggregate(pci.price_allocation_method) as price_allocation_method
          from v_pci_new                      pci,
               gcim_gmr_contract_item_mapping gcim
         where pci.internal_contract_item_ref_no =
               gcim.internal_contract_item_ref_no
         group by gcim.internal_gmr_ref_no) cp,
       (select sd.internal_gmr_ref_no,
               sd.bl_no bl_no,
               sd.bl_date bl_date
          from sd_shipment_detail sd) bl_details
 where gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
   and gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
   and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
   and axs.status(+) = 'Active'
   and axm.action_id(+) = axs.action_id
   and gmr.is_deleted = 'N'
   and gmr.status_id = gsm.status_id
   and gmr.qty_unit_id = qum.qty_unit_id
   and gmr.origin_city_id = cim_origin.city_id(+)
   and cim_origin.country_id = cym_origin.country_id(+)
   and gmr.destination_city_id = cim_des.city_id(+)
   and cim_des.country_id = cym_des.country_id(+)
   and gmr.loading_port_id = pmt_loading.port_id(+)
   and gmr.loading_country_id = cym_loading.country_id(+)
   and gmr.discharge_port_id = pmt_discharge.port_id(+)
   and gmr.discharge_country_id = cym_discharge.country_id(+)
   and gmr.trans_port_id = pmt_trans.port_id(+)
   and gmr.trans_country_id = cym_trans.country_id(+)
   and gmr.shipping_line_profile_id = phd_shipping_line.profileid(+)
   and gmr.controller_profile_id = phd_controller.profileid(+)
   and gmr.warehouse_profile_id = phd_warehouse.profileid(+)
   and gmr.shed_id = sld.storage_loc_id(+)
   and gmr.internal_gmr_ref_no = cp.internal_gmr_ref_no(+)
   and gmr.internal_gmr_ref_no = bl_details.internal_gmr_ref_no(+)
   and nvl(gmr.is_settlement_gmr, 'N') = 'N'
   and nvl(gmr.tolling_gmr_type, 'None Tolling') not in
       ('Input Process', 'Output Process', 'Mark For Tolling',
        'Received Materials', 'Pledge', 'Financial Settlement',
        'Return Material', 'Free Metal Utility')
   and gam.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and vd.status(+) = 'Active'
   and axs_last.internal_action_ref_no = gmr.internal_action_ref_no;
   
create or replace view v_list_of_gmr as
select gmr.corporate_id,
       cp.contract_ref_no contract_ref_no,
       gmr.trucking_receipt_no trucking_receipt_no,
       gmr.rail_receipt_no rail_receipt_no,
       to_char(gmr.trucking_receipt_date, 'dd-Mon-yyyy') trucking_receipt_date,
       to_char(gmr.rail_receipt_date, 'dd-Mon-yyyy') rail_receipt_date,
       axs.action_id,
       gmr.is_voyage_gmr,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       gam.action_no,
       axs.internal_action_ref_no,
       axs.eff_date activity_date,
       axs.action_ref_no activity_ref_no,
       gmr.warehouse_receipt_no warehouse_receipt_no,
       cim_origin.city_name origin_city,
       cim_origin.city_id origin_city_id,
       cym_origin.country_name origin_country,
       cym_origin.country_id origin_country_id,
       cim_des.city_name des_city,
       cym_des.country_name des_country,
       gmr.warehouse_profile_id warehouse_profile_id,
       phd_warehouse.companyname warehouse,
       gmr.shed_id shed_id,
       sld.storage_location_name shed_name,
       (case
         when gmr.is_internal_movement = 'Y' then
          (select f_string_aggregate(qat_sub.long_desc)
             from grd_goods_record_detail grd_sub,
                  qat_quality_attributes  qat_sub
            where grd_sub.internal_gmr_ref_no = gmr.internal_gmr_ref_no
              and qat_sub.quality_id = grd_sub.quality_id
              and grd_sub.is_deleted = 'N')
         else
          cp.product_specs
       end) productspec,
       nvl(nvl(gmr.current_qty, 0) - nvl(moved_out_qty, 0) -
           nvl(gmr.write_off_qty, 0),
           0) current_qty,
       gmr.qty_unit_id,
       qum.qty_unit,
       gmr.current_no_of_units,
       gmr.status_id,
       gsm.status status,
       gmr.inventory_status is_title_transfered,
       '' accrual_amt,
       '' accrual_currency,
       (select vcd.vessel_name
          from vcd_vessel_creation_detail vcd
         where vcd.vessel_id = vd.vessel_id) vessel_name,
       gam.delivered_pieces no_of_pieces,
       gam.release_ref_no release_no,
       gmr.gmr_latest_action_action_id latest_action_id,
       (select axm.action_name
          from axm_action_master axm
         where axm.action_id = gmr.gmr_latest_action_action_id) latest_action_name,
       cim_des.city_id des_city_id,
       cym_des.country_id des_country_id,
       (case
         when gmr.is_voyage_gmr = 'Y' then
          'Create Vessel Fixation'
         else
          axm.action_name
       end) first_action_name,
       axs.action_ref_no,
       cym_loading.country_name loading_country,
       pmt_loading.port_name loading_port,
       cym_discharge.country_name discharge_country,
       cym_discharge.country_id discharge_country_id,
       pmt_discharge.port_name discharge_port,
       pmt_discharge.port_id discharge_port_id,
       pmt_trans.port_name trans_port_name,
       cym_trans.country_name trans_country_name,
       phd_shipping_line.companyname shipping_line,
       phd_shipping_line.profileid shipping_line_profile_id,
       phd_controller.companyname controller,
       gmr.is_internal_movement,
       (case
         when gmr.contract_type = 'Purchase' then
          'P'
         when gmr.contract_type = 'Sales' then
          'S'
         else
          ''
       end) contract_type,
       cp.contract_party_profile_id cp_profile_id,
       cp.cp_name,
       to_number(substr(gmr.gmr_ref_no,
                        5,
                        (instr(gmr.gmr_ref_no, '-', 1, 2) -
                        instr(gmr.gmr_ref_no, '-', 1, 1) - 1))) gmr_middle_no,
       cp.contract_ref_no_middle_no conc_middle_no,
       cp.internal_contract_item_ref_no internal_contract_item_ref_nos,
       cp.contract_item_ref_no item_nos,
       nvl(gmr.tt_under_cma_qty, 0) tt_under_cma_qty,
       nvl(gmr.tt_in_qty, 0) tt_in_qty,
       nvl(gmr.tt_out_qty, 0) tt_out_qty,
       nvl(gmr.tt_none_qty, 0) tt_none_qty,
       vd.vessel_voyage_name,
       vd.booking_ref_no,
       gmr.internal_contract_ref_no,
       bl_details.bl_no bl_no,
       bl_details.bl_date bl_date,
       axs.created_date,
       (select aku_sub.login_name
          from ak_corporate_user aku_sub
         where aku_sub.user_id = axs.created_by) created_by,
       axs_last.updated_date,
       (select aku_sub.login_name
          from ak_corporate_user aku_sub
         where aku_sub.user_id = axs_last.created_by) updated_by,
       gmr.is_final_weight is_final_weight,
       gmr.is_warrant is_warrant,
       gmr.tolling_qty tolling_qty,
       cp.price_allocation_method,
       to_char(vd.eta, 'dd-Mon-yyyy') eta,
       gmr.mode_of_transport,
       gmr.wns_status wns_status,
       cp.del_distribution_item_no del_distribution_item_no
  from gmr_goods_movement_record gmr,
       gam_gmr_action_mapping gam,
       axs_action_summary axs,
       axs_action_summary axs_last,
       cim_citymaster cim_origin,
       cym_countrymaster cym_origin,
       cim_citymaster cim_des,
       cym_countrymaster cym_des,
       gsm_gmr_stauts_master gsm,
       qum_quantity_unit_master qum,
       axm_action_master axm,
       pmt_portmaster pmt_loading,
       cym_countrymaster cym_loading,
       pmt_portmaster pmt_discharge,
       cym_countrymaster cym_discharge,
       pmt_portmaster pmt_trans,
       cym_countrymaster cym_trans,
       phd_profileheaderdetails phd_shipping_line,
       phd_profileheaderdetails phd_controller,
       phd_profileheaderdetails phd_warehouse,
       sld_storage_location_detail sld,
       vd_voyage_detail vd,
       (select f_string_aggregate(gcim.internal_gmr_ref_no) internal_gmr_ref_no,
               f_string_aggregate(pci.internal_contract_ref_no) internal_contract_ref_no,
               f_string_aggregate(pci.contract_ref_no) contract_ref_no,
               f_string_aggregate(pci.middle_no) contract_ref_no_middle_no,
               f_string_aggregate(pci.cp_id) contract_party_profile_id,
               f_string_aggregate(pci.cp_name) as cp_name,
               f_string_aggregate(pci.internal_contract_item_ref_no) internal_contract_item_ref_no,
               f_string_aggregate(pci.contract_item_ref_no) contract_item_ref_no,
               f_string_aggregate(pci.product_specs) product_specs,
               f_string_aggregate(pci.price_allocation_method) as price_allocation_method,
               f_string_aggregate(pci.del_distribution_item_no) as del_distribution_item_no
          from v_pci                          pci,
               gcim_gmr_contract_item_mapping gcim
         where pci.internal_contract_item_ref_no =
               gcim.internal_contract_item_ref_no
         group by gcim.internal_gmr_ref_no) cp,
       (select sd.internal_gmr_ref_no,
               sd.bl_no bl_no,
               sd.bl_date bl_date
          from sd_shipment_detail sd) bl_details
 where gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
   and gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
   and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
   and axs.status(+) = 'Active'
   and axm.action_id(+) = axs.action_id
   and gmr.is_deleted = 'N'
   and gmr.status_id = gsm.status_id
   and gmr.qty_unit_id = qum.qty_unit_id
   and gmr.origin_city_id = cim_origin.city_id(+)
   and cim_origin.country_id = cym_origin.country_id(+)
   and gmr.destination_city_id = cim_des.city_id(+)
   and cim_des.country_id = cym_des.country_id(+)
   and gmr.loading_port_id = pmt_loading.port_id(+)
   and gmr.loading_country_id = cym_loading.country_id(+)
   and gmr.discharge_port_id = pmt_discharge.port_id(+)
   and gmr.discharge_country_id = cym_discharge.country_id(+)
   and gmr.trans_port_id = pmt_trans.port_id(+)
   and gmr.trans_country_id = cym_trans.country_id(+)
   and gmr.shipping_line_profile_id = phd_shipping_line.profileid(+)
   and gmr.controller_profile_id = phd_controller.profileid(+)
   and gmr.warehouse_profile_id = phd_warehouse.profileid(+)
   and gmr.shed_id = sld.storage_loc_id(+)
   and gmr.internal_gmr_ref_no = cp.internal_gmr_ref_no(+)
   and gmr.internal_gmr_ref_no = bl_details.internal_gmr_ref_no(+)
   and nvl(gmr.is_settlement_gmr, 'N') = 'N'
   and nvl(gmr.tolling_gmr_type, 'None Tolling') not in
       ('Input Process', 'Output Process', 'Mark For Tolling',
        'Received Materials', 'Pledge', 'Financial Settlement',
        'Return Material', 'Free Metal Utility')
   and gam.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and vd.status(+) = 'Active'
   and axs_last.internal_action_ref_no = gmr.internal_action_ref_no;
   
 create or replace view v_pci_multiple_premium as
select pcm.contract_ref_no,pcdi.pcdi_id,
       pcm.internal_contract_ref_no,
       pcpdqd.pcpq_id,
       stragg(pcqpd.premium_disc_value || ' ' || pum.price_unit_name) premium
  from pcm_physical_contract_main     pcm,
      pcdi_pc_delivery_item                   pcdi,
      pci_physical_contract_item           pci,      
      pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units        ppu,
       pum_price_unit_master          pum,
       pcpdqd_pd_quality_details      pcpdqd
 where pcm.internal_contract_ref_no=pcdi.internal_contract_ref_no
   and pcdi.pcdi_id=pci.pcdi_id
   and pci.pcpq_id=pcpdqd.pcpq_id
   and pcpdqd.pcqpd_id=pcqpd.pcqpd_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
   --and pcm.internal_contract_ref_no=163
 group by pcm.contract_ref_no, 
 pcm.internal_contract_ref_no,
 pcpdqd.pcpq_id,
 pcdi.pcdi_id;
create or replace view v_projected_price_exp_conc as
with pofh_header_data as( select *
  from pofh_price_opt_fixation_header pofh
 where pofh.internal_gmr_ref_no is null
   and pofh.qty_to_be_fixed is not null
   and pofh.is_active = 'Y'),
pfd_fixation_data as(
select pfd.pofh_id, round(sum(nvl(pfd.qty_fixed, 0)), 5) qty_fixed
  from pfd_price_fixation_details pfd
where pfd.is_active = 'Y'
 --and nvl(pfd.is_price_request,'N') ='N'
-- and  pfd.as_of_date > trunc(sysdate)
 group by pfd.pofh_id)

 --- not called off immediate pricing (any day pricing) + Excluding Event Based
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
        (case
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_from_date
         when (pfqpp.qp_pricing_period_type = 'Month') then
          to_date('01-' || pfqpp.qp_month || '-' || pfqpp.qp_year)
         when (pfqpp.qp_pricing_period_type = 'Date') then
          (pfqpp.qp_date)
         else
          qp_period_from_date
       end) qp_start_date,

       (case
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_to_date,'dd-Mon-YYYY')
         when (pfqpp.qp_pricing_period_type = 'Month') then
          to_char(last_day(to_date('01-' || pfqpp.qp_month || '-' || pfqpp.qp_year)),'dd-Mon-YYYY')
         when (pfqpp.qp_pricing_period_type = 'Date') then
          to_char(pfqpp.qp_date,'dd-Mon-YYYY')
         else
          to_char(qp_period_to_date,'dd-Mon-YYYY')
       end) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       pcbph.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       nvl(dipq.payable_qty,0) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            --pdm.base_quantity_unit,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       --pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       --qat_quality_attributes qat,
       aml_attribute_master_list aml,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,

       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pfqpp.qp_pricing_period_type <> 'Event'
   and dipq.price_option_call_off_status = 'Not Called Off'
   --and pcpd.pcpd_id = pcpq.pcpd_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   --and pcpq.quality_template_id = qat.quality_id
   --and qat.product_id = pdm.product_id
   and pcbph.element_id = aml.attribute_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = pcbph.element_id
   and pcbph.element_id = dipq.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = dipq.qty_unit_id
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   --and qat.is_active = 'Y'
   and ppfh.is_active = 'Y'
   --and pcm.contract_ref_no='SCT-105-BLD'
 union all
 ---not called off immediate pricing (average pricing) + Excluding Event Based
 select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing1' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
        (case
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_from_date
         when (pfqpp.qp_pricing_period_type = 'Month') then
          to_date('01-' || pfqpp.qp_month || '-' || pfqpp.qp_year)
         when (pfqpp.qp_pricing_period_type = 'Date') then
          (pfqpp.qp_date)
         else
          qp_period_from_date
       end) qp_start_date,

       (case
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_to_date,'dd-Mon-YYYY')
         when (pfqpp.qp_pricing_period_type = 'Month') then
          to_char(last_day(to_date('01-' || pfqpp.qp_month || '-' || pfqpp.qp_year)),'dd-Mon-YYYY')
         when (pfqpp.qp_pricing_period_type = 'Date') then
          to_char(pfqpp.qp_date,'dd-Mon-YYYY')
         else
          to_char(qp_period_to_date,'dd-Mon-YYYY')
       end) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       pcbph.element_id,
       aml.attribute_name element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       nvl(dipq.payable_qty,0) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       --pcdiqd_di_quality_details pcdiqd,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       --qat_quality_attributes qat,
       aml_attribute_master_list aml,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pfqpp.qp_pricing_period_type <> 'Event'
   and dipq.price_option_call_off_status = 'Not Called Off'
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   --and pcpd.pcpd_id = pcpq.pcpd_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   --and pcpq.quality_template_id = qat.quality_id
   --and qat.product_id = pdm.product_id
   and pcbph.element_id = aml.attribute_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbph.element_id = pcbph.element_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = dipq.qty_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and pcbph.element_id = dipq.element_id
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   --and qat.is_active = 'Y'
   and ppfh.is_active = 'Y'
   --and pcm.contract_ref_no='PCT-41-BLD'
--and ak.corporate_id = '{?CorporateID}'
union all
--- for event bases  not called off
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       dieqp.expected_qp_start_date qp_start_date,
       to_char(dieqp.expected_qp_end_date,'dd-Mon-YYYY') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       pcbph.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       nvl(dipq.payable_qty,0) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            --pdm.base_quantity_unit,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       --pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       --qat_quality_attributes qat,
       aml_attribute_master_list aml,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       di_del_item_exp_qp_details dieqp,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,

       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pfqpp.qp_pricing_period_type = 'Event'
   and dipq.price_option_call_off_status = 'Not Called Off'
   --and pcpd.pcpd_id = pcpq.pcpd_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   --and pcpq.quality_template_id = qat.quality_id
   --and qat.product_id = pdm.product_id
   and pcbph.element_id = aml.attribute_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = pcbph.element_id
   and pcdi.pcdi_id = dipq.pcdi_id
   and pcbph.element_id = dipq.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and dieqp.pcdi_id = pcdi.pcdi_id
   and dieqp.pcbpd_id = pcbpd.pcbpd_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = dipq.qty_unit_id
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pfqpp.qp_pricing_period_type = 'Event'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   --and qat.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and dieqp.is_active = 'Y'
   --and pcm.contract_ref_no='SCT-105-BLD'
 union all
 ------ for not called off event based
 select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing2' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       dieqp.expected_qp_start_date qp_start_date,
       to_char(dieqp.expected_qp_end_date,'dd-Mon-YYYY') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       pcbph.element_id,
       aml.attribute_name element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       nvl(dipq.payable_qty,0) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       --pcdiqd_di_quality_details pcdiqd,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       --qat_quality_attributes qat,
       aml_attribute_master_list aml,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
        di_del_item_exp_qp_details dieqp,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pfqpp.qp_pricing_period_type <> 'Event'
   and dipq.price_option_call_off_status = 'Not Called Off'
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   --and pcpd.pcpd_id = pcpq.pcpd_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   --and pcpq.quality_template_id = qat.quality_id
   --and qat.product_id = pdm.product_id
   and pcbph.element_id = aml.attribute_id
   and dieqp.pcdi_id = pcdi.pcdi_id
   and dieqp.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbph.element_id = pcbph.element_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = dipq.qty_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pfqpp.qp_pricing_period_type = 'Event'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and pcbph.element_id = dipq.element_id
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   --and qat.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and dieqp.is_active = 'Y'
   --and pcm.contract_ref_no='SCT-105-BLD'
-- and ak.corporate_id = '{?CorporateID}'

   union all
--Any Day Pricing Concentrate +Contract
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (pofh.qty_to_be_fixed - (nvl(pfd.qty_fixed, 0))) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            --pdm.base_quantity_unit,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       --pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       --qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_header_data pofh,
       pfd_fixation_data pfd,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   --and pcpd.pcpd_id = pcpq.pcpd_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   --and pcpq.quality_template_id = qat.quality_id
   --and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.element_id = aml.attribute_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = poch.element_id
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pofh.pocd_id = pocd.pocd_id(+)
   and pofh.pofh_id = pfd.pofh_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pocd.is_any_day_pricing='Y' -- newly added
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   --and qat.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   --and pcm.contract_ref_no='SCT-105-BLD'
--and ak.corporate_id = '{?CorporateID}'
union all
--Any Day Pricing Concentrate +GMR
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (pofh.qty_to_be_fixed - nvl(sum(pfd.qty_fixed), 0)) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       --pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       --qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       cpc_corporate_profit_center cpc,
       vd_voyage_detail vd,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   --and pcpd.pcpd_id = pcpq.pcpd_id
   and pdm.product_id = pcpd.product_id
   --and pcpq.quality_template_id = qat.quality_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   --and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.element_id = aml.attribute_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = poch.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pofh.pocd_id = pocd.pocd_id(+)
   and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
   and pofh.pofh_id = pfd.pofh_id(+)
   and pofh.internal_gmr_ref_no is not null
   and pcpd.profit_center_id = cpc.profit_center_id
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and nvl(vd.status,'NA') in('NA','Active')
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and nvl(gmr.is_deleted, 'N') = 'N'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   --and qat.is_active = 'Y'
   and pofh.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
  --and pcm.contract_ref_no='SCT-105-BLD'
--and ak.corporate_id = '{?CorporateID}'
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm_under.product_id,
          pdm_under.product_desc,
          pcm.contract_type,
          pofh.qp_start_date,
          to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy'),
          ppfd.instrument_id,
          pocd.pcbpd_id,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcm.contract_type,
          css.strategy_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          aml.attribute_name,
          pcm.issue_date,
          ppfh.formula_description,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month || ' - ' || pfqpp.qp_year,
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          pcm.contract_ref_no,
          pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no,
          gmr.gmr_ref_no,
          vd.eta,
          pofh.qty_to_be_fixed,
          pdm_under.product_id,
          pdm.product_id,
          qum.qty_unit_id,
          pum.price_unit_name,
          pdm_under.base_quantity_unit,
          pdm.base_quantity_unit,
          qum_under.qty_unit_id,
          qum_under.qty_unit,
          qum_under.decimals,
          to_char(pcqpd.premium_disc_value),
          pcqpd.premium_disc_unit_id,
          dipq.is_price_optionality_present,
          dipq.price_option_call_off_status
union all
--Average Pricing Concentrate+Contract
select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing3' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       pofh.per_day_pricing_qty *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       --pcdiqd_di_quality_details pcdiqd,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       --qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       pofh_header_data pofh,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   --and pcpd.pcpd_id = pcpq.pcpd_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   --and pcpq.quality_template_id = qat.quality_id
   --and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and poch.element_id = aml.attribute_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbph.element_id = poch.element_id
   and pofh.pocd_id = pocd.pocd_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id
   and pcm.contract_type = 'CONCENTRATES'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   --and qat.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   --and pcm.contract_ref_no='SCT-105-BLD'
--and ak.corporate_id = '{?CorporateID}'
union all
--Average Pricing Concentrate +GMR
select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing4' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       pofh.per_day_pricing_qty *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       --pcdiqd_di_quality_details pcdiqd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       --qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       vd_voyage_detail vd,
       pofh_price_opt_fixation_header pofh,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   --and pcpd.pcpd_id = pcpq.pcpd_id
   --and pcpq.quality_template_id = qat.quality_id
   --and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and poch.element_id = aml.attribute_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbph.element_id = poch.element_id
   and pofh.pocd_id = pocd.pocd_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
--   and pcm.internal_contract_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and nvl(vd.status,'NA') in('NA','Active')
   and pofh.internal_gmr_ref_no is not null
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   --and qat.is_active = 'Y'
   and pofh.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   --and pcm.contract_ref_no='PCT-41-BLD'
--and ak.corporate_id = '{?CorporateID}'
-----siva
union all
----Fixed by Price Request Concentrate+Contact
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       pfd.as_of_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       qum_quantity_unit_master qum,
       pcdi_pc_delivery_item pcdi,
       --pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       --qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum_under,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       cipq_contract_item_payable_qty cipq,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   --and pcpd.pcpd_id = pcpq.pcpd_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   --and qat.product_id = pdm.product_id
   --and pcpq.quality_template_id = qat.quality_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = poch.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pofh.pocd_id = pocd.pocd_id
   and pofh.qty_to_be_fixed is not null
   and pofh.internal_gmr_ref_no is null
   and pofh.pofh_id = pfd.pofh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id
   and pfqpp.is_qp_any_day_basis = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcm.contract_status <> 'Cancelled'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and cipq.element_id = poch.element_id
   and cipq.qty_unit_id = qum.qty_unit_id
      --and ak.corporate_id = '{?CorporateID}'
      --  and  pfd.as_of_date >= sysdate
   and pfd.is_price_request = 'Y'
   and pfd.as_of_date > trunc(sysdate)
   --and pcm.contract_ref_no='SCT-105-BLD'
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm_under.product_id,
          pdm_under.product_desc,
          css.strategy_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          aml.attribute_name,
          --qat.quality_name,
          pfd.as_of_date,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pdm_under.product_id,
          pdm.product_id,
          qum.qty_unit_id,
          pdm_under.base_quantity_unit,
          pdm.base_quantity_unit,
          qum_under.qty_unit,
          qum_under.qty_unit_id,
          qum_under.decimals,
          ppfh.formula_description,
          to_char(pcqpd.premium_disc_value),
          pcqpd.premium_disc_unit_id,
          pum.price_unit_name,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcdi.basis_type,
          pocd.pcbpd_id,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          ppfd.instrument_id,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          pcdi.transit_days,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          dipq.is_price_optionality_present,
          dipq.price_option_call_off_status
union all
-- Fixed By Request Concentrate + Contrcat + Excluding Event Based
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pcbpd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pcbpd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       pcbph.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * nvl(dipq.payable_qty,0)*
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       qum_quantity_unit_master qum,
       pcdi_pc_delivery_item pcdi,
       --pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       --qat_quality_attributes qat,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum_under,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   --and pcpd.pcpd_id = pcpq.pcpd_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   --and qat.product_id = pdm.product_id
   --and pcpq.quality_template_id = qat.quality_id
   and pcbph.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   --and pcbph.element_id = poch.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and pcbph.element_id = dipq.element_id
   and pfqpp.is_qp_any_day_basis = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcm.contract_status <> 'Cancelled'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and dipq.qty_unit_id = qum.qty_unit_id
   --and pcm.contract_ref_no='SCT-105-BLD'
union all
   -- Fixed By Request Concentrate + Contrcat + Event Based
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       di.expected_qp_start_date qp_start_date,
       to_char(di.expected_qp_end_date,'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       pcbph.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       pfqpp.no_of_event_months || ' ' || pfqpp.event_name qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * nvl(dipq.payable_qty,0)*
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       qum_quantity_unit_master qum,
       pcdi_pc_delivery_item pcdi,
       di_del_item_exp_qp_details di, -- Newly Added
       --pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       --qat_quality_attributes qat,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum_under,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = di.pcdi_id -- Newly Added
   and di.is_active = 'Y' -- Newly Added
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   --and pcpd.pcpd_id = pcpq.pcpd_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   --and qat.product_id = pdm.product_id
   --and pcpq.quality_template_id = qat.quality_id
   and pcbph.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   --and pcbph.element_id = poch.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and pcbph.element_id = dipq.element_id
   and pfqpp.is_qp_any_day_basis = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and pfqpp.qp_pricing_period_type = 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcm.contract_status <> 'Cancelled'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and dipq.qty_unit_id = qum.qty_unit_id
   --and pcm.contract_ref_no='SCT-105-BLD'
union all
----Fixed by Price Request Concentrate+GMR
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       pfd.as_of_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no,
       vd.eta expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       qum_quantity_unit_master qum,
       pcdi_pc_delivery_item pcdi,
       --pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       --pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       --qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum_under,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       cpc_corporate_profit_center cpc,
       vd_voyage_detail vd,
       pfqpp_phy_formula_qp_pricing pfqpp,
       cipq_contract_item_payable_qty cipq,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   --and pcpd.pcpd_id = pcpq.pcpd_id
   --and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and pcbph.element_id = poch.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pofh.pocd_id = pocd.pocd_id
   and pofh.pofh_id = pfd.pofh_id
   and pofh.internal_gmr_ref_no is not null
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
      and nvl(vd.status,'NA') in('NA','Active')
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and pfqpp.is_qp_any_day_basis = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcm.contract_status <> 'Cancelled'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N' --added to handle spot as separate
   and cipq.element_id = poch.element_id
   and poch.element_id = dipq.element_id
   and cipq.qty_unit_id = qum.qty_unit_id
   and ak.corporate_id = pcm.corporate_id
   and pcpd.product_id = pdm.product_id
   and pcpd.strategy_id = css.strategy_id
   --and qat.product_id = pdm.product_id
   --and pcpq.quality_template_id = qat.quality_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
      --and ak.corporate_id = '{?CorporateID}'
      --  and  pfd.as_of_date >= sysdate
   and pfd.is_price_request = 'Y'
   and pfd.as_of_date > trunc(sysdate)
   --and pcm.contract_ref_no='SCT-105-BLD'
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm_under.product_id,
          pdm_under.product_desc,
          css.strategy_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          aml.attribute_name,
          --qat.quality_name,
          pfd.as_of_date,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pdm_under.product_id,
          pdm.product_id,
          qum.qty_unit_id,
          pdm_under.base_quantity_unit,
          pdm.base_quantity_unit,
          qum_under.qty_unit,
          qum_under.qty_unit_id,
          qum_under.decimals,
          ppfh.formula_description,
          to_char(pcqpd.premium_disc_value),
          pcqpd.premium_disc_unit_id,
          pum.price_unit_name,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcdi.basis_type,
          pocd.pcbpd_id,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          ppfd.instrument_id,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          pcdi.transit_days,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pofh.qp_start_date,
          gmr.gmr_ref_no,
          pofh.qp_end_date,
          vd.eta,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          dipq.is_price_optionality_present,
          dipq.price_option_call_off_status ;
create or replace view v_projected_price_exposure as
with pfqpp_table as (select pci.pcdi_id,
       pcbph.internal_contract_ref_no,
       pfqpp.qp_pricing_period_type,
       pfqpp.qp_period_from_date,
       pfqpp.qp_period_to_date,
       pfqpp.qp_month,
       pfqpp.qp_year,
       pfqpp.qp_date,
       pfqpp.is_qp_any_day_basis,
       pfqpp.event_name,
       pfqpp.no_of_event_months,
       ppfh.ppfh_id,
       ppfh.formula_description,
       pfqpp.is_spot_pricing,
       pcbpd.pcbpd_id
  from pci_physical_contract_item    pci,
       pcipf_pci_pricing_formula     pcipf,
       pcbph_pc_base_price_header    pcbph,
       pcbpd_pc_base_price_detail    pcbpd,
       ppfh_phy_price_formula_header ppfh,
       pfqpp_phy_formula_qp_pricing  pfqpp
 where pci.internal_contract_item_ref_no =
       pcipf.internal_contract_item_ref_no
   and pcipf.pcbph_id = pcbph.pcbph_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.pcbpd_id = pcbpd.pcbpd_id
   and ppfh.is_active = 'Y'
   and pfqpp.is_active = 'Y'
   and pci.is_active = 'Y'
   and pcipf.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and pcbph.is_active = 'Y'
 group by pci.pcdi_id,
          pcbph.internal_contract_ref_no,
          pcbpd.price_basis,
          pcbpd.price_value,
          pcbpd.price_unit_id,
          pcbpd.tonnage_basis,
          pcbpd.fx_to_base,
          pcbpd.qty_to_be_priced,
          pcbph.price_description,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_date,
          pfqpp.event_name,
          pfqpp.no_of_event_months,
          is_qp_any_day_basis,
          ppfh.price_unit_id,
          ppfh.ppfh_id,
          ppfh.formula_description,
          pfqpp.is_spot_pricing,
       pcbpd.pcbpd_id),
pofh_header_data as
        (select *
           from pofh_price_opt_fixation_header pofh
          where pofh.internal_gmr_ref_no is null
            and pofh.qty_to_be_fixed is not null
            and pofh.is_active = 'Y'),
        pfd_fixation_data as
        (select   pfd.pofh_id,
                  round (sum (nvl (pfd.qty_fixed, 0)), 5) qty_fixed
             from pfd_price_fixation_details pfd
            where pfd.is_active = 'Y'
         group by pfd.pofh_id)          
--Any Day Pricing Base Metal +Contract + Not Called Off + Excluding Event Based          
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
         to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year)
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_from_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end)   qp_start_date,
       to_char((case
         when pfqpp.qp_pricing_period_type = 'Month' then
         last_day(to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year))
        when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_to_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end),'dd-Mon-yyyy')   qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null          quality,     
       pfqpp.formula_description formula,
       vp.premium,       
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (
        nvl(diqs.open_qty,0) *
        pkg_general.f_get_converted_quantity(pcpd.product_id,
                                             qum.qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1))
                                              qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp, 
       pfqpp_table pfqpp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no  
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pfqpp.pcdi_id=pcdi.pcdi_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and pfqpp.ppfh_id = ppfd.ppfh_id
   and pcpd.profit_center_id = cpc.profit_center_id
     and pdm.base_quantity_unit = qum.qty_unit_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
union all
--Any Day Pricing Base Metal +Contract + Not Called Off + Event Based
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,       
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       di.expected_qp_start_date  qp_start_date,
       to_char(di.expected_qp_end_date,'dd-Mon-yyyy')   qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null          quality,     
       pfqpp.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (
        nvl(diqs.open_qty,0) *
        pkg_general.f_get_converted_quantity(pcpd.product_id,
                                             qum.qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1))
                                              qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       di_del_item_exp_qp_details di,
       diqs_delivery_item_qty_status diqs,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp, 
       pfqpp_table pfqpp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id=di.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pfqpp.pcdi_id=pcdi.pcdi_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and di.is_active='Y'
   and pfqpp.ppfh_id = ppfd.ppfh_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type =  'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   union all
--Any Day Pricing Base Metal +Contract + Called Off + Not Applicable
 select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,       
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,       
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,       
       ppfd.instrument_id,
       0 pricing_days,       
       'Y' is_base_metal,
       'N' is_concentrate,       
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,       
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,       
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,       
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,       
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,       
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,       
       vp.premium,
       null price_unit_id,
       null price_unit,       
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (((case
          when pfqpp.qp_pricing_period_type = 'Event' then
           (diqs.total_qty - diqs.gmr_qty - diqs.fulfilled_qty)
          else
           pofh.qty_to_be_fixed
        end) - nvl(pfd.qty_fixed, 0)) *
        pkg_general.f_get_converted_quantity(pcpd.product_id,
                                             qum.qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1)) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,       
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
       
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       pofh_header_data pofh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pfd_fixation_data pfd,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp,
       pfqpp_table pfqpp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pofh.pofh_id = pfd.pofh_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
  and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pfqpp.pcdi_id=pcdi.pcdi_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
union all
--Any Day Pricing Base Metal +GMR
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,      
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * pofh.qty_to_be_fixed -
       sum(nvl(pfd.qty_fixed, 0)) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       cpc_corporate_profit_center cpc,
       vd_voyage_detail vd,
       pfqpp_table  pfqpp,
       v_pci_multiple_premium vp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id
 and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
 and pcdi.pcdi_id = pcdiqd.pcdi_id
 and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
 and pcpd.strategy_id = css.strategy_id
 and pdm.product_id = pcpd.product_id
 and pcdi.pcdi_id = poch.pcdi_id
 and pocd.poch_id = poch.poch_id
 and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
 and pcbph.pcbph_id = pcbpd.pcbph_id
 and pcbpd.pcbpd_id = pocd.pcbpd_id
 and pcbpd.pcbpd_id = ppfh.pcbpd_id
 and pofh.pocd_id = pocd.pocd_id(+)
 and pofh.pofh_id = pfd.pofh_id(+)
 and pofh.internal_gmr_ref_no is not null
 and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
 and pcpd.profit_center_id = cpc.profit_center_id
 and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
 and pfqpp.pcdi_id=pcdi.pcdi_id
 and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
 and nvl(vd.status, 'NA') in ('Active', 'NA')
 and ppfh.ppfh_id = pfqpp.ppfh_id
 and ppfh.ppfh_id = ppfd.ppfh_id
 and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
 and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
 and pdm.base_quantity_unit = qum.qty_unit_id
 and pcm.is_active = 'Y'
 and pcm.contract_type = 'BASEMETAL'
 and pcm.approval_status = 'Approved'
 and pcdi.is_active = 'Y'
 and gmr.is_deleted = 'N'
 and pdm.is_active = 'Y'
 and qum.is_active = 'Y'
 and pofh.is_active = 'Y'
 and poch.is_active = 'Y'
 and pocd.is_active = 'Y'
 and ppfh.is_active = 'Y'
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm.product_id,
          pdm.product_desc,
          pocd.pcbpd_id,
          pcm.contract_type,
          css.strategy_id,
          css.strategy_name,
          pofh.qp_start_date,
          to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy'),
          pcm.purchase_sales,
          pcm.issue_date,
          (case
            when pfqpp.qp_pricing_period_type = 'Month' then
             pfqpp.qp_month || ' - ' || pfqpp.qp_year
            when pfqpp.qp_pricing_period_type = 'Event' then
             pfqpp.no_of_event_months || ' ' || pfqpp.event_name
            when pfqpp.qp_pricing_period_type = 'Period' then
             to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
             to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
            when pfqpp.qp_pricing_period_type = 'Date' then
             to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
          end),
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no,
          gmr.gmr_ref_no,
          pofh.qty_to_be_fixed,
          vd.eta,
          pcpd.product_id,
          qum.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit_id,
          qum.qty_unit,
          qum.decimals,
          ppfh.formula_description,
          ppfd.exchange_id,
          ppfd.exchange_name,
          ppfd.instrument_id,
          vp.premium,
          pcdi.is_price_optionality_present,
          pcdi.price_option_call_off_status
   union all
--Average Pricing Base Metal+Contract + Not Called Off + Excluding Event Based
select   ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
      (case
         when pfqpp.qp_pricing_period_type = 'Month' then
         to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year)
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_from_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end)   qp_start_date,
       to_char((case
         when pfqpp.qp_pricing_period_type = 'Month' then
         last_day(to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year))
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_to_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end),'dd-Mon-yyyy')   qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       nvl(diqs.open_qty,0) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
    
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       pfqpp_table pfqpp,    
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       qum_quantity_unit_master qum,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'   
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'  
   and ppfh.is_active = 'Y' 
--Average Pricing Base Metal+Contract + Not Called Off + Event Based
union all
select   ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       di.expected_qp_start_date qp_start_date,
       to_char(di.expected_qp_end_date,'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       null trade_date,
       pfqpp.no_of_event_months || ' ' || pfqpp.event_name qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       nvl(diqs.open_qty,0) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
    
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       di_del_item_exp_qp_details di,
       pfqpp_table pfqpp,    
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       qum_quantity_unit_master qum,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and pcdi.pcdi_id = di.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+) 
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type = 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'  
   and ppfh.is_active = 'Y' 
 union all 
--Average Pricing Base Metal+Contract + Called Off + Not Applicable
   select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,       
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       pofh.per_day_pricing_qty *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
       
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,       
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,      
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pfqpp_table pfqpp,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       qum_quantity_unit_master qum,
       pofh_header_data pofh,
       cpc_corporate_profit_center cpc,
       --pfqpp_phy_formula_qp_pricing pfqpp,
       v_pci_multiple_premium vp
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id   
   and pcpd.strategy_id = css.strategy_id   
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id=pocd.poch_id
   and pcm.internal_contract_ref_no = pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pocd.pocd_id = pofh.pocd_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'   
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'   
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y' 
--Average Pricing Base Metal+GMR
   union all
   select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       pofh.per_day_pricing_qty *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff       
      
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       pcdi_pc_delivery_item pcdi,
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pfqpp_table pfqpp,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       qum_quantity_unit_master qum,
       vd_voyage_detail vd,
       pofh_price_opt_fixation_header pofh,
       cpc_corporate_profit_center cpc,       
       v_pci_multiple_premium vp
       
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id = pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id
   and ppfh.ppfh_id=ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pocd.pocd_id = pofh.pocd_id
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pofh.internal_gmr_ref_no is not null
   and nvl(vd.status, 'NA') in ('NA', 'Active')  
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'   
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and pofh.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and gmr.is_deleted = 'N'
 --Fixed by Price Request Base Metal +Contract + Not Called Off + Excluding Event Based 8
 union all
 select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pfqpp.pcbpd_id) qp_start_date,
       f_get_pricing_month(pfqpp.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * nvl(diqs.open_qty,0) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,       
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
      pcpd_pc_product_definition pcpd,
      pdm_productmaster pdm,
      css_corporate_strategy_setup css,
      pfqpp_table pfqpp,     
      ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       v_pci_multiple_premium vp,
       cpc_corporate_profit_center cpc,
       qum_quantity_unit_master qum       
       
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id   
  and ppfh.ppfh_id = ppfd.ppfh_id(+)
  and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pfqpp.is_qp_any_day_basis = 'Y'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pdm.base_quantity_unit
union all
--Fixed by Price Request Base Metal +Contract + Not Called Off + Event Based 9
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
      di.expected_qp_start_date qp_start_date,
       to_char(di.expected_qp_end_date,'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       null trade_date,
       pfqpp.no_of_event_months || ' ' || pfqpp.event_name qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * nvl(diqs.open_qty,0) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,       
       pcdi_pc_delivery_item pcdi,
       di_del_item_exp_qp_details di,
       diqs_delivery_item_qty_status diqs,
      pcpd_pc_product_definition pcpd,
      pdm_productmaster pdm,
      css_corporate_strategy_setup css,
      pfqpp_table pfqpp,     
      ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       v_pci_multiple_premium vp,
       cpc_corporate_profit_center cpc,
       qum_quantity_unit_master qum       
       
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = di.pcdi_id -- Newly Added
   and di.is_active = 'Y' 
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id   
  and  ppfh.ppfh_id = ppfd.ppfh_id(+)
  and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+) 
  and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pfqpp.is_qp_any_day_basis = 'Y'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pdm.base_quantity_unit
union all
--Fixed by Price Request Base Metal +Contract + Called Off + Not Applicable 10
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       pfd.as_of_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       null  quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,       
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,       
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       v_pci_multiple_premium vp,
       cpc_corporate_profit_center cpc,
       qum_quantity_unit_master qum,
       pfqpp_table pfqpp
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.product_id=pdm.product_id
   and pcpd.strategy_id = css.strategy_id      
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id = pfqpp.pcdi_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and pocd.pocd_id = pofh.pocd_id 
   and pofh.pofh_id = pfd.pofh_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pofh.internal_gmr_ref_no is null
   and pofh.qty_to_be_fixed is not null   
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and pfqpp.is_qp_any_day_basis = 'Y'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pfd.is_price_request = 'Y'
   and pfd.as_of_date > trunc(sysdate) --siva
--and ak.corporate_id = '{?CorporateID}'
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm.product_id,
          pdm.product_desc,
          css.strategy_id,
          ppfd.instrument_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,          
          pfd.as_of_date,
          pocd.pcbpd_id,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          pcpd.product_id,
          qum.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit,
          qum.qty_unit_id,
          qum.decimals,
          ppfh.formula_description,
          vp.premium,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcdi.basis_type,
          pcdi.transit_days,
          pcdi.is_price_optionality_present,
          pcdi.price_option_call_off_status
----Fixed by Price Request Base Metal +GMR 11
union all
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       pfd.as_of_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,       
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,      
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pfqpp_table  pfqpp,       
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       gmr_goods_movement_record gmr,
       vd_voyage_detail vd,
       v_pci_multiple_premium vp,
       qum_quantity_unit_master qum,
       cpc_corporate_profit_center cpc
       
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no  = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no  = pcpd.internal_contract_ref_no
   and pcpd.product_id = pdm.product_id
   and pcpd.strategy_id = css.strategy_id   
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id=pocd.poch_id
   and pcdi.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id   = pfqpp.pcdi_id
   and pocd.pocd_id=pofh.pocd_id   
   and pofh.pofh_id = pfd.pofh_id
   and pofh.internal_gmr_ref_no is not null   
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and nvl(vd.status, 'NA') in ('NA', 'Active')   
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.is_qp_any_day_basis = 'Y'
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pfd.is_price_request = 'Y'
   and pfd.as_of_date > trunc(sysdate)
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm.product_id,
          pdm.product_desc,
          css.strategy_id,
          ppfd.instrument_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          pfd.as_of_date,
          pocd.pcbpd_id,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          vd.eta,
          pcpd.product_id,
          qum.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit,
          qum.qty_unit_id,
          qum.decimals,
          ppfh.formula_description,
          vp.premium,
          ppfd.exchange_id,
          pofh.qp_start_date,
          pofh.qp_end_date,
          gmr.gmr_ref_no,
          ppfd.exchange_name,
          pcdi.basis_type,
          pcdi.transit_days,
          pcdi.is_price_optionality_present,
          pcdi.price_option_call_off_status;

create or replace package pkg_price is

  -- Author  : JANARDHANA
  -- Created : 12/8/2011 2:34:26 PM
  -- Purpose : Online Price Calculation for Contracts and GMRs
  procedure sp_calc_contract_price(pc_int_contract_item_ref_no varchar2,
                                   pd_trade_date               date,
                                   pn_price                    out number,
                                   pc_price_unit_id            out varchar2);

  procedure sp_calc_gmr_price(pc_internal_gmr_ref_no varchar2,
                              pd_trade_date          date,
                              pn_price               out number,
                              pc_price_unit_id       out varchar2);

  procedure sp_calc_contract_conc_price(pc_int_contract_item_ref_no varchar2,
                                        pc_element_id               varchar2,
                                        pd_trade_date               date,
                                        pn_price                    out number,
                                        pc_price_unit_id            out varchar2);

  procedure sp_calc_conc_gmr_price(pc_internal_gmr_ref_no varchar2,
                                   pc_element_id          varchar2,
                                   pd_trade_date          date,
                                   pn_price               out number,
                                   pc_price_unit_id       out varchar2);

  function f_get_next_day(pd_date     in date,
                          pc_day      in varchar2,
                          pn_position in number) return date;

  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean;

  function f_get_next_month_prompt_date(pc_promp_del_cal_id varchar2,
                                        pd_trade_date       date) return date;

end;
/
create or replace package body "PKG_PRICE" is

  procedure sp_calc_contract_price(pc_int_contract_item_ref_no varchar2,
                                   pd_trade_date               date,
                                   pn_price                    out number,
                                   pc_price_unit_id            out varchar2) is
    cursor cur_pcdi is
      select pcdi.pcdi_id,
             pcdi.delivery_period_type,
             pcdi.delivery_from_month,
             pcdi.delivery_from_year,
             pcdi.delivery_to_month,
             pcdi.delivery_to_year,
             pcdi.delivery_from_date,
             pcdi.delivery_to_date,
             pd_trade_date eod_trade_date,
             pcdi.basis_type,
             nvl(pcdi.transit_days, 0) transit_days,
             pcdi.price_option_call_off_status,
             pci.internal_contract_item_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpd.qty_unit_id,
             pcpd.product_id,
             qat.instrument_id,
             ps.price_source_id,
             apm.available_price_id,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable,
             akc.corporate_id
        from pcdi_pc_delivery_item        pcdi,
             pci_physical_contract_item   pci,
             pcm_physical_contract_main   pcm,
             ak_corporate                 akc,
             pcpd_pc_product_definition   pcpd,
             pcpq_pc_product_quality      pcpq,
             v_contract_exchange_detail   qat,
             dim_der_instrument_master    dim,
             div_der_instrument_valuation div,
             ps_price_source              ps,
             apm_available_price_master   apm,
             pum_price_unit_master        pum,
             v_der_instrument_price_unit  vdip,
             pdc_prompt_delivery_calendar pdc
       where pcdi.pcdi_id = pci.pcdi_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'BASEMETAL'
         and pci.internal_contract_item_ref_no =
             qat.internal_contract_item_ref_no(+)
         and qat.instrument_id = dim.instrument_id(+)
         and dim.instrument_id = div.instrument_id(+)
         and div.is_deleted(+) = 'N'
         and div.price_source_id = ps.price_source_id(+)
         and div.available_price_id = apm.available_price_id(+)
         and div.price_unit_id = pum.price_unit_id(+)
         and dim.instrument_id = vdip.instrument_id(+)
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id(+)
         and pci.item_qty > 0
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pci.internal_contract_item_ref_no =
             pc_int_contract_item_ref_no;
    cursor cur_called_off(pc_pcdi_id varchar2) is
      select poch.poch_id,
             poch.internal_action_ref_no,
             pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where poch.pcdi_id = pc_pcdi_id
         and poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    cursor cur_not_called_off(pc_pcdi_id varchar2, pc_int_cont_item_ref_no varchar2) is
      select pcbpd.pcbpd_id,
             pcbph.internal_contract_ref_no,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced
        from pci_physical_contract_item pci,
             pcipf_pci_pricing_formula  pcipf,
             pcbph_pc_base_price_header pcbph,
             pcbpd_pc_base_price_detail pcbpd
       where pci.internal_contract_item_ref_no =
             pcipf.internal_contract_item_ref_no
         and pcipf.pcbph_id = pcbph.pcbph_id
         and pcbph.pcbph_id = pcbpd.pcbph_id
         and pci.pcdi_id = pc_pcdi_id
         and pci.internal_contract_item_ref_no = pc_int_cont_item_ref_no
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    vn_contract_price              number;
    vc_price_unit_id               varchar2(15);
    vn_total_quantity              number;
    vn_qty_to_be_priced            number;
    vn_total_contract_value        number;
    vn_average_price               number;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(15);
    vd_shipment_date               date;
    vd_arrival_date                date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vd_3rd_wed_of_qp               date;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_set_price      number;
    vn_during_total_val_price      number;
    vn_count_set_qp                number;
    vn_count_val_qp                number;
    vn_workings_days               number;
    vd_quotes_date                 date;
    vn_during_qp_price             number;
    vc_during_price_dr_id          varchar2(15);
    vc_during_qp_price_unit_id     varchar2(15);
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_value number;
    vn_anyday_price_ufix_qty_value number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vn_no_of_trading_days          number;
  begin
    for cur_pcdi_rows in cur_pcdi
    loop
      vn_total_contract_value := 0;
      if cur_pcdi_rows.price_option_call_off_status in
         ('Called Off', 'Not Applicable') then
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id)
        loop
          if cur_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_called_off_rows.price_value;
            vn_total_quantity       := cur_pcdi_rows.item_qty;
            vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_called_off_rows.price_unit_id;
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select ppfh.ppfh_id,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id,
                               pocd.qp_period_type,
                               pofh.qp_start_date,
                               pofh.qp_end_date,
                               pfqpp.is_qp_any_day_basis,
                               pofh.qty_to_be_fixed,
                               pofh.priced_qty,
                               pofh.pofh_id,
                               pofh.no_of_prompt_days
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail     pcbpd,
                               ppfh_phy_price_formula_header  ppfh,
                               pfqpp_phy_formula_qp_pricing   pfqpp,
                               pofh_price_opt_fixation_header pofh,
                               v_ppu_pum                      ppu
                         where poch.poch_id = pocd.poch_id
                           and pocd.pcbpd_id = pcbpd.pcbpd_id
                           and pcbpd.pcbpd_id = ppfh.pcbpd_id
                           and ppfh.ppfh_id = pfqpp.ppfh_id
                           and pocd.pocd_id = pofh.pocd_id(+)
                           and pcbpd.pcbpd_id = cur_called_off_rows.pcbpd_id
                           and poch.poch_id = cur_called_off_rows.poch_id
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id
                           and poch.is_active = 'Y'
                           and pocd.is_active = 'Y'
                           and pcbpd.is_active = 'Y'
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                        -- and pofh.is_active(+) = 'Y'
                        )
            loop
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
              if cc1.qp_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Month' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                  when others then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                end;
              else
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if vc_period = 'Before QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif (vc_period = 'During QP' or vc_period = 'After QP') then
                vd_dur_qp_start_date           := vd_qp_start_date;
                vd_dur_qp_end_date             := vd_qp_end_date;
                vn_during_total_set_price      := 0;
                vn_count_set_qp                := 0;
                vn_any_day_price_fix_qty_value := 0;
                vn_any_day_fixed_qty           := 0;
                for cc in (select pfd.user_price,
                                  pfd.qty_fixed
                             from poch_price_opt_call_off_header poch,
                                  pocd_price_option_calloff_dtls pocd,
                                  pofh_price_opt_fixation_header pofh,
                                  pfd_price_fixation_details     pfd
                            where poch.poch_id = pocd.poch_id
                              and pocd.pocd_id = pofh.pocd_id
                              and pofh.pofh_id = cc1.pofh_id
                              and pofh.pofh_id = pfd.pofh_id
                              and pfd.as_of_date >= vd_dur_qp_start_date
                              and pfd.as_of_date <= pd_trade_date
                              and poch.is_active = 'Y'
                              and pocd.is_active = 'Y'
                              and pofh.is_active = 'Y'
                              and pfd.is_active = 'Y')
                loop
                  vn_during_total_set_price      := vn_during_total_set_price +
                                                    cc.user_price;
                  vn_any_day_price_fix_qty_value := vn_any_day_price_fix_qty_value +
                                                    (cc.user_price *
                                                    cc.qty_fixed);
                  vn_any_day_fixed_qty           := vn_any_day_fixed_qty +
                                                    cc.qty_fixed;
                  vn_count_set_qp                := vn_count_set_qp + 1;
                end loop;
                if cc1.is_qp_any_day_basis = 'Y' then
                  vn_market_flag := 'N';
                else
                  vn_market_flag := 'Y';
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if (vd_3rd_wed_of_qp <= pd_trade_date and
                     vc_period = 'During QP') or vc_period = 'After QP' then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   vd_qp_end_date);
                  elsif vc_period = 'After QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   pd_trade_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_val_price,
                         vc_during_val_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_during_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_during_val_price         := 0;
                    vc_during_val_price_unit_id := null;
                end;
                vn_during_total_val_price := 0;
                vn_count_val_qp           := 0;
                vd_dur_qp_start_date      := pd_trade_date + 1;
                if vn_market_flag = 'N' then
                  vn_during_total_val_price      := vn_during_total_val_price +
                                                    vn_during_val_price;
                  vn_any_day_unfixed_qty         := cc1.qty_to_be_fixed -
                                                    vn_any_day_fixed_qty;
                  vn_count_val_qp                := vn_count_val_qp + 1;
                  vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                                    vn_during_total_val_price);
                else
                  vn_no_of_trading_days := pkg_general.f_get_instrument_trading_days(cur_pcdi_rows.instrument_id,
                                                                                     vd_qp_start_date,
                                                                                     vd_qp_end_date);
                
                  vn_count_val_qp           := vn_no_of_trading_days -
                                               vn_count_set_qp;
                  vn_during_total_val_price := vn_during_total_val_price +
                                               vn_during_val_price *
                                               vn_count_val_qp;
                
                end if;
                if (vn_count_val_qp + vn_count_set_qp) <> 0 then
                  if vn_market_flag = 'N' then
                    vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                          vn_anyday_price_ufix_qty_value) /
                                          cc1.qty_to_be_fixed;
                  else
                    vn_during_qp_price := (vn_during_total_set_price +
                                          vn_during_total_val_price) /
                                          (vn_count_set_qp +
                                          vn_count_val_qp);
                  end if;
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_during_qp_price;
                else
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                  vn_total_contract_value := 0;
                end if;
                vc_price_unit_id := cc1.ppu_price_unit_id;
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      elsif cur_pcdi_rows.price_option_call_off_status = 'Not Called Off' then
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.internal_contract_item_ref_no)
        loop
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_not_called_off_rows.price_value;
            vn_total_quantity       := cur_pcdi_rows.item_qty;
            vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_not_called_off_rows.price_unit_id;
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select pfqpp.qp_pricing_period_type,
                               pfqpp.qp_period_from_date,
                               pfqpp.qp_period_to_date,
                               pfqpp.qp_month,
                               pfqpp.qp_year,
                               pfqpp.qp_date,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id --pum price unit id, as quoted available in this unit only
                          from ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing  pfqpp,
                               v_ppu_pum                     ppu
                         where ppfh.ppfh_id = pfqpp.ppfh_id
                           and ppfh.pcbpd_id =
                               cur_not_called_off_rows.pcbpd_id
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id)
            loop
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
              if cc1.qp_pricing_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              elsif cc1.qp_pricing_period_type = 'Month' then
                vd_qp_start_date := '01-' || cc1.qp_month || '-' ||
                                    cc1.qp_year;
                vd_qp_end_date   := last_day(vd_qp_start_date);
              elsif cc1.qp_pricing_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_date;
                vd_qp_end_date   := cc1.qp_date;
              elsif cc1.qp_pricing_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_not_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                  when others then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                end;
              else
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if vc_period = 'Before QP' then
                ---- get third wednesday of QP period
                --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif (vc_period = 'During QP' or vc_period = 'After QP') then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if (vd_3rd_wed_of_qp <= pd_trade_date and
                     vc_period = 'During QP') or vc_period = 'After QP' then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   vd_qp_end_date);
                  elsif vc_period = 'After QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   pd_trade_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_qp_price,
                         vc_during_qp_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_during_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_during_qp_price         := 0;
                    vc_during_qp_price_unit_id := null;
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_during_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      end if;
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_price_unit_id;
  end;

  procedure sp_calc_gmr_price(pc_internal_gmr_ref_no varchar2,
                              pd_trade_date          date,
                              pn_price               out number,
                              pc_price_unit_id       out varchar2) is
    cursor cur_gmr is
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.pofh_id,
             pd_trade_date eod_trade_date,
             qat.instrument_id,
             ps.price_source_id,
             apm.available_price_id,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             pocd.is_any_day_pricing,
             pofh.qty_to_be_fixed,
             round(pofh.priced_qty, 4) priced_qty,
             pofh.no_of_prompt_days,
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from grd_goods_record_detail grd
               where grd.status = 'Active'
                 and grd.is_deleted = 'N'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             v_gmr_exchange_details qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip,
             pdc_prompt_delivery_calendar pdc
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdtm.product_type_name = 'Standard'
         and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
         and qat.instrument_id = dim.instrument_id(+)
         and dim.instrument_id = div.instrument_id(+)
         and div.is_deleted(+) = 'N'
         and div.price_source_id = ps.price_source_id(+)
         and div.available_price_id = apm.available_price_id(+)
         and div.price_unit_id = pum.price_unit_id(+)
         and dim.instrument_id = vdip.instrument_id(+)
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id(+)
         and gmr.is_deleted = 'N'
         and pofh.is_active = 'Y'
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
      union all
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.pofh_id,
             pd_trade_date eod_trade_date,
             qat.instrument_id,
             ps.price_source_id,
             apm.available_price_id,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             pocd.is_any_day_pricing,
             pofh.qty_to_be_fixed,
             round(pofh.priced_qty, 4) priced_qty,
             pofh.no_of_prompt_days,
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from dgrd_delivered_grd grd
               where grd.status = 'Active'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             v_gmr_exchange_details qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip,
             pdc_prompt_delivery_calendar pdc
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdtm.product_type_name = 'Standard'
         and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
         and qat.instrument_id = dim.instrument_id(+)
         and dim.instrument_id = div.instrument_id(+)
         and div.is_deleted(+) = 'N'
         and div.price_source_id = ps.price_source_id(+)
         and div.available_price_id = apm.available_price_id(+)
         and div.price_unit_id = pum.price_unit_id(+)
         and dim.instrument_id = vdip.instrument_id(+)
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id(+)
         and gmr.is_deleted = 'N'
         and pofh.is_active = 'Y'
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(50);
    vd_3rd_wed_of_qp               date;
    workings_days                  number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_total_contract_value        number;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vn_during_qp_price             number;
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_value number;
    vn_anyday_price_ufix_qty_value number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_price_unit_id               varchar2(15);
    vc_ppu_price_unit_id           varchar2(15);
    vc_pcbpd_id                    varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
  begin
    for cur_gmr_rows in cur_gmr
    loop
      vn_total_contract_value        := 0;
      vn_market_flag                 := null;
      vn_any_day_price_fix_qty_value := 0;
      vn_anyday_price_ufix_qty_value := 0;
      vn_any_day_unfixed_qty         := 0;
      vn_any_day_fixed_qty           := 0;
      vc_pcbpd_id                    := cur_gmr_rows.pcbpd_id;
      vc_price_unit_id               := null;
      vc_ppu_price_unit_id           := null;
      vd_qp_start_date               := cur_gmr_rows.qp_start_date;
      vd_qp_end_date                 := cur_gmr_rows.qp_end_date;
      if cur_gmr_rows.eod_trade_date >= vd_qp_start_date and
         cur_gmr_rows.eod_trade_date <= vd_qp_end_date then
        vc_period := 'During QP';
      elsif cur_gmr_rows.eod_trade_date < vd_qp_start_date and
            cur_gmr_rows.eod_trade_date < vd_qp_end_date then
        vc_period := 'Before QP';
      elsif cur_gmr_rows.eod_trade_date > vd_qp_start_date and
            cur_gmr_rows.eod_trade_date > vd_qp_end_date then
        vc_period := 'After QP';
      end if;
      begin
        select ppu.product_price_unit_id,
               ppu.price_unit_id
          into vc_ppu_price_unit_id,
               vc_price_unit_id
          from ppfh_phy_price_formula_header ppfh,
               v_ppu_pum                     ppu
         where ppfh.pcbpd_id = vc_pcbpd_id
           and ppfh.price_unit_id = ppu.product_price_unit_id
           and rownum <= 1;
      exception
        when no_data_found then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
        when others then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
      end;
      if vc_period = 'Before QP' then
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date, 'Wed', 3);
          while true
          loop
            if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                vd_3rd_wed_of_qp) then
              vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
            else
              exit;
            end if;
          end loop;
          --- get 3rd wednesday  before QP period
          -- Get the quotation date = Trade Date +2 working Days
          if vd_3rd_wed_of_qp <= pd_trade_date then
            workings_days  := 0;
            vd_quotes_date := pd_trade_date + 1;
            while workings_days <> 2
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                  vd_quotes_date) then
                vd_quotes_date := vd_quotes_date + 1;
              else
                workings_days := workings_days + 1;
                if workings_days <> 2 then
                  vd_quotes_date := vd_quotes_date + 1;
                end if;
              end if;
            end loop;
            vd_3rd_wed_of_qp := vd_quotes_date;
          end if;
          begin
            select drm.dr_id
              into vc_before_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.prompt_date = vd_3rd_wed_of_qp
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vc_before_price_dr_id := null;
          end;
        elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
              cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
          vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                          vd_qp_end_date);
          vc_prompt_month := to_char(vc_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
          begin
            select drm.dr_id
              into vc_before_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.period_month = vc_prompt_month
               and drm.period_year = vc_prompt_year
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vc_before_price_dr_id := null;
          end;
        end if;
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_before_qp_price,
                 vc_before_qp_price_unit_id
            from dq_derivative_quotes          dq,
                 v_dqd_derivative_quote_detail dqd
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_before_price_dr_id
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dqd.price_unit_id = vc_price_unit_id
             and dq.corporate_id = cur_gmr_rows.corporate_id
             and dq.is_deleted = 'N'
             and dqd.is_deleted = 'N'
             and dq.trade_date =
                 (select max(dq.trade_date)
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_gmr_rows.instrument_id
                     and dqd.available_price_id =
                         cur_gmr_rows.available_price_id
                     and dq.price_source_id = cur_gmr_rows.price_source_id
                     and dqd.price_unit_id = vc_price_unit_id
                     and dq.corporate_id = cur_gmr_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date <= pd_trade_date);
        exception
          when no_data_found then
            vn_before_qp_price         := 0;
            vc_before_qp_price_unit_id := null;
        end;
        vn_total_contract_value := vn_total_contract_value +
                                   vn_before_qp_price;
      elsif (vc_period = 'During QP' or vc_period = 'After QP') then
        vd_dur_qp_start_date      := vd_qp_start_date;
        vd_dur_qp_end_date        := vd_qp_end_date;
        vn_during_total_set_price := 0;
        vn_count_set_qp           := 0;
        for cc in (select pfd.user_price,
                          pfd.as_of_date,
                          pfd.qty_fixed,
                          pofh.final_price,
                          pocd.is_any_day_pricing
                     from poch_price_opt_call_off_header poch,
                          pocd_price_option_calloff_dtls pocd,
                          pofh_price_opt_fixation_header pofh,
                          pfd_price_fixation_details     pfd
                    where poch.poch_id = pocd.poch_id
                      and pocd.pocd_id = pofh.pocd_id
                      and pofh.pofh_id = cur_gmr_rows.pofh_id
                      and pofh.pofh_id = pfd.pofh_id
                      and pfd.as_of_date >= vd_dur_qp_start_date
                      and pfd.as_of_date <= pd_trade_date
                      and poch.is_active = 'Y'
                      and pocd.is_active = 'Y'
                      and pofh.is_active = 'Y'
                      and pfd.is_active = 'Y')
        loop
          vn_during_total_set_price      := vn_during_total_set_price +
                                            cc.user_price;
          vn_count_set_qp                := vn_count_set_qp + 1;
          vn_any_day_fixed_qty           := vn_any_day_fixed_qty +
                                            cc.qty_fixed;
          vn_any_day_price_fix_qty_value := vn_any_day_price_fix_qty_value +
                                            (cc.user_price * cc.qty_fixed);
        end loop;
        if cur_gmr_rows.is_any_day_pricing = 'Y' then
          vn_market_flag := 'N';
        else
          vn_market_flag := 'Y';
        end if;
        -- get the third wednes day
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date, 'Wed', 3);
          while true
          loop
            if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                vd_3rd_wed_of_qp) then
              vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
            else
              exit;
            end if;
          end loop;
          --- get 3rd wednesday  before QP period
          -- Get the quotation date = Trade Date +2 working Days
          if (vd_3rd_wed_of_qp <= pd_trade_date and vc_period = 'During QP') or
             vc_period = 'After QP' then
            workings_days  := 0;
            vd_quotes_date := pd_trade_date + 1;
            while workings_days <> 2
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                  vd_quotes_date) then
                vd_quotes_date := vd_quotes_date + 1;
              else
                workings_days := workings_days + 1;
                if workings_days <> 2 then
                  vd_quotes_date := vd_quotes_date + 1;
                end if;
              end if;
            end loop;
            vd_3rd_wed_of_qp := vd_quotes_date;
          end if;
          begin
            select drm.dr_id
              into vc_during_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.prompt_date = vd_3rd_wed_of_qp
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vc_during_price_dr_id := null;
          end;
        elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
              cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
          if vc_period = 'During QP' then
            vc_prompt_date := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                           vd_qp_end_date);
          elsif vc_period = 'After QP' then
            vc_prompt_date := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                           pd_trade_date);
          end if;
          vc_prompt_month := to_char(vc_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
          begin
            select drm.dr_id
              into vc_during_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.period_month = vc_prompt_month
               and drm.period_year = vc_prompt_year
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vc_during_price_dr_id := null;
          end;
        end if;
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_during_val_price,
                 vc_during_val_price_unit_id
            from dq_derivative_quotes          dq,
                 v_dqd_derivative_quote_detail dqd
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_during_price_dr_id
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dqd.price_unit_id = vc_price_unit_id
             and dq.corporate_id = cur_gmr_rows.corporate_id
             and dq.is_deleted = 'N'
             and dqd.is_deleted = 'N'
             and dq.trade_date =
                 (select max(dq.trade_date)
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_gmr_rows.instrument_id
                     and dqd.available_price_id =
                         cur_gmr_rows.available_price_id
                     and dq.price_source_id = cur_gmr_rows.price_source_id
                     and dqd.price_unit_id = vc_price_unit_id
                     and dq.corporate_id = cur_gmr_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date <= pd_trade_date);
        exception
          when no_data_found then
            vn_during_val_price         := 0;
            vc_during_val_price_unit_id := null;
        end;
        vn_during_total_val_price := 0;
        vn_count_val_qp           := 0;
        vd_dur_qp_start_date      := pd_trade_date + 1;
        if vn_market_flag = 'N' then
          vn_during_total_val_price      := vn_during_total_val_price +
                                            vn_during_val_price;
          vn_any_day_unfixed_qty         := cur_gmr_rows.qty_to_be_fixed -
                                            vn_any_day_fixed_qty;
          vn_count_val_qp                := vn_count_val_qp + 1;
          vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                            vn_during_total_val_price);
        else
          vn_count_val_qp           := cur_gmr_rows.no_of_prompt_days -
                                       vn_count_set_qp;
          vn_during_total_val_price := vn_during_total_val_price +
                                       vn_during_val_price *
                                       vn_count_val_qp;
        
        end if;
        if (vn_count_val_qp + vn_count_set_qp) <> 0 then
          if vn_market_flag = 'N' then
            vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                  vn_anyday_price_ufix_qty_value) /
                                  cur_gmr_rows.qty_to_be_fixed;
          else
            vn_during_qp_price := (vn_during_total_set_price +
                                  vn_during_total_val_price) /
                                  (vn_count_set_qp + vn_count_val_qp);
          end if;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_during_qp_price;
        else
          vn_total_contract_value := 0;
        end if;
      end if;
    end loop;
    pn_price         := vn_total_contract_value;
    pc_price_unit_id := vc_ppu_price_unit_id;
  end;

  procedure sp_calc_contract_conc_price(pc_int_contract_item_ref_no varchar2,
                                        pc_element_id               varchar2,
                                        pd_trade_date               date,
                                        pn_price                    out number,
                                        pc_price_unit_id            out varchar2) is
    cursor cur_pcdi is
      select pcdi.pcdi_id,
             pcm.corporate_id,
             pcdi.internal_contract_ref_no,
             ceqs.element_id,
             ceqs.payable_qty,
             ceqs.payable_qty_unit_id,
             pcdi.delivery_item_no,
             pcdi.delivery_period_type,
             pcdi.delivery_from_month,
             pcdi.delivery_from_year,
             pcdi.delivery_to_month,
             pcdi.delivery_to_year,
             pcdi.delivery_from_date,
             pcdi.delivery_to_date,
             pd_trade_date eod_trade_date,
             pcdi.basis_type,
             nvl(pcdi.transit_days, 0) transit_days,
             pcdi.qp_declaration_date,
             pci.internal_contract_item_ref_no,
             pcm.contract_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpd.qty_unit_id,
             pcpd.product_id,
             aml.underlying_product_id,
             tt.instrument_id,
             akc.base_cur_id,
             tt.instrument_name,
             tt.price_source_id,
             tt.price_source_name,
             tt.available_price_id,
             tt.available_price_name,
             tt.price_unit_name,
             tt.ppu_price_unit_id,
             tt.price_unit_id,
             tt.delivery_calender_id,
             tt.is_daily_cal_applicable,
             tt.is_monthly_cal_applicable
        from pcdi_pc_delivery_item pcdi,
             v_contract_payable_qty ceqs,
             pci_physical_contract_item pci,
             pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcpd_pc_product_definition pcpd,
             pcpq_pc_product_quality pcpq,
             aml_attribute_master_list aml,
             (select qat.internal_contract_item_ref_no,
                     qat.element_id,
                     qat.instrument_id,
                     dim.instrument_name,
                     ps.price_source_id,
                     ps.price_source_name,
                     apm.available_price_id,
                     apm.available_price_name,
                     pum.price_unit_name,
                     vdip.ppu_price_unit_id,
                     div.price_unit_id,
                     dim.delivery_calender_id,
                     pdc.is_daily_cal_applicable,
                     pdc.is_monthly_cal_applicable
                from v_contract_exchange_detail   qat,
                     dim_der_instrument_master    dim,
                     div_der_instrument_valuation div,
                     ps_price_source              ps,
                     apm_available_price_master   apm,
                     pum_price_unit_master        pum,
                     v_der_instrument_price_unit  vdip,
                     pdc_prompt_delivery_calendar pdc
               where qat.instrument_id = dim.instrument_id
                 and dim.instrument_id = div.instrument_id
                 and div.is_deleted = 'N'
                 and div.price_source_id = ps.price_source_id
                 and div.available_price_id = apm.available_price_id
                 and div.price_unit_id = pum.price_unit_id
                 and dim.instrument_id = vdip.instrument_id
                 and dim.delivery_calender_id =
                     pdc.prompt_delivery_calendar_id) tt
       where pcdi.pcdi_id = pci.pcdi_id
         and pci.internal_contract_item_ref_no =
             ceqs.internal_contract_item_ref_no
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'CONCENTRATES'
         and ceqs.element_id = aml.attribute_id
         and ceqs.internal_contract_item_ref_no =
             tt.internal_contract_item_ref_no(+)
         and ceqs.element_id = tt.element_id(+)
         and pci.item_qty > 0
         and ceqs.payable_qty > 0
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pci.internal_contract_item_ref_no =
             pc_int_contract_item_ref_no
         and ceqs.element_id = pc_element_id;
    cursor cur_called_off(pc_pcdi_id varchar2, pc_element_id varchar2) is
      select poch.poch_id,
             poch.internal_action_ref_no,
             pocd.pricing_formula_id,
             pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.tonnage_basis,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced,
             pcbph.price_description
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where poch.pcdi_id = pc_pcdi_id
         and pcbpd.element_id = pc_element_id
         and poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    cursor cur_not_called_off(pc_pcdi_id varchar2, pc_element_id varchar2, pc_int_cont_item_ref_no varchar2) is
      select pcbpd.pcbpd_id,
             pcbph.internal_contract_ref_no,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.tonnage_basis,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced,
             pcbph.price_description
        from pci_physical_contract_item pci,
             pcipf_pci_pricing_formula  pcipf,
             pcbph_pc_base_price_header pcbph,
             pcbpd_pc_base_price_detail pcbpd
       where pci.internal_contract_item_ref_no =
             pcipf.internal_contract_item_ref_no
         and pcipf.pcbph_id = pcbph.pcbph_id
         and pcbph.pcbph_id = pcbpd.pcbph_id
         and pci.pcdi_id = pc_pcdi_id
         and pcbpd.element_id = pc_element_id
         and pci.internal_contract_item_ref_no = pc_int_cont_item_ref_no
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    vn_contract_price              number;
    vc_price_unit_id               varchar2(15);
    vn_total_quantity              number;
    vn_total_contract_value        number;
    vd_shipment_date               date;
    vd_arrival_date                date;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(20);
    vd_3rd_wed_of_qp               date;
    vn_workings_days               number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_qty_to_be_priced            number;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vn_any_day_price_fix_qty_value number;
    vn_any_day_fixed_qty           number;
    vn_market_flag                 char(1);
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vn_any_day_unfixed_qty         number;
    vn_anyday_price_ufix_qty_value number;
    vn_during_qp_price             number;
    vn_average_price               number;
    vc_during_qp_price_unit_id     varchar2(15);
    vc_price_option_call_off_sts   varchar2(50);
    vc_pcdi_id                     varchar2(15);
    vc_element_id                  varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vn_no_of_trading_days          number;
  begin
    for cur_pcdi_rows in cur_pcdi
    loop
      vc_pcdi_id    := cur_pcdi_rows.pcdi_id;
      vc_element_id := cur_pcdi_rows.element_id;
      begin
        select dipq.price_option_call_off_status
          into vc_price_option_call_off_sts
          from dipq_delivery_item_payable_qty dipq
         where dipq.pcdi_id = vc_pcdi_id
           and dipq.element_id = vc_element_id
           and dipq.is_active = 'Y';
      exception
        when no_data_found then
          vc_price_option_call_off_sts := null;
      end;
      vn_total_contract_value := 0;
      vd_qp_start_date        := null;
      vd_qp_end_date          := null;
      if vc_price_option_call_off_sts in ('Called Off', 'Not Applicable') then
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id,
                                                  cur_pcdi_rows.element_id)
        loop
          if cur_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_called_off_rows.price_value;
            vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                            cur_pcdi_rows.payable_qty_unit_id,
                                                                            cur_pcdi_rows.item_qty_unit_id,
                                                                            cur_pcdi_rows.payable_qty);
            vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_called_off_rows.price_unit_id;
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select ppfh.ppfh_id,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id,
                               pocd.qp_period_type,
                               pofh.qp_start_date,
                               pofh.qp_end_date,
                               pfqpp.event_name,
                               pfqpp.no_of_event_months,
                               pfqpp.is_qp_any_day_basis,
                               pofh.qty_to_be_fixed,
                               pofh.priced_qty,
                               pofh.pofh_id,
                               pofh.no_of_prompt_days
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail     pcbpd,
                               ppfh_phy_price_formula_header  ppfh,
                               pfqpp_phy_formula_qp_pricing   pfqpp,
                               pofh_price_opt_fixation_header pofh,
                               v_ppu_pum                      ppu
                         where poch.poch_id = pocd.poch_id
                           and pocd.pcbpd_id = pcbpd.pcbpd_id
                           and pcbpd.pcbpd_id = ppfh.pcbpd_id
                           and ppfh.ppfh_id = pfqpp.ppfh_id
                           and pocd.pocd_id = pofh.pocd_id(+)
                           and pcbpd.pcbpd_id = cur_called_off_rows.pcbpd_id
                           and poch.poch_id = cur_called_off_rows.poch_id
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id
                           and poch.is_active = 'Y'
                           and pocd.is_active = 'Y'
                           and pcbpd.is_active = 'Y'
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                        -- and pofh.is_active(+) = 'Y'
                        )
            loop
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
              if cc1.qp_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Month' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                  when others then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                end;
              else
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if vc_period = 'Before QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif (vc_period = 'During QP' or vc_period = 'After QP') then
                vd_dur_qp_start_date           := vd_qp_start_date;
                vd_dur_qp_end_date             := vd_qp_end_date;
                vn_during_total_set_price      := 0;
                vn_count_set_qp                := 0;
                vn_any_day_price_fix_qty_value := 0;
                vn_any_day_fixed_qty           := 0;
                for cc in (select pfd.user_price,
                                  pfd.as_of_date,
                                  pfd.qty_fixed
                             from poch_price_opt_call_off_header poch,
                                  pocd_price_option_calloff_dtls pocd,
                                  pofh_price_opt_fixation_header pofh,
                                  pfd_price_fixation_details     pfd
                            where poch.poch_id = pocd.poch_id
                              and pocd.pocd_id = pofh.pocd_id
                              and pofh.pofh_id = cc1.pofh_id
                              and pofh.pofh_id = pfd.pofh_id
                              and pfd.as_of_date >= vd_dur_qp_start_date
                              and pfd.as_of_date <= pd_trade_date
                              and poch.is_active = 'Y'
                              and pocd.is_active = 'Y'
                              and pofh.is_active = 'Y'
                              and pfd.is_active = 'Y')
                loop
                  vn_during_total_set_price      := vn_during_total_set_price +
                                                    cc.user_price;
                  vn_any_day_price_fix_qty_value := vn_any_day_price_fix_qty_value +
                                                    (cc.user_price *
                                                    cc.qty_fixed);
                  vn_any_day_fixed_qty           := vn_any_day_fixed_qty +
                                                    cc.qty_fixed;
                  vn_count_set_qp                := vn_count_set_qp + 1;
                end loop;
                if cc1.is_qp_any_day_basis = 'Y' then
                  vn_market_flag := 'N';
                else
                  vn_market_flag := 'Y';
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  -- get the third wednes day
                  vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if (vd_3rd_wed_of_qp <= pd_trade_date and
                     vc_period = 'During QP') or vc_period = 'After QP' then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   vd_qp_end_date);
                  elsif vc_period = 'After QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   pd_trade_date);
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_val_price,
                         vc_during_val_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_during_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_during_val_price         := 0;
                    vc_during_val_price_unit_id := null;
                end;
                vn_during_total_val_price := 0;
                vn_count_val_qp           := 0;
                vd_dur_qp_start_date      := pd_trade_date + 1;
                if vn_market_flag = 'N' then
                  vn_during_total_val_price      := vn_during_total_val_price +
                                                    vn_during_val_price;
                  vn_any_day_unfixed_qty         := nvl(cc1.qty_to_be_fixed,
                                                        0) -
                                                    vn_any_day_fixed_qty;
                  vn_count_val_qp                := vn_count_val_qp + 1;
                  vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                                    vn_during_total_val_price);
                else
                  vn_no_of_trading_days     := pkg_general.f_get_instrument_trading_days(cur_pcdi_rows.instrument_id,
                                                                                         vd_qp_start_date,
                                                                                         vd_qp_end_date);
                  vn_count_val_qp           := vn_no_of_trading_days -
                                               vn_count_set_qp;
                  vn_during_total_val_price := vn_during_total_val_price +
                                               vn_during_val_price *
                                               vn_count_val_qp;
                
                end if;
                if (vn_count_val_qp + vn_count_set_qp) <> 0 then
                  if vn_market_flag = 'N' then
                    vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                          vn_anyday_price_ufix_qty_value) /
                                          nvl(cc1.qty_to_be_fixed, 0);
                  else
                    vn_during_qp_price := (vn_during_total_set_price +
                                          vn_during_total_val_price) /
                                          (vn_count_set_qp +
                                          vn_count_val_qp);
                  end if;
                  vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                  cur_pcdi_rows.payable_qty_unit_id,
                                                                                  cur_pcdi_rows.item_qty_unit_id,
                                                                                  cur_pcdi_rows.payable_qty);
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_during_qp_price;
                  vc_price_unit_id        := cc1.ppu_price_unit_id;
                else
                  vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                  cur_pcdi_rows.payable_qty_unit_id,
                                                                                  cur_pcdi_rows.item_qty_unit_id,
                                                                                  cur_pcdi_rows.payable_qty);
                  vn_total_contract_value := 0;
                  vc_price_unit_id        := cc1.ppu_price_unit_id;
                end if;
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      elsif vc_price_option_call_off_sts = 'Not Called Off' then
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.element_id,
                                                          cur_pcdi_rows.internal_contract_item_ref_no)
        loop
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_not_called_off_rows.price_value;
            vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                            cur_pcdi_rows.payable_qty_unit_id,
                                                                            cur_pcdi_rows.item_qty_unit_id,
                                                                            cur_pcdi_rows.payable_qty);
            vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_not_called_off_rows.price_unit_id;
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select pfqpp.qp_pricing_period_type,
                               pfqpp.qp_period_from_date,
                               pfqpp.qp_period_to_date,
                               pfqpp.qp_month,
                               pfqpp.qp_year,
                               pfqpp.qp_date,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id --pum price unit id, as quoted available in this unit only
                          from ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing  pfqpp,
                               v_ppu_pum                     ppu
                         where ppfh.ppfh_id = pfqpp.ppfh_id
                           and ppfh.pcbpd_id =
                               cur_not_called_off_rows.pcbpd_id
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id)
            loop
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
              if cc1.qp_pricing_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              elsif cc1.qp_pricing_period_type = 'Month' then
                vd_qp_start_date := '01-' || cc1.qp_month || '-' ||
                                    cc1.qp_year;
                vd_qp_end_date   := last_day(vd_qp_start_date);
              elsif cc1.qp_pricing_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_date;
                vd_qp_end_date   := cc1.qp_date;
              elsif cc1.qp_pricing_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_not_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                  when others then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                end;
              else
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if vc_period = 'Before QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  ---- get third wednesday of QP period
                  --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if (vd_3rd_wed_of_qp <= pd_trade_date and
                     vc_period = 'During QP') or vc_period = 'After QP' then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   vd_qp_end_date);
                  elsif vc_period = 'After QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   pd_trade_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif (vc_period = 'During QP' or vc_period = 'After QP') then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if (vd_3rd_wed_of_qp <= pd_trade_date and
                     vc_period = 'During QP') or vc_period = 'After QP' then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  if vc_period = 'During QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   vd_qp_end_date);
                  elsif vc_period = 'After QP' then
                    vc_prompt_date := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                   pd_trade_date);
                  
                  end if;
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_qp_price,
                         vc_during_qp_price_unit_id
                    from dq_derivative_quotes          dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id = cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes          dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_during_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id =
                                 cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_during_qp_price         := 0;
                    vc_during_qp_price_unit_id := null;
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_during_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      end if;
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_price_unit_id;
  end;

  procedure sp_calc_conc_gmr_price(pc_internal_gmr_ref_no varchar2,
                                   pc_element_id          varchar2,
                                   pd_trade_date          date,
                                   pn_price               out number,
                                   pc_price_unit_id       out varchar2) is
    cursor cur_gmr is
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             gmr.qty_unit_id,
             grd.product_id,
             pd_trade_date eod_trade_date,
             tt.instrument_id,
             tt.instrument_name,
             tt.price_source_id,
             tt.price_source_name,
             tt.available_price_id,
             tt.available_price_name,
             tt.price_unit_name,
             tt.ppu_price_unit_id,
             tt.price_unit_id,
             tt.delivery_calender_id,
             tt.is_daily_cal_applicable,
             tt.is_monthly_cal_applicable,
             spq.element_id,
             spq.payable_qty,
             spq.qty_unit_id payable_qty_unit_id
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from grd_goods_record_detail grd
               where grd.status = 'Active'
                 and grd.is_deleted = 'N'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             v_gmr_stockpayable_qty spq,
             (select qat.internal_gmr_ref_no,
                     qat.instrument_id,
                     qat.element_id,
                     dim.instrument_name,
                     ps.price_source_id,
                     ps.price_source_name,
                     apm.available_price_id,
                     apm.available_price_name,
                     pum.price_unit_name,
                     vdip.ppu_price_unit_id,
                     div.price_unit_id,
                     dim.delivery_calender_id,
                     pdc.is_daily_cal_applicable,
                     pdc.is_monthly_cal_applicable
                from v_gmr_exchange_details       qat,
                     dim_der_instrument_master    dim,
                     div_der_instrument_valuation div,
                     ps_price_source              ps,
                     apm_available_price_master   apm,
                     pum_price_unit_master        pum,
                     v_der_instrument_price_unit  vdip,
                     pdc_prompt_delivery_calendar pdc
               where qat.instrument_id = dim.instrument_id
                 and dim.instrument_id = div.instrument_id
                 and div.is_deleted = 'N'
                 and div.price_source_id = ps.price_source_id
                 and div.available_price_id = apm.available_price_id
                 and div.price_unit_id = pum.price_unit_id
                 and dim.instrument_id = vdip.instrument_id
                 and dim.delivery_calender_id =
                     pdc.prompt_delivery_calendar_id) tt
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdtm.product_type_name = 'Composite'
         and tt.element_id = spq.element_id
         and tt.internal_gmr_ref_no = spq.internal_gmr_ref_no
         and gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
         and gmr.is_deleted = 'N'
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and spq.element_id = pc_element_id
      union all
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             gmr.qty_unit_id,
             grd.product_id,
             pd_trade_date eod_trade_date,
             tt.instrument_id,
             tt.instrument_name,
             tt.price_source_id,
             tt.price_source_name,
             tt.available_price_id,
             tt.available_price_name,
             tt.price_unit_name,
             tt.ppu_price_unit_id,
             tt.price_unit_id,
             tt.delivery_calender_id,
             tt.is_daily_cal_applicable,
             tt.is_monthly_cal_applicable,
             spq.element_id,
             spq.payable_qty,
             spq.qty_unit_id payable_qty_unit_id
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from dgrd_delivered_grd grd
               where grd.status = 'Active'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             v_gmr_stockpayable_qty spq,
             (select qat.internal_gmr_ref_no,
                     qat.instrument_id,
                     qat.element_id,
                     dim.instrument_name,
                     ps.price_source_id,
                     ps.price_source_name,
                     apm.available_price_id,
                     apm.available_price_name,
                     pum.price_unit_name,
                     vdip.ppu_price_unit_id,
                     div.price_unit_id,
                     dim.delivery_calender_id,
                     pdc.is_daily_cal_applicable,
                     pdc.is_monthly_cal_applicable
                from v_gmr_exchange_details       qat,
                     dim_der_instrument_master    dim,
                     div_der_instrument_valuation div,
                     ps_price_source              ps,
                     apm_available_price_master   apm,
                     pum_price_unit_master        pum,
                     v_der_instrument_price_unit  vdip,
                     pdc_prompt_delivery_calendar pdc
               where qat.instrument_id = dim.instrument_id
                 and dim.instrument_id = div.instrument_id
                 and div.is_deleted = 'N'
                 and div.price_source_id = ps.price_source_id
                 and div.available_price_id = apm.available_price_id
                 and div.price_unit_id = pum.price_unit_id
                 and dim.instrument_id = vdip.instrument_id
                 and dim.delivery_calender_id =
                     pdc.prompt_delivery_calendar_id) tt
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdm.product_type_id = 'Composite'
         and tt.element_id = spq.element_id
         and tt.internal_gmr_ref_no = spq.internal_gmr_ref_no
         and gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
         and gmr.is_deleted = 'N'
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and spq.element_id = pc_element_id;
    cursor cur_gmr_ele(pc_internal_gmr_ref_no varchar2, pc_element_id varchar2) is
      select pofh.internal_gmr_ref_no,
             pofh.pofh_id,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.qty_to_be_fixed,
             pcbpd.element_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pocd.is_any_day_pricing,
             pcbpd.price_basis,
             pcbph.price_description,
             pofh.no_of_prompt_days
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where pofh.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pcbpd.element_id = pc_element_id
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(50);
    vd_3rd_wed_of_qp               date;
    vn_workings_days               number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_total_contract_value        number;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vn_during_qp_price             number;
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_value number;
    vn_anyday_price_ufix_qty_value number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_price_unit_id               varchar2(15);
    vc_ppu_price_unit_id           varchar2(15);
    vc_price_name                  varchar2(100);
    vc_pcbpd_id                    varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vn_qty_to_be_priced            number;
    vn_total_quantity              number;
    vn_average_price               number;
  begin
    for cur_gmr_rows in cur_gmr
    loop
      vn_total_contract_value := 0;
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no,
                                          cur_gmr_rows.element_id)
      loop
        vn_market_flag                 := null;
        vn_any_day_price_fix_qty_value := 0;
        vn_anyday_price_ufix_qty_value := 0;
        vn_any_day_unfixed_qty         := 0;
        vn_any_day_fixed_qty           := 0;
        vc_pcbpd_id                    := cur_gmr_ele_rows.pcbpd_id;
        vc_price_unit_id               := null;
        vc_ppu_price_unit_id           := null;
        vd_qp_start_date               := cur_gmr_ele_rows.qp_start_date;
        vd_qp_end_date                 := cur_gmr_ele_rows.qp_end_date;
        if cur_gmr_rows.eod_trade_date >= vd_qp_start_date and
           cur_gmr_rows.eod_trade_date <= vd_qp_end_date then
          vc_period := 'During QP';
        elsif cur_gmr_rows.eod_trade_date < vd_qp_start_date and
              cur_gmr_rows.eod_trade_date < vd_qp_end_date then
          vc_period := 'Before QP';
        elsif cur_gmr_rows.eod_trade_date > vd_qp_start_date and
              cur_gmr_rows.eod_trade_date > vd_qp_end_date then
          vc_period := 'After QP';
        end if;
        begin
          select ppu.product_price_unit_id,
                 ppu.price_unit_id,
                 ppu.price_unit_name
            into vc_ppu_price_unit_id,
                 vc_price_unit_id,
                 vc_price_name
            from ppfh_phy_price_formula_header ppfh,
                 v_ppu_pum                     ppu
           where ppfh.pcbpd_id = vc_pcbpd_id
             and ppfh.price_unit_id = ppu.product_price_unit_id
             and rownum <= 1;
        exception
          when no_data_found then
            vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
            vc_price_unit_id     := cur_gmr_rows.price_unit_id;
            vc_price_name        := cur_gmr_rows.price_unit_name;
          when others then
            vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
            vc_price_unit_id     := cur_gmr_rows.price_unit_id;
            vc_price_name        := cur_gmr_rows.price_unit_name;
        end;
        if vc_period = 'Before QP' then
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
            vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date, 'Wed', 3);
            while true
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                  vd_3rd_wed_of_qp) then
                vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
              else
                exit;
              end if;
            end loop;
            --- get 3rd wednesday  before QP period
            -- Get the quotation date = Trade Date +2 working Days
            if vd_3rd_wed_of_qp <= pd_trade_date then
              vn_workings_days := 0;
              vd_quotes_date   := pd_trade_date + 1;
              while vn_workings_days <> 2
              loop
                if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                    vd_quotes_date) then
                  vd_quotes_date := vd_quotes_date + 1;
                else
                  vn_workings_days := vn_workings_days + 1;
                  if vn_workings_days <> 2 then
                    vd_quotes_date := vd_quotes_date + 1;
                  end if;
                end if;
              end loop;
              vd_3rd_wed_of_qp := vd_quotes_date;
            end if;
            ---- get the dr_id
            begin
              select drm.dr_id
                into vc_before_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.prompt_date = vd_3rd_wed_of_qp
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vc_before_price_dr_id := null;
            end;
          elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
                cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
            vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                            vd_qp_end_date);
            vc_prompt_month := to_char(vc_prompt_date, 'Mon');
            vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
            ---- get the dr_id
            begin
              select drm.dr_id
                into vc_before_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.period_month = vc_prompt_month
                 and drm.period_year = vc_prompt_year
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vc_before_price_dr_id := null;
            end;
          end if;
          begin
            select dqd.price,
                   dqd.price_unit_id
              into vn_before_qp_price,
                   vc_before_qp_price_unit_id
              from dq_derivative_quotes          dq,
                   v_dqd_derivative_quote_detail dqd
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_before_price_dr_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = cur_gmr_rows.price_source_id
               and dqd.price_unit_id = vc_price_unit_id
               and dq.corporate_id = cur_gmr_rows.corporate_id
               and dq.is_deleted = 'N'
               and dqd.is_deleted = 'N'
               and dq.trade_date =
                   (select max(dq.trade_date)
                      from dq_derivative_quotes          dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_before_price_dr_id
                       and dq.instrument_id = cur_gmr_rows.instrument_id
                       and dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                       and dq.price_source_id = cur_gmr_rows.price_source_id
                       and dqd.price_unit_id = vc_price_unit_id
                       and dq.corporate_id = cur_gmr_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date <= pd_trade_date);
          exception
            when no_data_found then
              vn_before_qp_price         := 0;
              vc_before_qp_price_unit_id := null;
          end;
          vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                          cur_gmr_rows.payable_qty_unit_id,
                                                                          cur_gmr_rows.qty_unit_id,
                                                                          cur_gmr_rows.payable_qty);
          vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_total_quantity *
                                     (vn_qty_to_be_priced / 100) *
                                     vn_before_qp_price;
        elsif (vc_period = 'During QP' or vc_period = 'After QP') then
          vd_dur_qp_start_date      := vd_qp_start_date;
          vd_dur_qp_end_date        := vd_qp_end_date;
          vn_during_total_set_price := 0;
          vn_count_set_qp           := 0;
          for cc in (select pfd.user_price,
                            pfd.as_of_date,
                            pfd.qty_fixed,
                            pofh.final_price,
                            pocd.is_any_day_pricing
                       from poch_price_opt_call_off_header poch,
                            pocd_price_option_calloff_dtls pocd,
                            pofh_price_opt_fixation_header pofh,
                            pfd_price_fixation_details     pfd
                      where poch.poch_id = pocd.poch_id
                        and pocd.pocd_id = pofh.pocd_id
                        and pofh.pofh_id = cur_gmr_ele_rows.pofh_id
                        and pofh.pofh_id = pfd.pofh_id
                        and pfd.as_of_date >= vd_dur_qp_start_date
                        and pfd.as_of_date <= pd_trade_date
                        and poch.is_active = 'Y'
                        and pocd.is_active = 'Y'
                        and pofh.is_active = 'Y'
                        and pfd.is_active = 'Y')
          loop
            vn_during_total_set_price := vn_during_total_set_price +
                                         cc.user_price;
            vn_count_set_qp           := vn_count_set_qp + 1;
            vn_any_day_fixed_qty      := vn_any_day_fixed_qty +
                                         cc.qty_fixed;
          
            vn_any_day_price_fix_qty_value := vn_any_day_price_fix_qty_value +
                                              (cc.user_price * cc.qty_fixed);
          end loop;
          if cur_gmr_ele_rows.is_any_day_pricing = 'Y' then
            vn_market_flag := 'N';
          else
            vn_market_flag := 'Y';
          end if;
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
            -- get the third wednes day
            vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date, 'Wed', 3);
            while true
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                  vd_3rd_wed_of_qp) then
                vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
              else
                exit;
              end if;
            end loop;
            --- get 3rd wednesday  before QP period
            -- Get the quotation date = Trade Date +2 working Days
            if (vd_3rd_wed_of_qp <= pd_trade_date and
               vc_period = 'During QP') or vc_period = 'After QP' then
              vn_workings_days := 0;
              vd_quotes_date   := pd_trade_date + 1;
              while vn_workings_days <> 2
              loop
                if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                    vd_quotes_date) then
                  vd_quotes_date := vd_quotes_date + 1;
                else
                  vn_workings_days := vn_workings_days + 1;
                  if vn_workings_days <> 2 then
                    vd_quotes_date := vd_quotes_date + 1;
                  end if;
                end if;
              end loop;
              vd_3rd_wed_of_qp := vd_quotes_date;
            end if;
            begin
              select drm.dr_id
                into vc_during_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.prompt_date = vd_3rd_wed_of_qp
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vc_during_price_dr_id := null;
            end;
          elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
                cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
            if vc_period = 'During QP' then
              vc_prompt_date := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                             vd_qp_end_date);
            elsif vc_period = 'After QP' then
              vc_prompt_date := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                             pd_trade_date);
            end if;
            vc_prompt_month := to_char(vc_prompt_date, 'Mon');
            vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
            ---- get the dr_id
            begin
              select drm.dr_id
                into vc_during_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.period_month = vc_prompt_month
                 and drm.period_year = vc_prompt_year
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vc_during_price_dr_id := null;
            end;
          end if;
          begin
            select dqd.price,
                   dqd.price_unit_id
              into vn_during_val_price,
                   vc_during_val_price_unit_id
              from dq_derivative_quotes          dq,
                   v_dqd_derivative_quote_detail dqd
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_during_price_dr_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = cur_gmr_rows.price_source_id
               and dqd.price_unit_id = vc_price_unit_id
               and dq.corporate_id = cur_gmr_rows.corporate_id
               and dq.is_deleted = 'N'
               and dqd.is_deleted = 'N'
               and dq.trade_date =
                   (select max(dq.trade_date)
                      from dq_derivative_quotes          dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_during_price_dr_id
                       and dq.instrument_id = cur_gmr_rows.instrument_id
                       and dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                       and dq.price_source_id = cur_gmr_rows.price_source_id
                       and dqd.price_unit_id = vc_price_unit_id
                       and dq.corporate_id = cur_gmr_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date <= pd_trade_date);
          exception
            when no_data_found then
              vn_during_val_price         := 0;
              vc_during_val_price_unit_id := null;
          end;
          vn_during_total_val_price := 0;
          vn_count_val_qp           := 0;
          vd_dur_qp_start_date      := pd_trade_date + 1;
          if vn_market_flag = 'N' then
            vn_during_total_val_price      := vn_during_total_val_price +
                                              vn_during_val_price;
            vn_any_day_unfixed_qty         := cur_gmr_ele_rows.qty_to_be_fixed -
                                              vn_any_day_fixed_qty;
            vn_count_val_qp                := vn_count_val_qp + 1;
            vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                              vn_during_total_val_price);
          else
            vn_count_val_qp           := cur_gmr_ele_rows.no_of_prompt_days -
                                         vn_count_set_qp;
            vn_during_total_val_price := vn_during_total_val_price +
                                         vn_during_val_price *
                                         vn_count_val_qp;
          
          end if;
          if (vn_count_val_qp + vn_count_set_qp) <> 0 then
            if vn_market_flag = 'N' then
              vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                    vn_anyday_price_ufix_qty_value) /
                                    cur_gmr_ele_rows.qty_to_be_fixed;
            else
              vn_during_qp_price := (vn_during_total_set_price +
                                    vn_during_total_val_price) /
                                    (vn_count_set_qp + vn_count_val_qp);
            end if;
            vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                            cur_gmr_rows.payable_qty_unit_id,
                                                                            cur_gmr_rows.qty_unit_id,
                                                                            cur_gmr_rows.payable_qty);
            vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_during_qp_price;
          else
            vn_total_contract_value := 0;
          end if;
        end if;
      end loop;
      vn_average_price := round(vn_total_contract_value / vn_total_quantity,
                                3);
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_ppu_price_unit_id;
  end;

  function f_get_next_day(pd_date     in date,
                          pc_day      in varchar2,
                          pn_position in number) return date is
    vd_position_date date;
  begin
    select next_day((trunc(pd_date, 'Mon') - 1), pc_day) +
           ((pn_position * 7) - 7)
      into vd_position_date
      from dual;
    return vd_position_date;
  end;

  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean is
    vn_counter    number(1);
    vb_result_val boolean;
  begin
    --Checking the Week End Holiday List
    begin
      select count(*)
        into vn_counter
        from dual
       where to_char(pc_trade_date, 'Dy') in
             (select clwh.holiday
                from dim_der_instrument_master    dim,
                     clm_calendar_master          clm,
                     clwh_calendar_weekly_holiday clwh
               where dim.holiday_calender_id = clm.calendar_id
                 and clm.calendar_id = clwh.calendar_id
                 and dim.instrument_id = pc_instrumentid
                 and clm.is_deleted = 'N'
                 and clwh.is_deleted = 'N');
      if (vn_counter = 1) then
        vb_result_val := true;
      else
        vb_result_val := false;
      end if;
      if (vb_result_val = false) then
        --Checking Other Holiday List
        select count(*)
          into vn_counter
          from dual
         where trim(pc_trade_date) in
               (select trim(hl.holiday_date)
                  from hm_holiday_master         hm,
                       hl_holiday_list           hl,
                       dim_der_instrument_master dim,
                       clm_calendar_master       clm
                 where hm.holiday_id = hl.holiday_id
                   and dim.holiday_calender_id = clm.calendar_id
                   and clm.calendar_id = hm.calendar_id
                   and dim.instrument_id = pc_instrumentid
                   and hm.is_deleted = 'N'
                   and hl.is_deleted = 'N');
        if (vn_counter = 1) then
          vb_result_val := true;
        else
          vb_result_val := false;
        end if;
      end if;
    end;
    return vb_result_val;
  end;

  function f_get_next_month_prompt_date(pc_promp_del_cal_id varchar2,
                                        pd_trade_date       date) return date is
    cursor cur_monthly_prompt_rule is
      select mpc.*
        from mpc_monthly_prompt_calendar mpc
       where mpc.prompt_delivery_calendar_id = pc_promp_del_cal_id;
    cursor cr_applicable_months is
      select mpcm.*
        from mpcm_monthly_prompt_cal_month mpcm,
             mnm_month_name_master         mnm
       where mpcm.prompt_delivery_calendar_id = pc_promp_del_cal_id
         and mpcm.applicable_month = mnm.month_name_id
       order by mnm.display_order;
    vc_pdc_period_type_id      varchar2(15);
    vc_month_prompt_start_date date;
    vc_equ_period_type         number;
    cr_monthly_prompt_rule_rec cur_monthly_prompt_rule%rowtype;
    vc_period_to               number;
    vd_start_date              date;
    vd_end_date                date;
    vc_month                   varchar2(15);
    vn_year                    number;
    vn_month_count             number(5);
    vd_prompt_date             date;
  begin
    vc_month_prompt_start_date := pd_trade_date;
    vn_month_count             := 0;
    begin
      select pm.period_type_id
        into vc_pdc_period_type_id
        from pm_period_master pm
       where pm.period_type_name = 'Month';
    end;
    open cur_monthly_prompt_rule;
    fetch cur_monthly_prompt_rule
      into cr_monthly_prompt_rule_rec;
    vc_period_to := cr_monthly_prompt_rule_rec.period_for; --no of forward months required
    begin
      select pm.equivalent_days
        into vc_equ_period_type
        from pm_period_master pm
       where pm.period_type_id = cr_monthly_prompt_rule_rec.period_type_id;
    end;
    vd_start_date := vc_month_prompt_start_date;
    vd_end_date   := vc_month_prompt_start_date +
                     (vc_period_to * vc_equ_period_type);
    for cr_applicable_months_rec in cr_applicable_months
    loop
      vc_month_prompt_start_date := to_date(('01-' ||
                                            cr_applicable_months_rec.applicable_month || '-' ||
                                            to_char(vd_start_date, 'YYYY')),
                                            'dd/mm/yyyy');
      --------------------
      if (vc_month_prompt_start_date >=
         to_date(('01-' || to_char(vd_start_date, 'Mon-YYYY')),
                  'dd/mm/yyyy') and
         vc_month_prompt_start_date <= vd_end_date) then
        vn_month_count := vn_month_count + 1;
        if vn_month_count = 1 then
          vc_month := to_char(vc_month_prompt_start_date, 'Mon');
          vn_year  := to_char(vc_month_prompt_start_date, 'YYYY');
        end if;
      end if;
      exit when vn_month_count > 1;
      ---------------
    end loop;
    close cur_monthly_prompt_rule;
    if vc_month is not null and vn_year is not null then
      vd_prompt_date := to_date('01-' || vc_month || '-' || vn_year,
                                'dd-Mon-yyyy');
    end if;
    return vd_prompt_date;
  end;

end;
/
CREATE TABLE FMUH_FREE_METAL_UTILITY_HEADER
(
  FMUH_ID                     VARCHAR2(15 CHAR),
  UTILITY_REF_NO              VARCHAR2(15 CHAR),
  SMELTER_ID                  VARCHAR2(15 CHAR),
  CONSUMPTION_MONTH           VARCHAR2 (15 CHAR),
  CONSUMPTION_YEAR            VARCHAR2 (15 CHAR),
  QP_START_DATE               DATE,
  QP_END_DATE                 DATE,
  INTERNAL_ACTION_REF_NO      VARCHAR2(15 CHAR),
  VERSION                     NUMBER(10),
  IS_ACTIVE                   CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMUH ON FMUH_FREE_METAL_UTILITY_HEADER
(FMUH_ID);

ALTER TABLE FMUH_FREE_METAL_UTILITY_HEADER ADD (
  CONSTRAINT PK_FMUH
 PRIMARY KEY (FMUH_ID));


CREATE TABLE FMED_FREE_METAL_ELEMT_DETAILS
(
  FMED_ID                  VARCHAR2(15 CHAR),
  FMUH_ID                  VARCHAR2(15 CHAR),
  ELEMENT_ID               VARCHAR2(15 CHAR),
  ELEMENT_NAME             VARCHAR2(30 CHAR),
  PRICE_BASIS              VARCHAR2(15 CHAR),
  PRICE_UNIT_ID            VARCHAR2(15 CHAR),
  FORMULA_ID               VARCHAR2(15 CHAR),
  FORMULA_NAME             VARCHAR2(50 CHAR),
  FORMULA_DESCRIPTION      VARCHAR2(100 CHAR),
  INTERNAL_FORMULA_DESC    VARCHAR2(100 CHAR),
  VERSION                  NUMBER(10),
  IS_ACTIVE                CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMED ON FMED_FREE_METAL_ELEMT_DETAILS
(FMED_ID);

ALTER TABLE FMED_FREE_METAL_ELEMT_DETAILS ADD (
  CONSTRAINT PK_FMED
 PRIMARY KEY (FMED_ID));

ALTER TABLE FMED_FREE_METAL_ELEMT_DETAILS ADD (
 CONSTRAINT FMED_UTILITY_HEADER_ID 
 FOREIGN KEY (FMUH_ID) 
 REFERENCES FMUH_FREE_METAL_UTILITY_HEADER (FMUH_ID),
 CONSTRAINT FMED_PRICE_UNIT_ID 
 FOREIGN KEY (PRICE_UNIT_ID) 
 REFERENCES PPU_PRODUCT_PRICE_UNITS (INTERNAL_PRICE_UNIT_ID));

  
CREATE TABLE FMEIFD_INDEX_FORMULA_DETAILS
(
  FMEIFD_ID                VARCHAR2(15 CHAR),
  FMED_ID                  VARCHAR2(15 CHAR),
  INSTRUMENT_ID            VARCHAR2(15 CHAR),
  INSTRUMENT_NAME          VARCHAR2(50 CHAR),
  PRICE_SOURCE_ID          VARCHAR2(15 CHAR),
  PRICE_POINT_ID           VARCHAR2(15 CHAR),
  AVAILABLE_PRICE_TYPE_ID  VARCHAR2(15 CHAR),
  VALUE_DATE_TYPE          VARCHAR2(30 CHAR),
  VALUE_DATE               DATE,
  VALUE_MONTH              VARCHAR2(15 CHAR),
  VALUE_YEAR               VARCHAR2(15 CHAR),
  OFF_DAY_PRICE            VARCHAR2(30 CHAR),
  VERSION                  NUMBER(10),
  IS_ACTIVE                CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMEIFD ON FMEIFD_INDEX_FORMULA_DETAILS
(FMEIFD_ID);

ALTER TABLE FMEIFD_INDEX_FORMULA_DETAILS ADD (
  CONSTRAINT PK_FMEIFD
 PRIMARY KEY (FMEIFD_ID));
  
ALTER TABLE FMEIFD_INDEX_FORMULA_DETAILS ADD (
  CONSTRAINT FMEIFD_AVAILABLE_PRICE_TYPE_ID 
 FOREIGN KEY (AVAILABLE_PRICE_TYPE_ID) 
 REFERENCES APM_AVAILABLE_PRICE_MASTER (AVAILABLE_PRICE_ID),
  CONSTRAINT FMEIFD_INSTRUMENT_ID 
 FOREIGN KEY (INSTRUMENT_ID) 
 REFERENCES DIM_DER_INSTRUMENT_MASTER (INSTRUMENT_ID),
  CONSTRAINT FMEIFD_ELEMENT_ID 
 FOREIGN KEY (FMED_ID) 
 REFERENCES FMED_FREE_METAL_ELEMT_DETAILS (FMED_ID),
  CONSTRAINT FMEIFD_PRICE_POINT_ID 
 FOREIGN KEY (PRICE_POINT_ID) 
 REFERENCES PP_PRICE_POINT (PRICE_POINT_ID),
  CONSTRAINT FMEIFD_PRICE_SOURCE_ID 
 FOREIGN KEY (PRICE_SOURCE_ID) 
 REFERENCES PS_PRICE_SOURCE (PRICE_SOURCE_ID));

CREATE TABLE FMPFH_PRICE_FIXATION_HEADER
(
  FMPFH_ID                    VARCHAR2(15 CHAR),
  FMED_ID                     VARCHAR2(15 CHAR),
  ELEMENT_ID                  VARCHAR2(15 CHAR),
  QTY_TO_BE_FIXED             NUMBER(25,10),
  PRICED_QTY                  NUMBER(25,10),
  NO_OF_PROMPT_DAYS           NUMBER(25,10),
  PER_DAY_PRICING_QTY         NUMBER(25,10),
  AVG_FINAL_PRICE             NUMBER(25,10),
  FINALIZE_DATE               DATE,
  NO_OF_PROMPT_DAYS_FIXED     NUMBER(25,10)     DEFAULT 0,
  AVG_PRICE_IN_PRICE_IN_CUR	  NUMBER (25,10),		
  AVG_FX	                  NUMBER (25,10),	
  FINAL_PRICE_IN_PRICING_CUR  NUMBER (25,10),
  VERSION                     NUMBER(10),
  IS_ACTIVE                   CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMPFH ON FMPFH_PRICE_FIXATION_HEADER
(FMPFH_ID);

ALTER TABLE FMPFH_PRICE_FIXATION_HEADER ADD (
  CONSTRAINT PK_FMPFH
 PRIMARY KEY (FMPFH_ID));
 
ALTER TABLE FMPFH_PRICE_FIXATION_HEADER ADD (
  CONSTRAINT FMPFH_FMED_ID 
 FOREIGN KEY (FMED_ID) 
 REFERENCES FMED_FREE_METAL_ELEMT_DETAILS (FMED_ID));

CREATE TABLE FMPFD_PRICE_FIXATION_DETAILS
(
  FMPFD_ID             VARCHAR2(15 CHAR),
  FMPFH_ID             VARCHAR2(15 CHAR),
  FPD_ID               VARCHAR2(15 CHAR),
  AS_OF_DATE           DATE,
  QTY_FIXED            NUMBER(25,10),
  USER_PRICE           NUMBER(25,10),
  PRICE_UNIT_ID        VARCHAR2(15 CHAR),
  FX_RATE              NUMBER(25,10),
  FX_TO_BASE           NUMBER(25,10),
  VERSION              NUMBER(10),
  IS_ACTIVE            CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMPFD ON FMPFD_PRICE_FIXATION_DETAILS
(FMPFD_ID);

ALTER TABLE FMPFD_PRICE_FIXATION_DETAILS ADD (
  CONSTRAINT PK_FMPFD
 PRIMARY KEY (FMPFD_ID));
 
ALTER TABLE FMPFD_PRICE_FIXATION_DETAILS ADD (
  CONSTRAINT FMPFD_FMPFH_ID 
 FOREIGN KEY (FMPFH_ID) 
 REFERENCES FMPFH_PRICE_FIXATION_HEADER (FMPFH_ID));

CREATE TABLE FMPFAM_PRICE_ACTION_MAPPING
(
  FMPFAM_ID                 VARCHAR2(15 CHAR),
  FMPFD_ID                  VARCHAR2(15 CHAR),
  INTERNAL_ACTION_REF_NO  VARCHAR2(15 CHAR),
  VERSION                 NUMBER(10),
  IS_ACTIVE               CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMPFAM_ID ON FMPFAM_PRICE_ACTION_MAPPING
(FMPFAM_ID);

ALTER TABLE FMPFAM_PRICE_ACTION_MAPPING ADD (
  CONSTRAINT PK_FMPFAM_ID
 PRIMARY KEY
 (FMPFAM_ID));

ALTER TABLE FMPFAM_PRICE_ACTION_MAPPING ADD (
  CONSTRAINT FMPFAM_INT_ACTION_REF_NO 
 FOREIGN KEY (INTERNAL_ACTION_REF_NO) 
 REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO));


CREATE SEQUENCE SEQ_FMUH
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;
  

CREATE SEQUENCE SEQ_FMED
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;
  

CREATE SEQUENCE SEQ_FMPFH
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


CREATE SEQUENCE SEQ_FMPFD
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

CREATE SEQUENCE SEQ_FMPFAM
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

 CREATE SEQUENCE SEQ_FMEIFD
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;
  
alter table PPL_PRICE_PROCESS_LIST add  FMUH_ID varchar2(15);
alter table PPLI_PRICE_PROCESS_ITEM_LIST add fmpfh_id varchar2(15);
alter table FMUH_FREE_METAL_UTILITY_HEADER add corporate_id varchar2(15);
alter table FMED_FREE_METAL_ELEMT_DETAILS add qty_unit_id varchar2(15);
alter table FMUH_FREE_METAL_UTILITY_HEADER add STATUS varchar2(30);
alter table FMPFH_PRICE_FIXATION_HEADER add HEDGE_CORRECTION_DATE DATE;
alter table FMED_FREE_METAL_ELEMT_DETAILS add INTERNAL_GMR_REF_NO varchar2(15);
alter table FMUH_FREE_METAL_UTILITY_HEADER add IS_FULLY_PRICE_FIXED varchar2(15);
alter table FMUH_FREE_METAL_UTILITY_HEADER add BASE_CUR_ID varchar2(15);
alter table POFH_PRICE_OPT_FIXATION_HEADER drop column TOTAT_HEDGE_CORRE_QTY;
alter table POFH_PRICE_OPT_FIXATION_HEADER add TOTAL_HEDGE_CORRECTION_QTY number(25,10);
alter table POFH_PRICE_OPT_FIXATION_HEADER drop column PER_DAY_HEDGE_CORRE_QTY;
alter table POFH_PRICE_OPT_FIXATION_HEADER add PER_DAY_HEDGE_CORRECTION_QTY number(25,10);
alter table PFD_PRICE_FIXATION_DETAILS add HEDGE_CORRECTION_ACTION_REF_NO varchar(30);
alter table PFD_PRICE_FIXATION_DETAILS add IS_HEDGE_CORRECTION_DURING_QP CHAR (1 Char);
alter table PFD_PRICE_FIXATION_DETAILS drop column  IS_HEDGE_CORRE_BEFORE_QP ;
alter table POFH_PRICE_OPT_FIXATION_HEADER drop column TOTAL_HEDGE_CORRECTION_QTY;
alter table POFH_PRICE_OPT_FIXATION_HEADER add TOTAL_HEDGE_CORRECTED_QTY number(25,10);
alter table POCD_PRICE_OPTION_CALLOFF_DTLS add FX_CONVERSION_METHOD varchar(30);
alter table HCD_HEDGE_CORRECTION_DETAILS add IS_HEDGE_CORRECTION_DURING_QP char(1 char );

ALTER TABLE IVD_INVOICE_VAT_DETAILS ADD (VAT_CODE_NAME VARCHAR2(30));

ALTER TABLE VAT_D ADD (INVOICE_DUE_DATE  VARCHAR2(30));

create or replace view v_invoice_doc as
select        'Invoice' section_name,
              'Invoice' sub_section,
               rownum record_no,
               akc.corporate_id,
               akc.corporate_name,
               akc.address1,
               akc.address2,
               akc.city,
               akc.state,
               akc.country,
               akc.logo_path,
               akc.phone_no,
               akc.fax_no,
               isd.internal_doc_ref_no,
               isd.due_date,
               isd.sales_purchase,
               isd.cp_name,
               isd.supplire_invoice_no cp_item_stock_ref_no,
               '' business_unit,
               isd.self_item_stock_ref_no,
               isd.inco_term_location,
               isd.contract_ref_no self_contract_item_no,
               isd.contract_date,
               isd.notify_party,
               isd.org_name,
               isd.cp_contract_ref_no,
               isd.productandquality_name,
               isd.contract_tolerance,
               isd.contract_quantity,
               isd.contract_qty_unit,
               isd.invoice_ref_no provisional_invoice_no,
               isd.internal_invoice_ref_no,
               isd.product,
               isd.quality,
               isd.invoice_amount amount,
               isd.invoice_amount_unit,
               isd.payment_term,
               isd.invoice_creation_date,
               null invoice_issue_date,
               isd.invoice_quantity,
               isd.invoice_dry_quantity,
               isd.invoice_wet_quantity,
               isd.invoiced_qty_unit,
               isd.moisture,
               isd.invoice_type_name invoice_type,
               isd.stock_size,
               isd.packing,
               isd.provisional_price,
               isd.origin,
               isd.tarriff,
               '' final_qty,
               isd.material_cost final_amount,
               ispcd.invoice_ref_no pi_number,
               ispcd.invoice_amount provisional_amount,
               '' amount_due,
               isd.addditional_charges,
               isd.taxes,
               isd.contract_type product_type,
               isd.Invoice_Status,
               isd.gmr_ref_no pledge_gmr_ref_no,
               isd.gmr_quality pledge_gmr_qty,
               isd.stock_ref_no pledge_stock_ref_no,
               isd.stock_quantity pledge_stock_qty,
               isc.internal_doc_ref_no internal_doc_ref_no0,
               isc.stock_ref_no,
               isc.stock_qty || '' || isc.invoiced_qty_unit stock_qty,
               isc.gmr_ref_no,
               isc.gmr_quality,
               isc.gmr_quantity,
               isc.price_as_per_defind_uom,
               isc.item_amount_in_inv_cur,
               isc.invoiced_price_unit,
               null element_price_unit,
               isc.total_price_qty total_quantity,
               isc.gmr_qty_unit,
               isp_c1.internal_doc_ref_no internal_doc_ref_no1,
               isp_c1.beneficiary_name benificiary_name_c1,
               isp_c1.bank_name bank_name_c1,
               isp_c1.account_no account_no_c1,
               isp_c1.iban iban_c1,
               isp_c1.aba_rtn aba_rtn_c1,
               isp_c1.instruction instruction_c1,
               isp_c2.internal_doc_ref_no internal_doc_ref_no2,
               isp_c2.beneficiary_name benificiary_name_c2,
               isp_c2.bank_name bank_name_c2,
               isp_c2.account_no account_no_c2,
               isp_c2.iban iban_c2,
               isp_c2.aba_rtn aba_rtn_c2,
               isp_c2.instruction instruction_c2,
               is_cp.internal_doc_ref_no internal_doc_ref_no3,
               is_cp.stock_ref_no stock_ref_no1,
               is_cp.gmr_ref_no stock_gmr_ref_no,
               is_cp.gmr_quantity cp_gmr_quantity,
               is_cp.stock_qty stock_qty1,
               is_cp.gmr_qty_unit gmr_qty_unit1,
               is_cp.element_id payable_element_id,
               is_cp.element_name payable_element,
               is_cp.assay_content analysis,
               is_cp.assay_content_unit analysis_unit,
               is_cp.invoice_price element_price,
               is_cp.invoiced_price_unit invoiced_price_unit1,
               is_cp.element_price_unit element_price_unit1,
               is_cp.sub_lot_no,
               is_cp.element_inv_amount,
               is_cp.element_invoiced_qty,
               is_cp.element_invoiced_qty_unit,
               null internal_doc_ref_no4,
               null tc_element_id,
               null element_name,
               null tc_rc_sub_lot_no,
               null tc_amount,
               null tc_amount_unit,
               null internal_doc_ref_no5,
               null rc_element_id,
               null element_name1,
               null rc_amount,
               null rc_amount_unit,
               null internal_doc_ref_no6,
               null pen_element_id,
               null element_name2,
               null pen_amount,
               null pen_amount_unit,
               vat.vat_no,
               vat.cp_vat_no,
               vat.vat_code,
               vat.vat_rate,
               vat.vat_rate_unit,
               vat.vat_amount,
               isd.invoice_amount_unit vat_amount_cur,
               isd.is_inv_draft,
               null cost_name,
               null charge_type,
               null charge_amount_rate,
               null charge_amount_rate_unit,
               null fx_rate,
               null charges_quantity,
               null charges_qty_unit,
               null charges_amount,
               null charge_amount_unit,
               null charges_invoice_amount,
               null charges_invoice_cur_name,
               null tax_code,
               null tax_rate,
               null tax_currency,
               null taxes_fx_rate,
               null Applicable_on,
               null taxes_amount,
               null taxes_amount_unit,
               null taxes_invoice_amount,
               null taxes_invoice_amount_cur,
               isd.is_free_metal,
               isd.is_pledge,
               isd.internal_comments,
               (case when  isd.sales_purchase='P' then
                        isp_c1.remarks
                        when isd.sales_purchase='S' then
                        isp_c2.remarks end) remarks,
                isc.yield,
                isc.product gmr_product,
                isc.invoiced_qty_unit child_qty_unit,
                isd.iban,
                api_d.internal_doc_ref_no api_internal_doc_ref_no,
                api_d.api_invoice_ref_no,
                api_d.api_amount_adjusted,
                api_d.invoice_currency api_invoice_currency
  from is_d isd,
       is_child_d isc,
       is_bdp_child_d isp_c1,
       is_bds_child_d isp_c2,
       is_conc_payable_child is_cp,
       is_parent_child_d ispcd,
       api_details_d api_d,
       ds_document_summary ds,
       v_ak_corporate akc,
        (select vat.internal_invoice_ref_no,
                       vat.our_vat_no vat_no,
                       vat.cp_vat_no,
                       vat.vat_code_name vat_code,
                       vat.vat_rate,
                       vat.vat_rate_unit,
                       vat.vat_amount_in_inv_cur vat_amount
                  from ivd_invoice_vat_details vat
                 where vat.is_separate_invoice = 'N')vat
         where isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
           and ds.corporate_id = akc.corporate_id(+)
           and isd.internal_doc_ref_no = isc.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = ispcd.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = api_d.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = isp_c1.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = isp_c2.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = is_cp.internal_doc_ref_no(+)
           and isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
union all
select        'Invoice' section_name,
              'Treatment Charge' sub_section,
               rownum record_no,
               akc.corporate_id,
               akc.corporate_name,
               akc.address1,
               akc.address2,
               akc.city,
               akc.state,
               akc.country,
               akc.logo_path,
               akc.phone_no,
               akc.fax_no,
               isd.internal_doc_ref_no,
               isd.due_date,
               isd.sales_purchase,
               isd.cp_name,
               isd.supplire_invoice_no cp_item_stock_ref_no,
               '' business_unit,
               isd.self_item_stock_ref_no,
               isd.inco_term_location,
               isd.contract_ref_no self_contract_item_no,
               isd.contract_date,
               isd.notify_party,
               isd.org_name,
               isd.cp_contract_ref_no,
               isd.productandquality_name,
               isd.contract_tolerance,
               isd.contract_quantity,
               isd.contract_qty_unit,
               isd.invoice_ref_no provisional_invoice_no,
               isd.internal_invoice_ref_no,
               isd.product,
               isd.quality,
               isd.invoice_amount amount,
               isd.invoice_amount_unit,
               isd.payment_term,
               isd.invoice_creation_date,
               null invoice_issue_date,
               isd.invoice_quantity,
               isd.invoice_dry_quantity,
               isd.invoice_wet_quantity,
               isd.invoiced_qty_unit,
               isd.moisture,
               isd.invoice_type_name invoice_type,
               isd.stock_size,
               isd.packing,
               isd.provisional_price,
               isd.origin,
               isd.tarriff,
               '' final_qty,
               isd.material_cost final_amount,
               '' pi_number,
               '' provisional_amount,
               '' amount_due,
               isd.addditional_charges,
               isd.taxes,
               isd.contract_type product_type,
               isd.Invoice_Status,
               isd.gmr_ref_no pledge_gmr_ref_no,
               isd.gmr_quality pledge_gmr_qty,
               isd.stock_ref_no pledge_stock_ref_no,
               isd.stock_quantity pledge_stock_qty,
               null internal_doc_ref_no0,
               null stock_ref_no1,
               null stock_qty,
               null gmr_ref_no,
               null gmr_quality,
               null gmr_quantity,
               null price_as_per_defind_uom,
               null item_amount_in_inv_cur,
               null invoiced_price_unit,
               null element_price_unit,
               null total_quantity,
               null gmr_qty_unit,
               isp_c1.internal_doc_ref_no internal_doc_ref_no1,
               isp_c1.beneficiary_name benificiary_name_c1,
               isp_c1.bank_name bank_name_c1,
               isp_c1.account_no account_no_c1,
               isp_c1.iban iban_c1,
               isp_c1.aba_rtn aba_rtn_c1,
               isp_c1.instruction instruction_c1,
               isp_c2.internal_doc_ref_no internal_doc_ref_no2,
               isp_c2.beneficiary_name benificiary_name_c2,
               isp_c2.bank_name bank_name_c2,
               isp_c2.account_no account_no_c2,
               isp_c2.iban iban_c2,
               isp_c2.aba_rtn aba_rtn_c2,
               isp_c2.instruction instruction_c2,
               null internal_doc_ref_no3,
               null stock_ref_no1,
               null stock_gmr_ref_no,
               null cp_gmr_quantity,
               null stock_qty1,
               null gmr_qty_unit1,
               null payable_element_id,
               null payable_element,
               null analysis,
               null analysis_unit,
               null element_price,
               null invoiced_price_unit1,
               null element_price_unit1,
               null sub_lot_no,
               null element_inv_amount,
               null element_invoiced_qty,
               null element_invoiced_qty_unit,
               istc.internal_doc_ref_no internal_doc_ref_no4,
               istc.tc_element_id,
               istc.element_name,
               istc.sub_lot_no tc_rc_sub_lot_no,
               istc.tc_amount,
               istc.tc_amount_unit,
               null internal_doc_ref_no5,
               null rc_element_id,
               null element_name1,
               null rc_amount,
               null rc_amount_unit,
               null internal_doc_ref_no6,
               null pen_element_id,
               null element_name2,
               null pen_amount,
               null pen_amount_unit,
               vat.vat_no,
               vat.cp_vat_no,
               vat.vat_code,
               vat.vat_rate,
               vat.vat_rate_unit,
               vat.vat_amount,
               isd.invoice_amount_unit vat_amount_cur,
               isd.is_inv_draft,
               null cost_name,
               null charge_type,
               null charge_amount_rate,
               null charge_amount_rate_unit,
               null fx_rate,
               null charges_quantity,
               null charges_qty_unit,
               null charges_amount,
               null charge_amount_unit,
               null charges_invoice_amount,
               null charges_invoice_cur_name,
               null tax_code,
               null tax_rate,
               null tax_currency,
               null taxes_fx_rate,
               null Applicable_on,
               null taxes_amount,
               null taxes_amount_unit,
               null taxes_invoice_amount,
               null taxes_invoice_amount_cur,
               isd.is_free_metal,
               isd.is_pledge,
               isd.internal_comments,
               (case when  isd.sales_purchase='P' then
                        isp_c1.remarks
                        when isd.sales_purchase='S' then
                        isp_c2.remarks end) remarks,
                null yield,
                null gmr_product,
                null child_qty_unit,
                isd.iban,
                null api_internal_doc_ref_no,
                null api_invoice_ref_no,
                null api_amount_adjusted,
                null api_invoice_currency
  from is_d isd,
       is_bdp_child_d isp_c1,
       is_bds_child_d isp_c2,
       ds_document_summary ds,
       v_ak_corporate akc,
       (select istc.internal_doc_ref_no,
               istc.element_id tc_element_id,
               istc.element_name,
               istc.sub_lot_no ||(case when istc.assay_detail is null then ''
                                      else ' : '|| istc.assay_detail end) sub_lot_no,
              istc.tc_amount,
               istc.amount_unit tc_amount_unit
          from is_conc_tc_child istc) istc,
        (select vat.internal_invoice_ref_no,
                       vat.our_vat_no vat_no,
                       vat.cp_vat_no,
                       vat.vat_code_name vat_code,
                       vat.vat_rate,
                       vat.vat_rate_unit,
                       vat.vat_amount_in_inv_cur vat_amount
                  from ivd_invoice_vat_details vat
                 where vat.is_separate_invoice = 'N')vat
         where isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
           and ds.corporate_id = akc.corporate_id(+)
           and isd.internal_doc_ref_no = isp_c1.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = isp_c2.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = istc.internal_doc_ref_no(+)
           and isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
Union all
select        'Invoice' section_name,
              'Refining Charge' sub_section,
               rownum record_no,
               akc.corporate_id,
               akc.corporate_name,
               akc.address1,
               akc.address2,
               akc.city,
               akc.state,
               akc.country,
               akc.logo_path,
               akc.phone_no,
               akc.fax_no,
               isd.internal_doc_ref_no,
               isd.due_date,
               isd.sales_purchase,
               isd.cp_name,
               isd.supplire_invoice_no cp_item_stock_ref_no,
               '' business_unit,
               isd.self_item_stock_ref_no,
               isd.inco_term_location,
               isd.contract_ref_no self_contract_item_no,
               isd.contract_date,
               isd.notify_party,
               isd.org_name,
               isd.cp_contract_ref_no,
               isd.productandquality_name,
               isd.contract_tolerance,
               isd.contract_quantity,
               isd.contract_qty_unit,
               isd.invoice_ref_no provisional_invoice_no,
               isd.internal_invoice_ref_no,
               isd.product,
               isd.quality,
               isd.invoice_amount amount,
               isd.invoice_amount_unit,
               isd.payment_term,
               isd.invoice_creation_date,
               null invoice_issue_date,
               isd.invoice_quantity,
               isd.invoice_dry_quantity,
               isd.invoice_wet_quantity,
               isd.invoiced_qty_unit,
               isd.moisture,
               isd.invoice_type_name invoice_type,
               isd.stock_size,
               isd.packing,
               isd.provisional_price,
               isd.origin,
               isd.tarriff,
               '' final_qty,
               isd.material_cost final_amount,
               '' pi_number,
               '' provisional_amount,
               '' amount_due,
               isd.addditional_charges,
               isd.taxes,
               isd.contract_type product_type,
               isd.Invoice_Status,
               isd.gmr_ref_no pledge_gmr_ref_no,
               isd.gmr_quality pledge_gmr_qty,
               isd.stock_ref_no pledge_stock_ref_no,
               isd.stock_quantity pledge_stock_qty,
               null internal_doc_ref_no0,
               null stock_ref_no,
               null stock_qty,
               null gmr_ref_no,
               null gmr_quality,
               null gmr_quantity,
               null price_as_per_defind_uom,
               null item_amount_in_inv_cur,
               null invoiced_price_unit,
               null element_price_unit,
               null total_quantity,
               null gmr_qty_unit,
               isp_c1.internal_doc_ref_no internal_doc_ref_no1,
               isp_c1.beneficiary_name benificiary_name_c1,
               isp_c1.bank_name bank_name_c1,
               isp_c1.account_no account_no_c1,
               isp_c1.iban iban_c1,
               isp_c1.aba_rtn aba_rtn_c1,
               isp_c1.instruction instruction_c1,
               isp_c2.internal_doc_ref_no internal_doc_ref_no2,
               isp_c2.beneficiary_name benificiary_name_c2,
               isp_c2.bank_name bank_name_c2,
               isp_c2.account_no account_no_c2,
               isp_c2.iban iban_c2,
               isp_c2.aba_rtn aba_rtn_c2,
               isp_c2.instruction instruction_c2,
               null internal_doc_ref_no3,
               null stock_ref_no1,
               null stock_gmr_ref_no,
               null cp_gmr_quantity,
               null stock_qty1,
               null gmr_qty_unit1,
               null payable_element_id,
               null payable_element,
               null analysis,
               null analysis_unit,
               null element_price,
               null invoiced_price_unit1,
               null element_price_unit1,
               null sub_lot_no,
               null element_inv_amount,
               null element_invoiced_qty,
               null element_invoiced_qty_unit,
               null internal_doc_ref_no4,
               null tc_element_id,
               null element_name,
               isrc.sub_lot_no tc_rc_sub_lot_no,
               null tc_amount,
               null tc_amount_unit,
               isrc.internal_doc_ref_no internal_doc_ref_no5,
               isrc.rc_element_id,
               isrc.element_name element_name1,
               isrc.rc_amount,
               isrc.rc_amount_unit,
               null internal_doc_ref_no6,
               null pen_element_id,
               null element_name2,
               null pen_amount,
               null pen_amount_unit,
               vat.vat_no,
               vat.cp_vat_no,
               vat.vat_code,
               vat.vat_rate,
               vat.vat_rate_unit,
               vat.vat_amount,
               isd.invoice_amount_unit vat_amount_cur,
               isd.is_inv_draft,
               null cost_name,
               null charge_type,
               null charge_amount_rate,
               null charge_amount_rate_unit,
               null fx_rate,
               null charges_quantity,
               null charges_qty_unit,
               null charges_amount,
               null charge_amount_unit,
               null charges_invoice_amount,
               null charges_invoice_cur_name,
               null tax_code,
               null tax_rate,
               null tax_currency,
               null taxes_fx_rate,
               null Applicable_on,
               null taxes_amount,
               null taxes_amount_unit,
               null taxes_invoice_amount,
               null taxes_invoice_amount_cur,
               isd.is_free_metal,
               isd.is_pledge,
               isd.internal_comments,
               (case when  isd.sales_purchase='P' then
                        isp_c1.remarks
                        when isd.sales_purchase='S' then
                        isp_c2.remarks end) remarks,
                null yield,
                null  gmr_product,
                null child_qty_unit,
                isd.iban,
                null api_internal_doc_ref_no,
                null api_invoice_ref_no,
                null api_amount_adjusted,
                null api_invoice_currency
  from is_d isd,
       is_bdp_child_d isp_c1,
       is_bds_child_d isp_c2,
       ds_document_summary ds,
       v_ak_corporate akc,
       (select isrc.internal_doc_ref_no,
               isrc.element_id rc_element_id,
               isrc.element_name,
               isrc.sub_lot_no ||(case when isrc.assay_content is null then ''
                                      else ' : '|| isrc.assay_content end) sub_lot_no,
               isrc.rc_amount,
               isrc.amount_unit rc_amount_unit
          from is_conc_rc_child isrc) isrc,
        (select vat.internal_invoice_ref_no,
                       vat.our_vat_no vat_no,
                       vat.cp_vat_no,
                       vat.vat_code_name vat_code,
                       vat.vat_rate,
                       vat.vat_rate_unit,
                       vat.vat_amount_in_inv_cur vat_amount
                  from ivd_invoice_vat_details vat
                 where vat.is_separate_invoice = 'N')vat
         where isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
           and ds.corporate_id = akc.corporate_id(+)
           and isd.internal_doc_ref_no = isp_c1.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = isp_c2.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = isrc.internal_doc_ref_no(+)
           and isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
union all
select 'Invoice' section_name,
       'Penality' sub_section,
       rownum record_no,
       akc.corporate_id,
       akc.corporate_name,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.logo_path,
       akc.phone_no,
       akc.fax_no,
       isd.internal_doc_ref_no,
       isd.due_date,
       isd.sales_purchase,
       isd.cp_name,
       isd.supplire_invoice_no cp_item_stock_ref_no,
       '' business_unit,
       isd.self_item_stock_ref_no,
       isd.inco_term_location,
       isd.contract_ref_no self_contract_item_no,
       isd.contract_date,
       isd.notify_party,
       isd.org_name,
       isd.cp_contract_ref_no,
       isd.productandquality_name,
       isd.contract_tolerance,
       isd.contract_quantity,
       isd.contract_qty_unit,
       isd.invoice_ref_no provisional_invoice_no,
       isd.internal_invoice_ref_no,
       isd.product,
       isd.quality,
       isd.invoice_amount amount,
       isd.invoice_amount_unit,
       isd.payment_term,
       isd.invoice_creation_date,
       null invoice_issue_date,
       isd.invoice_quantity,
       isd.invoice_dry_quantity,
       isd.invoice_wet_quantity,
       isd.invoiced_qty_unit,
       isd.moisture,
       isd.invoice_type_name invoice_type,
       isd.stock_size,
       isd.packing,
       isd.provisional_price,
       isd.origin,
       isd.tarriff,
       isd.material_cost final_qty,
       '' final_amount,
       '' pi_number,
       '' provisional_amount,
       null amount_due,
       isd.addditional_charges,
       isd.taxes,
       isd.contract_type product_type,
       isd.Invoice_Status,
       null pledge_gmr_ref_no,
       null  pledge_gmr_qty,
       null  pledge_stock_ref_no,
       null  pledge_stock_qty,
       null internal_doc_ref_no0,
       null stock_ref_no,
       null stock_qty,
       null gmr_ref_no,
       null gmr_quality,
       null gmr_quantity,
       null price_as_per_defind_uom,
       null item_amount_in_inv_cur,
       null invoiced_price_unit,
       null element_price_unit,
       null total_quantity,
       null gmr_qty_unit,
       isp_c1.internal_doc_ref_no internal_doc_ref_no1,
       isp_c1.beneficiary_name benificiary_name_c1,
       isp_c1.bank_name bank_name_c1,
       isp_c1.account_no account_no_c1,
       isp_c1.iban iban_c1,
       isp_c1.aba_rtn aba_rtn_c1,
       isp_c1.instruction instruction_c1,
       isp_c2.internal_doc_ref_no internal_doc_ref_no2,
       isp_c2.beneficiary_name benificiary_name_c2,
       isp_c2.bank_name bank_name_c2,
       isp_c2.account_no account_no_c2,
       isp_c2.iban iban_c2,
       isp_c2.aba_rtn aba_rtn_c2,
       isp_c2.instruction instruction_c2,
       null internal_doc_ref_no3,
       null stock_ref_no1,
       null stock_gmr_ref_no,
       null cp_gmr_quantity,
       null stock_qty1,
       null gmr_qty_unit1,
       null payable_element_id,
       null payable_element,
       null analysis,
       null analysis_unit,
       null element_price,
       null invoiced_price_unit1,
       null element_price_unit1,
       null sub_lot_no,
       null element_inv_amount,
       null element_invoiced_qty,
       null element_invoiced_qty_unit,
       null internal_doc_ref_no4,
       null tc_element_id,
       null element_name,
       null tc_rc_sub_lot_no,
       null tc_amount,
       null tc_amount_unit,
       null internal_doc_ref_no5,
       null rc_element_id,
       null element_name1,
       null rc_amount,
       null rc_amount_unit,
       isp.internal_doc_ref_no internal_doc_ref_no6,
       isp.pen_element_id,
       isp.element_name element_name2,
       isp.pen_amount,
       isp.pen_amount_unit,
       vat.vat_no,
       vat.cp_vat_no,
       vat.vat_code,
       vat.vat_rate,
       vat.vat_rate_unit,
       vat.vat_amount,
       isd.invoice_amount_unit vat_amount_cur,
       isd.is_inv_draft,
       null cost_name,
       null charge_type,
       null charge_amount_rate,
       null charge_amount_rate_unit,
       null fx_rate,
       null charges_quantity,
       null charges_qty_unit,
       null charges_amount,
       null charge_amount_unit,
       null charges_invoice_amount,
       null charges_invoice_cur_name,
       null tax_code,
       null tax_rate,
       null tax_currency,
       null taxes_fx_rate,
       null Applicable_on,
       null taxes_amount,
       null taxes_amount_unit,
       null taxes_invoice_amount,
       null taxes_invoice_amount_cur,
       isd. is_free_metal,
       isd. is_pledge,
       isd. internal_comments,
       null remarks,
       null yield,
       null gmr_product,
       null child_qty_unit,
       null iban,
       null api_internal_doc_ref_no,
       null api_invoice_ref_no,
       null api_amount_adjusted,
       null api_invoice_currency
  from is_d isd,
       ds_document_summary ds,
       v_ak_corporate akc,
       is_bdp_child_d isp_c1,
       is_bds_child_d isp_c2,
       (select isp.internal_doc_ref_no,
               isp.element_id pen_element_id,
               isp.element_name,
               sum(isp.penalty_amount) pen_amount,
               isp.amount_unit pen_amount_unit
          from is_conc_penalty_child isp
         group by isp.internal_doc_ref_no,
                  isp.element_id,
                  isp.element_name,
                  isp.amount_unit) isp,
        (select vat.internal_invoice_ref_no,
                       vat.our_vat_no vat_no,
                       vat.cp_vat_no,
                       vat.vat_code_name vat_code,
                       vat.vat_rate,
                       vat.vat_rate_unit,
                       vat.vat_amount_in_inv_cur vat_amount
                  from ivd_invoice_vat_details vat
                 where vat.is_separate_invoice = 'N')vat
 where isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
   and isd.internal_doc_ref_no = isp_c1.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = isp_c2.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = isp.internal_doc_ref_no(+)
   and isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
union all
select         'Other Charges' section_name,
               'Other Charges' sub_section,
               rownum record_no,
               akc.corporate_id,
               akc.corporate_name,
               akc.address1,
               akc.address2,
               akc.city,
               akc.state,
               akc.country,
               akc.logo_path,
               akc.phone_no,
               akc.fax_no,
               isd.internal_doc_ref_no,
               isd.due_date,
               isd.sales_purchase,
               isd.cp_name,
               isd.supplire_invoice_no cp_item_stock_ref_no,
               '' business_unit,
               isd.self_item_stock_ref_no,
               isd.inco_term_location,
               isd.contract_ref_no self_contract_item_no,
               isd.contract_date,
               isd.notify_party,
               isd.org_name,
               isd.cp_contract_ref_no,
               isd.productandquality_name,
               isd.contract_tolerance,
               isd.contract_quantity,
               isd.contract_qty_unit,
               isd.invoice_ref_no provisional_invoice_no,
               isd.internal_invoice_ref_no,
               isd.product,
               isd.quality,
               isd.invoice_amount amount,
               isd.invoice_amount_unit,
               isd.payment_term,
               isd.invoice_creation_date,
               null invoice_issue_date,
               isd.invoice_quantity,
               isd.invoice_dry_quantity,
               isd.invoice_wet_quantity,
               isd.invoiced_qty_unit,
               isd.moisture,
               isd.invoice_type_name invoice_type,
               isd.stock_size,
               isd.packing,
               isd.provisional_price,
               isd.origin,
               isd.tarriff,
               '' final_qty,
               isd.material_cost final_amount,
               '' pi_number,
               '' provisional_amount,
               '' amount_due,
               isd.addditional_charges,
               isd.taxes,
               isd.contract_type product_type,
               isd.Invoice_Status,
               null pledge_gmr_ref_no,
               null  pledge_gmr_qty,
               null  pledge_stock_ref_no,
               null  pledge_stock_qty,
               null internal_doc_ref_no0,
               null stock_ref_no,
               null stock_qty,
               null gmr_ref_no,
               null gmr_quality,
               null gmr_quantity,
               null price_as_per_defind_uom,
               null item_amount_in_inv_cur,
               null invoiced_price_unit,
               null element_price_unit,
               null total_quantity,
               null gmr_qty_unit,
               null internal_doc_ref_no1,
               null benificiary_name_c1,
               null bank_name_c1,
               null account_no_c1,
               null iban_c1,
               null aba_rtn_c1,
               null instruction_c1,
               null internal_doc_ref_no2,
               null benificiary_name_c2,
               null bank_name_c2,
               null account_no_c2,
               null iban_c2,
               null aba_rtn_c2,
               null instruction_c2,
               null internal_doc_ref_no3,
               null stock_ref_no1,
               null stock_gmr_ref_no,
               null cp_gmr_quantity,
               null stock_qty1,
               null gmr_qty_unit1,
               null payable_element_id,
               null payable_element,
               null analysis,
               null analysis_unit,
               null element_price,
               null invoiced_price_unit1,
               null element_price_unit1,
               null sub_lot_no,
               null element_inv_amount,
               null element_invoiced_qty,
               null element_invoiced_qty_unit,
               null internal_doc_ref_no4,
               null tc_element_id,
               null element_name,
               null tc_rc_sub_lot_no,
               null tc_amount,
               null tc_amount_unit,
               null internal_doc_ref_no5,
               null rc_element_id,
               null element_name1,
               null rc_amount,
               null rc_amount_unit,
               null internal_doc_ref_no6,
               null pen_element_id,
               null element_name2,
               null pen_amount,
               null pen_amount_unit,
               null vat_no,
               null cp_vat_no,
               null vat_code,
               null vat_rate,
               null vat_rate_unit,
               null vat_amount,
               null vat_amount_cur,
               isd.is_inv_draft,
               ioc.other_charge_cost_name cost_name,
               ioc.charge_type,
               ioc.charge_amount_rate,
               ioc.rate_price_unit_name charge_amount_rate_unit,
               ioc.fx_rate,
               ioc.quantity charges_quantity,
               ioc.quantity_unit charges_qty_unit,
               ioc.amount charges_amount,
               ioc.amount_unit charge_amount_unit,
               ioc.invoice_amount charges_invoice_amount,
               ioc.invoice_cur_name charges_invoice_cur_name,
               null tax_code,
               null tax_rate,
               null tax_currency,
               null taxes_fx_rate,
               null Applicable_on,
               null taxes_amount,
               null taxes_amount_unit,
               null taxes_invoice_amount,
               null taxes_invoice_amount_cur,
               isd. is_free_metal,
               isd. is_pledge,
               isd. internal_comments,
               null remarks,
               null yield,
               null gmr_product,
               null child_qty_unit,
               null iban,
               null api_internal_doc_ref_no,
               null api_invoice_ref_no,
               null api_amount_adjusted,
               null api_invoice_currency
       from ioc_d ioc,
            is_d isd,
            ds_document_summary ds,
            v_ak_corporate akc
     where ioc.internal_doc_ref_no = ds.internal_doc_ref_no
              and isd.internal_doc_ref_no = ioc.internal_doc_ref_no
              and ds.corporate_id = akc.corporate_id(+)
union all
select 'Other Taxes' section_name,
       'Other Taxes' sub_section,
       rownum record_no,
       akc.corporate_id,
       akc.corporate_name,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.logo_path,
       akc.phone_no,
       akc.fax_no,
       isd.internal_doc_ref_no,
       isd.due_date,
       isd.sales_purchase,
       isd.cp_name,
       isd.supplire_invoice_no cp_item_stock_ref_no,
       '' business_unit,
       isd.self_item_stock_ref_no,
       isd.inco_term_location,
       isd.contract_ref_no self_contract_item_no,
       isd.contract_date,
       isd.notify_party,
       isd.org_name,
       isd.cp_contract_ref_no,
       isd.productandquality_name,
       isd.contract_tolerance,
       isd.contract_quantity,
       isd.contract_qty_unit,
       isd.invoice_ref_no provisional_invoice_no,
       isd.internal_invoice_ref_no,
       isd.product,
       isd.quality,
       isd.invoice_amount amount,
       isd.invoice_amount_unit,
       isd.payment_term,
       isd.invoice_creation_date,
       null invoice_issue_date,
       isd.invoice_quantity,
       isd.invoice_dry_quantity,
       isd.invoice_wet_quantity,
       isd.invoiced_qty_unit,
       isd.moisture,
       isd.invoice_type_name invoice_type,
       isd.stock_size,
       isd.packing,
       isd.provisional_price,
       isd.origin,
       isd.tarriff,
       '' final_qty,
       isd.material_cost final_amount,
       '' pi_number,
       '' provisional_amount,
       '' amount_due,
       isd.addditional_charges,
       isd.taxes,
       isd.contract_type product_type,
       isd.Invoice_Status,
       null pledge_gmr_ref_no,
       null  pledge_gmr_qty,
       null  pledge_stock_ref_no,
       null  pledge_stock_qty,
       null internal_doc_ref_no0,
       null stock_ref_no,
       null stock_qty,
       null gmr_ref_no,
       null gmr_quality,
       null gmr_quantity,
       null price_as_per_defind_uom,
       null item_amount_in_inv_cur,
       null invoiced_price_unit,
       null element_price_unit,
       null total_quantity,
       null gmr_qty_unit,
       null internal_doc_ref_no1,
       null benificiary_name_c1,
       null bank_name_c1,
       null account_no_c1,
       null iban_c1,
       null aba_rtn_c1,
       null instruction_c1,
       null internal_doc_ref_no2,
       null benificiary_name_c2,
       null bank_name_c2,
       null account_no_c2,
       null iban_c2,
       null aba_rtn_c2,
       null instruction_c2,
       null internal_doc_ref_no3,
       null stock_ref_no1,
       null stock_gmr_ref_no,
       null cp_gmr_quantity,
       null stock_qty1,
       null gmr_qty_unit1,
       null payable_element_id,
       null payable_element,
       null analysis,
       null analysis_unit,
       null element_price,
       null invoiced_price_unit1,
       null element_price_unit1,
       null sub_lot_no,
       null element_inv_amount,
       null element_invoiced_qty,
       null element_invoiced_qty_unit,
       null internal_doc_ref_no4,
       null tc_element_id,
       null element_name,
       null tc_rc_sub_lot_no,
       null tc_amount,
       null tc_amount_unit,
       null internal_doc_ref_no5,
       null rc_element_id,
       null element_name1,
       null rc_amount,
       null rc_amount_unit,
       null internal_doc_ref_no6,
       null pen_element_id,
       null element_name2,
       null pen_amount,
       null pen_amount_unit,
       null vat_no,
       null cp_vat_no,
       null vat_code,
       null vat_rate,
       null vat_rate_unit,
       null vat_amount,
       null vat_amount_cur,
       isd.is_inv_draft,
       null cost_name,
       null charge_type,
       null charge_amount_rate,
       null charge_amount_rate_unit,
       null fx_rate,
       null charges_quantity,
       null charges_qty_unit,
       null charges_amount,
       null charge_amount_unit,
       null charges_invoice_amount,
       null charges_invoice_cur_name,
       itd.tax_code,
       itd.tax_rate,
       itd.tax_currency,
       itd.fx_rate taxes_fx_rate,
       '' Applicable_on,
       itd.amount taxes_amount,
       itd.tax_currency taxes_amount_unit,
       itd.invoice_amount taxes_invoice_amount,
       itd.invoice_currency taxes_invoice_amount_cur,
       isd.is_free_metal,
       isd.is_pledge,
       isd.internal_comments,
       null remarks,
       null yield,
       null gmr_product,
       null child_qty_unit,
       null iban,
       null api_internal_doc_ref_no,
       null api_invoice_ref_no,
       null api_amount_adjusted,
       null api_invoice_currency
     from itd_d itd,
         is_d isd,
         ds_document_summary ds,
         v_ak_corporate akc
        where itd.internal_doc_ref_no = ds.internal_doc_ref_no
          and isd.internal_doc_ref_no = itd.internal_doc_ref_no
          and ds.corporate_id = akc.corporate_id(+) ;
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD 
(
CONSTRAINT FK_GMR_FIRST_ACTION_REF_NO FOREIGN KEY (GMR_FIRST_INT_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),
CONSTRAINT FK_GMR_LATEST_ACTION_ID FOREIGN KEY (GMR_LATEST_ACTION_ACTION_ID) REFERENCES AXM_ACTION_MASTER (ACTION_ID),

CONSTRAINT FK_GMR_CORPORATE_ID FOREIGN KEY (CORPORATE_ID) REFERENCES AK_CORPORATE (CORPORATE_ID),
CONSTRAINT FK_GMR_CREATED_BY FOREIGN KEY (CREATED_BY) REFERENCES AK_CORPORATE_USER (USER_ID),
CONSTRAINT FK_GMR_QTY_UNIT_ID FOREIGN KEY (QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),

CONSTRAINT FK_GMR_ORIGIN_COUNTRY_ID FOREIGN KEY (ORIGIN_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_GMR_ORIGIN_CITY_ID FOREIGN KEY (ORIGIN_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_GMR_DESTINATION_COUNTRY_ID FOREIGN KEY (DESTINATION_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_GMR_DESTINATION_CITY_ID FOREIGN KEY (DESTINATION_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_GMR_LOADING_COUNTRY_ID FOREIGN KEY (LOADING_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_GMR_LOADING_PORT_ID FOREIGN KEY (LOADING_PORT_ID) REFERENCES PMT_PORTMASTER (PORT_ID),

CONSTRAINT FK_GMR_DISCHARGE_COUNTRY_ID FOREIGN KEY (DISCHARGE_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_GMR_DISCHARGE_PORT_ID FOREIGN KEY (DISCHARGE_PORT_ID) REFERENCES PMT_PORTMASTER (PORT_ID),

CONSTRAINT FK_GMR_TRANS_COUNTRY_ID FOREIGN KEY (TRANS_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_GMR_TRANS_PORT_ID FOREIGN KEY (TRANS_PORT_ID) REFERENCES PMT_PORTMASTER (PORT_ID),

CONSTRAINT FK_GMR_WAREHOUSE_PROFILE_ID FOREIGN KEY (WAREHOUSE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_GMR_SHIP_LINE_PROFILE_ID FOREIGN KEY (SHIPPING_LINE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_GMR_CONTROLLER_PROFILE_ID FOREIGN KEY (CONTROLLER_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),

CONSTRAINT FK_GMR_INTERNAL_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),

CONSTRAINT FK_GMR_LOADING_STATE_ID FOREIGN KEY (LOADING_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_GMR_LOADING_CITY_ID FOREIGN KEY (LOADING_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_GMR_TRANS_STATE_ID FOREIGN KEY (TRANS_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_GMR_TRANS_CITY_ID FOREIGN KEY (TRANS_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_GMR_DISCHARGE_STATE_ID FOREIGN KEY (DISCHARGE_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_GMR_DISCHARGE_CITY_ID FOREIGN KEY (DISCHARGE_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_GMR_POR_COUNTRY_ID FOREIGN KEY (PLACE_OF_RECEIPT_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_GMR_POR_STATE_ID FOREIGN KEY (PLACE_OF_RECEIPT_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_GMR_POR_CITY_ID FOREIGN KEY (PLACE_OF_RECEIPT_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_GMR_POD_COUNTRY_ID FOREIGN KEY (PLACE_OF_DELIVERY_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_GMR_POD_STATE_ID FOREIGN KEY (PLACE_OF_DELIVERY_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_GMR_POD_CITY_ID FOREIGN KEY (PLACE_OF_DELIVERY_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_GMR_POOL_ID FOREIGN KEY (POOL_ID) REFERENCES PM_POOL_MASTER (POOL_ID)
);

ALTER TABLE GMRUL_GMR_UL ADD 
(
CONSTRAINT FK_GMRUL_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE AGMR_ACTION_GMR ADD 
(
CONSTRAINT FK_AGMR_FIRST_ACTION_REF_NO FOREIGN KEY (GMR_FIRST_INT_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),
CONSTRAINT FK_AGMR_LATEST_ACTION_ID FOREIGN KEY (GMR_LATEST_ACTION_ACTION_ID) REFERENCES AXM_ACTION_MASTER (ACTION_ID),

CONSTRAINT FK_AGMR_CORPORATE_ID FOREIGN KEY (CORPORATE_ID) REFERENCES AK_CORPORATE (CORPORATE_ID),
CONSTRAINT FK_AGMR_CREATED_BY FOREIGN KEY (CREATED_BY) REFERENCES AK_CORPORATE_USER (USER_ID),
CONSTRAINT FK_AGMR_QTY_UNIT_ID FOREIGN KEY (QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),

CONSTRAINT FK_AGMR_ORIGIN_COUNTRY_ID FOREIGN KEY (ORIGIN_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_AGMR_ORIGIN_CITY_ID FOREIGN KEY (ORIGIN_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_AGMR_DEST_COUNTRY_ID FOREIGN KEY (DESTINATION_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_AGMR_DESTINATION_CITY_ID FOREIGN KEY (DESTINATION_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_AGMR_LOADING_COUNTRY_ID FOREIGN KEY (LOADING_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_AGMR_LOADING_PORT_ID FOREIGN KEY (LOADING_PORT_ID) REFERENCES PMT_PORTMASTER (PORT_ID),

CONSTRAINT FK_AGMR_DISCHARGE_COUNTRY_ID FOREIGN KEY (DISCHARGE_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_AGMR_DISCHARGE_PORT_ID FOREIGN KEY (DISCHARGE_PORT_ID) REFERENCES PMT_PORTMASTER (PORT_ID),

CONSTRAINT FK_AGMR_TRANS_COUNTRY_ID FOREIGN KEY (TRANS_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_AGMR_TRANS_PORT_ID FOREIGN KEY (TRANS_PORT_ID) REFERENCES PMT_PORTMASTER (PORT_ID),

CONSTRAINT FK_AGMR_WAREHOUSE_PROFILE_ID FOREIGN KEY (WAREHOUSE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_AGMR_SHIP_LINE_PROFILE_ID FOREIGN KEY (SHIPPING_LINE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_AGMR_CONTROLLER_PROFILE_ID FOREIGN KEY (CONTROLLER_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID)
);

ALTER TABLE SD_SHIPMENT_DETAIL ADD 
(
CONSTRAINT FK_SD_GMR_REF_NO_ACTION_NO FOREIGN KEY(INTERNAL_GMR_REF_NO,ACTION_NO) REFERENCES AGMR_ACTION_GMR(INTERNAL_GMR_REF_NO, ACTION_NO),
CONSTRAINT FK_SD_CONTROLLER_PROFILE_ID FOREIGN KEY (CONTROLLER_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_SD_SENDER_ID FOREIGN KEY (SENDER_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID), 
CONSTRAINT FK_SD_CONSIGNEE_ID FOREIGN KEY (CONSIGNEE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID), 
CONSTRAINT FK_SD_NOTIFY_PARTY_ID FOREIGN KEY (NOTIFY_PARTY_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID), 
CONSTRAINT FK_SD_FORWARDING_AGENT_ID FOREIGN KEY (FORWARDING_AGENT_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),

CONSTRAINT FK_SD_POA_COUNTRY_ID FOREIGN KEY (PORT_OF_ARRIVAL_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_SD_POA_STATE_ID FOREIGN KEY (PORT_OF_ARRIVAL_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_SD_POA_CITY_ID FOREIGN KEY (PORT_OF_ARRIVAL_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID)
);

ALTER TABLE SDUL_SHIPMENT_DETAIL_UL ADD 
(
CONSTRAINT FK_SDUL_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_SDUL_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE VD_VOYAGE_DETAIL ADD 
(
CONSTRAINT FK_VD_GMR_REF_NO_ACTION_NO FOREIGN KEY(INTERNAL_GMR_REF_NO,ACTION_NO) REFERENCES AGMR_ACTION_GMR(INTERNAL_GMR_REF_NO, ACTION_NO),
CONSTRAINT FK_VD_SHIP_LINE_PROFILE_ID FOREIGN KEY (SHIPPING_LINE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_VD_LOADING_PORT_ID FOREIGN KEY (LOADING_PORT_ID) REFERENCES PMT_PORTMASTER (PORT_ID), 
CONSTRAINT FK_VD_DISCHARGE_PORT_ID FOREIGN KEY (DISCHARGE_PORT_ID) REFERENCES PMT_PORTMASTER (PORT_ID), 
CONSTRAINT FK_VD_TRANS_SHIPMENT_PORT_ID FOREIGN KEY (TRANS_SHIPMENT_PORT_ID) REFERENCES PMT_PORTMASTER (PORT_ID), 

CONSTRAINT FK_VD_TRANS_SHIP_COUNTRY_ID FOREIGN KEY (TRANS_SHIPMENT_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_VD_TRANS_SHIPMENT_STATE_ID FOREIGN KEY (TRANS_SHIPMENT_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_VD_TRANS_SHIPMENT_CITY_ID FOREIGN KEY (TRANS_SHIPMENT_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_VD_DESTINATION_COUNTRY_ID FOREIGN KEY (DESTINATION_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_VD_DESTINATION_CITY_ID FOREIGN KEY (DESTINATION_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_VD_ORIGINATION_COUNTRY_ID FOREIGN KEY (ORIGINATION_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_VD_ORIGINATION_CITY_ID FOREIGN KEY (ORIGINATION_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_VD_SHIP_AGENT_PROFILE_ID FOREIGN KEY (SHIPPING_AGENT_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_VD_VOYAGE_QTY_UNIT_ID FOREIGN KEY (VOYAGE_QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),

CONSTRAINT FK_VD_LOADING_COUNTRY_ID FOREIGN KEY (LOADING_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_VD_LOADING_STATE_ID FOREIGN KEY (LOADING_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_VD_LOADING_CITY_ID FOREIGN KEY (LOADING_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_VD_DISCHARGE_COUNTRY_ID FOREIGN KEY (DISCHARGE_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_VD_DISCHARGE_STATE_ID FOREIGN KEY (DISCHARGE_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_VD_DISCHARGE_CITY_ID FOREIGN KEY (DISCHARGE_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_VD_POR_COUNTRY_ID FOREIGN KEY (PLACE_OF_RECEIPT_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_VD_POR_STATE_ID FOREIGN KEY (PLACE_OF_RECEIPT_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_VD_POR_CITY_ID FOREIGN KEY (PLACE_OF_RECEIPT_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_VD_POD_COUNTRY_ID FOREIGN KEY (PLACE_OF_DELIVERY_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_VD_POD_STATE_ID FOREIGN KEY (PLACE_OF_DELIVERY_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_VD_POD_CITY_ID FOREIGN KEY (PLACE_OF_DELIVERY_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_VD_CUSTOMS_CUR_ID FOREIGN KEY (DECLARED_VALUE_CUSTOMS_CUR_ID) REFERENCES CM_CURRENCY_MASTER (CUR_ID)
);

ALTER TABLE VDUL_VOYAGE_DETAIL_UL ADD 
(
CONSTRAINT FK_VDUL_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_VDUL_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);


ALTER TABLE VAD_VOYAGE_ALLOCATION_DETAIL ADD 
(
CONSTRAINT FK_VAD_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO)
);

ALTER TABLE WRD_WAREHOUSE_RECEIPT_DETAIL ADD 
(
CONSTRAINT FK_WRD_GMR_REF_NO_ACTION_NO FOREIGN KEY(INTERNAL_GMR_REF_NO,ACTION_NO) REFERENCES AGMR_ACTION_GMR(INTERNAL_GMR_REF_NO, ACTION_NO),
CONSTRAINT FK_WRD_WAREHOUSE_PROFILE_ID FOREIGN KEY (WAREHOUSE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),

CONSTRAINT FK_WRD_SENDER_ID FOREIGN KEY (SENDER_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID), 

CONSTRAINT FK_WRD_CONSIGNEE_ID FOREIGN KEY (CONSIGNEE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID), 

CONSTRAINT FK_WRD_TO_WAREHOUSE_ID FOREIGN KEY (TO_WAREHOUSE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_WRD_TO_SHED_ID FOREIGN KEY (TO_SHED_ID) REFERENCES SLD_STORAGE_LOCATION_DETAIL (STORAGE_LOC_ID)
);

ALTER TABLE WRDUL_WAREHOUSE_RECEIPT_UL ADD 
(
CONSTRAINT FK_WRDUL_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_WRDUL_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE SAD_SHIPMENT_ADVICE ADD 
(
CONSTRAINT FK_SAD_GMR_REF_NO_ACTION_NO FOREIGN KEY(INTERNAL_GMR_REF_NO,ACTION_NO) REFERENCES AGMR_ACTION_GMR(INTERNAL_GMR_REF_NO, ACTION_NO),
CONSTRAINT FK_SAD_CONTROLLER_PROFILE_ID FOREIGN KEY (CONTROLLER_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_SAD_SENDER_ID FOREIGN KEY (SENDER_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID), 
CONSTRAINT FK_SAD_CONSIGNEE_ID FOREIGN KEY (CONSIGNEE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID), 
CONSTRAINT FK_SAD_NOTIFY_PARTY_ID FOREIGN KEY (NOTIFY_PARTY_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID), 
CONSTRAINT FK_SAD_FORWARDING_AGENT_ID FOREIGN KEY (FORWARDING_AGENT_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),

CONSTRAINT FK_SAD_POA_COUNTRY_ID FOREIGN KEY (PORT_OF_ARRIVAL_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_SAD_POA_STATE_ID FOREIGN KEY (PORT_OF_ARRIVAL_STATE_ID) REFERENCES SM_STATE_MASTER (STATE_ID),
CONSTRAINT FK_SAD_POA_CITY_ID FOREIGN KEY (PORT_OF_ARRIVAL_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID)
);

ALTER TABLE SADUL_SHIPMENT_ADVICE_UL ADD 
(
CONSTRAINT FK_SADUL_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_SADUL_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE ROD_RELEASE_ORDER_DETAIL ADD 
(
CONSTRAINT FK_ROD_GMR_REF_NO_ACTION_NO FOREIGN KEY(INTERNAL_GMR_REF_NO,ACTION_NO) REFERENCES AGMR_ACTION_GMR(INTERNAL_GMR_REF_NO, ACTION_NO),
CONSTRAINT FK_ROD_WAREHOUSE_PROFILE_ID FOREIGN KEY (WAREHOUSE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_ROD_WAREHOUSE_SHED_ID FOREIGN KEY (WAREHOUSE_SHED_ID) REFERENCES SLD_STORAGE_LOCATION_DETAIL (STORAGE_LOC_ID),

CONSTRAINT FK_ROD_FD_COUNTRY_ID FOREIGN KEY (FINAL_DESTINATION_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_ROD_FD_CITY_ID FOREIGN KEY (FINAL_DESTINATION_CITY_ID) REFERENCES CIM_CITYMASTER (CITY_ID),

CONSTRAINT FK_ROD_ISSUE_ID FOREIGN KEY (ISSUE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID), 

CONSTRAINT FK_ROD_CONSIGNEE_ID FOREIGN KEY (CONSIGNEE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_ROD_WAREHOUSE_RENT_CUR_ID FOREIGN KEY (WAREHOUSE_RENT_CUR_ID) REFERENCES CM_CURRENCY_MASTER (CUR_ID)
);

ALTER TABLE RODUL_RELEASE_ORDER_DETAIL_UL ADD 
(
CONSTRAINT FK_RODUL_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_RODUL_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);


ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD 
(
CONSTRAINT FK_GRD_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_GRD_PRODUCT_ID FOREIGN KEY (PRODUCT_ID) REFERENCES PDM_PRODUCTMASTER (PRODUCT_ID),
CONSTRAINT FK_GRD_QTY_UNIT_ID FOREIGN KEY (QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
CONSTRAINT FK_GRD_QUALITY_ID FOREIGN KEY (QUALITY_ID) REFERENCES QAT_QUALITY_ATTRIBUTES (QUALITY_ID),
CONSTRAINT FK_GRD_WAREHOUSE_PROFILE_ID FOREIGN KEY (WAREHOUSE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_GRD_PARENT_INT_GRD_REF_NO FOREIGN KEY (PARENT_INTERNAL_GRD_REF_NO) REFERENCES GRD_GOODS_RECORD_DETAIL (INTERNAL_GRD_REF_NO),
CONSTRAINT FK_GRD_INTERNAL_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),
CONSTRAINT FK_GRD_CUSTOMS_ID FOREIGN KEY (CUSTOMS_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),
CONSTRAINT FK_GRD_TAX_ID FOREIGN KEY (TAX_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),
CONSTRAINT FK_GRD_DUTY_ID FOREIGN KEY (DUTY_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),
CONSTRAINT FK_GRD_PARTNERSHIP_TYPE FOREIGN KEY (PARTNERSHIP_TYPE) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID)
);

ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD 
(
CONSTRAINT FK_GRDUL_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE AGRD_ACTION_GRD ADD 
(
CONSTRAINT FK_AGRD_INTERNAL_GRD_REF_NO FOREIGN KEY (INTERNAL_GRD_REF_NO) REFERENCES GRD_GOODS_RECORD_DETAIL (INTERNAL_GRD_REF_NO),
CONSTRAINT FK_AGRD_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_AGRD_PRODUCT_ID FOREIGN KEY (PRODUCT_ID) REFERENCES PDM_PRODUCTMASTER (PRODUCT_ID),
CONSTRAINT FK_AGRD_QTY_UNIT_ID FOREIGN KEY (QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
CONSTRAINT FK_AGRD_QUALITY_ID FOREIGN KEY (QUALITY_ID) REFERENCES QAT_QUALITY_ATTRIBUTES (QUALITY_ID),
CONSTRAINT FK_AGRD_WAREHOUSE_PROFILE_ID FOREIGN KEY (WAREHOUSE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_AGRD_PARENT_INT_GRD_REF_NO FOREIGN KEY (PARENT_INTERNAL_GRD_REF_NO) REFERENCES GRD_GOODS_RECORD_DETAIL (INTERNAL_GRD_REF_NO),
CONSTRAINT FK_AGRD_CUSTOMS_ID FOREIGN KEY (CUSTOMS_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),
CONSTRAINT FK_AGRD_TAX_ID FOREIGN KEY (TAX_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),
CONSTRAINT FK_AGRD_DUTY_ID FOREIGN KEY (DUTY_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),
CONSTRAINT FK_AGRD_PARTNERSHIP_TYPE FOREIGN KEY (PARTNERSHIP_TYPE) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID)
);

ALTER TABLE DGRD_DELIVERED_GRD ADD 
(
CONSTRAINT FK_DGRD_DISCHARGE_COUNTRY_ID FOREIGN KEY (DISCHARGE_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_DGRD_DISCHARGE_PORT_ID FOREIGN KEY (DISCHARGE_PORT_ID) REFERENCES PMT_PORTMASTER (PORT_ID),

CONSTRAINT FK_DGRD_PRODUCT_ID FOREIGN KEY (PRODUCT_ID) REFERENCES PDM_PRODUCTMASTER (PRODUCT_ID),
CONSTRAINT FK_DGRD_QUALITY_ID FOREIGN KEY (QUALITY_ID) REFERENCES QAT_QUALITY_ATTRIBUTES (QUALITY_ID),

CONSTRAINT FK_DGRD_NET_WEIGHT_UNIT_ID FOREIGN KEY (NET_WEIGHT_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
CONSTRAINT FK_DGRD_PARENT_DGRD_REF_NO FOREIGN KEY (PARENT_DGRD_REF_NO) REFERENCES DGRD_DELIVERED_GRD (INTERNAL_DGRD_REF_NO),

CONSTRAINT FK_DGRD_WAREHOUSE_PROFILE_ID FOREIGN KEY (WAREHOUSE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_DGRD_SHED_ID FOREIGN KEY (SHED_ID) REFERENCES SLD_STORAGE_LOCATION_DETAIL (STORAGE_LOC_ID),

CONSTRAINT FK_DGRD_CONTRACT_ITEM_REF_NO FOREIGN KEY (INTERNAL_CONTRACT_ITEM_REF_NO) REFERENCES PCI_PHYSICAL_CONTRACT_ITEM (INTERNAL_CONTRACT_ITEM_REF_NO),

CONSTRAINT FK_DGRD_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),

CONSTRAINT FK_DGRD_CUSTOMS_ID FOREIGN KEY (CUSTOMS_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),
CONSTRAINT FK_DGRD_TAX_ID FOREIGN KEY (TAX_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),
CONSTRAINT FK_DGRD_DUTY_ID FOREIGN KEY (DUTY_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),

CONSTRAINT FK_DGRD_PARTNERSHIP_TYPE FOREIGN KEY (PARTNERSHIP_TYPE) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),

CONSTRAINT FK_DGRD_ASSAY_HEADER_ID FOREIGN KEY (ASSAY_HEADER_ID) REFERENCES ASH_ASSAY_HEADER (ASH_ID)
);

ALTER TABLE DGRDUL_DELIVERED_GRD_UL ADD 
(
CONSTRAINT FK_DGRDUL_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);


ALTER TABLE ADGRD_ACTION_DGRD ADD 
(
CONSTRAINT FK_ADGRD_DISCHARGE_COUNTRY_ID FOREIGN KEY (DISCHARGE_COUNTRY_ID) REFERENCES CYM_COUNTRYMASTER (COUNTRY_ID),
CONSTRAINT FK_ADGRD_DISCHARGE_PORT_ID FOREIGN KEY (DISCHARGE_PORT_ID) REFERENCES PMT_PORTMASTER (PORT_ID),

CONSTRAINT FK_ADGRD_PRODUCT_ID FOREIGN KEY (PRODUCT_ID) REFERENCES PDM_PRODUCTMASTER (PRODUCT_ID),
CONSTRAINT FK_ADGRD_QUALITY_ID FOREIGN KEY (QUALITY_ID) REFERENCES QAT_QUALITY_ATTRIBUTES (QUALITY_ID),

CONSTRAINT FK_ADGRD_NET_WEIGHT_UNIT_ID FOREIGN KEY (NET_WEIGHT_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),

CONSTRAINT FK_ADGRD_WAREHOUSE_PROFILE_ID FOREIGN KEY (WAREHOUSE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),

CONSTRAINT FK_ADGRD_CONTRACT_ITEM_REF_NO FOREIGN KEY (INTERNAL_CONTRACT_ITEM_REF_NO) REFERENCES PCI_PHYSICAL_CONTRACT_ITEM (INTERNAL_CONTRACT_ITEM_REF_NO),

CONSTRAINT FK_ADGRD_CUSTOMS_ID FOREIGN KEY (CUSTOMS_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),
CONSTRAINT FK_ADGRD_TAX_ID FOREIGN KEY (TAX_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),
CONSTRAINT FK_ADGRD_DUTY_ID FOREIGN KEY (DUTY_ID) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),

CONSTRAINT FK_ADGRD_PARTNERSHIP_TYPE FOREIGN KEY (PARTNERSHIP_TYPE) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),

CONSTRAINT FK_ADGRD_ASSAY_HEADER_ID FOREIGN KEY (ASSAY_HEADER_ID) REFERENCES ASH_ASSAY_HEADER (ASH_ID)
);


ALTER TABLE GEPD_GMR_ELEMENT_PLEDGE_DETAIL ADD 
(
CONSTRAINT FK_GEPD_PRODUCT_ID FOREIGN KEY (PRODUCT_ID) REFERENCES PDM_PRODUCTMASTER (PRODUCT_ID)
);

ALTER TABLE SPQ_STOCK_PAYABLE_QTY ADD 
(
CONSTRAINT FK_SPQ_ELEMENT_ID FOREIGN KEY (ELEMENT_ID) REFERENCES AML_ATTRIBUTE_MASTER_LIST (ATTRIBUTE_ID),
CONSTRAINT FK_SPQ_QTY_UNIT_ID FOREIGN KEY (QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
CONSTRAINT FK_SPQ_INTERNAL_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE PM_POOL_MASTER ADD 
(
CONSTRAINT FK_PM_POOL_CORPORATE_ID FOREIGN KEY (CORPORATE_ID) REFERENCES AK_CORPORATE (CORPORATE_ID),
CONSTRAINT FK_PM_POOL_PRODUCT_ID FOREIGN KEY (PRODUCT_ID) REFERENCES PDM_PRODUCTMASTER (PRODUCT_ID),
CONSTRAINT FK_PM_POOL_QUALITY_ID FOREIGN KEY (QUALITY_ID) REFERENCES QAT_QUALITY_ATTRIBUTES (QUALITY_ID),
CONSTRAINT FK_PM_POOL_QTY_UNIT_ID FOREIGN KEY (POOL_QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
CONSTRAINT FK_PM_POOL_WAREHOUSE_ID FOREIGN KEY (WAREHOUSE_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_PM_POOL_VALUATION_METHOD FOREIGN KEY (VALUATION_METHOD) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID),
CONSTRAINT FK_PM_POOL_PROFIT_CENTER_ID FOREIGN KEY (PROFIT_CENTER_ID) REFERENCES CPC_CORPORATE_PROFIT_CENTER (PROFIT_CENTER_ID),
CONSTRAINT FK_PM_POOL_CP_PROFILE_ID FOREIGN KEY (CP_PROFILE_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID)
);

ALTER TABLE PAQ_POOL_ALLOCATED_QUALITY ADD 
(
CONSTRAINT FK_PAQ_POOL_ID FOREIGN KEY (POOL_ID) REFERENCES PM_POOL_MASTER (POOL_ID),
CONSTRAINT FK_PAQ_ALLOCATED_QUALITY_ID FOREIGN KEY (ALLOCATED_QUALITY_ID) REFERENCES QAT_QUALITY_ATTRIBUTES (QUALITY_ID)
);

ALTER TABLE PQS_POOL_QUANTITY_STATUS ADD 
(
CONSTRAINT FK_PQS_QTY_UNIT_ID FOREIGN KEY (QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID)
);

ALTER TABLE PQUH_POOL_QTY_UPDATE_HISTORY ADD 
(
CONSTRAINT FK_PQUH_POOL_ID FOREIGN KEY (POOL_ID) REFERENCES PM_POOL_MASTER (POOL_ID),
CONSTRAINT FK_PQUH_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),
CONSTRAINT FK_PQUH_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_PQUH_QTY_UNIT_ID FOREIGN KEY (QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID)
);

ALTER TABLE PSR_POOL_STOCK_REGISTER ADD 
(
CONSTRAINT FK_PSR_POOL_ID FOREIGN KEY (POOL_ID) REFERENCES PM_POOL_MASTER (POOL_ID),
CONSTRAINT FK_PSR_INTERNAL_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),
CONSTRAINT FK_PSR_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_PSR_INTERNAL_GRD_REF_NO FOREIGN KEY (INTERNAL_GRD_REF_NO) REFERENCES GRD_GOODS_RECORD_DETAIL (INTERNAL_GRD_REF_NO),
CONSTRAINT FK_PSR_QTY_UNIT_ID FOREIGN KEY (QTY_UNIT) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID)
);

ALTER TABLE SPSM_SALES_POOL_STOCK_MAPPING ADD 
(
CONSTRAINT FK_SPSM_INT_SALES_GMR_REF_NO FOREIGN KEY (INTERNAL_SALES_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_SPSM_INTERNAL_GRD_REF_NO FOREIGN KEY (INTERNAL_GRD_REF_NO) REFERENCES GRD_GOODS_RECORD_DETAIL (INTERNAL_GRD_REF_NO),
CONSTRAINT FK_SPSM_SALES_QTY_UNIT_ID FOREIGN KEY (SALES_QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID)
);

ALTER TABLE WOP_WRITE_OFF_POOL ADD 
(
CONSTRAINT FK_WOP_POOL_ID FOREIGN KEY (POOL_ID) REFERENCES PM_POOL_MASTER (POOL_ID),
CONSTRAINT FK_WOP_INTERNAL_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),
CONSTRAINT FK_WOP_WRITE_OFF_QTY_UNIT_ID FOREIGN KEY (WRITE_OFF_QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID)
);

ALTER TABLE AGH_ALLOC_GROUP_HEADER ADD 
(
CONSTRAINT FK_AGH_ALLOC_ITEM_QTY_UNIT_ID FOREIGN KEY (ALLOC_ITEM_QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
CONSTRAINT FK_AGH_CREATED_BY FOREIGN KEY (CREATED_BY) REFERENCES AK_CORPORATE_USER (USER_ID),
CONSTRAINT FK_AGH_UPDATED_BY FOREIGN KEY (UPDATED_BY) REFERENCES AK_CORPORATE_USER (USER_ID),
CONSTRAINT FK_AGH_CANCELLED_BY FOREIGN KEY (CANCELLED_BY) REFERENCES AK_CORPORATE_USER (USER_ID),
CONSTRAINT FK_AGH_INTERNAL_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),
CONSTRAINT FK_AGH_PARTNERSHIP_TYPE FOREIGN KEY (PARTNERSHIP_TYPE) REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID)
);

ALTER TABLE AGHUL_ALLOC_GROUP_HEADER_UL ADD 
(
CONSTRAINT FK_AGHUL_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE AAGD_ACTION_ALLOC_GROUP_DETAIL ADD 
(
CONSTRAINT FK_AAGD_INTERNAL_STOCK_REF_NO FOREIGN KEY (INTERNAL_STOCK_REF_NO) REFERENCES GRD_GOODS_RECORD_DETAIL (INTERNAL_GRD_REF_NO)
);

ALTER TABLE AGD_ALLOC_GROUP_DETAIL ADD 
(
CONSTRAINT FK_AGD_CONTRACT_ITEM_REF_NO FOREIGN KEY (INTERNAL_CONTRACT_ITEM_REF_NO) REFERENCES PCI_PHYSICAL_CONTRACT_ITEM (INTERNAL_CONTRACT_ITEM_REF_NO),
CONSTRAINT FK_AGD_QTY_UNIT_ID FOREIGN KEY (QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
CONSTRAINT FK_AGD_SALES_QTY_UNIT_ID FOREIGN KEY (SALES_QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
CONSTRAINT FK_AGD_CREATED_BY FOREIGN KEY (CREATED_BY) REFERENCES AK_CORPORATE_USER (USER_ID),
CONSTRAINT FK_AGD_UPDATED_BY FOREIGN KEY (UPDATED_BY) REFERENCES AK_CORPORATE_USER (USER_ID),
CONSTRAINT FK_AGD_CANCELLED_BY FOREIGN KEY (CANCELLED_BY) REFERENCES AK_CORPORATE_USER (USER_ID),
CONSTRAINT FK_AGD_INTERNAL_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE AGDUL_ALLOC_GROUP_DETAIL_UL ADD 
(
CONSTRAINT FK_AGDUL_INT_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE GAM_GMR_ACTION_MAPPING ADD 
(
CONSTRAINT FK_GAM_INTERNAL_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),
CONSTRAINT FK_GAM_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_GAM_ACTIVITY_QTY_UNIT_ID FOREIGN KEY (ACTIVITY_QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
CONSTRAINT FK_GAM_POOL_ID FOREIGN KEY (POOL_ID) REFERENCES PM_POOL_MASTER (POOL_ID)
);


ALTER TABLE GCIM_GMR_CONTRACT_ITEM_MAPPING ADD
(
CONSTRAINT FK_GCIM_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO)
);

ALTER TABLE MOGRD_MOVED_OUT_GRD ADD 
(
CONSTRAINT FK_MOGRD_INTERNAL_GRD_REF_NO FOREIGN KEY (INTERNAL_GRD_REF_NO) REFERENCES GRD_GOODS_RECORD_DETAIL (INTERNAL_GRD_REF_NO),
CONSTRAINT FK_MOGRD_QTY_UNIT_ID FOREIGN KEY (QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
CONSTRAINT FK_MOGRD_POOL_ID FOREIGN KEY (POOL_ID) REFERENCES PM_POOL_MASTER (POOL_ID)
);

DELETE  CGAR_CORPORATE_GMR_ACTION_RULE CGAR
WHERE CGAR.ACTION_ID IN ('undoWrtOffCMAStocks', 'writeOffCMAStocks')
OR CGAR.PARENT_ACTION_ID IN
					 ('undoWrtOffCMAStocks', 'writeOffCMAStocks');
					 
ALTER TABLE CGAR_CORPORATE_GMR_ACTION_RULE ADD 
(
CONSTRAINT FK_CGAR_CORPORATE_ID FOREIGN KEY (CORPORATE_ID) REFERENCES AK_CORPORATE (CORPORATE_ID),
CONSTRAINT FK_CGAR_PARENT_ACTION_ID FOREIGN KEY (PARENT_ACTION_ID) REFERENCES AXM_ACTION_MASTER (ACTION_ID),
CONSTRAINT FK_CGAR_ACTION_ID FOREIGN KEY (ACTION_ID) REFERENCES AXM_ACTION_MASTER (ACTION_ID)
);
alter table PFD_PRICE_FIXATION_DETAILS add HEDGE_CORRECTION_ID varchar2(30);
            
 alter table ASH_ASSAY_HEADER add(CONSTRAINT fk_ash_internal_gmr_ref_no FOREIGN KEY     
  (internal_gmr_ref_no) REFERENCES gmr_goods_movement_record (internal_gmr_ref_no),
      CONSTRAINT fk_internal_contract_ref_no FOREIGN KEY(internal_contract_ref_no) REFERENCES 
      PCM_PHYSICAL_CONTRACT_MAIN(internal_contract_ref_no));

CREATE OR REPLACE VIEW V_BI_PHYSICAL_CALL_OFF_DUE AS
select t.corporate_id,
       t.product_id,
       t.product_name,
       t.qty,
       t.qty_unit_id base_qty_unit_id,
       t.qty_unit base_qty_unit,
       t.contract_ref_no || '(' || delivery_item_no || ')' delivery_item_ref_no,
       t.pcdi_id,
       t.qty_declaration_date due_date
  from (select pcdi.pcdi_id,
               pcm.corporate_id,
               pcpd.product_id,
               pcm.contract_ref_no,
               pcdi.delivery_item_no,
               pdm.product_desc product_name,
               pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                    diqs.item_qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    nvl(diqs.total_qty, 0) -
                                                    nvl(diqs.called_off_qty,
                                                        0)) qty,
               pdm.base_quantity_unit qty_unit_id,
               qum.qty_unit,
               pcm.issue_date,
               pcdi.payment_due_date,
               pcdi.qp_declaration_date,
               --pcdi.qty_declaration_date,
               trunc(least(nvl(pcdi.qty_declaration_date,sysdate),nvl(pcdi.quality_declaration_date,sysdate),nvl(pcdi.inco_location_declaration_date,sysdate))) qty_declaration_date, --added for 65307
               pcdi.quality_declaration_date,
               pcdi.inco_location_declaration_date
          from pcdi_pc_delivery_item         pcdi,
               pcm_physical_contract_main    pcm,
               pcpd_pc_product_definition    pcpd,
               pdm_productmaster             pdm,
               qum_quantity_unit_master      qum,
               diqs_delivery_item_qty_status diqs
         where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.product_id = pdm.product_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           and pcpd.input_output = 'Input'
           and pcdi.pcdi_id = diqs.pcdi_id
           and pcdi.is_active = 'Y'
           and pcm.is_active = 'Y'
           and pcpd.is_active = 'Y'
           and diqs.is_active = 'Y'
           and qum.is_active = 'Y'
           --and pcdi.quality_declaration_date <= sysdate--added for 65307
           and pcdi.is_phy_optionality_present = 'Y'
           and nvl(diqs.total_qty, 0) - nvl(diqs.called_off_qty, 0) > 0
           and pcm.contract_status <> 'Cancelled') t
           where t.qty_declaration_date <=trunc(sysdate); --added for 65307
create or replace view v_projected_price_exposure as
with pfqpp_table as (select pci.pcdi_id,
       pcbph.internal_contract_ref_no,
       pfqpp.qp_pricing_period_type,
       pfqpp.qp_period_from_date,
       pfqpp.qp_period_to_date,
       pfqpp.qp_month,
       pfqpp.qp_year,
       pfqpp.qp_date,
       pfqpp.is_qp_any_day_basis,
       pfqpp.event_name,
       pfqpp.no_of_event_months,
       ppfh.ppfh_id,
       ppfh.formula_description,
       pfqpp.is_spot_pricing,
       pcbpd.pcbpd_id
  from pci_physical_contract_item    pci,
       pcipf_pci_pricing_formula     pcipf,
       pcbph_pc_base_price_header    pcbph,
       pcbpd_pc_base_price_detail    pcbpd,
       ppfh_phy_price_formula_header ppfh,
       pfqpp_phy_formula_qp_pricing  pfqpp
 where pci.internal_contract_item_ref_no =
       pcipf.internal_contract_item_ref_no
   and pcipf.pcbph_id = pcbph.pcbph_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.pcbpd_id = pcbpd.pcbpd_id
   and ppfh.is_active = 'Y'
   and pfqpp.is_active = 'Y'
   and pci.is_active = 'Y'
   and pcipf.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and pcbph.is_active = 'Y'
 group by pci.pcdi_id,
          pcbph.internal_contract_ref_no,
          pcbpd.price_basis,
          pcbpd.price_value,
          pcbpd.price_unit_id,
          pcbpd.tonnage_basis,
          pcbpd.fx_to_base,
          pcbpd.qty_to_be_priced,
          pcbph.price_description,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_date,
          pfqpp.event_name,
          pfqpp.no_of_event_months,
          is_qp_any_day_basis,
          ppfh.price_unit_id,
          ppfh.ppfh_id,
          ppfh.formula_description,
          pfqpp.is_spot_pricing,
       pcbpd.pcbpd_id),
pofh_header_data as
        (select *
           from pofh_price_opt_fixation_header pofh
          where pofh.internal_gmr_ref_no is null
            and pofh.qty_to_be_fixed is not null
            and pofh.is_active = 'Y'),
        pfd_fixation_data as
        (select   pfd.pofh_id,
                  round (sum (nvl (pfd.qty_fixed, 0)), 5) qty_fixed
             from pfd_price_fixation_details pfd
            where pfd.is_active = 'Y'
         group by pfd.pofh_id)          
--Any Day Pricing Base Metal +Contract + Not Called Off + Excluding Event Based          
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
         to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year)
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_from_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end)   qp_start_date,
       to_char((case
         when pfqpp.qp_pricing_period_type = 'Month' then
         last_day(to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year))
        when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_to_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end),'dd-Mon-yyyy')   qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null          quality,     
       pfqpp.formula_description formula,
       vp.premium,       
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (
        nvl(diqs.open_qty,0) *
        pkg_general.f_get_converted_quantity(pcpd.product_id,
                                             qum.qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1))
                                              qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp, 
       pfqpp_table pfqpp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no  
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pfqpp.pcdi_id=pcdi.pcdi_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and pfqpp.ppfh_id = ppfd.ppfh_id
   and pcpd.profit_center_id = cpc.profit_center_id
     and pdm.base_quantity_unit = qum.qty_unit_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
union all
--Any Day Pricing Base Metal +Contract + Not Called Off + Event Based
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,       
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       di.expected_qp_start_date  qp_start_date,
       to_char(di.expected_qp_end_date,'dd-Mon-yyyy')   qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null          quality,     
       pfqpp.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (
        nvl(diqs.open_qty,0) *
        pkg_general.f_get_converted_quantity(pcpd.product_id,
                                             qum.qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1))
                                              qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       di_del_item_exp_qp_details di,
       diqs_delivery_item_qty_status diqs,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp, 
       pfqpp_table pfqpp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id=di.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pfqpp.pcdi_id=pcdi.pcdi_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and di.is_active='Y'
   and pfqpp.ppfh_id = ppfd.ppfh_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type =  'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   union all
--Any Day Pricing Base Metal +Contract + Called Off + Not Applicable
 select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,       
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,       
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,       
       ppfd.instrument_id,
       0 pricing_days,       
       'Y' is_base_metal,
       'N' is_concentrate,       
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,       
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,       
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,       
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,       
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,       
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,       
       vp.premium,
       null price_unit_id,
       null price_unit,       
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (((case
          when pfqpp.qp_pricing_period_type = 'Event' then
           (diqs.total_qty - diqs.gmr_qty - diqs.fulfilled_qty)
          else
           pofh.qty_to_be_fixed
        end) - nvl(pfd.qty_fixed, 0)) *
        pkg_general.f_get_converted_quantity(pcpd.product_id,
                                             qum.qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1)) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,       
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
       
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       pofh_header_data pofh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pfd_fixation_data pfd,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp,
       pfqpp_table pfqpp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pofh.pofh_id = pfd.pofh_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
  and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pfqpp.pcdi_id=pcdi.pcdi_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
union all
--Any Day Pricing Base Metal +GMR
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,      
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * pofh.qty_to_be_fixed -
       sum(nvl(pfd.qty_fixed, 0)) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       cpc_corporate_profit_center cpc,
       vd_voyage_detail vd,
       pfqpp_table  pfqpp,
       v_pci_multiple_premium vp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id
 and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
 and pcdi.pcdi_id = pcdiqd.pcdi_id
 and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
 and pcpd.strategy_id = css.strategy_id
 and pdm.product_id = pcpd.product_id
 and pcdi.pcdi_id = poch.pcdi_id
 and pocd.poch_id = poch.poch_id
 and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
 and pcbph.pcbph_id = pcbpd.pcbph_id
 and pcbpd.pcbpd_id = pocd.pcbpd_id
 and pcbpd.pcbpd_id = ppfh.pcbpd_id
 and pofh.pocd_id = pocd.pocd_id(+)
 and pofh.pofh_id = pfd.pofh_id(+)
 and pofh.internal_gmr_ref_no is not null
 and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
 and pcpd.profit_center_id = cpc.profit_center_id
 and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
 and pfqpp.pcdi_id=pcdi.pcdi_id
 and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
 and nvl(vd.status, 'NA') in ('Active', 'NA')
 and ppfh.ppfh_id = pfqpp.ppfh_id
 and ppfh.ppfh_id = ppfd.ppfh_id
 and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
 and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
 and pdm.base_quantity_unit = qum.qty_unit_id
 and pcm.is_active = 'Y'
 and pcm.contract_type = 'BASEMETAL'
 and pcm.approval_status = 'Approved'
 and pcdi.is_active = 'Y'
 and gmr.is_deleted = 'N'
 and pdm.is_active = 'Y'
 and qum.is_active = 'Y'
 and pofh.is_active = 'Y'
 and poch.is_active = 'Y'
 and pocd.is_active = 'Y'
 and ppfh.is_active = 'Y'
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm.product_id,
          pdm.product_desc,
          pocd.pcbpd_id,
          pcm.contract_type,
          css.strategy_id,
          css.strategy_name,
          pofh.qp_start_date,
          to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy'),
          pcm.purchase_sales,
          pcm.issue_date,
          (case
            when pfqpp.qp_pricing_period_type = 'Month' then
             pfqpp.qp_month || ' - ' || pfqpp.qp_year
            when pfqpp.qp_pricing_period_type = 'Event' then
             pfqpp.no_of_event_months || ' ' || pfqpp.event_name
            when pfqpp.qp_pricing_period_type = 'Period' then
             to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
             to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
            when pfqpp.qp_pricing_period_type = 'Date' then
             to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
          end),
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no,
          gmr.gmr_ref_no,
          pofh.qty_to_be_fixed,
          vd.eta,
          pcpd.product_id,
          qum.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit_id,
          qum.qty_unit,
          qum.decimals,
          ppfh.formula_description,
          ppfd.exchange_id,
          ppfd.exchange_name,
          ppfd.instrument_id,
          vp.premium,
          pcdi.is_price_optionality_present,
          pcdi.price_option_call_off_status
   union all
--Average Pricing Base Metal+Contract + Not Called Off + Excluding Event Based
select   ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
      (case
         when pfqpp.qp_pricing_period_type = 'Month' then
         to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year)
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_from_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end)   qp_start_date,
       to_char((case
         when pfqpp.qp_pricing_period_type = 'Month' then
         last_day(to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year))
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_to_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end),'dd-Mon-yyyy')   qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       nvl(diqs.open_qty,0) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
    
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       pfqpp_table pfqpp,    
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       qum_quantity_unit_master qum,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'   
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'  
   and ppfh.is_active = 'Y' 
--Average Pricing Base Metal+Contract + Not Called Off + Event Based
union all
select   ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       di.expected_qp_start_date qp_start_date,
       to_char(di.expected_qp_end_date,'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       null trade_date,
       pfqpp.no_of_event_months || ' ' || pfqpp.event_name qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       nvl(diqs.open_qty,0) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
    
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       di_del_item_exp_qp_details di,
       pfqpp_table pfqpp,    
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       qum_quantity_unit_master qum,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and pcdi.pcdi_id = di.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+) 
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type = 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'  
   and ppfh.is_active = 'Y' 
 union all 
--Average Pricing Base Metal+Contract + Called Off + Not Applicable
   select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,       
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       pofh.per_day_pricing_qty *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
       
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,       
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,      
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pfqpp_table pfqpp,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       qum_quantity_unit_master qum,
       pofh_header_data pofh,
       cpc_corporate_profit_center cpc,
       --pfqpp_phy_formula_qp_pricing pfqpp,
       v_pci_multiple_premium vp
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id   
   and pcpd.strategy_id = css.strategy_id   
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id=pocd.poch_id
   and pcm.internal_contract_ref_no = pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pocd.pocd_id = pofh.pocd_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'   
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'   
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y' 
--Average Pricing Base Metal+GMR
   union all
   select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       pofh.per_day_pricing_qty *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff       
      
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       pcdi_pc_delivery_item pcdi,
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pfqpp_table pfqpp,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       qum_quantity_unit_master qum,
       vd_voyage_detail vd,
       pofh_price_opt_fixation_header pofh,
       cpc_corporate_profit_center cpc,       
       v_pci_multiple_premium vp
       
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id = pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id
   and ppfh.ppfh_id=ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pocd.pocd_id = pofh.pocd_id
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pofh.internal_gmr_ref_no is not null
   and nvl(vd.status, 'NA') in ('NA', 'Active')  
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'   
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and pofh.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and gmr.is_deleted = 'N'
 --Fixed by Price Request Base Metal +Contract + Not Called Off + Excluding Event Based 8
 union all
 select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pfqpp.pcbpd_id) qp_start_date,
       f_get_pricing_month(pfqpp.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * nvl(diqs.open_qty,0) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,       
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
      pcpd_pc_product_definition pcpd,
      pdm_productmaster pdm,
      css_corporate_strategy_setup css,
      pfqpp_table pfqpp,     
      ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       v_pci_multiple_premium vp,
       cpc_corporate_profit_center cpc,
       qum_quantity_unit_master qum       
       
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id   
  and ppfh.ppfh_id = ppfd.ppfh_id(+)
  and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pfqpp.is_qp_any_day_basis = 'Y'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pdm.base_quantity_unit
union all
--Fixed by Price Request Base Metal +Contract + Not Called Off + Event Based 9
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
      di.expected_qp_start_date qp_start_date,
       to_char(di.expected_qp_end_date,'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       null trade_date,
       pfqpp.no_of_event_months || ' ' || pfqpp.event_name qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * nvl(diqs.open_qty,0) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,       
       pcdi_pc_delivery_item pcdi,
       di_del_item_exp_qp_details di,
       diqs_delivery_item_qty_status diqs,
      pcpd_pc_product_definition pcpd,
      pdm_productmaster pdm,
      css_corporate_strategy_setup css,
      pfqpp_table pfqpp,     
      ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       v_pci_multiple_premium vp,
       cpc_corporate_profit_center cpc,
       qum_quantity_unit_master qum       
       
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = di.pcdi_id -- Newly Added
   and di.is_active = 'Y' 
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id   
  and  ppfh.ppfh_id = ppfd.ppfh_id(+)
  and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+) 
  and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pfqpp.is_qp_any_day_basis = 'Y'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pdm.base_quantity_unit
union all
--Fixed by Price Request Base Metal +Contract + Called Off + Not Applicable 10
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       pfd.as_of_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       null  quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,       
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,       
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       v_pci_multiple_premium vp,
       cpc_corporate_profit_center cpc,
       qum_quantity_unit_master qum,
       pfqpp_table pfqpp
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.product_id=pdm.product_id
   and pcpd.strategy_id = css.strategy_id      
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id = pfqpp.pcdi_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and pocd.pocd_id = pofh.pocd_id 
   and pofh.pofh_id = pfd.pofh_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pofh.internal_gmr_ref_no is null
   and pofh.qty_to_be_fixed is not null   
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and pfqpp.is_qp_any_day_basis = 'Y'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pfd.is_price_request = 'Y'
   and pfd.as_of_date > trunc(sysdate) --siva
--and ak.corporate_id = '{?CorporateID}'
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm.product_id,
          pdm.product_desc,
          css.strategy_id,
          ppfd.instrument_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,          
          pfd.as_of_date,
          pocd.pcbpd_id,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          pcpd.product_id,
          qum.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit,
          qum.qty_unit_id,
          qum.decimals,
          ppfh.formula_description,
          vp.premium,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcdi.basis_type,
          pcdi.transit_days,
          pcdi.is_price_optionality_present,
          pcdi.price_option_call_off_status
----Fixed by Price Request Base Metal +GMR 11
union all
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       pfd.as_of_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,       
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,      
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pfqpp_table  pfqpp,       
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       gmr_goods_movement_record gmr,
       vd_voyage_detail vd,
       v_pci_multiple_premium vp,
       qum_quantity_unit_master qum,
       cpc_corporate_profit_center cpc
       
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no  = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no  = pcpd.internal_contract_ref_no
   and pcpd.product_id = pdm.product_id
   and pcpd.strategy_id = css.strategy_id   
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id=pocd.poch_id
   and pcdi.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id   = pfqpp.pcdi_id
   and pocd.pocd_id=pofh.pocd_id   
   and pofh.pofh_id = pfd.pofh_id
   and pofh.internal_gmr_ref_no is not null   
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and nvl(vd.status, 'NA') in ('NA', 'Active')   
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.is_qp_any_day_basis = 'Y'
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pfd.is_price_request = 'Y'
   and pfd.as_of_date > trunc(sysdate)
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm.product_id,
          pdm.product_desc,
          css.strategy_id,
          ppfd.instrument_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          pfd.as_of_date,
          pocd.pcbpd_id,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          vd.eta,
          pcpd.product_id,
          qum.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit,
          qum.qty_unit_id,
          qum.decimals,
          ppfh.formula_description,
          vp.premium,
          ppfd.exchange_id,
          pofh.qp_start_date,
          pofh.qp_end_date,
          gmr.gmr_ref_no,
          ppfd.exchange_name,
          pcdi.basis_type,
          pcdi.transit_days,
          pcdi.is_price_optionality_present,
          pcdi.price_option_call_off_status;

ALTER TABLE pqca_pq_chemical_attributes ADD (
  CONSTRAINT fk_pqca_unit_of_measure  FOREIGN KEY (unit_of_measure)
    REFERENCES rm_ratio_master (ratio_id));


ALTER TABLE sam_stock_assay_mapping ADD(
            CONSTRAINT fk_sam_internal_grd_ref_no FOREIGN KEY(internal_grd_ref_no) REFERENCES grd_goods_record_detail(internal_grd_ref_no),
            CONSTRAINT fk_sam_ash_id FOREIGN KEY(ash_id) REFERENCES ash_assay_header(ash_id));

create or replace view v_daily_position_section as
select s1.section_name,
       null contract_ref_no,
       akc.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       cpm.product_id,
       pdm.product_desc product_name,
       null issue_date,
       0 fixed_qty,
       0 quotational_qty,
       qum.qty_unit_id,
       qum.qty_unit base_qty_unit,
       0 open_fixed_qty,
       0 open_quotational_qty
  from ak_corporate akc,
       cpc_corporate_profit_center cpc,
       blm_business_line_master blm,
       cpm_corporateproductmaster cpm,
       pdm_productmaster pdm,
       qum_quantity_unit_master qum,
       (select (case
                 when rownum = 1 then
                  'Physicals'
                 when rownum = 2 then
                  'Any one day price fix'
                 when rownum = 3 then
                  'Average price fix'
                 when rownum = 4 then
                  'Futures'
               end) section_name
          from rml_report_master_list
         where rownum < 5) s1
 where cpc.corporateid = akc.corporate_id 
   and akc.corporate_id = cpm.corporate_id
   and blm.business_line_id(+) = cpc.business_line_id
   and cpm.product_id = pdm.product_id
   and pdm.base_quantity_unit = qum.qty_unit_id;
   
CREATE OR REPLACE VIEW V_BI_LOGISTICS as
with v_ash as(select ash.ash_id,
       sum(asm.net_weight) wet_weight,
       sum(asm.dry_weight)dry_weight
  from ash_assay_header         ash,
       asm_assay_sublot_mapping asm
 where ash.ash_id = asm.ash_id
   and ash.is_active = 'Y'
   and asm.is_active = 'Y'
 group by ash.ash_id), 
 v_agrd_qty as(
select agrd.qty                 qty,
       agrd.internal_grd_ref_no internal_grd_ref_no
  from ash_assay_header ash,
       agrd_action_grd  agrd
 where agrd.internal_grd_ref_no = ash.internal_grd_ref_no
   and agrd.action_no = 1
   and ash.assay_type = 'Shipment Assay'
   and ash.is_active = 'Y'
   and agrd.status = 'Active')
select t.groupid,
       t.corporate_group,
       t.corporate_id,
       t.corporate_name,
       t.profit_center_id,
       t.profit_center_name,
       t.profit_center_short_name,
       t.strategy_id,
       t.strategy_name,
       t.product_id,
       t.product_desc,
       t.quality_id,
       t.quality_name,
       t.contract_type,
       t.counterparty,
       t.contract_ref_no,
       t.delivery_item_ref_no,
       t.internal_contract_item_ref_no,
       t.gmr_ref_no,
       t.gmr_type,
       t.shipment_activity_date,
       t.landing_activity_date,
       t.arrival_no,
       t.invoice_status,
       t.mode_of_transport,
       t.trip_vehicle,
       t.vessel_name,
       t.loading_city_id,
       t.loading_city_name,
       t.loading_state_id,
       t.loading_state_name,
       t.loading_country_id,
       t.loading_country_name,
       t.discharge_city_id,
       t.discharge_city_name,
       t.discharge_state_id,
       t.discharge_state_name,
       t.discharge_country_id,
       t.discharge_country_name,
       t.warehouse_location_id,
       t.warehouse_location,
       t.warehouse_country_id,
       t.warehouse_country_name,
       t.warehouse_state_id,
       t.warehouse_state_name,
       t.warehouse_city_id,
       t.warehouse_city_name,
       t.assay_status,
       t.bl_product_base_uom,
       t.bl_wet_weight,
       t.bl_dry_weight,
       t.actual_product_base_uom,
       t.actual_wet_weight,
       t.actual_dry_weight,
       (t.bl_wet_weight - t.actual_wet_weight) wet_qty_diff,
       (t.bl_dry_weight - t.actual_dry_weight) dry_qty_diff,
       (t.bl_wet_weight - t.actual_wet_weight) / t.bl_wet_weight * 100 wet_ratio,
       (t.bl_dry_weight - t.actual_dry_weight) / t.bl_wet_weight * 100 dry_ratio
  from (select gcd.groupid,
               gcd.groupname corporate_group,
               gmr.corporate_id,
               akc.corporate_name,
               pcpd.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               css.strategy_id,
               css.strategy_name,
               pdm.product_id,
               pdm.product_desc,
               qat.quality_id,
               qat.quality_name,
               gmr.contract_type,
               phd.companyname counterparty,
               pcm.contract_ref_no,
               pcm.contract_ref_no || '-' || pci.del_distribution_item_no delivery_item_ref_no,
               pcm.contract_ref_no || '-' ||
               substr(pci.del_distribution_item_no, 1, 1) internal_contract_item_ref_no,
               gmr.gmr_ref_no,
               (case
                 when gmr.gmr_latest_action_action_id = 'landingDetail' then
                  'Landed'
                 when gmr.gmr_latest_action_action_id = 'shipmentDetail' then
                  'Shipped'
                 else
                  ''
               end) gmr_type,
               axs.eff_date shipment_activity_date,
               agmr.eff_date landing_activity_date,
               wrd.activity_ref_no arrival_no,
               iss.invoice_type_name invoice_status,
               gmr.mode_of_transport,
               agmr.bl_no trip_vehicle,
               gmr.vessel_name,
               cim_load.city_id loading_city_id,
               cim_load.city_name loading_city_name,
               sm_load.state_id loading_state_id,
               sm_load.state_name loading_state_name,
               cym_load.country_id loading_country_id,
               cym_load.country_name loading_country_name,
               cim_discharge.city_id discharge_city_id,
               cim_discharge.city_name discharge_city_name,
               sm_discharge.state_id discharge_state_id,
               sm_discharge.state_name discharge_state_name,
               cym_discharge.country_id discharge_country_id,
               cym_discharge.country_name discharge_country_name,
               sld.storage_loc_id warehouse_location_id,
               sld.storage_location_name warehouse_location,
               sld.country_id warehouse_country_id,
               cym_sld.country_name warehouse_country_name,
               sld.state_id warehouse_state_id,
               sm_sld.state_name warehouse_state_name,
               sld.city_id warehouse_city_id,
               cim_sld.city_name warehouse_city_name,
               ash.assay_type assay_status,
               qum.qty_unit bl_product_base_uom,
               sum(agrd.qty) bl_wet_weight,
               sum(case
                     when pcpq.unit_of_measure = 'Wet' then
                      pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                              sam.ash_id,
                                                              agrd.qty,
                                                              grd.qty_unit_id)
                     else
                      agrd.qty
                   end) bl_dry_weight,
               qum.qty_unit actual_product_base_uom,
               (case
                 when ash.assay_type = 'Weighing and Sampling Assay' then
                  sum(asm.wet_weight)
                 else
                  sum(grd.qty)
               end) actual_wet_weight,
               (case
                 when ash.assay_type = 'Weighing and Sampling Assay' then
                  sum(asm.dry_weight)
                 else
                  sum(case
                 when pcpq.unit_of_measure = 'Wet' then
                  pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                          sam.ash_id,
                                                          grd.qty,
                                                          grd.qty_unit_id)
                 else
                  agrd.qty
               end) end) actual_dry_weight
          from gmr_goods_movement_record gmr,
               ak_corporate akc,
               grd_goods_record_detail grd,
               gcd_groupcorporatedetails gcd,
               pcpd_pc_product_definition pcpd,
               cpc_corporate_profit_center cpc,
               (select gmr.internal_gmr_ref_no,
                       agmr.eff_date,
                       agmr.bl_no
                  from gmr_goods_movement_record gmr,
                       agmr_action_gmr           agmr
                 where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                   and agmr.gmr_latest_action_action_id = 'landingDetail'
                   and agmr.is_deleted = 'N') agmr,
               pcm_physical_contract_main pcm,
               v_bi_latest_gmr_invoice iis,
               is_invoice_summary iss,
               css_corporate_strategy_setup css,
               pcdi_pc_delivery_item pcdi,
               pci_physical_contract_item pci,
               pcpq_pc_product_quality pcpq,
               phd_profileheaderdetails phd,
               (select wrd.internal_gmr_ref_no,
                       wrd.activity_ref_no,
                       wrd.shed_id
                  from wrd_warehouse_receipt_detail wrd
                 where (wrd.internal_gmr_ref_no, wrd.action_no) in
                       (select wrd.internal_gmr_ref_no,
                               max(action_no)
                          from wrd_warehouse_receipt_detail wrd
                         group by wrd.internal_gmr_ref_no)) wrd,
               sld_storage_location_detail sld,
               sm_state_master sm_sld,
               cim_citymaster cim_sld,
               cym_countrymaster cym_sld,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
               qum_quantity_unit_master qum,
               sm_state_master sm_load,
               cim_citymaster cim_load,
               cym_countrymaster cym_load,
               sm_state_master sm_discharge,
               cim_citymaster cim_discharge,
               cym_countrymaster cym_discharge,
               ash_assay_header ash,
               v_ash asm,
               sam_stock_assay_mapping sam,
               axs_action_summary axs,
               v_agrd_qty agrd
         where gmr.corporate_id = akc.corporate_id
           and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and akc.groupid = gcd.groupid
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
           and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
           and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           and gmr.internal_gmr_ref_no = iis.internal_gmr_ref_no(+)
           and iis.internal_invoice_ref_no = iss.internal_invoice_ref_no(+)
           and pcpd.strategy_id = css.strategy_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           and pcdi.pcdi_id = pci.pcdi_id
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pci.pcpq_id = pcpq.pcpq_id
           and pcm.cp_id = phd.profileid
           and gmr.internal_gmr_ref_no = wrd.internal_gmr_ref_no(+)
           and wrd.shed_id = sld.storage_loc_id(+)
           and sld.state_id = sm_sld.state_id(+)
           and sld.city_id = cim_sld.city_id(+)
           and sld.country_id = cym_sld.country_id(+)
           and pcpd.product_id = pdm.product_id
           and pcpq.quality_template_id = qat.quality_id
           and pcpd.qty_unit_id = qum.qty_unit_id
           and gmr.loading_state_id = sm_load.state_id(+)
           and gmr.loading_city_id = cim_load.city_id(+)
           and gmr.loading_country_id = cym_load.country_id(+)
           and gmr.discharge_state_id = sm_discharge.state_id(+)
           and gmr.discharge_city_id = cim_discharge.city_id(+)
           and gmr.discharge_country_id = cym_discharge.country_id(+)
           and grd.internal_grd_ref_no = sam.internal_grd_ref_no
           and sam.ash_id = ash.ash_id
           and ash.ash_id = asm.ash_id
           and nvl(ash.is_active, 'Y') = 'Y'
           and grd.is_afloat = 'N'
           and gmr.is_deleted = 'N'
           and gmr.is_internal_movement = 'N'
           and pci.is_active = 'Y'
           and pcm.is_active = 'Y'
           and pcdi.is_active = 'Y'
           and pcpq.is_active = 'Y'
           and phd.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and gcd.is_active = 'Y'
           and sam.is_latest_pricing_assay = 'Y'
           and pcpd.input_output = 'Input'
           and grd.status = 'Active'
           and grd.internal_grd_ref_no = agrd.internal_grd_ref_no
           and grd.tolling_stock_type = 'None Tolling'
         group by gcd.groupid,
                  gcd.groupname,
                  gmr.corporate_id,
                  akc.corporate_name,
                  pcpd.profit_center_id,
                  cpc.profit_center_name,
                  cpc.profit_center_short_name,
                  css.strategy_id,
                  css.strategy_name,
                  pdm.product_id,
                  pdm.product_desc,
                  qat.quality_id,
                  qat.quality_name,
                  gmr.contract_type,
                  phd.companyname,
                  pcm.contract_ref_no,
                  pci.del_distribution_item_no,
                  gmr.gmr_ref_no,
                  gmr.gmr_latest_action_action_id,
                  axs.eff_date,
                  agmr.eff_date,
                  wrd.activity_ref_no,
                  iss.invoice_type_name,
                  gmr.mode_of_transport,
                  agmr.bl_no,
                  gmr.vessel_name,
                  cim_load.city_id,
                  cim_load.city_name,
                  sm_load.state_id,
                  sm_load.state_name,
                  cym_load.country_id,
                  cym_load.country_name,
                  cim_discharge.city_id,
                  cim_discharge.city_name,
                  sm_discharge.state_id,
                  sm_discharge.state_name,
                  cym_discharge.country_id,
                  cym_discharge.country_name,
                  sld.storage_loc_id,
                  sld.storage_location_name,
                  sld.country_id,
                  cym_sld.country_name,
                  sld.state_id,
                  sm_sld.state_name,
                  sld.city_id,
                  cim_sld.city_name,
                  ash.assay_type,
                  qum.qty_unit,
                  pcpq.unit_of_measure,
                  qum.qty_unit) t
/
drop MATERIALIZED VIEW MV_BI_LOGISTICS;
CREATE MATERIALIZED VIEW MV_BI_LOGISTICS
REFRESH FORCE ON DEMAND
START WITH TO_DATE('22-06-2012 16:33:41', 'DD-MM-YYYY HH24:MI:SS') NEXT SYSDATE+5/1440 
AS
SELECT * FROM V_BI_LOGISTICS;
create or replace view v_bi_assay_comparision as 
select t.corporate_id,
       t.corporate_name,
       t.business_line_name,
       t.profit_center_id,
       t.profit_center_name,
       t.profit_center_short_name,
       t.strategy_id,
       t.contract_type,
       t.producttype,
       t.product_desc,
       t.quality_name,
       t.contract_ref_no,
       t.delivery_ref_no,
       t.internal_contract_item_ref_no,
       t.cpname,
       t.trader,
       t.executiontype,
       t.gmr_ref_no,
       t.internal_grd_ref_no,
       t.gmr_latest_action_action_id,
       t.eff_date,
       t.internal_stock_ref_no,
       t.is_final_weight,
       t.sublot_ref_no,
       t.assay_winner,
       t.ash_id,
       t.assay_type,
       t.assay_ref_no,
       t.umpirename,
       t.wet_qty,
       t.dry_qty,
       t.product_base_uom,
       t.element_id,
       t.element_name,
       t.assayvalue,
       t.assayratio,
       t.assay_content,
       t.assayvalue weighted_avg_sublot,
       (sum(t.assay_content * t.assayvalue)
        over(partition by t.internal_grd_ref_no,
             t.element_id order by t.internal_grd_ref_no,
             t.element_id) / sum(decode(t.assay_content, null, 1, 0, 1))
        over(partition by t.internal_grd_ref_no,
             t.element_id order by t.internal_grd_ref_no,
             t.element_id)) weighted_avg_stock,
       (sum(t.assay_content * t.assayvalue)
        over(partition by t.gmr_ref_no, t.element_id order by t.gmr_ref_no) /
        sum(decode(t.assay_content, null, 1, 0, 1))
        over(partition by t.gmr_ref_no, t.element_id order by t.gmr_ref_no)) weighted_avg_gmr
  from ( --- purchase
        select gmr.corporate_id,
                akc.corporate_name,
                blm.business_line_name,
                grd.profit_center_id,
                cpc.profit_center_name,
                cpc.profit_center_short_name,
                grd.strategy_id,
                (case
                  when pcm.purchase_sales = 'P' and
                       pcm.is_tolling_contract = 'N' then
                   'Purchase Contract'
                  when pcm.purchase_sales = 'S' and
                       pcm.is_tolling_contract = 'N' then
                   'Sales Contract'
                  when pcmte.tolling_service_type = 'P' and
                       pcm.is_tolling_contract = 'Y' and
                       pcmte.is_pass_through = 'Y' then
                   'Internal Buy Tolling Service Contract'
                  when pcmte.tolling_service_type = 'P' and
                       pcm.is_tolling_contract = 'Y' and
                       pcmte.is_pass_through = 'N' then
                   'Buy Tolling Service Contract'
                  when pcmte.tolling_service_type = 'S' and
                       pcm.is_tolling_contract = 'Y' then
                   'Sell Tolling Service Contract'
                  when pcm.purchase_sales = 'P' and
                       pcm.is_tolling_contract = 'Y' and
                       pcmte.is_pass_through is null then
                   'Tolling Service Contract'
                end) contract_type,
                pdm.product_type_id producttype,
                pdm.product_desc,
                qat.quality_name,
                pcm.contract_ref_no,
                pci.del_distribution_item_no delivery_ref_no,
                grd.internal_contract_item_ref_no,
                phd.companyname cpname,
                aku.login_name trader,
                pcm.partnership_type executiontype,
                gmr.gmr_ref_no,
                grd.internal_grd_ref_no internal_grd_ref_no,
                gmr.gmr_latest_action_action_id,
                gmr.eff_date,
                grd.internal_stock_ref_no,
                gmr.is_final_weight,
                asm.sub_lot_no sublot_ref_no,
                pqca.assay_winner,
                ash.ash_id,
                (case
                  when ash.assay_type = 'Shipment Assay' then
                   'Contractual Assay'
                  else
                   ash.assay_type
                end) assay_type,
                ash.assay_ref_no,
                (case
                  when ash.assay_type in ('Umpire Assay', 'Final Assay') then
                   phd_umpire.companyname
                  else
                   null
                end) umpirename,
                asm.net_weight wet_qty,
                asm.dry_weight dry_qty,
                asm.net_weight_unit,
                qum.qty_unit product_base_uom,
                pqca.element_id,
                aml.attribute_name element_name,
                pqca.typical assayvalue,
                rm.ratio_name assayratio,
                pkg_report_general.fn_get_elmt_assay_content_qty(pqca.element_id,
                                                                 ash.ash_id,
                                                                 asm.dry_weight,
                                                                 asm.net_weight_unit) assay_content
          from gmr_goods_movement_record   gmr,
                grd_goods_record_detail     grd,
                pci_physical_contract_item  pci,
                pcm_physical_contract_main  pcm,
                pcmte_pcm_tolling_ext       pcmte,
                pcdi_pc_delivery_item       pcdi,
                pcpq_pc_product_quality     pcpq,
                pdm_productmaster           pdm,
                qat_quality_attributes      qat,
                qum_quantity_unit_master    qum,
                ash_assay_header            ash,
                asm_assay_sublot_mapping    asm,
                pqca_pq_chemical_attributes pqca,
                rm_ratio_master             rm,
                aml_attribute_master_list   aml,
                cpc_corporate_profit_center cpc,
                blm_business_line_master    blm,
                ak_corporate                akc,
                ak_corporate_user           aku,
                phd_profileheaderdetails    phd,
                phd_profileheaderdetails    phd_umpire
         where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and grd.status = 'Active'
           and gmr.corporate_id = akc.corporate_id
           and grd.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
           and pcm.cp_id = phd.profileid
           and pcm.trader_id = aku.user_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcdi.pcdi_id = pci.pcdi_id
           and pci.pcpq_id = pcpq.pcpq_id
           and grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           and grd.product_id = pdm.product_id
           and grd.quality_id = qat.quality_id
           and asm.net_weight_unit = qum.qty_unit_id
           and grd.internal_grd_ref_no = ash.internal_grd_ref_no
           and gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
           and ash.ash_id = asm.ash_id
           and asm.asm_id = pqca.asm_id
           and pqca.unit_of_measure = ratio_id
           and pqca.element_id = aml.attribute_id
           and ash.assayer = phd_umpire.profileid(+)
           and pci.is_active = 'Y'
           and pcm.is_active = 'Y'
           and pcdi.is_active = 'Y'
           and ash.is_active = 'Y'
           and asm.is_active = 'Y'
           and pqca.is_active = 'Y'
           and rm.is_active = 'Y'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and qum.is_active = 'Y'
           and aml.is_active = 'Y'
           and ash.assay_type not in
               ('Pricing Assay', 'Position Assay', 'Self Assay',
                'Umpire Assay', 'CounterParty Assay',
                'Weighted Avg Position Assay', 'Weighted Avg Pricing Assay',
                'Invoicing Assay', 'Weighted Avg Invoice Assay')
        union all ----sales 
        select gmr.corporate_id,
               akc.corporate_name,
               blm.business_line_name,
               dgrd.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               dgrd.strategy_id,
               (case
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'N' then
                  'Purchase Contract'
                 when pcm.purchase_sales = 'S' and
                      pcm.is_tolling_contract = 'N' then
                  'Sales Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'Y' then
                  'Internal Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'N' then
                  'Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'S' and
                      pcm.is_tolling_contract = 'Y' then
                  'Sell Tolling Service Contract'
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through is null then
                  'Tolling Service Contract'
               end) contract_type,
               pdm.product_type_id producttype,
               pdm.product_desc,
               qat.quality_name,
               pcm.contract_ref_no,
               pci.del_distribution_item_no delivery_ref_no,
               dgrd.internal_contract_item_ref_no,
               phd.companyname cpname,
               aku.login_name trader,
               pcm.partnership_type executiontype,
               gmr.gmr_ref_no,
               dgrd.internal_dgrd_ref_no internal_grd_ref_no,
               gmr.gmr_latest_action_action_id,
               gmr.eff_date,
               dgrd.internal_stock_ref_no,
               gmr.is_final_weight,
               asm.sub_lot_no sublot_ref_no,
               pqca.assay_winner,
               ash.ash_id,
               (case
                 when ash.assay_type = 'Shipment Assay' then
                  'Contractual Assay'
                 else
                  ash.assay_type
               end) assay_type,
               ash.assay_ref_no,
               (case
                 when ash.assay_type in ('Umpire Assay', 'Final Assay') then
                  phd_umpire.companyname
                 else
                  null
               end) umpirename,
               asm.net_weight wet_qty,
               asm.dry_weight dry_qty,
               asm.net_weight_unit,
               qum.qty_unit product_base_uom,
               pqca.element_id,
               aml.attribute_name element_name,
               pqca.typical assayvalue,
               rm.ratio_name assayratio,
               pkg_report_general.fn_get_elmt_assay_content_qty(pqca.element_id,
                                                                ash.ash_id,
                                                                asm.dry_weight,
                                                                asm.net_weight_unit) assay_content
          from gmr_goods_movement_record   gmr,
               dgrd_delivered_grd          dgrd,
               pci_physical_contract_item  pci,
               pcm_physical_contract_main  pcm,
               pcmte_pcm_tolling_ext       pcmte,
               pcdi_pc_delivery_item       pcdi,
               pcpq_pc_product_quality     pcpq,
               pdm_productmaster           pdm,
               qat_quality_attributes      qat,
               qum_quantity_unit_master    qum,
               ash_assay_header            ash,
               asm_assay_sublot_mapping    asm,
               pqca_pq_chemical_attributes pqca,
               rm_ratio_master             rm,
               aml_attribute_master_list   aml,
               cpc_corporate_profit_center cpc,
               blm_business_line_master    blm,
               ak_corporate                akc,
               ak_corporate_user           aku,
               phd_profileheaderdetails    phd,
               phd_profileheaderdetails    phd_umpire
         where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and dgrd.status = 'Active'
           and gmr.corporate_id = akc.corporate_id
           and dgrd.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
           and pcm.cp_id = phd.profileid
           and pcm.trader_id = aku.user_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcdi.pcdi_id = pci.pcdi_id
           and pci.pcpq_id = pcpq.pcpq_id
           and dgrd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           and dgrd.product_id = pdm.product_id
           and dgrd.quality_id = qat.quality_id
           and asm.net_weight_unit = qum.qty_unit_id
           and dgrd.internal_dgrd_ref_no = ash.internal_grd_ref_no
           and gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
           and ash.ash_id = asm.ash_id
           and asm.asm_id = pqca.asm_id
           and pqca.unit_of_measure = ratio_id
           and pqca.element_id = aml.attribute_id
           and ash.assayer = phd_umpire.profileid(+)
           and pci.is_active = 'Y'
           and pcm.is_active = 'Y'
           and pcdi.is_active = 'Y'
           and ash.is_active = 'Y'
           and asm.is_active = 'Y'
           and pqca.is_active = 'Y'
           and rm.is_active = 'Y'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and qum.is_active = 'Y'
           and aml.is_active = 'Y'
           and ash.assay_type not in
               ('Pricing Assay', 'Position Assay', 'Self Assay',
                'Umpire Assay', 'CounterParty Assay',
                'Weighted Avg Position Assay', 'Weighted Avg Pricing Assay',
                'Invoicing Assay', 'Weighted Avg Invoice Assay')
        union all --- multiple self,CP,Umpire assays for purchase
        select gmr.corporate_id,
               akc.corporate_name,
               blm.business_line_name,
               grd.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               grd.strategy_id,
               (case
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'N' then
                  'Purchase Contract'
                 when pcm.purchase_sales = 'S' and
                      pcm.is_tolling_contract = 'N' then
                  'Sales Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'Y' then
                  'Internal Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'N' then
                  'Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'S' and
                      pcm.is_tolling_contract = 'Y' then
                  'Sell Tolling Service Contract'
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through is null then
                  'Tolling Service Contract'
               end) contract_type,
               pdm.product_type_id producttype,
               pdm.product_desc,
               qat.quality_name,
               pcm.contract_ref_no,
               pci.del_distribution_item_no delivery_ref_no,
               grd.internal_contract_item_ref_no,
               phd.companyname cpname,
               aku.login_name trader,
               pcm.partnership_type executiontype,
               gmr.gmr_ref_no,
               grd.internal_grd_ref_no internal_grd_ref_no,
               gmr.gmr_latest_action_action_id,
               gmr.eff_date,
               grd.internal_stock_ref_no,
               gmr.is_final_weight,
               asm.sub_lot_no sublot_ref_no,
               pqca.assay_winner,
               ash.ash_id,
               (case
                 when ash.assay_type = 'Shipment Assay' then
                  'Contractual Assay'
                 else
                  ash.assay_type
               end) assay_type,
               ash.assay_ref_no,
               (case
                 when ash.assay_type in ('Umpire Assay', 'Final Assay') then
                  phd_umpire.companyname
                 else
                  null
               end) umpirename,
               asm.net_weight wet_qty,
               asm.dry_weight dry_qty,
               asm.net_weight_unit,
               qum.qty_unit product_base_uom,
               pqca.element_id,
               aml.attribute_name element_name,
               pqca.typical assayvalue,
               rm.ratio_name assayratio,
               pkg_report_general.fn_get_elmt_assay_content_qty(pqca.element_id,
                                                                ash.ash_id,
                                                                asm.dry_weight,
                                                                asm.net_weight_unit) assay_content
          from gmr_goods_movement_record   gmr,
               grd_goods_record_detail     grd,
               pci_physical_contract_item  pci,
               pcm_physical_contract_main  pcm,
               pcmte_pcm_tolling_ext       pcmte,
               pcdi_pc_delivery_item       pcdi,
               pcpq_pc_product_quality     pcpq,
               pdm_productmaster           pdm,
               qat_quality_attributes      qat,
               qum_quantity_unit_master    qum,
               ash_assay_header            ash,
               asm_assay_sublot_mapping    asm,
               pqca_pq_chemical_attributes pqca,
               rm_ratio_master             rm,
               aml_attribute_master_list   aml,
               cpc_corporate_profit_center cpc,
               blm_business_line_master    blm,
               ak_corporate                akc,
               ak_corporate_user           aku,
               phd_profileheaderdetails    phd,
               phd_profileheaderdetails    phd_umpire
         where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and grd.status = 'Active'
           and gmr.corporate_id = akc.corporate_id
           and grd.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
           and pcm.cp_id = phd.profileid
           and pcm.trader_id = aku.user_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcdi.pcdi_id = pci.pcdi_id
           and pci.pcpq_id = pcpq.pcpq_id
           and grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           and grd.product_id = pdm.product_id
           and grd.quality_id = qat.quality_id
           and asm.net_weight_unit = qum.qty_unit_id
           and grd.internal_grd_ref_no = ash.internal_grd_ref_no
           and gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
           and ash.ash_id = asm.ash_id
           and asm.asm_id = pqca.asm_id
           and pqca.unit_of_measure = ratio_id
           and pqca.element_id = aml.attribute_id
           and ash.assayer = phd_umpire.profileid(+)
           and pci.is_active = 'Y'
           and pcm.is_active = 'Y'
           and pcdi.is_active = 'Y'
           and ash.is_active = 'Y'
           and asm.is_active = 'Y'
           and pqca.is_active = 'Y'
           and rm.is_active = 'Y'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and qum.is_active = 'Y'
           and aml.is_active = 'Y'
           and ash.use_for_finalization = 'Y'
           and ash.assay_type in
               ('Self Assay', 'Umpire Assay', 'CounterParty Assay')
        union all  --- multiple self,CP,Umpire assays for sales
        select gmr.corporate_id,
               akc.corporate_name,
               blm.business_line_name,
               dgrd.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               dgrd.strategy_id,
               (case
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'N' then
                  'Purchase Contract'
                 when pcm.purchase_sales = 'S' and
                      pcm.is_tolling_contract = 'N' then
                  'Sales Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'Y' then
                  'Internal Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'N' then
                  'Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'S' and
                      pcm.is_tolling_contract = 'Y' then
                  'Sell Tolling Service Contract'
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through is null then
                  'Tolling Service Contract'
               end) contract_type,
               pdm.product_type_id producttype,
               pdm.product_desc,
               qat.quality_name,
               pcm.contract_ref_no,
               pci.del_distribution_item_no delivery_ref_no,
               dgrd.internal_contract_item_ref_no,
               phd.companyname cpname,
               aku.login_name trader,
               pcm.partnership_type executiontype,
               gmr.gmr_ref_no,
               dgrd.internal_dgrd_ref_no internal_grd_ref_no,
               gmr.gmr_latest_action_action_id,
               gmr.eff_date,
               dgrd.internal_stock_ref_no,
               gmr.is_final_weight,
               asm.sub_lot_no sublot_ref_no,
               pqca.assay_winner,
               ash.ash_id,
               (case
                 when ash.assay_type = 'Shipment Assay' then
                  'Contractual Assay'
                 else
                  ash.assay_type
               end) assay_type,
               ash.assay_ref_no,
               (case
                 when ash.assay_type in ('Umpire Assay', 'Final Assay') then
                  phd_umpire.companyname
                 else
                  null
               end) umpirename,
               asm.net_weight wet_qty,
               asm.dry_weight dry_qty,
               asm.net_weight_unit,
               qum.qty_unit product_base_uom,
               pqca.element_id,
               aml.attribute_name element_name,
               pqca.typical assayvalue,
               rm.ratio_name assayratio,
               pkg_report_general.fn_get_elmt_assay_content_qty(pqca.element_id,
                                                                ash.ash_id,
                                                                asm.dry_weight,
                                                                asm.net_weight_unit) assay_content
          from gmr_goods_movement_record   gmr,
               dgrd_delivered_grd          dgrd,
               pci_physical_contract_item  pci,
               pcm_physical_contract_main  pcm,
               pcmte_pcm_tolling_ext       pcmte,
               pcdi_pc_delivery_item       pcdi,
               pcpq_pc_product_quality     pcpq,
               pdm_productmaster           pdm,
               qat_quality_attributes      qat,
               qum_quantity_unit_master    qum,
               ash_assay_header            ash,
               asm_assay_sublot_mapping    asm,
               pqca_pq_chemical_attributes pqca,
               rm_ratio_master             rm,
               aml_attribute_master_list   aml,
               cpc_corporate_profit_center cpc,
               blm_business_line_master    blm,
               ak_corporate                akc,
               ak_corporate_user           aku,
               phd_profileheaderdetails    phd,
               phd_profileheaderdetails    phd_umpire
         where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and dgrd.status = 'Active'
           and gmr.corporate_id = akc.corporate_id
           and dgrd.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
           and pcm.cp_id = phd.profileid
           and pcm.trader_id = aku.user_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcdi.pcdi_id = pci.pcdi_id
           and pci.pcpq_id = pcpq.pcpq_id
           and dgrd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           and dgrd.product_id = pdm.product_id
           and dgrd.quality_id = qat.quality_id
           and asm.net_weight_unit = qum.qty_unit_id
           and dgrd.internal_dgrd_ref_no = ash.internal_grd_ref_no
           and gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
           and ash.ash_id = asm.ash_id
           and asm.asm_id = pqca.asm_id
           and pqca.unit_of_measure = ratio_id
           and pqca.element_id = aml.attribute_id
           and ash.assayer = phd_umpire.profileid(+)
           and pci.is_active = 'Y'
           and pcm.is_active = 'Y'
           and pcdi.is_active = 'Y'
           and ash.is_active = 'Y'
           and asm.is_active = 'Y'
           and pqca.is_active = 'Y'
           and rm.is_active = 'Y'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and qum.is_active = 'Y'
           and aml.is_active = 'Y'
           and ash.use_for_finalization = 'Y'
           and ash.assay_type in
               ('Self Assay', 'Umpire Assay', 'CounterParty Assay')) t;
DROP MATERIALIZED VIEW MV_BI_ASSAY_COMPARISION;
CREATE MATERIALIZED VIEW MV_BI_ASSAY_COMPARISION
REFRESH FORCE ON DEMAND
START WITH TO_DATE('25-06-2012 17:14:53', 'DD-MM-YYYY HH24:MI:SS') NEXT SYSDATE+20/1440  
AS
SELECT * FROM V_BI_ASSAY_COMPARISION;

create or replace view v_in_process_stock as
select ips_temp.corporate_id,
       ips_temp.internal_grd_ref_no,
       ips_temp.stock_ref_no,
       ips_temp.internal_gmr_ref_no,
       ips_temp.gmr_ref_no,
       ips_temp.action_id,
       (case
         when ips_temp.action_id = 'RECORD_OUT_PUT_TOLLING' then
          'Receive Material'
         when ips_temp.action_id = 'CREATE_FREE_MATERIAL' then
          'Capture Yield'
         else
          ips_temp.action_name
       end) action_name,
       ips_temp.internal_action_ref_no,
       ips_temp.activity_date,
       ips_temp.action_ref_no,
       ips_temp.internal_contract_item_ref_no,
       ips_temp.contract_item_ref_no,
       ips_temp.pcdi_id,
       ips_temp.delivery_item_ref_no,
       ips_temp.internal_contract_ref_no,
       ips_temp.contract_ref_no,
       ips_temp.smelter_cp_id,
       ips_temp.smelter_cp_name,
       ips_temp.product_id,
       ips_temp.product_name,
       ips_temp.quality_id,
       ips_temp.quality_name,
       ips_temp.element_id,
       ips_temp.element_name,
       ips_temp.warehouse_profile_id,
       ips_temp.warehouse,
       ips_temp.shed_id,
       ips_temp.shed_name,
       ips_temp.stock_qty,
       ips_temp.qty_unit,
       ips_temp.qty_unit_id,
       ips_temp.payable_returnable_type,
       (case
         when ips_temp.tolling_stock_type = 'RM In Process Stock' then
          'Receive Material Stock'
         when ips_temp.tolling_stock_type = 'MFT In Process Stock' then
          'In Process Stock'
       /* when ips_temp.tolling_stock_type = 'Free Material Stock' then
                                                           'Free Metal Stock'*/
         when ips_temp.tolling_stock_type = 'Delta MFT IP Stock' then
          'Delta IP Stock'
         else
          ips_temp.tolling_stock_type
       end) tolling_stock_type,
       ips_temp.assay_content_qty,
       ips_temp.is_pass_through,
       ips_temp.element_by_product,
       ips_temp.input_stock_ref_no
  from (select gmr.corporate_id,
               grd.internal_grd_ref_no,
               grd.internal_stock_ref_no stock_ref_no,
               gmr.internal_gmr_ref_no,
               gmr.gmr_ref_no,
               axs.action_id,
               axm.action_name action_name,
               axs.internal_action_ref_no,
               axs.eff_date activity_date,
               axs.action_ref_no,
               pci.internal_contract_item_ref_no,
               pci.contract_item_ref_no,
               pci.pcdi_id pcdi_id,
               pci.delivery_item_ref_no delivery_item_ref_no,
               pci.internal_contract_ref_no,
               pci.contract_ref_no,
               wrd.smelter_cp_id smelter_cp_id,
               phd.companyname smelter_cp_name,
               grd.product_id,
               prdm.product_desc product_name,
               qat.quality_id,
               qat.quality_name,
               grd.element_id,
               aml.attribute_name element_name,
               grd.warehouse_profile_id,
               shm.companyname as warehouse,
               grd.shed_id,
               shm.shed_name,
               nvl(grd.qty, 0) as stock_qty,
               pkg_general.f_get_quantity_unit(grd.qty_unit_id) as qty_unit,
               grd.qty_unit_id as qty_unit_id,
               grd.payable_returnable_type,
               grd.tolling_stock_type,
               grd.assay_content as assay_content_qty,
               gmr.is_pass_through is_pass_through,
               (aml.attribute_name || '/' || pdm_consc.product_desc) element_by_product,
               grd_cloned.internal_stock_ref_no input_stock_ref_no
          from grd_goods_record_detail      grd,
               grd_goods_record_detail      grd_cloned,
               pdm_productmaster            pdm_consc,
               gmr_goods_movement_record    gmr,
               gam_gmr_action_mapping       gam,
               axs_action_summary           axs,
               axm_action_master            axm,
               wrd_warehouse_receipt_detail wrd,
               v_pci                        pci,
               v_shm_shed_master            shm,
               pdm_productmaster            prdm,
               qat_quality_attributes       qat,
               aml_attribute_master_list    aml,
               phd_profileheaderdetails     phd
         where grd.is_deleted = 'N'
           and grd.status = 'Active'
           and grd.tolling_stock_type in
               ('MFT In Process Stock', 'Delta MFT IP Stock')
           and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and wrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and pci.internal_contract_item_ref_no =
               grd.internal_contract_item_ref_no
           and shm.profile_id = grd.warehouse_profile_id
           and shm.shed_id = grd.shed_id
           and prdm.product_id = grd.product_id
           and qat.quality_id = grd.quality_id
           and aml.attribute_id = grd.element_id
           and phd.profileid = wrd.smelter_cp_id
           and gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
           and gam.internal_action_ref_no(+) =
               gmr.gmr_first_int_action_ref_no
           and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
           and axs.status(+) = 'Active'
           and axm.action_id(+) = axs.action_id
           and grd_cloned.internal_grd_ref_no =
               grd.parent_internal_grd_ref_no
           and grd_cloned.is_deleted = 'N'
           and grd_cloned.status = 'Active'
           and pdm_consc.product_id = grd_cloned.product_id
        
        union all
        
        select gmr.corporate_id,
               grd.internal_grd_ref_no,
               grd.internal_stock_ref_no stock_ref_no,
               gmr.internal_gmr_ref_no,
               gmr.gmr_ref_no,
               axs.action_id,
               axm.action_name action_name,
               axs.internal_action_ref_no,
               axs.eff_date activity_date,
               axs.action_ref_no,
               pci.internal_contract_item_ref_no,
               pci.contract_item_ref_no,
               pci.pcdi_id pcdi_id,
               pci.delivery_item_ref_no delivery_item_ref_no,
               pci.internal_contract_ref_no,
               pci.contract_ref_no,
               wrd.smelter_cp_id smelter_cp_id,
               phd.companyname smelter_cp_name,
               grd.product_id,
               prdm.product_desc product_name,
               qat.quality_id,
               qat.quality_name,
               grd.element_id,
               aml.attribute_name element_name,
               grd.warehouse_profile_id,
               shm.companyname as warehouse,
               grd.shed_id,
               shm.shed_name,
               nvl(grd.qty, 0) as stock_qty,
               pkg_general.f_get_quantity_unit(grd.qty_unit_id) as qty_unit,
               grd.qty_unit_id as qty_unit_id,
               grd.payable_returnable_type,
               grd.tolling_stock_type,
               grd.assay_content as assay_content_qty,
               gmr.is_pass_through is_pass_through,
               (aml.attribute_name || '/' || pdm_parent.product_desc) element_by_product,
               grd_parent.internal_stock_ref_no input_stock_ref_no
        
          from grd_goods_record_detail      grd,
               grd_goods_record_detail      grd_parent,
               pdm_productmaster            pdm_parent,
               gmr_goods_movement_record    gmr,
               gam_gmr_action_mapping       gam,
               axs_action_summary           axs,
               axm_action_master            axm,
               wrd_warehouse_receipt_detail wrd,
               v_pci                        pci,
               v_shm_shed_master            shm,
               pdm_productmaster            prdm,
               qat_quality_attributes       qat,
               aml_attribute_master_list    aml,
               phd_profileheaderdetails     phd
         where grd.is_deleted = 'N'
           and grd.status = 'Active'
           and grd.tolling_stock_type = 'RM In Process Stock'
           and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and wrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and pci.internal_contract_item_ref_no(+) =
               grd.internal_contract_item_ref_no
           and shm.profile_id = grd.warehouse_profile_id
           and shm.shed_id = grd.shed_id
           and prdm.product_id = grd.product_id
           and qat.quality_id = grd.quality_id
           and aml.attribute_id(+) = grd.element_id
           and phd.profileid = wrd.smelter_cp_id
           and gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
           and gam.internal_action_ref_no(+) =
               gmr.gmr_first_int_action_ref_no
           and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
           and axs.status(+) = 'Active'
           and axm.action_id(+) = axs.action_id
           and grd_parent.internal_grd_ref_no(+) =
               grd.parent_internal_grd_ref_no
           and grd_parent.is_deleted(+) = 'N'
           and grd_parent.status(+) = 'Active'
           and pdm_parent.product_id(+) = grd_parent.product_id
        
        union all
        select agmr.corporate_id,
               agrd.internal_grd_ref_no,
               agrd.internal_stock_ref_no stock_ref_no,
               agmr.internal_gmr_ref_no,
               agmr.gmr_ref_no,
               axs.action_id,
               axm.action_name action_name,
               axs.internal_action_ref_no,
               axs.eff_date activity_date,
               axs.action_ref_no,
               pci.internal_contract_item_ref_no,
               pci.contract_item_ref_no,
               pci.pcdi_id pcdi_id,
               pci.delivery_item_ref_no delivery_item_ref_no,
               pci.internal_contract_ref_no,
               pci.contract_ref_no,
               wrd.smelter_cp_id smelter_cp_id,
               phd.companyname smelter_cp_name,
               agrd.product_id,
               prdm.product_desc product_name,
               qat.quality_id,
               qat.quality_name,
               agrd.element_id,
               aml.attribute_name element_name,
               agrd.warehouse_profile_id,
               shm.companyname as warehouse,
               agrd.shed_id,
               shm.shed_name,
               nvl(agrd.qty, 0) as stock_qty,
               pkg_general.f_get_quantity_unit(agrd.qty_unit_id) as qty_unit,
               agrd.qty_unit_id as qty_unit_id,
               agrd.payable_returnable_type,
               agrd.tolling_stock_type,
               agrd.assay_content as assay_content_qty,
               gmr.is_pass_through is_pass_through,
               (aml.attribute_name || '/' || pdm_consc.product_desc) element_by_product,
               agrd_cloned.internal_stock_ref_no input_stock_ref_no
          from agrd_action_grd              agrd,
               agrd_action_grd              agrd_fm,
               agrd_action_grd              agrd_cloned,
               pdm_productmaster            pdm_consc,
               ypd_yield_pct_detail         ypd,
               gmr_goods_movement_record    gmr,
               agmr_action_gmr              agmr,
               axs_action_summary           axs,
               axm_action_master            axm,
               wrd_warehouse_receipt_detail wrd,
               v_pci                        pci,
               v_shm_shed_master            shm,
               pdm_productmaster            prdm,
               qat_quality_attributes       qat,
               aml_attribute_master_list    aml,
               phd_profileheaderdetails     phd
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and agrd.tolling_stock_type in
               ('Free Metal IP Stock', 'Delta FM IP Stock')
           and agmr.gmr_latest_action_action_id = 'CREATE_FREE_MATERIAL'
           and agmr.is_deleted = 'N'
           and agmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no
           and agmr.action_no = agrd.action_no
           and agrd_fm.tolling_stock_type = 'Free Material Stock'
           and agrd_fm.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agrd_fm.action_no = agmr.action_no
           and agrd_fm.is_deleted = 'N'
           and agrd_fm.status = 'Active'
           and ypd.internal_gmr_ref_no = agrd.internal_gmr_ref_no
           and ypd.action_no = agrd.action_no
           and ypd.element_id = agrd.element_id
           and ypd.is_active = 'Y'
           and agrd.is_deleted = 'N'
           and agrd.status = 'Active'
           and wrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and pci.internal_contract_item_ref_no =
               agrd.internal_contract_item_ref_no
           and shm.profile_id = agrd.warehouse_profile_id
           and shm.shed_id = agrd.shed_id
           and prdm.product_id = agrd.product_id
           and qat.quality_id = agrd.quality_id
           and aml.attribute_id = agrd.element_id
           and phd.profileid = wrd.smelter_cp_id
           and axs.internal_action_ref_no = ypd.internal_action_ref_no
           and axs.status = 'Active'
           and axm.action_id = axs.action_id
           and agrd_cloned.internal_grd_ref_no =
               agrd_fm.parent_internal_grd_ref_no
           and agrd_fm.internal_grd_ref_no = agrd.parent_internal_grd_ref_no
           and agrd_cloned.is_deleted = 'N'
           and agrd_cloned.status = 'Active'
           and pdm_consc.product_id = agrd_cloned.product_id
        
        /* union all
                                        
                  select sbs.corporate_id,
                  sbs.sbs_id internal_grd_ref_no,
                  '' stock_ref_no,
                  '' internal_gmr_ref_no,
                  '' gmr_ref_no,
                  '' action_id,
                  '' action_name,
                  '' internal_action_ref_no,
                  sbs.activity_date,
                  '' action_ref_no,
                  '' internal_contract_item_ref_no,
                  '' contract_item_ref_no,
                  '' pcdi_id,
                  '' delivery_item_ref_no,
                  '' internal_contract_ref_no,
                  '' contract_ref_no,
                  sbs.smelter_cp_id smelter_cp_id,
                  phd.companyname smelter_cp_name,
                  sbs.product_id,
                  pdm.product_desc product_name,
                  sbs.quality_id,
                  qat.quality_name,
                  sbs.element_id,
                  aml.attribute_name element_name,
                  sbs.warehouse_profile_id,
                  shm.companyname as warehouse,
                  sbs.shed_id,
                  shm.shed_name,
                  nvl(sbs.qty, 0) as stock_qty,
                  pkg_general.f_get_quantity_unit(sbs.qty_unit_id) as qty_unit,
                  sbs.qty_unit_id as qty_unit_id,
                  'Returnable' payable_returnable_type,
                  'Base Stock' tolling_stock_type,
                  '' assay_content_qty,
                  '' is_pass_through,
                  '' element_by_product,
                  '' input_stock_ref_no
                  from sbs_smelter_base_stock    sbs,
                  pdm_productmaster         pdm,
                  qat_quality_attributes    qat,
                  aml_attribute_master_list aml,
                  phd_profileheaderdetails  phd,
                  v_shm_shed_master         shm
                  where pdm.product_id = sbs.product_id
                  and qat.quality_id = sbs.quality_id
                  and phd.profileid = sbs.smelter_cp_id
                  and aml.attribute_id(+) = sbs.element_id
                  and sbs.is_active = 'Y'
                  and shm.profile_id = sbs.warehouse_profile_id
                  and shm.shed_id = sbs.shed_id*/
        ) ips_temp;
		
create or replace view v_bi_assay_comparision as 
select t.corporate_id,
       t.corporate_name,
       t.business_line_name,
       t.profit_center_id,
       t.profit_center_name,
       t.profit_center_short_name,
       t.strategy_id,
       t.contract_type,
       t.producttype,
       t.product_desc,
       t.quality_name,
       t.contract_ref_no,
       t.delivery_ref_no,
       t.internal_contract_item_ref_no,
       t.cpname,
       t.trader,
       t.executiontype,
       t.gmr_ref_no,
       t.internal_grd_ref_no,
       t.gmr_latest_action_action_id,
       t.eff_date,
       t.internal_stock_ref_no,
       t.is_final_weight,
       t.sublot_ref_no,
       t.assay_winner,
       t.ash_id,
       t.assay_type,
       t.assay_ref_no,
       t.umpirename,
       t.wet_qty,
       t.dry_qty,
       t.product_base_uom,
       t.element_id,
       t.element_name,
       t.assayvalue,
       t.assayratio,
       t.assay_content,
       t.assayvalue weighted_avg_sublot,
       (sum(t.assay_content * t.assayvalue)
        over(partition by t.internal_grd_ref_no,
             t.element_id order by t.internal_grd_ref_no,
             t.element_id) / sum(decode(t.assay_content, null, 1, 0, 1))
        over(partition by t.internal_grd_ref_no,
             t.element_id order by t.internal_grd_ref_no,
             t.element_id)) weighted_avg_stock,
       (sum(t.assay_content * t.assayvalue)
        over(partition by t.gmr_ref_no, t.element_id order by t.gmr_ref_no) /
        sum(decode(t.assay_content, null, 1, 0, 1))
        over(partition by t.gmr_ref_no, t.element_id order by t.gmr_ref_no)) weighted_avg_gmr
  from ( --- purchase
        select gmr.corporate_id,
                akc.corporate_name,
                blm.business_line_name,
                grd.profit_center_id,
                cpc.profit_center_name,
                cpc.profit_center_short_name,
                grd.strategy_id,
                (case
                  when pcm.purchase_sales = 'P' and
                       pcm.is_tolling_contract = 'N' then
                   'Purchase Contract'
                  when pcm.purchase_sales = 'S' and
                       pcm.is_tolling_contract = 'N' then
                   'Sales Contract'
                  when pcmte.tolling_service_type = 'P' and
                       pcm.is_tolling_contract = 'Y' and
                       pcmte.is_pass_through = 'Y' then
                   'Internal Buy Tolling Service Contract'
                  when pcmte.tolling_service_type = 'P' and
                       pcm.is_tolling_contract = 'Y' and
                       pcmte.is_pass_through = 'N' then
                   'Buy Tolling Service Contract'
                  when pcmte.tolling_service_type = 'S' and
                       pcm.is_tolling_contract = 'Y' then
                   'Sell Tolling Service Contract'
                  when pcm.purchase_sales = 'P' and
                       pcm.is_tolling_contract = 'Y' and
                       pcmte.is_pass_through is null then
                   'Tolling Service Contract'
                end) contract_type,
                pdm.product_type_id producttype,
                pdm.product_desc,
                qat.quality_name,
                pcm.contract_ref_no,
                pci.del_distribution_item_no delivery_ref_no,
                grd.internal_contract_item_ref_no,
                phd.companyname cpname,
                aku.login_name trader,
                pcm.partnership_type executiontype,
                gmr.gmr_ref_no,
                grd.internal_grd_ref_no internal_grd_ref_no,
                gmr.gmr_latest_action_action_id,
                gmr.eff_date,
                grd.internal_stock_ref_no,
                gmr.is_final_weight,
                asm.sub_lot_no sublot_ref_no,
                pqca.assay_winner,
                ash.ash_id,
                (case
                  when ash.assay_type = 'Shipment Assay' then
                   'Contractual Assay'
                  else
                   ash.assay_type
                end) assay_type,
                ash.assay_ref_no,
                (case
                  when ash.assay_type in ('Umpire Assay', 'Final Assay') then
                   phd_umpire.companyname
                  else
                   null
                end) umpirename,
                asm.net_weight wet_qty,
                asm.dry_weight dry_qty,
                asm.net_weight_unit,
                qum.qty_unit product_base_uom,
                pqca.element_id,
                aml.attribute_name element_name,
                pqca.typical assayvalue,
                rm.ratio_name assayratio,
                pkg_report_general.fn_get_elmt_assay_content_qty(pqca.element_id,
                                                                 ash.ash_id,
                                                                 asm.dry_weight,
                                                                 asm.net_weight_unit) assay_content
          from gmr_goods_movement_record   gmr,
                grd_goods_record_detail     grd,
                pci_physical_contract_item  pci,
                pcm_physical_contract_main  pcm,
                pcmte_pcm_tolling_ext       pcmte,
                pcdi_pc_delivery_item       pcdi,
                pcpq_pc_product_quality     pcpq,
                pdm_productmaster           pdm,
                qat_quality_attributes      qat,
                qum_quantity_unit_master    qum,
                ash_assay_header            ash,
                asm_assay_sublot_mapping    asm,
                pqca_pq_chemical_attributes pqca,
                rm_ratio_master             rm,
                aml_attribute_master_list   aml,
                cpc_corporate_profit_center cpc,
                blm_business_line_master    blm,
                ak_corporate                akc,
                ak_corporate_user           aku,
                phd_profileheaderdetails    phd,
                phd_profileheaderdetails    phd_umpire
         where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and grd.status = 'Active'
           and gmr.corporate_id = akc.corporate_id
           and grd.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
           and pcm.cp_id = phd.profileid
           and pcm.trader_id = aku.user_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcdi.pcdi_id = pci.pcdi_id
           and pci.pcpq_id = pcpq.pcpq_id
           and grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           and grd.product_id = pdm.product_id
           and grd.quality_id = qat.quality_id
           and asm.net_weight_unit = qum.qty_unit_id
           and grd.internal_grd_ref_no = ash.internal_grd_ref_no
           and gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
           and ash.ash_id = asm.ash_id
           and asm.asm_id = pqca.asm_id
           and pqca.unit_of_measure = ratio_id
           and pqca.element_id = aml.attribute_id
           and ash.assayer = phd_umpire.profileid(+)
           and pci.is_active = 'Y'
           and pcm.is_active = 'Y'
           and pcdi.is_active = 'Y'
           and ash.is_active = 'Y'
           and asm.is_active = 'Y'
           and pqca.is_active = 'Y'
           and rm.is_active = 'Y'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and qum.is_active = 'Y'
           and aml.is_active = 'Y'
           and ash.assay_type not in
               ('Pricing Assay', 'Position Assay', 'Self Assay',
                'Umpire Assay', 'CounterParty Assay',
                'Weighted Avg Position Assay', 'Weighted Avg Pricing Assay',
                'Invoicing Assay', 'Weighted Avg Invoice Assay')
        union all ----sales 
        select gmr.corporate_id,
               akc.corporate_name,
               blm.business_line_name,
               dgrd.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               dgrd.strategy_id,
               (case
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'N' then
                  'Purchase Contract'
                 when pcm.purchase_sales = 'S' and
                      pcm.is_tolling_contract = 'N' then
                  'Sales Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'Y' then
                  'Internal Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'N' then
                  'Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'S' and
                      pcm.is_tolling_contract = 'Y' then
                  'Sell Tolling Service Contract'
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through is null then
                  'Tolling Service Contract'
               end) contract_type,
               pdm.product_type_id producttype,
               pdm.product_desc,
               qat.quality_name,
               pcm.contract_ref_no,
               pci.del_distribution_item_no delivery_ref_no,
               dgrd.internal_contract_item_ref_no,
               phd.companyname cpname,
               aku.login_name trader,
               pcm.partnership_type executiontype,
               gmr.gmr_ref_no,
               dgrd.internal_dgrd_ref_no internal_grd_ref_no,
               gmr.gmr_latest_action_action_id,
               gmr.eff_date,
               dgrd.internal_stock_ref_no,
               gmr.is_final_weight,
               asm.sub_lot_no sublot_ref_no,
               pqca.assay_winner,
               ash.ash_id,
               (case
                 when ash.assay_type = 'Shipment Assay' then
                  'Contractual Assay'
                 else
                  ash.assay_type
               end) assay_type,
               ash.assay_ref_no,
               (case
                 when ash.assay_type in ('Umpire Assay', 'Final Assay') then
                  phd_umpire.companyname
                 else
                  null
               end) umpirename,
               asm.net_weight wet_qty,
               asm.dry_weight dry_qty,
               asm.net_weight_unit,
               qum.qty_unit product_base_uom,
               pqca.element_id,
               aml.attribute_name element_name,
               pqca.typical assayvalue,
               rm.ratio_name assayratio,
               pkg_report_general.fn_get_elmt_assay_content_qty(pqca.element_id,
                                                                ash.ash_id,
                                                                asm.dry_weight,
                                                                asm.net_weight_unit) assay_content
          from gmr_goods_movement_record   gmr,
               dgrd_delivered_grd          dgrd,
               pci_physical_contract_item  pci,
               pcm_physical_contract_main  pcm,
               pcmte_pcm_tolling_ext       pcmte,
               pcdi_pc_delivery_item       pcdi,
               pcpq_pc_product_quality     pcpq,
               pdm_productmaster           pdm,
               qat_quality_attributes      qat,
               qum_quantity_unit_master    qum,
               ash_assay_header            ash,
               asm_assay_sublot_mapping    asm,
               pqca_pq_chemical_attributes pqca,
               rm_ratio_master             rm,
               aml_attribute_master_list   aml,
               cpc_corporate_profit_center cpc,
               blm_business_line_master    blm,
               ak_corporate                akc,
               ak_corporate_user           aku,
               phd_profileheaderdetails    phd,
               phd_profileheaderdetails    phd_umpire
         where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and dgrd.status = 'Active'
           and gmr.corporate_id = akc.corporate_id
           and dgrd.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
           and pcm.cp_id = phd.profileid
           and pcm.trader_id = aku.user_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcdi.pcdi_id = pci.pcdi_id
           and pci.pcpq_id = pcpq.pcpq_id
           and dgrd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           and dgrd.product_id = pdm.product_id
           and dgrd.quality_id = qat.quality_id
           and asm.net_weight_unit = qum.qty_unit_id
           and dgrd.internal_dgrd_ref_no = ash.internal_grd_ref_no
           and gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
           and ash.ash_id = asm.ash_id
           and asm.asm_id = pqca.asm_id
           and pqca.unit_of_measure = ratio_id
           and pqca.element_id = aml.attribute_id
           and ash.assayer = phd_umpire.profileid(+)
           and pci.is_active = 'Y'
           and pcm.is_active = 'Y'
           and pcdi.is_active = 'Y'
           and ash.is_active = 'Y'
           and asm.is_active = 'Y'
           and pqca.is_active = 'Y'
           and rm.is_active = 'Y'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and qum.is_active = 'Y'
           and aml.is_active = 'Y'
           and ash.assay_type not in
               ('Pricing Assay', 'Position Assay', 'Self Assay',
                'Umpire Assay', 'CounterParty Assay',
                'Weighted Avg Position Assay', 'Weighted Avg Pricing Assay',
                'Invoicing Assay', 'Weighted Avg Invoice Assay')
        union all --- multiple self,CP,Umpire assays for purchase
        select gmr.corporate_id,
               akc.corporate_name,
               blm.business_line_name,
               grd.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               grd.strategy_id,
               (case
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'N' then
                  'Purchase Contract'
                 when pcm.purchase_sales = 'S' and
                      pcm.is_tolling_contract = 'N' then
                  'Sales Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'Y' then
                  'Internal Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'N' then
                  'Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'S' and
                      pcm.is_tolling_contract = 'Y' then
                  'Sell Tolling Service Contract'
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through is null then
                  'Tolling Service Contract'
               end) contract_type,
               pdm.product_type_id producttype,
               pdm.product_desc,
               qat.quality_name,
               pcm.contract_ref_no,
               pci.del_distribution_item_no delivery_ref_no,
               grd.internal_contract_item_ref_no,
               phd.companyname cpname,
               aku.login_name trader,
               pcm.partnership_type executiontype,
               gmr.gmr_ref_no,
               grd.internal_grd_ref_no internal_grd_ref_no,
               gmr.gmr_latest_action_action_id,
               gmr.eff_date,
               grd.internal_stock_ref_no,
               gmr.is_final_weight,
               asm.sub_lot_no sublot_ref_no,
               pqca.assay_winner,
               ash.ash_id,
               (case
                 when ash.assay_type = 'Shipment Assay' then
                  'Contractual Assay'
                 else
                  ash.assay_type
               end) assay_type,
               ash.assay_ref_no,
               (case
                 when ash.assay_type in ('Umpire Assay', 'Final Assay') then
                  phd_umpire.companyname
                 else
                  null
               end) umpirename,
               asm.net_weight wet_qty,
               asm.dry_weight dry_qty,
               asm.net_weight_unit,
               qum.qty_unit product_base_uom,
               pqca.element_id,
               aml.attribute_name element_name,
               pqca.typical assayvalue,
               rm.ratio_name assayratio,
               pkg_report_general.fn_get_elmt_assay_content_qty(pqca.element_id,
                                                                ash.ash_id,
                                                                asm.dry_weight,
                                                                asm.net_weight_unit) assay_content
          from gmr_goods_movement_record   gmr,
               grd_goods_record_detail     grd,
               pci_physical_contract_item  pci,
               pcm_physical_contract_main  pcm,
               pcmte_pcm_tolling_ext       pcmte,
               pcdi_pc_delivery_item       pcdi,
               pcpq_pc_product_quality     pcpq,
               pdm_productmaster           pdm,
               qat_quality_attributes      qat,
               qum_quantity_unit_master    qum,
               ash_assay_header            ash,
               asm_assay_sublot_mapping    asm,
               pqca_pq_chemical_attributes pqca,
               rm_ratio_master             rm,
               aml_attribute_master_list   aml,
               cpc_corporate_profit_center cpc,
               blm_business_line_master    blm,
               ak_corporate                akc,
               ak_corporate_user           aku,
               phd_profileheaderdetails    phd,
               phd_profileheaderdetails    phd_umpire
         where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and grd.status = 'Active'
           and gmr.corporate_id = akc.corporate_id
           and grd.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
           and pcm.cp_id = phd.profileid
           and pcm.trader_id = aku.user_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcdi.pcdi_id = pci.pcdi_id
           and pci.pcpq_id = pcpq.pcpq_id
           and grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           and grd.product_id = pdm.product_id
           and grd.quality_id = qat.quality_id
           and asm.net_weight_unit = qum.qty_unit_id
           and grd.internal_grd_ref_no = ash.internal_grd_ref_no
           and gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
           and ash.ash_id = asm.ash_id
           and asm.asm_id = pqca.asm_id
           and pqca.unit_of_measure = ratio_id
           and pqca.element_id = aml.attribute_id
           and ash.assayer = phd_umpire.profileid(+)
           and pci.is_active = 'Y'
           and pcm.is_active = 'Y'
           and pcdi.is_active = 'Y'
           and ash.is_active = 'Y'
           and asm.is_active = 'Y'
           and pqca.is_active = 'Y'
           and rm.is_active = 'Y'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and qum.is_active = 'Y'
           and aml.is_active = 'Y'
           and ash.use_for_finalization = 'Y'
           and ash.assay_type in
               ('Self Assay', 'Umpire Assay', 'CounterParty Assay')
        union all  --- multiple self,CP,Umpire assays for sales
        select gmr.corporate_id,
               akc.corporate_name,
               blm.business_line_name,
               dgrd.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               dgrd.strategy_id,
               (case
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'N' then
                  'Purchase Contract'
                 when pcm.purchase_sales = 'S' and
                      pcm.is_tolling_contract = 'N' then
                  'Sales Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'Y' then
                  'Internal Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through = 'N' then
                  'Buy Tolling Service Contract'
                 when pcmte.tolling_service_type = 'S' and
                      pcm.is_tolling_contract = 'Y' then
                  'Sell Tolling Service Contract'
                 when pcm.purchase_sales = 'P' and
                      pcm.is_tolling_contract = 'Y' and
                      pcmte.is_pass_through is null then
                  'Tolling Service Contract'
               end) contract_type,
               pdm.product_type_id producttype,
               pdm.product_desc,
               qat.quality_name,
               pcm.contract_ref_no,
               pci.del_distribution_item_no delivery_ref_no,
               dgrd.internal_contract_item_ref_no,
               phd.companyname cpname,
               aku.login_name trader,
               pcm.partnership_type executiontype,
               gmr.gmr_ref_no,
               dgrd.internal_dgrd_ref_no internal_grd_ref_no,
               gmr.gmr_latest_action_action_id,
               gmr.eff_date,
               dgrd.internal_stock_ref_no,
               gmr.is_final_weight,
               asm.sub_lot_no sublot_ref_no,
               pqca.assay_winner,
               ash.ash_id,
               (case
                 when ash.assay_type = 'Shipment Assay' then
                  'Contractual Assay'
                 else
                  ash.assay_type
               end) assay_type,
               ash.assay_ref_no,
               (case
                 when ash.assay_type in ('Umpire Assay', 'Final Assay') then
                  phd_umpire.companyname
                 else
                  null
               end) umpirename,
               asm.net_weight wet_qty,
               asm.dry_weight dry_qty,
               asm.net_weight_unit,
               qum.qty_unit product_base_uom,
               pqca.element_id,
               aml.attribute_name element_name,
               pqca.typical assayvalue,
               rm.ratio_name assayratio,
               pkg_report_general.fn_get_elmt_assay_content_qty(pqca.element_id,
                                                                ash.ash_id,
                                                                asm.dry_weight,
                                                                asm.net_weight_unit) assay_content
          from gmr_goods_movement_record   gmr,
               dgrd_delivered_grd          dgrd,
               pci_physical_contract_item  pci,
               pcm_physical_contract_main  pcm,
               pcmte_pcm_tolling_ext       pcmte,
               pcdi_pc_delivery_item       pcdi,
               pcpq_pc_product_quality     pcpq,
               pdm_productmaster           pdm,
               qat_quality_attributes      qat,
               qum_quantity_unit_master    qum,
               ash_assay_header            ash,
               asm_assay_sublot_mapping    asm,
               pqca_pq_chemical_attributes pqca,
               rm_ratio_master             rm,
               aml_attribute_master_list   aml,
               cpc_corporate_profit_center cpc,
               blm_business_line_master    blm,
               ak_corporate                akc,
               ak_corporate_user           aku,
               phd_profileheaderdetails    phd,
               phd_profileheaderdetails    phd_umpire
         where gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and dgrd.status = 'Active'
           and gmr.corporate_id = akc.corporate_id
           and dgrd.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
           and pcm.cp_id = phd.profileid
           and pcm.trader_id = aku.user_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcdi.pcdi_id = pci.pcdi_id
           and pci.pcpq_id = pcpq.pcpq_id
           and dgrd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           and dgrd.product_id = pdm.product_id
           and dgrd.quality_id = qat.quality_id
           and asm.net_weight_unit = qum.qty_unit_id
           and dgrd.internal_dgrd_ref_no = ash.internal_grd_ref_no
           and gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
           and ash.ash_id = asm.ash_id
           and asm.asm_id = pqca.asm_id
           and pqca.unit_of_measure = ratio_id
           and pqca.element_id = aml.attribute_id
           and ash.assayer = phd_umpire.profileid(+)
           and pci.is_active = 'Y'
           and pcm.is_active = 'Y'
           and pcdi.is_active = 'Y'
           and ash.is_active = 'Y'
           and asm.is_active = 'Y'
           and pqca.is_active = 'Y'
           and rm.is_active = 'Y'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and qum.is_active = 'Y'
           and aml.is_active = 'Y'
           and ash.use_for_finalization = 'Y'
           and ash.assay_type in
               ('Self Assay', 'Umpire Assay', 'CounterParty Assay')) t;
DROP MATERIALIZED VIEW MV_BI_ASSAY_COMPARISION;
CREATE MATERIALIZED VIEW MV_BI_ASSAY_COMPARISION
REFRESH FORCE ON DEMAND
START WITH TO_DATE('25-06-2012 17:14:53', 'DD-MM-YYYY HH24:MI:SS') NEXT SYSDATE+20/1440  
AS
SELECT * FROM V_BI_ASSAY_COMPARISION;

ALTER TABLE ash_assay_header ADD(
    CONSTRAINT fk_ash_quality_id
     FOREIGN KEY (quality_id)
     REFERENCES qat_quality_attributes (quality_id),

    CONSTRAINT fk_ash_net_weight_unit
     FOREIGN KEY (net_weight_unit)
     REFERENCES qum_quantity_unit_master (qty_unit_id),

    CONSTRAINT fk_ash_int_action_ref_no
     FOREIGN KEY (internal_action_ref_no)
     REFERENCES axs_action_summary (internal_action_ref_no)
);
 alter table FMPFD_PRICE_FIXATION_DETAILS add HEDGE_CORRECTION_DATE DATE;
 alter table FMPFH_PRICE_FIXATION_HEADER drop column HEDGE_CORRECTION_DATE;
 
 CREATE INDEX FK_GMR_CORPORATE_ID ON GMR_GOODS_MOVEMENT_RECORD (CORPORATE_ID);
CREATE INDEX FK_GMR_PLOFDEL_STATE_ID ON GMR_GOODS_MOVEMENT_RECORD (PLACE_OF_DELIVERY_STATE_ID);
CREATE INDEX FK_GMR_PLOFDEL_COUNTRY_ID ON GMR_GOODS_MOVEMENT_RECORD (PLACE_OF_DELIVERY_COUNTRY_ID);
CREATE INDEX FK_GMR_DIS_CITY_ID ON GMR_GOODS_MOVEMENT_RECORD (DISCHARGE_CITY_ID);
CREATE INDEX FK_GMR_DIS_STATE_ID ON GMR_GOODS_MOVEMENT_RECORD (DISCHARGE_STATE_ID);
CREATE INDEX FK_GMR_LOAD_CITY_ID ON GMR_GOODS_MOVEMENT_RECORD (LOADING_CITY_ID);
CREATE INDEX FK_GMR_LOAD_STATE_ID ON GMR_GOODS_MOVEMENT_RECORD (LOADING_STATE_ID);
CREATE INDEX FK_GMR_INT_ACTION_REF_NO ON GMR_GOODS_MOVEMENT_RECORD (INTERNAL_ACTION_REF_NO);
CREATE INDEX FK_GMR_SHIP_LINE_PROF_ID ON GMR_GOODS_MOVEMENT_RECORD (SHIPPING_LINE_PROFILE_ID);
CREATE INDEX FK_GMR_WARE_PROF_ID ON GMR_GOODS_MOVEMENT_RECORD (WAREHOUSE_PROFILE_ID);
CREATE INDEX FK_GMR_QTY_UNIT_ID ON GMR_GOODS_MOVEMENT_RECORD (QTY_UNIT_ID);
CREATE INDEX FK_GMR_FIRST_INT_ACT_REF_NO ON GMR_GOODS_MOVEMENT_RECORD (GMR_FIRST_INT_ACTION_REF_NO);
CREATE INDEX FK_GMR_PLOFDEL_CITY_ID ON GMR_GOODS_MOVEMENT_RECORD (PLACE_OF_DELIVERY_CITY_ID);

CREATE INDEX FK_GMR_CREATED_BY ON GMR_GOODS_MOVEMENT_RECORD (CREATED_BY);
CREATE INDEX FK_GMR_LOAD_CNTRY_ID ON GMR_GOODS_MOVEMENT_RECORD (LOADING_COUNTRY_ID);
CREATE INDEX FK_GMR_DIS_CNTRY_ID ON GMR_GOODS_MOVEMENT_RECORD (DISCHARGE_COUNTRY_ID);
CREATE INDEX FK_GRD_QTY_UNIT_ID ON GRD_GOODS_RECORD_DETAIL (QTY_UNIT_ID);
CREATE INDEX FK_GRD_INT_ACTION_REF_NO ON GRD_GOODS_RECORD_DETAIL (INTERNAL_ACTION_REF_NO);
CREATE INDEX FK_GRD_WAREHOUSE_PROF_ID ON GRD_GOODS_RECORD_DETAIL (WAREHOUSE_PROFILE_ID);
CREATE INDEX FK_GRD_PRODUCT_ID ON GRD_GOODS_RECORD_DETAIL (PRODUCT_ID);
CREATE INDEX FK_GRD_QUALITY_ID ON GRD_GOODS_RECORD_DETAIL (QUALITY_ID);
CREATE INDEX FK_ASH_NET_WEIGHT_UNIT ON ASH_ASSAY_HEADER (NET_WEIGHT_UNIT);
CREATE INDEX FK_ASH_INT_GMR_REF_NO ON ASH_ASSAY_HEADER (INTERNAL_GMR_REF_NO);
CREATE INDEX FK_ASH_INT_GRD_REF_NO ON ASH_ASSAY_HEADER (INTERNAL_GRD_REF_NO);
CREATE INDEX FK_ASH_QUALITY_ID ON ASH_ASSAY_HEADER (QUALITY_ID);
CREATE INDEX FK_ASH_INT_ACTION_REF_NO ON ASH_ASSAY_HEADER (INTERNAL_ACTION_REF_NO);

CREATE TABLE IAD_INVOICE_AMOUNT_DETAILS
(
  IAD_ID             VARCHAR2(15 CHAR),
  UTIL_REF_NO        VARCHAR2(15 CHAR),
  INVOICE_REF_NO     VARCHAR2(15 CHAR),
  ELEMENT_NAME       VARCHAR2(15 CHAR),
  TC_AMOUNT          NUMBER(25,10),
  RC_AMOUNT          NUMBER(25,10),
  PENALTY_AMOUNT     NUMBER(25,10),
  FREE_METAL_AMOUNT  NUMBER(25,10)
);


ALTER TABLE IAD_INVOICE_AMOUNT_DETAILS ADD (
  CONSTRAINT IAD_INVOICE_AMOUNT_DETAILS_PK
 PRIMARY KEY
 (IAD_ID));


CREATE SEQUENCE SEQ_IAD
START WITH 0
INCREMENT BY 1
MINVALUE 0
MAXVALUE 100000000000000000000000000
NOCACHE 
NOCYCLE 
NOORDER ;

alter table IUD_INVOICE_UTILITY_DETAIL MODIFY FREE_METAL_QTY_DISPLAY VARCHAR2(100);

 ALTER TABLE FMPFAM_PRICE_ACTION_MAPPING ADD (
  CONSTRAINT FMPFAM_FMPFD_ID 
 FOREIGN KEY (FMPFD_ID) 
 REFERENCES FMPFD_PRICE_FIXATION_DETAILS (FMPFD_ID));

