alter table ECS_ELEMENT_COST_STORE add COST_REF_NO VARCHAR2(15 );
update POFH_PRICE_OPT_FIXATION_HEADER pofh
set POFH.QP_START_QTY = POFH.QTY_TO_BE_FIXED
,POFH.PER_DAY_PRICING_QTY = POFH.QTY_TO_BE_FIXED/ POFH.NO_OF_PROMPT_DAYS
where POFH.POFH_ID IN (select pofh_in.pofh_id
                       from POFH_PRICE_OPT_FIXATION_HEADER pofh_in
                       ,POCD_PRICE_OPTION_CALLOFF_DTLS pocd,
                       POCH_PRICE_OPT_CALL_OFF_HEADER poch
                        where POCH.POCH_ID = POCD.POCH_ID
                        and POCD.POCD_ID = POFH_in.POCD_ID
                        and POCH.IS_FREE_METAL_PRICING='Y'
                        and POFH_IN.QP_START_QTY=0
                        );

COMMIT;
declare
fetchqry1 clob := 'INSERT INTO IS_D(
INVOICE_REF_NO,
INVOICE_TYPE_NAME,
INVOICE_CREATION_DATE,
INVOICE_DRY_QUANTITY,
INVOICE_WET_QUANTITY,
MOISTURE,
INVOICED_QTY_UNIT,
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
MATERIAL_COST,
ADDDITIONAL_CHARGES,
TAXES,
DUE_DATE,
SUPPLIRE_INVOICE_NO,
CONTRACT_DATE,
CONTRACT_REF_NO,
STOCK_QUANTITY,
STOCK_REF_NO,
INVOICE_AMOUNT_UNIT,
GMR_REF_NO,
GMR_QUALITY,
CONTRACT_QUANTITY,
CONTRACT_QTY_UNIT,
CONTRACT_TOLERANCE,
QUALITY,
PRODUCT,
CP_CONTRACT_REF_NO,
PAYMENT_TERM,
GMR_FINALIZE_QTY,
CP_NAME,
CP_ADDRESS,
CP_COUNTRY,
CP_CITY,
CP_STATE,
CP_ZIP,
CONTRACT_TYPE,
ORIGIN,
INCO_TERM_LOCATION,
NOTIFY_PARTY,
SALES_PURCHASE,
INVOICE_STATUS,
INTERNAL_DOC_REF_NO
)
with test as (select invs.INTERNAL_INVOICE_REF_NO, sum(ASM.NET_WEIGHT) as wet,
sum(ASM.DRY_WEIGHT) as dry
from 
IS_INVOICE_SUMMARY invs,
ASH_ASSAY_HEADER ash,
ASM_ASSAY_SUBLOT_MAPPING asm,
IAM_INVOICE_ASSAY_MAPPING iam
where
INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
and IAM.ASH_ID = ASH.ASH_ID
and ASH.ASH_ID = ASM.ASH_ID
group by invs.INTERNAL_INVOICE_REF_NO
)
select
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME as INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE as INVOICE_CREATION_DATE,
t.DRY as INVOICE_DRY_QUANTITY,
t.WET as INVOICE_WET_QUANTITY,
ROUND((((t.WET - t.DRY)/t.WET)*100),2) as MOISTURE,
QUM_GMR.QTY_UNIT as INVOICED_QTY_UNIT,
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ as MATERIAL_COST,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as ADDDITIONAL_CHARGES,
INVS.TOTAL_TAX_AMOUNT as TAXES,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
INVS.CP_REF_NO as SUPPLIER_INVOICE_NO,
PCM.ISSUE_DATE as CONTRACT_DATE,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
sum(II.INVOICABLE_QTY) as STOCK_QUANTITY,
stragg(DISTINCT II.STOCK_REF_NO) as STOCK_REF_NO,
NVL (cm_pct.cur_code, cm.cur_code) AS invoice_amount_unit,
stragg(DISTINCT GMR.GMR_REF_NO) as GMR_REF_NO,
sum(GMR.QTY) as GMR_QUALITY,
PCPD.QTY_MAX_VAL as CONTRACT_QUANTITY,
QUM.QTY_UNIT as CONTRACT_QTY_UNIT,
PCPD.MAX_TOLERANCE as CONTRACT_TOLERANCE,
QAT.QUALITY_NAME as QUALITY,
PDM.PRODUCT_DESC as PRODUCT,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM as PAYMENT_TERM,
GMR.FINAL_WEIGHT as GMR_FINALIZE_QTY,
PHD.COMPANYNAME as CP_NAME,
PAD.ADDRESS as CP_ADDRESS,
CYM.COUNTRY_NAME as CP_COUNTRY,
CIM.CITY_NAME as CP_CITY,
SM.STATE_NAME as CP_STATE,
PAD.ZIP as CP_ZIP,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME as ORIGIN,
PCI.TERMS as INCO_TERM_LOCATION,
nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME) as NOTIFY_PARTY, 
PCI.CONTRACT_TYPE as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
?
from 
IS_INVOICE_SUMMARY invs,
IID_INVOICABLE_ITEM_DETAILS iid,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
II_INVOICABLE_ITEM ii,
CM_CURRENCY_MASTER cm,
GMR_GOODS_MOVEMENT_RECORD gmr,
PCPD_PC_PRODUCT_DEFINITION pcpd,
QUM_QUANTITY_UNIT_MASTER qum,
PCPQ_PC_PRODUCT_QUALITY pcpq,
QAT_QUALITY_ATTRIBUTES qat,
PDM_PRODUCTMASTER pdm,
PHD_PROFILEHEADERDETAILS phd,
PYM_PAYMENT_TERMS_MASTER pym,
PAD_PROFILE_ADDRESSES pad,
CYM_COUNTRYMASTER cym,
CIM_CITYMASTER cim,
SM_STATE_MASTER sm,
BPAT_BP_ADDRESS_TYPE bpat,
CYM_COUNTRYMASTER cymloading,
SAD_SHIPMENT_ADVICE sad,
SD_SHIPMENT_DETAIL sd,
PHD_PROFILEHEADERDETAILS phd1,
PHD_PROFILEHEADERDETAILS phd2,
QUM_QUANTITY_UNIT_MASTER qum_gmr,
cm_currency_master cm_pct,
test t
where
INVS.INTERNAL_INVOICE_REF_NO = IID.INTERNAL_INVOICE_REF_NO(+)
and IID.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO(+)
and IID.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO(+)
and IID.INVOICABLE_ITEM_ID = II.INVOICABLE_ITEM_ID(+)
and IID.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INVOICE_CURRENCY_ID = CM.CUR_ID(+)
and II.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INTERNAL_CONTRACT_REF_NO = PCPD.INTERNAL_CONTRACT_REF_NO(+)
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
and PCPD.PCPD_ID = PCPQ.PCPD_ID(+)
and PCI.QUALITY_ID = QAT.QUALITY_ID(+)
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
and INVS.CP_ID = PHD.PROFILEID(+)
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID(+)
and PHD.PROFILEID = PAD.PROFILE_ID(+)
and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.NOTIFY_PARTY_ID = PHD1.PROFILEID(+)
and SD.NOTIFY_PARTY_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and invs.invoice_cur_id = cm_pct.cur_id(+)
and PAD.ADDRESS_TYPE(+) = ''Billing''
and PAD.IS_DELETED(+) = ''N''
and PCPD.INPUT_OUTPUT in (''Input'')
and t.INTERNAL_INVOICE_REF_NO = INVS.INTERNAL_INVOICE_REF_NO
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
INVS.INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE,
INVS.INVOICED_QTY,
INVS.INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
INVS.TOTAL_TAX_AMOUNT,
INVS.PAYMENT_DUE_DATE,
INVS.CP_REF_NO,
PCM.ISSUE_DATE,
PCM.CONTRACT_REF_NO,
CM.CUR_CODE,
PCPD.QTY_MAX_VAL,
QUM.QTY_UNIT,
PCPD.MAX_TOLERANCE,
QAT.QUALITY_NAME,
PDM.PRODUCT_DESC,
PCM.CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM,
GMR.FINAL_WEIGHT,
PHD.COMPANYNAME,
PAD.ADDRESS,
CYM.COUNTRY_NAME,
CIM.CITY_NAME,
SM.STATE_NAME,
PAD.ZIP,
PCM.CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME,
PCI.TERMS,
PHD1.COMPANYNAME,
PHD2.COMPANYNAME,
QUM_GMR.QTY_UNIT,
PCI.CONTRACT_TYPE,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ,
INVS.INVOICE_STATUS,
cm_pct.cur_code,
t.DRY,
t.WET';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('DGM-PIC','DGM-FIC','DGM-DFIC');
  
end;
declare
fetchqry1 clob := 'INSERT INTO IS_D(
INVOICE_REF_NO,
INVOICE_TYPE_NAME,
INVOICE_CREATION_DATE,
INVOICE_QUANTITY,
INVOICED_QTY_UNIT,
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
MATERIAL_COST,
ADDDITIONAL_CHARGES,
TAXES,
DUE_DATE,
SUPPLIRE_INVOICE_NO,
CONTRACT_DATE,
CONTRACT_REF_NO,
STOCK_QUANTITY,
STOCK_REF_NO,
INVOICE_AMOUNT_UNIT,
GMR_REF_NO,
GMR_QUALITY,
CONTRACT_QUANTITY,
CONTRACT_QTY_UNIT,
CONTRACT_TOLERANCE,
QUALITY,
PRODUCT,
CP_CONTRACT_REF_NO,
PAYMENT_TERM,
GMR_FINALIZE_QTY,
CP_NAME,
CP_ADDRESS,
CP_COUNTRY,
CP_CITY,
CP_STATE,
CP_ZIP,
CONTRACT_TYPE,
ORIGIN,
INCO_TERM_LOCATION,
NOTIFY_PARTY,
SALES_PURCHASE,
INVOICE_STATUS,
IS_FREE_METAL,
IS_PLEDGE,
INTERNAL_COMMENTS,
INTERNAL_DOC_REF_NO
)
select
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME as INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE as INVOICE_CREATION_DATE,
INVS.INVOICED_QTY as INVOICE_QUANTITY,
QUM_GMR.QTY_UNIT as INVOICED_QTY_UNIT,
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ as MATERIAL_COST,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as ADDDITIONAL_CHARGES,
INVS.TOTAL_TAX_AMOUNT as TAXES,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
INVS.CP_REF_NO as SUPPLIER_INVOICE_NO,
PCM.ISSUE_DATE as CONTRACT_DATE,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
sum(II.INVOICABLE_QTY) as STOCK_QUANTITY,
stragg(distinct II.STOCK_REF_NO) as STOCK_REF_NO,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
stragg(GMR.GMR_REF_NO) as GMR_REF_NO,
sum(GMR.QTY) as GMR_QUALITY,
PCPD.QTY_MAX_VAL as CONTRACT_QUANTITY,
QUM.QTY_UNIT as CONTRACT_QTY_UNIT,
PCPD.MAX_TOLERANCE as CONTRACT_TOLERANCE,
QAT.QUALITY_NAME as QUALITY,
PDM.PRODUCT_DESC as PRODUCT,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM as PAYMENT_TERM,
GMR.FINAL_WEIGHT as GMR_FINALIZE_QTY,
PHD.COMPANYNAME as CP_NAME,
PAD.ADDRESS as CP_ADDRESS,
CYM.COUNTRY_NAME as CP_COUNTRY,
CIM.CITY_NAME as CP_CITY,
SM.STATE_NAME as CP_STATE,
PAD.ZIP as CP_ZIP,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME as ORIGIN,
PCI.TERMS as INCO_TERM_LOCATION,
nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME) as NOTIFY_PARTY, 
PCI.CONTRACT_TYPE as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
INVS.IS_FREE_METAL as IS_FREE_METAL,
INVS.IS_PLEDGE as IS_PLEDGE,
INVS.INTERNAL_COMMENTS as INTERNAL_COMMENTS,
?
from 
IS_INVOICE_SUMMARY invs,
IID_INVOICABLE_ITEM_DETAILS iid,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
II_INVOICABLE_ITEM ii,
CM_CURRENCY_MASTER cm,
GMR_GOODS_MOVEMENT_RECORD gmr,
PCPD_PC_PRODUCT_DEFINITION pcpd,
QUM_QUANTITY_UNIT_MASTER qum,
PCPQ_PC_PRODUCT_QUALITY pcpq,
QAT_QUALITY_ATTRIBUTES qat,
PDM_PRODUCTMASTER pdm,
PHD_PROFILEHEADERDETAILS phd,
PYM_PAYMENT_TERMS_MASTER pym,
PAD_PROFILE_ADDRESSES pad,
CYM_COUNTRYMASTER cym,
CIM_CITYMASTER cim,
SM_STATE_MASTER sm,
BPAT_BP_ADDRESS_TYPE bpat,
CYM_COUNTRYMASTER cymloading,
SAD_SHIPMENT_ADVICE sad,
SD_SHIPMENT_DETAIL sd,
PHD_PROFILEHEADERDETAILS phd1,
PHD_PROFILEHEADERDETAILS phd2,
QUM_QUANTITY_UNIT_MASTER qum_gmr
where
INVS.INTERNAL_INVOICE_REF_NO = IID.INTERNAL_INVOICE_REF_NO
and IID.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO
and IID.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and IID.INVOICABLE_ITEM_ID = II.INVOICABLE_ITEM_ID
and IID.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INVOICE_CURRENCY_ID = CM.CUR_ID
and II.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INTERNAL_CONTRACT_REF_NO = PCPD.INTERNAL_CONTRACT_REF_NO
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID
and PCPD.PCPD_ID = PCPQ.PCPD_ID
and PCI.QUALITY_ID = QAT.QUALITY_ID
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and INVS.CP_ID = PHD.PROFILEID
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID
and PHD.PROFILEID = PAD.PROFILE_ID(+)
and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.NOTIFY_PARTY_ID = PHD1.PROFILEID(+)
and SD.NOTIFY_PARTY_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.IS_DELETED(+) = ''N''
and PAD.ADDRESS_TYPE(+) = ''Billing''
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
INVS.INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE,
INVS.INVOICED_QTY,
INVS.INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
INVS.TOTAL_TAX_AMOUNT,
INVS.PAYMENT_DUE_DATE,
INVS.CP_REF_NO,
PCM.ISSUE_DATE,
PCM.CONTRACT_REF_NO,
CM.CUR_CODE,
PCPD.QTY_MAX_VAL,
QUM.QTY_UNIT,
PCPD.MAX_TOLERANCE,
QAT.QUALITY_NAME,
PDM.PRODUCT_DESC,
PCM.CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM,
GMR.FINAL_WEIGHT,
PHD.COMPANYNAME,
PAD.ADDRESS,
CYM.COUNTRY_NAME,
CIM.CITY_NAME,
SM.STATE_NAME,
PAD.ZIP,
PCM.CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME,
PCI.TERMS,
PHD1.COMPANYNAME,
PHD2.COMPANYNAME,
QUM_GMR.QTY_UNIT,
PCI.CONTRACT_TYPE,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ,
INVS.INVOICE_STATUS,
INVS.IS_FREE_METAL,
INVS.IS_PLEDGE,
INVS.INTERNAL_COMMENTS';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('11','10','12');
  
end;

Update PLD_PRODUCT_LICENCE_DETAIL SET PRODUCT_VERSION ='8.1.16.0';

commit;

CREATE OR REPLACE FORCE VIEW v_pci_for_assay (internal_contract_item_ref_no,
                                              internal_contract_ref_no,
                                              contract_ref_no,
                                              contract_item_ref_no,
                                              contract_type,
                                              corporate_id,
                                              cp_name,
                                              cp_id,
                                              product_id,
                                              product_name,
                                              quality_name,
                                              delivery_item_ref_no,
                                              middle_no
                                             )
AS
   SELECT pci.internal_contract_item_ref_no AS internal_contract_item_ref_no,
          pcm.internal_contract_ref_no AS internal_contract_ref_no,
          pcm.contract_ref_no AS contract_ref_no,
          (   pcm.contract_ref_no
           || ' '
           || 'Item No.'
           || ' '
           || pci.del_distribution_item_no
          ) contract_item_ref_no,
          pcm.purchase_sales AS contract_type,
          pcm.corporate_id AS corporate_id, phd.companyname AS cp_name,
          phd.profileid AS cp_id, pcpd.product_id AS product_id,
          pdm.product_desc AS product_name, qat.quality_name AS quality_name,
          (pcm.contract_ref_no || '-' || pcdi.delivery_item_no
          ) AS delivery_item_ref_no,
          pcm.middle_no
     FROM pci_physical_contract_item pci,
          pcm_physical_contract_main pcm,
          pcdb_pc_delivery_basis pcdb,
          pcdi_pc_delivery_item pcdi,
          pcpd_pc_product_definition pcpd,
          pcpq_pc_product_quality pcpq,
          phd_profileheaderdetails phd,
          pdm_productmaster pdm,
          qat_quality_attributes qat
    WHERE pcdb.pcdb_id = pci.pcdb_id
      AND pci.pcdi_id = pcdi.pcdi_id
      AND phd.profileid = pcm.cp_id
      AND pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
      AND pci.pcpq_id = pcpq.pcpq_id
      AND pcpq.pcpq_id = pci.pcpq_id
      AND pcpd.pcpd_id = pcpq.pcpd_id
      AND qat.quality_id = pcpq.quality_template_id
      AND pdm.product_id = pcpd.product_id
      AND pci.is_active = 'Y'
      AND pcm.contract_status = 'In Position'
      AND (pci.is_called_off = 'Y' OR pcdi.is_phy_optionality_present = 'N');
/
alter table CT_CURRENCY_TRADE add EXPIRY_DATE date
/
alter table CT_CURRENCY_TRADE add (IS_DELETED  char(1) DEFAULT 'N')
/
alter table CTUL_CURRENCY_TRADE_UL add EXPIRY_DATE date
/
      
update GMC_GRID_MENU_CONFIGURATION gmc
set GMC.DISPLAY_SEQ_NO = 8
where GMC.GRID_ID = 'LIST_EXCHNG_OPTION_TRADES'
and GMC.MENU_DISPLAY_NAME = 'View';
 
 
alter table DT_FBI drop constraint CHK_DT_FBI_FB_PERIOD_SUB_TYPE;
ALTER TABLE DT_FBI ADD
CONSTRAINT CHK_DT_FBI_FB_PERIOD_SUB_TYPE
CHECK (FB_PERIOD_SUB_TYPE IN ('Prompt Month','Delivery Month','Specific Period','Exchange Calendar','Delivered Month'));
 
commit;


/* Formatted on 2012/06/06 15:43 (Formatter Plus v4.8.8) */
ALTER TABLE dt_qty_log
MODIFY(total_lots_delta NUMBER(20))
/

ALTER TABLE dt_qty_log
MODIFY(open_lots_delta NUMBER(20))
/


ALTER TABLE dt_qty_log
MODIFY(closed_lots_delta NUMBER(20))
/


ALTER TABLE dt_qty_log
MODIFY(exercised_lots_delta NUMBER(20))
/


ALTER TABLE dt_qty_log
MODIFY(expired_lots_delta NUMBER(20))
/
alter table CT_CURRENCY_TRADE add EXPIRY_DATE date
/

alter table CT_CURRENCY_TRADE add (IS_DELETED  char(1) DEFAULT 'N')
/


alter table CTUL_CURRENCY_TRADE_UL add EXPIRY_DATE date
/
set define off;
update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_DISPLAY_NAME = 'Fx Trades'  where AMC.MENU_ID = 'T11'
/
update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_DISPLAY_NAME = 'New Fx Trade', AMC.MENU_PARENT_ID = 'T113', AMC.MENU_LEVEL_NO = 5  where AMC.MENU_ID = 'T111'
/
update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_PARENT_ID = 'T113', AMC.MENU_LEVEL_NO = 5  where AMC.MENU_ID = 'T112'
/
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('T113', 'Fx Forward', 1, 4, '/cdc/getListingPage.action?gridId=FX_TRADES', 
    NULL, 'T11', NULL, 'Derivative', NULL, 
    'N')
    /
    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('T114', 'Fx Option', 2, 4, '/cdc/getListingPage.action?gridId=FX_OPTION_TRADES', 
    NULL, 'T11', NULL, 'Derivative', NULL, 
    'N')
    /

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('T115', 'New Fx Option', 1, 5, '/cdc/newOptionFxTrade.action?gridId=ONO&dealTypeId=DTM-4', 
    NULL, 'T114', NULL, 'Derivative', NULL, 
    'N')
    /
    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('T116', 'List All', 2, 5, '/cdc/getListingPage.action?gridId=FX_OPTION_TRADES', 
    NULL, 'T114', NULL, 'Derivative', NULL, 
    'N')
/

UPDATE itcm_imp_table_column_mapping itcm
   SET itcm.property_name = 'deliveryPeriod'
 WHERE itcm.file_type_id = 'IMPORT_FX_OPTION_QUOTES'
   AND itcm.db_column_name = 'PERIOD'
/
   UPDATE itcm_imp_table_column_mapping itcm
   SET ITCM.MAPPED_COLUMN_NAME = 'INSTRUMENT_ID'
 WHERE itcm.file_type_id = 'IMPORT_FX_OPTION_QUOTES'
   AND itcm.db_column_name = 'INSTRUMENT_NAME'
/
   UPDATE itcm_imp_table_column_mapping itcm
   SET ITCM.MAPPED_COLUMN_NAME = 'PRICE_SOURCE_ID'
 WHERE itcm.file_type_id = 'IMPORT_FX_OPTION_QUOTES'
   AND itcm.db_column_name = 'PRICE_SOURCE'
/
   UPDATE itcm_imp_table_column_mapping itcm
   SET ITCM.MAPPED_COLUMN_NAME = 'AVAILABLE_PRICE_ID'
 WHERE itcm.file_type_id = 'IMPORT_FX_OPTION_QUOTES'
   AND itcm.db_column_name = 'PRICE_TYPE'
 /
 UPDATE GM_GRID_MASTER GM
   SET GM.DEFAULT_COLUMN_MODEL_STATE = '[
{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","id":"checker","sortable":false,"width":20},
{header: "Trader Ref No", width: 150, sortable: true, dataIndex: "tradeRefNum"},
{header: "External Ref No", width: 150, sortable: true, dataIndex: "extRefNo"},
{header: "Trade Type", width: 150, sortable: true, dataIndex: "tradeType"},
{header: "Trade Date", width: 150, sortable: true, dataIndex: "tradeDate"},
{header: "Trade Quantity", width: 150, sortable: true, dataIndex: "tradeQuantity"},
{header: "Trade Quantity In Lots", width: 150, sortable: true, dataIndex: "tradeQuantityInLots"},
{header: "Trade Price", width: 150, sortable: true, dataIndex: "tradePrice"},
{header: "Exchange Instrument", width: 150, sortable: true, dataIndex: "exchangeInstrument"},
{header: "Delivery Period", width: 150, sortable: true, dataIndex: "deliveryPeriod"},
{header: "Profit Center", width: 150, sortable: true, dataIndex: "profitCenter"},
{header: "Purpose", width: 150, sortable: true, dataIndex: "purpose"},
{header: "Strategy", width: 150, sortable: true, dataIndex: "strategy"},
{header: "Broker", width: 150, sortable: true, dataIndex: "broker"},
{header: "Clearer", width: 150, sortable: true, dataIndex: "clearer"}
]'
 WHERE GM.GRID_ID = 'LOTFIT'
 /
  --for futures
 UPDATE gmc_grid_menu_configuration
   SET display_seq_no = 7
 WHERE menu_id = 'FUT_TRADES-07'
/
UPDATE gmc_grid_menu_configuration
   SET display_seq_no = 6
 WHERE menu_id = 'FUT_TRADES-08'
/
--for Exchange options
UPDATE gmc_grid_menu_configuration
   SET display_seq_no = 8
 WHERE menu_id = 'EXCHANGE_OPTIONS-08'
/
UPDATE gmc_grid_menu_configuration
   SET display_seq_no = 7
 WHERE menu_id = 'EXCHANGE_OPTIONS-09'
/

--for fx trades

UPDATE gmc_grid_menu_configuration
   SET display_seq_no = 1
 WHERE menu_id = 'FX_TRADES-06'
/
UPDATE gmc_grid_menu_configuration
   SET display_seq_no = 2
 WHERE menu_id = 'FX_TRADES-07'
/
UPDATE gmc_grid_menu_configuration
   SET display_seq_no = 3
 WHERE menu_id = 'FX_TRADES-05'
/
UPDATE gmc_grid_menu_configuration
   SET display_seq_no = 4
 WHERE menu_id = 'FX_TRADES-04'
/
UPDATE gmc_grid_menu_configuration
   SET display_seq_no = 5
 WHERE menu_id = 'FX_TRADES-03'
/

Insert into ISTM_INSTR_SUB_TYPE_MASTER
(INSTRUMENT_SUB_TYPE_ID, INSTRUMENT_SUB_TYPE, INST_SUB_TYPE_DISPLAY_NAME, INSTRUMENT_TYPE_ID, DISPLAY_ORDER, VERSION, IS_ACTIVE, IS_DELETED)
Values
('ISTM-11', 'Asian', 'Asian', 'IRM-2', 11, '1', 'Y', 'N')
/

Insert into ISTM_INSTR_SUB_TYPE_MASTER
(INSTRUMENT_SUB_TYPE_ID, INSTRUMENT_SUB_TYPE, INST_SUB_TYPE_DISPLAY_NAME, INSTRUMENT_TYPE_ID, DISPLAY_ORDER, VERSION, IS_ACTIVE, IS_DELETED)
Values
('ISTM-12', 'Asian', 'Asian', 'IRM-3', 12, '1', 'Y', 'N')
/
commit;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(PAYABLE_QTY_DISPLAY VARCHAR2(1000 CHAR));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(FREE_METAL_QTY_DISPLAY VARCHAR2(1000 CHAR));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(TC_AMOUNT_DISPLAY VARCHAR2(1000 CHAR));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(RC_AMOUNT_DISPLAY VARCHAR2(1000 CHAR));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(PENALTY_AMOUNT_DISPLAY VARCHAR2(1000 CHAR));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(FREE_METAL_AMOUNT_DISPLAY VARCHAR2(1000 CHAR));

declare
fetchqry1 clob := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, internal_doc_ref_no)
   SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                   NVL (pcmac.addn_charge_name,
                        scm.cost_display_name
                       ) AS other_charge_cost_name,
                   ioc.charge_type AS charge_type,
                   NVL (ioc.rate_fx_rate, ioc.flat_amount_fx_rate) AS fx_rate,
                   ioc.quantity AS quantity,
                   NVL (ioc.rate_amount, ioc.flat_amount) AS amount,
                   ioc.amount_in_inv_cur AS invoice_amount,
                   cm.cur_code AS invoice_cur_name,
                   (CASE
                       WHEN ioc.rate_price_unit = ''Bags''
                          THEN cm.cur_code || ''/'' || ''Bag''
                       WHEN scm.cost_component_name IN
                              (''AssayCharge'', ''SamplingCharge'',
                               ''Ocular Inspection Charge'')
                          THEN cm.cur_code || ''/'' || ''Lot''
                       ELSE pum.price_unit_name
                    END
                   ) AS rate_price_unit_name,
                   NVL (ioc.flat_amount,
                        ioc.rate_charge
                       ) AS charge_amount_rate,
                   (CASE
                       WHEN ioc.rate_price_unit = ''Bags''
                          THEN ''Bags''
                       WHEN scm.cost_component_name IN
                              (''AssayCharge'', ''SamplingCharge'',
                               ''Ocular Inspection Charge'')
                          THEN ''Lots''
                       ELSE qum.qty_unit
                    END
                   ) AS quantity_unit,
                   cm_ioc.cur_code AS amount_unit, ?
              FROM is_invoice_summary invs,
                   ioc_invoice_other_charge ioc,
                   cm_currency_master cm,
                   scm_service_charge_master scm,
                   ppu_product_price_units ppu,
                   pum_price_unit_master pum,
                   qum_quantity_unit_master qum,
                   cm_currency_master cm_ioc,
                   pcmac_pcm_addn_charges pcmac
             WHERE invs.internal_invoice_ref_no = ioc.internal_invoice_ref_no
               AND ioc.other_charge_cost_id = scm.cost_id(+)
               AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
               AND ioc.invoice_cur_id = cm.cur_id(+)
               AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
               AND ppu.price_unit_id = pum.price_unit_id(+)
               AND ioc.qty_unit_id = qum.qty_unit_id(+)
               AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
               AND ioc.internal_invoice_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('DGM-DFI-C7','DGM-IOC_C','DGM-IOC_BM') AND DOC_ID NOT IN('CREATE_DC');
  
end;
commit;

CREATE OR REPLACE FORCE VIEW v_pci_for_assay (internal_contract_item_ref_no,
                                              internal_contract_ref_no,
                                              contract_ref_no,
                                              contract_item_ref_no,
                                              contract_type,
                                              corporate_id,
                                              cp_name,
                                              cp_id,
                                              product_id,
                                              product_name,
                                              quality_name,
                                              delivery_item_ref_no,
                                              middle_no
                                             )
AS
   SELECT pci.internal_contract_item_ref_no AS internal_contract_item_ref_no,
          pcm.internal_contract_ref_no AS internal_contract_ref_no,
          pcm.contract_ref_no AS contract_ref_no,
          (   pcm.contract_ref_no
           || ' '
           || 'Item No.'
           || ' '
           || pci.del_distribution_item_no
          ) contract_item_ref_no,
          pcm.purchase_sales AS contract_type,
          pcm.corporate_id AS corporate_id, phd.companyname AS cp_name,
          phd.profileid AS cp_id, pcpd.product_id AS product_id,
          pdm.product_desc AS product_name, qat.quality_name AS quality_name,
          (pcm.contract_ref_no || '-' || pcdi.delivery_item_no
          ) AS delivery_item_ref_no,
          pcm.middle_no
     FROM pci_physical_contract_item pci,
          pcm_physical_contract_main pcm,
          pcdb_pc_delivery_basis pcdb,
          pcdi_pc_delivery_item pcdi,
          pcpd_pc_product_definition pcpd,
          pcpq_pc_product_quality pcpq,
          phd_profileheaderdetails phd,
          pdm_productmaster pdm,
          qat_quality_attributes qat
    WHERE pcdb.pcdb_id = pci.pcdb_id
      AND pci.pcdi_id = pcdi.pcdi_id
      AND phd.profileid = pcm.cp_id
      AND pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
      AND pci.pcpq_id = pcpq.pcpq_id
      AND pcpq.pcpq_id = pci.pcpq_id
      AND pcpd.pcpd_id = pcpq.pcpd_id
      AND qat.quality_id = pcpq.quality_template_id
      AND pdm.product_id = pcpd.product_id
      AND pci.is_active = 'Y'
      AND pcm.contract_status = 'In Position'
      AND (pci.is_called_off = 'Y' OR pcdi.is_phy_optionality_present = 'N')
/

alter table ECS_ELEMENT_COST_STORE add COST_REF_NO VARCHAR2(15 );

declare
fetchqry1 clob := 'INSERT INTO IS_D(
INVOICE_REF_NO,
INVOICE_TYPE_NAME,
INVOICE_CREATION_DATE,
INVOICE_DRY_QUANTITY,
INVOICE_WET_QUANTITY,
MOISTURE,
INVOICED_QTY_UNIT,
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
MATERIAL_COST,
ADDDITIONAL_CHARGES,
TAXES,
DUE_DATE,
SUPPLIRE_INVOICE_NO,
CONTRACT_DATE,
CONTRACT_REF_NO,
STOCK_QUANTITY,
STOCK_REF_NO,
INVOICE_AMOUNT_UNIT,
GMR_REF_NO,
GMR_QUALITY,
CONTRACT_QUANTITY,
CONTRACT_QTY_UNIT,
CONTRACT_TOLERANCE,
QUALITY,
PRODUCT,
CP_CONTRACT_REF_NO,
PAYMENT_TERM,
GMR_FINALIZE_QTY,
CP_NAME,
CP_ADDRESS,
CP_COUNTRY,
CP_CITY,
CP_STATE,
CP_ZIP,
CONTRACT_TYPE,
ORIGIN,
INCO_TERM_LOCATION,
NOTIFY_PARTY,
SALES_PURCHASE,
INVOICE_STATUS,
INTERNAL_DOC_REF_NO
)
with test as (select invs.INTERNAL_INVOICE_REF_NO, sum(ASM.NET_WEIGHT) as wet,
sum(ASM.DRY_WEIGHT) as dry
from 
IS_INVOICE_SUMMARY invs,
ASH_ASSAY_HEADER ash,
ASM_ASSAY_SUBLOT_MAPPING asm,
IAM_INVOICE_ASSAY_MAPPING iam
where
INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
and IAM.ASH_ID = ASH.ASH_ID
and ASH.ASH_ID = ASM.ASH_ID
group by invs.INTERNAL_INVOICE_REF_NO
)
select
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME as INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE as INVOICE_CREATION_DATE,
t.DRY as INVOICE_DRY_QUANTITY,
t.WET as INVOICE_WET_QUANTITY,
ROUND((((t.WET - t.DRY)/t.WET)*100),2) as MOISTURE,
QUM_GMR.QTY_UNIT as INVOICED_QTY_UNIT,
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ as MATERIAL_COST,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as ADDDITIONAL_CHARGES,
INVS.TOTAL_TAX_AMOUNT as TAXES,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
INVS.CP_REF_NO as SUPPLIER_INVOICE_NO,
PCM.ISSUE_DATE as CONTRACT_DATE,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
sum(II.INVOICABLE_QTY) as STOCK_QUANTITY,
stragg(DISTINCT II.STOCK_REF_NO) as STOCK_REF_NO,
NVL (cm_pct.cur_code, cm.cur_code) AS invoice_amount_unit,
stragg(DISTINCT GMR.GMR_REF_NO) as GMR_REF_NO,
sum(GMR.QTY) as GMR_QUALITY,
PCPD.QTY_MAX_VAL as CONTRACT_QUANTITY,
QUM.QTY_UNIT as CONTRACT_QTY_UNIT,
PCPD.MAX_TOLERANCE as CONTRACT_TOLERANCE,
QAT.QUALITY_NAME as QUALITY,
PDM.PRODUCT_DESC as PRODUCT,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM as PAYMENT_TERM,
GMR.FINAL_WEIGHT as GMR_FINALIZE_QTY,
PHD.COMPANYNAME as CP_NAME,
PAD.ADDRESS as CP_ADDRESS,
CYM.COUNTRY_NAME as CP_COUNTRY,
CIM.CITY_NAME as CP_CITY,
SM.STATE_NAME as CP_STATE,
PAD.ZIP as CP_ZIP,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME as ORIGIN,
PCI.TERMS as INCO_TERM_LOCATION,
nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME) as NOTIFY_PARTY, 
PCI.CONTRACT_TYPE as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
?
from 
IS_INVOICE_SUMMARY invs,
IID_INVOICABLE_ITEM_DETAILS iid,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
II_INVOICABLE_ITEM ii,
CM_CURRENCY_MASTER cm,
GMR_GOODS_MOVEMENT_RECORD gmr,
PCPD_PC_PRODUCT_DEFINITION pcpd,
QUM_QUANTITY_UNIT_MASTER qum,
PCPQ_PC_PRODUCT_QUALITY pcpq,
QAT_QUALITY_ATTRIBUTES qat,
PDM_PRODUCTMASTER pdm,
PHD_PROFILEHEADERDETAILS phd,
PYM_PAYMENT_TERMS_MASTER pym,
PAD_PROFILE_ADDRESSES pad,
CYM_COUNTRYMASTER cym,
CIM_CITYMASTER cim,
SM_STATE_MASTER sm,
BPAT_BP_ADDRESS_TYPE bpat,
CYM_COUNTRYMASTER cymloading,
SAD_SHIPMENT_ADVICE sad,
SD_SHIPMENT_DETAIL sd,
PHD_PROFILEHEADERDETAILS phd1,
PHD_PROFILEHEADERDETAILS phd2,
QUM_QUANTITY_UNIT_MASTER qum_gmr,
cm_currency_master cm_pct,
test t
where
INVS.INTERNAL_INVOICE_REF_NO = IID.INTERNAL_INVOICE_REF_NO(+)
and IID.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO(+)
and IID.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO(+)
and IID.INVOICABLE_ITEM_ID = II.INVOICABLE_ITEM_ID(+)
and IID.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INVOICE_CURRENCY_ID = CM.CUR_ID(+)
and II.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INTERNAL_CONTRACT_REF_NO = PCPD.INTERNAL_CONTRACT_REF_NO(+)
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
and PCPD.PCPD_ID = PCPQ.PCPD_ID(+)
and PCI.QUALITY_ID = QAT.QUALITY_ID(+)
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
and INVS.CP_ID = PHD.PROFILEID(+)
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID(+)
and PHD.PROFILEID = PAD.PROFILE_ID(+)
and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.NOTIFY_PARTY_ID = PHD1.PROFILEID(+)
and SD.NOTIFY_PARTY_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and invs.invoice_cur_id = cm_pct.cur_id(+)
and PAD.ADDRESS_TYPE(+) = ''Billing''
and PAD.IS_DELETED(+) = ''N''
and PCPD.INPUT_OUTPUT in (''Input'')
and t.INTERNAL_INVOICE_REF_NO = INVS.INTERNAL_INVOICE_REF_NO
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
INVS.INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE,
INVS.INVOICED_QTY,
INVS.INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
INVS.TOTAL_TAX_AMOUNT,
INVS.PAYMENT_DUE_DATE,
INVS.CP_REF_NO,
PCM.ISSUE_DATE,
PCM.CONTRACT_REF_NO,
CM.CUR_CODE,
PCPD.QTY_MAX_VAL,
QUM.QTY_UNIT,
PCPD.MAX_TOLERANCE,
QAT.QUALITY_NAME,
PDM.PRODUCT_DESC,
PCM.CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM,
GMR.FINAL_WEIGHT,
PHD.COMPANYNAME,
PAD.ADDRESS,
CYM.COUNTRY_NAME,
CIM.CITY_NAME,
SM.STATE_NAME,
PAD.ZIP,
PCM.CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME,
PCI.TERMS,
PHD1.COMPANYNAME,
PHD2.COMPANYNAME,
QUM_GMR.QTY_UNIT,
PCI.CONTRACT_TYPE,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ,
INVS.INVOICE_STATUS,
cm_pct.cur_code,
t.DRY,
t.WET';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('DGM-PIC','DGM-FIC','DGM-DFIC');
  
end;
/

declare
fetchqry1 clob := 'INSERT INTO IS_D(
INVOICE_REF_NO,
INVOICE_TYPE_NAME,
INVOICE_CREATION_DATE,
INVOICE_QUANTITY,
INVOICED_QTY_UNIT,
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
MATERIAL_COST,
ADDDITIONAL_CHARGES,
TAXES,
DUE_DATE,
SUPPLIRE_INVOICE_NO,
CONTRACT_DATE,
CONTRACT_REF_NO,
STOCK_QUANTITY,
STOCK_REF_NO,
INVOICE_AMOUNT_UNIT,
GMR_REF_NO,
GMR_QUALITY,
CONTRACT_QUANTITY,
CONTRACT_QTY_UNIT,
CONTRACT_TOLERANCE,
QUALITY,
PRODUCT,
CP_CONTRACT_REF_NO,
PAYMENT_TERM,
GMR_FINALIZE_QTY,
CP_NAME,
CP_ADDRESS,
CP_COUNTRY,
CP_CITY,
CP_STATE,
CP_ZIP,
CONTRACT_TYPE,
ORIGIN,
INCO_TERM_LOCATION,
NOTIFY_PARTY,
SALES_PURCHASE,
INVOICE_STATUS,
IS_FREE_METAL,
IS_PLEDGE,
INTERNAL_COMMENTS,
INTERNAL_DOC_REF_NO
)
select
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME as INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE as INVOICE_CREATION_DATE,
INVS.INVOICED_QTY as INVOICE_QUANTITY,
QUM_GMR.QTY_UNIT as INVOICED_QTY_UNIT,
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ as MATERIAL_COST,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as ADDDITIONAL_CHARGES,
INVS.TOTAL_TAX_AMOUNT as TAXES,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
INVS.CP_REF_NO as SUPPLIER_INVOICE_NO,
PCM.ISSUE_DATE as CONTRACT_DATE,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
sum(II.INVOICABLE_QTY) as STOCK_QUANTITY,
stragg(distinct II.STOCK_REF_NO) as STOCK_REF_NO,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
stragg(GMR.GMR_REF_NO) as GMR_REF_NO,
sum(GMR.QTY) as GMR_QUALITY,
PCPD.QTY_MAX_VAL as CONTRACT_QUANTITY,
QUM.QTY_UNIT as CONTRACT_QTY_UNIT,
PCPD.MAX_TOLERANCE as CONTRACT_TOLERANCE,
QAT.QUALITY_NAME as QUALITY,
PDM.PRODUCT_DESC as PRODUCT,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM as PAYMENT_TERM,
GMR.FINAL_WEIGHT as GMR_FINALIZE_QTY,
PHD.COMPANYNAME as CP_NAME,
PAD.ADDRESS as CP_ADDRESS,
CYM.COUNTRY_NAME as CP_COUNTRY,
CIM.CITY_NAME as CP_CITY,
SM.STATE_NAME as CP_STATE,
PAD.ZIP as CP_ZIP,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME as ORIGIN,
PCI.TERMS as INCO_TERM_LOCATION,
nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME) as NOTIFY_PARTY, 
PCI.CONTRACT_TYPE as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
INVS.IS_FREE_METAL as IS_FREE_METAL,
INVS.IS_PLEDGE as IS_PLEDGE,
INVS.INTERNAL_COMMENTS as INTERNAL_COMMENTS,
?
from 
IS_INVOICE_SUMMARY invs,
IID_INVOICABLE_ITEM_DETAILS iid,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
II_INVOICABLE_ITEM ii,
CM_CURRENCY_MASTER cm,
GMR_GOODS_MOVEMENT_RECORD gmr,
PCPD_PC_PRODUCT_DEFINITION pcpd,
QUM_QUANTITY_UNIT_MASTER qum,
PCPQ_PC_PRODUCT_QUALITY pcpq,
QAT_QUALITY_ATTRIBUTES qat,
PDM_PRODUCTMASTER pdm,
PHD_PROFILEHEADERDETAILS phd,
PYM_PAYMENT_TERMS_MASTER pym,
PAD_PROFILE_ADDRESSES pad,
CYM_COUNTRYMASTER cym,
CIM_CITYMASTER cim,
SM_STATE_MASTER sm,
BPAT_BP_ADDRESS_TYPE bpat,
CYM_COUNTRYMASTER cymloading,
SAD_SHIPMENT_ADVICE sad,
SD_SHIPMENT_DETAIL sd,
PHD_PROFILEHEADERDETAILS phd1,
PHD_PROFILEHEADERDETAILS phd2,
QUM_QUANTITY_UNIT_MASTER qum_gmr
where
INVS.INTERNAL_INVOICE_REF_NO = IID.INTERNAL_INVOICE_REF_NO
and IID.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO
and IID.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and IID.INVOICABLE_ITEM_ID = II.INVOICABLE_ITEM_ID
and IID.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INVOICE_CURRENCY_ID = CM.CUR_ID
and II.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INTERNAL_CONTRACT_REF_NO = PCPD.INTERNAL_CONTRACT_REF_NO
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID
and PCPD.PCPD_ID = PCPQ.PCPD_ID
and PCI.QUALITY_ID = QAT.QUALITY_ID
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and INVS.CP_ID = PHD.PROFILEID
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID
and PHD.PROFILEID = PAD.PROFILE_ID(+)
and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.NOTIFY_PARTY_ID = PHD1.PROFILEID(+)
and SD.NOTIFY_PARTY_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.IS_DELETED(+) = ''N''
and PAD.ADDRESS_TYPE(+) = ''Billing''
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
INVS.INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE,
INVS.INVOICED_QTY,
INVS.INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
INVS.TOTAL_TAX_AMOUNT,
INVS.PAYMENT_DUE_DATE,
INVS.CP_REF_NO,
PCM.ISSUE_DATE,
PCM.CONTRACT_REF_NO,
CM.CUR_CODE,
PCPD.QTY_MAX_VAL,
QUM.QTY_UNIT,
PCPD.MAX_TOLERANCE,
QAT.QUALITY_NAME,
PDM.PRODUCT_DESC,
PCM.CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM,
GMR.FINAL_WEIGHT,
PHD.COMPANYNAME,
PAD.ADDRESS,
CYM.COUNTRY_NAME,
CIM.CITY_NAME,
SM.STATE_NAME,
PAD.ZIP,
PCM.CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME,
PCI.TERMS,
PHD1.COMPANYNAME,
PHD2.COMPANYNAME,
QUM_GMR.QTY_UNIT,
PCI.CONTRACT_TYPE,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ,
INVS.INVOICE_STATUS,
INVS.IS_FREE_METAL,
INVS.IS_PLEDGE,
INVS.INTERNAL_COMMENTS';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('11','10','12');
  
end;
/

update GMC_GRID_MENU_CONFIGURATION set GMC_GRID_MENU_CONFIGURATION.DISPLAY_SEQ_NO='7'
where GMC_GRID_MENU_CONFIGURATION.MENU_ID='LOAS-MA';

update AMC_APP_MENU_CONFIGURATION set MENU_DISPLAY_NAME='List Of Invoiceable Items' where MENU_ID='F5';

create or replace view v_bi_daily_price_exposure as
with main_q as (
        -- Average Pricing for the  base 
        select ak.corporate_id,
                pdm.product_id,
                pdm.product_desc product_name,
                1 dispay_order,
                'Average Exposure' pricing_by,
                decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
                pofh.per_day_pricing_qty *
                pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                     qum.qty_unit_id,
                                                     pdm.base_quantity_unit,
                                                     1) to_be_fixed_or_fixed_qty,
                'N' font_bold,
                pdm.base_quantity_unit base_qty_unit_id,
                qum_pdm.qty_unit base_qty_unit
          from pcm_physical_contract_main pcm,
                pcdi_pc_delivery_item pcdi,
                ak_corporate ak,
                gmr_goods_movement_record gmr,
                pcpd_pc_product_definition pcpd,
                pdm_productmaster pdm,
                css_corporate_strategy_setup css,
                --pcpq_pc_product_quality pcpq,
                qat_quality_attributes qat,
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
                qum_quantity_unit_master qum,
                pofh_price_opt_fixation_header pofh,
                cpc_corporate_profit_center cpc,
                vd_voyage_detail vd,
                pfqpp_phy_formula_qp_pricing pfqpp,
                --v_pci_multiple_premium vp,
                qum_quantity_unit_master qum_pdm
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.product_id = pdm.product_id
           and pcpd.strategy_id = css.strategy_id
           --and pcpd.pcpd_id = pcpq.pcpd_id
           --and pcpq.quality_template_id = qat.quality_id
           --and pcpq.pcpq_id = vp.pcpq_id(+)
           and pdm.product_id = qat.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and poch.poch_id = pocd.poch_id
           and pcm.internal_contract_ref_no = pcbph.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pocd.pocd_id = pofh.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and nvl(vd.status, 'Active') = 'Active'
           and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'BASEMETAL'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pofh.qp_start_date <= trunc(sysdate)
           and pofh.qp_end_date >= trunc(sysdate)
           and qum_pdm.qty_unit_id = pdm.base_quantity_unit
        union all
        -- Average Pricing for the  Concentrate  
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc,
               1 section_id,
               'Average Exposure',
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               pofh.per_day_pricing_qty *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                        pdm.product_id),
                                                    qum.qty_unit_id,
                                                    nvl(pdm_under.base_quantity_unit,
                                                        pdm.base_quantity_unit),
                                                    1) qty,
               'N',
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcdi_pc_delivery_item pcdi,
               qum_quantity_unit_master qum,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               --pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
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
               aml_attribute_master_list aml,
               pdm_productmaster pdm_under,
               qum_quantity_unit_master qum_under,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               pcqpd_pc_qual_premium_discount pcqpd,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum_pdm
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.strategy_id = css.strategy_id
           --and pcpd.pcpd_id = pcpq.pcpd_id
           and pcpd.product_id = pdm.product_id
           --and pcpq.quality_template_id = qat.quality_id
           and pdm.product_id = qat.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and poch.poch_id = pocd.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and poch.pcbph_id = pcbph.pcbph_id
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pocd.pocd_id = pofh.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pocd_id = pocd.pocd_id
           and poch.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbph.element_id = poch.element_id
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'CONCENTRATES'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pofh.qp_start_date <= trunc(sysdate)
           and pofh.qp_end_date >= trunc(sysdate)
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
        
        --Fixed by Price Request base
        union all
        select ak.corporate_id,
               pdm.product_id,
               pdm.product_desc product,
               2 display_order,
               'Fixed by Price Request',
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed) *
               pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                    qum.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    1) qty,
               'N',
               pdm.base_quantity_unit,
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               qum_quantity_unit_master qum,
               pcdi_pc_delivery_item pcdi,
               pcpd_pc_product_definition pcpd,
               --pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               css_corporate_strategy_setup css,
               qat_quality_attributes qat,
               poch_price_opt_call_off_header poch,
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
               --v_pci_multiple_premium vp,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           --and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           and pcpd.strategy_id = css.strategy_id
           --and pcpq.quality_template_id = qat.quality_id
           --and pcpq.pcpq_id = vp.pcpq_id(+)
           and qat.product_id = pdm.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pofh.pocd_id = pocd.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and pfqpp.ppfh_id = ppfh.ppfh_id
           and pcm.contract_type = 'BASEMETAL'
           and pfqpp.is_qp_any_day_basis = 'Y'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'N' --added to handle spot as separate
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pfd.as_of_date = trunc(sysdate)
           and pfd.is_price_request = 'Y'
           and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         group by ak.corporate_id,
                  pdm.product_id,
                  pdm.product_desc,
                  pcm.purchase_sales,
                  pcpd.product_id,
                  qum.qty_unit_id,
                  pdm.base_quantity_unit,
                  pdm.base_quantity_unit,
                  qum_pdm.qty_unit
        union all
        --Fixed by Price Request Concentrates
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc product,
               2 section_id,
               'Fixed by Price Request' section,
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed) *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                        pdm.product_id),
                                                    qum.qty_unit_id,
                                                    nvl(pdm_under.base_quantity_unit,
                                                        pdm.base_quantity_unit),
                                                    1) qty,
               'N',
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               ak_corporate ak,
               qum_quantity_unit_master qum,
               pcdi_pc_delivery_item pcdi,
               pcpd_pc_product_definition pcpd,
               --pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               css_corporate_strategy_setup css,
               qat_quality_attributes qat,
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
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           --and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           and pcpd.strategy_id = css.strategy_id
           and qat.product_id = pdm.product_id
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
           and pofh.pofh_id = pfd.pofh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and pfqpp.ppfh_id = ppfh.ppfh_id
           and ppfh.is_active = 'Y'
           and pfqpp.is_qp_any_day_basis = 'Y'
           and pcm.contract_type = 'CONCENTRATES'
           and pcm.contract_status <> 'Cancelled'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'N' --added to handle spot as separate
           and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
           and pfd.as_of_date = trunc(sysdate)
           and pfd.is_price_request = 'Y'
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
         group by ak.corporate_id,
                  pdm_under.product_id,
                  pdm_under.product_desc,
                  pcm.purchase_sales,
                  nvl(pdm_under.product_id, pdm.product_id),
                  qum.qty_unit_id,
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  qum_pdm.qty_unit
        -- Spot base metal
        union all
        select ak.corporate_id,
               pdm.product_id,
               pdm.product_desc product,
               3 section_id,
               'Spot Exposure' section,
               (decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed)) qty,
               'N',
               qum.qty_unit_id,
               qum.qty_unit
          from pcm_physical_contract_main pcm,
               pcdi_pc_delivery_item pcdi,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               --pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
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
               pfqpp_phy_formula_qp_pricing pfqpp,
               pcqpd_pc_qual_premium_discount pcqpd,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           --and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           and pcpd.strategy_id = css.strategy_id
           --and pcpq.quality_template_id = qat.quality_id
           and qat.product_id = pdm.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pofh.pocd_id = pocd.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'Y'
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcm.contract_type = 'BASEMETAL'
           and pcdi.qty_unit_id = qum.qty_unit_id
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and pfd.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pfd.as_of_date = trunc(sysdate)
         group by ak.corporate_id,
                  pdm.product_id,
                  pdm.product_desc,
                  pcm.purchase_sales,
                  qum.qty_unit_id,
                  qum.qty_unit
        
        union all --spot concentrate
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc product,
               3 section_id,
               'Spot Exposure' section,
               ((decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed)) *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                         pdm.product_id),
                                                     qum.qty_unit_id,
                                                     nvl(pdm_under.base_quantity_unit,
                                                         pdm.base_quantity_unit),
                                                     1)) qty,
               'N',
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               pcdi_pc_delivery_item pcdi,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcpd_pc_product_definition pcpd,
               --pcpq_pc_product_quality pcpq,
               css_corporate_strategy_setup css,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
               poch_price_opt_call_off_header poch,
               pocd_price_option_calloff_dtls pocd,
               pcbph_pc_base_price_header pcbph,
               pcbpd_pc_base_price_detail pcbpd,
               ppfh_phy_price_formula_header ppfh,
               aml_attribute_master_list aml,
               pdm_productmaster pdm_under,
               qum_quantity_unit_master qum_under,
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
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum,
               qum_quantity_unit_master qum_pdm
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.contract_type = 'CONCENTRATES'
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           --and pcpd.pcpd_id = pcpq.pcpd_id
           and pcpd.strategy_id = css.strategy_id
           and pdm.product_id = pcpd.product_id
           --and pcpq.quality_template_id = qat.quality_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.element_id = poch.element_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pofh.pocd_id = pocd.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'Y'
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and pfd.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pcbph.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm_under.product_id
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id
           and pfd.as_of_date = trunc(sysdate)
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
         group by ak.corporate_id,
                  pdm_under.product_id,
                  pdm_under.product_desc,
                  pcm.purchase_sales,
                  nvl(pdm_under.product_id, pdm.product_id),
                  qum.qty_unit_id,
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  qum_pdm.qty_unit
        
        union all
        --any day base metal
        select ak.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               5 display_order,
               'Any Day Exposure' pricing_by,
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               (pofh.qty_to_be_fixed - nvl(sum(pfd.qty_fixed), 0)) *
               pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                    qum.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    1) to_be_fixed_or_fixed_qty,
               'N' font_bold,
               pdm.base_quantity_unit base_qty_unit_id,
               qum_pdm.qty_unit base_qty_unit
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcdi_pc_delivery_item pcdi,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               --pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
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
               pfqpp_phy_formula_qp_pricing pfqpp,
               --v_pci_multiple_premium vp,
               qum_quantity_unit_master qum,
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.strategy_id = css.strategy_id
           --and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           --and pcpq.quality_template_id = qat.quality_id
           --and pcpq.pcpq_id = vp.pcpq_id(+)
           and qat.product_id = pdm.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pofh.pocd_id = pocd.pocd_id(+)
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'BASEMETAL'
           and pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0) > 0
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pfd.as_of_date(+) <= sysdate
           and trunc(sysdate) between pofh.qp_start_date and pofh.qp_end_date
           and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         group by ak.corporate_id,
                  pdm.product_id,
                  pdm.product_desc,
                  pcm.purchase_sales,
                  pofh.qty_to_be_fixed,
                  pcpd.product_id,
                  qum.qty_unit_id,
                  pdm.base_quantity_unit,
                  pdm.base_quantity_unit,
                  qum_pdm.qty_unit
        union all
        --any day concentrate
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc product_name,
               5 display_order,
               'Any Day Exposure' pricing_by,
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               (pofh.qty_to_be_fixed - nvl(sum(pfd.qty_fixed), 0)) *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                        pdm.product_id),
                                                    qum.qty_unit_id,
                                                    nvl(pdm_under.base_quantity_unit,
                                                        pdm.base_quantity_unit),
                                                    1) qty,
               'N' font_bold,
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit) base_qty_unit_id,
               /*qum_pdm.qty_unit_id*/qum_pdm.qty_unit base_qty_unit--fix 18-May-2012
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcdi_pc_delivery_item pcdi,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               --pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
               poch_price_opt_call_off_header poch,
               aml_attribute_master_list aml,
               pdm_productmaster pdm_under,
               qum_quantity_unit_master qum_under,
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
               qum_quantity_unit_master qum,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.strategy_id = css.strategy_id
           --and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           --and pcpq.quality_template_id = qat.quality_id
           and qat.product_id = pdm.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and poch.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
           and pocd.poch_id = poch.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.element_id = poch.element_id
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pofh.pocd_id = pocd.pocd_id(+)
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id(+)
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'CONCENTRATES'
           and pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0) > 0
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pfd.as_of_date(+) <= sysdate
           and trunc(sysdate) between pofh.qp_start_date and pofh.qp_end_date
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
         group by ak.corporate_id,
                  pdm_under.product_id,
                  pdm_under.product_desc,
                  pcm.purchase_sales,
                  pofh.qty_to_be_fixed,
                  nvl(pdm_under.product_id, pdm.product_id),
                  qum.qty_unit_id,
                  /*qum_pdm.qty_unit_id*/qum_pdm.qty_unit,--Fix 18-May-2012
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               1 dispay_order,
               'Average Exposure',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               2 dispay_order,
               'Fixed by Price Request',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
        
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               3 dispay_order,
               'Spot Exposure',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               5 dispay_order,
               'Any Day Exposure',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
         ) 
select corporate_id,
       product_id,
       product_name,
       dispay_order,
       pricing_by,
       to_be_fixed_or_fixed_qty,
       font_bold,
       base_qty_unit_id,
       base_qty_unit
  from main_q
union all
select corporate_id,
       product_id,
       product_name,
       4 dispay_order,
       'Total Exposure' pricing_by,
       sum(to_be_fixed_or_fixed_qty),
       'Y' font_bold,
       base_qty_unit_id,
       base_qty_unit
  from main_q
 where dispay_order in (1, 2, 3)
 group by corporate_id,
          product_id,
          product_name,
          base_qty_unit_id,
          base_qty_unit
union all
select corporate_id,
       product_id,
       product_name,
       6 dispay_order,
       'Total Exposure With Any Day' pricing_by,
       sum(to_be_fixed_or_fixed_qty),
       'Y' font_bold,
       base_qty_unit_id,
       base_qty_unit
  from main_q
 group by corporate_id,
          product_id,
          product_name,
          base_qty_unit_id,
          base_qty_unit
union all
select drt.corporate_id,
       drt.product_id,
       drt.product_desc product_name,
       7 dispay_order,
       'Net Hedge Exposure' pricing_by,
       sum(drt.hedge_qty * drt.qty_sign) to_be_fixed_or_fixed_qty,
       'Y' font_bold,
       drt.qty_unit_id base_qty_unit_id,
       drt.qty_unit base_qty_unit
  from v_bi_derivative_trades drt
where drt.trade_date =  trunc(sysdate)
 group by drt.corporate_id,
          drt.product_id,
          drt.product_desc,
          drt.qty_unit_id,
          drt.qty_unit
union all
select drt.corporate_id,
       drt.product_id,
       drt.product_desc product_name,
       8 dispay_order,
       'Net Strategic Exposure' pricing_by,
       sum(drt.strategic_qty * drt.qty_sign) to_be_fixed_or_fixed_qty,
       'Y' font_bold,
       drt.qty_unit_id base_qty_unit_id,
       drt.qty_unit base_qty_unit
  from v_bi_derivative_trades drt
where drt.trade_date =  trunc(sysdate)
 group by drt.corporate_id,
          drt.product_id,
          drt.product_desc,
          drt.qty_unit_id,
          drt.qty_unit
union all
select drt.corporate_id,
       drt.product_id,
       drt.product_desc product_name,
       9 dispay_order,
       'Net Derivative' pricing_by,
       sum(drt.trade_qty * drt.qty_sign) to_be_fixed_or_fixed_qty,
       'Y' font_bold,
       drt.qty_unit_id base_qty_unit_id,
       drt.qty_unit base_qty_unit
  from v_bi_derivative_trades drt
where drt.trade_date =  trunc(sysdate)
 group by drt.corporate_id,
          drt.product_id,
          drt.product_desc,
          drt.qty_unit_id,
          drt.qty_unit;    
 
/

create or replace view v_pci_multiple_premium as
select pcm.contract_ref_no,
       pcdi.pcdi_id,
       pcm.internal_contract_ref_no,
       pci.pcpq_id,
       stragg(distinct
              pcqpd.premium_disc_value || ' ' || pum.price_unit_name) premium
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pci_physical_contract_item     pci,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units        ppu,
       pum_price_unit_master          pum,
       
       pcpdqd_pd_quality_details pcpdqd
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.pcpq_id = pcpdqd.pcpq_id
   and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
   --and pcm.contract_ref_no = 'PC-5-TrxSA'
 group by pcm.contract_ref_no,
          pcm.internal_contract_ref_no,
          pcpdqd.pcpq_id,
          pci.pcpq_id,
          pcdi.pcdi_id
/

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
       --pcdiqd_di_quality_details pcdiqd,
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
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
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
       --pcdiqd_di_quality_details pcdiqd,
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
 --and pcdi.pcdi_id = pcdiqd.pcdi_id
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
          pcdi.price_option_call_off_status 
/

declare
fetchqry1 clob := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, internal_doc_ref_no)
   SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                   NVL (pcmac.addn_charge_name,
                        scm.cost_display_name
                       ) AS other_charge_cost_name,
                   ioc.charge_type AS charge_type,
                   NVL (ioc.rate_fx_rate, ioc.flat_amount_fx_rate) AS fx_rate,
                   ioc.quantity AS quantity,
                   NVL (ioc.rate_amount, ioc.flat_amount) AS amount,
                   ioc.amount_in_inv_cur AS invoice_amount,
                   cm.cur_code AS invoice_cur_name,
                   (CASE
                       WHEN ioc.rate_price_unit = ''Bags''
                          THEN cm.cur_code || ''/'' || ''Bag''
                       WHEN scm.cost_component_name IN
                              (''AssayCharge'', ''SamplingCharge'',
                               ''Ocular Inspection Charge'')
                          THEN cm.cur_code || ''/'' || ''Lot''
                       ELSE pum.price_unit_name
                    END
                   ) AS rate_price_unit_name,
                   NVL (ioc.flat_amount,
                        ioc.rate_charge
                       ) AS charge_amount_rate,
                   (CASE
                       WHEN ioc.rate_price_unit = ''Bags''
                          THEN ''Bags''
                       WHEN scm.cost_component_name IN
                              (''AssayCharge'', ''SamplingCharge'',
                               ''Ocular Inspection Charge'')
                          THEN ''Lots''
                       ELSE qum.qty_unit
                    END
                   ) AS quantity_unit,
                   cm_ioc.cur_code AS amount_unit, ?
              FROM is_invoice_summary invs,
                   ioc_invoice_other_charge ioc,
                   cm_currency_master cm,
                   scm_service_charge_master scm,
                   ppu_product_price_units ppu,
                   pum_price_unit_master pum,
                   qum_quantity_unit_master qum,
                   cm_currency_master cm_ioc,
                   pcmac_pcm_addn_charges pcmac
             WHERE invs.internal_invoice_ref_no = ioc.internal_invoice_ref_no
               AND ioc.other_charge_cost_id = scm.cost_id(+)
               AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
               AND ioc.invoice_cur_id = cm.cur_id(+)
               AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
               AND ppu.price_unit_id = pum.price_unit_id(+)
               AND ioc.qty_unit_id = qum.qty_unit_id(+)
               AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
               AND ioc.internal_invoice_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('DGM-DFI-C7','DGM-IOC_C','DGM-IOC_BM') AND DOC_ID NOT IN('CREATE_DC');
  
end;
/


BEGIN

for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 

loop

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-CWNS-&'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CANCEL_WNS_ASSAY', 'CancelWNS', 'N');

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-CWNS-&'||CC.CORPORATE_ID, 'CancelWNS', CC.CORPORATE_ID, 'CANCELWNS-', 1, 
    0,  '-'||CC.CORPORATE_ID, 1, 'N');

Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CANCEL_WNS_ASSAY', 'CANCELWNS-', 0, '-'||CC.CORPORATE_ID);
 

 end loop;

end;
/

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('CancelWNS', 'Cancel WNS Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');


--Added New Coloumn TRADING_MINING_COMB_TYPE 

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30));

ALTER TABLE GMRUL_GMR_UL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30));

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD add (
  CONSTRAINT CHK_GMR_TRADING_MINING_COMB
 CHECK (TRADING_MINING_COMB_TYPE IN ('Trading','Mining','Combined')));
 
 
ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE GRD_GOODS_RECORD_DETAIL add (
  CONSTRAINT CHK_GRD_TRADING_MINING_COMB
 CHECK (TRADING_MINING_COMB_TYPE IN ('Trading','Mining','Combined')));
 
 
ALTER TABLE DGRD_DELIVERED_GRD ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE DGRDUL_DELIVERED_GRD_UL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE DGRD_DELIVERED_GRD add (
  CONSTRAINT CHK_DGRD_TRADING_MINING_COMB
 CHECK (TRADING_MINING_COMB_TYPE IN ('Trading','Mining','Combined')));



--Added New Coloumn BASE_CONC_MIX_TYPE 

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD (BASE_CONC_MIX_TYPE  VARCHAR2(30));

ALTER TABLE GMRUL_GMR_UL ADD (BASE_CONC_MIX_TYPE  VARCHAR2(30));

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD add (
  CONSTRAINT CHK_GMR_BASE_CONC_MIX_TYPE
 CHECK (BASE_CONC_MIX_TYPE IN ('BASEMETAL','CONCENTRATES','BASECONCMIX')));
 
 
ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD (BASE_CONC_TYPE  VARCHAR2(30)); 

ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD (BASE_CONC_TYPE  VARCHAR2(30)); 

ALTER TABLE GRD_GOODS_RECORD_DETAIL add (
CONSTRAINT CHK_GRD_BASE_CONC_TYPE
 CHECK (BASE_CONC_TYPE IN ('BASEMETAL','CONCENTRATES')));
 
 
ALTER TABLE DGRD_DELIVERED_GRD ADD (BASE_CONC_TYPE  VARCHAR2(30)); 

ALTER TABLE DGRDUL_DELIVERED_GRD_UL ADD (BASE_CONC_TYPE  VARCHAR2(30)); 

ALTER TABLE DGRD_DELIVERED_GRD add (
 CONSTRAINT CHK_DGRD_BASE_CONC_TYPE
 CHECK (BASE_CONC_TYPE IN ('BASEMETAL','CONCENTRATES')));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(PAYABLE_QTY_DISPLAY VARCHAR2(1000 CHAR));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(FREE_METAL_QTY_DISPLAY VARCHAR2(1000 CHAR));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(TC_AMOUNT_DISPLAY VARCHAR2(1000 CHAR));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(RC_AMOUNT_DISPLAY VARCHAR2(1000 CHAR));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(PENALTY_AMOUNT_DISPLAY VARCHAR2(1000 CHAR));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(FREE_METAL_AMOUNT_DISPLAY VARCHAR2(1000 CHAR));

create or replace view v_daily_hedge_correction as
select
         akc.corporate_id,
         akc.corporate_name,
         'Hedge Correction' section,
         7 section_id,
         cpc.profit_center_id,
         cpc.profit_center_short_name profit_center,
         pdm.product_id,
         pdm.product_desc product,
         pcm.contract_type product_type,
         'Y' is_base_metal,
         'N' is_concentrate,
         ppfd.exchange_id,
         ppfd.exchange_name exchange,
         css.strategy_id,
         css.strategy_name strategy,
         decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
         null element_id,
         null element_name,
         pfd.as_of_date trade_date,
         pcm.contract_ref_no,
         pcm.contract_type,
         pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
         gmr.gmr_ref_no gmr_no,
         ((case
            when pcdi.basis_type = 'Arrival' then
                  (case
                   when pcdi.delivery_period_type = 'Date' then
                   pcdi.delivery_to_date
                   else
                   last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                   pcdi.delivery_to_year,'dd-Mon-yyyy'))
                   end) else(case
                   when pcdi.delivery_period_type = 'Date' then
                   pcdi.delivery_to_date
                   else
                   last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                   pcdi.delivery_to_year,'dd-Mon-yyyy'))
                   end) + pcdi.transit_days end))expected_delivery,
         null quality,
         ppfh.formula_description formula,
         null premimum,
         pum.price_unit_id,
         pum.price_unit_name price_unit,
         decode(pcm.purchase_sales, 'P', 1, 'S', -1)*pfd.qty_fixed*
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
         (nvl(pfd.user_price,0)+nvl(pfd.adjustment_price,0)) price,
         cm_pay.cur_code pay_in_ccy,
    (case
     when pfd.is_hedge_correction_during_qp = 'Y' then
      'Within QP'
     else
      'After QP'
         end) sub_section,
         pfd.hedge_correction_date,
         axs.action_id activity_type,
         axs.eff_date activity_date,
         phd.companyname cpname,
         (case
     when pfqpp.qp_pricing_period_type = 'Month' then
      pfqpp.qp_month || ' - ' || pfqpp.qp_year
     when pfqpp.qp_pricing_period_type = 'Event' then
      pfqpp.no_of_event_months || ' ' || pfqpp.event_name
     when pfqpp.qp_pricing_period_type = 'Period' then
      to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
      to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         end) qp,
         null utility_ref_no,
         null smelter
    from pcdi_pc_delivery_item          pcdi,
         pcm_physical_contract_main     pcm,
         poch_price_opt_call_off_header poch,
         pocd_price_option_calloff_dtls pocd,
         pofh_price_opt_fixation_header pofh,
         pfd_price_fixation_details     pfd,
         pcbpd_pc_base_price_detail     pcbpd,
         ppfh_phy_price_formula_header  ppfh,
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
         pfqpp_phy_formula_qp_pricing   pfqpp,
         gmr_goods_movement_record      gmr,
         ak_corporate                   akc,
         ak_corporate_user              akcu,
         pcpd_pc_product_definition     pcpd,
         css_corporate_strategy_setup   css,
         cpc_corporate_profit_center    cpc,
         pdm_productmaster              pdm,
         cm_currency_master             cm_base,
         cm_currency_master             cm_pay,
         v_ppu_pum                      ppu,
         pum_price_unit_master          pum,
         qum_quantity_unit_master       qum,
         axs_action_summary             axs,
         phd_profileheaderdetails       phd
   where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
     and pcdi.pcdi_id = poch.pcdi_id
     and poch.poch_id = pocd.poch_id
     and pocd.pocd_id = pofh.pocd_id
     and pofh.pofh_id = pfd.pofh_id
     and pocd.pcbpd_id = pcbpd.pcbpd_id
     and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
     and ppfh.ppfh_id = ppfd.ppfh_id(+)
     and ppfh.ppfh_id = pfqpp.ppfh_id(+)
     and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no(+)
     and pcm.corporate_id = akc.corporate_id
     and pcm.trader_id = akcu.user_id(+)
     and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
     and pcpd.strategy_id = css.strategy_id
     and pcpd.profit_center_id = cpc.profit_center_id
     and pcpd.product_id = pdm.product_id
     and akc.base_cur_id = cm_base.cur_id
     and pocd.pay_in_cur_id = cm_pay.cur_id
     and pfd.price_unit_id = ppu.product_price_unit_id(+)
     and ppu.price_unit_id = pum.price_unit_id(+)
     and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
     and pfd.hedge_correction_action_ref_no = axs.internal_action_ref_no
     and pcm.cp_id = phd.profileid
     and pcbpd.price_basis <> 'Fixed'
     and pcpd.input_output = 'Input'
     and pcdi.is_active = 'Y'
     and pcm.is_active = 'Y'
     and nvl(gmr.is_deleted, 'N') = 'N'
     and pcm.contract_status <> 'Cancelled'
     and pcm.contract_type = 'BASEMETAL'
     and poch.is_active = 'Y'
     and pocd.is_active = 'Y'
     and pofh.is_active(+) = 'Y'
     and pcbpd.is_active = 'Y'
     and ppfh.is_active(+) = 'Y'
     and pfqpp.is_active(+) = 'Y'
     and pfd.is_hedge_correction = 'Y'
     /*and akc.corporate_id = '{?CorporateID}'
     and pfd.hedge_correction_date = to_date('{?AsOfDate}', 'dd-Mon-yyyy')*/
union all
-- Hedge Correction + Concentrate:
select
         akc.corporate_id,
         akc.corporate_name,
         'Hedge Correction' section,
         7 section_id,
         cpc.profit_center_id,
         cpc.profit_center_short_name profit_center,
         pdm_under.product_id,
         pdm_under.product_desc product,
         pcm.contract_type product_type,
         'Y' is_base_metal,
         'N' is_concentrate,
         ppfd.exchange_id,
         ppfd.exchange_name exchange,
         css.strategy_id,
         css.strategy_name strategy,
         decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
         poch.element_id,
         aml.attribute_name element_name,
         pfd.as_of_date trade_date,
         pcm.contract_ref_no,
         pcm.contract_type,
         pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
         gmr.gmr_ref_no gmr_no,
         ((case
            when pcdi.basis_type = 'Arrival' then
                  (case
                   when pcdi.delivery_period_type = 'Date' then
                   pcdi.delivery_to_date
                   else
                   last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                   pcdi.delivery_to_year,'dd-Mon-yyyy'))
                   end) else(case
                   when pcdi.delivery_period_type = 'Date' then
                   pcdi.delivery_to_date
                   else
                   last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                   pcdi.delivery_to_year,'dd-Mon-yyyy'))
                   end) + pcdi.transit_days end))expected_delivery,
         null quality,
         ppfh.formula_description formula,
         null premimum,
         pum.price_unit_id,
         pum.price_unit_name price_unit,
         decode(pcm.purchase_sales, 'P', 1, 'S', -1)*pfd.qty_fixed*
                                         pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                                                  pdm.product_id),
                                                                                  qum.qty_unit_id,
                                                                                  nvl(pdm_under.base_quantity_unit,
                                                                                  pdm.base_quantity_unit),
                                                                                  1)  qty,
         qum_under.qty_unit_id,
         qum_under.qty_unit,
         qum_under.decimals qty_decimals,
         null instrument,
         null prompt_date,
         null lots,
         (nvl(pfd.user_price,0)+nvl(pfd.adjustment_price,0)) price,
         cm_pay.cur_code pay_in_ccy,
    (case
     when pfd.is_hedge_correction_during_qp = 'Y' then
      'Within QP'
     else
      'After QP'
         end) sub_section,
         pfd.hedge_correction_date,
         axs.action_id activity_type,
         axs.eff_date activity_date,
         phd.companyname cpname,
         (case
     when pfqpp.qp_pricing_period_type = 'Month' then
      pfqpp.qp_month || ' - ' || pfqpp.qp_year
     when pfqpp.qp_pricing_period_type = 'Event' then
      pfqpp.no_of_event_months || ' ' || pfqpp.event_name
     when pfqpp.qp_pricing_period_type = 'Period' then
      to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
      to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         end) qp,
         null utility_ref_no,
         null smelter
    from pcdi_pc_delivery_item          pcdi,
         pcm_physical_contract_main     pcm,
         poch_price_opt_call_off_header poch,
         aml_attribute_master_list aml,
         pdm_productmaster pdm_under,
         qum_quantity_unit_master qum_under,
         pocd_price_option_calloff_dtls pocd,
         pofh_price_opt_fixation_header pofh,
         pfd_price_fixation_details     pfd,
         pcbpd_pc_base_price_detail     pcbpd,
         ppfh_phy_price_formula_header  ppfh,
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
         pfqpp_phy_formula_qp_pricing   pfqpp,
         gmr_goods_movement_record      gmr,
         ak_corporate                   akc,
         ak_corporate_user              akcu,
         pcpd_pc_product_definition     pcpd,
         css_corporate_strategy_setup   css,
         cpc_corporate_profit_center    cpc,
         pdm_productmaster              pdm,
         cm_currency_master             cm_base,
         cm_currency_master             cm_pay,
         v_ppu_pum                      ppu,
         pum_price_unit_master          pum,
         qum_quantity_unit_master       qum,
         axs_action_summary             axs,
         phd_profileheaderdetails       phd
   where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
     and pcdi.pcdi_id = poch.pcdi_id
     and poch.element_id = aml.attribute_id
     and aml.underlying_product_id = pdm_under.product_id(+)
     and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
     and poch.poch_id = pocd.poch_id
     and pocd.pocd_id = pofh.pocd_id
     and pofh.pofh_id = pfd.pofh_id
     and pocd.pcbpd_id = pcbpd.pcbpd_id
     and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
     and ppfh.ppfh_id = ppfd.ppfh_id(+)
     and ppfh.ppfh_id = pfqpp.ppfh_id(+)
     and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no(+)
     and pcm.corporate_id = akc.corporate_id
     and pcm.trader_id = akcu.user_id(+)
     and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
     and pcpd.strategy_id = css.strategy_id
     and pcpd.profit_center_id = cpc.profit_center_id
     and pcpd.product_id = pdm.product_id
     and akc.base_cur_id = cm_base.cur_id
     and pocd.pay_in_cur_id = cm_pay.cur_id
     and pfd.price_unit_id = ppu.product_price_unit_id(+)
     and ppu.price_unit_id = pum.price_unit_id(+)
     and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
     and pfd.hedge_correction_action_ref_no = axs.internal_action_ref_no
     and pcm.cp_id = phd.profileid
     and pcbpd.price_basis <> 'Fixed'
     and pcpd.input_output = 'Input'
     and pcdi.is_active = 'Y'
     and pcm.is_active = 'Y'
     and nvl(gmr.is_deleted, 'N') = 'N'
     and pcm.contract_status <> 'Cancelled'
     and pcm.contract_type = 'CONCENTRATES'
     and poch.is_active = 'Y'
     and pocd.is_active = 'Y'
     and pofh.is_active(+) = 'Y'
     and pcbpd.is_active = 'Y'
     and ppfh.is_active(+) = 'Y'
     and pfqpp.is_active(+) = 'Y'
     and pfd.is_hedge_correction = 'Y'

/

create or replace view v_daily_fx_exposure_vat as
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Vat' section,
       null sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       iis.invoice_issue_date trade_date, --pcm.issue_date trade_date,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                cm_base.cur_id,
                                                cm_pay.cur_id,
                                                iis.invoice_issue_date,
                                                1) fx_rate,
       pcm.contract_ref_no,
       iis.invoice_ref_no,
       iis.vat_parent_ref_no parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pcdi.delivery_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       null element_name,
       null currency_pair,
       iis.payment_due_date expected_payment_due_date,
       null qp_start_date,
       null qp_end_date,
       null qp,
       null delivery_month,
       pym.payment_term payment_terms,
       null qty,
       null qty_unit,
       null qty_unit_id,
       null qty_decimals,
       null price,
       null price_unit_id,
       null price_unit,
       iis.payable_receivable,
       (decode(iis.payable_receivable, 'Payable', -1, 'Receivable', 1) *
       ivd.vat_amount_in_vat_cur) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date,
       iis.invoice_issue_date correction_date,
       null activity_type,
       null activity_date,
       null cpname
  from ivd_invoice_vat_details ivd,
       (select iid.internal_contract_item_ref_no,
               iid.internal_contract_ref_no,
               iid.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               sum(iid.invoiced_qty) invoiced_qty
          from iid_invoicable_item_details iid
         where iid.is_active = 'Y'
         group by iid.internal_contract_item_ref_no,
                  iid.internal_contract_ref_no,
                  iid.internal_gmr_ref_no,
                  iid.internal_invoice_ref_no) iid,
       is_invoice_summary iis,
       is_invoice_summary iis1,
       gmr_goods_movement_record gmr,
       pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       ak_corporate akc,
       ak_corporate_user akcu,
       gab_globaladdressbook gab,
       pcpd_pc_product_definition pcpd,
       pym_payment_terms_master pym,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay
 where ivd.internal_invoice_ref_no = iis.internal_invoice_ref_no
   and iis.vat_parent_ref_no = iis1.invoice_ref_no
   and iis1.internal_invoice_ref_no = iid.internal_invoice_ref_no
   and ivd.is_separate_invoice = 'Y'
   and pcm.purchase_sales = 'P'
   and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.input_output = 'Input'
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and ivd.vat_remit_cur_id = cm_pay.cur_id
   and akc.base_cur_id = cm_base.cur_id
   and nvl(ivd.vat_amount_in_vat_cur, 0) <> 0
   and iis.is_active = 'Y'
   and iis1.is_active = 'Y'
   and gmr.is_deleted = 'N'
union all
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Vat' section,
       null sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       iis.invoice_issue_date trade_date, --pcm.issue_date trade_date,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                cm_base.cur_id,
                                                cm_pay.cur_id,
                                                iis.invoice_issue_date,
                                                1) fx_rate,
       pcm.contract_ref_no,
       iis.invoice_ref_no,
       iis.invoice_ref_no parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pcdi.delivery_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       null element_name,
       null currency_pair,
       iis.payment_due_date expected_payment_due_date,
       null qp_start_date,
       null qp_end_date,
       null qp,
       null delivery_month,
       pym.payment_term payment_terms,
       null qty,
       null qty_unit,
       null qty_unit_id,
       null qty_decimals,
       null price,
       null price_unit_id,
       null price_unit,
       iis.payable_receivable,
       (decode(iis.payable_receivable, 'Payable', -1, 'Receivable', 1) *
       (case
         when pcm.purchase_sales = 'S' then
          ivd.vat_amount_in_inv_cur
         else
          nvl(ivd.vat_amount_in_vat_cur, ivd.vat_amount_in_inv_cur)
       end)) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date,
       iis.invoice_issue_date correction_date,
       null activity_type,
       null activity_date,
       null cpname
  from ivd_invoice_vat_details ivd,
       (select iid.internal_contract_item_ref_no,
               iid.internal_contract_ref_no,
               iid.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               sum(iid.invoiced_qty) invoiced_qty
          from iid_invoicable_item_details iid
         where iid.is_active = 'Y'
         group by iid.internal_contract_item_ref_no,
                  iid.internal_contract_ref_no,
                  iid.internal_gmr_ref_no,
                  iid.internal_invoice_ref_no) iid,
       is_invoice_summary iis,
       gmr_goods_movement_record gmr,
       pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       ak_corporate akc,
       ak_corporate_user akcu,
       gab_globaladdressbook gab,
       pcpd_pc_product_definition pcpd,
       pym_payment_terms_master pym,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay
 where ivd.internal_invoice_ref_no = iid.internal_invoice_ref_no
   and iid.internal_invoice_ref_no = iis.internal_invoice_ref_no
   and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.input_output = 'Input'
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and (case when pcm.purchase_sales = 'S' then ivd.invoice_cur_id else
        nvl(ivd.vat_remit_cur_id, ivd.invoice_cur_id) end) = cm_pay.cur_id --for purchase exposure in vat cur and
      --     for sales  eposure in invoice cur
   and akc.base_cur_id = cm_base.cur_id
   and iis.is_active = 'Y'
   and gmr.is_deleted = 'N'
union all ---for sales contract when invoice cur and vat cur are not same   outflow
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Vat' section,
       '' sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       iis.invoice_issue_date trade_date, --pcm.issue_date trade_date,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                cm_base.cur_id,
                                                cm_pay.cur_id,
                                                iis.invoice_issue_date,
                                                1) fx_rate,
       pcm.contract_ref_no,
       iis.invoice_ref_no,
       iis.invoice_ref_no parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pcdi.delivery_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       null element_name,
       null currency_pair,
       iis.payment_due_date expected_payment_due_date,
       null qp_start_date,
       null qp_end_date,
       null qp,
       null delivery_month,
       pym.payment_term payment_terms,
       null qty,
       null qty_unit,
       null qty_unit_id,
       null qty_decimals,
       null price,
       null price_unit_id,
       null price_unit,
       'Payable' payable_receivable,
       (decode(iis.payable_receivable, 'Payable', 1, 'Receivable', -1) * ---for make outflow sales amount
       ivd.vat_amount_in_vat_cur) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date,
       iis.invoice_issue_date correction_date,
       null activity_type,
       null activity_date,
       null cpname
  from ivd_invoice_vat_details ivd,
       (select iid.internal_contract_item_ref_no,
               iid.internal_contract_ref_no,
               iid.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               sum(iid.invoiced_qty)
          from iid_invoicable_item_details iid
         where iid.is_active = 'Y'
         group by iid.internal_contract_item_ref_no,
                  iid.internal_contract_ref_no,
                  iid.internal_gmr_ref_no,
                  iid.internal_invoice_ref_no) iid,
       is_invoice_summary iis,
       gmr_goods_movement_record gmr,
       pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       ak_corporate akc,
       ak_corporate_user akcu,
       gab_globaladdressbook gab,
       pcpd_pc_product_definition pcpd,
       pym_payment_terms_master pym,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay
 where ivd.internal_invoice_ref_no = iid.internal_invoice_ref_no
   and iid.internal_invoice_ref_no = iis.internal_invoice_ref_no
   and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and ivd.vat_remit_cur_id <> ivd.invoice_cur_id --for invoice exposure of sales
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.input_output = 'Input'
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and ivd.vat_remit_cur_id = cm_pay.cur_id
   and pcm.purchase_sales = 'S'
   and akc.base_cur_id = cm_base.cur_id
   and iis.is_active = 'Y'
   and gmr.is_deleted = 'N'
union all --- Free Metal
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Price Fixation' section,
       (case
         when pfqpp.is_qp_any_day_basis = 'Y' then
          'Spot Fixations'
         else
          'Average Fixations'
       end) sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       pfd.as_of_date trade_date, --pcm.issue_date trade_date,
       /* pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                                     cm_base.cur_id,
                                                                     cm_pay.cur_id,
                                                                     pfd.as_of_date,
                                                                     1) fx_rate,*/
       (case
         when pffxd.fx_rate_type = 'Fixed' then
          pffxd.fixed_fx_rate
         else
          pfd.fx_rate
       end) fx_rate,
       pcm.contract_ref_no,
       '' invoice_ref_no,
       '' parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pcdi.delivery_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       aml.attribute_name element_name,
       null currency_pair,
       pcdi.payment_due_date expected_payment_due_date,
       pfqpp.qp_period_from_date qp_start_date,
       pfqpp.qp_period_to_date qp_end_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
       end) qp,
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
       end) + pcdi.transit_days end) delivery_month,
       pym.payment_term payment_terms,
       pfd.qty_fixed qty,
       qum.qty_unit,
       qum.qty_unit_id,
       qum.decimals qty_decimals,
       (nvl(pfd.user_price, 0) + nvl(pfd.adjustment_price, 0)) price,
       pum.price_unit_id,
       pum.price_unit_name price_unit,
       null payable_receivable,
       (case
         when pfd.hedge_amount is null then
          decode(pcm.purchase_sales, 'P', -1, 'S', 1) *
          ((nvl(pfd.user_price, 0) + nvl(pfd.adjustment_price, 0)) /
           nvl(ppu.weight, 1)) *
         /*(round(pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                                              ppu.cur_id,
                                                                              cm_pay.cur_id,
                                                                              pfd.as_of_date,
                                                                              1),
                                     5) **/
          (case
         when pffxd.fx_rate_type = 'Fixed' then
          pffxd.fixed_fx_rate
         else
          pfd.fx_rate
       end) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            pum.weight_unit_id,
                                            pofh.per_day_pricing_qty) else pfd.hedge_amount end) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date,
       decode(pocd.fx_conversion_method,
              null,
              pfd.hedge_correction_date,
              pfd.fx_correction_date) correction_date,
       null activity_type,
       null activity_date,
       null cpname
  from pcdi_pc_delivery_item          pcdi,
       pcm_physical_contract_main     pcm,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       qum_quantity_unit_master       qum_under,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details     pfd,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       pfqpp_phy_formula_qp_pricing   pfqpp,
       gmr_goods_movement_record      gmr,
       -- pcpch_pc_payble_content_header pcpch,
       ak_corporate                 akc,
       ak_corporate_user            akcu,
       gab_globaladdressbook        gab,
       pcpd_pc_product_definition   pcpd,
       pym_payment_terms_master     pym,
       cpc_corporate_profit_center  cpc,
       pdm_productmaster            pdm,
       cm_currency_master           cm_base,
       cm_currency_master           cm_pay,
       v_ppu_pum                    ppu,
       pum_price_unit_master        pum,
       qum_quantity_unit_master     qum,
       pffxd_phy_formula_fx_details pffxd
 where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.is_free_metal_pricing = 'Y'
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and pofh.pofh_id = pfd.pofh_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   and ppfh.ppfh_id = pfqpp.ppfh_id(+)
      --and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
      /* and pcpch.internal_contract_ref_no = pcm.internal_contract_ref_no
                                 and nvl(pcpch.payable_type, 'Payable') = 'Payable'
                                 and poch.element_id = pcpch.element_id*/
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.input_output = 'Input'
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and pocd.pay_in_cur_id = cm_pay.cur_id
   and pfd.price_unit_id = ppu.product_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
   and pcbpd.price_basis <> 'Fixed'
   and pcm.contract_type = 'CONCENTRATES'
      -- and pcm.approval_status = 'Approved'
   and (case when pcm.is_tolling_contract = 'Y' then
        nvl(pcm.approval_status, 'Approved') else pcm.approval_status end) =
       'Approved'
   and pcdi.is_active = 'Y'
   and pcm.is_active = 'Y'
   and nvl(gmr.is_deleted, 'N') = 'N'
   and pcm.contract_status <> 'Cancelled'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active(+) = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active(+) = 'Y'
   and pfqpp.is_active(+) = 'Y'
   and pym.is_active = 'Y'
   and pym.is_deleted = 'N'
   and pcbpd.pffxd_id = pffxd.pffxd_id -- Newly Added
   and pffxd.is_active = 'Y' -- Newly Added
   and nvl(pfd.is_hedge_correction, 'N') = 'N'
--  and akc.corporate_id = '{?CorporateID}'
--  and to_char(pfd.as_of_date, 'dd-Mon-yyyy') = '{?AsOfDate}'
union all
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Hedge Corrections' section,
       (case
         when pfd.is_hedge_correction_during_qp = 'Y' then
          'Within QP'
         else
          'After QP'
       end) sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       aml.underlying_product_id product_id,
       pdm.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       pfd.as_of_date trade_date,
       (case
         when pffxd.fx_rate_type = 'Fixed' then
          pffxd.fixed_fx_rate
         else
          pfd.fx_rate
       end) fx_rate,
       pcm.contract_ref_no,
       null invoice_ref_no,
       null parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pcdi.delivery_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       null element_name,
       null currency_pair,
       pcdi.payment_due_date expected_payment_due_date,
       pfqpp.qp_period_from_date qp_start_date,
       pfqpp.qp_period_to_date qp_end_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
       end) qp,
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
       end) + pcdi.transit_days end) delivery_month,
       pym.payment_term payment_terms,
       pfd.qty_fixed qty,
       qum.qty_unit,
       qum.qty_unit_id,
       qum.decimals qty_decimals,
       pfd.user_price price,
       pum.price_unit_id,
       pum.price_unit_name price_unit,
       null payable_receivable,
       pfd.hedge_amount hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date,
       decode(pocd.fx_conversion_method,
              null,
              pfd.hedge_correction_date,
              pfd.fx_correction_date) correction_date,
       axs.action_id activity_type,
       axs.eff_date activity_date,
       phd.companyname cpname
  from pcdi_pc_delivery_item          pcdi,
       pcm_physical_contract_main     pcm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details     pfd,
       pcbpd_pc_base_price_detail     pcbpd,
       pffxd_phy_formula_fx_details   pffxd, -- Newly Added
       ppfh_phy_price_formula_header  ppfh,
       pfqpp_phy_formula_qp_pricing   pfqpp,
       gmr_goods_movement_record      gmr,
       ak_corporate                   akc,
       ak_corporate_user              akcu,
       gab_globaladdressbook          gab,
       pcpd_pc_product_definition     pcpd,
       pym_payment_terms_master       pym,
       cpc_corporate_profit_center    cpc,
       pdm_productmaster              pdm,
       cm_currency_master             cm_base,
       cm_currency_master             cm_pay,
       v_ppu_pum                      ppu,
       pum_price_unit_master          pum,
       qum_quantity_unit_master       qum,
       axs_action_summary             axs,
       phd_profileheaderdetails       phd,
       aml_attribute_master_list      aml
 where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and pofh.pofh_id = pfd.pofh_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pffxd_id = pffxd.pffxd_id -- Newly Added
   and pffxd.is_active = 'Y' -- Newly Added
   and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   and ppfh.ppfh_id = pfqpp.ppfh_id(+)
   and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no(+)
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and poch.element_id=aml.attribute_id
   and aml.underlying_product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and pocd.pay_in_cur_id = cm_pay.cur_id
   and pfd.price_unit_id = ppu.product_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
   and pfd.hedge_correction_action_ref_no = axs.internal_action_ref_no
   and pcm.cp_id = phd.profileid
   and pcbpd.price_basis <> 'Fixed'
      --and pcm.approval_status = 'Approved'
   and pcpd.input_output = 'Input'
   and pcdi.is_active = 'Y'
   and pcm.is_active = 'Y'
   and nvl(gmr.is_deleted, 'N') = 'N'
   and pcm.contract_status <> 'Cancelled'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active(+) = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active(+) = 'Y'
   and pfqpp.is_active(+) = 'Y'
   and pym.is_active = 'Y'
   and pym.is_deleted = 'N'
   and pfd.is_hedge_correction = 'Y'
-- and akc.corporate_id = '{?CorporateID}'
-- and to_char(pfd.as_of_date, 'dd-Mon-yyyy') = '{?AsOfDate}'
/


declare
fetchqry1 clob := 'INSERT INTO IS_D(
INVOICE_REF_NO,
INVOICE_TYPE_NAME,
INVOICE_CREATION_DATE,
INVOICE_QUANTITY,
INVOICED_QTY_UNIT,
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
MATERIAL_COST,
ADDDITIONAL_CHARGES,
TAXES,
DUE_DATE,
SUPPLIRE_INVOICE_NO,
CONTRACT_DATE,
CONTRACT_REF_NO,
STOCK_QUANTITY,
STOCK_REF_NO,
INVOICE_AMOUNT_UNIT,
GMR_REF_NO,
GMR_QUALITY,
CONTRACT_QUANTITY,
CONTRACT_QTY_UNIT,
CONTRACT_TOLERANCE,
QUALITY,
PRODUCT,
CP_CONTRACT_REF_NO,
PAYMENT_TERM,
GMR_FINALIZE_QTY,
CP_NAME,
CP_ADDRESS,
CP_COUNTRY,
CP_CITY,
CP_STATE,
CP_ZIP,
CONTRACT_TYPE,
ORIGIN,
INCO_TERM_LOCATION,
NOTIFY_PARTY,
SALES_PURCHASE,
INVOICE_STATUS,
IS_FREE_METAL,
IS_PLEDGE,
INTERNAL_COMMENTS,
INTERNAL_DOC_REF_NO
)
select
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME as INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE as INVOICE_CREATION_DATE,
INVS.INVOICED_QTY as INVOICE_QUANTITY,
QUM_GMR.QTY_UNIT as INVOICED_QTY_UNIT,
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ as MATERIAL_COST,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as ADDDITIONAL_CHARGES,
INVS.TOTAL_TAX_AMOUNT as TAXES,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
INVS.CP_REF_NO as SUPPLIER_INVOICE_NO,
PCM.ISSUE_DATE as CONTRACT_DATE,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
sum(II.INVOICABLE_QTY) as STOCK_QUANTITY,
stragg(distinct II.STOCK_REF_NO) as STOCK_REF_NO,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
stragg(distinct GMR.GMR_REF_NO) as GMR_REF_NO,
sum(GMR.QTY) as GMR_QUALITY,
PCPD.QTY_MAX_VAL as CONTRACT_QUANTITY,
QUM.QTY_UNIT as CONTRACT_QTY_UNIT,
PCPD.MAX_TOLERANCE as CONTRACT_TOLERANCE,
QAT.QUALITY_NAME as QUALITY,
PDM.PRODUCT_DESC as PRODUCT,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM as PAYMENT_TERM,
GMR.FINAL_WEIGHT as GMR_FINALIZE_QTY,
PHD.COMPANYNAME as CP_NAME,
PAD.ADDRESS as CP_ADDRESS,
CYM.COUNTRY_NAME as CP_COUNTRY,
CIM.CITY_NAME as CP_CITY,
SM.STATE_NAME as CP_STATE,
PAD.ZIP as CP_ZIP,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME as ORIGIN,
PCI.TERMS as INCO_TERM_LOCATION,
nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME) as NOTIFY_PARTY, 
PCI.CONTRACT_TYPE as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
INVS.IS_FREE_METAL as IS_FREE_METAL,
INVS.IS_PLEDGE as IS_PLEDGE,
INVS.INTERNAL_COMMENTS as INTERNAL_COMMENTS,
?
from 
IS_INVOICE_SUMMARY invs,
IID_INVOICABLE_ITEM_DETAILS iid,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
II_INVOICABLE_ITEM ii,
CM_CURRENCY_MASTER cm,
GMR_GOODS_MOVEMENT_RECORD gmr,
PCPD_PC_PRODUCT_DEFINITION pcpd,
QUM_QUANTITY_UNIT_MASTER qum,
PCPQ_PC_PRODUCT_QUALITY pcpq,
QAT_QUALITY_ATTRIBUTES qat,
PDM_PRODUCTMASTER pdm,
PHD_PROFILEHEADERDETAILS phd,
PYM_PAYMENT_TERMS_MASTER pym,
PAD_PROFILE_ADDRESSES pad,
CYM_COUNTRYMASTER cym,
CIM_CITYMASTER cim,
SM_STATE_MASTER sm,
BPAT_BP_ADDRESS_TYPE bpat,
CYM_COUNTRYMASTER cymloading,
SAD_SHIPMENT_ADVICE sad,
SD_SHIPMENT_DETAIL sd,
PHD_PROFILEHEADERDETAILS phd1,
PHD_PROFILEHEADERDETAILS phd2,
QUM_QUANTITY_UNIT_MASTER qum_gmr
where
INVS.INTERNAL_INVOICE_REF_NO = IID.INTERNAL_INVOICE_REF_NO
and IID.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO
and IID.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and IID.INVOICABLE_ITEM_ID = II.INVOICABLE_ITEM_ID
and IID.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INVOICE_CURRENCY_ID = CM.CUR_ID
and II.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INTERNAL_CONTRACT_REF_NO = PCPD.INTERNAL_CONTRACT_REF_NO
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID
and PCPD.PCPD_ID = PCPQ.PCPD_ID
and PCI.QUALITY_ID = QAT.QUALITY_ID
and PCPQ.QUALITY_TEMPLATE_ID = QAT.QUALITY_ID
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and INVS.CP_ID = PHD.PROFILEID
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID
and PHD.PROFILEID = PAD.PROFILE_ID(+)
and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.NOTIFY_PARTY_ID = PHD1.PROFILEID(+)
and SD.NOTIFY_PARTY_ID = PHD2.PROFILEID(+)
and INVS.INVOICED_QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.IS_DELETED(+) = ''N''
and PAD.ADDRESS_TYPE(+) = ''Billing''
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
INVS.INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE,
INVS.INVOICED_QTY,
INVS.INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
INVS.TOTAL_TAX_AMOUNT,
INVS.PAYMENT_DUE_DATE,
INVS.CP_REF_NO,
PCM.ISSUE_DATE,
PCM.CONTRACT_REF_NO,
CM.CUR_CODE,
PCPD.QTY_MAX_VAL,
QUM.QTY_UNIT,
PCPD.MAX_TOLERANCE,
QAT.QUALITY_NAME,
PDM.PRODUCT_DESC,
PCM.CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM,
GMR.FINAL_WEIGHT,
PHD.COMPANYNAME,
PAD.ADDRESS,
CYM.COUNTRY_NAME,
CIM.CITY_NAME,
SM.STATE_NAME,
PAD.ZIP,
PCM.CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME,
PCI.TERMS,
PHD1.COMPANYNAME,
PHD2.COMPANYNAME,
QUM_GMR.QTY_UNIT,
PCI.CONTRACT_TYPE,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ,
INVS.INVOICE_STATUS,
INVS.IS_FREE_METAL,
INVS.IS_PLEDGE,
INVS.INTERNAL_COMMENTS';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('CREATE_CFI');
  
end;

/

ALTER TABLE IS_D MODIFY (GMR_REF_NO varchar2(4000));
ALTER TABLE IS_D MODIFY (STOCK_REF_NO varchar2(4000));
alter table HCD_HEDGE_CORRECTION_DETAILS add EVENT_SEQUENC_NO varchar(30);

alter table QAT_QUALITY_ATTRIBUTES MODIFY (QUALITY_NAME VARCHAR2(200))
/
alter table QAV_QUALITY_ATTRIBUTE_VALUES MODIFY (ATTRIBUTE_TEXT VARCHAR2(200))
/


Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('PYM_PAYMENT_TERMS_MASTER', 'Base Date', 'BASE_DATE', NULL, 0, 
    'BASE_DATE', 5, 'baseDate')
/

Insert into ITCM_IMP_TABLE_COLUMN_MAPPING
   (FILE_TYPE_ID, FILE_COLUMN_NAME, DB_COLUMN_NAME, REMARKS, MIN_VALUE, 
    MAPPED_COLUMN_NAME, COLUMN_ORDER, PROPERTY_NAME)
 Values
   ('PYM_PAYMENT_TERMS_MASTER', 'Is EOW Term', 'IS_EOW_TERM', NULL, NULL, 
    NULL, 6, 'isEowTerm')
/

Insert into TRCD_REF_COL_DESC_DETAILS
   (TRCD_ID, MAIN_TABLE_NAME, MAIN_TABLE_COLUMN_NAME, IS_STANDARD_COLUMN, STANDARD_COLUMN_TYPE, 
    QUERY_ID)
 Values
   ('1345', 'PYM_PAYMENT_TERMS_MASTER', 'BASE_DATE', 'N', NULL, 
    '185')
/

UPDATE ifm_import_file_master ifm
   SET ifm.column_model =
          '[{header: "Line No", width: 100, sortable: false,  dataIndex: "lineNo"},{header: "Bad Record", width: 100, sortable: true,renderer:processBadRecord,  dataIndex: "isBadRecord"},{header:"Payterm Text", width: 100, sortable: false,  dataIndex:"property1"},{header:"Payterm Long Name", width: 100, sortable: false,  dataIndex:"property2"},{header:"Number Of Credit Days", width: 100, sortable: false,  dataIndex:"property3"},{header:"Payment Term", width: 100, sortable: false,  dataIndex:"property4"},{header:"Base Date", width: 100, sortable: false,  dataIndex:"property5"},{header:"Is EOW Term", width: 100, sortable: false,  dataIndex:"property6"}]',
       ifm.record_model =
          '[{name: "lineNo", mapping: "lineNo"},{name: "isBadRecord", mapping: "isBadRecord"},{name: "property1", mapping: "property1"},{name: "property2", mapping: "property2"},{name: "property3", mapping: "property3"},{name: "property4", mapping: "property4"},{name: "property5", mapping: "property5"},{name: "property6", mapping: "property6"}]',
       ifm.insert_query =
          'insert into IVR_IMPORT_VALID_RECORD(TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6) values(?,?,?,?,?,?,?,?,?)',
       ifm.select_query =
          'rn,count(*) over() TOTAL_NO_OF_RECORDS,TRANSACTION_ID,LINE_NO,IS_BAD_RECORD,property1,property2,property3,property4,property5,property6 from IVR_IMPORT_VALID_RECORD'
 WHERE ifm.file_type_id = 'PYM_PAYMENT_TERMS_MASTER'
/


ALTER TABLE AUMHP_ANALYTICS_UMHP
 ADD (USER_ID  VARCHAR2(15 CHAR))
/

ALTER TABLE AUMHP_ANALYTICS_UMHP ADD (
  CONSTRAINT FK_AUMHP_USER_ID 
 FOREIGN KEY (USER_ID) 
 REFERENCES AK_CORPORATE_USER (USER_ID))
/

update AUMHP_ANALYTICS_UMHP aumhp
set AUMHP.PANEL_NAME = 'P & L <a href="/iekaDashboardPage.do?method=getPortalMetadataJson&portalId=PRTLM-101"><img src="/private/images/bidashboard.gif" width="16" height="16"/></a> <a href="/ekaBI/biSpecificAction.do?method=getBIPage&URL_PROPERTY=UMURL"><img src="/private/images/bimanager.png" width="16" height="16"/></a>'
where AUMHP.AUMHP_ID = 'AUMHP-2'
/

ALTER TABLE SLD_STORAGE_LOCATION_DETAIL
MODIFY(STORAGE_LOCATION_NAME VARCHAR2(50 CHAR))
/

ALTER TABLE SM_STATE_MASTER
MODIFY(STATE_CODE VARCHAR2(6 CHAR))
/

alter table HCD_HEDGE_CORRECTION_DETAILS add EVENT_SEQUENC_NO varchar(30);
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('FX_OPTION_TRADES', 'Fx Option Trades List', '[
 {header: "Trade Ref No",  width: 100, sortable: true, dataIndex: "tradeRefNo"},
{header: "Trade Date",  width: 100, sortable: true, dataIndex: "tradeDate"},
{header: "External Trade Ref No",  width: 100, sortable: true, dataIndex: "externalRefNo"},
{header: "Instrument", width: 120, sortable: true, dataIndex: "exchangeInstrument"},
{header: "Underlying Instrument", width: 120, sortable: true, dataIndex: "underlyingInstrumentName"},
{header: "Trader", width: 120, sortable: true, dataIndex: "traderName"},
{header: "Option Call/Put", width: 120, sortable: true,align:"right", dataIndex: "optionCallPut"},
{header: "Trade Type - FX Trade 1", width: 120, sortable: true,align:"right", dataIndex: "tradeType"},
{header: "Option Type", width: 120, sortable: true, dataIndex: "optionType"},
{header: "Foregin Currency", width: 120, sortable: true,align:"right", dataIndex: "frgnCurrency"},
{header: "Foregin Currency Amount", width: 120, sortable: true,align:"right", dataIndex: "frgnCurrencyAmount"},
{header: "Profit Center", width: 150, sortable: true, dataIndex: "profitCenterName"},
{header: "Strategy", width: 150, sortable: true,align:"right", dataIndex: "strategy"},
{header: "Base Currency", width: 150, sortable: true, dataIndex: "baseCurrency"},
{header: "Expiry Date", width: 150, sortable: true, dataIndex: "expiryDate"},
{header: "Option Premium", width: 150, sortable: true, dataIndex: "premiumString"},
{header: "Strike Rate", width: 150, sortable: true, dataIndex: "strikeRate"},
{header: "Status", width: 150, sortable: true, dataIndex: "status"},
{header: "Created By", width: 150, sortable: true, dataIndex: "createdBy"},
{header: "Created Date", width: 150, sortable: true, dataIndex: "createdOn"}]', 'Treasury', '/cdc/loadListingPage.action?gridId=FX_OPTION_TRADES', 
    '
        
        
        [
             {name: "internalTreasuryRefNo", mapping: "internalTreasuryRefNo"},
            {name: "externalRefNo", mapping: "externalRefNo"}, 
            {name: "tradeDate", mapping: "tradeDate"},
            {name: "tradeRefNo", mapping: "tradeRefNo"},
            {name: "instrument", mapping: "instrument"},
            {name: "exchangeInstrument", mapping: "exchangeInstrument"},
            {name: "underlyingInstrumentName", mapping: "underlyingInstrumentName"},   
            {name: "traderName", mapping: "traderName"},   
            {name: "optionCallPut", mapping: "optionCallPut"},
            {name: "optionType", mapping: "optionType"},             
            {name: "currencyPairName", mapping: "currencyPairName"},
            {name: "tradeType", mapping: "tradeType"},
            {name: "frgnCurrency", mapping: "frgnCurrency"},
            {name: "frgnCurrencyAmount", mapping: "frgnCurrencyAmount"},
            {name: "exchangeRate", mapping: "exchangeRate"},
            {name: "valueDate", mapping: "valueDate"},
            {name: "baseCurrencyAmount", mapping: "baseCurrencyAmount"},
            {name: "strategy", mapping: "strategy"},
            {name: "baseCurrency", mapping: "baseCurrency"},
            {name: "expiryDate", mapping: "expiryDate"},
            {name: "premiumString", mapping: "premiumString"},
            {name: "strikeRate", mapping: "strikeRate"},
            {name: "profitCenterName", mapping: "profitCenterName"},
            {name: "status", mapping: "status"},
            {name: "createdBy", mapping: "createdBy"},
            {name: "createdOn", mapping: "createdOn"}
        ]', NULL, 'trademanagement/treasury/FxOptionTradeListing.jsp', '/private/js/trademanagement/treasury/FxOptionTradeListing.js')
/
 

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FX_OPTION_TRADES-01', 'FX_OPTION_TRADES', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FX_OPTION_TRADES-02', 'FX_OPTION_TRADES', 'Exercise', 1, 2, 
    NULL, 'function(){exerciseFxOptionTrade();}', NULL, 'FX_OPTION_TRADES-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FX_OPTION_TRADES-03', 'FX_OPTION_TRADES', 'Mark as Expired', 2, 2, 
    NULL, 'function(){markAsExpired();}', NULL, 'FX_OPTION_TRADES-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FX_OPTION_TRADES-04', 'FX_OPTION_TRADES', 'Verify', 3, 2, 
    NULL, 'function(){verifyFxOptionTrades();}', NULL, 'FX_OPTION_TRADES-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FX_OPTION_TRADES-05', 'FX_OPTION_TRADES', 'Unverify', 4, 2, 
    NULL, 'function(){unVerifyFxOptionTrades();}', NULL, 'FX_OPTION_TRADES-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FX_OPTION_TRADES-06', 'FX_OPTION_TRADES', 'Delete', 5, 2, 
    NULL, 'function(){deleteFxOptionTrades();}', NULL, 'FX_OPTION_TRADES-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FX_OPTION_TRADES-07', 'FX_OPTION_TRADES', 'Modify', 6, 2, 
    NULL, 'function(){modifyFxOptionTrade();}', NULL, 'FX_OPTION_TRADES-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FX_OPTION_TRADES-08', 'FX_OPTION_TRADES', 'Copy', 7, 2, 
    NULL, 'function(){copyFxOptionTrade();}', NULL, 'FX_OPTION_TRADES-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FX_OPTION_TRADES-09', 'FX_OPTION_TRADES', 'View', 8, 2, 
    NULL, 'function(){viewFxOptionTradeDetails();}', NULL, 'FX_OPTION_TRADES-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FX_OPTION_TRADES-10', 'FX_OPTION_TRADES', 'Import Fx Option Trade', 9, 2, 
    NULL, 'function(){importFxTrade();}', NULL, 'FX_OPTION_TRADES-01', NULL)
/
 
SET DEFINE OFF;
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FX_TRADES-13', 'FX_TRADES', 'Import Fx Trades', 10, 2, 
    NULL, 'function(){importFxTrade();}', NULL, 'FX_TRADES-01', NULL);
COMMIT;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(TOTAL_INVOICE_AMOUNT VARCHAR2(500 CHAR));
 
 
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(PARENT_INVOICE_AMOUNT VARCHAR2(500 CHAR));

BEGIN
for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 
loop


 Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-CHC-&'||CC.CORPORATE_ID, 'CHCRefNo', CC.CORPORATE_ID, 'HC-', 1, 
    0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-CHC-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CREATE_HEDGE_CORRECTION', 'CHCRefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CREATE_HEDGE_CORRECTION', 'HC-', 0, '-'||CC.CORPORATE_ID);

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-'||CC.CORPORATE_ID, 'ASYCRefNo', CC.CORPORATE_ID, 'ASY-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CANCEL_ASSAY', 'ASYCRefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CANCEL_ASSAY', 'ASY-', 0, '-'||CC.CORPORATE_ID);


 end loop;
end;


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('CREATE_HEDGE_CORRECTION', 'HedgeCorr', 'Create Hedge Correction', 'Y', 'Create Hedge Correction', 
    'N');
    
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_HEDGE_CORRECTION', 'Y', 'N', 'hedgeCorrectionDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('CHCRefNo', 'Hedge Correction Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');
    

 Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('CANCEL_ASSAY', 'Assay ', 'Cancel Assay', 'Y', 'Cancel Assay', 
    'N');
    
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('ASYCRefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

commit;    
alter table HCD_HEDGE_CORRECTION_DETAILS add EVENT_SEQUENC_NO varchar(30);
CREATE TABLE PL_PRICE_LOG
(
  INTERNAL_GMR_CONTRACT_REF_NO  VARCHAR2(15 CHAR),
  ELEMENT_ID                    VARCHAR2(15 CHAR),
  TRADE_DATE                    DATE,
  PRICE                         NUMBER,
  PRICE_UNIT_ID                 VARCHAR2(15 CHAR),
  PROCESS_RUN_DATE              TIMESTAMP(6),
  REMARKS                       VARCHAR2(1000 CHAR),
  GMR_CONTRACT                  VARCHAR2(10 CHAR));


INSERT INTO ien_interface_entity_name_eifc
            (entity_id, entity_code, entity_name
            )
     VALUES (seq_ien.NEXTVAL, 'PILE_DETAILS', 'Pile Details'
            );

INSERT INTO ien_interface_entity_name_eifc
            (entity_id, entity_code, entity_name
            )
     VALUES (seq_ien.NEXTVAL, 'PILE_STATUS', 'Pile Status'
            );